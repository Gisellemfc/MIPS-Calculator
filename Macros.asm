.data

.text



#MACRO QUE FINALIZA EL PROGRAMA
.macro fin
	li $v0, 10
	syscall
.end_macro 

		

#MACRO QUE IMPRIME MENSAJE
.macro mensaje_string (%text)
	li   $v0,4
	la   $a0, %text
	syscall
.end_macro 



#MACRO PARA IMPRIMIR LOS DATOS DE LA OPERACION
.macro imprimir_datos()

		mensaje_string(num1)
		beq $t4, 1, imp_mas_num1
			
			mensaje_string(menos)
			mensaje_string(numero1)
			b imprimir_operacion
		
		imp_mas_num1:

			mensaje_string(mas)
			mensaje_string(numero1)
			b imprimir_operacion

imprimir_operacion:
		
		beq $t0, 1, imp_signo_suma
		beq $t0, 2, imp_signo_resta
		
				mensaje_string(por)
				b imprimir_numero2
		
		imp_signo_suma:
		
				mensaje_string(mas)
				b imprimir_numero2
		
		imp_signo_resta:
		
				mensaje_string(menos)
				b imprimir_numero2
		
imprimir_numero2:

		mensaje_string(num2)
		beq $t5, 1, imp_mas_num2
			
			mensaje_string(menos)
			mensaje_string(numero2)
			b casos
		
		imp_mas_num2:

			mensaje_string(mas)
			mensaje_string(numero2)
			b casos
			
.end_macro 

#MACRO QUE IMPRIME EL RESULTADO DE LA OPERACION
.macro imprimir_resultado (%signo, %resultado, %res)

	mensaje_string(%res)
	mensaje_string(%signo)
	mensaje_string(%resultado)
	
.end_macro 

			
	
#MACRO QUE PIDE UN ENTERO
.macro pedir_entero (%registro)
	li  $v0, 5
	syscall
	move %registro, $v0
.end_macro 
	
	
	
#MACRO QUE PIDE UN STRING
.macro pedir_string (%direccion)
	li $v0, 8
	la $a0, %direccion
	la $a1, 50
	syscall
.end_macro 
	
	
	
#MACRO PARA LIMPIAR NUMERO EN MEMORIA SI ES INCORRECTO
.macro clean_numero(%direccion, %tamano)

li $s1, 0x00		#ASIGNA NULL A $S1

#LOOP PARA VACIAR EL ESPACIO DE MEMORIA
clean_num: 	 			
		sb $s1, %direccion(%tamano)		#METE NULL EN LA POSICION DEL DIGITO
		subi %tamano, %tamano, 1		#RETROCEDER UNA POSICION AL APUNTADOR
		bge %tamano, 0, clean_num		#RECORRER EL ESPACIO DE MEMORIA HASTA EL INICIO
.end_macro 
	
	
	
#MACRO PARA VALIDAR QUE EL NUMERO INGRESADO COMO STRING SEA UN NUMERO POSITIVO O NEGATIVO DE HASTA 50 DIGITOS
.macro validar_numero (%direccion_numero, %registro_signo, %salto_error, %mensaje,%registro_numero, %registro_tamano)

li $s0, 0			#APUNTADOR PARA RECORRER LA VALIDACIÓN DEL NUMERO

#LOOP QUE RECORRE EL STRING DEL NUMERO
loop_numero:		
		lb   %registro_numero, %direccion_numero($s0) 	#TOMAMOS UN DIGITO DEL STRING
		beqz $s0, validacion_digito			#SI ES EL PRIMER DÍGITO ENTONCES VALIDAMOS SI ES EL SIGNO
		blt  %registro_numero, 0x30, validacion_digito	#SI EL DIGITO ES MENOR QUE 0X30 (0) ENTONCES VALIDARLO
		bgt  %registro_numero, 0x39, validacion_digito	#SI EL DIGITO ES MAYOR QUE 0X39 (9) ENTONCES VALIDARLO

		validacion_apuntador:		
		addi $s0, $s0, 1			#AUMENTAR UNO AL APUNTADOR QUE RECORRE EL NUMERO		
		bgt  $s0, 50, error_digito		#VALIDAR SI EL NUMERO ES MAYOR A 50 DIGITOS ENTONCES ERROR
		j loop_numero			#SEGUIR VALIDADNDO EL NUMERO


#PORCION DE CODIGO QUE VALIDA SI SE INGRESO UNA LETRA U OTRA COSA
validacion_digito:
		beq  %registro_numero, 0x2d, numero_negativo	#REVISAR SI ES UN SIGNO - (2d)
		beq  %registro_numero, 0x2b, numero_positivo	#REVISAR SI ES UN SIGNO + (2b)
		beq  %registro_numero, 0x0a, fin_numero		#SI SE LLEGO AL FINAL DEL STRING ENTONCES TERMINAR LA VALIDACIÓN
		b error_digito			#SI NO CUMPLE NADA DE LO ANTERIOR ENTONCES IR A ERROR
		
		
#PORCIÓN DE CÓDIGO QUE GUARDA SI EL NUMERO ES NEGATIVO
numero_negativo:	
		bgtz $s0, error_digito	#SI EL APUNTADOR NO ESTÁ EN LA PRIMERA POSICIÓN, ENTONCES MOSTRAR ERROR, PORQUE ES UN CARACTER INCORRECTO EN MEDIO DEL NUMERO		
		li %registro_signo, 0	#CAMBIAR EL REGISTRO DEL SIGNO A 0 (-)
		j validacion_apuntador	#SEGUIR VALIDANDO
		
		
#PORCIÓN DE CÓDIGO QUE GUARDA SI EL NUMERO ES POSITIVO
numero_positivo:	
		bgtz $s0, error_digito	#SI EL APUNTADOR NO ESTÁ EN LA PRIMERA POSICIÓN, ENTONCES MOSTRAR ERROR, PORQUE ES UN CARACTER INCORRECTO EN MEDIO DEL NUMERO		
		j validacion_apuntador	#SEGUIR VALIDANDO, PORQUE POR DEFECTO EL REGISTRO DEL SIGNO ES (+)	


#PORCION DE CODIGO QUE MUESTRA ERROR
error_digito:
		mensaje_string(%mensaje)		#MENSAJE DE ERROR
		mensaje_string(separador)		#LÍNEA SEPARADORA
		clean_numero(%direccion_numero, $s0)	#VACIAR EL ESPACIO DE MEMORIA DONDE ESTABA EL NUMERO
		li $s0, 0				#REINICIAR EL APUNTADOR DEL NUMERO
		b %salto_error			#SALTAR A DONDE VUELVE A PEDIR DATO


#PORCION DE CODIGO QUE SE EJECUTA AL TERMINAR DE REVISAR EL NUMERO
fin_numero:		
		subi $s0, $s0, 2				#SE QUITA 2 PARA DESCONTAR EL SIGNO Y QUE APUNTA A NULL	
		move %registro_tamano, $s0			#SE GUARDA EL TAMAÑO DEL NUMERO EN UN REGISTRO
		addi $s0, $s0, 2				#SE DEJA EL APUNTADOR DONDE ESTABA ANTES
		shift_izquierda (%direccion_numero, $s0)		#SHIFT A LA IZQUIERDA PARA QUITAR EL SIGNO DEL STRING
.end_macro 



#MACRO PARA IGUALAR LOS TAMAÑOS DE LOS NUMEROS SI ES SUMA
.macro igualar_tamano(%numero1, %numero2, %tamano1, %tamano2)

beq %tamano1, %tamano2, final_relleno
blt %tamano1, %tamano2, rellenar_numero1
blt %tamano2, %tamano1, rellenar_numero2

rellenar_numero1:
		shift_derecha(%numero1, %tamano1)
		addi %tamano1, %tamano1, 1
		bne %tamano1, %tamano2, rellenar_numero1
		b final_relleno

rellenar_numero2:
		shift_derecha(%numero2, %tamano2)
		addi %tamano2, %tamano2, 1
		bne %tamano1, %tamano2, rellenar_numero2
		b final_relleno

final_relleno:
.end_macro 



#MACRO PARA CALCULAR EL MAYOR SI ES RESTA
.macro calcular_mayor()

li $s0, 0				#APUNTADOR AL PRINCIPIO DEL NÚMERO

beq $t6, $t7, comparar		#SI LOS NUMEROS TIENEN EL MISMO TAMAÑO ENTONCES COMPARAR PRIMER DÍGITO
blt $t6, $t7, numero2_mayor		#SI EL NUMERO 2 ES MÁS GRANDE
blt $t7, $t6, numero1_mayor		#SI EL NUMERO 1 ES MÁS GRANDE


#PORCIÓN DE CÓDIGO QUE COMPARA EL PRIMER DÍGITO DE LOS NUMEROS
comparar:
	
	lb  $t1, numero1($s0)	#AGARRO EL PRIMER DÍGITO DEL NÚMERO 1
	and $t1, $t1, 0x000f	
	lb  $t2, numero2($s0)	#AGARRO EL PRIMER DÍGITO DEL NÚMERO 2
	and $t2, $t2, 0x000f
		
	
	blt $t1, $t2, numero2_mayor	#SI EL ULTIMO DÍGITO DEL NUMERO 2 ES MAYOR ENTONCES NUMERO 2 ES MÁS GRANDE
	blt $t2, $t1, numero1_mayor	#SI EL ULTIMO DÍGITO DEL NUMERO 1 ES MAYOR ENTONCES NUMERO 1 ES MÁS GRANDE
	
	beq $s0, $t6, numero1_mayor
	addi $s0, $s0, 1
	beq $t1, $t2, comparar					
	
	
	
#PORCIÓN DE CODIGO SI EL NUMERO 1 ES MAYOR
numero1_mayor:
	li $t8, 0			#CAMBIAMOS EL REGISTRO A NÚMERO 1 ES EL MAYOR
	b final_calcular_mayor	#SALTAMOS AL FINAL

	
#PORCIÓN DE CODIGO SI EL NUMERO 2 ES MAYOR	
numero2_mayor:
	li $t8, 1			#CAMBIAMOS EL REGISTRO A NÚMERO 1 ES EL MAYOR
	b final_calcular_mayor	#SALTAMOS AL FINAL
	
final_calcular_mayor:
.end_macro 

	
			
#MACRO PARA HACER LA SUMA DE LOS DOS NUMERO
.macro sumar(%numero1, %numero2, %resultado, %tamano)

	li $s0, 0		#REGISTRO QUE ALMACENA EL ACARREO DE LA SUMA																							
	move $s1, %tamano	#TAMAÑO DEL NUMERO
	
loopsuma:			
	lb   $t1,%numero1($s1)	#AGARRAR EL ULTIMO DIGITO DEL NUMERO 1	
	lb   $t2, %numero2($s1)	#AGARRAR EL ULTIMO DIGITO DEL NUMERO 2
	
	subi $t1, $t1, 0x30
	subi $t2, $t2, 0x30
	
	add  $t3,$t2,$t1		#SUMA LOS DOS NUMEROS		
	add  $t3,$t3,$s0		#SUMA EL ACARREO
				
	li   $s0,0		#REINICIA EL ACARREO
	bge  $t3,10,acarreo		#SI $t3 ES MAYOR A 10 ENTONCES EL NUMERO TIENE ACARREO
				
loopsuma2:			
	ori  $t3,$t3,0x30		#CONVERTIR LO QUE QUEDO EN $t3 A ASCII
	sb   $t3, %resultado($s1)	#GUARDAR EL DIGITO DEL RESULTADO
				
loopsuma3:			
	subi $s1, $s1,1		#SE MUEVE EL APUNTADOR AL NUMERO DE LA IZQUIERDA
			
	bgez $s1, loopsuma		#MIENTRAS EL APUNTADOR SEA MAYOR A 0 SEGUIR SUMANDO

		
beqz $s0, final		#SI NO QUEDA ACARREO CUANDO SE TERMINAN DE SUMAR LOS DOS NUMEROS ENTONCES HAY QUE METER EL ACARREO EN EL NUMERO


#PORCIÓN DE CÓDIGO QUE MANEJA EL ACARREO FINAL DEL NÚMERO
acarreo_final:
	shift_derecha(%resultado, %tamano)	
	li   $t3, 0x31		#COMO EL ACARREO NO PUEDE SER MAYOR A 1, EL ACARREO VALE 1
	sb   $t3, resultado($s0)	#GUARDA EL ACARREO DEL PRINCIO (FINAL)
b final


#PARTE DE CODIGO QUE MANEJA EL ACARREO
acarreo:			
	subi $t3,$t3,10	#SE LE QUITA 10 A $t3 PORQUE NINGUN ACARREO LLEGA A 20
	li $s0,1		#SE PONE EL ACARREO EN 1
	b loopsuma2	#SE SIGUE SUMANDO
	
	
final:
.end_macro 



#MACRO PARA RESTAR LOS DOS NÚMEROS
.macro restar(%numero1, %numero2, %resultado, %tamano)
			
move $s0, %tamano			#APUNTADOR QUE RECORRE LOS NUMEROS DE ATRÁS PARA ADELANTE	
li $s1, 0				#GUARDA EL ACARREO DE LA RESTA																					
																						addi $t0, $a1, 2
Resta1_Loop:			
		lb   $t1, %numero1($s0)		#AGARRAMOS EL ÚLTIMO DÍGITO DEL NUMERO 1
		lb   $t2, %numero2($s0)		#AGARRAMOS EL ÚLTIMO DÍGITO DEL NUMERO 2
		
		subi $t1, $t1, 0x30
		subi $t2, $t2, 0x30
		
		bnez $s1, acarreo_resta		#SI HAY ACARREO DE LA RESTA VA AL CÓDIGO QUE MANEJA EL ACARREO
		
Resta1_Loop2:	
		blt  $t1, $t2, sumar_diez		#SI NO HAY ACARREO VERIFICA SI EL DE ARRIBA ES MENOR QUE EL DE ABAJO LE TIENE QUE SUMAR 10
Resta1_Loop3:				
		sub  $t3,$t1,$t2			#DESPUES LOS RESTA
				
		ori   $t3,$t3,0x30			#LO CONVIERTE A ASCII
		sb   $t3, %resultado($s0)		#GUARDA EL RESULTADO
				
Resta1_Loop4:			
		subi $s0, $s0, 1			#SE RESTA 1 AL APUNTADOR
		bgez $s0, Resta1_Loop		#MIENTRAS NO LLEGUE AL FINAL DEL NUMERO SIGUE RESTANDO
		j final_resta			#SI LLEGA AL FINAL SALTAR
	
	
#PORCIÓN DE CÓDIGO QUE PIDE PRESTADO 10 AL NUMERO DE AL LADO
sumar_diez:
		addi $t1, $t1, 10		#SUMA 10 AL NUMERO DE ARRIBA
		li   $s1, 1		#SUMA 1 AL ACARREO
		bnez $s0, Resta1_Loop3	#VUELVE A SEGUIR RESTANDO 
		b final_resta			

#PORCIÓN DE CÓDIGO QUE MANEJA EL ACARREO DE LA RESTA
acarreo_resta:			
		beqz $t1, caso_zero		#SI EL NUMERO DE ARRIBA ES 0, ENTONCES SE TIENE QUE CONVERTIR EN UN 9
		subi $t1, $t1, 1		#SI EL ANTERIOR PIDIÓ PRESTA HAY QUE RESTARLE 1 AL NUMERO
		li   $s1, 0		#SE REINICIA EL ACARREO		
		bgez $s0, Resta1_Loop2	#SE VUELVE A LA RESTA NORMAL
		b final_resta
		
#PORCION DE CODIGO EN CASO DE QUE EL NUMERO DE ARRIBA SEA 0						
caso_zero:			
		li $t1, 9			#SE CONVIERTE EL DIGITO DE ARRIBA EN 9
		bnez $s0, Resta1_Loop2	#SE SIGUE RESTANDO
		b final_resta
				

final_resta:
.end_macro 

	
	
#MACRO PARA HACER LA MULTIPLICACIÓN 
.macro multiplicar(%numero1, %numero2, %resultado, %tamano1, %tamano2)
				
move $s0, %tamano1 			#APUNTADOR QUE RECORRE EL PRIMER NUMERO	 $t7	
move $s1, %tamano2			#APUNTADOR QUE RECORRE EL SEGUNDO NUMERO $t8
move $t0, %tamano2				
li $s2, 0				#BANDERA PARA CORRER EL NUMERO AL MULTIPLICAR $s0


#LOOP PARA MULTIPLICAR
loop_mul:				
		bnez $s2, no_hacer_shift	#SI LA BANDERA ES 0 ENTONCES HACER SHIFT
		
	hacer_shift:
		jal shift_resultado		#SHIFT A LA DERECHA DEL RESULTADO

	no_hacer_shift:
	loop_mul1:		
		li $s2, 0				#REINICIAR LA BANDERA PARA CORRE EL NUMERO
		lb  $t1, %numero1($s0)		#CARGO UN DIGITO DE NUMERO 1	
		and $t1,$t1,0x00f			#SE PASA A DECIMAL
		
	
	#LOOP QUE MULTIPLICA TODO EL NUMERO 1 POR EL DIGITO DEL NUMERO 2		
	loop_digito:		
		lb  $t2, %numero2($s1)		#AGARRO UN DIGITO DE MUMERO 2
		and $t2,$t2,0x00f			#LO PASO A DECIMAL
		mul   $t3, $t1, $t2			#MULTIPLICO LOS DIGITOS
		add   $t3, $t3, $s6		  	#LE SUMO EL ACARREO ANTERIOR DE LA MULTIPLICACION
		li $s6, 0				#REINICIO EL ACARREO ($t5)
		bge   $t3, 10, acarreo_mult		#SI EL RESULTADO ES MAYOR A 10 TENGO ACARREO PARA EL SIGUIENTE
		
		loop_m2:			
			lb  $s7, %resultado($s1)		#$t6	AGARRO EL DÍGITO DE RESULTADO QUE ESTA EN LA POSICION A SUMAR	
			and $s7,$s7,0x00f			#SE PASA A DECIMAL
			add $t3, $t3, $s7			#SE SUMA EL RESULTADO ACTUAL CON LO QUE LLEVABA ANTES
			add $t3, $t3, $t9			#SE SUMA EL ACARREO DE LA SUMA SI HAY ($T4)
			li  $t9, 0			#SE REINICIA EL ACARREO DE LA SUMA
			bge $t3, 10, acarreo_final		#SI $T3 ES MAYOR A 10 ENTONCES TIENE ACARREO LA SUMA
				
		loop_m3:			
			ori $t3,$t3,0x30			#PASAR EL DIGITO A ASCII
			sb $t3, %resultado($s1)		#GUARDAR EL RESULTADO	
			
			subi $s1,$s1,1			#QUITO UNO AL APUNTADOR DEL NUMERO 2
			bgez $s1, loop_digito		#SE RECORRES HASTA QUE SE TERMINA DE MULTIPLICAR EL DIGITO POR TODO EL NUMERO 2
			bnez $s6, add_ultimo_digito		#AL TERMINAR, SI HAY ACARREO DE MULTIPLICACION, SE METE
			bnez $t9, add_ultimo_digito_suma			
	
		loop_num1:			
		move $s1, %tamano2			#COMO HUBO ACARREO EL NUMERO AHORA TIENE +1 DE TAMAÑO
		subi  $s0, $s0,1			#QUITAR UNO AL APUNTADOR DEL NUMERO 1
		bgez $s0, loop_mul			#SEGUIR RECORRIENDO LA MULTIPLICACION
		b revisar_ceros
	

#PORCION DE CODIGO PARA METER EL ACARREO DE LA MULTIPLICACION AL FINAL			
add_ultimo_digito:		
		li $s2, 1				
		add $s6, $s6, $t9
		jal shift_resultado
		bge $s6, 10, otro_mas
		b add_final
		
		otro_mas:	
			subi $s6, $s6, 10
			or $t3, $s6, 0x30
			sb $t3, %resultado($zero)
			li $s6, 0
			jal shift_resultado
			li $t3, 0x31
			sb $t3, %resultado($zero)
			j loop_num1
			
		add_final:	
			or $t3, $s6, 0x30
			sb $t3, %resultado($zero)
			li $s6, 0
			li $t9, 0
			j loop_num1


#PORCION DE CODIGO PARA METER EL ACARREO DE LA SUMA AL FINAL			
add_ultimo_digito_suma:		
		li $s2, 1	
		li $s6, 0			
		add $s6, $s6, $t9
		jal shift_resultado
		bge $s6, 10, otro_mas_suma
		b add_final_suma
		
		otro_mas_suma:	
			subi $s6, $s6, 10
			or $t3, $s6, 0x30
			sb $t3, %resultado($zero)
			li $s6, 0
			jal shift_resultado
			li $t3, 0x31
			sb $t3, %resultado($zero)
			j loop_num1
			
		add_final_suma:	
			or $t3, $s6, 0x30
			sb $t3, %resultado($zero)
			li $t9, 0
			li $s6, 0
			j loop_num1


#SHIFT A LA DERECHA DE RESULTADO
shift_resultado:		
		add  $s3, %tamano1, %tamano2		#$T0 APUNTADOR POSICIÓN ACTUAL (TAMAÑO MÁX DE LA MULTIPLICACIÓN)
		addi $s4, $s3, 1			#APUNTADOR A POSICIÓN SIGUIENTE $T4	
		li   $s5, 0x30			#CERO EN ASCII	
loop_shift_mul:	
		lb   $t3, %resultado($s3)		#SE TOMA EL NUMERO DE LA POSICION ACTUAL		
		sb   $s5, %resultado($s3)		#SE PONE CERO EN LA POSICION ACTUAL
		sb   $t3, %resultado($s4)		#SE MUEVE EL NUMERO ACTUAL A LA POSICION SIGUIENTE
		subi $s3, $s3, 1			#SE QUITA 1 AL APUNTADOR
		subi $s4, $s4, 1			#SE QUITA 1 AL APUNTADOR
		bgez $s3, loop_shift_mul		#SE REPITE HASTA LLEGAR AL INICIO DEL NUMERO
		li   $s4, 0			#SE LIMPIA $S4
		jr   $ra				#SEGUIR EN DONDE ESTABA
			
			
#PORCIÓN DE CODIGO QUE MANEJA EL ACARREO DE LA MULTIPLICACION
acarreo_mult:			div $s6, $t3, 10		# DIVIDO ENTRE 10 (35 / 10 = 3 EN LO)
				mfhi $t3			# DEJO EL RESIDUO EN T3 (35 / 10 --> 5 EN HI)
				j loop_m2			#VUELVO A SEGUIR MULTIPLICANDO
				
				
#PORCION DE CODIGO QUE MANEJA EL ACARREO DE LA SUMA		
acarreo_final:			subi $t3, $t3, 10		#LE QUITA 10 A $T3
				li $t9, 1			#SE PONE 1 EN EL ACARREO
				j loop_m3			#VOLVER A MULTIPLICAR
	
																									
revisar_ceros:

	lb  $t3, %resultado($zero)
	beq $t3, 0x30, quitar_cero
	b final_multiplicacion

quitar_cero:	
	add  $s3, %tamano1, %tamano2
	shift_izquierda(%resultado, $s3)
	lb  $t3, %resultado($zero)
	beq $t3, 0x30, quitar_cero

final_multiplicacion:
.end_macro
	
	
	
#MACRO PARA METER EL ULTIMO DIGITO DEL ACARREO EN EL NUMERO (SHIFT A LA DERECHA DEL NUMERO)
.macro shift_derecha(%direccion, %tamano)

addi $s0, %tamano, 1		#APUNTADOR AL ESPACIO SIGUIENTE
move $s1, %tamano		#APUNTADOR AL ESPACIO ACTUAL
li $s2, 0x30		#CERO
			
loop_shift:			
	lb   $s3, %direccion($s1)	#GUARDA EN $s3 EL DIGITO ACTUAL
	sb   $s2, %direccion($s1)	#CAMBIA EL DIGITO ACTUAL EN MEMORIA A 0
	sb   $s3, %direccion($s0)	#PONE EL DIGITO ACTUAL EN LA POSICION SIGUIENTE
	subi $s1, $s1, 1		#LE RESTA 1 AL APUNTADOR ACTUAL
	subi $s0, $s0, 1		#LE RESTA 1 AL APUNTADOR SIGUIENTE
	bgez $s1, loop_shift	#REPITE EL SHIFT HASTA QUE EL APUNTADOR ACTUAL LLEGA AL PRINCIPIO DEL NUMERO

.end_macro 



#MACRO PARA QUITAR EL SIGNO DEL NUMERO EN MEMORIA (SHIFT A LA IZQUIERDA DEL NUMERO)
.macro shift_izquierda (%direccion, %tamaño)

li $s1, 1 	#APUNTADOR POSICION SIGUIENTE
li $s2, 0 	#APUNTADOR POSICION ACTUAL
li $t9, 0x00	#ASIGNADOR DE NULL A ESPACIOS LIBRES

loop_shift:	
		lb   $t8, %direccion($s1)		#AGARRO EL NUMERO DE LA POSICION SIGUIENTE
		sb   $t9, %direccion($s1)		#PONGO NULL A ESA POSICION
		sb   $t8, %direccion($s2)		#PONGO EL NUMERO DE LA POSICION SIGUIENTE EN LA POSICION ACTUAL
		addi $s1, $s1, 1			#AUMENTO APUNTADOR SIGUIENTE
		addi $s2, $s2, 1			#AUMENTO APUNTADOR ACTUAL
		blt  $s2, %tamaño, loop_shift		#SE REPITE HASTA QUE RECORRE TODO EL NUMERO
.end_macro 
