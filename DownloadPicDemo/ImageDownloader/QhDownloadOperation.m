//
//  DownloadOperation.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import "QhDownloadOperation.h"

@interface QhDownloadOperation()

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) NSString *imageUrlStr;
@property (nonatomic, copy) DownloadCompletionHandler completionHandler;

@end

@implementation QhDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithImageUrlStr:(NSString *)imageUrlStr withCompletionHandler:(DownloadCompletionHandler)completionHandler {

    if(self = [super init]){
        
        self.imageUrlStr = imageUrlStr;
        if(completionHandler){
            self.completionHandler = completionHandler;
        }
    }
    
    return  self;
}

- (void)start{
    
    self.executing = YES;
    NSLog(@"开始执行任务%@ thread===%@",self.imageUrlStr,[NSThread currentThread]);
   
    if (self.isCancelled){
        self.executing = NO;
        self.finished = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;

    NSURL *url = [NSURL URLWithString:self.imageUrlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil){
            //默认把数据写到磁盘中：tmp/...随时可能被删除
            NSLog(@"location= %@", location);
            //转移文件
            NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
            NSString *filePath = [cache stringByAppendingPathComponent:response.suggestedFilename];
            NSLog(@"filePath = %@",filePath);
            NSURL *toURL = [NSURL fileURLWithPath:filePath];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:toURL error:nil];
            weakSelf.completionHandler(YES, filePath, nil);
        } else {
            weakSelf.completionHandler(NO, nil, error);
        }
        weakSelf.executing = NO;
        weakSelf.finished = YES;
    }];
    [downloadTask resume];
}

- (void)setExecuting:(BOOL )executing{

    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting{
    
    return _executing;
}

- (void)setFinished:(BOOL )finished{
   
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished{
   
    return _finished;
}

- (BOOL)isAsynchronous{
    
    return YES;
}

- (void)dealloc{
    
    NSLog(@"imageUrlStr:释放了:%@",self.imageUrlStr);
}
@end
