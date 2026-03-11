; 2 уязвимости:
; 1) нет проверки длины пароля (буфер на 16 символов)
;
; 2) т.к. данные лежат в стеке, то можно перезаписать адрес возврата из функции парсинга пароля
;                                                                       и сразу перейти к успеху
; должны перезаписать адрес возврата, который лежит в [sp + 22]
.model tiny
.code
org 100h

LF          equ 0dh          ; символ enter

start:
            mov dx, offset msg_prompt
            mov ah, 9
            int 21h

            call check_password
            cmp al, 0
            je denied

granted:
            mov dx, offset msg_granted
            jmp exit

denied:
            mov dx, offset msg_denied
exit:
            mov ah, 9
            int 21h
            mov ax, 4c00h
            int 21h


; ------stack visualization-----
; |                            |
; |        BP              SP  |
; |        ||              ||  |
; |  00 00 00 | 00 ... 00| 00  |
; |  bk pt BP |  buffer  | fg  |
; |                            |
; ------------------------------

check_password proc
            push bp
            mov bp, sp

            sub sp, 18d

            mov word ptr [bp - 2d], 0   ; is_ok = 0

            ; ввод пароля (уязвимость: нет контроля длины)
            lea si, [bp - 18d]

            call my_gets

            ; проверка пароля (сравнение с "secret")
            mov di, offset correct_pass
            mov cx, 6
            ; сравниваем [ES:DI] и [DS:SI]
            repe cmpsb

            cmp cx, 0
            jne not_match

            mov word ptr [bp - 2d], 1   ; is_ok = 1

not_match:
            mov al, byte ptr [bp - 2d]  ; возвращаем младший байт is_ok
            mov sp, bp
            pop bp

            ret
check_password endp


my_gets proc
            xor bx, bx

read_loop:
            mov ah, 01h
            int 21h

            cmp al, LF
            je  done_read

            mov [si + bx], al
            inc bx
            jmp read_loop

done_read:
            mov byte ptr [si + bx], 0   ; завершающий ноль

            ret
my_gets endp


msg_prompt      db 'Enter password (6 chars): $'
msg_granted     db 'Access granted$'
msg_denied      db 'Access denied$'

correct_pass    db 'secret'

end start
