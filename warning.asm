# File: warning.asm
# Author: Nicholas Donovan
# Class: CS 2340.004
# Date: Apr. 19, 2023
# Purpose: Responsible for catching non-fatal exceptions, uses a jump table to jump 
#   to the appropriate subroutine and prints the message if applicable. If the program 
#   can resume it jumps back to the return address and lets the caller decide on the 
#   action needed. Else it will exit the program.

.data
        _warning_jump_table:
		.word _w_invalid_edge_input_too_short    
		.word _w_invalid_edge_input_invalid_col  
		.word _w_invalid_edge_input_invalid_row 
		.word _w_invalid_edge_input_invalid_edge 
		.word _w_invalid_edge_input_edge_claimed 
	

        _w_iei_too_short_msg:    .asciiz "Input must be at least two characters.\n" # 0x00
        _w_iei_invalid_col_msg:  .asciiz "First character must be A-Q.\n"           # 0x01
        _w_iei_invalid_row_msg:  .asciiz "Numbers must be between 1-13.\n"          # 0x02
        _w_iei_invalid_edge_msg: .asciiz "Input is not an edge.\n"                  # 0x03
        _w_iei_edge_claimed_msg: .asciiz "Edge has already been claimed.\n"         # 0x04
        
        .globl _warning_throw_warning 
       
.text
main:
#       la $a0, main
#       li $a1, 0x00
#       jal _warning_throw_warning

# Description: Main driver for catching warnings, takes in error code and 
#              caller label address then uses jump table to perform an 
#              action.
#
# Pseudo representation:
#     public void _warning_throw_warning(Address a0, int error):
#         sp = sp - 4
#         stack[0] = a0
#
#         offset = error * 4
#         t0 = _warning_jump_table[offset]
#
#         return_to_caller = jump_to(t0)
#
#         if (return_to_caller):
#             return_to_caller()
#         else:
#             exit(1)
#     end _warning_throw_warning()
# Inputs:
#   $a0 - error code to throw
# Outputs:
#   None
# Registers modified: $sp, $ra
_warning_throw_warning:
        addi $sp, $sp, -4 # sp = sp - 8
        sw $ra, 0($sp)
        
        sll $a0, $a0, 2 # t0 = t0 * 4
        lw $t0, _warning_jump_table($a0) # t0 = _warning_jump_table[a1]
        
        jr $t0 # jump_to(t0)

	# Return to the caller method
	_w_tw_print_string_rtc:
		jal print_string############
		jal print_break
		
	_w_tw_return_to_caller:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra 
		
	_w_tw_exit_program:
		j exit # exit(1)

_w_invalid_edge_input_too_short:
 	la $a0, _w_iei_too_short_msg
        j _w_tw_print_string_rtc
        
_w_invalid_edge_input_invalid_col:
 	la $a0, _w_iei_invalid_col_msg
        j _w_tw_print_string_rtc
        
_w_invalid_edge_input_invalid_row:
 	la $a0, _w_iei_invalid_row_msg
        j _w_tw_print_string_rtc
        
_w_invalid_edge_input_invalid_edge:
 	la $a0, _w_iei_invalid_edge_msg
        j _w_tw_print_string_rtc
        
_w_invalid_edge_input_edge_claimed:
 	la $a0, _w_iei_edge_claimed_msg
        j _w_tw_print_string_rtc
