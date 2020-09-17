//
//  KDHelpers.h
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KDHelpers : NSObject

+ (UIView *)circleWithColor:(UIColor *)color
                     radius:(float)radius
                borderWidth:(float)borderWidth;

+ (void)wait:(double)delayInSeconds then:(void(^)(void))callback;

+ (void)async:(void(^)(void))callback;

+ (float)getPanPosition:(UIGestureRecognizer *)sender;

+ (UIView*)popupWithClose:(BOOL)close
          withCloseTarget:(id)target
         forCloseSelector:(SEL)selector
                withColor:(UIColor*)color
           withBlurAmount:(float)blur;

+ (UIViewController*)currentTopViewController;

+ (NSAttributedString*)underlinedString:(NSString*)string;

+ (BOOL)headsetPluggedIn;

+ (BOOL)isIpad;
+ (BOOL)isIpadPro_1366;

+ (float)getVolume;

+ (UILabel*)makeLabelWithWidth:(CGFloat)width
                     andHeight:(CGFloat)height;

+ (UILabel*)makeLabelWithWidth:(CGFloat)width
                   andFontSize:(CGFloat)size
                  andAlignment:(NSTextAlignment)align;

+ (void)setLabelHeightFor:(UILabel*)label
                 fontSize:(CGFloat)size
                 fontName:(NSString*)fontName
                 withText:(NSString*)text;

+ (void)appendView:(UIView*)view
            toView:(UIView*)source
       withMarginY:(CGFloat)y
        andIndentX:(CGFloat)x;

+ (void)setOriginX:(CGFloat)x
              andY:(CGFloat)y
           forView:(UIView*)view;

+ (void)setOriginX:(CGFloat)x
           forView:(UIView*)view;
+ (void)setOriginY:(CGFloat)y
           forView:(UIView*)view;
+ (void)setWidth:(CGFloat)width
         forView:(UIView*)view;

+ (void)setHeight:(CGFloat)height
          forView:(UIView*)view;

+ (void)addGradientMaskToView:(UIView*)view;

+ (BOOL)iPhoneXCheck;

+ (void)centerView:(UIView*)view
            onView:(UIView*)target;

+ (UILabel*)makeLabelWithWidth:(CGFloat)width
                  andAlignment:(NSTextAlignment)align;

// + (void)setLabelHeightFor:(UILabel*)label fontSize:(CGFloat)size fontName:(NSString*)fontName withText:(NSString*)text;
@end
