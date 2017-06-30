//
//  KEPageWebView.m
//  Kono
//
//  Created by Neo on 12/24/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEPageWebView.h"


@implementation KEPageWebView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}


- (void)dealloc{
    [self removeGestureRecognizer:self.tapRecognizer];
    [self removeGestureRecognizer:self.doubleTapGestureRecognizer];
    self.pageDelegate = nil;
    NSLog(@"dealloc webview ");

}


- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration{
    self = [super initWithFrame:frame configuration:configuration];
    //[self setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:233.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];

    self.navigationDelegate = self;
    self.UIDelegate = self;
    self.isNeedToResize = NO;
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [self goThroughSubViewFrom:self];
    [self initParameter];
    
    if( self.doubleTapGestureRecognizer == nil ){
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDoubleTap:)];
        self.doubleTapGestureRecognizer.delegate = self;
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
    }
    
    if( self.tapRecognizer == nil ){
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTap:)];
        self.tapRecognizer.delegate = self;
        self.tapRecognizer.numberOfTapsRequired = 1;
        [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
        [self addGestureRecognizer:self.tapRecognizer];
    }

}


- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL withComplete:(void (^)(void))completeBlock withFail:(void (^)(NSError *))failBlock{
    
    self.loadCompletionBlock = completeBlock;
    self.loadFailBlock = failBlock;
    
    return [self loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

# pragma mark - customize webview operate function

- (void)goThroughSubViewFrom:(UIView *)view {
    
    for (UIView *v in [view subviews]){
        
        if (v != view){
            
            [self goThroughSubViewFrom:v];
        }
    }
    for (UIGestureRecognizer *reco in [view gestureRecognizers]){
        
        if ([reco isKindOfClass:[UITapGestureRecognizer class]]){
        
            [view removeGestureRecognizer:reco];
            
        }

    }
    self.doubleTapGestureRecognizer = nil;
    self.tapRecognizer = nil;
}

- (void)initParameter{
    
    self.isNeedToResize = NO;
    
}

- (void)setContentFitScreenSize{
    
    [self.scrollView setZoomScale:1.0];
    self.isNeedToResize = NO;
    
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)userDoubleTap:(UITapGestureRecognizer*)recognizer{

    /* zoom in */
    CGFloat scale = 3.0;
    CGSize screenSize = self.frame.size;

    
    if( self.frame.size.width < self.scrollView.contentSize.width ){

        // WKWebview is embedded double click gesturre, and it would set the content size to its expection,
        // However, it may not be the zoom scale 1, we postpond the zoom out action to the default action complete.
        // [self.scrollView zoomToRect:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height) animated:YES];

        self.isNeedToResize = YES;
        
    }
    else{
        
        CGPoint touchPoint = [recognizer locationInView:self];
        
        CGRect zoomRect = CGRectMake(touchPoint.x-(screenSize.width/scale)/2, touchPoint.y-(screenSize.height/scale)/2, screenSize.width/scale, screenSize.height/scale);
        [self.scrollView zoomToRect:zoomRect animated:YES];
       
        if( [self.pageDelegate respondsToSelector:@selector(userStartOperationOnView)]){
            [self.pageDelegate userStartOperationOnView];
        }
        
    }
    
}


- (void)userTap:(UITapGestureRecognizer*)recognizer{
    
    if( [self.pageDelegate respondsToSelector:@selector(userDidSingleTapOnView:)]){
        [self.pageDelegate userDidSingleTapOnView:self];
    }
    
    return;

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
}

#pragma mark - web scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    
    if( [self.pageDelegate respondsToSelector:@selector(userStartOperationOnView)]){
        [self.pageDelegate userStartOperationOnView];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    if( [self.pageDelegate respondsToSelector:@selector(userDoneOperationOnView)]){
        if( scale <= scrollView.minimumZoomScale ){
            [self.pageDelegate userDoneOperationOnView];
        }
    }
    if( YES == self.isNeedToResize ){
        [self setContentFitScreenSize];
    }
    
}


#pragma mark - webview delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //UIWebView的 -webViewDidStartLoad:
    //NSLog(@"didStartProvisionalNavigation");

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //UIWebView 的 －webViewDidFinishLoad:
    //NSLog(@"didFinishNavigation");
    
    if(self.loadCompletionBlock!=nil && ![webView.URL.absoluteString isEqualToString:@"about:blank"]){
        self.loadCompletionBlock();
        self.loadCompletionBlock = nil;
    }

    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"loading webview fail and we don't handle before!!");
    if( self.loadFailBlock != nil ){
        self.loadFailBlock( error );
        self.loadFailBlock = nil;
    }
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //UIWebView 的- webView:didFailLoadWithError:
    
    //NSLog(@"didFailProvisionalNavigation");

    if( self.loadFailBlock != nil ){
        self.loadFailBlock( error );
    }
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
    
    if( WKNavigationTypeLinkActivated == navigationAction.navigationType ){
        
        if( [self.pageDelegate respondsToSelector:@selector(userClickInViewWithURL:)]){
            [self.pageDelegate userClickInViewWithURL:navigationAction.request.URL];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
    self.cacheKey = @"nil";
    
    
}
@end
