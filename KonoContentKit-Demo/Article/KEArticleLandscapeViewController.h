//
//  KEArticleLandscapeViewController.h
//  Kono
//
//  Created by kuokuo on 2016/12/8.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEFatPageWebView.h"
#import "KEPageWebView.h"
#import "UIImageViewAligned.h"

#define HEIGHT_FOR_THUMNAILLIST_CELL 160
#define HEIGHT_FOR_THUMNAILLIST_CELL_IPAD 200
#define HEIGHT_FOR_CORRECT_AREA 56
#define HEIGHT_FOR_CORRECT_AREA_IPAD 58

#define WIDTH_FOR_THUMNAILLIST_CELL 114.0
#define WIDTH_FOR_THUMNAILLIST_CELL_IPAD 141.0

typedef enum KELandscapeFlipAnimationDirection : NSUInteger{
    KELandscapeFlipAnimationDirectionToLeft = 0,
    KELandscapeFlipAnimationDirectionToRight = 1,
    KELandscapeFlipAnimationDirectionNone = 2,
}KELandscapeFlipAnimationDirection;

typedef enum KELandscapePageStatus : NSUInteger{
    KELandscapePageStatusDownloaded = 0,
    KELandscapePageStatusRequesting = 1,
    KELandscapePageStatusUnauthorized = 2,
    KELandscapePageStatusEmpty = 3,
    KELandscapePageStatusUnknown = 4
}KELandscapePageStatus;

typedef enum KELandscapePageDisplayMode : NSUInteger{
    KELandscapePageDisplayModeNone = 0,
    KELandscapePageDisplayModeLeftOnly = 1,
    KELandscapePageDisplayModeRightOnly = 1 << 1,
    KELandscapePageDisplayModeBoth = KELandscapePageDisplayModeLeftOnly | KELandscapePageDisplayModeRightOnly
}KELandscapePageDisplayMode;

typedef enum KELandscapePlacement : NSUInteger{
    KELandscapePlacementISOLeft = 0,
    KELandscapePlacementISORight = 1,
    KELandscapePlacementISO = 2,
    KELandscapePlacementTwoPages = 3

}KELandscapePlacement;


@interface KEArticleLandscapeViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate,UIWebViewDelegate,KEPageWebViewDelegate,KEFatPageWebViewDelegate>

// view related property
@property (nonatomic, strong) UIView *actionBackgroundView;

@property (nonatomic, strong) UICollectionView *thumbnailListView;

@property (weak, nonatomic) IBOutlet UICollectionView *landscapeViewer;

@property (weak, nonatomic) IBOutlet UIImageView *leftFlipIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *rightFlipIndicator;

@property (nonatomic, strong) UIView *panelView;

@property (nonatomic, strong) UIButton *leftCorrectBtn;

@property (nonatomic, strong) UIButton *rightCorrectBtn;


// data source related property
@property (nonatomic, strong) KCBookArticle   *articleItem;

@property (nonatomic, strong) NSMutableSet    *articleLockedSet;

@property (nonatomic, strong) NSArray         *previousTrackingArticleArray;

@property (nonatomic, strong) NSMutableArray  *evenFirstMergePageArray;

@property (nonatomic, strong) NSMutableArray  *oddFirstMergePageArray;

@property (nonatomic, strong) KCBook          *bookItem;

@property (nonatomic, strong) UIViewController *baseViewController;

@property (nonatomic) NSInteger basePageIndex;

@property (nonatomic) NSInteger currentScreenIndex;

@property (nonatomic) BOOL isWebviewInsideButtonActing;

@property (nonatomic) BOOL isEvenPageAsFirstPage;

@property (nonatomic) BOOL hasInitialized;

@property (nonatomic) NSTimeInterval webviewFadeinDelay;

@property (nonatomic) BOOL isNeedToShowFlipIndicator;

@property (nonatomic) UIDeviceOrientation lastOrientation;

@end
