# binary search in mips

.text
.globl main
main:
    # s0 - address of array base 
    # s1 - number of elements added
    la $a0, enterNumberOfElementsPrompt
    jal promptInt
    sw $v0, totalElements
    move $a0, $v0 # number of elements
    li $a1, 4 # size of an element
    jal initArray
    move $s0, $v0

    li $s1, 0 

    inputloop:
        la $a0, enterNumberPrompt
        jal promptInt

        move $a1, $v0
        move $a0, $s0
        li $a2, 4 # sizeof int = 4
        jal addElementArr
        bnez $v0, inputloop_cntd # check if element was added successfully or not
        
        la $a0, inputFailedPrompt
        jal printString
        jal exit 

        # else continue
        inputloop_cntd:
        addi $s1, $s1, 1
        lw $t1, totalElements
        slt $t0, $s1, $t1
        bnez $t0, inputloop
    
    move $a0, $s0
    li $a1, 4
    jal printArray
    
    la $a0, searchForPrompt
    jal promptInt
    move $a1, $v0
    move $a0, $s0
    li $a2, 4
    jal binarySearch
    li $t0, -1 
    beq $v0, $t0, exitMain
    move $a0, $v0
    jal printInt

    jal printNewLine

exitMain:
    jal exit

# binary search algorithm
# a0 - array base
# a1 - target value
# a2 - size of each element
# output:
# v0 - -1 if not found, else index
binarySearch:
    # convention:
    # s3 - low index
    # s4 - middle index
    # s5 - high index

    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)

    li $s3, 0 # low
    lw $s5, totalElements
    sub $s5, $s5, 1 # high


binarySearchLoop:
    blt $s5, $s3, binarySearchNotFound # if high < low, not found, exit

    # finding middle index
    add $t0, $s3, $s5
    div $s4, $t0, 2

    # check if middle == target
    lw $a0, 4($sp)
    move $a1, $s4 # middle index
    lw $a2, 12($sp)
    jal getElementArr
    move $t1, $v0 # middle value

    lw $t2, 8($sp) # move target value in a1
    blt $t1, $t2, binarySearchMoveRight # arr[mid] < target, move right
    bgt $t1, $t2, binarySearchMoveLeft  # arr[mid] > target, move left
    beq $t1, $t2, binarySearchFound # arr[mid] == target, found

binarySearchMoveRight:
    addi $s3, $s4, 1 # low = middle + 1
    j binarySearchLoop

binarySearchMoveLeft:
    subi $s5, $s4, 1 # high = middle - 1
    j binarySearchLoop

binarySearchFound:
    la $a0, foundPrompt
    jal printString
    move $v0, $s4 # set index
    j binarySearchEnd

binarySearchNotFound:
    la $a0, notFoundPrompt
    jal printString
    li $v0, -1 # return -1 if not found
    j binarySearchEnd

binarySearchEnd:
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

.data
    totalElements: .word 0
    enterNumberOfElementsPrompt: .asciiz "Enter number of elements: "
    enterNumberPrompt: .asciiz "Enter number: "
    inputFailedPrompt: .asciiz "input loop failed\n"
    searchForPrompt: .asciiz "Search for which element: "
    foundPrompt: .asciiz "Found !\n"
    notFoundPrompt: .asciiz "Not found !\n"

.include "utils.asm"
