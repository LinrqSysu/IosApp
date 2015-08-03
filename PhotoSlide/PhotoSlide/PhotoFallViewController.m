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
@property (strong, nonatomic) ImageData* imageData;
@property (strong, nonatomic) UILabel* lbl;

@end

@implementation PhotoFallViewController
@synthesize dataSource;
@synthesize delegate;
@synthesize imageData;

- (instancetype)initWithHeight: (CGFloat)viewHeight Title:(NSString*) title
{
    self = [super init];
    
    if (self) {
        
        self.imageData = [ImageData sharedImageData];
        
        CGRect frame = CGRectMake(4,4 + [Common globalStatusBarHeight] + 30, [Common globalWidth]-10, viewHeight - 34);
        
        //初始化layout
        _photoFallLayout = [[PhotoFallLayout alloc] init];
        
        //初始化view
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_photoFallLayout];
        
        //初始化cell
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"];
        
        //[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [Common globalBackgroundColor];
        
        //仅用于遮挡上方透明的状态栏呵呵
        UILabel *coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [Common globalWidth], 4 + [Common globalStatusBarHeight])];
        [coverLabel setBackgroundColor:[Common globalBackgroundColor]];
        [self.view addSubview:coverLabel];
        
        //设置标题栏
        _lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 4 + [Common globalStatusBarHeight], [Common globalWidth], 30)];
        _lbl.textAlignment = NSTextAlignmentCenter;
        _lbl.font = [UIFont systemFontOfSize:12];
        _lbl.text = title;
        [_lbl setBackgroundColor:[Common globalBackgroundColor]];
        [self.view addSubview:_lbl];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        
        [self.imageData subscribe:self];
        
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
    NSLog(@"imageHeights.count as numberOfItemsInSection=%lu, thread=%@", (unsigned long)[self.imageData.imageHeights count], [NSThread currentThread]);
    
    NSInteger count = [self.imageData.imageHeights count];
    [_photoFallLayout setCurrentCellCount: count];
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"1 section");
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"begin get cell for index path, indexPath.item=%lu", indexPath.item);
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"
                                                                           forIndexPath:indexPath];
    UIImageView *imageView = [[ImageData sharedImageData] imageAtIndex: indexPath.item CellSize: cell.bounds];
    
    [cell setBackgroundView:imageView];
    cell.backgroundColor = [Common globalBackgroundColor];
    NSLog(@"end get cell for index path, indexPath.item=%lu", indexPath.item);
    return cell;
}

/*
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    NSLog(@"viewForSupplementary, kind=%@ indexPath.section=%ld", kind, indexPath.section);
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        NSLog(@"kind is header, viewForSupplementary, kind=%@", kind);
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.bounds.size.width, headerView.bounds.size.height)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.text = self.title;
        [lbl setBackgroundColor:[Common globalBackgroundColor]];
        
        [headerView addSubview:lbl];
        
        reusableview = headerView;
    }
    
    reusableview.backgroundColor = [Common globalBackgroundColor];
    
    return reusableview;
}
*/


-(void) notifyDownloadFinished:(NSError *)error
{
    NSLog(@"receive download finished notify, to reloadData");
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 1, 1, 0);
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

@end
