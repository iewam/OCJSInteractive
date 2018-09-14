//
//  ViewController.m
//  OCJSInteractive
//
//  Created by Steven on 2018/9/14.
//  Copyright © 2018年 Spark. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define kMainWidth [UIScreen mainScreen].bounds.size.width
#define kMainHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *mainWebView;
@property (nonatomic, strong) UIButton *alertButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainWebView];
    [self.view addSubview:self.alertButton];
    
}


- (WKWebView *)mainWebView{
    if (_mainWebView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        configuration.userContentController = userController;
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kMainWidth, kMainHeight) configuration:configuration];
        NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"index.html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
        [_mainWebView loadRequest: request];
        _mainWebView.navigationDelegate = self;
        _mainWebView.UIDelegate = self;
        [userController addScriptMessageHandler:self name:@"currentCookies"];
    }
    return _mainWebView;
}

- (UIButton *)alertButton{
    
    if (_alertButton == nil) {
        _alertButton = [[UIButton alloc] initWithFrame:CGRectMake(kMainWidth*0.2, kMainHeight - 60, kMainWidth * 0.6, 40)];
        _alertButton.backgroundColor = [UIColor colorWithRed:250/255.0 green:204/255.0 blue:96/255.0 alpha:1.0];
        _alertButton.layer.cornerRadius = 6.0f;
        _alertButton.layer.masksToBounds = YES;
        _alertButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_alertButton setTitle:@"弹出弹窗" forState:UIControlStateNormal];
        [_alertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_alertButton addTarget:self action:@selector(alertButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alertButton;
}

- (void)alertButtonAction{
    
    [self.mainWebView evaluateJavaScript:@"alertAction('OC调用JS警告窗方法')" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        NSLog(@"OC调用JS警告窗方法 -- completeHandler()");
    }];
    
}


//JS调用的OC回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"currentCookies"]) {
        NSString *cookiesStr = message.body;
        NSLog(@"当前的cookie为： %@", cookiesStr);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"JS调用的OC回调方法" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)dealloc{
    [self.mainWebView.configuration.userContentController removeScriptMessageHandlerForName:@"currentCookies"];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"OC调用JS警告窗方法");
    completionHandler();
}


@end
