//
//  ViewController.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import "ViewController.h"
#import "QhSavePicToPhotoLibrary.h"
#import "QhUploadPicToServe.h"

#define   ServeIp      @"https://sm.ms/api/v2/upload"

@interface ViewController ()

@property(strong, nonatomic, nonnull) QhSavePicToPhotoLibrary *savePic;
@property(strong, nonatomic, nonnull) QhUploadPicToServe *upLoadPic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s",__func__);
}
- (IBAction)clickDown:(id)sender {
    
    NSLog(@"=========");
    
    /*
    NSArray *imageList = @[[UIImage imageNamed:@"001.jpg"],[UIImage imageNamed:@"002.jpg"],[UIImage imageNamed:@"003.jpg"],[UIImage imageNamed:@"00003.jpg"],[UIImage imageNamed:@"0004.jpg"],[UIImage imageNamed:@"0005.jpg"],
                           [UIImage imageNamed:@"00006.jpg"]];
    QhSavePicToPhotoLibrary *savePic = [[QhSavePicToPhotoLibrary alloc] init];
    [savePic saveImageToPhotoLibraryWithImageList:imageList andLibraryNmae:@"测试" callBack:^(BOOL success) {
        NSLog(@"success===%d",success);
    }];
    */
    
    NSArray *imageUrlList = @[[NSURL URLWithString:@"https://i.loli.net/2021/11/02/aYnZxByIC4u1GFX.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/2YMvcEGSZqAefRQ.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/pdF3jiDGTxLUPhl.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/OgBpvVI9L6X3qds.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/qoyLhApdReSXBxg.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/aYnZxByIC4u1GFX.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/2YMvcEGSZqAefRQ.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/pdF3jiDGTxLUPhl.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/OgBpvVI9L6X3qds.jpg"],
                              [NSURL URLWithString:@"https://i.loli.net/2021/11/02/qoyLhApdReSXBxg.jpg"]];
    
    self.savePic = [[QhSavePicToPhotoLibrary alloc] init];
    self.savePic.maxConcurrentDownloadCount = 1;
    [self.savePic saveOnLineImageToPhotoLibraryWithImageList:imageUrlList andLibraryName:@"测试2" callBack:^(BOOL success) {
        NSLog(@"success=========>>>>%d",success);
    }];
}

- (IBAction)cancelDownImage:(id)sender {
    
    NSLog(@"%s",__func__);
//    [self.savePic cancelAllDownloads];
    
    NSString *imageBundle = [[NSBundle mainBundle] pathForResource:@"test001" ofType:@"png"];
    NSArray *imageArr = @[imageBundle];
    self.upLoadPic = [[QhUploadPicToServe alloc] init];
    self.upLoadPic.maxConcurrentUploadCount = 1;
    
    [self.upLoadPic uploadImageWithServeIp:ServeIp andServeFileParameter:@"smfile" andImagePathList:imageArr withCompletionHandler:^(BOOL success,NSArray *imageUrlList) {
        NSLog(@"success==%d\nimageUrlList==%@",success,imageUrlList);
    }];
    
}

@end
