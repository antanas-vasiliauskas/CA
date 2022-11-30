; Antanas Vasiliauskas 3 grupė, 3 užduotis, 18 variantas
%include 'yasmmac.inc'
org 100h                       


section .text                    
    Pradzia:
      jmp Nustatymas                          
    Senas_I88:
      dw 0000, 0000
    input_handle:
      dw 0000
    output_handle:
      dw 0000
    tekstas:
      db  'Baigiame',0Dh, 0Ah, '$'


; Open input file                               // procFOpenForReading, I: ds:dx - ASCIIZ pavadinimas | O: bx - failo deskriptorius, jei CF == 0, CF = 1, jeigu klaida
; Open output file                              // procFOpenForWriting, I: ds:dx - ASCIIZ pavadinimas | O: bx - failo deskriptorius, jei CF == 0, CF = 1, jeigu klaida
; while !EOF and !0x0A and !0x0D
;   read char                                   // procFGetChar, I: bx - failo deskriptorius | O: ax - ar  nuskaitė (0 ar 1), cl - baitas, CF == 1, jeigu klaida
;   write char                                  // procFPutChar, I: bx - failo deskriptorius, al - rašomas baitas | O:  ax - kiek faktiškai įrašė
; Close files                                   // procFClose, I: bx - failo deskriptorius
; iret

Naujas_I88:                                            
      macPushAll

      push ds
      push es
      pop ds
      call procFOpenForReading
      ; Patikriname ar sekmingai atidare faila
      mov ax, 0000
      adc ax, 0
      cmp ax, 0001
      jnz Mark1
      push ds
      push cs
      pop ds
      macPutString "Nepavyko atidaryti duomenu failo.", crlf, '$'
      pop ds
      pop ds
      jmp return

      Mark1:
      mov [cs:input_handle], bx

      pop ds
      mov dx, cx
      
      ; Create file
      mov cx, 0
      mov ah, 3Ch
      int 0x21
      call procFOpenForWriting
      ; Patikriname ar sekmingai atidare faila
      
      mov ax, 0000
      adc ax, 0
      cmp ax, 0001
      jnz Mark2
      push ds
      push cs
      pop ds
      macPutString "Nepavyko atidaryti rezultatu failo.", crlf, '$'
      pop ds
      jmp return

      Mark2:
      mov [cs:output_handle], bx

      ;; Skaitom ir rasom i faila po viena simboli
      StartLoop:
      mov bx, input_handle
            push ds
            push cs
            pop ds
            push dx
            mov cx, 1
            mov dx, .baitas
            mov ah, 0x3F
            int 0x21
            mov cl, [.baitas]
            pop dx
            .baitas:
            db 00
            pop ds
      push ds
      push cs
      pop ds
   push dx
   push ax
   mov dl, cl
   mov ah, 02
   int 0x21
   pop ax
   pop dx
      pop ds
      cmp ax, 0000
      jz EndLoop
      cmp cl, 0x0A
      jz EndLoop
      cmp cl, 0x0D
      jz EndLoop
      mov al, cl
      mov bx, output_handle
      call procFPutChar
      jmp StartLoop
      EndLoop:
      ;;

      ; Uzdarome failus
      mov bx, [cs:input_handle]
      call procFClose
      mov bx, [cs:output_handle]
      call procFClose
      
      
      return:
      macPopAll               
      iret                                         


 
Nustatymas:
        ; Gauname sena 88h  vektoriu
        push    cs
        pop     ds
        mov     ax, 3588h                 ; gauname sena pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-35
        
        ; Saugome sena vektoriu 
        mov     [cs:Senas_I88], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:Senas_I88 + 2], es         ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja 1Ch (taimerio) vektoriu
        ;lea     dx, [Naujas_I88]
        mov     dx,  Naujas_I88
        mov     ax, 2588h                 ; nustatome pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-25
        
        macPutString "OK ...", crlf, '$'
        
        ;lea     dx, [Nustatymas  + 1]       ; dx - kiek baitu  
        mov dx, Nustatymas + 1
        int     27h                       ; Padarome rezidentu
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-27
%include 'yasmlib.asm'        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


