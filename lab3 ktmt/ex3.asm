
.data
# Tên file
input_file:    .asciiz "raw_input.txt"
output_file:   .asciiz "formatted_result.txt"

# Thông điệp in ra terminal và file
header:        .asciiz "-Student personal information-\n"
name_msg:      .asciiz "Name: "
id_msg:        .asciiz "ID: "
address_msg:   .asciiz "Address: "
age_msg:       .asciiz "Age: "
religion_msg:  .asciiz "Religion: "
newline:       .asciiz "\n"

# Buffer tạm để lưu chuỗi khi ghi file
buffer:        .space 128

.text
main:
    # Bước 1: Mở file raw_input.txt để đọc
    li $v0, 13              # Mã syscall để mở file
    la $a0, input_file      # Tên file raw_input.txt
    li $a1, 0               # Chế độ đọc (0: read)
    li $a2, 0               # Chế độ bỏ qua
    syscall
    move $s6, $v0           # Lưu file descriptor vào $s6

    # Bước 2: Cấp phát động bộ nhớ trên heap
    li $v0, 9               # Mã syscall để cấp phát động
    li $a0, 128             # Cấp phát 128 byte
    syscall
    move $s0, $v0           # $s0 chứa địa chỉ vùng bộ nhớ được cấp phát

    # Bước 3: Đọc nội dung từ file vào vùng bộ nhớ
    li $v0, 14              # Mã syscall để đọc file
    move $a0, $s6           # File descriptor
    move $a1, $s0           # Địa chỉ vùng bộ nhớ để lưu chuỗi
    li $a2, 128             # Số byte tối đa cần đọc
    syscall

    # Đóng file raw_input.txt
    li $v0, 16              # Mã syscall để đóng file
    move $a0, $s6           # File descriptor
    syscall

    # Bước 4: Mở file formatted_result.txt để ghi
    li $v0, 13              # Mã syscall để mở file
    la $a0, output_file     # Tên file formatted_result.txt
    li $a1, 1               # Chế độ ghi (1: write)
    li $a2, 0               # Chế độ bỏ qua
    syscall
    move $s7, $v0           # Lưu file descriptor vào $s7

    # Bước 5: Phân tích chuỗi và in ra terminal, đồng thời ghi vào file
    # In header
    li $v0, 4
    la $a0, header
    syscall
    # Ghi header vào file
    li $v0, 15
    move $a0, $s7
    la $a1, header
    li $a2, 30              # Độ dài của header
    syscall

    # Tách chuỗi và in từng trường
    move $t0, $s0           # $t0 trỏ đến đầu chuỗi

    # In trường Name
    li $v0, 4
    la $a0, name_msg
    syscall
    # Ghi "Name: " vào file
    li $v0, 15
    move $a0, $s7
    la $a1, name_msg
    li $a2, 6               # Độ dài của "Name: "
    syscall
    jal print_field         # In và ghi trường Name

    # In trường ID
    li $v0, 4
    la $a0, id_msg
    syscall
    # Ghi "ID: " vào file
    li $v0, 15
    move $a0, $s7
    la $a1, id_msg
    li $a2, 4               # Độ dài của "ID: "
    syscall
    jal print_field         # In và ghi trường ID

    # In trường Address
    li $v0, 4
    la $a0, address_msg
    syscall
    # Ghi "Address: " vào file
    li $v0, 15
    move $a0, $s7
    la $a1, address_msg
    li $a2, 9               # Độ dài của "Address: "
    syscall
    jal print_field         # In và ghi trường Address

    # In trường Age
    li $v0, 4
    la $a0, age_msg
    syscall
    # Ghi "Age: " vào file
    li $v0, 15
    move $a0, $s7
    la $a1, age_msg
    li $a2, 5               # Độ dài của "Age: "
    syscall
    jal print_field         # In và ghi trường Age

    # In trường Religion
    li $v0, 4
    la $a0, religion_msg
    syscall
    # Ghi "Religion: " vào file
    li $v0, 15
    move $a0, $s7
    la $a1, religion_msg
    li $a2, 10              # Độ dài của "Religion: "
    syscall
    jal print_field         # In và ghi trường Religion (không cần newline ở cuối)

    # Bước 6: Đóng file formatted_result.txt
    li $v0, 16
    move $a0, $s7
    syscall

    # Kết thúc chương trình
    li $v0, 10
    syscall

# Hàm print_field: In và ghi một trường từ chuỗi (cho đến dấu ',')
print_field:
    move $t1, $t0           # $t1 trỏ đến ký tự hiện tại
print_loop:
    lb $t2, 0($t1)          # Đọc ký tự tại $t1
    beq $t2, 44, end_field  # Nếu gặp dấu ',' (44), kết thúc trường
    beq $t2, 10, end_field  # Nếu gặp ký tự newline (10), kết thúc trường
    beq $t2, 0, end_field   # Nếu gặp ký tự null (0), kết thúc trường

    # In ký tự ra terminal
    li $v0, 11
    move $a0, $t2
    syscall

    # Lưu ký tự vào buffer để ghi file
    sb $t2, buffer($t3)
    addi $t3, $t3, 1

    addi $t1, $t1, 1        # Tăng con trỏ
    j print_loop

end_field:
    # In newline ra terminal
    li $v0, 4
    la $a0, newline
    syscall

    # Ghi trường và newline vào file
    li $v0, 15
    move $a0, $s7
    la $a1, buffer
    move $a2, $t3           # Độ dài của trường
    syscall
    li $v0, 15
    move $a0, $s7
    la $a1, newline
    li $a2, 1               # Độ dài của newline
    syscall

    # Reset buffer và $t3
    li $t3, 0
    move $t4, $zero
reset_buffer:
    beq $t4, 128, end_reset
    sb $zero, buffer($t4)
    addi $t4, $t4, 1
    j reset_buffer
end_reset:

    addi $t1, $t1, 1        # Bỏ qua dấu ','
    move $t0, $t1           # Cập nhật con trỏ $t0
    jr $ra