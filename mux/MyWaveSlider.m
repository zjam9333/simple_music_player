//
//  MyHiddenSlider.m
//  mux
//
//  Created by dabby on 2018/11/29.
//  Copyright © 2018 Jam. All rights reserved.
//

#import "MyWaveSlider.h"

#define kWidthPerColumn (1/UIScreen.mainScreen.scale)
#define kMarginForColumn (0)//(1/UIScreen.mainScreen.scale)
#define kSampleRate (1000)

@implementation MyWaveSlider {
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
    NSInteger count = self.numbers.length;
    if (count == 0) {
        return;
    }
    CGFloat totalWidth = count / kSampleRate * (kWidthPerColumn + kMarginForColumn);
    CGFloat deltaValue = (-_deltaX / totalWidth) * 4;
    [self touchSetValue:self.value + deltaValue];
//    NSLog(@"progress:%f", self.value);
}

- (void)setNumbers:(NSData *)numbers {
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

- (void)setNeedsDisplay {
    CGRect myFrameInWindow = [self convertRect:self.bounds toView:UIApplication.sharedApplication.keyWindow];
    if (!CGRectIntersectsRect(UIApplication.sharedApplication.keyWindow.bounds, myFrameInWindow)) {
        return;
    }
    [super setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    NSInteger totalSampleCount = self.numbers.length;
    if (totalSampleCount == 0) {
        return;
    }
    NSInteger columnCount = totalSampleCount / kSampleRate;
    if (columnCount == 0) {
        return;
    }
    
    CGFloat centerX = CGRectGetMidX(rect);
    
    CGFloat totalWidth = columnCount * (kWidthPerColumn + kMarginForColumn);
    CGFloat startX = centerX - totalWidth * self.value;
    
    CGSize size = self.frame.size;
    CGFloat topMax = size.height * 0.65;
    CGFloat botMax = size.height - topMax;
    
    
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);//kWidthPerColumn);
    
    NSInteger startIndex = (0 - startX) * columnCount / totalWidth;
    NSInteger endIndex = (size.width - startX) * columnCount / totalWidth;
    if (startIndex < 0) {
        startIndex = 0;
    }
    if (endIndex > columnCount) {
        endIndex = columnCount;
    }
    
    SInt8 *values = (SInt8 *)self.numbers.bytes;
    
    for (NSInteger i = startIndex; i < endIndex; i ++) {
        CGFloat lineCenterX = startX + totalWidth * i / columnCount;
        
        SInt8 showSampleValue = 0;
        NSInteger blockOffset = i * kSampleRate;
        NSInteger blockLength = kSampleRate;
        if (blockOffset + blockLength > totalSampleCount) {
            blockLength = totalSampleCount - blockOffset;
        }
        NSInteger blockMax = blockLength + blockOffset;
        for (NSInteger bla = blockOffset; bla < blockMax; bla ++) {
            SInt8 thisSample = values[bla];
            if (showSampleValue < thisSample) {
                showSampleValue = thisSample;
            }
        }
//        SInt8 blockAvgValue = blockTotalSampleValue / blockLength;
        CGPoint aPoints[2];
        CGFloat numberValue = (showSampleValue / 128.0);
        
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
