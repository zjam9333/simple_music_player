//
//  EqualizerView.m
//  mux
//
//  Created by dabby on 2018/12/12.
//  Copyright © 2018 Jam. All rights reserved.
//

#import "EqualizerView.h"

#define kMaxGain (12)
#define kMinGain (-12)

@interface EqualizerView ()

@property (weak, nonatomic) IBOutlet UIView *sliderContainer;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;

@end

@implementation EqualizerView

+ (void)show {
    [[self defaultEqualizer] show];
}

+ (instancetype)defaultEqualizer {
    EqualizerView *eqView = [[[UINib nibWithNibName:@"EqualizerView" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    if (![eqView isKindOfClass:self.class]) {
        return [[self alloc] init];
    }
    [eqView config];
    return eqView;
}

- (void)config {
    self.maxValueLabel.text = [NSString stringWithFormat:@"%ddb", kMaxGain];
    self.minValueLabel.text = [NSString stringWithFormat:@"%ddb", kMinGain];
    
    CGRect containerRect = self.sliderContainer.bounds;
    
    NSInteger count = kEQBandCount;
    CGSize sliderSize = CGSizeMake(containerRect.size.height, containerRect.size.width / count);
    CGFloat halfWidth = sliderSize.height / 2;
    CGFloat centerY = containerRect.size.height / 2;
    for (NSInteger i = 0; i < count; i ++) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, sliderSize.width, sliderSize.height)];
        slider.center = CGPointMake(halfWidth + i * sliderSize.height, centerY);
        slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [self.sliderContainer addSubview:slider];
        slider.tag = i;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
//         sliders appearance
        slider.continuous = NO;
        slider.minimumTrackTintColor = [UIColor redColor];
        slider.minimumValue = kMinGain;
        slider.maximumValue = kMaxGain;
        slider.value = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@%d", kEQBandKeyPrefix, (int)i]] floatValue] ;
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    long tag = slider.tag;
    [[NSUserDefaults standardUserDefaults] setValue:@(slider.value) forKey:[NSString stringWithFormat:@"%@%ld", kEQBandKeyPrefix, tag]];
    [self sendEQChangedNotification];
}

- (void)show {
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    self.alpha = 0;
    self.frame = self.superview.bounds;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

- (IBAction)close:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)resetAll:(id)sender {
    NSArray *sliders = self.sliderContainer.subviews;
    for (UISlider *slider in sliders) {
        if ([slider isKindOfClass:[UISlider class]]) {
            long tag = slider.tag;
            slider.value = 0;
            [[NSUserDefaults standardUserDefaults] setValue:@(slider.value) forKey:[NSString stringWithFormat:@"%@%ld", kEQBandKeyPrefix, tag]];
        }
    }
    [self sendEQChangedNotification];
}

- (void)sendEQChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQChangedNotificationName object:nil];
}

@end
