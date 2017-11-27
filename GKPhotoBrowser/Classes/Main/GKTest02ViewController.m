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

@interface GKTest02ViewController ()<UITableViewDataSource, UITableViewDelegate, GKPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation GKTest02ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test02";
    
    [self setupView];
    
    [self setupData];
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
        @[@"001", @"002", @"003"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=725c10ff470cf0282d148b7ec8e32a1d&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F9358d109b3de9c8210ea114f6581800a18d84367.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=70b2e4e0c6f1d7613d9a7154b9477f81&imgtype=0&src=http%3A%2F%2Fh.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F80cb39dbb6fd5266776325d5a218972bd50736a2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=69a986cc38212178c27dc157195f0700&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F241f95cad1c8a786a18336ce6e09c93d71cf5040.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435195&di=0342f8813a4135448d31297876d2540c&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fcc11728b4710b9128942bd3ecafdfc039345226a.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=1b0564b35bd718e2e4593a5374740ce3&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F1b4c510fd9f9d72ad30cb6dcdd2a2834359bbb83.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=541a696a6b096a51c650a7473ac32ff3&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F6159252dd42a28349109a6cb52b5c9ea14cebf47.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435193&di=496f021c6db03f1cb9a6fa1af9fa50b9&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4d086e061d950a7be91b560503d162d9f3d3c9c1.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435194&di=541a696a6b096a51c650a7473ac32ff3&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F6159252dd42a28349109a6cb52b5c9ea14cebf47.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084435193&di=496f021c6db03f1cb9a6fa1af9fa50b9&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4d086e061d950a7be91b560503d162d9f3d3c9c1.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536686&di=aa91a60dfb4f9f762f58bb4513f9ef64&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F50da81cb39dbb6fd493c67e70024ab18962b378f.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=3b472d84a7801f2fd48afaa4f041fadb&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0824ab18972bd40704fe413d72899e510fb30930.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=18fcb83dcc07f87aefbf58e8538ed4d8&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd1160924ab18972b22abd40aefcd7b899f510a59.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=b40f1593ca5f51f64c8f8670598e79a2&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fimage%2Fcrop%253D0%252C0%252C1024%252C654%2Fsign%3Dafc45f018b025aafc77d248bc6dd8754%2F838ba61ea8d3fd1f3fe3bbfb394e251f94ca5f0c.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a47731fce0273aae3ddeb03d89fc273b&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fb7003af33a87e950f0e956ad19385343faf2b471.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=121d9ff529f2d9807970f965aeca6c0f&imgtype=0&src=http%3A%2F%2Ff.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F241f95cad1c8a7861cb6a3ce6e09c93d71cf5056.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536685&di=a82dd1f57162599367340d0b5a9ece74&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fae51f3deb48f8c546c9162ee33292df5e1fe7fb5.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=22258dd90dec8f57bdeea79f8c17b04f&imgtype=0&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0d338744ebf81a4c1393d808de2a6059242da649.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084536684&di=16dfed673e74c9e5f1c53e02700ab174&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fd058ccbf6c81800a6d5592cfb83533fa838b47ba.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=c4c478a8b693759b6987defe7ea2d57a&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F7acb0a46f21fbe09afef810661600c338744ad6b.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=10b5ce1de774e825cf0e05b37ba49609&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F8601a18b87d6277f5062393822381f30e924fcba.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=3d2638db0b2f34f2879025a5c9739721&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fd50735fae6cd7b89051430a0052442a7d9330e9c.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=599d94f656740387d957be999c792917&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fd52a2834349b033b1c4bcdcf1fce36d3d439bde7.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=8dfd39e2d96b0fcabc65822f56f46df9&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3Da58e9cff1fce36d3b6098b73529a50f2%2Fd439b6003af33a87176b603fcc5c10385343b595.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624319&di=623a7467b94fade50d37df415616a4c0&imgtype=0&src=http%3A%2F%2Ftupian.enterdesk.com%2F2014%2Fmxy%2F04%2F3%2F2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084624320&di=8dfd39e2d96b0fcabc65822f56f46df9&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3Da58e9cff1fce36d3b6098b73529a50f2%2Fd439b6003af33a87176b603fcc5c10385343b595.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705809&di=84aa8c721b8ee51db9f8c9c74012eeaa&imgtype=0&src=http%3A%2F%2Ftupian.enterdesk.com%2F2014%2Fxll%2F01%2F24%2F1%2Fweimei5.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705809&di=e5592a5f90588824e978c5bfebe95294&imgtype=0&src=http%3A%2F%2Fpic41.nipic.com%2F20140519%2F18165794_221908372105_2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=353cc6066f30406f2f1a113842241c9d&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201503%2F2015030308.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=cd5dd462c5d0548c0261be6cb25c62e4&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F962bd40735fae6cdded3aa7505b30f2442a70fba.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705808&di=856902f14a4249ca68c0c984c81df32b&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F241f95cad1c8a786d18fe7076d09c93d70cf5015.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=6d59141f93c04d28d96002b1d4dc3a42&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Fa50f4bfbfbedab645a1dea02fe36afc378311e80.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=ebefc060c627b07cb2b34ca2a85b778f&imgtype=0&src=http%3A%2F%2Fimg03.tooopen.com%2Fimages%2F20131025%2Fsy_44135026991.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084705807&di=2776df68d88cd0ec1a31a152b7680403&imgtype=0&src=http%3A%2F%2Fb.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F0df3d7ca7bcb0a4683d077f86263f6246a60af05.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947873&di=7db554d4ad4386ce4ab6cc2e735f8587&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F83025aafa40f4bfb982b2e80094f78f0f636186e.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947871&di=1196b40ca4cfadcaec496e7a33f1b095&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fa1ec08fa513d2697f8f2ba895ffbb2fb4216d8c5.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947872&di=31acd5d2fb58fafc682fa33a3afbc5f0&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Ffd039245d688d43fc7682126771ed21b0ff43b24.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947871&di=ee05a85a6ef998115d352dfe99962285&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F4a36acaf2edda3ccd53548ea0be93901203f9223.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947870&di=757d8346420d03b0227d738ec3a6a1b9&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F96dda144ad345982cc2e364606f431adcaef84ba.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947870&di=f665b8ca5fd1973f34752816afc1e7a6&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fac4bd11373f0820207282ceb41fbfbedaa641baf.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947869&di=7cb43c6f5886740d9a67e12eca3f1a29&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fd1a20cf431adcbef0910a1d2a6af2edda3cc9f3a.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947869&di=b1753fb479f9004d04823783d622353d&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F5366d0160924ab18620f34e33ffae6cd7a890bcd.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084947868&di=a5c774fcaaa5dcbdc8abae14d9b1c0f4&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fb58f8c5494eef01fb693d3fcebfe9925bc317d00.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783392&di=b6b12b22d0278964846bce65e73fb8d6&imgtype=0&src=http%3A%2F%2Fwww.dabaoku.com%2Fsucaidatu%2Fzhonghua%2Ffengjingyouhua%2F173817.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783392&di=2b003afada58223a8f21bb0a0cfcc99a&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201508%2F2015082114.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783392&di=40880f3cc83ac1108e3a95ba32b62a8f&imgtype=0&src=http%3A%2F%2Fdl.bizhi.sogou.com%2Fimages%2F2013%2F08%2F05%2F355371.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783392&di=eba199cc4c8fdb63dc9f92219d068dad&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201503%2F2015031809.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783391&di=6e19fccdbc778033e8de9955592366d8&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Ff%2F568ca55c8ba5d.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783391&di=2074723419b03628b9001d5ae8d62d27&imgtype=0&src=http%3A%2F%2Fimg02.tooopen.com%2Fimages%2F20140516%2Fsy_61321928719.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783391&di=38da0d550fb5efaf05f30e43c1f52eaf&imgtype=0&src=http%3A%2F%2Fimg05.tooopen.com%2Fimages%2F20150314%2Ftooopen_sy_82511624158.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783391&di=b3170815b7b0bbdc050358c5a101b26d&imgtype=0&src=http%3A%2F%2Fwww.dabaoku.com%2Fsucaidatu%2Fzhonghua%2Ffengjingyouhua%2F472247.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084783390&di=121df1a52b706e478694db233959c8af&imgtype=0&src=http%3A%2F%2Ftupian.enterdesk.com%2F2013%2Flxy%2F12%2F24%2F3%2F7.jpg"],
        @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876094&di=ec846280b54859286f3425502b6f2079&imgtype=0&src=http%3A%2F%2Fpic64.nipic.com%2Ffile%2F20150417%2F11986156_092806491000_2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876094&di=6c56405c53271ad65dbe968962cf9aff&imgtype=0&src=http%3A%2F%2Fimg05.tooopen.com%2Fimages%2F20150314%2Ftooopen_sy_82507961982.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876093&di=a5d1e8204d37604fe6cfca7fdd7bab10&imgtype=0&src=http%3A%2F%2Fpic47.nipic.com%2F20140909%2F11114139_120018320000_2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876093&di=bee34ea61aab17e0df8a64a7704a6718&imgtype=0&src=http%3A%2F%2Fpic44.nipic.com%2F20140717%2F19244370_115433268000_2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876093&di=7c0cd59aae670476c3b2643cf84ddecc&imgtype=0&src=http%3A%2F%2Fpic2.ooopic.com%2F10%2F88%2F30%2F19b1OOOPIC6c.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876092&di=cb20a25f21c317fe187956e86d44cbd6&imgtype=0&src=http%3A%2F%2Fpic41.nipic.com%2F20140522%2F11114139_140336363186_2.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509084876092&di=7dceca5814d09807ab6b56d6c8c91044&imgtype=0&src=http%3A%2F%2Fimg05.tooopen.com%2Fimages%2F20140523%2Fsy_61685765447.jpg"]
        
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
//        browser.photos       = photoArrs;
//        browser.currentIndex = index;
        browser.showStyle    = GKPhotoBrowserShowStyleZoom;
        
        [browser showFromVC:self];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *images = self.dataSource[indexPath.row];
    
    return [GKTest02ViewCell cellHeightWithCount:images.count];
}

@end
