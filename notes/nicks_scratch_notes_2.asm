.data
        _warning_jump_table:
                .word _w_test1 # 0x00
                .word _w_test2 # 0x01
                
        _w_msg1_: .asciiz "Don't enter 0\n"
        _w_msg2_: .asciiz "test2 called"
.text
main:

        li $v0, 5
        syscall
        move $s0, $v0
        
        bnez $s0, exit
        

        la $a0, main
        li $a1, 0x00
        jal _warning_throw_warning

        j exit
        
_warning_throw_warning:
        addi $sp, $sp, -4
        sw $a0, 0($sp)
        
        sll $a1, $a1, 2
        lw $t0, _warning_jump_table($a1)
        
        jr $t0
        
_w_tw_return_to_caller:
        lw $a0, 0($sp)
        addi $sp, $sp, 4

        jr $a0
        
_w_tw_exit_program:
        j exit

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
