;
; Program Name		:	PerfectNum
; Program Version	:	Version 1.0a
; Source File Name	:	perfectnum.asm
; Date Created		:	2015/01/26
; Last modified		:	2015/01/26
; Author		: 	0xEDD1E (codemaster.eddie@gmail.com)
; Description		:	This Program Lists all the perfect numbers between 1
; 				and user given number. 
; Usage			: 	./perfectnum
;
; THIS HAS A DOWNSIDE: MAXIMUM NUMBER TO CHECK IS 4294967295


section .bss			; UNINITIAZED DATA SECTION [BSS]
	MSTRLEN equ 11   	; Bytes to reserve for Mstr
	Mstr: resb MSTRLEN	; Reserve 100 bytes for Mstr
	PSTRLEN equ 11		; Bytes to reserve for Pstr
	Pstr: resb PSTRLEN	; Reserve 100 bytes for Pstr
; END OF BSS SECTION

section .data								; INITIALIZED DATA SECTION (DATA)
	PromptMsg: db "Input the maximum number (< 4294967295): "	; Prompt message for Maximum number
	PROMPTLEN equ $-PromptMsg					; Maximum bytes (digits) to read for Maximum number
	E_NotANumber: db "ERROR: Input is Not A Number", 0AH		; Error Message if NaN input
	E_NOTANUMLEN equ $-E_NotANumber					; NaN Message length
	newLine db 0AH							; A New Line
	InitMsg: db "Perfect number found in the given range: ", 0AH    ; Massege to print before calculations
	InitLen equ $-InitMsg						; InitMsg length
; END OF DATA SECTION

section .text
global _start

_start:
	nop

;========================================[ HEADER ]=================================================
Prompt:
; 	prompts for the Maximum number
	mov eax, 4		; specify the sys_write
	mov ebx, 1		; specify stdout (:o better to be stderr)
	mov ecx, PromptMsg	; specify the base address of the string to print
	mov edx, PROMPTLE	; specify the length of string
	int 80H			; call Service Dispatcher

GetMaxStr:
; 	reads the maximum number into Mstr
	mov eax, 3		; specify sys_read
	mov ebx, 0		; specify stdin
	mov ecx, Mstr		; specify the base address of Maximum number string
	mov edx, MSTRLEN	; specify the number of bytes to read
				; Maximum digits for Mstr is 10, because 4294967295 has 10  digits. If user input
				; a number greater than 4294967295 but with 10 digits program will not perform well
				; For now, there is no way to handle this error. THIS IS A BUG!
	int 80H			; call Service Dispatcher
	
	push eax		; push the return value of sys_read onto the stack
				; this EAX value is used to convert the String into the Numerical value
				; by Str2Num procedure. Otherwise it will be not available after PrintInit procedure
	
PrintInit:			; A meeasge before the output
	mov eax, 4		; specify sys_write
	mov ebx, 1		; specify stdin
	mov ecx, InitMsg	; specify the base address of the message
	mov edx, InitLen	; specify the length of the message
	int 80H			; call Service Dispatcher
; ===================================================================================================


; ===================================[ Convert Str to Number ]=======================================
Str2Num:					; Main procedure
	pop eax					; pop the pushed sys_read return value into EAX
	dec eax					; decrease EAX by 1 (adjustment for LF; EAX = number of digits + 1(= LF))
	mov esi, eax				; ESI = EAX
	xor eax, eax				; EAX = 0 
	xor ecx, ecx				; ECX = 0
	xor ebx, ebx				; EBX = 0
						; These 3 registers should be cleared to start the convertion

Str2Num_Loop:					; Convertion Loop (@Str2Num)
	mov bl, byte [Mstr + ecx]		; put the character from Mstr + ECX (ECX initial value = 0) to BL
	cmp bl, 30H				; Compare BL with '0'
	jb ERRNAN				; if BL's character is below the '0' jump to ERRNAN procedure
	cmp bl, 39H				; Compare BL with '9'
	ja ERRNAN				; if BL's character is above the '9' jump to ERRNAN procedure
	sub bl, 30H				; BL = BL - 30H, this makes a number from BL's character
	mov edi, 0AH				; EDI = 10
	mul edi					; EAX = EAX * 10
	add eax, ebx				; EAX = EAX + EBX
	inc ecx					; ECX++
	cmp ecx, esi				; Compare ECX with ESI (adjusted return value of sys_read, see ln:78)
	jne Str2Num_Loop			; If ECX not equal to ESI jump to Str2Num_Loop procedure
	
	; At this point we have the Numerical representation of the Mstr in EAX
; ======================================================================================================

; =====================================[ Find Perfect Numbers ]=========================================
FindPerfectNum:					; Finds the perfect numbers in a given range
	mov esi, eax				; Put EAX into ESI
	xor eax, eax				; EAX = 0
	xor ebx, ebx				; EBX = 0
						; these 2 registers should be cleared at the begining
								
PerfectNum_BigStep:				; Stepping on the numbers in the range (1 < EBX < ESI) (=BigR) (@FindPerfectNum)
	inc ebx					; EBX++
	cmp ebx, esi				; Compare EBX with ESI
	je Exit					; If EBX = ESI jump to Exit procedure
	xor edi, edi				; clear EDI every time EBX is increased
						; EDI holds the sum of proper divisors of EBX's value
	mov ecx, 1				; ECX = 1 
PerfectNum_LittleStep:				; Stepping on the numbers in the range (1 < ECX < EBX) (=SmallR) (@PerfectNum_BigStep@FindPerfectNum)
	xor edx, edx				; clear EDX to avoid SIGFPE (DIV uses both EAX and EDX to DIVide a num)
	mov eax, ebx				; EAX = EBX
	cmp ecx, ebx				; Compare ECX with EBX
	je PerfectNum_BigStep_Out		; If ECX = EBX Jump to PerfectNum_BigStep_Out procedure
	div ecx					; DIVide EAX by ECX: QUO = EAX, REM = EDX
	cmp edx, 0				; If EDX = 0 ECX is a divisor of EBX
	jne NextLittleStep			; If EDX != 0 Then Jump to NextLittleStep procedure
	add edi, ecx				; IF EDX = 0 Then add ECX to EDI
NextLittleStep:					; Take a step in the range (1 <  ECX < EBX)
	inc ecx					; ECX++
	jmp PerfectNum_LittleStep		; unconditionally jump to PerfectNum_LittleStep

PerfectNum_BigStep_Out:				; ECX = EBX end of SmallR
	cmp edi, ebx				; Compare EDI with EBX
	jne PerfectNum_BigStep			; If EDI != EBX jump to PerfectNum_BigStep
						; ** At this point we've found a perfect number **
	mov eax, edi				; Put EDI into EAX (requirement for Num2Str)
	
	; Now we have to print this number but jumping immediately into the Num2Str will destroy the current register values
	; used by FindPerfectNum procedure, so those register values should be preserved befor jump there 
	; Here perserving is done by pushing those values into the stack
	
	push esi				; Push ESI onto stack
	push eax				; Push EAX onto stack
	push ebx				; Push EBX onto stack
	push ecx				; Push ECX onto stack
	push edx				; Push EDX onto stack	
	
	; Now we can proceed to print the perfect number (it is in EAX)
; ======================================================================================================

; =================================[ Convert Number to Str and Print]===================================
Num2Str:					; Converts the Number into String
;  	pop eax					; This is for generality If This procedure is used elsewhere push EAX to stack before jump into this
	xor ecx, ecx				; ECX = 0
	mov edi, 0AH				; EDI = 0AH (10)
	
Num2Str_Loop:					; This Loop generate the character string for the number, but in reverse order (@Num2Str)
	xor edx, edx				; clear EDX at the start. this avoids the SIGFPE
	div edi					; DIVide EAX's value by EDI (0AH), QUO->EAX, REM->EDX
	add edx, 30H				; ADD 30H to value in EDX to produce the ASCII character (30H = 0 <--> 39H = 9)
	mov byte [Pstr + ecx], dl   		; MOV DL into the place indicated by Pstr + ECX
	inc ecx					; INCrease the ECX's value
	cmp eax, 0				; check if EAX has become 0, If yes it means the end
	jne Num2Str_Loop			; If EAX is not 0 jump to Num2Str_Loop
	
	; At this point we have Pstr (reversed String of Number) and Length of the Pstr as ECX

Num2Str_Reverse:				; This procedure corrects the reverse order of Pstr (@NumStr)
	xor esi, esi				; ESI = 0
	xor edi, edi				; EDI = 0
	mov esi, ecx				; ESI = ECX
	dec esi					; ESI--, now ESI = Effective Length of Pstr
	jz Print				; If ESI = 0 (i.e Only one character in the string) jump to Print immediately
	
Num2Str_Reverse_Loop:				; This procedure reverse the (reversed) Pstr (@Num2Str_Reverse@Num2Str)
	mov cl, byte [Pstr + esi]		; Put Pstr + ESI into CL (initial ESI = Length of Pstr - 1)
	mov dl, byte [Pstr + edi]		; Put Pstr + EDI into DL (initial EDI = 0)
	mov byte [Pstr + edi], cl		; Put CL into Pstr + EDI (swapped!)
	mov byte [Pstr + esi], dl		; Put DL into Pstr + ESI (swapped!)
	inc edi					; EDI++		
	dec esi					; ESI--
	cmp esi, edi				; compare ESI with EDI
	ja Num2Str_Reverse_Loop			; If ESI is above EDI jump to Num2Str_Reverse_Loop
	
	; At this point we have Pstr contains a perfect number in ASCII characters, waiting to be printed
	; So let's print it
Print:						; This procedure prints the Pstr with a newLine
	mov eax, 4				; specify sys_write
	mov ebx, 1				; specify stdout
	mov ecx, Pstr				; specify Base address of the string (Pstr)
	mov edx, 100				; specify the maximum characters to print
	int 80H					; call Service Dispatcher
	
	mov eax, 4				; specify sys_write
	mov ebx, 1				; specify stdout
	mov ecx, newLine			; specify newLine string's base address
	mov edx, 1				; specify that only one character should be printed
	int 80H					; call Service Dispatcher
	
	; Now we should jump again into FindPerfectNum to find next Perfect number in the range
	; Before jumping into it, we should restore the preserved values in their registers
	pop edx					; pop the stack into EDX				
	pop ecx					; pop the stack into ECX
	pop ebx					; pop the stack into EBX
	pop eax					; pop the stack into EAX
	pop esi					; pop the stack into ESI
	jmp PerfectNum_BigStep			; Then unconditionally jump to PerfectNum_BigStep

; ==========================================================================================================

; ===========================================[ NaN Massege ]================================================
ERRNAN:						; Exits the program on an error
	; program will jump into this procedure if user input an invalid number
	; It simply prints an error massege and exits returning zero
	mov eax, 4				; specify sys_write
	mov ebx, 2				; specify stderr
	mov ecx, E_NotANumber			; specify the Base address of the err massege string
	mov edx, E_NOTANUMLEN			; specify the error massege string length
	int 80H					; call Service Dispatcher to print
	
	mov eax, 1				; specify sys_exit
	mov ebx, 1				; specify return value 1
	int 80H					; call Service Dispatcher to exit
; ===========================================================================================================

; ===============================================[ Exit ]====================================================
Exit:						; Exits the program successfully
	mov eax, 1				; specify sys_exit
	mov ebx, 0				; specify return value 0
	int 80H					; call Service Dispatcher to exit
; ===========================================================================================================
