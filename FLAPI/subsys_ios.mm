/*
 *  subsys_ios.cpp
 *  FLAPI
 *
 *  Created by Pierre-Mikael Legris on 08.03.11.
 *  Copyright 2011 fondation Defitech. All rights reserved.
 *
 * ref: http://blog.boreal-kiss.net/2011/03/15/how-to-create-universal-static-libraries-on-xcode-4/
 * http://trailsinthesand.com/exploring-iphone-audio-part-3/
 */

#include "subsys_ios.h"

#import "FLAPIX.h"

#include <AVFoundation/AVAudioSession.h>

RecordState recordState;

// use to read / write data used in developppement stages
FILE *filedev;
// tag if we are reading from filedev 0=none 1=reading -1=writing
int filedevtag = 0;

// The Buffer to work on;
short *myBuff;

// reference to pass events
FLAPIX *flapix;

bool stop_request = false; // we are waiting for a stop
bool stop_possible = true; // flag passed to true when OnSubSystemProcess


bool running = false;
bool paused = false;

// Standard Subsystem function
// ===========================

/**
 * set the system to read or save a file, used in dev mode
 * you must call FLAPI_Start() after that
 *
 * const char* torecord = [[NSTemporaryDirectory() stringByAppendingPathComponent: @"FLAPIrecord.raw"] UTF8String];
 * const char* toread = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"FLAPIrecorded.raw"] UTF8String];
 *
 * To stop, call  FLAPI_SUBSYS_IOS_file_dev(nil,true);
 *
 */
void FLAPI_SUBSYS_IOS_file_dev(const char* filepath,bool read){
    if (filepath == nil) {
        if (filedevtag != 0) fclose(filedev); // close file read / saving for devel
        filedevtag = 0;
        printf("FLAPI out of dev mode");
        return;
    }
    
    
	filedev = fopen(filepath, read ? "rb" : "wb");
	if (read) myBuff = (short*) malloc (sizeof(short)*gAudioInfo.buffer_sample);
	filedevtag = read ? 1 : -1;
	
	printf(read ? "Reading data to file %s\n" : "Writing data to file %s\n",filepath);
}


BOOL isMicrophonePluggedIn () {
    //--check the actual Route
    CFStringRef state = nil;
    UInt32 propertySize = sizeof(CFStringRef);
    OSStatus result = AudioSessionGetProperty( kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if( result == kAudioSessionNoError)
    {
        if( CFStringGetLength(state) > 0)
        {
            NSLog(@"SUbsyIOS:Actual ROUTE:%@",(NSString *)state);
            if ([@"HeadsetInOut" isEqualToString:(NSString *)state]) {
                NSLog(@"**Yeahh ready to go!");
                return YES;
            }
             return NO;
        }
    } NSLog(@"SUbsyIOS:Actual Failed"); 
    
    return NO;
}

void audioRouteChangeListenerCallback (
                         void                      *inClientData,
                         AudioSessionPropertyID    inPropertyID,
                         UInt32                    inDataSize,
                         const void                *inData
                         ) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return; // 5
    //MainViewController *controller = (MainViewController *) inUserData; // 6
    
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inData;        // 8
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary,
                                                                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    if ((routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) || 
        (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable)) {  // 9
            
    }
}


void FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(FLAPIX *owner){
    flapix = owner;
    
    // -- set the audio session for playback and recording
    NSError *myErr;
    BOOL    bSuccess = FALSE;
    BOOL    bAudioInputAvailable = FALSE;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setDelegate:[[subsys_ios_AVAudioSessionDelegate alloc] init]];
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     [audioSession delegate]);
    
    
    bAudioInputAvailable= [audioSession inputIsAvailable];
    
    if( bAudioInputAvailable)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
    }
    else {
        NSLog(@"FLAPI_SUBSYS_IOS_init_and_registerFLAPIX: Cannot init AudioSession");
    }
    
    // test
    isMicrophonePluggedIn();   
    
    
    bSuccess= [audioSession setActive: YES error: &myErr];  
    
    if(!bSuccess)
    {
        NSLog(@"Unable to Start Audio Session. Terminate Application.");
        NSLog(@"%@",[myErr localizedDescription]);
        NSLog(@"%@",[myErr localizedFailureReason]);
        NSLog(@"%@",[myErr localizedRecoverySuggestion]);
    }
    
    // mix with others
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideCategoryMixWithOthers,
                             sizeof (doSetProperty),
                             &doSetProperty
                             );
    
    
    //Add property listener
    
    //-- end of AudioSession 
    
    
    FLAPI_SetMode(1); // send winMSG
    FLAPI_Init();
    
    
    
}



int	SubSys_Start(){
	bool run = true;
       
	//Update AudioInfo
	if (run && (UpdateAudioInfo()!=FLAPI_SUCCESS))
		run=false;		
	//Openning device
	if (run && (OpenDevice()!=FLAPI_SUCCESS))
		run=false;	
	//Common init
	if (run && (OnSubSystemStart()!=FLAPI_SUCCESS) )
		run=false;
	
	if (! run) {
		printf("Error Cannot start\n");
		return false;
	}
	
	
	//Starting Main loop, called by the AudioQueue		
	OSStatus status = AudioQueueStart(recordState.queue, NULL);
	if ( status != noErr ) {
		printf("Error Starting AudioQueue\n");
		return false;	
	}
    
    stop_possible = true;
    stop_request = false;
    
	printf("Started\n");
    running = true;
	return FLAPI_SUCCESS;
}



int SubSys_Stop(){
    stop_request = true;
    if (stop_possible) {
        return FLAPI_SUBSYS_IOS_SubSys_Stop_Force();
    } 
    
    // we have to wait until the end of OnSubSystemProcess
    NSLog(@"Waiting the end of OnSubSystemProcess to stop FLAPI");

    
    return FLAPI_SUCCESS;
}

int FLAPI_SUBSYS_IOS_SubSys_Stop_Force() {
	if (filedevtag != 0) fclose(filedev); // close file read / saving for devel
	
	OSStatus status = AudioQueueStop(recordState.queue,true);
	if ( status != noErr ) {
		printf("Error Stoping AudioQueue\n");
		return false;	
	}
	
	OnSubSystemStop(); // tell the subsys we stopped
	printf("SubSys_Stop\n");
    running = false;
	return FLAPI_SUCCESS;
}

// called when AudioBuffer is full
// http://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html#//apple_ref/doc/c_ref/AudioQueueBuffer
void AudioInputCallback (
						void *inUserData, // The first parameter is a void pointer that will actually point to our RecordState structure that was passed into AudioQueueNewInput
						AudioQueueRef inAQ, // This is a reference to the audio input queue which is also in our RecordState structure
						AudioQueueBufferRef inBuffer, // This is the buffer that has just been filled. In our case this will contain 1 second worth of audio
						const AudioTimeStamp *inStartTime, // is a timestamp value that can be used to syncronize audio
						UInt32 inNumberPacketDescriptions, // The number of packet descriptions in next parameter (inPacketDescs)
						const AudioStreamPacketDescription *inPacketDescs) // An array of packet descriptions
{
    
    

	short buffSize = 0; 
	
	if ( filedevtag > 0) { // replace buffer by file's data
		buffSize = fread(myBuff,recordState.dataFormat.mBytesPerFrame,gAudioInfo.buffer_sample,filedev);
	
		if (buffSize != gAudioInfo.buffer_sample) {
			printf("BUffsize prob: %i %i\n",buffSize,gAudioInfo.buffer_sample);
		}
		if (feof(filedev)) {
			printf("EOF\n");
            rewind(filedev);
			//SubSys_Stop();
		}
		
	} else { // normal 
		myBuff = (short*)inBuffer->mAudioData; // cast audio data to shorts int
		buffSize = inBuffer->mAudioDataByteSize;
	}
	
	if ( filedevtag < 0) { // save buffer data to fil
		fwrite(myBuff, 1,buffSize, filedev);
		fflush(filedev);
	}

	//we cannot stop during process
    if ((! stop_request) && stop_possible) {
        stop_possible = false;
        if (FLAPI_SUCCESS != OnSubSystemProcess(myBuff)) {
            printf("AudioInputCallback: OnSubSystemProcess failed \n");
        }
        if (stop_request) {
            FLAPI_SUBSYS_IOS_SubSys_Stop_Force();
        }
        stop_possible = true;
    }
    	
	// switch the buffers
	RecordState* recordState = (RecordState*)inUserData;
	AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
	
}

// Init subsystem
int	SubSys_Init(){
	// FLAPI Init
	gDevicesCount = 1;
	gDevicesList = (FLAPI_rDevice *)malloc( gDevicesCount * sizeof(FLAPI_rDevice) ); // just 1 for iOS
	strcpy(gDevicesList[0].name,"iOS input device");
	
	
	FLAPI_ResetParams(); // Set the Params
    
   
	
    
    
    
	printf("SubSys_Init\n");
	return FLAPI_SUCCESS;
}

// Close subsystem
int	SubSys_Close(){
	printf("SubSys_Close\n");
    
    
    
	return FLAPI_SUCCESS;
}


// blow detection
double blow_last_start = 0.0f; // timestamp of the blow detection
double blow_last_freq = 0.0f; // timestamp of the last frequency change event

// duration of "in-range" frequencies 
double blow_in_range_duration = 0.0f; // duration of in-range blowing

// for convience
double blow_timestamp = 0.0f; // temporary timestamp for work on
int blow_frequency_trigger = 5;

// break blowing if too long
double blow_max_duration = 7.0f; //(seconds) when a blowing is declared as invalid because too long

// Internal Subsystem function
// ===========================
//Send windows message kept as-is to be the closest possible to original windows code
//So it just pass usefull events to FLAPIX
int SendWinMsg( int msg, int lparam, int hparam ){
	//NSLog(@"SendWinMsg msg:%i lparam:%i hparam:%i",msg,lparam,hparam);

	switch (msg) {
		case FLAPI_WINMSG_ON_STOP:
			printf("FLAPI_WINMSG_ON_STOP\n");
			break;
		
		case FLAPI_WINMSG_ON_START:
			printf("FLAPI_WINMSG_ON_START\n");
			break;
			
		case FLAPI_WINMSG_ON_ERROR:
			printf("FLAPI_WINMSG_ON_ERROR\n");
			break;
		case FLAPI_WINMSG_ON_LEVEL_CHANGE:
           // NSLog(@"Lev \t %f %f",FLAPI_GetLevel(),gBuffers.gate_stat);
            [flapix EventLevel:FLAPI_GetLevel()];
            
			break;

		case FLAPI_WINMSG_ON_FREQUENCY_CHANGE:
            //NSLog(@"FLAPI_WINMSG_ON_FREQUENCY_CHANGE ");
            [flapix EventFrequency:FLAPI_GetFrequency()];
           
            // coded this quickly because original FLAPI was lacking blow detection.. it seems sufficient but maybe IAV could
            // produce or more academic processing
            blow_timestamp = CFAbsoluteTimeGetCurrent(); // Warning.. date must not be changed during exercice
            if (blow_last_start > 0.0f) { // blowing
                
                // in-range detection occures whiles blowing
                if ((FLAPI_GetFrequency() > (gParams.target_frequency - gParams.frequency_tolerance)) && 
                    (FLAPI_GetFrequency() < (gParams.target_frequency + gParams.frequency_tolerance))) { // in range
                   
                    if (blow_last_freq > 0.0f) // skip first lap
                        blow_in_range_duration += (blow_timestamp - blow_last_freq); // add duration from last frequency
                    
                } else { // not in range
                    
                }
                
                /// -- blow detection, differs from "in-range frequency"
                if (FLAPI_GetFrequency() > blow_frequency_trigger) { // continue
                    //.. blowing
                } else { // stop blowing
                    [flapix EventBlowEnd:blow_last_start duration:(blow_last_freq - blow_last_start) in_range_duration:blow_in_range_duration];
                    blow_last_start = 0.0f;
                }
                
                
                
            } else { // not blowing (blow_last_start == 0)
                if (FLAPI_GetFrequency() > blow_frequency_trigger) { // start blowing
                    blow_last_start = blow_timestamp;
                    [flapix EventBlowStart:blow_last_start];
                    // init blowing vars
                    blow_last_freq = 0.0f;
                    blow_in_range_duration = 0.0f;
                } else { // continue
                    //.. not blowing
                }
            }
            blow_last_freq = blow_timestamp;
            
            break;

		case FLAPI_WINMSG_ON_BLOWING:
			printf("FLAPI_WINMSG_ON_BLOWING\n");
			break;

		case FLAPI_WINMSG_ON_SIGNAL_BUFFER:
			//NSLog(@"FLAPI_WINMSG_ON_SIGNAL_BUFFER \t%i \t%f", FLAPI_GetFrequency(), FLAPI_GetLevel());
			
            // break a blowing session if too long
            if (blow_last_start > 0.0f) { // blowing
                if ((CFAbsoluteTimeGetCurrent() - blow_last_start) > blow_max_duration) {
                    // force stop blowing
                    blow_last_start = 0.0f;
                    // Throw a frequency change to 0.. to 
                    [flapix EventFrequency:0];
                }
                
            }
            
            
			break;

		case FLAPI_WINMSG_ON_DETECTION_BUFFER:
			//NSLog(@"FLAPI_WINMSG_ON_DETECTION_BUFFER");
			break;
					
			
	}
	return FLAPI_SUCCESS;
}


//Open audio device
int OpenDevice(){
	// init the recordState structure from FLAPI settings 
	recordState.dataFormat.mSampleRate = gAudioInfo.sample_rate ; // 8000 to 48000
	recordState.dataFormat.mBitsPerChannel = gAudioInfo.sample_size; // 16bit recording
	recordState.bufferSize =  gAudioInfo.buffer_sample; // .. decrypted
	
	recordState.dataFormat.mFormatID = kAudioFormatLinearPCM;
	recordState.dataFormat.mFramesPerPacket = 1; // Standard with PCM
	recordState.dataFormat.mChannelsPerFrame = gAudioInfo.signal_channel; // mono we are at 1 on iOS
	recordState.dataFormat.mBytesPerFrame = (recordState.dataFormat.mBitsPerChannel>>3) * recordState.dataFormat.mChannelsPerFrame; // 2
	recordState.dataFormat.mBytesPerPacket = recordState.dataFormat.mBytesPerFrame * recordState.dataFormat.mFramesPerPacket;
	recordState.dataFormat.mReserved = 0;
	recordState.dataFormat.mFormatFlags =  kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked; // Little Indian!! 
	
	//Create the audio Queue
	OSStatus status = AudioQueueNewInput(
										 &recordState.dataFormat, 
										 AudioInputCallback, 
										 &recordState,  // parameter allows you to pass a pointer to whatever you want. We will pass a pointer to our RecordState structure
										 NULL, // CFRunLoopGetCurrent(),  // CFRunLoopGetCurrent causes the callback to be called on the main application thread. Passing NULL for this parameter will cause the callback to be called on the audio queue’s internal thread
										 kCFRunLoopCommonModes, // I’m not really sure what this is for. For now I’m content to leave it set to kCFRunLoopCommonModes.
										 0,  // eserved. Must be zero
										 &recordState.queue);  // A pointer to the input audio queue reference in our RecordState structure. This reference will be populated if the call succeeds.
	
	if ( status != noErr ) {
		printf("Error Creating AudioQueue\n");
		return false;	
	}
	
	// Allocate memory for the buffers
	// http://trailsinthesand.com/exploring-iphone-audio-part-2/
	for(int i = 0; i < NUM_BUFFERS; i++)
	{
		AudioQueueAllocateBuffer(recordState.queue, recordState.bufferSize, &recordState.buffers[i]);
		AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, NULL);
	}
	
	
	printf("SubSys_OpenDevice\n");
	return FLAPI_SUCCESS;
}

#pragma  mark PAUSE / START
OSStatus FLAPI_SUBSYS_IOS_Pause() {
    if (recordState.queue == nil || ! running || paused) { return nil; }
    paused = true;
    return AudioQueuePause(recordState.queue );
}

OSStatus FLAPI_SUBSYS_IOS_UnPause() {
    if (recordState.queue == nil || ! running || ! paused) { return nil; }
    printf("FLAPI_SUBSYS_IOS_UnPause\n");
    paused = false;
    return AudioQueueStart(recordState.queue , nil);
}


//Close audio device
int CloseDevice(){
	// Free the device 
	if ( gDevicesList )
		free( gDevicesList );
	printf("SubSys_CloseDevice\n");
	return FLAPI_SUCCESS;
}


