//
//  KDAccelView.m
//
//  Copyright (c) 2017-present Cady Holmes. All rights reserved.
//

#import "KDAccelView.h"

@interface KDAccelView()

- (void)accelViewRotationTransformWithEulerAngleDictionary:(NSDictionary *)dict;
- (void)accelViewAccelerationTransform:(float)acceleration;
- (void)resetMotionManager;
- (void)startMotionManager;
- (void)stopMotionManager;
- (void)update;

@end

@implementation KDAccelView

/* See below for example uses */

-(BOOL)canBecomeFirstResponder {
    return YES;
}

+ (KDAccelView *)initWithID:(int)uid {
    
    KDAccelView *accel = [[KDAccelView alloc] init];
    if (uid) {
        accel.uid = uid;
    }
    [accel initialize];
    
    return accel;
}

//delegate methods
- (void)KDAccelUpdate {
    id<KDAccelViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(KDAccelUpdate:)]) {
        [strongDelegate KDAccelUpdate:self];
    }
}
///////


- (void)initialize {
    [self setDefaults];
    [self startMotionManager];
    [self startPolling];
}
- (void)setDefaults {
    shadowColor = [UIColor colorWithRed:(22/255.0) green:(22/255.0) blue:(22/255.0) alpha:1];
    self.transformsWithAcceleration = NO;
    self.transformsWithAngles = YES;
    self.exposesAcceleration = NO;
    self.exposesAngles = YES;
    self.logsStuff = NO;
    self.resolution = 1;
    self.interval = 1/60;
    self.hasOutline = NO;
    self.userInteractionEnabled = YES;
    isStopped = NO;
    [self canShakeToReset:NO];
    canTap = NO;
    roundValues = NO;
}
- (void)startPolling {
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(accelUpdateCallback:) userInfo:nil repeats:YES];
    }
}
- (void)stopPolling {
    [timer invalidate];
    timer = nil;
}
- (void)accelUpdateCallback:(NSTimer *)timer {
    [self update];
    [self KDAccelUpdate];
}
- (void)startMotionManager {
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
}
- (void)stopMotionManager {
    [motionManager stopDeviceMotionUpdates];
}
- (void)resetMotionManager {
    [self stopMotionManager];
    [self startMotionManager];
}
- (void)toggleAccel {
    if (!isStopped) {
        [self stopPolling];
        [self stopMotionManager];
        
        dotImage.alpha = 1;
        imageView.alpha = 0;
        shadowImageView.alpha = 0;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            dotImage.alpha = 0;
            imageView.alpha = 1;
            shadowImageView.alpha = 1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startPolling];
                [self startMotionManager];
            });
        });
    }
    isStopped = !isStopped;
}
- (void)update {
    if (self.exposesAngles == YES) {
        
        NSDictionary *noGimbal = [self noGimbalDict:lastAccelDict];
        lastAccelDict = noGimbal;
        
        double pitch = [[noGimbal objectForKey:@"pitch"] floatValue];
        double yaw = [[noGimbal objectForKey:@"yaw"] floatValue];
        double roll = [[noGimbal objectForKey:@"roll"] floatValue];

        pitch = SCALE(pitch, -0.5, 0.5, -1, 1);
        yaw = SCALE(yaw, -0.5, 0.5, 1, -1);
        roll = SCALE(roll, -0.5, 0.5, -1, 1);
        
        if (roundValues) {
            pitch = floorf(pitch * 100 + 0.5) / 100;
            yaw = floorf(yaw * 100 + 0.5) / 100;
            roll = floorf(roll * 100 + 0.5) / 100;
        }

        
        _pitch = pitch / self.resolution;
        _yaw = yaw / self.resolution;
        _roll = roll / self.resolution;
        
        if (self.logsStuff == YES) {
            NSLog(@"\r Pitch %.3f | Yaw %.3f | Roll %.3f",self.pitch,self.yaw,self.roll);
        }
    }
    
    if (self.exposesAcceleration == YES) {
        
        float aX = fabsf((float)motionManager.deviceMotion.userAcceleration.x);
        float aY = fabsf((float)motionManager.deviceMotion.userAcceleration.y);
        float aZ = fabsf((float)motionManager.deviceMotion.userAcceleration.z);
        float acceleration = aX + aY + aZ;
        
        acceleration = [self filterCurrentInput:acceleration lastOutput:self.acceleration];
        aX = [self filterCurrentInput:aX lastOutput:lastX];
        aY = [self filterCurrentInput:aY lastOutput:lastY];
        aZ = [self filterCurrentInput:aZ lastOutput:lastZ];
        _acceleration = acceleration;
        lastX = aX;
        lastY = aY;
        lastZ = aZ;
        
        if (self.logsStuff == YES) {
            NSLog(@"\r X: %.2f| Y: %.2f | Z: %.2f | Total Acceration: %.2f",aX,aY,aZ,self.acceleration);
        }
    }
    
    if (self.hidden == NO) {
        if (self.transformsWithAngles == YES) {
            
            float pitch = self.pitch;
            float yaw = self.yaw;
            float roll = self.roll;
            
            NSArray *attitudeArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:pitch],[NSNumber numberWithFloat:yaw],[NSNumber numberWithFloat:roll],nil];
            NSArray *keyArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"pitch"],[NSString stringWithFormat:@"yaw"],[NSString stringWithFormat:@"roll"],nil];
            
            NSDictionary *transformDict = [NSDictionary dictionaryWithObjects:attitudeArray forKeys:keyArray];
            
            [self accelViewRotationTransformWithEulerAngleDictionary:transformDict];
        }
        
        if (self.transformsWithAcceleration == YES) {
            [self accelViewAccelerationTransform:self.acceleration];
        }
    }
}
- (NSDictionary *)noGimbalDict:(NSDictionary *)dictionary {
    
    double qw = motionManager.deviceMotion.attitude.quaternion.w;
    double qx = motionManager.deviceMotion.attitude.quaternion.x;
    double qy = motionManager.deviceMotion.attitude.quaternion.y;
    double qz = motionManager.deviceMotion.attitude.quaternion.z;
    
    double scale = 1;
    double yaw = (qw*qz - qx*qy) * scale;
    double pitch = (qw*qx - qy*qz) * scale;
    double roll = (qw*qy - qx*qz) * scale;
    
    //NSLog(@"yaw: %f pitch: %f roll: %f",yaw,pitch,roll);
    
    NSDictionary *filteredDict = [self filterPitch:pitch roll:roll yaw:yaw lastDict:dictionary];
    
    return filteredDict;
}
- (NSDictionary *)filterPitch:(double)pitch roll:(double)roll yaw:(double)yaw lastDict:(NSDictionary *)lastDict {
    
    double x = [[lastDict objectForKey:@"yaw"] doubleValue];
    double y = [[lastDict objectForKey:@"pitch"] doubleValue];
    double z = [[lastDict objectForKey:@"roll"] doubleValue];
    
    pitch = [self filterCurrentInput:pitch lastOutput:y];
    yaw = [self filterCurrentInput:yaw lastOutput:x];
    roll = [self filterCurrentInput:roll lastOutput:z];
    
    NSNumber *numPitch = [NSNumber numberWithDouble:pitch];
    NSNumber *numYaw = [NSNumber numberWithDouble:yaw];
    NSNumber *numRoll = [NSNumber numberWithDouble:roll];
    
    NSArray *attitudeArray = [NSArray arrayWithObjects:numPitch,numYaw,numRoll,nil];
    NSArray *keyArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"pitch"],[NSString stringWithFormat:@"yaw"],[NSString stringWithFormat:@"roll"],nil];
    
    NSDictionary *filteredDict = [NSDictionary dictionaryWithObjects:attitudeArray forKeys:keyArray];
    return filteredDict;
}
- (double)filterCurrentInput:(double)x lastOutput:(double)y {
    
    double q = 0.1;
    double r = 0.1;
    double p = 0.1;
    double k = 0.8;
    
    p = p + q;
    k = p / (p + r);
    x = x + k*(y - x);
    p = (1 - k)*p;
    
    return x;
}
- (void)visualizeOnView:(UIView *)view {
    CGRect frame = CGRectMake(view.bounds.size.width*.01, view.bounds.size.height*.024, view.bounds.size.width/6, view.bounds.size.height/10);
    self.frame = frame;
    [view addSubview:self];
    [self createPlaneView];
}
- (void)createPlaneView {
    
    isPlane = YES;
    _parentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.parentView];
    
    if (self.hasOutline) {
        shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowbottom.pdf"]];
    } else {
        shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowbottom_alt.pdf"]];
    }
    
    shadowImageView.center = self.center;
    shadowImageView.backgroundColor = [UIColor clearColor];
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [shadowImageView.layer setZPosition:1];
    [shadowImageView.layer setDoubleSided:YES];
    shadowImageView.frame = self.parentView.frame;
    
    if (self.hasOutline) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowtop.pdf"]];
    } else {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowtop_alt.pdf"]];
    }
    imageView.center = self.center;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView.layer setZPosition:2];
    [imageView.layer setDoubleSided:NO];
    imageView.frame = self.parentView.frame;

    imageView.layer.shadowOpacity = 1.0;
    imageView.layer.shadowRadius = 0;
    imageView.layer.shadowColor = shadowColor.CGColor;
    imageView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    
    shadowImageView.layer.shadowOpacity = 1.0;
    shadowImageView.layer.shadowRadius = 0;
    shadowImageView.layer.shadowColor = shadowColor.CGColor;
    shadowImageView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    
    dotImage = [[UIImageView alloc] initWithFrame:self.bounds];
    if (self.self.hasOutline) {
        dotImage.image = [UIImage imageNamed:@"dot.pdf"];
    } else {
        dotImage.image = [UIImage imageNamed:@"dot_alt.pdf"];
    }
    dotImage.alpha = 0;
    
    if (canTap == YES) {
        [self addTapGestures];
    }
    [self.parentView addSubview:shadowImageView];
    [self.parentView addSubview:imageView];
    [self.parentView addSubview:dotImage];
    self.layer.masksToBounds = NO;
}
- (void)addTapGestures {
    UITapGestureRecognizer *dt = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleAccel)];
    [dt setNumberOfTapsRequired:2];
    UITapGestureRecognizer *st = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetMotionManager)];
    [st setNumberOfTapsRequired:1];
    
    [self addGestureRecognizer:st];
    [self addGestureRecognizer:dt];
}
- (void)centerAt:(CGPoint)center {
    if (isPlane == YES) {
        self.center = center;
    }
}
- (void)setShadowColor:(UIColor *)color {
    shadowColor = color;
    shadowImageView.layer.shadowColor = shadowColor.CGColor;
    imageView.layer.shadowColor = shadowColor.CGColor;
}
- (void)accelViewRotationTransformWithEulerAngleDictionary:(NSDictionary *)dict  {
    
    float pitch = [[dict objectForKey:@"pitch"] floatValue];
    float yaw = [[dict objectForKey:@"yaw"] floatValue];
    float roll = [[dict objectForKey:@"roll"] floatValue];

    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DMakeRotation(0, 0, 0, 0);
    transform = CATransform3DRotate(transform, pitch-M_PI_2, 1, 0, 0);
    transform = CATransform3DRotate(transform, roll, 0, -1, 0);
    transform = CATransform3DRotate(transform, yaw, 0, 0, 1);
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         if (isPlane == YES) {
                             imageView.layer.transform = transform;
                             shadowImageView.layer.transform = transform;
                         } else {
                             self.layer.transform = transform;
                         }
                     } completion:^(BOOL finished){
                     }];
}

- (void)accelViewAccelerationTransform:(float)acceleration {
    
    acceleration = fabsf(acceleration);

    acceleration = SCALE(acceleration, 0, 1, 0, 80);
    acceleration = CLIP(acceleration, 0, 80);
    // xf = k * xf + (1.0 - k) * x;
    acceleration = FILTER(acceleration, lastAcceleration, .98);
    lastAcceleration = acceleration;
    
    float opacity = SCALE(acceleration, 0, 20, 0, 1);
    
    //NSLog(@"%f",opacity);
    
    self.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:.3
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         //self.transform = CGAffineTransformMakeScale(acceleration, acceleration);
                         imageView.layer.shadowOpacity = opacity;
                         shadowImageView.layer.shadowOpacity = opacity;
                         imageView.layer.shadowRadius = acceleration;
                         shadowImageView.layer.shadowRadius = acceleration;
                     } completion:^(BOOL finished){
                     }];
    
}
- (void)canShakeToReset:(BOOL)shakeReset {
    if (shakeReset == YES) {
        [self becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeSuccess) name:@"shake" object:nil];
    } else {
        [self resignFirstResponder];
    }
}
- (void)shakeSuccess {
    [self resetMotionManager];
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}
- (void)canTapToReset:(BOOL)tapReset {
    if (tapReset == YES) {
        if (canTap == NO) {
            canTap = YES;
            if (isPlane == YES) {
                [self addTapGestures];
            }
        }
    } else {
        canTap = NO;
        if (isPlane == YES) {
            for (UIGestureRecognizer *ges in [[NSArray alloc] initWithArray:self.gestureRecognizers]) {
                [self removeGestureRecognizer:ges];
            }
        }
    }
}
- (void)roundToTwoDecimals:(BOOL)round {
    roundValues = round;
}
@end
