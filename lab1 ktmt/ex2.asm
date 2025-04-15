.data
    array:      .space 20           # Array 5 phần tử
    prompt1:    .asciiz "Please input element "
    prompt2:    .asciiz ": "
    prompt_index: .asciiz "Please enter index: "
    newline:    .asciiz "\n"

.text
main:
    # Khởi tạo biến
    li $t0, 0               # $t0 là chỉ số i (từ 0 đến 4)
    la $t1, array           # $t1 là địa chỉ gốc của mảng

input_loop:
    # In "Please input element "
    li $v0, 4		     #sycall 4 in chuỗi
    la $a0, prompt1
    syscall

    # In chỉ số i
    li $v0, 1               # Syscall 1 in số nguyên
    move $a0, $t0           # In giá trị chỉ số i
    syscall

    # In ": "
    li $v0, 4		    #syscall 4 in chuỗi
    la $a0, prompt2
    syscall

    # Input số nguyên
    li $v0, 5               # Syscall 5 nhập số nguyên
    syscall
    sw $v0, 0($t1)          # Lưu số vừa nhập vào mảng tại vị trí $t1

    # Tăng chỉ số và con trỏ
    addi $t0, $t0, 1        # i = i + 1
    addi $t1, $t1, 4        # Tăng con trỏ mảng lên 4 byte (mỗi phần tử 4 byte)

    # Condition check (i < 5)
    blt $t0, 5, input_loop  # Nếu i < 5, tiếp tục vòng lặp

    # Thông báo yêu cầu input inde
    li $v0, 4		    #sycall 4 in chuỗ
    la $a0, prompt_index
    syscall

    # Input
    li $v0, 5               # syscall 5: nhận số nguyên
    syscall
    move $t2, $v0           # Lưu chỉ số vào $t2

    # Tính địa chỉ của phần tử tại chỉ số được chọn
    la $t1, array           # $t1 là địa chỉ gốc của mảng
    sll $t3, $t2, 2         # $t3 = index * 4 (mỗi phần tử 4 byte)
    add $t1, $t1, $t3       # $t1 = địa chỉ gốc + (index * 4)

    # Đọc giá trị tại địa chỉ đó
    lw $t4, 0($t1)          # $t4 = array[index]

    # In giá trị
    li $v0, 1               # System call 1: in số nguyên
    move $a0, $t4           # In giá trị trong $t4
    syscall

    # In xuống dòng
    li $v0, 4
    la $a0, newline
    syscall

    # Kết thúc chương trình
    li $v0, 10
    syscall