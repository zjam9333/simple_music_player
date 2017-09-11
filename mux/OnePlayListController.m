//
//  OnePlayListController.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "OnePlayListController.h"
#import "MediaQuery.h"

#import "SongCell.h"
#import "PlayingListHeaderCell.h"
#import "ShufflePlayHeaderCell.h"

#import "AudioPlayer.h"

@interface OnePlayListController ()

@end

@implementation OnePlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.rowHeight=54;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil] forCellReuseIdentifier:@"SongCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayingListHeaderCell" bundle:nil] forCellReuseIdentifier:@"PlayingListHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShufflePlayHeaderCell" bundle:nil] forCellReuseIdentifier:@"ShufflePlayHeaderCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==2) {
        return self.playList.count;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 130;
    }
    else if(indexPath.section==1)
    {
        return 44;
    }
    else
    {
        return 54;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        PlayingListHeaderCell* cell=[tableView dequeueReusableCellWithIdentifier:@"PlayingListHeaderCell" forIndexPath:indexPath];
        cell.image.image=[MediaQuery artworkImageForPlaylist:self.playList];
        cell.name.text=self.playList.name;
        cell.total.text=[NSString stringWithFormat:@"%d 首歌曲",(int)self.playList.count];
        return cell;
    }
    else if (indexPath.section==1){
        ShufflePlayHeaderCell* cell=[tableView dequeueReusableCellWithIdentifier:@"ShufflePlayHeaderCell" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.section==2) {
        SongCell* cell=[tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
        
        MPMediaItem* item=[self.playList.items objectAtIndex:indexPath.row];
        
        MPMediaItemArtwork* artwork=item.artwork;
        UIImage* img=[artwork imageWithSize:cell.image.bounds.size];
        cell.image.image=img;
        
        NSString* title=item.title;
        cell.name.text=title;
        
        NSString* artist=item.artist;
        cell.artist.text=artist;
        
        int min=item.playbackDuration/60;
        int sec=item.playbackDuration-min*60;
        NSString* duration=[NSString stringWithFormat:@"%d:%02d",min,sec];
        cell.duration.text=duration;
        
        //
        //    BOOL isThis=self.currentPlayingInfo.playingItem.persistentID==item.persistentID;
        //    cell.backgroundColor=isThis?[UIColor redColor]:[UIColor whiteColor];
        
        return cell;
    }
    return [[UITableViewCell alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        MPMediaItem* medi=[[self.playList items]objectAtIndex:(arc4random()%self.playList.count)];
        AudioPlayer* player=[AudioPlayer sharedAudioPlayer];
        [player shuffle:YES];
        [player setPlayingMediaItem:medi inPlayList:self.playList];
    }
    else if (indexPath.section==2) {
        MPMediaItem* medi=[[self.playList items]objectAtIndex:indexPath.row];
        AudioPlayer* player=[AudioPlayer sharedAudioPlayer];
        [player setPlayingMediaItem:medi inPlayList:self.playList];
    }
    
}

-(void)handlePlayingInfo:(PlayingInfoModel *)info
{
//    MPMediaItem* playing=info.playingItem;
//    NSArray* cells=[self.tableView visibleCells];
//    for (UITableViewCell* ce in cells) {
//        NSIndexPath* indexPath=[self.tableView indexPathForCell:ce];
//        MPMediaItem* item=[[self.playList items]objectAtIndex:indexPath.row];
//        BOOL isThis=playing.persistentID==item.persistentID;
//        ce.backgroundColor=isThis?[UIColor redColor]:[UIColor whiteColor];
//    }
}

@end
