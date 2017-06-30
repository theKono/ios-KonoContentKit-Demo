//
//  KEFatPageWebView.m
//  Kono
//
//  Created by Kono on 2015/12/15.
//  Copyright © 2015年 Kono. All rights reserved.
//

#import "KEFatPageWebView.h"

@interface KEFatPageWebView()

@property (nonatomic, strong) NSDate *lastTapTime;
@property (nonatomic) NSInteger tapTime;
@property (nonatomic) CGPoint lastTouchPoint;
@property (nonatomic) CGFloat currentScale;

@end


@implementation KEFatPageWebView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}


- (void)dealloc{
    [self removeGestureRecognizer:self.tapRecognizer];
    [self removeGestureRecognizer:self.doubleTapGestureRecognizer];
    [self removeGestureRecognizer:self.panGestureRecognizer];
    self.pageDelegate = nil;
    NSLog(@"dealloc webview ");
    
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //[self setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:233.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
    self.delegate = self;
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self goThroughSubViewFrom:self];
    
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


- (void)loadRequest:(NSURLRequest *)request withComplete:(void (^)(void))completeBlock withFail:(void (^)(NSError *))failBlock{
    self.loadCompletionBlock = completeBlock;
    self.loadFailBlock = failBlock;
 
    [self loadRequest:request];
}




- (void)panGestureFired:(UIPanGestureRecognizer*)gestureRecognizer{
    
    CGPoint (^mapping)(CGPoint) = ^(CGPoint orign){
        
        CGFloat xRatio = self.frame.size.width / self.touchPad.frame.size.width;
        CGFloat yRatio = self.frame.size.height / self.touchPad.frame.size.height;
        
        return CGPointMake(orign.x*xRatio*3, orign.y*yRatio*3);
        
    };
    
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.touchPad ];
    if( touchPoint.x > -20.0 && touchPoint.y > -20.0 ){
        
        CGPoint newPoint = mapping( touchPoint );
        
        [self.scrollView setContentOffset:newPoint];
        
    }
    
}

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

- (void)setContentFitScreenSize{
    
    [self.scrollView setZoomScale:1.0];
    self.isZoomed = NO;
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (void)zoomWithScale:(CGFloat)scale withTouchPoint:(CGPoint)touchPoint{
    
    CGSize screenSize = self.frame.size;
    
    CGRect zoomRect = CGRectMake(touchPoint.x-(screenSize.width/scale)/2, touchPoint.y-(screenSize.height/scale)/2, screenSize.width/scale, screenSize.height/scale);
    [self.scrollView zoomToRect:zoomRect animated:YES];
    
}

- (void)userDoubleTap:(UITapGestureRecognizer*)recognizer{
    
    /* zoom in */
    CGFloat scale = 3.0;
    CGSize screenSize = self.frame.size;
    //    [self.scrollView setZoomScale:6.0 animated:YES];
    if( self.frame.size.width < self.scrollView.contentSize.width ){
        
        [self.scrollView zoomToRect:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height) animated:YES];
        self.isZoomed = NO;
        if( [self.pageDelegate respondsToSelector:@selector(userDoneOperationOnView)]){
            [self.pageDelegate userDoneOperationOnView];
            
        }
        
    }
    else{
        
        CGPoint touchPoint = [recognizer locationInView:self];
        
        CGRect zoomRect = CGRectMake(touchPoint.x-(screenSize.width/scale)/2, touchPoint.y-(screenSize.height/scale)/2, screenSize.width/scale, screenSize.height/scale);
        [self.scrollView zoomToRect:zoomRect animated:YES];
        self.isZoomed = YES;
        if( [self.pageDelegate respondsToSelector:@selector(userStartOperationOnView)]){
            [self.pageDelegate userStartOperationOnView];
        }
        
    }
    
    self.lastTapTime = [NSDate date];
    self.lastTouchPoint = [recognizer locationInView:self];
    
    self.tapTime += 1;
    
}


- (void)userTap:(UITapGestureRecognizer*)recognizer{
    
    if ([self.pageDelegate respondsToSelector:@selector(userDidSingleTapOnFatView:)]) {
        [self.pageDelegate userDidSingleTapOnFatView:self];
    }
    
    return;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
}

#pragma mark - web scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if( [self.pageDelegate respondsToSelector:@selector(userStartOperationOnView)]){
        [self.pageDelegate userStartOperationOnView];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if( [self.pageDelegate respondsToSelector:@selector(userDoneOperationOnView)]){
        if( scrollView.zoomScale <= scrollView.minimumZoomScale ){
            [self.pageDelegate userDoneOperationOnView];
        }
    }
}



#pragma mark - webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
 
    if( [self.pageDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]){
        return [self.pageDelegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    else{
        return YES;
    }
}
 
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if( self.loadFailBlock != nil ){
        self.loadFailBlock( error );
        self.loadFailBlock = nil;
    }
}
 

-(void)webViewDidFinishLoad:(KEFatPageWebView *)webView{
    if(self.loadCompletionBlock!=nil && ![webView.request.URL.absoluteString isEqualToString:@"about:blank"]){
        self.loadCompletionBlock();
        self.loadCompletionBlock = nil;
    }
}

@end
