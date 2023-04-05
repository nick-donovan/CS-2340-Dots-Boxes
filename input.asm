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
        edgeStringMaxLen: .byte 3
        userPromptString: .asciiz "Enter an edge to claim (ex: A2): "
        invalidInputWarning: .asciiz "Please enter a letter (A-O) and a number (0-11)."
        insfCharactersWarning: .asciiz "PLACEHOLDER WARNING - NOT ENOUGH CHARS IN EDGE STRING"
        .globl getUserInput
        .globl convertEdgeString

.text
main:

        jal getUserInput
        j exit

# Description: Prints the userPromptString and saves a selected edge into 
#              userSelectedEdge before having it converted to two indicies.
#
# Pseudo representation:
#     public (int, int) getUserInput():
#         print(userPromptString)
#         a0 = input.next
#         (col, row) = convertEdgeString(a0)
#         return (col, row)
#     end getUserInput()
# Inputs: 
#   None
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra, $a0
getUserInput:
        addi $sp, $sp -4
        sw $ra, 0($sp)
        
        la $a0, userPromptString
        jal printString
        
        la $a0, userSelectedEdge
        lb $a1, userSelectedEdgeSize
        li $v0, 8
        syscall
        
        jal convertEdgeString
        
        # todo: jal validateUserInput
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        jr $ra
        
convertEdgeString:
        addi $sp, $sp -4
        sw $ra, 0($sp)
      
        jal getLength

        # todo: add error handling for len < 2
        
        move $a1, $v0
        jal splitInput

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        jr $ra

# Description: Returns the length of a string
#
# Pseudo representation:
#     private int getLength(String a0):
#         int len = 0
#         for (char in a0):
#             if (len >= edgeStringMaxLen || char == 0x00 || char == 0x0A):
#                 break
#             ++len
#         end for
#         return len
#     end getLength()
#
# Inputs: 
#   $a0 - string to get length of
# Outputs:
#   $v0 - length of string as integer
# Registers modified: $sp, $ra
getLength:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        move $t0, $a0 # First index of input string
        li $t1, 0   # Input string length
        lb $t2, edgeStringMaxLen

        getLengthLoop:
                lb $t3, ($t0)
                bge $t1, $t2, getLengthEnd # If length == 3, exit
                beqz $t3, getLengthEnd # If null terminated
                seq $t3, $t3, 0x0A
                bnez $t3, getLengthEnd # If line feed terminated
                

                add $t0, $t0, 1
                addi $t1, $t1, 1
                
                j getLengthLoop

        getLengthEnd:
                move $v0, $t1
                
                lw $ra, 0($sp)
                addi $sp, $sp, 4
                
                jr $ra

                

# Description: Splits the edge string into two indices for the array.
#
# Pseudo representation:
#     private (int, int) splitInput(String $a0, int $a1):
#         // EX: $a0 = "A11"
#         int col = input[0] - 0x41 # 'A' becomes 0
#         int row = input[1] - 0x30 # '1' becomes 1
#         if (input.length == 2):
#             return inputArr
#         row = (row * 10) + (input[2] - 0x30) # Row becomes '11'
#         --row # Row becomes '10'
#         return (col, row)
#     end splitInput()
#
# Inputs: 
#   $a0 - edge string containing the selected edge to split
#   $a1 - length of the edge string
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra
splitInput:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        lbu $t0, 0($a0)
        lbu $t1, 1($a0)
        
        subu $t0, $t0, 0x41
        subu $t1, $t1, 0x30
        
        seq $t2, $a1, 2
        bnez $t2, splitInputExit
        
        splitInputTwoNums: # a0 will not be greater than 3 chars
                lbu $t3, 2($a0)
                subu $t3, $t3, 0x30
                li $t4, 10
                mulu $t1, $t1, $t4
                addu $t1, $t1, $t3
        
        splitInputExit:
                addi $t1, $t1, -1
        
                move $v0, $t0
                move $v1, $t1
                
                lw $ra, 0($sp)
                addi $sp, $sp, 4
        
                jr $ra

exit:
        li $v0, 10
        syscall