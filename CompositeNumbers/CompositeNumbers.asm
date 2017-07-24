TITLE Composite Numbers		(Prog04.asm)

; Author: Corey Hemphill (hemphilc@oregonstate.edu)
; Title: Program 4
; Date: 11/8/2015
; Course / Project ID: CS271-400 / Prog04
; Description: "Composite Numbers" -- This program greets
;	the user, then prompts the user to enter an integer value 
;	in the range of [1 .. 400] that represents the number of
;	composite numbers they would like to see printed to the console. 
;	The program then prints out the composite numbers requested by 
;	the user, and then says farewell.
;
; Note: This program performs rudimentary data validation. If
;	the user enters an invalid integer less than 1 or greater
;	than 400, an error message is displayed and the user is
;	reprompted to enter a valid input.
;
INCLUDE Irvine32.inc

	RANGE_LOW   EQU	<1>		; Lowest Range value
	RANGE_HIGH  EQU	<400>	; Highest Range value
	LINE_BREAK  EQU <10>	; Print line-break at 10 values

.data
	userNum		DWORD  ?	; User input variable
	isValid		DWORD  0	; Validation boolean initialized to false (0)
	n			DWORD  4	; n = a * b -> n initialized to 4
	breakCount	DWORD  0	; Counting variable for line breaks
	
	; Print Statements
	greet1  	BYTE 'Welcome to "Composite Numbers"',0dh,0ah,0
	prgauth 	BYTE 'Programmed by Corey Hemphill',0dh,0ah,0
	instrn1 	BYTE 'Enter the number of composite numbers that you would like to see.',0dh,0ah,0
	instrn2		BYTE 'I will accept no less than 1 and no more than 400 composites.',0dh,0ah,0
	instrn3 	BYTE 'Enter the number of composites to be displayed [1 .. 400]: ',0
	oorfail 	BYTE 'Out of range. Please enter a number in [1 .. 400].',0dh,0ah,0
	space   	BYTE '   ',0
	authcrt 	BYTE 'These results are certified correct.',0dh,0ah,0
	goodbye 	BYTE 'That is all. Goodbye!',0dh,0ah,0
	
.code
main proc

	call introduction
	call getUserData
	call showComposites
	call farewell

	invoke ExitProcess,0
main endp


; Procedure greets the user, displays the program author's name,
;		and displays instructions to the user for input.
; Receives: Global variables greet1, prgauth, instrn1, and instrn2.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EDX
introduction PROC
	call Clrscr
	mov edx, OFFSET greet1
	call WriteString
	mov edx, OFFSET prgauth
	call WriteString
	call Crlf
	mov edx, OFFSET instrn1
	call WriteString
	mov edx, OFFSET instrn2
	call WriteString
	call Crlf
	ret
introduction ENDP


; Procedure acquires user input data and calls validate function to 
;		check that the input is legal.
; Receives: Global variables instrn3, userNum, and isValid.
; Returns: userNum if validate function returns isValid as TRUE.
; Preconditions: (none)
; Registers Changed: EAX, EDX
getUserData PROC
	top:
		mov edx, OFFSET instrn3
		call WriteString
		call ReadInt		; Read in the user's input
		mov userNum, eax
		call validate		; Check its validity
		cmp isValid, 1
		jne top				; If isValid is FALSE (0), try again...
		ret
getUserData ENDP


; Procedure checks userNum is in the range of 0 < userNum <= 400
;		and sets a boolean value to 1 if TRUE, 0 if FALSE.
; Receives: Global variables userNum and isValid.
; Returns: userNum and isValid.
; Preconditions: isValid = FALSE
; Registers Changed: EAX, EBX, EDX
validate PROC
	mov ebx, 0		; Set boolean to FALSE (0)
	mov isValid, ebx
	mov eax, userNum
	cmp eax, RANGE_LOW
	jl rangeError	; Error if n < 1
	cmp eax, RANGE_HIGH
	jg rangeError	; Error if n > 400
	; Input must be good
	call Crlf
	mov ebx, 1
	mov isValid, ebx	; Set boolean to TRUE (1)
	ret 			; Return to getUserData procedure
	rangeError:		; Input is not good --> print error message
		call Crlf
		mov edx, OFFSET oorfail
		call WriteString
		ret			; Return to getUserData procedure
validate ENDP


; Procedure prints out the number of composite values that the 
;		user indicates.
; Receives: Global variables userNum, n, space, and breakCount.
; Returns: Prints current value of n to the console.
; Preconditions: 0 < userNum <= 400, n = 4
; Registers Changed: EAX, EBX, ECX, EDX
showComposites PROC
	sub ecx, ecx
	mov ecx, userNum	; Set outside loop to print userNum of composite values
	top:
		mov eax, n
		call WriteDec
		mov edx, OFFSET space
		call WriteString
		inc breakCount
		; Break the line every 10 values
		mov ebx, breakCount
		cmp ebx, LINE_BREAK
		jne next
		call Crlf
		mov ebx, 0
		mov breakCount, ebx	; Reset breakCount
		; Find the next composite value
		next:
			call isComposite
	loop top
	call Crlf
	ret
showComposites ENDP


; Procedure checks to see if current n value is a composite
;		value and if it is not, increments n and tries again.
; Receives: Global variable n.
; Returns: Current value of n.
; Preconditions: n > 0
; Registers Changed: EAX, EBX, EDX
isComposite PROC
	top:
		inc n		; Increment n
		mov ebx, n	; Set EBX to the current value of n
		; Factor n out
		factor:
			mov eax, n
			dec ebx		; Decrement EBX by 1 -> initially will be (n-1)
			cmp ebx, 0	; Check to see if EBX is 0, if so, n is not composite -> try a new n
			je top
			mov edx, 0
			div ebx		; Divide n by the value in EBX (0 < EBX < n)
			checkRemainder:
				cmp edx, 0		; If the remainder is zero, check the quotient
				je checkQuotient
				jmp factor
			checkQuotient:
				cmp eax, n		; If the quotient is not equal to n, the value is composite
				jne break		; Jump to break the loop
				jmp top			; Value is not composite, jump to top and try again...
	break:
		ret		; Return n to showComposites
isComposite ENDP


; Procedure prints the authors certification of the data and says
;		'goodbye' to the user.
; Receives: Global variables authcrt and goodbye.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EDX
farewell PROC
	call Crlf
	mov edx, OFFSET authcrt
	call WriteString
	call Crlf
	mov edx, OFFSET goodbye
	call WriteString
	call Crlf
	ret
farewell ENDP

end main