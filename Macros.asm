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
	la $a1, 51
	syscall
	.end_macro 
	
#MACRO PARA LIMPIAR NUMERO EN MEMORIA INCORRECTO
.macro clean_numero(%direccion, %tamano)

li $s1, 0x00	#ASIGNA NULL A $S1

#LOOP PARA VACIAR EL ESPACIO DE MEMORIA
clean_numero: 	 			
		sb   $s1, %direccion($s0)	#METE NULL EN LA POSICION DEL DIGITO
		subi $s0, $s0, 1		#AUMENTAR UNO AL APUNTADOR
		bgez $s0, clean_numero	#RECORRER COMPLETO EL ESPACIO DE MEMORIA
	.end_macro 
	
#MACRO PARA QUITAR EL SIGNO DEL NUMERO EN MEMORIA (SHIFT A LA IZQUIERDA DEL NUMERO)
.macro quitar_signo (%direccion, %tamaño)
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
	
#MACRO PARA VALIDAR QUE EL NUMERO INGRESADO COMO STRING SEA UN NUMERO POSITIVO O 
#NEGATIVO DE HASTA 50 DIGITOS SI ES SUMA O RESTA Y DE HASTA 25 DIGITOS SI ES MULTIPLICACIÓN
.macro validar_numero (%direccion_numero, %registro_signo, %salto_error, %mensaje,%registro_numero)

li $s0, 0			#APUNTADOR PARA RECORRER LA VALIDACIÓN DEL NUMERO

#LOOP QUE RECORRE EL STRING DEL NUMERO
loop_numero:		
		lb   %registro_numero, %direccion_numero($s0) 	#TOMAMOS UN DIGITO DEL STRING
		beqz $s0, validacion_digito
		blt  %registro_numero, 0x30, validacion_digito	#SI EL DIGITO ES MENOR QUE 0X30 (0) ENTONCES VALIDARLO
		bgt  %registro_numero, 0x39, validacion_digito	#SI EL DIGITO ES MAYOR QUE 0X39 (9) ENTONCES VALIDARLO

validacion_apuntador:		
		addi $s0, $s0, 1			#AUMENTAR UNO AL APUNTADOR QUE RECORRE EL NUMERO
	  	bne  $t0, 3, validacion_no_pasar_50	#SI LA OPERACION ES SUMA O RESTA ENTONCES VALIDAR TAMAÑO DEL STRING MENOR A 50
	  	beq  $t0, 3, validacion_no_pasar_25	#SI LA OPERACION ES MULTIPLICACIÓN ENTONCES VALIDAR TAMAÑO MENOR A 25

validacion_no_pasar_50:		
		bgt  $s0, 50, error_digito		#SI ES SUMA O RESTA Y EL APUNTADOR ES MAYOR A 50 ENTONCES ERROR
		j loop_numero			#SEGUIR VALIDADNDO EL NUMERO

validacion_no_pasar_25:		
		bgt  $s0, 25, error_digito		#SI ES MULTIPLICACIÓN Y EL APUNTADOR ES MAYOR A 25 ENTONCES ERROR
		j loop_numero			#SEGUIR VALIDANDO EL NUMERO

#PORCION DE CODIGO QUE VALIDA SI SE INGRESO UNA LETRA U OTRA COSA
validacion_digito:
		beq  %registro_numero, 0x2d, numero_negativo	#REVISAR SI ES UN SIGNO - (2d)
		beq  %registro_numero, 0x2b, numero_positivo	#REVISAR SI ES UN SIGNO + (2b)
		beq  %registro_numero, 0x0a, fin_numero		#SI SE LLEGO AL FINAL DEL STRING ENTONCES TERMINAR LA VALIDACIÓN
		b error_digito			#SI NO CUMPLE NADA DE LO ANTERIOR ENTONCES IR A ERROR
		
#PORCIÓN DE CÓDIGO QUE GUARDA SI EL NUMERO ES NEGATIVO
numero_negativo:	
		bgtz $s0, error_digito	#SI EL APUNTADOR NO ESTÁ EN LA PRIMERA POSICIÓN, ENTONCES MOSTRAR ERROR, PORQUE ES UNA CARACTER INCORRECTO EN MEDIO DEL NUMERO		
		li %registro_signo, 0	#CAMBIAR EL REGISTRO DEL SIGNO A 0
		j validacion_apuntador	#SEGUIR VALIDANDO
		
#PORCIÓN DE CÓDIGO QUE GUARDA SI EL NUMERO ES POSITIVO
numero_positivo:	
		bgtz $s0, error_digito	#SI EL APUNTADOR NO ESTÁ EN LA PRIMERA POSICIÓN, ENTONCES MOSTRAR ERROR, PORQUE ES UNA CARACTER INCORRECTO EN MEDIO DEL NUMERO		
		j validacion_apuntador	#SEGUIR VALIDANDO	

#PORCION DE CODIGO QUE MUESTRA ERROR
error_digito:
		mensaje_string(%mensaje)		#MENSAJE DE ERROR
		clean_numero(%direccion_numero, $s0)	#VACIAR EL ESPACIO DE MEMORIA DONDE ESTABA EL NUMERO
		li $s0, 0				#REINICIAR EL APUNTADOR DEL NUMERO
		b %salto_error			#SALTAR A DONDE VUELVE A PEDIR DATO

#PORCION DE CODIGO QUE SE EJECUTA AL TERMINAR DE REVISAR EL NUMERO
fin_numero:		
		quitar_signo (%direccion_numero, $s0)		#SHIFT A LA IZQUIERDA PARA QUITAR EL SIGNO DEL STRING
	.end_macro 
	
.macro sumar(%numero1, %numero2, %resultado)

	li $s0, 0		#REGISTRO QUE ALMACENA EL ACARREO DE LA SUMA
																									
	move $s1, $a1	#TAMAÑO DEL NUMERO
	
loopsuma:			
	lb   $t1,%numero1($s1)	#AGARRAR EL ULTIMO DIGITO DEL NUMERO 1	
	lb   $t2, %numero2($s1)	#AGARRAR EL ULTIMO DIGITO DEL NUMERO 2
			
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
	
bnez $s0, acarreo_final		#SI QUEDA ACARREO CUANDO SE TERMINAN DE SUMAR LOS DOS NUMEROS ENTONCES HAY QUE METER EL ACARREO EN EL NUMERO
acarreo_final:
	meter_acarreo_final	
b final
#PARTE DE CODIGO QUE MANEJA EL ACARREO
acarreo:			
	subi $t3,$t3,10	#SE LE QUITA 10 A $t3 PORQUE NINGUN ACARREO LLEGA A 20
	li $s0,1		#SE PONE EL ACARREO EN 1
	b loopsuma2	#SE SIGUE SUMANDO
	
final:
.end_macro 
	
#MACRO PARA METER EL ULTIMO DIGITO DEL ACARREO EN EL NUMERO (SHIFT A LA DERECHA)
.macro meter_acarreo_final()

addi $s0, $a1, 1		#APUNTADOR AL ESPACIO SIGUIENTE
move $s1, $a1		#APUNTADOR AL ESPACIO ACTUAL
li $s2, 0x30		#CERO
			
loop_shift:			
	lb   $t3, resultado($s1)	#GUARDA EN $t3 EL DIGITO ACTUAL
	sb   $s2, resultado($s1)	#CAMBIA EL DIGITO ACTUAL EN MEMORIA A 0
	sb   $t1, resultado($s0)	#PONE EL DIGITO ACTUAL EN LA POSICION SIGUIENTE
	subi $s1, $s1, 1		#LE RESTA 1 AL APUNTADOR ACTUAL
	subi $s0, $s0, 1		#LE RESTA 1 AL APUNTADOR SIGUIENTE
	bgez $s1, loop_shift	#REPITE EL SHIFT HASTA QUE EL APUNTADOR ACTUAL LLEGA AL PRINCIPIO DEL NUMERO
	
li   $t3, 0x31		#COMO EL ACARREO NO PUEDE SER MAYOR A 1, EL ACARREO VALE 1
sb   $t3, resultado($s0)	#GUARDA EL ACARREO DEL PRINCIO (FINAL)
	.end_macro 