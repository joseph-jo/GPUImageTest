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

#define COLOR_1 ([UIColor colorWithRed:205/255.0 green:52/255.0 blue:37/255.0 alpha:1])
#define COLOR_2 ([UIColor colorWithRed:0/255.0 green:102/255.0 blue:255/255.0 alpha:1])


@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnColor1;
@property (strong, nonatomic) IBOutlet UIButton *btnColor2;
@property (strong, nonatomic) IBOutlet UIButton *btnOriginal;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UISlider *sliderHue;

@property (strong, nonatomic) UIImage *imgInput;
@property (strong, nonatomic) UIImage *imgResult;
@property (strong, nonatomic) UIColor *colorSplash;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imgInput = [UIImage imageNamed:@"Image"];
    self.imgResult = nil;
    self.imgView.image = self.imgInput;
    
    [self.btnColor1 setBackgroundImage:[UIImage imageFromColor:COLOR_1 size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    
    [self.btnColor2 setBackgroundImage:[UIImage imageFromColor:COLOR_2 size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    
    [self.btnOriginal setBackgroundImage:self.imgInput forState:UIControlStateNormal];
    self.btnOriginal.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.sliderHue setMinimumValue:0.0];
    [self.sliderHue setValue:90.0];
    [self.sliderHue setMaximumValue:360];
    
    self.colorSplash = nil;
    
}

- (void)onSplashActionWithImg:(UIImage *)imgInput
{
    if (!self.colorSplash)
        return;
    
    UIImage *imgMask = nil;
    UIImage *imgResult = nil;
    
    // A. inputImage -> imgMask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgInput];
        GPUImageChromaKeyFilter *chromaKeyFilter = [[GPUImageChromaKeyFilter alloc] init];
        
        CGFloat red, green, blue, alpha = 0;
        [self.colorSplash getRed:&red green:&green blue:&blue alpha:&alpha];
        [chromaKeyFilter setColorToReplaceRed:red green:green blue:blue];
        chromaKeyFilter.thresholdSensitivity = .3;
        
        [imgSource addTarget:chromaKeyFilter];
        [chromaKeyFilter useNextFrameForImageCapture];
        [imgSource processImage];
        imgMask = [chromaKeyFilter imageFromCurrentFramebuffer];
    }
    [imgMask saveToFile:@"imgMask.png"];
    
    
    
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
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgInput];

        GPUImageGrayscaleFilter *grayscaleFilter = [GPUImageGrayscaleFilter new];

       [imgSource addTarget:grayscaleFilter];
       [grayscaleFilter useNextFrameForImageCapture];
       [imgSource processImage];
       
       imgGrayscaled = [grayscaleFilter imageFromCurrentFramebuffer];
    }
    [imgGrayscaled saveToFile:@"imgGrayscaled.png"];
    
    
    /*
    // Masked mask 1
    UIImage *imgHalfMask = nil;
    {
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgGrayscaled];
        
        // Create mask img
        UIImage *imgBase = [UIImage imageFromColor:[UIColor whiteColor] size:imgInput.size];
        UIImage *imgNewMask = [UIImage imageByDrawingLeftHalfBlackOnImage:imgBase];
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
    */
    
    
    
    
    
    
    
    
    // -----
    
    // C. input Image + imgMask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgInput];
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
    
    self.imgResult = imgResult;
    self.imgView.image = self.imgResult;
}

- (void)onHueActionWithImg:(UIImage *)imgInput val:(CGFloat)val
{
    // HUE
    GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgInput];
    GPUImageHueFilter *hueFilter = [[GPUImageHueFilter alloc] init];
    [hueFilter setHue:val];

    [imgSource addTarget:hueFilter];
    [hueFilter useNextFrameForImageCapture];
    [imgSource processImage];
    UIImage *imgResult = [hueFilter imageFromCurrentFramebuffer];
    
    self.imgView.image = imgResult;
}

- (IBAction)onSplashColorRed:(id)sender
{
    self.colorSplash = COLOR_1;
    [self onSplashActionWithImg:self.imgInput];
}

- (IBAction)onSplashColorCyan:(id)sender
{
    self.colorSplash = COLOR_2;
    [self onSplashActionWithImg:self.imgInput];
}

- (IBAction)onOriginal:(id)sender
{
    self.imgView.image = self.imgInput;
    self.imgResult = nil;
}

- (IBAction)onSliderValChanged:(UISlider *)sender
{
    if (!self.imgResult)
        return;
    
    [self onHueActionWithImg:self.imgResult val:sender.value];
}

@end
