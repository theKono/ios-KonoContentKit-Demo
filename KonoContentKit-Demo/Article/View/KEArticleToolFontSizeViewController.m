//
//  KEArticleToolFontSizeViewController.m
//  Kono
//
//  Created by Kono on 2016/7/27.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KEArticleToolFontSizeViewController.h"
static int defaultFontSizeScale = 20;

@interface KEArticleToolFontSizeViewController ()

@end

@implementation KEArticleToolFontSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSInteger storeFontSizeOffset;
    
    if( [[storage objectForKey:@"KEArticleFontSize"] isKindOfClass:[NSNumber class]]){
        storeFontSizeOffset = [[storage objectForKey:@"KEArticleFontSize"] integerValue];
        self.adjustBar.value = ((float)storeFontSizeOffset / (float)defaultFontSizeScale) + 0.5;
    }
    self.adjustLabel.text = @"Font Size";
    [self.adjustBar setThumbImage:[UIImage imageNamed:@"adjustBarThumbimage"] forState:UIControlStateNormal];
    [self.adjustBar setThumbImage:[UIImage imageNamed:@"adjustBarThumbimage"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)valueChanged:(id)sender {

    //NSUInteger index = (NSUInteger)(slider.value + 0.5);
    //[slider setValue:index animated:NO];
    NSInteger adjustFontSize = (int)(( self.adjustBar.value - 0.5 ) * (float)defaultFontSizeScale);

    if( [self.delegate respondsToSelector:@selector(slideFontSizeController:)]){
        [self.delegate slideFontSizeController:adjustFontSize];
    }


}


@end
