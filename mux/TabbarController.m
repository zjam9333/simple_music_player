//
//  TabbarController.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "TabbarController.h"
#import "AllPlayListController.h"
#import "AllArtistController.h"

@interface TabbarController ()

@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController* playlists=[[UINavigationController alloc]initWithRootViewController:[[AllPlayListController alloc]init]];
    playlists.title=@"playlist";
    playlists.topViewController.title=@"playlist";
    [self addChildViewController:playlists];
    
    UINavigationController* artists=[[UINavigationController alloc]initWithRootViewController:[[AllArtistController alloc]init]];
    artists.title=@"artist";
    artists.topViewController.title=@"artist";
    [self addChildViewController:artists];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
