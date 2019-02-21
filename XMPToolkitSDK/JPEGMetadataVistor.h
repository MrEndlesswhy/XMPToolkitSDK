//
//  JPEGMetadataVistor.h
//  XMPToolkitSDK
//
//  Created by Evan Xie on 2018/9/30.
//  Copyright © 2018 GO6D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XMPErrorCode) {
    XMPErrorCodeOk,
    XMPErrorCodeXMPSetupFailed,
    XMPErrorCodeFileCanNotOpen,
    XMPErrorCodeMetadataNotWritable,
    XMPErrorCodeAddMetadataFailed
};

@interface JPEGMetadataVistor: NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithJpegFilePath:(NSString *)imageFilePath;

- (void)setPanoramaMetadataWithWidth:(NSInteger)width height:(NSInteger)height captureSoftware:(NSString *)captureSoftware;

- (void)setMotionMetadataWithQuaternion:(simd_float4)motion;

/// 调用此方法后，JPEGMetadataVistor将不再可用。
- (XMPErrorCode)saveMetadataToFile;

@end

NS_ASSUME_NONNULL_END
