a200
db 50

a260
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
inc bx	     
mov dl, [bx] 
cmp dl, 41   
db 74 04     
mov ah, 02   
int 21       
db e2 f2     
mov ah, 4c   
int 21


n lab1.com
r cx
500
w
q