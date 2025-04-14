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
    # base case node is 0
    beq $a0, $zero, print_tree_end
    
    # Prologue
    addi $sp, $sp, -8
    sw $a0, 4($sp) # store argument 
    sw $ra, 0($sp) # store ra
    
    # recursive call on left child
    lw $t0, 4($a0) # left child is index 1
    move $a0, $t0 # copy left child to a0, must perserve when return 
    jal print_tree 
    
    # restore 
    lw $a0, 4($sp)
    
    # print int value
    lw $t1, 0($a0) # save int value into $t1 (index 0)
    move $a0, $t1 # $a0 = current value 
    li $v0, 1 # load print integer
    syscall # prints current int value
    
    # print left parenthesis
    la $a0, lparen
    li $v0, 4 # load print string
    syscall
    
     # print parent
    
    # print color
    lw  $t1, 16($a0) # color (index 4) $t1 = 0 if black, $t1 = 1 if red
    beq $t1, $0, handle_black 
    # else: execute for red
    la $a0, color_red
    j common_print # avoid repetitive code
    	
handle_black:
    la $a0, color_black
    
common_print:
    li $v0, 11 # print char
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
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to find
# Returns:
#   $v0 : -1 if not found, else pointer to node

search_node:
    # Function prologue
	
	
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