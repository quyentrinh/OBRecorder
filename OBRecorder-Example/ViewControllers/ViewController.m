//
//  ViewController.m
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import "ViewController.h"
#import "OBRecorderVC.h"

@interface ViewController ()

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
    OBRecorderVC *recordVC = [[OBRecorderVC alloc] init];
    [self presentViewController:recordVC animated:YES completion:nil];
}


@end
