//
//  PlayingController.h
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayingController : UIViewController

@property (nonatomic,strong)NSMutableArray* playingList;
@property (nonatomic,strong)MPMediaItem* currentItem;

+(PlayingController*)sharedInstantype;
+(BOOL)isPlaying;

@end
