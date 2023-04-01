# File: main.asm
# Author: Nicholas Donovan
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for tying everything together and running the game loop. Functions 
#  for initializing the game, running the game loop, and displaying the final score and winner 
#  at the end of the game.

.text
main:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        jal initializeBoard
        jal printBoard
        
        li $a0, 3       # X index to change
        li $a1, 4       # Y Index to change
        li $a2, 0       # 0 is player, 1 is Computer
        jal updateEdge  # update edge
        
        jal printBoard
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        j exit
          
exit:
        li $v0, 10                   # Syscall for program term
        syscall                      # Exit program
