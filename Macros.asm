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
	la $a1, 50
	syscall
.end_macro 
	
	
	
#MACRO PARA LIMPIAR NUMERO EN MEMORIA SI ES INCORRECTO
.macro clean_numero(%direccion, %tamano)

li $s1, 0x00		#ASIGNA NULL A $S1

#LOOP PARA VACIAR EL ESPACIO DE MEMORIA
clean_numero: 	 			
		sb $s1, %direccion(%tamano)		#METE NULL EN LA POSICION DEL DIGITO
		subi %tamano, %tamano, 1		#RETROCEDER UNA POSICION AL APUNTADOR
		bgez %tamano, clean_numero		#RECORRER EL ESPACIO DE MEMORIA HASTA EL INICIO
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
