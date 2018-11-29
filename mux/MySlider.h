//
//  MyHiddenSlider.h
//  mux
//
//  Created by dabby on 2018/11/29.
//  Copyright © 2018 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MySlider : UIControl

@property (nonatomic, strong) NSArray<NSNumber *> *numbers; // 0 ~ 1
@property (nonatomic, assign) CGFloat value; // 0 ~ 1
@property (nonatomic, assign, readonly) BOOL isTouching;

@end

NS_ASSUME_NONNULL_END
