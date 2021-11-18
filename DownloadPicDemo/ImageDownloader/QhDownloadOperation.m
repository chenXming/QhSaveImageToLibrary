//
//  DownloadOperation.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import "QhDownloadOperation.h"

@interface QhDownloadOperation()

@property (assign, nonatomic, getter=isExecuting) BOOL executing;
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (copy, nonatomic) NSString *imageUrlStr;
@property (copy, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic, nullable) NSURLSession *session;

@property (copy, nonatomic) DownloadCompletionHandler completionHandler;
@property (assign, nonatomic) BOOL backgroundSupport;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation QhDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithImageUrlStr:(NSString *)imageUrlStr backgroundSupport:(BOOL)background withCompletionHandler:(DownloadCompletionHandler)completionHandler{

    if(self = [super init]){
        _backgroundSupport = background;
        _imageUrlStr = imageUrlStr;
        if(completionHandler){
            _completionHandler = completionHandler;
        }
    }
    return  self;
}

- (void)start{
    
    if (self.isCancelled){
        self.executing = NO;
        self.finished = YES;
        self.downloadTask = nil;
        return;
    }
    
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication && self.backgroundSupport) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;

            if (sself) {
                [sself cancel];
                [app endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
    }
    __weak typeof(self) weakSelf = self;

    NSURL *url = [NSURL URLWithString:self.imageUrlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    if(!self.session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15;
        configuration.allowsCellularAccess = YES;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        self.session = session;
    }
    
    self.downloadTask = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil){
            NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
            NSString *filePath = [cache stringByAppendingPathComponent:response.suggestedFilename];
            NSLog(@"filePath = %@",filePath);
            NSURL *toURL = [NSURL fileURLWithPath:filePath];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
            weakSelf.completionHandler(YES, filePath, nil);
        } else {
            weakSelf.completionHandler(NO, nil, error);
        }
        [weakSelf done];
    }];
    self.executing = YES;

    if(self.downloadTask) {
        [self.downloadTask resume];
    } else {
        self.completionHandler(NO, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]);
        [self done];
        return;
    }
}

- (void)setExecuting:(BOOL )executing{

    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting{
    
    return _executing;
}

- (void)done {
    
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
    
    self.finished = YES;
    self.executing = NO;
}

- (void)cancel {
    
    @synchronized (self) {
        [self cancelDownLoad];
    }
}

- (void)cancelDownLoad {
        
    if (self.isFinished) return;
    [super cancel];

    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
        [self done];
    }
    
    if (self.session) {
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}

- (void)setFinished:(BOOL )finished{
   
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished{
    
    return _finished;
}

- (BOOL)isConcurrent {
    
    return YES;
}

- (void)dealloc{
    
    NSLog(@"imageUrlStr:释放了:%@",self.imageUrlStr);
}
@end
