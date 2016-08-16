//
//  AllArtistController.m
//  mux
//
//  Created by iMac206 on 16/8/15.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "AllArtistController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "OnePlayListController.h"
#import "PlayingController.h"
#import "OneAlbumController.h"

#define cellHeight 64

@interface AllArtistController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray* playListArray;
@end

@implementation AllArtistController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self presentViewController:[PlayingController sharedInstantype] animated:YES completion:nil];
}

//-(instancetype)init
//{
//    self=[super init];
//    if (self) {
//        self.title=@"artist";
//        self.tabBarController.title=@"artist";
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.playListArray=[self getArtists];
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

-(NSArray*)getArtists
{
    NSArray* array=[[MPMediaQuery artistsQuery]collections];
    for (MPMediaItemCollection *list in array)
    {
        MPMediaItem* item=list.representativeItem;
        NSLog (@"Artists:%@",[item valueForProperty:MPMediaItemPropertyArtist]);
    }
    return array;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playListArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* iden=@"allartistcell";
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
    NSInteger index=indexPath.row;
    MPMediaPlaylist* list=[self.playListArray objectAtIndex:index];
    MPMediaItem* item=list.representativeItem;
    NSString* name=[item valueForProperty:MPMediaItemPropertyArtist];
    lab1.text=name;
    lab2.text=[NSString stringWithFormat:@"%d",(int)list.items.count];
    imgv.image=[item.artwork imageWithSize:imgv.frame.size];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OneAlbumController* one=[[OneAlbumController alloc]init];
    NSInteger row=indexPath.row;
    MPMediaItemCollection* list=[self.playListArray objectAtIndex:row];
    MPMediaItem* item=list.representativeItem;
//    items=list.items;
    one.title=[item valueForProperty:MPMediaItemPropertyArtist];
    one.representiveItem=item;
    
    [self.navigationController pushViewController:one animated:YES];
}

@end
