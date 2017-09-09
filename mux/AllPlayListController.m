//
//  AllPlayListController.m
//  mux
//
//  Created by Jamm on 16/8/12.
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
    
    self.tableView.rowHeight=64;
    
    self.playListArray=[MediaQuery allPlaylists];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayListCell" bundle:nil] forCellReuseIdentifier:@"PlayListCell"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return self.playListArray.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return @"所有播放列表";
    }
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayListCell* cell=[tableView dequeueReusableCellWithIdentifier:@"PlayListCell" forIndexPath:indexPath];
    
    if (indexPath.section==0) {
        cell.name.text=@"所有歌曲";
        cell.image.image=nil;
    }
    else
    {
        NSInteger index=indexPath.row;
        
        MPMediaPlaylist* list=[self.playListArray objectAtIndex:index];
        NSString* name=[list valueForProperty:MPMediaPlaylistPropertyName];
        
        cell.name.text=name;
        
        NSArray* seeds=[list items];
        if (seeds.count>0) {
            MPMediaItem* item=[seeds objectAtIndex:0];
            MPMediaItemArtwork* artwork=item.artwork;
            UIImage* img=[artwork imageWithSize:cell.image.bounds.size];
            cell.image.image=img;
        }
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

@end
