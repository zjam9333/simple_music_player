//
//  MyHiddenSlider.h
//  mux
//
//  Created by Jam on 2018/11/29.
//  Copyright © 2018 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWaveSlider : UIControl

@property (nonatomic, strong) NSData *numbers; // read bytes
@property (nonatomic, assign) CGFloat value; // 0 ~ 1
@property (nonatomic, assign, readonly) BOOL isTouching;

@end
