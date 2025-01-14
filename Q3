.data
END_MSG: .asciiz "\nThe number of identical char in a row is: "
buf: .space 21
buf1: .space 20
START_MSG: .asciiz "Please enter a string:\n"
PLUS: .byte '+'
MINUS: .byte '-'
EQUALS: .byte '='
NEWLINE: .byte '\n'
NULL: .byte '\0'

##############################################################################
# This algorithm checks the differences between 2                            #
# neighbouring characters, a character and its right neighbour, in a string. #
# If right neighbour is bigger, we store '-' sign in the result accordingly. #
# If right neighbour is smaller, we store '+' sign in the result accordingly.#
# If neighbours are identical, we store '=' sign in the result accordingly   #
# and count this occurence.                                                  #
# In the end, we print the result and the number of identical characters.    #
##############################################################################

.text
.globl main
main:

# Prints Please enter a string:
la $a0, START_MSG($0)
li $v0, 4
syscall

# Stores the user's input in a0 (we pass the input to a1)
la $a0, buf($0)
li $a1, 21
li $v0, 8
syscall

la $a0, buf1($0) # Stores the result
la $a1, buf($0) # Stores user input
lbu $s5, PLUS # Represents '+' sign
lbu $s6, MINUS # Represents '-' sign
lbu $s7, EQUALS # # Represents '=' sign

li $s0, 0 # Represents the counter i
li $s1, 1 # Represents the position i+1 in buf
li $s2, 0 # Counts the number of identical chars
li $s3, 0 # Counts the length of buf

lbu $a2, NEWLINE # a2 = '\n'

# Counts the length of buf
Buf_length: 
lbu $t1, buf($s0) # t1 = buf[i]
beq $t1, $a2, Less_than_20_char_entered # if (buf[i] = '\n') we're done
beq $t1, $0, End_buf_length # if (buf[i] = '\0') we're done
addi $s3, $s3, 1 # buf length counter++
addi $s0, $s0, 1 # i++
j Buf_length

# If user entered less than 20 chars, we manually replace '\n' with '\0'
Less_than_20_char_entered: 
lbu $a2, NULL
sb $a2, buf($s3)

# i = 0
End_buf_length: li $s0, 0

# for (i = 0; i < buf length; i++)
For: 
beq $s0, $s3, End_for # if (i = buf length) we're done
add $t2, $s0, $a1 # t2 = address of buf[i]
lbu $t3, 0($t2) # t3 = buf[i]
add $t4, $s1, $a1 # t4 = address of buf[i+1] (i+1 < buf length)
lbu $t5, 0($t4) # t5 = buf[i+1]

If: 
slt $s4, $t3, $t5 # if (buf[i] < buf[i+1]) 
beq $s4, $0, Else_if 
add $t6, $a0, $s0 # t6 = address of buf1[i]
sb $s6, 0($t6) # buf1[i] = '-'
j NISU

Else_if: 
slt $s4, $t5, $t3 # else if (buf[i] > buf[i+1])
beq $s4, $0, Else
add $t6, $a0, $s0 # t6 = address of buf1[i]
sb $s5, 0($t6) # buf1[i] = '+'
j NISU

Else: # else buf[i] = buf[i+1]
add $t6, $a0, $s0 # t6 = address of buf1[i]
sb $s7, 0($t6) # buf1[i] = '='
addi $s2, $s2, 1 # identical chars counter++

NISU: # Stands for Next Iteration Set Up
addi $s0, $s0, 1 # i++
addi $s1, $s1, 1 # Setting to the next (i+1)'th position in buf
j For

# We manually store '\0' in buf1[buf length - 1]
End_for:
lbu $a1, NULL
addi $s3, $s3, -1
sb $a1, buf1($s3)

lbu $a0, NEWLINE
li $v0, 11
syscall

# Prints the result
la $a0, buf1($0)
li $v0, 4
syscall

lbu $a0, NEWLINE
li $v0, 11
syscall

# Prints The number of identical char in a row is:
la $a0, END_MSG
li $v0, 4
syscall

# Prints the number of identical chars
move $a0, $s2
li $v0, 1
syscall

lbu $a0, NEWLINE
li $v0, 11
syscall

li $v0, 10
syscall

