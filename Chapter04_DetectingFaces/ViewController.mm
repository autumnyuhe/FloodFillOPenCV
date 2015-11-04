/*****************************************************************************
 *   ViewController.m
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 5th May 2013
 ******************************************************************************
 *   Chapter 4 of the "OpenCV for iOS" book
 *
 *   Detecting Faces with Cascade Classifier shows how to detect faces
 *   using OpenCV.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/

#import "ViewController.h"
//#import "opencv2/highgui/ios.h"

#import <opencv2/imgcodecs/ios.h>

#include <stdio.h>
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core.hpp"

#include <iostream>

#import "FloodFillOBJ.h"

using namespace cv;
using namespace std;

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load cascade classifier from the XML file
//    NSString* cascadePath = [[NSBundle mainBundle]
//                     pathForResource:@"haarcascade_frontalface_alt"
//                              ofType:@"xml"];
//    faceDetector.load([cascadePath UTF8String]);
    
    //Load image with face
    UIImage* image = [UIImage imageNamed:@"star.png"];
    imageView.image = image ;
    
    
//    _imageView2.image = [FloodFillOBJ positionImage:[UIImage imageNamed:@"wall.jpg"] fromImage:[UIImage imageNamed:@"words.jpg"]];

//    cv::Mat faceImage;
//    UIImageToMat(image, faceImage);
    
//    // Convert to grayscale
//    cv::Mat gray;
//    cvtColor(faceImage, gray, CV_BGR2GRAY);
//    
//    // Detect faces
//    std::vector<cv::Rect> faces;
//    faceDetector.detectMultiScale(gray, faces, 1.1,
//                                 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
//    
//    // Draw all detected faces
//    for(unsigned int i = 0; i < faces.size(); i++)
//    {
//        const cv::Rect& face = faces[i];
//        // Get top-left and bottom-right corner points
//        cv::Point tl(face.x, face.y);
//        cv::Point br = tl + cv::Point(face.width, face.height);
//        
//        // Draw rectangle around the face
//        cv::Scalar magenta = cv::Scalar(255, 0, 255);
//        cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
//    }
//    
//    // Show resulting image
//    imageView.image = MatToUIImage(faceImage);
    
}

//Mat image0, image, gray, mask;
//int ffillMode = 1;
//int loDiff = 20, upDiff = 20;
//int connectivity = 4;
//int isColor = true;
//bool useMask = false;
//int newMaskVal = 255;
//
//-(void)onMouse:(int) x :(int) y
//{
//    cv::Point seed = cv::Point(x,y);
//    int lo = ffillMode == 0 ? 0 : loDiff;
//    int up = ffillMode == 0 ? 0 : upDiff;
//    int flags = connectivity + (newMaskVal << 8) +
//    (ffillMode == 1 ? CV_FLOODFILL_FIXED_RANGE : 0);
//    int b = (unsigned)theRNG() & 255;
//    int g = (unsigned)theRNG() & 255;
//    int r = (unsigned)theRNG() & 255;
//    cv::Rect ccomp;
//    
//    Scalar newVal = isColor ? Scalar(b, g, r) : Scalar(r*0.299 + g*0.587 + b*0.114);
//    Mat dst = isColor ? image : gray;
//    int area;
//    
//    if( useMask )
//    {
//        threshold(mask, mask, 1, 128, CV_THRESH_BINARY_INV);
//        area = floodFill(dst, mask, seed, newVal, &ccomp, Scalar(lo, lo, lo),
//                         Scalar(up, up, up), flags);
//
//    }
//    else
//    {
//        area = floodFill(dst, seed, newVal, &ccomp, Scalar(lo, lo, lo),
//                         Scalar(up, up, up), flags);
//    }
//    
////    imshow("image", dst);
//    imageView.image = MatToUIImage(dst);
//    cout << area << " pixels were repainted\n";
//}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint tpoint = [[[event allTouches] anyObject] locationInView:self.view];
    
    lastPoint = tpoint;
    
    imageView.image = [FloodFillOBJ floodFill:[UIImage imageNamed:@"star.png"] startPoint:tpoint newColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lena.png"]] lodiff:10];
    


    return;
//    UIImage* image2 = [UIImage imageNamed:@"star.png"];
//    UIImageToMat(image2, image0);
//    
//    if( image0.empty() )
//    {
//        cout << "Image empty. Usage: ffilldemo <image_name>\n";
//        return;
//    }
//    image0.copyTo(image);
//    mask.create(image0.rows+2, image0.cols+2, CV_8UC1);
//    
//    cout << "Grayscale mode is set\n";
//    cvtColor(image0, gray, CV_BGRA2BGR);
//    
//    mask = Scalar::all(0);
//    isColor = false;
//    
//    [self onMouse:tpoint.x :tpoint.y];
}

-(IBAction)changeDiff:(id)sender
{
    int diff = diffText.text.intValue;
    
    [diffText resignFirstResponder];
    imageView.image = [FloodFillOBJ floodFill:[UIImage imageNamed:@"star.png"] startPoint:lastPoint newColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lena.png"]] lodiff:diff];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
