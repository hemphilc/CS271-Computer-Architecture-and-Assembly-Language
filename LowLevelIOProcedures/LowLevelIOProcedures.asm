TITLE Designing Lower-Level I/O Procedures		(Prog06A.asm)

; Author: Corey Hemphill (hemphilc@oregonstate.edu)
; Title: Program 6A
; Date: 11/27/2015
; Course / Project ID: CS271-400 / Prog06A
; Description: "Designing Lower-Level I/O Procedures" -- This 
;	program reads in a set of 10 unsigned integer values from
;	the user. It then prints the input values, calculates the
;	sum and the average of the values in the array, then
;	displays the sum and the average to the console.
;
; Note: This program performs rudimentary data validation. If
;	the user enters an invalid integer less than 0 or greater
;	than 4,294,967,295, an error message is displayed and the 
;	user is reprompted to enter a valid input. In addition,
;	the maximum intake number length is 10. If there are more
;	than 10 digits, the subsequent values are ignored.
;
INCLUDE Irvine32.inc
; Global Constants----------------------------------------------------
MAX_LENGTH	EQU <11>			; Maximum Length of String + 1 (for null)
LIST_SIZE	EQU <10>			; Size of User Input Value Array

; Macros--------------------------------------------------------------
displayString MACRO	stringOut
	push	edx
	mov		edx, stringOut
	call	WriteString
	pop		edx
ENDM

getString MACRO	inputBuffer, stringSize
	LOCAL	prompt
	.data
	prompt 	BYTE 'Please enter an unsigned integer [0 .. 4,294,967,295]: ',0
	.code
	pushad
	mov		edx, OFFSET prompt
	displayString	edx
	mov		edx, inputBuffer
	mov		ecx, MAX_LENGTH
	call	ReadString
	mov		stringSize, eax
	popad
ENDM

.data
numList		DWORD	LIST_SIZE DUP(?)
numSum		DWORD	?
numAve		DWORD	?
	
; Print Statements----------------------------------------------------
greet1  	BYTE 	'Welcome to "Designing Lower-Level I/O Procedures"',0dh,0ah,0
prgauth 	BYTE 	'Programmed by Corey Hemphill',0dh,0ah,0
progdesc 	BYTE 	'Please enter 15 unsigned decimal integers.',0dh,0ah
			BYTE	'Each integer must be small enough to fit into a 32-bit register [0 .. 4,294,967,295].',0dh,0ah
			BYTE	'After the you finish inputting the integers, this program will display a list',0dh,0ah
			BYTE	'of the integers, their sum, and their average value.',0dh,0ah,0
listNums	BYTE	'You entered the following unsigned integers:',0dh,0ah,0
sumNums		BYTE	'The sum of the unsigned integers is: ',0
aveNums		BYTE	'The average of the unsigned integers is: ',0
farewell	BYTE	'Thanks for playing! Goodbye.',0dh,0ah,0

.code
main PROC
	; Introduction
	push	OFFSET greet1
	push	OFFSET prgauth
	push	OFFSET progdesc
	call 	Introduction

	; Read in the values from the User
	push	OFFSET	numList
	call	ReadVal

	; Calculate the Sum and Average
	push 	OFFSET numList
	call 	GetCalcs
	pop 	numSum			; Save sum
	pop 	numAve			; Save average

	; Print each of the array's values
	push 	OFFSET listNums
	push 	OFFSET numList
	call 	PrintNumList
	
	; Print sum and average of the array
	push 	OFFSET aveNums
	push 	numAve
	push 	OFFSET sumNums
	push 	numSum	
	call	PrintCalcs
	
	; Say Goodbye
	push	OFFSET	farewell
	call	Goodbye
	
	invoke ExitProcess,0
main ENDP

;---------------------------------------------------------------------
; Procedure greets the user, displays the program author's name,
;		and displays instructions to the user for input.
; Receives: @greet1, @prgauth, and @progdesc.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EDX
;---------------------------------------------------------------------
Introduction PROC
	push	edx
	push	ebp
	mov 	ebp, esp
	mov		edx, [ebp+20]
	displayString	edx			; Greeting
	mov		edx, [ebp+16]
	displayString	edx			; Author
	call	Crlf
	mov		edx, [ebp+12]
	displayString	edx			; Program Description
	call 	Crlf
	pop		ebp
	pop		edx
	ret		12
Introduction ENDP


;---------------------------------------------------------------------
; Procedure invokes the getString macro to get the user's string of 
;		digits, converts the digit string to numeric, and validates the
;		user's inputs.
; Receives: @numList array
; Returns: numList is filled with the user's inputs.
; Preconditions: (none)
; Registers Changed: EAX, ECX, EDX
;---------------------------------------------------------------------
ReadVal PROC
	.data
	stringIn 	BYTE  MAX_LENGTH DUP(0)
	strLen		DWORD 0
	oorfail		BYTE 'Out of range or not a number. Please enter an unsigned integer [0 .. 4,294,967,295].',0dh,0ah,0
	.code
	push	ebp
	mov 	ebp, esp
	mov		ecx, LIST_SIZE
	lea		esi, stringIn 			; @stringIn  OFFSET
	mov		edi, [ebp+8]			; @numList OFFSET
	topOutter:
		pushad						; Save all registers
		jmp 	getInput
	inputError:
		lea		edx, oorfail		; Print the error message
		displayString	edx
		call	Crlf
		lea		esi, stringIn		; Try again
	; Get the Input
	getInput:
		getString esi, strLen
		mov		ecx, strLen			; Move size of string into ECX 
		cmp 	ecx, 0				; If ECX = 0, string is empty
		je		done
		xor		edx, edx			; Clear EDX
		xor		eax, eax			; Clear EAX
		cld
	; Validate the input
	topInner:
		lodsb						; Load a byte from the string
		cmp		al, 57				; ASCII - 9
		jg		inputError			; If greater, its not a number
		cmp		al, 48				; ASCII - 0
		jl		inputError			; If less, its not a number
	insert:							; The value must be a number
		imul	edx, edx, 10		; Multiply by respective 10's column
		sub		eax, 48				; Convert to number from ASCII
		add 	edx, eax			; Add it to the accumulator register
		jc		inputError			; If carry flag is set, the value was too large
		loop	topInner
		mov		[edi], edx			; The integer is valid, move it into the array
		popad
		cmp		ecx, 0				; If the loop counter is 0, break and end
		je		done
		add		edi, 4				; Otherwise, increase EDI by 4 to point to the next array position
		loop	topOutter
	done:
	call	Crlf
	pop		ebp
	ret		12
ReadVal ENDP


;---------------------------------------------------------------------
; Procedure invokes NumToStrings procedure to converts numeric value 
;		to a string of digits, and invokes the displayString macro to 
;		produce the output.
; Receives: An unsigned integer value.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EAX, EDX
;---------------------------------------------------------------------
WriteVal PROC
	LOCAL 	stringOut[MAX_LENGTH]:BYTE
	lea 	eax, stringOut			; @stringOut
	push 	eax						; Push @stringOut onto the stack
	push 	[ebp+8]					; Push the current value onto stack
	call 	NumToString				; Convert the value to string
	lea 	eax, stringOut			; @stringOut
	displayString 	eax				; Print the string (value)
	ret 4
WriteVal ENDP


;---------------------------------------------------------------------
; Procedure converts an unsigned integer value to a string of chars.
; Receives: @stringOut and an unsigned integer value
; Returns: A string of digits.
; Preconditions: Value must be an unsigned integer.
; Registers Changed: EAX, EBX, ECX, EDI
;---------------------------------------------------------------------
NumToString PROC
	LOCAL 	val:DWORD				; Temporary storage value
	push	ecx
	mov 	eax, [ebp+8]			; @stringOut OFFSET
	mov		ebx, LIST_SIZE
	xor 	ecx, ecx				; Clear ECX to zero
	top1:
		xor 	edx, edx			; Clear EDX to zero
		div 	ebx
		push 	edx					; Push Remainder onto stack
		inc 	ecx					; Add one to ECX
		test 	eax, eax			; Test EAX, if not zero, continue loop
		jnz 	top1
	mov 	edi, [ebp+12]			; Set EDI to the @stringOut OFFSET
	top2:
		pop 	val					; Pop value off of the stack
		mov 	al, BYTE PTR val	; Use PTR to move tempVal into AL
		add 	al, 48				; Convert to ASCII value
		stosb						; Store the character in EDI
		loop 	top2
	mov 	al, 0					; Move the null terminator into AL
	stosb							; Store the null terminator
	pop		ecx
	ret 	8
NumToString ENDP


;----------------------------------------------------------------------
; Procedure prints all of the elements of a given array.
; Receives: @listNums, @numList
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EBX, ECX, EDX, ESI
;----------------------------------------------------------------------
PrintNumList PROC
	.data
	space	BYTE ', ',0
	.code	
	push 	ebp
	mov 	ebp, esp
	mov 	edx, [ebp+12]			; @listNums message
	displayString	edx
	mov 	esi, [ebp+8]			; @numList OFFSET
	mov 	ecx, LIST_SIZE
	xor 	ebx, ebx
	printLoop:
		push 	[esi]				; Push the array OFFSET onto the stack
		call 	WriteVal			; Call WriteVal to print current item
		cmp		ecx, 1				; If ECX = 1, do not print another comma
		je		here
		lea 	edx, space			; @space for comma and space
		displayString	edx
		add 	esi, 4				; Increment ESI to the next array position
	here:
		loop 	printLoop
	call	Crlf
	pop 	ebp
	ret 	12
PrintNumList ENDP


;----------------------------------------------------------------------
; Procedure prints the sum and the average values from an array.
; Receives: @numAve, @numSum, @aveNums message, @sumNums message.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EAX, EDX
;----------------------------------------------------------------------
PrintCalcs PROC
	push	ebp
	mov		ebp, esp
	mov 	edx, [ebp+12]			; @sumNums message
	call	Crlf
	displayString	edx
	mov 	eax, [ebp+8]			; numSum
	push 	eax
	call 	WriteVal				; Call WriteVal to Print Sum
	call 	Crlf
	mov 	edx, [ebp+20]			; @aveNums message
	call	Crlf
	displayString	edx
	mov 	eax, [ebp+16]			; numAve
	push 	eax
	call 	WriteVal				; Call WriteVal to Print Average
	call 	Crlf
	pop		ebp
	ret		16
PrintCalcs ENDP


;---------------------------------------------------------------------
; Procedure calculates and returns the sum and the average value of an
;		array of 10 unsigned integer values
; Receives: @numList
; Returns: An integer sum and an integer average of the array values.
; Preconditions: (none)
; Registers Changed: EAX, ECX, ESI
;---------------------------------------------------------------------
GetCalcs PROC
	LOCAL 	sum:DWORD, 				; Temporary sum variable
			ave:DWORD, 				; Temporary average variable
			divisor:DWORD			; Temporary divisor variable
	xor		eax, eax				; Clear eax to zero
	mov 	esi, [ebp+8]			; @numList OFFSET
	mov 	ecx, LIST_SIZE			; Initialize counter to LIST_SIZE (10)
	mov 	divisor, LIST_SIZE		; Set divisor to LIST_SIZE (10)
	topSum:
		add 	eax, [esi]			; Add the current array value to the sum
		add 	esi, 4				; Increment ESI to next array position
		loop 	topSum
	mov 	sum, eax				; Move the sum into the sum variable
	fild 	sum						; Load the sum from memory
	fidiv 	divisor					; Divide the sum by the divisor
	fistp 	ave						; Store the average value
	mov 	eax, sum				; Push the sum value onto the stack
	mov 	[ebp+8], eax			
	mov 	eax, ave				; Push the average value onto the stack
	mov 	[ebp+12], eax
	ret								; Return 0 bytes -> results will be erased
GetCalcs ENDP


;---------------------------------------------------------------------
; Procedure prints a farewell message to the user.
; Receives: farewell by reference.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EDX
;---------------------------------------------------------------------
Goodbye PROC
	push	edx
	push	ebp
	mov 	ebp, esp
	mov		edx, [ebp+12]			; @farewell OFFSET
	call	Crlf
	displayString	edx
	call	Crlf
	pop		ebp
	pop		edx
	ret		4
Goodbye ENDP

end main