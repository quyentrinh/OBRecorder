//
//  OBRecorderVC.h
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBRecorderVC;

@protocol OBRecorderVCDelegate <NSObject>

- (void)OBRecorderDidCancelWithMessage:(NSString*_Nullable) message;

- (void)OBRecorderDidFinishWithVideoPath:(NSString*_Nullable) videoPath;

@end

@interface OBRecorderVC : UIViewController

@property (nonatomic, weak, nullable) id <OBRecorderVCDelegate> delegate;

- (instancetype _Nonnull )initWithMaxRecordingTime:(CGFloat)maxRecordingTime autoSaveVideo:(BOOL)isAutoSave delegate: (nonnull id<OBRecorderVCDelegate>)delegate;

- (void)terminate;

@end
