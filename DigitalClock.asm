ORG 0000H
AJMP MAIN

;Main asm code
ORG 0100H
MAIN:	
	;Setting the initial values for all the registers and defining output ports
		MOV P3, #00H
		MOV P1, #00H
		;R0 is used to select a display among 4 displays
		MOV R0, #11H
		;R1 to R4 are the displacements for each display respectively starting from left to right
		MOV R1, #00H
		MOV R2, #08H
		MOV R3, #05H
		MOV R4, #07H
		;R5 register determines if its AM or PM with a bot (h led)
		MOV R5, #00H
	;Loading the initial address of the data that has to be sent to the 7 segment display
LOAD: 
		MOV DPTR, #1000H
START:
		;One minute delay
		MOV R6, #04H
		MINUTE: MOV R7, #191D
		SECOND: ACALL DELAY
		DJNZ R7, SECOND
		DJNZ R6, MINUTE
		INC R4 ;Increasing R4 by one for every 1 second
		CJNE R4, #0AH, START ;Checking if 10 seconds (0 to 9) are completed if yes then increase the R3 and reset R4
		MOV R4, #00H
		INC R3
		;Check if R3 is greater than 5 (because the maximum seconds in an minute is 59 
		;considering form 0)if yes then clear R3 and increase R2
		CJNE R3, #06H, START 
		MOV R3, #00H
		INC R2
		;As in 12hr clock format the clock will reset to 1:00 after 12:59 so if there is '1' in '12' 
		;that means the clock should stop at 12 and next number will be 1 if not it will count upto 9
		;or else it will count to 2 and then sets the R2 and R1 to 1 and 0 respectively so that it will look like '01'
		CJNE R1, #01H, SKIP 
		CJNE R2, #03H, START
		MOV R2, #01H
		MOV R1, #00H
		;If it crossed '12' that means the clock crossed AM to PM or PM to AM so we increase R5 for later purpose
		INC R5
SKIP: 	
		;Loop if R1 is not 01 that means its somewhere around 03:xx so R2 can increase upto 9
		CJNE R2, #0AH, START
		MOV R2, #00H
		INC R1
		;Check if R1 crossed 1 and if yes then load 1000 into DPTR and start clock from the beginning (because 12 hr format).
		CJNE R1, #02H, START
		MOV R1, #00H
		SJMP LOAD
		
		;Maximum delay
DELAY:
		MOV TMOD, #01H
		MOV TH0, #00H
		MOV TL0, #00H
		SETB TR0
		HERE:
		;Load the display and turn on every display with minimum of 0.05s so they will look like they were turned on continuously
			ACALL LOAD4
			ACALL DELAY2
			ACALL LOAD3
			ACALL DELAY2
			ACALL LOAD2
			ACALL DELAY2
			ACALL LOAD1
			ACALL DELAY2
			JNB TF0, HERE
			CLR TR0
			CLR TF0
		RET
		
		;Delay for 0.05s
DELAY2:
		MOV TMOD, #10H
		MOV TH1, #0C3H
		MOV TL1, #050H
		SETB TR1
		HERE1: JNB TF1, HERE1
		CLR TR1
		CLR TF1
		RET
		
		;Loading and displaying data into different displays
LOAD4:
		;Checking if its AM or PM if its PM the . at the right most display will be turned on and its AM it will turn off
		CLR A
		MOV B, #00H
		MOV A, R5
		MOV B, #02H
		DIV AB
		MOV A, B
		CJNE A, #00H, CHANGE
		MOV DPTR, #2000H
		JMP SKIP1
		CHANGE: MOV DPTR, #1000H
		SKIP1: MOV A, R0
		MOV P1, A
		MOV A, R4
		MOVC A, @A+DPTR
		MOV P3, A
		MOV A, R0
		RL A
		MOV R0, A
RET
LOAD3:
		MOV DPTR, #1000H
		MOV A, R0
		MOV P1, A
		MOV A, R3
		MOVC A, @A+DPTR
		MOV P3, A
		MOV A, R0
		RL A
		MOV R0, A
RET
LOAD2:
		MOV DPTR, #1000H
		MOV A, R0
		MOV P1, A
		MOV A, R2
		MOVC A, @A+DPTR
		MOV P3, A
		MOV A, R0
		RL A
		MOV R0, A
RET
LOAD1:
		MOV DPTR, #1000H
		MOV A, R0
		MOV P1, A
		MOV A, R1
		MOVC A, @A+DPTR
		MOV P3, A
		MOV A, R0
		RL A
		MOV R0, A
RET
			
	;7 Segment display encoded data for 0 to 9 without '.'
ORG 1000H
		DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 98H
	;7 Segment display encoded data for 0 to 9 with '.'
ORG 2000H
		DB 40H, 79H, 24H, 30H, 19H, 12H, 02H, 78H, 00H, 18H
	;End of the code 
END