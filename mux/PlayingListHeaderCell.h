//
//  PlayingListHeaderCell.h
//  mux
//
//  Created by bangju on 2017/9/11.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingProgressButton.h"

@interface PlayingListHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *total;
@property (weak, nonatomic) IBOutlet PlayingProgressButton *progressButton;

@end
