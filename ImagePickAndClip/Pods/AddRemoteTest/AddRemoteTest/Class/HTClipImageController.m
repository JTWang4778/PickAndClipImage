

#import "HTClipImageController.h"

@interface HTClipImageController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    BOOL _isLandscape;
}

@property (nonatomic,strong)UIImage *originImage;
@property (nonatomic,assign)BOOL isRoundedCorner;

@property (nonatomic,weak)UIScrollView *scrollView;
@property (nonatomic,weak)UIImageView *showImageView;

@property (nonatomic,assign)CGRect clipFrame;

@end

@implementation HTClipImageController

- (instancetype)initWithImage:(UIImage *)image ClipFrame: (CGRect)frame IsRoundedCorner: (BOOL)isCorner{
    if (self = [super init]) {
        self.originImage = image;
        self.clipFrame = frame;
        self.isRoundedCorner = isCorner;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    /*
        1，确定裁剪区域
        2，根据裁剪区域的大小和原图的大小，计算出缩放后新的size，计算出imageView的frame，scrollView的contentsize， 调整offset使得图片位于中心位置
        3，根据裁剪区域frame， 设置模版大小和位置
        4，在缩放的代理方法中，根据新的imageView的frame， 设置contentSize和offset
        5，在点击确定的方法中，根据裁剪区域frame和当前imageView的frame，截取图片
     */
    [self calculateImageOriention];
    [self setUpScrollView];
    [self setupCoverView];
    [self setupControlButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)setUpScrollView{
    
    CGRect scrollFrame = self.view.bounds;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.layer.masksToBounds = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bouncesZoom = YES;
    scrollView.bounces = YES;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedTapGesture:)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    [self.scrollView addGestureRecognizer:tap];
    
    
    if (!_isLandscape) {
        CGFloat newHeight = (_clipFrame.size.width / _originImage.size.width) *  _originImage.size.height;
        CGSize contentSize = CGSizeMake(_clipFrame.size.width + 0.5, newHeight + 2 * _clipFrame.origin.y);
        CGRect imageFrame = CGRectMake(0, _clipFrame.origin.y, _clipFrame.size.width, newHeight);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
//        imageView.backgroundColor = [UIColor yellowColor];
        imageView.tag = 100;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.originImage;
        imageView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.userInteractionEnabled = YES;
        imageView.multipleTouchEnabled = YES;
        [self.scrollView addSubview:imageView];
        self.showImageView = imageView;
        self.scrollView.contentSize = contentSize;
        self.scrollView.contentOffset = CGPointMake(0,_clipFrame.origin.y - (scrollView.frame.size.height - newHeight) * 0.5);
    }else{
        CGFloat newHeight = _clipFrame.size.height;
        CGFloat newWidth = (newHeight / _originImage.size.height) *  _originImage.size.width;
        CGSize contentSize = CGSizeMake(newWidth, scrollView.frame.size.height + 0.5);;
        
        CGRect imageFrame = CGRectMake((contentSize.width - newWidth) * 0.5, _clipFrame.origin.y, newWidth, newHeight);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
//        imageView.backgroundColor = [UIColor yellowColor];
        imageView.tag = 100;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = self.originImage;
        imageView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.userInteractionEnabled = YES;
        imageView.multipleTouchEnabled = YES;
        [self.scrollView addSubview:imageView];
        self.showImageView = imageView;
        self.scrollView.contentSize = contentSize;
        self.scrollView.contentOffset = CGPointMake((contentSize.width - _clipFrame.size.width ) * 0.5, 0);
    }
}

- (void)calculateImageOriention{
    if (_originImage.size.width < _originImage.size.height) {
        CGFloat newWidth = _clipFrame.size.width;
        CGFloat newHeight = (newWidth / _originImage.size.width) *  _originImage.size.height;
        if (newHeight < _clipFrame.size.height) {
            _isLandscape = YES;
        }else{
            _isLandscape = NO;
        }
        
    }else{
        CGFloat newHeight = _clipFrame.size.height;
        CGFloat newWidth = (newHeight / _originImage.size.height) *  _originImage.size.width;
        if (newWidth > _clipFrame.size.width) {
            _isLandscape = YES;
        }else{
            _isLandscape = NO;
        }
    }
}

- (void)setupCoverView{
    // 根据裁剪区域，设置蒙版
    CGRect cropframe = self.clipFrame;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRoundedRect:cropframe cornerRadius:0];
    if (_isRoundedCorner) {
        cropPath = [UIBezierPath bezierPathWithOvalInRect:cropframe];
    }
    [path appendPath:cropPath];
    
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5].CGColor;
    //填充规则
    layer.fillRule=kCAFillRuleEvenOdd;
    layer.path = path.CGPath;
    [self.view.layer addSublayer:layer];
}

- (void)setupControlButton{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UILabel *tiplabel = [[UILabel alloc] init];
    tiplabel.textColor = [UIColor whiteColor];
    tiplabel.font = [UIFont systemFontOfSize:16];
    tiplabel.text = @"移动和缩放";
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.frame = CGRectMake(0, statusBarHeight + 10, _screenWidth, 30);
    [self.view addSubview:tiplabel];
    
    UIButton * canncelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    canncelBtn.frame = CGRectMake(0, _screenHeight - 44, 60, 44);
    canncelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [canncelBtn setTitle:@"取 消" forState:UIControlStateNormal];
    [canncelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [canncelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:canncelBtn];
    
    UIButton * doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.frame = CGRectMake(_screenWidth - 60, _screenHeight - 44, 60, 44);
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneBtn setTitle:@"完 成" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.showImageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // 缩放只是缩放的imageView，  所以缩放后要更新contentSize 和 contentOffset  判断当前
    if (_isLandscape) {
        UIImageView *imageView = [scrollView viewWithTag:100];
        if (scrollView.zoomScale == 1.0) {
            CGFloat newHeight = _clipFrame.size.height;
            CGFloat newWidth = (newHeight / _originImage.size.height) *  _originImage.size.width;
            CGSize contentSize = CGSizeMake(newWidth, scrollView.frame.size.height + 0.5);;
            self.scrollView.contentSize = contentSize;
            self.scrollView.contentOffset = CGPointMake((contentSize.width - _clipFrame.size.width ) * 0.5, 0);
            
        }else{
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, imageView.frame.size.height + _scrollView.frame.size.height - _clipFrame.size.height);
        }

    }else{
        if (scrollView.zoomScale == 1.0) {
            UIImageView *imageView = [scrollView viewWithTag:100];
            scrollView.contentOffset = CGPointMake(0, (imageView.frame.size.height - _clipFrame.size.height) * 0.5);
        }
        scrollView.contentSize = CGSizeMake(_clipFrame.size.width * scrollView.zoomScale + 0.5, scrollView.contentSize.height + scrollView.frame.size.height - _clipFrame.size.height);
    }
    
}

- (void)receivedTapGesture:(UITapGestureRecognizer *)ges{
    if (self.scrollView.zoomScale == 1.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.zoomScale = 3.0;
        }];
    }else if (self.scrollView.zoomScale == 3.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.zoomScale = 1.0;
        }];
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - 控制器按钮
- (void)cancelBtnClick{
    [self hiddenScrollView];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(clickCancle)]) {
        [self.delegate clickCancle];
    }
}
- (void)doneBtnClick{
    
    
    CGRect rect = [self.view convertRect:self.clipFrame toView:self.showImageView];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect myImageRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(_showImageView.bounds.size, YES, scale);
    [_showImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, myImageRect);
    UIImage *subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    [self hiddenScrollView];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(clickFinishWithImage:)]) {
        [self.delegate clickFinishWithImage:subImage];
    }
}

- (void)hiddenScrollView{
    self.showImageView.hidden = YES;
    self.scrollView.hidden = YES;
    [self.scrollView removeFromSuperview];
}
@end
