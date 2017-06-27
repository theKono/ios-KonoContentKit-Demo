//
//  KEBookLibraryHorizontalScrollCell.h
//  Kono
//
//  Created by Kono on 2016/4/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *horizonCellIdentifier = @"horizonCellIdentifier";

@interface KEBookLibraryHorizontalScrollCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setCellFrame:(CGSize)frameSize;

@end
