//
//  GKGIFViewController.m
//  GKPhotoBrowserDemo
//
//  Created by gaokun on 2018/6/13.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKGIFViewController.h"
#import <WebKit/WebKit.h>
#import "GKPhotoBrowser.h"

@interface GKGIFViewController ()<WKNavigationDelegate, GKPhotoBrowserDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) WKWebView *webView;
//@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSArray *imgUrls;

@property (nonatomic, strong) NSArray *imgFrames;

@property (nonatomic, strong) UIView *whiteView;

@end

@implementation GKGIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"详情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self addUIWebView];
    [self addWKWebView];
}

- (void)addWKWebView {
    CGRect frame = CGRectMake(0, self.gk_navigationBar.bottom, KScreenW, KScreenH - self.gk_navigationBar.height);
    self.webView = [[WKWebView alloc] initWithFrame:frame];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView loadHTMLString:[self getHtmlString] baseURL:nil];
}

//- (void)addUIWebView {
//    CGRect frame = CGRectMake(0, self.gk_navigationBar.bottom, KScreenW, KScreenH - self.gk_navigationBar.height);
//    self.webView = [[UIWebView alloc] initWithFrame:frame];
//    self.webView.delegate = self;
//    [self.view addSubview:self.webView];
//
//    [self.webView loadHTMLString:[self getHtmlString] baseURL:nil];
//}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    // 获取图片信息
    [self getImgsJSToWebView:webView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = navigationAction.request.URL.absoluteString;
    
    if ([url hasPrefix:@"imgurl:"]) {
        
        NSString *imgUrl = [url substringFromIndex:7];
        
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self getImgsJSToUIWebView:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;
    
    if ([url hasPrefix:@"imgurl:"]) {
        
        NSString *imgUrl = [url substringFromIndex:7];
        
        NSInteger index = [self.imgUrls indexOfObject:imgUrl];
        
        if (index >=0 && index < self.imgUrls.count) {
            [self showImageWithArray:self.imgUrls index:index];
        }
        
        return NO;
    }
    return YES;
}

- (void)showImageWithArray:(NSArray *)imageUrls index:(NSInteger)index {
    NSMutableArray *photos = [NSMutableArray new];
    
    [imageUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        photo.url = [NSURL URLWithString:obj];
        
        if (index == idx) {
            CGRect rect = CGRectFromString(self.imgFrames[idx]);
            
            rect.origin.y += 64;
            
            CGFloat offsetY = self.webView.scrollView.contentOffset.y;
            
            rect.origin.y -= offsetY;
            
            photo.sourceFrame = rect;
        }
        
        // 获取缓存？
        NSURLCache *cache = [NSURLCache sharedURLCache];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:obj]];
        
        NSCachedURLResponse *response = [cache cachedResponseForRequest:request];
        
        UIImage *image = [UIImage imageWithData:response.data];
        
        //        NSLog(@"%@", image);
        
        photo.placeholderImage = image;
        
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:index];
    browser.showStyle = GKPhotoBrowserShowStyleZoom;
    browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;
    
    browser.delegate  = self;
    
    [browser showFromVC:self];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index {
    // 执行js，隐藏对应的图片
    [self addViewToImageWithIndex:index hidden:NO];
}

- (void)photoBrowser:(GKPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear {
    // 执行js，显示对应的图片
    [self addViewToImageWithIndex:index hidden:YES];
}

- (void)addViewToImageWithIndex:(NSInteger)index hidden:(BOOL)hidden {
    if (hidden) {
        [self.whiteView removeFromSuperview];
        self.whiteView = nil;
    }else {
        CGRect frame = CGRectFromString(self.imgFrames[index]);
        
        CGFloat offsetY = self.webView.scrollView.contentOffset.y;
        
        frame.origin.y -= offsetY;
        
        self.whiteView = [[UIView alloc] initWithFrame:frame];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        [self.webView addSubview:self.whiteView];
    }
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
    
    // 获取图片frame
    NSString *getImgFramesJS = @"\
    function getImgFrames() {\
    var imgs = document.getElementsByTagName('img');\
    var frames = [];\
    for (var i = 0; i < imgs.length; i++) {\
    var img = imgs[i];\
    var imgX = img.offsetLeft;\
    var imgY = img.offsetTop;\
    var imgW = img.offsetWidth;\
    var imgH = img.offsetHeight;\
    frames[i] = {'x': imgX, 'y': imgY, 'w': imgW, 'h': imgH};\
    }\
    return frames;\
    }";
    
    [webView evaluateJavaScript:getImgFramesJS completionHandler:nil];
    
    [webView evaluateJavaScript:@"getImgFrames()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSArray *frames = (NSArray *)obj;
        
        NSMutableArray *imgFrames = [NSMutableArray new];
        
        for (NSDictionary *dic in frames) {
            CGRect rect = CGRectMake([dic[@"x"] floatValue],
                                     [dic[@"y"] floatValue],
                                     [dic[@"w"] floatValue],
                                     [dic[@"h"] floatValue]);
            
            [imgFrames addObject:NSStringFromCGRect(rect)];
        }
        self.imgFrames = imgFrames;
    }];
}

- (void)getImgsJSToUIWebView:(UIWebView *)webView {
    // 获取图片地址
    NSString *getImgUrlsJS = @"\
    function getImgUrls() {\
    var imgs = document.getElementsByTagName('img');\
    var strs = '';\
    for (var i = 0; i < imgs.length; i++) {\
    var img = imgs[i];\
    var str = (i == imgs.length - 1) ? '' : '||';\
    strs += img.src + str;\
    }\
    return strs;\
    }";
    
    [webView stringByEvaluatingJavaScriptFromString:getImgUrlsJS];
    
    NSString *strs = [webView stringByEvaluatingJavaScriptFromString:@"getImgUrls()"];
    self.imgUrls = [strs componentsSeparatedByString:@"||"];
    
    // 获取图片frame
    NSString *getImgFramesJS = @"\
    function getImgFrames() {\
    var imgs = document.getElementsByTagName('img');\
    var strs = '';\
    for (var i = 0; i < imgs.length; i++) {\
    var img = imgs[i];\
    var imgX = img.offsetLeft;\
    var imgY = img.offsetTop;\
    var imgW = img.offsetWidth;\
    var imgH = img.offsetHeight;\
    var frame = {'x': imgX, 'y': imgY, 'w': imgW, 'h': imgH};\
    var str = (i == imgs.length - 1) ? '' : '||';\
    strs += JSON.stringify(frame) + str;\
    }\
    return strs;\
    }";
    
    [webView stringByEvaluatingJavaScriptFromString:getImgFramesJS];
    
    NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"getImgFrames()"];
    
    NSArray *frames = [str componentsSeparatedByString:@"||"];
    
    NSMutableArray *imgFrames = [NSMutableArray new];
    
    for (NSString *s in frames) {
        
        NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        CGRect rect = CGRectMake([dic[@"x"] floatValue],
                                 [dic[@"y"] floatValue],
                                 [dic[@"w"] floatValue],
                                 [dic[@"h"] floatValue]);
        [imgFrames addObject:NSStringFromCGRect(rect)];
    }
    
    self.imgFrames = imgFrames;
}

- (NSString *)getHtmlString {
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>"];
    [html appendString:@"<head>"];
    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [html appendString:@"<meta content=\"width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" name=\"viewport\" />"];
    [html appendFormat:@"<style>"];
    [html appendFormat:@"body{\
     font-size:16px;\
     color: black;\
     padding: 10px;\
     /* 文字两端对齐 */\
     text-align: justify;\
     text-justify: inter-ideograph;\
     }\
     img{\
     width: 100%%;\
     height: auto;\
     }"];
    [html appendFormat:@"</style>"];
    [html appendFormat:@"</head>"];
    [html appendFormat:@"<body>"];
    [html appendString:[self getBodyString]];
    [html appendString:[self getImgClickJSString]];
    [html appendString:@"</script>"];
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    
    //    NSLog(@"%@", html);
    
    return html;
}

- (NSString *)getBodyString {
    NSString *content = @"&lt;div&gt;&lt;p&gt;有一天上课，老师问小丽：祖国是什么？小丽说：老师，祖国是我的母亲，老师说：回答的很好。接着老师又问小明：小明，祖国是什么啊？小明说：老师，祖国是小丽的母亲。&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/39a60002a2c7d04d9607&quot; img_width&#x3D;&quot;500&quot; img_height&#x3D;&quot;522&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;小朋友，你妈妈叫什么名字？”&lt;/p&gt;&lt;p&gt;“王者荣耀”&lt;/p&gt;&lt;p&gt;“完了完了，这孩子打游戏打傻了！”&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p1.pstatp.com/large/39a90000ae4c690e87b9&quot; img_width&#x3D;&quot;318&quot; img_height&#x3D;&quot;224&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;佛山无影脚！&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/39a30002b57d83e3ddd4&quot; img_width&#x3D;&quot;300&quot; img_height&#x3D;&quot;274&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;别人早起VS我早起！简直太形象。&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p9.pstatp.com/large/39a40002b3a7c82de150&quot; img_width&#x3D;&quot;327&quot; img_height&#x3D;&quot;190&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;先生们、女生们，别随意改变乘客的行程：人家要下车，您生生把人家挤回去了。&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/39a30002b76cfe12ed74&quot; img_width&#x3D;&quot;220&quot; img_height&#x3D;&quot;220&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;这样的”默契“你们领导和家人知道吗？&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/39a90000b7258fa30427&quot; img_width&#x3D;&quot;214&quot; img_height&#x3D;&quot;285&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;反正我看了好多遍，也没看清他长什么样！&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/39a90000ba9820e14411&quot; img_width&#x3D;&quot;369&quot; img_height&#x3D;&quot;400&quot; alt&#x3D;&quot;搞笑gif图片：生活远比段子精彩！&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;身材好，就这么自信！&lt;/p&gt;&lt;/div&gt;";
    
    NSAttributedString *body = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    
    return body.string;
}

- (NSString *)getImgClickJSString {
    
    NSMutableString *jsString = [NSMutableString new];
    
    // 给所有图片加入点击事件
    [jsString appendString:@"<script>"];
    [jsString appendString:@"function addImgClick() {\
     var imgs = document.getElementsByTagName('img');\
     for (var i = 0; i < imgs.length; i++) {\
     var img = imgs[i];\
     img.onclick = function() {\
     window.location.href = 'imgurl:' + this.src;\
     }\
     }\
     }"];
    [jsString appendString:@"addImgClick();"];  // 调用js
    
    return jsString;
}


- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW {
    CGSize size = CGSizeMake(maxW, CGFLOAT_MAX);
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:size options:options attributes:attrs context:nil].size;
}

- (CGSize)sizeWithAttrString:(NSAttributedString *)attrString maxW:(CGFloat)maxW {
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    
    return [attrString boundingRectWithSize:CGSizeMake(maxW, CGFLOAT_MAX) options:options context:nil].size;
}

@end
