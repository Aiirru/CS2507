# data segment
.data

str2float: .float 0.0
prompt1: .asciiz   "Ruairi Counihan 125521049 is implementing the CORE assignment\n"
prompt2: .asciiz  "Enter a real number [xxx.yyy]"
string_number: .space 20


.text
.globl main
main:
	#printing the prompts
	li $v0, 4
	la $a0, prompt1
	syscall

	li $v0, 4
	la $a0, prompt2
	syscall
	
	#reading user input
	li $v0, 8
	la $a0, string_number
	li $a1, 20
	syscall
	
	#debug
	li $v0, 4
	la $a0, string_number
	syscall
	
	la $s0, string_number
	
	#going to store the result of my parsing as follows:
	li $s1, 0 	#for the sign flag 0 = pos, 1 = neg
	li $s2, 0	#to store integer part xxx
	li $s3, 0	#to store fraction part yyy
	li $s4, 0	#to store the divisor factor, i.e yy = 100, yyy = 1000
	
check_sign:
	lb $t0, 0($s0)
	bne $t0, '-', intloop #branching onwards to loop if sign bit doesnt exist
	li $s1, 1	#recording if it is negative
	addi $s0, $s0, 1 #moving pointer past sign bit if it exists
	
intloop:
	#parsing the integer part xxx
	move $a0, $s0
	jal parse_digits
	move $s2, $v0	#recording xxx
	move $s0, $a0
	lb $t0, 0($s0)
	bne $t0, 46, parse_complete	#checking for '.'
	addi $s0, $s0, 1	#skipping over '.'
	
fracloop:
	#parsing the yyy
	move $a0, $s0
	jal parse_digits
	move $s3, $v0
	move $s4, $v1		#store scale factor for yyy
	
	
#at this stage we want to move the integer and decimal into the coprocessor
parse_complete:
	#doing floating point
	mtc1 $s2, $f0	#moves into $f0
	cvt.s.w $f0, $f0	#$f0 is = xxx.000
	
	mtc1 $s3 $f1
	cvt.s.w $f1 $f1		#$f1 is = yyy.000
	
	mtc1 $s4, $f2		#scale factor for yyy
	cvt.s.w $f2, $f2
	
	div.s $f1, $f1, $f2	#$f1 is = yyy/scale
	
	add.s $f0, $f0, $f1	#adding xxx and .yyy together so we get xxx.yyy
	
	beq $s1, 0, store_float
	neg.s $f0, $f0
	
store_float:
	s.s $f0, str2float	#store the float in the data segment
	
	
	
#generic function that converts a string of ascii digits into an integer accumilator 
#$a0 is the string to be processed 
#$v0 is the integer that will multiply by 10 and accumilate each char as its processed	
	
parse_digits:
	li $v0, 0
	li $v1, 1	#will count number of chars - i.e divisor for yyy

parse_loop:
	lb $t0, 0($a0)			#gets first digit of number
	
	#next 2 lines ensure return on meeting a non numeric char i.e '.' or '\n'
	
	blt $t0, 48, parse_done	 	#48 is ascii value for 0
	bgt $t0, 57, parse_done		#57 is ascii value for 9
	mul $v0, $v0, 10		#moving the digits 'to the left' for values that are xxx
	subi $t0, $t0, 48		#convert ascii to int
	add $v0, $v0, $t0
	
	mul $v1, $v1, 10		#for every y thats seen we need to x 10
	
	addi $a0, $a0, 1		#moves the pointer along to get next digit for loop
	j parse_loop

parse_done:
	jr $ra
				
	
	
	
	

	
