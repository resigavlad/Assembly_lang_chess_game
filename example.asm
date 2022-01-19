.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
scor dd '0','0','0','0','0','0','0','0','0','0','0','0'
i dd 0
i1 dd 0
j dd 0
j1 dd 0
k dd 0
l dd 0
a dd 0
b dd 0
comutator dd 0
elem dd 0
piesa dd 0
numar_elem dd 8
culoare_piesa dd 0
echipa_la_rand dd 1
last_selected_piece_i dd 0
last_selected_piece_j dd 0
miscare_completa dd 0

mat_joc db 4,3,2,6,5,2,3,4
		db 1,1,1,1,1,1,1,1
		db 0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0
		db 1,1,1,1,1,1,1,1
		db 4,3,2,6,5,2,3,4

mat_echipa db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 2,2,2,2,2,2,2,2
		   db 2,2,2,2,2,2,2,2
		   db 2,2,2,2,2,2,2,2
		   db 2,2,2,2,2,2,2,2
		   db 1,1,1,1,1,1,1,1
		   db 1,1,1,1,1,1,1,1
		   
mat_mutari db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0
		   db 0,0,0,0,0,0,0,0

window_title DB "Resiga Petre Vlad - Sah",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

piece_height EQU 48
piece_width EQU 48
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include piese.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
mark_possible_moves macro piesa , culoare_piesa , k , l
local mutare_pion,mutare_nebun,mutare_cal,mutare_tura,mutare_regina,mutare_rege,sfarsit_macro
	pusha
	
	cmp piesa,0
	je sfarsit_macro
	cmp piesa,1
	je mutare_pion
	cmp piesa,2
	je mutare_nebun
	cmp piesa,3
	je mutare_cal
	cmp piesa,4
	je mutare_tura
	cmp piesa,5
	je mutare_regina
	cmp piesa,6
	je mutare_rege
	
	mutare_pion:;mutari posibile pion
	
	cmp culoare_piesa,1
	je pion_merge_sus
	inc l
	inc l
	pion_merge_sus:
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp mat_joc[eax],0
	jne pion_nu_poate_inainta
	mov mat_mutari[eax],1
	
	pion_nu_poate_inainta:
	
	inc k
	mov eax,numar_elem
	mul l
	add eax,k
	push ebx
	mov ebx,culoare_piesa
	cmp mat_echipa[eax],2
	je pion_nu_poate_ataca_diagonala_dreapta
	cmp mat_echipa[eax],bl
	je pion_nu_poate_ataca_diagonala_dreapta
	mov mat_mutari[eax],1
	pion_nu_poate_ataca_diagonala_dreapta:
	pop ebx
	dec k
	dec k
	mov eax,numar_elem
	mul l
	add eax,k
	push ebx
	mov ebx,culoare_piesa
	cmp mat_echipa[eax],2
	je pion_nu_poate_ataca_diagonala_stanga
	cmp mat_echipa[eax],bl
	je pion_nu_poate_ataca_diagonala_stanga
	mov mat_mutari[eax],1
	pion_nu_poate_ataca_diagonala_stanga:
	pop ebx
	jmp sfarsit_macro;sfarsit mutari posibile pion
	
	mutare_nebun:;mutari posibile nebun
	
	mov ebx,k
	mov ecx,l
	nebun_stanga_sus:
		dec k
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_nebun_stanga_sus
		cmp k,0
		jl stop_nebun_stanga_sus
		cmp l,7
		ja stop_nebun_stanga_sus
		cmp l,0
		jl stop_nebun_stanga_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_nebun_stanga_sus
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je nebun_stanga_sus_lovit_oponent
		mov mat_mutari[eax],1
		jmp nebun_stanga_sus
	nebun_stanga_sus_lovit_oponent:
	mov mat_mutari[eax],1
	stop_nebun_stanga_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	nebun_dreapta_sus:
		inc k
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_nebun_dreapta_sus
		cmp k,0
		jl stop_nebun_dreapta_sus
		cmp l,7
		ja stop_nebun_dreapta_sus
		cmp l,0
		jl stop_nebun_dreapta_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_nebun_dreapta_sus
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je nebun_dreapta_sus_lovit_oponent
		mov mat_mutari[eax],1
		jmp nebun_dreapta_sus
	nebun_dreapta_sus_lovit_oponent:
	mov mat_mutari[eax],1
	stop_nebun_dreapta_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	nebun_stanga_jos:
		dec k
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_nebun_stanga_jos
		cmp k,0
		jl stop_nebun_stanga_jos
		cmp l,7
		ja stop_nebun_stanga_jos
		cmp l,0
		jl stop_nebun_stanga_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_nebun_stanga_jos
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je nebun_stanga_jos_lovit_oponent
		mov mat_mutari[eax],1
		jmp nebun_stanga_jos
	nebun_stanga_jos_lovit_oponent:
	mov mat_mutari[eax],1
	stop_nebun_stanga_jos:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	nebun_dreapta_jos:
		inc k
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_nebun_dreapta_jos
		cmp k,0
		jl stop_nebun_dreapta_jos
		cmp l,7
		ja stop_nebun_dreapta_jos
		cmp l,0
		jl stop_nebun_dreapta_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_nebun_dreapta_jos
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je nebun_dreapta_jos_lovit_oponent
		mov mat_mutari[eax],1
		jmp nebun_dreapta_jos
	nebun_dreapta_jos_lovit_oponent:
	mov mat_mutari[eax],1
	stop_nebun_dreapta_jos:
	mov k,ebx
	mov l,ecx
	jmp sfarsit_macro;sfarsit mutari posibile nebun
		
	mutare_cal:;mutari posibile cal
	
	mov ebx,k;mutare stanga jos
	mov ecx,l
	dec k
	dec k
	inc l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_stanga_jos
	cmp k,0
	jl cal_nu_merge_stanga_jos
	cmp l,7
	ja cal_nu_merge_stanga_jos
	cmp l,0
	jl cal_nu_merge_stanga_jos
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_stanga_jos
	mov mat_mutari[eax],1
	cal_nu_merge_stanga_jos:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare stanga sus
	mov ecx,l
	dec k
	dec k
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_stanga_sus
	cmp k,0
	jl cal_nu_merge_stanga_sus
	cmp l,7
	ja cal_nu_merge_stanga_sus
	cmp l,0
	jl cal_nu_merge_stanga_sus
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_stanga_sus
	mov mat_mutari[eax],1
	cal_nu_merge_stanga_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare dreapta jos
	mov ecx,l
	inc k
	inc k
	inc l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_dreapta_jos
	cmp k,0
	jl cal_nu_merge_dreapta_jos
	cmp l,7
	ja cal_nu_merge_dreapta_jos
	cmp l,0
	jl cal_nu_merge_dreapta_jos
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_dreapta_jos
	mov mat_mutari[eax],1
	cal_nu_merge_dreapta_jos:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare dreapta sus
	mov ecx,l
	inc k
	inc k
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_dreapta_sus
	cmp k,0
	jl cal_nu_merge_dreapta_sus
	cmp l,7
	ja cal_nu_merge_dreapta_sus
	cmp l,0
	jl cal_nu_merge_dreapta_sus
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_dreapta_sus
	mov mat_mutari[eax],1
	cal_nu_merge_dreapta_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare sus stanga
	mov ecx,l
	dec l
	dec l
	dec k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_sus_stanga
	cmp k,0
	jl cal_nu_merge_sus_stanga
	cmp l,7
	ja cal_nu_merge_sus_stanga
	cmp l,0
	jl cal_nu_merge_sus_stanga
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_sus_stanga
	mov mat_mutari[eax],1
	cal_nu_merge_sus_stanga:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare sus dreapta
	mov ecx,l
	dec l
	dec l
	inc k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_sus_dreapta
	cmp k,0
	jl cal_nu_merge_sus_dreapta
	cmp l,7
	ja cal_nu_merge_sus_dreapta
	cmp l,0
	jl cal_nu_merge_sus_dreapta
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_sus_dreapta
	mov mat_mutari[eax],1
	cal_nu_merge_sus_dreapta:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare jos stanga
	mov ecx,l
	inc l
	inc l
	dec k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_jos_stanga
	cmp k,0
	jl cal_nu_merge_jos_stanga
	cmp l,7
	ja cal_nu_merge_jos_stanga
	cmp l,0
	jl cal_nu_merge_jos_stanga
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_jos_stanga
	mov mat_mutari[eax],1
	cal_nu_merge_jos_stanga:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;mutare jos dreapta
	mov ecx,l
	inc l
	inc l
	inc k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja cal_nu_merge_jos_dreapta
	cmp k,0
	jl cal_nu_merge_jos_dreapta
	cmp l,7
	ja cal_nu_merge_jos_dreapta
	cmp l,0
	jl cal_nu_merge_jos_dreapta
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je cal_nu_merge_jos_dreapta
	mov mat_mutari[eax],1
	cal_nu_merge_jos_dreapta:
	mov k,ebx
	mov l,ecx
	jmp sfarsit_macro;sfarsit mutari posibile cal
	
	mutare_tura:;mutari posibile tura
	
	mov ebx,k
	mov ecx,l
	tura_dreapta:
		inc k
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_tura_dreapta
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_tura_dreapta
		xor edx,1
		cmp mat_echipa[eax],dl
		je tura_dreapta_lovit_inamic
		mov mat_mutari[eax],1
		jmp tura_dreapta
	tura_dreapta_lovit_inamic:
	mov mat_mutari[eax],1
	stop_tura_dreapta:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	tura_stanga:
		dec k
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,0
		jl stop_tura_stanga
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_tura_stanga
		xor edx,1
		cmp mat_echipa[eax],dl
		je tura_stanga_lovit_inamic
		mov mat_mutari[eax],1
		jmp tura_stanga
	tura_stanga_lovit_inamic:
	mov mat_mutari[eax],1
	stop_tura_stanga:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	tura_sus:
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp l,0
		jl stop_tura_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_tura_sus
		xor edx,1
		cmp mat_echipa[eax],dl
		je tura_sus_lovit_inamic
		mov mat_mutari[eax],1
		jmp tura_sus
	tura_sus_lovit_inamic:
	mov mat_mutari[eax],1
	stop_tura_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	tura_jos:
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp l,7
		ja stop_tura_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_tura_jos
		xor edx,1
		cmp mat_echipa[eax],dl
		je tura_jos_lovit_inamic
		mov mat_mutari[eax],1
		jmp tura_jos
	tura_jos_lovit_inamic:
	mov mat_mutari[eax],1
	stop_tura_jos:
	mov k,ebx
	mov l,ecx
	jmp sfarsit_macro;stop mutari posibile tura
	
	mutare_regina:;mutari posibile regina
	
	mov ebx,k
	mov ecx,l
	regina_stanga_sus:
		dec k
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_regina_stanga_sus
		cmp k,0
		jl stop_regina_stanga_sus
		cmp l,7
		ja stop_regina_stanga_sus
		cmp l,0
		jl stop_regina_stanga_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_stanga_sus
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_stanga_sus_lovit_oponent
		mov mat_mutari[eax],1
		jmp regina_stanga_sus
	regina_stanga_sus_lovit_oponent:
	mov mat_mutari[eax],1
	stop_regina_stanga_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_dreapta_sus:
		inc k
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_regina_dreapta_sus
		cmp k,0
		jl stop_regina_dreapta_sus
		cmp l,7
		ja stop_regina_dreapta_sus
		cmp l,0
		jl stop_regina_dreapta_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_dreapta_sus
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_dreapta_sus_lovit_oponent
		mov mat_mutari[eax],1
		jmp regina_dreapta_sus
	regina_dreapta_sus_lovit_oponent:
	mov mat_mutari[eax],1
	stop_regina_dreapta_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_stanga_jos:
		dec k
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_regina_stanga_jos
		cmp k,0
		jl stop_regina_stanga_jos
		cmp l,7
		ja stop_regina_stanga_jos
		cmp l,0
		jl stop_regina_stanga_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_stanga_jos
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_stanga_jos_lovit_oponent
		mov mat_mutari[eax],1
		jmp regina_stanga_jos
	regina_stanga_jos_lovit_oponent:
	mov mat_mutari[eax],1
	stop_regina_stanga_jos:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_dreapta_jos:
		inc k
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_regina_dreapta_jos
		cmp k,0
		jl stop_regina_dreapta_jos
		cmp l,7
		ja stop_regina_dreapta_jos
		cmp l,0
		jl stop_regina_dreapta_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_dreapta_jos
		mov edx,culoare_piesa
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_dreapta_jos_lovit_oponent
		mov mat_mutari[eax],1
		jmp regina_dreapta_jos
	regina_dreapta_jos_lovit_oponent:
	mov mat_mutari[eax],1
	stop_regina_dreapta_jos:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_dreapta:
		inc k
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,7
		ja stop_regina_dreapta
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_dreapta
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_dreapta_lovit_inamic
		mov mat_mutari[eax],1
		jmp regina_dreapta
	regina_dreapta_lovit_inamic:
	mov mat_mutari[eax],1
	stop_regina_dreapta:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_stanga:
		dec k
		mov eax,numar_elem
		mul l
		add eax,k
		cmp k,0
		jl stop_regina_stanga
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_stanga
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_stanga_lovit_inamic
		mov mat_mutari[eax],1
		jmp regina_stanga
	regina_stanga_lovit_inamic:
	mov mat_mutari[eax],1
	stop_regina_stanga:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_sus:
		dec l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp l,0
		jl stop_regina_sus
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_sus
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_sus_lovit_inamic
		mov mat_mutari[eax],1
		jmp regina_sus
	regina_sus_lovit_inamic:
	mov mat_mutari[eax],1
	stop_regina_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k
	mov ecx,l
	regina_jos:
		inc l
		mov eax,numar_elem
		mul l
		add eax,k
		cmp l,7
		ja stop_regina_jos
		mov edx,culoare_piesa
		cmp mat_echipa[eax],dl
		je stop_regina_jos
		xor edx,1
		cmp mat_echipa[eax],dl
		je regina_jos_lovit_inamic
		mov mat_mutari[eax],1
		jmp regina_jos
	regina_jos_lovit_inamic:
	mov mat_mutari[eax],1
	stop_regina_jos:
	mov k,ebx
	mov l,ecx
	jmp sfarsit_macro;stop mutari posibile regina
	
	mutare_rege:;mutari posibile rege
	
	mov ebx,k;rege stanga
	mov ecx,l
	dec k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,0
	jl rege_nu_merge_stanga
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_stanga
	mov mat_mutari[eax],1
	rege_nu_merge_stanga:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege stanga sus
	mov ecx,l
	dec k
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,0
	jl rege_nu_merge_stanga_sus
	cmp l,0
	jl rege_nu_merge_stanga_sus
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_stanga_sus
	mov mat_mutari[eax],1
	rege_nu_merge_stanga_sus:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege stanga jos
	mov ecx,l
	dec k
	inc l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,0
	jl rege_nu_merge_stanga_jos
	cmp l,7
	ja rege_nu_merge_stanga_jos
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_stanga_jos
	mov mat_mutari[eax],1
	rege_nu_merge_stanga_jos:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege dreapta
	mov ecx,l
	inc k
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja rege_nu_merge_dreapta
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_dreapta
	mov mat_mutari[eax],1
	rege_nu_merge_dreapta:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege dreapta sus
	mov ecx,l
	inc k
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja rege_nu_merge_dreapta_sus
	cmp l,0
	jl rege_nu_merge_dreapta_sus
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_dreapta_sus
	mov mat_mutari[eax],1
	rege_nu_merge_dreapta_sus:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege dreapta jos
	mov ecx,l
	inc k
	inc l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp k,7
	ja rege_nu_merge_dreapta_jos
	cmp l,7
	ja rege_nu_merge_dreapta_jos
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_dreapta_jos
	mov mat_mutari[eax],1
	rege_nu_merge_dreapta_jos:
	mov k,ebx
	mov l,ecx
	;jmp sfarsit_macro
	
	mov ebx,k;rege sus
	mov ecx,l
	dec l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp l,0
	jl rege_nu_merge_sus
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_sus
	mov mat_mutari[eax],1
	rege_nu_merge_sus:
	mov k,ebx
	mov l,ecx
	
	mov ebx,k;rege jos
	mov ecx,l
	inc l
	mov eax,numar_elem
	mul l
	add eax,k
	cmp l,7
	ja rege_nu_merge_jos
	mov edx,culoare_piesa
	cmp mat_echipa[eax],dl
	je rege_nu_merge_jos
	mov mat_mutari[eax],1
	rege_nu_merge_jos:
	mov k,ebx
	mov l,ecx
	jmp sfarsit_macro;sfarsit mutari posibile rege
	sfarsit_macro:
	popa
endm

draw_piece proc
	push ebp
	mov ebp, esp
	pusha
	
	lea esi,piese
	mov eax, [ebp+arg1]
	mov ebx, piece_width
	mul ebx
	mov ebx, piece_height
	mul ebx
	add esi, eax
	mov ecx, piece_height
bucla_simbol_linii1:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, piece_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, piece_width
bucla_simbol_coloane1:
	cmp byte ptr [esi], 0
	je simbol_pixel_next1
	cmp culoare_piesa,0
	je color_black_piece
	mov dword ptr [edi], 0FFCF9Fh
	jmp simbol_pixel_next1
	color_black_piece:
	mov dword ptr [edi], 0h
	jmp simbol_pixel_next1
simbol_pixel_next1:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane1
	pop ecx
	loop bucla_simbol_linii1
	popa
	mov esp, ebp
	pop ebp
	ret
draw_piece endp

draw_piece_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call draw_piece
	add esp, 16
endm

draw_vertical_line macro area , x , y , lenght , color
local start_loop , end_loop
	push eax
	push ecx
	push ebx
	
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	;mov ecx,lenght
	xor ecx,ecx
	start_loop:
		add eax,2559
		mov ebx,area
		add ebx,ecx
		mov dword ptr [ebx+eax] , color
		inc ecx
		inc ecx
		cmp ecx,lenght
		je end_loop
		loop start_loop
	end_loop:
	pop ebx
	pop ecx
	pop eax
endm

draw_horisontal_line macro area , x , y , lenght , color
local start_loop , end_loop
	push eax
	push ecx
	push ebx
	
	mov eax,x
	mov ebx,area_width
	mul ebx
	add eax,y
	shl eax,2
	xor ecx,ecx
	start_loop:
		mov ebx,area
		add ebx,ecx
		mov dword ptr [ebx+eax] , color
		inc ecx
		inc ecx
		cmp ecx,lenght
		je end_loop
		loop start_loop
	end_loop:
	pop ebx
	pop ecx
	pop eax
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

draw_score_board proc ; desenez in dreapta scorul jucatorilor
	mov culoare_piesa,0
	draw_piece_macro 0 , area , 420, 100
	draw_piece_macro 1 , area , 420, 160
	draw_piece_macro 2 , area , 420, 220
	draw_piece_macro 3 , area , 420, 280
	draw_piece_macro 4 , area , 420, 340
	draw_piece_macro 5 , area , 420, 400
	make_text_macro 'X' , area , 470 , 120
	make_text_macro 'X' , area , 470 , 180
	make_text_macro 'X' , area , 470 , 240
	make_text_macro 'X' , area , 470 , 300
	make_text_macro 'X' , area , 470 , 360
	make_text_macro 'X' , area , 470 , 420
	make_text_macro [scor+0] , area , 490 , 120
	make_text_macro [scor+4] , area , 490 , 180
	make_text_macro [scor+8] , area , 490 , 240
	make_text_macro [scor+12] , area , 490 , 300
	make_text_macro [scor+16] , area , 490 , 360
	make_text_macro [scor+20] , area , 490 , 420
	mov culoare_piesa,1
	draw_piece_macro 0 , area , 540, 100
	draw_piece_macro 1 , area , 540, 160
	draw_piece_macro 2 , area , 540, 220
	draw_piece_macro 3 , area , 540, 280
	draw_piece_macro 4 , area , 540, 340
	draw_piece_macro 5 , area , 540, 400
	make_text_macro 'X' , area , 590 , 120
	make_text_macro 'X' , area , 590 , 180
	make_text_macro 'X' , area , 590 , 240
	make_text_macro 'X' , area , 590 , 300
	make_text_macro 'X' , area , 590 , 360
	make_text_macro 'X' , area , 590 , 420
	make_text_macro [scor+24] , area , 610 , 120
	make_text_macro [scor+28] , area , 610 , 180
	make_text_macro [scor+32] , area , 610 , 240
	make_text_macro [scor+36] , area , 610 , 300
	make_text_macro [scor+40] , area , 610 , 360
	make_text_macro [scor+44] , area , 610 , 420
	ret
draw_score_board endp

draw_square proc ; desenez un patrat
	push ebp
	mov ebp, esp
	pusha
	draw_text:
	mov ebx, 48
	mul ebx
	mov ebx, 48
	mul ebx
	add esi, eax
	mov ecx, 48
bucla_simbol_linii:
	mov edi, [ebp+8] ; pointer la matricea de pixeli
	mov eax, [ebp+16] ; pointer la coord y
	add eax, 48
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+12] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, 48
bucla_simbol_coloane:
	mov edx,[ebp+20]
	mov dword ptr [edi], edx
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	pop ebp
	ret
draw_square endp

draw_square_macro macro area , x , y , color
	push color
	push y
	push x
	push area
	call draw_square
	add esp,16
endm

write_message proc
	push ebp
	mov ebp,esp
	pusha
	make_text_macro 'E' , area , 450 , 50
	make_text_macro 'S' , area , 460 , 50
	make_text_macro 'T' , area , 470 , 50
	make_text_macro 'E' , area , 480 , 50
	make_text_macro ' ' , area , 490 , 50
	make_text_macro 'R' , area , 500 , 50
	make_text_macro 'I' , area , 510 , 50
	make_text_macro 'N' , area , 520 , 50
	make_text_macro 'D' , area , 530 , 50
	make_text_macro 'U' , area , 540 , 50
	make_text_macro 'L' , area , 550 , 50
	make_text_macro ' ' , area , 560 , 50
	make_text_macro 'L' , area , 570 , 50
	make_text_macro 'U' , area , 580 , 50
	make_text_macro 'I' , area , 590 , 50
	make_text_macro ' ' , area , 600 , 50
	
	;scriu a carui echipa este randul
	mov eax,[ebp+8]
	cmp eax,1
	je afiseaza_echipa_alba
	make_text_macro 'N' , area , 500 , 72
	make_text_macro 'E' , area , 510 , 72
	make_text_macro 'G' , area , 520 , 72
	make_text_macro 'R' , area , 530 , 72
	make_text_macro 'U' , area , 540 , 72
	jmp finish_afisare_echipa
	afiseaza_echipa_alba:
	make_text_macro ' ' , area , 500 , 72
	make_text_macro 'A' , area , 510 , 72
	make_text_macro 'L' , area , 520 , 72
	make_text_macro 'B' , area , 530 , 72
	make_text_macro ' ' , area , 540 , 72
	finish_afisare_echipa:
	
	;scriu titlul
	make_text_macro 'C' , area , 240 , 10
	make_text_macro 'H' , area , 250 , 10
	make_text_macro 'E' , area , 260 , 10
	make_text_macro 'S' , area , 270 , 10
	make_text_macro 'S' , area , 280 , 10
	make_text_macro 'M' , area , 300 , 10
	make_text_macro 'A' , area , 310 , 10
	make_text_macro 'S' , area , 320 , 10
	make_text_macro 'T' , area , 330 , 10
	make_text_macro 'E' , area , 340 , 10
	make_text_macro 'R' , area , 350 , 10
	popa
	pop ebp
	ret
write_message endp

write_message_macro macro echipa_la_rand
	push echipa_la_rand
	call write_message
	add esp,8
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	push eax
	push ebx
	mov eax,[ebp+12]
	mov ebx,[ebp+16]
	cmp eax,11
	jl finish_evt_click
	cmp eax,400
	ja finish_evt_click
	cmp ebx,51
	jl finish_evt_click
	cmp ebx,440
	ja finish_evt_click
	
	push ecx
	push edx
	xor edx,edx
	mov ecx,59
	find_i:
		cmp eax,ecx
		jl finish_find_i
		add ecx,50
		inc edx
		jmp find_i
	finish_find_i:
	mov i,edx
	xor edx,edx
	mov ecx,99
	find_j:
		cmp ebx,ecx
		jl finish_find_j
		add ecx,50
		inc edx
		jmp find_j
	finish_find_j:
	mov j,edx
	pop edx
	pop ecx
	push eax
	mov eax,numar_elem
	mul j
	add eax,i
	push edx
	xor edx,edx
	
	cmp mat_mutari[eax],0
	je nu_se_muta_piesa
	push ecx
	mov ecx,i
	mov i1,ecx
	mov ecx,j
	mov j1,ecx
	pop ecx
	push ebx
	push eax
	mov eax,numar_elem
	mul j
	add eax,i
	mov ebx,eax
	pop eax
	push edx
	push eax
	mov eax,numar_elem
	mul last_selected_piece_j
	add eax,last_selected_piece_i
	mov edx,eax
	pop eax
	push ecx
	xor ecx,ecx
	mov cl,mat_joc[edx]
	push eax
	xor eax,eax
	mov al,mat_joc[ebx]
	mov a,eax
	pop eax
	mov mat_joc[ebx],cl
	xor ecx,ecx
	mov cl,mat_echipa[edx]
	push eax
	xor eax,eax
	mov al,mat_echipa[ebx]
	mov b,eax
	pop eax
	mov mat_echipa[ebx],cl
	mov mat_echipa[edx],2
	mov mat_joc[edx],0
	pop edx
	pop ecx
	pop ebx
	mov miscare_completa,1
	push eax
	mov eax,i
	mov last_selected_piece_i,eax
	mov eax,j
	mov last_selected_piece_j,eax
	pop eax
	cmp b,1
	ja nu_a_fost_luata_pieasa
	mov eax,6
	mul b
	add eax,a
	dec eax
	mov ebx,4
	mul ebx
	
	add [scor+eax],1
	nu_a_fost_luata_pieasa:
	
	nu_se_muta_piesa:
	mov i1,0;fomatez matricea de miscari posibile
	format_mat_mutari1:
		mov j1,0
		format_mat_mutari12:
		push eax
		mov eax,numar_elem
		mul j1
		add eax,i1
		mov mat_mutari[eax],0
		pop eax
		inc j1
		cmp j1,8
		jl format_mat_mutari12
	inc i1
	cmp i1,8
	jl format_mat_mutari1;termin formatat
	
	;nu_formatez:
	; cmp miscare_completa,1
	; je finish_evt_click
	pusha
	mov ecx,i
	mov last_selected_piece_i,ecx
	;mov k,ecx
	mov edx,j
	mov last_selected_piece_j,edx
	;mov l,edx
	popa
	
	mov dl,mat_echipa[eax]
	mov culoare_piesa,edx
	xor edx,edx
	
	mov dl,mat_joc[eax]
	mov piesa,edx
	pop edx
	pop eax
	
	cmp miscare_completa,1
	je finish_evt_click
	
	cmp piesa,0
	je finish_evt_click;nu exista piesa in patratelul selectat
	push ecx
	mov ecx,echipa_la_rand
	cmp culoare_piesa,ecx
	pop ecx
	jne finish_evt_click;nu este randul echipei pe care am dat click
	
	;aici scriu cod pentru piese alese corect
	pusha
	mov ecx,i
	;mov last_selected_piece_i,ecx
	mov k,ecx
	mov edx,j
	;mov last_selected_piece_j,edx
	mov l,edx
	popa
	
	mark_possible_moves piesa , culoare_piesa , k , l
	
	finish_evt_click: ; sare aici daca click-ul nu se incadreaza in tabla
	cmp miscare_completa,0
	je nu_schimb_echipa_la_rand
	xor echipa_la_rand,1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov i1,0;fomatez matricea de miscari posibile
	format_mat_mutari10:
		mov j1,0
		format_mat_mutari6:
		push eax
		push ebx
		mov eax,numar_elem
		mul i1
		add eax,j1
		xor ebx,ebx
		mov mat_mutari[eax],bl
		pop ebx
		pop eax
		inc j1
		cmp j1,8
		jl format_mat_mutari6
	inc i1
	cmp i1,8
	jl format_mat_mutari10;termin formatat
	nu_schimb_echipa_la_rand:
	mov miscare_completa,0
	pop ebx
	pop eax
	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:
	call draw_score_board
	write_message_macro echipa_la_rand
	
	;afisez grid line-ul
	push eax
	push ecx
	
	mov eax,50
	mov ecx,9
	loop_horisontal_lines:
		draw_horisontal_line area , eax , 10 , 1600 , 0h
		inc eax
		draw_horisontal_line area , eax , 10 , 1600 , 0h
		dec eax
		add eax,50
		loop loop_horisontal_lines
	
	push edi
	mov edi,10
	mov ecx,9
	loop_vertical_lines:
		draw_vertical_line area, edi , 50 ,401 ,0h
		inc edi
		draw_vertical_line area , edi , 50 , 401 , 0h
		dec edi
		add edi,50
		loop loop_vertical_lines
	pop edi
	pop ecx
	pop eax

	;desenez patratelele
	push eax ; tine coordonata x
	push ebx ; tine coordonata y
	push ecx ; contor pt for pt colorare
	
	mov comutator,0
	mov i,0
	for1:
		mov j,0
		for2:
		mov eax,50
		mul j
		add eax,50
		mov ebx,eax
		mov eax,50
		mul i
		add eax,10
		add eax,2
		add ebx,2
		
		mov a,eax
		mov b,ebx
		mov ecx,48
		xor comutator,1
		cmp comutator,1
		je pun_patratel_alb
		draw_square_macro area , a , b , 0c8c8c8h
		jmp pus_patratel_gri
		pun_patratel_alb:
		draw_square_macro area , a , b , 0FFFFFFh
		pus_patratel_gri:
		
		mov eax,numar_elem
		mul j
		add eax,i
		cmp mat_mutari[eax],0
		je nu_pun_mutare_posibila
		draw_square_macro area , a , b , 0FF0000h
		nu_pun_mutare_posibila:
				
		;desenez piesele
		push eax
		mov eax,j
		mul numar_elem
		add eax,i
		push edx
		xor edx,edx
		mov dl,mat_joc[eax]
		push ebx
		xor ebx,ebx
		mov bl,mat_echipa[eax]
		mov culoare_piesa,ebx
		pop ebx
		mov elem,edx
		pop edx
		pop eax
		cmp elem,0
		je skip_piece;sar peste colorat piese daca in acel patratel nu exista nici una
		sub elem,1
		draw_piece_macro elem , area , a , b
		skip_piece:
		
		inc j
		cmp j,8
		jl for2
	xor comutator,1
	inc i
	cmp i,8
	jl for1	
	
	pop ecx
	pop ebx
	pop eax
	
;finish draw
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
