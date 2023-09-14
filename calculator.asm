.data
main_menu_message: .asciiz "\n\nChoose an operation \n1. Addition, 2. Subtraction, 3. Multiplication, 4. Division, 5. Power, 6. Terminate Program\n"
invalid_option: .asciiz "\nPick a number between 1 and 6"
number1_input: .asciiz "\nType first number or M to recall from memory: "
number2_input: .asciiz "\nType second number or M to recall from memory: "
result_msg: .asciiz "\nResult is: "
print_question: .asciiz "\nChoose an option to print\n1. Decimal, 2. Binary, 3. Hexadecimal\n"

input: .space 10

#get input and pass variable to functions
.macro get_input
	li $t0, 0 #flush temp registers
	li $t1, 0
	
	la $a0, number1_input #print message	
	jal printf	
	
	la $a0, input #set input address to argument
	li $a1, 10 #set max chars to read
	jal get_str #call input function
	jal parse_str #parse string to numbers	
	
	addi $s0, $v1, 0 #copy 1st integer to temp 0
	
	la $a0, number2_input #print message	
	jal printf	
	
	la $a0, input #set input address to argument
	li $a1, 10 #set max chars to read
	jal get_str #call input function
	jal parse_str #parse string to numbers
	
	addi $s1, $v1, 0 #copy 1st integer to temp 0
	
	addi $a0, $s0, 0 #restore 1st number from temp to $a0
	addi $a1, $s1, 0 #restore 2nd number from temp to $a1
.end_macro

#print result to terminal
.macro print_result
	li $t5, 0 #flush $t0
	addi $t5, $v1, 0 #backup result to $t0
	
	la $a0, print_question
	li $v0, 4
	syscall
	
	la $a0, input #set input address to argument
	li $a1, 3 #set max chars to read
	jal get_str #call input function
	jal parse_str #parse string to numbers
	
	la $a0, result_msg #print result message
	li $v0, 4
	syscall	
	
	li $a0, 0 #flush $a0
	addi $a0, $t5, 0 #transfer result to $a0
	
	beq $v1, 1, decimal
	beq $v1, 2, binary
	beq $v1, 3, hex	
	
	decimal:
	#la $a0, result_msg
	li $v0, 1
	syscall
	j end_print
	
	binary:
	#la $a0, result_msg
	li $v0, 35
	syscall
	j end_print
	
	hex:
	#la $a0, result_msg
	li $v0, 34
	syscall		
	
	end_print:	
.end_macro

.text		
	menu_loop:
	la $a0, main_menu_message
	jal printf
	
	la $a0, input #set input address to argument
	li $a1, 3 #set max chars to read ---IF SET TO 2 YOU DON'T HAVE TO PRESS ENTER???---
	jal get_str #call input function
	jal parse_str #call parse string function to get number
	
	beq $v1, 1, addition_branch
	beq $v1, 2, subtraction_branch
	beq $v1, 3, multiplication_branch
	beq $v1, 4, division_branch
	beq $v1, 5, power_branch
	beq $v1, 6, terminate_program
	
	la $v0, invalid_option
	jal printf
	j loop
	
	#addition process section
	addition_branch:		
	get_input #call get input macro get user input and pass variables to function	
	jal addition #call addition function	
	print_result #print result to terminal	
	j menu_loop
	
	#subtraction process section
	subtraction_branch:
	get_input #call get input macro get user input and pass variables to function
	jal subtraction #call subtraction function	
	print_result #print result to terminal macro	
	j menu_loop
	
	#multipplication process section
	multiplication_branch:
	get_input #call get input macro get user input and pass variables to function
	jal multiplication #call multiplication function	
	print_result#print result to terminal macro
	j menu_loop
	
	#division process section
	division_branch:
	get_input #call get input macro get user input and pass variables to function
	jal division #call subtraction function	
	print_result #print result to terminal macro	
	j menu_loop
	
	#power process section
	power_branch:
	get_input #call get input macro get user input and pass variables to function
	jal power #call power function
	print_result #print result to terminal macro
	j menu_loop
	
	terminate_program:
	jal terminate

addition:
	add $v1, $a0, $a1
	add $s3, $v1, $zero #copy result to memory
	jr $ra

subtraction:
	sub $v1, $a0, $a1
	add $s3, $v1, $zero #copy result to memory
	jr $ra
	
multiplication:
	mul $v1, $a0, $a1
	add $s3, $v1, $zero #copy result to memory
	jr $ra
	
division:
	div $v1, $a0, $a1
	add $s3, $v1, $zero #copy result to memory
	jr $ra
	
power:	
	li $v1, 0 #flush v0
	add $t0, $a1, 0 #load power into loop 
	loop:						
	beqz $a1, return_one #check if power is zero	
	beqz $t0, finnish_loop #check if loop is finished
	bne $v1, $zero, continue #check if its the first loop
	add $v1, $a0, $zero #add base to result on first loop
	addi $t0, $t0, -1 #reduce loop counter
	j loop
	continue:
	mul $v1, $v1, $a0 #multiply base with itself
	addi $t0, $t0, -1 #reduce loop counter
	j loop
	finnish_loop:
	add $s3, $v1, $zero #copy result to memory
	jr $ra
	return_one:
	li $v1, 1 #return 1 if power is 0
	add $s3, $v1, $zero #copy result to memory
	jr $ra

printf:	
	li $v0, 4	#syscall to print string on screen
	syscall
	jr $ra

get_str:
	li $v0, 8	#syscall to read string from input	
	syscall
	jr $ra

#$t0 loop counter, $t1 ascii characters from string, 
#$t2 true ascii number, $t3 multiples position, $t4 end address
parse_str:	
	li $v1, 0 #flush $v1 register
	li $t0, 0 #initialize loop counter
	
	add $t4, $a0, 0 #copy address
	count_loop:
	
	lb $t1, 0($t4) #read character from address
	beq $t1, $zero, done_counting #end of string
	
	addi $t4, $t4, 1 #advance address
	j count_loop
	
	done_counting:	
	li $t0, 0 #initialize loop counter
	li $t3, 1 #set multiples register
	
	loop2:	
	lb $t1, -1($t4) #read character from address
	beq $t1, 77, memory_recall
	beq $t1, $zero, exit #end of string
	
	ble $t1, 47, continue2 #if its not a number (outside ascii int range) less than 0
	bge $t1, 58, continue2 #if its not a number (outside ascii int range) greater than 9
	
	sub $t2, $t1, 48 #subtract ascii 49 code to get true integer value
	mul $t2, $t2, $t3 #mult to get position value (1s 10s 100s etc...)
	add $v1, $v1, $t2 #add result to $v1
	
	mul $t3, $t3, 10 #advance position value to next value (1s 10s 100s etc...) testing before continue2
	
	continue2:	
	addi $t4, $t4, -1 #advance next string char / byte (go backwards since it starts at the end)
	addi $t0, $t0, 1 #advance counter
	j loop2
	
	return_zero:
	li $v1, 0 #return zero value
	j exit
	
	memory_recall:
	addi $v1, $s3, 0 #return stored memory value
	
	exit:
	jr $ra	
	
terminate:
	li $v0, 10
	syscall