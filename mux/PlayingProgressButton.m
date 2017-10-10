//
//  PlayingProgressButton.m
//  mux
//
//  Created by bangju on 2017/9/12.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "PlayingProgressButton.h"
#import "AudioPlayer.h"

@interface PlayingProgressButton()
{
    UIImageView* playImage;
    CircleProgressView* progressView;
}
@end

@implementation PlayingProgressButton

-(void)awakeFromNib
{
    [super awakeFromNib];
//    NSLog(@"%@ awakeFromNib",NSStringFromClass(self.class));
    [self config];
}

-(void)config
{
    self.backgroundColor=[UIColor clearColor];
    UIVisualEffectView* blur=[[UIVisualEffectView alloc]initWithFrame:self.bounds];
    blur.effect=[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    blur.layer.cornerRadius=self.bounds.size.width/2;
    blur.layer.masksToBounds=YES;
    [self addSubview:blur];
    
    playImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    playImage.center=blur.center;
    [self addSubview:playImage];
    
    progressView=[[CircleProgressView alloc]initWithFrame:self.bounds];
    progressView.backgroundColor=[UIColor clearColor];
    [self addSubview:progressView];
    
    self.progress=0;
    self.currentState=ProgressStatePlaying;
    
    for (UIView* sub in self.subviews) {
        sub.userInteractionEnabled=NO;
    }
    
    [self addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    progressView.progress=progress;
}

-(void)setCurrentState:(ProgressState)currentState
{
    _currentState=currentState;
    playImage.image=self.currentState==ProgressStatePlaying?[UIImage imageNamed:@"playSmall"]:[UIImage imageNamed:@"pauseSmall"];
}

-(void)pressed
{
//    if ([self.delegate respondsToSelector:@selector(playingProgressButtonDidSelected)]) {
//        [self.delegate playingProgressButtonDidSelected];
//    }
    [[AudioPlayer sharedAudioPlayer]playOrPause];
}

@end

@implementation CircleProgressView

-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(self.bounds.size.width/2,self.bounds.size.width/2);  //设置圆心位置
    CGFloat radius = self.bounds.size.width/2-1;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * self.progress;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 2); //设置线条宽度
    [[UIColor blackColor] setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
    
}

@end
