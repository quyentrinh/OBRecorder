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


#define TOP_BUTTON_SIZE                         44
#define TOP_BUTTON_MARGIN_TOP                   10

#define RECORD_BUTTON_SIZE                      90
#define BOTTOM_BUTTON_SIZE                      60
#define BOTTOM_TOOL_BAR_HEIGH                   150
#define BOTTOM_BUTTON_MARGIN_LEFT               30
#define BOTTOM_BUTTON_MARGIN_TOP                50

#define BUTTON_RECORD_COLOR                     [UIColor colorWithWhite:0.9 alpha:0.9];
#define BUTTON_RETAKE_COLOR                     [UIColor colorWithWhite:0.95 alpha:0.5];
#define BUTTON_DONE_COLOR                       [UIColor colorWithRed:52/255.0 green:204/255.0 blue:176/255.0 alpha:0.8];

#define VIDEO_DURATION                         10


@interface OBRecorderVC () <OBRecordManagerDelegate>

@property (nonatomic, strong) OBRecordManager *recordingManager;

@property (nonatomic, weak) UIView   *topBar;
@property (nonatomic, weak) UIButton *btnClose;
@property (nonatomic, weak) UIButton *btnTurnCamera;

@property (nonatomic, weak) UIView   *bottomBar;
@property (nonatomic, weak) OBRecorderButton *btnRecording;
@property (nonatomic, weak) UIButton *btnRetake;
@property (nonatomic, weak) UIButton *btnDone;

@property (nonatomic, strong)          NSTimer        *progressTimer;
@property (nonatomic)                  CGFloat        progress;

@end

@implementation OBRecorderVC

#pragma mark - LIFE CYCLE


- (OBRecordManager *)recordingManager {
    
    if (!_recordingManager) {
        _recordingManager = [[OBRecordManager alloc] init];
        _recordingManager.maxRecordingTime = 15.0;
        _recordingManager.delegate = self;
    }
    return _recordingManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self startRecording];
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
    [self setupCaptureArea];
}

- (void)setupTopBar {
    UIView *toolBar = [[UIView alloc] init];
    toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [self.view addSubview:toolBar];
    self.topBar = toolBar;
    
    UIButton *btnClose = [[UIButton alloc] init];
    btnClose.frame = CGRectMake(0, TOP_BUTTON_MARGIN_TOP, TOP_BUTTON_SIZE, TOP_BUTTON_SIZE);
    [btnClose setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnClose];
    self.btnClose = btnClose;
    
    UIButton *btnTurnCamera = [[UIButton alloc] init];
    btnTurnCamera.frame = CGRectMake(self.view.frame.size.width - TOP_BUTTON_SIZE - 5, TOP_BUTTON_MARGIN_TOP, TOP_BUTTON_SIZE, TOP_BUTTON_SIZE);
    [btnTurnCamera setImage:[UIImage imageNamed:@"ic_camera_turn"] forState:UIControlStateNormal];
    [btnTurnCamera addTarget:self action:@selector(turnCameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnTurnCamera];
    self.btnTurnCamera = btnTurnCamera;
}

- (void)setupBottomBar {
    UIView *bottomToolBar = [[UIView alloc] init];
    bottomToolBar.frame = CGRectMake(0, self.view.frame.size.height - BOTTOM_TOOL_BAR_HEIGH, self.view.frame.size.width, BOTTOM_TOOL_BAR_HEIGH);
    bottomToolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomToolBar];
    self.bottomBar = bottomToolBar;
    
    
    OBRecorderButton *startRecordingBtn = [[OBRecorderButton alloc] initWithFrame:CGRectMake((bottomToolBar.frame.size.width - RECORD_BUTTON_SIZE) * 0.5, (bottomToolBar.frame.size.height - RECORD_BUTTON_SIZE) * 0.5, RECORD_BUTTON_SIZE, RECORD_BUTTON_SIZE)];
    
    [startRecordingBtn addTarget:self action:@selector(startRecordingButtonTappeds) forControlEvents:UIControlEventTouchDown];
    [startRecordingBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [startRecordingBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpOutside];
    
    
    startRecordingBtn.buttonColor = BUTTON_RECORD_COLOR;
    startRecordingBtn.progressColor = BUTTON_DONE_COLOR;
    [bottomToolBar addSubview:startRecordingBtn];
    self.btnRecording = startRecordingBtn;
    
    UIButton *btnRetake = [[UIButton alloc] init];
    btnRetake.frame = CGRectMake(BOTTOM_BUTTON_MARGIN_LEFT, BOTTOM_BUTTON_MARGIN_TOP, BOTTOM_BUTTON_SIZE, BOTTOM_BUTTON_SIZE);
    btnRetake.backgroundColor = BUTTON_RETAKE_COLOR;
    [btnRetake setImage:[UIImage imageNamed:@"ic_retake"] forState:UIControlStateNormal];
    btnRetake.layer.cornerRadius = BOTTOM_BUTTON_SIZE * 0.5;
    btnRetake.layer.masksToBounds = YES;
    [btnRetake addTarget:self action:@selector(retakeRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:btnRetake];
    self.btnRetake = btnRetake;
    btnRetake.hidden = YES;
    
    
    UIButton *btnDone = [[UIButton alloc] init];
    btnDone.frame = CGRectMake(self.bottomBar.frame.size.width - BOTTOM_BUTTON_SIZE - BOTTOM_BUTTON_MARGIN_LEFT,  BOTTOM_BUTTON_MARGIN_TOP, BOTTOM_BUTTON_SIZE, BOTTOM_BUTTON_SIZE);
    btnDone.backgroundColor = BUTTON_DONE_COLOR;
    btnDone.layer.cornerRadius = BOTTOM_BUTTON_SIZE * 0.5;
    [btnDone setImage:[UIImage imageNamed:@"ic_done"] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(recordVideoDone) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:btnDone];
    self.btnDone = btnDone;
    btnDone.hidden = YES;
}

- (void)setupCaptureArea {
    
}


#pragma mark - SELECTOR ACTION

- (void)closeButtonTapped {
    NSLog(@"Recording has closed.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnCameraButtonTapped: (UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        NSLog(@"Camera turn to front.");
        [self.recordingManager switchCameraInputDeviceToFront];
    } else {
        NSLog(@"Camera turn to backside.");
        [self.recordingManager swithCameraInputDeviceToBack];
    }
}

- (void)startRecordingButtonTappeds {
    NSLog(@"Started recording");
    [self refreshProgress];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self.recordingManager startRecoring];
}

- (void)retakeRecording {
    NSLog(@"Retake recording.");
    [self refreshProgress];
}

- (void)recordVideoDone {
    NSLog(@"Recording has finished.");
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.recordingManager.videoPath]];
    [self presentViewController:playerViewController animated:YES completion:nil];

}

#pragma mark - MAIN ACTION

- (void)startRecording {
    self.recordingManager.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.recordingManager.previewLayer atIndex:0];
    [self.recordingManager startCapture];
}

- (void)stopRecording {
    NSLog(@"Stop recording");
    [self.progressTimer invalidate];
    [self.recordingManager stopRecordingHandler:^(UIImage *firstFrameImage) {
        [self setButton:_btnRetake hidden:NO];
        [self setButton:_btnDone hidden:NO];
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
    self.progress += 0.05 / VIDEO_DURATION;
    [self.btnRecording setProgress:self.progress];
    if (self.progress >= 1)
        [self.progressTimer invalidate];
}

- (void)refreshProgress {
    self.progress = 0;
    [self setButton:_btnRetake hidden:YES];
    [self setButton:_btnDone hidden:YES];
    [self.btnRecording setProgress:self.progress];
}

#pragma mark - Help Function

- (void)setButton:(UIButton *)button hidden:(BOOL)hidden {
    [UIView transitionWithView: button duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^(void){
        [button setHidden:hidden];
    } completion:nil];
}

@end
