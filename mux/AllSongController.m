//
//  AllSongController.m
//  mux
//
//  Created by bangju on 2017/10/10.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "AllSongController.h"
#import "MediaQuery.h"

#import "PlayingListHeaderCell.h"
#import "ShufflePlayHeaderCell.h"

#import "AudioPlayController.h"

@interface AllSongController ()
{
    NSArray* songs;
}
@end

@implementation AllSongController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"全部歌曲";
    
}


@end
