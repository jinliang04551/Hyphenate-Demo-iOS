/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraAboutViewController.h"

@interface AgoraAboutViewController ()

@end

@implementation AgoraAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    self.title = @"About";
    
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndetifier = @"aboutCell";
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (!cell) {

        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndetifier];
    }
    if (indexPath.row == 0) {
        
        cell.textLabel.attributedText = [self titleAttribute:@"UI Library Version"];
        NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *detailContent = [NSString stringWithFormat:@"AgoraChat v:%@",ver];
        cell.detailTextLabel.attributedText = [self detailAttribute:detailContent];
        
    } else if (indexPath.row == 1) {
        
        cell.textLabel.attributedText = [self titleAttribute:@"SDK Version"];
        NSString *detailContent = [NSString stringWithFormat:@"AgoraChat v:%@",[[AgoraChatClient sharedClient] version]];
        cell.detailTextLabel.attributedText = [self detailAttribute:detailContent];
    }
    
    return cell;
}

- (NSAttributedString *)titleAttribute:(NSString *)title {
    return [ACDUtil attributeContent:title color:TextLabelBlack2Color font:Font(@"PingFang SC",16.0)];
}

- (NSAttributedString *)detailAttribute:(NSString *)detail {
    return [ACDUtil attributeContent:detail color:TextLabelGrayColor font:Font(@"PingFang SC",16.0)];
}

@end
