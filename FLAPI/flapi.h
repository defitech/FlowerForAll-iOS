//*************************************************************************************
//								--=	F.L.A.P.I =--
//	   					     flapi.org - 14/09/2010
//*************************************************************************************
#ifndef _FLAPI_H_
#define _FLAPI_H_

// Constantes
#define	FLAPI_MAX_STR_SIZE		512
#define	FLAPI_MAX_LINE_SIZE		1024

//stat
#define	FLAPI_STAT_STOPPED		0
#define	FLAPI_STAT_STARTED		1

//Mode
#define	FLAPI_MODE_NONE			0
#define	FLAPI_MODE_WINMSG		1

// Log
#define	FLAPI_LOG_INFO			0
#define	FLAPI_LOG_WARN			1
#define	FLAPI_LOG_ERROR			2
#define	FLAPI_LOG_DEBUG			3

//Blowig Status
#define	FLAPI_BLOWING_NOT		0
#define	FLAPI_BLOWING_START		1
#define	FLAPI_BLOWING			2
#define	FLAPI_BLOWING_TARGETED	3
#define	FLAPI_BLOWING_END		4

// Windows messages
#define	FLAPI_WINMSG_ON_START				0
#define	FLAPI_WINMSG_ON_STOP				1
#define	FLAPI_WINMSG_ON_ERROR				2
#define	FLAPI_WINMSG_ON_LEVEL_CHANGE		3
#define	FLAPI_WINMSG_ON_FREQUENCY_CHANGE	4
#define	FLAPI_WINMSG_ON_BLOWING				5
#define	FLAPI_WINMSG_ON_SIGNAL_BUFFER		6		
#define	FLAPI_WINMSG_ON_DETECTION_BUFFER	7

// Erreur
#define	FLAPI_SUCCESS			0	//Success
#define	FLAPI_ERR_NOMEM			-1	//Memory leak
#define	FLAPI_ERR_INVARG		-2	//Invalid argument
#define	FLAPI_ERR_INVSTAT		-3	//Invalid stat
#define	FLAPI_ERR_DEV			-4	//Device error
#define	FLAPI_ERR_FILTER		-5  //Filter error

// Stuffs
#define	FLAPI_REFRESH_MIN_INTERVAL		100

// STRUCTURES
// ==========
#pragma pack(push, 1)

// Version
struct FLAPI_rVersion{
	char	name[64];	//Version Name
	int		major;		//Major version number
	int		minor;		//Minor version number
	char	date[128];	//Compilation date
	char	os[32];		//Operating system
	char	author[32]; //Lib author
	char	url[128];	//Extended url
	char	desc[255];	//Lib description
};

// Params
struct FLAPI_rParams{
	int		device_id;				// Device ID	
	int		device_buffer_count;	// Buffer count
	int		device_buffer_duration;	// buffer duration

	double	mic_calibration;
	bool	remove_dc;

	int		signal_duration;
	int		filter_id;
	int		sta_duration;
	int		sta_per_lta;
	int		rta_offset;

	int		frequency_smoothing;
	int		frequency_max;
	int		frequency_min;

	double	threshold;
	int		frequency_tolerance;
	int		target_frequency;
	int		target_duration;


	bool	debug;
};

// Audio info
struct FLAPI_rAudioInfo{
	int		device_id;
	char	device_name[128];
	int		buffer_count;	
	int		buffer_size;
	int		buffer_duration;
	int		buffer_sample;
	int		signal_channel;
	int		signal_size;
	int		signal_duration;
	int		signal_sample;
	int		signal_buffer_count;
	int		signal_sta_count;
	int		sample_rate;
	int		sample_size;
	int		sample_bytes;
	int		sample_per_ms;
	int		sample_max;
	int		sta_duration;	
	int		sta_sample;
	int		lta_duration;
	int		lta_sample;
	int		sta_per_lta;
	int		rta_offset;
	int		rta_offset_duration;
	int		rta_offset_sample;
	double	calibration;	
	int		refresh_detection_buffer;
	int		period_max_sample;
	int		period_min_sample;
};


struct FLAPI_rTimers{
	long	sample_counter;
	int		refresh_detection_count;
	int		refresh_freq_count;
	bool	pulse_stat;
	long	pulse_origin;
	long	pulse_sample;
	long	pulse_tick;
	long	prev_tick;
	int		*freq_smoother;
	int		prev_frequency;
};	

struct FLAPI_rDevice{
	char	name[128];	
};

struct FLAPI_rBuffers{	
	int		bloc;	
	short	*raw;
	double	*norm;
	double	*filter;
	double	*gate;
	double	gate_stat;
	double	sum;
	int		win;
	int		id;
	double	*sta_lin;
	double	*sta_db;
	double	*lta_lin;
	double	*lta_db;
	double	*rta_lin;
	double	*rta_db;
};

struct FLAPI_rFilterBank {
	bool			enabled;
	char			title[128];
	double			*a;
	long			na;
	double			*b;
	long			nb;
};

struct FLAPI_rFilterInfo{
	FLAPI_rFilterBank				params;
	long							count;
	long							*ind_a;
	long							*ind_b;
	long							*ind_va;
	long							*ind_vb;
	double							*v;
	double							*in;
	double							*out;
	bool							first_frag;	
};


struct FLAPI_rBlowInfo{
	int		status;	
	int		blow_count;
	int		blowing_duration;	
	int		frequency;		
	double	level;
};

#pragma pack(pop)

// COMMON
// ======


void FLAPI_GetVersion(struct FLAPI_rVersion *version ); 

// CONTROL
// ========

int	FLAPI_Init();
int	FLAPI_Exit();
int	FLAPI_Start();
int	FLAPI_Stop();

#ifdef	WIN32
#include <windows.h>
int FLAPI_SetWinMsgCfg( HWND hWnd, int msgBase );
#endif

int	FLAPI_SetMode(int mode);
int	FLAPI_GetStatus();
int	FLAPI_GetLastError(char *comment);

// PARAMS
// ======

int		FLAPI_GetParams( FLAPI_rParams *params );
int		FLAPI_SetParams( FLAPI_rParams *params );
int		FLAPI_ResetParams();

int		FLAPI_GetAudioInfo( FLAPI_rAudioInfo *info );
bool	FLAPI_GetFiltersList( FLAPI_rFilterBank **filters, int *count );

int		FLAPI_SetDevice( int deviceID );
int		FLAPI_GetDevice();

int		FLAPI_SetThreshold( double threshold );
double	FLAPI_GetThreshold();

int		FLAPI_SetBlowCount( int count );
int		FLAPI_GetBlowCount();

int		FLAPI_SetTargetFrequency( int freq, int tolerance );
double		FLAPI_GetTargetFrequency();
double		FLAPI_GetFrequencyTolerance();

int		FLAPI_SetTargetBlowingDuration( int duration );
int		FLAPI_GetTargetBlowingDuration();

bool	FLAPI_IsBlowingTargeted();
bool	FLAPI_IsBlowing();

int		FLAPI_GetBlowingDuration();
int		FLAPI_GetBlowingStatus();
double		FLAPI_GetFrequency();
double	FLAPI_GetLevel();
double	FLAPI_GetLevelMax();


// TOOLS
// ======

int	FLAPI_GetDevicesList( FLAPI_rDevice **devices, int *count );
int	FLAPI_GetDeviceName(int deviceID, char *name);


int	FLAPI_GetBuffers( FLAPI_rBuffers *buffers );







#endif