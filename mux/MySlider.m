//
//  MyHiddenSlider.m
//  mux
//
//  Created by dabby on 2018/11/29.
//  Copyright © 2018 Jam. All rights reserved.
//

#import "MySlider.h"

const CGFloat kWidthPerColumn = 2;
const CGFloat kMarginForColumn = 1;

@implementation MySlider {
    CGFloat _startX;
    CGFloat _deltaX;
    BOOL _isTouching;
    
//    CALayer *_columnLayer;
}

- (BOOL)isTouching {
    return _isTouching;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _startX = [touches.anyObject locationInView:self].x;
    _isTouching = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isTouching = YES;
    CGFloat endX = [touches.anyObject locationInView:self].x;
    _deltaX = endX - _startX;
    _startX = endX;
    [self sliding];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isTouching = NO;
//    });
    CGFloat endX = [touches.anyObject locationInView:self].x;
    _deltaX = endX - _startX;
    _startX = endX;
    [self didSlide];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isTouching = NO;
}

- (void)sliding {
    [self calculateProgress];
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

- (void)didSlide {
    // do slide
    [self calculateProgress];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)calculateProgress {
    NSInteger count = self.numbers.count;
    if (count == 0) {
        return;
    }
    CGFloat totalWidth = count * (kWidthPerColumn + kMarginForColumn);
    CGFloat deltaValue = (-_deltaX / totalWidth);
    [self touchSetValue:self.value + deltaValue];
//    NSLog(@"progress:%f", self.value);
}

- (void)setNumbers:(NSArray<NSNumber *> *)numbers {
    _numbers = numbers;
    [self setNeedsDisplay];
}

- (void)setValue:(CGFloat)value {
    if (_isTouching) {
        return;
    }
    [self touchSetValue:value];
}

- (void)touchSetValue:(CGFloat)value {
    if (value < 0) {
        value = 0;
    } else if (value > 1){
        value = 1;
    }
    _value = value;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    NSInteger count = self.numbers.count;
    if (count == 0) {
        return;
    }
    
    CGFloat centerX = CGRectGetMidX(rect);
    
    CGFloat totalWidth = count * (kWidthPerColumn + kMarginForColumn);
    CGFloat startX = centerX - totalWidth * self.value;
    
    CGSize size = self.frame.size;
    CGFloat topMax = size.height * 0.65;
    CGFloat botMax = size.height - topMax;
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger i = 0; i < count; i ++) {
        CGFloat lineCenterX = startX + totalWidth * i / count;
        if (lineCenterX < 0 || lineCenterX > size.width) {
            continue;
        }
        CGContextSetLineWidth(context, kWidthPerColumn);
        
        CGPoint aPoints[2];
        CGFloat numberValue = self.numbers[i].doubleValue;
        
        for (int k = 0; k < 2; k ++) {
            aPoints[0] = CGPointMake(lineCenterX, topMax);
            aPoints[1] = CGPointMake(lineCenterX, topMax * (1 - numberValue));
            
            if (lineCenterX < centerX) {
                if (k == 0) {
                    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0); // top left
                } else {
                    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.3); // bot left
                    aPoints[1] = CGPointMake(lineCenterX, topMax + botMax *numberValue);
                }
            } else {
                if (k == 0) {
                    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); // top right
                } else {
                    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.3); // bot right
                    aPoints[1] = CGPointMake(lineCenterX, topMax + botMax *numberValue);
                }
            }
            //添加线 points[]坐标数组，和count大小
            CGContextAddLines(context, aPoints, 2);
            //根据坐标绘制路径
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
}

@end
