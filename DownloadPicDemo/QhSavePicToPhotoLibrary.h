//
//  QhSavePicToPhotoLibrary.h
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SaveCompletionHandler)(BOOL success);

@interface QhSavePicToPhotoLibrary : NSObject

/**
 * 网络图片最大同时下载数量
 * default = 5
 */
@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount;

/**
 * 保存成功后是否删除下载缓存的网络图片
 * default = YES
 */
@property (nonatomic, assign) BOOL deleteDownloadImageCache;

/**
 * @brief 保存本地图片到相册
 * @param imageList 图片数组
 * @param libryName 相册名称，传空则保存到系统相册
 * @param completionHandler 保存后回调
 */
- (void)saveImageToPhotoLibraryWithImageList:(NSArray <UIImage *> *)imageList andLibraryName:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler;

/**
 * @brief 保存网络图片到相册
 * @param imageUrlList 图片url数组
 * @param libryName 相册名称，传空则保存到系统相册
 * @param completionHandler 保存后回调
 */
- (void)saveOnLineImageToPhotoLibraryWithImageList:(NSArray <NSURL *> *)imageUrlList andLibraryName:(NSString *)libryName callBack:(SaveCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END