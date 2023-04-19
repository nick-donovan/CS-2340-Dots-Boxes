# WIP

.data
        _warning_jump_table:
                .word _w_invalid_edge_input # 0x0X
                
	_w_invalid_edge_input_msgs:
	        _w_invalid_edge_msg_: .asciiz "AAA\n" ##########
        
        .globl _warning_throw_warning 
       
.text
main:
       la $a0, main
       li $a1, 0x00
       jal _warning_throw_warning

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
#   $a0 - address of the caller label
#   $a1 - error code to throw
# Outputs:
#   None - Initialized board is saved in memory
# Registers modified: $sp, $ra
_warning_throw_warning:
        addi $sp, $sp, -4 # sp = sp - 4
        sw $a0, 0($sp) # sp[0] = a0
        
        srl $t0, $a1, 1 # t0 = a1 / 4
        sll $t0, $t0, 2 # t0 = t0 * 4
        lw $t0, _warning_jump_table($a1) # t0 = _warning_jump_table[a1]
        
        jr $t0 # jump_to(t0)

	# Return to the caller method
	_w_tw_return_to_caller:
		lw $a0, 0($sp) # a0 = sp[0]
		addi $sp, $sp, 4 # sp = sp + 4

		jr $a0 # jump_to (t0)
		
	_w_tw_exit_program:
		j exit # exit(1)

 _w_invalid_edge_input:
        la $a0, _w_invalid_edge_msg_
        li $v0, 4
        syscall
        j _w_tw_return_to_caller

exit:
        li $v0, 10
        syscall
