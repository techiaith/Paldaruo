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
        _completionHandler = nil;
        _boundaryData = [[NSString stringWithFormat:@"\r\n--%@\r\n", kRequestBoundary] dataUsingEncoding:NSUTF8StringEncoding];
        _responseData = [NSMutableData new];
        _bodyDataArray = [NSMutableArray new];

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
        return nil;
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
    if ([self.bodyDataArray count]) {
        [body appendData:_boundaryData];
        for (NSData *d in self.bodyDataArray) {
            [body appendData:d];
        }
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
    _request500ed = NO;

    if (!request) {
        NSLog(@"Aborting request...");
        return;
    }
    
    if (async) {
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // http status code is forgotten about in synchronous communications.
        if ([response statusCode]!=200)
        {
            error = [NSError errorWithDomain:@"uk.ac.bangor.techiaith.paldaruo"
                                        code:-9999
                                    userInfo:@{NSLocalizedDescriptionKey:@"Gwall cyffredinol gyda gweinydd Paldaruo"}];
        }
        
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
    
    NSLog(error.localizedDescription);
    
    if (self.completionHandler) {
        self.completionHandler(self.responseData, nil);
    }
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:connection didFailWithError:error];
    }
    _request = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   
    NSError *err = nil;
    if (self.request500ed) {
        err = [NSError errorWithDomain:@"uk.ac.bangor.techiaith.paldaruo"
                                  code:-9999
                              userInfo:@{NSLocalizedDescriptionKey : @"Gwall cyffredinol gyda gweinydd Paldaruo"}];
    }
    if (self.completionHandler) {
        self.completionHandler(err ? nil : self.responseData, err);
    }
    
    if (err) {
        // The server gave a 500 error, so we fake that this is a connection failure (for our own error handling)
        [self connection:connection didFailWithError:err];
        return;
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

- (void)connection:(NSURLConnection *)connection c:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if ([self.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        
        NSString* message = [NSString stringWithFormat:@"%d written out of %d", totalBytesWritten, totalBytesExpectedToWrite];
        NSLog(message);
        
        [self.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesExpectedToWrite totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    //if (response.statusCode == 500) {
    if (response.statusCode != 200) {
        self.request500ed = YES;
    }
}
@end
