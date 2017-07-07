//
//  KEBookLibraryTitleViewController.h
//  Kono
//
//  Created by Neo on 4/14/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KEShowcaseTableView.h"
#import "KELibraryBookCell.h"
#import "KELibraryTitleHeaderView.h"

@interface KEBookLibraryTitleViewController : UIViewController<KEShowcaseTableViewDelegate, KEShowcaseTableViewDatasource, KELibraryTitleHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet KEShowcaseTableView *showcaseTableView;

@end
