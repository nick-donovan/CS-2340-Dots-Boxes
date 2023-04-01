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
        li $v0, 10
        syscall

initializeBoard:
        addi $sp, $sp, -4        # Make room in stack
        sw $ra, 0($sp)           # Store return address in stack

        la $t0, boardArray       # Load address of the array into $t0
        la $t1, boardRowSize     # Load rowSize address into $t1
        lb $t1, ($t1)            # Set $t1 to rowSize integer
        la $t2, boardColumnSize  # Load colSize address into $t2
        lb $t2, ($t2)            # Set $t2 to colSize integer
        li $t3, 0                # Initialize row index to 0
        li $t4, 0                # Initialize col index to 0 (not needed here but helps know which reg it's in)
        
        
        initializeBoardRowLoop:
                blt $t3, $t1, initializeBoardColumnLoopStart  # If row index is less than the amount of rows, loop column 
                j initializeBoardExit                         # Else, exit the loop

                initializeBoardColumnLoopStart:
                        li $t4, 0                                     # Reset column index to 0
                        
                initializeBoardColumnLoop:
                        blt $t4, $t2, initializeBoardChar             # Jump if column index is less that the total columns in a row
                        j initializeBoardColumnLoopEnd                # Processed to next row
                        
                initializeBoardChar:
                        mul $t5, $t3, $t2           # Multiply the row we're on by total columns
                        add $t5, $t5, $t4           # Add column index to $t5 to get current element index
                        add $t5, $t0, $t5           # Set $t5 to current cell address in array
                        
                        andi $t6, $t3, 0x01         # Check if row index is even
                        bnez $t6, loadSpace         # If odd, insert a space in the cell
                        
                        andi $t6, $t4, 0x01         # Check if the column index is even
                        bnez $t6, loadSpace         # If odd, insert a space in the cell
                        
                        addi $t4, $t4, 1            # Increment counter
                        
                        lb $t6, boardSymbolChar     # Load boardSymbolChar in $t6 for insertion
                        j initializeBoardAddChar    # Jump to label that inserts char in array
                        
                loadSpace:
                        addi $t4, $t4, 1            # Increment column index
                        lb $t6, spaceChar           # Load space into $t6 for insertion
                        
                initializeBoardAddChar:
                        sb $t6, ($t5)               # Store the character in the array
                        j initializeBoardColumnLoop # Process next cell in row
                
        initializeBoardColumnLoopEnd:
                addi $t3, $t3, 1            # Increment row index
                j initializeBoardRowLoop    # Process next row in array
                
initializeBoardExit:
        lw $ra, 0($sp)              # Load return address from stack
        addi $sp, $sp, 4            # Restore the stack

        jr $ra                      # Jump to return address

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
        
        


