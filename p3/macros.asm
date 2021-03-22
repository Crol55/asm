
print macro cadena
    mov Ah, 09H
    mov DX, offset cadena
    int 21h
endm

readKeyboard macro ; El caracter leido es colocado en Al
    mov Ah, 01h
    int 21h
endm 

printChar macro char
    mov ah,02h
    mov dl ,char
    int 21h
endm


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

readCadenaTeclado macro buffer; lee cadena del teclado y lo inserta en la direccion de memoria de buffer
    mov ah, 0AH
    mov dx, offset buffer
    int 21h
endm

ejecutarOperacionAritmetica macro operando1, operando2, operador ; operando1 y operando2, tienen la misma direccion de memoria de las variables globales
    LOCAL fin, resta, multiplicacion, division
    CMP operador, '+' ; Sumar los operandos
    jne resta
        xor AX,AX 
        mov AX, operando2
        ADD operando1, AX ; resultado se almacenara en operando1
    resta:
    CMP operador,'-'
    jne multiplicacion
        xor AX,AX
        mov AX, operando2
        SUB operando1, AX
    multiplicacion:
    CMP operador, '*'
    jne division
        mov Bx, operando2
        mov Ax, operando1
        IMUL Bx ; Ax * Bx -> resultado en Ax
        mov operando1, ax
    division:; La division con signo, requiere que AX sea signo extendido a DX
        CMP operador, '/'
        jne fin
            mov Ax, operando1; dividendo
            cwd ; sign-extended AX en DX
            mov Bx, operando2; divisor
            IDIV Bx; Cociente en AX, residuo en DX
            mov operando1, ax
    fin:
endm

itos macro val ;integer to string
    LOCAL L6,imprimir, L7,salir

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
      mov ah, 02h 
      int 21h ; El valor lo extrae de dl   
                                        
      dec cx
      inc si
      jmp imprimir
      
    L7: ; ingresa unicamente si es 0
      ; print 0
      mov dx, ax
      add dx,48 
      mov [si],dx
      mov ah, 02h
      int 21h ; El valor lo extrae de dl
    salir:
endm

limpiarVariable macro variable, varSize ; coloca '$' en la variable indicada
    LOCAL iterar
    mov cx, varSize
    mov si, offset variable
    mov dl, '$' ; caracter de limpieza
    iterar:
        mov [si], dl
        inc si
    loop iterar ; internamente -> DEC cx
endm


MoverSB macro destino,pos1, origen, pos2 
    LOCAL for, breakk
    mov ax, @data 
    mov es, ax ; Extra segment
    mov si, offset origen  ; si = source
    mov di, offset destino ; di = destination
    mov cx, SIZEOF origen
    ; Indicar a si y di desde donde deben empezar ya que no siempre pueden empezar en 0
    add si, pos2 ; aplicar offset si es necesario
    add di, pos1 ; aplicar offset si es necesario
        mov dl, '$'
        for:
            cmp [si],dl
            je breakk
            movsb
        loop for 

        breakk:
endm


getFactorial macro val
    LOCAL L9, afuera
    mov cx,val
    mov ax, 1
    L9: 
      ;while (cx != 0)
      cmp cx,0
      je afuera
      
      mov dx, 0
      mul cx ; ax = ax * cx
      ; decrementar el valor
      dec cx

      jmp L9
    
    afuera:
      mov resp, ax

endm