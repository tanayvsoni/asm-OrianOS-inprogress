org 0x7C00
bits 16         ; 16-bit code

%define ENDL 0x0D, 0x0A

start:
    jmp main

msg_hello: db 'Hello World!', ENDL, 0

print:
    ; Prints a string to the screen
    ; Parms:
    ;   - ds:si points to string
    
        ; Save onto stack
        push si
        push ax
        push bx
    
        .loop:
            lodsb               ; loads next char in al
            or al, al           ; if al is null (0) then order will update zero flag
            jz .print_done      ; jump if zero flag is lit
            
            ; calls bios interrupt
            mov ah, 0x0e        ; need this for print to tty
            mov bh, 0           ; page number
            mov bl, 0x04        ; pixel color in graphics mode (not needed since we are in tty)
            int 0x10            ; interrupt 10 (print to screen)
    
            jmp .loop
        
        .print_done:
            ; Restore from stack
            pop bx
            pop ax
            pop si
            ret

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
    call print
    hlt



times 510-($-$$) db 0
db 0x55, 0xAA