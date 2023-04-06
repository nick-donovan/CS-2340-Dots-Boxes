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

.text
main:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        jal board_initialize_board
        jal board_print_board
        
        jal input_get_user_input
        
        move $a0, $v0   # X index to change
        move $a1, $v1   # Y Index to change
        li $a2, 0       # 0 is player, 1 is Computer
        jal board_update_edge  # update edge
        
        jal board_print_board
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        j exit
          
exit:
        li $v0, 10                   # Syscall for program term
        syscall                      # Exit program

        
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
