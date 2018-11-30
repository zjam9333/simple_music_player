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
#import "MySlider.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayingView()

@property (weak, nonatomic) IBOutlet UIView *playingSmallBar;
@property (weak, nonatomic) IBOutlet UIButton *pauseSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseLargeButton;
@property (weak, nonatomic) IBOutlet UIButton *playSmallButton;
@property (weak, nonatomic) IBOutlet UIButton *playLargeButton;

@property (weak, nonatomic) IBOutlet UIView *playingMainPage;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *bgArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *playedDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameSmallLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumSmallLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *progressSmallView;
@property (weak, nonatomic) IBOutlet MySlider *myProgressSlider;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumnView;

@property (weak, nonatomic) PlayingInfoModel *currentInfoModel;

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
//    [self.progressSlider setThumbImage:[UIImage imageNamed:@"progressThumb"] forState:UIControlStateNormal];
//    [self.volumnView setVolumeThumbImage:[UIImage imageNamed:@"volumnThumb"] forState:UIControlStateNormal];
}

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    PlayingInfoModel* info=[noti.userInfo valueForKey:@"mediaInfo"];
    PlayingInfoModel* lastInfo = self.currentInfoModel;
    self.currentInfoModel = info;
    
    if ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
        return;
    }
    
    // always same
    if (lastInfo != info) {
        self.artworkImageView.image=info.artwork;
        //    self.bgArtworkImageView.image=self.artworkImageView.image;

        self.nameSmallLabel.text=info.name;
        self.artistAlbumSmallLabel.text=[NSString stringWithFormat:@"%@ - %@",info.artist,info.album];

        //    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        //    paragraphStyle.maximumLineHeight = 20;
        //    paragraphStyle.minimumLineHeight = 20;
        
        NSString *firstTitle = [NSString stringWithFormat:@"%@", info.name];
        NSString *secondTitle = [NSString stringWithFormat:@"%@ - %@",info.artist,info.album];

        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor blackColor], NSBackgroundColorAttributeName,
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    nil];
        
        self.firstTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:firstTitle attributes:attributes];
        self.secondTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:secondTitle attributes:attributes];
        
        self.myProgressSlider.numbers = ({
            NSMutableArray *arr = [NSMutableArray array];
            NSInteger count = info.playbackDuration.integerValue;
            for (NSInteger i = 0; i < count; i ++) {
                [arr addObject:@(0.01)];
            }
            arr;
        });
        [self analyseWaveUrl:info.url];
    }
    
    
    // not same;
    BOOL playing=info.playing.boolValue;
    self.playSmallButton.hidden=playing;
    self.playLargeButton.hidden=playing;
    self.pauseSmallButton.hidden=!playing;
    self.pauseLargeButton.hidden=!playing;
    
    self.shuffleButton.selected=info.shuffle.boolValue;
    
    if (self.myProgressSlider.isTouching) {
        return;
    }
    //    self.volumnSlider.value=
    CGFloat progressValue = info.currentTime.floatValue/info.playbackDuration.floatValue;
    // set artwork image frame and progerss
    [self setWithProgress:progressValue];
}

- (void)setWithProgress:(CGFloat)progress {
    self.playedDurationLabel.text=[self stringWithNumber:[NSNumber numberWithInteger:progress * self.currentInfoModel.playbackDuration.integerValue]];
    self.leftDurationLabel.text=[self stringWithNumber:[NSNumber numberWithInteger:(1 - progress) * self.currentInfoModel.playbackDuration.integerValue]];
    
    self.progressSlider.value=progress;
    self.progressSmallView.progress=progress;
    self.myProgressSlider.value = progress;

    if (self.currentInfoModel.artwork) {
        CGSize windowSize = UIApplication.sharedApplication.keyWindow.bounds.size;
        CGFloat imgH = windowSize.height;
        CGFloat imgW = imgH / self.currentInfoModel.artwork.size.height * self.currentInfoModel.artwork.size.width;
        CGFloat imgY = 0; //self.frame.size.height - imgH;
        CGFloat totalMove = windowSize.width - imgW;
        CGFloat imgX = (CGFloat)(progress * totalMove);
        self.artworkImageView.frame = CGRectMake(imgX, imgY, imgW, imgH);
    }
}

- (void)analyseWaveUrl:(NSURL *)url {
    PlayingInfoModel *info = self.currentInfoModel;
    NSInteger count = info.playbackDuration.integerValue * 5;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!url) {
            return;
        }
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
        if (!reader) {
            return;
        }
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        NSDictionary *dic = @{AVFormatIDKey :@(kAudioFormatLinearPCM),
                              AVLinearPCMIsBigEndianKey:@NO,
                              AVLinearPCMIsFloatKey:@NO,
                              AVLinearPCMBitDepthKey :@(16)
                              };
        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc]initWithTrack:track outputSettings:dic];
        [reader addOutput:output];
        [reader startReading];
        NSMutableData *data = [NSMutableData data];
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer]; //读取到数据
            if (sampleBuffer) {
                CMBlockBufferRef blockBUfferRef = CMSampleBufferGetDataBuffer(sampleBuffer);//取出数据
                size_t length = CMBlockBufferGetDataLength(blockBUfferRef); //返回一个大小,size_t针对不同的品台有不同的实现,扩展性更好
                SInt16 sampleBytes[length];
                CMBlockBufferCopyDataBytes(blockBUfferRef, 0, length, sampleBytes); //将数据放入数组
                [data appendBytes:sampleBytes length:length]; //将数据附加到data中
                CMSampleBufferInvalidate(sampleBuffer);//销毁
                CFRelease(sampleBuffer); //释放
            }
        }
        if (reader.status != AVAssetReaderStatusCompleted) {
            return;
        }
        NSUInteger sampleCount = data.length / sizeof(SInt16);//计算所有数据个数
        NSUInteger blockSize = sampleCount / count; //将数据分割,也就是按照我们的需求width将数据分为一个个小包
        SInt16 *sampleBytes = (SInt16 *)data.bytes; //总的数据个数
        
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSUInteger i= 0; i < sampleCount; i += blockSize) {//在sampleCount(所有数据)个数据中抽样,抽样方法为在binSize个数据为一个样本,在样本中选取一个数据
            SInt16 power = 0; //sampleBytes[i] - 32767;
//            unsigned long long totalPower = 0;
            for (NSUInteger j = 0; j < blockSize; j++) {//先将每次抽样样本的binSize个数据遍历出来
                SInt16 value = CFSwapInt16LittleToHost(sampleBytes[i + j]);
                if (value > power) {
                    power = value;
                }
            }
////            SInt16 avg = 0xffff;
////
//            SInt16 avgForBin = totalPower / ;
//            NSLog(@"%d", power);
            CGFloat maxTop = 32767;
            [numbers addObject:@(((CGFloat)power)/maxTop)];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (info == self.currentInfoModel) {
                self.myProgressSlider.numbers = numbers;
            }
        });
    });
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

- (IBAction)progressSliderValueChanged:(MySlider *)sender {
    CGFloat progress=[sender value];
//        CGFloat max=0.95;
//        if (progress>max)
//        {
//            progress=max;
//        }
    [[AudioPlayer sharedAudioPlayer]setProgress:progress];
    [self setWithProgress:progress];
}
- (IBAction)progressSliderDragInside:(MySlider *)sender {
    CGFloat progress=[sender value];
    [self setWithProgress:progress];
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
        origin.y=screen.height-((UITabBarController *)(UIApplication.sharedApplication.keyWindow.rootViewController)).tabBar.frame.size.height-offset;
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
    if (toY < - self.playingSmallBar.frame.size.height) {
        toY = - self.playingSmallBar.frame.size.height;
    }
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
