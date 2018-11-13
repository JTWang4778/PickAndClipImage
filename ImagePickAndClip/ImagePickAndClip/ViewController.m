//
//  ViewController.m
//  ImagePickAndClip
//
//  Created by wangjintao on 2018/11/13.
//  Copyright © 2018年 wangjintao. All rights reserved.
//

#define ScreenW                             [UIScreen mainScreen].bounds.size.width
#define ScreenH                             [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "HTClipImageController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, HTClipImageControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,weak)UIImagePickerController *pickController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)clickPhotoLibiary:(UIButton *)sender {
    [self checkPhotoLibraryAuthorization];
}
- (IBAction)clickCamera:(UIButton *)sender {
    [self checkCameraAuthorization];
}

- (void)checkCameraAuthorization{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        NSString *errorStr = @"XXXX没有获得相机的使用权限，请在设置中开启";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无权使用您的相机" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:jumpUrl options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:jumpUrl];
            }
        }];
        
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sure];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self pickImageFromType:UIImagePickerControllerSourceTypeCamera];
            });
        }];
    }else{
        [self pickImageFromType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)checkPhotoLibraryAuthorization{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无权使用您的照片库" message:@"XXXX未能获得访问照片库的权限，请在设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:jumpUrl options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:jumpUrl];
            }
        }];
        
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sure];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (status == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self pickImageFromType:UIImagePickerControllerSourceTypePhotoLibrary];
                });
            }
        }];
    }else{
        [self pickImageFromType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}
- (void)pickImageFromType: (UIImagePickerControllerSourceType)type{
    if ([UIImagePickerController availableMediaTypesForSourceType:type]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = type;
        picker.delegate = self;
        self.pickController = picker;
        
        [self presentViewController:picker animated:true completion:nil];
    }else{
        NSLog(@"没有权限");
    };
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
    //    CGFloat newHeight = ScreenW * 132.0 / 204.0;
    //    CGRect clipFrame = CGRectMake(0, (ScreenH - newHeight) * 0.5, ScreenW, newHeight);
    CGRect clipFrame = CGRectMake(0, (ScreenH - ScreenW) * 0.5, ScreenW, ScreenW);
    HTClipImageController *controller = [[HTClipImageController alloc] initWithImage:image ClipFrame:clipFrame IsRoundedCorner:NO];
    controller.delegate = self;
    [picker pushViewController:controller animated:true];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.pickController dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - HTClipImageControllerDelegate
- (void)clickCancle{
    [self.pickController dismissViewControllerAnimated:true completion:nil];
}

- (void)clickFinishWithImage:(UIImage *)image{
    [self.pickController dismissViewControllerAnimated:true completion:nil];
    self.imageView.image = image;
}

@end
