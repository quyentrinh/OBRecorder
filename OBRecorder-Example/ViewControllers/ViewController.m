//
//  ViewController.m
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import "ViewController.h"
#import "OBRecorderVC.h"

@interface ViewController () <OBRecorderVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startRecordingButtonTapped:(id)sender {
    OBRecorderVC *recordVC = [[OBRecorderVC alloc] initWithMaxRecordingTime:5.0 autoSaveVideo:YES delegate:self];
    [self presentViewController:recordVC animated:YES completion:nil];
}

#pragma mark - OBRecorderVCDelegate

- (void)OBRecorderDidCancelWithMessage:(NSString *)message {
    NSLog(@"%@", message);
}

- (void)OBRecorderDidFinishWithVideoPath:(NSString *)videoPath {
    NSLog(@"%@", videoPath);
}

@end
