asect 0xf8
br 0x20

asect 0xf0 #vec 0 кнопка количества игроков
dc CountPlayers #0x10
dc 0x80

asect 0xf2 #vec 1 кнопка на геймпаде
dc GamepadBtn #0x84
dc 0x80

asect 0xf4 #vec 2 кнопка Reset
dc 0x00
dc 0x00


asect 0x00

ldi r0, 0
stsp r0
ldi r0, 0x10
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


jsr putX 			# кладет крестик в массив
save r2
jsr test_win 		# проверяет статус игры
restore
ldi r1, 0b11000000	# вычленяем статус игры
and r3, r1			#
if 
tst r1
is eq
br 0xf8    			# уход в ИИ - переключение банков
else
ldi r1, 192
if
cmp r1, r3
is ne
jsr rowIllumination	# подсветка ряда в случае победы
else 
ldi r1, 0xe3		# в случае ничьи
ldi r3, 0b11111111	#
st r1, r3			#
fi
fi
br 0x20
halt


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



putX:				# функция, которая кладёт в массив крестик
wait
GamepadBtn:
pop r0				# чтобы стереть значения
pop r0		
ldi r0, 0xe3  		# загрузка инпута
ld r0, r2
ldi r1, 0b00001111
and r2, r1			# вычленяем индекс массива
ldi r3, 2
st r1, r3
rts



rowIllumination:	# подсветка ряда
ldi r2, 3			# идём в начало выигрышной комбинации
sub r0, r2
ldi r1, 3
while
tst r1 
stays gt 
clr r3
ldc r2, r3			# загружаем нужный индекс
shl r3
shl r3
ldi r0, 0b10000011
or r3, r0
ldi r3, 0xe3		
st r3, r0			# отдаем в оутпут
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