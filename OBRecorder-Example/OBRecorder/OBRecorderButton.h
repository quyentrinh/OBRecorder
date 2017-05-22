//
//  OBRecorderButton.h
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/18/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBRecorderButton : UIButton

@property (nonatomic, strong) IBInspectable UIColor *buttonColor;
@property (nonatomic, strong) IBInspectable UIColor *progressColor;
@property (nonatomic, strong) CALayer *circleLayer;
@property (nonatomic, strong) CALayer *circleBorder;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *gradientMaskLayer;

- (void)setProgress:(CGFloat)newProgress;

@end
