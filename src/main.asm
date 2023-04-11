org 0x7C00
bits 16

start:
    jmp main

main:
    ; Debugging output
    mov ax, 0
    mov bh, 0
    mov bl, 0x07       ; Set BL to the attribute to use (white on black)

    mov ah, 0x0e
    mov al, 'H'
    int 0x10

    mov al, 'e'
    int 0x10

    mov al, 'l'
    int 0x10

    mov al, 'l'
    int 0x10

    mov al, 'o'
    int 0x10

    mov al, 0x20
    int 0x10

    mov al, 'W'
    int 0x10

    mov al, 'o'
    int 0x10

    mov al, 'r'
    int 0x10

    mov al, 'l'
    int 0x10

    mov al, 'd'
    int 0x10

    mov al, 0x0d       ; Set AL to the ASCII code for the carriage return character
    int 0x10           ; Call the BIOS video interrupt to write a CR to the screen

    mov al, 0x0a       ; Set AL to the ASCII code for the line feed character
    int 0x10           ; Call the BIOS video interrupt to write a LF to the screen

    hlt

    .halt:
        jmp .halt

times 510-($-$$) db 0
db 0x55, 0xAA