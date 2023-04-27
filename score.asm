# File: score.asm
# Author: Rushi Kona
# Class: CS 2340.004
# Date: Mar. 26, 2023
# Purpose: Responsible for keeping track of the score during the game. Functions for
#  updating the score after each move, and displaying the final score at the end of
#  the game. Updating the center if a player owns that box.


.data
        .globl score_update_score
.text
#input  $a0 $a1 x y cooards for edge that was placed  $a2-current player value, $a3-current player score
#output $v0 next player value, $v1 current player score (after edge placed)
score_update_score:
        addi $sp, $sp, -16                               # Make room in stack
        sw $s2, 12($sp)                                  # Save s2
        sw $s1, 8($sp)                                   # Save s1
        sw $s0, 4($sp)                                   # Save s0
        sw $ra, 0($sp)                                   # Save the return address

        add $s0, $a0, $zero                              #save original x val
        add $s1, $a1, $zero                              #save original y val
        addi $s2, $a2, 0                                 #save orignal player val


        jal isColEven                                    #check if column is even return bool to $v0
        bnez $v0, horiz_edge_placed                      #Branch if $v0 != 0 horiz edge was placed else vertical was placed
                bnez $a0, last_col                       #Branch if col != 0
                        jal horizR                       #Check box Right
                        beqz $v0, return_from_firstcol   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1         #increments input score by 1
                                addi $a0, $s0, 1         #x val goes to center of box to right
                                add $a1, $s1, $zero      #y val restore
                                jal board_update_edge    #update center of box
                                xori $a2, $a2, 1         #switch player for next turn

                return_from_firstcol:       # no box found right
                        xori $a2, $a2, 1    # switch player for next turn
                        move $v0, $a2       #output for next player
                        move $v1, $a3       #output added points

                        lw $ra, 0($sp)      # Restore the return address
                        lw $s0, 4($sp)      # Restore s0
                        lw $s1, 8($sp)      # Restore s1
                        lw $s2, 12($sp)     # Restore s2
                        addi $sp, $sp, 16   # Restore the stack

                        jr $ra              # Return

                li $t5, 16                  #Load 16(last col) into $t5
                last_col:                                       #Last column edge case
                        bne $a0, $t5, not_edgecase_col          #branch if(x!=16)
                                jal horizL                      #Check box Left
                                beqz $v0, return_from_lastcol   #branch if $v0 is 0(no box) to return
                                        addi $a3, $a3, 1        #increments input score by 1
                                        addi $a0, $s0, -1       #x val goes to center of box to right
                                        add $a1, $s1, $zero     #y val restore
                                        jal board_update_edge   #update center of box
                                        xori $a2, $a2, 1        #switch player for next turn

                        return_from_lastcol:
                                xori $a2, $a2, 1    #switch player for next turn
                                move $v0, $a2       #output for next player turn value
                                move $v1, $a3       #output points for current player
                                lw $ra, 0($sp)      # Restore the return address
                                lw $s0, 4($sp)      # Restore s0
                                lw $s1, 8($sp)      # Restore s1
                                lw $s2, 12($sp)     # Restore s2
                                addi $sp, $sp, 16   # Restore the stack

                                jr $ra              # Return
                not_edgecase_col:                           #Not edge case
                        jal horizR                          #Check box Right
                        move $a0, $s0
                        move $a1, $s1
                        beqz $v0, return_from_nonedgecolR   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1            #increments input score by 1
                                addi $a0, $s0, 1            #x val goes to center of box to right
                                add $a1, $s1, $zero         #y val restore
                                jal board_update_edge       #update center of box
                                add $a1, $s1, $zero         #restore y val
                                add $a0, $s0, $zero         #restore x val
                                addi $t2, $t2, 1            #points this turn +1
                return_from_nonedgecolR:

                        jal horizL                          #Check box Left
                        move $a0, $s0
                        move $a1, $s1
                        beqz $v0, return_from_nonedgecolL   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1            #increments input score by 1
                                addi $a0, $s0, -1           #x val goes to center of box to right
                                add $a1, $s1, $zero         #y val restore
                                jal board_update_edge       #update center of box
                                add $a1, $s1, $zero         #restore y val
                                add $a0, $s0, $zero         #restore x val
                                addi $t2, $t2, 1            #points this turn +1
                return_from_nonedgecolL:
                        beqz $t2, no_box_horiz_B   #branches if either only one or two box is found else switch next turn player
                                xori $a2, $a2, 1   #switch player for next turn
                no_box_horiz_B:
                        xori $a2, $a2, 1    #switch player for next turn
                        move $v0, $a2       #output for next player turn value
                        move $v1, $a3       #output points for current player
                        lw $ra, 0($sp)      # Restore the return address
                        lw $s0, 4($sp)      # Restore s0
                        lw $s1, 8($sp)      # Restore s1
                        lw $s2, 12($sp)     # Restore s2
                        addi $sp, $sp, 16   # Restore the stack

                        jr $ra              # Return

        horiz_edge_placed:
                bnez $a1, last_row                       #Branch if row != 0
                        jal vertD                        #Check box down
                        beqz $v0, return_from_firstrow   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1         #increments input score by 1
                                add $a0, $s0, $zero      #x val restore
                                addi $a1, $s1, 1         #y val down to center of box
                                jal board_update_edge    #update center of box
                                xori $a2, $a2, 1         #switch player for next turn

                return_from_firstrow:       # no box found down
                        xori $a2, $a2, 1    # switch player for next turn
                        move $v0, $a2       #output for next player turn value
                        move $v1, $a3       #output points for current player
                        lw $ra, 0($sp)      # Restore the return address
                        lw $s0, 4($sp)      # Restore s0
                        lw $s1, 8($sp)      # Restore s1
                        lw $s2, 12($sp)     # Restore s2
                        addi $sp, $sp, 16   # Restore the stack

                        jr $ra              # Return

                li $t3, 12                  #Load 11(last row) into $t3
                last_row:                                       #Last column edge case
                        bne $a1, $t3, not_edgecase_row          #branch if(y!=12)
                                jal vertU                       #Check box up
                                beqz $v0, return_from_lastrow   #branch if $v0 is 0(no box) to return
                                        addi $a3, $a3, 1        #increments input score by 1
                                        add $a0, $s0, $zero     #x val restore
                                        addi $a1, $s1, -1       #y val up to center of box
                                        jal board_update_edge   #update center of box
                                        xori $a2, $a2, 1        #switch player for next turn

                        return_from_lastrow:        #no box found up
                                xori $a2, $a2, 1    #switch player for next turn
                                move $v0, $a2       #output for next player turn value
                                move $v1, $a3       #output points for current player
                                lw $ra, 0($sp)      # Restore the return address
                                lw $s0, 4($sp)      # Restore s0
                                lw $s1, 8($sp)      # Restore s1
                                lw $s2, 12($sp)     # Restore s2
                                addi $sp, $sp, 16   # Restore the stack

                                jr $ra              # Return
                not_edgecase_row:                           #Not edge case
                        jal vertD                           #Check box down
                        move $a0, $s0
                        move $a1, $s1
                        beqz $v0, return_from_nonedgerowD   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1            #increments input score by 1
                                add $a0, $s0, $zero         #x val restore
                                addi $a1, $s1, 1            #y val down to center of box
                                jal board_update_edge       #update center of box
                                add $a1, $s1, $zero         #restore y val
                                add $a0, $s0, $zero         #restore x val
                                addi $t2, $t2, 1            #points this turn +1
                return_from_nonedgerowD:

                        jal vertU                           #Check box up
                        move $a0, $s0
                        move $a1, $s1
                        beqz $v0, return_from_nonedgerowU   #branch if $v0 is 0(no box) to return
                                addi $a3, $a3, 1            #increments input score by 1
                                add $a0, $s0, $zero         #x val restore
                                addi $a1, $s1, -1           #y val down to center of box
                                jal board_update_edge       #update center of box
                                add $a1, $s1, $zero         #restore y val
                                add $a0, $s0, $zero         #restore x val
                                addi $t2, $t2, 1            #points this turn +1
                return_from_nonedgerowU:
                        beqz $t2, no_box_vert_B    #branches if no box is found
                                xori $a2, $a2, 1   #switch player for next turn
                no_box_vert_B:
                        xori $a2, $a2, 1    #switch player for next turn
                        move $v0, $a2       #output for next player turn value
                        move $v1, $a3       #output  points for current player
                        lw $ra, 0($sp)      # Restore the return address
                        lw $s0, 4($sp)      # Restore s0
                        lw $s1, 8($sp)      # Restore s1
                        lw $s2, 12($sp)     # Restore s2
                        addi $sp, $sp, 16   # Restore the stack

                        jr $ra              # Return

#checks if column is even
#output col%2
isColEven:
        li $t0, 2
        div $a0, $t0
        mfhi $t0
        add $v0, $t0, $zero
        jr $ra

#if filled return true(1) else false(0)
horizR:
        addi $sp, $sp, -4             # Make room in stack
        sw $ra, 0($sp)                # Save the return address

        add $s0, $a0, $zero           #save original x val
        add $s1, $a1, $zero           #save original y val

        addi $a0, $s0, 1              #x+1 in $a0

        addi $a1, $s1, 1              #y+1 in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hR          #branch if not claimed

        addi $a1, $s1, -1             #y-1 in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hR          #branch if not claimed

        addi $a0, $s0, 2              #x+2 in $a0
        add $a1, $s1, $zero           #y in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hR          #branch if not claimed

        li $v0, 1                     # return value

        lw $ra, 0($sp)                # Restore the return address
        addi $sp, $sp, 4              # Restore the stack

        jr $ra                        # Return

        not_box_hR:
                addi $v0, $zero, 0   # return value

                lw $ra, 0($sp)       # Restore the return address
                addi $sp, $sp, 4     # Restore the stack

                jr $ra               # Return

horizL:
        addi $sp, $sp, -4             # Make room in stack
        sw $ra, 0($sp)                # Save the return address

        add $s0, $a0, $zero           #save original x val
        add $s1, $a1, $zero           #save original y val

        addi $a0, $s0, -1             #x-1 in $a0

        addi $a1, $a1, 1              #y+1 in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hL          #branch if not claimed

        addi $a1, $a1, -2             #y-1 in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hL          #branch if not claimed

        addi $a0, $s0, -2             #x-2 in $a0
        add $a1, $s1, $zero           #y in $a1
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_hL          #branch if not claimed

        li $v0, 1                     # return value

        lw $ra, 0($sp)                # Restore the return address
        addi $sp, $sp, 4              # Restore the stack

        jr $ra                        # Return

        not_box_hL:
                addi $v0, $zero, 0   # return value

                lw $ra, 0($sp)       # Restore the return address
                addi $sp, $sp, 4     # Restore the stack

                jr $ra               # Return

vertU:
        addi $sp, $sp, -4             # Make room in stack
        sw $ra, 0($sp)                # Save the return address

        add $s0, $a0, $zero           #save original x val
        add $s1, $a1, $zero           #save original y val

        addi $a1, $s1, -1             #y+1 in $a0

        addi $a0, $s0, 1              #x+1 in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vU          #branch if not claimed

        addi $a0, $s0, -1             #x-1 in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vU          #branch if not claimed

        addi $a1, $s1, -2             #y-2 in $a0
        add $a0, $s0, $zero           #x in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vU          #branch if not claimed

        li $v0, 1                     # return value

        lw $ra, 0($sp)                # Restore the return address
        addi $sp, $sp, 4              # Restore the stack

        jr $ra                        # Return

        not_box_vU:
                addi $v0, $zero, 0   # return value

                lw $ra, 0($sp)       # Restore the return address
                addi $sp, $sp, 4     # Restore the stack

                jr $ra               # Return

vertD:
        addi $sp, $sp, -4             # Make room in stack
        sw $ra, 0($sp)                # Save the return address

        add $s0, $a0, $zero           #save original x val
        add $s1, $a1, $zero           #save original y val

        addi $a1, $s1, 1              #y+1 in $a0

        addi $a0, $s0, 1              #x+1 in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vD          #branch if not claimed

        addi $a0, $s0, -1             #x-1 in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vD          #branch if not claimed

        addi $a1, $s1, 2              #y+2 in $a0
        add $a0, $s0, $zero           #x in $a0
        jal board_is_edge_unclaimed   # $v0 returns false (0) if claimed
        bnez $v0, not_box_vD          #branch if not claimed

        li $v0, 1                     # return value

        lw $ra, 0($sp)                # Restore the return address
        addi $sp, $sp, 4              # Restore the stack

        jr $ra                        # Return

        not_box_vD:
                addi $v0, $zero, 0          # return value

                lw $ra, 0($sp)          # Restore the return address
                addi $sp, $sp, 4        # Restore the stack

                jr $ra                  # Return



# edge_check:
#         if (X%2 == 0){ #vertical
#                 if(X=0){
#                         if(horizR){
#                         }
#                         return
#                 }
#                 if(X=16){
#                         horizL
#                         return
#                 }
#                 if(X!=0 && X!=16){
#                         horizR
#                         horizL
#                         return
#                 }
#         }
#         else{ #horizontal
#                 if(Y=0){
#                         vertD
#                         return
#                 }
#                 if(Y=12){
#                         vertU
#                         return
#                 }
#                 if(Y!=0 && Y!=12){
#                         vertD
#                         vertU
#                         return
#                 }
#         }
# horizR:
#         isFilled(X+1,Y-1);
#         isFilled(X+1,Y+1);
#         isFilled(X+2,Y);
# horizL:
#         isFilled(X,Y-1);
#         isFilled(X,Y+1);
#         isFilled(X-2,Y);
# vertU:
#         isFilled(X-1,Y-1);
#         isFilled(X+1,Y-1);
#         isFilled(X,Y-2)
# vertD:
#         isFilled(X-1,Y+1);
#         isFilled(X+1,Y+1);
#         isFilled(X,Y+2);