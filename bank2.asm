asect 0xf6
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
if							# проверка статуса игры
	tst r1	
is eq						# если после крестиков продолжение игры
ldi r3, 0xe4				##########ЗАМЕНИТЬ НА Е4##########################
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
is eq						# если после ноликов продолжение игры
	br 0x00
else
ldi r1, 0b01000000
and r3, r1
if 
	tst r1
is eq						# если нолики победили
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
fi							# конец для ноликов
else 
ldi r1, 0b01000000
and r3, r1
if
	tst r1
is eq						#победа крестиков
ldi r1, 0b00001111	
and r2, r1	
ldi r2, 2		
jsr output
dec r0
dec r0
dec r0
ldi r3, 0b10000000
jsr rowIllumination 
else						# ничья после крестиков
ldi r1, 0b00001111	
and r2, r1
ldi r2, 2
jsr output
fi
fi
br 0x00
halt


putX0:				# функция, которая кладёт в массив крестик/нолик
wait
GamepadBtn:
pop r0
pop r0
ldi r0, 0xe3		##########ЗАМЕНИТЬ НА Е3##########################
ld r0, r2
ldi r1, 0b00001111
and r2, r1			# вычленяем индекс массива
st r1, r3
rts


output:
shl r1			# в r1 индекс массива
shl r1
or r1, r2		# в r2 код символа
or r2, r3		# в r3 статус игры
ldi r2, 0xe3	##########ЗАМЕНИТЬ НА Е3##########################
st r2, r3
rts


rowIllumination:	# подсветка ряда
ldi r1, 3
while
tst r1 
stays gt 
save r1
ldc r0, r1			# загружаем нужный индекс
ldi r2, 0b11000000
and r2, r3
ldi r2, 0b00000011
jsr output
inc r0
restore
dec r1
wend
rts


test_win:	  		# функция, проверяющая статус игры
ldi r0, table
ldi r3, 8			# кол-во выигрышных комбинаций
while 
tst r3
stays gt
dec r3	    		# загрузка адреса очередной выигрышной комбинации
ldc r0, r1			# заменить на ldc
inc r0
ld r1, r1			# загружаем данные из ячейки с адресом выигрышной позиции в r1 
if 
tst r1
is gt				# проверка, что в ячейке что-то лежит
move r1, r2
ldc r0, r1			# загружаем следующий символ из выигрышной комбинации
ld r1, r1			#
inc r0
if 
cmp r2, r1			# сравниваем на равенство с предыдущим символом из комбинации
is eq
ldc r0, r1			# загружаем следующий символ из выигрышной комбинации
ld r1, r1
inc r0
if 
cmp r2, r1			# сравниваем на равенство с предыдущим символом из комбинации
is eq 
ldi r3, 0b10000000	# флаг победы
rts
fi
else 
inc r0
fi
else 
inc r0				# сдвиги адреса в table
inc r0				#
fi
wend
clr r0				# теперь проходим весь массив и проверяем на наличие пустых клеток
ldi r2, 3			# 3 - ближайшая ячейка, в которую не кладём символы 
ldi r1, 10			# кол-во ячеек
while 
cmp r1, r0
stays ge
ld r0, r3
if 
tst r3
is eq
ldi r3, 0b00000000  # флаг продолжения игры 
rts
fi
inc r0
if 
cmp r2, r0
is eq
inc r0
ldi r2, 7			# 7 - ближайшая ячейка, в которую не кладём символы
fi
wend
ldi r3, 0b11000000 	# флаг ничьи
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