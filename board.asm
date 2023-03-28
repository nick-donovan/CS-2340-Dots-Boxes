# File: board.asm
# Author: Nicholas Donovan [ADD YOUR NAMES HERE IF YOU WORK ON IT]
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for creating, updating, and displaying the game board. Will contain 
#  functions for initializing the board, updating the state of the board after a move is made, 
#  and printing the board to the console.

# I'll add comments to this later -ND

.data
	boardRowSize: .byte 11
	boardColumnSize: .byte 15
	boardSymbolChar: .byte '+'
	spaceChar: .byte ' '
	boardArray: .space 165
	boardArraySize: .half 165
	boardHeaderString: .asciiz "   A B C D E F G H I J K L M N O \n   -----------------------------\n"
	
.text
main:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal initializeBoard
	jal printBoard
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	j Exit

initializeBoard:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $a1, 28($sp)

	la $a1, boardArray
	la $t0, boardRowSize	# Load row size address == 11
	lb $t0, ($t0)				# Set row size to $t0
	la $t1, boardColumnSize  			# Load row size address == 15
	lb $t1, ($t1)				# set col size to $t1
	li $t2, 0      				# Row counter
	li $t3, 0					# Column counter
	
	
initializeBoardRowLoop:
	blt $t2, $t0, initializeBoardInnerLoopStart 
	j initializeBoardExit

initializeBoardInnerLoopStart:
	li $t3, 0
	
initializeBoardInnerLoop:
	blt $t3, $t1, initializeBoardChar
	j initializeBoardInnerLoopEnd
	
initializeBoardChar:
	mul $t4, $t2, $t1
	add $t4, $t4, $t3
	add $t4, $a1, $t4
	
	andi $t5, $t2, 0x01
	bnez $t5, loadSpace
	
	andi $t5, $t3, 0x01 # Check if col is even
	bnez $t5, loadSpace
	
	addi $t3, $t3, 1 # increment counter
	
	lb $t5, boardSymbolChar                 # Symbol char == '+'
	j initializeBoardAddChar
	
loadSpace:
	addi $t3, $t3, 1 # increment counter
	lb $t5, spaceChar
	
initializeBoardAddChar:
	sb $t5, ($t4)
	j initializeBoardInnerLoop
	
initializeBoardInnerLoopEnd:
	addi $t2, $t2, 1
	j initializeBoardRowLoop
	
initializeBoardExit:
	lw $a1, 28($sp)
	lw $t5, 24($sp)
	lw $t4, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 32

	jr $ra

printBoard:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t5, 20($sp)
	sw $a1, 24($sp)
		
	la $a1, boardArray			# Load address of boardArray
	la $t0, boardRowSize			# Load row size address
	lb $t0, ($t0)				# Set row size to $t0
	la $t1, boardColumnSize     		# Load row size address
	lb $t1, ($t1)				# set col size to $t1
	li $t2, 0      				# Row counter
	li $t3, 0				# Column counter
	li $t4, 1				# Row num counter

	la $a0, boardHeaderString
	li $v0, 4
	syscall

		
printBoardOuter:
	blt $t2, $t0, printBoardInnerLoopStart #
	j printBoardExit
	
printBoardInnerLoopStart:
	li $t3, 0
	
	addi $a0, $t2, 1
	li $v0, 1
	syscall
	li $a0, ' '
	li $v0, 11
	syscall
	
	slti $t5, $t2, 9
	beq  $t5, $0, printBoardInnerLoop
	
	li $v0, 11
	syscall
	
printBoardInnerLoop:	
	blt $t3, $t1, printBoardChar
	j printBoardInnerLoopEnd
	
printBoardChar:
	mul $t5, $t2, $t1
	add $t5, $t5, $t3
	add $t5, $a1, $t5

	lb $a0, ($t5)
	li $v0, 11
	syscall
	
	li $a0, ' '
	li $v0, 11
	syscall
	
	addi $t3, $t3, 1
	
	j printBoardInnerLoop
	
printBoardInnerLoopEnd:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	addi $t2, $t2, 1
	
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	j printBoardOuter
	
printBoardExit:

	lw $a1, 24($sp)
	lw $t5, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 28
	
	jr $ra
	
Exit:
	li $v0, 10
	syscall

