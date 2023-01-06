a300
db 01 03 04 07

a200
db 50

db 'Ivesk teksta' 0D 0A '$'

a100
mov ah, 09
mov dx, 260
int 21
mov ah, 0A
mov dx, 200
int 21
mov ah, 02
mov dl, 0d
int 21
mov ah, 02
mov dl, 0a
int 21
xor cx, cx
mov bx, 201
mov cl, [bx]
add bl, [bx]
mov dl, [bx]
mov al, 00
clc
push cx
push bx
mov cx 0004
mov bx, cx
push cx
mov dh, dl
mov cl, [bx+300-1]
rcr dh, cl
adc al, 0
pop cx
loopw 12a
pop cx
pop bx
db 74 04
cmp al, 02
db 75 02
mov dl, 31
mov ah, 02
int 21
dec bx 
loopw 123
mov ah, 4c
int 21

n uzd8.com
r cx
500
w
q