//
//  FloodFillOBJ.h
//  Chapter04_DetectingFaces
//
//  Created by 马天龙 on 15/10/8.
//  Copyright (c) 2015年 Alexander Shishkov & Kirill Kornyakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloodFillOBJ : NSObject

+(UIImage *)floodFill:(UIImage *)srcimage startPoint:(CGPoint )point newColor:(UIColor *)newcolor lodiff:(int )lodiff;
+(UIImage *) ROI_AddImage:(UIImage *)srcimage fromImage:(UIImage *)targetImage;
+(UIImage *) ROI_LinearBlending:(UIImage *)srcimage fromImage:(UIImage *)targetImage;

+(UIImage *)blendImageFrom:(UIImage *)srcImage toImage:(UIImage *)targetImage;

+(UIImage *)positionImage:(UIImage *)srcimage fromImage:(UIImage *)targetImage;
@end
