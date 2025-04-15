.data
    prompt_a:    .asciiz "Insert a: "
    prompt_b:    .asciiz "Insert b: "
    prompt_c:    .asciiz "Insert c: "
    prompt_d:    .asciiz "Insert d: "
    error_prompt: .asciiz "a + b + c can not be 0"
    result_msg:  .asciiz "F = "
    remainder_msg: .asciiz ", remainder "
    newline:     .asciiz "\n"

.text
main:
    # Nhận a
    li $v0, 4		 #syscall 4 in chuỗi
    la $a0, prompt_a
    syscall
    li $v0, 5		 #syscall 5 nhập số nguyên
    syscall
    move $s0, $v0        # Lưu a vào $s0

    # Nhận b
    li $v0, 4		 #syscall 4 in chuỗi
    la $a0, prompt_b
    syscall
    li $v0, 5		 #syscall 5 nhâp số nguyên
    syscall
    move $s1, $v0        # Lưu b vào $s1

    # Nhận c
    li $v0, 4
    la $a0, prompt_c
    syscall
    li $v0, 5
    syscall
    move $s2, $v0        # Lưu c vào $s2

    # Nhận d
    li $v0, 4
    la $a0, prompt_d
    syscall
    li $v0, 5
    syscall
    move $s3, $v0        # Lưu d vào $s3

    # Tính (a + 10) * (b - d) * (c - 2 * a)
    # a + 10
    addi $t0, $s0, 10    # $t0 = a + 10

    # b - d
    sub $t1, $s1, $s3    # $t1 = b - d

    # 2 * a
    sll $t2, $s0, 1      # $t2 = 2 * a 

    # c - 2 * a
    sub $t3, $s2, $t2    # $t3 = c - 2 * a

    # (a + 10) * (b - d)
    mul $t4, $t0, $t1    # $t4 = (a + 10) * (b - d)

    # (a + 10) * (b - d) * (c - 2 * a)
    mul $t5, $t4, $t3    # $t5 = tử số

    # Tính mẫu: a + b + c
    add $t6, $s0, $s1    # $t6 = a + b
    add $t6, $t6, $s2    # $t6 = a + b + c
    # Nếu a + b + c = 0, báo lỗi và thoát
    bne $t6, $zero, error
error:
    li $v0, 4
    la $a0, error_prompt
    syscall
    j exit

    # Tính F: tử số / mẫu số
    div $t5, $t6         # Chia tử số ($t5) cho mẫu số ($t6)
    mflo $t7             # $t7 = thương (quotient)
    mfhi $t8             # $t8 = dư (remainder)

    # In kết quả
    # In "F = "
    li $v0, 4
    la $a0, result_msg
    syscall

    # In thương
    li $v0, 1
    move $a0, $t7
    syscall

    # In ", remainder "
    li $v0, 4
    la $a0, remainder_msg
    syscall

    # In dư
    li $v0, 1
    move $a0, $t8
    syscall

exit:
    # In xuống dòng
    li $v0, 4
    la $a0, newline
    syscall
    
    # Kết thúc chương trình
    li $v0, 10
    syscall