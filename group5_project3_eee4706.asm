		ORG 00H
ON:		MOV 30H,#0H			;Memory locations and registers to be used are set to #0H
		MOV 31H,#0H
		MOV 35H,#0H
		MOV 40H,#0H
		MOV 41H,#0H
		MOV 42H,#0H
		MOV 43H,#0H
		MOV 44H,#0H
		MOV 45H,#0H
		MOV 46H,#0H
		MOV 47H,#0H
		MOV 48H,#0H
		MOV 49H,#0H
		MOV R0,#30H
		MOV R1,#40H
		MOV R6,#0H			;Acts as a counter for digits in first number
		MOV R7,#0H			;Acts as a counter for digits in second number
		ACALL DISPLAYRST		;Initialize the display to show values as they are typed
KEYPAD:		MOV P2,#0FFH			;Make P2 as input port
K1:		MOV P0,#0H			;Ground all rows at once
		MOV A,P2			;Read all column values
		ANL A,#00001111B		;Mask unused bits
		CJNE A,#00001111B,K1		;Check till all keys released
K2:		ACALL DELAY
		MOV A,P2			;See if any key is pressed
		ANL A,#00001111B
		CJNE A,#00001111B,OVER		;Move forward if key is pressed
		SJMP K2				;Repeat loop if key is not pressed
OVER:		ACALL DELAY			;Debounce time for key press
		MOV A,P2			;Check key closure
		ANL A,#00001111B
		CJNE A,#00001111B,OVER1		;Find row if key is pressed
		SJMP K2		
OVER1:		MOV P0,#11111110B		;Ground row 0
		MOV A,P2
		ANL A,#00001111B
		CJNE A,#00001111B,ROW_0		;If row 0 is the right row, they won't be equal so move to next step
		MOV P0,#11111101B
		MOV A,P2
		ANL A,#00001111B
		CJNE A,#00001111B,ROW_1
		MOV P0,#11111011B
		MOV A,P2
		ANL A,#00001111B
		CJNE A,#00001111B,ROW_2
		MOV P0,#11110111B
		MOV A,P2
		ANL A,#00001111B
		CJNE A,#00001111B,ROW_3
		LJMP K2				;Jump back if there is a false input		
ROW_0:		MOV DPTR,#KCODE0		;Set DPTR at the start of row 0 character lookup table
		SJMP FIND			;Jump to FIND subroutine to find the column again
ROW_1:		MOV DPTR,#KCODE1
		SJMP FIND
ROW_2:		MOV DPTR,#KCODE2
		SJMP FIND
ROW_3:		MOV DPTR,#KCODE3
		SJMP FIND		
FIND:		RRC A				;Check if CY = 0
		JNC MATCH			;Go to the next step to get ASCII code if CY = 0
		INC DPTR			;Point to next column address
		SJMP FIND			;Repeat loop
		
MATCH:		CLR A
		MOVC A,@A+DPTR			;Move DPTR value to A
		CJNE A,#'+',NEXT1		;Compare with each operator to see whether operator or number is pressed
		CJNE R6,#1H,SWAP1		;R6 = 1 means the number saved has only one digit so far
		INC R6				;When operator is pressed, no more digits can be input for 1st number
		ACALL SWAP0			;Call SWAP0 subroutine which will make single digit input like 5 as 05
SWAP1:		MOV 35H,A			
		ACALL DATAWRT			;display the operator on the screen
		LJMP K1
NEXT1:		CJNE A,#'-',NEXT2
		CJNE R6,#1H,SWAP2
		INC R6
		ACALL SWAP0
SWAP2:		MOV 35H,A
		ACALL DATAWRT
		LJMP K1
NEXT2:		CJNE A,#'*',NEXT3
		CJNE R6,#1H,SWAP3
		INC R6
		ACALL SWAP0
SWAP3:		MOV 35H,A
		ACALL DATAWRT
		LJMP K1
NEXT3:		CJNE A,#'/',NEXT4
		CJNE R6,#1H,SWAP4
		INC R6
		ACALL SWAP0
SWAP4:		MOV 35H,A
		ACALL DATAWRT
		LJMP K1
NEXT4:		CJNE A,#'=',NEXT5
		CJNE R7,#1H,SWAP5
		INC R7
		SETB PSW.4
		MOV R0,#40H
		MOV R1,#41H
		MOV @R1,40H
		MOV @R0,#0H
		CLR PSW.4
SWAP5:		ACALL DATAWRT
		LJMP RESULT
NEXT5:		CJNE A,#'C',NEXT6
		LJMP ON
		
NEXT6:		CJNE R6,#0H,STEP1		;the digits are saved in memory
		MOV @R0,A
		ADD A,#30H
		INC R0
		INC R6
		ACALL DATAWRT
		CLR A
		LJMP K1
STEP1:		CJNE R6,#1H,STEP2
		MOV @R0,A
		ADD A,#30H
		INC R0
		INC R6
		ACALL DATAWRT
		CLR A
		LJMP K1
STEP2:		CJNE R7,#0H,STEP3
		MOV @R1,A
		ADD A,#30H
		INC R1
		INC R7
		ACALL DATAWRT
		CLR A
		LJMP K1
STEP3:		CJNE R7,#1H,STEP4
		MOV @R1,A
		ADD A,#30H
		INC R1
		INC R7
		ACALL DATAWRT
		CLR A
STEP4:		LJMP K1

RESULT:		MOV A,35H			;operator is checked to determine which operation will be shown as result
PLUS:		CLR C				;Addition
		CJNE A,#'+',MINUS
		MOV R2,#0H
		MOV A,31H
		ADD A,41H
		CJNE A,#0AH,LOO
LOO:		JNC LO
		ADD A,#30H
		SJMP L
LO:		ADD A,#26H
		INC R2
L:		MOV 45H,A
		MOV A,30H
		ADD A,40H
		ADD A,R2
		MOV R2,#0H
		CJNE A,#0AH,LOO1
LOO1:		JNC LO1
		ADD A,#30H
		SJMP L1
LO1:		ADD A,#26H
		INC R2
L1:		MOV 44H,A
		MOV A,R2
		ADD A,#30H
		MOV 43H,A
		LJMP OUTPUTM

MINUS:		CJNE A,#'-',MINUSNOT		;Subtraction
		SJMP MINUSIS
MINUSNOT:	LJMP MULTI
MINUSIS:	MOV A,30H
		CJNE A,40H,SIGNCHK
SIGNCHK:	JNC POSIT
		CLR C
		MOV A,41H
		CJNE A,31H,SIGNCHK2
SIGNCHK2:	JNC NOBOR
		CLR C
		ADD A,#10H
		SUBB A,31H
		ADD A,#30H
		SUBB A,#6H
		MOV 45H,A
		MOV A,40H
		SUBB A,#1H
		SUBB A,30H
		ADD A,#30H
		MOV 44H,A
		MOV 43H,#'-'
		LJMP OUTPUTM
NOBOR:		SUBB A,31H
		ADD A,#30H
		MOV 45H,A
		MOV A,40H
		SUBB A,30H
		ADD A,#30H
		MOV 44H,A
		MOV 43H,#'-'
		LJMP OUTPUTM
POSIT:		MOV A,40H
		CJNE A,30H,CHKSIGN
CHKSIGN:	JNC CUDBENEG
		CLR C
		MOV A,31H
		CJNE A,41H,AGENCHK
AGENCHK:	JNC NOBOR1
		CLR C
		ADD A,#10H
		SUBB A,41H
		ADD A,#30H
		SUBB A,#6H
		MOV 45H,A
		MOV A,30H
		SUBB A,#1H
		SUBB A,40H
		ADD A,#30H
		MOV 44H,A
		MOV 43H,#30H
		LJMP OUTPUTM
NOBOR1:		SUBB A,41H
		ADD A,#30H
		MOV 45H,A
		MOV A,30H
		SUBB A,40H
		ADD A,#30H
		MOV 44H,A
		MOV 43H,#30H
		LJMP OUTPUTM
CUDBENEG:	MOV A,31H
		CJNE A,41H,AGANCHK
AGANCHK:	JNC NOBOR2
		CLR C
		MOV A,41H
		SUBB A,31H
		ADD A,#30H
		MOV 45H,A
		MOV 44H,#30H
		MOV 43H,#'-'
		LJMP OUTPUTM		
NOBOR2:		SUBB A,41H
		ADD A,#30H
		MOV 45H,A
		MOV A,30H
		SUBB A,40H
		ADD A,#30H
		MOV 44H,A
		MOV 43H,#30H
		LJMP OUTPUTM
				
MULTI:		CLR C				;Multiplication
		CJNE A,#'*',DIVI
		SJMP MANA
DIVI:		LJMP DIVIDE
MANA:		MOV R5,#0H
		MOV A,31H
		MOV R2,41H
		CJNE A,#0H,ZER
		MOV 45H,#30H
		SJMP BLE
ZER:		CJNE R2,#0H,ZER1
		MOV 45H,#30H
		SJMP STG2
ZER1:		MOV R3,A
		MOV A,#0H
M2:		ADD A,R3
		CJNE A,#0AH,M1
M1:		JC NOCAR
		INC R5
		ADD A,#6H
		ANL A,#00001111B
		DJNZ R2,M2
		SJMP NXTM
NOCAR:		ANL A,#00001111B
		DJNZ R2,M2
NXTM:		ADD A,#30H
		MOV 45H,A			
		MOV 49H,R5			
		MOV R5,#0H
		
BLE:		MOV A,30H
		MOV R2,41H
ZER2:		CJNE R2,#0H,ZER11
		MOV A,31H
		CJNE A,#0H,BLUE
		MOV 49H,#0H
BLUE:		MOV A,30H
		SJMP NXTM1
ZER11:		MOV R3,A
		MOV A,#0H
M3:		ADD A,R3
		CJNE A,#0AH,M4
M4:		JC NOCAR1
		INC R5
		ADD A,#6H
		ANL A,#00001111B
		DJNZ R2,M3
		SJMP NXTM1
NOCAR1:		ANL A,#00001111B
		DJNZ R2,M3
NXTM1:		ADD A,49H
		CJNE A,#0AH,NII
NII:		JC NI1
		INC R5
		ADD A,#6H
		ANL A,#00001111B
NI1:		MOV 48H,A		
		MOV A,R5
		MOV 47H,A						
STG2:		MOV R5,#0H
		MOV A,31H
		MOV R2,40H
		CJNE A,#0H,ZER5
		MOV A,41H
		CJNE A,#0H,ZER5
		MOV 48H,#0H
ZER5:		MOV A,31H
		CJNE R2,#0H,ZER15
		MOV A,41H
ULA:		MOV 42H,#30H
		MOV A,42H
		ACALL DATAWRT
		MOV A,47H
		ADD A,#30H
		MOV 43H,A
		MOV A,41H
		CJNE A,#0H,TUU
		MOV 44H,#30H
		LJMP OUTPUTM
TUU:		MOV A,48H
		ADD A,#30H
		MOV 44H,A
		LJMP OUTPUTM
ZER15:		MOV R3,A
		MOV A,#0H
M25:		ADD A,R3
		CJNE A,#0AH,M15
M15:		JC NOCAR5
		INC R5
		ADD A,#6H
		ANL A,#00001111B
		DJNZ R2,M25
		SJMP NXTM5
NOCAR5:		CLR C
		ANL A,#00001111B
		DJNZ R2,M25
NXTM5:		ADD A,48H
		CJNE A,#0AH,YU1
YU1:		JC YU2
		MOV R1,47H
		INC R1
		MOV 47H,R1
		ADD A,#6H
		ANL A,#00001111B
YU2:		CLR C
		ADD A,#30H
		MOV 44H,A		
		MOV 49H,R5		
ST3:		MOV R5,#0H
		MOV A,30H
		MOV R2,40H
		CJNE A,#0H,ZER7
		SJMP NO7	
ZER7:		CJNE R2,#0H,ZURU
		SJMP NINI
ZURU:		MOV R3,A
		MOV A,#0H
MIT:		ADD A,R3
		CJNE A,#0AH,MUTU
MUTU:		JC NORU
		INC R5
		ADD A,#6H
		ANL A,#00001111B
		DJNZ R2,MIT
		SJMP NO7
NORU:		CLR C
		ANL A,#00001111B
		DJNZ R2,MIT	
NO7:		ADD A,49H
		CJNE A,#0AH,MURU
MURU:		JC MORO
		INC R5
		ADD A,#6H
		ANL A,#00001111B
MORO:		ADD A,47H
		CJNE A,#0AH,BORO
BORO:		JC NINI
		INC R5
		ADD A,#6H
		ANL A,#00001111B
NINI:		ADD A,#30H
		MOV 43H,A
		MOV A,R5
		ADD A,#30H
		MOV 42H,A
		ACALL DATAWRT
		LJMP OUTPUTM
		
DIVIDE:		MOV A,30H			;Divide
		RL A
		RL A
		RL A
		RL A
		ADD A,31H
		MOV 32H,A
		MOV A,40H
		RL A
		RL A
		RL A
		RL A
		ADD A,41H
		MOV 42H,A
		MOV B,A
		MOV A,32H
		DIV AB
		MOV R2,A
		ANL A,#11110000B
		RR A
		RR A
		RR A
		RR A
		ADD A,#30H
		MOV 44H,A
		ACALL DATAWRT
		MOV A,R2
		ANL A,#00001111B
		CJNE A,#0AH,OVAR
OVAR:		JC JULU
		SUBB A,#6H
JULU:		ADD A,#30H
		MOV 45H,A
		ACALL DATAWRT
		LJMP K1

OUTPUTM:	MOV A,43H
		ACALL DATAWRT
		MOV A,44H
		ACALL DATAWRT
		MOV A,45H
		ACALL DATAWRT
		LJMP K1

CLEAR:		LJMP ON

COMNWRT:	MOV P1,A			;Subroutine for giving command information to LCD
		CLR P3.0
		CLR P3.1
		SETB P3.2
		ACALL DELAY
		CLR P3.2
		RET
DATAWRT:	MOV P1,A			;Subroutine for giving data information to LCD
		SETB P3.0
		CLR P3.1
		SETB P3.2
		ACALL DELAY
		CLR P3.2
		RET	
DISPLAYRST:	MOV A,#38H			;Initialize LCD
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#0EH			;Display on, cursor on
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#01H			;Clear LCD
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#06H			;Shift cursor right
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#80H			;Put the display cursor at the start of the first line
		ACALL COMNWRT
		ACALL DELAY
		RET
SWAP0:		SETB PSW.4
		MOV R0,#30H
		MOV R1,#31H
		MOV @R1,30H
		MOV @R0,#0H
		CLR PSW.4
		RET
DELAY: 		MOV R4,#50			;Delay subroutine
HERE2: 		MOV R5,#50
HERE1: 		DJNZ R5,HERE1
		DJNZ R4,HERE2
		RET
		ORG 500H			;Location for lookup table
KCODE0:		DB 7H,8H,9H,'/'			;Lookup table for row 0 characters
KCODE1:		DB 4H,5H,6H,'*'			;Lookup table for row 1 characters
KCODE2:		DB 1H,2H,3H,'-'			;Lookup table for row 2 characters
KCODE3:		DB 'C',0H,'=','+'		;Lookup table for row 3 characters
		END				;End of the entire program