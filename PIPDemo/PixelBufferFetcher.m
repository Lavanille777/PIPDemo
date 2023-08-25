//
//  bridge.m
//  PIPDemo
//
//  Created by lavanille on 2023/8/23.
//

#import "PixelBufferFetcher.h"
#import <AVKit/AVKit.h>

@interface PixelBufferFetcher() {
    CVPixelBufferRef _previousPixelBuffer;
}
@end

@implementation PixelBufferFetcher

- (CMSampleBufferRef)fetchPixelBufferBy:(IJKFFMoviePlayerController *)player sampleBufferLayer: (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    [player framePixelbufferLock];
    CVPixelBufferRef pixelBuffer = [player framePixelbuffer];
    [self displayPixelBuffer:pixelBuffer sampleBufferLayer:sampleBufferDisplayLayer];
    [player framePixelbufferUnlock];
    return nil;
}

- (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
  
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus err = noErr;
    CMVideoFormatDescriptionRef formatDesc = NULL;
    
    CVPixelBufferRetain(pixelBuffer);
    
    err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);
  
    if (err != noErr) {
        return nil;
    }
    
    CMSampleTimingInfo sampleTimingInfo = kCMTimingInfoInvalid;
  
    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc, &sampleTimingInfo, &sampleBuffer);
  
    if (sampleBuffer) {
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    }
  
    if (err != noErr) {
        return nil;
    }
  
    formatDesc = nil;
    CVPixelBufferRelease(pixelBuffer);
  
    return sampleBuffer;
  
}

- (void)displayPixelBuffer:(CVPixelBufferRef) pixelBuffer sampleBufferLayer: (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    
    if (sampleBufferDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [sampleBufferDisplayLayer flush];
    }
    if (sampleBufferDisplayLayer.isReadyForMoreMediaData && pixelBuffer) {
        CMSampleBufferRef sampleBuffer = [self sampleBufferFromPixelBuffer:pixelBuffer];
        if (CMSampleBufferDataIsReady(sampleBuffer)){
            dispatch_async(dispatch_get_main_queue(), ^{
                [sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            });
        }
    }
}

//
//
//-  (CVPixelBufferRef)copyWithPixelbuffer:(CVPixelBufferRef)originalPixelBuffer {
//    // 创建一个IOSurface属性字典
//
//    CVPixelBufferLockBaseAddress(originalPixelBuffer, 0);
//    size_t width = CVPixelBufferGetWidth(originalPixelBuffer);
//    size_t height = CVPixelBufferGetHeight(originalPixelBuffer);
//    OSType pixelFormatType = CVPixelBufferGetPixelFormatType(originalPixelBuffer);
//    NSDictionary *pixelBufferAttributes = @{
//        (NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{}
//    };
//
//    // 创建新的CVPixelBuffer
//    CVPixelBufferRef copiedPixelBuffer;
//    CVReturn result = CVPixelBufferCreate(
//        kCFAllocatorDefault,
//        width,
//        height,
//        pixelFormatType,
//        (__bridge CFDictionaryRef)pixelBufferAttributes,
//        &copiedPixelBuffer
//    );
//
//    if (result != kCVReturnSuccess) {
//        // 处理创建CVPixelBuffer的错误
//        return NULL;
//    }
//
//    // 复制像素数据到新的CVPixelBuffer
//
//    CVPixelBufferLockBaseAddress(copiedPixelBuffer, 0);
//
//    void *srcBaseAddress = CVPixelBufferGetBaseAddress(originalPixelBuffer);
//    void *dstBaseAddress = CVPixelBufferGetBaseAddress(copiedPixelBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(originalPixelBuffer);
//    size_t bufferSize = CVPixelBufferGetDataSize(originalPixelBuffer);
//
//    memcpy(dstBaseAddress, srcBaseAddress, bufferSize);
//
//    CVPixelBufferUnlockBaseAddress(originalPixelBuffer, 0);
//    CVPixelBufferUnlockBaseAddress(copiedPixelBuffer, 0);
//
//    // 处理复制完成后的CVPixelBuffer
//
//    return copiedPixelBuffer;
//}
//


/// image to buffer
//- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
//    NSDictionary *options = @{
//                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
//                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
//                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]
//                              };
//    CVPixelBufferRef pxbuffer = NULL;
//    CGFloat frameWidth = CGImageGetWidth(image);
//    CGFloat frameHeight = CGImageGetHeight(image);
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                          frameWidth,
//                                          frameHeight,
//                                          kCVPixelFormatType_32BGRA,
//                                          (__bridge CFDictionaryRef) options,
//                                          &pxbuffer);
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata,
//                                                 frameWidth,
//                                                 frameHeight,
//                                                 8,
//                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
//                                                 rgbColorSpace,
//                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
//    NSParameterAssert(context);
//    CGContextConcatCTM(context, CGAffineTransformIdentity);
//    CGContextDrawImage(context, CGRectMake(0,
//                                           0,
//                                           frameWidth,
//                                           frameHeight),
//                       image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    return pxbuffer;
//}

@end
