//
//  KETextUtil.h
//  Kono
//
//  Created by Neo on 5/8/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KETextUtil : NSObject


+ (NSAttributedString*)quote:(NSString*)quote;

+ (NSAttributedString*)socialDescription:(NSString*)message;

+ (NSAttributedString*)notificationDescription:(NSString*)message;

+ (NSAttributedString*)commentMessage:(NSString*)message;


+ (NSAttributedString*)promotionString:(NSString*)promotion;

+ (NSAttributedString*)magazineInfoDescription:(NSString*)infoString;

+ (NSAttributedString*)attributedStringWithColor:(UIColor*)color withFontSize:(float)size withText:(NSString*)text;

+ (NSAttributedString *)attributedStringWithColor:(UIColor *)color withFontSize:(float)size withLineSpacing:(float)lineSpacing withText:(NSString*)text;

+ (NSAttributedString *)attributedStringWithColor:(UIColor *)color withFontSize:(float)size withLineSpacing:(float)lineSpacing withTruncateMode:(NSLineBreakMode)mode withText:(NSString*)text;

@end
