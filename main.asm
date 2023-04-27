# File: main.asm
# Author: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for tying everything together and running the game loop. Functions 
#  for initializing the game, running the game loop, and displaying the final score and winner 
#  at the end of the game.
.data
        .globl print_string
        .globl print_int
        .globl print_char
        .globl print_break
        .globl exit

.text
main:

        jal board_initialize_board
        
	jal score_test_init
	jal score_test
	move $s0, $v0
	
	jal board_print_board
	
	move $a0, $s0
	jal print_int
        
        # jal game_loop

	# jal score_print_final_scores
        
        j exit

game_loop: # THIS IS JUST A DRAFT, CHANGE IT TO HOW THE IMPLEMENTATION IS DONE -ND
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal board_print_board
	
	jal input_get_user_input
	move $a0, $v0   # X index to change
        move $a1, $v1   # Y Index to change
        li $a2, 0       # 0 is player, 1 is Computer
        jal board_update_edge  # update edge
        
        # jal computer_get_computer_move
        # move $a0, $v0   # X index to change
        # move $a1, $v1   # Y Index to change
        # li $a2, 1       # 0 is player, 1 is Computer
        # jal board_update_edge  # update edge
        
        # jal score_update_score
        
        # jal score_is_game_over
        # beq $v0, $zero, game_loop
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        jr $ra
        
# Description: Prints a string to stdout.
#
# Inputs: 
#   $a0 - the string to print
# Outputs:
#   None
# Registers modified: None
print_string:
        li $v0, 4
        syscall
        jr $ra
        
# Description: Prints an int to stdout.
#
# Inputs: 
#   $a0 - the int to print
# Outputs:
#   None
# Registers modified: None
print_int:
        li $v0, 1
        syscall
        jr $ra

# Description: Prints a char to stdout.
#
# Inputs: 
#   $a0 - the char to print
# Outputs:
#   None
# Registers modified: None 
print_char:
        li $v0, 11
        syscall
        jr $ra

# Description: Prints a new line to stdout.
#
# Inputs: 
#   None
# Outputs:
#   None
# Registers modified: None    
print_break:
        li $a0, '\n'
        li $v0, 11
        syscall
        jr $ra
        
        

# Description: Exits the program.
#
# Inputs: 
#   None
# Outputs:
#   None
# Registers modified: None  
exit:
        li $v0, 10                   # Syscall for program term
        syscall                      # Exit program


score_test_init:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $a0, 1
	li $a1, 0
	li $a2, 0
	jal board_update_edge
	
	li $a0, 1
	li $a1, 4
	li $a2, 0
	jal board_update_edge
	
	li $a0, 1
	li $a1, 2
	li $a2, 0
	jal board_update_edge
	
	li $a0, 0
	li $a1, 1
	li $a2, 0
	jal board_update_edge
	
	li $a0, 2
	li $a1, 1
	li $a2, 1
	jal board_update_edge
	
	li $a0, 2
	li $a1, 3
	li $a2, 1
	jal board_update_edge
	
	li $a0, 0
	li $a1, 3
	li $a2, 1
	jal board_update_edge
	
	li $a0, 5
	li $a1, 2
	li $a2, 1
	jal board_update_edge
	
	li $a0, 4
	li $a1, 3
	li $a2, 1
	jal board_update_edge
	
	li $a0, 6
	li $a1, 3
	li $a2, 1
	jal board_update_edge
	
	li $a0, 5
	li $a1, 4
	li $a2, 1
	jal board_update_edge
	
	##
	
	li $a0, 15
	li $a1, 12
	li $a2, 0
	jal board_update_edge
	
	li $a0, 15
	li $a1, 10
	li $a2, 1
	jal board_update_edge
	
	li $a0, 16
	li $a1, 11
	li $a2, 1
	jal board_update_edge
	
	li $a0, 14
	li $a1, 11
	li $a2, 1
	jal board_update_edge
	
	li $a0, 15
	li $a1, 12
	li $a2, 1
	jal board_update_edge
	
	##
	 
	li $a0, 9
	li $a1, 12
	li $a2, 0
	jal board_update_edge
	
	li $a0, 9
	li $a1, 10
	li $a2, 1
	jal board_update_edge
	
	li $a0, 10
	li $a1, 11
	li $a2, 1
	jal board_update_edge
	
	li $a0, 8
	li $a1, 11
	li $a2, 1
	jal board_update_edge
	
	li $a0, 9
	li $a1, 12
	li $a2, 1
	jal board_update_edge
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

score_test:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	#input  $a0 $a1 x y cooards for edge that was placed  $a2-current player value, $a3-current player score 
	#output $v0 next player value, $v1 current player score (after edge placed)

	li $s6, 0 # comp score
	
	li $s0, 96
	li $s1, 97
	li $s2, 98

	
	# Test double
	li $a0, 1
	li $a1, 2
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	# Test vert
	li $a0, 4
	li $a1, 3
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
		
	# Test horiz
	li $a0, 5
	li $a1, 4
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	# Test top edge
	li $a0, 1
	li $a1, 0
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	# Test left edge
	li $a0, 0
	li $a1, 1
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	# Test right edge
	li $a0, 16
	li $a1, 11
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	# Test bottom edge
	li $a0, 9
	li $a1, 12
	li $a2, 0
	move $a3, $s6
	jal score_update_score
	move $s6, $v1
	
	move $v0, $s6
	
	
	lw $ra, 0($sp)########################
	addi $sp, $sp, 4
	
	jr $ra