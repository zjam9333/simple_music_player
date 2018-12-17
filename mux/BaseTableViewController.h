//
//  BaseTableViewController.h
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingInfoModel.h"

@interface BaseTableViewController : UITableViewController

@property (nonatomic,weak) PlayingInfoModel* currentPlayingInfo;

-(void)handlePlayingInfo:(PlayingInfoModel*)info;

@end
