
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

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
f010004b:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 d5 61 00 00       	call   f0106239 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 69 10 f0 	movl   $0xf0106920,(%esp)
f010007d:	e8 f0 3e 00 00       	call   f0103f72 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 b1 3e 00 00       	call   f0103f3f <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 50 7a 10 f0 	movl   $0xf0107a50,(%esp)
f0100095:	e8 d8 3e 00 00       	call   f0103f72 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 43 08 00 00       	call   f01008e9 <monitor>
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
f01000af:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f01000b4:	2d 5f a9 22 f0       	sub    $0xf022a95f,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 5f a9 22 f0 	movl   $0xf022a95f,(%esp)
f01000cc:	e8 16 5b 00 00       	call   f0105be7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 b9 05 00 00       	call   f010068f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 8c 69 10 f0 	movl   $0xf010698c,(%esp)
f01000e5:	e8 88 3e 00 00       	call   f0103f72 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 dd 12 00 00       	call   f01013cc <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 fd 35 00 00       	call   f01036f1 <env_init>
	trap_init();
f01000f4:	e8 67 3f 00 00       	call   f0104060 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 2c 5e 00 00       	call   f0105f2a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 4f 61 00 00       	call   f0106254 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 98 3d 00 00       	call   f0103ea2 <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	spin_initlock(&kernel_lock);
f010010a:	c7 44 24 04 a7 69 10 	movl   $0xf01069a7,0x4(%esp)
f0100111:	f0 
f0100112:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100119:	e8 7e 63 00 00       	call   f010649c <__spin_initlock>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011e:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100125:	e8 8d 63 00 00       	call   f01064b7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010012a:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f0100131:	77 24                	ja     f0100157 <i386_init+0xaf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100133:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f010013a:	00 
f010013b:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0100142:	f0 
f0100143:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 b4 69 10 f0 	movl   $0xf01069b4,(%esp)
f0100152:	e8 e9 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100157:	b8 62 5e 10 f0       	mov    $0xf0105e62,%eax
f010015c:	2d e8 5d 10 f0       	sub    $0xf0105de8,%eax
f0100161:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100165:	c7 44 24 04 e8 5d 10 	movl   $0xf0105de8,0x4(%esp)
f010016c:	f0 
f010016d:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100174:	e8 bb 5a 00 00       	call   f0105c34 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100179:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f010017e:	eb 4d                	jmp    f01001cd <i386_init+0x125>
		if (c == cpus + cpunum())  // We've started already.
f0100180:	e8 b4 60 00 00       	call   f0106239 <cpunum>
f0100185:	6b c0 74             	imul   $0x74,%eax,%eax
f0100188:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010018d:	39 c3                	cmp    %eax,%ebx
f010018f:	74 39                	je     f01001ca <i386_init+0x122>
f0100191:	89 d8                	mov    %ebx,%eax
f0100193:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100198:	c1 f8 02             	sar    $0x2,%eax
f010019b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001a1:	c1 e0 0f             	shl    $0xf,%eax
f01001a4:	8d 80 00 50 23 f0    	lea    -0xfdcb000(%eax),%eax
f01001aa:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001af:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001b6:	00 
f01001b7:	0f b6 03             	movzbl (%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 e2 61 00 00       	call   f01063a4 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001c2:	8b 43 04             	mov    0x4(%ebx),%eax
f01001c5:	83 f8 01             	cmp    $0x1,%eax
f01001c8:	75 f8                	jne    f01001c2 <i386_init+0x11a>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ca:	83 c3 74             	add    $0x74,%ebx
f01001cd:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01001d4:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001d9:	39 c3                	cmp    %eax,%ebx
f01001db:	72 a3                	jb     f0100180 <i386_init+0xd8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001e4:	00 
f01001e5:	c7 04 24 75 0e 1a f0 	movl   $0xf01a0e75,(%esp)
f01001ec:	e8 10 37 00 00       	call   f0103901 <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f01001f1:	e8 93 48 00 00       	call   f0104a89 <sched_yield>

f01001f6 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001f6:	55                   	push   %ebp
f01001f7:	89 e5                	mov    %esp,%ebp
f01001f9:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001fc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100201:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100206:	77 20                	ja     f0100228 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100208:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010020c:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0100213:	f0 
f0100214:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f010021b:	00 
f010021c:	c7 04 24 b4 69 10 f0 	movl   $0xf01069b4,(%esp)
f0100223:	e8 18 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100228:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010022d:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100230:	e8 04 60 00 00       	call   f0106239 <cpunum>
f0100235:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100239:	c7 04 24 c0 69 10 f0 	movl   $0xf01069c0,(%esp)
f0100240:	e8 2d 3d 00 00       	call   f0103f72 <cprintf>

	lapic_init();
f0100245:	e8 0a 60 00 00       	call   f0106254 <lapic_init>
	env_init_percpu();
f010024a:	e8 78 34 00 00       	call   f01036c7 <env_init_percpu>
	trap_init_percpu();
f010024f:	90                   	nop
f0100250:	e8 3b 3d 00 00       	call   f0103f90 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100255:	e8 df 5f 00 00       	call   f0106239 <cpunum>
f010025a:	6b d0 74             	imul   $0x74,%eax,%edx
f010025d:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100263:	b8 01 00 00 00       	mov    $0x1,%eax
f0100268:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010026c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100273:	e8 3f 62 00 00       	call   f01064b7 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100278:	e8 0c 48 00 00       	call   f0104a89 <sched_yield>

f010027d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010027d:	55                   	push   %ebp
f010027e:	89 e5                	mov    %esp,%ebp
f0100280:	53                   	push   %ebx
f0100281:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100284:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100287:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010028e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100291:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100295:	c7 04 24 d6 69 10 f0 	movl   $0xf01069d6,(%esp)
f010029c:	e8 d1 3c 00 00       	call   f0103f72 <cprintf>
	vcprintf(fmt, ap);
f01002a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a5:	8b 45 10             	mov    0x10(%ebp),%eax
f01002a8:	89 04 24             	mov    %eax,(%esp)
f01002ab:	e8 8f 3c 00 00       	call   f0103f3f <vcprintf>
	cprintf("\n");
f01002b0:	c7 04 24 50 7a 10 f0 	movl   $0xf0107a50,(%esp)
f01002b7:	e8 b6 3c 00 00       	call   f0103f72 <cprintf>
	va_end(ap);
}
f01002bc:	83 c4 14             	add    $0x14,%esp
f01002bf:	5b                   	pop    %ebx
f01002c0:	5d                   	pop    %ebp
f01002c1:	c3                   	ret    
f01002c2:	66 90                	xchg   %ax,%ax
f01002c4:	66 90                	xchg   %ax,%ax
f01002c6:	66 90                	xchg   %ax,%ax
f01002c8:	66 90                	xchg   %ax,%ax
f01002ca:	66 90                	xchg   %ax,%ax
f01002cc:	66 90                	xchg   %ax,%ax
f01002ce:	66 90                	xchg   %ax,%ax

f01002d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d9:	a8 01                	test   $0x1,%al
f01002db:	74 08                	je     f01002e5 <serial_proc_data+0x15>
f01002dd:	b2 f8                	mov    $0xf8,%dl
f01002df:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002e0:	0f b6 c0             	movzbl %al,%eax
f01002e3:	eb 05                	jmp    f01002ea <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ea:	5d                   	pop    %ebp
f01002eb:	c3                   	ret    

f01002ec <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp
f01002f3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002f5:	eb 2a                	jmp    f0100321 <cons_intr+0x35>
		if (c == 0)
f01002f7:	85 d2                	test   %edx,%edx
f01002f9:	74 26                	je     f0100321 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002fb:	a1 24 b2 22 f0       	mov    0xf022b224,%eax
f0100300:	8d 48 01             	lea    0x1(%eax),%ecx
f0100303:	89 0d 24 b2 22 f0    	mov    %ecx,0xf022b224
f0100309:	88 90 20 b0 22 f0    	mov    %dl,-0xfdd4fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010030f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100315:	75 0a                	jne    f0100321 <cons_intr+0x35>
			cons.wpos = 0;
f0100317:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
f010031e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100321:	ff d3                	call   *%ebx
f0100323:	89 c2                	mov    %eax,%edx
f0100325:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100328:	75 cd                	jne    f01002f7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010032a:	83 c4 04             	add    $0x4,%esp
f010032d:	5b                   	pop    %ebx
f010032e:	5d                   	pop    %ebp
f010032f:	c3                   	ret    

f0100330 <kbd_proc_data>:
f0100330:	ba 64 00 00 00       	mov    $0x64,%edx
f0100335:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100336:	a8 01                	test   $0x1,%al
f0100338:	0f 84 ef 00 00 00    	je     f010042d <kbd_proc_data+0xfd>
f010033e:	b2 60                	mov    $0x60,%dl
f0100340:	ec                   	in     (%dx),%al
f0100341:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100343:	3c e0                	cmp    $0xe0,%al
f0100345:	75 0d                	jne    f0100354 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100347:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
		return 0;
f010034e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100353:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100354:	55                   	push   %ebp
f0100355:	89 e5                	mov    %esp,%ebp
f0100357:	53                   	push   %ebx
f0100358:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010035b:	84 c0                	test   %al,%al
f010035d:	79 37                	jns    f0100396 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 40 6b 10 f0 	movzbl -0xfef94c0(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c1                	and    %eax,%ecx
f0100386:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
		return 0;
f010038c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100391:	e9 9d 00 00 00       	jmp    f0100433 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100396:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f010039c:	f6 c1 40             	test   $0x40,%cl
f010039f:	74 0e                	je     f01003af <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003a1:	83 c8 80             	or     $0xffffff80,%eax
f01003a4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003a6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a9:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f01003af:	0f b6 d2             	movzbl %dl,%edx
f01003b2:	0f b6 82 40 6b 10 f0 	movzbl -0xfef94c0(%edx),%eax
f01003b9:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
	shift ^= togglecode[data];
f01003bf:	0f b6 8a 40 6a 10 f0 	movzbl -0xfef95c0(%edx),%ecx
f01003c6:	31 c8                	xor    %ecx,%eax
f01003c8:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003cd:	89 c1                	mov    %eax,%ecx
f01003cf:	83 e1 03             	and    $0x3,%ecx
f01003d2:	8b 0c 8d 20 6a 10 f0 	mov    -0xfef95e0(,%ecx,4),%ecx
f01003d9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003dd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003e0:	a8 08                	test   $0x8,%al
f01003e2:	74 1b                	je     f01003ff <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003e4:	89 da                	mov    %ebx,%edx
f01003e6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e9:	83 f9 19             	cmp    $0x19,%ecx
f01003ec:	77 05                	ja     f01003f3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003ee:	83 eb 20             	sub    $0x20,%ebx
f01003f1:	eb 0c                	jmp    f01003ff <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003f3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003f6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003f9:	83 fa 19             	cmp    $0x19,%edx
f01003fc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ff:	f7 d0                	not    %eax
f0100401:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100403:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100405:	f6 c2 06             	test   $0x6,%dl
f0100408:	75 29                	jne    f0100433 <kbd_proc_data+0x103>
f010040a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100410:	75 21                	jne    f0100433 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100412:	c7 04 24 f0 69 10 f0 	movl   $0xf01069f0,(%esp)
f0100419:	e8 54 3b 00 00       	call   f0103f72 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100423:	b8 03 00 00 00       	mov    $0x3,%eax
f0100428:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	eb 06                	jmp    f0100433 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010042d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100432:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100433:	83 c4 14             	add    $0x14,%esp
f0100436:	5b                   	pop    %ebx
f0100437:	5d                   	pop    %ebp
f0100438:	c3                   	ret    

f0100439 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100439:	55                   	push   %ebp
f010043a:	89 e5                	mov    %esp,%ebp
f010043c:	57                   	push   %edi
f010043d:	56                   	push   %esi
f010043e:	53                   	push   %ebx
f010043f:	83 ec 1c             	sub    $0x1c,%esp
f0100442:	89 c7                	mov    %eax,%edi
f0100444:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100449:	be fd 03 00 00       	mov    $0x3fd,%esi
f010044e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100453:	eb 06                	jmp    f010045b <cons_putc+0x22>
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ec                   	in     (%dx),%al
f0100458:	ec                   	in     (%dx),%al
f0100459:	ec                   	in     (%dx),%al
f010045a:	ec                   	in     (%dx),%al
f010045b:	89 f2                	mov    %esi,%edx
f010045d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010045e:	a8 20                	test   $0x20,%al
f0100460:	75 05                	jne    f0100467 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100462:	83 eb 01             	sub    $0x1,%ebx
f0100465:	75 ee                	jne    f0100455 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100467:	89 f8                	mov    %edi,%eax
f0100469:	0f b6 c0             	movzbl %al,%eax
f010046c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100474:	ee                   	out    %al,(%dx)
f0100475:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010047a:	be 79 03 00 00       	mov    $0x379,%esi
f010047f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100484:	eb 06                	jmp    f010048c <cons_putc+0x53>
f0100486:	89 ca                	mov    %ecx,%edx
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	ec                   	in     (%dx),%al
f010048b:	ec                   	in     (%dx),%al
f010048c:	89 f2                	mov    %esi,%edx
f010048e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010048f:	84 c0                	test   %al,%al
f0100491:	78 05                	js     f0100498 <cons_putc+0x5f>
f0100493:	83 eb 01             	sub    $0x1,%ebx
f0100496:	75 ee                	jne    f0100486 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100498:	ba 78 03 00 00       	mov    $0x378,%edx
f010049d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004a1:	ee                   	out    %al,(%dx)
f01004a2:	b2 7a                	mov    $0x7a,%dl
f01004a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a9:	ee                   	out    %al,(%dx)
f01004aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01004af:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004b0:	89 fa                	mov    %edi,%edx
f01004b2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004b8:	89 f8                	mov    %edi,%eax
f01004ba:	80 cc 07             	or     $0x7,%ah
f01004bd:	85 d2                	test   %edx,%edx
f01004bf:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004c2:	89 f8                	mov    %edi,%eax
f01004c4:	0f b6 c0             	movzbl %al,%eax
f01004c7:	83 f8 09             	cmp    $0x9,%eax
f01004ca:	74 76                	je     f0100542 <cons_putc+0x109>
f01004cc:	83 f8 09             	cmp    $0x9,%eax
f01004cf:	7f 0a                	jg     f01004db <cons_putc+0xa2>
f01004d1:	83 f8 08             	cmp    $0x8,%eax
f01004d4:	74 16                	je     f01004ec <cons_putc+0xb3>
f01004d6:	e9 9b 00 00 00       	jmp    f0100576 <cons_putc+0x13d>
f01004db:	83 f8 0a             	cmp    $0xa,%eax
f01004de:	66 90                	xchg   %ax,%ax
f01004e0:	74 3a                	je     f010051c <cons_putc+0xe3>
f01004e2:	83 f8 0d             	cmp    $0xd,%eax
f01004e5:	74 3d                	je     f0100524 <cons_putc+0xeb>
f01004e7:	e9 8a 00 00 00       	jmp    f0100576 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01004ec:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f01004f3:	66 85 c0             	test   %ax,%ax
f01004f6:	0f 84 e5 00 00 00    	je     f01005e1 <cons_putc+0x1a8>
			crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	66 81 e7 00 ff       	and    $0xff00,%di
f010050d:	83 cf 20             	or     $0x20,%edi
f0100510:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100516:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051a:	eb 78                	jmp    f0100594 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010051c:	66 83 05 28 b2 22 f0 	addw   $0x50,0xf022b228
f0100523:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100524:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010052b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100531:	c1 e8 16             	shr    $0x16,%eax
f0100534:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100537:	c1 e0 04             	shl    $0x4,%eax
f010053a:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
f0100540:	eb 52                	jmp    f0100594 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100542:	b8 20 00 00 00       	mov    $0x20,%eax
f0100547:	e8 ed fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 e3 fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 d9 fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f0100560:	b8 20 00 00 00       	mov    $0x20,%eax
f0100565:	e8 cf fe ff ff       	call   f0100439 <cons_putc>
		cons_putc(' ');
f010056a:	b8 20 00 00 00       	mov    $0x20,%eax
f010056f:	e8 c5 fe ff ff       	call   f0100439 <cons_putc>
f0100574:	eb 1e                	jmp    f0100594 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100576:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100594:	66 81 3d 28 b2 22 f0 	cmpw   $0x7cf,0xf022b228
f010059b:	cf 07 
f010059d:	76 42                	jbe    f01005e1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059f:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f01005a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005ab:	00 
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005b6:	89 04 24             	mov    %eax,(%esp)
f01005b9:	e8 76 56 00 00       	call   f0105c34 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005be:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cf:	83 c0 01             	add    $0x1,%eax
f01005d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005d7:	75 f0                	jne    f01005c9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005d9:	66 83 2d 28 b2 22 f0 	subw   $0x50,0xf022b228
f01005e0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005e1:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 ca                	mov    %ecx,%edx
f01005ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ef:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
f01005f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f9:	89 d8                	mov    %ebx,%eax
f01005fb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ff:	89 f2                	mov    %esi,%edx
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
f010060a:	89 d8                	mov    %ebx,%eax
f010060c:	89 f2                	mov    %esi,%edx
f010060e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010060f:	83 c4 1c             	add    $0x1c,%esp
f0100612:	5b                   	pop    %ebx
f0100613:	5e                   	pop    %esi
f0100614:	5f                   	pop    %edi
f0100615:	5d                   	pop    %ebp
f0100616:	c3                   	ret    

f0100617 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100617:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
f010061e:	74 11                	je     f0100631 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100626:	b8 d0 02 10 f0       	mov    $0xf01002d0,%eax
f010062b:	e8 bc fc ff ff       	call   f01002ec <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	f3 c3                	repz ret 

f0100633 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100639:	b8 30 03 10 f0       	mov    $0xf0100330,%eax
f010063e:	e8 a9 fc ff ff       	call   f01002ec <cons_intr>
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010064b:	e8 c7 ff ff ff       	call   f0100617 <serial_intr>
	kbd_intr();
f0100650:	e8 de ff ff ff       	call   f0100633 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100655:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f010065a:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f0100660:	74 26                	je     f0100688 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100662:	8d 50 01             	lea    0x1(%eax),%edx
f0100665:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f010066b:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100672:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100674:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067a:	75 11                	jne    f010068d <cons_getc+0x48>
			cons.rpos = 0;
f010067c:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
f0100683:	00 00 00 
f0100686:	eb 05                	jmp    f010068d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	57                   	push   %edi
f0100693:	56                   	push   %esi
f0100694:	53                   	push   %ebx
f0100695:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100698:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010069f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a6:	5a a5 
	if (*cp != 0xA55A) {
f01006a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b3:	74 11                	je     f01006c6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b5:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
f01006bc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006c4:	eb 16                	jmp    f01006dc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cd:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
f01006d4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006dc:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f01006e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e7:	89 ca                	mov    %ecx,%edx
f01006e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ea:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	89 da                	mov    %ebx,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	0f b6 f0             	movzbl %al,%esi
f01006f3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fb:	89 ca                	mov    %ecx,%edx
f01006fd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100701:	89 3d 2c b2 22 f0    	mov    %edi,0xf022b22c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100707:	0f b6 d8             	movzbl %al,%ebx
f010070a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010070c:	66 89 35 28 b2 22 f0 	mov    %si,0xf022b228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100713:	e8 1b ff ff ff       	call   f0100633 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100718:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010071f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100724:	89 04 24             	mov    %eax,(%esp)
f0100727:	e8 07 37 00 00       	call   f0103e33 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100731:	b8 00 00 00 00       	mov    $0x0,%eax
f0100736:	89 f2                	mov    %esi,%edx
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fb                	mov    $0xfb,%dl
f010073b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100740:	ee                   	out    %al,(%dx)
f0100741:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100746:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 f9                	mov    $0xf9,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 fb                	mov    $0xfb,%dl
f0100758:	b8 03 00 00 00       	mov    $0x3,%eax
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 fc                	mov    $0xfc,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 f9                	mov    $0xf9,%dl
f0100768:	b8 01 00 00 00       	mov    $0x1,%eax
f010076d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076e:	b2 fd                	mov    $0xfd,%dl
f0100770:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100771:	3c ff                	cmp    $0xff,%al
f0100773:	0f 95 c1             	setne  %cl
f0100776:	88 0d 34 b2 22 f0    	mov    %cl,0xf022b234
f010077c:	89 f2                	mov    %esi,%edx
f010077e:	ec                   	in     (%dx),%al
f010077f:	89 da                	mov    %ebx,%edx
f0100781:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100782:	84 c9                	test   %cl,%cl
f0100784:	75 0c                	jne    f0100792 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100786:	c7 04 24 fc 69 10 f0 	movl   $0xf01069fc,(%esp)
f010078d:	e8 e0 37 00 00       	call   f0103f72 <cprintf>
}
f0100792:	83 c4 1c             	add    $0x1c,%esp
f0100795:	5b                   	pop    %ebx
f0100796:	5e                   	pop    %esi
f0100797:	5f                   	pop    %edi
f0100798:	5d                   	pop    %ebp
f0100799:	c3                   	ret    

f010079a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a3:	e8 91 fc ff ff       	call   f0100439 <cons_putc>
}
f01007a8:	c9                   	leave  
f01007a9:	c3                   	ret    

f01007aa <getchar>:

int
getchar(void)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b0:	e8 90 fe ff ff       	call   f0100645 <cons_getc>
f01007b5:	85 c0                	test   %eax,%eax
f01007b7:	74 f7                	je     f01007b0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b9:	c9                   	leave  
f01007ba:	c3                   	ret    

f01007bb <iscons>:

int
iscons(int fdnum)
{
f01007bb:	55                   	push   %ebp
f01007bc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007be:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c3:	5d                   	pop    %ebp
f01007c4:	c3                   	ret    
f01007c5:	66 90                	xchg   %ax,%ax
f01007c7:	66 90                	xchg   %ax,%ax
f01007c9:	66 90                	xchg   %ax,%ax
f01007cb:	66 90                	xchg   %ax,%ax
f01007cd:	66 90                	xchg   %ax,%ax
f01007cf:	90                   	nop

f01007d0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d6:	c7 44 24 08 40 6c 10 	movl   $0xf0106c40,0x8(%esp)
f01007dd:	f0 
f01007de:	c7 44 24 04 5e 6c 10 	movl   $0xf0106c5e,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 63 6c 10 f0 	movl   $0xf0106c63,(%esp)
f01007ed:	e8 80 37 00 00       	call   f0103f72 <cprintf>
f01007f2:	c7 44 24 08 cc 6c 10 	movl   $0xf0106ccc,0x8(%esp)
f01007f9:	f0 
f01007fa:	c7 44 24 04 6c 6c 10 	movl   $0xf0106c6c,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 63 6c 10 f0 	movl   $0xf0106c63,(%esp)
f0100809:	e8 64 37 00 00       	call   f0103f72 <cprintf>
	return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010081b:	c7 04 24 75 6c 10 f0 	movl   $0xf0106c75,(%esp)
f0100822:	e8 4b 37 00 00       	call   f0103f72 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100827:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010082e:	00 
f010082f:	c7 04 24 f4 6c 10 f0 	movl   $0xf0106cf4,(%esp)
f0100836:	e8 37 37 00 00       	call   f0103f72 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010083b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100842:	00 
f0100843:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010084a:	f0 
f010084b:	c7 04 24 1c 6d 10 f0 	movl   $0xf0106d1c,(%esp)
f0100852:	e8 1b 37 00 00       	call   f0103f72 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100857:	c7 44 24 08 07 69 10 	movl   $0x106907,0x8(%esp)
f010085e:	00 
f010085f:	c7 44 24 04 07 69 10 	movl   $0xf0106907,0x4(%esp)
f0100866:	f0 
f0100867:	c7 04 24 40 6d 10 f0 	movl   $0xf0106d40,(%esp)
f010086e:	e8 ff 36 00 00       	call   f0103f72 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100873:	c7 44 24 08 5f a9 22 	movl   $0x22a95f,0x8(%esp)
f010087a:	00 
f010087b:	c7 44 24 04 5f a9 22 	movl   $0xf022a95f,0x4(%esp)
f0100882:	f0 
f0100883:	c7 04 24 64 6d 10 f0 	movl   $0xf0106d64,(%esp)
f010088a:	e8 e3 36 00 00       	call   f0103f72 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010088f:	c7 44 24 08 08 d0 26 	movl   $0x26d008,0x8(%esp)
f0100896:	00 
f0100897:	c7 44 24 04 08 d0 26 	movl   $0xf026d008,0x4(%esp)
f010089e:	f0 
f010089f:	c7 04 24 88 6d 10 f0 	movl   $0xf0106d88,(%esp)
f01008a6:	e8 c7 36 00 00       	call   f0103f72 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008ab:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f01008b0:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008b5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ba:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008c0:	85 c0                	test   %eax,%eax
f01008c2:	0f 48 c2             	cmovs  %edx,%eax
f01008c5:	c1 f8 0a             	sar    $0xa,%eax
f01008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cc:	c7 04 24 ac 6d 10 f0 	movl   $0xf0106dac,(%esp)
f01008d3:	e8 9a 36 00 00       	call   f0103f72 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008dd:	c9                   	leave  
f01008de:	c3                   	ret    

f01008df <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008df:	55                   	push   %ebp
f01008e0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e7:	5d                   	pop    %ebp
f01008e8:	c3                   	ret    

f01008e9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e9:	55                   	push   %ebp
f01008ea:	89 e5                	mov    %esp,%ebp
f01008ec:	57                   	push   %edi
f01008ed:	56                   	push   %esi
f01008ee:	53                   	push   %ebx
f01008ef:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008f2:	c7 04 24 d8 6d 10 f0 	movl   $0xf0106dd8,(%esp)
f01008f9:	e8 74 36 00 00       	call   f0103f72 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008fe:	c7 04 24 fc 6d 10 f0 	movl   $0xf0106dfc,(%esp)
f0100905:	e8 68 36 00 00       	call   f0103f72 <cprintf>

	if (tf != NULL)
f010090a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010090e:	74 0b                	je     f010091b <monitor+0x32>
		print_trapframe(tf);
f0100910:	8b 45 08             	mov    0x8(%ebp),%eax
f0100913:	89 04 24             	mov    %eax,(%esp)
f0100916:	e8 80 3b 00 00       	call   f010449b <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010091b:	c7 04 24 8e 6c 10 f0 	movl   $0xf0106c8e,(%esp)
f0100922:	e8 69 50 00 00       	call   f0105990 <readline>
f0100927:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100929:	85 c0                	test   %eax,%eax
f010092b:	74 ee                	je     f010091b <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010092d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100934:	be 00 00 00 00       	mov    $0x0,%esi
f0100939:	eb 0a                	jmp    f0100945 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010093b:	c6 03 00             	movb   $0x0,(%ebx)
f010093e:	89 f7                	mov    %esi,%edi
f0100940:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100943:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100945:	0f b6 03             	movzbl (%ebx),%eax
f0100948:	84 c0                	test   %al,%al
f010094a:	74 63                	je     f01009af <monitor+0xc6>
f010094c:	0f be c0             	movsbl %al,%eax
f010094f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100953:	c7 04 24 92 6c 10 f0 	movl   $0xf0106c92,(%esp)
f010095a:	e8 4b 52 00 00       	call   f0105baa <strchr>
f010095f:	85 c0                	test   %eax,%eax
f0100961:	75 d8                	jne    f010093b <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100963:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100966:	74 47                	je     f01009af <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100968:	83 fe 0f             	cmp    $0xf,%esi
f010096b:	75 16                	jne    f0100983 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100974:	00 
f0100975:	c7 04 24 97 6c 10 f0 	movl   $0xf0106c97,(%esp)
f010097c:	e8 f1 35 00 00       	call   f0103f72 <cprintf>
f0100981:	eb 98                	jmp    f010091b <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100983:	8d 7e 01             	lea    0x1(%esi),%edi
f0100986:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010098a:	eb 03                	jmp    f010098f <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010098c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010098f:	0f b6 03             	movzbl (%ebx),%eax
f0100992:	84 c0                	test   %al,%al
f0100994:	74 ad                	je     f0100943 <monitor+0x5a>
f0100996:	0f be c0             	movsbl %al,%eax
f0100999:	89 44 24 04          	mov    %eax,0x4(%esp)
f010099d:	c7 04 24 92 6c 10 f0 	movl   $0xf0106c92,(%esp)
f01009a4:	e8 01 52 00 00       	call   f0105baa <strchr>
f01009a9:	85 c0                	test   %eax,%eax
f01009ab:	74 df                	je     f010098c <monitor+0xa3>
f01009ad:	eb 94                	jmp    f0100943 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f01009af:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009b6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009b7:	85 f6                	test   %esi,%esi
f01009b9:	0f 84 5c ff ff ff    	je     f010091b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009bf:	c7 44 24 04 5e 6c 10 	movl   $0xf0106c5e,0x4(%esp)
f01009c6:	f0 
f01009c7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ca:	89 04 24             	mov    %eax,(%esp)
f01009cd:	e8 7a 51 00 00       	call   f0105b4c <strcmp>
f01009d2:	85 c0                	test   %eax,%eax
f01009d4:	74 1b                	je     f01009f1 <monitor+0x108>
f01009d6:	c7 44 24 04 6c 6c 10 	movl   $0xf0106c6c,0x4(%esp)
f01009dd:	f0 
f01009de:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009e1:	89 04 24             	mov    %eax,(%esp)
f01009e4:	e8 63 51 00 00       	call   f0105b4c <strcmp>
f01009e9:	85 c0                	test   %eax,%eax
f01009eb:	75 2f                	jne    f0100a1c <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009ed:	b0 01                	mov    $0x1,%al
f01009ef:	eb 05                	jmp    f01009f6 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f1:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009f6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009f9:	01 d0                	add    %edx,%eax
f01009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01009fe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a02:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a05:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a09:	89 34 24             	mov    %esi,(%esp)
f0100a0c:	ff 14 85 2c 6e 10 f0 	call   *-0xfef91d4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a13:	85 c0                	test   %eax,%eax
f0100a15:	78 1d                	js     f0100a34 <monitor+0x14b>
f0100a17:	e9 ff fe ff ff       	jmp    f010091b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a1c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a23:	c7 04 24 b4 6c 10 f0 	movl   $0xf0106cb4,(%esp)
f0100a2a:	e8 43 35 00 00       	call   f0103f72 <cprintf>
f0100a2f:	e9 e7 fe ff ff       	jmp    f010091b <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a34:	83 c4 5c             	add    $0x5c,%esp
f0100a37:	5b                   	pop    %ebx
f0100a38:	5e                   	pop    %esi
f0100a39:	5f                   	pop    %edi
f0100a3a:	5d                   	pop    %ebp
f0100a3b:	c3                   	ret    
f0100a3c:	66 90                	xchg   %ax,%ax
f0100a3e:	66 90                	xchg   %ax,%ax

f0100a40 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a40:	55                   	push   %ebp
f0100a41:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a43:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100a4a:	75 11                	jne    f0100a5d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a4c:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100a51:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a57:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a5d:	85 c0                	test   %eax,%eax
f0100a5f:	75 07                	jne    f0100a68 <boot_alloc+0x28>
		return nextfree;
f0100a61:	a1 38 b2 22 f0       	mov    0xf022b238,%eax
f0100a66:	eb 19                	jmp    f0100a81 <boot_alloc+0x41>
	result = nextfree;
f0100a68:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a6e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a7a:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
	
	// return the head address of the alloc pages;
	return result;
f0100a7f:	89 d0                	mov    %edx,%eax
}
f0100a81:	5d                   	pop    %ebp
f0100a82:	c3                   	ret    

f0100a83 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a83:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100a89:	c1 f8 03             	sar    $0x3,%eax
f0100a8c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a8f:	89 c2                	mov    %eax,%edx
f0100a91:	c1 ea 0c             	shr    $0xc,%edx
f0100a94:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100a9a:	72 26                	jb     f0100ac2 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100a9c:	55                   	push   %ebp
f0100a9d:	89 e5                	mov    %esp,%ebp
f0100a9f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100aa6:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0100aad:	f0 
f0100aae:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ab5:	00 
f0100ab6:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0100abd:	e8 7e f5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ac2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ac7:	c3                   	ret    

f0100ac8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ac8:	89 d1                	mov    %edx,%ecx
f0100aca:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100acd:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad0:	a8 01                	test   $0x1,%al
f0100ad2:	74 5d                	je     f0100b31 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ad9:	89 c1                	mov    %eax,%ecx
f0100adb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ade:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0100ae4:	72 26                	jb     f0100b0c <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ae6:	55                   	push   %ebp
f0100ae7:	89 e5                	mov    %esp,%ebp
f0100ae9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100af0:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100b07:	e8 34 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b0c:	c1 ea 0c             	shr    $0xc,%edx
f0100b0f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b15:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b1c:	89 c2                	mov    %eax,%edx
f0100b1e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b26:	85 d2                	test   %edx,%edx
f0100b28:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b2d:	0f 44 c2             	cmove  %edx,%eax
f0100b30:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b36:	c3                   	ret    

f0100b37 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b37:	55                   	push   %ebp
f0100b38:	89 e5                	mov    %esp,%ebp
f0100b3a:	57                   	push   %edi
f0100b3b:	56                   	push   %esi
f0100b3c:	53                   	push   %ebx
f0100b3d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b40:	84 c0                	test   %al,%al
f0100b42:	0f 85 31 03 00 00    	jne    f0100e79 <check_page_free_list+0x342>
f0100b48:	e9 3e 03 00 00       	jmp    f0100e8b <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b4d:	c7 44 24 08 3c 6e 10 	movl   $0xf0106e3c,0x8(%esp)
f0100b54:	f0 
f0100b55:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100b5c:	00 
f0100b5d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100b64:	e8 d7 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b69:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b6c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b6f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b75:	89 c2                	mov    %eax,%edx
f0100b77:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b7d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b83:	0f 95 c2             	setne  %dl
f0100b86:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b89:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b8d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b8f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b93:	8b 00                	mov    (%eax),%eax
f0100b95:	85 c0                	test   %eax,%eax
f0100b97:	75 dc                	jne    f0100b75 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ba8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100baa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bad:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb7:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100bbd:	eb 63                	jmp    f0100c22 <check_page_free_list+0xeb>
f0100bbf:	89 d8                	mov    %ebx,%eax
f0100bc1:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100bc7:	c1 f8 03             	sar    $0x3,%eax
f0100bca:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bcd:	89 c2                	mov    %eax,%edx
f0100bcf:	c1 ea 16             	shr    $0x16,%edx
f0100bd2:	39 f2                	cmp    %esi,%edx
f0100bd4:	73 4a                	jae    f0100c20 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd6:	89 c2                	mov    %eax,%edx
f0100bd8:	c1 ea 0c             	shr    $0xc,%edx
f0100bdb:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100be1:	72 20                	jb     f0100c03 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100be7:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0100bee:	f0 
f0100bef:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bf6:	00 
f0100bf7:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0100bfe:	e8 3d f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c03:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c0a:	00 
f0100c0b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c12:	00 
	return (void *)(pa + KERNBASE);
f0100c13:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c18:	89 04 24             	mov    %eax,(%esp)
f0100c1b:	e8 c7 4f 00 00       	call   f0105be7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c20:	8b 1b                	mov    (%ebx),%ebx
f0100c22:	85 db                	test   %ebx,%ebx
f0100c24:	75 99                	jne    f0100bbf <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2b:	e8 10 fe ff ff       	call   f0100a40 <boot_alloc>
f0100c30:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c33:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c39:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
		assert(pp < pages + npages);
f0100c3f:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0100c44:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c47:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c4a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c4d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c50:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c55:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c58:	e9 c4 01 00 00       	jmp    f0100e21 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c5d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c60:	73 24                	jae    f0100c86 <check_page_free_list+0x14f>
f0100c62:	c7 44 24 0c 73 77 10 	movl   $0xf0107773,0xc(%esp)
f0100c69:	f0 
f0100c6a:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100c71:	f0 
f0100c72:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0100c79:	00 
f0100c7a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100c81:	e8 ba f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c86:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c89:	72 24                	jb     f0100caf <check_page_free_list+0x178>
f0100c8b:	c7 44 24 0c 94 77 10 	movl   $0xf0107794,0xc(%esp)
f0100c92:	f0 
f0100c93:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100c9a:	f0 
f0100c9b:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100ca2:	00 
f0100ca3:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100caa:	e8 91 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100caf:	89 d0                	mov    %edx,%eax
f0100cb1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100cb4:	a8 07                	test   $0x7,%al
f0100cb6:	74 24                	je     f0100cdc <check_page_free_list+0x1a5>
f0100cb8:	c7 44 24 0c 60 6e 10 	movl   $0xf0106e60,0xc(%esp)
f0100cbf:	f0 
f0100cc0:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100cc7:	f0 
f0100cc8:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0100ccf:	00 
f0100cd0:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100cd7:	e8 64 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cdc:	c1 f8 03             	sar    $0x3,%eax
f0100cdf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ce2:	85 c0                	test   %eax,%eax
f0100ce4:	75 24                	jne    f0100d0a <check_page_free_list+0x1d3>
f0100ce6:	c7 44 24 0c a8 77 10 	movl   $0xf01077a8,0xc(%esp)
f0100ced:	f0 
f0100cee:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100cf5:	f0 
f0100cf6:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100cfd:	00 
f0100cfe:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100d05:	e8 36 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d0a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d0f:	75 24                	jne    f0100d35 <check_page_free_list+0x1fe>
f0100d11:	c7 44 24 0c b9 77 10 	movl   $0xf01077b9,0xc(%esp)
f0100d18:	f0 
f0100d19:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100d20:	f0 
f0100d21:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100d28:	00 
f0100d29:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100d30:	e8 0b f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d35:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d3a:	75 24                	jne    f0100d60 <check_page_free_list+0x229>
f0100d3c:	c7 44 24 0c 94 6e 10 	movl   $0xf0106e94,0xc(%esp)
f0100d43:	f0 
f0100d44:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100d4b:	f0 
f0100d4c:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d53:	00 
f0100d54:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100d5b:	e8 e0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d60:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d65:	75 24                	jne    f0100d8b <check_page_free_list+0x254>
f0100d67:	c7 44 24 0c d2 77 10 	movl   $0xf01077d2,0xc(%esp)
f0100d6e:	f0 
f0100d6f:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100d86:	e8 b5 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d8b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d90:	0f 86 1c 01 00 00    	jbe    f0100eb2 <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d96:	89 c1                	mov    %eax,%ecx
f0100d98:	c1 e9 0c             	shr    $0xc,%ecx
f0100d9b:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100d9e:	77 20                	ja     f0100dc0 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100da0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100da4:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0100dab:	f0 
f0100dac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100db3:	00 
f0100db4:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0100dbb:	e8 80 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dc0:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100dc6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100dc9:	0f 86 d3 00 00 00    	jbe    f0100ea2 <check_page_free_list+0x36b>
f0100dcf:	c7 44 24 0c b8 6e 10 	movl   $0xf0106eb8,0xc(%esp)
f0100dd6:	f0 
f0100dd7:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100dde:	f0 
f0100ddf:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0100de6:	00 
f0100de7:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100dee:	e8 4d f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100df3:	c7 44 24 0c ec 77 10 	movl   $0xf01077ec,0xc(%esp)
f0100dfa:	f0 
f0100dfb:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100e02:	f0 
f0100e03:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100e0a:	00 
f0100e0b:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100e12:	e8 29 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e17:	83 c3 01             	add    $0x1,%ebx
f0100e1a:	eb 03                	jmp    f0100e1f <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100e1c:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e1f:	8b 12                	mov    (%edx),%edx
f0100e21:	85 d2                	test   %edx,%edx
f0100e23:	0f 85 34 fe ff ff    	jne    f0100c5d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e29:	85 db                	test   %ebx,%ebx
f0100e2b:	7f 24                	jg     f0100e51 <check_page_free_list+0x31a>
f0100e2d:	c7 44 24 0c 09 78 10 	movl   $0xf0107809,0xc(%esp)
f0100e34:	f0 
f0100e35:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100e3c:	f0 
f0100e3d:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0100e44:	00 
f0100e45:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100e4c:	e8 ef f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e51:	85 ff                	test   %edi,%edi
f0100e53:	7f 70                	jg     f0100ec5 <check_page_free_list+0x38e>
f0100e55:	c7 44 24 0c 1b 78 10 	movl   $0xf010781b,0xc(%esp)
f0100e5c:	f0 
f0100e5d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0100e64:	f0 
f0100e65:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100e6c:	00 
f0100e6d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0100e74:	e8 c7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e79:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0100e7e:	85 c0                	test   %eax,%eax
f0100e80:	0f 85 e3 fc ff ff    	jne    f0100b69 <check_page_free_list+0x32>
f0100e86:	e9 c2 fc ff ff       	jmp    f0100b4d <check_page_free_list+0x16>
f0100e8b:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f0100e92:	0f 84 b5 fc ff ff    	je     f0100b4d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e98:	be 00 04 00 00       	mov    $0x400,%esi
f0100e9d:	e9 15 fd ff ff       	jmp    f0100bb7 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ea2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea7:	0f 85 6f ff ff ff    	jne    f0100e1c <check_page_free_list+0x2e5>
f0100ead:	e9 41 ff ff ff       	jmp    f0100df3 <check_page_free_list+0x2bc>
f0100eb2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eb7:	0f 85 5a ff ff ff    	jne    f0100e17 <check_page_free_list+0x2e0>
f0100ebd:	8d 76 00             	lea    0x0(%esi),%esi
f0100ec0:	e9 2e ff ff ff       	jmp    f0100df3 <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ec5:	83 c4 4c             	add    $0x4c,%esp
f0100ec8:	5b                   	pop    %ebx
f0100ec9:	5e                   	pop    %esi
f0100eca:	5f                   	pop    %edi
f0100ecb:	5d                   	pop    %ebp
f0100ecc:	c3                   	ret    

f0100ecd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ecd:	55                   	push   %ebp
f0100ece:	89 e5                	mov    %esp,%ebp
f0100ed0:	56                   	push   %esi
f0100ed1:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ed2:	be 00 00 00 00       	mov    $0x0,%esi
f0100ed7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100edc:	e9 e1 00 00 00       	jmp    f0100fc2 <page_init+0xf5>
		if(i == 0)
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	75 16                	jne    f0100efb <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100ee5:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100eea:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100ef0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ef6:	e9 c1 00 00 00       	jmp    f0100fbc <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100efb:	83 fb 07             	cmp    $0x7,%ebx
f0100efe:	75 17                	jne    f0100f17 <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100f00:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100f05:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100f0b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f12:	e9 a5 00 00 00       	jmp    f0100fbc <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100f17:	3b 1d 44 b2 22 f0    	cmp    0xf022b244,%ebx
f0100f1d:	73 25                	jae    f0100f44 <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100f1f:	89 f0                	mov    %esi,%eax
f0100f21:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f27:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100f2d:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0100f33:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f35:	89 f0                	mov    %esi,%eax
f0100f37:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f3d:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
f0100f42:	eb 78                	jmp    f0100fbc <page_init+0xef>
f0100f44:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100f4a:	83 f8 5f             	cmp    $0x5f,%eax
f0100f4d:	77 16                	ja     f0100f65 <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100f4f:	89 f0                	mov    %esi,%eax
f0100f51:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f57:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f63:	eb 57                	jmp    f0100fbc <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f65:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f6b:	76 2c                	jbe    f0100f99 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100f6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f72:	e8 c9 fa ff ff       	call   f0100a40 <boot_alloc>
f0100f77:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f7c:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f7f:	39 c3                	cmp    %eax,%ebx
f0100f81:	73 16                	jae    f0100f99 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100f83:	89 f0                	mov    %esi,%eax
f0100f85:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f8b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f97:	eb 23                	jmp    f0100fbc <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f99:	89 f0                	mov    %esi,%eax
f0100f9b:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fa1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100fa7:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0100fad:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100faf:	89 f0                	mov    %esi,%eax
f0100fb1:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fb7:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100fbc:	83 c3 01             	add    $0x1,%ebx
f0100fbf:	83 c6 08             	add    $0x8,%esi
f0100fc2:	3b 1d 88 be 22 f0    	cmp    0xf022be88,%ebx
f0100fc8:	0f 82 13 ff ff ff    	jb     f0100ee1 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100fce:	5b                   	pop    %ebx
f0100fcf:	5e                   	pop    %esi
f0100fd0:	5d                   	pop    %ebp
f0100fd1:	c3                   	ret    

f0100fd2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fd2:	55                   	push   %ebp
f0100fd3:	89 e5                	mov    %esp,%ebp
f0100fd5:	53                   	push   %ebx
f0100fd6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100fd9:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100fdf:	85 db                	test   %ebx,%ebx
f0100fe1:	74 6f                	je     f0101052 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100fe3:	8b 03                	mov    (%ebx),%eax
f0100fe5:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	page->pp_link = 0;
f0100fea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f0100ff0:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f0100ff2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ff6:	74 5f                	je     f0101057 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ff8:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100ffe:	c1 f8 03             	sar    $0x3,%eax
f0101001:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101004:	89 c2                	mov    %eax,%edx
f0101006:	c1 ea 0c             	shr    $0xc,%edx
f0101009:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010100f:	72 20                	jb     f0101031 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101011:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101015:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f010101c:	f0 
f010101d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101024:	00 
f0101025:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f010102c:	e8 0f f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0101031:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101038:	00 
f0101039:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101040:	00 
	return (void *)(pa + KERNBASE);
f0101041:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101046:	89 04 24             	mov    %eax,(%esp)
f0101049:	e8 99 4b 00 00       	call   f0105be7 <memset>
	return page;
f010104e:	89 d8                	mov    %ebx,%eax
f0101050:	eb 05                	jmp    f0101057 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0101052:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
	return 0;
}
f0101057:	83 c4 14             	add    $0x14,%esp
f010105a:	5b                   	pop    %ebx
f010105b:	5d                   	pop    %ebp
f010105c:	c3                   	ret    

f010105d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010105d:	55                   	push   %ebp
f010105e:	89 e5                	mov    %esp,%ebp
f0101060:	83 ec 18             	sub    $0x18,%esp
f0101063:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0101066:	83 38 00             	cmpl   $0x0,(%eax)
f0101069:	75 07                	jne    f0101072 <page_free+0x15>
f010106b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101070:	74 1c                	je     f010108e <page_free+0x31>
		panic("page_free is not right");
f0101072:	c7 44 24 08 2c 78 10 	movl   $0xf010782c,0x8(%esp)
f0101079:	f0 
f010107a:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0101081:	00 
f0101082:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101089:	e8 b2 ef ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010108e:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0101094:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101096:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	return; 
}
f010109b:	c9                   	leave  
f010109c:	c3                   	ret    

f010109d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010109d:	55                   	push   %ebp
f010109e:	89 e5                	mov    %esp,%ebp
f01010a0:	83 ec 18             	sub    $0x18,%esp
f01010a3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010a6:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01010aa:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01010ad:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010b1:	66 85 d2             	test   %dx,%dx
f01010b4:	75 08                	jne    f01010be <page_decref+0x21>
		page_free(pp);
f01010b6:	89 04 24             	mov    %eax,(%esp)
f01010b9:	e8 9f ff ff ff       	call   f010105d <page_free>
}
f01010be:	c9                   	leave  
f01010bf:	c3                   	ret    

f01010c0 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010c0:	55                   	push   %ebp
f01010c1:	89 e5                	mov    %esp,%ebp
f01010c3:	56                   	push   %esi
f01010c4:	53                   	push   %ebx
f01010c5:	83 ec 10             	sub    $0x10,%esp
f01010c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f01010cb:	89 f3                	mov    %esi,%ebx
f01010cd:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f01010d0:	c1 e3 02             	shl    $0x2,%ebx
f01010d3:	03 5d 08             	add    0x8(%ebp),%ebx
f01010d6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010d9:	75 2c                	jne    f0101107 <pgdir_walk+0x47>
f01010db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010df:	74 6c                	je     f010114d <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f01010e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010e8:	e8 e5 fe ff ff       	call   f0100fd2 <page_alloc>
		if(page == NULL)
f01010ed:	85 c0                	test   %eax,%eax
f01010ef:	74 63                	je     f0101154 <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f01010f1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010f6:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01010fc:	c1 f8 03             	sar    $0x3,%eax
f01010ff:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0101102:	83 c8 07             	or     $0x7,%eax
f0101105:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f0101107:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f0101109:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f010110e:	c1 ee 0c             	shr    $0xc,%esi
f0101111:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101117:	89 c2                	mov    %eax,%edx
f0101119:	c1 ea 0c             	shr    $0xc,%edx
f010111c:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101122:	72 20                	jb     f0101144 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101124:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101128:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f010112f:	f0 
f0101130:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0101137:	00 
f0101138:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010113f:	e8 fc ee ff ff       	call   f0100040 <_panic>
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
f0101144:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010114b:	eb 0c                	jmp    f0101159 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f010114d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101152:	eb 05                	jmp    f0101159 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0101154:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f0101159:	83 c4 10             	add    $0x10,%esp
f010115c:	5b                   	pop    %ebx
f010115d:	5e                   	pop    %esi
f010115e:	5d                   	pop    %ebp
f010115f:	c3                   	ret    

f0101160 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101160:	55                   	push   %ebp
f0101161:	89 e5                	mov    %esp,%ebp
f0101163:	57                   	push   %edi
f0101164:	56                   	push   %esi
f0101165:	53                   	push   %ebx
f0101166:	83 ec 2c             	sub    $0x2c,%esp
f0101169:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010116c:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size)
f010116e:	89 d3                	mov    %edx,%ebx
f0101170:	8b 45 08             	mov    0x8(%ebp),%eax
f0101173:	29 d0                	sub    %edx,%eax
f0101175:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0101178:	8b 45 0c             	mov    0xc(%ebp),%eax
f010117b:	83 c8 01             	or     $0x1,%eax
f010117e:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101181:	eb 2c                	jmp    f01011af <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101183:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010118a:	00 
f010118b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010118f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101192:	89 04 24             	mov    %eax,(%esp)
f0101195:	e8 26 ff ff ff       	call   f01010c0 <pgdir_walk>
		if(pte == NULL)
f010119a:	85 c0                	test   %eax,%eax
f010119c:	74 1b                	je     f01011b9 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f010119e:	0b 7d dc             	or     -0x24(%ebp),%edi
f01011a1:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f01011a3:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f01011a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011b2:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f01011b5:	85 f6                	test   %esi,%esi
f01011b7:	75 ca                	jne    f0101183 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f01011b9:	83 c4 2c             	add    $0x2c,%esp
f01011bc:	5b                   	pop    %ebx
f01011bd:	5e                   	pop    %esi
f01011be:	5f                   	pop    %edi
f01011bf:	5d                   	pop    %ebp
f01011c0:	c3                   	ret    

f01011c1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011c1:	55                   	push   %ebp
f01011c2:	89 e5                	mov    %esp,%ebp
f01011c4:	53                   	push   %ebx
f01011c5:	83 ec 14             	sub    $0x14,%esp
f01011c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f01011cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011d2:	00 
f01011d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011da:	8b 45 08             	mov    0x8(%ebp),%eax
f01011dd:	89 04 24             	mov    %eax,(%esp)
f01011e0:	e8 db fe ff ff       	call   f01010c0 <pgdir_walk>
	if(pte == NULL)
f01011e5:	85 c0                	test   %eax,%eax
f01011e7:	74 42                	je     f010122b <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f01011e9:	8b 10                	mov    (%eax),%edx
f01011eb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f01011f1:	85 db                	test   %ebx,%ebx
f01011f3:	74 02                	je     f01011f7 <page_lookup+0x36>
		*pte_store = pte ;
f01011f5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f7:	89 d0                	mov    %edx,%eax
f01011f9:	c1 e8 0c             	shr    $0xc,%eax
f01011fc:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0101202:	72 1c                	jb     f0101220 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101204:	c7 44 24 08 00 6f 10 	movl   $0xf0106f00,0x8(%esp)
f010120b:	f0 
f010120c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101213:	00 
f0101214:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f010121b:	e8 20 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101220:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101226:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f0101229:	eb 05                	jmp    f0101230 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f010122b:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f0101230:	83 c4 14             	add    $0x14,%esp
f0101233:	5b                   	pop    %ebx
f0101234:	5d                   	pop    %ebp
f0101235:	c3                   	ret    

f0101236 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101236:	55                   	push   %ebp
f0101237:	89 e5                	mov    %esp,%ebp
f0101239:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010123c:	e8 f8 4f 00 00       	call   f0106239 <cpunum>
f0101241:	6b c0 74             	imul   $0x74,%eax,%eax
f0101244:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010124b:	74 16                	je     f0101263 <tlb_invalidate+0x2d>
f010124d:	e8 e7 4f 00 00       	call   f0106239 <cpunum>
f0101252:	6b c0 74             	imul   $0x74,%eax,%eax
f0101255:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010125b:	8b 55 08             	mov    0x8(%ebp),%edx
f010125e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101261:	75 06                	jne    f0101269 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101263:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101266:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101269:	c9                   	leave  
f010126a:	c3                   	ret    

f010126b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010126b:	55                   	push   %ebp
f010126c:	89 e5                	mov    %esp,%ebp
f010126e:	56                   	push   %esi
f010126f:	53                   	push   %ebx
f0101270:	83 ec 20             	sub    $0x20,%esp
f0101273:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101276:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101279:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010127c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101280:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101284:	89 1c 24             	mov    %ebx,(%esp)
f0101287:	e8 35 ff ff ff       	call   f01011c1 <page_lookup>
	if(page == 0)
f010128c:	85 c0                	test   %eax,%eax
f010128e:	74 2d                	je     f01012bd <page_remove+0x52>
		return;
	*pte = 0;
f0101290:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101293:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101299:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010129d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01012a0:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f01012a4:	66 85 d2             	test   %dx,%dx
f01012a7:	75 08                	jne    f01012b1 <page_remove+0x46>
		page_free(page);
f01012a9:	89 04 24             	mov    %eax,(%esp)
f01012ac:	e8 ac fd ff ff       	call   f010105d <page_free>
	tlb_invalidate(pgdir, va);
f01012b1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012b5:	89 1c 24             	mov    %ebx,(%esp)
f01012b8:	e8 79 ff ff ff       	call   f0101236 <tlb_invalidate>
}
f01012bd:	83 c4 20             	add    $0x20,%esp
f01012c0:	5b                   	pop    %ebx
f01012c1:	5e                   	pop    %esi
f01012c2:	5d                   	pop    %ebp
f01012c3:	c3                   	ret    

f01012c4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012c4:	55                   	push   %ebp
f01012c5:	89 e5                	mov    %esp,%ebp
f01012c7:	57                   	push   %edi
f01012c8:	56                   	push   %esi
f01012c9:	53                   	push   %ebx
f01012ca:	83 ec 1c             	sub    $0x1c,%esp
f01012cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012d0:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01012d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012da:	00 
f01012db:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012df:	8b 45 08             	mov    0x8(%ebp),%eax
f01012e2:	89 04 24             	mov    %eax,(%esp)
f01012e5:	e8 d6 fd ff ff       	call   f01010c0 <pgdir_walk>
f01012ea:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f01012ec:	85 c0                	test   %eax,%eax
f01012ee:	74 5a                	je     f010134a <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f01012f0:	8b 00                	mov    (%eax),%eax
f01012f2:	89 c1                	mov    %eax,%ecx
f01012f4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012fa:	89 da                	mov    %ebx,%edx
f01012fc:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101302:	c1 fa 03             	sar    $0x3,%edx
f0101305:	c1 e2 0c             	shl    $0xc,%edx
f0101308:	39 d1                	cmp    %edx,%ecx
f010130a:	75 07                	jne    f0101313 <page_insert+0x4f>
		pp->pp_ref--;
f010130c:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101311:	eb 13                	jmp    f0101326 <page_insert+0x62>
	
	else if(*pte != 0)
f0101313:	85 c0                	test   %eax,%eax
f0101315:	74 0f                	je     f0101326 <page_insert+0x62>
		page_remove(pgdir, va);
f0101317:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010131b:	8b 45 08             	mov    0x8(%ebp),%eax
f010131e:	89 04 24             	mov    %eax,(%esp)
f0101321:	e8 45 ff ff ff       	call   f010126b <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f0101326:	8b 55 14             	mov    0x14(%ebp),%edx
f0101329:	83 ca 01             	or     $0x1,%edx
f010132c:	89 d8                	mov    %ebx,%eax
f010132e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101334:	c1 f8 03             	sar    $0x3,%eax
f0101337:	c1 e0 0c             	shl    $0xc,%eax
f010133a:	09 d0                	or     %edx,%eax
f010133c:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010133e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101343:	b8 00 00 00 00       	mov    $0x0,%eax
f0101348:	eb 05                	jmp    f010134f <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f010134a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010134f:	83 c4 1c             	add    $0x1c,%esp
f0101352:	5b                   	pop    %ebx
f0101353:	5e                   	pop    %esi
f0101354:	5f                   	pop    %edi
f0101355:	5d                   	pop    %ebp
f0101356:	c3                   	ret    

f0101357 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101357:	55                   	push   %ebp
f0101358:	89 e5                	mov    %esp,%ebp
f010135a:	53                   	push   %ebx
f010135b:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010135e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101361:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101367:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010136d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101370:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if(size + base >= MMIOLIM)
f0101376:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010137c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010137f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101384:	76 1c                	jbe    f01013a2 <mmio_map_region+0x4b>
		panic("mmio_map_region not implemented");
f0101386:	c7 44 24 08 20 6f 10 	movl   $0xf0106f20,0x8(%esp)
f010138d:	f0 
f010138e:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0101395:	00 
f0101396:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010139d:	e8 9e ec ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01013a2:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01013a9:	00 
f01013aa:	89 0c 24             	mov    %ecx,(%esp)
f01013ad:	89 d9                	mov    %ebx,%ecx
f01013af:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01013b4:	e8 a7 fd ff ff       	call   f0101160 <boot_map_region>
	uintptr_t ret = base;
f01013b9:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base = base +size;
f01013be:	01 c3                	add    %eax,%ebx
f01013c0:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void*) ret;
}
f01013c6:	83 c4 14             	add    $0x14,%esp
f01013c9:	5b                   	pop    %ebx
f01013ca:	5d                   	pop    %ebp
f01013cb:	c3                   	ret    

f01013cc <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013cc:	55                   	push   %ebp
f01013cd:	89 e5                	mov    %esp,%ebp
f01013cf:	57                   	push   %edi
f01013d0:	56                   	push   %esi
f01013d1:	53                   	push   %ebx
f01013d2:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013d5:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01013dc:	e8 28 2a 00 00       	call   f0103e09 <mc146818_read>
f01013e1:	89 c3                	mov    %eax,%ebx
f01013e3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013ea:	e8 1a 2a 00 00       	call   f0103e09 <mc146818_read>
f01013ef:	c1 e0 08             	shl    $0x8,%eax
f01013f2:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013f4:	89 d8                	mov    %ebx,%eax
f01013f6:	c1 e0 0a             	shl    $0xa,%eax
f01013f9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013ff:	85 c0                	test   %eax,%eax
f0101401:	0f 48 c2             	cmovs  %edx,%eax
f0101404:	c1 f8 0c             	sar    $0xc,%eax
f0101407:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010140c:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101413:	e8 f1 29 00 00       	call   f0103e09 <mc146818_read>
f0101418:	89 c3                	mov    %eax,%ebx
f010141a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101421:	e8 e3 29 00 00       	call   f0103e09 <mc146818_read>
f0101426:	c1 e0 08             	shl    $0x8,%eax
f0101429:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010142b:	89 d8                	mov    %ebx,%eax
f010142d:	c1 e0 0a             	shl    $0xa,%eax
f0101430:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101436:	85 c0                	test   %eax,%eax
f0101438:	0f 48 c2             	cmovs  %edx,%eax
f010143b:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010143e:	85 c0                	test   %eax,%eax
f0101440:	74 0e                	je     f0101450 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101442:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101448:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
f010144e:	eb 0c                	jmp    f010145c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101450:	8b 15 44 b2 22 f0    	mov    0xf022b244,%edx
f0101456:	89 15 88 be 22 f0    	mov    %edx,0xf022be88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010145c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010145f:	c1 e8 0a             	shr    $0xa,%eax
f0101462:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101466:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f010146b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010146e:	c1 e8 0a             	shr    $0xa,%eax
f0101471:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101475:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010147a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010147d:	c1 e8 0a             	shr    $0xa,%eax
f0101480:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101484:	c7 04 24 40 6f 10 f0 	movl   $0xf0106f40,(%esp)
f010148b:	e8 e2 2a 00 00       	call   f0103f72 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101490:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101495:	e8 a6 f5 ff ff       	call   f0100a40 <boot_alloc>
f010149a:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f010149f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014a6:	00 
f01014a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ae:	00 
f01014af:	89 04 24             	mov    %eax,(%esp)
f01014b2:	e8 30 47 00 00       	call   f0105be7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014b7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014bc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014c1:	77 20                	ja     f01014e3 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014c7:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f01014ce:	f0 
f01014cf:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014d6:	00 
f01014d7:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01014de:	e8 5d eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01014e3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014e9:	83 ca 05             	or     $0x5,%edx
f01014ec:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f01014f2:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01014f7:	c1 e0 03             	shl    $0x3,%eax
f01014fa:	e8 41 f5 ff ff       	call   f0100a40 <boot_alloc>
f01014ff:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101504:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f010150a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101511:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101515:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010151c:	00 
f010151d:	89 04 24             	mov    %eax,(%esp)
f0101520:	e8 c2 46 00 00       	call   f0105be7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101525:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010152a:	e8 11 f5 ff ff       	call   f0100a40 <boot_alloc>
f010152f:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101534:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010153b:	00 
f010153c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101543:	00 
f0101544:	89 04 24             	mov    %eax,(%esp)
f0101547:	e8 9b 46 00 00       	call   f0105be7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010154c:	e8 7c f9 ff ff       	call   f0100ecd <page_init>

	check_page_free_list(1);
f0101551:	b8 01 00 00 00       	mov    $0x1,%eax
f0101556:	e8 dc f5 ff ff       	call   f0100b37 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010155b:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101562:	75 1c                	jne    f0101580 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f0101564:	c7 44 24 08 43 78 10 	movl   $0xf0107843,0x8(%esp)
f010156b:	f0 
f010156c:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101573:	00 
f0101574:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010157b:	e8 c0 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101580:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101585:	bb 00 00 00 00       	mov    $0x0,%ebx
f010158a:	eb 05                	jmp    f0101591 <mem_init+0x1c5>
		++nfree;
f010158c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010158f:	8b 00                	mov    (%eax),%eax
f0101591:	85 c0                	test   %eax,%eax
f0101593:	75 f7                	jne    f010158c <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101595:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010159c:	e8 31 fa ff ff       	call   f0100fd2 <page_alloc>
f01015a1:	89 c7                	mov    %eax,%edi
f01015a3:	85 c0                	test   %eax,%eax
f01015a5:	75 24                	jne    f01015cb <mem_init+0x1ff>
f01015a7:	c7 44 24 0c 5e 78 10 	movl   $0xf010785e,0xc(%esp)
f01015ae:	f0 
f01015af:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01015be:	00 
f01015bf:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01015c6:	e8 75 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d2:	e8 fb f9 ff ff       	call   f0100fd2 <page_alloc>
f01015d7:	89 c6                	mov    %eax,%esi
f01015d9:	85 c0                	test   %eax,%eax
f01015db:	75 24                	jne    f0101601 <mem_init+0x235>
f01015dd:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f01015e4:	f0 
f01015e5:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01015ec:	f0 
f01015ed:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f01015f4:	00 
f01015f5:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01015fc:	e8 3f ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101608:	e8 c5 f9 ff ff       	call   f0100fd2 <page_alloc>
f010160d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101610:	85 c0                	test   %eax,%eax
f0101612:	75 24                	jne    f0101638 <mem_init+0x26c>
f0101614:	c7 44 24 0c 8a 78 10 	movl   $0xf010788a,0xc(%esp)
f010161b:	f0 
f010161c:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101623:	f0 
f0101624:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010162b:	00 
f010162c:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101633:	e8 08 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101638:	39 f7                	cmp    %esi,%edi
f010163a:	75 24                	jne    f0101660 <mem_init+0x294>
f010163c:	c7 44 24 0c a0 78 10 	movl   $0xf01078a0,0xc(%esp)
f0101643:	f0 
f0101644:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010164b:	f0 
f010164c:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101653:	00 
f0101654:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010165b:	e8 e0 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101660:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101663:	39 c6                	cmp    %eax,%esi
f0101665:	74 04                	je     f010166b <mem_init+0x29f>
f0101667:	39 c7                	cmp    %eax,%edi
f0101669:	75 24                	jne    f010168f <mem_init+0x2c3>
f010166b:	c7 44 24 0c 7c 6f 10 	movl   $0xf0106f7c,0xc(%esp)
f0101672:	f0 
f0101673:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010167a:	f0 
f010167b:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101682:	00 
f0101683:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010168a:	e8 b1 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010168f:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101695:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010169a:	c1 e0 0c             	shl    $0xc,%eax
f010169d:	89 f9                	mov    %edi,%ecx
f010169f:	29 d1                	sub    %edx,%ecx
f01016a1:	c1 f9 03             	sar    $0x3,%ecx
f01016a4:	c1 e1 0c             	shl    $0xc,%ecx
f01016a7:	39 c1                	cmp    %eax,%ecx
f01016a9:	72 24                	jb     f01016cf <mem_init+0x303>
f01016ab:	c7 44 24 0c b2 78 10 	movl   $0xf01078b2,0xc(%esp)
f01016b2:	f0 
f01016b3:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01016ba:	f0 
f01016bb:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01016c2:	00 
f01016c3:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01016ca:	e8 71 e9 ff ff       	call   f0100040 <_panic>
f01016cf:	89 f1                	mov    %esi,%ecx
f01016d1:	29 d1                	sub    %edx,%ecx
f01016d3:	c1 f9 03             	sar    $0x3,%ecx
f01016d6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016d9:	39 c8                	cmp    %ecx,%eax
f01016db:	77 24                	ja     f0101701 <mem_init+0x335>
f01016dd:	c7 44 24 0c cf 78 10 	movl   $0xf01078cf,0xc(%esp)
f01016e4:	f0 
f01016e5:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01016ec:	f0 
f01016ed:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01016f4:	00 
f01016f5:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01016fc:	e8 3f e9 ff ff       	call   f0100040 <_panic>
f0101701:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101704:	29 d1                	sub    %edx,%ecx
f0101706:	89 ca                	mov    %ecx,%edx
f0101708:	c1 fa 03             	sar    $0x3,%edx
f010170b:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010170e:	39 d0                	cmp    %edx,%eax
f0101710:	77 24                	ja     f0101736 <mem_init+0x36a>
f0101712:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f0101719:	f0 
f010171a:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101721:	f0 
f0101722:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101729:	00 
f010172a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101731:	e8 0a e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101736:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010173b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010173e:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101745:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101748:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010174f:	e8 7e f8 ff ff       	call   f0100fd2 <page_alloc>
f0101754:	85 c0                	test   %eax,%eax
f0101756:	74 24                	je     f010177c <mem_init+0x3b0>
f0101758:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f010175f:	f0 
f0101760:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101767:	f0 
f0101768:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f010176f:	00 
f0101770:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101777:	e8 c4 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010177c:	89 3c 24             	mov    %edi,(%esp)
f010177f:	e8 d9 f8 ff ff       	call   f010105d <page_free>
	page_free(pp1);
f0101784:	89 34 24             	mov    %esi,(%esp)
f0101787:	e8 d1 f8 ff ff       	call   f010105d <page_free>
	page_free(pp2);
f010178c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010178f:	89 04 24             	mov    %eax,(%esp)
f0101792:	e8 c6 f8 ff ff       	call   f010105d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010179e:	e8 2f f8 ff ff       	call   f0100fd2 <page_alloc>
f01017a3:	89 c6                	mov    %eax,%esi
f01017a5:	85 c0                	test   %eax,%eax
f01017a7:	75 24                	jne    f01017cd <mem_init+0x401>
f01017a9:	c7 44 24 0c 5e 78 10 	movl   $0xf010785e,0xc(%esp)
f01017b0:	f0 
f01017b1:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01017b8:	f0 
f01017b9:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01017c0:	00 
f01017c1:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01017c8:	e8 73 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017d4:	e8 f9 f7 ff ff       	call   f0100fd2 <page_alloc>
f01017d9:	89 c7                	mov    %eax,%edi
f01017db:	85 c0                	test   %eax,%eax
f01017dd:	75 24                	jne    f0101803 <mem_init+0x437>
f01017df:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f01017e6:	f0 
f01017e7:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01017ee:	f0 
f01017ef:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f01017f6:	00 
f01017f7:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01017fe:	e8 3d e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101803:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010180a:	e8 c3 f7 ff ff       	call   f0100fd2 <page_alloc>
f010180f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101812:	85 c0                	test   %eax,%eax
f0101814:	75 24                	jne    f010183a <mem_init+0x46e>
f0101816:	c7 44 24 0c 8a 78 10 	movl   $0xf010788a,0xc(%esp)
f010181d:	f0 
f010181e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101825:	f0 
f0101826:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010182d:	00 
f010182e:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101835:	e8 06 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010183a:	39 fe                	cmp    %edi,%esi
f010183c:	75 24                	jne    f0101862 <mem_init+0x496>
f010183e:	c7 44 24 0c a0 78 10 	movl   $0xf01078a0,0xc(%esp)
f0101845:	f0 
f0101846:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010184d:	f0 
f010184e:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101855:	00 
f0101856:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010185d:	e8 de e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101865:	39 c7                	cmp    %eax,%edi
f0101867:	74 04                	je     f010186d <mem_init+0x4a1>
f0101869:	39 c6                	cmp    %eax,%esi
f010186b:	75 24                	jne    f0101891 <mem_init+0x4c5>
f010186d:	c7 44 24 0c 7c 6f 10 	movl   $0xf0106f7c,0xc(%esp)
f0101874:	f0 
f0101875:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010187c:	f0 
f010187d:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101884:	00 
f0101885:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010188c:	e8 af e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101898:	e8 35 f7 ff ff       	call   f0100fd2 <page_alloc>
f010189d:	85 c0                	test   %eax,%eax
f010189f:	74 24                	je     f01018c5 <mem_init+0x4f9>
f01018a1:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f01018a8:	f0 
f01018a9:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01018b8:	00 
f01018b9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01018c0:	e8 7b e7 ff ff       	call   f0100040 <_panic>
f01018c5:	89 f0                	mov    %esi,%eax
f01018c7:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01018cd:	c1 f8 03             	sar    $0x3,%eax
f01018d0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018d3:	89 c2                	mov    %eax,%edx
f01018d5:	c1 ea 0c             	shr    $0xc,%edx
f01018d8:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01018de:	72 20                	jb     f0101900 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018e4:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f01018eb:	f0 
f01018ec:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018f3:	00 
f01018f4:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f01018fb:	e8 40 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101900:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101907:	00 
f0101908:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010190f:	00 
	return (void *)(pa + KERNBASE);
f0101910:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101915:	89 04 24             	mov    %eax,(%esp)
f0101918:	e8 ca 42 00 00       	call   f0105be7 <memset>
	page_free(pp0);
f010191d:	89 34 24             	mov    %esi,(%esp)
f0101920:	e8 38 f7 ff ff       	call   f010105d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101925:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010192c:	e8 a1 f6 ff ff       	call   f0100fd2 <page_alloc>
f0101931:	85 c0                	test   %eax,%eax
f0101933:	75 24                	jne    f0101959 <mem_init+0x58d>
f0101935:	c7 44 24 0c 18 79 10 	movl   $0xf0107918,0xc(%esp)
f010193c:	f0 
f010193d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101944:	f0 
f0101945:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010194c:	00 
f010194d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101954:	e8 e7 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101959:	39 c6                	cmp    %eax,%esi
f010195b:	74 24                	je     f0101981 <mem_init+0x5b5>
f010195d:	c7 44 24 0c 36 79 10 	movl   $0xf0107936,0xc(%esp)
f0101964:	f0 
f0101965:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010196c:	f0 
f010196d:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101974:	00 
f0101975:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010197c:	e8 bf e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101981:	89 f0                	mov    %esi,%eax
f0101983:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101989:	c1 f8 03             	sar    $0x3,%eax
f010198c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010198f:	89 c2                	mov    %eax,%edx
f0101991:	c1 ea 0c             	shr    $0xc,%edx
f0101994:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010199a:	72 20                	jb     f01019bc <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010199c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019a0:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f01019a7:	f0 
f01019a8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019af:	00 
f01019b0:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f01019b7:	e8 84 e6 ff ff       	call   f0100040 <_panic>
f01019bc:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01019c2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01019c8:	80 38 00             	cmpb   $0x0,(%eax)
f01019cb:	74 24                	je     f01019f1 <mem_init+0x625>
f01019cd:	c7 44 24 0c 46 79 10 	movl   $0xf0107946,0xc(%esp)
f01019d4:	f0 
f01019d5:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01019dc:	f0 
f01019dd:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f01019e4:	00 
f01019e5:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01019ec:	e8 4f e6 ff ff       	call   f0100040 <_panic>
f01019f1:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01019f4:	39 d0                	cmp    %edx,%eax
f01019f6:	75 d0                	jne    f01019c8 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01019f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019fb:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101a00:	89 34 24             	mov    %esi,(%esp)
f0101a03:	e8 55 f6 ff ff       	call   f010105d <page_free>
	page_free(pp1);
f0101a08:	89 3c 24             	mov    %edi,(%esp)
f0101a0b:	e8 4d f6 ff ff       	call   f010105d <page_free>
	page_free(pp2);
f0101a10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a13:	89 04 24             	mov    %eax,(%esp)
f0101a16:	e8 42 f6 ff ff       	call   f010105d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a1b:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101a20:	eb 05                	jmp    f0101a27 <mem_init+0x65b>
		--nfree;
f0101a22:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a25:	8b 00                	mov    (%eax),%eax
f0101a27:	85 c0                	test   %eax,%eax
f0101a29:	75 f7                	jne    f0101a22 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f0101a2b:	85 db                	test   %ebx,%ebx
f0101a2d:	74 24                	je     f0101a53 <mem_init+0x687>
f0101a2f:	c7 44 24 0c 50 79 10 	movl   $0xf0107950,0xc(%esp)
f0101a36:	f0 
f0101a37:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a46:	00 
f0101a47:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101a4e:	e8 ed e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a53:	c7 04 24 9c 6f 10 f0 	movl   $0xf0106f9c,(%esp)
f0101a5a:	e8 13 25 00 00       	call   f0103f72 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a66:	e8 67 f5 ff ff       	call   f0100fd2 <page_alloc>
f0101a6b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a6e:	85 c0                	test   %eax,%eax
f0101a70:	75 24                	jne    f0101a96 <mem_init+0x6ca>
f0101a72:	c7 44 24 0c 5e 78 10 	movl   $0xf010785e,0xc(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101a81:	f0 
f0101a82:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101a89:	00 
f0101a8a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101a91:	e8 aa e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a9d:	e8 30 f5 ff ff       	call   f0100fd2 <page_alloc>
f0101aa2:	89 c3                	mov    %eax,%ebx
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	75 24                	jne    f0101acc <mem_init+0x700>
f0101aa8:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0101aaf:	f0 
f0101ab0:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101ab7:	f0 
f0101ab8:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101abf:	00 
f0101ac0:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101ac7:	e8 74 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101acc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ad3:	e8 fa f4 ff ff       	call   f0100fd2 <page_alloc>
f0101ad8:	89 c6                	mov    %eax,%esi
f0101ada:	85 c0                	test   %eax,%eax
f0101adc:	75 24                	jne    f0101b02 <mem_init+0x736>
f0101ade:	c7 44 24 0c 8a 78 10 	movl   $0xf010788a,0xc(%esp)
f0101ae5:	f0 
f0101ae6:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101aed:	f0 
f0101aee:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101af5:	00 
f0101af6:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101afd:	e8 3e e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b02:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b05:	75 24                	jne    f0101b2b <mem_init+0x75f>
f0101b07:	c7 44 24 0c a0 78 10 	movl   $0xf01078a0,0xc(%esp)
f0101b0e:	f0 
f0101b0f:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101b1e:	00 
f0101b1f:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101b26:	e8 15 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b2b:	39 c3                	cmp    %eax,%ebx
f0101b2d:	74 05                	je     f0101b34 <mem_init+0x768>
f0101b2f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b32:	75 24                	jne    f0101b58 <mem_init+0x78c>
f0101b34:	c7 44 24 0c 7c 6f 10 	movl   $0xf0106f7c,0xc(%esp)
f0101b3b:	f0 
f0101b3c:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101b43:	f0 
f0101b44:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b4b:	00 
f0101b4c:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101b53:	e8 e8 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b58:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101b5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b60:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101b67:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b71:	e8 5c f4 ff ff       	call   f0100fd2 <page_alloc>
f0101b76:	85 c0                	test   %eax,%eax
f0101b78:	74 24                	je     f0101b9e <mem_init+0x7d2>
f0101b7a:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f0101b81:	f0 
f0101b82:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101b89:	f0 
f0101b8a:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101b91:	00 
f0101b92:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101b99:	e8 a2 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ba5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bac:	00 
f0101bad:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101bb2:	89 04 24             	mov    %eax,(%esp)
f0101bb5:	e8 07 f6 ff ff       	call   f01011c1 <page_lookup>
f0101bba:	85 c0                	test   %eax,%eax
f0101bbc:	74 24                	je     f0101be2 <mem_init+0x816>
f0101bbe:	c7 44 24 0c bc 6f 10 	movl   $0xf0106fbc,0xc(%esp)
f0101bc5:	f0 
f0101bc6:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101bcd:	f0 
f0101bce:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101bd5:	00 
f0101bd6:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101bdd:	e8 5e e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101be2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101be9:	00 
f0101bea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bf1:	00 
f0101bf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bf6:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101bfb:	89 04 24             	mov    %eax,(%esp)
f0101bfe:	e8 c1 f6 ff ff       	call   f01012c4 <page_insert>
f0101c03:	85 c0                	test   %eax,%eax
f0101c05:	78 24                	js     f0101c2b <mem_init+0x85f>
f0101c07:	c7 44 24 0c f4 6f 10 	movl   $0xf0106ff4,0xc(%esp)
f0101c0e:	f0 
f0101c0f:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101c16:	f0 
f0101c17:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101c1e:	00 
f0101c1f:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101c26:	e8 15 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2e:	89 04 24             	mov    %eax,(%esp)
f0101c31:	e8 27 f4 ff ff       	call   f010105d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c36:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c3d:	00 
f0101c3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c45:	00 
f0101c46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c4a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101c4f:	89 04 24             	mov    %eax,(%esp)
f0101c52:	e8 6d f6 ff ff       	call   f01012c4 <page_insert>
f0101c57:	85 c0                	test   %eax,%eax
f0101c59:	74 24                	je     f0101c7f <mem_init+0x8b3>
f0101c5b:	c7 44 24 0c 24 70 10 	movl   $0xf0107024,0xc(%esp)
f0101c62:	f0 
f0101c63:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101c6a:	f0 
f0101c6b:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101c72:	00 
f0101c73:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101c7a:	e8 c1 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c7f:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c85:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101c8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c8d:	8b 17                	mov    (%edi),%edx
f0101c8f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c95:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c98:	29 c1                	sub    %eax,%ecx
f0101c9a:	89 c8                	mov    %ecx,%eax
f0101c9c:	c1 f8 03             	sar    $0x3,%eax
f0101c9f:	c1 e0 0c             	shl    $0xc,%eax
f0101ca2:	39 c2                	cmp    %eax,%edx
f0101ca4:	74 24                	je     f0101cca <mem_init+0x8fe>
f0101ca6:	c7 44 24 0c 54 70 10 	movl   $0xf0107054,0xc(%esp)
f0101cad:	f0 
f0101cae:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101cb5:	f0 
f0101cb6:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101cbd:	00 
f0101cbe:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101cc5:	e8 76 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cca:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ccf:	89 f8                	mov    %edi,%eax
f0101cd1:	e8 f2 ed ff ff       	call   f0100ac8 <check_va2pa>
f0101cd6:	89 da                	mov    %ebx,%edx
f0101cd8:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101cdb:	c1 fa 03             	sar    $0x3,%edx
f0101cde:	c1 e2 0c             	shl    $0xc,%edx
f0101ce1:	39 d0                	cmp    %edx,%eax
f0101ce3:	74 24                	je     f0101d09 <mem_init+0x93d>
f0101ce5:	c7 44 24 0c 7c 70 10 	movl   $0xf010707c,0xc(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101cfc:	00 
f0101cfd:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101d04:	e8 37 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d09:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d0e:	74 24                	je     f0101d34 <mem_init+0x968>
f0101d10:	c7 44 24 0c 5b 79 10 	movl   $0xf010795b,0xc(%esp)
f0101d17:	f0 
f0101d18:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101d1f:	f0 
f0101d20:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101d27:	00 
f0101d28:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101d2f:	e8 0c e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d37:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d3c:	74 24                	je     f0101d62 <mem_init+0x996>
f0101d3e:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101d4d:	f0 
f0101d4e:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101d55:	00 
f0101d56:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101d5d:	e8 de e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d62:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d69:	00 
f0101d6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d71:	00 
f0101d72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d76:	89 3c 24             	mov    %edi,(%esp)
f0101d79:	e8 46 f5 ff ff       	call   f01012c4 <page_insert>
f0101d7e:	85 c0                	test   %eax,%eax
f0101d80:	74 24                	je     f0101da6 <mem_init+0x9da>
f0101d82:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0101d89:	f0 
f0101d8a:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101d91:	f0 
f0101d92:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101d99:	00 
f0101d9a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101da6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dab:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101db0:	e8 13 ed ff ff       	call   f0100ac8 <check_va2pa>
f0101db5:	89 f2                	mov    %esi,%edx
f0101db7:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101dbd:	c1 fa 03             	sar    $0x3,%edx
f0101dc0:	c1 e2 0c             	shl    $0xc,%edx
f0101dc3:	39 d0                	cmp    %edx,%eax
f0101dc5:	74 24                	je     f0101deb <mem_init+0xa1f>
f0101dc7:	c7 44 24 0c e8 70 10 	movl   $0xf01070e8,0xc(%esp)
f0101dce:	f0 
f0101dcf:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101dd6:	f0 
f0101dd7:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101dde:	00 
f0101ddf:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101de6:	e8 55 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101deb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101df0:	74 24                	je     f0101e16 <mem_init+0xa4a>
f0101df2:	c7 44 24 0c 7d 79 10 	movl   $0xf010797d,0xc(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101e01:	f0 
f0101e02:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101e09:	00 
f0101e0a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101e11:	e8 2a e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e1d:	e8 b0 f1 ff ff       	call   f0100fd2 <page_alloc>
f0101e22:	85 c0                	test   %eax,%eax
f0101e24:	74 24                	je     f0101e4a <mem_init+0xa7e>
f0101e26:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f0101e2d:	f0 
f0101e2e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101e35:	f0 
f0101e36:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101e3d:	00 
f0101e3e:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101e45:	e8 f6 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e4a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e51:	00 
f0101e52:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e59:	00 
f0101e5a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e5e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e63:	89 04 24             	mov    %eax,(%esp)
f0101e66:	e8 59 f4 ff ff       	call   f01012c4 <page_insert>
f0101e6b:	85 c0                	test   %eax,%eax
f0101e6d:	74 24                	je     f0101e93 <mem_init+0xac7>
f0101e6f:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101e8e:	e8 ad e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e98:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e9d:	e8 26 ec ff ff       	call   f0100ac8 <check_va2pa>
f0101ea2:	89 f2                	mov    %esi,%edx
f0101ea4:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101eaa:	c1 fa 03             	sar    $0x3,%edx
f0101ead:	c1 e2 0c             	shl    $0xc,%edx
f0101eb0:	39 d0                	cmp    %edx,%eax
f0101eb2:	74 24                	je     f0101ed8 <mem_init+0xb0c>
f0101eb4:	c7 44 24 0c e8 70 10 	movl   $0xf01070e8,0xc(%esp)
f0101ebb:	f0 
f0101ebc:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101ec3:	f0 
f0101ec4:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101ecb:	00 
f0101ecc:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101ed3:	e8 68 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ed8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101edd:	74 24                	je     f0101f03 <mem_init+0xb37>
f0101edf:	c7 44 24 0c 7d 79 10 	movl   $0xf010797d,0xc(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101eee:	f0 
f0101eef:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101ef6:	00 
f0101ef7:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101efe:	e8 3d e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f0a:	e8 c3 f0 ff ff       	call   f0100fd2 <page_alloc>
f0101f0f:	85 c0                	test   %eax,%eax
f0101f11:	74 24                	je     f0101f37 <mem_init+0xb6b>
f0101f13:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f0101f1a:	f0 
f0101f1b:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101f2a:	00 
f0101f2b:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101f32:	e8 09 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f37:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0101f3d:	8b 02                	mov    (%edx),%eax
f0101f3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f44:	89 c1                	mov    %eax,%ecx
f0101f46:	c1 e9 0c             	shr    $0xc,%ecx
f0101f49:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0101f4f:	72 20                	jb     f0101f71 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f55:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0101f5c:	f0 
f0101f5d:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101f64:	00 
f0101f65:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101f6c:	e8 cf e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f71:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f80:	00 
f0101f81:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f88:	00 
f0101f89:	89 14 24             	mov    %edx,(%esp)
f0101f8c:	e8 2f f1 ff ff       	call   f01010c0 <pgdir_walk>
f0101f91:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101f94:	8d 51 04             	lea    0x4(%ecx),%edx
f0101f97:	39 d0                	cmp    %edx,%eax
f0101f99:	74 24                	je     f0101fbf <mem_init+0xbf3>
f0101f9b:	c7 44 24 0c 18 71 10 	movl   $0xf0107118,0xc(%esp)
f0101fa2:	f0 
f0101fa3:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101faa:	f0 
f0101fab:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101fb2:	00 
f0101fb3:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0101fba:	e8 81 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fbf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101fc6:	00 
f0101fc7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fce:	00 
f0101fcf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fd3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101fd8:	89 04 24             	mov    %eax,(%esp)
f0101fdb:	e8 e4 f2 ff ff       	call   f01012c4 <page_insert>
f0101fe0:	85 c0                	test   %eax,%eax
f0101fe2:	74 24                	je     f0102008 <mem_init+0xc3c>
f0101fe4:	c7 44 24 0c 58 71 10 	movl   $0xf0107158,0xc(%esp)
f0101feb:	f0 
f0101fec:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0101ff3:	f0 
f0101ff4:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101ffb:	00 
f0101ffc:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102003:	e8 38 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102008:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f010200e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102013:	89 f8                	mov    %edi,%eax
f0102015:	e8 ae ea ff ff       	call   f0100ac8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010201a:	89 f2                	mov    %esi,%edx
f010201c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102022:	c1 fa 03             	sar    $0x3,%edx
f0102025:	c1 e2 0c             	shl    $0xc,%edx
f0102028:	39 d0                	cmp    %edx,%eax
f010202a:	74 24                	je     f0102050 <mem_init+0xc84>
f010202c:	c7 44 24 0c e8 70 10 	movl   $0xf01070e8,0xc(%esp)
f0102033:	f0 
f0102034:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010203b:	f0 
f010203c:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102043:	00 
f0102044:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010204b:	e8 f0 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102050:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102055:	74 24                	je     f010207b <mem_init+0xcaf>
f0102057:	c7 44 24 0c 7d 79 10 	movl   $0xf010797d,0xc(%esp)
f010205e:	f0 
f010205f:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102066:	f0 
f0102067:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010206e:	00 
f010206f:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102076:	e8 c5 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010207b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102082:	00 
f0102083:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010208a:	00 
f010208b:	89 3c 24             	mov    %edi,(%esp)
f010208e:	e8 2d f0 ff ff       	call   f01010c0 <pgdir_walk>
f0102093:	f6 00 04             	testb  $0x4,(%eax)
f0102096:	75 24                	jne    f01020bc <mem_init+0xcf0>
f0102098:	c7 44 24 0c 98 71 10 	movl   $0xf0107198,0xc(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01020a7:	f0 
f01020a8:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f01020af:	00 
f01020b0:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01020b7:	e8 84 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020bc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01020c1:	f6 00 04             	testb  $0x4,(%eax)
f01020c4:	75 24                	jne    f01020ea <mem_init+0xd1e>
f01020c6:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f01020cd:	f0 
f01020ce:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01020d5:	f0 
f01020d6:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01020dd:	00 
f01020de:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01020e5:	e8 56 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020ea:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020f1:	00 
f01020f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020f9:	00 
f01020fa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020fe:	89 04 24             	mov    %eax,(%esp)
f0102101:	e8 be f1 ff ff       	call   f01012c4 <page_insert>
f0102106:	85 c0                	test   %eax,%eax
f0102108:	74 24                	je     f010212e <mem_init+0xd62>
f010210a:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0102111:	f0 
f0102112:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102129:	e8 12 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010212e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102135:	00 
f0102136:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010213d:	00 
f010213e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102143:	89 04 24             	mov    %eax,(%esp)
f0102146:	e8 75 ef ff ff       	call   f01010c0 <pgdir_walk>
f010214b:	f6 00 02             	testb  $0x2,(%eax)
f010214e:	75 24                	jne    f0102174 <mem_init+0xda8>
f0102150:	c7 44 24 0c cc 71 10 	movl   $0xf01071cc,0xc(%esp)
f0102157:	f0 
f0102158:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010215f:	f0 
f0102160:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102167:	00 
f0102168:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010216f:	e8 cc de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102174:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010217b:	00 
f010217c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102183:	00 
f0102184:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102189:	89 04 24             	mov    %eax,(%esp)
f010218c:	e8 2f ef ff ff       	call   f01010c0 <pgdir_walk>
f0102191:	f6 00 04             	testb  $0x4,(%eax)
f0102194:	74 24                	je     f01021ba <mem_init+0xdee>
f0102196:	c7 44 24 0c 00 72 10 	movl   $0xf0107200,0xc(%esp)
f010219d:	f0 
f010219e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01021ad:	00 
f01021ae:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01021b5:	e8 86 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021ba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021c1:	00 
f01021c2:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01021c9:	00 
f01021ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021d1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01021d6:	89 04 24             	mov    %eax,(%esp)
f01021d9:	e8 e6 f0 ff ff       	call   f01012c4 <page_insert>
f01021de:	85 c0                	test   %eax,%eax
f01021e0:	78 24                	js     f0102206 <mem_init+0xe3a>
f01021e2:	c7 44 24 0c 38 72 10 	movl   $0xf0107238,0xc(%esp)
f01021e9:	f0 
f01021ea:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01021f1:	f0 
f01021f2:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f01021f9:	00 
f01021fa:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102201:	e8 3a de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102206:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010220d:	00 
f010220e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102215:	00 
f0102216:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010221a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010221f:	89 04 24             	mov    %eax,(%esp)
f0102222:	e8 9d f0 ff ff       	call   f01012c4 <page_insert>
f0102227:	85 c0                	test   %eax,%eax
f0102229:	74 24                	je     f010224f <mem_init+0xe83>
f010222b:	c7 44 24 0c 70 72 10 	movl   $0xf0107270,0xc(%esp)
f0102232:	f0 
f0102233:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010223a:	f0 
f010223b:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102242:	00 
f0102243:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010224a:	e8 f1 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010224f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102256:	00 
f0102257:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010225e:	00 
f010225f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102264:	89 04 24             	mov    %eax,(%esp)
f0102267:	e8 54 ee ff ff       	call   f01010c0 <pgdir_walk>
f010226c:	f6 00 04             	testb  $0x4,(%eax)
f010226f:	74 24                	je     f0102295 <mem_init+0xec9>
f0102271:	c7 44 24 0c 00 72 10 	movl   $0xf0107200,0xc(%esp)
f0102278:	f0 
f0102279:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102280:	f0 
f0102281:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102288:	00 
f0102289:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102290:	e8 ab dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102295:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f010229b:	ba 00 00 00 00       	mov    $0x0,%edx
f01022a0:	89 f8                	mov    %edi,%eax
f01022a2:	e8 21 e8 ff ff       	call   f0100ac8 <check_va2pa>
f01022a7:	89 c1                	mov    %eax,%ecx
f01022a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022ac:	89 d8                	mov    %ebx,%eax
f01022ae:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01022b4:	c1 f8 03             	sar    $0x3,%eax
f01022b7:	c1 e0 0c             	shl    $0xc,%eax
f01022ba:	39 c1                	cmp    %eax,%ecx
f01022bc:	74 24                	je     f01022e2 <mem_init+0xf16>
f01022be:	c7 44 24 0c ac 72 10 	movl   $0xf01072ac,0xc(%esp)
f01022c5:	f0 
f01022c6:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01022cd:	f0 
f01022ce:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f01022d5:	00 
f01022d6:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e7:	89 f8                	mov    %edi,%eax
f01022e9:	e8 da e7 ff ff       	call   f0100ac8 <check_va2pa>
f01022ee:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01022f1:	74 24                	je     f0102317 <mem_init+0xf4b>
f01022f3:	c7 44 24 0c d8 72 10 	movl   $0xf01072d8,0xc(%esp)
f01022fa:	f0 
f01022fb:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102302:	f0 
f0102303:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010230a:	00 
f010230b:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102312:	e8 29 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102317:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010231c:	74 24                	je     f0102342 <mem_init+0xf76>
f010231e:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0102325:	f0 
f0102326:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010232d:	f0 
f010232e:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102335:	00 
f0102336:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010233d:	e8 fe dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102342:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102347:	74 24                	je     f010236d <mem_init+0xfa1>
f0102349:	c7 44 24 0c b5 79 10 	movl   $0xf01079b5,0xc(%esp)
f0102350:	f0 
f0102351:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102358:	f0 
f0102359:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102360:	00 
f0102361:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010236d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102374:	e8 59 ec ff ff       	call   f0100fd2 <page_alloc>
f0102379:	85 c0                	test   %eax,%eax
f010237b:	74 04                	je     f0102381 <mem_init+0xfb5>
f010237d:	39 c6                	cmp    %eax,%esi
f010237f:	74 24                	je     f01023a5 <mem_init+0xfd9>
f0102381:	c7 44 24 0c 08 73 10 	movl   $0xf0107308,0xc(%esp)
f0102388:	f0 
f0102389:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102390:	f0 
f0102391:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102398:	00 
f0102399:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01023a0:	e8 9b dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01023ac:	00 
f01023ad:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01023b2:	89 04 24             	mov    %eax,(%esp)
f01023b5:	e8 b1 ee ff ff       	call   f010126b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023ba:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01023c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01023c5:	89 f8                	mov    %edi,%eax
f01023c7:	e8 fc e6 ff ff       	call   f0100ac8 <check_va2pa>
f01023cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023cf:	74 24                	je     f01023f5 <mem_init+0x1029>
f01023d1:	c7 44 24 0c 2c 73 10 	movl   $0xf010732c,0xc(%esp)
f01023d8:	f0 
f01023d9:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01023e0:	f0 
f01023e1:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01023e8:	00 
f01023e9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023f5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023fa:	89 f8                	mov    %edi,%eax
f01023fc:	e8 c7 e6 ff ff       	call   f0100ac8 <check_va2pa>
f0102401:	89 da                	mov    %ebx,%edx
f0102403:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102409:	c1 fa 03             	sar    $0x3,%edx
f010240c:	c1 e2 0c             	shl    $0xc,%edx
f010240f:	39 d0                	cmp    %edx,%eax
f0102411:	74 24                	je     f0102437 <mem_init+0x106b>
f0102413:	c7 44 24 0c d8 72 10 	movl   $0xf01072d8,0xc(%esp)
f010241a:	f0 
f010241b:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102422:	f0 
f0102423:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f010242a:	00 
f010242b:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102432:	e8 09 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102437:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010243c:	74 24                	je     f0102462 <mem_init+0x1096>
f010243e:	c7 44 24 0c 5b 79 10 	movl   $0xf010795b,0xc(%esp)
f0102445:	f0 
f0102446:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010244d:	f0 
f010244e:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102455:	00 
f0102456:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010245d:	e8 de db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102462:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102467:	74 24                	je     f010248d <mem_init+0x10c1>
f0102469:	c7 44 24 0c b5 79 10 	movl   $0xf01079b5,0xc(%esp)
f0102470:	f0 
f0102471:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102478:	f0 
f0102479:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102480:	00 
f0102481:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102488:	e8 b3 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010248d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102494:	00 
f0102495:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010249c:	00 
f010249d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024a1:	89 3c 24             	mov    %edi,(%esp)
f01024a4:	e8 1b ee ff ff       	call   f01012c4 <page_insert>
f01024a9:	85 c0                	test   %eax,%eax
f01024ab:	74 24                	je     f01024d1 <mem_init+0x1105>
f01024ad:	c7 44 24 0c 50 73 10 	movl   $0xf0107350,0xc(%esp)
f01024b4:	f0 
f01024b5:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01024bc:	f0 
f01024bd:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f01024c4:	00 
f01024c5:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01024cc:	e8 6f db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024d1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024d6:	75 24                	jne    f01024fc <mem_init+0x1130>
f01024d8:	c7 44 24 0c c6 79 10 	movl   $0xf01079c6,0xc(%esp)
f01024df:	f0 
f01024e0:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01024e7:	f0 
f01024e8:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01024ef:	00 
f01024f0:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01024f7:	e8 44 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01024fc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01024ff:	74 24                	je     f0102525 <mem_init+0x1159>
f0102501:	c7 44 24 0c d2 79 10 	movl   $0xf01079d2,0xc(%esp)
f0102508:	f0 
f0102509:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102510:	f0 
f0102511:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102518:	00 
f0102519:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102520:	e8 1b db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102525:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010252c:	00 
f010252d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102532:	89 04 24             	mov    %eax,(%esp)
f0102535:	e8 31 ed ff ff       	call   f010126b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010253a:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102540:	ba 00 00 00 00       	mov    $0x0,%edx
f0102545:	89 f8                	mov    %edi,%eax
f0102547:	e8 7c e5 ff ff       	call   f0100ac8 <check_va2pa>
f010254c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010254f:	74 24                	je     f0102575 <mem_init+0x11a9>
f0102551:	c7 44 24 0c 2c 73 10 	movl   $0xf010732c,0xc(%esp)
f0102558:	f0 
f0102559:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102560:	f0 
f0102561:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102568:	00 
f0102569:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102575:	ba 00 10 00 00       	mov    $0x1000,%edx
f010257a:	89 f8                	mov    %edi,%eax
f010257c:	e8 47 e5 ff ff       	call   f0100ac8 <check_va2pa>
f0102581:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102584:	74 24                	je     f01025aa <mem_init+0x11de>
f0102586:	c7 44 24 0c 88 73 10 	movl   $0xf0107388,0xc(%esp)
f010258d:	f0 
f010258e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102595:	f0 
f0102596:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f010259d:	00 
f010259e:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01025a5:	e8 96 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01025aa:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025af:	74 24                	je     f01025d5 <mem_init+0x1209>
f01025b1:	c7 44 24 0c e7 79 10 	movl   $0xf01079e7,0xc(%esp)
f01025b8:	f0 
f01025b9:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01025c0:	f0 
f01025c1:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f01025c8:	00 
f01025c9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01025d0:	e8 6b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025d5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025da:	74 24                	je     f0102600 <mem_init+0x1234>
f01025dc:	c7 44 24 0c b5 79 10 	movl   $0xf01079b5,0xc(%esp)
f01025e3:	f0 
f01025e4:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01025f3:	00 
f01025f4:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01025fb:	e8 40 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102600:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102607:	e8 c6 e9 ff ff       	call   f0100fd2 <page_alloc>
f010260c:	85 c0                	test   %eax,%eax
f010260e:	74 04                	je     f0102614 <mem_init+0x1248>
f0102610:	39 c3                	cmp    %eax,%ebx
f0102612:	74 24                	je     f0102638 <mem_init+0x126c>
f0102614:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f010261b:	f0 
f010261c:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102623:	f0 
f0102624:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010262b:	00 
f010262c:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102633:	e8 08 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102638:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010263f:	e8 8e e9 ff ff       	call   f0100fd2 <page_alloc>
f0102644:	85 c0                	test   %eax,%eax
f0102646:	74 24                	je     f010266c <mem_init+0x12a0>
f0102648:	c7 44 24 0c 09 79 10 	movl   $0xf0107909,0xc(%esp)
f010264f:	f0 
f0102650:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102657:	f0 
f0102658:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010265f:	00 
f0102660:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102667:	e8 d4 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010266c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102671:	8b 08                	mov    (%eax),%ecx
f0102673:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102679:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010267c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102682:	c1 fa 03             	sar    $0x3,%edx
f0102685:	c1 e2 0c             	shl    $0xc,%edx
f0102688:	39 d1                	cmp    %edx,%ecx
f010268a:	74 24                	je     f01026b0 <mem_init+0x12e4>
f010268c:	c7 44 24 0c 54 70 10 	movl   $0xf0107054,0xc(%esp)
f0102693:	f0 
f0102694:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010269b:	f0 
f010269c:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f01026a3:	00 
f01026a4:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01026ab:	e8 90 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01026b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01026b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026b9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026be:	74 24                	je     f01026e4 <mem_init+0x1318>
f01026c0:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f01026c7:	f0 
f01026c8:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01026cf:	f0 
f01026d0:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01026d7:	00 
f01026d8:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01026df:	e8 5c d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01026e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026e7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01026ed:	89 04 24             	mov    %eax,(%esp)
f01026f0:	e8 68 e9 ff ff       	call   f010105d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01026f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026fc:	00 
f01026fd:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102704:	00 
f0102705:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010270a:	89 04 24             	mov    %eax,(%esp)
f010270d:	e8 ae e9 ff ff       	call   f01010c0 <pgdir_walk>
f0102712:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102718:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f010271e:	8b 7a 04             	mov    0x4(%edx),%edi
f0102721:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102727:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f010272d:	89 f8                	mov    %edi,%eax
f010272f:	c1 e8 0c             	shr    $0xc,%eax
f0102732:	39 c8                	cmp    %ecx,%eax
f0102734:	72 20                	jb     f0102756 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102736:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010273a:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0102741:	f0 
f0102742:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102749:	00 
f010274a:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102751:	e8 ea d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102756:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010275c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010275f:	74 24                	je     f0102785 <mem_init+0x13b9>
f0102761:	c7 44 24 0c f8 79 10 	movl   $0xf01079f8,0xc(%esp)
f0102768:	f0 
f0102769:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102770:	f0 
f0102771:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102778:	00 
f0102779:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102780:	e8 bb d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102785:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f010278c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010278f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102795:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010279b:	c1 f8 03             	sar    $0x3,%eax
f010279e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027a1:	89 c2                	mov    %eax,%edx
f01027a3:	c1 ea 0c             	shr    $0xc,%edx
f01027a6:	39 d1                	cmp    %edx,%ecx
f01027a8:	77 20                	ja     f01027ca <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027ae:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f01027b5:	f0 
f01027b6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027bd:	00 
f01027be:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f01027c5:	e8 76 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027d1:	00 
f01027d2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01027d9:	00 
	return (void *)(pa + KERNBASE);
f01027da:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027df:	89 04 24             	mov    %eax,(%esp)
f01027e2:	e8 00 34 00 00       	call   f0105be7 <memset>
	page_free(pp0);
f01027e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027ea:	89 3c 24             	mov    %edi,(%esp)
f01027ed:	e8 6b e8 ff ff       	call   f010105d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027f9:	00 
f01027fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102801:	00 
f0102802:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102807:	89 04 24             	mov    %eax,(%esp)
f010280a:	e8 b1 e8 ff ff       	call   f01010c0 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010280f:	89 fa                	mov    %edi,%edx
f0102811:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102817:	c1 fa 03             	sar    $0x3,%edx
f010281a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010281d:	89 d0                	mov    %edx,%eax
f010281f:	c1 e8 0c             	shr    $0xc,%eax
f0102822:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102828:	72 20                	jb     f010284a <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010282a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010282e:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0102835:	f0 
f0102836:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010283d:	00 
f010283e:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010284a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102850:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102853:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102859:	f6 00 01             	testb  $0x1,(%eax)
f010285c:	74 24                	je     f0102882 <mem_init+0x14b6>
f010285e:	c7 44 24 0c 10 7a 10 	movl   $0xf0107a10,0xc(%esp)
f0102865:	f0 
f0102866:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010286d:	f0 
f010286e:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102875:	00 
f0102876:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010287d:	e8 be d7 ff ff       	call   f0100040 <_panic>
f0102882:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102885:	39 d0                	cmp    %edx,%eax
f0102887:	75 d0                	jne    f0102859 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102889:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010288e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102897:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010289d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028a0:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240

	// free the pages we took
	page_free(pp0);
f01028a6:	89 04 24             	mov    %eax,(%esp)
f01028a9:	e8 af e7 ff ff       	call   f010105d <page_free>
	page_free(pp1);
f01028ae:	89 1c 24             	mov    %ebx,(%esp)
f01028b1:	e8 a7 e7 ff ff       	call   f010105d <page_free>
	page_free(pp2);
f01028b6:	89 34 24             	mov    %esi,(%esp)
f01028b9:	e8 9f e7 ff ff       	call   f010105d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028be:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01028c5:	00 
f01028c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028cd:	e8 85 ea ff ff       	call   f0101357 <mmio_map_region>
f01028d2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028d4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028db:	00 
f01028dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028e3:	e8 6f ea ff ff       	call   f0101357 <mmio_map_region>
f01028e8:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01028ea:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01028f0:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01028f5:	77 08                	ja     f01028ff <mem_init+0x1533>
f01028f7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028fd:	77 24                	ja     f0102923 <mem_init+0x1557>
f01028ff:	c7 44 24 0c d4 73 10 	movl   $0xf01073d4,0xc(%esp)
f0102906:	f0 
f0102907:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010290e:	f0 
f010290f:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102916:	00 
f0102917:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010291e:	e8 1d d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102923:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102929:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010292f:	77 08                	ja     f0102939 <mem_init+0x156d>
f0102931:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102937:	77 24                	ja     f010295d <mem_init+0x1591>
f0102939:	c7 44 24 0c fc 73 10 	movl   $0xf01073fc,0xc(%esp)
f0102940:	f0 
f0102941:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102948:	f0 
f0102949:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102950:	00 
f0102951:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102958:	e8 e3 d6 ff ff       	call   f0100040 <_panic>
f010295d:	89 da                	mov    %ebx,%edx
f010295f:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102961:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102967:	74 24                	je     f010298d <mem_init+0x15c1>
f0102969:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f0102970:	f0 
f0102971:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102978:	f0 
f0102979:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102980:	00 
f0102981:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102988:	e8 b3 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010298d:	39 c6                	cmp    %eax,%esi
f010298f:	73 24                	jae    f01029b5 <mem_init+0x15e9>
f0102991:	c7 44 24 0c 27 7a 10 	movl   $0xf0107a27,0xc(%esp)
f0102998:	f0 
f0102999:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01029a0:	f0 
f01029a1:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01029a8:	00 
f01029a9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01029b0:	e8 8b d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029b5:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01029bb:	89 da                	mov    %ebx,%edx
f01029bd:	89 f8                	mov    %edi,%eax
f01029bf:	e8 04 e1 ff ff       	call   f0100ac8 <check_va2pa>
f01029c4:	85 c0                	test   %eax,%eax
f01029c6:	74 24                	je     f01029ec <mem_init+0x1620>
f01029c8:	c7 44 24 0c 4c 74 10 	movl   $0xf010744c,0xc(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01029d7:	f0 
f01029d8:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f01029df:	00 
f01029e0:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01029e7:	e8 54 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029ec:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01029f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029f5:	89 c2                	mov    %eax,%edx
f01029f7:	89 f8                	mov    %edi,%eax
f01029f9:	e8 ca e0 ff ff       	call   f0100ac8 <check_va2pa>
f01029fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a03:	74 24                	je     f0102a29 <mem_init+0x165d>
f0102a05:	c7 44 24 0c 70 74 10 	movl   $0xf0107470,0xc(%esp)
f0102a0c:	f0 
f0102a0d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102a14:	f0 
f0102a15:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102a1c:	00 
f0102a1d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102a24:	e8 17 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a29:	89 f2                	mov    %esi,%edx
f0102a2b:	89 f8                	mov    %edi,%eax
f0102a2d:	e8 96 e0 ff ff       	call   f0100ac8 <check_va2pa>
f0102a32:	85 c0                	test   %eax,%eax
f0102a34:	74 24                	je     f0102a5a <mem_init+0x168e>
f0102a36:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0102a3d:	f0 
f0102a3e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102a45:	f0 
f0102a46:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102a4d:	00 
f0102a4e:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102a55:	e8 e6 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a5a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a60:	89 f8                	mov    %edi,%eax
f0102a62:	e8 61 e0 ff ff       	call   f0100ac8 <check_va2pa>
f0102a67:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a6a:	74 24                	je     f0102a90 <mem_init+0x16c4>
f0102a6c:	c7 44 24 0c c4 74 10 	movl   $0xf01074c4,0xc(%esp)
f0102a73:	f0 
f0102a74:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102a7b:	f0 
f0102a7c:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102a83:	00 
f0102a84:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102a8b:	e8 b0 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a97:	00 
f0102a98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a9c:	89 3c 24             	mov    %edi,(%esp)
f0102a9f:	e8 1c e6 ff ff       	call   f01010c0 <pgdir_walk>
f0102aa4:	f6 00 1a             	testb  $0x1a,(%eax)
f0102aa7:	75 24                	jne    f0102acd <mem_init+0x1701>
f0102aa9:	c7 44 24 0c f0 74 10 	movl   $0xf01074f0,0xc(%esp)
f0102ab0:	f0 
f0102ab1:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102ab8:	f0 
f0102ab9:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102ac0:	00 
f0102ac1:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102ac8:	e8 73 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102acd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ad4:	00 
f0102ad5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ad9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102ade:	89 04 24             	mov    %eax,(%esp)
f0102ae1:	e8 da e5 ff ff       	call   f01010c0 <pgdir_walk>
f0102ae6:	f6 00 04             	testb  $0x4,(%eax)
f0102ae9:	74 24                	je     f0102b0f <mem_init+0x1743>
f0102aeb:	c7 44 24 0c 34 75 10 	movl   $0xf0107534,0xc(%esp)
f0102af2:	f0 
f0102af3:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102afa:	f0 
f0102afb:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102b02:	00 
f0102b03:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102b0a:	e8 31 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b16:	00 
f0102b17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b1b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b20:	89 04 24             	mov    %eax,(%esp)
f0102b23:	e8 98 e5 ff ff       	call   f01010c0 <pgdir_walk>
f0102b28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b35:	00 
f0102b36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b3d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b42:	89 04 24             	mov    %eax,(%esp)
f0102b45:	e8 76 e5 ff ff       	call   f01010c0 <pgdir_walk>
f0102b4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b57:	00 
f0102b58:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b5c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b61:	89 04 24             	mov    %eax,(%esp)
f0102b64:	e8 57 e5 ff ff       	call   f01010c0 <pgdir_walk>
f0102b69:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b6f:	c7 04 24 39 7a 10 f0 	movl   $0xf0107a39,(%esp)
f0102b76:	e8 f7 13 00 00       	call   f0103f72 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b7b:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0102b80:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102b87:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b8d:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b92:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b97:	77 20                	ja     f0102bb9 <mem_init+0x17ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b9d:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102ba4:	f0 
f0102ba5:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102bac:	00 
f0102bad:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102bb4:	e8 87 d4 ff ff       	call   f0100040 <_panic>
f0102bb9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bc0:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bc1:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bc6:	89 04 24             	mov    %eax,(%esp)
f0102bc9:	89 d9                	mov    %ebx,%ecx
f0102bcb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102bd0:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102bd5:	e8 86 e5 ff ff       	call   f0101160 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102bda:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102be6:	77 20                	ja     f0102c08 <mem_init+0x183c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bec:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102bf3:	f0 
f0102bf4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102bfb:	00 
f0102bfc:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102c03:	e8 38 d4 ff ff       	call   f0100040 <_panic>
f0102c08:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c0f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c10:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c16:	89 04 24             	mov    %eax,(%esp)
f0102c19:	89 d9                	mov    %ebx,%ecx
f0102c1b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c20:	e8 3b e5 ff ff       	call   f0101160 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102c25:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c2a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c2f:	77 20                	ja     f0102c51 <mem_init+0x1885>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c31:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c35:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102c3c:	f0 
f0102c3d:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102c44:	00 
f0102c45:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102c4c:	e8 ef d3 ff ff       	call   f0100040 <_panic>
f0102c51:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c58:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c59:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c5e:	89 04 24             	mov    %eax,(%esp)
f0102c61:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c66:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c6b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c70:	e8 eb e4 ff ff       	call   f0101160 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102c75:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c7b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c81:	77 20                	ja     f0102ca3 <mem_init+0x18d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c83:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c87:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102c8e:	f0 
f0102c8f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102c96:	00 
f0102c97:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102c9e:	e8 9d d3 ff ff       	call   f0100040 <_panic>
f0102ca3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102caa:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cab:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102cb1:	89 04 24             	mov    %eax,(%esp)
f0102cb4:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102cb9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102cbe:	e8 9d e4 ff ff       	call   f0101160 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cc3:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102cc8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ccd:	77 20                	ja     f0102cef <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cd3:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102cda:	f0 
f0102cdb:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102ce2:	00 
f0102ce3:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102cea:	e8 51 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102cef:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102cf6:	00 
f0102cf7:	c7 04 24 00 60 11 00 	movl   $0x116000,(%esp)
f0102cfe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d03:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d08:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d0d:	e8 4e e4 ff ff       	call   f0101160 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102d12:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d19:	00 
f0102d1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d21:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102d26:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d2b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d30:	e8 2b e4 ff ff       	call   f0101160 <boot_map_region>
f0102d35:	bf 00 d0 26 f0       	mov    $0xf026d000,%edi
f0102d3a:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f0102d3f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d44:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d4a:	77 20                	ja     f0102d6c <mem_init+0x19a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d4c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d50:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102d57:	f0 
f0102d58:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102d5f:	00 
f0102d60:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102d67:	e8 d4 d2 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102d6c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d73:	00 
f0102d74:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d7a:	89 04 24             	mov    %eax,(%esp)
f0102d7d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d82:	89 f2                	mov    %esi,%edx
f0102d84:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d89:	e8 d2 e3 ff ff       	call   f0101160 <boot_map_region>
f0102d8e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d94:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
f0102d9a:	39 fb                	cmp    %edi,%ebx
f0102d9c:	75 a6                	jne    f0102d44 <mem_init+0x1978>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d9e:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102da4:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0102da9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102dac:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102db3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102db8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dbb:	8b 35 90 be 22 f0    	mov    0xf022be90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc1:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102dc4:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102dca:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102dd2:	eb 6a                	jmp    f0102e3e <mem_init+0x1a72>
f0102dd4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dda:	89 f8                	mov    %edi,%eax
f0102ddc:	e8 e7 dc ff ff       	call   f0100ac8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102de1:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102de8:	77 20                	ja     f0102e0a <mem_init+0x1a3e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dee:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102df5:	f0 
f0102df6:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102dfd:	00 
f0102dfe:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102e05:	e8 36 d2 ff ff       	call   f0100040 <_panic>
f0102e0a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e0d:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e10:	39 d0                	cmp    %edx,%eax
f0102e12:	74 24                	je     f0102e38 <mem_init+0x1a6c>
f0102e14:	c7 44 24 0c 68 75 10 	movl   $0xf0107568,0xc(%esp)
f0102e1b:	f0 
f0102e1c:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102e23:	f0 
f0102e24:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102e2b:	00 
f0102e2c:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102e33:	e8 08 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e38:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e3e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e41:	77 91                	ja     f0102dd4 <mem_init+0x1a08>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e43:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e49:	89 de                	mov    %ebx,%esi
f0102e4b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e50:	89 f8                	mov    %edi,%eax
f0102e52:	e8 71 dc ff ff       	call   f0100ac8 <check_va2pa>
f0102e57:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e5d:	77 20                	ja     f0102e7f <mem_init+0x1ab3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e5f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e63:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102e6a:	f0 
f0102e6b:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e72:	00 
f0102e73:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102e7a:	e8 c1 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e7f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e84:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102e8a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e8d:	39 d0                	cmp    %edx,%eax
f0102e8f:	74 24                	je     f0102eb5 <mem_init+0x1ae9>
f0102e91:	c7 44 24 0c 9c 75 10 	movl   $0xf010759c,0xc(%esp)
f0102e98:	f0 
f0102e99:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102ea0:	f0 
f0102ea1:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ea8:	00 
f0102ea9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102eb0:	e8 8b d1 ff ff       	call   f0100040 <_panic>
f0102eb5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ebb:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102ec1:	0f 85 a8 05 00 00    	jne    f010346f <mem_init+0x20a3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ec7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102eca:	c1 e6 0c             	shl    $0xc,%esi
f0102ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ed2:	eb 3b                	jmp    f0102f0f <mem_init+0x1b43>
f0102ed4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eda:	89 f8                	mov    %edi,%eax
f0102edc:	e8 e7 db ff ff       	call   f0100ac8 <check_va2pa>
f0102ee1:	39 c3                	cmp    %eax,%ebx
f0102ee3:	74 24                	je     f0102f09 <mem_init+0x1b3d>
f0102ee5:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f0102eec:	f0 
f0102eed:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102ef4:	f0 
f0102ef5:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102efc:	00 
f0102efd:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102f04:	e8 37 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f0f:	39 f3                	cmp    %esi,%ebx
f0102f11:	72 c1                	jb     f0102ed4 <mem_init+0x1b08>
f0102f13:	c7 45 d0 00 d0 22 f0 	movl   $0xf022d000,-0x30(%ebp)
f0102f1a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f21:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f26:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
f0102f2b:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f30:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f33:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f39:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f3c:	89 f2                	mov    %esi,%edx
f0102f3e:	89 f8                	mov    %edi,%eax
f0102f40:	e8 83 db ff ff       	call   f0100ac8 <check_va2pa>
f0102f45:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f48:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f4e:	77 20                	ja     f0102f70 <mem_init+0x1ba4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f50:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f54:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0102f5b:	f0 
f0102f5c:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f63:	00 
f0102f64:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102f6b:	e8 d0 d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f70:	89 f3                	mov    %esi,%ebx
f0102f72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102f75:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102f78:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f7b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f7e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102f81:	39 c2                	cmp    %eax,%edx
f0102f83:	74 24                	je     f0102fa9 <mem_init+0x1bdd>
f0102f85:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f0102f8c:	f0 
f0102f8d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102f94:	f0 
f0102f95:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f9c:	00 
f0102f9d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102fa4:	e8 97 d0 ff ff       	call   f0100040 <_panic>
f0102fa9:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102faf:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fb2:	0f 85 a9 04 00 00    	jne    f0103461 <mem_init+0x2095>
f0102fb8:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102fbe:	89 da                	mov    %ebx,%edx
f0102fc0:	89 f8                	mov    %edi,%eax
f0102fc2:	e8 01 db ff ff       	call   f0100ac8 <check_va2pa>
f0102fc7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fca:	74 24                	je     f0102ff0 <mem_init+0x1c24>
f0102fcc:	c7 44 24 0c 40 76 10 	movl   $0xf0107640,0xc(%esp)
f0102fd3:	f0 
f0102fd4:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0102fdb:	f0 
f0102fdc:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102fe3:	00 
f0102fe4:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0102feb:	e8 50 d0 ff ff       	call   f0100040 <_panic>
f0102ff0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102ff6:	39 de                	cmp    %ebx,%esi
f0102ff8:	75 c4                	jne    f0102fbe <mem_init+0x1bf2>
f0102ffa:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103000:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0103007:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010300e:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103014:	0f 85 19 ff ff ff    	jne    f0102f33 <mem_init+0x1b67>
f010301a:	b8 00 00 00 00       	mov    $0x0,%eax
f010301f:	e9 c2 00 00 00       	jmp    f01030e6 <mem_init+0x1d1a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103024:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010302a:	83 fa 04             	cmp    $0x4,%edx
f010302d:	77 2e                	ja     f010305d <mem_init+0x1c91>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010302f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103033:	0f 85 aa 00 00 00    	jne    f01030e3 <mem_init+0x1d17>
f0103039:	c7 44 24 0c 52 7a 10 	movl   $0xf0107a52,0xc(%esp)
f0103040:	f0 
f0103041:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0103048:	f0 
f0103049:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103050:	00 
f0103051:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0103058:	e8 e3 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010305d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103062:	76 55                	jbe    f01030b9 <mem_init+0x1ced>
				assert(pgdir[i] & PTE_P);
f0103064:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103067:	f6 c2 01             	test   $0x1,%dl
f010306a:	75 24                	jne    f0103090 <mem_init+0x1cc4>
f010306c:	c7 44 24 0c 52 7a 10 	movl   $0xf0107a52,0xc(%esp)
f0103073:	f0 
f0103074:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010307b:	f0 
f010307c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0103083:	00 
f0103084:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010308b:	e8 b0 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103090:	f6 c2 02             	test   $0x2,%dl
f0103093:	75 4e                	jne    f01030e3 <mem_init+0x1d17>
f0103095:	c7 44 24 0c 63 7a 10 	movl   $0xf0107a63,0xc(%esp)
f010309c:	f0 
f010309d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01030a4:	f0 
f01030a5:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01030ac:	00 
f01030ad:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01030b4:	e8 87 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01030b9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030bd:	74 24                	je     f01030e3 <mem_init+0x1d17>
f01030bf:	c7 44 24 0c 74 7a 10 	movl   $0xf0107a74,0xc(%esp)
f01030c6:	f0 
f01030c7:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01030ce:	f0 
f01030cf:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01030d6:	00 
f01030d7:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01030de:	e8 5d cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01030e3:	83 c0 01             	add    $0x1,%eax
f01030e6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030eb:	0f 85 33 ff ff ff    	jne    f0103024 <mem_init+0x1c58>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01030f1:	c7 04 24 64 76 10 f0 	movl   $0xf0107664,(%esp)
f01030f8:	e8 75 0e 00 00       	call   f0103f72 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01030fd:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103102:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103107:	77 20                	ja     f0103129 <mem_init+0x1d5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103109:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010310d:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103114:	f0 
f0103115:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f010311c:	00 
f010311d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0103124:	e8 17 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103129:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010312e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103131:	b8 00 00 00 00       	mov    $0x0,%eax
f0103136:	e8 fc d9 ff ff       	call   f0100b37 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010313b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010313e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103141:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103146:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103150:	e8 7d de ff ff       	call   f0100fd2 <page_alloc>
f0103155:	89 c3                	mov    %eax,%ebx
f0103157:	85 c0                	test   %eax,%eax
f0103159:	75 24                	jne    f010317f <mem_init+0x1db3>
f010315b:	c7 44 24 0c 5e 78 10 	movl   $0xf010785e,0xc(%esp)
f0103162:	f0 
f0103163:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010316a:	f0 
f010316b:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103172:	00 
f0103173:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010317a:	e8 c1 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010317f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103186:	e8 47 de ff ff       	call   f0100fd2 <page_alloc>
f010318b:	89 c7                	mov    %eax,%edi
f010318d:	85 c0                	test   %eax,%eax
f010318f:	75 24                	jne    f01031b5 <mem_init+0x1de9>
f0103191:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0103198:	f0 
f0103199:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01031a0:	f0 
f01031a1:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f01031a8:	00 
f01031a9:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01031b0:	e8 8b ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031bc:	e8 11 de ff ff       	call   f0100fd2 <page_alloc>
f01031c1:	89 c6                	mov    %eax,%esi
f01031c3:	85 c0                	test   %eax,%eax
f01031c5:	75 24                	jne    f01031eb <mem_init+0x1e1f>
f01031c7:	c7 44 24 0c 8a 78 10 	movl   $0xf010788a,0xc(%esp)
f01031ce:	f0 
f01031cf:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01031d6:	f0 
f01031d7:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01031de:	00 
f01031df:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01031e6:	e8 55 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031eb:	89 1c 24             	mov    %ebx,(%esp)
f01031ee:	e8 6a de ff ff       	call   f010105d <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01031f3:	89 f8                	mov    %edi,%eax
f01031f5:	e8 89 d8 ff ff       	call   f0100a83 <page2kva>
f01031fa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103201:	00 
f0103202:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103209:	00 
f010320a:	89 04 24             	mov    %eax,(%esp)
f010320d:	e8 d5 29 00 00       	call   f0105be7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103212:	89 f0                	mov    %esi,%eax
f0103214:	e8 6a d8 ff ff       	call   f0100a83 <page2kva>
f0103219:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103220:	00 
f0103221:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103228:	00 
f0103229:	89 04 24             	mov    %eax,(%esp)
f010322c:	e8 b6 29 00 00       	call   f0105be7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103231:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103238:	00 
f0103239:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103240:	00 
f0103241:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103245:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010324a:	89 04 24             	mov    %eax,(%esp)
f010324d:	e8 72 e0 ff ff       	call   f01012c4 <page_insert>
	assert(pp1->pp_ref == 1);
f0103252:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103257:	74 24                	je     f010327d <mem_init+0x1eb1>
f0103259:	c7 44 24 0c 5b 79 10 	movl   $0xf010795b,0xc(%esp)
f0103260:	f0 
f0103261:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0103268:	f0 
f0103269:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103270:	00 
f0103271:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0103278:	e8 c3 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010327d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103284:	01 01 01 
f0103287:	74 24                	je     f01032ad <mem_init+0x1ee1>
f0103289:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f0103290:	f0 
f0103291:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0103298:	f0 
f0103299:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01032a0:	00 
f01032a1:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01032a8:	e8 93 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01032ad:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032b4:	00 
f01032b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032bc:	00 
f01032bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032c1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01032c6:	89 04 24             	mov    %eax,(%esp)
f01032c9:	e8 f6 df ff ff       	call   f01012c4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032ce:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032d5:	02 02 02 
f01032d8:	74 24                	je     f01032fe <mem_init+0x1f32>
f01032da:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f01032e1:	f0 
f01032e2:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01032e9:	f0 
f01032ea:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f01032f1:	00 
f01032f2:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01032f9:	e8 42 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032fe:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103303:	74 24                	je     f0103329 <mem_init+0x1f5d>
f0103305:	c7 44 24 0c 7d 79 10 	movl   $0xf010797d,0xc(%esp)
f010330c:	f0 
f010330d:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0103314:	f0 
f0103315:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010331c:	00 
f010331d:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0103324:	e8 17 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103329:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010332e:	74 24                	je     f0103354 <mem_init+0x1f88>
f0103330:	c7 44 24 0c e7 79 10 	movl   $0xf01079e7,0xc(%esp)
f0103337:	f0 
f0103338:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010333f:	f0 
f0103340:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103347:	00 
f0103348:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010334f:	e8 ec cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103354:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010335b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010335e:	89 f0                	mov    %esi,%eax
f0103360:	e8 1e d7 ff ff       	call   f0100a83 <page2kva>
f0103365:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010336b:	74 24                	je     f0103391 <mem_init+0x1fc5>
f010336d:	c7 44 24 0c cc 76 10 	movl   $0xf01076cc,0xc(%esp)
f0103374:	f0 
f0103375:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f010337c:	f0 
f010337d:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103384:	00 
f0103385:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010338c:	e8 af cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103391:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103398:	00 
f0103399:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010339e:	89 04 24             	mov    %eax,(%esp)
f01033a1:	e8 c5 de ff ff       	call   f010126b <page_remove>
	assert(pp2->pp_ref == 0);
f01033a6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01033ab:	74 24                	je     f01033d1 <mem_init+0x2005>
f01033ad:	c7 44 24 0c b5 79 10 	movl   $0xf01079b5,0xc(%esp)
f01033b4:	f0 
f01033b5:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01033bc:	f0 
f01033bd:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033c4:	00 
f01033c5:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f01033cc:	e8 6f cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033d1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033d6:	8b 08                	mov    (%eax),%ecx
f01033d8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033de:	89 da                	mov    %ebx,%edx
f01033e0:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01033e6:	c1 fa 03             	sar    $0x3,%edx
f01033e9:	c1 e2 0c             	shl    $0xc,%edx
f01033ec:	39 d1                	cmp    %edx,%ecx
f01033ee:	74 24                	je     f0103414 <mem_init+0x2048>
f01033f0:	c7 44 24 0c 54 70 10 	movl   $0xf0107054,0xc(%esp)
f01033f7:	f0 
f01033f8:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01033ff:	f0 
f0103400:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0103407:	00 
f0103408:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f010340f:	e8 2c cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103414:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010341a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010341f:	74 24                	je     f0103445 <mem_init+0x2079>
f0103421:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f0103428:	f0 
f0103429:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0103430:	f0 
f0103431:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103438:	00 
f0103439:	c7 04 24 67 77 10 f0 	movl   $0xf0107767,(%esp)
f0103440:	e8 fb cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103445:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010344b:	89 1c 24             	mov    %ebx,(%esp)
f010344e:	e8 0a dc ff ff       	call   f010105d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103453:	c7 04 24 f8 76 10 f0 	movl   $0xf01076f8,(%esp)
f010345a:	e8 13 0b 00 00       	call   f0103f72 <cprintf>
f010345f:	eb 1c                	jmp    f010347d <mem_init+0x20b1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103461:	89 da                	mov    %ebx,%edx
f0103463:	89 f8                	mov    %edi,%eax
f0103465:	e8 5e d6 ff ff       	call   f0100ac8 <check_va2pa>
f010346a:	e9 0c fb ff ff       	jmp    f0102f7b <mem_init+0x1baf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010346f:	89 da                	mov    %ebx,%edx
f0103471:	89 f8                	mov    %edi,%eax
f0103473:	e8 50 d6 ff ff       	call   f0100ac8 <check_va2pa>
f0103478:	e9 0d fa ff ff       	jmp    f0102e8a <mem_init+0x1abe>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010347d:	83 c4 4c             	add    $0x4c,%esp
f0103480:	5b                   	pop    %ebx
f0103481:	5e                   	pop    %esi
f0103482:	5f                   	pop    %edi
f0103483:	5d                   	pop    %ebp
f0103484:	c3                   	ret    

f0103485 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103485:	55                   	push   %ebp
f0103486:	89 e5                	mov    %esp,%ebp
f0103488:	57                   	push   %edi
f0103489:	56                   	push   %esi
f010348a:	53                   	push   %ebx
f010348b:	83 ec 1c             	sub    $0x1c,%esp
f010348e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103491:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103497:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034a0:	03 45 10             	add    0x10(%ebp),%eax
f01034a3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f01034b0:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034b6:	76 5d                	jbe    f0103515 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f01034b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034bb:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
        return -E_FAULT;
f01034c0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034c5:	eb 58                	jmp    f010351f <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034ce:	00 
f01034cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034d3:	8b 47 60             	mov    0x60(%edi),%eax
f01034d6:	89 04 24             	mov    %eax,(%esp)
f01034d9:	e8 e2 db ff ff       	call   f01010c0 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034de:	85 c0                	test   %eax,%eax
f01034e0:	74 0c                	je     f01034ee <user_mem_check+0x69>
f01034e2:	8b 00                	mov    (%eax),%eax
f01034e4:	a8 01                	test   $0x1,%al
f01034e6:	74 06                	je     f01034ee <user_mem_check+0x69>
f01034e8:	21 f0                	and    %esi,%eax
f01034ea:	39 c6                	cmp    %eax,%esi
f01034ec:	74 21                	je     f010350f <user_mem_check+0x8a>
        {
            if (addr < va)
f01034ee:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034f1:	76 0f                	jbe    f0103502 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f6:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034fb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103500:	eb 1d                	jmp    f010351f <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f0103502:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
            }
            
            return -E_FAULT;
f0103508:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010350d:	eb 10                	jmp    f010351f <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f010350f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103515:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103518:	72 ad                	jb     f01034c7 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f010351a:	b8 00 00 00 00       	mov    $0x0,%eax

}
f010351f:	83 c4 1c             	add    $0x1c,%esp
f0103522:	5b                   	pop    %ebx
f0103523:	5e                   	pop    %esi
f0103524:	5f                   	pop    %edi
f0103525:	5d                   	pop    %ebp
f0103526:	c3                   	ret    

f0103527 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103527:	55                   	push   %ebp
f0103528:	89 e5                	mov    %esp,%ebp
f010352a:	53                   	push   %ebx
f010352b:	83 ec 14             	sub    $0x14,%esp
f010352e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103531:	8b 45 14             	mov    0x14(%ebp),%eax
f0103534:	83 c8 04             	or     $0x4,%eax
f0103537:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010353b:	8b 45 10             	mov    0x10(%ebp),%eax
f010353e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103542:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103545:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103549:	89 1c 24             	mov    %ebx,(%esp)
f010354c:	e8 34 ff ff ff       	call   f0103485 <user_mem_check>
f0103551:	85 c0                	test   %eax,%eax
f0103553:	79 24                	jns    f0103579 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103555:	a1 3c b2 22 f0       	mov    0xf022b23c,%eax
f010355a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010355e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103561:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103565:	c7 04 24 24 77 10 f0 	movl   $0xf0107724,(%esp)
f010356c:	e8 01 0a 00 00       	call   f0103f72 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103571:	89 1c 24             	mov    %ebx,(%esp)
f0103574:	e8 02 07 00 00       	call   f0103c7b <env_destroy>
	}
}
f0103579:	83 c4 14             	add    $0x14,%esp
f010357c:	5b                   	pop    %ebx
f010357d:	5d                   	pop    %ebp
f010357e:	c3                   	ret    

f010357f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010357f:	55                   	push   %ebp
f0103580:	89 e5                	mov    %esp,%ebp
f0103582:	57                   	push   %edi
f0103583:	56                   	push   %esi
f0103584:	53                   	push   %ebx
f0103585:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f0103588:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f010358b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103592:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103597:	89 d1                	mov    %edx,%ecx
f0103599:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010359f:	29 c8                	sub    %ecx,%eax
f01035a1:	c1 e8 0c             	shr    $0xc,%eax
f01035a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f01035a7:	89 d6                	mov    %edx,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f01035a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035ae:	eb 6d                	jmp    f010361d <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f01035b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035b7:	e8 16 da ff ff       	call   f0100fd2 <page_alloc>
		if(newPage == 0)
f01035bc:	85 c0                	test   %eax,%eax
f01035be:	75 1c                	jne    f01035dc <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f01035c0:	c7 44 24 08 84 7a 10 	movl   $0xf0107a84,0x8(%esp)
f01035c7:	f0 
f01035c8:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01035cf:	00 
f01035d0:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f01035d7:	e8 64 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035dc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035e3:	00 
f01035e4:	89 74 24 08          	mov    %esi,0x8(%esp)
f01035e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ec:	89 3c 24             	mov    %edi,(%esp)
f01035ef:	e8 d0 dc ff ff       	call   f01012c4 <page_insert>
f01035f4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f01035fa:	85 c0                	test   %eax,%eax
f01035fc:	74 1c                	je     f010361a <region_alloc+0x9b>
			panic("page_insert fail\n");
f01035fe:	c7 44 24 08 be 7a 10 	movl   $0xf0107abe,0x8(%esp)
f0103605:	f0 
f0103606:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f010360d:	00 
f010360e:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103615:	e8 26 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010361a:	83 c3 01             	add    $0x1,%ebx
f010361d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103620:	7c 8e                	jl     f01035b0 <region_alloc+0x31>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103622:	83 c4 2c             	add    $0x2c,%esp
f0103625:	5b                   	pop    %ebx
f0103626:	5e                   	pop    %esi
f0103627:	5f                   	pop    %edi
f0103628:	5d                   	pop    %ebp
f0103629:	c3                   	ret    

f010362a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010362a:	55                   	push   %ebp
f010362b:	89 e5                	mov    %esp,%ebp
f010362d:	56                   	push   %esi
f010362e:	53                   	push   %ebx
f010362f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103632:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103635:	85 c0                	test   %eax,%eax
f0103637:	75 1a                	jne    f0103653 <envid2env+0x29>
		*env_store = curenv;
f0103639:	e8 fb 2b 00 00       	call   f0106239 <cpunum>
f010363e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103641:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010364a:	89 01                	mov    %eax,(%ecx)
		return 0;
f010364c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103651:	eb 70                	jmp    f01036c3 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103653:	89 c3                	mov    %eax,%ebx
f0103655:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010365b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010365e:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103664:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103668:	74 05                	je     f010366f <envid2env+0x45>
f010366a:	39 43 48             	cmp    %eax,0x48(%ebx)
f010366d:	74 10                	je     f010367f <envid2env+0x55>
		*env_store = 0;
f010366f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103672:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103678:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010367d:	eb 44                	jmp    f01036c3 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010367f:	84 d2                	test   %dl,%dl
f0103681:	74 36                	je     f01036b9 <envid2env+0x8f>
f0103683:	e8 b1 2b 00 00       	call   f0106239 <cpunum>
f0103688:	6b c0 74             	imul   $0x74,%eax,%eax
f010368b:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103691:	74 26                	je     f01036b9 <envid2env+0x8f>
f0103693:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103696:	e8 9e 2b 00 00       	call   f0106239 <cpunum>
f010369b:	6b c0 74             	imul   $0x74,%eax,%eax
f010369e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01036a4:	3b 70 48             	cmp    0x48(%eax),%esi
f01036a7:	74 10                	je     f01036b9 <envid2env+0x8f>
		*env_store = 0;
f01036a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036b2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036b7:	eb 0a                	jmp    f01036c3 <envid2env+0x99>
	}

	*env_store = e;
f01036b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036bc:	89 18                	mov    %ebx,(%eax)
	return 0;
f01036be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036c3:	5b                   	pop    %ebx
f01036c4:	5e                   	pop    %esi
f01036c5:	5d                   	pop    %ebp
f01036c6:	c3                   	ret    

f01036c7 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036c7:	55                   	push   %ebp
f01036c8:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036ca:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f01036cf:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036d2:	b8 23 00 00 00       	mov    $0x23,%eax
f01036d7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036d9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036db:	b0 10                	mov    $0x10,%al
f01036dd:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036df:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036e1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036e3:	ea ea 36 10 f0 08 00 	ljmp   $0x8,$0xf01036ea
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036ea:	b0 00                	mov    $0x0,%al
f01036ec:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036ef:	5d                   	pop    %ebp
f01036f0:	c3                   	ret    

f01036f1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036f1:	55                   	push   %ebp
f01036f2:	89 e5                	mov    %esp,%ebp
f01036f4:	56                   	push   %esi
f01036f5:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036f6:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
f01036fc:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103702:	ba 00 04 00 00       	mov    $0x400,%edx
f0103707:	b9 00 00 00 00       	mov    $0x0,%ecx
f010370c:	89 c3                	mov    %eax,%ebx
f010370e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103715:	89 48 44             	mov    %ecx,0x44(%eax)
f0103718:	83 e8 7c             	sub    $0x7c,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f010371b:	83 ea 01             	sub    $0x1,%edx
f010371e:	74 04                	je     f0103724 <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103720:	89 d9                	mov    %ebx,%ecx
f0103722:	eb e8                	jmp    f010370c <env_init+0x1b>
f0103724:	89 35 4c b2 22 f0    	mov    %esi,0xf022b24c
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010372a:	e8 98 ff ff ff       	call   f01036c7 <env_init_percpu>
}
f010372f:	5b                   	pop    %ebx
f0103730:	5e                   	pop    %esi
f0103731:	5d                   	pop    %ebp
f0103732:	c3                   	ret    

f0103733 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103733:	55                   	push   %ebp
f0103734:	89 e5                	mov    %esp,%ebp
f0103736:	53                   	push   %ebx
f0103737:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010373a:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f0103740:	85 db                	test   %ebx,%ebx
f0103742:	0f 84 a7 01 00 00    	je     f01038ef <env_alloc+0x1bc>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103748:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010374f:	e8 7e d8 ff ff       	call   f0100fd2 <page_alloc>
f0103754:	85 c0                	test   %eax,%eax
f0103756:	0f 84 9a 01 00 00    	je     f01038f6 <env_alloc+0x1c3>
f010375c:	89 c2                	mov    %eax,%edx
f010375e:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103764:	c1 fa 03             	sar    $0x3,%edx
f0103767:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010376a:	89 d1                	mov    %edx,%ecx
f010376c:	c1 e9 0c             	shr    $0xc,%ecx
f010376f:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0103775:	72 20                	jb     f0103797 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103777:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010377b:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0103782:	f0 
f0103783:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010378a:	00 
f010378b:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0103792:	e8 a9 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103797:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010379d:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f01037a0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037ac:	00 
f01037ad:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01037b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037b6:	8b 43 60             	mov    0x60(%ebx),%eax
f01037b9:	89 04 24             	mov    %eax,(%esp)
f01037bc:	e8 db 24 00 00       	call   f0105c9c <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037c1:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037c8:	00 
f01037c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037d0:	00 
f01037d1:	8b 43 60             	mov    0x60(%ebx),%eax
f01037d4:	89 04 24             	mov    %eax,(%esp)
f01037d7:	e8 0b 24 00 00       	call   f0105be7 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037dc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037e4:	77 20                	ja     f0103806 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ea:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f01037f1:	f0 
f01037f2:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01037f9:	00 
f01037fa:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103801:	e8 3a c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103806:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010380c:	83 ca 05             	or     $0x5,%edx
f010380f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103815:	8b 43 48             	mov    0x48(%ebx),%eax
f0103818:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010381d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103822:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103827:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010382a:	89 da                	mov    %ebx,%edx
f010382c:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f0103832:	c1 fa 02             	sar    $0x2,%edx
f0103835:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010383b:	09 d0                	or     %edx,%eax
f010383d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103840:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103843:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103846:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010384d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103854:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010385b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103862:	00 
f0103863:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010386a:	00 
f010386b:	89 1c 24             	mov    %ebx,(%esp)
f010386e:	e8 74 23 00 00       	call   f0105be7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103873:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103879:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010387f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103885:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010388c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103892:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103899:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010389d:	8b 43 44             	mov    0x44(%ebx),%eax
f01038a0:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f01038a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01038a8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038aa:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038ad:	e8 87 29 00 00       	call   f0106239 <cpunum>
f01038b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b5:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ba:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01038c1:	74 11                	je     f01038d4 <env_alloc+0x1a1>
f01038c3:	e8 71 29 00 00       	call   f0106239 <cpunum>
f01038c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038cb:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01038d1:	8b 50 48             	mov    0x48(%eax),%edx
f01038d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038d8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038dc:	c7 04 24 d0 7a 10 f0 	movl   $0xf0107ad0,(%esp)
f01038e3:	e8 8a 06 00 00       	call   f0103f72 <cprintf>
	return 0;
f01038e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01038ed:	eb 0c                	jmp    f01038fb <env_alloc+0x1c8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038ef:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038f4:	eb 05                	jmp    f01038fb <env_alloc+0x1c8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038fb:	83 c4 14             	add    $0x14,%esp
f01038fe:	5b                   	pop    %ebx
f01038ff:	5d                   	pop    %ebp
f0103900:	c3                   	ret    

f0103901 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103901:	55                   	push   %ebp
f0103902:	89 e5                	mov    %esp,%ebp
f0103904:	57                   	push   %edi
f0103905:	56                   	push   %esi
f0103906:	53                   	push   %ebx
f0103907:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f010390a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103911:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103918:	00 
f0103919:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010391c:	89 04 24             	mov    %eax,(%esp)
f010391f:	e8 0f fe ff ff       	call   f0103733 <env_alloc>
	if(r < 0)
f0103924:	85 c0                	test   %eax,%eax
f0103926:	79 1c                	jns    f0103944 <env_create+0x43>
		panic("env_create fault\n");
f0103928:	c7 44 24 08 e5 7a 10 	movl   $0xf0107ae5,0x8(%esp)
f010392f:	f0 
f0103930:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0103937:	00 
f0103938:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f010393f:	e8 fc c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103944:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103947:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010394a:	8b 45 08             	mov    0x8(%ebp),%eax
f010394d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103953:	74 1c                	je     f0103971 <env_create+0x70>
			panic("e_magic is not right\n");
f0103955:	c7 44 24 08 f7 7a 10 	movl   $0xf0107af7,0x8(%esp)
f010395c:	f0 
f010395d:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103964:	00 
f0103965:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f010396c:	e8 cf c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103971:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103974:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103977:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010397c:	77 20                	ja     f010399e <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010397e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103982:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103989:	f0 
f010398a:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103991:	00 
f0103992:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103999:	e8 a2 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010399e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039a3:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f01039a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a9:	89 c3                	mov    %eax,%ebx
f01039ab:	03 58 1c             	add    0x1c(%eax),%ebx
f01039ae:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039b2:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f01039b5:	be 01 00 00 00       	mov    $0x1,%esi
f01039ba:	eb 54                	jmp    f0103a10 <env_create+0x10f>
		int i=0;
		for(; i<num; i++){
			ph++;
f01039bc:	83 c3 20             	add    $0x20,%ebx
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039bf:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039c2:	75 49                	jne    f0103a0d <env_create+0x10c>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039c4:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039c7:	8b 53 08             	mov    0x8(%ebx),%edx
f01039ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039cd:	e8 ad fb ff ff       	call   f010357f <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039d2:	8b 43 10             	mov    0x10(%ebx),%eax
f01039d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01039dc:	03 43 04             	add    0x4(%ebx),%eax
f01039df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039e3:	8b 43 08             	mov    0x8(%ebx),%eax
f01039e6:	89 04 24             	mov    %eax,(%esp)
f01039e9:	e8 46 22 00 00       	call   f0105c34 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01039ee:	8b 43 10             	mov    0x10(%ebx),%eax
f01039f1:	8b 53 14             	mov    0x14(%ebx),%edx
f01039f4:	29 c2                	sub    %eax,%edx
f01039f6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a01:	00 
f0103a02:	03 43 08             	add    0x8(%ebx),%eax
f0103a05:	89 04 24             	mov    %eax,(%esp)
f0103a08:	e8 da 21 00 00       	call   f0105be7 <memset>
f0103a0d:	83 c6 01             	add    $0x1,%esi

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a10:	39 fe                	cmp    %edi,%esi
f0103a12:	75 a8                	jne    f01039bc <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a14:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a17:	8b 40 18             	mov    0x18(%eax),%eax
f0103a1a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a1d:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a20:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a25:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a2a:	89 f8                	mov    %edi,%eax
f0103a2c:	e8 4e fb ff ff       	call   f010357f <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a31:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a36:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a3b:	77 20                	ja     f0103a5d <env_create+0x15c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a41:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103a48:	f0 
f0103a49:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103a50:	00 
f0103a51:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103a58:	e8 e3 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a5d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a62:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a68:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a6b:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a6e:	83 c4 3c             	add    $0x3c,%esp
f0103a71:	5b                   	pop    %ebx
f0103a72:	5e                   	pop    %esi
f0103a73:	5f                   	pop    %edi
f0103a74:	5d                   	pop    %ebp
f0103a75:	c3                   	ret    

f0103a76 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a76:	55                   	push   %ebp
f0103a77:	89 e5                	mov    %esp,%ebp
f0103a79:	57                   	push   %edi
f0103a7a:	56                   	push   %esi
f0103a7b:	53                   	push   %ebx
f0103a7c:	83 ec 2c             	sub    $0x2c,%esp
f0103a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a82:	e8 b2 27 00 00       	call   f0106239 <cpunum>
f0103a87:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a8a:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0103a90:	75 34                	jne    f0103ac6 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a92:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a97:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a9c:	77 20                	ja     f0103abe <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aa2:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103aa9:	f0 
f0103aaa:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103ab1:	00 
f0103ab2:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103ab9:	e8 82 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103abe:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ac3:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ac6:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103ac9:	e8 6b 27 00 00       	call   f0106239 <cpunum>
f0103ace:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ad1:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ad6:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0103add:	74 11                	je     f0103af0 <env_free+0x7a>
f0103adf:	e8 55 27 00 00       	call   f0106239 <cpunum>
f0103ae4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103aed:	8b 40 48             	mov    0x48(%eax),%eax
f0103af0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103af4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af8:	c7 04 24 0d 7b 10 f0 	movl   $0xf0107b0d,(%esp)
f0103aff:	e8 6e 04 00 00       	call   f0103f72 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b04:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103b0b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b0e:	89 c8                	mov    %ecx,%eax
f0103b10:	c1 e0 02             	shl    $0x2,%eax
f0103b13:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b16:	8b 47 60             	mov    0x60(%edi),%eax
f0103b19:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b1c:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b22:	0f 84 b7 00 00 00    	je     f0103bdf <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b28:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b2e:	89 f0                	mov    %esi,%eax
f0103b30:	c1 e8 0c             	shr    $0xc,%eax
f0103b33:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b36:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103b3c:	72 20                	jb     f0103b5e <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b3e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b42:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0103b49:	f0 
f0103b4a:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103b51:	00 
f0103b52:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103b59:	e8 e2 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b61:	c1 e0 16             	shl    $0x16,%eax
f0103b64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b67:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b6c:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b73:	01 
f0103b74:	74 17                	je     f0103b8d <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b76:	89 d8                	mov    %ebx,%eax
f0103b78:	c1 e0 0c             	shl    $0xc,%eax
f0103b7b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b82:	8b 47 60             	mov    0x60(%edi),%eax
f0103b85:	89 04 24             	mov    %eax,(%esp)
f0103b88:	e8 de d6 ff ff       	call   f010126b <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b8d:	83 c3 01             	add    $0x1,%ebx
f0103b90:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b96:	75 d4                	jne    f0103b6c <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b98:	8b 47 60             	mov    0x60(%edi),%eax
f0103b9b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b9e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ba5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ba8:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103bae:	72 1c                	jb     f0103bcc <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103bb0:	c7 44 24 08 00 6f 10 	movl   $0xf0106f00,0x8(%esp)
f0103bb7:	f0 
f0103bb8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bbf:	00 
f0103bc0:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0103bc7:	e8 74 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bcc:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0103bd1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bd4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103bd7:	89 04 24             	mov    %eax,(%esp)
f0103bda:	e8 be d4 ff ff       	call   f010109d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bdf:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103be3:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bea:	0f 85 1b ff ff ff    	jne    f0103b0b <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bf0:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bf3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bf8:	77 20                	ja     f0103c1a <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bfe:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103c05:	f0 
f0103c06:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103c0d:	00 
f0103c0e:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103c15:	e8 26 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c1a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c21:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c26:	c1 e8 0c             	shr    $0xc,%eax
f0103c29:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103c2f:	72 1c                	jb     f0103c4d <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103c31:	c7 44 24 08 00 6f 10 	movl   $0xf0106f00,0x8(%esp)
f0103c38:	f0 
f0103c39:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c40:	00 
f0103c41:	c7 04 24 59 77 10 f0 	movl   $0xf0107759,(%esp)
f0103c48:	e8 f3 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c4d:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0103c53:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c56:	89 04 24             	mov    %eax,(%esp)
f0103c59:	e8 3f d4 ff ff       	call   f010109d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c5e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c65:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f0103c6a:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c6d:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f0103c73:	83 c4 2c             	add    $0x2c,%esp
f0103c76:	5b                   	pop    %ebx
f0103c77:	5e                   	pop    %esi
f0103c78:	5f                   	pop    %edi
f0103c79:	5d                   	pop    %ebp
f0103c7a:	c3                   	ret    

f0103c7b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c7b:	55                   	push   %ebp
f0103c7c:	89 e5                	mov    %esp,%ebp
f0103c7e:	53                   	push   %ebx
f0103c7f:	83 ec 14             	sub    $0x14,%esp
f0103c82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c85:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c89:	75 19                	jne    f0103ca4 <env_destroy+0x29>
f0103c8b:	e8 a9 25 00 00       	call   f0106239 <cpunum>
f0103c90:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c93:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103c99:	74 09                	je     f0103ca4 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c9b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ca2:	eb 2f                	jmp    f0103cd3 <env_destroy+0x58>
	}

	env_free(e);
f0103ca4:	89 1c 24             	mov    %ebx,(%esp)
f0103ca7:	e8 ca fd ff ff       	call   f0103a76 <env_free>

	if (curenv == e) {
f0103cac:	e8 88 25 00 00       	call   f0106239 <cpunum>
f0103cb1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb4:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103cba:	75 17                	jne    f0103cd3 <env_destroy+0x58>
		curenv = NULL;
f0103cbc:	e8 78 25 00 00       	call   f0106239 <cpunum>
f0103cc1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc4:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0103ccb:	00 00 00 
		sched_yield();
f0103cce:	e8 b6 0d 00 00       	call   f0104a89 <sched_yield>
	}
}
f0103cd3:	83 c4 14             	add    $0x14,%esp
f0103cd6:	5b                   	pop    %ebx
f0103cd7:	5d                   	pop    %ebp
f0103cd8:	c3                   	ret    

f0103cd9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cd9:	55                   	push   %ebp
f0103cda:	89 e5                	mov    %esp,%ebp
f0103cdc:	53                   	push   %ebx
f0103cdd:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ce0:	e8 54 25 00 00       	call   f0106239 <cpunum>
f0103ce5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce8:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103cee:	e8 46 25 00 00       	call   f0106239 <cpunum>
f0103cf3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103cf6:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cf9:	61                   	popa   
f0103cfa:	07                   	pop    %es
f0103cfb:	1f                   	pop    %ds
f0103cfc:	83 c4 08             	add    $0x8,%esp
f0103cff:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d00:	c7 44 24 08 23 7b 10 	movl   $0xf0107b23,0x8(%esp)
f0103d07:	f0 
f0103d08:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0103d0f:	00 
f0103d10:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103d17:	e8 24 c3 ff ff       	call   f0100040 <_panic>

f0103d1c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d1c:	55                   	push   %ebp
f0103d1d:	89 e5                	mov    %esp,%ebp
f0103d1f:	53                   	push   %ebx
f0103d20:	83 ec 14             	sub    $0x14,%esp
f0103d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d26:	e8 0e 25 00 00       	call   f0106239 <cpunum>
f0103d2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2e:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103d35:	75 10                	jne    f0103d47 <env_run+0x2b>
		curenv = e;
f0103d37:	e8 fd 24 00 00       	call   f0106239 <cpunum>
f0103d3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3f:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
f0103d45:	eb 29                	jmp    f0103d70 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d47:	e8 ed 24 00 00       	call   f0106239 <cpunum>
f0103d4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d4f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d55:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d59:	75 15                	jne    f0103d70 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d5b:	e8 d9 24 00 00       	call   f0106239 <cpunum>
f0103d60:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d63:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d69:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d70:	e8 c4 24 00 00       	call   f0106239 <cpunum>
f0103d75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d78:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d7e:	e8 b6 24 00 00       	call   f0106239 <cpunum>
f0103d83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d86:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d8c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d93:	e8 a1 24 00 00       	call   f0106239 <cpunum>
f0103d98:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d9b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103da1:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103da5:	e8 8f 24 00 00       	call   f0106239 <cpunum>
f0103daa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dad:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103db3:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103db6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dbb:	77 20                	ja     f0103ddd <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dc1:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0103dc8:	f0 
f0103dc9:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0103dd0:	00 
f0103dd1:	c7 04 24 b3 7a 10 f0 	movl   $0xf0107ab3,(%esp)
f0103dd8:	e8 63 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ddd:	05 00 00 00 10       	add    $0x10000000,%eax
f0103de2:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103de5:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0103dec:	e8 72 27 00 00       	call   f0106563 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103df1:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103df3:	e8 41 24 00 00       	call   f0106239 <cpunum>
f0103df8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dfb:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103e01:	89 04 24             	mov    %eax,(%esp)
f0103e04:	e8 d0 fe ff ff       	call   f0103cd9 <env_pop_tf>

f0103e09 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e09:	55                   	push   %ebp
f0103e0a:	89 e5                	mov    %esp,%ebp
f0103e0c:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e10:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e15:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e16:	b2 71                	mov    $0x71,%dl
f0103e18:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e19:	0f b6 c0             	movzbl %al,%eax
}
f0103e1c:	5d                   	pop    %ebp
f0103e1d:	c3                   	ret    

f0103e1e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e1e:	55                   	push   %ebp
f0103e1f:	89 e5                	mov    %esp,%ebp
f0103e21:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e25:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e2a:	ee                   	out    %al,(%dx)
f0103e2b:	b2 71                	mov    $0x71,%dl
f0103e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e30:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e31:	5d                   	pop    %ebp
f0103e32:	c3                   	ret    

f0103e33 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e33:	55                   	push   %ebp
f0103e34:	89 e5                	mov    %esp,%ebp
f0103e36:	56                   	push   %esi
f0103e37:	53                   	push   %ebx
f0103e38:	83 ec 10             	sub    $0x10,%esp
f0103e3b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e3e:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103e44:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f0103e4b:	74 4e                	je     f0103e9b <irq_setmask_8259A+0x68>
f0103e4d:	89 c6                	mov    %eax,%esi
f0103e4f:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e54:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e55:	66 c1 e8 08          	shr    $0x8,%ax
f0103e59:	b2 a1                	mov    $0xa1,%dl
f0103e5b:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e5c:	c7 04 24 2f 7b 10 f0 	movl   $0xf0107b2f,(%esp)
f0103e63:	e8 0a 01 00 00       	call   f0103f72 <cprintf>
	for (i = 0; i < 16; i++)
f0103e68:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e6d:	0f b7 f6             	movzwl %si,%esi
f0103e70:	f7 d6                	not    %esi
f0103e72:	0f a3 de             	bt     %ebx,%esi
f0103e75:	73 10                	jae    f0103e87 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103e77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e7b:	c7 04 24 f3 7f 10 f0 	movl   $0xf0107ff3,(%esp)
f0103e82:	e8 eb 00 00 00       	call   f0103f72 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e87:	83 c3 01             	add    $0x1,%ebx
f0103e8a:	83 fb 10             	cmp    $0x10,%ebx
f0103e8d:	75 e3                	jne    f0103e72 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e8f:	c7 04 24 50 7a 10 f0 	movl   $0xf0107a50,(%esp)
f0103e96:	e8 d7 00 00 00       	call   f0103f72 <cprintf>
}
f0103e9b:	83 c4 10             	add    $0x10,%esp
f0103e9e:	5b                   	pop    %ebx
f0103e9f:	5e                   	pop    %esi
f0103ea0:	5d                   	pop    %ebp
f0103ea1:	c3                   	ret    

f0103ea2 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103ea2:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f0103ea9:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103eb3:	ee                   	out    %al,(%dx)
f0103eb4:	b2 a1                	mov    $0xa1,%dl
f0103eb6:	ee                   	out    %al,(%dx)
f0103eb7:	b2 20                	mov    $0x20,%dl
f0103eb9:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ebe:	ee                   	out    %al,(%dx)
f0103ebf:	b2 21                	mov    $0x21,%dl
f0103ec1:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ec6:	ee                   	out    %al,(%dx)
f0103ec7:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ecc:	ee                   	out    %al,(%dx)
f0103ecd:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ed2:	ee                   	out    %al,(%dx)
f0103ed3:	b2 a0                	mov    $0xa0,%dl
f0103ed5:	b8 11 00 00 00       	mov    $0x11,%eax
f0103eda:	ee                   	out    %al,(%dx)
f0103edb:	b2 a1                	mov    $0xa1,%dl
f0103edd:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ee2:	ee                   	out    %al,(%dx)
f0103ee3:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ee8:	ee                   	out    %al,(%dx)
f0103ee9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eee:	ee                   	out    %al,(%dx)
f0103eef:	b2 20                	mov    $0x20,%dl
f0103ef1:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ef6:	ee                   	out    %al,(%dx)
f0103ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103efc:	ee                   	out    %al,(%dx)
f0103efd:	b2 a0                	mov    $0xa0,%dl
f0103eff:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f04:	ee                   	out    %al,(%dx)
f0103f05:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f0a:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f0b:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103f12:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f16:	74 12                	je     f0103f2a <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f18:	55                   	push   %ebp
f0103f19:	89 e5                	mov    %esp,%ebp
f0103f1b:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103f1e:	0f b7 c0             	movzwl %ax,%eax
f0103f21:	89 04 24             	mov    %eax,(%esp)
f0103f24:	e8 0a ff ff ff       	call   f0103e33 <irq_setmask_8259A>
}
f0103f29:	c9                   	leave  
f0103f2a:	f3 c3                	repz ret 

f0103f2c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f2c:	55                   	push   %ebp
f0103f2d:	89 e5                	mov    %esp,%ebp
f0103f2f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f32:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f35:	89 04 24             	mov    %eax,(%esp)
f0103f38:	e8 5d c8 ff ff       	call   f010079a <cputchar>
	*cnt++;
}
f0103f3d:	c9                   	leave  
f0103f3e:	c3                   	ret    

f0103f3f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f3f:	55                   	push   %ebp
f0103f40:	89 e5                	mov    %esp,%ebp
f0103f42:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f53:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f61:	c7 04 24 2c 3f 10 f0 	movl   $0xf0103f2c,(%esp)
f0103f68:	e8 37 15 00 00       	call   f01054a4 <vprintfmt>
	return cnt;
}
f0103f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f70:	c9                   	leave  
f0103f71:	c3                   	ret    

f0103f72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f72:	55                   	push   %ebp
f0103f73:	89 e5                	mov    %esp,%ebp
f0103f75:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f82:	89 04 24             	mov    %eax,(%esp)
f0103f85:	e8 b5 ff ff ff       	call   f0103f3f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f8a:	c9                   	leave  
f0103f8b:	c3                   	ret    
f0103f8c:	66 90                	xchg   %ax,%ax
f0103f8e:	66 90                	xchg   %ax,%ax

f0103f90 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103f99:	e8 9b 22 00 00       	call   f0106239 <cpunum>
f0103f9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa1:	0f b6 98 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103fa8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fac:	c7 04 24 43 7b 10 f0 	movl   $0xf0107b43,(%esp)
f0103fb3:	e8 ba ff ff ff       	call   f0103f72 <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fb8:	e8 7c 22 00 00       	call   f0106239 <cpunum>
f0103fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc0:	89 da                	mov    %ebx,%edx
f0103fc2:	f7 da                	neg    %edx
f0103fc4:	c1 e2 10             	shl    $0x10,%edx
f0103fc7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fcd:	89 90 30 c0 22 f0    	mov    %edx,-0xfdd3fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fd3:	e8 61 22 00 00       	call   f0106239 <cpunum>
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdb:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f0103fe2:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0103fe4:	83 c3 05             	add    $0x5,%ebx
f0103fe7:	e8 4d 22 00 00       	call   f0106239 <cpunum>
f0103fec:	89 c7                	mov    %eax,%edi
f0103fee:	e8 46 22 00 00       	call   f0106239 <cpunum>
f0103ff3:	89 c6                	mov    %eax,%esi
f0103ff5:	e8 3f 22 00 00       	call   f0106239 <cpunum>
f0103ffa:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0104001:	f0 67 00 
f0104004:	6b ff 74             	imul   $0x74,%edi,%edi
f0104007:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f010400d:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0104014:	f0 
f0104015:	6b d6 74             	imul   $0x74,%esi,%edx
f0104018:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f010401e:	c1 ea 10             	shr    $0x10,%edx
f0104021:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0104028:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010402f:	40 
f0104030:	6b c0 74             	imul   $0x74,%eax,%eax
f0104033:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f0104038:	c1 e8 18             	shr    $0x18,%eax
f010403b:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104042:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f0104049:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010404a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010404d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104050:	b8 aa 03 12 f0       	mov    $0xf01203aa,%eax
f0104055:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104058:	83 c4 1c             	add    $0x1c,%esp
f010405b:	5b                   	pop    %ebx
f010405c:	5e                   	pop    %esi
f010405d:	5f                   	pop    %edi
f010405e:	5d                   	pop    %ebp
f010405f:	c3                   	ret    

f0104060 <trap_init>:
}


void
trap_init(void)
{
f0104060:	55                   	push   %ebp
f0104061:	89 e5                	mov    %esp,%ebp
f0104063:	83 ec 08             	sub    $0x8,%esp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104066:	b8 de 48 10 f0       	mov    $0xf01048de,%eax
f010406b:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f0104071:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f0104078:	08 00 
f010407a:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f0104081:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f0104088:	c1 e8 10             	shr    $0x10,%eax
f010408b:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f0104091:	b8 e8 48 10 f0       	mov    $0xf01048e8,%eax
f0104096:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f010409c:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01040a3:	08 00 
f01040a5:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01040ac:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01040b3:	c1 e8 10             	shr    $0x10,%eax
f01040b6:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040bc:	b8 f2 48 10 f0       	mov    $0xf01048f2,%eax
f01040c1:	66 a3 70 b2 22 f0    	mov    %ax,0xf022b270
f01040c7:	66 c7 05 72 b2 22 f0 	movw   $0x8,0xf022b272
f01040ce:	08 00 
f01040d0:	c6 05 74 b2 22 f0 00 	movb   $0x0,0xf022b274
f01040d7:	c6 05 75 b2 22 f0 8e 	movb   $0x8e,0xf022b275
f01040de:	c1 e8 10             	shr    $0x10,%eax
f01040e1:	66 a3 76 b2 22 f0    	mov    %ax,0xf022b276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01040e7:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f01040ec:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f01040f2:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f01040f9:	08 00 
f01040fb:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f0104102:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f0104109:	c1 e8 10             	shr    $0x10,%eax
f010410c:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104112:	b8 06 49 10 f0       	mov    $0xf0104906,%eax
f0104117:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f010411d:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0104124:	08 00 
f0104126:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f010412d:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0104134:	c1 e8 10             	shr    $0x10,%eax
f0104137:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010413d:	b8 10 49 10 f0       	mov    $0xf0104910,%eax
f0104142:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0104148:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f010414f:	08 00 
f0104151:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0104158:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f010415f:	c1 e8 10             	shr    $0x10,%eax
f0104162:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104168:	b8 1a 49 10 f0       	mov    $0xf010491a,%eax
f010416d:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f0104173:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f010417a:	08 00 
f010417c:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f0104183:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f010418a:	c1 e8 10             	shr    $0x10,%eax
f010418d:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f0104193:	b8 24 49 10 f0       	mov    $0xf0104924,%eax
f0104198:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f010419e:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f01041a5:	08 00 
f01041a7:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f01041ae:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f01041b5:	c1 e8 10             	shr    $0x10,%eax
f01041b8:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041be:	b8 2e 49 10 f0       	mov    $0xf010492e,%eax
f01041c3:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f01041c9:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f01041d0:	08 00 
f01041d2:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f01041d9:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f01041e0:	c1 e8 10             	shr    $0x10,%eax
f01041e3:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01041e9:	b8 36 49 10 f0       	mov    $0xf0104936,%eax
f01041ee:	66 a3 a8 b2 22 f0    	mov    %ax,0xf022b2a8
f01041f4:	66 c7 05 aa b2 22 f0 	movw   $0x8,0xf022b2aa
f01041fb:	08 00 
f01041fd:	c6 05 ac b2 22 f0 00 	movb   $0x0,0xf022b2ac
f0104204:	c6 05 ad b2 22 f0 8e 	movb   $0x8e,0xf022b2ad
f010420b:	c1 e8 10             	shr    $0x10,%eax
f010420e:	66 a3 ae b2 22 f0    	mov    %ax,0xf022b2ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104214:	b8 40 49 10 f0       	mov    $0xf0104940,%eax
f0104219:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f010421f:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0104226:	08 00 
f0104228:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f010422f:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0104236:	c1 e8 10             	shr    $0x10,%eax
f0104239:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010423f:	b8 48 49 10 f0       	mov    $0xf0104948,%eax
f0104244:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f010424a:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0104251:	08 00 
f0104253:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f010425a:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0104261:	c1 e8 10             	shr    $0x10,%eax
f0104264:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010426a:	b8 50 49 10 f0       	mov    $0xf0104950,%eax
f010426f:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f0104275:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f010427c:	08 00 
f010427e:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f0104285:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f010428c:	c1 e8 10             	shr    $0x10,%eax
f010428f:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f0104295:	b8 58 49 10 f0       	mov    $0xf0104958,%eax
f010429a:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f01042a0:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f01042a7:	08 00 
f01042a9:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f01042b0:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f01042b7:	c1 e8 10             	shr    $0x10,%eax
f01042ba:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042c0:	b8 60 49 10 f0       	mov    $0xf0104960,%eax
f01042c5:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f01042cb:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f01042d2:	08 00 
f01042d4:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f01042db:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f01042e2:	c1 e8 10             	shr    $0x10,%eax
f01042e5:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01042eb:	b8 68 49 10 f0       	mov    $0xf0104968,%eax
f01042f0:	66 a3 d8 b2 22 f0    	mov    %ax,0xf022b2d8
f01042f6:	66 c7 05 da b2 22 f0 	movw   $0x8,0xf022b2da
f01042fd:	08 00 
f01042ff:	c6 05 dc b2 22 f0 00 	movb   $0x0,0xf022b2dc
f0104306:	c6 05 dd b2 22 f0 8e 	movb   $0x8e,0xf022b2dd
f010430d:	c1 e8 10             	shr    $0x10,%eax
f0104310:	66 a3 de b2 22 f0    	mov    %ax,0xf022b2de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104316:	b8 72 49 10 f0       	mov    $0xf0104972,%eax
f010431b:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0104321:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0104328:	08 00 
f010432a:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0104331:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0104338:	c1 e8 10             	shr    $0x10,%eax
f010433b:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104341:	b8 7c 49 10 f0       	mov    $0xf010497c,%eax
f0104346:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f010434c:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0104353:	08 00 
f0104355:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f010435c:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0104363:	c1 e8 10             	shr    $0x10,%eax
f0104366:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010436c:	b8 84 49 10 f0       	mov    $0xf0104984,%eax
f0104371:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f0104377:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f010437e:	08 00 
f0104380:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f0104387:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f010438e:	c1 e8 10             	shr    $0x10,%eax
f0104391:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f0104397:	b8 8e 49 10 f0       	mov    $0xf010498e,%eax
f010439c:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f01043a2:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f01043a9:	08 00 
f01043ab:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f01043b2:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f01043b9:	c1 e8 10             	shr    $0x10,%eax
f01043bc:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043c2:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f01043c7:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f01043cd:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f01043d4:	08 00 
f01043d6:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f01043dd:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f01043e4:	c1 e8 10             	shr    $0x10,%eax
f01043e7:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6




	// Per-CPU setup 
	trap_init_percpu();
f01043ed:	e8 9e fb ff ff       	call   f0103f90 <trap_init_percpu>
}
f01043f2:	c9                   	leave  
f01043f3:	c3                   	ret    

f01043f4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01043f4:	55                   	push   %ebp
f01043f5:	89 e5                	mov    %esp,%ebp
f01043f7:	53                   	push   %ebx
f01043f8:	83 ec 14             	sub    $0x14,%esp
f01043fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043fe:	8b 03                	mov    (%ebx),%eax
f0104400:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104404:	c7 04 24 51 7b 10 f0 	movl   $0xf0107b51,(%esp)
f010440b:	e8 62 fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104410:	8b 43 04             	mov    0x4(%ebx),%eax
f0104413:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104417:	c7 04 24 60 7b 10 f0 	movl   $0xf0107b60,(%esp)
f010441e:	e8 4f fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104423:	8b 43 08             	mov    0x8(%ebx),%eax
f0104426:	89 44 24 04          	mov    %eax,0x4(%esp)
f010442a:	c7 04 24 6f 7b 10 f0 	movl   $0xf0107b6f,(%esp)
f0104431:	e8 3c fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104436:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104439:	89 44 24 04          	mov    %eax,0x4(%esp)
f010443d:	c7 04 24 7e 7b 10 f0 	movl   $0xf0107b7e,(%esp)
f0104444:	e8 29 fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104449:	8b 43 10             	mov    0x10(%ebx),%eax
f010444c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104450:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0104457:	e8 16 fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010445c:	8b 43 14             	mov    0x14(%ebx),%eax
f010445f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104463:	c7 04 24 9c 7b 10 f0 	movl   $0xf0107b9c,(%esp)
f010446a:	e8 03 fb ff ff       	call   f0103f72 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010446f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104472:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104476:	c7 04 24 ab 7b 10 f0 	movl   $0xf0107bab,(%esp)
f010447d:	e8 f0 fa ff ff       	call   f0103f72 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104482:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104485:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104489:	c7 04 24 ba 7b 10 f0 	movl   $0xf0107bba,(%esp)
f0104490:	e8 dd fa ff ff       	call   f0103f72 <cprintf>
}
f0104495:	83 c4 14             	add    $0x14,%esp
f0104498:	5b                   	pop    %ebx
f0104499:	5d                   	pop    %ebp
f010449a:	c3                   	ret    

f010449b <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f010449b:	55                   	push   %ebp
f010449c:	89 e5                	mov    %esp,%ebp
f010449e:	56                   	push   %esi
f010449f:	53                   	push   %ebx
f01044a0:	83 ec 10             	sub    $0x10,%esp
f01044a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044a6:	e8 8e 1d 00 00       	call   f0106239 <cpunum>
f01044ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044b3:	c7 04 24 1e 7c 10 f0 	movl   $0xf0107c1e,(%esp)
f01044ba:	e8 b3 fa ff ff       	call   f0103f72 <cprintf>
	print_regs(&tf->tf_regs);
f01044bf:	89 1c 24             	mov    %ebx,(%esp)
f01044c2:	e8 2d ff ff ff       	call   f01043f4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044c7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044cf:	c7 04 24 3c 7c 10 f0 	movl   $0xf0107c3c,(%esp)
f01044d6:	e8 97 fa ff ff       	call   f0103f72 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044db:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e3:	c7 04 24 4f 7c 10 f0 	movl   $0xf0107c4f,(%esp)
f01044ea:	e8 83 fa ff ff       	call   f0103f72 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044ef:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01044f2:	83 f8 13             	cmp    $0x13,%eax
f01044f5:	77 09                	ja     f0104500 <print_trapframe+0x65>
		return excnames[trapno];
f01044f7:	8b 14 85 e0 7e 10 f0 	mov    -0xfef8120(,%eax,4),%edx
f01044fe:	eb 1f                	jmp    f010451f <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104500:	83 f8 30             	cmp    $0x30,%eax
f0104503:	74 15                	je     f010451a <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104505:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104508:	83 fa 0f             	cmp    $0xf,%edx
f010450b:	ba d5 7b 10 f0       	mov    $0xf0107bd5,%edx
f0104510:	b9 e8 7b 10 f0       	mov    $0xf0107be8,%ecx
f0104515:	0f 47 d1             	cmova  %ecx,%edx
f0104518:	eb 05                	jmp    f010451f <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010451a:	ba c9 7b 10 f0       	mov    $0xf0107bc9,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010451f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104523:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104527:	c7 04 24 62 7c 10 f0 	movl   $0xf0107c62,(%esp)
f010452e:	e8 3f fa ff ff       	call   f0103f72 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104533:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0104539:	75 19                	jne    f0104554 <print_trapframe+0xb9>
f010453b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010453f:	75 13                	jne    f0104554 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104541:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104544:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104548:	c7 04 24 74 7c 10 f0 	movl   $0xf0107c74,(%esp)
f010454f:	e8 1e fa ff ff       	call   f0103f72 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104554:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104557:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455b:	c7 04 24 83 7c 10 f0 	movl   $0xf0107c83,(%esp)
f0104562:	e8 0b fa ff ff       	call   f0103f72 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104567:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010456b:	75 51                	jne    f01045be <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010456d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104570:	89 c2                	mov    %eax,%edx
f0104572:	83 e2 01             	and    $0x1,%edx
f0104575:	ba f7 7b 10 f0       	mov    $0xf0107bf7,%edx
f010457a:	b9 02 7c 10 f0       	mov    $0xf0107c02,%ecx
f010457f:	0f 45 ca             	cmovne %edx,%ecx
f0104582:	89 c2                	mov    %eax,%edx
f0104584:	83 e2 02             	and    $0x2,%edx
f0104587:	ba 0e 7c 10 f0       	mov    $0xf0107c0e,%edx
f010458c:	be 14 7c 10 f0       	mov    $0xf0107c14,%esi
f0104591:	0f 44 d6             	cmove  %esi,%edx
f0104594:	83 e0 04             	and    $0x4,%eax
f0104597:	b8 19 7c 10 f0       	mov    $0xf0107c19,%eax
f010459c:	be 4e 7d 10 f0       	mov    $0xf0107d4e,%esi
f01045a1:	0f 44 c6             	cmove  %esi,%eax
f01045a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045a8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b0:	c7 04 24 91 7c 10 f0 	movl   $0xf0107c91,(%esp)
f01045b7:	e8 b6 f9 ff ff       	call   f0103f72 <cprintf>
f01045bc:	eb 0c                	jmp    f01045ca <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045be:	c7 04 24 50 7a 10 f0 	movl   $0xf0107a50,(%esp)
f01045c5:	e8 a8 f9 ff ff       	call   f0103f72 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045ca:	8b 43 30             	mov    0x30(%ebx),%eax
f01045cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d1:	c7 04 24 a0 7c 10 f0 	movl   $0xf0107ca0,(%esp)
f01045d8:	e8 95 f9 ff ff       	call   f0103f72 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045dd:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e5:	c7 04 24 af 7c 10 f0 	movl   $0xf0107caf,(%esp)
f01045ec:	e8 81 f9 ff ff       	call   f0103f72 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045f1:	8b 43 38             	mov    0x38(%ebx),%eax
f01045f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f8:	c7 04 24 c2 7c 10 f0 	movl   $0xf0107cc2,(%esp)
f01045ff:	e8 6e f9 ff ff       	call   f0103f72 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104604:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104608:	74 27                	je     f0104631 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010460a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010460d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104611:	c7 04 24 d1 7c 10 f0 	movl   $0xf0107cd1,(%esp)
f0104618:	e8 55 f9 ff ff       	call   f0103f72 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010461d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104621:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104625:	c7 04 24 e0 7c 10 f0 	movl   $0xf0107ce0,(%esp)
f010462c:	e8 41 f9 ff ff       	call   f0103f72 <cprintf>
	}
}
f0104631:	83 c4 10             	add    $0x10,%esp
f0104634:	5b                   	pop    %ebx
f0104635:	5e                   	pop    %esi
f0104636:	5d                   	pop    %ebp
f0104637:	c3                   	ret    

f0104638 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104638:	55                   	push   %ebp
f0104639:	89 e5                	mov    %esp,%ebp
f010463b:	57                   	push   %edi
f010463c:	56                   	push   %esi
f010463d:	53                   	push   %ebx
f010463e:	83 ec 1c             	sub    $0x1c,%esp
f0104641:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104644:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104647:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010464c:	75 1c                	jne    f010466a <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f010464e:	c7 44 24 08 98 7e 10 	movl   $0xf0107e98,0x8(%esp)
f0104655:	f0 
f0104656:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f010465d:	00 
f010465e:	c7 04 24 f3 7c 10 f0 	movl   $0xf0107cf3,(%esp)
f0104665:	e8 d6 b9 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010466a:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010466d:	e8 c7 1b 00 00       	call   f0106239 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104672:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104676:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f010467a:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010467d:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104683:	8b 40 48             	mov    0x48(%eax),%eax
f0104686:	89 44 24 04          	mov    %eax,0x4(%esp)
f010468a:	c7 04 24 bc 7e 10 f0 	movl   $0xf0107ebc,(%esp)
f0104691:	e8 dc f8 ff ff       	call   f0103f72 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104696:	89 1c 24             	mov    %ebx,(%esp)
f0104699:	e8 fd fd ff ff       	call   f010449b <print_trapframe>
	env_destroy(curenv);
f010469e:	e8 96 1b 00 00       	call   f0106239 <cpunum>
f01046a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a6:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01046ac:	89 04 24             	mov    %eax,(%esp)
f01046af:	e8 c7 f5 ff ff       	call   f0103c7b <env_destroy>
}
f01046b4:	83 c4 1c             	add    $0x1c,%esp
f01046b7:	5b                   	pop    %ebx
f01046b8:	5e                   	pop    %esi
f01046b9:	5f                   	pop    %edi
f01046ba:	5d                   	pop    %ebp
f01046bb:	c3                   	ret    

f01046bc <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01046bc:	55                   	push   %ebp
f01046bd:	89 e5                	mov    %esp,%ebp
f01046bf:	57                   	push   %edi
f01046c0:	56                   	push   %esi
f01046c1:	83 ec 20             	sub    $0x20,%esp
f01046c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01046c7:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01046c8:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f01046cf:	74 01                	je     f01046d2 <trap+0x16>
		asm volatile("hlt");
f01046d1:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01046d2:	e8 62 1b 00 00       	call   f0106239 <cpunum>
f01046d7:	6b d0 74             	imul   $0x74,%eax,%edx
f01046da:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01046e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01046e5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01046e9:	83 f8 02             	cmp    $0x2,%eax
f01046ec:	75 0c                	jne    f01046fa <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01046ee:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01046f5:	e8 bd 1d 00 00       	call   f01064b7 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01046fa:	9c                   	pushf  
f01046fb:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01046fc:	f6 c4 02             	test   $0x2,%ah
f01046ff:	74 24                	je     f0104725 <trap+0x69>
f0104701:	c7 44 24 0c ff 7c 10 	movl   $0xf0107cff,0xc(%esp)
f0104708:	f0 
f0104709:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0104710:	f0 
f0104711:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0104718:	00 
f0104719:	c7 04 24 f3 7c 10 f0 	movl   $0xf0107cf3,(%esp)
f0104720:	e8 1b b9 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104725:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104729:	83 e0 03             	and    $0x3,%eax
f010472c:	66 83 f8 03          	cmp    $0x3,%ax
f0104730:	0f 85 a7 00 00 00    	jne    f01047dd <trap+0x121>
f0104736:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010473d:	e8 75 1d 00 00       	call   f01064b7 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104742:	e8 f2 1a 00 00       	call   f0106239 <cpunum>
f0104747:	6b c0 74             	imul   $0x74,%eax,%eax
f010474a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104751:	75 24                	jne    f0104777 <trap+0xbb>
f0104753:	c7 44 24 0c 18 7d 10 	movl   $0xf0107d18,0xc(%esp)
f010475a:	f0 
f010475b:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f0104762:	f0 
f0104763:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f010476a:	00 
f010476b:	c7 04 24 f3 7c 10 f0 	movl   $0xf0107cf3,(%esp)
f0104772:	e8 c9 b8 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104777:	e8 bd 1a 00 00       	call   f0106239 <cpunum>
f010477c:	6b c0 74             	imul   $0x74,%eax,%eax
f010477f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104785:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104789:	75 2d                	jne    f01047b8 <trap+0xfc>
			env_free(curenv);
f010478b:	e8 a9 1a 00 00       	call   f0106239 <cpunum>
f0104790:	6b c0 74             	imul   $0x74,%eax,%eax
f0104793:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104799:	89 04 24             	mov    %eax,(%esp)
f010479c:	e8 d5 f2 ff ff       	call   f0103a76 <env_free>
			curenv = NULL;
f01047a1:	e8 93 1a 00 00       	call   f0106239 <cpunum>
f01047a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a9:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01047b0:	00 00 00 
			sched_yield();
f01047b3:	e8 d1 02 00 00       	call   f0104a89 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01047b8:	e8 7c 1a 00 00       	call   f0106239 <cpunum>
f01047bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c0:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01047c6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047cb:	89 c7                	mov    %eax,%edi
f01047cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01047cf:	e8 65 1a 00 00       	call   f0106239 <cpunum>
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d7:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01047dd:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f01047e3:	8b 46 28             	mov    0x28(%esi),%eax
f01047e6:	83 f8 0e             	cmp    $0xe,%eax
f01047e9:	75 0d                	jne    f01047f8 <trap+0x13c>
		page_fault_handler(tf);
f01047eb:	89 34 24             	mov    %esi,(%esp)
f01047ee:	e8 45 fe ff ff       	call   f0104638 <page_fault_handler>
f01047f3:	e9 a5 00 00 00       	jmp    f010489d <trap+0x1e1>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f01047f8:	83 f8 03             	cmp    $0x3,%eax
f01047fb:	75 0d                	jne    f010480a <trap+0x14e>
		monitor(tf);
f01047fd:	89 34 24             	mov    %esi,(%esp)
f0104800:	e8 e4 c0 ff ff       	call   f01008e9 <monitor>
f0104805:	e9 93 00 00 00       	jmp    f010489d <trap+0x1e1>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f010480a:	83 f8 30             	cmp    $0x30,%eax
f010480d:	75 32                	jne    f0104841 <trap+0x185>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f010480f:	8b 46 04             	mov    0x4(%esi),%eax
f0104812:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104816:	8b 06                	mov    (%esi),%eax
f0104818:	89 44 24 10          	mov    %eax,0x10(%esp)
f010481c:	8b 46 10             	mov    0x10(%esi),%eax
f010481f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104823:	8b 46 18             	mov    0x18(%esi),%eax
f0104826:	89 44 24 08          	mov    %eax,0x8(%esp)
f010482a:	8b 46 14             	mov    0x14(%esi),%eax
f010482d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104831:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104834:	89 04 24             	mov    %eax,(%esp)
f0104837:	e8 04 03 00 00       	call   f0104b40 <syscall>
f010483c:	89 46 1c             	mov    %eax,0x1c(%esi)
f010483f:	eb 5c                	jmp    f010489d <trap+0x1e1>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104841:	83 f8 27             	cmp    $0x27,%eax
f0104844:	75 16                	jne    f010485c <trap+0x1a0>
		cprintf("Spurious interrupt on irq 7\n");
f0104846:	c7 04 24 1f 7d 10 f0 	movl   $0xf0107d1f,(%esp)
f010484d:	e8 20 f7 ff ff       	call   f0103f72 <cprintf>
		print_trapframe(tf);
f0104852:	89 34 24             	mov    %esi,(%esp)
f0104855:	e8 41 fc ff ff       	call   f010449b <print_trapframe>
f010485a:	eb 41                	jmp    f010489d <trap+0x1e1>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010485c:	89 34 24             	mov    %esi,(%esp)
f010485f:	e8 37 fc ff ff       	call   f010449b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104864:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104869:	75 1c                	jne    f0104887 <trap+0x1cb>
		panic("unhandled trap in kernel");
f010486b:	c7 44 24 08 3c 7d 10 	movl   $0xf0107d3c,0x8(%esp)
f0104872:	f0 
f0104873:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f010487a:	00 
f010487b:	c7 04 24 f3 7c 10 f0 	movl   $0xf0107cf3,(%esp)
f0104882:	e8 b9 b7 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104887:	e8 ad 19 00 00       	call   f0106239 <cpunum>
f010488c:	6b c0 74             	imul   $0x74,%eax,%eax
f010488f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104895:	89 04 24             	mov    %eax,(%esp)
f0104898:	e8 de f3 ff ff       	call   f0103c7b <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010489d:	e8 97 19 00 00       	call   f0106239 <cpunum>
f01048a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a5:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01048ac:	74 2a                	je     f01048d8 <trap+0x21c>
f01048ae:	e8 86 19 00 00       	call   f0106239 <cpunum>
f01048b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b6:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01048bc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048c0:	75 16                	jne    f01048d8 <trap+0x21c>
		env_run(curenv);
f01048c2:	e8 72 19 00 00       	call   f0106239 <cpunum>
f01048c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ca:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01048d0:	89 04 24             	mov    %eax,(%esp)
f01048d3:	e8 44 f4 ff ff       	call   f0103d1c <env_run>
	else
		sched_yield();
f01048d8:	e8 ac 01 00 00       	call   f0104a89 <sched_yield>
f01048dd:	90                   	nop

f01048de <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f01048de:	6a 00                	push   $0x0
f01048e0:	6a 00                	push   $0x0
f01048e2:	e9 ba 00 00 00       	jmp    f01049a1 <_alltraps>
f01048e7:	90                   	nop

f01048e8 <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f01048e8:	6a 00                	push   $0x0
f01048ea:	6a 01                	push   $0x1
f01048ec:	e9 b0 00 00 00       	jmp    f01049a1 <_alltraps>
f01048f1:	90                   	nop

f01048f2 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01048f2:	6a 00                	push   $0x0
f01048f4:	6a 02                	push   $0x2
f01048f6:	e9 a6 00 00 00       	jmp    f01049a1 <_alltraps>
f01048fb:	90                   	nop

f01048fc <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01048fc:	6a 00                	push   $0x0
f01048fe:	6a 03                	push   $0x3
f0104900:	e9 9c 00 00 00       	jmp    f01049a1 <_alltraps>
f0104905:	90                   	nop

f0104906 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104906:	6a 00                	push   $0x0
f0104908:	6a 04                	push   $0x4
f010490a:	e9 92 00 00 00       	jmp    f01049a1 <_alltraps>
f010490f:	90                   	nop

f0104910 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104910:	6a 00                	push   $0x0
f0104912:	6a 05                	push   $0x5
f0104914:	e9 88 00 00 00       	jmp    f01049a1 <_alltraps>
f0104919:	90                   	nop

f010491a <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f010491a:	6a 00                	push   $0x0
f010491c:	6a 06                	push   $0x6
f010491e:	e9 7e 00 00 00       	jmp    f01049a1 <_alltraps>
f0104923:	90                   	nop

f0104924 <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104924:	6a 00                	push   $0x0
f0104926:	6a 07                	push   $0x7
f0104928:	e9 74 00 00 00       	jmp    f01049a1 <_alltraps>
f010492d:	90                   	nop

f010492e <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f010492e:	6a 08                	push   $0x8
f0104930:	e9 6c 00 00 00       	jmp    f01049a1 <_alltraps>
f0104935:	90                   	nop

f0104936 <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104936:	6a 00                	push   $0x0
f0104938:	6a 09                	push   $0x9
f010493a:	e9 62 00 00 00       	jmp    f01049a1 <_alltraps>
f010493f:	90                   	nop

f0104940 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104940:	6a 0a                	push   $0xa
f0104942:	e9 5a 00 00 00       	jmp    f01049a1 <_alltraps>
f0104947:	90                   	nop

f0104948 <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104948:	6a 0b                	push   $0xb
f010494a:	e9 52 00 00 00       	jmp    f01049a1 <_alltraps>
f010494f:	90                   	nop

f0104950 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104950:	6a 0c                	push   $0xc
f0104952:	e9 4a 00 00 00       	jmp    f01049a1 <_alltraps>
f0104957:	90                   	nop

f0104958 <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104958:	6a 0d                	push   $0xd
f010495a:	e9 42 00 00 00       	jmp    f01049a1 <_alltraps>
f010495f:	90                   	nop

f0104960 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104960:	6a 0e                	push   $0xe
f0104962:	e9 3a 00 00 00       	jmp    f01049a1 <_alltraps>
f0104967:	90                   	nop

f0104968 <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104968:	6a 00                	push   $0x0
f010496a:	6a 0f                	push   $0xf
f010496c:	e9 30 00 00 00       	jmp    f01049a1 <_alltraps>
f0104971:	90                   	nop

f0104972 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104972:	6a 00                	push   $0x0
f0104974:	6a 10                	push   $0x10
f0104976:	e9 26 00 00 00       	jmp    f01049a1 <_alltraps>
f010497b:	90                   	nop

f010497c <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f010497c:	6a 11                	push   $0x11
f010497e:	e9 1e 00 00 00       	jmp    f01049a1 <_alltraps>
f0104983:	90                   	nop

f0104984 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104984:	6a 00                	push   $0x0
f0104986:	6a 12                	push   $0x12
f0104988:	e9 14 00 00 00       	jmp    f01049a1 <_alltraps>
f010498d:	90                   	nop

f010498e <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f010498e:	6a 00                	push   $0x0
f0104990:	6a 13                	push   $0x13
f0104992:	e9 0a 00 00 00       	jmp    f01049a1 <_alltraps>
f0104997:	90                   	nop

f0104998 <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104998:	6a 00                	push   $0x0
f010499a:	6a 30                	push   $0x30
f010499c:	e9 00 00 00 00       	jmp    f01049a1 <_alltraps>

f01049a1 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f01049a1:	1e                   	push   %ds
	pushl %es
f01049a2:	06                   	push   %es
	pushal
f01049a3:	60                   	pusha  
	movl $GD_KD, %eax
f01049a4:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01049a9:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01049ab:	8e c0                	mov    %eax,%es

	pushl %esp
f01049ad:	54                   	push   %esp
	call trap
f01049ae:	e8 09 fd ff ff       	call   f01046bc <trap>

f01049b3 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01049b3:	55                   	push   %ebp
f01049b4:	89 e5                	mov    %esp,%ebp
f01049b6:	83 ec 18             	sub    $0x18,%esp
f01049b9:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01049bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01049c4:	8b 4a 54             	mov    0x54(%edx),%ecx
f01049c7:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01049ca:	83 f9 02             	cmp    $0x2,%ecx
f01049cd:	76 0f                	jbe    f01049de <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01049cf:	83 c0 01             	add    $0x1,%eax
f01049d2:	83 c2 7c             	add    $0x7c,%edx
f01049d5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01049da:	75 e8                	jne    f01049c4 <sched_halt+0x11>
f01049dc:	eb 07                	jmp    f01049e5 <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01049de:	3d 00 04 00 00       	cmp    $0x400,%eax
f01049e3:	75 1a                	jne    f01049ff <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f01049e5:	c7 04 24 30 7f 10 f0 	movl   $0xf0107f30,(%esp)
f01049ec:	e8 81 f5 ff ff       	call   f0103f72 <cprintf>
		while (1)
			monitor(NULL);
f01049f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01049f8:	e8 ec be ff ff       	call   f01008e9 <monitor>
f01049fd:	eb f2                	jmp    f01049f1 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01049ff:	e8 35 18 00 00       	call   f0106239 <cpunum>
f0104a04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a07:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104a0e:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a11:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104a16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a1b:	77 20                	ja     f0104a3d <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a21:	c7 44 24 08 68 69 10 	movl   $0xf0106968,0x8(%esp)
f0104a28:	f0 
f0104a29:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0104a30:	00 
f0104a31:	c7 04 24 59 7f 10 f0 	movl   $0xf0107f59,(%esp)
f0104a38:	e8 03 b6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104a3d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104a42:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a45:	e8 ef 17 00 00       	call   f0106239 <cpunum>
f0104a4a:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a4d:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104a53:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a58:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104a5c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0104a63:	e8 fb 1a 00 00       	call   f0106563 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104a68:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104a6a:	e8 ca 17 00 00       	call   f0106239 <cpunum>
f0104a6f:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104a72:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104a78:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104a7d:	89 c4                	mov    %eax,%esp
f0104a7f:	6a 00                	push   $0x0
f0104a81:	6a 00                	push   $0x0
f0104a83:	fb                   	sti    
f0104a84:	f4                   	hlt    
f0104a85:	eb fd                	jmp    f0104a84 <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104a87:	c9                   	leave  
f0104a88:	c3                   	ret    

f0104a89 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104a89:	55                   	push   %ebp
f0104a8a:	89 e5                	mov    %esp,%ebp
f0104a8c:	57                   	push   %edi
f0104a8d:	56                   	push   %esi
f0104a8e:	53                   	push   %ebx
f0104a8f:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
f0104a92:	e8 a2 17 00 00       	call   f0106239 <cpunum>
f0104a97:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9a:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104aa0:	85 db                	test   %ebx,%ebx
f0104aa2:	74 3f                	je     f0104ae3 <sched_yield+0x5a>
			
		EnvID =  e-envs;
f0104aa4:	89 de                	mov    %ebx,%esi
f0104aa6:	2b 35 48 b2 22 f0    	sub    0xf022b248,%esi
f0104aac:	c1 fe 02             	sar    $0x2,%esi
f0104aaf:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104ab5:	89 f1                	mov    %esi,%ecx
		e->env_status = ENV_RUNNABLE;
f0104ab7:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104abe:	83 c6 01             	add    $0x1,%esi
f0104ac1:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104ac6:	89 f0                	mov    %esi,%eax
f0104ac8:	f7 ea                	imul   %edx
f0104aca:	01 f2                	add    %esi,%edx
f0104acc:	c1 fa 09             	sar    $0x9,%edx
f0104acf:	89 f0                	mov    %esi,%eax
f0104ad1:	c1 f8 1f             	sar    $0x1f,%eax
f0104ad4:	29 c2                	sub    %eax,%edx
f0104ad6:	89 d0                	mov    %edx,%eax
f0104ad8:	c1 e0 0a             	shl    $0xa,%eax
f0104adb:	29 d0                	sub    %edx,%eax
f0104add:	89 f2                	mov    %esi,%edx
f0104adf:	29 c2                	sub    %eax,%edx
f0104ae1:	eb 0a                	jmp    f0104aed <sched_yield+0x64>

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
f0104ae3:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104aed:	8b 3d 48 b2 22 f0    	mov    0xf022b248,%edi
f0104af3:	6b c2 7c             	imul   $0x7c,%edx,%eax
f0104af6:	01 f8                	add    %edi,%eax
f0104af8:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104afc:	75 08                	jne    f0104b06 <sched_yield+0x7d>
			//envs[i].env_cpunum = cpunum();
			env_run(&envs[i]);
f0104afe:	89 04 24             	mov    %eax,(%esp)
f0104b01:	e8 16 f2 ff ff       	call   f0103d1c <env_run>
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104b06:	83 c2 01             	add    $0x1,%edx
f0104b09:	89 d6                	mov    %edx,%esi
f0104b0b:	c1 fe 1f             	sar    $0x1f,%esi
f0104b0e:	c1 ee 16             	shr    $0x16,%esi
f0104b11:	01 f2                	add    %esi,%edx
f0104b13:	89 d0                	mov    %edx,%eax
f0104b15:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104b1a:	29 f0                	sub    %esi,%eax
f0104b1c:	89 c2                	mov    %eax,%edx
f0104b1e:	39 c1                	cmp    %eax,%ecx
f0104b20:	75 d1                	jne    f0104af3 <sched_yield+0x6a>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e)
f0104b22:	85 db                	test   %ebx,%ebx
f0104b24:	74 08                	je     f0104b2e <sched_yield+0xa5>
		env_run(e);
f0104b26:	89 1c 24             	mov    %ebx,(%esp)
f0104b29:	e8 ee f1 ff ff       	call   f0103d1c <env_run>
	


  
	// sched_halt never returns
	sched_halt();
f0104b2e:	e8 80 fe ff ff       	call   f01049b3 <sched_halt>
	}
f0104b33:	83 c4 1c             	add    $0x1c,%esp
f0104b36:	5b                   	pop    %ebx
f0104b37:	5e                   	pop    %esi
f0104b38:	5f                   	pop    %edi
f0104b39:	5d                   	pop    %ebp
f0104b3a:	c3                   	ret    
f0104b3b:	66 90                	xchg   %ax,%ax
f0104b3d:	66 90                	xchg   %ax,%ax
f0104b3f:	90                   	nop

f0104b40 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104b40:	55                   	push   %ebp
f0104b41:	89 e5                	mov    %esp,%ebp
f0104b43:	57                   	push   %edi
f0104b44:	56                   	push   %esi
f0104b45:	53                   	push   %ebx
f0104b46:	83 ec 2c             	sub    $0x2c,%esp
f0104b49:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104b4c:	83 f8 0a             	cmp    $0xa,%eax
f0104b4f:	0f 87 0e 04 00 00    	ja     f0104f63 <syscall+0x423>
f0104b55:	ff 24 85 a0 7f 10 f0 	jmp    *-0xfef8060(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104b5c:	e8 d8 16 00 00       	call   f0106239 <cpunum>
f0104b61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104b68:	00 
f0104b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b6c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104b70:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b73:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104b80:	89 04 24             	mov    %eax,(%esp)
f0104b83:	e8 9f e9 ff ff       	call   f0103527 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104b88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b8f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b96:	c7 04 24 66 7f 10 f0 	movl   $0xf0107f66,(%esp)
f0104b9d:	e8 d0 f3 ff ff       	call   f0103f72 <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104ba2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ba7:	e9 bc 03 00 00       	jmp    f0104f68 <syscall+0x428>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104bac:	e8 94 ba ff ff       	call   f0100645 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104bb1:	e9 b2 03 00 00       	jmp    f0104f68 <syscall+0x428>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104bb6:	e8 7e 16 00 00       	call   f0106239 <cpunum>
f0104bbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbe:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104bc4:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104bc7:	e9 9c 03 00 00       	jmp    f0104f68 <syscall+0x428>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104bcc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104bd3:	00 
f0104bd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bde:	89 04 24             	mov    %eax,(%esp)
f0104be1:	e8 44 ea ff ff       	call   f010362a <envid2env>
		return r;
f0104be6:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104be8:	85 c0                	test   %eax,%eax
f0104bea:	78 6e                	js     f0104c5a <syscall+0x11a>
		return r;
	if (e == curenv)
f0104bec:	e8 48 16 00 00       	call   f0106239 <cpunum>
f0104bf1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bf4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf7:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104bfd:	75 23                	jne    f0104c22 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104bff:	e8 35 16 00 00       	call   f0106239 <cpunum>
f0104c04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c07:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c0d:	8b 40 48             	mov    0x48(%eax),%eax
f0104c10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c14:	c7 04 24 6b 7f 10 f0 	movl   $0xf0107f6b,(%esp)
f0104c1b:	e8 52 f3 ff ff       	call   f0103f72 <cprintf>
f0104c20:	eb 28                	jmp    f0104c4a <syscall+0x10a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104c22:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104c25:	e8 0f 16 00 00       	call   f0106239 <cpunum>
f0104c2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104c2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c31:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c37:	8b 40 48             	mov    0x48(%eax),%eax
f0104c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c3e:	c7 04 24 86 7f 10 f0 	movl   $0xf0107f86,(%esp)
f0104c45:	e8 28 f3 ff ff       	call   f0103f72 <cprintf>
	env_destroy(e);
f0104c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c4d:	89 04 24             	mov    %eax,(%esp)
f0104c50:	e8 26 f0 ff ff       	call   f0103c7b <env_destroy>
	return 0;
f0104c55:	ba 00 00 00 00       	mov    $0x0,%edx
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
f0104c5a:	89 d0                	mov    %edx,%eax
						break;
f0104c5c:	e9 07 03 00 00       	jmp    f0104f68 <syscall+0x428>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c61:	e8 23 fe ff ff       	call   f0104a89 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	
	struct Env* childEnv=0;
f0104c66:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct Env* parentEnv = curenv;
f0104c6d:	e8 c7 15 00 00       	call   f0106239 <cpunum>
f0104c72:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c75:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104c7b:	8b 46 48             	mov    0x48(%esi),%eax
f0104c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c85:	89 04 24             	mov    %eax,(%esp)
f0104c88:	e8 a6 ea ff ff       	call   f0103733 <env_alloc>
	if(r < 0)
f0104c8d:	85 c0                	test   %eax,%eax
f0104c8f:	0f 88 d3 02 00 00    	js     f0104f68 <syscall+0x428>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104c95:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104c9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ca2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104ca9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104cb0:	8b 40 48             	mov    0x48(%eax),%eax
f0104cb3:	e9 b0 02 00 00       	jmp    f0104f68 <syscall+0x428>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e =0;
f0104cb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104cbf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104cc6:	00 
f0104cc7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cce:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cd1:	89 04 24             	mov    %eax,(%esp)
f0104cd4:	e8 51 e9 ff ff       	call   f010362a <envid2env>
f0104cd9:	85 c0                	test   %eax,%eax
f0104cdb:	0f 88 87 02 00 00    	js     f0104f68 <syscall+0x428>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104ce1:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ce5:	74 06                	je     f0104ced <syscall+0x1ad>
f0104ce7:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104ceb:	75 13                	jne    f0104d00 <syscall+0x1c0>
		return -E_INVAL;
	e->env_status = status;
f0104ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104cf3:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f0104cf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cfb:	e9 68 02 00 00       	jmp    f0104f68 <syscall+0x428>
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104d00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
f0104d05:	e9 5e 02 00 00       	jmp    f0104f68 <syscall+0x428>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e =0;
f0104d0a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104d11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d18:	00 
f0104d19:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d23:	89 04 24             	mov    %eax,(%esp)
f0104d26:	e8 ff e8 ff ff       	call   f010362a <envid2env>
f0104d2b:	85 c0                	test   %eax,%eax
f0104d2d:	78 6c                	js     f0104d9b <syscall+0x25b>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104d2f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d36:	77 67                	ja     f0104d9f <syscall+0x25f>
f0104d38:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d3f:	75 65                	jne    f0104da6 <syscall+0x266>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104d41:	8b 75 14             	mov    0x14(%ebp),%esi
f0104d44:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f0104d4a:	75 61                	jne    f0104dad <syscall+0x26d>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104d4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d4f:	83 e0 05             	and    $0x5,%eax
f0104d52:	83 f8 05             	cmp    $0x5,%eax
f0104d55:	75 5d                	jne    f0104db4 <syscall+0x274>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104d57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104d5e:	e8 6f c2 ff ff       	call   f0100fd2 <page_alloc>
f0104d63:	89 c3                	mov    %eax,%ebx
	if(page == 0)
f0104d65:	85 c0                	test   %eax,%eax
f0104d67:	74 52                	je     f0104dbb <syscall+0x27b>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104d69:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d70:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d73:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d7e:	8b 40 60             	mov    0x60(%eax),%eax
f0104d81:	89 04 24             	mov    %eax,(%esp)
f0104d84:	e8 3b c5 ff ff       	call   f01012c4 <page_insert>
f0104d89:	89 c7                	mov    %eax,%edi
	if(r <0){
f0104d8b:	85 c0                	test   %eax,%eax
f0104d8d:	79 31                	jns    f0104dc0 <syscall+0x280>
		page_free(page);
f0104d8f:	89 1c 24             	mov    %ebx,(%esp)
f0104d92:	e8 c6 c2 ff ff       	call   f010105d <page_free>
		return r;
f0104d97:	89 fe                	mov    %edi,%esi
f0104d99:	eb 25                	jmp    f0104dc0 <syscall+0x280>

	// LAB 4: Your code here.
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104d9b:	89 c6                	mov    %eax,%esi
f0104d9d:	eb 21                	jmp    f0104dc0 <syscall+0x280>
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104d9f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104da4:	eb 1a                	jmp    f0104dc0 <syscall+0x280>
f0104da6:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104dab:	eb 13                	jmp    f0104dc0 <syscall+0x280>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0104dad:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104db2:	eb 0c                	jmp    f0104dc0 <syscall+0x280>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0104db4:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104db9:	eb 05                	jmp    f0104dc0 <syscall+0x280>
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f0104dbb:	be fc ff ff ff       	mov    $0xfffffffc,%esi

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
f0104dc0:	89 f0                	mov    %esi,%eax
						break;
f0104dc2:	e9 a1 01 00 00       	jmp    f0104f68 <syscall+0x428>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
f0104dc7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0104dce:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0104dd5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ddc:	00 
f0104ddd:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104de0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104de7:	89 04 24             	mov    %eax,(%esp)
f0104dea:	e8 3b e8 ff ff       	call   f010362a <envid2env>
		return r;
f0104def:	89 c2                	mov    %eax,%edx
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0104df1:	85 c0                	test   %eax,%eax
f0104df3:	0f 88 05 01 00 00    	js     f0104efe <syscall+0x3be>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f0104df9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e00:	00 
f0104e01:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e08:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e0b:	89 04 24             	mov    %eax,(%esp)
f0104e0e:	e8 17 e8 ff ff       	call   f010362a <envid2env>
f0104e13:	85 c0                	test   %eax,%eax
f0104e15:	0f 88 a9 00 00 00    	js     f0104ec4 <syscall+0x384>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f0104e1b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e22:	0f 87 a0 00 00 00    	ja     f0104ec8 <syscall+0x388>
f0104e28:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e2f:	0f 85 9a 00 00 00    	jne    f0104ecf <syscall+0x38f>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f0104e35:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104e3c:	0f 87 94 00 00 00    	ja     f0104ed6 <syscall+0x396>
f0104e42:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104e49:	0f 85 8e 00 00 00    	jne    f0104edd <syscall+0x39d>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f0104e4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f0104e56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e59:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e5d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e67:	8b 40 60             	mov    0x60(%eax),%eax
f0104e6a:	89 04 24             	mov    %eax,(%esp)
f0104e6d:	e8 4f c3 ff ff       	call   f01011c1 <page_lookup>
	if(page == 0)
f0104e72:	85 c0                	test   %eax,%eax
f0104e74:	74 6e                	je     f0104ee4 <syscall+0x3a4>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104e76:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104e7d:	75 6c                	jne    f0104eeb <syscall+0x3ab>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104e7f:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104e82:	83 e2 05             	and    $0x5,%edx
f0104e85:	83 fa 05             	cmp    $0x5,%edx
f0104e88:	75 68                	jne    f0104ef2 <syscall+0x3b2>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f0104e8a:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104e8e:	74 08                	je     f0104e98 <syscall+0x358>
f0104e90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e93:	f6 02 02             	testb  $0x2,(%edx)
f0104e96:	74 61                	je     f0104ef9 <syscall+0x3b9>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f0104e98:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104e9b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104e9f:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104ea2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ead:	8b 40 60             	mov    0x60(%eax),%eax
f0104eb0:	89 04 24             	mov    %eax,(%esp)
f0104eb3:	e8 0c c4 ff ff       	call   f01012c4 <page_insert>
f0104eb8:	85 c0                	test   %eax,%eax
f0104eba:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ebf:	0f 4e d0             	cmovle %eax,%edx
f0104ec2:	eb 3a                	jmp    f0104efe <syscall+0x3be>
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
f0104ec4:	89 c2                	mov    %eax,%edx
f0104ec6:	eb 36                	jmp    f0104efe <syscall+0x3be>
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f0104ec8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ecd:	eb 2f                	jmp    f0104efe <syscall+0x3be>
f0104ecf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ed4:	eb 28                	jmp    f0104efe <syscall+0x3be>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
f0104ed6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104edb:	eb 21                	jmp    f0104efe <syscall+0x3be>
f0104edd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ee2:	eb 1a                	jmp    f0104efe <syscall+0x3be>
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f0104ee4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ee9:	eb 13                	jmp    f0104efe <syscall+0x3be>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0104eeb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ef0:	eb 0c                	jmp    f0104efe <syscall+0x3be>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0104ef2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ef7:	eb 05                	jmp    f0104efe <syscall+0x3be>
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
		return -E_INVAL;
f0104ef9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
f0104efe:	89 d0                	mov    %edx,%eax
						break;
f0104f00:	eb 66                	jmp    f0104f68 <syscall+0x428>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e =0;
f0104f02:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f09:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f10:	00 
f0104f11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f1b:	89 04 24             	mov    %eax,(%esp)
f0104f1e:	e8 07 e7 ff ff       	call   f010362a <envid2env>
f0104f23:	85 c0                	test   %eax,%eax
f0104f25:	78 41                	js     f0104f68 <syscall+0x428>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104f27:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f2e:	77 25                	ja     f0104f55 <syscall+0x415>
f0104f30:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f37:	75 23                	jne    f0104f5c <syscall+0x41c>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f0104f39:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f43:	8b 40 60             	mov    0x60(%eax),%eax
f0104f46:	89 04 24             	mov    %eax,(%esp)
f0104f49:	e8 1d c3 ff ff       	call   f010126b <page_remove>
	return 0;
f0104f4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f53:	eb 13                	jmp    f0104f68 <syscall+0x428>
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104f55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f5a:	eb 0c                	jmp    f0104f68 <syscall+0x428>
f0104f5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
f0104f61:	eb 05                	jmp    f0104f68 <syscall+0x428>
		default:
			return -E_NO_SYS;
f0104f63:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
	return ret;
}
f0104f68:	83 c4 2c             	add    $0x2c,%esp
f0104f6b:	5b                   	pop    %ebx
f0104f6c:	5e                   	pop    %esi
f0104f6d:	5f                   	pop    %edi
f0104f6e:	5d                   	pop    %ebp
f0104f6f:	c3                   	ret    

f0104f70 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f70:	55                   	push   %ebp
f0104f71:	89 e5                	mov    %esp,%ebp
f0104f73:	57                   	push   %edi
f0104f74:	56                   	push   %esi
f0104f75:	53                   	push   %ebx
f0104f76:	83 ec 14             	sub    $0x14,%esp
f0104f79:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f7c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104f7f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f82:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f85:	8b 1a                	mov    (%edx),%ebx
f0104f87:	8b 01                	mov    (%ecx),%eax
f0104f89:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f8c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104f93:	e9 88 00 00 00       	jmp    f0105020 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f9b:	01 d8                	add    %ebx,%eax
f0104f9d:	89 c7                	mov    %eax,%edi
f0104f9f:	c1 ef 1f             	shr    $0x1f,%edi
f0104fa2:	01 c7                	add    %eax,%edi
f0104fa4:	d1 ff                	sar    %edi
f0104fa6:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104fa9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104fac:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104faf:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104fb1:	eb 03                	jmp    f0104fb6 <stab_binsearch+0x46>
			m--;
f0104fb3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104fb6:	39 c3                	cmp    %eax,%ebx
f0104fb8:	7f 1f                	jg     f0104fd9 <stab_binsearch+0x69>
f0104fba:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104fbe:	83 ea 0c             	sub    $0xc,%edx
f0104fc1:	39 f1                	cmp    %esi,%ecx
f0104fc3:	75 ee                	jne    f0104fb3 <stab_binsearch+0x43>
f0104fc5:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104fc8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fcb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104fce:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104fd2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104fd5:	76 18                	jbe    f0104fef <stab_binsearch+0x7f>
f0104fd7:	eb 05                	jmp    f0104fde <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104fd9:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104fdc:	eb 42                	jmp    f0105020 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104fde:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104fe1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104fe3:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fe6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104fed:	eb 31                	jmp    f0105020 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104fef:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ff2:	73 17                	jae    f010500b <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104ff4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ff7:	83 e8 01             	sub    $0x1,%eax
f0104ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ffd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105000:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105002:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105009:	eb 15                	jmp    f0105020 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010500b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010500e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105011:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105013:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105017:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105019:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105020:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105023:	0f 8e 6f ff ff ff    	jle    f0104f98 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105029:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010502d:	75 0f                	jne    f010503e <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010502f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105032:	8b 00                	mov    (%eax),%eax
f0105034:	83 e8 01             	sub    $0x1,%eax
f0105037:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010503a:	89 07                	mov    %eax,(%edi)
f010503c:	eb 2c                	jmp    f010506a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010503e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105041:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105043:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105046:	8b 0f                	mov    (%edi),%ecx
f0105048:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010504b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010504e:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105051:	eb 03                	jmp    f0105056 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105053:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105056:	39 c8                	cmp    %ecx,%eax
f0105058:	7e 0b                	jle    f0105065 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f010505a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010505e:	83 ea 0c             	sub    $0xc,%edx
f0105061:	39 f3                	cmp    %esi,%ebx
f0105063:	75 ee                	jne    f0105053 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105065:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105068:	89 07                	mov    %eax,(%edi)
	}
}
f010506a:	83 c4 14             	add    $0x14,%esp
f010506d:	5b                   	pop    %ebx
f010506e:	5e                   	pop    %esi
f010506f:	5f                   	pop    %edi
f0105070:	5d                   	pop    %ebp
f0105071:	c3                   	ret    

f0105072 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105072:	55                   	push   %ebp
f0105073:	89 e5                	mov    %esp,%ebp
f0105075:	57                   	push   %edi
f0105076:	56                   	push   %esi
f0105077:	53                   	push   %ebx
f0105078:	83 ec 4c             	sub    $0x4c,%esp
f010507b:	8b 75 08             	mov    0x8(%ebp),%esi
f010507e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105081:	c7 07 cc 7f 10 f0    	movl   $0xf0107fcc,(%edi)
	info->eip_line = 0;
f0105087:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010508e:	c7 47 08 cc 7f 10 f0 	movl   $0xf0107fcc,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105095:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f010509c:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f010509f:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01050a6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01050ac:	0f 87 c1 00 00 00    	ja     f0105173 <debuginfo_eip+0x101>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01050b2:	e8 82 11 00 00       	call   f0106239 <cpunum>
f01050b7:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01050be:	00 
f01050bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01050c6:	00 
f01050c7:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01050ce:	00 
f01050cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01050d8:	89 04 24             	mov    %eax,(%esp)
f01050db:	e8 a5 e3 ff ff       	call   f0103485 <user_mem_check>
f01050e0:	85 c0                	test   %eax,%eax
f01050e2:	0f 85 49 02 00 00    	jne    f0105331 <debuginfo_eip+0x2bf>
			return -1;

		stabs = usd->stabs;
f01050e8:	a1 00 00 20 00       	mov    0x200000,%eax
f01050ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01050f0:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f01050f6:	a1 08 00 20 00       	mov    0x200008,%eax
f01050fb:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f01050fe:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105104:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105107:	e8 2d 11 00 00       	call   f0106239 <cpunum>
f010510c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105113:	00 
f0105114:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f010511b:	00 
f010511c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010511f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105123:	6b c0 74             	imul   $0x74,%eax,%eax
f0105126:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010512c:	89 04 24             	mov    %eax,(%esp)
f010512f:	e8 51 e3 ff ff       	call   f0103485 <user_mem_check>
f0105134:	85 c0                	test   %eax,%eax
f0105136:	0f 85 fc 01 00 00    	jne    f0105338 <debuginfo_eip+0x2c6>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010513c:	e8 f8 10 00 00       	call   f0106239 <cpunum>
f0105141:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105148:	00 
f0105149:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010514c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010514f:	29 ca                	sub    %ecx,%edx
f0105151:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105155:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105159:	6b c0 74             	imul   $0x74,%eax,%eax
f010515c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0105162:	89 04 24             	mov    %eax,(%esp)
f0105165:	e8 1b e3 ff ff       	call   f0103485 <user_mem_check>
f010516a:	85 c0                	test   %eax,%eax
f010516c:	74 1f                	je     f010518d <debuginfo_eip+0x11b>
f010516e:	e9 cc 01 00 00       	jmp    f010533f <debuginfo_eip+0x2cd>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105173:	c7 45 bc fe 5d 11 f0 	movl   $0xf0115dfe,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010517a:	c7 45 c0 c1 27 11 f0 	movl   $0xf01127c1,-0x40(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105181:	bb c0 27 11 f0       	mov    $0xf01127c0,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105186:	c7 45 c4 ac 84 10 f0 	movl   $0xf01084ac,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010518d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105190:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105193:	0f 83 ad 01 00 00    	jae    f0105346 <debuginfo_eip+0x2d4>
f0105199:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010519d:	0f 85 aa 01 00 00    	jne    f010534d <debuginfo_eip+0x2db>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01051a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01051aa:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f01051ad:	c1 fb 02             	sar    $0x2,%ebx
f01051b0:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f01051b6:	83 e8 01             	sub    $0x1,%eax
f01051b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01051bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051c0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01051c7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01051ca:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01051cd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01051d0:	89 d8                	mov    %ebx,%eax
f01051d2:	e8 99 fd ff ff       	call   f0104f70 <stab_binsearch>
	if (lfile == 0)
f01051d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051da:	85 c0                	test   %eax,%eax
f01051dc:	0f 84 72 01 00 00    	je     f0105354 <debuginfo_eip+0x2e2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01051e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01051e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01051eb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051ef:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01051f6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01051f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051fc:	89 d8                	mov    %ebx,%eax
f01051fe:	e8 6d fd ff ff       	call   f0104f70 <stab_binsearch>

	if (lfun <= rfun) {
f0105203:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105206:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105209:	39 d8                	cmp    %ebx,%eax
f010520b:	7f 32                	jg     f010523f <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010520d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105210:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105213:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105216:	8b 0a                	mov    (%edx),%ecx
f0105218:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f010521b:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010521e:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0105221:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f0105224:	73 09                	jae    f010522f <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105226:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105229:	03 4d c0             	add    -0x40(%ebp),%ecx
f010522c:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010522f:	8b 52 08             	mov    0x8(%edx),%edx
f0105232:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105235:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105237:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010523a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010523d:	eb 0f                	jmp    f010524e <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010523f:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0105242:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105245:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105248:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010524b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010524e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105255:	00 
f0105256:	8b 47 08             	mov    0x8(%edi),%eax
f0105259:	89 04 24             	mov    %eax,(%esp)
f010525c:	e8 6a 09 00 00       	call   f0105bcb <strfind>
f0105261:	2b 47 08             	sub    0x8(%edi),%eax
f0105264:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105267:	89 74 24 04          	mov    %esi,0x4(%esp)
f010526b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105272:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105275:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105278:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010527b:	89 f0                	mov    %esi,%eax
f010527d:	e8 ee fc ff ff       	call   f0104f70 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105282:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105285:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0105288:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f010528b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105290:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105296:	89 c3                	mov    %eax,%ebx
f0105298:	89 d0                	mov    %edx,%eax
f010529a:	01 ca                	add    %ecx,%edx
f010529c:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010529f:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01052a2:	89 df                	mov    %ebx,%edi
f01052a4:	eb 06                	jmp    f01052ac <debuginfo_eip+0x23a>
f01052a6:	83 e8 01             	sub    $0x1,%eax
f01052a9:	83 ea 0c             	sub    $0xc,%edx
f01052ac:	89 c6                	mov    %eax,%esi
f01052ae:	39 c7                	cmp    %eax,%edi
f01052b0:	7f 3c                	jg     f01052ee <debuginfo_eip+0x27c>
	       && stabs[lline].n_type != N_SOL
f01052b2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01052b6:	80 f9 84             	cmp    $0x84,%cl
f01052b9:	75 08                	jne    f01052c3 <debuginfo_eip+0x251>
f01052bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01052be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01052c1:	eb 11                	jmp    f01052d4 <debuginfo_eip+0x262>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01052c3:	80 f9 64             	cmp    $0x64,%cl
f01052c6:	75 de                	jne    f01052a6 <debuginfo_eip+0x234>
f01052c8:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01052cc:	74 d8                	je     f01052a6 <debuginfo_eip+0x234>
f01052ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01052d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01052d4:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01052d7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01052da:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01052dd:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01052e0:	2b 55 c0             	sub    -0x40(%ebp),%edx
f01052e3:	39 d0                	cmp    %edx,%eax
f01052e5:	73 0a                	jae    f01052f1 <debuginfo_eip+0x27f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052e7:	03 45 c0             	add    -0x40(%ebp),%eax
f01052ea:	89 07                	mov    %eax,(%edi)
f01052ec:	eb 03                	jmp    f01052f1 <debuginfo_eip+0x27f>
f01052ee:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01052f4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052f7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052fc:	39 da                	cmp    %ebx,%edx
f01052fe:	7d 60                	jge    f0105360 <debuginfo_eip+0x2ee>
		for (lline = lfun + 1;
f0105300:	83 c2 01             	add    $0x1,%edx
f0105303:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105306:	89 d0                	mov    %edx,%eax
f0105308:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010530b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010530e:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105311:	eb 04                	jmp    f0105317 <debuginfo_eip+0x2a5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105313:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105317:	39 c3                	cmp    %eax,%ebx
f0105319:	7e 40                	jle    f010535b <debuginfo_eip+0x2e9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010531b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010531f:	83 c0 01             	add    $0x1,%eax
f0105322:	83 c2 0c             	add    $0xc,%edx
f0105325:	80 f9 a0             	cmp    $0xa0,%cl
f0105328:	74 e9                	je     f0105313 <debuginfo_eip+0x2a1>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010532a:	b8 00 00 00 00       	mov    $0x0,%eax
f010532f:	eb 2f                	jmp    f0105360 <debuginfo_eip+0x2ee>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0105331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105336:	eb 28                	jmp    f0105360 <debuginfo_eip+0x2ee>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010533d:	eb 21                	jmp    f0105360 <debuginfo_eip+0x2ee>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f010533f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105344:	eb 1a                	jmp    f0105360 <debuginfo_eip+0x2ee>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010534b:	eb 13                	jmp    f0105360 <debuginfo_eip+0x2ee>
f010534d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105352:	eb 0c                	jmp    f0105360 <debuginfo_eip+0x2ee>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105359:	eb 05                	jmp    f0105360 <debuginfo_eip+0x2ee>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010535b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105360:	83 c4 4c             	add    $0x4c,%esp
f0105363:	5b                   	pop    %ebx
f0105364:	5e                   	pop    %esi
f0105365:	5f                   	pop    %edi
f0105366:	5d                   	pop    %ebp
f0105367:	c3                   	ret    
f0105368:	66 90                	xchg   %ax,%ax
f010536a:	66 90                	xchg   %ax,%ax
f010536c:	66 90                	xchg   %ax,%ax
f010536e:	66 90                	xchg   %ax,%ax

f0105370 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105370:	55                   	push   %ebp
f0105371:	89 e5                	mov    %esp,%ebp
f0105373:	57                   	push   %edi
f0105374:	56                   	push   %esi
f0105375:	53                   	push   %ebx
f0105376:	83 ec 3c             	sub    $0x3c,%esp
f0105379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010537c:	89 d7                	mov    %edx,%edi
f010537e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105381:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105384:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105387:	89 c3                	mov    %eax,%ebx
f0105389:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010538c:	8b 45 10             	mov    0x10(%ebp),%eax
f010538f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105392:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105397:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010539a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010539d:	39 d9                	cmp    %ebx,%ecx
f010539f:	72 05                	jb     f01053a6 <printnum+0x36>
f01053a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01053a4:	77 69                	ja     f010540f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01053a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01053a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01053ad:	83 ee 01             	sub    $0x1,%esi
f01053b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01053b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053b8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01053bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01053c0:	89 c3                	mov    %eax,%ebx
f01053c2:	89 d6                	mov    %edx,%esi
f01053c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01053ca:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01053d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053d5:	89 04 24             	mov    %eax,(%esp)
f01053d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01053db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053df:	e8 9c 12 00 00       	call   f0106680 <__udivdi3>
f01053e4:	89 d9                	mov    %ebx,%ecx
f01053e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01053ee:	89 04 24             	mov    %eax,(%esp)
f01053f1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053f5:	89 fa                	mov    %edi,%edx
f01053f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053fa:	e8 71 ff ff ff       	call   f0105370 <printnum>
f01053ff:	eb 1b                	jmp    f010541c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105401:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105405:	8b 45 18             	mov    0x18(%ebp),%eax
f0105408:	89 04 24             	mov    %eax,(%esp)
f010540b:	ff d3                	call   *%ebx
f010540d:	eb 03                	jmp    f0105412 <printnum+0xa2>
f010540f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105412:	83 ee 01             	sub    $0x1,%esi
f0105415:	85 f6                	test   %esi,%esi
f0105417:	7f e8                	jg     f0105401 <printnum+0x91>
f0105419:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010541c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105420:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105424:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105427:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010542a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010542e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105432:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105435:	89 04 24             	mov    %eax,(%esp)
f0105438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010543b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010543f:	e8 6c 13 00 00       	call   f01067b0 <__umoddi3>
f0105444:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105448:	0f be 80 d6 7f 10 f0 	movsbl -0xfef802a(%eax),%eax
f010544f:	89 04 24             	mov    %eax,(%esp)
f0105452:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105455:	ff d0                	call   *%eax
}
f0105457:	83 c4 3c             	add    $0x3c,%esp
f010545a:	5b                   	pop    %ebx
f010545b:	5e                   	pop    %esi
f010545c:	5f                   	pop    %edi
f010545d:	5d                   	pop    %ebp
f010545e:	c3                   	ret    

f010545f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010545f:	55                   	push   %ebp
f0105460:	89 e5                	mov    %esp,%ebp
f0105462:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105465:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105469:	8b 10                	mov    (%eax),%edx
f010546b:	3b 50 04             	cmp    0x4(%eax),%edx
f010546e:	73 0a                	jae    f010547a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105470:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105473:	89 08                	mov    %ecx,(%eax)
f0105475:	8b 45 08             	mov    0x8(%ebp),%eax
f0105478:	88 02                	mov    %al,(%edx)
}
f010547a:	5d                   	pop    %ebp
f010547b:	c3                   	ret    

f010547c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010547c:	55                   	push   %ebp
f010547d:	89 e5                	mov    %esp,%ebp
f010547f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105482:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105485:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105489:	8b 45 10             	mov    0x10(%ebp),%eax
f010548c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105490:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105493:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105497:	8b 45 08             	mov    0x8(%ebp),%eax
f010549a:	89 04 24             	mov    %eax,(%esp)
f010549d:	e8 02 00 00 00       	call   f01054a4 <vprintfmt>
	va_end(ap);
}
f01054a2:	c9                   	leave  
f01054a3:	c3                   	ret    

f01054a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01054a4:	55                   	push   %ebp
f01054a5:	89 e5                	mov    %esp,%ebp
f01054a7:	57                   	push   %edi
f01054a8:	56                   	push   %esi
f01054a9:	53                   	push   %ebx
f01054aa:	83 ec 3c             	sub    $0x3c,%esp
f01054ad:	8b 75 08             	mov    0x8(%ebp),%esi
f01054b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054b3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01054b6:	eb 11                	jmp    f01054c9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01054b8:	85 c0                	test   %eax,%eax
f01054ba:	0f 84 48 04 00 00    	je     f0105908 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01054c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054c4:	89 04 24             	mov    %eax,(%esp)
f01054c7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054c9:	83 c7 01             	add    $0x1,%edi
f01054cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054d0:	83 f8 25             	cmp    $0x25,%eax
f01054d3:	75 e3                	jne    f01054b8 <vprintfmt+0x14>
f01054d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01054d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01054e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01054e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01054ee:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054f3:	eb 1f                	jmp    f0105514 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01054f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01054fc:	eb 16                	jmp    f0105514 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105501:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105505:	eb 0d                	jmp    f0105514 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105507:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010550a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010550d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105514:	8d 47 01             	lea    0x1(%edi),%eax
f0105517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010551a:	0f b6 17             	movzbl (%edi),%edx
f010551d:	0f b6 c2             	movzbl %dl,%eax
f0105520:	83 ea 23             	sub    $0x23,%edx
f0105523:	80 fa 55             	cmp    $0x55,%dl
f0105526:	0f 87 bf 03 00 00    	ja     f01058eb <vprintfmt+0x447>
f010552c:	0f b6 d2             	movzbl %dl,%edx
f010552f:	ff 24 95 a0 80 10 f0 	jmp    *-0xfef7f60(,%edx,4)
f0105536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105539:	ba 00 00 00 00       	mov    $0x0,%edx
f010553e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105541:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105544:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105548:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010554b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010554e:	83 f9 09             	cmp    $0x9,%ecx
f0105551:	77 3c                	ja     f010558f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105553:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105556:	eb e9                	jmp    f0105541 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105558:	8b 45 14             	mov    0x14(%ebp),%eax
f010555b:	8b 00                	mov    (%eax),%eax
f010555d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105560:	8b 45 14             	mov    0x14(%ebp),%eax
f0105563:	8d 40 04             	lea    0x4(%eax),%eax
f0105566:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010556c:	eb 27                	jmp    f0105595 <vprintfmt+0xf1>
f010556e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105571:	85 d2                	test   %edx,%edx
f0105573:	b8 00 00 00 00       	mov    $0x0,%eax
f0105578:	0f 49 c2             	cmovns %edx,%eax
f010557b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010557e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105581:	eb 91                	jmp    f0105514 <vprintfmt+0x70>
f0105583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105586:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010558d:	eb 85                	jmp    f0105514 <vprintfmt+0x70>
f010558f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105592:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105595:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105599:	0f 89 75 ff ff ff    	jns    f0105514 <vprintfmt+0x70>
f010559f:	e9 63 ff ff ff       	jmp    f0105507 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01055a4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01055aa:	e9 65 ff ff ff       	jmp    f0105514 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055af:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01055b2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01055b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055ba:	8b 00                	mov    (%eax),%eax
f01055bc:	89 04 24             	mov    %eax,(%esp)
f01055bf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01055c4:	e9 00 ff ff ff       	jmp    f01054c9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055c9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01055cc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01055d0:	8b 00                	mov    (%eax),%eax
f01055d2:	99                   	cltd   
f01055d3:	31 d0                	xor    %edx,%eax
f01055d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01055d7:	83 f8 09             	cmp    $0x9,%eax
f01055da:	7f 0b                	jg     f01055e7 <vprintfmt+0x143>
f01055dc:	8b 14 85 00 82 10 f0 	mov    -0xfef7e00(,%eax,4),%edx
f01055e3:	85 d2                	test   %edx,%edx
f01055e5:	75 20                	jne    f0105607 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f01055e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01055eb:	c7 44 24 08 ee 7f 10 	movl   $0xf0107fee,0x8(%esp)
f01055f2:	f0 
f01055f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055f7:	89 34 24             	mov    %esi,(%esp)
f01055fa:	e8 7d fe ff ff       	call   f010547c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105602:	e9 c2 fe ff ff       	jmp    f01054c9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105607:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010560b:	c7 44 24 08 91 77 10 	movl   $0xf0107791,0x8(%esp)
f0105612:	f0 
f0105613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105617:	89 34 24             	mov    %esi,(%esp)
f010561a:	e8 5d fe ff ff       	call   f010547c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010561f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105622:	e9 a2 fe ff ff       	jmp    f01054c9 <vprintfmt+0x25>
f0105627:	8b 45 14             	mov    0x14(%ebp),%eax
f010562a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010562d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105630:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105633:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105637:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105639:	85 ff                	test   %edi,%edi
f010563b:	b8 e7 7f 10 f0       	mov    $0xf0107fe7,%eax
f0105640:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105643:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105647:	0f 84 92 00 00 00    	je     f01056df <vprintfmt+0x23b>
f010564d:	85 c9                	test   %ecx,%ecx
f010564f:	0f 8e 98 00 00 00    	jle    f01056ed <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105655:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105659:	89 3c 24             	mov    %edi,(%esp)
f010565c:	e8 17 04 00 00       	call   f0105a78 <strnlen>
f0105661:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105664:	29 c1                	sub    %eax,%ecx
f0105666:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0105669:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010566d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105670:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105673:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105675:	eb 0f                	jmp    f0105686 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0105677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010567b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567e:	89 04 24             	mov    %eax,(%esp)
f0105681:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105683:	83 ef 01             	sub    $0x1,%edi
f0105686:	85 ff                	test   %edi,%edi
f0105688:	7f ed                	jg     f0105677 <vprintfmt+0x1d3>
f010568a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010568d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105690:	85 c9                	test   %ecx,%ecx
f0105692:	b8 00 00 00 00       	mov    $0x0,%eax
f0105697:	0f 49 c1             	cmovns %ecx,%eax
f010569a:	29 c1                	sub    %eax,%ecx
f010569c:	89 75 08             	mov    %esi,0x8(%ebp)
f010569f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01056a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01056a5:	89 cb                	mov    %ecx,%ebx
f01056a7:	eb 50                	jmp    f01056f9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01056a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01056ad:	74 1e                	je     f01056cd <vprintfmt+0x229>
f01056af:	0f be d2             	movsbl %dl,%edx
f01056b2:	83 ea 20             	sub    $0x20,%edx
f01056b5:	83 fa 5e             	cmp    $0x5e,%edx
f01056b8:	76 13                	jbe    f01056cd <vprintfmt+0x229>
					putch('?', putdat);
f01056ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056c1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01056c8:	ff 55 08             	call   *0x8(%ebp)
f01056cb:	eb 0d                	jmp    f01056da <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01056cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01056d4:	89 04 24             	mov    %eax,(%esp)
f01056d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01056da:	83 eb 01             	sub    $0x1,%ebx
f01056dd:	eb 1a                	jmp    f01056f9 <vprintfmt+0x255>
f01056df:	89 75 08             	mov    %esi,0x8(%ebp)
f01056e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01056e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01056e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01056eb:	eb 0c                	jmp    f01056f9 <vprintfmt+0x255>
f01056ed:	89 75 08             	mov    %esi,0x8(%ebp)
f01056f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01056f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01056f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01056f9:	83 c7 01             	add    $0x1,%edi
f01056fc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0105700:	0f be c2             	movsbl %dl,%eax
f0105703:	85 c0                	test   %eax,%eax
f0105705:	74 25                	je     f010572c <vprintfmt+0x288>
f0105707:	85 f6                	test   %esi,%esi
f0105709:	78 9e                	js     f01056a9 <vprintfmt+0x205>
f010570b:	83 ee 01             	sub    $0x1,%esi
f010570e:	79 99                	jns    f01056a9 <vprintfmt+0x205>
f0105710:	89 df                	mov    %ebx,%edi
f0105712:	8b 75 08             	mov    0x8(%ebp),%esi
f0105715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105718:	eb 1a                	jmp    f0105734 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010571a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010571e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105725:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105727:	83 ef 01             	sub    $0x1,%edi
f010572a:	eb 08                	jmp    f0105734 <vprintfmt+0x290>
f010572c:	89 df                	mov    %ebx,%edi
f010572e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105734:	85 ff                	test   %edi,%edi
f0105736:	7f e2                	jg     f010571a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010573b:	e9 89 fd ff ff       	jmp    f01054c9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105740:	83 f9 01             	cmp    $0x1,%ecx
f0105743:	7e 19                	jle    f010575e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0105745:	8b 45 14             	mov    0x14(%ebp),%eax
f0105748:	8b 50 04             	mov    0x4(%eax),%edx
f010574b:	8b 00                	mov    (%eax),%eax
f010574d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105750:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105753:	8b 45 14             	mov    0x14(%ebp),%eax
f0105756:	8d 40 08             	lea    0x8(%eax),%eax
f0105759:	89 45 14             	mov    %eax,0x14(%ebp)
f010575c:	eb 38                	jmp    f0105796 <vprintfmt+0x2f2>
	else if (lflag)
f010575e:	85 c9                	test   %ecx,%ecx
f0105760:	74 1b                	je     f010577d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0105762:	8b 45 14             	mov    0x14(%ebp),%eax
f0105765:	8b 00                	mov    (%eax),%eax
f0105767:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010576a:	89 c1                	mov    %eax,%ecx
f010576c:	c1 f9 1f             	sar    $0x1f,%ecx
f010576f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105772:	8b 45 14             	mov    0x14(%ebp),%eax
f0105775:	8d 40 04             	lea    0x4(%eax),%eax
f0105778:	89 45 14             	mov    %eax,0x14(%ebp)
f010577b:	eb 19                	jmp    f0105796 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010577d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105780:	8b 00                	mov    (%eax),%eax
f0105782:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105785:	89 c1                	mov    %eax,%ecx
f0105787:	c1 f9 1f             	sar    $0x1f,%ecx
f010578a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010578d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105790:	8d 40 04             	lea    0x4(%eax),%eax
f0105793:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105796:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105799:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010579c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01057a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01057a5:	0f 89 04 01 00 00    	jns    f01058af <vprintfmt+0x40b>
				putch('-', putdat);
f01057ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057af:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01057b6:	ff d6                	call   *%esi
				num = -(long long) num;
f01057b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01057bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01057be:	f7 da                	neg    %edx
f01057c0:	83 d1 00             	adc    $0x0,%ecx
f01057c3:	f7 d9                	neg    %ecx
f01057c5:	e9 e5 00 00 00       	jmp    f01058af <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01057ca:	83 f9 01             	cmp    $0x1,%ecx
f01057cd:	7e 10                	jle    f01057df <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01057cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01057d2:	8b 10                	mov    (%eax),%edx
f01057d4:	8b 48 04             	mov    0x4(%eax),%ecx
f01057d7:	8d 40 08             	lea    0x8(%eax),%eax
f01057da:	89 45 14             	mov    %eax,0x14(%ebp)
f01057dd:	eb 26                	jmp    f0105805 <vprintfmt+0x361>
	else if (lflag)
f01057df:	85 c9                	test   %ecx,%ecx
f01057e1:	74 12                	je     f01057f5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f01057e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01057e6:	8b 10                	mov    (%eax),%edx
f01057e8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057ed:	8d 40 04             	lea    0x4(%eax),%eax
f01057f0:	89 45 14             	mov    %eax,0x14(%ebp)
f01057f3:	eb 10                	jmp    f0105805 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f01057f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01057f8:	8b 10                	mov    (%eax),%edx
f01057fa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057ff:	8d 40 04             	lea    0x4(%eax),%eax
f0105802:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105805:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010580a:	e9 a0 00 00 00       	jmp    f01058af <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010580f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105813:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010581a:	ff d6                	call   *%esi
			putch('X', putdat);
f010581c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105820:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105827:	ff d6                	call   *%esi
			putch('X', putdat);
f0105829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010582d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105834:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105836:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105839:	e9 8b fc ff ff       	jmp    f01054c9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010583e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105842:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105849:	ff d6                	call   *%esi
			putch('x', putdat);
f010584b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010584f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105856:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105858:	8b 45 14             	mov    0x14(%ebp),%eax
f010585b:	8b 10                	mov    (%eax),%edx
f010585d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0105862:	8d 40 04             	lea    0x4(%eax),%eax
f0105865:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105868:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010586d:	eb 40                	jmp    f01058af <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010586f:	83 f9 01             	cmp    $0x1,%ecx
f0105872:	7e 10                	jle    f0105884 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0105874:	8b 45 14             	mov    0x14(%ebp),%eax
f0105877:	8b 10                	mov    (%eax),%edx
f0105879:	8b 48 04             	mov    0x4(%eax),%ecx
f010587c:	8d 40 08             	lea    0x8(%eax),%eax
f010587f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105882:	eb 26                	jmp    f01058aa <vprintfmt+0x406>
	else if (lflag)
f0105884:	85 c9                	test   %ecx,%ecx
f0105886:	74 12                	je     f010589a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0105888:	8b 45 14             	mov    0x14(%ebp),%eax
f010588b:	8b 10                	mov    (%eax),%edx
f010588d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105892:	8d 40 04             	lea    0x4(%eax),%eax
f0105895:	89 45 14             	mov    %eax,0x14(%ebp)
f0105898:	eb 10                	jmp    f01058aa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f010589a:	8b 45 14             	mov    0x14(%ebp),%eax
f010589d:	8b 10                	mov    (%eax),%edx
f010589f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058a4:	8d 40 04             	lea    0x4(%eax),%eax
f01058a7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01058aa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01058af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01058b3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01058b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058be:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01058c2:	89 14 24             	mov    %edx,(%esp)
f01058c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01058c9:	89 da                	mov    %ebx,%edx
f01058cb:	89 f0                	mov    %esi,%eax
f01058cd:	e8 9e fa ff ff       	call   f0105370 <printnum>
			break;
f01058d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058d5:	e9 ef fb ff ff       	jmp    f01054c9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01058da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058de:	89 04 24             	mov    %eax,(%esp)
f01058e1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01058e6:	e9 de fb ff ff       	jmp    f01054c9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01058eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058ef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01058f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01058f8:	eb 03                	jmp    f01058fd <vprintfmt+0x459>
f01058fa:	83 ef 01             	sub    $0x1,%edi
f01058fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105901:	75 f7                	jne    f01058fa <vprintfmt+0x456>
f0105903:	e9 c1 fb ff ff       	jmp    f01054c9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0105908:	83 c4 3c             	add    $0x3c,%esp
f010590b:	5b                   	pop    %ebx
f010590c:	5e                   	pop    %esi
f010590d:	5f                   	pop    %edi
f010590e:	5d                   	pop    %ebp
f010590f:	c3                   	ret    

f0105910 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105910:	55                   	push   %ebp
f0105911:	89 e5                	mov    %esp,%ebp
f0105913:	83 ec 28             	sub    $0x28,%esp
f0105916:	8b 45 08             	mov    0x8(%ebp),%eax
f0105919:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010591c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010591f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105923:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105926:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010592d:	85 c0                	test   %eax,%eax
f010592f:	74 30                	je     f0105961 <vsnprintf+0x51>
f0105931:	85 d2                	test   %edx,%edx
f0105933:	7e 2c                	jle    f0105961 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105935:	8b 45 14             	mov    0x14(%ebp),%eax
f0105938:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010593c:	8b 45 10             	mov    0x10(%ebp),%eax
f010593f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105943:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105946:	89 44 24 04          	mov    %eax,0x4(%esp)
f010594a:	c7 04 24 5f 54 10 f0 	movl   $0xf010545f,(%esp)
f0105951:	e8 4e fb ff ff       	call   f01054a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105956:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105959:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010595c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010595f:	eb 05                	jmp    f0105966 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105961:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105966:	c9                   	leave  
f0105967:	c3                   	ret    

f0105968 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105968:	55                   	push   %ebp
f0105969:	89 e5                	mov    %esp,%ebp
f010596b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010596e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105971:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105975:	8b 45 10             	mov    0x10(%ebp),%eax
f0105978:	89 44 24 08          	mov    %eax,0x8(%esp)
f010597c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010597f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105983:	8b 45 08             	mov    0x8(%ebp),%eax
f0105986:	89 04 24             	mov    %eax,(%esp)
f0105989:	e8 82 ff ff ff       	call   f0105910 <vsnprintf>
	va_end(ap);

	return rc;
}
f010598e:	c9                   	leave  
f010598f:	c3                   	ret    

f0105990 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105990:	55                   	push   %ebp
f0105991:	89 e5                	mov    %esp,%ebp
f0105993:	57                   	push   %edi
f0105994:	56                   	push   %esi
f0105995:	53                   	push   %ebx
f0105996:	83 ec 1c             	sub    $0x1c,%esp
f0105999:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010599c:	85 c0                	test   %eax,%eax
f010599e:	74 10                	je     f01059b0 <readline+0x20>
		cprintf("%s", prompt);
f01059a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059a4:	c7 04 24 91 77 10 f0 	movl   $0xf0107791,(%esp)
f01059ab:	e8 c2 e5 ff ff       	call   f0103f72 <cprintf>

	i = 0;
	echoing = iscons(0);
f01059b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01059b7:	e8 ff ad ff ff       	call   f01007bb <iscons>
f01059bc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01059be:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01059c3:	e8 e2 ad ff ff       	call   f01007aa <getchar>
f01059c8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01059ca:	85 c0                	test   %eax,%eax
f01059cc:	79 17                	jns    f01059e5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01059ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059d2:	c7 04 24 28 82 10 f0 	movl   $0xf0108228,(%esp)
f01059d9:	e8 94 e5 ff ff       	call   f0103f72 <cprintf>
			return NULL;
f01059de:	b8 00 00 00 00       	mov    $0x0,%eax
f01059e3:	eb 6d                	jmp    f0105a52 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01059e5:	83 f8 7f             	cmp    $0x7f,%eax
f01059e8:	74 05                	je     f01059ef <readline+0x5f>
f01059ea:	83 f8 08             	cmp    $0x8,%eax
f01059ed:	75 19                	jne    f0105a08 <readline+0x78>
f01059ef:	85 f6                	test   %esi,%esi
f01059f1:	7e 15                	jle    f0105a08 <readline+0x78>
			if (echoing)
f01059f3:	85 ff                	test   %edi,%edi
f01059f5:	74 0c                	je     f0105a03 <readline+0x73>
				cputchar('\b');
f01059f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01059fe:	e8 97 ad ff ff       	call   f010079a <cputchar>
			i--;
f0105a03:	83 ee 01             	sub    $0x1,%esi
f0105a06:	eb bb                	jmp    f01059c3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105a08:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105a0e:	7f 1c                	jg     f0105a2c <readline+0x9c>
f0105a10:	83 fb 1f             	cmp    $0x1f,%ebx
f0105a13:	7e 17                	jle    f0105a2c <readline+0x9c>
			if (echoing)
f0105a15:	85 ff                	test   %edi,%edi
f0105a17:	74 08                	je     f0105a21 <readline+0x91>
				cputchar(c);
f0105a19:	89 1c 24             	mov    %ebx,(%esp)
f0105a1c:	e8 79 ad ff ff       	call   f010079a <cputchar>
			buf[i++] = c;
f0105a21:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f0105a27:	8d 76 01             	lea    0x1(%esi),%esi
f0105a2a:	eb 97                	jmp    f01059c3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105a2c:	83 fb 0d             	cmp    $0xd,%ebx
f0105a2f:	74 05                	je     f0105a36 <readline+0xa6>
f0105a31:	83 fb 0a             	cmp    $0xa,%ebx
f0105a34:	75 8d                	jne    f01059c3 <readline+0x33>
			if (echoing)
f0105a36:	85 ff                	test   %edi,%edi
f0105a38:	74 0c                	je     f0105a46 <readline+0xb6>
				cputchar('\n');
f0105a3a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105a41:	e8 54 ad ff ff       	call   f010079a <cputchar>
			buf[i] = 0;
f0105a46:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f0105a4d:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f0105a52:	83 c4 1c             	add    $0x1c,%esp
f0105a55:	5b                   	pop    %ebx
f0105a56:	5e                   	pop    %esi
f0105a57:	5f                   	pop    %edi
f0105a58:	5d                   	pop    %ebp
f0105a59:	c3                   	ret    
f0105a5a:	66 90                	xchg   %ax,%ax
f0105a5c:	66 90                	xchg   %ax,%ax
f0105a5e:	66 90                	xchg   %ax,%ax

f0105a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105a60:	55                   	push   %ebp
f0105a61:	89 e5                	mov    %esp,%ebp
f0105a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a66:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6b:	eb 03                	jmp    f0105a70 <strlen+0x10>
		n++;
f0105a6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105a74:	75 f7                	jne    f0105a6d <strlen+0xd>
		n++;
	return n;
}
f0105a76:	5d                   	pop    %ebp
f0105a77:	c3                   	ret    

f0105a78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105a78:	55                   	push   %ebp
f0105a79:	89 e5                	mov    %esp,%ebp
f0105a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a81:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a86:	eb 03                	jmp    f0105a8b <strnlen+0x13>
		n++;
f0105a88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a8b:	39 d0                	cmp    %edx,%eax
f0105a8d:	74 06                	je     f0105a95 <strnlen+0x1d>
f0105a8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105a93:	75 f3                	jne    f0105a88 <strnlen+0x10>
		n++;
	return n;
}
f0105a95:	5d                   	pop    %ebp
f0105a96:	c3                   	ret    

f0105a97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105a97:	55                   	push   %ebp
f0105a98:	89 e5                	mov    %esp,%ebp
f0105a9a:	53                   	push   %ebx
f0105a9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105aa1:	89 c2                	mov    %eax,%edx
f0105aa3:	83 c2 01             	add    $0x1,%edx
f0105aa6:	83 c1 01             	add    $0x1,%ecx
f0105aa9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105aad:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105ab0:	84 db                	test   %bl,%bl
f0105ab2:	75 ef                	jne    f0105aa3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105ab4:	5b                   	pop    %ebx
f0105ab5:	5d                   	pop    %ebp
f0105ab6:	c3                   	ret    

f0105ab7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105ab7:	55                   	push   %ebp
f0105ab8:	89 e5                	mov    %esp,%ebp
f0105aba:	53                   	push   %ebx
f0105abb:	83 ec 08             	sub    $0x8,%esp
f0105abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ac1:	89 1c 24             	mov    %ebx,(%esp)
f0105ac4:	e8 97 ff ff ff       	call   f0105a60 <strlen>
	strcpy(dst + len, src);
f0105ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105acc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ad0:	01 d8                	add    %ebx,%eax
f0105ad2:	89 04 24             	mov    %eax,(%esp)
f0105ad5:	e8 bd ff ff ff       	call   f0105a97 <strcpy>
	return dst;
}
f0105ada:	89 d8                	mov    %ebx,%eax
f0105adc:	83 c4 08             	add    $0x8,%esp
f0105adf:	5b                   	pop    %ebx
f0105ae0:	5d                   	pop    %ebp
f0105ae1:	c3                   	ret    

f0105ae2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ae2:	55                   	push   %ebp
f0105ae3:	89 e5                	mov    %esp,%ebp
f0105ae5:	56                   	push   %esi
f0105ae6:	53                   	push   %ebx
f0105ae7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105aed:	89 f3                	mov    %esi,%ebx
f0105aef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105af2:	89 f2                	mov    %esi,%edx
f0105af4:	eb 0f                	jmp    f0105b05 <strncpy+0x23>
		*dst++ = *src;
f0105af6:	83 c2 01             	add    $0x1,%edx
f0105af9:	0f b6 01             	movzbl (%ecx),%eax
f0105afc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105aff:	80 39 01             	cmpb   $0x1,(%ecx)
f0105b02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105b05:	39 da                	cmp    %ebx,%edx
f0105b07:	75 ed                	jne    f0105af6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105b09:	89 f0                	mov    %esi,%eax
f0105b0b:	5b                   	pop    %ebx
f0105b0c:	5e                   	pop    %esi
f0105b0d:	5d                   	pop    %ebp
f0105b0e:	c3                   	ret    

f0105b0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105b0f:	55                   	push   %ebp
f0105b10:	89 e5                	mov    %esp,%ebp
f0105b12:	56                   	push   %esi
f0105b13:	53                   	push   %ebx
f0105b14:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b17:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105b1d:	89 f0                	mov    %esi,%eax
f0105b1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105b23:	85 c9                	test   %ecx,%ecx
f0105b25:	75 0b                	jne    f0105b32 <strlcpy+0x23>
f0105b27:	eb 1d                	jmp    f0105b46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105b29:	83 c0 01             	add    $0x1,%eax
f0105b2c:	83 c2 01             	add    $0x1,%edx
f0105b2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105b32:	39 d8                	cmp    %ebx,%eax
f0105b34:	74 0b                	je     f0105b41 <strlcpy+0x32>
f0105b36:	0f b6 0a             	movzbl (%edx),%ecx
f0105b39:	84 c9                	test   %cl,%cl
f0105b3b:	75 ec                	jne    f0105b29 <strlcpy+0x1a>
f0105b3d:	89 c2                	mov    %eax,%edx
f0105b3f:	eb 02                	jmp    f0105b43 <strlcpy+0x34>
f0105b41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105b43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105b46:	29 f0                	sub    %esi,%eax
}
f0105b48:	5b                   	pop    %ebx
f0105b49:	5e                   	pop    %esi
f0105b4a:	5d                   	pop    %ebp
f0105b4b:	c3                   	ret    

f0105b4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105b4c:	55                   	push   %ebp
f0105b4d:	89 e5                	mov    %esp,%ebp
f0105b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105b55:	eb 06                	jmp    f0105b5d <strcmp+0x11>
		p++, q++;
f0105b57:	83 c1 01             	add    $0x1,%ecx
f0105b5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105b5d:	0f b6 01             	movzbl (%ecx),%eax
f0105b60:	84 c0                	test   %al,%al
f0105b62:	74 04                	je     f0105b68 <strcmp+0x1c>
f0105b64:	3a 02                	cmp    (%edx),%al
f0105b66:	74 ef                	je     f0105b57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b68:	0f b6 c0             	movzbl %al,%eax
f0105b6b:	0f b6 12             	movzbl (%edx),%edx
f0105b6e:	29 d0                	sub    %edx,%eax
}
f0105b70:	5d                   	pop    %ebp
f0105b71:	c3                   	ret    

f0105b72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105b72:	55                   	push   %ebp
f0105b73:	89 e5                	mov    %esp,%ebp
f0105b75:	53                   	push   %ebx
f0105b76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b79:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b7c:	89 c3                	mov    %eax,%ebx
f0105b7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105b81:	eb 06                	jmp    f0105b89 <strncmp+0x17>
		n--, p++, q++;
f0105b83:	83 c0 01             	add    $0x1,%eax
f0105b86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105b89:	39 d8                	cmp    %ebx,%eax
f0105b8b:	74 15                	je     f0105ba2 <strncmp+0x30>
f0105b8d:	0f b6 08             	movzbl (%eax),%ecx
f0105b90:	84 c9                	test   %cl,%cl
f0105b92:	74 04                	je     f0105b98 <strncmp+0x26>
f0105b94:	3a 0a                	cmp    (%edx),%cl
f0105b96:	74 eb                	je     f0105b83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b98:	0f b6 00             	movzbl (%eax),%eax
f0105b9b:	0f b6 12             	movzbl (%edx),%edx
f0105b9e:	29 d0                	sub    %edx,%eax
f0105ba0:	eb 05                	jmp    f0105ba7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105ba2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ba7:	5b                   	pop    %ebx
f0105ba8:	5d                   	pop    %ebp
f0105ba9:	c3                   	ret    

f0105baa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105baa:	55                   	push   %ebp
f0105bab:	89 e5                	mov    %esp,%ebp
f0105bad:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105bb4:	eb 07                	jmp    f0105bbd <strchr+0x13>
		if (*s == c)
f0105bb6:	38 ca                	cmp    %cl,%dl
f0105bb8:	74 0f                	je     f0105bc9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105bba:	83 c0 01             	add    $0x1,%eax
f0105bbd:	0f b6 10             	movzbl (%eax),%edx
f0105bc0:	84 d2                	test   %dl,%dl
f0105bc2:	75 f2                	jne    f0105bb6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105bc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bc9:	5d                   	pop    %ebp
f0105bca:	c3                   	ret    

f0105bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105bcb:	55                   	push   %ebp
f0105bcc:	89 e5                	mov    %esp,%ebp
f0105bce:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105bd5:	eb 07                	jmp    f0105bde <strfind+0x13>
		if (*s == c)
f0105bd7:	38 ca                	cmp    %cl,%dl
f0105bd9:	74 0a                	je     f0105be5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105bdb:	83 c0 01             	add    $0x1,%eax
f0105bde:	0f b6 10             	movzbl (%eax),%edx
f0105be1:	84 d2                	test   %dl,%dl
f0105be3:	75 f2                	jne    f0105bd7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105be5:	5d                   	pop    %ebp
f0105be6:	c3                   	ret    

f0105be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105be7:	55                   	push   %ebp
f0105be8:	89 e5                	mov    %esp,%ebp
f0105bea:	57                   	push   %edi
f0105beb:	56                   	push   %esi
f0105bec:	53                   	push   %ebx
f0105bed:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105bf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105bf3:	85 c9                	test   %ecx,%ecx
f0105bf5:	74 36                	je     f0105c2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105bf7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105bfd:	75 28                	jne    f0105c27 <memset+0x40>
f0105bff:	f6 c1 03             	test   $0x3,%cl
f0105c02:	75 23                	jne    f0105c27 <memset+0x40>
		c &= 0xFF;
f0105c04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105c08:	89 d3                	mov    %edx,%ebx
f0105c0a:	c1 e3 08             	shl    $0x8,%ebx
f0105c0d:	89 d6                	mov    %edx,%esi
f0105c0f:	c1 e6 18             	shl    $0x18,%esi
f0105c12:	89 d0                	mov    %edx,%eax
f0105c14:	c1 e0 10             	shl    $0x10,%eax
f0105c17:	09 f0                	or     %esi,%eax
f0105c19:	09 c2                	or     %eax,%edx
f0105c1b:	89 d0                	mov    %edx,%eax
f0105c1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105c1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105c22:	fc                   	cld    
f0105c23:	f3 ab                	rep stos %eax,%es:(%edi)
f0105c25:	eb 06                	jmp    f0105c2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105c27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c2a:	fc                   	cld    
f0105c2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105c2d:	89 f8                	mov    %edi,%eax
f0105c2f:	5b                   	pop    %ebx
f0105c30:	5e                   	pop    %esi
f0105c31:	5f                   	pop    %edi
f0105c32:	5d                   	pop    %ebp
f0105c33:	c3                   	ret    

f0105c34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105c34:	55                   	push   %ebp
f0105c35:	89 e5                	mov    %esp,%ebp
f0105c37:	57                   	push   %edi
f0105c38:	56                   	push   %esi
f0105c39:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105c42:	39 c6                	cmp    %eax,%esi
f0105c44:	73 35                	jae    f0105c7b <memmove+0x47>
f0105c46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105c49:	39 d0                	cmp    %edx,%eax
f0105c4b:	73 2e                	jae    f0105c7b <memmove+0x47>
		s += n;
		d += n;
f0105c4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105c50:	89 d6                	mov    %edx,%esi
f0105c52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c54:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105c5a:	75 13                	jne    f0105c6f <memmove+0x3b>
f0105c5c:	f6 c1 03             	test   $0x3,%cl
f0105c5f:	75 0e                	jne    f0105c6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105c61:	83 ef 04             	sub    $0x4,%edi
f0105c64:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105c67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105c6a:	fd                   	std    
f0105c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c6d:	eb 09                	jmp    f0105c78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105c6f:	83 ef 01             	sub    $0x1,%edi
f0105c72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105c75:	fd                   	std    
f0105c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105c78:	fc                   	cld    
f0105c79:	eb 1d                	jmp    f0105c98 <memmove+0x64>
f0105c7b:	89 f2                	mov    %esi,%edx
f0105c7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c7f:	f6 c2 03             	test   $0x3,%dl
f0105c82:	75 0f                	jne    f0105c93 <memmove+0x5f>
f0105c84:	f6 c1 03             	test   $0x3,%cl
f0105c87:	75 0a                	jne    f0105c93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105c89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105c8c:	89 c7                	mov    %eax,%edi
f0105c8e:	fc                   	cld    
f0105c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c91:	eb 05                	jmp    f0105c98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105c93:	89 c7                	mov    %eax,%edi
f0105c95:	fc                   	cld    
f0105c96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105c98:	5e                   	pop    %esi
f0105c99:	5f                   	pop    %edi
f0105c9a:	5d                   	pop    %ebp
f0105c9b:	c3                   	ret    

f0105c9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105c9c:	55                   	push   %ebp
f0105c9d:	89 e5                	mov    %esp,%ebp
f0105c9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ca2:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105cac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cb3:	89 04 24             	mov    %eax,(%esp)
f0105cb6:	e8 79 ff ff ff       	call   f0105c34 <memmove>
}
f0105cbb:	c9                   	leave  
f0105cbc:	c3                   	ret    

f0105cbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105cbd:	55                   	push   %ebp
f0105cbe:	89 e5                	mov    %esp,%ebp
f0105cc0:	56                   	push   %esi
f0105cc1:	53                   	push   %ebx
f0105cc2:	8b 55 08             	mov    0x8(%ebp),%edx
f0105cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105cc8:	89 d6                	mov    %edx,%esi
f0105cca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ccd:	eb 1a                	jmp    f0105ce9 <memcmp+0x2c>
		if (*s1 != *s2)
f0105ccf:	0f b6 02             	movzbl (%edx),%eax
f0105cd2:	0f b6 19             	movzbl (%ecx),%ebx
f0105cd5:	38 d8                	cmp    %bl,%al
f0105cd7:	74 0a                	je     f0105ce3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105cd9:	0f b6 c0             	movzbl %al,%eax
f0105cdc:	0f b6 db             	movzbl %bl,%ebx
f0105cdf:	29 d8                	sub    %ebx,%eax
f0105ce1:	eb 0f                	jmp    f0105cf2 <memcmp+0x35>
		s1++, s2++;
f0105ce3:	83 c2 01             	add    $0x1,%edx
f0105ce6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ce9:	39 f2                	cmp    %esi,%edx
f0105ceb:	75 e2                	jne    f0105ccf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cf2:	5b                   	pop    %ebx
f0105cf3:	5e                   	pop    %esi
f0105cf4:	5d                   	pop    %ebp
f0105cf5:	c3                   	ret    

f0105cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105cf6:	55                   	push   %ebp
f0105cf7:	89 e5                	mov    %esp,%ebp
f0105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105cff:	89 c2                	mov    %eax,%edx
f0105d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105d04:	eb 07                	jmp    f0105d0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105d06:	38 08                	cmp    %cl,(%eax)
f0105d08:	74 07                	je     f0105d11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105d0a:	83 c0 01             	add    $0x1,%eax
f0105d0d:	39 d0                	cmp    %edx,%eax
f0105d0f:	72 f5                	jb     f0105d06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105d11:	5d                   	pop    %ebp
f0105d12:	c3                   	ret    

f0105d13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105d13:	55                   	push   %ebp
f0105d14:	89 e5                	mov    %esp,%ebp
f0105d16:	57                   	push   %edi
f0105d17:	56                   	push   %esi
f0105d18:	53                   	push   %ebx
f0105d19:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d1f:	eb 03                	jmp    f0105d24 <strtol+0x11>
		s++;
f0105d21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d24:	0f b6 0a             	movzbl (%edx),%ecx
f0105d27:	80 f9 09             	cmp    $0x9,%cl
f0105d2a:	74 f5                	je     f0105d21 <strtol+0xe>
f0105d2c:	80 f9 20             	cmp    $0x20,%cl
f0105d2f:	74 f0                	je     f0105d21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105d31:	80 f9 2b             	cmp    $0x2b,%cl
f0105d34:	75 0a                	jne    f0105d40 <strtol+0x2d>
		s++;
f0105d36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105d39:	bf 00 00 00 00       	mov    $0x0,%edi
f0105d3e:	eb 11                	jmp    f0105d51 <strtol+0x3e>
f0105d40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105d45:	80 f9 2d             	cmp    $0x2d,%cl
f0105d48:	75 07                	jne    f0105d51 <strtol+0x3e>
		s++, neg = 1;
f0105d4a:	8d 52 01             	lea    0x1(%edx),%edx
f0105d4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105d56:	75 15                	jne    f0105d6d <strtol+0x5a>
f0105d58:	80 3a 30             	cmpb   $0x30,(%edx)
f0105d5b:	75 10                	jne    f0105d6d <strtol+0x5a>
f0105d5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105d61:	75 0a                	jne    f0105d6d <strtol+0x5a>
		s += 2, base = 16;
f0105d63:	83 c2 02             	add    $0x2,%edx
f0105d66:	b8 10 00 00 00       	mov    $0x10,%eax
f0105d6b:	eb 10                	jmp    f0105d7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0105d6d:	85 c0                	test   %eax,%eax
f0105d6f:	75 0c                	jne    f0105d7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105d71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105d73:	80 3a 30             	cmpb   $0x30,(%edx)
f0105d76:	75 05                	jne    f0105d7d <strtol+0x6a>
		s++, base = 8;
f0105d78:	83 c2 01             	add    $0x1,%edx
f0105d7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0105d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105d85:	0f b6 0a             	movzbl (%edx),%ecx
f0105d88:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105d8b:	89 f0                	mov    %esi,%eax
f0105d8d:	3c 09                	cmp    $0x9,%al
f0105d8f:	77 08                	ja     f0105d99 <strtol+0x86>
			dig = *s - '0';
f0105d91:	0f be c9             	movsbl %cl,%ecx
f0105d94:	83 e9 30             	sub    $0x30,%ecx
f0105d97:	eb 20                	jmp    f0105db9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105d99:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105d9c:	89 f0                	mov    %esi,%eax
f0105d9e:	3c 19                	cmp    $0x19,%al
f0105da0:	77 08                	ja     f0105daa <strtol+0x97>
			dig = *s - 'a' + 10;
f0105da2:	0f be c9             	movsbl %cl,%ecx
f0105da5:	83 e9 57             	sub    $0x57,%ecx
f0105da8:	eb 0f                	jmp    f0105db9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105daa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105dad:	89 f0                	mov    %esi,%eax
f0105daf:	3c 19                	cmp    $0x19,%al
f0105db1:	77 16                	ja     f0105dc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0105db3:	0f be c9             	movsbl %cl,%ecx
f0105db6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105db9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105dbc:	7d 0f                	jge    f0105dcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0105dbe:	83 c2 01             	add    $0x1,%edx
f0105dc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0105dc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0105dc7:	eb bc                	jmp    f0105d85 <strtol+0x72>
f0105dc9:	89 d8                	mov    %ebx,%eax
f0105dcb:	eb 02                	jmp    f0105dcf <strtol+0xbc>
f0105dcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0105dcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105dd3:	74 05                	je     f0105dda <strtol+0xc7>
		*endptr = (char *) s;
f0105dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105dda:	f7 d8                	neg    %eax
f0105ddc:	85 ff                	test   %edi,%edi
f0105dde:	0f 44 c3             	cmove  %ebx,%eax
}
f0105de1:	5b                   	pop    %ebx
f0105de2:	5e                   	pop    %esi
f0105de3:	5f                   	pop    %edi
f0105de4:	5d                   	pop    %ebp
f0105de5:	c3                   	ret    
f0105de6:	66 90                	xchg   %ax,%ax

f0105de8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105de8:	fa                   	cli    

	xorw    %ax, %ax
f0105de9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105deb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ded:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105def:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105df1:	0f 01 16             	lgdtl  (%esi)
f0105df4:	74 70                	je     f0105e66 <mpentry_end+0x4>
	movl    %cr0, %eax
f0105df6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105df9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105dfd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105e00:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105e06:	08 00                	or     %al,(%eax)

f0105e08 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105e08:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105e0c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105e0e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105e10:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105e12:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105e16:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105e18:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105e1a:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105e1f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105e22:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105e25:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105e2a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105e2d:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105e33:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105e38:	b8 f6 01 10 f0       	mov    $0xf01001f6,%eax
	call    *%eax
f0105e3d:	ff d0                	call   *%eax

f0105e3f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105e3f:	eb fe                	jmp    f0105e3f <spin>
f0105e41:	8d 76 00             	lea    0x0(%esi),%esi

f0105e44 <gdt>:
	...
f0105e4c:	ff                   	(bad)  
f0105e4d:	ff 00                	incl   (%eax)
f0105e4f:	00 00                	add    %al,(%eax)
f0105e51:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105e58:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105e5c <gdtdesc>:
f0105e5c:	17                   	pop    %ss
f0105e5d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105e62 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105e62:	90                   	nop
f0105e63:	66 90                	xchg   %ax,%ax
f0105e65:	66 90                	xchg   %ax,%ax
f0105e67:	66 90                	xchg   %ax,%ax
f0105e69:	66 90                	xchg   %ax,%ax
f0105e6b:	66 90                	xchg   %ax,%ax
f0105e6d:	66 90                	xchg   %ax,%ax
f0105e6f:	90                   	nop

f0105e70 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105e70:	55                   	push   %ebp
f0105e71:	89 e5                	mov    %esp,%ebp
f0105e73:	56                   	push   %esi
f0105e74:	53                   	push   %ebx
f0105e75:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e78:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0105e7e:	89 c3                	mov    %eax,%ebx
f0105e80:	c1 eb 0c             	shr    $0xc,%ebx
f0105e83:	39 cb                	cmp    %ecx,%ebx
f0105e85:	72 20                	jb     f0105ea7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e8b:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0105e92:	f0 
f0105e93:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105e9a:	00 
f0105e9b:	c7 04 24 c5 83 10 f0 	movl   $0xf01083c5,(%esp)
f0105ea2:	e8 99 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ea7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105ead:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105eaf:	89 c2                	mov    %eax,%edx
f0105eb1:	c1 ea 0c             	shr    $0xc,%edx
f0105eb4:	39 d1                	cmp    %edx,%ecx
f0105eb6:	77 20                	ja     f0105ed8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ebc:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0105ec3:	f0 
f0105ec4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105ecb:	00 
f0105ecc:	c7 04 24 c5 83 10 f0 	movl   $0xf01083c5,(%esp)
f0105ed3:	e8 68 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ed8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105ede:	eb 36                	jmp    f0105f16 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ee0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105ee7:	00 
f0105ee8:	c7 44 24 04 d5 83 10 	movl   $0xf01083d5,0x4(%esp)
f0105eef:	f0 
f0105ef0:	89 1c 24             	mov    %ebx,(%esp)
f0105ef3:	e8 c5 fd ff ff       	call   f0105cbd <memcmp>
f0105ef8:	85 c0                	test   %eax,%eax
f0105efa:	75 17                	jne    f0105f13 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105efc:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0105f01:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105f05:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f07:	83 c2 01             	add    $0x1,%edx
f0105f0a:	83 fa 10             	cmp    $0x10,%edx
f0105f0d:	75 f2                	jne    f0105f01 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105f0f:	84 c0                	test   %al,%al
f0105f11:	74 0e                	je     f0105f21 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105f13:	83 c3 10             	add    $0x10,%ebx
f0105f16:	39 f3                	cmp    %esi,%ebx
f0105f18:	72 c6                	jb     f0105ee0 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f1f:	eb 02                	jmp    f0105f23 <mpsearch1+0xb3>
f0105f21:	89 d8                	mov    %ebx,%eax
}
f0105f23:	83 c4 10             	add    $0x10,%esp
f0105f26:	5b                   	pop    %ebx
f0105f27:	5e                   	pop    %esi
f0105f28:	5d                   	pop    %ebp
f0105f29:	c3                   	ret    

f0105f2a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105f2a:	55                   	push   %ebp
f0105f2b:	89 e5                	mov    %esp,%ebp
f0105f2d:	57                   	push   %edi
f0105f2e:	56                   	push   %esi
f0105f2f:	53                   	push   %ebx
f0105f30:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105f33:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f0105f3a:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f3d:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105f44:	75 24                	jne    f0105f6a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f46:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0105f4d:	00 
f0105f4e:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0105f55:	f0 
f0105f56:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0105f5d:	00 
f0105f5e:	c7 04 24 c5 83 10 f0 	movl   $0xf01083c5,(%esp)
f0105f65:	e8 d6 a0 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105f6a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105f71:	85 c0                	test   %eax,%eax
f0105f73:	74 16                	je     f0105f8b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0105f75:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105f78:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f7d:	e8 ee fe ff ff       	call   f0105e70 <mpsearch1>
f0105f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f85:	85 c0                	test   %eax,%eax
f0105f87:	75 3c                	jne    f0105fc5 <mp_init+0x9b>
f0105f89:	eb 20                	jmp    f0105fab <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105f8b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105f92:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105f95:	2d 00 04 00 00       	sub    $0x400,%eax
f0105f9a:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f9f:	e8 cc fe ff ff       	call   f0105e70 <mpsearch1>
f0105fa4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105fa7:	85 c0                	test   %eax,%eax
f0105fa9:	75 1a                	jne    f0105fc5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105fab:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fb0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105fb5:	e8 b6 fe ff ff       	call   f0105e70 <mpsearch1>
f0105fba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105fbd:	85 c0                	test   %eax,%eax
f0105fbf:	0f 84 54 02 00 00    	je     f0106219 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105fc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105fc8:	8b 70 04             	mov    0x4(%eax),%esi
f0105fcb:	85 f6                	test   %esi,%esi
f0105fcd:	74 06                	je     f0105fd5 <mp_init+0xab>
f0105fcf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105fd3:	74 11                	je     f0105fe6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0105fd5:	c7 04 24 38 82 10 f0 	movl   $0xf0108238,(%esp)
f0105fdc:	e8 91 df ff ff       	call   f0103f72 <cprintf>
f0105fe1:	e9 33 02 00 00       	jmp    f0106219 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105fe6:	89 f0                	mov    %esi,%eax
f0105fe8:	c1 e8 0c             	shr    $0xc,%eax
f0105feb:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0105ff1:	72 20                	jb     f0106013 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ff3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ff7:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f0105ffe:	f0 
f0105fff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106006:	00 
f0106007:	c7 04 24 c5 83 10 f0 	movl   $0xf01083c5,(%esp)
f010600e:	e8 2d a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106013:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106019:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106020:	00 
f0106021:	c7 44 24 04 da 83 10 	movl   $0xf01083da,0x4(%esp)
f0106028:	f0 
f0106029:	89 1c 24             	mov    %ebx,(%esp)
f010602c:	e8 8c fc ff ff       	call   f0105cbd <memcmp>
f0106031:	85 c0                	test   %eax,%eax
f0106033:	74 11                	je     f0106046 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106035:	c7 04 24 68 82 10 f0 	movl   $0xf0108268,(%esp)
f010603c:	e8 31 df ff ff       	call   f0103f72 <cprintf>
f0106041:	e9 d3 01 00 00       	jmp    f0106219 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106046:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010604a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010604e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106051:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106056:	b8 00 00 00 00       	mov    $0x0,%eax
f010605b:	eb 0d                	jmp    f010606a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f010605d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106064:	f0 
f0106065:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106067:	83 c0 01             	add    $0x1,%eax
f010606a:	39 c7                	cmp    %eax,%edi
f010606c:	7f ef                	jg     f010605d <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010606e:	84 d2                	test   %dl,%dl
f0106070:	74 11                	je     f0106083 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106072:	c7 04 24 9c 82 10 f0 	movl   $0xf010829c,(%esp)
f0106079:	e8 f4 de ff ff       	call   f0103f72 <cprintf>
f010607e:	e9 96 01 00 00       	jmp    f0106219 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106083:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106087:	3c 04                	cmp    $0x4,%al
f0106089:	74 1f                	je     f01060aa <mp_init+0x180>
f010608b:	3c 01                	cmp    $0x1,%al
f010608d:	8d 76 00             	lea    0x0(%esi),%esi
f0106090:	74 18                	je     f01060aa <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106092:	0f b6 c0             	movzbl %al,%eax
f0106095:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106099:	c7 04 24 c0 82 10 f0 	movl   $0xf01082c0,(%esp)
f01060a0:	e8 cd de ff ff       	call   f0103f72 <cprintf>
f01060a5:	e9 6f 01 00 00       	jmp    f0106219 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01060aa:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01060ae:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01060b2:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01060b4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01060b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01060be:	eb 09                	jmp    f01060c9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f01060c0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01060c4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01060c6:	83 c0 01             	add    $0x1,%eax
f01060c9:	39 c6                	cmp    %eax,%esi
f01060cb:	7f f3                	jg     f01060c0 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01060cd:	02 53 2a             	add    0x2a(%ebx),%dl
f01060d0:	84 d2                	test   %dl,%dl
f01060d2:	74 11                	je     f01060e5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01060d4:	c7 04 24 e0 82 10 f0 	movl   $0xf01082e0,(%esp)
f01060db:	e8 92 de ff ff       	call   f0103f72 <cprintf>
f01060e0:	e9 34 01 00 00       	jmp    f0106219 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01060e5:	85 db                	test   %ebx,%ebx
f01060e7:	0f 84 2c 01 00 00    	je     f0106219 <mp_init+0x2ef>
		return;
	ismp = 1;
f01060ed:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f01060f4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01060f7:	8b 43 24             	mov    0x24(%ebx),%eax
f01060fa:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01060ff:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106102:	be 00 00 00 00       	mov    $0x0,%esi
f0106107:	e9 86 00 00 00       	jmp    f0106192 <mp_init+0x268>
		switch (*p) {
f010610c:	0f b6 07             	movzbl (%edi),%eax
f010610f:	84 c0                	test   %al,%al
f0106111:	74 06                	je     f0106119 <mp_init+0x1ef>
f0106113:	3c 04                	cmp    $0x4,%al
f0106115:	77 57                	ja     f010616e <mp_init+0x244>
f0106117:	eb 50                	jmp    f0106169 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106119:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010611d:	8d 76 00             	lea    0x0(%esi),%esi
f0106120:	74 11                	je     f0106133 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106122:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0106129:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010612e:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f0106133:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f0106138:	83 f8 07             	cmp    $0x7,%eax
f010613b:	7f 13                	jg     f0106150 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010613d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106140:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0106146:	83 c0 01             	add    $0x1,%eax
f0106149:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f010614e:	eb 14                	jmp    f0106164 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106150:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106154:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106158:	c7 04 24 10 83 10 f0 	movl   $0xf0108310,(%esp)
f010615f:	e8 0e de ff ff       	call   f0103f72 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106164:	83 c7 14             	add    $0x14,%edi
			continue;
f0106167:	eb 26                	jmp    f010618f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106169:	83 c7 08             	add    $0x8,%edi
			continue;
f010616c:	eb 21                	jmp    f010618f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010616e:	0f b6 c0             	movzbl %al,%eax
f0106171:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106175:	c7 04 24 38 83 10 f0 	movl   $0xf0108338,(%esp)
f010617c:	e8 f1 dd ff ff       	call   f0103f72 <cprintf>
			ismp = 0;
f0106181:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f0106188:	00 00 00 
			i = conf->entry;
f010618b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010618f:	83 c6 01             	add    $0x1,%esi
f0106192:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106196:	39 c6                	cmp    %eax,%esi
f0106198:	0f 82 6e ff ff ff    	jb     f010610c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010619e:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f01061a3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01061aa:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f01061b1:	75 22                	jne    f01061d5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01061b3:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f01061ba:	00 00 00 
		lapicaddr = 0;
f01061bd:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f01061c4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01061c7:	c7 04 24 58 83 10 f0 	movl   $0xf0108358,(%esp)
f01061ce:	e8 9f dd ff ff       	call   f0103f72 <cprintf>
		return;
f01061d3:	eb 44                	jmp    f0106219 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01061d5:	8b 15 c4 c3 22 f0    	mov    0xf022c3c4,%edx
f01061db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01061df:	0f b6 00             	movzbl (%eax),%eax
f01061e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061e6:	c7 04 24 df 83 10 f0 	movl   $0xf01083df,(%esp)
f01061ed:	e8 80 dd ff ff       	call   f0103f72 <cprintf>

	if (mp->imcrp) {
f01061f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061f5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01061f9:	74 1e                	je     f0106219 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01061fb:	c7 04 24 84 83 10 f0 	movl   $0xf0108384,(%esp)
f0106202:	e8 6b dd ff ff       	call   f0103f72 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106207:	ba 22 00 00 00       	mov    $0x22,%edx
f010620c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106211:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106212:	b2 23                	mov    $0x23,%dl
f0106214:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106215:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106218:	ee                   	out    %al,(%dx)
	}
}
f0106219:	83 c4 2c             	add    $0x2c,%esp
f010621c:	5b                   	pop    %ebx
f010621d:	5e                   	pop    %esi
f010621e:	5f                   	pop    %edi
f010621f:	5d                   	pop    %ebp
f0106220:	c3                   	ret    

f0106221 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106221:	55                   	push   %ebp
f0106222:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106224:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f010622a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010622d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010622f:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106234:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106237:	5d                   	pop    %ebp
f0106238:	c3                   	ret    

f0106239 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106239:	55                   	push   %ebp
f010623a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010623c:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0106241:	85 c0                	test   %eax,%eax
f0106243:	74 08                	je     f010624d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106245:	8b 40 20             	mov    0x20(%eax),%eax
f0106248:	c1 e8 18             	shr    $0x18,%eax
f010624b:	eb 05                	jmp    f0106252 <cpunum+0x19>
	return 0;
f010624d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106252:	5d                   	pop    %ebp
f0106253:	c3                   	ret    

f0106254 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106254:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0106259:	85 c0                	test   %eax,%eax
f010625b:	0f 84 23 01 00 00    	je     f0106384 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106261:	55                   	push   %ebp
f0106262:	89 e5                	mov    %esp,%ebp
f0106264:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106267:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010626e:	00 
f010626f:	89 04 24             	mov    %eax,(%esp)
f0106272:	e8 e0 b0 ff ff       	call   f0101357 <mmio_map_region>
f0106277:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010627c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106281:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106286:	e8 96 ff ff ff       	call   f0106221 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010628b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106290:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106295:	e8 87 ff ff ff       	call   f0106221 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010629a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010629f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01062a4:	e8 78 ff ff ff       	call   f0106221 <lapicw>
	lapicw(TICR, 10000000); 
f01062a9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01062ae:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01062b3:	e8 69 ff ff ff       	call   f0106221 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01062b8:	e8 7c ff ff ff       	call   f0106239 <cpunum>
f01062bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01062c0:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01062c5:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f01062cb:	74 0f                	je     f01062dc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01062cd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062d2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01062d7:	e8 45 ff ff ff       	call   f0106221 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01062dc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062e1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01062e6:	e8 36 ff ff ff       	call   f0106221 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01062eb:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01062f0:	8b 40 30             	mov    0x30(%eax),%eax
f01062f3:	c1 e8 10             	shr    $0x10,%eax
f01062f6:	3c 03                	cmp    $0x3,%al
f01062f8:	76 0f                	jbe    f0106309 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01062fa:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062ff:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106304:	e8 18 ff ff ff       	call   f0106221 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106309:	ba 33 00 00 00       	mov    $0x33,%edx
f010630e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106313:	e8 09 ff ff ff       	call   f0106221 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106318:	ba 00 00 00 00       	mov    $0x0,%edx
f010631d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106322:	e8 fa fe ff ff       	call   f0106221 <lapicw>
	lapicw(ESR, 0);
f0106327:	ba 00 00 00 00       	mov    $0x0,%edx
f010632c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106331:	e8 eb fe ff ff       	call   f0106221 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106336:	ba 00 00 00 00       	mov    $0x0,%edx
f010633b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106340:	e8 dc fe ff ff       	call   f0106221 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106345:	ba 00 00 00 00       	mov    $0x0,%edx
f010634a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010634f:	e8 cd fe ff ff       	call   f0106221 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106354:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106359:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010635e:	e8 be fe ff ff       	call   f0106221 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106363:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0106369:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010636f:	f6 c4 10             	test   $0x10,%ah
f0106372:	75 f5                	jne    f0106369 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106374:	ba 00 00 00 00       	mov    $0x0,%edx
f0106379:	b8 20 00 00 00       	mov    $0x20,%eax
f010637e:	e8 9e fe ff ff       	call   f0106221 <lapicw>
}
f0106383:	c9                   	leave  
f0106384:	f3 c3                	repz ret 

f0106386 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106386:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f010638d:	74 13                	je     f01063a2 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010638f:	55                   	push   %ebp
f0106390:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106392:	ba 00 00 00 00       	mov    $0x0,%edx
f0106397:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010639c:	e8 80 fe ff ff       	call   f0106221 <lapicw>
}
f01063a1:	5d                   	pop    %ebp
f01063a2:	f3 c3                	repz ret 

f01063a4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01063a4:	55                   	push   %ebp
f01063a5:	89 e5                	mov    %esp,%ebp
f01063a7:	56                   	push   %esi
f01063a8:	53                   	push   %ebx
f01063a9:	83 ec 10             	sub    $0x10,%esp
f01063ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01063af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01063b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01063b7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01063bc:	ee                   	out    %al,(%dx)
f01063bd:	b2 71                	mov    $0x71,%dl
f01063bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01063c4:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063c5:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f01063cc:	75 24                	jne    f01063f2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063ce:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01063d5:	00 
f01063d6:	c7 44 24 08 44 69 10 	movl   $0xf0106944,0x8(%esp)
f01063dd:	f0 
f01063de:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01063e5:	00 
f01063e6:	c7 04 24 fc 83 10 f0 	movl   $0xf01083fc,(%esp)
f01063ed:	e8 4e 9c ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01063f2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01063f9:	00 00 
	wrv[1] = addr >> 4;
f01063fb:	89 f0                	mov    %esi,%eax
f01063fd:	c1 e8 04             	shr    $0x4,%eax
f0106400:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106406:	c1 e3 18             	shl    $0x18,%ebx
f0106409:	89 da                	mov    %ebx,%edx
f010640b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106410:	e8 0c fe ff ff       	call   f0106221 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106415:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010641a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010641f:	e8 fd fd ff ff       	call   f0106221 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106424:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106429:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010642e:	e8 ee fd ff ff       	call   f0106221 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106433:	c1 ee 0c             	shr    $0xc,%esi
f0106436:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010643c:	89 da                	mov    %ebx,%edx
f010643e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106443:	e8 d9 fd ff ff       	call   f0106221 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106448:	89 f2                	mov    %esi,%edx
f010644a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010644f:	e8 cd fd ff ff       	call   f0106221 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106454:	89 da                	mov    %ebx,%edx
f0106456:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010645b:	e8 c1 fd ff ff       	call   f0106221 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106460:	89 f2                	mov    %esi,%edx
f0106462:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106467:	e8 b5 fd ff ff       	call   f0106221 <lapicw>
		microdelay(200);
	}
}
f010646c:	83 c4 10             	add    $0x10,%esp
f010646f:	5b                   	pop    %ebx
f0106470:	5e                   	pop    %esi
f0106471:	5d                   	pop    %ebp
f0106472:	c3                   	ret    

f0106473 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106473:	55                   	push   %ebp
f0106474:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106476:	8b 55 08             	mov    0x8(%ebp),%edx
f0106479:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010647f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106484:	e8 98 fd ff ff       	call   f0106221 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106489:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f010648f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106495:	f6 c4 10             	test   $0x10,%ah
f0106498:	75 f5                	jne    f010648f <lapic_ipi+0x1c>
		;
}
f010649a:	5d                   	pop    %ebp
f010649b:	c3                   	ret    

f010649c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010649c:	55                   	push   %ebp
f010649d:	89 e5                	mov    %esp,%ebp
f010649f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01064a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01064a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064ab:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01064ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01064b5:	5d                   	pop    %ebp
f01064b6:	c3                   	ret    

f01064b7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01064b7:	55                   	push   %ebp
f01064b8:	89 e5                	mov    %esp,%ebp
f01064ba:	56                   	push   %esi
f01064bb:	53                   	push   %ebx
f01064bc:	83 ec 20             	sub    $0x20,%esp
f01064bf:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01064c2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01064c5:	75 07                	jne    f01064ce <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01064c7:	ba 01 00 00 00       	mov    $0x1,%edx
f01064cc:	eb 42                	jmp    f0106510 <spin_lock+0x59>
f01064ce:	8b 73 08             	mov    0x8(%ebx),%esi
f01064d1:	e8 63 fd ff ff       	call   f0106239 <cpunum>
f01064d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01064d9:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01064de:	39 c6                	cmp    %eax,%esi
f01064e0:	75 e5                	jne    f01064c7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01064e2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01064e5:	e8 4f fd ff ff       	call   f0106239 <cpunum>
f01064ea:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01064ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064f2:	c7 44 24 08 0c 84 10 	movl   $0xf010840c,0x8(%esp)
f01064f9:	f0 
f01064fa:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106501:	00 
f0106502:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f0106509:	e8 32 9b ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010650e:	f3 90                	pause  
f0106510:	89 d0                	mov    %edx,%eax
f0106512:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106515:	85 c0                	test   %eax,%eax
f0106517:	75 f5                	jne    f010650e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106519:	e8 1b fd ff ff       	call   f0106239 <cpunum>
f010651e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106521:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106526:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106529:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010652c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010652e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106533:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106539:	76 12                	jbe    f010654d <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010653b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010653e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106541:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106543:	83 c0 01             	add    $0x1,%eax
f0106546:	83 f8 0a             	cmp    $0xa,%eax
f0106549:	75 e8                	jne    f0106533 <spin_lock+0x7c>
f010654b:	eb 0f                	jmp    f010655c <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010654d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106554:	83 c0 01             	add    $0x1,%eax
f0106557:	83 f8 09             	cmp    $0x9,%eax
f010655a:	7e f1                	jle    f010654d <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010655c:	83 c4 20             	add    $0x20,%esp
f010655f:	5b                   	pop    %ebx
f0106560:	5e                   	pop    %esi
f0106561:	5d                   	pop    %ebp
f0106562:	c3                   	ret    

f0106563 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106563:	55                   	push   %ebp
f0106564:	89 e5                	mov    %esp,%ebp
f0106566:	57                   	push   %edi
f0106567:	56                   	push   %esi
f0106568:	53                   	push   %ebx
f0106569:	83 ec 6c             	sub    $0x6c,%esp
f010656c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010656f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106572:	74 18                	je     f010658c <spin_unlock+0x29>
f0106574:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106577:	e8 bd fc ff ff       	call   f0106239 <cpunum>
f010657c:	6b c0 74             	imul   $0x74,%eax,%eax
f010657f:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106584:	39 c3                	cmp    %eax,%ebx
f0106586:	0f 84 ce 00 00 00    	je     f010665a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010658c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106593:	00 
f0106594:	8d 46 0c             	lea    0xc(%esi),%eax
f0106597:	89 44 24 04          	mov    %eax,0x4(%esp)
f010659b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010659e:	89 1c 24             	mov    %ebx,(%esp)
f01065a1:	e8 8e f6 ff ff       	call   f0105c34 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01065a6:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01065a9:	0f b6 38             	movzbl (%eax),%edi
f01065ac:	8b 76 04             	mov    0x4(%esi),%esi
f01065af:	e8 85 fc ff ff       	call   f0106239 <cpunum>
f01065b4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01065b8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01065bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065c0:	c7 04 24 38 84 10 f0 	movl   $0xf0108438,(%esp)
f01065c7:	e8 a6 d9 ff ff       	call   f0103f72 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01065cc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01065cf:	eb 65                	jmp    f0106636 <spin_unlock+0xd3>
f01065d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01065d5:	89 04 24             	mov    %eax,(%esp)
f01065d8:	e8 95 ea ff ff       	call   f0105072 <debuginfo_eip>
f01065dd:	85 c0                	test   %eax,%eax
f01065df:	78 39                	js     f010661a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01065e1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01065e3:	89 c2                	mov    %eax,%edx
f01065e5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01065e8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01065ec:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01065ef:	89 54 24 14          	mov    %edx,0x14(%esp)
f01065f3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01065f6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01065fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01065fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106601:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106604:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106608:	89 44 24 04          	mov    %eax,0x4(%esp)
f010660c:	c7 04 24 80 84 10 f0 	movl   $0xf0108480,(%esp)
f0106613:	e8 5a d9 ff ff       	call   f0103f72 <cprintf>
f0106618:	eb 12                	jmp    f010662c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010661a:	8b 06                	mov    (%esi),%eax
f010661c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106620:	c7 04 24 97 84 10 f0 	movl   $0xf0108497,(%esp)
f0106627:	e8 46 d9 ff ff       	call   f0103f72 <cprintf>
f010662c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010662f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106632:	39 c3                	cmp    %eax,%ebx
f0106634:	74 08                	je     f010663e <spin_unlock+0xdb>
f0106636:	89 de                	mov    %ebx,%esi
f0106638:	8b 03                	mov    (%ebx),%eax
f010663a:	85 c0                	test   %eax,%eax
f010663c:	75 93                	jne    f01065d1 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010663e:	c7 44 24 08 9f 84 10 	movl   $0xf010849f,0x8(%esp)
f0106645:	f0 
f0106646:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010664d:	00 
f010664e:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f0106655:	e8 e6 99 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010665a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106661:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106668:	b8 00 00 00 00       	mov    $0x0,%eax
f010666d:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106670:	83 c4 6c             	add    $0x6c,%esp
f0106673:	5b                   	pop    %ebx
f0106674:	5e                   	pop    %esi
f0106675:	5f                   	pop    %edi
f0106676:	5d                   	pop    %ebp
f0106677:	c3                   	ret    
f0106678:	66 90                	xchg   %ax,%ax
f010667a:	66 90                	xchg   %ax,%ax
f010667c:	66 90                	xchg   %ax,%ax
f010667e:	66 90                	xchg   %ax,%ax

f0106680 <__udivdi3>:
f0106680:	55                   	push   %ebp
f0106681:	57                   	push   %edi
f0106682:	56                   	push   %esi
f0106683:	83 ec 0c             	sub    $0xc,%esp
f0106686:	8b 44 24 28          	mov    0x28(%esp),%eax
f010668a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010668e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106692:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106696:	85 c0                	test   %eax,%eax
f0106698:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010669c:	89 ea                	mov    %ebp,%edx
f010669e:	89 0c 24             	mov    %ecx,(%esp)
f01066a1:	75 2d                	jne    f01066d0 <__udivdi3+0x50>
f01066a3:	39 e9                	cmp    %ebp,%ecx
f01066a5:	77 61                	ja     f0106708 <__udivdi3+0x88>
f01066a7:	85 c9                	test   %ecx,%ecx
f01066a9:	89 ce                	mov    %ecx,%esi
f01066ab:	75 0b                	jne    f01066b8 <__udivdi3+0x38>
f01066ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01066b2:	31 d2                	xor    %edx,%edx
f01066b4:	f7 f1                	div    %ecx
f01066b6:	89 c6                	mov    %eax,%esi
f01066b8:	31 d2                	xor    %edx,%edx
f01066ba:	89 e8                	mov    %ebp,%eax
f01066bc:	f7 f6                	div    %esi
f01066be:	89 c5                	mov    %eax,%ebp
f01066c0:	89 f8                	mov    %edi,%eax
f01066c2:	f7 f6                	div    %esi
f01066c4:	89 ea                	mov    %ebp,%edx
f01066c6:	83 c4 0c             	add    $0xc,%esp
f01066c9:	5e                   	pop    %esi
f01066ca:	5f                   	pop    %edi
f01066cb:	5d                   	pop    %ebp
f01066cc:	c3                   	ret    
f01066cd:	8d 76 00             	lea    0x0(%esi),%esi
f01066d0:	39 e8                	cmp    %ebp,%eax
f01066d2:	77 24                	ja     f01066f8 <__udivdi3+0x78>
f01066d4:	0f bd e8             	bsr    %eax,%ebp
f01066d7:	83 f5 1f             	xor    $0x1f,%ebp
f01066da:	75 3c                	jne    f0106718 <__udivdi3+0x98>
f01066dc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01066e0:	39 34 24             	cmp    %esi,(%esp)
f01066e3:	0f 86 9f 00 00 00    	jbe    f0106788 <__udivdi3+0x108>
f01066e9:	39 d0                	cmp    %edx,%eax
f01066eb:	0f 82 97 00 00 00    	jb     f0106788 <__udivdi3+0x108>
f01066f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01066f8:	31 d2                	xor    %edx,%edx
f01066fa:	31 c0                	xor    %eax,%eax
f01066fc:	83 c4 0c             	add    $0xc,%esp
f01066ff:	5e                   	pop    %esi
f0106700:	5f                   	pop    %edi
f0106701:	5d                   	pop    %ebp
f0106702:	c3                   	ret    
f0106703:	90                   	nop
f0106704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106708:	89 f8                	mov    %edi,%eax
f010670a:	f7 f1                	div    %ecx
f010670c:	31 d2                	xor    %edx,%edx
f010670e:	83 c4 0c             	add    $0xc,%esp
f0106711:	5e                   	pop    %esi
f0106712:	5f                   	pop    %edi
f0106713:	5d                   	pop    %ebp
f0106714:	c3                   	ret    
f0106715:	8d 76 00             	lea    0x0(%esi),%esi
f0106718:	89 e9                	mov    %ebp,%ecx
f010671a:	8b 3c 24             	mov    (%esp),%edi
f010671d:	d3 e0                	shl    %cl,%eax
f010671f:	89 c6                	mov    %eax,%esi
f0106721:	b8 20 00 00 00       	mov    $0x20,%eax
f0106726:	29 e8                	sub    %ebp,%eax
f0106728:	89 c1                	mov    %eax,%ecx
f010672a:	d3 ef                	shr    %cl,%edi
f010672c:	89 e9                	mov    %ebp,%ecx
f010672e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106732:	8b 3c 24             	mov    (%esp),%edi
f0106735:	09 74 24 08          	or     %esi,0x8(%esp)
f0106739:	89 d6                	mov    %edx,%esi
f010673b:	d3 e7                	shl    %cl,%edi
f010673d:	89 c1                	mov    %eax,%ecx
f010673f:	89 3c 24             	mov    %edi,(%esp)
f0106742:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106746:	d3 ee                	shr    %cl,%esi
f0106748:	89 e9                	mov    %ebp,%ecx
f010674a:	d3 e2                	shl    %cl,%edx
f010674c:	89 c1                	mov    %eax,%ecx
f010674e:	d3 ef                	shr    %cl,%edi
f0106750:	09 d7                	or     %edx,%edi
f0106752:	89 f2                	mov    %esi,%edx
f0106754:	89 f8                	mov    %edi,%eax
f0106756:	f7 74 24 08          	divl   0x8(%esp)
f010675a:	89 d6                	mov    %edx,%esi
f010675c:	89 c7                	mov    %eax,%edi
f010675e:	f7 24 24             	mull   (%esp)
f0106761:	39 d6                	cmp    %edx,%esi
f0106763:	89 14 24             	mov    %edx,(%esp)
f0106766:	72 30                	jb     f0106798 <__udivdi3+0x118>
f0106768:	8b 54 24 04          	mov    0x4(%esp),%edx
f010676c:	89 e9                	mov    %ebp,%ecx
f010676e:	d3 e2                	shl    %cl,%edx
f0106770:	39 c2                	cmp    %eax,%edx
f0106772:	73 05                	jae    f0106779 <__udivdi3+0xf9>
f0106774:	3b 34 24             	cmp    (%esp),%esi
f0106777:	74 1f                	je     f0106798 <__udivdi3+0x118>
f0106779:	89 f8                	mov    %edi,%eax
f010677b:	31 d2                	xor    %edx,%edx
f010677d:	e9 7a ff ff ff       	jmp    f01066fc <__udivdi3+0x7c>
f0106782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106788:	31 d2                	xor    %edx,%edx
f010678a:	b8 01 00 00 00       	mov    $0x1,%eax
f010678f:	e9 68 ff ff ff       	jmp    f01066fc <__udivdi3+0x7c>
f0106794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106798:	8d 47 ff             	lea    -0x1(%edi),%eax
f010679b:	31 d2                	xor    %edx,%edx
f010679d:	83 c4 0c             	add    $0xc,%esp
f01067a0:	5e                   	pop    %esi
f01067a1:	5f                   	pop    %edi
f01067a2:	5d                   	pop    %ebp
f01067a3:	c3                   	ret    
f01067a4:	66 90                	xchg   %ax,%ax
f01067a6:	66 90                	xchg   %ax,%ax
f01067a8:	66 90                	xchg   %ax,%ax
f01067aa:	66 90                	xchg   %ax,%ax
f01067ac:	66 90                	xchg   %ax,%ax
f01067ae:	66 90                	xchg   %ax,%ax

f01067b0 <__umoddi3>:
f01067b0:	55                   	push   %ebp
f01067b1:	57                   	push   %edi
f01067b2:	56                   	push   %esi
f01067b3:	83 ec 14             	sub    $0x14,%esp
f01067b6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01067ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01067be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01067c2:	89 c7                	mov    %eax,%edi
f01067c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067c8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01067cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01067d0:	89 34 24             	mov    %esi,(%esp)
f01067d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01067d7:	85 c0                	test   %eax,%eax
f01067d9:	89 c2                	mov    %eax,%edx
f01067db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067df:	75 17                	jne    f01067f8 <__umoddi3+0x48>
f01067e1:	39 fe                	cmp    %edi,%esi
f01067e3:	76 4b                	jbe    f0106830 <__umoddi3+0x80>
f01067e5:	89 c8                	mov    %ecx,%eax
f01067e7:	89 fa                	mov    %edi,%edx
f01067e9:	f7 f6                	div    %esi
f01067eb:	89 d0                	mov    %edx,%eax
f01067ed:	31 d2                	xor    %edx,%edx
f01067ef:	83 c4 14             	add    $0x14,%esp
f01067f2:	5e                   	pop    %esi
f01067f3:	5f                   	pop    %edi
f01067f4:	5d                   	pop    %ebp
f01067f5:	c3                   	ret    
f01067f6:	66 90                	xchg   %ax,%ax
f01067f8:	39 f8                	cmp    %edi,%eax
f01067fa:	77 54                	ja     f0106850 <__umoddi3+0xa0>
f01067fc:	0f bd e8             	bsr    %eax,%ebp
f01067ff:	83 f5 1f             	xor    $0x1f,%ebp
f0106802:	75 5c                	jne    f0106860 <__umoddi3+0xb0>
f0106804:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106808:	39 3c 24             	cmp    %edi,(%esp)
f010680b:	0f 87 e7 00 00 00    	ja     f01068f8 <__umoddi3+0x148>
f0106811:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106815:	29 f1                	sub    %esi,%ecx
f0106817:	19 c7                	sbb    %eax,%edi
f0106819:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010681d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106821:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106825:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106829:	83 c4 14             	add    $0x14,%esp
f010682c:	5e                   	pop    %esi
f010682d:	5f                   	pop    %edi
f010682e:	5d                   	pop    %ebp
f010682f:	c3                   	ret    
f0106830:	85 f6                	test   %esi,%esi
f0106832:	89 f5                	mov    %esi,%ebp
f0106834:	75 0b                	jne    f0106841 <__umoddi3+0x91>
f0106836:	b8 01 00 00 00       	mov    $0x1,%eax
f010683b:	31 d2                	xor    %edx,%edx
f010683d:	f7 f6                	div    %esi
f010683f:	89 c5                	mov    %eax,%ebp
f0106841:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106845:	31 d2                	xor    %edx,%edx
f0106847:	f7 f5                	div    %ebp
f0106849:	89 c8                	mov    %ecx,%eax
f010684b:	f7 f5                	div    %ebp
f010684d:	eb 9c                	jmp    f01067eb <__umoddi3+0x3b>
f010684f:	90                   	nop
f0106850:	89 c8                	mov    %ecx,%eax
f0106852:	89 fa                	mov    %edi,%edx
f0106854:	83 c4 14             	add    $0x14,%esp
f0106857:	5e                   	pop    %esi
f0106858:	5f                   	pop    %edi
f0106859:	5d                   	pop    %ebp
f010685a:	c3                   	ret    
f010685b:	90                   	nop
f010685c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106860:	8b 04 24             	mov    (%esp),%eax
f0106863:	be 20 00 00 00       	mov    $0x20,%esi
f0106868:	89 e9                	mov    %ebp,%ecx
f010686a:	29 ee                	sub    %ebp,%esi
f010686c:	d3 e2                	shl    %cl,%edx
f010686e:	89 f1                	mov    %esi,%ecx
f0106870:	d3 e8                	shr    %cl,%eax
f0106872:	89 e9                	mov    %ebp,%ecx
f0106874:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106878:	8b 04 24             	mov    (%esp),%eax
f010687b:	09 54 24 04          	or     %edx,0x4(%esp)
f010687f:	89 fa                	mov    %edi,%edx
f0106881:	d3 e0                	shl    %cl,%eax
f0106883:	89 f1                	mov    %esi,%ecx
f0106885:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106889:	8b 44 24 10          	mov    0x10(%esp),%eax
f010688d:	d3 ea                	shr    %cl,%edx
f010688f:	89 e9                	mov    %ebp,%ecx
f0106891:	d3 e7                	shl    %cl,%edi
f0106893:	89 f1                	mov    %esi,%ecx
f0106895:	d3 e8                	shr    %cl,%eax
f0106897:	89 e9                	mov    %ebp,%ecx
f0106899:	09 f8                	or     %edi,%eax
f010689b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010689f:	f7 74 24 04          	divl   0x4(%esp)
f01068a3:	d3 e7                	shl    %cl,%edi
f01068a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01068a9:	89 d7                	mov    %edx,%edi
f01068ab:	f7 64 24 08          	mull   0x8(%esp)
f01068af:	39 d7                	cmp    %edx,%edi
f01068b1:	89 c1                	mov    %eax,%ecx
f01068b3:	89 14 24             	mov    %edx,(%esp)
f01068b6:	72 2c                	jb     f01068e4 <__umoddi3+0x134>
f01068b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f01068bc:	72 22                	jb     f01068e0 <__umoddi3+0x130>
f01068be:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01068c2:	29 c8                	sub    %ecx,%eax
f01068c4:	19 d7                	sbb    %edx,%edi
f01068c6:	89 e9                	mov    %ebp,%ecx
f01068c8:	89 fa                	mov    %edi,%edx
f01068ca:	d3 e8                	shr    %cl,%eax
f01068cc:	89 f1                	mov    %esi,%ecx
f01068ce:	d3 e2                	shl    %cl,%edx
f01068d0:	89 e9                	mov    %ebp,%ecx
f01068d2:	d3 ef                	shr    %cl,%edi
f01068d4:	09 d0                	or     %edx,%eax
f01068d6:	89 fa                	mov    %edi,%edx
f01068d8:	83 c4 14             	add    $0x14,%esp
f01068db:	5e                   	pop    %esi
f01068dc:	5f                   	pop    %edi
f01068dd:	5d                   	pop    %ebp
f01068de:	c3                   	ret    
f01068df:	90                   	nop
f01068e0:	39 d7                	cmp    %edx,%edi
f01068e2:	75 da                	jne    f01068be <__umoddi3+0x10e>
f01068e4:	8b 14 24             	mov    (%esp),%edx
f01068e7:	89 c1                	mov    %eax,%ecx
f01068e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01068ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01068f1:	eb cb                	jmp    f01068be <__umoddi3+0x10e>
f01068f3:	90                   	nop
f01068f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01068fc:	0f 82 0f ff ff ff    	jb     f0106811 <__umoddi3+0x61>
f0106902:	e9 1a ff ff ff       	jmp    f0106821 <__umoddi3+0x71>
