//
//  KEArticleViewController.h
//  Kono
//
//  Created by Kono on 2016/6/20.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEArticleSelectionMenuViewController.h"
#import "NESandwichView.h"
//#import <AFNetworkReachabilityManager.h>
#import <WYPopoverController.h>

typedef enum KEPDFPreloadStatusCode : NSUInteger{
    
    KEPDFPreloadStatusCodeStop = 0,
    KEPDFPreloadStatusCodeRunning = 1,
    KEPDFPreloadStatusCodeLimit = 2,
    KEPDFPreloadStatusCodeDone = 3,
    KEPDFPreloadStatusCodeUnknown = 4
    
}KEPDFPreloadStatusCode;

typedef enum KEArticleReadMode : NSInteger{
    
    KEArticleReadModeFitReadingOnly = 0,
    KEArticleReadModePDFOnly = 1,
    KEArticleReadModeBoth = 2,
    KEArticleReadModeNone = 3
    
} KEArticleReadMode;


@interface KEArticleViewController : UIViewController <UIGestureRecognizerDelegate, NESandwichViewDatasource, NESandwichViewDelegate, UIAlertViewDelegate, WYPopoverControllerDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic)           KCBook              *bookItem;

@property (nonatomic, strong)   NSMutableSet        *articleLockedSet;

@property (nonatomic)           NSInteger           currentMagazineIndex;

@property (nonatomic, strong)   NSString            *currentArticleID;

@property (nonatomic)           BOOL                isArticleOOBEDone;

@property (nonatomic)           BOOL                isFlipAnimationDone;

@property (nonatomic)           BOOL                isNavigationBarShow;

@property (nonatomic)           BOOL                isNeedShowFlipIndicator;

@property (nonatomic, strong)   NSArray            *previousTrackingArticleArray;

@property (nonatomic, strong)   WYPopoverController *popoverController;

@property (weak, nonatomic) IBOutlet UIImageView *leftFlipIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *rightFlipIndicator;

@property (weak, nonatomic) IBOutlet UIButton *fitReadingBtn;

@property (weak, nonatomic) IBOutlet UIButton *translationBtn;

@property (weak, nonatomic) IBOutlet UIButton *tocBtn;

@property (weak, nonatomic) IBOutlet UIView *navigationBorderView;

@property (weak, nonatomic) IBOutlet NESandwichView *articlePDFView;

@property (weak, nonatomic) IBOutlet UIView *navigationView;

@end
