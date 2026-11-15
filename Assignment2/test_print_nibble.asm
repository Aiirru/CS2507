.data

str2float: .word 0x00ABCDEF
nibble_buffer: .space 2		#need this because syscall 11 isnt allowed


.text
.globl main
main:

	lw $s0, str2float
	move $a0, $s0	#tryig to replicate how this will be used in main program
	li $a1, 6	#number of nibbles being printer (ammount in hex)
	jal print_hex_string
	li $v0, 10
	syscall
	
print_hex_string:
	addi $sp, $sp, -12	#created space in stack
	sw $ra, 0($sp)		#storing return adress in stack because this is a branch function 
				#sw found in help menu to find which order the variable you want to store it in must be
				#e.g sw $ra, 0($sp) INSTEAD OF sw 0($sp), $ra
	
	sw $s0, 4($sp)		#storing $s0 into stack as we are using it twice
	sw $s1, 8($sp) 		#storing $s1 into stack as we are using it twice 
	
	move $s0, $a0
	move $s1, $a1		#$s1 contains the number of nibbles we want to print

hex_loop:
	blez $s1, print_done	#exits loop when loop count is zero 
	subi $t0, $s1, 1	#minus nibble count by 1 as you want to shift by -1 the char count as starts at 0
	mul $t0, $t0, 4		#mul the nibble count by 4 to turn it into its bit count to be able to shift properly
	srlv $a0, $s0, $t0	#shifts target nibble by number of bits stored in $t0
	jal print_nibble
	subi $s1, $s1, 1	#decrements counter
	j hex_loop
	
	
print_done:
	lw $ra, 0($sp)		#restoring return adress so there isnt an infinite loop caused by the following $ra
	lw $s0, 4($sp)		#restoring original values back into $s0 and $s1 as they held important info and i was messing with it 
	lw $s1, 8($sp)
	
	jr $ra			#returns to return adress
	
 
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
	la $t2, nibble_buffer	#points to address of buffer
	sb $a0, 0($t2)		#dumps 1 nibble into buffer
	sb $zero, 1($t2)	#dumps Null into second bufer space
	move $a0, $t2		#prep for syscall
	li $v0, 4
	syscall
	
	jr $ra
	

	
	
	
