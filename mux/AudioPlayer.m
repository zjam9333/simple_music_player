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

@implementation AudioPlayer
{
    NSTimer* timer;
    AVAudioPlayer* player;
    PlayingInfoModel* currenPlayingInfo;
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
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeDidChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
        [timer setFireDate:[NSDate date]];
    }
    return self;
}

-(void)setPlayingMediaItem:(MPMediaItem *)item inPlayList:(MPMediaPlaylist *)list
{
    _playingMediaItem=item;
    _playingList=list;
    [self playMedia:self.playingMediaItem];
}

-(void)playMedia:(MPMediaItem*)media
{
    if (media) {
        currenPlayingInfo=[[PlayingInfoModel alloc]init];
        
        currenPlayingInfo.name=media.title;
        currenPlayingInfo.artist=media.artist;
        currenPlayingInfo.album=media.albumTitle;
        currenPlayingInfo.artwork=[media.artwork imageWithSize:CGSizeMake(512, 512)];
        currenPlayingInfo.playbackDuration=@(media.playbackDuration);
        currenPlayingInfo.currentTime=@(0);
        currenPlayingInfo.playing=@(YES);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:AudioPlayerPlayingMediaInfoNotification object:nil userInfo:[NSDictionary dictionaryWithObject:currenPlayingInfo forKey:@"mediaInfo"]];
    }
}

-(void)handleInterruption:(NSNotification*)notification
{
    
}

-(void)volumeDidChanged:(NSNotification *)notification
{
   
}

-(void)timerRunning
{
    
}

@end
