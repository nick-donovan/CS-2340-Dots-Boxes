# File: input.asm
# Authors: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for handling user input and validating it according to the 
#  rules of the game. Functions for reading input from the user, checking if the 
#  input is valid, and displaying error messages if the input is invalid.

.data
        input_user_selected_edge: .space 3
        input_user_selected_edge_size: .byte 4
        input_edge_string_max_len: .byte 3
        input_user_prompt_string: .asciiz "Enter an edge to claim (ex: A2): "
        input_invalid_input_warning: .asciiz "Please enter a letter (A-O) and a number (0-11)."
        input_insf_characters_warning: .asciiz "PLACEHOLDER WARNING - NOT ENOUGH CHARS IN EDGE STRING"
        .globl input_get_user_input
        .globl input_convert_edge_string

.text
main:

        jal input_get_user_input
        j exit

# Description: Prints the input_user_prompt_string and saves a selected edge into 
#              input_user_selected_edge before having it converted to two indicies.
#
# Pseudo representation:
#     public (int, int) input_get_user_input():
#         print(input_user_prompt_string)
#         a0 = input.next
#         (col, row) = input_convert_edge_string(a0)
#         return (col, row)
#     end input_get_user_input()
# Inputs: 
#   None
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra, $a0
input_get_user_input:
        addi $sp, $sp -4
        sw $ra, 0($sp)
        
        la $a0, input_user_prompt_string
        jal print_string
        
        la $a0, input_user_selected_edge
        lb $a1, input_user_selected_edge_size
        li $v0, 8
        syscall
        
        jal input_convert_edge_string
        
        # todo: jal input_validate_user_input
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        jr $ra
        
# Description: Converts an inputted edge string (Ex: "A2") into indicies (Ex: (0, 1)
#
# Pseudo representation:
#     public (int col, int row) input_convert_edge_string(String a0):
#         int v0 = input_get_length(a0)
#         int a1 = v0
#         (col, row) = input_split_input(a0, a1)
#         return (col, row)
#     end input_convert_edge_string()
#
# Inputs: 
#   $a0 - string to get length of
# Outputs:
#   $v0 - length of string as integer
# Registers modified: $sp, $ra
input_convert_edge_string:
        addi $sp, $sp -4
        sw $ra, 0($sp)
      
        jal input_get_length

        # todo: add error handling for len < 2
        
        move $a1, $v0
        jal input_split_input

        # $v0 - the col index of the selected edge
        # $v1 - the row index of the selected edge

        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        jr $ra

# Description: Returns the length of a string
#
# Pseudo representation:
#     private int input_get_length(String a0):
#         int len = 0
#         for (char in a0):
#             if (len >= input_edge_string_max_len || char == 0x00 || char == 0x0A):
#                 break
#             ++len
#         end for
#         return len
#     end input_get_length()
#
# Inputs:
#   $a0 - string to get length of
# Outputs:
#   $v0 - length of string as integer
# Registers modified: $sp, $ra
input_get_length:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        move $t0, $a0 # First index of input string
        li $t1, 0   # Input string length
        lb $t2, input_edge_string_max_len

        i_gl_loop:
                lb $t3, ($t0)
                bge $t1, $t2, i_gl_end # If length == 3, exit
                beqz $t3, i_gl_end # If null terminated
                seq $t3, $t3, 0x0A
                bnez $t3, i_gl_end # If line feed terminated

                add $t0, $t0, 1
                addi $t1, $t1, 1
                
                j i_gl_loop

        i_gl_end:
                move $v0, $t1
                
                lw $ra, 0($sp)
                addi $sp, $sp, 4
                
                jr $ra

                

# Description: Splits the edge string into two indices for the array.
#
# Pseudo representation:
#     private (int col, int row) input_split_input(String $a0, int $a1):
#         // EX: $a0 = "A11"
#         int col = input[0] - 0x41 # 'A' becomes 0
#         int row = input[1] - 0x30 # '1' becomes 1
#         if (input.length == 2):
#             return inputArr
#         row = (row * 10) + (input[2] - 0x30) # Row becomes '11'
#         --row # Row becomes '10'
#         return (col, row)
#     end input_split_input()
#
# Inputs: 
#   $a0 - edge string containing the selected edge to split
#   $a1 - length of the edge string
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra
input_split_input:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        lbu $t0, 0($a0)
        lbu $t1, 1($a0)
        
        subu $t0, $t0, 0x41
        subu $t1, $t1, 0x30
        
        seq $t2, $a1, 2
        bnez $t2, i_si_exit
        
        i_si_two_nums: # a0 will not be greater than 3 chars
                lbu $t3, 2($a0)
                subu $t3, $t3, 0x30
                li $t4, 10
                mulu $t1, $t1, $t4
                addu $t1, $t1, $t3
        
        i_si_exit:
                addi $t1, $t1, -1
        
                move $v0, $t0
                move $v1, $t1
                
                lw $ra, 0($sp)
                addi $sp, $sp, 4
        
                jr $ra

exit:
        li $v0, 10
        syscall
