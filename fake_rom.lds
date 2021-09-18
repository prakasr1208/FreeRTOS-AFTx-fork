OUTPUT_ARCH( "riscv" )
ENTRY( _mstart )

MEMORY
{
	/* Fake ROM area */
	ram (rwxa) : ORIGIN = 0x8400, LENGTH = 512K
}

SECTIONS
{
	.init :
	{
		_text = .;
		KEEP (*(SORT_NONE(.init)))
	} >ram AT>ram
	
	.text :
	{
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*)
		*(.gnu.linkonce.t.*)
	} >ram AT>ram
	
	.fini :
	{
		KEEP (*(SORT_NONE(.fini)))
		_etext = .;
	} >ram AT>ram

	.rodata.align :
	{
		. = ALIGN(4);
		_rodata = .;
	} >ram AT>ram

	.rodata.start :
	{
		_rodata_lma = LOADADDR(.rodata.start);
	} >ram AT>ram

	.rodata :
	{
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)

		. = ALIGN(4);
		_erodata = .;
	} >ram AT>ram

	.data.align :
	{
		. = ALIGN(4);
		_data = .;
	} >ram AT>ram

	.data.start :
	{
		_data_lma = LOADADDR(.data.start);
	} >ram AT>ram

	.data :
	{
		*(.data .data.*)
		*(.gnu.linkonce.d.*)
		. = ALIGN(8);
		PROVIDE( __global_pointer$ = . + 0x800 );
		*(.sdata .sdata.*)
		*(.sdata2 .sdata2.*)
		*(.gnu.linkonce.s.*)
		. = ALIGN(8);
		*(.srodata.cst16)
		*(.srodata.cst8)
		*(.srodata.cst4)
		*(.srodata.cst2)
		*(.srodata .srodata.*)

		. = ALIGN(4);
		_edata = .;
	} >ram AT>ram

	.bss.align :
	{
		. = ALIGN(4);
		_bss = .;
	} >ram AT>ram

	.bss.start :
	{
		_bss_lma = LOADADDR(.bss.start);
	} >ram AT>ram

	.bss :
	{
		*(.sbss*)
		*(.gnu.linkonce.sb.*)
		*(.bss .bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
	} >ram AT>ram

	. = ALIGN(8);
	_end = .;

	.stack :
	{
		. = ALIGN(16);
		. += __stack_size;
		_stack_top = .;
	} >ram AT>ram
}
