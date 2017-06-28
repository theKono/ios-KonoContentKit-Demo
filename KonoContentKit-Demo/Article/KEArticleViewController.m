//
//  KEArticleViewController.m
//  Kono
//
//  Created by Kono on 2017/6/20.
//  Copyright © 2017年 Kono. All rights reserved.
//

#import "KEArticleViewController.h"
#import "KEBookLibraryTOCPageViewController.h"
#import "KEArticleFitReadingViewController.h"
#import "KEArticleLandscapeViewController.h"
#import "KEColor.h"
#import "KERotationPresentAnimation.h"
#import <MBProgressHUD.h>

#import <MZFormSheetController.h>

static NSString* KE_UPGRADE_BLOCK_REASON_NEEDVERIFY = @"NOTVERIFY";

#define ALERT_OFFSET_VERIFY_EMAIL 1001
#define ALERT_OFFSET_AGE_CONFIRMATION  1002
#define ALERT_OFFSET_MAGAZINE_BUNDLE_UPDATE  1003
#define ALERT_OFFSET_MAGAZINE_CACHE_UPDATE  1004

@interface KEArticleViewController ()
@property (nonatomic) NSString *tempFilePath;

@end

@implementation KEArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self initProperty];
    [self initDefaultLayout];
    
    [self fetchTOCInfo];
    
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (BOOL)isCurrentViewControllerVisible {
    
    BOOL isVisible = NO;
    
    if ( self.isViewLoaded && self.view.window){
        isVisible = YES;
    }
    
    return isVisible;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init function

- (void)initDefaultLayout {
    
    self.view.backgroundColor = [KEColor konoBackgroundHighlightGray];
    
    [self.articlePDFView initLayout];
    
    if( DEVICE_IS_IPAD ){
        self.rightFlipIndicator.frame = CGRectMake( self.view.frame.size.width-181 , 0 ,181, self.view.frame.size.height );
        self.leftFlipIndicator.frame = CGRectMake( 0 , 0 ,181, self.view.frame.size.height );
    }
    else{
        self.rightFlipIndicator.frame = CGRectMake( self.view.frame.size.width-148 , 0 ,148, self.view.frame.size.height );
        self.leftFlipIndicator.frame = CGRectMake( 0 , 0 ,148, self.view.frame.size.height );
    }
    
    self.navigationView.frame = CGRectMake( 0, -50, self.view.frame.size.width, 49 );
    self.tocBtn.frame = CGRectMake( self.view.frame.size.width - (48), 0, 48, 48 );
    self.navigationBorderView.frame = CGRectMake( 0 , 48, self.view.frame.size.width, 1 );
    
    CGFloat leftMargin = 0;
    
    if( DEVICE_IS_IPAD ){
        leftMargin = 15;
    }
    else{
        leftMargin = 10;
    }
    
    CGFloat interval = 10;

    self.fitReadingBtn.frame = CGRectMake( leftMargin, self.view.frame.size.height, self.fitReadingBtn.frame.size.width, self.fitReadingBtn.frame.size.height);
    [self.fitReadingBtn setHidden:YES];
    self.translationBtn.frame = CGRectMake( leftMargin + self.fitReadingBtn.frame.size.width + interval, self.view.frame.size.height, self.translationBtn.frame.size.width, self.translationBtn.frame.size.height);
    [self.translationBtn setHidden:YES];
    [self.rightFlipIndicator setHidden:YES];
    [self.leftFlipIndicator setHidden:YES];

}

- (void)initFrameForAnimation {
    
    if (self.bookItem.isLeftFlip) {
        self.articlePDFView.frame = CGRectMake( 2 * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height );
    } else {
        self.articlePDFView.frame = CGRectMake( -2 * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
}

- (void)initProperty{
    
    self.articlePDFView.dataSource = self;
    self.articlePDFView.delegate = self;
    
    self.preloadStatus = KEPDFPreloadStatusCodeUnknown;
    self.limitPreloadDoneNum = 0;
    
    self.isFlipAnimationDone = NO;
    self.isNeedShowFlipIndicator = NO;
    
}

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter]
                                            addObserver:self
                                               selector:@selector(pageChange:)
                                                   name:@"KEMagazinePageChange"
                                                 object:nil];
    
}

- (void)registerLandscapeMode {
    

    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(didRotate:)
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
    
}


#pragma mark - clean up function

- (void)cleanUpArticleViewer{
    
    [self.tocBtn setUserInteractionEnabled:NO];
    [self.preloadQueue cancelAllOperations];
    [self unregisterNotification];
    [self.articlePDFView cleanView];
    
}

- (void)unregisterNotification{
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {} @finally {}
    
}

- (void)dealloc{
    
    if( nil != self.popoverController ){
        self.popoverController.delegate = nil;
        self.popoverController = nil;
    }
    self.articlePDFView.dataSource = nil;
    self.articlePDFView.delegate = nil;
    
    
}

#pragma mark - device rotate notification

- (void) didRotate:(NSNotification *)notification{
    

    if( [self isCurrentViewControllerVisible] ){
    
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        if ( UIDeviceOrientationIsLandscape(orientation) ){
            
            KCBookPage *magSinglePageInfo = [self.bookItem.pageMappingArray objectAtIndex:self.currentMagazineIndex];
            KCBookArticle *pageArticleSource = [magSinglePageInfo.articleArray objectAtIndex:0];
            
            KEArticleLandscapeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"KEArticleLandscapeViewController"];

            vc.transitioningDelegate = self;
            vc.baseViewController = self;
            vc.bookItem = self.bookItem;
            vc.articleItem = pageArticleSource;
            vc.basePageIndex = self.currentMagazineIndex;
            
            [self presentViewController:vc animated:YES completion:nil];
            [self.popoverController dismissPopoverAnimated:NO];
            [self dismissFormSheetControllerAnimated:NO completionHandler:^(MZFormSheetController *formSheetController){}];
            
        }
    }
}


#pragma mark - page change notification

- (void)pageChange:(NSNotification*)notification {
    
    NSDictionary *receiveInfo = [notification userInfo];
    if( self == [receiveInfo objectForKey:@"baseViewController"]){
        NSInteger magazineIdx = ((NSIndexPath *)([receiveInfo objectForKey:@"pageIndexPath"])).row;
        NSInteger tableIdx = [self getTableViewIndex:magazineIdx];
        
        self.currentMagazineIndex = magazineIdx;
        
        [self updateFitReadingModeStatus];
        
        [self.articlePDFView.tableView beginUpdates];
        [self.articlePDFView.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:tableIdx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.articlePDFView.tableView endUpdates];
        [self.articlePDFView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableIdx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.isNeedShowFlipIndicator = YES;
    }
}

# pragma mark - magazine info datasource

- (void)fetchTOCInfo {
    
    [self initFrameForAnimation];
    
    NSLog(@"fetchTOCInfo");
    
    [[KCService contentManager] getAllArticlesForBook:self.bookItem complete:^(KCBook *book) {
        
        [[KCService contentManager] getThumbnailForBook:self.bookItem complete:^(KCBook *book) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            self.isNeedShowFlipIndicator = YES;
            
            self.currentMagazineIndex = 0;
            NSInteger tableViewIdx = [self getTableViewIndex:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.articlePDFView.tableView reloadData];
                [self.articlePDFView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableViewIdx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
            
        } fail:^(NSError *error) {
            
            NSLog(@"error");
            
        }];
        
    } fail:^(NSError *error) {
        NSLog(@"error");
    }];
}

- (NSInteger)getTableViewIndex:(NSInteger)magazineIndex {
    
    NSInteger tableViewIdx = 0;
    
    if (self.bookItem.pageMappingArray.count > 0) {
        
        if (NO == self.bookItem.isLeftFlip) {
            tableViewIdx = self.bookItem.pageMappingArray.count - magazineIndex - 1;
        }
        else{
            tableViewIdx = magazineIndex;
        }
    }
    
    return tableViewIdx;
}

- (NSInteger)getMagazinePageIndex:(NSInteger)tableViewIndex {
    
    NSInteger magazineIdx = 0;
    
    if (self.bookItem.pageMappingArray.count > 0) {
        
        if (!self.bookItem.isLeftFlip) {
            magazineIdx = self.bookItem.pageMappingArray.count - tableViewIndex - 1;
        }
        else{
            magazineIdx = tableViewIndex;
        }
    }
    
    return magazineIdx;
}


#pragma mark - handle the UI relate function

- (void)showArticleSelectionMenuOniPhone:(KEArticleSelectionMenuType)displayType {
    
    KCBookPage *page = self.bookItem.pageMappingArray[self.currentMagazineIndex];
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    
    KEArticleSelectionMenuViewController *vc = [[KEArticleSelectionMenuViewController alloc] initWithNibName:@"KEArticleSelectionMenuViewController" bundle:nil];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    CGFloat selectionMenuHeight = ARTICLE_MENU_TITLE_HEIGHT + ARTICLE_MENU_ITEM_HEIGHT * [page.articleArray count];
    
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.size.width, selectionMenuHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.portraitTopInset = self.view.frame.size.height - selectionMenuHeight;
    formSheet.shadowOpacity = 0;
    formSheet.cornerRadius = 0;
    formSheet.shadowRadius = 0.0;
    
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
        KEArticleSelectionMenuViewController *vc = (KEArticleSelectionMenuViewController*)formSheetController.presentedFSViewController;
        vc.bookItem = self.bookItem;
        vc.parentViewController = self;
        vc.articleArray = page.articleArray;
        vc.displayType = displayType;
        [vc refreshArticleMenuView];
    }];
    
    [formSheet setWillDismissCompletionHandler:^(UIViewController *vc){
        KEArticleSelectionMenuViewController *dismissVC = (KEArticleSelectionMenuViewController *)vc;
        if( nil != dismissVC.selectedArticleItem ){
            switch ( dismissVC.displayType ) {
                case KEArticleSelectionMenuFitReadingType:{
                    //dismissVC.selectedArticleItem.showTranslation = NO;
                    [self openArticleFitReadingPage:dismissVC.selectedArticleItem];
                    break;
                }
                case KEArticleSelectionMenuTranslationType: {
                    //dismissVC.selectedArticleItem.showTranslation = YES;
                    [self openArticleFitReadingPage:dismissVC.selectedArticleItem];
                }
                    break;
                default:
                    break;
            }
        }
        
    }];
}

- (void)showArticleSelectionMenuOniPad:(KEArticleSelectionMenuType)displayType{
    
    KCBookPage *page = self.bookItem.pageMappingArray[self.currentMagazineIndex];
    
    KEArticleSelectionMenuViewController *vc = [[KEArticleSelectionMenuViewController alloc] initWithNibName:@"KEArticleSelectionMenuViewController" bundle:nil];

    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.500]];
    
    UINavigationController *nvController = [[UINavigationController alloc] initWithRootViewController:vc];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:nvController];
    CGFloat selectionMenuHeight = ARTICLE_MENU_TITLE_HEIGHT + ARTICLE_MENU_ITEM_HEIGHT * [page.articleArray count];
    
    formSheet.presentedFormSheetSize = CGSizeMake(480, selectionMenuHeight);
    formSheet.portraitTopInset = 418;
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.cornerRadius = 2.0;
    formSheet.shadowOpacity = 0;
    formSheet.shadowRadius = 0.0;
    
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

        KEArticleSelectionMenuViewController *vc = (KEArticleSelectionMenuViewController *)(((UINavigationController *)formSheetController.presentedFSViewController).visibleViewController);

        vc.bookItem = self.bookItem;
        vc.parentViewController = self;
        vc.articleArray = page.articleArray;
        vc.displayType = displayType;
        [vc refreshArticleMenuView];
    }];
    
    [formSheet setWillDismissCompletionHandler:^(UIViewController *vc){
        KEArticleSelectionMenuViewController *dismissVC = (KEArticleSelectionMenuViewController *)(((UINavigationController *)vc).visibleViewController);
        if( nil != dismissVC.selectedArticleItem ){
            switch ( dismissVC.displayType ) {
                    
                case KEArticleSelectionMenuFitReadingType:{
//                    dismissVC.selectedArticleItem.showTranslation = NO;
//                    [KEUniversalController openArticleFitReadingWithArticle:dismissVC.selectedArticleItem withMagItem:self.magazineItem onViewController:self];
                    break;
                }
                case KEArticleSelectionMenuTranslationType: {
//                    dismissVC.selectedArticleItem.showTranslation = YES;
//                    [KEUniversalController openArticleFitReadingWithArticle:dismissVC.selectedArticleItem withMagItem:self.magazineItem onViewController:self];
                }
                    break;
                default:
                    break;
            }
        }
    }];

}

- (void)updateFitReadingModeStatus {
    
    BOOL isContainFitReading = NO;
    BOOL isContainTranslation = NO;
    BOOL isContainMedia = NO;
    
    KCBookPage *page = self.bookItem.pageMappingArray[self.currentMagazineIndex];
    
    if (page.articleArray) {
        for (KCBookArticle *article in page.articleArray) {
            if (article.isHasFitreading) {
                isContainFitReading = YES;
                if (article.isHasAudio || article.isHasVideo) {
                    isContainMedia = YES;
                }
                //                    if (article.isHasTranslation) {
                //                        isContainTranslation = YES;
                //                    }
            }
        }
    }
    
    if( YES == isContainMedia ){
        [self.fitReadingBtn setImage:[UIImage imageNamed:@"btn_fitreading_with_media_normal"] forState:UIControlStateNormal];
        [self.fitReadingBtn setImage:[UIImage imageNamed:@"btn_fitreading_with_media_pressed"] forState:UIControlStateHighlighted];

    }
    else{
        [self.fitReadingBtn setImage:[UIImage imageNamed:@"btn_fitreading_normal"] forState:UIControlStateNormal];
        [self.fitReadingBtn setImage:[UIImage imageNamed:@"btn_fitreading_pressed"] forState:UIControlStateHighlighted];
    }
    
    [self showFitReadingBtn:isContainFitReading hasTranslation:isContainTranslation];
    
}

- (BOOL)isMultiFitReadingWithPage:(NSInteger)pageIdx{
    
    BOOL isContainsMultiFitReading = NO;
    NSInteger containsFitReadingArticleNum = 0;
    
    KCBookPage *page = self.bookItem.pageMappingArray[pageIdx];
    
    for (KCBookArticle *article in page.articleArray) {
        if (article.isHasFitreading) {
            containsFitReadingArticleNum++;
        }
    }
    
    if (containsFitReadingArticleNum > 1) {
        isContainsMultiFitReading = YES;
    }
    
    return isContainsMultiFitReading;
}

#pragma mark - view animation

- (void)showArticlePDFView {
    
    CGFloat delayTime = 0.2;
    if( DEVICE_IS_IPHONE_4_OR_LESS || DEVICE_IS_IPHONE_5 || DEVICE_IS_IPAD ){
        delayTime = 0.5;
    }
    
    if( NO == self.isFlipAnimationDone ){
        
        [self registerLandscapeMode];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [UIView animateWithDuration:0.7
                              delay:delayTime
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.articlePDFView.frame = CGRectMake( 0, 0,self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if( YES == finished ){
                                 self.articlePDFView.frame = CGRectMake( 0, 0,self.view.frame.size.width, self.view.frame.size.height);
                             }
                         }
         ];
        self.isFlipAnimationDone = YES;
        
        
    }
    
    
}

- (void)showFitReadingBtn:(BOOL)isShow hasTranslation:(BOOL)hasTranslation{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat leftMargin = 0;
    CGFloat bottomMargin = 0;
    CGFloat interval = 10;
    
    if( DEVICE_IS_IPAD ){
        leftMargin = 15;
        bottomMargin = 32;
    }
    else{
        leftMargin = 10;
        bottomMargin = 10;
    }
    
    if( isShow ){
        
        [self.fitReadingBtn setHidden:NO];
        
        if (hasTranslation) {
            self.translationBtn.hidden = NO;
        } else {
            self.translationBtn.hidden = YES;
        }
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.fitReadingBtn.frame = CGRectMake( leftMargin, screenHeight - self.fitReadingBtn.frame.size.height - bottomMargin, self.fitReadingBtn.frame.size.width, self.fitReadingBtn.frame.size.height);
                             self.translationBtn.frame = CGRectMake( leftMargin + self.fitReadingBtn.frame.size.width + interval, screenHeight - self.translationBtn.frame.size.height - bottomMargin, self.translationBtn.frame.size.width, self.translationBtn.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
        
    }
    else{
        
        self.fitReadingBtn.frame = CGRectMake( leftMargin, screenHeight - self.fitReadingBtn.frame.size.height - bottomMargin, self.fitReadingBtn.frame.size.width, self.fitReadingBtn.frame.size.height);
        self.translationBtn.frame = CGRectMake( leftMargin + self.fitReadingBtn.frame.size.width + interval, screenHeight - self.translationBtn.frame.size.height - bottomMargin, self.translationBtn.frame.size.width, self.translationBtn.frame.size.height);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.fitReadingBtn.frame = CGRectMake( leftMargin, screenHeight, self.fitReadingBtn.frame.size.width, self.fitReadingBtn.frame.size.height);
                             self.translationBtn.frame = CGRectMake( leftMargin + self.fitReadingBtn.frame.size.width + interval, screenHeight, self.translationBtn.frame.size.width, self.translationBtn.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if( YES == finished ){
                                 
                                 [self.fitReadingBtn setHidden:YES];
                                 [self.translationBtn setHidden:YES];
                             }
                             
                         }
         ];
    }
    
    
}

- (void)showNavigationBar:(BOOL)isShow {
    
    if (self.isNavigationBarShow == isShow) {
        return;
    }
    
    self.isNavigationBarShow = isShow;
    
    if (isShow) {
        self.navigationView.alpha = 1.0;
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.navigationView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 49);
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
        
    }
    else {
        
        self.navigationView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 49);
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.navigationView.frame = CGRectMake( 0, -50, self.view.frame.size.width, 49);
                         }
                         completion:^(BOOL finished) {
                             if (YES == finished) {
                                 self.navigationView.alpha = 0;
                             }
                         }
        ];
    }
    
}

- (void)showSwipeIndicator {
    
    self.isNeedShowFlipIndicator = NO;
    
    if (self.bookItem.isLeftFlip) {
        self.rightFlipIndicator.hidden = NO;
        self.rightFlipIndicator.alpha = 0;
        [UIView animateWithDuration:0.5
                              delay:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.rightFlipIndicator.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:1.2
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.rightFlipIndicator.alpha = 0;
                                              }
                                              completion:nil];
                         }
        ];
    } else {
        self.leftFlipIndicator.hidden = NO;
        self.leftFlipIndicator.alpha = 0;
        [UIView animateWithDuration:0.5
                              delay:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.leftFlipIndicator.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:1.2
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.leftFlipIndicator.alpha = 0;
                                              }
                                              completion:nil];
                         }
        ];

    }
    
}


# pragma mark - preload mechanism function

- (NSInteger)getNextPreloadIdx:(NSInteger)currentIdx{
    
    NSInteger nextPreloadIdx = MIN( currentIdx, [self.preloadCompleteMarkArray count] - 1);
    NSInteger preloadCompleteNum = 0;
    
    while( 1 == [[self.preloadCompleteMarkArray objectAtIndex:nextPreloadIdx] integerValue] ){
        nextPreloadIdx ++;
        preloadCompleteNum ++;
        
        if( preloadCompleteNum >= [self.preloadCompleteMarkArray count] ){
            nextPreloadIdx = -1;
            break;
        }
        if( nextPreloadIdx >= [self.preloadCompleteMarkArray count]){
            nextPreloadIdx = 0;
        }
    }
    return nextPreloadIdx;
}

#pragma mark - sandwich view datasource

- (NSString *)thumbnailURLAtIndex:(NSInteger)index {
    
    if (self.bookItem.pageMappingArray) {
        KCBookPage *page = self.bookItem.pageMappingArray[index];
        return page.thumbnailURL;
    }
    
    return nil;
}

- (NSString *)htmlFilePathForItemAtIndex:(NSInteger)index isPreload:(BOOL)isPreload {
    
    NSInteger magazinePageIdx;
    
    // determine left-flip or right-flip
    magazinePageIdx = [self getMagazinePageIndex:index];
    
    if (self.currentMagazineIndex != magazinePageIdx) {
        return nil;
    }
    
    KCBookPage *page = self.bookItem.pageMappingArray[magazinePageIdx];
    
    NSString *filePath = [page.htmlFilePath stringByAppendingPathComponent:@"index.html"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        if (self.currentMagazineIndex == magazinePageIdx) {
            [self showArticlePDFView];
        }
        
        if (self.isNeedShowFlipIndicator) {
            [self showSwipeIndicator];
        }
        
        return filePath;
    }
    
    [[KCService contentManager] getPageHTMLForBookPage:page progress:nil complete:^(NSString *bundleFilePath) {
        
        [self.articlePDFView reloadPageAtIndex:index];
        
    }fail:^(NSError *error) {
        NSLog(@"download HTML file failed:%@",error);
    }];
    
    return nil;
}

#pragma mark - sandwich delegate method

- (NSInteger)numberOfitems {
    
    NSInteger totalPages = 0;
    if (self.bookItem.pageMappingArray) {
        totalPages = [self.bookItem.pageMappingArray count];
    }
    
    return totalPages;
    
}

- (void)articleViewStartMoving {

    [self showNavigationBar:NO];
}

- (void)userSingleTapOnView:(NESandwichView*)view {
    
    [self showNavigationBar:!self.isNavigationBarShow];
    
}

- (void)userStartOperationOnView {
    
    [self showNavigationBar:NO];
    [self updateFitReadingModeStatus];
    
}

- (void)userDoneOperationOnView {
    
    [self showNavigationBar:YES];
    [self updateFitReadingModeStatus];
    
}

- (void)updateDisplayPage:(NSInteger)currentIdx {

    self.currentMagazineIndex  = [self getMagazinePageIndex:currentIdx];
    [self updateFitReadingModeStatus];
    
}

- (void)willDisplayPage:(NSInteger)pageIdx{
    
    //We will update the current magazine index, after initial procedure
    //delegate from willDisplayCell
    if (self.isFlipAnimationDone) {
        NSInteger magazinePageIdx = [self getMagazinePageIndex:pageIdx];
        
        self.currentMagazineIndex = magazinePageIdx;
    }
    
}

# pragma mark - Button handle function
- (IBAction)backBtnPressed:(id)sender {
    
    [self cleanUpArticleViewer];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)tocBtnPressed:(id)sender {
    
    KCBookPage *page = self.bookItem.pageMappingArray[self.currentMagazineIndex];
    KCBookArticle *article = page.articleArray[0];
    
    NSInteger articleIndex = [self.bookItem.articleArray indexOfObject:article];
    
    KEBookLibraryTOCPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"KEBookLibraryTOCPageViewController"];
    
    vc.baseViewController = self;
    
    vc.bookItem = self.bookItem;
    vc.targetArticleIndex = articleIndex;
    vc.targetPageIndex = self.currentMagazineIndex;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)fitReadingBtnPressed:(id)sender {

    [self openFitReadingViewInTranslation:NO];
}

- (IBAction)translationBtnPressed:(id)sender {
    
    [self openFitReadingViewInTranslation:YES];
}

- (void)openFitReadingViewInTranslation:(BOOL)isShowTranslation {
    
    KCBookPage *page = self.bookItem.pageMappingArray[self.currentMagazineIndex];
    
    [self showNavigationBar:NO];
    
    KEArticleSelectionMenuType selectionType = isShowTranslation ? KEArticleSelectionMenuTranslationType : KEArticleSelectionMenuFitReadingType;
    
    if ([self isMultiFitReadingWithPage:self.currentMagazineIndex]) {
        
        if (DEVICE_IS_IPAD) {
            [self showArticleSelectionMenuOniPad:selectionType];
        } else {
            [self showArticleSelectionMenuOniPhone:selectionType];
        }
        
    } else {
        
        KCBookArticle *article = page.articleArray[0];
        //article.showTranslation = isShowTranslation;
        
        [self openArticleFitReadingPage:article];
        
    }
    
}

- (void)openArticleFitReadingPage:(KCBookArticle *)article {
    
    KEArticleFitReadingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"KEArticleFitReadingViewController"];
    __weak KEArticleFitReadingViewController *weakVC = vc;
    vc.articleItem = article;
    vc.bookItem = self.bookItem;
    vc.baseViewController = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navigationController animated:YES completion:^{
        [weakVC.navigationView setAlpha:1.0];
        [weakVC showNavigationBar:YES];
    }];
    
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    KERotationDirection rotateDirection;
    
    if( UIDeviceOrientationLandscapeLeft ==  orientation ){
        rotateDirection = KERotationDirectionLeft;
    }
    else if( UIDeviceOrientationLandscapeRight == orientation ){
        rotateDirection = KERotationDirectionRight;
    }
    else{
        rotateDirection = KERotationDirectionDefault;
    }
    KERotationPresentAnimation *animator = [[KERotationPresentAnimation alloc] initWithDirection:rotateDirection];
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    KERotationDirection rotateDirection;
    
    if( UIDeviceOrientationLandscapeLeft ==  ((KEArticleLandscapeViewController *)dismissed).lastOrientation ){
        rotateDirection = KERotationDirectionRight;
    }
    else if( UIDeviceOrientationLandscapeRight == ((KEArticleLandscapeViewController *)dismissed).lastOrientation ){
        rotateDirection = KERotationDirectionLeft;
    }
    else{
        rotateDirection = KERotationDirectionDefault;
    }
    
    KERotationPresentAnimation *animator = [[KERotationPresentAnimation alloc] initWithDirection:rotateDirection];
    return animator;
    
}

@end
