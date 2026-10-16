# data segment
.data

string2float: .float 0.0
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
	
	
	
	

	