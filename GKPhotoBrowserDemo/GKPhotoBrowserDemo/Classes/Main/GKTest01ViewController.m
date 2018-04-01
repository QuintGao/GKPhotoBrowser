//
//  GKTest01ViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/25.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKTest01ViewController.h"
#import "GKTest01ViewCell.h"
#import "GKPhotoBrowser.h"

@interface GKTest01ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GKTest01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"test01";
    
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
    [self.tableView registerClass:[GKTest01ViewCell class] forCellReuseIdentifier:@"test01"];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    self.dataSource = @[@"http://c.hiphotos.baidu.com/image/pic/item/d50735fae6cd7b89bcbbb642062442a7d8330e1f.jpg",
                        @"http://e.hiphotos.baidu.com/image/pic/item/21a4462309f79052f4d5baff05f3d7ca7acbd52d.jpg",
                        @"http://e.hiphotos.baidu.com/image/pic/item/6f061d950a7b02084771d7216bd9f2d3562cc8b2.jpg",
                        @"http://h.hiphotos.baidu.com/image/pic/item/30adcbef76094b3623b3f32daacc7cd98c109dc9.jpg",
                        @"http://b.hiphotos.baidu.com/image/pic/item/aec379310a55b319427afeb54aa98226cefc176a.jpg",
                        @"http://g.hiphotos.baidu.com/image/pic/item/b90e7bec54e736d1615493c992504fc2d46269af.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/4a36acaf2edda3cc3f54a1e108e93901203f92ba.jpg",
                        @"http://d.hiphotos.baidu.com/image/pic/item/cb8065380cd791232c1a07b4a4345982b3b7807c.jpg",
                        @"http://c.hiphotos.baidu.com/image/pic/item/58ee3d6d55fbb2fb89670ed3464a20a44723dca7.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509101764395&di=90494aa34db8a173e11731abcddece2e&imgtype=0&src=http%3A%2F%2Fpic13.nipic.com%2F20110319%2F6682414_092248180187_2.jpg"];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTest01ViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test01"];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *photos = [NSMutableArray new];
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKPhoto *photo = [GKPhoto new];
        photo.url = [NSURL URLWithString:obj];
       
        [photos addObject:photo];
    }];
    
    GKPhotoBrowser *browser = [GKPhotoBrowser photoBrowserWithPhotos:photos currentIndex:indexPath.row];
    browser.showStyle = GKPhotoBrowserShowStyleNone;
    browser.loadStyle = GKPhotoBrowserLoadStyleDeterminate;
    [browser showFromVC:self];
}

@end
