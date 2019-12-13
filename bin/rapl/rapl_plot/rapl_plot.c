/** 
 * @author  Vince Weaver
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "papi.h"

#define MAX_EVENTS 128

char events[MAX_EVENTS][BUFSIZ];
char units[MAX_EVENTS][BUFSIZ];
int data_type[MAX_EVENTS];
//char event_names[MAX_EVENTS][BUFSIZ];

FILE *fff;
FILE *fff_energy_cnt_package, *fff_energy_cnt_dram, 
	 *fff_energy_cnt_pp0, *fff_energy_cnt_pp1;
FILE *fff_energy_package, *fff_energy_dram,
	 *fff_energy_pp0, *fff_energy_pp1;
FILE *fff_power_package, *fff_power_dram,
	 *fff_power_pp0, *fff_power_pp1;

static int num_events=0;

int main (int argc, char **argv)
{

	int retval,cid,rapl_cid=-1,numcmp;
	int EventSet = PAPI_NULL;
	long long values[MAX_EVENTS];
	int i,code,enum_retval;
	PAPI_event_info_t evinfo;
	const PAPI_component_info_t *cmpinfo = NULL;
	long long start_time,before_time,after_time,offset_time;
	double elapsed_time,total_time;
	char event_name[BUFSIZ];

	if(argc<2)
	{
		printf("Usage: rapl_plot $(output_filename) $(seconds_interval)\n");
		exit(-1);
	}

	char* arg_filename = argv[1];
	size_t array_length = strlen(arg_filename)+30;
	char output_filename[array_length], 
	 output_filename_energy_cnt_package[array_length],
	 output_filename_energy_cnt_dram[array_length],
	 output_filename_energy_cnt_pp0[array_length],
	 output_filename_energy_cnt_pp1[array_length],
	 output_filename_energy_package[array_length], 
	 output_filename_energy_dram[array_length], 
	 output_filename_energy_pp0[array_length], 
	 output_filename_energy_pp1[array_length], 
	 output_filename_power_package[array_length], 
	 output_filename_power_dram[array_length], 
	 output_filename_power_pp0[array_length], 
	 output_filename_power_pp1[array_length];

	sprintf(output_filename, "%s.csv", arg_filename);
	sprintf(output_filename_energy_cnt_package, "%s_energy_cnt_package.csv", arg_filename);
	sprintf(output_filename_energy_cnt_dram, "%s_energy_cnt_dram.csv", arg_filename);
	sprintf(output_filename_energy_cnt_pp0, "%s_energy_cnt_pp0.csv", arg_filename);
	sprintf(output_filename_energy_cnt_pp1, "%s_energy_cnt_pp1.csv", arg_filename);
	sprintf(output_filename_energy_package, "%s_energy_joules_package.csv", arg_filename);
	sprintf(output_filename_energy_dram, "%s_energy_joules_dram.csv", arg_filename);
	sprintf(output_filename_energy_pp0, "%s_energy_joules_pp0.csv", arg_filename);
	sprintf(output_filename_energy_pp1, "%s_energy_joules_pp1.csv", arg_filename);
	sprintf(output_filename_power_package, "%s_power_package.csv", arg_filename);
	sprintf(output_filename_power_dram, "%s_power_dram.csv", arg_filename);
	sprintf(output_filename_power_pp0, "%s_power_pp0.csv", arg_filename);
	sprintf(output_filename_power_pp1, "%s_power_pp1.csv", arg_filename);

	int seconds_interval;
	sscanf(argv[2], "%d", &seconds_interval);
	int microseconds_interval = seconds_interval * 1e6;

	printf("Filename: %s\n",output_filename);
	printf("Microseconds interval: %d\n",microseconds_interval);


	/* PAPI Initialization */
	retval = PAPI_library_init( PAPI_VER_CURRENT );
	if ( retval != PAPI_VER_CURRENT ) {
		fprintf(stderr,"PAPI_library_init failed\n");
		exit(1);
	}

	numcmp = PAPI_num_components();

	for(cid=0; cid<numcmp; cid++) {

		if ( (cmpinfo = PAPI_get_component_info(cid)) == NULL) {
			fprintf(stderr,"PAPI_get_component_info failed\n");
			exit(1);
		}

		if (strstr(cmpinfo->name,"rapl")) {
			rapl_cid=cid;
			printf("Found rapl component at cid %d\n", rapl_cid);

			if (cmpinfo->disabled) {
				fprintf(stderr,"No rapl events found: %s\n",
						cmpinfo->disabled_reason);
				exit(1);
			}
			break;
		}
	}

	/* Component not found */
	if (cid==numcmp) {
		fprintf(stderr,"No rapl component found\n");
		exit(1);
	}

	/* Find Events */
	code = PAPI_NATIVE_MASK;

	enum_retval = PAPI_enum_cmp_event( &code, PAPI_ENUM_FIRST, cid );

	while ( enum_retval == PAPI_OK ) {

		retval = PAPI_event_code_to_name( code, event_name );
		if ( retval != PAPI_OK ) {
			printf("Error translating %#x\n",code);
			exit(1);
		}

		printf("Found: %s\n",event_name);
		strncpy(events[num_events],event_name,BUFSIZ);
		//sprintf(event_names[num_events],"%s",event_name);


        /* Find additional event information: unit, data type */
		retval = PAPI_get_event_info(code, &evinfo);
		if (retval != PAPI_OK) {
			printf("Error getting event info for %#x\n",code);
			exit(1);
		}

		strncpy(units[num_events],evinfo.units,sizeof(units[0])-1);
		/* buffer must be null terminated to safely use strstr operation on it below */
		units[num_events][sizeof(units[0])-1] = '\0';

		data_type[num_events] = evinfo.data_type;

		num_events++;

		if (num_events==MAX_EVENTS) {
			printf("Too many events! %d\n",num_events);
			exit(1);
		}

		enum_retval = PAPI_enum_cmp_event( &code, PAPI_ENUM_EVENTS, cid );

	}



	if (num_events==0) {
		printf("Error!  No RAPL events found!\n");
		exit(1);
	}

	/* Open output files */

	fff=fopen(output_filename,"w");
	if (fff==NULL) {
		fprintf(stderr,"Could not open fff %s\n",output_filename);
		exit(1);
	}

	fff_energy_cnt_package=fopen(output_filename_energy_cnt_package,"w");
	fff_energy_cnt_dram=fopen(output_filename_energy_cnt_dram,"w");
	fff_energy_cnt_pp0=fopen(output_filename_energy_cnt_pp0,"w");
	fff_energy_cnt_pp1=fopen(output_filename_energy_cnt_pp1,"w");

	if (fff_energy_cnt_package==NULL) {
		fprintf(stderr,"Could not open fff_energy_cnt_package %s\n",output_filename_energy_cnt_package);
		exit(1);
	}
	if (fff_energy_cnt_dram==NULL) {
		fprintf(stderr,"Could not open fff_energy_cnt_dram %s\n",output_filename_energy_cnt_dram);
		exit(1);
	}
	if (fff_energy_cnt_pp0==NULL) {
		fprintf(stderr,"Could not open fff_energy_cnt_pp0 %s\n",output_filename_energy_cnt_pp0);
		exit(1);
	}
	if (fff_energy_cnt_pp1==NULL) {
		fprintf(stderr,"Could not open fff_energy_cnt_pp1 %s\n",output_filename_energy_cnt_pp1);
		exit(1);
	}

	fff_energy_package=fopen(output_filename_energy_package,"w");
	fff_energy_dram=fopen(output_filename_energy_dram,"w");
	fff_energy_pp0=fopen(output_filename_energy_pp0,"w");
	fff_energy_pp1=fopen(output_filename_energy_pp1,"w");

	if (fff_energy_package==NULL) {
		fprintf(stderr,"Could not open fff_energy_package %s\n",output_filename_energy_package);
		exit(1);
	}
	if (fff_energy_dram==NULL) {
		fprintf(stderr,"Could not open fff_energy_dram %s\n",output_filename_energy_dram);
		exit(1);
	}
	if (fff_energy_pp0==NULL) {
		fprintf(stderr,"Could not open fff_energy_pp0 %s\n",output_filename_energy_pp0);
		exit(1);
	}
	if (fff_energy_pp1==NULL) {
		fprintf(stderr,"Could not open fff_energy_pp1 %s\n",output_filename_energy_pp1);
		exit(1);
	}

	fff_power_package=fopen(output_filename_power_package,"w");
	fff_power_dram=fopen(output_filename_power_dram,"w");
	fff_power_pp0=fopen(output_filename_power_pp0,"w");
	fff_power_pp1=fopen(output_filename_power_pp1,"w");

	if (fff_power_package==NULL) {
		fprintf(stderr,"Could not open fff_power_package %s\n",output_filename_power_package);
		exit(1);
	}
	if (fff_power_dram==NULL) {
		fprintf(stderr,"Could not open fff_power_dram %s\n",output_filename_power_dram);
		exit(1);
	}
	if (fff_power_pp0==NULL) {
		fprintf(stderr,"Could not open fff_power_pp0 %s\n",output_filename_power_pp0);
		exit(1);
	}
	if (fff_power_pp1==NULL) {
		fprintf(stderr,"Could not open fff_power_pp1 %s\n",output_filename_power_pp1);
		exit(1);
	}

	/* Write file header */

	fprintf(fff,"TIME(s)");
	fprintf(fff_energy_cnt_package,"TIME(s)");
	fprintf(fff_energy_cnt_dram,"TIME(s)");
	fprintf(fff_energy_cnt_pp0,"TIME(s)");
	fprintf(fff_energy_cnt_pp1,"TIME(s)");
	fprintf(fff_energy_package,"TIME(s)");
	fprintf(fff_energy_dram,"TIME(s)");
	fprintf(fff_energy_pp0,"TIME(s)");
	fprintf(fff_energy_pp1,"TIME(s)");
	fprintf(fff_power_package,"TIME(s)");
	fprintf(fff_power_dram,"TIME(s)");
	fprintf(fff_power_pp0,"TIME(s)");
	fprintf(fff_power_pp1,"TIME(s)");

	for(i=0;i<num_events;i++) {
		if (!strstr(events[i],"ENERGY"))
		{
			if(strcmp(units[i],"") == 0)
				fprintf(fff,", %s",events[i]);
			else
				fprintf(fff,", %s(%s)",events[i],units[i]);
		}
		else if (strstr(events[i],"ENERGY_CNT"))
		{
			if (strstr(events[i],"DRAM_"))
				fprintf(fff_energy_cnt_dram,", %s",events[i]);
			else if (strstr(events[i],"PP0_"))
				fprintf(fff_energy_cnt_pp0,", %s",events[i]);
			else if (strstr(events[i],"PP1_"))
				fprintf(fff_energy_cnt_pp1,", %s",events[i]);
			else if (strstr(events[i],"PACKAGE_"))
				fprintf(fff_energy_cnt_package,", %s",events[i]);
			else
				fprintf(fff,", %s",events[i]);
		}
		else
		{
			if (strstr(events[i],"DRAM_"))
			{
				fprintf(fff_energy_dram,", %s(J)",events[i]);
				fprintf(fff_power_dram,", %s(W)",events[i]);
			}
			else if (strstr(events[i],"PP0_"))
			{
				fprintf(fff_energy_pp0,", %s(J)",events[i]);
				fprintf(fff_power_pp0,", %s(W)",events[i]);
			}
			else if (strstr(events[i],"PP1_"))
			{
				fprintf(fff_energy_pp1,", %s(J)",events[i]);
				fprintf(fff_power_pp1,", %s(W)",events[i]);
			}
			else if (strstr(events[i],"PACKAGE_"))
			{
				fprintf(fff_energy_package,", %s(J)",events[i]);
				fprintf(fff_power_package,", %s(W)",events[i]);
			}
			else
			{
				fprintf(fff,", %s(J)",events[i]);
				fprintf(fff,", %s(W)",events[i]);
			}
		}
	}


	fprintf(fff,"\n");
	fprintf(fff_energy_cnt_package,"\n");
	fprintf(fff_energy_cnt_dram,"\n");
	fprintf(fff_energy_cnt_pp0,"\n");
	fprintf(fff_energy_cnt_pp1,"\n");
	fprintf(fff_energy_package,"\n");
	fprintf(fff_energy_dram,"\n");
	fprintf(fff_energy_pp0,"\n");
	fprintf(fff_energy_pp1,"\n");
	fprintf(fff_power_package,"\n");
	fprintf(fff_power_dram,"\n");
	fprintf(fff_power_pp0,"\n");
	fprintf(fff_power_pp1,"\n");


	/* Create EventSet */
	retval = PAPI_create_eventset( &EventSet );
	if (retval != PAPI_OK) {
		fprintf(stderr,"Error creating eventset!\n");
	}

	for(i=0;i<num_events;i++) {

		retval = PAPI_add_named_event( EventSet, events[i] );
		if (retval != PAPI_OK) {
			fprintf(stderr,"Error adding event %s\n",events[i]);
		}
	}



	start_time=PAPI_get_real_nsec();

	after_time=start_time;

	while(1) {

		/* Start Counting */
		before_time=PAPI_get_real_nsec();
		retval = PAPI_start( EventSet);
		if (retval != PAPI_OK) {
			fprintf(stderr,"PAPI_start() failed\n");
			exit(1);
		}

		offset_time=(PAPI_get_real_nsec() - after_time)/1000 + 50;

		usleep(microseconds_interval - offset_time);

		/* Stop Counting */
		after_time=PAPI_get_real_nsec();
		retval = PAPI_stop( EventSet, values);
		if (retval != PAPI_OK) {
			fprintf(stderr, "PAPI_start() failed\n");
		}

		total_time=((double)(after_time-start_time))/1.0e9;
		elapsed_time=((double)(after_time-before_time))/1.0e9;


		fprintf(fff,"%.4f",
				total_time);
		fprintf(fff_energy_cnt_package,"%.4f",
						total_time);
		fprintf(fff_energy_cnt_dram,"%.4f",
						total_time);
		fprintf(fff_energy_cnt_pp0,"%.4f",
						total_time);
		fprintf(fff_energy_cnt_pp1,"%.4f",
						total_time);
		fprintf(fff_energy_package,"%.4f",
						total_time);
		fprintf(fff_energy_dram,"%.4f",
						total_time);
		fprintf(fff_energy_pp0,"%.4f",
						total_time);
		fprintf(fff_energy_pp1,"%.4f",
						total_time);
		fprintf(fff_power_package,"%.4f",
						total_time);
		fprintf(fff_power_dram,"%.4f",
						total_time);
		fprintf(fff_power_pp0,"%.4f",
						total_time);
		fprintf(fff_power_pp1,"%.4f",
						total_time);

		for(i=0;i<num_events;i++) {


			if (!strstr(events[i],"ENERGY")) {

                /* Scaled fixed value */
				if (data_type[i] == PAPI_DATATYPE_FP64) {

					union {
						long long ll;
						double fp;
					} result;

					result.ll=values[i];


					fprintf(fff,", %.3f",
							result.fp);

				} 
				/* Fixed value counts */
				else if (data_type[i] == PAPI_DATATYPE_UINT64) {

					fprintf(fff,", %lld",
							values[i]);

				}
			}

			/* Energy measurement counts */
			else if (strstr(events[i],"ENERGY_CNT")) {  

				if (strstr(events[i],"DRAM_"))
					fprintf(fff_energy_cnt_dram,", %lld",
						values[i] );
				else if (strstr(events[i],"PP0_"))
					fprintf(fff_energy_cnt_pp0,", %lld",
						values[i] );
				else if (strstr(events[i],"PP1_"))
					fprintf(fff_energy_cnt_pp1,", %lld",
						values[i] );
				else if (strstr(events[i],"PACKAGE_"))
					fprintf(fff_energy_cnt_package,", %lld",
						values[i] );
				else
					fprintf(fff,", %lld",
						values[i] );

			}

			/* Scaled energy measurements */
			else {
				if (strstr(events[i],"DRAM_"))
				{
					fprintf(fff_energy_dram,", %.3f",
							((double)values[i]/1.0e9));
					fprintf(fff_power_dram,", %.3f",
							((double)values[i]/1.0e9)/elapsed_time);
				}
				else if (strstr(events[i],"PP0_"))
				{
					fprintf(fff_energy_pp0,", %.3f",
							((double)values[i]/1.0e9));
					fprintf(fff_power_pp0,", %.3f",
							((double)values[i]/1.0e9)/elapsed_time);
				}
				else if (strstr(events[i],"PP1_"))
				{
					fprintf(fff_energy_pp1,", %.3f",
							((double)values[i]/1.0e9));
					fprintf(fff_power_pp1,", %.3f",
							((double)values[i]/1.0e9)/elapsed_time);
				}
				else if (strstr(events[i],"PACKAGE_"))
				{
					fprintf(fff_energy_package,", %.3f",
							((double)values[i]/1.0e9));
					fprintf(fff_power_package,", %.3f",
							((double)values[i]/1.0e9)/elapsed_time);
				}
				else
				{
					fprintf(fff,", %.3f",
							((double)values[i]/1.0e9));
					fprintf(fff,", %.3f",
							((double)values[i]/1.0e9)/elapsed_time);
				}

			};

			//fflush(fff);
		}

		fprintf(fff,"\n");
		fprintf(fff_energy_cnt_package,"\n");
		fprintf(fff_energy_cnt_dram,"\n");
		fprintf(fff_energy_cnt_pp0,"\n");
		fprintf(fff_energy_cnt_pp1,"\n");
		fprintf(fff_energy_package,"\n");
		fprintf(fff_energy_dram,"\n");
		fprintf(fff_energy_pp0,"\n");
		fprintf(fff_energy_pp1,"\n");
		fprintf(fff_power_package,"\n");
		fprintf(fff_power_dram,"\n");
		fprintf(fff_power_pp0,"\n");
		fprintf(fff_power_pp1,"\n");

		fflush(fff);
		fflush(fff_energy_cnt_package);
		fflush(fff_energy_cnt_dram);
		fflush(fff_energy_cnt_pp0);
		fflush(fff_energy_cnt_pp1);
		fflush(fff_energy_package);
		fflush(fff_energy_dram);
		fflush(fff_energy_pp0);
		fflush(fff_energy_pp1);
		fflush(fff_power_package);
		fflush(fff_power_dram);
		fflush(fff_power_pp0);
		fflush(fff_power_pp1);

	}

	return 0;
}

