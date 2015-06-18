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

#import <MatrixSDK/MatrixSDK.h>

/**
 Posted when account user information (display name, picture, presence) has been updated.
 The notification object is the matrix user id of the account.
 */
extern NSString *const kMXKAccountUserInfoDidChangeNotification;

/**
 Posted when the activity of the Push notification service has been changed.
 The notification object is the matrix user id of the account.
 */
extern NSString *const kMXKAccountAPNSActivityDidChangeNotification;

/**
 `MXKAccount` object contains the credentials of a logged matrix user. It is used to handle matrix
 session and presence for this user.
 */
@interface MXKAccount : NSObject <NSCoding>

/**
 The account's credentials: homeserver, access token, user id.
 */
@property (nonatomic, readonly) MXCredentials *mxCredentials;

/**
 The identity server URL.
 */
@property (nonatomic) NSString *identityServerURL;

/**
 The matrix REST client used to make matrix API requests.
 */
@property (nonatomic, readonly) MXRestClient *mxRestClient;

/**
 The matrix session opened with the account (nil by default).
 */
@property (nonatomic, readonly) MXSession *mxSession;

/**
 The account user's display name (nil by default, available if matrix session `mxSession` is opened).
 The notification `kMXKAccountUserInfoDidChangeNotification` is posted in case of change of this property.
 */
@property (nonatomic, readonly) NSString *userDisplayName;

/**
 The account user's avatar url (nil by default, available if matrix session `mxSession` is opened).
 The notification `kMXKAccountUserInfoDidChangeNotification` is posted in case of change of this property.
 */
@property (nonatomic, readonly) NSString *userAvatarUrl;

/**
 The account display name based on user id and user displayname (if any).
 */
@property (nonatomic, readonly) NSString *fullDisplayName;

/**
 The account user's presence (`MXPresenceUnknown` by default, available if matrix session `mxSession` is opened).
 The notification `kMXKAccountUserInfoDidChangeNotification` is posted in case of change of this property.      
 */
@property (nonatomic, readonly) MXPresence userPresence;

/**
 The account user's tint color: a unique color fixed by the user id. This tint color may be used to highlight
 rooms which belong to this account's user.
 */
@property (nonatomic, readonly) UIColor *userTintColor;

/**
 The Push notification activity for this account. YES when APNS is turned on (locally available and synced with server).
 */
@property (nonatomic, readonly) BOOL pushNotificationServiceIsActive;

/**
 Enable Push notifications. Set YES to sync the device with the server.
 NO by default.
 */
@property (nonatomic) BOOL enablePushNotifications;

/**
 Enable In-App notifications based on Remote notifications rules.
 NO by default.
 */
@property (nonatomic) BOOL enableInAppNotifications;

/**
 Get the color code related to a specific presence.
 
 @param presence
 @return color defined for the provided presence (nil if no color is defined).
 */
+ (UIColor*)presenceColor:(MXPresence)presence;

/**
 Init `MXKAccount` instance with credentials.
 
 @param credentials user's credentials
 */
- (instancetype)initWithCredentials:(MXCredentials*)credentials;

/**
 Create a matrix session based on the provided store.
 When store data is ready, the live stream is automatically launched by synchronising the session with the server.
 
 In case of failure during server sync, the method is reiterated until the data is up-to-date with the server.
 This loop is stopped if you call [MXCAccount closeSession:], it is suspended if you call [MXCAccount pauseInBackgroundTask].
 
 @param store the store to use for the session.
 */
-(void)openSessionWithStore:(id<MXStore>)store;

/**
 Close the matrix session.
 
 @param clearStore set YES to delete all store data.
 */
-(void)closeSession:(BOOL)clearStore;

/**
 Pause the current matrix session.
 */
- (void)pauseInBackgroundTask;

/**
 Resume the current matrix session.
 */
- (void)resume;

/**
 Set the display name of the account user.
 
 @param displayname the new display name.
 
 @param success A block object called when the operation succeeds.
 @param failure A block object called when the operation fails.
 */
- (void)setUserDisplayName:(NSString*)displayname success:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 Set the avatar url of the account user.
 
 @param avatarUrl the new avatar url.
 
 @param success A block object called when the operation succeeds.
 @param failure A block object called when the operation fails.
 */
- (void)setUserAvatarUrl:(NSString*)avatarUrl success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Push notification listeners
/**
 Register a listener to push notifications for the account's session.
 
 The listener will be called when a push rule matches a live event.
 Note: only one listener is supported. Potential existing listener is removed.
 
 You may use `[MXCAccount updateNotificationListenerForRoomId:]` to disable/enable all notifications from a specific room.
 
 @param listenerBlock the block that will be called once a live event matches a push rule.
 */
- (void)listenToNotifications:(MXOnNotification)onNotification;

/**
 Unregister the listener.
 */
- (void)removeNotificationListener;

/**
 Update the listener to ignore or restore notifications from a specific room.
 
 @param roomID the id of the concerned room.
 @param isIgnored YES to disable notifications from the specified room. NO to restore them.
 */
- (void)updateNotificationListenerForRoomId:(NSString*)roomID ignore:(BOOL)isIgnored;

@end