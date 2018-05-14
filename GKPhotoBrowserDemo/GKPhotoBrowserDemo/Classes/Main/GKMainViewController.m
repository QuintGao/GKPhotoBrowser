//
//  GKMainViewController.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/25.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKMainViewController.h"
#import "GKTest01ViewController.h"

@interface GKMainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *mainTable;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation GKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"Main";
    
    [self setupView];
    
    [self setupData];
}

- (void)setupView {
    self.mainTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.mainTable.top        = self.gk_navigationBar.bottom;
    self.mainTable.height     = self.view.height - self.gk_navigationBar.height;
    self.mainTable.dataSource = self;
    self.mainTable.delegate   = self;
    [self.mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mainTableCell"];
    [self.view addSubview:self.mainTable];
}

- (void)setupData {
    self.dataList = @[
                      @{@"text"  : @"TableViewCell单图none",
                        @"class" : @"GKTest01ViewController"},
                      @{@"text"  : @"TableViewCell多图zoom",
                        @"class" : @"GKTest02ViewController"},
                      @{@"text"  : @"TableViewCell多图push",
                        @"class" : @"GKTest03ViewController"},
                      @{@"text"  : @"微信朋友圈",
                        @"class" : @"GKTimeLineViewController"},
                      @{@"text"  : @"今日头条",
                        @"class" : @"GKToutiaoViewController"},
                      @{@"text"  : @"简书",
                        @"class" : @"GKJianshuViewController"},
                      @{@"text"  : @"测试",
                        @"class" : @"GKTestViewController"}
                      ];
    
    [self.mainTable reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainTableCell"];
    
    NSDictionary *dic = self.dataList[indexPath.row];
    
    cell.textLabel.text = dic[@"text"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataList[indexPath.row];
    
    Class cls = NSClassFromString(dic[@"class"]);
    
    UIViewController *vc = [cls new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
