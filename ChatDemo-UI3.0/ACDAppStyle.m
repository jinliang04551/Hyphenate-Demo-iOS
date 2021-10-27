//
//  ACDAppStyle.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDAppStyle.h"

@implementation ACDAppStyle
+ (instancetype)shareAppStyle {
    static ACDAppStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = ACDAppStyle.new;
    });
    
    return instance;
}


- (void)defaultStyle {
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : COLOR_HEX(0xC9CFCF)
                                                      } forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : COLOR_HEX(0x114EFF)
                                                      } forState:UIControlStateSelected];
//    UITabBar.appearance.backgroundImage = IMAGE_HEX(0xFFFFFF);
//    UITabBar.appearance.shadowImage = IMAGE_HEX(0xFFFFFF);
}


@end
