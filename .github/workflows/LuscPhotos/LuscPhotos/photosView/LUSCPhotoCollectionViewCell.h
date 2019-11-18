//
//  LUSCPhotoCollectionViewCell.h
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUSCPhotoCollectionViewCellDelegate <NSObject>

-(void) touchSelected:(UICollectionViewCell*) cell indexPath:(NSIndexPath *)indexPath;

@end


@interface LUSCPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSInteger beSelectedNumber;
@property (nonatomic,weak) UIViewController<LUSCPhotoCollectionViewCellDelegate>* controller;
@property (nonatomic,weak) NSIndexPath *indexPath;
@property (nonatomic,strong) NSString* localIdentifier;
@property (nonatomic,readonly) BOOL isBeSelected;
@property (nonatomic) NSInteger index;


-(void) setImage:(UIImage*) image;
-(UIImage*) getImage;
-(void) setNotSelectedImage:( UIImage* _Nullable) image;
-(void) setSelectedImage:(UIImage* _Nullable) image;

- (void) showMask;
- (void) hideMask;

@end

NS_ASSUME_NONNULL_END
