.286
        IDEAL
        MODEL LARGE,CPP
        LOCALS
        PUBLIC  @ResetCPU$qv
        PUBLIC  @HookOneCommand$qv
        PUBLIC  @Drawing$qv
        PUBLIC  @ClearBreak$qv
        PUBLIC  _CodeSeg
        PUBLIC  _Timens
        PUBLIC  _Timemks
        PUBLIC  _Timems
        PUBLIC  _Timesec
        PUBLIC  _StrPr1
        PUBLIC  _StrPr2
        PUBLIC  _Linia


OkOperation             equ 0000H
UnumplementedMemory     equ 0001H
UnumplementedCode       equ 0002H
SkipCommand             equ 0003H
StackOverflow           equ 0004H
StackUnderOverflow      equ 0005H
SizeRecevQ              equ 22     ;длина очереди приема
ReactionOnIRQ           equ 10*5  ; 20 mks
ReactionOnWrite         equ 30*5  ; 20 mks
WaitOnPowerReset        equ 500*5 ;100 mks
PauseBWKeybTransm       equ 1000*5 ;800 mks
PeriodChange            equ 15*5  ; 20 mks
NumBitKeyboard          equ 12    ;количество передаваемых бит
TestNum                 equ 500*5 ;через сколько mks писать данные
Delay50BOD              equ 10000*5;20 ms
HighDelay50BOD          equ 0
DelayError              equ  6799*5;20 ms
HighDelayError          equ 0
PeriodFor0              equ 5000*5 ;изменение на линии порта B 0
PeriodFor1              equ 10001*5 ;изменение на линии порта B 1
PeriodFor2              equ 12003*5 ;изменение на линии порта B 2
PeriodFor3              equ 10089*5 ;изменение на линии порта B 3
StateOfVib              equ 2CH         ;адрес ячейки из программы
                        ; о состоянии внутреннего триггера
SizeReceve      equ  100H
TMR0    equ     01H
PCL     equ     02H
STATUS  equ     03H
        ;биты статуса
;       IRP     equ     7
        RP1     equ     6
        RP0     equ     5
        TO      equ     4
        PD      equ     3
        Z       equ     2
        DC      equ     1
;       C       equ     0

FSR     equ     04H
PORTA   equ     05H
        TR      EQU     0       ;Вывод сигнала передачи
        IRQ     EQU     5       ;Вывод для запроса IRQ ЦП
        DTKB    EQU     4       ;Вывод с открытым колектором данные keyboard
PORTB   equ     06H
        KCIN    EQU     0       ;Ввод синхро клаиатуры
        KCOUT   EQU     3       ;Вывод на микросхему с открытым колектором
                                ;синхро клавиатуры
PORTC   equ     07H
PORTD   equ     08H
PORTE   equ     09H
PCLATH  equ     0AH
INTCON  equ     0BH
        ;биты управляющего регистра прерываний
        GIE     equ     7
        PEIE    equ     6
        T0IE    equ     5
        INTE    equ     4
        RBIE    equ     3
        T0IF    equ     2
        INTF    equ     1
        RBIF    equ     0
PIR1    equ     0CH
        PSPIF   EQU     7
        RCIF    EQU     5
        TXIF    EQU     4
        SSPIF   EQU     3
        CCP1IF  EQU     2
        TMR2IF  EQU     1
        TMR1IF  EQU     0
PIR2    equ     0DH
TMR1L   equ     0EH
TMR1H   equ     0FH
T1CON   equ     10H
TMR2    equ     11H
T2CON   equ     12H
SSPBUF  equ     13H
SSPCON  equ     14H
CCPR1L  equ     15H
CCPR1H  equ     16H
CCP1CON equ     17H
RCSTA   equ     18H
TXREG   equ     19H
RCREG   equ     1AH
CCPR2L  equ     1BH
CCPR2H  equ     1CH
CCP2CON equ     1DH
;Второй банк
OPTION  equ     81H
        INTEDG  EQU 6 ;Interrupt edge select
TRISA   equ     85H
;значение для начальной инициализации порта A
;RA5(IRQ)  на вывод (запрос прерывания)
;RA4(DTKB) на вывод (c открытым колектором,данные клавиатуры)
;RA0(OUT1  на вывод (передатчик)
        InitPortA       EQU 11001110B
TRISB   equ     86H
;значение для начальной инициализации порта B
;RB0(KCIN)  на ввод (синхро клавиатуры)
;RB1(D+)    на ввод
;RB2(D-)    на ввод
;RB3(KCOUT) на вывод (синхро клавиатуры,управляет открытым колектором)
        InitPortB       EQU 11110111B ;пока все на ввод
TRISC   equ     87H
;значение для начальной инициализации порта C
;RC1/CCP2 на вывод динамика
        InitPortC       EQU 11111101B ;
TRISD   equ     88H
TRISE   equ     89H
        IBF     EQU     7
        OBF     EQU     6
        IBOV    EQU     5
        PSPMODE EQU     4
        TRISE2  EQU     2
        TRISE1  EQU     1
        TRISE0  EQU     0
;//##############################################
;ФОРМАТ ПЕРЕДАЧИ МЕЖДУ PIC И CPU
;старшие четыре бита код передачи
;младшие четыре бита данные
;коды передачи/приема
;данные поступающие из CPU(ЦП)
;0 - установка скорости передачи/приема
;1 - установить передатчик в соответствии с кодом (код в младшей половине)
;2 - послать данные (младшая половина)
;3 - послать данные на передачу (старшая половина)
;4 - послать данные на клавиатуру (старшая половина)
;5 - послать данные на принтер (старшая половина)
;6 - послать данные в часы
;7 - послать данные в пзу
;8 - послать адрес для пзу/часов
;9 - данные для BEEP
;A - количество бит в данных и кол-во стопов
;B
;C
;D
;E
;F - команда сброса
;команда выполняется после приема старшей половины
;данные посылаемы в CPU(ЦП)
;0 - буфер передачи пуст, можно засылать новые данные
;1 - буфер клавиатуры пуст, можно засылать новые данные
;2 - принятые данные (младшая половина)
;3 - принятые данные с линии (старшая половина)
;4 - принятые данные с клавиатуры (старшая половина)
;5 - принятые данные с принтера (старшая половина)
;6 - количество свободных байт в очереди передачи данных
;7 -
;8
;9 - ошибка принятия байта с линии (нет стопа)
;A - код данных о состоянии линии в единице (код в младшей половине) (каждые 20 ms)
;B - код данных о состоянии линии в нуле (код в младшей половине) (каждые 20 ms)
;C - код данных о состоянии линии в обрыве (код в младшей половине) (каждые 20 ms)
;D - код данных о состоянии линии в аварии (код в младшей половине) (каждые 20 ms)
;D - передается последним
;E
;F - произошло переполнение приемника
ErrorOverflow   EQU     0F0H
;//##############################################
PIE1    equ     8CH
PIE2    equ     8DH
PCON    equ     8EH
        POR     EQU 1
PR2     equ     92H
SSPADD  equ     93H
SSPSTAT equ     94H
TXSTA   equ     98H
SPBRG   equ     99H

DATASEG
_MemorySeg      db 100H         DUP (?)
_CodeSeg        dw 1000H        DUP (?)
_BreakPoint     db 1000H        DUP (?)

ReceveBuffer    db SizeReceve DUP (?)   ;Буфер для сообщений приема 1
EndReceveBuffer db ?
HeadReceve      dw ?                    ;Голова очереди буфера приема 1
HvostReceve     dw ?                    ;Хвост очереди буфера приема 1

_W      db ?
PCH     db ?
SKIP    db ?
Dummy   db ?
_StrPr1 db 80 DUP (?)
_StrPr2 db 80 DUP (?)

StringDisAsm    db 80 DUP (?)
StringDisAsm1   db 80 DUP (?)
BufferConvert   db 5 DUP (?)
@Monitor        dw 80*50 DUP (?)
PICSTACK        dw 10 dup (?)
NumWordInStack  db ?
_Timens         dw ?
_Timemks        dw ?
_Timems         dw ?
_Timesec        dw ?
_Linia          db ?
Count50BOD      dd ?
CountData       db ?
LastStateIRQ    db ?
LastStatePortB  db ?
DataTransm      dw ?
WaitTime        db ?
Period          dw ?
Period0         dw ?
Period1         dw ?
CounterPortB0   dw ?
CounterPortB1   dw ?
CounterPortB2   dw ?
CounterPortB3   dw ?
LastState       db ?
CounterReactionIRQ      dw ?
CounterReactWrite       dw ?
WaitFromBegin           dw ?
RecevedDataFromPic      db SizeRecevQ DUP (?)
PauseBWKeybTransmCoun   dw ? ;счетчик паузы м/у передачами данных клавиатуры
PeriodChangeCount       dw ? ;счетчик полупериода
NumBitKeyboardCount     dw ? ;счетчик переданных стробов
TestNumCount            dw ? ;счетчик записи любых данных в PIC
CODESEG
;------------------------------------------------
PROC    @ClearBreak$qv  far
USES DI,CX,AX
        push ds
        pop es
        mov di,offset _BreakPoint
        cld
        mov cx,1000H
        mov al,0
        rep stosb
        ret
ENDP    @ClearBreak$qv
;------------------------------------------------
PROC    @ResetCPU$qv    FAR
        mov [BYTE PTR PCH],0
        call near @WriteByte C,PCL,0
        call near @WriteByte C,OPTION,0FFH
        call near @WriteByte C,PORTB,1
        mov [byte ptr _Timens],0
        mov [word ptr _Timemks],0
        mov [word ptr _Timems],0
        mov [byte ptr _Timesec],0
        mov [byte ptr SKIP],0
        mov [byte ptr Dummy],0
        mov [byte ptr NumWordInStack],0
        mov [byte ptr LastStateIRQ],0
        mov [byte ptr LastStatePortB],0
        mov [WORD ptr CounterReactWrite],0
        mov [WORD ptr PauseBWKeybTransmCoun],PauseBWKeybTransm
        mov [WORD ptr WaitFromBegin],WaitOnPowerReset
        mov [WORD ptr NumBitKeyboardCount],NumBitKeyboard
        mov [WORD ptr PeriodChangeCount],0
        mov [WORD ptr TestNumCount],TestNum
        mov [byte ptr CountData],2
        mov [word ptr DataTransm],11101011B
        mov [word ptr Count50BOD],Delay50BOD
        mov [word ptr Count50BOD+2],HighDelay50BOD
        mov [byte ptr _Linia],1
        mov [byte ptr WaitTime],0
        mov [word ptr CounterPortB0],PeriodFor0
        mov [word ptr CounterPortB1],PeriodFor1
        mov [word ptr CounterPortB2],PeriodFor2
        mov [word ptr CounterPortB3],PeriodFor3
        call far @InitReceveBuffer
        call far @PutReceveQ C,020H
        call far @PutReceveQ C,070H
        ret
ENDP    @ResetCPU$qv
;------------------------------------------------
;Инициализайия буфера приема
PROC    @InitReceveBuffer       FAR
        mov [WORD PTR HeadReceve],offset ReceveBuffer
        mov [WORD PTR HvostReceve],offset ReceveBuffer
        ret
ENDP    @InitReceveBuffer

PROC    @Refresh        FAR
USES ES,SI,DI,CX
        cld
        push 0B800H
        pop es
        mov si,offset @Monitor
        xor di,di
        mov cx,80*50
        rep movsw
        ret
ENDP    @Refresh
;------------------------------------------------
PROC    @ClrScr FAR
USES AX,DI,CX,ES
        push ds
        pop es
        mov di,offset @Monitor
        mov ax,0720H
        cld
        mov cx,80*50
        rep stosw
        ret
ENDP    @ClrScr
;------------------------------------------------
PROC    @PutStringDisplay FAR
ARG Point:DWORD,Coord:Word,Attrib:word
USES AX,DS,BX,DI,ES,DX
        push ds
        pop es
        mov dx,[Attrib]
        mov ax,[Coord]
        mov ah,160
        mul ah
        mov di,ax
        mov ax,[Coord]
        xchg ah,al
        xor ah,ah
        shl ax,1
        add di,ax
        add di,offset @Monitor
        lds bx,[Point]
@PutDisplay1:
        mov al,[bx]
        cmp al,0
        jz @PutDisplay2
        mov [es:di],al
        inc di
        mov [es:di],dl
        inc di
        inc bx
        jmp short @PutDisplay1
@PutDisplay2:
        ret
ENDP    @PutStringDisplay
;------------------------------------------------
;Преобразование байта в текстовый формат
;Параметры
;       -младший байт-для преобразования
;       -адрес области для преобразования DS:сегмент
PROC    @Byte2Text FAR
ARG     Slovo:WORD,Buffer:WORD
USES AX,BX,SI,CX
        mov ax,[Slovo]
        and al,0F0H
        mov cl,4
        shr al,cl
        mov bx,OFFSET TABLE0123
        XLAT [CS:TABLE0123]
        mov si,[Buffer]
        mov [si],al
        mov ax,[Slovo]
        and al,0FH
        XLAT [CS:TABLE0123]
        inc si
        mov [si],al
        ret
TABLE0123 DB '0123456789ABCDEF'
ENDP    @Byte2Text
;------------------------------------------------
;Преобразование слова в текстовый формат
;Параметры
;       -для преобразования
;       -адрес области для преобразования DS:сегмент
PROC    @Word2Text FAR
ARG     Slovo:WORD,Buffer:WORD
USES AX
        mov ax,[Slovo]
        xchg al,ah
        call far @Byte2Text C,AX,[Buffer]
        mov ax,[Buffer]
        add ax,2
        call far @Byte2Text C,[Slovo],AX
        ret
ENDP    @Word2Text
;------------------------------------------------
PROC    @Drawing$qv     FAR
USES CX,SI,DI,ES
        call far @ClrScr
        call far @DrawData
        call far @DrawCode
        call far @Refresh
        ret
ENDP    @Drawing$qv
;------------------------------------------------
PROC    @DrawData       FAR
        mov [byte ptr BufferConvert+4],0
        call far @Word2Text C,[word ptr Period0],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,201AH,7
        call far @Word2Text C,[word ptr Period1],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,201BH,7

        call far @Word2Text C,[word ptr CounterPortB0],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,281AH,7
        call far @Word2Text C,[word ptr CounterPortB1],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,281BH,7
        call far @Word2Text C,[word ptr CounterPortB2],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,281CH,7
        call far @Word2Text C,[word ptr CounterPortB3],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,281DH,7

        call far @PutStringDisplay C,Offset _StrPr1,ds,0025H,7
        call far @PutStringDisplay C,Offset _StrPr2,ds,0031H,7
        call far @PutStringDisplay C,Offset @WRegister,cs,0013H,7
        mov [byte ptr BufferConvert+2],0
        mov al,[byte ptr _W]
        call far @Byte2Text C,AX,Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,0213H,7
;------------------------------------------------
        cmp [byte ptr SKIP],0
        jz @Draw05
        call far @PutStringDisplay C,Offset SkipString,cs,2F11H,16H
@Draw05:
        cmp [WORD PTR CounterReactionIRQ],0
        jz @Draw05_1
        call far @PutStringDisplay C,Offset ZaprosIRQ,cs,0020H,20H
@Draw05_1:
        cmp [WORD PTR CounterReactWrite],0
        jz @Draw05_2
        call far @PutStringDisplay C,Offset WriteToPIC,cs,0021H,20H
@Draw05_2:
        cmp [WORD PTR PauseBWKeybTransmCoun],0
        jnz @Draw05_3
        call far @PutStringDisplay C,Offset WorkKeyboard,cs,0022H,30H
@Draw05_3:

;------------------------------------------------
;вывод на экран принятых данных с пикушки
        call far @PutStringDisplay C,Offset BufferConvert,ds,0213H,7
        mov si,offset RecevedDataFromPic
        mov bx,3515H
        mov cx,0
@DrawQu1:
        call far @Byte2Text C,[word ptr si],Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,bx,7
        add bx,1
        inc si
        inc cx
        cmp cx,SizeRecevQ
        jnz @DrawQu1

;------------------------------------------------
        call far @PutStringDisplay C,Offset @TRString,cs,0014H,7
        call near @ReadByte C,PORTA
        test al,1
        jz TRZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0314H,7
        jmp short TRPrinted
TRZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0314H,7
TRPrinted:
        call far @PutStringDisplay C,Offset @KCINString,cs,0015H,7
        call near @ReadByte C,PORTB
        test al,1
        jz KCINZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0515H,7
        jmp short KCINPrinted
KCINZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0515H,7
KCINPrinted:
        call far @PutStringDisplay C,Offset @KCOUTString,cs,0016H,7
        call near @ReadByte C,PORTB
        test al,8
        jz KCOUTZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0616H,7
        jmp short KCOUTPrinted
KCOUTZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0616H,7
KCOUTPrinted:
        call far @PutStringDisplay C,Offset @YRSTString,cs,0017H,7
        call near @ReadByte C,PORTA
        test al,4
        jz YRSTZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0617H,7
        jmp short YRSTPrinted
YRSTZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0617H,7
YRSTPrinted:
        call far @PutStringDisplay C,Offset @YSCLKtring,cs,0018H,7
        call near @ReadByte C,PORTC
        test al,8
        jz YSCLKZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0618H,7
        jmp short YSCLKPrinted
YSCLKZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0618H,7
YSCLKPrinted:
        call far @PutStringDisplay C,Offset @YIOString,cs,0019H,7
        call near @ReadByte C,PORTC
        test al,20H
        jz YIOZero
        call far @PutStringDisplay C,Offset @TRString1,cs,0619H,7
        jmp short YIOPrinted
YIOZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,0619H,7
YIOPrinted:
        call near @ReadByte C,TRISC
        test al,20H
        jz YIOOut
        call far @PutStringDisplay C,Offset @StrInput,cs,0819H,7
        jmp short YIOInput
YIOOut:
        call far @PutStringDisplay C,Offset @StrOutput,cs,0819H,7
YIOInput:
        call far @PutStringDisplay C,Offset @DOSString,cs,001AH,7
        call near @ReadByte C,PORTC
        test al,10H
        jz DOSZero
        call far @PutStringDisplay C,Offset @TRString1,cs,061AH,7
        jmp short DOSPrinted
DOSZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,061AH,7
DOSPrinted:
        call near @ReadByte C,TRISC
        test al,10H
        jz DOSOut
        call far @PutStringDisplay C,Offset @StrInput,cs,081AH,7
        jmp short DOSInput
DOSOut:
        call far @PutStringDisplay C,Offset @StrOutput,cs,081AH,7
DOSInput:

        call far @PutStringDisplay C,Offset @CSSRString,cs,001BH,7
        call near @ReadByte C,PORTC
        test al,1H
        jz CSSRZero
        call far @PutStringDisplay C,Offset @TRString1,cs,061BH,7
        jmp short CSSRPrinted
CSSRZero:
        call far @PutStringDisplay C,Offset @TRString0,cs,061BH,7
CSSRPrinted:
        mov bx,300H
        mov cx,0
@Draw04:call far @Byte2Text C,CX,Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,bx,7
        add bx,300H
        inc cx
        cmp cx,10H
        jnz @Draw04

        mov cx,0
        mov bx,1
@Draw01:
        call far @Byte2Text C,CX,Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,bx,7
        add bx,300H

@Draw02:call near @ReadByte C,CX
        call far @Byte2Text C,AX,Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,bx,7
        inc cx
        add bx,300H
        test cx,0FH
        jnz @Draw02
        and bx,0FFH
        add bx,1H
        cmp cx,100H
        jz @Draw03
        jmp @Draw01
@Draw03:
        ret
@TRString0 db '0',0
@TRString1 db '1',0
@TRString  db 'TR=',0
@KCINString db 'KCIN=',0
@KCOUTString db 'KCOUT=',0
@WRegister db 'W=',0
@YRSTString db 'CSSC=',0
@YSCLKtring db 'CLS=',0
@YIOString db 'DIOS=',0
@DOSString DB 'DOS=',0
@CSSRString db 'CSSR=',0
@StrInput  db 'Input',0
@StrOutput db 'Output',0
SkipString db 'SKIP',0
ZaprosIRQ  db 'IRQ ',0
WriteToPIC db 'Запись данных в PIC',0
WorkKeyboard db 'Передача ->keyboard',0

ENDP    @DrawData
;------------------------------------------------
PROC    @DrawCode       FAR
USES CX,bx,dx,DI
        mov [byte ptr BufferConvert+4],0
        call near @ReadByte C,PCL
        mov ah,[byte ptr PCH]
        mov cx,ax
        cmp ax,10
        jnc @DrawC01
        mov ax,10
@DrawC01:
        sub ax,10
        mov dx,3500H
@DrawC02:
        call far @Word2Text C,AX,Offset BufferConvert
        call far @PutStringDisplay C,Offset BufferConvert,ds,dx,7
        add dx,500H
        push ax
        call far @DisAsmOneCommand C,AX
        pop ax
        mov di,7
        cmp ax,cx
        jnz @DrawC03
        mov di,70H
@DrawC03:
        call far @PutStringDisplay C,Offset StringDisAsm,ds,dx,di
        mov dh,35H
        inc dl
        inc ax
        cmp dl,20
        jnz @DrawC02
        ret
ENDP    @DrawCode
;------------------------------------------------
PROC    @PushInStack NEAR
ARG     Data:Word
USEs BX,ax
        inc [byte ptr NumWordInStack]
        mov bl,[byte ptr NumWordInStack]
        xor bh,bh
        shl bx,1
        add bx,offset PICSTACK
        mov ax,[Data]
        mov [bx],ax
        cmp [byte ptr NumWordInStack],8
        jnc @Push01
        mov dx,OkOperation
        ret
@Push01:mov dx,StackOverflow
        ret
ENDP    @PushInStack
;------------------------------------------------
PROC    @PopInStack NEAR
ARG     Data:Word
USEs BX
        mov bl,[byte ptr NumWordInStack]
        xor bh,bh
        shl bx,1
        add bx,offset PICSTACK
        mov ax,[Data]
        mov ax,[bx]
        cmp [byte ptr NumWordInStack],0
        jz @Pop01
        dec [byte ptr NumWordInStack]
        mov dx,OkOperation
        ret
@Pop01:mov dx,StackUnderOverflow
        ret
ENDP    @PopInStack
;------------------------------------------------
PROC    @ReadBankByte   NEAR
ARG     Adress:WORD
USES BX
        mov bx,[Adress]
        and bx,07FH
        test [byte ptr _MemorySeg+STATUS],20H
        jz @ReadBank1
        or bx,080H
@ReadBank1:
;------------------------------------------------
;эмуляция чтения данных с порта D
;при чтении сбрасывается TRISE->IBF
        cmp bl,PORTD
        jnz ThisIsNotPortD
        push ax
        call near @ReadByte C,TRISE
        and al,7FH
        call near @WriteByte C,TRISE,AX
        pop ax
ThisIsNotPortD:
;------------------------------------------------

        call near @ReadByte C,BX
        ret
ENDP    @ReadBankByte

PROC    @WriteBankByte  NEAR
ARG     Adress:WORD,Data:Word
USES BX
        mov bx,[Adress]
        and bx,07FH
        test [byte ptr _MemorySeg+STATUS],20H
        jz @WriteBank1
        or bx,080H
@WriteBank1:
        cmp bl,TMR0
        jnz ThisIsNotTMR0
        mov [byte ptr WaitTime],3
ThisIsNotTMR0:
        call near @WriteByte C,BX,[Data]
        ret
ENDP    @WriteBankByte
PROC    @ReadByte       NEAR
ARG     Adress:WORD
USES BX
        mov bx,[Adress]
        and BX,0FFH
        cmp BX,01EH
        jc @ReadByte1
        cmp BX,020H
        jc @ReadByteError
        cmp BX,080H
        jz @ReadByte2
        cmp BX,082H
        jc @ReadByte1
        cmp BX,085H
        jc @ReadByte2
        cmp BX,08AH
        jc @ReadByte1
        cmp BX,08CH
        jc @ReadByte2
        cmp BX,08FH
        jc @ReadByte1
        cmp BX,092H
        jc @ReadByteError
        cmp BX,095H
        jc @ReadByte1
        cmp BX,098H
        jc @ReadByteError
        cmp BX,09AH
        jc @ReadByte1
        cmp BX,0A0H
        jc @ReadByteError
        cmp BX,100H
        jc @ReadByte1
@ReadByteError:
        xor al,al
        mov dx,UnumplementedMemory
        ret
@ReadByte2:and bx,07FH
@ReadByte1:
        cmp bx,0
        jz @ReadByte3
        add bx,offset _MemorySeg
@ReadByte5:
        mov al,[byte ptr bx]
@ReadByte4:
        xor dx,dx
        ret
@ReadByte3:
        call near @ReadByte C,04H
        cmp al,0
        jz @ReadByte4
        mov bx,offset _MemorySeg
        xor ah,ah
        add bx,ax
        jmp short @ReadByte5
ENDP    @ReadByte
;------------------------------------------------
PROC    @WriteByte      NEAR
ARG     Adress:WORD,Data:Word
USES BX
        mov bx,[Adress]
        and bx,0FFH
        cmp BX,01EH
        jc @WriteByte1
        cmp BX,020H
        jc @WriteByteError
        cmp BX,080H
        jz @WriteByte2
        cmp BX,082H
        jc @WriteByte1
        cmp BX,085H
        jc @WriteByte2
        cmp BX,08AH
        jc @WriteByte1
        cmp BX,08CH
        jc @WriteByte2
        cmp BX,08FH
        jc @WriteByte1
        cmp BX,092H
        jc @WriteByteError
        cmp BX,095H
        jc @WriteByte1
        cmp BX,098H
        jc @WriteByteError
        cmp BX,09AH
        jc @WriteByte1
        cmp BX,0A0H
        jc @WriteByteError
        cmp BX,100H
        jc @WriteByte1
@WriteByteError:
        mov dx,UnumplementedMemory
        ret
@WriteByte2:and bx,07FH
@WriteByte1:
        cmp bx,0
        jz @WriteByte3
        add bx,offset _MemorySeg
@WriteByte5:
        mov ax,[Data]
        mov [byte ptr bx],al
@WriteByte4:
        xor dx,dx
        ret
@WriteByte3:
        call near @ReadByte C,04H
        cmp al,0
        jz @WriteByte4
        mov bx,offset _MemorySeg
        xor ah,ah
        add bx,ax
        jmp short @WriteByte5
ENDP    @WriteByte
;------------------------------------------------
PROC    @GetReceveData  FAR
USES    BX
        mov bx,[HvostReceve]
        cmp bx,[HeadReceve]
        jz @GetReceve01
        mov al,[BYTE PTR bx]
        call near @IncHead C,OFFSET HvostReceve,OFFSET EndReceveBuffer,OFFSET ReceveBuffer
        mov bl,0FFH
        and bl,bl
@GetReceve01:
        ret
ENDP    @GetReceveData
;------------------------------------------------
;Байт в очередь к порту на прием
PROC    @PutReceveQ FAR
ARG     Char:Word
USES    BX
        mov ax,[Char]
        mov bx,[HeadReceve]
        mov [Byte ptr bx],al
        call near @IncHead C,OFFSET HeadReceve,OFFSET EndReceveBuffer,OFFSET ReceveBuffer
        ret
ENDP    @PutReceveQ
;------------------------------------------------
;Увеличение указателя очереди на байт
;Параметры -Указатель на ячейку указателя
;          -Адрес последней ячейки очереди
;          -Адрес первой ячеки очереди
PROC    @IncHead NEAR
ARG     Head:WORD,Last:Word,First:Word
USES    BX,AX
        mov bx,[Head]
        inc [WORD PTR bx]
        mov ax,[bx]
        cmp ax,[Last]
        jnc @IncHead01
        jmp short @IncHeadQ
@IncHead01:
        mov ax,[First]
        mov [bx],ax
@IncHeadQ:
        ret
ENDP    @IncHead

PROC    @WorkInterrupt  NEAR
USES AX,BX
        cmp [byte ptr SKIP],0
        jz @WorkNotSkip
        jmp @WorkInt01  ;идет SKIP-команда
@WorkNotSkip:
        mov al,[byte ptr _MemorySeg+INTCON]
        test al,80H
        jz @WorkInt01   ;все прерывания запрещены
        test al,40H     ;Peripheral interrupt
        jz @WorkInt02   ;прерывания внешних устройств запрещены
        test [byte ptr _MemorySeg+PIR1],80h
        jz @WorkIntPIE1 ;прерывания PSP пока не было PSPIF=0
        test [byte ptr _MemorySeg+PIE1],80h
        jz @WorkIntPIE1 ;а прерывания PSP запрещены PSPIE=0
        jmp short @GoINT
@WorkIntPIE1:
        test [byte ptr _MemorySeg+PIR1],01h
        jz @WorkIntPIE2 ;прерывания TMR1 пока не было TMR1IF=0
        test [byte ptr _MemorySeg+PIE1],01h
        jz @WorkIntPIE2 ;а прерывания TMR1 запрещены TMR1IE=0
        jmp short @GoINT
@WorkIntPIE2:
@WorkInt02:
        test al,04H
        jz @WorkInt03   ;прерывания TMR0 пока еще не было
        test al,20H     ;прерывания TMR0
        jz @WorkInt03   ;а прерывания TMR0 запрещены
        jmp short @GoINT
@WorkInt03:
        test al,2
        jz @WorkInt04   ;прерывания INT пока еще нет
        test al,10H     ;прерывания INT
        jz @WorkInt04   ;а прерывания INT запрещены
        jmp short @GoINT
@WorkInt04:
        test al,1
        jz @WorkInt05   ;прерывания RBChange пока еще нет
        test al,08H     ;прерывания RBChange
        jz @WorkInt05   ;а прерывания RBChange запрещены
        jmp short @GoINT
@WorkInt05:
@WorkInt01:
        ret
@GoINT:
        mov al,[byte ptr _MemorySeg+PCL]
        mov ah,[byte ptr PCH]
        call near @PushInStack C,AX
        and [byte ptr _MemorySeg+INTCON],7FH
        mov [byte ptr PCH],0
        mov [byte ptr _MemorySeg+PCL],4
        ret
ENDP    @WorkInterrupt
PROC    @WorkPicOperation       NEAR
USES AX,BX
        mov al,[byte ptr _MemorySeg+OPTION]
        test al,20H     ;TMR0 работает от CLKOUT ?
        jnz @WorkPic01  ;нет,работает от RA4/T0CKI
;увеличиваем значение таймера
        cmp [byte ptr WaitTime],0       ;запись в таймер была?
        jz NotWtiteToTime
        dec [byte ptr WaitTime]         ;т.к. была запись в таймер
                                        ;два такта надо пропустить
        jmp short @WorkPic02
NotWtiteToTime:
        inc [byte ptr _MemorySeg+TMR0]
        jnz @WorkPic02  ;переполнения пока нет
        or [byte ptr _MemorySeg+INTCON],04H ;устанавливаем флаг переполнения счетчика
@WorkPic02:
@WorkPic01:
;------------------------------------------------
;таймер1
        test [byte ptr _MemorySeg+T1CON],01H
        jz Timer1ShutOff        ;таймер1 выключен
        inc [byte ptr _MemorySeg+TMR1L]
        jnz Timer1ShutOff
        inc [byte ptr _MemorySeg+TMR1H]
        jnz Timer1ShutOff
        or  [byte ptr _MemorySeg+PIR1],01H ;произошло переполнение таймера1
Timer1ShutOff:
;------------------------------------------------
;время работы
        add [word ptr _Timens],2
        cmp [word ptr _Timens],10
        jc Time01
        mov [word ptr _Timens],0
        inc [word ptr _Timemks]
        cmp [word ptr _Timemks],1000
        jc Time01
        mov [word ptr _Timemks],0
        inc [word ptr _Timems]
        cmp [word ptr _Timems],1000
        jc Time01
        mov [word ptr _Timems],0
        inc [word ptr _Timesec]
        cmp [word ptr _Timesec],60
        jc Time01
        mov [word ptr _Timesec],0
Time01:
;------------------------------------------------
;анализатор приема
        call @ReadByte C,StateOfVib
        test al,1
        jz @LineInZero
        cmp [byte ptr LastState],1
        jnz @ChangeState1
        inc [word ptr Period]
        jmp short @QAnaliz
@ChangeState1:
        mov [byte ptr LastState],1
        mov ax,[word ptr Period]
        mov [word ptr Period0],ax
        mov [word ptr Period],0
        jmp short @QAnaliz
@LineInZero:
        cmp [byte ptr LastState],0
        jnz @ChangeState0
        inc [word ptr Period]
        jmp short @QAnaliz
@ChangeState0:
        mov [byte ptr LastState],0
        mov ax,[word ptr Period]
        mov [word ptr Period1],ax
        mov [word ptr Period],0
        jmp short @QAnaliz
@QAnaliz:
;------------------------------------------------
;проверяем запрос IRQ
        test [byte ptr _MemorySeg+PORTA],20H    ;единичка есть ?
        jz IRQ_2
        test [byte ptr _MemorySeg+TRISA],20H    ;работает на вывод RA5 ?
        jnz IRQ_1       ;пока нет
        cmp [byte ptr LastStateIRQ],0
        jnz IRQ_3       ;запрос уже обработан
        mov [WORD ptr CounterReactionIRQ],ReactionOnIRQ
IRQ_3:  mov [byte ptr LastStateIRQ],1
        jmp short IRQ_1
IRQ_2:  mov [byte ptr LastStateIRQ],0
IRQ_1:
;------------------------------------------------
        dec [word ptr CounterPortB0]
        jnz DecPortB1
        mov [word ptr CounterPortB0],PeriodFor0
        xor [byte ptr _MemorySeg+PORTB],10H
DecPortB1:
        dec [word ptr CounterPortB1]
        jnz DecPortB2
        mov [word ptr CounterPortB1],PeriodFor1
        xor [byte ptr _MemorySeg+PORTB],20H
DecPortB2:
        dec [word ptr CounterPortB2]
        jnz DecPortB3
        mov [word ptr CounterPortB2],PeriodFor2
        xor [byte ptr _MemorySeg+PORTB],40H
DecPortB3:
        dec [word ptr CounterPortB3]
        jnz DecPortB4
        mov [word ptr CounterPortB3],PeriodFor3
        xor [byte ptr _MemorySeg+PORTB],80H
DecPortB4:
;------------------------------------------------
        mov al,[byte ptr _MemorySeg+PORTB]
        and al,0F0H
        cmp [byte ptr LastStatePortB],al
        jz PortBNotChanged
        mov [byte ptr LastStatePortB],al
        or [byte ptr _MemorySeg+INTCON],01H ;уст.флаг изменения состояния
PortBNotChanged:
;------------------------------------------------
        cmp [WORD ptr CounterReactionIRQ],0
        jz NotCountIRQ1
        dec [WORD ptr CounterReactionIRQ]
        jz CountIRQ1
NotCountIRQ1:
        jmp NotCountIRQ
CountIRQ1:
        call near @ReadByte C,TRISE
        and al,0BFH             ;ЭМУЛЯЦИЯ КОМАНДЫ ЧТЕНИЯ ЦП
        call near @WriteByte C,TRISE,AX
        call near @ReadByte C,PIR1
        or al,80H               ;ЭМУЛЯЦИЯ ЗАПРОСА ПРЕРЫВАНИЯ PSPIF=1
        call near @WriteByte C,PIR1,AX
        call near @ReadByte C,PORTD
;затолкаем данные в псевдо очередь для вывода на экран
        push si
        push di
        push cx
        push es
        push ds
        pop  es
        mov  di,offset RecevedDataFromPic
        mov  si,offset RecevedDataFromPic+1
        cld
        mov cx,SizeRecevQ-1
        rep movsb
        mov [RecevedDataFromPic+SizeRecevQ-1],al
        pop es
        pop cx
        pop di
        pop si
;СЕЙЧАС В AL ЧИСЛО СЧИТАННОЕ С ПИКУШКИ
        mov bl,al
        and al,0F0H
        cmp al,050H
        jnz ReadDPIC1
;       call far @PutReceveQ C,0E0H
ReadDPIC1:

NotCountIRQ:
;------------------------------------------------
;попробуем как бы записать данные в пикушку
;
        cmp [WORD ptr WaitFromBegin],0
        jz NotCount
        dec [WORD ptr WaitFromBegin]
        jmp ReceveWritePULL
NotCount:
        cmp [Word ptr TestNumCount],0
        jnz PokaNePishem
        mov [Word ptr TestNumCount],TestNum
;       call far @PutReceveQ C,0A0H
        jmp short Zapisali

PokaNePishem:
        dec [Word ptr TestNumCount]
Zapisali:
        cmp [WORD ptr CounterReactWrite],0
        jz NotCountWrite
        dec [WORD ptr CounterReactWrite]
        jnz ReceveWritePULL
        call near @ReadByte C,TRISE
        test al,80H             ;процессор считал предыдущие данные?
        jz CPUcanRead           ;вроде считал
        or al,20H               ;ставим флаг перезаписи(ошибки)
CPUcanRead:
        or al,080H              ;ЭМУЛЯЦИЯ КОМАНДЫ ЗАПИСИ ЦП
        call near @WriteByte C,TRISE,AX
        call near @ReadByte C,PIR1
        or al,80H               ;ЭМУЛЯЦИЯ ЗАПРОСА ПРЕРЫВАНИЯ PSPIF=1
        call near @WriteByte C,PIR1,AX
        call far @GetReceveData
        call near @WriteByte C,PORTD,AX
NotCountWrite:
        mov ax,[HeadReceve]
        cmp ax,[HvostReceve]
        jz ReceveWritePULL
        mov [WORD ptr CounterReactWrite],ReactionOnWrite
ReceveWritePULL:
;------------------------------------------------
;делаем работу линии
;       jmp short @EmulationGo ;выключена
        cmp [byte ptr _Linia],0
        jz @OutPICZero
        call near @ReadByte C,PORTB
        and al,0F9H
        or al,2
        call near @WriteByte C,PORTB,AX
        jmp short @EmulationGo
@OutPICZero:
        call near @ReadByte C,PORTB
        and al,0F9H
        or al,4
        call near @WriteByte C,PORTB,AX
@EmulationGo:
        sub [word ptr Count50BOD],1
        sbb [word ptr Count50BOD+2],0
        jnz NotBOD
        cmp [word ptr Count50BOD],0
        jnz NotBOD
        mov [word ptr Count50BOD],Delay50BOD
        mov [word ptr Count50BOD+2],HighDelay50BOD
        cmp [byte ptr CountData],0
        jnz NotEndData
        mov [byte ptr CountData],9
        mov [word ptr DataTransm],111101010B
        mov [word ptr Count50BOD],DelayError
        mov [word ptr Count50BOD+2],HighDelayError
NotEndData:
        dec [byte ptr CountData]
        mov [byte ptr _Linia],0
        shr [word ptr DataTransm],1
        jnc ItIsZero
        mov [byte ptr _Linia],1
ItIsZero:
NotBOD:
;------------------------------------------------
;эмуляция работы клавиатуры
;       jmp     QuitEmulKeyb ;эмуляция выключена
        cmp [WORD ptr PauseBWKeybTransmCoun],0
        jz EmulKeyb
        jmp NotEmulKeyb
EmulKeyb:
        cmp [PeriodChangeCount],0
	jz NotWaitPeriod
	jmp WaitPeriod
NotWaitPeriod:
	call near @ReadByte C,PORTB
	xor al,1
	call near @WriteByte C,PORTB,AX
	test al,1
	jz ItIsFallingEdge
	push ax
	call near @ReadByte C,OPTION
	test al,40H
	jz @NotInterrup
	jmp short @SetINTKeyb
ItIsFallingEdge:
	push ax
	call near @ReadByte C,OPTION
	test al,40H
	jnz @NotInterrup
@SetINTKeyb:
	call near @ReadByte C,INTCON
	or al,2
	call near @WriteByte C,INTCON,AX
@NotInterrup:
	pop ax
	test al,1
	jz LoadConstAgain
	dec [word ptr NumBitKeyboardCount]
	jz LoadAllConstAgain
	jmp short LoadConstAgain
LoadAllConstAgain:
	mov [WORD ptr PauseBWKeybTransmCoun],PauseBWKeybTransm
	mov [WORD ptr NumBitKeyboardCount],NumBitKeyboard
LoadConstAgain:
	mov [WORD ptr PeriodChangeCount],PeriodChange
	jmp short QuitEmulKeyb

WaitPeriod:
	dec [PeriodChangeCount]
	jmp short QuitEmulKeyb

NotEmulKeyb:
	dec [WORD ptr PauseBWKeybTransmCoun]
QuitEmulKeyb:
;------------------------------------------------
	ret
ENDP	@WorkPicOperation
PROC	@HookOneCommand$qv	FAR
LOCAL	ADRES:WORD
USES BX,CX
	mov bl,[byte ptr _MemorySeg+PCL]
	mov bh,[byte ptr PCH]
	add bx,bx
	add bx,offset _CodeSeg
	mov ax,[word ptr bx]
	mov bl,ah
	xor bh,bh
	cmp bl,40H
	jnc Unumplemented
	shl bx,1
	add bx,offset TableCode
;INC PCL
	inc [byte ptr _MemorySeg+PCL]
	jnz @IncAd1
	inc [byte ptr PCH]
@IncAd1:
;------
	call near @WorkPicOperation
	cmp [byte ptr SKIP],0
	jnz @Hook01
	mov dx,UnumplementedCode
	call [WORD PTR CS:BX]
	mov ax,dx
	push ax
	call near @WorkInterrupt
	cmp [byte ptr Dummy],0
	jz NotDummy
	mov [byte ptr Dummy],0
	call near @WorkPicOperation
NotDummy:

	pop ax
	ret
Unumplemented:
	mov ax,UnumplementedCode
	ret
@Hook01:
	mov [byte ptr SKIP],0
	xor ax,ax
	ret
TableCode DW Code00,Code01,Code02,Code03,Code04,Code05,Code06,Code07
	DW Code08,Code09,Code0A,Code0B,Code0C,Code0D,Code0E,Code0F
	DW Code10,Code11,Code12,Code13,Code14,Code15,Code16,Code17
	DW Code18,Code19,Code1A,Code1B,Code1C,Code1D,Code1E,Code1F
	DW Code20,Code21,Code22,Code23,Code24,Code25,Code26,Code27
	DW Code28,Code29,Code2A,Code2B,Code2C,Code2D,Code2E,Code2F
	DW Code30,Code31,Code32,Code33,Code34,Code35,Code36,Code37
	DW Code38,Code39,Code3A,Code3B,Code3C,Code3D,Code3E,Code3F
ENDP	@HookOneCommand$qv
;------------------------------------------------
PROC	@CodeForInstruction NEAR
Code3B:
	retn
;------------------------------------------------
;ADDLW k
;(W)+k ->W , Status Affected C,DC,Z
Code3E:
Code3F: xor bh,bh
	add [byte ptr _W],al
	pushf
	jnc @ADD_1	;переноса не было C поставить в 0
	or bh,01H       ;перенос был C поставить в 1
@ADD_1:	popf
	pushf
	jnz @ADD_2      ;результат не равен нулю Z=0
	or bh,04H	;результат  равен нулю Z=1
@ADD_2:	popf
	and [byte ptr _MemorySeg+STATUS],0F8H
	or  [byte ptr _MemorySeg+STATUS],bh
	mov dx,OkOperation
	retn
;------------------------------------------------
;ANDLW k
; W & k ->W , Status Affected Z
Code39: and [byte ptr _MemorySeg+STATUS],0FBH
	and [byte ptr _W],al
	jnz @AND_1      ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@AND_1:
	mov dx,OkOperation
	retn
;------------------------------------------------
;ADDWF f,d
;(W)+(f) ->(dest) , Status Affected C,DC,Z
Code07:
	mov cx,ax
	call near @ReadBankByte C,AX
	xor bh,bh
	add al,[byte ptr _W]
	pushf
	jnc @ADD_11	;переноса не было C поставить в 0
	or bh,01H       ;перенос был C поставить в 1
@ADD_11:popf
	pushf
	jnz @ADD_21     ;результат не равен нулю Z=0
	or bh,04H	;результат  равен нулю Z=1
@ADD_21:popf
	and [byte ptr _MemorySeg+STATUS],0F8H
	or  [byte ptr _MemorySeg+STATUS],bh
	test cx,080H
	JZ ADDWFtoW
	call near @WriteBankByte C,CX,AX
	retn
ADDWFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;ANDWF f,d
; W & (f) ->(dest) , Status Affected Z
Code05:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov ah,[byte ptr _W]
	and [byte ptr _MemorySeg+STATUS],0FBH
	and al,ah
	jnz @AND_11     ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@AND_11:test bx,080H
	JZ ANDWFtoW
	call near @WriteBankByte C,BX,AX
	retn
ANDWFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;BCF f,b
;0->f<b>
Code10:
Code11:
Code12:
Code13:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov dx,bx
	shl dx,1
	and dh,07h
	mov dl,00000001B
	cmp dh,0
BCF_02:	jz BCF_01
	shl dl,1
	dec dh
	jmp short BCF_02
BCF_01: xor dl,0FFH
	and al,dl
	call near @WriteBankByte C,BX,AX
	retn
;------------------------------------------------
;BTFSC f,b
;skip if (f<b>)=0
Code18:
Code19:
Code1A:
Code1B:
	mov bx,ax
	call near @ReadBankByte C,BX
	push dx
	mov dx,bx
	shl dx,1
	and dh,07h
	mov dl,00000001B
	cmp dh,0
BTFSC_02:
	jz BTFSC_01
	shl dl,1
	dec dh
	jmp short BTFSC_02
BTFSC_01:
	test al,dl
	jnz BTFSC_03
	mov [byte ptr SKIP],SkipCommand
BTFSC_03:
	pop dx
	retn
;------------------------------------------------
;BSF f,b
;1->f<b>
Code14:
Code15:
Code16:
Code17:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov dx,bx
	shl dx,1
	and dh,07h
	mov dl,00000001B
	cmp dh,0
BSF_02:	jz BSF_01
	shl dl,1
	dec dh
	jmp short BSF_02
BSF_01: or al,dl
	call near @WriteBankByte C,BX,AX
	retn
;------------------------------------------------
;BTFSS f,b
;skip if (f<b>)=1
Code1C:
Code1D:
Code1E:
Code1F:
	mov bx,ax
	call near @ReadBankByte C,BX
	push dx
	mov dx,bx
	shl dx,1
	and dh,07h
	mov dl,00000001B
	cmp dh,0
BTFSS_02:
	jz BTFSS_01
	shl dl,1
	dec dh
	jmp short BTFSS_02
BTFSS_01:
	test al,dl
	jz BTFSS_03
	mov [byte ptr SKIP],SkipCommand
BTFSS_03:
	pop dx
	retn
;------------------------------------------------
;CALL k
;(PC)+1->TOS
;k->PC<10:0>
;(PCLATH<4:3>)->PC<12:11>
Code20:
Code21:
Code22:
Code23:
Code24:
Code25:
Code26:
Code27:
	mov bx,ax
	mov al,[byte ptr _MemorySeg+PCL]
	mov ah,[byte ptr PCH]
	call near @PushInStack C,AX
	push dx
	mov al,[byte ptr _MemorySeg+PCLATH]
	and al,18H
	and bh,03H
	or bh,al
	mov [byte ptr PCH],bh
	mov [byte ptr _MemorySeg+PCL],bl
	pop dx
	mov [byte ptr Dummy],1
	retn
;------------------------------------------------
;CLRF f
;00->f
;1->Z  , Status Affected Z
;и совпадает вторая команда CLRW
Code01: TEST AX,0080h
	jz CLRWComm
	call near @WriteBankByte C,AX,0
	jmp short SecondComm
CLRWComm:
	mov [byte ptr _W],0
SecondComm:
	or [byte ptr _MemorySeg+STATUS],04h ;Z=1
	mov dx,OkOperation
	retn
;------------------------------------------------
;CLRWDT -
;________________________________________________
;RETFIE -
;________________________________________________
;MOVWF f
;(W)->(f) ,Status Affected None
;________________________________________________
;NOP    -
;________________________________________________
;OPTION -
;________________________________________________
;RETURN -
;________________________________________________
;SLEEP  -
;________________________________________________
;TRIS f
;W->TRIS register f
;________________________________________________
Code00:
	cmp al,064H
	jnz Code00_1
	jmp short CLRWDTComm
Code00_1:
	cmp al,09H
	jnz Code00_2
	jmp short RETFIEComm
Code00_2:
	cmp al,08H
	jnz Code00_3
	jmp short RETURNComm
Code00_3:
	cmp al,63H
	jnz Code00_4
	jmp short SLEEPComm
Code00_4:
	cmp al,62H
	jnz Code00_5
	jmp short OPTIONComm
Code00_5:
	test ax,080h
	jz  TRISFComm
	jmp short MOVWFComm
TRISFComm:
	retn
MOVWFComm:
	mov bl,[byte ptr _W]
	call near @WriteBankByte C,AX,BX
	retn
CLRWDTComm:
	mov dx,OkOperation
	retn
RETFIEComm:
	call near @PopInStack
	mov [byte ptr _MemorySeg+PCL],al
	mov [byte ptr PCH],ah
	or [byte ptr _MemorySeg+INTCON],80H
	mov [byte ptr Dummy],1
	retn
RETURNComm:
	call near @PopInStack
	mov [byte ptr _MemorySeg+PCL],al
	mov [byte ptr PCH],ah
	mov [byte ptr Dummy],1
	retn
SLEEPComm:
	retn
OPTIONComm:
	retn

;------------------------------------------------
;COMF f,d
;(#f)->(dest)
Code09:
	retn
;------------------------------------------------
;DECF f,d
;(f)-1)->(dest) , Status Affected Z
Code03:
	mov bx,ax
	call near @ReadBankByte C,AX
	and [byte ptr _MemorySeg+STATUS],0FBH
	dec al
	jnz @STAT_1      ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@STAT_1:
	test bx,080H
	JZ DECFtoW
	call near @WriteBankByte C,BX,AX
	retn
DECFtoW:mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;DECFSZ f,d
;(f)-1)->(dest) ,Skip if result =0, Status Affected None
Code0B:
	mov bx,ax
	call near @ReadBankByte C,AX
	dec al
	jnz DECFSZNotSkip
	mov [byte ptr SKIP],SkipCommand
DECFSZNotSkip:
	test bx,080H
	JZ DECFSZtoW
	call near @WriteBankByte C,BX,AX
	retn
DECFSZtoW:mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;INCF f,d
;(f)+1)->(dest) , Status Affected Z
Code0A:
	mov bx,ax
	call near @ReadBankByte C,AX
	and [byte ptr _MemorySeg+STATUS],0FBH
	inc al
	jnz @STAT_11     ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@STAT_11:
	test bx,080H
	JZ INCFtoW
	call near @WriteBankByte C,BX,AX
	retn
INCFtoW:mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;INCFSZ f,d
;(f)+1)->(dest) ,Skip if result =0, Status Affected None
Code0F:
	mov bx,ax
	call near @ReadBankByte C,AX
	inc al
	jnz INCFSZNotSkip
	mov [byte ptr SKIP],SkipCommand
INCFSZNotSkip:
	test bx,080H
	JZ INCFSZtoW
	call near @WriteBankByte C,BX,AX
	retn
INCFSZtoW:mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;GOTO k
;k->PC<10:0>
;(PCLATH<4:3>)->PC<12:11>  Status Affected None
Code28:
Code29:
Code2A:
Code2B:
Code2C:
Code2D:
Code2E:
Code2F:
	mov bx,ax
	mov ah,[byte ptr PCH]
	mov al,[byte ptr _MemorySeg+PCLATH]
	and al,18H
	and bh,07H
	or bh,al
	mov [byte ptr PCH],bh
	mov [byte ptr _MemorySeg+PCL],bl
	mov [byte ptr Dummy],1
	mov dx,OkOperation
	retn
;------------------------------------------------
;IORLW k
;(W) or (k) ->(W) , Status Affected Z
Code38:
	and [byte ptr _MemorySeg+STATUS],0FBH
	or [byte ptr _W],al
	jnz @IOR_1      ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@IOR_1:
	mov dx,OkOperation
	retn
;------------------------------------------------
;IORWF f,d
;(W) or (f) ->(dest) , Status Affected Z
Code04:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov ah,[byte ptr _W]
	and [byte ptr _MemorySeg+STATUS],0FBH
	or al,ah
	jnz @IOR_11     ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@IOR_11:test bx,080H
	JZ IORWFtoW
	call near @WriteBankByte C,BX,AX
	retn
IORWFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;MOVLW k
;k->(W) ,Status Affected None
Code30:
Code31:
Code32:
Code33:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;MOVF f,d
;(f)->(dest) , Status Affected Z
Code08:
	mov bx,ax
	call near @ReadBankByte C,AX
	test bx,080H
	JNZ NOTMOVFtoW
	mov [byte ptr _W],al
NOTMOVFtoW:
	mov dx,OkOperation
	retn
;------------------------------------------------
;RETLW k
; k->w;TOS->PC ,Status Affected None
Code34:
Code35:
Code36:
Code37:
	mov [byte ptr _W],al
	call near @PopInStack
	mov [byte ptr _MemorySeg+PCL],al
	mov [byte ptr PCH],ah
	mov [byte ptr Dummy],1
	mov dx,OkOperation
	retn
;------------------------------------------------
;RLF f,d
;Status Affected C
Code0D:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov cl,al
	mov al,[byte ptr _MemorySeg+STATUS]
	shr al,1
	rcl cl,1
	rcl al,1
	mov [byte ptr _MemorySeg+STATUS],al
	test bx,080H
	jz RLFToW
	call near @WriteBankByte C,BX,CX
	mov dx,OkOperation
	retn
RLFToW: mov [byte ptr _W],cl
	mov dx,OkOperation
	retn

;------------------------------------------------
;RRF f,d
;Status Affected C
Code0C:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov cl,al
	mov al,[byte ptr _MemorySeg+STATUS]
	shr al,1
	rcr cl,1
	rcl al,1
	mov [byte ptr _MemorySeg+STATUS],al
	test bx,080H
	jz RRFToW
	call near @WriteBankByte C,BX,CX
	mov dx,OkOperation
	retn
RRFToW: mov [byte ptr _W],cl
	mov dx,OkOperation
	retn
;------------------------------------------------
;SUBLW k
;k-(W) ->(W) , Status Affected Z,C,DC
Code3C:
Code3D:
	mov ah,[byte ptr _W]
	xor bh,bh
	xor ah,0FFH
	inc ah
	add al,ah
	pushf
	jnc @SUB_1	;переноса не было C поставить в 0
	or bh,01H       ;перенос был C поставить в 1
@SUB_1:	popf
	pushf
	jnz @SUB_2      ;результат не равен нулю Z=0
	or bh,04H	;результат  равен нулю Z=1
@SUB_2:	popf
	and [byte ptr _MemorySeg+STATUS],0F8H
	or  [byte ptr _MemorySeg+STATUS],bh
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;SUBWF f,d
;f-(W) ->(dest) , Status Affected Z,C,DC
Code02:
	mov cx,ax
	call near @ReadBankByte C,CX
	mov ah,[byte ptr _W]
	xor bh,bh
	xor ah,0FFH
	inc ah
	add al,ah
	pushf
	jnc @SUB_11	;переноса не было C поставить в 0
	or bh,01H       ;перенос был C поставить в 1
@SUB_11:popf
	pushf
	jnz @SUB_21     ;результат не равен нулю Z=0
	or bh,04H	;результат  равен нулю Z=1
@SUB_21:popf
	and [byte ptr _MemorySeg+STATUS],0F8H
	or  [byte ptr _MemorySeg+STATUS],bh
	test cx,080H
	JZ SUBWFtoW
	call near @WriteBankByte C,CX,AX
	retn
SUBWFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;SWAPF f,d
;f<0:3>->d<4:7>
;f<4:7>->d<0:3> ,Status Affected None
Code0E:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov ah,al
	shl ah,4
	shr al,4
	or al,ah
	test bx,080H
	JZ SWAPFtoW
	call near @WriteBankByte C,BX,AX
	retn
SWAPFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
;------------------------------------------------
;XORLW k
;(W) XOR k -> (W) , Status Affected Z
Code3A:
	and [byte ptr _MemorySeg+STATUS],0FBH
	xor [byte ptr _W],al
	jnz @XOR_1      ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@XOR_1:
	mov dx,OkOperation
	retn
;------------------------------------------------
;XORWF f,d
;(W) XOR (f) -> (dest) , Status Affected Z
Code06:
	mov bx,ax
	call near @ReadBankByte C,BX
	mov ah,[byte ptr _W]
	and [byte ptr _MemorySeg+STATUS],0FBH
	xor al,ah
	jnz @XOR_11     ;результат не равен нулю Z=0
	or [byte ptr _MemorySeg+STATUS],04H	;результат  равен нулю Z=1
@XOR_11:test bx,080H
	JZ XORWFtoW
	call near @WriteBankByte C,BX,AX
	retn
XORWFtoW:
	mov [byte ptr _W],al
	mov dx,OkOperation
	retn
ENDP	@CodeForInstruction

;------------------------------------------------
PROC	@DisAsmOneCommand	FAR
ARG	ADRES:WORD
USES BX,SI,DI,CX,DX
	mov bx,offset _CodeSeg
	add bx,[ADRES]
	add bx,[ADRES]
	mov ax,[word ptr bx]
	mov bl,ah
	xor bh,bh
	cmp bl,40H
	jnc UnumplementedComm
	shl bx,1
	add bx,offset DisTableCode
	mov dx,UnumplementedCode
	push ds
	pop es
	cld
	push ax
	mov al,0
	mov cx,80
	mov di,offset StringDisAsm1
	rep stosb
	mov di,offset StringDisAsm1
	pop ax
	call [WORD PTR CS:BX]
	cmp dx,UnumplementedCode
	jz UnumplementedComm
	mov bx,offset StringDisAsm
@DisAsmOn2:
	mov al,[byte ptr cs:si]
	mov [byte ptr bx],al
	cmp al,0
	jz @DisAsmOn1
	inc si
	inc bx
	jmp short @DisAsmOn2
@DisAsmOn1:
	mov [byte ptr bx],' '
	inc bx
	mov di,offset StringDisAsm1
@DisAsmOn4:
	mov al,[byte ptr di]
	mov [byte ptr bx],al
	cmp al,0
	jz @DisAsmOn3
	inc di
	inc bx
	jmp short @DisAsmOn4
@DisAsmOn3:
	xor ax,ax
	ret
UnumplementedComm:
	mov bx,offset StringDisAsm
	mov si,offset UnUmplem
@DisAsmOn6:
	mov al,[byte ptr cs:si]
	mov [byte ptr bx],al
	cmp al,0
	jz @DisAsmOn5
	inc si
	inc bx
	jmp short @DisAsmOn6
@DisAsmOn5:
	inc bx
	mov [byte ptr bx],0
	mov ax,1
	ret
DisTableCode DW DisCode00,DisCode01,DisCode02,DisCode03,DisCode04,DisCode05,DisCode06,DisCode07
	DW DisCode08,DisCode09,DisCode0A,DisCode0B,DisCode0C,DisCode0D,DisCode0E,DisCode0F
	DW DisCode10,DisCode11,DisCode12,DisCode13,DisCode14,DisCode15,DisCode16,DisCode17
	DW DisCode18,DisCode19,DisCode1A,DisCode1B,DisCode1C,DisCode1D,DisCode1E,DisCode1F
	DW DisCode20,DisCode21,DisCode22,DisCode23,DisCode24,DisCode25,DisCode26,DisCode27
	DW DisCode28,DisCode29,DisCode2A,DisCode2B,DisCode2C,DisCode2D,DisCode2E,DisCode2F
	DW DisCode30,DisCode31,DisCode32,DisCode33,DisCode34,DisCode35,DisCode36,DisCode37
	DW DisCode38,DisCode39,DisCode3A,DisCode3B,DisCode3C,DisCode3D,DisCode3E,DisCode3F
ENDP	@DisAsmOneCommand
;------------------------------------------------
UnUmplem	db 'Unimplemented',0
InstADDLW	db 'ADDLW',0
InstADDWF	db 'ADDWF',0
InstSUBLW	db 'SUBLW',0
InstSUBWF	db 'SUBWF',0
InstSWAPF	db 'SWAPF',0
InstANDLW	db 'ANDLW',0
InstANDWF	db 'ANDWF',0
InstIORLW	db 'IORLW',0
InstIORWF	db 'IORWF',0
InstXORLW	db 'XORLW',0
InstXORWF	db 'XORWF',0
InstBCF  	db 'BCF  ',0
InstBSF  	db 'BSF  ',0
InstBTFSC	db 'BTFSC',0
InstBTFSS	db 'BTFSS',0
InstCALL 	db 'CALL ',0
InstGOTO 	db 'GOTO ',0
InstRETURN	db 'RETURN',0
InstRETFIE	db 'RETFIE',0
InstCLRWDT	db 'CLRWDT',0
InstSLEEP 	db 'SLEEP',0
InstRETLW 	db 'RETLW',0
InstCLRW  	db 'CLRW ',0
InstCLRF  	db 'CLRF ',0
InstMOVWF 	db 'MOVWF',0
InstMOVLW 	db 'MOVLW',0
InstMOVF  	db 'MOVF ',0
InstRLF   	db 'RLF  ',0
InstRRF   	db 'RRF  ',0
InstDECF  	db 'DECF ',0
InstDECFSZ  	db 'DECFSZ',0
InstINCF  	db 'INCF ',0
InstINCFSZ  	db 'INCFSZ',0

PROC	@DisCodeForInstruction NEAR
DisCode3B:
	retn
;------------------------------------------------
;ADDLW k
;(W)+k ->W , Status Affected C,DC,Z
DisCode3E:
DisCode3F:
	mov si,offset InstADDLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;ANDLW k
; W & k ->W , Status Affected Z
DisCode39:
	mov si,offset InstANDLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;ADDWF f,d
;(W)+(f) ->(dest) , Status Affected C,DC,Z
DisCode07:
	mov si,offset InstADDWF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;ANDWF f,d
; W & (f) ->(dest) , Status Affected Z
DisCode05:
	mov si,offset InstANDWF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;BCF f,b
;0->f<b>
DisCode10:
DisCode11:
DisCode12:
DisCode13:
	mov si,offset InstBCF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintNumB
	mov dx,OkOperation
	retn
;------------------------------------------------
;BTFSC f,b
;skip if (f<b>)=0
DisCode18:
DisCode19:
DisCode1A:
DisCode1B:
	mov si,offset InstBTFSC
	call far @IntelByte2TextBank
	add di,2
	call far @PrintNumB
	mov dx,OkOperation
	retn
;------------------------------------------------
;BSF f,b
;1->f<b>
DisCode14:
DisCode15:
DisCode16:
DisCode17:
	mov si,offset InstBSF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintNumB
	mov dx,OkOperation
	retn
;------------------------------------------------
;BTFSS f,b
;skip if (f<b>)=1
DisCode1C:
DisCode1D:
DisCode1E:
DisCode1F:
	mov si,offset InstBTFSS
	call far @IntelByte2TextBank
	add di,2
	call far @PrintNumB
	mov dx,OkOperation
	retn
;------------------------------------------------
;CALL k
;(PC)+1->TOS
;k->PC<10:0>
;(PCLATH<4:3>)->PC<12:11>
DisCode20:
DisCode21:
DisCode22:
DisCode23:
DisCode24:
DisCode25:
DisCode26:
DisCode27:
	mov si,offset InstCALL
	call far @Word2TextBank
	mov dx,OkOperation
	retn
;------------------------------------------------
;CLRF f
;00->f
;1->Z  , Status Affected Z
;и совпадает вторая команда CLRW
DisCode01: TEST AX,0080h
	jz DISCLRWComm
	jmp short DISSecondComm
DISCLRWComm:
	mov si,offset InstCLRW
	mov dx,OkOperation
	retn
DISSecondComm:
	mov si,offset InstCLRF
	call far @IntelByte2TextBank
	mov dx,OkOperation
	retn
;------------------------------------------------
;CLRWDT -
;________________________________________________
;RETFIE -
;________________________________________________
;MOVWF f
;(W)->(f) ,Status Affected None
;________________________________________________
;NOP    -
;________________________________________________
;OPTION -
;________________________________________________
;RETURN -
;________________________________________________
;SLEEP  -
;________________________________________________
;TRIS f
;W->TRIS register f
;________________________________________________
DisCode00:
	cmp al,064H
	jnz DisCode00_1
	jmp short DISCLRWDTComm
DisCode00_1:
	cmp al,09H
	jnz DisCode00_2
	jmp short DISRETFIEComm
DisCode00_2:
	cmp al,08H
	jnz DisCode00_3
	jmp short DISRETURNComm
DisCode00_3:
	cmp al,63H
	jnz DisCode00_4
	jmp short DISSLEEPComm
DisCode00_4:
	cmp al,62H
	jnz DisCode00_5
	jmp short DISOPTIONComm
DisCode00_5:
	test ax,080h
	jz  DISTRISFComm
	jmp short DISMOVWFComm
DISTRISFComm:
	retn
DISMOVWFComm:
	mov si,offset InstMOVWF
	call far @IntelByte2TextBank C,AX,DI
	mov dx,OkOperation
	retn
DISCLRWDTComm:
	mov si,offset InstCLRWDT
	mov dx,OkOperation
	retn
DISRETFIEComm:
	mov si,offset InstRETFIE
	mov dx,OkOperation
	retn
DISRETURNComm:
	mov si,offset InstRETURN
	mov dx,OkOperation
	retn
DISSLEEPComm:
	mov si,offset InstSLEEP
	mov dx,OkOperation
	retn
DISOPTIONComm:
	retn

;------------------------------------------------
;COMF f,d
;(#f)->(dest)
DisCode09:
	retn
;------------------------------------------------
;DECF f,d
;(f)-1)->(dest) , Status Affected Z
DisCode03:
	mov si,offset InstDECF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;DECFSZ f,d
;(f)-1)->(dest) ,Skip if result =0, Status Affected None
DisCode0B:
	mov si,offset InstDECFSZ
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;INCF f,d
;(f)+1)->(dest) , Status Affected Z
DisCode0A:
	mov si,offset InstINCF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;INCFSZ f,d
;(f)+1)->(dest) ,Skip if result =0, Status Affected None
DisCode0F:
	mov si,offset InstINCFSZ
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;GOTO k
;k->PC<10:0>
;(PCLATH<4:3>)->PC<12:11>  Status Affected None
DisCode28:
DisCode29:
DisCode2A:
DisCode2B:
DisCode2C:
DisCode2D:
DisCode2E:
DisCode2F:
	mov si,offset InstGOTO
	call far @Word2TextBank
	mov dx,OkOperation
	retn
;------------------------------------------------
;IORLW k
;(W) or (k) ->(W) , Status Affected Z
DisCode38:
	mov si,offset InstIORLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;IORWF f,d
;(W) or (f) ->(dest) , Status Affected Z
DisCode04:
	mov si,offset InstIORWF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;MOVLW k
;k->(W) ,Status Affected None
DisCode30:
DisCode31:
DisCode32:
DisCode33:
	mov si,offset InstMOVLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;MOVF f,d
;(f)->(dest) , Status Affected Z
DisCode08:
	mov si,offset InstMOVF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;RETLW k
; k->w;TOS->PC ,Status Affected None
DisCode34:
DisCode35:
DisCode36:
DisCode37:
	mov si,offset InstRETLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;RLF f,d
;Status Affected C
DisCode0D:
	mov si,offset InstRLF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;RRF f,d
;Status Affected C
DisCode0C:
	mov si,offset InstRRF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;SUBLW k
;k-(W) ->(W) , Status Affected Z,C,DC
DisCode3C:
DisCode3D:
	mov si,offset InstSUBLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;SUBWF f,d
;f-(W) ->(dest) , Status Affected Z,C,DC
DisCode02:
	mov si,offset InstSUBWF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;SWAPF f,d
;f<0:3>->d<4:7>
;f<4:7>->d<0:3> ,Status Affected None
DisCode0E:
	mov si,offset InstSWAPF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn
;------------------------------------------------
;XORLW k
;(W) XOR k -> (W) , Status Affected Z
DisCode3A:
	mov si,offset InstXORLW
	call far @Byte2Text C,AX,DI
	mov dx,OkOperation
	retn
;------------------------------------------------
;XORWF f,d
;(W) XOR (f) -> (dest) , Status Affected Z
DisCode06:
	mov si,offset InstXORWF
	call far @IntelByte2TextBank
	add di,2
	call far @PrintWorF
	mov dx,OkOperation
	retn

;------------------------------------------------


ENDP	@DisCodeForInstruction





PROC	@Byte2TextBank	FAR
USES AX,BX,DI
	mov bx,ax
	and bx,07FH
	call near @ReadByte C,03H
	test al,20H
	jz @Byte2TextB1
	or bx,080H
@Byte2TextB1:
	call far @Byte2Text C,BX,DI
	ret
ENDP	@Byte2TextBank
PROC	@IntelByte2TextBank	FAR
USES AX,BX,DI,SI
	mov bx,ax
	and bx,07FH
	call near @ReadByte C,03H
	test al,20H
	jz @IntelByte2TextB1
	or bx,080H
@IntelByte2TextB1:
	cmp bx,20H
	jc @IntelB01
	cmp bx,80H
	jc @IntelB02
	cmp bx,0A0H
	jc @IntelB01Second
@IntelB02:
	call far @Byte2Text C,BX,DI
	ret
@IntelB01:
	push bx
	shl bx,1
	add bx,offset FirstTable
	mov si,[word ptr cs:bx]
	pop bx
	cmp si,0
	jz @IntelB02
	jmp short @CopyByffer
@IntelB01Second:
	push bx
	sub bx,80H
	shl bx,1
	add bx,offset SecondTable
	mov si,[word ptr cs:bx]
	pop bx
	cmp si,0
	jz @IntelB02
@CopyByffer:
	mov al,[byte ptr cs:si]
	mov [byte ptr di],al
	cmp al,0
	jz @CopyALL
	inc si
	inc di
	jmp short @CopyByffer

@CopyALL:
	ret
LABEL FirstTable WORD
dw    	StINDF, StTMR0,  StPCL,   StSTATUS,StFSR,    StPORTA,  StPORTB, StPORTC
dw	StPORTD,StPORTE, StPCLATH,StINTCON,StPIR1,   StPIR2,   StTMR1L, StTMR1H
dw	StT1CON,StTMR2,  StT2CON, StSSPBUF,StSSPCON, StCCPR1L, StCCPR1H,StCCP1CON
dw	StRCSTA,StTXREG, StRCREG, StCCPR2L,StCCPR2H, StCCP2CON,0,       0
LABEL SecondTable WORD
dw    	StINDF, StOPTION,StPCL,   StSTATUS,StFSR,    StTRISA,  StTRISB, StTRISC
dw	StTRISD,StTRISE, StPCLATH,StINTCON,StPIE1,   StPIE2,   StPCON,  0
dw      0,      0,       StPR2,   StSSPADD,StSSPSTAT,0,        0,       0
dw	StTXSTA,StSPBRG, 0,       0,       0,        0,        0,       0

StINDF		db 'INDF',0
StTMR0		db 'TMR0',0
StPCL		db 'PCL',0
StSTATUS	db 'STATUS',0
StFSR		db 'FSR',0
StPORTA		db 'PORTA',0
StPORTB		db 'PORTB',0
StPORTC		db 'PORTC',0
StPORTD		db 'PORTD',0
StPORTE		db 'PORTE',0
StPCLATH	db 'PCLATH',0
StINTCON	db 'INTCON',0
StPIR1		db 'PIR1',0
StPIR2		db 'PIR2',0
StTMR1L		db 'TMR1L',0
StTMR1H		db 'TMR1H',0
StT1CON		db 'T1CON',0
StTMR2		db 'TMR2',0
StT2CON		db 'T2CON',0
StSSPBUF	db 'SSPBUF',0
StSSPCON	db 'SSPCON',0
StCCPR1L	db 'CCPR1L',0
StCCPR1H	db 'CCPR1H',0
StCCP1CON	db 'CCP1CON',0
StRCSTA		db 'RCSTA',0
StTXREG		db 'TXREG',0
StRCREG		db 'RCREG',0
StCCPR2L	db 'CCPR2L',0
StCCPR2H	db 'CCPR2H',0
StCCP2CON	db 'CCP2CON',0
StOPTION	db 'OPTION',0
StTRISA		db 'TRISA',0
StTRISB		db 'TRISB',0
StTRISC		db 'TRISC',0
StTRISD		db 'TRISD',0
StTRISE		db 'TRISE',0
StPIE1		db 'PIE1',0
StPIE2		db 'PIE2',0
StPCON		db 'PCON',0
StPR2		db 'PR2',0
StSSPADD  	db 'SSPADD',0
StSSPSTAT	db 'SSPSTAT',0
StTXSTA		db 'TXSTA',0
StSPBRG		db 'SPBRG',0

ENDP	@IntelByte2TextBank

PROC	@Word2TextBank	FAR
USES AX,BX
	mov bx,ax
	call near @ReadByte C,PCLATH
	and al,18H
	and bh,07H
	or bh,al
	call far @Word2Text C,BX,DI
	ret
ENDP	@Word2TextBank
PROC	@PrintWorF	FAR
@PrintWorF01:
	cmp [byte ptr di],0
	jz @PrintWorF02
	inc di
	jmp short @PrintWorF01
@PrintWorF02:
	mov [byte ptr di],','
	mov [byte ptr di+1],'F'
	test ax,080H
	jnz PrintedF
	mov [byte ptr di+1],'W'
PrintedF:
	ret
ENDP	@PrintWorF
PROC	@PrintNumB	FAR
USES AX
@PrintNum01:
	cmp [byte ptr di],0
	jz @PrintNum02
	inc di
	jmp short @PrintNum01
@PrintNum02:
	shl ax,1
	and ah,07H
	add ah,30H
	mov [byte ptr di],','
	mov [byte ptr di+1],ah
	ret
ENDP	@PrintNumB
STACK
END
