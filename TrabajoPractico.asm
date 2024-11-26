.data
slist:      .word 0
clist:      .word 0
wclist:     .word 0
schedv:     .space 32

menu:       .asciiz "Colecciones de objetos categorizados\n" \
            "1) Nueva categoría\n" \
            "2) Siguiente categoría\n" \
            "3) Listar categorías\n" \
            "4) Borrar categoría actual\n" \
            "5) Anexar objeto a categoría actual\n" \
            "6) Listar objetos de categoría actual\n" \
            "7) Borrar un objeto de la categoría actual\n" \
            "0) Salir\n"

error:      .asciiz "Error: "
catName:    .asciiz "Ingrese el nombre de una categoría: "
selCat:     .asciiz "Se ha seleccionado la categoría: "
noCat:      .asciiz "No hay categorías disponibles.\n"
noCatToDelete: .asciiz "No hay categorías para borrar.\n"
objID:      .asciiz "Ingrese el ID del objeto a eliminar: "
done:       .asciiz "Operación realizada con éxito.\n"

.text
.globl main

main:
    la $t0, schedv
    li $t1, 8
    jal initialize

menu_loop:
    la $a0, menu
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $t2, $v0

    blt $t2, 0, invalid_option
    bge $t2, $t1, invalid_option

    sll $t3, $t2, 2
    lw $t4, schedv($t3)
    jalr $t4

    b menu_loop

invalid_option:
    la $a0, error
    li $v0, 4
    syscall
    b menu_loop

initialize:
    la $t0, slist
    sw $zero, 0($t0)
    la $t0, clist
    sw $zero, 0($t0)
    la $t0, wclist
    sw $zero, 0($t0)
    la $t0, schedv
    la $t1, newcategory
    sw $t1, 0($t0)
    la $t1, nextcategory
    sw $t1, 4($t0)
    la $t1, listcategories
    sw $t1, 8($t0)
    la $t1, deletecategory
    sw $t1, 12($t0)
    jr $ra

newcategory:
    jal smalloc
    move $t0, $v0
    beqz $t0, mem_error

    la $a0, catName
    li $v0, 4
    syscall

    la $a0, ($t0)
    li $a1, 16
    li $v0, 8
    syscall

    lw $t1, slist
    beqz $t1, first_category

    lw $t2, -4($t1)
    sw $t0, -4($t1)
    sw $t2, ($t0)
    b done_category

first_category:
    sw $t0, slist
    sw $t0, ($t0)
    sw $t0, -4($t0)
    sw $t0, clist

done_category:
    la $a0, done
    li $v0, 4
    syscall
    jr $ra

mem_error:
    la $a0, error
    li $v0, 4
    syscall
    jr $ra

nextcategory:
    lw $t0, clist
    beqz $t0, noCat

    lw $t1, ($t0)
    sw $t1, clist

    la $a0, selCat
    li $v0, 4
    syscall

    la $a0, ($t1)
    li $v0, 4
    syscall

    jr $ra

noCat:
    la $a0, noCat
    li $v0, 4
    syscall
    jr $ra

listcategories:
    lw $t0, slist
    beqz $t0, noCat

    move $t1, $t0

list_loop:
    la $a0, ($t1)
    li $v0, 4
    syscall

    lw $t1, ($t1)
    bne $t1, $t0, list_loop

    jr $ra

deletecategory:
    lw $t0, clist
    beqz $t0, noCatToDelete

    lw $t1, 4($t0)
    beqz $t1, skip_delete_objects

delete_objects_loop:
    lw $t2, ($t1)
    move $a1, $t1
    jal free
    move $t1, $t2
    bnez $t1, delete_objects_loop

skip_delete_objects:
    lw $t2, -4($t0)
    lw $t3, ($t0)

    beq $t2, $t0, single_category
    sw $t3, ($t2)
    sw $t2, -4($t3)
    sw $t3, clist
    b free_current_category

single_category:
    sw $zero, slist
    sw $zero, clist

free_current_category:
    move $a1, $t0
    jal free
    la $a0, done
    li $v0, 4
    syscall
    jr $ra

smalloc:
    li $a0, 16
    li $v0, 9
    syscall
    jr $ra

free:
    move $a0, $a1
    li $v0, 10
    syscall
    jr $ra
