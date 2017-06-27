//
//  KERotationPresentAnimation.h
//  Kono
//
//  Created by Kono on 2016/11/4.
//  Copyright © 2016年 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum KERotationDirection : NSUInteger{
    
    KERotationDirectionLeft = 0,
    KERotationDirectionRight = 1,
    KERotationDirectionDefault = 2
    
}KERotationDirection;


@interface KERotationPresentAnimation : NSObject<UIViewControllerAnimatedTransitioning>

- (id)initWithDirection:(KERotationDirection)rotateDirection;

@property (nonatomic)   KERotationDirection rotateDirection;

@end
