//
//  PlayingInfoModel.h
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlayingInfoModel : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* artist;
@property (nonatomic,strong) NSString* album;
@property (nonatomic,strong) UIImage* artwork;
@property (nonatomic,strong) NSNumber* playbackDuration;
@property (nonatomic,strong) NSNumber* currentTime;
@property (nonatomic,strong) NSNumber* playing;

@end
