#include "p16f18446.inc"

; CONFIG1
; __config 0x3FEF
 __CONFIG _CONFIG1, _FEXTOSC_ECH & _RSTOSC_HFINT1 & _CLKOUTEN_OFF & _CSWEN_ON & _FCMEN_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _MCLRE_ON & _PWRTS_OFF & _LPBOREN_OFF & _BOREN_ON & _BORV_LO & _ZCD_OFF & _PPS1WAY_ON & _STVREN_ON
; CONFIG3
; __config 0x3FFF
 __CONFIG _CONFIG3, _WDTCPS_WDTCPS_31 & _WDTE_ON & _WDTCWS_WDTCWS_7 & _WDTCCS_SC
; CONFIG4
; __config 0x3FFF
 __CONFIG _CONFIG4, _BBSIZE_BB512 & _BBEN_OFF & _SAFEN_OFF & _WRTAPP_OFF & _WRTB_OFF & _WRTC_OFF & _WRTD_OFF & _WRTSAF_OFF & _LVP_ON
; CONFIG5
; __config 0x3FFF
  __CONFIG _CONFIG5, _CP_OFF
RES_VECT  CODE    0x0000  
 
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;I have labeled the trajectory of the code please follow it!!!!!!!    (1)
 ;read in between the trajactory points eg. between (1) and (2)
 ;read in between the trajactory points eg. between (1) and (2)
 ;read in between the trajactory points eg. between (1) and (2)
 ;read in between the trajactory points eg. between (1) and (2)
 ;read in between the trajactory points eg. between (1) and (2)
 ;read in between the trajactory points eg. between (1) and (2)
 
 
          ; processor reset vector
    GOTO    START                   ; go to beginning of program        (2)
    
    ; functions for the direction of tests
    
    DUTYTEST
    goto test
    
    DUTYTEST2
    goto test2
    
    DUTYTEST3
    goto test3
    finish
   
    
    
    return
    
    

; TODO ADD INTERRUPTS HERE IF USED
    
    
   
  ; subroutines testing and fine tunning the duty cycle values from the ADC for proper and precise synchronization.
    test
        btfsc 20h,7
    goto left
    movwf 20h
    btfss 20h,6
    goto DUTYTEST2
    btfss 20h,5
    goto DUTYTEST2
 
    goto left
    
    left
    clrw
    movlw d'80'
    goto DUTYTEST2
   
test2
    movwf 21h
    btfsc 21h,6
    goto DUTYTEST3
    btfsc 21h,5
    goto DUTYTEST3
     btfsc 21h,4
    goto DUTYTEST3
    goto right
    
    right
    clrw
    movlw d'18'
    goto DUTYTEST3
    
    test3
    movwf 22h
   btfsc 22h,6
   goto finish
   btfss 22h,5
   goto finish
   
   movlw d'47'
   goto finish
   
   
    
    
    
     
    timer                                  ;sub routine to be called later        (5)   go to (6)          
    BANKSEL T2CLKCON 
    MOVLW   b'0001' 
    MOVWF   T2CLKCON
    return
    
    delay                                  ;sub routine to be called later         (8)   go to (9)
    BANKSEL PIR4
    BTFSS   PIR4, 1
    GOTO    delay
    return
    

MAIN_PROG CODE                      

START:                                                                                      ;(3)                
    BANKSEL RA4PPS                         ; search the bank in which RA4PPS is in.
    MOVLW   b'001100'                      ; value required to setup RA4 as output.
    MOVWF   RA4PPS 
    BANKSEL TRISA                          ; search the bank in which RA4PPS is in.
    BSF	    TRISA,4                        ; CCP4 pin output driver disabled
    BANKSEL ANSELA
    BCF	    ANSELA,4                       ; analog input blocked
    
    BANKSEL CCP4CON                        ; search the bank in which CCP4CON is in.
    MOVLW   B'10001111'                    ; clr bit 4 to activate right alignment, mode operation
    MOVWF   CCP4CON			   ; 
    BANKSEL T2PR                           ; search the bank in which T2PR is in.
    
    
    
    MOVLW   B'10011011'                    ; T2PR value calculated
    MOVWF   T2PR
    
    banksel TRISA                          ; search the bank in which TRISA is in.
    bsf	    TRISA,1                        ; set pin 1 of port A to be in input mode
    banksel ANSELA                         ; search the bank in which TRISA is in.
    bsf	    ANSELA, 1                      ; select analog input for pin4 of port A. by default, the pin is selected for digital input.
    

    banksel ADPCH                          ; the register for positive channel selection
    movlw   b'000001'                      ;  value required in ADPCH to select channel ANA4
    movwf   ADPCH                          ; channel ANA1 selected.
    
    
    banksel ADREF                          ; search the bank in which TRISA is in.
    movlw   b'00000'                       ; bit 4 is for Negativ Voltage Reference(NREF), bit 0 and bit 1 are for Positive reference(PREF), putting a zero in NREF chooses AVSS, which is the ground as Negative referenceand writing 00 in PREF choooses VDD (5V) as positive reference
    movwf   ADREF                          ; since we are using a potentiometer that has a voltage that runs from 0 to 5V, it makes sense to choose ) as Negative reference and 5V as Positive reference
 
   banksel  ADCON0                         ; search the bank in which ADCON0 is in.
   movlw    b'10000000'                    ; ADC ON(ON==0), CONT mode disabled(CONT==0); Frc selected(CS==0), 8 bit mode selectes(Left Alignment)(FRM==0); ADC conversion not in progress(G0==0)
   movwf    ADCON0
   
MAIN:
    bsf	    ADCON0,0	                   ;begin conversion(GO==1)
    
    
    
    
check:                                     ;polling                       
    btfsc   ADCON0,0	                   ;check if the Go bit is clear(GO==0) (ADC Conversion is complete) if it is, skip next line of code 
    goto    check                          ; This line will be skipped the moment that the GO bit is clear (conversion complete, 
    banksel ADRESH                         ; switch to whatever memory bank in the Data memory that the register ADRESH(High byte of the AD Results reg); 
    movfw   ADRESH                         ; moving the ADC results to the Working register from the ADRESH reg
                                           
    
    
    BANKSEL CCPR4L
    ;MOVLW   D'79'
    
    call DUTYTEST                         ;calls the subroutine that checks and fine tunes the values that will be inserted in the duty cycle registors and the duty cycle value 
   
    
    MOVWF   CCPR4L                        ;duty cycle value loaded in the duty cycle registors
    BANKSEL CCPR4H                        ; search the bank in which TRISA is in.
    CLRF    CCPR4H                        ; clear CCPR4H registor
    
    BANKSEL PIR4                         
    BCF	   PIR4, 1
    
    call timer                            ;calls the routine that configures timer 2      (4) go up to check the subroutine
    
    
    BANKSEL T2CON                         ; prescalling                                    (6)
    MOVLW   b'11010000'                   ;prescaler:1:32; post scaling 1:1

    MOVWF   T2CON                             
    call delay                            ; calls the delay subroutine that waits for the interupt flag of the timer to be set.  
                                                                                            ;(7) go to up to check it
                                                                                          
    BANKSEL TRISA                                                                                                                 
    BCF	    TRISA, 4                        ; before the code loops CCP4 enabled as output    
    

    END                                                                                       ;(9)                                         ()