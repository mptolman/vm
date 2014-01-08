A1      .INT 1
A2      .INT 2
A3      .INT 3
A4      .INT 4
A5      .INT 5
A6      .INT 6
B1      .INT 300
B2      .INT 150
B3      .INT 50
B4      .INT 20
B5      .INT 10
B6      .INT 5
C1      .INT 500
C2      .INT 2
C3      .INT 5
C4      .INT 10
SUM     .INT 0
PRODUCT .INT 0
M       .BYT 'M'
a       .BYT 'a'
t       .BYT 't'
h       .BYT 'h'
e       .BYT 'e'
w       .BYT 'w'
T       .BYT 'T'
o       .BYT 'o'
l       .BYT 'l'
m       .BYT 'm'
n       .BYT 'n'
SPACE   .BYT ' '
COMMA   .BYT ','
CRLF    .BYT '\n'


;------------------------------
; Print my name (Last, First)
;------------------------------
BEGIN   LDB R0, T
        TRP 3
        LDB R0, o
        TRP 3
        LDB R0, l
        TRP 3
        LDB R0, m
        TRP 3
        LDB R0, a
        TRP 3
        LDB R0, n
        TRP 3
        LDB R0, COMMA
        TRP 3
        LDB R0, SPACE
        TRP 3
        LDB R0, M
        TRP 3
        LDB R0, a
        TRP 3
        LDB R0, t
        TRP 3
        TRP 3
        LDB R0, h
        TRP 3
        LDB R0, e
        TRP 3
        LDB R0, w
        TRP 3
        LDB R0, CRLF
        TRP 3
        TRP 3

;------------------------------
; Add up all elements of B
; Store result in SUM
;------------------------------
        LDR R0, B1      ; R0 <- B1
        LDR R1, B2      ; R1 <- B2
        ADD R0, R1      ; R0 <- R0 + R1 (B1+B2)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, B3      ; R1 <- B3
        ADD R0, R1      ; R0 <- R0 + R1 (B1+B2+B3)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, B4      ; R1 <- B4
        ADD R0, R1      ; R0 <- R0 + R1 (B1+B2+B3+B4)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, B5      ; R1 <- B5
        ADD R0, R1      ; R0 <- R0 + R1 (B1+B2+B3+B4+B5)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, B6      ; R1 <- B6
        ADD R0, R1      ; R0 <- R0 + R1 (B1+B2+B3+B4+B5+B6)
        TRP 1           ; Print result
        STR R0, SUM     ; Store result in SUM
        LDB R0, CRLF    ; Print blank line
        TRP 3
        TRP 3

;------------------------------
; Multiply elements of A
; Store result in PRODUCT
;------------------------------
        LDR R0, A1      ; R0 <- A1
        LDR R1, A2      ; R1 <- A2
        MUL R0, R1      ; R0 <- R0 * R1 (A1*A2)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, A3      ; R1 <- A3
        MUL R0, R1      ; R0 <- R0 * R1 (A1*A2*A3)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, A4      ; R1 <- A4
        MUL R0, R1      ; R0 <- R0 * R1 (A1*A2*A3*A4)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, A5      ; R1 <- A5
        MUL R0, R1      ; R0 <- R0 * R1 (A1*A2*A3*A4*A5)
        TRP 1           ; Print result
        MOV R1, R0      ; Save R0
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R1      ; Restore R0
        LDR R1, A6      ; R1 <- A6
        MUL R0, R1      ; R0 <- R0 * R1 (A1*A2*A3*A4*A5*A6)
        TRP 1           ; Print result
        STR R0, PRODUCT ; Store result in PRODUCT
        LDB R0, CRLF    ; Print blank line
        TRP 3
        TRP 3

;----------------------------------
; Divide SUM by each element in B
;----------------------------------
        LDR R2, SUM     ; R2 <- SUM
        MOV R0, R2      ; R0 <- R2
        LDR R1, B1      ; R1 <- B1
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B1)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (SUM)
        LDR R1, B2      ; R1 <- B2
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B2)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (SUM)
        LDR R1, B3      ; R1 <- B3
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B3)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (SUM)
        LDR R1, B4      ; R1 <- B4
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B4)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (SUM)
        LDR R1, B5      ; R1 <- B5
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B5)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (SUM)
        LDR R1, B6      ; R1 <- B6
        DIV R0, R1      ; R0 <- R0 / R1 (SUM / B6)
        TRP 1           ; Print result
        LDB R0, CRLF    ; Print blank line
        TRP 3
        TRP 3

;-----------------------------------------
; Subtract each element in C from PRODUCT
;-----------------------------------------
        LDR R2, PRODUCT ; R2 <- PRODUCT
        MOV R0, R2      ; R0 <- R2
        LDR R1, C1      ; R1 <- C1
        SUB R0, R1      ; R0 <- R0 - R1 (PRODUCT - C1)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (PRODUCT)
        LDR R1, C2      ; R1 <- C2
        SUB R0, R1      ; R0 <- R0 - R1 (PRODUCT - C2)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (PRODUCT)
        LDR R1, C3      ; R1 <- C3
        SUB R0, R1      ; R0 <- R0 - R1 (PRODUCT - C3)
        TRP 1           ; Print result
        LDB R0, SPACE   ; Print two spaces
        TRP 3
        TRP 3
        MOV R0, R2      ; R0 <- R2 (PRODUCT)
        LDR R1, C4      ; R1 <- C4
        SUB R0, R1      ; R0 <- R0 - R1 (PRODUCT - C4)
        TRP 1           ; Print result

HALT    TRP 0           ; Halt