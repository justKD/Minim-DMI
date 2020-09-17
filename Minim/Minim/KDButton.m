//
//  KDButton.m
//
//  Created by Cady Holmes on 2/26/18.
//  Copyright © 2018-present Cady Holmes. All rights reserved.
//

#import "KDButton.h"

@implementation KDButton

+ (KDButton *)initWithID:(int)uid {
    
    KDButton *button = [[KDButton alloc] init];
    button.uid = uid;
    
    return button;
}

+ (KDButton *)initWithID:(int)uid andWidth:(CGFloat)width andText:(NSString*)text {
    
    KDButton *button = [[KDButton alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    button.uid = uid;
    button.text = text;
    button.frame = CGRectMake(0, 0, width, 0);
    return button;
}

- (void)willMoveToSuperview:(UIView*)superview {
    [self initialize];
}

- (void)initialize {
    if (!self.alignment) {
        self.alignment = NSTextAlignmentCenter;
    }
    if (!self.fontSize) {
        self.fontSize = 20;
    }
    label = [KDHelpers makeLabelWithWidth:self.frame.size.width andAlignment:self.alignment];
    [KDHelpers setLabelHeightFor:label fontSize:self.fontSize fontName:self.fontName withText:self.text];
    if (self.attributedText) {
        label.text = nil;
        label.attributedText = self.attributedText;
    }
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, label.frame.size.height);
    self.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, label.bounds.size.height);
    [self addSubview:label];
}
- (void)underline {
    self.attributedText = [KDHelpers underlinedString:self.text];
}
- (void)setTapAction:(void(^)(UITapGestureRecognizer*sender))callback {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapCallback = callback;
    [self addGestureRecognizer:tap];
}
- (void)handleTap:(UITapGestureRecognizer*)sender {
    if (self.tapCallback) {
        self.tapCallback(tap);
    }
}

@end
