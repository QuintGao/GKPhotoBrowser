//
//  GKToutiaoDetailViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/11/13.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKToutiaoDetailViewController.h"
#import "GKToutiaoModel.h"
#import <WebKit/WebKit.h>
#import "GKPhotoBrowser.h"

@interface GKToutiaoDetailViewController ()<WKNavigationDelegate, GKPhotoBrowserDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) WKWebView *webView;
//@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSArray *imgUrls;

@property (nonatomic, strong) NSArray *imgFrames;

@property (nonatomic, strong) UIView *whiteView;

@end

@implementation GKToutiaoDetailViewController

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
    NSString *content = @"&lt;div&gt;&lt;p&gt;电视剧《猎场》在最新的剧情种贾衣玫终于出场了，也就是说和郑秋冬有感情线的三位女主角都在剧中“集合”了，但是在剧中最新的剧情中郑秋冬和熊青春还好着呢，那么郑秋冬又怎么会和贾衣玫在一起呢？&lt;/p&gt;&lt;p&gt;在《猎场》的官方人物介绍总，贾衣玫的身份是郑秋冬的前女友，所以在剧中如果贾衣玫和郑秋冬在一起的话，前提郑秋冬和熊青春得分手。&lt;/p&gt;&lt;p&gt;一个是大雪纷飞的冬季，一个是春暖花开的春季，合在一起就成为了恋爱的季节。在杭州合伙同开职介所的郑秋冬和熊青春，在经历过对彼此的误解、不安之后，终于认清了对方并成功转化为好感。&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p9.pstatp.com/large/46d4000303bba298a49e&quot; img_width&#x3D;&quot;600&quot; img_height&#x3D;&quot;400&quot; alt&#x3D;&quot;《猎场》郑秋冬和贾衣玫怎么好上的 前提是和熊青春分手&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;在惠成功(徐阁饰)的尽力撮合下，“季节cp”这对欢喜冤家终于在一起了。&lt;/p&gt;&lt;p&gt;“季节cp”刚刚开始发糖，贾衣玫(章龄之饰)就在马不停蹄赶来的路上了。贾衣玫来到职介所面试，熊青春亲自出马面见了她。那么，熊青春究竟会抛出什么问题来考核贾衣玫，贾衣玫能否轻松过关最终加入“玉汝于成职介所”呢？&lt;/p&gt;&lt;p&gt;好奇的网友们已经开始了自己的预测，“赌五毛钱贾衣玫一定能成功，就是这么自信”、“熊青春看到郑秋冬和洗脚小妹多聊了几句就醋性大发，这么优秀的贾衣玫她能傻到引狼入室？&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/46cf000513d2b4307208&quot; img_width&#x3D;&quot;600&quot; img_height&#x3D;&quot;400&quot; alt&#x3D;&quot;《猎场》郑秋冬和贾衣玫怎么好上的 前提是和熊青春分手&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;在之前公布的剧照中能看出，郑秋冬和贾衣玫应该会是同事关系然后发展成为男女朋友关系的，据悉贾衣玫在郑秋冬的事业上也会有所帮助。&lt;/p&gt;&lt;p&gt;剧中郑秋冬一共有三个女朋友，罗伊人、熊青春和贾衣玫，虽然在剧中郑秋冬和这三个人都在一起过，但是都经历过分手，最后郑秋冬和感情归宿到底是谁，还要看剧情接下来会如何发展了。&lt;/p&gt;&lt;p&gt;在《猎场》中，章龄之饰演的贾衣玫是一个非常特别的角色，她不但要周旋在诸多职场精英之间展示自己女性特有的魅力，还要负责调和气氛的情感线索。&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p1.pstatp.com/large/46d10004d8be18e1d401&quot; img_width&#x3D;&quot;600&quot; img_height&#x3D;&quot;400&quot; alt&#x3D;&quot;《猎场》郑秋冬和贾衣玫怎么好上的 前提是和熊青春分手&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;她与胡歌组成的情侣档，更是成为观众关注的焦点——随着《伪装者》、《琅琊榜》等剧的热播，胡歌的人气再次飙升，男神地位无法撼动，而人气花旦章龄之，在结束了《他来了请闭眼》的拍摄后，火速走进《猎场》，这两位偶像实力派的强强发力，自然成为热门话题。&lt;/p&gt;&lt;p&gt;另外，众所周知，胡歌和章龄之的老公陈龙是“伉俪情深”的好兄弟，二人合作多次，见证彼此在演艺道路上的成长，而到了《猎场》，三个人的关系就略显“奇妙”——老公的“兄弟”胡歌竟然成为章龄之的男朋友，这一转变不但让演员觉得很有意思，也让广大的观众很是好奇。&lt;/p&gt;&lt;/div&gt;";
    
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
