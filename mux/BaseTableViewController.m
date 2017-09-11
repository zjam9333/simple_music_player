//
//  BaseTableViewController.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AudioPlayer.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.showsVerticalScrollIndicator=NO;
    
    self.tableView.contentInset=UIEdgeInsetsMake(64, 0, 49, 0);
    if ([[AudioPlayer sharedAudioPlayer]hasSongPlay]) {
        [self mediaStartedPlayingNotification:nil];
    }
    
    self.tableView.contentOffset=CGPointMake(0, -self.tableView.contentInset.top);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaStartedPlayingNotification:) name:AudioPlayerStartMediaPlayNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMediaInfoNotification:) name:AudioPlayerPlayingMediaInfoNotification object:nil];
}

-(void)mediaStartedPlayingNotification:(NSNotification*)noti
{
    self.tableView.contentInset=UIEdgeInsetsMake(64, 0, 44+49, 0);
}

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    PlayingInfoModel* info=[noti.userInfo valueForKey:@"mediaInfo"];
    self.currentPlayingInfo=info;
    [self handlePlayingInfo:info];
}

-(void)handlePlayingInfo:(PlayingInfoModel *)info
{
    
}

@end
