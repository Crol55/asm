include macros.asm

 ;nodo struc 
 ;   val db ?
 ;   conta db ?
 ;nodo ends

    nodo struc 
       val dw ?
       conta dw ?
    nodo ends

.model small 


.stack 

.data 
    cadena db "Hola soy yo denuevo",'$'
    salto  db 10,'$'
    f      db "funciona",10,'$'
    e      db "NO funciona",10,'$'
    strNumero        db 7 dup ('$') ;Para castear int a string
    ; Variables para consola de comandos 
    varStrConsola db "consolap2> ",'$'
    varBufferEntrada db 30, 0 , 30 dup('$') ; 29 caracteres  + 1 \cret 
    varComando1      db "cprom"
    varComando2      db "abrir_"
    varComando3      db "cmediana"
    varComando4      db "cmoda"
    varComando5      db "salir"
    varComando6      db "cmax"
    varComando7      db "cmin"
    varComando8      db "limpiar"
    varComando9      db "info"
    varComando10      db "reporte"
    varResultado     db 0   ; resultado de la comparacion de strings default 0
    ; Variables para fichero/archivos
    handlerLF        dw 0
    buffer           db 3000 dup('$')
    lexema db 30 dup('$')
    token  db 0
    
    ; Variables para mensajes de sistema
    errorFichero   db 10,"Error al abrir el fichero/archivo o NO existe",10,'$'
    errLectura     db "Error al realizar la lectura del fichero",10,'$'
    errCierre      db 10,"Error al realizar la lectura del fichero",10,'$'
    varErrorExtension db "La extension ingresada no es correcta (.xml)",10,'$'
    ; variables para funciones
    resultado dw 0 ; Utilizada en Stoi
    res       dw 1 ; utilizada en stoi -> para poder realizar las potencias de 10
    ;contador  db 0 ; Utilizada en Stoi -> creo que se eliminara

    ; VARIABLES UTILIZADAS EN ANALISIS DE ENTRADA DE NUMEROS
    arrNumeros     dw 1000 dup(0);25,25,41,25,15,19,78,80,9,3,10,65,76 ;dup(0)
    arr            dw 20 dup(0); Para colocar el arreglo como al inicio 
    contaNumeros   dw 0;13 ; Saber cuantos numeros hay en arrNumeros
    maxVal         dw 0;80 ; Cual de los numeros de arrNumeros es el mayor
    minVal         dw 0    ; Cual de los numeros de arrNumeros es el menor
    ; VARIABLES PARA CPROM 
    entero dw 0
    decimal dw 0
    ;variables para Cmediana
    conta          db 0
    varTemp        dw 0
    ; VARIABLES PARA MODA 
    hash nodo 75 dup({-1, -1}) ; 75 * 4 bytes = 300 bytes apartados, -1 = null('para mi')
    valModa        dw 0
    valConta       dw 0
    datos_quemados dw 10,10,10,15,5,5,5,1,1,1,10,5,5,9,7
    ; VARIABLES PARA INFO
    varInfo db 'ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1',10,'SECCION A',10
            db 'PRIMER SEMESTRE 2021',10,'CARLOS RENE ORANTES LARA',10,'201314172',10
            db 'Proyecto 2 Assembler',10,'$'    
  
.code 
main proc 
    mov ax, @data 
    mov ds, ax 

    ;lea si, prueba
    ;;mov (nodo ptr [bx]).val , 'A'
    ;mov bx, (nodo ptr [si]).conta
    ;mov ax, (nodo ptr [si]).val
    ;printChar bl
    ;mov pp, ax 
    ;mov prueba2
    ;printChar pp.val


    ; Ejecutar de manera continua el modo lectura de comandos
    consola: 
        print varStrConsola
        ;leer teclado 
        readCadenaTeclado varBufferEntrada 
        print salto
        cprom:
            compararStrings varBufferEntrada+2, varComando1, varBufferEntrada + 1, varResultado
            cmp varResultado, 1 
            jne abrir_
                ;printChar 'P'
                CALL ejecutar_cprom
                jmp ret_consola
                
        abrir_:  
            compararStrings varBufferEntrada+2, varComando2, 6, varResultado
            cmp varResultado, 1 
            jne cmediana
                CALL leer_archivo
                cmp handlerLF,0 
                je finAbrir_
                    caLL analizar_texto

                finAbrir_:
                jmp ret_consola
        cmediana: 
            compararStrings varBufferEntrada+2, varComando3, varBufferEntrada + 1, varResultado ; Cmediana
            cmp varResultado, 1 
            jne cmoda
                ;printChar 'M'
                CALL ejecutar_cmediana
                jmp ret_consola
        cmoda: 
            compararStrings varBufferEntrada+2, varComando4, varBufferEntrada + 1, varResultado; Cmoda
            cmp varResultado, 1 
            jne cmax
                CALL ejecutar_cmoda
                jmp ret_consola
        cmax: 
            compararStrings varBufferEntrada+2, varComando6, varBufferEntrada + 1, varResultado; Cmax
            cmp varResultado, 1 
            jne cmin
                limpiarVariable strNumero, sizeof strNumero
                itos maxVal, strNumero
                print varStrConsola
                print strNumero
                print salto
                jmp ret_consola
        cmin: 
            compararStrings varBufferEntrada+2, varComando7, varBufferEntrada + 1, varResultado; Cmin
            cmp varResultado, 1 
            jne limpiar
                limpiarVariable strNumero, sizeof strNumero
                itos minVal, strNumero
                print varStrConsola
                print strNumero
                print salto
                jmp ret_consola 
        limpiar: 
            compararStrings varBufferEntrada+2, varComando8, varBufferEntrada + 1, varResultado   ;limpiar
            cmp varResultado, 1 
            jne info
                printChar 'L'
                cls
                jmp ret_consola
        info: 
            compararStrings varBufferEntrada+2, varComando9, varBufferEntrada + 1, varResultado   ;limpiar
            cmp varResultado, 1 
            jne reporte
                print varStrConsola
                print varInfo
                jmp ret_consola
        reporte: 
            compararStrings varBufferEntrada+2, varComando10, varBufferEntrada + 1, varResultado   ;limpiar
            cmp varResultado, 1 
            jne csalir
                printChar 'R'
                
                jmp ret_consola     
        csalir: 
            compararStrings varBufferEntrada+2, varComando5, varBufferEntrada + 1, varResultado ; salir
            cmp varResultado, 1 
            jne ret_consola
                jmp FIN
        ret_consola:
        jmp consola ; salta a consola hasta que el comando le dice que termine la ejecucion


    FIN:
    mov Ah,4Ch
    int 21h
main endp


leer_archivo proc 

    ; leer el fichero -> el nombre estara en varBufferEntrada + 8
    ; Verificar que la extension del archivo sea .xml
    xor bx,bx
    mov bl, varBufferEntrada + 1 ; En la pos 1, se encuentra la longitud del string
    lea si, varBufferEntrada + 1
    add si, bx ; -> nos colocamos al final de la cadena

    mov bl, [si] 
    cmp bl, 'l'
    jne errorExtension
    mov bl,[si-1]
    cmp bl, 'm' 
    jne errorExtension
    mov bl,[si-2]
    cmp bl, 'x' 
    jne errorExtension
    mov bl,[si-3]
    cmp bl, '.' 
    jne errorExtension
    ; extension del archivo es correcta
        mov bl, 0
        mov [si +1 ], bl ; -> colocar 0 al final de la cadena, sino nunca abrira el archivo
        limpiarVariable buffer, SIZEOF buffer
        abrirFichero varBufferEntrada +8, handlerLF
        leerFichero handlerLF, buffer, SIZEOF buffer
        ;print buffer
        cerrarFichero handlerLF
        JC errorCF

        jmp finLA

        errorAF: 
            print errorFichero
            jmp finLA
        errorLF:
            print errLectura
            jmp finLA
        errorCF:
            print errCierre
            jmp finLA
    errorExtension:
        print varErrorExtension
    finLA:
    ret 
leer_archivo endp 



stoi proc ; Idealmente se utilizara "lexema" para esta funcion
    ; Guardar variables para no perder su valor
    push cx  
    push si 
    push bx 
    push dx
    ;Obtener el size del numero el (1 o 2)
    mov cx,0 ; para almacenar el size del numero
    mov si,0 ; para iterar adentro de lexema
    mov bx,0

    iterarL1:
        cmp lexema[si], '$' ; Ya termino de contar el tamaño de la cadena de digitos
        je salirL1
            inc cx 
            inc si 
        jmp iterarL1
    salirL1:
    ; Al finalizar, CX tendra el tamaño del numero -> para poder iterar de atras hacia adelante
    ;convertir el string de numeros a integer
    mov dx, 0
    mov bl,0 ; funcionara como el exponente 10^exp
    forL1:
        mov si, cx 
        dec si     ; porque el indice inicia en +0
        push bx ; preservar el valor de bl 
        get_potencia 10, bl, res  ; devuelve potencias de 10 dependiendo de cx y bl
        pop bx    

        mov dl,lexema[si]
        SUB dl,48 ; ah = ah - 48 // convierte el char a digito 
        ; multiplicar dl * 10 ^exp
        mov ax, res
        MUL dx ; MUL multiplica lo del registro al con el operador siguiente de la instruccion MUL -> ej (10 * ah)
        ;mov dl, al ; El resultado de la multiplicacion se coloca en dx
        ADD resultado, AX
        inc bl 
    loop forL1 ; decrementa cx

    pop dx
    pop bx
    pop si 
    pop cx
ret
stoi endp


analizar_texto proc
    ; Lo unico que nos interesa es extraer los (int) de archivo leido
    mov si,0 
    mov di,0 
    ; reiniciar variables
    mov maxVal, 0
    mov minVal, 0ffffh
    mov contaNumeros,0

    forAT: ; Iterar hasta que encuentre '$'
        ; ingresa al analizador lexico si y solo si, es diferente de '$'
        cmp buffer[si],'$'
        je L1
        analizadorLexico buffer,lexema, token 
        
        cmp token, 10 ; token = 10 -> SON digitos(integer)
        jne salite 
            print salto
            print lexema
            CALL stoi ; convertir string -> integer, Lo almacenara en la variable 'resultado'
            mov ax, resultado
            ;cmp ax, 10038
            ;jne contt 
            ;    print f
            ;contt:
            mov arrNumeros[di], ax
            mov arr[di],ax ; Copia de los numeros ingresados
            add di, 2
            ; contar cuantos numeros hay
            inc contaNumeros 
            ;Determinar cual es el valor mas grande de los numeros ingresados
            cmp ax, maxVal
            jb getMinimo
                mov maxVal, ax
            getMinimo: 
            cmp ax, minVal  
            JNB salite  ; continuar
                mov minVal,ax 
        salite:
        ;limpiar variables
        limpiarVariable lexema, SIZEOF lexema
        mov token,0
        mov resultado,0
    jmp forAT 
    L1:
    ret 
analizar_texto endp


ejecutar_cprom proc 

    mov si,0
    mov cx, contaNumeros 
    mov dx,0 ; almacenara el resultado de la suma
    mov res, 0 ; Almacenara el resultado de la suma de todos los numeros ingresado
    loopear:
        ;print f
        mov ax,si
        mov bx,2 
        mul bx ; resultado en AX 
        mov bx,ax 
        
        mov ax ,arrNumeros[bx]
        add res,ax
        
        inc si
    loop loopear
    
    ;itos res, strNumero
    ;print strNumero
    print salto
    print varStrConsola
    division_decimal res,contaNumeros
    limpiarVariable strNumero, sizeof strNumero
    itos entero, strNumero
    print strNumero
    printChar '.'
    limpiarVariable strNumero, sizeof strNumero
    itos decimal, strNumero
    print strNumero
    print salto

 ret 
ejecutar_cprom endp


ejecutar_cmediana proc 
    
    ;Ordenar los numeros
    CALL void_bubbleSort
    ;mov ax, arrNumeros
    ;mov bx, 0 
    ;mov cx, contaNumeros
    ;lupear: 
    ;    limpiarVariable strNumero, sizeof strNumero
    ;    itos arrNumeros[bx], strNumero
    ;    print strNumero
    ;    print salto
    ;    add bx,2 
    ;loop lupear
    
    ;ejecutar DIV para saber de donde sacar la mediana
    xor dx,dx 
    mov ax, contaNumeros
    mov bx, 2 
    div bx ; -> cociente en ax, residuo en dx 

    ;SUB ax, 1 ; Si es par o impar en ambos casos incrementamos el cociente, ya que los indices inician en '0'

    cmp dx,0 ; Si es =0 es par, sino es impar
    jne impar 
    par: 
        ;ax contiene la mitad de contaNumeros -> (contaNumeros/2) - 1
        ;bx contiene 2
        xor dx,dx 
        mul bx ; ((contaNumeros/2) ) *2 obtenemos la posicion en el arreglo tipo word

        mov bx, ax ; 
        mov ax, arrNumeros[bx] 
        sub bx,2
        add ax, arrNumeros[bx]
        mov varTemp, ax 
        ; posible division decimal
        ;print salto
        print varStrConsola
        division_decimal varTemp,2 ; modifica variable entero y decimal
        limpiarVariable strNumero, sizeof strNumero
        itos entero, strNumero
        print strNumero
        printChar '.'
        limpiarVariable strNumero, sizeof strNumero
        itos decimal, strNumero
        print strNumero
        print salto
        
        jmp fin_mediana
    impar: 
        ;ax contiene la mitad de contaNumeros -> (contaNumeros/2) - 1
        ;bx contiene 2
        xor dx,dx 
        mul bx ; ((contaNumeros/2)) *2 obtenemos la posicion en el arreglo tipo word

        mov bx, ax ; 
        limpiarVariable strNumero, sizeof strNumero
        itos arrNumeros[bx], strNumero
        print salto
        print varStrConsola
        print strNumero
        print salto
    fin_mediana: 
    
 ret 
ejecutar_cmediana endp


void_bubbleSort proc 

    ; arrNumeros.length - 1  
     mov ax, contaNumeros 
     mov ch, al
     dec ch 

    a1:
    mov cl, ch
    lea si, arrNumeros
    mov conta, 0
    
    rept1:
    mov ax, [si]
    add si,2
    cmp ax, [si]
    jbe next1
    xchg ax, [si]
    mov [si-2], ax
    ;push cx
        mov al, conta 
        cbw ; -> Ah
        ;mov di, ax 
        ;borrar_rectangulo di,anchoRectangulo;***************************
        ;add ax,2 
        ;mov di, ax 
        ;borrar_rectangulo di,anchoRectangulo;***************************
        ;Delay constDelay
        ;CALL GRAFICAR_NUMEROS
        ;Delay constDelay
    ;pop cx
    next1:
    add conta,2
    dec cl
    jnz rept1
    dec ch
    jnz a1

 ret 
void_bubbleSort endp 


ejecutar_cmoda proc 
    ; Ordenar los valores
    ;CALL void_bubbleSort
    ; limpiar las variables implicadas 
    lea di, datos_quemados
    mov cx, 15          ; Tamaño de entrada de datos

    lup: 
        lea si, hash        ;si apunta al inicio del arreglo de hash
        ; buscar adentro de hash para verificar si ya se inserto el valor
        iterar: ; iterar hasta que el valor exista o el valor este null "-1"
            
            ; if(nodo.val == -1) -> llego al final "implica que el valor no existe"
            mov ax, (nodo ptr[si]).val 
            cmp ax, -1 
            jne noNull 
                ; Si no existe insertar un nuevo registro en esa posicion
                    mov ax, [di]                    ;dato que se esta analizando
                    mov (nodo ptr [si]).val , ax
                    mov (nodo ptr [si]).conta , 1 
                    ;printChar 'N'
                    ;printChar 'N'
                    ;printChar 'N'
                    ;printChar 'N'
                jmp continuar ; se sale del ciclo
            noNull:
                ;if (nodo.val == dato) -> Si es igual incrementar el contador
                cmp ax, [di] 
                jne L1  
                    mov ax, (nodo ptr [si]).conta ; Como ya existe solo incrementamos su contador
                    add ax,1 
                    mov (nodo ptr [si]).conta , ax 
                jmp continuar  
            L1: 
            ; si llega al final, implica que no ha encontrado null ni valor igual
            add si, 4 ; Es el tamaño en bytes del struc "nodo"
        jmp iterar

        continuar: 
        add di,2        ;mover de posicion en los datos tipo "word" -> datos ingresados por el usuario

    loop lup  

    ; Luego de ordenarlo, buscar cual es el que mas veces se repite

    lea si, hash ; nos colocamos nuevamente al inicio del hash
    buscarModa: 
        ; if (nodo =! '-1') -> continuar ejecucion
        mov ax, (nodo ptr[si]).val
        cmp ax, -1
        JE finModa
        mov ax, (nodo ptr[si]).conta
        cmp ax, valConta
        ; if(ax > valConta)
        JNA noCambiar 
            ;intercambiar moda
            mov ax, (nodo ptr[si]).conta
            mov valConta, ax 
            mov ax, (nodo ptr[si]).val
            mov valModa, ax
        noCambiar:
        add si,4 ; 
    jmp buscarModa 
    finModa:
    mov bx, valModa
    add bl, 39
    printChar bl
    ; verficar si todo esta bien
    ;lea bx, hash
    ;;mov (nodo ptr [bx]).val , 'A'
    ;;mov bx, (nodo ptr [si]).conta
    ;mov ax, (nodo ptr [bx]).conta
    ;add al, 39
    ;printChar al

 ret 
ejecutar_cmoda endp 

end main

