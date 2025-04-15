.data
    prompt:     .asciiz "Enter your name: "   
    hello:      .asciiz "Hello, "   
    buffer:     .space 256                   

.text
main:
    # Prompt nhập tên
    li $v0, 4              # Syscall 4 in chuỗi
    la $a0, prompt     
    syscall

    # Nhập chuỗi
    li $v0, 8              # Syscall 8 nhập chuỗi
    la $a0, buffer         # Địa chỉ của bộ đệm để lưu chuỗi
    li $a1, 256            # Độ dài tối đa của chuỗi
    syscall

    # Xoá ký tự xuống dòng (\n) trong chuỗi nhập vào
    la $t0, buffer         # Địa chỉ của chuỗi nhập vào
remove_newline:
    lb $t1, 0($t0)         # Đọc từng ký tự trong chuỗi
    beq $t1, 10, end_loop  # Nếu gặp ký tự \n (ASCII 10), thoát vòng lặp
    beq $t1, 0, end_loop   # Nếu gặp ký tự null (kết thúc chuỗi), thoát vòng lặp
    addi $t0, $t0, 1       # Tăng con trỏ lên 1 để đọc ký tự tiếp theo
    j remove_newline
end_loop:
    sb $zero, 0($t0)       # Thay ký tự \n bằng ký tự null để kết thúc chuỗi

    # In "Hello, "
    li $v0, 4              # Syscall 4: in chuỗi
    la $a0, hello          # Địa chỉ của chuỗi "Hello, "
    syscall

    # In tên
    li $v0, 4              # Syscall 4: in chuỗi
    la $a0, buffer         # Địa chỉ của chuỗi tên
    syscall

    # Kết thúc chương trình
    li $v0, 10             
    syscall