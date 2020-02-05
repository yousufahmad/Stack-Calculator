;
;This program is a stack based calculator which uses a variety of subroutines to execute expressions  
;in post-fix notation. This calculator is capcable of addition, subtraction, multiplication, division,
;and exponential functions. The program echoes the users' inputs and pushes and pops values from a 
;stack to complete each individual operation. The final answer is stored in R5, after all the 
;computations are completed.
;
;Register Table
;R0- contains the running total of the computations, and sends it to R5 at the end.
;R1-used primarily to decide which operation to complete, and contains negated values of operators.
;R2-used in the print hex segment as a counter, also to check for negatives multiplication
;R3-contains one of the input values after being popped from the stack
;R4-contains the other input value after being popped from the stack
;R5-used to check for underflow, and contains the final answer at the end of the computations.
;R6-used as a temporary register to save R0
;R7-contains the PC value, is saved and restored while calling JSR subroutines.
;
;partners: at18, lofendo2

.ORIG x3000

GETCHAR
    GETC        ; prompt user for input and echo to screen
    OUT        ; print
    JSR EVALUATE    ; jump to evaluate subroutine
    BR GETCHAR    ; always branch to get the next char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R3- value to print in hexadecimal
PRINT_HEX
;CONVERTS BINARY(R3) to HEX (R0)
	AND R5, R5, #0        ;clear R5
    ADD R5, R5, R0        ;put final answer into R5
    AND R3, R3, #0        ;clear R3
    ADD R3, R3, R0        ;puts the answer to be printed in R3
    AND R0, R0, #0        ;clear R0
    AND R1, R1, #0        ;clear big counter
    ADD R1, R1, #15        ;big counter = 15
    AND R2, R2, #0        ;clear small counter
   
NEXTCHAR
    ADD R2, R2, #4        ;small counter = 4
FOURBITS
    ADD R0, R0, R0        ;left shift R0
    ADD R3, R3, #0        ;Need to branch on R3
    BRn ADDONE
    BRzp ADDZERO

ADDONE   
    ADD R0, R0, #1        ;get MSB of R3 to LSB of R0
    ADD R3, R3, R3        ;left shift R3
    ADD R2, R2, #-1        ;small counter
    BRp FOURBITS
    BRnz CHECK

ADDZERO
    ADD R0, R0, #0        ;Add zero (useless but for understanding)
    ADD R3, R3, R3        ;left shift R3
    ADD R2, R2, #-1        ;small counter
    BRp FOURBITS
    BRnz CHECK

CHECK
    ADD R0, R0, #-10    ;Need to branch on R0
    BRn NUMBER
    BRzp LETTER
   
NUMBER   
    ADD R0, R0, #15        ;get to ASCII numbers
    ADD R0, R0, #15        ;get to ASCII numbers
    ADD R0, R0, #15     ;get to ASCII numbers
    ADD R0, R0, #10
    ADD R0, R0, #3        ;get to ASCII numbers
    BR PRINT

LETTER
    ADD R0, R0, #15        ;get to ASCII letters
    ADD R0, R0, #15        ;get to ASCII letters
    ADD R0, R0, #15        ;get to ASCII letters
    ADD R0, R0, #10        ;get to ASCII letters
    ADD R0, R0, #10        ;get to ASCII letters
    BR PRINT

PRINT
    OUT
    AND R0, R0, #0
    ADD R1, R1, #-4
    BRzp NEXTCHAR
    HALT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
EVALUATE
    ST R7, SAVER7_1  ; save R7
SPACECHECK   
    LD R1, NEG_SPACE ; load the opposite ASCII of ' '           
    ADD R1, R0, R1   ; subtract ' ' from R0
    BRnp MULTCHECK     ; branch to MULTCHECK if not ' ' char
    RET

MULTCHECK
    LD R1, NEG_MULT  ;load the opposite ASCII of '*'
    ADD R1, R0, R1   ; subtract '*' from R0
    BRnp DIVCHECK    ; branch to DIVCHECK if not '*' char
    JSR MULT     ; jump to MULT subroutine because we've seen a '*'
    LD R7, SAVER7_1  ; restore R7
    RET

DIVCHECK
    LD R1, NEG_DIV     ; load the opposite ASCII of '/'
    ADD R1, R0, R1   ; subtract '/' from R0
    BRnp ADDCHECK    ; branch to ADDCHECK if not '/' char
    JSR DIV         ; jump to DIV subroutine because we've seen a '/'
    LD R7, SAVER7_1  ; restore R7
    RET

ADDCHECK
    LD R1, NEG_ADD   ; load opposite ACII of '+'
    ADD R1, R0, R1   ; subtract '+' from R0
    BRnp MINUSCHECK     ; branch to MINUSCHECK if not '+' char
    JSR PLUS     ; jump to PLUS subroutine because we've seen a '+'
    LD R7, SAVER7_1  ; restore R7
    RET

MINUSCHECK
    LD R1, NEG_SUBTR ; load opposite ASCII of '-'
    ADD R1, R0, R1   ; subtract '-' from R0
    BRnp EXPCHECK    ; branch to EXPCHECK if not '-' char
    JSR MIN          ; jump to MIN subroutine because we've seen a '-'
    LD R7, SAVER7_1  ; restore R7
    RET

EXPCHECK
    LD R1, NEG_EXP   ; load opposite ASCII of '^'
    ADD R1, R0, R1   ; subtract '^' from R0
    BRnp NUMCHECK    ; branch to NUMCHECK if not '^' char
    JSR EXP          ; jump to EXP subroutine because we've seen a '^'
    LD R7, SAVER7_1  ; restore R7
    RET

NUMCHECK
    LD R1, NEG_ZERO  ; load opposite ASCII of '0'
    ADD R1, R0, R1   ; subtract '0' from R0
    BRn INVAL     ; branch to INVAL if char not in range
    LD R1, NEG_NINE  ; load opposite ASCII of '9'
    ADD R1, R0, R1   ; subtract '9' from R0
    BRp EQCHECK     ; if positive then branch to EQCHECK
    LD R1, NEG_ZERO  ; load opposite ASCII of '0'
    ADD R0, R1, R0   ; add it to what's in R0
    JSR PUSH     ; push operand
    LD R7, SAVER7_1  ; restore
    RET

EQCHECK
    LD R1, NEG_EQUAL ; load opposite ASCII of '='
    ADD R1, R0, R1   ; subtract '=' from R0
    BRnp INVAL     ; if not equal, char must be invalid at this point
    
    JSR EQUAL     ; jump to equal subroutine
    LD R7, SAVER7_1     ; restore
    RET

; seen equal
EQUAL
    ST R7, SAVER_7
    JSR POP         ; first pop to check stack
    LD R7, SAVER_7
    AND R6, R6, #0     ; clear R6
    ADD R6, R0, R6   ; add R0 into R6
; need to pop once more to check if there is another number in stack
    ST R7, SAVER_7
    JSR POP         ; second pop
    LD R7, SAVER_7
    ADD R5, R5, #0     ; set CC for R5
    BRp PRINT_HEX     ; if positive, go to print the value in hex
    JSR INVAL     ; a number or operator must be left in stack, so jump to INVAL
    RET

   

;seen invalid character
INVAL
    LEA R0, INVALIDSTRING ; load the address of string
    PUTS              ; print invalid string
    BR DONE              ; done with program
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NEG_MULT    .FILL xFFD6    ;
RELOAD		.BLKW #1
NEG_SPACE    .FILL xFFE0	;
POP_SaveR3      .BLKW #1    ;
POP_SaveR4      .BLKW #1    ;
SAVER7_1    .BLKW #1        ;
SAVER_7		.BLKW #1	;
SAVER_4		.BLKW #1	;
STACK_END       .FILL x3FF0    ;
STACK_START     .FILL x4000    ;
STACK_TOP       .FILL x4000    ;
NEG_ADD        .FILL xFFD5    ;   
NEG_SUBTR    .FILL xFFD3    ;

NEG_DIV        .FILL xFFD1    ;
NEG_EXP        .FILL xFFA2    ;
NEG_EQUAL    .FILL xFFC3    ;
NEG_ZERO    .FILL xFFD0     ;
NEG_NINE    .FILL xFFC7    ;
INVALIDSTRING   .STRINGZ "Invalid Expression" ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;input R3, R4    (R3+R4)
;out R0

PLUS  
    	AND R0, R0, #0		;clear R0
	AND R3, R3, #0		; clear R3
	AND R4, R4, #0		; clear R4
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		; restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R3, R3, R0		; load popped number into R3
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		; restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R4, R4, R0		; load second popped number into R4

	ADD R0, R3, R4		;adding contents of R3 and R4
	ST R7, SAVER_7		; save
	JSR PUSH
	LD R7, SAVER_7		; restore
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4    (R3-R4)
;out R0
MIN  
    	AND R0, R0, #0		;clear R0
	AND R3, R3, #0		; clear R3
	AND R4, R4, #0		; clear R4
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		; restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R3, R3, R0		; load popped number into R3
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		; restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R4, R4, R0		; load second popped number into R4

	NOT R3, R3		; negating
	ADD R3, R3, #1		; negating
	ADD R0, R3, R4		; actual subtraction operation
	ST R7, SAVER_7		; save
	JSR PUSH
	LD R7, SAVER_7		; restore
	RET
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4 (R3*R4)
;out R0 (R0=product)
MULT
	AND R0, R0, #0		;clear R0
	AND R3, R3, #0		; clear R3
	AND R4, R4, #0		; clear R4
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		;restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R4, R4, R0		; load popped number into R4
	ST R7, SAVER_7		; save
	JSR POP
	LD R7, SAVER_7		; restore
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R3, R3, R0		; load second popped number into R3

	AND R2, R2, #0		; clear R2
	AND R6, R6, #0		; clear R6

	ADD R3, R3, #0		; setcc
	BRzp CHECK4		; branches if 0 or positive
	ADD R2, R2, #-1		; if R3 is negative, R2 is changed to -1
	NOT R3, R3
	ADD R3, R3, #1		; negating
	ADD R4, R4, #0		; setcc
	BRzp MULTLOOP		; goes to loop if positive or 0
	ADD R6, R6, #-1		; if R4 is negative, R6 is changed to -1
	NOT R4, R4
	ADD R4, R4, #1		; negation
	BRnzp MULTLOOP		; unconditional branch
CHECK4
	ADD R4, R4, #0		; setcc
	BRzp MULTLOOP		; branches if 0 or positive
	ADD R6, R6, #-1		; if R4 is negative, R6 is changed to -1
	NOT R4, R4
	ADD R4, R4, #1		; negation
	
	
MULTLOOP
	ADD R3, R3, #0		; setcc
	BRz ZERO		; checks if 0
	ADD R4, R4, #0		; setcc
	BRz ZERO		; checks if 0
	ADD R0, R0, R3		;loops adds the first number, b times 	
	ADD R4, R4, #-1		; decrements for branch
	BRz ONE			
REPEAT
	ADD R0, R3, R0	
	ADD R4, R4, #-1		;decrementing the loop counter
	BRp REPEAT		;if the loop counter is positive, go back to loop
	
	ADD R2, R2, #0		; setcc
	BRn NEG6		;first loop of 4 cases
	ADD R6, R6, #0		; setcc
	BRn FIX2		; branch for positive negative case
	BRz JANK		; branch for positive positive case
	
NEG6	ADD R6, R6, #0		; setcc
	BRn FIX			; branch for negative negative case
	BRz ZFIX		; branch for negative positive case
	
FIX2	NOT R3, R3		
	ADD R3, R3, #1		; negation
	ADD R0, R0, R3		; accounts for offset from addition
	BRnzp FLIP		; unconditional branch
	
ZFIX	ADD R0, R0, R3		
	BRnzp FLIP
FIX	ADD R0, R0, R3
	BRnzp END
	
JANK
	NOT R3, R3
	ADD R3, R3, #1		; negation 
	ADD R0, R0, R3		;accounts for offset from addition
	BRnzp END

ONE	AND R0, R0, #0
	ADD R0, R0, R3		; accounts for offset from addition
	BRnzp END		;unconditional branch
ZERO	
	AND R0, R0, #0		; setcc
	BRnzp END		; unconditional branch
FLIP
	NOT R0, R0
	ADD R0, R0, #1		; negation

END	
	ST R7, SAVER_7		; save
	JSR PUSH
	LD R7, SAVER_7		; restore
	RET			; goes back to main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4 (R3/R4)
;out R0 (R0=quotient, R1=remainder)
DIV   
   	AND R0, R0, #0		;clear R0
	AND R3, R3, #0		; clear R3
	AND R4, R4, #0		; clear R4
	ST R7, SAVER_7
	JSR POP
	LD R7, SAVER_7
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R4, R4, R0		; load popped number into R3
	ST R7, SAVER_7
	JSR POP
	LD R7, SAVER_7
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R3, R3, R0		; load second popped number into R4

	

	AND R0, R0, #0		; clear R0
	AND R1, R1, #0		; clear R1
	ADD R1, R1, R3
	NOT R4, R4
	ADD R4, R4, #1		; negation
DIVLOOP
	ADD R0, R0, #1
	ADD R1, R1, R4
	BRzp DIVLOOP		;overshoot
	ADD R0, R0, #-1
	ST R7, SAVER_7		; save
	JSR PUSH
	LD R7, SAVER_7		; restore
	RET			; goes back to main code
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
	AND R0, R0, #0		;clear R0
	AND R3, R3, #0		; clear R3
	AND R4, R4, #0		; clear R4
	ST R7, SAVER_7
	JSR POP
	LD R7, SAVER_7
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R4, R4, R0		; load popped number into R3
	ST R7, SAVER_7
	JSR POP
	LD R7, SAVER_7
	ADD R5, R5, #0		; setcc
	BRp INVAL		; if underflow, shows invalid
	ADD R3, R3, R0		; load second popped number into R4

	AND R0, R0, #0		; clear R0
	AND R2, R2, #0		; clear R2
	ST R3, RELOAD		; contains the multiplication counter
	ADD R4, R4, #-1
	BRz POWERONE
	BRn POWERZERO
EXPO
	LD R2, RELOAD		; R2 contains the multiplication counter
TIMES	
	ADD R0, R0, R3
	ADD R2, R2, #-1		; decrements exponent counter outside of the loop
	BRp TIMES		; small addition loop

	AND R3, R3, #0		; clear R3
	ADD R3, R3, R0		; running total transferred to R3
	AND R0, R0, #0		; clear R0
	ADD R4, R4, #-1		; decrement exponent counter in code
	BRp EXPO		; big loop for repeated multiplication

	ADD R0, R0, R3
	BRnzp FINAL		; unconditional branch
POWERONE
	ADD R0, R0, R3
	BRnzp FINAL		; unconditional branch
POWERZERO
	ADD R0, R0, #1

FINAL	ST R7, SAVER_7		; save
	JSR PUSH
	LD R7, SAVER_7		; restore
	RET			; goes back to main code
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DONE    HALT	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH  
     ST R3, PUSH_SaveR3    ;save R3
     ST R4, PUSH_SaveR4    ;save R4
     AND R5, R5, #0        ;
     LD R3, STACK_END    ;
     LD R4, STACk_TOP    ;
     ADD R3, R3, #-1        ;
     NOT R3, R3        ;
     ADD R3, R3, #1        ;
     ADD R3, R3, R4        ;
     BRz OVERFLOW        ;stack is full
     STR R0, R4, #0        ;no overflow, store value in the stack
     ADD R4, R4, #-1        ;move top of the stack
     ST R4, STACK_TOP    ;store top of stack pointer
     BRnzp DONE_PUSH      ;
OVERFLOW
    ADD R5, R5, #1        ;
DONE_PUSH
    LD R3, PUSH_SaveR3    ;
    LD R4, PUSH_SaveR4    ;
    RET


PUSH_SaveR3    .BLKW #1    ;
PUSH_SaveR4    .BLKW #1    ;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP  
    ST R3, POP_SaveR3    ;save R3
    ST R4, POP_SaveR4    ;save R3
    AND R5, R5, #0        ;clear R5
    LD R3, STACK_START    ;
    LD R4, STACK_TOP    ;
    NOT R3, R3        ;
    ADD R3, R3, #1        ;
    ADD R3, R3, R4        ;
    BRz UNDERFLOW        ;
    ADD R4, R4, #1        ;
    LDR R0, R4, #0        ;
    ST R4, STACK_TOP    ;
    BRnzp DONE_POP        ;
UNDERFLOW
    ADD R5, R5, #1        ;
DONE_POP
    LD R3, POP_SaveR3    ;
    LD R4, POP_SaveR4    ;
    RET

.END


