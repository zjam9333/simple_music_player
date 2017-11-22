//
//  AudioPlayer.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayingInfoModel.h"

static AudioPlayer* shared;

const CFTimeInterval scheduledTime=0.5;

const NSString* lastPlayingItemKey=@"fjs09djf0w9ef09ef09ewfoijfsd";
const NSString* lastPlayingListKey=@"0f90eir9023urcjm982ne89u2389";

@interface AudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic,strong) MPMediaItem* playingMediaItem;
@property (nonatomic,strong) MPMediaPlaylist* playingList;
@property (nonatomic,strong) NSArray* songs;
@property (nonatomic,strong) NSMutableArray* playingOrder;

@end

@implementation AudioPlayer
{
    NSTimer* timer;
    AVAudioPlayer* player;
    PlayingInfoModel* currenPlayingInfo;
    BOOL manualPaused;
    NSInteger currentPlayingIndex;
}

+(instancetype)sharedAudioPlayer
{
    if (shared==nil) {
        shared=[[AudioPlayer alloc]init];
    }
    return shared;
}

-(instancetype)init
{
    self=[super init];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        
        timer=[NSTimer scheduledTimerWithTimeInterval:scheduledTime target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate date]];
        
        [self setRemoteCommandCenter];
    }
    return self;
}

-(BOOL)hasSongPlay
{
    return self.playingMediaItem!=nil;
}

-(void)setPlayingMediaItem:(MPMediaItem *)item inPlayList:(MPMediaPlaylist *)list
{
    self.playingList=list;
    [self setPlayMediaItem:item inSongs:list.items];
}

-(void)setPlayMediaItem:(MPMediaItem*)item inSongs:(NSArray*)songs
{
    self.playingMediaItem=item;
    self.songs=songs;
    [[NSNotificationCenter defaultCenter]postNotificationName:AudioPlayerStartMediaPlayNotification object:nil userInfo:nil];
    
    [self rebuildSongsListWithSongs:songs currentItem:item shuffle:[self isShuffle]];
}

-(void)shuffle:(BOOL)shuffle
{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:shuffle] forKey:@"shuffle"];
    currenPlayingInfo.shuffle=[NSNumber numberWithBool:shuffle];
    
    [self rebuildSongsListWithSongs:self.songs currentItem:self.playingMediaItem shuffle:[self isShuffle]];
}

-(BOOL)isShuffle
{
    BOOL shuffle=[[[NSUserDefaults standardUserDefaults]valueForKey:@"shuffle"]boolValue];
    return shuffle;
}

-(void)rebuildSongsListWithSongs:(NSArray*)songs currentItem:(MPMediaItem*)item shuffle:(BOOL)shuffle
{
    self.playingOrder=[NSMutableArray array];
    
    NSArray* orderNow=[self sortedArray:songs shuffle:shuffle];
    
    NSInteger inde=[orderNow indexOfObject:item];
    inde=inde+songs.count;
    
    NSArray* orderOld=[self sortedArray:songs shuffle:shuffle];
    
    [self.playingOrder addObjectsFromArray:orderOld];
    [self.playingOrder addObjectsFromArray:orderNow];
    
    currentPlayingIndex=inde;
}

-(NSArray*)sortedArray:(NSArray*)array shuffle:(BOOL)shuffle
{
    if (shuffle) {
        return [self shuffleArray:array];
    }
    return array;
}

-(NSArray*)shuffleArray:(NSArray*)array
{
    NSMutableArray* shus=[NSMutableArray arrayWithArray:array];
    NSInteger count=shus.count;
    for (NSInteger i=0; i<count; i++) { // how many rounds should be better ?
        if(i>0)
        {
            NSInteger randomIndex=arc4random()%i;
            [shus exchangeObjectAtIndex:randomIndex withObjectAtIndex:i];
        }
    }
    return shus;
}

-(void)setPlayingMediaItem:(MPMediaItem *)playingMediaItem
{
    MPMediaItem* media=playingMediaItem;
    if (media==_playingMediaItem&&self.playing) {
        return;
    }
    _playingMediaItem=media;
    if (media) {
        currenPlayingInfo=[[PlayingInfoModel alloc]init];
        
        currenPlayingInfo.name=media.title;
        currenPlayingInfo.artist=media.artist;
        currenPlayingInfo.album=media.albumTitle;
        currenPlayingInfo.artwork=[media.artwork imageWithSize:CGSizeMake(512, 512)];
        currenPlayingInfo.mediaArtwork=media.artwork;
        currenPlayingInfo.playbackDuration=@(media.playbackDuration);
        currenPlayingInfo.currentTime=@(0);
        currenPlayingInfo.playing=@(YES);
        currenPlayingInfo.shuffle=[[NSUserDefaults standardUserDefaults]valueForKey:@"shuffle"];
        
        currenPlayingInfo.playingItem=self.playingMediaItem;
        currenPlayingInfo.playingList=self.playingList;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:currenPlayingInfo forKey:@"mediaInfo"]];
        
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[media valueForProperty:MPMediaItemPropertyAssetURL] error:nil];
        player.delegate=self;
        player.currentTime=0;
        [self play];
        [self saveLastPlay];
    }
}

-(void)play
{
    manualPaused=NO;
    [self becomeActive];
    [player play];
}

-(void)pause
{
    manualPaused=YES;
    [player pause];
}

-(void)playOrPause
{
    if (player.isPlaying) {
        [self pause];
    }
    else
    {
        [self play];
    }
}

-(void)playNext
{
    NSInteger next=currentPlayingIndex+1;
    if (next>=self.playingOrder.count) {
        [self.playingOrder addObjectsFromArray:[self sortedArray:self.songs shuffle:[self isShuffle]]];
    }
    if (next<self.playingOrder.count) {
        self.playingMediaItem=[self.playingOrder objectAtIndex:next];
        currentPlayingIndex=next;
    }
}

-(void)playPrevious
{
    if (self.currentTime>10) {
        self.currentTime=0;
        return;
    }
    NSInteger pre=currentPlayingIndex-1;
    if (pre>=0&&pre<self.playingOrder.count) {
        self.playingMediaItem=[self.playingOrder objectAtIndex:pre];
        currentPlayingIndex=pre;
    }
}

-(void)handleInterruption:(NSNotification*)notification
{
    NSLog(@"\n\ninterruption: \n%@",notification);
    
    NSDictionary* dict=notification.userInfo;
    AVAudioSessionInterruptionType interruptionType=[[dict valueForKey:AVAudioSessionInterruptionTypeKey]integerValue];
    if (interruptionType==AVAudioSessionInterruptionTypeBegan) {
//        [self pause];
    }
    else if(interruptionType==AVAudioSessionInterruptionTypeEnded)
    {
        if([[dict valueForKey:AVAudioSessionInterruptionOptionKey]integerValue]==AVAudioSessionInterruptionOptionShouldResume)
        {
            if (!manualPaused) {
                [self play];
            }
        }
        
    }
}

-(void)handleRouteChange:(NSNotification*)notification
{
//    NSLog(@"routechange: \n%@",notification);
    
    NSDictionary* userinfo=notification.userInfo;
    
    AVAudioSessionRouteChangeReason reason=[[userinfo valueForKey:AVAudioSessionRouteChangeReasonKey]unsignedIntegerValue];
    
    if (reason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        AVAudioSessionRouteDescription* prevoiusRouteDescription=[userinfo valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription* portDescription=prevoiusRouteDescription.outputs.firstObject;
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self pause];
        }
    }
}

-(void)handleRemoteControlEvent:(UIEvent *)event
{
//    if (event.type==UIEventTypeRemoteControl) {
//        switch (event.subtype) {
//            case UIEventSubtypeRemoteControlPause:
//                [self pause];
//                break;
//            case UIEventSubtypeRemoteControlPlay:
//                [self play];
//                break;
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [self playOrPause];
//                break;
//            case UIEventSubtypeRemoteControlPreviousTrack:
//                [self playPrevious];
//                break;
//            case UIEventSubtypeRemoteControlNextTrack:
//                [self playNext];
//                break;
//            default:
//                break;
//        }
//    }
}

-(void)setRemoteCommandCenter
{
//    return;
    MPRemoteCommandCenter* center=[MPRemoteCommandCenter sharedCommandCenter];
    
    __weak typeof(self) weself=self;
    
    [center.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"%@",event);
        [weself play];
        return weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];
    
    [center.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"%@",event);
        [weself pause];
        return !weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];
    
    [center.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        // 耳机用
        NSLog(@"%@",event);
        BOOL oldIsPlaying=[weself playing];
        [weself playOrPause];
        return oldIsPlaying!=weself.playing?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
    }];

    [center.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"%@",event);
        [weself playNext];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [center.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"%@",event);
        [weself playPrevious];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [center.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"%@",event);
        if ([event isKindOfClass:[MPChangePlaybackPositionCommandEvent class]]) {
            MPChangePlaybackPositionCommandEvent* ev=(MPChangePlaybackPositionCommandEvent*)event;
            NSTimeInterval newPositionTime=ev.positionTime;
            [weself setCurrentTime:newPositionTime];
            return weself.currentTime==newPositionTime?MPRemoteCommandHandlerStatusSuccess:MPRemoteCommandHandlerStatusCommandFailed;
        }  
        return MPRemoteCommandHandlerStatusCommandFailed;
    }];
}

-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    [player setCurrentTime:(progress*player.duration)];
}

-(void)setCurrentTime:(NSTimeInterval)currentTime
{
    [player setCurrentTime:currentTime];
}

-(NSTimeInterval)currentTime
{
    return [player currentTime];
}

-(BOOL)playing
{
    return player.isPlaying;
}

-(void)timerRunning
{
    if (currenPlayingInfo) {
        currenPlayingInfo.currentTime=@(player.currentTime);
        currenPlayingInfo.playbackDuration=@(player.duration);
        currenPlayingInfo.playing=@(player.isPlaying);
        
        currenPlayingInfo.playingItem=self.playingMediaItem;
        currenPlayingInfo.playingList=self.playingList;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:currenPlayingInfo forKey:@"mediaInfo"]];
        
        if (player.isPlaying) {
            NSMutableDictionary* dict=[NSMutableDictionary dictionary];
            [dict setValue:@(player.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [dict setValue:@(player.duration) forKey:MPMediaItemPropertyPlaybackDuration];
            [dict setValue:currenPlayingInfo.name forKey:MPMediaItemPropertyTitle];
            [dict setObject:currenPlayingInfo.artist forKey:MPMediaItemPropertyArtist];
            [dict setObject:currenPlayingInfo.album forKey:MPMediaItemPropertyAlbumTitle];
            [dict setObject:currenPlayingInfo.mediaArtwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter
              defaultCenter] setNowPlayingInfo:dict];
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNext];
}

-(void)becomeActive
{
    [[UIApplication sharedApplication] becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    [[AVAudioSession sharedInstance]setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
}

-(void)saveLastPlay
{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithLongLong:self.playingMediaItem.persistentID] forKey:lastPlayingItemKey.description
     ];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithLongLong:self.playingList.persistentID] forKey:lastPlayingListKey.description
     ];
}

-(void)loadLastPlay
{
//    return;
    MPMediaEntityPersistentID itemID=[[[NSUserDefaults standardUserDefaults]valueForKey:lastPlayingItemKey.description]longLongValue];
    MPMediaEntityPersistentID listID=[[[NSUserDefaults standardUserDefaults]valueForKey:lastPlayingListKey.description]longLongValue];
    
    NSArray* allsongs=[MediaQuery allSongs];
    NSArray* alllists=[MediaQuery allPlaylists];
    
    for (MPMediaItem* item in allsongs) {
        if (item.persistentID==itemID) {
            self.playingMediaItem=item;
            NSLog(@"%@",item);
            for (MPMediaPlaylist* list in alllists) {
                if (list.persistentID==listID) {
                    if ([list.items containsObject:item]) {
                        self.playingList=list;
                        NSLog(@"%@",list);
                        break;
                    }
                }
            }
            
            [self setPlayingMediaItem:self.playingMediaItem inPlayList:self.playingList];
            [self pause];
//            [self performSelector:@selector(pause) withObject:nil afterDelay:0.1];
            
            break;
        }
    }
    
}

@end
