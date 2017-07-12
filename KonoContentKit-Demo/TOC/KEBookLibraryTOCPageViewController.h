//
//  KEBookLibraryTOCPageViewController.h
//  Kono
//
//  Created by Kono on 2016/4/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEBookLibraryTOCTableCell.h"
#import "KEBookLibraryHorizontalScrollCell.h"



@class KEMagazineItem;


@interface KEBookLibraryTOCPageViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) KCBook *bookItem;

@property (nonatomic, strong) UIViewController *baseViewController;

@property (nonatomic) NSInteger targetArticleIndex;

@property (nonatomic) NSInteger targetPageIndex;


@property (weak, nonatomic) IBOutlet UIView *navigationView;

@property (weak, nonatomic) IBOutlet UILabel *magazineIssueName;

@property (weak, nonatomic) IBOutlet UITableView *previewTableView;

@property (weak, nonatomic) IBOutlet UITableView *tocTableView;

@property (weak, nonatomic) IBOutlet UIButton *infoBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
