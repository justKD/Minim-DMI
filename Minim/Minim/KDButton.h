//
//  KDButton.h
//
//  Created by Cady Holmes on 2/26/18.
//  Copyright © 2018-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"

typedef void(^TapCallback)(UITapGestureRecognizer *sender);

@interface KDButton : UIView {
    UILabel *label;
    UITapGestureRecognizer *tap;
}

@property (nonatomic) int uid;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSAttributedString* attributedText;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic) NSString* fontName;
@property (nonatomic) float fontSize;
@property (nonatomic, copy) TapCallback tapCallback;

+ (KDButton *)initWithID:(int)uid;
+ (KDButton *)initWithID:(int)uid andWidth:(CGFloat)width andText:(NSString*)text;
- (void)underline;
- (void)setTapAction:(void(^)(UITapGestureRecognizer *sender))callback;

@end
