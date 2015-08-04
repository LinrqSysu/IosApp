//
//  PhotoFallViewController.m
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "PhotoFallViewController.h"
#import "PhotoFallLayout.h"
#import "ImageData.h"
#import "AppDelegate.h"
#import "Common.h"

@interface PhotoFallViewController ()

@property (strong, nonatomic) id<UICollectionViewDataSource> dataSource;
@property (strong, nonatomic) id<UICollectionViewDelegate> delegate;
@property (strong, nonatomic) PhotoFallLayout* photoFallLayout;
@property (strong, nonatomic) NSIndexPath* indexPathToDelete;  //即将用于删除的indexpath
@property (strong, nonatomic) UILabel* lbl;

- (void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer;
@end

@implementation PhotoFallViewController
@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithHeight: (CGFloat)viewHeight Title:(NSString*) title
{
    self = [super init];
    
    if (self) {
        
        CGRect frame = CGRectMake(4,4 + [Common globalStatusBarHeight] + TITLE_FIELD_HEIGHT, [Common globalWidth]-10, viewHeight - TITLE_FIELD_HEIGHT - 4);
        
        //初始化layout
        _photoFallLayout = [[PhotoFallLayout alloc] init];
        
        //初始化view
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_photoFallLayout];
        
        //初始化cell
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"];
        
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        UILongPressGestureRecognizer *longPressReconizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        longPressReconizer.minimumPressDuration = .8; //seconds
        longPressReconizer.delegate = self;
        [self.collectionView addGestureRecognizer:longPressReconizer];
        
        self.collectionView.backgroundColor = [Common globalBackgroundColor];
        
        //仅用于遮挡上方透明的状态栏呵呵
        UILabel *coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [Common globalWidth], 4 + [Common globalStatusBarHeight])];
        [coverLabel setBackgroundColor:[Common globalBackgroundColor]];
        [self.view addSubview:coverLabel];
        
        //设置标题栏
        _lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 4 + [Common globalStatusBarHeight], [Common globalWidth], TITLE_FIELD_HEIGHT)];
        _lbl.textAlignment = NSTextAlignmentCenter;
        _lbl.font = [UIFont systemFontOfSize:12];
        _lbl.text = title;
        [_lbl setBackgroundColor:[Common globalBackgroundColor]];
        [self.view addSubview:_lbl];
        
        //设置搜索栏
        CGRect searchBarFrame = CGRectMake(0, 4 + [Common globalStatusBarHeight] + TITLE_FIELD_HEIGHT, [Common globalWidth], SEARCH_BAR_HEIGHT);
        _searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
        _searchBar.searchBarStyle = UISearchBarIconSearch;
        _searchBar.barTintColor = [Common globalBackgroundColor];
        _searchBar.placeholder = @"Search";
        _searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
        _searchFlag = NO;
        _searchText = nil;
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        
        [[ImageData sharedImageData] subscribe:self];
        
        NSLog(@"end init");
    }
    
    return self;
}

- (void)viewDidLoad {
    NSLog(@"before super viewDidLoad");
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"imageHeights.count as_numberOfItemsInSection=%lu, thread=%@", (unsigned long)[[ImageData sharedImageData].imageHeights count], [NSThread currentThread]);
    
    NSInteger count = 0;
    //若当前是搜索状态，则从imageData中获取匹配的图片个数
    if( _searchFlag && _searchBar.text != nil )
    {
        count = [[ImageData sharedImageData] getImageCountMatchSearch: _searchBar.text];
        
        NSLog(@"after getImageCountMatchSearch, searchFlag is YES, count=%ld, searchBar.text=%@", count, _searchBar.text);
    }
    else
    {
        count = [[ImageData sharedImageData] getImageCount];
        
        NSLog(@"searchFlag is NO, count=%ld", count);
    }
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSLog(@"1 section");
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"
                                                                           forIndexPath:indexPath];
    
    BOOL bUseSearch = NO;
    if( _searchFlag && _searchBar.text != nil )
    {
        bUseSearch = YES;
    }
    
    NSUInteger imageIndex = [[ImageData sharedImageData] getImageIndex:indexPath.item UseSearch: bUseSearch];
    
    NSLog(@"cellForItemAtIndexPath, indexPath.item=%lu imageIndex=%lu bUseSearch=%d", indexPath.item, imageIndex, bUseSearch);
    
    UIImageView *imageView = [[ImageData sharedImageData] imageAtIndex: imageIndex CellSize: cell.bounds];
    
    [cell setBackgroundView:imageView];
    cell.backgroundColor = [Common globalBackgroundColor];
    return cell;
}


-(void) notifyDownloadFinished:(NSString*)filename Error:(NSError *)error
{
    NSLog(@"receive download finished notify, to reloadData, filename=%@ searchFlag=%d searchBar.text=%@", filename, _searchFlag, _searchBar.text);
    
    //若处于搜索状态，并且文件名不匹配，则不需要reload
    if( _searchFlag && _searchBar.text != nil && [filename hasPrefix: _searchBar.text] == NO )
    {
        NSLog(@"no need to reloadData");
        return;
    }
    
    NSLog(@"need to reloadData");
    [self.collectionView reloadData];
}

#pragma ScrollView deletegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint newOffset = CGPointMake(0, self.collectionView.contentOffset.y);
    scrollView.contentOffset = newOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    if (scrollView.contentOffset.y < -3)
    {
        //上拉刷新
        NSLog(@"need to refresh");
        [appDelegate startRefresh];
    }
    else if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 3 )
    {
        //下拉更新
        NSLog(@"need to continue_download");
        [appDelegate continueDownload];
    }
}

#pragma gesture recognizer
- (void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        NSLog(@"gestureRecognizer.state=%ld", gestureRecognizer.state);
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    _indexPathToDelete = [self.collectionView indexPathForItemAtPoint:p];
    
    NSLog(@"point.x=%f, point.y=%f, indexPath.section=%ld indexPath.item=%ld", p.x, p.y, _indexPathToDelete.section, _indexPathToDelete.item);
    
    if (_indexPathToDelete == nil)
    {
        NSLog(@"couldn't find index path");
        return;
    } else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle: nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"删除", nil),nil];
        [actionSheet showInView:self.view];
    }
}

#pragma actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"_indexPathToDelete.section=%ld indexPath.item=%ld _searchFlag=%d _searchBar.text=%@", _indexPathToDelete.section, _indexPathToDelete.item, _searchFlag, _searchBar.text);
    if( _indexPathToDelete == nil || buttonIndex != 0)
    {
        NSLog(@"_indexPathToDelete is nil or buttonIndex=%ld, no need to delete", buttonIndex);
        return;
    }
    
    //根据cell index获得image index，并更新layout中的数量
    NSUInteger imageIndex = 0;
    if( _searchFlag && _searchBar.text != nil )
    {
        //从_photoLayout的_mapIndexToImage中删除cell index对应的数据，并且返回该cell index对应的imageIndex
        imageIndex = [[ImageData sharedImageData] removeImageIndexAt:_indexPathToDelete.item];
        NSLog(@"after removeImageAtIndex, _searchFlag is YES, cell index=%ld, imageIndex=%lu", _indexPathToDelete.item, imageIndex);
    }
    else
    {
        imageIndex = _indexPathToDelete.item;
        NSLog(@"_searchFlag is NO, cell index=%ld, imageIndex=%lu", _indexPathToDelete.item, imageIndex);
    }
    
    //从数据源中删除原始图片数据
    [[ImageData sharedImageData] removeImageAtIndex: imageIndex];
    
    
    NSArray* indexArray = [NSArray arrayWithObject:_indexPathToDelete];
    [self.collectionView deleteItemsAtIndexPaths:indexArray];
    
    //删除完毕，清空_indexPathToDelete
    _indexPathToDelete = nil;
    NSLog(@"end _indexPathToDelete.section=%ld indexPath.item=%ld", _indexPathToDelete.section, _indexPathToDelete.item);
}

#pragma searchBar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _searchFlag = YES;
    _searchText = _searchBar.text;
    _photoFallLayout.useSearch = YES;
    //searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    
    //触发更新ui
    [self.collectionView reloadData];
    NSLog(@"search button clicked, end");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    _searchFlag = NO;
    _searchText = nil;
    _photoFallLayout.useSearch = NO;
    [searchBar resignFirstResponder];
}

@end
