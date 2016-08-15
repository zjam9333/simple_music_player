//
//  AllPlayListController.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "AllPlayListController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OnePlayListController.h"
#import "PlayingController.h"

#define cellHeight 64

@interface AllPlayListController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray* playListArray;
@end

@implementation AllPlayListController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self presentViewController:[PlayingController sharedInstantype] animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.title=@"playlist";
    self.title=@"playlist";
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.playListArray=[self getPlayLists];
    UITableView* table=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.tableFooterView=[[UIView alloc]init];
    table.dataSource=self;
    table.delegate=self;
    table.rowHeight=cellHeight;
    [self.view addSubview:table];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray*)getPlayLists
{
    NSArray* array=[[MPMediaQuery playlistsQuery]collections];
    for (MPMediaPlaylist *list in array)
    {
        NSString *listName = [list valueForProperty: MPMediaPlaylistPropertyName];
        NSLog (@"playlist:%@",listName);
    }
    return array;
}

-(NSArray*)getAllSongs
{
    NSArray* array=[[MPMediaQuery songsQuery]items];
    return array;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1+self.playListArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* iden=@"allplaylistcell";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:iden];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, cellHeight-20, cellHeight-20)];
        img.backgroundColor=[UIColor lightGrayColor];
        img.tag=101;
        [cell.contentView addSubview:img];
        
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(cellHeight, 10, (self.view.frame.size.width-cellHeight)*0.6, cellHeight-20)];
        lab.tag=102;
        lab.textAlignment=NSTextAlignmentLeft;
        [cell.contentView addSubview:lab];
        
        UILabel* lab2=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-90, 10, 60, cellHeight-20)];
        lab2.tag=103;
        lab2.textAlignment=NSTextAlignmentRight;
        lab2.textColor=[UIColor lightGrayColor];
        [cell.contentView addSubview:lab2];
    }
    UIImageView* imgv=[cell.contentView viewWithTag:101];
    UILabel* lab1=[cell.contentView viewWithTag:102];
    UILabel* lab2=[cell.contentView viewWithTag:103];
    if(indexPath.row==0)
    {
        imgv.image=nil;
        lab1.text=@"all songs";
        lab2.text=[NSString stringWithFormat:@"%d",(int)[self getAllSongs].count];
    }
    else
    {
        NSInteger index=indexPath.row-1;
        MPMediaPlaylist* list=[self.playListArray objectAtIndex:index];
        NSString* name=[list valueForProperty:MPMediaPlaylistPropertyName];
        lab1.text=name;
        lab2.text=[NSString stringWithFormat:@"%d",(int)list.items.count];
        NSArray* seeds=[list items];
        if (seeds.count>0) {
            MPMediaItem* item=[seeds objectAtIndex:0];
            MPMediaItemArtwork* artwork=item.artwork;
            UIImage* img=[artwork imageWithSize:imgv.bounds.size];
            imgv.image=img;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OnePlayListController* one=[[OnePlayListController alloc]init];
    NSArray* items=nil;
    if (indexPath.row==0) {
        items=[self getAllSongs];
        one.title=@"all songs";
        one.items=items;
    }
    else
    {
        NSInteger row=indexPath.row-1;
        MPMediaPlaylist* list=[self.playListArray objectAtIndex:row];
        items=list.items;
        one.title=[list valueForProperty:MPMediaPlaylistPropertyName];
        one.items=items;
    }
    [self.navigationController pushViewController:one animated:YES];
}

@end
