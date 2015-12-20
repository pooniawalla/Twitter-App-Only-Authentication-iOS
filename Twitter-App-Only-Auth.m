//
//  Twitter-App-Only-Auth.m
//  Twitter-App-Only-Authentication-iOS-App
//
//  Created by Babu Lal on 20/12/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import "Twitter-App-Only-Auth.h"

static NSString* kConsumerKey = @"30SybZNHZvNOsMj0kwEegqwjA";
static NSString* kConsumerSecretKey = @"mLWGpyjlKW7rtGcdiv77AXias9PBJopsy0FIyt5XvarwKrGj24";
static NSString* kTwitterAuthAPI = @"https://api.twitter.com/oauth2/token";

#define kRequestTimeOutInterval 30.0

@interface Twitter_App_Only_Auth()

@property (nonatomic, retain) NSString *accessToken;

@end

@implementation Twitter_App_Only_Auth

/* Steps to get Access_Token:
 1. Create application on you "dev.twitter" acount
 2. Get "kConsumerKey" and "kConsumerSecretKey"
 3. Get getBase64EncodedBearerToken
 4. Make "kTwitterAuthAPI" call with "Basic Authorization"
 5. Get "access_token" and use it in "Bearer Authorization" calls
 */

#pragma mark - Get Access Token

- (void)verifyCredentialsAndGetAccessToken:(void(^)(NSString *accessToken, NSError *error))block{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kTwitterAuthAPI]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:kRequestTimeOutInterval];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:@{@"grant_type":@"client_credentials"}]];
    [request setValue:[NSString stringWithFormat:@"Basic %@", [self getBase64EncodedBearerToken]] forHTTPHeaderField:@"Authorization"];
    
    [self performURLSessionTaskForRequest:request successBlock:^(id responseObject) {
        // Your access_token is here.
        if(responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
            if(responseObject[@"access_token"]){
                NSString *token = responseObject[@"access_token"];
                if(block)
                    block(token, nil);
            } else {
                if(block)
                    block(nil, nil);
            }
        }
    } errorBlock:^(NSError *error) {
        if (block)
            block(nil, error);
    }];
}

#pragma mark - Perform URLSession Task

/*
 * Method to perform session task
 */

- (void)performURLSessionTaskForRequest:(NSURLRequest *)request
                           successBlock:(void(^)(id responseObject))successBlock
                             errorBlock:(void(^)(NSError *error))errorBlock{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSLog(@"Error: %@", error);
            if(errorBlock){
                errorBlock(error);
            }
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                NSLog(@"Error Code: %ld", (long)statusCode);
                if(errorBlock){
                    errorBlock(nil);
                }
                return;
            }
        }
        
        if(data){
            NSError *parseError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (!responseObject) {
                NSLog(@"Error in Parsing Data");
                if(errorBlock){
                    errorBlock(parseError);
                }
            } else {
                NSLog(@"ResponseObject for request: %@", request.URL);
                if(successBlock){
                    successBlock(responseObject);
                }
            }
        }
    }];
    [task resume];
}

#pragma mark - Private Methods

/*
 * percent escape legal characters
 * replace " " with "+" for query params
 */

- (NSString *)percentEscapeString:(NSString *)string
{
    string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceCharacterSet]];
    return [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

/*
 * BearerToken = "ConsumerKey" + ":" + "ConsumerSecretKey"
 */

- (NSString *)getBase64EncodedBearerToken
{
    NSString *encodedConsumerToken = [self percentEscapeString:kConsumerKey];
    NSString *encodedConsumerSecret = [self percentEscapeString:kConsumerSecretKey];
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", encodedConsumerToken, encodedConsumerSecret];
    NSData *data = [bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

@end
