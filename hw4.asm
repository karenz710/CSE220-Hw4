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
    # Base case node is 0
    beq $a0, $zero, print_tree_end
    
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
    lw  $t1, 12($a0) # color (index 4) $t1 = 0 if black, $t1 = 1 if red
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

insert_node_done:
	#Function Epilogue
    jr $ra
