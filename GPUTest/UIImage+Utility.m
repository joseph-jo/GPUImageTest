//
//  UIImage+Utility.m
//  GPUTest
//
//  Created by Joseph on 2020/5/15.
//  Copyright © 2020 Joseph. All rights reserved.
//

#import "UIImage+Utility.h"
#define DEBUG_IMG

@implementation UIImage (Utility)


+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
 
+ (UIImage *)imageByDrawingLeftHalfBlackOnImage:(UIImage *)image
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);

    // draw original image into the context
    [image drawAtPoint:CGPointZero];

    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // set stroking color and draw circle
    [[UIColor blackColor] setFill];
     
    CGContextFillRect(ctx, CGRectMake(0, 0, image.size.width / 2, image.size.height));

    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();

    // free the context
    UIGraphicsEndImageContext();

    return retImage;
}

- (void)saveToFile:(NSString *)filename
{
#ifndef DEBUG_IMG
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];

    NSLog(@"file saved: %@", filePath);
    // Save image.
    [UIImagePNGRepresentation(self) writeToFile:filePath atomically:YES];
#endif
}
@end
