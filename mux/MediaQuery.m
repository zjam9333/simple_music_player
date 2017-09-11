//
//  MediaQuery.m
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import "MediaQuery.h"

static NSMutableDictionary* artworkImageDictionary;

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

+(UIImage*)artworkImageForPlaylist:(MPMediaPlaylist*)playlist
{
    if (artworkImageDictionary==nil) {
        artworkImageDictionary=[NSMutableDictionary dictionary];
    }
    
    NSString* key=[NSString stringWithFormat:@"playlist:%@,%d",playlist.name,(int)playlist.persistentID];
    UIImage* img=[artworkImageDictionary valueForKey:key];
    if (img) {
        return img;
    }
    
    NSArray* items=playlist.items;
    NSMutableArray* fourArtworks=[NSMutableArray array];
    
    MPMediaEntityPersistentID lastAlbumPersistenId=0;
    
    for (MPMediaItem* item in items) {
        MPMediaEntityPersistentID thisAlbumId=item.albumPersistentID;
        if (thisAlbumId!=lastAlbumPersistenId) {
            MPMediaItemArtwork* artwork=item.artwork;
            if (artwork) {
                [fourArtworks addObject:artwork];
                lastAlbumPersistenId=thisAlbumId;
                if (fourArtworks.count==4) {
                    break;
                }
            }
        }
    }
    
    if (fourArtworks.count>=4) {
        
        CGSize smallSize=CGSizeMake(256, 256);
        CGSize largeSize=CGSizeMake(512, 512);
        UIGraphicsBeginImageContext(largeSize);
        for (int i=0; i<4; i++) {
            MPMediaItemArtwork* ar=[fourArtworks objectAtIndex:i];
            UIImage* smallImage=[ar imageWithSize:smallSize];
            [smallImage drawInRect:CGRectMake((i%2)*smallSize.width, (i/2)*smallSize.height, smallSize.width, smallSize.height)];
        }
        UIImage *imageC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [artworkImageDictionary setValue:imageC forKey:key];
        
        return imageC;
    }
    else
    {
        MPMediaItemArtwork* artwork=[fourArtworks firstObject];
        UIImage* imageC=[artwork imageWithSize:CGSizeMake(512, 512)];
        
        [artworkImageDictionary setValue:imageC forKey:key];
        
        return imageC;
    }
    
    return nil;
}

@end
