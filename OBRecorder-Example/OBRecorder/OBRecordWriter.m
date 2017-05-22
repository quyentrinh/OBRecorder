//
//  OBRecordWriter.m

//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import "OBRecordWriter.h"


@interface OBRecordWriter ()

@property (nonatomic, copy, readwrite) NSString *videoPath;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetAudioInput;

@end

@implementation OBRecordWriter

- (void)dealloc {
    
    _assetWriter     = nil;
    _assetVideoInput = nil;
    _assetAudioInput = nil;
    _videoPath       = nil;
}

+ (instancetype)recordingWriterWithVideoPath:(NSString*)videoPath
                             resolutionWidth:(NSInteger)width
                            resolutionHeight:(NSInteger)height
                                audioChannel:(int)channel
                                  sampleRate:(Float64)rate
{
    return [[self alloc] initWithVideoPath:videoPath resolutionWidth:width resolutionHeight:height audioChannel:channel sampleRate:rate];
}

- (instancetype)initWithVideoPath:(NSString*)videoPath
                  resolutionWidth:(NSInteger)width
                 resolutionHeight:(NSInteger)height
                     audioChannel:(int)channel
                       sampleRate:(Float64)rate
{
    self = [super init];
    if (self) {
        _videoPath = videoPath;
        [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
        _assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:self.videoPath] fileType:AVFileTypeMPEG4 error:nil];
        _assetWriter.shouldOptimizeForNetworkUse = YES;
        
        {
            NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                      @(width), AVVideoWidthKey,
                                      @(height), AVVideoHeightKey, nil];
            _assetVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
            _assetVideoInput.expectsMediaDataInRealTime = YES;             [_assetWriter addInput:_assetVideoInput];
        }
        
        if (channel != 0 && rate != 0) {
            NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:@(kAudioFormatMPEG4AAC), AVFormatIDKey,
                                      @(channel), AVNumberOfChannelsKey,
                                      @(rate), AVSampleRateKey,
                                      @(128000), AVEncoderBitRateKey, nil];
            _assetAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
            _assetAudioInput.expectsMediaDataInRealTime = YES;
            [_assetWriter addInput:_assetAudioInput];
        }
    }
    return self;
}

- (BOOL)writeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo {
    
    BOOL isSuccess = NO;
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (_assetWriter.status == AVAssetWriterStatusUnknown && isVideo) {             [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        if (_assetWriter.status == AVAssetWriterStatusFailed) {
            NSLog(@"write error %@", _assetWriter.error.localizedDescription);
            isSuccess = NO;
        }
        
        if (isVideo) {
            if (_assetVideoInput.readyForMoreMediaData) {
                [_assetVideoInput appendSampleBuffer:sampleBuffer];
                isSuccess = YES;
            }
        } else {
            if (_assetAudioInput.readyForMoreMediaData) {
                [_assetAudioInput appendSampleBuffer:sampleBuffer];
                isSuccess = YES;
            }
        }
    }
    return isSuccess;
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
    
    [_assetWriter finishWritingWithCompletionHandler:handler];
}

@end

