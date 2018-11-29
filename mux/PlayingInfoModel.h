//
//  PlayingInfoModel.h
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MediaQuery.h"

@interface PlayingInfoModel : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* artist;
@property (nonatomic,strong) NSString* album;
@property (nonatomic,strong) UIImage* artwork;
@property (nonatomic,strong) MPMediaItemArtwork* mediaArtwork;
@property (nonatomic,strong) NSNumber* playbackDuration;
@property (nonatomic,strong) NSNumber* currentTime;
@property (nonatomic,strong) NSNumber* playing;
@property (nonatomic,strong) NSNumber* shuffle;

@property (nonatomic,strong) MPMediaItem* playingItem;
@property (nonatomic,strong) MPMediaPlaylist* playingList;

@end
