//
//  NSTimer+HICategory.h
//  demo
//
//  Created by h_n on 2018/3/28.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (HICategory)

// block回调，别用ios9没有的scheduledTimerWithTimeInterval:repeats:block:
+ (NSTimer*)db_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end
