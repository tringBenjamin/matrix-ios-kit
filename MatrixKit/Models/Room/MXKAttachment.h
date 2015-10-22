/*
 Copyright 2015 OpenMarket Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <MatrixSDK/MatrixSDK.h>

/**
 List attachment types
 */
typedef enum : NSUInteger {
    MXKAttachmentTypeUndefined,
    MXKAttachmentTypeImage,
    MXKAttachmentTypeAudio,
    MXKAttachmentTypeVideo,
    MXKAttachmentTypeLocation,
    MXKAttachmentTypeFile
    
} MXKAttachmentType;

/**
 `MXKAttachment` represents a room attachment.
 */
@interface MXKAttachment : NSObject

/**
 The related matrix event.
 */
@property (nonatomic, readonly) MXEvent *event;

/**
 The attachment type.
 */
@property (nonatomic, readonly) MXKAttachmentType type;

/**
 The attachment information retrieved from event content.
 In case of image, the thumbnail information are not defined anymore, 'thumbnailURL' and 'thumbnailInfo' are then nil.
 */
@property (nonatomic, readonly) NSString *contentURL;
@property (nonatomic, readonly) NSDictionary *contentInfo;
@property (nonatomic) NSString *thumbnailURL;
@property (nonatomic) NSDictionary *thumbnailInfo;

/**
 The actual attachment url
 */
@property (nonatomic, readonly) NSString *actualURL;

/**
 The thumbnail orientation (relevant in case of image).
 */
@property (nonatomic, readonly) UIImageOrientation thumbnailOrientation;

/**
 The cache file path of the attachment.
 */
@property (nonatomic, readonly) NSString *cacheFilePath;

/**
 Local url used to store a preview of the attachment.
 */
@property (nonatomic) NSString *previewURL;

- (instancetype)initWithEvent:(MXEvent*)mxEvent andMatrixSession:(MXSession*)mxSession;

@end