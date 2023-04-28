# File: computer.asm
# Author: Advaith Sreeram, Hari Ramalingam, Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for implementing the computer's strategy for selecting moves.
#  Functions for choosing a random move, selecting the move that creates the most boxes,
#  or using a more advanced algorithm to make smarter moves.

.data
        .globl computer_calculate_best_score

.text


# Description: Uses the computer_find_max_loop subroutine to find and return
#              the best move for the computer to make. The move is returned
#              as column and row indices.
#
# Pseudo representation:
#     public computer_calculate_best_score(): int, int:
#         s0 = board_array
#         col, row = computer_find_max_loop
#         return col, row
#     end computer_calculate_best_score()
#
# Inputs:
#   None
# Outputs:
#   $v0 - the best column index
#   $v1 - the best row index
# Registers modified: $sp, $ra, $s0 (restored)
computer_calculate_best_score:
        addi $sp, $sp, -8            # Make room in the stack
        sw $s0, 4($sp)               # Save s0
        sw $ra, 0($sp)               # Save return address


        # Load the board_array
        la $s0, board_array          # Set s0 to the board_array address

        # Find the edge with the highest score
        move $a0, $s0                # Set the board address as arg 0
        jal computer_find_max_loop   # Find the highest scores edge

        # Finish and return the indices
        c_fb_finish:
                lw $ra, 0($sp)     # Restore the return address
                lw $s0, 4($sp)     # Restore s0
                addi $sp, $sp, 8   # Restore the stack

                jr $ra             # Return

# Description: Nested for loop that iterates through each edge in the array
#              and calculating scores for each box the edge can see. The
#              maximum score that won't give the opponent an advantage (if
#              possible) is selected and returned.
#
# Pseudo representation:
#      private computer_find_max_loop(char[][] board_array): int, int:
#         int s5 = max_score = -1
#         int s6 = max_score_row = -1
#         int s7 = max_score_col = -1
#         for (int s1 = row = 0; row < BOARD_ROW_SIZE; ++row):
#             int s2 = col
#             if (row.isEven) col = 1
#             else col = 0
#             for (col; col < BOARD_COL_SIZE; col += 2):
#                 if (board_array[row][col] != ' ') continue
#                     int curr = computer_get_edge_score(row, col, BOARD_ROW_SIZE, BOARD_COL_SIZE)
#
#                     if (computer_compare_max_current_score(max, curr) != max):
#                         max_score = curr
#                         max_score_row = row
#                         max_score_col = col
#             end for()
#         end for()
#
#         return max_score_row, max_score_col
#     end computer_find_max_loop()
#
# Inputs:
#   $a0 - board array address
# Outputs:
#   $v0 - the best column index
#   $v1 - the best row index
# Registers modified: $sp, $ra, $s0-$s7 (restored)
computer_find_max_loop:
        addi $sp, $sp, -36          # Make a lot of room in the stack
        sw $s7, 32($sp)             # Save s7
        sw $s6, 28($sp)             # Save s6
        sw $s5, 24($sp)             # Save s5
        sw $s4, 20($sp)             # Save s4
        sw $s3, 16($sp)             # Save s3
        sw $s2, 12($sp)             # Save s2
        sw $s1, 8($sp)              # Save s1
        sw $s0, 4($sp)              # Save s0
        sw $ra, 0($sp)              # Save ra

        # Index address
        move $s0, $a0               # Save base address to s0
        addi $s0, $s0, 1            # Increment by 1 to get first edge

        # Row index
        li $s1, 0                   # Save starting row index to 0

        # Col index
        li $s2, 0                   # Save starting col index to 0

        # Save row size
        lb $s3, board_row_size      # Save row size to s3

         # Save column size
        lb $s4, board_column_size   # Save col size to s4

        # Save highest score
        li $s5, -1                  # Init high score to -1

        # Save highest row
        li $s6, -1                  # Init high score row to -1

        # Save highest column
        li $s7, -1                  # Init high score col to -1

        c_fml_row:

                # If row is over max exit
                sge $t0, $s1, $s3               # Is row > max rows
                bne $t0, $zero, c_fml_close     # If so exit loop

                # Odd rows have different starting columns for edges
                andi $t0, $s1, 0x01             # Is row odd
                bne $t0, $zero, c_fml_odd_row   # If so branch
                li $s2, 1                       # Otherwise initialize col with 1
                j c_fml_col                     # Jump to col loop

                # Row is odd
                c_fml_odd_row:
                        li $s2, 0   # Initialize col with 0

                c_fml_col:
                        # Go to next row when appropriate
                        sge $t0, $s2, $s4                        # Is col over max cols
                        bne $t0, $zero, c_fml_next_row           # If so jump to next row

                        # Check if current edge is occupied
                        lb $t0, ($s0)                            # Load current edge
                        bne $t0, 0x20, c_fml_next_col            # If it's not a space, skip


                        # Load arguments
                        move $a0, $s0                            # Set current addr index to arg 0
                         move $a1, $s1                           # Set current row index to arg 1
                         move $a2, $s2                           # Set current col index to arg 2

                         # Save both row and col size in a3
                         sll $a3, $s3, 8                         # Shift the row size to the left
                         addu $a3, $a3, $s4                      # Add the col to the shift

                         # Calculate the edges score
                        jal computer_get_edge_score

                        # Get output, compare, if current score is 1 and last is 2 return the 1
                        move $a0, $s5                            # Save the max to arg 0
                        move $a1, $v0                            # Save the current to arg 1
                        jal computer_compare_max_current_score   # Compare

                        # If new max is not equal to the old max
                        beq $v0, $s5, c_fml_next_col
                        move $s5, $v0                            # Save value
                        move $s6, $s1                            # Save row
                        move $s7, $s2                            # Save col

                # Go to next element
                c_fml_next_col:
                        addi $s2, $s2, 2   # Add two to the col
                        addi $s0, $s0, 2   # Add two to the index address

                        j c_fml_col        # Jump to next cell

        # Move to next row
        c_fml_next_row:
                addi $s1, $s1, 1   # Increment row
                j c_fml_row        # Jump to next row

        # Exit the loop
        c_fml_close:
                move $v0, $s7   # Return the col
                move $v1, $s6   # Return the row

                # Restore registers and the stack
                lw $ra, 0($sp)
                lw $s0, 4($sp)
                lw $s1, 8($sp)
                lw $s2, 12($sp)
                lw $s3, 16($sp)
                lw $s4, 20($sp)
                lw $s5, 24($sp)
                lw $s6, 28($sp)
                lw $s7, 32($sp)
                addi $sp, $sp, 36

                jr $ra          # Return


# Description: Uses the computer_find_max_loop subroutine to find and return
#              the best move for the computer to make. The move is returned
#              as column and row indices.
#
# Pseudo representation:
#     public computer_calculate_best_score(): int, int:
#         s0 = board_array
#         col, row = computer_find_max_loop
#         return col, row
#     end computer_calculate_best_score()
#
# Inputs:
#   None
# Outputs:
#   $a0 - current address index
#   $a1 - current row
#   $a2 - current col
#   $a3 - max row : max col
# Registers modified: $sp, $ra, $s0-$s5 (restored)
computer_get_edge_score:
        addi $sp, $sp, -28   # Make room in stack

        # Save save registers and return address
        sw $s5, 24($sp)
        sw $s4, 20($sp)
        sw $s3, 16($sp)
        sw $s2, 12($sp)
        sw $s1, 8($sp)
        sw $s0, 4($sp)
        sw $ra, 0($sp)

        # Save arguments
        move $s0, $a0        # index
        move $s1, $a1        # current row
        move $s2, $s2        # current col

        # Column size
        andi $s3, $a3, 0xFF

        # Row size
        srl $s4, $a3, 8

        # If current row is odd check left right boxes
        andi $t0, $s1, 0x01
        bne $t0, $zero, c_ges_left_right

        # Otherwise look up and down
        c_ges_top_down:
                # Reset score counter to 0
                li $s5, 0
                c_ges_check_top:
                        # If a top box doesn't exit jump to bottom
                        slti $t0, $s1, 2                     # Is row < 2
                        bne $t0, $zero, c_ges_check_bottom   # If so skip

                        # Get the far top edge
                        subu $t0, $s0, $s3
                        subu $a0, $t0, $s3

                        # Get the left and right
                        addi $a1, $t0, 1
                        subi $a2, $t0, 1

                        # Check the box
                        jal computer_check_box

                        # Add the boxes score to s5
                        add $s5, $s5, $v0

                        # If the score is 2, the opponent would have an advantage, move on
                        beq $s5, 2, c_ges_ct_throwing

                        # Otherwise check bottom
                        j c_ges_check_bottom

                        # Score is 2, set to 0 so it's still an option, but deprioritize it
                        c_ges_ct_throwing:
                                li $s5, 0
                                j c_ges_exit

                # Check the bottom box
                c_ges_check_bottom:
                        # Subtract 2 from max rows and make sure there's a bottom
                        subiu $t1, $s4, 2            # Subtract 2 from max rows
                        sgt $t0, $s1, $t1            # If current row is greater than that
                        bne $t0, $zero, c_ges_exit   # Exit

                        # Get far bottom edge
                        addu $t0, $s0, $s3
                        addu $a0, $t0, $s3

                        # Get left and right
                        addi $a1, $t0, 1
                        subi $a2, $t0, 1

                        # Get the boxes score and add it to the counter
                        jal computer_check_box
                        add $s5, $s5, $v0

                        # If the score is 2, the opponent would have an advantage, move on
                        beq $s5, 2, c_ges_cb_throwing

                        # If not just exit
                        j c_ges_exit

                        # Score is 2, set score to 0 and exit
                        c_ges_cb_throwing:
                                li $s5, 0


                        j c_ges_exit

        # Check the left and right boxes
        c_ges_left_right:
                # Reset score counter to 0
                li $s5, 0
                c_ges_check_right:
                        # If the right box doesn't exist, check left
                        subiu $t1, $s3, 2
                        sgt $t0, $s2, $t1
                        bne $t0, $zero c_ges_check_left

                        # Get far right edge
                        addi $a0, $s0, 2

                        # Check top and bottom edges in right
                        addi $a1, $s0, 1
                        subu $a1, $a1, $s3

                        addi $a2, $s0, 1
                        addu $a2, $a2, $s3

                        # Get the boxes score
                        jal computer_check_box
                        add $s5, $s5, $v0

                        # If the score is 2, the opponent would have an advantage, move on
                        beq $s5, 2, c_ges_cr_throwing

                        # If not check the left
                        j c_ges_check_left

                        # Score is 2, set score to 0 and exit
                        c_ges_cr_throwing:
                                li $s5, 0
                                j c_ges_exit

                c_ges_check_left:
                        # Check if left box exists
                        slti $t0, $s2, 2
                        bne $t0, $zero, c_ges_exit

                        # If it does get the far left edge
                        subi $a0, $s0, 2

                        # Get the top and bottom edges in the left box
                        subi $a1, $s0, 1
                        subu $a1, $a1, $s3

                        subi $a2, $s0, 1
                        addu $a2, $a2, $s3

                        # Get the boxes score
                         jal computer_check_box
                         add $s5, $s5, $v0

                        # If the score is 2, the opponent would have an advantage, move on
                         beq $s5, 2, c_ges_cl_throwing

                         # Otherwise exit
                         j c_ges_exit

                         # Score is 2, reset the score and exit
                         c_ges_cl_throwing:
                                 li $s5, 0

        # Exit the subroutine
        c_ges_exit:
                # Return the score
                move $v0, $s5

                # Restore registers and stack
                lw $ra, 0($sp)
                lw $s0, 4($sp)
                lw $s1, 8($sp)
                lw $s2, 12($sp)
                lw $s3, 16($sp)
                lw $s4, 20($sp)
                lw $s5, 24($sp)
                addi $sp, $sp, 28

                # Return
                jr $ra



# Description: Uses the passed addresses to check the provided edges. If an
#              edge is not a space, the score counter is incremented.
#
# Pseudo representation:
#     private computer_check_box(Edge *far, Edge *adjacent_1, Edge *adjacent_2): int:
#         int v0 = count = 0
#         if (&far != ' ') ++count
#         if (&adjacent_1 != ' ') ++count
#         if (&adjacent_2 != ' ') ++count
#         return count
#     end computer_check_box()
#
# Inputs:
#   $a0 - the far edges address
#   $a1 - the first adjacent edges address
#   $a2 - the second adjacent edges address
# Outputs:
#   $v0 - the boxes score count
# Registers modified: $sp, $ra
computer_check_box:
        addi $sp, $sp, -4   # Make room in stack
        sw $ra, 0($sp)      # Save return address

        # Initialize return counter to 0
        li $v0, 0

        # Check the far edge
        c_cb_far:
                # Load the byte in the address
                lb $t0, ($a0)

                # If it's not space ++v0
                seq $t0, $t0, 0x20              # Is char == ' '
                bne $t0, $zero, c_cb_adjacent   # If so skip
                addi $v0, $v0, 1                # Otherwise increment

        # Check the first adjacent
        c_cb_adjacent:
                # Load the byte in the address
                lb $t0, ($a1)

                # If it's not space ++v0
                seq $t0, $t0, 0x20   # Is char == ' '
                bne $t0, $zero, c_cb_next_adjacent
                addi $v0, $v0, 1     # Otherwise increment

        # Check the second adjacent
        c_cb_next_adjacent:
                # Load the byte in the address
                lb $t0, ($a2)

                # If it's not space ++v0
                seq $t0, $t0, 0x20          # Is char == ' '
                bne $t0, $zero, c_cb_exit   # If so skip
                addi $v0, $v0, 1            # Otherwise increment

        # Exit the subroutine
        c_cb_exit:
                lw $ra, 0($sp)     # Restore the return address
                addi $sp, $sp, 4   # Restore the stack

                jr $ra             # Return the counter



# Description: Compares the old maximum to the most recent calculated score
#
# Pseudo representation:
#     private computer_compare_max_current_score(int a0, int a1): int:
#         a0 = max
#         a1 = current
#
#         if (current - max > 0) return current
#
#         return max
#     end computer_compare_max_current_score()
#
# Inputs:
#   $a0 - the current maximum
#   $a1 - the most recent calculated score
# Outputs:
#   $v0 - the larger of the two
# Registers modified: None
computer_compare_max_current_score:
        # If the current is 6, return it, maximum score
        beq $a1, 6, c_cmcs_return_recent

        # Check if current is larger than max
        sub $t0, $a1, $a0                      # Subtract max from current
        bgt $t0, $zero, c_cmcs_return_recent   # If the result is > 0, current is larger

        # Result was not larger than 0, return max
        move $v0, $a0
        jr $ra

        # Current is larger return current
        c_cmcs_return_recent:
                move $v0, $a1
                jr $ra