//
//  PlayingProgressButton.h
//  mux
//
//  Created by bangju on 2017/9/12.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ProgressState)
{
    ProgressStatePlaying,
    ProgressStatePaused,
    ProgressStateStoped,
};

//@protocol PlayingProgressButtonDelegate <NSObject>
//
//@optional
//-(void)playingProgressButtonDidSelected;
//
//@end

@interface PlayingProgressButton : UIControl

@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign) ProgressState currentState;

//@property (nonatomic,weak) id<PlayingProgressButtonDelegate>delegate;

@end

@interface CircleProgressView : UIView

@property (nonatomic,assign) CGFloat progress;

@end
