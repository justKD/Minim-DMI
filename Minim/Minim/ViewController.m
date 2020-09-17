//
//  ViewController.m
//  Minim
//
//  Created by Cady Holmes on 11/26/17.
//  Copyright © 2017 Cady Holmes. All rights reserved.
//

#import "ViewController.h"
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "NNEasyPD.h"
#import "NNSlider.h"
#import "KDAccelView.h"
#import "LDToggle.h"
#import "BVReorderTableView.h"
#import "HapticHelper.h"
#import "KDWarningLabel.h"
#import "KDPrimitiveDataStore.h"
#import "KDScrollView.h"
#import "KDActivityIndicator.h"
#import "KDButton.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <StoreKit/StoreKit.h>

@interface ViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ReorderTableViewDelegate, KDAccelViewDelegate, KDToggleDelegate, NNEasyPDDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate>

{
    float sw;
    float sh;
    
    int numInstruments;
    int numCircles;
    int patchCounter;
    
    int menuArrowTagMod;
    int menuViewTagMod;
    int circleTagMod;
    int dialTagMod;
    
    float circleSize;
    float circleLineWidth;
    float spacerSize;
    
    float numWidth;
    float numHeight;
    float remWidth;
    float remHeight;
    float menuWidth;
    
    float slideAnimDur;
    float fadeAnimDur;
    float rotateAnimDur;
    float lowPitch;
    float pitchSliderValue;
    
    UIColor *menuBGColor;
    UIColor *circleColor;
    
    NSString *globalFont;
    NSString *boldFont;
    
    float smallFontSize;
    float fontSize;
    float bigFontSize;
    float arrowFontSize;
    float hamburgerFontSize;
    
    NSMutableArray *circleArray;
    NSMutableArray *dollarZeroArray;
    NSMutableArray *menuPositionArray;
    NSMutableArray *menuArray;
    NSMutableArray *dialArray;
    NSMutableArray *bigMenuArray;
    NSMutableArray *bigMenuLabelsArray;
    NSMutableArray *toggleArray;
    
    NSMutableArray *settings;
    NSMutableArray *savedSettings;
    NSMutableArray *fxSettings;
    NSMutableArray *fxSavedSettings;
    NSMutableArray *savedToggleSettings;
    
    int topMenuCount;
    NSString *topMenuString;
    NSArray *saveMenuArray;
    NSArray *iconArray;
    NSArray *defaultsArray;
    
    UIView *legendView;
    UIView *bigMenuView;
    UIView *topMenu;
    UIView *subMenu;
    UIView *sideMenu;
    UIView *saveMenu;
    UIView *toggleContainer;
    UILabel *globalMenuArrow;
    UILabel *miniMenuArrow;
    UILabel *hamburger;
    
    NSMutableArray *topMenuPulsing;
    NSMutableArray *topMenuRotating;
    NSMutableArray *topMenuRecordings;
    NSMutableArray *topMenuTimers;
    
    NSString *settingsPath;
    NSString *fxSettingsPath;
    NSString *lastSettingsPath;
    NSString *lastFxSettingsPath;
    NSString *toggleSettingsPath;
    NSString *lastToggleSettingsPath;
    
    NNEasyPD *pd;
    KDAccelView *accel;
    BVReorderTableView *tableView;
    BVReorderTableView *miniTableView;
    NSIndexPath *deleteIndex;
    
    BOOL useHaptics;
    BOOL useForceTouch;
    BOOL useNaturalTuning;
    BOOL settingsOpen;
    
    KDWarningLabel *warningLabel;
    
    int openCount;
    KDPrimitiveDataStore *store;
    
    NSMutableArray *helpViews;
    
    NSArray *lastPitch;
    
    UIView *miniMenu;

    BOOL hasLock;
    BOOL hasAds;
    BOOL savePageAdLoaded;
    BOOL loadPageAdLoaded;
    BOOL bannerAdLoaded;
    float bannerAdHeight;
    float bannerAdWidth;
    float bannerAdOffset;
    UIView *bannerAdView;
//    FBAdView *bannerAd;
//    FBAdView *savePageAd;
//    FBAdView *loadPageAd;
    NSTimer *adTimer;
    
    NSArray *personalAds;
    int personalAdCount;
    
    NSString *removeAdsProductID;
    NSString *removeAdsProductPrice;
    
    KDActivityIndicator *spinner;

}

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(BOOL)shouldAutorotate {
    return NO;
}

-(void)appWillResignActive:(NSNotification*)note {
    [self stopPD];
//    if (adTimer) {
//        [adTimer invalidate];
//        adTimer = nil;
//    }
//    if (hasAds) {
//        [bannerAdView removeFromSuperview];
//        bannerAdView = nil;
//        bannerAd = nil;
//    }
    UIView *white = [[UIView alloc] initWithFrame:self.view.bounds];
    white.backgroundColor = menuBGColor;
    white.userInteractionEnabled = NO;
    [self.view addSubview:white];
    [self.view bringSubviewToFront:white];
    [self showSpinner];
}
-(void)applicationDidBecomeActive:(NSNotification*)note {
    if (!pd) {
        [self reload];
    }
//    if (hasAds) {
//        if (!adTimer) {
//            [KDHelpers wait:1.7 then:^{
//                [self resetBannerAd];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self resetSavePageAd];
//                    [self resetLoadPageAd];
//                });
//            }];
//
//            [self makeAdTimer];
//        }
//    }
}

//- (void)applicationWillEnterForeground:(NSNotification*)note {
//    NSLog(@"fore");
//}
//- (void)applicationDidEnterBackground:(NSNotification*)note {
//    NSLog(@"back")
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    [self load];
    
//    [KDHelpers wait:5 then:^{
//        [self handlePurchaseFull];
//        [KDHelpers wait:5 then:^{
//            [self reload];
//        }];
//    }];
}

- (void)load {
    [self checkAds];

    [self setup];
    [self loadAllSettings];
    
    [self createKeys];
    [self loadKeys];
    [self createMenus];
    [self loadMenus];
    
    [self setupAccel];
    
    [self makeBigMenu];
    [self loadBigMenu];
    [self makeSubMenu];
    [self makeSideMenu];
    [self makeMiniMenu];
    
    [self updateSettingsUI];
    [self updateFxSettingsUI];
    
    warningLabel = [[KDWarningLabel alloc] init];
    [self.view addSubview:warningLabel];
    
    [self handleOpenCount];
    
//    if (hasAds) {
////        NSLog(@"load ads on load");
//        // preload ads
//        [self resetSavePageAd];
//        [self resetLoadPageAd];
//        [KDHelpers wait:2.7 then:^{
//            [self resetBannerAd];
//        }];
//        [self makeAdTimer];
//    }
}

- (void)handlePurchaseFull {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"fullmode.plist"];
    NSArray *array = @[@0];
    
    [fileManager createFileAtPath:path
                         contents:nil
                       attributes:nil];
    
    [array writeToFile:path atomically:YES];
}

- (void)reload {
    [self showSplash];
    if (spinner) {
        [self hideSpinner];
    }
    if (pd) {
        [pd invalidate];
    }
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [self load];
}

- (void)checkAds {
    hasAds = NO;
    hasLock = YES;
//    bannerAdHeight = 90;
//    bannerAdWidth = self.view.bounds.size.width * .95;
//    bannerAdOffset = self.view.bounds.size.width - bannerAdWidth;
//    if ([KDHelpers iPhoneXCheck]) {
//        bannerAdOffset = bannerAdOffset + 40;
//    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"fullmode.plist"];
    
    if ([fileManager fileExistsAtPath:path]) {
//        hasAds = NO;
        hasLock = NO;
//        bannerAdHeight = 0;
//        bannerAdWidth = 0;
//        bannerAdOffset = 0;
    }
    
    // test no ads
    //hasLock = NO;
    hasAds = NO;
    bannerAdHeight = 0;
    bannerAdWidth = 0;
    bannerAdOffset = 0;
}

//- (void)resetSavePageAd {
////    dispatch_async(dispatch_get_main_queue(), ^{
////        if (savePageAd) {
////            savePageAd = nil;
////        }
////        if (hasAds) {
////            savePageAdLoaded = NO;
////            savePageAd = [[FBAdView alloc] initWithPlacementID:@"145233309506994_145245352839123"
////                                                        adSize:kFBAdSizeHeight250Rectangle
////                                            rootViewController:self];
////            savePageAd.tag = 2;
////            savePageAd.delegate = self;
////            [savePageAd loadAd];
////        }
////    });
////    if (savePageAd) {
////        savePageAd = nil;
////    }
////    if (hasAds) {
////        savePageAdLoaded = NO;
////        savePageAd = [[FBAdView alloc] initWithPlacementID:@"145233309506994_145245352839123"
////                                                    adSize:kFBAdSizeHeight250Rectangle
////                                        rootViewController:self];
////        savePageAd.tag = 2;
////        savePageAd.delegate = self;
////        [savePageAd loadAd];
////    }
//}

//- (void)resetLoadPageAd {
////    dispatch_async(dispatch_get_main_queue(), ^{
////        if (loadPageAd) {
////            loadPageAd = nil;
////        }
////        if (hasAds) {
////            loadPageAdLoaded = NO;
////            loadPageAd = [[FBAdView alloc] initWithPlacementID:@"145233309506994_145254496171542"
////                                                        adSize:kFBAdSizeHeight250Rectangle
////                                            rootViewController:self];
////            loadPageAd.tag = 1;
////            loadPageAd.delegate = self;
////            [loadPageAd loadAd];
////        }
////    });
//}

//- (void)resetBannerAd {
//
////    bannerAdLoaded = NO;
////    if (bannerAdView) {
////        [KDAnimations slide:bannerAdView amountX:0 amountY:bannerAdHeight*2 duration:.5 then:^{
////            [bannerAdView removeFromSuperview];
////            bannerAdView = nil;
////            if (bannerAd) {
////                bannerAd = nil;
////            }
////        }];
////    }
////
////    [KDHelpers wait:.5 then:^{
////        if (hasAds) {
////            bannerAd = [[FBAdView alloc] initWithPlacementID:@"145233309506994_145233756173616"
////                                                      adSize:kFBAdSizeHeight90Banner
////                                          rootViewController:self];
////            bannerAd.tag = 0;
////            bannerAd.delegate = self;
////            [bannerAd loadAd];
////        }
////    }];
//}

//- (void)makeAdTimer {
////    adTimer = [NSTimer scheduledTimerWithTimeInterval:28 repeats:YES block:^(NSTimer *timer){
////        if (hasAds) {
////            [self resetBannerAd];
////        }
////    }];
//}

//- (void)makeBannerAdView {
//    bannerAdView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-bannerAdHeight-(bannerAdOffset/2), bannerAdWidth, bannerAdHeight)];
//    bannerAdView.center = CGPointMake(self.view.bounds.size.width/2, bannerAdView.center.y);
//    bannerAdView.layer.cornerRadius = 10;
//    bannerAdView.layer.masksToBounds = YES;
//    [KDAnimations slide:bannerAdView amountX:-sw amountY:0 duration:0 then:nil];
//
//    UILabel *bannerAdPlaceholder = [KDHelpers makeLabelWithWidth:bannerAdWidth andHeight:bannerAdHeight];
//    bannerAdPlaceholder.frame = bannerAdView.bounds;
//    bannerAdPlaceholder.font = [UIFont fontWithName:globalFont size:fontSize * .75];
//    bannerAdPlaceholder.textAlignment = NSTextAlignmentCenter;
//    bannerAdPlaceholder.text = [self getPersonalAd];;
//    [bannerAdView addSubview:bannerAdPlaceholder];
//
//    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnlock:)];
//    [bannerAdPlaceholder addGestureRecognizer:t];
//
//    if (bannerAdLoaded) {
////        bannerAd.frame = bannerAdView.bounds;
////        [bannerAdView addSubview:bannerAd];
//    }
//
//    [self.view insertSubview:bannerAdView atIndex:0];
//    [KDAnimations slide:bannerAdView amountX:0 amountY:0 duration:.5 then:nil];
//}

//- (void)adViewDidClick:(FBAdView *)adView
//{
//    NSLog(@"Banner ad was clicked.");
//}
//
//- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
//{
//    NSLog(@"Banner ad did finish click handling.");
//}
//
//- (void)adViewWillLogImpression:(FBAdView *)adView
//{
//    NSLog(@"Banner ad impression is being captured.");
//}

//- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
//    //NSLog(@"Ad failed to load");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (adView.tag == 0) {
//            //NSLog(@"banner failed");
//            bannerAdLoaded = NO;
//            [KDHelpers wait:10 then:^{
//                [self makeBannerAdView];
//            }];
//
////            [KDHelpers wait:.1 then:^{
////                [self bannerAdPlaceholder];
////            }];
//        }
//        switch ((int)adView.tag) {
//            case 1:
//                NSLog(@"load page ad failed");
//                loadPageAdLoaded = NO;
//                break;
//            case 2:
//                NSLog(@"save page ad failed");
//                savePageAdLoaded = NO;
//                break;
//
//            default:
//                break;
//        }
//
//        if (!loadPageAdLoaded) {
//            [KDHelpers wait:10 then:^{
//                [self resetLoadPageAd];
//            }];
//        }
//        if (!savePageAdLoaded) {
//            [KDHelpers wait:10 then:^{
//                [self resetSavePageAd];
//            }];
//        }
//    });
//}

//- (void)adViewDidLoad:(FBAdView *)adView {
//    //NSLog(@"Ad was loaded and ready to be displayed");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (adView.tag == 0) {
//            bannerAdLoaded = YES;
//            [KDHelpers wait:.2 then:^{
//                [self makeBannerAdView];
//            }];
//        }
//        switch ((int)adView.tag) {
//            case 1:
//                //NSLog(@"load page ad loaded");
//                loadPageAdLoaded = YES;
//                break;
//            case 2:
//                //NSLog(@"save page ad loaded");
//                savePageAdLoaded = YES;
//                break;
//
//            default:
//                break;
//        }
//    });
//}

- (void)handleOpenCount {
    store = [[kdPrimitiveDataStore alloc] initWithFile:@"store"];
    if (store.data) {
        openCount = [[store.data firstObject] intValue];
        openCount++;
    } else {
        openCount = 1;
    }
    [store save:@[[NSNumber numberWithInt:openCount]]];
    
    if (openCount > 1) {
        //[self showAppTour];
        [self showSplash];
    } else {
        [self showAppTour];
    }

    int reviewCount = openCount % 8;
    reviewCount = MAX(reviewCount, 1);

    if (reviewCount == 3) {
        [SKStoreReviewController requestReview];
    }
}

- (void)showAppTour {
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *headphoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height/3)];
    UIImageView *headphones = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headphoneView.bounds.size.width/2, headphoneView.bounds.size.height)];
    headphones.image = [UIImage imageNamed:@"headphone.png"];
    headphones.contentMode = UIViewContentModeScaleAspectFit;
    UIView *textContainer = [[UIView alloc] initWithFrame:CGRectMake(headphoneView.bounds.size.width/2, 0, headphoneView.bounds.size.width/2, headphoneView.bounds.size.height)];
    UILabel *headphoneLabel = [KDHelpers makeLabelWithWidth:textContainer.bounds.size.width*.7 andHeight:textContainer.bounds.size.height*.7];
    headphoneLabel.font = [UIFont fontWithName:globalFont size:fontSize];
    headphoneLabel.textAlignment = NSTextAlignmentCenter;
    headphoneLabel.center = CGPointMake(textContainer.bounds.size.width/2, textContainer.bounds.size.height/2);
    headphoneLabel.text = @"Best experienced with headphones or external speakers!";
    [textContainer addSubview:headphoneLabel];
    [headphoneView addSubview:headphones];
    [headphoneView addSubview:textContainer];
    
    UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height/3, view.bounds.size.width, view.bounds.size.height/2)];
    UILabel *label = [KDHelpers makeLabelWithWidth:welcomeView.bounds.size.width*.8 andHeight:welcomeView.bounds.size.height*.7];
    label.center = CGPointMake(welcomeView.bounds.size.width/2, welcomeView.bounds.size.height/3);
    label.font = [UIFont fontWithName:globalFont size:fontSize*1.2];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Minim is easy to get started with.\n\nJust tap or press on the circles!\n\nBut there's a lot more to discover in the help menus!";
    [welcomeView addSubview:label];
    
    UILabel *help = [KDHelpers makeLabelWithWidth:sw andFontSize:fontSize*1.5 andAlignment:NSTextAlignmentCenter];
    help.attributedText = [KDHelpers underlinedString:@"Show me the help files."];
    help.tag = 1;
    [KDHelpers setOriginY:self.view.frame.size.height-help.frame.size.height-150 forView:help];
    UITapGestureRecognizer *taphelp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAppTour:)];
    [help addGestureRecognizer:taphelp];

    UILabel *ok = [KDHelpers makeLabelWithWidth:sw andFontSize:fontSize*2 andAlignment:NSTextAlignmentCenter];
    ok.attributedText = [KDHelpers underlinedString:@"Sound now!!"];
    [KDHelpers setOriginY:self.view.frame.size.height-ok.frame.size.height-50 forView:ok];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAppTour:)];
    [ok addGestureRecognizer:tap];
    
    [view addSubview:headphoneView];
    [view addSubview:welcomeView];
    [view addSubview:help];
    [view addSubview:ok];
    
//    [KDAnimations animateViewGrowAndShow:view then:nil];
    [self.view addSubview:view];
}
- (void)closeAppTour:(UITapGestureRecognizer*)sender {
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
    if (sender.view.tag > 0) {
        [self openHelp:sender];
    }
}

- (void)showSplash {
    
    [self.view setUserInteractionEnabled:NO];
    
    UIView *splash = [[UIView alloc] initWithFrame:self.view.frame];
    splash.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_1024"]];
    image.frame = self.view.frame;
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    [splash addSubview:image];
    
    [self.view addSubview:splash];
    
    [KDAnimations rock:image.layer degrees:180 withDuration:1.3 then:^{
        [KDHelpers wait:1.3 then:^{
            [KDAnimations stopRock:image.layer withDuration:.2 then:^{
                [KDAnimations jiggle:splash amount:1.05 then:^{
                    [KDAnimations animateViewShrinkAndWink:splash andRemoveFromSuperview:YES then:^{
                        [self.view setUserInteractionEnabled:YES];
                    }];
                }];
            }];
        }];
    }];
}

- (void)loadAllSettings {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    settingsPath = [documentsPath stringByAppendingPathComponent:@"settings.plist"];
    lastSettingsPath = [documentsPath stringByAppendingPathComponent:@"lastSettings.plist"];
    fxSettingsPath = [documentsPath stringByAppendingPathComponent:@"fxSettings.plist"];
    lastFxSettingsPath = [documentsPath stringByAppendingPathComponent:@"lastFxSettings.plist"];
    toggleSettingsPath = [documentsPath stringByAppendingPathComponent:@"toggleSettings.plist"];
    lastToggleSettingsPath = [documentsPath stringByAppendingPathComponent:@"lastToggleSettings.plist"];
    
    settings = [[NSMutableArray alloc] init];
    savedSettings = [[NSMutableArray alloc] init];
    fxSettings = [[NSMutableArray alloc] init];
    fxSavedSettings = [[NSMutableArray alloc] init];
    savedToggleSettings = [[NSMutableArray alloc] init];
    
    defaultsArray = @[
                      @[@"_Crystal",
                        @[@"1",@"80",@"100",@"20",@"50"],
                        @[@"0",@".5",@".65",@".12",@"1",@"1",@"1",@".3",@".75"],
                        @[@"0",@"1"]
                        ],
                      @[@"_LDB",
                        @[@"4",@"28",@"0",@"50",@"6"],
                        @[@".35",@".1",@".2",@"0",@"0",@"0",@"0",@".5",@".7"],
                        @[@"0",@"0"]
                        ],
                      @[@"_Kickball",
                        @[@"3",@"0",@"0",@"43",@"20"],
                        @[@".5",@".15",@".5",@"0",@".58",@"0",@"0",@"0",@".5"],
                        @[@"0",@"0"]
                        ],
                      @[@"_DevBass",
                        @[@"3",@"8",@"100",@"10",@"50"],
                        @[@".9",@".22",@".33",@".425",@"1",@"0",@"0",@".1",@".7"],
                        @[@"0",@"0"]
                        ],
                      @[@"_Shrug",
                        @[@"1",@"50",@"100",@"25",@"50"],
                        @[@".5",@"0",@"0",@".15",@"1",@"0",@"0",@".5",@".5"],
                        @[@"0",@"0"]
                        ],
                      @[@"_BeepBoop",
                        @[@"2",@"0",@"0",@"100",@"40"],
                        @[@"0",@".15",@".25",@"0",@"1",@"0",@"0",@"0",@"1"],
                        @[@"0",@"0"]
                        ]
                      ];
    [self loadSettings];
    [self loadLastSettings];
    [self loadLastFxSettings];
    [self loadLastToggleSettings];
}

- (void)setup {

    sw = self.view.frame.size.width;
    sh = self.view.frame.size.height - bannerAdHeight - bannerAdOffset;
    if ([KDHelpers iPhoneXCheck]) {
        sh = self.view.frame.size.height - bannerAdHeight;
    }

    useForceTouch = [self checkForForceTouch];
    
    numInstruments = 4;
    numCircles = 0;
    patchCounter = 0;

    menuArrowTagMod = 200;
    menuViewTagMod = 300;
    circleTagMod = 100;
    dialTagMod = 400;
    
    circleLineWidth = .75;
    circleSize = sw / 5.76923076923;
    spacerSize = circleSize / 8;
    
    numWidth = 3;
    numHeight = 7;
    
    if ([KDHelpers isIpad]) {
        circleSize = sw / 6.5;
        spacerSize = circleSize / 12;
        
        numWidth = 4;
        numHeight = 6;
    } else if ([KDHelpers iPhoneXCheck]) {
        numHeight = 8;
    }
    
    numCircles = numWidth * numHeight;
    
//    if (hasAds) {
//        numHeight = numHeight - 1;
//        numCircles = numCircles - numWidth;
//    }

    remWidth = 0;
    remHeight = 0;
    menuWidth = 0;
    
    slideAnimDur = .4;
    fadeAnimDur = slideAnimDur/2;
    rotateAnimDur = .3;
    lowPitch = 0;
    pitchSliderValue = 0;
    
    menuBGColor = [UIColor whiteColor];
    circleColor = [UIColor clearColor];

    globalFont = @"HelveticaNeue-UltraLight";
    boldFont = @"HelveticaNeue-Light";
    
    smallFontSize = 18;
    fontSize = 20;
    bigFontSize = 30;
    arrowFontSize = 40;
    hamburgerFontSize = 26;
    
    circleArray = [[NSMutableArray alloc] init];
    dollarZeroArray = [[NSMutableArray alloc] init];
    menuPositionArray = [[NSMutableArray alloc] init];
    dialArray = [[NSMutableArray alloc] init];
    menuArray = [[NSMutableArray alloc] init];
    bigMenuArray = [[NSMutableArray alloc] init];
    bigMenuLabelsArray = [[NSMutableArray alloc] init];
    toggleArray = [[NSMutableArray alloc] initWithObjects:@0, @0, nil];
    
    topMenuCount = 4;
    topMenuString = @"ⓧ";
    saveMenuArray = @[@"save  ⤒",@"⤓  load"];
    iconArray = @[@"Type",@"Body",@"Trem",@"FX",@"Amp"];

    legendView = [[UIView alloc] init];
    bigMenuView = [[UIView alloc] init];
    topMenu = [[UIView alloc] init];
    subMenu = [[UIView alloc] init];
    sideMenu = [[UIView alloc] init];
    miniMenu = [[UIView alloc] init];
    saveMenu = [[UIView alloc] init];
    toggleContainer = [[UIView alloc] init];
    globalMenuArrow = [[UILabel alloc] init];
    miniMenuArrow = [[UILabel alloc] init];
    hamburger = [[UILabel alloc] init];

    topMenuPulsing = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",nil];
    topMenuRotating = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",nil];
    topMenuRecordings = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0", nil];
    topMenuTimers = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",nil];
    
    [self loadPD];

    useHaptics = YES;
    useNaturalTuning = NO;
    settingsOpen = NO;
    
    helpViews = [[NSMutableArray alloc] init];
    
    personalAds = @[@"Hey! Thanks for trying out Minim.\nThe full version will remove all ads\nand unlock extra features!\n♡\n(available as an in-app purchase)",
                    @"The full version adds an extra row of pads, unlocks the global fx page, removes all ads, doubles the recording buffers, unlocks the quick access preset menu, and adds pressure senstivity (on supported devices).",
                    @"Try moving your finger around after pressing and holding a pad. The sound will shift subtletly as the filters change.",
                    @"Even though the pads are laid out in a grid, the pitch register may not always be exactly 'low-to-high'. You'll have to explore your current settings and really learn what sounds you can make!",
                    @"The layout of the settings page lets you really get nitty-gritty with customizing your pads. Every row doesn't ALWAYS have to have the same settings!"];
    personalAdCount = 0;
    
    removeAdsProductID = @"01";
    removeAdsProductPrice = @"$1.99";
}

- (void)loadPD {
    pd = [[NNEasyPD alloc] initWithPatch:@"minim.pd"];
    [pd listenToReceivers:@[@"0.animtime",@"1.animtime",@"2.animtime",@"3.animtime"]];
    pd.delegate = self;
}

- (void)stopPD {
    [pd invalidate];
    pd = nil;
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma CREATE

- (void)createKeys {

    remHeight = sh - (circleSize * numHeight) - (spacerSize * (numHeight-1));
    if ([KDHelpers iPhoneXCheck]) {
        remHeight = remHeight * .9;
    }

    int tagNum = 0;
    float radius = (circleSize/2);

    for (int i = 0; i < numHeight; i++) {
        
        float heightPosition = 0;
        
        float offsetHeight = (remHeight / 2) + (circleSize * .75) + spacerSize;
//        if ([KDHelpers isIpad]) {
//            offsetHeight = (remHeight / 2) + (circleSize * 1) + spacerSize;
//        }
        float y = offsetHeight + (circleSize * i) + (spacerSize * i);
        float tempNumWidth = numWidth;
        
        if (i % 2 == 1) {
            tempNumWidth = numWidth - 1;
        
        }
        remWidth = sw - (circleSize * tempNumWidth) - (spacerSize * (tempNumWidth-1));
        
        for (int j = 0; j < numWidth; j++) {
            
            float offsetWidth = remWidth / 4;
            float x = offsetWidth + (circleSize * j) + (spacerSize * j);
            
            UIView *circle = [KDHelpers circleWithColor:circleColor radius:radius borderWidth:circleLineWidth];
            [circle setFrame:CGRectMake(x, y, circle.frame.size.width, circle.frame.size.height)];
            [circle setTag:tagNum + circleTagMod];
            
            [circleArray addObject:circle];
            
            heightPosition = circle.center.y;
            
            tagNum++;
        }
        
        [menuPositionArray addObject:[NSNumber numberWithFloat:heightPosition]];
    }
    
    remWidth = sw - (circleSize * (numWidth+1)) - (spacerSize * numWidth);
    menuWidth = sw-remWidth;
}

- (void)createMenus {
    
    float y = (remHeight / 2) - (circleSize / 2) + spacerSize;
//    if (!hasAds) {
//        if ([KDHelpers isIpad]) {
//            y = (remHeight / 2);
//        }
//    }
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            hamburgerFontSize = hamburgerFontSize * 2;
        } else {
            hamburgerFontSize = hamburgerFontSize * 1.5;
        }
    }
    hamburger = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
    [hamburger setCenter:CGPointMake(sw-(circleSize*.75), y)];
    [hamburger setTextAlignment:NSTextAlignmentCenter];
    [hamburger setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
    [hamburger setText:@"≡"];
    [hamburger setUserInteractionEnabled:YES];
    [hamburger setTag:9998];
    
    UITapGestureRecognizer *tapHamburger = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHamburger:)];
    [hamburger addGestureRecognizer:tapHamburger];
    
    y = (remHeight / 2) + (circleSize / 3) + spacerSize;
//    if (!hasAds) {
//        if ([KDHelpers isIpad]) {
//            y = (remHeight / 2) + (circleSize / 3);
//        }
//    }

    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            arrowFontSize = arrowFontSize * 2;
        } else {
            arrowFontSize = arrowFontSize * 1.5;
        }
    }
    globalMenuArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
    [globalMenuArrow setCenter:CGPointMake(sw-(circleSize*.75), y)];
    [globalMenuArrow setTextAlignment:NSTextAlignmentCenter];
    [globalMenuArrow setFont:[UIFont fontWithName:globalFont size:arrowFontSize]];
    [globalMenuArrow setText:@"«"];//⟪
    [globalMenuArrow setUserInteractionEnabled:YES];
    [globalMenuArrow setTag:8998];
    [globalMenuArrow setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *tapGlobalArrow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGlobalArrow:)];
    [globalMenuArrow addGestureRecognizer:tapGlobalArrow];
    
    if (!hasLock) {
        float tempy = (sh - circleSize) + spacerSize;
        if ([KDHelpers iPhoneXCheck]) {
            tempy = (sh - circleSize) + (-spacerSize);
        }
        if ([KDHelpers isIpad]) {
            tempy = (sh - circleSize) + (spacerSize * 3);
        }
        miniMenuArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [miniMenuArrow setCenter:CGPointMake(sw-(circleSize*.75), tempy)];
        [miniMenuArrow setTextAlignment:NSTextAlignmentCenter];
        [miniMenuArrow setFont:[UIFont fontWithName:globalFont size:arrowFontSize]];
        [miniMenuArrow setText:@"‹"];
        [miniMenuArrow setUserInteractionEnabled:YES];
        [miniMenuArrow setTag:8998];
        [miniMenuArrow setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *tapMiniArrow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMiniArrow:)];
        [miniMenuArrow addGestureRecognizer:tapMiniArrow];
    } else {
        float dialFontSize = arrowFontSize*.75;
        float tempy = (sh - circleSize) + (spacerSize * 3);
        if ([KDHelpers iPhoneXCheck]) {
            tempy = (sh - circleSize) + (-spacerSize);
        }
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                tempy = (sh - circleSize) + (spacerSize * 5);
                dialFontSize = dialFontSize * 1.5;
            } else {
                tempy = (sh - circleSize) + (spacerSize * 4);
                dialFontSize = dialFontSize * 1.25;
            }
        }
        miniMenuArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [miniMenuArrow setCenter:CGPointMake(sw-(circleSize*.75), tempy)];
        [miniMenuArrow setTextAlignment:NSTextAlignmentCenter];
        [miniMenuArrow setFont:[UIFont fontWithName:globalFont size:dialFontSize]];
        [miniMenuArrow setText:@"?"];
        [miniMenuArrow setUserInteractionEnabled:YES];
        [miniMenuArrow setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *tapMiniArrow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openHelp:)];
        [miniMenuArrow addGestureRecognizer:tapMiniArrow];
    }
    
    bigMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, sw, self.view.bounds.size.height)];
    [bigMenuView setBackgroundColor:menuBGColor];
    [bigMenuView setAlpha:0];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[[defaultsArray firstObject] objectAtIndex:1]];
    int tagNum = 0;
    for (NSNumber *num in menuPositionArray) {
        float y = [num floatValue];
        
        UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(-menuWidth, y-(circleSize/2)-(spacerSize/2), menuWidth, circleSize+spacerSize)];
        [menuView setBackgroundColor:menuBGColor];
        [menuView setTag:tagNum + menuViewTagMod];
        menuView.layer.cornerRadius = circleSize/2;
        menuView.layer.masksToBounds = NO;
        [menuView setAlpha:0];
        
        for (int i = 0; i < iconArray.count; i++) {
            
            float x = (menuWidth/(iconArray.count+1)) * (i+1);
            float y = menuView.bounds.size.height/2;
            
            int dialTagNum = dialTagMod + (tagNum * 10) + i;
            
            if (i == 0) {
                UILabel *dial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
                [dial setTextAlignment:NSTextAlignmentCenter];
                [dial setTag:dialTagNum];
                float dialFontSize = fontSize;
                if ([KDHelpers isIpad]) {
                    if ([KDHelpers isIpadPro_1366]) {
                        dialFontSize = dialFontSize * 2.5;
                    } else {
                        dialFontSize = dialFontSize * 2;
                    }
                }
                [dial setFont:[UIFont fontWithName:globalFont size:dialFontSize]];
                [dial setCenter:CGPointMake(x, y)];
                [dial setUserInteractionEnabled:YES];
                [dial setText:[arr objectAtIndex:0]];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapType:)];
                [dial addGestureRecognizer:tap];
                
                [dialArray addObject:dial];
                [menuView addSubview:dial];
            } else {
                float frameSize = circleSize*.75;
                NNSlider *dial = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, frameSize, frameSize)];
                [dial addTarget:self action:@selector(sliderAction:withEvent:) forControlEvents:UIControlEventValueChanged];
                [dial addTarget:self action:@selector(sliderTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
                [dial addTarget:self action:@selector(sliderTouchDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
                [dial addTarget:self action:@selector(sliderTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
                dial.isDial = YES;
                dial.knobColor = [UIColor clearColor];
                dial.isClockwise = NO;
                dial.shouldFlip = YES;
                dial.hasLabel = NO;
                dial.value = [[arr objectAtIndex:i] floatValue] * .01;
                [dial setBackgroundColor:menuBGColor];
                [dial setTag:dialTagNum];
                [dial setCenter:CGPointMake(x, y)];
                [dial.layer setBorderWidth:0];
                [dial.layer setMasksToBounds:YES];
                [dial.layer setCornerRadius:circleSize/2];

                float dialFontSize = fontSize;
                if ([KDHelpers isIpad]) {
                    if ([KDHelpers isIpadPro_1366]) {
                        dialFontSize = dialFontSize * 2.5;
                    } else {
                        dialFontSize = dialFontSize * 2;
                    }
                }
                UILabel *dot = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameSize, frameSize)];
                [dot setTextAlignment:NSTextAlignmentCenter];
                [dot setFont:[UIFont fontWithName:globalFont size:dialFontSize]];
                [dot setCenter:CGPointMake(dial.bounds.size.width/2, dial.bounds.size.height/2)];
                [dot setText:@"ᐧ"];
                [dial addSubview:dot];
                
                [dialArray addObject:dial];
                [menuView addSubview:dial];
            }
        }
        [settings addObject:arr];
        [menuArray addObject:menuView];
        tagNum++;
    }
    menuPositionArray = nil;
    
    float frameSize = circleSize*.75;
    [legendView setFrame:CGRectMake(-menuWidth, 0, menuWidth, circleSize+spacerSize)];
    [legendView setCenter:CGPointMake(legendView.center.x, globalMenuArrow.center.y)];
    [legendView setAlpha:0];
    [legendView setBackgroundColor:[UIColor clearColor]];
    y = legendView.bounds.size.height/2;
    for (int i = 0; i < iconArray.count; i++) {
        float x = (menuWidth/(iconArray.count+1)) * (i+1);
        float dialFontSize = smallFontSize;
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                dialFontSize = dialFontSize * 2.5;
            } else {
                dialFontSize = dialFontSize * 2;
            }
        }
        UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [icon setTextAlignment:NSTextAlignmentCenter];
        [icon setFont:[UIFont fontWithName:globalFont size:dialFontSize]];
        [icon setCenter:CGPointMake(x, y)];
        [icon setText:[iconArray objectAtIndex:i]];
        [icon setAlpha:.4];
        [icon setBackgroundColor:[UIColor clearColor]];
        
        NNSlider *globalDial = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, frameSize, frameSize)];
        if (i == 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTypeGlobal:)];
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTypeGlobal:)];
            swipe.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
            
            [icon setUserInteractionEnabled:YES];
            [icon addGestureRecognizer:tap];
            [icon addGestureRecognizer:swipe];
        } else {
            [globalDial addTarget:self action:@selector(globalSliderAction:withEvent:) forControlEvents:UIControlEventValueChanged];
            [globalDial addTarget:self action:@selector(globalSliderTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
            [globalDial addTarget:self action:@selector(globalSliderTouchDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
            [globalDial addTarget:self action:@selector(globalSliderTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
            globalDial.isDial = YES;
            globalDial.knobColor = [UIColor clearColor];
            globalDial.isClockwise = NO;
            globalDial.shouldFlip = YES;
            globalDial.hasLabel = NO;
            globalDial.value = 0;
            [globalDial setTag:i];
            [globalDial setCenter:CGPointMake(x, y)];
            [globalDial.layer setBorderWidth:0];
            [globalDial.layer setMasksToBounds:YES];
            [globalDial.layer setCornerRadius:circleSize/2];
            
            globalDial.alpha = 0.2;
            [legendView addSubview:globalDial];
        }
        
        [legendView addSubview:icon];
    }
    
    [topMenu setFrame:CGRectMake(0, 0, menuWidth, circleSize)];
    [topMenu setCenter:CGPointMake(topMenu.center.x, hamburger.center.y)];
    y = topMenu.bounds.size.height/2;
    for (int i = 0; i < topMenuCount; i++) {
        
        float x = ((menuWidth/(topMenuCount+1)) * (i+1)) + (i*spacerSize*1.5) - spacerSize;
        float radius = circleSize/2;
        
        UIView *circle = [KDHelpers circleWithColor:[UIColor clearColor] radius:radius borderWidth:0];
        [circle setCenter:CGPointMake(x, y)];
        
        UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [icon setTextAlignment:NSTextAlignmentCenter];
        
        CGFloat size = bigFontSize;
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                size = size * 2.5;
            } else {
                size = size * 1.5;
            }
        }
        [icon setFont:[UIFont fontWithName:globalFont size:size]];
        [icon setCenter:CGPointMake(radius, radius)];
        [icon setText:topMenuString];
        [icon setTag:i];
        [icon setUserInteractionEnabled:YES];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTopMenu:)];
        [icon addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lpTopMenu:)];
        [icon addGestureRecognizer:lp];
        
        [circle addSubview:icon];
        
        [topMenu addSubview:circle];
        
        if (hasLock) {
            if (i > 1) {
                circle.hidden = YES;
            }
        }
    }
    
    if (hasLock) {
//        UILabel *helpButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, topMenu.bounds.size.width/5, topMenu.bounds.size.height*.4)];
//        helpButton.center = CGPointMake(0, topMenu.bounds.size.height/2);
//        float spacerMod = 6;
//        float topMenuFontSize = fontSize*1.5;
//        if ([KDHelpers isIpad]) {
//            if ([KDHelpers isIpadPro_1366]) {
//                topMenuFontSize = fontSize * 2.5;
//                spacerMod = 8;
//            } else {
//                topMenuFontSize = fontSize * 2;
//            }
//        }
//        [KDHelpers setOriginX:((topMenu.bounds.size.width/5)*2)+(spacerSize*spacerMod) forView:helpButton];
//        helpButton.font = [UIFont fontWithName:globalFont size:topMenuFontSize];
//        helpButton.textAlignment = NSTextAlignmentCenter;
//        helpButton.userInteractionEnabled = NO;
//        helpButton.text = @"";
//        [topMenu addSubview:helpButton];

//        UITapGestureRecognizer *tt = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openHelp:)];
//        [helpButton addGestureRecognizer:tt];

        UIImageView *unlock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlock.pdf"]];
        unlock.frame = CGRectMake(0, 0, topMenu.bounds.size.width/5, topMenu.bounds.size.height*.4);
        unlock.center = CGPointMake(0, topMenu.bounds.size.height/2);
        float spacerMod = 7;
        float topMenuFontSize = fontSize*1.5;
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                topMenuFontSize = fontSize * 2.5;
                spacerMod = 9;
            } else {
                topMenuFontSize = fontSize * 2;
            }
        }
        [KDHelpers setOriginX:((topMenu.bounds.size.width/5)*3)+(spacerSize*spacerMod) forView:unlock];
        unlock.contentMode = UIViewContentModeScaleAspectFit;
        unlock.userInteractionEnabled = YES;
        unlock.alpha = .7;
        [topMenu addSubview:unlock];
        
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnlock:)];
        [unlock addGestureRecognizer:t];
    }
    
    [saveMenu setFrame:CGRectMake(-menuWidth, 0, menuWidth, circleSize)];
    [saveMenu setAlpha:0];
    [saveMenu setCenter:CGPointMake(saveMenu.center.x, hamburger.center.y)];
    [saveMenu setBackgroundColor:menuBGColor];
    y = saveMenu.bounds.size.height/2;
    for (int i = 0; i < saveMenuArray.count; i++) {
        UITapGestureRecognizer *tapSaveLoad = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSaveLoad:)];
        float x = (menuWidth/(saveMenuArray.count+1)) * (i+1);
        UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [icon setTag:i];
        [icon setTextAlignment:NSTextAlignmentCenter];
        float dialFontSize = fontSize;
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                dialFontSize = dialFontSize * 2.5;
            } else {
                dialFontSize = dialFontSize * 2;
            }
        }
        [icon setFont:[UIFont fontWithName:globalFont size:dialFontSize]];
        [icon setCenter:CGPointMake(x, y)];
        [icon setText:[saveMenuArray objectAtIndex:i]];
        [icon setUserInteractionEnabled:YES];
        [icon addGestureRecognizer:tapSaveLoad];
        
        [saveMenu addSubview:icon];
    }
}

- (void)tapUnlock:(UITapGestureRecognizer *)sender {
    [KDAnimations jiggle:sender.view amount:1.15 then:nil];
    [self openPurchasePage:NO];
}

- (void)makeBigMenu {
    
    float numTiers = 9;
    float height = circleSize * .75;
    float knobRadius = circleSize/8;
    float lineWidth = 1;
    BOOL hasLabel = NO;
    
    UIColor *knobColor = [UIColor clearColor];
    UIColor *sliderBgColor = [UIColor clearColor];
    
    float yOffset = circleSize/3;
    float labelHeight = 20;
    float labelBuffer = 0;
    int count = 1;
    
    float width = .8;
    float cX = (sw/2)-(bigMenuView.frame.origin.x);
    
    if (fxSettings.count < 1) {
        fxSettings = [NSMutableArray arrayWithArray:[[defaultsArray firstObject] objectAtIndex:2]];
    }
    
    float h = bigMenuView.bounds.size.height;
    NNSlider *pitch = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [pitch addTarget:self action:@selector(pitchSliderAction:) forControlEvents:UIControlEventValueChanged];
    [pitch setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [pitch setBackgroundColor:sliderBgColor];
    pitch.knobColor = knobColor;
    pitch.knobRadius = knobRadius;
    pitch.lineWidth = lineWidth;
    pitch.hasLabel = hasLabel;
    pitch.value = [[fxSettings objectAtIndex:0] floatValue];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Tune";
    label.center = CGPointMake(cX, pitch.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:pitch];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *revAmount = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [revAmount addTarget:self action:@selector(reverbSliderAction:) forControlEvents:UIControlEventValueChanged];
    [revAmount setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [revAmount setBackgroundColor:sliderBgColor];
    revAmount.knobColor = knobColor;
    revAmount.knobRadius = knobRadius;
    revAmount.lineWidth = lineWidth;
    revAmount.hasLabel = hasLabel;
    revAmount.tag = 0;
    revAmount.value = [[fxSettings objectAtIndex:1] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Reverb Amount";
    label.center = CGPointMake(cX, revAmount.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:revAmount];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *revWD = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [revWD addTarget:self action:@selector(reverbSliderAction:) forControlEvents:UIControlEventValueChanged];
    [revWD setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [revWD setBackgroundColor:sliderBgColor];
    revWD.knobColor = knobColor;
    revWD.knobRadius = knobRadius;
    revWD.lineWidth = lineWidth;
    revWD.hasLabel = hasLabel;
    revWD.tag = 1;
    revWD.value = [[fxSettings objectAtIndex:2] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Reverb Mix";
    label.center = CGPointMake(cX, revWD.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:revWD];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *delay = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [delay addTarget:self action:@selector(delaySliderAction:) forControlEvents:UIControlEventValueChanged];
    [delay setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [delay setBackgroundColor:sliderBgColor];
    delay.knobColor = knobColor;
    delay.knobRadius = knobRadius;
    delay.lineWidth = lineWidth;
    delay.hasLabel = hasLabel;
    delay.value = [[fxSettings objectAtIndex:3] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Delay";
    label.center = CGPointMake(cX, delay.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:delay];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *od = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [od addTarget:self action:@selector(odSliderAction:) forControlEvents:UIControlEventValueChanged];
    [od setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [od setBackgroundColor:sliderBgColor];
    od.knobColor = knobColor;
    od.knobRadius = knobRadius;
    od.lineWidth = lineWidth;
    od.hasLabel = hasLabel;
    od.value = [[fxSettings objectAtIndex:4] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Distortion";
    label.center = CGPointMake(cX, od.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:od];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *odFX = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [odFX addTarget:self action:@selector(odFXSliderAction:) forControlEvents:UIControlEventValueChanged];
    [odFX setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [odFX setBackgroundColor:sliderBgColor];
    odFX.knobColor = knobColor;
    odFX.knobRadius = knobRadius;
    odFX.lineWidth = lineWidth;
    odFX.hasLabel = hasLabel;
    odFX.value = [[fxSettings objectAtIndex:5] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Distortion Delay";
    label.center = CGPointMake(cX, odFX.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:odFX];
    [bigMenuLabelsArray addObject:label];
    
    count++;
    
    NNSlider *crush = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [crush addTarget:self action:@selector(crushSliderAction:) forControlEvents:UIControlEventValueChanged];
    [crush setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [crush setBackgroundColor:sliderBgColor];
    crush.knobColor = knobColor;
    crush.knobRadius = knobRadius;
    crush.lineWidth = lineWidth;
    crush.hasLabel = hasLabel;
    crush.value = [[fxSettings objectAtIndex:6] floatValue];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw*width, labelHeight)];
    label.font = [UIFont fontWithName:globalFont size:smallFontSize];
    label.text = @"Crush";
    label.center = CGPointMake(cX, crush.center.y-labelHeight-labelBuffer);
    [label.layer setMasksToBounds:NO];
    [label setBackgroundColor:sliderBgColor];
    
    [bigMenuArray addObject:crush];
    [bigMenuLabelsArray addObject:label];
    
    count++;

    NSArray *toggleImages = @[[UIImage imageNamed:@"accel_icon.pdf"],[UIImage imageNamed:@"tuningfork.pdf"]];
    toggleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw*width, height)];
    [toggleContainer setCenter:CGPointMake(cX, (h/numTiers)*count+yOffset)];
    [toggleContainer setBackgroundColor:sliderBgColor];
    float margin = 25;
    float x = margin;
    float size = height;
    for (int i = 1; i < 3; i++) {
        kdToggle *toggle = [kdToggle initWithID:i-1];
        toggle.delegate = self;
        toggle.onColor = sliderBgColor;
        toggle.offColor = sliderBgColor;
        toggle.size = size;
        toggle.backgroundImage = [toggleImages objectAtIndex:i-1];
        
        if (i == 2) {
            x = (toggleContainer.bounds.size.width/2)-(toggle.size/2);
        }

        [toggle setFrame:CGRectMake(x, toggle.frame.origin.y, toggle.frame.size.width, toggle.frame.size.height)];
        [toggleContainer addSubview:toggle];
    }
    
    UILabel *helpButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    x = toggleContainer.bounds.size.width-helpButton.frame.size.width-margin;
    helpButton.frame = CGRectMake(x, helpButton.frame.origin.y, helpButton.frame.size.width, helpButton.frame.size.height);
    float helpFontSize = fontSize * 2;
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            helpFontSize = helpFontSize * 2.5;
        } else {
            helpFontSize = helpFontSize * 2;
        }
    }
    helpButton.font = [UIFont fontWithName:globalFont size:helpFontSize];
    helpButton.textAlignment = NSTextAlignmentCenter;
    helpButton.userInteractionEnabled = YES;
    helpButton.text = @"?";
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openHelp:)];
    [helpButton addGestureRecognizer:t];
    
    [toggleContainer addSubview:helpButton];
    
    [bigMenuArray addObject:toggleContainer];
}

- (void)makeSubMenu {
    [subMenu setFrame:CGRectMake(0, 0, menuWidth, circleSize)];
    [subMenu setCenter:CGPointMake(subMenu.center.x, globalMenuArrow.center.y)];
    subMenu.backgroundColor = [UIColor clearColor];
    float y = subMenu.bounds.size.height/2;
    
    float height = circleSize * .75;
    float knobRadius = circleSize/8;
    float lineWidth = 1;
    BOOL hasLabel = NO;
    
    UIColor *knobColor = [UIColor clearColor];
    UIColor *sliderBgColor = [UIColor clearColor];

    float width = sw * .6;
    float x = (menuWidth / 2) + (spacerSize * 1);
    NNSlider *vol = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [vol addTarget:self action:@selector(subSliderAction:withEvent:) forControlEvents:UIControlEventValueChanged];
    [vol addTarget:self action:@selector(subSliderTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [vol addTarget:self action:@selector(subSliderTouchDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [vol addTarget:self action:@selector(subSliderTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [vol setCenter:CGPointMake(x,y)];
    [vol setBackgroundColor:sliderBgColor];
    vol.tag = 1;
    vol.knobColor = knobColor;
    vol.knobRadius = knobRadius;
    vol.lineWidth = lineWidth;
    vol.hasLabel = hasLabel;
    vol.shouldDoCoolAnimation = NO;
    vol.isSegmented = YES;
    vol.segments = 2;
    vol.snapsToSegments = NO;
    vol.segmentLineOffset = -3;
    vol.value = [[fxSettings objectAtIndex:8] floatValue];;
    
    [subMenu addSubview:vol];
    [KDAnimations jiggle:vol amount:1.1 then:nil];
}

- (void)makeSideMenu {
    float h = sh * .65;
    float y = (sh * .55) - (spacerSize / 2);
    
    
//    if ([KDHelpers isIpad]) {
//        if (!hasAds) {
//            h = sh * .6;
//            y = (sh * .55) + (spacerSize * 2);
//        } else {
//            h = sh * .55;
//            y = (sh * .55) + (spacerSize);
//        }
//    } else if ([KDHelpers iPhoneXCheck]) {
//        if (!hasAds) {
//            h = sh * .6;
//            y = (sh * .55) - (spacerSize * 2);
//        } else {
//            h = sh * .55;
//            y = (sh * .55) - (spacerSize * 3);
//        }
//    }


    [sideMenu setFrame:CGRectMake(0, 0, circleSize, h)];
    [sideMenu setCenter:CGPointMake(globalMenuArrow.center.x, y)];
    sideMenu.backgroundColor = [UIColor clearColor];
    
    y = sideMenu.bounds.size.height/2;
    
    float height = sideMenu.bounds.size.height;
    float knobRadius = circleSize/8;
    float lineWidth = 1;
    BOOL hasLabel = NO;
    
    UIColor *knobColor = [UIColor clearColor];
    UIColor *sliderBgColor = [UIColor clearColor];
    
    float width = sideMenu.bounds.size.width;
    float x = sideMenu.bounds.size.width/2;
    NNSlider *pitch = [[NNSlider alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [pitch addTarget:self action:@selector(subSliderAction:withEvent:) forControlEvents:UIControlEventValueChanged];
    [pitch addTarget:self action:@selector(subSliderTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [pitch addTarget:self action:@selector(subSliderTouchDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [pitch addTarget:self action:@selector(subSliderTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [pitch setCenter:CGPointMake(x,y)];
    [pitch setBackgroundColor:sliderBgColor];
    pitch.tag = 0;
    pitch.knobColor = knobColor;
    pitch.knobRadius = knobRadius;
    pitch.lineWidth = lineWidth;
    pitch.hasLabel = hasLabel;
    pitch.shouldDoCoolAnimation = NO;
    pitch.isSegmented = YES;
    pitch.segments = 6;
    pitch.snapsToSegments = NO;
    pitch.segmentLineOffset = -3;
    pitch.value = [[fxSettings objectAtIndex:7] floatValue];
    
    [sideMenu addSubview:pitch];
    [KDAnimations jiggle:pitch amount:1.1 then:nil];
}

- (void)makeMiniMenu {
    float h = sh * .65;
    float y = (sh * .55) - (spacerSize / 2);
    float cx = circleSize;
    float w = cx + spacerSize;
    [miniMenu setFrame:CGRectMake(0, 0, w, h)];
    [miniMenu setCenter:CGPointMake(globalMenuArrow.center.x + cx, y)];
    miniMenu.alpha = 0;
    [self makeMiniTableViewOnView:miniMenu];
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma FX Slider Actions

- (void)pitchSliderAction:(NNSlider*)slider {
    pitchSliderValue = slider.value;
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%f",pitchSliderValue]];
        [self saveLastFxSettings];
    });
}
- (void)reverbSliderAction:(NNSlider*)slider {
    float val = slider.value;
    int index = 1;
    if ((int)slider.tag == 0) {
        [pd sendFloat:val toReceiver:@"revAmount"];
    } else {
        [pd sendFloat:val toReceiver:@"revWD"];
        index = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%f",val]];
        [self saveLastFxSettings];
    });
}
- (void)delaySliderAction:(NNSlider*)slider {
    [pd sendFloat:slider.value toReceiver:@"delay"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%f",slider.value]];
        [self saveLastFxSettings];
    });
}
- (void)odSliderAction:(NNSlider*)slider {
    [pd sendFloat:slider.value toReceiver:@"odAmount"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%f",slider.value]];
        [self saveLastFxSettings];
    });
}
- (void)odFXSliderAction:(NNSlider*)slider {
    [pd sendFloat:slider.value toReceiver:@"odFX"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%f",slider.value]];
        [self saveLastFxSettings];
    });
}
- (void)crushSliderAction:(NNSlider*)slider {
    float val = slider.value;
    val = val * 100;
    val = (int)val;
    [pd sendFloat:val toReceiver:@"crush"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [fxSettings replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%f",slider.value]];
        [self saveLastFxSettings];
    });
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //


#pragma LOAD

- (void)loadBigMenu {
    for (int i = 0; i < bigMenuArray.count; i++) {
        UIView *view = [bigMenuArray objectAtIndex:i];
//        if (hasAds) {
//            view.alpha = .5;
//            view.userInteractionEnabled = NO;
//        }
        [bigMenuView addSubview:view];
    }
    for (int i = 0; i < bigMenuLabelsArray.count; i++) {
        UIView *view = [bigMenuLabelsArray objectAtIndex:i];
//        if (hasAds) {
//            view.alpha = .5;
//            view.userInteractionEnabled = NO;
//        }
        [bigMenuView addSubview:view];
    }
    
    if (hasLock) {
        UIView *popup = [KDHelpers popupWithClose:NO withCloseTarget:nil forCloseSelector:nil withColor:menuBGColor withBlurAmount:.2];
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, bigMenuView.frame.size.width*.7, bigMenuView.frame.size.height/2);
        view.backgroundColor = menuBGColor;
        view.layer.shadowOpacity = .5;
        view.layer.shadowOffset = CGSizeMake(1, 1);
        view.layer.shadowRadius = 3;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.masksToBounds = NO;
        
        KDButton *button = [KDButton initWithID:0 andWidth:view.bounds.size.width*.9 andText:@"Global Effects\n\nThe built-in presets use these effects, but consider unlocking the full version if you'd like to play around with them yourself!\n\nJust tap here to check out the unlock features!"];
        [button setTapAction:^(UITapGestureRecognizer*sender){
            [KDAnimations jiggle:sender.view amount:1.05 then:^{
                [self openPurchasePage:NO];
                [KDHelpers wait:.3 then:^{
                    [self handleHamburger];
                }];
            }];
        }];
 
        [view addSubview:button];
        [popup addSubview:view];
        [bigMenuView addSubview:popup];
        
        [KDHelpers centerView:button onView:view];
        [KDHelpers centerView:view onView:popup];
    }
}
//- (void)tapBigMenuUnlock:(UITapGestureRecognizer*)tap {
//
//}

- (void)loadKeys {
    int count = 0;
    
    for (UIView* circle in circleArray) {
        
        int newTag = ABS((int)circle.tag - circleTagMod - (int)circleArray.count + 1) + circleTagMod;
        circle.tag = newTag;
        [KDHelpers wait:.0125*count then:^{
            [self.view addSubview:circle];
            [self.view sendSubviewToBack:circle];
            [KDAnimations jiggle:circle amount:1.05 then:nil];
        }];
        count++;
    }
}

- (void)loadMenus {
    for (UIView* menuView in menuArray) {
        [self.view addSubview:menuView];
    }

    [self.view addSubview:topMenu];
    [self.view addSubview:subMenu];
    [self.view addSubview:sideMenu];
    [self.view addSubview:miniMenu];
    [self.view addSubview:globalMenuArrow];
    [self.view addSubview:miniMenuArrow];
    [self.view addSubview:saveMenu];
    [self.view addSubview:legendView];
    [self.view addSubview:bigMenuView];
    [self.view addSubview:hamburger];

}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Accel

- (void)setupAccel {
    
    accel = [kdAccelView initWithID:1];
    [accel setDelegate:self];
    [accel stopPolling];
}

- (void)kdAccelUpdate:(kdAccelView *)accel {
    
    if ([[toggleArray objectAtIndex:0] intValue] > 0) {
        float x = accel.pitch;
        x = [self curveAccel:x];
        [pd sendFloat:x toReceiver:@"x"];
        
        float y = accel.roll;
        y = [self curveAccel:y];
        [pd sendFloat:y toReceiver:@"y"];
        
        float z = accel.yaw;
        z = [self curveAccel:z];
        [pd sendFloat:z toReceiver:@"z"];
        
        //NSLog(@"\nx: %f  |  y: %f  |  z: %f",x,y,z);
    }
}

- (float)curveAccel:(float)x {
    float scale = 90;
    
    x = fabsf(x);
    x = log10f(x);
    x = MAX(MIN(x, 0), -1);
    x = 1 / x;
    x = MAX(MIN(x, -1), -scale);
    x = fabsf(x);
    x = x / scale;
    
    return x;
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Toggles

- (void)kdToggleWasToggled:(kdToggle *)toggle {
    //NSLog(@"Toggle: %d | State: %d",toggle.uid,toggle.isOn);

    [toggleArray replaceObjectAtIndex:toggle.uid withObject:[NSNumber numberWithBool:toggle.isOn]];
    [self handleToggle:toggle];
    [self saveLastToggleSettings];
}
- (void)handleToggle:(kdToggle*)toggle {
    switch (toggle.uid) {
        case 0:
            if (toggle.isOn) {
                [accel startPolling];
                [pd sendFloat:1 toReceiver:@"accelFade"];
            } else {
                [pd sendFloat:0 toReceiver:@"accelFade"];
                [accel stopPolling];
            }
            break;
        case 1:
            useNaturalTuning = toggle.isOn;
            float val = toggle.isOn + 1;
            [pd sendFloat:val toReceiver:@"tuning"];
            break;
            
        default:
            break;
    }
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Make Sound

- (int)handlePoly:(int)tag {
    NSArray *tempArr = [NSArray arrayWithArray:dollarZeroArray];
    
    patchCounter++;
    patchCounter = patchCounter % numInstruments;
    int dollarZero = patchCounter;
    
    if (tempArr.count > 0) {
        for (NSArray *arr in tempArr) {
            if ([[arr objectAtIndex:1] intValue] == patchCounter) {
                patchCounter ++;
                patchCounter = patchCounter % numInstruments;
            }
        }
        dollarZero = patchCounter;
    }
    
    NSNumber *t = [NSNumber numberWithInt:tag];
    NSNumber * dZ = [NSNumber numberWithInt:dollarZero];
    NSArray *touchArray = @[t, dZ];
    
    [dollarZeroArray addObject:touchArray];
    //NSLog(@"touch on %@",touchArray);
    
    return dollarZero;
}

- (void)handleXY:(CGPoint)loc viewTag:(int)tag dollarZero:(int)dollarZero {

    int row = (tag - circleTagMod) / numWidth;
    NSArray *arr = [NSArray arrayWithArray:[settings objectAtIndex:row]];
    int type = [[arr objectAtIndex:0] intValue];
    
    float x = .5;
    float y = .5;
    float fx = [[arr objectAtIndex:2] floatValue];
    if (fx > 0) {
        x = loc.x / circleSize;
        y = loc.y / circleSize;
        x = MAX(MIN(x, 1), 0);
        y = MAX(MIN(y, 1), 0);
    }

    [pd sendFloat:x toReceiver:[NSString stringWithFormat:@"%d-%d.q",dollarZero,type]];
    [pd sendFloat:y toReceiver:[NSString stringWithFormat:@"%d-%d.bpf",dollarZero,type]];
}

- (void)handleForce:(CGFloat)force viewTag:(int)tag dollarZero:(int)dollarZero {
    

    
    int row = (tag - circleTagMod) / numWidth;
    NSArray *arr = [NSArray arrayWithArray:[settings objectAtIndex:row]];
    int type = [[arr objectAtIndex:0] intValue];

    float f = .5;
    if (!hasLock) {
        if (useForceTouch) {
            f = force;
        }
    }
    f = CLIP(f, .15, 6.66);
    [pd sendFloat:f toReceiver:[NSString stringWithFormat:@"%d-%d.force",dollarZero,type]];
}

- (BOOL)checkForForceTouch {
    BOOL forceTouch = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        forceTouch = YES;
    }
    return forceTouch;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    CGPoint loc = [touch locationInView:view];

    [self handleBegin:view loc:loc force:touch.force];
}
- (void)handleBegin:(UIView *)view loc:(CGPoint)loc force:(CGFloat)force {
    int tag = (int)view.tag;
    if (tag < 200) {
        if (tag >= 100) {
            int dollarZero = [self handlePoly:tag];
            
            [self handleXY:loc viewTag:tag dollarZero:dollarZero];
            [self handleForce:force viewTag:tag dollarZero:dollarZero];
            [self playSound:view dollarZero:dollarZero];
            [KDAnimations jiggleSize:view amount:1.075 then:nil];
            [self showTouchDown:loc inView:view];
        }
    }
}
 
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    
    CGPoint loc = [touch locationInView:view];
    [self handleMoved:loc inView:view force:touch.force];
}
- (void)handleMoved:(CGPoint)loc inView:(UIView *)view force:(CGFloat)force {
    int tag = (int)view.tag;
    
    NSArray *tempArr = [NSArray arrayWithArray:dollarZeroArray];
    int dollarZero = 0;
    for (NSArray *touchArray in tempArr) {
        int touch = [[touchArray objectAtIndex:0] intValue];
        if (touch == tag) {
            dollarZero = [[touchArray objectAtIndex:1] intValue];
        }
    }
    
    if (tag < 200) {
        if (tag >= 100) {
            [self handleXY:loc viewTag:tag dollarZero:dollarZero];
            [self handleForce:force viewTag:tag dollarZero:dollarZero];
            [self showTouchDown:loc inView:view];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];

    [self handleEnd:view];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];

    [self handleEnd:view];
}
- (void)handleEnd:(UIView *)view {
    int tag = (int)view.tag;
    if (tag < 200) {
        if (tag >= 100) {
            [self stopSound:view];
            [KDAnimations jiggleSizeReset:view then:nil];
        }
    }
}

- (void)showTouchDown:(CGPoint)loc inView:(UIView *)view {
    float size = circleSize / 2.5;
    [KDAnimations showTouchDownAt:loc withSize:size andLineWidth:circleLineWidth onView:view then:nil];
}

- (void)playSound:(UIView*)view dollarZero:(int)dollarZero {
    
    for (NNSlider* slider in subMenu.subviews) {
        if (slider.value == 0) {
            [KDAnimations jiggle:slider amount:1.1 then:nil];
        }
    }
    
    [warningLabel checkVolume];
    
    int tag = (int)view.tag;
    int row = (tag - circleTagMod) / numWidth;
    NSArray *arr = [NSArray arrayWithArray:[settings objectAtIndex:row]];
    
    int type = [[arr objectAtIndex:0] intValue];
    float body = [[arr objectAtIndex:1] floatValue];
    float style = [[arr objectAtIndex:2] floatValue];
    if (style > 0) {
        style = 101 - style;
    }
    
    float pit = [self getPitForTag:tag type:type];
    
//        NSLog(@"pitch slider %f",pitchSliderValue);
//        NSLog(@"lowpitch %f",lowPitch);
//        NSLog(@"pit %f",pit);
    
    float fx = [[arr objectAtIndex:3] floatValue];
    float vol = [[arr objectAtIndex:4] floatValue];
    
    lastPitch = @[[NSNumber numberWithInt:tag],[NSNumber numberWithInt:type],[NSString stringWithFormat:@"%d-%d.pit",dollarZero,type],[NSString stringWithFormat:@"%d-%d.toggle",dollarZero,type]];
    [pd sendFloat:body toReceiver:[NSString stringWithFormat:@"%d.sustain",dollarZero]];
    [pd sendFloat:body toReceiver:[NSString stringWithFormat:@"%d-%d.body",dollarZero,type]];
    [pd sendFloat:fx toReceiver:[NSString stringWithFormat:@"%d-fx",dollarZero]];
    [pd sendFloat:vol toReceiver:[NSString stringWithFormat:@"%d-%d.vol",dollarZero,type]];
    [pd sendFloat:style toReceiver:[NSString stringWithFormat:@"%d-%d.style",dollarZero,type]];
    [pd sendFloat:pit toReceiver:[NSString stringWithFormat:@"%d-%d.pit",dollarZero,type]];
    [pd sendFloat:1 toReceiver:[NSString stringWithFormat:@"%d-%d.toggle",dollarZero,type]];
    [pd sendFloat:1 toReceiver:[NSString stringWithFormat:@"%d.off",dollarZero]];
//        NSLog(@"Circle Tag: %d Began with $0 %d",(int)view.tag,dollarZero);
//        NSLog(@"pit %f",pit);
//        //NSLog(@"%@",arr);
//        NSLog(@"type %d, body %f, fx %f, vol %f, pit %f",type,body,fx,vol,pit);
}

- (float)getPitForTag:(int)tag type:(int)type {
    float pit = 0;
    float tempPitchSliderValue = pitchSliderValue * 2.05;
    float tempLowPitch = lowPitch;
    
    if (type == 4) {
        tempLowPitch = lowPitch + 10;
    }
    
    if (useNaturalTuning) {
        
        float pitchMod = 4 + tempLowPitch;
        float pitch = (((float)tag - circleTagMod)+1) * pitchMod;
        float basePitch = ((100 - circleTagMod)+1) * pitchMod;
        float mod = 10;
        
        pitch = pitch * mod;
        basePitch = pitchMod * mod;
        
        float pitMod = 0;
        
        float loop = tag - circleTagMod;
        if ((loop * tempPitchSliderValue) > 0) {
            for (int i = 0; i < loop; i++) {
                pitMod = pitMod + tempPitchSliderValue;
            }
            pitMod = (pitMod * basePitch);
        } else {
            
        }
        
        pit = pitch + pitMod + (500 * tempPitchSliderValue);
    } else {
        
        float pitMod = 0;
        float tempLow = (int)tempLowPitch * 1.00;
        pit = tag - circleTagMod + 48;
        
        float loop = tag - circleTagMod;
        if ((loop * tempPitchSliderValue) > 0) {
            for (int i = 0; i < loop; i++) {
                pitMod = pitMod + tempPitchSliderValue;
            }
        }
        pit = pit + pitMod + tempLow;
    }
    return pit;
}

- (void)stopSound:(UIView*)view {
    int tag = (int)view.tag;
    int row = (tag - circleTagMod) / numWidth;
    NSArray *arr = [NSArray arrayWithArray:[settings objectAtIndex:row]];
    int type = [[arr objectAtIndex:0] intValue];

    NSArray *tempArr = [NSArray arrayWithArray:dollarZeroArray];
    int dollarZero = 0;
    for (NSArray *touchArray in tempArr) {
        int touch = [[touchArray objectAtIndex:0] intValue];
        if (touch == tag) {
            dollarZero = [[touchArray objectAtIndex:1] intValue];
        }
    }
    //NSLog(@"touch off %d",dollarZero);
    
    [self soundOff:type dollarZero:dollarZero];
    //    NSLog(@"off: %d %d %d %d",typeOneCount,typeTwoCount,typeThreeCount,typeFourCount);
    //    NSLog(@"Circle Tag: %d Ended",(int)view.tag);
}

- (void)soundOff:(int)type dollarZero:(int)dollarZero {
    
    lastPitch = nil;
    [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d-%d.toggle",dollarZero,type]];
    [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d.off",dollarZero]];
    
    NSArray *tempArr = [NSArray arrayWithArray:dollarZeroArray];
    for (NSArray *arr in tempArr) {
        if ([[arr objectAtIndex:1] intValue] == dollarZero) {
            [dollarZeroArray removeObject:arr];
        }
    }
}
- (void)soundOffAll {
    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 4; j++){
            [self soundOff:j dollarZero:i];
        }
    }
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Handle Show Settings

- (void)tapHamburger:(UITapGestureRecognizer *)sender {
    [self handleHamburger];
}
- (void)handleHamburger {
    float degrees = 270;
    float slideDur = slideAnimDur;
    float fadeDur = fadeAnimDur;
    float rotateDur = rotateAnimDur;
    
    if (hamburger.tag < 9999) {
        hamburger.tag = 9999;
        [KDAnimations slide:bigMenuView amountX:0 amountY:self.view.bounds.size.height duration:slideDur then:nil];
        [KDAnimations fade:bigMenuView alpha:1 duration:fadeDur then:nil];
    } else {
        hamburger.tag = 9998;
        degrees = 0;
        [KDAnimations slide:bigMenuView amountX:0 amountY:-self.view.bounds.size.height duration:slideDur then:nil];
        [KDAnimations fade:bigMenuView alpha:0 duration:fadeDur then:nil];
    }
    [KDAnimations rotate:hamburger degrees:degrees duration:rotateDur then:nil];
}

- (void)tapGlobalArrow:(UITapGestureRecognizer *)sender {
    [self handleTapGlobalArrow:sender.view];
}
- (void)handleTapGlobalArrow:(UIView *)view {
    float degrees = 180;
    float amount = menuWidth;
    float slideDur = slideAnimDur;
    float fadeDur = fadeAnimDur;
    float rotateDur = rotateAnimDur;
    float alpha = 1;
    
    if (view.tag < 8999) {
        view.tag = 8999;
        for (UIView* menu in menuArray) {
            [KDAnimations slide:menu amountX:amount amountY:0 duration:slideDur then:nil];
            [KDAnimations fade:menu alpha:alpha duration:fadeDur then:nil];
        }
        [self slideLegend:amount alpha:alpha slideDur:slideDur fadeDur:fadeDur];
    } else {
        view.tag = 8998;
        degrees = 0;
        alpha = 0;
        amount = -amount;
        
        for (UIView* menu in menuArray) {
            [KDAnimations slide:menu amountX:amount amountY:0 duration:slideDur then:nil];
            [KDAnimations fade:menu alpha:alpha duration:fadeDur then:nil];
        }
        [self slideLegend:amount alpha:alpha slideDur:slideDur fadeDur:fadeDur];
    }
    [KDAnimations rotate:view degrees:degrees duration:rotateDur then:nil];
}
- (void)tapMiniArrow:(UITapGestureRecognizer *)sender {
    [self handleTapMiniArrow:sender.view];
}
- (void)handleTapMiniArrow:(UIView *)view {
    float degrees = 180;
    float amount = 0;
    float slideDur = slideAnimDur;
    float fadeDur = fadeAnimDur;
    float rotateDur = rotateAnimDur;
    float alpha = 1;
    
    if (view.tag < 8999) {
        view.tag = 8999;
        amount = -circleSize;
    } else {
        view.tag = 8998;
        degrees = 0;
        alpha = 0;
    }
    [KDAnimations slide:miniMenu amountX:amount amountY:0 duration:slideDur then:nil];
    [KDAnimations slide:sideMenu amountX:amount amountY:0 duration:slideDur then:nil];
    [KDAnimations fade:miniMenu alpha:alpha duration:fadeDur then:nil];
    [KDAnimations fade:sideMenu alpha:1-alpha duration:fadeDur then:nil];
    [KDAnimations rotate:view degrees:degrees duration:rotateDur then:nil];
}

- (void)slideLegend:(float)amount alpha:(float)alpha slideDur:(float)slideDur fadeDur:(float)fadeDur {
    [KDAnimations slide:legendView amountX:amount amountY:0 duration:slideDur then:nil];
    [KDAnimations fade:legendView alpha:alpha duration:fadeDur then:nil];
    [KDAnimations slide:saveMenu amountX:amount amountY:0 duration:slideDur then:nil];
    [KDAnimations fade:saveMenu alpha:alpha duration:fadeDur then:nil];
    [KDAnimations fade:topMenu alpha:1-alpha duration:fadeDur then:nil];
    [KDAnimations fade:subMenu alpha:1-alpha duration:fadeDur then:nil];
    settingsOpen = !settingsOpen;
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Handle Global Settings

- (void)tapType:(UITapGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *dial = (UILabel*)sender.view;
        int num = [dial.text intValue];
        num = num + 1;
        if (num > 4) {
            num = 1;
        }
        dial.text = [NSString stringWithFormat:@"%d",num];
        
        [self saveDial:sender.view value:num];
        [self saveLastSettings];
    });
}

- (void)tapTypeGlobal:(UITapGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < dialArray.count; i++) {
            if (i % iconArray.count == 0) {
                UILabel *dial = [dialArray objectAtIndex:i];
                int num = [dial.text intValue];
                num = num + 1;
                if (num > numInstruments) {
                    num = 1;
                }
                dial.text = [NSString stringWithFormat:@"%d",num];
                
                [self saveDial:dial value:num];
                [self saveLastSettings];
            }
        }
    });
}

- (void)swipeTypeGlobal:(UISwipeGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < dialArray.count; i++) {
            if (i % iconArray.count == 0) {
                UILabel *dial = [dialArray objectAtIndex:i];
                dial.text = [NSString stringWithFormat:@"1"];
                
                [self saveDial:dial value:[dial.text intValue]];
                [self saveLastSettings];
            }
        }
    });
}

- (void)globalSliderAction:(NNSlider *)dial withEvent:(UIEvent*)event {
}
- (void)globalSliderTouchDown:(NNSlider*)dial withEvent:(UIEvent*)event {
    [self handleGlobalSlider:dial];
}
- (void)globalSliderTouchDrag:(NNSlider*)dial withEvent:(UIEvent*)event {
    [self handleGlobalSlider:dial];
}
- (void)globalSliderTouchEnd:(NNSlider*)dial withEvent:(UIEvent*)event {
    [self handleGlobalSlider:dial];
}
- (void)handleGlobalSlider:(NNSlider*)dial {
    for (int i = 0; i < dialArray.count; i++) {
        if (i % iconArray.count != 0) {
            NNSlider *newDial = [dialArray objectAtIndex:i];
            int newDialTag = (int)newDial.tag % 10;
            
            if (newDialTag == (int)dial.tag) {
                newDial.value = dial.value;
                [newDial animateUpdateValue:dial.value];
                
                [self saveDial:newDial value:dial.value*100];
                [self saveLastSettings];
            }
        }
    }
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Handle Settings

- (void)sliderAction:(NNSlider *)dial withEvent:(UIEvent*)event {
    [KDHelpers async:^{
        [self saveDial:dial value:dial.value*100];
        [self saveLastSettings];
    }];
}
- (void)sliderTouchDown:(NNSlider*)dial withEvent:(UIEvent*)event {
    [dial.superview bringSubviewToFront:dial];
    float x = [self getLocX:dial withEvent:event];
    BOOL left = YES;
    if (x < dial.frame.size.width/2) {
        left = NO;
    }
    [dial.superview bringSubviewToFront:dial];
    if (left) {
        dial.shouldFlip = NO;
        [KDAnimations offsetLeft:dial amount:circleSize/2 then:nil];
    } else {
        dial.shouldFlip = YES;
        [KDAnimations offsetRight:dial amount:circleSize/2 then:nil];
    }
}
- (void)sliderTouchDrag:(NNSlider*)dial withEvent:(UIEvent*)event {
    float x = [self getLocX:dial withEvent:event];
    BOOL left = YES;
    if (x < dial.frame.size.width/2) {
        left = NO;
    }

    if (left) {
        if (dial.shouldFlip) {
            dial.shouldFlip = NO;
            [KDAnimations offsetLeft:dial amount:circleSize/2 then:nil];
        }
    } else {
        if (!dial.shouldFlip) {
            dial.shouldFlip = YES;
            [KDAnimations offsetRight:dial amount:circleSize/2 then:nil];
        }
    }
}
- (void)sliderTouchEnd:(NNSlider*)dial withEvent:(UIEvent*)event {
    [dial.superview sendSubviewToBack:dial];
    [KDAnimations offsetReset:dial then:nil];
}
- (float)getLocX:(NNSlider*)dial withEvent:(UIEvent*)event {
    UITouch *touch = [[event touchesForView:dial] anyObject];
    CGPoint loc = [touch locationInView:dial];
    float x = MIN(loc.x,dial.frame.size.width);
    x = MAX(x,0);
    return x;
}

- (void)tapSaveLoad:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 0:
            if (!hasAds) {
                [self openSaveDialogueWithTag:0];
            } else {
//                UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(closeAdToSavePopup:) withColor:[UIColor whiteColor] withBlurAmount:0];
//
//                UILabel *mainText = [KDHelpers makeLabelWithWidth:sw*.7 andHeight:view.bounds.size.height/4];
//                mainText.textAlignment = NSTextAlignmentCenter;
//                mainText.font = [UIFont fontWithName:globalFont size:fontSize];
//                mainText.text = @"Save Preset?";
//                mainText.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/5);
//
//                if (savePageAdLoaded) {
//                    savePageAd.frame = CGRectMake(0, 0, view.bounds.size.width, savePageAd.bounds.size.height);
//                    savePageAd.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
//                } else {
//                    UILabel *label = [KDHelpers makeLabelWithWidth:view.bounds.size.width * .95 andHeight:300];
//                    label.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
//                    label.font = [UIFont fontWithName:globalFont size:fontSize];
//                    label.textAlignment = NSTextAlignmentCenter;
//                    label.text = [self getPersonalAd];
//
//                    [view addSubview:label];
//
//                    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnlock:)];
//                    [label addGestureRecognizer:t];
//                }
//
//                UILabel *save = [KDHelpers makeLabelWithWidth:sw*.9 andHeight:60];
//                save.textAlignment = NSTextAlignmentCenter;
//                save.font = [UIFont fontWithName:globalFont size:fontSize];
//                save.attributedText = [KDHelpers underlinedString:@"Yes!"];
//                save.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height - (view.bounds.size.height/5));
//
//                UITapGestureRecognizer *tapSave = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reallySave:)];
//                [save addGestureRecognizer:tapSave];
//
//                [view addSubview:mainText];
//                [view addSubview:savePageAd];
//                [view addSubview:save];
//
//                [KDAnimations animateViewGrowAndShow:view then:nil];
//                [self.view addSubview:view];
            }
            break;
        case 1:
            [self openLoadDialogue];
            break;
        default:
            break;
    }
    
    [KDAnimations jiggle:sender.view amount:1.05 then:nil];
}

- (NSString*)getPersonalAd {
    NSString *str = [personalAds objectAtIndex:personalAdCount];
    personalAdCount++;
    personalAdCount = personalAdCount % [personalAds count];
    return str;
}

- (void)reallySave:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view amount:1.05 then:^{
        [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:^{
            [KDHelpers wait:.05 then:^{
                [self openSaveDialogueWithTag:0];
            }];
        }];
    }];
}

//- (void)closeAdToSavePopup:(UIGestureRecognizer*)sender {
//    [KDAnimations jiggle:sender.view amount:1.05 then:nil];
//    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:^{
//        [self resetSavePageAd];
//    }];
//}

- (void)openSaveDialogueWithTag:(int)tag {
    UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(tapCloseTableView:) withColor:menuBGColor withBlurAmount:0];
    
    float textFieldMargin = 50;
    float textFieldHeight = 100;
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(textFieldMargin, view.bounds.size.height/3, sw-textFieldMargin, textFieldHeight)];
    textfield.font = [UIFont fontWithName:globalFont size:fontSize*1.25];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.keyboardType = UIKeyboardTypeDefault;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.delegate = self;
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.tintColor = [UIColor blackColor];
    
    NSString *place = @"   Save As";
    if (tag > 0 ) {
        place = @"   Rename";
    }
    textfield.placeholder = place;
    textfield.tag = tag;
    [view addSubview:textfield];
    
    [KDAnimations animateViewGrowAndShow:view then:nil];
    [self.view addSubview:view];
    [textfield becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doSaveSettings:textField];
    return YES;
}

- (void)doSaveSettings:(UITextField*)textField {
    NSString *str = textField.text;
    
    if (textField.tag < 1) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:settings];
        NSMutableArray *tempFx = [NSMutableArray arrayWithArray:fxSettings];
        NSMutableArray *tempTog = [NSMutableArray arrayWithArray:toggleArray];
        [temp addObject:str];
        [savedSettings addObject:temp];
        [fxSavedSettings addObject:tempFx];
        [savedToggleSettings addObject:tempTog];
    } else {
        NSMutableArray *temp = [savedSettings objectAtIndex:(int)textField.tag];
        [[savedSettings objectAtIndex:(int)textField.tag] replaceObjectAtIndex:temp.count-1 withObject:str];
    }
    [KDAnimations animateViewShrinkAndWink:textField.superview andRemoveFromSuperview:YES then:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveSettings];
        if (tableView) {
            [tableView reloadData];
        }
        if (miniTableView) {
            [miniTableView reloadData];
        }
    });
}

- (void)openLoadDialogue {
    UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(tapCloseTableView:) withColor:menuBGColor withBlurAmount:0];
    [KDAnimations animateViewGrowAndShow:view then:nil];
    [self makeTableViewOnView:view];
    [self.view addSubview:view];
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Handle Pitch and Volume Settings

- (void)subSliderAction:(NNSlider *)dial withEvent:(UIEvent*)event {
}
- (void)subSliderTouchDown:(NNSlider*)dial withEvent:(UIEvent*)event {
    [self handleSubSlider:dial];
}
- (void)subSliderTouchDrag:(NNSlider*)dial withEvent:(UIEvent*)event {
    [self handleSubSlider:dial];
}
- (void)subSliderTouchEnd:(NNSlider*)dial withEvent:(UIEvent*)event {
}
- (void)handleSubSlider:(NNSlider*)dial {
    int index = 7;
    switch (dial.tag) {
        case 0:
            lowPitch = dial.value * 20;
            if (lastPitch) {
                int tag = [[lastPitch objectAtIndex:0] intValue];
                int type = [[lastPitch objectAtIndex:1] intValue];
                NSString *pitReceive = [lastPitch objectAtIndex:2];
                NSString *togReceive = [lastPitch objectAtIndex:3];
                float pit = [self getPitForTag:tag type:type];
                [pd sendFloat:pit toReceiver:pitReceive];
                [pd sendFloat:1 toReceiver:togReceive];
                [KDHelpers wait:.1 then:^{
                    [pd sendFloat:1 toReceiver:togReceive];
                }];
            }
            [self handleGlissValues:dial.value];
            break;
        case 1:
            [pd sendFloat:dial.value toReceiver:@"masterVol"];
            index = 8;
            break;
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [NSString stringWithFormat:@"%f",dial.value];
        [fxSettings replaceObjectAtIndex:index withObject:str];
        [self saveLastFxSettings];
    });
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Recording Buttons

- (void)tapTopMenu:(UITapGestureRecognizer *)sender {
    int tag = (int)sender.view.tag;
    
    if ([[topMenuRotating objectAtIndex:tag] intValue] > 0) {
        if (useHaptics) {
            [HapticHelper generateFeedback:FeedbackType_Impact_Light];
        }
        [topMenuRotating replaceObjectAtIndex:tag withObject:@"0"];
        [self stopAnimating:sender.view];
        [self setHasRecording:sender.view];
    } else {
        if ([[topMenuPulsing objectAtIndex:tag] intValue] < 1) {
            int recorded = [[topMenuRecordings objectAtIndex:tag] intValue];
            if (recorded > 0) {
                [topMenuPulsing replaceObjectAtIndex:tag withObject:@"1"];
                [self startPlayback:sender.view];
            } else {
                [self turnOnRecording:sender.view];
            }
        } else {
            [self resetPlayback:sender.view];
        }
    }
}

- (void)lpTopMenu:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        int tag = (int)sender.view.tag;
        [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d.play",tag]];
        [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d.record",tag]];
        
        [topMenuPulsing replaceObjectAtIndex:tag withObject:@"0"];
        [topMenuRotating replaceObjectAtIndex:tag withObject:@"0"];
        [topMenuRecordings replaceObjectAtIndex:tag withObject:@"0"];
        [self stopAnimating:sender.view];
        [self setHasRecording:sender.view];
        
        if (useHaptics) {
            [HapticHelper generateFeedback:FeedbackType_Impact_Medium];
        }
    }
}

- (void)turnOnRecording:(UIView*)view {
    int tag = (int)view.tag;
    [topMenuRotating replaceObjectAtIndex:tag withObject:@"1"];
    [topMenuRecordings replaceObjectAtIndex:tag withObject:@"1"];
    [self animateStartRecording:view];
}

- (void)animateStartRecording:(UIView*)view {
    float amount = 1.2;
    int tag = (int)view.tag;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f
                              delay:0.0f
             usingSpringWithDamping:.2f
              initialSpringVelocity:12.f
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, amount, amount);
                         }
                         completion:^(BOOL finished) {
                             if (useHaptics) {
                                 [HapticHelper generateFeedback:FeedbackType_Impact_Medium];
                             }
                             [pd sendFloat:1 toReceiver:[NSString stringWithFormat:@"%d.record",tag]];
                             [KDAnimations rock:view.layer degrees:40 withDuration:.4 then:nil];
                         }];
    });
}

- (void)resetPlayback:(UIView*)view {
    int tag = (int)view.tag;
    [topMenuPulsing replaceObjectAtIndex:tag withObject:@"0"];
    
    [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d.play",tag]];
    
    [self stopAnimating:view];
    [KDAnimations jiggle:view amount:1.2 then:nil];
}

- (void)startPlayback:(UIView*)view {
    
    [warningLabel checkVolume];
    
    int index = (int)view.tag;
    [pd sendFloat:1 toReceiver:[NSString stringWithFormat:@"%d.play",index]];
    
    [self handleAnimateRecording:view];
}

- (void)handleAnimateRecording:(UIView*)view {
    [self doAnimateRecording:view];
}

- (void)doAnimateRecording:(UIView*)view {
    int index = (int)view.tag;
    float animTime = [[topMenuTimers objectAtIndex:index] floatValue];
    animTime = animTime / 1000;
    animTime = animTime - .27;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.05
                              delay:0.0f
             usingSpringWithDamping:.5f
              initialSpringVelocity:4.f
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, .3, .3);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:animTime
                                                   delay:0.0f
                                                 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                                              animations:^{
                                                  view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                              }
                                              completion:^(BOOL finished) {
                                                  if (finished) {
                                                      [UIView animateWithDuration:0.1f
                                                                            delay:0.0f
                                                           usingSpringWithDamping:.5f
                                                            initialSpringVelocity:4.f
                                                                          options:(UIViewAnimationOptionAllowUserInteraction |
                                                                                   UIViewAnimationOptionCurveEaseOut)
                                                                       animations:^{
                                                                           view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                                                                       }
                                                                       completion:^(BOOL finished) {
                                                                           [UIView animateWithDuration:0.12f
                                                                                                 delay:0.0f
                                                                                usingSpringWithDamping:.3f
                                                                                 initialSpringVelocity:10.0f
                                                                                               options:(UIViewAnimationOptionAllowUserInteraction |
                                                                                                        UIViewAnimationOptionCurveEaseOut)
                                                                                            animations:^{
                                                                                                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                                                                            }
                                                                                            completion:^(BOOL finished) {
                                                                                                [self handleAnimateRecording:view];
                                                                                            }];
                                                                       }];
                                                  }
                                              }];
                         }];
    });
}

- (void)setHasRecording:(UIView*)view {
    [KDAnimations jiggle:view amount:1.5 then:nil];
    int tag = (int)view.tag;
    int recorded = [[topMenuRecordings objectAtIndex:tag] intValue];
    UILabel *label = (UILabel*)view;
    NSString *text = topMenuString;
    
    [pd sendFloat:0 toReceiver:[NSString stringWithFormat:@"%d.record",tag]];
    
    if (recorded > 0) {
        text = @"ⓞ";
    }
    [label setText:text];
}

- (void)resetRecording:(int)index {
    [topMenuRecordings replaceObjectAtIndex:index withObject:@"0"];
}

- (void)stopAnimating:(UIView*)view {
    [KDAnimations stopPulse:view.layer withDuration:.2 then:nil];
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma Table View

- (void)makeTableViewOnView:(UIView*)view {
    
    float sideMargin = 20;
    float topMargin = 70; //in makeDialoguePopup - closeSize+marginSize
    CGRect frame = CGRectMake(sideMargin,topMargin,view.bounds.size.width-(sideMargin*2)-15,view.bounds.size.height-(topMargin*2));
    
//    if (hasAds) {
//        float adSize = 250;
//        float adOffset = 40;
//        frame = CGRectMake(sideMargin,topMargin,view.bounds.size.width-(sideMargin*2)-15,view.bounds.size.height-(topMargin*1)-adSize-adOffset);
//
//        if (loadPageAdLoaded) {
//            loadPageAd.frame = CGRectMake(0, view.bounds.size.height-adSize-(adOffset/2), view.bounds.size.width, loadPageAd.bounds.size.height);
//            loadPageAd.center = CGPointMake(view.bounds.size.width/2, loadPageAd.center.y);
//        } else {
//            UILabel *label = [KDHelpers makeLabelWithWidth:view.bounds.size.width * .95 andHeight:300];
//            [KDHelpers setOriginY:view.bounds.size.height-adSize-(adOffset/2) forView:label];
//            label.center = CGPointMake(view.bounds.size.width/2, label.center.y);
//            label.font = [UIFont fontWithName:globalFont size:fontSize];
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = [self getPersonalAd];;
//
//            UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnlock:)];
//            [label addGestureRecognizer:t];
//
//            [view addSubview:label];
//        }
//
//        [view addSubview:loadPageAd];
//    }

    
    UIView *container = [[UIView alloc] initWithFrame:frame];
    tableView = [[BVReorderTableView alloc]init];
    tableView.tag = 0;
    tableView.frame = container.bounds;
    tableView.dataSource=self;
    tableView.delegate=self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [tableView reloadData];
    
    [container addSubview:tableView];
    [KDHelpers addGradientMaskToView:container];
    [view addSubview:container];
}
- (void)makeMiniTableViewOnView:(UIView*)view {
    UIView *container = [[UIView alloc] initWithFrame:view.bounds];
    miniTableView = [[BVReorderTableView alloc]init];
    miniTableView.tag = 1;
    miniTableView.canReorder = NO;
    miniTableView.frame = container.bounds;
    miniTableView.dataSource=self;
    miniTableView.delegate=self;
    miniTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    miniTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [miniTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [miniTableView reloadData];
    
    [container addSubview:miniTableView];
    [KDHelpers addGradientMaskToView:container];
    [view addSubview:container];
}

- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [savedSettings objectAtIndex:indexPath.row];

    [savedSettings replaceObjectAtIndex:indexPath.row withObject:@"_____---------REORDERDUMMY-----______"];
    return object;
}
- (id)saveObject2AndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [fxSavedSettings objectAtIndex:indexPath.row];

    [fxSavedSettings replaceObjectAtIndex:indexPath.row withObject:@"_____---------REORDERDUMMY-----______"];
    return object;
}
- (id)saveObject3AndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [savedToggleSettings objectAtIndex:indexPath.row];

    [savedToggleSettings replaceObjectAtIndex:indexPath.row withObject:@"_____---------REORDERDUMMY-----______"];
    return object;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id object = [savedSettings objectAtIndex:fromIndexPath.row];
    id fxobject = [fxSavedSettings objectAtIndex:fromIndexPath.row];
    id toggleobject = [savedToggleSettings objectAtIndex:fromIndexPath.row];
    
    [savedSettings removeObjectAtIndex:fromIndexPath.row];
    [savedSettings insertObject:object atIndex:toIndexPath.row];
    
    [fxSavedSettings removeObjectAtIndex:fromIndexPath.row];
    [fxSavedSettings insertObject:fxobject atIndex:toIndexPath.row];
    
    [savedToggleSettings removeObjectAtIndex:fromIndexPath.row];
    [savedToggleSettings insertObject:toggleobject atIndex:toIndexPath.row];
}

- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    [savedSettings replaceObjectAtIndex:indexPath.row withObject:object];
}
- (void)finishReorderingWithObject2:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    [fxSavedSettings replaceObjectAtIndex:indexPath.row withObject:object];
}
- (void)finishReorderingWithObject3:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    [savedToggleSettings replaceObjectAtIndex:indexPath.row withObject:object];
}
- (void)reorderComplete {
    [self saveSettings];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (miniTableView) {
            [miniTableView reloadData];
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return savedSettings.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier   forIndexPath:indexPath] ;
    
    if ([[savedSettings objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&
        [[savedSettings objectAtIndex:indexPath.row] isEqualToString:@"_____---------REORDERDUMMY-----______"]) {
        cell.textLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ((int)tableView.tag == 0) {
            cell.textLabel.font = [UIFont fontWithName:globalFont size:fontSize];
        } else {
            cell.textLabel.font = [UIFont fontWithName:globalFont size:fontSize/2];
        }
        cell.textLabel.text=[[savedSettings objectAtIndex:indexPath.row] lastObject];
        
    }
    
    cell.tag = indexPath.row;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [KDAnimations jiggle:[tableView cellForRowAtIndexPath:indexPath] amount:1.1 then:nil];
    [self handleLoading:(int)indexPath.row];
    if ((int)tableView.tag == 0) {
        [KDAnimations animateViewShrinkAndWink:tableView.superview.superview andRemoveFromSuperview:YES then:nil];
        tableView = nil;
        [self handleTapGlobalArrow:globalMenuArrow];
    }
}

- (void)handleLoading:(int)index {
    [self soundOffAll];
    NSArray *tempArr = [savedSettings objectAtIndex:index];
    NSArray *tempFxArr = [fxSavedSettings objectAtIndex:index];
    NSArray *tempToggleArr = [savedToggleSettings objectAtIndex:index];
    NSMutableArray *temp = [NSMutableArray arrayWithArray:tempArr];
    [temp removeLastObject];
    settings = [NSMutableArray arrayWithArray:temp];
    fxSettings = [NSMutableArray arrayWithArray:tempFxArr];
    toggleArray = [NSMutableArray arrayWithArray:tempToggleArr];
    [self saveLastSettings];
    [self saveLastFxSettings];
    [self saveLastToggleSettings];
    for (NNSlider* dial in legendView.subviews) {
        if ([dial isKindOfClass:[NNSlider class]]) {
            dial.value = 0;
            [dial animateUpdateValue:dial.value];
        }
    }
    [self updateSettingsUI];
    [self updateFxSettingsUI];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL edit = YES;
    if ((int)tableView.tag == 0) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        if ([cell.textLabel.text isKindOfClass:[NSString class]] && [cell.textLabel.text isEqualToString:@"_Defaults"]) {
//            edit = NO;
//        }
    } else {
        edit = NO;
    }


    return edit;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        deleteIndex = indexPath;
        
        UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(tapCloseTableView:) withColor:menuBGColor withBlurAmount:0];
        [KDAnimations animateViewGrowAndShow:view then:nil];

        NSString *title = [[savedSettings objectAtIndex:indexPath.row] lastObject];
        
        float y = sh - (sh / 3);
        
        UILabel *yes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [yes setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
        [yes setAttributedText:[KDHelpers underlinedString:@"Yes"]];
        [yes setTextAlignment:NSTextAlignmentCenter];
        [yes setCenter:CGPointMake(sw/3, y)];
        [yes setTag:1];
        [yes setUserInteractionEnabled:YES];
        
        UILabel *no = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        [no setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
        [no setAttributedText:[KDHelpers underlinedString:@"No"]];
        [no setTextAlignment:NSTextAlignmentCenter];
        [no setCenter:CGPointMake(sw-(sw/3), y)];
        [no setTag:0];
        [no setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapYes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reallyDelete:)];
        UITapGestureRecognizer *tapNo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reallyDelete:)];
        
        [yes addGestureRecognizer:tapYes];
        [no addGestureRecognizer:tapNo];
        
        [view addSubview:yes];
        [view addSubview:no];
        
        float x = sw / 2;
        y = y - circleSize;
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw, circleSize)];
        [text setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
        [text setText:@"Are you sure?"];
        [text setTextAlignment:NSTextAlignmentCenter];
        [text setCenter:CGPointMake(x, y)];
        [view addSubview:text];
        
        y = y - circleSize - circleSize;
        text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw, circleSize)];
        [text setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
        [text setText:[NSString stringWithFormat:@"%@",title]];
        [text setTextAlignment:NSTextAlignmentCenter];
        [text setCenter:CGPointMake(x, y)];
        [view addSubview:text];
        
        y = y - circleSize;
        text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw, circleSize)];
        [text setFont:[UIFont fontWithName:globalFont size:hamburgerFontSize]];
        [text setText:@"Deleting"];
        [text setTextAlignment:NSTextAlignmentCenter];
        [text setCenter:CGPointMake(x, y)];
        [view addSubview:text];

        [self.view addSubview:view];
    }];

    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openSaveDialogueWithTag:(int)indexPath.row];
        });
    }];
    
    return @[deleteAction,renameAction];
}

- (void)reallyDelete:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view amount:1.05 then:nil];
    if (sender.view.tag > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [savedSettings removeObjectAtIndex:deleteIndex.row];
            [fxSavedSettings removeObjectAtIndex:deleteIndex.row];
            [savedToggleSettings removeObjectAtIndex:deleteIndex.row];
            [tableView deleteRowsAtIndexPaths:@[deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
            [self saveSettings];
            deleteIndex = nil;
        });
    }
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
}

- (void)tapCloseTableView:(UITapGestureRecognizer *)sender {
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
    if (tableView) {
        tableView = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (miniTableView) {
            [miniTableView reloadData];
        }
    });
    //[self resetLoadPageAd];
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma SAVE LOAD

- (void)saveDial:(UIView *)dial value:(float)value {
    int row = ((int)dial.tag % dialTagMod) / 10;
    int dialType = ((int)dial.tag - dialTagMod) % 10;
    
    NSArray *temp = [settings objectAtIndex:row];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
    [arr replaceObjectAtIndex:dialType withObject:[NSString stringWithFormat:@"%.0f",value]];
    [settings replaceObjectAtIndex:row withObject:arr];
}

- (void)saveSettings {
    NSString *path = settingsPath;
    NSString *fxPath = fxSettingsPath;
    NSString *togglePath = toggleSettingsPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *array = [NSArray arrayWithArray:savedSettings];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
        
        [fileManager createFileAtPath:path
                             contents:nil
                           attributes:nil];
        
        [array writeToFile:path atomically:YES];
        
        NSArray *fxArray = [NSArray arrayWithArray:fxSavedSettings];
        if ([fileManager fileExistsAtPath:fxPath]) {
            [fileManager removeItemAtPath:fxPath error:nil];
        }
        
        [fileManager createFileAtPath:fxPath
                             contents:nil
                           attributes:nil];
        
        [fxArray writeToFile:fxPath atomically:YES];
        
        NSArray *togArray = [NSArray arrayWithArray:savedToggleSettings];
        if ([fileManager fileExistsAtPath:togglePath]) {
            [fileManager removeItemAtPath:togglePath error:nil];
        }
        
        [fileManager createFileAtPath:togglePath
                             contents:nil
                           attributes:nil];
        
        [togArray writeToFile:togglePath atomically:YES];
    });
}

- (void)loadSettings {
    NSString *path  = settingsPath;
    NSString *fxPath  = fxSettingsPath;
    NSString *togglePath = toggleSettingsPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array;
    NSArray *fxArray;
    NSArray *togArray;
    
    if ([fileManager fileExistsAtPath:path]) {
        array = [[NSArray alloc] initWithContentsOfFile:path];
        savedSettings = [NSMutableArray arrayWithArray:array];
    } else {
        for (NSArray* arr in defaultsArray) {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for (int i = 0; i < numHeight; i++) {
                [temp addObject:[arr objectAtIndex:1]];
            }
            [temp addObject:[arr firstObject]];
            [savedSettings addObject:temp];
        }
    }

    if ([fileManager fileExistsAtPath:fxPath]) {
        fxArray = [[NSArray alloc] initWithContentsOfFile:fxPath];
        fxSavedSettings = [NSMutableArray arrayWithArray:fxArray];
    } else {
        for (NSArray* arr in defaultsArray) {
            [fxSavedSettings addObject:[arr objectAtIndex:2]];
        }
    }
    
    if ([fileManager fileExistsAtPath:togglePath]) {
        togArray = [[NSArray alloc] initWithContentsOfFile:togglePath];
        savedToggleSettings = [NSMutableArray arrayWithArray:togArray];
    } else {
        for (NSArray* arr in defaultsArray) {
            [savedToggleSettings addObject:[arr objectAtIndex:3]];
        }
    }
}

- (void)saveLastToggleSettings {
    NSString *path = lastToggleSettingsPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [NSArray arrayWithArray:toggleArray];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
        
        [fileManager createFileAtPath:path
                             contents:nil
                           attributes:nil];
        
        [array writeToFile:path atomically:YES];
    });
}

- (void)saveLastSettings {
    NSString *path = lastSettingsPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [NSArray arrayWithArray:settings];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
        
        [fileManager createFileAtPath:path
                             contents:nil
                           attributes:nil];
        
        [array writeToFile:path atomically:YES];
    });
}
- (void)saveLastFxSettings {
    NSString *fxPath = lastFxSettingsPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *fxArray = [NSArray arrayWithArray:fxSettings];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fxPath]) {
            [fileManager removeItemAtPath:fxPath error:nil];
        }
        
        [fileManager createFileAtPath:fxPath
                             contents:nil
                           attributes:nil];
        
        [fxArray writeToFile:fxPath atomically:YES];
    });
}

- (void)loadLastSettings {
    NSString *path  = lastSettingsPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array;
    
    if ([fileManager fileExistsAtPath:path]) {
        array = [[NSArray alloc] initWithContentsOfFile:path];
        settings = [NSMutableArray arrayWithArray:array];
    }
}

- (void)loadLastFxSettings {
    NSString *fxPath  = lastFxSettingsPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fxArray;
    
    if ([fileManager fileExistsAtPath:fxPath]) {
        fxArray = [[NSArray alloc] initWithContentsOfFile:fxPath];
        fxSettings = [NSMutableArray arrayWithArray:fxArray];
    }
}

- (void)loadLastToggleSettings {
    NSString *path  = lastToggleSettingsPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array;
    
    if ([fileManager fileExistsAtPath:path]) {
        array = [[NSArray alloc] initWithContentsOfFile:path];
        toggleArray = [NSMutableArray arrayWithArray:array];
    }
}

- (void)updateSettingsUI {
    NSMutableArray *tempSettings = [[NSMutableArray alloc] init];
    for (NSArray *arr in settings) {
        for (NSString* str in arr) {
            [tempSettings addObject:str];
        }
    }
    for (kdToggle *toggle in toggleContainer.subviews) {
        if ([toggle isKindOfClass:[kdToggle class]]) {
            BOOL val = [[toggleArray objectAtIndex:toggle.uid] boolValue];
            [toggle setOn:val];
            [self handleToggle:toggle];
        }
    }
    for (int i = 0; i < dialArray.count; i++) {
        NSArray *arr = [NSArray arrayWithArray:[[defaultsArray objectAtIndex:1] objectAtIndex:1]];
        int modI = i % arr.count;
        NSString *str = [tempSettings objectAtIndex:i];
        if (modI == 0) {
            UILabel *dial = [dialArray objectAtIndex:i];
            dial.text = str;
        } else {
            NNSlider *dial = [dialArray objectAtIndex:i];
            float value = [str floatValue] / 100;
            dial.value = value;
            [dial animateUpdateValue:value];
        }
    }
}

- (void)updateFxSettingsUI {
    NSMutableArray *tempSettings = [NSMutableArray arrayWithArray:fxSettings];
    
    for (int i = 0; i < bigMenuArray.count-1; i++) {
        NSString *str = [tempSettings objectAtIndex:i];
        NNSlider *dial = [bigMenuArray objectAtIndex:i];
        float value = [str floatValue];
        dial.value = value;
        [dial animateUpdateValue:value];
    }
    
    for (NNSlider* slider in subMenu.subviews) {
        NSString *str = [tempSettings objectAtIndex:8];
        float value = [str floatValue];
        slider.value = value;
        [slider animateUpdateValue:value];
    }
    
    for (NNSlider* slider in sideMenu.subviews) {
        NSString *str = [tempSettings objectAtIndex:7];
        float value = [str floatValue];
        slider.value = value;
        [slider animateUpdateValue:value];
        
        [self handleGlissValues:slider.value];
    }
    
    lowPitch = [[tempSettings objectAtIndex:7] floatValue] * 20;
    [pd sendFloat:[[tempSettings objectAtIndex:8] floatValue] toReceiver:@"masterVol"];
}

- (void)handleGlissValues:(float)value {
    float value1 = (value * 12000) + 2000;
    float value2 = (value * 6000) + 4000;
    float value3 = (value * 2000) + 10000;
    [pd sendFloat:value1 toReceiver:@"glissValue1"];
    [pd sendFloat:value2 toReceiver:@"glissValue2"];
    [pd sendFloat:value3 toReceiver:@"glissValue3"];
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma PD Receives

- (void)receive:(NSDictionary *)message {
    //NSLog(@"%@",message);
    if ([[message objectForKey:@"receive"] isEqualToString:@"0.animtime"]) {
        [topMenuTimers replaceObjectAtIndex:0 withObject:[message objectForKey:@"float"]];
    }
    if ([[message objectForKey:@"receive"] isEqualToString:@"1.animtime"]) {
        [topMenuTimers replaceObjectAtIndex:1 withObject:[message objectForKey:@"float"]];
    }
    if ([[message objectForKey:@"receive"] isEqualToString:@"2.animtime"]) {
        [topMenuTimers replaceObjectAtIndex:2 withObject:[message objectForKey:@"float"]];
    }
    if ([[message objectForKey:@"receive"] isEqualToString:@"3.animtime"]) {
        [topMenuTimers replaceObjectAtIndex:3 withObject:[message objectForKey:@"float"]];
    }
}

// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // // // // // // // //

#pragma App Tour

- (void)openHelp:(UITapGestureRecognizer*)sender {
    
    [KDAnimations jiggle:sender.view amount:1.15 then:nil];
    
    UIView *helpView = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(closeHelp) withColor:menuBGColor withBlurAmount:0];
    UIView *textContainer = [self makeTextContainer];
    [helpView addSubview:textContainer];
    
    float maxLabelWidth = textContainer.bounds.size.width;
    float helpFontSize = fontSize * 1.5;
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            helpFontSize = fontSize * 2.5;
        } else {
            helpFontSize = fontSize * 2;
        }
    }
    float height = helpFontSize * 1.1;
    float yPad = self.view.frame.size.height/7.5;
    float xPad = 30;
    UIFont *helpFont = [UIFont fontWithName:globalFont size:helpFontSize];
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    NSString *arrowText = @"→";
    NSString *titleString = @"Help Topics";
    NSArray *arr = @[@"Sound Controls",
                       @"Pad Settings",
                       @"Global FX",
                       @"Record Banks",
                       @"Save and Load",];
    NSMutableArray *textArray = [NSMutableArray arrayWithArray:arr];
    if (hasLock) {
        [textArray addObject:@"Unlock Full App"];
    }
    
    //title
    UILabel *title = [self makeHelpLabelFor:textContainer withText:titleString fontSize:fontSize*1.5];
    //UILabel *title = [self makeHelpTitleFor:textContainer withText:titleString];
    [labelArray addObject:title];
    [textContainer addSubview:title];
    
    //sub text
    for (int i = 0; i < textArray.count; i++) {
        
        float width = maxLabelWidth - (xPad * 2);
        float pad = xPad;
        if (i < 1) {
            pad = yPad;
        }
        
        UIView *subTextContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [KDHelpers appendView:subTextContainer toView:[labelArray lastObject] withMarginY:pad andIndentX:xPad];
        subTextContainer.userInteractionEnabled = YES;
        subTextContainer.tag = i;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHelpContentMenu:)];
        [subTextContainer addGestureRecognizer:tap];
        
        UILabel *text = [KDHelpers makeLabelWithWidth:width andHeight:height];
        text.font = helpFont;
        text.text = [textArray objectAtIndex:i];
        
        UILabel *arrow = [KDHelpers makeLabelWithWidth:width andHeight:height];
        arrow.font = helpFont;
        arrow.textAlignment = NSTextAlignmentRight;
        arrow.text = arrowText;

        [subTextContainer addSubview:text];
        [subTextContainer addSubview:arrow];
        [labelArray addObject:subTextContainer];
        [textContainer addSubview:subTextContainer];
        
    }
    
    UILabel *footer = [KDHelpers makeLabelWithWidth:maxLabelWidth andHeight:height];
    [KDHelpers setOriginX:xPad andY:self.view.bounds.size.height-footer.frame.size.height-xPad+(helpFontSize*.2) forView:footer];
    footer.font = [UIFont fontWithName:globalFont size:fontSize];
    footer.text = @"superofficial@notnatural.co";
    [helpView addSubview:footer];
    
    [KDAnimations animateViewGrowAndShow:helpView then:nil];
    
    [helpViews addObject:helpView];
    [self.view addSubview:helpView];
}

- (void)tapHelpContentMenu:(UITapGestureRecognizer*)sender {
    switch ((int)sender.view.tag) {
        case 0:
            [self soundControlsPage];
            break;
        case 1:
            [self padSettingsPage];
            break;
        case 2:
            [self globalFxPage];
            break;
        case 3:
            [self recordBanksPage];
            break;
        case 4:
            [self saveAndLoadPage];
            break;
        case 5:
            [self openPurchasePage:YES];
            break;
            
        default:
            break;
    }
    
    [KDAnimations jiggle:sender.view amount:1.05 then:nil];
}

- (void)openPurchasePage:(BOOL)fromHelp {
    UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(closeHelp) withColor:menuBGColor withBlurAmount:0];
    
    if (fromHelp) {
        [KDHelpers setOriginX:sw forView:view];
        
        float closeSize = 50;
        float marginSize = 20;
        UILabel *back = [[UILabel alloc] initWithFrame:CGRectMake(marginSize, marginSize, closeSize, closeSize)];
        float helpFontSize = fontSize * 1.5;
        if ([KDHelpers isIpad]) {
            if ([KDHelpers isIpadPro_1366]) {
                helpFontSize = fontSize * 2.5;
            } else {
                helpFontSize = fontSize * 2;
            }
        }
        [back setFont:[UIFont fontWithName:globalFont size:helpFontSize]];
        [back setUserInteractionEnabled:YES];
        [back setText:@"<"];
        [back setTextAlignment:NSTextAlignmentCenter];
        
        UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackHelp)];
        [back addGestureRecognizer:tapBack];
        
        [view addSubview:back];
    }
    [helpViews addObject:view];
    
    UIView *textContainer = [self makeTextContainer];
    
    float maxLabelWidth = textContainer.bounds.size.width;
    float helpFontSize = fontSize * 1.5;
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            helpFontSize = fontSize * 2.5;
        } else {
            helpFontSize = fontSize * 2;
        }
    }
    UIFont *helpFont = [UIFont fontWithName:globalFont size:helpFontSize];
    
    float yPad = 10;
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    //////////
    //subviews
    
    float staticContentHeight = textContainer.bounds.size.height/6;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlock.pdf"]];
    icon.frame = CGRectMake(0, 0, maxLabelWidth, staticContentHeight);
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.alpha = .7;
    [labelArray addObject:icon];
    
    UILabel *title = [self makeHelpLabelFor:textContainer withText:@"Unlock All Features" fontSize:fontSize*1.5];
    //UILabel *title = [self makeHelpTitleFor:textContainer withText:@"Unlock All Features"];
    title.textAlignment = NSTextAlignmentCenter;
    [KDHelpers appendView:title toView:icon withMarginY:yPad*2 andIndentX:0];
    [labelArray addObject:title];
    
    UILabel *subtitle = [self makeHelpLabelFor:textContainer withText:removeAdsProductPrice fontSize:fontSize*1.25];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [KDHelpers appendView:subtitle toView:title withMarginY:yPad andIndentX:0];
    [labelArray addObject:subtitle];
    
    UIView *inAppButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxLabelWidth, staticContentHeight)];
    UILabel *purchase = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inAppButtons.bounds.size.width/2, inAppButtons.bounds.size.height)];
    purchase.textAlignment = NSTextAlignmentCenter;
    purchase.userInteractionEnabled = YES;
    purchase.font = helpFont;
    purchase.attributedText = [KDHelpers underlinedString:@"Purchase"];
    UILabel *restore = [[UILabel alloc] initWithFrame:CGRectMake(inAppButtons.bounds.size.width/2, 0, inAppButtons.bounds.size.width/2, inAppButtons.bounds.size.height)];
    restore.textAlignment = NSTextAlignmentCenter;
    restore.userInteractionEnabled = YES;
    restore.font = helpFont;
    restore.attributedText = [KDHelpers underlinedString:@"Restore"];
    [inAppButtons addSubview:purchase];
    [inAppButtons addSubview:restore];
    [KDHelpers appendView:inAppButtons toView:subtitle withMarginY:yPad*2 andIndentX:0];
    [labelArray addObject:inAppButtons];
    
    UITapGestureRecognizer *tapPurchase = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPurchase:)];
    UITapGestureRecognizer *tapRestore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRestore:)];
    [purchase addGestureRecognizer:tapPurchase];
    [restore addGestureRecognizer:tapRestore];
    
    float usedHeight = inAppButtons.frame.origin.y + inAppButtons.frame.size.height + (yPad*2);
    float remHeight = textContainer.bounds.size.height - usedHeight;
    UIView *remContainer = [[UIView alloc] initWithFrame:CGRectMake(0, usedHeight, maxLabelWidth, remHeight)];
    
    KDScrollView *sv = [KDScrollView initWithID:0 andFrame:remContainer.bounds];
    
    /* @[text or image, label or header, string] */
    NSArray *content = @[@[@0, @0, @"♡"],
                         @[@0, @0, @"· unlock global fx ·"],
                         @[@0, @0, @"· double loop banks ·"],
                         @[@0, @0, @"· quick access presets ·"],
                         @[@0, @0, @"· accelerometer ·"],
                         @[@0, @0, @"· pressure sensitivity ·"],
                         @[@0, @0, @"( on force touch devices )"]
                         ];
    
    NSMutableArray *svContent = [[NSMutableArray alloc] init];
    for (NSArray *arr in content) {
        int type = [[arr objectAtIndex:0] intValue];
        NSString *str = [arr objectAtIndex:2];
        if (type == 0) {
            UILabel *label = [self makeHelpLabelFor:sv withText:str fontSize:fontSize];
            if ([KDHelpers isIpad]) {
                if ([KDHelpers isIpadPro_1366]) {
                    [KDHelpers setLabelHeightFor:label fontSize:fontSize*2.25 fontName:globalFont withText:str];
                } else {
                    [KDHelpers setLabelHeightFor:label fontSize:fontSize*1.25 fontName:globalFont withText:str];
                }
            }
            label.textAlignment = NSTextAlignmentCenter;

            [svContent addObject:label];
        }
    }
    
    if (![KDHelpers isIpad]) {
        yPad = yPad * .4;
        [sv appendSpacerWithSize:yPad];
    } else {
        [sv appendSpacerWithSize:yPad*2];
    }
    
    for (UIView *subview in svContent) {
        [sv appendView:subview];
        [sv appendSpacerWithSize:yPad];
        subview.center = CGPointMake(sv.bounds.size.width/2, subview.center.y);
    }

    [remContainer addSubview:sv];
    [KDHelpers addGradientMaskToView:remContainer];
    [labelArray addObject:remContainer];

    for (UIView *subview in labelArray) {
        subview.center = CGPointMake(textContainer.bounds.size.width/2, subview.center.y);
        [textContainer addSubview:subview];
    }
    
    [view addSubview:textContainer];
    [self.view addSubview:view];
    
    if (fromHelp) {
        [KDAnimations slide:view amountX:-sw amountY:0 duration:.3 then:nil];
    } else {
        [KDAnimations animateViewGrowAndShow:view then:nil];
    }
}

/*
//@[text or image,
// label or title or header (or spacer/no spacer if image) (-1 for centered text),
// string]
NSArray *content = @[@[@0, @2, @"Header"],
                     @[@0, @1, @"Title"],
                     @[@0, @0, @"text"]
                     ];
[self makeHelpNavigationPageWithContent:content];
*/

- (void)soundControlsPage {
    NSString *force = @"(Sorry, your iOS device is not force touch capable.)";
    if ([self checkForForceTouch]) {
        force = @"(Congrats! Your device can respond to pressure sensitivity!)";
    }
    NSArray *content = @[@[@0, @2, @"Sound Controls"],
                         @[@0, @0, @"Minim shares similarities with some synthesizers, but there are plenty of differences.\n\nFor one, it's microtonal, which means the pitches won't always match what you might expect from a regular piano.\n\nMinim also uses a custom synthesis engine that's a little more unique than most standard synths.\n\nThis opens up tons of interesting possibilities for making different sounds!\n\nThe basics are pretty easy, but you'll want to play around with how various settings and actions interact with each other!"],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Pads"],
                         @[@1, @1, @"sound1.png"],
                         @[@0, @0, @"Minim is a four-voice polyphonic instrument, which means you can have up to four 'notes' playing at a time. It's essentially played by tapping and pressing on the pads, but there's several interactions you should know about:"],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Tap"],
                         @[@0, @0, @"Tap on a pad to play sound. The body setting for that row will affect how long the attack and release will be."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Press and Hold"],
                         @[@0, @0, @"If you hold a pad, the sound will sustain. It may or may not sustain indefinitely depending on the other settings, but it will sustain until you release the pad."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Aftertouch"],
                         @[@0, @0, @"Each sound has an adjustable filter attached to it. While holding down on a pad, just move your finger up, down, left, and right to control the filter."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Pressure Sensitivity"],
                         @[@0, @0, @"[full version only]"],
                         @[@0, @0, @"Adjusting how hard you are pressing on a pad will affect the sound."],
                         @[@0, @0, @" "],
                         @[@0, @1, @"Warning!!!"],
                         @[@0, @0, @"Some iOS devices do not support force touch capabilities!"],
                         @[@0, @0, @"If you device does not have force touch, you will not be able to use pressure sensitivity even if you unlock the full version! For your convenience, I've run a little check and will let you know if your device has proper support..."],
                         @[@0, @0, @" "],
                         @[@0, @-1, force],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Sliders"],
                         @[@1, @2, @"sound2.png"],
                         
                         @[@0, @1, @"Fade Slider"],
                         @[@0, @0, @"This controls the global volume for the sound pads. Use it as just a volume controller, or use it in real time to control dynamics or fades."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Pitch Slider"],
                         @[@0, @0, @"Basically, this slider changes the lowest possible pitch for the pads. But it can also be used in real time to create some crazy sounds."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Mini Menu"],
                         @[@0, @0, @"[full version only]"],
                         @[@1, @1, @"sound3.png"],
                         @[@1, @2, @"sound4.png"],
                         @[@0, @0, @"The mini menu gives you convenient access to your saved settings. It doesn't allow you to reorder or edit anything, but tap on a selection to load the settings. It really shines when used in conjunction with the recording buffers! Quickly change back and forth between sounds in order to build musical textures."],
                         @[@0, @0, @" "],
                         
                         
                         ];
    [self makeHelpNavigationPageWithContent:content];
}
- (void)padSettingsPage {
    NSArray *content = @[@[@0, @2, @"Pad Settings"],
                         @[@0, @-1, @"(tap the double arrow to open)"],
                         @[@1, @1, @"pad1.png"],
                         
                         @[@0, @1, @"Individual Dials"],
                         @[@1, @0, @"pad2.png"],
                         @[@0, @0, @"Every row corresponds to a row of pads. Just touch and drag a dial up or down. (tap on the 'type' column instead of dragging)"],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Global Dials"],
                         @[@1, @0, @"pad3.png"],
                         @[@0, @0, @"You can also use the column headers in order to synchronize all of the rows at the same time. They work just like dials, so tap or drag."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Type"],
                         @[@0, @0, @"There are 4 base types of sounds. You'll have to play around with them to hear how they interact with the other settings!"],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Body"],
                         @[@0, @0, @"This is a rough approximation of how resonant the sound can be."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Trem"],
                         @[@0, @0, @"Trem is short for tremelo. Increase this setting to add extra attacks to a sound."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"FX"],
                         @[@0, @0, @"This is a global wet/dry setting for he effects in the Global FX page. If it's set to zero, that particular row will not be affected by global effects."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Amp"],
                         @[@0, @0, @"This is the amplitude of the sound. While it will generally affect how loud the sound is, increase it enough to introduce clipping distortion and create interesting sounds!"],
                         @[@0, @0, @" "]
                         ];

    [self makeHelpNavigationPageWithContent:content];
}
- (void)globalFxPage {
    NSArray *content = @[@[@0, @2, @"Global Effects"],
                         @[@0, @-1, @"(tap the hamburger to open)"],
                         @[@1, @1, @"gfx1.png"],
                         @[@0, @0, @"The global effects will change any sound for any pad based on the individual row FX settings."],
                         @[@1, @2, @"gfx2.png"],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Tune"],
                         @[@0, @0, @"This adjusts how the pads are tuned. Increasing this setting will increase the frequency difference between consecutive pads. How this setting affects the sound can be drastically altered by the other settings."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Reverb Amount"],
                         @[@0, @0, @"This increases the reverb time. The minimum turns reverb off altogether, and the maximum will go crazy and make a lot of noise. You have been warned."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Reverb Mix"],
                         @[@0, @0, @"This is the wet/dry mix for the reverb. It won't do anything by itself, but will adjust the mix if reverb amount is set higher than the minimum."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Delay"],
                         @[@0, @0, @"This delay is global, as opposed to the tremelo setting for individual rows. It compounds with that setting. Increasing this setting decreases the time between successive attacks."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Distortion"],
                         @[@0, @0, @"Distortion, or overdrive. While most of the other settings go to ten, this one goes to eleven. Haha you know that's funny even if it's not."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Distortion Delay"],
                         @[@0, @0, @"This is a seperate delay that only affects the distorted sound."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Crush"],
                         @[@0, @0, @"This affects the sampling resolution of the sound. Increasing it will lower the fidelity."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Toggles"],
                         @[@1, @1, @"gfx3.png"],
                         
                         @[@0, @1, @"Accelerometer"],
                         @[@0, @0, @"This turns on the accelerometer. If it's on, you can wiggle your device to add vibrato to the sound."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Tuning"],
                         @[@0, @0, @"This toggles between a pseudo-equal-tempered tuning system and a natural tuning system. It will affect every pad, and also affects how the 'Tune' slider setting works."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Help Button"],
                         @[@0, @0, @"This button is how you get to this page. It's the only way to get to this page if you have unlocked the full version of Minim!"],
                         @[@0, @0, @" "]
                         ];
    [self makeHelpNavigationPageWithContent:content];
}
- (void)recordBanksPage {
    NSArray *content = @[@[@0, @2, @"Record Banks"],
                         @[@1, @1, @"record1.png"],
                         @[@0, @0, @"Each of these icons represents a record buffer. When activated, anything you play will record to that buffer. An X means it's an empty buffer, and an O means it has something already recorded."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Record"],
                         @[@0, @0, @"Tap on an empty buffer to start recording. It'll start animating to let you know it's active. Tap again to stop recording."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Play / Stop"],
                         @[@0, @0, @"Tap on a non-empty buffer to start playback. It'll start animating to let you know it's playing. Tap at any time to stop playback. There's no pause function, so it'll always start from the beginning of the recording."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Reset"],
                         @[@0, @0, @"Press and hold a non-empty buffer for a second, and it will delete and reset."],
                         @[@0, @0, @" "]
                         ];
    [self makeHelpNavigationPageWithContent:content];
}
- (void)saveAndLoadPage {
    NSArray *content = @[@[@0, @2, @"Save and Load"],
                         @[@1, @1, @"sal1.png"],
                         @[@0, @0, @"The Save and Load buttons are at the top of the pad settings page. These will let you store and recover your current settings."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Save"],
                         @[@0, @0, @"Tap save, and name your settings however you'd like. Once you hit 'Done', your current settings will available in the load page. Tap the X at the top of the page to cancel."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Load"],
                         @[@0, @0, @"The load page contains a list of all of your saved settings. There's some default examples in there to begin with. Just tap on a selection to load the settings."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Reorder"],
                         @[@0, @0, @"Press and hold on a selection for a second to reorder your list. Just drag it to a new position once it lifts off the page."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Other Edit Actions"],
                         @[@1, @1, @"sal2.png"],
                         @[@0, @0, @"Swipe left on a selection to see more edit options."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Rename"],
                         @[@0, @0, @"Rename will open a page similar to the 'Save' page, but it will not affect the actual settings once you hit done. It just updates the name of selection."],
                         @[@0, @0, @" "],
                         
                         @[@0, @1, @"Delete"],
                         @[@0, @0, @"Delete will... delete the selection. Don't worry. You'll be prompted to ensure you really want to delete, so it's hard to delete by accident."],
                         @[@0, @0, @" "]
                         ];
    [self makeHelpNavigationPageWithContent:content];
}

- (UIView*)makeTextContainer {
    float yPad = self.view.frame.size.height/7.5;
    float xPad = 30;
    float w = self.view.bounds.size.width-(xPad*2);
    float h = self.view.bounds.size.height-yPad-xPad;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(xPad, yPad, w, h)];
    return view;
}

- (UILabel*)makeHelpLabelFor:(UIView*)view withText:(NSString*)text fontSize:(float)size {
    float width = view.bounds.size.width;
    UILabel *label = [KDHelpers makeLabelWithWidth:width andAlignment:NSTextAlignmentCenter];
    [KDHelpers setLabelHeightFor:label fontSize:size fontName:nil withText:text];
    [KDHelpers setWidth:width forView:label];
    //NSLog(@"%f",label.frame.size.width);
//    UILabel *label = [KDHelpers makeLabelWithWidth:width andFontSize:size andAlignment:NSTextAlignmentCenter];
//    [KDHelpers setLabelHeightFor:label fontSize:size fontName:nil withText:text];
    
    return label;
}
- (void)makeHelpNavigationPageWithContent:(NSArray*)content {
    UIView *view = [KDHelpers popupWithClose:YES withCloseTarget:self forCloseSelector:@selector(closeHelp) withColor:menuBGColor withBlurAmount:0];
    [KDHelpers setOriginX:sw forView:view];
    
    float closeSize = 50;
    float marginSize = 20;
    UILabel *back = [[UILabel alloc] initWithFrame:CGRectMake(marginSize, marginSize, closeSize, closeSize)];
    float helpFontSize = fontSize * 1.5;
    if ([KDHelpers isIpad]) {
        if ([KDHelpers isIpadPro_1366]) {
            helpFontSize = fontSize * 2.5;
        } else {
            helpFontSize = fontSize * 2;
        }
    }
    [back setFont:[UIFont fontWithName:globalFont size:helpFontSize]];
    [back setUserInteractionEnabled:YES];
    [back setText:@"<"];
    [back setTextAlignment:NSTextAlignmentCenter];
    
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackHelp)];
    [back addGestureRecognizer:tapBack];
    
    [view addSubview:back];

    UIView *textContainer = [self makeTextContainer];
    
    KDScrollView *sv = [KDScrollView initWithID:0 andFrame:textContainer.bounds];
    [textContainer addSubview:sv];
    [KDHelpers addGradientMaskToView:textContainer];
    
    NSMutableArray *svContent = [[NSMutableArray alloc] init];
    
    float yPad = 10;
    for (NSArray *arr in content) {
        int type = [[arr objectAtIndex:0] intValue];
        int size = [[arr objectAtIndex:1] intValue];
        NSString *str = [arr objectAtIndex:2];
        if (type == 0) {
            float helpFontSize = 1;
            switch (size) {
                case 1:
                    helpFontSize = 1.5;
                    if ([KDHelpers isIpad]) {
                        if ([KDHelpers isIpadPro_1366]) {
                            helpFontSize = 2.5;
                        } else {
                            helpFontSize = 2;
                        }
                    }
                    break;
                case 2:
                    helpFontSize = 1.75;
                    if ([KDHelpers isIpad]) {
                        if ([KDHelpers isIpadPro_1366]) {
                            helpFontSize = 2.75;
                        } else {
                            helpFontSize = 2.25;
                        }
                    }
                    break;
                    
                default:
                    break;
            }
            UILabel *label = [self makeHelpLabelFor:sv withText:str fontSize:fontSize*helpFontSize];
            label.textAlignment = NSTextAlignmentLeft;
            if (size < 0) {
                label.textAlignment = NSTextAlignmentCenter;
            }
            [svContent addObject:label];
            if (size > 1) {
                UILabel *spacer = [self makeHelpLabelFor:sv withText:@" " fontSize:fontSize];
                [svContent addObject:spacer];
            }
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            float width = sv.bounds.size.width;
            imageView.frame = CGRectMake(0, 0, width, sv.bounds.size.height/4);
            if (size > 1) {
                imageView.frame = CGRectMake(0, 0, width, sv.bounds.size.height*.66);
            }
            [svContent addObject:imageView];
            if (size > 0) {
                UILabel *spacer = [self makeHelpLabelFor:sv withText:@" " fontSize:fontSize];
                [svContent addObject:spacer];
            }

        }
    }
    
    [sv appendSpacerWithSize:yPad*3];
    for (UIView *subview in svContent) {
        [sv appendView:subview];
        [sv appendSpacerWithSize:yPad];
    }
    
    [view addSubview:textContainer];
    
    [self.view addSubview:view];
    [helpViews addObject:view];
    [KDAnimations slide:view amountX:-sw amountY:0 duration:.3 then:nil];
}

- (void)closeHelp {
    [self hideSpinner];
    
    for (UIView *view in helpViews) {
        [KDAnimations animateViewShrinkAndWink:view andRemoveFromSuperview:YES then:nil];
    }
    [helpViews removeAllObjects];
}

- (void)goBackHelp {
    UIView *view = [helpViews lastObject];
    [KDAnimations slide:view amountX:-sw amountY:0 duration:.3 then:nil];
    [helpViews removeLastObject];
    [view removeFromSuperview];
}

- (void)tapPurchase:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view amount:1.1 then:nil];
    if (!spinner) {
        [self purchase];
    }
}
- (void)tapRestore:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view amount:1.1 then:nil];
    if (!spinner) {
        [self restore];
    }
}


- (void)purchase {
    NSLog(@"User requests to remove ads");

    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");

        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product

        [self showSpinner];
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:removeAdsProductID]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls

        [warningLabel flashWithString:@"Oops! Please check your device settings to enable purchases!"];
    }
}
- (void)restore {
    [self showSpinner];
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");

        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self hideSpinner];
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");

            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            
            NSString *productID = transaction.payment.productIdentifier;
            if ([productID isEqualToString:removeAdsProductID]) {
                [warningLabel flashWithString:@"Purchases restored!"];
                if (hasLock) {
                    [self doRemoveAds];
                }
            }
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    // test error.code, if it equals SKErrorPaymentCancelled it's been cancelled
    
    [self hideSpinner];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                if (hasLock) {
                    [self doRemoveAds];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
//                if (hasLock) {
//                    [self doRemoveAds];
//                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction state -> Cancelled");
                //called when the transaction does not finish
                [self hideSpinner];
                if(transaction.error.code == SKErrorPaymentCancelled){
                    [warningLabel flashWithString:@"Transaction cancelled."];
                    //the user cancelled the payment ;(
                } else {
                    [warningLabel flashWithString:@"Oops! Something went wrong... Please try again!"];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"Transaction state -> Deferred");
                if (hasLock) {
                    [self doRemoveAds];
                }
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)doRemoveAds {
    [self hideSpinner];
    [self handlePurchaseFull];
    [self reload];
}

- (void)showSpinner {
    [self hideSpinner];
    spinner = [[KDActivityIndicator alloc] init];
    [spinner showThen:nil];
    [self.view addSubview:spinner];
}

- (void)hideSpinner {
    if (spinner) {
        [spinner hideThen:^{
            [spinner removeFromSuperview];
            spinner = nil;
        }];
    }
}


@end
