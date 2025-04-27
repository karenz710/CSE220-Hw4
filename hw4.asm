.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

# red-black data
lparen: .asciiz "("
rparen_space: .asciiz ") "
color_red: .asciiz "R"
color_black: .asciiz "B"

.text
.globl print_tree 
.globl search_node
.globl insert_node

# Function: print_tree
# Print all the values and colors with in-order traversal (format: value, left, right, color)
# Arguments: 
#   $a0 - pointer to root
# Returns: void
print_tree:
    # Base case node is 0 then no value was found
    beq $a0, $0, print_tree_end
    
    # Prologue
    addi $sp, $sp, -8
    sw $a0, 4($sp) # store argument 
    sw $ra, 0($sp) # store ra 
    
    # recursive call on left child
    lw $t0, 4($a0) # left child is index 1
    move $a0, $t0 # copy left child to a0, must perserve when return 
    jal print_tree 
    
    # set a0 back to current
    lw $a0, 4($sp)
    
    # print int value
    lw $t1, 0($a0) # load (because array) int value into $t1 (index 0)
    move $a0, $t1 # $a0 = current value 
    li $v0, 1 # load print integer
    syscall # prints current int value
    
    # print left parenthesis
    la $a0, lparen
    li $v0, 4 # load print string
    syscall
    
    # set a0 back to current
    lw $a0, 4($sp)
    
    # print parent
    lw $t2, 16($a0) # t2 = parent address
    # if t2 == 0 (at root parent is 0 or None)
    beq $t2, $0, handle_root
    # else has a parent 
    lw $t3, 0($t2) # t3 = parents value 
    move $a0, $t3 # a0 = parent value
    j parent_print
    
handle_root:
    move $a0, $0
parent_print:
    li $v0, 1 # load print integer
    syscall
    
    # restore 
    lw $a0, 4($sp)
    
    # print color
    lw  $t1, 12($a0) # color (index 3) $t1 = 0 if black, $t1 = 1 if red
    beq $t1, $0, handle_black # if t1 == 0
    # else: execute for red
    la $a0, color_red
    j color_print # avoid repetitive code
    	
handle_black:
    la $a0, color_black
    
color_print:
    li $v0, 4 # print char
    syscall
    
    # print right parenthesis
    la $a0, rparen_space
    li $v0, 4 # load print string
    syscall
    	
    # restore $a0 to be argument
    lw $a0, 4($sp)
    
    # recursive call on right child
    lw $t0, 8($a0) # load right child
    move $a0, $t0
    jal print_tree 
    
    # restore registers and return
    lw $a0, 4($sp) 
    lw $ra, 0($sp)
    addi $sp, $sp, 8

print_tree_end:
    # Epilogue
    jr $ra
    

# Function: search_node
# This is a Binary Search Tree so if greater than search right, less than search left (
# use iteration
# Arguments: 
#   $a0 - pointer to root (perserve) 
#   $a1 - value to find	(perserve)
# Returns:
#   $v0 : -1 if not found, else pointer to node

search_node:
    # Function prologue
    move $t0, $a0 # $t0 = curr_node. Initialize curr_node = root 
loop:
    # first check if curr_node is NULL then curr_val DNE 
    beq $t0, $0, no_value_found
    
    lw $t1, 0($t0) # t1 = val at index 0 of curr_node
    beq $t1, $a1, value_found
    
    # if target < curr val, go left; otherwise, go right
    blt $a1, $t1, search_left 
    # else go right
    lw $t0, 8($t0)
    j loop
    
search_left:
    lw $t0, 4($t0)
    j loop
    
no_value_found:
    li $v0, -1
    j search_node_end

value_found: 
    move $v0, $t0
    j search_node_end
    	
search_node_end:	
    #Function Epilogue
    jr $ra


# Function: insert_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to insert
# Returns: 
#	$v0 - pointer to root

insert_node:
	# Function prologue
    addi $sp, $sp, -8 # move stack ptr down by 2 words
    sw $ra, 4($sp) # store return address
    sw $s0, 0($sp) # store to return org val back later
    
    move $s0, $a0 # save original root in $s0
    
    # create 5 words (20 bytes)
    li $v0, 9 # syscall $a0 = number of bytes to allocate 
    li $a0, 20 # $a0 = number of bytes to allocate
    syscall
    move $t0, $v0 # $t0 stores new_node ptr $v0 contains address of allocated memory
    
    # initialize new_node 
    sw $a1, 0($t0) # $a1 is val to insert new_node->value = val
    sw $0, 4($t0) # new_node->left_child = NULL 
    sw $0, 8($t0) # new_node->right_child = NULL
    li $t1, 1 # t1 = 1 (red)
    sw $t1, 12($t0) #new_node->color = red(1)
    sw $0, 16($t0) #new_node->parent = NULL
    
    # ordinary BST-insert
    move $t2, $0 # t2 = parent = NULL
    move $t3, $s0 # t3 = current = root

# traverse the BST
BST_loop:
    beq $t3, $0, link_node # finish loop 
    move $t2, $t3 # set parent = current
    lw $t4, 0($t3) # t4 = current->val
    blt $a1, $t4, go_left # if $a1 < $t4 .go_left if val to insert < current
    # else go right
    lw $t3, 8($t3) # set current to right child 
    j BST_loop
    
go_left:
    lw $t3, 4($t3) # set current to left child
    j BST_loop    
    
link_node:
    # t2 = parent node $t0 = new node 
    sw $t2, 16($t0) # new_node->parent = t2
    beq $t2, $0, new_root # if parent is NULL just a new root
    
    # link to left or right child
    lw $t5, 0($t2) # $t5 = parent val
    blt $a1, $t5, link_left # if a1 < t5 ; new_val < parent 
    # else link right
    sw $t0, 8($t2) # parent->right = new_node
    j balance_tree
    
link_left:
    sw $t0, 4($t2) # parent->left = new_node
    j balance_tree
    
new_root: 
# tree empty new_node is new root 
    sw $0, 12($t0) # color black
    move $s0, $t0 # set the original root node to the new root node
    j insert_node_done
    
balance_tree:      
    move  $t5, $t0 # $t5 = x = newly inserted node
    
fixup_loop:
    #t5 is the newly inserted node at fisrt
    lw $t6, 16($t5) # t6 = parent(x)
    beq $t6, $0, fixup_done
    lw $t7, 12($t6) # t7 = color(parent)
    beq $t7, $0, fixup_done

    lw $t8, 16($t6) # t8 = grandparent
    beq $t8, $0, fixup_done # if no grandparent, done
    
    # is parent a left child?
    lw $t9, 4($t8)       
    beq $t9, $t6, l_case
    # right side cases 
    lw $t9, 4($t8) # uncle = gp->left
    beq $t9, $0, r_case2
    lw $t7, 12($t9)
    li $t1, 1
    bne $t7, $t1, r_case2
    # r_case1: parent+uncle RED ? recolor and move up
    li $t1, 0
    sw $t1, 12($t6)
    sw $t1, 12($t9)
    li $t1, 1
    sw $t1, 12($t8)
    move $t5, $t8
    j fixup_loop
    
r_case2:
    # if x is left child ? rotate right(parent)
    lw $t7, 4($t6)
    bne $t7, $t5, r_after
    move $a0, $s0
    move $a1, $t6
    jal right_rotate
    move $s0, $v0
    move $t5, $t6
r_after:
    # recolor and rotate left(gp)  
    # recolor new parent black gp red
    lw $t6, 16($t5) # parent
    lw $t8, 16($t6) # grandparent
    li $t1, 0
    sw $t1, 12($t6) # parent = black
    li $t1, 1
    sw $t1, 12($t8) # grandparent = red
    
    move $a0, $s0
    move $a1, $t8
    jal left_rotate
    move $s0, $v0
    
    j fixup_done

l_case:
    # left?side cases
    lw $t9, 8($t8)  # uncle = gp->right
    beq $t9, $0, l_case2
    lw $t7, 12($t9)
    li $t1, 1
    bne $t7, $t1, l_case2
    # l_case1: parent+uncle RED recolor and move up
    li $t1, 0
    sw $t1, 12($t6)
    sw $t1, 12($t9)
    li $t1, 1
    sw $t1, 12($t8)
    move $t5, $t8
    j fixup_loop
l_case2:
    # if x is right child ? rotate left(parent)
    lw $t7, 8($t6)
    bne $t7, $t5, l_after
    move $a0, $s0
    move $a1, $t6
    jal left_rotate
    move $s0, $v0
    move $t5, $t6
l_after:
    # recolor and rotate right(gp)
    # recolor new parent black gp red
    lw $t6, 16($t5) # parent
    lw $t8, 16($t6) # grandparent
    li $t1, 0
    sw $t1, 12($t6) # parent = black
    li $t1, 1
    sw $t1, 12($t8) # grandparent = red
    
    move $a0, $s0
    move $a1, $t8
    jal right_rotate
    move $s0, $v0
    
    j fixup_done

fixup_done:
    # change root to BLACK
    li $t1, 0
    sw $t1, 12($s0)
   
insert_node_done:
    move $v0, $s0 # return the root inside reg $v0
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
	#Function Epilogue
    jr $ra

# rotates the subtree left at x
# $a0 = root node $a1 = node to rotate at x
# returns v0 = root pointer
# the right child of x moves up = y and y's right child becomes the x's left child  
left_rotate:
    addi $sp, $sp, -8
    sw $ra, 4($sp) # store return address good practice 
    sw $s0, 0($sp) # s0 where we store the new root 

    move $s0, $a0 # save root in s0
    move $t0, $a1 # t0 = x = root node 
    lw $t1, 8($t0) # t1 = y = x->right x's right child

    # x->right = y->left; x's right node becomes y's left child 
    lw $t2, 4($t1) # t2 = y->left
    sw $t2, 8($t0) # set x's child to t2
    bne  $t2, $0, L0 # if y-> left not NULL fix parent ptr
    j L1 # else don't fix parent ptr
    
L0:
    sw $t0, 16($t2)
L1:
    # y->parent = x->parent
    lw $t3, 16($t0) 
    sw $t3, 16($t1)

    # relink y into the tree above x
    beq $t3, $0, L_make_root # if x was root, y becomes root
    
    # else reattach as l or r child of x's old parent
    lw $t4, 4($t3)
    beq $t4, $t0, LL3 # if x was left child
    sw $t1, 8($t3) # else x was right child
    j LL2
    
LL3:
    sw $t1, 4($t3)
    j LL2
    
L_make_root:
    move $s0, $t1 # new root = y 
    
LL2:
    # complete the rotation
    sw $t0, 4($t1) # y->left = x
    sw $t1, 16($t0) # x->parent = y
    
    move  $v0, $s0 # return root which was possibly updated (whole root of tree)

    lw $ra, 4($sp) 
    lw $s0, 0($sp) # restore $s0 
    addi $sp, $sp, 8 # restore sp 
    jr $ra


# right_rotate(root, y)
# rotates the subtree right at y
# a0 = root pointer, a1 = y node
# returns v0 = (possibly new) root pointer
right_rotate:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a0 # save root
    move $t0, $a1 # t0 = y
    lw $t1, 4($t0) # t1 = x = y->left

    # y->left = x->right
    lw $t2, 8($t1)# t2 = x->right
    sw $t2, 4($t0)
    # if (x->right != NULL) x->right->parent = y
    bne $t2, $0, R0 # fix parent
    j R1
R0:
    sw $t0, 16($t2)
R1:
    # x->parent = y->parent
    lw $t3, 16($t0)
    sw $t3, 16($t1)


    # relink x into the tree above y
    beq $t3, $0, R_make_root
    # else
    lw $t4, 8($t3)
    beq $t4, $t0, LR3 # if y was right child
    sw $t1, 4($t3) # else y was left child
    j LR2
LR3:
    sw $t1, 8($t3) # parent-> right = x
    
R_make_root:
    move $s0, $t1 # whole new root = x
    
LR2:
    # finalize rotation
    sw $t0, 8($t1) # x->right = y
    sw $t1, 16($t0) # y->parent = x

    move $v0, $s0 # return root which might have been updated.

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

