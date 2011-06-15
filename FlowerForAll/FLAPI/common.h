#ifndef _COMMON_H_
#define _COMMON_H_

// Windows 32
#ifdef		WIN32
	#define		WIN32_LEAN_AND_MEAN
	#include	<windows.h>
	#pragma comment(lib, "winmm.lib" )
	#include	<mmsystem.h>		
	#define		FLAPI_VERSION_OS		"Win32"	
	#include	"subsys_win.h"
#endif

#ifdef __APPLE__
	#define		FLAPI_VERSION_OS		"Apple"
	#include	"subsys_ios.h"
#endif

#ifdef __LINUX__
	#define		FLAPI_VERSION_OS		"Linux"
#endif

									
// Utils
#include    <string.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<stdarg.h>
#include	<math.h>

#include	"flapi.h"
#include	"filter.h"

// INTERNAL CONSTANTS
// ==================

#define	FLAPI_VERSION_NAME		"FLAPI"
#define	FLAPI_VERSION_MAJOR		2
#define	FLAPI_VERSION_MINOR		9
#define	FLAPI_VERSION_AUTOR		"flapi.org"
#define	FLAPI_VERSION_URL		"http://www.flapi.org"
#define	FLAPI_VERSION_DESC		"Flutter acoustic managment API"

// GLOBALS VARIABLES
// =================

// Params
extern struct FLAPI_rParams			gParams;
extern struct FLAPI_rAudioInfo		gAudioInfo;
extern struct FLAPI_rBuffers		gBuffers;
extern struct FLAPI_rFilterInfo		gFilter;
extern struct FLAPI_rTimers			gTimers;
extern struct FLAPI_rBlowInfo		gBlowInfo;
extern int							gMode;
extern int							gStatus;

// Devices list
extern struct FLAPI_rDevice			*gDevicesList;
extern int							gDevicesCount;

// Filter List
extern	struct FLAPI_rFilterBank		*Filter_Banks;
extern	long							Filter_BanksCount;

//Last error
extern int							gLastErrNum;
extern char							gLastErrMsg[256];

// TOOLS
// =====

int		UpdateAudioInfo();
int		CheckAudioInfo();
int		SetError( int num, char *msg);


// EVENT HANDLER
// =============

void EventOnError();
void EventOnStart();
void EventOnStop();
void EventOnSignalBuffer();
void EventOnDetectionBuffer();

void EventOnLevelChange();
void EventOnFrequencyChange();
void EventOnBlowing();


// EVENT SUBSYSTEM
// ================


int OnSubSystemStart();
int OnSubSystemStop();
int OnSubSystemProcess(short *buffer);


double ComputePreviousLta(double *sta_lin, long sta_count, long idx, long count);	
double ComputeMaxPreviousLta(double *lta_lin, long sta_count, long idx, long count);

int SmoothFrequency(int freq);

// Windows 32
#ifdef		WIN32
  int round(double d);
#endif// Windows 32

#endif
