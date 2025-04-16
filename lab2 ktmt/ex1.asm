.data
input:  .asciiz "abdeefgff"  # Input
counts: .space 256           # Mảng đếm số lần xuất hiện (theo mã ASCII)
comma:  .asciiz ", "
semicolon: .asciiz "; "
newline: .asciiz "\n"

.text
main:
    #Đếm số lần xuất hiện của từng ký tự
    la $t0, input           # Địa chỉ chuỗi inout
    la $t1, counts          # Địa chỉ mảng counts
    
count_loop:
    lb $t2, 0($t0)          # Đọc ký tự từ chuỗi
    beq $t2, $zero, end_count  # Nếu gặp ký tự null, kết thúc đếm
    
    # Tăng giá trị đếm tại vị trí tương ứng với mã ASCII của ký tự
    addu $t3, $t1, $t2      # Địa chỉ trong mảng counts
    lb $t4, 0($t3)          # Đọc giá trị hiện tại
    addi $t4, $t4, 1        # Tăng đếm
    sb $t4, 0($t3)          # Lưu lại giá trị
    
    addi $t0, $t0, 1        # Chuyển sang ký tự tiếp theo
    j count_loop

end_count:
    #In kết quả theo thứ tự tăng dần của số lần xuất hiện
    li $s0, 1               # Bắt đầu từ số lần xuất hiện = 1
sort_loop:
    li $t0, 97              # Bắt đầu từ ký tự 'a' (ASCII 97)
    la $t1, counts          # Địa chỉ mảng đếm

char_loop:
    bgt $t0, 122, next_count  # Nếu vượt quá 'z' (ASCII 122), chuyển sang số lần xuất hiện tiếp theo
    addu $t2, $t1, $t0      # Địa chỉ trong mảng đếm
    lb $t3, 0($t2)          # Số lần xuất hiện của ký tự
    bne $t3, $s0, skip_char # Nếu không đúng số lần xuất hiện đang xét, bỏ qua
    
    # In ký tự và số lần xuất hiện
    move $a0, $t0           # In ký tự
    li $v0, 11
    syscall
    
    la $a0, comma           # In dấu ", "
    li $v0, 4
    syscall
    
    move $a0, $t3           # In số lần xuất hiện
    li $v0, 1
    syscall
    
    la $a0, semicolon       # In dấu "; "
    li $v0, 4
    syscall

skip_char:
    addi $t0, $t0, 1        # Chuyển sang ký tự tiếp theo
    j char_loop

next_count:
    addi $s0, $s0, 1        # Tăng số lần xuất hiện cần xét
    bgt $s0, 10, end_program  # Nếu số lần xuất hiện vượt quá 10, kết thúc
    j sort_loop

end_program:
    la $a0, newline         # In chuỗi
    li $v0, 4
    syscall
    
    li $v0, 10              
    syscall