TITLE Integer Accumulator		(Prog03.asm)

; Author: Corey Hemphill (hemphilc@oregonstate.edu)
; Title: Program 3
; Date: 11/1/2015
; Course / Project ID: CS271-400 / Prog03
; Description: "Integer Accumulator" -- This program greets
;	and requests the user to input their name. The program then
;	prompts the user to enter negative integers in the range of
;	[-100 .. -1]. When finished entering negative integers, the 
;	user must enter a positive value (0 included) to view the
;	results of the accumulator. The program then prints the number
;	of valid inputs entered, the sum of the inputs, and the
;	average of the inputs.
;
;	Note: This program performs rudimentary data validation. If
;	the user enters an invalid integer less than -100, an error
;	message is displayed and the user is prompted to enter a
;	valid input. If the user enters a number greater than -1
;	without first entering any valid inputs, the program displays
;	a special message and then terminates.
;
INCLUDE Irvine32.inc

	NAME_LENGTH EQU <20>
	RANGE_LOW   EQU	<-100>
	RANGE_HIGH  EQU	<-1>

.data
	sumVal	DWORD  0	; Stores the sum the values entered
	count	DWORD  0	; Counts total number of values entered
	lineCnt DWORD  1	; Number for lines of user input

	; Print Statements
	usrname BYTE  ?
	greet1  BYTE 'Welcome to "Integer Accumulator"',0dh,0ah,0
	prgauth BYTE 'Programmed by Corey Hemphill',0dh,0ah,0
	exCred	BYTE '**EC: Program numbers the lines during user input.',0dh,0ah,0
	instrn1 BYTE 'What is your name? ',0
	greet2  BYTE 'Hello, ',0
	punct   BYTE '. ',0
	instrn2 BYTE 'Enter negative numbers in the range of [-100 .. -1].',0dh,0ah,0
	instrn3 BYTE 'When you are finished, please enter a non-negative number to view the accumulator results. ',0dh,0ah,0
	instrn4 BYTE 'Enter a number: ',0
	oorfail BYTE 'Out of range. Please enter a number in [-100 .. -1].',0dh,0ah,0
	cnfirm1 BYTE 'You entered ',0
	cnfirm2 BYTE ' valid negative number(s).',0dh,0ah,0
	noNums  BYTE 'You did not enter any valid negative numbers.',0dh,0ah,0
	prntSum BYTE 'The sum of the numbers entered is ',0
	prntAve BYTE 'The rounded average of the numbers is ',0
	thanks  BYTE 'Thanks for playing Integer Accumulator!',0dh,0ah,0
	goodbye BYTE 'That is all. Goodbye, ',0

.code
main proc
; Initial Greeting & Introduction
	call Clrscr
	mov	edx, OFFSET greet1
	call WriteString
	mov edx, OFFSET prgauth
	call WriteString
	mov edx, OFFSET exCred	; Extra Credit Statement
	call WriteString
	call Crlf

; Prompt User to Enter Name & Welcome
	mov edx, OFFSET instrn1
	call WriteString
	mov edx, OFFSET usrname
	mov ecx, NAME_LENGTH	; Set max char length for usrname 
	call ReadString
	call Crlf
	mov edx, OFFSET greet2
	call WriteString
	mov edx, OFFSET usrname
	call WriteString
	mov edx, OFFSET punct
	call WriteString
	call Crlf
	call Crlf
	
; Provide Instruction & Prompt User for Inputs
	mov edx, OFFSET instrn2
	call WriteString
	mov edx, OFFSET instrn3
	call WriteString
	call Crlf
	
; Begin Loop for Obtaining User Input
	getNumbers:
	mov eax, lineCnt
	call WriteDec
	mov edx, OFFSET punct
	call WriteString
	inc lineCnt
	mov edx, OFFSET instrn4
	call WriteString
	call ReadInt
	cmp eax, RANGE_LOW
	jl 	rangeError		; Check value is < -100
	cmp eax, RANGE_HIGH
	jg  printResult		; Check value is > -1
	mov ebx, sumVal
	add	ebx, eax
	mov sumVal, ebx
	inc count
	jmp getNumbers
	
	rangeError:		; Input is bad --> Print Range Error Message
	mov edx, OFFSET oorfail
	call WriteString
	jmp getNumbers	; Try again...

; Print the Sum and Average of the User Inputs
	printResult:
	call Crlf
	mov eax, count	; If count < 1, jump to noInput, print message, & proceed to end program
	cmp eax, 1
	jl noInput
	mov edx, OFFSET cnfirm1	; Print Total Number of Numbers Entered
	call WriteString
	call WriteDec
	mov edx, OFFSET cnfirm2
	call WriteString
	mov edx, OFFSET prntSum	; Print Sum
	call WriteString
	mov eax, sumVal
	call WriteInt
	call Crlf
	mov edx, OFFSET prntAve
	call WriteString
	mov eax, sumVal	 ; Compute & Print Average
	cdq
	mov ebx, count
	idiv ebx
	call WriteInt
	call Crlf
	jmp endProg	; Proceed to End Program
	
; User Did Not Provide Valid Input --> Print Message
	noInput:
	mov edx, OFFSET noNums
	call WriteString
	
; Thank User for Playing, Say Goodbye & End Program
	endProg:
	call Crlf
	mov edx, OFFSET thanks
	call WriteString
	mov edx, OFFSET goodbye
	call WriteString
	mov edx, OFFSET usrname
	call WriteString
	mov edx, OFFSET punct
	call WriteString
	call Crlf
	call Crlf
	
	invoke ExitProcess,0
main endp
end main