//
//  OneAlbumController.m
//  mux
//
//  Created by iMac206 on 16/8/15.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "OneAlbumController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OnePlayListController.h"
#define cellHeight 54

@interface OneAlbumController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray* items;
}
@end

@implementation OneAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    items=[self getAlbums];
    
    UITableView* table=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.tableFooterView=[[UIView alloc]init];
    table.dataSource=self;
    table.delegate=self;
    table.rowHeight=cellHeight;
    [self.view addSubview:table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

-(NSArray*)getAlbums
{
    NSArray* array=[[MPMediaQuery albumsQuery]collections];
    NSMutableArray* result=[NSMutableArray array];
    for(MPMediaItemCollection* col in array)
    {
        MPMediaItem* it=col.representativeItem;
        if([[[it valueForProperty:MPMediaItemPropertyArtist]uppercaseString]isEqualToString:[[self.representiveItem valueForProperty:MPMediaItemPropertyArtist]uppercaseString]])
        {
            [result addObject:col];
        }
    }
    return [NSArray arrayWithArray:result];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* iden=@"oneplaylistcell";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:iden];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
        cell.backgroundColor=[UIColor whiteColor];
        cell.opaque=YES;
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
    UILabel* labv=[cell.contentView viewWithTag:102];
    UILabel* lab2=[cell.contentView viewWithTag:103];
    
    MPMediaItemCollection* ablum=[items objectAtIndex:indexPath.row];
    MPMediaItem* item=ablum.representativeItem;
    
    NSString* title=item.title;
    labv.text=title;
    
    lab2.text=[NSString stringWithFormat:@"%ld",(long)ablum.items.count];
    
    MPMediaItemArtwork* artwork=item.artwork;
    UIImage* img=[artwork imageWithSize:imgv.bounds.size];
    imgv.image=img;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MPMediaPlaylist* list=[items objectAtIndex:indexPath.row];
    OnePlayListController* one=[[OnePlayListController alloc]init];
    one.title=[list valueForProperty:MPMediaPlaylistPropertyName];
    one.items=list.items;
    [self.navigationController pushViewController:one animated:YES];
}

@end
