//
//  KonoViewerDemoViewController.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/9/5.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KonoViewerDemoViewController.h"
#import "KENewArticleViewController.h"
#import "KENewFitReadingViewController.h"
#import <MBProgressHUD.h>

@interface KonoViewerDemoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *bookIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *articleIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPDFBtn;
@property (weak, nonatomic) IBOutlet UIButton *showFitReadingBtn;

@property (strong, nonatomic) NSString *demoBookID;
@property (strong, nonatomic) NSString *demoArticleID;
@end

@implementation KonoViewerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Viewer Demo";
    self.demoBookID = @"57d0e7ef48ebf";
    self.demoArticleID = @"0fd6f0f3-1ac6-4d8d-8dda-432fcb5283de";
    self.bookIDTextField.text = self.demoBookID;
    self.articleIDTextField.text = self.demoArticleID;
    
    // Make the textField readonly temporary
    [self.bookIDTextField setUserInteractionEnabled:NO];
    [self.articleIDTextField setUserInteractionEnabled:NO];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)showPDFView:(id)sender {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KCService contentManager] getBookForBookID:self.bookIDTextField.text complete:^(KCBook *bookItem) {
        
            [[KCService contentManager] getAllArticlesForBook:bookItem complete:^(KCBook *book) {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                KENewArticleViewController *articleViewController = [KENewArticleViewController new];
                articleViewController.bookItem = book;
                articleViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:articleViewController animated:YES];
                
            } fail:^(NSError *error) {
                NSLog(@"error");
            }];
        
    } fail:^(NSError *error) {
        NSLog(@"get demo book error:%@",error);
    }];
    

    
}
- (IBAction)showFitReadingView:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KCService contentManager] getArticleForArticleID:self.articleIDTextField.text complete:^(KCBookArticle *articleItem) {
    
        [[KCService contentManager] getBookForBookID:articleItem.bookID complete:^(KCBook *bookItem) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            KENewFitReadingViewController *articleViewController = [KENewFitReadingViewController new];
            articleViewController.bookItem = bookItem;
            articleViewController.articleItem = articleItem;
            articleViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:articleViewController animated:YES];
            
        } fail:^(NSError *error) {
            
        }];
        
        
    } fail:^(NSError *error) {
        NSLog(@"error");
    }];
    
    
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
