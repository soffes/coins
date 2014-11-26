//
//  amibeingdebugged.h
//  HSILibs
//
//  Copyright (c) 2013 Haiku Software, Inc. All rights reserved.
//

#ifndef HSI_amibeingdebugged_h
#define HSI_amibeingdebugged_h


extern bool AmIBeingDebugged( void );

#if defined(DEBUG) && (DEBUG == 1)
    extern void dRaiseSIGINT( void );
#else
    #define dRaiseSIGINT( void )    
#endif


#if defined(DEBUG) && (DEBUG == 1)
    #define dASSERT_RAISE( cond, objCformatStr, var_args1... )     do { if (!(cond)) { NSLog( objCformatStr, ## var_args1 ); dRaiseSIGINT(); } } while (0)
#else
    #define dASSERT_RAISE( cond, objCformatStr, var_args1... )
#endif

#endif
