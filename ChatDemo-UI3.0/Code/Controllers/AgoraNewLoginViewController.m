//
//  AgoraNewLoginViewController.m
//  login-UI3.0
//
//  Created by liang on 2021/10/18.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraNewLoginViewController.h"
#import "AgoraChatHttpRequest.h"

#define kLoginButtonHeight 48.0f

@interface AgoraNewLoginViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView* titleImageView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic) BOOL isLogin;

@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation AgoraNewLoginViewController

#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupForDismissKeyboard];
    [self placeAndLayoutSubViews];
}


- (void)placeAndLayoutSubViews
{
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.logoImageView];
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.usernameTextField];
    [self.contentView addSubview:self.passwordTextField];
    [self.contentView addSubview:self.loginButton];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(134.0);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.contentView);
//        make.width.equalTo(@108);
//        make.height.equalTo(@29);
        
    }];
        
    
    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom).offset(40);
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_usernameTextField.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(kAgroaPadding * 2);
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.height.equalTo(@kLoginButtonHeight);
    }];
}

#pragma mark - private
- (BOOL)_isEmpty
{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
        [alert show];

    }
    
    return ret;
}


- (void)doLogin {
    
    if ([self _isEmpty]) {
        return;
    }
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void (^finishBlock) (NSString *aName, AgoraChatError *aError) = ^(NSString *aName, AgoraChatError *aError) {
        if (!aError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"login.succeed", @"Sign in succeed") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                [alertError show];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES userInfo:@{@"userName":aName,@"nickName":_passwordTextField.text}];
            });
            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
        switch (aError.code) {
            case AgoraChatErrorServerNotReachable:
                errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                break;
            case AgoraChatErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                break;
            case AgoraChatErrorServerTimeout:
                errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                break;
            case AgoraChatErrorUserAlreadyExist:
                errorDes = NSLocalizedString(@"login.taken", @"Username taken");
                break;
            default:
                errorDes = NSLocalizedString(@"login.failure", @"login failure");
                break;
        }
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:errorDes delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
        [alertError show];
    };
    
    if ([AgoraChatClient sharedClient].isLoggedIn) {
        [[AgoraChatClient sharedClient] logout:YES];
    }
    
    [[AgoraChatClient sharedClient] loginWithUsername:[_usernameTextField.text lowercaseString] password:_passwordTextField.text completion:finishBlock];
    return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //unify token login
    __weak typeof(self) weakself = self;
    [[AgoraChatHttpRequest sharedManager] loginToApperServer:[_usernameTextField.text lowercaseString] nickName:_passwordTextField.text completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSString *alertStr = nil;
            if (response && response.length > 0 && statusCode) {
                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *token = [responsedict objectForKey:@"accessToken"];
                NSString *loginName = [responsedict objectForKey:@"chatUserName"];
                if (token && token.length > 0) {
                    [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:finishBlock];
                    return;
                } else {
                    alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
                }
            } else {
                alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"loginAppServer.ok", @"Ok"), nil];
            [alert show];
        });
    }];
    
}

#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect buttonFrame = _loginButton.frame;
    CGFloat top = 0;

    if (endRect.origin.y == self.view.frame.size.height) {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame);
    } else if(beginRect.origin.y == self.view.frame.size.height){
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;
        top = -100;
    } else {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;
        top = -100;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [[UIApplication sharedApplication].keyWindow setTop:top];
//        _loginButton.frame = buttonFrame;
    }];
}




#pragma mark getter and setter
- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.image = ImageWithName(@"login.bundle/login_logo");
    }
    return _logoImageView;
}

- (UIImageView *)titleImageView {
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.image = ImageWithName(@"login.bundle/login_agoraChat");
    }
    return _titleImageView;
}


- (UITextField *)usernameTextField {
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.backgroundColor = COLOR_HEX(0xF2F2F2);
        _usernameTextField.delegate = self;
        _usernameTextField.borderStyle = UITextBorderStyleNone;
        _usernameTextField.placeholder = @"AgoraID";
        
        _usernameTextField.returnKeyType = UIReturnKeyGo;
        _usernameTextField.font = [UIFont systemFontOfSize:17];
        _usernameTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.cornerRadius = kLoginButtonHeight * 0.5;
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.backgroundColor = COLOR_HEX(0xF2F2F2);
        _passwordTextField.delegate = self;
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.placeholder = NSLocalizedString(@"login.passwordTextField.password", @"Password");
        _passwordTextField.font = [UIFont systemFontOfSize:17];
        _passwordTextField.returnKeyType = UIReturnKeyGo;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.clearsOnBeginEditing = NO;
        _passwordTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.layer.cornerRadius = kLoginButtonHeight * 0.5;
      

    }
    return _passwordTextField;
}


- (UIButton *)loginButton {
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = COLOR_HEX(0x114EFF);
        [_loginButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.layer.cornerRadius = kLoginButtonHeight * 0.5;

    }
    return _loginButton;
}

@end
#undef loginButtonHeight

