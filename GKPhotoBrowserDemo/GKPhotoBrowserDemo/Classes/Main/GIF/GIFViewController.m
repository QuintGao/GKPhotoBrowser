//
//  GIFViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/12/4.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GIFViewController.h"
#import "GKToutiaoModel.h"
#import <WebKit/WebKit.h>
#import "GKPhotoBrowser.h"

@interface GIFViewController ()<WKNavigationDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSArray *imgUrls;

@property (nonatomic, strong) NSArray *imgFrames;

@property (nonatomic, strong) UIView *whiteView;

@end

@implementation GIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"GIF图片加载";
    self.view.backgroundColor    = [UIColor whiteColor];
    
    [self addWKWebView];
}

- (void)addWKWebView {
    CGRect frame = CGRectMake(0, self.gk_navigationBar.bottom, KScreenW, KScreenH - self.gk_navigationBar.height);
    self.webView = [[WKWebView alloc] initWithFrame:frame];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView loadHTMLString:[self getHtmlString] baseURL:nil];
}

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
        
        if (index >= 0 && index < self.imgUrls.count) {
            [self showImageWithArray:self.imgUrls index:index];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
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
    
    return html;
}

- (NSString *)getBodyString {
    NSString *content = @"&lt;div&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p1.pstatp.com/large/402e0002bb952d89b317&quot; img_width&#x3D;&quot;195&quot; img_height&#x3D;&quot;273&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;第一次来大城市，没见过这种车&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p1.pstatp.com/large/402f0001698b3231793d&quot; img_width&#x3D;&quot;173&quot; img_height&#x3D;&quot;214&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;手不够，嘴来凑，妹子果然聪明！&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/402d0002c62195dd68c9&quot; img_width&#x3D;&quot;215&quot; img_height&#x3D;&quot;244&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;这就叫乐极生悲吧&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/402b0002d805574e34b9&quot; img_width&#x3D;&quot;257&quot; img_height&#x3D;&quot;170&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;就觉得很有爱&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/402a0002e18148958ca9&quot; img_width&#x3D;&quot;300&quot; img_height&#x3D;&quot;296&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;厉害了，我的姐！！吃东西我只服你！！&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p1.pstatp.com/large/402d0002c6a5cb854b69&quot; img_width&#x3D;&quot;500&quot; img_height&#x3D;&quot;281&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;神同步&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p9.pstatp.com/large/402a0002e177d91cf123&quot; img_width&#x3D;&quot;210&quot; img_height&#x3D;&quot;228&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;这是干什么的啊！！！&lt;/p&gt;&lt;p&gt;&lt;img src&#x3D;&quot;http://p3.pstatp.com/large/402e0002bd4f67e630fe&quot; img_width&#x3D;&quot;224&quot; img_height&#x3D;&quot;251&quot; alt&#x3D;&quot;搞笑gif动态图，段子：不是，最后他老婆和别人跑了&quot; inline&#x3D;&quot;0&quot;&gt;&lt;/p&gt;&lt;p&gt;我知道你有大胆的想法&lt;/p&gt;&lt;p&gt;1：同事：小伙子还在加班吗？我：是啊！刚来业务不熟加班多多熟悉业务。同事：嗯，不错啊，挺积极啊，有前途。你让我想起一个同事他以前和你一样天天加班，最后……我：最后加薪了还是升职了？同事：不是，最后他老婆和别人跑了……&lt;/p&gt;&lt;p&gt;2：我们老师的口头禅，觉得对就顶我！1.这又是一道送分题。2.我在办公室里都能听到你们的声音，整栋楼就咱们班最吵！3.由于时间关系这道题我们一起做。4.我要找平时不举手的同学回答问题！5.你们成绩差跟我有关系吗？我的工资一分不少！6.你们班是我教过最差的一班！7.我再讲两分钟，之后再下课！8.今天体育老师没有来，我们上英语课！&lt;/p&gt;&lt;p&gt;3：大海刚上地铁，就闻到一股韭菜包子味，大海坐下，用杀人的眼光看着吃韭菜包子的那汉子。那汉子好像感觉到了不对，把包子收起来，转头对大海说：“哥呀，我不吃包子了，能不能把您鞋穿上，咱各退一步……”&lt;/p&gt;&lt;p&gt;4：父子赌气妻子出差，丈夫和儿子都不愿做饭，只得赌气上饭店。儿子对服务生说：给那角落的老头上好酒好菜，我买单！服务生不解：为何？儿子说：我和他儿媳相好！服务生看老头吃的欢，便问：他和你儿媳妇好你不揍他？老头笑了：他和我儿媳好才几年？我跟他妈好三十年了！&lt;/p&gt;&lt;/div&gt;";
    
    // 转义字符
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
