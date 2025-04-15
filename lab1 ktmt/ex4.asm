.data
    prompt:      .asciiz "Please enter a positive integer less than 16: "
    result_msg:  .asciiz "Its binary form is: "
    newline:     .asciiz "\n"
    error_prompt: .asciiz "The number has to be less than 16"
.text
main:
    # In thông báo yêu cầu nhập số
    li $v0, 4
    la $a0, prompt
    syscall

    # Nhận số từ người dùng
    li $v0, 5
    syscall
    move $s0, $v0        # Lưu số vào $s0
    
    # In "Its binary form is: "
    li $v0, 4
    la $a0, result_msg
    syscall

    # Chuyển số thành nhị phân 4-bit
    li $t0, 3            # $t0 là chỉ số bit (từ 3 xuống 0)
    li $t1, 8            # $t1 là giá trị bit (2^3 = 8, 2^2 = 4, 2^1 = 2, 2^0 = 1)

convert_loop:
    # Kiểm tra bit hiện tại
    bge $s0, $t1, print_one  # Nếu số >= giá trị bit, in 1 và trừ đi giá trị bit
    li $v0, 1
    li $a0, 0                # Nếu không, in 0
    syscall
    j next_bit

print_one:
    li $v0, 1
    li $a0, 1                # In 1
    syscall
    sub $s0, $s0, $t1       # Trừ giá trị bit khỏi số

next_bit:
    # Giảm chỉ số bit và cập nhật giá trị bit
    srl $t1, $t1, 1          # Dịch phải 1 bit (chia 2): 8 -> 4 -> 2 -> 1
    addi $t0, $t0, -1        # Giảm chỉ số bit
    bgez $t0, convert_loop   # Nếu chỉ số bit >= 0, tiếp tục vòng lặp

    # In xuống dòng
    li $v0, 4
    la $a0, newline
    syscall

exit:
    # Kết thúc chương trình
    li $v0, 10
    syscall