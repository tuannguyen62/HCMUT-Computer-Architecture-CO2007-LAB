# Chương trình MIPS để tính tích phân xác định
# f(x) = ∫(v to u) (a*x^6 + b*x^5 + c*x) / (d^4 + e^3) dx
# Kết quả làm tròn chính xác đến 4 chữ số thập phân

.data
prompt_u: .asciiz "Please insert u: "
prompt_v: .asciiz "Please insert v: "
prompt_a: .asciiz "Please insert a: "
prompt_b: .asciiz "Please insert b: "
prompt_c: .asciiz "Please insert c: "
prompt_d: .asciiz "Please insert d: "
prompt_e: .asciiz "Please insert e: "
result_msg: .asciiz "The result is "
newline: .asciiz "\n"

# Hằng số cần thiết
one: .float 1.0
two: .float 2.0
six: .float 6.0
seven: .float 7.0
scale: .float 10000.0   # Để làm tròn đến 4 chữ số thập phân
scale_100k: .float 100000.0  # Để kiểm tra chữ số thứ 5

.text
main:
    # Nhập u
    li $v0, 4
    la $a0, prompt_u
    syscall
    li $v0, 6
    syscall
    mov.s $f1, $f0      # Lưu u vào $f1

    # Nhập v
    li $v0, 4
    la $a0, prompt_v
    syscall
    li $v0, 6
    syscall
    mov.s $f2, $f0      # Lưu v vào $f2

    # Nhập a
    li $v0, 4
    la $a0, prompt_a
    syscall
    li $v0, 6
    syscall
    mov.s $f3, $f0      # Lưu a vào $f3

    # Nhập b
    li $v0, 4
    la $a0, prompt_b
    syscall
    li $v0, 6
    syscall
    mov.s $f4, $f0      # Lưu b vào $f4

    # Nhập c
    li $v0, 4
    la $a0, prompt_c
    syscall
    li $v0, 6
    syscall
    mov.s $f5, $f0      # Lưu c vào $f5

    # Nhập d
    li $v0, 4
    la $a0, prompt_d
    syscall
    li $v0, 6
    syscall
    mov.s $f6, $f0      # Lưu d vào $f6

    # Nhập e
    li $v0, 4
    la $a0, prompt_e
    syscall
    li $v0, 6
    syscall
    mov.s $f7, $f0      # Lưu e vào $f7

    # In thông báo kết quả
    li $v0, 4
    la $a0, result_msg
    syscall

    # Tính d^4 + e^3
    mul.s $f8, $f6, $f6     # $f8 = d^2
    mul.s $f8, $f8, $f8     # $f8 = d^4
    mul.s $f9, $f7, $f7     # $f9 = e^2
    mul.s $f9, $f9, $f7     # $f9 = e^3
    add.s $f8, $f8, $f9     # $f8 = d^4 + e^3
    lwc1 $f10, one
    div.s $f8, $f10, $f8    # $f8 = 1/(d^4 + e^3)

    # Tính u^2, v^2
    mul.s $f11, $f1, $f1    # $f11 = u^2
    mul.s $f12, $f2, $f2    # $f12 = v^2

    # Tính c/2 * (u^2 - v^2)
    lwc1 $f10, two
    div.s $f13, $f5, $f10   # $f13 = c/2
    sub.s $f14, $f11, $f12  # $f14 = u^2 - v^2
    mul.s $f14, $f14, $f13  # $f14 = c/2 * (u^2 - v^2)
    mul.s $f14, $f14, $f8   # $f14 = 1/(d^4 + e^3) * [c/2 * (u^2 - v^2)]

    # Tính u^6, v^6
    mul.s $f15, $f11, $f11  # $f15 = u^4
    mul.s $f16, $f12, $f12  # $f16 = v^4
    mul.s $f15, $f15, $f11  # $f15 = u^6
    mul.s $f16, $f16, $f12  # $f16 = v^6

    # Tính b/6 * (u^6 - v^6)
    lwc1 $f10, six
    div.s $f17, $f4, $f10   # $f17 = b/6
    sub.s $f18, $f15, $f16  # $f18 = u^6 - v^6
    mul.s $f18, $f18, $f17  # $f18 = b/6 * (u^6 - v^6)
    mul.s $f18, $f18, $f8   # $f18 = 1/(d^4 + e^3) * [b/6 * (u^6 - v^6)]

    # Tính u^7, v^7
    mul.s $f19, $f15, $f1   # $f19 = u^7
    mul.s $f20, $f16, $f2   # $f20 = v^7

    # Tính a/7 * (u^7 - v^7)
    lwc1 $f10, seven
    div.s $f21, $f3, $f10   # $f21 = a/7
    sub.s $f22, $f19, $f20  # $f22 = u^7 - v^7
    mul.s $f22, $f22, $f21  # $f22 = a/7 * (u^7 - v^7)
    mul.s $f22, $f22, $f8   # $f22 = 1/(d^4 + e^3) * [a/7 * (u^7 - v^7)]

    # Tổng các thành phần
    add.s $f23, $f14, $f18  # $f23 = c/2 * (u^2 - v^2) + b/6 * (u^6 - v^6)
    add.s $f23, $f23, $f22  # $f23 = c/2 * (u^2 - v^2) + b/6 * (u^6 - v^6) + a/7 * (u^7 - v^7)

    # Làm tròn 4 chữ số thập phân
    lwc1 $f24, scale_100k   # $f24 = 100000.0
    mul.s $f25, $f23, $f24  # $f25 = result * 100000
    cvt.w.s $f25, $f25      # Chuyển thành số nguyên

    mfc1 $t0, $f25          # Di chuyển giá trị sang thanh ghi CPU
    li $t1, 10
    div $t0, $t1            # Chia cho 10 để lấy chữ số thứ 5
    mfhi $t2                # $t2 = chữ số thứ 5
    abs $t2, $t2            # Lấy giá trị tuyệt đối của chữ số thứ 5
    mflo $t0                # $t0 = phần nguyên (loại bỏ chữ số thứ 5)

    # Kiểm tra làm tròn
    li $t3, 5
    blt $t2, $t3, no_round  # Nếu chữ số thứ 5 < 5, không làm tròn
    bltz $t0, round_neg     # Nếu số âm, làm tròn âm
    bgez $t0, round_pos     # Nếu số dương, làm tròn dương

round_neg:
    sub $t0, $t0, 1         # Làm tròn xuống (âm hơn)
    j no_round
round_pos:
    add $t0, $t0, 1         # Làm tròn lên (dương hơn)
    j no_round

no_round:
    mtc1 $t0, $f25          # Chuyển giá trị đã làm tròn về FPU
    cvt.s.w $f25, $f25      # Chuyển về số thực
    lwc1 $f24, scale        # $f24 = 10000.0
    div.s $f23, $f25, $f24  # $f23 = result đã làm tròn (chia cho 10000)

    # In kết quả
    li $v0, 2
    mov.s $f12, $f23
    syscall

    # In dòng mới
    li $v0, 4
    la $a0, newline
    syscall

    # Kết thúc chương trình
    li $v0, 10
    syscall
