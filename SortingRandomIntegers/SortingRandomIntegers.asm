TITLE Sorting Random Integers		(Prog05.asm)

; Author: Corey Hemphill (hemphilc@oregonstate.edu)
; Title: Program 5
; Date: 11/22/2015
; Course / Project ID: CS271-400 / Prog05
; Description: "Sorting Random Integers" -- This program generates
;	random numbers in the range of [100 .. 999], displays the 
;	original list, sorts the list, and calculates the median value.
;	Finally, it displays the list sorted in descending order.
;
; Note: This program performs rudimentary data validation. If
;	the user enters an invalid integer less than 10 or greater
;	than 200, an error message is displayed and the user is
;	reprompted to enter a valid input.
;
INCLUDE Irvine32.inc
	; Global Constant Variables
	VALID_LOW	EQU <10>	; Lowest userNum value
	VALID_HIGH	EQU <200>	; Highest userNum value
	RANGE_LOW   EQU	<100>	; Lowest Random Range value
	RANGE_HIGH  EQU	<999>	; Highest Random Range value
	LINE_BREAK  EQU <10>	; Print line-break at 10 values
	MAX_SIZE	EQU <200>	; Maximum Array Size
.data
	; Global Variables
	userNum		DWORD  	?
	numList		DWORD	MAX_SIZE DUP(?)
	; Print Statements
	greet1  	BYTE 	'Welcome to "Sorting Random Integers"',0dh,0ah,0
	prgauth 	BYTE 	'Programmed by Corey Hemphill',0dh,0ah,0
	progdesc1 	BYTE 	'This program generates random numbers in the range of [100 .. 999],',0dh,0ah,0
	progdesc2	BYTE 	'displays the original list, sorts the list, and calculates the',0dh,0ah,0
	progdesc3 	BYTE 	'median value. Finally, it displays the list sorted in descending order.',0dh,0ah,0
	instrn1		BYTE 	'How many numbers should be generated [10 .. 200]?: ',0
	oorfail 	BYTE 	'Out of range. Please enter a number in [10 .. 200].',0dh,0ah,0
	median		BYTE	'Random List Median Value: ',0
	space   	BYTE 	'   ',0	
	; Titles
	unsorted	BYTE	'Unsorted Random Number List:',0dh,0ah,0
	sorted		BYTE	'Sorted Random Number List:',0dh,0ah,0
.code
main PROC
	; Seed Random Numbers
	call 	Randomize
	
	; Introduction
	call 	introduction
	
	; Get Data
	push 	OFFSET userNum	; Parameter @userName (reference)
	call 	getData
	
	; Fill Array
	push	OFFSET numList	; Parameter @numList (reference)
	push	userNum			; Parameter userName (value)
	call	fillArray
	
	; Display Unsorted List
	push 	OFFSET unsorted	; Parameter @title1 (reference)
	push	OFFSET numList  ; Parameter @numList (reference)
	push	userNum			; Parameter userNum (value)
	call	displayList
	
	; Sort List
	push	OFFSET numList	; Parameter @numList (reference)
	push	userNum			; Parameter userName (value)
	call	sortList
	
	; Display Median
	push 	OFFSET numList	; Parameter @numList (reference)
	push 	userNum			; Parameter userName (value)
	call	displayMedian
	
	; Display Sorted List
	push 	OFFSET sorted	; Parameter @title1 (reference)
	push	OFFSET numList  ; Parameter @numList (reference)
	push	userNum			; Parameter userNum (value)
	call	displayList
	
	invoke ExitProcess,0
main ENDP

;---------------------------------------------------------------------
; Procedure greets the user, displays the program author's name,
;		and displays instructions to the user for input.
; Receives: Global variables greet1, prgauth, progdesc1, progdesc2,
;		and progdesc3.
; Returns: Does not return anything other than printing to console.
; Preconditions: (none)
; Registers Changed: EDX
;---------------------------------------------------------------------
introduction PROC
	call 	Clrscr	
	mov 	edx, OFFSET greet1			; Greeting
	call 	WriteString
	mov 	edx, OFFSET prgauth			; Author
	call 	WriteString
	call 	Crlf
	mov 	edx, OFFSET progdesc1		; Program Description line 1
	call 	WriteString
	mov 	edx, OFFSET progdesc2		; Program Description line 2
	call 	WriteString
	mov 	edx, OFFSET progdesc3		; Program Description line 3
	call 	WriteString
	call 	Crlf
	ret
introduction ENDP

;---------------------------------------------------------------------
; Procedure prompts the user to enter an value that represents the
;		number of random values to printed, validates the input and
;		returns the value by reference.
; Receives: Variable userNum to store user input.
; Returns: User input as userNum by reference.
; Preconditions: (none)
; Registers Changed: EAX, EBX, EDX
;---------------------------------------------------------------------
getData PROC
	push 	ebp
	mov 	ebp, esp
	mov 	ebx, [ebp+8]
	top:
		mov 	edx, OFFSET instrn1
		call 	WriteString
		call 	ReadInt
		cmp 	eax, VALID_LOW
		jl 		rangeError		; Error if EAX < 10
		cmp 	eax, VALID_HIGH
		jg 		rangeError		; Error if EAX > 200
		jmp 	break			; Input is good
		rangeError:				; Input is not good --> print error message
			call 	Crlf
			mov 	edx, OFFSET oorfail
			call 	WriteString
			call	Crlf
			jmp 	top			; Try again
	break:
	mov		[ebx], eax
	pop 	ebp
	ret		4
getData ENDP

;---------------------------------------------------------------------
; Procedure fills the specified array with random integer values.
; Receives: Variables numList and userNum.
; Returns: An array filled with random integers.
; Preconditions: userNum > 0
; Registers Changed: EAX, ECX, EDX, ESI
;---------------------------------------------------------------------
fillArray PROC
	push 	ebp
	mov 	ebp, esp
	mov 	ecx, [ebp+8]		; userNum
	mov		esi, [ebp+12]		; numList offset
	; High - Low = RANGE
	mov 	edx, RANGE_HIGH
	inc		edx					; include 999
	sub		edx, RANGE_LOW
	top:
		mov		eax, edx		; Obtain the absolute range
		call	RandomRange
		add		eax, RANGE_LOW	; Add RANGE_LOW and bias the resulting value
		mov		[esi], eax		; Insert the random value into the array
		add		esi, 4			; Move ESI forward to point at next value
		loop 	top
	pop		ebp
	ret		8
fillArray ENDP

;---------------------------------------------------------------------
; Procedure receives an unsorted array and sorts the array
;		using bubble sort algorithm.
; Receives: Variables numList and userNum.
; Returns: A sorted array list.
; Preconditions: userNum > 0
; Registers Changed: EAX, ECX, ESI
;---------------------------------------------------------------------
sortList PROC
	push	ebp
	mov 	ebp, esp
	mov 	ecx, [ebp+8]	; userNum
	dec		ecx				; Dec count by 1
	; BubbleSort --> Referenced from "Assembly Language for x86 Processors" - Kip Irvine --> pg 375
	L1:
		push 	ecx				; Push and save outer loop counter
		mov		esi, [ebp+12]	; numList offset
	L2:
		mov 	eax, [esi]		; Get current value
		cmp		[esi+4], eax	; Compare the current value with the next value in the array
		jl		L3				; If [ESI] >= [ESI+4], do NOT exchange the values
		xchg	eax, [esi+4]	; Else perform the exchange
		mov		[esi], eax
	L3:
		add		esi, 4			; Move ESI forward to point at next value
		loop	L2				; Continue inner loop
		pop		ecx				; If finished with inner loop, pop outer loop counter off the stack and continue
		loop	L1				; Repeat outer loop if necessary
	pop 	ebp
	ret		8
sortList ENDP

;---------------------------------------------------------------------
; Procedure finds and displays the median value from a sorted
;		array.
; Receives: Variables numList and userNum.
; Returns: The median value from the sorted array.
; Preconditions: numList must be sorted, userNum > 0
; Registers Changed: EAX, EBX, EDX, ESI
;---------------------------------------------------------------------
displayMedian PROC
	push	ebp
	mov 	ebp, esp
	; Referenced from "Assembly Language for x86 Processors" - Kip Irvine --> pg 377
	mov		eax, [ebp+8]	; userNum - 1
	dec		eax
	mov		ebx, [ebp+12]	; numList offset
	shr		eax, 1
	mov		esi, eax
	shl		esi, 2			; Scale mid by 4
	mov		eax,[ebx+esi]	; Move the middle value into EAX
	mov 	edx, OFFSET median
	call	Crlf
	call 	WriteString
	call	WriteDec		; Print middle value
	call 	Crlf
	pop 	ebp
	ret 	8 
displayMedian ENDP

;---------------------------------------------------------------------
; Procedure prints out the contents of an array to the console.
; Receives: Variables title1, numList, and userNum.
; Returns: Does not return anything other than printing the 
; 		contents of the array to the console.
; Preconditions: userNum > 0
; Registers Changed: EAX, EBX, ECX, EDX, ESI
;---------------------------------------------------------------------
displayList PROC
	push	ebp
	mov 	ebp, esp
	mov		ecx, [ebp+8]	; userNum
	mov		esi, [ebp+12]	; numList offset
	mov		edx, [ebp+16]	; title offset
	call 	Crlf
	call	WriteString
	mov		ebx, 0
	top:
		mov		eax, [esi]	; Get current value
		call	WriteDec	; Print current value
		mov 	edx, OFFSET space
		call 	WriteString
		inc 	ebx
		; Break the line every 10 values
		cmp 	ebx, LINE_BREAK
		jne 	next
		call 	Crlf
		mov 	ebx, 0		; Reset break-line counter
		next: 
			add		esi, 4	; Inc pointer to next value
			loop 	top
	call 	Crlf
	pop 	ebp
	ret 	12
displayList ENDP

end main
