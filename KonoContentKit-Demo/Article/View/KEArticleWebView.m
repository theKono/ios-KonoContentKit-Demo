//
//  KEArticleWebView.m
//  Kono
//
//  Created by Neo on 4/7/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEArticleWebView.h"


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

    return NO;
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
