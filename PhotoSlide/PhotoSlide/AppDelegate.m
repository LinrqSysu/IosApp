//
//  AppDelegate.m
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "AppDelegate.h"
#import "Common.h"
#import "ImageData.h"
#import "FlickrFetcher.h"
#import "UITabBarController+MyTabBarController.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSMutableArray *photoList;
@property (atomic) int activeNetCount;
@end

@implementation AppDelegate

- (void)createImageArchive
{
    NSLog(@"begin createImageArchive");
    NSArray *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imagePath = [[cachePath objectAtIndex:0] stringByAppendingString:@"/Image"];
    NSError *mkdirError;
    [[NSFileManager defaultManager] createDirectoryAtPath:imagePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&mkdirError];
    if (mkdirError) {
        NSLog(@"%@", mkdirError.description);
        return;
    }
    
    self.imageDirectory = imagePath;
    NSLog(@"end createImageArchive");
}

- (void) beginBackgroundDownload
{
    //先开启后台下载
    NSLog(@"begin startFlickrFetch");
    _activeNetCount = 0;
    // getTasksWithCompletionHandler: is ASYNCHRONOUS
    // but that's okay because we're not expecting startFlickrFetch to do anything synchronously anyway
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // let's see if we're already working on a fetch ...
        if (![downloadTasks count]) {
            // ... not working on a fetch, let's start one up
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH_LIST;
            
            _activeNetCount++;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            [task resume];
            
            NSLog(@"begin downloadtask with image list");
        } else {
            // ... we are working on a fetch (let's make sure it (they) is (are) running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
    
    //下载成功后保存到sharedImageData中(保存url，保存文件，生成缩略图的高度)
    return;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self createImageArchive];
   
    //根据可视面积初始化 TabBarController
    CGFloat photoViewHeight = [Common globalHeight] - self.rootController.tabBar.frame.size.height - [Common globalStatusBarHeight];
    self.rootController = [[UITabBarController alloc] initWithHeight:photoViewHeight];
    
    //将TabBarController增加为rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.rootController;
    self.window.backgroundColor = [Common globalBackgroundColor];
    [self.window makeKeyAndVisible];
    
    //开启后台下载
    [self beginBackgroundDownload];
    return YES;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

#pragma mark - NSURLSessionDownloadDelegate
- (NSString*) GetUnique:(NSString*)discription
{
    NSArray* array = [discription componentsSeparatedByString: FLICKR_FETCH_IMAGE];
    
    return array[0];
}

- (void)DownLoadBetweenIndex
{
    //下载从_currentIndex到_endIndex之间的图片，注：不包含下标为_endIndex的图片
    for ( ; _currentIndex < _endIndex; _currentIndex++ )
    {
        NSDictionary *photoDictionary = _photoList[_currentIndex];
        
        NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
        NSString *imageUrl = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        //判断文件是否已经存在了，若已存在了，直接通知
        NSString *savePath = [NSString stringWithFormat:@"%@/%@", self.imageDirectory, unique];
        if( [[NSFileManager defaultManager] fileExistsAtPath:savePath] )
        {
            NSLog(@"current image file existed, unique = %@ savePath=%@", unique, savePath);
            [[ImageData sharedImageData] saveFile:savePath];
            continue;
        }
        
        NSLog(@"before download single image: unique = %@, imageUrl=%@", unique, imageUrl);
        
        NSURL* url = [NSURL URLWithString:imageUrl];
        NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:url];
        task.taskDescription = [unique stringByAppendingString: FLICKR_FETCH_IMAGE];
        
        _activeNetCount++;
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [task resume];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_LIST])
    {
        _activeNetCount--;
        
        [_photoList removeAllObjects];
        _photoList = [[self flickrPhotosAtURL:localFile] mutableCopy];
        
        NSLog(@"image list download back, first time download image");
        
        //先下载30张
        _currentIndex = 0;
        _endIndex = 30;
        [self DownLoadBetweenIndex];
    }
    
    else if([downloadTask.taskDescription hasSuffix:FLICKR_FETCH_IMAGE])
    {
        //获得unique，然后做为文件名，并将数据保存到文件中
        NSString* unique = [self GetUnique: downloadTask.taskDescription];
        
        NSString *savePath = [NSString stringWithFormat:@"%@/%@", self.imageDirectory, unique];
        
        //NSLog(@"unique=%@, savePath=%@", unique, savePath);
        _activeNetCount--;
        
        NSError *mvError = nil;
        [[NSFileManager defaultManager] moveItemAtPath:[localFile path] toPath:savePath error:&mvError];
        if (mvError) {
            NSLog(@"%@", mvError.description);
        }
        else
        {
            [[ImageData sharedImageData] saveFile:savePath];
        }
    }
    
    if( _activeNetCount > 0 )
    {
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else
    {
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (NSURLSession *)flickrDownloadSession // the NSURLSession we will use to fetch Flickr data in the background
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken; // dispatch_once ensures that the block will only ever get executed once per application launch
        dispatch_once(&onceToken, ^{
            // notice the configuration here is "backgroundSessionConfiguration:"
            // that means that we will (eventually) get the results even if we are not the foreground application
            // even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH_ID];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self    // we MUST have a delegate for background configurations
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
        });
    }
    return _flickrDownloadSession;
}

-(void) continueDownload
{
    _endIndex += 30;
    if( _endIndex > [_photoList count])
    {
        _endIndex = [_photoList count];
    }
    NSLog(@"continueDownload, current _endIndex=%lul _photoList.count=%lul", (unsigned long)_endIndex, (unsigned long)[_photoList count]);
    
    [self DownLoadBetweenIndex];
}

-(void) startRefresh
{
    [self beginBackgroundDownload];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
