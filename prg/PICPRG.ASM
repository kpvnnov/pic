	IDEAL
	MODEL  LARGE, PROLOG
	LOCALS
	PUBLIC @CheckPlate$qv
	PUBLIC @ReadAllData$qv
	PUBLIC @WriteAllData$qv
	PUBLIC @ReadIdInformation$qv
	PUBLIC @WriteIdInformation$qv
	PUBLIC @WriteIdInformationProt$qv
	EXTRN _DataBuffer:WORD
	EXTRN _DataBuffer1:WORD
	EXTRN  @delay100mks$qv:PROC
	EXTRN  @delay5mks$qv:PROC
	EXTRN  @delay10mks$qv:PROC
NumPort	EQU	180H
CODESEG
PROC	Wait5mks	FAR
USES BX,CX,DX,AX
	call far @delay10mks$qv
	ret
ENDP	Wait5mks
PROC	Delay	FAR
USES AX,BX,DX,CX,SI,DI
	call far @delay5mks$qv
	ret
ENDP	Delay

PROC 	@CheckPlate$qv  FAR
	call far @SetMCLRtoGround
	ret
ENDP	@CheckPlate$qv
PROC	@SetMCLRtoGround	FAR
	mov dx,NumPort		;номер порта платы
	mov al,11111011B	;Power=0,Clock and Data TriState
	out dx,al
	call far Wait5mks
	call far Wait5mks
	call far Wait5mks
	ret
ENDP	@SetMCLRtoGround
PROC	@SetMCLRtoVihh	FAR
	mov dx,NumPort		;номер порта платы
	mov al,11001000B	;Power=0,Clock and Data 0
	out dx,al
	call far Wait5mks
	call far Wait5mks
	call far Wait5mks
	mov al,11001100B	;Power=1,Clock and Data 0
	out dx,al
	call far Wait5mks
	call far Wait5mks
	call far Wait5mks
	ret
ENDP	@SetMCLRtoVihh
PROC	@SendCommand FAR
ARG  Command:WORD
USES CX,BX
	mov bx,[Command]
	mov cx,6
	mov dx,NumPort		;номер порта платы
	mov al,11001100B	;Power=1,Clock=1 Data=0
@SendCo02:
	and al,0FDH	;маскирование бита DATA
	or  al,01H	;установка CLOCK
	shr bx,1
	jnc @SendCo01
	or al,02H
@SendCo01:
	out dx,al
	call far Delay
	and al,0FEH	;маскирование бита CLOCK
	out dx,al
	call far Delay
	loop @SendCo02
	mov al,11101100B	;Power=1,Clock=0 Data=TriState
	out dx,al
	ret
ENDP	@SendCommand
PROC	@ReadWord	FAR
USES CX
	mov cx,16
	mov dx,NumPort		;номер порта платы
	mov al,11101100B	;Power=1,Clock=0 Data=TriState
	out dx,al
@ReadW01:
	call far Delay
	mov al,11101101B	;Power=1,Clock=1 Data=TriState
	out dx,al
	call far Delay
	in al,dx
	shr ax,1
	shr ax,1
	rcr bx,1
	mov al,11101100B	;Power=1,Clock=0 Data=TriState
	out dx,al
	loop @ReadW01
	call far Delay
	mov ax,bx
	ret
ENDP	@ReadWord
PROC	@WriteWord	FAR
ARG Point:WORD
USES CX,BX
	mov bx,[Point]
	rcl bx,1
	and bx,07FFEH
	mov cx,16
	mov dx,NumPort		;номер порта платы
@WriteW01:
	mov al,11001101B	;Power=1,Clock=1 Data=Out
	and al,0FDH	;маскирование бита DATA
	shr bx,1
	jnc @WriteCo01
	or al,02H
@WriteCo01:
	out dx,al
	call far Delay
	and al,0FEH	;сброс CLOCK
	out dx,al
	call far Delay
	loop @WriteW01
	call far Delay
	mov al,11101100B	;Power=1,Clock=0 Data=TriState
	out dx,al
	call far Delay
	ret
ENDP	@WriteWord
PROC	@ReadData	FAR
USES BX,CX
	mov al,000100B		;Read Data Command
	call far @SendCommand C,AX
	call far Wait5mks
	call far @ReadWord
	call far Wait5mks
	rcr ax,1
	or ax,0C000H
	xor dx,dx
	ret
ENDP	@ReadData

PROC	@WriteData	FAR
ARG DataWord:WORD
USES BX,AX,CX
	mov al,000010B		;Load Data Command
	call far @SendCommand C,AX
	call far Wait5mks
	call far @WriteWord C,[DataWord]
	call far Wait5mks
	cli
	mov al,001000B	;Begin Progarmming
	call far @SendCommand C,AX
	call far @delay100mks$qv
	mov al,001110B	;End Progarmming
	call far @SendCommand C,AX
	sti
	call far Wait5mks
	xor dx,dx
	ret
ENDP	@WriteData

PROC	@ReadAllData$qv	FAR
USES CX
	call far @SetMCLRtoGround
	call far @SetMCLRtoVihh
	call far Wait5mks
	mov cx,01000H		;размер программной памяти PIC16C65
	mov bx,offset _DataBuffer
@ReadAll01:
	call far @ReadData
	or dx,dx
	jnz @ErrorReading
	cmp ax,0FFFFH
	jz ReadAll02
	and ax,03FFFH
ReadAll02:
	mov [bx],ax
	add bx,2
	mov al,000110B	;Increment Adress
	call far @SendCommand C,AX
	call far Wait5mks
	loop @ReadAll01
	call far @SetMCLRtoGround
@ErrorReading:
	ret

ENDP	@ReadAllData$qv

PROC	@ReadIdInformation$qv  FAR
USES CX
	call far @SetMCLRtoGround
	call far @SetMCLRtoVihh
	mov al,0
	call far @SendCommand C,AX
	call far Wait5mks
	mov ax,0FFFFH
	call far @WriteWord C,AX
	call far Wait5mks
	mov cx,8H		;размер программной памяти ID PIC16C65
	mov bx,offset _DataBuffer1
@ReadID01:
	call far @ReadData
	or dx,dx
	jnz @ErrorReadingID
	cmp ax,0FFFFH
	jz ReadID02
	and ax,03FFFH
ReadID02:
	mov [bx],ax
	add bx,2
	mov al,000110B	;Increment Adress
	call far @SendCommand C,AX
	call far Wait5mks
	loop @ReadID01
	call far @SetMCLRtoGround
@ErrorReadingID:
	ret
ENDP	@ReadIdInformation$qv

PROC	@WriteIdInformation$qv  FAR
USES CX
	call far @SetMCLRtoGround
	call far @SetMCLRtoVihh
	mov al,0
	call far @SendCommand C,AX
	call far Wait5mks
	mov ax,0FFFFH
	call far @WriteWord C,AX
	call far Wait5mks
	mov cx,7H		;ID PIC16C65 2007H-конфигурация
@WriteID01:
	mov al,000110B	;Increment Adress
	call far @SendCommand C,AX
	call far Wait5mks
	loop @WriteID01

;  13 12 11 10  9   8   7   6   5   4    3     2    1     0
;   -  -  -  -  -   -   -   -   CP1 CP0  PWRTE WDTE FOSC1 FOSC0
;   1  1  1  1  1   1   1   1   1   1    1     0    1     0     0FFFAH
;HS OSCILATOR
;WDT DISABLED

;  13 12 11 10  9   8   7   6   5   4    3     2    1     0
;   -  -  -  -  -   -   -   -   CP1 CP0  PWRTE WDTE FOSC1 FOSC0
;   1  1  1  1  1   1   1   1   0   0    1     0    1     0     0FFCAH
;HS OSCILATOR
;WDT DISABLED
;ALL MEMORY PROTECTED

	mov ax,0FFFAH			;FOSC
	call far @WriteData C,AX
	call far @SetMCLRtoGround
	ret
ENDP	@WriteIdInformation$qv

PROC	@WriteIdInformationProt$qv  FAR
USES CX
	call far @SetMCLRtoGround
	call far @SetMCLRtoVihh
	mov al,0
	call far @SendCommand C,AX	;Load Configuration
	call far Wait5mks
	mov ax,0FFFFH
	call far @WriteWord C,AX	;Write to PIC Data
	call far Wait5mks
	mov cx,7H		;ID PIC16C65 2007H-конфигурация
@@WriteID02:
	mov al,000110B	;Increment Adress
	call far @SendCommand C,AX
	call far Wait5mks
	loop @@WriteID02

;  13 12 11 10  9   8   7   6   5   4    3     2    1     0
;   -  -  -  -  -   -   -   -   CP1 CP0  PWRTE WDTE FOSC1 FOSC0
;   1  1  1  1  1   1   1   1   1   1    1     0    1     0     0FFFAH
;HS OSCILATOR
;WDT DISABLED

;  13 12 11 10  9   8   7   6   5   4    3     2    1     0
;   -  -  -  -  -   -   -   -   CP1 CP0  PWRTE WDTE FOSC1 FOSC0
;   1  1  1  1  1   1   1   1   0   0    1     0    1     0     0FFCAH
;HS OSCILATOR
;WDT DISABLED
;ALL MEMORY PROTECTED

	mov ax,0FFCAH			;FOSC
	call far @WriteData C,AX
	call far @SetMCLRtoGround
	ret
ENDP	@WriteIdInformationProt$qv
PROC	@WriteAllData$qv	FAR
USES CX
	call far @SetMCLRtoGround
	call far @SetMCLRtoVihh
	call far Wait5mks
	mov cx,01000H		;размер программной памяти PIC16C65
	mov bx,offset _DataBuffer
@WriteAll01:
	mov ax,[bx]
	cmp ax,0FFFFH
	jz @NeNadoPisat
	call far @WriteData C,AX
	or dx,dx
	jnz @ErrorWriting
	call far @ReadData
	mov dx,[bx]
	or dx,0C000H
	cmp ax,dx
	jnz @ErrorWriting
	mov ax,[bx]
	call far @WriteData C,AX
	call far @WriteData C,AX
	call far @WriteData C,AX
@NeNadoPisat:
	add bx,2
	mov al,000110B	;Increment Adress
	call far @SendCommand C,AX
	call far Wait5mks
	loop @WriteAll01
	call far @SetMCLRtoGround
	xor ax,ax
	ret
@ErrorWriting:
	call far @SetMCLRtoGround
	mov ax,1
	ret
ENDP	@WriteAllData$qv
END

