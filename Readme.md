# TP Compilation : Génération de code pour un sous ensemble du langage λ-ada.

À partir de l'arbre abstrait construit lors du dernier TP, avec les outils JFlex et CUP, l'objectif consiste à générer du code pour la machine à registres décrite dans le cours, afin d'être en mesure d'exécuter les programmes reconnus par l'analyseur sur la machine à registres.

## Exercice 1 :

Dans la première partie du tp on pourra se limiter à la génération de code pour les expressions arithmétiques sur les nombres entiers.

Ainsi, l'expression

```
let prixHt = 200;
let prixTtc =  prixHt * 119 / 100 .
```
correspondant, par exemple, à l'arbre ci-dessous pourrait amener à la production du code suivant :

```
DATA SEGMENT
	prixHt DD
	prixTtc DD
DATA ENDS
CODE SEGMENT
	mov eax, 200
	mov prixHt, eax
	mov eax, prixHt
	push eax
	mov eax, 119
	pop ebx
	mul eax, ebx
	push eax
	mov eax, 100
	pop ebx
	div ebx, eax
	mov eax, ebx
	mov prixTtc, eax
CODE ENDS
```
```
; ──┬── LET ──┬── prixHt
    │         │   
    │         └── 200
    │   
    └── LET ──┬── prixTtc
              │   
              └── / ──┬── * ──┬── prixHt
                      │       │   
                      │       └── 119
                      │   
                      └── 100
```

## Exercice 2 :

Étendre la génération de code aux opérateurs booléens, de comparaison, aux boucles et aux conditionnelles, correspondant au sous-ensemble du langage **λ-ada** utilisé pour le TP précédent.

Exemple de code source pour le compilateur : calcul de PGCD.

```
let a = input;
let b = input;
while (0 < b)
do (let aux=(a mod b); let a=b; let b=aux );
output a
.
```
Et un exemple de code qui pourrait être produit :

```
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
```
## Exemple avec une fonction récursive

PGCD avec une fonction récursive :

```
let x = input;
let y = input;
let pgcd = 
  lambda (a, b) (
    if (0 < b) then pgcd(b, a mod b) else a
  );
let z = output pgcd(x, y);
output z
.
```

Code généré :

```
DATA SEGMENT
	x DD
	y DD
	pgcd DD
	z DD
DATA ENDS
CODE SEGMENT
	in eax
	mov x, eax
	in eax
	mov y, eax
	lea eax, lambda_0
	mov pgcd, eax
	mov eax, pgcd
	push eax
	mov eax, x
	push eax
	mov eax, y
	push eax
	mov eax, 8[esp]
	call eax
	add esp, 8
	pop eax
	out eax
	mov z, eax
	mov eax, z
	out eax
	jmp end_pg_4
lambda_0:
	enter 0
	mov eax, 0
	push eax
	mov eax, 8[ebp]
	pop ebx
	sub ebx, eax
	jl vrai_jl_1
	mov eax, 0
	jmp fin_jl_1
vrai_jl_1:
	mov eax, 1
fin_jl_1:
	jz else_2
	mov eax, pgcd
	push eax
	mov eax, 8[ebp]
	push eax
	mov eax, 12[ebp]
	push eax
	mov eax, 8[ebp]
	pop ebx
	mov ecx, eax
	mov eax, ebx
	div ebx, ecx
	mul ebx, ecx
	sub eax, ebx
	push eax
	mov eax, 8[esp]
	call eax
	add esp, 8
	pop eax
	jmp fin_if_2
else_2:
	mov eax, 12[ebp]
fin_if_2:
	mov 16[ebp], eax
	leave
	ret
end_pg_4:
CODE ENDS
```

Arbre abstrait généré (sans le calcul de type) :

```
; ──┬── LET ──┬── x
    │         │
    │         └── INPUT
    │
    └── ; ──┬── LET ──┬── y
            │         │
            │         └── INPUT
            │
            └── ; ──┬── LET ──┬── pgcd
                    │         │
                    │         └── LAMBDA ──┬── , ──┬── a
                    │                      │       │
                    │                      │       └── b
                    │                      │
                    │                      └── IF ──┬── < ──┬── 0
                    │                               │       │
                    │                               │       └── b
                    │                               │
                    │                               └── THEN ──┬── FCALL ──┬── pgcd
                    │                                          │           │
                    │                                          │           └── , ──┬── b
                    │                                          │                   │
                    │                                          │                   └── MOD ──┬── a
                    │                                          │                             │
                    │                                          │                             └── b
                    │                                          │
                    │                                          └── a
                    │
                    └── ; ──┬── LET ──┬── z
                            │         │
                            │         └── OUTPUT ───── FCALL ──┬── pgcd
                            │                                  │
                            │                                  └── , ──┬── x
                            │                                          │
                            │                                          └── y
                            │
                            └── OUTPUT ───── z
```

Arbre abstrait généré (avec le calcul de type) :

```
; INT ──┬── LET INT ──┬── x INT
        │             │
        │             └── INPUT INT
        │
        └── ; INT ──┬── LET INT ──┬── y INT
                    │             │
                    │             └── INPUT INT
                    │
                    └── ; INT ──┬── LET f0:(INTxINT-->INT) ──┬── pgcd f0:(INTxINT-->INT)
                                │                            │
                                │                            └── LAMBDA f1:(INTxINT-->INT) ──┬── , INTxINT ──┬── a[12] INT
                                │                                                            │               │
                                │                                                            │               └── b[8] INT
                                │                                                            │
                                │                                                            └── IF INT ──┬── < BOOL ──┬── 0 INT
                                │                                                                         │            │
                                │                                                                         │            └── b[8] INT
                                │                                                                         │
                                │                                                                         └── THEN INT ──┬── FCALL INT ──┬── pgcd f0:(INTxINT-->INT)
                                │                                                                                        │               │
                                │                                                                                        │               └── , INTxINT ──┬── b[8] INT
                                │                                                                                        │                               │
                                │                                                                                        │                               └── MOD INT ──┬── a[12] INT
                                │                                                                                        │                                             │
                                │                                                                                        │                                             └── b[8] INT
                                │                                                                                        │
                                │                                                                                        └── a[12] INT
                                │
                                └── ; INT ──┬── LET INT ──┬── z INT
                                            │             │
                                            │             └── OUTPUT INT ───── FCALL INT ──┬── pgcd f0:(INTxINT-->INT)
                                            │                                              │
                                            │                                              └── , INTxINT ──┬── x INT
                                            │                                                              │
                                            │                                                              └── y INT
                                            │
                                            └── OUTPUT INT ───── z INT
```

## Émulateur pour la machine à pile

Vous trouverez un émulateur pour la machine à registres ici : [vm-0.9.jar](./vm-0.9.jar).

Il s'utilise de la façon suivante :

`java -jar vm-0.9.jar pgcd.asm`

ou

`java -jar vm-0.9.jar pgcd.asm --debug`

## À rendre :

À la fin du tp, vous ferez une présentation intermédiaire de votre compilateur, de l'ordre de 5 minutes, à l'enseignant qui vous encadre en tp.

Avant le 10 mars 2025, vous enverrez par mail (mettre **INFO805 - compilation** dans le sujet du mail) à l'enseignant qui vous encadre (Stephane.Talbot@univ-smb.fr) votre tp, sous la forme d'un lien vers un dépot git, dont la branche principale devra comprendre un petit compte-rendu (un readme par exemple) avec des exemples bien choisis de génération de code et l'ensemble de vos fichiers source.

**Important :** Le compte-rendu et le mail devront indiquer clairement le nom du ou des auteurs (s'il a été fait en binôme) du TP. 
