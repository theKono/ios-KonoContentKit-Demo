//
//  KERotationPresentAnimation.m
//  Kono
//
//  Created by Kono on 2016/11/4.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import "KERotationPresentAnimation.h"

@implementation KERotationPresentAnimation


- (id)initWithDirection:(KERotationDirection)rotateDirection{
    
    self = [super init];
    if( self ){
        self.rotateDirection = rotateDirection;
    }
    
    return self;
    
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.2f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
   
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
   
    CGRect finalRect = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = finalRect;
    
    switch ( self.rotateDirection ) {
        case KERotationDirectionLeft:
            toVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case KERotationDirectionRight:
            toVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        default:
            break;
    }
    toVC.view.alpha = 0.2;
   
    [[transitionContext containerView]addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        toVC.view.transform = CGAffineTransformMakeRotation(0);
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
    }];
    
}


@end
