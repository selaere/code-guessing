entry:
    pop r30  ; terminal stream pointer
    pop r0
    pop r1  ; unused
    pop r1  ; unused
    pop r1  ; unused
    cmp r0, 0
    ifz mov r0, default_filename
    mov r1, 1    ; read from our own disk
    mov r2, file_struct
    call open
    cmp r0, 0
    ifnz jmp no_error_read
    mov r0, 20
    mov r1, r30
    mov r2, msg_error_read
    call write
    call end_current_task
no_error_read:
    mov r0, file_struct
    call get_size
    mov r3, r0         ; r3: file size left
read_more:
    call read_to_buf
    mov r0, buffer
    mov r31, r4
count_loop:
    mov.8 r1, [r0]     ; r1 = char
    and r1, 0x7F
    sla r1, 2
    add r1, arr
    inc [r1]

    inc r0
    loop count_loop

    cmp r3, 0
    ifnz jmp read_more

; FREQUENCY ANALYSIS
    mov r5, 0     ; r5 = current character
    mov r6, arr   ; r6 = pointer to end of queue
    mov r31, 128
add_queue_loop:
    mov r1, r5
    sla r1, 2
    add r1, arr
    mov r0, [r1]  ; read frequency
    cmp r0, 0
    sla r0, 8
    ifz jmp no_add
    or r0, r5     ; frequency + character
    call insert
no_add:
    inc r5
    loop add_queue_loop

; HUFFMAN TREE
tree_loop:
    mov r0, [arr]
    call extract  ; pop

    cmp arr, r6
    ifz jmp tree_finished

    mov r1, [arr]
    call extract  ; pop
    mov r10, r0
    and r10, 0xff
    xor r0, r10
    mov r11, r1
    and r11, 0xff
    xor r1, r11
    sla r11, 8
    or  r10, r11  ; r10 = combined node
    add r0, r1    ; sum of probabilities << 8
    mov r1, r6
    add r1, 4     ; pointer to new node (leaving 1 empty to insert later)
    mov [r1], r10
    sub r1, arr
    sra r1, 2     ; index of new node (positive)
    or  r1, 0x80
    or  r0, r1    ; full item
    call insert
    jmp tree_loop
tree_finished:
    ; last node at r0 which should have frequency = sample length
    and r0, 0xff
    mov r7, 0     ; sequence length
    mov r8, 0     ; sequence
    call traverse
    
; ENCODING
    mov r9, 39
    mov r0, 0
    mov r1, file_struct
    call seek
    ; same loop as above really
    mov r0, file_struct
    call get_size
    mov r3, r0          ; r3: file size left
read_more2:
    call read_to_buf
    mov r0, buffer
    mov r31, r4
encode_loop:
    movz.8 r1, [r0]     ; r1 = char
    sla r1, 3
    add r1, code
    mov r7, [r1]
    mov r8, [r1+4]
    call print_binary
    inc r0
    loop encode_loop
    cmp r3, 0
    ifnz jmp read_more2
    call print_nl
    call end_current_task

; clobbers r1,r2
; inout r3: size left
; out r4: amount read
read_to_buf:
    mov r4, r3
    cmp r4, 256
    ifgt mov r4, 256
    mov r0, r4
    mov r1, file_struct
    mov r2, buffer
    call read
    sub r3, r4
    ret


; in r0: item
; clobbers r2,r3
; inout r6: pointer to end of queue
insert:
    mov [r6], r0  ; insert item to the end
    mov r2, r6
    add r6, 4
heap_up:
    ; r2 = current item. if r2 == arr it's the top node
    cmp r2, arr
    ifz ret

    mov r3, r2
    sub r3, arr
    sub r3, 4
    sra r3, 1
    and r3, 0xfffffffc
    add r3, arr   ; r3 = parent(r2)

    cmp [r3], [r2]
    iflteq ret
    xor [r2], [r3]
    xor [r3], [r2]
    xor [r2], [r3]
    mov r2, r3
    jmp heap_up

; inout r6: pointer to end of queue
; clobbers r2,r3,r4,r9
extract:
    sub r6, 4
    mov [arr], [r6]

    mov r2, arr  ; r2 = current node
down_heap:
    mov r3, r2
    sub r3, arr
    sla r3, 1
    add r3, 4
    add r3, arr  ; r3 = left child
    mov r4, r3
    add r4, 4    ; r4 = right child
    mov r9, r2   ; r9 = minimum of the above

    cmp r3, r6
    ifgteq ret  ; stop if no children
    cmp [r9], [r3]
    ifgt mov r9, r3

    cmp r4, r6
    ifgteq jmp extract_skip_r4  ; skip if r>=end
    cmp [r9], [r4]
    ifgt mov r9, r4
extract_skip_r4:
    cmp r9, r2
    ifz ret
    xor [r2], [r9]
    xor [r9], [r2]
    xor [r2], [r9]
    mov r2, r9
    jmp down_heap

; in r0: node number
; in r7: sequence length
; in r8: sequence
traverse:
    bts r0, 7
    ifz jmp traverse_leaf
    push r1
    
    xor r0, 0x80
    sla r0, 2
    add r0, arr
    mov r0, [r0]   ; r0 has left/right node
    push r0
    ; left node
    and r0, 0xff
    inc r7
    call traverse
    dec r7
    pop r0
    push r0
    ; right node
    sra r0, 8
    mov r1, 1
    sla r1, r7
    or  r8, r1
    inc r7
    call traverse
    dec r7
    
    xor r8, r1
    pop r0
    pop r1
    ret
traverse_leaf:
    push r2
    push r1
    push r0

    mov r1, r0
    sla r1, 3
    add r1, code
    mov [r1], r7
    mov [r1+4], r8

    mov r2, rsp
    mov r0, 1
    mov r1, r30
    call write
    mov r0, r8
    mov r9, 39
    call print_binary
    call print_nl

    pop r0
    pop r1
    pop r2
    ret

; in r7: sequence length
; in r8: sequence
; in r9: characters left for newline
print_binary:
    push r8
    push r7
    push r2
    push r1
    push r0
print_binary_loop:
    dec r7
    ifc jmp print_binary_stop
    mov r0, 1
    mov r1, r30
    mov r2, r8
    and r2, 1
    add r2, '0'
    push r2
    mov r2, rsp
    call write
    pop r2
    sra r8, 1

    dec r9
    ifnc jmp print_binary_loop
    call print_nl  ; newline if too far
    mov r9, 39
    jmp print_binary_loop
print_binary_stop:
    pop r0
    pop r1
    pop r2
    pop r7
    pop r8
    ret

print_nl:
    push r0
    push r1
    push r2
    mov r0, 1
    mov r1, r30
    push 10
    mov r2, rsp
    call write
    pop r2
    pop r2
    pop r1
    pop r0
    ret


arr: data.fill 0, 512   ; 128*4
code: data.fill 0, 1024 ; 128*8
file_struct: data.fill 0, 8
buffer: data.fill 0, 256

msg_error_read: data.str "Error reading file" data.8 10 data.8 0
default_filename: data.str "1:input.txt" data.8 0

#include "fox32rom.def"
#include "fox32os.def"

