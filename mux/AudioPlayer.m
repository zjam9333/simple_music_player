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

@interface AudioPlayer()<AVAudioPlayerDelegate>

@end

@implementation AudioPlayer
{
    NSTimer* timer;
    AVAudioPlayer* player;
    PlayingInfoModel* currenPlayingInfo;
    NSMutableArray* playedMedias;
    BOOL wasPlaying;
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
        timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate date]];
    }
    return self;
}

-(BOOL)hasSongPlay
{
    return self.playingMediaItem!=nil;
}

-(void)setPlayingMediaItem:(MPMediaItem *)item inPlayList:(MPMediaPlaylist *)list
{
    id old=self.playingMediaItem;
    self.playingMediaItem=item;
    self.playingList=list;
    [self playMedia:self.playingMediaItem];
    if (old==nil&&item!=nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:AudioPlayerStartMediaPlayNotification object:nil userInfo:nil];
    }
}

-(void)setPlayingList:(MPMediaPlaylist *)playingList
{
    _playingList=playingList;
    playedMedias=[NSMutableArray array];
}

-(void)shuffle:(BOOL)shuffle
{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:shuffle] forKey:@"shuffle"];
    currenPlayingInfo.shuffle=[NSNumber numberWithBool:shuffle];
}

-(void)playMedia:(MPMediaItem*)media
{
    self.playingMediaItem=media;
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:currenPlayingInfo forKey:@"mediaInfo"]];
        
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[media valueForProperty:MPMediaItemPropertyAssetURL] error:nil];
        player.delegate=self;
        player.currentTime=media.bookmarkTime;
        [self play];
        
        [playedMedias addObject:media];
    }
}

-(void)play
{
    [player play];
    wasPlaying=YES;
}

-(void)pause
{
    [player pause];
    wasPlaying=NO;
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
    BOOL shuffle=[[[NSUserDefaults standardUserDefaults]valueForKey:@"shuffle"]boolValue];
    NSArray* all=[self.playingList items];
    if(shuffle)
    {
        MPMediaItem* next=[all objectAtIndex:(arc4random()%all.count)];
        [self playMedia:next];
    }
    else
    {
        NSInteger currenIndex=self.playingMediaItem?[all indexOfObject:self.playingMediaItem]:0;
        NSInteger nextIndex=currenIndex+1;
        if (nextIndex>=all.count) {
            nextIndex=0;
        }
        MPMediaItem* next=[all objectAtIndex:nextIndex];
        [self playMedia:next];
    }
}

-(void)playPrevious
{
    if (player.currentTime>10) {
        player.currentTime=0;
    }
    else
    {
        [playedMedias removeLastObject];
        if (playedMedias.count>0) {
            MPMediaItem* last=playedMedias.lastObject;
            [playedMedias removeLastObject];
            [self playMedia:last];
        }
        else
        {
            [self playMedia:self.playingMediaItem];
        }
    }
    
}

-(void)handleInterruption:(NSNotification*)notification
{
    NSLog(@"interruption: \n%@",notification);
    NSDictionary* dict=notification.userInfo;
    AVAudioSessionInterruptionType interruptionType=[[dict valueForKey:AVAudioSessionInterruptionTypeKey]integerValue];
    if (interruptionType==AVAudioSessionInterruptionTypeBegan) {
        
    }
    else if(interruptionType==AVAudioSessionInterruptionTypeEnded)
    {
        if([[dict allKeys]containsObject:AVAudioSessionInterruptionOptionKey])
        {
            if([[dict valueForKey:AVAudioSessionInterruptionOptionKey]integerValue]==AVAudioSessionInterruptionOptionShouldResume)
            {
                if(wasPlaying)
                {
                    [player play];
                    [self becomeActive];
                }
            }
        }
    }
}

-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    [player setCurrentTime:(progress*player.duration)];
}

-(void)timerRunning
{
    if (currenPlayingInfo) {
        currenPlayingInfo.currentTime=@(player.currentTime);
        currenPlayingInfo.playbackDuration=@(player.duration);
        currenPlayingInfo.playing=@(player.isPlaying);
        [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:currenPlayingInfo forKey:@"mediaInfo"]];
        if (player.isPlaying) {
            [self becomeActive];
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

@end
