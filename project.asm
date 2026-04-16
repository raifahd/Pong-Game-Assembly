; Ping Pong Game - COM Format
[org 0x0100]

jmp start

; Game Configuration
win_width dw 140h
win_height dw 0C8h
bounds dw 6
time_prev db 0

; Ball Properties
ball_init_x dw 0A0h
ball_init_y dw 64h
ball_x dw 0Ah
ball_y dw 0Ah
ball_prev_x dw 0Ah
ball_prev_y dw 0Ah
ball_size dw 04h
ball_vel_x dw 05h
ball_vel_y dw 02h

; Paddle Properties
pad_left_x dw 0Ah
pad_left_y dw 0Ah
pad_left_prev_y dw 0Ah
pad_right_x dw 130h
pad_right_y dw 0Ah
pad_right_prev_y dw 0Ah
pad_width dw 04h
pad_height dw 1Fh
pad_speed dw 0Ah

; Score
score_left db 0
score_right db 0
score_msg_left db 'P1: $'
score_msg_right db 'P2: $'
win_msg_p1 db 'Player 1 Wins! Press R to Restart or ESC to Exit$'
win_msg_p2 db 'Player 2 Wins! Press R to Restart or ESC to Exit$'
game_over db 0


clear_screen:
    mov ah, 00h
    mov al, 13h
    int 10h
    mov ah, 0Bh
    mov bh, 00h
    mov bl, 00h
    int 10h
    ret

reset_ball:
    mov ax, [ball_init_x]
    mov [ball_x], ax
    mov [ball_prev_x], ax
    mov ax, [ball_init_y]
    mov [ball_y], ax
    mov [ball_prev_y], ax
    ret

erase_ball:
    mov cx, [ball_prev_x]
    mov dx, [ball_prev_y]
    
.horizontal:
    mov ah, 0Ch
    xor al, al
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [ball_prev_x]
    cmp ax, [ball_size]
    jng .horizontal
    
    mov cx, [ball_prev_x]
    inc dx
    mov ax, dx
    sub ax, [ball_prev_y]
    cmp ax, [ball_size]
    jng .horizontal
    ret

draw_ball:
    mov cx, [ball_x]
    mov dx, [ball_y]
    
.horizontal:
    mov ah, 0Ch
    mov al, 0Eh
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [ball_x]
    cmp ax, [ball_size]
    jng .horizontal
    
    mov cx, [ball_x]
    inc dx
    mov ax, dx
    sub ax, [ball_y]
    cmp ax, [ball_size]
    jng .horizontal
    ret

erase_paddles:
    mov cx, [pad_left_x]
    mov dx, [pad_left_prev_y]
    
.left_h:
    mov ah, 0Ch
    xor al, al
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [pad_left_x]
    cmp ax, [pad_width]
    jng .left_h
    
    mov cx, [pad_left_x]
    inc dx
    mov ax, dx
    sub ax, [pad_left_prev_y]
    cmp ax, [pad_height]
    jng .left_h
    
    mov cx, [pad_right_x]
    mov dx, [pad_right_prev_y]
    
.right_h:
    mov ah, 0Ch
    xor al, al
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [pad_right_x]
    cmp ax, [pad_width]
    jng .right_h
    
    mov cx, [pad_right_x]
    inc dx
    mov ax, dx
    sub ax, [pad_right_prev_y]
    cmp ax, [pad_height]
    jng .right_h
    ret

draw_paddles:
    mov cx, [pad_left_x]
    mov dx, [pad_left_y]
    
.left_h:
    mov ah, 0Ch
    mov al, 04h
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [pad_left_x]
    cmp ax, [pad_width]
    jng .left_h
    
    mov cx, [pad_left_x]
    inc dx
    mov ax, dx
    sub ax, [pad_left_y]
    cmp ax, [pad_height]
    jng .left_h
    
    mov cx, [pad_right_x]
    mov dx, [pad_right_y]
    
.right_h:
    mov ah, 0Ch
    mov al, 01h
    mov bh, 00h
    int 10h
    inc cx
    mov ax, cx
    sub ax, [pad_right_x]
    cmp ax, [pad_width]
    jng .right_h
    
    mov cx, [pad_right_x]
    inc dx
    mov ax, dx
    sub ax, [pad_right_y]
    cmp ax, [pad_height]
    jng .right_h
    ret

move_ball:
    ; Move horizontally
    mov ax, [ball_vel_x]
    add [ball_x], ax
    
    ; Check left/right boundaries
    mov ax, [bounds]
    cmp [ball_x], ax
    jl .reset
    
    mov ax, [win_width]
    sub ax, [ball_size]
    sub ax, [bounds]
    cmp [ball_x], ax
    jg .reset
    
    ; Move vertically
    mov ax, [ball_vel_y]
    add [ball_y], ax
    
    ; Check top/bottom boundaries
    mov ax, [bounds]
    cmp [ball_y], ax
    jl .flip_y
    
    mov ax, [win_height]
    sub ax, [ball_size]
    sub ax, [bounds]
    cmp [ball_y], ax
    jg .flip_y
    jmp .check_paddles
    
.reset:
    call update_score
    call reset_ball
    ret
    
.flip_y:
    neg word [ball_vel_y]
    jmp .check_paddles
    
.check_paddles:
    ; Check right paddle collision
    mov ax, [ball_x]
    add ax, [ball_size]
    cmp ax, [pad_right_x]
    jng .check_left
    
    mov ax, [pad_right_x]
    add ax, [pad_width]
    cmp [ball_x], ax
    jnl .check_left
    
    mov ax, [ball_y]
    add ax, [ball_size]
    cmp ax, [pad_right_y]
    jng .check_left
    
    mov ax, [pad_right_y]
    add ax, [pad_height]
    cmp [ball_y], ax
    jnl .check_left
    
    neg word [ball_vel_x]
    ret
    
.check_left:
    ; Check left paddle collision
    mov ax, [pad_left_x]
    add ax, [pad_width]
    cmp [ball_x], ax
    jnl .done
    
    mov ax, [ball_x]
    add ax, [ball_size]
    cmp ax, [pad_left_x]
    jng .done
    
    mov ax, [ball_y]
    add ax, [ball_size]
    cmp ax, [pad_left_y]
    jng .done
    
    mov ax, [pad_left_y]
    add ax, [pad_height]
    cmp [ball_y], ax
    jnl .done
    
    neg word [ball_vel_x]
    
.done:
    ret

move_paddles:
    mov ah, 01h
    int 16h
    jz near .done
    
    mov ah, 00h
    int 16h
    
    cmp al, 1Bh
    je near terminate
    
    cmp al, 77h
    je .left_up
    cmp al, 57h
    je .left_up
    
    cmp al, 73h
    je .left_down
    cmp al, 53h
    je .left_down
    jmp .check_right
    
.left_up:
    mov ax, [pad_speed]
    sub [pad_left_y], ax
    mov ax, [bounds]
    cmp [pad_left_y], ax
    jl .fix_left_top
    jmp .check_right
    
.fix_left_top:
    mov [pad_left_y], ax
    jmp .check_right
    
.left_down:
    mov ax, [pad_speed]
    add [pad_left_y], ax
    mov ax, [win_height]
    sub ax, [bounds]
    sub ax, [pad_height]
    cmp [pad_left_y], ax
    jg .fix_left_bottom
    jmp .check_right
    
.fix_left_bottom:
    mov [pad_left_y], ax
    
.check_right:
    cmp al, 6Fh
    je .right_up
    cmp al, 4Fh
    je .right_up
    
    cmp al, 6Ch
    je .right_down
    cmp al, 4Ch
    je .right_down
    jmp .done
    
.right_up:
    mov ax, [pad_speed]
    sub [pad_right_y], ax
    mov ax, [bounds]
    cmp [pad_right_y], ax
    jl .fix_right_top
    jmp .done
    
.fix_right_top:
    mov [pad_right_y], ax
    jmp .done
    
.right_down:
    mov ax, [pad_speed]
    add [pad_right_y], ax
    mov ax, [win_height]
    sub ax, [bounds]
    sub ax, [pad_height]
    cmp [pad_right_y], ax
    jg .fix_right_bottom
    jmp .done
    
.fix_right_bottom:
    mov [pad_right_y], ax
    
.done:
    ret

print_scores:
    push ax
    push bx
    push cx
    push dx
    
    ; Print P1 score (top left)
    mov ah, 02h
    mov bh, 00h
    mov dh, 0
    mov dl, 2
    int 10h
    
    mov ah, 09h
    mov dx, score_msg_left
    int 21h
    
    ; Convert score to decimal
    mov al, [score_left]
    xor ah, ah
    mov bl, 10
    div bl          ; AL = tens, AH = ones
    
    ; Print tens digit (if not zero)
    cmp al, 0
    je .skip_tens_left
    push ax
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    jmp .print_ones_left
    
.skip_tens_left:
    ; If tens is 0, print space for alignment
    push ax
    mov dl, ' '
    mov ah, 02h
    int 21h
    pop ax
    
.print_ones_left:
    ; Print ones digit
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ; Print P2 score (top right)
    mov ah, 02h
    mov bh, 00h
    mov dh, 0
    mov dl, 30
    int 10h
    
    mov ah, 09h
    mov dx, score_msg_right
    int 21h
    
    ; Convert score to decimal
    mov al, [score_right]
    xor ah, ah
    mov bl, 10
    div bl
    
    ; Print tens digit (if not zero)
    cmp al, 0
    je .skip_tens_right
    push ax
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    jmp .print_ones_right
    
.skip_tens_right:
    ; If tens is 0, print space for alignment
    push ax
    mov dl, ' '
    mov ah, 02h
    int 21h
    pop ax
    
.print_ones_right:
    ; Print ones digit
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

update_score:
    ; Check if ball went past left boundary (right player scores)
    mov ax, [bounds]
    cmp [ball_x], ax
    jl .right_scores
    
    ; Check if ball went past right boundary (left player scores)
    mov ax, [win_width]
    sub ax, [ball_size]
    sub ax, [bounds]
    cmp [ball_x], ax
    jg .left_scores
    ret
    
.left_scores:
    inc byte [score_left]
    cmp byte [score_left], 10
    jge .p1_wins
    ret
    
.right_scores:
    inc byte [score_right]
    cmp byte [score_right], 10
    jge .p2_wins
    ret
    
.p1_wins:
    mov byte [game_over], 1
    ret
    
.p2_wins:
    mov byte [game_over], 2
    ret

show_winner:
    call clear_screen
    
    ; Set cursor to middle of screen
    mov ah, 02h
    mov bh, 00h
    mov dh, 12
    mov dl, 2
    int 10h
    
    ; Display winner message
    mov ah, 09h
    cmp byte [game_over], 1
    je .show_p1
    mov dx, win_msg_p2
    jmp .display
    
.show_p1:
    mov dx, win_msg_p1
    
.display:
    int 21h
    
.wait_input:
    mov ah, 00h
    int 16h
    
    cmp al, 'r'
    je .restart
    cmp al, 'R'
    je .restart
    cmp al, 1Bh
    je terminate
    jmp .wait_input
    
.restart:
    mov byte [score_left], 0
    mov byte [score_right], 0
    mov byte [game_over], 0
    ret

draw_center_line:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, [win_width]
    shr cx, 1           ; Divide by 2 to get center X position
    mov dx, 0           ; Start from top
    
.draw_line:
    ; Draw a dot every 8 pixels (creates dashed effect)
    mov ax, dx
    and ax, 0Fh         ; Check if current Y mod 16 < 8
    cmp ax, 8
    jge .skip_dot
    
    mov ah, 0Ch
    mov al, 0Fh         ; White color
    mov bh, 00h
    int 10h
    
.skip_dot:
    inc dx
    cmp dx, [win_height]
    jl .draw_line
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

terminate:
    mov ah, 00h
    mov al, 02h
    int 10h
    mov ax, 4C00h
    int 21h

start:
    call clear_screen
    call draw_center_line
    call reset_ball
    
.game_loop:
    ; Check if game is over
    cmp byte [game_over], 0
    jne .winner
    
    mov ah, 2Ch
    int 21h
    cmp dl, [time_prev]
    je .game_loop
    
    mov [time_prev], dl
    
    mov ax, [ball_x]
    mov [ball_prev_x], ax
    mov ax, [ball_y]
    mov [ball_prev_y], ax
    call erase_ball
    
    mov ax, [pad_left_y]
    mov [pad_left_prev_y], ax
    mov ax, [pad_right_y]
    mov [pad_right_prev_y], ax
    call erase_paddles
    
    call move_ball
    call move_paddles
    call draw_ball
    call draw_paddles
    call draw_center_line
    call print_scores
    jmp .game_loop
    
.winner:
    call show_winner
    jmp start