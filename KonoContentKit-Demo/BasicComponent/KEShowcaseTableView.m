//
//  KEShowcaseTableView.m
//  Kono
//
//  Created by Neo on 2/19/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEShowcaseTableView.h"

#import "KEColor.h"
#import <Masonry.h>

static NSString *sectionCellIdentifier = @"sectionCell";
static NSString *horizontalCellIdentifier = @"hCell";

@implementation KEShowcaseTableViewCell

@synthesize contentArray = _contentArray;
@synthesize horizontalTableView = _horizontalTableView;
@synthesize section = _section;
@synthesize showcaseView = _showcaseView;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){

        self.horizontalTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.horizontalTableView.dataSource = self;
        self.horizontalTableView.delegate = self;
        self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.horizontalTableView.showsVerticalScrollIndicator = NO;
        
        CGFloat offset = 7.0;
        if( DEVICE_IS_IPAD ){
            offset = 13.0;
        }
        self.horizontalTableView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
        
        [self.horizontalTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:horizontalCellIdentifier];
        
    }
    
    return self;

}

- (id<KEShowcaseTableViewDatasource>)hDatasource{
    return _hDatasource;
}


- (void)setHDatasource:(id<KEShowcaseTableViewDatasource>)hDatasource{
    
    _hDatasource = hDatasource;
    
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)cellIdentifier{

    [self.horizontalTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];

}

- (void)registerClass:(__unsafe_unretained Class)classInstance forCellReuseIdentifier:(NSString *)cellIdentifier{
    
    [self.horizontalTableView registerClass:classInstance forCellReuseIdentifier:cellIdentifier];
    
}

- (void)layoutSubviews{
    
    [self.contentView addSubview:self.horizontalTableView];

    
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
    self.horizontalTableView.transform = rotateTable;
    
    
    [self.horizontalTableView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.width.equalTo( self.horizontalTableView.superview.mas_height );
        make.height.equalTo( self.horizontalTableView.superview.mas_width );
        make.centerX.equalTo( self.horizontalTableView.superview.mas_centerX );
        make.centerY.equalTo( self.horizontalTableView.superview.mas_centerY );

    }];
        
        
    
    [super layoutSubviews];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.hDatasource showcaseView:self.showcaseView numberOfItemsForSection:self.section];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [self.hDatasource widthForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;

    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.section];
    
    if(  [self.hDatasource respondsToSelector:@selector(showcaseViewInCell:viewForItemAtIndexPath:)]){
        cell = (UITableViewCell*)[self.hDatasource showcaseViewInCell:self viewForItemAtIndexPath:newIndexPath];
    }
    
    if( cell == nil ){
        //if the tableview is out of visible bound, we can't get the tableview
        //then retreive the reuse cell to update the new value.
        //Add an dummy cell here to prevent crash
        cell = [[UITableViewCell alloc]init];
        
    }
    
    CGAffineTransform rotateImage = CGAffineTransformMakeRotation(M_PI_2);
    cell.transform = rotateImage;
    cell.center = CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2);

    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if([self.hDelegate respondsToSelector:@selector(showcaseView:didSelectRowAtIndexPath:)]){
        [self.hDelegate showcaseView:self.showcaseView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.section]];
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if( [self.hDelegate respondsToSelector:@selector(showcaseView:willDisplayCell:willDisplayItemAtIndexPath:)]){
        [self.hDelegate showcaseView:self.showcaseView willDisplayCell:cell willDisplayItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:self.section]];
    }
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier forIndexPath:(NSIndexPath *)indexPath{
    
    return [self.horizontalTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        [arr addObject:[NSIndexPath indexPathForRow:obj.row inSection:0]];
    }];
//    [self.horizontalTableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.horizontalTableView reloadData];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        [arr addObject:[NSIndexPath indexPathForRow:obj.row inSection:0]];
    }];

    [self.horizontalTableView reloadData];

}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        
        [arr addObject:[NSIndexPath indexPathForRow:obj.row inSection:0]];
        
    }];
    [self.horizontalTableView reloadData];
}

@end


@implementation KEShowcaseTableView


@synthesize scDatasource = _scDatasource;
@synthesize scDelegate = _scDelegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        
    }
    return self;
}


- (void)awakeFromNib{

    [super awakeFromNib];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
    
    tableView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(0);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
    }];
    
    self.tableView = tableView;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass:[KEShowcaseTableViewCell class] forCellReuseIdentifier:sectionCellIdentifier];

}


- (void)registerClass:(__unsafe_unretained Class)classInstance forCellReuseIdentifier:(NSString *)cellIdentifier{
    
    if( _classRegistrationArray == nil ) {
        _classRegistrationArray = [[NSMutableArray alloc] init];
    }

    [_classRegistrationArray addObject:@[ classInstance , cellIdentifier]];

}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)cellIdentifier{
    

    if( _nibRegistrationArray == nil ){
        
        _nibRegistrationArray = [[ NSMutableArray alloc] init];
        
    }
    
    [_nibRegistrationArray addObject:@[ nib , cellIdentifier ]];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.scDatasource numberOfSectionInShowcaseView:self];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    return [self.scDatasource showcaseView:self heightForRowAtSection:indexPath.row];
    
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /* show custom header view if datasource implements it */
    if ([self.scDatasource respondsToSelector:@selector(showcaseView:viewForHeaderInSection:)]) {
        
        UIView *headerView = [self.scDatasource showcaseView:self viewForHeaderInSection:section];
        return headerView;
        
    } else {
        
        CGFloat sectionHeight = [self.scDatasource showcaseView:self heightForHeaderInSection:section];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, sectionHeight)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width, sectionHeight)];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.text = [self.scDatasource showcaseView:self titleForSection:section];
        label.textColor = [KEColor generalTitleColor];
        label.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc ]initWithFrame:CGRectMake(0, 0, self.frame.size.width, sectionHeight)];
        imageView.image = [UIImage imageNamed:@"Library-bg-iphone.png"];
        
        UIImageView *lineImageView = [[UIImageView alloc ]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        lineImageView.image = [UIImage imageNamed:@"Library-bgline-iphone.png.png"];
        
        [headerView addSubview:imageView];
        [headerView addSubview:lineImageView];
        [headerView addSubview:label];
        
        return headerView;

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.scDatasource respondsToSelector:@selector(showcaseView:viewForFooterInSection:)]) {
        
        UIView *headerView = [self.scDatasource showcaseView:self viewForFooterInSection:section];
        return headerView;
    } else {
        CGFloat footerHeight = [self.scDatasource showcaseView:self heightForFooterInSection:section];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, footerHeight)];
        return footerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if([self.scDatasource respondsToSelector:@selector(showcaseView:heightForHeaderInSection:)]){
        return [self.scDatasource showcaseView:self heightForHeaderInSection:section];
    }else{
        return 0.0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if([self.scDatasource respondsToSelector:@selector(showcaseView:heightForFooterInSection:)]){
        return [self.scDatasource showcaseView:self heightForFooterInSection:section];
    }else{
        return 0.0;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KEShowcaseTableViewCell *cell = (KEShowcaseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:sectionCellIdentifier forIndexPath:indexPath];
    
    if( cell == nil ){
        cell = [[KEShowcaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sectionCellIdentifier];
    }
    
    
    [_nibRegistrationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UINib *nib = [obj objectAtIndex:0];
        NSString *cellId = [obj objectAtIndex:1];
        
        [cell registerNib:nib forCellReuseIdentifier:cellId];
        
    }];
    
    
    [_classRegistrationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        __unsafe_unretained Class classInstance = [obj objectAtIndex:0];
        NSString *cellID = [obj objectAtIndex:1];
        
        [cell registerClass:classInstance forCellReuseIdentifier:cellID];
        
    }];

    cell.hDatasource = self.scDatasource;
    cell.hDelegate = self.scDelegate;
    cell.showcaseView = self;
    
    cell.section = indexPath.section;

    cell.horizontalTableView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
   // [cell.horizontalTableView reloadData];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    /* scroll to top */
    if( [self.scDatasource showcaseView:self numberOfItemsForSection:indexPath.section]>0){
        
        if( [[(KEShowcaseTableViewCell*)cell horizontalTableView] numberOfRowsInSection:0] > 0 ){
            [[(KEShowcaseTableViewCell*)cell horizontalTableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }

    if( [self.scDelegate respondsToSelector:@selector(showcaseView:willDisplaySection:)]){
        [self.scDelegate showcaseView:self willDisplaySection:indexPath.section];
    }
    [[(KEShowcaseTableViewCell*)cell horizontalTableView] reloadData];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if( [self.scDelegate respondsToSelector:@selector(showcaseView:didEndDisplaySection:)]){
        [self.scDelegate showcaseView:self didEndDisplaySection:indexPath.section];
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{

    KEShowcaseTableViewCell *cell = (KEShowcaseTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];

    return [cell.horizontalTableView numberOfRowsInSection:0];
    
}

- (void)reloadData{
    
    [self.tableView reloadData];

    
}


- (NSArray *)visibleSections{

    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [self.tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        NSIndexPath *indexPath = (NSIndexPath*)obj;
        [arr addObject:@(indexPath.section)];
        
    }];
    
    return [NSArray arrayWithArray:arr];
    
}


- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier forIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = [indexPath section];
    
    KEShowcaseTableViewCell *hTableView = (KEShowcaseTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    // if the showcaseTableView is out of visible bound, the hTableView will get nil
    
    return [hTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
}

- (UITableViewHeaderFooterView*)dequeueReusableHeaderFooterViewWithIdentifier:(NSString*)headerIdentifier{
    
    return (UITableViewHeaderFooterView*)[[self.tableView dequeueReusableCellWithIdentifier:headerIdentifier] contentView];
    
}



- (void)deleteSection:(NSInteger)section{
    
    
    NSIndexSet *idxSet = [[NSIndexSet alloc] initWithIndex:section];
    
    [self.tableView deleteSections:idxSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


- (void)insertSection:(NSInteger)section{
    
    NSIndexSet *idxSet = [[NSIndexSet alloc] initWithIndex:section];
    [self.tableView insertSections:idxSet withRowAnimation:UITableViewRowAnimationAutomatic];

    
}



- (void)reloadSection:(NSInteger)section{

    NSIndexSet *idxSet = [[NSIndexSet alloc] initWithIndex:section];

    @try {
        //[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    @catch (NSException *exception) {
        NSLog(@"number of row:%ld",(long)[self.tableView numberOfRowsInSection:section]);
        NSLog(@"number of section:%ld",(long)[self.tableView numberOfSections]);
        
    }
    @finally {
        
    }
    
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths{
    
    NSInteger section = [[indexPaths firstObject] section];
    
    KEShowcaseTableViewCell *cell = (KEShowcaseTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [cell insertRowsAtIndexPaths:indexPaths];

}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths{
    
    NSInteger section = [[indexPaths firstObject] section];
    
    KEShowcaseTableViewCell *cell = (KEShowcaseTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [cell deleteRowsAtIndexPaths:indexPaths];
    
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths{
    
    NSInteger section = [[indexPaths firstObject] section];
    
    KEShowcaseTableViewCell *cell = (KEShowcaseTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [cell reloadRowsAtIndexPaths:indexPaths];
    
}


- (UIView *)headerViewForSection:(NSInteger)section{
    
    return [self.tableView headerViewForSection:section];
    
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    
    if( [self.scDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)] ){
        
        [self.scDelegate scrollViewWillBeginDragging:scrollView];
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if( [self.scDelegate respondsToSelector:@selector( scrollViewDidScroll:)] ){
        
        
        [self.scDelegate scrollViewDidScroll:scrollView];
        
        
    }
    
    /* change the default behavior that headers stay on top of tableview */
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if( [self.scDelegate respondsToSelector:@selector( scrollViewDidEndDragging:willDecelerate:)] ){
        
        
        [self.scDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        
        
    }
    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    if ( [self.scDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]){
        [self.scDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    
}

@end
