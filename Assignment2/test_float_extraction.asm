.data 

str2float: .float -5.55

.text
.globl main
main:
	lw $a0, str2float	#$a0 contains value of reg
	jal extract_float
	#when we return, $s1,$s2,$s3 contain clean sign, exponent and mantissa
	
	li $v0, 10
	syscall
	
extract_float:
	#use $s1 to store sign, $s2 to store exponent, $s3 to store mantissa.
	
	#sign first
	srl $s1, $a0, 31
	
	#exponent
	srl $s2, $a0, 23
	andi $s2, $s2, 0xFF	#masks out the sign if its 1 
	
	#mantissa
	#andi $s3, $s3, 0x7FFFFF	#masks the mantissa (23 digits)
	#doesnt work as andi only takes 16 bits so i will shift left then right instead
	
	sll $s3, $a0, 9
	srl $s3, $s3, 9
	jr $ra