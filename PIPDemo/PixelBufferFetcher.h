//
//  bridge.h
//  PIPDemo
//
//  Created by lavanille on 2023/8/23.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    int a;
} __TestStruct;

@interface PixelBufferFetcher : NSObject
- (CMSampleBufferRef)fetchPixelBufferBy: (IJKFFMoviePlayerController *)player sampleBufferLayer: (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer;
- (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

NS_ASSUME_NONNULL_END
