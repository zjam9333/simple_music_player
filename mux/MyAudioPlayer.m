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

static const int kNumberBuffers = 3;                              // 1
struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[kNumberBuffers];       // 4
    AudioFileID                   mAudioFile;                     // 5
    UInt32                        bufferByteSize;                 // 6
    SInt64                        mCurrentPacket;                 // 7
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
    bool                          mIsRunning;                     // 10
};

typedef struct AQPlayerState AQPlayerState;

@implementation MyAudioPlayer {
    AQPlayerState aqData;
}

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

- (BOOL)play {
    
    
    return [super play];
}

- (void)readPCMData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{// 我现在知道通过（采样率、声道数、时长）可以计算出样品个数
//        NSInteger sampleCount = self.duration * sampleRate * channelCount;
//
//        NSMutableData *sampleData = [NSMutableData dataWithLength:sampleCount];
//        self.pcmData = sampleData;
//
//        if (!self.url) {
//            return;
//        }
//        AVAsset *asset = [AVAsset assetWithURL:self.url];
//        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
//        if (!reader) {
//            return;
//        }
//        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//        NSDictionary *dic = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
//                              AVLinearPCMIsBigEndianKey:@NO,
//                              AVLinearPCMIsFloatKey:@NO,
//                              AVLinearPCMBitDepthKey:@(bitDepth),
//                              AVSampleRateKey:@(sampleRate),
//                              AVNumberOfChannelsKey:@(channelCount),
//                              };
//        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc]initWithTrack:track outputSettings:dic];
//        [reader addOutput:output];
//        [reader startReading];
//
//        size_t readOffset = 0;
//        while (reader.status == AVAssetReaderStatusReading) {
//            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
//            if (sampleBuffer) {
//                CMBlockBufferRef blockBUfferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
//                size_t length = CMBlockBufferGetDataLength(blockBUfferRef);
//                if (readOffset + length > sampleCount) {
//                    length = sampleCount - readOffset;
//                }
//                Byte readSampleBytes[length];
//                CMBlockBufferCopyDataBytes(blockBUfferRef, 0, length, readSampleBytes);
//
//                [sampleData replaceBytesInRange:NSMakeRange(readOffset, length) withBytes:readSampleBytes length:length];
//                readOffset += length; // 修改当前已读数
//
//                CMSampleBufferInvalidate(sampleBuffer);//销毁
//                CFRelease(sampleBuffer); //释放
//            }
//        }
        
        // from https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQPlayback/PlayingAudio.html#//apple_ref/doc/uid/TP40005343-CH3-SW2
        
        // Opening an Audio File
        CFURLRef audioFileURL = ((__bridge CFURLRef)self.url);
//        OSStatus result =
        AudioFileOpenURL (audioFileURL, kAudioFileReadPermission, 0, &aqData.mAudioFile);
        CFRelease (audioFileURL);
        
        // Obtaining a File’s Audio Data Format
        UInt32 dataFormatSize = sizeof (aqData.mDataFormat);    // 1
        AudioFileGetProperty (aqData.mAudioFile, kAudioFilePropertyDataFormat, &dataFormatSize, &aqData.mDataFormat);
        
        // Create a Playback Audio Queue
        AudioQueueNewOutput (&aqData.mDataFormat, HandleOutputBuffer, &aqData, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &aqData.mQueue);
        
        // Set Sizes for a Playback Audio Queue
        UInt32 maxPacketSize;
        UInt32 propertySize = sizeof (maxPacketSize);
        AudioFileGetProperty (                               // 1
                              aqData.mAudioFile,                               // 2
                              kAudioFilePropertyPacketSizeUpperBound,          // 3
                              &propertySize,                                   // 4
                              &maxPacketSize                                   // 5
                              );
        
        DeriveBufferSize (                                   // 6
                          aqData.mDataFormat,                              // 7
                          maxPacketSize,                                   // 8
                          0.5,                                             // 9
                          &aqData.bufferByteSize,                          // 10
                          &aqData.mNumPacketsToRead                        // 11
                          );
        
        // Allocating Memory for a Packet Descriptions Array
        bool isFormatVBR = (                                       // 1
                            aqData.mDataFormat.mBytesPerPacket == 0 ||
                            aqData.mDataFormat.mFramesPerPacket == 0
                            );
        
        if (isFormatVBR) {                                         // 2
            aqData.mPacketDescs =
            (AudioStreamPacketDescription*) malloc (
                                                    aqData.mNumPacketsToRead * sizeof (AudioStreamPacketDescription)
                                                    );
        } else {                                                   // 3
            aqData.mPacketDescs = NULL;
        }
        
        // Set a Magic Cookie for a Playback Audio Queue
        UInt32 cookieSize = sizeof (UInt32);                   // 1
        bool couldNotGetProperty =                             // 2
        AudioFileGetPropertyInfo (                         // 3
                                  aqData.mAudioFile,                             // 4
                                  kAudioFilePropertyMagicCookieData,             // 5
                                  &cookieSize,                                   // 6
                                  NULL                                           // 7
                                  );
        
        if (!couldNotGetProperty && cookieSize) {              // 8
            char* magicCookie =
            (char *) malloc (cookieSize);
            
            AudioFileGetProperty (                             // 9
                                  aqData.mAudioFile,                             // 10
                                  kAudioFilePropertyMagicCookieData,             // 11
                                  &cookieSize,                                   // 12
                                  magicCookie                                    // 13
                                  );
            
            AudioQueueSetProperty (                            // 14
                                   aqData.mQueue,                                 // 15
                                   kAudioQueueProperty_MagicCookie,               // 16
                                   magicCookie,                                   // 17
                                   cookieSize                                     // 18
                                   );
            
            free (magicCookie);                                // 19
        }
        
        // Allocate and Prime Audio Queue Buffers
        aqData.mCurrentPacket = 0;                                // 1
        
        for (int i = 0; i < kNumberBuffers; ++i) {                // 2
            AudioQueueAllocateBuffer (                            // 3
                                      aqData.mQueue,                                    // 4
                                      aqData.bufferByteSize,                            // 5
                                      &aqData.mBuffers[i]                               // 6
                                      );
            
            HandleOutputBuffer (                                  // 7
                                &aqData,                                          // 8
                                aqData.mQueue,                                    // 9
                                aqData.mBuffers[i]                                // 10
                                );
        }
        
        // Set an Audio Queue’s Playback Gain
//        Float32 gain = 1.0;                                       // 1
//        // Optionally, allow user to override gain setting here
//        AudioQueueSetParameter (                                  // 2
//                                aqData.mQueue,                                        // 3
//                                kAudioQueueParam_Volume,                              // 4
//                                gain                                                  // 5
//                                );
        
        // Start and Run an Audio Queue
        aqData.mIsRunning = true;                          // 1
        
        AudioQueueStart (                                  // 2
                         aqData.mQueue,                                 // 3
                         NULL                                           // 4
                         );
        
        do {                                               // 5
            CFRunLoopRunInMode (                           // 6
                                kCFRunLoopDefaultMode,                     // 7
                                0.25,                                      // 8
                                false                                      // 9
                                );
        } while (aqData.mIsRunning);
        
        CFRunLoopRunInMode (                               // 10
                            kCFRunLoopDefaultMode,
                            1,
                            false
                            );
        
        // Clean Up After Playing
        AudioQueueDispose (                            // 1
                           aqData.mQueue,                             // 2
                           true                                       // 3
                           );
        
        AudioFileClose (aqData.mAudioFile);            // 4
        
        free (aqData.mPacketDescs);                    // 5
    });
}

static void HandleOutputBuffer (
                                void                *aqData,
                                AudioQueueRef       inAQ,
                                AudioQueueBufferRef inBuffer
                                ) {
    AQPlayerState *pAqData = (AQPlayerState *) aqData;        // 1
    if (pAqData->mIsRunning == 0) return;                     // 2
    UInt32 numBytesReadFromFile;                              // 3
    UInt32 numPackets = pAqData->mNumPacketsToRead;           // 4
    AudioFileReadPackets (
                          pAqData->mAudioFile,
                          false,
                          &numBytesReadFromFile,
                          pAqData->mPacketDescs,
                          pAqData->mCurrentPacket,
                          &numPackets,
                          inBuffer->mAudioData
                          );
    if (numPackets > 0) {                                     // 5
        inBuffer->mAudioDataByteSize = numBytesReadFromFile;  // 6
        AudioQueueEnqueueBuffer (
                                 pAqData->mQueue,
                                 inBuffer,
                                 (pAqData->mPacketDescs ? numPackets : 0),
                                 pAqData->mPacketDescs
                                 );
        pAqData->mCurrentPacket += numPackets;                // 7
    } else {
        AudioQueueStop (
                        pAqData->mQueue,
                        false
                        );
        pAqData->mIsRunning = false;
    }
}

static void DeriveBufferSize (
                       AudioStreamBasicDescription ASBDesc,                            // 1
                       UInt32                      maxPacketSize,                       // 2
                       Float64                     seconds,                             // 3
                       UInt32                      *outBufferSize,                      // 4
                       UInt32                      *outNumPacketsToRead                 // 5
) {
    static const int maxBufferSize = 0x50000;                        // 6
    static const int minBufferSize = 0x4000;                         // 7
    
    if (ASBDesc.mFramesPerPacket != 0) {                             // 8
        Float64 numPacketsForTime =
        ASBDesc.mSampleRate / ASBDesc.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {                                                         // 9
        *outBufferSize =
        maxBufferSize > maxPacketSize ?
        maxBufferSize : maxPacketSize;
    }
    
    if (                                                             // 10
        *outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize
        )
        *outBufferSize = maxBufferSize;
    else {                                                           // 11
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12
}

@end
