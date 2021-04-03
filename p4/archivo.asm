include macros.asm

.model small

.stack


.data
    encabezado   db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA",10,"FACULTAD DE INGENIERIA",10
    encabezado1  db "ESCUELA DE CIENCIAS Y SISTEMAS",10,"ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1 A",10
    encabezado2  db "SECCION A",10,"PRIMER SEMESTRE 2021",10
    encabezado3  db "CARLOS RENE ORANTES LARA",10,"201314172",10,"PRACTICA 4",10,"$"
    strMenu      db "MENU PRINCIPAL",10,"1) Cargar Archivo",10,"2) Ordenar",10,"3) Generar Reporte",10,"4) Salir",10,'$'
    strSeleccion db "Ingrese el # de operacion que desea realizar:$"
    salto        db 10,'$'

    strIngresoArchivo db 10,"Ingrese la ruta del archivo:",'$'
    nombreArchivo db 30 dup('$') ; Para que pueda leer el nombre del archivo debe terminar en null : 0 
    errorExtension db "La extension ingresada no es correcta (.xml)",'$'
    errorFichero db 10,"Error al abrir el fichero/archivo o NO existe",'$'
    errLectura db 10,"Error al realizar la lectura del fichero",'$'
    errCierre db 10,"Error al realizar la lectura del fichero",'$'
    buffer db 1500 dup('$')

    handlerCA    dw 0
    cadena db "52",'$'
    cadena2 db "33", '$'

    lexema db 30 dup('$')
    token db 0

    arrNumeros     dw 25,25,41,25,15,19,78,80,9,3 ;dup(0)
    contaNumeros   dw 10
    maxVal         dw 80 ; Cual de los numeros de arrNumeros es el mayor
    finRect        dw 25 ; (fila) Altura maxima del rectangulo

    varPosCursor     db 0
    varExcede        db 0 ; Flag para saber si el ancho de los rectangulos es < 20 
    varDesproporcion dw 0 ; Cambia de valor si la altura del rectangulo estara desproporcionada
    strNumero        db 7 dup ('$') ;Para castear int a string
    colorcito dw 10

    anchoRectangulo dw 0
    resultado dw 0 ; Utilizada en Stoi
    contador  db 0 ; Utilizada en Stoi

    izq dw 0
    der dw 0

    fun db "entro",10,'$'
.code 

main proc
    mov ax, @data 
    mov ds, ax 
    
 ; %%%%%%%%%%%%%% Imprimir el encabezado %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    print encabezado
    displayMenu:
        print salto
        print strMenu
        print strSeleccion
 ; %%%%%%%%%%%%%% LEER Teclado %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    readKeyboard
    print salto
    cmp Al,'1'
    JE cargarArchivo 
    cmp Al, '2'
    JE ordenar
    cmp al, '3'
    JE crearReporte
    cmp al,'4'
    JE FIN
    JMP displayMenu 

    cargarArchivo:
        CALL CARGAR_ARCHIVO ; Los bytes de cargan a buffer
        mov si,0
        mov di,0 ; para insertar los digitos ingresados por el usuario
        forCA: ; Iterar hasta que encuentre '$'
            ; ingresa al analizador lexico si y solo si, es diferente de '$'
            cmp buffer[si],'$'
            je L1
            analizadorLexico buffer,lexema, token 
            
            cmp token, 10
            jne salite 
                print salto
                print lexema
                CALL stoi ; convertir string -> integer, Lo almacenara en la variable 'resultado'
                mov ax, resultado
                mov arrNumeros[di], ax
                inc di
            salite:
            ;limpiar variables
            limpiarVariable lexema, SIZEOF lexema
            mov token,0
            mov resultado,0
            jmp forCA 
        L1:
        jmp displayMenu
    ordenar:

    ;jmp pruebas
    crearReporte:

    mov der, 18
    CALL INI_VIDEO
    CALL QUICKSORT
    ; Mostrar el arreglo final ordenado
    limpiar_pantalla
    CALL GRAFICAR_NUMEROS
            mov ah, 10h
            int 16h 
            limpiar_pantalla
    mov ah, 10h
    int 16h 
    
    CALL FIN_VIDEO
    ;CALL INI_VIDEO
    ;pintar_marco 20,190,15,305,15
    ;mov ah, 10h
    ;int 16h 
    ;CALL FIN_VIDEO



    ;pruebas:
    ;CALL INI_VIDEO 
;
    ;;pintar_pixel 50,100,15
    ;pintar_marco 20,190,15,305,15
;
    ;;pintar_rectangulo 150,170,25,10 
    ;pintar_rectangulo 20,43,25,10 
    ;pintar_rectangulo 48,71,25,10
    ;pintar_rectangulo 76,99,25,10
    ;pintar_rectangulo 104,127,25,10
    ;pintar_rectangulo 132,155,25,10
    ;pintar_rectangulo 160,183,25,10
    ;pintar_rectangulo 188,211,25,10
    ;pintar_rectangulo 216,239,25,10
    ;pintar_rectangulo 244,267,25,10
    ;pintar_rectangulo 272,295,25,10
;
;
    ;
;
    ;posicionar_cursor 20,2
    ;CALL DS_DATOS
    ;print cadena
    ;mov ah, 10h
    ;int 16h 
    ;posicionar_cursor 20,6    
    ;print cadena2
    ;posicionar_cursor 20,9   
    ;print cadena2
    ;posicionar_cursor 20,13  
    ;print cadena2
    ;posicionar_cursor 20,17
    ;print cadena2
    ;mov ah, 10h
    ;int 16h 
    ;CALL DS_VIDEO    
;
    ;CALL FIN_VIDEO
    ;print cadena

    FIN:
    mov Ah,4Ch
    int 21h

main endp


QUICKSORT proc     
    
    
    push si 
    push di
    push ax  
    push bx  ; aux
    
    CALL DS_DATOS

    mov si, izq ; izq =0, i +-
    mov di, der ; der =9  j +-
     
    mov bx,izq 
    mov ax,arrNumeros[bx] ;pivote 
    
    while1:
    cmp si, di
    JGE finwhile1
        
        while2: ; Buscar el elemento mayor que pivote 
        ;mov ax,arrNumeros[si*2]
        cmp arrNumeros[si], ax ; ax       
        JA finwhile2
        cmp si, di 
        JGE finwhile2
            add si, 2
        
            jmp while2
        finwhile2:
        
        while3: ;Buscar el elemento menor que pivote
        cmp arrNumeros[di], ax 
        jbe finwhile3
            sub di,2
            jmp while3
        finwhile3: 
        ; if(i < j)
        cmp si, di
        JGE L20       
            ; Incercambiar los valores
            mov bx, arrNumeros[si]
            push bx 
            mov bx, arrNumeros[di]
            mov arrNumeros[si],bx
            pop bx 
            mov arrNumeros[di], bx 

            CALL GRAFICAR_NUMEROS
            Delay 3000 
            limpiar_pantalla
            
        
        L20:
        
     
     jmp while1  
    finwhile1:
    ;pausa
    mov bx, izq  
    push ax
    mov ax, arrNumeros[di] 
    mov arrNumeros[bx],ax 
    pop ax
    mov arrNumeros[di], ax  
    
    CALL GRAFICAR_NUMEROS
    Delay 3000 
    limpiar_pantalla
    
    
    mov bx, di
    sub bx, 2  
    cmp izq,bx
    jg L21   
        
        push der
        push izq   
        mov der, bx ; 
        CALL QUICKSORT
        pop izq 
        pop der
         
        ;jmp L22  
        ;pausa
    L21:
        mov bx, di 
        add bx, 2
        cmp bx, der
        jg L22    
            mov izq, bx
            CALL QUICKSORT 
      
            
    L22:
    pop bx
    pop ax
    pop di
    pop si
    
ret
QUICKSORT endp 

GRAFICAR_NUMEROS proc 
    pushF
    CALL DS_DATOS
    ; %%%%%%%%%%%% Calcular el ancho que deben tener los rectangulos %%%%%%%%%%%%%%%%%
    mov ax, contaNumeros
    mov bx, 5   ; Espaciado entre cada rectangulo 
    mul bx ; Resultado en DX,AX -> Si no supera los 16 bits entonces el resultado estara en AX

    mov bx, 280 ; Tamaño maximo disponible para poder alojar los rectangulos
    sub bx, ax  ; Tamaño real para alojar los bloques para que cada uno tenga una espaciado de '5'

    ; divir tamaño real/cantidad de numeros para saber el ancho de cada bloque
    mov dx, 0 ; Limpiar la parte alta del dividendo
    mov ax,bx ; Set la parte baja del dividendo  (bx)
    div contaNumeros ; divisor -> cociente ax, residuo dx
    ; El tamaño de cada rectangulo estara en AX
    mov anchoRectangulo, ax
    cmp ax, 20 ; Verificar si el ancho del rectangulo es menor a 20
    JAE continuarL1 
        mov varExcede, 1 ; Indicando que los numeros ya no caben y deben desplegarse verticalmente

    continuarL1:
        mov bx, 20 ; columna inicial donde iniciara el primer rectangulo
        mov cx, 0  ; iterar en los numeros ingresados
        mov ax, 0  ; limpiar ax
        mov si, 0  ; Para ingresar a 'arrNumeros'

    CALL DS_VIDEO 

    pintar_marco 20,190,15,305,15

    ;Crear todos los rectangulos y colocarle sus respectivos valores+
    forL2:
        CALL DS_DATOS ; Apuntar al segmento de datos
        cmp cx, contaNumeros
        je finL2 ; salir del for

        ;%%%%%%%%%%% Calcular la altura del rectangulo, respecto al valor mas grande
        mov ax, bx 
        add ax, anchoRectangulo
        ;Calcular altura del rectangulo -> 25 +(num mayor - num actual) + "if(maxval/arrNumeros[si] > 2) sumar -> 50"
        mov dx, maxVal
        ;printChar dl
        sub dx, arrNumeros[si]
        add dx, 25 ; dx tendra la altura del rectangulo

        ; Arreglar la posible desproporcion si un numero es muy pequeño if(maxval/arrNumeros[si] > 2) sumar -> (130 - MaxVal)
        push dx 
        push ax 
            mov dx, 0 
            mov ax, maxVal
            div arrNumeros[si] ; AX -> Cociente 
            cmp ax, 2
            JBE noDesproporcion
                mov ax, 130 
                sub ax, maxVal
                mov varDesproporcion, ax ; ( 130 - Maxval)
                jmp finL4
            noDesproporcion:
                mov varDesproporcion, 0
            finL4:
        pop ax 
        pop dx 

        add dx, varDesproporcion  ; varDesproporcion puede ser ( 0 | x)

        ;%%%%%%%%%%% Colocar Numero
        limpiarVariable strNumero, SIZEOF strNumero
        itos arrNumeros[si], strNumero 

        CALL GET_PosCursor ; actualiza 'varPosCursor'
        posicionar_cursor 20,varPosCursor
        ;print strNumero
        printChar strNumero
        cmp strNumero+1, '$'
        je continuarL2 
            cmp anchoRectangulo, 18
            jbe incFila ; Sino incrementamos la columna
                inc varPosCursor
                posicionar_cursor 20,varPosCursor
                printChar strNumero[1]
                jmp continuarL2

            incFila: ; Incrementamos la fila 20 +1 (21)  
                posicionar_cursor 21,varPosCursor
                printChar strNumero[1]
        continuarL2: 
                            ;push ax 
                            ;mov ah, 10h
                            ;int 16h  
                            ;pop ax
        ;%%%%%%%%%%% pintar el rectangulo
        GET_color arrNumeros[si], colorcito

        CALL DS_VIDEO ; Apuntar al segmento de videos
        pintar_rectangulo bx,ax,dx,colorcito 
        CALL DS_DATOS
        mov bx, ax 
        add bx, 5 ; Agregamos el espaciado entre cada rectangulo

        add si,2
        inc cx
        jmp forL2
    finL2:
    popF
ret 
GRAFICAR_NUMEROS endp



CARGAR_ARCHIVO proc 
; leer la ruta donde se encuentra el archivo
    ;Leer la entrada del usuario
    iniCA:
    print strIngresoArchivo
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
    
    CMP nombreArchivo[bx+1],'x'
    jne errorCA
    CMP nombreArchivo[bx+2],'m'
    jne errorCA
    CMP nombreArchivo[bx+3],'l'
    jne errorCA
        ; --> La extension del archivo es la correcta
        ; ****** Abrir el fichero/archivo **********
        abrirFichero nombreArchivo, handlerCA
        leerFichero handlerCA,buffer,SIZEOF buffer
        ;print buffer
        cerrarFichero handlerCA
        jc errorCF
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
    ; Al finalizar, CX tendra el tamaño del numero 
    ;convertir el string de numeros a integer
    mov contador,0
    mov dx, 0
    forL1:
        mov si, cx 
        dec si 
        cmp contador,0
        jne L2
            mov dl, lexema[si]
            SUB dl,48 ; dl = dl - 48 // convierte el char a digito 
            ADD resultado, DX ; La primera iteracion 0 = 0 + ah
            jmp L3
        L2:
            cmp contador, 1
            jne L3 
            mov dl,lexema[si]
            SUB dl,48 ; ah = ah - 48 // convierte el char a digito 
            mov al, 10
            MUL dl ; MUL multiplica lo del registro al con el operador siguiente de la instruccion MUL -> ej (10 * ah)
            mov dl, al ; El resultado de la multiplicacion se coloca en dl
            ADD resultado, DX

        L3: 
        inc contador
    loop forL1

    pop dx
    pop bx
    pop si 
    pop cx
ret
stoi endp



INI_VIDEO proc
    mov ax,0013h
    int 10h 
    mov ax, 0A000h ; inicio de modo video
    mov ds, ax
ret
INI_VIDEO endp


FIN_VIDEO proc 

    mov ax, 0003h
    int 10h 
    mov ax, @data 
    mov ds, ax 
ret
FIN_VIDEO endp

DS_DATOS proc
    push ax 
    mov ax, @data 
    mov ds, ax 
    pop ax
ret
DS_DATOS endp

DS_VIDEO proc
    push ax 
    mov ax, 0A000h 
    mov ds, ax 
    pop ax
ret
DS_VIDEO endp


GET_PosCursor proc ; Calcular la posicion donde colocar el cursor para colocar el numero abajo del rectangulo
; Antes de ejecutar este procedimiento se debe de llamar DS_DATOS
; El inicio del rectangulo se encuentra en bx 
    push bx
    push ax 
 
    mov ax, bx 
    mov bl, 8 ; 8 bits que ocupa el escribir un digito 
    div bl  ; AL = cociente, ah = residuo

    mov varPosCursor, al 
    cmp ah, 0 ; Si tiene residuo debemos incrementar la variable en +1
    je finL3
        inc varPosCursor
    finL3: 
    pop ax 
    pop bx

ret
GET_PosCursor endp



end main

