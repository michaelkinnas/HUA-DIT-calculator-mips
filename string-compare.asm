.data
input_msg1: .asciiz "Enter first string: "
input_msg2: .asciiz "Enter second string: "
result_msg1: .asciiz "\nYou entered the same string two times"
result_msg2: .asciiz "\nEntered strings are not the same"
input_string1: .space 50
input_string2: .space 50

.text
main:	
	la $a0 input_msg1 #pass 1st message address
	jal printf #printf 1st message
	
	la $a0 input_string1 #address of 1st input buffer
	li $a1 50 #max characters to read
	jal gets
	
	la $a0 input_msg2 #pass 2nd message address
	jal printf #printf 2nd message
	
	la $a0 input_string2 #address of 2nd input buffer
	li $a1 50 #max characters to read
	jal gets
	
	# save $t0 - $t4 to stack (it is not needed for this program, 
	# but it is for the purpose of demonstrating the caller-callee conventions)
	addi $sp, $sp, -16 #reserve 4 integer spaces in the stack and move sp
	sw $t0, 12($sp)	#save temp registers to stack
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $t3, 0($sp)
	
	la $a0 input_string1 #first argument for strcmp
	la $a1 input_string2 #second argument for strcmp	
	jal strcmp
	
	lw $t3, 0($sp) #restore temp registers from stack
	lw $t2, 4($sp)
	lw $t1, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16 #release reserved space from stack and move sp back
	
	beqz $v1 true
	
	#false if string are not equal
	la $a0 result_msg2
	jal printf
	j exit	
	
	#true if strings are equal
	true:
	la $a0 result_msg1
	jal printf
	
	exit:
	li $v1 0 #return 0 to system
	li $v0 10 #call program termination
	syscall	
	
#print message
printf:	
	li $v0, 4	#syscall to print string on screen
	syscall
	jr $ra

#read string from input
gets:
	li $v0, 8	#syscan to read string from input
	syscall
	jr $ra

#compare each character of each string
strcmp:
	li $t3, 0 #initialize loop counter
	
	loop:
	beq $t3, 50, exit_loop #exit loop condition, after 50 loops
	
	lb $t0, 0($a0) #load character from string char
	lb $t1, 0($a1)
	sub $t2, $t0, $t1 #substract the binary representation of each character from both strings
	add $v1, $v1, $t2 #add the result to v1
	
	addi $a0, $a0, 1 #advance counter and next byte/character
	addi $a1, $a1, 1
	addi $t3, $t3, 1	
	j loop
	
	exit_loop:
	jr $ra