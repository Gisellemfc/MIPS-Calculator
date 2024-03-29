#INCLUIR EL ARCHIVO DE LOS MACROS EN EL PROYECTO
.include "macros.asm"


#SECCI�N DE DATOS EN MEMORIA
.data

#MENSAJES DE INICIO DEL PROGRAMA
titulo:		.asciiz "------------------------------------------------|    CALCULADORA BASICA    |-------------------------------------------------\n\n"
encabezado:	.asciiz "        Este proyecto fue elaborado por Nicole Brito y Giselle Ferreira, estudiantes de la Universidad Metropolitana, \n        en la asignatura de Organizaci�n del Computador, dictada por el profesor Rafael Matienzo.\n"	
descripcion:	.asciiz "\nDescripci�n: Este es un programa que realiza la suma, la resta y la multiplicaci�n de n�meros enteros largos. Dichos \nenteros no caben en registros, sino que se representan como cadenas de caracteres de hasta 50 caracteres, todos los \ncuales son caracteres ASCII num�ricos, excepto el primero que es un signo (+ o -).\n\n"
instrucciones:	.asciiz "Instrucciones:\n1) Las operaciones se realizan con n�meros de hasta 50 d�gitos, incluyendo el signo. \n2) Los n�meros que ingrese deben incluir obligatoriamente como primer d�gito un signo (+) si el n�mero es positivo o un \nsigno (-) si el n�mero es negativo.\n3)Al introducir un dato err�neo, recibir� un mensaje de error y se le solicitar�n los datos nuevamente.\n"
separador:	.asciiz "\n-----------------------------------------------------------------------------------------------------------------------------\n"	

#MENSAJES DE ERROR
opcion_invalida:	.asciiz "\nOpci�n inv�lida... Int�ntalo nuevamente"
numero_invalido:	.asciiz "\nN�mero inv�lido... Int�ntalo nuevamente"

#MEN� DE OPERACIONES
menu:		.asciiz "\nMen�: \n\n(1) Sumar \n(2) Restar \n(3) Multiplicar \n\nIngrese el n�mero de la operaci�n que desea realizar: "

#MENSAJE DE DESPEDIDA
adios:		.asciiz "\n\nGracias por usar la calculadora, hasta pronto."

#MENSAJES PARA PEDIR NUMEROS
solicitud1:	.asciiz "\nIngrese el primer n�mero: "
solicitud2:	.asciiz "\nIngrese el segundo n�mero: "

#MENSAJES DEL RESULTADO DE LAS OPERACIONES
num1:		.asciiz "\nN�mero 1: "
num2:		.asciiz "\nNumero 2: "
res:		.asciiz "\nResultado: "

#SIGNOS
mas:		.asciiz " + "
menos:		.asciiz " - "
por:		.asciiz " x "

#ESPACIOS DE MEMORIA RESERVADOS PARA LOS STRINGS A UTILIZAR
numero1:		.space 51
numero2:		.space 51
resultado:	.space 55
resultado_mult:	.space 106

#SECCI�N DE C�DIGO MAIN
.text


#INICIALIZAR REGISTROS A USAR
li $t0, 0 	#OPCI�N SELECCIONADA DEL MEN� DE OPERACIONES
li $t1, 0		#PRIMER N�MERO
li $t2, 0		#SEGUNDO N�MERO
li $t3, 0		#RESULTADO
li $t4, 1		#SIGNO DEL PRIMER NUMERO	
li $t5, 1		#SIGNO DEL SEGUNDO NUMERO
li $t6, 0		#TAMA�O DEL PRIMER NUMERO 
li $t7, 0		#TAMA�O DEL SEGUNDO NUMERO 
li $t8, 0		#GUARDA CUAL ES EL N�MERO MAYOR

		
#MENSAJES DE INICIO DEL PROGRAMA
mensaje_string(titulo)		
mensaje_string(encabezado)		
mensaje_string(separador)		
mensaje_string(descripcion)		
mensaje_string(instrucciones)				
	
	
#LOOP DE INSERTAR OPCIONES DEL MEN� CON VALIDACI�N	
Insertar_Opciones:	


		mensaje_string(separador)
		mensaje_string(menu)		
		pedir_entero($t0)			#PEDIR OPCI�N DEL MEN�
		mensaje_string(separador)		
		
		ble $t0, 0, error			#SI EL NUMERO ES MENOR QUE 1 MENSAJE DE ERROR
		bgt $t0, 3, error			#SI EL NUMERO ES MAYOR A 3 MENSAJE DE ERROR
		b Insertar_Datos			#SI EL NUMERO EST� BIEN, PEDIR LOS DATOS
		
		
# SECCI�N DE C�DIGO DE MENSAJE DE ERROR			
error:			

	mensaje_string(opcion_invalida)	#MENSAJE DE ERROR
	b Insertar_Opciones			#VOLVER A PEDIR LA OPCI�N DEL MEN�


#SECCI�N DE CODIGO PARA INSERTAR LOS NUMEROS A OPERAR
Insertar_Datos:

	#LOOP DE INSERTAR EL PRIMER NUMERO CON VALIDACI�N
	Insertar_Num1:		
		mensaje_string(solicitud1)						#MENSAJE PEDIR PRIMER N�MERO
		pedir_string(numero1)						#GUARDAR NUMERO 1 EN MEMORIA
		validar_numero(numero1, $t4, Insertar_Num1, numero_invalido, $t1, $t6)	#VALIDAR EL NUMERO 1
			
	#LOOP DE INSERTAR EL SEGUNDO NUMERO CON VALIDACI�N
	Insertar_Num2:	
		mensaje_string(solicitud2)						#MENSAJE PEDIR EL SEGUNDO NUMERO
		pedir_string(numero2)						#GUARDAR EL NUMERO 2 EN MEMORIA
		validar_numero(numero2, $t5, Insertar_Num2, numero_invalido, $t2, $t7)	#VALIDAR EL NUMERO 2
		mensaje_string(separador)
	
#IMPRIMIR LOS DATOS DE LA OPERACION
imprimir_datos									
	
																			
#CONDICIONAL DE LOS CASOS DE OPERACIONES
casos:	
beq $t0, 1, suma			
beq $t0, 2, resta			
beq $t0, 3, multiplicacion		


#CASOS DE LA SUMA
suma:
	
		# SI ESTAMOS EN LA SUMA:
		#
		# 1) CALCULAR EL TAMA�O DE AMBOS NUMEROS
		# 2) IGUALAR EL TAMA�O DE AMBOS NUMEROS
		# 3) CALCULAR CUAL DE LOS DOS NUMEROS ES EL MAYOR
		# 4) CASOS:
		#
		#    - SI LOS DOS SON DEL MISMO SIGNO, ENTONCES ACTUA COMO SUMA:
		#	* SE HACE LA SUMA CON EL MAYOR ARRIBA
		#	* TOMA EL SIGNO DEL NUMERO MAYOR
		#
		#    - SI LOS DOS SON DE DISTINTO SIGNO, ENTONCES ACTUA COMO RESTA:
		#	* SE HACE LA RESTA CON EL MAYOR ARRIBA
		#	* TOMA EL SIGNO DEL NUMERO MAYOR
	
	calcular_mayor				
	igualar_tamano(numero1, numero2, $t6, $t7)	

	
	#SI LOS DOS NUMEROS SON DEL MISMO SIGNO
	beq $t4, $t5, hacer_suma
	#SI LOS DOS NUMEROS SON DE DISTINTO SIGNO
	bne $t4, $t5, hacer_suma_restada
	
	
	hacer_suma:
		sumar(numero1, numero2, resultado, $t6)
		beqz $t4, imprimir_menos_suma
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_suma:
				imprimir_resultado(menos, resultado, res)
				b final
	
	
	hacer_suma_restada:
	
		beqz $t8, num1_mayor_suma_restada
	
		#SI NUMERO 2 ES MAYOR
		restar(numero2, numero1, resultado, $t6)
		
		beqz $t5, imprimir_menos_suma_restada_num2
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_suma_restada_num2:
		
				imprimir_resultado(menos, resultado, res)
				b final
	
	
		num1_mayor_suma_restada:
		
		#SI NUMERO 1 ES MAYOR
		restar(numero1, numero2, resultado, $t6)
		
		beqz $t4, imprimir_menos_suma_restada_num1
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_suma_restada_num1:
				
				imprimir_resultado(menos, resultado, res)
				b final	

#CASOS DE LA RESTA
resta:

	# SI ESTAMOS EN LA RESTA:
	#
	# 1) CALCULAR EL TAMA�O DE AMBOS NUMEROS
	# 2) IGUALAR EL TAMA�O DE AMBOS NUMEROS
	# 3) CALCULAR CUAL DE LOS DOS NUMEROS ES EL MAYOR
	# 4) CASOS:
	#
	#    - SI LOS DOS SON DEL MISMO SIGNO, ENTONCES ACTUA COMO RESTA:
	#	* SE HACE LA RESTA CON EL MAYOR ARRIBA
	#	* TOMA EL SIGNO DEL NUMERO MAYOR
	#
	#    - SI LOS DOS SON DE DISTINTO SIGNO, ENTONCES ACTUA COMO SUMA:
	#	* SE HACE LA SUMA CON EL MAYOR ARRIBA
	#	* TOMA EL SIGNO DEL NUMERO MAYOR

	calcular_mayor
	igualar_tamano(numero1, numero2, $t6, $t7)
	
	
	#SI LOS DOS NUMEROS SON DEL MISMO SIGNO
	beq $t4, $t5, hacer_resta
	#SI LOS DOS NUMEROS SON DE DISTINTO SIGNO
	bne $t4, $t5, hacer_resta_sumada
	
	hacer_resta:
	
		beqz $t8, num1_mayor_resta
	
		#SI NUMERO 2 ES MAYOR
		restar(numero2, numero1, resultado, $t6)
		
		beqz $t5, imprimir_menos_resta_num2
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_resta_num2:
				
				imprimir_resultado(menos, resultado, res)
				b final
	
	
		num1_mayor_resta:
		
		#SI NUMERO 1 ES MAYOR
		restar(numero1, numero2, resultado, $t6)
		
		beqz $t4, imprimir_menos_resta_num1
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_resta_num1:
				
				imprimir_resultado(menos, resultado, res)
				b final	

	
	hacer_resta_sumada:
		sumar(numero1, numero2, resultado, $t6)
		
		beqz $t8, num1_mayor
		
		beqz $t5, imprimir_menos_resta_sumada_num2
		
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_resta_sumada_num2:
				
				imprimir_resultado(menos, resultado, res)
				b final
		
		num1_mayor:
		beqz $t4, imprimir_menos_resta_sumada_num1
		
				
				imprimir_resultado(mas, resultado, res)
				b final
		
		imprimir_menos_resta_sumada_num1:
				
				imprimir_resultado(menos, resultado,res)
				b final


#CASOS DE LA MULTIPLICACION
multiplicacion:

	# 1) SE CALCULA CUAL NUMERO ES MAYOR
	# 2) SE IGUALA EL TAMA�O DE LOS DOS N�MEROS
	# 3) SE MULTIPLICAN LOS DOS NUMEROS CON EL MAYOR ARRIBA
	# 4) SE IMPRIME EL SIGNO POR MULTIPLICACION DE SIGNOS
	
	calcular_mayor
	igualar_tamano(numero1, numero2, $t6, $t7)
	
	beqz $t8, num1_mayor_multiplicacion
	
		multiplicar(numero2, numero1, resultado_mult, $t7, $t6)
		b signo_m
	
	num1_mayor_multiplicacion:
	
		multiplicar(numero1, numero2, resultado_mult, $t6, $t7)
		b signo_m
	
	
	signo_m:
		bne $t4, $t5, menos_multi
		
			mensaje_string(res)
			mensaje_string(mas)
			b final_m
		
		menos_multi:
			
			mensaje_string(res)
			mensaje_string(menos)
			b final_m
			
	final_m:
		mensaje_string(resultado_mult)
		

#SALTO AL FINALIZAR LA OPERACI�N
final:
	mensaje_string(separador)
	mensaje_string(adios)
	fin 	#MACRO QUE FINALIZA EL PROGRAMA
