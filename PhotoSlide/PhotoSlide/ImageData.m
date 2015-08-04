//
//  ImageData.m
//  
//
//  Created by samuel on 15/7/27.
//
//

#import "Common.h"
#import "ImageData.h"
#import <UIKit/UIKit.h>

@interface ImageData()
@property (nonatomic) CGFloat scaleHeight; //由于下载回来的图片尺寸一致，scaleHeight用于保存缩放后的图片高度
@property (strong, nonatomic) NSMutableDictionary* mapIndexToImage; //存储cell index对应的image index的映射关系
@property (nonatomic) NSInteger currentCellCount;
@end

@implementation ImageData

//单例方法
+ (instancetype) sharedImageData
{
    static ImageData *imageData;
    static dispatch_once_t once;
    
    dispatch_once( &once, ^{
        imageData = [[self alloc] init];
        imageData.scaleHeight = 0;
    });
    
    return imageData;
}

- (NSInteger) getImageCountMatchSearch: (NSString*) searchText
{
    static int step = 0;
    
    //第step次(若step为奇数，则直接返回个数)
    if( step % 2 != 0 )
    {
        NSLog(@"no need to make_mapIndexToImage, step=%d, count=%lu data=%@", step, [_mapIndexToImage count], _mapIndexToImage);
        step++;
        return [_mapIndexToImage count];
    }
    
    if( !_mapIndexToImage )
    {
        _mapIndexToImage = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [_mapIndexToImage removeAllObjects];
    }
 
    int cellIndex = 0;
    for ( NSUInteger i = 0; i < [_imageUrls count]; i++ )
    {
        if([_imageUrls[i] hasPrefix:searchText])
        {
            //key为字符串格式的数字(从0开始), value为图片在_imageUrl中的index(格式为NSNumber)
            [_mapIndexToImage setValue:[NSNumber numberWithUnsignedInteger:i] forKey:[[NSString alloc] initWithFormat:@"%d", cellIndex]];
            cellIndex++;
        }
    }
    
    NSLog(@"step=%d, count=%lu data=%@", step, [_mapIndexToImage count], _mapIndexToImage);
    step++;
    return [_mapIndexToImage count];
   
}

//根据图片缩放后的宽度，得出对应的缩放后的高度
- (CGFloat) GetImageScaleHeight: (CGFloat)scaleWidth
{
    //若之前计算过了，直接使用
    if( _scaleHeight > 0 ) return _scaleHeight;
    
    //若没有图片数据，则返回一个默认的值
    if( [_imageUrls count] == 0 )
    {
        return TABLE_VIEW_CELL_HEIGHT;
    }
    
    UIImage *image = [UIImage imageNamed: _imageUrls[0]];
    _scaleHeight = (image.size.height / image.size.width ) * scaleWidth;
    
    return _scaleHeight;
}

- (void) removeImageAtIndex: (NSInteger)index
{
    //若越界，若返回
    if(index >= [self.imageUrls count])
    {
        NSLog(@"current index exceed imageUrl array, index=%ld imageUrls.count=%lu", (long)index, (unsigned long)[self.imageUrls count]);
        return;
    }
    
    NSString* url = self.imageUrls[index];
    NSLog(@"removeImageAtIndex, index=%ld url=%@", index, url);
    
    [self.imageHeights removeObjectAtIndex: index];
    [self.imageUrls removeObjectAtIndex: index];
}
//从文件中获得单个UIImageView
- (UIImageView*) imageAtIndex: (NSInteger)index CellSize:(CGRect) bounds
{
    //若越界，返回nil，用于在一行不够指定数量图片时
    if(index >= [self.imageUrls count])
    {
        NSLog(@"current index exceed imageUrl array, index=%ld imageUrls.count=%lu", (long)index, (unsigned long)[self.imageUrls count]);
        return nil;
    }
    
    NSString* url = self.imageUrls[index];
    NSLog(@"imageAtIndex, index=%ld url=%@", index, url);
    
    UIImage *image = [UIImage imageNamed:url];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = image;
    imageView.layer.backgroundColor = [UIColor grayColor].CGColor;
    imageView.layer.borderWidth = 0.5;
    
    return imageView;
}

- (void) saveFileAndNotify: (NSString*) savePath UniqueId:(NSString*)unique
{
    //保存url到数组中
    if (self.imageUrls)
    {
        [self.imageUrls addObject:savePath];
    } else
    {
        self.imageUrls = [[NSMutableArray alloc] initWithObjects:savePath, nil];
    }
    
    //加载图片，获得尺寸
    UIImage *image = [UIImage imageNamed:savePath];
    if (!image) {
        NSLog(@"load image file failed, savePath=%@", savePath);
        return;
    }
    
    //按比例得到高度，并保存尺寸到数组中
    
    UIEdgeInsets inset = GLOBAL_INSET;
    int itermSpace = GLOBAL_ITEM_SPACE;
    int itermWidth = ([Common globalWidth] - inset.left - inset.right - 2 * itermSpace) / 3; // cell宽度
    NSNumber *zoomOutHeight = [NSNumber numberWithFloat:(image.size.height / image.size.width ) * itermWidth + arc4random_uniform(80)];
    if (self.imageHeights)
    {
        [self.imageHeights addObject:zoomOutHeight];
    } else
    {
        self.imageHeights = [[NSMutableArray alloc] initWithObjects:zoomOutHeight, nil];
    }
    
    //到主线程中更新ui
    NSError* error;
    for (id<DownloadNotify> observer in self.notifyDelegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<DownloadNotify>)observer notifyDownloadFinished:unique Error:error];
        });
    }
    
    NSLog(@"push data called: zoomOutHeight=%@ imageHeights.count=%d now %d images, notify %d views at thread %@",
          zoomOutHeight,
          (int)[self.imageHeights count],
          (int)[self.imageUrls count],
          (int)self.notifyDelegates.count,
          [NSThread currentThread]);
    
    return;
}

//接收订阅，收到图片时，通知订阅者
- (void)subscribe:(id)observer {
    if (self.notifyDelegates) {
        [self.notifyDelegates addObject:observer];
    } else {
        self.notifyDelegates = [[NSMutableArray alloc] initWithObjects:observer, nil];
    }
    NSLog(@"subscriber count=%d", (int)self.notifyDelegates.count);
}

- (NSInteger) getImageCount
{
    static int step_no_search = 0;
    
    //若为偶数，则要算一次，并保存
    if( step_no_search % 2 == 0 )
    {
        NSLog(@"current step_no_search is %d, need to calc _imageUrl count", step_no_search);
        _currentCellCount = [_imageUrls count];
        
        step_no_search++;
        return _currentCellCount;
    }
    else
    {
        NSLog(@"current step_no_search is %d, no need to calc _imageUrl count", step_no_search);
        
        step_no_search++;
        return _currentCellCount;
    }
}

#pragma imageIndex
-(NSInteger) getImageIndexCount
{
    return [_mapIndexToImage count];
}

-(void) setImageIndexMap:(NSArray *)imageIndexArray
{
    if( !_mapIndexToImage )
    {
        _mapIndexToImage = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [_mapIndexToImage removeAllObjects];
    }
    
    //建立cell index到imageIndex的映射关系
    int i = 0;
    for( NSNumber* indexNum in imageIndexArray)
    {
        NSLog(@"i=%d imageIndex=%@", i, indexNum);
        [_mapIndexToImage setValue:indexNum  forKey:[[NSString alloc] initWithFormat:@"%d", i]];
        i++;
    }
    
    NSLog(@"_mapInexToImage.count=%ld, data=%@", [_mapIndexToImage count], _mapIndexToImage);
}

//根据cell index获得对应的image index
-(NSUInteger) getImageIndex:(NSUInteger) i UseSearch:(BOOL)useSearch
{
    if( useSearch )
    {
        NSNumber* indexNum = [_mapIndexToImage valueForKey:[[NSString alloc] initWithFormat:@"%lu", i]];
        NSLog(@"useSearch, getImageIndex cellindex=%lu imageIndex=%@", i, indexNum);
        
        return [indexNum unsignedIntegerValue];
    }
    
    return i;
}

//删除cell index对应的image index信息，并返回image index
-(NSUInteger) removeImageIndexAt:(NSUInteger) i
{
    NSString* key = [[NSString alloc] initWithFormat:@"%lu", i];
    NSNumber* indexNum = [_mapIndexToImage valueForKey:key];
    
    NSLog(@"key=%@ indexNum=%@", key, indexNum);
    
    [_mapIndexToImage removeObjectForKey:key];
    
    return [indexNum unsignedIntegerValue];
}

@end
