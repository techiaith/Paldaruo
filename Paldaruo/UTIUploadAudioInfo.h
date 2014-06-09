//
//  UTIUploadAudioInfo.h
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 9.6.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UTIUploadAudioInfo : NSObject

@property (nonatomic, strong) NSString* ident;
@property (nonatomic, strong) NSString* uid;
@property (nonatomic, strong) NSURL* uploadSource;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic) double uploadProgress;
@property (nonatomic) BOOL isUploading;
@property (nonatomic) BOOL uploadComplete;
@property (nonatomic) unsigned long taskIdentifier;

-(id) initWithUid:(NSString*) uid andUploadSource:(NSURL *)source  andIdent:(NSString *)ident;

@end
