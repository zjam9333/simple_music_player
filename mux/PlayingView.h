//
//  PlayingView.h
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PlayingViewShowingNotification @"PlayingViewShowingNotification"
#define PlayingViewHidingNotification @"PlayingViewHidingNotification"

@interface PlayingView : UIView

+(instancetype)defaultPlayingView;

@end
