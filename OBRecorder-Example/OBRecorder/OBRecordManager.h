//
//  OBRecordManager.h

//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol OBRecordManagerDelegate <NSObject>

- (void)updateRecordingProgress:(CGFloat)progress;

@end

@interface OBRecordManager : NSObject

@property (nonatomic, weak) id<OBRecordManagerDelegate> delegate;

@property (nonatomic, assign) CGFloat maxRecordingTime;

@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, assign) BOOL autoSaveVideo;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (void)startCapture;
- (void)stopCapture;

- (void)startRecoring;
- (void)stopRecoring;
- (void)stopRecordingHandler:(void (^)(UIImage *movieImage))handler;

- (void)switchCameraInputDeviceToFront;
- (void)swithCameraInputDeviceToBack;

- (void)saveCurrentRecordingVideo;

@end
