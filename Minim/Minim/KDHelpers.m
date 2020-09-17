//
//  KDHelpers.m
//
//  Created by Cady Holmes on 1/12/18.
//  Copyright © 2018-present Cady Holmes. All rights reserved.
//

#import "KDHelpers.h"

@implementation KDHelpers

+ (UIView*)circleWithColor:(UIColor *)color radius:(float)radius borderWidth:(float)borderWidth {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *knobPath = [UIBezierPath bezierPath];
    [knobPath addArcWithCenter:CGPointMake(circle.bounds.size.width/2, circle.bounds.size.height/2) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [knobPath CGPath];
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.fillColor = color.CGColor;
    layer.lineWidth = borderWidth;
    layer.lineJoin = kCALineJoinBevel;
    layer.strokeEnd = 1;
    layer.drawsAsynchronously = YES;
    
    [circle.layer addSublayer:layer];
    
    return circle;
}

+ (void)wait:(double)delayInSeconds then:(void(^)(void))callback {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        if(callback){
            callback();
        }
    });
    
    /*
     [self wait:<#(double)#> then:^{
     
     }];
     */
}

+ (void)async:(void(^)(void))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(callback){
            callback();
        }
    });
    
    /*
     [self async:^{
     
     }];
     */
}

+ (float)getPanPosition:(UIGestureRecognizer *)sender {
    float pos = [sender locationInView:sender.view].y;
    pos = 100 - ((pos/sender.view.frame.size.height) * 100);
    pos = MIN(pos, 100);
    pos = MAX(pos, 0);
    return pos;
}

+ (UIView*)popupWithClose:(BOOL)close withCloseTarget:(id)target forCloseSelector:(SEL)selector withColor:(UIColor*)color withBlurAmount:(float)blur {
    
    UIView *view = [[UIView alloc] initWithFrame:[KDHelpers currentTopViewController].view.frame];
    
    if (color) {
        [view setBackgroundColor:color];
    }
    
    if (blur) {
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

        visualEffectView.backgroundColor = color;

        visualEffectView.frame = view.bounds;
        visualEffectView.alpha = blur;

        [view addSubview:visualEffectView];
    }
    
    if (close) {
        float closeSize = 50;
        float marginSize = 20;
        if ([KDHelpers iPhoneXCheck]) {
            
        }
        UILabel *close = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.size.width-closeSize-marginSize, marginSize, closeSize, closeSize)];
        if ([KDHelpers iPhoneXCheck]) {
            close.frame = CGRectMake(view.bounds.size.width-closeSize-marginSize, marginSize*2, closeSize, closeSize);
        }
        [close setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30]];
        [close setUserInteractionEnabled:YES];
        [close setText:@"X"];
        [close setTextAlignment:NSTextAlignmentCenter];
        
        UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
        [close addGestureRecognizer:tapClose];
        
        [view addSubview:close];
    }
    
    return view;
}

+ (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (NSAttributedString*)underlinedString:(NSString*)string {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:string
                                                              attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    return str;
}

+ (BOOL)headsetPluggedIn {
    // Get array of current audio outputs (there should only be one)
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    
    NSString *portName = [[outputs objectAtIndex:0] portName];
    
    if ([portName isEqualToString:@"Headphones"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isIpad {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        return YES;
    }
    return NO;
}

+(BOOL) isIpadPro_1366
{

    if ([UIScreen mainScreen].bounds.size.height == 1366) {
        return  YES;
    }
    return NO;
}

+ (float)getVolume {
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    return vol;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.userInteractionEnabled = YES;
    
    return label;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andFontSize:(CGFloat)size andAlignment:(NSTextAlignment)align {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, size*1.1)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment = align;
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
    label.userInteractionEnabled = YES;
    
    return label;
}

+ (UILabel*)makeLabelWithWidth:(CGFloat)width andAlignment:(NSTextAlignment)align {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.preferredMaxLayoutWidth = width;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment = align;
    label.userInteractionEnabled = YES;
    return label;
}
+ (void)setLabelHeightFor:(UILabel*)label fontSize:(CGFloat)size fontName:(NSString*)fontName withText:(NSString*)text {
    if (!fontName) {
        fontName = @"HelveticaNeue-UltraLight";
    }
    label.font = [UIFont fontWithName:fontName size:size];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    label.frame = rect;
    label.text = text;
}

+ (void)setTextAndSizeToFitHeight:(UILabel*)label width:(CGFloat)width andFontSize:(CGFloat)size text:(NSString*)text {
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    label.frame = rect;
    label.text = text;
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, width, label.frame.size.height);
}

-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text{
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    return ceil(rect.size.height);
}

+ (void)appendView:(UIView*)view toView:(UIView*)source withMarginY:(CGFloat)y andIndentX:(CGFloat)x {
    CGRect frame = CGRectMake(source.bounds.origin.x + x,
                              source.frame.origin.y + source.frame.size.height + y,
                              view.frame.size.width,
                              view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setOriginX:(CGFloat)x andY:(CGFloat)y forView:(UIView*)view {
    CGRect frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setOriginX:(CGFloat)x forView:(UIView*)view {
    CGRect frame = CGRectMake(x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}

+ (void)setOriginY:(CGFloat)y forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    [view setFrame:frame];
}
+ (void)setWidth:(CGFloat)width forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
    [view setFrame:frame];
}
+ (void)setHeight:(CGFloat)height forView:(UIView*)view {
    CGRect frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
    [view setFrame:frame];
}

+ (void)addGradientMaskToView:(UIView*)view {
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = view.bounds;
    gradientMask.colors = @[(id)[UIColor clearColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor clearColor].CGColor];
    //gradientMask.locations = @[@0.0, @0.08, @0.92, @1.0];
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            gradientMask.locations = @[@0.0, @0.02, @0.98, @1.0];
        } else {
            gradientMask.locations = @[@0.0, @0.04, @0.96, @1.0];
        }
    } else {
        gradientMask.locations = @[@0.0, @0.08, @0.92, @1.0];
    }
    view.layer.masksToBounds = YES;
    view.layer.mask = gradientMask;
}

+ (BOOL)iPhoneXCheck {
    //NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //NSLog(@"iphone");
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (screenSize.height == 812) {
            //NSLog(@"iphone x");
            return YES;
        }
    }
    return NO;
}

+ (void)centerView:(UIView*)view onView:(UIView*)target {
    [view setCenter:CGPointMake(target.bounds.size.width/2, target.bounds.size.height/2)];
}

@end
