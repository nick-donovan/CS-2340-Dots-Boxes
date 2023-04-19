.data
        test1: .asciiz "labelOne called"
        test2: .asciiz "labelTwo called"
        
.text
labelOne:
        li $t0, 999
        
labelTwo:
        la $a0, labelOne
        la $a1, labelTwo
        jal getCallerAddress
        move $s0, $v0

        beq $v0, $a0, oneCalled
        
        la $a0, test2
        jal printString
        j exit
        
        oneCalled:
                la $a0, test1
                jal printString
        
        
        
        j exit
getCallerAddress:
        slt $t0, $a0, $a1
        beq $t0, $zero, gCASwapValues
        
        j gCAContinue
        
        gCASwapValues:
                move $t0, $a0
                move $a1, $a0
                move $a0, $t0
        
        gCAContinue:
                slt $t0, $ra, $a1
                beq $t0, $zero, gCAsecondCalled
                
                move $v0, $a0
                
                jr $ra
                        
        gCAsecondCalled:
                move $v0, $a1####################
                jr $ra
        
        

exit:
        li $v0, 10
        syscall
        
printInt:
        li $v0, 1
        syscall
        jr $ra
        
printString:
        li $v0, 4
        syscall
        jr $ra
        
printBreak:
        li $a0, '\n'
        li $v0, 11
        syscall
        jr $ra
