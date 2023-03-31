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
        
.text
initializeBoard:
        addi $sp, $sp, -8        # Make room in stack
        sw $ra, 0($sp)           # Store return address in stack
        sw $a1, 4($sp)           # Store a1 register in stack

        la $a1, boardArray       # Load address of the array into $a1
        la $t0, boardRowSize     # Load rowSize address into $t0
        lb $t0, ($t0)            # Set $t0 to rowSize integer
        la $t1, boardColumnSize  # Load colSize address into $t1
        lb $t1, ($t1)            # Set $t1 to colSize integer
        li $t2, 0                # Initialize row index to 0
        li $t3, 0                # Initialize col index to 0 (not needed here but helps know which reg it's in)
        
        
        initializeBoardRowLoop:
                blt $t2, $t0, initializeBoardColumnLoopStart  # If row index is less than the amount of rows, loop column 
                j initializeBoardExit                         # Else, exit the loop

                initializeBoardColumnLoopStart:
                        li $t3, 0                                     # Reset column index to 0
                        
                initializeBoardColumnLoop:
                        blt $t3, $t1, initializeBoardChar             # Jump if column index is less that the total columns in a row
                        j initializeBoardColumnLoopEnd                # Processed to next row
                        
                initializeBoardChar:
                        mul $t4, $t2, $t1           # Multiply the row we're on by total columns
                        add $t4, $t4, $t3           # Add column index to $t4 to get current element index
                        add $t4, $a1, $t4           # Set $t4 to current cell address in array
                        
                        andi $t5, $t2, 0x01         # Check if row index is even
                        bnez $t5, loadSpace         # If odd, insert a space in the cell
                        
                        andi $t5, $t3, 0x01         # Check if the column index is even
                        bnez $t5, loadSpace         # If odd, insert a space in the cell
                        
                        addi $t3, $t3, 1            # Increment counter
                        
                        lb $t5, boardSymbolChar     # Load boardSymbolChar in $t5 for insertion
                        j initializeBoardAddChar    # Jump to label that inserts char in array
                        
                loadSpace:
                        addi $t3, $t3, 1            # Increment column index
                        lb $t5, spaceChar           # Load space into $t5 for insertion
                        
                initializeBoardAddChar:
                        sb $t5, ($t4)               # Store the character in the array
                        j initializeBoardColumnLoop # Process next cell in row
                
        initializeBoardColumnLoopEnd:
                addi $t2, $t2, 1            # Increment row index
                j initializeBoardRowLoop    # Process next row in array
                
initializeBoardExit:
        lw $a1, 4($sp)              # Load a1 register from stack
        lw $ra, 0($sp)              # Load return address from stack
        addi $sp, $sp, 8            # Restore the stack

        jr $ra                      # Jump to return address

printBoard:
        addi $sp, $sp, -8           # Make room in stack
        sw $ra, 0($sp)              # Store return address in stack
        sw $a1, 4($sp)              # Store a1 register in stack
                
        la $a1, boardArray          # Load address of the array into $a1
        la $t0, boardRowSize        # Load rowSize address into $t0
        lb $t0, ($t0)               # Set $t0 to rowSize integer
        la $t1, boardColumnSize     # Load colSize address into $t1
        lb $t1, ($t1)               # Set $t1 to colSize integer
        li $t2, 0                   # Initialize row index to 0
        li $t3, 0                   # Initialize col index to 0 (not needed here but helps know which reg it's in)

        la $a0, boardHeaderString   # Load address for boardHeaderString
        li $v0, 4                   # Syscall for print string
        syscall                     # Print boardHeaderString

                
        printBoardRowLoop:
                blt $t2, $t0, printBoardColumnLoopStart # If row index is less than the amount of rows, loop column
                j printBoardExit                        # Else, exit the loop
                
                printBoardColumnLoopStart:
                        li $t3, 0                          # Set Col index to 0
                        
                        addi $a0, $t2, 1                   # Set the row counter to index + 1
                        li $v0, 1                          # Syscall for print integer
                        syscall                            # Print row counter
                        
                        li $a0, ' '                        # Load a space into a0
                        li $v0, 11                         # Syscall for printing a character
                        syscall                            # Print the space
                        
                        slti $t4, $t2, 9                   # If row index is not less than 9
                        beq  $t4, $0, printBoardColumnLoop # Skip the second space (alignment)
                        
                        li $v0, 11                         # Syscall for printing a character
                        syscall                            # Print another space
                        
                printBoardColumnLoop:        
                        blt $t3, $t1, printBoardChar # If column index is less than total columns, print the row
                        j printBoardColumnLoopEnd    # Else end the column loop
                        
                printBoardChar:
                        mul $t4, $t2, $t1            # Multiply the row we're on by total columns
                        add $t4, $t4, $t3            # Add column index to $t4 to get current element index
                        add $t4, $a1, $t4            # Set $t4 to current cell address in array

                        lb $a0, ($t4)                # Load the current array element into $a0
                        li $v0, 11                   # Syscall for printing a char
                        syscall                      # Print the current element
                        
                        li $a0, ' '                  # Load a space into $a0
                        li $v0, 11                   # Syscall for printing a character
                        syscall                      # Print a space
                        
                        addi $t3, $t3, 1             # Increment the column index
                        
                        j printBoardColumnLoop       # Move to next cell
                        
                printBoardColumnLoopEnd:        
                        li $a0, '\n'                 # Load a new line into $a0
                        li $v0, 11                   # Syscall for printing a character
                        syscall                      # Print a new line
                        
                        addi $t2, $t2, 1             # Increment the row index
                        
                        j printBoardRowLoop          # Move on to next row
                        
printBoardExit:
        lw $a1, 4($sp)               # Load a1 register from stack
        lw $ra, 0($sp)               # Load return address from stack
        addi $sp, $sp, 8             # Restore the stack
        
        jr $ra                       # Jump to return address


