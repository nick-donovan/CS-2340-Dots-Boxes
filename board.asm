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
        playerEdgeSymbol: .byte 'P'
        oppEdgeSymbol: .byte 'C'
        .globl printBoard
        .globl initializeBoard
        .globl updateEdge
        
.text
main:
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
# Registers modified: $sp, $ra
initializeBoard:
        addi $sp, $sp, -4        # Make room in stack
        sw $ra, 0($sp)           # Save the return address

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
 
                        # Load a space if either row or col are odd
                        loadSpace:
                                lb $t6, spaceChar    # Load the space character into $t6

                        # Insert the loaded symbol into the game board array
                        iBInsertChar:
                                sb $t6, ($t0)        # Insert the loaded char into the game board array

                        # Adjust indexes and positions
                        addi $t4, $t4, 1             # Increment col index
                        addi $t0, $t0, 1             # Increment position to next element
                        j iBColLoop                  # Move to next element

                # End of the column loop
                iBColLoopEnd:
                        addi $t3, $t3, 1             # Increment row index
                        j iBRowLoop                  # Move to next row

        iBExit:
                lw $ra, 0($sp)                       # Load return address from stack
                addi $sp, $sp, 4                     # Free up stack space

                jr $ra                               # Return
        
# Description: Prints the game board in it's current state.
#
# Pseudo representation:
#     public void printBoard():
#         print(boardHeaderString)
#         for(int row = 0; row < boardRowSize; ++row):
#             for (int col = 0; col < boardColumnSize; ++col):
#                  print(row + 1)
#                  print(' ')
#                  if (row + 1 < 9): print(' ')
#                  print(boardArray[row][col] + " ")
#              end for
#              print('\n')
#          end for
#      end printBoard()
#
# Inputs: 
#   None
# Outputs:
#   None
# Registers modified: $sp, $ra, $a0
printBoard:
        addi $sp, $sp, -4         # Make room in stack
        sw $ra, 0($sp)            # Save the return address

        la $t0, boardArray        # Load address of the array into $t0
        la $t1, boardRowSize      # Load rowSize address into $t1
        lb $t1, ($t1)             # Set $t1 to rowSize integer
        la $t2, boardColumnSize   # Load colSize address into $t2
        lb $t2, ($t2)             # Set $t2 to colSize integer 
        li $t3, 0                 # Initialize row index to 0 (int row = 0)

        la $a0, boardHeaderString
        jal printString

        # Loop through each row of the game board
        pBRowLoop:
                slt $t5, $t3, $t1      # Is row < boardRowSize
                beq $t5, $zero, pBExit # If not, exit
                
                li $t4, 0              # Set col index to 0 (int col = 0)
                
                # Print the number label for each row
                pBPrintRowNum:
                        move $a0, $t3                # Move row index to a0
                        addiu $a0, $a0, 1            # Add 1
                        jal printInt                 # Print row index
                        
                        lb $a0, spaceChar            # Load space char
                        jal printChar                # Print a space
                        
                        slti $t5, $t3, 9             # Is row in the one digit num range
                        beq $t5, $zero, pBPrintCell  # If not skip to pBPrintCell
                        
                        jal printChar                # Else print another space

                # Loop through each column of the game board
                pBColLoop:
                        slt $t5, $t4, $t2            # Is col < boardColumnSize
                        beq $t5, $zero, pBColLoopEnd # If not, move to next row  
                                
                        # Print the current cell
                        pBPrintCell:
                                lb $a0, ($t0)                # Load the current array element into $a0
                                jal printChar                # Print the current element
                        
                                lb $a0, spaceChar            # Load a space into $a0
                                jal printChar                # Print a space
                                
                        # Adjust indexes and positions
                        addi $t4, $t4, 1             # Increment col index
                        addi $t0, $t0, 1             # Increment position to next element
                        j pBColLoop                  # Move to next element
                                
                pBColLoopEnd:
                        addi $t3, $t3, 1  # Increment row index
                        
                        la $a0, '\n'      # Load new line char
                        jal printChar     # Print new line
                        
                        j pBRowLoop       # Move to next row
                        
        pBExit:
                lw $ra, 0($sp)            # Load return address from stack
                addi $sp, $sp, 4          # Free up stack space

                jr $ra                    # Return
  
# Description: Updates a board edge and sets a marker for who claimed it
#
# Pseudo representation:
#    private void updateEdge(int $a0, int $a1, $int a2):
#        if (a2 == 0)
#            boardArray[a1][a0] = playerEdgeSymbol
#        else
#            boardArray[a1][a0] = oppEdgeSymbol
#    end updateEdge()     
#
# Inputs: 
#   $a0 - Col index of the edge
#   $a1 - Row index of the edge
#   $a2 - Integer for which player claims the edge; 0 for player, 1 for opponent
# Outputs:
#   None
# Registers modified: $sp, $ra
updateEdge:
        addi $sp, $sp, -4              # Make room in stack
        sw $ra, 0($sp)                 # Save the return address
        
        la $t0, boardArray             # Load address of the array into $t0
        la $t1, boardRowSize           # Load rowSize address into $t1
        lb $t1, ($t1)                  # Set $t1 to rowSize integer
        la $t2, boardColumnSize        # Load colSize address into $t2
        lb $t2, ($t2)                  # Set $t2 to colSize integer
        
        mul $t4, $a1, $t2              # Get current row
        add $t4, $t4, $a0              # Get current element index in row
        add $t4, $t4, $t0              # Add index to array address to get current address
        
        bnez $a2, opponentEdge         # if (a2 != 0) it's the opponents edge
        
        lb $t5, playerEdgeSymbol       # Load players edge symbol
        j setEdge                      # Set players edge
        
        opponentEdge:
                lb $t5, oppEdgeSymbol  # Load opponents edge symbol

        setEdge:
                sb $t5, ($t4)          # Store symbol as current element
        
        lw $ra, 0($sp)                 # Load return address
        addi $sp, $sp, 4               # Restore the stack
        
        jr $ra                         # Return

