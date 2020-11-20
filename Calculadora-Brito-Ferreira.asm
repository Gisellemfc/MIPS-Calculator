#INCLUIR EL ARCHIVO DE LOS MACROS EN EL PROYECTO
.include "macros.asm"


#SECCIÓN DE DATOS EN MEMORIA
.data

#MENSAJES DE INICIO DEL PROGRAMA
titulo:		.asciiz "------------------------------------------------|    CALCULADORA BASICA    |------------------------------------------------\n\n"
encabezado:	.asciiz "      Este proyecto fue elaborado por Nicole Brito y Giselle Ferreira, estudiantes de la Universidad Metropolitana de\n      Caracas - Venezuela, en la asignatura de Organización del Computador, dictada por el profesor Rafael Matienzo.\n"	
descripcion:	.asciiz "\nDescripción: Este es un programa que realiza la suma, la resta y la multiplicación de números enteros largos. Dichos \nenteros no caben en registros, sino que se representan como cadenas de caracteres de hasta 50 caracteres, todos los \ncuales son caracteres ASCII numéricos, excepto el primero que es un signo (+ o -).\n\n"
instrucciones:	.asciiz "Instrucciones:\n1) Las operaciones se realizan con números de hasta 50 dígitos, incluyendo el signo. \n2) Los números que ingrese deben incluir obligatoriamente como primer dígito un signo (+) si el número es positivo o un \nsigno (-) si el número es negativo.\n3)Al introducir un dato erróneo, recibirá un mensaje de error y se le solicitarán los datos nuevamente.\n"
separador:	.asciiz "\n----------------------------------------------------------------------------------------------------------------------------\n"	

#MENSAJES DE ERROR
opcion_invalida:	.asciiz "\nOpción inválida... Inténtalo nuevamente"
numero_invalido:	.asciiz "\nNúmero inválido... Inténtalo nuevamente"

#MENÚ DE OPERACIONES
menu:		.asciiz "\nMenú: \n\n(1) Sumar \n(2) Restar \n(3) Multiplicar \n\nIngrese el número de la operación que desea realizar: "

#MENSAJES PARA PEDIR NUMEROS
solicitud1:	.asciiz "\nIngrese el primer número: "
solicitud2:	.asciiz "\nIngrese el segundo número: "

#MENSAJES DEL RESULTADO DE LAS OPERACIONES
res:		.asciiz "\nResultado: "
num1:		.asciiz "\nNúmero 1: "
num2:		.asciiz "\nNúmero 2: "

#SIGNOS
mas:		.asciiz " + "
menos:		.asciiz " - "
por:		.asciiz " x "
igual:		.asciiz " = "

#ESPACIOS DE MEMORIA RESERVADOS PARA LOS STRINGS A UTILIZAR
numero1:		.space 51
numero2:		.space 51
resultado:	.space 55
resultado_mult:	.space 105

#SECCIÓN DE CÓDIGO MAIN
.text


#INICIALIZAR REGISTROS A USAR
li $t0, 0 	#OPCIÓN SELECCIONADA DEL MENÚ DE OPERACIONES
li $t1, 0		#PRIMER NÚMERO
li $t2, 0		#SEGUNDO NÚMERO
li $t3, 0		#RESULTADO
li $t4, 1		#SIGNO DEL PRIMER NUMERO	
li $t5, 1		#SIGNO DEL SEGUNDO NUMERO
li $t6, 0		#TAMAÑO DEL PRIMER NUMERO 
li $t7, 0		#TAMAÑO DEL SEGUNDO NUMERO 
li $t8, 0		#GUARDA CUAL ES EL NÚMERO MAYOR

		
#MENSAJES DE INICIO DEL PROGRAMA
mensaje_string(titulo)		#TITULO DE LA CALCULADORA
mensaje_string(encabezado)		#ENCABEZADO DEL PROGRAMA
mensaje_string(separador)		#LÍNEA SEPARADORA	
mensaje_string(descripcion)		#DESCRIPCIÓN DEL PROGRAMA
mensaje_string(instrucciones)		#INSTRUCCIONES DEL PROGRAMA
mensaje_string(separador)		#LÍNEA SEPARADORA
	
	
#LOOP DE INSERTAR OPCIONES DEL MENÚ CON VALIDACIÓN	
Insertar_Opciones:	
		mensaje_string(menu)		#MENÚ DE OPCIONES
		pedir_entero($t0)			#PEDIR OPCIÓN DEL MENÚ
		mensaje_string(separador)		#LÍNEA SEPARADORA
		
		ble $t0, 0, error			#SI EL NUMERO ES MENOR QUE 1 MENSAJE DE ERROR
		bgt $t0, 3, error			#SI EL NUMERO ES MAYOR A 3 MENSAJE DE ERROR
		b Insertar_Datos			#SI EL NUMERO ESTÁ BIEN, PEDIR LOS DATOS
		
		
# SECCIÓN DE CÓDIGO DE MENSAJE DE ERROR			
error:			
		mensaje_string(opcion_invalida)	#MENSAJE DE ERROR
		mensaje_string(separador)		#LÍNEA SEPARADORA
		b Insertar_Opciones			#VOLVER A PEDIR LA OPCIÓN DEL MENÚ


#SECCIÓN DE CODIGO PARA INSERTAR LOS NUMEROS A OPERAR
Insertar_Datos:
	#LOOP DE INSERTAR EL PRIMER NUMERO CON VALIDACIÓN
	Insertar_Num1:		
		mensaje_string(solicitud1)						#MENSAJE PEDIR PRIMER NÚMERO
		pedir_string(numero1)						#GUARDAR NUMERO 1 EN MEMORIA
		validar_numero(numero1, $t4, Insertar_Num1, numero_invalido, $t1, $t6)	#VALIDAR EL NUMERO 1

	#LOOP DE INSERTAR EL SEGUNDO NUMERO CON VALIDACIÓN
	Insertar_Num2:	
		mensaje_string(solicitud2)						#MENSAJE PEDIR EL SEGUNDO NUMERO
		pedir_string(numero2)						#GUARDAR EL NUMERO 2 EN MEMORIA
		validar_numero(numero2, $t5, Insertar_Num2, numero_invalido, $t2, $t7)	#VALIDAR EL NUMERO 2
	
							
#CONDICIONAL DE LOS CASOS	
beq $t0, 1, suma			#IR AL CASO DE LA OPERACIÓN SUMA
beq $t0, 2, resta			#IR AL CASO DE LA OPERACION RESTA
beq $t0, 3, multiplicacion		#IR AL CASO DE LA OPERACIÓN MULTIPLICACIÓN


#CASOS DE LA SUMA
suma:
	
		# SI ESTAMOS EN LA SUMA:
		#
		# 1) CALCULAR EL TAMAÑO DE AMBOS NUMEROS
		# 2) IGUALAR EL TAMAÑO DE AMBOS NUMEROS
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
	
	calcular_mayor				#CALCULAMOS CÚAL NUMERO ES MAYOR
	igualar_tamano(numero1, numero2, $t6, $t7)	#IGUALAR LOS TAMAÑOS DE LOS NÚMEROS	

	
	#SI LOS DOS NUMEROS SON DEL MISMO SIGNO
	beq $t4, $t5, hacer_suma
	#SI LOS DOS NUMEROS SON DE DISTINTO SIGNO
	bne $t4, $t5, hacer_suma_restada
	
	hacer_suma:
		sumar(numero1, numero2, resultado, $t6)
		beqz $t4, imprimir_menos_suma
		
				mensaje_string(mas)
				mensaje_string(resultado)
				b final
		
		imprimir_menos_suma:
				mensaje_string(menos)
				mensaje_string(resultado)
				b final
	
	
	hacer_suma_restada:
	
	b final


#CASOS DE LA RESTA
resta:

	# SI ESTAMOS EN LA RESTA:
	#
	# 1) CALCULAR EL TAMAÑO DE AMBOS NUMEROS
	# 2) IGUALAR EL TAMAÑO DE AMBOS NUMEROS
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
	
		#NUMERO 2 ES MAYOR
		restar(numero2, numero1, resultado, $t6)
		
		beqz $t5, imprimir_menos_resta_num2
		
				mensaje_string(mas)
				mensaje_string(resultado)
				b final
		
		imprimir_menos_resta_num2:
				mensaje_string(menos)
				mensaje_string(resultado)
				b final
	
	
		num1_mayor_resta:
		
		#NUMERO 1 ES MAYOR
		restar(numero1, numero2, resultado, $t6)
		
		beqz $t4, imprimir_menos_resta_num1
		
				mensaje_string(mas)
				mensaje_string(resultado)
				b final
		
		imprimir_menos_resta_num1:
				mensaje_string(menos)
				mensaje_string(resultado)
				b final	

	
	hacer_resta_sumada:
		sumar(numero1, numero2, resultado, $t6)
		
		beqz $t8, num1_mayor
		
		beqz $t5, imprimir_menos_resta_sumada_num2
		
				mensaje_string(mas)
				mensaje_string(resultado)
				b final
		
		imprimir_menos_resta_sumada_num2:
				mensaje_string(menos)
				mensaje_string(resultado)
				b final
		
		num1_mayor:
		beqz $t4, imprimir_menos_resta_sumada_num1
		
				mensaje_string(mas)
				mensaje_string(resultado)
				b final
		
		imprimir_menos_resta_sumada_num1:
				mensaje_string(menos)
				mensaje_string(resultado)
				b final


#CASOS DE LA MULTIPLICACION
multiplicacion:


#SALTO AL FINALIZAR LA OPERACIÓN
final:
		
	fin 	#MACRO QUE FINALIZA EL PROGRAMA
