//
//  ZJViewController.m
//  mux
//
//  Created by Jamm on 16/8/13.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ZJViewController.h"
#import "PlayingController.h"

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
    
    UIBarButtonItem* pl=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(goToPlaying)];
    self.navigationItem.rightBarButtonItem=pl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToPlaying
{
    [self presentViewController:[PlayingController sharedInstantype] animated:YES completion:nil];
}

@end
