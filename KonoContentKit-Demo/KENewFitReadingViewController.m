//
//  KENewFitReadingViewController.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/9/5.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KENewFitReadingViewController.h"
#import "KonoFitreadingView.h"
#import "KonoNavigationView.h"
#import "KEDemoContentManager.h"

@interface KENewFitReadingViewController () <UIScrollViewDelegate,KonoFitreadingViewDelegate, KonoFitreadingViewDatasource,KonoNavigationViewDelegate>

@property (nonatomic, strong) KonoFitreadingView *FitReadingViewer;
@property (nonatomic, strong) KonoNavigationView *navigationView;
@property (nonatomic, strong) KEDemoContentManager *interactionManager;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *previousBtn;

@end

@implementation KENewFitReadingViewController {
    float _previousScrollOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.FitReadingViewer = [[KonoFitreadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    self.FitReadingViewer.actionDelegate = self;
    self.FitReadingViewer.dataSource = self;
    self.FitReadingViewer.scrollView.delegate = self;
    [self.view addSubview:self.FitReadingViewer];
    [self.FitReadingViewer mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.view.mas_left ).with.offset( 0 );
        make.right.equalTo( self.view.mas_right ).with.offset( 0 );
        make.top.equalTo( self.view.mas_top ).with.offset( 0 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( 0 );
        
    }];
    
    self.navigationView = [KonoNavigationView defatulView];
    self.navigationView.delegate = self;
    [self.view addSubview:self.navigationView];
    
    [self initOperateButton];

    
    self.interactionManager = [[KEDemoContentManager alloc] initWithViewer:self.FitReadingViewer];
    
    _previousScrollOffset = 0;
    
    if( self.articleItem.accessKey ) {
        [self fetchArticleText];
    }
    else {
        [self fetchArticleKey];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.navigationView show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init operate button

- (void)initOperateButton{
    
    self.previousBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.previousBtn.tag = KEOperateButtonTypePrevious;
    [self.previousBtn setImage:[UIImage imageNamed:@"btn_demo_previous"] forState:UIControlStateNormal];
    [self.previousBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.previousBtn];
    
    [self.previousBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.view.mas_left ).with.offset( 10 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( -10 );
        
    }];
    
    self.playBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.playBtn.tag = KEOperateButtonTypePlay;
    [self.playBtn setImage:[UIImage imageNamed:@"btn_demo_play"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.previousBtn.mas_right  ).with.offset( 10 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( -10 );
        
    }];
    
    self.stopBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.stopBtn.tag = KEOperateButtonTypeStop;
    [self.stopBtn setImage:[UIImage imageNamed:@"btn_demo_stop"] forState:UIControlStateNormal];
    [self.stopBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopBtn];
    
    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.playBtn.mas_right  ).with.offset( 10 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( -10 );
        
    }];
    
    
    self.nextBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.nextBtn.tag = KEOperateButtonTypeNext;
    [self.nextBtn setImage:[UIImage imageNamed:@"btn_demo_next"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.stopBtn.mas_right ).with.offset( 10 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( -10 );
        
    }];
    
}


- (void)fetchArticleKey {
    
    __weak typeof (self) weakSelf = self;
    
    [[KCService contentManager] getAccessKeyForArticle:self.articleItem complete:^(KCBookArticle *updateArticle) {
        weakSelf.articleItem = updateArticle;
        [weakSelf fetchArticleText];
        
    } fail:^(NSError *error) {
        NSLog(@"fetch article access token error:%@",error);
    }];
    
}

- (void)fetchArticleText {
    
    
    [[KCService contentManager] getArticleTextForArticle:self.articleItem complete:^(NSData *articleData) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:articleData options:kNilOptions error:&error];
        ArticleHTMLInfo* articleHTMLInfo = [KonoViewUtil getHTMLTemplateFromArticleDic:json withCSSFilePath:nil];
        NSURL *bundleFileURL = [NSURL URLWithString:[[KonoViewUtil resourceBundle] bundlePath]];
        [self.FitReadingViewer loadHTMLString:articleHTMLInfo.htmlString baseURL:bundleFileURL];
        self.interactionManager.totalSentenceCount = articleHTMLInfo.totalSentenceCount;
        //[self.FitReadingViewer renderFitreadingArticleFromData:articleData withImageRefPath:nil requireKey:NO];
    } fail:^(NSError *error) {
        NSLog(@"fetch article text data error:%@",error);
    }];
    
    
}

#pragma mark - fit-reading view datasource function 

- (KCBook *)displayBookItem {
    
    return self.bookItem;
}


#pragma mark - fit-reading content view delegate function

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float scrollOffset = scrollView.contentOffset.y;
    
    if( scrollOffset < _previousScrollOffset || 0 >= scrollOffset ){
        [self.navigationView show];
    }
    else{
        [self.navigationView hide];
        
    }
    
    _previousScrollOffset = scrollOffset;
   
}

- (void)userDidClickOnContent {
    
    if( self.navigationView.isDisplay ) {
        [self.navigationView hide];
    }
    else{
        [self.navigationView show];
    }
    
}

#pragma mark - navigation view delegate function

- (void)backBtnPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - webview controlling button function

- (void)buttonAction:(id)sender {
    
    
    switch ([sender tag]) {
        case KEOperateButtonTypeNext:
            [self.interactionManager playNext];
            break;
        case KEOperateButtonTypePlay:
            [self.interactionManager autoPlay];
            break;
        case KEOperateButtonTypeStop:
            [self.interactionManager stop];
            break;
        case KEOperateButtonTypePrevious:
            [self.interactionManager playPrevious];
            break;
        default:
            break;
    }

}

@end
