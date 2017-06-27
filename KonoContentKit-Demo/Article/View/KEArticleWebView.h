//
//  KEArticleWebView.h
//  Kono
//
//  Created by Neo on 4/7/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KEArticleWebView;

@protocol KEArticleWebViewDelegate <UIWebViewDelegate>

- (void)userDidClickOnContent;

@optional

- (void)openShareInterfaceWithQuoteWithQuote:(NSString*)quote;

- (void)openKonogramEditingInterfaceWithQuote:(NSString*)quote;

@end



@interface KEArticleWebView : UIWebView<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) KCBookArticle *articleItem;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, copy) void (^webViewLoadingCompletionBlock)(void);

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, weak) id<KEArticleWebViewDelegate> articleDelegate;


@property (nonatomic) BOOL isContextMenuShown;

@property (nonatomic) BOOL isMessageShown;


@end
