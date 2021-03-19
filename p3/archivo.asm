include macros.asm

.model small


.stack 100h
;xchg, loop (cx), neg, inc dec, movsb (di,si), rep (cx), loop (cx)


.data
    mensaje db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA",10,"FACULTAD DE INGENIERIA",10
    mensaje2 db "ESCUELA DE CIENCIAS Y SISTEMAS",10,"ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1 A",10
    mensaje3 db "SECCION B",10,"PRIMER SEMESTRE 2021",10
    mensaje4 db "CARLOS RENE ORANTES LARA",10,"201314172",10,"Primera Practica Assembler",10,"$"
    menu  db 10,"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10
    menu1 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MENU PRINCIPAL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10
    menu2 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10
    menu3 db "%% 1. Cargar Archivo                                                         %%",10
    menu4 db "%% 2. Modo Calculadora                                                       %%",10
    menu5 db "%% 3.Factorial                                                               %%",10
    menu6 db "%% 4. Crear Reporte                                                          %%",10
    menu7 db "%% 5. Salir                                                                  %%",10
    menu8 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10,"$"
    salto db 10,'$'
    ; Usadas en cargar archivo
    funciono db "si funciono",10,"$"
    nombreArchivo db 30 dup('$') ; Para que pueda leer el nombre del archivo debe terminar en null : 0 
    errorExtension db "La extension ingresada no es correcta (.arq)",'$'
    msgIngresoArchivo db 10,"Ingrese la ruta del archivo:",'$'
    errorFichero db 10,"Error al abrir el fichero/archivo o NO existe",'$'
    errLectura db 10,"Error al realizar la lectura del fichero",'$'
    errCierre db 10,"Error al realizar la lectura del fichero",'$'
    handlerCA dw 0
    buffer db 5000 dup('$')
    ; Usadas en MODO CALCULADORA
    buffNum db 4,0,0,0,0,0   ; Almacenara numeros ej (99,-10,5)
    buffOperador db 2,0,0,0 ; Almacenara operador (+,-,/,*,;)
    msgModoCalc  db 10,"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10
    msgModoCalc2 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MODO CALCULADORA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10
    msgModoCalc3 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",10,'$'
    msgNum       db "%% Ingrese un Numero                                                         %%",10,'$'
    msgoperador  db 10,"%% Ingrese un Operador                                                       %%",10,'$'
    msgFinOper   db "%% Ingrese un operador o ';' para finalizar                                  %%",10,'$'
    msgOpen      db "%% ",'$'
    msgClose     db "                                                                             %%",10,'$'
    contador  db 0
    resultado db 0
    operador  db 0; almacenara el char -> +,-,*,/
    operando1      dw 0,'?','$' ; Aqui se almacenara el resultado final de las operaciones aritmeticas
    operando2      dw 0 
    locura db 10,"QUE?",'$'
.code

main proc
    mov AX,@data 
    mov ds,AX 

 ;************************ IMPRIMIR CABECERA *****************
     print mensaje
     displayMenu:
        print menu

        
   
 ;*********************** Leer teclado ***************
    readKeyboard ; Lee teclado, el resultado lo almacena en Al
    cmp Al,'1'
    JE cargarArchivo 
    cmp Al, '2'
    JE modoCalculadora
    cmp al, '3'
    JE modoFactorial
    cmp al,'4'
    JE crearReporte
    cmp al,'5'
    JE FIN
    JMP displayMenu 
 ;************** CARGAR ARCHIVO *************
    cargarArchivo:
    CALL cargar_archivo
    CALL operar_etiquetas
    print buffer 
    JMP displayMenu

 ;************** MODO CALCULADORA *************
    modoCalculadora:
        CALL modo_calculadora

 ;************** MODO FACTORIAL *************
    modoFactorial:

 ;************** CREAR REPORTE *************
    crearReporte:


 ;********************** SALIR ***************
    FIN:
    mov Ah,4Ch
    int 21h
main endp 



modo_calculadora proc
    print salto
    print msgModoCalc
    print msgNum
    print msgOpen
    readCadenaTeclado buffNum ; leer entrada de digito 
        CALL stoi   ; castear string to integer, el resultado se almacena en "resultado"
        xor AX,AX  
        mov ah, resultado ; Insertar resultado (8-bits) a una variable de 16 bits (AX)
        mov operando1, AX
        cmp operando1, -10
        jne seguir 
            print locura
    seguir:print operando1
    print msgOpen
    print msgOperador
        readKeyboard; operador estara en AL
        mov operador, Al 
    print salto
    print msgNum
    print msgOpen
    readCadenaTeclado buffNum ; leer entrada de digito 
        CALL stoi
        xor AX,AX
        mov al, resultado
        mov operando2, AX
        ejecutarOperacionAritmetica operando1, operando2, operador
        
print salto
    cmp operando1, -5
    jne mierda
        print funciono
    mierda:
ret
modo_calculadora endp
    
cargar_archivo proc 

    ;Leer la entrada del usuario
    iniCA:
    print msgIngresoArchivo
    mov si, 0 
    mov bx,0 ; Almacenar la pos de Si donde se encuentra el punto
    lee: 
        readKeyboard ; resultado de lectura almacenado en AL
        mov nombreArchivo[si], Al
        CMP al,'.'
            JE posPunto ;almacenar unicamente donde esta el (.)
            JMP PPCA
            posPunto:
                mov bx,si ; bx contiene donde se encuentra el .
        ppCA:
        INC si
        CMP al,13 ; if (al != 'cret')
            JNE lee ; leer hasta encontrar salto de linea (enter)
    DEC si 
    mov nombreArchivo[si], 0 ; Eliminar de la cadena el ultimo enter ( y settear null)
    ; Verificar que el nombre del archivo tenga la extension correcta (.ARQ), apartir de donde esta el punto
    
    CMP nombreArchivo[bx+1],'a'
    jne errorCA
    CMP nombreArchivo[bx+2],'r'
    jne errorCA
    CMP nombreArchivo[bx+3],'q'
    jne errorCA
        ; --> La extension del archivo es la correcta
        ; ****** Abrir el fichero/archivo **********
        abrirFichero nombreArchivo, handlerCA
        leerFichero handlerCA,buffer,SIZEOF buffer
        cerrarFichero handlerCA
    salirAF:
        jmp salirCA
    errorCA: 
        print errorExtension
        JMP iniCA
    errorAF:
        print errorFichero
        jmp iniCA
    errorLF:
        print errLectura
        jmp salirCA
    errorCF:
        print errCierre
    salirCA:
ret
cargar_archivo endp


stoi proc ; Convierte "-10"(string) a -10 (integer)
    mov AX,0
    mov al, buffNum+1 ; tamaño de la entrada
    ;printChar buffNum+1
    mov CX, AX; cx = tamaño de cadena leida ( loop -> CX)
    mov BX,CX ; para poder acceder a los numeros
    INC BX ; La cadena esta siempre en size+1 (cx + 1)
    mov resultado, 0 ; limpiamos donde se almacenara el resultado final 
    mov contador,0
    forMD:
        ; if ( contador) == 0  // Estariamos en la ultima posicion del string 
        CMP contador,0
        jne L1MD
            ;printChar buffNum[BX]
            mov ah, buffNum[BX]
            SUB ah,48 ; ah = ah - 48 // convierte el char a digito 
            ADD resultado, ah ; Siempre sera 0 = 0 + ah
        L1MD:
        ;else if (contador == 1) // Estariamos en el ultimo digito posible (19) -> estariamos en el 1
        CMP contador,1
        jne L2MD
            ;printChar buffNum[BX]
            mov ah,buffNum[BX]
            SUB ah,48 ; ah = ah - 48 // convierte el char a digito 
            mov al, 10
            MUL ah ; MUL multiplica lo del registro al con el operador siguiente de la instruccion MUL -> ej (10 * ah)
            ADD resultado, al
        L2MD:
        ;else if (contador == 2) // Estariamos en el signo del digito (- o +) 
        CMP contador,2
        jne L3MD
            ;printChar buffNum[BX]
            CMP buffNum[BX],'-' ; if(es numero negativo)
            jne L3MD
                NEG resultado ; Convertimos el resultado a negativo
        L3MD:
        DEC BX ; Moverse al caracter anterior
        INC contador
    loop forMD ; Utiliza por defecto cx para iterar
ret
stoi endp
    

operar_etiquetas proc 
ret
operar_etiquetas endp


end main

