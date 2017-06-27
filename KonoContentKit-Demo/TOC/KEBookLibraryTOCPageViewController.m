//
//  KEBookLibraryTOCPageViewController.m
//  Kono
//
//  Created by Kono on 2016/4/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleViewController.h"
//#import "KEArticleFitReadingViewController.h"
#import "KEBookLibraryDetailPageInformationViewController.h"
#import "KEBookLibraryTOCPageViewController.h"
#import "KEBookLibraryItemCell.h"
#import "KEColor.h"

#import <MZFormSheetController.h>
#import <MBProgressHUD.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

static NSString *libCellIdentifier = @"libCellIdentifier";
static NSString *previewCellIdentifier = @"previewCellIdentifier";

#define CELL_TAG_OFFSET 100
#define MAGZINE_COVER_HEIGHT_IPHONE 415.0

@interface KEBookLibraryTOCPageViewController()

@property (nonatomic, strong) NSArray *previewArray;
@property (nonatomic, strong) NSDictionary *detailDictionary;

@end

@implementation KEBookLibraryTOCPageViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.tocTableView registerNib:[UINib nibWithNibName:@"KEBookLibraryTOCTableCell" bundle:nil] forCellReuseIdentifier:libCellIdentifier];
    
    [self.previewTableView registerNib:[UINib nibWithNibName:@"KEBookLibraryHorizontalScrollCell" bundle:nil] forCellReuseIdentifier:previewCellIdentifier];
    
    self.magazineIssueName.layer.borderColor = [KEColor konoSeperatorGray].CGColor;
    self.magazineIssueName.layer.borderWidth = 1.0;
    
    self.previewTableView.delegate = self;
    self.previewTableView.dataSource = self;
    self.tocTableView.delegate = self;
    self.tocTableView.dataSource = self;
    
    self.tocTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.previewTableView.scrollEnabled = NO;
    
    [self fetchTOCInfo];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - adjust layout function

- (void)updateLayoutForWebcontent{
    
    [self.previewTableView removeFromSuperview];
    [self.magazineIssueName mas_updateConstraints:^(MASConstraintMaker *make){
        make.top.equalTo( self.navigationView.mas_bottom ).with.offset(0);
    }];
    
}

#pragma mark - collection view util

- (NSInteger)getCollectionViewIndex:(NSInteger)magazineIndex {
    
    NSInteger collectionViewIdx = 0;
    
    if (self.bookItem.pageMappingArray.count > 0) {
        
        if (!self.bookItem.isLeftFlip) {
            collectionViewIdx = self.bookItem.pageMappingArray.count - magazineIndex - 1;
        }
        else{
            collectionViewIdx = magazineIndex;
        }
    }
    
    return collectionViewIdx;
}

- (NSInteger)getMagazinePageIndex:(NSInteger)tableViewIndex{
    
    NSInteger magazineIdx = 0;
    
    if (self.bookItem.pageMappingArray.count > 0) {
        
        if (!self.bookItem.isLeftFlip) {
            magazineIdx = self.bookItem.pageMappingArray.count - tableViewIndex - 1;
        }
        else{
            magazineIdx = tableViewIndex;
        }
    }
    
    return magazineIdx;
}

- (void)fetchTOCInfo {
    
    self.magazineIssueName.text = [NSString stringWithFormat:@"%@ %@",self.bookItem.issue, @"Table of Content"];
    
    if (!self.bookItem.isHasPDF) {
        [self updateLayoutForWebcontent];
    }
    
    [self.tocTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tocTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.targetArticleIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
    });
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

#pragma mark - tableview Delegate & Data Source Function

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.previewTableView) {
        return 1;
    }
    else{
        return [self.bookItem.articleArray count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight;
    
    if( self.previewTableView == tableView ){
        cellHeight = self.previewTableView.frame.size.height;
    }
    else{
        if( DEVICE_IS_IPAD ){
            cellHeight = 160;
        }
        else{
            cellHeight = 95;
        }
    }
    
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.previewTableView == tableView) {
        
        KEBookLibraryHorizontalScrollCell *cell = [tableView dequeueReusableCellWithIdentifier:previewCellIdentifier forIndexPath:indexPath];
        
        CGFloat previewImageWidth = 0;
        if( DEVICE_IS_IPAD ){
            previewImageWidth = 141;
        }
        else{
            previewImageWidth = 114;
        }
        
        [cell setCellFrame:CGSizeMake( previewImageWidth, self.previewTableView.frame.size.height)];
        cell.collectionView.dataSource = self;
        cell.collectionView.delegate = self;
        
        return (UITableViewCell* )cell;
        
    } else {
    
        KEBookLibraryTOCTableCell *cell = [tableView dequeueReusableCellWithIdentifier:libCellIdentifier forIndexPath:indexPath];
        
        KCBookArticle *article = self.bookItem.articleArray[indexPath.row];
        
        NSAttributedString *attString;
        //NSAttributedString *descriptionString;
        CGFloat descriptionWidth = 0;
        
        if (DEVICE_IS_IPAD) {
            descriptionWidth = cell.frame.size.width - 185;
            
            attString = [KETextUtil attributedStringWithColor:[KEColor konoGrayPressed] withFontSize:15 withLineSpacing:8.0 withText:article.articleDescription ];

        }
        else {
            descriptionWidth = cell.frame.size.width - 104;
            if( DEVICE_IS_IOS9_OR_LATER ){
                attString = [KETextUtil attributedStringWithColor:[KEColor konoGrayPressed] withFontSize:15 withLineSpacing:8.0  withText:article.articleTitle];
            }
            else{
                attString = [KETextUtil attributedStringWithColor:[KEColor konoGrayPressed] withFontSize:16 withLineSpacing:6.0  withText:article.articleTitle];
            }
        }
        
        CGSize size = CGSizeMake(0, 0);
        if( nil != attString ){
            size = [attString boundingRectWithSize:CGSizeMake(descriptionWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        }
        
        cell.articleNameLabel.text = article.articleTitle;
        
        if (DEVICE_IS_IPAD) {
            
            cell.articleIntroText.attributedText = [KETextUtil attributedStringWithColor:[KEColor konoGrayPressed] withFontSize:15 withLineSpacing:8.0  withTruncateMode:NSLineBreakByTruncatingTail withText:article.articleDescription ];
            
            [cell.articleIntroText mas_updateConstraints:^(MASConstraintMaker *make){
                if( size.height > 72 ){
                    make.height.equalTo(@(72));
                }
                else{
                    make.height.equalTo(@(size.height));
                }
                make.top.equalTo( cell.articleNameLabel.mas_bottom ).with.offset( 10 );
            }];
        }
        else {
            [cell.articleNameLabel mas_updateConstraints:^(MASConstraintMaker *make){
                if( size.height > 42 ){
                    make.height.equalTo(@(42));
                }
                else{
                    make.height.equalTo(@(size.height));
                }
                make.top.equalTo( cell.mas_top ).with.offset( 10 );
            }];
        }
        
        cell.articleCoverImage.image = nil;
        
        [cell.articleCoverImage pin_setImageFromURL:[NSURL URLWithString:article.smallMainImageURL]];
        
        cell.articleReadModeTag.hidden = NO;
        
        if (article.isHasPDF && article.isHasFitreading) {
            cell.articleReadModeTag.text = @"PDF | EZ Read";
        } else if (article.isHasPDF) {
            cell.articleReadModeTag.text = @"PDF";
        } else if (article.isHasFitreading) {
            cell.articleReadModeTag.text = @"EZ Read";
        } else {
            cell.articleReadModeTag.hidden = YES;
        }
        
        cell.tag = CELL_TAG_OFFSET + indexPath.row;
        
        BOOL hasMultiMedia = article.isHasAudio || article.isHasVideo;
        
        
        [cell setupDescriptionWithMultiMedia:hasMultiMedia hasTranslation:NO];
        
        //[cell setupDescriptionWithMultiMedia:hasMultiMedia hasTranslation:article.isHasTranslation];
        
        return (UITableViewCell*)cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tocTableView == tableView) {
        
        KEBookLibraryTOCTableCell *tocTableCell = (KEBookLibraryTOCTableCell *)cell;
        
        if (self.targetArticleIndex == indexPath.row) {
            
            tocTableCell.articleNameLabel.textColor = [KEColor konoGreenPressed];
            if (DEVICE_IS_IPAD) {
                tocTableCell.articleIntroText.textColor = [KEColor konoGreenPressed];
            }
        }
        else {
            
            tocTableCell.articleNameLabel.textColor = [KEColor konoGrayPressed];
            if (DEVICE_IS_IPAD) {
                tocTableCell.articleIntroText.textColor = [KEColor konoGrayPressed];
            }
        }
    }
    else if( self.previewTableView == tableView ){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [((KEBookLibraryHorizontalScrollCell *)cell).collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self getCollectionViewIndex:self.targetPageIndex] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        });
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        [self openArticleAtIndex:indexPath.row];
    
}


#pragma mark - collection view data source & delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KEBookLibraryItemCell *cell = (KEBookLibraryItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:horizonCellIdentifier forIndexPath:indexPath];
    
    KCBookPage *page = self.bookItem.pageMappingArray[[self getMagazinePageIndex:indexPath.row]];
    
    cell.itemImage.image = nil;
    cell.itemImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.itemImage pin_setImageFromURL:[NSURL URLWithString:page.thumbnailURL]];
    
    if (self.targetPageIndex == [self getMagazinePageIndex:indexPath.row]) {
        [cell.currentPageIndicator setHidden:NO];
    }
    else {
        [cell.currentPageIndicator setHidden:YES];
    }
     
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.bookItem.pageMappingArray count];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 8, 0, 0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *magazineIdxPath = [NSIndexPath indexPathForRow:[self getMagazinePageIndex:indexPath.row] inSection:0];
    
    KCBookPage *page = self.bookItem.pageMappingArray[magazineIdxPath.row];
    
    KCBookArticle *article = page.articleArray[0];
    
    NSDictionary *clickArticleInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      article,@"article",
                                      magazineIdxPath,@"pageIndexPath",
                                      self.baseViewController,@"baseViewController",
                                      @(YES),@"isThumbnailClick",
                                      nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEMagazinePageChange" object:nil userInfo:clickArticleInfo];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - click delegate function

- (void)openArticleAtIndex:(NSInteger)idx{
    
    KCBookArticle *article = self.bookItem.articleArray[idx];
    
    NSInteger pageIdx = article.beginAt - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageIdx inSection:0];
    
    if( self.baseViewController == nil ){
        self.baseViewController = self;
    }
    
    NSDictionary *clickArticleInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                      article,@"article",
                                      indexPath,@"pageIndexPath",
                                      self.baseViewController,@"baseViewController",
                                      @(NO),@"isThumbnailClick",
                                      nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KEMagazinePageChange" object:nil userInfo:clickArticleInfo];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - formsheet producer

- (void)showInfoViewOniPhone {
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.400]];
    
    KEBookLibraryDetailPageInformationViewController *vc = [[KEBookLibraryDetailPageInformationViewController alloc] initWithNibName:@"KEBookLibraryDetailPageInformationViewController" bundle:nil];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.presentedFormSheetSize = CGSizeMake(290, 446);
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.portraitTopInset = 61.0;
    formSheet.cornerRadius = 2.0;
    formSheet.shadowOpacity = 0;
    formSheet.shadowRadius = 0.0;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        
        KEBookLibraryDetailPageInformationViewController *vc = (KEBookLibraryDetailPageInformationViewController*)presentedFSViewController;
        
        //vc.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.magazineItem.magazineName,self.magazineItem.issue];
        
        //vc.descriptionLabel.attributedText =  [KETextUtil magazineInfoDescription:self.magazineItem.magazineDescription];
        [vc initDisplayContent:[NSString stringWithFormat:@"%@ %@",self.bookItem.name,self.bookItem.issue] withMagazineInfo:[KETextUtil magazineInfoDescription:self.bookItem.bookDescription]];
    };
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
        
    }];

    
}

- (void)showInfoViewOniPad{
    
    KEBookLibraryDetailPageInformationViewController *vc = [[KEBookLibraryDetailPageInformationViewController alloc] initWithNibName:@"KEBookLibraryDetailPageInformationViewController" bundle:nil];
    
    vc.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.bookItem.name, self.bookItem.issue];
    
    vc.descriptionLabel.attributedText = [KETextUtil magazineInfoDescription:self.bookItem.bookDescription];
    
    UINavigationController *nvController = [[UINavigationController alloc] initWithRootViewController:vc];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:nvController];
    
    formSheet.presentedFormSheetSize = CGSizeMake(480, 560);
    
    formSheet.portraitTopInset = 232;
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    
    formSheet.cornerRadius = 2.0;
    
    formSheet.shadowOpacity = 0;
    
    formSheet.shadowRadius = 0.0;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {

        
    };
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        NSLog(@"form sheet complete!");
        KEBookLibraryDetailPageInformationViewController *vc = (KEBookLibraryDetailPageInformationViewController *)(((UINavigationController *)formSheetController.presentedFSViewController).visibleViewController);
        
        //vc.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.magazineItem.magazineName,self.magazineItem.issue];
        [vc initDisplayContent:[NSString stringWithFormat:@"%@ %@",self.bookItem.name,self.bookItem.issue] withMagazineInfo:[KETextUtil magazineInfoDescription:self.bookItem.bookDescription]];

    }];

    
}


#pragma mark - navigation bar button handle function

- (IBAction)backBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)infoBtnPressed:(id)sender {
    
    if( DEVICE_IS_IPAD ){
        [self showInfoViewOniPad];
    }
    else{
        [self showInfoViewOniPhone];
    }
}

@end

