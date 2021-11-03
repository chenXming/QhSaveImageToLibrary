//
//  DownloadOperation.h
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadCompletionHandler)(BOOL success , NSString * __nullable filePath, NSError * __nullable error);

@interface QhDownloadOperation : NSOperation

- (instancetype)initWithImageUrlStr:(NSString *)imageUrlStr withCompletionHandler:(DownloadCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
