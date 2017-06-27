//
//  KEArticleFitReadingViewController.h
//  Kono
//
//  Created by Kono on 2016/7/5.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEArticleToolFontSizeViewController.h"
#import "KEFitReadingViewCell.h"

@interface KEArticleFitReadingViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, KEArticleWebViewDelegate, KEFitReadingArticleCellDelegate, KEArticleToolFontSizeAdjustDelegate>

@property (nonatomic, strong)       KCBookArticle       *articleItem;

@property (nonatomic, strong)       NSString            *targetArticleID;

@property (nonatomic)               NSInteger           currentArticleFontSizeOffset;

@property (nonatomic)               BOOL                isToolBarShow;

@property (nonatomic, strong)       KCBook              *bookItem;

@property (nonatomic, strong)       NSArray             *articlesArray;

@property (nonatomic, strong)       NSString            *articleSource;

@property (nonatomic, strong)       UIViewController    *baseViewController;

@property (nonatomic, copy) void (^webViewLoadCompleteBlock)(void);

@property (weak, nonatomic) IBOutlet UICollectionView *fitReadingView;

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *toolBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

- (void)showNavigationBar:(BOOL)isShow;

@end
