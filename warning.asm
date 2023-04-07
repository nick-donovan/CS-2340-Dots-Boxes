# WIP

.data
        _warning_jump_table:
                .word _w_test1 # 0x00
                .word _w_test2 # 0x01
                
        _w_msg1_: .asciiz "Don't enter 0\n"
        _w_msg2_: .asciiz "test2 called"
        .globl _warning_throw_warning 
       
.text

#        la $a0, main
#        li $a1, 0x00
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
#   None
# Outputs:
#   None - Initialized board is saved in memory
# Registers modified: $sp, $ra
_warning_throw_warning:
        addi $sp, $sp, -4 # sp = sp - 4
        sw $a0, 0($sp) # sp[0] = a0
        
        sll $a1, $a1, 2 # a1 = a1 * 4
        lw $t0, _warning_jump_table($a1) # t0 = _warning_jump_table[a1]
        
        jr $t0 # jump_to(t0)

# Return to the caller method
_w_tw_return_to_caller:
        lw $a0, 0($sp) # a0 = sp[0]
        addi $sp, $sp, 4 # sp = sp + 4

        jr $a0 # jump_to (t0)
        
_w_tw_exit_program:
        j exit # exit(1)

_w_test1:
        la $a0, _w_msg1_
        li $v0, 4
        syscall
        j _w_tw_return_to_caller
        
_w_test2:
        la $a0, _w_msg2_
        li $v0, 4
        syscall
        j _w_tw_return_to_caller

exit:
        li $v0, 10
        syscall
