//
//  AgoraGroupListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraGroupListViewController.h"
#import "MISScrollPage.h"

@interface AgoraGroupListViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation AgoraGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.purpleColor;
}

#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidLoadedForIndex ---------- %lu", (unsigned long)index);
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewWillAppearForIndex ---------- %lu", (unsigned long)index);
}

- (void)viewDidAppearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidAppearForIndex ---------- %lu", (unsigned long)index);
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewWillDisappearForIndex ---------- %lu", (unsigned long)index);
    
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidDisappearForIndex ---------- %lu", (unsigned long)index);
}


@end
