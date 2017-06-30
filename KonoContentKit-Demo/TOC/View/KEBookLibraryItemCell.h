//
//  KEBookLibraryItemCell.h
//  Kono
//
//  Created by Neo on 11/18/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEBookLibraryItemCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *itemImage;

@property (weak, nonatomic) IBOutlet UIView *currentPageIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *itemBackgroundView;

@end
