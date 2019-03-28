//
//  GKTest02ViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/27.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTest02ViewController.h"
#import "GKTest02ViewCell.h"

#import "GKPhotoBrowser.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface GKTest02ViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

//@property (nonatomic, strong) UIView *containerView;

@end

@implementation GKTest02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    
    [self setupView];

    [self setupData];
}

- (void)dealloc {
    NSLog(@"002dealloc");
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.top        = self.gk_navigationBar.bottom;
    self.tableView.height     = self.view.height - self.gk_navigationBar.height;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.rowHeight  = 200;
    [self.tableView registerClass:[GKTest02ViewCell class] forCellReuseIdentifier:@"test02"];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    
    self.dataSource = @[
        @[@"001", @"002", @"004"],
        @[@"http://ww2.sinaimg.cn/large/85d77acdgw1f4hzsolyscg20cy07xkjp.jpg",
          @"http://ww2.sinaimg.cn/large/85ccde71gw1f9ksx38wjrg20dw05ah0v.jpg",
          @"http://ww1.sinaimg.cn/large/85cccab3gw1etdecj1njlg20dw06lnpd.jpg",
          @"http://ww2.sinaimg.cn/large/85cccab3gw1etdeckhl80g20dw0991f4.jpg",
          @"http://ww1.sinaimg.cn/large/85cccab3gw1etekil9309g20dw06ex1r.jpgs",
          @"http://ww2.sinaimg.cn/large/85cccab3gw1etdz3c7w9ag20dw07th5f.jpg",
          @"http://ww1.sinaimg.cn/large/85cccab3gw1ete5mkvd3kg20dw07en7y.jpg",
          @"https://upfile2.asqql.com/upfile/2009pasdfasdfic2009s305985-ts/gif_spic/2018-5/201852021281430160.gif",
          @"http://s1.dwstatic.com/group1/M00/AC/19/ee76abfe1e23a8ad93665c5863c89a21.gif"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=725c10ff470cf0282d148b7ec8e32a1d&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F9358d109b3de9c8210ea114f6581800a18d84367.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=70b2e4e0c6f1d7613d9a7154b9477f81&imgtype=0&src=http%3A%2F%2Fh.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F80cb39dbb6fd5266776325d5a218972bd50736a2.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=69a986cc38212178c27dc157195f0700&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F241f95cad1c8a786a18336ce6e09c93d71cf5040.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=0342f8813a4135448d31297876d2540c&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fcc11728b4710b9128942bd3ecafdfc039345226a.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=1b0564b35bd718e2e4593a5374740ce3&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F1b4c510fd9f9d72ad30cb6dcdd2a2834359bbb83.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=541a696a6b096a51c650a7473ac32ff3&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F6159252dd42a28349109a6cb52b5c9ea14cebf47.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435193&di=496f021c6db03f1cb9a6fa1af9fa50b9&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4d086e061d950a7be91b560503d162d9f3d3c9c1.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=541a696a6b096a51c650a7473ac32ff3&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F6159252dd42a28349109a6cb52b5c9ea14cebf47.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435193&di=496f021c6db03f1cb9a6fa1af9fa50b9&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4d086e061d950a7be91b560503d162d9f3d3c9c1.jpg",
          @"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=3120490352,2615057413&fm=173&s=90945A951850C7D859A42DCC030050B0&w=640&h=1058&img.JPEG"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536686&di=aa91a60dfb4f9f762f58bb4513f9ef64&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F50da81cb39dbb6fd493c67e70024ab18962b378f.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=3b472d84a7801f2fd48afaa4f041fadb&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0824ab18972bd40704fe413d72899e510fb30930.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=18fcb83dcc07f87aefbf58e8538ed4d8&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd1160924ab18972b22abd40aefcd7b899f510a59.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=b40f1593ca5f51f64c8f8670598e79a2&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fcrop%253D0%252C0%252C1024%252C654%2Fsign%3Dafc45f018b025aafc77d248bc6dd8754%2F838ba61ea8d3fd1f3fe3bbfb394e251f94ca5f0c.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a47731fce0273aae3ddeb03d89fc273b&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fb7003af33a87e950f0e956ad19385343faf2b471.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=121d9ff529f2d9807970f965aeca6c0f&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F241f95cad1c8a7861cb6a3ce6e09c93d71cf5056.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a82dd1f57162599367340d0b5a9ece74&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fae51f3deb48f8c546c9162ee33292df5e1fe7fb5.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=22258dd90dec8f57bdeea79f8c17b04f&imgtype=0&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0d338744ebf81a4c1393d808de2a6059242da649.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=16dfed673e74c9e5f1c53e02700ab174&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd058ccbf6c81800a6d5592cfb83533fa838b47ba.jpg"],
        @[@"http://dpic.tiankong.com/ms/sm/QJ6951370763.jpg",
          @"http://dpic.tiankong.com/l2/7h/QJ8115237746.jpg",
          @"http://dpic.tiankong.com/d1/kd/QJ8128775622.jpg",
          @"http://dpic.tiankong.com/tp/sa/QJ9122677367.jpg",
          @"http://dpic.tiankong.com/p9/um/QJ6256170643.jpg",
          @"http://dpic.tiankong.com/8t/zv/QJ8911632097.jpg",
          @"http://dpic.tiankong.com/5c/uu/QJ6328325368.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705809&di=84aa8c721b8ee51db9f8c9c74012eeaa&imgtype=0&src=http%3A%2F%2Ftupian.enterdesk.com%2F2014%2Fxll%2F01%2F24%2F1%2Fweimei5.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705809&di=e5592a5f90588824e978c5bfebe95294&imgtype=0&src=http%3A%2F%2Fpic41.nipic.com%2F20140519%2F18165794_221908372105_2.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=353cc6066f30406f2f1a113842241c9d&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201503%2F2015030308.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=cd5dd462c5d0548c0261be6cb25c62e4&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F962bd40735fae6cdded3aa7505b30f2442a70fba.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=856902f14a4249ca68c0c984c81df32b&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F241f95cad1c8a786d18fe7076d09c93d70cf5015.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=6d59141f93c04d28d96002b1d4dc3a42&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fa50f4bfbfbedab645a1dea02fe36afc378311e80.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=ebefc060c627b07cb2b34ca2a85b778f&imgtype=0&src=http%3A%2F%2Fimg03.tooopen.com%2Fimages%2F20131025%2Fsy_44135026991.jpg",
          @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=2776df68d88cd0ec1a31a152b7680403&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0df3d7ca7bcb0a4683d077f86263f6246a60af05.jpg"],
        @[@"http://dpic.tiankong.com/kl/6r/QJ6475648593.jpg",
          @"http://dpic.tiankong.com/ng/0v/QJ6399247343.jpg",
          @"http://dpic.tiankong.com/09/cs/QJ8196726416.jpg",
          @"http://dpic.tiankong.com/25/he/QJ6731671323.jpg",
          @"http://dpic.tiankong.com/7h/1z/QJ6611712300.jpg",
          @"http://dpic.tiankong.com/gt/zp/QJ6180943615.jpg",
          @"http://dpic.tiankong.com/pv/lc/QJ6912461619.jpg",
          @"http://dpic.tiankong.com/tz/1u/QJ6490864055.jpg",
          @"http://dpic.tiankong.com/gg/kh/QJ6870583295.jpg"],
        @[@"http://dpic.tiankong.com/rw/1z/QJ6365297557.jpg",
          @"http://dpic.tiankong.com/26/t3/QJ8823004283.jpg",
          @"http://dpic.tiankong.com/h9/pl/QJ6858296969.jpg",
          @"http://dpic.tiankong.com/bw/bs/QJ6499097494.jpg",
          @"http://dpic.tiankong.com/un/mb/QJ8128245221.jpg",
          @"http://dpic.tiankong.com/52/9c/QJ6867374968.jpg",
          @"http://dpic.tiankong.com/5h/h3/QJ6132344120.jpg"]
    ];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTest02ViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test02" forIndexPath:indexPath];
    
    cell.photos = self.dataSource[indexPath.row];
    
    __weak __typeof(self) weakSelf = self;
    cell.imgClickBlock = ^(UIView *containerView, NSArray *photos, NSInteger index) {
        NSMutableArray *photoArrs = [NSMutableArray new];
        
        [photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKPhoto *photo        = [GKPhoto new];
            if ([obj hasPrefix:@"http"]) {
                photo.url         = [NSURL URLWithString:obj];
            }else {
                photo.image       = [UIImage imageNamed:obj];
            }
            photo.sourceImageView = containerView.subviews[idx];
            [photoArrs addObject:photo];
        }];
        
        GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photoArrs currentIndex:index];
        browser.showStyle       = GKPhotoBrowserShowStyleZoom;
        browser.hideStyle       = GKPhotoBrowserHideStyleZoomScale;
        browser.failStyle       = GKPhotoBrowserFailStyleOnlyImage;
        browser.failureText     = @"图片加载失败了，555";
        browser.failureImage    = [UIImage imageNamed:@"error"];
        browser.delegate        = self;
        browser.isLowGifMemory  = YES;
        
        [browser showFromVC:weakSelf];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithCount:images.count];
}

#pragma mark - GKPhotoBrowserDelegate
- (void)photoBrowser:(GKPhotoBrowser *)browser loadFailAtIndex:(NSInteger)index photoView:(GKPhotoView *)photoView {
    [SVProgressHUD setMaximumDismissTimeInterval:2.0f];
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

@end
