; 2 labaratorine uzduotis 18 variantas Antanas Vasiliauskas
%include 'yasmmac.inc'

org 100h


section .text
    startas:

    macPutString 'Antanas Vasiliauskas 1 kursas 3 grupe', crlf, '$'
    mov bl, byte [0x80] ;- command line argument length
    mov bh, 0
    mov byte [0x81+bx], 00 ;- remove 0D from command line argument
    

    ; Open file
    mov dx, 0x82
    call procFOpenForReading
    mov ax, 0
    adc ax, 0
    cmp ax, 0
    jz opened_input
    macPutString 'Nepavyko atidaryti duomenu failo', crlf, '$'
    jmp program_end
    opened_input:

    macPutString 'Iveskite rezultatu failo pavadinima', crlf, '$'
    mov al, 128
    mov dx, output_filename
    call procGetStr
    macNewLine


    call read_line ; ignore first line
    
    read_loop:
    call read_line
    cmp ax, 0 ; - ax - bytes read. If 0 means EOF
    jz eof_global
    call five_digit_numbers_in_line
    call add_floating_number_in_line
    add [number_count], ax
    jmp read_loop
    
    eof_global:
    call procFClose
    
    ;; Total numbers
    mov ax, [number_count]
    mov dx, number_count_str
    call procUInt16ToStr

    mov ax, [decimal_sum]
    mov dx, decimal_sum_str
    call procInt16ToStr

    mov ax, [floating_sum]
    mov dx, floating_sum_str
    call procUInt16ToStr

    ; Create file
    mov cx, 0
    mov dx, output_filename
    mov ah, 3Ch
    int 0x21    

    mov dx, output_filename
    call procFOpenForWriting


    mov dx, number_count_str
    push bx
    mov bx, -1
    number_of_bytes_loop:
    inc bx
    cmp byte [number_count_str+bx], 00
    jnz number_of_bytes_loop
    mov byte [number_count_str+bx], 0x0A
    mov byte [number_count_str+bx+1], 0x0D
    inc bx
    inc bx
    mov cx, bx
    pop bx
    call procFWrite

    

    mov dx, decimal_sum_str
    push bx
    mov bx, -1
    number_of_bytes_loop2:
    inc bx
    cmp byte [decimal_sum_str+bx], 00
    jnz number_of_bytes_loop2
    mov byte [decimal_sum_str+bx], 0x0A
    mov byte [decimal_sum_str+bx+1], 0x0D
    inc bx
    inc bx
    mov cx, bx
    pop bx
    call procFWrite

    mov dx, floating_sum_str
    push bx
    mov bx, -1
    number_of_bytes_loop3:
    inc bx
    cmp byte [floating_sum_str+bx], 00
    jnz number_of_bytes_loop3
    mov byte [floating_sum_str+bx], 0x0A
    mov byte [floating_sum_str+bx+1], 0x0D
    inc bx
    inc bx
    mov cx, bx
    pop bx
    call procFWrite


    call procFClose

    program_end:
    mov ah, 4Ch
    int 21h

read_line:
    ; Input: bx - file descriptor, variable buffer 256 bytes reserved, variable cursor: dw storing offset from file orgin.
    ; Output ax - how many bytes read. If 0 means EOF. Buffer is filled with string line. Newline is replaced with '$'. Cursor is changed to point to next line.
    
    push bx ; - File descriptor
    
    ; Read 256 bytes to the buffer
    mov dx, buffer
    mov cx, 256
    mov ah, 0x3F
    int 0x21

    ; If EOF, end
    cmp ax, 0
    jz eof
    
    ;find newline
    mov bx, 0
    cr_loop:
    inc bx
    cmp byte [bx + buffer - 1], 0Ah
    jnz cr_loop


    add [cursor], bx
    mov byte [bx+buffer], '$'

    ; fseek to cursor (last newline)
    pop bx
    push ax
    push bx
    push cx
    push dx
    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, [cursor]
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    push bx
    
    eof:
    pop bx
    ret



five_digit_numbers_in_line:
    ; returns result in ax
    push bx
    push cx
    push dx

    mov ax, 0 ; - number count
    mov bx, 0 ; - index in buffer
    mov cl, 1 ; - is number
    mov ch, 0 ; - non-zero reached
    mov dl, 0 ; - digit count
    mov dh, 1 ; - current cell

    mov bx, -1

    buffer_loop:
    mov ch, 0
    inc bx
    cmp byte [buffer+bx], 0x3B
    jnz Mark2
    inc dh
    jmp Mark3
    Mark2:
    cmp byte [buffer+bx], 0x20
    jnz Mark4
    Mark3:
    cmp cl, 0
    jz Mark5
    cmp dl, 5
    jnz Mark5
    inc ax
    Mark5:
    mov cl, 1
    mov dl, 0
    cmp dh, 2
    jg return
    jmp buffer_loop
    Mark4:
    cmp cl, 0
    jz buffer_loop
    cmp byte [buffer+bx], 0x31
    jl Mark10
    cmp byte [buffer+bx], 0x39
    jg Mark10
    inc dl
    mov ch, 1
    jmp buffer_loop
    Mark10:
    cmp byte [buffer+bx], 0x30
    jnz Mark6
    cmp ch, 0
    jz buffer_loop
    inc dl
    jmp buffer_loop
    Mark6:
    cmp dl, 0
    jnz Mark8
    cmp byte [buffer + bx], 0x2B
    jz Mark7
    cmp byte [buffer + bx], 0x2D
    jnz Mark8
    Mark7:
    jmp buffer_loop
    Mark8:
    mov cl, 0
    jmp buffer_loop

    return:
    pop dx
    pop cx
    pop bx
    ret

add_floating_number_in_line:
    ; Changes decimal_sum and floating_sum variables internally
    ; Register states are preserved
    push ax
    push bx
    push cx
    push dx

    ; ah = cell
    ; al = is_positive
    ; ch = which_number
    ; bx = bx
    mov ah, 1
    mov al, 1
    mov ch, 1
    mov bx, -1

    Loop2:
    inc bx
    cmp byte [buffer+bx], 0x0A
    jz OutLoop2
    cmp byte [buffer+bx], 0x3B
    jnz L1
    inc ah
    jmp Loop2
    L1:
    cmp ah, 6
    jl Loop2
    cmp byte [buffer+bx], 0x2B
    jz Loop2
    cmp byte [buffer+bx], 0x2D
    jnz L2
    mov al, 0
    jmp Loop2
    L2:
    cmp ch, 1
    jnz L3
    inc ch
    cmp al, 0
    jz L4
    mov cl, [buffer+bx]
    sub cl, 0x30
    add [decimal_sum], cl
    jmp L5
    L4:
    mov cl, [buffer+bx]
    sub cl, 0x30
    sub [decimal_sum], cl
    L5:
    inc bx
    jmp Loop2

    L3:
    cmp ch, 2
    jnz L6
    inc ch
    cmp al, 0
    jz L7
    push ax
    push dx
    mov al, [buffer+bx]
    sub al, 0x30
    mov cl, 10
    mul cl
    add [floating_sum], ax
    pop dx
    pop ax
    jmp L8

    L7:
    push ax
    push dx
    mov al, [buffer+bx]
    sub al, 0x30
    mov cl, 10
    mul cl
    sub [floating_sum], ax
    pop dx
    pop ax

    L8:
    jmp Loop2
    L6:
    cmp al, 0
    jz L10
    mov cl, [buffer+bx]
    sub cl, 0x30
    add [floating_sum], cl
    jmp OutLoop2
    L10:
    mov cl, [buffer+bx]
    sub cl, 0x30
    sub [floating_sum], cl
    OutLoop2:

    pop dx
    pop cx
    pop bx
    pop ax

    cmp word [floating_sum], 99
    jge L12
    cmp word [floating_sum], -99
    jge L13
    ret
    L12:
    sub word [floating_sum], 100
    inc word [decimal_sum]
    ret
    L13:
    add word [floating_sum], 100
    dec word [decimal_sum]
    ret



    

%include 'yasmlib.asm'


section .data
    input_filename:
        ;'failas.csv', 00
        times 256 db 00
    output_filename:
        times 256 db 00
    debug:
        db 00, 00, crlf, '$'
    buffer:
        times 256 db 00, crlf, '$'
    cursor:
        dw 0000
    number_count:
        dw 0000
    number_count_str:
        times 16 db 00, crlf, '$'
    decimal_sum_str:
        times 16 db 00, crlf, '$'
    floating_sum_str:
        times 16 db 00, crlf, '$'
    decimal_sum:
        dw 0000
    floating_sum:
        dw 0000
    
section .bss
