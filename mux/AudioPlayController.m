//
//  AudioPlayer.m
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "AudioPlayController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayingInfoModel.h"
#import "MyAudioPlayer.h"

@interface UIApplication()

- (void)_performMemoryWarning;

@end

static AudioPlayController *_sharedPlayer;

const CFTimeInterval scheduledTime = 0.016;

const NSString *lastPlayingItemKey = @"fjs09djf0w9ef09ef09ewfoijfsd";
const NSString *lastPlayingListKey = @"0f90eir9023urcjm982ne89u2389";

@interface AudioPlayController()<AVAudioPlayerDelegate>

@end

@implementation AudioPlayController {
    // 播放列表相关
    MPMediaItem *_playingMediaItem;
    MPMediaPlaylist *_playingList;
    NSArray *_songs;
    NSMutableArray *_playingOrder;
    NSMutableArray *_cutLineOrder;
    
    // 播放器相关
    NSTimer *_timer;
    MyAudioPlayer *_player;
    PlayingInfoModel *_currenPlayingInfo;
    BOOL _manualPaused;
    NSInteger _currentPlayingIndex;
    
    // 内存警告相关
    NSTimeInterval _lastPlayTime;
    BOOL _wasLowMemory;
}

+ (void)load {
    // 读取最后一次播放的歌单
    [[AudioPlayController sharedAudioPlayer] performSelector:@selector(loadLastPlay) withObject:nil afterDelay:1];
}

+ (instancetype)sharedAudioPlayer {
    if (_sharedPlayer == nil) {
        _sharedPlayer = [[AudioPlayController alloc] init];
    }
    return _sharedPlayer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 处理中断、耳机拔出、内存警告
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        // 定时发送播放状态
        _timer = [NSTimer scheduledTimerWithTimeInterval:scheduledTime target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate date]];
        
        // 设置控制中心与线控
        [self setRemoteCommandCenter];
    }
    return self;
}

#pragma mark - item and list

- (BOOL)hasSongPlay {
    return _playingMediaItem != nil;
}

- (void)playMediaItem:(MPMediaItem *)item inPlayList:(MPMediaPlaylist *)list {
    _playingList = list;
    [self setPlayMediaItem:item inSongs:list.items];
}

- (void)setPlayMediaItem:(MPMediaItem *)item inSongs:(NSArray *)songs {
    [self playMediaItem:item];
    _songs = songs;
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerStartMediaPlayNotification object:nil userInfo:nil];
    
    [self rebuildSongsListWithSongs:songs currentItem:item shuffle:[self isShuffle]];
}

- (void)insertCutMediaItem:(MPMediaItem *)item {
    // 插播列表作用于“play next”方法
    if (_cutLineOrder == nil) {
        _cutLineOrder = [NSMutableArray array];
    }
    if (item) {
        [_cutLineOrder insertObject:item atIndex:0];
    }
}

- (void)shuffle:(BOOL)shuffle {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:shuffle] forKey:@"shuffle"];
    _currenPlayingInfo.shuffle = [NSNumber numberWithBool:shuffle];
    
    [self rebuildSongsListWithSongs:_songs currentItem:_playingMediaItem shuffle:[self isShuffle]];
}

- (BOOL)isShuffle {
    BOOL shuffle = [[[NSUserDefaults standardUserDefaults] valueForKey:@"shuffle"] boolValue];
    return shuffle;
}

- (void)rebuildSongsListWithSongs:(NSArray *)songs currentItem:(MPMediaItem *)item shuffle:(BOOL)shuffle {
    _playingOrder = [NSMutableArray array];
    
    NSArray *orderNow = [self sortedArray:songs shuffle:shuffle];
    
    NSInteger inde = [orderNow indexOfObject:item];
    inde = inde + songs.count;
    
    NSArray *orderOld = [self sortedArray:songs shuffle:shuffle];
    
    [_playingOrder addObjectsFromArray:orderOld];
    [_playingOrder addObjectsFromArray:orderNow];
    
    _currentPlayingIndex = inde;
    
    // 这里为什么这么搞？
    // 为了伪造播放历史，避免点击上一首没有东西
}

- (NSArray *)sortedArray:(NSArray *)array shuffle:(BOOL)shuffle {
    if (shuffle) {
        return [self shuffleArray:array];
    }
    return array;
}

- (NSArray *)shuffleArray:(NSArray *)array {
    NSMutableArray *shus = [NSMutableArray arrayWithArray:array];
    NSInteger count = shus.count;
    for (NSInteger i = 0; i < count; i++) { // how many rounds should be better ?
        if (i > 0) {
            NSInteger randomIndex = arc4random()%i;
            [shus exchangeObjectAtIndex:randomIndex withObjectAtIndex:i];
        }
    }
    return shus;
}

- (void)playMediaItem:(MPMediaItem *)playingMediaItem {
    MPMediaItem *media = playingMediaItem;
    if (media == _playingMediaItem && self.playing) {
        return;
    }
    _playingMediaItem = media;
    if (media) {
        _currenPlayingInfo = [[PlayingInfoModel alloc] init];
        _currenPlayingInfo.url = [media valueForProperty:MPMediaItemPropertyAssetURL];
        _currenPlayingInfo.name = media.title;
        _currenPlayingInfo.artist = media.artist;
        _currenPlayingInfo.album = media.albumTitle;
        _currenPlayingInfo.artwork = [media.artwork imageWithSize:CGSizeMake(512,  512)];
        _currenPlayingInfo.mediaArtwork = media.artwork;
        _currenPlayingInfo.playbackDuration = @(media.playbackDuration);
        _currenPlayingInfo.currentTime = @(0);
        _currenPlayingInfo.playing = @(YES);
        _currenPlayingInfo.shuffle = [[NSUserDefaults standardUserDefaults] valueForKey:@"shuffle"];
        
        _currenPlayingInfo.playingItem = _playingMediaItem;
        _currenPlayingInfo.playingList = _playingList;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:_currenPlayingInfo forKey:@"mediaInfo"]];
        [self removePlayer];
        [self resetLastTimeIfNeed];
        [self createPlayerIfNeed];
        [self play];
        [self saveLastPlay];
    }
}

#pragma mark - play actions

- (void)createPlayerIfNeed {
    if (_player) {
        return;
    }
    NSError *err = nil;
    _player = [[MyAudioPlayer alloc] initWithContentsOfURL:_currenPlayingInfo.url error:&err];
    _player.delegate = self;
    _player.currentTime = 0;
}

- (void)resetLastTimeIfNeed {
    if (_wasLowMemory) {
        _player.currentTime = _lastPlayTime;
    }
    _wasLowMemory = NO;
}

- (void)removePlayer {
    [_player stop];
    _player = nil;
}

- (void)play {
    [self createPlayerIfNeed];
    [self resetLastTimeIfNeed];
    _manualPaused = NO;
    [self becomeActive];
    [_player play];
}

- (void)pause {
    _manualPaused = YES;
    [_player pause];
}

- (void)playOrPause {
    if (_player.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)playNext {
    // 如果有插播内容，就优先播放
    if (_cutLineOrder.count > 0) {
        [self playMediaItem:_cutLineOrder.firstObject];
        [_cutLineOrder removeObject:_playingMediaItem];
        return;
    }
    NSInteger next = _currentPlayingIndex + 1;
    if (next >= _playingOrder.count) {
        [_playingOrder addObjectsFromArray:[self sortedArray:_songs shuffle:[self isShuffle]]];
    }
    if (next < _playingOrder.count) {
        [self playMediaItem:[_playingOrder objectAtIndex:next]];
        _currentPlayingIndex = next;
    }
}

- (void)playPrevious {
//    // test low memory
//    [[UIApplication sharedApplication] _performMemoryWarning];
//    return;
    
    if (self.currentTime > 10) {
        self.currentTime = 0;
        return;
    }
    NSInteger pre = _currentPlayingIndex-1;
    if (pre >= 0 && pre < _playingOrder.count) {
        [self playMediaItem:[_playingOrder objectAtIndex:pre]];
        _currentPlayingIndex = pre;
    }
}

- (void)becomeActive {
    [[UIApplication sharedApplication] becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - handle action and exception

- (void)handleInterruption:(NSNotification *)notification {
//    NSLog(@"\n\ninterruption: \n%@", notification);
    // 其他app播放声音时，可能会触发中断
    NSDictionary *dict = notification.userInfo;
    AVAudioSessionInterruptionType interruptionType = [[dict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self pause];
        _manualPaused = NO;
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        if ([[dict valueForKey:AVAudioSessionInterruptionOptionKey] integerValue] == AVAudioSessionInterruptionOptionShouldResume) {
            if (!_manualPaused) {
                [self play];
            }
        }
    }
}

- (void)handleRouteChange:(NSNotification *)notification {
//    NSLog(@"routechange: \n%@", notification);
    
    NSDictionary *userinfo = notification.userInfo;
    
    AVAudioSessionRouteChangeReason reason = [[userinfo valueForKey:AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *prevoiusRouteDescription = [userinfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = prevoiusRouteDescription.outputs.firstObject;
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self pause]; // 处理耳机拔出
        }
    }
}

- (void)handleMemoryWarning:(NSNotification *)notification {
//    NSLog(@"%@", notification);
    
    // 处理低内存警告，似乎问题不在这里，而是在封面图片缓存那里
    _lastPlayTime = _player.currentTime;
    _wasLowMemory = YES;
    [self removePlayer];
}

#pragma mark - center control

- (void)setRemoteCommandCenter {
//    return;
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];

    __weak typeof(self) weself = self;

    [center.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
//        NSLog(@"%@", event);
        [weself play];
        return weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];

    [center.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
//        NSLog(@"%@", event);
        [weself playOrPause];
        return MPRemoteCommandHandlerStatusSuccess;//!weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];

    [center.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
        // 耳机用
//        NSLog(@"%@", event);
        BOOL oldIsPlaying = [weself playing];
        [weself playOrPause];
        return oldIsPlaying != weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];

    [center.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
//        NSLog(@"%@", event);
        [weself playNext];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [center.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
//        NSLog(@"%@", event);
        [weself playPrevious];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    if (@available(iOS 9.1, *)) {
        [center.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *_Nonnull event) {
            NSLog(@"%@", event);
            if ([event isKindOfClass:[MPChangePlaybackPositionCommandEvent class]]) {
                MPChangePlaybackPositionCommandEvent *ev = (MPChangePlaybackPositionCommandEvent *)event;
                NSTimeInterval newPositionTime = ev.positionTime;
                [weself setCurrentTime:newPositionTime];
                return weself.currentTime == newPositionTime?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
            }
            return MPRemoteCommandHandlerStatusCommandFailed;
        }];
    }
}

#pragma mark - current status

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [_player setCurrentTime:(progress * _player.duration)];
    [self timerRunning];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [_player setCurrentTime:currentTime];
}

- (NSTimeInterval)currentTime {
    return [_player currentTime];
}

- (BOOL)playing {
    return _player.isPlaying;
}

- (void)timerRunning {
    // 定时发送当前状态的通知
    if (_currenPlayingInfo) {
        _currenPlayingInfo.currentTime = @(_player.currentTime);
        _currenPlayingInfo.playbackDuration = @(_player.duration);
        _currenPlayingInfo.playing = @(_player.isPlaying);
        _currenPlayingInfo.playingItem = _playingMediaItem;
        _currenPlayingInfo.playingList = _playingList;
        _currenPlayingInfo.pcmData = _player.pcmData;
        if (_player.isPlaying) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@(_player.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [dict setValue:@(_player.duration) forKey:MPMediaItemPropertyPlaybackDuration];
            [dict setValue:_currenPlayingInfo.name forKey:MPMediaItemPropertyTitle];
            [dict setValue:_currenPlayingInfo.artist forKey:MPMediaItemPropertyArtist];
            [dict setValue:_currenPlayingInfo.album forKey:MPMediaItemPropertyAlbumTitle];
            [dict setValue:_currenPlayingInfo.mediaArtwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter
              defaultCenter] setNowPlayingInfo:dict];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:_currenPlayingInfo forKey:@"mediaInfo"]];
        } else if (arc4random() % 100 < 10) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:_currenPlayingInfo forKey:@"mediaInfo"]];
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"did finish?");
    [self playNext];
}

#pragma mark - last play

- (void)saveLastPlay {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:_playingMediaItem.persistentID] forKey:lastPlayingItemKey.description];
    if (_playingList) {
        [[NSUserDefaults standardUserDefaults] setValue:_playingList.name forKey:lastPlayingListKey.description];
    }
}

- (void)loadLastPlay {
//    return;
    MPMediaEntityPersistentID itemID = [[[NSUserDefaults standardUserDefaults] valueForKey:lastPlayingItemKey.description] longLongValue];
    NSString *listName = [[NSUserDefaults standardUserDefaults] valueForKey:lastPlayingListKey.description];
    
    NSArray *allsongs = [MediaQuery allSongs];
    NSArray *alllists = [MediaQuery allPlaylists];
    
    for (MPMediaItem *item in allsongs) {
        if (item.persistentID == itemID) {
            _playingMediaItem = item;
            NSLog(@"%@", item);
            for (MPMediaPlaylist *list in alllists) {
                if ([list.name isEqualToString:listName]) {
                    if ([list.items containsObject:item]) {
                        _playingList = list;
                        NSLog(@"%@", list);
                        break;
                    }
                }
            }
            
            [self playMediaItem:_playingMediaItem inPlayList:_playingList];
            [self pause];
            _player.currentTime = 0;
//            [self performSelector:@selector(pause) withObject:nil afterDelay:0.1];
            
            break;
        }
    }
    
}

@end
