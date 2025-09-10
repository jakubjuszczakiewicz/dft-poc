BITS 64

SECTION .note.GNU-stack noalloc noexec nowrite progbits

SECTION .text

GLOBAL dft_avx2

; rdi -> output
; rsi -> input
; rdx -> costab
; ecx -> fft_size
dft_avx2:
    push rbx
    push r12
    push r13
    push r14
    push r15

    xorpd xmm0, xmm0
    xor rbx, rbx
dft_avx2_memset:
    movapd [rdi + rbx * 8], xmm0
    movapd [rdi + rbx * 8 + 16], xmm0
    movapd [rdi + rbx * 8 + 32], xmm0
    movapd [rdi + rbx * 8 + 48], xmm0
    add rbx, 8
    cmp rbx, rcx
    jb dft_avx2_memset

    mov r12d, ecx
    shl r12, 2

    mov eax, ecx
    shl rax, 32
    add rax, rcx
    movq xmm15, rax
    movq xmm14, rax
    punpcklqdq xmm15, xmm14

    mov eax, ecx
    shr eax, 2
    mov r8d, eax
    shl rax, 32
    add rax, r8
    movq xmm14, rax
    movq xmm13, rax
    punpcklqdq xmm14, xmm13

    mov eax, ecx
    dec eax
    shl rax, 32
    add rax, rcx
    dec rax
    movq xmm13, rax
    movq xmm12, rax
    punpcklqdq xmm13, xmm12

    xor ebx, ebx
dft_avx2_loop1:
    mov eax, ebx
    shl rax, 32
    movq xmm0, rax
    add rax, rbx
    movq xmm1, rax
    pslld xmm1, 1
    paddq xmm1, xmm0
    mov r8, rbx
    punpcklqdq xmm0, xmm1
    shl r8, 3
    movdqa xmm1, xmm0
    paddd xmm1, xmm14
    movapd xmm4, [rsi + r8]
    movdqa xmm2, xmm0
    movapd xmm5, [rsi + r8 + 16]

    xor r11, r11
dft_avx2_loop2:
    movdqa xmm6, xmm0
    movdqa xmm7, xmm1
    pcmpgtd xmm6, xmm13
    pcmpgtd xmm7, xmm13
    pand xmm6, xmm15
    pand xmm7, xmm15
    psubd xmm0, xmm6
    psubd xmm1, xmm7
    movdqa xmm6, xmm0
    movdqa xmm7, xmm1
    pcmpgtd xmm6, xmm13
    pcmpgtd xmm7, xmm13
    pand xmm6, xmm15
    pand xmm7, xmm15
    psubd xmm0, xmm6
    psubd xmm1, xmm7
    movdqa xmm6, xmm0
    movdqa xmm7, xmm1
    pcmpgtd xmm6, xmm13
    pcmpgtd xmm7, xmm13
    pand xmm6, xmm15
    pand xmm7, xmm15
    psubd xmm0, xmm6
    psubd xmm1, xmm7
    movdqa xmm6, xmm0
    movdqa xmm7, xmm1
    pcmpgtd xmm6, xmm13
    pcmpgtd xmm7, xmm13
    pand xmm6, xmm15
    pand xmm7, xmm15
    psubd xmm0, xmm6
    psubd xmm1, xmm7

    pcmpeqd xmm12, xmm12
    movdqa xmm11, xmm0
    vgatherdpd xmm6, [rdx+8*xmm0], xmm12
    pcmpeqd xmm12, xmm12
    punpckhqdq xmm11, xmm0
    vgatherdpd xmm8, [rdx+8*xmm11], xmm12

    mulpd xmm6, xmm4
    movapd xmm7, [rdi + r11]
    mulpd xmm8, xmm5
    movapd xmm9, [rdi + r11 + 16]
    addpd xmm7, xmm6
    addpd xmm9, xmm8
    movapd [rdi + r11], xmm7
    movapd [rdi + r11 + 16], xmm9

    pcmpeqd xmm12, xmm12
    movdqa xmm11, xmm1
    vgatherdpd xmm6, [rdx+8*xmm1], xmm12
    pcmpeqd xmm12, xmm12
    punpckhqdq xmm11, xmm1
    vgatherdpd xmm8, [rdx+8*xmm11], xmm12

    add r11, r12

    mulpd xmm6, xmm4
    movapd xmm7, [rdi + r11]
    mulpd xmm8, xmm5
    movapd xmm9, [rdi + r11 + 16]
    addpd xmm7, xmm6
    addpd xmm9, xmm8
    movapd [rdi + r11], xmm7
    movapd [rdi + r11 + 16], xmm9

    sub r11, r12
    paddd xmm0, xmm2
    add r11, 32
    paddd xmm1, xmm2
    cmp r11, r12
    jb dft_avx2_loop2

    add rbx, 4
    cmp rbx, rcx
    jb dft_avx2_loop1

dft_avx2_end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
