//
//  NSTimer+HICategory.m
//  demo
//
//  Created by h_n on 2018/3/28.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "NSTimer+HICategory.h"
#import <objc/runtime.h>

@implementation NSTimer (HICategory)

+ (NSTimer *)db_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *))block {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerCustomSeletor:) userInfo:nil repeats:repeats];
    timer.earlyBlock = block;
    return timer;
}

- (void)setEarlyBlock:(void (^)(NSTimer *))earlyBlock {
    objc_setAssociatedObject(self, @selector(earlyBlock), earlyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSTimer *))earlyBlock {
    return objc_getAssociatedObject(self, @selector(earlyBlock));
}

+ (void)timerCustomSeletor:(NSTimer *)timer {
    __weak typeof(timer) weakSelf = timer;
    if(timer.earlyBlock) {
        timer.earlyBlock(weakSelf);
    }
}

@end


