# Processeur RISC-V monocycle en Verilog

Un petit processeur RISC-V 32 bits **monocycle** (une instruction par cycle d'horloge) décrit en Verilog,
avec un mini-assembleur en Python et un banc de test **auto-vérifiant**.

## Instructions prises en charge

`add`, `sub`, `and`, `or`, `addi`, `lw`, `sw`, `beq` (format RV32I).

## Architecture

Le chemin de données est le chemin monocycle classique : compteur de programme, mémoire d'instructions,
banc de registres, unité de contrôle (décodeur principal et décodeur d'ALU), ALU, extension de l'immédiat,
mémoire de données et multiplexeurs.

| Fichier | Rôle |
|---|---|
| `mono_cycle_top.v` | module de plus haut niveau, relie tous les blocs |
| `program_counter.v`, `add4.v`, `add2.v` | compteur de programme, PC + 4, calcul de l'adresse de branchement |
| `instruction_memory.v` | mémoire d'instructions (128 mots), chargée depuis `program.hex` |
| `Reg_file.v` | banc de 32 registres (x0 vaut toujours 0). Au démarrage de la simulation, quelques registres reçoivent des valeurs fixes pour le test : x1 = 11, x3 = 2, x4 = 7, x8 = 8, x16 = 2, x25 = 5 |
| `RISCV_Controller.v`, `maindec_simple.v`, `aludec_simple.v` | unité de contrôle |
| `alu.v` | unité arithmétique et logique (add, sub, and, or) |
| `Extended.v` | extension de l'immédiat (type I, S et branchement) |
| `data_memory.v` | mémoire de données |
| `Multiplexer.v` | multiplexeurs |
| `tb_selfcheck.v` | banc de test auto-vérifiant (PASS / FAIL) |
| `tb.v` | banc de test simple : affiche à chaque cycle le compteur de programme, l'instruction et le résultat |
| `asm.py`, `program.asm`, `program.hex` | mini-assembleur, programme de test et son code machine |

## Lancer la simulation

Avec Icarus Verilog (dans ce dossier, `program.hex` doit s'y trouver) :

```
iverilog -g2012 -s tb_selfcheck -o sim *.v
vvp sim
```

Résultat obtenu (Icarus Verilog 12) :

```
PASS  x0 (x0 reste a 0) = 0
PASS  x13 (add) = 7
PASS  x14 (sub) = 6
PASS  x15 (and) = 3
PASS  x17 (or) = 15
PASS  x18 (addi) = 20
PASS  x19 (addi negatif) = 15
PASS  x20 (lw) = 11
PASS  x21 (saute par beq) = 0
PASS  x22 (beq non pris) = 1
PASS  x23 (boucle beq) = 0
PASS  x24 (saut avant de 64 octets) = 0
PASS  x26 (arrivee apres le saut) = 7
PASS  memory[1] (sw) = 11
TEST PASSED : toutes les verifications sont bonnes
```

L'avertissement `$readmemh ... Not enough words` est sans conséquence : le programme est plus court que la mémoire.

## Ce que vérifie le banc de test

Le programme de test (`program.asm`) exécute chaque instruction, un `sw` suivi d'un `lw`, un `beq` pris et un `beq` non pris,
une petite boucle construite avec `beq` et un saut en avant de 64 octets. À la fin, le banc compare les registres et la
mémoire aux valeurs attendues et affiche PASS ou FAIL pour chacun. Un chien de garde arrête la simulation si le
programme ne se termine pas.

## Changer le programme

Écrire les instructions dans `program.asm`, puis :

```
python3 asm.py program.asm program.hex
```

## Limites connues

- Vérifié en simulation uniquement ; la synthèse sur FPGA n'a pas été refaite sur cette version.
- Le bit 11 de la constante de branchement n'est pas testé (la mémoire d'instructions ne fait que 128 mots).
- Seules 8 instructions sont prises en charge : pas de décalages, de comparaisons ni de sauts `jal` / `jalr`.
