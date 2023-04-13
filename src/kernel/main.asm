org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

main:
    ; start data segments
    mov ax, 0       ; cant write to ds/es directly
    mov ds, ax
    mov es, ax 

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00

    ; print message
    mov si, msg_hello
    call puts
    hlt

    .halt: 
        jmp .halt

puts:
; Prints a string to the screen
; Parms:
;   - ds:si points to string

    ; Save onto stack
    push si
    push ax

    .loop:
        lodsb
        or al, al
        jz .done

        mov ah, 0x0e
        mov bh, 0
        mov bl, 0x07
        int 0x10

        jmp .loop
    
    .done:
        ; Restore from stack
        pop ax
        pop si
        ret

msg_hello: db 'Hello World!', ENDL, 0

times 510-($-$$) db 0
db 0x55, 0xAA