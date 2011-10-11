/*
 *  subsys_ios.h
 *  FLAPI
 *
 *  Created by Pierre-Mikael Legris (Perki) on 08.03.11.
 *  Copyright 2011 fondation Defitech All rights reserved.
 *
 * Make a Lib
 * http://blog.stormyprods.com/2008/11/using-static-libraries-with-iphone-sdk.html
 */
#ifdef __APPLE__
#ifndef _SUBSYS_IOS_H_
#define _SUBSYS_IOS_H_

#include "common.h"
#include "flapi.h"

#import "FLAPIX.h"
#import "subsys_ios_AVAudioSessionDelegate.h"

#include <AudioToolbox/AudioToolbox.h>
#define NUM_BUFFERS 3


#define DEBUG_SAVE_BUFFER 0
#define DEBUG_READ_FROM_FILE 1

typedef struct
{
    AudioStreamBasicDescription dataFormat; //is a structure that defines the format of the audio data to be captured. This structure is used to set the sample rate, mono vs. stereo, etc.
    AudioQueueRef queue; //is a reference to the audio input queue that we’ll initialize later. All subsequent audio API calls used for recording will reference this queue.
    AudioQueueBufferRef buffers[NUM_BUFFERS]; //is an array of buffers that audio data will be written to.
	UInt32 bufferSize; // bufferSize
} RecordState;

// Structure used for IO Monitoring
#define NUM_IO_BUFFERS 20
typedef struct
{
    bool playBackIsOn; // The user want's playback
    
    bool isPlaying; // Inidicate if Player is On
    float playBackVolume; // PlayBack Volume
    AudioQueueRef queue; // reference to the used Audio Queue
    short bufferSize; // number of samples
    short bufferByteSize; // number of samples * size of each one
    
    
    short* buff[NUM_IO_BUFFERS]; // Buffers that keeps I/O sound
    short buffSize[NUM_IO_BUFFERS]; // Quantity to read for each buffer
    int next_to_read ; // pointer to the next buffer to read
    int next_to_write ; // pointer to the next buffer to write
} IOState;


// Custom (Differ from windows FLAPI) Subsystem start for devel
void FLAPI_SUBSYS_IOS_file_dev(const char* filepath,bool read);

// Custom  (Differ from windows FLAPI) Register the FLAPIX Controller instance
void FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(FLAPIX *flapix);

double FLAPI_SUBSYS_IOS_get_current_blow_in_range_duration();

// Custom  PlayBack .. Set Volume to 0 to Stop PlayBack
void FLAPI_SUBSYS_IOS_SET_PlayBackVolume(float volume);
float FLAPI_SUBSYS_IOS_GET_PlayBackVolume() ;


#pragma  mark PAUSE / START
OSStatus FLAPI_SUBSYS_IOS_Pause();
OSStatus FLAPI_SUBSYS_IOS_UnPause();

// Standard Subsystem function
// ===========================

int	SubSys_Init();
int	SubSys_Start();
int	SubSys_Stop();
int	SubSys_Close();


// Internal Subsystem function
// ===========================

int SendWinMsg( int msg, int lparam, int hparam );

int	OpenDevice();
int	CloseDevice();

void io_init();
void io_check_state();
void io_stop();
void io_push_buff_for_playback(short* buffer,short buffSize);
void io_pop_buff_for_playback(AudioQueueBufferRef buffer);

BOOL checkMicrophonePluggedIn ();

#endif
#endif