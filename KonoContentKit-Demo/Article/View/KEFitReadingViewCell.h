//
//  KEFitReadingViewCell.h
//  Kono
//
//  Created by Kono on 2016/7/19.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEArticleWebView.h"

@class KEFitReadingViewCell;

@protocol KEFitReadingArticleCellDelegate <NSObject>

- (void)openRelatedArticle:(NSString*)articleID;

- (void)purchaseBtnPressed;

- (void)referralBtnPressed;

- (void)registerBtnPressed;

- (void)adjustFontSizeWithRealTime:(KEFitReadingViewCell *)cell withRealTimeAction:(BOOL)isRealTimeAdjustment;

- (void)articleLoadingComplete:(KCBookArticle *)articleItem;

@end

@interface KEFitReadingViewCell : UICollectionViewCell <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet KEArticleWebView *webView;

@property (nonatomic) BOOL isLoadComplete;

@property (nonatomic, weak) KCBookArticle *articleItem;

@property (nonatomic, weak) KCBook *bookItem;

@property (nonatomic, copy) void (^webViewLoadCompleteBlock)(void);

@property (nonatomic, weak) id <KEFitReadingArticleCellDelegate> delegate;

- (void)loadFitreadingArticleWithComplete:(void(^)(void))completeBlock;

- (void)clearContent;

@end
