//
//  OBToolBarButton.m
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/23/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import "OBToolBarButton.h"

@interface OBToolBarButton () {
    
    UIImage *imageOfButton;
    UIColor *bgrColorOfButton;
    void (^buttonTappedBlock)(void);
}

@end

@implementation OBToolBarButton

- (id)initToolBarButtonType: (OBTOOLBUTTONTYPE) type
                  withFrame: (CGRect) frame
                   andImage: (UIImage *) image
         andBackgroundColor: (UIColor *) bgrColor
                  andAction: (void (^ __nullable)(void))actionTapped {
    
    imageOfButton = image;
    bgrColorOfButton = bgrColor;
    buttonTappedBlock = actionTapped;
    return [self initToolBarButtonType:type withFrame:frame];
}


- (id)initToolBarButtonType: (OBTOOLBUTTONTYPE) type withFrame: (CGRect)frame {
    switch (type) {
        case OBToolButtonTop:
            return [self initTopBarButtonWithFrame:frame];
            break;
        case OBToolButtonBottom:
            return [self initBottomBarButtonWithFrame:frame];
            break;
        default:
            break;
    }
}


-  (id)initBottomBarButtonWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        self.backgroundColor = bgrColorOfButton;
        [self setImage:imageOfButton forState:UIControlStateNormal];
        self.layer.cornerRadius = aRect.size.width * 0.5;
        [self addTarget:self action:@selector(buttonTappedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

-  (id)initTopBarButtonWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        self.backgroundColor = bgrColorOfButton;
        [self setImage:imageOfButton forState:UIControlStateNormal];
        [self addTarget:self action:@selector(buttonTappedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)buttonTappedAction {
    if (buttonTappedBlock) {
        buttonTappedBlock();
    }
}

@end
