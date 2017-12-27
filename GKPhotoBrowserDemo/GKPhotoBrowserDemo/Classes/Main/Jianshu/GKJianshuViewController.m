//
//  GKToutiaoDetailViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/11.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKJianshuViewController.h"
#import <WebKit/WebKit.h>
#import "GKPhotoBrowser.h"

@interface GKJianshuViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSArray *imgUrls;

@end

@implementation GKJianshuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupWebView];
}

- (void)setupWebView {
    self.navigationItem.title = @"简书";
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.gk_navigationBar.bottom, self.view.width, self.view.height - self.gk_navigationBar.height)];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    self.url = @"http://www.jianshu.com/p/7baaff716f6f";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self getImgsJSToWebView:webView];
    
    [self addImgClick];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = navigationAction.request.URL.absoluteString;
    
    if ([url hasPrefix:@"image-preview:"]) {
        
        NSString *imgUrl = [url substringFromIndex:14];
        
        NSLog(@"%@", imgUrl);
        
        NSInteger index = [self.imgUrls indexOfObject:imgUrl];
        
        if (index >=0 && index < self.imgUrls.count) {
            [self showImageWithArray:self.imgUrls index:index];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)getImgsJSToWebView:(WKWebView *)webView {
    // 获取图片地址
    NSString *getImgUrlsJS = @"\
    function getImgUrls() {\
    var imgs = document.getElementsByTagName('img');\
    var urls = [];\
    for (var i = 0; i < imgs.length; i++) {\
    var img = imgs[i];\
    urls[i] = img.src;\
    }\
    return urls;\
    }";
    
    [webView evaluateJavaScript:getImgUrlsJS completionHandler:nil];
    
    [webView evaluateJavaScript:@"getImgUrls()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        self.imgUrls = obj;
    }];
}



// 给网页中的图片添加点击方法
- (void)addImgClick {
    NSString *imgClickJS = @"function imgClickAction(){var imgs=document.getElementsByTagName('img');var length=imgs.length;for(var i=0; i < length;i++){img=imgs[i];if(\"ad\" ==img.getAttribute(\"flag\")){var parent = this.parentNode;if(parent.nodeName.toLowerCase() != \"a\")return;}img.onclick=function(){window.location.href='image-preview:'+this.src}}}";
    [self.webView evaluateJavaScript:imgClickJS completionHandler:nil];
    
    [self.webView evaluateJavaScript:@"imgClickAction()" completionHandler:nil];
}


- (void)showImageWithArray:(NSArray *)imageUrls index:(NSInteger)index {
    NSMutableArray *photos = [NSMutableArray new];
    
    [imageUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        photo.url = [NSURL URLWithString:obj];
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.showStyle = GKPhotoBrowserShowStylePush;
    
    [browser showFromVC:self];
}

@end
