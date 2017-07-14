//
//  KEBookLibraryTitleViewController.m
//  Kono
//
//  Created by Kono on 6/14/17.
//  Copyright (c) 2017 Kono. All rights reserved.
//
#import "KEArticleViewController.h"
#import "KEBookLibraryTitleViewController.h"
#import "KEColor.h"
#import "KELibraryBookCell.h"
#import "KETextUtil.h"

#import <MBProgressHUD.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

#define HEIGHT_FOR_CELL 240.0
#define HEIGHT_FOR_CELL_IPAD 402.0
#define WIDTH_FOR_CELL 145.0
#define WIDTH_FOR_CELL_IPAD 290.0

#define CELL_TAG_OFFSET 1000


static NSString *cellIdentifier = @"cellIdentifier";
static NSString *horizonCellIdentifier = @"horizonCellIdentifier";

@interface KEBookLibraryTitleViewController ()
    
@property (nonatomic, strong) NSString *titleDescription;
@property (nonatomic, strong) NSArray *categoryYearArray;
@property (nonatomic, strong) NSMutableDictionary *booksDictionary;
@property (nonatomic, strong) KELibraryTitleHeaderView *titleDescriptionView;


@end

@implementation KEBookLibraryTitleViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KELibraryTitleHeaderView" owner:nil options:nil];
    
    if( DEVICE_IS_IPAD ){
        self.titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:1];
    }
    else{
        self.titleDescriptionView = (KELibraryTitleHeaderView*)[nib objectAtIndex:0];
    }
    
    self.booksDictionary = [[NSMutableDictionary alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self getTitleInformation];
    [self getTitleBooksDictionary];
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
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
}

- (void)getTitleBooksDictionary {
    
    __weak KEBookLibraryTitleViewController *weakSelf = self;
    
    [[KCService contentManager] getAllYearsContainBooksForTitleID:KonoContentKitDemoMagazine complete:^(NSArray *yearArray) {
        
        self.categoryYearArray = [NSMutableArray arrayWithArray:yearArray];
        
        for( NSDictionary* titleYear in yearArray ) {
            
            NSString *year;
            year = [[titleYear objectForKey:@"year"] stringValue];
            
            NSMutableArray *booksArray = [self.booksDictionary objectForKey:[[titleYear objectForKey:@"year"] stringValue]];
            
            if( booksArray == nil ) {
                
                [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
                    
                    [self.booksDictionary setObject:bookArray forKey:year];
                    [weakSelf.tableView reloadData];
                    
                } fail:^(NSError *error) {
                    
                }];
            }
        }
        
        [weakSelf.tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    } fail:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];

    
}

- (void)getTitleInformation{
    
    [[KCService contentManager] getTitleInfoForTitleID:KonoContentKitDemoMagazine complete:^(NSDictionary *titleInfo) {
        
        self.titleDescription = titleInfo[@"description"];
        self.navigationItem.title = titleInfo[@"name"];
        [self loadTitleHeaderView];
        
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
        
        
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 208, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.titleDescriptionView.titleDescription.numberOfLines = 0;
        self.titleDescriptionView.titleDescription.attributedText = attString;
        
        /* default we keep bottom 20px padding*/
        [self.titleDescriptionView.titleDescription mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.height.equalTo( @( ceilf(size.height) ) );
            
        }];
        CGRect newFrame = self.titleDescriptionView.frame;
        newFrame.size.height = MAX( ceilf(size.height) + 60 , 100 );
        self.titleDescriptionView.frame = newFrame;
        
        self.tableView.tableHeaderView = self.titleDescriptionView;
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
            
            self.tableView.tableHeaderView = self.titleDescriptionView;
            
        }
        else {
            self.titleDescriptionView.showDescriptionBtn.alpha = 1;
            self.tableView.tableHeaderView = self.titleDescriptionView;
        }
    }
   
}


#pragma mark - tableview Delegate & Data Source Function

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.categoryYearArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(DEVICE_IS_IPAD) {
        return HEIGHT_FOR_CELL_IPAD;
    }
    else {
        return HEIGHT_FOR_CELL;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    UILabel *yearTitle = [cell viewWithTag:999];
    if( yearTitle == nil ) {
        
        yearTitle = [[UILabel alloc] initWithFrame:CGRectMake( 8 , 0 ,self.tableView.frame.size.width, 20 )];
        yearTitle.tag = 999;
        [cell.contentView addSubview:yearTitle];
    }
    
    UICollectionView *yearCollection = [cell viewWithTag:indexPath.row + CELL_TAG_OFFSET];
    if( yearCollection == nil ) {
        CGFloat cellHeight;
        CGFloat cellWidth;
        
        if(DEVICE_IS_IPAD) {
            cellHeight = HEIGHT_FOR_CELL_IPAD;
            cellWidth = WIDTH_FOR_CELL_IPAD;
        }
        else {
            cellHeight = HEIGHT_FOR_CELL;
            cellWidth = WIDTH_FOR_CELL;
        }
        UICollectionViewFlowLayout *colFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        colFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        colFlowLayout.itemSize = CGSizeMake( cellWidth, cellHeight);
        colFlowLayout.minimumLineSpacing = 1;
        
        
        yearCollection = [[UICollectionView alloc] initWithFrame:CGRectMake( 0 , 30 ,self.tableView.frame.size.width, HEIGHT_FOR_CELL ) collectionViewLayout:colFlowLayout];
        [yearCollection registerNib:[UINib nibWithNibName:@"KELibraryBookCell" bundle:nil] forCellWithReuseIdentifier:horizonCellIdentifier];
        [yearCollection setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
        yearCollection.showsHorizontalScrollIndicator = NO;
        yearCollection.dataSource = self;
        yearCollection.delegate = self;
        yearCollection.tag = indexPath.row + CELL_TAG_OFFSET;
        [cell.contentView addSubview:yearCollection];
    }
    
    return (UITableViewCell* )cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UILabel *yearTitle = [cell viewWithTag:999];
    if( yearTitle ){
        NSDictionary *yearInfo = [self.categoryYearArray objectAtIndex:indexPath.row];
        [yearTitle setAttributedText:[KETextUtil attributedStringWithColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.224 alpha:1.000] withFontSize:14 withText:[yearInfo[@"year"] stringValue]]];
    }
    
    UICollectionView *yearCollection = [cell viewWithTag:indexPath.row + CELL_TAG_OFFSET];
    if( yearCollection ){
        [yearCollection reloadData];
    }
    
}


#pragma mark - collection view data source & delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    KELibraryBookCell *cell = (KELibraryBookCell*)[collectionView dequeueReusableCellWithReuseIdentifier:horizonCellIdentifier forIndexPath:indexPath];
    
    NSInteger index = collectionView.tag - CELL_TAG_OFFSET;
    NSString *year = [[NSString alloc] initWithString:[[[self.categoryYearArray objectAtIndex:index] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger index = collectionView.tag - CELL_TAG_OFFSET;
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:index] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    
    
    return [bookArr count];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 8, 0, 0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KELibraryBookCell *displayCell = (KELibraryBookCell *)cell;
    
    NSString *year = [[NSString alloc]initWithString:[[[self.categoryYearArray objectAtIndex:indexPath.section] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    KCBook *book = [bookArr objectAtIndex:indexPath.row];
    
    [displayCell.coverImageView pin_setImageFromURL:[NSURL URLWithString:book.coverImageMedium]];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = collectionView.tag - CELL_TAG_OFFSET;
    NSString *year = [[NSString alloc] initWithString:[[[self.categoryYearArray objectAtIndex:index] objectForKey:@"year"] stringValue]];
    
    NSArray *bookArr = [self.booksDictionary objectForKey:year];
    KCBook *bookItem = [bookArr objectAtIndex:indexPath.row];
    
    KEArticleViewController *articleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KEArticleViewController"];
    articleViewController.hidesBottomBarWhenPushed = YES;
    articleViewController.bookItem = bookItem;
    
    [self.navigationController pushViewController:articleViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - header view delegate

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
        
    }
    else {
        
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

    self.tableView.tableHeaderView = self.titleDescriptionView;

    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.tableView layoutIfNeeded];
                     }];

}

@end
