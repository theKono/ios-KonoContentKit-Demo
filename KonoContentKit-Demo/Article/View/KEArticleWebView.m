//
//  KEArticleWebView.m
//  Kono
//
//  Created by Neo on 4/7/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEArticleWebView.h"
#import <Masonry.h>



@implementation KEArticleWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@synthesize articleItem = _articleItem;
//@synthesize mode = _mode;
@synthesize webViewLoadingCompletionBlock = _webViewLoadingCompletionBlock;

- (void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    /* add action to user selection menu
    UIMenuItem *quoteAction = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"share_article_with_quote_str",@"InfoPlist",nil) action:@selector(openShareInterfaceWithQuote)];
    UIMenuItem *konogramAction = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"share_konogram_str",@"InfoPlist",nil) action:@selector(openKonogramInterface)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    menu.menuItems = @[quoteAction, konogramAction ];
    [menu update];
    */
    
    if( self.tapGestureRecognizer == nil ){
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap)];
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)userDidTap{
    if( [self.articleDelegate respondsToSelector:@selector(userDidClickOnContent)]){
        [self.articleDelegate userDidClickOnContent];
    }
}

- (void)dealloc{
    [self removeGestureRecognizer:self.tapGestureRecognizer];
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    [self setDelegate:nil];
    [self removeFromSuperview];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{

    /* lock the context menu */
    if( !self.isContextMenuShown ){
        return NO;
    }
    
    if(action == @selector(openShareInterfaceWithQuote) || action == @selector(openKonogramInterface)){
        return YES;
    }else{
        return NO;
    }
    
}

- (void)openShareInterfaceWithQuote{
    NSString *selection = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    if( ![selection isEqualToString:@""] ){
        [self.articleDelegate openShareInterfaceWithQuoteWithQuote:selection];
    }
    
}

- (void)openKonogramInterface{
    
    NSString *selection = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];

    if( ![selection isEqualToString:@""] ){
        
        [self.articleDelegate openKonogramEditingInterfaceWithQuote:selection];
        
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setIsMessageShown:(BOOL)isMessageShown{
    
    if( isMessageShown ){
        self.textLabel.alpha = 1.0;
    }else{
        self.textLabel.alpha = 0.0;
    }
    
}

- (BOOL)isMessageShown{
    return NO;
}


@end
