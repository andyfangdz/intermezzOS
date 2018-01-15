; ; boot.asm
; ;
; ; - setup page table
; ; - enable long mode

global start

section .text
bits 32
start:
    ; Point the first entry of the level 4 page table
    ; to the first entry in the p3 table
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax

    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each page tabel level two entry to a page
    mov ecx, 0                    ; counter variable
.map_p2_table:
    mov eax, 0x200000             ; 2MB
    mul ecx                       ; eax = eax * ecx
    or eax, 0b10000011            ; huge page bit: 2MiB pages
    mov [p2_table + ecx * 8], eax ; each entry 8 bytes (64 bit addr space)

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; move page table addr to cr3
    mov eax, p4_table
    mov cr3, eax

    ; eable physical address extension (PAE)
    ; 5th bit of cr4
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    lgdt [gdt64.pointer]

    ; update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    ; jump to long mode!
    jmp gdt64.code:long_mode_start
    hlt

section .bss

align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096


section .rodata
gdt64:
    dq 0
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64
    ; 44: ‘descriptor type’: This has to be 1 for code and data segments
    ; 47: ‘present’: This is set to 1 if the entry is valid
    ; 41: ‘read/write’: If this is a code segment, 1 means that it’s readable
    ; 43: ‘executable’: Set to 1 for code segments
    ; 53: ‘64-bit’: if this is a 64-bit GDT, this should be set


section .text
bits 64
long_mode_start:
    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax
    hlt
