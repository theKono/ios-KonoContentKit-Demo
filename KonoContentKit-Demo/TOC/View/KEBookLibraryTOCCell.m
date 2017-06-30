//
//  KEBookLibraryTOCCell.m
//  Kono
//
//  Created by Neo on 11/18/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import "KEBookLibraryTOCCell.h"



static NSInteger doubleTagBorderOffset = 16;
static NSInteger singleTagBorderOffset = 23;

@implementation KEBookLibraryTOCCell


@synthesize delegate = _delegate;

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

    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    if(_gestureReconizer==nil){
        _gestureReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOnView:)];

        _gestureReconizer.delegate = self;
        
        [self addGestureRecognizer:_gestureReconizer];
    }
    
}

-(KEArticleReadMode)readMode {
    return 0;
}

- (void)setReadMode:(KEArticleReadMode)readMode {
    CGSize basicSize;
    UIFont* tagFont = [UIFont systemFontOfSize:12];
    
    switch (readMode) {
        case KEArticleReadModeBoth:
            [self.readModeTag setTitle:@"PDF | EZ Read" forState:UIControlStateNormal];
            [self.readModeTag setHidden:NO];
             basicSize = [@"PDF | EZ Read" sizeWithSystemFontSize:tagFont];
            [self.readModeTag mas_updateConstraints:^(MASConstraintMaker *make){
                make.width.equalTo(@(basicSize.width + doubleTagBorderOffset ));
            }];
            break;
            
        case KEArticleReadModeFitReadingOnly:
            [self.readModeTag setTitle:@"EZ Read" forState:UIControlStateNormal];
            [self.readModeTag setHidden:NO];
            basicSize = [@"EZ Read" sizeWithSystemFontSize:tagFont];
            [self.readModeTag mas_updateConstraints:^(MASConstraintMaker *make){
                make.width.equalTo(@(basicSize.width + singleTagBorderOffset));
            }];
            break;
            
        case KEArticleReadModePDFOnly:
            [self.readModeTag setTitle:@"PDF" forState:UIControlStateNormal];
            [self.readModeTag setHidden:NO];
            basicSize = [@"PDF" sizeWithSystemFontSize:tagFont];
            [self.readModeTag mas_updateConstraints:^(MASConstraintMaker *make){
                make.width.equalTo(@(basicSize.width + singleTagBorderOffset));
            }];
            break;
            
        default:
            [self.readModeTag setHidden:YES];
            break;
    }
    
    
}

- (BOOL)isProvideMedia{
    
    return NO;
    
}


- (void)setIsProvideMedia:(BOOL)isProvideMedia{

    if( YES == isProvideMedia ){
        [self.mediaTag setHidden:NO];
    }
    else if( NO == isProvideMedia ){
        [self.mediaTag setHidden:YES];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    return YES;
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (void)touchOnView:(UIGestureRecognizer*)gestureRecongnizer{
    
    //if( !self.actionProcessed ){

        if( [self.delegate respondsToSelector:@selector(clickedOnCell:)]){
            
      //       self.actionProcessed = YES;

            [self.delegate clickedOnCell:self];

        //    self.actionProcessed = NO;
            
        }
        return;
    //}
    
    
}

- (void)dealloc{
    
    [self removeGestureRecognizer:_gestureReconizer];
    _gestureReconizer = nil;

}




@end
