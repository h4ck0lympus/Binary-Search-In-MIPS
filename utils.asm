# print prompt and take integer input
# input: a0 - address of prompt string
# return: v0 - integer read
.text
promptInt:
    addi $sp, $sp, -8 # make functions frame on stack
    sw $ra, 0($sp) # save ra
    sw $a0, 4($sp) # first argument

    jal printString
    lw $a0, 4($sp)

    li $v0, 5
    syscall

    lw $ra, 0($sp) # pop rip
    lw $a0, 4($sp) # pop rip
    addi $sp, $sp, 8 # reset stack
    jr $ra

# print string 
# input: a0 - address of string to print
# return: output
.text
printString:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    lw $a0, 4($sp)
    li $v0, 4
    syscall

    lw $ra, 0($sp)
    sw $a0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# print int
# input: a0 - integer to print
# return: output
.text
printInt:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    lw $a0, 4($sp)
    li $v0, 1
    syscall

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# print int
# input: a0 - character to print
# return: output
.text
printChar:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    lw $a0, 4($sp)
    li $v0, 11
    syscall

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# print new line character
# void function
.text
printNewLine:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, 0xa
    jal printChar

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# allocate heap memory
# a0 - size of memory allocated
# v0 - address of returned address
.text
malloc:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    lw $a0, 4($sp) # a0 - size of memory allocated
    li $v0, 9
    syscall

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# initiate array
# a0 - number of elements
# a1 - size of an element
# v0 - address of returned address
.text
initArray:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)

    mul $a0, $a0, $a1
    jal malloc

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# add element in array
# a0 - base of array
# a1 - element to be inserted
# a2 - size of one element
# return 1 if successful else 0
addElementArr:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp) # first arg
    sw $a1, 8($sp) # second arg
    sw $a2, 12($sp) # third arg
    
    lw $t0, __numElementsAdded
    lw $t1, totalElements
    slt $t2, $t0, $t1
    beqz $t2, addFailed # if not (added < total), fail

    # N = number of elements added
    # address_of_element = base_address +  (size * N)
    lw $t0, __numElementsAdded
    mul $t0, $t0, $a2
    add $t0, $a0, $t0
    sw $a1, 0($t0)
    
    # update number of elements added
    lw $t0, __numElementsAdded
    addi $t0, $t0, 1
    sw $t0, __numElementsAdded

    li $v0, 1 # return success
    j addEnd

    addFailed:
    li $v0, 0 # return failed

    addEnd:
    lw $ra, 0($sp)
    lw $a0, 4($sp) # first arg
    lw $a1, 8($sp) # second arg
    lw $a2, 12($sp) # third arg
    addi $sp, $sp, 16
    jr $ra

.data
    __numElementsAdded: .word 0

.text
getElementArr:
# get element in array
# a0 - base of array
# a1 - idx
# a2 - size of one element
# v0 - returns element
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp) # first arg
    sw $a1, 8($sp) # second arg
    sw $a2, 12($sp) # third arg
    
    lw $t0, totalElements
    bge $a1, $t0, getFailed # if idx greater than or equal to size of array, fail

    # address_of_element = (size of one element * idx)
    mul $t0, $a1, $a2
    add $t0, $a0, $t0 # base + address_of_element
    lw $v0, 0($t0) # get element
    j getEnd

    getFailed:
    li $v0, 0

    getEnd:
    lw $ra, 0($sp)
    lw $a0, 4($sp) # first arg
    lw $a1, 8($sp) # second arg
    lw $a2, 12($sp) # third arg
    addi $sp, $sp, 16
    jr $ra

# prints array
# a0 - base of array
# a1 - size of each element
# output - void
.text
printArray:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)

    la $a0, printArrayPrompt
    jal printString
    la $a0, squareBracketStart
    jal printString

    lw $t0, 4($sp) # t0 store address of element to be printed
    lw $t1, 8($sp) # t1 store size of each element 
    li $t2, 0 # elements printed
    lw $t3, totalElements

    printLoop:
        slt $t4, $t2, $t3
        beqz $t4, printArrayEnd # if index == totalElements, end loop
        
        lw $a0, 0($t0)
        jal printInt

        add $t0, $t0, $t1

        la $a0, arrayDelimeter
        jal printString
        addi $t2, $t2, 1
        b printLoop

    printArrayEnd:
    la $a0, squareBracketStop
    jal printString

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12
    jr $ra    

.data
    printArrayPrompt: .asciiz "Array: "
    squareBracketStart: .asciiz "[ "
    arrayDelimeter: .asciiz ", "
    squareBracketStop: .asciiz "]\n"

# print signature
# void function
.text
printSignature:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    sw $ra, 0($sp)
    la $a0, name
    jal printString
    la $a0, email
    jal printString
    la $a0, course_num
    jal printString

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

.data:
name: .asciiz "Vishal Juneja(hackolympus)\n"
email: .asciiz "VISXXXXXXX@maricopa.edu\n"
course_num: .asciiz "CSC230 Phoenix College Summer 2024\n"

# exit
# void function
.text
exit:
    jal printSignature
    li $v0, 10
    syscall
