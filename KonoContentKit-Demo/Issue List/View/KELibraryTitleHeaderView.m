//
//  KELibraryTitleHeaderView.m
//  Kono
//
//  Created by Kono on 2015/7/22.
//  Copyright (c) 2015年 Kono. All rights reserved.
//

#import "KELibraryTitleHeaderView.h"

@implementation KELibraryTitleHeaderView


- (void)awakeFromNib{
    
    [super awakeFromNib];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)showDescriptionBtnPressed:(id)sender {

    if( self.showDescriptionBtn.selected == YES){
        
        [self.delegate showDescriptionBtnPressed:NO];
        self.showDescriptionBtn.selected = NO;
    }
    else if( self.showDescriptionBtn.selected == NO ){
        [self.delegate showDescriptionBtnPressed:YES];
        self.showDescriptionBtn.selected = YES;
    }
    
}

@end
