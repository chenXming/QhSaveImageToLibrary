//
//  DownloadOperation.h
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import <Foundation/Foundation.h>
#import "QhBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadCompletionHandler)(BOOL success , NSString * __nullable filePath, NSError * __nullable error);

@interface QhDownloadOperation : QhBaseOperation

/**
 * @brief 初始化下载任务
 * @param imageUrlStr 图片url
 * @param background 是否支持后台下载
 * @param completionHandler 下载完成后回调
 */
- (instancetype)initWithImageUrlStr:(NSString *)imageUrlStr backgroundSupport:(BOOL)background withCompletionHandler:(DownloadCompletionHandler)completionHandler;

/**
 *@brief 取消当前下载任务
 */
- (void)cancelDownLoad;
@end

NS_ASSUME_NONNULL_END
