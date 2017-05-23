//
//  OBToolBarButton.h
//  OBRecorder-Example
//
//  Created by Trinh Van Quyen on 5/23/17.
//  Copyright © 2017 Trinh Van Quyen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    OBToolButtonTop,
    OBToolButtonBottom
} OBTOOLBUTTONTYPE;

@interface OBToolBarButton : UIButton

- (id _Nullable )initToolBarButtonType: (OBTOOLBUTTONTYPE) type
                  withFrame: (CGRect) frame
                   andImage: (UIImage *_Nullable) image
         andBackgroundColor: (UIColor *_Nullable) bgrColor
                  andAction: (void (^ __nullable)(void))actionTapped;

@end
