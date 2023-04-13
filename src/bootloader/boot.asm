org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

BOOT:
;
;   FAT12 Header
;   Boot 
;
    jmp main
    times 3-($-$$) db 0x90   ; Support 2 or 3 byte encoded JMPs before BPB, 0x90 = NOP

    OEM_name:               db    "mkfs.fat"
    bytes_per_sector:       dw    512
    sect_per_cluster:       db    1
    reserved_sectors:       dw    1
    num_FAT:                db    2
    num_root_dir_entries:   dw    224
    num_sectors:            dw    2880
    media_Type:             db    0xf0
    num_sectors_per_FAT:    dw    9
    sectors_per_track:      dw    18
    num_heads:              dw    2
    num_hidden_sectors:     dd    0
    num_sectors_huge:       dd    0
    
    ; extended boot record
    drive_num:          db    0
    reserved:           db    0
    signature:          db    0x29
    volume_ID:          dd    0x2d7e5a1a
    volume_label:       db    "ORIAN OS   "
    file_sys_type:      db    "FAT12   "

main:

    ; setup data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00

    ; read something from floppy disk
    ; BIOS should set DL to driv enumber
    mov [drive_num], dl

    mov ax, 1                   ; LBA = 1, second sector
    mov cl, 1                   ; 1 sector to read
    mov bx, 0x7E00              ; data should be after the bootloader
    call disk_read

    ; Print hello world
    mov si, msg_hello
    call puts

    cli
    hlt

;
;   Disk Routines   
;
lba_to_chs:
;
;   Converts an LBA address to a CHS address
;   Parameters:
;       - ax: LBA address
;   Returns:
;       - cx [bits 0-5]: sector number
;       - cx [bits 6-15]: cylinder
;       - dh: head

    ; Push registers onto stack
    push ax
    push dx

    xor dx, dx                      ; dx = 0
    div word [sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                    ; dx = LBA % SectorsPerTrack

    inc dx                          ; dx = (LBA % SectorsPerTrack + 1) = sector
    mov cx, dx                      ; cx = sector
    
    xor dx, dx                      ; dx = 0
    div word [num_heads]            ; ax = (LBA / SectorsPerTrack) / Heads = cylinder            
                                    ; dx = (LBA / SectorsPerTrack) % Headers = head            
    mov dh, dl                      ; dh = head
    mov ch, al                      ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                       ; put upper 2 bits of cylinder in CL

    ; Restore registers
    pop ax
    mov dl, al
    pop ax
    ret

disk_read:
;
;   Reads sectors from a disk
;   Parameters:
;       - ax: LBA address
;       - cl: number of sectors to read (up to 128)
;       - dl: drive number
;       - es:bx: memory address where to store read data
;
    ; Push registers onto stack
    push ax
    push bx
    push cx
    push dx
    push di

    push cx             ; temporarily save CL (number of sectors to read)
    call lba_to_chs     ; compute CHS
    pop ax              ; AL = number of sections to read

    mov ah, 0x02        
    mov di, 3           ; retry count

    .retry:
        ; save all registers, we don't know what bios modifies
        pusha           

        stc             ; set carry flag, some BIOS'es don't set it
        int 0x13        ; carry flag cleared = success
        jnc .done

        ; read failed
        call disk_reset

        dec di
        test di, di
        jnz .retry
    
    .fail:
        ; all attempts have failed
        jmp floppy_error

    .done:
        ; Restore registers
        popa
        pop ax
        pop bx
        pop cx
        pop dx
        pop di
        ret

disk_reset:
;
;   Resets disk controller
;   Parameters:
;       - dl: drive number
;
    ; Save all registers
    pusha   

    mov ah, 0
    stc
    int 0x13
    jc floppy_error

    ; Restore all registers
    popa
    ret

;
;   Error handlers
;
floppy_error:

    mov si, msg_read_failed
    call puts
    jmp .wait_key_and_reboot

    .wait_key_and_reboot:
        mov ah, 0
        int 0x16                ; wait fpr keypress
        jmp 0x0FFFF:0           ; jump to beginning of BIOS, should reboot

;
;   Extra Functions
;
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

msg_hello:          db 'Hello World!', ENDL, 0
msg_read_failed:    db 'Read from disk failed!', ENDL, 0

times 510-($-$$) db 0
db 0x55, 0xAA