DATA SEGMENT
	a DD
	b DD
	aux DD
DATA ENDS
CODE SEGMENT
	in eax
	mov a, eax
	in eax
	mov b, eax
debut_while_0:
	mov eax, 0
	push eax
	mov eax, b
	pop ebx
	sub ebx, eax
	jl vrai_jl_1
	mov eax, 0
	jmp fin_jl_1
vrai_jl_1:
	mov eax, 1
fin_jl_1:
	jz fin_while_0
	mov eax, a
	push eax
	mov eax, b
	pop ebx
	mov ecx, eax
	mov eax, ebx
	div ebx, ecx
	mul ebx, ecx
	sub eax, ebx
	mov aux, eax
	mov eax, b
	mov a, eax
	mov eax, aux
	mov b, eax
	jmp debut_while_0
fin_while_0:
	mov eax, a
	out eax
CODE ENDS
