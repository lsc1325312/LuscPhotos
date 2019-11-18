//
//  LUSCPreviewImageView.h
//  LuscPhotos
//
//  Created by xy on 2018/9/28.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPreviewImageView : UIView

@property (nonatomic,strong,nullable) UIImage* displayImage;

- (void) resetImage;
- (void) setHiddenStatus:(BOOL) isHidden;

@end

NS_ASSUME_NONNULL_END
