//
//  KEBookLibraryTitleViewController.m
//  Kono
//
//  Created by Neo on 4/14/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEBookLibraryTitleViewController.h"
#import "KEColor.h"
#import "KETextUtil.h"
#import "KEArticleViewController.h"

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

//static CGFloat ANIMATION_INTERVAL = 0.2;

static NSString *cellIdentifier = @"cellIdentifier";

@interface KEBookLibraryTitleViewController ()

@property (nonatomic, strong) NSString *titleDescription;

@property (nonatomic, strong) NSArray *categoryYearArray;
@property (atomic, strong) NSMutableDictionary *booksDictionary;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic) CGFloat lastScrollViewOffset;

@end

@implementation KEBookLibraryTitleViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.showcaseTableView registerNib:[UINib nibWithNibName:@"KELibraryBookCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.showcaseTableView.scDatasource = self;
    self.showcaseTableView.scDelegate = self;
    self.showcaseTableView.tableView.dataSource = self.showcaseTableView;
    self.showcaseTableView.tableView.delegate = self.showcaseTableView;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KELibraryTitleHeaderView" owner:nil options:nil];
    
    if( DEVICE_IS_IPAD ){
        self.titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:1];
    }
    else{
        self.titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:0];
    }
    
    self.booksDictionary = [[NSMutableDictionary alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __weak KEBookLibraryTitleViewController *weakSelf = self;
    [self getTitleInformation];
    
    [[KCService contentManager] getAllYearsContainBooksForTitleID:KonoContentKitDemoMagazine complete:^(NSArray *yearArray) {
        
        weakSelf.categoryYearArray = [NSMutableArray arrayWithArray:yearArray];
        
        for( NSDictionary* titleYear in yearArray ){
            NSString *year;
            if( [[titleYear objectForKey:@"year"] isKindOfClass:[NSString class]]){
                year = [titleYear objectForKey:@"year"];
            }
            else{
                year = [[titleYear objectForKey:@"year"] stringValue];
            }
            NSMutableArray *booksArray = [weakSelf.booksDictionary objectForKey:year];
            
            if( booksArray == nil ){
                
                [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
                    
                    [weakSelf.booksDictionary setObject:bookArray forKey:year];
                    
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.currentIndexPath) {
        [self.showcaseTableView reloadRowsAtIndexPaths:@[self.currentIndexPath]];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    if ( [self.navigationController.viewControllers indexOfObject:self] == NSNotFound ) {
        
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        self.showcaseTableView.scDatasource = nil;
        self.showcaseTableView.scDelegate = nil;
        self.showcaseTableView.tableView.delegate = nil;
        self.showcaseTableView.tableView.dataSource = nil;
    }
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]
                                            removeObserver:self
                                                      name:@"KEBookTitleFollowed"
                                                    object:nil];
}

- (void)getTitleInformation{
    
    [[KCService contentManager] getAllTitles:^(NSArray *titleArray) {
        
        for (NSDictionary *titleDic in titleArray) {
            if ([titleDic[@"title"] isEqualToString:KonoContentKitDemoMagazine]) {
                self.titleDescription = titleDic[@"description"];
                self.navigationItem.title = titleDic[@"name"];
                [self loadTitleHeaderView];
            }
        }
        
    } fail:^(NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
}

- (void)loadTitleHeaderView{
    
    NSAttributedString *attString;
    
    self.titleDescriptionView.titleDescription.text = self.titleDescription;
    self.titleDescriptionView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.000];
    self.titleDescriptionView.delegate = self;
    
    
    if( DEVICE_IS_IPAD ){
        attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:16 withLineSpacing:8.0  withText:self.titleDescription ];
        
        
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.showcaseTableView.frame.size.width - 208, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.titleDescriptionView.titleDescription.numberOfLines = 0;
        self.titleDescriptionView.titleDescription.attributedText = attString;
        
        /* default we keep bottom 20px padding*/
        [self.titleDescriptionView.titleDescription mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.height.equalTo( @( ceilf(size.height) ) );
            
        }];
        CGRect newFrame = self.titleDescriptionView.frame;
        newFrame.size.height = MAX( ceilf(size.height) + 60 , 100 );
        self.titleDescriptionView.frame = newFrame;
        
        self.showcaseTableView.tableView.tableHeaderView = self.titleDescriptionView;
    }
    else {
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat descriptionMargin = 15;
        CGFloat descriptionFieldWidth = screen.bounds.size.width - 2 * descriptionMargin;
        
        attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:14 withText:self.titleDescription ];
        
        CGSize size = [attString boundingRectWithSize:CGSizeMake(descriptionFieldWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        self.titleDescriptionView.titleDescription.attributedText = attString;

        if (floor(size.height) <= self.titleDescriptionView.titleDescription.frame.size.height) {
            self.titleDescriptionView.showDescriptionBtn.alpha = 0;
            
            [self.titleDescriptionView.showDescriptionBtn removeFromSuperview];
            
            CGRect newFrame = self.titleDescriptionView.frame;
            newFrame.size.height = newFrame.size.height - 33;
            self.titleDescriptionView.frame = newFrame;
            
            self.showcaseTableView.tableView.tableHeaderView = self.titleDescriptionView;
            
        }
        else {
            self.titleDescriptionView.showDescriptionBtn.alpha = 1;
            self.showcaseTableView.tableView.tableHeaderView = self.titleDescriptionView;
        }
    }
   
}

- (NSString *)refineIssueLabelText:(NSString *)issueText{
    
    NSString *refineIssueText;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"20../" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:issueText options:0 range:NSMakeRange(0, [issueText length]) withTemplate:@""];
    
    NSRange range = [modifiedString rangeOfString:@" "];
    
    if( range.location != NSNotFound ){
    
        refineIssueText = [modifiedString stringByReplacingCharactersInRange:range withString:@"\n"];
    }
    else{
        refineIssueText = modifiedString;
    }
    return refineIssueText;
}


- (NSInteger)numberOfSectionInShowcaseView:(KEShowcaseTableView *)showcaseView{
    
    return [self.categoryYearArray count];
}


- (NSInteger)showcaseView:(KEShowcaseTableView *)showcaseView numberOfItemsForSection:(NSInteger)section{
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    
    
    return [bookArr count];
    
}


- (NSString *)showcaseView:(KEShowcaseTableView *)shoecaseView titleForSection:(NSInteger)section{
    
    NSString *title;
    if( [[[self.categoryYearArray objectAtIndex:section] objectForKey:@"year"] isKindOfClass:[NSString class]] ){
        title = [[self.categoryYearArray objectAtIndex:section] objectForKey:@"year"];
    }
    else{
        title = [[[self.categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue];
    }
    
    return title;
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
    
    self.currentIndexPath = indexPath;
    //[self performSegueWithIdentifier:@"openBookLibraryDetailPage" sender:self];
    
    /* prototype entry point */
    NSString *year = [[NSString alloc] initWithString:[[[self.categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    KCBook *bookItem = [bookArr objectAtIndex:indexPath.row];
    
    KEArticleViewController *articleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KEArticleViewController"];
    articleViewController.hidesBottomBarWhenPushed = YES;
    articleViewController.bookItem = bookItem;
    
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (UIView *)showcaseViewInCell:(KEShowcaseTableViewCell *)showcaseCell viewForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KELibraryBookCell *cell = (KELibraryBookCell*)[showcaseCell dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
    cell.tag = CELL_TAG_MUTIPLIER*indexPath.section + indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.coverImageView.image = nil;
    
    if( DEVICE_IS_IPAD ){
        cell.issueLabel.text = book.issue;
    }
    else{
        cell.issueLabel.text = [self refineIssueLabelText:book.issue];
    }
    
    //todo: to check the media tag could be showed properly
    if (YES == book.isHasAudio || YES == book.isHasVideo) {
        cell.mediaTag.alpha = 1.0;
    }
    else{
        cell.mediaTag.alpha = 0.0;
    }
   
    BOOL isHasTranslation = NO;
    
    if (YES == book.isNew) {
        cell.tagBackgroundView.alpha = 1.0;
        cell.firstTag.alpha = 1.0;
        cell.secondTag.alpha = 0.0;
        
        if (isHasTranslation) {
            cell.secondTag.alpha = 1.0;
            [cell setupTagImage:KEIssueCoverTagTypeBoth];
        } else {
            [cell setupTagImage:KEIssueCoverTagTypeNew];
        }
    }
    else {
        cell.tagBackgroundView.alpha = 0.0;
        cell.firstTag.alpha = 0.0;
        cell.secondTag.alpha = 0.0;
        
        if (isHasTranslation) {
            cell.tagBackgroundView.alpha = 1.0;
            cell.firstTag.alpha = 1.0;
            [cell setupTagImage:KEIssueCoverTagTypeTranslation];
        }
    }
    
    return cell;
    
}

- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplayCell:(UITableViewCell *)cell willDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KELibraryBookCell *displayCell = (KELibraryBookCell *)cell;
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
    [displayCell.coverImageView pin_setImageFromURL:[NSURL URLWithString:book.coverImageMedium]];
    
//    CGFloat readPercentage = [KEPersonalReadingRecord getPersonalMagazineReadingPercentage:user.kid withMagazineID:magazineItem.bid];
//    NSInteger progressBarHeight = ceil( readPercentage * displayCell.readingProgressBase.frame.size.height );
//   
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        displayCell.readingProgressValue.frame = CGRectMake(0, displayCell.readingProgressBase.frame.size.height, displayCell.readingProgressBase.frame.size.width, 0);
//        [UIView animateWithDuration:0.5
//                              delay:(ANIMATION_INTERVAL * indexPath.row)
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             displayCell.readingProgressValue.frame = CGRectMake(0, displayCell.readingProgressBase.frame.size.height - progressBarHeight, displayCell.readingProgressBase.frame.size.width, progressBarHeight);
//                         } completion:^(BOOL finished){
//                         }];
//    }];
}

- (CGFloat)widthForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if( DEVICE_IS_IPAD ){
        return WIDTH_FOR_CELL_IPAD;
    }else{
        return WIDTH_FOR_CELL;        
    }

    
}



- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplaySection:(NSInteger)section{
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:section] objectForKey:@"year"] stringValue]];
    NSMutableArray *booksArray;

    booksArray = [self.booksDictionary objectForKey:year];

    if( booksArray == nil ) {
        
        __weak KEBookLibraryTitleViewController *weakSelf = self;
        
        [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
            
            [weakSelf.booksDictionary setObject:bookArray forKey:year];
            [weakSelf.showcaseTableView reloadData];
            
        } fail:^(NSError *error) {
            
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - header view delegate

- (void)followBtnPressed:(void (^)(void))followBlock unFollowComplete:(void (^)(void))unfollowBlock{

    
}

- (void)showDescriptionBtnPressed:(BOOL)wantExpendView {
    
    NSAttributedString *attString;
    
    attString = [KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:14 withText:self.titleDescription];
    
    CGSize size = [attString boundingRectWithSize:CGSizeMake(self.titleDescriptionView.titleDescription.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (wantExpendView) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect newFrame = self.titleDescriptionView.frame;
                             newFrame.size.height = newFrame.size.height + ceilf(size.height - 62.f);
                             self.titleDescriptionView.frame = newFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             CGRect newFrame = self.titleDescriptionView.titleDescription.frame;
                             newFrame.size.height = ceilf(size.height);
                             self.titleDescriptionView.titleDescription.frame = newFrame;
                             
                             [self.titleDescriptionView.titleDescription setNumberOfLines:0];
                         }];
        
    } else {
        
        CGRect newFrame = self.titleDescriptionView.titleDescription.frame;
        newFrame.size.height = 62;
        self.titleDescriptionView.titleDescription.frame = newFrame;
        
        [self.titleDescriptionView.titleDescription setNumberOfLines:3];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect newFrame = self.titleDescriptionView.frame;
                             newFrame.size.height = newFrame.size.height - ceilf(size.height - 62.f);
                             self.titleDescriptionView.frame = newFrame;
                         }];
        
    }

    self.showcaseTableView.tableView.tableHeaderView = self.titleDescriptionView;

    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.showcaseTableView.tableView layoutIfNeeded];
                     }];

}

@end
