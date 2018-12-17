//
//  OnePlayListController.h
//  mux
//
//  Created by Jam on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "MediaQuery.h"

@interface OnePlayListController : BaseTableViewController

@property (nonatomic,strong) MPMediaPlaylist* playList;

@end
