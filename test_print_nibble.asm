.data

str2float: .word 0x000000BA

.text
.globl main
main:

	lw $s0, str2float
	move $a0, $s0	#tryig to replicate how this will be used in main program
	jal print_nibble
	li $v0, 10
	syscall
	
	
 
print_nibble:
	#this converts the lower 4 bits of $a0 to ascii and then prints 
	andi $t0, $a0, 0x0F	#this masks the lower 4 bits
	slti $t1, $t0, 10	#$t1 = 0 if greater than 10 and 1 if less than 10
	beqz $t1, is_letter
	addi $a0, $t0, 48	#mapping
	j do_print 

is_letter:
	addi $a0, $t0, 55	#maps 10 -> 15 to A -> F
	
	
do_print:
	li $v0, 11
	syscall
	
	jr $ra
	
	
	
	
