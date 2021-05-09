

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


readCadenaTeclado macro buffer; lee cadena del teclado y lo inserta en la direccion de memoria de buffer
    mov ah, 0AH
    mov dx, offset buffer
    int 21h
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


;%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERACIONES CON ARCHIVOS/FICHEROS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

abrirFichero macro archivo, handler ; Si no hay error AX = handler, sino JC = true
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

;%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


;%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERACIONES CON STRINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compararStrings macro str1, str2, tamano, varReturn
    local desigualdad, fin

    push ax
    push cx 
    push si 
    push di 

    mov ax, @data 
    mov ES, ax  ; requerido para utilizar CMPSB

    ; Verificar que ambas cadenas sean del mismo tamaño
    mov al, tamano 
    cmp al, sizeof str2
    jne desigualdad

    cld ; DF = 0 , inicia desde el 0

    mov cx, 0 
    mov cl, tamano 

    lea si, str1 
    lea di, str2 

    repe CMPSB 

    jne desigualdad

        cmp cx, 0 
        jne desigualdad
            ;print f 
            mov varReturn, 1
            jmp fin      

    desigualdad: ; las cadenas no son iguales
        ;print e
        mov varReturn, 0
    fin:
    pop ax 
    pop cx 
    pop si 
    pop di
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
;%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


;%%%%%%%%%%%%%%%%%%%%%%%%%%% OPERACIONES CON FUNCIONES VARIADAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


get_potencia macro base, exponente, resultado ; resultado = 1
    local for, fin  
    push ax 

    mov resultado, 1 
    for: 
        cmp exponente, 0
        je fin
            mov ax, base ; Base
            mul resultado ; ax = ax * res

            mov resultado, ax 
        dec exponente   
    jmp for 

    fin:

    pop ax

endm


division_decimal macro num, num2
    local ciclo 
    xor dx,dx 
    mov ax, num 
    mov bx, num2 
    div bx  ; num / num2
    mov entero, ax ; cociente -> entero
    mov decimal,0  ; siempre reiniciar decimal

    mov cx,3 ; Solo mostrar 3 decimales
    ciclo:
        ; Multiplicar por 10 el residuo
        mov ax,dx ;-> movemos el residuo al dividendo
        xor dx,dx 
        mov bx,10 
        mul bx ; Resultado en AX

        ;dividir nuevo dividendo / num2
        xor dx,dx 
        mov bx, num2
        div bx ; -> AX / num2 -> cociente en AX
        ;Convertir cada digito a su potencia (1)x10+val...
        push ax ; almacenamos el cociente
        push dx ; Almacenar el residuo para cuando regrese a la etiqueta 'ciclo'
        mov ax,decimal 
        xor dx,dx 
        mov bx,10 
        mul bx

        mov decimal, ax
        pop dx          ; recuperar el residuo para la proxima iteracion del ciclo
        pop ax          ; recuperar el cociente 
        add decimal, ax ; decimal = decimal * 10 + cociente
    loop ciclo

endm


cls macro
    local ciclo 
    mov cx,50
    ciclo:
        printChar 10

    loop ciclo    
endm 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
