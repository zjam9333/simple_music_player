//
//  PlayingView.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "PlayingView.h"
#import "PlayingInfoModel.h"
#import "AudioPlayer.h"

@interface PlayingView()

@property (weak, nonatomic) IBOutlet UIButton *pauseSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseLargeButton;
@property (weak, nonatomic) IBOutlet UIButton *playSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *playLargeButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *playedDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameSmallLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumSmallLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *progressSmallView;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumnView;

@end

@implementation PlayingView
{
    BOOL touchMoved;
    CGPoint touchBeganPointOffset;
}

+(instancetype)defaultPlayingView
{
    PlayingView* pl=[[[UINib nibWithNibName:@"PlayingView" bundle:nil]instantiateWithOwner:nil options:nil]firstObject];
    pl.frame=[pl frameForShowing:NO];
    [[NSNotificationCenter defaultCenter]addObserver:pl selector:@selector(refreshMediaInfoNotification:) name:AudioPlayerPlayingMediaInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:pl selector:@selector(mediaStartedPlayingNotification:) name:AudioPlayerStartMediaPlayNotification object:nil];
    return pl;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"progressThumb"] forState:UIControlStateNormal];
    [self.volumnView setVolumeThumbImage:[UIImage imageNamed:@"volumnThumb"] forState:UIControlStateNormal];
}

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    PlayingInfoModel* info=[noti.userInfo valueForKey:@"mediaInfo"];
    
    BOOL playing=info.playing.boolValue;
    self.playSmallButton.hidden=playing;
    self.playLargeButton.hidden=playing;
    self.pauseSmallButton.hidden=!playing;
    self.pauseLargeButton.hidden=!playing;
    
    self.artworkImageView.image=info.artwork;
    self.bgArtworkImageView.image=self.artworkImageView.image;
    
    self.nameLabel.text=info.name;
    self.nameSmallLabel.text=self.nameLabel.text;
    
    self.artistAlbumLabel.text=[NSString stringWithFormat:@"%@ - %@",info.artist,info.album];
    self.artistAlbumSmallLabel.text=self.artistAlbumLabel.text;
    
    self.playedDurationLabel.text=[self stringWithNumber:info.currentTime];
    self.leftDurationLabel.text=[self stringWithNumber:[NSNumber numberWithInt:info.playbackDuration.intValue-info.currentTime.intValue]];
    
    self.progressSlider.value=info.currentTime.floatValue/info.playbackDuration.floatValue;
    self.progressSmallView.progress=self.progressSlider.value;
    
    self.shuffleButton.selected=info.shuffle.boolValue;
//    self.volumnSlider.value=
}

-(void)mediaStartedPlayingNotification:(NSNotification*)noti
{
    [self hidePlaying:nil];
}

- (IBAction)playOrPause:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
//        UIButton* btn=(UIButton*)sender;
//        BOOL selected=!btn.selected;
//        
//        self.playSmallButton.selected=selected;
//        self.playLargeButton.selected=selected;
        [[AudioPlayer sharedAudioPlayer]playOrPause];
    }
}
- (IBAction)playNext:(id)sender {
    [[AudioPlayer sharedAudioPlayer]playNext];
}

- (IBAction)playPrevious:(id)sender {
    [[AudioPlayer sharedAudioPlayer]playPrevious];
}

- (IBAction)shuffleOrNot:(id)sender {
    self.shuffleButton.selected=!self.shuffleButton.selected;
    [[AudioPlayer sharedAudioPlayer]shuffle:self.shuffleButton.selected];
}

- (IBAction)progressSliderValueChanged:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        CGFloat progress=((UISlider*)sender).value;
        CGFloat max=0.95;
        if (progress>max)
        {
            progress=max;
        }
        [[AudioPlayer sharedAudioPlayer]setProgress:progress];
    }
}

- (IBAction)showPlaying:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:PlayingViewShowingNotification object:nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame=[self frameForShowing:YES];
    } completion:^(BOOL finished) {
        self.volumnView.hidden=NO;
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (IBAction)hidePlaying:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:PlayingViewHidingNotification object:nil];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame=[self frameForShowing:NO];
    } completion:^(BOOL finished) {
        self.volumnView.hidden=YES;
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

-(CGRect)frameForShowing:(BOOL)showing
{
    CGFloat offset=44;
    CGSize screen=[[UIScreen mainScreen]bounds].size;
    CGSize size=[self sizeForPlayingView];
    CGPoint origin=CGPointMake(0, 0);
    
    if (showing) {
        origin.y=-offset;
    }
    else
    {
        origin.y=screen.height-49-offset;
    }
    
    CGRect frame=CGRectZero;
    frame.origin=origin;
    frame.size=size;
    
    return frame;
}

-(CGSize)sizeForPlayingView
{
    CGFloat offset=44;
    CGSize screen=[[UIScreen mainScreen]bounds].size;
    CGSize size=CGSizeMake(screen.width, screen.height+offset);
    return size;
}

-(NSString*)stringWithNumber:(NSNumber*)number
{
    int secs=number.intValue;
    int min=secs/60;
    int sec=secs%60;
    return [NSString stringWithFormat:@"%d:%02d",min,sec];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* to=[touches anyObject];
    CGPoint loc=[to locationInView:self.superview];
//    NSLog(@"began %@",NSStringFromCGPoint(loc));
    touchMoved=NO;
    touchBeganPointOffset=loc;
    touchBeganPointOffset.y=touchBeganPointOffset.y-self.frame.origin.y;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* to=[touches anyObject];
    CGPoint loc=[to locationInView:self.superview];
//    NSLog(@"moved %@",NSStringFromCGPoint(loc));
    touchMoved=YES;
    
    CGRect fra=CGRectZero;
    fra.size=[self sizeForPlayingView];
    CGFloat toY=loc.y-touchBeganPointOffset.y;
    fra.origin=CGPointMake(0, toY);
    self.frame=fra;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* to=[touches anyObject];
    CGPoint loc=[to locationInView:self.superview];
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
        CGPoint pre=[to previousLocationInView:self.superview];
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
