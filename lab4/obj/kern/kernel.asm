
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 ae 22 f0 00 	cmpl   $0x0,0xf022ae80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 ae 22 f0    	mov    %esi,0xf022ae80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 b5 5b 00 00       	call   f0105c19 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 63 10 f0 	movl   $0xf0106300,(%esp)
f010007d:	e8 b2 3e 00 00       	call   f0103f34 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 73 3e 00 00       	call   f0103f01 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 30 74 10 f0 	movl   $0xf0107430,(%esp)
f0100095:	e8 9a 3e 00 00       	call   f0103f34 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 13 08 00 00       	call   f01008b9 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000af:	b8 08 c0 26 f0       	mov    $0xf026c008,%eax
f01000b4:	2d 5f 99 22 f0       	sub    $0xf022995f,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 5f 99 22 f0 	movl   $0xf022995f,(%esp)
f01000cc:	e8 f6 54 00 00       	call   f01055c7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 89 05 00 00       	call   f010065f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 6c 63 10 f0 	movl   $0xf010636c,(%esp)
f01000e5:	e8 4a 3e 00 00       	call   f0103f34 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 ad 12 00 00       	call   f010139c <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 cd 35 00 00       	call   f01036c1 <env_init>
	trap_init();
f01000f4:	e8 27 3f 00 00       	call   f0104020 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 0c 58 00 00       	call   f010590a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 2f 5b 00 00       	call   f0105c34 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 5a 3d 00 00       	call   f0103e64 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010010a:	83 3d 88 ae 22 f0 07 	cmpl   $0x7,0xf022ae88
f0100111:	77 24                	ja     f0100137 <i386_init+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100113:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f010011a:	00 
f010011b:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100122:	f0 
f0100123:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f010012a:	00 
f010012b:	c7 04 24 87 63 10 f0 	movl   $0xf0106387,(%esp)
f0100132:	e8 09 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100137:	b8 42 58 10 f0       	mov    $0xf0105842,%eax
f010013c:	2d c8 57 10 f0       	sub    $0xf01057c8,%eax
f0100141:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100145:	c7 44 24 04 c8 57 10 	movl   $0xf01057c8,0x4(%esp)
f010014c:	f0 
f010014d:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100154:	e8 bb 54 00 00       	call   f0105614 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100159:	bb 20 b0 22 f0       	mov    $0xf022b020,%ebx
f010015e:	eb 4d                	jmp    f01001ad <i386_init+0x105>
		if (c == cpus + cpunum())  // We've started already.
f0100160:	e8 b4 5a 00 00       	call   f0105c19 <cpunum>
f0100165:	6b c0 74             	imul   $0x74,%eax,%eax
f0100168:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010016d:	39 c3                	cmp    %eax,%ebx
f010016f:	74 39                	je     f01001aa <i386_init+0x102>
f0100171:	89 d8                	mov    %ebx,%eax
f0100173:	2d 20 b0 22 f0       	sub    $0xf022b020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100178:	c1 f8 02             	sar    $0x2,%eax
f010017b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100181:	c1 e0 0f             	shl    $0xf,%eax
f0100184:	8d 80 00 40 23 f0    	lea    -0xfdcc000(%eax),%eax
f010018a:	a3 84 ae 22 f0       	mov    %eax,0xf022ae84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010018f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100196:	00 
f0100197:	0f b6 03             	movzbl (%ebx),%eax
f010019a:	89 04 24             	mov    %eax,(%esp)
f010019d:	e8 e2 5b 00 00       	call   f0105d84 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001a2:	8b 43 04             	mov    0x4(%ebx),%eax
f01001a5:	83 f8 01             	cmp    $0x1,%eax
f01001a8:	75 f8                	jne    f01001a2 <i386_init+0xfa>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001aa:	83 c3 74             	add    $0x74,%ebx
f01001ad:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f01001b4:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f01001b9:	39 c3                	cmp    %eax,%ebx
f01001bb:	72 a3                	jb     f0100160 <i386_init+0xb8>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f01001bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001c4:	00 
f01001c5:	c7 04 24 6a 0f 22 f0 	movl   $0xf0220f6a,(%esp)
f01001cc:	e8 00 37 00 00       	call   f01038d1 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001d1:	e8 67 48 00 00       	call   f0104a3d <sched_yield>

f01001d6 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001d6:	55                   	push   %ebp
f01001d7:	89 e5                	mov    %esp,%ebp
f01001d9:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001dc:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001e6:	77 20                	ja     f0100208 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001ec:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f01001f3:	f0 
f01001f4:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f01001fb:	00 
f01001fc:	c7 04 24 87 63 10 f0 	movl   $0xf0106387,(%esp)
f0100203:	e8 38 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100208:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010020d:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100210:	e8 04 5a 00 00       	call   f0105c19 <cpunum>
f0100215:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100219:	c7 04 24 93 63 10 f0 	movl   $0xf0106393,(%esp)
f0100220:	e8 0f 3d 00 00       	call   f0103f34 <cprintf>

	lapic_init();
f0100225:	e8 0a 5a 00 00       	call   f0105c34 <lapic_init>
	env_init_percpu();
f010022a:	e8 68 34 00 00       	call   f0103697 <env_init_percpu>
	trap_init_percpu();
f010022f:	90                   	nop
f0100230:	e8 1b 3d 00 00       	call   f0103f50 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100235:	e8 df 59 00 00       	call   f0105c19 <cpunum>
f010023a:	6b d0 74             	imul   $0x74,%eax,%edx
f010023d:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100243:	b8 01 00 00 00       	mov    $0x1,%eax
f0100248:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010024c:	eb fe                	jmp    f010024c <mp_main+0x76>

f010024e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010024e:	55                   	push   %ebp
f010024f:	89 e5                	mov    %esp,%ebp
f0100251:	53                   	push   %ebx
f0100252:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100255:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100258:	8b 45 0c             	mov    0xc(%ebp),%eax
f010025b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010025f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100262:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100266:	c7 04 24 a9 63 10 f0 	movl   $0xf01063a9,(%esp)
f010026d:	e8 c2 3c 00 00       	call   f0103f34 <cprintf>
	vcprintf(fmt, ap);
f0100272:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100276:	8b 45 10             	mov    0x10(%ebp),%eax
f0100279:	89 04 24             	mov    %eax,(%esp)
f010027c:	e8 80 3c 00 00       	call   f0103f01 <vcprintf>
	cprintf("\n");
f0100281:	c7 04 24 30 74 10 f0 	movl   $0xf0107430,(%esp)
f0100288:	e8 a7 3c 00 00       	call   f0103f34 <cprintf>
	va_end(ap);
}
f010028d:	83 c4 14             	add    $0x14,%esp
f0100290:	5b                   	pop    %ebx
f0100291:	5d                   	pop    %ebp
f0100292:	c3                   	ret    
f0100293:	66 90                	xchg   %ax,%ax
f0100295:	66 90                	xchg   %ax,%ax
f0100297:	66 90                	xchg   %ax,%ax
f0100299:	66 90                	xchg   %ax,%ax
f010029b:	66 90                	xchg   %ax,%ax
f010029d:	66 90                	xchg   %ax,%ax
f010029f:	90                   	nop

f01002a0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a9:	a8 01                	test   $0x1,%al
f01002ab:	74 08                	je     f01002b5 <serial_proc_data+0x15>
f01002ad:	b2 f8                	mov    $0xf8,%dl
f01002af:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002b0:	0f b6 c0             	movzbl %al,%eax
f01002b3:	eb 05                	jmp    f01002ba <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ba:	5d                   	pop    %ebp
f01002bb:	c3                   	ret    

f01002bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 04             	sub    $0x4,%esp
f01002c3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002c5:	eb 2a                	jmp    f01002f1 <cons_intr+0x35>
		if (c == 0)
f01002c7:	85 d2                	test   %edx,%edx
f01002c9:	74 26                	je     f01002f1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002cb:	a1 24 a2 22 f0       	mov    0xf022a224,%eax
f01002d0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002d3:	89 0d 24 a2 22 f0    	mov    %ecx,0xf022a224
f01002d9:	88 90 20 a0 22 f0    	mov    %dl,-0xfdd5fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002df:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002e5:	75 0a                	jne    f01002f1 <cons_intr+0x35>
			cons.wpos = 0;
f01002e7:	c7 05 24 a2 22 f0 00 	movl   $0x0,0xf022a224
f01002ee:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f1:	ff d3                	call   *%ebx
f01002f3:	89 c2                	mov    %eax,%edx
f01002f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f8:	75 cd                	jne    f01002c7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002fa:	83 c4 04             	add    $0x4,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5d                   	pop    %ebp
f01002ff:	c3                   	ret    

f0100300 <kbd_proc_data>:
f0100300:	ba 64 00 00 00       	mov    $0x64,%edx
f0100305:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100306:	a8 01                	test   $0x1,%al
f0100308:	0f 84 ef 00 00 00    	je     f01003fd <kbd_proc_data+0xfd>
f010030e:	b2 60                	mov    $0x60,%dl
f0100310:	ec                   	in     (%dx),%al
f0100311:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100313:	3c e0                	cmp    $0xe0,%al
f0100315:	75 0d                	jne    f0100324 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100317:	83 0d 00 a0 22 f0 40 	orl    $0x40,0xf022a000
		return 0;
f010031e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100323:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100324:	55                   	push   %ebp
f0100325:	89 e5                	mov    %esp,%ebp
f0100327:	53                   	push   %ebx
f0100328:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010032b:	84 c0                	test   %al,%al
f010032d:	79 37                	jns    f0100366 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010032f:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f0100335:	89 cb                	mov    %ecx,%ebx
f0100337:	83 e3 40             	and    $0x40,%ebx
f010033a:	83 e0 7f             	and    $0x7f,%eax
f010033d:	85 db                	test   %ebx,%ebx
f010033f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100342:	0f b6 d2             	movzbl %dl,%edx
f0100345:	0f b6 82 20 65 10 f0 	movzbl -0xfef9ae0(%edx),%eax
f010034c:	83 c8 40             	or     $0x40,%eax
f010034f:	0f b6 c0             	movzbl %al,%eax
f0100352:	f7 d0                	not    %eax
f0100354:	21 c1                	and    %eax,%ecx
f0100356:	89 0d 00 a0 22 f0    	mov    %ecx,0xf022a000
		return 0;
f010035c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100361:	e9 9d 00 00 00       	jmp    f0100403 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100366:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f010036c:	f6 c1 40             	test   $0x40,%cl
f010036f:	74 0e                	je     f010037f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100371:	83 c8 80             	or     $0xffffff80,%eax
f0100374:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100376:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100379:	89 0d 00 a0 22 f0    	mov    %ecx,0xf022a000
	}

	shift |= shiftcode[data];
f010037f:	0f b6 d2             	movzbl %dl,%edx
f0100382:	0f b6 82 20 65 10 f0 	movzbl -0xfef9ae0(%edx),%eax
f0100389:	0b 05 00 a0 22 f0    	or     0xf022a000,%eax
	shift ^= togglecode[data];
f010038f:	0f b6 8a 20 64 10 f0 	movzbl -0xfef9be0(%edx),%ecx
f0100396:	31 c8                	xor    %ecx,%eax
f0100398:	a3 00 a0 22 f0       	mov    %eax,0xf022a000

	c = charcode[shift & (CTL | SHIFT)][data];
f010039d:	89 c1                	mov    %eax,%ecx
f010039f:	83 e1 03             	and    $0x3,%ecx
f01003a2:	8b 0c 8d 00 64 10 f0 	mov    -0xfef9c00(,%ecx,4),%ecx
f01003a9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003ad:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003b0:	a8 08                	test   $0x8,%al
f01003b2:	74 1b                	je     f01003cf <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003b4:	89 da                	mov    %ebx,%edx
f01003b6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003b9:	83 f9 19             	cmp    $0x19,%ecx
f01003bc:	77 05                	ja     f01003c3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003be:	83 eb 20             	sub    $0x20,%ebx
f01003c1:	eb 0c                	jmp    f01003cf <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003c3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003c9:	83 fa 19             	cmp    $0x19,%edx
f01003cc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003cf:	f7 d0                	not    %eax
f01003d1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003d5:	f6 c2 06             	test   $0x6,%dl
f01003d8:	75 29                	jne    f0100403 <kbd_proc_data+0x103>
f01003da:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003e0:	75 21                	jne    f0100403 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01003e2:	c7 04 24 c3 63 10 f0 	movl   $0xf01063c3,(%esp)
f01003e9:	e8 46 3b 00 00       	call   f0103f34 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ee:	ba 92 00 00 00       	mov    $0x92,%edx
f01003f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01003f8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f9:	89 d8                	mov    %ebx,%eax
f01003fb:	eb 06                	jmp    f0100403 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100402:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100403:	83 c4 14             	add    $0x14,%esp
f0100406:	5b                   	pop    %ebx
f0100407:	5d                   	pop    %ebp
f0100408:	c3                   	ret    

f0100409 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100409:	55                   	push   %ebp
f010040a:	89 e5                	mov    %esp,%ebp
f010040c:	57                   	push   %edi
f010040d:	56                   	push   %esi
f010040e:	53                   	push   %ebx
f010040f:	83 ec 1c             	sub    $0x1c,%esp
f0100412:	89 c7                	mov    %eax,%edi
f0100414:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100419:	be fd 03 00 00       	mov    $0x3fd,%esi
f010041e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100423:	eb 06                	jmp    f010042b <cons_putc+0x22>
f0100425:	89 ca                	mov    %ecx,%edx
f0100427:	ec                   	in     (%dx),%al
f0100428:	ec                   	in     (%dx),%al
f0100429:	ec                   	in     (%dx),%al
f010042a:	ec                   	in     (%dx),%al
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010042e:	a8 20                	test   $0x20,%al
f0100430:	75 05                	jne    f0100437 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100432:	83 eb 01             	sub    $0x1,%ebx
f0100435:	75 ee                	jne    f0100425 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100437:	89 f8                	mov    %edi,%eax
f0100439:	0f b6 c0             	movzbl %al,%eax
f010043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100444:	ee                   	out    %al,(%dx)
f0100445:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044a:	be 79 03 00 00       	mov    $0x379,%esi
f010044f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100454:	eb 06                	jmp    f010045c <cons_putc+0x53>
f0100456:	89 ca                	mov    %ecx,%edx
f0100458:	ec                   	in     (%dx),%al
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	ec                   	in     (%dx),%al
f010045c:	89 f2                	mov    %esi,%edx
f010045e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010045f:	84 c0                	test   %al,%al
f0100461:	78 05                	js     f0100468 <cons_putc+0x5f>
f0100463:	83 eb 01             	sub    $0x1,%ebx
f0100466:	75 ee                	jne    f0100456 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100468:	ba 78 03 00 00       	mov    $0x378,%edx
f010046d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b2 7a                	mov    $0x7a,%dl
f0100474:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100479:	ee                   	out    %al,(%dx)
f010047a:	b8 08 00 00 00       	mov    $0x8,%eax
f010047f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100480:	89 fa                	mov    %edi,%edx
f0100482:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100488:	89 f8                	mov    %edi,%eax
f010048a:	80 cc 07             	or     $0x7,%ah
f010048d:	85 d2                	test   %edx,%edx
f010048f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100492:	89 f8                	mov    %edi,%eax
f0100494:	0f b6 c0             	movzbl %al,%eax
f0100497:	83 f8 09             	cmp    $0x9,%eax
f010049a:	74 76                	je     f0100512 <cons_putc+0x109>
f010049c:	83 f8 09             	cmp    $0x9,%eax
f010049f:	7f 0a                	jg     f01004ab <cons_putc+0xa2>
f01004a1:	83 f8 08             	cmp    $0x8,%eax
f01004a4:	74 16                	je     f01004bc <cons_putc+0xb3>
f01004a6:	e9 9b 00 00 00       	jmp    f0100546 <cons_putc+0x13d>
f01004ab:	83 f8 0a             	cmp    $0xa,%eax
f01004ae:	66 90                	xchg   %ax,%ax
f01004b0:	74 3a                	je     f01004ec <cons_putc+0xe3>
f01004b2:	83 f8 0d             	cmp    $0xd,%eax
f01004b5:	74 3d                	je     f01004f4 <cons_putc+0xeb>
f01004b7:	e9 8a 00 00 00       	jmp    f0100546 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01004bc:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f01004c3:	66 85 c0             	test   %ax,%ax
f01004c6:	0f 84 e5 00 00 00    	je     f01005b1 <cons_putc+0x1a8>
			crt_pos--;
f01004cc:	83 e8 01             	sub    $0x1,%eax
f01004cf:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d5:	0f b7 c0             	movzwl %ax,%eax
f01004d8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004dd:	83 cf 20             	or     $0x20,%edi
f01004e0:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f01004e6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004ea:	eb 78                	jmp    f0100564 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004ec:	66 83 05 28 a2 22 f0 	addw   $0x50,0xf022a228
f01004f3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004f4:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f01004fb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100501:	c1 e8 16             	shr    $0x16,%eax
f0100504:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100507:	c1 e0 04             	shl    $0x4,%eax
f010050a:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
f0100510:	eb 52                	jmp    f0100564 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100512:	b8 20 00 00 00       	mov    $0x20,%eax
f0100517:	e8 ed fe ff ff       	call   f0100409 <cons_putc>
		cons_putc(' ');
f010051c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100521:	e8 e3 fe ff ff       	call   f0100409 <cons_putc>
		cons_putc(' ');
f0100526:	b8 20 00 00 00       	mov    $0x20,%eax
f010052b:	e8 d9 fe ff ff       	call   f0100409 <cons_putc>
		cons_putc(' ');
f0100530:	b8 20 00 00 00       	mov    $0x20,%eax
f0100535:	e8 cf fe ff ff       	call   f0100409 <cons_putc>
		cons_putc(' ');
f010053a:	b8 20 00 00 00       	mov    $0x20,%eax
f010053f:	e8 c5 fe ff ff       	call   f0100409 <cons_putc>
f0100544:	eb 1e                	jmp    f0100564 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100546:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f010054d:	8d 50 01             	lea    0x1(%eax),%edx
f0100550:	66 89 15 28 a2 22 f0 	mov    %dx,0xf022a228
f0100557:	0f b7 c0             	movzwl %ax,%eax
f010055a:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100560:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100564:	66 81 3d 28 a2 22 f0 	cmpw   $0x7cf,0xf022a228
f010056b:	cf 07 
f010056d:	76 42                	jbe    f01005b1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010056f:	a1 2c a2 22 f0       	mov    0xf022a22c,%eax
f0100574:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010057b:	00 
f010057c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100582:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100586:	89 04 24             	mov    %eax,(%esp)
f0100589:	e8 86 50 00 00       	call   f0105614 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010058e:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100594:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100599:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010059f:	83 c0 01             	add    $0x1,%eax
f01005a2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005a7:	75 f0                	jne    f0100599 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005a9:	66 83 2d 28 a2 22 f0 	subw   $0x50,0xf022a228
f01005b0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005b1:	8b 0d 30 a2 22 f0    	mov    0xf022a230,%ecx
f01005b7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bc:	89 ca                	mov    %ecx,%edx
f01005be:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005bf:	0f b7 1d 28 a2 22 f0 	movzwl 0xf022a228,%ebx
f01005c6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005c9:	89 d8                	mov    %ebx,%eax
f01005cb:	66 c1 e8 08          	shr    $0x8,%ax
f01005cf:	89 f2                	mov    %esi,%edx
f01005d1:	ee                   	out    %al,(%dx)
f01005d2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d7:	89 ca                	mov    %ecx,%edx
f01005d9:	ee                   	out    %al,(%dx)
f01005da:	89 d8                	mov    %ebx,%eax
f01005dc:	89 f2                	mov    %esi,%edx
f01005de:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005df:	83 c4 1c             	add    $0x1c,%esp
f01005e2:	5b                   	pop    %ebx
f01005e3:	5e                   	pop    %esi
f01005e4:	5f                   	pop    %edi
f01005e5:	5d                   	pop    %ebp
f01005e6:	c3                   	ret    

f01005e7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005e7:	80 3d 34 a2 22 f0 00 	cmpb   $0x0,0xf022a234
f01005ee:	74 11                	je     f0100601 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005f6:	b8 a0 02 10 f0       	mov    $0xf01002a0,%eax
f01005fb:	e8 bc fc ff ff       	call   f01002bc <cons_intr>
}
f0100600:	c9                   	leave  
f0100601:	f3 c3                	repz ret 

f0100603 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100609:	b8 00 03 10 f0       	mov    $0xf0100300,%eax
f010060e:	e8 a9 fc ff ff       	call   f01002bc <cons_intr>
}
f0100613:	c9                   	leave  
f0100614:	c3                   	ret    

f0100615 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
f0100618:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061b:	e8 c7 ff ff ff       	call   f01005e7 <serial_intr>
	kbd_intr();
f0100620:	e8 de ff ff ff       	call   f0100603 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100625:	a1 20 a2 22 f0       	mov    0xf022a220,%eax
f010062a:	3b 05 24 a2 22 f0    	cmp    0xf022a224,%eax
f0100630:	74 26                	je     f0100658 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100632:	8d 50 01             	lea    0x1(%eax),%edx
f0100635:	89 15 20 a2 22 f0    	mov    %edx,0xf022a220
f010063b:	0f b6 88 20 a0 22 f0 	movzbl -0xfdd5fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100642:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100644:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010064a:	75 11                	jne    f010065d <cons_getc+0x48>
			cons.rpos = 0;
f010064c:	c7 05 20 a2 22 f0 00 	movl   $0x0,0xf022a220
f0100653:	00 00 00 
f0100656:	eb 05                	jmp    f010065d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100658:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065d:	c9                   	leave  
f010065e:	c3                   	ret    

f010065f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010065f:	55                   	push   %ebp
f0100660:	89 e5                	mov    %esp,%ebp
f0100662:	57                   	push   %edi
f0100663:	56                   	push   %esi
f0100664:	53                   	push   %ebx
f0100665:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100668:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100676:	5a a5 
	if (*cp != 0xA55A) {
f0100678:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100683:	74 11                	je     f0100696 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100685:	c7 05 30 a2 22 f0 b4 	movl   $0x3b4,0xf022a230
f010068c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100694:	eb 16                	jmp    f01006ac <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100696:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069d:	c7 05 30 a2 22 f0 d4 	movl   $0x3d4,0xf022a230
f01006a4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ac:	8b 0d 30 a2 22 f0    	mov    0xf022a230,%ecx
f01006b2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006b7:	89 ca                	mov    %ecx,%edx
f01006b9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ba:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006bd:	89 da                	mov    %ebx,%edx
f01006bf:	ec                   	in     (%dx),%al
f01006c0:	0f b6 f0             	movzbl %al,%esi
f01006c3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006cb:	89 ca                	mov    %ecx,%edx
f01006cd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ce:	89 da                	mov    %ebx,%edx
f01006d0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006d1:	89 3d 2c a2 22 f0    	mov    %edi,0xf022a22c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006d7:	0f b6 d8             	movzbl %al,%ebx
f01006da:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006dc:	66 89 35 28 a2 22 f0 	mov    %si,0xf022a228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006e3:	e8 1b ff ff ff       	call   f0100603 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006e8:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f01006ef:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f4:	89 04 24             	mov    %eax,(%esp)
f01006f7:	e8 f9 36 00 00       	call   f0103df5 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fc:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100701:	b8 00 00 00 00       	mov    $0x0,%eax
f0100706:	89 f2                	mov    %esi,%edx
f0100708:	ee                   	out    %al,(%dx)
f0100709:	b2 fb                	mov    $0xfb,%dl
f010070b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100710:	ee                   	out    %al,(%dx)
f0100711:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100716:	b8 0c 00 00 00       	mov    $0xc,%eax
f010071b:	89 da                	mov    %ebx,%edx
f010071d:	ee                   	out    %al,(%dx)
f010071e:	b2 f9                	mov    $0xf9,%dl
f0100720:	b8 00 00 00 00       	mov    $0x0,%eax
f0100725:	ee                   	out    %al,(%dx)
f0100726:	b2 fb                	mov    $0xfb,%dl
f0100728:	b8 03 00 00 00       	mov    $0x3,%eax
f010072d:	ee                   	out    %al,(%dx)
f010072e:	b2 fc                	mov    $0xfc,%dl
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	b2 f9                	mov    $0xf9,%dl
f0100738:	b8 01 00 00 00       	mov    $0x1,%eax
f010073d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073e:	b2 fd                	mov    $0xfd,%dl
f0100740:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100741:	3c ff                	cmp    $0xff,%al
f0100743:	0f 95 c1             	setne  %cl
f0100746:	88 0d 34 a2 22 f0    	mov    %cl,0xf022a234
f010074c:	89 f2                	mov    %esi,%edx
f010074e:	ec                   	in     (%dx),%al
f010074f:	89 da                	mov    %ebx,%edx
f0100751:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100752:	84 c9                	test   %cl,%cl
f0100754:	75 0c                	jne    f0100762 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100756:	c7 04 24 cf 63 10 f0 	movl   $0xf01063cf,(%esp)
f010075d:	e8 d2 37 00 00       	call   f0103f34 <cprintf>
}
f0100762:	83 c4 1c             	add    $0x1c,%esp
f0100765:	5b                   	pop    %ebx
f0100766:	5e                   	pop    %esi
f0100767:	5f                   	pop    %edi
f0100768:	5d                   	pop    %ebp
f0100769:	c3                   	ret    

f010076a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010076a:	55                   	push   %ebp
f010076b:	89 e5                	mov    %esp,%ebp
f010076d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100770:	8b 45 08             	mov    0x8(%ebp),%eax
f0100773:	e8 91 fc ff ff       	call   f0100409 <cons_putc>
}
f0100778:	c9                   	leave  
f0100779:	c3                   	ret    

f010077a <getchar>:

int
getchar(void)
{
f010077a:	55                   	push   %ebp
f010077b:	89 e5                	mov    %esp,%ebp
f010077d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100780:	e8 90 fe ff ff       	call   f0100615 <cons_getc>
f0100785:	85 c0                	test   %eax,%eax
f0100787:	74 f7                	je     f0100780 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100789:	c9                   	leave  
f010078a:	c3                   	ret    

f010078b <iscons>:

int
iscons(int fdnum)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010078e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100793:	5d                   	pop    %ebp
f0100794:	c3                   	ret    
f0100795:	66 90                	xchg   %ax,%ax
f0100797:	66 90                	xchg   %ax,%ax
f0100799:	66 90                	xchg   %ax,%ax
f010079b:	66 90                	xchg   %ax,%ax
f010079d:	66 90                	xchg   %ax,%ax
f010079f:	90                   	nop

f01007a0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a6:	c7 44 24 08 20 66 10 	movl   $0xf0106620,0x8(%esp)
f01007ad:	f0 
f01007ae:	c7 44 24 04 3e 66 10 	movl   $0xf010663e,0x4(%esp)
f01007b5:	f0 
f01007b6:	c7 04 24 43 66 10 f0 	movl   $0xf0106643,(%esp)
f01007bd:	e8 72 37 00 00       	call   f0103f34 <cprintf>
f01007c2:	c7 44 24 08 ac 66 10 	movl   $0xf01066ac,0x8(%esp)
f01007c9:	f0 
f01007ca:	c7 44 24 04 4c 66 10 	movl   $0xf010664c,0x4(%esp)
f01007d1:	f0 
f01007d2:	c7 04 24 43 66 10 f0 	movl   $0xf0106643,(%esp)
f01007d9:	e8 56 37 00 00       	call   f0103f34 <cprintf>
	return 0;
}
f01007de:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e3:	c9                   	leave  
f01007e4:	c3                   	ret    

f01007e5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007eb:	c7 04 24 55 66 10 f0 	movl   $0xf0106655,(%esp)
f01007f2:	e8 3d 37 00 00       	call   f0103f34 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007f7:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007fe:	00 
f01007ff:	c7 04 24 d4 66 10 f0 	movl   $0xf01066d4,(%esp)
f0100806:	e8 29 37 00 00       	call   f0103f34 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010080b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100812:	00 
f0100813:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010081a:	f0 
f010081b:	c7 04 24 fc 66 10 f0 	movl   $0xf01066fc,(%esp)
f0100822:	e8 0d 37 00 00       	call   f0103f34 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100827:	c7 44 24 08 e7 62 10 	movl   $0x1062e7,0x8(%esp)
f010082e:	00 
f010082f:	c7 44 24 04 e7 62 10 	movl   $0xf01062e7,0x4(%esp)
f0100836:	f0 
f0100837:	c7 04 24 20 67 10 f0 	movl   $0xf0106720,(%esp)
f010083e:	e8 f1 36 00 00       	call   f0103f34 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100843:	c7 44 24 08 5f 99 22 	movl   $0x22995f,0x8(%esp)
f010084a:	00 
f010084b:	c7 44 24 04 5f 99 22 	movl   $0xf022995f,0x4(%esp)
f0100852:	f0 
f0100853:	c7 04 24 44 67 10 f0 	movl   $0xf0106744,(%esp)
f010085a:	e8 d5 36 00 00       	call   f0103f34 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085f:	c7 44 24 08 08 c0 26 	movl   $0x26c008,0x8(%esp)
f0100866:	00 
f0100867:	c7 44 24 04 08 c0 26 	movl   $0xf026c008,0x4(%esp)
f010086e:	f0 
f010086f:	c7 04 24 68 67 10 f0 	movl   $0xf0106768,(%esp)
f0100876:	e8 b9 36 00 00       	call   f0103f34 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087b:	b8 07 c4 26 f0       	mov    $0xf026c407,%eax
f0100880:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100885:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100890:	85 c0                	test   %eax,%eax
f0100892:	0f 48 c2             	cmovs  %edx,%eax
f0100895:	c1 f8 0a             	sar    $0xa,%eax
f0100898:	89 44 24 04          	mov    %eax,0x4(%esp)
f010089c:	c7 04 24 8c 67 10 f0 	movl   $0xf010678c,(%esp)
f01008a3:	e8 8c 36 00 00       	call   f0103f34 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ad:	c9                   	leave  
f01008ae:	c3                   	ret    

f01008af <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008af:	55                   	push   %ebp
f01008b0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b7:	5d                   	pop    %ebp
f01008b8:	c3                   	ret    

f01008b9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008b9:	55                   	push   %ebp
f01008ba:	89 e5                	mov    %esp,%ebp
f01008bc:	57                   	push   %edi
f01008bd:	56                   	push   %esi
f01008be:	53                   	push   %ebx
f01008bf:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008c2:	c7 04 24 b8 67 10 f0 	movl   $0xf01067b8,(%esp)
f01008c9:	e8 66 36 00 00       	call   f0103f34 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ce:	c7 04 24 dc 67 10 f0 	movl   $0xf01067dc,(%esp)
f01008d5:	e8 5a 36 00 00       	call   f0103f34 <cprintf>

	if (tf != NULL)
f01008da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008de:	74 0b                	je     f01008eb <monitor+0x32>
		print_trapframe(tf);
f01008e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e3:	89 04 24             	mov    %eax,(%esp)
f01008e6:	e8 70 3b 00 00       	call   f010445b <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01008eb:	c7 04 24 6e 66 10 f0 	movl   $0xf010666e,(%esp)
f01008f2:	e8 79 4a 00 00       	call   f0105370 <readline>
f01008f7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008f9:	85 c0                	test   %eax,%eax
f01008fb:	74 ee                	je     f01008eb <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008fd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100904:	be 00 00 00 00       	mov    $0x0,%esi
f0100909:	eb 0a                	jmp    f0100915 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010090b:	c6 03 00             	movb   $0x0,(%ebx)
f010090e:	89 f7                	mov    %esi,%edi
f0100910:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100913:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100915:	0f b6 03             	movzbl (%ebx),%eax
f0100918:	84 c0                	test   %al,%al
f010091a:	74 63                	je     f010097f <monitor+0xc6>
f010091c:	0f be c0             	movsbl %al,%eax
f010091f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100923:	c7 04 24 72 66 10 f0 	movl   $0xf0106672,(%esp)
f010092a:	e8 5b 4c 00 00       	call   f010558a <strchr>
f010092f:	85 c0                	test   %eax,%eax
f0100931:	75 d8                	jne    f010090b <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100933:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100936:	74 47                	je     f010097f <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100938:	83 fe 0f             	cmp    $0xf,%esi
f010093b:	75 16                	jne    f0100953 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010093d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100944:	00 
f0100945:	c7 04 24 77 66 10 f0 	movl   $0xf0106677,(%esp)
f010094c:	e8 e3 35 00 00       	call   f0103f34 <cprintf>
f0100951:	eb 98                	jmp    f01008eb <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100953:	8d 7e 01             	lea    0x1(%esi),%edi
f0100956:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010095a:	eb 03                	jmp    f010095f <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010095c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010095f:	0f b6 03             	movzbl (%ebx),%eax
f0100962:	84 c0                	test   %al,%al
f0100964:	74 ad                	je     f0100913 <monitor+0x5a>
f0100966:	0f be c0             	movsbl %al,%eax
f0100969:	89 44 24 04          	mov    %eax,0x4(%esp)
f010096d:	c7 04 24 72 66 10 f0 	movl   $0xf0106672,(%esp)
f0100974:	e8 11 4c 00 00       	call   f010558a <strchr>
f0100979:	85 c0                	test   %eax,%eax
f010097b:	74 df                	je     f010095c <monitor+0xa3>
f010097d:	eb 94                	jmp    f0100913 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f010097f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100986:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100987:	85 f6                	test   %esi,%esi
f0100989:	0f 84 5c ff ff ff    	je     f01008eb <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010098f:	c7 44 24 04 3e 66 10 	movl   $0xf010663e,0x4(%esp)
f0100996:	f0 
f0100997:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010099a:	89 04 24             	mov    %eax,(%esp)
f010099d:	e8 8a 4b 00 00       	call   f010552c <strcmp>
f01009a2:	85 c0                	test   %eax,%eax
f01009a4:	74 1b                	je     f01009c1 <monitor+0x108>
f01009a6:	c7 44 24 04 4c 66 10 	movl   $0xf010664c,0x4(%esp)
f01009ad:	f0 
f01009ae:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b1:	89 04 24             	mov    %eax,(%esp)
f01009b4:	e8 73 4b 00 00       	call   f010552c <strcmp>
f01009b9:	85 c0                	test   %eax,%eax
f01009bb:	75 2f                	jne    f01009ec <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009bd:	b0 01                	mov    $0x1,%al
f01009bf:	eb 05                	jmp    f01009c6 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c1:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009c6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009c9:	01 d0                	add    %edx,%eax
f01009cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01009ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01009d2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009d9:	89 34 24             	mov    %esi,(%esp)
f01009dc:	ff 14 85 0c 68 10 f0 	call   *-0xfef97f4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009e3:	85 c0                	test   %eax,%eax
f01009e5:	78 1d                	js     f0100a04 <monitor+0x14b>
f01009e7:	e9 ff fe ff ff       	jmp    f01008eb <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009ec:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f3:	c7 04 24 94 66 10 f0 	movl   $0xf0106694,(%esp)
f01009fa:	e8 35 35 00 00       	call   f0103f34 <cprintf>
f01009ff:	e9 e7 fe ff ff       	jmp    f01008eb <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a04:	83 c4 5c             	add    $0x5c,%esp
f0100a07:	5b                   	pop    %ebx
f0100a08:	5e                   	pop    %esi
f0100a09:	5f                   	pop    %edi
f0100a0a:	5d                   	pop    %ebp
f0100a0b:	c3                   	ret    
f0100a0c:	66 90                	xchg   %ax,%ax
f0100a0e:	66 90                	xchg   %ax,%ax

f0100a10 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a13:	83 3d 38 a2 22 f0 00 	cmpl   $0x0,0xf022a238
f0100a1a:	75 11                	jne    f0100a2d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a1c:	ba 07 d0 26 f0       	mov    $0xf026d007,%edx
f0100a21:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a27:	89 15 38 a2 22 f0    	mov    %edx,0xf022a238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	75 07                	jne    f0100a38 <boot_alloc+0x28>
		return nextfree;
f0100a31:	a1 38 a2 22 f0       	mov    0xf022a238,%eax
f0100a36:	eb 19                	jmp    f0100a51 <boot_alloc+0x41>
	result = nextfree;
f0100a38:	8b 15 38 a2 22 f0    	mov    0xf022a238,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a3e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4a:	a3 38 a2 22 f0       	mov    %eax,0xf022a238
	
	// return the head address of the alloc pages;
	return result;
f0100a4f:	89 d0                	mov    %edx,%eax
}
f0100a51:	5d                   	pop    %ebp
f0100a52:	c3                   	ret    

f0100a53 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a53:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100a59:	c1 f8 03             	sar    $0x3,%eax
f0100a5c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a5f:	89 c2                	mov    %eax,%edx
f0100a61:	c1 ea 0c             	shr    $0xc,%edx
f0100a64:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100a6a:	72 26                	jb     f0100a92 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100a6c:	55                   	push   %ebp
f0100a6d:	89 e5                	mov    %esp,%ebp
f0100a6f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a76:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100a7d:	f0 
f0100a7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100a85:	00 
f0100a86:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0100a8d:	e8 ae f5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100a92:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100a97:	c3                   	ret    

f0100a98 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a98:	89 d1                	mov    %edx,%ecx
f0100a9a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a9d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aa0:	a8 01                	test   $0x1,%al
f0100aa2:	74 5d                	je     f0100b01 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aa4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aa9:	89 c1                	mov    %eax,%ecx
f0100aab:	c1 e9 0c             	shr    $0xc,%ecx
f0100aae:	3b 0d 88 ae 22 f0    	cmp    0xf022ae88,%ecx
f0100ab4:	72 26                	jb     f0100adc <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ab6:	55                   	push   %ebp
f0100ab7:	89 e5                	mov    %esp,%ebp
f0100ab9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100abc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ac0:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100ac7:	f0 
f0100ac8:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0100acf:	00 
f0100ad0:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100ad7:	e8 64 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100adc:	c1 ea 0c             	shr    $0xc,%edx
f0100adf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ae5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100aec:	89 c2                	mov    %eax,%edx
f0100aee:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100af1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af6:	85 d2                	test   %edx,%edx
f0100af8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100afd:	0f 44 c2             	cmove  %edx,%eax
f0100b00:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b06:	c3                   	ret    

f0100b07 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b07:	55                   	push   %ebp
f0100b08:	89 e5                	mov    %esp,%ebp
f0100b0a:	57                   	push   %edi
f0100b0b:	56                   	push   %esi
f0100b0c:	53                   	push   %ebx
f0100b0d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b10:	84 c0                	test   %al,%al
f0100b12:	0f 85 31 03 00 00    	jne    f0100e49 <check_page_free_list+0x342>
f0100b18:	e9 3e 03 00 00       	jmp    f0100e5b <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b1d:	c7 44 24 08 1c 68 10 	movl   $0xf010681c,0x8(%esp)
f0100b24:	f0 
f0100b25:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100b2c:	00 
f0100b2d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100b34:	e8 07 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b39:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b3f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b42:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b45:	89 c2                	mov    %eax,%edx
f0100b47:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b4d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b53:	0f 95 c2             	setne  %dl
f0100b56:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b59:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b5d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b5f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b63:	8b 00                	mov    (%eax),%eax
f0100b65:	85 c0                	test   %eax,%eax
f0100b67:	75 dc                	jne    f0100b45 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b75:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b78:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b7d:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b82:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b87:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100b8d:	eb 63                	jmp    f0100bf2 <check_page_free_list+0xeb>
f0100b8f:	89 d8                	mov    %ebx,%eax
f0100b91:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100b97:	c1 f8 03             	sar    $0x3,%eax
f0100b9a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b9d:	89 c2                	mov    %eax,%edx
f0100b9f:	c1 ea 16             	shr    $0x16,%edx
f0100ba2:	39 f2                	cmp    %esi,%edx
f0100ba4:	73 4a                	jae    f0100bf0 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba6:	89 c2                	mov    %eax,%edx
f0100ba8:	c1 ea 0c             	shr    $0xc,%edx
f0100bab:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100bb1:	72 20                	jb     f0100bd3 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bb7:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100bbe:	f0 
f0100bbf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bc6:	00 
f0100bc7:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0100bce:	e8 6d f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bd3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100bda:	00 
f0100bdb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100be2:	00 
	return (void *)(pa + KERNBASE);
f0100be3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100be8:	89 04 24             	mov    %eax,(%esp)
f0100beb:	e8 d7 49 00 00       	call   f01055c7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bf0:	8b 1b                	mov    (%ebx),%ebx
f0100bf2:	85 db                	test   %ebx,%ebx
f0100bf4:	75 99                	jne    f0100b8f <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bfb:	e8 10 fe ff ff       	call   f0100a10 <boot_alloc>
f0100c00:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c03:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c09:	8b 0d 90 ae 22 f0    	mov    0xf022ae90,%ecx
		assert(pp < pages + npages);
f0100c0f:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0100c14:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c17:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c1d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c20:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c25:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c28:	e9 c4 01 00 00       	jmp    f0100df1 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c2d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c30:	73 24                	jae    f0100c56 <check_page_free_list+0x14f>
f0100c32:	c7 44 24 0c 53 71 10 	movl   $0xf0107153,0xc(%esp)
f0100c39:	f0 
f0100c3a:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100c41:	f0 
f0100c42:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0100c49:	00 
f0100c4a:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100c51:	e8 ea f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c56:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c59:	72 24                	jb     f0100c7f <check_page_free_list+0x178>
f0100c5b:	c7 44 24 0c 74 71 10 	movl   $0xf0107174,0xc(%esp)
f0100c62:	f0 
f0100c63:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100c6a:	f0 
f0100c6b:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100c72:	00 
f0100c73:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100c7a:	e8 c1 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7f:	89 d0                	mov    %edx,%eax
f0100c81:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100c84:	a8 07                	test   $0x7,%al
f0100c86:	74 24                	je     f0100cac <check_page_free_list+0x1a5>
f0100c88:	c7 44 24 0c 40 68 10 	movl   $0xf0106840,0xc(%esp)
f0100c8f:	f0 
f0100c90:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100c97:	f0 
f0100c98:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0100c9f:	00 
f0100ca0:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100ca7:	e8 94 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cac:	c1 f8 03             	sar    $0x3,%eax
f0100caf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cb2:	85 c0                	test   %eax,%eax
f0100cb4:	75 24                	jne    f0100cda <check_page_free_list+0x1d3>
f0100cb6:	c7 44 24 0c 88 71 10 	movl   $0xf0107188,0xc(%esp)
f0100cbd:	f0 
f0100cbe:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100cc5:	f0 
f0100cc6:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100ccd:	00 
f0100cce:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100cd5:	e8 66 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cda:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cdf:	75 24                	jne    f0100d05 <check_page_free_list+0x1fe>
f0100ce1:	c7 44 24 0c 99 71 10 	movl   $0xf0107199,0xc(%esp)
f0100ce8:	f0 
f0100ce9:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100cf0:	f0 
f0100cf1:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100cf8:	00 
f0100cf9:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100d00:	e8 3b f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d05:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d0a:	75 24                	jne    f0100d30 <check_page_free_list+0x229>
f0100d0c:	c7 44 24 0c 74 68 10 	movl   $0xf0106874,0xc(%esp)
f0100d13:	f0 
f0100d14:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100d1b:	f0 
f0100d1c:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d23:	00 
f0100d24:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100d2b:	e8 10 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d30:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d35:	75 24                	jne    f0100d5b <check_page_free_list+0x254>
f0100d37:	c7 44 24 0c b2 71 10 	movl   $0xf01071b2,0xc(%esp)
f0100d3e:	f0 
f0100d3f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100d46:	f0 
f0100d47:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d4e:	00 
f0100d4f:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100d56:	e8 e5 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d5b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d60:	0f 86 1c 01 00 00    	jbe    f0100e82 <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d66:	89 c1                	mov    %eax,%ecx
f0100d68:	c1 e9 0c             	shr    $0xc,%ecx
f0100d6b:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100d6e:	77 20                	ja     f0100d90 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d70:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d74:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100d7b:	f0 
f0100d7c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d83:	00 
f0100d84:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0100d8b:	e8 b0 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d90:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100d96:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100d99:	0f 86 d3 00 00 00    	jbe    f0100e72 <check_page_free_list+0x36b>
f0100d9f:	c7 44 24 0c 98 68 10 	movl   $0xf0106898,0xc(%esp)
f0100da6:	f0 
f0100da7:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100dae:	f0 
f0100daf:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0100db6:	00 
f0100db7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100dbe:	e8 7d f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dc3:	c7 44 24 0c cc 71 10 	movl   $0xf01071cc,0xc(%esp)
f0100dca:	f0 
f0100dcb:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100dd2:	f0 
f0100dd3:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100dda:	00 
f0100ddb:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100de2:	e8 59 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100de7:	83 c3 01             	add    $0x1,%ebx
f0100dea:	eb 03                	jmp    f0100def <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100dec:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100def:	8b 12                	mov    (%edx),%edx
f0100df1:	85 d2                	test   %edx,%edx
f0100df3:	0f 85 34 fe ff ff    	jne    f0100c2d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100df9:	85 db                	test   %ebx,%ebx
f0100dfb:	7f 24                	jg     f0100e21 <check_page_free_list+0x31a>
f0100dfd:	c7 44 24 0c e9 71 10 	movl   $0xf01071e9,0xc(%esp)
f0100e04:	f0 
f0100e05:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100e0c:	f0 
f0100e0d:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0100e14:	00 
f0100e15:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100e1c:	e8 1f f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e21:	85 ff                	test   %edi,%edi
f0100e23:	7f 70                	jg     f0100e95 <check_page_free_list+0x38e>
f0100e25:	c7 44 24 0c fb 71 10 	movl   $0xf01071fb,0xc(%esp)
f0100e2c:	f0 
f0100e2d:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0100e34:	f0 
f0100e35:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100e3c:	00 
f0100e3d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0100e44:	e8 f7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e49:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0100e4e:	85 c0                	test   %eax,%eax
f0100e50:	0f 85 e3 fc ff ff    	jne    f0100b39 <check_page_free_list+0x32>
f0100e56:	e9 c2 fc ff ff       	jmp    f0100b1d <check_page_free_list+0x16>
f0100e5b:	83 3d 40 a2 22 f0 00 	cmpl   $0x0,0xf022a240
f0100e62:	0f 84 b5 fc ff ff    	je     f0100b1d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e68:	be 00 04 00 00       	mov    $0x400,%esi
f0100e6d:	e9 15 fd ff ff       	jmp    f0100b87 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e72:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e77:	0f 85 6f ff ff ff    	jne    f0100dec <check_page_free_list+0x2e5>
f0100e7d:	e9 41 ff ff ff       	jmp    f0100dc3 <check_page_free_list+0x2bc>
f0100e82:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e87:	0f 85 5a ff ff ff    	jne    f0100de7 <check_page_free_list+0x2e0>
f0100e8d:	8d 76 00             	lea    0x0(%esi),%esi
f0100e90:	e9 2e ff ff ff       	jmp    f0100dc3 <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e95:	83 c4 4c             	add    $0x4c,%esp
f0100e98:	5b                   	pop    %ebx
f0100e99:	5e                   	pop    %esi
f0100e9a:	5f                   	pop    %edi
f0100e9b:	5d                   	pop    %ebp
f0100e9c:	c3                   	ret    

f0100e9d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e9d:	55                   	push   %ebp
f0100e9e:	89 e5                	mov    %esp,%ebp
f0100ea0:	56                   	push   %esi
f0100ea1:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ea2:	be 00 00 00 00       	mov    $0x0,%esi
f0100ea7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eac:	e9 e1 00 00 00       	jmp    f0100f92 <page_init+0xf5>
		if(i == 0)
f0100eb1:	85 db                	test   %ebx,%ebx
f0100eb3:	75 16                	jne    f0100ecb <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100eb5:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f0100eba:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100ec0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ec6:	e9 c1 00 00 00       	jmp    f0100f8c <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100ecb:	83 fb 07             	cmp    $0x7,%ebx
f0100ece:	75 17                	jne    f0100ee7 <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100ed0:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f0100ed5:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100edb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100ee2:	e9 a5 00 00 00       	jmp    f0100f8c <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100ee7:	3b 1d 44 a2 22 f0    	cmp    0xf022a244,%ebx
f0100eed:	73 25                	jae    f0100f14 <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100eef:	89 f0                	mov    %esi,%eax
f0100ef1:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100ef7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100efd:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0100f03:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f05:	89 f0                	mov    %esi,%eax
f0100f07:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100f0d:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
f0100f12:	eb 78                	jmp    f0100f8c <page_init+0xef>
f0100f14:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100f1a:	83 f8 5f             	cmp    $0x5f,%eax
f0100f1d:	77 16                	ja     f0100f35 <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100f1f:	89 f0                	mov    %esi,%eax
f0100f21:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100f27:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f33:	eb 57                	jmp    f0100f8c <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f35:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f3b:	76 2c                	jbe    f0100f69 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100f3d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f42:	e8 c9 fa ff ff       	call   f0100a10 <boot_alloc>
f0100f47:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f4c:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f4f:	39 c3                	cmp    %eax,%ebx
f0100f51:	73 16                	jae    f0100f69 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100f53:	89 f0                	mov    %esi,%eax
f0100f55:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100f5b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f67:	eb 23                	jmp    f0100f8c <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f69:	89 f0                	mov    %esi,%eax
f0100f6b:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100f71:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f77:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0100f7d:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f7f:	89 f0                	mov    %esi,%eax
f0100f81:	03 05 90 ae 22 f0    	add    0xf022ae90,%eax
f0100f87:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f8c:	83 c3 01             	add    $0x1,%ebx
f0100f8f:	83 c6 08             	add    $0x8,%esi
f0100f92:	3b 1d 88 ae 22 f0    	cmp    0xf022ae88,%ebx
f0100f98:	0f 82 13 ff ff ff    	jb     f0100eb1 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100f9e:	5b                   	pop    %ebx
f0100f9f:	5e                   	pop    %esi
f0100fa0:	5d                   	pop    %ebp
f0100fa1:	c3                   	ret    

f0100fa2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fa2:	55                   	push   %ebp
f0100fa3:	89 e5                	mov    %esp,%ebp
f0100fa5:	53                   	push   %ebx
f0100fa6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100fa9:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100faf:	85 db                	test   %ebx,%ebx
f0100fb1:	74 6f                	je     f0101022 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100fb3:	8b 03                	mov    (%ebx),%eax
f0100fb5:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
	page->pp_link = 0;
f0100fba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f0100fc0:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f0100fc2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fc6:	74 5f                	je     f0101027 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fc8:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100fce:	c1 f8 03             	sar    $0x3,%eax
f0100fd1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd4:	89 c2                	mov    %eax,%edx
f0100fd6:	c1 ea 0c             	shr    $0xc,%edx
f0100fd9:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100fdf:	72 20                	jb     f0101001 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fe5:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0100fec:	f0 
f0100fed:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ff4:	00 
f0100ff5:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0100ffc:	e8 3f f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0101001:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101008:	00 
f0101009:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101010:	00 
	return (void *)(pa + KERNBASE);
f0101011:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101016:	89 04 24             	mov    %eax,(%esp)
f0101019:	e8 a9 45 00 00       	call   f01055c7 <memset>
	return page;
f010101e:	89 d8                	mov    %ebx,%eax
f0101020:	eb 05                	jmp    f0101027 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0101022:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
	return 0;
}
f0101027:	83 c4 14             	add    $0x14,%esp
f010102a:	5b                   	pop    %ebx
f010102b:	5d                   	pop    %ebp
f010102c:	c3                   	ret    

f010102d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010102d:	55                   	push   %ebp
f010102e:	89 e5                	mov    %esp,%ebp
f0101030:	83 ec 18             	sub    $0x18,%esp
f0101033:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0101036:	83 38 00             	cmpl   $0x0,(%eax)
f0101039:	75 07                	jne    f0101042 <page_free+0x15>
f010103b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101040:	74 1c                	je     f010105e <page_free+0x31>
		panic("page_free is not right");
f0101042:	c7 44 24 08 0c 72 10 	movl   $0xf010720c,0x8(%esp)
f0101049:	f0 
f010104a:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0101051:	00 
f0101052:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101059:	e8 e2 ef ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010105e:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0101064:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101066:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
	return; 
}
f010106b:	c9                   	leave  
f010106c:	c3                   	ret    

f010106d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010106d:	55                   	push   %ebp
f010106e:	89 e5                	mov    %esp,%ebp
f0101070:	83 ec 18             	sub    $0x18,%esp
f0101073:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101076:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010107a:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010107d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101081:	66 85 d2             	test   %dx,%dx
f0101084:	75 08                	jne    f010108e <page_decref+0x21>
		page_free(pp);
f0101086:	89 04 24             	mov    %eax,(%esp)
f0101089:	e8 9f ff ff ff       	call   f010102d <page_free>
}
f010108e:	c9                   	leave  
f010108f:	c3                   	ret    

f0101090 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	56                   	push   %esi
f0101094:	53                   	push   %ebx
f0101095:	83 ec 10             	sub    $0x10,%esp
f0101098:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f010109b:	89 f3                	mov    %esi,%ebx
f010109d:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f01010a0:	c1 e3 02             	shl    $0x2,%ebx
f01010a3:	03 5d 08             	add    0x8(%ebp),%ebx
f01010a6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010a9:	75 2c                	jne    f01010d7 <pgdir_walk+0x47>
f01010ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010af:	74 6c                	je     f010111d <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f01010b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010b8:	e8 e5 fe ff ff       	call   f0100fa2 <page_alloc>
		if(page == NULL)
f01010bd:	85 c0                	test   %eax,%eax
f01010bf:	74 63                	je     f0101124 <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f01010c1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c6:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f01010cc:	c1 f8 03             	sar    $0x3,%eax
f01010cf:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f01010d2:	83 c8 07             	or     $0x7,%eax
f01010d5:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f01010d7:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f01010d9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01010de:	c1 ee 0c             	shr    $0xc,%esi
f01010e1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010e7:	89 c2                	mov    %eax,%edx
f01010e9:	c1 ea 0c             	shr    $0xc,%edx
f01010ec:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f01010f2:	72 20                	jb     f0101114 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010f8:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f01010ff:	f0 
f0101100:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0101107:	00 
f0101108:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010110f:	e8 2c ef ff ff       	call   f0100040 <_panic>
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
f0101114:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010111b:	eb 0c                	jmp    f0101129 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f010111d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101122:	eb 05                	jmp    f0101129 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0101124:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f0101129:	83 c4 10             	add    $0x10,%esp
f010112c:	5b                   	pop    %ebx
f010112d:	5e                   	pop    %esi
f010112e:	5d                   	pop    %ebp
f010112f:	c3                   	ret    

f0101130 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101130:	55                   	push   %ebp
f0101131:	89 e5                	mov    %esp,%ebp
f0101133:	57                   	push   %edi
f0101134:	56                   	push   %esi
f0101135:	53                   	push   %ebx
f0101136:	83 ec 2c             	sub    $0x2c,%esp
f0101139:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010113c:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size)
f010113e:	89 d3                	mov    %edx,%ebx
f0101140:	8b 45 08             	mov    0x8(%ebp),%eax
f0101143:	29 d0                	sub    %edx,%eax
f0101145:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0101148:	8b 45 0c             	mov    0xc(%ebp),%eax
f010114b:	83 c8 01             	or     $0x1,%eax
f010114e:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101151:	eb 2c                	jmp    f010117f <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101153:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010115a:	00 
f010115b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010115f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101162:	89 04 24             	mov    %eax,(%esp)
f0101165:	e8 26 ff ff ff       	call   f0101090 <pgdir_walk>
		if(pte == NULL)
f010116a:	85 c0                	test   %eax,%eax
f010116c:	74 1b                	je     f0101189 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f010116e:	0b 7d dc             	or     -0x24(%ebp),%edi
f0101171:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f0101173:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f0101179:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010117f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101182:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101185:	85 f6                	test   %esi,%esi
f0101187:	75 ca                	jne    f0101153 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f0101189:	83 c4 2c             	add    $0x2c,%esp
f010118c:	5b                   	pop    %ebx
f010118d:	5e                   	pop    %esi
f010118e:	5f                   	pop    %edi
f010118f:	5d                   	pop    %ebp
f0101190:	c3                   	ret    

f0101191 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101191:	55                   	push   %ebp
f0101192:	89 e5                	mov    %esp,%ebp
f0101194:	53                   	push   %ebx
f0101195:	83 ec 14             	sub    $0x14,%esp
f0101198:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f010119b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011a2:	00 
f01011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ad:	89 04 24             	mov    %eax,(%esp)
f01011b0:	e8 db fe ff ff       	call   f0101090 <pgdir_walk>
	if(pte == NULL)
f01011b5:	85 c0                	test   %eax,%eax
f01011b7:	74 42                	je     f01011fb <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f01011b9:	8b 10                	mov    (%eax),%edx
f01011bb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f01011c1:	85 db                	test   %ebx,%ebx
f01011c3:	74 02                	je     f01011c7 <page_lookup+0x36>
		*pte_store = pte ;
f01011c5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011c7:	89 d0                	mov    %edx,%eax
f01011c9:	c1 e8 0c             	shr    $0xc,%eax
f01011cc:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f01011d2:	72 1c                	jb     f01011f0 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f01011d4:	c7 44 24 08 e0 68 10 	movl   $0xf01068e0,0x8(%esp)
f01011db:	f0 
f01011dc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01011e3:	00 
f01011e4:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f01011eb:	e8 50 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011f0:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
f01011f6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f01011f9:	eb 05                	jmp    f0101200 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f01011fb:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f0101200:	83 c4 14             	add    $0x14,%esp
f0101203:	5b                   	pop    %ebx
f0101204:	5d                   	pop    %ebp
f0101205:	c3                   	ret    

f0101206 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101206:	55                   	push   %ebp
f0101207:	89 e5                	mov    %esp,%ebp
f0101209:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010120c:	e8 08 4a 00 00       	call   f0105c19 <cpunum>
f0101211:	6b c0 74             	imul   $0x74,%eax,%eax
f0101214:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f010121b:	74 16                	je     f0101233 <tlb_invalidate+0x2d>
f010121d:	e8 f7 49 00 00       	call   f0105c19 <cpunum>
f0101222:	6b c0 74             	imul   $0x74,%eax,%eax
f0101225:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010122b:	8b 55 08             	mov    0x8(%ebp),%edx
f010122e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101231:	75 06                	jne    f0101239 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101233:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101236:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101239:	c9                   	leave  
f010123a:	c3                   	ret    

f010123b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	56                   	push   %esi
f010123f:	53                   	push   %ebx
f0101240:	83 ec 20             	sub    $0x20,%esp
f0101243:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101246:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101249:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010124c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101250:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101254:	89 1c 24             	mov    %ebx,(%esp)
f0101257:	e8 35 ff ff ff       	call   f0101191 <page_lookup>
	if(page == 0)
f010125c:	85 c0                	test   %eax,%eax
f010125e:	74 2d                	je     f010128d <page_remove+0x52>
		return;
	*pte = 0;
f0101260:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101263:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101269:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010126d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101270:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f0101274:	66 85 d2             	test   %dx,%dx
f0101277:	75 08                	jne    f0101281 <page_remove+0x46>
		page_free(page);
f0101279:	89 04 24             	mov    %eax,(%esp)
f010127c:	e8 ac fd ff ff       	call   f010102d <page_free>
	tlb_invalidate(pgdir, va);
f0101281:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101285:	89 1c 24             	mov    %ebx,(%esp)
f0101288:	e8 79 ff ff ff       	call   f0101206 <tlb_invalidate>
}
f010128d:	83 c4 20             	add    $0x20,%esp
f0101290:	5b                   	pop    %ebx
f0101291:	5e                   	pop    %esi
f0101292:	5d                   	pop    %ebp
f0101293:	c3                   	ret    

f0101294 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101294:	55                   	push   %ebp
f0101295:	89 e5                	mov    %esp,%ebp
f0101297:	57                   	push   %edi
f0101298:	56                   	push   %esi
f0101299:	53                   	push   %ebx
f010129a:	83 ec 1c             	sub    $0x1c,%esp
f010129d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012a0:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01012a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012aa:	00 
f01012ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012af:	8b 45 08             	mov    0x8(%ebp),%eax
f01012b2:	89 04 24             	mov    %eax,(%esp)
f01012b5:	e8 d6 fd ff ff       	call   f0101090 <pgdir_walk>
f01012ba:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f01012bc:	85 c0                	test   %eax,%eax
f01012be:	74 5a                	je     f010131a <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f01012c0:	8b 00                	mov    (%eax),%eax
f01012c2:	89 c1                	mov    %eax,%ecx
f01012c4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012ca:	89 da                	mov    %ebx,%edx
f01012cc:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f01012d2:	c1 fa 03             	sar    $0x3,%edx
f01012d5:	c1 e2 0c             	shl    $0xc,%edx
f01012d8:	39 d1                	cmp    %edx,%ecx
f01012da:	75 07                	jne    f01012e3 <page_insert+0x4f>
		pp->pp_ref--;
f01012dc:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01012e1:	eb 13                	jmp    f01012f6 <page_insert+0x62>
	
	else if(*pte != 0)
f01012e3:	85 c0                	test   %eax,%eax
f01012e5:	74 0f                	je     f01012f6 <page_insert+0x62>
		page_remove(pgdir, va);
f01012e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ee:	89 04 24             	mov    %eax,(%esp)
f01012f1:	e8 45 ff ff ff       	call   f010123b <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01012f6:	8b 55 14             	mov    0x14(%ebp),%edx
f01012f9:	83 ca 01             	or     $0x1,%edx
f01012fc:	89 d8                	mov    %ebx,%eax
f01012fe:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0101304:	c1 f8 03             	sar    $0x3,%eax
f0101307:	c1 e0 0c             	shl    $0xc,%eax
f010130a:	09 d0                	or     %edx,%eax
f010130c:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010130e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101313:	b8 00 00 00 00       	mov    $0x0,%eax
f0101318:	eb 05                	jmp    f010131f <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f010131a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010131f:	83 c4 1c             	add    $0x1c,%esp
f0101322:	5b                   	pop    %ebx
f0101323:	5e                   	pop    %esi
f0101324:	5f                   	pop    %edi
f0101325:	5d                   	pop    %ebp
f0101326:	c3                   	ret    

f0101327 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101327:	55                   	push   %ebp
f0101328:	89 e5                	mov    %esp,%ebp
f010132a:	53                   	push   %ebx
f010132b:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010132e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101331:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101337:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010133d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101340:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if(size + base >= MMIOLIM)
f0101346:	8b 15 00 f3 11 f0    	mov    0xf011f300,%edx
f010134c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010134f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101354:	76 1c                	jbe    f0101372 <mmio_map_region+0x4b>
		panic("mmio_map_region not implemented");
f0101356:	c7 44 24 08 00 69 10 	movl   $0xf0106900,0x8(%esp)
f010135d:	f0 
f010135e:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0101365:	00 
f0101366:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010136d:	e8 ce ec ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101372:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101379:	00 
f010137a:	89 0c 24             	mov    %ecx,(%esp)
f010137d:	89 d9                	mov    %ebx,%ecx
f010137f:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101384:	e8 a7 fd ff ff       	call   f0101130 <boot_map_region>
	uintptr_t ret = base;
f0101389:	a1 00 f3 11 f0       	mov    0xf011f300,%eax
	base = base +size;
f010138e:	01 c3                	add    %eax,%ebx
f0101390:	89 1d 00 f3 11 f0    	mov    %ebx,0xf011f300
	return (void*) ret;
}
f0101396:	83 c4 14             	add    $0x14,%esp
f0101399:	5b                   	pop    %ebx
f010139a:	5d                   	pop    %ebp
f010139b:	c3                   	ret    

f010139c <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010139c:	55                   	push   %ebp
f010139d:	89 e5                	mov    %esp,%ebp
f010139f:	57                   	push   %edi
f01013a0:	56                   	push   %esi
f01013a1:	53                   	push   %ebx
f01013a2:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013a5:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01013ac:	e8 1a 2a 00 00       	call   f0103dcb <mc146818_read>
f01013b1:	89 c3                	mov    %eax,%ebx
f01013b3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013ba:	e8 0c 2a 00 00       	call   f0103dcb <mc146818_read>
f01013bf:	c1 e0 08             	shl    $0x8,%eax
f01013c2:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013c4:	89 d8                	mov    %ebx,%eax
f01013c6:	c1 e0 0a             	shl    $0xa,%eax
f01013c9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013cf:	85 c0                	test   %eax,%eax
f01013d1:	0f 48 c2             	cmovs  %edx,%eax
f01013d4:	c1 f8 0c             	sar    $0xc,%eax
f01013d7:	a3 44 a2 22 f0       	mov    %eax,0xf022a244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013dc:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013e3:	e8 e3 29 00 00       	call   f0103dcb <mc146818_read>
f01013e8:	89 c3                	mov    %eax,%ebx
f01013ea:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01013f1:	e8 d5 29 00 00       	call   f0103dcb <mc146818_read>
f01013f6:	c1 e0 08             	shl    $0x8,%eax
f01013f9:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01013fb:	89 d8                	mov    %ebx,%eax
f01013fd:	c1 e0 0a             	shl    $0xa,%eax
f0101400:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101406:	85 c0                	test   %eax,%eax
f0101408:	0f 48 c2             	cmovs  %edx,%eax
f010140b:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010140e:	85 c0                	test   %eax,%eax
f0101410:	74 0e                	je     f0101420 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101412:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101418:	89 15 88 ae 22 f0    	mov    %edx,0xf022ae88
f010141e:	eb 0c                	jmp    f010142c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101420:	8b 15 44 a2 22 f0    	mov    0xf022a244,%edx
f0101426:	89 15 88 ae 22 f0    	mov    %edx,0xf022ae88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010142c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010142f:	c1 e8 0a             	shr    $0xa,%eax
f0101432:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101436:	a1 44 a2 22 f0       	mov    0xf022a244,%eax
f010143b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010143e:	c1 e8 0a             	shr    $0xa,%eax
f0101441:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101445:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f010144a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010144d:	c1 e8 0a             	shr    $0xa,%eax
f0101450:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101454:	c7 04 24 20 69 10 f0 	movl   $0xf0106920,(%esp)
f010145b:	e8 d4 2a 00 00       	call   f0103f34 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101460:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101465:	e8 a6 f5 ff ff       	call   f0100a10 <boot_alloc>
f010146a:	a3 8c ae 22 f0       	mov    %eax,0xf022ae8c
	memset(kern_pgdir, 0, PGSIZE);
f010146f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101476:	00 
f0101477:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010147e:	00 
f010147f:	89 04 24             	mov    %eax,(%esp)
f0101482:	e8 40 41 00 00       	call   f01055c7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101487:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010148c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101491:	77 20                	ja     f01014b3 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101493:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101497:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f010149e:	f0 
f010149f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014a6:	00 
f01014a7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01014ae:	e8 8d eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01014b3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014b9:	83 ca 05             	or     $0x5,%edx
f01014bc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f01014c2:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f01014c7:	c1 e0 03             	shl    $0x3,%eax
f01014ca:	e8 41 f5 ff ff       	call   f0100a10 <boot_alloc>
f01014cf:	a3 90 ae 22 f0       	mov    %eax,0xf022ae90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f01014d4:	8b 0d 88 ae 22 f0    	mov    0xf022ae88,%ecx
f01014da:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01014e1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01014e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ec:	00 
f01014ed:	89 04 24             	mov    %eax,(%esp)
f01014f0:	e8 d2 40 00 00       	call   f01055c7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f01014f5:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014fa:	e8 11 f5 ff ff       	call   f0100a10 <boot_alloc>
f01014ff:	a3 48 a2 22 f0       	mov    %eax,0xf022a248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101504:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010150b:	00 
f010150c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101513:	00 
f0101514:	89 04 24             	mov    %eax,(%esp)
f0101517:	e8 ab 40 00 00       	call   f01055c7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010151c:	e8 7c f9 ff ff       	call   f0100e9d <page_init>

	check_page_free_list(1);
f0101521:	b8 01 00 00 00       	mov    $0x1,%eax
f0101526:	e8 dc f5 ff ff       	call   f0100b07 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010152b:	83 3d 90 ae 22 f0 00 	cmpl   $0x0,0xf022ae90
f0101532:	75 1c                	jne    f0101550 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f0101534:	c7 44 24 08 23 72 10 	movl   $0xf0107223,0x8(%esp)
f010153b:	f0 
f010153c:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101543:	00 
f0101544:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010154b:	e8 f0 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101550:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0101555:	bb 00 00 00 00       	mov    $0x0,%ebx
f010155a:	eb 05                	jmp    f0101561 <mem_init+0x1c5>
		++nfree;
f010155c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010155f:	8b 00                	mov    (%eax),%eax
f0101561:	85 c0                	test   %eax,%eax
f0101563:	75 f7                	jne    f010155c <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101565:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010156c:	e8 31 fa ff ff       	call   f0100fa2 <page_alloc>
f0101571:	89 c7                	mov    %eax,%edi
f0101573:	85 c0                	test   %eax,%eax
f0101575:	75 24                	jne    f010159b <mem_init+0x1ff>
f0101577:	c7 44 24 0c 3e 72 10 	movl   $0xf010723e,0xc(%esp)
f010157e:	f0 
f010157f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101586:	f0 
f0101587:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f010158e:	00 
f010158f:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101596:	e8 a5 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010159b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a2:	e8 fb f9 ff ff       	call   f0100fa2 <page_alloc>
f01015a7:	89 c6                	mov    %eax,%esi
f01015a9:	85 c0                	test   %eax,%eax
f01015ab:	75 24                	jne    f01015d1 <mem_init+0x235>
f01015ad:	c7 44 24 0c 54 72 10 	movl   $0xf0107254,0xc(%esp)
f01015b4:	f0 
f01015b5:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01015bc:	f0 
f01015bd:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f01015c4:	00 
f01015c5:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01015cc:	e8 6f ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d8:	e8 c5 f9 ff ff       	call   f0100fa2 <page_alloc>
f01015dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	75 24                	jne    f0101608 <mem_init+0x26c>
f01015e4:	c7 44 24 0c 6a 72 10 	movl   $0xf010726a,0xc(%esp)
f01015eb:	f0 
f01015ec:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01015f3:	f0 
f01015f4:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f01015fb:	00 
f01015fc:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101603:	e8 38 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101608:	39 f7                	cmp    %esi,%edi
f010160a:	75 24                	jne    f0101630 <mem_init+0x294>
f010160c:	c7 44 24 0c 80 72 10 	movl   $0xf0107280,0xc(%esp)
f0101613:	f0 
f0101614:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010161b:	f0 
f010161c:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101623:	00 
f0101624:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010162b:	e8 10 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101630:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101633:	39 c6                	cmp    %eax,%esi
f0101635:	74 04                	je     f010163b <mem_init+0x29f>
f0101637:	39 c7                	cmp    %eax,%edi
f0101639:	75 24                	jne    f010165f <mem_init+0x2c3>
f010163b:	c7 44 24 0c 5c 69 10 	movl   $0xf010695c,0xc(%esp)
f0101642:	f0 
f0101643:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010164a:	f0 
f010164b:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101652:	00 
f0101653:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010165a:	e8 e1 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010165f:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101665:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f010166a:	c1 e0 0c             	shl    $0xc,%eax
f010166d:	89 f9                	mov    %edi,%ecx
f010166f:	29 d1                	sub    %edx,%ecx
f0101671:	c1 f9 03             	sar    $0x3,%ecx
f0101674:	c1 e1 0c             	shl    $0xc,%ecx
f0101677:	39 c1                	cmp    %eax,%ecx
f0101679:	72 24                	jb     f010169f <mem_init+0x303>
f010167b:	c7 44 24 0c 92 72 10 	movl   $0xf0107292,0xc(%esp)
f0101682:	f0 
f0101683:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010168a:	f0 
f010168b:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101692:	00 
f0101693:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010169a:	e8 a1 e9 ff ff       	call   f0100040 <_panic>
f010169f:	89 f1                	mov    %esi,%ecx
f01016a1:	29 d1                	sub    %edx,%ecx
f01016a3:	c1 f9 03             	sar    $0x3,%ecx
f01016a6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016a9:	39 c8                	cmp    %ecx,%eax
f01016ab:	77 24                	ja     f01016d1 <mem_init+0x335>
f01016ad:	c7 44 24 0c af 72 10 	movl   $0xf01072af,0xc(%esp)
f01016b4:	f0 
f01016b5:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01016bc:	f0 
f01016bd:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01016c4:	00 
f01016c5:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01016cc:	e8 6f e9 ff ff       	call   f0100040 <_panic>
f01016d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016d4:	29 d1                	sub    %edx,%ecx
f01016d6:	89 ca                	mov    %ecx,%edx
f01016d8:	c1 fa 03             	sar    $0x3,%edx
f01016db:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01016de:	39 d0                	cmp    %edx,%eax
f01016e0:	77 24                	ja     f0101706 <mem_init+0x36a>
f01016e2:	c7 44 24 0c cc 72 10 	movl   $0xf01072cc,0xc(%esp)
f01016e9:	f0 
f01016ea:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01016f1:	f0 
f01016f2:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01016f9:	00 
f01016fa:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101701:	e8 3a e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101706:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f010170b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010170e:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f0101715:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101718:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010171f:	e8 7e f8 ff ff       	call   f0100fa2 <page_alloc>
f0101724:	85 c0                	test   %eax,%eax
f0101726:	74 24                	je     f010174c <mem_init+0x3b0>
f0101728:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f010172f:	f0 
f0101730:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101737:	f0 
f0101738:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f010173f:	00 
f0101740:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101747:	e8 f4 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010174c:	89 3c 24             	mov    %edi,(%esp)
f010174f:	e8 d9 f8 ff ff       	call   f010102d <page_free>
	page_free(pp1);
f0101754:	89 34 24             	mov    %esi,(%esp)
f0101757:	e8 d1 f8 ff ff       	call   f010102d <page_free>
	page_free(pp2);
f010175c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010175f:	89 04 24             	mov    %eax,(%esp)
f0101762:	e8 c6 f8 ff ff       	call   f010102d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101767:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176e:	e8 2f f8 ff ff       	call   f0100fa2 <page_alloc>
f0101773:	89 c6                	mov    %eax,%esi
f0101775:	85 c0                	test   %eax,%eax
f0101777:	75 24                	jne    f010179d <mem_init+0x401>
f0101779:	c7 44 24 0c 3e 72 10 	movl   $0xf010723e,0xc(%esp)
f0101780:	f0 
f0101781:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101788:	f0 
f0101789:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101790:	00 
f0101791:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101798:	e8 a3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010179d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a4:	e8 f9 f7 ff ff       	call   f0100fa2 <page_alloc>
f01017a9:	89 c7                	mov    %eax,%edi
f01017ab:	85 c0                	test   %eax,%eax
f01017ad:	75 24                	jne    f01017d3 <mem_init+0x437>
f01017af:	c7 44 24 0c 54 72 10 	movl   $0xf0107254,0xc(%esp)
f01017b6:	f0 
f01017b7:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01017be:	f0 
f01017bf:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f01017c6:	00 
f01017c7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01017ce:	e8 6d e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017da:	e8 c3 f7 ff ff       	call   f0100fa2 <page_alloc>
f01017df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017e2:	85 c0                	test   %eax,%eax
f01017e4:	75 24                	jne    f010180a <mem_init+0x46e>
f01017e6:	c7 44 24 0c 6a 72 10 	movl   $0xf010726a,0xc(%esp)
f01017ed:	f0 
f01017ee:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01017f5:	f0 
f01017f6:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f01017fd:	00 
f01017fe:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101805:	e8 36 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010180a:	39 fe                	cmp    %edi,%esi
f010180c:	75 24                	jne    f0101832 <mem_init+0x496>
f010180e:	c7 44 24 0c 80 72 10 	movl   $0xf0107280,0xc(%esp)
f0101815:	f0 
f0101816:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010181d:	f0 
f010181e:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101825:	00 
f0101826:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010182d:	e8 0e e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101835:	39 c7                	cmp    %eax,%edi
f0101837:	74 04                	je     f010183d <mem_init+0x4a1>
f0101839:	39 c6                	cmp    %eax,%esi
f010183b:	75 24                	jne    f0101861 <mem_init+0x4c5>
f010183d:	c7 44 24 0c 5c 69 10 	movl   $0xf010695c,0xc(%esp)
f0101844:	f0 
f0101845:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010184c:	f0 
f010184d:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101854:	00 
f0101855:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010185c:	e8 df e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101861:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101868:	e8 35 f7 ff ff       	call   f0100fa2 <page_alloc>
f010186d:	85 c0                	test   %eax,%eax
f010186f:	74 24                	je     f0101895 <mem_init+0x4f9>
f0101871:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f0101878:	f0 
f0101879:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101880:	f0 
f0101881:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101888:	00 
f0101889:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101890:	e8 ab e7 ff ff       	call   f0100040 <_panic>
f0101895:	89 f0                	mov    %esi,%eax
f0101897:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f010189d:	c1 f8 03             	sar    $0x3,%eax
f01018a0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a3:	89 c2                	mov    %eax,%edx
f01018a5:	c1 ea 0c             	shr    $0xc,%edx
f01018a8:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f01018ae:	72 20                	jb     f01018d0 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018b4:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f01018bb:	f0 
f01018bc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018c3:	00 
f01018c4:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f01018cb:	e8 70 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018d7:	00 
f01018d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01018df:	00 
	return (void *)(pa + KERNBASE);
f01018e0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018e5:	89 04 24             	mov    %eax,(%esp)
f01018e8:	e8 da 3c 00 00       	call   f01055c7 <memset>
	page_free(pp0);
f01018ed:	89 34 24             	mov    %esi,(%esp)
f01018f0:	e8 38 f7 ff ff       	call   f010102d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018fc:	e8 a1 f6 ff ff       	call   f0100fa2 <page_alloc>
f0101901:	85 c0                	test   %eax,%eax
f0101903:	75 24                	jne    f0101929 <mem_init+0x58d>
f0101905:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f010190c:	f0 
f010190d:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101914:	f0 
f0101915:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010191c:	00 
f010191d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101924:	e8 17 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101929:	39 c6                	cmp    %eax,%esi
f010192b:	74 24                	je     f0101951 <mem_init+0x5b5>
f010192d:	c7 44 24 0c 16 73 10 	movl   $0xf0107316,0xc(%esp)
f0101934:	f0 
f0101935:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010193c:	f0 
f010193d:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101944:	00 
f0101945:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010194c:	e8 ef e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101951:	89 f0                	mov    %esi,%eax
f0101953:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0101959:	c1 f8 03             	sar    $0x3,%eax
f010195c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010195f:	89 c2                	mov    %eax,%edx
f0101961:	c1 ea 0c             	shr    $0xc,%edx
f0101964:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f010196a:	72 20                	jb     f010198c <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010196c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101970:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0101977:	f0 
f0101978:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010197f:	00 
f0101980:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0101987:	e8 b4 e6 ff ff       	call   f0100040 <_panic>
f010198c:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101992:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101998:	80 38 00             	cmpb   $0x0,(%eax)
f010199b:	74 24                	je     f01019c1 <mem_init+0x625>
f010199d:	c7 44 24 0c 26 73 10 	movl   $0xf0107326,0xc(%esp)
f01019a4:	f0 
f01019a5:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f01019b4:	00 
f01019b5:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01019bc:	e8 7f e6 ff ff       	call   f0100040 <_panic>
f01019c1:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01019c4:	39 d0                	cmp    %edx,%eax
f01019c6:	75 d0                	jne    f0101998 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01019c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019cb:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f01019d0:	89 34 24             	mov    %esi,(%esp)
f01019d3:	e8 55 f6 ff ff       	call   f010102d <page_free>
	page_free(pp1);
f01019d8:	89 3c 24             	mov    %edi,(%esp)
f01019db:	e8 4d f6 ff ff       	call   f010102d <page_free>
	page_free(pp2);
f01019e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e3:	89 04 24             	mov    %eax,(%esp)
f01019e6:	e8 42 f6 ff ff       	call   f010102d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019eb:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01019f0:	eb 05                	jmp    f01019f7 <mem_init+0x65b>
		--nfree;
f01019f2:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019f5:	8b 00                	mov    (%eax),%eax
f01019f7:	85 c0                	test   %eax,%eax
f01019f9:	75 f7                	jne    f01019f2 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f01019fb:	85 db                	test   %ebx,%ebx
f01019fd:	74 24                	je     f0101a23 <mem_init+0x687>
f01019ff:	c7 44 24 0c 30 73 10 	movl   $0xf0107330,0xc(%esp)
f0101a06:	f0 
f0101a07:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101a0e:	f0 
f0101a0f:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a16:	00 
f0101a17:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101a1e:	e8 1d e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a23:	c7 04 24 7c 69 10 f0 	movl   $0xf010697c,(%esp)
f0101a2a:	e8 05 25 00 00       	call   f0103f34 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a36:	e8 67 f5 ff ff       	call   f0100fa2 <page_alloc>
f0101a3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a3e:	85 c0                	test   %eax,%eax
f0101a40:	75 24                	jne    f0101a66 <mem_init+0x6ca>
f0101a42:	c7 44 24 0c 3e 72 10 	movl   $0xf010723e,0xc(%esp)
f0101a49:	f0 
f0101a4a:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101a51:	f0 
f0101a52:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101a59:	00 
f0101a5a:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101a61:	e8 da e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a6d:	e8 30 f5 ff ff       	call   f0100fa2 <page_alloc>
f0101a72:	89 c3                	mov    %eax,%ebx
f0101a74:	85 c0                	test   %eax,%eax
f0101a76:	75 24                	jne    f0101a9c <mem_init+0x700>
f0101a78:	c7 44 24 0c 54 72 10 	movl   $0xf0107254,0xc(%esp)
f0101a7f:	f0 
f0101a80:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101a87:	f0 
f0101a88:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101a8f:	00 
f0101a90:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101a97:	e8 a4 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa3:	e8 fa f4 ff ff       	call   f0100fa2 <page_alloc>
f0101aa8:	89 c6                	mov    %eax,%esi
f0101aaa:	85 c0                	test   %eax,%eax
f0101aac:	75 24                	jne    f0101ad2 <mem_init+0x736>
f0101aae:	c7 44 24 0c 6a 72 10 	movl   $0xf010726a,0xc(%esp)
f0101ab5:	f0 
f0101ab6:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101abd:	f0 
f0101abe:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101ac5:	00 
f0101ac6:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101acd:	e8 6e e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ad2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101ad5:	75 24                	jne    f0101afb <mem_init+0x75f>
f0101ad7:	c7 44 24 0c 80 72 10 	movl   $0xf0107280,0xc(%esp)
f0101ade:	f0 
f0101adf:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101ae6:	f0 
f0101ae7:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101aee:	00 
f0101aef:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101af6:	e8 45 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101afb:	39 c3                	cmp    %eax,%ebx
f0101afd:	74 05                	je     f0101b04 <mem_init+0x768>
f0101aff:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b02:	75 24                	jne    f0101b28 <mem_init+0x78c>
f0101b04:	c7 44 24 0c 5c 69 10 	movl   $0xf010695c,0xc(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b1b:	00 
f0101b1c:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101b23:	e8 18 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b28:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0101b2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b30:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f0101b37:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b41:	e8 5c f4 ff ff       	call   f0100fa2 <page_alloc>
f0101b46:	85 c0                	test   %eax,%eax
f0101b48:	74 24                	je     f0101b6e <mem_init+0x7d2>
f0101b4a:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101b59:	f0 
f0101b5a:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101b61:	00 
f0101b62:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101b69:	e8 d2 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b7c:	00 
f0101b7d:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101b82:	89 04 24             	mov    %eax,(%esp)
f0101b85:	e8 07 f6 ff ff       	call   f0101191 <page_lookup>
f0101b8a:	85 c0                	test   %eax,%eax
f0101b8c:	74 24                	je     f0101bb2 <mem_init+0x816>
f0101b8e:	c7 44 24 0c 9c 69 10 	movl   $0xf010699c,0xc(%esp)
f0101b95:	f0 
f0101b96:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101b9d:	f0 
f0101b9e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101ba5:	00 
f0101ba6:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101bad:	e8 8e e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bb2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bb9:	00 
f0101bba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bc1:	00 
f0101bc2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bc6:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101bcb:	89 04 24             	mov    %eax,(%esp)
f0101bce:	e8 c1 f6 ff ff       	call   f0101294 <page_insert>
f0101bd3:	85 c0                	test   %eax,%eax
f0101bd5:	78 24                	js     f0101bfb <mem_init+0x85f>
f0101bd7:	c7 44 24 0c d4 69 10 	movl   $0xf01069d4,0xc(%esp)
f0101bde:	f0 
f0101bdf:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101be6:	f0 
f0101be7:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101bee:	00 
f0101bef:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101bf6:	e8 45 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101bfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfe:	89 04 24             	mov    %eax,(%esp)
f0101c01:	e8 27 f4 ff ff       	call   f010102d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c06:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c0d:	00 
f0101c0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c15:	00 
f0101c16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c1a:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101c1f:	89 04 24             	mov    %eax,(%esp)
f0101c22:	e8 6d f6 ff ff       	call   f0101294 <page_insert>
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	74 24                	je     f0101c4f <mem_init+0x8b3>
f0101c2b:	c7 44 24 0c 04 6a 10 	movl   $0xf0106a04,0xc(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101c42:	00 
f0101c43:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101c4a:	e8 f1 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c4f:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c55:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f0101c5a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c5d:	8b 17                	mov    (%edi),%edx
f0101c5f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c65:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c68:	29 c1                	sub    %eax,%ecx
f0101c6a:	89 c8                	mov    %ecx,%eax
f0101c6c:	c1 f8 03             	sar    $0x3,%eax
f0101c6f:	c1 e0 0c             	shl    $0xc,%eax
f0101c72:	39 c2                	cmp    %eax,%edx
f0101c74:	74 24                	je     f0101c9a <mem_init+0x8fe>
f0101c76:	c7 44 24 0c 34 6a 10 	movl   $0xf0106a34,0xc(%esp)
f0101c7d:	f0 
f0101c7e:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101c8d:	00 
f0101c8e:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101c95:	e8 a6 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c9f:	89 f8                	mov    %edi,%eax
f0101ca1:	e8 f2 ed ff ff       	call   f0100a98 <check_va2pa>
f0101ca6:	89 da                	mov    %ebx,%edx
f0101ca8:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101cab:	c1 fa 03             	sar    $0x3,%edx
f0101cae:	c1 e2 0c             	shl    $0xc,%edx
f0101cb1:	39 d0                	cmp    %edx,%eax
f0101cb3:	74 24                	je     f0101cd9 <mem_init+0x93d>
f0101cb5:	c7 44 24 0c 5c 6a 10 	movl   $0xf0106a5c,0xc(%esp)
f0101cbc:	f0 
f0101cbd:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101cc4:	f0 
f0101cc5:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101ccc:	00 
f0101ccd:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101cd4:	e8 67 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cd9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cde:	74 24                	je     f0101d04 <mem_init+0x968>
f0101ce0:	c7 44 24 0c 3b 73 10 	movl   $0xf010733b,0xc(%esp)
f0101ce7:	f0 
f0101ce8:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101cef:	f0 
f0101cf0:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101cf7:	00 
f0101cf8:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101cff:	e8 3c e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d07:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d0c:	74 24                	je     f0101d32 <mem_init+0x996>
f0101d0e:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f0101d15:	f0 
f0101d16:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101d1d:	f0 
f0101d1e:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101d25:	00 
f0101d26:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101d2d:	e8 0e e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d32:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d39:	00 
f0101d3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d41:	00 
f0101d42:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d46:	89 3c 24             	mov    %edi,(%esp)
f0101d49:	e8 46 f5 ff ff       	call   f0101294 <page_insert>
f0101d4e:	85 c0                	test   %eax,%eax
f0101d50:	74 24                	je     f0101d76 <mem_init+0x9da>
f0101d52:	c7 44 24 0c 8c 6a 10 	movl   $0xf0106a8c,0xc(%esp)
f0101d59:	f0 
f0101d5a:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101d61:	f0 
f0101d62:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101d69:	00 
f0101d6a:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101d71:	e8 ca e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d76:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d7b:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101d80:	e8 13 ed ff ff       	call   f0100a98 <check_va2pa>
f0101d85:	89 f2                	mov    %esi,%edx
f0101d87:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101d8d:	c1 fa 03             	sar    $0x3,%edx
f0101d90:	c1 e2 0c             	shl    $0xc,%edx
f0101d93:	39 d0                	cmp    %edx,%eax
f0101d95:	74 24                	je     f0101dbb <mem_init+0xa1f>
f0101d97:	c7 44 24 0c c8 6a 10 	movl   $0xf0106ac8,0xc(%esp)
f0101d9e:	f0 
f0101d9f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101dae:	00 
f0101daf:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101db6:	e8 85 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101dbb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dc0:	74 24                	je     f0101de6 <mem_init+0xa4a>
f0101dc2:	c7 44 24 0c 5d 73 10 	movl   $0xf010735d,0xc(%esp)
f0101dc9:	f0 
f0101dca:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101dd1:	f0 
f0101dd2:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101dd9:	00 
f0101dda:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101de1:	e8 5a e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101de6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ded:	e8 b0 f1 ff ff       	call   f0100fa2 <page_alloc>
f0101df2:	85 c0                	test   %eax,%eax
f0101df4:	74 24                	je     f0101e1a <mem_init+0xa7e>
f0101df6:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f0101dfd:	f0 
f0101dfe:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101e0d:	00 
f0101e0e:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101e15:	e8 26 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e1a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e21:	00 
f0101e22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e29:	00 
f0101e2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e2e:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101e33:	89 04 24             	mov    %eax,(%esp)
f0101e36:	e8 59 f4 ff ff       	call   f0101294 <page_insert>
f0101e3b:	85 c0                	test   %eax,%eax
f0101e3d:	74 24                	je     f0101e63 <mem_init+0xac7>
f0101e3f:	c7 44 24 0c 8c 6a 10 	movl   $0xf0106a8c,0xc(%esp)
f0101e46:	f0 
f0101e47:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101e56:	00 
f0101e57:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101e5e:	e8 dd e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e63:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e68:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101e6d:	e8 26 ec ff ff       	call   f0100a98 <check_va2pa>
f0101e72:	89 f2                	mov    %esi,%edx
f0101e74:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101e7a:	c1 fa 03             	sar    $0x3,%edx
f0101e7d:	c1 e2 0c             	shl    $0xc,%edx
f0101e80:	39 d0                	cmp    %edx,%eax
f0101e82:	74 24                	je     f0101ea8 <mem_init+0xb0c>
f0101e84:	c7 44 24 0c c8 6a 10 	movl   $0xf0106ac8,0xc(%esp)
f0101e8b:	f0 
f0101e8c:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101e93:	f0 
f0101e94:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101e9b:	00 
f0101e9c:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101ea3:	e8 98 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ea8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ead:	74 24                	je     f0101ed3 <mem_init+0xb37>
f0101eaf:	c7 44 24 0c 5d 73 10 	movl   $0xf010735d,0xc(%esp)
f0101eb6:	f0 
f0101eb7:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101ec6:	00 
f0101ec7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101ece:	e8 6d e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ed3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eda:	e8 c3 f0 ff ff       	call   f0100fa2 <page_alloc>
f0101edf:	85 c0                	test   %eax,%eax
f0101ee1:	74 24                	je     f0101f07 <mem_init+0xb6b>
f0101ee3:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f0101eea:	f0 
f0101eeb:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101ef2:	f0 
f0101ef3:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101efa:	00 
f0101efb:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101f02:	e8 39 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f07:	8b 15 8c ae 22 f0    	mov    0xf022ae8c,%edx
f0101f0d:	8b 02                	mov    (%edx),%eax
f0101f0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f14:	89 c1                	mov    %eax,%ecx
f0101f16:	c1 e9 0c             	shr    $0xc,%ecx
f0101f19:	3b 0d 88 ae 22 f0    	cmp    0xf022ae88,%ecx
f0101f1f:	72 20                	jb     f0101f41 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f21:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f25:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0101f2c:	f0 
f0101f2d:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101f34:	00 
f0101f35:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101f3c:	e8 ff e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f41:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f50:	00 
f0101f51:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f58:	00 
f0101f59:	89 14 24             	mov    %edx,(%esp)
f0101f5c:	e8 2f f1 ff ff       	call   f0101090 <pgdir_walk>
f0101f61:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101f64:	8d 51 04             	lea    0x4(%ecx),%edx
f0101f67:	39 d0                	cmp    %edx,%eax
f0101f69:	74 24                	je     f0101f8f <mem_init+0xbf3>
f0101f6b:	c7 44 24 0c f8 6a 10 	movl   $0xf0106af8,0xc(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101f82:	00 
f0101f83:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101f8a:	e8 b1 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f96:	00 
f0101f97:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f9e:	00 
f0101f9f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fa3:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101fa8:	89 04 24             	mov    %eax,(%esp)
f0101fab:	e8 e4 f2 ff ff       	call   f0101294 <page_insert>
f0101fb0:	85 c0                	test   %eax,%eax
f0101fb2:	74 24                	je     f0101fd8 <mem_init+0xc3c>
f0101fb4:	c7 44 24 0c 38 6b 10 	movl   $0xf0106b38,0xc(%esp)
f0101fbb:	f0 
f0101fbc:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0101fc3:	f0 
f0101fc4:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101fcb:	00 
f0101fcc:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0101fd3:	e8 68 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fd8:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0101fde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe3:	89 f8                	mov    %edi,%eax
f0101fe5:	e8 ae ea ff ff       	call   f0100a98 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fea:	89 f2                	mov    %esi,%edx
f0101fec:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101ff2:	c1 fa 03             	sar    $0x3,%edx
f0101ff5:	c1 e2 0c             	shl    $0xc,%edx
f0101ff8:	39 d0                	cmp    %edx,%eax
f0101ffa:	74 24                	je     f0102020 <mem_init+0xc84>
f0101ffc:	c7 44 24 0c c8 6a 10 	movl   $0xf0106ac8,0xc(%esp)
f0102003:	f0 
f0102004:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010200b:	f0 
f010200c:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102013:	00 
f0102014:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010201b:	e8 20 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102020:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102025:	74 24                	je     f010204b <mem_init+0xcaf>
f0102027:	c7 44 24 0c 5d 73 10 	movl   $0xf010735d,0xc(%esp)
f010202e:	f0 
f010202f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102036:	f0 
f0102037:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010203e:	00 
f010203f:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102046:	e8 f5 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010204b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102052:	00 
f0102053:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010205a:	00 
f010205b:	89 3c 24             	mov    %edi,(%esp)
f010205e:	e8 2d f0 ff ff       	call   f0101090 <pgdir_walk>
f0102063:	f6 00 04             	testb  $0x4,(%eax)
f0102066:	75 24                	jne    f010208c <mem_init+0xcf0>
f0102068:	c7 44 24 0c 78 6b 10 	movl   $0xf0106b78,0xc(%esp)
f010206f:	f0 
f0102070:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102077:	f0 
f0102078:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f010207f:	00 
f0102080:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102087:	e8 b4 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010208c:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102091:	f6 00 04             	testb  $0x4,(%eax)
f0102094:	75 24                	jne    f01020ba <mem_init+0xd1e>
f0102096:	c7 44 24 0c 6e 73 10 	movl   $0xf010736e,0xc(%esp)
f010209d:	f0 
f010209e:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01020a5:	f0 
f01020a6:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01020ad:	00 
f01020ae:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01020b5:	e8 86 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020ba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020c1:	00 
f01020c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020c9:	00 
f01020ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020ce:	89 04 24             	mov    %eax,(%esp)
f01020d1:	e8 be f1 ff ff       	call   f0101294 <page_insert>
f01020d6:	85 c0                	test   %eax,%eax
f01020d8:	74 24                	je     f01020fe <mem_init+0xd62>
f01020da:	c7 44 24 0c 8c 6a 10 	movl   $0xf0106a8c,0xc(%esp)
f01020e1:	f0 
f01020e2:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01020e9:	f0 
f01020ea:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01020f1:	00 
f01020f2:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01020f9:	e8 42 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102105:	00 
f0102106:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010210d:	00 
f010210e:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102113:	89 04 24             	mov    %eax,(%esp)
f0102116:	e8 75 ef ff ff       	call   f0101090 <pgdir_walk>
f010211b:	f6 00 02             	testb  $0x2,(%eax)
f010211e:	75 24                	jne    f0102144 <mem_init+0xda8>
f0102120:	c7 44 24 0c ac 6b 10 	movl   $0xf0106bac,0xc(%esp)
f0102127:	f0 
f0102128:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010212f:	f0 
f0102130:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102137:	00 
f0102138:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010213f:	e8 fc de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010214b:	00 
f010214c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102153:	00 
f0102154:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102159:	89 04 24             	mov    %eax,(%esp)
f010215c:	e8 2f ef ff ff       	call   f0101090 <pgdir_walk>
f0102161:	f6 00 04             	testb  $0x4,(%eax)
f0102164:	74 24                	je     f010218a <mem_init+0xdee>
f0102166:	c7 44 24 0c e0 6b 10 	movl   $0xf0106be0,0xc(%esp)
f010216d:	f0 
f010216e:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102175:	f0 
f0102176:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010217d:	00 
f010217e:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102185:	e8 b6 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010218a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102191:	00 
f0102192:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102199:	00 
f010219a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021a1:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01021a6:	89 04 24             	mov    %eax,(%esp)
f01021a9:	e8 e6 f0 ff ff       	call   f0101294 <page_insert>
f01021ae:	85 c0                	test   %eax,%eax
f01021b0:	78 24                	js     f01021d6 <mem_init+0xe3a>
f01021b2:	c7 44 24 0c 18 6c 10 	movl   $0xf0106c18,0xc(%esp)
f01021b9:	f0 
f01021ba:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01021c1:	f0 
f01021c2:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f01021c9:	00 
f01021ca:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01021d1:	e8 6a de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021d6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021dd:	00 
f01021de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021e5:	00 
f01021e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021ea:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01021ef:	89 04 24             	mov    %eax,(%esp)
f01021f2:	e8 9d f0 ff ff       	call   f0101294 <page_insert>
f01021f7:	85 c0                	test   %eax,%eax
f01021f9:	74 24                	je     f010221f <mem_init+0xe83>
f01021fb:	c7 44 24 0c 50 6c 10 	movl   $0xf0106c50,0xc(%esp)
f0102202:	f0 
f0102203:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010220a:	f0 
f010220b:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102212:	00 
f0102213:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010221a:	e8 21 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010221f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102226:	00 
f0102227:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010222e:	00 
f010222f:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102234:	89 04 24             	mov    %eax,(%esp)
f0102237:	e8 54 ee ff ff       	call   f0101090 <pgdir_walk>
f010223c:	f6 00 04             	testb  $0x4,(%eax)
f010223f:	74 24                	je     f0102265 <mem_init+0xec9>
f0102241:	c7 44 24 0c e0 6b 10 	movl   $0xf0106be0,0xc(%esp)
f0102248:	f0 
f0102249:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102250:	f0 
f0102251:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102258:	00 
f0102259:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102260:	e8 db dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102265:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f010226b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102270:	89 f8                	mov    %edi,%eax
f0102272:	e8 21 e8 ff ff       	call   f0100a98 <check_va2pa>
f0102277:	89 c1                	mov    %eax,%ecx
f0102279:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010227c:	89 d8                	mov    %ebx,%eax
f010227e:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102284:	c1 f8 03             	sar    $0x3,%eax
f0102287:	c1 e0 0c             	shl    $0xc,%eax
f010228a:	39 c1                	cmp    %eax,%ecx
f010228c:	74 24                	je     f01022b2 <mem_init+0xf16>
f010228e:	c7 44 24 0c 8c 6c 10 	movl   $0xf0106c8c,0xc(%esp)
f0102295:	f0 
f0102296:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010229d:	f0 
f010229e:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f01022a5:	00 
f01022a6:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01022ad:	e8 8e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022b2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022b7:	89 f8                	mov    %edi,%eax
f01022b9:	e8 da e7 ff ff       	call   f0100a98 <check_va2pa>
f01022be:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01022c1:	74 24                	je     f01022e7 <mem_init+0xf4b>
f01022c3:	c7 44 24 0c b8 6c 10 	movl   $0xf0106cb8,0xc(%esp)
f01022ca:	f0 
f01022cb:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01022d2:	f0 
f01022d3:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f01022da:	00 
f01022db:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01022e2:	e8 59 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022e7:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01022ec:	74 24                	je     f0102312 <mem_init+0xf76>
f01022ee:	c7 44 24 0c 84 73 10 	movl   $0xf0107384,0xc(%esp)
f01022f5:	f0 
f01022f6:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01022fd:	f0 
f01022fe:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102305:	00 
f0102306:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010230d:	e8 2e dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102312:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102317:	74 24                	je     f010233d <mem_init+0xfa1>
f0102319:	c7 44 24 0c 95 73 10 	movl   $0xf0107395,0xc(%esp)
f0102320:	f0 
f0102321:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102328:	f0 
f0102329:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102330:	00 
f0102331:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102338:	e8 03 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010233d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102344:	e8 59 ec ff ff       	call   f0100fa2 <page_alloc>
f0102349:	85 c0                	test   %eax,%eax
f010234b:	74 04                	je     f0102351 <mem_init+0xfb5>
f010234d:	39 c6                	cmp    %eax,%esi
f010234f:	74 24                	je     f0102375 <mem_init+0xfd9>
f0102351:	c7 44 24 0c e8 6c 10 	movl   $0xf0106ce8,0xc(%esp)
f0102358:	f0 
f0102359:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102360:	f0 
f0102361:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102368:	00 
f0102369:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102370:	e8 cb dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102375:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010237c:	00 
f010237d:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102382:	89 04 24             	mov    %eax,(%esp)
f0102385:	e8 b1 ee ff ff       	call   f010123b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010238a:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0102390:	ba 00 00 00 00       	mov    $0x0,%edx
f0102395:	89 f8                	mov    %edi,%eax
f0102397:	e8 fc e6 ff ff       	call   f0100a98 <check_va2pa>
f010239c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010239f:	74 24                	je     f01023c5 <mem_init+0x1029>
f01023a1:	c7 44 24 0c 0c 6d 10 	movl   $0xf0106d0c,0xc(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01023b8:	00 
f01023b9:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01023c0:	e8 7b dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ca:	89 f8                	mov    %edi,%eax
f01023cc:	e8 c7 e6 ff ff       	call   f0100a98 <check_va2pa>
f01023d1:	89 da                	mov    %ebx,%edx
f01023d3:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f01023d9:	c1 fa 03             	sar    $0x3,%edx
f01023dc:	c1 e2 0c             	shl    $0xc,%edx
f01023df:	39 d0                	cmp    %edx,%eax
f01023e1:	74 24                	je     f0102407 <mem_init+0x106b>
f01023e3:	c7 44 24 0c b8 6c 10 	movl   $0xf0106cb8,0xc(%esp)
f01023ea:	f0 
f01023eb:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01023f2:	f0 
f01023f3:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01023fa:	00 
f01023fb:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102402:	e8 39 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102407:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010240c:	74 24                	je     f0102432 <mem_init+0x1096>
f010240e:	c7 44 24 0c 3b 73 10 	movl   $0xf010733b,0xc(%esp)
f0102415:	f0 
f0102416:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010241d:	f0 
f010241e:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102425:	00 
f0102426:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010242d:	e8 0e dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102432:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102437:	74 24                	je     f010245d <mem_init+0x10c1>
f0102439:	c7 44 24 0c 95 73 10 	movl   $0xf0107395,0xc(%esp)
f0102440:	f0 
f0102441:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102448:	f0 
f0102449:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102450:	00 
f0102451:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102458:	e8 e3 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010245d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102464:	00 
f0102465:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010246c:	00 
f010246d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102471:	89 3c 24             	mov    %edi,(%esp)
f0102474:	e8 1b ee ff ff       	call   f0101294 <page_insert>
f0102479:	85 c0                	test   %eax,%eax
f010247b:	74 24                	je     f01024a1 <mem_init+0x1105>
f010247d:	c7 44 24 0c 30 6d 10 	movl   $0xf0106d30,0xc(%esp)
f0102484:	f0 
f0102485:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010248c:	f0 
f010248d:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102494:	00 
f0102495:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010249c:	e8 9f db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024a1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024a6:	75 24                	jne    f01024cc <mem_init+0x1130>
f01024a8:	c7 44 24 0c a6 73 10 	movl   $0xf01073a6,0xc(%esp)
f01024af:	f0 
f01024b0:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01024b7:	f0 
f01024b8:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01024bf:	00 
f01024c0:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01024c7:	e8 74 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01024cc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01024cf:	74 24                	je     f01024f5 <mem_init+0x1159>
f01024d1:	c7 44 24 0c b2 73 10 	movl   $0xf01073b2,0xc(%esp)
f01024d8:	f0 
f01024d9:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01024e0:	f0 
f01024e1:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01024e8:	00 
f01024e9:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01024f0:	e8 4b db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01024f5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024fc:	00 
f01024fd:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102502:	89 04 24             	mov    %eax,(%esp)
f0102505:	e8 31 ed ff ff       	call   f010123b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010250a:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0102510:	ba 00 00 00 00       	mov    $0x0,%edx
f0102515:	89 f8                	mov    %edi,%eax
f0102517:	e8 7c e5 ff ff       	call   f0100a98 <check_va2pa>
f010251c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010251f:	74 24                	je     f0102545 <mem_init+0x11a9>
f0102521:	c7 44 24 0c 0c 6d 10 	movl   $0xf0106d0c,0xc(%esp)
f0102528:	f0 
f0102529:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102530:	f0 
f0102531:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102538:	00 
f0102539:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102540:	e8 fb da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102545:	ba 00 10 00 00       	mov    $0x1000,%edx
f010254a:	89 f8                	mov    %edi,%eax
f010254c:	e8 47 e5 ff ff       	call   f0100a98 <check_va2pa>
f0102551:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102554:	74 24                	je     f010257a <mem_init+0x11de>
f0102556:	c7 44 24 0c 68 6d 10 	movl   $0xf0106d68,0xc(%esp)
f010255d:	f0 
f010255e:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102565:	f0 
f0102566:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f010256d:	00 
f010256e:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102575:	e8 c6 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010257a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010257f:	74 24                	je     f01025a5 <mem_init+0x1209>
f0102581:	c7 44 24 0c c7 73 10 	movl   $0xf01073c7,0xc(%esp)
f0102588:	f0 
f0102589:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102590:	f0 
f0102591:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102598:	00 
f0102599:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01025a0:	e8 9b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025a5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025aa:	74 24                	je     f01025d0 <mem_init+0x1234>
f01025ac:	c7 44 24 0c 95 73 10 	movl   $0xf0107395,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01025cb:	e8 70 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025d7:	e8 c6 e9 ff ff       	call   f0100fa2 <page_alloc>
f01025dc:	85 c0                	test   %eax,%eax
f01025de:	74 04                	je     f01025e4 <mem_init+0x1248>
f01025e0:	39 c3                	cmp    %eax,%ebx
f01025e2:	74 24                	je     f0102608 <mem_init+0x126c>
f01025e4:	c7 44 24 0c 90 6d 10 	movl   $0xf0106d90,0xc(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01025f3:	f0 
f01025f4:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01025fb:	00 
f01025fc:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102608:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010260f:	e8 8e e9 ff ff       	call   f0100fa2 <page_alloc>
f0102614:	85 c0                	test   %eax,%eax
f0102616:	74 24                	je     f010263c <mem_init+0x12a0>
f0102618:	c7 44 24 0c e9 72 10 	movl   $0xf01072e9,0xc(%esp)
f010261f:	f0 
f0102620:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102627:	f0 
f0102628:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010262f:	00 
f0102630:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102637:	e8 04 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010263c:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102641:	8b 08                	mov    (%eax),%ecx
f0102643:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102649:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010264c:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0102652:	c1 fa 03             	sar    $0x3,%edx
f0102655:	c1 e2 0c             	shl    $0xc,%edx
f0102658:	39 d1                	cmp    %edx,%ecx
f010265a:	74 24                	je     f0102680 <mem_init+0x12e4>
f010265c:	c7 44 24 0c 34 6a 10 	movl   $0xf0106a34,0xc(%esp)
f0102663:	f0 
f0102664:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010266b:	f0 
f010266c:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102673:	00 
f0102674:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010267b:	e8 c0 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102680:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102686:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102689:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010268e:	74 24                	je     f01026b4 <mem_init+0x1318>
f0102690:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f0102697:	f0 
f0102698:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010269f:	f0 
f01026a0:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01026a7:	00 
f01026a8:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01026af:	e8 8c d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01026b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026b7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01026bd:	89 04 24             	mov    %eax,(%esp)
f01026c0:	e8 68 e9 ff ff       	call   f010102d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01026c5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026cc:	00 
f01026cd:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01026d4:	00 
f01026d5:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01026da:	89 04 24             	mov    %eax,(%esp)
f01026dd:	e8 ae e9 ff ff       	call   f0101090 <pgdir_walk>
f01026e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01026e8:	8b 15 8c ae 22 f0    	mov    0xf022ae8c,%edx
f01026ee:	8b 7a 04             	mov    0x4(%edx),%edi
f01026f1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f7:	8b 0d 88 ae 22 f0    	mov    0xf022ae88,%ecx
f01026fd:	89 f8                	mov    %edi,%eax
f01026ff:	c1 e8 0c             	shr    $0xc,%eax
f0102702:	39 c8                	cmp    %ecx,%eax
f0102704:	72 20                	jb     f0102726 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102706:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010270a:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0102711:	f0 
f0102712:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102719:	00 
f010271a:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102721:	e8 1a d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102726:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010272c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010272f:	74 24                	je     f0102755 <mem_init+0x13b9>
f0102731:	c7 44 24 0c d8 73 10 	movl   $0xf01073d8,0xc(%esp)
f0102738:	f0 
f0102739:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102740:	f0 
f0102741:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102748:	00 
f0102749:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102750:	e8 eb d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102755:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f010275c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010275f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102765:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f010276b:	c1 f8 03             	sar    $0x3,%eax
f010276e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102771:	89 c2                	mov    %eax,%edx
f0102773:	c1 ea 0c             	shr    $0xc,%edx
f0102776:	39 d1                	cmp    %edx,%ecx
f0102778:	77 20                	ja     f010279a <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010277a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010277e:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0102785:	f0 
f0102786:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010278d:	00 
f010278e:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0102795:	e8 a6 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010279a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027a1:	00 
f01027a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01027a9:	00 
	return (void *)(pa + KERNBASE);
f01027aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027af:	89 04 24             	mov    %eax,(%esp)
f01027b2:	e8 10 2e 00 00       	call   f01055c7 <memset>
	page_free(pp0);
f01027b7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027ba:	89 3c 24             	mov    %edi,(%esp)
f01027bd:	e8 6b e8 ff ff       	call   f010102d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027c2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027c9:	00 
f01027ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027d1:	00 
f01027d2:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01027d7:	89 04 24             	mov    %eax,(%esp)
f01027da:	e8 b1 e8 ff ff       	call   f0101090 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027df:	89 fa                	mov    %edi,%edx
f01027e1:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f01027e7:	c1 fa 03             	sar    $0x3,%edx
f01027ea:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027ed:	89 d0                	mov    %edx,%eax
f01027ef:	c1 e8 0c             	shr    $0xc,%eax
f01027f2:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f01027f8:	72 20                	jb     f010281a <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027fe:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0102805:	f0 
f0102806:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010280d:	00 
f010280e:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0102815:	e8 26 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010281a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102823:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102829:	f6 00 01             	testb  $0x1,(%eax)
f010282c:	74 24                	je     f0102852 <mem_init+0x14b6>
f010282e:	c7 44 24 0c f0 73 10 	movl   $0xf01073f0,0xc(%esp)
f0102835:	f0 
f0102836:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010283d:	f0 
f010283e:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102845:	00 
f0102846:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010284d:	e8 ee d7 ff ff       	call   f0100040 <_panic>
f0102852:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102855:	39 d0                	cmp    %edx,%eax
f0102857:	75 d0                	jne    f0102829 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102859:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f010285e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102867:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010286d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102870:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240

	// free the pages we took
	page_free(pp0);
f0102876:	89 04 24             	mov    %eax,(%esp)
f0102879:	e8 af e7 ff ff       	call   f010102d <page_free>
	page_free(pp1);
f010287e:	89 1c 24             	mov    %ebx,(%esp)
f0102881:	e8 a7 e7 ff ff       	call   f010102d <page_free>
	page_free(pp2);
f0102886:	89 34 24             	mov    %esi,(%esp)
f0102889:	e8 9f e7 ff ff       	call   f010102d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010288e:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102895:	00 
f0102896:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010289d:	e8 85 ea ff ff       	call   f0101327 <mmio_map_region>
f01028a2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028a4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028ab:	00 
f01028ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028b3:	e8 6f ea ff ff       	call   f0101327 <mmio_map_region>
f01028b8:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01028ba:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01028c0:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01028c5:	77 08                	ja     f01028cf <mem_init+0x1533>
f01028c7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028cd:	77 24                	ja     f01028f3 <mem_init+0x1557>
f01028cf:	c7 44 24 0c b4 6d 10 	movl   $0xf0106db4,0xc(%esp)
f01028d6:	f0 
f01028d7:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01028de:	f0 
f01028df:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01028e6:	00 
f01028e7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01028ee:	e8 4d d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01028f3:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01028f9:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01028ff:	77 08                	ja     f0102909 <mem_init+0x156d>
f0102901:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102907:	77 24                	ja     f010292d <mem_init+0x1591>
f0102909:	c7 44 24 0c dc 6d 10 	movl   $0xf0106ddc,0xc(%esp)
f0102910:	f0 
f0102911:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102918:	f0 
f0102919:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102920:	00 
f0102921:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102928:	e8 13 d7 ff ff       	call   f0100040 <_panic>
f010292d:	89 da                	mov    %ebx,%edx
f010292f:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102931:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102937:	74 24                	je     f010295d <mem_init+0x15c1>
f0102939:	c7 44 24 0c 04 6e 10 	movl   $0xf0106e04,0xc(%esp)
f0102940:	f0 
f0102941:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102948:	f0 
f0102949:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102950:	00 
f0102951:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102958:	e8 e3 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010295d:	39 c6                	cmp    %eax,%esi
f010295f:	73 24                	jae    f0102985 <mem_init+0x15e9>
f0102961:	c7 44 24 0c 07 74 10 	movl   $0xf0107407,0xc(%esp)
f0102968:	f0 
f0102969:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102970:	f0 
f0102971:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102978:	00 
f0102979:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102980:	e8 bb d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102985:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f010298b:	89 da                	mov    %ebx,%edx
f010298d:	89 f8                	mov    %edi,%eax
f010298f:	e8 04 e1 ff ff       	call   f0100a98 <check_va2pa>
f0102994:	85 c0                	test   %eax,%eax
f0102996:	74 24                	je     f01029bc <mem_init+0x1620>
f0102998:	c7 44 24 0c 2c 6e 10 	movl   $0xf0106e2c,0xc(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01029a7:	f0 
f01029a8:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f01029af:	00 
f01029b0:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01029b7:	e8 84 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029bc:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01029c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029c5:	89 c2                	mov    %eax,%edx
f01029c7:	89 f8                	mov    %edi,%eax
f01029c9:	e8 ca e0 ff ff       	call   f0100a98 <check_va2pa>
f01029ce:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029d3:	74 24                	je     f01029f9 <mem_init+0x165d>
f01029d5:	c7 44 24 0c 50 6e 10 	movl   $0xf0106e50,0xc(%esp)
f01029dc:	f0 
f01029dd:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01029e4:	f0 
f01029e5:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01029ec:	00 
f01029ed:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01029f4:	e8 47 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029f9:	89 f2                	mov    %esi,%edx
f01029fb:	89 f8                	mov    %edi,%eax
f01029fd:	e8 96 e0 ff ff       	call   f0100a98 <check_va2pa>
f0102a02:	85 c0                	test   %eax,%eax
f0102a04:	74 24                	je     f0102a2a <mem_init+0x168e>
f0102a06:	c7 44 24 0c 80 6e 10 	movl   $0xf0106e80,0xc(%esp)
f0102a0d:	f0 
f0102a0e:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102a15:	f0 
f0102a16:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102a1d:	00 
f0102a1e:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102a25:	e8 16 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a2a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a30:	89 f8                	mov    %edi,%eax
f0102a32:	e8 61 e0 ff ff       	call   f0100a98 <check_va2pa>
f0102a37:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a3a:	74 24                	je     f0102a60 <mem_init+0x16c4>
f0102a3c:	c7 44 24 0c a4 6e 10 	movl   $0xf0106ea4,0xc(%esp)
f0102a43:	f0 
f0102a44:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102a4b:	f0 
f0102a4c:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102a53:	00 
f0102a54:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102a5b:	e8 e0 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a67:	00 
f0102a68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a6c:	89 3c 24             	mov    %edi,(%esp)
f0102a6f:	e8 1c e6 ff ff       	call   f0101090 <pgdir_walk>
f0102a74:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a77:	75 24                	jne    f0102a9d <mem_init+0x1701>
f0102a79:	c7 44 24 0c d0 6e 10 	movl   $0xf0106ed0,0xc(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102a88:	f0 
f0102a89:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a90:	00 
f0102a91:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102a98:	e8 a3 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102aa4:	00 
f0102aa5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102aa9:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102aae:	89 04 24             	mov    %eax,(%esp)
f0102ab1:	e8 da e5 ff ff       	call   f0101090 <pgdir_walk>
f0102ab6:	f6 00 04             	testb  $0x4,(%eax)
f0102ab9:	74 24                	je     f0102adf <mem_init+0x1743>
f0102abb:	c7 44 24 0c 14 6f 10 	movl   $0xf0106f14,0xc(%esp)
f0102ac2:	f0 
f0102ac3:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102aca:	f0 
f0102acb:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102ad2:	00 
f0102ad3:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102ada:	e8 61 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102adf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ae6:	00 
f0102ae7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102aeb:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102af0:	89 04 24             	mov    %eax,(%esp)
f0102af3:	e8 98 e5 ff ff       	call   f0101090 <pgdir_walk>
f0102af8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102afe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b05:	00 
f0102b06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b0d:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102b12:	89 04 24             	mov    %eax,(%esp)
f0102b15:	e8 76 e5 ff ff       	call   f0101090 <pgdir_walk>
f0102b1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b27:	00 
f0102b28:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b2c:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102b31:	89 04 24             	mov    %eax,(%esp)
f0102b34:	e8 57 e5 ff ff       	call   f0101090 <pgdir_walk>
f0102b39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b3f:	c7 04 24 19 74 10 f0 	movl   $0xf0107419,(%esp)
f0102b46:	e8 e9 13 00 00       	call   f0103f34 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b4b:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0102b50:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102b57:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b5d:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b67:	77 20                	ja     f0102b89 <mem_init+0x17ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b6d:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102b74:	f0 
f0102b75:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102b7c:	00 
f0102b7d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102b84:	e8 b7 d4 ff ff       	call   f0100040 <_panic>
f0102b89:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b90:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b91:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b96:	89 04 24             	mov    %eax,(%esp)
f0102b99:	89 d9                	mov    %ebx,%ecx
f0102b9b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102ba0:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102ba5:	e8 86 e5 ff ff       	call   f0101130 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102baa:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102bb6:	77 20                	ja     f0102bd8 <mem_init+0x183c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bbc:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102bc3:	f0 
f0102bc4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102bcb:	00 
f0102bcc:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102bd3:	e8 68 d4 ff ff       	call   f0100040 <_panic>
f0102bd8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102bdf:	00 
	return (physaddr_t)kva - KERNBASE;
f0102be0:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102be6:	89 04 24             	mov    %eax,(%esp)
f0102be9:	89 d9                	mov    %ebx,%ecx
f0102beb:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102bf0:	e8 3b e5 ff ff       	call   f0101130 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102bf5:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bfa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bff:	77 20                	ja     f0102c21 <mem_init+0x1885>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c01:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c05:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102c0c:	f0 
f0102c0d:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102c14:	00 
f0102c15:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102c1c:	e8 1f d4 ff ff       	call   f0100040 <_panic>
f0102c21:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c28:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c29:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c2e:	89 04 24             	mov    %eax,(%esp)
f0102c31:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c36:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c3b:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102c40:	e8 eb e4 ff ff       	call   f0101130 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102c45:	8b 15 48 a2 22 f0    	mov    0xf022a248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c4b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c51:	77 20                	ja     f0102c73 <mem_init+0x18d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c53:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c57:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102c5e:	f0 
f0102c5f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102c66:	00 
f0102c67:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102c6e:	e8 cd d3 ff ff       	call   f0100040 <_panic>
f0102c73:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c7a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c7b:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c81:	89 04 24             	mov    %eax,(%esp)
f0102c84:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c89:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102c8e:	e8 9d e4 ff ff       	call   f0101130 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c93:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0102c98:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c9d:	77 20                	ja     f0102cbf <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ca3:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102caa:	f0 
f0102cab:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102cb2:	00 
f0102cb3:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102cba:	e8 81 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102cbf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102cc6:	00 
f0102cc7:	c7 04 24 00 50 11 00 	movl   $0x115000,(%esp)
f0102cce:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cd3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102cd8:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102cdd:	e8 4e e4 ff ff       	call   f0101130 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102ce2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ce9:	00 
f0102cea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cf1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102cf6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102cfb:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102d00:	e8 2b e4 ff ff       	call   f0101130 <boot_map_region>
f0102d05:	bf 00 c0 26 f0       	mov    $0xf026c000,%edi
f0102d0a:	bb 00 c0 22 f0       	mov    $0xf022c000,%ebx
f0102d0f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d14:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d1a:	77 20                	ja     f0102d3c <mem_init+0x19a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d1c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d20:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102d27:	f0 
f0102d28:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102d2f:	00 
f0102d30:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102d37:	e8 04 d3 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102d3c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d43:	00 
f0102d44:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d4a:	89 04 24             	mov    %eax,(%esp)
f0102d4d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d52:	89 f2                	mov    %esi,%edx
f0102d54:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102d59:	e8 d2 e3 ff ff       	call   f0101130 <boot_map_region>
f0102d5e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d64:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
f0102d6a:	39 fb                	cmp    %edi,%ebx
f0102d6c:	75 a6                	jne    f0102d14 <mem_init+0x1978>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d6e:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d74:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0102d79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d7c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102d83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d88:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d8b:	8b 35 90 ae 22 f0    	mov    0xf022ae90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d91:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102d94:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102d9a:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102da2:	eb 6a                	jmp    f0102e0e <mem_init+0x1a72>
f0102da4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102daa:	89 f8                	mov    %edi,%eax
f0102dac:	e8 e7 dc ff ff       	call   f0100a98 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db1:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102db8:	77 20                	ja     f0102dda <mem_init+0x1a3e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dbe:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102dd5:	e8 66 d2 ff ff       	call   f0100040 <_panic>
f0102dda:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ddd:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102de0:	39 d0                	cmp    %edx,%eax
f0102de2:	74 24                	je     f0102e08 <mem_init+0x1a6c>
f0102de4:	c7 44 24 0c 48 6f 10 	movl   $0xf0106f48,0xc(%esp)
f0102deb:	f0 
f0102dec:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102df3:	f0 
f0102df4:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102dfb:	00 
f0102dfc:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102e03:	e8 38 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e08:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e0e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e11:	77 91                	ja     f0102da4 <mem_init+0x1a08>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e13:	8b 1d 48 a2 22 f0    	mov    0xf022a248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e19:	89 de                	mov    %ebx,%esi
f0102e1b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e20:	89 f8                	mov    %edi,%eax
f0102e22:	e8 71 dc ff ff       	call   f0100a98 <check_va2pa>
f0102e27:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e2d:	77 20                	ja     f0102e4f <mem_init+0x1ab3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e2f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e33:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102e3a:	f0 
f0102e3b:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e42:	00 
f0102e43:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102e4a:	e8 f1 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e4f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e54:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102e5a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e5d:	39 d0                	cmp    %edx,%eax
f0102e5f:	74 24                	je     f0102e85 <mem_init+0x1ae9>
f0102e61:	c7 44 24 0c 7c 6f 10 	movl   $0xf0106f7c,0xc(%esp)
f0102e68:	f0 
f0102e69:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102e70:	f0 
f0102e71:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e78:	00 
f0102e79:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102e80:	e8 bb d1 ff ff       	call   f0100040 <_panic>
f0102e85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e8b:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102e91:	0f 85 a8 05 00 00    	jne    f010343f <mem_init+0x20a3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e97:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e9a:	c1 e6 0c             	shl    $0xc,%esi
f0102e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ea2:	eb 3b                	jmp    f0102edf <mem_init+0x1b43>
f0102ea4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eaa:	89 f8                	mov    %edi,%eax
f0102eac:	e8 e7 db ff ff       	call   f0100a98 <check_va2pa>
f0102eb1:	39 c3                	cmp    %eax,%ebx
f0102eb3:	74 24                	je     f0102ed9 <mem_init+0x1b3d>
f0102eb5:	c7 44 24 0c b0 6f 10 	movl   $0xf0106fb0,0xc(%esp)
f0102ebc:	f0 
f0102ebd:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102ec4:	f0 
f0102ec5:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102ecc:	00 
f0102ecd:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102ed4:	e8 67 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ed9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102edf:	39 f3                	cmp    %esi,%ebx
f0102ee1:	72 c1                	jb     f0102ea4 <mem_init+0x1b08>
f0102ee3:	c7 45 d0 00 c0 22 f0 	movl   $0xf022c000,-0x30(%ebp)
f0102eea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102ef1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102ef6:	b8 00 c0 22 f0       	mov    $0xf022c000,%eax
f0102efb:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f00:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f03:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f09:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f0c:	89 f2                	mov    %esi,%edx
f0102f0e:	89 f8                	mov    %edi,%eax
f0102f10:	e8 83 db ff ff       	call   f0100a98 <check_va2pa>
f0102f15:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f18:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f1e:	77 20                	ja     f0102f40 <mem_init+0x1ba4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f20:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f24:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0102f2b:	f0 
f0102f2c:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f33:	00 
f0102f34:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102f3b:	e8 00 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f40:	89 f3                	mov    %esi,%ebx
f0102f42:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102f45:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102f48:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f4b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f4e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102f51:	39 c2                	cmp    %eax,%edx
f0102f53:	74 24                	je     f0102f79 <mem_init+0x1bdd>
f0102f55:	c7 44 24 0c d8 6f 10 	movl   $0xf0106fd8,0xc(%esp)
f0102f5c:	f0 
f0102f5d:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102f64:	f0 
f0102f65:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f6c:	00 
f0102f6d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102f74:	e8 c7 d0 ff ff       	call   f0100040 <_panic>
f0102f79:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f7f:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102f82:	0f 85 a9 04 00 00    	jne    f0103431 <mem_init+0x2095>
f0102f88:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f8e:	89 da                	mov    %ebx,%edx
f0102f90:	89 f8                	mov    %edi,%eax
f0102f92:	e8 01 db ff ff       	call   f0100a98 <check_va2pa>
f0102f97:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f9a:	74 24                	je     f0102fc0 <mem_init+0x1c24>
f0102f9c:	c7 44 24 0c 20 70 10 	movl   $0xf0107020,0xc(%esp)
f0102fa3:	f0 
f0102fa4:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0102fab:	f0 
f0102fac:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102fb3:	00 
f0102fb4:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0102fbb:	e8 80 d0 ff ff       	call   f0100040 <_panic>
f0102fc0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fc6:	39 de                	cmp    %ebx,%esi
f0102fc8:	75 c4                	jne    f0102f8e <mem_init+0x1bf2>
f0102fca:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102fd0:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0102fd7:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102fde:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102fe4:	0f 85 19 ff ff ff    	jne    f0102f03 <mem_init+0x1b67>
f0102fea:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fef:	e9 c2 00 00 00       	jmp    f01030b6 <mem_init+0x1d1a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102ff4:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ffa:	83 fa 04             	cmp    $0x4,%edx
f0102ffd:	77 2e                	ja     f010302d <mem_init+0x1c91>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102fff:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103003:	0f 85 aa 00 00 00    	jne    f01030b3 <mem_init+0x1d17>
f0103009:	c7 44 24 0c 32 74 10 	movl   $0xf0107432,0xc(%esp)
f0103010:	f0 
f0103011:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103018:	f0 
f0103019:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103020:	00 
f0103021:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103028:	e8 13 d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010302d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103032:	76 55                	jbe    f0103089 <mem_init+0x1ced>
				assert(pgdir[i] & PTE_P);
f0103034:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103037:	f6 c2 01             	test   $0x1,%dl
f010303a:	75 24                	jne    f0103060 <mem_init+0x1cc4>
f010303c:	c7 44 24 0c 32 74 10 	movl   $0xf0107432,0xc(%esp)
f0103043:	f0 
f0103044:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010304b:	f0 
f010304c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0103053:	00 
f0103054:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010305b:	e8 e0 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103060:	f6 c2 02             	test   $0x2,%dl
f0103063:	75 4e                	jne    f01030b3 <mem_init+0x1d17>
f0103065:	c7 44 24 0c 43 74 10 	movl   $0xf0107443,0xc(%esp)
f010306c:	f0 
f010306d:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103074:	f0 
f0103075:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010307c:	00 
f010307d:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103084:	e8 b7 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103089:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010308d:	74 24                	je     f01030b3 <mem_init+0x1d17>
f010308f:	c7 44 24 0c 54 74 10 	movl   $0xf0107454,0xc(%esp)
f0103096:	f0 
f0103097:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010309e:	f0 
f010309f:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01030a6:	00 
f01030a7:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01030ae:	e8 8d cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01030b3:	83 c0 01             	add    $0x1,%eax
f01030b6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030bb:	0f 85 33 ff ff ff    	jne    f0102ff4 <mem_init+0x1c58>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01030c1:	c7 04 24 44 70 10 f0 	movl   $0xf0107044,(%esp)
f01030c8:	e8 67 0e 00 00       	call   f0103f34 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01030cd:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01030d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d7:	77 20                	ja     f01030f9 <mem_init+0x1d5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030dd:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f01030e4:	f0 
f01030e5:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f01030ec:	00 
f01030ed:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01030f4:	e8 47 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030f9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030fe:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103101:	b8 00 00 00 00       	mov    $0x0,%eax
f0103106:	e8 fc d9 ff ff       	call   f0100b07 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010310b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010310e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103111:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103116:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103120:	e8 7d de ff ff       	call   f0100fa2 <page_alloc>
f0103125:	89 c3                	mov    %eax,%ebx
f0103127:	85 c0                	test   %eax,%eax
f0103129:	75 24                	jne    f010314f <mem_init+0x1db3>
f010312b:	c7 44 24 0c 3e 72 10 	movl   $0xf010723e,0xc(%esp)
f0103132:	f0 
f0103133:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010313a:	f0 
f010313b:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103142:	00 
f0103143:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010314a:	e8 f1 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010314f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103156:	e8 47 de ff ff       	call   f0100fa2 <page_alloc>
f010315b:	89 c7                	mov    %eax,%edi
f010315d:	85 c0                	test   %eax,%eax
f010315f:	75 24                	jne    f0103185 <mem_init+0x1de9>
f0103161:	c7 44 24 0c 54 72 10 	movl   $0xf0107254,0xc(%esp)
f0103168:	f0 
f0103169:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103170:	f0 
f0103171:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103178:	00 
f0103179:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103180:	e8 bb ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010318c:	e8 11 de ff ff       	call   f0100fa2 <page_alloc>
f0103191:	89 c6                	mov    %eax,%esi
f0103193:	85 c0                	test   %eax,%eax
f0103195:	75 24                	jne    f01031bb <mem_init+0x1e1f>
f0103197:	c7 44 24 0c 6a 72 10 	movl   $0xf010726a,0xc(%esp)
f010319e:	f0 
f010319f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01031a6:	f0 
f01031a7:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01031ae:	00 
f01031af:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01031b6:	e8 85 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031bb:	89 1c 24             	mov    %ebx,(%esp)
f01031be:	e8 6a de ff ff       	call   f010102d <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01031c3:	89 f8                	mov    %edi,%eax
f01031c5:	e8 89 d8 ff ff       	call   f0100a53 <page2kva>
f01031ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031d1:	00 
f01031d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031d9:	00 
f01031da:	89 04 24             	mov    %eax,(%esp)
f01031dd:	e8 e5 23 00 00       	call   f01055c7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f01031e2:	89 f0                	mov    %esi,%eax
f01031e4:	e8 6a d8 ff ff       	call   f0100a53 <page2kva>
f01031e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f0:	00 
f01031f1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031f8:	00 
f01031f9:	89 04 24             	mov    %eax,(%esp)
f01031fc:	e8 c6 23 00 00       	call   f01055c7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103201:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103208:	00 
f0103209:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103210:	00 
f0103211:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103215:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f010321a:	89 04 24             	mov    %eax,(%esp)
f010321d:	e8 72 e0 ff ff       	call   f0101294 <page_insert>
	assert(pp1->pp_ref == 1);
f0103222:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103227:	74 24                	je     f010324d <mem_init+0x1eb1>
f0103229:	c7 44 24 0c 3b 73 10 	movl   $0xf010733b,0xc(%esp)
f0103230:	f0 
f0103231:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103238:	f0 
f0103239:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103240:	00 
f0103241:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103248:	e8 f3 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010324d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103254:	01 01 01 
f0103257:	74 24                	je     f010327d <mem_init+0x1ee1>
f0103259:	c7 44 24 0c 64 70 10 	movl   $0xf0107064,0xc(%esp)
f0103260:	f0 
f0103261:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103268:	f0 
f0103269:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0103270:	00 
f0103271:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103278:	e8 c3 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010327d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103284:	00 
f0103285:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010328c:	00 
f010328d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103291:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0103296:	89 04 24             	mov    %eax,(%esp)
f0103299:	e8 f6 df ff ff       	call   f0101294 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010329e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032a5:	02 02 02 
f01032a8:	74 24                	je     f01032ce <mem_init+0x1f32>
f01032aa:	c7 44 24 0c 88 70 10 	movl   $0xf0107088,0xc(%esp)
f01032b1:	f0 
f01032b2:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01032b9:	f0 
f01032ba:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f01032c1:	00 
f01032c2:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01032c9:	e8 72 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032ce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01032d3:	74 24                	je     f01032f9 <mem_init+0x1f5d>
f01032d5:	c7 44 24 0c 5d 73 10 	movl   $0xf010735d,0xc(%esp)
f01032dc:	f0 
f01032dd:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01032e4:	f0 
f01032e5:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f01032ec:	00 
f01032ed:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01032f4:	e8 47 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032f9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032fe:	74 24                	je     f0103324 <mem_init+0x1f88>
f0103300:	c7 44 24 0c c7 73 10 	movl   $0xf01073c7,0xc(%esp)
f0103307:	f0 
f0103308:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010330f:	f0 
f0103310:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103317:	00 
f0103318:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010331f:	e8 1c cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103324:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010332b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010332e:	89 f0                	mov    %esi,%eax
f0103330:	e8 1e d7 ff ff       	call   f0100a53 <page2kva>
f0103335:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010333b:	74 24                	je     f0103361 <mem_init+0x1fc5>
f010333d:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0103344:	f0 
f0103345:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010334c:	f0 
f010334d:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103354:	00 
f0103355:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010335c:	e8 df cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103361:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103368:	00 
f0103369:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f010336e:	89 04 24             	mov    %eax,(%esp)
f0103371:	e8 c5 de ff ff       	call   f010123b <page_remove>
	assert(pp2->pp_ref == 0);
f0103376:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010337b:	74 24                	je     f01033a1 <mem_init+0x2005>
f010337d:	c7 44 24 0c 95 73 10 	movl   $0xf0107395,0xc(%esp)
f0103384:	f0 
f0103385:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f010338c:	f0 
f010338d:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f0103394:	00 
f0103395:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f010339c:	e8 9f cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033a1:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01033a6:	8b 08                	mov    (%eax),%ecx
f01033a8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033ae:	89 da                	mov    %ebx,%edx
f01033b0:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f01033b6:	c1 fa 03             	sar    $0x3,%edx
f01033b9:	c1 e2 0c             	shl    $0xc,%edx
f01033bc:	39 d1                	cmp    %edx,%ecx
f01033be:	74 24                	je     f01033e4 <mem_init+0x2048>
f01033c0:	c7 44 24 0c 34 6a 10 	movl   $0xf0106a34,0xc(%esp)
f01033c7:	f0 
f01033c8:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01033cf:	f0 
f01033d0:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f01033d7:	00 
f01033d8:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f01033df:	e8 5c cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01033e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01033ea:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01033ef:	74 24                	je     f0103415 <mem_init+0x2079>
f01033f1:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f01033f8:	f0 
f01033f9:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0103400:	f0 
f0103401:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103408:	00 
f0103409:	c7 04 24 47 71 10 f0 	movl   $0xf0107147,(%esp)
f0103410:	e8 2b cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103415:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010341b:	89 1c 24             	mov    %ebx,(%esp)
f010341e:	e8 0a dc ff ff       	call   f010102d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103423:	c7 04 24 d8 70 10 f0 	movl   $0xf01070d8,(%esp)
f010342a:	e8 05 0b 00 00       	call   f0103f34 <cprintf>
f010342f:	eb 1c                	jmp    f010344d <mem_init+0x20b1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103431:	89 da                	mov    %ebx,%edx
f0103433:	89 f8                	mov    %edi,%eax
f0103435:	e8 5e d6 ff ff       	call   f0100a98 <check_va2pa>
f010343a:	e9 0c fb ff ff       	jmp    f0102f4b <mem_init+0x1baf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010343f:	89 da                	mov    %ebx,%edx
f0103441:	89 f8                	mov    %edi,%eax
f0103443:	e8 50 d6 ff ff       	call   f0100a98 <check_va2pa>
f0103448:	e9 0d fa ff ff       	jmp    f0102e5a <mem_init+0x1abe>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010344d:	83 c4 4c             	add    $0x4c,%esp
f0103450:	5b                   	pop    %ebx
f0103451:	5e                   	pop    %esi
f0103452:	5f                   	pop    %edi
f0103453:	5d                   	pop    %ebp
f0103454:	c3                   	ret    

f0103455 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103455:	55                   	push   %ebp
f0103456:	89 e5                	mov    %esp,%ebp
f0103458:	57                   	push   %edi
f0103459:	56                   	push   %esi
f010345a:	53                   	push   %ebx
f010345b:	83 ec 1c             	sub    $0x1c,%esp
f010345e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103461:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103467:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010346d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103470:	03 45 10             	add    0x10(%ebp),%eax
f0103473:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103478:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010347d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f0103480:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103486:	76 5d                	jbe    f01034e5 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f0103488:	8b 45 0c             	mov    0xc(%ebp),%eax
f010348b:	a3 3c a2 22 f0       	mov    %eax,0xf022a23c
        return -E_FAULT;
f0103490:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103495:	eb 58                	jmp    f01034ef <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f0103497:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010349e:	00 
f010349f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034a3:	8b 47 60             	mov    0x60(%edi),%eax
f01034a6:	89 04 24             	mov    %eax,(%esp)
f01034a9:	e8 e2 db ff ff       	call   f0101090 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034ae:	85 c0                	test   %eax,%eax
f01034b0:	74 0c                	je     f01034be <user_mem_check+0x69>
f01034b2:	8b 00                	mov    (%eax),%eax
f01034b4:	a8 01                	test   $0x1,%al
f01034b6:	74 06                	je     f01034be <user_mem_check+0x69>
f01034b8:	21 f0                	and    %esi,%eax
f01034ba:	39 c6                	cmp    %eax,%esi
f01034bc:	74 21                	je     f01034df <user_mem_check+0x8a>
        {
            if (addr < va)
f01034be:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034c1:	76 0f                	jbe    f01034d2 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034c6:	a3 3c a2 22 f0       	mov    %eax,0xf022a23c
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034cb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034d0:	eb 1d                	jmp    f01034ef <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f01034d2:	89 1d 3c a2 22 f0    	mov    %ebx,0xf022a23c
            }
            
            return -E_FAULT;
f01034d8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034dd:	eb 10                	jmp    f01034ef <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f01034df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034e5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01034e8:	72 ad                	jb     f0103497 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f01034ea:	b8 00 00 00 00       	mov    $0x0,%eax

}
f01034ef:	83 c4 1c             	add    $0x1c,%esp
f01034f2:	5b                   	pop    %ebx
f01034f3:	5e                   	pop    %esi
f01034f4:	5f                   	pop    %edi
f01034f5:	5d                   	pop    %ebp
f01034f6:	c3                   	ret    

f01034f7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01034f7:	55                   	push   %ebp
f01034f8:	89 e5                	mov    %esp,%ebp
f01034fa:	53                   	push   %ebx
f01034fb:	83 ec 14             	sub    $0x14,%esp
f01034fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103501:	8b 45 14             	mov    0x14(%ebp),%eax
f0103504:	83 c8 04             	or     $0x4,%eax
f0103507:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010350b:	8b 45 10             	mov    0x10(%ebp),%eax
f010350e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103512:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103515:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103519:	89 1c 24             	mov    %ebx,(%esp)
f010351c:	e8 34 ff ff ff       	call   f0103455 <user_mem_check>
f0103521:	85 c0                	test   %eax,%eax
f0103523:	79 24                	jns    f0103549 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103525:	a1 3c a2 22 f0       	mov    0xf022a23c,%eax
f010352a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010352e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103531:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103535:	c7 04 24 04 71 10 f0 	movl   $0xf0107104,(%esp)
f010353c:	e8 f3 09 00 00       	call   f0103f34 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103541:	89 1c 24             	mov    %ebx,(%esp)
f0103544:	e8 02 07 00 00       	call   f0103c4b <env_destroy>
	}
}
f0103549:	83 c4 14             	add    $0x14,%esp
f010354c:	5b                   	pop    %ebx
f010354d:	5d                   	pop    %ebp
f010354e:	c3                   	ret    

f010354f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010354f:	55                   	push   %ebp
f0103550:	89 e5                	mov    %esp,%ebp
f0103552:	57                   	push   %edi
f0103553:	56                   	push   %esi
f0103554:	53                   	push   %ebx
f0103555:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f0103558:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f010355b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103567:	89 d1                	mov    %edx,%ecx
f0103569:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010356f:	29 c8                	sub    %ecx,%eax
f0103571:	c1 e8 0c             	shr    $0xc,%eax
f0103574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f0103577:	89 d6                	mov    %edx,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f0103579:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010357e:	eb 6d                	jmp    f01035ed <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f0103580:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103587:	e8 16 da ff ff       	call   f0100fa2 <page_alloc>
		if(newPage == 0)
f010358c:	85 c0                	test   %eax,%eax
f010358e:	75 1c                	jne    f01035ac <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f0103590:	c7 44 24 08 64 74 10 	movl   $0xf0107464,0x8(%esp)
f0103597:	f0 
f0103598:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f010359f:	00 
f01035a0:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f01035a7:	e8 94 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035ac:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035b3:	00 
f01035b4:	89 74 24 08          	mov    %esi,0x8(%esp)
f01035b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035bc:	89 3c 24             	mov    %edi,(%esp)
f01035bf:	e8 d0 dc ff ff       	call   f0101294 <page_insert>
f01035c4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f01035ca:	85 c0                	test   %eax,%eax
f01035cc:	74 1c                	je     f01035ea <region_alloc+0x9b>
			panic("page_insert fail\n");
f01035ce:	c7 44 24 08 9e 74 10 	movl   $0xf010749e,0x8(%esp)
f01035d5:	f0 
f01035d6:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01035dd:	00 
f01035de:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f01035e5:	e8 56 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035ea:	83 c3 01             	add    $0x1,%ebx
f01035ed:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01035f0:	7c 8e                	jl     f0103580 <region_alloc+0x31>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f01035f2:	83 c4 2c             	add    $0x2c,%esp
f01035f5:	5b                   	pop    %ebx
f01035f6:	5e                   	pop    %esi
f01035f7:	5f                   	pop    %edi
f01035f8:	5d                   	pop    %ebp
f01035f9:	c3                   	ret    

f01035fa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01035fa:	55                   	push   %ebp
f01035fb:	89 e5                	mov    %esp,%ebp
f01035fd:	56                   	push   %esi
f01035fe:	53                   	push   %ebx
f01035ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103602:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103605:	85 c0                	test   %eax,%eax
f0103607:	75 1a                	jne    f0103623 <envid2env+0x29>
		*env_store = curenv;
f0103609:	e8 0b 26 00 00       	call   f0105c19 <cpunum>
f010360e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103611:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103617:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010361a:	89 01                	mov    %eax,(%ecx)
		return 0;
f010361c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103621:	eb 70                	jmp    f0103693 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103623:	89 c3                	mov    %eax,%ebx
f0103625:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010362b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010362e:	03 1d 48 a2 22 f0    	add    0xf022a248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103634:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103638:	74 05                	je     f010363f <envid2env+0x45>
f010363a:	39 43 48             	cmp    %eax,0x48(%ebx)
f010363d:	74 10                	je     f010364f <envid2env+0x55>
		*env_store = 0;
f010363f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103642:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103648:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010364d:	eb 44                	jmp    f0103693 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010364f:	84 d2                	test   %dl,%dl
f0103651:	74 36                	je     f0103689 <envid2env+0x8f>
f0103653:	e8 c1 25 00 00       	call   f0105c19 <cpunum>
f0103658:	6b c0 74             	imul   $0x74,%eax,%eax
f010365b:	39 98 28 b0 22 f0    	cmp    %ebx,-0xfdd4fd8(%eax)
f0103661:	74 26                	je     f0103689 <envid2env+0x8f>
f0103663:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103666:	e8 ae 25 00 00       	call   f0105c19 <cpunum>
f010366b:	6b c0 74             	imul   $0x74,%eax,%eax
f010366e:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103674:	3b 70 48             	cmp    0x48(%eax),%esi
f0103677:	74 10                	je     f0103689 <envid2env+0x8f>
		*env_store = 0;
f0103679:	8b 45 0c             	mov    0xc(%ebp),%eax
f010367c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103682:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103687:	eb 0a                	jmp    f0103693 <envid2env+0x99>
	}

	*env_store = e;
f0103689:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368c:	89 18                	mov    %ebx,(%eax)
	return 0;
f010368e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103693:	5b                   	pop    %ebx
f0103694:	5e                   	pop    %esi
f0103695:	5d                   	pop    %ebp
f0103696:	c3                   	ret    

f0103697 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103697:	55                   	push   %ebp
f0103698:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010369a:	b8 20 f3 11 f0       	mov    $0xf011f320,%eax
f010369f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036a2:	b8 23 00 00 00       	mov    $0x23,%eax
f01036a7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036a9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036ab:	b0 10                	mov    $0x10,%al
f01036ad:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036af:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036b1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036b3:	ea ba 36 10 f0 08 00 	ljmp   $0x8,$0xf01036ba
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036ba:	b0 00                	mov    $0x0,%al
f01036bc:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036bf:	5d                   	pop    %ebp
f01036c0:	c3                   	ret    

f01036c1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036c1:	55                   	push   %ebp
f01036c2:	89 e5                	mov    %esp,%ebp
f01036c4:	56                   	push   %esi
f01036c5:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036c6:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
f01036cc:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01036d2:	ba 00 04 00 00       	mov    $0x400,%edx
f01036d7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01036dc:	89 c3                	mov    %eax,%ebx
f01036de:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01036e5:	89 48 44             	mov    %ecx,0x44(%eax)
f01036e8:	83 e8 7c             	sub    $0x7c,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f01036eb:	83 ea 01             	sub    $0x1,%edx
f01036ee:	74 04                	je     f01036f4 <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01036f0:	89 d9                	mov    %ebx,%ecx
f01036f2:	eb e8                	jmp    f01036dc <env_init+0x1b>
f01036f4:	89 35 4c a2 22 f0    	mov    %esi,0xf022a24c
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01036fa:	e8 98 ff ff ff       	call   f0103697 <env_init_percpu>
}
f01036ff:	5b                   	pop    %ebx
f0103700:	5e                   	pop    %esi
f0103701:	5d                   	pop    %ebp
f0103702:	c3                   	ret    

f0103703 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103703:	55                   	push   %ebp
f0103704:	89 e5                	mov    %esp,%ebp
f0103706:	53                   	push   %ebx
f0103707:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010370a:	8b 1d 4c a2 22 f0    	mov    0xf022a24c,%ebx
f0103710:	85 db                	test   %ebx,%ebx
f0103712:	0f 84 a7 01 00 00    	je     f01038bf <env_alloc+0x1bc>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103718:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010371f:	e8 7e d8 ff ff       	call   f0100fa2 <page_alloc>
f0103724:	85 c0                	test   %eax,%eax
f0103726:	0f 84 9a 01 00 00    	je     f01038c6 <env_alloc+0x1c3>
f010372c:	89 c2                	mov    %eax,%edx
f010372e:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0103734:	c1 fa 03             	sar    $0x3,%edx
f0103737:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010373a:	89 d1                	mov    %edx,%ecx
f010373c:	c1 e9 0c             	shr    $0xc,%ecx
f010373f:	3b 0d 88 ae 22 f0    	cmp    0xf022ae88,%ecx
f0103745:	72 20                	jb     f0103767 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103747:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010374b:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0103752:	f0 
f0103753:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010375a:	00 
f010375b:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0103762:	e8 d9 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103767:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010376d:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f0103770:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103775:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010377c:	00 
f010377d:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0103782:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103786:	8b 43 60             	mov    0x60(%ebx),%eax
f0103789:	89 04 24             	mov    %eax,(%esp)
f010378c:	e8 eb 1e 00 00       	call   f010567c <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f0103791:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f0103798:	00 
f0103799:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037a0:	00 
f01037a1:	8b 43 60             	mov    0x60(%ebx),%eax
f01037a4:	89 04 24             	mov    %eax,(%esp)
f01037a7:	e8 1b 1e 00 00       	call   f01055c7 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037ac:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b4:	77 20                	ja     f01037d6 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ba:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f01037c1:	f0 
f01037c2:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01037c9:	00 
f01037ca:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f01037d1:	e8 6a c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037d6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037dc:	83 ca 05             	or     $0x5,%edx
f01037df:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01037e5:	8b 43 48             	mov    0x48(%ebx),%eax
f01037e8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01037ed:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01037f2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01037f7:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01037fa:	89 da                	mov    %ebx,%edx
f01037fc:	2b 15 48 a2 22 f0    	sub    0xf022a248,%edx
f0103802:	c1 fa 02             	sar    $0x2,%edx
f0103805:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010380b:	09 d0                	or     %edx,%eax
f010380d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103810:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103813:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103816:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010381d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103824:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010382b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103832:	00 
f0103833:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010383a:	00 
f010383b:	89 1c 24             	mov    %ebx,(%esp)
f010383e:	e8 84 1d 00 00       	call   f01055c7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103843:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103849:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010384f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103855:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010385c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103862:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103869:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010386d:	8b 43 44             	mov    0x44(%ebx),%eax
f0103870:	a3 4c a2 22 f0       	mov    %eax,0xf022a24c
	*newenv_store = e;
f0103875:	8b 45 08             	mov    0x8(%ebp),%eax
f0103878:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010387a:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010387d:	e8 97 23 00 00       	call   f0105c19 <cpunum>
f0103882:	6b c0 74             	imul   $0x74,%eax,%eax
f0103885:	ba 00 00 00 00       	mov    $0x0,%edx
f010388a:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103891:	74 11                	je     f01038a4 <env_alloc+0x1a1>
f0103893:	e8 81 23 00 00       	call   f0105c19 <cpunum>
f0103898:	6b c0 74             	imul   $0x74,%eax,%eax
f010389b:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01038a1:	8b 50 48             	mov    0x48(%eax),%edx
f01038a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038a8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038ac:	c7 04 24 b0 74 10 f0 	movl   $0xf01074b0,(%esp)
f01038b3:	e8 7c 06 00 00       	call   f0103f34 <cprintf>
	return 0;
f01038b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01038bd:	eb 0c                	jmp    f01038cb <env_alloc+0x1c8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038bf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038c4:	eb 05                	jmp    f01038cb <env_alloc+0x1c8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038c6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038cb:	83 c4 14             	add    $0x14,%esp
f01038ce:	5b                   	pop    %ebx
f01038cf:	5d                   	pop    %ebp
f01038d0:	c3                   	ret    

f01038d1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038d1:	55                   	push   %ebp
f01038d2:	89 e5                	mov    %esp,%ebp
f01038d4:	57                   	push   %edi
f01038d5:	56                   	push   %esi
f01038d6:	53                   	push   %ebx
f01038d7:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f01038da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f01038e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038e8:	00 
f01038e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038ec:	89 04 24             	mov    %eax,(%esp)
f01038ef:	e8 0f fe ff ff       	call   f0103703 <env_alloc>
	if(r < 0)
f01038f4:	85 c0                	test   %eax,%eax
f01038f6:	79 1c                	jns    f0103914 <env_create+0x43>
		panic("env_create fault\n");
f01038f8:	c7 44 24 08 c5 74 10 	movl   $0xf01074c5,0x8(%esp)
f01038ff:	f0 
f0103900:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0103907:	00 
f0103908:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f010390f:	e8 2c c7 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010391a:	8b 45 08             	mov    0x8(%ebp),%eax
f010391d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103923:	74 1c                	je     f0103941 <env_create+0x70>
			panic("e_magic is not right\n");
f0103925:	c7 44 24 08 d7 74 10 	movl   $0xf01074d7,0x8(%esp)
f010392c:	f0 
f010392d:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103934:	00 
f0103935:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f010393c:	e8 ff c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103941:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103944:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103947:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010394c:	77 20                	ja     f010396e <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010394e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103952:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0103959:	f0 
f010395a:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103961:	00 
f0103962:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103969:	e8 d2 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010396e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103973:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f0103976:	8b 45 08             	mov    0x8(%ebp),%eax
f0103979:	89 c3                	mov    %eax,%ebx
f010397b:	03 58 1c             	add    0x1c(%eax),%ebx
f010397e:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f0103982:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f0103985:	be 01 00 00 00       	mov    $0x1,%esi
f010398a:	eb 54                	jmp    f01039e0 <env_create+0x10f>
		int i=0;
		for(; i<num; i++){
			ph++;
f010398c:	83 c3 20             	add    $0x20,%ebx
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f010398f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103992:	75 49                	jne    f01039dd <env_create+0x10c>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f0103994:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103997:	8b 53 08             	mov    0x8(%ebx),%edx
f010399a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010399d:	e8 ad fb ff ff       	call   f010354f <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039a2:	8b 43 10             	mov    0x10(%ebx),%eax
f01039a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ac:	03 43 04             	add    0x4(%ebx),%eax
f01039af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039b3:	8b 43 08             	mov    0x8(%ebx),%eax
f01039b6:	89 04 24             	mov    %eax,(%esp)
f01039b9:	e8 56 1c 00 00       	call   f0105614 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01039be:	8b 43 10             	mov    0x10(%ebx),%eax
f01039c1:	8b 53 14             	mov    0x14(%ebx),%edx
f01039c4:	29 c2                	sub    %eax,%edx
f01039c6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039d1:	00 
f01039d2:	03 43 08             	add    0x8(%ebx),%eax
f01039d5:	89 04 24             	mov    %eax,(%esp)
f01039d8:	e8 ea 1b 00 00       	call   f01055c7 <memset>
f01039dd:	83 c6 01             	add    $0x1,%esi

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f01039e0:	39 fe                	cmp    %edi,%esi
f01039e2:	75 a8                	jne    f010398c <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f01039e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01039e7:	8b 40 18             	mov    0x18(%eax),%eax
f01039ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01039ed:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f01039f0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01039f5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01039fa:	89 f8                	mov    %edi,%eax
f01039fc:	e8 4e fb ff ff       	call   f010354f <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a01:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a06:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a0b:	77 20                	ja     f0103a2d <env_create+0x15c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a11:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0103a18:	f0 
f0103a19:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103a20:	00 
f0103a21:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103a28:	e8 13 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a2d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a32:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a38:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a3b:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a3e:	83 c4 3c             	add    $0x3c,%esp
f0103a41:	5b                   	pop    %ebx
f0103a42:	5e                   	pop    %esi
f0103a43:	5f                   	pop    %edi
f0103a44:	5d                   	pop    %ebp
f0103a45:	c3                   	ret    

f0103a46 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a46:	55                   	push   %ebp
f0103a47:	89 e5                	mov    %esp,%ebp
f0103a49:	57                   	push   %edi
f0103a4a:	56                   	push   %esi
f0103a4b:	53                   	push   %ebx
f0103a4c:	83 ec 2c             	sub    $0x2c,%esp
f0103a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a52:	e8 c2 21 00 00       	call   f0105c19 <cpunum>
f0103a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a5a:	39 b8 28 b0 22 f0    	cmp    %edi,-0xfdd4fd8(%eax)
f0103a60:	75 34                	jne    f0103a96 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a62:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a6c:	77 20                	ja     f0103a8e <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a72:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0103a79:	f0 
f0103a7a:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103a81:	00 
f0103a82:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103a89:	e8 b2 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a8e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a93:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a96:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103a99:	e8 7b 21 00 00       	call   f0105c19 <cpunum>
f0103a9e:	6b d0 74             	imul   $0x74,%eax,%edx
f0103aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103aa6:	83 ba 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%edx)
f0103aad:	74 11                	je     f0103ac0 <env_free+0x7a>
f0103aaf:	e8 65 21 00 00       	call   f0105c19 <cpunum>
f0103ab4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab7:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103abd:	8b 40 48             	mov    0x48(%eax),%eax
f0103ac0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ac8:	c7 04 24 ed 74 10 f0 	movl   $0xf01074ed,(%esp)
f0103acf:	e8 60 04 00 00       	call   f0103f34 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ad4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103adb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ade:	89 c8                	mov    %ecx,%eax
f0103ae0:	c1 e0 02             	shl    $0x2,%eax
f0103ae3:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103ae6:	8b 47 60             	mov    0x60(%edi),%eax
f0103ae9:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103aec:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103af2:	0f 84 b7 00 00 00    	je     f0103baf <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103af8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103afe:	89 f0                	mov    %esi,%eax
f0103b00:	c1 e8 0c             	shr    $0xc,%eax
f0103b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b06:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0103b0c:	72 20                	jb     f0103b2e <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b0e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b12:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0103b19:	f0 
f0103b1a:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103b21:	00 
f0103b22:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103b29:	e8 12 c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b31:	c1 e0 16             	shl    $0x16,%eax
f0103b34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b37:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b3c:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b43:	01 
f0103b44:	74 17                	je     f0103b5d <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b46:	89 d8                	mov    %ebx,%eax
f0103b48:	c1 e0 0c             	shl    $0xc,%eax
f0103b4b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b52:	8b 47 60             	mov    0x60(%edi),%eax
f0103b55:	89 04 24             	mov    %eax,(%esp)
f0103b58:	e8 de d6 ff ff       	call   f010123b <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b5d:	83 c3 01             	add    $0x1,%ebx
f0103b60:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b66:	75 d4                	jne    f0103b3c <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b68:	8b 47 60             	mov    0x60(%edi),%eax
f0103b6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b6e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b75:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b78:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0103b7e:	72 1c                	jb     f0103b9c <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103b80:	c7 44 24 08 e0 68 10 	movl   $0xf01068e0,0x8(%esp)
f0103b87:	f0 
f0103b88:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b8f:	00 
f0103b90:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0103b97:	e8 a4 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b9c:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f0103ba1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ba4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103ba7:	89 04 24             	mov    %eax,(%esp)
f0103baa:	e8 be d4 ff ff       	call   f010106d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103baf:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bb3:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bba:	0f 85 1b ff ff ff    	jne    f0103adb <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bc0:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bc8:	77 20                	ja     f0103bea <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bce:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0103bd5:	f0 
f0103bd6:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103bdd:	00 
f0103bde:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103be5:	e8 56 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bea:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103bf1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bf6:	c1 e8 0c             	shr    $0xc,%eax
f0103bf9:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0103bff:	72 1c                	jb     f0103c1d <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103c01:	c7 44 24 08 e0 68 10 	movl   $0xf01068e0,0x8(%esp)
f0103c08:	f0 
f0103c09:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c10:	00 
f0103c11:	c7 04 24 39 71 10 f0 	movl   $0xf0107139,(%esp)
f0103c18:	e8 23 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c1d:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
f0103c23:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c26:	89 04 24             	mov    %eax,(%esp)
f0103c29:	e8 3f d4 ff ff       	call   f010106d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c2e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c35:	a1 4c a2 22 f0       	mov    0xf022a24c,%eax
f0103c3a:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c3d:	89 3d 4c a2 22 f0    	mov    %edi,0xf022a24c
}
f0103c43:	83 c4 2c             	add    $0x2c,%esp
f0103c46:	5b                   	pop    %ebx
f0103c47:	5e                   	pop    %esi
f0103c48:	5f                   	pop    %edi
f0103c49:	5d                   	pop    %ebp
f0103c4a:	c3                   	ret    

f0103c4b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c4b:	55                   	push   %ebp
f0103c4c:	89 e5                	mov    %esp,%ebp
f0103c4e:	53                   	push   %ebx
f0103c4f:	83 ec 14             	sub    $0x14,%esp
f0103c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c55:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c59:	75 19                	jne    f0103c74 <env_destroy+0x29>
f0103c5b:	e8 b9 1f 00 00       	call   f0105c19 <cpunum>
f0103c60:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c63:	39 98 28 b0 22 f0    	cmp    %ebx,-0xfdd4fd8(%eax)
f0103c69:	74 09                	je     f0103c74 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c6b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c72:	eb 2f                	jmp    f0103ca3 <env_destroy+0x58>
	}

	env_free(e);
f0103c74:	89 1c 24             	mov    %ebx,(%esp)
f0103c77:	e8 ca fd ff ff       	call   f0103a46 <env_free>

	if (curenv == e) {
f0103c7c:	e8 98 1f 00 00       	call   f0105c19 <cpunum>
f0103c81:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c84:	39 98 28 b0 22 f0    	cmp    %ebx,-0xfdd4fd8(%eax)
f0103c8a:	75 17                	jne    f0103ca3 <env_destroy+0x58>
		curenv = NULL;
f0103c8c:	e8 88 1f 00 00       	call   f0105c19 <cpunum>
f0103c91:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c94:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103c9b:	00 00 00 
		sched_yield();
f0103c9e:	e8 9a 0d 00 00       	call   f0104a3d <sched_yield>
	}
}
f0103ca3:	83 c4 14             	add    $0x14,%esp
f0103ca6:	5b                   	pop    %ebx
f0103ca7:	5d                   	pop    %ebp
f0103ca8:	c3                   	ret    

f0103ca9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ca9:	55                   	push   %ebp
f0103caa:	89 e5                	mov    %esp,%ebp
f0103cac:	53                   	push   %ebx
f0103cad:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cb0:	e8 64 1f 00 00       	call   f0105c19 <cpunum>
f0103cb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb8:	8b 98 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%ebx
f0103cbe:	e8 56 1f 00 00       	call   f0105c19 <cpunum>
f0103cc3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103cc6:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cc9:	61                   	popa   
f0103cca:	07                   	pop    %es
f0103ccb:	1f                   	pop    %ds
f0103ccc:	83 c4 08             	add    $0x8,%esp
f0103ccf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cd0:	c7 44 24 08 03 75 10 	movl   $0xf0107503,0x8(%esp)
f0103cd7:	f0 
f0103cd8:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0103cdf:	00 
f0103ce0:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103ce7:	e8 54 c3 ff ff       	call   f0100040 <_panic>

f0103cec <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103cec:	55                   	push   %ebp
f0103ced:	89 e5                	mov    %esp,%ebp
f0103cef:	53                   	push   %ebx
f0103cf0:	83 ec 14             	sub    $0x14,%esp
f0103cf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103cf6:	e8 1e 1f 00 00       	call   f0105c19 <cpunum>
f0103cfb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfe:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103d05:	75 10                	jne    f0103d17 <env_run+0x2b>
		curenv = e;
f0103d07:	e8 0d 1f 00 00       	call   f0105c19 <cpunum>
f0103d0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0f:	89 98 28 b0 22 f0    	mov    %ebx,-0xfdd4fd8(%eax)
f0103d15:	eb 29                	jmp    f0103d40 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d17:	e8 fd 1e 00 00       	call   f0105c19 <cpunum>
f0103d1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1f:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d25:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d29:	75 15                	jne    f0103d40 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d2b:	e8 e9 1e 00 00       	call   f0105c19 <cpunum>
f0103d30:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d33:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d39:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d40:	e8 d4 1e 00 00       	call   f0105c19 <cpunum>
f0103d45:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d48:	89 98 28 b0 22 f0    	mov    %ebx,-0xfdd4fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d4e:	e8 c6 1e 00 00       	call   f0105c19 <cpunum>
f0103d53:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d56:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d5c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d63:	e8 b1 1e 00 00       	call   f0105c19 <cpunum>
f0103d68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6b:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d71:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103d75:	e8 9f 1e 00 00       	call   f0105c19 <cpunum>
f0103d7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d83:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d8b:	77 20                	ja     f0103dad <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d91:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f0103d98:	f0 
f0103d99:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0103da0:	00 
f0103da1:	c7 04 24 93 74 10 f0 	movl   $0xf0107493,(%esp)
f0103da8:	e8 93 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103dad:	05 00 00 00 10       	add    $0x10000000,%eax
f0103db2:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(& (curenv->env_tf) );
f0103db5:	e8 5f 1e 00 00       	call   f0105c19 <cpunum>
f0103dba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dbd:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103dc3:	89 04 24             	mov    %eax,(%esp)
f0103dc6:	e8 de fe ff ff       	call   f0103ca9 <env_pop_tf>

f0103dcb <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dcb:	55                   	push   %ebp
f0103dcc:	89 e5                	mov    %esp,%ebp
f0103dce:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dd2:	ba 70 00 00 00       	mov    $0x70,%edx
f0103dd7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103dd8:	b2 71                	mov    $0x71,%dl
f0103dda:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103ddb:	0f b6 c0             	movzbl %al,%eax
}
f0103dde:	5d                   	pop    %ebp
f0103ddf:	c3                   	ret    

f0103de0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103de0:	55                   	push   %ebp
f0103de1:	89 e5                	mov    %esp,%ebp
f0103de3:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103de7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103dec:	ee                   	out    %al,(%dx)
f0103ded:	b2 71                	mov    $0x71,%dl
f0103def:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103df2:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103df3:	5d                   	pop    %ebp
f0103df4:	c3                   	ret    

f0103df5 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103df5:	55                   	push   %ebp
f0103df6:	89 e5                	mov    %esp,%ebp
f0103df8:	56                   	push   %esi
f0103df9:	53                   	push   %ebx
f0103dfa:	83 ec 10             	sub    $0x10,%esp
f0103dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e00:	66 a3 a8 f3 11 f0    	mov    %ax,0xf011f3a8
	if (!didinit)
f0103e06:	80 3d 50 a2 22 f0 00 	cmpb   $0x0,0xf022a250
f0103e0d:	74 4e                	je     f0103e5d <irq_setmask_8259A+0x68>
f0103e0f:	89 c6                	mov    %eax,%esi
f0103e11:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e16:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e17:	66 c1 e8 08          	shr    $0x8,%ax
f0103e1b:	b2 a1                	mov    $0xa1,%dl
f0103e1d:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e1e:	c7 04 24 0f 75 10 f0 	movl   $0xf010750f,(%esp)
f0103e25:	e8 0a 01 00 00       	call   f0103f34 <cprintf>
	for (i = 0; i < 16; i++)
f0103e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e2f:	0f b7 f6             	movzwl %si,%esi
f0103e32:	f7 d6                	not    %esi
f0103e34:	0f a3 de             	bt     %ebx,%esi
f0103e37:	73 10                	jae    f0103e49 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103e39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e3d:	c7 04 24 94 79 10 f0 	movl   $0xf0107994,(%esp)
f0103e44:	e8 eb 00 00 00       	call   f0103f34 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e49:	83 c3 01             	add    $0x1,%ebx
f0103e4c:	83 fb 10             	cmp    $0x10,%ebx
f0103e4f:	75 e3                	jne    f0103e34 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e51:	c7 04 24 30 74 10 f0 	movl   $0xf0107430,(%esp)
f0103e58:	e8 d7 00 00 00       	call   f0103f34 <cprintf>
}
f0103e5d:	83 c4 10             	add    $0x10,%esp
f0103e60:	5b                   	pop    %ebx
f0103e61:	5e                   	pop    %esi
f0103e62:	5d                   	pop    %ebp
f0103e63:	c3                   	ret    

f0103e64 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103e64:	c6 05 50 a2 22 f0 01 	movb   $0x1,0xf022a250
f0103e6b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e75:	ee                   	out    %al,(%dx)
f0103e76:	b2 a1                	mov    $0xa1,%dl
f0103e78:	ee                   	out    %al,(%dx)
f0103e79:	b2 20                	mov    $0x20,%dl
f0103e7b:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e80:	ee                   	out    %al,(%dx)
f0103e81:	b2 21                	mov    $0x21,%dl
f0103e83:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e88:	ee                   	out    %al,(%dx)
f0103e89:	b8 04 00 00 00       	mov    $0x4,%eax
f0103e8e:	ee                   	out    %al,(%dx)
f0103e8f:	b8 03 00 00 00       	mov    $0x3,%eax
f0103e94:	ee                   	out    %al,(%dx)
f0103e95:	b2 a0                	mov    $0xa0,%dl
f0103e97:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e9c:	ee                   	out    %al,(%dx)
f0103e9d:	b2 a1                	mov    $0xa1,%dl
f0103e9f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ea4:	ee                   	out    %al,(%dx)
f0103ea5:	b8 02 00 00 00       	mov    $0x2,%eax
f0103eaa:	ee                   	out    %al,(%dx)
f0103eab:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eb0:	ee                   	out    %al,(%dx)
f0103eb1:	b2 20                	mov    $0x20,%dl
f0103eb3:	b8 68 00 00 00       	mov    $0x68,%eax
f0103eb8:	ee                   	out    %al,(%dx)
f0103eb9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ebe:	ee                   	out    %al,(%dx)
f0103ebf:	b2 a0                	mov    $0xa0,%dl
f0103ec1:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ec6:	ee                   	out    %al,(%dx)
f0103ec7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ecc:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103ecd:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f0103ed4:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ed8:	74 12                	je     f0103eec <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103eda:	55                   	push   %ebp
f0103edb:	89 e5                	mov    %esp,%ebp
f0103edd:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103ee0:	0f b7 c0             	movzwl %ax,%eax
f0103ee3:	89 04 24             	mov    %eax,(%esp)
f0103ee6:	e8 0a ff ff ff       	call   f0103df5 <irq_setmask_8259A>
}
f0103eeb:	c9                   	leave  
f0103eec:	f3 c3                	repz ret 

f0103eee <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103eee:	55                   	push   %ebp
f0103eef:	89 e5                	mov    %esp,%ebp
f0103ef1:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ef7:	89 04 24             	mov    %eax,(%esp)
f0103efa:	e8 6b c8 ff ff       	call   f010076a <cputchar>
	*cnt++;
}
f0103eff:	c9                   	leave  
f0103f00:	c3                   	ret    

f0103f01 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f01:	55                   	push   %ebp
f0103f02:	89 e5                	mov    %esp,%ebp
f0103f04:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f11:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f15:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f18:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f23:	c7 04 24 ee 3e 10 f0 	movl   $0xf0103eee,(%esp)
f0103f2a:	e8 55 0f 00 00       	call   f0104e84 <vprintfmt>
	return cnt;
}
f0103f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f32:	c9                   	leave  
f0103f33:	c3                   	ret    

f0103f34 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f34:	55                   	push   %ebp
f0103f35:	89 e5                	mov    %esp,%ebp
f0103f37:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f3a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f41:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f44:	89 04 24             	mov    %eax,(%esp)
f0103f47:	e8 b5 ff ff ff       	call   f0103f01 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f4c:	c9                   	leave  
f0103f4d:	c3                   	ret    
f0103f4e:	66 90                	xchg   %ax,%ax

f0103f50 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f50:	55                   	push   %ebp
f0103f51:	89 e5                	mov    %esp,%ebp
f0103f53:	57                   	push   %edi
f0103f54:	56                   	push   %esi
f0103f55:	53                   	push   %ebx
f0103f56:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103f59:	e8 bb 1c 00 00       	call   f0105c19 <cpunum>
f0103f5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f61:	0f b6 98 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103f68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f6c:	c7 04 24 23 75 10 f0 	movl   $0xf0107523,(%esp)
f0103f73:	e8 bc ff ff ff       	call   f0103f34 <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103f78:	e8 9c 1c 00 00       	call   f0105c19 <cpunum>
f0103f7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f80:	89 da                	mov    %ebx,%edx
f0103f82:	f7 da                	neg    %edx
f0103f84:	c1 e2 10             	shl    $0x10,%edx
f0103f87:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103f8d:	89 90 30 b0 22 f0    	mov    %edx,-0xfdd4fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103f93:	e8 81 1c 00 00       	call   f0105c19 <cpunum>
f0103f98:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9b:	66 c7 80 34 b0 22 f0 	movw   $0x10,-0xfdd4fcc(%eax)
f0103fa2:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0103fa4:	83 c3 05             	add    $0x5,%ebx
f0103fa7:	e8 6d 1c 00 00       	call   f0105c19 <cpunum>
f0103fac:	89 c7                	mov    %eax,%edi
f0103fae:	e8 66 1c 00 00       	call   f0105c19 <cpunum>
f0103fb3:	89 c6                	mov    %eax,%esi
f0103fb5:	e8 5f 1c 00 00       	call   f0105c19 <cpunum>
f0103fba:	66 c7 04 dd 40 f3 11 	movw   $0x67,-0xfee0cc0(,%ebx,8)
f0103fc1:	f0 67 00 
f0103fc4:	6b ff 74             	imul   $0x74,%edi,%edi
f0103fc7:	81 c7 2c b0 22 f0    	add    $0xf022b02c,%edi
f0103fcd:	66 89 3c dd 42 f3 11 	mov    %di,-0xfee0cbe(,%ebx,8)
f0103fd4:	f0 
f0103fd5:	6b d6 74             	imul   $0x74,%esi,%edx
f0103fd8:	81 c2 2c b0 22 f0    	add    $0xf022b02c,%edx
f0103fde:	c1 ea 10             	shr    $0x10,%edx
f0103fe1:	88 14 dd 44 f3 11 f0 	mov    %dl,-0xfee0cbc(,%ebx,8)
f0103fe8:	c6 04 dd 46 f3 11 f0 	movb   $0x40,-0xfee0cba(,%ebx,8)
f0103fef:	40 
f0103ff0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff3:	05 2c b0 22 f0       	add    $0xf022b02c,%eax
f0103ff8:	c1 e8 18             	shr    $0x18,%eax
f0103ffb:	88 04 dd 47 f3 11 f0 	mov    %al,-0xfee0cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104002:	c6 04 dd 45 f3 11 f0 	movb   $0x89,-0xfee0cbb(,%ebx,8)
f0104009:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010400a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010400d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104010:	b8 aa f3 11 f0       	mov    $0xf011f3aa,%eax
f0104015:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104018:	83 c4 1c             	add    $0x1c,%esp
f010401b:	5b                   	pop    %ebx
f010401c:	5e                   	pop    %esi
f010401d:	5f                   	pop    %edi
f010401e:	5d                   	pop    %ebp
f010401f:	c3                   	ret    

f0104020 <trap_init>:
}


void
trap_init(void)
{
f0104020:	55                   	push   %ebp
f0104021:	89 e5                	mov    %esp,%ebp
f0104023:	83 ec 08             	sub    $0x8,%esp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104026:	b8 92 48 10 f0       	mov    $0xf0104892,%eax
f010402b:	66 a3 60 a2 22 f0    	mov    %ax,0xf022a260
f0104031:	66 c7 05 62 a2 22 f0 	movw   $0x8,0xf022a262
f0104038:	08 00 
f010403a:	c6 05 64 a2 22 f0 00 	movb   $0x0,0xf022a264
f0104041:	c6 05 65 a2 22 f0 8e 	movb   $0x8e,0xf022a265
f0104048:	c1 e8 10             	shr    $0x10,%eax
f010404b:	66 a3 66 a2 22 f0    	mov    %ax,0xf022a266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f0104051:	b8 9c 48 10 f0       	mov    $0xf010489c,%eax
f0104056:	66 a3 68 a2 22 f0    	mov    %ax,0xf022a268
f010405c:	66 c7 05 6a a2 22 f0 	movw   $0x8,0xf022a26a
f0104063:	08 00 
f0104065:	c6 05 6c a2 22 f0 00 	movb   $0x0,0xf022a26c
f010406c:	c6 05 6d a2 22 f0 8e 	movb   $0x8e,0xf022a26d
f0104073:	c1 e8 10             	shr    $0x10,%eax
f0104076:	66 a3 6e a2 22 f0    	mov    %ax,0xf022a26e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f010407c:	b8 a6 48 10 f0       	mov    $0xf01048a6,%eax
f0104081:	66 a3 70 a2 22 f0    	mov    %ax,0xf022a270
f0104087:	66 c7 05 72 a2 22 f0 	movw   $0x8,0xf022a272
f010408e:	08 00 
f0104090:	c6 05 74 a2 22 f0 00 	movb   $0x0,0xf022a274
f0104097:	c6 05 75 a2 22 f0 8e 	movb   $0x8e,0xf022a275
f010409e:	c1 e8 10             	shr    $0x10,%eax
f01040a1:	66 a3 76 a2 22 f0    	mov    %ax,0xf022a276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01040a7:	b8 b0 48 10 f0       	mov    $0xf01048b0,%eax
f01040ac:	66 a3 78 a2 22 f0    	mov    %ax,0xf022a278
f01040b2:	66 c7 05 7a a2 22 f0 	movw   $0x8,0xf022a27a
f01040b9:	08 00 
f01040bb:	c6 05 7c a2 22 f0 00 	movb   $0x0,0xf022a27c
f01040c2:	c6 05 7d a2 22 f0 ee 	movb   $0xee,0xf022a27d
f01040c9:	c1 e8 10             	shr    $0x10,%eax
f01040cc:	66 a3 7e a2 22 f0    	mov    %ax,0xf022a27e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f01040d2:	b8 ba 48 10 f0       	mov    $0xf01048ba,%eax
f01040d7:	66 a3 80 a2 22 f0    	mov    %ax,0xf022a280
f01040dd:	66 c7 05 82 a2 22 f0 	movw   $0x8,0xf022a282
f01040e4:	08 00 
f01040e6:	c6 05 84 a2 22 f0 00 	movb   $0x0,0xf022a284
f01040ed:	c6 05 85 a2 22 f0 8e 	movb   $0x8e,0xf022a285
f01040f4:	c1 e8 10             	shr    $0x10,%eax
f01040f7:	66 a3 86 a2 22 f0    	mov    %ax,0xf022a286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f01040fd:	b8 c4 48 10 f0       	mov    $0xf01048c4,%eax
f0104102:	66 a3 88 a2 22 f0    	mov    %ax,0xf022a288
f0104108:	66 c7 05 8a a2 22 f0 	movw   $0x8,0xf022a28a
f010410f:	08 00 
f0104111:	c6 05 8c a2 22 f0 00 	movb   $0x0,0xf022a28c
f0104118:	c6 05 8d a2 22 f0 8e 	movb   $0x8e,0xf022a28d
f010411f:	c1 e8 10             	shr    $0x10,%eax
f0104122:	66 a3 8e a2 22 f0    	mov    %ax,0xf022a28e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104128:	b8 ce 48 10 f0       	mov    $0xf01048ce,%eax
f010412d:	66 a3 90 a2 22 f0    	mov    %ax,0xf022a290
f0104133:	66 c7 05 92 a2 22 f0 	movw   $0x8,0xf022a292
f010413a:	08 00 
f010413c:	c6 05 94 a2 22 f0 00 	movb   $0x0,0xf022a294
f0104143:	c6 05 95 a2 22 f0 8e 	movb   $0x8e,0xf022a295
f010414a:	c1 e8 10             	shr    $0x10,%eax
f010414d:	66 a3 96 a2 22 f0    	mov    %ax,0xf022a296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f0104153:	b8 d8 48 10 f0       	mov    $0xf01048d8,%eax
f0104158:	66 a3 98 a2 22 f0    	mov    %ax,0xf022a298
f010415e:	66 c7 05 9a a2 22 f0 	movw   $0x8,0xf022a29a
f0104165:	08 00 
f0104167:	c6 05 9c a2 22 f0 00 	movb   $0x0,0xf022a29c
f010416e:	c6 05 9d a2 22 f0 8e 	movb   $0x8e,0xf022a29d
f0104175:	c1 e8 10             	shr    $0x10,%eax
f0104178:	66 a3 9e a2 22 f0    	mov    %ax,0xf022a29e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f010417e:	b8 e2 48 10 f0       	mov    $0xf01048e2,%eax
f0104183:	66 a3 a0 a2 22 f0    	mov    %ax,0xf022a2a0
f0104189:	66 c7 05 a2 a2 22 f0 	movw   $0x8,0xf022a2a2
f0104190:	08 00 
f0104192:	c6 05 a4 a2 22 f0 00 	movb   $0x0,0xf022a2a4
f0104199:	c6 05 a5 a2 22 f0 8e 	movb   $0x8e,0xf022a2a5
f01041a0:	c1 e8 10             	shr    $0x10,%eax
f01041a3:	66 a3 a6 a2 22 f0    	mov    %ax,0xf022a2a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01041a9:	b8 ea 48 10 f0       	mov    $0xf01048ea,%eax
f01041ae:	66 a3 a8 a2 22 f0    	mov    %ax,0xf022a2a8
f01041b4:	66 c7 05 aa a2 22 f0 	movw   $0x8,0xf022a2aa
f01041bb:	08 00 
f01041bd:	c6 05 ac a2 22 f0 00 	movb   $0x0,0xf022a2ac
f01041c4:	c6 05 ad a2 22 f0 8e 	movb   $0x8e,0xf022a2ad
f01041cb:	c1 e8 10             	shr    $0x10,%eax
f01041ce:	66 a3 ae a2 22 f0    	mov    %ax,0xf022a2ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f01041d4:	b8 f4 48 10 f0       	mov    $0xf01048f4,%eax
f01041d9:	66 a3 b0 a2 22 f0    	mov    %ax,0xf022a2b0
f01041df:	66 c7 05 b2 a2 22 f0 	movw   $0x8,0xf022a2b2
f01041e6:	08 00 
f01041e8:	c6 05 b4 a2 22 f0 00 	movb   $0x0,0xf022a2b4
f01041ef:	c6 05 b5 a2 22 f0 8e 	movb   $0x8e,0xf022a2b5
f01041f6:	c1 e8 10             	shr    $0x10,%eax
f01041f9:	66 a3 b6 a2 22 f0    	mov    %ax,0xf022a2b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f01041ff:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f0104204:	66 a3 b8 a2 22 f0    	mov    %ax,0xf022a2b8
f010420a:	66 c7 05 ba a2 22 f0 	movw   $0x8,0xf022a2ba
f0104211:	08 00 
f0104213:	c6 05 bc a2 22 f0 00 	movb   $0x0,0xf022a2bc
f010421a:	c6 05 bd a2 22 f0 8e 	movb   $0x8e,0xf022a2bd
f0104221:	c1 e8 10             	shr    $0x10,%eax
f0104224:	66 a3 be a2 22 f0    	mov    %ax,0xf022a2be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010422a:	b8 04 49 10 f0       	mov    $0xf0104904,%eax
f010422f:	66 a3 c0 a2 22 f0    	mov    %ax,0xf022a2c0
f0104235:	66 c7 05 c2 a2 22 f0 	movw   $0x8,0xf022a2c2
f010423c:	08 00 
f010423e:	c6 05 c4 a2 22 f0 00 	movb   $0x0,0xf022a2c4
f0104245:	c6 05 c5 a2 22 f0 8e 	movb   $0x8e,0xf022a2c5
f010424c:	c1 e8 10             	shr    $0x10,%eax
f010424f:	66 a3 c6 a2 22 f0    	mov    %ax,0xf022a2c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f0104255:	b8 0c 49 10 f0       	mov    $0xf010490c,%eax
f010425a:	66 a3 c8 a2 22 f0    	mov    %ax,0xf022a2c8
f0104260:	66 c7 05 ca a2 22 f0 	movw   $0x8,0xf022a2ca
f0104267:	08 00 
f0104269:	c6 05 cc a2 22 f0 00 	movb   $0x0,0xf022a2cc
f0104270:	c6 05 cd a2 22 f0 8e 	movb   $0x8e,0xf022a2cd
f0104277:	c1 e8 10             	shr    $0x10,%eax
f010427a:	66 a3 ce a2 22 f0    	mov    %ax,0xf022a2ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f0104280:	b8 14 49 10 f0       	mov    $0xf0104914,%eax
f0104285:	66 a3 d0 a2 22 f0    	mov    %ax,0xf022a2d0
f010428b:	66 c7 05 d2 a2 22 f0 	movw   $0x8,0xf022a2d2
f0104292:	08 00 
f0104294:	c6 05 d4 a2 22 f0 00 	movb   $0x0,0xf022a2d4
f010429b:	c6 05 d5 a2 22 f0 8e 	movb   $0x8e,0xf022a2d5
f01042a2:	c1 e8 10             	shr    $0x10,%eax
f01042a5:	66 a3 d6 a2 22 f0    	mov    %ax,0xf022a2d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01042ab:	b8 1c 49 10 f0       	mov    $0xf010491c,%eax
f01042b0:	66 a3 d8 a2 22 f0    	mov    %ax,0xf022a2d8
f01042b6:	66 c7 05 da a2 22 f0 	movw   $0x8,0xf022a2da
f01042bd:	08 00 
f01042bf:	c6 05 dc a2 22 f0 00 	movb   $0x0,0xf022a2dc
f01042c6:	c6 05 dd a2 22 f0 8e 	movb   $0x8e,0xf022a2dd
f01042cd:	c1 e8 10             	shr    $0x10,%eax
f01042d0:	66 a3 de a2 22 f0    	mov    %ax,0xf022a2de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f01042d6:	b8 26 49 10 f0       	mov    $0xf0104926,%eax
f01042db:	66 a3 e0 a2 22 f0    	mov    %ax,0xf022a2e0
f01042e1:	66 c7 05 e2 a2 22 f0 	movw   $0x8,0xf022a2e2
f01042e8:	08 00 
f01042ea:	c6 05 e4 a2 22 f0 00 	movb   $0x0,0xf022a2e4
f01042f1:	c6 05 e5 a2 22 f0 8e 	movb   $0x8e,0xf022a2e5
f01042f8:	c1 e8 10             	shr    $0x10,%eax
f01042fb:	66 a3 e6 a2 22 f0    	mov    %ax,0xf022a2e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104301:	b8 30 49 10 f0       	mov    $0xf0104930,%eax
f0104306:	66 a3 e8 a2 22 f0    	mov    %ax,0xf022a2e8
f010430c:	66 c7 05 ea a2 22 f0 	movw   $0x8,0xf022a2ea
f0104313:	08 00 
f0104315:	c6 05 ec a2 22 f0 00 	movb   $0x0,0xf022a2ec
f010431c:	c6 05 ed a2 22 f0 8e 	movb   $0x8e,0xf022a2ed
f0104323:	c1 e8 10             	shr    $0x10,%eax
f0104326:	66 a3 ee a2 22 f0    	mov    %ax,0xf022a2ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010432c:	b8 38 49 10 f0       	mov    $0xf0104938,%eax
f0104331:	66 a3 f0 a2 22 f0    	mov    %ax,0xf022a2f0
f0104337:	66 c7 05 f2 a2 22 f0 	movw   $0x8,0xf022a2f2
f010433e:	08 00 
f0104340:	c6 05 f4 a2 22 f0 00 	movb   $0x0,0xf022a2f4
f0104347:	c6 05 f5 a2 22 f0 8e 	movb   $0x8e,0xf022a2f5
f010434e:	c1 e8 10             	shr    $0x10,%eax
f0104351:	66 a3 f6 a2 22 f0    	mov    %ax,0xf022a2f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f0104357:	b8 42 49 10 f0       	mov    $0xf0104942,%eax
f010435c:	66 a3 f8 a2 22 f0    	mov    %ax,0xf022a2f8
f0104362:	66 c7 05 fa a2 22 f0 	movw   $0x8,0xf022a2fa
f0104369:	08 00 
f010436b:	c6 05 fc a2 22 f0 00 	movb   $0x0,0xf022a2fc
f0104372:	c6 05 fd a2 22 f0 8e 	movb   $0x8e,0xf022a2fd
f0104379:	c1 e8 10             	shr    $0x10,%eax
f010437c:	66 a3 fe a2 22 f0    	mov    %ax,0xf022a2fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104382:	b8 4c 49 10 f0       	mov    $0xf010494c,%eax
f0104387:	66 a3 e0 a3 22 f0    	mov    %ax,0xf022a3e0
f010438d:	66 c7 05 e2 a3 22 f0 	movw   $0x8,0xf022a3e2
f0104394:	08 00 
f0104396:	c6 05 e4 a3 22 f0 00 	movb   $0x0,0xf022a3e4
f010439d:	c6 05 e5 a3 22 f0 ee 	movb   $0xee,0xf022a3e5
f01043a4:	c1 e8 10             	shr    $0x10,%eax
f01043a7:	66 a3 e6 a3 22 f0    	mov    %ax,0xf022a3e6




	// Per-CPU setup 
	trap_init_percpu();
f01043ad:	e8 9e fb ff ff       	call   f0103f50 <trap_init_percpu>
}
f01043b2:	c9                   	leave  
f01043b3:	c3                   	ret    

f01043b4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01043b4:	55                   	push   %ebp
f01043b5:	89 e5                	mov    %esp,%ebp
f01043b7:	53                   	push   %ebx
f01043b8:	83 ec 14             	sub    $0x14,%esp
f01043bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043be:	8b 03                	mov    (%ebx),%eax
f01043c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043c4:	c7 04 24 31 75 10 f0 	movl   $0xf0107531,(%esp)
f01043cb:	e8 64 fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043d0:	8b 43 04             	mov    0x4(%ebx),%eax
f01043d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043d7:	c7 04 24 40 75 10 f0 	movl   $0xf0107540,(%esp)
f01043de:	e8 51 fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043e3:	8b 43 08             	mov    0x8(%ebx),%eax
f01043e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043ea:	c7 04 24 4f 75 10 f0 	movl   $0xf010754f,(%esp)
f01043f1:	e8 3e fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043f6:	8b 43 0c             	mov    0xc(%ebx),%eax
f01043f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043fd:	c7 04 24 5e 75 10 f0 	movl   $0xf010755e,(%esp)
f0104404:	e8 2b fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104409:	8b 43 10             	mov    0x10(%ebx),%eax
f010440c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104410:	c7 04 24 6d 75 10 f0 	movl   $0xf010756d,(%esp)
f0104417:	e8 18 fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010441c:	8b 43 14             	mov    0x14(%ebx),%eax
f010441f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104423:	c7 04 24 7c 75 10 f0 	movl   $0xf010757c,(%esp)
f010442a:	e8 05 fb ff ff       	call   f0103f34 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010442f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104432:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104436:	c7 04 24 8b 75 10 f0 	movl   $0xf010758b,(%esp)
f010443d:	e8 f2 fa ff ff       	call   f0103f34 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104442:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104445:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104449:	c7 04 24 9a 75 10 f0 	movl   $0xf010759a,(%esp)
f0104450:	e8 df fa ff ff       	call   f0103f34 <cprintf>
}
f0104455:	83 c4 14             	add    $0x14,%esp
f0104458:	5b                   	pop    %ebx
f0104459:	5d                   	pop    %ebp
f010445a:	c3                   	ret    

f010445b <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f010445b:	55                   	push   %ebp
f010445c:	89 e5                	mov    %esp,%ebp
f010445e:	56                   	push   %esi
f010445f:	53                   	push   %ebx
f0104460:	83 ec 10             	sub    $0x10,%esp
f0104463:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104466:	e8 ae 17 00 00       	call   f0105c19 <cpunum>
f010446b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010446f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104473:	c7 04 24 fe 75 10 f0 	movl   $0xf01075fe,(%esp)
f010447a:	e8 b5 fa ff ff       	call   f0103f34 <cprintf>
	print_regs(&tf->tf_regs);
f010447f:	89 1c 24             	mov    %ebx,(%esp)
f0104482:	e8 2d ff ff ff       	call   f01043b4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104487:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010448b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010448f:	c7 04 24 1c 76 10 f0 	movl   $0xf010761c,(%esp)
f0104496:	e8 99 fa ff ff       	call   f0103f34 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010449b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010449f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a3:	c7 04 24 2f 76 10 f0 	movl   $0xf010762f,(%esp)
f01044aa:	e8 85 fa ff ff       	call   f0103f34 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044af:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01044b2:	83 f8 13             	cmp    $0x13,%eax
f01044b5:	77 09                	ja     f01044c0 <print_trapframe+0x65>
		return excnames[trapno];
f01044b7:	8b 14 85 c0 78 10 f0 	mov    -0xfef8740(,%eax,4),%edx
f01044be:	eb 1f                	jmp    f01044df <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01044c0:	83 f8 30             	cmp    $0x30,%eax
f01044c3:	74 15                	je     f01044da <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01044c5:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01044c8:	83 fa 0f             	cmp    $0xf,%edx
f01044cb:	ba b5 75 10 f0       	mov    $0xf01075b5,%edx
f01044d0:	b9 c8 75 10 f0       	mov    $0xf01075c8,%ecx
f01044d5:	0f 47 d1             	cmova  %ecx,%edx
f01044d8:	eb 05                	jmp    f01044df <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01044da:	ba a9 75 10 f0       	mov    $0xf01075a9,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044df:	89 54 24 08          	mov    %edx,0x8(%esp)
f01044e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e7:	c7 04 24 42 76 10 f0 	movl   $0xf0107642,(%esp)
f01044ee:	e8 41 fa ff ff       	call   f0103f34 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01044f3:	3b 1d 60 aa 22 f0    	cmp    0xf022aa60,%ebx
f01044f9:	75 19                	jne    f0104514 <print_trapframe+0xb9>
f01044fb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044ff:	75 13                	jne    f0104514 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104501:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104504:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104508:	c7 04 24 54 76 10 f0 	movl   $0xf0107654,(%esp)
f010450f:	e8 20 fa ff ff       	call   f0103f34 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104514:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104517:	89 44 24 04          	mov    %eax,0x4(%esp)
f010451b:	c7 04 24 63 76 10 f0 	movl   $0xf0107663,(%esp)
f0104522:	e8 0d fa ff ff       	call   f0103f34 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104527:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010452b:	75 51                	jne    f010457e <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010452d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104530:	89 c2                	mov    %eax,%edx
f0104532:	83 e2 01             	and    $0x1,%edx
f0104535:	ba d7 75 10 f0       	mov    $0xf01075d7,%edx
f010453a:	b9 e2 75 10 f0       	mov    $0xf01075e2,%ecx
f010453f:	0f 45 ca             	cmovne %edx,%ecx
f0104542:	89 c2                	mov    %eax,%edx
f0104544:	83 e2 02             	and    $0x2,%edx
f0104547:	ba ee 75 10 f0       	mov    $0xf01075ee,%edx
f010454c:	be f4 75 10 f0       	mov    $0xf01075f4,%esi
f0104551:	0f 44 d6             	cmove  %esi,%edx
f0104554:	83 e0 04             	and    $0x4,%eax
f0104557:	b8 f9 75 10 f0       	mov    $0xf01075f9,%eax
f010455c:	be 2e 77 10 f0       	mov    $0xf010772e,%esi
f0104561:	0f 44 c6             	cmove  %esi,%eax
f0104564:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104568:	89 54 24 08          	mov    %edx,0x8(%esp)
f010456c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104570:	c7 04 24 71 76 10 f0 	movl   $0xf0107671,(%esp)
f0104577:	e8 b8 f9 ff ff       	call   f0103f34 <cprintf>
f010457c:	eb 0c                	jmp    f010458a <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010457e:	c7 04 24 30 74 10 f0 	movl   $0xf0107430,(%esp)
f0104585:	e8 aa f9 ff ff       	call   f0103f34 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010458a:	8b 43 30             	mov    0x30(%ebx),%eax
f010458d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104591:	c7 04 24 80 76 10 f0 	movl   $0xf0107680,(%esp)
f0104598:	e8 97 f9 ff ff       	call   f0103f34 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010459d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a5:	c7 04 24 8f 76 10 f0 	movl   $0xf010768f,(%esp)
f01045ac:	e8 83 f9 ff ff       	call   f0103f34 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045b1:	8b 43 38             	mov    0x38(%ebx),%eax
f01045b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b8:	c7 04 24 a2 76 10 f0 	movl   $0xf01076a2,(%esp)
f01045bf:	e8 70 f9 ff ff       	call   f0103f34 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01045c4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045c8:	74 27                	je     f01045f1 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045ca:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d1:	c7 04 24 b1 76 10 f0 	movl   $0xf01076b1,(%esp)
f01045d8:	e8 57 f9 ff ff       	call   f0103f34 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045dd:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e5:	c7 04 24 c0 76 10 f0 	movl   $0xf01076c0,(%esp)
f01045ec:	e8 43 f9 ff ff       	call   f0103f34 <cprintf>
	}
}
f01045f1:	83 c4 10             	add    $0x10,%esp
f01045f4:	5b                   	pop    %ebx
f01045f5:	5e                   	pop    %esi
f01045f6:	5d                   	pop    %ebp
f01045f7:	c3                   	ret    

f01045f8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045f8:	55                   	push   %ebp
f01045f9:	89 e5                	mov    %esp,%ebp
f01045fb:	57                   	push   %edi
f01045fc:	56                   	push   %esi
f01045fd:	53                   	push   %ebx
f01045fe:	83 ec 1c             	sub    $0x1c,%esp
f0104601:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104604:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104607:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010460c:	75 1c                	jne    f010462a <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f010460e:	c7 44 24 08 78 78 10 	movl   $0xf0107878,0x8(%esp)
f0104615:	f0 
f0104616:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f010461d:	00 
f010461e:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f0104625:	e8 16 ba ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010462a:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010462d:	e8 e7 15 00 00       	call   f0105c19 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104632:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104636:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f010463a:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010463d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0104643:	8b 40 48             	mov    0x48(%eax),%eax
f0104646:	89 44 24 04          	mov    %eax,0x4(%esp)
f010464a:	c7 04 24 9c 78 10 f0 	movl   $0xf010789c,(%esp)
f0104651:	e8 de f8 ff ff       	call   f0103f34 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104656:	89 1c 24             	mov    %ebx,(%esp)
f0104659:	e8 fd fd ff ff       	call   f010445b <print_trapframe>
	env_destroy(curenv);
f010465e:	e8 b6 15 00 00       	call   f0105c19 <cpunum>
f0104663:	6b c0 74             	imul   $0x74,%eax,%eax
f0104666:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010466c:	89 04 24             	mov    %eax,(%esp)
f010466f:	e8 d7 f5 ff ff       	call   f0103c4b <env_destroy>
}
f0104674:	83 c4 1c             	add    $0x1c,%esp
f0104677:	5b                   	pop    %ebx
f0104678:	5e                   	pop    %esi
f0104679:	5f                   	pop    %edi
f010467a:	5d                   	pop    %ebp
f010467b:	c3                   	ret    

f010467c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010467c:	55                   	push   %ebp
f010467d:	89 e5                	mov    %esp,%ebp
f010467f:	57                   	push   %edi
f0104680:	56                   	push   %esi
f0104681:	83 ec 20             	sub    $0x20,%esp
f0104684:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104687:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104688:	83 3d 80 ae 22 f0 00 	cmpl   $0x0,0xf022ae80
f010468f:	74 01                	je     f0104692 <trap+0x16>
		asm volatile("hlt");
f0104691:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104692:	e8 82 15 00 00       	call   f0105c19 <cpunum>
f0104697:	6b d0 74             	imul   $0x74,%eax,%edx
f010469a:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01046a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01046a5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01046a9:	83 f8 02             	cmp    $0x2,%eax
f01046ac:	75 0c                	jne    f01046ba <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01046ae:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f01046b5:	e8 dd 17 00 00       	call   f0105e97 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01046ba:	9c                   	pushf  
f01046bb:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01046bc:	f6 c4 02             	test   $0x2,%ah
f01046bf:	74 24                	je     f01046e5 <trap+0x69>
f01046c1:	c7 44 24 0c df 76 10 	movl   $0xf01076df,0xc(%esp)
f01046c8:	f0 
f01046c9:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f01046d0:	f0 
f01046d1:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f01046d8:	00 
f01046d9:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f01046e0:	e8 5b b9 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01046e5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01046e9:	83 e0 03             	and    $0x3,%eax
f01046ec:	66 83 f8 03          	cmp    $0x3,%ax
f01046f0:	0f 85 9b 00 00 00    	jne    f0104791 <trap+0x115>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01046f6:	e8 1e 15 00 00       	call   f0105c19 <cpunum>
f01046fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fe:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0104705:	75 24                	jne    f010472b <trap+0xaf>
f0104707:	c7 44 24 0c f8 76 10 	movl   $0xf01076f8,0xc(%esp)
f010470e:	f0 
f010470f:	c7 44 24 08 5f 71 10 	movl   $0xf010715f,0x8(%esp)
f0104716:	f0 
f0104717:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f010471e:	00 
f010471f:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f0104726:	e8 15 b9 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010472b:	e8 e9 14 00 00       	call   f0105c19 <cpunum>
f0104730:	6b c0 74             	imul   $0x74,%eax,%eax
f0104733:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0104739:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010473d:	75 2d                	jne    f010476c <trap+0xf0>
			env_free(curenv);
f010473f:	e8 d5 14 00 00       	call   f0105c19 <cpunum>
f0104744:	6b c0 74             	imul   $0x74,%eax,%eax
f0104747:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010474d:	89 04 24             	mov    %eax,(%esp)
f0104750:	e8 f1 f2 ff ff       	call   f0103a46 <env_free>
			curenv = NULL;
f0104755:	e8 bf 14 00 00       	call   f0105c19 <cpunum>
f010475a:	6b c0 74             	imul   $0x74,%eax,%eax
f010475d:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0104764:	00 00 00 
			sched_yield();
f0104767:	e8 d1 02 00 00       	call   f0104a3d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010476c:	e8 a8 14 00 00       	call   f0105c19 <cpunum>
f0104771:	6b c0 74             	imul   $0x74,%eax,%eax
f0104774:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010477a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010477f:	89 c7                	mov    %eax,%edi
f0104781:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104783:	e8 91 14 00 00       	call   f0105c19 <cpunum>
f0104788:	6b c0 74             	imul   $0x74,%eax,%eax
f010478b:	8b b0 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104791:	89 35 60 aa 22 f0    	mov    %esi,0xf022aa60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f0104797:	8b 46 28             	mov    0x28(%esi),%eax
f010479a:	83 f8 0e             	cmp    $0xe,%eax
f010479d:	75 0d                	jne    f01047ac <trap+0x130>
		page_fault_handler(tf);
f010479f:	89 34 24             	mov    %esi,(%esp)
f01047a2:	e8 51 fe ff ff       	call   f01045f8 <page_fault_handler>
f01047a7:	e9 a6 00 00 00       	jmp    f0104852 <trap+0x1d6>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f01047ac:	83 f8 03             	cmp    $0x3,%eax
f01047af:	90                   	nop
f01047b0:	75 0d                	jne    f01047bf <trap+0x143>
		monitor(tf);
f01047b2:	89 34 24             	mov    %esi,(%esp)
f01047b5:	e8 ff c0 ff ff       	call   f01008b9 <monitor>
f01047ba:	e9 93 00 00 00       	jmp    f0104852 <trap+0x1d6>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f01047bf:	83 f8 30             	cmp    $0x30,%eax
f01047c2:	75 32                	jne    f01047f6 <trap+0x17a>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f01047c4:	8b 46 04             	mov    0x4(%esi),%eax
f01047c7:	89 44 24 14          	mov    %eax,0x14(%esp)
f01047cb:	8b 06                	mov    (%esi),%eax
f01047cd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01047d1:	8b 46 10             	mov    0x10(%esi),%eax
f01047d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047d8:	8b 46 18             	mov    0x18(%esi),%eax
f01047db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047df:	8b 46 14             	mov    0x14(%esi),%eax
f01047e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047e6:	8b 46 1c             	mov    0x1c(%esi),%eax
f01047e9:	89 04 24             	mov    %eax,(%esp)
f01047ec:	e8 59 02 00 00       	call   f0104a4a <syscall>
f01047f1:	89 46 1c             	mov    %eax,0x1c(%esi)
f01047f4:	eb 5c                	jmp    f0104852 <trap+0x1d6>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01047f6:	83 f8 27             	cmp    $0x27,%eax
f01047f9:	75 16                	jne    f0104811 <trap+0x195>
		cprintf("Spurious interrupt on irq 7\n");
f01047fb:	c7 04 24 ff 76 10 f0 	movl   $0xf01076ff,(%esp)
f0104802:	e8 2d f7 ff ff       	call   f0103f34 <cprintf>
		print_trapframe(tf);
f0104807:	89 34 24             	mov    %esi,(%esp)
f010480a:	e8 4c fc ff ff       	call   f010445b <print_trapframe>
f010480f:	eb 41                	jmp    f0104852 <trap+0x1d6>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104811:	89 34 24             	mov    %esi,(%esp)
f0104814:	e8 42 fc ff ff       	call   f010445b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104819:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010481e:	75 1c                	jne    f010483c <trap+0x1c0>
		panic("unhandled trap in kernel");
f0104820:	c7 44 24 08 1c 77 10 	movl   $0xf010771c,0x8(%esp)
f0104827:	f0 
f0104828:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f010482f:	00 
f0104830:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f0104837:	e8 04 b8 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010483c:	e8 d8 13 00 00       	call   f0105c19 <cpunum>
f0104841:	6b c0 74             	imul   $0x74,%eax,%eax
f0104844:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010484a:	89 04 24             	mov    %eax,(%esp)
f010484d:	e8 f9 f3 ff ff       	call   f0103c4b <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104852:	e8 c2 13 00 00       	call   f0105c19 <cpunum>
f0104857:	6b c0 74             	imul   $0x74,%eax,%eax
f010485a:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0104861:	74 2a                	je     f010488d <trap+0x211>
f0104863:	e8 b1 13 00 00       	call   f0105c19 <cpunum>
f0104868:	6b c0 74             	imul   $0x74,%eax,%eax
f010486b:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0104871:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104875:	75 16                	jne    f010488d <trap+0x211>
		env_run(curenv);
f0104877:	e8 9d 13 00 00       	call   f0105c19 <cpunum>
f010487c:	6b c0 74             	imul   $0x74,%eax,%eax
f010487f:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0104885:	89 04 24             	mov    %eax,(%esp)
f0104888:	e8 5f f4 ff ff       	call   f0103cec <env_run>
	else
		sched_yield();
f010488d:	e8 ab 01 00 00       	call   f0104a3d <sched_yield>

f0104892 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104892:	6a 00                	push   $0x0
f0104894:	6a 00                	push   $0x0
f0104896:	e9 ba 00 00 00       	jmp    f0104955 <_alltraps>
f010489b:	90                   	nop

f010489c <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f010489c:	6a 00                	push   $0x0
f010489e:	6a 01                	push   $0x1
f01048a0:	e9 b0 00 00 00       	jmp    f0104955 <_alltraps>
f01048a5:	90                   	nop

f01048a6 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01048a6:	6a 00                	push   $0x0
f01048a8:	6a 02                	push   $0x2
f01048aa:	e9 a6 00 00 00       	jmp    f0104955 <_alltraps>
f01048af:	90                   	nop

f01048b0 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01048b0:	6a 00                	push   $0x0
f01048b2:	6a 03                	push   $0x3
f01048b4:	e9 9c 00 00 00       	jmp    f0104955 <_alltraps>
f01048b9:	90                   	nop

f01048ba <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01048ba:	6a 00                	push   $0x0
f01048bc:	6a 04                	push   $0x4
f01048be:	e9 92 00 00 00       	jmp    f0104955 <_alltraps>
f01048c3:	90                   	nop

f01048c4 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f01048c4:	6a 00                	push   $0x0
f01048c6:	6a 05                	push   $0x5
f01048c8:	e9 88 00 00 00       	jmp    f0104955 <_alltraps>
f01048cd:	90                   	nop

f01048ce <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01048ce:	6a 00                	push   $0x0
f01048d0:	6a 06                	push   $0x6
f01048d2:	e9 7e 00 00 00       	jmp    f0104955 <_alltraps>
f01048d7:	90                   	nop

f01048d8 <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f01048d8:	6a 00                	push   $0x0
f01048da:	6a 07                	push   $0x7
f01048dc:	e9 74 00 00 00       	jmp    f0104955 <_alltraps>
f01048e1:	90                   	nop

f01048e2 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f01048e2:	6a 08                	push   $0x8
f01048e4:	e9 6c 00 00 00       	jmp    f0104955 <_alltraps>
f01048e9:	90                   	nop

f01048ea <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f01048ea:	6a 00                	push   $0x0
f01048ec:	6a 09                	push   $0x9
f01048ee:	e9 62 00 00 00       	jmp    f0104955 <_alltraps>
f01048f3:	90                   	nop

f01048f4 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f01048f4:	6a 0a                	push   $0xa
f01048f6:	e9 5a 00 00 00       	jmp    f0104955 <_alltraps>
f01048fb:	90                   	nop

f01048fc <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f01048fc:	6a 0b                	push   $0xb
f01048fe:	e9 52 00 00 00       	jmp    f0104955 <_alltraps>
f0104903:	90                   	nop

f0104904 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104904:	6a 0c                	push   $0xc
f0104906:	e9 4a 00 00 00       	jmp    f0104955 <_alltraps>
f010490b:	90                   	nop

f010490c <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f010490c:	6a 0d                	push   $0xd
f010490e:	e9 42 00 00 00       	jmp    f0104955 <_alltraps>
f0104913:	90                   	nop

f0104914 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104914:	6a 0e                	push   $0xe
f0104916:	e9 3a 00 00 00       	jmp    f0104955 <_alltraps>
f010491b:	90                   	nop

f010491c <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f010491c:	6a 00                	push   $0x0
f010491e:	6a 0f                	push   $0xf
f0104920:	e9 30 00 00 00       	jmp    f0104955 <_alltraps>
f0104925:	90                   	nop

f0104926 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104926:	6a 00                	push   $0x0
f0104928:	6a 10                	push   $0x10
f010492a:	e9 26 00 00 00       	jmp    f0104955 <_alltraps>
f010492f:	90                   	nop

f0104930 <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104930:	6a 11                	push   $0x11
f0104932:	e9 1e 00 00 00       	jmp    f0104955 <_alltraps>
f0104937:	90                   	nop

f0104938 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104938:	6a 00                	push   $0x0
f010493a:	6a 12                	push   $0x12
f010493c:	e9 14 00 00 00       	jmp    f0104955 <_alltraps>
f0104941:	90                   	nop

f0104942 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104942:	6a 00                	push   $0x0
f0104944:	6a 13                	push   $0x13
f0104946:	e9 0a 00 00 00       	jmp    f0104955 <_alltraps>
f010494b:	90                   	nop

f010494c <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f010494c:	6a 00                	push   $0x0
f010494e:	6a 30                	push   $0x30
f0104950:	e9 00 00 00 00       	jmp    f0104955 <_alltraps>

f0104955 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104955:	1e                   	push   %ds
	pushl %es
f0104956:	06                   	push   %es
	pushal
f0104957:	60                   	pusha  
	movl $GD_KD, %eax
f0104958:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010495d:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010495f:	8e c0                	mov    %eax,%es

	pushl %esp
f0104961:	54                   	push   %esp
	call trap
f0104962:	e8 15 fd ff ff       	call   f010467c <trap>

f0104967 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104967:	55                   	push   %ebp
f0104968:	89 e5                	mov    %esp,%ebp
f010496a:	83 ec 18             	sub    $0x18,%esp
f010496d:	8b 15 48 a2 22 f0    	mov    0xf022a248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104973:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104978:	8b 4a 54             	mov    0x54(%edx),%ecx
f010497b:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010497e:	83 f9 02             	cmp    $0x2,%ecx
f0104981:	76 0f                	jbe    f0104992 <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104983:	83 c0 01             	add    $0x1,%eax
f0104986:	83 c2 7c             	add    $0x7c,%edx
f0104989:	3d 00 04 00 00       	cmp    $0x400,%eax
f010498e:	75 e8                	jne    f0104978 <sched_halt+0x11>
f0104990:	eb 07                	jmp    f0104999 <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104992:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104997:	75 1a                	jne    f01049b3 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104999:	c7 04 24 10 79 10 f0 	movl   $0xf0107910,(%esp)
f01049a0:	e8 8f f5 ff ff       	call   f0103f34 <cprintf>
		while (1)
			monitor(NULL);
f01049a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01049ac:	e8 08 bf ff ff       	call   f01008b9 <monitor>
f01049b1:	eb f2                	jmp    f01049a5 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01049b3:	e8 61 12 00 00       	call   f0105c19 <cpunum>
f01049b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049bb:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f01049c2:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01049c5:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01049ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01049cf:	77 20                	ja     f01049f1 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049d5:	c7 44 24 08 48 63 10 	movl   $0xf0106348,0x8(%esp)
f01049dc:	f0 
f01049dd:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
f01049e4:	00 
f01049e5:	c7 04 24 39 79 10 f0 	movl   $0xf0107939,(%esp)
f01049ec:	e8 4f b6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01049f1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01049f6:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01049f9:	e8 1b 12 00 00       	call   f0105c19 <cpunum>
f01049fe:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a01:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104a07:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a0c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104a10:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f0104a17:	e8 27 15 00 00       	call   f0105f43 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104a1c:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104a1e:	e8 f6 11 00 00       	call   f0105c19 <cpunum>
f0104a23:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104a26:	8b 80 30 b0 22 f0    	mov    -0xfdd4fd0(%eax),%eax
f0104a2c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104a31:	89 c4                	mov    %eax,%esp
f0104a33:	6a 00                	push   $0x0
f0104a35:	6a 00                	push   $0x0
f0104a37:	fb                   	sti    
f0104a38:	f4                   	hlt    
f0104a39:	eb fd                	jmp    f0104a38 <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104a3b:	c9                   	leave  
f0104a3c:	c3                   	ret    

f0104a3d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104a3d:	55                   	push   %ebp
f0104a3e:	89 e5                	mov    %esp,%ebp
f0104a40:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0104a43:	e8 1f ff ff ff       	call   f0104967 <sched_halt>
}
f0104a48:	c9                   	leave  
f0104a49:	c3                   	ret    

f0104a4a <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a4a:	55                   	push   %ebp
f0104a4b:	89 e5                	mov    %esp,%ebp
f0104a4d:	83 ec 18             	sub    $0x18,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0104a50:	c7 44 24 08 46 79 10 	movl   $0xf0107946,0x8(%esp)
f0104a57:	f0 
f0104a58:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f0104a5f:	00 
f0104a60:	c7 04 24 5e 79 10 f0 	movl   $0xf010795e,(%esp)
f0104a67:	e8 d4 b5 ff ff       	call   f0100040 <_panic>

f0104a6c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a6c:	55                   	push   %ebp
f0104a6d:	89 e5                	mov    %esp,%ebp
f0104a6f:	57                   	push   %edi
f0104a70:	56                   	push   %esi
f0104a71:	53                   	push   %ebx
f0104a72:	83 ec 14             	sub    $0x14,%esp
f0104a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a7e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a81:	8b 1a                	mov    (%edx),%ebx
f0104a83:	8b 01                	mov    (%ecx),%eax
f0104a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a88:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a8f:	e9 88 00 00 00       	jmp    f0104b1c <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a97:	01 d8                	add    %ebx,%eax
f0104a99:	89 c7                	mov    %eax,%edi
f0104a9b:	c1 ef 1f             	shr    $0x1f,%edi
f0104a9e:	01 c7                	add    %eax,%edi
f0104aa0:	d1 ff                	sar    %edi
f0104aa2:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104aa5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104aa8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104aab:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104aad:	eb 03                	jmp    f0104ab2 <stab_binsearch+0x46>
			m--;
f0104aaf:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ab2:	39 c3                	cmp    %eax,%ebx
f0104ab4:	7f 1f                	jg     f0104ad5 <stab_binsearch+0x69>
f0104ab6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104aba:	83 ea 0c             	sub    $0xc,%edx
f0104abd:	39 f1                	cmp    %esi,%ecx
f0104abf:	75 ee                	jne    f0104aaf <stab_binsearch+0x43>
f0104ac1:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ac4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ac7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104aca:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ace:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ad1:	76 18                	jbe    f0104aeb <stab_binsearch+0x7f>
f0104ad3:	eb 05                	jmp    f0104ada <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104ad5:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104ad8:	eb 42                	jmp    f0104b1c <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104ada:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104add:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104adf:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ae2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ae9:	eb 31                	jmp    f0104b1c <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104aeb:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104aee:	73 17                	jae    f0104b07 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104af0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104af3:	83 e8 01             	sub    $0x1,%eax
f0104af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104af9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104afc:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104afe:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b05:	eb 15                	jmp    f0104b1c <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b0a:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104b0d:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0104b0f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b13:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b15:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b1c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b1f:	0f 8e 6f ff ff ff    	jle    f0104a94 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b25:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b29:	75 0f                	jne    f0104b3a <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b2e:	8b 00                	mov    (%eax),%eax
f0104b30:	83 e8 01             	sub    $0x1,%eax
f0104b33:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104b36:	89 07                	mov    %eax,(%edi)
f0104b38:	eb 2c                	jmp    f0104b66 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b3d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b42:	8b 0f                	mov    (%edi),%ecx
f0104b44:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b47:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104b4a:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b4d:	eb 03                	jmp    f0104b52 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b4f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b52:	39 c8                	cmp    %ecx,%eax
f0104b54:	7e 0b                	jle    f0104b61 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104b56:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b5a:	83 ea 0c             	sub    $0xc,%edx
f0104b5d:	39 f3                	cmp    %esi,%ebx
f0104b5f:	75 ee                	jne    f0104b4f <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b64:	89 07                	mov    %eax,(%edi)
	}
}
f0104b66:	83 c4 14             	add    $0x14,%esp
f0104b69:	5b                   	pop    %ebx
f0104b6a:	5e                   	pop    %esi
f0104b6b:	5f                   	pop    %edi
f0104b6c:	5d                   	pop    %ebp
f0104b6d:	c3                   	ret    

f0104b6e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b6e:	55                   	push   %ebp
f0104b6f:	89 e5                	mov    %esp,%ebp
f0104b71:	57                   	push   %edi
f0104b72:	56                   	push   %esi
f0104b73:	53                   	push   %ebx
f0104b74:	83 ec 3c             	sub    $0x3c,%esp
f0104b77:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b7d:	c7 06 6d 79 10 f0    	movl   $0xf010796d,(%esi)
	info->eip_line = 0;
f0104b83:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104b8a:	c7 46 08 6d 79 10 f0 	movl   $0xf010796d,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104b91:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104b98:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104b9b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ba2:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104ba8:	77 21                	ja     f0104bcb <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104baa:	a1 00 00 20 00       	mov    0x200000,%eax
f0104baf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104bb2:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104bb7:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0104bbd:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f0104bc0:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0104bc6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104bc9:	eb 1a                	jmp    f0104be5 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104bcb:	c7 45 cc e9 4f 11 f0 	movl   $0xf0114fe9,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104bd2:	c7 45 d0 4d 1a 11 f0 	movl   $0xf0111a4d,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104bd9:	b8 4c 1a 11 f0       	mov    $0xf0111a4c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104bde:	c7 45 d4 58 7e 10 f0 	movl   $0xf0107e58,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104be5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104be8:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0104beb:	0f 83 2f 01 00 00    	jae    f0104d20 <debuginfo_eip+0x1b2>
f0104bf1:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104bf5:	0f 85 2c 01 00 00    	jne    f0104d27 <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104bfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104c05:	29 d8                	sub    %ebx,%eax
f0104c07:	c1 f8 02             	sar    $0x2,%eax
f0104c0a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c10:	83 e8 01             	sub    $0x1,%eax
f0104c13:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c16:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c1a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104c21:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104c24:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c27:	89 d8                	mov    %ebx,%eax
f0104c29:	e8 3e fe ff ff       	call   f0104a6c <stab_binsearch>
	if (lfile == 0)
f0104c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c31:	85 c0                	test   %eax,%eax
f0104c33:	0f 84 f5 00 00 00    	je     f0104d2e <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c39:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c42:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c46:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104c4d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104c50:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c53:	89 d8                	mov    %ebx,%eax
f0104c55:	e8 12 fe ff ff       	call   f0104a6c <stab_binsearch>

	if (lfun <= rfun) {
f0104c5a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104c5d:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104c60:	7f 23                	jg     f0104c85 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c62:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104c65:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104c68:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104c6b:	8b 10                	mov    (%eax),%edx
f0104c6d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104c70:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f0104c73:	39 ca                	cmp    %ecx,%edx
f0104c75:	73 06                	jae    f0104c7d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c77:	03 55 d0             	add    -0x30(%ebp),%edx
f0104c7a:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c7d:	8b 40 08             	mov    0x8(%eax),%eax
f0104c80:	89 46 10             	mov    %eax,0x10(%esi)
f0104c83:	eb 06                	jmp    f0104c8b <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104c85:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104c88:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104c8b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104c92:	00 
f0104c93:	8b 46 08             	mov    0x8(%esi),%eax
f0104c96:	89 04 24             	mov    %eax,(%esp)
f0104c99:	e8 0d 09 00 00       	call   f01055ab <strfind>
f0104c9e:	2b 46 08             	sub    0x8(%esi),%eax
f0104ca1:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ca4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ca7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104caa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104cad:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104cb0:	eb 06                	jmp    f0104cb8 <debuginfo_eip+0x14a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104cb2:	83 eb 01             	sub    $0x1,%ebx
f0104cb5:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104cb8:	39 fb                	cmp    %edi,%ebx
f0104cba:	7c 2c                	jl     f0104ce8 <debuginfo_eip+0x17a>
	       && stabs[lline].n_type != N_SOL
f0104cbc:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104cc0:	80 fa 84             	cmp    $0x84,%dl
f0104cc3:	74 0b                	je     f0104cd0 <debuginfo_eip+0x162>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104cc5:	80 fa 64             	cmp    $0x64,%dl
f0104cc8:	75 e8                	jne    f0104cb2 <debuginfo_eip+0x144>
f0104cca:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104cce:	74 e2                	je     f0104cb2 <debuginfo_eip+0x144>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104cd0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104cd3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104cd6:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0104cd9:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104cdc:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0104cdf:	39 d0                	cmp    %edx,%eax
f0104ce1:	73 05                	jae    f0104ce8 <debuginfo_eip+0x17a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ce3:	03 45 d0             	add    -0x30(%ebp),%eax
f0104ce6:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ce8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104ceb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104cee:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104cf3:	39 cb                	cmp    %ecx,%ebx
f0104cf5:	7d 43                	jge    f0104d3a <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f0104cf7:	8d 53 01             	lea    0x1(%ebx),%edx
f0104cfa:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104cfd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d00:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104d03:	eb 07                	jmp    f0104d0c <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d05:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104d09:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d0c:	39 ca                	cmp    %ecx,%edx
f0104d0e:	74 25                	je     f0104d35 <debuginfo_eip+0x1c7>
f0104d10:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d13:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104d17:	74 ec                	je     f0104d05 <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d19:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d1e:	eb 1a                	jmp    f0104d3a <debuginfo_eip+0x1cc>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104d20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d25:	eb 13                	jmp    f0104d3a <debuginfo_eip+0x1cc>
f0104d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d2c:	eb 0c                	jmp    f0104d3a <debuginfo_eip+0x1cc>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104d2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d33:	eb 05                	jmp    f0104d3a <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d3a:	83 c4 3c             	add    $0x3c,%esp
f0104d3d:	5b                   	pop    %ebx
f0104d3e:	5e                   	pop    %esi
f0104d3f:	5f                   	pop    %edi
f0104d40:	5d                   	pop    %ebp
f0104d41:	c3                   	ret    
f0104d42:	66 90                	xchg   %ax,%ax
f0104d44:	66 90                	xchg   %ax,%ax
f0104d46:	66 90                	xchg   %ax,%ax
f0104d48:	66 90                	xchg   %ax,%ax
f0104d4a:	66 90                	xchg   %ax,%ax
f0104d4c:	66 90                	xchg   %ax,%ax
f0104d4e:	66 90                	xchg   %ax,%ax

f0104d50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104d50:	55                   	push   %ebp
f0104d51:	89 e5                	mov    %esp,%ebp
f0104d53:	57                   	push   %edi
f0104d54:	56                   	push   %esi
f0104d55:	53                   	push   %ebx
f0104d56:	83 ec 3c             	sub    $0x3c,%esp
f0104d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d5c:	89 d7                	mov    %edx,%edi
f0104d5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d67:	89 c3                	mov    %eax,%ebx
f0104d69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d6c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d6f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104d72:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d77:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d7a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104d7d:	39 d9                	cmp    %ebx,%ecx
f0104d7f:	72 05                	jb     f0104d86 <printnum+0x36>
f0104d81:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0104d84:	77 69                	ja     f0104def <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104d86:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104d89:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104d8d:	83 ee 01             	sub    $0x1,%esi
f0104d90:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104d94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d98:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104d9c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104da0:	89 c3                	mov    %eax,%ebx
f0104da2:	89 d6                	mov    %edx,%esi
f0104da4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104da7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104daa:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104dae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104db5:	89 04 24             	mov    %eax,(%esp)
f0104db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dbf:	e8 9c 12 00 00       	call   f0106060 <__udivdi3>
f0104dc4:	89 d9                	mov    %ebx,%ecx
f0104dc6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104dca:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104dce:	89 04 24             	mov    %eax,(%esp)
f0104dd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104dd5:	89 fa                	mov    %edi,%edx
f0104dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dda:	e8 71 ff ff ff       	call   f0104d50 <printnum>
f0104ddf:	eb 1b                	jmp    f0104dfc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104de1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104de5:	8b 45 18             	mov    0x18(%ebp),%eax
f0104de8:	89 04 24             	mov    %eax,(%esp)
f0104deb:	ff d3                	call   *%ebx
f0104ded:	eb 03                	jmp    f0104df2 <printnum+0xa2>
f0104def:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104df2:	83 ee 01             	sub    $0x1,%esi
f0104df5:	85 f6                	test   %esi,%esi
f0104df7:	7f e8                	jg     f0104de1 <printnum+0x91>
f0104df9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104dfc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e00:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104e04:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e07:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104e12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e15:	89 04 24             	mov    %eax,(%esp)
f0104e18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e1f:	e8 6c 13 00 00       	call   f0106190 <__umoddi3>
f0104e24:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e28:	0f be 80 77 79 10 f0 	movsbl -0xfef8689(%eax),%eax
f0104e2f:	89 04 24             	mov    %eax,(%esp)
f0104e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e35:	ff d0                	call   *%eax
}
f0104e37:	83 c4 3c             	add    $0x3c,%esp
f0104e3a:	5b                   	pop    %ebx
f0104e3b:	5e                   	pop    %esi
f0104e3c:	5f                   	pop    %edi
f0104e3d:	5d                   	pop    %ebp
f0104e3e:	c3                   	ret    

f0104e3f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e3f:	55                   	push   %ebp
f0104e40:	89 e5                	mov    %esp,%ebp
f0104e42:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e45:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e49:	8b 10                	mov    (%eax),%edx
f0104e4b:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e4e:	73 0a                	jae    f0104e5a <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e50:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e53:	89 08                	mov    %ecx,(%eax)
f0104e55:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e58:	88 02                	mov    %al,(%edx)
}
f0104e5a:	5d                   	pop    %ebp
f0104e5b:	c3                   	ret    

f0104e5c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104e5c:	55                   	push   %ebp
f0104e5d:	89 e5                	mov    %esp,%ebp
f0104e5f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104e62:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e65:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e69:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e6c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e77:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e7a:	89 04 24             	mov    %eax,(%esp)
f0104e7d:	e8 02 00 00 00       	call   f0104e84 <vprintfmt>
	va_end(ap);
}
f0104e82:	c9                   	leave  
f0104e83:	c3                   	ret    

f0104e84 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104e84:	55                   	push   %ebp
f0104e85:	89 e5                	mov    %esp,%ebp
f0104e87:	57                   	push   %edi
f0104e88:	56                   	push   %esi
f0104e89:	53                   	push   %ebx
f0104e8a:	83 ec 3c             	sub    $0x3c,%esp
f0104e8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e93:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e96:	eb 11                	jmp    f0104ea9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104e98:	85 c0                	test   %eax,%eax
f0104e9a:	0f 84 48 04 00 00    	je     f01052e8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0104ea0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ea4:	89 04 24             	mov    %eax,(%esp)
f0104ea7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ea9:	83 c7 01             	add    $0x1,%edi
f0104eac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104eb0:	83 f8 25             	cmp    $0x25,%eax
f0104eb3:	75 e3                	jne    f0104e98 <vprintfmt+0x14>
f0104eb5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104eb9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ec0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ec7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104ece:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ed3:	eb 1f                	jmp    f0104ef4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ed5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104ed8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104edc:	eb 16                	jmp    f0104ef4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ede:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104ee1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104ee5:	eb 0d                	jmp    f0104ef4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104ee7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104eea:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104eed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ef4:	8d 47 01             	lea    0x1(%edi),%eax
f0104ef7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104efa:	0f b6 17             	movzbl (%edi),%edx
f0104efd:	0f b6 c2             	movzbl %dl,%eax
f0104f00:	83 ea 23             	sub    $0x23,%edx
f0104f03:	80 fa 55             	cmp    $0x55,%dl
f0104f06:	0f 87 bf 03 00 00    	ja     f01052cb <vprintfmt+0x447>
f0104f0c:	0f b6 d2             	movzbl %dl,%edx
f0104f0f:	ff 24 95 40 7a 10 f0 	jmp    *-0xfef85c0(,%edx,4)
f0104f16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f19:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f21:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104f24:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104f28:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0104f2b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104f2e:	83 f9 09             	cmp    $0x9,%ecx
f0104f31:	77 3c                	ja     f0104f6f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f33:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f36:	eb e9                	jmp    f0104f21 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f38:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f3b:	8b 00                	mov    (%eax),%eax
f0104f3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f43:	8d 40 04             	lea    0x4(%eax),%eax
f0104f46:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104f4c:	eb 27                	jmp    f0104f75 <vprintfmt+0xf1>
f0104f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104f51:	85 d2                	test   %edx,%edx
f0104f53:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f58:	0f 49 c2             	cmovns %edx,%eax
f0104f5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f61:	eb 91                	jmp    f0104ef4 <vprintfmt+0x70>
f0104f63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104f66:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f6d:	eb 85                	jmp    f0104ef4 <vprintfmt+0x70>
f0104f6f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104f72:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104f75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f79:	0f 89 75 ff ff ff    	jns    f0104ef4 <vprintfmt+0x70>
f0104f7f:	e9 63 ff ff ff       	jmp    f0104ee7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104f84:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104f8a:	e9 65 ff ff ff       	jmp    f0104ef4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f8f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104f92:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104f96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f9a:	8b 00                	mov    (%eax),%eax
f0104f9c:	89 04 24             	mov    %eax,(%esp)
f0104f9f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104fa4:	e9 00 ff ff ff       	jmp    f0104ea9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fac:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104fb0:	8b 00                	mov    (%eax),%eax
f0104fb2:	99                   	cltd   
f0104fb3:	31 d0                	xor    %edx,%eax
f0104fb5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104fb7:	83 f8 09             	cmp    $0x9,%eax
f0104fba:	7f 0b                	jg     f0104fc7 <vprintfmt+0x143>
f0104fbc:	8b 14 85 a0 7b 10 f0 	mov    -0xfef8460(,%eax,4),%edx
f0104fc3:	85 d2                	test   %edx,%edx
f0104fc5:	75 20                	jne    f0104fe7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0104fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fcb:	c7 44 24 08 8f 79 10 	movl   $0xf010798f,0x8(%esp)
f0104fd2:	f0 
f0104fd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fd7:	89 34 24             	mov    %esi,(%esp)
f0104fda:	e8 7d fe ff ff       	call   f0104e5c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104fe2:	e9 c2 fe ff ff       	jmp    f0104ea9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104fe7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104feb:	c7 44 24 08 71 71 10 	movl   $0xf0107171,0x8(%esp)
f0104ff2:	f0 
f0104ff3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ff7:	89 34 24             	mov    %esi,(%esp)
f0104ffa:	e8 5d fe ff ff       	call   f0104e5c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105002:	e9 a2 fe ff ff       	jmp    f0104ea9 <vprintfmt+0x25>
f0105007:	8b 45 14             	mov    0x14(%ebp),%eax
f010500a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010500d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105010:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105013:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105017:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105019:	85 ff                	test   %edi,%edi
f010501b:	b8 88 79 10 f0       	mov    $0xf0107988,%eax
f0105020:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105023:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105027:	0f 84 92 00 00 00    	je     f01050bf <vprintfmt+0x23b>
f010502d:	85 c9                	test   %ecx,%ecx
f010502f:	0f 8e 98 00 00 00    	jle    f01050cd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105035:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105039:	89 3c 24             	mov    %edi,(%esp)
f010503c:	e8 17 04 00 00       	call   f0105458 <strnlen>
f0105041:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105044:	29 c1                	sub    %eax,%ecx
f0105046:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0105049:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010504d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105050:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105053:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105055:	eb 0f                	jmp    f0105066 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0105057:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010505b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010505e:	89 04 24             	mov    %eax,(%esp)
f0105061:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105063:	83 ef 01             	sub    $0x1,%edi
f0105066:	85 ff                	test   %edi,%edi
f0105068:	7f ed                	jg     f0105057 <vprintfmt+0x1d3>
f010506a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010506d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105070:	85 c9                	test   %ecx,%ecx
f0105072:	b8 00 00 00 00       	mov    $0x0,%eax
f0105077:	0f 49 c1             	cmovns %ecx,%eax
f010507a:	29 c1                	sub    %eax,%ecx
f010507c:	89 75 08             	mov    %esi,0x8(%ebp)
f010507f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105082:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105085:	89 cb                	mov    %ecx,%ebx
f0105087:	eb 50                	jmp    f01050d9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105089:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010508d:	74 1e                	je     f01050ad <vprintfmt+0x229>
f010508f:	0f be d2             	movsbl %dl,%edx
f0105092:	83 ea 20             	sub    $0x20,%edx
f0105095:	83 fa 5e             	cmp    $0x5e,%edx
f0105098:	76 13                	jbe    f01050ad <vprintfmt+0x229>
					putch('?', putdat);
f010509a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010509d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050a1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01050a8:	ff 55 08             	call   *0x8(%ebp)
f01050ab:	eb 0d                	jmp    f01050ba <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01050ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01050b4:	89 04 24             	mov    %eax,(%esp)
f01050b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050ba:	83 eb 01             	sub    $0x1,%ebx
f01050bd:	eb 1a                	jmp    f01050d9 <vprintfmt+0x255>
f01050bf:	89 75 08             	mov    %esi,0x8(%ebp)
f01050c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050cb:	eb 0c                	jmp    f01050d9 <vprintfmt+0x255>
f01050cd:	89 75 08             	mov    %esi,0x8(%ebp)
f01050d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050d9:	83 c7 01             	add    $0x1,%edi
f01050dc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01050e0:	0f be c2             	movsbl %dl,%eax
f01050e3:	85 c0                	test   %eax,%eax
f01050e5:	74 25                	je     f010510c <vprintfmt+0x288>
f01050e7:	85 f6                	test   %esi,%esi
f01050e9:	78 9e                	js     f0105089 <vprintfmt+0x205>
f01050eb:	83 ee 01             	sub    $0x1,%esi
f01050ee:	79 99                	jns    f0105089 <vprintfmt+0x205>
f01050f0:	89 df                	mov    %ebx,%edi
f01050f2:	8b 75 08             	mov    0x8(%ebp),%esi
f01050f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050f8:	eb 1a                	jmp    f0105114 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01050fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105105:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105107:	83 ef 01             	sub    $0x1,%edi
f010510a:	eb 08                	jmp    f0105114 <vprintfmt+0x290>
f010510c:	89 df                	mov    %ebx,%edi
f010510e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105114:	85 ff                	test   %edi,%edi
f0105116:	7f e2                	jg     f01050fa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105118:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010511b:	e9 89 fd ff ff       	jmp    f0104ea9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105120:	83 f9 01             	cmp    $0x1,%ecx
f0105123:	7e 19                	jle    f010513e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0105125:	8b 45 14             	mov    0x14(%ebp),%eax
f0105128:	8b 50 04             	mov    0x4(%eax),%edx
f010512b:	8b 00                	mov    (%eax),%eax
f010512d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105130:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105133:	8b 45 14             	mov    0x14(%ebp),%eax
f0105136:	8d 40 08             	lea    0x8(%eax),%eax
f0105139:	89 45 14             	mov    %eax,0x14(%ebp)
f010513c:	eb 38                	jmp    f0105176 <vprintfmt+0x2f2>
	else if (lflag)
f010513e:	85 c9                	test   %ecx,%ecx
f0105140:	74 1b                	je     f010515d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0105142:	8b 45 14             	mov    0x14(%ebp),%eax
f0105145:	8b 00                	mov    (%eax),%eax
f0105147:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010514a:	89 c1                	mov    %eax,%ecx
f010514c:	c1 f9 1f             	sar    $0x1f,%ecx
f010514f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105152:	8b 45 14             	mov    0x14(%ebp),%eax
f0105155:	8d 40 04             	lea    0x4(%eax),%eax
f0105158:	89 45 14             	mov    %eax,0x14(%ebp)
f010515b:	eb 19                	jmp    f0105176 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010515d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105160:	8b 00                	mov    (%eax),%eax
f0105162:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105165:	89 c1                	mov    %eax,%ecx
f0105167:	c1 f9 1f             	sar    $0x1f,%ecx
f010516a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010516d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105170:	8d 40 04             	lea    0x4(%eax),%eax
f0105173:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105176:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105179:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010517c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105181:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105185:	0f 89 04 01 00 00    	jns    f010528f <vprintfmt+0x40b>
				putch('-', putdat);
f010518b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010518f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105196:	ff d6                	call   *%esi
				num = -(long long) num;
f0105198:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010519b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010519e:	f7 da                	neg    %edx
f01051a0:	83 d1 00             	adc    $0x0,%ecx
f01051a3:	f7 d9                	neg    %ecx
f01051a5:	e9 e5 00 00 00       	jmp    f010528f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051aa:	83 f9 01             	cmp    $0x1,%ecx
f01051ad:	7e 10                	jle    f01051bf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01051af:	8b 45 14             	mov    0x14(%ebp),%eax
f01051b2:	8b 10                	mov    (%eax),%edx
f01051b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01051b7:	8d 40 08             	lea    0x8(%eax),%eax
f01051ba:	89 45 14             	mov    %eax,0x14(%ebp)
f01051bd:	eb 26                	jmp    f01051e5 <vprintfmt+0x361>
	else if (lflag)
f01051bf:	85 c9                	test   %ecx,%ecx
f01051c1:	74 12                	je     f01051d5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f01051c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c6:	8b 10                	mov    (%eax),%edx
f01051c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051cd:	8d 40 04             	lea    0x4(%eax),%eax
f01051d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01051d3:	eb 10                	jmp    f01051e5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f01051d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051d8:	8b 10                	mov    (%eax),%edx
f01051da:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051df:	8d 40 04             	lea    0x4(%eax),%eax
f01051e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01051e5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f01051ea:	e9 a0 00 00 00       	jmp    f010528f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01051ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01051fa:	ff d6                	call   *%esi
			putch('X', putdat);
f01051fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105200:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105207:	ff d6                	call   *%esi
			putch('X', putdat);
f0105209:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010520d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105214:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105216:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105219:	e9 8b fc ff ff       	jmp    f0104ea9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010521e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105222:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105229:	ff d6                	call   *%esi
			putch('x', putdat);
f010522b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010522f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105236:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105238:	8b 45 14             	mov    0x14(%ebp),%eax
f010523b:	8b 10                	mov    (%eax),%edx
f010523d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0105242:	8d 40 04             	lea    0x4(%eax),%eax
f0105245:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105248:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010524d:	eb 40                	jmp    f010528f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010524f:	83 f9 01             	cmp    $0x1,%ecx
f0105252:	7e 10                	jle    f0105264 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0105254:	8b 45 14             	mov    0x14(%ebp),%eax
f0105257:	8b 10                	mov    (%eax),%edx
f0105259:	8b 48 04             	mov    0x4(%eax),%ecx
f010525c:	8d 40 08             	lea    0x8(%eax),%eax
f010525f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105262:	eb 26                	jmp    f010528a <vprintfmt+0x406>
	else if (lflag)
f0105264:	85 c9                	test   %ecx,%ecx
f0105266:	74 12                	je     f010527a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0105268:	8b 45 14             	mov    0x14(%ebp),%eax
f010526b:	8b 10                	mov    (%eax),%edx
f010526d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105272:	8d 40 04             	lea    0x4(%eax),%eax
f0105275:	89 45 14             	mov    %eax,0x14(%ebp)
f0105278:	eb 10                	jmp    f010528a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f010527a:	8b 45 14             	mov    0x14(%ebp),%eax
f010527d:	8b 10                	mov    (%eax),%edx
f010527f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105284:	8d 40 04             	lea    0x4(%eax),%eax
f0105287:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010528a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010528f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105293:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105297:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010529a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010529e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01052a2:	89 14 24             	mov    %edx,(%esp)
f01052a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01052a9:	89 da                	mov    %ebx,%edx
f01052ab:	89 f0                	mov    %esi,%eax
f01052ad:	e8 9e fa ff ff       	call   f0104d50 <printnum>
			break;
f01052b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b5:	e9 ef fb ff ff       	jmp    f0104ea9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01052be:	89 04 24             	mov    %eax,(%esp)
f01052c1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052c6:	e9 de fb ff ff       	jmp    f0104ea9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01052cf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01052d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052d8:	eb 03                	jmp    f01052dd <vprintfmt+0x459>
f01052da:	83 ef 01             	sub    $0x1,%edi
f01052dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052e1:	75 f7                	jne    f01052da <vprintfmt+0x456>
f01052e3:	e9 c1 fb ff ff       	jmp    f0104ea9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01052e8:	83 c4 3c             	add    $0x3c,%esp
f01052eb:	5b                   	pop    %ebx
f01052ec:	5e                   	pop    %esi
f01052ed:	5f                   	pop    %edi
f01052ee:	5d                   	pop    %ebp
f01052ef:	c3                   	ret    

f01052f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01052f0:	55                   	push   %ebp
f01052f1:	89 e5                	mov    %esp,%ebp
f01052f3:	83 ec 28             	sub    $0x28,%esp
f01052f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01052f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01052fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105303:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010530d:	85 c0                	test   %eax,%eax
f010530f:	74 30                	je     f0105341 <vsnprintf+0x51>
f0105311:	85 d2                	test   %edx,%edx
f0105313:	7e 2c                	jle    f0105341 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105315:	8b 45 14             	mov    0x14(%ebp),%eax
f0105318:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010531c:	8b 45 10             	mov    0x10(%ebp),%eax
f010531f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105323:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105326:	89 44 24 04          	mov    %eax,0x4(%esp)
f010532a:	c7 04 24 3f 4e 10 f0 	movl   $0xf0104e3f,(%esp)
f0105331:	e8 4e fb ff ff       	call   f0104e84 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105336:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105339:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010533f:	eb 05                	jmp    f0105346 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105341:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105346:	c9                   	leave  
f0105347:	c3                   	ret    

f0105348 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105348:	55                   	push   %ebp
f0105349:	89 e5                	mov    %esp,%ebp
f010534b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010534e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105351:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105355:	8b 45 10             	mov    0x10(%ebp),%eax
f0105358:	89 44 24 08          	mov    %eax,0x8(%esp)
f010535c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010535f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105363:	8b 45 08             	mov    0x8(%ebp),%eax
f0105366:	89 04 24             	mov    %eax,(%esp)
f0105369:	e8 82 ff ff ff       	call   f01052f0 <vsnprintf>
	va_end(ap);

	return rc;
}
f010536e:	c9                   	leave  
f010536f:	c3                   	ret    

f0105370 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105370:	55                   	push   %ebp
f0105371:	89 e5                	mov    %esp,%ebp
f0105373:	57                   	push   %edi
f0105374:	56                   	push   %esi
f0105375:	53                   	push   %ebx
f0105376:	83 ec 1c             	sub    $0x1c,%esp
f0105379:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010537c:	85 c0                	test   %eax,%eax
f010537e:	74 10                	je     f0105390 <readline+0x20>
		cprintf("%s", prompt);
f0105380:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105384:	c7 04 24 71 71 10 f0 	movl   $0xf0107171,(%esp)
f010538b:	e8 a4 eb ff ff       	call   f0103f34 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105397:	e8 ef b3 ff ff       	call   f010078b <iscons>
f010539c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010539e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01053a3:	e8 d2 b3 ff ff       	call   f010077a <getchar>
f01053a8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01053aa:	85 c0                	test   %eax,%eax
f01053ac:	79 17                	jns    f01053c5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01053ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053b2:	c7 04 24 c8 7b 10 f0 	movl   $0xf0107bc8,(%esp)
f01053b9:	e8 76 eb ff ff       	call   f0103f34 <cprintf>
			return NULL;
f01053be:	b8 00 00 00 00       	mov    $0x0,%eax
f01053c3:	eb 6d                	jmp    f0105432 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053c5:	83 f8 7f             	cmp    $0x7f,%eax
f01053c8:	74 05                	je     f01053cf <readline+0x5f>
f01053ca:	83 f8 08             	cmp    $0x8,%eax
f01053cd:	75 19                	jne    f01053e8 <readline+0x78>
f01053cf:	85 f6                	test   %esi,%esi
f01053d1:	7e 15                	jle    f01053e8 <readline+0x78>
			if (echoing)
f01053d3:	85 ff                	test   %edi,%edi
f01053d5:	74 0c                	je     f01053e3 <readline+0x73>
				cputchar('\b');
f01053d7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01053de:	e8 87 b3 ff ff       	call   f010076a <cputchar>
			i--;
f01053e3:	83 ee 01             	sub    $0x1,%esi
f01053e6:	eb bb                	jmp    f01053a3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053e8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01053ee:	7f 1c                	jg     f010540c <readline+0x9c>
f01053f0:	83 fb 1f             	cmp    $0x1f,%ebx
f01053f3:	7e 17                	jle    f010540c <readline+0x9c>
			if (echoing)
f01053f5:	85 ff                	test   %edi,%edi
f01053f7:	74 08                	je     f0105401 <readline+0x91>
				cputchar(c);
f01053f9:	89 1c 24             	mov    %ebx,(%esp)
f01053fc:	e8 69 b3 ff ff       	call   f010076a <cputchar>
			buf[i++] = c;
f0105401:	88 9e 80 aa 22 f0    	mov    %bl,-0xfdd5580(%esi)
f0105407:	8d 76 01             	lea    0x1(%esi),%esi
f010540a:	eb 97                	jmp    f01053a3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010540c:	83 fb 0d             	cmp    $0xd,%ebx
f010540f:	74 05                	je     f0105416 <readline+0xa6>
f0105411:	83 fb 0a             	cmp    $0xa,%ebx
f0105414:	75 8d                	jne    f01053a3 <readline+0x33>
			if (echoing)
f0105416:	85 ff                	test   %edi,%edi
f0105418:	74 0c                	je     f0105426 <readline+0xb6>
				cputchar('\n');
f010541a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105421:	e8 44 b3 ff ff       	call   f010076a <cputchar>
			buf[i] = 0;
f0105426:	c6 86 80 aa 22 f0 00 	movb   $0x0,-0xfdd5580(%esi)
			return buf;
f010542d:	b8 80 aa 22 f0       	mov    $0xf022aa80,%eax
		}
	}
}
f0105432:	83 c4 1c             	add    $0x1c,%esp
f0105435:	5b                   	pop    %ebx
f0105436:	5e                   	pop    %esi
f0105437:	5f                   	pop    %edi
f0105438:	5d                   	pop    %ebp
f0105439:	c3                   	ret    
f010543a:	66 90                	xchg   %ax,%ax
f010543c:	66 90                	xchg   %ax,%ax
f010543e:	66 90                	xchg   %ax,%ax

f0105440 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105440:	55                   	push   %ebp
f0105441:	89 e5                	mov    %esp,%ebp
f0105443:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105446:	b8 00 00 00 00       	mov    $0x0,%eax
f010544b:	eb 03                	jmp    f0105450 <strlen+0x10>
		n++;
f010544d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105450:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105454:	75 f7                	jne    f010544d <strlen+0xd>
		n++;
	return n;
}
f0105456:	5d                   	pop    %ebp
f0105457:	c3                   	ret    

f0105458 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105458:	55                   	push   %ebp
f0105459:	89 e5                	mov    %esp,%ebp
f010545b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010545e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105461:	b8 00 00 00 00       	mov    $0x0,%eax
f0105466:	eb 03                	jmp    f010546b <strnlen+0x13>
		n++;
f0105468:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010546b:	39 d0                	cmp    %edx,%eax
f010546d:	74 06                	je     f0105475 <strnlen+0x1d>
f010546f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105473:	75 f3                	jne    f0105468 <strnlen+0x10>
		n++;
	return n;
}
f0105475:	5d                   	pop    %ebp
f0105476:	c3                   	ret    

f0105477 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105477:	55                   	push   %ebp
f0105478:	89 e5                	mov    %esp,%ebp
f010547a:	53                   	push   %ebx
f010547b:	8b 45 08             	mov    0x8(%ebp),%eax
f010547e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105481:	89 c2                	mov    %eax,%edx
f0105483:	83 c2 01             	add    $0x1,%edx
f0105486:	83 c1 01             	add    $0x1,%ecx
f0105489:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010548d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105490:	84 db                	test   %bl,%bl
f0105492:	75 ef                	jne    f0105483 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105494:	5b                   	pop    %ebx
f0105495:	5d                   	pop    %ebp
f0105496:	c3                   	ret    

f0105497 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105497:	55                   	push   %ebp
f0105498:	89 e5                	mov    %esp,%ebp
f010549a:	53                   	push   %ebx
f010549b:	83 ec 08             	sub    $0x8,%esp
f010549e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054a1:	89 1c 24             	mov    %ebx,(%esp)
f01054a4:	e8 97 ff ff ff       	call   f0105440 <strlen>
	strcpy(dst + len, src);
f01054a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054b0:	01 d8                	add    %ebx,%eax
f01054b2:	89 04 24             	mov    %eax,(%esp)
f01054b5:	e8 bd ff ff ff       	call   f0105477 <strcpy>
	return dst;
}
f01054ba:	89 d8                	mov    %ebx,%eax
f01054bc:	83 c4 08             	add    $0x8,%esp
f01054bf:	5b                   	pop    %ebx
f01054c0:	5d                   	pop    %ebp
f01054c1:	c3                   	ret    

f01054c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054c2:	55                   	push   %ebp
f01054c3:	89 e5                	mov    %esp,%ebp
f01054c5:	56                   	push   %esi
f01054c6:	53                   	push   %ebx
f01054c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01054ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054cd:	89 f3                	mov    %esi,%ebx
f01054cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054d2:	89 f2                	mov    %esi,%edx
f01054d4:	eb 0f                	jmp    f01054e5 <strncpy+0x23>
		*dst++ = *src;
f01054d6:	83 c2 01             	add    $0x1,%edx
f01054d9:	0f b6 01             	movzbl (%ecx),%eax
f01054dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054df:	80 39 01             	cmpb   $0x1,(%ecx)
f01054e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054e5:	39 da                	cmp    %ebx,%edx
f01054e7:	75 ed                	jne    f01054d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054e9:	89 f0                	mov    %esi,%eax
f01054eb:	5b                   	pop    %ebx
f01054ec:	5e                   	pop    %esi
f01054ed:	5d                   	pop    %ebp
f01054ee:	c3                   	ret    

f01054ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01054ef:	55                   	push   %ebp
f01054f0:	89 e5                	mov    %esp,%ebp
f01054f2:	56                   	push   %esi
f01054f3:	53                   	push   %ebx
f01054f4:	8b 75 08             	mov    0x8(%ebp),%esi
f01054f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01054fd:	89 f0                	mov    %esi,%eax
f01054ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105503:	85 c9                	test   %ecx,%ecx
f0105505:	75 0b                	jne    f0105512 <strlcpy+0x23>
f0105507:	eb 1d                	jmp    f0105526 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105509:	83 c0 01             	add    $0x1,%eax
f010550c:	83 c2 01             	add    $0x1,%edx
f010550f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105512:	39 d8                	cmp    %ebx,%eax
f0105514:	74 0b                	je     f0105521 <strlcpy+0x32>
f0105516:	0f b6 0a             	movzbl (%edx),%ecx
f0105519:	84 c9                	test   %cl,%cl
f010551b:	75 ec                	jne    f0105509 <strlcpy+0x1a>
f010551d:	89 c2                	mov    %eax,%edx
f010551f:	eb 02                	jmp    f0105523 <strlcpy+0x34>
f0105521:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105523:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105526:	29 f0                	sub    %esi,%eax
}
f0105528:	5b                   	pop    %ebx
f0105529:	5e                   	pop    %esi
f010552a:	5d                   	pop    %ebp
f010552b:	c3                   	ret    

f010552c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010552c:	55                   	push   %ebp
f010552d:	89 e5                	mov    %esp,%ebp
f010552f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105532:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105535:	eb 06                	jmp    f010553d <strcmp+0x11>
		p++, q++;
f0105537:	83 c1 01             	add    $0x1,%ecx
f010553a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010553d:	0f b6 01             	movzbl (%ecx),%eax
f0105540:	84 c0                	test   %al,%al
f0105542:	74 04                	je     f0105548 <strcmp+0x1c>
f0105544:	3a 02                	cmp    (%edx),%al
f0105546:	74 ef                	je     f0105537 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105548:	0f b6 c0             	movzbl %al,%eax
f010554b:	0f b6 12             	movzbl (%edx),%edx
f010554e:	29 d0                	sub    %edx,%eax
}
f0105550:	5d                   	pop    %ebp
f0105551:	c3                   	ret    

f0105552 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105552:	55                   	push   %ebp
f0105553:	89 e5                	mov    %esp,%ebp
f0105555:	53                   	push   %ebx
f0105556:	8b 45 08             	mov    0x8(%ebp),%eax
f0105559:	8b 55 0c             	mov    0xc(%ebp),%edx
f010555c:	89 c3                	mov    %eax,%ebx
f010555e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105561:	eb 06                	jmp    f0105569 <strncmp+0x17>
		n--, p++, q++;
f0105563:	83 c0 01             	add    $0x1,%eax
f0105566:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105569:	39 d8                	cmp    %ebx,%eax
f010556b:	74 15                	je     f0105582 <strncmp+0x30>
f010556d:	0f b6 08             	movzbl (%eax),%ecx
f0105570:	84 c9                	test   %cl,%cl
f0105572:	74 04                	je     f0105578 <strncmp+0x26>
f0105574:	3a 0a                	cmp    (%edx),%cl
f0105576:	74 eb                	je     f0105563 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105578:	0f b6 00             	movzbl (%eax),%eax
f010557b:	0f b6 12             	movzbl (%edx),%edx
f010557e:	29 d0                	sub    %edx,%eax
f0105580:	eb 05                	jmp    f0105587 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105582:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105587:	5b                   	pop    %ebx
f0105588:	5d                   	pop    %ebp
f0105589:	c3                   	ret    

f010558a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010558a:	55                   	push   %ebp
f010558b:	89 e5                	mov    %esp,%ebp
f010558d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105590:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105594:	eb 07                	jmp    f010559d <strchr+0x13>
		if (*s == c)
f0105596:	38 ca                	cmp    %cl,%dl
f0105598:	74 0f                	je     f01055a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010559a:	83 c0 01             	add    $0x1,%eax
f010559d:	0f b6 10             	movzbl (%eax),%edx
f01055a0:	84 d2                	test   %dl,%dl
f01055a2:	75 f2                	jne    f0105596 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055a9:	5d                   	pop    %ebp
f01055aa:	c3                   	ret    

f01055ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055ab:	55                   	push   %ebp
f01055ac:	89 e5                	mov    %esp,%ebp
f01055ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01055b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055b5:	eb 07                	jmp    f01055be <strfind+0x13>
		if (*s == c)
f01055b7:	38 ca                	cmp    %cl,%dl
f01055b9:	74 0a                	je     f01055c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01055bb:	83 c0 01             	add    $0x1,%eax
f01055be:	0f b6 10             	movzbl (%eax),%edx
f01055c1:	84 d2                	test   %dl,%dl
f01055c3:	75 f2                	jne    f01055b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01055c5:	5d                   	pop    %ebp
f01055c6:	c3                   	ret    

f01055c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055c7:	55                   	push   %ebp
f01055c8:	89 e5                	mov    %esp,%ebp
f01055ca:	57                   	push   %edi
f01055cb:	56                   	push   %esi
f01055cc:	53                   	push   %ebx
f01055cd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01055d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01055d3:	85 c9                	test   %ecx,%ecx
f01055d5:	74 36                	je     f010560d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01055d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01055dd:	75 28                	jne    f0105607 <memset+0x40>
f01055df:	f6 c1 03             	test   $0x3,%cl
f01055e2:	75 23                	jne    f0105607 <memset+0x40>
		c &= 0xFF;
f01055e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055e8:	89 d3                	mov    %edx,%ebx
f01055ea:	c1 e3 08             	shl    $0x8,%ebx
f01055ed:	89 d6                	mov    %edx,%esi
f01055ef:	c1 e6 18             	shl    $0x18,%esi
f01055f2:	89 d0                	mov    %edx,%eax
f01055f4:	c1 e0 10             	shl    $0x10,%eax
f01055f7:	09 f0                	or     %esi,%eax
f01055f9:	09 c2                	or     %eax,%edx
f01055fb:	89 d0                	mov    %edx,%eax
f01055fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01055ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105602:	fc                   	cld    
f0105603:	f3 ab                	rep stos %eax,%es:(%edi)
f0105605:	eb 06                	jmp    f010560d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105607:	8b 45 0c             	mov    0xc(%ebp),%eax
f010560a:	fc                   	cld    
f010560b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010560d:	89 f8                	mov    %edi,%eax
f010560f:	5b                   	pop    %ebx
f0105610:	5e                   	pop    %esi
f0105611:	5f                   	pop    %edi
f0105612:	5d                   	pop    %ebp
f0105613:	c3                   	ret    

f0105614 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105614:	55                   	push   %ebp
f0105615:	89 e5                	mov    %esp,%ebp
f0105617:	57                   	push   %edi
f0105618:	56                   	push   %esi
f0105619:	8b 45 08             	mov    0x8(%ebp),%eax
f010561c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010561f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105622:	39 c6                	cmp    %eax,%esi
f0105624:	73 35                	jae    f010565b <memmove+0x47>
f0105626:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105629:	39 d0                	cmp    %edx,%eax
f010562b:	73 2e                	jae    f010565b <memmove+0x47>
		s += n;
		d += n;
f010562d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105630:	89 d6                	mov    %edx,%esi
f0105632:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105634:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010563a:	75 13                	jne    f010564f <memmove+0x3b>
f010563c:	f6 c1 03             	test   $0x3,%cl
f010563f:	75 0e                	jne    f010564f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105641:	83 ef 04             	sub    $0x4,%edi
f0105644:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105647:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010564a:	fd                   	std    
f010564b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010564d:	eb 09                	jmp    f0105658 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010564f:	83 ef 01             	sub    $0x1,%edi
f0105652:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105655:	fd                   	std    
f0105656:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105658:	fc                   	cld    
f0105659:	eb 1d                	jmp    f0105678 <memmove+0x64>
f010565b:	89 f2                	mov    %esi,%edx
f010565d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010565f:	f6 c2 03             	test   $0x3,%dl
f0105662:	75 0f                	jne    f0105673 <memmove+0x5f>
f0105664:	f6 c1 03             	test   $0x3,%cl
f0105667:	75 0a                	jne    f0105673 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105669:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010566c:	89 c7                	mov    %eax,%edi
f010566e:	fc                   	cld    
f010566f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105671:	eb 05                	jmp    f0105678 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105673:	89 c7                	mov    %eax,%edi
f0105675:	fc                   	cld    
f0105676:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105678:	5e                   	pop    %esi
f0105679:	5f                   	pop    %edi
f010567a:	5d                   	pop    %ebp
f010567b:	c3                   	ret    

f010567c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010567c:	55                   	push   %ebp
f010567d:	89 e5                	mov    %esp,%ebp
f010567f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105682:	8b 45 10             	mov    0x10(%ebp),%eax
f0105685:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105689:	8b 45 0c             	mov    0xc(%ebp),%eax
f010568c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105690:	8b 45 08             	mov    0x8(%ebp),%eax
f0105693:	89 04 24             	mov    %eax,(%esp)
f0105696:	e8 79 ff ff ff       	call   f0105614 <memmove>
}
f010569b:	c9                   	leave  
f010569c:	c3                   	ret    

f010569d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010569d:	55                   	push   %ebp
f010569e:	89 e5                	mov    %esp,%ebp
f01056a0:	56                   	push   %esi
f01056a1:	53                   	push   %ebx
f01056a2:	8b 55 08             	mov    0x8(%ebp),%edx
f01056a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056a8:	89 d6                	mov    %edx,%esi
f01056aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056ad:	eb 1a                	jmp    f01056c9 <memcmp+0x2c>
		if (*s1 != *s2)
f01056af:	0f b6 02             	movzbl (%edx),%eax
f01056b2:	0f b6 19             	movzbl (%ecx),%ebx
f01056b5:	38 d8                	cmp    %bl,%al
f01056b7:	74 0a                	je     f01056c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056b9:	0f b6 c0             	movzbl %al,%eax
f01056bc:	0f b6 db             	movzbl %bl,%ebx
f01056bf:	29 d8                	sub    %ebx,%eax
f01056c1:	eb 0f                	jmp    f01056d2 <memcmp+0x35>
		s1++, s2++;
f01056c3:	83 c2 01             	add    $0x1,%edx
f01056c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056c9:	39 f2                	cmp    %esi,%edx
f01056cb:	75 e2                	jne    f01056af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056d2:	5b                   	pop    %ebx
f01056d3:	5e                   	pop    %esi
f01056d4:	5d                   	pop    %ebp
f01056d5:	c3                   	ret    

f01056d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01056d6:	55                   	push   %ebp
f01056d7:	89 e5                	mov    %esp,%ebp
f01056d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01056dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01056df:	89 c2                	mov    %eax,%edx
f01056e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01056e4:	eb 07                	jmp    f01056ed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01056e6:	38 08                	cmp    %cl,(%eax)
f01056e8:	74 07                	je     f01056f1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056ea:	83 c0 01             	add    $0x1,%eax
f01056ed:	39 d0                	cmp    %edx,%eax
f01056ef:	72 f5                	jb     f01056e6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056f1:	5d                   	pop    %ebp
f01056f2:	c3                   	ret    

f01056f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056f3:	55                   	push   %ebp
f01056f4:	89 e5                	mov    %esp,%ebp
f01056f6:	57                   	push   %edi
f01056f7:	56                   	push   %esi
f01056f8:	53                   	push   %ebx
f01056f9:	8b 55 08             	mov    0x8(%ebp),%edx
f01056fc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056ff:	eb 03                	jmp    f0105704 <strtol+0x11>
		s++;
f0105701:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105704:	0f b6 0a             	movzbl (%edx),%ecx
f0105707:	80 f9 09             	cmp    $0x9,%cl
f010570a:	74 f5                	je     f0105701 <strtol+0xe>
f010570c:	80 f9 20             	cmp    $0x20,%cl
f010570f:	74 f0                	je     f0105701 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105711:	80 f9 2b             	cmp    $0x2b,%cl
f0105714:	75 0a                	jne    f0105720 <strtol+0x2d>
		s++;
f0105716:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105719:	bf 00 00 00 00       	mov    $0x0,%edi
f010571e:	eb 11                	jmp    f0105731 <strtol+0x3e>
f0105720:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105725:	80 f9 2d             	cmp    $0x2d,%cl
f0105728:	75 07                	jne    f0105731 <strtol+0x3e>
		s++, neg = 1;
f010572a:	8d 52 01             	lea    0x1(%edx),%edx
f010572d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105731:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105736:	75 15                	jne    f010574d <strtol+0x5a>
f0105738:	80 3a 30             	cmpb   $0x30,(%edx)
f010573b:	75 10                	jne    f010574d <strtol+0x5a>
f010573d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105741:	75 0a                	jne    f010574d <strtol+0x5a>
		s += 2, base = 16;
f0105743:	83 c2 02             	add    $0x2,%edx
f0105746:	b8 10 00 00 00       	mov    $0x10,%eax
f010574b:	eb 10                	jmp    f010575d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010574d:	85 c0                	test   %eax,%eax
f010574f:	75 0c                	jne    f010575d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105751:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105753:	80 3a 30             	cmpb   $0x30,(%edx)
f0105756:	75 05                	jne    f010575d <strtol+0x6a>
		s++, base = 8;
f0105758:	83 c2 01             	add    $0x1,%edx
f010575b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010575d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105762:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105765:	0f b6 0a             	movzbl (%edx),%ecx
f0105768:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010576b:	89 f0                	mov    %esi,%eax
f010576d:	3c 09                	cmp    $0x9,%al
f010576f:	77 08                	ja     f0105779 <strtol+0x86>
			dig = *s - '0';
f0105771:	0f be c9             	movsbl %cl,%ecx
f0105774:	83 e9 30             	sub    $0x30,%ecx
f0105777:	eb 20                	jmp    f0105799 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105779:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010577c:	89 f0                	mov    %esi,%eax
f010577e:	3c 19                	cmp    $0x19,%al
f0105780:	77 08                	ja     f010578a <strtol+0x97>
			dig = *s - 'a' + 10;
f0105782:	0f be c9             	movsbl %cl,%ecx
f0105785:	83 e9 57             	sub    $0x57,%ecx
f0105788:	eb 0f                	jmp    f0105799 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010578a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010578d:	89 f0                	mov    %esi,%eax
f010578f:	3c 19                	cmp    $0x19,%al
f0105791:	77 16                	ja     f01057a9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0105793:	0f be c9             	movsbl %cl,%ecx
f0105796:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105799:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010579c:	7d 0f                	jge    f01057ad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010579e:	83 c2 01             	add    $0x1,%edx
f01057a1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01057a5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01057a7:	eb bc                	jmp    f0105765 <strtol+0x72>
f01057a9:	89 d8                	mov    %ebx,%eax
f01057ab:	eb 02                	jmp    f01057af <strtol+0xbc>
f01057ad:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01057af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057b3:	74 05                	je     f01057ba <strtol+0xc7>
		*endptr = (char *) s;
f01057b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057b8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01057ba:	f7 d8                	neg    %eax
f01057bc:	85 ff                	test   %edi,%edi
f01057be:	0f 44 c3             	cmove  %ebx,%eax
}
f01057c1:	5b                   	pop    %ebx
f01057c2:	5e                   	pop    %esi
f01057c3:	5f                   	pop    %edi
f01057c4:	5d                   	pop    %ebp
f01057c5:	c3                   	ret    
f01057c6:	66 90                	xchg   %ax,%ax

f01057c8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01057c8:	fa                   	cli    

	xorw    %ax, %ax
f01057c9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01057cb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057cd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057cf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01057d1:	0f 01 16             	lgdtl  (%esi)
f01057d4:	74 70                	je     f0105846 <mpentry_end+0x4>
	movl    %cr0, %eax
f01057d6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01057d9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057dd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057e0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057e6:	08 00                	or     %al,(%eax)

f01057e8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057e8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01057ec:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057ee:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057f0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01057f2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01057f6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01057f8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01057fa:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f01057ff:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105802:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105805:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010580a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010580d:	8b 25 84 ae 22 f0    	mov    0xf022ae84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105813:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105818:	b8 d6 01 10 f0       	mov    $0xf01001d6,%eax
	call    *%eax
f010581d:	ff d0                	call   *%eax

f010581f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010581f:	eb fe                	jmp    f010581f <spin>
f0105821:	8d 76 00             	lea    0x0(%esi),%esi

f0105824 <gdt>:
	...
f010582c:	ff                   	(bad)  
f010582d:	ff 00                	incl   (%eax)
f010582f:	00 00                	add    %al,(%eax)
f0105831:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105838:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f010583c <gdtdesc>:
f010583c:	17                   	pop    %ss
f010583d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105842 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105842:	90                   	nop
f0105843:	66 90                	xchg   %ax,%ax
f0105845:	66 90                	xchg   %ax,%ax
f0105847:	66 90                	xchg   %ax,%ax
f0105849:	66 90                	xchg   %ax,%ax
f010584b:	66 90                	xchg   %ax,%ax
f010584d:	66 90                	xchg   %ax,%ax
f010584f:	90                   	nop

f0105850 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105850:	55                   	push   %ebp
f0105851:	89 e5                	mov    %esp,%ebp
f0105853:	56                   	push   %esi
f0105854:	53                   	push   %ebx
f0105855:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105858:	8b 0d 88 ae 22 f0    	mov    0xf022ae88,%ecx
f010585e:	89 c3                	mov    %eax,%ebx
f0105860:	c1 eb 0c             	shr    $0xc,%ebx
f0105863:	39 cb                	cmp    %ecx,%ebx
f0105865:	72 20                	jb     f0105887 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105867:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010586b:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0105872:	f0 
f0105873:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010587a:	00 
f010587b:	c7 04 24 65 7d 10 f0 	movl   $0xf0107d65,(%esp)
f0105882:	e8 b9 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105887:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010588d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010588f:	89 c2                	mov    %eax,%edx
f0105891:	c1 ea 0c             	shr    $0xc,%edx
f0105894:	39 d1                	cmp    %edx,%ecx
f0105896:	77 20                	ja     f01058b8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105898:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010589c:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f01058a3:	f0 
f01058a4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01058ab:	00 
f01058ac:	c7 04 24 65 7d 10 f0 	movl   $0xf0107d65,(%esp)
f01058b3:	e8 88 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058b8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01058be:	eb 36                	jmp    f01058f6 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058c0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01058c7:	00 
f01058c8:	c7 44 24 04 75 7d 10 	movl   $0xf0107d75,0x4(%esp)
f01058cf:	f0 
f01058d0:	89 1c 24             	mov    %ebx,(%esp)
f01058d3:	e8 c5 fd ff ff       	call   f010569d <memcmp>
f01058d8:	85 c0                	test   %eax,%eax
f01058da:	75 17                	jne    f01058f3 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058dc:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01058e1:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01058e5:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058e7:	83 c2 01             	add    $0x1,%edx
f01058ea:	83 fa 10             	cmp    $0x10,%edx
f01058ed:	75 f2                	jne    f01058e1 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058ef:	84 c0                	test   %al,%al
f01058f1:	74 0e                	je     f0105901 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01058f3:	83 c3 10             	add    $0x10,%ebx
f01058f6:	39 f3                	cmp    %esi,%ebx
f01058f8:	72 c6                	jb     f01058c0 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01058fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ff:	eb 02                	jmp    f0105903 <mpsearch1+0xb3>
f0105901:	89 d8                	mov    %ebx,%eax
}
f0105903:	83 c4 10             	add    $0x10,%esp
f0105906:	5b                   	pop    %ebx
f0105907:	5e                   	pop    %esi
f0105908:	5d                   	pop    %ebp
f0105909:	c3                   	ret    

f010590a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010590a:	55                   	push   %ebp
f010590b:	89 e5                	mov    %esp,%ebp
f010590d:	57                   	push   %edi
f010590e:	56                   	push   %esi
f010590f:	53                   	push   %ebx
f0105910:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105913:	c7 05 c0 b3 22 f0 20 	movl   $0xf022b020,0xf022b3c0
f010591a:	b0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010591d:	83 3d 88 ae 22 f0 00 	cmpl   $0x0,0xf022ae88
f0105924:	75 24                	jne    f010594a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105926:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010592d:	00 
f010592e:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0105935:	f0 
f0105936:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010593d:	00 
f010593e:	c7 04 24 65 7d 10 f0 	movl   $0xf0107d65,(%esp)
f0105945:	e8 f6 a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010594a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105951:	85 c0                	test   %eax,%eax
f0105953:	74 16                	je     f010596b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0105955:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105958:	ba 00 04 00 00       	mov    $0x400,%edx
f010595d:	e8 ee fe ff ff       	call   f0105850 <mpsearch1>
f0105962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105965:	85 c0                	test   %eax,%eax
f0105967:	75 3c                	jne    f01059a5 <mp_init+0x9b>
f0105969:	eb 20                	jmp    f010598b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010596b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105972:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105975:	2d 00 04 00 00       	sub    $0x400,%eax
f010597a:	ba 00 04 00 00       	mov    $0x400,%edx
f010597f:	e8 cc fe ff ff       	call   f0105850 <mpsearch1>
f0105984:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105987:	85 c0                	test   %eax,%eax
f0105989:	75 1a                	jne    f01059a5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010598b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105990:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105995:	e8 b6 fe ff ff       	call   f0105850 <mpsearch1>
f010599a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010599d:	85 c0                	test   %eax,%eax
f010599f:	0f 84 54 02 00 00    	je     f0105bf9 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01059a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059a8:	8b 70 04             	mov    0x4(%eax),%esi
f01059ab:	85 f6                	test   %esi,%esi
f01059ad:	74 06                	je     f01059b5 <mp_init+0xab>
f01059af:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01059b3:	74 11                	je     f01059c6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01059b5:	c7 04 24 d8 7b 10 f0 	movl   $0xf0107bd8,(%esp)
f01059bc:	e8 73 e5 ff ff       	call   f0103f34 <cprintf>
f01059c1:	e9 33 02 00 00       	jmp    f0105bf9 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059c6:	89 f0                	mov    %esi,%eax
f01059c8:	c1 e8 0c             	shr    $0xc,%eax
f01059cb:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f01059d1:	72 20                	jb     f01059f3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01059d7:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f01059de:	f0 
f01059df:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01059e6:	00 
f01059e7:	c7 04 24 65 7d 10 f0 	movl   $0xf0107d65,(%esp)
f01059ee:	e8 4d a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059f3:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059f9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105a00:	00 
f0105a01:	c7 44 24 04 7a 7d 10 	movl   $0xf0107d7a,0x4(%esp)
f0105a08:	f0 
f0105a09:	89 1c 24             	mov    %ebx,(%esp)
f0105a0c:	e8 8c fc ff ff       	call   f010569d <memcmp>
f0105a11:	85 c0                	test   %eax,%eax
f0105a13:	74 11                	je     f0105a26 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105a15:	c7 04 24 08 7c 10 f0 	movl   $0xf0107c08,(%esp)
f0105a1c:	e8 13 e5 ff ff       	call   f0103f34 <cprintf>
f0105a21:	e9 d3 01 00 00       	jmp    f0105bf9 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a26:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105a2a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105a2e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a31:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a36:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a3b:	eb 0d                	jmp    f0105a4a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f0105a3d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a44:	f0 
f0105a45:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a47:	83 c0 01             	add    $0x1,%eax
f0105a4a:	39 c7                	cmp    %eax,%edi
f0105a4c:	7f ef                	jg     f0105a3d <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a4e:	84 d2                	test   %dl,%dl
f0105a50:	74 11                	je     f0105a63 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a52:	c7 04 24 3c 7c 10 f0 	movl   $0xf0107c3c,(%esp)
f0105a59:	e8 d6 e4 ff ff       	call   f0103f34 <cprintf>
f0105a5e:	e9 96 01 00 00       	jmp    f0105bf9 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a63:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a67:	3c 04                	cmp    $0x4,%al
f0105a69:	74 1f                	je     f0105a8a <mp_init+0x180>
f0105a6b:	3c 01                	cmp    $0x1,%al
f0105a6d:	8d 76 00             	lea    0x0(%esi),%esi
f0105a70:	74 18                	je     f0105a8a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a72:	0f b6 c0             	movzbl %al,%eax
f0105a75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a79:	c7 04 24 60 7c 10 f0 	movl   $0xf0107c60,(%esp)
f0105a80:	e8 af e4 ff ff       	call   f0103f34 <cprintf>
f0105a85:	e9 6f 01 00 00       	jmp    f0105bf9 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a8a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f0105a8e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0105a92:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a94:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a99:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a9e:	eb 09                	jmp    f0105aa9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0105aa0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0105aa4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aa6:	83 c0 01             	add    $0x1,%eax
f0105aa9:	39 c6                	cmp    %eax,%esi
f0105aab:	7f f3                	jg     f0105aa0 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105aad:	02 53 2a             	add    0x2a(%ebx),%dl
f0105ab0:	84 d2                	test   %dl,%dl
f0105ab2:	74 11                	je     f0105ac5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ab4:	c7 04 24 80 7c 10 f0 	movl   $0xf0107c80,(%esp)
f0105abb:	e8 74 e4 ff ff       	call   f0103f34 <cprintf>
f0105ac0:	e9 34 01 00 00       	jmp    f0105bf9 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105ac5:	85 db                	test   %ebx,%ebx
f0105ac7:	0f 84 2c 01 00 00    	je     f0105bf9 <mp_init+0x2ef>
		return;
	ismp = 1;
f0105acd:	c7 05 00 b0 22 f0 01 	movl   $0x1,0xf022b000
f0105ad4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ad7:	8b 43 24             	mov    0x24(%ebx),%eax
f0105ada:	a3 00 c0 26 f0       	mov    %eax,0xf026c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105adf:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105ae2:	be 00 00 00 00       	mov    $0x0,%esi
f0105ae7:	e9 86 00 00 00       	jmp    f0105b72 <mp_init+0x268>
		switch (*p) {
f0105aec:	0f b6 07             	movzbl (%edi),%eax
f0105aef:	84 c0                	test   %al,%al
f0105af1:	74 06                	je     f0105af9 <mp_init+0x1ef>
f0105af3:	3c 04                	cmp    $0x4,%al
f0105af5:	77 57                	ja     f0105b4e <mp_init+0x244>
f0105af7:	eb 50                	jmp    f0105b49 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105af9:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105afd:	8d 76 00             	lea    0x0(%esi),%esi
f0105b00:	74 11                	je     f0105b13 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0105b02:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f0105b09:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105b0e:	a3 c0 b3 22 f0       	mov    %eax,0xf022b3c0
			if (ncpu < NCPU) {
f0105b13:	a1 c4 b3 22 f0       	mov    0xf022b3c4,%eax
f0105b18:	83 f8 07             	cmp    $0x7,%eax
f0105b1b:	7f 13                	jg     f0105b30 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0105b1d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105b20:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
				ncpu++;
f0105b26:	83 c0 01             	add    $0x1,%eax
f0105b29:	a3 c4 b3 22 f0       	mov    %eax,0xf022b3c4
f0105b2e:	eb 14                	jmp    f0105b44 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b30:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b38:	c7 04 24 b0 7c 10 f0 	movl   $0xf0107cb0,(%esp)
f0105b3f:	e8 f0 e3 ff ff       	call   f0103f34 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b44:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b47:	eb 26                	jmp    f0105b6f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b49:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b4c:	eb 21                	jmp    f0105b6f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b4e:	0f b6 c0             	movzbl %al,%eax
f0105b51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b55:	c7 04 24 d8 7c 10 f0 	movl   $0xf0107cd8,(%esp)
f0105b5c:	e8 d3 e3 ff ff       	call   f0103f34 <cprintf>
			ismp = 0;
f0105b61:	c7 05 00 b0 22 f0 00 	movl   $0x0,0xf022b000
f0105b68:	00 00 00 
			i = conf->entry;
f0105b6b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b6f:	83 c6 01             	add    $0x1,%esi
f0105b72:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b76:	39 c6                	cmp    %eax,%esi
f0105b78:	0f 82 6e ff ff ff    	jb     f0105aec <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b7e:	a1 c0 b3 22 f0       	mov    0xf022b3c0,%eax
f0105b83:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b8a:	83 3d 00 b0 22 f0 00 	cmpl   $0x0,0xf022b000
f0105b91:	75 22                	jne    f0105bb5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b93:	c7 05 c4 b3 22 f0 01 	movl   $0x1,0xf022b3c4
f0105b9a:	00 00 00 
		lapicaddr = 0;
f0105b9d:	c7 05 00 c0 26 f0 00 	movl   $0x0,0xf026c000
f0105ba4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ba7:	c7 04 24 f8 7c 10 f0 	movl   $0xf0107cf8,(%esp)
f0105bae:	e8 81 e3 ff ff       	call   f0103f34 <cprintf>
		return;
f0105bb3:	eb 44                	jmp    f0105bf9 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105bb5:	8b 15 c4 b3 22 f0    	mov    0xf022b3c4,%edx
f0105bbb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105bbf:	0f b6 00             	movzbl (%eax),%eax
f0105bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bc6:	c7 04 24 7f 7d 10 f0 	movl   $0xf0107d7f,(%esp)
f0105bcd:	e8 62 e3 ff ff       	call   f0103f34 <cprintf>

	if (mp->imcrp) {
f0105bd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bd5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bd9:	74 1e                	je     f0105bf9 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105bdb:	c7 04 24 24 7d 10 f0 	movl   $0xf0107d24,(%esp)
f0105be2:	e8 4d e3 ff ff       	call   f0103f34 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105be7:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bec:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bf1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bf2:	b2 23                	mov    $0x23,%dl
f0105bf4:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105bf5:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bf8:	ee                   	out    %al,(%dx)
	}
}
f0105bf9:	83 c4 2c             	add    $0x2c,%esp
f0105bfc:	5b                   	pop    %ebx
f0105bfd:	5e                   	pop    %esi
f0105bfe:	5f                   	pop    %edi
f0105bff:	5d                   	pop    %ebp
f0105c00:	c3                   	ret    

f0105c01 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105c01:	55                   	push   %ebp
f0105c02:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105c04:	8b 0d 04 c0 26 f0    	mov    0xf026c004,%ecx
f0105c0a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105c0d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105c0f:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105c14:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105c17:	5d                   	pop    %ebp
f0105c18:	c3                   	ret    

f0105c19 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105c19:	55                   	push   %ebp
f0105c1a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105c1c:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105c21:	85 c0                	test   %eax,%eax
f0105c23:	74 08                	je     f0105c2d <cpunum+0x14>
		return lapic[ID] >> 24;
f0105c25:	8b 40 20             	mov    0x20(%eax),%eax
f0105c28:	c1 e8 18             	shr    $0x18,%eax
f0105c2b:	eb 05                	jmp    f0105c32 <cpunum+0x19>
	return 0;
f0105c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c32:	5d                   	pop    %ebp
f0105c33:	c3                   	ret    

f0105c34 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c34:	a1 00 c0 26 f0       	mov    0xf026c000,%eax
f0105c39:	85 c0                	test   %eax,%eax
f0105c3b:	0f 84 23 01 00 00    	je     f0105d64 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c41:	55                   	push   %ebp
f0105c42:	89 e5                	mov    %esp,%ebp
f0105c44:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c47:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0105c4e:	00 
f0105c4f:	89 04 24             	mov    %eax,(%esp)
f0105c52:	e8 d0 b6 ff ff       	call   f0101327 <mmio_map_region>
f0105c57:	a3 04 c0 26 f0       	mov    %eax,0xf026c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c5c:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c61:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c66:	e8 96 ff ff ff       	call   f0105c01 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c6b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c70:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c75:	e8 87 ff ff ff       	call   f0105c01 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c7a:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c7f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c84:	e8 78 ff ff ff       	call   f0105c01 <lapicw>
	lapicw(TICR, 10000000); 
f0105c89:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c8e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c93:	e8 69 ff ff ff       	call   f0105c01 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c98:	e8 7c ff ff ff       	call   f0105c19 <cpunum>
f0105c9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca0:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105ca5:	39 05 c0 b3 22 f0    	cmp    %eax,0xf022b3c0
f0105cab:	74 0f                	je     f0105cbc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0105cad:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cb2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105cb7:	e8 45 ff ff ff       	call   f0105c01 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105cbc:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cc1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105cc6:	e8 36 ff ff ff       	call   f0105c01 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ccb:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105cd0:	8b 40 30             	mov    0x30(%eax),%eax
f0105cd3:	c1 e8 10             	shr    $0x10,%eax
f0105cd6:	3c 03                	cmp    $0x3,%al
f0105cd8:	76 0f                	jbe    f0105ce9 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0105cda:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cdf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105ce4:	e8 18 ff ff ff       	call   f0105c01 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ce9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cee:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cf3:	e8 09 ff ff ff       	call   f0105c01 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105cf8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cfd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d02:	e8 fa fe ff ff       	call   f0105c01 <lapicw>
	lapicw(ESR, 0);
f0105d07:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d0c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d11:	e8 eb fe ff ff       	call   f0105c01 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105d16:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d1b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d20:	e8 dc fe ff ff       	call   f0105c01 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105d25:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d2a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d2f:	e8 cd fe ff ff       	call   f0105c01 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d34:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d39:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d3e:	e8 be fe ff ff       	call   f0105c01 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d43:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f0105d49:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d4f:	f6 c4 10             	test   $0x10,%ah
f0105d52:	75 f5                	jne    f0105d49 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d54:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d59:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d5e:	e8 9e fe ff ff       	call   f0105c01 <lapicw>
}
f0105d63:	c9                   	leave  
f0105d64:	f3 c3                	repz ret 

f0105d66 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d66:	83 3d 04 c0 26 f0 00 	cmpl   $0x0,0xf026c004
f0105d6d:	74 13                	je     f0105d82 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d6f:	55                   	push   %ebp
f0105d70:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d72:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d77:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d7c:	e8 80 fe ff ff       	call   f0105c01 <lapicw>
}
f0105d81:	5d                   	pop    %ebp
f0105d82:	f3 c3                	repz ret 

f0105d84 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d84:	55                   	push   %ebp
f0105d85:	89 e5                	mov    %esp,%ebp
f0105d87:	56                   	push   %esi
f0105d88:	53                   	push   %ebx
f0105d89:	83 ec 10             	sub    $0x10,%esp
f0105d8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d92:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d97:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d9c:	ee                   	out    %al,(%dx)
f0105d9d:	b2 71                	mov    $0x71,%dl
f0105d9f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105da4:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105da5:	83 3d 88 ae 22 f0 00 	cmpl   $0x0,0xf022ae88
f0105dac:	75 24                	jne    f0105dd2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105dae:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0105db5:	00 
f0105db6:	c7 44 24 08 24 63 10 	movl   $0xf0106324,0x8(%esp)
f0105dbd:	f0 
f0105dbe:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0105dc5:	00 
f0105dc6:	c7 04 24 9c 7d 10 f0 	movl   $0xf0107d9c,(%esp)
f0105dcd:	e8 6e a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105dd2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105dd9:	00 00 
	wrv[1] = addr >> 4;
f0105ddb:	89 f0                	mov    %esi,%eax
f0105ddd:	c1 e8 04             	shr    $0x4,%eax
f0105de0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105de6:	c1 e3 18             	shl    $0x18,%ebx
f0105de9:	89 da                	mov    %ebx,%edx
f0105deb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105df0:	e8 0c fe ff ff       	call   f0105c01 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105df5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dfa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dff:	e8 fd fd ff ff       	call   f0105c01 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105e04:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105e09:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e0e:	e8 ee fd ff ff       	call   f0105c01 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e13:	c1 ee 0c             	shr    $0xc,%esi
f0105e16:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e1c:	89 da                	mov    %ebx,%edx
f0105e1e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e23:	e8 d9 fd ff ff       	call   f0105c01 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e28:	89 f2                	mov    %esi,%edx
f0105e2a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e2f:	e8 cd fd ff ff       	call   f0105c01 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e34:	89 da                	mov    %ebx,%edx
f0105e36:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e3b:	e8 c1 fd ff ff       	call   f0105c01 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e40:	89 f2                	mov    %esi,%edx
f0105e42:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e47:	e8 b5 fd ff ff       	call   f0105c01 <lapicw>
		microdelay(200);
	}
}
f0105e4c:	83 c4 10             	add    $0x10,%esp
f0105e4f:	5b                   	pop    %ebx
f0105e50:	5e                   	pop    %esi
f0105e51:	5d                   	pop    %ebp
f0105e52:	c3                   	ret    

f0105e53 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e53:	55                   	push   %ebp
f0105e54:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e56:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e59:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e5f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e64:	e8 98 fd ff ff       	call   f0105c01 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e69:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f0105e6f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e75:	f6 c4 10             	test   $0x10,%ah
f0105e78:	75 f5                	jne    f0105e6f <lapic_ipi+0x1c>
		;
}
f0105e7a:	5d                   	pop    %ebp
f0105e7b:	c3                   	ret    

f0105e7c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e7c:	55                   	push   %ebp
f0105e7d:	89 e5                	mov    %esp,%ebp
f0105e7f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e88:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e8b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e95:	5d                   	pop    %ebp
f0105e96:	c3                   	ret    

f0105e97 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e97:	55                   	push   %ebp
f0105e98:	89 e5                	mov    %esp,%ebp
f0105e9a:	56                   	push   %esi
f0105e9b:	53                   	push   %ebx
f0105e9c:	83 ec 20             	sub    $0x20,%esp
f0105e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105ea2:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ea5:	75 07                	jne    f0105eae <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105ea7:	ba 01 00 00 00       	mov    $0x1,%edx
f0105eac:	eb 42                	jmp    f0105ef0 <spin_lock+0x59>
f0105eae:	8b 73 08             	mov    0x8(%ebx),%esi
f0105eb1:	e8 63 fd ff ff       	call   f0105c19 <cpunum>
f0105eb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb9:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105ebe:	39 c6                	cmp    %eax,%esi
f0105ec0:	75 e5                	jne    f0105ea7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ec2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ec5:	e8 4f fd ff ff       	call   f0105c19 <cpunum>
f0105eca:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105ece:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ed2:	c7 44 24 08 ac 7d 10 	movl   $0xf0107dac,0x8(%esp)
f0105ed9:	f0 
f0105eda:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0105ee1:	00 
f0105ee2:	c7 04 24 10 7e 10 f0 	movl   $0xf0107e10,(%esp)
f0105ee9:	e8 52 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105eee:	f3 90                	pause  
f0105ef0:	89 d0                	mov    %edx,%eax
f0105ef2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ef5:	85 c0                	test   %eax,%eax
f0105ef7:	75 f5                	jne    f0105eee <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ef9:	e8 1b fd ff ff       	call   f0105c19 <cpunum>
f0105efe:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f01:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105f06:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105f09:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0105f0c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105f0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105f13:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105f19:	76 12                	jbe    f0105f2d <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105f1b:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105f1e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105f21:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105f23:	83 c0 01             	add    $0x1,%eax
f0105f26:	83 f8 0a             	cmp    $0xa,%eax
f0105f29:	75 e8                	jne    f0105f13 <spin_lock+0x7c>
f0105f2b:	eb 0f                	jmp    f0105f3c <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105f2d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105f34:	83 c0 01             	add    $0x1,%eax
f0105f37:	83 f8 09             	cmp    $0x9,%eax
f0105f3a:	7e f1                	jle    f0105f2d <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105f3c:	83 c4 20             	add    $0x20,%esp
f0105f3f:	5b                   	pop    %ebx
f0105f40:	5e                   	pop    %esi
f0105f41:	5d                   	pop    %ebp
f0105f42:	c3                   	ret    

f0105f43 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f43:	55                   	push   %ebp
f0105f44:	89 e5                	mov    %esp,%ebp
f0105f46:	57                   	push   %edi
f0105f47:	56                   	push   %esi
f0105f48:	53                   	push   %ebx
f0105f49:	83 ec 6c             	sub    $0x6c,%esp
f0105f4c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f4f:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f52:	74 18                	je     f0105f6c <spin_unlock+0x29>
f0105f54:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f57:	e8 bd fc ff ff       	call   f0105c19 <cpunum>
f0105f5c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f5f:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f64:	39 c3                	cmp    %eax,%ebx
f0105f66:	0f 84 ce 00 00 00    	je     f010603a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f6c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0105f73:	00 
f0105f74:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f7b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f7e:	89 1c 24             	mov    %ebx,(%esp)
f0105f81:	e8 8e f6 ff ff       	call   f0105614 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f86:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f89:	0f b6 38             	movzbl (%eax),%edi
f0105f8c:	8b 76 04             	mov    0x4(%esi),%esi
f0105f8f:	e8 85 fc ff ff       	call   f0105c19 <cpunum>
f0105f94:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105f98:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fa0:	c7 04 24 d8 7d 10 f0 	movl   $0xf0107dd8,(%esp)
f0105fa7:	e8 88 df ff ff       	call   f0103f34 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105fac:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105faf:	eb 65                	jmp    f0106016 <spin_unlock+0xd3>
f0105fb1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fb5:	89 04 24             	mov    %eax,(%esp)
f0105fb8:	e8 b1 eb ff ff       	call   f0104b6e <debuginfo_eip>
f0105fbd:	85 c0                	test   %eax,%eax
f0105fbf:	78 39                	js     f0105ffa <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105fc1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105fc3:	89 c2                	mov    %eax,%edx
f0105fc5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105fc8:	89 54 24 18          	mov    %edx,0x18(%esp)
f0105fcc:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0105fcf:	89 54 24 14          	mov    %edx,0x14(%esp)
f0105fd3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0105fd6:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105fda:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0105fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105fe1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0105fe4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105fe8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fec:	c7 04 24 20 7e 10 f0 	movl   $0xf0107e20,(%esp)
f0105ff3:	e8 3c df ff ff       	call   f0103f34 <cprintf>
f0105ff8:	eb 12                	jmp    f010600c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105ffa:	8b 06                	mov    (%esi),%eax
f0105ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106000:	c7 04 24 37 7e 10 f0 	movl   $0xf0107e37,(%esp)
f0106007:	e8 28 df ff ff       	call   f0103f34 <cprintf>
f010600c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010600f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106012:	39 c3                	cmp    %eax,%ebx
f0106014:	74 08                	je     f010601e <spin_unlock+0xdb>
f0106016:	89 de                	mov    %ebx,%esi
f0106018:	8b 03                	mov    (%ebx),%eax
f010601a:	85 c0                	test   %eax,%eax
f010601c:	75 93                	jne    f0105fb1 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010601e:	c7 44 24 08 3f 7e 10 	movl   $0xf0107e3f,0x8(%esp)
f0106025:	f0 
f0106026:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010602d:	00 
f010602e:	c7 04 24 10 7e 10 f0 	movl   $0xf0107e10,(%esp)
f0106035:	e8 06 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010603a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106041:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106048:	b8 00 00 00 00       	mov    $0x0,%eax
f010604d:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106050:	83 c4 6c             	add    $0x6c,%esp
f0106053:	5b                   	pop    %ebx
f0106054:	5e                   	pop    %esi
f0106055:	5f                   	pop    %edi
f0106056:	5d                   	pop    %ebp
f0106057:	c3                   	ret    
f0106058:	66 90                	xchg   %ax,%ax
f010605a:	66 90                	xchg   %ax,%ax
f010605c:	66 90                	xchg   %ax,%ax
f010605e:	66 90                	xchg   %ax,%ax

f0106060 <__udivdi3>:
f0106060:	55                   	push   %ebp
f0106061:	57                   	push   %edi
f0106062:	56                   	push   %esi
f0106063:	83 ec 0c             	sub    $0xc,%esp
f0106066:	8b 44 24 28          	mov    0x28(%esp),%eax
f010606a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010606e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106072:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106076:	85 c0                	test   %eax,%eax
f0106078:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010607c:	89 ea                	mov    %ebp,%edx
f010607e:	89 0c 24             	mov    %ecx,(%esp)
f0106081:	75 2d                	jne    f01060b0 <__udivdi3+0x50>
f0106083:	39 e9                	cmp    %ebp,%ecx
f0106085:	77 61                	ja     f01060e8 <__udivdi3+0x88>
f0106087:	85 c9                	test   %ecx,%ecx
f0106089:	89 ce                	mov    %ecx,%esi
f010608b:	75 0b                	jne    f0106098 <__udivdi3+0x38>
f010608d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106092:	31 d2                	xor    %edx,%edx
f0106094:	f7 f1                	div    %ecx
f0106096:	89 c6                	mov    %eax,%esi
f0106098:	31 d2                	xor    %edx,%edx
f010609a:	89 e8                	mov    %ebp,%eax
f010609c:	f7 f6                	div    %esi
f010609e:	89 c5                	mov    %eax,%ebp
f01060a0:	89 f8                	mov    %edi,%eax
f01060a2:	f7 f6                	div    %esi
f01060a4:	89 ea                	mov    %ebp,%edx
f01060a6:	83 c4 0c             	add    $0xc,%esp
f01060a9:	5e                   	pop    %esi
f01060aa:	5f                   	pop    %edi
f01060ab:	5d                   	pop    %ebp
f01060ac:	c3                   	ret    
f01060ad:	8d 76 00             	lea    0x0(%esi),%esi
f01060b0:	39 e8                	cmp    %ebp,%eax
f01060b2:	77 24                	ja     f01060d8 <__udivdi3+0x78>
f01060b4:	0f bd e8             	bsr    %eax,%ebp
f01060b7:	83 f5 1f             	xor    $0x1f,%ebp
f01060ba:	75 3c                	jne    f01060f8 <__udivdi3+0x98>
f01060bc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01060c0:	39 34 24             	cmp    %esi,(%esp)
f01060c3:	0f 86 9f 00 00 00    	jbe    f0106168 <__udivdi3+0x108>
f01060c9:	39 d0                	cmp    %edx,%eax
f01060cb:	0f 82 97 00 00 00    	jb     f0106168 <__udivdi3+0x108>
f01060d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060d8:	31 d2                	xor    %edx,%edx
f01060da:	31 c0                	xor    %eax,%eax
f01060dc:	83 c4 0c             	add    $0xc,%esp
f01060df:	5e                   	pop    %esi
f01060e0:	5f                   	pop    %edi
f01060e1:	5d                   	pop    %ebp
f01060e2:	c3                   	ret    
f01060e3:	90                   	nop
f01060e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060e8:	89 f8                	mov    %edi,%eax
f01060ea:	f7 f1                	div    %ecx
f01060ec:	31 d2                	xor    %edx,%edx
f01060ee:	83 c4 0c             	add    $0xc,%esp
f01060f1:	5e                   	pop    %esi
f01060f2:	5f                   	pop    %edi
f01060f3:	5d                   	pop    %ebp
f01060f4:	c3                   	ret    
f01060f5:	8d 76 00             	lea    0x0(%esi),%esi
f01060f8:	89 e9                	mov    %ebp,%ecx
f01060fa:	8b 3c 24             	mov    (%esp),%edi
f01060fd:	d3 e0                	shl    %cl,%eax
f01060ff:	89 c6                	mov    %eax,%esi
f0106101:	b8 20 00 00 00       	mov    $0x20,%eax
f0106106:	29 e8                	sub    %ebp,%eax
f0106108:	89 c1                	mov    %eax,%ecx
f010610a:	d3 ef                	shr    %cl,%edi
f010610c:	89 e9                	mov    %ebp,%ecx
f010610e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106112:	8b 3c 24             	mov    (%esp),%edi
f0106115:	09 74 24 08          	or     %esi,0x8(%esp)
f0106119:	89 d6                	mov    %edx,%esi
f010611b:	d3 e7                	shl    %cl,%edi
f010611d:	89 c1                	mov    %eax,%ecx
f010611f:	89 3c 24             	mov    %edi,(%esp)
f0106122:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106126:	d3 ee                	shr    %cl,%esi
f0106128:	89 e9                	mov    %ebp,%ecx
f010612a:	d3 e2                	shl    %cl,%edx
f010612c:	89 c1                	mov    %eax,%ecx
f010612e:	d3 ef                	shr    %cl,%edi
f0106130:	09 d7                	or     %edx,%edi
f0106132:	89 f2                	mov    %esi,%edx
f0106134:	89 f8                	mov    %edi,%eax
f0106136:	f7 74 24 08          	divl   0x8(%esp)
f010613a:	89 d6                	mov    %edx,%esi
f010613c:	89 c7                	mov    %eax,%edi
f010613e:	f7 24 24             	mull   (%esp)
f0106141:	39 d6                	cmp    %edx,%esi
f0106143:	89 14 24             	mov    %edx,(%esp)
f0106146:	72 30                	jb     f0106178 <__udivdi3+0x118>
f0106148:	8b 54 24 04          	mov    0x4(%esp),%edx
f010614c:	89 e9                	mov    %ebp,%ecx
f010614e:	d3 e2                	shl    %cl,%edx
f0106150:	39 c2                	cmp    %eax,%edx
f0106152:	73 05                	jae    f0106159 <__udivdi3+0xf9>
f0106154:	3b 34 24             	cmp    (%esp),%esi
f0106157:	74 1f                	je     f0106178 <__udivdi3+0x118>
f0106159:	89 f8                	mov    %edi,%eax
f010615b:	31 d2                	xor    %edx,%edx
f010615d:	e9 7a ff ff ff       	jmp    f01060dc <__udivdi3+0x7c>
f0106162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106168:	31 d2                	xor    %edx,%edx
f010616a:	b8 01 00 00 00       	mov    $0x1,%eax
f010616f:	e9 68 ff ff ff       	jmp    f01060dc <__udivdi3+0x7c>
f0106174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106178:	8d 47 ff             	lea    -0x1(%edi),%eax
f010617b:	31 d2                	xor    %edx,%edx
f010617d:	83 c4 0c             	add    $0xc,%esp
f0106180:	5e                   	pop    %esi
f0106181:	5f                   	pop    %edi
f0106182:	5d                   	pop    %ebp
f0106183:	c3                   	ret    
f0106184:	66 90                	xchg   %ax,%ax
f0106186:	66 90                	xchg   %ax,%ax
f0106188:	66 90                	xchg   %ax,%ax
f010618a:	66 90                	xchg   %ax,%ax
f010618c:	66 90                	xchg   %ax,%ax
f010618e:	66 90                	xchg   %ax,%ax

f0106190 <__umoddi3>:
f0106190:	55                   	push   %ebp
f0106191:	57                   	push   %edi
f0106192:	56                   	push   %esi
f0106193:	83 ec 14             	sub    $0x14,%esp
f0106196:	8b 44 24 28          	mov    0x28(%esp),%eax
f010619a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010619e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01061a2:	89 c7                	mov    %eax,%edi
f01061a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061a8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01061ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01061b0:	89 34 24             	mov    %esi,(%esp)
f01061b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061b7:	85 c0                	test   %eax,%eax
f01061b9:	89 c2                	mov    %eax,%edx
f01061bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01061bf:	75 17                	jne    f01061d8 <__umoddi3+0x48>
f01061c1:	39 fe                	cmp    %edi,%esi
f01061c3:	76 4b                	jbe    f0106210 <__umoddi3+0x80>
f01061c5:	89 c8                	mov    %ecx,%eax
f01061c7:	89 fa                	mov    %edi,%edx
f01061c9:	f7 f6                	div    %esi
f01061cb:	89 d0                	mov    %edx,%eax
f01061cd:	31 d2                	xor    %edx,%edx
f01061cf:	83 c4 14             	add    $0x14,%esp
f01061d2:	5e                   	pop    %esi
f01061d3:	5f                   	pop    %edi
f01061d4:	5d                   	pop    %ebp
f01061d5:	c3                   	ret    
f01061d6:	66 90                	xchg   %ax,%ax
f01061d8:	39 f8                	cmp    %edi,%eax
f01061da:	77 54                	ja     f0106230 <__umoddi3+0xa0>
f01061dc:	0f bd e8             	bsr    %eax,%ebp
f01061df:	83 f5 1f             	xor    $0x1f,%ebp
f01061e2:	75 5c                	jne    f0106240 <__umoddi3+0xb0>
f01061e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01061e8:	39 3c 24             	cmp    %edi,(%esp)
f01061eb:	0f 87 e7 00 00 00    	ja     f01062d8 <__umoddi3+0x148>
f01061f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01061f5:	29 f1                	sub    %esi,%ecx
f01061f7:	19 c7                	sbb    %eax,%edi
f01061f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106201:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106205:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106209:	83 c4 14             	add    $0x14,%esp
f010620c:	5e                   	pop    %esi
f010620d:	5f                   	pop    %edi
f010620e:	5d                   	pop    %ebp
f010620f:	c3                   	ret    
f0106210:	85 f6                	test   %esi,%esi
f0106212:	89 f5                	mov    %esi,%ebp
f0106214:	75 0b                	jne    f0106221 <__umoddi3+0x91>
f0106216:	b8 01 00 00 00       	mov    $0x1,%eax
f010621b:	31 d2                	xor    %edx,%edx
f010621d:	f7 f6                	div    %esi
f010621f:	89 c5                	mov    %eax,%ebp
f0106221:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106225:	31 d2                	xor    %edx,%edx
f0106227:	f7 f5                	div    %ebp
f0106229:	89 c8                	mov    %ecx,%eax
f010622b:	f7 f5                	div    %ebp
f010622d:	eb 9c                	jmp    f01061cb <__umoddi3+0x3b>
f010622f:	90                   	nop
f0106230:	89 c8                	mov    %ecx,%eax
f0106232:	89 fa                	mov    %edi,%edx
f0106234:	83 c4 14             	add    $0x14,%esp
f0106237:	5e                   	pop    %esi
f0106238:	5f                   	pop    %edi
f0106239:	5d                   	pop    %ebp
f010623a:	c3                   	ret    
f010623b:	90                   	nop
f010623c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106240:	8b 04 24             	mov    (%esp),%eax
f0106243:	be 20 00 00 00       	mov    $0x20,%esi
f0106248:	89 e9                	mov    %ebp,%ecx
f010624a:	29 ee                	sub    %ebp,%esi
f010624c:	d3 e2                	shl    %cl,%edx
f010624e:	89 f1                	mov    %esi,%ecx
f0106250:	d3 e8                	shr    %cl,%eax
f0106252:	89 e9                	mov    %ebp,%ecx
f0106254:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106258:	8b 04 24             	mov    (%esp),%eax
f010625b:	09 54 24 04          	or     %edx,0x4(%esp)
f010625f:	89 fa                	mov    %edi,%edx
f0106261:	d3 e0                	shl    %cl,%eax
f0106263:	89 f1                	mov    %esi,%ecx
f0106265:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106269:	8b 44 24 10          	mov    0x10(%esp),%eax
f010626d:	d3 ea                	shr    %cl,%edx
f010626f:	89 e9                	mov    %ebp,%ecx
f0106271:	d3 e7                	shl    %cl,%edi
f0106273:	89 f1                	mov    %esi,%ecx
f0106275:	d3 e8                	shr    %cl,%eax
f0106277:	89 e9                	mov    %ebp,%ecx
f0106279:	09 f8                	or     %edi,%eax
f010627b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010627f:	f7 74 24 04          	divl   0x4(%esp)
f0106283:	d3 e7                	shl    %cl,%edi
f0106285:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106289:	89 d7                	mov    %edx,%edi
f010628b:	f7 64 24 08          	mull   0x8(%esp)
f010628f:	39 d7                	cmp    %edx,%edi
f0106291:	89 c1                	mov    %eax,%ecx
f0106293:	89 14 24             	mov    %edx,(%esp)
f0106296:	72 2c                	jb     f01062c4 <__umoddi3+0x134>
f0106298:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010629c:	72 22                	jb     f01062c0 <__umoddi3+0x130>
f010629e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01062a2:	29 c8                	sub    %ecx,%eax
f01062a4:	19 d7                	sbb    %edx,%edi
f01062a6:	89 e9                	mov    %ebp,%ecx
f01062a8:	89 fa                	mov    %edi,%edx
f01062aa:	d3 e8                	shr    %cl,%eax
f01062ac:	89 f1                	mov    %esi,%ecx
f01062ae:	d3 e2                	shl    %cl,%edx
f01062b0:	89 e9                	mov    %ebp,%ecx
f01062b2:	d3 ef                	shr    %cl,%edi
f01062b4:	09 d0                	or     %edx,%eax
f01062b6:	89 fa                	mov    %edi,%edx
f01062b8:	83 c4 14             	add    $0x14,%esp
f01062bb:	5e                   	pop    %esi
f01062bc:	5f                   	pop    %edi
f01062bd:	5d                   	pop    %ebp
f01062be:	c3                   	ret    
f01062bf:	90                   	nop
f01062c0:	39 d7                	cmp    %edx,%edi
f01062c2:	75 da                	jne    f010629e <__umoddi3+0x10e>
f01062c4:	8b 14 24             	mov    (%esp),%edx
f01062c7:	89 c1                	mov    %eax,%ecx
f01062c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01062cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01062d1:	eb cb                	jmp    f010629e <__umoddi3+0x10e>
f01062d3:	90                   	nop
f01062d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01062dc:	0f 82 0f ff ff ff    	jb     f01061f1 <__umoddi3+0x61>
f01062e2:	e9 1a ff ff ff       	jmp    f0106201 <__umoddi3+0x71>
