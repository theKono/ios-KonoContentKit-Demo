//
//  KEShowcaseTableView.h
//  Kono
//
//  Created by Neo on 2/19/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KEShowcaseTableView;
@class KEShowcaseTableViewCell;

@protocol KEShowcaseTableViewDelegate <NSObject>

@optional

- (void)showcaseView:(KEShowcaseTableView *)showcaseView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplayCell:(UITableViewCell *)cell willDisplayItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)showcaseView:(KEShowcaseTableView *)showcaseView willDisplaySection:(NSInteger)section;

- (void)showcaseView:(KEShowcaseTableView *)showcaseView didEndDisplaySection:(NSInteger)section;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

@end


@protocol KEShowcaseTableViewDatasource <NSObject>

- (UIView *)showcaseViewInCell:(KEShowcaseTableViewCell *)showcaseCell viewForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)showcaseView:(KEShowcaseTableView *)showcaseView numberOfItemsForSection:(NSInteger)section;

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForRowAtSection:(NSInteger)section;

- (NSInteger)numberOfSectionInShowcaseView:(KEShowcaseTableView*)showcaseView;

- (CGFloat)widthForItemAtIndexPath:(NSIndexPath*)indexPath;

@optional

- (UIView *)showcaseView:(KEShowcaseTableView *)showcaseView viewForHeaderInSection:(NSInteger)section;

- (UIView *)showcaseView:(KEShowcaseTableView *)showcaseView viewForFooterInSection:(NSInteger)section;

- (NSString*)showcaseView:(KEShowcaseTableView*)shoecaseView titleForSection:(NSInteger)section;

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForHeaderInSection:(NSInteger)section;

- (CGFloat)showcaseView:(KEShowcaseTableView *)showcaseView heightForFooterInSection:(NSInteger)section;


@end




@interface KEShowcaseTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>{
    
    __weak id <KEShowcaseTableViewDatasource> _hDatasource;
    
}
    

@property (nonatomic, strong) UITableView *horizontalTableView;

@property (nonatomic, strong) NSArray *contentArray;

@property (nonatomic) NSInteger section;

@property (nonatomic, weak) KEShowcaseTableView *showcaseView;

@property (nonatomic, weak) id<KEShowcaseTableViewDatasource> hDatasource;
@property (nonatomic, weak) id<KEShowcaseTableViewDelegate> hDelegate;


- (UITableViewCell*)dequeueReusableCellWithIdentifier:(NSString*)cellIdentifier forIndexPath:(NSIndexPath*)indexPath;

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

- (void)registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)cellIdentifier;
- (void)registerClass:(__unsafe_unretained Class)classInstance forCellReuseIdentifier:(NSString *)cellIdentifier;

@end




@interface KEShowcaseTableView : UIView<UITableViewDataSource, UITableViewDelegate>{
    
    NSMutableArray *_classRegistrationArray;
    NSMutableArray *_nibRegistrationArray;
    
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<KEShowcaseTableViewDelegate> scDelegate;

@property (nonatomic, weak) id<KEShowcaseTableViewDatasource> scDatasource;


- (void)reloadData;

- (NSArray*)visibleSections;

- (void)reloadSection:(NSInteger)section;
- (void)deleteSection:(NSInteger)section;
- (void)insertSection:(NSInteger)section;


- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

- (UIView*)headerViewForSection:(NSInteger)section;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell*)dequeueReusableCellWithIdentifier:(NSString*)cellIdentifier forIndexPath:(NSIndexPath*)indexPath;

- (UITableViewHeaderFooterView*)dequeueReusableHeaderFooterViewWithIdentifier:(NSString*)headerIdentifier;

- (void)registerNib:(UINib*)nib forCellReuseIdentifier:(NSString*)cellIdentifier;


- (void)registerClass:(__unsafe_unretained Class)classInstance forCellReuseIdentifier:(NSString *)cellIdentifier;

@end
