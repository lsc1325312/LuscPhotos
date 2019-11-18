//
//  LUSCPhotoCollectionViewCell.m
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotoCollectionViewCell.h"

// RGB颜色转换（16进制->10进制）(0x00000000--0xFFFFFFFF)
#define UIColorFromHexadecimalAlphaLUSCCell(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]
#define mainColorCell UIColorFromHexadecimalAlphaLUSCCell(0xff48C1a4)

@interface LUSCPhotoCollectionViewCell ()

@property (nonatomic,strong) UIImageView* imageView;

@property (nonatomic,strong) UIView* touchSelectedArea;
@property (nonatomic,strong) UIImageView* selectedArea;
@property (nonatomic) CGPoint selectedAreaCenter;
@property (nonatomic) CGSize selectedAreaSize;

@property (nonatomic,strong) UILabel* numberLabel;

@property (nonatomic,strong) UIView* maskView;


@end

@implementation LUSCPhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blueColor];
        self.contentView.clipsToBounds = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:self.imageView];
        
        self.touchSelectedArea = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-30, 0, 30, 30)];
        [self.contentView addSubview:self.touchSelectedArea];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSelected)];
        [self.touchSelectedArea addGestureRecognizer:tap];
        
        self.selectedArea = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-25, 5, 20, 20)];
        self.selectedArea.layer.cornerRadius = self.selectedArea.frame.size.width/2;
        self.selectedArea.layer.borderColor = [UIColor grayColor].CGColor;
        self.selectedArea.layer.borderWidth = 1;
        [self.contentView addSubview:self.selectedArea];
        
        self.selectedAreaSize = self.selectedArea.frame.size;
        self.selectedAreaCenter = self.selectedArea.center;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.selectedArea.frame.size.width, self.selectedArea.frame.size.height)];
        self.numberLabel.font = [UIFont systemFontOfSize:12];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.textColor = [UIColor whiteColor];
        [self.selectedArea addSubview:self.numberLabel];
        
        self.numberLabel.hidden=YES;
        
        self.maskView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.maskView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
        [self.contentView addSubview:self.maskView];
        
        self.maskView.hidden = YES;
    }
    return self;
}

#pragma mark event

-(void) touchSelected{
    if ([self.controller respondsToSelector:@selector(touchSelected:indexPath:)]) {
        [self.controller touchSelected:self indexPath:self.indexPath];
    }
}

#pragma mark set and get

-(void) setImage:(UIImage*) image{
    self.imageView.image = image;
    CGFloat ratio = [self imageCompressFitSizeScale:image targetSize:self.frame.size];
    self.imageView.frame = CGRectMake(0, 0, image.size.width*ratio, image.size.height*ratio);
    self.imageView.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    
}

-(UIImage*) getImage{
    return [UIImage imageWithCGImage:self.imageView.image.CGImage];
}

-(void) setNotSelectedImage:(UIImage* _Nullable) image{
    _isBeSelected = NO;
    self.numberLabel.hidden=YES;
    if (image==nil) {
        self.selectedArea.layer.cornerRadius = self.selectedArea.frame.size.width/2;
        self.selectedArea.layer.borderColor = [UIColor grayColor].CGColor;
        self.selectedArea.layer.borderWidth = 1;
        
        self.selectedArea.backgroundColor = [UIColor clearColor];
        
        self.selectedArea.image = nil;
        return;
    }
    
    UIImage* img = [UIImage imageWithCGImage:image.CGImage];
    
    self.selectedArea.layer.cornerRadius = 0;
    self.selectedArea.layer.borderColor = [UIColor clearColor].CGColor;
    self.selectedArea.layer.borderWidth = 0;
    
    self.selectedArea.image = img;
}
-(void) setSelectedImage:(UIImage* _Nullable) image{
    _isBeSelected = YES;
    self.numberLabel.hidden=NO;
    if (image==nil) {
        
        
        self.selectedArea.layer.cornerRadius = self.selectedArea.frame.size.width/2;
        self.selectedArea.layer.borderColor = [UIColor grayColor].CGColor;
        self.selectedArea.layer.borderWidth = 0;
        
        self.selectedArea.backgroundColor = mainColorCell;
        
        self.selectedArea.image = nil;
        
        [self selected1];
        return;
    }
    
    UIImage* img = [UIImage imageWithCGImage:image.CGImage];
    
    self.selectedArea.layer.cornerRadius = 0;
    self.selectedArea.layer.borderColor = [UIColor clearColor].CGColor;
    self.selectedArea.layer.borderWidth = 0;
    
    self.selectedArea.image = img;
}

- (CGFloat) imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
    CGFloat ratio = size.width/sourceImage.size.width;
    if (sourceImage.size.height*ratio<size.height) {
        ratio = size.height/sourceImage.size.height;
    }
    
    return ratio;
}

- (void) showMask{
    if (self.isBeSelected==YES) {
        self.maskView.hidden=YES;
    }else{
        self.maskView.hidden=NO;
    }
}

- (void) hideMask{
    self.maskView.hidden = YES;
}

-(void)setBeSelectedNumber:(NSInteger)beSelectedNumber{
    _beSelectedNumber = beSelectedNumber;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)beSelectedNumber];
}

-(void) selected1{
    self.selectedArea.frame = CGRectMake(0, 0, self.selectedAreaSize.width+4, self.selectedAreaSize.height+4);
    self.selectedArea.center = self.selectedAreaCenter;
    self.selectedArea.layer.cornerRadius = self.selectedAreaSize.width/2;
    self.numberLabel.center = CGPointMake(self.selectedArea.frame.size.width/2, self.selectedArea.frame.size.height/2);
    
    [self performSelector:@selector(selected2) withObject:nil afterDelay:0.08];
}
-(void) selected2{
    self.selectedArea.frame = CGRectMake(0, 0, self.selectedAreaSize.width-2, self.selectedAreaSize.height-2);
    self.selectedArea.center = self.selectedAreaCenter;
    self.selectedArea.layer.cornerRadius = self.selectedAreaSize.width/2;
    self.numberLabel.center = CGPointMake(self.selectedArea.frame.size.width/2, self.selectedArea.frame.size.height/2);
    
    [self performSelector:@selector(selected3) withObject:nil afterDelay:0.08];
}
-(void) selected3{
    self.selectedArea.frame = CGRectMake(0, 0, self.selectedAreaSize.width+2, self.selectedAreaSize.height+2);
    self.selectedArea.center = self.selectedAreaCenter;
    self.selectedArea.layer.cornerRadius = self.selectedAreaSize.width/2;
    self.numberLabel.center = CGPointMake(self.selectedArea.frame.size.width/2, self.selectedArea.frame.size.height/2);
    
    [self performSelector:@selector(selected4) withObject:nil afterDelay:0.04];
}
-(void) selected4{
    self.selectedArea.frame = CGRectMake(0, 0, self.selectedAreaSize.width-1, self.selectedAreaSize.height-1);
    self.selectedArea.center = self.selectedAreaCenter;
    self.selectedArea.layer.cornerRadius = self.selectedAreaSize.width/2;
    self.numberLabel.center = CGPointMake(self.selectedArea.frame.size.width/2, self.selectedArea.frame.size.height/2);
    
    [self performSelector:@selector(selected5) withObject:nil afterDelay:0.04];
}
-(void) selected5{
    self.selectedArea.frame = CGRectMake(0, 0, self.selectedAreaSize.width, self.selectedAreaSize.height);
    self.selectedArea.center = self.selectedAreaCenter;
    self.selectedArea.layer.cornerRadius = self.selectedAreaSize.width/2;
    self.numberLabel.center = CGPointMake(self.selectedArea.frame.size.width/2, self.selectedArea.frame.size.height/2);
}


@end
