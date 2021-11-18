//
//  QhUploadOperation.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import "QhUploadOperation.h"

//分隔符
#define Boundary @"QhUploadImage"
//换行
#define Enter [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]
//NSString转NSData
#define Encode(string) [string dataUsingEncoding:NSUTF8StringEncoding]

@interface QhUploadOperation()

@property (assign, nonatomic, getter=isExecuting) BOOL executing;
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (copy, nonatomic) NSString *serveIp;
@property (copy, nonatomic) NSString *imageLocalUrl;
@property (copy, nonatomic) NSString *serveFileParameter;
@property (copy, nonatomic) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic, nullable) NSURLSession *session;

@property (copy, nonatomic) UploadCompletionHandler completionHandler;
@property (assign, nonatomic) BOOL backgroundSupport;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation QhUploadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithServeIp:(NSString *)serveIp andServeFileParameter:(NSString *)serveFileParameter andImageUrlStr:(NSString *)imageLocalUrl backgroundSupport:(BOOL)background withCompletionHandler:(UploadCompletionHandler)completionHandler {

    if(self = [super init]){
        _serveIp = serveIp;
        _backgroundSupport = background;
        _imageLocalUrl = imageLocalUrl;
        _serveFileParameter = serveFileParameter;
        if(completionHandler){
            _completionHandler = completionHandler;
        }
    }
    return  self;
}

- (void)start{
    
    NSLog(@"开始执行任务%@ thread===%@",self.imageLocalUrl,[NSThread currentThread]);
    NSLog(@"self.isCancelled====%d",self.isCancelled);

    if (self.isCancelled){
        self.executing = NO;
        self.finished = YES;
        self.uploadTask = nil;
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

    NSURL *url = [NSURL URLWithString:_serveIp];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *head = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",Boundary];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    if(!self.session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15;
        configuration.allowsCellularAccess = YES;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        self.session = session;
    }
    
    NSData *uploadData = [self getUploadDataWithParameter:_serveFileParameter];
    self.uploadTask = [self.session uploadTaskWithRequest:request fromData:uploadData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"jsonDict==%@",jsonDict);
            if(weakSelf.completionHandler){
                weakSelf.completionHandler(YES, nil);
            }
        } else {
            weakSelf.completionHandler(NO, error);
        }
        [weakSelf done];
    }];
    
    self.executing = YES;
    
    if(self.uploadTask) {
        [self.uploadTask resume];
    } else {
        self.completionHandler(NO, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]);
        [self done];
        return;
    }
}

- (NSData*)getUploadDataWithParameter:(NSString *)serveFileParameter{
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:Encode(@"--")];
    [data appendData:Encode(Boundary)];
    [data appendData:Enter];
    NSString *imageName = [NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"test001.png\"",serveFileParameter];
    [data appendData:Encode(imageName)];
    [data appendData:Enter];
    [data appendData:Encode(@"Content-Type:image/png")];
    [data appendData:Enter];
    [data appendData:Enter];
    //图片数据  并且转换为Data
    UIImage *image = [UIImage imageWithContentsOfFile:self.imageLocalUrl];
    NSData *imagedata = UIImagePNGRepresentation(image);
    [data appendData:imagedata];
    [data appendData:Enter];
    //3、结束标记
    [data appendData:Encode(@"--")];
    [data appendData:Encode(Boundary)];
    [data appendData:Encode(@"--")];
    [data appendData:Enter];
    
    return data;
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
    NSLog(@"---------------------->");
    
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
        [self cancelUpLoad];
    }
}

- (void)cancelUpLoad {
        
    if (self.isFinished) return;
    [super cancel];

    if (self.uploadTask) {
        [self.uploadTask cancel];
        self.uploadTask = nil;
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
    
    NSLog(@"imageUrlStr:释放了:%@",self.imageLocalUrl);
}

@end
