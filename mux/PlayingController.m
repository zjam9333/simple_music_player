//
//  PlayingController.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "PlayingController.h"

static PlayingController* shared;
static AVAudioPlayer* player;

@interface PlayingController ()<AVAudioPlayerDelegate,AVAudioSessionDelegate>
{
    UIImageView* artWork;
    UISlider* timeSlider;
    UIButton* back;
    UILabel* current;
    UILabel* duration;
    UILabel* title;
    UILabel* detail;
    UIButton* previous;
    UIButton* play;
    UIButton* next;
    UISlider* volumeSlider;
    NSTimer* timer;
    
    NSMutableArray* playedList;
    NSMutableArray* willPlayList;
    
    BOOL wasPlaying;
}
@end

@implementation PlayingController

+(PlayingController*)sharedInstantype
{
    if(shared==nil)
    {
        shared=[[PlayingController alloc]init];
    }
    return shared;
}

+(BOOL)isPlaying
{
    return player.isPlaying;
}

-(instancetype)init
{
    self=[super init];
    if(self)
    {
        _playingList=[NSMutableArray array];
        playedList=[NSMutableArray array];
        willPlayList=[NSMutableArray array];
        NSLog(@"init");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGFloat aboveH=self.view.frame.size.width;
    CGFloat belowH=self.view.frame.size.height-aboveH;//248;
    
    
    artWork=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, aboveH)];
    artWork.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:artWork];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(12, 28, 24,24)];
    back.titleLabel.font=[UIFont systemFontOfSize:18];
    [back setTitle:@"▼" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    back.layer.shadowColor=[UIColor blackColor].CGColor;
    back.layer.shadowOpacity=1;
    back.layer.shadowRadius=2;
    back.layer.shadowOffset=CGSizeMake(0, 0);
    back.layer.masksToBounds=YES;
    [self.view addSubview:back];
    [back addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView* belowView=[[UIView alloc]initWithFrame:CGRectMake(0, artWork.frame.size.height+artWork.frame.origin.y, self.view.frame.size.width, belowH)];
    [self.view addSubview:belowView];
    
    timeSlider=[[UISlider alloc]initWithFrame:CGRectMake(0, aboveH-8, self.view.frame.size.width, 16)];
    [timeSlider addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeSlider];
    
    current=[[UILabel alloc]initWithFrame:CGRectMake(14, 20, 80, 12)];
    current.font=[UIFont systemFontOfSize:12];
    current.textAlignment=NSTextAlignmentLeft;
    current.textColor=[UIColor grayColor];
    current.text=@"0:00";
    [belowView addSubview:current];
    
    duration=[[UILabel alloc]initWithFrame:CGRectMake(belowView.frame.size.width-80-14, 20, 80, 12)];
    duration.font=[UIFont systemFontOfSize:12];
    duration.textAlignment=NSTextAlignmentRight;
    duration.textColor=[UIColor grayColor];
    duration.text=@"--";
    [belowView addSubview:duration];
    
    title=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, belowView.frame.size.width-30, 18)];
    title.center=CGPointMake(belowView.frame.size.width/2, belowH*0.3);
    title.textAlignment=NSTextAlignmentCenter;
    title.font=[UIFont systemFontOfSize:17];
    title.textColor=[UIColor blackColor];
    title.text=@"-";
    [belowView addSubview:title];
    
    detail=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, title.frame.size.width, 12)];
    detail.center=CGPointMake(belowView.frame.size.width/2, title.center.y+20);
    detail.textAlignment=NSTextAlignmentCenter;
    detail.font=[UIFont systemFontOfSize:12];
    detail.textColor=[UIColor grayColor];
    detail.text=@"-";
    [belowView addSubview:detail];
    
    //◀︎▶︎
    CGFloat centY=0.65;
    previous=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
    previous.center=CGPointMake(belowView.frame.size.width*0.3, belowH*centY);
    previous.titleLabel.font=[UIFont systemFontOfSize:20];
    [previous setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [previous setTitle:@"◀︎◀︎" forState:UIControlStateNormal];
    [previous addTarget:self action:@selector(playPrevious) forControlEvents:UIControlEventTouchUpInside];
    [belowView addSubview:previous];
    
    next=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
    next.center=CGPointMake(belowView.frame.size.width*0.7, belowH*centY);
    next.titleLabel.font=[UIFont systemFontOfSize:20];
    [next setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [next setTitle:@"▶︎▶︎" forState:UIControlStateNormal];
    [next addTarget:self action:@selector(playNext) forControlEvents:UIControlEventTouchUpInside];
    [belowView addSubview:next];
    
    play=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
    play.center=CGPointMake(belowView.frame.size.width*0.5, belowH*centY);
    play.titleLabel.font=[UIFont systemFontOfSize:32];
    [play setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [play setTitle:@"▶︎" forState:UIControlStateNormal];
    [play addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [belowView addSubview:play];
    
    volumeSlider=[[UISlider alloc]initWithFrame:CGRectMake(0, 0, belowView.frame.size.width-60, 20)];
    volumeSlider.center=CGPointMake(belowView.frame.size.width/2, belowH*0.85);
    [volumeSlider addTarget:self action:@selector(volumeValueChanged:) forControlEvents:UIControlEventValueChanged];
    volumeSlider.value=[[MPMusicPlayerController applicationMusicPlayer]volume];
    [belowView addSubview:volumeSlider];
    
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
        [timeSlider setThumbImage:[self createImageWithColor:[UIColor redColor] size:CGSizeMake(4, 20)] forState:UIControlStateNormal];
        [timeSlider setTintColor:[UIColor orangeColor]];
        [volumeSlider setThumbImage:[self createImageWithColor:[UIColor redColor] size:CGSizeMake(4, 10)] forState:UIControlStateNormal];
        [volumeSlider setTintColor:[UIColor orangeColor]];
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeDidChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate date]];
    
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //check out if should play new song;
    NSString* playingURL=player.url.absoluteString;
    NSString* shouldPlayURL=[[_currentItem valueForProperty:MPMediaItemPropertyAssetURL]absoluteString];
    if (![playingURL isEqualToString:shouldPlayURL]) {
        [self setWithItem:_currentItem];
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)dealloc
{
    [timer invalidate];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

-(void)setPlayingList:(NSMutableArray *)playingList
{
    _playingList=[NSArray arrayWithArray:playingList];
    [playedList removeAllObjects];
    [willPlayList removeAllObjects];
    [willPlayList addObjectsFromArray:_playingList];
}

-(NSString*)durationString:(CGFloat)time
{
    int min=time/60;
    int sec=time-min*60;
    return [NSString stringWithFormat:@"%d:%02d",min,sec];
}

-(NSString*)durationCountDownString:(CGFloat)time
{
    NSString* str=[NSString stringWithFormat:@"-%@",[self durationString:time]];
    return str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setWithItem:(MPMediaItem*)item
{
    artWork.image=[item.artwork imageWithSize:artWork.frame.size];
    title.text=item.title;
    detail.text=[NSString stringWithFormat:@"%@ - %@",item.artist,item.albumTitle];
    current.text=[self durationString:0];
    duration.text=[self durationCountDownString:item.playbackDuration];
    if (player.isPlaying) {
        [player stop];
    }
    NSError* error=nil;
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[item valueForProperty:MPMediaItemPropertyAssetURL] error:&error];
    player.delegate=self;
    [player play];
    wasPlaying=player.isPlaying;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type==UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [self playOrPause];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [self playOrPause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPrevious];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNext];
                break;
            default:
                break;
        }
    }
}

-(void)playPrevious
{
    if(player.currentTime>10)
    {
        player.currentTime=0;
    }
    else
    {
        [willPlayList insertObject:_currentItem atIndex:0];
        if(playedList.count>0)
        {
            _currentItem=[playedList lastObject];
            [playedList removeLastObject];
        }
        else
        {
            _currentItem=[willPlayList lastObject];
            [willPlayList removeLastObject];
        }
        [self setWithItem:_currentItem];
    }
}

-(void)playOrPause
{
    if (player.playing) {
        [player pause];
    }
    else
    {
        [player play];
    }
    wasPlaying=player.isPlaying;
}

-(void)playNext
{
    [playedList addObject:_currentItem];
    if(playedList.count>=_playingList.count/2)
    {
        [willPlayList addObject:[playedList firstObject]];
        [playedList removeObjectAtIndex:0];
    }
    int ran=arc4random()%willPlayList.count;
    _currentItem=[willPlayList objectAtIndex:ran];
    [willPlayList removeObjectAtIndex:ran];
    [self setWithItem:_currentItem];
}

-(void)timeValueChanged:(id)sender
{
    if([sender isMemberOfClass:[UISlider class]])
    {
        UISlider* sli=(UISlider*)sender;
        NSLog(@"%f",sli.value);
        current.text=[self durationString:(sli.value/sli.maximumValue)*self.currentItem.playbackDuration];
        duration.text=[self durationCountDownString:self.currentItem.playbackDuration*((sli.maximumValue-sli.value)/sli.maximumValue)];
        if(!sli.isTracking)
            player.currentTime=player.duration*sli.value;
    }
}

-(void)timerRunning
{
    if (player) {
        NSMutableDictionary* dict=[NSMutableDictionary dictionary];
        [dict setValue:@(player.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [dict setValue:@(player.duration) forKey:MPMediaItemPropertyPlaybackDuration];
        [dict setValue:_currentItem.title forKey:MPMediaItemPropertyTitle];
        [dict setObject:_currentItem.artist forKey:MPMediaItemPropertyArtist];
        [dict setObject:_currentItem.albumTitle forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:_currentItem.artwork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter
          defaultCenter] setNowPlayingInfo:dict];
    }
    if(player.isPlaying)
    {
        if(!timeSlider.isTracking)
        {
            CGFloat currentTime=player.currentTime;
            CGFloat durationTime=player.duration;
            CGFloat countDownTime=durationTime-currentTime;
            current.text=[self durationString:currentTime];
            duration.text=[self durationCountDownString:countDownTime];
            timeSlider.value=currentTime/durationTime;
        }
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
    [play setTitle:player.isPlaying?@"||":@"▶︎" forState:UIControlStateNormal];
}

-(void)volumeValueChanged:(id)sender
{
    if([sender isMemberOfClass:[UISlider class]])
    {
        UISlider* sli=(UISlider*)sender;
        [[MPMusicPlayerController applicationMusicPlayer]setVolume:sli.value];
        MPVolumeSettingsAlertHide();
    }
}

-(void)volumeDidChanged:(NSNotification *)notification
{
    MPVolumeSettingsAlertHide();
    if(volumeSlider.isTracking)
        volumeSlider.value=[[[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]floatValue];
}

-(void)handleInterruption:(NSNotification*)notification
{
    NSLog(@"%@",notification.userInfo);
    NSDictionary* dict=notification.userInfo;
    AVAudioSessionInterruptionType interruptionType=[[dict valueForKey:AVAudioSessionInterruptionTypeKey]integerValue];
    if (interruptionType==AVAudioSessionInterruptionTypeBegan) {
        
    }
    else if(interruptionType==AVAudioSessionInterruptionTypeEnded)
    {
        if([[dict allKeys]containsObject:AVAudioSessionInterruptionOptionKey])
        {
            if([[dict valueForKey:AVAudioSessionInterruptionOptionKey]integerValue]==AVAudioSessionInterruptionOptionShouldResume)
            {
                if(wasPlaying)
                {
                    [player play];
                    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                    [self becomeFirstResponder];
                }
            }
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNext];
}

- (UIImage*) createImageWithColor: (UIColor*) color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
