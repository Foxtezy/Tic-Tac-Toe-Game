asect 0xf8						# similarly as in the main bank
br 0x00

asect 0xf4
dc 0x00
dc 0x00

asect 0x00

ldi r3, 2  
jsr find2inRow					# before calling, it is necessary to load into r3 the opposite symbol from those for which we are looking for 2 occupied and 1 empty

if 
	tst r3
is ge
	ldi r3, 1
	jsr find2inRow
	if
		tst r3
	is ge
		jsr testMiddle
		if
			tst r3
		is ge
			jsr callCorners
		fi
	fi
	ldi r2, 0b00000001
	jsr output
else
save r2
ldi r2, 0b01000001
jsr output
restore
jsr rowIllumination 
fi
br 0xf8



find2inRow:
ldi r0, table
ldi r2, 8						# number of winning combinations
while 
	tst r2
stays gt
	dec r2
	save r2						# we use it as an additional register
	clr r2
	ldc r0, r1
	ld r1, r1					# loading data from the cell with the address of the winning position in r1 
	inc r0
	if 
		cmp r3, r1
	is ne						# checking that there is NO cross in 1 cell
		if 
			tst r1
		is eq
			inc r2
		fi
		ldc r0, r1
		ld r1, r1
		inc r0
		if
			cmp r3, r1
		is ne					# checking that there is NO cross in the 2nd cell
			if
				tst r1	
			is eq				# if there is a void in the second cell of the row
				inc r2
			fi
			ldc r0, r1
			ld r1, r1
			inc r0
			if 
				cmp r3, r1		# checking that there is NO cross in cell 3
			is ne
				if 
					tst r1
				is eq
					inc r2
				fi
				ldi r1, 1
				if 
					cmp r2, r1
				is eq
					jsr put0
					pop r3
					ldi r3, -1	# flag for entering put0
					rts
				fi
			fi
		else
			inc r0
		fi
	else
	inc r0						# address shifts in table
	inc r0						#
	fi
	restore
wend
rts


put0:
clr r2
dec r0
dec r0
dec r0
ldc r0, r1
ld r1, r1
while 
	tst r1
stays ne
	inc r0
	ldc r0, r1
	ld r1, r1
	inc r2
wend
save r2
ldc r0, r1						# r0 contains the address from table
ldi r2, 1						# in r1 is the index
st r1, r2
restore
rts



testMiddle:
ldi r0, 5
ld r0, r1
if
	tst r1
is eq
	ldi r1, 1
	st r0, r1
	ldi r3, -1					# flag
fi
move r0, r1
rts


corners:
ld r1, r0
if
	tst r0
is eq
	ldi r0, 1
	st r1, r0
	ldi r3, -1
fi
rts



callCorners:
ldi r2, cells
while 
	tst r3
stays ge
	ldc r2, r1
	jsr corners
	inc r2
wend
rts


output:
move r1, r3						# in r1 is the index of the array
shla r3
shla r3
or r2, r3
ldi r2, 0xe3
st r2, r3
rts


rowIllumination:				# row illumination
while 
	tst r2
stays gt
	dec r0
	dec r2
wend
ldi r1, 3
move r0, r2
while
tst r1 
stays gt 
clr r3
ldc r2, r3						# loading the desired index
shla r3
shla r3
ldi r0, 0b01000011
or r3, r0
ldi r3, 0xe3		
st r3, r0						# we give it to the output
inc r2
dec r1
wend
rts



inputs>
cells: dc 8, 10, 2, 0, 1, 4, 6, 9
table: dc 0,1,2
       dc 4,5,6
	   dc 8,9,10
	   dc 0,4,8
	   dc 1,5,9
	   dc 2,6,10
	   dc 0,5,10 
	   dc 8,5,2 
	end
