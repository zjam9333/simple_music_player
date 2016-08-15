//
//  OnePlayListController.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "OnePlayListController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayingController.h"
#define cellHeight 54

@interface OnePlayListController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation OnePlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    return self.items.count;
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
    
    MPMediaItem* item=[self.items objectAtIndex:indexPath.row];
    
    NSString* title=item.title;
    labv.text=title;
    
    int min=item.playbackDuration/60;
    int sec=item.playbackDuration-min*60;
    NSString* duration=[NSString stringWithFormat:@"%d:%02d",min,sec];
    lab2.text=duration;
    
    MPMediaItemArtwork* artwork=item.artwork;
    UIImage* img=[artwork imageWithSize:imgv.bounds.size];
    imgv.image=img;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [PlayingController sharedInstantype].playingList=self.items;
    MPMediaItem* playingItem=[[PlayingController sharedInstantype]currentItem];
    MPMediaItem* selectItem=[self.items objectAtIndex:indexPath.row];
    if (playingItem.persistentID!=selectItem.persistentID) {
        [PlayingController sharedInstantype].currentItem=selectItem;
    }
    [self presentViewController:[PlayingController sharedInstantype] animated:YES completion:nil];
}

@end
