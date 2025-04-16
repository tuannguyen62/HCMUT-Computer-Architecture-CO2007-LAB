.data
array: .space 40           # Mảng 10 số nguyên
prompt: .asciiz "Please insert a element: "
newline: .asciiz "\n"
space: .asciiz " "
result_msg: .asciiz "Second largest value is "
index_msg: .asciiz ", found in index "

.text
main:
    # Input 10 số từ người dùng
    la $t0, array        # Địa chỉ mảng

input_loop:
    bge $t1, 10, end_input  # Nếu i >= 10 thì kết thúc
    
    # In thông báo nhập
    la $a0, prompt       # In "Please insert element: "
    li $v0, 4
    syscall   
    
    # Input từ người dùng
    li $v0, 5            # Nhập số nguyên
    syscall
    sw $v0, 0($t0)       # Lưu số vào mảng
    
    addi $t0, $t0, 4     # Tăng địa chỉ mảng
    addi $t1, $t1, 1     # Tăng i
    j input_loop

end_input:

    # Find max và second_max
    la $t0, array        # Địa chỉ mảng
    li $t1, 0            # i = 0
    li $t2, -2147483648  # largest = giá trị nhỏ nhất có thể (MIN_INT)
    li $t3, -2147483648  # second_largest = giá trị nhỏ nhất có thể (MIN_INT)

find_loop:
    bge $t1, 10, end_find  # Nếu i >= 10 thì kết thúc
    
    lw $t4, 0($t0)       # Đọc số tại array[i]
    
    # So sánh với largest
    ble $t4, $t2, check_second  # Nếu array[i] <= largest, kiểm tra second_largest
    move $t3, $t2        # second_largest = largest
    move $t2, $t4        # largest = array[i]
    j next_find

check_second:
    ble $t4, $t3, next_find  # Nếu array[i] <= second_largest, bỏ qua
    beq $t4, $t2, next_find  # Nếu array[i] = largest, bỏ qua
    move $t3, $t4        # second_largest = array[i]

next_find:
    addi $t0, $t0, 4     # Tăng địa chỉ mảng
    addi $t1, $t1, 1     # Tăng biến đếm i
    j find_loop

end_find:
    # In kết quả
    # In "Second largest value is "
    la $a0, result_msg   # In "Second largest value is "
    li $v0, 4
    syscall
    
    move $a0, $t3        # In giá trị lớn thứ hai
    li $v0, 1
    syscall
    
    # In ", found in index "
    la $a0, index_msg    # In ", found in index "
    li $v0, 4
    syscall
    
    # Tìm và in tất cả index của second_largest
    la $t0, array        # Địa chỉ mảng
    li $t1, 0            # i = 0
    li $t5, 0            # Biến để kiểm tra đã in chỉ số đầu tiên chưa

index_loop:
    bge $t1, 10, end_index  # Nếu i >= 10, kết thúc
    
    lw $t4, 0($t0)       # Đọc số tại array[i]
    bne $t4, $t3, next_index  # Nếu array[i] != second_largest, bỏ qua
    
    # In chỉ số
    beq $t5, $zero, first_index  # Nếu là chỉ số đầu tiên, không in dấu cách trước
    la $a0, space        # In dấu cách trước các chỉ số sau
    li $v0, 4
    syscall

first_index:
    move $a0, $t1        # In chỉ số i
    li $v0, 1
    syscall
    li $t5, 1            # Đánh dấu đã in chỉ số đầu tiên

next_index:
    addi $t0, $t0, 4     # Tăng địa chỉ mảng
    addi $t1, $t1, 1     # Tăng biến đếm i
    j index_loop

end_index:
    la $a0, newline      # In dòng mới
    li $v0, 4
    syscall
    
    li $v0, 10           # Thoát chương trình
    syscall