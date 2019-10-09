

#import <UIKit/UIKit.h>

@protocol HTClipImageControllerDelegate<NSObject>

- (void)clickFinishWithImage:(UIImage *)image;
- (void)clickCancle;

@end

@interface HTClipImageController : UIViewController
/**
 初始化方法

 @param image 原图
 @param frame 裁剪区域的位置
 @param isCorner 裁剪的蒙版是否是圆角
 */
- (instancetype)initWithImage:(UIImage *)image ClipFrame: (CGRect)frame IsRoundedCorner: (BOOL)isCorner;


@property (nonatomic,weak)id <HTClipImageControllerDelegate> delegate;
@end
