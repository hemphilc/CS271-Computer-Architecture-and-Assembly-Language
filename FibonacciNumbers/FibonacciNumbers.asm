TITLE Fibonacci Numbers		(Prog02.asm)

; Author: Corey Hemphill (hemphilc@oregonstate.edu)
; Title: Program 2
; Date: 10/11/2015
; Course / Project ID: CS271-400 / Prog02
; Description: "Fibonacci Numbers" -- This program greets
;	and requests the user to input their name. The program
;	then requests the user to enter the number of Fibonacci
;	terms they'd like to be displayed, then calculates and
;	prints all of the Fibonacci numbers up to and including
;	the nth term.

;	Note: This program performs rudimentary data validation.
;	If the user enters an integer that is less than 1 or
;	greater than 46, an error message will be displayed and 
;	the user will be directed to enter a new value. There
;	is also a 20 character max to the user name input.

INCLUDE Irvine32.inc

	RANGE_LOW   EQU	<1>
	RANGE_HIGH  EQU	<46>
	NAME_LENGTH EQU <20>
	LINE_BREAK  EQU <5>

.data
	; Variables
	n		DWORD  ?  	; Number of Fibonacci Terms Specified by User
	val1 	DWORD  0  	; First Fibonacci Value
	val2 	DWORD  1  	; Second Fibonacci Value
	sumVal	DWORD  ?	; Sum
	count	DWORD  0	; Count Variable
	
	; Print Statements
	usrname BYTE   ?
	greet1  BYTE 'Welcome to "Fibonacci Numbers"',0dh,0ah,0
	prgauth BYTE 'Programmed by Corey Hemphill',0dh,0ah,0
	instrn1 BYTE 'What is your name?: ',0
	greet2  BYTE 'Hello, ',0
	punct   BYTE '.',0dh,0ah,0
	space   BYTE '     ',0
	instrn2 BYTE 'Please enter the number of Fibonacci numbers to be displayed.',0dh,0ah,0
	instrn3 BYTE 'Provide the number as an integer in the range of [1 .. 46]. ',0dh,0ah,0
	instrn4 BYTE 'How many Fibonacci terms would you like?: ',0
	oorfail BYTE 'Out of range. Please enter a number in [1 .. 46].',0dh,0ah,0
	authcrt BYTE 'These results are certified correct.',0dh,0ah,0
	goodbye BYTE 'That is all. Goodbye, ',0
	
.code
main proc
; Greeting & Introduction
	introduction:
	call Clrscr
	mov	edx, OFFSET greet1
	call WriteString
	mov edx, OFFSET prgauth
	call WriteString
	call Crlf
	
; Prompt User for Input
	userInstructions:
	mov edx, OFFSET instrn1
	call WriteString
	mov edx, OFFSET usrname
	mov ecx, NAME_LENGTH
	call ReadString
	call Crlf
	mov edx, OFFSET greet2
	call WriteString
	mov edx, OFFSET usrname
	call WriteString
	mov edx, OFFSET punct
	call WriteString
	call Crlf
	mov edx, OFFSET instrn2
	call WriteString
	mov edx, OFFSET instrn3
	call WriteString
	call Crlf
	getUserData:
	mov edx, OFFSET instrn4
	call WriteString
	call ReadInt
	mov n, eax		; Validate User Input
	cmp eax, RANGE_LOW
	jl 	rangeError	; Error if n < 1
	cmp eax, RANGE_HIGH
	jg  rangeError	; Error if n > 46
	call Crlf
	jmp displayFibs	; Input is good
	rangeError:
	call Crlf
	mov edx, OFFSET oorfail
	call WriteString
	jmp getUserData ; Input is bad -> Try again...
	
; Calculate & Print Fibonacci Terms for Specified Range
	displayFibs:
	mov ecx, n
	calculate:
	mov eax, val2
	call WriteDec
	mov edx, OFFSET space	
	call WriteString
	add eax, val1
	mov sumVal, eax
	mov eax, val2
	mov val1, eax
	mov eax, sumVal
	mov val2, eax
	
; Every Five Terms, Breakline
	inc count
	mov eax, count
	cmp eax, LINE_BREAK
    je breakLine
	jmp nextCalc
	breakLine:
	call Crlf
	sub eax, eax
	mov count, eax
	nextCalc:
	loop calculate ; Continue Loop
	
; Say Goodbye & End Program
	farewell:
	call Crlf
	call Crlf
	mov edx, OFFSET authcrt
	call WriteString
	call Crlf
	mov edx, OFFSET goodbye
	call WriteString
	mov edx, OFFSET usrname
	call WriteString
	mov edx, OFFSET punct
	call WriteString
	call Crlf
	invoke ExitProcess,0
main endp
end main