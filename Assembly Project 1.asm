INCLUDE Irvine32.inc
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data

    salesArr DWORD 30 DUP (0)       
    numSales DWORD 0
    
    prompt1 BYTE '1) Enter a Sale', 0
    prompt2 BYTE '2) View All Sales', 0
    prompt3 BYTE '3) View Total', 0
    prompt4 BYTE '4) Quit', 0
    menuPrompt BYTE 'Please Select one of the options (1-4): ', 0

    addSaleP1 BYTE 'Please enter the sale amount: $', 0
    addSaleP2 BYTE 'No more sales can be added. The Array is full!', 0
    addSaleP3 BYTE 'Enter the number 0 to go back to the menu.', 0

    viewSalesP1 BYTE 'These are the sales entered:', 0
    viewSalesP2 BYTE 'Please enter atleast one sale to show recorded sales.', 0
    dollarSign BYTE '$', 0

    saleTotal BYTE 'The total sales amount is: $', 0
    saleZero BYTE 'No Sales have been recorded!', 0

    goodbyeMsg BYTE 'Thank you for using the Sales Management Program. Goodbye!', 0

.code
main PROC

MainMenu:
    call Crlf
    mov edx, OFFSET prompt1                     ; prints the menu options
    call WriteString
    call Crlf
    mov edx, OFFSET prompt2
    call WriteString
    call Crlf
    mov edx, OFFSET prompt3
    call WriteString
    call Crlf
    mov edx, OFFSET prompt4
    call WriteString
    call Crlf
    mov edx, OFFSET menuPrompt
    call WriteString
    call ReadInt                                ; asks for user input, a value between 1-4
    
    cmp eax, 1                                  ; determines which option was selected
    je DoAddSale
    cmp eax, 2
    je DoViewSales
    cmp eax, 3
    je DoViewTotal
    cmp eax, 4
    je ExitProgram
    jmp MainMenu                                ; if no valid input we show the menu again

DoAddSale:                                      ; calls the AddSale procedure
    call addSale
    jmp MainMenu                                ; after procedure returns we show the menu again

DoViewSales:                                    ; calls the ViewSales procedure
    call ViewSales
    jmp MainMenu                                ; after procedure returns we show the menu again

DoViewTotal:                                    ; calls the ViewTotal procedure
    call ViewTotal
    jmp MainMenu                                ; after procedure returns we show the menu again

ExitProgram:                                    ; exits the program and prints the good bye message
    call Crlf
    mov edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf

    INVOKE ExitProcess, 0
main ENDP

addSale PROC USES ebx esi ecx

    mov esi, OFFSET salesArr
    mov ecx, numSales
    mov eax, ecx
    shl eax, 2                                  ; multiply by 4 to get byte offset
    add esi, eax                                ; point esi to the next free available element in the array
    mov ebx, LENGTHOF salesArr                  ; get max number of elements in array
    
    call Crlf
    mov edx, OFFSET addSaleP3                   ; notify user how to return to menu
    call WriteString
    call Crlf
    
addSaleWhile:
    cmp ecx, ebx
    jge ArrayFull                               ; if the array is full skip the body of the while loop and go to ArrayFull label
    
    call Crlf
    mov edx, OFFSET addSaleP1
    call WriteString
    call ReadInt                                ; ask user for input to record the sale amount
    
    cmp eax, 0                                  ; if user enters 0 we go back to menu 
    je Done
    
    mov [esi], eax                              ; moves user input to the array
    add esi, 4
    inc ecx
    jmp addSaleWhile
    
ArrayFull:
    call Crlf
    mov edx, OFFSET addSaleP2                   ; let the user know the array is full
    call WriteString
    call Crlf
    
Done:
    mov numSales, ecx                           ; update the number of sales recorded
    call Crlf

    ret
addSale ENDP

ViewSales PROC USES esi ecx

    call Crlf
    mov ecx, numSales                           ; get number of sales recorded
    
    cmp ecx, 0
    je NoSales                                  ; if no sales recorded go to NoSales label
    
    mov edx, OFFSET viewSalesP1
    call WriteString
    call Crlf
    mov esi, OFFSET salesArr                    ; get the memory address of first sale entry
    
PrintLoop:
    call Crlf
    mov edx, OFFSET dollarSign                  ; print dollar sign before each sale amount
    call WriteString
    mov eax, [esi]                              ; move the array element to eax to print
    call WriteDec
    add esi, 4                                  ; move to next element in array
    call Crlf
    loop PrintLoop

    ret
    
NoSales:
    mov edx, OFFSET viewSalesP2                 ; notify the user that no sales were recorded
    call WriteString
    call Crlf

    ret
ViewSales ENDP

ViewTotal PROC USES esi ecx

    mov esi, OFFSET salesArr                    ; get the memory address of first sale entry
    mov ecx, numSales                           ; get the number of sales recorded to initialize loop counter
    xor eax, eax                                ; clearing eax to use it as accumulator for total sales amount (xoring is faster than mov eax, 0)
    
TotalLoop:
    cmp ecx, 0                                  ; check if any sales have been recorded
    je NoSales
    add eax, [esi]                              ; add each sale amount to eax
    add esi, 4                                  ; iterate to next element in array
    loop TotalLoop
    
    call Crlf
    mov edx, OFFSET saleTotal                   ; print the total sales message
    call WriteString
    call WriteDec                               ; print the total sales amount
    call Crlf
    jmp SalesExit

NoSales:
    call Crlf
    mov edx, OFFSET saleZero                   ; notify user that no sales have been recorded
    call WriteString
    call Crlf

SalesExit:
    
    ret
ViewTotal ENDP
END main
