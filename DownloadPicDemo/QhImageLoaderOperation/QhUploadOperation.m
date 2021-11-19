//
//  QhUploadOperation.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import "QhUploadOperation.h"
#import "UIImage+ImageContent.h"

//分隔符
#define Boundary @"QhUploadImage"
//换行
#define Enter [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]
//NSString转NSData
#define Encode(string) [string dataUsingEncoding:NSUTF8StringEncoding]

@interface QhUploadOperation()

@property (assign, nonatomic, getter=isExecuting) BOOL executing;
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (copy, nonatomic, nullable) NSString *serveIp;
@property (copy, nonatomic, nullable) NSString *imageLocalUrl;
@property (copy, nonatomic, nullable) NSString *serveFileParameter;
@property (copy, nonatomic, nullable) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic, nullable) NSURLSession *session;

@property (copy, nonatomic, nullable) UploadCompletionHandler completionHandler;
@property (assign, nonatomic) BOOL backgroundSupport;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation QhUploadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithServeIp:(NSString *)serveIp andServeFileParameter:(NSString *)serveFileParameter andImageUrlStr:(NSString *)imageLocalUrl backgroundSupport:(BOOL)background withCompletionHandler:(UploadCompletionHandler)completionHandler {

    if(self = [super init]){
        _serveIp = serveIp;
        _imageLocalUrl = imageLocalUrl;
        _backgroundSupport = background;
        _serveFileParameter = serveFileParameter;
        
        if(completionHandler){
            _completionHandler = completionHandler;
        }
    }
    return  self;
}

- (void)start{

    if (self.isCancelled) {
        self.executing = NO;
        self.finished = YES;
        self.uploadTask = nil;
        return;
    }

    __weak __typeof__ (self) wself = self;

    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
   
    if (hasApplication && self.backgroundSupport) {
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
        
        __strong __typeof (wself) sself = wself;
        // 解析服务器返回的数据
        if(error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"jsonDict==%@",jsonDict);
            NSString *imageUrl = @"";
            if([jsonDict[data] isKindOfClass:[NSDictionary class]]){
                NSDictionary *dataDict = jsonDict[data];
                imageUrl = dataDict[@"url"];
            } else {
                imageUrl = jsonDict[@"images"];
            }
            
            if(sself.completionHandler){
                sself.completionHandler(YES,imageUrl,nil);
            }
        } else {
            if(sself.completionHandler){
                sself.completionHandler(NO,nil,error);
            }
        }
        
        [sself done];
    }];
    
    self.executing = YES;
    
    if(self.uploadTask) {
        [self.uploadTask resume];
    } else {
        self.completionHandler(NO,nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]);
        [self done];
        return;
    }
}

/**
 * 拼接上传数据
 */
- (NSData *)getUploadDataWithParameter:(NSString *)serveFileParameter{
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:Encode(@"--")];
    [data appendData:Encode(Boundary)];
    [data appendData:Enter];
    NSString *imageContent = [NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"",serveFileParameter,[self getImageFileName]];
    [data appendData:Encode(imageContent)];
    [data appendData:Enter];
    [data appendData:Encode(@"Content-Type:image/png")];
    [data appendData:Enter];
    [data appendData:Enter];
    UIImage * image = [UIImage imageWithContentsOfFile:self.imageLocalUrl];
    NSData *imageData = [UIImage getDataWithImage:image];
    [data appendData:imageData];
    [data appendData:Enter];
    [data appendData:Encode(@"--")];
    [data appendData:Encode(Boundary)];
    [data appendData:Encode(@"--")];
    [data appendData:Enter];
    
    return data;
}

- (NSString *)getImageFileName{
    
    NSString *fileName = @"qhImage.png";
    if(self.imageLocalUrl == nil) return fileName;
    
    NSArray *fileNameArr = [self.imageLocalUrl componentsSeparatedByString:@"/"];
    if(fileNameArr.count > 0){
        fileName = [fileNameArr lastObject];
    }
    return  fileName;
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
