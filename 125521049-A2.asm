# data segment
.data

str2float: .float 0.0
prompt1: .asciiz   "Ruairi Counihan 125521049 is implementing the CORE assignment\n"
prompt2: .asciiz  "Enter a real number [xxx.yyy]"
string_number: .space 20
nibble_buffer: .space 2		#need this because syscall 11 isnt allowed
dividor: .asciiz " | "
newline: .asciiz "\n"


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
	move $s0, $a0	#$s0 should now be pointing at the '.' as we have incremented it to that point in parse_digits
	lb $t0, 0($s0)
	bne $t0, 46, parse_complete	#checking for '.' adn also skips onto parse_complete if no '.' was entered i.e 123
	addi $s0, $s0, 1	#skipping over '.'
	
fracloop:
	#parsing the yyy
	move $a0, $s0
	jal parse_digits
	move $s3, $v0		#yyy saved into $s3
	move $s4, $v1		#store scale factor for yyy (divisor)
	
	
#at this stage we want to move the integer and decimal into the coproc reg
parse_complete:
	#doing floating point
	mtc1 $s2, $f0	#moves into $f0
	cvt.s.w $f0, $f0	#$f0 is = xxx.000
	
	mtc1 $s3, $f1
	cvt.s.w $f1, $f1		#$f1 is = yyy.000
	
	mtc1 $s4, $f2		#scale factor for yyy
	cvt.s.w $f2, $f2
	
	div.s $f1, $f1, $f2	#$f1 is = yyy/scale
				#dividing yyy by the scale factor
	
	add.s $f0, $f0, $f1	#adding xxx and .yyy together so we get xxx.yyy
	
	beq $s1, 0, store_float #jumps to store_float if no negative
	neg.s $f0, $f0		#changes to negative in coproc if negative was entered. This is skipped by line above if no negative
	
store_float:
	s.s $f0, str2float	#store the float in the data segment
		

# at this stage str2float contains IEEE value of input string 
# now im moving on to print this

	lw $a0, str2float	#$a0 contains value of reg
	jal extract_float
	#when we return, $s1,$s2,$s3 contain clean sign, exponent and mantissa
	
	#first print sign 
	move $a0, $s1	#moved sign into $a0
	li $a1, 1	#sign is just 1 nibble
	jal print_hex_string

	#insert dividor
	la $a0, dividor
	li $v0, 4
	syscall
	
	#now print exponenet
	move $a0, $s2	#moved exponenet into $a0
	li $a1, 2	#exponent is just 2 nibble
	jal print_hex_string
	
	#insert dividor
	la $a0, dividor
	li $v0, 4
	syscall
	
	#now print mantissa
	move $a0, $s3	#moved mantissa into $a0
	li $a1, 6	#mantissa is 23 bits so 6 nibbles
	jal print_hex_string
	
	#insert new line
	la $a0, newline
	li $v0, 4
	syscall



	li $v0, 10
	syscall
	
	
	
#generic function that converts a string of ascii digits into an integer accumilator 
#$a0 is the string to be processed 
#$v0 is the integer that will multiply by 10 and accumilate each char as its processed	
	
parse_digits:
	li $v0, 0	#intitialises 0 into $v0 
	li $v1, 1	#will count number of chars - i.e divisor for yyy

parse_loop:
	lb $t0, 0($a0)			#gets first digit of number
	
	#next 2 lines ensure return on meeting a non numeric char i.e '.' or '\n'
	
	blt $t0, 48, parse_done	 	#48 is ascii value for 0
	bgt $t0, 57, parse_done		#57 is ascii value for 9
					#also kicks me out of loop when the '.' is reached 
	mul $v0, $v0, 10		#moving the digits 'to the left' for values that are xxx
	subi $t0, $t0, 48		#convert ascii to int
	add $v0, $v0, $t0
	
	mul $v1, $v1, 10		#for every y thats seen we need to x 10
	
	addi $a0, $a0, 1		#moves the pointer along to get next digit for loop
	j parse_loop

parse_done:
	jr $ra
				
		
	
	
	
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
	
	

	
