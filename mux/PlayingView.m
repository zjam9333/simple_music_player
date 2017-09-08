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

@end

@implementation PlayingView

+(instancetype)defaultPlayingView
{
    PlayingView* pl=[[[UINib nibWithNibName:@"PlayingView" bundle:nil]instantiateWithOwner:nil options:nil]firstObject];
    pl.frame=[pl frameForShowing:NO];
    [[NSNotificationCenter defaultCenter]addObserver:pl selector:@selector(refreshMediaInfoNotification:) name:AudioPlayerPlayingMediaInfoNotification object:nil];
    return pl;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)refreshMediaInfoNotification:(NSNotification*)noti
{
    PlayingInfoModel* info=[noti.userInfo valueForKey:@"mediaInfo"];
    
    self.playLargeButton.selected=info.playing.boolValue;
    self.playSmallButton.selected=self.playLargeButton.selected;
    
    self.artworkImageView.image=info.artwork;
    self.bgArtworkImageView.image=self.artworkImageView.image;
    
    self.nameLabel.text=info.name;
    self.nameSmallLabel.text=self.nameLabel.text;
    
    self.artistAlbumLabel.text=[NSString stringWithFormat:@"%@ - %@",info.artist,info.album];
    self.artistAlbumSmallLabel.text=self.artistAlbumLabel.text;
    
    self.playedDurationLabel.text=[self stringWithNumber:info.currentTime];
    self.leftDurationLabel.text=[self stringWithNumber:[NSNumber numberWithInt:info.playbackDuration.intValue-info.currentTime.intValue]];
}

- (IBAction)playOrPause:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* btn=(UIButton*)sender;
        BOOL selected=!btn.selected;
        
        self.playSmallButton.selected=selected;
        self.playLargeButton.selected=selected;
    }
}
- (IBAction)shuffleOrNot:(id)sender {
    self.shuffleButton.selected=!self.shuffleButton.selected;
}

- (IBAction)showPlaying:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:PlayingViewShowingNotification object:nil];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame=[self frameForShowing:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)hidePlaying:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:PlayingViewHidingNotification object:nil];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame=[self frameForShowing:NO];
    } completion:^(BOOL finished) {
        
    }];
}

-(CGRect)frameForShowing:(BOOL)showing
{
    CGFloat offset=44;
    CGSize screen=[[UIScreen mainScreen]bounds].size;
    CGSize size=CGSizeMake(screen.width, screen.height+offset);
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

-(NSString*)stringWithNumber:(NSNumber*)number
{
    int secs=number.intValue;
    int min=secs/60;
    int sec=secs%60;
    return [NSString stringWithFormat:@"%d:%02d",min,sec];
}

@end
