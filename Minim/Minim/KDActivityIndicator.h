//
//  KDActivityIndicator.h
//
//  Created by Cady Holmes on 2/21/18.
//  Copyright © 2018-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDHelpers.h"
#import "KDAnimations.h"

@interface KDActivityIndicator : UIView {
    NSArray *dots;
}

- (void)showThen:(void(^)(void))callback;
- (void)hideThen:(void(^)(void))callback;

@end
