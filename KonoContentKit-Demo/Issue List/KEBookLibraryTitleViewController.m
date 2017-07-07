//
//  KEBookLibraryTitleViewController.m
//  Kono
//
//  Created by Neo on 4/14/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//
#import "KEArticleViewController.h"
#import "KEBookLibraryTitleViewController.h"
#import "KEColor.h"
#import "KETextUtil.h"

#import <MZFormSheetController.h>
#import <MBProgressHUD.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <Masonry.h>

#define HEIGHT_FOR_CELL 240.0
#define HEIGHT_FOR_CELL_IPAD 402.0
#define WIDTH_FOR_CELL 145.0
#define WIDTH_FOR_CELL_IPAD 290.0

#define CELL_TAG_MUTIPLIER 1000
#define ALERT_OFFSET_DOWNLOAD  2001
#define ALERT_OFFSET_VERIFY_EMAIL 2002

static NSString *cellIdentifier = @"cellIdentifier";

@interface KEBookLibraryTitleViewController () {
    
    NSString *titleDescription;
    NSArray *categoryYearArray;
    NSMutableDictionary *booksDictionary;
    KELibraryTitleHeaderView *titleDescriptionView;
    
}

@end

@implementation KEBookLibraryTitleViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [self.showcaseTableView registerNib:[UINib nibWithNibName:@"KELibraryBookCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.showcaseTableView.scDatasource = self;
    self.showcaseTableView.scDelegate = self;
    self.showcaseTableView.tableView.dataSource = self.showcaseTableView;
    self.showcaseTableView.tableView.delegate = self.showcaseTableView;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KELibraryTitleHeaderView" owner:nil options:nil];
    
    if( DEVICE_IS_IPAD ){
        titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:1];
    }
    else{
        titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:0];
    }
    
    booksDictionary = [[NSMutableDictionary alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __weak KEBookLibraryTitleViewController *weakSelf = self;
    [self getTitleInformation];
    
    [[KCService contentManager] getAllYearsContainBooksForTitleID:KonoContentKitDemoMagazine complete:^(NSArray *yearArray) {
        
        categoryYearArray = [NSMutableArray arrayWithArray:yearArray];
        
        for( NSDictionary* titleYear in yearArray ) {
            
            NSString *year;
            year = [[titleYear objectForKey:@"year"] stringValue];

            NSMutableArray *booksArray = [booksDictionary objectForKey:[[titleYear objectForKey:@"year"] stringValue]];
            
            if( booksArray == nil ){
                
                [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
                    
                    [booksDictionary setObject:bookArray forKey:year];
                    
                } fail:^(NSError *error) {
                    
                }];
                
            }
            
        }
        
        [weakSelf.showcaseTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    } fail:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]
                                            removeObserver:self
                                                      name:@"KEBookTitleFollowed"
                                                    object:nil];
    self.showcaseTableView.scDatasource = nil;
    self.showcaseTableView.scDelegate = nil;
    self.showcaseTableView.tableView.delegate = nil;
    self.showcaseTableView.tableView.dataSource = nil;
    
}

- (void)getTitleInformation{
    
    [[KCService contentManager] getTitleInfoForTitleID:KonoContentKitDemoMagazine complete:^(NSDictionary *titleInfo) {
        
        titleDescription = titleInfo[@"description"];
        self.navigationItem.title = titleInfo[@"name"];
        [self loadTitleHeaderView];
        
    } fail:^(NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
}

- (void)loadTitleHeaderView{
    
    NSAttributedString *attString;
    
    titleDescriptionView.titleDescription.text = titleDescription;
    titleDescriptionView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.000];
    titleDescriptionView.delegate = self;
    
    
    if( DEVICE_IS_IPAD ){
        attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:16 withLineSpacing:8.0  withText:titleDescription ];
        
        
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.showcaseTableView.frame.size.width - 208, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        titleDescriptionView.titleDescription.numberOfLines = 0;
        titleDescriptionView.titleDescription.attributedText = attString;
        
        /* default we keep bottom 20px padding*/
        [titleDescriptionView.titleDescription mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.height.equalTo( @( ceilf(size.height) ) );
            
        }];
        CGRect newFrame = titleDescriptionView.frame;
        newFrame.size.height = MAX( ceilf(size.height) + 60 , 100 );
        titleDescriptionView.frame = newFrame;
        
        self.showcaseTableView.tableView.tableHeaderView = titleDescriptionView;
    }
    else {
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat descriptionMargin = 15;
        CGFloat descriptionFieldWidth = screen.bounds.size.width - 2 * descriptionMargin;
        
        attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:14 withText:titleDescription ];
        
        CGSize size = [attString boundingRectWithSize:CGSizeMake(descriptionFieldWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        titleDescriptionView.titleDescription.attributedText = attString;

        if (floor(size.height) <= titleDescriptionView.titleDescription.frame.size.height) {
            titleDescriptionView.showDescriptionBtn.alpha = 0;
            
            [titleDescriptionView.showDescriptionBtn removeFromSuperview];
            
            CGRect newFrame = titleDescriptionView.frame;
            newFrame.size.height = newFrame.size.height - 33;
            titleDescriptionView.frame = newFrame;
            
            self.showcaseTableView.tableView.tableHeaderView = titleDescriptionView;
            
        }
        else {
            titleDescriptionView.showDescriptionBtn.alpha = 1;
            self.showcaseTableView.tableView.tableHeaderView = titleDescriptionView;
        }
    }
   
}


- (NSInteger)numberOfSectionInShowcaseView:(KEShowcaseTableView *)showcaseView{
    
    return [categoryYearArray count];
}

- (NSInteger)showcaseView:(KEShowcaseTableView *)showcaseView numberOfItemsForSection:(NSInteger)section{
    
    NSString *year = [[NSString alloc]initWithString:[[[categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [booksDictionary objectForKey:year];
    
    
    return [bookArr count];
    
}

- (NSString *)showcaseView:(KEShowcaseTableView *)shoecaseView titleForSection:(NSInteger)section{
    
    return [[[categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue];
}

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForHeaderInSection:(NSInteger)section{
    if(DEVICE_IS_IPAD){
        return 53.0;
    }else{
        return 34.0;
    }
}

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForFooterInSection:(NSInteger)section {
    if(DEVICE_IS_IPAD){
        return 20;
    }else{
        return 7;
    }
}

- (UIView *)showcaseView:(KEShowcaseTableView *)showcaseView viewForHeaderInSection:(NSInteger)section {
    CGFloat sectionHeight = [self showcaseView:self.showcaseTableView heightForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, sectionHeight)];
    
    CGFloat labelFrameX = 12.0;
    CGFloat labelFrameY = 14.0;
    CGFloat fontSize = 14.0;
    if( DEVICE_IS_IPAD ){
        labelFrameX = 26.0;
        labelFrameY = 20.0;
        fontSize = 18.0;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelFrameX, labelFrameY, self.view.frame.size.width, fontSize)];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = [self showcaseView:self.showcaseTableView titleForSection:section];
    label.textColor = [KEColor konoGrayPressed];
    label.backgroundColor = [UIColor clearColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [KEColor konoSeperatorGray];
    [headerView addSubview:lineView];
    
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForRowAtSection:(NSInteger)section{
    if(DEVICE_IS_IPAD){
        return HEIGHT_FOR_CELL_IPAD;
    }else{
        return HEIGHT_FOR_CELL;
    }
}

- (void)showcaseView:(KEShowcaseTableView *)showcaseView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *year = [[NSString alloc] initWithString:[[[categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [booksDictionary objectForKey:year];
    KCBook *bookItem = [bookArr objectAtIndex:indexPath.row];
    
    KEArticleViewController *articleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KEArticleViewController"];
    articleViewController.hidesBottomBarWhenPushed = YES;
    articleViewController.bookItem = bookItem;
    
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (UIView *)showcaseViewInCell:(KEShowcaseTableViewCell *)showcaseCell viewForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KELibraryBookCell *cell = (KELibraryBookCell*)[showcaseCell dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *year = [[NSString alloc]initWithString:[[[categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [booksDictionary objectForKey:year];
    
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
    cell.tag = CELL_TAG_MUTIPLIER*indexPath.section + indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.coverImageView.image = nil;
    cell.issueLabel.text = book.issue;
    
    if (YES == book.isHasAudio || YES == book.isHasVideo) {
        cell.mediaTag.alpha = 1.0;
    }
    else{
        cell.mediaTag.alpha = 0.0;
    }

    
    if (YES == book.isNew) {
        cell.tagBackgroundView.alpha = 1.0;
        cell.firstTag.alpha = 1.0;
        cell.secondTag.alpha = 0.0;
        
        [cell setupTagImage:KEIssueCoverTagTypeNew];
    }
    else {
        cell.tagBackgroundView.alpha = 0.0;
        cell.firstTag.alpha = 0.0;
        cell.secondTag.alpha = 0.0;
    }
    
    return cell;
    
}

- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplayCell:(UITableViewCell *)cell willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KELibraryBookCell *displayCell = (KELibraryBookCell *)cell;
    
    NSString *year = [[NSString alloc]initWithString:[[[categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    NSArray *bookArr = [booksDictionary objectForKey:year];
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
    [displayCell.coverImageView pin_setImageFromURL:[NSURL URLWithString:book.coverImageMedium]];
    
}

- (CGFloat)widthForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if( DEVICE_IS_IPAD ){
        return WIDTH_FOR_CELL_IPAD;
    }else{
        return WIDTH_FOR_CELL;        
    }

}


- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplaySection:(NSInteger)section {
    
    NSString *year = [[NSString alloc]initWithString:[[[categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue]];
    NSMutableArray *booksArray;

    booksArray = [booksDictionary objectForKey:year];

    if( booksArray == nil ) {
        
        __weak KEBookLibraryTitleViewController *weakSelf = self;
        
        [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
            
            [booksDictionary setObject:bookArray forKey:year];
            [weakSelf.showcaseTableView reloadData];
            
        } fail:^(NSError *error) {
            
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - header view delegate

- (void)showDescriptionBtnPressed:(BOOL)wantExpendView {
    
    NSAttributedString *attString;
    
    attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:14 withText:titleDescription];
    
    CGSize size = [attString boundingRectWithSize:CGSizeMake(titleDescriptionView.titleDescription.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (wantExpendView) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect newFrame = titleDescriptionView.frame;
                             newFrame.size.height = newFrame.size.height + ceilf(size.height - 62.f);
                             titleDescriptionView.frame = newFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             CGRect newFrame = titleDescriptionView.titleDescription.frame;
                             newFrame.size.height = ceilf(size.height);
                             titleDescriptionView.titleDescription.frame = newFrame;
                             
                             [titleDescriptionView.titleDescription setNumberOfLines:0];
                         }];
        
    } else {
        
        CGRect newFrame = titleDescriptionView.titleDescription.frame;
        newFrame.size.height = 62;
        titleDescriptionView.titleDescription.frame = newFrame;
        
        [titleDescriptionView.titleDescription setNumberOfLines:3];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect newFrame = titleDescriptionView.frame;
                             newFrame.size.height = newFrame.size.height - ceilf(size.height - 62.f);
                             titleDescriptionView.frame = newFrame;
                         }];
        
    }

    self.showcaseTableView.tableView.tableHeaderView = titleDescriptionView;

    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.showcaseTableView.tableView layoutIfNeeded];
                     }];

}

@end
