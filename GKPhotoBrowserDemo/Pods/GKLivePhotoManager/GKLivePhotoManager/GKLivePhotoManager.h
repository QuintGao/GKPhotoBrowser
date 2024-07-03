//
//  GKLivePhotoManager.h
//  GKLivePhotoManager
//
//  Created by QuintGao on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKLivePhotoManager : NSObject

+ (instancetype)manager NS_SWIFT_NAME(default());
+ (void)deallocManager;

/// 处理视频并生成livePhoto需要的文件
/// - Parameters:
///   - videoPath: 视频地址（必须是本地地址）
///   - completion: 完成回调
- (void)handleDataWithVideoPath:(NSString *_Nonnull)videoPath
                  progressBlock:(void(^_Nullable)(float progress))progressBlock
                     completion:(void(^_Nullable)(NSString *_Nullable outVideoPath, NSString *_Nullable outImagePath, NSError *_Nullable error))completion;

/// 处理视频和图片并生成livePhoto需要的文件
/// - Parameters:
///   - videoPath: 视频地址（必须是本地地址）
///   - imagePath: 图片地址（必须是本地地址）
///   - completion: 完成回调
- (void)handleDataWithVideoPath:(NSString *_Nonnull)videoPath
                      imagePath:(NSString *_Nullable)imagePath
                  progressBlock:(void(^_Nullable)(float progress))progressBlock
                     completion:(void(^_Nullable)(NSString *_Nullable outVideoPath, NSString *_Nullable outImagePath, NSError *_Nullable error))completion;

/// 根据视频和图片地址生成livePHoto
/// - Parameters:
///   - videoPath: 视频地址（必须是本地地址）
///   - imagePath: 图片地址（必须是本地地址）
///   - targetSize: 目标尺寸
///   - completion: 完成回调
- (void)createLivePhotoWithVideoPath:(NSString *)videoPath
                           imagePath:(NSString *)imagePath
                          targetSize:(CGSize)targetSize
                          completion:(void(^_Nullable)(PHLivePhoto *_Nullable livePhoto, NSError *_Nullable error))completion;

/// 根据相册资源文件生成livePhoto
/// - Parameters:
///   - asset: 资源
///   - targetSize: 目标尺寸
///   - completion: 完成回调
- (void)createLivePhotoWithAsset:(PHAsset *)asset
                      targetSize:(CGSize)targetSize
                   progressBlock:(void(^_Nullable)(float progress))progressBlock
                      completion:(void(^_Nullable)(PHLivePhoto *_Nullable livePhoto, NSError *_Nullable error))completion;

/// 保存livePHoto到相册
/// - Parameters:
///   - videoPath: 视频地址（必须是本地地址）
///   - imagePath: 图片地址（必须是本地地址）
///   - completion: 完成回调
- (void)saveLivePhotoWithVideoPath:(NSString *)videoPath
                         imagePath:(NSString *)imagePath
                        completion:(void(^_Nullable)(BOOL, NSError *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
