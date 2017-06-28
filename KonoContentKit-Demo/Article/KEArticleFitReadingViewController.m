//
//  KEArticleFitReadingViewController.m
//  Kono
//
//  Created by Kono on 2017/6/25.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import "KEArticleFitReadingViewController.h"
#import "KEColor.h"
#import "KEBookLibraryTOCPageViewController.h"
#import <MBProgressHUD.h>
#import <MZFormSheetController.h>
#import <WYPopoverController.h>

static NSString *cellIdentifier = @"articleFitReadingCellIdentifier";

static int ARTICLE_TOOL_FONT_ADJUST_VIEW_HEIGHT = 72;

static CGFloat KEFITREADING_CLOSE_GESTURE_OFFSET = -100;


@interface KEArticleFitReadingViewController ()<WYPopoverControllerDelegate>{
    
    WYPopoverController* popoverController;
}

@property (nonatomic) UIButton *translationSwitchButton;

@end

@implementation KEArticleFitReadingViewController {
    
    float _previousScrollOffset;
}

@synthesize currentArticleFontSizeOffset = _currentArticleFontSizeOffset;

#pragma mark - property getter/setter function

- (void)setCurrentArticleFontSizeOffset:(NSInteger )currentArticleFontSizeOffset {
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSNumber *fontSizeOffset = [NSNumber numberWithInteger:currentArticleFontSizeOffset];
    [storage setObject:fontSizeOffset forKey:@"KEArticleFontSize"];
    
    [storage synchronize];
}

- (NSInteger )currentArticleFontSizeOffset {
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSNumber *defaultFontSizeOffset = @(0);
    
    if( [[storage objectForKey:@"KEArticleFontSize"] isKindOfClass:[NSNumber class]]){
        defaultFontSizeOffset = [storage objectForKey:@"KEArticleFontSize"];
    }
    
    return [defaultFontSizeOffset integerValue];
    
}

# pragma mark - viewcontroller life cycle function

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initProperty];
    
    [self initDefaultLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articleChange:)
                                                 name:@"KEMagazinePageChange"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissNavigationBar) userInfo:nil repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if( [self.articlesArray count] > 1 ){
        [self initMagazineOpenPosition];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat leftMargin = 10;
    CGFloat bottomMargin = 12;
    CGFloat buttonLength = 52;
    
    if (DEVICE_IS_IPAD) {
        leftMargin = 15;
        bottomMargin = 32;
    }
    
    self.translationSwitchButton.frame = CGRectMake(leftMargin, screenHeight - buttonLength - bottomMargin, buttonLength, buttonLength);
}

- (void)dealloc{
    
    /* remove the observer */
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {} @finally {}
    
    [self removePropertyRef];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - init function

- (void)initDefaultLayout{
    
    [self.fitReadingView registerNib:[UINib nibWithNibName:NSStringFromClass([KEFitReadingViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    
    UICollectionViewFlowLayout *colFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    colFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    colFlowLayout.itemSize = self.view.frame.size;
    self.fitReadingView.collectionViewLayout = colFlowLayout;
    self.fitReadingView.pagingEnabled = YES;
    
    self.fitReadingView.bounces = NO;
    self.fitReadingView.dataSource = self;
    self.fitReadingView.delegate = self;
    [self.fitReadingView setBackgroundColor:[KEColor konoBackgroundHighlightGray]];
    
//    if (self.bookItem.isHasTranslation) {
//        self.translationSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, -52, 52, 52)];
//        
//        UIImage *image = [UIImage imageNamed:@"btn_translation_ch_normal"];
//        UIImage *highlightedImage = [UIImage imageNamed:@"btn_translation_ch_pressed"];
//        if (self.articleItem.showTranslation) {
//            image = [UIImage imageNamed:@"btn_translation_jp_normal"];
//            highlightedImage = [UIImage imageNamed:@"btn_translation_jp_pressed"];
//        }
//        [self.translationSwitchButton setImage:image forState:UIControlStateNormal];
//        [self.translationSwitchButton setImage:highlightedImage forState:UIControlStateHighlighted];
//        
//        [self.translationSwitchButton addTarget:self action:@selector(translationSwitchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self.view addSubview:self.translationSwitchButton];
//    }
    
}

- (void)initMagazineOpenPosition{
    
    NSInteger articleIndex = [self getArticleIndexInMagazine:self.articleItem.articleID];
    
    [self.fitReadingView reloadData];
    [self.fitReadingView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:articleIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
}


- (void)initProperty{
    
    _previousScrollOffset = 0;
    
    self.articlesArray = @[self.articleItem];
    
    self.isToolBarShow = YES;
    
    if (!self.baseViewController) {
        self.baseViewController = self;
    }
    
}

- (void)removePropertyRef {
    
    for ( KEFitReadingViewCell *cell in [self.fitReadingView visibleCells]) {
        
        [cell.webView setDelegate:nil];
        cell.webView.scrollView.delegate = nil;
        cell.webView.articleDelegate = nil;
        cell.delegate = nil;
        [cell.webView stopLoading];
        
    }
    
    self.webViewLoadCompleteBlock = nil;
    self.bookItem = nil;
    self.articleItem = nil;
    self.baseViewController = nil;
    self.articlesArray = nil;
    self.fitReadingView.delegate = nil;
    self.fitReadingView.dataSource = nil;
    
}

# pragma mark - TOC article selected notification

- (void)articleChange:(NSNotification*)notification{
    
    NSDictionary *receiveInfo = [notification userInfo];
    
    if( self.baseViewController != nil && self.baseViewController == [receiveInfo objectForKey:@"baseViewController"] ){
    
    
        self.articleItem = [receiveInfo objectForKey:@"article"];
        if( [self.articlesArray count] > 1 ){
            //webContent
            NSInteger articleIndex = [self getArticleIndexInMagazine:self.articleItem.articleID];
            
            if( articleIndex != 0){
                [self.fitReadingView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:articleIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
            else{
                
                for( KEFitReadingViewCell *cell in [self.fitReadingView visibleCells] ) {
                    
                    cell.isLoadComplete = NO;
                }
                
                [self.fitReadingView reloadData];
            }
        }
        else{
            [[self presentingViewController]  dismissViewControllerAnimated:YES completion:^{
                [self removePropertyRef];
            }];
            
            /* fitReading tool view, keep in fit-reading view
            if( self.articleItem.isHasFitreading && NO == [[receiveInfo objectForKey:@"isThumbnailClick"] boolValue] ){
                self.tocArray = @[ self.articleItem ];
                [self.fitReadingView reloadData];
            }
            else{
                
                [[self presentingViewController]  dismissViewControllerAnimated:YES completion:^{
                    [self removePropertyRef];
                }];
            }*/
            
        }
        
    }
    
}

# pragma mark - index calculating function

- (NSInteger)getArticleIndexInMagazine:(NSString *)articleID{
    
    NSInteger articleIndex = 0;
    
    if (self.bookItem) {
        
        for (KCBookArticle *article in self.bookItem.articleArray) {
            
            if ([article.articleID isEqualToString:articleID]) {
                break;
            }
            else{
                articleIndex++;
            }
            
        }
    }
    
    return articleIndex;
}

# pragma mark - UI animation control function

- (void)dismissArticleToolMenu {
    
    if (DEVICE_IS_IPAD) {
        
        [popoverController dismissPopoverAnimated:NO options:WYPopoverAnimationOptionFade completion:^{
            popoverController.delegate = nil;
            popoverController = nil;
        }];
        
    }
    else{
        [self dismissFormSheetControllerAnimated:NO completionHandler:^(MZFormSheetController *formSheetController){
            KEArticleToolFontSizeViewController *vc = (KEArticleToolFontSizeViewController *)(formSheetController.presentedFSViewController);
            vc.delegate = nil;
        }];
    }
    
}

- (void)dismissNavigationBar {
    if (self.isToolBarShow) {
        self.isToolBarShow = NO;
        [self showNavigationBar:NO];
    }
}

- (void)dismissFitreadingView{
    
    [[self presentingViewController]  dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
}

- (void)showNavigationBar:(BOOL)isShow {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat leftMargin = 10;
    CGFloat bottomMargin = 12;
    CGFloat buttonLength = 52;
    
    if (DEVICE_IS_IPAD) {
        leftMargin = 15;
        bottomMargin = 32;
    }
    
    if (isShow) {
        [self.navigationView setHidden:NO];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.navigationView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 49);
                             
                             self.translationSwitchButton.frame = CGRectMake(leftMargin, screenHeight - buttonLength - bottomMargin, buttonLength, buttonLength);
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
        
    }
    else {
        
        self.navigationView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 49);
        
        self.translationSwitchButton.frame = CGRectMake(leftMargin, screenHeight - buttonLength - bottomMargin, buttonLength, buttonLength);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.translationSwitchButton.frame = CGRectMake(leftMargin, screenHeight, buttonLength, buttonLength);
                             
                             self.navigationView.frame = CGRectMake( 0, -49, self.view.frame.size.width, 49);
                         }
                         completion:^(BOOL finished) {
                             if( YES == finished ){
                                 [self.navigationView setHidden:YES];
                             }
                             
                         }
         ];
    }
    
}

- (void)toggleToolbar{
    
    if( YES == self.isToolBarShow ){
        self.isToolBarShow = NO;
    }
    else{
        self.isToolBarShow = YES;
    }
    [self showNavigationBar:self.isToolBarShow];
    
}

- (void)showFontAdjustBar{
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    
    KEArticleToolFontSizeViewController *vc = [[KEArticleToolFontSizeViewController alloc] initWithNibName:@"KEArticleToolFontSizeViewController" bundle:nil];
    
    vc.delegate = self;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    CGFloat selectionMenuHeight = ARTICLE_TOOL_FONT_ADJUST_VIEW_HEIGHT;
    
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width, selectionMenuHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    formSheet.portraitTopInset = self.view.frame.size.height - selectionMenuHeight;
    
    formSheet.shadowOpacity = 0;
    
    formSheet.cornerRadius = 0;
    
    formSheet.shadowRadius = 0.0;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        
        
    };
    
    
    [formSheet setWillDismissCompletionHandler:^(UIViewController *vc){
        
        
    }];
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
        
    }];

    
    
    
}

- (void)showToolMenu:(NSInteger)popularNum isUserLiked:(BOOL)isLiked{
    
    if( DEVICE_IS_IPAD ){
        [self showiPadToolMenu:popularNum isUserLiked:isLiked];
    }
    else{
        [self showToolMenuOniPhone:popularNum isUserLiked:isLiked];
    }
    
}

- (void)showiPadToolMenu:(NSInteger)popularNum isUserLiked:(BOOL)isLiked{
    
    KEArticleToolFontSizeViewController *vc = [[KEArticleToolFontSizeViewController alloc] initWithNibName:@"KEArticleToolFontSizeViewController" bundle:nil];
    
    vc.delegate = self;
    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:vc];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(320,   ARTICLE_TOOL_FONT_ADJUST_VIEW_HEIGHT);
    
    
    WYPopoverTheme *theme = [WYPopoverTheme theme];
    
    theme.tintColor = [UIColor blackColor];
    theme.outerCornerRadius = 2;
    theme.innerCornerRadius = 2;
    theme.borderWidth = 0;
    theme.fillTopColor = [UIColor colorWithWhite:0 alpha:1];
    theme.fillBottomColor = [UIColor colorWithWhite:0 alpha:1];
    theme.arrowHeight = 0;
    
    popoverController.theme = theme;
    
    
    
    [popoverController presentPopoverFromRect:self.toolBtn.frame inView:self.navigationView permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    
}

- (void)showToolMenuOniPhone:(NSInteger)popularNum isUserLiked:(BOOL)isLiked{
    
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    
    
    KEArticleToolFontSizeViewController *vc = [[KEArticleToolFontSizeViewController alloc] initWithNibName:@"KEArticleToolFontSizeViewController" bundle:nil];
    
    vc.delegate = self;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    CGFloat selectionMenuHeight = ARTICLE_TOOL_FONT_ADJUST_VIEW_HEIGHT;
    
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width, selectionMenuHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    formSheet.portraitTopInset = self.view.frame.size.height - selectionMenuHeight;
    
    formSheet.shadowOpacity = 0;
    
    formSheet.cornerRadius = 0;
    
    formSheet.shadowRadius = 0.0;
    
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
        
    }];
    
}

# pragma mark - collection view related function

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    return screenRect.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.articlesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KEFitReadingViewCell *cell = (KEFitReadingViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    KCBookArticle *articleItem = self.articlesArray[indexPath.row];
    
    cell.articleItem = articleItem;
    cell.bookItem = self.bookItem;
    
    cell.delegate = self;
    cell.webView.scrollView.delegate = self;
    cell.webView.articleDelegate = self;
    
    if (!DEVICE_IS_IOS8_OR_LATER) {
        [cell loadFitreadingArticleWithComplete:^{
            
        }];
    }
    
    return (UICollectionViewCell*)cell;
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(KEFitReadingViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!cell.isLoadComplete) {
        [cell loadFitreadingArticleWithComplete:^{
            
        }];
    }

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //stop playing the fit-reading audio/video
    
    CGRect visibleRect = (CGRect){.origin = self.fitReadingView.contentOffset, .size = self.fitReadingView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.fitReadingView indexPathForItemAtPoint:visiblePoint];
    
    
    if( visibleIndexPath.row != indexPath.row ){
        
        [(KEFitReadingViewCell *)cell clearContent];
    }
    
}


# pragma mark - Fit Reading article cell delegate function

- (void)adjustFontSizeWithRealTime:(KEFitReadingViewCell *)cell withRealTimeAction:(BOOL)isRealTimeAdjustment{
    
    if( isRealTimeAdjustment ){
        
        [cell.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"adjustDivFontSize(%ld)",(long)self.currentArticleFontSizeOffset]];
    }
    else{
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            sleep(1);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [cell.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"adjustDivFontSize(%ld)",(long)self.currentArticleFontSizeOffset]];
            });
        });
    }
    
}

# pragma mark - Fit Reading tool delegate function

- (void)slideFontSizeController:(NSInteger)fontSize{
    
    KEFitReadingViewCell *cell = (KEFitReadingViewCell *)([[self.fitReadingView visibleCells] objectAtIndex:0]);
    
    if( self.currentArticleFontSizeOffset != fontSize ){
        NSInteger adjustValue = fontSize - self.currentArticleFontSizeOffset;
        [cell.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"adjustDivFontSize(%ld)",(long)adjustValue]];
        self.currentArticleFontSizeOffset = fontSize;
    }

    
}


# pragma mark - Fit Reading WebView delegate function

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float scrollOffset = scrollView.contentOffset.y;
    if( self.fitReadingView == scrollView ){
        
    }
    else{
        if( scrollOffset < KEFITREADING_CLOSE_GESTURE_OFFSET ){
            
            [self dismissFitreadingView];
        }
        
        if( scrollOffset < _previousScrollOffset || 0 >= scrollOffset ){
            // then we are at the top
            if( NO == self.isToolBarShow ){
                self.isToolBarShow = YES;
                [self showNavigationBar:self.isToolBarShow];
            }
            
        }
        else{
            if( YES == self.isToolBarShow ){
                self.isToolBarShow = NO;
                [self showNavigationBar:self.isToolBarShow];
            }

        }
        
        _previousScrollOffset = scrollOffset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if( self.fitReadingView == scrollView ){
        NSInteger currentIndex = self.fitReadingView.contentOffset.x / self.fitReadingView.frame.size.width;
        if( [self.articlesArray count] > 1 ){
            
            self.articleItem = [self.articlesArray objectAtIndex:currentIndex];
        }
    }
    
}

- (void)userDidClickOnContent{
    
    [self toggleToolbar];
}


# pragma mark - iPad popover delegate function

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller{
    
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller{
    
    //remove the delegate in popover viewcontroller
    ((KEArticleToolFontSizeViewController *)controller.contentViewController).delegate = nil;
    popoverController.delegate = nil;
    popoverController = nil;
}


# pragma mark - button handle function

- (IBAction)toolBtnPressed:(id)sender {
    
    
    if( DEVICE_IS_IPAD ){
        [self showiPadToolMenu:0 isUserLiked:NO];
    }
    else{
        [self showFontAdjustBar];
    }
    return;
    
}

- (IBAction)tocBtnPressed:(id)sender {
    
    NSInteger articleIndex = [self getArticleIndexInMagazine:self.articleItem.articleID];
    NSInteger pageIndex = 0;
    
    pageIndex = self.articleItem.beginAt - 1;
    
    KEBookLibraryTOCPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"KEBookLibraryTOCPageViewController"];
    
    vc.baseViewController = self;
    
    vc.bookItem = self.bookItem;
    vc.targetArticleIndex = articleIndex;
    vc.targetPageIndex = pageIndex;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)backBtnPressed:(id)sender {
    
    
    [self dismissFitreadingView];
    
}


- (void)translationSwitchButtonPressed {
    
//    self.articleItem.showTranslation = !self.articleItem.showTranslation;
//    
//    UIImage *image = [UIImage imageNamed:@"btn_translation_ch_normal"];
//    UIImage *highlightedImage = [UIImage imageNamed:@"btn_translation_ch_pressed"];
//    if (self.articleItem.showTranslation) {
//        image = [UIImage imageNamed:@"btn_translation_jp_normal"];
//        highlightedImage = [UIImage imageNamed:@"btn_translation_jp_pressed"];
//    }
//    [self.translationSwitchButton setImage:image forState:UIControlStateNormal];
//    [self.translationSwitchButton setImage:highlightedImage forState:UIControlStateHighlighted];
//    
//    for( KEFitReadingViewCell *cell in [self.fitReadingView visibleCells] ) {
//        
//        cell.isLoadComplete = NO;
//    }
//    
//    [self.fitReadingView reloadData];
}


@end
