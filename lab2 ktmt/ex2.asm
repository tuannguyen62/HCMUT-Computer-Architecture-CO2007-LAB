.data
prompt_a: .asciiz "a = "
prompt_b: .asciiz "b = "
gcd_msg: .asciiz "GCD="
lcm_msg: .asciiz ", LCM="
newline: .asciiz "\n"
error_msg: .asciiz "Please enter a positive number!\n"

.text
main:
    # Nhập số a
input_a:
    la $a0, prompt_a
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $s0, $v0
    ble $s0, $zero, error_a
    j input_b

error_a:
    la $a0, error_msg
    li $v0, 4
    syscall
    j input_a

    # Nhập số b
input_b:
    la $a0, prompt_b
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $s1, $v0
    ble $s1, $zero, error_b

    # Tính GCD không đệ quy
    move $t0, $s0       # t0 = a
    move $t1, $s1       # t1 = b
gcd_loop:
    beq $t1, $zero, gcd_done  # Nếu b = 0, GCD là a
    div $t0, $t1        # a / b
    mfhi $t2            # t2 = a % b
    move $t0, $t1       # a = b
    move $t1, $t2       # b = a % b
    j gcd_loop

gcd_done:
    move $s2, $t0       # Lưu GCD vào $s2

    # Tính LCM
    mul $t0, $s0, $s1
    div $t0, $s2
    mflo $s3            # Lưu LCM vào $s3

    # In kết quả
    la $a0, gcd_msg
    li $v0, 4
    syscall
    move $a0, $s2
    li $v0, 1
    syscall
    la $a0, lcm_msg
    li $v0, 4
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
    li $v0, 10
    syscall

error_b:
    la $a0, error_msg
    li $v0, 4
    syscall
    j input_b