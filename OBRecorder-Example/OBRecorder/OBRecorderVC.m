//
//  OBRecorderVC.m
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//




#import "OBRecorderVC.h"
#import <AVKit/AVKit.h>
#import "OBRecordWriter.h"
#import "OBRecordManager.h"
#import "OBRecorderButton.h"
#import "OBToolBarButton.h"


#define TOP_BUTTON_SIZE                         44
#define TOP_BUTTON_MARGIN_TOP                   10

#define RECORD_BUTTON_SIZE                      90
#define BOTTOM_BUTTON_SIZE                      60
#define BOTTOM_TOOL_BAR_HEIGH                   150
#define BOTTOM_BUTTON_MARGIN_LEFT               30
#define BOTTOM_BUTTON_MARGIN_TOP                50

#define BUTTON_RECORD_COLOR                     [UIColor colorWithWhite:0.9 alpha:0.9]
#define BUTTON_RETAKE_COLOR                     [UIColor colorWithWhite:0.95 alpha:0.5]
#define BUTTON_DONE_COLOR                       [UIColor colorWithRed:52/255.0 green:204/255.0 blue:176/255.0 alpha:0.8]


@interface OBRecorderVC () <OBRecordManagerDelegate>

@property (nonatomic, strong) OBRecordManager *recordingManager;

@property (nonatomic, weak) UIView   *topBar;
@property (nonatomic, weak) OBToolBarButton *btnClose;
@property (nonatomic, weak) OBToolBarButton *btnTurnCamera;

@property (nonatomic, weak) UIView   *bottomBar;
@property (nonatomic, weak) UILabel  *lblHint;
@property (nonatomic, weak) OBRecorderButton *btnRecording;
@property (nonatomic, weak) OBToolBarButton *btnRetake;
@property (nonatomic, weak) OBToolBarButton *btnDone;

@property (nonatomic)                  CGFloat          maxRecordingTime;
@property (nonatomic, strong)          NSTimer          *progressTimer;
@property (nonatomic)                  CGFloat          progress;
@property (nonatomic)                  BOOL             isAutoSaveVideo;
@property (nonatomic)                  BOOL             isUsingFrontCamera;
@end

@implementation OBRecorderVC


- (instancetype)initWithMaxRecordingTime:(CGFloat)maxRecordingTime autoSaveVideo:(BOOL)isAutoSave delegate: (nonnull id<OBRecorderVCDelegate>)delegate {
    self = [super init];
    if (self) {
        self.maxRecordingTime = maxRecordingTime;
        self.isAutoSaveVideo = isAutoSave;
        self.delegate = delegate;
    }
    return self;
}

- (OBRecordManager *)recordingManager {
    
    if (!_recordingManager) {
        _recordingManager = [[OBRecordManager alloc] init];
        _recordingManager.maxRecordingTime = _maxRecordingTime;
        _recordingManager.autoSaveVideo = _isAutoSaveVideo;
        _recordingManager.delegate = self;
    }
    return _recordingManager;
}


#pragma mark - LIFE CYCLE

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self startupCapture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SETUP UI

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self setupTopBar];
    [self setupBottomBar];
}

- (void)setupTopBar {
    UIView *toolBar = [[UIView alloc] init];
    toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [self.view addSubview:toolBar];
    self.topBar = toolBar;
    
    CGRect buttonCloseFrame = CGRectMake(0, TOP_BUTTON_MARGIN_TOP, TOP_BUTTON_SIZE, TOP_BUTTON_SIZE);
    OBToolBarButton *buttonClose = [[OBToolBarButton alloc] initToolBarButtonType:OBToolButtonTop
                                                                        withFrame:buttonCloseFrame
                                                                         andImage:[UIImage imageNamed:@"ic_close"]
                                                               andBackgroundColor:[UIColor clearColor]
                                                                        andAction:^{
                                                                            [self closeButtonTapped];
                                                                        }];
    [toolBar addSubview:buttonClose];
    self.btnClose = buttonClose;
    
    CGRect buttonTurnCameraFrame = CGRectMake(self.view.frame.size.width - TOP_BUTTON_SIZE - 5, TOP_BUTTON_MARGIN_TOP, TOP_BUTTON_SIZE, TOP_BUTTON_SIZE);
    OBToolBarButton *buttonTurnCamera = [[OBToolBarButton alloc]    initToolBarButtonType:OBToolButtonTop
                                                                                withFrame:buttonTurnCameraFrame
                                                                                 andImage:[UIImage imageNamed:@"ic_camera_turn"]
                                                                       andBackgroundColor:[UIColor clearColor]
                                                                                andAction:^{
                                                                                    [self turnCameraButtonTapped: self.isUsingFrontCamera];
                                                                                }];
 
    [toolBar addSubview:buttonTurnCamera];
    self.btnTurnCamera = buttonTurnCamera;
}

- (void)setupBottomBar {
    UIView *bottomToolBar = [[UIView alloc] init];
    bottomToolBar.frame = CGRectMake(0, self.view.frame.size.height - BOTTOM_TOOL_BAR_HEIGH, self.view.frame.size.width, BOTTOM_TOOL_BAR_HEIGH);
    bottomToolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomToolBar];
    self.bottomBar = bottomToolBar;
    
    
    CGRect hintLabelFrame = CGRectMake(0, 0, bottomToolBar.frame.size.width, 20);
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:hintLabelFrame];
    hintLabel.text = @"Hold to record video";
    [hintLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    hintLabel.layer.shadowRadius = 5.0;
    hintLabel.layer.shadowOpacity = 1;
    
    [bottomToolBar addSubview:hintLabel];
    self.lblHint = hintLabel;
    
    
    
    CGRect buttonRecordFrame = CGRectMake((bottomToolBar.frame.size.width - RECORD_BUTTON_SIZE) * 0.5, (bottomToolBar.frame.size.height - RECORD_BUTTON_SIZE) * 0.5, RECORD_BUTTON_SIZE, RECORD_BUTTON_SIZE);
    OBRecorderButton *startRecordingBtn = [[OBRecorderButton alloc] initWithFrame: buttonRecordFrame
                                                                     andMainColor: BUTTON_RECORD_COLOR
                                                                 andProgressColor: BUTTON_DONE_COLOR];
    
    [startRecordingBtn addTarget:self action:@selector(startRecordingButtonTappeds) forControlEvents:UIControlEventTouchDown];
    [startRecordingBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [startRecordingBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpOutside];

    [bottomToolBar addSubview:startRecordingBtn];
    self.btnRecording = startRecordingBtn;
    
    
    CGRect buttonRetakeFrame = CGRectMake(BOTTOM_BUTTON_MARGIN_LEFT, BOTTOM_BUTTON_MARGIN_TOP, BOTTOM_BUTTON_SIZE, BOTTOM_BUTTON_SIZE);
    OBToolBarButton *buttonRetake = [[OBToolBarButton alloc]     initToolBarButtonType:OBToolButtonBottom
                                                                             withFrame: buttonRetakeFrame
                                                                              andImage: [UIImage imageNamed:@"ic_retake"]
                                                                    andBackgroundColor: BUTTON_RETAKE_COLOR
                                                                             andAction: ^{
                                                                                 [self retakeRecording];
                                                                             }];
    buttonRetake.hidden = YES;
    [self.bottomBar addSubview:buttonRetake];
    self.btnRetake = buttonRetake;
    
    
    
    CGRect buttonDoneFrame = CGRectMake(self.bottomBar.frame.size.width - BOTTOM_BUTTON_SIZE - BOTTOM_BUTTON_MARGIN_LEFT,  BOTTOM_BUTTON_MARGIN_TOP, BOTTOM_BUTTON_SIZE, BOTTOM_BUTTON_SIZE);
    OBToolBarButton *buttonDone = [[OBToolBarButton alloc]   initToolBarButtonType: OBToolButtonBottom
                                                                         withFrame: buttonDoneFrame
                                                                          andImage: [UIImage imageNamed:@"ic_done"]
                                                                andBackgroundColor: BUTTON_DONE_COLOR
                                                                         andAction: ^{
                                                                             [self recordVideoDone];
                                                                         }];
    buttonDone.hidden = YES;
    [self.bottomBar addSubview:buttonDone];
    self.btnDone = buttonDone;

}

#pragma mark - SELECTOR ACTION

- (void)closeButtonTapped {
    NSString * message = @"OBRecorder : Close button have tapped.";
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(OBRecorderDidCancelWithMessage:)]) {
            [self.delegate OBRecorderDidCancelWithMessage:message];
        }
    });

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnCameraButtonTapped: (BOOL) isFrontCamera {
    if (!isFrontCamera) {
        NSLog(@"OBRecorder : Camera turn to front.");
        [self.recordingManager switchCameraInputDeviceToFront];
    } else {
        NSLog(@"OBRecorder : Camera turn to backside.");
        [self.recordingManager swithCameraInputDeviceToBack];
    }
    self.isUsingFrontCamera = !isFrontCamera;
}

- (void)startRecordingButtonTappeds {
    [self refreshProgress];
    [self setItem:_lblHint hidden:YES];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self startRecording];
}

- (void)retakeRecording {
    NSLog(@"OBRecorder : Retake recording.");
    [self refreshProgress];
}

- (void)recordVideoDone {
    NSLog(@"OBRecorder : Recording has finished.");
    if (_isAutoSaveVideo) {
        [self.recordingManager saveCurrentRecordingVideo];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(OBRecorderDidFinishWithVideoPath:)]) {
            [self.delegate OBRecorderDidFinishWithVideoPath:self.recordingManager.videoPath];
        }
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MAIN ACTION

- (void)startupCapture {
    self.recordingManager.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.recordingManager.previewLayer atIndex:0];
    [self.recordingManager startCapture];
}

- (void)startRecording {
    NSLog(@"OBRecorder : Start recording");
    [self.recordingManager startRecoring];
}

- (void)stopRecording {
    NSLog(@"OBRecorder : Stop recording");
    [self.progressTimer invalidate];
    [self.recordingManager stopRecordingHandler:^(UIImage *firstFrameImage) {
        [self setItem:_btnRecording hidden:YES];
        [self setItem:_btnRetake hidden:NO];
        [self setItem:_btnDone hidden:NO];
    }];
}


#pragma mark - SRRecordingManagerDelegate

- (void)updateRecordingProgress:(CGFloat)progress {

    if (progress >= 1.0) {
        [self stopRecording];
    }
}

#pragma mark - SRRecorderButton Action

- (void)updateProgress {
    self.progress += 0.05 / _maxRecordingTime;
    [self.btnRecording setProgress:self.progress];
    if (self.progress >= 1)
        [self.progressTimer invalidate];
}

- (void)refreshProgress {
    self.progress = 0;
    [self setItem:_lblHint hidden:NO];
    [self setItem:_btnRecording hidden:NO];
    [self setItem:_btnRetake hidden:YES];
    [self setItem:_btnDone hidden:YES];
    [self.btnRecording setProgress:self.progress];
}

#pragma mark - Help Function

- (void)setItem:(UIView *)view hidden:(BOOL)hidden {
    [UIView transitionWithView: view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [view setHidden:hidden];
    } completion:nil];
}

@end
