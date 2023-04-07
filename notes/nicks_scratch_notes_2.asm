.data
	_warning_jump_table:
		.word _w_test1
		
		
        
        WARNING_CODE: .word 10
.text
main:
        la $a0, main
        li $a1, 0x02
	jal throw_warning

	j exit
	
throw_warning:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	sll $a1, $a1, 2
	la $a0, __warning($a1)
	li $v0, 4
	syscall

	
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

_w_test1:
	

exit:
li $v0, 10
syscall