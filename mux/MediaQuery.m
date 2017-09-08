//
//  MediaQuery.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "MediaQuery.h"

@implementation MediaQuery

+(NSArray*)allPlaylists
{
    NSArray* array=[[MPMediaQuery playlistsQuery]collections];
    return array;
}

+(NSArray*)allSongs
{
    NSArray* array=[[MPMediaQuery songsQuery]items];
    return array;
}

@end
