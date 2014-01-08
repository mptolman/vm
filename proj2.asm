SIZE        .INT 10
ARR         .INT 10, 2, 3, 4, 15, -6, 7, 8, 9, 10
I           .INT 0
SUM         .INT 0
TEMP        .INT 0
DAGS        .BYT 'DAGS'
SUM_IS      .BYT 'Sum is '
IS_ODD      .BYT ' is odd\n'
IS_EVEN     .BYT ' is even\n'
CRLF        .BYT '\n'
SPACE       .BYT ' '

; while (i < SIZE) {
WHILE       LDR R4, I           ; R4 <- I
            LDR R3, SIZE        ; R3 <- SIZE
            CMP R3, R4          ; Is I < SIZE?
            BLT R3, ENDWHILE    ; No--break out of loop
            BRZ R3, ENDWHILE
; sum += arr[i]
            SUB R3, R3          ; R3 <- array offset (I * 4)
            ADI R3, 4
            MUL R3, R4
            LDA R2, ARR         ; R2 <- ARR + offset
            ADD R2, R3
            LDR R3, (R2)        ; R3 <- ARR[offset]
            MOV R0, R3          ; Print ARR[offset]
            TRP 1
            LDR R2, SUM         ; R2 <- SUM + ARR[offset]
            ADD R2, R3
            STR R2, SUM         ; Store updated SUM in memory
; Determine if arr[i] is even or odd            
            SUB R2, R2          ; R2 <- #2
            ADI R2, 2
            MOV R1, R3          ; R1 <- ARR[offset] / 2
            DIV R1, R2
            MUL R1, R2          ; Multiply quotient by divisor
            CMP R1, R3          ; Does product equal original number?
            BNZ R1, ELSE        ; No--the number is odd
; arr[i] is even
            LDA R1, IS_EVEN     ; Print " is even"
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            JMP ENDIF
; arr[i] is odd
ELSE        LDA R1, IS_ODD      ; Print " is odd"
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
            ADI R1, 1
            LDB R0, (R1)
            TRP 3
ENDIF       ADI R4, 1           ; i++
            STR R4, I
            JMP WHILE           ; Return to top of loop

; printf("Sum is %d\n", sum)       
ENDWHILE    LDA R1, SUM_IS
            LDB R0, (R1)        
            TRP 3
            ADI R1, 1          
            LDB R0, (R1)
            TRP 3
            ADI R1, 1          
            LDB R0, (R1)
            TRP 3
            ADI R1, 1         
            LDB R0, (R1)
            TRP 3
            ADI R1, 1         
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           
            LDB R0, (R1)
            TRP 3
            ADI R1, 1 
            LDB R0, (R1)
            TRP 3
            LDR R0, SUM
            TRP 1
            LDB R0, CRLF
            TRP 3

;-------------------------------
; DAGS/GADS section
;------------------------------- 
            LDA R1, DAGS        ; Print DAGS[0]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[1]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[2]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[3]
            LDB R0, (R1)
            TRP 3
            LDB R0, SPACE
            TRP 3
            LDR R0, DAGS        ; Print integer representation of DAGS
            TRP 1
            STR R0, TEMP        ; Save integer value in memory for later
            LDB R0, CRLF        ; Print CRLF
            TRP 3
            
            LDA R1, DAGS        ; R1 <- DAGS + 2
            ADI R1, 2
            LDB R2, DAGS        ; R2 <- DAGS[0]
            LDB R3, (R1)        ; R3 <- DAGS[2]
            STB R2, (R1)        ; Store "D" in DAGS[2]
            STB R3, DAGS        ; Store "G" in DAGS[0]
            
            LDA R1, DAGS        ; Print DAGS[0]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[1]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[2]
            LDB R0, (R1)
            TRP 3
            ADI R1, 1           ; Print DAGS[3]
            LDB R0, (R1)
            TRP 3
            LDB R0, SPACE
            TRP 3
            LDR R0, DAGS        ; Print integer representation of DAGS
            TRP 1
            MOV R1, R0          ; Print CRLF
            LDB R0, CRLF
            TRP 3
            MOV R0, R1
            LDR R1, TEMP        ; Print integer value of "GADS" - "DAGS"
            SUB R0, R1
            TRP 1

            TRP 0