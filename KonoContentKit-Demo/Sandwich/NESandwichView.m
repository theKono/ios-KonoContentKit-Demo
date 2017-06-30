//
//  NESandwichView.m
//  Kono
//
//  Created by Neo on 11/13/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "NESandwichView.h"
#import "KEPageWebView.h"

#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

static NSString *cellIdentifier = @"webCellIdentifier";
static int thumbnailObjTag = 1001;
int webviewObjectNum = 200;
@implementation NESandwichView {
//    NSMutableArray *_webviewArray;
    NSMutableDictionary *_webviewDictionary;
}

- (void)awakeFromNib{
    
    [super awakeFromNib];
    if( self.tableView == nil ){
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
        
        UIScreen *screen = [UIScreen mainScreen];
        self.tableView.transform = rotateTable;
        
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.edges.equalTo( self ).with.insets(UIEdgeInsetsZero);
            make.width.equalTo( @(screen.bounds.size.height) );
            make.height.equalTo( @(screen.bounds.size.width) );
            make.centerX.equalTo( self.tableView.superview.mas_centerX );
            make.centerY.equalTo( self.tableView.superview.mas_centerY );
            
        }];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        NSLog(@"a new table view ");
        self.tableView.pagingEnabled = YES;
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:0.933 green:0.914 blue:0.878 alpha:1.0]];
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, screen.bounds.size.height-8);
        
    }
    if( DEVICE_IS_IOS9_OR_LATER ){
        webviewObjectNum = 10;
    }
    else{
        webviewObjectNum = 3;
    }
}

/* init tableview and webviews */
- (void)initLayout {
    
    if( nil != self.tableView ){
        [self.tableView reloadData];
    }
}

- (void)endDisplay{
    
    [_webviewDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if( DEVICE_IS_IOS9_OR_LATER ){
            [(KEPageWebView *)obj stopLoading];
            [(KEPageWebView *)obj loadHTMLString:@"" baseURL:nil];
            [(KEPageWebView *)obj removeFromSuperview];
        }
        else{
            [(KEFatPageWebView *)obj stopLoading];
            [(KEFatPageWebView *)obj loadHTMLString:@"" baseURL:nil];
            [(KEFatPageWebView *)obj removeFromSuperview];
        }
        
    }];
    
}

- (void)showThumbnailImage:(BOOL)needToShowThumbnail withImagePath:(NSString *)imageURL forItemAtIndex:(NSInteger)index{
    
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    NSMutableIndexSet *visibleIdxSet = [[NSMutableIndexSet alloc] init];
    
    for( NSIndexPath *visibleIndexPath in visibleRows ) {
        [visibleIdxSet addIndex:visibleIndexPath.row];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    UIImageView *thumbnailImage = (UIImageView*)[cell viewWithTag:thumbnailObjTag];
    
    
    if( [visibleIdxSet containsIndex:index] ) {
        if( needToShowThumbnail ){
            thumbnailImage.alpha = 1;
            [thumbnailImage pin_setImageFromURL:[NSURL URLWithString:imageURL]];
            
        }
        else{
            thumbnailImage.alpha = 0;
        }
    }
    
}

- (void)cleanView {

    
    [_webviewDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if( DEVICE_IS_IOS9_OR_LATER ){
            ((KEPageWebView *)obj).pageDelegate = nil;
            ((KEPageWebView *)obj).scrollView.delegate = nil;
        }
        else{
            ((KEFatPageWebView *)obj).pageDelegate = nil;
            ((KEFatPageWebView *)obj).scrollView.delegate = nil;
        }
    }];
    
    [_webviewDictionary removeAllObjects];
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    
}

/* scroll tableview to top */
- (void)goBackToTop{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
}

- (KEPageWebView*)createAWebviewWithIndex:(NSInteger)idx {
    
    /* set the size to fit the screen */
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Disable the long press copy menu bar
    NSString *source = @"var style = document.createElement('style'); \
    style.type = 'text/css'; \
    style.innerText = '*:not(input):not(textarea) { -webkit-user-select: none; -webkit-touch-callout: none; }'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(style);";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    // Create the user content controller and add the script to it
    WKUserContentController *userContentController = [WKUserContentController new];
    [userContentController addUserScript:script];
    
    // Create the configuration with the user content controller
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;
    
    KEPageWebView *webview = [[KEPageWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) configuration:configuration];
    
    webview.pageDelegate = self;
    webview.scrollView.delegate = self;
    webview.scrollView.bounces = NO;
    
    [self enqueueReusableWebview:webview forIndex:idx];

    return webview;
}

- (KEFatPageWebView*)createAFatWebviewWithIndex:(NSInteger)idx {
    
    /* set the size to fit the screen */
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    KEFatPageWebView *webview = [[KEFatPageWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    webview.pageDelegate = self;
    webview.scalesPageToFit = YES;
    webview.scrollView.delegate = self;
    webview.scrollView.bounces = NO;
    
    [self enqueueReusableFatWebview:webview forIndex:idx];
    return webview;
}


/* perload cache number */
- (NSInteger)numberOfCacheItem:(NSUInteger)pageNum {
    
    if(DEVICE_IS_IOS9_OR_LATER){
        return MIN(4,pageNum);
    }
    else{
        return MIN(2,pageNum);
    }
    
}


/* current page index */
- (NSInteger)currentIndex {
    return [[self.tableView indexPathForCell:[[self.tableView visibleCells] firstObject]] row];
}

- (void)reloadPageAtIndex:(NSInteger)index{
    //NSLog(@"download complete! reload %ld",(long)index);
    if( DEVICE_IS_IOS9_OR_LATER ){
        [self loadPageAtIndex:index inWebView:[self dequeueReusableWebViewForIndex:(index % webviewObjectNum)] isPreload:NO];
    }
    else{
        [self loadPageAtIndex:index inFatWebView:[self dequeueReusableFatWebViewForIndex:(index % webviewObjectNum)] isPreload:NO];
    }
}

- (void)loadPageAtIndex:(NSInteger)idx inWebView:(KEPageWebView*)webview isPreload:(BOOL)isPreload {
    
    NSString *path = [self.dataSource htmlFilePathForItemAtIndex:idx isPreload:isPreload];
    NSLog(@"load page at :%d" , (int)idx );
    if( path == nil ){
        
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        webview.alpha = 0;
        webview.cacheKey = @"nil";
        NSLog(@"path = nil ");
        return;
    }
    
    if( [path isEqualToString:webview.cacheKey] ){
        [webview setContentFitScreenSize];
        webview.alpha = 1;
        self.tableView.alpha = 1.0;
        return;
    }

    [webview stopLoading];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    webview.alpha = 0;
    webview.pageNum = idx;

    NSURL *url = [NSURL fileURLWithPath:path];
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSURL *dir_url = [NSURL fileURLWithPath:directory isDirectory:YES];

    __weak KEPageWebView *weakOperator = webview;
    __weak NESandwichView *weakSelf = self;

    [webview loadFileURL:url allowingReadAccessToURL:dir_url withComplete:^{
        
        weakOperator.isReadyToShow = YES;
        weakOperator.alpha = 1.0;
        weakSelf.tableView.alpha = 1.0;
        weakOperator.cacheKey = path;
        
        //if(idx==0){
        //    [weakSelf.tableView reloadData];
        //}
    } withFail:^(NSError *error) {
        NSLog(@"fail :%@" , error );
    }];

}

- (void)loadPageAtIndex:(NSInteger)idx inFatWebView:(KEFatPageWebView*)webview isPreload:(BOOL)isPreload{
    
    NSString *path = [self.dataSource htmlFilePathForItemAtIndex:idx isPreload:NO];
    NSLog(@"load fat page at :%d" , (int)idx );
    if( path == nil ){
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        webview.alpha = 0;
        webview.cacheKey = @"nil";
        NSLog(@"path = nil ");
        return;
    }
    
    
    if( [path isEqualToString:webview.cacheKey] ){
        [webview setContentFitScreenSize];
        webview.alpha = 1;
        self.tableView.alpha = 1.0;
        return;
    }
    [webview stopLoading];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    webview.alpha = 0;
    webview.pageNum = idx;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    __weak KEFatPageWebView *weakOperator = webview;
    __weak NESandwichView *weakSelf = self;
    NSLog(@"req : %@ %d" , request , (int)idx);

    [webview loadRequest:request withComplete:^{
        
        weakOperator.isReadyToShow = YES;
        weakOperator.alpha = 1.0;
        weakSelf.tableView.alpha = 1.0;
        weakOperator.cacheKey = path;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
     
        //if(idx==0){
        //    [weakSelf.tableView reloadData];
        //}
    }withFail:^(NSError *error) {
        NSLog(@"fail :%@" , error );
    }];
    
}



#pragma mark - table view datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    for( UIView *view in cell.contentView.subviews ){
        if( [view isKindOfClass:[KEPageWebView class]] || [view isKindOfClass:[KEFatPageWebView class]]){
            [view removeFromSuperview];
        }
    }
    if( [self.delegate respondsToSelector:@selector(willDisplayPage:)]){
        [self.delegate willDisplayPage:indexPath.row];
    }
    
    if( DEVICE_IS_IOS9_OR_LATER ) {
        KEPageWebView *webview = [self dequeueReusableWebViewForIndex:(indexPath.row % webviewObjectNum)];
        if( webview == nil ){
            webview = [self createAWebviewWithIndex:(indexPath.row % webviewObjectNum)];
        }
        webview.alpha = 0.0;
        [self loadPageAtIndex:indexPath.row inWebView:webview isPreload:NO];
        
        
        webview.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.width);
        [cell.contentView addSubview:webview];
    }
    else{
        KEFatPageWebView *webview = [self dequeueReusableFatWebViewForIndex:(indexPath.row % webviewObjectNum)];
        if( webview == nil ){
            webview = [self createAFatWebviewWithIndex:(indexPath.row % webviewObjectNum)];
        }
        webview.alpha = 0.0;
        [self loadPageAtIndex:indexPath.row inFatWebView:webview isPreload:NO];
        
        webview.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.width);
        [cell.contentView addSubview:webview];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *thumbNailImage = (UIImageView *)[cell viewWithTag:thumbnailObjTag];
    if( thumbNailImage == nil ){
        thumbNailImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.width)];
        thumbNailImage.tag = thumbnailObjTag;
        thumbNailImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:thumbNailImage];
    }
    
    CGAffineTransform rotateImage = CGAffineTransformMakeRotation(M_PI_2);
    cell.transform = rotateImage;
    
    thumbNailImage.image = nil;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return self.frame.size.height;
    return self.frame.size.width;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource numberOfitems];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[self preloadWebView:indexPath.row];
    
//    UIImageView *thumbNailImage = (UIImageView *)[cell viewWithTag:thumbnailObjTag];
//    thumbNailImage.alpha = 0;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - user touch event handler

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    if( [self.delegate respondsToSelector:@selector(userSingleTapOnView:)]){
        [self.delegate userSingleTapOnView:self];
    }
}

#pragma mark - scrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if( [self.delegate respondsToSelector:@selector(articleViewStartMoving)]){
        [self.delegate articleViewStartMoving];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if( scrollView != self.tableView ){
        
        if( (scrollView.contentSize.height-scrollView.contentOffset.y)<=scrollView.frame.size.height ){
            /* scroll to the next page, but it is useless here */

            if( scrollView.frame.size.height - (scrollView.contentSize.height-scrollView.contentOffset.y) > 40 ){
                if( self.currentIndex+1 < [self.dataSource numberOfitems] && scrollView.zoomScale >= 1.0 ){
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex+1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                }
            }
        }else if (scrollView.contentOffset.y < -40.0){
            /* scroll to top */
            if( self.currentIndex-1 >= 0 && scrollView.zoomScale >= 1.0 ){
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if( scrollView == self.tableView ){
    
        //get refrence of vertical indicator
        UIImageView *verticalIndicator = ((UIImageView *)[scrollView.subviews objectAtIndex:(scrollView.subviews.count-1)]);
        //set color to vertical indicator
        [verticalIndicator setBackgroundColor:[UIColor greenColor]]; // Your color
        
        //get refrence of horizontal indicator
        UIImageView *horizontalIndicator = ((UIImageView *)[scrollView.subviews objectAtIndex:(scrollView.subviews.count-2)]);
        //set color to horizontal indicator
        [horizontalIndicator setBackgroundColor:[UIColor blueColor]]; // Your color
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if( scrollView == self.tableView ){
        
        NSIndexPath *currentVisibleIndexPath;
        
        if( [[self.tableView indexPathsForVisibleRows] count] > 0 ){
        
            currentVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
        }
        else if( [[self.tableView visibleCells] count] > 0 ){
            
            UITableViewCell *cell = [[self.tableView visibleCells] objectAtIndex:0];
            currentVisibleIndexPath = [self.tableView indexPathForCell:cell];
            
        }
        
        if( nil != currentVisibleIndexPath && [self.delegate respondsToSelector:@selector(updateDisplayPage:)]){
            [self.delegate updateDisplayPage:currentVisibleIndexPath.row];
        }
        
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    //handle scroll programmatically to update article property
    if( scrollView == self.tableView ){
        
        NSIndexPath *currentVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
        
        if( [self.delegate respondsToSelector:@selector(updateDisplayPage:)]){
            [self.delegate updateDisplayPage:currentVisibleIndexPath.row];
        }
        
    }
    
}


# pragma mark - experience enhancement function

- (void)preloadWebView:(NSInteger)centerIdx{
    
    NSInteger prePageIdx = MAX( 0 , centerIdx - PRELOAD_CELL_COUNT);
    NSInteger nextPageIdx = MIN( centerIdx + PRELOAD_CELL_COUNT, [self.dataSource numberOfitems] - 1);
    
    if( DEVICE_IS_IOS9_OR_LATER ){
        if( centerIdx > prePageIdx ){
            KEPageWebView *preWebview = [self dequeueReusableWebViewForIndex:(prePageIdx % webviewObjectNum)];
            if( preWebview == nil ){
                preWebview = [self createAWebviewWithIndex:(prePageIdx % webviewObjectNum)];
            }
            ((KEPageWebView *)preWebview).alpha = 0.0;
            [self loadPageAtIndex:prePageIdx inWebView:preWebview isPreload:YES];
        }
        if( centerIdx < nextPageIdx ){
            KEPageWebView *nextWebview = [self dequeueReusableWebViewForIndex:(nextPageIdx % webviewObjectNum)];
            if( nextWebview == nil ){
                nextWebview = [self createAWebviewWithIndex:(nextPageIdx % webviewObjectNum)];
            }
            nextWebview.alpha = 0.0;
            [self loadPageAtIndex:nextPageIdx inWebView:nextWebview isPreload:YES];
        }
    }
    else{
      
        if( centerIdx > prePageIdx ){
            KEFatPageWebView *preWebview = [self dequeueReusableFatWebViewForIndex:(prePageIdx % webviewObjectNum)];
            if( preWebview == nil ){
                preWebview = [self createAFatWebviewWithIndex:(prePageIdx % webviewObjectNum)];
            }
            ((KEFatPageWebView *)preWebview).alpha = 0.0;
            [self loadPageAtIndex:prePageIdx inFatWebView:preWebview isPreload:YES];
        }
        if( centerIdx < nextPageIdx ){
            KEFatPageWebView *nextWebview = [self dequeueReusableFatWebViewForIndex:(nextPageIdx % webviewObjectNum)];
            if( nextWebview == nil ){
                nextWebview = [self createAFatWebviewWithIndex:(nextPageIdx % webviewObjectNum)];
            }
            nextWebview.alpha = 0.0;
            [self loadPageAtIndex:nextPageIdx inFatWebView:nextWebview isPreload:YES];
        }
        
    }
}

- (void)refreshCacheAggresively{
    self.tableView.alpha = 0.0;

    [_webviewDictionary removeAllObjects];

    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    return;

}

- (KEPageWebView*)dequeueReusableWebViewForIndex:(NSInteger)idx{
    return [_webviewDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)idx]];
}

- (KEFatPageWebView*)dequeueReusableFatWebViewForIndex:(NSInteger)idx{
    return [_webviewDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)idx]];
}

- (void)enqueueReusableWebview:(KEPageWebView*)webview forIndex:(NSInteger)idx {
    if( _webviewDictionary == nil ){
        _webviewDictionary = [NSMutableDictionary dictionary];
    }
    [_webviewDictionary setObject:webview forKey:[NSString stringWithFormat:@"%d", (int)idx]];
}

- (void)enqueueReusableFatWebview:(KEFatPageWebView*)webview forIndex:(NSInteger)idx {
    if( _webviewDictionary == nil ){
        _webviewDictionary = [NSMutableDictionary dictionary];
    }
    [_webviewDictionary setObject:webview forKey:[NSString stringWithFormat:@"%d", (int)idx]];
}


#pragma mark  ios9 webview delegate
- (void)userDidSingleTapOnView:(KEPageWebView *)view{
    if( [self.delegate respondsToSelector:@selector(userSingleTapOnView:)]){
        [self.delegate userSingleTapOnView:self];
    }
}

- (void)userStartOperationOnView{
    if( [self.delegate respondsToSelector:@selector(userStartOperationOnView)]){
        [self.delegate userStartOperationOnView];
    }
}

- (void)userDoneOperationOnView{
    if( [self.delegate respondsToSelector:@selector(userDoneOperationOnView)]){
        [self.delegate userDoneOperationOnView];
    }
    
}

#pragma mark ios7 ios8 webview delegate
- (BOOL)webView:(KEFatPageWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if( navigationType == UIWebViewNavigationTypeLinkClicked ){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
}

- (void)userDidSingleTapOnFatView:(KEFatPageWebView *)view{
    if( [self.delegate respondsToSelector:@selector(userSingleTapOnView:)]){
        [self.delegate userSingleTapOnView:self];
    }
}

@end
