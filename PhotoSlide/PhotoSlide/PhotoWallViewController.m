//
//  PhotoWallViewController.m
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "ImageData.h"
#import "PhotoWallViewController.h"

@interface PhotoWallViewController ()
@property (strong, nonatomic) ImageData* imageData;
@property (nonatomic) CGRect frame;
@end

@implementation PhotoWallViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithHeight: (CGFloat)photoViewHeight
{
    self = [super init];
    if (self)
    {
        NSLog(@"begin init table view");
        _imageData = [ImageData sharedImageData];
        
        _frame = CGRectMake(0,4 + [Common globalStatusBarHeight], [Common globalWidth], photoViewHeight - 4);
        self.tableView = [self.tableView initWithFrame:_frame];
        
        NSLog(@"tableView frame: x=4, y=%f, width=%f, height=%f",4 + [Common globalStatusBarHeight], [Common globalWidth], photoViewHeight - 4);
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"TABLE_VIEW_CELL_ID"];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [Common globalBackgroundColor];
        
        [_imageData subscribe:self];
        NSLog(@"end init table view");
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame = _frame;
}

- (CGRect)GetImageBounds: (CGRect)cellBound IndexInRow:(int)indexInRow
{
    CGFloat width = (cellBound.size.width - 5*4 ) / 4;
    CGFloat x = (indexInRow+1) * 4 + indexInRow * width;
    
    NSLog(@"indexInRow=%d: x=%f y=2 width=%f height=%f", indexInRow, x, width, cellBound.size.height -2);
    return CGRectMake(x, 2, width, cellBound.size.height - 2);
}


#pragma mark - dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView return 1");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 0;
    if ([_imageData.imageHeights count] > 0 )
    {
        rowNum = [_imageData.imageHeights count]/4 + 1;
    }
    else
    {
        rowNum = 0;
    }
    
    NSLog(@"numberOfRowsInSection, section=%ld num=%ld", (long)section, (long)rowNum);
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TABLE_VIEW_CELL_ID"];
    
    int row = (int)indexPath.row;
    CGFloat scaleWidth = ([Common globalWidth] - 5*4 ) / 4;
    CGFloat scaleHeight = [[ImageData sharedImageData] GetImageScaleHeight:scaleWidth];
    
    cell.frame = CGRectMake(0, (2 + scaleHeight ) * row, [Common globalWidth], scaleHeight );
    NSLog(@"current section=%d row=%d, cell.x=%f, cell.y=%f, cell.width=%f cell.height=%f", (int)indexPath.section, row,
          cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height);
    
    //一行要展示三张图片
    for( int i = 0; i < 4; i++ )
    {
        int imageIndex = row * 4 + i;
        
        NSLog(@"row=%d current_i=%d imageIndex=%d", row, i, imageIndex);
        
        CGRect imageBounds = [self GetImageBounds: cell.bounds IndexInRow: i ];
        
        UIImageView *imageView = [[ImageData sharedImageData] imageAtIndex: imageIndex CellSize: imageBounds];
        
        //由于当前这一行的图片不够四张，此时返回的imageView为nil，在addSubviewue前要做一次判断
        if( imageView != nil) [cell.contentView addSubview: imageView];
    }
    
    cell.backgroundColor = [Common globalBackgroundColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat scaleWidth = ([Common globalWidth] - 5*4 ) / 4;
    CGFloat scaleHeight = [[ImageData sharedImageData] GetImageScaleHeight:scaleWidth];
    
    NSLog(@"scaleWidth=%f scaleHeght=%f", scaleWidth, scaleHeight);
    
    return scaleHeight;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    if (scrollView.contentOffset.y < -3)
    {
        NSLog(@"need to refresh");
        [appDelegate startRefresh];
    }
    else if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 3 )
    {
        NSLog(@"need to continue_download");
        [appDelegate continueDownload];
    }
}

-(void) notifyDownloadFinished:(NSError *)error
{
    NSLog(@"in_tableview, receive download finished notify, to reloadData");
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
