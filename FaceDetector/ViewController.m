//
//  ViewController.m
//  FaceDetector
//
//  Created by Atsushi Yoshida on 2014/01/30.
//  Copyright (c) 2014年 Atsushi Yoshida. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showUIImagePicker
{
    // カメラが使用可能かどうか判定する
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    // UIImagePickerControllerのインスタンスを生成
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    // デリゲートを設定
    imagePickerController.delegate = self;
    
    // 画像の取得先をカメラに設定
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // 画像取得後に編集するかどうか（デフォルトはNO）
    imagePickerController.allowsEditing = YES;
    
    // 撮影画面をモーダルビューとして表示する
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

// 画像が選択された時に呼ばれるデリゲートメソッド
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    // モーダルビューを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 渡されてきた画像をUIImageViewに表示
    
    for(UIView* subview in _imageView.subviews){
        [subview removeFromSuperview];
    }
    
    [_imageView setImage:image];
}

- (IBAction)captureImage:(id)sender {
    [super viewDidAppear:YES];
    
    [self showUIImagePicker];
}

- (IBAction)faceDetect:(id)sender {
    for(UIView* subview in _imageView.subviews){
        [subview removeFromSuperview];
    }

    // インスタンス生成
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                        forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:options];
    
    // 画像をWebから取得
    UIImage *originalImage = self.imageView.image;

    // 取得した画像の縦サイズ、横サイズを取得する
    int imageW = originalImage.size.width;
    int imageH = originalImage.size.height;
    int viewW = self.imageView.bounds.size.width;
    int viewH = self.imageView.bounds.size.height;
    
    // リサイズする倍率を作成する。
    float scale = (imageW > imageH ? (float)viewH/imageH : (float)viewW/imageW);
    int resizeW = imageW * scale;
    int resizeH = imageH * scale;
    int offsetX = (viewW-resizeW)/2;
    int offsetY = (viewH-resizeH)/2;
    
    // リサイズ
    originalImage = [self resizeImage:originalImage newSize:CGSizeMake(resizeW, resizeH)];
    self.imageView.image = originalImage;
    
    // 顔検出
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:originalImage.CGImage];
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:CIDetectorImageOrientation];
    NSArray *array = [detector featuresInImage:ciImage options:imageOptions];
    
    // CoreImageは、左下の座標が (0,0) となるので、UIKitと同じ座標系に変換
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -viewH);
    
    // 検出されたデータを取得
    for (CIFaceFeature *faceFeature in array)
    {
        // 座標変換
        CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        faceRect.origin.x = faceRect.origin.x - offsetX;
        faceRect.origin.y = faceRect.origin.y - offsetY;
        
        // 顔検出された範囲に赤い枠線を付ける
        UIView *faceView = [[UIView alloc] initWithFrame:faceRect];
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [self.imageView addSubview:faceView];
    }
}

// イメージをリサイズする
- (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end
