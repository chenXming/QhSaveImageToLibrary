//
//  QhUploadPicToServe.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import "QhUploadPicToServe.h"
#import "ImageDownloader/QhUploadOperation.h"

@interface QhUploadPicToServe()

@property (strong, nonatomic, nonnull) NSMutableArray    *imagePathList;
@property (strong, nonatomic, nonnull) NSOperationQueue  *uploadQueue;

@end

@implementation QhUploadPicToServe

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxConcurrentUploadCount = 5;
        self.backgroundUploadSupport = YES;
        self.imagePathList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

/**
 * @brief 上传图片到服务端
 */
- (void)uploadImageWithServeIp:(NSString *)serveIp andServeFileParameter:(NSString *)serveFileParameter andImagePathList:(NSArray *)imagePathList withCompletionHandler:(LoadCompletionHandler)completionHandler {
    
    __weak QhUploadPicToServe *wself = self;

    self.uploadQueue = [[NSOperationQueue alloc] init];
    self.uploadQueue.maxConcurrentOperationCount = self.maxConcurrentUploadCount;
    
    NSBlockOperation *finalTask = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"所有图片上传成功");
        __strong __typeof (wself) sself = wself;
        [sself allImageUploadComplate:completionHandler];
    }];

    for (NSInteger i = 0; i < imagePathList.count; i++) {
        QhUploadOperation *task = [[QhUploadOperation alloc] initWithServeIp:serveIp andServeFileParameter:serveFileParameter andImageUrlStr:imagePathList[i] backgroundSupport:self.backgroundUploadSupport withCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if(success){
                NSLog(@"上传成功");
            }
        }];
        [self.uploadQueue addOperation:task];
        [finalTask addDependency:task];
    }
    
    [self.uploadQueue addOperation:finalTask];
}

- (void)allImageUploadComplate:(LoadCompletionHandler)completionHandler{
    
    if(completionHandler){
        completionHandler(YES);
    }
}
/**
 * 取消所有上传任务
 */
- (void)cancelAllUpload {
   
    if(self.uploadQueue){
        [self.uploadQueue cancelAllOperations];
    }
}

@end
