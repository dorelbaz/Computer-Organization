.data
End_Of_Mips:   .word 0xffffffff  
TheCode: .word 0xAC850000,0x35ED000F,0x8c912000,0x02CF702F,0x02CF7520,0x01CF7020,0x8E600100,0x13390111,0x00ADC024,0x02CE602A,0x01AF0020,0x130D0054,0x40851800,0x40851801,0x40851300,0xffffffff
NEWLINE: .byte '\n'     #     ^                      ^         ^                   ^           ^                                ^                                ^          ^
			# The ^ point at flawed instructions
Command_Table: .word 0,0,0 # Command_Table[0] = counter for lw, Command_Table[1] = counter for sw, Command_Table[2] = counter for beq
Register_Table: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 # Counter array for the registers
Table_Contents: .asciiz "inst code/reg\t\t\tappearances\n"
RTYPES: .asciiz "R-Type\t\t\t\t"
TABS: .asciiz "\t\t\t\t"
COMMAND_LW: .asciiz "lw\t\t\t\t"
COMMAND_SW: .asciiz "sw\t\t\t\t"
COMMAND_BEQ: .asciiz "beq\t\t\t\t"


Funct_Table: # Functs of R type instructions
.word 0x00000020,0x00000021,0x00000008,0x00000027,0x00000025,
0x0000002a,0x0000002b,0x00000000,0x00000002,0x00000022,
0x00000023,0x0000001a,0x0000001b,0x00000010,0x00000012,
0x00000000,0x00000018,0x00000019,0x00000003,0x00000024

# Error messages
Instruction: .asciiz "Instruction "
Error_With_Opcode: .asciiz "\t opcode is undefined. Instruction can only be of type R or beq, lw, sw.\n"
Error_In_Funct: .asciiz "\t funct is of illegal value.\n"
Error_In_Shamt: .asciiz "\t shamt != 0 if and only if instruction is srl, sll, sra.\n"
Rt_Is_Zero: .asciiz "\t Error: attempt to load a value to $0.\n"
Rd_Is_Zero: .asciiz "\t Error: rd is 0 in instruction of type R.\n"
Equality_In_Beq: .asciiz "\t Identical rs and rt fields in beq.\n"
Error_In_Mcfo_Funct: .asciiz "\t funct in mcfo should be 0.\n"
Error_In_Mfco_Shamt: .asciiz "\t shamt in mcfo should be 0.\n"

################################################################################################################
# This algorithm first scans through a MIPS instruction array, TheCode, for errors. If an error                #
# has been found, it prints the instruction position together with appropriate error message and replaces the  #
# flawed instruction with 0. Then, the algorithm scans TheCode a second time, counting the appearances of the  #
# registers, R type instructions and the I type instructions lw, sw, beq. It Ends the operation when 0xffffffff#
# is found. It also skips to next instruction if a 0 is found. Finally, it prints the result in a table format.#
################################################################################################################


.text
.globl main
main:

# The first scan of TheCode. Examines for errors.
lw $s7, End_Of_Mips($0) # s7 = 0xffffffff
li $s1, 0 # i = 0
Examine_TheCode: lw $a1, TheCode($s1) # a1 = TheCode[i]
beq $a1, $s7, Start # if (a1 = 0xffffffff) we're done with the first scan and start the second scan
jal Error_Examiner
addi $s1, $s1, 4 # i++
j Examine_TheCode

Start:
li $s0, 0 # R type counter
li $s1, 0 # TheCode counter
li $s2, 0 # Register/Command Table counter 
li $s3, 12 # Size of Command_Table in bytes
li $s4, 32 # Total registers
li $s5, 0 # Represent the current register in the result table 
li $s6, 0 #  Helps in copying opcode, rs, rt, rd, shamt and funct bit fields 

lw $a1, TheCode($0)# $a1 = TheCode[0]

While: beq $a1, $s7, End_While # if ( TheCode[i] = 0xffffffff) we're done
beq $a1, $0, NISU # Stands for Next Iteration Set Up, if a1 = 0 we skip to the next iteration
jal Extract_Opcode # Copies opcode to v0
bne $v0, $0, FI # If ($v0 = 0) then instruction is of format R else it is format I
FR: addi $s0, $s0, 1 # R type counter += 1
jal Extract_RD #  Copies rd to $v0
jal Update_Register_Table # Updates its appearance
j RsRt 
FI: li $t0, 16 # Instruction mcfo opcode is 16 in decimal
beq $v0, $t0, FR # mcfo is R type instruction
jal Update_Command_Table # Identifies which command $v0 is and updates its appearance in Command_Table accordingly
RsRt: jal Extract_Registers # Copies rs, rt to $v0, $v1 respectively
jal Update_Register_Table # Updates the appearances of the registers in $v0 and $v1 in Register_Table
move $v0, $v1
jal Update_Register_Table
NISU: 
addi $s1,$s1,4 # Sets TheCode counter to the next instruction
lw $a1, TheCode($s1)# a1 = TheCode[i]
j While

############################################################

End_While: li $v0, 4 # Prints inst code/reg 	appearances
la $a0, Table_Contents
syscall

##############################################################

la $a0, RTYPES # Prints the appearances of R type instructions
syscall

li $v0, 1
move $a0, $s0
syscall

li $v0, 11
lbu $a0, NEWLINE 
syscall

##################################################################################################################

Print_Commands: # Prints the appearances of I type instructions
li $v0, 4 
la $a0, COMMAND_LW($0) 
syscall

li $v0, 1
la $a2, Command_Table($s2) # Prints lw appearances, Command_Table[0] = lw appearance counter
lw $a0, 0($a2)
syscall

li $v0, 11
lbu $a0, NEWLINE
syscall

addi $s2, $s2, 4 #  Command_Table[1] = sw appearance counter

li $v0, 4 
la $a0, COMMAND_SW($0) 
syscall

li $v0, 1
la $a2, Command_Table($s2) # Prints sw appearances
lw $a0, 0($a2)
syscall

li $v0, 11
lbu $a0, NEWLINE
syscall

addi $s2, $s2, 4 # Command_Table[2] = beq appearance counter

li $v0, 4 
la $a0, COMMAND_BEQ($0)  
syscall

li $v0, 1
la $a2, Command_Table($s2) # Prints beq appearances
lw $a0, 0($a2)
syscall

li $v0, 11
lbu $a0, NEWLINE
syscall

##################################################################################################################

Finished: li $s2, 0 # Register_Table counter = 0
 
Print_Registers: 
la $a2, Register_Table($s2) # a2 = address of current register appearance counter
lw $a0, 0($a2) # a0 = current register appearance counter
beq $a0, $0, Skip # If current register didn't appear at all, we skip
beq $s5, $s4, Done # if (current register = 32) we're done

# Prints the current register
li $v0, 1
move $a0, $s5 # s5 represents the current register
syscall

li $v0, 4
la $a0, TABS 
syscall

# Prints the current register appearances
li $v0, 1
lw $a0, 0($a2)
syscall 

lbu $a0, NEWLINE
li $v0, 11
syscall

Skip: addi $s2, $s2, 4 # Register_Table counter += 1
addi $s5, $s5, 1 # Sets to next register
j Print_Registers

Done: li $v0, 10
syscall

##################################################################################################################
######################## Subroutines Used In Both Scans ##########################################################
##################################################################################################################

# Copies the necessary bit field from the current instruction in $a1 to $v0
Cpynbits:
li $t5, 1 # mask = 1
li $t6, 0 # i = 0
li $v0, 0 # Result = 0

For: bge $t6, $s6, End_For # $s6 = 6 or 5, depending which area we want to copy, for (i = 0; i < 6; i++)
sub $t7, $t9, $t6 # $t7 = how much to shift the 1 in the mask. t9 represents the end of the bit field to be copied
sllv $t5, $t5, $t7 
If: and $t8, $a1, $t5 # if (theCode & mask) 
beq $t8, $0, End_If # If $t8 = 0 nothing to copy from mask 
li $t5, 1 
sub $t7, $t0, $t6 # t7 = how much to shift the 1 in the mask, this time to adjust the 1 so the value of the field copied is accurate (I.E copy the bits just as they are within the field) 
# t0 acts as a limit, similar to t9.
sllv $t5, $t5, $t7 
or $v0, $v0, $t5 # Copies from mask to $v0
End_If: addi $t6, $t6, 1 # i++  
li $t5, 1 # Resetting the mask
j For

End_For: jr $ra  

##################################################################################################################

Extract_Opcode:
li $t9, 31 # Opcode ends at bit 31
li $t0, 5 # Equals s6-1 because an offset is needed when copying from mask to $v0 (because of how MIPS shifts bits)
li $s6, 6 # Opcode field is of 6 bits

addi $sp, $sp, -4
sw $ra, 0($sp)

jal Cpynbits # Copies Opcode to $v0

lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra

####################################################################################################################

Extract_RD:
li $t9, 15 # Rd ends at bit 15
li $t0, 4  # Offset needed when copying from mask to v0
li $s6, 5 # Rd field is of 5 bits

addi $sp, $sp, -4
sw $ra, 0($sp)

jal Cpynbits # Copies rd to v0

lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra

##################################################################################################################

Extract_Registers:
li $t9, 20 # Rt ends at bit 20
li $t0, 4 # Offset needed when copying from mask to v0
li $s6, 5 # Rt, rs fields are 5 bits

addi $sp, $sp, -4
sw $ra, 0($sp)

jal Cpynbits # Copies rt to v0
move $v1, $v0 # v1 = rt
li $t9, 25 # Rs field ends at bit 25
jal Cpynbits # Copies rs to v0

lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra

########################################################################################
################### Subroutines For The First Scan #####################################
########################################################################################

# Examines a given instruction for a variety of errors.
Error_Examiner:
addi $sp, $sp, -4 # Save $ra to stack
sw $ra, 0($sp) 


jal Extract_Opcode
move $t1, $v0 # t1 = Opcode

# No subroutines dedicated for copying funct and shamt because they are needed to be copied only for error examination
li $t9, 5 
li $t0, 5
jal Cpynbits # Copies Funct to $v0
move $t2, $v0 # t2 = Funct

li $t9, 10 
li $t0, 4
li $s6, 5
jal Cpynbits # Copies Shamt to $v0
move $t3, $v0 # t3 = Shamt

# Examining OPCODE
beq $t1, $0, isRType
li $t0, 16 
beq $t1, $t0, isMfco
li $t0, 4
beq $t1, $t0, isBeq
li $t0, 35
beq $t1, $t0, isLw
li $t0, 43
beq $t1, $t0, End_Of_Examination


# If it is neither of the above, then the opcode is illegal
la $a0, Error_With_Opcode
jal Print_Error_Message
j End_Of_Examination

# Now that we know what is the instruction, we move to a more precise examination
isRType: jal RType_Examination
j End_Of_Examination

isMfco: jal Mfco_Examination
j End_Of_Examination 

isBeq: jal Beq_Examination
j End_Of_Examination

isLw: jal Lw_Examination
j End_Of_Examination

End_Of_Examination: 
lw $ra, 0($sp) # Restore original $ra from stack
addi $sp, $sp, 4
jr $ra

######################################################

RType_Examination:
addi $sp, $sp, -4
sw $ra, 0($sp)
li $t6, 80 # Size of Funct_Table in bytes

# Examining Funct
li $t5, 0 # Funct_Table counter = 0
Funct: lw $t4, Funct_Table($t5) # t4 = Funct_Table[i]
beq $t4, $t2, Shamt # if (Funct_Table[i] = Funct) we move to examine shamt
beq $t5, $t6, Error_With_Funct # Funct_Table counter out of range
addi $t5, $t5, 4 # Funct_Table counter += 1
j Funct

Error_With_Funct: la $a0, Error_In_Funct
jal Print_Error_Message
j End_Of_RType_Examination

# Examining Shamt
Shamt: bne $t3, $0, Examine_Shamt # Shamt != 0 if and only if instruction is srl, sll, sra. 
j Rd

Examine_Shamt: beq $t2, $0, Rd # sll funct is 0
li $t0, 2
beq $t2, $t0, Rd # srl funct is 2
li $t0, 3
beq $t2, $t0, Rd # sra funct is 3

la $a0, Error_In_Shamt
jal Print_Error_Message
j End_Of_RType_Examination


# Examine rd field
Rd: jal Extract_RD
bne $v0, $0, End_Of_RType_Examination # rd should be different than 0

la $a0, Rd_Is_Zero
jal Print_Error_Message
j End_Of_RType_Examination

End_Of_RType_Examination: 
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#######################################################

Mfco_Examination:
addi $sp, $sp, -4
sw $ra, 0($sp)

bne $t2, $0, Error_With_Mcfo_Funct # Mcfo funct is 0 same as sll funct
bne $t3, $0, Error_With_Mfco_Shamt # Mcfo shamt should be 0
j End_Of_Mcfo_Examination

Error_With_Mcfo_Funct: la $a0, Error_In_Mcfo_Funct
jal Print_Error_Message
j End_Of_Mcfo_Examination

Error_With_Mfco_Shamt: la $a0, Error_In_Mfco_Shamt
jal Print_Error_Message
j End_Of_Mcfo_Examination

End_Of_Mcfo_Examination: 
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#######################################################

Beq_Examination:
addi $sp, $sp, -4
sw $ra, 0($sp)

# Check Rs, Rt fields for equality
jal Extract_Registers

bne $v0, $v1, No_Equality # if (rt != rs)
la $a0, Instruction
li $v0, 4
syscall

li $t0, 4 # prints the instruction position
div $s1, $s1, $t0 # divide the bytes by 4 to get the position
move $a0, $s1
li $v0, 1
syscall
mul $s1, $s1, $t0 # multiply by 4 to restore s1

la $a0, Equality_In_Beq # Notifies of register equality (Not really an error and thus why no call to Print_Error_Message)
li $v0, 4
syscall

No_Equality: 
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#########################################################

Lw_Examination:
addi $sp, $sp, -4
sw $ra, 0($sp)

# Check Rt if 0
# Here we just copy rt hence why Extract_Registers isn't called
li $t9, 20 
li $t0, 4
li $s6, 5
jal Cpynbits # Copies rt to v0
bne $v0, $0, End_Of_Lw_Examination # if (rt != 0)

la $a0, Rt_Is_Zero
jal Print_Error_Message

End_Of_Lw_Examination: 
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

########################################################

Print_Error_Message:
move $a2, $a0 # Before the call. a0 recieves the appropriate error message and now we print it

li $v0, 4
la $a0, Instruction
syscall

li $t0, 4 # prints the instruction position
div $s1, $s1, $t0 # divide the bytes by 4 to get the position
move $a0, $s1
li $v0, 1
syscall
mul $s1, $s1, $t0 # multiply by 4 to restore s1

move $a0, $a2 # Prints the flawed instruction
li $v0, 4
syscall

la $a2, TheCode($s1) # Replaces the flawed instruction with 0, so we can skip the it in the second scan
sw $0, 0($a2)

jr $ra

##################################################################################################################
############################ Subroutines For The Second Scan ##############################################
##################################################################################################################

# Updates the appearance of a register in Register_Table
Update_Register_Table:
li $t9, 4 # Represents the size of each position in Register_Table
mul $t4, $v0, $t9 # Calculates the position of the register within the array (the position is the same as the register number)
la $a2, Register_Table($t4)
lw $t3, 0($a2)
addi $t3, $t3, 1 # Increments its appearance
sw $t3, 0($a2)
jr $ra

##################################################################################################################

Update_Command_Table:
li $t9, 35 # Opcode of lw is 35 in decimal
LW: bne $v0, $t9, SW
la $a2, Command_Table($0)
lw $t3, 0($a2)
addi $t3, $t3, 1 # Increments lw's appearance
sw $t3, 0($a2)
j End

SW: li $t9, 43 # Opcode of sw is 43 in decimal
bne $v0, $t9, BEQ 
li $t4, 4
la $a2, Command_Table($t4)
lw $t3, 0($a2)
addi $t3, $t3, 1 # Increments sw's appearance
sw $t3, 0($a2)
j End
BEQ: li $t4, 8
la $a2, Command_Table($t4)
lw $t3, 0($a2)
addi $t3, $t3, 1 # Increments beq's appearance
sw $t3, 0($a2)
End: jr $ra
