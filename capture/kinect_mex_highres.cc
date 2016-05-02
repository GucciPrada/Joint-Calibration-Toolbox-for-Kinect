/*
* This is demo code by Alex Berg (c) 2010 and is adapted from and relies on
* code in the OpenKinect Project. http://www.openkinect.org
* Copyright (c) 2010 individual OpenKinect contributors. See the end of this file
* for details.
*
* This code is licensed to you under the terms of the Apache License, version
* 2.0, or, at your option, the terms of the GNU General Public License,
* version 2.0. See the APACHE20 and GPL2 files for the text of the licenses,
* or the following URLs:
* http://www.apache.org/licenses/LICENSE-2.0
* http://www.gnu.org/licenses/gpl-2.0.txt
*
* If you redistribute this file in source form, modified or unmodified, you
* may:
*   1) Leave this header intact and distribute it under the same terms,
*      accompanying it with the APACHE20 and GPL20 files, or
*   2) Delete the Apache 2.0 clause and accompany it with the GPL2 file, or
*   3) Delete the GPL v2 clause and accompany it with the APACHE20 file
* In all cases you must keep the copyright notice intact and include a copy
* of the CONTRIB file.
*
* Binary distributions must follow the binary distribution requirements of
* either License.
*/

//
// See acberg.com/kinect for more information.
//
//
// COMPILING THE MEX FILE:
//
//  can compile the mex function from matlab with something like:
//
// mex  -I/Users/aberg/work/kinect/libfreenect/include -I/Users/aberg/work/kinect/libfreenect/examples/../wrappers/c_sync  -I/usr/local/include lib/libfreenect.0.0.1.dylib /usr/local/lib/libusb-1.0.dylib kinect_mex.cc
//
//
//  modify the paths as needed (especially to  libfreenect)
//
//



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "libfreenect.h"
#include <pthread.h>
#include <math.h>
typedef uint16_t char16_t;
#include "mex.h"

//#define KINECT_VERBOSE
//#define ENABLE_REGISTRATION
#define RGB_HIGH_RES


#ifdef RGB_HIGH_RES
#define RGB_WIDTH 1280
#define RGB_HEIGHT 1024
#define ROWS 3932160
#define COLUMNS 1
#define ELEMENTS 3932160
#else
#define RGB_WIDTH 640
#define RGB_HEIGHT 480
#define ROWS 307200
#define COLUMNS 1
#define ELEMENTS 307200
#endif

// 640 480
#define DROWS 307200
#define DCOLUMNS 1
#define DELEMENTS 307200
// DEPTH_MAX_RAW_VALUE


#ifdef ENABLE_REGISTRATION
#include "libfreenect-registration.h"
#endif

pthread_t freenect_thread;

volatile int die = 0;

pthread_mutex_t gl_backbuf_mutex = PTHREAD_MUTEX_INITIALIZER;

// back: owned by libfreenect (implicit for depth)
// mid: owned by callbacks, "latest frame ready"
// front: ready to copy to matlab variables

uint16_t *depth_mid, *depth_front;
uint8_t *rgb_back, *rgb_mid, *rgb_front;
#ifdef ENABLE_REGISTRATION
#define DEPTH_MAX_RAW_VALUE 2048
#endif

freenect_context *f_ctx;
freenect_device *f_dev;
int freenect_angle = 0;
int freenect_led;

freenect_video_format requested_format = FREENECT_VIDEO_RGB;
freenect_video_format current_format = FREENECT_VIDEO_RGB;

pthread_cond_t gl_frame_cond = PTHREAD_COND_INITIALIZER;
int got_rgb = 0;
int got_depth = 0;

int g_state=0;

void print_usage()
{
	printf("usage simple_kinect_mex( [ c ] )  where c is an optional character:\n");
	printf("'' init or get depth and color image\n");
	printf("'q' stop kinect thread\n");
	printf("'w' angle kinect up\n");
	printf("'x' angle kinect down\n");
	printf("'s' level kinect\n");
	printf("'R' video format RGB (default)");
	printf("'Y' video format YUV_RGB");
	printf("'I' video format IR");
	printf("'1' set kinect led GREEN\n");
	printf("'2' set kinect led RED\n");
	printf("'3' set kinect led YELLOW\n");
	printf("'4' set kinect led BLINK YELLOW\n");
	printf("'5' set kinect led BLINK GREEN\n");
	printf("'6' set kinect led BLINK RED YELLOW\n");
	printf("'7' set kinect led OFF\n");
	printf("---------------------------------------\n");
}



void Update()
{
	pthread_mutex_lock(&gl_backbuf_mutex);
	// When using YUV_RGB mode, RGB frames only arrive at 15Hz, so we shouldn't force them to draw in lock-step.
	// However, this is CPU/GPU intensive when we are receiving frames in lockstep.
	if (current_format == FREENECT_VIDEO_YUV_RGB) {
		while (!got_depth && !got_rgb) {
			pthread_cond_wait(&gl_frame_cond, &gl_backbuf_mutex);
		}
	} else {
		while ((!got_depth || !got_rgb) && requested_format != current_format) {
			pthread_cond_wait(&gl_frame_cond, &gl_backbuf_mutex);
		}
	}

	if (requested_format != current_format) {
		pthread_mutex_unlock(&gl_backbuf_mutex);
		return;
	}

	void *tmp;

	if (got_depth) {
		tmp = depth_front;
		depth_front = depth_mid;
		depth_mid = (uint16_t*)tmp;
		got_depth = 0;
	}
	if (got_rgb) {
		tmp = rgb_front;
		rgb_front = rgb_mid;
		rgb_mid = (uint8_t*)tmp;
		got_rgb = 0;
	}

	pthread_mutex_unlock(&gl_backbuf_mutex);
}


uint16_t t_gamma[2048];

void depth_cb(freenect_device *dev, void *v_depth, uint32_t timestamp)
{
	int i;
	uint16_t *depth = (uint16_t*)v_depth;

	pthread_mutex_lock(&gl_backbuf_mutex);
	for (i=0; i<640*480; i++) {
		depth_mid[i] = depth[i];
	}
	got_depth++;
	pthread_cond_signal(&gl_frame_cond);
	pthread_mutex_unlock(&gl_backbuf_mutex);
}

void rgb_cb(freenect_device *dev, void *rgb, uint32_t timestamp)
{
	pthread_mutex_lock(&gl_backbuf_mutex);

	// swap buffers
	assert (rgb_back == rgb);
	rgb_back = rgb_mid;
	freenect_set_video_buffer(dev, rgb_back);
	rgb_mid = (uint8_t*)rgb;

	got_rgb++;
	pthread_cond_signal(&gl_frame_cond);
	pthread_mutex_unlock(&gl_backbuf_mutex);
}

void *freenect_threadfunc(void *arg)
{
#ifdef KINECT_VERBOSE
	printf("Initializing...\n");
#endif // KINECT_VERBOSE
	freenect_set_tilt_degs(f_dev,freenect_angle);
#ifdef KINECT_VERBOSE
	printf("Step 1: set tilt degrees--finished\n");
#endif // KINECT_VERBOSE

	freenect_set_led(f_dev,LED_RED);
#ifdef KINECT_VERBOSE
	printf("Step 2: set LED--finished\n");
#endif // KINECT_VERBOSE
	fflush(stdout);
	freenect_set_depth_callback(f_dev, depth_cb);
	freenect_set_video_callback(f_dev, rgb_cb);
	freenect_set_video_mode(f_dev, freenect_find_video_mode(FREENECT_RESOLUTION_HIGH, current_format));
	freenect_set_depth_mode(f_dev, freenect_find_depth_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_DEPTH_11BIT));
	freenect_set_video_buffer(f_dev, rgb_back);
#ifdef KINECT_VERBOSE
	printf("Step 3: set mode/callback/buffer--finished\n");


#endif // KINECT_VERBOSE	

#ifdef KINECT_VERBOSE
	// printf("I am here");
#endif // KINECT_VERBOSE

	freenect_start_depth(f_dev);
	freenect_start_video(f_dev);
#ifdef KINECT_VERBOSE
	// printf("I am here2");
	printf("'w'-tilt up, 's'-level, 'x'-tilt down, '0'-'6'-select LED mode, 'f'-video format\n");
#endif // KINECT_VERBOSE


	while (!die && freenect_process_events(f_ctx) >= 0) {
		//#ifdef KINECT_VERBOSE
			//printf("I am here3");
		//#endif // KINECT_VERBOSE
		freenect_raw_tilt_state* state;
		freenect_update_tilt_state(f_dev);
		state = freenect_get_tilt_state(f_dev);
		double dx,dy,dz;
		freenect_get_mks_accel(state, &dx, &dy, &dz);
		//		printf("\r raw acceleration: %4d %4d %4d  mks acceleration: %4f %4f %4f", state->accelerometer_x, state->accelerometer_y, state->accelerometer_z, dx, dy, dz);
		fflush(stdout);


		if (requested_format != current_format) {
			freenect_stop_video(f_dev);
			freenect_set_video_mode(f_dev, freenect_find_video_mode(FREENECT_RESOLUTION_MEDIUM, requested_format));
			freenect_start_video(f_dev);
			current_format = requested_format;
		}
	}

#ifdef KINECT_VERBOSE
	printf("shutting down streams...\n");
#endif // KINECT_VERBOSE		

	freenect_stop_depth(f_dev);
	freenect_stop_video(f_dev);

	freenect_close_device(f_dev);
	freenect_shutdown(f_ctx);

#ifdef KINECT_VERBOSE
	printf("-- done!\n");
#endif // KINECT_VERBOSE		
	
	g_state=0;
	die = 0;
	return NULL;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	uint16_t *depth_data;
	uint8_t *rgb_data; 
	mwSize index;


	/* Check for proper number of arguments. */

	depth_data = (uint16_t*)mxCalloc(DELEMENTS, sizeof(uint16_t));
	rgb_data = (uint8_t*)mxCalloc(ELEMENTS, sizeof(uint8_t));
	//    for ( index = 0; index < ELEMENTS; index++ ) {
	//        dynamicData[index] = data[index];
	//    }

	plhs[0] = mxCreateNumericMatrix(0, 0, mxUINT16_CLASS, mxREAL);
	plhs[1] = mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);

	mxSetData(plhs[0], depth_data);
	mxSetM(plhs[0], DROWS);
	mxSetN(plhs[0], DCOLUMNS);

	mxSetData(plhs[1], rgb_data);
	mxSetM(plhs[1], ROWS);
	mxSetN(plhs[1], COLUMNS);

#ifdef ENABLE_REGISTRATION
	const char *field_names[] = { "reference_distance", "reference_pixel_size", "raw_to_mm_shift" };
	plhs[2] = mxCreateStructMatrix(1, 1, 3, field_names);

	/*mxSetFieldByNumber(plhs[2], 0, 0, mxCreateString("test"));
	mxArray* ref_pixel_size = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray* tmp = mxCreateDoubleMatrix(DEPTH_MAX_RAW_VALUE, 1, mxREAL);
	double* dblptr = mxGetPr(tmp);
	for (int i = 0; i < DEPTH_MAX_RAW_VALUE; i++)
	{
		dblptr[i] = 1;
	} *mxGetPr(ref_pixel_size) = 1.5;
	mxSetFieldByNumber(plhs[2], 0, 1, ref_pixel_size); 
	mxSetFieldByNumber(plhs[2], 0, 2, tmp);*/

#endif

	if ( nrhs >1  ) {
		print_usage();
		return;
	} 

	//      printf("in kinect_mex\n");

	if (0==g_state){ /* do init */
#ifdef KINECT_VERBOSE
		printf("initializing libfreenect\n");
#endif // KINECT_VERBOSE	
		g_state=1;
		depth_mid = (uint16_t*)malloc(640*480*3*sizeof(uint16_t));
		depth_front = (uint16_t*)malloc(640*480*3*sizeof(uint16_t));
		rgb_back = (uint8_t*)malloc(RGB_WIDTH*RGB_HEIGHT*3);
		rgb_mid = (uint8_t*)malloc(RGB_WIDTH*RGB_HEIGHT*3);
		rgb_front = (uint8_t*)malloc(RGB_WIDTH*RGB_HEIGHT*3);


#ifdef KINECT_VERBOSE
		printf("Kinect camera test\n");
#endif // KINECT_VERBOSE			

		int i;
		for (i=0; i<2048; i++) {
			float v = i/2048.0;
			v = powf(v, 3)* 6;
			t_gamma[i] = v*6*256;
		}


		if (freenect_init(&f_ctx, NULL) < 0) {
			printf("freenect_init() failed\n");
			return;
		}
		freenect_set_log_level(f_ctx, FREENECT_LOG_DEBUG);

		freenect_select_subdevices(f_ctx, (freenect_device_flags)(FREENECT_DEVICE_MOTOR | FREENECT_DEVICE_CAMERA));
		//      freenect_set_log_level(f_ctx, FREENECT_LOG_DEBUG);

		int nr_devices = freenect_num_devices (f_ctx);
#ifdef KINECT_VERBOSE
		printf ("Number of devices found: %d\n", nr_devices);
#endif // KINECT_VERBOSE				

		int user_device_number = 0;

		if (nr_devices < 1){
			g_state=0;
			return;
		}
#ifdef KINECT_VERBOSE
		printf("opening device...\n");
#endif // KINECT_VERBOSE			
		if (freenect_open_device(f_ctx, &f_dev, user_device_number) < 0) {
			printf("user_device_number = %d\n", user_device_number);
			printf("Could not open device\n");
			printf("f_ctx = %p\n", f_ctx);
			printf("f_dev = %p\n", f_dev);
			return;
		}

		int res;
		//printf("starting thread...\n");
		res = pthread_create(&freenect_thread, NULL, freenect_threadfunc, NULL);
		if (res) {
			printf("pthread_create failed\n");
			return;
		}
		//printf("returning after starting thread...\n");
		return;

	}


#ifdef ENABLE_REGISTRATION
	mxArray* ref_dist, *ref_pixel_size, *shift_matrix;
	freenect_registration reg = freenect_copy_registration(f_dev);
	// print out registration parameters
#ifdef KINECT_VERBOSE
	printf("reference_distance: %f\n", reg.zero_plane_info.reference_distance);
	printf("reference_pixel_size: %f\n", reg.zero_plane_info.reference_pixel_size);
#endif // KINECT_VERBOSE

	ref_dist = mxCreateDoubleMatrix(1, 1, mxREAL);
	ref_pixel_size = mxCreateDoubleMatrix(1, 1, mxREAL);
	shift_matrix = mxCreateDoubleMatrix(DEPTH_MAX_RAW_VALUE, 1, mxREAL);
	double* dblptr = mxGetPr(shift_matrix);
	for (int i = 0; i < DEPTH_MAX_RAW_VALUE; i++)
	{
		dblptr[i] = (double)reg.raw_to_mm_shift[i];
		printf("i = %d, raw_data = %f\n", i, dblptr[i]);
	}
	*mxGetPr(ref_dist) = reg.zero_plane_info.reference_distance;
	*mxGetPr(ref_pixel_size) = reg.zero_plane_info.reference_pixel_size;
	//Assign the field values
	mxSetFieldByNumber(plhs[2], 0, 0, ref_dist);
	mxSetFieldByNumber(plhs[2], 0, 1, ref_pixel_size); 
	mxSetFieldByNumber(plhs[2], 0, 2, shift_matrix);

	/*	plhs[2] = mxCreateNumericMatrix(0, 0, mxUINT16_CLASS, mxREAL);
	uint16_t* raw_mm = (uint16_t*)mxCalloc(DEPTH_MAX_RAW_VALUE, sizeof(uint16_t));
	mxSetData(plhs[2], raw_mm);
	mxSetM(plhs[2], DEPTH_MAX_RAW_VALUE);
	mxSetN(plhs[2], 1);

	for (i = 0; i < DEPTH_MAX_RAW_VALUE; i++) {
		raw_mm[i] = (double)reg.raw_to_mm_shift[i];
	} */
#endif 

	//      printf("checking variables\n");

	if ( nrhs > 0 ){
		if ( mxIsChar(prhs[0]) != 1){
			print_usage();
			return;
		}
		if ((mxGetM(prhs[0])!=1)||(mxGetN(prhs[0])!=1)){
			; //normal usage
		}else{
			mxChar c = *(mxGetChars(prhs[0]));
			//	printf("char is %c\n",c);
			switch ( c ){
			case 'q':
				die=1;
				//	    printf("dying\n");
				break;
			case 'w':
				freenect_angle++;
				if (freenect_angle > 30) {
					freenect_angle = 30;
				}
				freenect_set_tilt_degs(f_dev,freenect_angle);
				break;
			case 'x':
				freenect_angle--;
				if (freenect_angle < -30) {
					freenect_angle = -30;
				}
				freenect_set_tilt_degs(f_dev,freenect_angle);
				break;
			case 's':
				freenect_angle=0;
				freenect_set_tilt_degs(f_dev,freenect_angle);
				break;
			case 'I':
				requested_format = FREENECT_VIDEO_IR_8BIT;
				break;
			case 'R':
				requested_format = FREENECT_VIDEO_RGB;
				break;
			case 'Y':
				requested_format = FREENECT_VIDEO_YUV_RGB;
				break;
			case '1':
				freenect_set_led(f_dev,LED_GREEN);
				break;
			case '2':
				freenect_set_led(f_dev,LED_RED);
				break;
			case '3':
				freenect_set_led(f_dev,LED_YELLOW);
				break;
			case '4':
				freenect_set_led(f_dev,LED_BLINK_GREEN);
				break;
			case '5':
				freenect_set_led(f_dev,LED_BLINK_RED_YELLOW);
				break;
			case '0':
				freenect_set_led(f_dev,LED_OFF);
				break;
			}
		}
	}


	//    printf("before update\n");
	Update();
	//    printf("after update\n");

	//    printf("copying data\n");
	for ( index = 0; index < DELEMENTS; index++ ) {
		depth_data[index] = depth_mid[index];
	}

	//    printf("copied data 1\n");

	if ( FREENECT_VIDEO_IR_8BIT==current_format ){
		//      printf("changing sizes\n");
		mxFree(rgb_data);
		rgb_data = (uint8_t*)mxCalloc(DELEMENTS, sizeof(uint8_t));
		mxSetData(plhs[1], rgb_data);
		mxSetM(plhs[1], DROWS);
		mxSetN(plhs[1], DCOLUMNS);

		for ( index = 0; index < DELEMENTS; index++ ) {
			rgb_data[index] = rgb_mid[index];
		}
		//      printf("copied data 2.1\n");
	}else{
		for ( index = 0; index < ELEMENTS; index++ ) {
			rgb_data[index] = rgb_mid[index];
		}
		//      printf("copied data 2.2\n");
	}

	//   printf("returning\n");
	return;
}

