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
@property (strong, nonatomic) IBOutlet UIImageView *imgFullColorView;
@property (strong, nonatomic) IBOutlet UIImageView *imgMaskView;
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
    self.imgFullColorView.image = self.imgInput;
    self.imgMaskView.image = nil;
    self.view.backgroundColor = [UIColor greenColor];
    
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
    
    // B. imgAlphaMask -> imgBlackWhiteMask
    UIImage *imgAlphaMask = imgMask;
    UIImage *imgBlackWhiteMask = nil;
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc]
                                      initWithImage:imgAlphaMask];

        GPUImageColorMatrixFilter *colorMatrixFilter = [GPUImageColorMatrixFilter new];
        colorMatrixFilter.colorMatrix = (GPUMatrix4x4){
            {0, 0, 0, 1},
            {0, 0, 0, 1},
            {0, 0, 0, 1},
            {1, 1, 1, 1}};
        
        [imgSource addTarget:colorMatrixFilter];
        [colorMatrixFilter useNextFrameForImageCapture];
        [imgSource processImage];

        imgBlackWhiteMask = [colorMatrixFilter imageFromCurrentFramebuffer];
        
        
        // .....
        UIImage *imgBlack = [UIImage imageFromColor:[UIColor blackColor] size:imgBlackWhiteMask.size];
        {
            GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgBlack];
            GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgBlackWhiteMask];

            GPUImageNormalBlendFilter *maskFilter = [GPUImageNormalBlendFilter new];

            [imgSource addTarget:maskFilter];
            [imgSource processImage];

            [maskFilter useNextFrameForImageCapture];

            [imgSourceMask addTarget:maskFilter];
            [imgSourceMask processImage];

            imgBlackWhiteMask = [maskFilter imageFromCurrentFramebuffer];
        }
    }
    [imgBlackWhiteMask saveToFile:@"imgBlackWhiteMask.png"];
    
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
    
    
    // imgGrayscaled + blackwhite mask
    {
        GPUImagePicture *imgSource = [[GPUImagePicture alloc] initWithImage:imgGrayscaled];
        GPUImagePicture *imgSourceMask = [[GPUImagePicture alloc] initWithImage:imgBlackWhiteMask];
        
        GPUImageMaskFilter *maskFilter = [GPUImageMaskFilter new];
        [imgSource addTarget:maskFilter];
        [imgSource processImage];
        
        [maskFilter useNextFrameForImageCapture];
        
        [imgSourceMask addTarget:maskFilter];
        [imgSourceMask processImage];
        
        imgResult = [maskFilter imageFromCurrentFramebuffer];
    }
    [imgResult saveToFile:@"imgResult.png"];
    self.imgResult = imgResult;
    self.imgMaskView.image = self.imgResult;
    return;
    
    
    
    
    
    
    
    
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
    
    self.imgFullColorView.image = imgResult;
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
    self.imgFullColorView.image = self.imgInput;
    self.imgMaskView.image = nil;
}

- (IBAction)onSliderValChanged:(UISlider *)sender
{
    [self onHueActionWithImg:self.imgInput val:sender.value];
}

@end
