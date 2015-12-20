//
//  Twitter-App-Only-Auth.h
//  Twitter-App-Only-Authentication-iOS-App
//
//  Created by Babu Lal on 20/12/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Twitter_App_Only_Auth : NSObject

#pragma mark - Get Access Token

- (void)verifyCredentialsAndGetAccessToken:(void(^)(NSString *accessToken, NSError *error))block;

@end
