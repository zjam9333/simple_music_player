//
//  ShufflePlayHeaderCell.m
//  mux
//
//  Created by Jam on 2017/9/11.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "ShufflePlayHeaderCell.h"

@implementation ShufflePlayHeaderCell {
    
    __weak IBOutlet UIImageView *shuffleImageView;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    shuffleImageView.tintColor = [UIColor blackColor];
    shuffleImageView.image = [shuffleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
