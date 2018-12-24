//
//  PlayingView.m
//  mux
//
//  Created by Jam on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "PlayingView.h"
#import "PlayingInfoModel.h"
#import "AudioPlayController.h"
#import "MyWaveSlider.h"

#import "EqualizerView.h"

@interface PlayingView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *playingSmallBar;
@property (weak, nonatomic) IBOutlet UIButton *pauseSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseLargeButton;
@property (weak, nonatomic) IBOutlet UIButton *playSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *playLargeButton;

@property (weak, nonatomic) IBOutlet UIView *playingMainPage;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *playedDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameSmallLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumSmallLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *progressSmallView;
@property (weak, nonatomic) IBOutlet MyWaveSlider *myProgressSlider;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumnView;

@property (weak, nonatomic) PlayingInfoModel *currentInfoModel;

@end

@implementation PlayingView
{
    BOOL touchMoved;
    CGPoint touchBeganPointOffset;
}

+ (instancetype)defaultPlayingView
{
    PlayingView *pl = [[[UINib nibWithNibName:@"PlayingView" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    pl.frame = [pl frameForShowing:NO];
    [[NSNotificationCenter defaultCenter] addObserver:pl selector:@selector(refreshMediaInfoNotification:) name:AudioPlayerPlayingMediaInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:pl selector:@selector(mediaStartedPlayingNotification:) name:AudioPlayerStartMediaPlayNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1  *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets inset = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
            pl.bottomViewBottomConstraint.constant = inset.bottom;
            pl.topViewTopConstraint.constant = inset.top + 20;
        } else {
            // Fallback on earlier versions
        }
    });
    
    return pl;
}

#pragma mark - notification

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    PlayingInfoModel *info = [noti.userInfo valueForKey:@"mediaInfo"];
    PlayingInfoModel *lastInfo = self.currentInfoModel;
    self.currentInfoModel = info;
    
    // always same
    if (lastInfo != info) {
        self.artworkImageView.image = info.artwork;

        self.nameSmallLabel.text = info.name;
        self.artistAlbumSmallLabel.text = [NSString stringWithFormat:@"%@ - %@",info.artist,info.album];

        NSString *firstTitle = [NSString stringWithFormat:@"%@", info.name];
        NSString *secondTitle = [NSString stringWithFormat:@"%@ - %@",info.artist,info.album];

        self.firstTitleLabel.text = firstTitle;
        self.secondTitleLabel.text = secondTitle;
    }
    
    // not same;
    BOOL playing = info.playing.boolValue;
    self.playSmallButton.hidden = playing;
    self.playLargeButton.hidden = playing;
    self.pauseSmallButton.hidden = !playing;
    self.pauseLargeButton.hidden = !playing;
    
    self.shuffleButton.selected = info.shuffle.boolValue;
    self.myProgressSlider.numbers = info.pcmData;
    
    if (self.myProgressSlider.isTouching) {
        return; // 在滑动进度条的时候，不要改progress了
    }
    
    // set artwork image frame and progerss
    CGFloat progressValue = info.currentTime.floatValue/info.playbackDuration.floatValue;
    if (isnan(progressValue)) {
        progressValue = 0;
    }
    [self setWithProgress:progressValue];
}

-(void)mediaStartedPlayingNotification:(NSNotification*)noti
{
    [self hidePlaying:nil];
}

#pragma mark - playing status and actions

- (void)setWithProgress:(CGFloat)progress {
    self.playedDurationLabel.text = [self stringWithNumber:[NSNumber numberWithInteger:progress  *self.currentInfoModel.playbackDuration.integerValue] ];
    self.leftDurationLabel.text = [self stringWithNumber:[NSNumber numberWithInteger:(1 - progress)  *self.currentInfoModel.playbackDuration.integerValue] ];
    
    self.progressSlider.value = progress;
    self.progressSmallView.progress = progress;
    self.myProgressSlider.value  =  progress;

    if (self.currentInfoModel.artwork) {
        CGSize windowSize  =  UIApplication.sharedApplication.keyWindow.bounds.size;
        CGFloat imgH  =  windowSize.height;
        CGFloat imgW  =  imgH / self.currentInfoModel.artwork.size.height  *self.currentInfoModel.artwork.size.width;
        CGFloat imgY  =  0; //self.frame.size.height - imgH;
        CGFloat totalMove  =  windowSize.width - imgW;
        CGFloat imgX  =  (CGFloat)(progress  *totalMove);
        self.artworkImageView.frame  =  CGRectMake(imgX, imgY, imgW, imgH);
    }
}

-(NSString*)stringWithNumber:(NSNumber*)number
{
    int secs = number.intValue;
    int min = secs/60;
    int sec = secs%60;
    return [NSString stringWithFormat:@"%d:%02d",min,sec];
}

- (IBAction)playOrPause:(id)sender {
    [[AudioPlayController sharedAudioPlayer] playOrPause];
}
- (IBAction)playNext:(id)sender {
    [[AudioPlayController sharedAudioPlayer] playNext];
}

- (IBAction)playPrevious:(id)sender {
    [[AudioPlayController sharedAudioPlayer] playPrevious];
}

- (IBAction)shuffleOrNot:(id)sender {
    self.shuffleButton.selected = !self.shuffleButton.selected;
    [[AudioPlayController sharedAudioPlayer] shuffle:self.shuffleButton.selected];
}

- (IBAction)progressSliderValueChanged:(MyWaveSlider *)sender {
    CGFloat progress = [sender value];
    [[AudioPlayController sharedAudioPlayer] setProgress:progress];
    [self setWithProgress:progress];
}
- (IBAction)progressSliderDragInside:(MyWaveSlider *)sender {
    CGFloat progress = [sender value];
    [self setWithProgress:progress];
}

#pragma mark - show and hide

- (IBAction)showPlaying:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayingViewShowingNotification object:nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = [self frameForShowing:YES];
    } completion:^(BOOL finished) {
        self.volumnView.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (IBAction)hidePlaying:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayingViewHidingNotification object:nil];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = [self frameForShowing:NO];
    } completion:^(BOOL finished) {
        self.volumnView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (IBAction)showMoreAction:(id)sender {
    UIAlertController *alert  =  [UIAlertController alertControllerWithTitle:@"Setting" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"EQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *_Nonnull action) {
        [EqualizerView show];
    }] ];
    [alert addAction:[UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleCancel handler:nil] ];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - rect and size

-(CGRect)frameForShowing:(BOOL)showing
{
    CGFloat offset = 44;
    CGSize screen = [[UIScreen mainScreen] bounds] .size;
    CGSize size = [self sizeForPlayingView];
    CGPoint origin = CGPointMake(0, 0);
    
    if (showing) {
        origin.y = -offset;
    }
    else
    {
        origin.y = screen.height-((UITabBarController *)(UIApplication.sharedApplication.keyWindow.rootViewController)).tabBar.frame.size.height-offset;
    }
    
    CGRect frame = CGRectZero;
    frame.origin = origin;
    frame.size = size;
    
    return frame;
}

-(CGSize)sizeForPlayingView
{
    CGFloat offset = 44;
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    CGSize size = CGSizeMake(screen.width, screen.height+offset);
    return size;
}

#pragma mark - touches

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *to = [touches anyObject];
    CGPoint loc = [to locationInView:self.superview];
//    NSLog(@"began %@",NSStringFromCGPoint(loc));
    touchMoved = NO;
    touchBeganPointOffset = loc;
    touchBeganPointOffset.y = touchBeganPointOffset.y-self.frame.origin.y;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *to = [touches anyObject];
    CGPoint loc = [to locationInView:self.superview];
//    NSLog(@"moved %@",NSStringFromCGPoint(loc));
    touchMoved = YES;
    
    CGRect fra = CGRectZero;
    fra.size = [self sizeForPlayingView];
    CGFloat toY = loc.y-touchBeganPointOffset.y;
    if (toY < - self.playingSmallBar.frame.size.height) {
        toY  =  - self.playingSmallBar.frame.size.height;
    }
    fra.origin = CGPointMake(0, toY);
    self.frame = fra;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *to = [touches anyObject];
    CGPoint loc = [to locationInView:self.superview];
//    NSLog(@"ended %@",NSStringFromCGPoint(loc));
    if (!touchMoved) {
        if (loc.y<self.frame.size.height/2) {
//            [self hidePlaying:nil];
        }
        else
        {
            [self showPlaying:nil];
        }
    }
    else
    {
        CGPoint pre = [to previousLocationInView:self.superview];
        if (loc.y<pre.y) {
            [self showPlaying:nil];
        }
        else
        {
            [self hidePlaying:nil];
        }
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
