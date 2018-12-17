//
//  MarginLabel.m
//  mux
//
//  Created by Jam on 2018/11/28.
//  Copyright © 2018 Jam. All rights reserved.
//

#import "MarginLabel.h"

@implementation MarginLabel

-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [super textRectForBounds:CGRectInset(bounds, self.marginX, self.marginY) limitedToNumberOfLines:numberOfLines];
    rect.origin.x -= self.marginX;
    rect.origin.y -= self.marginY;
    rect.size.width += 2 * self.marginX;
    rect.size.height += 2 * self.marginY;
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:CGRectInset(rect, self.marginX, self.marginY)];
}

@end
