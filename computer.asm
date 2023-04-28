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

main:
	jal board_initialize_board

	jal test_init	

	jal computer_calculate_best_score
	move $a0, $v0
	li $v0, 1
	syscall
	
	jal print_break
	
	move $a0, $v1
	li $v0, 1
	syscall

	jal board_print_board

	
	j exit
	
computer_calculate_best_score:
	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	la $s0, board_array
	
	move $a0, $s0
	jal computer_find_max_loop 
	
	c_fb_finish:
			
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		addi $sp, $sp, 8
		
		jr $ra
	
# a0 board address
computer_find_max_loop:
	addi $sp, $sp, -36
	sw $s7, 32($sp)
	sw $s6, 28($sp)
	sw $s5, 24($sp)
	sw $s4, 20($sp)
	sw $s3, 16($sp)	
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	# Index address
	move $s0, $a0
	addi $s0, $s0, 1

	# Row index
	li $s1, 0
	
	# Col index
	li $s2, 0
	
	# Save row size
	lb $s3, board_row_size
	
 	# Save column size 
	lb $s4, board_column_size
	
	# Save highest score
	li $s5, -1
	
	# Save highest row
	li $s6, -1
	
	# Save highest column
	li $s7, -1

	c_fml_row: 
		sge $t0, $s1, $s3
		bne $t0, $zero, c_fml_close
		
		andi $t0, $s1, 0x01
		bne $t0, $zero, c_fml_odd_row
		li $s2, 1
		j c_fml_col
		
		c_fml_odd_row: 
			li $s2, 0
		
		c_fml_col:
			sge $t0, $s2, $s4
			bne $t0, $zero, c_fml_next_row
			
			lb $t0, ($s0)
			bne $t0, 0x20, c_fml_next_col
			
			move $a0, $s0
		 	move $a1, $s1
		 	move $a2, $s2
		 	
		 	# Save both row and col size in a3
		 	sll $a3, $s3, 8
		 	addu $a3, $a3, $s4
		 	
			jal computer_get_edge_score
			
			move $a0, $v0
			li $v0, 1
			syscall
			move $v0, $a0
			
			# Get output, compare, if current score is 1 and last is 2 return the 1
			move $a0, $s5
			move $a1, $v0
			jal computer_compare_max_current_score
			
			beq $v0, $s5, c_fml_next_col
			move $s5, $v0
			move $s6, $s1
			move $s7, $s2
			
			
		c_fml_next_col:
			addi $s2, $s2, 2
			addi $s0, $s0, 2
			
			j c_fml_col	

	c_fml_next_row:
		addi $s1, $s1, 1
		j c_fml_row

	c_fml_close:
		jal print_break
		move $v0, $s7
		
		move $v1, $s6
		
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

		jr $ra 

# a0 - index
# a1 - current row
# a2 - current col
# a3 - max row : max col
computer_get_edge_score:
	addi $sp, $sp, -28
	sw $s5, 24($sp)
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)

	move $s0, $a0 # index
	move $s1, $a1 # current row
	move $s2, $s2 # current col
	
	# Column size
	andi $s3, $a3, 0xFF

	# Row size
	srl $s4, $a3, 8

	# Score increment


	andi $t0, $s1, 0x01
	bne $t0, $zero, c_ges_left_right
	
	c_ges_top_down:
		li $s5, 0
		c_ges_check_top:
			slti $t0, $s1, 2
			bne $t0, $zero, c_ges_check_bottom
			
			subu $t0, $s0, $s3
			subu $a0, $t0, $s3
			
			addi $a1, $t0, 1
			subi $a2, $t0, 1
			
			jal computer_check_box
			add $s5, $s5, $v0
			
			beq $s5, 2, c_ges_ct_throwing
			
			j c_ges_check_bottom
			
			c_ges_ct_throwing:
				li $s5, 0
				j c_ges_exit
		
		c_ges_check_bottom:
			subiu $t1, $s4, 2
			sgt $t0, $s1, $t1
			bne $t0, $zero, c_ges_exit
			
			addu $t0, $s0, $s3
			addu $a0, $t0, $s3
			
			addi $a1, $t0, 1
			subi $a2, $t0, 1
		
			jal computer_check_box
			add $s5, $s5, $v0
			
			beq $s5, 2, c_ges_cb_throwing
			
			j c_ges_exit
			
			c_ges_cb_throwing:
				li $s5, 0
			
			
			j c_ges_exit
	
	c_ges_left_right:
		li $s5, 0
		c_ges_check_right:
			subiu $t1, $s3, 2
			sgt $t0, $s2, $t1
			bne $t0, $zero c_ges_check_left
			
			addi $a0, $s0, 2
	
			addi $a1, $s0, 1
			subu $a1, $a1, $s3
			
			addi $a2, $s0, 1
			addu $a2, $a2, $s3
			
			jal computer_check_box
			add $s5, $s5, $v0
			
			
			beq $s5, 2, c_ges_cr_throwing
			
			j c_ges_check_left
			
			c_ges_cr_throwing:
				li $s5, 0
				j c_ges_exit			
			
		c_ges_check_left:
			slti $t0, $s2, 2
			bne $t0, $zero, c_ges_exit
			
			subi $a0, $s0, 2
			
			subi $a1, $s0, 1
			subu $a1, $a1, $s3
			
			subi $a2, $s0, 1
			addu $a2, $a2, $s3
		
	 		jal computer_check_box
	 		add $s5, $s5, $v0
	 		
	 		beq $s5, 2, c_ges_cl_throwing
	 		
	 		j c_ges_exit
	 		
	 		c_ges_cl_throwing:
	 			li $s5, 0
	 		
	c_ges_exit:
		move $v0, $s5
	
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		addi $sp, $sp, 28
		
		jr $ra
		
		
# a0 far edge
# a1 adjacent edge 1
# a2 adjacent edge 2
computer_check_box:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $v0, 0
	
	c_cb_far:
		lb $t0, ($a0)

		seq $t0, $t0, 0x20
		bne $t0, $zero, c_cb_adjacent			
		addi $v0, $v0, 1
	
	c_cb_adjacent:
		lb $t0, ($a1)
		
		seq $t0, $t0, 0x20
		bne $t0, $zero, c_cb_next_adjacent
		addi $v0, $v0, 1
		
	c_cb_next_adjacent:
		lb $t0, ($a2)

		seq $t0, $t0, 0x20
		bne $t0, $zero, c_cb_exit
		addi $v0, $v0, 1
		
	c_cb_exit:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	
	

# a0 - the current max
# a1 - the recent score
computer_compare_max_current_score:
	# Get output, compare, if current score is 1 and last is 2 return the 1
	beq $a1, 6, c_cmcs_return_recent
	
	
		sub $t0, $a1, $a0
		bgt $t0, $zero, c_cmcs_return_recent
	

		move $v0, $a0
		jr $ra
	
	c_cmcs_return_recent:
		move $v0, $a1
		jr $ra

computer_submit_move:
	li $t0, 'X'
#	

	
	jr $ra
	


test_init:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	

	li $a0, 1
	li $a1, 0
	li $a2, 0
	# jal board_update_edge
	
	li $a0, 0
	li $a1, 1
	li $a2, 0
	jal board_update_edge
	
	li $a0, 1
	li $a1, 2
	li $a2, 0
	jal board_update_edge
	
	li $a0, 3
	li $a1, 0
	li $a2, 1
	jal board_update_edge
	
	li $a0, 3
	li $a1, 2
	li $a2, 1
	jal board_update_edge
	
	li $a0, 4
	li $a1, 1
	li $a2, 1
	jal board_update_edge
	
	li $a0, 13
	li $a1, 0
	li $a2, 1
	jal board_update_edge
	
	li $a0, 14
	li $a1, 1
	li $a2, 1
	jal board_update_edge
	
	li $a0, 12
	li $a1, 1
	li $a2, 1
	jal board_update_edge
	
	li $a0, 14
	li $a1, 3
	li $a2, 0
	jal board_update_edge
	
	li $a0, 13
	li $a1, 4
	li $a2, 0
	# jal board_update_edge
	
	li $a0, 12
	li $a1, 3
	li $a2, 0
	jal board_update_edge
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
