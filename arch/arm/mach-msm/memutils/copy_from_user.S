/*
 *  linux/arch/arm/lib/copy_from_user.S
 *
 *  Author:	Nicolas Pitre
 *  Created:	Sep 29, 2005
 *  Copyright:	MontaVista Software, Inc.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2 as
 *  published by the Free Software Foundation.
 */

#include <linux/linkage.h>
#include <asm/assembler.h>

/*
 * Prototype:
 *
 *	size_t __copy_from_user(void *to, const void *from, size_t n)
 *
 * Purpose:
 *
 *	copy a block to kernel memory from user memory
 *
 * Params:
 *
 *	to = kernel memory
 *	from = user memory
 *	n = number of bytes to copy
 *
 * Return value:
 *
 *	Number of bytes NOT copied.
 */

#ifndef CONFIG_THUMB2_KERNEL
#define LDR1W_SHIFT	0
#else
#define LDR1W_SHIFT	1
#endif
#define STR1W_SHIFT	0

	.macro ldr1w ptr reg abort
	ldrusr	\reg, \ptr, 4, abort=\abort
	.endm

	.macro ldr4w ptr reg1 reg2 reg3 reg4 abort
	ldr1w \ptr, \reg1, \abort
	ldr1w \ptr, \reg2, \abort
	ldr1w \ptr, \reg3, \abort
	ldr1w \ptr, \reg4, \abort
	.endm

	.macro ldr8w ptr reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 abort
	ldr4w \ptr, \reg1, \reg2, \reg3, \reg4, \abort
	ldr4w \ptr, \reg5, \reg6, \reg7, \reg8, \abort
	.endm

	.macro ldr1b ptr reg cond=al abort
	ldrusr	\reg, \ptr, 1, \cond, abort=\abort
	.endm

	.macro str1w ptr reg abort
	W(str) \reg, [\ptr], #4
	.endm

	.macro str8w ptr reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 abort
	stmia \ptr!, {\reg1, \reg2, \reg3, \reg4, \reg5, \reg6, \reg7, \reg8}
	.endm

	.macro ldstr8w ptrl ptrw reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 abort
	ldr4w \ptrl, \reg1, \reg2, \reg3, \reg4, \abort
	ldr4w \ptrl, \reg5, \reg6, \reg7, \reg8, \abort
	stmia \ptrw!, {\reg1, \reg2, \reg3, \reg4, \reg5, \reg6, \reg7, \reg8}
	.endm

#ifdef CONFIG_USE_LDRDSTRD_OVER_LDMSTM
	.macro cpy8w dst src reg1 reg2 abort
	.irp offset, #0, #8, #16, #24
	ldr1w \src, \reg1, \abort
	ldr1w \src, \reg2, \abort
	strd \reg1, \reg2, [\dst, \offset]
	.endr
	add \dst, \dst, #32
	.endm
#endif

	.macro str1b ptr reg cond=al abort
	str\cond\()b \reg, [\ptr], #1
	.endm

	.macro enter reg1 reg2
	mov	r3, #0
	stmdb	sp!, {r0, r2, r3, \reg1, \reg2}
	.endm

	.macro exit reg1 reg2
	add	sp, sp, #8
	ldmfd	sp!, {r0, \reg1, \reg2}
	.endm

	.text

ENTRY(__copy_from_user)

#include "copy_template.S"

ENDPROC(__copy_from_user)

	.pushsection .fixup,"ax"
	.align 0
	copy_abort_preamble
	ldmfd	sp!, {r1, r2}
	sub	r3, r0, r1
	rsb	r1, r3, r2
	str	r1, [sp]
	bl	__memzero
	ldr	r0, [sp], #4
	copy_abort_end
	.popsection

