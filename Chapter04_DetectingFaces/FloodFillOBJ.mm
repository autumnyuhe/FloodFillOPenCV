//
//  FloodFillOBJ.m
//  Chapter04_DetectingFaces
//
//  Created by 马天龙 on 15/10/8.
//  Copyright (c) 2015年 Alexander Shishkov & Kirill Kornyakov. All rights reserved.
//

#import "FloodFillOBJ.h"

#import <opencv2/imgcodecs/ios.h>

#include <stdio.h>
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core.hpp"
#include "poisson.h"

#include <iostream>
using namespace cv;
using namespace std;


@implementation FloodFillOBJ



+(UIImage *)floodFill:(UIImage *)srcimage startPoint:(CGPoint )point newColor:(UIColor *)newcolor lodiff:(int )diff
{
    Mat image0, image, gray, mask;
    int ffillMode = 1;
    //int loDiff = 20, upDiff = 20;
    int connectivity = 4;
    int isColor = true;
    bool useMask = false;
    int newMaskVal = 255;
    
    UIImageToMat(srcimage, image0);
    
    int loDiff = diff, upDiff = diff;
    
    if( image0.empty() )
    {
        cout << "Image empty. Usage: ffilldemo <image_name>\n";
        return nil;
    }
    
    image0.copyTo(image);
    mask.create(image0.rows+2, image0.cols+2, CV_8UC1);
    
    cout << "Grayscale mode is set\n";
    cvtColor(image0, gray, CV_BGRA2BGR);
    
    mask = Scalar::all(0);
    isColor = false;
    
    cv::Point seed = cv::Point(point.x,point.y);
    int lo = ffillMode == 0 ? 0 : loDiff;
    int up = ffillMode == 0 ? 0 : upDiff;
    int flags = connectivity + (newMaskVal << 8) +
    (ffillMode == 1 ? CV_FLOODFILL_FIXED_RANGE : 0);
    int b = (unsigned)theRNG() & 255;
    int g = (unsigned)theRNG() & 255;
    int r = (unsigned)theRNG() & 255;
    cv::Rect ccomp;
    
    Scalar newVal = isColor ? Scalar(b, g, r) : Scalar(r*0.299 + g*0.587 + b*0.114);
    Mat dst = isColor ? image : gray;
    int area;
    
    if( useMask )
    {
        threshold(mask, mask, 1, 128, CV_THRESH_BINARY_INV);
        area = floodFill(dst, mask, seed, newVal, &ccomp, Scalar(lo, lo, lo),
                         Scalar(up, up, up), flags);
        
    }
    else
    {
        area = floodFill(dst, seed, newVal, &ccomp, Scalar(lo, lo, lo),
                         Scalar(up, up, up), flags);
    }
    
    //    imshow("image", dst);
    cout << area << " pixels were repainted\n";
    return MatToUIImage(dst);
    
}

//

//----------------------------------【ROI_AddImage( )函数】----------------------------------
// 函数名：ROI_AddImage（）
//     描述：利用感兴趣区域ROI实现图像叠加
//----------------------------------------------------------------------------------------------
+(UIImage *) ROI_AddImage:(UIImage *)srcimage fromImage:(UIImage *)targetImage
{
    Mat srcImage1, logoImage;
    
    //【1】读入图像
//    Mat srcImage1= imread("dota_pa.jpg");
    
    UIImageToMat(srcimage, srcImage1);
    
//    Mat logoImage= imread("dota_logo.jpg");
    
    UIImageToMat(targetImage, logoImage);
    
    if(!srcImage1.data ) { printf("你妹，读取srcImage1错误~！ \n"); return nil; }
    if(!logoImage.data ) { printf("你妹，读取logoImage错误~！ \n"); return nil; }
    
    //【2】定义一个Mat类型并给其设定ROI区域
    Mat imageROI= srcImage1(cv::Rect(0,0,logoImage.cols,logoImage.rows));
    
    //【3】加载掩模（必须是灰度图）
    Mat mask= imread("dota_logo.jpg",0);
    
    //【4】将掩膜拷贝到ROI
    logoImage.copyTo(imageROI,mask);
    
//    //【5】显示结果
//    namedWindow("<1>利用ROI实现图像叠加示例窗口");
//    imshow("<1>利用ROI实现图像叠加示例窗口",srcImage1);
    
    return MatToUIImage(srcImage1);;
}


//---------------------------------【LinearBlending（）函数】-------------------------------------
// 函数名：LinearBlending（）
// 描述：利用cv::addWeighted（）函数实现图像线性混合
//--------------------------------------------------------------------------------------------
bool LinearBlending()
{
    //【0】定义一些局部变量
    double alphaValue = 0.5;
    double betaValue;
    Mat srcImage2, srcImage3, dstImage;
    
    //【1】读取图像 ( 两幅图片需为同样的类型和尺寸 )
    srcImage2= imread("mogu.jpg");
    srcImage3= imread("rain.jpg");
    
    if(!srcImage2.data ) { printf("你妹，读取srcImage2错误~！ \n"); return false; }
    if(!srcImage3.data ) { printf("你妹，读取srcImage3错误~！ \n"); return false; }
    
    //【2】进行图像混合加权操作
    betaValue= ( 1.0 - alphaValue );
    addWeighted(srcImage2, alphaValue, srcImage3, betaValue, 0.0, dstImage);
    
    //【3】创建并显示原图窗口
    namedWindow("<2>线性混合示例窗口【原图】 by浅墨", 1);
    imshow("<2>线性混合示例窗口【原图】 by浅墨", srcImage2 );
    
    namedWindow("<3>线性混合示例窗口【效果图】 by浅墨", 1);
    imshow("<3>线性混合示例窗口【效果图】 by浅墨", dstImage );
    
    return true;
    
}

//---------------------------------【ROI_LinearBlending（）】-------------------------------------
// 函数名：ROI_LinearBlending（）
// 描述：线性混合实现函数,指定区域线性图像混合.利用cv::addWeighted（）函数结合定义
//                     感兴趣区域ROI，实现自定义区域的线性混合
//--------------------------------------------------------------------------------------------
+(UIImage *) ROI_LinearBlending:(UIImage *)srcimage fromImage:(UIImage *)targetImage
{
    
    //【1】读取图像
    Mat srcImage4;
    
    UIImageToMat(srcimage, srcImage4);
    
    Mat logoImage;
    UIImageToMat(targetImage, logoImage);
    
    if(!srcImage4.data ) { printf("你妹，读取srcImage4错误~！ \n"); return nil; }
    if(!logoImage.data ) { printf("你妹，读取logoImage错误~！ \n"); return nil; }
    
    //【2】定义一个Mat类型并给其设定ROI区域
    Mat imageROI;
    //方法一
    imageROI=srcImage4(cv::Rect(0,0,logoImage.cols,logoImage.rows));
    //方法二
    //imageROI=srcImage4(Range(250,250+logoImage.rows),Range(200,200+logoImage.cols));
    
    //【3】将logo加到原图上
    addWeighted(imageROI,0.5,logoImage,0.5,0.,imageROI);
    
//    //【4】显示结果
//    namedWindow("<4>区域线性图像混合示例窗口 by浅墨");
//    imshow("<4>区域线性图像混合示例窗口 by浅墨",srcImage4);
    
    return MatToUIImage(srcImage4);
}

//blend position

IplImage *img0, *img1, *img2, *result, *res, *res1, *final, *final1;

CvPoint point;
int drag = 0;
int destx, desty;

int numpts = 50;
CvPoint* pts = new CvPoint[50];
CvPoint* pts1 = new CvPoint[50];
CvPoint* pts2 = new CvPoint[50];

int s = 0;
int flag = 0;
int flag1 = 0;

int minx,miny,maxx,maxy,lenx,leny;
int minxd,minyd,maxxd,maxyd,lenxd,lenyd;

int channel,num;

char src[50];
char dest[50];

float alpha,beta;

float red, green, blue;

void mouseHandler(int event, int x, int y, int flags, void* param)
{
    
    if (event == CV_EVENT_LBUTTONDOWN && !drag)
    {
        if(flag1 == 0)
        {
            if(s==0)
                img1 = cvCloneImage(img0);
            point = cvPoint(x, y);
            cvCircle(img1,point,2,CV_RGB(255, 0, 0),-1, 8, 0);
            pts[s] = point;
            s++;
            drag  = 1;
            if(s>1)
                cvLine(img1,pts[s-2], point, cvScalar(0, 0, 255, 0), 2, CV_AA, 0);
            
//            cvShowImage("Source", img1);
        }
    }
    
    
    if (event == CV_EVENT_LBUTTONUP && drag)
    {
//        cvShowImage("Source", img1);
        drag = 0;
    }
    if (event == CV_EVENT_RBUTTONDOWN)
    {
        flag1 = 1;
        img1 = cvCloneImage(img0);
        for(int i = s; i < numpts ; i++)
            pts[i] = point;
        
        if(s!=0)
        {
            cvPolyLine( img1, &pts, &numpts,1, 1, CV_RGB(0,0,0), 2, CV_AA, 0);
        }
        
        for(int i=0;i<s;i++)
        {
            minx = min(minx,pts[i].x);
            maxx = max(maxx,pts[i].x);
            miny = min(miny,pts[i].y);
            maxy = max(maxy,pts[i].y);
        }
        lenx = maxx - minx;
        leny = maxy - miny;
        
//        cvShowImage("Source", img1);
    }
    
    if (event == CV_EVENT_RBUTTONUP)
    {
        flag = s;
        
        cvZero(res1);
        cvZero(final);
        
        cvFillPoly(res1, &pts, &numpts, 1, CV_RGB(255, 255, 255), CV_AA, 0);
        
        cvAnd(img0, img0, final,res1);
        
//        cvNamedWindow("mask",1);
//        cvShowImage("mask", final);
        cvSaveImage("mask.jpg",final);
//        cvShowImage("Source", img1);
        if(num == 3)
        {
            Local_color_change obj;
            result = obj.color_change(img0,final,res1,red,green,blue);
            
            cvSaveImage("Output.jpg",result);
//            cvNamedWindow("Blended Image",1);
//            cvShowImage("Blended Image", result);
//            cvWaitKey(0);
//            cvDestroyWindow("Blended Image");
        }
        else if(num == 4)
        {
            Local_illum_change obj;
            result = obj.illum_change(img0,final,res1,alpha,beta);
            
            cvSaveImage("Output.jpg",result);
//            cvNamedWindow("Blended Image",1);
//            cvShowImage("Blended Image", result);
//            cvWaitKey(0);
//            cvDestroyWindow("Blended Image");
            
        }
        
    }
    if (event == CV_EVENT_MBUTTONDOWN)
    {
        for(int i = 0; i < numpts ; i++)
        {
            pts[i].x=0;
            pts[i].y=0;
        }
        s = 0;
        flag1 = 0;
//        cvShowImage("Source", img0);
        drag = 0;
    }
}


void mouseHandler1(int event, int x, int y, int flags, void* param)
{
    
    
    IplImage *im1;
    
    im1 = cvCloneImage(img2);
    if (event == CV_EVENT_LBUTTONDOWN)
    {
        if(flag1 == 1)
        {
            point = cvPoint(x, y);
            
            for(int i =0; i < numpts;i++)
                pts1[i] = pts[i];
            
            int tempx;
            int tempy;
            for(int i =0; i < flag; i++)
            {
                tempx = pts1[i+1].x - pts1[i].x;
                tempy = pts1[i+1].y - pts1[i].y;
                if(i==0)
                {
                    pts2[i+1].x = point.x + tempx;
                    pts2[i+1].y = point.y + tempy;
                }
                else if(i>0)
                {
                    pts2[i+1].x = pts2[i].x + tempx;
                    pts2[i+1].y = pts2[i].y + tempy;
                }
                
            }
            
            for(int i=flag;i<numpts;i++)
                pts2[i] = pts2[flag-1];
            
            pts2[0] = point;
            
            cvPolyLine( im1, &pts2, &numpts,1, 1, CV_RGB(255,0,0), 2, CV_AA, 0);
            
            destx = x;
            desty = y;
            
//            cvShowImage("Destination", im1);
        }
    }
    if (event == CV_EVENT_RBUTTONUP)
    {
        for(int i=0;i<flag;i++)
        {
            minxd = min(minxd,pts2[i].x);
            maxxd = max(maxxd,pts2[i].x);
            minyd = min(minyd,pts2[i].y);
            maxyd = max(maxyd,pts2[i].y);
        }
        
        if(maxxd > im1->width || maxyd > im1->height || minxd < 0 || minyd < 0)
        {
            cout << "Index out of range" << endl;
            exit(0);
        }
        
        int k,l;
        for(int i=miny, k=minyd;i<(miny+leny);i++,k++)
            for(int j=minx,l=minxd ;j<(minx+lenx);j++,l++)
            {
                for(int c=0;c<channel;c++)
                {
                    CV_IMAGE_ELEM(final1,uchar,k,l*channel+c) = CV_IMAGE_ELEM(final,uchar,i,j*channel+c);
                }
            }
        
        
        cvFillPoly(res, &pts2, &numpts, 1, CV_RGB(255, 255, 255), CV_AA, 0);
        
        if(num == 1 || num == 2 || num == 5)
        {
            Normal_Blending obj;
            result = obj.normal_blend(img2,final1,res,num);
        }
        
        cvZero(res);
        for(int i = 0; i < flag ; i++)
        {
            pts2[i].x=0;
            pts2[i].y=0;
        }
        
        minxd = 100000; minyd = 100000; maxxd = -100000; maxyd = -100000;
        
        ////////// save blended result ////////////////////
        
        cvSaveImage("Output.jpg",result);
//        cvNamedWindow("Blended Image",1);
//        cvShowImage("Blended Image", result);
//        cvWaitKey(0);
//        cvDestroyWindow("Blended Image");
    }
    
    cvReleaseImage(&im1);
}

void checkfile(char *file)
{
    while(1)
    {
        printf("Enter %s Image: ",file);
        if(!strcmp(file,"Source"))
        {
            cin >> src;
            if(access( src, F_OK ) != -1 )
            {
                break;
            }
            else
            {
                printf("Image doesn't exist\n");
            }
        }
        else if(!strcmp(file,"Destination"))
        {
            cin >> dest;
            
            if(access( dest, F_OK ) != -1 )
            {	
                break;
            }
            else
            {
                printf("Image doesn't exist\n");
            }
            
        }
    }
}

+ (IplImage *)convertToIplImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height),
                                       IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast |
                                                    kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGB2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// 把IplImage类型转换成UIImage类型.
// NOTE You should convert color mode as RGB before passing to this function.
+ (UIImage *)convertToUIImage:(IplImage *)image {
    NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s",
          image->width,
          image->height,
          image->depth,
          image->nChannels,
          image->widthStep,
          image->channelSeq);
    cvCvtColor(image, image, CV_BGR2RGB);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone |
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

+(UIImage *)positionImage:(UIImage *)srcimage fromImage:(UIImage *)targetImage
{
    
//    cout << " Poisson Image Editing" << endl;
//    cout << "-----------------------" << endl;
//    cout << "Options: " << endl;
//    cout << endl;
//    cout << "1) Poisson Blending " << endl;
//    cout << "2) Mixed Poisson Blending " << endl;
//    cout << "3) Local Color Change " << endl;
//    cout << "4) Local Illumination Change " << endl;
//    cout << "5) Monochrome Transfer " << endl;
//    cout << "6) Texture Flattening " << endl;
//    
//    cout << endl;
//    
//    cout << "Press number 1-6 to choose from above techniques: ";
//    cin >> num;
//    cout << endl;
    
    num = 1;
    
    char s[]="Source";
    char d[]="Destination";
    
    minx = 100000; miny = 100000; maxx = -100000; maxy = -100000;
    
    minxd = 100000; minyd = 100000; maxxd = -100000; maxyd = -100000;
    
    
    if(num == 1 || num == 2 || num == 5)
    {
        
//        checkfile(s);
//        checkfile(d);
        
        img0 = [self convertToIplImage:srcimage];
        
        img2 = [self convertToIplImage:targetImage];
        
        
//        UIImageToMat(srcimage, img0);
        
        
        channel = img0->nChannels;
        
        res = cvCreateImage(cvGetSize(img2), 8, 1);
        res1 = cvCreateImage(cvGetSize(img0), 8, 1);
        final = cvCreateImage(cvGetSize(img0), 8, 3);
        final1 = cvCreateImage(cvGetSize(img2), 8, 3);
        cvZero(res1);
        cvZero(final);
        cvZero(final1);
        //////////// source image ///////////////////
        
//        cvNamedWindow("Source", 1);
//        cvSetMouseCallback("Source", mouseHandler, NULL);
        
        mouseHandler(1, 0, 0, 1, nil);
        
        mouseHandler(5,0,0,1, nil);
//        cvShowImage("Source", img0);
        
        /////////// destination image ///////////////
        
//        cvNamedWindow("Destination", 1);
//        cvSetMouseCallback("Destination", mouseHandler1, NULL);
//        cvShowImage("Destination",img2);
        
        mouseHandler1(5, 0, 0, 1, nil);
        
//        cvWaitKey(0);
//        cvDestroyWindow("Source");
//        cvDestroyWindow("Destination");
        
//        cvReleaseImage(&img0);
//        cvReleaseImage(&img1);
//        cvReleaseImage(&img2);
        
        return [self convertToUIImage:result];
    }
    else if(num == 3)
    {
        checkfile(s);
        
        cout << "Enter RGB values: " << endl;
        cout << "Red: ";
        cin >> red;
        
        cout << "Green: ";
        cin >> green;
        
        cout << "Blue: ";
        cin >> blue;
        
        img0 = cvLoadImage(src);
        
        res1 = cvCreateImage(cvGetSize(img0), 8, 1);
        final = cvCreateImage(cvGetSize(img0), 8, 3);
        cvZero(res1);
        cvZero(final);
        
        //////////// source image ///////////////////
        
        cvNamedWindow("Source", 1);
        cvSetMouseCallback("Source", mouseHandler, NULL);
        cvShowImage("Source", img0);
        
        cvWaitKey(0);
        cvDestroyWindow("Source");
        
        cvReleaseImage(&img0);
    }
    else if(num == 4)
    {
        checkfile(s);
        
        cout << "alpha: ";
        cin >> alpha;
        
        cout << "beta: ";
        cin >> beta;
        
        img0 = cvLoadImage(src);
        
        res1 = cvCreateImage(cvGetSize(img0), 8, 1);
        final = cvCreateImage(cvGetSize(img0), 8, 3);
        cvZero(res1);
        cvZero(final);
        
        //////////// source image ///////////////////
        
        cvNamedWindow("Source", 1);
        cvSetMouseCallback("Source", mouseHandler, NULL);
        cvShowImage("Source", img0);
        
        cvWaitKey(0);
        cvDestroyWindow("Source");
        
        cvReleaseImage(&img0);
    }
    else if(num == 6)
    {
        checkfile(s);
        
        img0 = cvLoadImage(src);
        
        Texture_flat obj;
        result = obj.tex_flattening(img0);
        
        cvSaveImage("Output.jpg",result);
        cvNamedWindow("Image cloned",1);
        cvShowImage("Image cloned", result);
        cvWaitKey(0);
        cvDestroyWindow("Image cloned");
        
        cvWaitKey(0);
        cvDestroyWindow("Source");
        
        cvReleaseImage(&img0);
    }
    
    cvReleaseImage(&res);
    cvReleaseImage(&res1);
    cvReleaseImage(&final);
    cvReleaseImage(&final1);
    cvReleaseImage(&result);
    
    return 0;
}

+(UIImage *)blendImageFrom:(UIImage *)srcImage toImage:(UIImage *)targetImage
{
    double alpha = 0.5; double beta; double input;
    
    Mat src1, src2, dst;
    
//    /// Ask the user enter alpha
//    std::cout<<" Simple Linear Blender "<<std::endl;
//    std::cout<<"-----------------------"<<std::endl;
//    std::cout<<"* Enter alpha [0-1]: ";
//    std::cin>>input;
    
    input = 0.3;
    
    /// We use the alpha provided by the user iff it is between 0 and 1
    if( alpha >= 0 && alpha <= 1 )
    { alpha = input; }
    
    /// Read image ( same size, same type )
    UIImageToMat(srcImage, src1);
//    src2 = imread("../../images/WindowsLogo.jpg");
    
    UIImageToMat(targetImage, src2);
    
    if( !src1.data ) { printf("Error loading src1 \n"); return nil; }
    if( !src2.data ) { printf("Error loading src2 \n"); return nil; }
    
    /// Create Windows
//    namedWindow("Linear Blend", 1);
    
    beta = ( 1.0 - alpha );
    addWeighted( src2, alpha, src1, beta, 0.0, dst);
    
//    imshow( "Linear Blend", dst );
    
    return MatToUIImage(dst);
    
}

@end
