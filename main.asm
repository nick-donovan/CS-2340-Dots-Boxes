# File: main.asm
# Author: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for tying everything together and running the game loop. Functions 
#  for initializing the game, running the game loop, and displaying the final score and winner 
#  at the end of the game.
.data
	player_wins: .asciiz "You win!"
	computer_wins: .asciiz "The computer won!"
	tie: .asciiz "It's a tie!"
	player_string: .asciiz "Player Score: "
	computer_string: .asciiz "Computer Score: "
        .globl print_string
        .globl print_int
        .globl print_char
        .globl print_break
        .globl exit

.text
main:
	# Set up a new board
        jal board_initialize_board
                            
	# Start the game    
        jal main_game_loop
	
	# Print the final scores and winner
	move $a0, $v0
	move $a1, $v1
	jal main_print_final_scores
        
        j exit

# Description: Drives the game play in a loop until the maximum score is 
#              reached, responsible for retrieving user and computer input 
#              and tracking the score.
#
# Pseudo representation:
#     private main_game_loop(): int, int:
#         int user_score = 0
#         int computer_score = 0
#         boolean current_player = 0
#         
#         while (user_score + computer_score != 48):
#             board_print_board()
#             if (!current_player):
#                 col, row = input_get_user_input()
#                 board_update_edge(col, row, current_player)
#                 current_player, user_score = score_update_score(col, row, 
#                                                         current_player, user_score)
#             else:
#                 col, row = computer_calculate_best_score()
#                 board_update_edge(col, row, current_player)
#                 current_player, computer_score = score_update_score(col, row, 
#                                                         current_player, computer_score)
#     end main_game_loop()
#
# Inputs:
#   None
# Outputs:
#   $v0 - the final user score
#   $v1 - the final computer score
# Registers modified: $sp, $ra, $s3 - $s7 (restored)
main_game_loop: 
	# Make room in stack
        addi $sp, $sp, -24
        
        # Save registers
	sw $s7, 20($sp)
	sw $s6, 16($sp)
	sw $s5, 12($sp)
	sw $s4, 8($sp)
	sw $s3, 4($sp) 
        sw $ra, 0($sp)
        
        li $s5, 0 # The user score
        li $s6, 0 # The computer score
        
        li $s7, 0 # Tracks which players turn it is

	# Start the loop
        m_gl_start: 
        	# Print the board
                jal board_print_board
            
            	# If the player isn't zero, it's the computers turn
                bne $s7, $zero, m_gl_computer_turn
                
                # Otherwise it's the players turn
                m_gl_user_turn:
                	# Get user input from console
                        jal input_get_user_input # Get input
                        move $s3, $v0 # Save col
                        move $s4, $v1 # Save row
                
                	# Update the selected edge on the board
                        move $a0, $v0   # X index to change
                        move $a1, $v1   # Y Index to change
                        li $a2, 0       # 0 is player, 1 is Computer
                        jal board_update_edge  # update edge 
                
                        # Update the score
                        move $a0, $s3 # Last placed X
                        move $a1, $s4 # Last placed Y
                        move $a2, $s7 # Player value
                        move $a3, $s5 # Player Score
                        jal score_update_score
                        move $s7, $v0 # Save the next turn
                        move $s5, $v1 # Save score
                
                	# If the total score is 48, the game is over break
                        addu $t0, $s5, $s6 # Is sum equal to 48
                        bne $t0, 48, m_gl_start # If not go again
                	
                	# Otherwise exit
                        j m_gl_exit
            
            	# For the computers turn
                m_gl_computer_turn:
                
                	# Calculate the computers next move
                        jal computer_calculate_best_score # Calculate move
                        move $s3, $v0 # Save col
                        move $s4, $v1 # Save row
                        
                        # Update the edge on the board
                        move $a0, $s3   # X index to change 
                        move $a1, $s4   # Y Index to change
                        li $a2, 1      # 0 is player, 1 is Computer
                        jal board_update_edge  # update edge
                        
                        # Update the score
                        move $a0, $s3 # Last x (col)
                        move $a1, $s4 # Last y (row)
                        move $a2, $s7 # Player 
                        move $a3, $s6 # PC Score
                        jal score_update_score
                        move $s7, $v0 # Save the next players turn
                        move $s6, $v1 # Save the new score
                    
                    	
                        # If the total score is 48, the game is over break
                        addu $t0, $s5, $s6 # Is sum equal to 48
                        bne $t0, 48, m_gl_start # If not go again
                	
                	# Otherwise exit
                        j m_gl_exit
            
        # Exit the main game loop
        m_gl_exit:
        	# Return the scores
        	move $v0, $s5 # Return user score
        	move $v1, $s6 # Return computer score
        	
        	# Restore the registers and stack
                lw $ra, 0($sp)
                lw $s3, 4($sp)
                lw $s4, 8($sp)
                lw $s5, 12($sp)
                lw $s6, 16($sp)
                lw $s7, 20($sp)
                addi $sp, $sp, 24
        
        	# Return
                jr $ra
                
# Description: Prints the game winner and the final scores
#
# Pseudo representation:
#     private main_print_final_scores(int a0, int a1): 
#         user_score = a0
#         computer_score = a1
#         if (user_score == computer_score) 
#             print(tie_string)
#         else if (user_score < computer_score)
#             print(computer_wins)
#         else
#             print(player_wins)
#             
#         print(user_score)
#         print(computer_score)
#     end main_print_final_scores()
#
# Inputs:
#   $a0 - the players score
#   $a1 - the computers score
# Outputs:
#   None
# Registers modified: $sp, $ra
main_print_final_scores:
	addi $sp, $sp, -4 # Make room in stack
	sw $ra, 0($sp) # Save return address

	# Save the scores
	move $t0, $a0
	move $t1, $a1

	# Compare the user score to the computer score
	sub $t0, $a0, $a1 # Subtract computer score from user
	beq $t0, $zero, m_pfs_equal # If it's 0, it's a tie
	blt $t0, $zero, m_pfs_computer # If it's less than, the computer won
	
	# Player wins
	la $a0, player_wins # Load address for player wins string
	jal print_string # Print string
	j m_pfs_exit # Exit
	
	m_pfs_equal:
		# It's a tie
		la $a0, tie # Load address for tie string
		jal print_string # Print string
		j m_pfs_exit # Exit
		
	m_pfs_computer:
		# Computer wins
		la $a0, computer_wins # Load address for computer wins string
		jal print_string # Print String
		
	m_pfs_exit:
		# Print the player score
		la $a0, player_string # Load the player string
		jal print_string # print the string
		move $a0, $t0 # Load the players score
		jal print_int # Print the players score
		
		# Print a line break
		jal print_break
		
		la $a0, computer_string # Load the computer string
		jal print_string # Print the string
		move $a0, $t1 # Load the computer score
		jal print_int # Print the player score
	
		lw $ra, 0($sp) # Restore the return address
		addi $sp, $sp, 4 # Restore the stack
		
		jr $ra # Return
        
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