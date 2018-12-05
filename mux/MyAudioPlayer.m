//
//  MyAudioPlayer.m
//  mux
//
//  Created by dabby on 2018/12/5.
//  Copyright © 2018 Jam. All rights reserved.
//

#import "MyAudioPlayer.h"
//#import <AudioToolbox/AudioToolbox.h>


const double sampleRate = 44100;
const NSInteger channelCount = 1;
const NSInteger bitDepth = 8;

@implementation MyAudioPlayer

- (void)dealloc {
    NSLog(@"dealloc: %@", self);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)outError {
    self = [super initWithContentsOfURL:url error:outError];
    if (self) {
        [self readPCMData];
    }
    return self;
}

- (void)readPCMData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{// 我现在知道通过（采样率、声道数、时长）可以计算出样品个数
        NSInteger sampleCount = self.duration * sampleRate * channelCount;
        
        NSMutableData *sampleData = [NSMutableData dataWithLength:sampleCount];
        self.pcmData = sampleData;

        if (!self.url) {
            return;
        }
        AVAsset *asset = [AVAsset assetWithURL:self.url];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
        if (!reader) {
            return;
        }
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        NSDictionary *dic = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                              AVLinearPCMIsBigEndianKey:@NO,
                              AVLinearPCMIsFloatKey:@NO,
                              AVLinearPCMBitDepthKey:@(bitDepth),
                              AVSampleRateKey:@(sampleRate),
                              AVNumberOfChannelsKey:@(channelCount),
                              };
        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc]initWithTrack:track outputSettings:dic];
        [reader addOutput:output];
        [reader startReading];
        
        size_t readOffset = 0;
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
            if (sampleBuffer) {
                CMBlockBufferRef blockBUfferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
                size_t length = CMBlockBufferGetDataLength(blockBUfferRef);
                if (readOffset + length > sampleCount) {
                    length = sampleCount - readOffset;
                }
                Byte readSampleBytes[length];
                CMBlockBufferCopyDataBytes(blockBUfferRef, 0, length, readSampleBytes);
                
                [sampleData replaceBytesInRange:NSMakeRange(readOffset, length) withBytes:readSampleBytes length:length];
                readOffset += length; // 修改当前已读数
                
                CMSampleBufferInvalidate(sampleBuffer);//销毁
                CFRelease(sampleBuffer); //释放
            }
        }
    });
}

@end
