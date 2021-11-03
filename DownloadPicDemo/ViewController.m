//
//  ViewController.m
//  DownloadPicDemo
//
//  Created by 陈小明 on 2021/10/21.
//

#import "ViewController.h"
#import "ImageDownloader/QhDownloadOperation.h"
#import "QhSavePicToPhotoLibrary.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s",__func__);
}

- (IBAction)downloadClick:(id)sender {
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
    
    QhSavePicToPhotoLibrary *savePic = [[QhSavePicToPhotoLibrary alloc] init];
    savePic.maxConcurrentDownloadCount = 5;
    [savePic saveOnLineImageToPhotoLibraryWithImageList:imageUrlList andLibraryName:@"" callBack:^(BOOL success) {
        NSLog(@"success=========>>>>%d",success);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"下载");
   
}
@end
