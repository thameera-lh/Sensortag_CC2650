/******************************************************************************

 @file  cc26xx_app_oad.cmd

 @brief CC2650F128 linker configuration file for TI-RTOS with Code Composer
        Studio.

 Group: WCS, BTS
 Target Device: CC2650, CC2640

 ******************************************************************************
 
 Copyright (c) 2013-2020, Texas Instruments Incorporated
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 *  Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

 *  Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 *  Neither the name of Texas Instruments Incorporated nor the names of
    its contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 ******************************************************************************
 Release Name: ble_sdk_2_02_02_
 Release Date: 2020-03-10 01:52:58
 *****************************************************************************/

/* Retain interrupt vector table variable                                    */
--retain=g_pfnVectors
/* Override default entry point.                                             */
--entry_point ResetISR
/* Suppress warnings and errors:                                             */
/* - 10063: Warning about entry point not being _c_int00                     */
/* - 16011, 16012: 8-byte alignment errors. Observed when linking in object  */
/*   files compiled using Keil (ARM compiler)                                */
--diag_suppress=10063,16011,16012

/* The following command line options are set as part of the CCS project.    */
	/* If you are building using the command line, or for some reason want to    */
/* define them here, you can uncomment and modify these lines as needed.     */
/* If you are using CCS for building, it is probably better to make any such */
/* modifications in your CCS project and leave this file alone.              */
/*                                                                           */
/* --heap_size=0                                                             */
/* --stack_size=256                                                          */
/* --library=rtsv7M3_T_le_eabi.lib                                           */

/* The starting address of the application.  Normally the interrupt vectors  */
/* must be located at the beginning of the application.                      */
#ifndef FLASH_APP_BASE
#define FLASH_APP_BASE          0x00001000
#endif /* FLASH_APP_BASE */

#define FLASH_OAD_IMG_HDR_SIZE  0x10
#define FLASH_OAD_IMG_START     FLASH_APP_BASE + FLASH_OAD_IMG_HDR_SIZE
#define FLASH_OAD_IMG_MAX_LEN   FLASH_LEN - (2 * FLASH_PAGE_LEN) - FLASH_OAD_IMG_HDR_SIZE

#define FLASH_LEN               0x20000
#define FLASH_PAGE_LEN          0x1000

/* RAM starts at 0x20000000 and is 20KB */
#define RAM_APP_BASE            0x20000000
#define RAM_LEN                 0x5000
/* RAM reserved by ROM code starts. */
#define RAM_RESERVED_OFFSET      0x4F00


/* System memory map */

MEMORY
{
    /* EDITOR'S NOTE:
     * the FLASH and SRAM lengths can be changed by defining
     * ICALL_STACK0_START or ICALL_RAM0_START in
     * Properties->ARM Linker->Advanced Options->Command File Preprocessing.
     */

    /* Application stored in and executes from internal flash starting at 4KB offset from 0x0 */
    /* Flash Size 128 KB */
    #ifdef ICALL_STACK0_START
        FLASH (RX) : origin = FLASH_OAD_IMG_START, length = ICALL_STACK0_START - FLASH_OAD_IMG_START
    #else
        /* default.  First and last page excluded for OAD. */
        FLASH (RX) : origin = FLASH_OAD_IMG_START, length = FLASH_OAD_IMG_MAX_LEN
    #endif

    IMAGE_HEADER (RX) : origin = FLASH_APP_BASE, length = FLASH_OAD_IMG_HDR_SIZE

    /* Application uses internal RAM for data */
    /* RAM Size 16 KB */
    #ifdef ICALL_RAM0_START
        SRAM (RWX) : origin = RAM_APP_BASE, length = ICALL_RAM0_START - RAM_APP_BASE
    #else //default
        SRAM (RWX) : origin = RAM_APP_BASE, length = RAM_RESERVED_OFFSET
    #endif
}

/* Section allocation in memory */

SECTIONS
{
	  .imgHdr       :   > IMAGE_HEADER
    .intvecs        :   > FLASH
    .text           :   > FLASH
    .const          :   > FLASH
    .constdata      :   > FLASH
    .rodata         :   > FLASH
    .cinit          :   > FLASH
    .pinit          :   > FLASH
    .init_array     :   > FLASH
    .emb_text       :   > FLASH

	GROUP > SRAM
	{
	    .data
	    .bss
		.vtable
	    .vtable_ram
	     vtable_ram
	    .sysmem
    	.nonretenvar
	} LOAD_END(heapStart)

	.stack          :   >  SRAM (HIGH) LOAD_START(heapEnd)
}

/* Create global constant that points to top of stack */
/* CCS: Change stack size under Project Properties    */
__STACK_TOP = __stack + __STACK_SIZE;

/* Allow main() to take args */
/*--args 0x8*/