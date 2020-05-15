//
//  UIImage+Utility.m
//  GPUTest
//
//  Created by Joseph on 2020/5/15.
//  Copyright © 2020 Joseph. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)


+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect {
//    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
 
- (UIImage *)imageByDrawingLeftHalfBlackOnImage:(UIImage *)image
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

    // make circle rect 5 px from border
//    CGRect circleRect = CGRectMake(0, 0,
//                image.size.width,
//                image.size.height);
//    circleRect = CGRectInset(circleRect, 5, 5);
//
//    // draw circle
//    CGContextStrokeEllipseInRect(ctx, circleRect);

    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();

    // free the context
    UIGraphicsEndImageContext();

    return retImage;
}
- (void)saveToFile:(NSString *)filename
{
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];

    NSLog(@"file saved: %@", filePath);
    // Save image.
    [UIImagePNGRepresentation(self) writeToFile:filePath atomically:YES];
}
@end
