//
//  MyAudioPlayer.h
//  mux
//
//  Created by dabby on 2018/12/5.
//  Copyright © 2018 Jam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface MyAudioPlayer : AVAudioPlayer

@property (nonatomic, strong) NSMutableData *pcmData;

@end
