
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
    jc errorCF
endm

readCadenaTeclado macro buffer; lee cadena del teclado y lo inserta en la direccion de memoria de buffer
    mov ah, 0AH
    mov dx, offset buffer
    int 21h
endm

ejecutarOperacionAritmetica macro operando1, operando2, operador ; operando1 y operando2, tienen la misma direccion de memoria de las variables globales

    CMP operador, '+' ; Sumar los operandos
    jne resta
        xor AX,AX 
        mov AX, operando2
        ADD operando1, AX ; resultado se almacenara en operando1
    resta:
endm

