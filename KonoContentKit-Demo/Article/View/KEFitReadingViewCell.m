//
//  KEFitReadingViewCell.m
//  Kono
//
//  Created by Kono on 2016/7/19.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEFitReadingViewCell.h"
#import <MBProgressHUD.h>

@implementation KEFitReadingViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.webView.delegate = self;
    self.isLoadComplete = NO;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
}

- (void)dealloc{
    
    //NSLog(@"dealloc web content webview!");
    
}

- (void)prepareWebViewTemplateWithComplete:(void(^)(void))completeBlock withFail:(void(^)(void))failBlock{
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"dist"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    self.webViewLoadCompleteBlock = completeBlock;
    
}

- (void)loadFitreadingArticleWithComplete:(void(^)(void))completeBlock {
    
    KCBookArticle *tmpArticleItem = self.articleItem;
    
    [[KCService contentManager] getArticleTextForArticle:tmpArticleItem complete:^(NSData *jsonData) {
        
        self.isLoadComplete = YES;
        /* in case that article callback is called after cell changes, test that if article item changed or not */
        if ( tmpArticleItem == self.articleItem ){
            BOOL isNeedKeyToRender = (tmpArticleItem.isHasAudio || tmpArticleItem.isHasVideo);
            [self renderFitreadingArticleFromData:jsonData requireKey:isNeedKeyToRender];
            completeBlock();
            
        }
        
    } fail:^(NSError *error) {
        
        self.isLoadComplete = YES;
        NSLog(@"load fit-reading error:%@", error);
        
    }];
    
}

- (void)clearContent{
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"clearContent()"];
    self.isLoadComplete = NO;
}


- (void)renderFitreadingArticleFromData:(NSData*)data requireKey:(BOOL)requireKey {
    
    [self prepareWebViewTemplateWithComplete:^{
        
        NSError* error;
        NSData *parsedData;
        
        if (self.bookItem) {
            
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:json];
            [dic setObject:self.bookItem.name forKey:@"magTitle"];
            [dic setObject:self.bookItem.issue forKey:@"magIssue"];
            
            parsedData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        }
        
        NSString *myString = [[NSString alloc] initWithData:parsedData encoding:NSUTF8StringEncoding];
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"setDeviceType(%d)", DEVICE_IS_IPAD ]];
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"open_article(%@, %d, '%@')", myString , YES , PROD_SERVER]];
        
    } withFail:^{
        
    }];
    
}

- (void)adjustDefaultFontSize {
    
    if([self.delegate respondsToSelector:@selector(adjustFontSizeWithRealTime:withRealTimeAction:)]){
        [self.delegate adjustFontSizeWithRealTime:self withRealTimeAction:YES];
    }
    
}


# pragma mark - webView operate function

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"erorr loading webview:  %@" , webView.request);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self adjustDefaultFontSize];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    
    if ([requestString hasPrefix:@"ios-log:"]) {
        /* Uncomment for debug
         NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
         DDLogDebug(@"UIWebView console: %@", logString);
         */
        return NO;
    }
    
    /* template finish loading */
    if( [request.URL.scheme isEqualToString:@"kono"] && [request.URL.host isEqualToString:@"template_load_finished"]){
        
        /* templated is ready */
        if( self.webViewLoadCompleteBlock != nil ){
            self.webViewLoadCompleteBlock();
            
            self.webViewLoadCompleteBlock = nil;
        }
        
        return NO;
        
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
    
}

@end
