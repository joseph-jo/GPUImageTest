//
//  ViewController.m
//  GPUTest
//
//  Created by Joseph on 2020/5/15.
//  Copyright © 2020 Joseph. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Utility.h"
#import "GPUImage.h"

@interface ViewController ()
 
@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor greenColor];
    
    UIImageView *imgViewColored = [[UIImageView alloc] initWithFrame:self.view.frame];
    imgViewColored.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgViewColored];
    
    UIImageView *imgViewGray = [[UIImageView alloc] initWithFrame:self.view.frame];
    imgViewGray.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgViewGray];
    
    //
    UIImage *inputImage = [UIImage imageNamed:@"Image"];
    UIImage *imgMask = nil;
    UIImage *imgResult = nil;
    
    // A. inputImage -> imgMask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        GPUImageChromaKeyFilter *chromaKeyFilter = [[GPUImageChromaKeyFilter alloc] init];
        [chromaKeyFilter setColorToReplaceRed:1/255.0 green:102/255.0 blue:255/255.0];
        chromaKeyFilter.thresholdSensitivity = .3;
        
        [imgSource addTarget:chromaKeyFilter];
        [chromaKeyFilter useNextFrameForImageCapture];
        [imgSource processImage];
        imgMask = [chromaKeyFilter imageFromCurrentFramebuffer];
    }
    [imgMask saveToFile:@"imgMask.png"];
    
    // HUE
//    {
//
//        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:inputImage];
//        GPUImageHueFilter *hueFilter = [[GPUImageHueFilter alloc] init];
//        [hueFilter setHue:128];
//
//        [imgSource addTarget:hueFilter];
//        [hueFilter useNextFrameForImageCapture];
//        [imgSource processImage];
//        inputImage = [hueFilter imageFromCurrentFramebuffer];
//
//    }
    
    // B. imgMask -> Gray imgMask
    {
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgMask];

       GPUImageGrayscaleFilter *grayscaleFilter = [GPUImageGrayscaleFilter new];
 
        [imgSourceMask addTarget:grayscaleFilter];
        [grayscaleFilter useNextFrameForImageCapture];
        [imgSourceMask processImage];
        
        imgMask = [grayscaleFilter imageFromCurrentFramebuffer];
    }
    [imgMask saveToFile:@"imgMask_Grayscaled.png"];
    
    
    // inputimage -> Grayscaled
    UIImage *imgGrayscaled = nil;
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:inputImage];

        GPUImageGrayscaleFilter *grayscaleFilter = [GPUImageGrayscaleFilter new];

       [imgSource addTarget:grayscaleFilter];
       [grayscaleFilter useNextFrameForImageCapture];
       [imgSource processImage];
       
       imgGrayscaled = [grayscaleFilter imageFromCurrentFramebuffer];
    }
    [imgGrayscaled saveToFile:@"imgGrayscaled.png"];
    
    
    // Masked mask 1
    UIImage *imgHalfMask = nil;
    {
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgGrayscaled];
        
        // Create mask img
        CGRect rectHalf = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
        UIImage *imgBase = [UIImage imageFromColor:[UIColor whiteColor] rect:rectHalf];
        UIImage *imgNewMask = [imgBase imageByDrawingLeftHalfBlackOnImage:imgBase];
        GPUImagePicture *imgSourceOtherMask = [[GPUImagePicture alloc] initWithImage:imgNewMask];
        
        GPUImageMaskFilter *maskFilter = [GPUImageMaskFilter new];
        [imgSourceMask addTarget:maskFilter];
        [imgSourceMask processImage];
        
        [maskFilter useNextFrameForImageCapture];
        
        [imgSourceOtherMask addTarget:maskFilter];
        [imgSourceOtherMask processImage];
        
        imgHalfMask = [maskFilter imageFromCurrentFramebuffer];
        
    }
    [imgHalfMask saveToFile:@"imgHalfMask.png"];
    
    // Masked mask 2
    // imgHalfMask + splashed imgMask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgMask];
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgHalfMask];

        GPUImageSourceOverBlendFilter *maskFilter = [GPUImageSourceOverBlendFilter new];

        [imgSource addTarget:maskFilter];
        [imgSource processImage];

        [maskFilter useNextFrameForImageCapture];

        [imgSourceMask addTarget:maskFilter];
        [imgSourceMask processImage];

        imgMask = [maskFilter imageFromCurrentFramebuffer];
    }
    [imgMask saveToFile:@"imgMask.png"];
    
    
    
    
    
    
    
    
    
    // -----
    
    // C. input Image + imgMask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgMask];

        GPUImageSourceOverBlendFilter *maskFilter = [GPUImageSourceOverBlendFilter new];

        [imgSource addTarget:maskFilter];
        [imgSource processImage];

        [maskFilter useNextFrameForImageCapture];

        [imgSourceMask addTarget:maskFilter];
        [imgSourceMask processImage];

        imgResult = [maskFilter imageFromCurrentFramebuffer];
    }
    [imgResult saveToFile:@"imgResult.png"];
     
//    imgViewGray.image = imgMask;
//    imgViewColored.image = inputImage;
    
    imgViewColored.image = imgResult;
}

@end
