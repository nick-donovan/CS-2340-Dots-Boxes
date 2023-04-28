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
        
        #jal score_test_init
        #jal score_test
        
        #jal test_init

        #jal board_print_board
        
                                
        jal game_loop

        # jal score_print_final_scores
        
        j exit

game_loop: # THIS IS JUST A DRAFT, CHANGE IT TO HOW THE IMPLEMENTATION IS DONE -ND
        addi $sp, $sp, -4
        
        sw $ra, 0($sp)
        
        li $s5, 0
        li $s6, 0
        
        li $s7, 0

        m_gl_start: 
            jal board_print_board
            
            bne $s7, $zero, m_gl_computer_turn
            m_gl_user_turn:
                jal input_get_user_input
                move $s3, $v0
                move $s4, $v1
                
                move $a0, $v0   # X index to change
                move $a1, $v1   # Y Index to change
                li $a2, 0       # 0 is player, 1 is Computer
                jal board_update_edge  # update edge 
                
                #input  $a0 $a1 x y cooards for edge that was placed  $a2-current player value, $a3-current player score
                #output $v0 next player value, $v1 current player score (after edge placed)
                move $a0, $s3 # Last placed X
                move $a1, $s4 # Last placed Y
		move $a2, $s7 # Player value
                move $a3, $s5 # Player Score
                jal score_update_score
                move $s7, $v0 ###############################
                move $s5, $v1 # Save score
                
                addu $t0, $s5, $s6
		bne $t0, 48, m_gl_start
                
                j m_gl_exit
            
            m_gl_computer_turn:
                jal computer_calculate_best_score
                move $s3, $v0
                move $s4, $v1
                
                move $a0, $s3   # X index to change 
                move $a1, $s4   # Y Index to change
                li $a2, 1      # 0 is player, 1 is Computer
                jal board_update_edge  # update edge
                
                move $a0, $s3 # Last x (col)
                move $a1, $s4 # Last y (row)
		move $a2, $s7 # Player 
                move $a3, $s6 # PC Score
                jal score_update_score
		move $s7, $v0 #####################################
                move $s6, $v1
                
                
	            move $a0, $s5
        	    li $v0, 1
	            syscall
            
	            jal print_break
            
	            move $a0, $s6
	            li $v0, 1
        	    syscall
            
	            jal print_break
	            
	            addu $t0, $s5, $s6
	            bne $t0, 48, m_gl_start
                
                j m_gl_exit
            
            
            
            
            
        m_gl_exit:

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

