//
//  QhUploadPicToServe.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import "QhUploadPicToServe.h"
#import "QhImageLoaderOperation/QhUploadOperation.h"

@interface QhUploadPicToServe()

@property (strong, nonatomic, nonnull) NSOperationQueue  *uploadQueue;
@property (strong, nonatomic, nonnull) NSMutableArray    *imageUrlList;//服务返回的图片url数组

@end

@implementation QhUploadPicToServe

- (instancetype)init {
    self = [super init];
   
    if (self) {
        self.maxConcurrentUploadCount = 5;
        self.backgroundUploadSupport = YES;
        self.imageUrlList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

/**
 * @brief 上传图片到服务端
 */
- (void)uploadImageWithServeIp:(NSString *)serveIp andServeFileParameter:(NSString *)serveFileParameter andImagePathList:(NSArray *)imagePathList withCompletionHandler:(QhLoadCompletionHandler)completionHandler {
    __weak QhUploadPicToServe *wself = self;

    self.uploadQueue = [[NSOperationQueue alloc] init];
    self.uploadQueue.maxConcurrentOperationCount = self.maxConcurrentUploadCount;
    
    NSBlockOperation *finalTask = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"所有图片上传成功");
        __strong __typeof (wself) sself = wself;
        [sself allImageUploadComplate:completionHandler];
    }];

    for (NSInteger i = 0; i < imagePathList.count; i++) {
        QhUploadOperation *task = [[QhUploadOperation alloc] initWithServeIp:serveIp andServeFileParameter:serveFileParameter andImageUrlStr:imagePathList[i] backgroundSupport:self.backgroundUploadSupport withCompletionHandler:^(BOOL success,NSString * _Nullable imageUrl, NSError * _Nullable error) {
            __strong __typeof (wself) sself = wself;

            if (success && imageUrl) {
                [sself.imageUrlList addObject:imageUrl];
            } else {
                [sself.imageUrlList addObject:error.localizedDescription];
            }
        }];
        [self.uploadQueue addOperation:task];
        [finalTask addDependency:task];
    }
    [self.uploadQueue addOperation:finalTask];
}

- (void)allImageUploadComplate:(QhLoadCompletionHandler)completionHandler{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (completionHandler) {
            completionHandler(YES,self.imageUrlList);
        }
    });
}
/**
 * 取消所有上传任务
 */
- (void)cancelAllUpload {
   
    if (self.uploadQueue) {
        [self.uploadQueue cancelAllOperations];
    }
}

@end
