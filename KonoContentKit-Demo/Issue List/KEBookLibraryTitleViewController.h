//
//  KEBookLibraryTitleViewController.h
//  Kono
//
//  Created by Kono on 6/14/17.
//  Copyright (c) 2017 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KELibraryTitleHeaderView.h"

@interface KEBookLibraryTitleViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate,KELibraryTitleHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
