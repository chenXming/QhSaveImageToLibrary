//
//  QhUploadPicToServe.h
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LoadCompletionHandler)(BOOL success);

@interface QhUploadPicToServe : NSObject

/**
 * 网络图片最大上传数量
 * default = 5
 */
@property (nonatomic, assign) NSInteger maxConcurrentUploadCount;

/**
 * 是否需要后台上传网络图片
 * default = YES
 */
@property (nonatomic, assign) BOOL backgroundUploadSupport;

/**
 * @brief 上传图片到服务端
 * @param mianUrl 上传服务地址
 * @param serveFileParameter 服务端文件参数字段
 * @param imagePathList 图片路径list
 * @param completionHandler 完成后回调
 */
- (void)uploadImageWithMianUrl:(NSString *)mianUrl andServeFileParameter:(NSString *)serveFileParameter andImagePathList:(NSArray *)imagePathList withCompletionHandler:(LoadCompletionHandler)completionHandler;

/**
 * 取消所有上传任务
 */
- (void)cancelAllUpload;

@end

NS_ASSUME_NONNULL_END
