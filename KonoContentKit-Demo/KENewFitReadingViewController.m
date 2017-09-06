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

@interface KENewFitReadingViewController () <UIScrollViewDelegate,KonoFitreadingViewDelegate, KonoFitreadingViewDatasource,KonoNavigationViewDelegate>

@property (nonatomic, strong) KonoFitreadingView *FitReadingViewer;
@property (nonatomic, strong) KonoNavigationView *navigationView;

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
        [self.FitReadingViewer renderFitreadingArticleFromData:articleData withImageRefPath:nil requireKey:NO];
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

@end
