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
#import "AudioPlayer.h"

@interface OnePlayListController ()

@end

@implementation OnePlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight=54;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil] forCellReuseIdentifier:@"SongCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playList.items.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return self.playList.name;
    }
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MPMediaItem* medi=[[self.playList items]objectAtIndex:indexPath.row];
    
    AudioPlayer* player=[AudioPlayer sharedAudioPlayer];
    [player setPlayingMediaItem:medi inPlayList:self.playList];
}

@end
