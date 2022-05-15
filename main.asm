asect 0xf8			# the first two lines are where we need to go back ->
br 0x20				# -> after switching from 1 bank to zero

asect 0xf0			# vec 0 button of the number of players
dc CountPlayers		# 0x10
dc 0x80

asect 0xf2			# vec 1 button on the gamepad
dc GamepadBtn		# 0x84
dc 0x80

asect 0xf4			# vec 2 the Reset button
dc 0x00
dc 0x00


asect 0x00

ldi r0, 0
stsp r0				# stack shift to the original position because when reset SP it does not return to the beginning
ldi r0, 0x10		# setting the I (Interrupt) flag in PS (so that interrupts work)
push r0
ldi r0, 0b10000000
push r0
rti 

CountPlayers:
ldi r0, 0xe4
ld r0, r1
if
	tst r1
is eq
wait 
else
ldi r0, 2
if
	cmp r1, r0
is eq
br 0xf6
fi
fi


jsr putX 			# puts a cross in the array
save r2
jsr test_win 		# checks the status of the game
restore
ldi r1, 0b11000000	# we isolate the status of the game
and r3, r1			#
if 
tst r1
is eq
br 0xf8    			# going into AI - switching banks
else
ldi r1, 192
if
cmp r1, r3
is ne
jsr rowIllumination	# row illumination in case of victory
else 
ldi r1, 0xe3		# in case of a draw
ldi r3, 0b11111111	#
st r1, r3			#
fi
fi
br 0x20
halt


test_win:	  		# a function that checks the status of the game
ldi r0, table
ldi r3, 8			# number of winning combinations
while 
tst r3
stays gt
dec r3	    		# uploading the address of the next winning combination
ldc r0, r1
inc r0
ld r1, r1			# loading data from the cell with the address of the winning position in r1 
if 
tst r1
is gt				# checking that there is something in the cell
move r1, r2
ldc r0, r1			# loading the next symbol from the winning combination
ld r1, r1			#
inc r0
if 
cmp r2, r1			# compare for equality with the previous symbol from the combination
is eq
ldc r0, r1			# loading the next symbol from the winning combination
ld r1, r1
inc r0
if 
cmp r2, r1			# compare for equality with the previous symbol from the combination
is eq 
ldi r3, 0b10000000	# victory flag
rts
fi
else 
inc r0
fi
else 
inc r0				# address shifts in table
inc r0				#
fi
wend
clr r0				# now we go through the array completely and check for empty cells
ldi r2, 3			# 3 - the nearest cell in which we don't put symbols
ldi r1, 10			# number of cells
while 
cmp r1, r0
stays ge
ld r0, r3
if 
tst r3
is eq
ldi r3, 0b00000000  # flag of the continuation of the game
rts
fi
inc r0
if 
cmp r2, r0
is eq
inc r0
ldi r2, 7			# 7 - the nearest cell in which we don't put symbols
fi
wend
ldi r3, 0b11000000 	# draw flag
rts



putX:				# a function that puts a cross in the array
wait
GamepadBtn:
pop r0				# to erase values
pop r0		
ldi r0, 0xe3  		# loading the input
ld r0, r2
ldi r1, 0b00001111
and r2, r1			# we isolate the index of the array
ldi r3, 2
st r1, r3
rts



rowIllumination:	# row illumination
ldi r2, 3			# go to the beginning of the winning combination
sub r0, r2
ldi r1, 3
while
tst r1 
stays gt 
clr r3
ldc r2, r3			# loading the desired index
shl r3
shl r3
ldi r0, 0b10000011
or r3, r0
ldi r3, 0xe3		
st r3, r0			# we give it to the output
inc r2
dec r1
wend
rts


inputs>
table: dc 0,1,2
       dc 4,5,6
	   dc 8,9,10
	   dc 0,4,8
	   dc 1,5,9
	   dc 2,6,10
	   dc 0,5,10 
	   dc 8,5,2 
	end