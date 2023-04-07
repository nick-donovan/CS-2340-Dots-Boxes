# File: board.asm
# Authors: Nicholas Donovan [ADD YOUR NAMES HERE IF YOU WORK ON IT]
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for creating, updating, and displaying the game board. Will contain
#  functions for initializing the board, updating the state of the board after a move is made,
#  and printing the board to the console.

# I'll add comments to this later -ND

.data
        board_row_size:      .byte 11
        board_column_size:   .byte 15
        board_symbol_char:   .byte '+'
        board_space_char:      .byte ' '
        board_array:        .space 165
        board_array_size:    .half 165
        board_header_string: .asciiz "   A B C D E F G H I J K L M N O \n   -----------------------------\n"
        board_player_symbol: .byte 'P'
        board_opp_symbol: .byte 'C'
        .globl board_print_board
        .globl board_initialize_board
        .globl board_update_edge

.text
# Description: Initializes the game board with the board_symbol_char as dots
#              and spaces for empty areas.
#
# Pseudo representation:
#     public void board_initialize_board():
#         for(int row = 0; row < board_row_size; ++row):
#             for (int col = 0; col < board_column_size; ++col):
#                 if (row.isEven() && col.isEven()):
#                     board_array[row][col] = board_symbol_char
#                 else
#                     board_array[row][col] = ' '
#             end for
#         end for
#     end board_initialize_board
#
# Inputs:
#   None
# Outputs:
#   None - Initialized board is saved in memory
# Registers modified: $sp, $ra
board_initialize_board:
        addi $sp, $sp, -4           # Make room in stack
        sw $ra, 0($sp)              # Save the return address

        la $t0, board_array         # Load address of the array into $t0
        la $t1, board_row_size      # Load rowSize address into $t1
        lb $t1, ($t1)               # Set $t1 to rowSize integer
        la $t2, board_column_size   # Load colSize address into $t2
        lb $t2, ($t2)               # Set $t2 to colSize integer
        li $t3, 0                   # Initialize row index to 0 (int row = 0)

        # Loop through each row of the game board
        b_ib_row_loop:
                slt $t5, $t3, $t1           # Is row < board_row_size
                beq $t5, $zero, b_ib_exit   # If not, exit

                li $t4, 0                   # Set col index to 0 (int col = 0)

                # Loop through each column of the game board
                b_ib_col_loop:
                        slt $t5, $t4, $t2                   # Is col < board_column_size
                        beq $t5, $zero, b_ib_col_loop_end   # If not, move to next row

                        # Check if current position is even
                        andi $t5, $t3, 0x01                 # Use AND to check if row index is even
                        bnez $t5, b_ib_cl_load_space        # Jump to b_ib_cl_load_space if row index is odd

                        andi $t5, $t4, 0x01                 # Use AND to check if col index is even
                        bnez $t5, b_ib_cl_load_space        # Jump to b_ib_cl_load_space if col index is odd

                        lb $t6, board_symbol_char           # Load board_symbol_char into $t6

                        j b_ib_insert_char                  # Insert into the game board array

                        # Load a space if either row or col are odd
                        b_ib_cl_load_space:
                                lb $t6, board_space_char   # Load the space character into $t6

                        # Insert the loaded symbol into the game board array
                        b_ib_insert_char:
                                sb $t6, ($t0)   # Insert the loaded char into the game board array

                        # Adjust indexes and positions
                        addi $t4, $t4, 1        # Increment col index
                        addi $t0, $t0, 1        # Increment position to next element
                        j b_ib_col_loop         # Move to next element

                # End of the column loop
                b_ib_col_loop_end:
                        addi $t3, $t3, 1   # Increment row index
                        j b_ib_row_loop    # Move to next row

        b_ib_exit:
                lw $ra, 0($sp)     # Load return address from stack
                addi $sp, $sp, 4   # Free up stack space

                jr $ra             # Return

# Description: Prints the game board in it's current state.
#
# Pseudo representation:
#     public void board_print_board():
#         print(board_header_string)
#         for(int row = 0; row < board_row_size; ++row):
#             for (int col = 0; col < board_column_size; ++col):
#                  print(row + 1)
#                  print(' ')
#                  if (row + 1 < 9): print(' ')
#                  print(board_array[row][col] + " ")
#              end for
#              print('\n')
#          end for
#      end board_print_board()
#
# Inputs:
#   None
# Outputs:
#   None
# Registers modified: $sp, $ra, $a0
board_print_board:
        addi $sp, $sp, -4           # Make room in stack
        sw $ra, 0($sp)              # Save the return address

        la $t0, board_array         # Load address of the array into $t0
        la $t1, board_row_size      # Load rowSize address into $t1
        lb $t1, ($t1)               # Set $t1 to rowSize integer
        la $t2, board_column_size   # Load colSize address into $t2
        lb $t2, ($t2)               # Set $t2 to colSize integer
        li $t3, 0                   # Initialize row index to 0 (int row = 0)

        jal print_break

        la $a0, board_header_string
        jal print_string

        # Loop through each row of the game board
        b_pb_row_loop:
                slt $t5, $t3, $t1           # Is row < board_row_size
                beq $t5, $zero, b_pb_exit   # If not, exit

                li $t4, 0                   # Set col index to 0 (int col = 0)

                # Print the number label for each row
                b_pb_print_row_num:
                        move $a0, $t3                     # Move row index to a0
                        addiu $a0, $a0, 1                 # Add 1
                        jal print_int                     # Print row index

                        lb $a0, board_space_char          # Load space char
                        jal print_char                    # Print a space

                        slti $t5, $t3, 9                  # Is row in the one digit num range
                        beq $t5, $zero, b_pb_print_cell   # If not skip to b_pb_print_cell

                        jal print_char                    # Else print another space

                # Loop through each column of the game board
                b_pb_col_loop:
                        slt $t5, $t4, $t2                   # Is col < board_column_size
                        beq $t5, $zero, b_pb_col_loop_end   # If not, move to next row

                        # Print the current cell
                        b_pb_print_cell:
                                lb $a0, ($t0)              # Load the current array element into $a0
                                jal print_char             # Print the current element

                                lb $a0, board_space_char   # Load a space into $a0
                                jal print_char             # Print a space

                        # Adjust indexes and positions
                        addi $t4, $t4, 1                   # Increment col index
                        addi $t0, $t0, 1                   # Increment position to next element
                        j b_pb_col_loop                    # Move to next element

                b_pb_col_loop_end:
                        addi $t3, $t3, 1   # Increment row index

                        la $a0, '\n'       # Load new line char
                        jal print_char     # Print new line

                        j b_pb_row_loop    # Move to next row

        b_pb_exit:
                lw $ra, 0($sp)     # Load return address from stack
                addi $sp, $sp, 4   # Free up stack space

                jr $ra             # Return

# Description: Updates a board edge and sets a marker for who claimed it
#
# Pseudo representation:
#    private void board_update_edge(int $a0, int $a1, $int a2):
#        if (a2 == 0)
#            board_array[a1][a0] = board_player_symbol
#        else
#            board_array[a1][a0] = board_opp_symbol
#    end board_update_edge()
#
# Inputs:
#   $a0 - Col index of the edge
#   $a1 - Row index of the edge
#   $a2 - Integer for which player claims the edge; 0 for player, 1 for opponent
# Outputs:
#   None
# Registers modified: $sp, $ra
board_update_edge:
        addi $sp, $sp, -4              # Make room in stack
        sw $ra, 0($sp)                 # Save the return address

        la $t0, board_array            # Load address of the array into $t0
        la $t1, board_row_size         # Load rowSize address into $t1
        lb $t1, ($t1)                  # Set $t1 to rowSize integer
        la $t2, board_column_size      # Load colSize address into $t2
        lb $t2, ($t2)                  # Set $t2 to colSize integer

        mul $t4, $a1, $t2              # Get current row
        add $t4, $t4, $a0              # Get current element index in row
        add $t4, $t4, $t0              # Add index to array address to get current address

        bnez $a2, b_ue_opponent_edge   # if (a2 != 0) it's the opponents edge

        lb $t5, board_player_symbol    # Load players edge symbol
        j b_ue_set_edge                # Set players edge

        b_ue_opponent_edge:
                lb $t5, board_opp_symbol   # Load opponents edge symbol

        b_ue_set_edge:
                sb $t5, ($t4)   # Store symbol as current element

        lw $ra, 0($sp)          # Load return address
        addi $sp, $sp, 4        # Restore the stack

        jr $ra                  # Return
