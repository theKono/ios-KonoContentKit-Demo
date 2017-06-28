//
//  KEUtil.m
//  Kono
//
//  Created by Neo on 12/12/13.
//  Copyright (c) 2013 Kono. All rights reserved.
//

#import "KEColor.h"
#import "KEUtil.h"
#import <sys/utsname.h>

#define kChunkSizeBytes (1024)

@implementation NSString (KEString)

- (CGSize)sizeWithSystemFontSize:(UIFont *)font{
    
    return [self sizeWithAttributes:@{NSFontAttributeName: font}];
}

@end

@implementation NSMutableDictionary (DefaultDictionary)


- (void)addObject:(id)obj forKey:(id<NSCopying>)key{

    NSMutableArray *arr = [self objectForKey:key];
    
    if (arr == nil ){
        
        arr = [[NSMutableArray alloc] init];
        
        [arr addObject:obj];
        
        [self setObject:arr forKey:key];
        
    }else{
        
        [arr addObject:obj];
        
    }
}


@end

@implementation PushAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //[[transitionContext containerView] addSubview:toViewController.view];
    
    [transitionContext.containerView addSubview:toViewController.view];
    //toViewController.view.alpha = 0.0;
    
    CGRect endFrame = toViewController.view.frame;
    CGRect startFrame = endFrame;
    startFrame.origin.x -= 320;
    
    toViewController.view.frame = startFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //toViewController.view.alpha = 1.0;
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        toViewController.view.frame = endFrame;
    } completion:^(BOOL finished) {
        //[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [transitionContext completeTransition:YES];
    }];
}

@end

@implementation PopAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect endFrame = toViewController.view.frame;
    CGRect startFrame = endFrame;
    startFrame.origin.x += 320;
    
    toViewController.view.frame = startFrame;
    
    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];
    //[[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //fromViewController.view.alpha = 0.0;
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        toViewController.view.frame = endFrame;
    } completion:^(BOOL finished) {
        //[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [transitionContext completeTransition:YES];
    }];
}

@end


@implementation KEUtil

#pragma mark - ViewController operating function

+ (UIViewController *)getCurrentViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}


+ (void)popToNavigationController:(UINavigationController *)rootNavigationController completion:(void (^)(void))completionBlock {
    
    UINavigationController *currentNavigationController = [self getCurrentViewController].navigationController;
    
    if ( rootNavigationController != currentNavigationController ) {
        
        [currentNavigationController dismissViewControllerAnimated:NO completion:^{
            
            [self popToNavigationController:rootNavigationController completion:completionBlock];
            
        }];
        
    }
    else {
        completionBlock();
    }
    
}

#pragma mark - alert or toast util function

+ (void)showGlobalAlert:(NSString *)msg {
    
    UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:@"Notifications"
                          message:msg
                         delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles: nil];
    
    [alertView show];
    
}

#pragma mark - file related 

+ (NSString *)getPDFPageRatio:(NSString *)htmlFilePath {
    
    NSString *pdfPageRatio;
    
    NSString* content = [NSString stringWithContentsOfFile:htmlFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *divComponent = [content componentsSeparatedByString:@"<div class="];
    
    for( NSString *seperateStr in divComponent ){
        
        if( [seperateStr hasPrefix:@"\"stub\""] ){
            
            NSArray *subComponent = [seperateStr componentsSeparatedByString:@"padding-top: "];
            NSString *targetString = [subComponent lastObject];
            NSRange range = [targetString rangeOfString:@"\">"];
            if( range.location != NSNotFound ){
                pdfPageRatio = [targetString substringToIndex:range.location];
            }
            else{
                pdfPageRatio = @"100%";
            }
        }
        
    }
    if( nil == pdfPageRatio ){
        pdfPageRatio = @"100%";
    }
    
    return pdfPageRatio;
}

+ (NSString*)getDeviceName{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)getLandscapeHTML:(NSString *)magazineBid leftFilePath:(NSString *)leftFilePath withLeftRatio:(NSString *)leftFileRatio disableLeftPage:(BOOL)isLeftPageDisable rightFilePath:(NSString *)rightFilePath withRightRatio:(NSString *)rightFileRatio disableRightPage:(BOOL)isRightPageDisable ISOFilePath:(NSString *)ISOFilePath withISORatio:(NSString *)ISOFileRatio disableISOPage:(BOOL)isISOPageDisable isISOMode:(BOOL)isISOMode {
    
    NSString *landscapeFilePath;
    NSString *templateFileName = [[NSBundle mainBundle] pathForResource:@"landscape"
                                                         ofType:@"html"];
    NSMutableString *landscapeTemplate = [NSMutableString stringWithContentsOfFile:templateFileName
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSMutableString *customizeLandscapeFile = [[landscapeTemplate stringByReplacingOccurrencesOfString:@"$LEFT_PAGE" withString:leftFilePath] mutableCopy];
    customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$RATIO_LEFT" withString:leftFileRatio] mutableCopy];
    if( YES == isLeftPageDisable ){
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_LEFT_PAGE" withString:@"true"] mutableCopy];
    }
    else{
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_LEFT_PAGE" withString:@"false"] mutableCopy];
    }
    
    customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$RIGHT_PAGE" withString:rightFilePath] mutableCopy];
    customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$RATIO_RIGHT" withString:rightFileRatio] mutableCopy];
    if( YES == isRightPageDisable ){
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_RIGHT_PAGE" withString:@"true"] mutableCopy];
    }
    else{
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_RIGHT_PAGE" withString:@"false"] mutableCopy];
    }
    customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$ISO_PAGE" withString:ISOFilePath] mutableCopy];
    customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$RATIO_ISO" withString:ISOFileRatio] mutableCopy];
    
    if( YES == isISOPageDisable ){
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_ISO_PAGE" withString:@"true"] mutableCopy];
    }
    else{
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$DISABLE_ISO_PAGE" withString:@"false"] mutableCopy];
    }
    
    if( YES == isISOMode ){
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$ENABLE_ISO_PAGE" withString:@"true"] mutableCopy];
    }
    else{
        customizeLandscapeFile = [[customizeLandscapeFile stringByReplacingOccurrencesOfString:@"$ENABLE_ISO_PAGE" withString:@"false"] mutableCopy];
    }
    NSError *error;
    NSString *docsFolder = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"Caches/tmpBooks/%@", magazineBid]];
    
    NSString *leftPageNumber = [[[leftFilePath stringByDeletingLastPathComponent] componentsSeparatedByString:@"/"] lastObject] ;
    NSString *rightPageNumber = [[[rightFilePath stringByDeletingLastPathComponent] componentsSeparatedByString:@"/"] lastObject] ;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docsFolder] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:docsFolder] withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            NSLog(@"[Landscape file Directory] %@", [error description]);
            return nil;
        }
    }
    
    
    landscapeFilePath = [docsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.html",leftPageNumber,rightPageNumber]];
    
    // save the NSString that contains the HTML to a file
    
    [customizeLandscapeFile writeToFile:landscapeFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    return landscapeFilePath;
    
}

+ (BOOL)fileExistsAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

+ (NSDictionary *)listFileAttribute:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [[NSDictionary alloc] init];
    if ([fileManager fileExistsAtPath:path]) {
        attributes = [fileManager attributesOfItemAtPath:path error:nil];
    }
    return attributes;
}

+ (void)removeAllDataAtPath:(NSString*)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:path]){
        
        [fileManager removeItemAtPath:path error:&error];
        
    }
    
}

#pragma mark - color tools
+ (UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end


