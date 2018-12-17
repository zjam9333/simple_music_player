//
//  PlayListCell.m
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "PlayListCell.h"

@implementation PlayListCell

- (void)dealloc {
    NSLog(@"dealloc: %@", self);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
