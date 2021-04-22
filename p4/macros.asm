
print macro cadena
    push ax
    push dx 
    ; interrupcion para mostrar un string en pantalla
    mov Ah, 09H
    mov dx, offset cadena
    int 21h
    ;Devolver los valores para evitar modificaciones de registros
    pop dx
    pop ax
endm 


printChar macro char
    push ax
    push dx 

    mov ah,02h
    mov dl ,char
    int 21h

    pop dx 
    pop ax
endm


readKeyboard macro ; El caracter leido es colocado en Al
    
    mov Ah, 01h
    int 21h
endm 


readCadenaTeclado macro buffer; lee cadena del teclado y lo inserta en la direccion de memoria de buffer
    mov ah, 0AH
    mov dx, offset buffer
    int 21h
endm


;%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERACIONES CON ARCHIVOS/FICHEROS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
abrirFichero macro archivo, handler
    mov AH, 3DH
    mov Al, 02 ; Abrir lectura y escritura 
    mov DX, offset archivo
    int 21h
    JC errorAF ; CF = 1 -> error al abrir el fichero
        mov handler, AX ; colocamos el manejador del fichero en la variables handler
endm


leerFichero macro handle,buffer, numBytes 
    mov ah, 3FH
    mov bx, handle
    mov cx, numBytes
    mov dx, offset buffer
    int 21h
    jc errorLF

endm


cerrarFichero macro handle
    mov ah, 3EH
    mov bx, handle
    int 21h
endm

crearFichero macro nombre 
        
    mov ah, 3CH
    mov cx, 00H ; FICHERO NORMAL
    mov dx, offset nombre ; nombre del fichero
    int 21h    
endm

writeFichero macro handler, cadena, numBytes
    mov ah, 40H
    mov bx, handler       ; puntero al archivo
    mov cx, numBytes      ; cantidad de bytes a escribir
    mov dx, offset cadena ; bytes de donde se sacara la informacion
    int 21h
endm
;%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analizadorLexico macro buffer, lexema, token ; su funcion es formar un lexema
    LOCAL for,estado0, estado1, estadofinal, fin 
    ;La posicion se manejara en SI (si ingresa desde afuera de la funcion)
    push bx 
    push di 

    mov bl, 0 ; Manejar el estado del analizador
    mov di, 0 ; Posicion en donde insertara en lexema
    for:
        mov bh, buffer[si] ; Leer 1 caracter del buffer

        estado0: ; estado inicial donde puede ser '<' o (0-9) -> cualquier otro simbolo es un error
            cmp bl, 0
            jne estado1
            
            cmp bh,'<'
            jne digitos
                mov lexema[di], bh
                inc di
                mov bl, 2 ; Cambiamos al estado 2
                jmp iterar 
            digitos:
                cmp bh,48
                jb estadofinal
                cmp bh, 58
                ja estadofinal
                
                mov lexema[di],bh 
                inc di
                mov bl,1
                mov token,10
                jmp iterar ; Cambiamos al estado 1 

        estado1: ; solo puede leer si (0-9)+ 
            cmp bl, 1 
            jne estado2 
            
            cmp bh,48
            jb estadofinal
            cmp bh, 58
            ja estadofinal

                mov lexema[di],bh 
                inc di
                mov bl,1   ; permanecemos en el mismo estado
                mov token, 10
                jmp iterar ; Cambiamos al estado 1 

        estado2: 
            cmp bl, 2 
            jne estadofinal
            
            cmp bh,'>'
            je estado3
            
            mov lexema[di], bh
            inc di 
            jmp iterar
            
        estado3: ; Solo almacena '>'
            mov lexema[di], bh
            inc di 
            mov token, 20

        estadofinal:
            inc si
            jmp fin 

        iterar:
        inc si 
        jmp for 
    fin:
   ; print lexema
    pop di 
    pop bx  

endm 


limpiarVariable macro variable, varSize ; coloca '$' en la variable indicada
    LOCAL iterar
    push cx
    push si 
    push dx 

    mov cx, varSize
    mov si, offset variable
    mov dl, '$' ; caracter de limpieza
    iterar:
        mov [si], dl
        inc si
    loop iterar ; internamente -> DEC cx

    pop dx 
    pop si 
    pop cx
endm


itos macro val,valString ;integer to string
    LOCAL L6,imprimir, L7,salir
    push ax 
    push dx 
    push cx  
    push si
    push bx 

    mov ax, val
    mov dx,0 ; Aqui ira el residuo 
    mov cx,0 ; Para saber cuanto sacar de la pila   
    mov si,offset valString ; contador para colocar los 'chars' en la variable 'numResp'       
    ; if ax == 0, no operar y solo mostrar el valor '0'
    cmp ax,0
    je L7
     
    L6:
    ;if cociente = 0, ya no puede didivir, por lo que debe terminar
      cmp ax, 0
      je imprimir
    
      mov bx, 10
      div bx ; ax / bx    
      
      ;Almacenar el residuo
      push dx
      ;incrementar el contador
      inc cx 
      ; limpiar dx, ya que DIV uitliza dx en sus calculos
      xor dx,dx
      jmp L6
    imprimir: 
      ;Extraer de la pila
      cmp cx,0
      je salir  
      
      pop dx
      ; convertir ascii del digito    
      add dx,48
      ; Colocar el ascii del digito en la variable si -> 'valString'
      mov [si], dl
      ; interrupcion para imprimir caracter
      ;mov ah, 02h 
      ;int 21h ; El valor lo extrae de dl   
                             
      dec cx
      inc si
      jmp imprimir
      
    L7: ; ingresa unicamente si es 0
      ; print 0
      mov dx, ax
      add dx,48 
      mov [si],dx
      ;mov ah, 02h
      ;int 21h ; El valor lo extrae de dl
    salir:
    ; No afectar los registros
    pop bx 
    pop si 
    pop cx
    pop dx
    pop ax 

endm



Delay macro constante
    LOCAL D1,D2,Fin, no_change, contar_minutos,L1
    push si
    push di
    push ax 
    push dx 
    push cx 

    mov si,constante
    D1:
    dec si
    jz Fin
        mov  ah, 2ch
        int  21h ;RETURNA SECONDS en DH.
        ;Chqeuar si ya paso un segundo. 
        cmp  dh, segundos
        je   no_change
        ;Si no salta, entonces implica que paso 1 segundo
         mov  segundos, dh
        ; Verificar si el 'segundo' es 59
        cmp contaSeg, 59
        je contar_minutos
            inc contaSeg
            jmp L1

        contar_minutos:
            mov contaSeg, 0 ; reiniciar el contador de segundos
            ; Imprimir en pantalla los minutos
            inc contaMin
            limpiarVariable strNumero, sizeof strNumero
            itos contaMin, strNumero
            posicionar_cursor 1,67
            print strNumero
        
        L1: ; Imprimir en pantalla los segundos
            limpiarVariable strNumero, sizeof strNumero
            itos contaSeg, strNumero
            posicionar_cursor 1,69
            print strNumero

        no_change:
    mov di,constante
    D2:
    dec di
    jnz D2
    jmp D1
    
    Fin:
    pop cx
    pop dx
    pop ax 
    pop di
    pop si
endm



strCpy macro Origen, Destino, ptrDestino 
    LOCAL for 
    push si 
    push di 
    push cx 
    push bx 
    push ax 

    mov di, offset destino 
    mov si, offset origen

    ;mov cx, SIZEOF Origen ; Tamaño del string que se desea copiar
    get_length origen ;-> resultado en cx
    mov bx, ptrDestino       ; Desde donde debe empezar a colocar los caracteres
    for:  
        mov al, [si]
        mov [di + bx], al
        inc bx
        inc si 
    loop for 
    ; actualizar el id del puntero
    ;dec bx ; Colocar el puntero al final de '$'
    mov ptrDestino,bx 

    pop ax 
    pop bx 
    pop cx
    pop di
    pop si

endm


get_length macro string ; Obtener el tamaño de un string -> resultado estara en cx
    local for, break  
    push si 

    mov cx,0 ; contador -> 64k palabras es lo maximo que podria contar un contador de 16 bits
    mov si,0 
    for:
        ;if char != '$'
        cmp string[si], '$'
        je break
            inc si 
            inc cx 
        jmp for 
    break:

    pop si

endm 

INSERT_ASC macro texto1, texto2 ; procedimiento que inserta las numeros y numeros ordenados en la cadena de texto para el reporte
    LOCAL L25, L24, forL23 
    ;if (conta == 0 || conta == 1) 
    cmp contaAscendente, 0
    je  L25
    cmp contaAscendente, 1  
    jne L24
    L25:  
        strCpy texto1, strAscendente, ptrAscendente 
        mov cx, contaNumeros
        mov si, 0  
        forL23:
            limpiarVariable strNumero, sizeof strNumero
            itos arrNumeros[si], strNumero
            strCpy strNumero, strAscendente, ptrAscendente ;Numeros     
            strCpy comma, strAscendente, ptrAscendente     ; comma
            add si, 2
            dec cx 
        jnz forL23
        strCpy texto2, strAscendente, ptrAscendente
        inc contaAscendente ; Solo ingresara 2 veces, esto para evitar que si ingresan multiples veces a bubblesort, no se concatenen cosas de mas.
    L24: ; salida de procedimiento 
endm 


INSERT_DESC macro texto1, texto2 ; procedimiento que inserta las numeros y numeros ordenados en la cadena de texto para el reporte
    LOCAL L25, L24, forL23, forL24 
    ;if (conta == 0 ) 
    cmp contaDescendente, 0
    jne  L25
        strCpy texto1, strDescendente, ptrDescendente 
        mov cx, contaNumeros
        mov si, 0  
        forL23:
            limpiarVariable strNumero, sizeof strNumero
            itos arrNumeros[si], strNumero
            strCpy strNumero, strDescendente, ptrDescendente ;Numeros     
            strCpy comma, strDescendente, ptrDescendente     ; comma
            add si, 2
            dec cx 
        jnz forL23
        strCpy texto2, strDescendente, ptrDescendente
        inc contaDescendente ; Solo ingresara 2 veces, esto para evitar que si ingresan multiples veces a bubblesort, no se concatenen cosas de mas.
        jmp L24
    L25:
    ;else if (conta == 1)
    cmp contaDescendente, 1  
    jne L24
        strCpy texto1, strDescendente, ptrDescendente 
        mov cx, contaNumeros
        ; posicionarse al final del array
         mov dx, 0 
         mov ax, 2
         mul contaNumeros
         sub ax, 2 ; EJEMPLO!!!->(10*2)-2 ->Iniciaria desde el final, hacia 0
         mov si, ax 
        forL24:
            limpiarVariable strNumero, sizeof strNumero
            itos arrNumeros[si], strNumero
            strCpy strNumero, strDescendente, ptrDescendente ;Numeros     
            strCpy comma, strDescendente, ptrDescendente     ; comma
            sub si, 2
            dec cx 
        jnz forL24
        strCpy texto2, strDescendente, ptrDescendente
        inc contaDescendente ; Solo ingresara 2 veces, esto para evitar que si ingresan multiples veces a bubblesort, no se concatenen cosas de mas.  
        
    L24: ; salida de procedimiento 
endm 

borrar_rectangulo macro indice,ancho ;Usar (di|si|variable word) -> Indice debe estar multiplicado por 2
    LOCAL forcol, forfila, L1
     
    push di 
    push si 
    push ax 
    push dx 
    push cx 
    push bx 
    ;push ax

    cmp modoOrdenamiento, 2
    jne L1 ; El borrado es en el indice indicado
        mov dx, 0 
        mov ax, 2
        mul contaNumeros ; resultado en ax

        sub ax, 2  
        sub ax, indice 
        mov indice, ax 
        
    L1:
    ; ej 18/2 = 9
    mov dx, 0 
    mov ax, indice 
    mov cx, 2 ;  coiciente en AX
    div cx

    ; Calcular el inicio del rectangulo a borrar
    mov bx, ax ; bx = indice / 2 
    ; (ancho + 5)
    mov dx, ancho 
    add dx, 5 
    
    ; indice ( ancho + 5)
    mov ax, dx 
    mul bx  
    
    
    ; 20 + indice ( ancho + 5)
    add ax,20

    ;limpiarVariable strNumero, sizeof strNumero 
    ;itos ax, strNumero 
    ;posicionar_cursor 0,0
    ;print strNumero 
    ;readKeyboard
    push ancho 
    add ancho, ax 
    ; Borra el rectangulo
    pintar_rectangulo ax, ancho, 25,0
    pop ancho

    ; Borra el numero asociado abajo del rectangulo
    push ancho 
    add ancho, ax
    mov si,ax
    forcol:
        mov cx, 158 ; fila donde iniciara
        forfila:
            pintar_pixel cx, si, 0
            inc cx 
            cmp cx, 178 ;fila donde terminara 
        jne forfila
        inc si 
        cmp si,ancho
    jne forcol 

    pop ancho
    
    ;pop ax
    pop bx
    pop cx 
    pop dx 
    pop ax 
    pop si 
    pop di


endm

; %%%%%%%%%%%%%%%%%%%%%%%% MACROS PARA MODO VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pintar_pixel macro i,j,color ; i(fila) -> (0,199), j(col)-> (0-319)
    push ax
    push bx
    push di
    push dx ; Al utilizar MUL
    ;limpiar variables
    mov ax,0
    mov bx,0
    ;mapeo lexicografico
    mov ax, 320
    mov bx, i 
    mul bx ; ax = ax * bx
    add ax, j 
    ; asignar el color en la direccion de memoria indicada
    mov di, ax 
        mov ax, color
    CALL DS_VIDEO
    mov [di],ax ; [] -> Asigna en el segmento de VIDEO actual el valor 
    CALL DS_DATOS  
    pop dx
    pop di
    pop bx
    pop ax 

endm


pintar_marco macro fila1, fila2, col1, col2, color
    local for1 , for2
    push si

    mov si,0
    mov si, col1; inicia desde la columna 1
    for1: 
        pintar_pixel fila1,si,color
        pintar_pixel fila2,si,color 
        inc si 
        cmp si, col2
    jne for1

    mov si, fila1 
    for2:
        pintar_pixel si, col1, color
        pintar_pixel si, col2, color
        inc si
        cmp si, fila2
    jne for2

    pop si
endm


pintar_rectangulo macro ancho1, ancho2, altura, color
    LOCAL forcol, forfila
    push si 
    push cx

    mov si,ancho1
    forcol:
        mov cx, 155 ; fila donde iniciara
        forfila:
            pintar_pixel cx, si, color
            dec cx 
            cmp cx, altura ;fila donde terminara
        jne forfila
        inc si 
        cmp si, ancho2
    jne forcol 

    pop cx
    pop si
endm 


posicionar_cursor macro fila, columna ; (maximos fila 25, columna 118)
    push ax
    push bx
    push dx 
    mov ax, 0
    ; codigo para posicionar el cursor 
    mov ah, 02h 
    mov bh, 00h
    mov dh, fila; Linea del cursor (solo 23 filas)
    mov dl, columna ; Columna del cursor ; 118 columnas
    int 10h
    ;Recuperar para no afectar registros
    pop dx
    pop bx
    pop ax
endm

GET_color macro valor, retorno 
    LOCAL salida, L1,L2,L3,L4 
    ; if(valor<= 20 )
    cmp valor, 20
    ja L1
        mov retorno, 4 ;ROJO
        jmp salida
    L1:
        cmp valor, 40
        ja L2
        mov retorno, 1 ;Azul
        jmp salida
    L2:
        cmp valor, 60
        ja L3
        mov retorno, 14 ;Amarillo
        jmp salida
    L3:
        cmp valor, 80
        ja L4
        mov retorno, 2 ;Verde
        jmp salida
    L4: 
        mov retorno, 15 ; blanco

    salida: 
endm 


limpiar_pantalla macro 
    local fori, forj
 ; Aqui debe iniciarse
    push si 
    push di

    mov si, 0
    mov di, 0

    fori:
        forj:  
            pintar_pixel si, di, 0 ; color negro
            inc di 
            cmp di, 319
            jb forj 
        
        inc si 
        mov di, 0
        cmp si, 199 
        jb fori 

    pop di
    pop si

endm

pausar macro 
    push ax 
    mov ah, 10h
    int 16h 
    pop ax
endm 

