//
//  UTIUploadAudioInfo.m
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 9.6.2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIUploadAudioInfo.h"

@implementation UTIUploadAudioInfo

-(id) initWithUid:(NSString*) uid andUploadSource:(NSURL *)source  andIdent:(NSString *)ident {

    if (self == [super init]) {
        self.uid=uid;
        self.ident=ident;
        self.uploadSource=source;
        self.uploadProgress=0.0;
        self.isUploading=NO;
        self.uploadComplete=NO;
        self.taskIdentifier=-1;
    }
    
    return self;
    
}

@end

