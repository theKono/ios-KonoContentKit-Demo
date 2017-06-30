//
//  KELibraryTitleHeaderView.h
//  Kono
//
//  Created by Kono on 2015/7/22.
//  Copyright (c) 2015年 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KELibraryTitleHeaderView;

@protocol KELibraryTitleHeaderViewDelegate <NSObject>

- (void)showDescriptionBtnPressed:(BOOL)wantExpendView;

@end


@interface KELibraryTitleHeaderView : UIView

@property (nonatomic, weak) id<KELibraryTitleHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleDescription;
@property (weak, nonatomic) IBOutlet UIButton *showDescriptionBtn;

@end
