//
//  MediaQuery.h
//  mux
//
//  Created by bangju on 2017/9/8.
//  Copyright © 2017年 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MediaQuery : NSObject

+(NSArray*)allPlaylists;

+(NSArray*)allAlbums;

+(NSArray*)allSongs;

//+(UIImage*)artworkImageForSongs:(NSArray*)songs;
+(UIImage*)artworkImageForPlaylist:(MPMediaPlaylist*)playlist;

@end
