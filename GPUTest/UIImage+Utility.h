//
//  UIImage+Utility.h
//  GPUTest
//
//  Created by Joseph on 2020/5/15.
//  Copyright © 2020 Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageByDrawingLeftHalfBlackOnImage:(UIImage *)image;
- (void)saveToFile:(NSString *)filename;
@end

NS_ASSUME_NONNULL_END
