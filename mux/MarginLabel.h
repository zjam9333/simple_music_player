//
//  MarginLabel.h
//  mux
//
//  Created by Jam on 2018/11/28.
//  Copyright © 2018 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MarginLabel : UILabel

@property (nonatomic, assign) IBInspectable NSInteger marginY;
@property (nonatomic, assign) IBInspectable NSInteger marginX;

@end

NS_ASSUME_NONNULL_END
