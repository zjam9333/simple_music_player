//
//  AllAlbumController.m
//  mux
//
//  Created by Jam on 2017/10/12.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "AllAlbumController.h"
#import "MediaQuery.h"
#import "PlayListCell.h"

@interface AllAlbumController ()

@end

@implementation AllAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"专辑";
    
    NSArray* albums=[MediaQuery allAlbums];
    NSLog(@"%@",albums);
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
