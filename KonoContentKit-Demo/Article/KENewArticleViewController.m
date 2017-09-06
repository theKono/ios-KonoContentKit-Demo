//
//  KENewArticleViewController.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/8/7.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KENewArticleViewController.h"
#import "KonoPDFView.h"
#import "KonoNavigationView.h"

@interface KENewArticleViewController () <KonoPDFViewDelegate,KonoPDFViewDatasource, KonoNavigationViewDelegate>

@property (nonatomic, strong) KonoPDFView *PDFViewer;
@property (nonatomic, strong) KonoNavigationView *navigationView;

@end

@implementation KENewArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.PDFViewer = [[KonoPDFView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    self.PDFViewer.dataSource = self;
    self.PDFViewer.delegate = self;
    [self.view addSubview:self.PDFViewer];
    [self.PDFViewer mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo( self.view.mas_left ).with.offset( 0 );
        make.right.equalTo( self.view.mas_right ).with.offset( 0 );
        make.top.equalTo( self.view.mas_top ).with.offset( 0 );
        make.bottom.equalTo( self.view.mas_bottom ).with.offset( 0 );
        
    }];
    
    self.navigationView = [KonoNavigationView defatulView];
    self.navigationView.delegate = self;
    [self.view addSubview:self.navigationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.navigationView show];
    [self.PDFViewer initViewContainerAtPageIdx:0];
    
}

#pragma mark - PDF Viewer datasource delegate

- (BOOL)isLeftFlip {
    return self.bookItem.isLeftFlip;
}


- (NSInteger)numberOfPages {
    
    return [self.bookItem.pageMappingArray count];
}

- (NSString *)htmlFilePathForItemAtIndex:(NSInteger)index isPreload:(BOOL)isPreload {
    
    KCBookPage *page = [self.bookItem.pageMappingArray objectAtIndex:index];
    NSString *indexFilePath = [page.htmlFilePath stringByAppendingPathComponent:@"index.html"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:indexFilePath]) {
        return page.htmlFilePath;
    }
    else {
        [[KCService contentManager] getPageHTMLForBookPage:page progress:nil complete:^(NSString *htmlDirPath){
            
            if (!isPreload) {
                [self.PDFViewer reloadPageIndex:index withFilePath:htmlDirPath];
            }
        }fail:^(NSError *error) {}];
    }
    return nil;
}

#pragma mark - PDF view delegate function

- (void)PDFViewStartMoving {
    [self.navigationView hide];
}

- (void)PDFViewTapped {
    
    if( self.navigationView.isDisplay ) {
        [self.navigationView hide];
    }
    else {
        [self.navigationView show];
    }
    
}

- (void)PDFViewZoomin {
    
    [self.navigationView hide];
    
}

- (void)PDFViewZoomReset {
    
    [self.navigationView show];
    
}


#pragma mark - navigation view delegate function

- (void)backBtnPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
