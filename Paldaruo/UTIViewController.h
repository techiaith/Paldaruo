//
//  UTIViewController.h
//  Paldaruo
//
//  Created by Dewi Bryn Jones on 27.12.2013.
//  Copyright (c) 2013 Uned Technolegau Iaith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>


@interface UTIViewController : UIViewController

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSOperationQueue *uploadQueue;

-(void) uploadAudio;
-(void) handleUploadAudioResponse : (NSData *) data error:(NSError *) errorData;

-(void) downloadPrompts;
-(void) handleDownloadPromptsResponse : (NSData *) data error:(NSError *) errorData;

@end


