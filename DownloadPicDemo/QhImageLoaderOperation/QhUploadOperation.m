//
//  QhUploadOperation.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import "QhUploadOperation.h"
#import "UIImage+ImageContent.h"

#define Boundary @"QhUploadImage"
#define Enter [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]
#define Encode(string) [string dataUsingEncoding:NSUTF8StringEncoding]

@interface QhUploadOperation()

@property (copy, nonatomic, nullable) NSString *serveIp;
@property (copy, nonatomic, nullable) NSString *imageLocalUrl;
@property (copy, nonatomic, nullable) NSString *serveFileParameter;
@property (copy, nonatomic, nullable) NSURLSessionUploadTask *uploadTask;
@property (copy, nonatomic, nullable) UploadCompletionHandler completionHandler;

@end

@implementation QhUploadOperation

- (instancetype)initWithServeIp:(NSString *)serveIp andServeFileParameter:(NSString *)serveFileParameter andImageUrlStr:(NSString *)imageLocalUrl backgroundSupport:(BOOL)background withCompletionHandler:(UploadCompletionHandler)completionHandler {

    if(self = [super init]){
        self.serveIp = serveIp;
        self.imageLocalUrl = imageLocalUrl;
        self.backgroundSupport = background;
        self.serveFileParameter = serveFileParameter;
        
        if(completionHandler){
            _completionHandler = completionHandler;
        }
    }
    return  self;
}

- (void)startTask{

    __weak __typeof__ (self) wself = self;

    NSURL *url = [NSURL URLWithString:_serveIp];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *head = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",Boundary];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
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

- (void)cancelTask {
    if (self.uploadTask) {
        [self.uploadTask cancel];
        self.uploadTask = nil;
        [self done];
    }
}

- (void)cancelUpLoad {
    [super cancel];
}

@end
