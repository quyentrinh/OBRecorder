//
//  OBRecordWriter.h

//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface OBRecordWriter : NSObject

@property (nonatomic, copy, readonly) NSString *videoPath;

+ (instancetype)recordingWriterWithVideoPath:(NSString*)videoPath
                             resolutionWidth:(NSInteger)width
                            resolutionHeight:(NSInteger)height
                                audioChannel:(int)channel
                                  sampleRate:(Float64)rate;

- (BOOL)writeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;

- (void)finishWritingWithCompletionHandler:(void (^)(void))completion;

@end
