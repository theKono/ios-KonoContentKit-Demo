//
//  KEBookLibraryHorizontalScrollCell.m
//  Kono
//
//  Created by Kono on 2016/4/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEBookLibraryHorizontalScrollCell.h"
#import "KEColor.h"


@implementation KEBookLibraryHorizontalScrollCell


- (void)awakeFromNib{

    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"KEBookLibraryItemCell" bundle:nil] forCellWithReuseIdentifier:horizonCellIdentifier];
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
}

- (void)setCellFrame:(CGSize)frameSize{
    
    UICollectionViewFlowLayout *colFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    colFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    colFlowLayout.itemSize = frameSize;
    colFlowLayout.minimumLineSpacing = 1;
    self.collectionView.collectionViewLayout = colFlowLayout;
    
}

@end
