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
IOState ioState;

// use to read / write data used in developppement stages
FILE *filedev;
// tag if we are reading from filedev 0=none 1=reading -1=writing
int filedevtag = 0;

// The Buffer to work on;
short *myBuff;
short *waitingBooth; // buffer that wait to be filled up to 480 to be given to OnSubSystemProcess
short waitingBoothPointer; // where we are ..

// reference to pass events
FLAPIX *flapix;

bool stop_request = false; // we are waiting for a stop
bool stop_possible = true; // flag passed to true when OnSubSystemProcess


bool running = false;
bool paused = false;


// Standard Subsystem function
// ===========================

#pragma  mark PAUSE / START
OSStatus FLAPI_SUBSYS_IOS_Pause() {
    if (recordState.queue == nil || ! running || paused) { return nil; }
    paused = true;
    
    if (ioState.isPlaying) AudioQueuePause(ioState.queue);
    
    return AudioQueuePause(recordState.queue );
}

OSStatus FLAPI_SUBSYS_IOS_UnPause() {
    if (recordState.queue == nil || ! running || ! paused) { return nil; }
    printf("FLAPI_SUBSYS_IOS_UnPause\n");
    
    if (ioState.isPlaying) AudioQueueStart(ioState.queue,nil);
    
    paused = false;
    return AudioQueueStart(recordState.queue , nil);
}

# pragma mark START / STOP



// Init subsystem
int	SubSys_Init(){
	// FLAPI Init
	gDevicesCount = 1;
	gDevicesList = (FLAPI_rDevice *)malloc( gDevicesCount * sizeof(FLAPI_rDevice) ); // just 1 for iOS
	strcpy(gDevicesList[0].name,"iOS input device");
	
	FLAPI_ResetParams(); // Set the Params
    
    io_init(); // Init the ioState for Playback
    
    waitingBooth = (short*) malloc (sizeof(short)*gAudioInfo.buffer_sample);
    waitingBoothPointer = 0;
    
	printf("SubSys_Init\n");
	return FLAPI_SUCCESS;
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
    
    io_check_state() ; // start playback if needed
    
	return FLAPI_SUCCESS;
}


/** (internal) really do the stop when possible **/
int _Stop_Force() {
	if (filedevtag != 0) fclose(filedev); // close file read / saving for devel
	
    io_stop() ; // stop playback (if any)
    
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


int SubSys_Stop(){
    stop_request = true;
    if (stop_possible) {
        return _Stop_Force();
    } 
    
    // we have to wait until the end of OnSubSystemProcess
    NSLog(@"Waiting the end of OnSubSystemProcess to stop FLAPI");
    
    return FLAPI_SUCCESS;
}


// Close subsystem
int	SubSys_Close(){
	printf("SubSys_Close\n");
	return FLAPI_SUCCESS;
}


# pragma mark I/O detection and management

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

# pragma mark INIT IOS SPECIFIC CALL

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




# pragma mark Internal Subsystem functions



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
       
		if (feof(filedev)) {
			printf("EOF\n");
            rewind(filedev);
		}
		
	} else { // normal 
		myBuff = (short*)inBuffer->mAudioData; // cast audio data to shorts int
		buffSize = inBuffer->mAudioDataByteSize / recordState.dataFormat.mBytesPerFrame;
	}
	
	if ( filedevtag < 0) { // save buffer data to fil
		fwrite(myBuff, 1,buffSize, filedev);
		fflush(filedev);
	}
    
    //copy the buffer to the play_back
    if (ioState.isPlaying) io_push_buff_for_playback(myBuff,buffSize);
    
	//we cannot stop during process, so we have handle stops as soon as their prossible
    if ((! stop_request) && stop_possible) {
        stop_possible = false;
        
        // to be sure we give 480 - sized buffers to the FLAPI Process
        for (int i = 0; i < buffSize; i++) {
            waitingBooth[waitingBoothPointer] = myBuff[i];
            waitingBoothPointer++;
            if (waitingBoothPointer == gAudioInfo.buffer_sample) {
                 if (FLAPI_SUCCESS != OnSubSystemProcess(waitingBooth)) 
                     printf("AudioInputCallback: OnSubSystemProcess failed \n");
                waitingBoothPointer = 0;
            }
        }
        
        
    
        if (stop_request) {
            _Stop_Force();
        }
        stop_possible = true;
    }
    
	// switch the buffers
	RecordState* recordState = (RecordState*)inUserData;
	AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);	
}


// blow detection
double blow_last_start = 0.0f; // timestamp of the blow detection
double blow_last_freq = 0.0f; // timestamp of the last frequency change event

// duration of "in-range" frequencies 
double blow_in_range_duration = 0.0f; // duration of in-range blowing

// for convience
double blow_timestamp = 0.0f; // temporary timestamp for work on


// break blowing if too long
double blow_max_duration = 30.0f; //(seconds) when a blowing is declared as invalid because too long

float blow_frequency_trigger = 0.0f;

// Internal Subsystem function
// ===========================
//Send windows message kept as-is to be the closest possible to original windows code
//So it just pass usefull events to FLAPIX
int SendWinMsg( int msg, int lparam, int hparam ){
	//NSLog(@"SendWinMsg msg:%i lparam:%i hparam:%i",msg,lparam,hparam);
    blow_frequency_trigger = gParams.target_frequency - gParams.frequency_tolerance - 2 ;

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
           
            // blow_frequency_trigger is normaly 7 .. but we lower it in case minFrequency -2 is lower
            
            if (blow_frequency_trigger > 7) blow_frequency_trigger = 7;
            NSLog(@"blow_frequency_trigger %f",blow_frequency_trigger);
            
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
                if (FLAPI_GetFrequency() >= blow_frequency_trigger) { // continue
                    //.. blowing
                } else { // stop blowing
                    [flapix EventBlowEnd:blow_last_start duration:(blow_last_freq - blow_last_start) in_range_duration:blow_in_range_duration];
                    blow_last_start = 0.0f;
                    
            
                }
                
            } else { // not blowing (blow_last_start == 0)
                if (FLAPI_GetFrequency() >= blow_frequency_trigger) { // start blowing
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

# pragma mark DEVEL UTILS

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
    // may cause memory leak.. when using a lot Demo modes.. but we do not care..
	if (read ) myBuff = (short*) malloc (sizeof(short)*gAudioInfo.buffer_sample);
	filedevtag = read ? 1 : -1;
	
	printf(read ? "Reading data to file %s\n" : "Writing data to file %s\n",filepath);
}



# pragma mark OPEN / CLOSE

//Open audio device
int OpenDevice(){
	// init the recordState structure from FLAPI settings 
	recordState.dataFormat.mSampleRate = gAudioInfo.sample_rate ; // 48000
	recordState.dataFormat.mBitsPerChannel = gAudioInfo.sample_size; // 16
	recordState.bufferSize =  gAudioInfo.buffer_sample * gAudioInfo.sample_bytes; // .. decrypted  480 x 2
	
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


//Close audio device
int CloseDevice(){
	// Free the device 
	if ( gDevicesList )
		free( gDevicesList );
	printf("SubSys_CloseDevice\n");
	return FLAPI_SUCCESS;
}

# pragma mark PLAYBACK
// ----------------------- audio output for feedback --------------------------- //

// AudioQueue output queue callback.
void AudioEngineOutputBufferCallback (void *inUserData, AudioQueueRef queue, AudioQueueBufferRef buffer) {
    OSStatus err;
    if (ioState.isPlaying == YES) {
        io_pop_buff_for_playback(buffer);
        err = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
        if (err == 560030580) { // Queue is not active due to Music being started or other reasons
            io_stop();
             NSLog(@"AudioQueueEnqueueBuffer() STOPED PLAYING");
        } else if (err != noErr) {
            NSLog(@"AudioQueueEnqueueBuffer() error %d", (int)err);
        }
    } else {
        io_stop();
    }
}


// Custom  PlayBack Stop

void FLAPI_SUBSYS_IOS_SET_PlayBack(BOOL on) {
    ioState.playBackIsOn = on ;
    io_check_state();
}

BOOL FLAPI_SUBSYS_IOS_GET_PlayBack_State() {
    return ioState.playBackIsOn;
}

void io_stop() {
    if (ioState.isPlaying == YES) {
        OSStatus err = AudioQueueStop (ioState.queue, NO);
        if (err != noErr) NSLog(@"AudioQueueStop() error: %d",  (int)err);
    }
    ioState.isPlaying = NO;
}

void io_check_state() {
    if (ioState.isPlaying && ! ioState.playBackIsOn ) { //STOP any eventual playBack 
        io_stop();
        return;
    }
    if (ioState.isPlaying && ioState.playBackIsOn ) { // RUNNING AND OK 
        return;
    }
    // needs to start
    OSStatus err = noErr; 
    if (ioState.isPlaying == NO) {
        // New output queue ---- PLAYBACK ----
        err = AudioQueueNewOutput(&recordState.dataFormat, AudioEngineOutputBufferCallback, nil, nil, nil, 0, &ioState.queue);
        if (err != noErr) printf("AudioQueueNewOutput() error: %d \n",  (int)err);
        
        NSLog(@"buff sizes %i %i",ioState.bufferSize,ioState.bufferByteSize);
        
        AudioQueueBufferRef buffers[NUM_BUFFERS];
        for (int i=0; i<NUM_BUFFERS; i++) {
            err = AudioQueueAllocateBuffer (ioState.queue, ioState.bufferByteSize, &buffers[i]); 
            if (err == noErr) {
                io_pop_buff_for_playback(buffers[i]);
                err = AudioQueueEnqueueBuffer (ioState.queue, buffers[i], 0, nil);
                if (err != noErr) NSLog(@"AudioQueueEnqueueBuffer() error A: %d",  (int)err);
            } else {
                NSLog(@"AudioQueueAllocateBuffer() error B: %d",  (int)err); 
                return;
            }
        }
        
        ioState.isPlaying = YES;
        err = AudioQueueStart(ioState.queue, nil);
        
        if (err != noErr) { 
            printf("AudioQueueStart() error: %ld\n", err); 
            io_stop(); 
            return; 
        }
        NSLog(@"PlayBack initialized");
    } else {
        NSLog (@"Error: audio is already playing back.");
    }    
}

// Called by SubSys_init;
void io_init() {
    ioState.playBackIsOn = YES;
    ioState.isPlaying = NO;
    ioState.next_to_read = -1;
    ioState.next_to_write = 0;
    ioState.bufferSize = gAudioInfo.buffer_sample;
    ioState.bufferByteSize = sizeof(short)*ioState.bufferSize;
    for (int i = 0; i < NUM_IO_BUFFERS ; i++) {
        ioState.buff[i] = (short*) malloc (ioState.bufferByteSize);
        ioState.buffSize[i] = 0;
    }
}

void io_push_buff_for_playback(short* buffer,short buffSize) {
    int writing = ioState.next_to_write; // lock the one we want to write
    if ((ioState.next_to_write + 1) == NUM_IO_BUFFERS) { ioState.next_to_write = 0; } else { ioState.next_to_write++; }
    //printf(" w:%i s:%i     r:%i\n",writing,buffSize, ioState.next_to_read);
    ioState.buffSize[writing] =  buffSize;
    for (int i = 0; i < buffSize; i++) {
        ioState.buff[writing][i] = buffer[i];
    }
    
    if (ioState.next_to_read < 0) ioState.next_to_read = writing; // unlock reading ...
    
}



void io_pop_buff_for_playback(AudioQueueBufferRef buffer) {
    short *p = (short*)buffer->mAudioData;
    int dstBuffSize = buffer->mAudioDataBytesCapacity / sizeof(short);
    
    if (ioState.next_to_read < 0 || ioState.buffSize[ioState.next_to_read] <= 0) {
        // fill buff with whites and return
        for (int i = 0; i < dstBuffSize; i++) p[i] = 0 ;
        buffer->mAudioDataByteSize = dstBuffSize * sizeof (short);
        return;
    }
    
    int reading = ioState.next_to_read;
    if ((ioState.next_to_read + 1) == NUM_IO_BUFFERS) { ioState.next_to_read = 0; } else { ioState.next_to_read++; } // increase next_to_read
    int srcBuffSize = ioState.buffSize[reading];  
    
    //printf(" r:%i ss:%i ds:%i    w:%i\n",reading,srcBuffSize,dstBuffSize, ioState.next_to_write);
    int buffSize = srcBuffSize < dstBuffSize ? srcBuffSize : dstBuffSize; // we loose data if one of the buffer is smaller
    for (int i = 0; i < buffSize; i++) {
        p[i] = ioState.buff[reading][i] ;
    }
    buffer->mAudioDataByteSize = buffSize * sizeof (short);
    // mark buffer as read;
    ioState.buffSize[reading] = 0;
}


