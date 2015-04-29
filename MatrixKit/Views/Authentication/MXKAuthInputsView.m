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

#import "MXKAuthInputsView.h"

@implementation MXKAuthInputsView

+ (UINib *)nib {
    // By default, no nib is available.
    return nil;
}

+ (instancetype)authInputsView {
    
    // Check whether a xib is defined
    if ([[self class] nib]) {
        return [[[self class] nib] instantiateWithOwner:nil options:nil].firstObject;
    }
    
    return [[[self class] alloc] init];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    self.authType = MXKAuthenticationTypeLogin;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.authType = MXKAuthenticationTypeLogin;
    }
    return self;
}

#pragma mark -

- (CGFloat)actualHeight {
    return self.frame.size.height;
}

- (BOOL)areAllRequiredFieldsFilled {
    // Currently no field to check here
    return YES;
}

- (void)setAuthType:(MXKAuthenticationType)authType {
    if (authType == MXKAuthenticationTypeLogin) {
        self.displayNameTextField.hidden = YES;
    } else {
        self.displayNameTextField.hidden = NO;
    }
    _authType = authType;
}

- (void)dismissKeyboard {
    [self.displayNameTextField resignFirstResponder];
}

- (void)nextStep {
    self.displayNameTextField.hidden = YES;
}

- (void)resetStep {
    self.authType = _authType;
}

@end