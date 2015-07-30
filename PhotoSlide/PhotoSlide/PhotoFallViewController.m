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
#import "Common.h"

@interface PhotoFallViewController ()

@property (strong, nonatomic) id<UICollectionViewDataSource> dataSource;
@property (strong, nonatomic) id<UICollectionViewDelegate> delegate;
@property (strong, nonatomic) PhotoFallLayout* fallLayout;
@property (strong, nonatomic) ImageData* imageData;

@end

@implementation PhotoFallViewController
@synthesize viewHeight;
@synthesize dataSource;
@synthesize delegate;
@synthesize imageData;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.imageData = [ImageData sharedImageData];
        
        CGRect frame = CGRectMake(4,6 + [Common globalStatusBarHeight], [Common globalWidth]-8, self.viewHeight - 6);
        
        NSLog(@"before collectionView initWithFrame");
        //初始化layout
        PhotoFallLayout *photoFallLayout = [[PhotoFallLayout alloc] init];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:photoFallLayout];
        
        //初始化cell
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"];
        
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [Common globalBackgroundColor];
        
        [self.imageData subscribe:self];
        
        NSLog(@"end init");
        //[self.view addSubview:self.fallView];
    }
    
    return self;
}

- (void)viewDidLoad {
    NSLog(@"before super viewDidLoad");
    [super viewDidLoad];
    
//    self.imageData = [ImageData sharedImageData];
//    
//    CGRect frame = CGRectMake(4,4, [Common globalWidth], self.viewHeight);
//    
//    NSLog(@"before collectionView initWithFrame");
//    //初始化layout
//    PhotoFallLayout *photoFallLayout = [[PhotoFallLayout alloc] init];
//    
//    if (photoFallLayout) {
//        NSLog(@"layout is nil");
//    }
//    self.fallView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:photoFallLayout];
//    NSLog(@"after collectionView initWithFrame");
//    
//    //初始化cell
//    [self.fallView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PHOTO_FALL_CELL_IDENTIFIER"];
//    
//    self.fallView.dataSource = self;
//    self.fallView.delegate = self;
//    
//    [self.view addSubview:self.fallView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"number of items in section=%lu", (unsigned long)[self.imageData.imageHeights count]);
    return [self.imageData.imageHeights count];
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

-(void) notifyDownloadFinished:(NSError *)error
{
    NSLog(@"receive download finished notify, to reloadData");
    [self.collectionView reloadData];
}


@end
