;----------------------------------
; Data Segment
;----------------------------------
SIZE                .INT 7
CNT                 .INT 0
TENTH               .INT 0
DATA                .INT 0
FLAG                .INT 0
OPDV                .INT 0
C                   .BYT '\0\0\0\0\0\0\0'

CRLF                .BYT '\n'
AT                  .BYT '@'
PLUS                .BYT '+'
MINUS               .BYT '-'

ZERO                .BYT '0'
ONE                 .BYT '1'
TWO                 .BYT '2'
THREE               .BYT '3'
FOUR                .BYT '4'
FIVE                .BYT '5'
SIX                 .BYT '6'
SEVEN               .BYT '7'
EIGHT               .BYT '8'
NINE                .BYT '9'

NOTANUMBER          .BYT ' is not a number\n'
NOTANUMBERSZ        .INT 17

OPERANDIS           .BYT 'Operand is '
OPERANDISSZ         .INT 11

NUMTOOBIG           .BYT 'Number too Big\n'
NUMTOOBIGSZ         .INT 15

STROVERFLOW         .BYT 'Stack overflow detected! Terminating application.\n'
STROVERFLOWSZ       .INT 50

STRUNDERFLOW        .BYT 'Stack underflow detected! Terminating application.\n'
STRUNDERFLOWSZ      .INT 51

;----------------------------------
; void main() {
;----------------------------------
; reset(1, 0, 0, 0) // Reset globals
MAIN                MOV R1, SP              ; Check overflow
                    ADI R1, -24
                    CMP R1, SL
                    BLT R1, OVERFLOW
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4              
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    SUB R1, R1              ; Push 1
                    ADI R1, 1
                    STR R1, (SP)
                    ADI SP, -4
                    SUB R1, R1              ; Push 0
                    STR R1, (SP)
                    ADI SP, -4
                    STR R1, (SP)            ; Push 0
                    ADI SP, -4
                    STR R1, (SP)            ; Push 0
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)                    
                    JMP RESET               ; reset(1, 0, 0, 0)                      
; getdata() // Get data
                    MOV R1, SP              ; Check overflow
                    ADI R1, -8
                    CMP R1, SL
                    BLT R1, OVERFLOW                    
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)                  
                    JMP GETDATA             ; getdata()                    
; while (c[0] != '@') {                    
MAINWHILE           LDB R1, C               ; Does c[0] == '@'?
                    LDB R2, AT
                    CMP R2, R1
                    BRZ R2, ENDMAINWHILE    ; Yes--break out of loop                    
;   if (c[0] == '+' || c[0] == '-') {                   
                    LDB R2, PLUS            ; Does c[0] == '+'?
                    CMP R2, R1                          
                    BRZ R2, GETSIGBYTE      ; Yes--jump to GETSIGBYTE
                    LDB R2, MINUS           ; Does c[0] == '-'?
                    CMP R2, R1
                    BNZ R2, DEFAULTSIGN     ; No--jump to else case
;     getdata()                    
GETSIGBYTE          MOV R1, SP              ; Check overflow
                    ADI R1, -8
                    CMP R1, SL
                    BLT R1, OVERFLOW
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)
                    JMP GETDATA             ; getdata()      
                    JMP MAINWHILE2          ; Skip else block
;   } else { // Default sign is '+'             
;     c[1] = c[0]            
DEFAULTSIGN         LDA R1, C
                    MOV R2, R1
                    ADI R2, 1
                    LDB R1, (R1)
                    STB R1, (R2)
;     c[0] = '+'                    
                    LDB R1, PLUS
                    STB R1, C
;     cnt++                    
                    LDR R1, CNT
                    ADI R1, 1
                    STR R1, CNT
;   }                    
;   while (data) {                    
MAINWHILE2          LDR R1, DATA            ; Does data == 0?
                    BRZ R1, ENDMAINWHILE2   ; Yes--break out of loop
;     if (c[cnt-1] == '\n') {
                    LDA R1, C               ; R1 <- &c
                    LDR R2, CNT             ; R2 <- cnt - 1
                    ADI R2, -1
                    ADD R1, R2              ; R1 <- c[cnt-1]
                    LDB R1, (R1)            
                    LDB R2, CRLF            ; Does c[cnt-1] == '\n'?
                    CMP R1, R2
                    BNZ R1, MAINGETNEXTBYTE ; No--next byte of data
;       data = 0                    
                    SUB R1, R1
                    STR R1, DATA
;       tenth = 1                    
                    ADI R1, 1               
                    STR R1, TENTH           
;       cnt = cnt - 2                    
                    LDR R1, CNT             
                    ADI R1, -2   
                    STR R1, CNT
;       while (!flag && cnt != 0) {
MAINWHILE3          LDR R1, FLAG
                    BNZ R1, ENDMAINWHILE3
                    LDR R1, CNT
                    BRZ R1, ENDMAINWHILE3                    
;         opd(c[0], tenth, c[cnt])                    
                    MOV R1, SP              ; Check overflow
                    ADI R1, -20
                    CMP R1, SL
                    BLT R1, OVERFLOW
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    LDB R1, C               ; Push c[0]
                    STB R1, (SP)
                    ADI SP, -4
                    LDR R1, TENTH           ; Push tenth
                    STR R1, (SP)
                    ADI SP, -4
                    LDA R1, C               ; Push c[cnt] 
                    LDR R2, CNT             ; R2 <- cnt
                    ADD R1, R2
                    LDB R1, (R1)                   
                    STB R1, (SP)
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)
                    JMP OPD                 ; opd(c[0], tenth, c[cnt])
;         cnt--           
                    LDR R1, CNT
                    ADI R1, -1
                    STR R1, CNT
;         tenth *= 10                    
                    LDR R1, TENTH           
                    SUB R2, R2
                    ADI R2, 10
                    MUL R1, R2
                    STR R1, TENTH
                    JMP MAINWHILE3                 
;       } // while (!flag && cnt != 0)
;       if (!flag)
;         printf("Operand is %d\n", opdv)
ENDMAINWHILE3       LDR R1, FLAG
                    BNZ R1, MAINWHILE2
                    LDA R1, OPERANDIS
                    LDR R2, OPERANDISSZ
PRNTOPERANDIS       LDB R0, (R1)
                    TRP 3
                    ADI R1, 1
                    ADI R2, -1
                    BNZ R2, PRNTOPERANDIS
                    LDR R0, OPDV
                    TRP 1
                    LDB R0, CRLF
                    TRP 3
                    JMP MAINWHILE2
;     } // if (c[cnt-1] == '\n')
;     else
;       getdata();
MAINGETNEXTBYTE     MOV R1, SP              ; Check overflow
                    ADI R1, -8
                    CMP R1, SL
                    BLT R1, OVERFLOW                    
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)
                    JMP GETDATA             ; getdata()
                    JMP MAINWHILE2
;   } // while(data)
;   reset(1, 0, 0, 0)
ENDMAINWHILE2       MOV R1, SP              ; Check overflow
                    ADI R1, -24
                    CMP R1, SL
                    BLT R1, OVERFLOW                    
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    SUB R1, R1              ; Push 1
                    ADI R1, 1
                    STR R1, (SP)
                    ADI SP, -4              
                    SUB R1, R1              ; Push 0
                    STR R1, (SP)
                    ADI SP, -4
                    STR R1, (SP)            ; Push 0
                    ADI SP, -4
                    STR R1, (SP)            ; Push 0
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)
                    JMP RESET               ; reset(1,0,0,0)
;   getdata()
                    MOV R1, SP              ; Check overflow
                    ADI R1, -8
                    CMP R1, SL
                    BLT R1, OVERFLOW                    
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36
                    STR R1, (FP)
                    JMP GETDATA             ; getdata()
                    JMP MAINWHILE
; } // while (c[0] != '@')
;}
ENDMAINWHILE        TRP 0                   ; End of main--halt                   

;----------------------------------                    
; opd(char s, int k, char j) {
;----------------------------------                                        
OPD                 MOV R1, SP              ; Check overflow
                    ADI R1, -4
                    CMP R1, SL
                    BLT R1, OVERFLOW
; int t = 0  // Local var
                    SUB R1, R1
                    STR R1, (SP)
                    MOV R9, SP              ; R9 <- save t's address
                    ADI SP, -4
; if (j == '0')                    
                    MOV R1, FP              ; R8 <- char j
                    ADI R1, -16
                    LDB R8, (R1)                          
                    LDB R1, ZERO
                    CMP R1, R8
                    BNZ R1, CHECKONE
;   t = 0                    
                    SUB R1, R1
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '1')                    
CHECKONE            LDB R1, ONE
                    CMP R1, R8
                    BNZ R1, CHECKTWO
;   t = 1                    
                    SUB R1, R1
                    ADI R1, 1
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '2')                    
CHECKTWO            LDB R1, TWO
                    CMP R1, R8
                    BNZ R1, CHECKTHREE
;   t = 2                    
                    SUB R1, R1
                    ADI R1, 2
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '3')                    
CHECKTHREE          LDB R1, THREE
                    CMP R1, R8
                    BNZ R1, CHECKFOUR
;   t = 3                    
                    SUB R1, R1
                    ADI R1, 3
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '4')                    
CHECKFOUR           LDB R1, FOUR     
                    CMP R1, R8
                    BNZ R1, CHECKFIVE
;   t = 4                    
                    SUB R1, R1       
                    ADI R1, 4
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '5')                    
CHECKFIVE           LDB R1, FIVE            
                    CMP R1, R8
                    BNZ R1, CHECKSIX
;   t = 5                    
                    SUB R1, R1              
                    ADI R1, 5
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '6')                    
CHECKSIX            LDB R1, SIX 
                    CMP R1, R8
                    BNZ R1, CHECKSEVEN
;   t = 6                    
                    SUB R1, R1  
                    ADI R1, 6
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '7')                    
CHECKSEVEN          LDB R1, SEVEN         
                    CMP R1, R8
                    BNZ R1, CHECKEIGHT
;   t = 7                    
                    SUB R1, R1            
                    ADI R1, 7
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '8')                    
CHECKEIGHT          LDB R1, EIGHT
                    CMP R1, R8
                    BNZ R1, CHECKNINE
;   t = 8                    
                    SUB R1, R1          
                    ADI R1, 8
                    STR R1, (R9)
                    JMP ENDCONVERT
; else if (j == '9')                    
CHECKNINE           LDB R1, NINE            
                    CMP R1, R8
                    BNZ R1, CONVERTELSE
;   t = 9                    
                    SUB R1, R1              
                    ADI R1, 9
                    STR R1, (R9)
                    JMP ENDCONVERT
; else {                    
;   printf("%c is not a number\n", j)
CONVERTELSE         MOV R0, R8              
                    TRP 3                   
                    LDA R1, NOTANUMBER
                    LDR R2, NOTANUMBERSZ
PRNTNOTANUMBER      LDB R0, (R1)            
                    TRP 3
                    ADI R1, 1
                    ADI R2, -1
                    BNZ R2, PRNTNOTANUMBER 
;   flag = 1                    
                    SUB R1, R1
                    ADI R1, 1
                    STR R1, FLAG
; }   
; if (!flag) {                
ENDCONVERT          LDR R1, FLAG
                    BNZ R1, ENDIFNOTFLAG
;   if (s == '+')                    
                    MOV R1, FP              
                    ADI R1, -8
                    LDB R1, (R1)
                    LDB R2, PLUS
                    CMP R1, R2
                    BNZ R1, SNOTPLUS
;     t *= k                    
                    MOV R1, FP              ; R1 <- k 
                    ADI R1, -12
                    LDR R1, (R1)                             
                    LDR R2, (R9)            ; R2 <- t
                    MUL R1, R2              ; t *= k
                    STR R1, (R9)            
                    JMP INCOPDV             ; Skip else block
;   else
;     t *= -k                    
SNOTPLUS            MOV R1, FP              ; R1 <- k
                    ADI R1, -12
                    LDR R1, (R1)            
                    SUB R2, R2              ; R2 <- -k
                    SUB R2, R1
                    LDR R1, (R9)            ; R1 <- t                                
                    MUL R1, R2              ; t *= -k
                    STR R1, (R9)
;   opdv += t                     
INCOPDV             LDR R1, OPDV            ; R1 <- opdv
                    LDR R2, (R9)            ; R2 <- t
                    ADD R1, R2              ; opdv += t
                    STR R1, OPDV
; } // if (!flag)                    
ENDIFNOTFLAG        MOV SP, FP              ; SP = FP
                    MOV R1, SP              ; Check underflow
                    CMP R1, SB
                    BGT R1, UNDERFLOW                    
                    LDR R1, (FP)            ; R1 <- return address
                    MOV R2, FP              ; FP = PFP
                    ADI R2, -4
                    LDR FP, (R2)
                    JMR R1                  ; Return
;}                
                    
;----------------------------------                    
; void flush() {
;----------------------------------
; data = 0
FLUSH               SUB R1, R1              
                    STR R1, DATA
; c[0] = getchar()
; while (c[0] != '\n') {              
;   c[0] = getchar()     
FLUSHWHILE          TRP 4                   ; R0 <- getchar()  
                    LDB R1, CRLF            ; Does R0 == '\n'?
                    CMP R1, R0
                    BNZ R1, FLUSHWHILE      ; No--get another character
                    STB R0, C               ; c[0] = R0
; }                                        
                    MOV SP, FP              ; SP = FP
                    MOV R1, SP              ; Check underflow
                    CMP R1, SB
                    BGT R1, UNDERFLOW                    
                    LDR R1, (FP)            ; R1 <- return address
                    MOV R2, FP              ; FP = PFP
                    ADI R2, -4
                    LDR FP, (R2)
                    JMR R1                  ; Return
;}                 

;----------------------------------
; void getdata() {
;----------------------------------
; if (cnt < SIZE) {
GETDATA             LDR R1, CNT             ; R1 <- cnt
                    LDR R2, SIZE            ; R2 <- SIZE
                    CMP R2, R1              ; is cnt < SIZE?
                    BLT R2, GETDATAELSE     ; No--number too big
                    BRZ R2, GETDATAELSE
;   c[cnt] = getchar()                    
                    TRP 4                   ; R0 <- getchar()
                    LDA R2, C               ; R2 <- &c + cnt
                    ADD R2, R1
                    STB R0, (R2)            ; c[cnt] = getchar()
;   cnt++                    
                    ADI R1, 1
                    STR R1, CNT
                    JMP GETDATAENDIF        ; Skip else block
; else {
;   printf("Number too Big\n")                    
GETDATAELSE         LDA R1, NUMTOOBIG
                    LDR R2, NUMTOOBIGSZ
PRINTTOOBIG         LDB R0, (R1)
                    TRP 3
                    ADI R1, 1
                    ADI R2, -1
                    BNZ R2, PRINTTOOBIG
;   flush()
                    MOV R1, SP              ; Check overflow
                    ADI R1, -8
                    CMP R1, SL
                    BLT R1, OVERFLOW                    
                    MOV R1, FP              ; R1 <- PFP
                    MOV FP, SP              ; FP = SP
                    ADI SP, -4              
                    STR R1, (SP)            ; Push PFP
                    ADI SP, -4
                    MOV R1, PC              ; Store return address
                    ADI R1, 36              
                    STR R1, (FP)            
                    JMP FLUSH               ; flush()
; }                     
GETDATAENDIF        MOV SP, FP              ; SP = FP
                    MOV R1, SP              ; Check underflow
                    CMP R1, SB
                    BGT R1, UNDERFLOW                    
                    LDR R1, (FP)            ; R1 <- return address
                    MOV R2, FP              ; FP = PFP
                    ADI R2, -4
                    LDR FP, (R2)
                    JMR R1                  ; Return
;}

;----------------------------------
; void reset(int w, int x, int y, int z) {
;----------------------------------
RESET               MOV R1, SP              ; Check overflow for local vars
                    ADI R1, -4
                    CMP R1, SL
                    BLT R1, OVERFLOW
; int k = 0                    
                    SUB R1, R1              ; R1 <- k = 0
                    STR R1, (SP)            ; Push k
                    ADI SP, -4
; for (k = 0; k < SIZE; k++)                    
RESETFOR            LDR R2, SIZE
                    CMP R2, R1              ; Is k < SIZE?
                    BLT R2, RESETFOREND     ; No--end loop
                    BRZ R2, RESETFOREND
;   c[k] = 0                    
                    LDA R2, C               ; R2 <- &c + k
                    ADD R2, R1              
                    SUB R3, R3              ; c[k] = 0
                    STB R3, (R2)                 
                    ADI R1, 1               ; k++            
                    JMP RESETFOR
; data = w                    
RESETFOREND         MOV R1, FP
                    ADI R1, -8
                    LDR R2, (R1)
                    STR R2, DATA
; opdv = x                    
                    ADI R1, -4
                    LDR R2, (R1)
                    STR R2, OPDV
; cnt = y                    
                    ADI R1, -4              
                    LDR R2, (R1)
                    STR R2, CNT
; flag = z                    
                    ADI R1, -4
                    LDR R2, (R1)
                    STR R2, FLAG
                    
                    MOV SP, FP              ; SP = FP
                    MOV R1, SP              ; Check underflow
                    CMP R1, SB
                    BGT R1, UNDERFLOW                    
                    LDR R1, (FP)            ; R1 <- return address
                    MOV R2, FP              ; FP = PFP
                    ADI R2, -4
                    LDR FP, (R2)
                    JMR R1                  ; Return
;}

OVERFLOW            LDA R1, STROVERFLOW
                    LDR R2, STROVERFLOWSZ
PRNTOVERFLOW        LDB R0, (R1)
                    TRP 3
                    ADI R1, 1
                    ADI R2, -1
                    BNZ R2, PRNTOVERFLOW
                    TRP 0
                    
UNDERFLOW           LDA R1, STRUNDERFLOW
                    LDR R2, STRUNDERFLOWSZ
PRNTUNDERFLOW       LDB R0, (R1)
                    TRP 3
                    ADI R1, 1
                    ADI R2, -1
                    BNZ R2, PRNTUNDERFLOW
                    TRP 0