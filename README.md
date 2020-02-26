# Stack-Calculator

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
