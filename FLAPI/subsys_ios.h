/*
 *  subsys_ios.h
 *  FLAPI
 *
 *  Created by Pierre-Mikael Legris on 08.03.11.
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


// Custom (Differ from windows FLAPI) Subsystem start for devel
void FLAPI_SUBSYS_IOS_file_dev(const char* filepath,bool read);

// Custom  (Differ from windows FLAPI) Register the FLAPIX Controller instance
void FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(FLAPIX *flapix);

int FLAPI_SUBSYS_IOS_SubSys_Stop_Force();

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

#endif
#endif