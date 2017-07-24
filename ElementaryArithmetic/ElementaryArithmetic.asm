; Author: Corey Hemphill
; Title: Program 1
; Date: 10/4/2015
; Course / Project ID: CS271-400 / Prog01
; Description: "Elementary Arithmetic"

INCLUDE Irvine32.inc

.data
	; Variables
	num1	DWORD  ?
	num2	DWORD  ?
	oprslt  DWORD  ?
	rmndr	DWORD  ?
	
	; Print Statements
	greetng BYTE 'Welcome to "Elementary Arithmetic" by Corey Hemphill.',0dh,0ah,0
	instrn1 BYTE 'Type an integer value and press "Enter": ',0dh,0ah,0
	instrn2 BYTE 'Type another integer value that is less than the previous and press "Enter": ',0dh,0ah,0
	goodbye BYTE 'That is all. Goodbye!',0dh,0ah,0
	frstnum BYTE 'First Number: ',0
	scndnum BYTE 'Second Number: ',0
	addtn 	BYTE ' + ',0
	subtrcn BYTE ' - ',0
	mltpcn 	BYTE ' * ',0
	dvsn 	BYTE ' / ',0
	rmndrtx	BYTE ' remainder ',0
	equals	BYTE ' = ',0
	
.code
main proc
	; Prints Greeting & Instructions, Requests & Stores Inputs
	call Clrscr
	mov	edx, OFFSET greetng
	call WriteString
	call Crlf
	top:
	mov	edx, OFFSET instrn1
	call WriteString
	call ReadInt
	mov	num1, eax
	mov edx, OFFSET instrn2
	call WriteString
	call ReadInt
	call Crlf
	mov	num2, eax
	
	; Prints & Confirms the Inputs
	mov	eax, num1
	mov	edx, OFFSET frstnum
	call WriteString
	call WriteDec
	call Crlf
	mov	eax, num2
	mov	edx, OFFSET scndnum
	call WriteString
	call WriteDec
	call Crlf
	call Crlf
	
	; Addition & Print Expression
	mov eax, num1
	add	eax, num2
	mov	oprslt, eax
	mov	eax, num1
	mov	edx, OFFSET addtn
	call WriteDec
	call WriteString
	mov	eax, num2
	mov	edx, OFFSET equals
	call WriteDec
	call WriteString
	mov eax, oprslt
	call WriteDec
	call Crlf
	
	; Subtraction & Print Expression
	mov eax, num1
	sub	eax, num2
	mov	oprslt, eax
	mov	eax, num1
	mov	edx, OFFSET subtrcn
	call WriteDec
	call WriteString
	mov	eax, num2
	mov	edx, OFFSET equals
	call WriteDec
	call WriteString
	mov eax, oprslt
	call WriteDec
	call Crlf
	
	; Multiplication & Print Expression
	mov eax, num1
	mov	ebx, num2
	mul ebx
	mov	oprslt, eax
	mov	eax, num1
	mov	edx, OFFSET mltpcn
	call WriteDec
	call WriteString
	mov	eax, num2
	mov	edx, OFFSET equals
	call WriteDec
	call WriteString
	mov eax, oprslt
	call WriteDec
	call Crlf
	
	; Division & Print Expression
	mov eax, num1
	mov	ebx, num2
	sub edx, edx
	div ebx
	mov	oprslt, eax
	mov rmndr, edx
	mov	eax, num1
	mov	edx, OFFSET dvsn
	call WriteDec
	call WriteString
	mov	eax, num2
	mov	edx, OFFSET equals
	call WriteDec
	call WriteString
	mov eax, oprslt
	call WriteDec
	mov edx, OFFSET rmndrtx
	mov eax, rmndr
	call WriteString
	call WriteDec
	call Crlf
	call Crlf
	
	; Say Goodbye
	mov edx, OFFSET goodbye
	call WriteString
	call Crlf
	invoke ExitProcess,0
main endp
end main