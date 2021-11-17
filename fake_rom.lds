OUTPUT_ARCH( "riscv" )

_STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 0x1000;

/*****************************************************************************
 * Define memory layout
 ****************************************************************************/
MEMORY {
	ram (rwxa) : ORIGIN = 0x8400, LENGTH = 512K
}

/* Specify the default entry point to the program */

ENTRY(_mstart)

/*****************************************************************************
 * Define the sections, and where they are mapped in memory 
 ****************************************************************************/
SECTIONS {
	.text : {
	    *boot.o(.text);
		*(.text);
		*(.text.*);
	} > ram

	.init : {
	   KEEP (*(.init))
	} > ram

    .fini : {
       KEEP (*(.fini))
    } > ram

    .rodata : {
       __rodata_start = .;
       *(.rodata)
       *(.rodata.*)
       *(.gnu.linkonce.r.*)
       __rodata_end = .;
	} > ram

	.sbss : {
	   __sbss_start = .;
	   *(.sbss)
	   *(.sbss.*)
	   *(.gnu.linkonce.sb.*)
	   __sbss_end = .;
	} > ram
	
    .sdata : {
        _gp = . + 0x800;
        *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
        *(.sdata .sdata.* .gnu.linkonce.s.*)
     }	> ram

	.data : {
	   . = ALIGN(4);
	   __data_start = .;
	   *(.data)
	   *(.data.*)
	   *(.gnu.linkonce.d.*)
	   __data_end = .;
	} > ram

    .bss : {
       . = ALIGN(4);
       __bss_start = .;
       *(.bss)
       *(.bss.*)
       *(.gnu.linkonce.b.*)
       *(COMMON)
       . = ALIGN(4);
       __bss_end = .;
    } > ram

    /* Generate Stack and Heap definitions */

    

    .stack : {
       _stack_end = .;
       . += _STACK_SIZE;
       . = ALIGN(4);
       _stack = .;
       __stack = _stack;
    } > ram
    
    _end = .;
}