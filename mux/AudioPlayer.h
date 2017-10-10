//
//  AudioPlayer.h
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define AudioPlayerPlayingMediaInfoNotification @"AudioPlayerPlayingMediaInfoNotification"
#define AudioPlayerStartMediaPlayNotification @"AudioPlayerStartMediaPlayNotification"

@interface AudioPlayer : NSObject

+(instancetype)sharedAudioPlayer;

@property (readonly,nonatomic) BOOL hasSongPlay;

-(void)setPlayingMediaItem:(MPMediaItem*)item inPlayList:(MPMediaPlaylist*)list;

-(void)play;
-(void)pause;
-(void)playOrPause;
-(void)playPrevious;
-(void)playNext;
-(void)shuffle:(BOOL)shuffle;

-(void)becomeActive;

-(void)handleRemoteControlEvent:(UIEvent *)event;

@property (nonatomic,assign) CGFloat progress;

@end
