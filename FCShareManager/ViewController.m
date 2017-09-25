//
//  ViewController.m
//  FCShareManager
//
//  Created by fanchuan on 2017/9/25.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //large title
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    self.navigationItem.title = @"测试";
    
    //safe inset
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    NSLog(@"%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    NSLog(@"%@",NSStringFromUIEdgeInsets(self.tableView.safeAreaInsets));
    NSLog(@"%@",NSStringFromUIEdgeInsets(self.tableView.adjustedContentInset));
    NSLog(@"%@",NSStringFromUIEdgeInsets(self.tableView.contentInset));
    
    //search navigation item
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
    UISearchController *searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchVC.delegate = self;
    searchVC.searchResultsUpdater = self;
    self.navigationItem.searchController = searchVC;
}

#pragma mark - search
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSLog(@"%@",searchController.searchBar.text);
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
NSLog(@"%f",self.navigationController.navigationBar.frame.size.height);
}


@end
