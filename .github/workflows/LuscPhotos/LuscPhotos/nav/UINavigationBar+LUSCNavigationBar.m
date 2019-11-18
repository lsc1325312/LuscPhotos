//
//  UINavigationBar+LUSCNavigationBar.m
//  LuscPhotos
//
//  Created by xy on 2018/9/26.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "UINavigationBar+LUSCNavigationBar.h"

@implementation UINavigationBar (LUSCNavigationBar)

-(void) setColor:(UIColor*) color{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].applicationFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height+self.frame.size.height)];
    view.backgroundColor = color;
    
    [self setValue:view forKey:@"backgroundView"];
}

@end
