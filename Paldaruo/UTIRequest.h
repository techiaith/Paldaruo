//
//  UTIRequest.h
//  Paldaruo
//
//  Created by Patrick Robertson on 25/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^voidBlock)(void);
typedef void (^urlCompletionHandler)(NSURLResponse *response, NSData *data, NSError *error);


@class UTIRequest;
@protocol UTIRequestDelegate <NSObject>

@required

- (void)handleRequest:(UTIRequest *)request withResponse:(NSURLResponse *)response body:(NSData *)data error:(NSError *)error;

@end
/**
 *  Handles request objects to/from the server
 */
@interface UTIRequest : NSObject {
    urlCompletionHandler _completionHandler;
}

@property id <UTIRequestDelegate> delegate;
@property NSString * serverURLString;
@property NSString * requestHTTPMethod;
@property NSString * requestPath;
@property (readonly, strong, nonatomic) NSMutableURLRequest *request;
@property NSString *contentType;
@property NSError __block *responseError;

/**
 *  An array of strings which are added to the body of the http request. Separated by the boundary string
 */
@property NSMutableArray *bodyDataArray;

- (void)sendRequestAsync;
- (void)sendRequestSync;

- (void)setCompletionHandler:(urlCompletionHandler)c;
- (urlCompletionHandler)completionHandler;
- (void)addBodyData:(NSData *)data;
- (void)addBodyString:(NSString *)string;
- (void)addBodyString:(NSString *)string usingEncoding:(NSStringEncoding)e;

@end
