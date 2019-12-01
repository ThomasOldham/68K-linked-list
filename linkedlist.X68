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
    lea.l list_head, A6
    jsr merge_sort
    
    jsr print_list * Print the now-sorted list.
    SIMHALT

* SUBROUTINE
* Pass a double pointer to the head of a linked list to A6.L.
* Sorts the linked list.
merge_sort
    movem.l D7/A0/A5/A6, -(SP)
    * Check if the list is size 1.
    * All lists of size 1 are sorted.
    jsr length
    cmp.l #1, D7
    ble ms_sorted
    * else
        * Split the list.
        move.l A6, A5
        jsr split
        * Sort the two halves.
        move.l A6, -(SP)
        move.l SP, A6
        jsr merge_sort
        move.l A5, A6
        jsr merge_sort
        move.l (SP)+, A6
        * Merge the two sorted halves.
        jsr merge
ms_sorted
    movem.l (SP)+, D7/A0/A5/A6
    rts

* SUBROUTINE
* Pass a double pointer to the first node in A6.L.
* Returns the length of the list in D7.L.
length
    movem.l D2/A2, -(SP)
    clr.l D7
    move.l (A6), D2
length_loop
    * Check if next node is null.
    tst.l D2
    beq length_cleanup
        * Increment counter move to next node.
        move.l D2, A2
        addq.l #node_next, A2
        move.l (A2), D2
        addq.l #1, D7
    bra length_loop
length_cleanup
    movem.l (SP)+, D2/A2
    rts
    
* SUBROUTINE
* Pass a double pointer to the first node in A5.L.
* Pass the length of the list in D7.L.
* Sets the element before the midpoint's next to null.
* Returns the address of the midpoint in A6.L.
split
    movem.l D7/A5, -(SP)
    lsr.l #1, D7
    move.l A5, A6
split_loop
    tst.l D7
    beq split_cleanup
        move.l (A6), A6
        addq.l #node_next, A6
        subq.l #1, D7
    bra split_loop
split_cleanup
    move.l (A6), A5
    clr.l (A6)
    move.l A5, A6
    movem.l (SP)+, D7/A5
    rts
    
* SUBROUTINE
* Pass a double pointer to the first nodes of each of two
* sorted lists to A5.L ("left") and A6.L ("right").
* Merges the lists and returns a double pointer to the
* merged list in A5.L.
* The contents of A6.L are undefined after calling this
* subroutine.
merge
    movem.l D2/D3/A2/A3/A5, -(SP)
merge_loop
    tst.l (A5)
    beq merge_left_empty
    tst.l (A6)
    beq merge_right_empty
        move.l (A5), A2
        move.l (A2), D2
        move.l (A6), A3
        move.l (A3), D3
        cmp.b D3, D2
        ble merge_less_or_equal
merge_greater
            * Store head of right list.
            move.l A6, A2
            * Go to next on right list.
            move.l (A6), A6
            addq.l #node_next, A6
            * Prepend stored node to left list.
            ** Change stored node's next to left list head.
            move.l (A2), A3
            addq.l #node_next, A3
            move.l (A5), (A3)
            ** Make the left list head double pointer point to the stored node.
            move.l (A2), (A5)
            * We just moved back up one in the left list, so fallthrough to
            * move back down.
merge_less_or_equal
            * Go to next on left list.
            move.l (A5), A5
            addq.l #node_next, A5
        bra merge_loop
    
merge_left_empty
    * Append the right list to the end of the left list.
    move.l (A6), (A5)
    * Fallthrough to merge_cleanup.
merge_right_empty
    * Everything has been merged into the left list--nothing left to do.
    * Fallthrough to merge_cleanup.
merge_cleanup
    movem.l (SP)+, D2/D3/A2/A3/A5
    rts
    
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
