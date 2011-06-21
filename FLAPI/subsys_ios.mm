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

RecordState recordState;

// use to read / write data used in developppement stages
FILE *filedev;
// tag if we are reading from filedev 0=none 1=reading -1=writing
int filedevtag = 0;

// The Buffer to work on;
short *myBuff;

// reference to pass events
FLAPIX *flapix;

// Standard Subsystem function
// ===========================

/**
 * set the system to read or save a file, used in dev mode
 * you must call FLAPI_Start() after that
 *
 * const char* torecord = [[NSTemporaryDirectory() stringByAppendingPathComponent: @"FLAPIrecord.raw"] UTF8String];
 * const char* toread = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"FLAPIrecorded.raw"] UTF8String];
 *
 */
void FLAPI_SUBSYS_IOS_file_dev(const char* filepath,bool read){
	filedev = fopen(filepath, read ? "rb" : "wb");
	if (read) myBuff = (short*) malloc (sizeof(short)*gAudioInfo.buffer_sample);
	filedevtag = read ? 1 : -1;
	
	printf(read ? "Reading data to file %s\n" : "Writing data to file %s\n",filepath);
}

void FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(FLAPIX *owner){
    flapix = owner;
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
	printf("Started\n");
	return FLAPI_SUCCESS;
}

int	SubSys_Stop(){
	if (filedevtag != 0) fclose(filedev); // close file read / saving for devel
	
	OSStatus status = AudioQueueStop(recordState.queue,true);
	if ( status != noErr ) {
		printf("Error Stoping AudioQueue\n");
		return false;	
	}
	
	OnSubSystemStop(); // tell the subsys we stopped
	
	printf("SubSys_Stop\n");
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

	
	if (FLAPI_SUCCESS != OnSubSystemProcess(myBuff)) {
		printf("AudioInputCallback: OnSubSystemProcess failed \n");
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
                    blow_in_range_duration = 0.0f;
                }
                
                
                
            } else { // not blowing
                if (FLAPI_GetFrequency() > blow_frequency_trigger) { // start blowing
                    blow_last_start = blow_timestamp;
                    [flapix EventBlowStart:blow_last_start];
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

//Close audio device
int CloseDevice(){
	// Free the device 
	if ( gDevicesList )
		free( gDevicesList );
	printf("SubSys_CloseDevice\n");
	return FLAPI_SUCCESS;
}


