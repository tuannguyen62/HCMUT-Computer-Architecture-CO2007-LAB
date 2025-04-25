.data
inserta: .asciiz "Please insert a: "
insertb: .asciiz "Please insert b: "
insertc: .asciiz "Please insert c: "
x1: .asciiz "x1 = "
x2: .asciiz "x2 = "
onesol: .asciiz "There is one solution, x = "
equals0: .asciiz "x = "
noreal: .asciiz "There is no real solution"
four: .float 4.0
zero: .float 0.0
minusone: .float -1.0
space: .asciiz "  "
.text
main:
li $v0, 4 
la $a0, inserta
syscall

li $v0,6
syscall
mov.s $f1,$f0#f1 = a


li $v0, 4 
la $a0, insertb
syscall

li $v0,6
syscall
mov.s $f2,$f0#f2 = b

li $v0, 4 
la $a0, insertc
syscall

li $v0,6
syscall
mov.s $f3,$f0#f3 = c



#Tính delta
mul.s $f4,$f2,$f2	#b^2
lwc1 $f5,four		#4
mul.s $f6,$f5,$f1	#4a
mul.s $f7,$f6,$f3#4ac
sub.s $f8,$f4,$f7#b^2-4ac
lwc1 $f9,zero#0
lwc1 $f11,minusone
mul.s $f13,$f11,$f2#-b
add.s $f15,$f1,$f1#2a

c.eq.s $f1,$f9#nếu a=0
bc1t aequals0

c.eq.s $f8,$f9#nếu delta=0
bc1t equalbranch
c.lt.s $f8,$f9#nếu delta<0
bc1t lessbranch

li $v0, 4 
la $a0, x1
syscall

sqrt.s $f10,$f8#can bac 2 delta


sub.s $f14,$f13,$f10#-b-can delta

div.s $f16,$f14,$f15#-b-can delta/2a

mov.s $f12,$f16 
li $v0,2
syscall

li $v0, 4 
la $a0, space
syscall

li $v0, 4 
la $a0, x2
syscall

add.s $f17,$f13,$f10#-b+can delta
div.s $f18,$f17,$f15#-b+can delta/2a
mov.s $f12,$f18
li $v0,2
syscall

j exit

equalbranch:
li $v0, 4 
la $a0, onesol
syscall#in "There is one solution, x = "

div.s $f19,$f13,$f15#-b/2a
mov.s $f12,$f19
li $v0,2
syscall
j exit

lessbranch:
li $v0, 4 
la $a0, noreal#in "There is no real solution"
syscall
j exit

aequals0:
li $v0, 4 
la $a0, equals0#in "x = "
syscall

div.s $f5,$f3,$f2#c/b
mul.s $f6,$f5,$f11#-c/b
mov.s $f12,$f6
li $v0,2
syscall
j exit
exit:
li $v0, 10 #terminate execution
syscall






