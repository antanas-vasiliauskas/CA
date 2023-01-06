.model small
.stack 100h
.data 
	labas: int 21h
	msg db "Labas pasauli", 10, 13, "$"
.code
	mov ax, @data
	mov ds, ax

	mov ah, 9
	mov dx, offset msg
	int 21h

	mov ah, 4Ch
	mov al, 0
	int 21h
END
