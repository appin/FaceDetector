//
//  ViewController.h
//  FaceDetector
//
//  Created by Atsushi Yoshida on 2014/01/30.
//  Copyright (c) 2014年 Atsushi Yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (IBAction)captureImage:(id)sender;
- (IBAction)faceDetect:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
