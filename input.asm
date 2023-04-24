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

        .globl input_get_user_input
        .globl input_convert_edge_string
        .globl input_is_valid_edge
        .globl input_is_row_valid
        .globl input_is_col_valid

.text
input_main_test:   # Remove before submission

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
#     public input_get_user_input(): (int col, int row):
#         print(input_user_prompt_string)
#         a0 = input()
#         (col, row) = input_convert_edge_string(a0)
#         return (col, row)
#     end input_get_user_input()
# Inputs:
#   None
# Outputs:
#   $v0 - the col index of the selected edge
#   $v1 - the row index of the selected edge
# Registers modified: $sp, $ra, $s0 (restored), $s1 (restored)
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

        lw $ra, 0($sp)                             # Load return address from stack
        lw $s1, 4($sp)                             # Restore s1
        lw $s2, 8($sp)                             # Restore s2
        addi $sp, $sp, 12                          # Restore the stack

        jr $ra                                     # Return


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
# Registers modified: None
input_get_length:
        move $t0, $a0                       # First index of input string
        li $t1, 0                           # Input string length
        lb $t2, input_edge_string_max_len   # Get max length of string

        # For char in string
        i_gl_loop:
                # If max_length || null_term || or line_feed: end
                lb $t3, ($t0)            # Load the current character to t3
                bge $t1, $t2, i_gl_end   # If length == 3, exit
                beqz $t3, i_gl_end       # If t3 is null terminator
                seq $t3, $t3, 0x0A       # Is t3 a line feed (enter)
                bnez $t3, i_gl_end       # If so end loop

                # Increment index and counter
                addi $t0, $t0, 1         # Move to next char
                addi $t1, $t1, 1         # Increment length

                j i_gl_loop              # Loop again

        # End loop
        i_gl_end:
                # Return counter
                move $v0, $t1   # Save counter
                jr $ra          # Return


# Description: Splits the edge string into two indices for the array.
#
# Pseudo representation:
#     private input_split_input(String a0, int a1): (int col, int row):
#         // EX: a0 = "A11", a1 = 3
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
        addi $sp, $sp, -4           # Make room in stack
        sw $ra, 0($sp)              # Save the return address

        # Get characters
        lbu $t0, 0($a0)             # Get first char,  t0 = a0[0]
        lbu $t1, 1($a0)             # Get second char, t1 = a0[1]

        # Convert from ascii to indices
        subu $t0, $t0, 0x41         # Subtract 0x41 ('A'), from the letter
        subu $t1, $t1, 0x30         # Subtract 0x30 ('0'), from the "number"

        # If len == 2, exit
        seq $t2, $a1, 2             # Compare length with '2'
        bne $t2, $zero, i_si_exit   # If equal, exit

        # If len == 3, there are two numbers
        i_si_two_nums:
                # Combine the two numbers
                lbu $t3, 2($a0)       # Get third char, t3 = a0[2]
                subu $t3, $t3, 0x30   # Subtract 0x30 ('0'), from the "number"
                mulu $t1, $t1, 10     # Multiply the first num by 10
                addu $t1, $t1, $t3    # Add the second number

                # If the len is 3, the Mars GUI forces an enter resulting in odd formatting (CLI doesn't do this)
                jal print_break       # Print break for formatting

        # Exit program
        i_si_exit:
                addi $t1, $t1, -1   # Convert the num to an index

                move $v0, $t0       # Save column index
                move $v1, $t1       # Save row index

                lw $ra, 0($sp)      # Restore the return address
                addi $sp, $sp, 4    # Restore the stack

                jr $ra              # Return

# Description: Checks whether the strings input length is valid, if it isn't
#              an error is thrown and the program requests new input.
#
# Pseudo representation:
#     public input_validate_input_length(int a0): void:
#         # len == a0
#         if (len < 2) print(warning(0x00))
#         jump to i_gui_begin
#     end input_validate_input_length()
#
# Inputs:
#   $a0 - length of the edge string
# Outputs:
#   None
# Registers modified: $sp, $ra
input_validate_input_length:
        addi $sp, $sp, -4               # Make room in stack
        sw $ra, 0($sp)                  # Save the return address

        # Check if length < 2
        slti $t0, $a0, 2                # t0 = a0 < 2
        bne $t0, $zero, i_vil_invalid   # if (t0), invalid length

        # Length is valid, exit
        j i_vil_valid

        # Length is invalid
        i_vil_invalid:
                # Throw warning and reget input
                li $a0, 0x00                 # Error for input too short
                jal _warning_throw_warning   # Print the warning
                addi $sp, $sp, 16            # Restore the stack
                j i_gui_begin                # Get new input

        # Length is valid
        i_vil_valid:
                lw $ra, 0($sp)     # Restore the return address
                addi $sp, $sp, 4   # Restore the stack

                jr $ra             # Return

# Description: Validates the input after being converted to indices, it'll
#              check the ranges of both column and row, verify it's an edge,
#              and then check if the edge is already occupied. If all tests
#              pass the program continues, if not an error is thrown and the
#              program requests new input.
#
# Pseudo representation:
#     public input_validate_input(int a0, int a1): void:
#         col, row = a0, a1
#
#         # Check if col index is between 0-16
#         if !(input_is_valid_col(a0)):
#             print(warning(0x01)) # Invalid Col
#             jump to i_gui_begin
#
#         # Check if row index is between 0-12
#         if !(input_is_valid_row(a1)):
#             print(warning(0x02)) # Invalid row
#             jump to i_gui_begin
#
#         # Check if the edge is a valid edge
#         if !(input_is_valid_edge)
#             print(warning(0x03)) # Not an edge
#             jump to i_gui_begin
#
#         # Check if the edge is occupied
#         if (board_array[row][col] != ' '):
#             print(warning(0x04)) # Edge occupied
#             jump to i_gui_begin
#
# Inputs:
#   $a0 - the col index of the selected edge
#   $a1 - the row index of the selected edge
# Outputs:
#   None
# Registers modified: $sp, $ra
input_validate_input:
        addi $sp, $sp, -12              # Make room in stack
        sw $s0, 8($sp)                  # Save s0
        sw $s1, 4($sp)                  # Save s1
        sw $ra, 0($sp)                  # Save the return address

        move $s0, $a0                   # Save the col index
        move $s1, $a1                   # Save the row index

        # Check column and row indices
        # Check if col index is between 0-16
        jal input_is_col_valid          # Check col range

        li $t0, 0x01                    # Error for invalid column index
        beq $v0, $zero, i_vir_invalid   # If return is 0, invalid

        # Check if row index is between 0-12
        move $a0, $s1                   # Move row to arg 0
        jal input_is_row_valid          # Check row range

        li $t0, 0x02                    # Error for invalid row index
        beq $v0, $zero, i_vir_invalid   # If return is 0, invalid


        # Check if the edge is a valid edge
        move $a0, $s0                   # Move col to arg 0
        move $a1, $s1                   # Move row to arg 1
        jal input_is_valid_edge         # Check if selection is valid edge

        li $t0, 0x03                    # Error for invalid edge
        beq $v0, $zero, i_vir_invalid   # If return is 0, invalid


        # Check if the edge is occupied
        jal board_is_edge_unclaimed     # Checks if current edge is a space
        li $t0, 0x04                    # Error for claimed edge
        andi $t1, $v0, 0x01             # If claimed, t1 = 0
        beq $t1, $zero, i_vir_invalid   # If t1 == 0, it's claimed, invalid


        # Valid edge, continue
        j i_vir_valid

        # Edge selected is invalid
        i_vir_invalid:
                move $a0, $t0                # Move appropriate error to subroutine argument
                jal _warning_throw_warning   # Print the warning and return
                addi $sp, $sp, 12            # Restore the stack
                j i_gui_begin                # Request new input

        # Edge selected is valid
        i_vir_valid:
                lw $ra, 0($sp)      # Restore the return address
                addi $sp, $sp, 12   # Restore the stack

                jr $ra              # Return


# Description: Checks the provided column index and makes sure it's greater
#              or equal to 0 and less than the board column size
#
# Pseudo representation:
#     public input_is_col_valid(int a0): boolean:
#         col = a0
#         int col_size = board_get_column_size - 1
#         return 0 <= col <= col_size
#     end input_is_col_valid
# Inputs:
#   $a0 - the column index to validate
# Outputs:
#   $v0 - 0x01 if true, 0x00 if false
# Registers modified: $sp, $ra
input_is_col_valid:
        addi $sp, $sp, -4               # Make room in stack
        sw $ra, 0($sp)                  # Save return address

        # Get max column index
        jal board_get_column_size       # Get column size
        move $t0, $v0                   # Save to t0
        subi $t0, $t0, 1                # Subtract 1

        # Use v0 as a boolean
        li $v0, 0x01                    # Default to true

        # If !(0 <= col <= 16): invalid
        slti $t1, $a0, 0                # Is column index less than 0
        bne $t1, $zero, i_icv_invalid   # If so col index is invalid
        sgt $t1, $a0, $t0               # Is column index greater than column size - 1
        bne $t1, $zero, i_icv_invalid   # If so col index is invalid


        # Return v0 as valid
        j i_icv_exit

        # Input is invalid, mark false and return
        i_icv_invalid:
                li $v0, 0x00   # Set v0 to false

        i_icv_exit:
                lw $ra 0($sp)      # Load return address
                addi $sp, $sp, 4   # Restore the stack
                jr $ra             # Return

# Description: Checks the provided row index and makes sure it's greater
#              or equal to 0 and less than the board row size
#
# Pseudo representation:
#     public input_is_row_valid(int a0): boolean:
#         row = a0
#         int row_size = board_get_row_size - 1
#         return 0 <= row <= row_size
#     end input_is_row_valid
# Inputs:
#   $a0 - the row index to validate
# Outputs:
#   $v0 - 0x01 if true, 0x00 if false
# Registers modified: $sp, $ra
input_is_row_valid:
        addi $sp, $sp, -4               # Make room in stack
        sw $ra, 0($sp)                  # Save return address

        # Get max row index
        jal board_get_row_size          # Get column size
        move $t0, $v0                   # Save to t0
        subi $t0, $t0, 1                # Subtract 1

        # Use v0 as a boolean
        li $v0, 0x01                    # Default to true

        # If !(0 <= row <= 12): invalid
        slti $t1, $a0, 0                # Is row index less than 0
        bne $t1, $zero, i_irv_invalid   # If so row index is invalid
        sgt $t1, $a0, $t0               # Is row index greater than row size - 1
        bne $t1, $zero, i_irv_invalid   # If so row index is invalid

        # Return v0 as valid
        j i_irv_exit

        # Input is invalid, mark false and return
        i_irv_invalid:
                li $v0, 0x00   # Set v0 to false

        # Exit the subroutine
        i_irv_exit:
                lw $ra 0($sp)      # Load return address
                addi $sp, $sp, 4   # Restore the stack
                jr $ra             # Return


# Description: Checks whether the selected edge is an edge. If the row and
#              column are both either odd or even, it's not an edge.
#
# Pseudo representation:
#     public input_is_valid_edge(int a0, int a1): boolean:
#         col = a0
#         row = a1
#         return (isEven(col) && !isEven(row)) || (!isEven(col) && isEven(row))
#     end input_is_valid_edge
# Inputs:
#   $a0 - the column index to validate
#   $a1 - the row index to validate
# Outputs:
#   $v0 - 0x01 if true, 0x00 if false
# Registers modified: $sp, $ra
input_is_valid_edge:
        # Use v0 as a boolean
        li $v0, 0x01                # Default to true

        # Validate columm and row selection
        andi $t0, $a0, 0x01         # Check if col is even, t0 = isEven(col)
        andi $t1, $a1, 0x01         # Check if row is even, t1 = isEven(row)

        # Valid edge is one odd, one even index
        addu $t0, $t0, $t1          # Add results of isEven
        bne $t0, 1, i_ive_invalid   # If result is not 1 (false + true), then it's invalid

        # Valid
        jr $ra                      # Return true

        # Invalid
        i_ive_invalid:
                li $v0, 0x00   # Set v0 to false
                jr $ra         # Return