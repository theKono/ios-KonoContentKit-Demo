//
//  NESandwichView.h
//  Kono
//
//  Created by Neo on 11/13/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEPageWebView.h"
#import "KEFatPageWebView.h"

static const int PRELOAD_CELL_COUNT = 1;

@class NESandwichView;

@protocol NESandwichViewDatasource <NSObject>

- (NSString*)thumbnailURLAtIndex:(NSInteger)index;

- (NSString*)htmlFilePathForItemAtIndex:(NSInteger)index isPreload:(BOOL)isPreload;

- (NSInteger)numberOfitems;

@optional
- (CGFloat)downloadPercentageForItemAtIndex:(NSInteger)index;

@end



@protocol NESandwichViewDelegate <NSObject>

@optional
- (void)userSingleTapOnView:(NESandwichView*)view;

- (void)userStartOperationOnView;

- (void)userDoneOperationOnView;

- (void)articleViewStartMoving;

- (void)updateDisplayPage:(NSInteger)currentIdx;

- (void)willDisplayPage:(NSInteger)currentIdx;

- (void)purchaseBtnPressed;

- (void)referralBtnPressed;

- (void)registerBtnPressed;

@end

@interface NESandwichView : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, KEPageWebViewDelegate,KEFatPageWebViewDelegate>

@property (nonatomic, readonly) NSInteger currentIndex;

/* tableview fot displaying pages */
@property (nonatomic, strong) UITableView *tableView;

/* datasource for presenting html pages */
@property (nonatomic, weak) id<NESandwichViewDatasource> dataSource;

/* delegate for actions */
@property (nonatomic, weak) id<NESandwichViewDelegate> delegate;

- (void)showThumbnailImage:(BOOL)needToShowThumbnail withImagePath:(NSString *)imageURL forItemAtIndex:(NSInteger)index;

- (void)cleanView;

- (void)initLayout;

- (void)endDisplay;

- (void)reloadPageAtIndex:(NSInteger)index;

- (void)goBackToTop;

- (void)refreshCacheAggresively;

@end
