//
//  SongCell.h
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingProgressButton.h"

@interface SongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet PlayingProgressButton *progressButton;

@end
