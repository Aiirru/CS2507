# data segment
.data

string2float: .float 0.0
prompt1: .asciiz   "Ruairi Counihan 125521049 is implementing the CORE assignment\n"
prompt2: .asciiz  "Enter a real number [xxx.yyy]"

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

