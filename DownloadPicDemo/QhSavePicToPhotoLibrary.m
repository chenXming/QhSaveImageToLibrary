//
//  QhSavePicToPhotoLibrary.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/25.
//

#import "QhSavePicToPhotoLibrary.h"
#import "ImageDownloader/QhDownloadOperation.h"
#import <Photos/Photos.h>


@interface QhSavePicToPhotoLibrary ()
//自定义相册
@property (strong, nonatomic, nonnull) PHAssetCollection *createCollection;
@property (strong, nonatomic, nonnull) NSMutableArray    *imagePathList;
@property (strong, nonatomic, nonnull) NSOperationQueue  *downloadQueue;

@end

@implementation QhSavePicToPhotoLibrary

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxConcurrentDownloadCount = 5;
        self.deleteDownloadImageCache = YES;
        self.backgroundDownloadSupport = YES;
        self.imagePathList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

/**
 * @brief 保存图片到相册
 * @param imageList 图片数组
 * @param libryName 相册名称，默认为应用名
 * @param completionHandler 保存后回调
 */
- (void)saveImageToPhotoLibraryWithImageList:(NSArray <UIImage *> *)imageList andLibraryName:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler {

    return [self saveImageToPhotoWithRequestAuthorizationWithImageList:imageList andLibraryNmae:libryName callBack:(SaveCompletionHandler)completionHandler];
}

/**
 * @brief 保存网络图片到相册
 * @param imageUrlList 图片url数组
 * @param libryName 相册名称，默认为应用名
 * @param completionHandler 保存后回调
 */
- (void)saveOnLineImageToPhotoLibraryWithImageList:(NSArray <NSURL *> *)imageUrlList andLibraryName:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler {
    
    __weak QhSavePicToPhotoLibrary *wself = self;

    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.maxConcurrentOperationCount = self.maxConcurrentDownloadCount;
    
    NSBlockOperation *finalTask = [NSBlockOperation blockOperationWithBlock:^{

        [self backgroundSaveImageAndDeleteOldFilesWithLibraryName:libryName callBack:completionHandler];
    }];

    for (NSInteger i = 0; i < imageUrlList.count; i++) {
        QhDownloadOperation *task = [[QhDownloadOperation alloc] initWithImageUrlStr:[NSString stringWithFormat:@"%@",imageUrlList[i]] backgroundSupport:self.backgroundDownloadSupport withCompletionHandler:^(BOOL success, NSString * _Nullable filePath, NSError * _Nullable error) {
            __strong __typeof (wself) sself = wself;
            
            if(success && filePath != nil){
                [sself.imagePathList addObject:filePath];
            }
        }];
        [self.downloadQueue addOperation:task];
        [finalTask addDependency:task];
        NSLog(@"task=====%@",task);
    }
    [self.downloadQueue addOperation:finalTask];
}

/**
 * 后台保存任务
 */
- (void)backgroundSaveImageAndDeleteOldFilesWithLibraryName:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler {
    
    __weak QhSavePicToPhotoLibrary *wself = self;

    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    NSMutableArray *cacheImageList = [NSMutableArray array];
    [self.imagePathList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = (NSString*)obj;
        [cacheImageList addObject:[UIImage imageWithContentsOfFile:filePath]];
    }];
    
    [self saveImageToPhotoLibraryWithImageList:cacheImageList andLibraryName:libryName callBack:^(BOOL success) {
        NSLog(@"存储成功");
        [cacheImageList removeAllObjects];
        [wself saveSuccessImageWithCompletionHandler:completionHandler];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)saveImageToPhotoWithRequestAuthorizationWithImageList:(NSArray <UIImage *> *)imageList andLibraryNmae:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler{
        
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
          
            switch (status) {
              case PHAuthorizationStatusLimited:
                   NSLog(@"受限的访问权限创建自定义相册会失败");
                   [self saveImageListToLibrary:[imageList mutableCopy] andLibraryNmae:libryName andSaveCallBack:completionHandler];
                   break;
              case PHAuthorizationStatusDenied:
                   NSLog(@"访问相册权限受限");
                   break;
              case PHAuthorizationStatusAuthorized:
                   [self saveImageListToLibrary:[imageList mutableCopy] andLibraryNmae:libryName andSaveCallBack:completionHandler];
                   break;
              default:
                  break;
          }
        }];
    } else {
        PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
        if (authorStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    [self saveImageListToLibrary:[imageList mutableCopy] andLibraryNmae:libryName andSaveCallBack:completionHandler];
                } else {
                    NSLog(@"访问相册权限受限");
                }
            }];
        } else if (authorStatus == PHAuthorizationStatusAuthorized) {
            [self saveImageListToLibrary:[imageList mutableCopy] andLibraryNmae:libryName andSaveCallBack:completionHandler];
        } else {
            NSLog(@"访问相册权限受限");
        }
    }
}

- (void)saveImageListToLibrary:(NSMutableArray <UIImage *> *)imageList andLibraryNmae:(NSString *)libryName andSaveCallBack:(SaveCompletionHandler)completionHandler{
    
    if([imageList count] == 0){
        
        if (completionHandler) {
            completionHandler(YES);
        }
        return;
    }
    
    if (libryName != nil && ![libryName isEqualToString:@""]) {
        self.createCollection = [self createPHAssetLibraryWithName:libryName];
    }

    UIImage* imagePhoto = [imageList firstObject];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

        PHAssetCollectionChangeRequest *assetCollectionChangeRequest;
        
        if (self.createCollection) {
            assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.createCollection];
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:imagePhoto];
            PHObjectPlaceholder *placeholder = [assetChangeRequest placeholderForCreatedAsset];
            [assetCollectionChangeRequest addAssets:@[placeholder]];
        } else {
            [PHAssetChangeRequest creationRequestForAssetFromImage:imagePhoto];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"保存成功");
            [imageList removeObjectAtIndex:0];
        }
        
        [self saveImageListToLibrary:imageList andLibraryNmae:libryName andSaveCallBack:completionHandler];
    }];
}

/**
 * 保存成功后的回调
 */
- (void)saveSuccessImageWithCompletionHandler:(SaveCompletionHandler)completionHandler {
    
    if (self.deleteDownloadImageCache) { //删除下载缓存数据
        [self delateOldFiles];
    }
        
    if(completionHandler){
        completionHandler(YES);
    }
}

/**
 * 创建用户自定义相册
*/
- (PHAssetCollection *)createPHAssetLibraryWithName:(NSString *)libraryName{

    NSString *albumName = @"";
    if(libraryName == nil || [libraryName isEqualToString:@""]){
        albumName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    }else{
        albumName = libraryName;
    }

    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHAssetCollection *appCollection = nil;
   
    for (PHAssetCollection *collection in collections) {
        
        if ([collection.localizedTitle isEqualToString:albumName]) {
            return collection;
        }
    }
    
    if (appCollection == nil) {
        NSError *error = nil;
        __block NSString *createCollectionID = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            
            createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error];
        
        if (error) {
            return nil;
        } else {
            appCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
        }
    }

    return appCollection;
}

/**
 * 取消所有下载任务
 */
- (void)cancelAllDownloads {
    
    if(self.downloadQueue){
        [self.downloadQueue cancelAllOperations];
    }
    
    [self delateOldFiles];
}

- (void)delateOldFiles {
    
    if(self.imagePathList.count > 0){
        [self.imagePathList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[NSFileManager defaultManager] removeItemAtPath:(NSString *)obj error:nil];
        }];
        [self.imagePathList removeAllObjects];
    }
}

- (void)dealloc {
 
    [self.downloadQueue cancelAllOperations];
}
@end
