# File: input.asm
# Authors: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for handling user input and validating it according to the 
#  rules of the game. Functions for reading input from the user, checking if the 
#  input is valid, and displaying error messages if the input is invalid.

.data
        userSelectedEdge: .space 3
        userSelectedEdgeSize: .byte 4
        userPromptString: .asciiz "Enter an edge to claim (ex: A2): "
        invalidInputWarning: .asciiz "Please enter a letter (A-O) and a number (0-11)."

        

.text
main:
        j getUserInput

getUserInput:
        addi $sp, $sp -16
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        sw $a1, 8($sp)
        sw $a2, 12($sp)
        
        la $a0, userPromptString
        li $v0, 4
        syscall
        
        la $a0, userSelectedEdge
        lb $a1, userSelectedEdgeSize
        li $v0, 8
        syscall
        
        jal getLength
        
        move $a1, $v0
        
        # Input may be A0-O11
        jal splitInput

        move $t0, $v0
        move $t1, $v1

        li $a0, '\n'
        li $v0, 11
        syscall
                        
        move $a0, $t0
        li $v0, 1
        syscall
        
        li $a0, '\n'
        li $v0, 11
        syscall
        
        move $a0, $t1
        li $v0, 1
        syscall
        
        j exit
        
        # jal validateUserInput TODO
        
        subi $v0, $a1, 0x41 # Convert to column index
        subi $v1, $a2, 0x30 # Convert to row index
        
        move $a0, $v0
        li $v0, 1
        syscall
        
        move $a0, $v1
        li $v0, 1
        syscall
        
#        li $a0, 2222
#        li $v0, 1
#        syscall
        
        lw $a2, 12($sp)
        lw $a1, 8($sp)
        lw $a0, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 16
        
        j exit

getLength:
        move $t0, $a0 # First index of input string
        li $t1, 0   # Input string length
        
getLengthLoop:
        lb $t2, ($t0)
        beqz $t2, getLengthEnd # If null terminated
        seq $t2, $t2, 0xa
        bnez $t2, getLengthEnd # If line feed terminated
        
        
        add $t0, $t0, 1
        addi $t1, $t1, 1
        
        j getLengthLoop
        
getLengthEnd:
        move $v0, $t1
        jr $ra

splitInput:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        lbu $t0, 0($a0)
        subu $t0, $t0, 0x41
        
        lbu $t1, 1($a0)
        subu $t1, $t1, 0x30
        
        seq $t2, $a1, 2
        bnez $t2, splitInputExit
        
        lbu $t3, 2($a0)
        subu $t3, $t3, 0x30
        li $t4, 0xA
        mult $t1, $t4
        mflo $t1
        addu $t1, $t1, $t3 

splitInputExit:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        move $v0, $t0
        move $v1, $t1

        jr $ra

validateUserInput:
        addi $sp, $sp -4
        sw $ra, 0($sp)
        
        blt $a1, 0x41, invalidInput
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        # Column accepted between 0x41 && 0x4F
        
        
invalidInput:
        la $a0, invalidInputWarning
        li $v0, 4
        syscall
        
        j getUserInput

exit:
        li $v0, 10
        syscall
#        jr $ra
