//
//  KENewArticleViewController.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/8/7.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KENewArticleViewController.h"
#import "KonoPDFView.h"
#import "KonoFitreadingView.h"

@interface KENewArticleViewController () <KonoPDFViewDelegate,KonoPDFViewDatasource>

@property (nonatomic, strong) KonoPDFView *PDFViewer;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.PDFViewer initViewContainer];
    
}

#pragma mark - PDF Viewer datasource delegate

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
