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

@property (weak, nonatomic) IBOutlet UITextField *customLibraryField;
@property (weak, nonatomic) IBOutlet UITextField *setMaxCocurrentCountField;
@property (weak, nonatomic) IBOutlet UISwitch *backgroundTaskSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *whetherDeleateCacheSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.savePic = [[QhSavePicToPhotoLibrary alloc] init];
    self.upLoadPic = [[QhUploadPicToServe alloc] init];

    NSLog(@"%s",__func__);
}

- (IBAction)saveLocalImageToCustomLibraryClick:(id)sender {
    
    NSArray *imageList = @[[UIImage imageNamed:@"001.jpg"],[UIImage imageNamed:@"002.jpg"],[UIImage imageNamed:@"003.jpg"],[UIImage imageNamed:@"00003.jpg"],[UIImage imageNamed:@"0004.jpg"],[UIImage imageNamed:@"0005.jpg"],
                           [UIImage imageNamed:@"00006.jpg"]];
    [self.savePic saveImageToPhotoLibraryWithImageList:imageList andLibraryName:@"" callBack:^(BOOL success) {
        
    }];
}

- (IBAction)downloadImageToLibraryClick:(id)sender {

    __weak __typeof (self) wself = self;
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
    self.savePic.maxConcurrentDownloadCount = 3;
    [self.savePic saveOnLineImageToPhotoLibraryWithImageList:imageUrlList andLibraryName:@"测试2" callBack:^(BOOL success) {
        __strong __typeof (wself) sself = wself;
        NSLog(@"success=========>>>>%d",success);
        if(success){
            
        }else {
            [sself showAlert];
        }
    }];
}

- (IBAction)upLoadImageListToServerClick:(id)sender {
    
    NSString *imageBundle = [[NSBundle mainBundle] pathForResource:@"test001" ofType:@"png"];
    NSArray *imageArr = @[imageBundle,imageBundle];
    self.upLoadPic.maxConcurrentUploadCount = 1;

    [self.upLoadPic uploadImageWithServeIp:ServeIp andServeFileParameter:@"smfile" andImagePathList:imageArr withCompletionHandler:^(BOOL success,NSArray *imageUrlList) {
        NSLog(@"success==%d\nimageUrlList==%@",success,imageUrlList);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)showAlert {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的\"设置-隐私-照片\"中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
