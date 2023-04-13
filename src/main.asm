org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

boot:
    jmp main
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

    ; Dos 4.0 EBPB 1.44MB floppy
    OEMname:           db    "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw    512
    sectPerCluster:    db    1
    reservedSectors:   dw    1
    numFAT:            db    2
    numRootDirEntries: dw    224
    numSectors:        dw    2880
    mediaType:         db    0xf0
    numFATsectors:     dw    9
    sectorsPerTrack:   dw    18
    numHeads:          dw    2
    numHiddenSectors:  dd    0
    numSectorsHuge:    dd    0
    driveNum:          db    0
    reserved:          db    0
    signature:         db    0x29
    volumeID:          dd    0x2d7e5a1a
    volumeLabel:       db    "NO NAME    "
    fileSysType:       db    "FAT12   "

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
    ; -ds:si points to string

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