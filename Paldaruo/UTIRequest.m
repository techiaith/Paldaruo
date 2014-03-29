//
//  UTIRequest.m
//  Paldaruo
//
//  Created by Patrick Robertson on 25/03/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIRequest.h"


@implementation UTIRequest

@synthesize request=_request;


- (instancetype)init {
    if (self = [super init]) {
        _bodyDataArray = [NSMutableArray new];
        _completionHandler = nil;
    }
    return self;
}

- (NSMutableURLRequest *)request {
    if (_request) {
        // Request already set up. No need to recreate it
        return _request;
    }
    
    if (!self.requestPath) {
        NSLog(@"ERROR: You must set a request path before submitting a request");
    }
    
    NSURL *url = [NSURL URLWithString:(self.serverURLString ? self.serverURLString : kServerHost)];
    url = [url URLByAppendingPathComponent:self.requestPath];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:(self.requestHTTPMethod ? self.requestHTTPMethod : @"POST")];
    
    NSString *contentType = self.contentType;
    if (!contentType) {
        contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kRequestBoundary];
    }
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData new];
    NSData *boundaryData = [[NSString stringWithFormat:@"\r\n--%@\r\n", kRequestBoundary]dataUsingEncoding:NSUTF8StringEncoding];
    [body appendData:boundaryData];
    for (NSData *data in self.bodyDataArray) {
        [body appendData:data];
        [body appendData:boundaryData];
    }
    
    [request setHTTPBody:body];
    
    _request = request;
    return request;
    
}


- (void)sendRequestAsync {
    [self sendRequestAsynchronously:YES];
}

- (void)sendRequestSync {
    [self sendRequestAsynchronously:NO];
}

- (void)sendRequestAsynchronously:(BOOL)async {
    
    NSMutableURLRequest *request = self.request;
    
    if (!request) {
        NSLog(@"Aborting request...");
        return;
    }
    
    if (async) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (self.delegate) {
                [self.delegate handleRequest:self withResponse:response body:data error:connectionError];
            } else if (self.completionHandler) {
                self.completionHandler(response, data, connectionError);
            }
            // Clear the old request. A new one will be generated if need be
            _request = nil;
        }];
    } else {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        self.completionHandler(response, data, error);
        self.responseError = error;
    }

}

- (void)addBodyData:(NSData *)data {
    if (![data isKindOfClass:[NSData class]]) {
        NSLog(@"ERROR: You must set an NSData object for the request body data. Aborting");
        return;
    }
    [self.bodyDataArray addObject:data];
}

- (void)addBodyString:(NSString *)string usingEncoding:(NSStringEncoding)e {
    NSData *d = [string dataUsingEncoding:e];
    [self.bodyDataArray addObject:d];
}

#pragma mark Property accessors

- (void)setCompletionHandler:(urlCompletionHandler)c {
    _completionHandler = c;
}

- (urlCompletionHandler)completionHandler {
    return _completionHandler;
}
@end
