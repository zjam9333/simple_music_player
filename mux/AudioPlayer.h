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

@interface AudioPlayer : UIResponder

+(instancetype)sharedAudioPlayer;

@property (nonatomic,strong) MPMediaItem* playingMediaItem;
@property (nonatomic,strong) MPMediaPlaylist* playingList;

@property (readonly) BOOL hasSongPlay;

-(void)setPlayingMediaItem:(MPMediaItem*)item inPlayList:(MPMediaPlaylist*)list;

-(void)play;
-(void)pause;
-(void)playPrevious;
-(void)playNext;

@property (nonatomic,assign) CGFloat progress;

@end
