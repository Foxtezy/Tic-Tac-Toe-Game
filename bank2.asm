asect 0xf6			# similarly as in the main program
br 0x00

asect 0xf2
dc GamepadBtn
dc 0x80

asect 0xf4
dc 0x00
dc 0x00

asect 0x00

ldi r3, 2
jsr putX0
save r2
jsr test_win
restore
ldi r1, 0b10000000
and r3, r1
if					# checking the status of the game
	tst r1	
is eq				# if after the move of the crosses the game continues
ldi r3, 0xe4
st r3, r3
ldi r3, 1
jsr putX0
save r2
jsr test_win
restore
ldi r1, 0b10000000
and r3, r1
if
	tst r1
is eq				# if after the move of the noughts the game continues
	br 0x00
else
ldi r1, 0b01000000
and r3, r1
if 
	tst r1
is eq				# if the noughts won
ldi r3, 0b01000000
ldi r1, 0b00001111	
and r2, r1	
ldi r2, 1		
jsr output
dec r0
dec r0
dec r0
ldi r3, 0b01000000
jsr rowIllumination 
fi
fi					# the end for the noughts
else 
ldi r1, 0b01000000
and r3, r1
if
	tst r1
is eq				# victory of crosses
ldi r1, 0b00001111	
and r2, r1	
ldi r2, 2		
jsr output
dec r0
dec r0
dec r0
ldi r3, 0b10000000
jsr rowIllumination 
else				# draw after the move of crosses
ldi r1, 0b00001111	
and r2, r1
ldi r2, 2
jsr output
fi
fi
br 0x00
halt


putX0:				# a function that puts crosses and noughts in the array
wait
GamepadBtn:
pop r0
pop r0
ldi r0, 0xe3
ld r0, r2
ldi r1, 0b00001111
and r2, r1			# we isolate the index of the array
st r1, r3
rts


output:
shl r1				# in r1 is the index of the array
shl r1
or r1, r2			# in r2 is the symbol code
or r2, r3			# in r3 is the status of the game
ldi r2, 0xe3
st r2, r3
rts


rowIllumination:	# row illumination
ldi r1, 3
while
tst r1 
stays gt 
save r1
ldc r0, r1			# loading the desired index
ldi r2, 0b11000000
and r2, r3
ldi r2, 0b00000011
jsr output
inc r0
restore
dec r1
wend
rts


test_win:	 		# a function that checks the status of the game
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
ldi r1, 10			# the number of cells
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
ldi r3, 0b11000000	# draw flag
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