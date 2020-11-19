.include "macros.asm"
.data
#SECCIÓN DE DATOS EN MEMORIA

entrada:	.asciiz "-------------------------------------------------|    CALCULADORA BASICA    |-------------------------------------------------\n     Este programa fue elaborado por( Samuel Boada y Marcos De Andrade ), estudiantes de la Universidad Metropolitana de\n     Caracas Venezuela, en la asignatura de Organización del Computador, dictada por el profesor Rafael Matienzo con la\n     ayuda del preparador Gabriele Lafigliola. \n\n"	
descripcion:	.asciiz "Descripcion: El siguiente programa es una calculadora capaz de realizar 3 operaciones basicas, suma, resta y mutiplicación.\nPuede operar hasta 50 digitos en cuanto a la suma y resta, y hasta 25 digitos en cuanto a la multiplicación.               \nSiga todas las instrucciones para el correcto funcionamiento en cuanto al calculo de que desee operar.\n-----------------------------------------------------------------------------------------------------------------------------\n"	

saludo:		.asciiz "\nIngrese el primer numero \n"
saludo2:		.asciiz "\nIngrese el segundo numero \n"
salto:		.asciiz "\n"

res:		.asciiz "\nResultado: "
num1:		.asciiz "\n     Num1: "
num2:		.asciiz "\n     Num2: "

mas:		.asciiz " + "
menos:		.asciiz " - "
por:		.asciiz " x "
igual:		.asciiz " = "

menu:		.asciiz "\n (1) Sumar            (Máximo 50 dígitos por Número - Incluyendo Decimales)\n (2) Restar           (Máximo 50 dígitos por Número - Incluyendo Decimales)\n (3) Multiplicar      (Máximo 25 dígitos por Número - Incluyendo Decimales) \n"
opcion_invalida:	.asciiz "\nOpción Inválida... No sabes escribir?!"
numero_invalido:		.asciiz "\nNumero inválido, intenta con otro."

numero1:		.space 50
numero2:		.space 50
resultado:	.space 55

.text
#SECCIÓN DE CÓDIGO MAIN

	li $t0, 0 	#OPCIÓN SELECCIONADA DEL MENÚ DE OPERACIONES
	li $t1, 0		#PRIMER NÚMERO
	li $t2, 0		#SEGUNDO NÚMERO
	li $t3, 0		#RESULTADO
	li $t4, 1		#SIGNO DEL PRIMER NUMERO	
	li $t5, 1		#SIGNO DEL SEGUNDO NUMERO
	
		mensaje_string(entrada)		#MENSAJE DE BIENVENIDA	
		mensaje_string(descripcion)		#DESCRIPCIÓN DEL PROGRAMA
	
#LOOP DE INSERTAR OPCIONES DEL MENÚ (POR SI INSERTA UNA OPCIÓN INVÁLIDA)	
Insertar_Opciones:	
		mensaje_string(menu)		#MENÚ DE OPCIONES
		
		pedir_entero($t0)			#PEDIR OPCIÓN DEL MENÚ
			
		ble $t0, 0, error			#SI EL NUMERO ES MENOR QUE 1 MENSAJE DE ERROR
		bgt $t0, 3, error			#SI EL NUMERO ES MAYOR A 3 MENSAJE DE ERROR
		b Insertar_Datos			#SI EL NUMERO ESTÁ BIEN, PEDIR LOS DATOS
		
# SECCIÓN DE CÓDIGO DE MENSAJE DE ERROR			
error:			
		mensaje_string(opcion_invalida)	#MENSAJE DE ERROR
		b Insertar_Opciones			#VOLVER A PEDIR LA OPCIÓN DEL MENÚ


Insertar_Datos:
		#LOOP DE INSERTAR EL PRIMER NUMERO CON VALIDACIÓN
		Insertar_Num1:		
				mensaje_string(saludo)	#MENSAJE DE PEDIR PRIMER NÚMERO
				pedir_string(numero1)	#GUARDAR NUMERO 1 EN MEMORIA
				validar_numero(numero1, $t4, Insertar_Num1, numero_invalido, $t1)	#VALIDAR EL NUMERO
	
		#LOOP DE INSERTAR EL SEGUNDO NUMERO CON VALIDACIÓN
		Insertar_Num2:	
				mensaje_string(saludo2)
				pedir_string(numero2)
				validar_numero(numero2, $t5, Insertar_Num2, numero_invalido, $t2)
				
		
	fin 	#MACRO QUE FINALIZA EL PROGRAMA
