//
//  UTIRequest.h
//  Paldaruo
//
//  Created by Patrick Robertson on 25/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^voidBlock)(void);
typedef void (^urlCompletionHandler)(NSData *data, NSError *error);

/**
 *  Handles request objects to/from the server
 */
@interface UTIRequest : NSObject {
    urlCompletionHandler _completionHandler;
    NSData *_boundaryData;
}

@property NSString * serverURLString;
@property NSString * requestHTTPMethod;
@property NSString * requestPath;
@property (readonly, strong, nonatomic) NSMutableURLRequest *request;
@property NSString *contentType;
@property (strong) id <NSURLConnectionDelegate, NSURLConnectionDataDelegate> delegate;
@property (strong) NSMutableData *responseData;

/**
 *  An array of strings which are added to the body of the http request. Separated by the boundary string
 */
@property NSMutableData *bodyData;

- (void)sendRequestAsync;
- (void)sendRequestSync;

- (void)setCompletionHandler:(urlCompletionHandler)c;
- (urlCompletionHandler)completionHandler;
- (void)addBodyData:(NSData *)data withBoundary:(BOOL)withBoundary;
- (void)addBodyString:(NSString *)string withBoundary:(BOOL)withBoundary;
- (void)addBodyString:(NSString *)string usingEncoding:(NSStringEncoding)e withBoundary:(BOOL)withBoundary;

@end
