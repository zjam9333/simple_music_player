//
//  MyAudioPlayer.h
//  mux
//
//  Created by dabby on 2018/12/5.
//  Copyright © 2018 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
@interface HisAudioPlayer : AVAudioPlayer

@property (nonatomic, strong) NSMutableData *pcmData;

@end

@protocol AVAudioPlayerDelegate;

@interface MyAudioPlayer : NSObject

@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id<AVAudioPlayerDelegate> delegate;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError;
- (void)play;
- (void)pause;
- (void)stop;

@end
