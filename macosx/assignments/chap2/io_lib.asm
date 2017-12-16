; io_lib.asm - A Collection of some useful I/O functions
; Consult section 2.7 Assignment: Input/Output library for more
; informations.
; =============================================================

section .text

; exit - Accepts an exit code and terminates current process
; rdi - Argument #1, the exit code
; ==========================================================
exit:
    mov rax, 0x2000001          ; exit syscall number
    syscall

; string_length - Accepts a pointer to a null-terminated string
; and returns its length.
; rdi - Argument #1, the pointer to a null-terminated string
; @returns rax, the length of the given string.
; ============================================================
string_length:
    xor rax, rax                ; equivalent to mov rax, 0 but less expensive
.iterate:
    cmp byte [rdi + rax], 0     ; Is the current char a null char '\0'
    je .end                     ; If yes, terminate the loop, and go to .end
    inc rax                     ; If no, increment rax by 1
    jmp .iterate                ; and move on to the next iteration
.end:
    ret                         

; print_string - Accepts a pointer to a null-terminated string
; and outputs it to stdout
; rdi - Argument #1, the pointer to a null-terminated string
; ============================================================
print_string:
    push rdi
    call string_length
    mov rdx, rax                ; #bytes to write
    pop rsi                     ; starting address of the input string
    mov rdi, 1                  ; stdout file descriptor
    mov rax, 0x2000004          ; write syscall number
    syscall

; print_char - Accepts a character code directly as its
; first argument and outputs it to stdout.
; rdi - Argument #1, the character code
; ===========================================================
print_char:
    push rdi
    pop rsi
    mov rdi, 1                  ; stdout file descriptor
    mov rdx, 1                  ; #bytes to write
    mov rax, 0x2000004          ; write syscall number
    syscall

; print_newline - Outputs the new line character to stdout.
; =========================================================
print_newline:
    mov rdi, 10                 ; 10 is the character code of new line
                                ; in decimal form. (man ascii)  
    jmp print_char

; print_uint - Takes an 8-byte unsigned integer as its
; first argument and outputs it to stdout in decimal format.
; rdi - Argument #1, the 8-byte unsigned integer
; ===========================================================
print_uint:
    mov rax, rdi                
    mov rdi, rsp
    push 0                      ; Allocate 8 byte, zero-initilized on stack
    sub rsp, 16                 ; Allocate 16 more bytes on stack
    dec rdi                     
    mov r8, 10                  

.iterate:
    xor rdx, rdx                ; Result of rax%10 will be sotred in rdx
    div r8                      ; equivalent to rax = rax/r8 and dl = rax%r8
    or dl, 0x30                 ; Convert to decimal digit
    dec rdi                     ; Where to write next digit?
    mov [rdi], dl               ; Store decimal digit
    test rax, rax               
    jnz .iterate                
    
    call print_string           
    add rsp, 24                 ; Restore stack states
    ret
    
