#ifndef _FILTER_H_
#define _FILTER_H_

#include	<stdio.h>
#include	<stdlib.h>
#include	"common.h"
#include	"flapi.h"


//Bank
int Filter_InitBanks();

//Raw filtering tools
int Filter_Init(struct FLAPI_rFilterInfo *filter, int index, long count);
int Filter_Free(struct FLAPI_rFilterInfo *filter);
int Filter_ProcessBuffer(struct FLAPI_rFilterInfo *filter, double *input, double *output);
int Filter_RemoveDC(double *input, long count);

//Automated realtime filtering
int Filter_InitFragment(struct FLAPI_rFilterInfo *filter, int index, long count);
int Filter_ProcessFragment(struct FLAPI_rFilterInfo *filter, double *input, double *output);
int Filter_ProcessFirstFragment(struct FLAPI_rFilterInfo *filter, double *input, double *output);
int Filter_ProcessNextFragment(struct FLAPI_rFilterInfo *filter, double *input, double *output);

#endif