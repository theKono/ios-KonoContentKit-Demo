//
//  KEDemoContentManager.h
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/11/15.
//  Copyright © 2017年 kono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KonoFitreadingView.h"


@interface KEDemoContentManager : NSObject

@property (nonatomic) NSInteger totalSentenceCount;

- (id)initWithViewer:(KonoFitreadingView *)viewer;

- (void)autoPlay;

- (void)stop;

- (void)playNext;

- (void)playPrevious;

@end
