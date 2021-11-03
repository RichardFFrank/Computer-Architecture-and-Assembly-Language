TITLE Proj6_frankri     (Proj6_frankri.asm)

; Author: Richard Frank
; Last Modified: 03/14/2021
; OSU email address: frankri@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:    6             Due Date: 3/14/2021
; Description: The main procedure in this program contains functionality to test two macros (mGetString and mDisplayString)
;				and two procedures (ReadVal and WriteVal). The ReadVal procedures leverages the mdisplayString macro to display
;				instructions to enter a string to the user and mGetString to receive the input from the user. The ReadVal procedure
;				takes a value as a string and converts it to a signed integer before adding it to an array. The WriteVal procedure
;				converts an integer to its string equivalent and then uses mDisplayString to display the value to the user.
;				The test program requests 10 string integers from a user then uses the procedures to display the sum and average of the integers. 
;				The values entered by the user are also displayed.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a string and leverages the ReadString procedure to read the value from the user.
;
; Preconditions: None.
;
; Receives:
; prompt = the prompt to display to the user.
; size = the max size of the string that can be received.
; value = the location where the value received should be stored.
;
; returns: value = the value (string) received from the user.
; ---------------------------------------------------------------------------------
mGetString MACRO value, size, prompt
	push	EDX
	push	ECX
	call	CrLf
	mDisplayString prompt
	mov		EDX, value
	mov		ECX, (size - 1)
	call	ReadString
	pop		ECX
	pop		EDX
ENDM
; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays the string at the offset provided to the macro by leveraging the WriteString procedure.
;
; Preconditions: None.
;
; Receives:
; string = The string to be displayed. The user must provide the OFFSET of the string, not the string itself.

;
; returns: None. The string is displayed on screen.
; ---------------------------------------------------------------------------------
mDisplayString MACRO string
	push	EDX
	mov		EDX, string
	call	WriteString
	pop		EDX
ENDM

INPUTAMOUNT	= 10
MAXSIZE = 32

.data

inputString			byte	26 DUP(0)
integerArray		SDWORD	INPUTAMOUNT DUP(0)
totalString			byte	26 DUP(0)
total				SDWORD	0
averageString		byte	26 DUP(0)
average				SDWORD	0
titlePrompt			byte	"Project 6 - String Primitives and Macros by Richard Frank", 0
instructionPrompt	byte	"Please provide 10 signed decimal integers.", 0
guidelines1			byte	"Each number needs to be small enough to fit inside a 32 bit register. ", 0
guidelines2			byte	"After you have finished inputting the raw numbers I will display a list of the integers,"
					byte	" their sum, and their average value.", 0
inputPrompt			byte	"Please enter a signed number: ", 0
errorPrompt			byte	"ERROR: You did not enter a signed number or your number was too big.", 0
retryPrompt			byte	"Please try again", 0
entryPrompt			byte	"You entered the following numbers: ", 0
sumPrompt			byte	"The sum of these numbers is: ",0
avgPrompt			byte	"The average of these numbers is: ",0
goodbye				byte	"Thanks for playing, Goodbye!",0
comma				byte	", ",0

.code
main PROC
	push	OFFSET titlePrompt
	push	OFFSET instructionPrompt
	push	OFFSET guidelines1
	push	OFFSET guidelines2
	call	introduction
	
; --------------------------
; Asks users to provide the number of integers defined in the INPUTAMOUNT constant.
;	Those values are received as string and converted to integers before they are added to the provided array.
; --------------------------

	mov		ECX, INPUTAMOUNT				; set the loop counter
	mov		EDI, OFFSET integerArray		; set EDI to the start of the desired array
_get_integers:
	push	EDI				
	push	TYPE integerArray
	push	OFFSET retryPrompt 
	push	OFFSET errorPrompt
	push	OFFSET inputPrompt
	push	SIZEOF inputString
	push	offset inputString
	call	ReadVal	
	add		EDI, TYPE integerArray			; increment EDI to the next memory location and loop until finished.
	loop	_get_integers
	call	CrLf
	call	CrLf
; --------------------------
; Display the integers in the array by converting them to their string values (using the WriteVal) procedure.
; --------------------------
	mDisplayString	OFFSET entryPrompt
	call	CrLf
	mov		ECX, INPUTAMOUNT				; Set the loop counter for the number of values in the Array
	mov		EDI, OFFSET integerArray		; Set EDI to the start of the desired array
_display_loop:
	push	EDI
	push	OFFSET inputString
	call	WriteVal						; Use WriteVal to convert the value at the location in EDI to string and display.
	add		EDI, TYPE integerArray
	cmp		ECX, 1							; If ECX does not equal 1, a comma should separate each value.
	je		_no_comma						; If ECX equals 1, thus we've reached the last value in the list, we shouldn't print a comma.
	mDisplayString OFFSET comma
	loop	_display_loop
_no_comma:
	loop	_display_loop
	call	CrLf

; ---------
;	Calculate & Display Sum
; ---------
	mov		EDI, OFFSET integerArray			; Set the start of the Array
	mov		ECX, LENGTHOF integerArray			; Set the loop counter for the number of values in the Array
_calculate_sum:									; calculate the sum of all values in the array.
	mov		EAX, [EDI]
	add		total, EAX
	add		edi, TYPE integerArray
	loop	_calculate_sum

	call	CrLf
	mDisplayString OFFSET sumPrompt
	push	OFFSET total
	push	OFFSET totalString
	call	WriteVal							; convert the sum of all values to a string and display.

; ---------
;	Calculate & Display Average
; ---------

	call	CrLf
	call	CrLf
	mov		EAX, total
	MOV		EBX, LENGTHOF integerArray
	CDQ
	idiv	EBX									; divide the sum by the number of values in the array.
	mov		average, EAX

	mDisplayString OFFSET avgPrompt
	push	OFFSET average
	push	OFFSET averageString
	call	WriteVal							; convert the average to a string and display.
	call	CrLf
	call	CrLf
	mDisplayString OFFSET goodbye				; display the goodbye message.
	call	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP
; ---------------------------------------------------------------------------------
; Name: introduction
;
; This procedure the title and instructions related to the program.
; 
; Preconditions: None. 
;
; Postconditions: None.
;
; Receives:
;
;	[ebp+20]	= The title string (string).
;	[ebp+16]	= The instructions for using the program (string).
;	[ebp+12]	= Initial guidelines for the program (string).
;	[ebp+8]		= Additional guidelines for the proram (string).
;
; Returns: None. The strings are displayed on the screen using the mDisplayString macro. 
; ---------------------------------------------------------------------------------
introduction PROC
	push	EBP
	mov		EBP, ESP
	mDisplayString [ebp + 20]
	call	CrLf
	call	CrLf
	mDisplayString [ebp + 16]
	call	CrLf
	call	CrLf
	mDisplayString [ebp + 12]
	call	CrLf
	mDisplayString [ebp + 8]
	call	CrLf
	call	CrLf
	pop		EBP
	ret		12
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure uses the mGetString macro to get a string of integers (and sign if provided) from a user and 
;	converts the string to it's integer value (in decimal). That value is then added to the an array of integers for
;	later processing by the program.
; 
; Preconditions: None.
;
; Postconditions: None.
;
; Receives:
;	[ebp+32]	= The array offset which the integer value will be stored.
;	[ebp+28]	= The datatype of the array elements.
;	[ebp+24]	= The prompt requesting a user to retry after an invalid input was detected (string).
;	[ebp+20]	= The prompt notifying the user that an invalid input was detected (string).
;	[ebp+16]	= The prompt requesting a user provide an input (string).
;	[ebp+12]	= The size of string storage location, to be used in the mGetString macro.
;	[ebp+8]		= The offset where the provided string should be stored during processing.
;
; Returns: A value is added to the array at the offset provided in [EBP+32].
; ---------------------------------------------------------------------------------
ReadVal PROC
	local count:SDWORD
	local value:SDWORD
	local intCount:SDWORD
	local tempNeg:SDWORD
	pushad
	mov			tempNeg, 0					; tempNeg stores a 1 or a 0, if 1 then the value is negative (calculated later in the proc.)
	mov			value, 0
	mov			edi, [ebp + 32]				; move the start of the array to EDI.
	mov			edx, [EBP+12]				; move the size of the string to EDX

_string_loop:
	
	mGetString	[ebp+8], [ebp+12], [ebp+16]
	cmp			EAX, 0
	je			_invalid_entry				; if the user doesnt enter a value, retry.
	cmp			EAX, 11						
	jg			_invalid_entry				; if the user enters a value more than 11 digits long, it's an invalid value.
	mov			ecx, eax
	mov			count, eax
	mov			esi, [ebp+8]
	cld
convertDigit:
	lodsb
	cmp			ECX, count					; load the first digit into AL and determine if it is the first digit or not.
	je			_first_value
	jne			_validate_input

_first_value:								; if it is the first digit we check for the presence of a sign.
	cmp			al, 43
	je			_positive
	cmp			al, 45
	je			_negative
	jne			_validate_input

_positive:									; if a sign is detected and it's positive, we move to the next digit.
	loop		convertDigit				

_negative:									; if a negative sign is detected, we use tempneg to keep track of the 
	mov			tempNeg, 1					;	negative and convert the next digit as positive.
	loop		convertDigit
_validate_input:							; We make sure the character entered is in the desired ascii range.
	cmp			al, 57
	jg			_invalid_entry
	cmp			al, 48
	jl			_invalid_entry
	jge			_valid_input

_invalid_entry:								; if the value is invalid, we display our error prompts and restart the process.
	mDisplayString	[EBP + 20]
	call		CrLf
	mDisplayString	[EBP + 24]
	mov			value, 0
	jmp			_string_loop

_valid_input:								; if the value is valid, we convert it to it's integer value.
	sub			EAX, 48
	push		EAX
	mov			EAX, value
	mov			EBX, 10
	imul		EBX
	pop			EBX
	add			EAX, EBX
	jo			_invalid_entry				; if the value triggers an overflow, we define it as an invalid entry.
	mov			value, EAX
	loop		convertDigit
	jmp			_add_to_array

_add_to_array:								; as we add to the array, if the number if positive, we add it directly.
	mov			EAX, value					; if the number is negative, based on the value in tempNeg, we negate the value
	cmp			tempNeg, 1					; and then add that value to the array.
	je			_neg
	jne			_continue
_neg:
	neg			EAX
_continue:
	mov			[EDI], EAX
	mov			value, 0
	add			edi, [ebp + 28]
	je			_finish	

_finish:
	popad
	ret 32                                             
ReadVal	ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure converts an integer to a string value and uses the mDisplayString macro to display the value on screen.
; 
; Preconditions: An array and a string must both be declared to hold the input for processing into an integer and
;					storing the values.
;
; Postconditions: A value is added to the array at the memory offset pushed to the procedure.
;;
; Receives:
;	[ebp+12]	= The offset of the integer to be processed is located in memory.
;	[ebp+8]		= The offset where the provided string should be stored during processing.
;
; Returns: A value is added to the array at the offset provided in [EBP+32].
; ---------------------------------------------------------------------------------

WriteVal PROC
	local count:SDWORD
	local testval:sdword
	pushad
	mov			count, 0
	mov			EDI, [EBP + 12]		; move the first value in the array to EAX.
	mov			EAX, [EDI]
	mov			EDI, [ebp+8]		; move the string location into EDI.
	cmp			eax, 0				; determine if the value in EAX is positive or negative.
	jns			_pos
	js			_negative

_negative:							; if the value is negative, display the negative character ("-")
	neg			EAX					; and negate the value in EAX. Then proceed as if the number is positive.
	push		45
	pop			[EDI]
	mDisplayString   EDI
	jmp			_pos

_pos:								; divide the first value by 10 and add 48 to get the desired ascii charater code
	mov			EDX, 0				; and push it to the stack, then increment the count. Once count = the string length
	mov			EBX, 10				; then generate the string.
	div			EBX
	add			EDX, 48
	push		EDX
	inc			count
	cmp			EAX, 0
	jne			_pos

_generate_string:					; pop the ascii value from the stack and use mDisplayString to display the value.
	pop			[EDI]				; this repeats for the entire length of the string.
	mDisplayString   EDI

	dec			count
	cmp			count, 0
	jne			_generate_string

	mov               edx, [ebp+8]
	popad
	ret 8 
WriteVal ENDP



END main
