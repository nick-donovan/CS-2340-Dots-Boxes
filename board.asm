# File: board.asm
# Authors: Nicholas Donovan [ADD YOUR NAMES HERE IF YOU WORK ON IT]
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for creating, updating, and displaying the game board. Will contain 
#  functions for initializing the board, updating the state of the board after a move is made, 
#  and printing the board to the console.

# I'll add comments to this later -ND

.data
        boardRowSize:      .byte 11
        boardColumnSize:   .byte 15
        boardSymbolChar:   .byte '+'
        spaceChar:         .byte ' '
        boardArray:        .space 165
        boardArraySize:    .half 165
        boardHeaderString: .asciiz "   A B C D E F G H I J K L M N O \n   -----------------------------\n"
        .globl printBoard
        .globl initializeBoard
        .globl updateEdge
        
.text
main:
	jal initializeBoard
	jal printBoard

        li $v0, 10
        syscall

# Description: Initializes the game board with the boardSymbolChar as dots 
#              and spaces for empty areas.
#
# Pseudo representation:
#     public void initializeBoard():
#         for(int row = 0; row < boardRowSize; ++row):
#         	for (int col = 0; col < boardColumnSize; ++col):
#         	    if (row.isEven() && col.isEven()):
#         	        boardArray[row][col] = boardSymbolChar
#         	    else
#         	        boardArray[row][col] = ' '
#         	end for
#         end for
#     end initializeBoard
#
# Inputs: 
#   None
# Outputs:
#   None - Initialized board is saved in memory
# Registers modified: None
initializeBoard:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        la $t0, boardArray       # Load address of the array into $t0
        la $t1, boardRowSize     # Load rowSize address into $t1
        lb $t1, ($t1)            # Set $t1 to rowSize integer
        la $t2, boardColumnSize  # Load colSize address into $t2
        lb $t2, ($t2)            # Set $t2 to colSize integer 
        li $t3, 0                # Initialize row index to 0 (int row = 0)
        
        # Loop through each row of the game board
        iBRowLoop:
                slt $t5, $t3, $t1      # Is row < boardRowSize
                beq $t5, $zero, iBExit # If not, exit
                
                li $t4, 0              # Set col index to 0 (int col = 0)

                # Loop through each column of the game board
                iBColLoop:
                        slt $t5, $t4, $t2            # Is col < boardColumnSize
                        beq $t5, $zero, iBColLoopEnd # If not, move to next row

                        # Check if current position is even
                        andi $t5, $t3, 0x01          # Use AND to check if row index is even
                        bnez $t5, loadSpace          # Jump to loadSpace if row index is odd

                        andi $t5, $t4, 0x01          # Use AND to check if col index is even
                        bnez $t5, loadSpace          # Jump to loadSpace if col index is odd

                        lb $t6, boardSymbolChar      # Load boardSymbolChar into $t6

                        j iBInsertChar               # Insert into the game board array
 
                        
                        loadSpace:
                                lb $t6, spaceChar    # Load the space character into $t6

                        # Insert the loaded symbol into the game board array
                        iBInsertChar:
                                mul $t5, $t3, $t2    # Calculate the index of the current position on the game board array
                                add $t5, $t5, $t4
                                add $t5, $t5, $t0    # Add the address of the game board to the index

                                sb $t6, ($t5)        # Insert the loaded char into the game board array

                        addi $t4, $t4, 1             # Increment col index

                        j iBColLoop                  # Move to next element

                # End of the column loop
                iBColLoopEnd:
                        addi $t3, $t3, 1             # Increment row index
                        j iBRowLoop                  # Move to next row

        iBExit:
                lw $ra, 0($sp)                       # Load return address from stack
                addi $sp, $sp, 4                     # Free up stack space

                jr $ra                               # Return
        
printBoard:
        addi $sp, $sp, -4           # Make room in stack
        sw $ra, 0($sp)              # Store return address in stack
                
        la $t0, boardArray          # Load address of the array into $t0
        la $t1, boardRowSize        # Load rowSize address into $t1
        lb $t1, ($t1)               # Set $t1 to rowSize integer
        la $t2, boardColumnSize     # Load colSize address into $t2
        lb $t2, ($t2)               # Set $t2 to colSize integer
        li $t3, 0                   # Initialize row index to 0
        li $t4, 0                   # Initialize col index to 0 (not needed here but helps know which reg it's in)

        la $a0, boardHeaderString   # Load address for boardHeaderString
        li $v0, 4                   # Syscall for print string
        syscall                     # Print boardHeaderString

                
        printBoardRowLoop:
                blt $t3, $t1, printBoardColumnLoopStart # If row index is less than the amount of rows, loop column
                j printBoardExit                        # Else, exit the loop
                
                printBoardColumnLoopStart:
                        li $t4, 0                          # Set Col index to 0
                        
                        addi $a0, $t3, 1                   # Set the row counter to index + 1
                        li $v0, 1                          # Syscall for print integer
                        syscall                            # Print row counter
                        
                        li $a0, ' '                        # Load a space into a0
                        li $v0, 11                         # Syscall for printing a character
                        syscall                            # Print the space
                        
                        slti $t5, $t3, 9                   # If row index is not less than 9
                        beq  $t5, $0, printBoardColumnLoop # Skip the second space (alignment)
                        
                        li $v0, 11                         # Syscall for printing a character
                        syscall                            # Print another space
                        
                printBoardColumnLoop:        
                        blt $t4, $t2, printBoardChar # If column index is less than total columns, print the row
                        j printBoardColumnLoopEnd    # Else end the column loop
                        
                printBoardChar:
                        mul $t5, $t3, $t2            # Multiply the row we're on by total columns
                        add $t5, $t5, $t4            # Add column index to $t5 to get current element index
                        add $t5, $t0, $t5            # Set $t5 to current cell address in array

                        lb $a0, ($t5)                # Load the current array element into $a0
                        li $v0, 11                   # Syscall for printing a char
                        syscall                      # Print the current element
                        
                        li $a0, ' '                  # Load a space into $a0
                        li $v0, 11                   # Syscall for printing a character
                        syscall                      # Print a space
                        
                        addi $t4, $t4, 1             # Increment the column index
                        
                        j printBoardColumnLoop       # Move to next cell
                        
                printBoardColumnLoopEnd:        
                        li $a0, '\n'                 # Load a new line into $a0
                        li $v0, 11                   # Syscall for printing a character
                        syscall                      # Print a new line
                        
                        addi $t3, $t3, 1             # Increment the row index
                        
                        j printBoardRowLoop          # Move on to next row
                            
printBoardExit:
        lw $ra, 0($sp)               # Load return address from stack
        addi $sp, $sp, 4             # Restore the stack
        
        jr $ra                       # Jump to return address
        
updateEdge:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        la $t0, boardArray          # Load address of the array into $t0
        la $t1, boardRowSize        # Load rowSize address into $t1
        lb $t1, ($t1)               # Set $t1 to rowSize integer
        la $t2, boardColumnSize     # Load colSize address into $t2
        lb $t2, ($t2)               # Set $t2 to colSize integer
        
        
        mul $t4, $a1, $t2
        add $t4, $t4, $a0
        add $t4, $t4, $t0
        
        
        bnez $a2, opponentEdge
        
        li $t5, 'P'
        j updateEdgeContinue
        
        opponentEdge:
                li $t5, 'C'
        
        updateEdgeContinue:
                sb $t5, ($t4)
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
        
        


