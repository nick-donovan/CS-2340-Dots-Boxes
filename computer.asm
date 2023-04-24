# File: computer.asm
# Author: Advaith Sreeram, Hari Ramalingam
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for implementing the computer's strategy for selecting moves. 
#  Functions for choosing a random move, selecting the move that creates the most boxes, 
#  or using a more advanced algorithm to make smarter moves.
.data
	.globl computer_get_Index

.text

# Description: When given a set of coordinates corresponding to an index in the board, sees if that index is empty, and if so, adds 1 to the "fill" variable.
#
# Pseudo representation:
#	void edgeCheck(int index, int fill) {
#		if (board[index] != 0) {fill++;}
#	}
# Inputs:
#   $a0 - Index of the edge
#   $a1 - Fill variable to be updated
#
# Outputs:
#   None
# Registers modified: none

computer_edge_check:

	jal board_get_board	# Gets board into v0
		
	add $a0, $a0, $v0	# a0 = location of board[index]
	lb $a0, ($a0)		# a0 = board[index]
	
	seq $a0, $a0, 0x20	# a0 = (a0 == ' ')
	beq $a0, 1, computer_edge_check_exit # a0 == ' ' go to the exit
	addi $a1, $a1, 1 	# if board[index] != 0, fill++;
	
	computer_edge_check_exit:
	
	jr $ra 			# return
	

# Description: Returns the index of the array to access for a given set of coordinates.
#
# Pseudo representation:
#	int getIndex(int a, int b) { a is column (a0), b is row (a1)
# 		return a + (b*MAX_COL);
# 	}
# Inputs:
#   $a0 - Col index of the edge
#   $a1 - Row index of the edge
# Outputs:
#   $v0 - Index for the coordinates
# Registers modified: None 
computer_get_Index:

	addi $sp, -4 		# Make room in the stack
	sw $ra, 0($sp) 		# Save the return address
	
	jal board_get_column_size # v0 now holds the column size
	move $t5, $v0 		# t1 = column size
	
	add $t4, $zero, $a0 	# t4 = a
	mulu $t5, $t5, $a1 	# t5 = b * column size
	
	add $t4, $t4, $t5 	# a = a + b * (MAX_COL)
	add $v0, $zero, $t0
	
	lw $ra, 0($sp)          # Load return address
        addi $sp, $sp, 4        # Restore the stack

        jr $ra                  # Return
       
       
# Description: When given an edge coordinates, determines if it would be a bad idea to select that edge.
#
# Pseudo representation:
#	bool throwing(int arr[17][13], int a, int b) {
#
#	int filled = 0; //tells us how many other adjacent edges that could be used to make a box are filled in.
#
#	//Handle the edge cases (literally). 
#	//Top row: row = 0;
#	if (b == 0) {
#		checks bottom left and right edges tells you if you're throwing
#	}
#
#	//Bottom row; row = 12
#	else if (b == 12) {
#		checks top left and right edges tells you if you're throwing
#	}
#
#	//Left column; col = 0
#	else if (a == 0) {
#		checks top bottom and right edges tells you if you're throwing
#	}
#
#	//Right column; col = 16
#		checks top bottom and left edges tells you if you're throwing
#	}
#
#	//We are not on the edge of the board. Each of these edges connects TWO boxes. If either of them allows the player to finish a box, they are certified throwing, and we return true.
#	else {
#
#		//If b is even, it connects two boxes in the middle vertically.
#		if (b % 2 == 0) {
#			checks top box and bottom box, if either is throwing it tells you
#		}
#		//If b is odd, it connects two boxes in the middle horizontally.
#		else {
#			checks left box and right box, if either is throwing it tells you
#		}
#	}
#
#}
# Inputs:
#   $a0 - Col index of the edge
#   $a1 - Row index of the edge
# Outputs:
#   $v0 - 1 if you are throwing, 0 if you aren't throwing
# Registers modified: $s0 
computer_throwing:
	
	addi $sp, -4 		# Make room in the stack
	sw $ra, 0($sp) 		# Save the return address

	jal board_get_board
	move $s0, $v0 		# $s0 = the board array

	move $t0, $a0		# $t0 = a (Should not be manipulated, if you want to mess with the value, use a0)
	move $t1, $a1		# $t1 = b (Should not be manipulated, if you want to mess with the value, use a1)
	addi $t2, $t2, $zero	# $t2 = filled
	
	# $t6 = MAX_COLS - 1
	jal board_get_column_size
	move $t6, $v0
	subu $t6, $t6, 1
	
	# $t7 = MAX_ROWS - 1
	jal board_get_row_size
	move $t7, $v0
	subu $t7, $t7, 1
	
	# Handle edges. 
	beqz $t1, computer_throwing_top_row 		# Top edge: b = 0
	beq $t1, $t7, computer_throwing_bottom_row 	# Bottom edge: b = MAX_ROWS - 1
	beqz $t0, computer_throwing_left_col		# Left edge: a = 0
	beq $t0, $t6, computer_throwing_right_col	# Right edge: a = MAX_COLS - 1
	
	# If we're here, then there's two possibilities. Our edge either connects two boxes vertically or it connects them horizontally. If b is even, it's vertical, otherwise horizontal
	
	div $t1, 2 					# LO = t1 % 2.
	mflo $t3 					# t3 = t1 % 2
	
	beq $t3, 1, computer_throwing_horizontal_connection # If t3 = 1, b is odd and as a result we're connecting two boxes horizontally.
	j computer_throwing_vertical_connection 	# Otherwise, we're connecting two boxes vertically.
	

	
	
	computer_throwing_top_row:			# This handles the checking if the edge we're checking is in the top edge.
		
		# Left edge
		subi $a0, $t0, 1			# a = a-1
		addi $a1, $t1, 1			# b = b+1
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Right edge
		addi $a0, $t0, 1			# a = a+1, b doesn't change.
		jal computer_get_index			# v0 = the index we're trying to access
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Bottom edge
		addi $a0, $t0, $zero			# a = a
		addi $a1, $t1, 2			# b = b+2
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
				
		beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
		addi $v0, $zero, $zero			# If filled != 2, we aren't throwing by doing this, so we set our return to zero
		j computer_throwing_exit		# Go to return
		
	computer_throwing_bottom_row:			# This handles the checking if the edge we're checking is in the bottom edge.

		# Left edge
		subi $a0, $t0, 1			# a = a-1
		subi $a1, $t1, 1			# b = b-1
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Right edge
		addi $a0, $t0, 1			# a = a+1, b doesn't change.
		jal computer_get_index			# v0 = the index we're trying to access
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Top edge
		addi $a0, $t0, $zero			# a = a
		subi $a1, $t1, 2			# b = b-2
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
				
		beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
		addi $v0, $zero, $zero			# If filled != 2, we aren't throwing by doing this, so we set our return to zero
		j computer_throwing_exit		# Go to return
		
	computer_throwing_left_col:			# This handles the checking if the edge we're checking is in the left edge.
		
		# Top edge
		addi $a0, $t0, 1			# a = a+1
		subi $a1, $t1, 1			# b = b-1
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Bottom edge
		addi $a1, $t1, 1			# b = b+1, a doesn't change.
		jal computer_get_index			# v0 = the index we're trying to access
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Right edge
		addi $a0, $t0, 2			# a = a+2
		addi $a1, $t1, $zero			# b = b
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
				
		beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
		addi $v0, $zero, $zero			# If filled != 2, we aren't throwing by doing this, so we set our return to zero
		j computer_throwing_exit		# Go to return


	computer_throwing_right_col:			# This handles the checking if the edge we're checking is in the right edge.
	
		# Top edge
		subi $a0, $t0, 1			# a = a-1
		subi $a1, $t1, 1			# b = b-1
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Bottom edge
		addi $a1, $t1, 1			# b = b+1, a doesn't change.
		jal computer_get_index			# v0 = the index we're trying to access
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
		# Left edge
		subi $a0, $t0, 2			# a = a-2
		addi $a1, $t1, $zero			# b = b
		jal computer_get_index			# v0 = desired index
		
		move $a0, $v0				# Argument 1 = index
		addi $a1, $zero, $t2			# Argument 2 = filled
		jal computer_edge_check			# if board[index] != 0, a1++
		move $t2, $a1				# Move it back to the filled variable
		
				
		beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
		addi $v0, $zero, $zero			# If filled != 2, we aren't throwing by doing this, so we set our return to zero
		j computer_throwing_exit		# Go to return
	
	computer_throwing_vertical_connection:		# Handles an edge not on the outer edge of the board which connects two boxes vertically.
	

		computer_throwing_vertical_top:		# First, we'll do the top box. This label just exists to make indentation a lot easier to understand.
		
			# Left edge
			subi $a0, $t0, 1		# a = a-1
			subi $a1, $t1, 1		# b = b-1
			jal computer_get_index		# v0 = desired index
		
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Right edge
			addi $a0, $t0, 1		# a = a+1, b doesn't change.
			jal computer_get_index		# v0 = the index we're trying to access
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Top edge
			addi $a0, $t0, $zero		# a = a
			subi $a1, $t1, 2		# b = b-2
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
					
			beq $t2, 2, computer_throwing_yes # At this point, if filled = 2, we are throwing	
			addi $t2, $zero, $zero		# If we are not throwing, we set filled back to zero and move onto the bottom box.
			
		computer_throwing_vertical_bottom:	# Now we check the bottom box. This label just exists to make indentation a lot easier to understand.
		
			# Left edge
			subi $a0, $t0, 1		# a = a-1
			addi $a1, $t1, 1		# b = b+1
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Right edge
			addi $a0, $t0, 1		# a = a+1, b doesn't change.
			jal computer_get_index		# v0 = the index we're trying to access
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Bottom edge
			addi $a0, $t0, $zero		# a = a
			addi $a1, $t1, 2		# b = b+2
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
					
			beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
			addi $v0, $zero, $zero		# If filled != 2, we aren't throwing by doing this, so we set our return to zero
			j computer_throwing_exit	# Go to return
				
			
	computer_throwing_horizontal_connection:
	
		computer_throwing_horizontal_left:	# First, we'll do the left box. This label just exists to make indentation a lot easier to understand.
			
			# Top edge
			subi $a0, $t0, 1		# a = a-1
			subi $a1, $t1, 1		# b = b-1
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Bottom edge
			addi $a1, $t1, 1		# b = b+1, a doesn't change.
			jal computer_get_index		# v0 = the index we're trying to access
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Left edge
			subi $a0, $t0, 2		# a = a-2
			addi $a1, $t1, $zero		# b = b
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
					
			beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
			addi $t2, $zero, $zero		# If we are not throwing, we set filled back to zero and move onto the right box
			
		computer_throwing_horizontal_right:	# Now we check the right box. This label just exists to make indentation a lot easier to understand.
			
			# Top edge
			addi $a0, $t0, 1		# a = a+1
			subi $a1, $t1, 1		# b = b-1
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Bottom edge
			addi $a1, $t1, 1		# b = b+1, a doesn't change.
			jal computer_get_index		# v0 = the index we're trying to access
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			# Right edge
			addi $a0, $t0, 2		# a = a+2
			addi $a1, $t1, $zero		# b = b
			jal computer_get_index		# v0 = desired index
			
			move $a0, $v0			# Argument 1 = index
			addi $a1, $zero, $t2		# Argument 2 = filled
			jal computer_edge_check		# if board[index] != 0, a1++
			move $t2, $a1			# Move it back to the filled variable
			
			beq $t2, 2, computer_throwing_yes	# At this point, if filled = 2, we are throwing	
			addi $v0, $zero, $zero		# If filled != 2, we aren't throwing by doing this, so we set our return to zero
			j computer_throwing_exit	# Go to return
	
	computer_throwing_yes: 				# Yes, you are indeed throwing
	addi $v0, $zero, 1				# We will return 1
	j computer_throwing_exit			# Go to exit
	
	computer_throwing_exit:
	
        lw $ra, 0($sp)          			# Load return address
        addi $sp, $sp, 4        			# Restore the stack

        jr $ra                  			# Return	