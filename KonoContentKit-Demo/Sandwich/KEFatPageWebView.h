//
//  KEFatPageWebView.h
//  Kono
//
//  Created by Kono on 2015/12/15.
//  Copyright © 2015年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KEFatPageWebView;

@protocol KEFatPageWebViewDelegate <NSObject>

@optional

- (void)userDidSingleTapOnFatView:(KEFatPageWebView*)view;

- (BOOL)webView:(KEFatPageWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

- (void)userStartOperationOnView;

- (void)userDoneOperationOnView;

@end


@interface KEFatPageWebView : UIWebView<UIGestureRecognizerDelegate, UIWebViewDelegate ,UIScrollViewDelegate>

@property (nonatomic) NSInteger pageNum;
@property (nonatomic) BOOL isReadyToShow;

@property (nonatomic, strong) id<KEFatPageWebViewDelegate> pageDelegate;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL isZoomed;

@property (nonatomic, strong) UIView *touchPad;

@property (nonatomic, strong) NSString *cacheKey;

@property (nonatomic, copy) void (^loadCompletionBlock)(void);
@property (nonatomic, copy) void (^loadFailBlock)(NSError* error);

- (void)loadRequest:(NSURLRequest *)request withComplete:(void(^)(void))completeBlock withFail:(void(^)(NSError *error))failBlock;

- (void)setContentFitScreenSize;

@end

