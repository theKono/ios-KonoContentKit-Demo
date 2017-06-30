//
//  KEBookLibraryItemCell.m
//  Kono
//
//  Created by Neo on 11/18/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import "KEBookLibraryItemCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation KEBookLibraryItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.itemImage.layer.cornerRadius = 2;

}


@end
