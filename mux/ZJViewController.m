//
//  ZJViewController.m
//  mux
//
//  Created by Jamm on 16/8/13.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ZJViewController.h"

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([[[UIDevice currentDevice]systemVersion]floatValue]<7.0)
    {
        CGSize size=[UIScreen mainScreen].bounds.size;
        CGFloat x=0;
        CGFloat y=0;
        CGFloat h=size.height-20;
        if (self.navigationController!=nil) {
            h=h-44;
            //            y=y+44;
            self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
        }
        if (self.tabBarController!=nil) {
            h=h-49;
        }
        CGFloat w=size.width;
        self.view.frame=CGRectMake(x,y,w,h);
        
    }
    else
    {
    }
    self.view.backgroundColor=[UIColor whiteColor];
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
