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
        _boundaryData = [[NSString stringWithFormat:@"\r\n--%@\r\n", kRequestBoundary]dataUsingEncoding:NSUTF8StringEncoding];
        _responseData = [NSMutableData new];
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
    
    // The very first boundary data is slightly different from the rest (there is no trailing -- after the boundary
    [body appendData:_boundaryData];
    for (NSData *data in self.bodyDataArray) {
        [body appendData:data];
    }
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kRequestBoundary]dataUsingEncoding:NSUTF8StringEncoding]];
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
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        self.completionHandler(data, error);
        _request = nil;
    }
}

- (void)addBodyData:(NSData *)data withBoundary:(BOOL)withBoundary{
    if (![data isKindOfClass:[NSData class]]) {
        NSLog(@"ERROR: You must set an NSData object for the request body data. Aborting");
        return;
    }
    [self.bodyDataArray addObject:data];
    if (withBoundary) {
        [self.bodyDataArray addObject:_boundaryData];
    }
}

- (void)addBodyString:(NSString *)string withBoundary:(BOOL)withBoundary {
    [self addBodyString:string usingEncoding:NSUTF8StringEncoding withBoundary:withBoundary];
}

- (void)addBodyString:(NSString *)string usingEncoding:(NSStringEncoding)e withBoundary:(BOOL)withBoundary {
    NSData *d = [string dataUsingEncoding:e];
    [self addBodyData:d withBoundary:withBoundary];
}

#pragma mark Property accessors

- (void)setCompletionHandler:(urlCompletionHandler)c {
    _completionHandler = c;
}

- (urlCompletionHandler)completionHandler {
    return _completionHandler;
}

#pragma mark Delegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.completionHandler) {
        self.completionHandler(self.responseData, nil);
    }
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:connection didFailWithError:error];
    }
    _request = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.completionHandler) {
        self.completionHandler(self.responseData, nil);
    }
    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.delegate connectionDidFinishLoading:connection];
    }
    _request = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.delegate connection:connection didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesExpectedToWrite totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}
@end
