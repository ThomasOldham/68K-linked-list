*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
trap_p_char equ 6
trap_p_nullterm_crlf equ 13

node_next equ 2 ; offset within a node struct of the pointer to the next node

START:                  ; first instruction of program

    jsr print_list * Print initial state of the list.
    
    * Insert sorting implementation here.
    
    jsr print_list * Print the now-sorted list.
    SIMHALT

* SUBROUTINE
* Prints the list.
print_list
    movem.l D0/D1/D2/A1, -(SP)
    lea.l list_head, A1
pl_loop
    move.l (A1), D2
    tst.l D2
    beq pl_cleanup
    move.l (A1), A1
    move.b (A1), D1
    move.l #trap_p_char, D0
    trap #15
    add.l #node_next, A1
    bra pl_loop
pl_cleanup
    move.l #trap_p_nullterm_crlf, D0
    trap #15
    movem.l (SP)+, D0/D1/D2/A1
    rts

* Put variables and constants here

list_head ; pointer to the first node in the list
    dc.l b_node
b_node
    dc.b 'b'
    dc.l a_node
a_node
    dc.b 'a'
    dc.l e_node
c_node
    dc.b 'c'
    dc.l 0
d_node
    dc.b 'd'
    dc.l c_node
e_node
    dc.b 'e'
    dc.l d_node
    
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
