.data
	input1: .asciiz "Player 1, please input your coordinates: "
	input2: .asciiz "Player 2, please input your coordinates: "
	win1: .asciiz "Player 1 wins"
	win2: .asciiz "Player 2 wins"
	tie: .asciiz "Tie"
	board: .space 225
	board_prompt: .asciiz "Board:\n"
	res_prompt: .asciiz "-\-\-\-Final Result-\-\-\-"
	nl: .asciiz "\n"
	space: .asciiz " "
	output: .asciiz "D:/BK/HK242/CA/Lab/result.txt"
	input_buffer: .space 20
	input_error: .asciiz "Out of bound. Please input again!\n"
	cell_error: .asciiz "Cell already taken. Please choose another one!\n"
	error_message: .asciiz "An error occurred.\n"

.text
	# Open board file
	li $v0, 13
	la $a0, output
	li $a1, 1         		# write mode
	syscall
	
	slti $t1, $v0, 0
	bne $t1, $zero, file_open_failed  
	move $s5, $v0             	# output file descriptor
	
	# Initialize the board with '.'
	la $t0, board
	li $t1, 225
	li $t2, 46		# ASCII '.'

init_board_loop:
    	sb $t2, 0($t0) # store '.' into current cell
    	addi $t0, $t0, 1
    	addi $t1, $t1, -1
    	bnez $t1, init_board_loop
    	jal print_board

	li $t0, 225	# count	

player1_input:
	# Player 1 input
	la $a0, input1
	li $v0, 4
	syscall
	# Read the coordination: x,y
	li $v0, 8
	la $a0, input_buffer
	li $a1, 20
	syscall
	la $t2, input_buffer
	
	li $t1, 0	# Player 1's turn	
	jal handle_board
	# Update invalid cell on board
	addi $t0, $t0, -1
	jal print_board
	j find_path
player2_input:
	# Player 2 input
	la $a0, input2
	li $v0, 4
	syscall
	# Read the coordination: x,y
	li $v0, 8
	la $a0, input_buffer
	li $a1, 20
	syscall
	la $t2, input_buffer
	
	li $t1, 1	# Player 2's turn 	
	jal handle_board
	# Update invalid cell on board
	addi $t0, $t0, -1
	jal print_board
	j find_path

#***************************************#
#************ Handle board *************#
#***************************************#
handle_board:
	li $t3, 0		# row coordination (x)
	li $t4, 0		# col coordination (y)
	li $t5, 0		# flag: 0 = reading first num, 1 = after comma
get_coordination:
	lb $t6, 0($t2)
	beqz $t6, update_board
	beq $t6, 44, switch_to_second_num
	beq $t6, 45, handle_input_error	# ASCII '-'
	li $t7, 48		# ASCII 0
	li $t8, 58		# ASCII 9
	slt $t9, $t6, $t7
	bnez $t9, skip_char
	slt $t9, $t6, $t8
	beqz $t9, skip_char
	
	sub $t6, $t6, $t7	# Convert char to digit
	beqz $t5, add_row
	j add_col
	
add_row:
	mul $t3, $t3, 10
	add $t3, $t3, $t6
	j continue
	
add_col:
	mul $t4, $t4, 10
	add $t4, $t4, $t6
	j continue
	
switch_to_second_num:
	li $t5, 1		# Update flag: 1
	j continue

skip_char:
	j continue

continue: 
	addi $t2, $t2, 1
	j get_coordination

#************* Update board ************#
update_board:
	# Check x > 14
	slti $t2, $t3, 15
	beqz $t2, handle_input_error
	# Check y > 14
	slti $t2, $t4, 15
	beqz $t2, handle_input_error
	
	la $t2, board		# base address of board
	li $t5, 15		# num of col
	
	mul $t5, $t5, $t3	# (x * num_col)
	add $t5, $t5, $t4	# (x * num_col) + y
	add $t5, $t2, $t5	# base addr + ((x * num_col) + y) * 1
	
	lb $t6, 0($t5)
	li $t9, 46		# ASCII '.'
	bne $t6, $t9, handle_cell_error
	
	beqz $t1, update_X
	
	# Update 'O'
	li $t6, 79        	# ASCII of 'O'
	sb $t6, 0($t5)
	jr $ra
	
update_X:
	li $t6, 88        	# ASCII of 'X'
    	sb $t6, 0($t5)
	jr $ra
	
#***************************************#
#************** Find Path **************#
#***************************************#
find_path:
	la $t2, board		# base address of board
	li $t5, 15		# num of col
	
	beqz $t1, set_X
	li $s3, 79
	j horizontal_prepare
set_X:
	li $s3, 88
	
horizontal_prepare:
	li $t3, 0
row_loop:
	li $t4, 0
	li $t8, 0
column_loop:
	mul $t6, $t3, $t5
	add $t6, $t6, $t4
	add $t6, $t2, $t6
	
	lb $t9, 0($t6)
	
	beq $t9, $s3, increase_count
	j reset_count
	
increase_count:
	addi $t8, $t8, 1
	beq $t8, 5, check_condition
	j next_cell
reset_count:
	li $t8, 0
	j next_cell
next_cell:
	addi $t4, $t4, 1
	slti $t7, $t4, 15
	bnez $t7, column_loop
	
	addi $t3, $t3, 1
	slti $t7, $t3, 15
	bnez $t7, row_loop
	
check_vertical:
	li $t4, 0       		# Column index (j)  
    	la $t2, board   		# Base address of board
    	li $t5, 15      		# Board width
    	
column_loop_v:
    	li $t3, 0       	 	# Row index (i)    	
    	li $t8, 0       		# Reset consecutive count for each column
	
row_loop_v:
    	# Compute board address: board + (i * 15) + j
    	mul $t6, $t3, $t5   		# (row_index * num_col)
    	add $t6, $t6, $t4   		# (row_index * num_col) + col_index
    	add $t6, $t2, $t6   		# base_addr + offset

    	# Load the current cell
    	lb $t9, 0($t6)

    	# Check if the cell is the player's mark ($s3 contains 'X' or 'O')
    	beq $t9, $s3, increase_count_v   # If match, increase count
    	j reset_count_v                  # Otherwise, reset count

increase_count_v:
    	addi $t8, $t8, 1   		# Increase the streak count
    	beq $t8, 5, check_condition	# If count reaches 5, jump to win condition
    	j next_row_v        		# Continue checking next row

reset_count_v:
    	li $t8, 0          		# Reset consecutive count
    	j next_row_v        		# Continue checking next row

next_row_v:
    	addi $t3, $t3, 1   		# Move to next row
    	slti $t7, $t3, 15
    	bnez $t7, row_loop_v   		# If not at end of column, continue
    
    	# Finished column, move to next column
    	addi $t4, $t4, 1  
    	slti $t7, $t4, 15
    	bnez $t7, column_loop_v  	# If not at last column, continue
    	
check_diagonal:
    	la $t2, board   
    	li $t5, 15      
# ***** CHECK "\" (TOP-LEFT to BOTTOM-RIGHT) *****
    	li $t3, 0       		# Row index (i)
# Diagonals starting from the top row (row=0, col=0..14)
diag_1_bottom_loop:  
    	li $t4, 0       		# Column index (j)
    	li $t8, 0       		# Reset consecutive count for each diagonal
    	addi $s4, $t3, 0
diag_1_bottom_inner_loop:
    	# Compute board address: board + (i * 15) + j
    	mul $t6, $s4, $t5   
    	add $t6, $t6, $t4  
    	add $t6, $t2, $t6   

    	# Load cell content
    	lb $t9, 0($t6)

    	# Check if the cell matches the player's mark ($s3 contains 'X' or 'O')
    	beq $t9, $s3, increase_count_diag_1_bottom   
    	j reset_count_diag_1_bottom                  

increase_count_diag_1_bottom:
    	addi $t8, $t8, 1   
    	beq $t8, 5, check_condition
    	j diag_1_bottom_next_cell  

reset_count_diag_1_bottom:
    	li $t8, 0      
    	j diag_1_bottom_next_cell 

diag_1_bottom_next_cell:
    	addi $s4, $s4, 1   		# Move diagonally down
    	addi $t4, $t4, 1   
    	slti $t7, $s4, 15
    	bnez $t7, diag_1_bottom_inner_loop   

    	addi $t3, $t3, 1   		# Start from next diagonal
    	slti $t7, $t3, 15
    	bnez $t7, diag_1_bottom_loop  

# Diagonals starting from the left column (col=0, row=1..14)
    	li $t4, 1       		# Column index (i)
# Diagonals starting from the top row (row=0, col=1..14)
diag_1_top_loop:  
    	li $t3, 0       		# Row index (j)
    	li $t8, 0       		# Reset consecutive count for each diagonal
    	addi $s4, $t4, 0
diag_1_top_inner_loop:
    	# Compute board address: board + (i * 15) + j
    	mul $t6, $t3, $t5   
    	add $t6, $t6, $s4  
    	add $t6, $t2, $t6   

    	# Load cell content
    	lb $t9, 0($t6)

    	# Check if the cell matches the player's mark ($s3 contains 'X' or 'O')
    	beq $t9, $s3, increase_count_diag_1_top  
    	j reset_count_diag_1_top                  

increase_count_diag_1_top:
    	addi $t8, $t8, 1   
    	beq $t8, 5, check_condition
    	j diag_1_top_next_cell  

reset_count_diag_1_top:
    	li $t8, 0      
    	j diag_1_top_next_cell 

diag_1_top_next_cell:
    	addi $t3, $t3, 1   		# Move diagonally down
    	addi $s4, $s4, 1   
    	slti $t7, $s4, 15
    	bnez $t7, diag_1_top_inner_loop   

    	addi $t4, $t4, 1   		# Start from next diagonal
    	slti $t7, $t4, 15
    	bnez $t7, diag_1_top_loop 

# ***** CHECK "/" (TOP-RIGHT to BOTTOM-LEFT) *****
    	li $t3, 0  
diag_2_bottom_loop:  
    	li $t4, 14      		# Start from last column
    	li $t8, 0      
    	addi $s4, $t3, 0
diag_2_bottom_inner_loop:
    	la $t2, board   
    	li $t5, 15      
    	mul $t6, $s4, $t5   
    	add $t6, $t6, $t4  
   	add $t6, $t2, $t6   

    	lb $t9, 0($t6)

    	beq $t9, $s3, increase_count_diag_2_bottom   
    	j reset_count_diag_2_bottom                  

increase_count_diag_2_bottom:
    	addi $t8, $t8, 1   
    	beq $t8, 5, check_condition
    	j diag_2_bottom_next_cell  

reset_count_diag_2_bottom:
    	li $t8, 0      
    	j diag_2_bottom_next_cell  

diag_2_bottom_next_cell:
    	addi $s4, $s4, 1   # Move diagonally down
    	subi $t4, $t4, 1   
    	slti $t7, $s4, 15
    	bnez $t7, diag_2_bottom_inner_loop   

    	addi $t3, $t3, 1  
    	slti $t7, $t3, 15
    	bnez $t7, diag_2_bottom_loop  
    	
# ***********************************
	li $t4, 13  
diag_2_top_loop:  
    	li $t3, 0      		# Start from last column
    	li $t8, 0      
    	addi $s4, $t4, 0
diag_2_top_inner_loop:
    	la $t2, board   
    	li $t5, 15      
    	mul $t6, $t3, $t5   
    	add $t6, $t6, $s4  
   	add $t6, $t2, $t6   

    	lb $t9, 0($t6)

    	beq $t9, $s3, increase_count_diag_2_top   
    	j reset_count_diag_2_top                  

increase_count_diag_2_top:
    	addi $t8, $t8, 1   
    	beq $t8, 5, check_condition
    	j diag_2_top_next_cell  

reset_count_diag_2_top:
    	li $t8, 0      
    	j diag_2_top_next_cell  

diag_2_top_next_cell:
    	addi $t3, $t3, 1   # Move diagonally down
    	addi $s4, $s4, -1   
    	slti $t7, $s4, 0
    	beqz $t7, diag_2_top_inner_loop   

    	addi $t4, $t4, -1  
    	slti $t7, $t4, 0
    	beqz $t7, diag_2_top_loop  
	
    	j switch_player
    	
switch_player:
	beqz $t1, player2_input
	bnez $t1, player1_input

check_condition:
	beqz $t1, win_1
	j win_2

#***************************************#
#**************** Result ***************#
#***************************************#
win_1:
	li $v0, 4
	la $a0, win1
	syscall
	j write_board
	
win_2:
	li $v0, 4
	la $a0, win2
	syscall
	j write_board

tie_res:
	li $v0, 4
	la $a0, tie
	syscall
	j write_board
	
#***************************************#
#******* Print board on terminal *******#
#***************************************#
print_board:
    	# Print board prompt
    	li $v0, 4
    	la $a0, board_prompt
    	syscall

    	# Initialize pointers
    	la $t0, board   # Load address of board
    	li $t9, 225     # Total cells
    	li $t2, 15      # Board width (assuming 15x15)

print_loop:
    	# Print cell content
    	li $v0, 11      # syscall for printing a character
    	lb $a0, 0($t0)  # Load board cell
    	syscall

    	# Print a space between cells
    	li $v0, 4
    	la $a0, space
    	syscall

    	# Move to next cell
    	addi $t0, $t0, 1
    	addi $t9, $t9, -1

    	# Check if we need a newline (every 15 cells)
    	div $t3, $t9, $t2   # t3 = remaining cells / 15
    	mfhi $t3            # Get remainder
    	bnez $t3, continue_print  # If remainder != 0, continue

    	# Print newline
    	li $v0, 4
    	la $a0, nl
    	syscall

continue_print:
    	bnez $t9, print_loop # Continue until all cells printed
    	jr $ra  # Return

#***************************************#
#******* Write into outpur file ********#
#***************************************#
write_board:
    	# Write final result heading
    	li $v0, 15         # syscall 15 = write to file
    	move $a0, $s5      # file descriptor (saved earlier)
    	la $a1, res_prompt # pointer to string
    	jal write_string

    	# Write newline
	jal write_newline
	
    	# Write board contents
    	la $t0, board      # starting address of board
    	li $t9, 225        # 15x15 = 225 cells
    	li $t2, 15         # 15 columns per row

write_board_loop:
    	# Write one cell
    	li $v0, 15
    	move $a0, $s5
    	move $a1, $t0      # address of character
    	li $a2, 1          # write 1 byte
    	syscall

    	# Write space
    	li $v0, 15
    	move $a0, $s5
    	la $a1, space
    	li $a2, 1
    	syscall

    	addi $t0, $t0, 1   # move to next cell
    	addi $t9, $t9, -1  # decrement total cell count

    	# Newline after 15 cells
    	div $t3, $t9, $t2
    	mfhi $t3
    	bnez $t3, write_continue

    	li $v0, 15
    	move $a0, $s5
    	la $a1, nl
    	li $a2, 1
    	syscall

write_continue:
    	bnez $t9, write_board_loop
    	
    	beqz $t1, write_win1
    	j write_win2

write_win1:
    	la $a1, win1
    	jal write_string
    	j close_file

write_win2:
    	la $a1, win2
    	jal write_string
    	j close_file

close_file:
    	li $v0, 16    # syscall 16 = close file
    	move $a0, $s5
    	syscall
    	j exit
    	
write_char:
	li $a2, 1
	move $a0, $s5       # output file descriptor
	li $v0, 15
	syscall
	jr $ra
    	
write_newline:
	la $a1, nl
	li $a2, 1
	move $a0, $s5
	li $v0, 15
	syscall
	jr $ra
    	
write_string:
	move $t8, $a1       # start of string

write_loop:
	lb $t2, ($t8)
	beqz $t2, write_done
	move $a1, $t8
	li $a2, 1
	move $a0, $s5
	li $v0, 15
	syscall
	addi $t8, $t8, 1
	j write_loop

write_done:
	jr $ra

exit:
	li $v0, 10
	syscall
	
file_open_failed:
	li $v0, 4                  
	la $a0, error_message       
	syscall                    
	li $v0, 10                 
	syscall
	
handle_input_error:
	la $a0, input_error
	li $v0, 4
	syscall
	beqz $t1, player1_input
	j player2_input
	
handle_cell_error:
	la $a0, cell_error
	li $v0, 4
	syscall
	beqz $t1, player1_input
	j player2_input
