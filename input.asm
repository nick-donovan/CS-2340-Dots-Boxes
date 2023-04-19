# File: input.asm
# Authors: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for handling user input and validating it according to the
#  rules of the game. Functions for reading input from the user, checking if the
#  input is valid, and displaying error messages if the input is invalid.

.data
        input_user_selected_edge:      .space 3
        input_user_selected_edge_size: .byte 4
        input_edge_string_max_len:     .byte 3
        input_user_prompt_string:      .asciiz "Enter an edge to claim (ex: A2): "
        input_invalid_input_warning:   .asciiz "Please enter a letter (A-O) and a number (0-11)."
        input_insf_characters_warning: .asciiz "PLACEHOLDER WARNING - NOT ENOUGH CHARS IN EDGE STRING"

        .globl input_get_user_input
        .globl input_convert_edge_string

.text
main:
        jal board_initialize_board
        li $a0, 0
        li $a1, 1
        li $a2, 0
        jal board_update_edge
        jal board_print_board
        jal input_get_user_input

        move $a0, $v0
        move $a1, $v1
        li $a2, 0
        jal board_update_edge
        jal board_print_board

        j exit

# Description: Prints the input_user_prompt_string and saves a selected edge into
#              input_user_selected_edge before having it converted to two indices.
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
        addi $sp, $sp, -12   # Make room in stack
        sw $s0, 8($sp)       # Save s0
        sw $s1, 4($sp)       # Save s1
        sw $ra, 0($sp)       # Save the return address

        # Used to loop back in case of error
        i_gui_begin:
                # Print prompt to console
                la $a0, input_user_prompt_string   # Load prompt
                jal print_string                   # Print prompt

                # Read in the user selected edge
                la $a0, input_user_selected_edge   # Load area to store the input
                li $a1, 0X04                       # Size of the input is 4 (3 + \nul)
                li $v0, 8                          # Syscall to read string
                syscall                            # Read string

                # Convert the string to indices
                jal input_convert_edge_string      # Convert
                move $s0, $v0                      # Save the column index
                move $s1, $v1                      # Save the row index

                # Validate the input
                move $a0, $v0                      # Move the column index to a0
                move $a1, $v1                      # Move the row index to a1
                jal input_validate_input           # Validate the input

                # Return the column and row indices
                move $v0, $s0                      # Move column index to v0
                move $v1, $s1                      # Move row index to v1

        lw $ra, 0($sp)       # Load return address from stack
        lw $s1, 4($sp)       # Restore s1
        lw $s2, 8($sp)       # Restore s2
        addi $sp, $sp, 12    # Restore the stack

        jr $ra               # Return


# Description: Converts an inputted edge string (Ex: "A2") into indices (Ex: (0, 1))
#
# Pseudo representation:
#     public input_convert_edge_string(String a0): (int col, int row):
#         # Preserve the string to s0
#         String s0 = a0
#
#         # Get the length of the string
#         int v0 = input_get_length(a0)
#         int s1 = v0
#
#         # Validate the input length
#         input_validate_input_length(s1)
#
#         # Split the input into a col and row index
#         (col, row) = input_split_input(s0, s1)
#         int s0, s1 = col, row
#
#         # Validate the input
#         input_validate_input(s0, s1)
#
#         # Return the column and row indices
#         return (col, row)
#     end input_convert_edge_string()
#
# Inputs:
#   $a0 - the string to convert to indices
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra, $s0 (restored), $s1 (restored)
input_convert_edge_string:
        addi $sp, $sp -12                 # Make room in stack
        sw $s0, 8($sp)                    # Save s0
        sw $s1, 4($sp)                    # Save s1
        sw $ra, 0($sp)                    # Save the return address

        move $s0, $a0                     # Preserve the string to s0

          # Get the length of the string
        jal input_get_length              # Get length
        move $s1, $v0                     # Save return value in s1

        # Validate the input length
        move $a0, $s1                     # Move s1 to subroutine arg
        jal input_validate_input_length   # Validate length

        # Split the input into a col and row index
        move $a0, $s0                     # Move String to arg 1
        move $a1, $s1                     # Move length to arg 2
        jal input_split_input             # Split the input

        # Column and row indices are returned as v0 and v1

        lw $ra, 0($sp)                    # Load return address
        lw $s1, 4($sp)                    # Load s1
        lw $s0, 8($sp)                    # Load s2
        addi $sp, $sp, 12                 # Restore the stack

        jr $ra                            # Return

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

        move $t0, $a0   # First index of input string
        li $t1, 0       # Input string length
        lb $t2, input_edge_string_max_len

        i_gl_loop:
                lb $t3, ($t0)
                bge $t1, $t2, i_gl_end   # If length == 3, exit
                beqz $t3, i_gl_end       # If null terminated
                seq $t3, $t3, 0x0A
                bnez $t3, i_gl_end       # If line feed terminated

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

        i_si_two_nums:   # a0 will not be greater than 3 chars
                lbu $t3, 2($a0)
                subu $t3, $t3, 0x30
                li $t4, 10
                mulu $t1, $t1, $t4
                addu $t1, $t1, $t3

                jal print_break

        i_si_exit:
                addi $t1, $t1, -1

                move $v0, $t0
                move $v1, $t1

                lw $ra, 0($sp)
                addi $sp, $sp, 4

                jr $ra


input_get_caller_address:
        slt $t0, $a0, $a1
        beq $t0, $zero, i_gca_swap_values

        j i_gca_continue

        i_gca_swap_values:
                move $t0, $a0
                move $a1, $a0
                move $a0, $t0

        i_gca_continue:
                slt $t0, $ra $a1
                beq $t0, $zero, i_gca_second_label

                move $v0, $a0

                jr $ra

        i_gca_second_label:
                move $v0, $a1
                jr $ra
# a0 length
input_validate_input_length:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        slti $t0, $a0, 2
        bne $t0, $zero, i_vil_invalid

        j i_vil_valid

        i_vil_invalid:
                li $a0, 0x00
                jal _warning_throw_warning
                addi $sp, $sp, 16
                j i_gui_begin

        i_vil_valid:
                lw $ra, 0($sp)
                addi $sp, $sp, 4
                jr $ra

#   $a0 - the col index of the selected edge
#   $a1 - the row index of the selected edge
input_validate_input:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        i_vir_check_ranges:
        li $t0, 0x01
        slti $t1, $a0, 0                # if (a0 < 0) t1 = 1
        bne $t1, $zero, i_vir_invalid   # if t1 != 0 invalid

        sgt $t1, $a0, 16                # if (a0 > 16) t1 = 1
        bne $t1, $zero, i_vir_invalid   # if t1 !- 0 invalid

        li $t0, 0x02
        slti $t1, $a1, 0
        bne $t1, $zero, i_vir_invalid

        sgt $t1, $a1, 12
        bne $t1, $zero, i_vir_invalid

        i_vir_check_edge:
        li $t0, 0x03
        andi $t1, $a0, 0x01
        andi $t2, $a1, 0x01

        addu $t1, $t1, $t2
        bne $t1, 1, i_vir_invalid

        i_vir_check_occupied:
        jal board_is_edge_unclaimed   #TAKESE AO AND A1
        li $t0, 0x04
        andi $t1, $v0, 0x01
        beq $t1, $zero, i_vir_invalid

        j i_vir_valid

        i_vir_invalid:
                move $a0, $t0
                jal _warning_throw_warning
                addi $sp, $sp, 4
                j i_gui_begin

        i_vir_valid:
                lw $ra, 0($sp)
                addi $sp, $sp, 4
                jr $ra