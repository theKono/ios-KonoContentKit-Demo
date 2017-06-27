//
//  KEArticleLandscapeViewController.m
//  Kono
//
//  Created by kuokuo on 2016/12/8.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleLandscapeViewController.h"
#import "KEBookLibraryItemCell.h"
#import <MBProgressHUD.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

static NSString *contentCellIdentifier = @"contentCellIdentifier";
static NSString *thumbnailCellIdentifier = @"thumbnailCellIdentifier";
static NSInteger NUM_PRELOAD_SCREEN = 3;
static NSInteger LEFT_CORRECT_BTN_TAG = 100;
static NSInteger RIGHT_CORRECT_BTN_TAG = 101;
static NSInteger LEFT_PREVIEW_THUMBNAIL_TAG = 1000;
static NSInteger RIGHT_PREVIEW_THUMBNAIL_TAG = 1001;
static NSInteger ISO_PREVIEW_THUMBNAIL_TAG = 1002;
static double FADEIN_DELAY_BASE = 0.45;
static double FADEIN_DELAY_STEP = 0.15;


@interface KELandscapePageScreen : NSObject

@property (nonatomic) NSInteger firstPageIdx;
@property (nonatomic) NSInteger secondPageIdx;
@property (nonatomic) KELandscapePageStatus firstPageStatus;
@property (nonatomic) KELandscapePageStatus secondPageStatus;
@property (nonatomic) KELandscapePlacement screenPagePlacement;

@end

@implementation KELandscapePageScreen

- (id)initWithBookItem:(KCBook *)bookItem{
    
    self = [super init];
    if( self ){
        self.firstPageIdx = [bookItem.pageMappingArray count];
        self.secondPageIdx = [bookItem.pageMappingArray count];
        self.firstPageStatus = KELandscapePageStatusUnknown;
        self.secondPageStatus = KELandscapePageStatusUnknown;
        self.screenPagePlacement = KELandscapePlacementTwoPages;
    }
    return self;
}


@end


@interface KEArticleLandscapeViewController ()

@property (nonatomic, strong) NSMutableDictionary *webviewDictionary;

@end

@implementation KEArticleLandscapeViewController

#pragma mark - viewcontroller operate function

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    UICollectionViewFlowLayout *colFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    colFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    colFlowLayout.itemSize = CGSizeMake( screenHeight, screenWidth );
    colFlowLayout.minimumLineSpacing = 0;

    [self.landscapeViewer setCollectionViewLayout:colFlowLayout];
    [self.landscapeViewer setPagingEnabled:YES];
    [self.landscapeViewer setDelegate:self];
    [self.landscapeViewer setDataSource:self];
    [self.landscapeViewer setBackgroundColor:[UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0]];
    [self.landscapeViewer registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:contentCellIdentifier];

    
    self.actionBackgroundView = [self createActionBackgroundView];
    [self.view addSubview:self.actionBackgroundView];
    
    self.panelView = [self createPanelView];
    [self.view addSubview:self.panelView];
    
    self.thumbnailListView = [self createThumbnailListView];
    self.leftCorrectBtn = [self createCorrectBtnWithImage:@"btn_revise_landscape_left"];
    self.leftCorrectBtn.tag = LEFT_CORRECT_BTN_TAG;
    
    self.rightCorrectBtn = [self createCorrectBtnWithImage:@"btn_revise_landscape_right"];
    self.rightCorrectBtn.tag = RIGHT_CORRECT_BTN_TAG;

    [self.panelView addSubview:self.thumbnailListView];
    [self.panelView addSubview:self.leftCorrectBtn];
    [self.panelView addSubview:self.rightCorrectBtn];
    
    
    [self initGesture];
    [self initProperty];
    [self initWebviewDic];
    [self parsePageMergeArray];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(didRotate:)
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter]
                                            addObserver:self
                                               selector:@selector(pageReload:)
                                                   name:@"KEPageDownloadStatusChange"
                                                 object:nil];
    
    [self customizeLayout];
    
    
    self.isWebviewInsideButtonActing = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if( [self isPortrait] ){
        [self cleanLandscapeViewer];
        return;
    }
    
    
    
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    if ([self.bookItem.pageMappingArray count] > self.basePageIndex && !self.hasInitialized) {
        
        NSInteger targetScreenIndex = [self getScreenIndexWithPageIndex:self.basePageIndex isEvenPageFirst:self.isEvenPageAsFirstPage];
        self.currentScreenIndex = targetScreenIndex;
        
        [self.landscapeViewer scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self parseIndexByFlipDirectionWithIndex:targetScreenIndex] inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.hasInitialized = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    @catch (NSException *exception) {} @finally {}
    
}

- (BOOL)isPortrait{
    
    BOOL isScreenPortrait = NO;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if ( UIDeviceOrientationPortrait == orientation ){
        isScreenPortrait = YES;
    }
    if( UIDeviceOrientationPortraitUpsideDown != orientation ){
        self.lastOrientation = orientation;
    }
    
    return isScreenPortrait;
}

- (void)customizeLayout{
    
    [self.view setBackgroundColor:[UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0]];
    
    CGFloat thumbnailCellHeight;
    
    if( DEVICE_IS_IPAD ){
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL_IPAD;
    }
    else{
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL;
    }
    
    [self.thumbnailListView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.leading.equalTo(self.panelView.mas_leading).with.offset(0);
        make.trailing.equalTo(self.panelView.mas_trailing).with.offset(0);
        make.top.equalTo( self.panelView.mas_top).with.offset(0);
        make.height.equalTo( @(thumbnailCellHeight) );
        make.width.equalTo( @(self.panelView.frame.size.width) );
    }];
    
    [self.leftCorrectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo( self.panelView.mas_centerX ).with.offset( -0.5 * (self.leftCorrectBtn.frame.size.width) - 5 );
        make.bottom.equalTo( self.panelView.mas_bottom ).with.offset(-10);
        
    }];
    
    [self.rightCorrectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo( self.panelView.mas_centerX ).with.offset( 0.5 * (self.leftCorrectBtn.frame.size.width) + 5 );
        make.bottom.equalTo(self.panelView.mas_bottom).with.offset(-10);
        
    }];
    
    [self.actionBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.leading.equalTo(self.view.mas_leading).with.offset(0);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(0);
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        
    }];
    
    self.leftFlipIndicator.alpha = 0;
    self.rightFlipIndicator.alpha = 0;

}

#pragma mark - dealloc related function

- (void)cleanLandscapeViewer{
    
    [self postCurrentPageInfo];
    [self removeDelegate];
    [[self presentingViewController]  dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)removeDelegate{
    
    for( UITapGestureRecognizer *recognizer in self.actionBackgroundView.gestureRecognizers ){
        [self.actionBackgroundView removeGestureRecognizer:recognizer];
    }
    for( UITapGestureRecognizer *recognizer in self.landscapeViewer.gestureRecognizers ){
        [self.landscapeViewer removeGestureRecognizer:recognizer];
    }
    
    [self.webviewDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if( DEVICE_IS_IOS9_OR_LATER ){
            ((KEPageWebView *)obj).pageDelegate = nil;
            ((KEPageWebView *)obj).scrollView.delegate = nil;
        }
        else{
            ((KEFatPageWebView *)obj).pageDelegate = nil;
            ((KEFatPageWebView *)obj).scrollView.delegate = nil;
        }
    }];
    
    [self.webviewDictionary removeAllObjects];
    
    
    self.landscapeViewer.delegate = nil;
    self.landscapeViewer.dataSource = nil;
    self.thumbnailListView.delegate = nil;
    self.thumbnailListView.dataSource = nil;
    [self.thumbnailListView removeFromSuperview];
    
}


- (void)dealloc{
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {} @finally {}
    
}

#pragma mark - subview creation

- (UIView* )createActionBackgroundView{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    [backgroundView setHidden:YES];
    
    return backgroundView;
}

- (UIView *)createPanelView{
    
    CGFloat thumbnailCellHeight, correctBtnHeight,panelHeight;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if( DEVICE_IS_IPAD ){
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL_IPAD;
        correctBtnHeight = HEIGHT_FOR_CORRECT_AREA_IPAD;
    }
    else{
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL;
        correctBtnHeight = HEIGHT_FOR_CORRECT_AREA;
    }
    panelHeight = thumbnailCellHeight + correctBtnHeight;

    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake( 0 , screenWidth, screenHeight, panelHeight )];
    panelView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    panelView.alpha = 1;
    
    return panelView;
    
}

- (UIButton *)createCorrectBtnWithImage:(NSString *)imageName{
    
    UIButton *correctBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 272, 44)];
    NSString *pressedImageName = [imageName stringByAppendingString:@"_pressed"];
    NSString *disableImageName = [imageName stringByAppendingString:@"_disable"];
    
    [correctBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [correctBtn setBackgroundImage:[UIImage imageNamed:pressedImageName] forState:UIControlStateHighlighted];
    [correctBtn setBackgroundImage:[UIImage imageNamed:disableImageName] forState:UIControlStateDisabled];
    [correctBtn addTarget:self action:@selector(correctBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return correctBtn;
}

- (KEPageWebView*)createWebView{
    
    // Disable the long press copy menu bar
    NSString *source = @"var style = document.createElement('style'); \
    style.type = 'text/css'; \
    style.innerText = '*:not(input):not(textarea) { -webkit-user-select: none; -webkit-touch-callout: none; }'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(style);";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    // Create the user content controller and add the script to it
    WKUserContentController *userContentController = [WKUserContentController new];
    [userContentController addUserScript:script];
    
    // Create the configuration with the user content controller
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat frameWidth = MAX(screen.bounds.size.height,screen.bounds.size.width);
    CGFloat frameHeight = MIN(screen.bounds.size.height,screen.bounds.size.width);
    
    KEPageWebView *webview = [[KEPageWebView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight) configuration:configuration];
    webview.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0];
    webview.pageDelegate = self;
    webview.scrollView.delegate = self;
    webview.scrollView.bounces = NO;
    
    return webview;
}

- (KEFatPageWebView*)createFatWebView{
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat frameWidth = MAX(screen.bounds.size.height,screen.bounds.size.width);
    CGFloat frameHeight = MIN(screen.bounds.size.height,screen.bounds.size.width);
    
    KEFatPageWebView *webview = [[KEFatPageWebView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, frameHeight)];
    webview.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0];
    webview.pageDelegate = self;
    webview.scalesPageToFit = YES;
    webview.scrollView.delegate = self;
    webview.scrollView.bounces = NO;
    
    return webview;

}

- (UICollectionView *)createThumbnailListView{
    
    CGFloat thumbnailCellHeight, thumbnailCellWidth;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    if( DEVICE_IS_IPAD ){
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL_IPAD;
        thumbnailCellWidth = WIDTH_FOR_THUMNAILLIST_CELL_IPAD;
    }
    else{
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL;
        thumbnailCellWidth = WIDTH_FOR_THUMNAILLIST_CELL;
    }
    
    
    UICollectionView *thumbnailListView;
    UICollectionViewFlowLayout *colFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    colFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    colFlowLayout.itemSize = CGSizeMake( thumbnailCellWidth, thumbnailCellHeight );
    colFlowLayout.minimumLineSpacing = 0;

    thumbnailListView = [[UICollectionView alloc] initWithFrame:CGRectMake( 0 , 0 ,screenHeight, thumbnailCellHeight ) collectionViewLayout:colFlowLayout];
    
    [thumbnailListView setDataSource:self];
    [thumbnailListView setDelegate:self];
    
    [thumbnailListView registerNib:[UINib nibWithNibName:@"KEBookLibraryItemCell" bundle:nil] forCellWithReuseIdentifier:thumbnailCellIdentifier];
    [thumbnailListView setBackgroundColor:[UIColor clearColor]];
    
    return thumbnailListView;
}


# pragma mark - init function

- (void)initProperty{
    
    self.basePageIndex = MIN( self.basePageIndex, [self.bookItem.pageMappingArray count] - 1 );
    
    self.hasInitialized = NO;
    self.isWebviewInsideButtonActing = NO;
    self.articleLockedSet = [[NSMutableSet alloc] init];
    self.webviewFadeinDelay = [self optimizeDelayTimeByDevice];
    self.isEvenPageAsFirstPage = YES;
    self.isNeedToShowFlipIndicator = YES;
    
}

- (void)initGesture{
    
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delaysTouchesBegan = YES;
    [self.actionBackgroundView addGestureRecognizer:tapGesture];
    
}

- (void)initWebviewDic{
    
    self.webviewDictionary = [[NSMutableDictionary alloc] init];
    
    for( int idx = 0 ; idx < NUM_PRELOAD_SCREEN ; idx++ ){
     
        if( DEVICE_IS_IOS9_OR_LATER ){
            KEPageWebView *webview = [self createWebView];
            [self.webviewDictionary setObject:webview forKey:[NSString stringWithFormat:@"%d",idx]];
        }
        else{
            KEFatPageWebView *webview = [self createFatWebView];
            [self.webviewDictionary setObject:webview forKey:[NSString stringWithFormat:@"%d",idx]];
        }
    }
}

- (void)parsePageMergeArray{
    
    self.oddFirstMergePageArray = [[NSMutableArray alloc] init];
    self.evenFirstMergePageArray = [[NSMutableArray alloc] init];
    
    NSInteger NOT_EXIST_PAGE = [self.bookItem.pageMappingArray count];
    
    if ( 0 < [self.bookItem.pageMappingArray count] ) {
        
        NSInteger oddPageParsingTmpIdx = NOT_EXIST_PAGE;
        NSInteger evenPageParsingTmpIdx = NOT_EXIST_PAGE;
        
        for (int i = 0 ; i < [self.bookItem.pageMappingArray count] ; i++) {
            
            KCBookPage *currentPageInfo = self.bookItem.pageMappingArray[i];
            
            if ( currentPageInfo.pageNumber % 2 == 1 ) {
                
                // Encounter two odd page number continuously placed in current magazine
                if ( oddPageParsingTmpIdx != NOT_EXIST_PAGE ) {
                    KELandscapePageScreen *oddFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
                    oddFirstScreen.firstPageIdx = oddPageParsingTmpIdx;
                    oddFirstScreen.screenPagePlacement = KELandscapePlacementISO;
                    [self.oddFirstMergePageArray addObject:oddFirstScreen];
                }
                
                // Odd first parsing part
                oddPageParsingTmpIdx = i;
                
                // Even first parsing part
                KELandscapePageScreen *evenFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
                evenFirstScreen.firstPageIdx = evenPageParsingTmpIdx;
                evenFirstScreen.secondPageIdx = i;
                evenFirstScreen.screenPagePlacement = KELandscapePlacementTwoPages;
                [self.evenFirstMergePageArray addObject:evenFirstScreen];
                evenPageParsingTmpIdx = NOT_EXIST_PAGE;
                
            } else {
                
                // Encounter two even page number continuously placed in current magazine
                if ( evenPageParsingTmpIdx != NOT_EXIST_PAGE ) {
                    KELandscapePageScreen *evenFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
                    evenFirstScreen.firstPageIdx = evenPageParsingTmpIdx;
                    evenFirstScreen.screenPagePlacement = KELandscapePlacementISO;
                    [self.evenFirstMergePageArray addObject:evenFirstScreen];
                }
                
                // Even first parsing part
                evenPageParsingTmpIdx = i;
                
                // Odd first parsing part
                KELandscapePageScreen *oddFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
                oddFirstScreen.firstPageIdx = oddPageParsingTmpIdx;
                oddFirstScreen.secondPageIdx = i;
                oddFirstScreen.screenPagePlacement = KELandscapePlacementTwoPages;
                [self.oddFirstMergePageArray addObject:oddFirstScreen];
                oddPageParsingTmpIdx = NOT_EXIST_PAGE;
                
            }
        }
        
        if ( oddPageParsingTmpIdx != NOT_EXIST_PAGE ) {
            KELandscapePageScreen *oddFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
            oddFirstScreen.firstPageIdx = oddPageParsingTmpIdx;
            oddFirstScreen.screenPagePlacement = KELandscapePlacementISO;
            [self.oddFirstMergePageArray addObject:oddFirstScreen];
        }
        
        if ( evenPageParsingTmpIdx != NOT_EXIST_PAGE ) {
            KELandscapePageScreen *evenFirstScreen = [[KELandscapePageScreen alloc] initWithBookItem:self.bookItem];
            evenFirstScreen.firstPageIdx = evenPageParsingTmpIdx;
            evenFirstScreen.screenPagePlacement = KELandscapePlacementISO;
            [self.evenFirstMergePageArray addObject:evenFirstScreen];
        }
    }
}


# pragma mark - webview dictionary operation function

- (void)clearWebview{
    
    [self.webviewDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if( DEVICE_IS_IOS9_OR_LATER ){
            ((KEPageWebView *)obj).cacheKey = nil;
        }
        else{
            ((KEFatPageWebView *)obj).cacheKey = nil;
        }
    }];
    [self.evenFirstMergePageArray removeAllObjects];
    [self.oddFirstMergePageArray removeAllObjects];
    [self parsePageMergeArray];
    
}

- (KEPageWebView *)getWebviewWithIndex:(NSInteger)index{
    
    return [self.webviewDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)(index % NUM_PRELOAD_SCREEN)]];
    
}

- (KEFatPageWebView *)getFatWebviewWithIndex:(NSInteger)index{
    
    return [self.webviewDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)(index % NUM_PRELOAD_SCREEN)]];
}

# pragma mark - index handling function

- (NSInteger)getScreenIndexWithPageIndex:(NSInteger)pageIndex isEvenPageFirst:(BOOL)isEvenPageFirst{
    
    NSInteger screenIndex = 0;
    if( YES == isEvenPageFirst ){
        
        if( [self.bookItem.pageMappingArray count] == pageIndex ){
            screenIndex = [self.evenFirstMergePageArray count];
        }
        else{
            for( int i=0 ; i<[self.evenFirstMergePageArray count] ; i++ ){
                KELandscapePageScreen *iterScreen = self.evenFirstMergePageArray[i];
                if( pageIndex == iterScreen.firstPageIdx || pageIndex == iterScreen.secondPageIdx ){
                    screenIndex = i;
                    break;
                }
            }
        }
    }
    else{
        
        if( [self.bookItem.pageMappingArray count] == pageIndex ){
            screenIndex = [self.oddFirstMergePageArray count];
        }
        else{
            for( int i=0 ; i<[self.oddFirstMergePageArray count] ; i++ ){
                KELandscapePageScreen *iterScreen = self.oddFirstMergePageArray[i];
                if( pageIndex == iterScreen.firstPageIdx || pageIndex == iterScreen.secondPageIdx ){
                    screenIndex = i;
                    break;
                }
            }
        }
    }
    return screenIndex;
}

- (NSInteger)getMagazinePageIndex:(NSInteger)index {
    
    NSInteger magazineIdx = 0;
    
    if (self.bookItem.pageMappingArray.count > 0) {
        
        if (!self.bookItem.isLeftFlip) {
            magazineIdx = self.bookItem.pageMappingArray.count - index - 1;
        }
        else {
            magazineIdx = index;
        }
    }
    
    return magazineIdx;
}

- (NSInteger)parseIndexByFlipDirectionWithIndex:(NSInteger)index{
    
    NSInteger viewerIndex = 0;
    
    NSArray *currentScreenArray;
    
    if (self.isEvenPageAsFirstPage) {
        
        currentScreenArray = self.evenFirstMergePageArray;
    }
    else {
        currentScreenArray = self.oddFirstMergePageArray;
    }
    
    if ([currentScreenArray count] > 0) {
        
        if (!self.bookItem.isLeftFlip) {
            viewerIndex = [currentScreenArray count] - index - 1;
        }
        else {
            viewerIndex = index;
        }
    }
    
    return viewerIndex;
    
}

#pragma mark - notification handle function

- (void)didRotate:(NSNotification *)notification{
    
    if( [self isPortrait] ){
        [self cleanLandscapeViewer];
    }
    
}

- (void)pageReload:(NSNotification*)notification{
    
    NSDictionary *receiveInfo = [notification userInfo];
    KCBookArticle *articleItem = [receiveInfo objectForKey:@"article"];
    NSInteger indexOffset = [[receiveInfo objectForKey:@"pageIndex"] integerValue];
    
    NSInteger articleIndex = [self.bookItem.articleArray indexOfObject:articleItem];
    NSInteger downloadCompleteIdx = articleIndex + indexOffset;
    NSInteger screenIdx = [self getScreenIndexWithPageIndex:downloadCompleteIdx isEvenPageFirst:self.isEvenPageAsFirstPage];

    if( [self.articleLockedSet containsObject:@( downloadCompleteIdx )] ){
        
        if( screenIdx == self.currentScreenIndex ){
            [self showContentWithScreenIndex:screenIdx isPreload:NO];
        }
        [self.articleLockedSet removeObject:@( downloadCompleteIdx )];
    }
    
}


#pragma mark - gesture handle function

-(void)handleTap:(UITapGestureRecognizer *)gesture {
    
    [self displayPanelView:NO];
    [self.actionBackgroundView setHidden:YES];
    
}

#pragma mark - viewer data source related function

- (void)loadThumbnailBackgroundForScreenIndex:(NSInteger)screenIndex withLeftImageView:(UIImageViewAligned *)leftImage withRightImageView:(UIImageViewAligned *)rightImage withISOImageView:(UIImageViewAligned *)isoImage {
    
    KELandscapePageScreen *displayScreen = [self getScreenWithIndex:screenIndex];
    KCBookPage *leftPageInfo, *rightPageInfo, *isoPageInfo;
    
    if (displayScreen.firstPageIdx >= [self.bookItem.pageMappingArray count] || displayScreen.secondPageIdx >= [self.bookItem.pageMappingArray count]) {
        
        leftImage.alpha = 0;
        rightImage.alpha = 0;
        isoImage.alpha = 1;
        
        isoPageInfo = [self.bookItem.pageMappingArray objectAtIndex:MIN(displayScreen.firstPageIdx, displayScreen.secondPageIdx)];
        isoImage.image = nil;
        [isoImage pin_setImageFromURL:[NSURL URLWithString:isoPageInfo.thumbnailURL]];
        [MBProgressHUD showHUDAddedTo:isoImage animated:YES];
        
    }
    else{
        leftImage.alpha = 1;
        rightImage.alpha = 1;
        isoImage.alpha = 0;
        
        if (self.bookItem.isLeftFlip) {
            
            leftPageInfo = [self.bookItem.pageMappingArray objectAtIndex:displayScreen.firstPageIdx];
            rightPageInfo = [self.bookItem.pageMappingArray objectAtIndex:displayScreen.secondPageIdx];
            
        }
        else {
            leftPageInfo = [self.bookItem.pageMappingArray objectAtIndex:displayScreen.secondPageIdx];
            rightPageInfo = [self.bookItem.pageMappingArray objectAtIndex:displayScreen.firstPageIdx];
        }
        
        leftImage.image = nil;
        rightImage.image = nil;
        [leftImage pin_setImageFromURL:[NSURL URLWithString:leftPageInfo.thumbnailURL]];
        [rightImage pin_setImageFromURL:[NSURL URLWithString:rightPageInfo.thumbnailURL]];
        [MBProgressHUD showHUDAddedTo:leftImage animated:YES];
        [MBProgressHUD showHUDAddedTo:rightImage animated:YES];
    }
    
}


- (KELandscapePageScreen *)getScreenWithIndex:(NSInteger)screenIndex{
    
    KELandscapePageScreen *screenObj;
    
    if( YES == self.isEvenPageAsFirstPage ){
        screenObj = [self.evenFirstMergePageArray objectAtIndex:screenIndex];
    }
    else{
        screenObj = [self.oddFirstMergePageArray objectAtIndex:screenIndex];
    }
    
    return screenObj;
}

- (void)updateCorrectBtnStatus{
    
    self.rightCorrectBtn.enabled = YES;
    self.leftCorrectBtn.enabled = YES;
    
    NSInteger overlapLeftPageIndex,overlapRightPageIndex, targetLeftScreenIndex, targetRightScreenIndex;
    
    KELandscapePageScreen *oldScreen = [self getScreenWithIndex:self.currentScreenIndex];
    KELandscapePageScreen *checkLeftScreen, *checkRightScreen;
    
    checkLeftScreen = nil;
    checkRightScreen = nil;
    
    //Left correct button
    if (self.bookItem.isLeftFlip) {
        overlapLeftPageIndex = oldScreen.firstPageIdx;
    }
    else{
        overlapLeftPageIndex = oldScreen.secondPageIdx;
    }
    
    //Right correct button
    if (self.bookItem.isLeftFlip) {
        overlapRightPageIndex = oldScreen.secondPageIdx;
    }
    else{
        overlapRightPageIndex = oldScreen.firstPageIdx;
    }
    
    
    targetLeftScreenIndex = [self getScreenIndexWithPageIndex:overlapLeftPageIndex isEvenPageFirst:!self.isEvenPageAsFirstPage ];
    targetRightScreenIndex = [self getScreenIndexWithPageIndex:overlapRightPageIndex isEvenPageFirst:!self.isEvenPageAsFirstPage];
    
    if( YES == self.isEvenPageAsFirstPage ){
        if( [self.oddFirstMergePageArray count] > targetLeftScreenIndex ){
            checkLeftScreen = [self.oddFirstMergePageArray objectAtIndex:targetLeftScreenIndex];
        }
        
        if( [self.oddFirstMergePageArray count] > targetRightScreenIndex ){
            checkRightScreen = [self.oddFirstMergePageArray objectAtIndex:targetRightScreenIndex];
        }
    }
    else{
        
        if( [self.evenFirstMergePageArray count] > targetLeftScreenIndex ){
            checkLeftScreen = [self.evenFirstMergePageArray objectAtIndex:targetLeftScreenIndex];
        }
        
        if( [self.evenFirstMergePageArray count] > targetRightScreenIndex ){
            checkRightScreen = [self.evenFirstMergePageArray objectAtIndex:targetRightScreenIndex];
        }
    }
    
    if( nil == checkLeftScreen ){
        [self.leftCorrectBtn setEnabled:NO];
    }
    else{
        if (checkLeftScreen.firstPageIdx >= [self.bookItem.pageMappingArray count] || checkLeftScreen.secondPageIdx >= [self.bookItem.pageMappingArray count]) {
            [self.leftCorrectBtn setEnabled:NO];
        }
    }
    
    if( nil == checkRightScreen ){
        [self.rightCorrectBtn setEnabled:NO];
    }
    else{
        if (checkRightScreen.firstPageIdx >= [self.bookItem.pageMappingArray count] || checkRightScreen.secondPageIdx >= [self.bookItem.pageMappingArray count]) {
            [self.rightCorrectBtn setEnabled:NO];
        }
    }
}

- (void)showContentWithScreenIndex:(NSInteger)index isPreload:(BOOL)isPreload{
    
    KELandscapePageScreen *currentScreen;
    NSString *mergeHTMLFilePath;
    
    currentScreen = [self getScreenWithIndex:index];
    
    if( KELandscapePageStatusUnknown == currentScreen.firstPageStatus ){
        [self getDisplayFileWithMagazineIndex:currentScreen.firstPageIdx isFirstPage:YES forScreenIdx:index isPreload:isPreload];
    }
    if( KELandscapePageStatusUnknown == currentScreen.secondPageStatus ){
        [self getDisplayFileWithMagazineIndex:currentScreen.secondPageIdx isFirstPage:NO forScreenIdx:index isPreload:isPreload];
    }
    
    mergeHTMLFilePath = [self getMergeFilePathWithScreen:currentScreen isPreload:isPreload];
    
    if( nil != mergeHTMLFilePath ){
        if( DEVICE_IS_IOS9_OR_LATER ){
            KEPageWebView *webview = [self getWebviewWithIndex:index];
            [self loadHTMLFileWithWebview:webview withHTMLFilePath:mergeHTMLFilePath];
            
        }
        else{
            KEFatPageWebView *webview = [self getFatWebviewWithIndex:index];
            [self loadHTMLFileWithFatWebview:webview withHTMLFilePath:mergeHTMLFilePath];
        }
    }

}

- (void)getDisplayFileWithMagazineIndex:(NSInteger)targetPageIdx isFirstPage:(BOOL)isFirstPage forScreenIdx:(NSInteger)screenIndex isPreload:(BOOL)isPreload{
    
    KELandscapePageScreen *displayScreen;
    
    displayScreen = [self getScreenWithIndex:screenIndex];
    
    if (targetPageIdx >= [self.bookItem.pageMappingArray count]) {
        if( YES == isFirstPage ){
            displayScreen.firstPageStatus = KELandscapePageStatusEmpty;
        }
        else{
            displayScreen.secondPageStatus = KELandscapePageStatusEmpty;
        }
        return;
    }
    
    
    KCBookPage *magSinglePageInfo = [self.bookItem.pageMappingArray objectAtIndex:targetPageIdx];
    NSString *targetFilePath = [magSinglePageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
    
    if ([KEUtil fileExistsAtPath:targetFilePath]) {
        if (isFirstPage) {
            displayScreen.firstPageStatus = KELandscapePageStatusDownloaded;
        }
        else {
            displayScreen.secondPageStatus = KELandscapePageStatusDownloaded;
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        
        [[KCService contentManager] getPageHTMLForBookPage:magSinglePageInfo progress:nil complete:^(NSString *indexHTMLPath) {
            
            // check the complete item is the same as current item
            if( [targetFilePath isEqualToString:indexHTMLPath] ){
                if( YES == isFirstPage ){
                    displayScreen.firstPageStatus = KELandscapePageStatusDownloaded;
                }
                else{
                    displayScreen.secondPageStatus = KELandscapePageStatusDownloaded;
                }
                [weakSelf showContentWithScreenIndex:screenIndex isPreload:isPreload];
            }
            
        } fail:^(NSError *error) {
            
            NSLog(@"getPageHTMLForBookPage fail:%@", error);
            
//            if( KEArticleErrorStatusCodeAccessKeyNull == statusCode ){
//                if( YES == isFirstPage ){
//                    displayScreen.firstPageStatus = KELandscapePageStatusUnauthorized;
//                }
//                else{
//                    displayScreen.secondPageStatus = KELandscapePageStatusUnauthorized;
//                }
//                [weakSelf showContentWithScreenIndex:screenIndex isPreload:isPreload];
//                
//            }
//            else if( statusCode == KEArticleErrorStatusCodeDownloadError || statusCode == KEArticleErrorStatusCodeBadFile ){
//                
//                
//                [KEUtil showGlobalMessage:LocalizedString(@"global_error_fetch_data")];
//            }
//            else if( statusCode ==  KEArticleErrorStatusCodeDownloadLock ){
//                [weakSelf.articleLockedSet addObject:@(targetPageIdx)];
//            }
//            else{
//                if( statusCode ==  KEArticleErrorStatusCodeUserTokenExpired ){
//                    [KEUtil showGlobalMessage:LocalizedString(@"login_require_msg_expired")];
//                }
//                else if( statusCode == KEArticleErrorStatusCodeNullResult ){
//                    [KEUtil showGlobalMessage:LocalizedString(@"global_error_network")];
//                    
//                }
//            }
            
        }];
    }
}

- (NSString*)getMergeFilePathWithScreen:(KELandscapePageScreen *)screen isPreload:(BOOL)isPreload{
    
    NSString *leftFilePath, *rightFilePath, *isoFilePath, *leftRatio, *rightRatio, *isoRatio;
    BOOL isDisableLeftPage = YES, isDisableRightPage = YES,isDisableISOPage = YES;
    NSInteger leftPageIndex,rightPageIndex;
    KELandscapePageDisplayMode screenDisplayMode;
    
    NSString *mergeFilePath;
    KCBookPage *leftPageInfo;
    KCBookPage *rightPageInfo;
    
    NSArray *allArticlesArray;
    NSArray *uniqueArticleArray;
    
    if( screen.firstPageStatus == KELandscapePageStatusUnknown ||
        screen.firstPageStatus == KELandscapePageStatusRequesting ||
        screen.secondPageStatus == KELandscapePageStatusUnknown ||
        screen.secondPageStatus == KELandscapePageStatusRequesting ){
        
        return nil;
    }
    if (self.bookItem.isLeftFlip) {
        leftPageIndex = screen.firstPageIdx;
        rightPageIndex = screen.secondPageIdx;
        if( [self.bookItem.pageMappingArray count] <= screen.firstPageIdx ){
            screen.screenPagePlacement = KELandscapePlacementISORight;
        }
        else if( [self.bookItem.pageMappingArray count] <= screen.secondPageIdx ){
            screen.screenPagePlacement = KELandscapePlacementISOLeft;
        }
    }
    else {
        leftPageIndex = screen.secondPageIdx;
        rightPageIndex = screen.firstPageIdx;
        if( [self.bookItem.pageMappingArray count] <= screen.firstPageIdx ){
            screen.screenPagePlacement = KELandscapePlacementISOLeft;
        }
        else if( [self.bookItem.pageMappingArray count] <= screen.secondPageIdx ){
            screen.screenPagePlacement = KELandscapePlacementISORight;
        }
    }
    screenDisplayMode = [self parseDisplayModeWithScreen:screen];
    
    if( KELandscapePlacementTwoPages == screen.screenPagePlacement ){
        leftPageInfo = [self.bookItem.pageMappingArray objectAtIndex:leftPageIndex];
        rightPageInfo = [self.bookItem.pageMappingArray objectAtIndex:rightPageIndex];
        
        //set default file path is thumbnail image
        leftFilePath = leftPageInfo.thumbnailURL;
        rightFilePath = rightPageInfo.thumbnailURL;
        
        leftRatio = @"100%";
        rightRatio = @"100%";
        
        switch( screenDisplayMode ){
            case KELandscapePageDisplayModeNone:{
                NSLog(@"display full screen purchase view");
                break;
            }
            case KELandscapePageDisplayModeLeftOnly:{
                NSLog(@"display purcahse view only on the right page");
                leftFilePath = [leftPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
                allArticlesArray = [NSArray arrayWithArray:leftPageInfo.articleArray];

                leftRatio = [KEUtil getPDFPageRatio:leftFilePath];
                isDisableLeftPage = NO;
                break;
            }
            case KELandscapePageDisplayModeRightOnly:{
                NSLog(@"display purchase view only on the left page");
                rightFilePath = [rightPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
                allArticlesArray = [NSArray arrayWithArray:rightPageInfo.articleArray];
                
                rightRatio = [KEUtil getPDFPageRatio:rightFilePath];
                isDisableRightPage = NO;
                break;
            }
            case KELandscapePageDisplayModeBoth:{
                leftFilePath = [leftPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
                rightFilePath = [rightPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
                
                allArticlesArray = [leftPageInfo.articleArray arrayByAddingObjectsFromArray:rightPageInfo.articleArray];
                leftRatio = [KEUtil getPDFPageRatio:leftFilePath];
                rightRatio = [KEUtil getPDFPageRatio:rightFilePath];
                isDisableLeftPage = NO;
                isDisableRightPage = NO;
                break;
            }
            default:
                break;
        }

        mergeFilePath = [KEUtil getLandscapeHTML:self.bookItem.bookID
                                    leftFilePath:leftFilePath
                                   withLeftRatio:leftRatio
                                 disableLeftPage:isDisableLeftPage
                                   rightFilePath:rightFilePath
                                  withRightRatio:rightRatio
                                disableRightPage:isDisableRightPage
                                     ISOFilePath:@""
                                    withISORatio:@"100%"
                                  disableISOPage:NO
                                       isISOMode:NO];
    }
    else if( KELandscapePlacementISORight == screen.screenPagePlacement ){
        
        rightPageInfo = [self.bookItem.pageMappingArray objectAtIndex:rightPageIndex];
        if( screenDisplayMode & KELandscapePageDisplayModeRightOnly ){
            isDisableISOPage = NO;
            isoFilePath = [rightPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
            isoRatio = [KEUtil getPDFPageRatio:isoFilePath];
            allArticlesArray = [NSArray arrayWithArray:rightPageInfo.articleArray];
        }
        else{
            isoFilePath = rightPageInfo.thumbnailURL;
            isoRatio = @"100%";
        }
        
        mergeFilePath = [KEUtil getLandscapeHTML:self.bookItem.bookID
                                    leftFilePath:isoFilePath
                                   withLeftRatio:isoRatio
                                 disableLeftPage:isDisableISOPage
                                   rightFilePath:isoFilePath
                                  withRightRatio:isoRatio
                                disableRightPage:isDisableISOPage
                                     ISOFilePath:isoFilePath
                                    withISORatio:isoRatio
                                  disableISOPage:isDisableISOPage
                                       isISOMode:YES];
        
    }
    else if( KELandscapePlacementISOLeft == screen.screenPagePlacement ){
        
        leftPageInfo = [self.bookItem.pageMappingArray objectAtIndex:leftPageIndex];
        if( screenDisplayMode & KELandscapePageDisplayModeLeftOnly ){
            isDisableISOPage = NO;
            isoFilePath = [leftPageInfo.htmlFilePath stringByAppendingPathComponent:@"index.html"];
            isoRatio = [KEUtil getPDFPageRatio:isoFilePath];
            allArticlesArray = [NSArray arrayWithArray:leftPageInfo.articleArray];
        }
        else{
            isoFilePath = leftPageInfo.thumbnailURL;
            isoRatio = @"100%";
        }
        
        mergeFilePath = [KEUtil getLandscapeHTML:self.bookItem.bookID
                                    leftFilePath:isoFilePath
                                   withLeftRatio:isoRatio
                                 disableLeftPage:isDisableISOPage
                                   rightFilePath:isoFilePath
                                  withRightRatio:isoRatio
                                disableRightPage:isDisableISOPage
                                     ISOFilePath:isoFilePath
                                    withISORatio:isoRatio
                                  disableISOPage:isDisableISOPage
                                       isISOMode:YES];
    }
    
    return mergeFilePath;
}

- (KELandscapePageDisplayMode)parseDisplayModeWithScreen:(KELandscapePageScreen *)screen {
    
    KELandscapePageDisplayMode screenDisplayMode = KELandscapePageDisplayModeNone;
    if (self.bookItem.isLeftFlip) {
        
        if( KELandscapePageStatusDownloaded == screen.firstPageStatus ){
            screenDisplayMode |= KELandscapePageDisplayModeLeftOnly;
        }
        if( KELandscapePageStatusDownloaded == screen.secondPageStatus ){
            screenDisplayMode |= KELandscapePageDisplayModeRightOnly;
        }
    }
    else {
        if( KELandscapePageStatusDownloaded == screen.firstPageStatus ){
            screenDisplayMode |= KELandscapePageDisplayModeRightOnly;
        }
        if( KELandscapePageStatusDownloaded == screen.secondPageStatus ){
            screenDisplayMode |= KELandscapePageDisplayModeLeftOnly;
        }
        
    }
    return screenDisplayMode;
}

- (void)loadHTMLFileWithWebview:(KEPageWebView *)webview withHTMLFilePath:(NSString *)mergeFilePath{
    
    if( [mergeFilePath isEqualToString:webview.cacheKey] ){
        
        webview.alpha = 1;
        return;
    }
    
    
    webview.alpha = 0;
    webview.cacheKey = nil;
    
    [webview stopLoading];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];

    
    NSURL *url = [NSURL fileURLWithPath:mergeFilePath];
    NSString *directory = [mergeFilePath stringByDeletingLastPathComponent];
    NSURL *dir_url = [NSURL fileURLWithPath:directory isDirectory:YES];
    
    __weak KEPageWebView *weakOperator = webview;
    __weak typeof (self) weakSelf = self;

    [webview loadFileURL:url allowingReadAccessToURL:dir_url withComplete:^{
        weakOperator.isReadyToShow = YES;
        
        [weakSelf fadeInWithView:weakOperator withDelay:self.webviewFadeinDelay];
        [weakSelf stopLoadingView];
        weakOperator.cacheKey = mergeFilePath;

    } withFail:^(NSError *error) {
        NSLog(@"fail :%@" , error );
    }];

}

- (void)loadHTMLFileWithFatWebview:(KEFatPageWebView *)webview withHTMLFilePath:(NSString *)mergeFilePath{
    
    if( [mergeFilePath isEqualToString:webview.cacheKey] ){
        webview.alpha = 1;
        return;
    }
    
    
    webview.alpha = 0;
    webview.cacheKey = nil;
    
    [webview stopLoading];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    NSURL *url = [NSURL fileURLWithPath:mergeFilePath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    
    __weak KEFatPageWebView *weakOperator = webview;
    __weak typeof(self) weakSelf = self;
    
    [webview loadRequest:request withComplete:^{
        weakOperator.isReadyToShow = YES;
        [weakSelf fadeInWithView:weakOperator withDelay:0.3];
        [weakSelf stopLoadingView];
        
        weakOperator.cacheKey = mergeFilePath;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];

    }withFail:^(NSError *error) {
        NSLog(@"fail :%@" , error );
    }];

    
}

# pragma mark - animation related function

- (NSTimeInterval)optimizeDelayTimeByDevice{
    
    NSTimeInterval optimizeDelayTime = FADEIN_DELAY_BASE;
    NSString *deviceName = [[[KEUtil getDeviceName] componentsSeparatedByString:@","]firstObject];
    NSInteger deviceGeneration = [[deviceName substringFromIndex:[deviceName length]-1] integerValue];
    
    NSInteger baseGeneration = 8;
    NSInteger iPadGenerationGap = 2;
    
        
    if( [deviceName hasPrefix:@"iPad"] ){
        deviceGeneration += iPadGenerationGap;
        FADEIN_DELAY_STEP = 0.2;
        
    }
    deviceGeneration = MIN( deviceGeneration, baseGeneration);
    optimizeDelayTime += (baseGeneration - deviceGeneration) * FADEIN_DELAY_STEP;
        
    return optimizeDelayTime;
}

- (void)displayPanelView:(BOOL)isNeedToShow {
    
    CGFloat thumbnailCellHeight,correctBtnHeight,panelHeight;

    if( DEVICE_IS_IPAD ){
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL_IPAD;
        correctBtnHeight = HEIGHT_FOR_CORRECT_AREA_IPAD;
    }
    else{
        thumbnailCellHeight = HEIGHT_FOR_THUMNAILLIST_CELL;
        correctBtnHeight = HEIGHT_FOR_CORRECT_AREA;
    }
    panelHeight = thumbnailCellHeight + correctBtnHeight;
    
    CGRect hideFrame = CGRectMake( 0 , self.view.frame.size.height ,self.view.frame.size.width, panelHeight );
    ;
    CGRect showFrame = CGRectMake( 0 , self.view.frame.size.height - panelHeight ,self.view.frame.size.width, panelHeight );
    
    CGRect targetFrame;
    
    if( YES == isNeedToShow ){
        self.panelView.frame = hideFrame;
        targetFrame = showFrame;
    }
    else{
        self.panelView.frame = showFrame;
        targetFrame = hideFrame;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.panelView.frame = targetFrame;
                     }
                     completion:^(BOOL finished) {
                         self.panelView.frame = targetFrame;
                     }
     ];
    
}

- (void)fadeInWithView:(UIView *)view withDelay:(NSTimeInterval)delayTime{
    
    [UIView animateWithDuration:0.3
                          delay:delayTime
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         view.alpha = 1.0;
                     }
     ];
    
}

- (void)showSwipeIndicator{
    
    if (self.basePageIndex >= [self.bookItem.pageMappingArray count] - 1) {
        return;
    }
    if (self.isNeedToShowFlipIndicator) {
        self.isNeedToShowFlipIndicator = NO;
        if (self.bookItem.isLeftFlip) {
            [self.rightFlipIndicator setHidden:NO];
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
                                                  completion:^(BOOL finished) {
                                                      self.rightFlipIndicator.alpha = 0;
                                                  }
                                  ];
                                 
                             }
             ];
            
            
        }
        else {
            [self.leftFlipIndicator setHidden:NO];
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
                                                  completion:^(BOOL finished) {
                                                      self.leftFlipIndicator.alpha = 0;
                                                  }
                                  ];
                                 
                             }
             ];
            
        }
    }
    
}

- (void)slideToCurrentPageThumbnail{
    
    [self.thumbnailListView reloadData];
    [self.thumbnailListView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self getMagazinePageIndex:self.basePageIndex] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
}

- (void)stopLoadingView{
    
    for( UICollectionViewCell *cell in [self.landscapeViewer visibleCells] ){
        
        UIImageViewAligned *leftThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:LEFT_PREVIEW_THUMBNAIL_TAG];
        UIImageViewAligned *rightThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:RIGHT_PREVIEW_THUMBNAIL_TAG];
        UIImageViewAligned *isoThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:ISO_PREVIEW_THUMBNAIL_TAG];
        
        [MBProgressHUD hideAllHUDsForView:leftThumbNailImage animated:YES];
        [MBProgressHUD hideAllHUDsForView:rightThumbNailImage animated:YES];
        [MBProgressHUD hideAllHUDsForView:isoThumbNailImage animated:YES];
        
    }
}


# pragma mark - page action related function

- (void)postCurrentPageInfo{
    
    NSIndexPath *magazineIdxPath = [NSIndexPath indexPathForRow:self.basePageIndex inSection:0];
    KCBookPage *magSinglePageInfo = [self.bookItem.pageMappingArray objectAtIndex:magazineIdxPath.row];
    KCBookArticle *item = [magSinglePageInfo.articleArray objectAtIndex:0];
    
    
    NSDictionary *clickArticleInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                      item,@"article",
                                      magazineIdxPath,@"pageIndexPath",
                                      self.baseViewController,@"baseViewController",
                                      @(YES),@"isThumbnailClick",
                                      nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEMagazinePageChange" object:nil userInfo:clickArticleInfo];
}


#pragma mark - btn handle function
- (void)correctBtnPressed:(id)sender{
    
    UIButton *clickBtn = (UIButton *)sender;
    NSInteger overlapPageIndex, newScreenIndex;
    
    KELandscapePageScreen *oldScreen = [self getScreenWithIndex:self.currentScreenIndex];
    overlapPageIndex = self.basePageIndex;
    
    self.isEvenPageAsFirstPage ^= YES;
    
    if( clickBtn.tag == LEFT_CORRECT_BTN_TAG ){
        if (self.bookItem.isLeftFlip) {
            overlapPageIndex = oldScreen.firstPageIdx;
        }
        else{
            overlapPageIndex = oldScreen.secondPageIdx;
        }
    }
    else if( clickBtn.tag == RIGHT_CORRECT_BTN_TAG ){
        if (self.bookItem.isLeftFlip) {
            overlapPageIndex = oldScreen.secondPageIdx;
        }
        else{
            overlapPageIndex = oldScreen.firstPageIdx;
        }
    }
    newScreenIndex = [self getScreenIndexWithPageIndex:overlapPageIndex isEvenPageFirst:self.isEvenPageAsFirstPage];
    
    [self displayPanelView:NO];
    [self.actionBackgroundView setHidden:YES];
    
    self.currentScreenIndex = newScreenIndex;
    self.isNeedToShowFlipIndicator = YES;
    [self.landscapeViewer reloadData];
    [self.landscapeViewer scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self parseIndexByFlipDirectionWithIndex:newScreenIndex] inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}


#pragma mark - collection view data source & delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger itemNum = 1;
    
    if( self.landscapeViewer == collectionView ){
        if( self.isEvenPageAsFirstPage ){
            itemNum = [self.evenFirstMergePageArray count];
        }
        else{
            itemNum = [self.oddFirstMergePageArray count];
        }
    }
    else if( self.thumbnailListView ==  collectionView ){
        itemNum = [self.bookItem.pageMappingArray count];
    }
    
    return itemNum;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if( self.landscapeViewer == collectionView ){

        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:contentCellIdentifier forIndexPath:indexPath];
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat frameWidth = screen.bounds.size.width;
        CGFloat frameHeight = screen.bounds.size.height;
        
        UIImageViewAligned *leftThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:LEFT_PREVIEW_THUMBNAIL_TAG];
        if( nil == leftThumbNailImage ){
            leftThumbNailImage = [[UIImageViewAligned alloc]initWithFrame:CGRectMake(0, 0, frameWidth / 2, frameHeight)];
            leftThumbNailImage.tag = LEFT_PREVIEW_THUMBNAIL_TAG;
            leftThumbNailImage.contentMode = UIViewContentModeScaleAspectFit;
            leftThumbNailImage.alignRight = YES;
            [cell.contentView addSubview:leftThumbNailImage];
            [leftThumbNailImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo( @(frameWidth/2 ) );
                make.centerY.equalTo( cell.mas_centerY );
                make.leading.equalTo( cell.mas_leading ).with.offset(0);
                make.top.equalTo( cell.mas_top ).with.offset(0);
            }];
             
        }
        
        UIImageViewAligned *rightThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:RIGHT_PREVIEW_THUMBNAIL_TAG];
        if( nil == rightThumbNailImage ){
            rightThumbNailImage = [[UIImageViewAligned alloc]initWithFrame:CGRectMake(frameWidth / 2, 0, frameWidth / 2, frameHeight)];
            rightThumbNailImage.tag = RIGHT_PREVIEW_THUMBNAIL_TAG;
            rightThumbNailImage.contentMode = UIViewContentModeScaleAspectFit;
            rightThumbNailImage.alignLeft = YES;
            [cell.contentView addSubview:rightThumbNailImage];
            [rightThumbNailImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo( @(frameWidth/2 ) );
                make.centerY.equalTo( cell.mas_centerY );
                make.trailing.equalTo( cell.mas_trailing ).with.offset(0);
                make.top.equalTo( cell.mas_top ).with.offset(0);
            }];
        }
        UIImageViewAligned *isoThumbNailImage = (UIImageViewAligned *)[cell viewWithTag:ISO_PREVIEW_THUMBNAIL_TAG];
        if( nil == isoThumbNailImage ){
            isoThumbNailImage = [[UIImageViewAligned alloc]initWithFrame:CGRectMake(0, 0, frameWidth / 2, frameHeight)];
            isoThumbNailImage.tag = ISO_PREVIEW_THUMBNAIL_TAG;
            isoThumbNailImage.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:isoThumbNailImage];
            [isoThumbNailImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo( @(frameWidth/2 ) );
                make.height.equalTo( @(frameHeight) );
                make.centerY.equalTo( cell.mas_centerY );
                make.centerX.equalTo( cell.mas_centerX );
            }];
        }
        
        [self loadThumbnailBackgroundForScreenIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row] withLeftImageView:leftThumbNailImage withRightImageView:rightThumbNailImage withISOImageView:isoThumbNailImage];
        
        for( UIView *view in cell.contentView.subviews ){
            if( [view isKindOfClass:[KEPageWebView class]] || [view isKindOfClass:[KEFatPageWebView class]]){
                [view removeFromSuperview];
            }
        }
        if( DEVICE_IS_IOS9_OR_LATER ){
            KEPageWebView *webview = [self getWebviewWithIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row]];
            [cell.contentView addSubview:webview];
            webview.alpha = 0;
            
            
            [webview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo( webview.superview.mas_top ).with.offset(0);
                make.bottom.equalTo( webview.superview.mas_bottom).with.offset(0);
                make.leading.equalTo( webview.superview.mas_leading ).with.offset(0);
                make.trailing.equalTo( webview.superview.mas_trailing ).with.offset(0);
            }];
            
        }
        else{
            KEFatPageWebView *webview = [self getFatWebviewWithIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row]];
            [cell.contentView addSubview:webview];
            webview.alpha = 0;
          
            [webview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo( webview.superview.mas_top ).with.offset(0);
                make.bottom.equalTo( webview.superview.mas_bottom).with.offset(0);
                make.leading.equalTo( webview.superview.mas_leading ).with.offset(0);
                make.trailing.equalTo( webview.superview.mas_trailing ).with.offset(0);
            }];
        }
        [self showContentWithScreenIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row] isPreload:NO];
        return cell;

    }
    else{
        KEBookLibraryItemCell *cell = (KEBookLibraryItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:thumbnailCellIdentifier forIndexPath:indexPath];
        
        KCBookPage *pageInfo = [self.bookItem.pageMappingArray objectAtIndex:[self getMagazinePageIndex:indexPath.row]];
        
        
        cell.itemImage.image = nil;
        cell.itemImage.contentMode = UIViewContentModeScaleAspectFill;
        
        [cell.itemImage pin_setImageFromURL:[NSURL URLWithString:pageInfo.thumbnailURL]];
        
        [cell.currentPageIndicator setHidden:YES];
        KELandscapePageScreen *currentScreen = [self getScreenWithIndex:self.currentScreenIndex];
        NSInteger leftPageIndex,rightPageIndex;
        if (self.bookItem.isLeftFlip) {
            leftPageIndex = currentScreen.firstPageIdx;
            rightPageIndex = currentScreen.secondPageIdx;
        }
        else {
            leftPageIndex = currentScreen.secondPageIdx;
            rightPageIndex = currentScreen.firstPageIdx;
        }
        
        if (leftPageIndex == [self getMagazinePageIndex:indexPath.row]) {
            cell.itemBackgroundView.image = nil;
            cell.itemBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.itemBackgroundView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(4.0, 4.0)];
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.view.bounds;
            maskLayer.path  = maskPath.CGPath;
            cell.itemBackgroundView.layer.mask = maskLayer;
            
        }
        else if (rightPageIndex == [self getMagazinePageIndex:indexPath.row]) {
            cell.itemBackgroundView.image = nil;
            cell.itemBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.itemBackgroundView.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadii:CGSizeMake(4.0, 4.0)];
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.view.bounds;
            maskLayer.path  = maskPath.CGPath;
            cell.itemBackgroundView.layer.mask = maskLayer;
            
        }
        else {
            cell.itemBackgroundView.image = [UIImage imageNamed:@"background_issue_list_book"];
            cell.itemBackgroundView.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets collectionViewInset;
    if( self.thumbnailListView == collectionView ){
        collectionViewInset = UIEdgeInsetsMake(0, 8, 0, 0);
    }
    else{
        collectionViewInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    
    return collectionViewInset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if( self.thumbnailListView == collectionView ){
        NSInteger selectedPageIdx = [self getMagazinePageIndex:indexPath.row];
        
        if( selectedPageIdx != self.basePageIndex ){
            self.basePageIndex = MIN( selectedPageIdx, [self.bookItem.pageMappingArray count] - 1 );
            self.isNeedToShowFlipIndicator = YES;
            NSInteger screenIdx = [self getScreenIndexWithPageIndex:selectedPageIdx isEvenPageFirst:self.isEvenPageAsFirstPage];
            self.currentScreenIndex = screenIdx;
            [self.landscapeViewer scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self parseIndexByFlipDirectionWithIndex:screenIdx] inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            [self postCurrentPageInfo];
        }
        
        [self displayPanelView:NO];
        [self.actionBackgroundView setHidden:YES];
    }

}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if( self.landscapeViewer == collectionView ){
        
        [self showSwipeIndicator];
        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if( self.landscapeViewer == collectionView ){
        if( DEVICE_IS_IOS9_OR_LATER ){
            KEPageWebView *webview = [self getWebviewWithIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row]];
            [webview setContentFitScreenSize];
        }
        else{
            KEFatPageWebView *webView = [self getFatWebviewWithIndex:[self parseIndexByFlipDirectionWithIndex:indexPath.row]];
            [webView.scrollView setZoomScale:1.0];
        }
    }
    
}

#pragma mark - scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if( self.landscapeViewer == scrollView ){
        CGFloat pageWidth = self.landscapeViewer.frame.size.width;
        int currentScrollviewIndex = (int)( self.landscapeViewer.contentOffset.x / pageWidth + 0.5 );
        
        self.currentScreenIndex = [self parseIndexByFlipDirectionWithIndex:currentScrollviewIndex];
        
        KELandscapePageScreen *currentScreen = [self getScreenWithIndex:self.currentScreenIndex];
        
        if( currentScreen.firstPageIdx != self.basePageIndex && currentScreen.secondPageIdx != self.basePageIndex ){
            self.basePageIndex = MIN( currentScreen.firstPageIdx , currentScreen.secondPageIdx );
        }
    }
    
}


#pragma mark - ios9 webview delegate
- (void)userDidSingleTapOnView:(KEPageWebView *)view{
    
    if( view.scrollView.zoomScale <= 1.0  && NO == self.isWebviewInsideButtonActing ){
    
        [self updateCorrectBtnStatus];
        [self slideToCurrentPageThumbnail];
        [self displayPanelView:YES];
        
        [self.actionBackgroundView setHidden:NO];
    }
    
}

- (void)userDidDoubleTapOnView:(KEPageWebView*)view{
    
    [view setContentFitScreenSize];
    
}

- (void)userClickInViewWithURL:(NSURL *)url{
    
    if ([url.scheme isEqualToString:@"kono"] ){
        
    }
    else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - older webview delegate

- (BOOL)webView:(KEFatPageWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if( navigationType == UIWebViewNavigationTypeLinkClicked ){
        
        if ([request.URL.scheme isEqualToString:@"kono"] ){
            
        }
        else{
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
    
    return YES;
}

- (void)userDidSingleTapOnFatView:(KEFatPageWebView*)view{
    
    CGFloat actualZoomScale = 1.0 / view.scrollView.minimumZoomScale;
    if( actualZoomScale <= 1.0 && NO == self.isWebviewInsideButtonActing ){
        
        [self updateCorrectBtnStatus];
        [self slideToCurrentPageThumbnail];
        [self displayPanelView:YES];
        
        [self.actionBackgroundView setHidden:NO];
    }
}

#pragma mark - out of memory handle function

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
