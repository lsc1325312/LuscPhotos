//
//  LUSCPreviewImageView.m
//  LuscPhotos
//
//  Created by xy on 2018/9/28.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPreviewImageView.h"

#define MAXScale 3.0
#define MINScale 1.0

@interface LUSCPreviewImageView()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIImageView* imageView;

@property (nonatomic) CGSize baseSize;

@property (nonatomic) CGSize beganSize;

@property (nonatomic) CGFloat zoomScale;

@property (nonatomic) CGPoint pointToTopRatio;
@property (nonatomic) CGPoint pinchTouchCenter;


@end

@implementation LUSCPreviewImageView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
                
        self.clipsToBounds = YES;
        self.zoomScale = 1.0f;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scrollView.clipsToBounds = NO;
        self.scrollView.showsVerticalScrollIndicator = YES;
        self.scrollView.showsHorizontalScrollIndicator = YES;
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView addSubview:self.imageView];
        
        
        UITapGestureRecognizer *doubleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleClick.numberOfTapsRequired = 2;
        doubleClick.delegate = self;
        [self addGestureRecognizer:doubleClick];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(setPinchChick:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
    }
    return self;
}

//设置新图片
- (void) setDisplayImage:(UIImage *)displayImage{
    _displayImage = displayImage;
    [self layoutImageView];
}
//重置图片大小为屏幕适配大小
- (void) resetImage{
    [self layoutImageView];
}
//接收navBar显示土与隐藏
- (void) setHiddenStatus:(BOOL) isHidden{
    
}

//图片适配屏幕
- (void)layoutImageView {
    CGRect imageFrame;
    if (_displayImage.size.width > self.bounds.size.width || _displayImage.size.height > self.bounds.size.height) {
        CGFloat imageRatio = _displayImage.size.width/_displayImage.size.height;
        CGFloat photoRatio = self.bounds.size.width/self.bounds.size.height;
        
        if (imageRatio > photoRatio) {
            imageFrame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.width/_displayImage.size.width*_displayImage.size.height);
            imageFrame.origin.x = 0;
            imageFrame.origin.y = (self.bounds.size.height-imageFrame.size.height)/2.0;
        }
        else {
            imageFrame.size = CGSizeMake(self.bounds.size.height/_displayImage.size.height*_displayImage.size.width, self.bounds.size.height);
            imageFrame.origin.x = (self.bounds.size.width-imageFrame.size.width)/2.0;
            imageFrame.origin.y = 0;
        }
    }
    else {
        imageFrame.size = _displayImage.size;
        imageFrame.origin.x = (self.bounds.size.width-_displayImage.size.width)/2.0;
        imageFrame.origin.y = (self.bounds.size.height-_displayImage.size.height)/2.0;
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
    _imageView.frame = imageFrame;
//    _imageView.frame = CGRectMake(0, 0, imageFrame.size.width, imageFrame.size.height);
    _imageView.image = _displayImage;
    
    _baseSize = imageFrame.size;
    
    _zoomScale = 1.0;
}
//双击手势
- (void) doubleClick:(UITapGestureRecognizer*) gestureRecognizer{
    
    //双击坐标点
    CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:self];
    //捏合的中心坐水标点
    CGPoint center = p1;
    //转换到图片坐标
    CGPoint imageCenter = [self convertPoint:center toView:self.imageView];
    
    self.pointToTopRatio  = [self clickPointToVertexRatioWithPoint:imageCenter inView:self.imageView];
    self.pinchTouchCenter = center;
    
//    NSLog(@"\n p1 = %@ \n center = %@ \n imageCenter = %@",NSStringFromCGPoint(p1),NSStringFromCGPoint(center),NSStringFromCGPoint(imageCenter));

    
    if (self.zoomScale > MINScale) {
        [self animationWithScale:MINScale center:imageCenter scrollViewTouchPoint:self.pinchTouchCenter];
    } else {
        [self animationWithScale:MAXScale center:imageCenter scrollViewTouchPoint:self.pinchTouchCenter];
    }
}

//捏合手势
-(void) setPinchChick:(UIPinchGestureRecognizer*) pinch{
    //2个捏合坐标点
    CGPoint p1 = [pinch locationOfTouch:0 inView:self];
    CGPoint p2 = p1;
    if (pinch.numberOfTouches==2) {
        p2 = [pinch locationOfTouch:1 inView:self];
    }
    //捏合的中心坐水标点
    CGPoint center = CGPointMake((p2.x+p1.x)/2, (p2.y+p1.y)/2);
    //转换到图片坐标
    CGPoint imageCenter = [pinch.view convertPoint:center toView:self.imageView];
    imageCenter = [self touchCenterCorrectWithTouchCenter:imageCenter];

    
    
    CGFloat factor = pinch.scale;
    if (pinch.state == UIGestureRecognizerStateBegan){
        self.beganSize = self.imageView.frame.size;
        self.pointToTopRatio  = [self clickPointToVertexRatioWithPoint:imageCenter inView:self.imageView];
//        self.pinchTouchCenter =  [pinch.view convertPoint:center toView:self.scrollView];
        self.pinchTouchCenter = center;
        NSLog(@" \n pinchTouchCenter = %@",NSStringFromCGPoint(self.pinchTouchCenter));

    }
    if (pinch.state == UIGestureRecognizerStateChanged){
    }
//    self.imageView.transform = CGAffineTransformMakeScale(_zoomScale*factor, _zoomScale*factor);
    self.imageView.frame = CGRectMake(0, 0, self.beganSize.width*factor, self.beganSize.height*factor);
    [self setScrollContentSizeWithTouchCenter:imageCenter scrollViewTouchPoint:self.pinchTouchCenter];
    //状态是否结束，如果结束保存数据
    if (pinch.state == UIGestureRecognizerStateEnded){
        _zoomScale = self.imageView.frame.size.width/self.baseSize.width;
        if (_zoomScale>MAXScale) {
            [self animationWithScale:MAXScale center:center scrollViewTouchPoint:self.pinchTouchCenter];
            _zoomScale = MAXScale;
        }
        if (_zoomScale<MINScale) {
            [self animationWithScale:MINScale center:center scrollViewTouchPoint:self.pinchTouchCenter];
            _zoomScale = MINScale;
        }
        
    }
}
//scrollView设置
-(void) setScrollContentSizeWithTouchCenter:(CGPoint) touchCenter scrollViewTouchPoint:(CGPoint) touchPoint{
    [self scrollContentSizeFitImageSize];
    [self setImageViewCenterWithTouchCenter:touchCenter scrollViewTouchPoint:touchPoint];
}


//scrollView适配图片大小
-(void) scrollContentSizeFitImageSize{
    CGFloat w = self.imageView.frame.size.width;
    CGFloat h = self.imageView.frame.size.height;
    if (w<self.scrollView.frame.size.width) {
        w = self.scrollView.frame.size.width;
    }
    if (h<self.scrollView.frame.size.height) {
        h = self.scrollView.frame.size.height;
    }
    self.scrollView.contentSize = CGSizeMake(w, h);
}

//imageView适配scrollView点击位置
-(void) setImageViewCenterWithTouchCenter:(CGPoint) touchCenter scrollViewTouchPoint:(CGPoint) touchPoint{
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width/2, self.scrollView.contentSize.height/2);
    CGFloat x = self.imageView.frame.size.width*self.pointToTopRatio.x - touchPoint.x;
    CGFloat y = self.imageView.frame.size.height*self.pointToTopRatio.y - touchPoint.y;
    if (self.scrollView.frame.size.width>=self.scrollView.contentSize.width) {
        x = self.scrollView.contentOffset.x;
    }
    if (self.scrollView.frame.size.height>=self.scrollView.contentSize.height) {
        y = self.scrollView.contentOffset.y;
    }
    self.scrollView.contentOffset = CGPointMake(x,y);
//    NSLog(@"self.pointToTopRatio = %@",NSStringFromCGPoint(self.pointToTopRatio));
    
}
//点击图片位置矫正，把超出图片的定位改到图片边缘
- (CGPoint) touchCenterCorrectWithTouchCenter:(CGPoint) touchCenter{
    CGFloat x = touchCenter.x;
    CGFloat y = touchCenter.y;
    if (touchCenter.x<0) {
        x = 0;
    }
    if (touchCenter.x>self.imageView.frame.size.width) {
        x = self.imageView.frame.size.width;
    }
    if (touchCenter.y<0) {
        y = 0;
    }
    if (touchCenter.y>self.imageView.frame.size.height) {
        y = self.imageView.frame.size.height;
    }
    CGPoint center = CGPointMake(x, y);
    return center;
}
//点距离顶点的比例
- (CGPoint) clickPointToVertexRatioWithPoint:(CGPoint) point inView:(UIView*) view{
    return CGPointMake(point.x/view.frame.size.width, point.y/view.frame.size.height);
}

//缩放回力动画 scale回力比例
-(void) animationWithScale:(CGFloat) scale center:(CGPoint) center scrollViewTouchPoint:(CGPoint) touchPoint{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
//        weakSelf.imageView.transform = CGAffineTransformMakeScale(scale, scale);//比例计算，不要和frame一起用会出问题，要用就用bounds+center来改变
        weakSelf.imageView.frame = CGRectMake(0, 0, weakSelf.baseSize.width*scale, weakSelf.baseSize.height*scale);//frame方法
        [weakSelf setScrollContentSizeWithTouchCenter:center scrollViewTouchPoint:touchPoint];
    } completion:^(BOOL finished) {
        weakSelf.zoomScale = scale;
    }];
}

//允许多个手势并发
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    NSLog(@"%@",gestureRecognizer.view);
//    return YES;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
