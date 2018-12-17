//
//  BaseTableViewController.m
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AudioPlayController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)dealloc {
    NSLog(@"dealloc: %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.showsVerticalScrollIndicator=NO;
//    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
//    self.tableView.contentInset=UIEdgeInsetsMake(64, 0, 49, 0);
    if ([[AudioPlayController sharedAudioPlayer]hasSongPlay]) {
        [self mediaStartedPlayingNotification:nil];
    }
    
//    self.tableView.contentOffset=CGPointMake(0, -self.tableView.contentInset.top);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaStartedPlayingNotification:) name:AudioPlayerStartMediaPlayNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMediaInfoNotification:) name:AudioPlayerPlayingMediaInfoNotification object:nil];
}

-(void)mediaStartedPlayingNotification:(NSNotification*)noti
{
//    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 49, 0);
}

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    if ([[UIApplication sharedApplication]applicationState]==UIApplicationStateActive) {
        PlayingInfoModel* info=[noti.userInfo valueForKey:@"mediaInfo"];
        self.currentPlayingInfo=info;
        [self handlePlayingInfo:info];
    }
    
}

-(void)handlePlayingInfo:(PlayingInfoModel *)info
{
    
}

@end
