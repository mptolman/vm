ARRAY           .INT 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ARRAY_SIZE      .INT 30
CNT             .INT 0
ARRAY_LCK       .INT -1

THREAD_COUNT    .INT 5

PLS_ENTER       .BYT 'Please enter 5 numbers (one per line)\n'
PLS_ENTER_SZ    .INT 38

PROMPT          .BYT 'Enter a number: '
PROMPT_SZ       .INT 16

FACTORIALOF     .BYT 'Factorial of '
FACTORIALOF_SZ  .INT 13

IS              .BYT ' is '
IS_SZ           .INT 4

COMMA           .BYT ','
CRLF            .BYT '\n'

STROVERFLOW     .BYT 'Stack overflow has occurred! Terminating application.\n'
STROVERFLOW_SZ  .INT 54
STRUNDERFLOW    .BYT 'Stack underflow has occurred! Terminating application.\n'
STRUNDERFLOW_SZ .INT 55

                MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP FACT_TEST
                
                MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP THREAD_TEST
                
                TRP 0

                
                
FACT_TEST       MOV R1, SP
                ADI R1, -4
                CMP R1, SL
                BLT R1, OVERFLOW
                SUB R1, R1
                STR R1, (SP)
                ADI SP, -4
                
FACT_LOOP       LDR R1, CNT
                LDR R2, ARRAY_SIZE
                CMP R1, R2
                BRZ R1, DO_PRNTARRAY
                BGT R1, DO_PRNTARRAY
                
                LDA R1, PROMPT
                LDR R2, PROMPT_SZ
PRNTPROMPT      LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNTPROMPT  
                
                TRP 2                   ; Get input
                BRZ R0, DO_PRNTARRAY    ; Stop when zero is entered                
                
                MOV R1, FP              ; Store input on stack
                ADI R1, -8
                STR R0, (R1)
                
                MOV R1, SP              ; Check overflow
                ADI R1, -12
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP              ; R1 <- PFP
                MOV FP, SP              ; FP = SP
                ADI SP, -4
                STR R1, (SP)            ; Push PFP
                ADI SP, -4
                STR R0, (SP)            ; Push parameter
                ADI SP, -4
                MOV R1, PC              ; Store return address
                ADI R1, 36
                STR R1, (FP)
                JMP FACTORIAL           ; factorial(n)
                
                MOV R1, FP
                ADI R1, -8
                LDR R1, (R1)            ; R1 <- input
                LDR R2, (SP)            ; R2 <- result
                
                LDA R3, FACTORIALOF
                LDR R4, FACTORIALOF_SZ
PRNTFACTOF      LDB R0, (R3)
                TRP 3
                ADI R3, 1
                ADI R4, -1
                BNZ R4, PRNTFACTOF
                
                MOV R0, R1
                TRP 1
                
                LDA R3, IS
                LDR R4, IS_SZ
PRNTIS          LDB R0, (R3)
                TRP 3
                ADI R3, 1
                ADI R4, -1
                BNZ R4, PRNTIS
                
                MOV R0, R2
                TRP 1
                LDB R0, CRLF
                TRP 3
                
                LDA R3, ARRAY           ; array[count] = input
                LDR R4, CNT             ; array[count+1] = result
                SUB R5, R5
                ADI R5, 4
                MUL R5, R4
                ADD R3, R5
                STR R1, (R3)
                ADI R3, 4
                STR R2, (R3)
                
                ADI R4, 2               ; count += 2
                STR R4, CNT
                JMP FACT_LOOP
                
DO_PRNTARRAY    MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP PRNTARRAY
                
                MOV SP, FP
                MOV R1, SP
                CMP R1, SB
                BGT R1, UNDERFLOW
                LDR R1, (FP)
                MOV R2, FP
                ADI R2, -4
                LDR FP, (R2)
                JMR R1             

                
                
THREAD_TEST     MOV R1, SP
                ADI R1, -4
                CMP R1, SL
                BLT R1, OVERFLOW
                SUB R1, R1
                STR R1, (SP)
                ADI SP, -4
                
                SUB R1, R1
                STR R1, CNT

                LDA R1, PLS_ENTER
                LDR R2, PLS_ENTER_SZ
PRNT_PLS_ENTER  LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNT_PLS_ENTER
                
                LDR R5, THREAD_COUNT
                SUB R6, R6
PROMPT_WHL      MOV R7, R6
                CMP R7, R5
                BRZ R7, START_THREADS
                BGT R7, START_THREADS
                ADI R6, 1
                
                LDA R1, PROMPT
                LDR R2, PROMPT_SZ
PRNT_PROMPT     LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNT_PROMPT                
                TRP 2
                
                LDA R1, ARRAY
                SUB R2, R2
                ADI R2, 4
                MUL R2, R6
                ADD R1, R2
                STR R0, (R1)
                JMP PROMPT_WHL
                
START_THREADS   LDR R5, THREAD_COUNT
START_LOOP      BRZ R5, JOIN_THREADS
                RUN R9, THREAD_START
                ADI R5, -1
                JMP START_LOOP
                
JOIN_THREADS    BLK

                MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP PRNTARRAY
                
                MOV SP, FP
                MOV R1, SP
                CMP R1, SB
                BGT R1, UNDERFLOW
                LDR R1, (FP)
                MOV R2, FP
                ADI R2, -4
                LDR FP, (R2)
                JMR R1
                                
THREAD_START    MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP THREAD_FACT
                END

THREAD_FACT     MOV R1, SP
                ADI R1, -4
                CMP R1, SL
                BLT R1, OVERFLOW
                LDA R1, ARRAY
                SUB R2, R2
                ADI R2, 4
                MUL R2, R9
                ADD R1, R2
                LDR R3, (R1)
                STR R3, (SP)
                ADI SP, -4
                
                MOV R1, SP
                ADI R1, -12
                CMP R1, SL
                BLT R1, OVERFLOW
                MOV R1, FP
                MOV FP, SP
                ADI SP, -4
                STR R1, (SP)
                ADI SP, -4
                STR R3, (SP)
                ADI SP, -4
                MOV R1, PC
                ADI R1, 36
                STR R1, (FP)
                JMP FACTORIAL
                
                MOV R1, FP
                ADI R1, -8
                LDR R4, (R1)
                LDR R5, (SP)
                
                LCK ARRAY_LCK
                LDA R1, ARRAY
                LDR R2, CNT
                SUB R3, R3
                ADI R3, 4
                MUL R3, R2
                ADD R1, R3
                STR R4, (R1)
                ADI R1, 4
                STR R5, (R1)                
                ADI R2, 2
                STR R2, CNT
                ULK ARRAY_LCK
                
                LDA R1, FACTORIALOF
                LDR R2, FACTORIALOF_SZ
PRNT_FACTOF     LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNT_FACTOF
                
                MOV R0, R4
                TRP 1
                
                LDA R1, IS
                LDR R2, IS_SZ
PRNT_IS         LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNT_IS
                
                MOV R0, R5
                TRP 1        
                LDB R0, CRLF
                TRP 3
                
                MOV SP, FP
                MOV R1, SP
                CMP R1, SB
                BGT R1, UNDERFLOW
                LDR R1, (FP)
                MOV R2, FP
                ADI R2, -4
                LDR FP, (R2)
                JMR R1

                

FACTORIAL       MOV R1, FP              ; R1 <- n
                ADI R1, -8
                LDR R1, (R1)
                
                BNZ R1, FACTRECURSE
                ADI R1, 1
                MOV R9, R1
                JMP FACTRETURN
                
FACTRECURSE     MOV R2, SP              ; Test overflow
                ADI R2, -12
                CMP R2, SL
                BLT R2, OVERFLOW
                MOV R2, FP              ; R2 <- PFP
                MOV FP, SP              ; FP = SP
                ADI SP, -4
                STR R2, (SP)
                ADI SP, -4
                MOV R2, R1
                ADI R2, -1
                STR R2, (SP)
                ADI SP, -4
                MOV R2, PC
                ADI R2, 36
                STR R2, (FP)
                JMP FACTORIAL
                
                LDR R9, (SP)            ; R9 <- n * fact(n-1)
                MOV R1, FP
                ADI R1, -8
                LDR R1, (R1)                
                MUL R9, R1     
                
FACTRETURN      MOV SP, FP              ; SP = FP
                MOV R1, SP              ; Test underflow
                CMP R1, SB
                BGT R1, UNDERFLOW
                LDR R1, (FP)            ; R1 <- return address
                MOV R2, FP              ; FP = PFP
                ADI R2, -4
                LDR FP, (R2)  
                STR R9, (SP)            ; Store return value
                JMR R1
                
                
                
PRNTARRAY       MOV R1, SP
                ADI R1, -8
                CMP R1, SL
                BLT R1, OVERFLOW
                SUB R1, R1
                STR R1, (SP)
                ADI SP, -4
                LDR R2, CNT
                ADI R2, -1
                STR R2, (SP)
                ADI SP, -4                
                
PRNTARRAY_WHL   MOV R1, FP
                ADI R1, -8
                LDR R1, (R1)
                MOV R2, FP
                ADI R2, -12
                LDR R2, (R2)                
                MOV R3, R1
                CMP R3, R2
                BRZ R3, PRNTARRAY_RTN
                BGT R3, PRNTARRAY_RTN
                BRZ R1, SKIPCOMMA
                LDB R0, COMMA
                TRP 3
                
SKIPCOMMA       LDA R3, ARRAY
                SUB R4, R4
                ADI R4, 4
                MUL R4, R1
                ADD R4, R3
                LDR R0, (R4)
                TRP 1                
                LDB R0, COMMA
                TRP 3
                
                SUB R4, R4
                ADI R4, 4
                MUL R4, R2
                ADD R4, R3
                LDR R0, (R4)
                TRP 1

                ADI R1, 1               ; ++front
                MOV R3, FP
                ADI R3, -8
                STR R1, (R3)
                ADI R2, -1              ; --back
                ADI R3, -4
                STR R2, (R3)
                JMP PRNTARRAY_WHL
                
PRNTARRAY_RTN   LDB R0, CRLF
                TRP 3
                MOV SP, FP
                MOV R1, SP
                CMP R1, SB
                BGT R1, UNDERFLOW
                LDR R1, (FP)
                MOV R2, FP
                ADI R2, -4
                LDR FP, (R2)
                JMR R1



OVERFLOW        LDA R1, STROVERFLOW
                LDR R2, STROVERFLOW_SZ
PRNTOVERFLOW    LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNTOVERFLOW
                TRP 0

UNDERFLOW       LDA R1, STRUNDERFLOW
                LDR R2, STRUNDERFLOW_SZ
PRNTUNDERFLOW   LDB R0, (R1)
                TRP 3
                ADI R1, 1
                ADI R2, -1
                BNZ R2, PRNTUNDERFLOW
                TRP 0 