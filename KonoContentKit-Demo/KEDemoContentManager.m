//
//  KEDemoContentManager.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/11/15.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KEDemoContentManager.h"

@interface KEDemoContentManager ()

@property (nonatomic) NSInteger currentHightSentenceIdx;
@property (nonatomic, strong) KonoFitreadingView *viewer;
@property (nonatomic) NSTimer *autoPlayTimer;

@end


@implementation KEDemoContentManager

- (id)initWithViewer:(KonoFitreadingView *)viewer {
    
    self = [super init];
    if( self ){
        self.viewer = viewer;
        self.currentHightSentenceIdx = -1;
    }
    return self;
}

- (void)autoPlay {
    
    self.autoPlayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playNext) userInfo:nil repeats:YES];
    
}

- (void)stop {
    
    [self.autoPlayTimer invalidate];
    self.autoPlayTimer = nil;
    
}

- (void)playNext{
    
    self.currentHightSentenceIdx = MIN(self.totalSentenceCount - 1, self.currentHightSentenceIdx +1);
    
    [self.viewer stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"scrollSentenceToMiddle('%ld')",(long)self.currentHightSentenceIdx]];
    [self.viewer stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"highlightSentence('%ld')",(long)self.currentHightSentenceIdx]];
    
    
}

- (void)playPrevious{
    
    self.currentHightSentenceIdx = MAX(0, self.currentHightSentenceIdx - 1);
    
    [self.viewer stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"scrollSentenceToMiddle('%ld')",(long)self.currentHightSentenceIdx]];
    [self.viewer stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"highlightSentence('%ld')",(long)self.currentHightSentenceIdx]];
    
}


- (void)querySelectedText {
    
    NSString * highlighted = [self.viewer stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    [self.viewer stringByEvaluatingJavaScriptFromString:@"removeHighLight()"];
    
    NSLog(@"highlighted string:%@",highlighted);
    
}

- (void)highlightSelectedTextSection {
    
    NSString *highlightDomID = [self.viewer stringByEvaluatingJavaScriptFromString:@"highlightSelectedTextSection()"];
    
    NSArray *components = [highlightDomID componentsSeparatedByString:@"-"];
    self.currentHightSentenceIdx = [[components lastObject] integerValue];

}

@end
