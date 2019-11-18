//
//  LUSCPhotoManageDelegate.h
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUSCPhotoManageDelegate <NSObject>

-(void) respondPowerIsOpen:(BOOL) isOpen;

@end

NS_ASSUME_NONNULL_END
