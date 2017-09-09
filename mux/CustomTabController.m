//
//  CustomTabController.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "CustomTabController.h"
#import "PlayingView.h"

@interface CustomTabController ()

@end

@implementation CustomTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PlayingView* pv=[PlayingView defaultPlayingView];
    CGRect pvf=pv.frame;
    pvf.origin.y=self.tabBar.frame.origin.y;
    pv.frame=pvf;
    
    [self.view insertSubview:pv belowSubview:self.tabBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playingViewWillHideNotification:) name:PlayingViewHidingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playingViewWillShowNotification:) name:PlayingViewShowingNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playingViewWillHideNotification:(NSNotification*)noti
{
    [UIView animateWithDuration:0.25 animations:^{
        self.tabBar.frame=[self frameForShowingBar:YES];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)playingViewWillShowNotification:(NSNotification*)noti
{
    [UIView animateWithDuration:0.25 animations:^{
        self.tabBar.frame=[self frameForShowingBar:NO];
    } completion:^(BOOL finished) {
        
    }];
}

-(CGRect)frameForShowingBar:(BOOL)showing
{
    CGSize screen=[[UIScreen mainScreen]bounds].size;
    CGSize size=CGSizeMake(screen.width, 49);
    CGPoint origin=CGPointMake(0, 0);
    
    if (showing) {
        origin.y=screen.height-size.height;
    }
    else
    {
        origin.y=screen.height;
    }
    
    CGRect frame=CGRectZero;
    frame.origin=origin;
    frame.size=size;
    
    return frame;
}

@end
