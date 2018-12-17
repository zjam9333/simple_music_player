//
//  AllPlayListController.m
//  mux
//
//  Created by Jam on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "AllPlayListController.h"
#import "MediaQuery.h"
#import "PlayListCell.h"
#import "OnePlayListController.h"

@interface AllPlayListController ()
@property (nonatomic,strong)NSArray* playListArray;
@end

@implementation AllPlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.title=@"播放列表";
    
    self.tableView.rowHeight=64;
    
    self.playListArray=[MediaQuery allPlaylists];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayListCell" bundle:nil] forCellReuseIdentifier:@"PlayListCell"];
    
    // Do any additional setup after loading the view.
    self.refreshControl=[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshAllPlayList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshAllPlayList
{
    self.playListArray=[MediaQuery allPlaylists];
    [self.tableView reloadData];
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return self.playListArray.count;
}

//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section==1) {
//        return @"所有播放列表";
//    }
//    return nil;
//}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayListCell* cell=[tableView dequeueReusableCellWithIdentifier:@"PlayListCell" forIndexPath:indexPath];
    
    if (indexPath.section==0) {
        cell.name.text=@"所有歌曲";
        cell.image.image=nil;
        cell.progressButton.hidden=YES;
    }
    else
    {
        NSInteger index=indexPath.row;
        
        MPMediaPlaylist* list=[self.playListArray objectAtIndex:index];
        NSString* name=[list valueForProperty:MPMediaPlaylistPropertyName];
        
        cell.name.text=name;
        cell.count.text=[NSString stringWithFormat:@"%d首歌",(int)list.count];
        cell.image.image=[MediaQuery artworkImageForPlaylist:list];
        
        BOOL isThis=list.persistentID==self.currentPlayingInfo.playingList.persistentID;
        
        PlayingProgressButton* ppb=cell.progressButton;
        ppb.hidden=!isThis;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
//        one.items=[MediaQuery allSongs];
        //play all song;
    }
    else
    {
        OnePlayListController* one=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OnePlayListController"];
        MPMediaPlaylist* list=[self.playListArray objectAtIndex:indexPath.row];
        one.playList=list;
        [self.navigationController pushViewController:one animated:YES];
    }
    
}

-(void)handlePlayingInfo:(PlayingInfoModel *)info
{
//    NSArray* cells=[self.ta]
    MPMediaPlaylist* list=info.playingList;
    NSInteger isplay=info.playing.integerValue;
    CGFloat progress=info.currentTime.floatValue/info.playbackDuration.floatValue;
    NSArray* cells=[self.tableView visibleCells];
    for (UITableViewCell* ce in cells) {
        
        NSIndexPath* indexPath=[self.tableView indexPathForCell:ce];
        
        if ([ce isKindOfClass:[PlayListCell class]]&&indexPath.section==1) {
            MPMediaPlaylist* thatlist=[self.playListArray objectAtIndex:indexPath.row];
            BOOL isThis=list.persistentID==thatlist.persistentID;
            
            PlayingProgressButton* ppb=((PlayListCell*)ce).progressButton;
            ppb.hidden=!isThis;
            ppb.progress=progress;
            ppb.currentState=isplay;
        }
    }

}

@end
