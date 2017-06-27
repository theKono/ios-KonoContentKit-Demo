//
//  KEArticleSelectionMenuViewController.m
//  Kono
//
//  Created by Kono on 2016/7/11.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleSelectionMenuViewController.h"
#import "KEColor.h"
#import <MZFormSheetController.h>

static NSString *cellIdentifier = @"articleMenuCellIdentifier";

@interface KEArticleSelectionMenuViewController ()


@end

@implementation KEArticleSelectionMenuViewController

@dynamic parentViewController;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self.selectionTable registerNib:[UINib nibWithNibName:@"KEArticleSelectionMenuTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.selectionTable.delegate = self;
    self.selectionTable.dataSource = self;
    
    self.selectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if( DEVICE_IS_IPAD ){
        
        UIBarButtonItem *backBackButton = [[UIBarButtonItem alloc] initWithTitle:@"cancel"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(dismissView)];
        
        self.navigationItem.leftBarButtonItem = backBackButton;
        
        [self.selectionMenuTitle removeFromSuperview];
        [self.selectionTable mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo( self.view.mas_top ).with.offset(0);
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    
    //NSLog(@"article selection menu page dealloc!");
    self.selectionTable.delegate = nil;
    self.selectionTable.dataSource = nil;
    self.parentViewController = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dismissView{
    
    [self dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
}

#pragma mark - article info

- (void)refreshArticleMenuView {
    
    NSString *defaultMenuStr = @"Fit Reading";;
    
    if( DEVICE_IS_IPAD ){
        self.navigationItem.title = [NSString stringWithFormat:defaultMenuStr,[self.articleArray count]];
    }
    else{
        self.selectionMenuTitle.text = [NSString stringWithFormat:defaultMenuStr,[self.articleArray count]];
    }
    
    [self.selectionTable reloadData];
    
}

#pragma mark - tableview Delegate & Data Source Function

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.articleArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowHeight = 0;
    
    if( DEVICE_IS_IPAD ){
        rowHeight = ARTICLE_MENU_ITEM_HEIGHT_IPAD;
    }
    else{
        rowHeight = ARTICLE_MENU_ITEM_HEIGHT;
    }
    
    
    return rowHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    KEArticleSelectionMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    KCBookArticle *article = self.articleArray[indexPath.row];
    cell.selectionMenuArticleTitle.text = article.articleTitle;
    
    [cell.selectionMenuArticleStat setHidden:YES];
    [cell.selectionMenuArticleTitle mas_updateConstraints:^(MASConstraintMaker *make){
        make.top.equalTo( cell.contentView.mas_top ).with.offset(22);
        make.bottom.equalTo( cell.contentView.mas_bottom ).with.offset(-22);
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedArticleItem = self.articleArray[indexPath.row];
    
    __weak KEArticleSelectionMenuViewController* weakSelf = self;
    
    [self dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
        weakSelf.selectionTable.delegate = nil;
        weakSelf.selectionTable.dataSource = nil;

    }];
    
    
}

@end
