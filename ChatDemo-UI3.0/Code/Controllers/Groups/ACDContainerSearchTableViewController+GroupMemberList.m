//
//  ACDContainerSearchTableViewController+GroupMemberList.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController+GroupMemberList.h"

@implementation ACDContainerSearchTableViewController (GroupMemberList)

- (void)showMemberActionSheetWithGroup:(AgoraChatGroup *)group {
    if (group.permissionType == AgoraChatGroupPermissionTypeMember) {
        return;
    }
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    ACD_WS
    if (group.permissionType == AgoraChatGroupPermissionTypeOwner) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Make Admin" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Mute" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Move to Blocked List" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Move to Allowed List" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Remove From Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        for (UIAlertAction *alertAction in alertController.actions)
            [alertAction setValue:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        
    }
    
    if (group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Mute" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Move to Blocked List" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Move to Allowed List" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Remove From Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        for (UIAlertAction *alertAction in alertController.actions)
            [alertAction setValue:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forKey:@"_titleTextColor"];
        
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    return;

}
   

- (void)makeAdmin {
    
}

- (void)mute {
    
}

- (void)makeBlock {
    
}

@end
