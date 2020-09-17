//
//  KDAccelView.h
//
//  Created by Cady Holmes.
//  Copyright (c) 2015-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreGraphics/CoreGraphics.h>

static inline float FILTER(float input,float lastInput,float k) {return k*lastInput+(1.0-k)*input;}
static inline float CLIP(float input,float min,float max) {return MAX(min,MIN(max,input));}
static inline float SCALE(float input,float min1,float max1,float min2,float max2) {return (((input-min1)*(max2-min2))/(max1-min1))+min2;}

@protocol KDAccelViewDelegate;
@interface KDAccelView : UIView {
    CMDeviceMotion *deviceMotion;
    CMAttitude *currentAttitude;
    CMMotionManager *motionManager;
    NSTimer *timer;
    NSDictionary *lastAccelDict;
    double lastAcceleration;
    double lastX;
    double lastY;
    double lastZ;
    UIColor *shadowColor;
    UIImageView *dotImage;
    UIImageView *shadowImageView;
    UIImageView *imageView;
    BOOL isPlane;
    BOOL canTap;
    BOOL isStopped;
    BOOL roundValues;
}

@property (nonatomic, weak) id<KDAccelViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *parentView;
@property (nonatomic, readonly) double pitch;
@property (nonatomic, readonly) double yaw;
@property (nonatomic, readonly) double roll;
@property (nonatomic, readonly) double acceleration;
@property (nonatomic) int uid;
@property (nonatomic) double resolution;
@property (nonatomic) double interval;
@property (nonatomic) BOOL transformsWithAngles;
@property (nonatomic) BOOL transformsWithAcceleration;
@property (nonatomic) BOOL exposesAngles;
@property (nonatomic) BOOL exposesAcceleration;
@property (nonatomic) BOOL logsStuff;
@property (nonatomic) BOOL hasOutline;

+ (KDAccelView *)initWithID:(int)uid;
- (void)startPolling;
- (void)stopPolling;
- (void)visualizeOnView:(UIView *)view;
- (void)centerAt:(CGPoint)center;
- (void)canShakeToReset:(BOOL)shakeReset;
- (void)canTapToReset:(BOOL)tapReset;
- (void)setShadowColor:(UIColor *)color;
- (void)roundToTwoDecimals:(BOOL)round;

@end

@protocol KDAccelViewDelegate <NSObject>
- (void)KDAccelUpdate:(kdAccelView *)accel;
@end

/* Example Use */

/*
 
@interface ViewController () <KDAccelViewDelegate>
 
#pragma KDAccelView
 
- (void)setupAccel {
 
//- initialize and add delegate to controller ^
//- declare parent view
//- set center
//- set instance delegate
//- set options (options default to NO)
 
    KDAccelView *accel = [KDAccelView initWithID:1];
    [accel visualizeOnView:self.view];
    [accel centerAt:CGPointMake(50, 50)];
    [accel setDelegate:self];
 
    //[accel canTapToReset:YES];
    //[accel canShakeToReset:YES];
    //[accel setLogsStuff:YES];
    //[accel roundToTwoDecimals:YES];
    //[accel setShadowColor:[UIColor blackColor];
    //[accel setHidden:YES];
 
    //start/stop polling (on by default)
    //[accel startPolling];
    //[accel stopPolling];
}

// KDAccelView Delegate Method
- (void)KDAccelUpdate:(KDAccelView *)accel {
    float pitch = accel.pitch;
    float yaw = accel.yaw;
    float roll = accel.roll;
 
    //do stuff with pitch, yaw, and roll
}
 
*/

