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
    
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 44, 0);
    self.tableView.tableFooterView=[[UIView alloc]init];
    
}

@end
