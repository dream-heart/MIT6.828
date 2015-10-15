
obj/kern/kernel:     file format elf32-i386


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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

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
f010004b:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 ce 22 f0    	mov    %esi,0xf022ce80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 90 62 00 00       	call   f01062f4 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f010007d:	e8 fc 3e 00 00       	call   f0103f7e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 bd 3e 00 00       	call   f0103f4b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 40 7b 10 f0 	movl   $0xf0107b40,(%esp)
f0100095:	e8 e4 3e 00 00       	call   f0103f7e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 23 08 00 00       	call   f01008c9 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 8b 6a 10 f0 	movl   $0xf0106a8b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 0d 62 00 00       	call   f01062f4 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 97 6a 10 f0 	movl   $0xf0106a97,(%esp)
f01000f2:	e8 87 3e 00 00       	call   f0103f7e <cprintf>

	lapic_init();
f01000f7:	e8 12 62 00 00       	call   f010630e <lapic_init>
	env_init_percpu();
f01000fc:	e8 c4 35 00 00       	call   f01036c5 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 9a 3e 00 00       	call   f0103fa0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 e9 61 00 00       	call   f01062f4 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100124:	e8 7b 64 00 00       	call   f01065a4 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100129:	e8 a6 4a 00 00       	call   f0104bd4 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 e0 26 f0       	mov    $0xf026e008,%eax
f010013a:	2d 77 b6 22 f0       	sub    $0xf022b677,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 77 b6 22 f0 	movl   $0xf022b677,(%esp)
f0100152:	e8 3c 5b 00 00       	call   f0105c93 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 10 05 00 00       	call   f010066c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 ad 6a 10 f0 	movl   $0xf0106aad,(%esp)
f010016b:	e8 0e 3e 00 00       	call   f0103f7e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 ec 11 00 00       	call   f0101361 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 75 35 00 00       	call   f01036ef <env_init>
	trap_init();
f010017a:	e8 f1 3e 00 00       	call   f0104070 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 91 5e 00 00       	call   f0106016 <mp_init>
	lapic_init();
f0100185:	e8 84 61 00 00       	call   f010630e <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 1e 3d 00 00       	call   f0103ead <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	spin_initlock(&kernel_lock);
f010018f:	c7 44 24 04 c8 6a 10 	movl   $0xf0106ac8,0x4(%esp)
f0100196:	f0 
f0100197:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010019e:	e8 e6 63 00 00       	call   f0106589 <__spin_initlock>
f01001a3:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01001aa:	e8 f5 63 00 00       	call   f01065a4 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001af:	83 3d 88 ce 22 f0 07 	cmpl   $0x7,0xf022ce88
f01001b6:	77 24                	ja     f01001dc <i386_init+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b8:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001bf:	00 
f01001c0:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01001c7:	f0 
f01001c8:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f01001cf:	00 
f01001d0:	c7 04 24 8b 6a 10 f0 	movl   $0xf0106a8b,(%esp)
f01001d7:	e8 64 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001dc:	b8 32 5f 10 f0       	mov    $0xf0105f32,%eax
f01001e1:	2d b8 5e 10 f0       	sub    $0xf0105eb8,%eax
f01001e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001ea:	c7 44 24 04 b8 5e 10 	movl   $0xf0105eb8,0x4(%esp)
f01001f1:	f0 
f01001f2:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001f9:	e8 f0 5a 00 00       	call   f0105cee <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001fe:	bb 20 d0 22 f0       	mov    $0xf022d020,%ebx
f0100203:	eb 4d                	jmp    f0100252 <i386_init+0x124>
		if (c == cpus + cpunum())  // We've started already.
f0100205:	e8 ea 60 00 00       	call   f01062f4 <cpunum>
f010020a:	6b c0 74             	imul   $0x74,%eax,%eax
f010020d:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0100212:	39 c3                	cmp    %eax,%ebx
f0100214:	74 39                	je     f010024f <i386_init+0x121>

static void boot_aps(void);


void
i386_init(void)
f0100216:	89 d8                	mov    %ebx,%eax
f0100218:	2d 20 d0 22 f0       	sub    $0xf022d020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021d:	c1 f8 02             	sar    $0x2,%eax
f0100220:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100226:	c1 e0 0f             	shl    $0xf,%eax
f0100229:	8d 80 00 60 23 f0    	lea    -0xfdca000(%eax),%eax
f010022f:	a3 84 ce 22 f0       	mov    %eax,0xf022ce84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100234:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010023b:	00 
f010023c:	0f b6 03             	movzbl (%ebx),%eax
f010023f:	89 04 24             	mov    %eax,(%esp)
f0100242:	e8 15 62 00 00       	call   f010645c <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100247:	8b 43 04             	mov    0x4(%ebx),%eax
f010024a:	83 f8 01             	cmp    $0x1,%eax
f010024d:	75 f8                	jne    f0100247 <i386_init+0x119>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010024f:	83 c3 74             	add    $0x74,%ebx
f0100252:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f0100259:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f010025e:	39 c3                	cmp    %eax,%ebx
f0100260:	72 a3                	jb     f0100205 <i386_init+0xd7>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100262:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100269:	00 
f010026a:	c7 04 24 9a 2c 22 f0 	movl   $0xf0222c9a,(%esp)
f0100271:	e8 8c 36 00 00       	call   f0103902 <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f0100276:	e8 59 49 00 00       	call   f0104bd4 <sched_yield>

f010027b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010027b:	55                   	push   %ebp
f010027c:	89 e5                	mov    %esp,%ebp
f010027e:	53                   	push   %ebx
f010027f:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100282:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100285:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100288:	89 44 24 08          	mov    %eax,0x8(%esp)
f010028c:	8b 45 08             	mov    0x8(%ebp),%eax
f010028f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100293:	c7 04 24 d5 6a 10 f0 	movl   $0xf0106ad5,(%esp)
f010029a:	e8 df 3c 00 00       	call   f0103f7e <cprintf>
	vcprintf(fmt, ap);
f010029f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a3:	8b 45 10             	mov    0x10(%ebp),%eax
f01002a6:	89 04 24             	mov    %eax,(%esp)
f01002a9:	e8 9d 3c 00 00       	call   f0103f4b <vcprintf>
	cprintf("\n");
f01002ae:	c7 04 24 40 7b 10 f0 	movl   $0xf0107b40,(%esp)
f01002b5:	e8 c4 3c 00 00       	call   f0103f7e <cprintf>
	va_end(ap);
}
f01002ba:	83 c4 14             	add    $0x14,%esp
f01002bd:	5b                   	pop    %ebx
f01002be:	5d                   	pop    %ebp
f01002bf:	c3                   	ret    

f01002c0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002c8:	ec                   	in     (%dx),%al
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002cc:	5d                   	pop    %ebp
f01002cd:	c3                   	ret    

f01002ce <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ce:	55                   	push   %ebp
f01002cf:	89 e5                	mov    %esp,%ebp
f01002d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002dc:	a8 01                	test   $0x1,%al
f01002de:	74 06                	je     f01002e6 <serial_proc_data+0x18>
f01002e0:	b2 f8                	mov    $0xf8,%dl
f01002e2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002e3:	0f b6 c8             	movzbl %al,%ecx
}
f01002e6:	89 c8                	mov    %ecx,%eax
f01002e8:	5d                   	pop    %ebp
f01002e9:	c3                   	ret    

f01002ea <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ea:	55                   	push   %ebp
f01002eb:	89 e5                	mov    %esp,%ebp
f01002ed:	53                   	push   %ebx
f01002ee:	83 ec 04             	sub    $0x4,%esp
f01002f1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002f3:	eb 25                	jmp    f010031a <cons_intr+0x30>
		if (c == 0)
f01002f5:	85 c0                	test   %eax,%eax
f01002f7:	74 21                	je     f010031a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f9:	8b 15 24 c2 22 f0    	mov    0xf022c224,%edx
f01002ff:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
f0100305:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100308:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010030d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100312:	0f 44 c2             	cmove  %edx,%eax
f0100315:	a3 24 c2 22 f0       	mov    %eax,0xf022c224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010031a:	ff d3                	call   *%ebx
f010031c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010031f:	75 d4                	jne    f01002f5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100321:	83 c4 04             	add    $0x4,%esp
f0100324:	5b                   	pop    %ebx
f0100325:	5d                   	pop    %ebp
f0100326:	c3                   	ret    

f0100327 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100327:	55                   	push   %ebp
f0100328:	89 e5                	mov    %esp,%ebp
f010032a:	57                   	push   %edi
f010032b:	56                   	push   %esi
f010032c:	53                   	push   %ebx
f010032d:	83 ec 2c             	sub    $0x2c,%esp
f0100330:	89 c7                	mov    %eax,%edi
f0100332:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100337:	be fd 03 00 00       	mov    $0x3fd,%esi
f010033c:	eb 05                	jmp    f0100343 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010033e:	e8 7d ff ff ff       	call   f01002c0 <delay>
f0100343:	89 f2                	mov    %esi,%edx
f0100345:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100346:	a8 20                	test   $0x20,%al
f0100348:	75 05                	jne    f010034f <cons_putc+0x28>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010034a:	83 eb 01             	sub    $0x1,%ebx
f010034d:	75 ef                	jne    f010033e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010034f:	89 fa                	mov    %edi,%edx
f0100351:	89 f8                	mov    %edi,%eax
f0100353:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100356:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010035b:	ee                   	out    %al,(%dx)
f010035c:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	be 79 03 00 00       	mov    $0x379,%esi
f0100366:	eb 05                	jmp    f010036d <cons_putc+0x46>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100368:	e8 53 ff ff ff       	call   f01002c0 <delay>
f010036d:	89 f2                	mov    %esi,%edx
f010036f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100370:	84 c0                	test   %al,%al
f0100372:	78 05                	js     f0100379 <cons_putc+0x52>
f0100374:	83 eb 01             	sub    $0x1,%ebx
f0100377:	75 ef                	jne    f0100368 <cons_putc+0x41>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100379:	ba 78 03 00 00       	mov    $0x378,%edx
f010037e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100382:	ee                   	out    %al,(%dx)
f0100383:	b2 7a                	mov    $0x7a,%dl
f0100385:	b8 0d 00 00 00       	mov    $0xd,%eax
f010038a:	ee                   	out    %al,(%dx)
f010038b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100390:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100391:	89 fa                	mov    %edi,%edx
f0100393:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100399:	89 f8                	mov    %edi,%eax
f010039b:	80 cc 07             	or     $0x7,%ah
f010039e:	85 d2                	test   %edx,%edx
f01003a0:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	25 ff 00 00 00       	and    $0xff,%eax
f01003aa:	83 f8 09             	cmp    $0x9,%eax
f01003ad:	74 79                	je     f0100428 <cons_putc+0x101>
f01003af:	83 f8 09             	cmp    $0x9,%eax
f01003b2:	7f 0e                	jg     f01003c2 <cons_putc+0x9b>
f01003b4:	83 f8 08             	cmp    $0x8,%eax
f01003b7:	0f 85 9f 00 00 00    	jne    f010045c <cons_putc+0x135>
f01003bd:	8d 76 00             	lea    0x0(%esi),%esi
f01003c0:	eb 10                	jmp    f01003d2 <cons_putc+0xab>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	74 3b                	je     f0100402 <cons_putc+0xdb>
f01003c7:	83 f8 0d             	cmp    $0xd,%eax
f01003ca:	0f 85 8c 00 00 00    	jne    f010045c <cons_putc+0x135>
f01003d0:	eb 38                	jmp    f010040a <cons_putc+0xe3>
	case '\b':
		if (crt_pos > 0) {
f01003d2:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f01003d9:	66 85 c0             	test   %ax,%ax
f01003dc:	0f 84 e4 00 00 00    	je     f01004c6 <cons_putc+0x19f>
			crt_pos--;
f01003e2:	83 e8 01             	sub    $0x1,%eax
f01003e5:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003eb:	0f b7 c0             	movzwl %ax,%eax
f01003ee:	66 81 e7 00 ff       	and    $0xff00,%di
f01003f3:	83 cf 20             	or     $0x20,%edi
f01003f6:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
f01003fc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100400:	eb 77                	jmp    f0100479 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100402:	66 83 05 34 c2 22 f0 	addw   $0x50,0xf022c234
f0100409:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010040a:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f0100411:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100417:	c1 e8 16             	shr    $0x16,%eax
f010041a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010041d:	c1 e0 04             	shl    $0x4,%eax
f0100420:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
f0100426:	eb 51                	jmp    f0100479 <cons_putc+0x152>
		break;
	case '\t':
		cons_putc(' ');
f0100428:	b8 20 00 00 00       	mov    $0x20,%eax
f010042d:	e8 f5 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100432:	b8 20 00 00 00       	mov    $0x20,%eax
f0100437:	e8 eb fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f010043c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100441:	e8 e1 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 d7 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 cd fe ff ff       	call   f0100327 <cons_putc>
f010045a:	eb 1d                	jmp    f0100479 <cons_putc+0x152>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010045c:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f0100463:	0f b7 c8             	movzwl %ax,%ecx
f0100466:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
f010046c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100470:	83 c0 01             	add    $0x1,%eax
f0100473:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100479:	66 81 3d 34 c2 22 f0 	cmpw   $0x7cf,0xf022c234
f0100480:	cf 07 
f0100482:	76 42                	jbe    f01004c6 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100484:	a1 30 c2 22 f0       	mov    0xf022c230,%eax
f0100489:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100490:	00 
f0100491:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100497:	89 54 24 04          	mov    %edx,0x4(%esp)
f010049b:	89 04 24             	mov    %eax,(%esp)
f010049e:	e8 4b 58 00 00       	call   f0105cee <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a3:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a9:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004ae:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b4:	83 c0 01             	add    $0x1,%eax
f01004b7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004bc:	75 f0                	jne    f01004ae <cons_putc+0x187>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004be:	66 83 2d 34 c2 22 f0 	subw   $0x50,0xf022c234
f01004c5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c6:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
f01004cc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d1:	89 ca                	mov    %ecx,%edx
f01004d3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d4:	0f b7 35 34 c2 22 f0 	movzwl 0xf022c234,%esi
f01004db:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004de:	89 f0                	mov    %esi,%eax
f01004e0:	66 c1 e8 08          	shr    $0x8,%ax
f01004e4:	89 da                	mov    %ebx,%edx
f01004e6:	ee                   	out    %al,(%dx)
f01004e7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ec:	89 ca                	mov    %ecx,%edx
f01004ee:	ee                   	out    %al,(%dx)
f01004ef:	89 f0                	mov    %esi,%eax
f01004f1:	89 da                	mov    %ebx,%edx
f01004f3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f4:	83 c4 2c             	add    $0x2c,%esp
f01004f7:	5b                   	pop    %ebx
f01004f8:	5e                   	pop    %esi
f01004f9:	5f                   	pop    %edi
f01004fa:	5d                   	pop    %ebp
f01004fb:	c3                   	ret    

f01004fc <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004fc:	55                   	push   %ebp
f01004fd:	89 e5                	mov    %esp,%ebp
f01004ff:	53                   	push   %ebx
f0100500:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100503:	ba 64 00 00 00       	mov    $0x64,%edx
f0100508:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100509:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010050e:	a8 01                	test   $0x1,%al
f0100510:	0f 84 de 00 00 00    	je     f01005f4 <kbd_proc_data+0xf8>
f0100516:	b2 60                	mov    $0x60,%dl
f0100518:	ec                   	in     (%dx),%al
f0100519:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010051b:	3c e0                	cmp    $0xe0,%al
f010051d:	75 11                	jne    f0100530 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010051f:	83 0d 28 c2 22 f0 40 	orl    $0x40,0xf022c228
		return 0;
f0100526:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052b:	e9 c4 00 00 00       	jmp    f01005f4 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100530:	84 c0                	test   %al,%al
f0100532:	79 37                	jns    f010056b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100534:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f010053a:	89 cb                	mov    %ecx,%ebx
f010053c:	83 e3 40             	and    $0x40,%ebx
f010053f:	83 e0 7f             	and    $0x7f,%eax
f0100542:	85 db                	test   %ebx,%ebx
f0100544:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100547:	0f b6 d2             	movzbl %dl,%edx
f010054a:	0f b6 82 20 6b 10 f0 	movzbl -0xfef94e0(%edx),%eax
f0100551:	83 c8 40             	or     $0x40,%eax
f0100554:	0f b6 c0             	movzbl %al,%eax
f0100557:	f7 d0                	not    %eax
f0100559:	21 c1                	and    %eax,%ecx
f010055b:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
		return 0;
f0100561:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100566:	e9 89 00 00 00       	jmp    f01005f4 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010056b:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f0100571:	f6 c1 40             	test   $0x40,%cl
f0100574:	74 0e                	je     f0100584 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100576:	89 c2                	mov    %eax,%edx
f0100578:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057e:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
	}

	shift |= shiftcode[data];
f0100584:	0f b6 d2             	movzbl %dl,%edx
f0100587:	0f b6 82 20 6b 10 f0 	movzbl -0xfef94e0(%edx),%eax
f010058e:	0b 05 28 c2 22 f0    	or     0xf022c228,%eax
	shift ^= togglecode[data];
f0100594:	0f b6 8a 20 6c 10 f0 	movzbl -0xfef93e0(%edx),%ecx
f010059b:	31 c8                	xor    %ecx,%eax
f010059d:	a3 28 c2 22 f0       	mov    %eax,0xf022c228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a2:	89 c1                	mov    %eax,%ecx
f01005a4:	83 e1 03             	and    $0x3,%ecx
f01005a7:	8b 0c 8d 20 6d 10 f0 	mov    -0xfef92e0(,%ecx,4),%ecx
f01005ae:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b2:	a8 08                	test   $0x8,%al
f01005b4:	74 19                	je     f01005cf <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005b6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005b9:	83 fa 19             	cmp    $0x19,%edx
f01005bc:	77 05                	ja     f01005c3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005be:	83 eb 20             	sub    $0x20,%ebx
f01005c1:	eb 0c                	jmp    f01005cf <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005c3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01005c6:	8d 53 20             	lea    0x20(%ebx),%edx
f01005c9:	83 f9 19             	cmp    $0x19,%ecx
f01005cc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005cf:	f7 d0                	not    %eax
f01005d1:	a8 06                	test   $0x6,%al
f01005d3:	75 1f                	jne    f01005f4 <kbd_proc_data+0xf8>
f01005d5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005db:	75 17                	jne    f01005f4 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01005dd:	c7 04 24 ef 6a 10 f0 	movl   $0xf0106aef,(%esp)
f01005e4:	e8 95 39 00 00       	call   f0103f7e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e9:	ba 92 00 00 00       	mov    $0x92,%edx
f01005ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f3:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005f4:	89 d8                	mov    %ebx,%eax
f01005f6:	83 c4 14             	add    $0x14,%esp
f01005f9:	5b                   	pop    %ebx
f01005fa:	5d                   	pop    %ebp
f01005fb:	c3                   	ret    

f01005fc <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005fc:	55                   	push   %ebp
f01005fd:	89 e5                	mov    %esp,%ebp
f01005ff:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100602:	80 3d 00 c0 22 f0 00 	cmpb   $0x0,0xf022c000
f0100609:	74 0a                	je     f0100615 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010060b:	b8 ce 02 10 f0       	mov    $0xf01002ce,%eax
f0100610:	e8 d5 fc ff ff       	call   f01002ea <cons_intr>
}
f0100615:	c9                   	leave  
f0100616:	c3                   	ret    

f0100617 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010061d:	b8 fc 04 10 f0       	mov    $0xf01004fc,%eax
f0100622:	e8 c3 fc ff ff       	call   f01002ea <cons_intr>
}
f0100627:	c9                   	leave  
f0100628:	c3                   	ret    

f0100629 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100629:	55                   	push   %ebp
f010062a:	89 e5                	mov    %esp,%ebp
f010062c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010062f:	e8 c8 ff ff ff       	call   f01005fc <serial_intr>
	kbd_intr();
f0100634:	e8 de ff ff ff       	call   f0100617 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100639:	8b 15 20 c2 22 f0    	mov    0xf022c220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010063f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100644:	3b 15 24 c2 22 f0    	cmp    0xf022c224,%edx
f010064a:	74 1e                	je     f010066a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010064c:	0f b6 82 20 c0 22 f0 	movzbl -0xfdd3fe0(%edx),%eax
f0100653:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100656:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100661:	0f 44 d1             	cmove  %ecx,%edx
f0100664:	89 15 20 c2 22 f0    	mov    %edx,0xf022c220
		return c;
	}
	return 0;
}
f010066a:	c9                   	leave  
f010066b:	c3                   	ret    

f010066c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010066c:	55                   	push   %ebp
f010066d:	89 e5                	mov    %esp,%ebp
f010066f:	57                   	push   %edi
f0100670:	56                   	push   %esi
f0100671:	53                   	push   %ebx
f0100672:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100675:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100683:	5a a5 
	if (*cp != 0xA55A) {
f0100685:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100690:	74 11                	je     f01006a3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100692:	c7 05 2c c2 22 f0 b4 	movl   $0x3b4,0xf022c22c
f0100699:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006a1:	eb 16                	jmp    f01006b9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006aa:	c7 05 2c c2 22 f0 d4 	movl   $0x3d4,0xf022c22c
f01006b1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006b9:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
f01006bf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c4:	89 ca                	mov    %ecx,%edx
f01006c6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006c7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ca:	89 da                	mov    %ebx,%edx
f01006cc:	ec                   	in     (%dx),%al
f01006cd:	0f b6 f8             	movzbl %al,%edi
f01006d0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006d8:	89 ca                	mov    %ecx,%edx
f01006da:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006db:	89 da                	mov    %ebx,%edx
f01006dd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006de:	89 35 30 c2 22 f0    	mov    %esi,0xf022c230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e4:	0f b6 d8             	movzbl %al,%ebx
f01006e7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006e9:	66 89 3d 34 c2 22 f0 	mov    %di,0xf022c234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f0:	e8 22 ff ff ff       	call   f0100617 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f5:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006fc:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100701:	89 04 24             	mov    %eax,(%esp)
f0100704:	e8 33 37 00 00       	call   f0103e3c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100709:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	89 da                	mov    %ebx,%edx
f0100715:	ee                   	out    %al,(%dx)
f0100716:	b2 fb                	mov    $0xfb,%dl
f0100718:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010071d:	ee                   	out    %al,(%dx)
f010071e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100723:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100728:	89 ca                	mov    %ecx,%edx
f010072a:	ee                   	out    %al,(%dx)
f010072b:	b2 f9                	mov    $0xf9,%dl
f010072d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100732:	ee                   	out    %al,(%dx)
f0100733:	b2 fb                	mov    $0xfb,%dl
f0100735:	b8 03 00 00 00       	mov    $0x3,%eax
f010073a:	ee                   	out    %al,(%dx)
f010073b:	b2 fc                	mov    $0xfc,%dl
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	b2 f9                	mov    $0xf9,%dl
f0100745:	b8 01 00 00 00       	mov    $0x1,%eax
f010074a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074b:	b2 fd                	mov    $0xfd,%dl
f010074d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010074e:	3c ff                	cmp    $0xff,%al
f0100750:	0f 95 c0             	setne  %al
f0100753:	89 c6                	mov    %eax,%esi
f0100755:	a2 00 c0 22 f0       	mov    %al,0xf022c000
f010075a:	89 da                	mov    %ebx,%edx
f010075c:	ec                   	in     (%dx),%al
f010075d:	89 ca                	mov    %ecx,%edx
f010075f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100760:	89 f0                	mov    %esi,%eax
f0100762:	84 c0                	test   %al,%al
f0100764:	75 0c                	jne    f0100772 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f0100766:	c7 04 24 fb 6a 10 f0 	movl   $0xf0106afb,(%esp)
f010076d:	e8 0c 38 00 00       	call   f0103f7e <cprintf>
}
f0100772:	83 c4 1c             	add    $0x1c,%esp
f0100775:	5b                   	pop    %ebx
f0100776:	5e                   	pop    %esi
f0100777:	5f                   	pop    %edi
f0100778:	5d                   	pop    %ebp
f0100779:	c3                   	ret    

f010077a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077a:	55                   	push   %ebp
f010077b:	89 e5                	mov    %esp,%ebp
f010077d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	e8 9f fb ff ff       	call   f0100327 <cons_putc>
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <getchar>:

int
getchar(void)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100790:	e8 94 fe ff ff       	call   f0100629 <cons_getc>
f0100795:	85 c0                	test   %eax,%eax
f0100797:	74 f7                	je     f0100790 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100799:	c9                   	leave  
f010079a:	c3                   	ret    

f010079b <iscons>:

int
iscons(int fdnum)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010079e:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    
	...

f01007b0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b6:	c7 04 24 30 6d 10 f0 	movl   $0xf0106d30,(%esp)
f01007bd:	e8 bc 37 00 00       	call   f0103f7e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007c9:	00 
f01007ca:	c7 04 24 bc 6d 10 f0 	movl   $0xf0106dbc,(%esp)
f01007d1:	e8 a8 37 00 00       	call   f0103f7e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007dd:	00 
f01007de:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 e4 6d 10 f0 	movl   $0xf0106de4,(%esp)
f01007ed:	e8 8c 37 00 00       	call   f0103f7e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f2:	c7 44 24 08 05 6a 10 	movl   $0x106a05,0x8(%esp)
f01007f9:	00 
f01007fa:	c7 44 24 04 05 6a 10 	movl   $0xf0106a05,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 08 6e 10 f0 	movl   $0xf0106e08,(%esp)
f0100809:	e8 70 37 00 00       	call   f0103f7e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080e:	c7 44 24 08 77 b6 22 	movl   $0x22b677,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 77 b6 22 	movl   $0xf022b677,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 2c 6e 10 f0 	movl   $0xf0106e2c,(%esp)
f0100825:	e8 54 37 00 00       	call   f0103f7e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082a:	c7 44 24 08 08 e0 26 	movl   $0x26e008,0x8(%esp)
f0100831:	00 
f0100832:	c7 44 24 04 08 e0 26 	movl   $0xf026e008,0x4(%esp)
f0100839:	f0 
f010083a:	c7 04 24 50 6e 10 f0 	movl   $0xf0106e50,(%esp)
f0100841:	e8 38 37 00 00       	call   f0103f7e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100846:	b8 07 e4 26 f0       	mov    $0xf026e407,%eax
f010084b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100850:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100855:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085b:	85 c0                	test   %eax,%eax
f010085d:	0f 48 c2             	cmovs  %edx,%eax
f0100860:	c1 f8 0a             	sar    $0xa,%eax
f0100863:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100867:	c7 04 24 74 6e 10 f0 	movl   $0xf0106e74,(%esp)
f010086e:	e8 0b 37 00 00       	call   f0103f7e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100873:	b8 00 00 00 00       	mov    $0x0,%eax
f0100878:	c9                   	leave  
f0100879:	c3                   	ret    

f010087a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100880:	c7 44 24 08 49 6d 10 	movl   $0xf0106d49,0x8(%esp)
f0100887:	f0 
f0100888:	c7 44 24 04 67 6d 10 	movl   $0xf0106d67,0x4(%esp)
f010088f:	f0 
f0100890:	c7 04 24 6c 6d 10 f0 	movl   $0xf0106d6c,(%esp)
f0100897:	e8 e2 36 00 00       	call   f0103f7e <cprintf>
f010089c:	c7 44 24 08 a0 6e 10 	movl   $0xf0106ea0,0x8(%esp)
f01008a3:	f0 
f01008a4:	c7 44 24 04 75 6d 10 	movl   $0xf0106d75,0x4(%esp)
f01008ab:	f0 
f01008ac:	c7 04 24 6c 6d 10 f0 	movl   $0xf0106d6c,(%esp)
f01008b3:	e8 c6 36 00 00       	call   f0103f7e <cprintf>
	return 0;
}
f01008b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008bd:	c9                   	leave  
f01008be:	c3                   	ret    

f01008bf <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008bf:	55                   	push   %ebp
f01008c0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c7:	5d                   	pop    %ebp
f01008c8:	c3                   	ret    

f01008c9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008c9:	55                   	push   %ebp
f01008ca:	89 e5                	mov    %esp,%ebp
f01008cc:	57                   	push   %edi
f01008cd:	56                   	push   %esi
f01008ce:	53                   	push   %ebx
f01008cf:	83 ec 5c             	sub    $0x5c,%esp
f01008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008d5:	c7 04 24 c8 6e 10 f0 	movl   $0xf0106ec8,(%esp)
f01008dc:	e8 9d 36 00 00       	call   f0103f7e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008e1:	c7 04 24 ec 6e 10 f0 	movl   $0xf0106eec,(%esp)
f01008e8:	e8 91 36 00 00       	call   f0103f7e <cprintf>

	if (tf != NULL)
f01008ed:	85 ff                	test   %edi,%edi
f01008ef:	74 08                	je     f01008f9 <monitor+0x30>
		print_trapframe(tf);
f01008f1:	89 3c 24             	mov    %edi,(%esp)
f01008f4:	e8 b2 3b 00 00       	call   f01044ab <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01008f9:	c7 04 24 7e 6d 10 f0 	movl   $0xf0106d7e,(%esp)
f0100900:	e8 3b 51 00 00       	call   f0105a40 <readline>
f0100905:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100907:	85 c0                	test   %eax,%eax
f0100909:	74 ee                	je     f01008f9 <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010090b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100912:	be 00 00 00 00       	mov    $0x0,%esi
f0100917:	eb 06                	jmp    f010091f <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100919:	c6 03 00             	movb   $0x0,(%ebx)
f010091c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010091f:	0f b6 03             	movzbl (%ebx),%eax
f0100922:	84 c0                	test   %al,%al
f0100924:	74 63                	je     f0100989 <monitor+0xc0>
f0100926:	0f be c0             	movsbl %al,%eax
f0100929:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092d:	c7 04 24 82 6d 10 f0 	movl   $0xf0106d82,(%esp)
f0100934:	e8 1d 53 00 00       	call   f0105c56 <strchr>
f0100939:	85 c0                	test   %eax,%eax
f010093b:	75 dc                	jne    f0100919 <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f010093d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100940:	74 47                	je     f0100989 <monitor+0xc0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100942:	83 fe 0f             	cmp    $0xf,%esi
f0100945:	75 16                	jne    f010095d <monitor+0x94>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100947:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010094e:	00 
f010094f:	c7 04 24 87 6d 10 f0 	movl   $0xf0106d87,(%esp)
f0100956:	e8 23 36 00 00       	call   f0103f7e <cprintf>
f010095b:	eb 9c                	jmp    f01008f9 <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f010095d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100961:	83 c6 01             	add    $0x1,%esi
f0100964:	eb 03                	jmp    f0100969 <monitor+0xa0>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100966:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100969:	0f b6 03             	movzbl (%ebx),%eax
f010096c:	84 c0                	test   %al,%al
f010096e:	74 af                	je     f010091f <monitor+0x56>
f0100970:	0f be c0             	movsbl %al,%eax
f0100973:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100977:	c7 04 24 82 6d 10 f0 	movl   $0xf0106d82,(%esp)
f010097e:	e8 d3 52 00 00       	call   f0105c56 <strchr>
f0100983:	85 c0                	test   %eax,%eax
f0100985:	74 df                	je     f0100966 <monitor+0x9d>
f0100987:	eb 96                	jmp    f010091f <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100989:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100990:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100991:	85 f6                	test   %esi,%esi
f0100993:	0f 84 60 ff ff ff    	je     f01008f9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100999:	c7 44 24 04 67 6d 10 	movl   $0xf0106d67,0x4(%esp)
f01009a0:	f0 
f01009a1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009a4:	89 04 24             	mov    %eax,(%esp)
f01009a7:	e8 4b 52 00 00       	call   f0105bf7 <strcmp>
f01009ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01009b1:	85 c0                	test   %eax,%eax
f01009b3:	74 1c                	je     f01009d1 <monitor+0x108>
f01009b5:	c7 44 24 04 75 6d 10 	movl   $0xf0106d75,0x4(%esp)
f01009bc:	f0 
f01009bd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009c0:	89 04 24             	mov    %eax,(%esp)
f01009c3:	e8 2f 52 00 00       	call   f0105bf7 <strcmp>
f01009c8:	85 c0                	test   %eax,%eax
f01009ca:	75 28                	jne    f01009f4 <monitor+0x12b>
f01009cc:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01009d1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01009d4:	01 c2                	add    %eax,%edx
f01009d6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009da:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e1:	89 34 24             	mov    %esi,(%esp)
f01009e4:	ff 14 95 1c 6f 10 f0 	call   *-0xfef90e4(,%edx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	78 1d                	js     f0100a0c <monitor+0x143>
f01009ef:	e9 05 ff ff ff       	jmp    f01008f9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fb:	c7 04 24 a4 6d 10 f0 	movl   $0xf0106da4,(%esp)
f0100a02:	e8 77 35 00 00       	call   f0103f7e <cprintf>
f0100a07:	e9 ed fe ff ff       	jmp    f01008f9 <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a0c:	83 c4 5c             	add    $0x5c,%esp
f0100a0f:	5b                   	pop    %ebx
f0100a10:	5e                   	pop    %esi
f0100a11:	5f                   	pop    %edi
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a17:	83 3d 3c c2 22 f0 00 	cmpl   $0x0,0xf022c23c
f0100a1e:	75 11                	jne    f0100a31 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a20:	ba 07 f0 26 f0       	mov    $0xf026f007,%edx
f0100a25:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a2b:	89 15 3c c2 22 f0    	mov    %edx,0xf022c23c
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
		return nextfree;
f0100a31:	8b 15 3c c2 22 f0    	mov    0xf022c23c,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a37:	85 c0                	test   %eax,%eax
f0100a39:	74 17                	je     f0100a52 <boot_alloc+0x3e>
		return nextfree;
	result = nextfree;
f0100a3b:	8b 15 3c c2 22 f0    	mov    0xf022c23c,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a41:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4d:	a3 3c c2 22 f0       	mov    %eax,0xf022c23c
	
	// return the head address of the alloc pages;
	return result;
}
f0100a52:	89 d0                	mov    %edx,%eax
f0100a54:	5d                   	pop    %ebp
f0100a55:	c3                   	ret    

f0100a56 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a56:	55                   	push   %ebp
f0100a57:	89 e5                	mov    %esp,%ebp
f0100a59:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a5c:	89 d1                	mov    %edx,%ecx
f0100a5e:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a61:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a69:	f6 c1 01             	test   $0x1,%cl
f0100a6c:	74 57                	je     f0100ac5 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a6e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a74:	89 c8                	mov    %ecx,%eax
f0100a76:	c1 e8 0c             	shr    $0xc,%eax
f0100a79:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0100a7f:	72 20                	jb     f0100aa1 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a81:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a85:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100a8c:	f0 
f0100a8d:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0100a94:	00 
f0100a95:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100a9c:	e8 9f f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100aa1:	c1 ea 0c             	shr    $0xc,%edx
f0100aa4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100aaa:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100ab1:	89 c2                	mov    %eax,%edx
f0100ab3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ab6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100abb:	85 d2                	test   %edx,%edx
f0100abd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ac2:	0f 44 c2             	cmove  %edx,%eax
}
f0100ac5:	c9                   	leave  
f0100ac6:	c3                   	ret    

f0100ac7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ac7:	55                   	push   %ebp
f0100ac8:	89 e5                	mov    %esp,%ebp
f0100aca:	83 ec 18             	sub    $0x18,%esp
f0100acd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ad0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ad3:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ad5:	89 04 24             	mov    %eax,(%esp)
f0100ad8:	e8 37 33 00 00       	call   f0103e14 <mc146818_read>
f0100add:	89 c6                	mov    %eax,%esi
f0100adf:	83 c3 01             	add    $0x1,%ebx
f0100ae2:	89 1c 24             	mov    %ebx,(%esp)
f0100ae5:	e8 2a 33 00 00       	call   f0103e14 <mc146818_read>
f0100aea:	c1 e0 08             	shl    $0x8,%eax
f0100aed:	09 f0                	or     %esi,%eax
}
f0100aef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100af2:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100af5:	89 ec                	mov    %ebp,%esp
f0100af7:	5d                   	pop    %ebp
f0100af8:	c3                   	ret    

f0100af9 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100af9:	55                   	push   %ebp
f0100afa:	89 e5                	mov    %esp,%ebp
f0100afc:	57                   	push   %edi
f0100afd:	56                   	push   %esi
f0100afe:	53                   	push   %ebx
f0100aff:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b02:	3c 01                	cmp    $0x1,%al
f0100b04:	19 f6                	sbb    %esi,%esi
f0100b06:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b0c:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b0f:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100b15:	85 d2                	test   %edx,%edx
f0100b17:	75 1c                	jne    f0100b35 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100b19:	c7 44 24 08 2c 6f 10 	movl   $0xf0106f2c,0x8(%esp)
f0100b20:	f0 
f0100b21:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100b28:	00 
f0100b29:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100b30:	e8 0b f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100b35:	84 c0                	test   %al,%al
f0100b37:	74 4b                	je     f0100b84 <check_page_free_list+0x8b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b39:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b3c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b3f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b42:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b45:	89 d0                	mov    %edx,%eax
f0100b47:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100b4d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b50:	c1 e8 16             	shr    $0x16,%eax
f0100b53:	39 c6                	cmp    %eax,%esi
f0100b55:	0f 96 c0             	setbe  %al
f0100b58:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b5b:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100b5f:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b61:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b65:	8b 12                	mov    (%edx),%edx
f0100b67:	85 d2                	test   %edx,%edx
f0100b69:	75 da                	jne    f0100b45 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b74:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b7a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b7f:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b84:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f0100b8a:	eb 63                	jmp    f0100bef <check_page_free_list+0xf6>
f0100b8c:	89 d8                	mov    %ebx,%eax
f0100b8e:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100b94:	c1 f8 03             	sar    $0x3,%eax
f0100b97:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b9a:	89 c2                	mov    %eax,%edx
f0100b9c:	c1 ea 16             	shr    $0x16,%edx
f0100b9f:	39 d6                	cmp    %edx,%esi
f0100ba1:	76 4a                	jbe    f0100bed <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba3:	89 c2                	mov    %eax,%edx
f0100ba5:	c1 ea 0c             	shr    $0xc,%edx
f0100ba8:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0100bae:	72 20                	jb     f0100bd0 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bb4:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100bbb:	f0 
f0100bbc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bc3:	00 
f0100bc4:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0100bcb:	e8 70 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bd0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100bd7:	00 
f0100bd8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100bdf:	00 
	return (void *)(pa + KERNBASE);
f0100be0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100be5:	89 04 24             	mov    %eax,(%esp)
f0100be8:	e8 a6 50 00 00       	call   f0105c93 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bed:	8b 1b                	mov    (%ebx),%ebx
f0100bef:	85 db                	test   %ebx,%ebx
f0100bf1:	75 99                	jne    f0100b8c <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bf8:	e8 17 fe ff ff       	call   f0100a14 <boot_alloc>
f0100bfd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c00:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c06:	8b 0d 90 ce 22 f0    	mov    0xf022ce90,%ecx
		assert(pp < pages + npages);
f0100c0c:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f0100c11:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c14:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c1a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c1d:	be 00 00 00 00       	mov    $0x0,%esi
f0100c22:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c25:	e9 ca 01 00 00       	jmp    f0100df4 <check_page_free_list+0x2fb>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c2a:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100c2d:	73 24                	jae    f0100c53 <check_page_free_list+0x15a>
f0100c2f:	c7 44 24 0c 63 78 10 	movl   $0xf0107863,0xc(%esp)
f0100c36:	f0 
f0100c37:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100c3e:	f0 
f0100c3f:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0100c46:	00 
f0100c47:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100c4e:	e8 ed f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c53:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c56:	72 24                	jb     f0100c7c <check_page_free_list+0x183>
f0100c58:	c7 44 24 0c 84 78 10 	movl   $0xf0107884,0xc(%esp)
f0100c5f:	f0 
f0100c60:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100c67:	f0 
f0100c68:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100c6f:	00 
f0100c70:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100c77:	e8 c4 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7c:	89 d0                	mov    %edx,%eax
f0100c7e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c81:	a8 07                	test   $0x7,%al
f0100c83:	74 24                	je     f0100ca9 <check_page_free_list+0x1b0>
f0100c85:	c7 44 24 0c 50 6f 10 	movl   $0xf0106f50,0xc(%esp)
f0100c8c:	f0 
f0100c8d:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100c94:	f0 
f0100c95:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0100c9c:	00 
f0100c9d:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100ca4:	e8 97 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ca9:	c1 f8 03             	sar    $0x3,%eax
f0100cac:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100caf:	85 c0                	test   %eax,%eax
f0100cb1:	75 24                	jne    f0100cd7 <check_page_free_list+0x1de>
f0100cb3:	c7 44 24 0c 98 78 10 	movl   $0xf0107898,0xc(%esp)
f0100cba:	f0 
f0100cbb:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100cc2:	f0 
f0100cc3:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100cca:	00 
f0100ccb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100cd2:	e8 69 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cdc:	75 24                	jne    f0100d02 <check_page_free_list+0x209>
f0100cde:	c7 44 24 0c a9 78 10 	movl   $0xf01078a9,0xc(%esp)
f0100ce5:	f0 
f0100ce6:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100ced:	f0 
f0100cee:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100cf5:	00 
f0100cf6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100cfd:	e8 3e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d02:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d07:	75 24                	jne    f0100d2d <check_page_free_list+0x234>
f0100d09:	c7 44 24 0c 84 6f 10 	movl   $0xf0106f84,0xc(%esp)
f0100d10:	f0 
f0100d11:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100d18:	f0 
f0100d19:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d20:	00 
f0100d21:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100d28:	e8 13 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d2d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d32:	75 24                	jne    f0100d58 <check_page_free_list+0x25f>
f0100d34:	c7 44 24 0c c2 78 10 	movl   $0xf01078c2,0xc(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100d43:	f0 
f0100d44:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d4b:	00 
f0100d4c:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100d53:	e8 e8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d58:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d5d:	76 59                	jbe    f0100db8 <check_page_free_list+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d5f:	89 c1                	mov    %eax,%ecx
f0100d61:	c1 e9 0c             	shr    $0xc,%ecx
f0100d64:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100d67:	77 20                	ja     f0100d89 <check_page_free_list+0x290>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d6d:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100d74:	f0 
f0100d75:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d7c:	00 
f0100d7d:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0100d84:	e8 b7 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d89:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d8f:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100d92:	76 24                	jbe    f0100db8 <check_page_free_list+0x2bf>
f0100d94:	c7 44 24 0c a8 6f 10 	movl   $0xf0106fa8,0xc(%esp)
f0100d9b:	f0 
f0100d9c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100da3:	f0 
f0100da4:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0100dab:	00 
f0100dac:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100db3:	e8 88 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dbd:	75 24                	jne    f0100de3 <check_page_free_list+0x2ea>
f0100dbf:	c7 44 24 0c dc 78 10 	movl   $0xf01078dc,0xc(%esp)
f0100dc6:	f0 
f0100dc7:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100dce:	f0 
f0100dcf:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100dd6:	00 
f0100dd7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100dde:	e8 5d f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100de3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100de8:	77 05                	ja     f0100def <check_page_free_list+0x2f6>
			++nfree_basemem;
f0100dea:	83 c6 01             	add    $0x1,%esi
f0100ded:	eb 03                	jmp    f0100df2 <check_page_free_list+0x2f9>
		else
			++nfree_extmem;
f0100def:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100df2:	8b 12                	mov    (%edx),%edx
f0100df4:	85 d2                	test   %edx,%edx
f0100df6:	0f 85 2e fe ff ff    	jne    f0100c2a <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dfc:	85 f6                	test   %esi,%esi
f0100dfe:	7f 24                	jg     f0100e24 <check_page_free_list+0x32b>
f0100e00:	c7 44 24 0c f9 78 10 	movl   $0xf01078f9,0xc(%esp)
f0100e07:	f0 
f0100e08:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100e0f:	f0 
f0100e10:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0100e17:	00 
f0100e18:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100e1f:	e8 1c f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e24:	85 db                	test   %ebx,%ebx
f0100e26:	7f 24                	jg     f0100e4c <check_page_free_list+0x353>
f0100e28:	c7 44 24 0c 0b 79 10 	movl   $0xf010790b,0xc(%esp)
f0100e2f:	f0 
f0100e30:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0100e37:	f0 
f0100e38:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100e3f:	00 
f0100e40:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0100e47:	e8 f4 f1 ff ff       	call   f0100040 <_panic>
}
f0100e4c:	83 c4 4c             	add    $0x4c,%esp
f0100e4f:	5b                   	pop    %ebx
f0100e50:	5e                   	pop    %esi
f0100e51:	5f                   	pop    %edi
f0100e52:	5d                   	pop    %ebp
f0100e53:	c3                   	ret    

f0100e54 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e54:	55                   	push   %ebp
f0100e55:	89 e5                	mov    %esp,%ebp
f0100e57:	56                   	push   %esi
f0100e58:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e59:	be 00 00 00 00       	mov    $0x0,%esi
f0100e5e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e63:	e9 e1 00 00 00       	jmp    f0100f49 <page_init+0xf5>
		if(i == 0)
f0100e68:	85 db                	test   %ebx,%ebx
f0100e6a:	75 16                	jne    f0100e82 <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100e6c:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e71:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e7d:	e9 c1 00 00 00       	jmp    f0100f43 <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100e82:	83 fb 07             	cmp    $0x7,%ebx
f0100e85:	75 17                	jne    f0100e9e <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100e87:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e8c:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100e92:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100e99:	e9 a5 00 00 00       	jmp    f0100f43 <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100e9e:	3b 1d 38 c2 22 f0    	cmp    0xf022c238,%ebx
f0100ea4:	73 25                	jae    f0100ecb <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100ea6:	89 f0                	mov    %esi,%eax
f0100ea8:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100eae:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100eb4:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100eba:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100ebc:	89 f0                	mov    %esi,%eax
f0100ebe:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100ec4:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
f0100ec9:	eb 78                	jmp    f0100f43 <page_init+0xef>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100ecb:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100ed1:	83 f8 5f             	cmp    $0x5f,%eax
f0100ed4:	77 16                	ja     f0100eec <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100ed6:	89 f0                	mov    %esi,%eax
f0100ed8:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100ede:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ee4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100eea:	eb 57                	jmp    f0100f43 <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100eec:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100ef2:	76 2c                	jbe    f0100f20 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100ef4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef9:	e8 16 fb ff ff       	call   f0100a14 <boot_alloc>
f0100efe:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f03:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f06:	39 c3                	cmp    %eax,%ebx
f0100f08:	73 16                	jae    f0100f20 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100f0a:	89 f0                	mov    %esi,%eax
f0100f0c:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f12:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f1e:	eb 23                	jmp    f0100f43 <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f20:	89 f0                	mov    %esi,%eax
f0100f22:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f28:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f2e:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100f34:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f36:	89 f0                	mov    %esi,%eax
f0100f38:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f3e:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f43:	83 c3 01             	add    $0x1,%ebx
f0100f46:	83 c6 08             	add    $0x8,%esi
f0100f49:	3b 1d 88 ce 22 f0    	cmp    0xf022ce88,%ebx
f0100f4f:	0f 82 13 ff ff ff    	jb     f0100e68 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100f55:	5b                   	pop    %ebx
f0100f56:	5e                   	pop    %esi
f0100f57:	5d                   	pop    %ebp
f0100f58:	c3                   	ret    

f0100f59 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f59:	55                   	push   %ebp
f0100f5a:	89 e5                	mov    %esp,%ebp
f0100f5c:	53                   	push   %ebx
f0100f5d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100f60:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f0100f66:	85 db                	test   %ebx,%ebx
f0100f68:	74 6b                	je     f0100fd5 <page_alloc+0x7c>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100f6a:	8b 03                	mov    (%ebx),%eax
f0100f6c:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	page->pp_link = 0;
f0100f71:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f77:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f7b:	74 58                	je     f0100fd5 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f7d:	89 d8                	mov    %ebx,%eax
f0100f7f:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100f85:	c1 f8 03             	sar    $0x3,%eax
f0100f88:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f8b:	89 c2                	mov    %eax,%edx
f0100f8d:	c1 ea 0c             	shr    $0xc,%edx
f0100f90:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0100f96:	72 20                	jb     f0100fb8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f98:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f9c:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100fa3:	f0 
f0100fa4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100fab:	00 
f0100fac:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0100fb3:	e8 88 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100fb8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fbf:	00 
f0100fc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fc7:	00 
	return (void *)(pa + KERNBASE);
f0100fc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fcd:	89 04 24             	mov    %eax,(%esp)
f0100fd0:	e8 be 4c 00 00       	call   f0105c93 <memset>
	return page;
	return 0;
}
f0100fd5:	89 d8                	mov    %ebx,%eax
f0100fd7:	83 c4 14             	add    $0x14,%esp
f0100fda:	5b                   	pop    %ebx
f0100fdb:	5d                   	pop    %ebp
f0100fdc:	c3                   	ret    

f0100fdd <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fdd:	55                   	push   %ebp
f0100fde:	89 e5                	mov    %esp,%ebp
f0100fe0:	83 ec 18             	sub    $0x18,%esp
f0100fe3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0100fe6:	83 38 00             	cmpl   $0x0,(%eax)
f0100fe9:	75 07                	jne    f0100ff2 <page_free+0x15>
f0100feb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ff0:	74 1c                	je     f010100e <page_free+0x31>
		panic("page_free is not right");
f0100ff2:	c7 44 24 08 1c 79 10 	movl   $0xf010791c,0x8(%esp)
f0100ff9:	f0 
f0100ffa:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0101001:	00 
f0101002:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101009:	e8 32 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010100e:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0101014:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101016:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	return; 
}
f010101b:	c9                   	leave  
f010101c:	c3                   	ret    

f010101d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010101d:	55                   	push   %ebp
f010101e:	89 e5                	mov    %esp,%ebp
f0101020:	83 ec 18             	sub    $0x18,%esp
f0101023:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101026:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010102a:	83 ea 01             	sub    $0x1,%edx
f010102d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101031:	66 85 d2             	test   %dx,%dx
f0101034:	75 08                	jne    f010103e <page_decref+0x21>
		page_free(pp);
f0101036:	89 04 24             	mov    %eax,(%esp)
f0101039:	e8 9f ff ff ff       	call   f0100fdd <page_free>
}
f010103e:	c9                   	leave  
f010103f:	c3                   	ret    

f0101040 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101040:	55                   	push   %ebp
f0101041:	89 e5                	mov    %esp,%ebp
f0101043:	56                   	push   %esi
f0101044:	53                   	push   %ebx
f0101045:	83 ec 10             	sub    $0x10,%esp
f0101048:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f010104b:	89 f3                	mov    %esi,%ebx
f010104d:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f0101050:	c1 e3 02             	shl    $0x2,%ebx
f0101053:	03 5d 08             	add    0x8(%ebp),%ebx
f0101056:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101059:	0f 94 c0             	sete   %al
f010105c:	75 06                	jne    f0101064 <pgdir_walk+0x24>
f010105e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101062:	74 70                	je     f01010d4 <pgdir_walk+0x94>
		return NULL;
	if(pgdir[pdeIndex] == 0){
f0101064:	84 c0                	test   %al,%al
f0101066:	74 26                	je     f010108e <pgdir_walk+0x4e>
		struct PageInfo* page = page_alloc(1);
f0101068:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010106f:	e8 e5 fe ff ff       	call   f0100f59 <page_alloc>
		if(page == NULL)
f0101074:	85 c0                	test   %eax,%eax
f0101076:	74 63                	je     f01010db <pgdir_walk+0x9b>
			return NULL;
		page->pp_ref++;
f0101078:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010107d:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0101083:	c1 f8 03             	sar    $0x3,%eax
f0101086:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0101089:	83 c8 07             	or     $0x7,%eax
f010108c:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f010108e:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f0101090:	25 00 fc ff ff       	and    $0xfffffc00,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101095:	89 c2                	mov    %eax,%edx
f0101097:	c1 ea 0c             	shr    $0xc,%edx
f010109a:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f01010a0:	72 20                	jb     f01010c2 <pgdir_walk+0x82>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010a6:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01010ad:	f0 
f01010ae:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f01010b5:	00 
f01010b6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01010bd:	e8 7e ef ff ff       	call   f0100040 <_panic>
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01010c2:	c1 ee 0a             	shr    $0xa,%esi
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
f01010c5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010cb:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
	return pte;
f01010d2:	eb 0c                	jmp    f01010e0 <pgdir_walk+0xa0>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f01010d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d9:	eb 05                	jmp    f01010e0 <pgdir_walk+0xa0>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f01010db:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f01010e0:	83 c4 10             	add    $0x10,%esp
f01010e3:	5b                   	pop    %ebx
f01010e4:	5e                   	pop    %esi
f01010e5:	5d                   	pop    %ebp
f01010e6:	c3                   	ret    

f01010e7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010e7:	55                   	push   %ebp
f01010e8:	89 e5                	mov    %esp,%ebp
f01010ea:	57                   	push   %edi
f01010eb:	56                   	push   %esi
f01010ec:	53                   	push   %ebx
f01010ed:	83 ec 2c             	sub    $0x2c,%esp
f01010f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010f3:	89 d6                	mov    %edx,%esi
f01010f5:	89 cb                	mov    %ecx,%ebx
f01010f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	while(size)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f01010fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010fd:	83 c8 01             	or     $0x1,%eax
f0101100:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101103:	eb 34                	jmp    f0101139 <boot_map_region+0x52>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101105:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010110c:	00 
f010110d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101114:	89 04 24             	mov    %eax,(%esp)
f0101117:	e8 24 ff ff ff       	call   f0101040 <pgdir_walk>
		if(pte == NULL)
f010111c:	85 c0                	test   %eax,%eax
f010111e:	74 1d                	je     f010113d <boot_map_region+0x56>
			return;
		*pte= pa |perm|PTE_P;
f0101120:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101123:	09 fa                	or     %edi,%edx
f0101125:	89 10                	mov    %edx,(%eax)
		
		size -= PGSIZE;
f0101127:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
		pa  += PGSIZE;
f010112d:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va  += PGSIZE;
f0101133:	81 c6 00 10 00 00    	add    $0x1000,%esi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101139:	85 db                	test   %ebx,%ebx
f010113b:	75 c8                	jne    f0101105 <boot_map_region+0x1e>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f010113d:	83 c4 2c             	add    $0x2c,%esp
f0101140:	5b                   	pop    %ebx
f0101141:	5e                   	pop    %esi
f0101142:	5f                   	pop    %edi
f0101143:	5d                   	pop    %ebp
f0101144:	c3                   	ret    

f0101145 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101145:	55                   	push   %ebp
f0101146:	89 e5                	mov    %esp,%ebp
f0101148:	53                   	push   %ebx
f0101149:	83 ec 14             	sub    $0x14,%esp
f010114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f010114f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101156:	00 
f0101157:	8b 45 0c             	mov    0xc(%ebp),%eax
f010115a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010115e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101161:	89 04 24             	mov    %eax,(%esp)
f0101164:	e8 d7 fe ff ff       	call   f0101040 <pgdir_walk>
	if(pte == NULL)
f0101169:	85 c0                	test   %eax,%eax
f010116b:	74 42                	je     f01011af <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f010116d:	8b 10                	mov    (%eax),%edx
f010116f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f0101175:	85 db                	test   %ebx,%ebx
f0101177:	74 02                	je     f010117b <page_lookup+0x36>
		*pte_store = pte ;
f0101179:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010117b:	89 d0                	mov    %edx,%eax
f010117d:	c1 e8 0c             	shr    $0xc,%eax
f0101180:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0101186:	72 1c                	jb     f01011a4 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101188:	c7 44 24 08 f0 6f 10 	movl   $0xf0106ff0,0x8(%esp)
f010118f:	f0 
f0101190:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101197:	00 
f0101198:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f010119f:	e8 9c ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011a4:	c1 e0 03             	shl    $0x3,%eax
f01011a7:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
	return pa2page(pa);	
f01011ad:	eb 05                	jmp    f01011b4 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f01011af:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f01011b4:	83 c4 14             	add    $0x14,%esp
f01011b7:	5b                   	pop    %ebx
f01011b8:	5d                   	pop    %ebp
f01011b9:	c3                   	ret    

f01011ba <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011ba:	55                   	push   %ebp
f01011bb:	89 e5                	mov    %esp,%ebp
f01011bd:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011c0:	e8 2f 51 00 00       	call   f01062f4 <cpunum>
f01011c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01011c8:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01011cf:	74 16                	je     f01011e7 <tlb_invalidate+0x2d>
f01011d1:	e8 1e 51 00 00       	call   f01062f4 <cpunum>
f01011d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01011df:	8b 55 08             	mov    0x8(%ebp),%edx
f01011e2:	39 50 60             	cmp    %edx,0x60(%eax)
f01011e5:	75 06                	jne    f01011ed <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011ea:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011ed:	c9                   	leave  
f01011ee:	c3                   	ret    

f01011ef <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011ef:	55                   	push   %ebp
f01011f0:	89 e5                	mov    %esp,%ebp
f01011f2:	83 ec 28             	sub    $0x28,%esp
f01011f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01011f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01011fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01011fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101201:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101204:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101208:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010120c:	89 34 24             	mov    %esi,(%esp)
f010120f:	e8 31 ff ff ff       	call   f0101145 <page_lookup>
	if(page == 0)
f0101214:	85 c0                	test   %eax,%eax
f0101216:	74 2d                	je     f0101245 <page_remove+0x56>
		return;
	*pte = 0;
f0101218:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010121b:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101221:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101225:	83 ea 01             	sub    $0x1,%edx
f0101228:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f010122c:	66 85 d2             	test   %dx,%dx
f010122f:	75 08                	jne    f0101239 <page_remove+0x4a>
		page_free(page);
f0101231:	89 04 24             	mov    %eax,(%esp)
f0101234:	e8 a4 fd ff ff       	call   f0100fdd <page_free>
	tlb_invalidate(pgdir, va);
f0101239:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010123d:	89 34 24             	mov    %esi,(%esp)
f0101240:	e8 75 ff ff ff       	call   f01011ba <tlb_invalidate>
}
f0101245:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101248:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010124b:	89 ec                	mov    %ebp,%esp
f010124d:	5d                   	pop    %ebp
f010124e:	c3                   	ret    

f010124f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010124f:	55                   	push   %ebp
f0101250:	89 e5                	mov    %esp,%ebp
f0101252:	83 ec 28             	sub    $0x28,%esp
f0101255:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101258:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010125b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010125e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101261:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101264:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010126b:	00 
f010126c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101270:	8b 45 08             	mov    0x8(%ebp),%eax
f0101273:	89 04 24             	mov    %eax,(%esp)
f0101276:	e8 c5 fd ff ff       	call   f0101040 <pgdir_walk>
f010127b:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f010127d:	85 c0                	test   %eax,%eax
f010127f:	74 5a                	je     f01012db <page_insert+0x8c>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f0101281:	8b 00                	mov    (%eax),%eax
f0101283:	89 c1                	mov    %eax,%ecx
f0101285:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010128b:	89 da                	mov    %ebx,%edx
f010128d:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101293:	c1 fa 03             	sar    $0x3,%edx
f0101296:	c1 e2 0c             	shl    $0xc,%edx
f0101299:	39 d1                	cmp    %edx,%ecx
f010129b:	75 07                	jne    f01012a4 <page_insert+0x55>
		pp->pp_ref--;
f010129d:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01012a2:	eb 13                	jmp    f01012b7 <page_insert+0x68>
	
	else if(*pte != 0)
f01012a4:	85 c0                	test   %eax,%eax
f01012a6:	74 0f                	je     f01012b7 <page_insert+0x68>
		page_remove(pgdir, va);
f01012a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01012af:	89 04 24             	mov    %eax,(%esp)
f01012b2:	e8 38 ff ff ff       	call   f01011ef <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01012b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ba:	83 c8 01             	or     $0x1,%eax
f01012bd:	89 da                	mov    %ebx,%edx
f01012bf:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01012c5:	c1 fa 03             	sar    $0x3,%edx
f01012c8:	c1 e2 0c             	shl    $0xc,%edx
f01012cb:	09 d0                	or     %edx,%eax
f01012cd:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01012cf:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01012d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d9:	eb 05                	jmp    f01012e0 <page_insert+0x91>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f01012db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f01012e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01012e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01012e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01012e9:	89 ec                	mov    %ebp,%esp
f01012eb:	5d                   	pop    %ebp
f01012ec:	c3                   	ret    

f01012ed <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012ed:	55                   	push   %ebp
f01012ee:	89 e5                	mov    %esp,%ebp
f01012f0:	53                   	push   %ebx
f01012f1:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f01012f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012f7:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01012fd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	if(size + base >= MMIOLIM)
f0101303:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101309:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010130c:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101311:	76 1c                	jbe    f010132f <mmio_map_region+0x42>
		panic("mmio_map_region not implemented");
f0101313:	c7 44 24 08 10 70 10 	movl   $0xf0107010,0x8(%esp)
f010131a:	f0 
f010131b:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0101322:	00 
f0101323:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010132a:	e8 11 ed ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010132f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101336:	00 
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
	pa = ROUNDDOWN(pa, PGSIZE);
f0101337:	8b 45 08             	mov    0x8(%ebp),%eax
f010133a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if(size + base >= MMIOLIM)
		panic("mmio_map_region not implemented");
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010133f:	89 04 24             	mov    %eax,(%esp)
f0101342:	89 d9                	mov    %ebx,%ecx
f0101344:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101349:	e8 99 fd ff ff       	call   f01010e7 <boot_map_region>
	uintptr_t ret = base;
f010134e:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base +size;
f0101353:	01 c3                	add    %eax,%ebx
f0101355:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) ret;
}
f010135b:	83 c4 14             	add    $0x14,%esp
f010135e:	5b                   	pop    %ebx
f010135f:	5d                   	pop    %ebp
f0101360:	c3                   	ret    

f0101361 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101361:	55                   	push   %ebp
f0101362:	89 e5                	mov    %esp,%ebp
f0101364:	57                   	push   %edi
f0101365:	56                   	push   %esi
f0101366:	53                   	push   %ebx
f0101367:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010136a:	b8 15 00 00 00       	mov    $0x15,%eax
f010136f:	e8 53 f7 ff ff       	call   f0100ac7 <nvram_read>
f0101374:	c1 e0 0a             	shl    $0xa,%eax
f0101377:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010137d:	85 c0                	test   %eax,%eax
f010137f:	0f 48 c2             	cmovs  %edx,%eax
f0101382:	c1 f8 0c             	sar    $0xc,%eax
f0101385:	a3 38 c2 22 f0       	mov    %eax,0xf022c238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010138a:	b8 17 00 00 00       	mov    $0x17,%eax
f010138f:	e8 33 f7 ff ff       	call   f0100ac7 <nvram_read>
f0101394:	c1 e0 0a             	shl    $0xa,%eax
f0101397:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010139d:	85 c0                	test   %eax,%eax
f010139f:	0f 48 c2             	cmovs  %edx,%eax
f01013a2:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01013a5:	85 c0                	test   %eax,%eax
f01013a7:	74 0e                	je     f01013b7 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01013a9:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013af:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88
f01013b5:	eb 0c                	jmp    f01013c3 <mem_init+0x62>
	else
		npages = npages_basemem;
f01013b7:	8b 15 38 c2 22 f0    	mov    0xf022c238,%edx
f01013bd:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01013c3:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013c6:	c1 e8 0a             	shr    $0xa,%eax
f01013c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01013cd:	a1 38 c2 22 f0       	mov    0xf022c238,%eax
f01013d2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013d5:	c1 e8 0a             	shr    $0xa,%eax
f01013d8:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01013dc:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f01013e1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013e4:	c1 e8 0a             	shr    $0xa,%eax
f01013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013eb:	c7 04 24 30 70 10 f0 	movl   $0xf0107030,(%esp)
f01013f2:	e8 87 2b 00 00       	call   f0103f7e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013f7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013fc:	e8 13 f6 ff ff       	call   f0100a14 <boot_alloc>
f0101401:	a3 8c ce 22 f0       	mov    %eax,0xf022ce8c
	memset(kern_pgdir, 0, PGSIZE);
f0101406:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010140d:	00 
f010140e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101415:	00 
f0101416:	89 04 24             	mov    %eax,(%esp)
f0101419:	e8 75 48 00 00       	call   f0105c93 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010141e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101423:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101428:	77 20                	ja     f010144a <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010142a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010142e:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0101435:	f0 
f0101436:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f010143d:	00 
f010143e:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101445:	e8 f6 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010144a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101450:	83 ca 05             	or     $0x5,%edx
f0101453:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f0101459:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f010145e:	c1 e0 03             	shl    $0x3,%eax
f0101461:	e8 ae f5 ff ff       	call   f0100a14 <boot_alloc>
f0101466:	a3 90 ce 22 f0       	mov    %eax,0xf022ce90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f010146b:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
f0101471:	c1 e2 03             	shl    $0x3,%edx
f0101474:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101478:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010147f:	00 
f0101480:	89 04 24             	mov    %eax,(%esp)
f0101483:	e8 0b 48 00 00       	call   f0105c93 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101488:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010148d:	e8 82 f5 ff ff       	call   f0100a14 <boot_alloc>
f0101492:	a3 48 c2 22 f0       	mov    %eax,0xf022c248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101497:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010149e:	00 
f010149f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014a6:	00 
f01014a7:	89 04 24             	mov    %eax,(%esp)
f01014aa:	e8 e4 47 00 00       	call   f0105c93 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014af:	e8 a0 f9 ff ff       	call   f0100e54 <page_init>

	check_page_free_list(1);
f01014b4:	b8 01 00 00 00       	mov    $0x1,%eax
f01014b9:	e8 3b f6 ff ff       	call   f0100af9 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014be:	83 3d 90 ce 22 f0 00 	cmpl   $0x0,0xf022ce90
f01014c5:	75 1c                	jne    f01014e3 <mem_init+0x182>
		panic("'pages' is a null pointer!");
f01014c7:	c7 44 24 08 33 79 10 	movl   $0xf0107933,0x8(%esp)
f01014ce:	f0 
f01014cf:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01014d6:	00 
f01014d7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01014de:	e8 5d eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014e3:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f01014e8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014ed:	eb 05                	jmp    f01014f4 <mem_init+0x193>
		++nfree;
f01014ef:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014f2:	8b 00                	mov    (%eax),%eax
f01014f4:	85 c0                	test   %eax,%eax
f01014f6:	75 f7                	jne    f01014ef <mem_init+0x18e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ff:	e8 55 fa ff ff       	call   f0100f59 <page_alloc>
f0101504:	89 c6                	mov    %eax,%esi
f0101506:	85 c0                	test   %eax,%eax
f0101508:	75 24                	jne    f010152e <mem_init+0x1cd>
f010150a:	c7 44 24 0c 4e 79 10 	movl   $0xf010794e,0xc(%esp)
f0101511:	f0 
f0101512:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101519:	f0 
f010151a:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101521:	00 
f0101522:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101529:	e8 12 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010152e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101535:	e8 1f fa ff ff       	call   f0100f59 <page_alloc>
f010153a:	89 c7                	mov    %eax,%edi
f010153c:	85 c0                	test   %eax,%eax
f010153e:	75 24                	jne    f0101564 <mem_init+0x203>
f0101540:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f0101547:	f0 
f0101548:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010154f:	f0 
f0101550:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101557:	00 
f0101558:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010155f:	e8 dc ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101564:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010156b:	e8 e9 f9 ff ff       	call   f0100f59 <page_alloc>
f0101570:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101573:	85 c0                	test   %eax,%eax
f0101575:	75 24                	jne    f010159b <mem_init+0x23a>
f0101577:	c7 44 24 0c 7a 79 10 	movl   $0xf010797a,0xc(%esp)
f010157e:	f0 
f010157f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101586:	f0 
f0101587:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010158e:	00 
f010158f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101596:	e8 a5 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010159b:	39 fe                	cmp    %edi,%esi
f010159d:	75 24                	jne    f01015c3 <mem_init+0x262>
f010159f:	c7 44 24 0c 90 79 10 	movl   $0xf0107990,0xc(%esp)
f01015a6:	f0 
f01015a7:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01015ae:	f0 
f01015af:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f01015b6:	00 
f01015b7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01015be:	e8 7d ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c3:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01015c6:	74 05                	je     f01015cd <mem_init+0x26c>
f01015c8:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015cb:	75 24                	jne    f01015f1 <mem_init+0x290>
f01015cd:	c7 44 24 0c 6c 70 10 	movl   $0xf010706c,0xc(%esp)
f01015d4:	f0 
f01015d5:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01015dc:	f0 
f01015dd:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01015e4:	00 
f01015e5:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01015ec:	e8 4f ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015f1:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015f7:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f01015fc:	c1 e0 0c             	shl    $0xc,%eax
f01015ff:	89 f1                	mov    %esi,%ecx
f0101601:	29 d1                	sub    %edx,%ecx
f0101603:	c1 f9 03             	sar    $0x3,%ecx
f0101606:	c1 e1 0c             	shl    $0xc,%ecx
f0101609:	39 c1                	cmp    %eax,%ecx
f010160b:	72 24                	jb     f0101631 <mem_init+0x2d0>
f010160d:	c7 44 24 0c a2 79 10 	movl   $0xf01079a2,0xc(%esp)
f0101614:	f0 
f0101615:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010161c:	f0 
f010161d:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101624:	00 
f0101625:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010162c:	e8 0f ea ff ff       	call   f0100040 <_panic>
f0101631:	89 f9                	mov    %edi,%ecx
f0101633:	29 d1                	sub    %edx,%ecx
f0101635:	c1 f9 03             	sar    $0x3,%ecx
f0101638:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010163b:	39 c8                	cmp    %ecx,%eax
f010163d:	77 24                	ja     f0101663 <mem_init+0x302>
f010163f:	c7 44 24 0c bf 79 10 	movl   $0xf01079bf,0xc(%esp)
f0101646:	f0 
f0101647:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010164e:	f0 
f010164f:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101656:	00 
f0101657:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010165e:	e8 dd e9 ff ff       	call   f0100040 <_panic>
f0101663:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101666:	29 d1                	sub    %edx,%ecx
f0101668:	89 ca                	mov    %ecx,%edx
f010166a:	c1 fa 03             	sar    $0x3,%edx
f010166d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101670:	39 d0                	cmp    %edx,%eax
f0101672:	77 24                	ja     f0101698 <mem_init+0x337>
f0101674:	c7 44 24 0c dc 79 10 	movl   $0xf01079dc,0xc(%esp)
f010167b:	f0 
f010167c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101683:	f0 
f0101684:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f010168b:	00 
f010168c:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101693:	e8 a8 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101698:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f010169d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016a0:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f01016a7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016b1:	e8 a3 f8 ff ff       	call   f0100f59 <page_alloc>
f01016b6:	85 c0                	test   %eax,%eax
f01016b8:	74 24                	je     f01016de <mem_init+0x37d>
f01016ba:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f01016c1:	f0 
f01016c2:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01016c9:	f0 
f01016ca:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01016d1:	00 
f01016d2:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01016d9:	e8 62 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016de:	89 34 24             	mov    %esi,(%esp)
f01016e1:	e8 f7 f8 ff ff       	call   f0100fdd <page_free>
	page_free(pp1);
f01016e6:	89 3c 24             	mov    %edi,(%esp)
f01016e9:	e8 ef f8 ff ff       	call   f0100fdd <page_free>
	page_free(pp2);
f01016ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016f1:	89 04 24             	mov    %eax,(%esp)
f01016f4:	e8 e4 f8 ff ff       	call   f0100fdd <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101700:	e8 54 f8 ff ff       	call   f0100f59 <page_alloc>
f0101705:	89 c6                	mov    %eax,%esi
f0101707:	85 c0                	test   %eax,%eax
f0101709:	75 24                	jne    f010172f <mem_init+0x3ce>
f010170b:	c7 44 24 0c 4e 79 10 	movl   $0xf010794e,0xc(%esp)
f0101712:	f0 
f0101713:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010171a:	f0 
f010171b:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101722:	00 
f0101723:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010172a:	e8 11 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010172f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101736:	e8 1e f8 ff ff       	call   f0100f59 <page_alloc>
f010173b:	89 c7                	mov    %eax,%edi
f010173d:	85 c0                	test   %eax,%eax
f010173f:	75 24                	jne    f0101765 <mem_init+0x404>
f0101741:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f0101748:	f0 
f0101749:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101750:	f0 
f0101751:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101758:	00 
f0101759:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101760:	e8 db e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176c:	e8 e8 f7 ff ff       	call   f0100f59 <page_alloc>
f0101771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101774:	85 c0                	test   %eax,%eax
f0101776:	75 24                	jne    f010179c <mem_init+0x43b>
f0101778:	c7 44 24 0c 7a 79 10 	movl   $0xf010797a,0xc(%esp)
f010177f:	f0 
f0101780:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101787:	f0 
f0101788:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010178f:	00 
f0101790:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010179c:	39 fe                	cmp    %edi,%esi
f010179e:	75 24                	jne    f01017c4 <mem_init+0x463>
f01017a0:	c7 44 24 0c 90 79 10 	movl   $0xf0107990,0xc(%esp)
f01017a7:	f0 
f01017a8:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01017af:	f0 
f01017b0:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01017b7:	00 
f01017b8:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01017bf:	e8 7c e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017c7:	74 05                	je     f01017ce <mem_init+0x46d>
f01017c9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017cc:	75 24                	jne    f01017f2 <mem_init+0x491>
f01017ce:	c7 44 24 0c 6c 70 10 	movl   $0xf010706c,0xc(%esp)
f01017d5:	f0 
f01017d6:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01017dd:	f0 
f01017de:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f01017e5:	00 
f01017e6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01017ed:	e8 4e e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f9:	e8 5b f7 ff ff       	call   f0100f59 <page_alloc>
f01017fe:	85 c0                	test   %eax,%eax
f0101800:	74 24                	je     f0101826 <mem_init+0x4c5>
f0101802:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f0101809:	f0 
f010180a:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101811:	f0 
f0101812:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101819:	00 
f010181a:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101821:	e8 1a e8 ff ff       	call   f0100040 <_panic>
f0101826:	89 f0                	mov    %esi,%eax
f0101828:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f010182e:	c1 f8 03             	sar    $0x3,%eax
f0101831:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101834:	89 c2                	mov    %eax,%edx
f0101836:	c1 ea 0c             	shr    $0xc,%edx
f0101839:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f010183f:	72 20                	jb     f0101861 <mem_init+0x500>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101841:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101845:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f010184c:	f0 
f010184d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101854:	00 
f0101855:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f010185c:	e8 df e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101861:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101868:	00 
f0101869:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101870:	00 
	return (void *)(pa + KERNBASE);
f0101871:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101876:	89 04 24             	mov    %eax,(%esp)
f0101879:	e8 15 44 00 00       	call   f0105c93 <memset>
	page_free(pp0);
f010187e:	89 34 24             	mov    %esi,(%esp)
f0101881:	e8 57 f7 ff ff       	call   f0100fdd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101886:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010188d:	e8 c7 f6 ff ff       	call   f0100f59 <page_alloc>
f0101892:	85 c0                	test   %eax,%eax
f0101894:	75 24                	jne    f01018ba <mem_init+0x559>
f0101896:	c7 44 24 0c 08 7a 10 	movl   $0xf0107a08,0xc(%esp)
f010189d:	f0 
f010189e:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01018a5:	f0 
f01018a6:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01018ad:	00 
f01018ae:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01018b5:	e8 86 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018ba:	39 c6                	cmp    %eax,%esi
f01018bc:	74 24                	je     f01018e2 <mem_init+0x581>
f01018be:	c7 44 24 0c 26 7a 10 	movl   $0xf0107a26,0xc(%esp)
f01018c5:	f0 
f01018c6:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01018cd:	f0 
f01018ce:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01018d5:	00 
f01018d6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01018dd:	e8 5e e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e2:	89 f2                	mov    %esi,%edx
f01018e4:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01018ea:	c1 fa 03             	sar    $0x3,%edx
f01018ed:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f0:	89 d0                	mov    %edx,%eax
f01018f2:	c1 e8 0c             	shr    $0xc,%eax
f01018f5:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01018fb:	72 20                	jb     f010191d <mem_init+0x5bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101901:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0101908:	f0 
f0101909:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101910:	00 
f0101911:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0101918:	e8 23 e7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010191d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101923:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101929:	80 38 00             	cmpb   $0x0,(%eax)
f010192c:	74 24                	je     f0101952 <mem_init+0x5f1>
f010192e:	c7 44 24 0c 36 7a 10 	movl   $0xf0107a36,0xc(%esp)
f0101935:	f0 
f0101936:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010193d:	f0 
f010193e:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101945:	00 
f0101946:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010194d:	e8 ee e6 ff ff       	call   f0100040 <_panic>
f0101952:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101955:	39 d0                	cmp    %edx,%eax
f0101957:	75 d0                	jne    f0101929 <mem_init+0x5c8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101959:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010195c:	89 15 40 c2 22 f0    	mov    %edx,0xf022c240

	// free the pages we took
	page_free(pp0);
f0101962:	89 34 24             	mov    %esi,(%esp)
f0101965:	e8 73 f6 ff ff       	call   f0100fdd <page_free>
	page_free(pp1);
f010196a:	89 3c 24             	mov    %edi,(%esp)
f010196d:	e8 6b f6 ff ff       	call   f0100fdd <page_free>
	page_free(pp2);
f0101972:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101975:	89 04 24             	mov    %eax,(%esp)
f0101978:	e8 60 f6 ff ff       	call   f0100fdd <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010197d:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f0101982:	eb 05                	jmp    f0101989 <mem_init+0x628>
		--nfree;
f0101984:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101987:	8b 00                	mov    (%eax),%eax
f0101989:	85 c0                	test   %eax,%eax
f010198b:	75 f7                	jne    f0101984 <mem_init+0x623>
		--nfree;
	assert(nfree == 0);
f010198d:	85 db                	test   %ebx,%ebx
f010198f:	74 24                	je     f01019b5 <mem_init+0x654>
f0101991:	c7 44 24 0c 40 7a 10 	movl   $0xf0107a40,0xc(%esp)
f0101998:	f0 
f0101999:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01019a0:	f0 
f01019a1:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01019a8:	00 
f01019a9:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01019b0:	e8 8b e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019b5:	c7 04 24 8c 70 10 f0 	movl   $0xf010708c,(%esp)
f01019bc:	e8 bd 25 00 00       	call   f0103f7e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c8:	e8 8c f5 ff ff       	call   f0100f59 <page_alloc>
f01019cd:	89 c7                	mov    %eax,%edi
f01019cf:	85 c0                	test   %eax,%eax
f01019d1:	75 24                	jne    f01019f7 <mem_init+0x696>
f01019d3:	c7 44 24 0c 4e 79 10 	movl   $0xf010794e,0xc(%esp)
f01019da:	f0 
f01019db:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01019e2:	f0 
f01019e3:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01019ea:	00 
f01019eb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01019f2:	e8 49 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019fe:	e8 56 f5 ff ff       	call   f0100f59 <page_alloc>
f0101a03:	89 c6                	mov    %eax,%esi
f0101a05:	85 c0                	test   %eax,%eax
f0101a07:	75 24                	jne    f0101a2d <mem_init+0x6cc>
f0101a09:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f0101a10:	f0 
f0101a11:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101a18:	f0 
f0101a19:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101a20:	00 
f0101a21:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101a28:	e8 13 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a34:	e8 20 f5 ff ff       	call   f0100f59 <page_alloc>
f0101a39:	89 c3                	mov    %eax,%ebx
f0101a3b:	85 c0                	test   %eax,%eax
f0101a3d:	75 24                	jne    f0101a63 <mem_init+0x702>
f0101a3f:	c7 44 24 0c 7a 79 10 	movl   $0xf010797a,0xc(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101a4e:	f0 
f0101a4f:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101a56:	00 
f0101a57:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101a5e:	e8 dd e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a63:	39 f7                	cmp    %esi,%edi
f0101a65:	75 24                	jne    f0101a8b <mem_init+0x72a>
f0101a67:	c7 44 24 0c 90 79 10 	movl   $0xf0107990,0xc(%esp)
f0101a6e:	f0 
f0101a6f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101a76:	f0 
f0101a77:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101a7e:	00 
f0101a7f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101a86:	e8 b5 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a8b:	39 c6                	cmp    %eax,%esi
f0101a8d:	74 04                	je     f0101a93 <mem_init+0x732>
f0101a8f:	39 c7                	cmp    %eax,%edi
f0101a91:	75 24                	jne    f0101ab7 <mem_init+0x756>
f0101a93:	c7 44 24 0c 6c 70 10 	movl   $0xf010706c,0xc(%esp)
f0101a9a:	f0 
f0101a9b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101aa2:	f0 
f0101aa3:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101aaa:	00 
f0101aab:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101ab2:	e8 89 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ab7:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0101abd:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101ac0:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f0101ac7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101aca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ad1:	e8 83 f4 ff ff       	call   f0100f59 <page_alloc>
f0101ad6:	85 c0                	test   %eax,%eax
f0101ad8:	74 24                	je     f0101afe <mem_init+0x79d>
f0101ada:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f0101ae1:	f0 
f0101ae2:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101ae9:	f0 
f0101aea:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101af1:	00 
f0101af2:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101af9:	e8 42 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101afe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b01:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b0c:	00 
f0101b0d:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101b12:	89 04 24             	mov    %eax,(%esp)
f0101b15:	e8 2b f6 ff ff       	call   f0101145 <page_lookup>
f0101b1a:	85 c0                	test   %eax,%eax
f0101b1c:	74 24                	je     f0101b42 <mem_init+0x7e1>
f0101b1e:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0101b25:	f0 
f0101b26:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101b2d:	f0 
f0101b2e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101b35:	00 
f0101b36:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101b3d:	e8 fe e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b49:	00 
f0101b4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b51:	00 
f0101b52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b56:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101b5b:	89 04 24             	mov    %eax,(%esp)
f0101b5e:	e8 ec f6 ff ff       	call   f010124f <page_insert>
f0101b63:	85 c0                	test   %eax,%eax
f0101b65:	78 24                	js     f0101b8b <mem_init+0x82a>
f0101b67:	c7 44 24 0c e4 70 10 	movl   $0xf01070e4,0xc(%esp)
f0101b6e:	f0 
f0101b6f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101b76:	f0 
f0101b77:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101b7e:	00 
f0101b7f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101b86:	e8 b5 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b8b:	89 3c 24             	mov    %edi,(%esp)
f0101b8e:	e8 4a f4 ff ff       	call   f0100fdd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b93:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b9a:	00 
f0101b9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ba2:	00 
f0101ba3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ba7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101bac:	89 04 24             	mov    %eax,(%esp)
f0101baf:	e8 9b f6 ff ff       	call   f010124f <page_insert>
f0101bb4:	85 c0                	test   %eax,%eax
f0101bb6:	74 24                	je     f0101bdc <mem_init+0x87b>
f0101bb8:	c7 44 24 0c 14 71 10 	movl   $0xf0107114,0xc(%esp)
f0101bbf:	f0 
f0101bc0:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101bc7:	f0 
f0101bc8:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101bcf:	00 
f0101bd0:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101bd7:	e8 64 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bdc:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f0101be2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101be5:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0101bea:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bed:	8b 11                	mov    (%ecx),%edx
f0101bef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bf5:	89 f8                	mov    %edi,%eax
f0101bf7:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101bfa:	c1 f8 03             	sar    $0x3,%eax
f0101bfd:	c1 e0 0c             	shl    $0xc,%eax
f0101c00:	39 c2                	cmp    %eax,%edx
f0101c02:	74 24                	je     f0101c28 <mem_init+0x8c7>
f0101c04:	c7 44 24 0c 44 71 10 	movl   $0xf0107144,0xc(%esp)
f0101c0b:	f0 
f0101c0c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101c13:	f0 
f0101c14:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101c1b:	00 
f0101c1c:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101c23:	e8 18 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c28:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c30:	e8 21 ee ff ff       	call   f0100a56 <check_va2pa>
f0101c35:	89 f2                	mov    %esi,%edx
f0101c37:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c3a:	c1 fa 03             	sar    $0x3,%edx
f0101c3d:	c1 e2 0c             	shl    $0xc,%edx
f0101c40:	39 d0                	cmp    %edx,%eax
f0101c42:	74 24                	je     f0101c68 <mem_init+0x907>
f0101c44:	c7 44 24 0c 6c 71 10 	movl   $0xf010716c,0xc(%esp)
f0101c4b:	f0 
f0101c4c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101c53:	f0 
f0101c54:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101c5b:	00 
f0101c5c:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101c63:	e8 d8 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c68:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6d:	74 24                	je     f0101c93 <mem_init+0x932>
f0101c6f:	c7 44 24 0c 4b 7a 10 	movl   $0xf0107a4b,0xc(%esp)
f0101c76:	f0 
f0101c77:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101c7e:	f0 
f0101c7f:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101c86:	00 
f0101c87:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101c8e:	e8 ad e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c93:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c98:	74 24                	je     f0101cbe <mem_init+0x95d>
f0101c9a:	c7 44 24 0c 5c 7a 10 	movl   $0xf0107a5c,0xc(%esp)
f0101ca1:	f0 
f0101ca2:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101ca9:	f0 
f0101caa:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101cb1:	00 
f0101cb2:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101cb9:	e8 82 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cbe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cc5:	00 
f0101cc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ccd:	00 
f0101cce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cd2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101cd5:	89 14 24             	mov    %edx,(%esp)
f0101cd8:	e8 72 f5 ff ff       	call   f010124f <page_insert>
f0101cdd:	85 c0                	test   %eax,%eax
f0101cdf:	74 24                	je     f0101d05 <mem_init+0x9a4>
f0101ce1:	c7 44 24 0c 9c 71 10 	movl   $0xf010719c,0xc(%esp)
f0101ce8:	f0 
f0101ce9:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101cf0:	f0 
f0101cf1:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101cf8:	00 
f0101cf9:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101d00:	e8 3b e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101d0f:	e8 42 ed ff ff       	call   f0100a56 <check_va2pa>
f0101d14:	89 da                	mov    %ebx,%edx
f0101d16:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101d1c:	c1 fa 03             	sar    $0x3,%edx
f0101d1f:	c1 e2 0c             	shl    $0xc,%edx
f0101d22:	39 d0                	cmp    %edx,%eax
f0101d24:	74 24                	je     f0101d4a <mem_init+0x9e9>
f0101d26:	c7 44 24 0c d8 71 10 	movl   $0xf01071d8,0xc(%esp)
f0101d2d:	f0 
f0101d2e:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101d35:	f0 
f0101d36:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101d3d:	00 
f0101d3e:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101d45:	e8 f6 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d4a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d4f:	74 24                	je     f0101d75 <mem_init+0xa14>
f0101d51:	c7 44 24 0c 6d 7a 10 	movl   $0xf0107a6d,0xc(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101d60:	f0 
f0101d61:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101d68:	00 
f0101d69:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101d70:	e8 cb e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d7c:	e8 d8 f1 ff ff       	call   f0100f59 <page_alloc>
f0101d81:	85 c0                	test   %eax,%eax
f0101d83:	74 24                	je     f0101da9 <mem_init+0xa48>
f0101d85:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f0101d8c:	f0 
f0101d8d:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101d94:	f0 
f0101d95:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101d9c:	00 
f0101d9d:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101da4:	e8 97 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101da9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101db0:	00 
f0101db1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101db8:	00 
f0101db9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dbd:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101dc2:	89 04 24             	mov    %eax,(%esp)
f0101dc5:	e8 85 f4 ff ff       	call   f010124f <page_insert>
f0101dca:	85 c0                	test   %eax,%eax
f0101dcc:	74 24                	je     f0101df2 <mem_init+0xa91>
f0101dce:	c7 44 24 0c 9c 71 10 	movl   $0xf010719c,0xc(%esp)
f0101dd5:	f0 
f0101dd6:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101ddd:	f0 
f0101dde:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101de5:	00 
f0101de6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101ded:	e8 4e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101df2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101dfc:	e8 55 ec ff ff       	call   f0100a56 <check_va2pa>
f0101e01:	89 da                	mov    %ebx,%edx
f0101e03:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101e09:	c1 fa 03             	sar    $0x3,%edx
f0101e0c:	c1 e2 0c             	shl    $0xc,%edx
f0101e0f:	39 d0                	cmp    %edx,%eax
f0101e11:	74 24                	je     f0101e37 <mem_init+0xad6>
f0101e13:	c7 44 24 0c d8 71 10 	movl   $0xf01071d8,0xc(%esp)
f0101e1a:	f0 
f0101e1b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101e22:	f0 
f0101e23:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101e2a:	00 
f0101e2b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101e32:	e8 09 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e37:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e3c:	74 24                	je     f0101e62 <mem_init+0xb01>
f0101e3e:	c7 44 24 0c 6d 7a 10 	movl   $0xf0107a6d,0xc(%esp)
f0101e45:	f0 
f0101e46:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101e55:	00 
f0101e56:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101e5d:	e8 de e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e69:	e8 eb f0 ff ff       	call   f0100f59 <page_alloc>
f0101e6e:	85 c0                	test   %eax,%eax
f0101e70:	74 24                	je     f0101e96 <mem_init+0xb35>
f0101e72:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101e81:	f0 
f0101e82:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101e89:	00 
f0101e8a:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101e91:	e8 aa e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e96:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0101e9c:	8b 02                	mov    (%edx),%eax
f0101e9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ea3:	89 c1                	mov    %eax,%ecx
f0101ea5:	c1 e9 0c             	shr    $0xc,%ecx
f0101ea8:	3b 0d 88 ce 22 f0    	cmp    0xf022ce88,%ecx
f0101eae:	72 20                	jb     f0101ed0 <mem_init+0xb6f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101eb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101eb4:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0101ebb:	f0 
f0101ebc:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101ec3:	00 
f0101ec4:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101ecb:	e8 70 e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101ed0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ed5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ed8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101edf:	00 
f0101ee0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ee7:	00 
f0101ee8:	89 14 24             	mov    %edx,(%esp)
f0101eeb:	e8 50 f1 ff ff       	call   f0101040 <pgdir_walk>
f0101ef0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ef3:	83 c2 04             	add    $0x4,%edx
f0101ef6:	39 d0                	cmp    %edx,%eax
f0101ef8:	74 24                	je     f0101f1e <mem_init+0xbbd>
f0101efa:	c7 44 24 0c 08 72 10 	movl   $0xf0107208,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101f19:	e8 22 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f1e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f25:	00 
f0101f26:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f2d:	00 
f0101f2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f32:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101f37:	89 04 24             	mov    %eax,(%esp)
f0101f3a:	e8 10 f3 ff ff       	call   f010124f <page_insert>
f0101f3f:	85 c0                	test   %eax,%eax
f0101f41:	74 24                	je     f0101f67 <mem_init+0xc06>
f0101f43:	c7 44 24 0c 48 72 10 	movl   $0xf0107248,0xc(%esp)
f0101f4a:	f0 
f0101f4b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101f5a:	00 
f0101f5b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101f62:	e8 d9 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f67:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f0101f6d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f70:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f75:	89 c8                	mov    %ecx,%eax
f0101f77:	e8 da ea ff ff       	call   f0100a56 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f7c:	89 da                	mov    %ebx,%edx
f0101f7e:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101f84:	c1 fa 03             	sar    $0x3,%edx
f0101f87:	c1 e2 0c             	shl    $0xc,%edx
f0101f8a:	39 d0                	cmp    %edx,%eax
f0101f8c:	74 24                	je     f0101fb2 <mem_init+0xc51>
f0101f8e:	c7 44 24 0c d8 71 10 	movl   $0xf01071d8,0xc(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0101fa5:	00 
f0101fa6:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101fad:	e8 8e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fb2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fb7:	74 24                	je     f0101fdd <mem_init+0xc7c>
f0101fb9:	c7 44 24 0c 6d 7a 10 	movl   $0xf0107a6d,0xc(%esp)
f0101fc0:	f0 
f0101fc1:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101fd0:	00 
f0101fd1:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0101fd8:	e8 63 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe4:	00 
f0101fe5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fec:	00 
f0101fed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff0:	89 04 24             	mov    %eax,(%esp)
f0101ff3:	e8 48 f0 ff ff       	call   f0101040 <pgdir_walk>
f0101ff8:	f6 00 04             	testb  $0x4,(%eax)
f0101ffb:	75 24                	jne    f0102021 <mem_init+0xcc0>
f0101ffd:	c7 44 24 0c 88 72 10 	movl   $0xf0107288,0xc(%esp)
f0102004:	f0 
f0102005:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010200c:	f0 
f010200d:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102014:	00 
f0102015:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102021:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102026:	f6 00 04             	testb  $0x4,(%eax)
f0102029:	75 24                	jne    f010204f <mem_init+0xcee>
f010202b:	c7 44 24 0c 7e 7a 10 	movl   $0xf0107a7e,0xc(%esp)
f0102032:	f0 
f0102033:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010203a:	f0 
f010203b:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102042:	00 
f0102043:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010204a:	e8 f1 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010204f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102056:	00 
f0102057:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010205e:	00 
f010205f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102063:	89 04 24             	mov    %eax,(%esp)
f0102066:	e8 e4 f1 ff ff       	call   f010124f <page_insert>
f010206b:	85 c0                	test   %eax,%eax
f010206d:	74 24                	je     f0102093 <mem_init+0xd32>
f010206f:	c7 44 24 0c 9c 71 10 	movl   $0xf010719c,0xc(%esp)
f0102076:	f0 
f0102077:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010207e:	f0 
f010207f:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102086:	00 
f0102087:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010208e:	e8 ad df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102093:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010209a:	00 
f010209b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020a2:	00 
f01020a3:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01020a8:	89 04 24             	mov    %eax,(%esp)
f01020ab:	e8 90 ef ff ff       	call   f0101040 <pgdir_walk>
f01020b0:	f6 00 02             	testb  $0x2,(%eax)
f01020b3:	75 24                	jne    f01020d9 <mem_init+0xd78>
f01020b5:	c7 44 24 0c bc 72 10 	movl   $0xf01072bc,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01020d4:	e8 67 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020e0:	00 
f01020e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020e8:	00 
f01020e9:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01020ee:	89 04 24             	mov    %eax,(%esp)
f01020f1:	e8 4a ef ff ff       	call   f0101040 <pgdir_walk>
f01020f6:	f6 00 04             	testb  $0x4,(%eax)
f01020f9:	74 24                	je     f010211f <mem_init+0xdbe>
f01020fb:	c7 44 24 0c f0 72 10 	movl   $0xf01072f0,0xc(%esp)
f0102102:	f0 
f0102103:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010210a:	f0 
f010210b:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102112:	00 
f0102113:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010211a:	e8 21 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010211f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102126:	00 
f0102127:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010212e:	00 
f010212f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102133:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102138:	89 04 24             	mov    %eax,(%esp)
f010213b:	e8 0f f1 ff ff       	call   f010124f <page_insert>
f0102140:	85 c0                	test   %eax,%eax
f0102142:	78 24                	js     f0102168 <mem_init+0xe07>
f0102144:	c7 44 24 0c 28 73 10 	movl   $0xf0107328,0xc(%esp)
f010214b:	f0 
f010214c:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102153:	f0 
f0102154:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f010215b:	00 
f010215c:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102163:	e8 d8 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102168:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010216f:	00 
f0102170:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102177:	00 
f0102178:	89 74 24 04          	mov    %esi,0x4(%esp)
f010217c:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102181:	89 04 24             	mov    %eax,(%esp)
f0102184:	e8 c6 f0 ff ff       	call   f010124f <page_insert>
f0102189:	85 c0                	test   %eax,%eax
f010218b:	74 24                	je     f01021b1 <mem_init+0xe50>
f010218d:	c7 44 24 0c 60 73 10 	movl   $0xf0107360,0xc(%esp)
f0102194:	f0 
f0102195:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010219c:	f0 
f010219d:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01021a4:	00 
f01021a5:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01021ac:	e8 8f de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021b8:	00 
f01021b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021c0:	00 
f01021c1:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01021c6:	89 04 24             	mov    %eax,(%esp)
f01021c9:	e8 72 ee ff ff       	call   f0101040 <pgdir_walk>
f01021ce:	f6 00 04             	testb  $0x4,(%eax)
f01021d1:	74 24                	je     f01021f7 <mem_init+0xe96>
f01021d3:	c7 44 24 0c f0 72 10 	movl   $0xf01072f0,0xc(%esp)
f01021da:	f0 
f01021db:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01021f2:	e8 49 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021f7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01021fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0102204:	e8 4d e8 ff ff       	call   f0100a56 <check_va2pa>
f0102209:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010220c:	89 f0                	mov    %esi,%eax
f010220e:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0102214:	c1 f8 03             	sar    $0x3,%eax
f0102217:	c1 e0 0c             	shl    $0xc,%eax
f010221a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010221d:	74 24                	je     f0102243 <mem_init+0xee2>
f010221f:	c7 44 24 0c 9c 73 10 	movl   $0xf010739c,0xc(%esp)
f0102226:	f0 
f0102227:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010222e:	f0 
f010222f:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102236:	00 
f0102237:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010223e:	e8 fd dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102243:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224b:	e8 06 e8 ff ff       	call   f0100a56 <check_va2pa>
f0102250:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102253:	74 24                	je     f0102279 <mem_init+0xf18>
f0102255:	c7 44 24 0c c8 73 10 	movl   $0xf01073c8,0xc(%esp)
f010225c:	f0 
f010225d:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102264:	f0 
f0102265:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010226c:	00 
f010226d:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102274:	e8 c7 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102279:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010227e:	74 24                	je     f01022a4 <mem_init+0xf43>
f0102280:	c7 44 24 0c 94 7a 10 	movl   $0xf0107a94,0xc(%esp)
f0102287:	f0 
f0102288:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010228f:	f0 
f0102290:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102297:	00 
f0102298:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010229f:	e8 9c dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022a4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a9:	74 24                	je     f01022cf <mem_init+0xf6e>
f01022ab:	c7 44 24 0c a5 7a 10 	movl   $0xf0107aa5,0xc(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01022ba:	f0 
f01022bb:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01022c2:	00 
f01022c3:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01022ca:	e8 71 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022d6:	e8 7e ec ff ff       	call   f0100f59 <page_alloc>
f01022db:	85 c0                	test   %eax,%eax
f01022dd:	74 04                	je     f01022e3 <mem_init+0xf82>
f01022df:	39 c3                	cmp    %eax,%ebx
f01022e1:	74 24                	je     f0102307 <mem_init+0xfa6>
f01022e3:	c7 44 24 0c f8 73 10 	movl   $0xf01073f8,0xc(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01022fa:	00 
f01022fb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102302:	e8 39 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102307:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010230e:	00 
f010230f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102314:	89 04 24             	mov    %eax,(%esp)
f0102317:	e8 d3 ee ff ff       	call   f01011ef <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010231c:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0102322:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102325:	ba 00 00 00 00       	mov    $0x0,%edx
f010232a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010232d:	e8 24 e7 ff ff       	call   f0100a56 <check_va2pa>
f0102332:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102335:	74 24                	je     f010235b <mem_init+0xffa>
f0102337:	c7 44 24 0c 1c 74 10 	movl   $0xf010741c,0xc(%esp)
f010233e:	f0 
f010233f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102346:	f0 
f0102347:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010234e:	00 
f010234f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102356:	e8 e5 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010235b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102360:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102363:	e8 ee e6 ff ff       	call   f0100a56 <check_va2pa>
f0102368:	89 f2                	mov    %esi,%edx
f010236a:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102370:	c1 fa 03             	sar    $0x3,%edx
f0102373:	c1 e2 0c             	shl    $0xc,%edx
f0102376:	39 d0                	cmp    %edx,%eax
f0102378:	74 24                	je     f010239e <mem_init+0x103d>
f010237a:	c7 44 24 0c c8 73 10 	movl   $0xf01073c8,0xc(%esp)
f0102381:	f0 
f0102382:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102389:	f0 
f010238a:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102391:	00 
f0102392:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010239e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023a3:	74 24                	je     f01023c9 <mem_init+0x1068>
f01023a5:	c7 44 24 0c 4b 7a 10 	movl   $0xf0107a4b,0xc(%esp)
f01023ac:	f0 
f01023ad:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01023b4:	f0 
f01023b5:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01023bc:	00 
f01023bd:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01023c4:	e8 77 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023c9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023ce:	74 24                	je     f01023f4 <mem_init+0x1093>
f01023d0:	c7 44 24 0c a5 7a 10 	movl   $0xf0107aa5,0xc(%esp)
f01023d7:	f0 
f01023d8:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01023df:	f0 
f01023e0:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f01023e7:	00 
f01023e8:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01023ef:	e8 4c dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01023f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01023fb:	00 
f01023fc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102403:	00 
f0102404:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102408:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010240b:	89 0c 24             	mov    %ecx,(%esp)
f010240e:	e8 3c ee ff ff       	call   f010124f <page_insert>
f0102413:	85 c0                	test   %eax,%eax
f0102415:	74 24                	je     f010243b <mem_init+0x10da>
f0102417:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f010241e:	f0 
f010241f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102426:	f0 
f0102427:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010242e:	00 
f010242f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102436:	e8 05 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010243b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102440:	75 24                	jne    f0102466 <mem_init+0x1105>
f0102442:	c7 44 24 0c b6 7a 10 	movl   $0xf0107ab6,0xc(%esp)
f0102449:	f0 
f010244a:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102451:	f0 
f0102452:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0102459:	00 
f010245a:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102461:	e8 da db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102466:	83 3e 00             	cmpl   $0x0,(%esi)
f0102469:	74 24                	je     f010248f <mem_init+0x112e>
f010246b:	c7 44 24 0c c2 7a 10 	movl   $0xf0107ac2,0xc(%esp)
f0102472:	f0 
f0102473:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010247a:	f0 
f010247b:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102482:	00 
f0102483:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010248a:	e8 b1 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010248f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102496:	00 
f0102497:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010249c:	89 04 24             	mov    %eax,(%esp)
f010249f:	e8 4b ed ff ff       	call   f01011ef <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024a4:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01024a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01024b1:	e8 a0 e5 ff ff       	call   f0100a56 <check_va2pa>
f01024b6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024b9:	74 24                	je     f01024df <mem_init+0x117e>
f01024bb:	c7 44 24 0c 1c 74 10 	movl   $0xf010741c,0xc(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01024d2:	00 
f01024d3:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01024da:	e8 61 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024df:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024e7:	e8 6a e5 ff ff       	call   f0100a56 <check_va2pa>
f01024ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024ef:	74 24                	je     f0102515 <mem_init+0x11b4>
f01024f1:	c7 44 24 0c 78 74 10 	movl   $0xf0107478,0xc(%esp)
f01024f8:	f0 
f01024f9:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102500:	f0 
f0102501:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0102508:	00 
f0102509:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102510:	e8 2b db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102515:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010251a:	74 24                	je     f0102540 <mem_init+0x11df>
f010251c:	c7 44 24 0c d7 7a 10 	movl   $0xf0107ad7,0xc(%esp)
f0102523:	f0 
f0102524:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010252b:	f0 
f010252c:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102533:	00 
f0102534:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010253b:	e8 00 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102540:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102545:	74 24                	je     f010256b <mem_init+0x120a>
f0102547:	c7 44 24 0c a5 7a 10 	movl   $0xf0107aa5,0xc(%esp)
f010254e:	f0 
f010254f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102556:	f0 
f0102557:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f010255e:	00 
f010255f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102566:	e8 d5 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010256b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102572:	e8 e2 e9 ff ff       	call   f0100f59 <page_alloc>
f0102577:	85 c0                	test   %eax,%eax
f0102579:	74 04                	je     f010257f <mem_init+0x121e>
f010257b:	39 c6                	cmp    %eax,%esi
f010257d:	74 24                	je     f01025a3 <mem_init+0x1242>
f010257f:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0102586:	f0 
f0102587:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010258e:	f0 
f010258f:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102596:	00 
f0102597:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010259e:	e8 9d da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01025a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025aa:	e8 aa e9 ff ff       	call   f0100f59 <page_alloc>
f01025af:	85 c0                	test   %eax,%eax
f01025b1:	74 24                	je     f01025d7 <mem_init+0x1276>
f01025b3:	c7 44 24 0c f9 79 10 	movl   $0xf01079f9,0xc(%esp)
f01025ba:	f0 
f01025bb:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01025c2:	f0 
f01025c3:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01025ca:	00 
f01025cb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01025d2:	e8 69 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025d7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01025dc:	8b 08                	mov    (%eax),%ecx
f01025de:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025e4:	89 fa                	mov    %edi,%edx
f01025e6:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01025ec:	c1 fa 03             	sar    $0x3,%edx
f01025ef:	c1 e2 0c             	shl    $0xc,%edx
f01025f2:	39 d1                	cmp    %edx,%ecx
f01025f4:	74 24                	je     f010261a <mem_init+0x12b9>
f01025f6:	c7 44 24 0c 44 71 10 	movl   $0xf0107144,0xc(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102605:	f0 
f0102606:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f010260d:	00 
f010260e:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102615:	e8 26 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010261a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102620:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102625:	74 24                	je     f010264b <mem_init+0x12ea>
f0102627:	c7 44 24 0c 5c 7a 10 	movl   $0xf0107a5c,0xc(%esp)
f010262e:	f0 
f010262f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102636:	f0 
f0102637:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010263e:	00 
f010263f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102646:	e8 f5 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010264b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102651:	89 3c 24             	mov    %edi,(%esp)
f0102654:	e8 84 e9 ff ff       	call   f0100fdd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102659:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102660:	00 
f0102661:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102668:	00 
f0102669:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010266e:	89 04 24             	mov    %eax,(%esp)
f0102671:	e8 ca e9 ff ff       	call   f0101040 <pgdir_walk>
f0102676:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102679:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f010267f:	8b 51 04             	mov    0x4(%ecx),%edx
f0102682:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102688:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010268b:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
f0102691:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102694:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102697:	c1 ea 0c             	shr    $0xc,%edx
f010269a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010269d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01026a0:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01026a3:	72 23                	jb     f01026c8 <mem_init+0x1367>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026a5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01026a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01026ac:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01026b3:	f0 
f01026b4:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f01026bb:	00 
f01026bc:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01026c3:	e8 78 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026cb:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01026d1:	39 d0                	cmp    %edx,%eax
f01026d3:	74 24                	je     f01026f9 <mem_init+0x1398>
f01026d5:	c7 44 24 0c e8 7a 10 	movl   $0xf0107ae8,0xc(%esp)
f01026dc:	f0 
f01026dd:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f01026ec:	00 
f01026ed:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01026f4:	e8 47 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01026f9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102700:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102706:	89 f8                	mov    %edi,%eax
f0102708:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f010270e:	c1 f8 03             	sar    $0x3,%eax
f0102711:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102714:	89 c1                	mov    %eax,%ecx
f0102716:	c1 e9 0c             	shr    $0xc,%ecx
f0102719:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010271c:	77 20                	ja     f010273e <mem_init+0x13dd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010271e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102722:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0102729:	f0 
f010272a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102731:	00 
f0102732:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0102739:	e8 02 d9 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010273e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102745:	00 
f0102746:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010274d:	00 
	return (void *)(pa + KERNBASE);
f010274e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102753:	89 04 24             	mov    %eax,(%esp)
f0102756:	e8 38 35 00 00       	call   f0105c93 <memset>
	page_free(pp0);
f010275b:	89 3c 24             	mov    %edi,(%esp)
f010275e:	e8 7a e8 ff ff       	call   f0100fdd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102763:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010276a:	00 
f010276b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102772:	00 
f0102773:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102778:	89 04 24             	mov    %eax,(%esp)
f010277b:	e8 c0 e8 ff ff       	call   f0101040 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102780:	89 fa                	mov    %edi,%edx
f0102782:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102788:	c1 fa 03             	sar    $0x3,%edx
f010278b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010278e:	89 d0                	mov    %edx,%eax
f0102790:	c1 e8 0c             	shr    $0xc,%eax
f0102793:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0102799:	72 20                	jb     f01027bb <mem_init+0x145a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010279b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010279f:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01027a6:	f0 
f01027a7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027ae:	00 
f01027af:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f01027b6:	e8 85 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01027bb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01027c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027c4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01027ca:	f6 00 01             	testb  $0x1,(%eax)
f01027cd:	74 24                	je     f01027f3 <mem_init+0x1492>
f01027cf:	c7 44 24 0c 00 7b 10 	movl   $0xf0107b00,0xc(%esp)
f01027d6:	f0 
f01027d7:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01027de:	f0 
f01027df:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01027e6:	00 
f01027e7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01027ee:	e8 4d d8 ff ff       	call   f0100040 <_panic>
f01027f3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01027f6:	39 d0                	cmp    %edx,%eax
f01027f8:	75 d0                	jne    f01027ca <mem_init+0x1469>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01027fa:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01027ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102805:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010280b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010280e:	89 0d 40 c2 22 f0    	mov    %ecx,0xf022c240

	// free the pages we took
	page_free(pp0);
f0102814:	89 3c 24             	mov    %edi,(%esp)
f0102817:	e8 c1 e7 ff ff       	call   f0100fdd <page_free>
	page_free(pp1);
f010281c:	89 34 24             	mov    %esi,(%esp)
f010281f:	e8 b9 e7 ff ff       	call   f0100fdd <page_free>
	page_free(pp2);
f0102824:	89 1c 24             	mov    %ebx,(%esp)
f0102827:	e8 b1 e7 ff ff       	call   f0100fdd <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010282c:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102833:	00 
f0102834:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010283b:	e8 ad ea ff ff       	call   f01012ed <mmio_map_region>
f0102840:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102842:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102849:	00 
f010284a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102851:	e8 97 ea ff ff       	call   f01012ed <mmio_map_region>
f0102856:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102858:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010285e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102864:	76 07                	jbe    f010286d <mem_init+0x150c>
f0102866:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010286b:	76 24                	jbe    f0102891 <mem_init+0x1530>
f010286d:	c7 44 24 0c c4 74 10 	movl   $0xf01074c4,0xc(%esp)
f0102874:	f0 
f0102875:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010287c:	f0 
f010287d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102884:	00 
f0102885:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010288c:	e8 af d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102891:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102897:	76 0e                	jbe    f01028a7 <mem_init+0x1546>
f0102899:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010289f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01028a5:	76 24                	jbe    f01028cb <mem_init+0x156a>
f01028a7:	c7 44 24 0c ec 74 10 	movl   $0xf01074ec,0xc(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01028b6:	f0 
f01028b7:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028be:	00 
f01028bf:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01028c6:	e8 75 d7 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028cb:	89 da                	mov    %ebx,%edx
f01028cd:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028cf:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01028d5:	74 24                	je     f01028fb <mem_init+0x159a>
f01028d7:	c7 44 24 0c 14 75 10 	movl   $0xf0107514,0xc(%esp)
f01028de:	f0 
f01028df:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01028e6:	f0 
f01028e7:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01028ee:	00 
f01028ef:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01028f6:	e8 45 d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01028fb:	39 c6                	cmp    %eax,%esi
f01028fd:	73 24                	jae    f0102923 <mem_init+0x15c2>
f01028ff:	c7 44 24 0c 17 7b 10 	movl   $0xf0107b17,0xc(%esp)
f0102906:	f0 
f0102907:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010290e:	f0 
f010290f:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102916:	00 
f0102917:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010291e:	e8 1d d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102923:	8b 3d 8c ce 22 f0    	mov    0xf022ce8c,%edi
f0102929:	89 da                	mov    %ebx,%edx
f010292b:	89 f8                	mov    %edi,%eax
f010292d:	e8 24 e1 ff ff       	call   f0100a56 <check_va2pa>
f0102932:	85 c0                	test   %eax,%eax
f0102934:	74 24                	je     f010295a <mem_init+0x15f9>
f0102936:	c7 44 24 0c 3c 75 10 	movl   $0xf010753c,0xc(%esp)
f010293d:	f0 
f010293e:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102945:	f0 
f0102946:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f010294d:	00 
f010294e:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102955:	e8 e6 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010295a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102960:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102963:	89 c2                	mov    %eax,%edx
f0102965:	89 f8                	mov    %edi,%eax
f0102967:	e8 ea e0 ff ff       	call   f0100a56 <check_va2pa>
f010296c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102971:	74 24                	je     f0102997 <mem_init+0x1636>
f0102973:	c7 44 24 0c 60 75 10 	movl   $0xf0107560,0xc(%esp)
f010297a:	f0 
f010297b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102982:	f0 
f0102983:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f010298a:	00 
f010298b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102992:	e8 a9 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102997:	89 f2                	mov    %esi,%edx
f0102999:	89 f8                	mov    %edi,%eax
f010299b:	e8 b6 e0 ff ff       	call   f0100a56 <check_va2pa>
f01029a0:	85 c0                	test   %eax,%eax
f01029a2:	74 24                	je     f01029c8 <mem_init+0x1667>
f01029a4:	c7 44 24 0c 90 75 10 	movl   $0xf0107590,0xc(%esp)
f01029ab:	f0 
f01029ac:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01029b3:	f0 
f01029b4:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01029bb:	00 
f01029bc:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01029c3:	e8 78 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01029c8:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01029ce:	89 f8                	mov    %edi,%eax
f01029d0:	e8 81 e0 ff ff       	call   f0100a56 <check_va2pa>
f01029d5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029d8:	74 24                	je     f01029fe <mem_init+0x169d>
f01029da:	c7 44 24 0c b4 75 10 	movl   $0xf01075b4,0xc(%esp)
f01029e1:	f0 
f01029e2:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01029e9:	f0 
f01029ea:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f01029f1:	00 
f01029f2:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01029f9:	e8 42 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01029fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a05:	00 
f0102a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a0a:	89 3c 24             	mov    %edi,(%esp)
f0102a0d:	e8 2e e6 ff ff       	call   f0101040 <pgdir_walk>
f0102a12:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a15:	75 24                	jne    f0102a3b <mem_init+0x16da>
f0102a17:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f0102a1e:	f0 
f0102a1f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102a26:	f0 
f0102a27:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a2e:	00 
f0102a2f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102a36:	e8 05 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a42:	00 
f0102a43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a47:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102a4c:	89 04 24             	mov    %eax,(%esp)
f0102a4f:	e8 ec e5 ff ff       	call   f0101040 <pgdir_walk>
f0102a54:	f6 00 04             	testb  $0x4,(%eax)
f0102a57:	74 24                	je     f0102a7d <mem_init+0x171c>
f0102a59:	c7 44 24 0c 24 76 10 	movl   $0xf0107624,0xc(%esp)
f0102a60:	f0 
f0102a61:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102a68:	f0 
f0102a69:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a70:	00 
f0102a71:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102a78:	e8 c3 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a84:	00 
f0102a85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a89:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102a8e:	89 04 24             	mov    %eax,(%esp)
f0102a91:	e8 aa e5 ff ff       	call   f0101040 <pgdir_walk>
f0102a96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102aa3:	00 
f0102aa4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102aa7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102aab:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102ab0:	89 04 24             	mov    %eax,(%esp)
f0102ab3:	e8 88 e5 ff ff       	call   f0101040 <pgdir_walk>
f0102ab8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102abe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ac5:	00 
f0102ac6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102aca:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102acf:	89 04 24             	mov    %eax,(%esp)
f0102ad2:	e8 69 e5 ff ff       	call   f0101040 <pgdir_walk>
f0102ad7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102add:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102ae4:	e8 95 14 00 00       	call   f0103f7e <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ae9:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102aef:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102af4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102af9:	77 20                	ja     f0102b1b <mem_init+0x17ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102aff:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102b06:	f0 
f0102b07:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102b0e:	00 
f0102b0f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102b16:	e8 25 d5 ff ff       	call   f0100040 <_panic>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b1b:	8d 1c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ebx
f0102b22:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b28:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b2f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b30:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b35:	89 04 24             	mov    %eax,(%esp)
f0102b38:	89 d9                	mov    %ebx,%ecx
f0102b3a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b3f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102b44:	e8 9e e5 ff ff       	call   f01010e7 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102b49:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b4f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102b55:	77 20                	ja     f0102b77 <mem_init+0x1816>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b57:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b5b:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102b62:	f0 
f0102b63:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102b6a:	00 
f0102b6b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102b72:	e8 c9 d4 ff ff       	call   f0100040 <_panic>
f0102b77:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102b7e:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b7f:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102b85:	89 04 24             	mov    %eax,(%esp)
f0102b88:	89 d9                	mov    %ebx,%ecx
f0102b8a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102b8f:	e8 53 e5 ff ff       	call   f01010e7 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102b94:	a1 48 c2 22 f0       	mov    0xf022c248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b99:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b9e:	77 20                	ja     f0102bc0 <mem_init+0x185f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ba0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ba4:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102bab:	f0 
f0102bac:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102bb3:	00 
f0102bb4:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102bbb:	e8 80 d4 ff ff       	call   f0100040 <_panic>
f0102bc0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bc7:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bc8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bcd:	89 04 24             	mov    %eax,(%esp)
f0102bd0:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102bd5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102bda:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102bdf:	e8 03 e5 ff ff       	call   f01010e7 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102be4:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bea:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102bf0:	77 20                	ja     f0102c12 <mem_init+0x18b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bf6:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102c05:	00 
f0102c06:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102c0d:	e8 2e d4 ff ff       	call   f0100040 <_panic>
f0102c12:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c19:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c1a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c20:	89 04 24             	mov    %eax,(%esp)
f0102c23:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c28:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102c2d:	e8 b5 e4 ff ff       	call   f01010e7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c32:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102c37:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c3c:	77 20                	ja     f0102c5e <mem_init+0x18fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c42:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102c49:	f0 
f0102c4a:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102c51:	00 
f0102c52:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102c59:	e8 e2 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102c5e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c65:	00 
f0102c66:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102c6d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c72:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102c77:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102c7c:	e8 66 e4 ff ff       	call   f01010e7 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102c81:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c88:	00 
f0102c89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c90:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102c95:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c9a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102c9f:	e8 43 e4 ff ff       	call   f01010e7 <boot_map_region>
f0102ca4:	c7 45 cc 00 e0 22 f0 	movl   $0xf022e000,-0x34(%ebp)
f0102cab:	bb 00 e0 22 f0       	mov    $0xf022e000,%ebx
f0102cb0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102cbb:	77 20                	ja     f0102cdd <mem_init+0x197c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cbd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cc1:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102cc8:	f0 
f0102cc9:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102cd0:	00 
f0102cd1:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102cd8:	e8 63 d3 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102cdd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ce4:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ce5:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102ceb:	89 04 24             	mov    %eax,(%esp)
f0102cee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cf3:	89 f2                	mov    %esi,%edx
f0102cf5:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102cfa:	e8 e8 e3 ff ff       	call   f01010e7 <boot_map_region>
f0102cff:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d05:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
f0102d0b:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d11:	75 a2                	jne    f0102cb5 <mem_init+0x1954>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d13:	8b 1d 8c ce 22 f0    	mov    0xf022ce8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d19:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f0102d1f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d22:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d29:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d2f:	be 00 00 00 00       	mov    $0x0,%esi
f0102d34:	eb 70                	jmp    f0102da6 <mem_init+0x1a45>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d36:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d3c:	89 d8                	mov    %ebx,%eax
f0102d3e:	e8 13 dd ff ff       	call   f0100a56 <check_va2pa>
f0102d43:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d49:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d4f:	77 20                	ja     f0102d71 <mem_init+0x1a10>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d51:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d55:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102d5c:	f0 
f0102d5d:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102d64:	00 
f0102d65:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102d6c:	e8 cf d2 ff ff       	call   f0100040 <_panic>
f0102d71:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d78:	39 d0                	cmp    %edx,%eax
f0102d7a:	74 24                	je     f0102da0 <mem_init+0x1a3f>
f0102d7c:	c7 44 24 0c 58 76 10 	movl   $0xf0107658,0xc(%esp)
f0102d83:	f0 
f0102d84:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102d8b:	f0 
f0102d8c:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102d93:	00 
f0102d94:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102d9b:	e8 a0 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102da0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102da6:	39 f7                	cmp    %esi,%edi
f0102da8:	77 8c                	ja     f0102d36 <mem_init+0x19d5>
f0102daa:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102daf:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102db5:	89 d8                	mov    %ebx,%eax
f0102db7:	e8 9a dc ff ff       	call   f0100a56 <check_va2pa>
f0102dbc:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102dc8:	77 20                	ja     f0102dea <mem_init+0x1a89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102dce:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102dd5:	f0 
f0102dd6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ddd:	00 
f0102dde:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102de5:	e8 56 d2 ff ff       	call   f0100040 <_panic>
f0102dea:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102df1:	39 d0                	cmp    %edx,%eax
f0102df3:	74 24                	je     f0102e19 <mem_init+0x1ab8>
f0102df5:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102e14:	e8 27 d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e19:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e1f:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e25:	75 88                	jne    f0102daf <mem_init+0x1a4e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e27:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e2a:	c1 e7 0c             	shl    $0xc,%edi
f0102e2d:	be 00 00 00 00       	mov    $0x0,%esi
f0102e32:	eb 3b                	jmp    f0102e6f <mem_init+0x1b0e>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e34:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e3a:	89 d8                	mov    %ebx,%eax
f0102e3c:	e8 15 dc ff ff       	call   f0100a56 <check_va2pa>
f0102e41:	39 c6                	cmp    %eax,%esi
f0102e43:	74 24                	je     f0102e69 <mem_init+0x1b08>
f0102e45:	c7 44 24 0c c0 76 10 	movl   $0xf01076c0,0xc(%esp)
f0102e4c:	f0 
f0102e4d:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102e54:	f0 
f0102e55:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102e5c:	00 
f0102e5d:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102e64:	e8 d7 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e69:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e6f:	39 fe                	cmp    %edi,%esi
f0102e71:	72 c1                	jb     f0102e34 <mem_init+0x1ad3>
f0102e73:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f0102e7a:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e7c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e82:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e85:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e8b:	89 c6                	mov    %eax,%esi
f0102e8d:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102e93:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102e96:	81 c2 00 00 01 00    	add    $0x10000,%edx
f0102e9c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e9f:	89 da                	mov    %ebx,%edx
f0102ea1:	89 f8                	mov    %edi,%eax
f0102ea3:	e8 ae db ff ff       	call   f0100a56 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ea8:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102eaf:	77 23                	ja     f0102ed4 <mem_init+0x1b73>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eb1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102eb4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102eb8:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102ebf:	f0 
f0102ec0:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102ec7:	00 
f0102ec8:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>
f0102ed4:	39 f0                	cmp    %esi,%eax
f0102ed6:	74 24                	je     f0102efc <mem_init+0x1b9b>
f0102ed8:	c7 44 24 0c e8 76 10 	movl   $0xf01076e8,0xc(%esp)
f0102edf:	f0 
f0102ee0:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102ee7:	f0 
f0102ee8:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102eef:	00 
f0102ef0:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102ef7:	e8 44 d1 ff ff       	call   f0100040 <_panic>
f0102efc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f02:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f08:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102f0b:	0f 85 58 05 00 00    	jne    f0103469 <mem_init+0x2108>
f0102f11:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f16:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f19:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f1c:	89 f8                	mov    %edi,%eax
f0102f1e:	e8 33 db ff ff       	call   f0100a56 <check_va2pa>
f0102f23:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f26:	74 24                	je     f0102f4c <mem_init+0x1beb>
f0102f28:	c7 44 24 0c 30 77 10 	movl   $0xf0107730,0xc(%esp)
f0102f2f:	f0 
f0102f30:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102f37:	f0 
f0102f38:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102f3f:	00 
f0102f40:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102f47:	e8 f4 d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f4c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f52:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f58:	75 bf                	jne    f0102f19 <mem_init+0x1bb8>
f0102f5a:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0102f61:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f68:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0102f6f:	0f 85 07 ff ff ff    	jne    f0102e7c <mem_init+0x1b1b>
f0102f75:	89 fb                	mov    %edi,%ebx
f0102f77:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f7c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f82:	83 fa 04             	cmp    $0x4,%edx
f0102f85:	77 2e                	ja     f0102fb5 <mem_init+0x1c54>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102f87:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f8b:	0f 85 aa 00 00 00    	jne    f010303b <mem_init+0x1cda>
f0102f91:	c7 44 24 0c 42 7b 10 	movl   $0xf0107b42,0xc(%esp)
f0102f98:	f0 
f0102f99:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102fa0:	f0 
f0102fa1:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102fa8:	00 
f0102fa9:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102fb0:	e8 8b d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102fb5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fba:	76 55                	jbe    f0103011 <mem_init+0x1cb0>
				assert(pgdir[i] & PTE_P);
f0102fbc:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102fbf:	f6 c2 01             	test   $0x1,%dl
f0102fc2:	75 24                	jne    f0102fe8 <mem_init+0x1c87>
f0102fc4:	c7 44 24 0c 42 7b 10 	movl   $0xf0107b42,0xc(%esp)
f0102fcb:	f0 
f0102fcc:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102fd3:	f0 
f0102fd4:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102fdb:	00 
f0102fdc:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0102fe3:	e8 58 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102fe8:	f6 c2 02             	test   $0x2,%dl
f0102feb:	75 4e                	jne    f010303b <mem_init+0x1cda>
f0102fed:	c7 44 24 0c 53 7b 10 	movl   $0xf0107b53,0xc(%esp)
f0102ff4:	f0 
f0102ff5:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0102ffc:	f0 
f0102ffd:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0103004:	00 
f0103005:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010300c:	e8 2f d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103011:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103015:	74 24                	je     f010303b <mem_init+0x1cda>
f0103017:	c7 44 24 0c 64 7b 10 	movl   $0xf0107b64,0xc(%esp)
f010301e:	f0 
f010301f:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103026:	f0 
f0103027:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010302e:	00 
f010302f:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103036:	e8 05 d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010303b:	83 c0 01             	add    $0x1,%eax
f010303e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103043:	0f 85 33 ff ff ff    	jne    f0102f7c <mem_init+0x1c1b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103049:	c7 04 24 54 77 10 f0 	movl   $0xf0107754,(%esp)
f0103050:	e8 29 0f 00 00       	call   f0103f7e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103055:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010305a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305f:	77 20                	ja     f0103081 <mem_init+0x1d20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103061:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103065:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f010306c:	f0 
f010306d:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103074:	00 
f0103075:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010307c:	e8 bf cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103081:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103086:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103089:	b8 00 00 00 00       	mov    $0x0,%eax
f010308e:	e8 66 da ff ff       	call   f0100af9 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103093:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103096:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010309b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010309e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030a8:	e8 ac de ff ff       	call   f0100f59 <page_alloc>
f01030ad:	89 c6                	mov    %eax,%esi
f01030af:	85 c0                	test   %eax,%eax
f01030b1:	75 24                	jne    f01030d7 <mem_init+0x1d76>
f01030b3:	c7 44 24 0c 4e 79 10 	movl   $0xf010794e,0xc(%esp)
f01030ba:	f0 
f01030bb:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01030c2:	f0 
f01030c3:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01030ca:	00 
f01030cb:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01030d2:	e8 69 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030de:	e8 76 de ff ff       	call   f0100f59 <page_alloc>
f01030e3:	89 c7                	mov    %eax,%edi
f01030e5:	85 c0                	test   %eax,%eax
f01030e7:	75 24                	jne    f010310d <mem_init+0x1dac>
f01030e9:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f01030f0:	f0 
f01030f1:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01030f8:	f0 
f01030f9:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103100:	00 
f0103101:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103108:	e8 33 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010310d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103114:	e8 40 de ff ff       	call   f0100f59 <page_alloc>
f0103119:	89 c3                	mov    %eax,%ebx
f010311b:	85 c0                	test   %eax,%eax
f010311d:	75 24                	jne    f0103143 <mem_init+0x1de2>
f010311f:	c7 44 24 0c 7a 79 10 	movl   $0xf010797a,0xc(%esp)
f0103126:	f0 
f0103127:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010312e:	f0 
f010312f:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0103136:	00 
f0103137:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010313e:	e8 fd ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103143:	89 34 24             	mov    %esi,(%esp)
f0103146:	e8 92 de ff ff       	call   f0100fdd <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010314b:	89 f8                	mov    %edi,%eax
f010314d:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103153:	c1 f8 03             	sar    $0x3,%eax
f0103156:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103159:	89 c2                	mov    %eax,%edx
f010315b:	c1 ea 0c             	shr    $0xc,%edx
f010315e:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103164:	72 20                	jb     f0103186 <mem_init+0x1e25>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103166:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010316a:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103171:	f0 
f0103172:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103179:	00 
f010317a:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0103181:	e8 ba ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103186:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010318d:	00 
f010318e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103195:	00 
	return (void *)(pa + KERNBASE);
f0103196:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010319b:	89 04 24             	mov    %eax,(%esp)
f010319e:	e8 f0 2a 00 00       	call   f0105c93 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031a3:	89 d8                	mov    %ebx,%eax
f01031a5:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f01031ab:	c1 f8 03             	sar    $0x3,%eax
f01031ae:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031b1:	89 c2                	mov    %eax,%edx
f01031b3:	c1 ea 0c             	shr    $0xc,%edx
f01031b6:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f01031bc:	72 20                	jb     f01031de <mem_init+0x1e7d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031c2:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01031c9:	f0 
f01031ca:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031d1:	00 
f01031d2:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f01031d9:	e8 62 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031e5:	00 
f01031e6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031ed:	00 
	return (void *)(pa + KERNBASE);
f01031ee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031f3:	89 04 24             	mov    %eax,(%esp)
f01031f6:	e8 98 2a 00 00       	call   f0105c93 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031fb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103202:	00 
f0103203:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010320a:	00 
f010320b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010320f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103214:	89 04 24             	mov    %eax,(%esp)
f0103217:	e8 33 e0 ff ff       	call   f010124f <page_insert>
	assert(pp1->pp_ref == 1);
f010321c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103221:	74 24                	je     f0103247 <mem_init+0x1ee6>
f0103223:	c7 44 24 0c 4b 7a 10 	movl   $0xf0107a4b,0xc(%esp)
f010322a:	f0 
f010322b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103232:	f0 
f0103233:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f010323a:	00 
f010323b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103242:	e8 f9 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103247:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010324e:	01 01 01 
f0103251:	74 24                	je     f0103277 <mem_init+0x1f16>
f0103253:	c7 44 24 0c 74 77 10 	movl   $0xf0107774,0xc(%esp)
f010325a:	f0 
f010325b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103262:	f0 
f0103263:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f010326a:	00 
f010326b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103272:	e8 c9 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103277:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010327e:	00 
f010327f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103286:	00 
f0103287:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010328b:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103290:	89 04 24             	mov    %eax,(%esp)
f0103293:	e8 b7 df ff ff       	call   f010124f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103298:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010329f:	02 02 02 
f01032a2:	74 24                	je     f01032c8 <mem_init+0x1f67>
f01032a4:	c7 44 24 0c 98 77 10 	movl   $0xf0107798,0xc(%esp)
f01032ab:	f0 
f01032ac:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01032b3:	f0 
f01032b4:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f01032bb:	00 
f01032bc:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01032c3:	e8 78 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032c8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032cd:	74 24                	je     f01032f3 <mem_init+0x1f92>
f01032cf:	c7 44 24 0c 6d 7a 10 	movl   $0xf0107a6d,0xc(%esp)
f01032d6:	f0 
f01032d7:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01032de:	f0 
f01032df:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f01032e6:	00 
f01032e7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01032ee:	e8 4d cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032f3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032f8:	74 24                	je     f010331e <mem_init+0x1fbd>
f01032fa:	c7 44 24 0c d7 7a 10 	movl   $0xf0107ad7,0xc(%esp)
f0103301:	f0 
f0103302:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103309:	f0 
f010330a:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103311:	00 
f0103312:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103319:	e8 22 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010331e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103325:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103328:	89 d8                	mov    %ebx,%eax
f010332a:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103330:	c1 f8 03             	sar    $0x3,%eax
f0103333:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103336:	89 c2                	mov    %eax,%edx
f0103338:	c1 ea 0c             	shr    $0xc,%edx
f010333b:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103341:	72 20                	jb     f0103363 <mem_init+0x2002>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103343:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103347:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f010334e:	f0 
f010334f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103356:	00 
f0103357:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f010335e:	e8 dd cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103363:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010336a:	03 03 03 
f010336d:	74 24                	je     f0103393 <mem_init+0x2032>
f010336f:	c7 44 24 0c bc 77 10 	movl   $0xf01077bc,0xc(%esp)
f0103376:	f0 
f0103377:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010337e:	f0 
f010337f:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103386:	00 
f0103387:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f010338e:	e8 ad cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103393:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010339a:	00 
f010339b:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01033a0:	89 04 24             	mov    %eax,(%esp)
f01033a3:	e8 47 de ff ff       	call   f01011ef <page_remove>
	assert(pp2->pp_ref == 0);
f01033a8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033ad:	74 24                	je     f01033d3 <mem_init+0x2072>
f01033af:	c7 44 24 0c a5 7a 10 	movl   $0xf0107aa5,0xc(%esp)
f01033b6:	f0 
f01033b7:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01033be:	f0 
f01033bf:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033c6:	00 
f01033c7:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f01033ce:	e8 6d cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033d3:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01033d8:	8b 08                	mov    (%eax),%ecx
f01033da:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033e0:	89 f2                	mov    %esi,%edx
f01033e2:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01033e8:	c1 fa 03             	sar    $0x3,%edx
f01033eb:	c1 e2 0c             	shl    $0xc,%edx
f01033ee:	39 d1                	cmp    %edx,%ecx
f01033f0:	74 24                	je     f0103416 <mem_init+0x20b5>
f01033f2:	c7 44 24 0c 44 71 10 	movl   $0xf0107144,0xc(%esp)
f01033f9:	f0 
f01033fa:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103401:	f0 
f0103402:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0103409:	00 
f010340a:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103411:	e8 2a cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103416:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010341c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103421:	74 24                	je     f0103447 <mem_init+0x20e6>
f0103423:	c7 44 24 0c 5c 7a 10 	movl   $0xf0107a5c,0xc(%esp)
f010342a:	f0 
f010342b:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f0103432:	f0 
f0103433:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f010343a:	00 
f010343b:	c7 04 24 49 78 10 f0 	movl   $0xf0107849,(%esp)
f0103442:	e8 f9 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103447:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010344d:	89 34 24             	mov    %esi,(%esp)
f0103450:	e8 88 db ff ff       	call   f0100fdd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103455:	c7 04 24 e8 77 10 f0 	movl   $0xf01077e8,(%esp)
f010345c:	e8 1d 0b 00 00       	call   f0103f7e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103461:	83 c4 3c             	add    $0x3c,%esp
f0103464:	5b                   	pop    %ebx
f0103465:	5e                   	pop    %esi
f0103466:	5f                   	pop    %edi
f0103467:	5d                   	pop    %ebp
f0103468:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103469:	89 da                	mov    %ebx,%edx
f010346b:	89 f8                	mov    %edi,%eax
f010346d:	e8 e4 d5 ff ff       	call   f0100a56 <check_va2pa>
f0103472:	e9 5d fa ff ff       	jmp    f0102ed4 <mem_init+0x1b73>

f0103477 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103477:	55                   	push   %ebp
f0103478:	89 e5                	mov    %esp,%ebp
f010347a:	57                   	push   %edi
f010347b:	56                   	push   %esi
f010347c:	53                   	push   %ebx
f010347d:	83 ec 2c             	sub    $0x2c,%esp
f0103480:	8b 75 08             	mov    0x8(%ebp),%esi
f0103483:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103489:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010348f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103492:	03 45 10             	add    0x10(%ebp),%eax
f0103495:	05 ff 0f 00 00       	add    $0xfff,%eax
f010349a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010349f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f01034a2:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034a8:	76 5d                	jbe    f0103507 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f01034aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034ad:	a3 44 c2 22 f0       	mov    %eax,0xf022c244
        return -E_FAULT;
f01034b2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b7:	eb 58                	jmp    f0103511 <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034c0:	00 
f01034c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034c5:	8b 46 60             	mov    0x60(%esi),%eax
f01034c8:	89 04 24             	mov    %eax,(%esp)
f01034cb:	e8 70 db ff ff       	call   f0101040 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034d0:	85 c0                	test   %eax,%eax
f01034d2:	74 0c                	je     f01034e0 <user_mem_check+0x69>
f01034d4:	8b 00                	mov    (%eax),%eax
f01034d6:	a8 01                	test   $0x1,%al
f01034d8:	74 06                	je     f01034e0 <user_mem_check+0x69>
f01034da:	21 f8                	and    %edi,%eax
f01034dc:	39 c7                	cmp    %eax,%edi
f01034de:	74 21                	je     f0103501 <user_mem_check+0x8a>
        {
            if (addr < va)
f01034e0:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034e3:	76 0f                	jbe    f01034f4 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034e8:	a3 44 c2 22 f0       	mov    %eax,0xf022c244
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034ed:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034f2:	eb 1d                	jmp    f0103511 <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f01034f4:	89 1d 44 c2 22 f0    	mov    %ebx,0xf022c244
            }
            
            return -E_FAULT;
f01034fa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034ff:	eb 10                	jmp    f0103511 <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f0103501:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103507:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010350a:	72 ad                	jb     f01034b9 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f010350c:	b8 00 00 00 00       	mov    $0x0,%eax

}
f0103511:	83 c4 2c             	add    $0x2c,%esp
f0103514:	5b                   	pop    %ebx
f0103515:	5e                   	pop    %esi
f0103516:	5f                   	pop    %edi
f0103517:	5d                   	pop    %ebp
f0103518:	c3                   	ret    

f0103519 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103519:	55                   	push   %ebp
f010351a:	89 e5                	mov    %esp,%ebp
f010351c:	53                   	push   %ebx
f010351d:	83 ec 14             	sub    $0x14,%esp
f0103520:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103523:	8b 45 14             	mov    0x14(%ebp),%eax
f0103526:	83 c8 04             	or     $0x4,%eax
f0103529:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010352d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103530:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103534:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103537:	89 44 24 04          	mov    %eax,0x4(%esp)
f010353b:	89 1c 24             	mov    %ebx,(%esp)
f010353e:	e8 34 ff ff ff       	call   f0103477 <user_mem_check>
f0103543:	85 c0                	test   %eax,%eax
f0103545:	79 24                	jns    f010356b <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103547:	a1 44 c2 22 f0       	mov    0xf022c244,%eax
f010354c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103550:	8b 43 48             	mov    0x48(%ebx),%eax
f0103553:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103557:	c7 04 24 14 78 10 f0 	movl   $0xf0107814,(%esp)
f010355e:	e8 1b 0a 00 00       	call   f0103f7e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103563:	89 1c 24             	mov    %ebx,(%esp)
f0103566:	e8 18 07 00 00       	call   f0103c83 <env_destroy>
	}
}
f010356b:	83 c4 14             	add    $0x14,%esp
f010356e:	5b                   	pop    %ebx
f010356f:	5d                   	pop    %ebp
f0103570:	c3                   	ret    
f0103571:	00 00                	add    %al,(%eax)
	...

f0103574 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103574:	55                   	push   %ebp
f0103575:	89 e5                	mov    %esp,%ebp
f0103577:	57                   	push   %edi
f0103578:	56                   	push   %esi
f0103579:	53                   	push   %ebx
f010357a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f010357d:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f0103580:	89 d3                	mov    %edx,%ebx
f0103582:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103589:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010358e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103594:	29 d0                	sub    %edx,%eax
f0103596:	c1 e8 0c             	shr    $0xc,%eax
f0103599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f010359c:	be 00 00 00 00       	mov    $0x0,%esi
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035a1:	eb 6d                	jmp    f0103610 <region_alloc+0x9c>
		struct PageInfo* newPage = page_alloc(0);
f01035a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035aa:	e8 aa d9 ff ff       	call   f0100f59 <page_alloc>
		if(newPage == 0)
f01035af:	85 c0                	test   %eax,%eax
f01035b1:	75 1c                	jne    f01035cf <region_alloc+0x5b>
			panic("there is no more page to region_alloc for env\n");
f01035b3:	c7 44 24 08 74 7b 10 	movl   $0xf0107b74,0x8(%esp)
f01035ba:	f0 
f01035bb:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01035c2:	00 
f01035c3:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f01035ca:	e8 71 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035cf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035d6:	00 
f01035d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035df:	89 3c 24             	mov    %edi,(%esp)
f01035e2:	e8 68 dc ff ff       	call   f010124f <page_insert>
f01035e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if(ret)
f01035ed:	85 c0                	test   %eax,%eax
f01035ef:	74 1c                	je     f010360d <region_alloc+0x99>
			panic("page_insert fail\n");
f01035f1:	c7 44 24 08 ae 7b 10 	movl   $0xf0107bae,0x8(%esp)
f01035f8:	f0 
f01035f9:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0103600:	00 
f0103601:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103608:	e8 33 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010360d:	83 c6 01             	add    $0x1,%esi
f0103610:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103613:	7c 8e                	jl     f01035a3 <region_alloc+0x2f>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103615:	83 c4 2c             	add    $0x2c,%esp
f0103618:	5b                   	pop    %ebx
f0103619:	5e                   	pop    %esi
f010361a:	5f                   	pop    %edi
f010361b:	5d                   	pop    %ebp
f010361c:	c3                   	ret    

f010361d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010361d:	55                   	push   %ebp
f010361e:	89 e5                	mov    %esp,%ebp
f0103620:	83 ec 18             	sub    $0x18,%esp
f0103623:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103626:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103629:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010362c:	8b 45 08             	mov    0x8(%ebp),%eax
f010362f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103632:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103636:	85 c0                	test   %eax,%eax
f0103638:	75 17                	jne    f0103651 <envid2env+0x34>
		*env_store = curenv;
f010363a:	e8 b5 2c 00 00       	call   f01062f4 <cpunum>
f010363f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103642:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103648:	89 06                	mov    %eax,(%esi)
		return 0;
f010364a:	b8 00 00 00 00       	mov    $0x0,%eax
f010364f:	eb 67                	jmp    f01036b8 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103651:	89 c3                	mov    %eax,%ebx
f0103653:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103659:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010365c:	03 1d 48 c2 22 f0    	add    0xf022c248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103662:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103666:	74 05                	je     f010366d <envid2env+0x50>
f0103668:	39 43 48             	cmp    %eax,0x48(%ebx)
f010366b:	74 0d                	je     f010367a <envid2env+0x5d>
		*env_store = 0;
f010366d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103673:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103678:	eb 3e                	jmp    f01036b8 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010367a:	84 d2                	test   %dl,%dl
f010367c:	74 33                	je     f01036b1 <envid2env+0x94>
f010367e:	e8 71 2c 00 00       	call   f01062f4 <cpunum>
f0103683:	6b c0 74             	imul   $0x74,%eax,%eax
f0103686:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f010368c:	74 23                	je     f01036b1 <envid2env+0x94>
f010368e:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103691:	e8 5e 2c 00 00       	call   f01062f4 <cpunum>
f0103696:	6b c0 74             	imul   $0x74,%eax,%eax
f0103699:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010369f:	3b 78 48             	cmp    0x48(%eax),%edi
f01036a2:	74 0d                	je     f01036b1 <envid2env+0x94>
		*env_store = 0;
f01036a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036aa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036af:	eb 07                	jmp    f01036b8 <envid2env+0x9b>
	}

	*env_store = e;
f01036b1:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01036bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01036be:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01036c1:	89 ec                	mov    %ebp,%esp
f01036c3:	5d                   	pop    %ebp
f01036c4:	c3                   	ret    

f01036c5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036c5:	55                   	push   %ebp
f01036c6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036c8:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036cd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036d0:	b8 23 00 00 00       	mov    $0x23,%eax
f01036d5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036d7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036d9:	b0 10                	mov    $0x10,%al
f01036db:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036dd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036df:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036e1:	ea e8 36 10 f0 08 00 	ljmp   $0x8,$0xf01036e8
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036e8:	b0 00                	mov    $0x0,%al
f01036ea:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036ed:	5d                   	pop    %ebp
f01036ee:	c3                   	ret    

f01036ef <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036ef:	55                   	push   %ebp
f01036f0:	89 e5                	mov    %esp,%ebp
f01036f2:	56                   	push   %esi
f01036f3:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036f4:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01036fa:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103700:	b9 00 00 00 00       	mov    $0x0,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f0103705:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010370a:	eb 02                	jmp    f010370e <env_init+0x1f>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f010370c:	89 d9                	mov    %ebx,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f010370e:	89 c3                	mov    %eax,%ebx
f0103710:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103717:	89 48 44             	mov    %ecx,0x44(%eax)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f010371a:	83 ea 01             	sub    $0x1,%edx
f010371d:	83 e8 7c             	sub    $0x7c,%eax
f0103720:	83 fa ff             	cmp    $0xffffffff,%edx
f0103723:	75 e7                	jne    f010370c <env_init+0x1d>
f0103725:	89 35 4c c2 22 f0    	mov    %esi,0xf022c24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010372b:	e8 95 ff ff ff       	call   f01036c5 <env_init_percpu>
}
f0103730:	5b                   	pop    %ebx
f0103731:	5e                   	pop    %esi
f0103732:	5d                   	pop    %ebp
f0103733:	c3                   	ret    

f0103734 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103734:	55                   	push   %ebp
f0103735:	89 e5                	mov    %esp,%ebp
f0103737:	53                   	push   %ebx
f0103738:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010373b:	8b 1d 4c c2 22 f0    	mov    0xf022c24c,%ebx
f0103741:	85 db                	test   %ebx,%ebx
f0103743:	0f 84 a7 01 00 00    	je     f01038f0 <env_alloc+0x1bc>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103749:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103750:	e8 04 d8 ff ff       	call   f0100f59 <page_alloc>
f0103755:	85 c0                	test   %eax,%eax
f0103757:	0f 84 9a 01 00 00    	je     f01038f7 <env_alloc+0x1c3>
f010375d:	89 c2                	mov    %eax,%edx
f010375f:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0103765:	c1 fa 03             	sar    $0x3,%edx
f0103768:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010376b:	89 d1                	mov    %edx,%ecx
f010376d:	c1 e9 0c             	shr    $0xc,%ecx
f0103770:	3b 0d 88 ce 22 f0    	cmp    0xf022ce88,%ecx
f0103776:	72 20                	jb     f0103798 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103778:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010377c:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103783:	f0 
f0103784:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010378b:	00 
f010378c:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0103793:	e8 a8 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103798:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010379e:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f01037a1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037a6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037ad:	00 
f01037ae:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01037b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037b7:	8b 43 60             	mov    0x60(%ebx),%eax
f01037ba:	89 04 24             	mov    %eax,(%esp)
f01037bd:	e8 a5 25 00 00       	call   f0105d67 <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037c2:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037c9:	00 
f01037ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037d1:	00 
f01037d2:	8b 43 60             	mov    0x60(%ebx),%eax
f01037d5:	89 04 24             	mov    %eax,(%esp)
f01037d8:	e8 b6 24 00 00       	call   f0105c93 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037dd:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037e5:	77 20                	ja     f0103807 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037eb:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f01037f2:	f0 
f01037f3:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01037fa:	00 
f01037fb:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103802:	e8 39 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103807:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010380d:	83 ca 05             	or     $0x5,%edx
f0103810:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103816:	8b 43 48             	mov    0x48(%ebx),%eax
f0103819:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010381e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103823:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103828:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010382b:	89 da                	mov    %ebx,%edx
f010382d:	2b 15 48 c2 22 f0    	sub    0xf022c248,%edx
f0103833:	c1 fa 02             	sar    $0x2,%edx
f0103836:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010383c:	09 d0                	or     %edx,%eax
f010383e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103841:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103844:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103847:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010384e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103855:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010385c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103863:	00 
f0103864:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010386b:	00 
f010386c:	89 1c 24             	mov    %ebx,(%esp)
f010386f:	e8 1f 24 00 00       	call   f0105c93 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103874:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010387a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103880:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103886:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010388d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103893:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010389a:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010389e:	8b 43 44             	mov    0x44(%ebx),%eax
f01038a1:	a3 4c c2 22 f0       	mov    %eax,0xf022c24c
	*newenv_store = e;
f01038a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01038a9:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038ab:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038ae:	e8 41 2a 00 00       	call   f01062f4 <cpunum>
f01038b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01038bb:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01038c2:	74 11                	je     f01038d5 <env_alloc+0x1a1>
f01038c4:	e8 2b 2a 00 00       	call   f01062f4 <cpunum>
f01038c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038cc:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01038d2:	8b 50 48             	mov    0x48(%eax),%edx
f01038d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038d9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038dd:	c7 04 24 c0 7b 10 f0 	movl   $0xf0107bc0,(%esp)
f01038e4:	e8 95 06 00 00       	call   f0103f7e <cprintf>
	return 0;
f01038e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01038ee:	eb 0c                	jmp    f01038fc <env_alloc+0x1c8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038f0:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038f5:	eb 05                	jmp    f01038fc <env_alloc+0x1c8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038fc:	83 c4 14             	add    $0x14,%esp
f01038ff:	5b                   	pop    %ebx
f0103900:	5d                   	pop    %ebp
f0103901:	c3                   	ret    

f0103902 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103902:	55                   	push   %ebp
f0103903:	89 e5                	mov    %esp,%ebp
f0103905:	57                   	push   %edi
f0103906:	56                   	push   %esi
f0103907:	53                   	push   %ebx
f0103908:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f010390b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103912:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103919:	00 
f010391a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010391d:	89 04 24             	mov    %eax,(%esp)
f0103920:	e8 0f fe ff ff       	call   f0103734 <env_alloc>
	if(r < 0)
f0103925:	85 c0                	test   %eax,%eax
f0103927:	79 1c                	jns    f0103945 <env_create+0x43>
		panic("env_create fault\n");
f0103929:	c7 44 24 08 d5 7b 10 	movl   $0xf0107bd5,0x8(%esp)
f0103930:	f0 
f0103931:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0103938:	00 
f0103939:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103940:	e8 fb c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103945:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103948:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010394b:	8b 55 08             	mov    0x8(%ebp),%edx
f010394e:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103954:	74 1c                	je     f0103972 <env_create+0x70>
			panic("e_magic is not right\n");
f0103956:	c7 44 24 08 e7 7b 10 	movl   $0xf0107be7,0x8(%esp)
f010395d:	f0 
f010395e:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103965:	00 
f0103966:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f010396d:	e8 ce c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103972:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103975:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103978:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010397d:	77 20                	ja     f010399f <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010397f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103983:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f010398a:	f0 
f010398b:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103992:	00 
f0103993:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f010399a:	e8 a1 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010399f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039a4:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f01039a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039aa:	03 5b 1c             	add    0x1c(%ebx),%ebx
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
f01039ad:	83 c3 20             	add    $0x20,%ebx
f01039b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039b3:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039b7:	83 c7 01             	add    $0x1,%edi
f01039ba:	be 01 00 00 00       	mov    $0x1,%esi
f01039bf:	eb 54                	jmp    f0103a15 <env_create+0x113>
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
			ph++;
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039c1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039c4:	75 49                	jne    f0103a0f <env_create+0x10d>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039c6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039c9:	8b 53 08             	mov    0x8(%ebx),%edx
f01039cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039cf:	e8 a0 fb ff ff       	call   f0103574 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039d4:	8b 43 10             	mov    0x10(%ebx),%eax
f01039d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039db:	8b 45 08             	mov    0x8(%ebp),%eax
f01039de:	03 43 04             	add    0x4(%ebx),%eax
f01039e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039e5:	8b 43 08             	mov    0x8(%ebx),%eax
f01039e8:	89 04 24             	mov    %eax,(%esp)
f01039eb:	e8 fe 22 00 00       	call   f0105cee <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01039f0:	8b 43 10             	mov    0x10(%ebx),%eax
f01039f3:	8b 53 14             	mov    0x14(%ebx),%edx
f01039f6:	29 c2                	sub    %eax,%edx
f01039f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a03:	00 
f0103a04:	03 43 08             	add    0x8(%ebx),%eax
f0103a07:	89 04 24             	mov    %eax,(%esp)
f0103a0a:	e8 84 22 00 00       	call   f0105c93 <memset>
f0103a0f:	83 c6 01             	add    $0x1,%esi
f0103a12:	83 c3 20             	add    $0x20,%ebx

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a15:	39 fe                	cmp    %edi,%esi
f0103a17:	75 a8                	jne    f01039c1 <env_create+0xbf>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a19:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a1c:	8b 42 18             	mov    0x18(%edx),%eax
f0103a1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a22:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a25:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a2a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a32:	e8 3d fb ff ff       	call   f0103574 <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a37:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a41:	77 20                	ja     f0103a63 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a47:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103a4e:	f0 
f0103a4f:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103a56:	00 
f0103a57:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103a5e:	e8 dd c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a63:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a68:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a71:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a74:	83 c4 3c             	add    $0x3c,%esp
f0103a77:	5b                   	pop    %ebx
f0103a78:	5e                   	pop    %esi
f0103a79:	5f                   	pop    %edi
f0103a7a:	5d                   	pop    %ebp
f0103a7b:	c3                   	ret    

f0103a7c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a7c:	55                   	push   %ebp
f0103a7d:	89 e5                	mov    %esp,%ebp
f0103a7f:	57                   	push   %edi
f0103a80:	56                   	push   %esi
f0103a81:	53                   	push   %ebx
f0103a82:	83 ec 2c             	sub    $0x2c,%esp
f0103a85:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a88:	e8 67 28 00 00       	call   f01062f4 <cpunum>
f0103a8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a90:	39 b8 28 d0 22 f0    	cmp    %edi,-0xfdd2fd8(%eax)
f0103a96:	75 34                	jne    f0103acc <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a98:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a9d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aa2:	77 20                	ja     f0103ac4 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aa8:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103aaf:	f0 
f0103ab0:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103ab7:	00 
f0103ab8:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103abf:	e8 7c c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ac4:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ac9:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103acc:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103acf:	e8 20 28 00 00       	call   f01062f4 <cpunum>
f0103ad4:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ad7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103adc:	83 ba 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%edx)
f0103ae3:	74 11                	je     f0103af6 <env_free+0x7a>
f0103ae5:	e8 0a 28 00 00       	call   f01062f4 <cpunum>
f0103aea:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aed:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103af3:	8b 40 48             	mov    0x48(%eax),%eax
f0103af6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103afa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103afe:	c7 04 24 fd 7b 10 f0 	movl   $0xf0107bfd,(%esp)
f0103b05:	e8 74 04 00 00       	call   f0103f7e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b0a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b14:	c1 e0 02             	shl    $0x2,%eax
f0103b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b1a:	8b 47 60             	mov    0x60(%edi),%eax
f0103b1d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b20:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103b23:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b29:	0f 84 b8 00 00 00    	je     f0103be7 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b2f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b35:	89 f0                	mov    %esi,%eax
f0103b37:	c1 e8 0c             	shr    $0xc,%eax
f0103b3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b3d:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103b43:	72 20                	jb     f0103b65 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b45:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b49:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103b50:	f0 
f0103b51:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103b58:	00 
f0103b59:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103b60:	e8 db c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b65:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b68:	c1 e2 16             	shl    $0x16,%edx
f0103b6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b6e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b73:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b7a:	01 
f0103b7b:	74 17                	je     f0103b94 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b7d:	89 d8                	mov    %ebx,%eax
f0103b7f:	c1 e0 0c             	shl    $0xc,%eax
f0103b82:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b89:	8b 47 60             	mov    0x60(%edi),%eax
f0103b8c:	89 04 24             	mov    %eax,(%esp)
f0103b8f:	e8 5b d6 ff ff       	call   f01011ef <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b94:	83 c3 01             	add    $0x1,%ebx
f0103b97:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b9d:	75 d4                	jne    f0103b73 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b9f:	8b 47 60             	mov    0x60(%edi),%eax
f0103ba2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ba5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bac:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103baf:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103bb5:	72 1c                	jb     f0103bd3 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0103bb7:	c7 44 24 08 f0 6f 10 	movl   $0xf0106ff0,0x8(%esp)
f0103bbe:	f0 
f0103bbf:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bc6:	00 
f0103bc7:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0103bce:	e8 6d c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bd6:	c1 e0 03             	shl    $0x3,%eax
f0103bd9:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
		page_decref(pa2page(pa));
f0103bdf:	89 04 24             	mov    %eax,(%esp)
f0103be2:	e8 36 d4 ff ff       	call   f010101d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103be7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103beb:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bf2:	0f 85 19 ff ff ff    	jne    f0103b11 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bf8:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bfb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c00:	77 20                	ja     f0103c22 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c06:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103c0d:	f0 
f0103c0e:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103c15:	00 
f0103c16:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103c1d:	e8 1e c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c22:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c29:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c2e:	c1 e8 0c             	shr    $0xc,%eax
f0103c31:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103c37:	72 1c                	jb     f0103c55 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f0103c39:	c7 44 24 08 f0 6f 10 	movl   $0xf0106ff0,0x8(%esp)
f0103c40:	f0 
f0103c41:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c48:	00 
f0103c49:	c7 04 24 55 78 10 f0 	movl   $0xf0107855,(%esp)
f0103c50:	e8 eb c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c55:	c1 e0 03             	shl    $0x3,%eax
f0103c58:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
	page_decref(pa2page(pa));
f0103c5e:	89 04 24             	mov    %eax,(%esp)
f0103c61:	e8 b7 d3 ff ff       	call   f010101d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c66:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c6d:	a1 4c c2 22 f0       	mov    0xf022c24c,%eax
f0103c72:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c75:	89 3d 4c c2 22 f0    	mov    %edi,0xf022c24c
}
f0103c7b:	83 c4 2c             	add    $0x2c,%esp
f0103c7e:	5b                   	pop    %ebx
f0103c7f:	5e                   	pop    %esi
f0103c80:	5f                   	pop    %edi
f0103c81:	5d                   	pop    %ebp
f0103c82:	c3                   	ret    

f0103c83 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c83:	55                   	push   %ebp
f0103c84:	89 e5                	mov    %esp,%ebp
f0103c86:	53                   	push   %ebx
f0103c87:	83 ec 14             	sub    $0x14,%esp
f0103c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c8d:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c91:	75 19                	jne    f0103cac <env_destroy+0x29>
f0103c93:	e8 5c 26 00 00       	call   f01062f4 <cpunum>
f0103c98:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c9b:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103ca1:	74 09                	je     f0103cac <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103ca3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103caa:	eb 2f                	jmp    f0103cdb <env_destroy+0x58>
	}

	env_free(e);
f0103cac:	89 1c 24             	mov    %ebx,(%esp)
f0103caf:	e8 c8 fd ff ff       	call   f0103a7c <env_free>

	if (curenv == e) {
f0103cb4:	e8 3b 26 00 00       	call   f01062f4 <cpunum>
f0103cb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbc:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103cc2:	75 17                	jne    f0103cdb <env_destroy+0x58>
		curenv = NULL;
f0103cc4:	e8 2b 26 00 00       	call   f01062f4 <cpunum>
f0103cc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccc:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0103cd3:	00 00 00 
		sched_yield();
f0103cd6:	e8 f9 0e 00 00       	call   f0104bd4 <sched_yield>
	}
}
f0103cdb:	83 c4 14             	add    $0x14,%esp
f0103cde:	5b                   	pop    %ebx
f0103cdf:	5d                   	pop    %ebp
f0103ce0:	c3                   	ret    

f0103ce1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ce1:	55                   	push   %ebp
f0103ce2:	89 e5                	mov    %esp,%ebp
f0103ce4:	53                   	push   %ebx
f0103ce5:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ce8:	e8 07 26 00 00       	call   f01062f4 <cpunum>
f0103ced:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf0:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f0103cf6:	e8 f9 25 00 00       	call   f01062f4 <cpunum>
f0103cfb:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103cfe:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d01:	61                   	popa   
f0103d02:	07                   	pop    %es
f0103d03:	1f                   	pop    %ds
f0103d04:	83 c4 08             	add    $0x8,%esp
f0103d07:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d08:	c7 44 24 08 13 7c 10 	movl   $0xf0107c13,0x8(%esp)
f0103d0f:	f0 
f0103d10:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0103d17:	00 
f0103d18:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103d1f:	e8 1c c3 ff ff       	call   f0100040 <_panic>

f0103d24 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d24:	55                   	push   %ebp
f0103d25:	89 e5                	mov    %esp,%ebp
f0103d27:	53                   	push   %ebx
f0103d28:	83 ec 14             	sub    $0x14,%esp
f0103d2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d2e:	e8 c1 25 00 00       	call   f01062f4 <cpunum>
f0103d33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d36:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0103d3d:	75 10                	jne    f0103d4f <env_run+0x2b>
		curenv = e;
f0103d3f:	e8 b0 25 00 00       	call   f01062f4 <cpunum>
f0103d44:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d47:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
f0103d4d:	eb 29                	jmp    f0103d78 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d4f:	e8 a0 25 00 00       	call   f01062f4 <cpunum>
f0103d54:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d57:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103d5d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d61:	75 15                	jne    f0103d78 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d63:	e8 8c 25 00 00       	call   f01062f4 <cpunum>
f0103d68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6b:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103d71:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d78:	e8 77 25 00 00       	call   f01062f4 <cpunum>
f0103d7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d80:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d86:	e8 69 25 00 00       	call   f01062f4 <cpunum>
f0103d8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d8e:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103d94:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d9b:	e8 54 25 00 00       	call   f01062f4 <cpunum>
f0103da0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103da9:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103dad:	e8 42 25 00 00       	call   f01062f4 <cpunum>
f0103db2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103dbb:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dbe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dc3:	77 20                	ja     f0103de5 <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dc9:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103dd0:	f0 
f0103dd1:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0103dd8:	00 
f0103dd9:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0103de0:	e8 5b c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103de5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dea:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ded:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103df4:	e8 47 28 00 00       	call   f0106640 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103df9:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103dfb:	e8 f4 24 00 00       	call   f01062f4 <cpunum>
f0103e00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e03:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103e09:	89 04 24             	mov    %eax,(%esp)
f0103e0c:	e8 d0 fe ff ff       	call   f0103ce1 <env_pop_tf>
f0103e11:	00 00                	add    %al,(%eax)
	...

f0103e14 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e14:	55                   	push   %ebp
f0103e15:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e17:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e20:	b2 71                	mov    $0x71,%dl
f0103e22:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e23:	0f b6 c0             	movzbl %al,%eax
}
f0103e26:	5d                   	pop    %ebp
f0103e27:	c3                   	ret    

f0103e28 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e28:	55                   	push   %ebp
f0103e29:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e2b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e33:	ee                   	out    %al,(%dx)
f0103e34:	b2 71                	mov    $0x71,%dl
f0103e36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e39:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e3a:	5d                   	pop    %ebp
f0103e3b:	c3                   	ret    

f0103e3c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e3c:	55                   	push   %ebp
f0103e3d:	89 e5                	mov    %esp,%ebp
f0103e3f:	56                   	push   %esi
f0103e40:	53                   	push   %ebx
f0103e41:	83 ec 10             	sub    $0x10,%esp
f0103e44:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e47:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e49:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e4f:	80 3d 50 c2 22 f0 00 	cmpb   $0x0,0xf022c250
f0103e56:	74 4e                	je     f0103ea6 <irq_setmask_8259A+0x6a>
f0103e58:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e5d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e5e:	89 f0                	mov    %esi,%eax
f0103e60:	66 c1 e8 08          	shr    $0x8,%ax
f0103e64:	b2 a1                	mov    $0xa1,%dl
f0103e66:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e67:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103e6e:	e8 0b 01 00 00       	call   f0103f7e <cprintf>
	for (i = 0; i < 16; i++)
f0103e73:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e78:	0f b7 f6             	movzwl %si,%esi
f0103e7b:	f7 d6                	not    %esi
f0103e7d:	0f a3 de             	bt     %ebx,%esi
f0103e80:	73 10                	jae    f0103e92 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103e82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e86:	c7 04 24 33 81 10 f0 	movl   $0xf0108133,(%esp)
f0103e8d:	e8 ec 00 00 00       	call   f0103f7e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e92:	83 c3 01             	add    $0x1,%ebx
f0103e95:	83 fb 10             	cmp    $0x10,%ebx
f0103e98:	75 e3                	jne    f0103e7d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e9a:	c7 04 24 40 7b 10 f0 	movl   $0xf0107b40,(%esp)
f0103ea1:	e8 d8 00 00 00       	call   f0103f7e <cprintf>
}
f0103ea6:	83 c4 10             	add    $0x10,%esp
f0103ea9:	5b                   	pop    %ebx
f0103eaa:	5e                   	pop    %esi
f0103eab:	5d                   	pop    %ebp
f0103eac:	c3                   	ret    

f0103ead <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ead:	55                   	push   %ebp
f0103eae:	89 e5                	mov    %esp,%ebp
f0103eb0:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103eb3:	c6 05 50 c2 22 f0 01 	movb   $0x1,0xf022c250
f0103eba:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ebf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ec4:	ee                   	out    %al,(%dx)
f0103ec5:	b2 a1                	mov    $0xa1,%dl
f0103ec7:	ee                   	out    %al,(%dx)
f0103ec8:	b2 20                	mov    $0x20,%dl
f0103eca:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ecf:	ee                   	out    %al,(%dx)
f0103ed0:	b2 21                	mov    $0x21,%dl
f0103ed2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ed7:	ee                   	out    %al,(%dx)
f0103ed8:	b8 04 00 00 00       	mov    $0x4,%eax
f0103edd:	ee                   	out    %al,(%dx)
f0103ede:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ee3:	ee                   	out    %al,(%dx)
f0103ee4:	b2 a0                	mov    $0xa0,%dl
f0103ee6:	b8 11 00 00 00       	mov    $0x11,%eax
f0103eeb:	ee                   	out    %al,(%dx)
f0103eec:	b2 a1                	mov    $0xa1,%dl
f0103eee:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ef3:	ee                   	out    %al,(%dx)
f0103ef4:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ef9:	ee                   	out    %al,(%dx)
f0103efa:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eff:	ee                   	out    %al,(%dx)
f0103f00:	b2 20                	mov    $0x20,%dl
f0103f02:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f07:	ee                   	out    %al,(%dx)
f0103f08:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b2 a0                	mov    $0xa0,%dl
f0103f10:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f15:	ee                   	out    %al,(%dx)
f0103f16:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f1b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f1c:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f23:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f27:	74 0b                	je     f0103f34 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0103f29:	0f b7 c0             	movzwl %ax,%eax
f0103f2c:	89 04 24             	mov    %eax,(%esp)
f0103f2f:	e8 08 ff ff ff       	call   f0103e3c <irq_setmask_8259A>
}
f0103f34:	c9                   	leave  
f0103f35:	c3                   	ret    
	...

f0103f38 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f38:	55                   	push   %ebp
f0103f39:	89 e5                	mov    %esp,%ebp
f0103f3b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f41:	89 04 24             	mov    %eax,(%esp)
f0103f44:	e8 31 c8 ff ff       	call   f010077a <cputchar>
	*cnt++;
}
f0103f49:	c9                   	leave  
f0103f4a:	c3                   	ret    

f0103f4b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f4b:	55                   	push   %ebp
f0103f4c:	89 e5                	mov    %esp,%ebp
f0103f4e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f62:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f66:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f6d:	c7 04 24 38 3f 10 f0 	movl   $0xf0103f38,(%esp)
f0103f74:	e8 64 16 00 00       	call   f01055dd <vprintfmt>
	return cnt;
}
f0103f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f7c:	c9                   	leave  
f0103f7d:	c3                   	ret    

f0103f7e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f7e:	55                   	push   %ebp
f0103f7f:	89 e5                	mov    %esp,%ebp
f0103f81:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f84:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f8e:	89 04 24             	mov    %eax,(%esp)
f0103f91:	e8 b5 ff ff ff       	call   f0103f4b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f96:	c9                   	leave  
f0103f97:	c3                   	ret    
	...

f0103fa0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fa0:	55                   	push   %ebp
f0103fa1:	89 e5                	mov    %esp,%ebp
f0103fa3:	57                   	push   %edi
f0103fa4:	56                   	push   %esi
f0103fa5:	53                   	push   %ebx
f0103fa6:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103fa9:	e8 46 23 00 00       	call   f01062f4 <cpunum>
f0103fae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb1:	0f b6 98 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103fb8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fbc:	c7 04 24 33 7c 10 f0 	movl   $0xf0107c33,(%esp)
f0103fc3:	e8 b6 ff ff ff       	call   f0103f7e <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fc8:	e8 27 23 00 00       	call   f01062f4 <cpunum>
f0103fcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd0:	89 da                	mov    %ebx,%edx
f0103fd2:	f7 da                	neg    %edx
f0103fd4:	c1 e2 10             	shl    $0x10,%edx
f0103fd7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fdd:	89 90 30 d0 22 f0    	mov    %edx,-0xfdd2fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fe3:	e8 0c 23 00 00       	call   f01062f4 <cpunum>
f0103fe8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103feb:	66 c7 80 34 d0 22 f0 	movw   $0x10,-0xfdd2fcc(%eax)
f0103ff2:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0103ff4:	83 c3 05             	add    $0x5,%ebx
f0103ff7:	e8 f8 22 00 00       	call   f01062f4 <cpunum>
f0103ffc:	89 c6                	mov    %eax,%esi
f0103ffe:	e8 f1 22 00 00       	call   f01062f4 <cpunum>
f0104003:	89 c7                	mov    %eax,%edi
f0104005:	e8 ea 22 00 00       	call   f01062f4 <cpunum>
f010400a:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0104011:	f0 67 00 
f0104014:	6b f6 74             	imul   $0x74,%esi,%esi
f0104017:	81 c6 2c d0 22 f0    	add    $0xf022d02c,%esi
f010401d:	66 89 34 dd 42 13 12 	mov    %si,-0xfedecbe(,%ebx,8)
f0104024:	f0 
f0104025:	6b d7 74             	imul   $0x74,%edi,%edx
f0104028:	81 c2 2c d0 22 f0    	add    $0xf022d02c,%edx
f010402e:	c1 ea 10             	shr    $0x10,%edx
f0104031:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104038:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010403f:	40 
f0104040:	6b c0 74             	imul   $0x74,%eax,%eax
f0104043:	05 2c d0 22 f0       	add    $0xf022d02c,%eax
f0104048:	c1 e8 18             	shr    $0x18,%eax
f010404b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104052:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0104059:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010405a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010405d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104060:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0104065:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104068:	83 c4 1c             	add    $0x1c,%esp
f010406b:	5b                   	pop    %ebx
f010406c:	5e                   	pop    %esi
f010406d:	5f                   	pop    %edi
f010406e:	5d                   	pop    %ebp
f010406f:	c3                   	ret    

f0104070 <trap_init>:
}


void
trap_init(void)
{
f0104070:	55                   	push   %ebp
f0104071:	89 e5                	mov    %esp,%ebp
f0104073:	83 ec 08             	sub    $0x8,%esp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104076:	b8 24 4a 10 f0       	mov    $0xf0104a24,%eax
f010407b:	66 a3 60 c2 22 f0    	mov    %ax,0xf022c260
f0104081:	66 c7 05 62 c2 22 f0 	movw   $0x8,0xf022c262
f0104088:	08 00 
f010408a:	c6 05 64 c2 22 f0 00 	movb   $0x0,0xf022c264
f0104091:	c6 05 65 c2 22 f0 8e 	movb   $0x8e,0xf022c265
f0104098:	c1 e8 10             	shr    $0x10,%eax
f010409b:	66 a3 66 c2 22 f0    	mov    %ax,0xf022c266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f01040a1:	b8 2e 4a 10 f0       	mov    $0xf0104a2e,%eax
f01040a6:	66 a3 68 c2 22 f0    	mov    %ax,0xf022c268
f01040ac:	66 c7 05 6a c2 22 f0 	movw   $0x8,0xf022c26a
f01040b3:	08 00 
f01040b5:	c6 05 6c c2 22 f0 00 	movb   $0x0,0xf022c26c
f01040bc:	c6 05 6d c2 22 f0 8e 	movb   $0x8e,0xf022c26d
f01040c3:	c1 e8 10             	shr    $0x10,%eax
f01040c6:	66 a3 6e c2 22 f0    	mov    %ax,0xf022c26e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040cc:	b8 38 4a 10 f0       	mov    $0xf0104a38,%eax
f01040d1:	66 a3 70 c2 22 f0    	mov    %ax,0xf022c270
f01040d7:	66 c7 05 72 c2 22 f0 	movw   $0x8,0xf022c272
f01040de:	08 00 
f01040e0:	c6 05 74 c2 22 f0 00 	movb   $0x0,0xf022c274
f01040e7:	c6 05 75 c2 22 f0 8e 	movb   $0x8e,0xf022c275
f01040ee:	c1 e8 10             	shr    $0x10,%eax
f01040f1:	66 a3 76 c2 22 f0    	mov    %ax,0xf022c276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01040f7:	b8 42 4a 10 f0       	mov    $0xf0104a42,%eax
f01040fc:	66 a3 78 c2 22 f0    	mov    %ax,0xf022c278
f0104102:	66 c7 05 7a c2 22 f0 	movw   $0x8,0xf022c27a
f0104109:	08 00 
f010410b:	c6 05 7c c2 22 f0 00 	movb   $0x0,0xf022c27c
f0104112:	c6 05 7d c2 22 f0 ee 	movb   $0xee,0xf022c27d
f0104119:	c1 e8 10             	shr    $0x10,%eax
f010411c:	66 a3 7e c2 22 f0    	mov    %ax,0xf022c27e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104122:	b8 4c 4a 10 f0       	mov    $0xf0104a4c,%eax
f0104127:	66 a3 80 c2 22 f0    	mov    %ax,0xf022c280
f010412d:	66 c7 05 82 c2 22 f0 	movw   $0x8,0xf022c282
f0104134:	08 00 
f0104136:	c6 05 84 c2 22 f0 00 	movb   $0x0,0xf022c284
f010413d:	c6 05 85 c2 22 f0 8e 	movb   $0x8e,0xf022c285
f0104144:	c1 e8 10             	shr    $0x10,%eax
f0104147:	66 a3 86 c2 22 f0    	mov    %ax,0xf022c286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010414d:	b8 56 4a 10 f0       	mov    $0xf0104a56,%eax
f0104152:	66 a3 88 c2 22 f0    	mov    %ax,0xf022c288
f0104158:	66 c7 05 8a c2 22 f0 	movw   $0x8,0xf022c28a
f010415f:	08 00 
f0104161:	c6 05 8c c2 22 f0 00 	movb   $0x0,0xf022c28c
f0104168:	c6 05 8d c2 22 f0 8e 	movb   $0x8e,0xf022c28d
f010416f:	c1 e8 10             	shr    $0x10,%eax
f0104172:	66 a3 8e c2 22 f0    	mov    %ax,0xf022c28e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104178:	b8 60 4a 10 f0       	mov    $0xf0104a60,%eax
f010417d:	66 a3 90 c2 22 f0    	mov    %ax,0xf022c290
f0104183:	66 c7 05 92 c2 22 f0 	movw   $0x8,0xf022c292
f010418a:	08 00 
f010418c:	c6 05 94 c2 22 f0 00 	movb   $0x0,0xf022c294
f0104193:	c6 05 95 c2 22 f0 8e 	movb   $0x8e,0xf022c295
f010419a:	c1 e8 10             	shr    $0x10,%eax
f010419d:	66 a3 96 c2 22 f0    	mov    %ax,0xf022c296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f01041a3:	b8 6a 4a 10 f0       	mov    $0xf0104a6a,%eax
f01041a8:	66 a3 98 c2 22 f0    	mov    %ax,0xf022c298
f01041ae:	66 c7 05 9a c2 22 f0 	movw   $0x8,0xf022c29a
f01041b5:	08 00 
f01041b7:	c6 05 9c c2 22 f0 00 	movb   $0x0,0xf022c29c
f01041be:	c6 05 9d c2 22 f0 8e 	movb   $0x8e,0xf022c29d
f01041c5:	c1 e8 10             	shr    $0x10,%eax
f01041c8:	66 a3 9e c2 22 f0    	mov    %ax,0xf022c29e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041ce:	b8 74 4a 10 f0       	mov    $0xf0104a74,%eax
f01041d3:	66 a3 a0 c2 22 f0    	mov    %ax,0xf022c2a0
f01041d9:	66 c7 05 a2 c2 22 f0 	movw   $0x8,0xf022c2a2
f01041e0:	08 00 
f01041e2:	c6 05 a4 c2 22 f0 00 	movb   $0x0,0xf022c2a4
f01041e9:	c6 05 a5 c2 22 f0 8e 	movb   $0x8e,0xf022c2a5
f01041f0:	c1 e8 10             	shr    $0x10,%eax
f01041f3:	66 a3 a6 c2 22 f0    	mov    %ax,0xf022c2a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01041f9:	b8 7c 4a 10 f0       	mov    $0xf0104a7c,%eax
f01041fe:	66 a3 a8 c2 22 f0    	mov    %ax,0xf022c2a8
f0104204:	66 c7 05 aa c2 22 f0 	movw   $0x8,0xf022c2aa
f010420b:	08 00 
f010420d:	c6 05 ac c2 22 f0 00 	movb   $0x0,0xf022c2ac
f0104214:	c6 05 ad c2 22 f0 8e 	movb   $0x8e,0xf022c2ad
f010421b:	c1 e8 10             	shr    $0x10,%eax
f010421e:	66 a3 ae c2 22 f0    	mov    %ax,0xf022c2ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104224:	b8 86 4a 10 f0       	mov    $0xf0104a86,%eax
f0104229:	66 a3 b0 c2 22 f0    	mov    %ax,0xf022c2b0
f010422f:	66 c7 05 b2 c2 22 f0 	movw   $0x8,0xf022c2b2
f0104236:	08 00 
f0104238:	c6 05 b4 c2 22 f0 00 	movb   $0x0,0xf022c2b4
f010423f:	c6 05 b5 c2 22 f0 8e 	movb   $0x8e,0xf022c2b5
f0104246:	c1 e8 10             	shr    $0x10,%eax
f0104249:	66 a3 b6 c2 22 f0    	mov    %ax,0xf022c2b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010424f:	b8 8e 4a 10 f0       	mov    $0xf0104a8e,%eax
f0104254:	66 a3 b8 c2 22 f0    	mov    %ax,0xf022c2b8
f010425a:	66 c7 05 ba c2 22 f0 	movw   $0x8,0xf022c2ba
f0104261:	08 00 
f0104263:	c6 05 bc c2 22 f0 00 	movb   $0x0,0xf022c2bc
f010426a:	c6 05 bd c2 22 f0 8e 	movb   $0x8e,0xf022c2bd
f0104271:	c1 e8 10             	shr    $0x10,%eax
f0104274:	66 a3 be c2 22 f0    	mov    %ax,0xf022c2be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010427a:	b8 96 4a 10 f0       	mov    $0xf0104a96,%eax
f010427f:	66 a3 c0 c2 22 f0    	mov    %ax,0xf022c2c0
f0104285:	66 c7 05 c2 c2 22 f0 	movw   $0x8,0xf022c2c2
f010428c:	08 00 
f010428e:	c6 05 c4 c2 22 f0 00 	movb   $0x0,0xf022c2c4
f0104295:	c6 05 c5 c2 22 f0 8e 	movb   $0x8e,0xf022c2c5
f010429c:	c1 e8 10             	shr    $0x10,%eax
f010429f:	66 a3 c6 c2 22 f0    	mov    %ax,0xf022c2c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f01042a5:	b8 9e 4a 10 f0       	mov    $0xf0104a9e,%eax
f01042aa:	66 a3 c8 c2 22 f0    	mov    %ax,0xf022c2c8
f01042b0:	66 c7 05 ca c2 22 f0 	movw   $0x8,0xf022c2ca
f01042b7:	08 00 
f01042b9:	c6 05 cc c2 22 f0 00 	movb   $0x0,0xf022c2cc
f01042c0:	c6 05 cd c2 22 f0 8e 	movb   $0x8e,0xf022c2cd
f01042c7:	c1 e8 10             	shr    $0x10,%eax
f01042ca:	66 a3 ce c2 22 f0    	mov    %ax,0xf022c2ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042d0:	b8 a6 4a 10 f0       	mov    $0xf0104aa6,%eax
f01042d5:	66 a3 d0 c2 22 f0    	mov    %ax,0xf022c2d0
f01042db:	66 c7 05 d2 c2 22 f0 	movw   $0x8,0xf022c2d2
f01042e2:	08 00 
f01042e4:	c6 05 d4 c2 22 f0 00 	movb   $0x0,0xf022c2d4
f01042eb:	c6 05 d5 c2 22 f0 8e 	movb   $0x8e,0xf022c2d5
f01042f2:	c1 e8 10             	shr    $0x10,%eax
f01042f5:	66 a3 d6 c2 22 f0    	mov    %ax,0xf022c2d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01042fb:	b8 ae 4a 10 f0       	mov    $0xf0104aae,%eax
f0104300:	66 a3 d8 c2 22 f0    	mov    %ax,0xf022c2d8
f0104306:	66 c7 05 da c2 22 f0 	movw   $0x8,0xf022c2da
f010430d:	08 00 
f010430f:	c6 05 dc c2 22 f0 00 	movb   $0x0,0xf022c2dc
f0104316:	c6 05 dd c2 22 f0 8e 	movb   $0x8e,0xf022c2dd
f010431d:	c1 e8 10             	shr    $0x10,%eax
f0104320:	66 a3 de c2 22 f0    	mov    %ax,0xf022c2de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104326:	b8 b8 4a 10 f0       	mov    $0xf0104ab8,%eax
f010432b:	66 a3 e0 c2 22 f0    	mov    %ax,0xf022c2e0
f0104331:	66 c7 05 e2 c2 22 f0 	movw   $0x8,0xf022c2e2
f0104338:	08 00 
f010433a:	c6 05 e4 c2 22 f0 00 	movb   $0x0,0xf022c2e4
f0104341:	c6 05 e5 c2 22 f0 8e 	movb   $0x8e,0xf022c2e5
f0104348:	c1 e8 10             	shr    $0x10,%eax
f010434b:	66 a3 e6 c2 22 f0    	mov    %ax,0xf022c2e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104351:	b8 c2 4a 10 f0       	mov    $0xf0104ac2,%eax
f0104356:	66 a3 e8 c2 22 f0    	mov    %ax,0xf022c2e8
f010435c:	66 c7 05 ea c2 22 f0 	movw   $0x8,0xf022c2ea
f0104363:	08 00 
f0104365:	c6 05 ec c2 22 f0 00 	movb   $0x0,0xf022c2ec
f010436c:	c6 05 ed c2 22 f0 8e 	movb   $0x8e,0xf022c2ed
f0104373:	c1 e8 10             	shr    $0x10,%eax
f0104376:	66 a3 ee c2 22 f0    	mov    %ax,0xf022c2ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010437c:	b8 ca 4a 10 f0       	mov    $0xf0104aca,%eax
f0104381:	66 a3 f0 c2 22 f0    	mov    %ax,0xf022c2f0
f0104387:	66 c7 05 f2 c2 22 f0 	movw   $0x8,0xf022c2f2
f010438e:	08 00 
f0104390:	c6 05 f4 c2 22 f0 00 	movb   $0x0,0xf022c2f4
f0104397:	c6 05 f5 c2 22 f0 8e 	movb   $0x8e,0xf022c2f5
f010439e:	c1 e8 10             	shr    $0x10,%eax
f01043a1:	66 a3 f6 c2 22 f0    	mov    %ax,0xf022c2f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f01043a7:	b8 d4 4a 10 f0       	mov    $0xf0104ad4,%eax
f01043ac:	66 a3 f8 c2 22 f0    	mov    %ax,0xf022c2f8
f01043b2:	66 c7 05 fa c2 22 f0 	movw   $0x8,0xf022c2fa
f01043b9:	08 00 
f01043bb:	c6 05 fc c2 22 f0 00 	movb   $0x0,0xf022c2fc
f01043c2:	c6 05 fd c2 22 f0 8e 	movb   $0x8e,0xf022c2fd
f01043c9:	c1 e8 10             	shr    $0x10,%eax
f01043cc:	66 a3 fe c2 22 f0    	mov    %ax,0xf022c2fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043d2:	b8 de 4a 10 f0       	mov    $0xf0104ade,%eax
f01043d7:	66 a3 e0 c3 22 f0    	mov    %ax,0xf022c3e0
f01043dd:	66 c7 05 e2 c3 22 f0 	movw   $0x8,0xf022c3e2
f01043e4:	08 00 
f01043e6:	c6 05 e4 c3 22 f0 00 	movb   $0x0,0xf022c3e4
f01043ed:	c6 05 e5 c3 22 f0 ee 	movb   $0xee,0xf022c3e5
f01043f4:	c1 e8 10             	shr    $0x10,%eax
f01043f7:	66 a3 e6 c3 22 f0    	mov    %ax,0xf022c3e6




	// Per-CPU setup 
	trap_init_percpu();
f01043fd:	e8 9e fb ff ff       	call   f0103fa0 <trap_init_percpu>
}
f0104402:	c9                   	leave  
f0104403:	c3                   	ret    

f0104404 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104404:	55                   	push   %ebp
f0104405:	89 e5                	mov    %esp,%ebp
f0104407:	53                   	push   %ebx
f0104408:	83 ec 14             	sub    $0x14,%esp
f010440b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010440e:	8b 03                	mov    (%ebx),%eax
f0104410:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104414:	c7 04 24 41 7c 10 f0 	movl   $0xf0107c41,(%esp)
f010441b:	e8 5e fb ff ff       	call   f0103f7e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104420:	8b 43 04             	mov    0x4(%ebx),%eax
f0104423:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104427:	c7 04 24 50 7c 10 f0 	movl   $0xf0107c50,(%esp)
f010442e:	e8 4b fb ff ff       	call   f0103f7e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104433:	8b 43 08             	mov    0x8(%ebx),%eax
f0104436:	89 44 24 04          	mov    %eax,0x4(%esp)
f010443a:	c7 04 24 5f 7c 10 f0 	movl   $0xf0107c5f,(%esp)
f0104441:	e8 38 fb ff ff       	call   f0103f7e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104446:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104449:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444d:	c7 04 24 6e 7c 10 f0 	movl   $0xf0107c6e,(%esp)
f0104454:	e8 25 fb ff ff       	call   f0103f7e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104459:	8b 43 10             	mov    0x10(%ebx),%eax
f010445c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104460:	c7 04 24 7d 7c 10 f0 	movl   $0xf0107c7d,(%esp)
f0104467:	e8 12 fb ff ff       	call   f0103f7e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010446c:	8b 43 14             	mov    0x14(%ebx),%eax
f010446f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104473:	c7 04 24 8c 7c 10 f0 	movl   $0xf0107c8c,(%esp)
f010447a:	e8 ff fa ff ff       	call   f0103f7e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010447f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104482:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104486:	c7 04 24 9b 7c 10 f0 	movl   $0xf0107c9b,(%esp)
f010448d:	e8 ec fa ff ff       	call   f0103f7e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104492:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104495:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104499:	c7 04 24 aa 7c 10 f0 	movl   $0xf0107caa,(%esp)
f01044a0:	e8 d9 fa ff ff       	call   f0103f7e <cprintf>
}
f01044a5:	83 c4 14             	add    $0x14,%esp
f01044a8:	5b                   	pop    %ebx
f01044a9:	5d                   	pop    %ebp
f01044aa:	c3                   	ret    

f01044ab <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f01044ab:	55                   	push   %ebp
f01044ac:	89 e5                	mov    %esp,%ebp
f01044ae:	56                   	push   %esi
f01044af:	53                   	push   %ebx
f01044b0:	83 ec 10             	sub    $0x10,%esp
f01044b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044b6:	e8 39 1e 00 00       	call   f01062f4 <cpunum>
f01044bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044c3:	c7 04 24 0e 7d 10 f0 	movl   $0xf0107d0e,(%esp)
f01044ca:	e8 af fa ff ff       	call   f0103f7e <cprintf>
	print_regs(&tf->tf_regs);
f01044cf:	89 1c 24             	mov    %ebx,(%esp)
f01044d2:	e8 2d ff ff ff       	call   f0104404 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044d7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044df:	c7 04 24 2c 7d 10 f0 	movl   $0xf0107d2c,(%esp)
f01044e6:	e8 93 fa ff ff       	call   f0103f7e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044eb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f3:	c7 04 24 3f 7d 10 f0 	movl   $0xf0107d3f,(%esp)
f01044fa:	e8 7f fa ff ff       	call   f0103f7e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044ff:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104502:	83 f8 13             	cmp    $0x13,%eax
f0104505:	77 09                	ja     f0104510 <print_trapframe+0x65>
		return excnames[trapno];
f0104507:	8b 14 85 20 80 10 f0 	mov    -0xfef7fe0(,%eax,4),%edx
f010450e:	eb 1d                	jmp    f010452d <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f0104510:	ba b9 7c 10 f0       	mov    $0xf0107cb9,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104515:	83 f8 30             	cmp    $0x30,%eax
f0104518:	74 13                	je     f010452d <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010451a:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010451d:	83 fa 0f             	cmp    $0xf,%edx
f0104520:	ba c5 7c 10 f0       	mov    $0xf0107cc5,%edx
f0104525:	b9 d8 7c 10 f0       	mov    $0xf0107cd8,%ecx
f010452a:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010452d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104531:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104535:	c7 04 24 52 7d 10 f0 	movl   $0xf0107d52,(%esp)
f010453c:	e8 3d fa ff ff       	call   f0103f7e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104541:	3b 1d 60 ca 22 f0    	cmp    0xf022ca60,%ebx
f0104547:	75 19                	jne    f0104562 <print_trapframe+0xb7>
f0104549:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010454d:	75 13                	jne    f0104562 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010454f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104552:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104556:	c7 04 24 64 7d 10 f0 	movl   $0xf0107d64,(%esp)
f010455d:	e8 1c fa ff ff       	call   f0103f7e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104562:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104565:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104569:	c7 04 24 73 7d 10 f0 	movl   $0xf0107d73,(%esp)
f0104570:	e8 09 fa ff ff       	call   f0103f7e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104575:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104579:	75 51                	jne    f01045cc <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010457b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010457e:	89 c2                	mov    %eax,%edx
f0104580:	83 e2 01             	and    $0x1,%edx
f0104583:	ba e7 7c 10 f0       	mov    $0xf0107ce7,%edx
f0104588:	b9 f2 7c 10 f0       	mov    $0xf0107cf2,%ecx
f010458d:	0f 45 ca             	cmovne %edx,%ecx
f0104590:	89 c2                	mov    %eax,%edx
f0104592:	83 e2 02             	and    $0x2,%edx
f0104595:	ba fe 7c 10 f0       	mov    $0xf0107cfe,%edx
f010459a:	be 04 7d 10 f0       	mov    $0xf0107d04,%esi
f010459f:	0f 44 d6             	cmove  %esi,%edx
f01045a2:	83 e0 04             	and    $0x4,%eax
f01045a5:	b8 09 7d 10 f0       	mov    $0xf0107d09,%eax
f01045aa:	be 73 7e 10 f0       	mov    $0xf0107e73,%esi
f01045af:	0f 44 c6             	cmove  %esi,%eax
f01045b2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045b6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045be:	c7 04 24 81 7d 10 f0 	movl   $0xf0107d81,(%esp)
f01045c5:	e8 b4 f9 ff ff       	call   f0103f7e <cprintf>
f01045ca:	eb 0c                	jmp    f01045d8 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045cc:	c7 04 24 40 7b 10 f0 	movl   $0xf0107b40,(%esp)
f01045d3:	e8 a6 f9 ff ff       	call   f0103f7e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045d8:	8b 43 30             	mov    0x30(%ebx),%eax
f01045db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045df:	c7 04 24 90 7d 10 f0 	movl   $0xf0107d90,(%esp)
f01045e6:	e8 93 f9 ff ff       	call   f0103f7e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045eb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f3:	c7 04 24 9f 7d 10 f0 	movl   $0xf0107d9f,(%esp)
f01045fa:	e8 7f f9 ff ff       	call   f0103f7e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045ff:	8b 43 38             	mov    0x38(%ebx),%eax
f0104602:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104606:	c7 04 24 b2 7d 10 f0 	movl   $0xf0107db2,(%esp)
f010460d:	e8 6c f9 ff ff       	call   f0103f7e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104612:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104616:	74 27                	je     f010463f <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104618:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010461b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010461f:	c7 04 24 c1 7d 10 f0 	movl   $0xf0107dc1,(%esp)
f0104626:	e8 53 f9 ff ff       	call   f0103f7e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010462b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010462f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104633:	c7 04 24 d0 7d 10 f0 	movl   $0xf0107dd0,(%esp)
f010463a:	e8 3f f9 ff ff       	call   f0103f7e <cprintf>
	}
}
f010463f:	83 c4 10             	add    $0x10,%esp
f0104642:	5b                   	pop    %ebx
f0104643:	5e                   	pop    %esi
f0104644:	5d                   	pop    %ebp
f0104645:	c3                   	ret    

f0104646 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104646:	55                   	push   %ebp
f0104647:	89 e5                	mov    %esp,%ebp
f0104649:	57                   	push   %edi
f010464a:	56                   	push   %esi
f010464b:	53                   	push   %ebx
f010464c:	83 ec 6c             	sub    $0x6c,%esp
f010464f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104652:	0f 20 d0             	mov    %cr2,%eax
f0104655:	89 45 a0             	mov    %eax,-0x60(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104658:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010465d:	75 1c                	jne    f010467b <page_fault_handler+0x35>
		panic("page fault happens in the kern mode");
f010465f:	c7 44 24 08 c0 7f 10 	movl   $0xf0107fc0,0x8(%esp)
f0104666:	f0 
f0104667:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f010466e:	00 
f010466f:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f0104676:	e8 c5 b9 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
f010467b:	e8 74 1c 00 00       	call   f01062f4 <cpunum>
f0104680:	6b c0 74             	imul   $0x74,%eax,%eax
f0104683:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104689:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010468d:	75 4d                	jne    f01046dc <page_fault_handler+0x96>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010468f:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104692:	e8 5d 1c 00 00       	call   f01062f4 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104697:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010469b:	8b 55 a0             	mov    -0x60(%ebp),%edx
f010469e:	89 54 24 08          	mov    %edx,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f01046a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046ab:	8b 40 48             	mov    0x48(%eax),%eax
f01046ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b2:	c7 04 24 e4 7f 10 f0 	movl   $0xf0107fe4,(%esp)
f01046b9:	e8 c0 f8 ff ff       	call   f0103f7e <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f01046be:	89 1c 24             	mov    %ebx,(%esp)
f01046c1:	e8 e5 fd ff ff       	call   f01044ab <print_trapframe>
		env_destroy(curenv);
f01046c6:	e8 29 1c 00 00       	call   f01062f4 <cpunum>
f01046cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ce:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01046d4:	89 04 24             	mov    %eax,(%esp)
f01046d7:	e8 a7 f5 ff ff       	call   f0103c83 <env_destroy>
	}
	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f01046dc:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046df:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			panic("No memory for the UxStack");
		int temp =0;
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -4;
f01046e5:	83 e8 38             	sub    $0x38,%eax
f01046e8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
	}
	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f01046eb:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01046f1:	0f 86 82 00 00 00    	jbe    f0104779 <page_fault_handler+0x133>
		struct PageInfo *page = page_alloc(1);
f01046f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01046fe:	e8 56 c8 ff ff       	call   f0100f59 <page_alloc>
f0104703:	89 c6                	mov    %eax,%esi
		if(page == 0)
f0104705:	85 c0                	test   %eax,%eax
f0104707:	75 1c                	jne    f0104725 <page_fault_handler+0xdf>
			panic("No Memory for the UxStack\n");
f0104709:	c7 44 24 08 ef 7d 10 	movl   $0xf0107def,0x8(%esp)
f0104710:	f0 
f0104711:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f0104718:	00 
f0104719:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f0104720:	e8 1b b9 ff ff       	call   f0100040 <_panic>
		int r = page_insert(curenv->env_pgdir, page, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P);
f0104725:	e8 ca 1b 00 00       	call   f01062f4 <cpunum>
f010472a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104731:	00 
f0104732:	c7 44 24 08 00 f0 bf 	movl   $0xeebff000,0x8(%esp)
f0104739:	ee 
f010473a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010473e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104741:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104747:	8b 40 60             	mov    0x60(%eax),%eax
f010474a:	89 04 24             	mov    %eax,(%esp)
f010474d:	e8 fd ca ff ff       	call   f010124f <page_insert>
		if(r < 0)
			panic("No memory for the UxStack");
		int temp =0;
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
f0104752:	c7 45 a4 cc ff bf ee 	movl   $0xeebfffcc,-0x5c(%ebp)
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
		struct PageInfo *page = page_alloc(1);
		if(page == 0)
			panic("No Memory for the UxStack\n");
		int r = page_insert(curenv->env_pgdir, page, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P);
		if(r < 0)
f0104759:	85 c0                	test   %eax,%eax
f010475b:	79 1c                	jns    f0104779 <page_fault_handler+0x133>
			panic("No memory for the UxStack");
f010475d:	c7 44 24 08 0a 7e 10 	movl   $0xf0107e0a,0x8(%esp)
f0104764:	f0 
f0104765:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f010476c:	00 
f010476d:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f0104774:	e8 c7 b8 ff ff       	call   f0100040 <_panic>
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -4;
	
	UT.utf_err = tf->tf_err;
f0104779:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010477c:	89 45 b8             	mov    %eax,-0x48(%ebp)
	UT.utf_regs = tf->tf_regs;
f010477f:	8d 7d bc             	lea    -0x44(%ebp),%edi
f0104782:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104787:	89 de                	mov    %ebx,%esi
f0104789:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	UT.utf_eflags = tf->tf_eflags;
f010478b:	8b 43 38             	mov    0x38(%ebx),%eax
f010478e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	UT.utf_eip = tf->tf_eip;
f0104791:	8b 43 30             	mov    0x30(%ebx),%eax
f0104794:	89 45 dc             	mov    %eax,-0x24(%ebp)
	UT.utf_esp = tf->tf_esp;
f0104797:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010479a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	UT.utf_fault_va = fault_va;
f010479d:	8b 45 a0             	mov    -0x60(%ebp),%eax
f01047a0:	89 45 b4             	mov    %eax,-0x4c(%ebp)

	user_mem_assert(curenv,(void*)newEsp, sizeof(struct UTrapframe),PTE_U|PTE_P|PTE_W );
f01047a3:	e8 4c 1b 00 00       	call   f01062f4 <cpunum>
f01047a8:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01047af:	00 
f01047b0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047b7:	00 
f01047b8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f01047bb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01047bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c2:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01047c8:	89 04 24             	mov    %eax,(%esp)
f01047cb:	e8 49 ed ff ff       	call   f0103519 <user_mem_assert>
	memcpy((void*)newEsp, (&UT) ,sizeof(struct UTrapframe));
f01047d0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047d7:	00 
f01047d8:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f01047db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047df:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01047e2:	89 04 24             	mov    %eax,(%esp)
f01047e5:	e8 7d 15 00 00       	call   f0105d67 <memcpy>
	tf->tf_esp = newEsp;
f01047ea:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f01047ed:	89 53 3c             	mov    %edx,0x3c(%ebx)
	env_run(curenv);
f01047f0:	e8 ff 1a 00 00       	call   f01062f4 <cpunum>
f01047f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f8:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01047fe:	89 04 24             	mov    %eax,(%esp)
f0104801:	e8 1e f5 ff ff       	call   f0103d24 <env_run>

f0104806 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104806:	55                   	push   %ebp
f0104807:	89 e5                	mov    %esp,%ebp
f0104809:	57                   	push   %edi
f010480a:	56                   	push   %esi
f010480b:	83 ec 20             	sub    $0x20,%esp
f010480e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104811:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104812:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f0104819:	74 01                	je     f010481c <trap+0x16>
		asm volatile("hlt");
f010481b:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010481c:	e8 d3 1a 00 00       	call   f01062f4 <cpunum>
f0104821:	6b d0 74             	imul   $0x74,%eax,%edx
f0104824:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010482a:	b8 01 00 00 00       	mov    $0x1,%eax
f010482f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104833:	83 f8 02             	cmp    $0x2,%eax
f0104836:	75 0c                	jne    f0104844 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104838:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010483f:	e8 60 1d 00 00       	call   f01065a4 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104844:	9c                   	pushf  
f0104845:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104846:	f6 c4 02             	test   $0x2,%ah
f0104849:	74 24                	je     f010486f <trap+0x69>
f010484b:	c7 44 24 0c 24 7e 10 	movl   $0xf0107e24,0xc(%esp)
f0104852:	f0 
f0104853:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f010485a:	f0 
f010485b:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0104862:	00 
f0104863:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f010486a:	e8 d1 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010486f:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104873:	83 e0 03             	and    $0x3,%eax
f0104876:	83 f8 03             	cmp    $0x3,%eax
f0104879:	0f 85 a7 00 00 00    	jne    f0104926 <trap+0x120>
f010487f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104886:	e8 19 1d 00 00       	call   f01065a4 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010488b:	e8 64 1a 00 00       	call   f01062f4 <cpunum>
f0104890:	6b c0 74             	imul   $0x74,%eax,%eax
f0104893:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f010489a:	75 24                	jne    f01048c0 <trap+0xba>
f010489c:	c7 44 24 0c 3d 7e 10 	movl   $0xf0107e3d,0xc(%esp)
f01048a3:	f0 
f01048a4:	c7 44 24 08 6f 78 10 	movl   $0xf010786f,0x8(%esp)
f01048ab:	f0 
f01048ac:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f01048b3:	00 
f01048b4:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f01048bb:	e8 80 b7 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01048c0:	e8 2f 1a 00 00       	call   f01062f4 <cpunum>
f01048c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c8:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01048ce:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01048d2:	75 2d                	jne    f0104901 <trap+0xfb>
			env_free(curenv);
f01048d4:	e8 1b 1a 00 00       	call   f01062f4 <cpunum>
f01048d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048dc:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01048e2:	89 04 24             	mov    %eax,(%esp)
f01048e5:	e8 92 f1 ff ff       	call   f0103a7c <env_free>
			curenv = NULL;
f01048ea:	e8 05 1a 00 00       	call   f01062f4 <cpunum>
f01048ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f2:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f01048f9:	00 00 00 
			sched_yield();
f01048fc:	e8 d3 02 00 00       	call   f0104bd4 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104901:	e8 ee 19 00 00       	call   f01062f4 <cpunum>
f0104906:	6b c0 74             	imul   $0x74,%eax,%eax
f0104909:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010490f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104914:	89 c7                	mov    %eax,%edi
f0104916:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104918:	e8 d7 19 00 00       	call   f01062f4 <cpunum>
f010491d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104920:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104926:	89 35 60 ca 22 f0    	mov    %esi,0xf022ca60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f010492c:	8b 46 28             	mov    0x28(%esi),%eax
f010492f:	83 f8 0e             	cmp    $0xe,%eax
f0104932:	75 08                	jne    f010493c <trap+0x136>
		page_fault_handler(tf);
f0104934:	89 34 24             	mov    %esi,(%esp)
f0104937:	e8 0a fd ff ff       	call   f0104646 <page_fault_handler>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f010493c:	83 f8 03             	cmp    $0x3,%eax
f010493f:	75 0d                	jne    f010494e <trap+0x148>
		monitor(tf);
f0104941:	89 34 24             	mov    %esi,(%esp)
f0104944:	e8 80 bf ff ff       	call   f01008c9 <monitor>
f0104949:	e9 93 00 00 00       	jmp    f01049e1 <trap+0x1db>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f010494e:	83 f8 30             	cmp    $0x30,%eax
f0104951:	75 32                	jne    f0104985 <trap+0x17f>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104953:	8b 46 04             	mov    0x4(%esi),%eax
f0104956:	89 44 24 14          	mov    %eax,0x14(%esp)
f010495a:	8b 06                	mov    (%esi),%eax
f010495c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104960:	8b 46 10             	mov    0x10(%esi),%eax
f0104963:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104967:	8b 46 18             	mov    0x18(%esi),%eax
f010496a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010496e:	8b 46 14             	mov    0x14(%esi),%eax
f0104971:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104975:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104978:	89 04 24             	mov    %eax,(%esp)
f010497b:	e8 20 03 00 00       	call   f0104ca0 <syscall>
f0104980:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104983:	eb 5c                	jmp    f01049e1 <trap+0x1db>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104985:	83 f8 27             	cmp    $0x27,%eax
f0104988:	75 16                	jne    f01049a0 <trap+0x19a>
		cprintf("Spurious interrupt on irq 7\n");
f010498a:	c7 04 24 44 7e 10 f0 	movl   $0xf0107e44,(%esp)
f0104991:	e8 e8 f5 ff ff       	call   f0103f7e <cprintf>
		print_trapframe(tf);
f0104996:	89 34 24             	mov    %esi,(%esp)
f0104999:	e8 0d fb ff ff       	call   f01044ab <print_trapframe>
f010499e:	eb 41                	jmp    f01049e1 <trap+0x1db>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01049a0:	89 34 24             	mov    %esi,(%esp)
f01049a3:	e8 03 fb ff ff       	call   f01044ab <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01049a8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01049ad:	75 1c                	jne    f01049cb <trap+0x1c5>
		panic("unhandled trap in kernel");
f01049af:	c7 44 24 08 61 7e 10 	movl   $0xf0107e61,0x8(%esp)
f01049b6:	f0 
f01049b7:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
f01049be:	00 
f01049bf:	c7 04 24 e3 7d 10 f0 	movl   $0xf0107de3,(%esp)
f01049c6:	e8 75 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01049cb:	e8 24 19 00 00       	call   f01062f4 <cpunum>
f01049d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01049d9:	89 04 24             	mov    %eax,(%esp)
f01049dc:	e8 a2 f2 ff ff       	call   f0103c83 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049e1:	e8 0e 19 00 00       	call   f01062f4 <cpunum>
f01049e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e9:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01049f0:	74 2a                	je     f0104a1c <trap+0x216>
f01049f2:	e8 fd 18 00 00       	call   f01062f4 <cpunum>
f01049f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fa:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104a00:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a04:	75 16                	jne    f0104a1c <trap+0x216>
		env_run(curenv);
f0104a06:	e8 e9 18 00 00       	call   f01062f4 <cpunum>
f0104a0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0e:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104a14:	89 04 24             	mov    %eax,(%esp)
f0104a17:	e8 08 f3 ff ff       	call   f0103d24 <env_run>
	else
		sched_yield();
f0104a1c:	e8 b3 01 00 00       	call   f0104bd4 <sched_yield>
f0104a21:	00 00                	add    %al,(%eax)
	...

f0104a24 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104a24:	6a 00                	push   $0x0
f0104a26:	6a 00                	push   $0x0
f0104a28:	e9 ba 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a2d:	90                   	nop

f0104a2e <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	6a 01                	push   $0x1
f0104a32:	e9 b0 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a37:	90                   	nop

f0104a38 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f0104a38:	6a 00                	push   $0x0
f0104a3a:	6a 02                	push   $0x2
f0104a3c:	e9 a6 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a41:	90                   	nop

f0104a42 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104a42:	6a 00                	push   $0x0
f0104a44:	6a 03                	push   $0x3
f0104a46:	e9 9c 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a4b:	90                   	nop

f0104a4c <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	6a 04                	push   $0x4
f0104a50:	e9 92 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a55:	90                   	nop

f0104a56 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104a56:	6a 00                	push   $0x0
f0104a58:	6a 05                	push   $0x5
f0104a5a:	e9 88 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a5f:	90                   	nop

f0104a60 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104a60:	6a 00                	push   $0x0
f0104a62:	6a 06                	push   $0x6
f0104a64:	e9 7e 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a69:	90                   	nop

f0104a6a <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	6a 07                	push   $0x7
f0104a6e:	e9 74 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a73:	90                   	nop

f0104a74 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104a74:	6a 08                	push   $0x8
f0104a76:	e9 6c 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a7b:	90                   	nop

f0104a7c <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104a7c:	6a 00                	push   $0x0
f0104a7e:	6a 09                	push   $0x9
f0104a80:	e9 62 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a85:	90                   	nop

f0104a86 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104a86:	6a 0a                	push   $0xa
f0104a88:	e9 5a 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a8d:	90                   	nop

f0104a8e <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104a8e:	6a 0b                	push   $0xb
f0104a90:	e9 52 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a95:	90                   	nop

f0104a96 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104a96:	6a 0c                	push   $0xc
f0104a98:	e9 4a 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104a9d:	90                   	nop

f0104a9e <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104a9e:	6a 0d                	push   $0xd
f0104aa0:	e9 42 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104aa5:	90                   	nop

f0104aa6 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104aa6:	6a 0e                	push   $0xe
f0104aa8:	e9 3a 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104aad:	90                   	nop

f0104aae <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104aae:	6a 00                	push   $0x0
f0104ab0:	6a 0f                	push   $0xf
f0104ab2:	e9 30 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104ab7:	90                   	nop

f0104ab8 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104ab8:	6a 00                	push   $0x0
f0104aba:	6a 10                	push   $0x10
f0104abc:	e9 26 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104ac1:	90                   	nop

f0104ac2 <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104ac2:	6a 11                	push   $0x11
f0104ac4:	e9 1e 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104ac9:	90                   	nop

f0104aca <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104aca:	6a 00                	push   $0x0
f0104acc:	6a 12                	push   $0x12
f0104ace:	e9 14 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104ad3:	90                   	nop

f0104ad4 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104ad4:	6a 00                	push   $0x0
f0104ad6:	6a 13                	push   $0x13
f0104ad8:	e9 0a 00 00 00       	jmp    f0104ae7 <_alltraps>
f0104add:	90                   	nop

f0104ade <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104ade:	6a 00                	push   $0x0
f0104ae0:	6a 30                	push   $0x30
f0104ae2:	e9 00 00 00 00       	jmp    f0104ae7 <_alltraps>

f0104ae7 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104ae7:	1e                   	push   %ds
	pushl %es
f0104ae8:	06                   	push   %es
	pushal
f0104ae9:	60                   	pusha  
	movl $GD_KD, %eax
f0104aea:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104aef:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104af1:	8e c0                	mov    %eax,%es

	pushl %esp
f0104af3:	54                   	push   %esp
	call trap
f0104af4:	e8 0d fd ff ff       	call   f0104806 <trap>
f0104af9:	00 00                	add    %al,(%eax)
	...

f0104afc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104afc:	55                   	push   %ebp
f0104afd:	89 e5                	mov    %esp,%ebp
f0104aff:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104b02:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
f0104b08:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b0b:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104b10:	8b 0a                	mov    (%edx),%ecx
f0104b12:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104b15:	83 f9 02             	cmp    $0x2,%ecx
f0104b18:	76 0f                	jbe    f0104b29 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b1a:	83 c0 01             	add    $0x1,%eax
f0104b1d:	83 c2 7c             	add    $0x7c,%edx
f0104b20:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b25:	75 e9                	jne    f0104b10 <sched_halt+0x14>
f0104b27:	eb 07                	jmp    f0104b30 <sched_halt+0x34>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b29:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b2e:	75 1a                	jne    f0104b4a <sched_halt+0x4e>
		cprintf("No runnable environments in the system!\n");
f0104b30:	c7 04 24 70 80 10 f0 	movl   $0xf0108070,(%esp)
f0104b37:	e8 42 f4 ff ff       	call   f0103f7e <cprintf>
		while (1)
			monitor(NULL);
f0104b3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b43:	e8 81 bd ff ff       	call   f01008c9 <monitor>
f0104b48:	eb f2                	jmp    f0104b3c <sched_halt+0x40>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b4a:	e8 a5 17 00 00       	call   f01062f4 <cpunum>
f0104b4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b52:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104b59:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b5c:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b61:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104b66:	77 20                	ja     f0104b88 <sched_halt+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b68:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b6c:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0104b73:	f0 
f0104b74:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0104b7b:	00 
f0104b7c:	c7 04 24 99 80 10 f0 	movl   $0xf0108099,(%esp)
f0104b83:	e8 b8 b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b88:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104b8d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b90:	e8 5f 17 00 00       	call   f01062f4 <cpunum>
f0104b95:	6b d0 74             	imul   $0x74,%eax,%edx
f0104b98:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104b9e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104ba3:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104ba7:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104bae:	e8 8d 1a 00 00       	call   f0106640 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104bb3:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104bb5:	e8 3a 17 00 00       	call   f01062f4 <cpunum>
f0104bba:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104bbd:	8b 80 30 d0 22 f0    	mov    -0xfdd2fd0(%eax),%eax
f0104bc3:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104bc8:	89 c4                	mov    %eax,%esp
f0104bca:	6a 00                	push   $0x0
f0104bcc:	6a 00                	push   $0x0
f0104bce:	fb                   	sti    
f0104bcf:	f4                   	hlt    
f0104bd0:	eb fd                	jmp    f0104bcf <sched_halt+0xd3>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104bd2:	c9                   	leave  
f0104bd3:	c3                   	ret    

f0104bd4 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104bd4:	55                   	push   %ebp
f0104bd5:	89 e5                	mov    %esp,%ebp
f0104bd7:	57                   	push   %edi
f0104bd8:	56                   	push   %esi
f0104bd9:	53                   	push   %ebx
f0104bda:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
f0104bdd:	e8 12 17 00 00       	call   f01062f4 <cpunum>
f0104be2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be5:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
f0104beb:	b8 00 00 00 00       	mov    $0x0,%eax
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104bf5:	85 db                	test   %ebx,%ebx
f0104bf7:	74 3e                	je     f0104c37 <sched_yield+0x63>
			
		EnvID =  e-envs;
f0104bf9:	89 de                	mov    %ebx,%esi
f0104bfb:	2b 35 48 c2 22 f0    	sub    0xf022c248,%esi
f0104c01:	c1 fe 02             	sar    $0x2,%esi
f0104c04:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104c0a:	89 f1                	mov    %esi,%ecx
		e->env_status = ENV_RUNNABLE;
f0104c0c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104c13:	83 c6 01             	add    $0x1,%esi
f0104c16:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104c1b:	89 f0                	mov    %esi,%eax
f0104c1d:	f7 ea                	imul   %edx
f0104c1f:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104c22:	c1 f8 09             	sar    $0x9,%eax
f0104c25:	89 f7                	mov    %esi,%edi
f0104c27:	c1 ff 1f             	sar    $0x1f,%edi
f0104c2a:	29 f8                	sub    %edi,%eax
f0104c2c:	89 c2                	mov    %eax,%edx
f0104c2e:	c1 e2 0a             	shl    $0xa,%edx
f0104c31:	29 c2                	sub    %eax,%edx
f0104c33:	29 d6                	sub    %edx,%esi
f0104c35:	89 f0                	mov    %esi,%eax
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104c37:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
f0104c3d:	ba 01 00 00 00       	mov    $0x1,%edx
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c42:	eb 2c                	jmp    f0104c70 <sched_yield+0x9c>
		if(envs[i].env_status == ENV_RUNNABLE){
f0104c44:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104c47:	01 f2                	add    %esi,%edx
f0104c49:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104c4d:	75 08                	jne    f0104c57 <sched_yield+0x83>
			//envs[i].env_cpunum = cpunum();
			env_run(&envs[i]);
f0104c4f:	89 14 24             	mov    %edx,(%esp)
f0104c52:	e8 cd f0 ff ff       	call   f0103d24 <env_run>
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c57:	83 c0 01             	add    $0x1,%eax
f0104c5a:	89 c2                	mov    %eax,%edx
f0104c5c:	c1 fa 1f             	sar    $0x1f,%edx
f0104c5f:	c1 ea 16             	shr    $0x16,%edx
f0104c62:	01 d0                	add    %edx,%eax
f0104c64:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104c69:	29 d0                	sub    %edx,%eax
		if(envs[i].env_status == ENV_RUNNABLE){
			//envs[i].env_cpunum = cpunum();
			env_run(&envs[i]);
		}
		firstEnv = false;
f0104c6b:	ba 00 00 00 00       	mov    $0x0,%edx
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c70:	84 d2                	test   %dl,%dl
f0104c72:	75 d0                	jne    f0104c44 <sched_yield+0x70>
f0104c74:	39 c8                	cmp    %ecx,%eax
f0104c76:	75 cc                	jne    f0104c44 <sched_yield+0x70>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e)
f0104c78:	85 db                	test   %ebx,%ebx
f0104c7a:	74 08                	je     f0104c84 <sched_yield+0xb0>
		env_run(e);
f0104c7c:	89 1c 24             	mov    %ebx,(%esp)
f0104c7f:	e8 a0 f0 ff ff       	call   f0103d24 <env_run>
	


  
	// sched_halt never returns
	sched_halt();
f0104c84:	e8 73 fe ff ff       	call   f0104afc <sched_halt>
	}
f0104c89:	83 c4 1c             	add    $0x1c,%esp
f0104c8c:	5b                   	pop    %ebx
f0104c8d:	5e                   	pop    %esi
f0104c8e:	5f                   	pop    %edi
f0104c8f:	5d                   	pop    %ebp
f0104c90:	c3                   	ret    
	...

f0104ca0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ca0:	55                   	push   %ebp
f0104ca1:	89 e5                	mov    %esp,%ebp
f0104ca3:	83 ec 48             	sub    $0x48,%esp
f0104ca6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104ca9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104cac:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104caf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cb5:	8b 75 10             	mov    0x10(%ebp),%esi
f0104cb8:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104cbb:	83 f8 0a             	cmp    $0xa,%eax
f0104cbe:	0f 87 c0 03 00 00    	ja     f0105084 <syscall+0x3e4>
f0104cc4:	ff 24 85 e0 80 10 f0 	jmp    *-0xfef7f20(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104ccb:	e8 24 16 00 00       	call   f01062f4 <cpunum>
f0104cd0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104cd7:	00 
f0104cd8:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104cdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ce0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104ce9:	89 04 24             	mov    %eax,(%esp)
f0104cec:	e8 28 e8 ff ff       	call   f0103519 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104cf1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104cf5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104cf9:	c7 04 24 a6 80 10 f0 	movl   $0xf01080a6,(%esp)
f0104d00:	e8 79 f2 ff ff       	call   f0103f7e <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104d05:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d0a:	e9 7a 03 00 00       	jmp    f0105089 <syscall+0x3e9>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d0f:	e8 15 b9 ff ff       	call   f0100629 <cons_getc>
f0104d14:	89 c3                	mov    %eax,%ebx
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104d16:	e9 6e 03 00 00       	jmp    f0105089 <syscall+0x3e9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d1b:	90                   	nop
f0104d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d20:	e8 cf 15 00 00       	call   f01062f4 <cpunum>
f0104d25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d28:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d2e:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104d31:	e9 53 03 00 00       	jmp    f0105089 <syscall+0x3e9>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d36:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d3d:	00 
f0104d3e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d45:	89 1c 24             	mov    %ebx,(%esp)
f0104d48:	e8 d0 e8 ff ff       	call   f010361d <envid2env>
f0104d4d:	89 c3                	mov    %eax,%ebx
f0104d4f:	85 c0                	test   %eax,%eax
f0104d51:	0f 88 32 03 00 00    	js     f0105089 <syscall+0x3e9>
		return r;
	if (e == curenv)
f0104d57:	e8 98 15 00 00       	call   f01062f4 <cpunum>
f0104d5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d62:	39 90 28 d0 22 f0    	cmp    %edx,-0xfdd2fd8(%eax)
f0104d68:	75 23                	jne    f0104d8d <syscall+0xed>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104d6a:	e8 85 15 00 00       	call   f01062f4 <cpunum>
f0104d6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d72:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d78:	8b 40 48             	mov    0x48(%eax),%eax
f0104d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d7f:	c7 04 24 ab 80 10 f0 	movl   $0xf01080ab,(%esp)
f0104d86:	e8 f3 f1 ff ff       	call   f0103f7e <cprintf>
f0104d8b:	eb 28                	jmp    f0104db5 <syscall+0x115>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104d8d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104d90:	e8 5f 15 00 00       	call   f01062f4 <cpunum>
f0104d95:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d99:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d9c:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104da2:	8b 40 48             	mov    0x48(%eax),%eax
f0104da5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104da9:	c7 04 24 c6 80 10 f0 	movl   $0xf01080c6,(%esp)
f0104db0:	e8 c9 f1 ff ff       	call   f0103f7e <cprintf>
	env_destroy(e);
f0104db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104db8:	89 04 24             	mov    %eax,(%esp)
f0104dbb:	e8 c3 ee ff ff       	call   f0103c83 <env_destroy>
	return 0;
f0104dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
						break;
f0104dc5:	e9 bf 02 00 00       	jmp    f0105089 <syscall+0x3e9>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104dca:	e8 05 fe ff ff       	call   f0104bd4 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	
	struct Env* childEnv=0;
f0104dcf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	struct Env* parentEnv = curenv;
f0104dd6:	e8 19 15 00 00       	call   f01062f4 <cpunum>
f0104ddb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dde:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104de4:	8b 46 48             	mov    0x48(%esi),%eax
f0104de7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104deb:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104dee:	89 04 24             	mov    %eax,(%esp)
f0104df1:	e8 3e e9 ff ff       	call   f0103734 <env_alloc>
f0104df6:	89 c3                	mov    %eax,%ebx
	if(r < 0)
f0104df8:	85 c0                	test   %eax,%eax
f0104dfa:	0f 88 89 02 00 00    	js     f0105089 <syscall+0x3e9>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104e00:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e03:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e08:	89 c7                	mov    %eax,%edi
f0104e0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104e0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e0f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104e16:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104e1d:	8b 58 48             	mov    0x48(%eax),%ebx
						break;
		case SYS_yield:      	sys_yield();	
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
f0104e20:	e9 64 02 00 00       	jmp    f0105089 <syscall+0x3e9>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e =0;
f0104e25:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104e2c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e33:	00 
f0104e34:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e3b:	89 1c 24             	mov    %ebx,(%esp)
f0104e3e:	e8 da e7 ff ff       	call   f010361d <envid2env>
f0104e43:	89 c3                	mov    %eax,%ebx
f0104e45:	85 c0                	test   %eax,%eax
f0104e47:	0f 88 3c 02 00 00    	js     f0105089 <syscall+0x3e9>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104e4d:	83 fe 02             	cmp    $0x2,%esi
f0104e50:	74 0e                	je     f0104e60 <syscall+0x1c0>
		return -E_INVAL;
f0104e52:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104e57:	83 fe 04             	cmp    $0x4,%esi
f0104e5a:	0f 85 29 02 00 00    	jne    f0105089 <syscall+0x3e9>
		return -E_INVAL;
	e->env_status = status;
f0104e60:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e63:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104e66:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e6b:	e9 19 02 00 00       	jmp    f0105089 <syscall+0x3e9>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e =0;
f0104e70:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104e77:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e7e:	00 
f0104e7f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e86:	89 1c 24             	mov    %ebx,(%esp)
f0104e89:	e8 8f e7 ff ff       	call   f010361d <envid2env>
f0104e8e:	89 c3                	mov    %eax,%ebx
f0104e90:	85 c0                	test   %eax,%eax
f0104e92:	0f 88 f1 01 00 00    	js     f0105089 <syscall+0x3e9>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104e98:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	// LAB 4: Your code here.
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104e9d:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ea3:	0f 87 e0 01 00 00    	ja     f0105089 <syscall+0x3e9>
f0104ea9:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104eaf:	0f 85 d4 01 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104eb5:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f0104ebb:	0f 85 c8 01 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104ec1:	89 f8                	mov    %edi,%eax
f0104ec3:	83 e0 05             	and    $0x5,%eax
f0104ec6:	83 f8 05             	cmp    $0x5,%eax
f0104ec9:	0f 85 ba 01 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104ecf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104ed6:	e8 7e c0 ff ff       	call   f0100f59 <page_alloc>
f0104edb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(page == 0)
f0104ede:	85 c0                	test   %eax,%eax
f0104ee0:	74 30                	je     f0104f12 <syscall+0x272>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104ee2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104ee6:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104eea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ef1:	8b 40 60             	mov    0x60(%eax),%eax
f0104ef4:	89 04 24             	mov    %eax,(%esp)
f0104ef7:	e8 53 c3 ff ff       	call   f010124f <page_insert>
f0104efc:	89 c3                	mov    %eax,%ebx
	if(r <0){
f0104efe:	85 c0                	test   %eax,%eax
f0104f00:	79 1a                	jns    f0104f1c <syscall+0x27c>
		page_free(page);
f0104f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f05:	89 04 24             	mov    %eax,(%esp)
f0104f08:	e8 d0 c0 ff ff       	call   f0100fdd <page_free>
f0104f0d:	e9 77 01 00 00       	jmp    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f0104f12:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104f17:	e9 6d 01 00 00       	jmp    f0105089 <syscall+0x3e9>
	r = page_insert(e->env_pgdir, page, va,perm);
	if(r <0){
		page_free(page);
		return r;
	}
	return 0;
f0104f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
f0104f21:	e9 63 01 00 00       	jmp    f0105089 <syscall+0x3e9>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
f0104f26:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0104f2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0104f34:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f3b:	00 
f0104f3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f43:	89 1c 24             	mov    %ebx,(%esp)
f0104f46:	e8 d2 e6 ff ff       	call   f010361d <envid2env>
f0104f4b:	89 c3                	mov    %eax,%ebx
f0104f4d:	85 c0                	test   %eax,%eax
f0104f4f:	0f 88 34 01 00 00    	js     f0105089 <syscall+0x3e9>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f0104f55:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f5c:	00 
f0104f5d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f64:	89 3c 24             	mov    %edi,(%esp)
f0104f67:	e8 b1 e6 ff ff       	call   f010361d <envid2env>
f0104f6c:	89 c3                	mov    %eax,%ebx
f0104f6e:	85 c0                	test   %eax,%eax
f0104f70:	0f 88 13 01 00 00    	js     f0105089 <syscall+0x3e9>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f0104f76:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f0104f7b:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f81:	0f 87 02 01 00 00    	ja     f0105089 <syscall+0x3e9>
f0104f87:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104f8d:	0f 85 f6 00 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f0104f93:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f9a:	0f 87 e9 00 00 00    	ja     f0105089 <syscall+0x3e9>
f0104fa0:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104fa7:	0f 85 dc 00 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f0104fad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f0104fb4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fbb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104fc2:	8b 40 60             	mov    0x60(%eax),%eax
f0104fc5:	89 04 24             	mov    %eax,(%esp)
f0104fc8:	e8 78 c1 ff ff       	call   f0101145 <page_lookup>
	if(page == 0)
f0104fcd:	85 c0                	test   %eax,%eax
f0104fcf:	74 5a                	je     f010502b <syscall+0x38b>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104fd1:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104fd8:	0f 85 ab 00 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104fde:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104fe1:	83 e2 05             	and    $0x5,%edx
f0104fe4:	83 fa 05             	cmp    $0x5,%edx
f0104fe7:	0f 85 9c 00 00 00    	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f0104fed:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104ff1:	74 0c                	je     f0104fff <syscall+0x35f>
f0104ff3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ff6:	f6 02 02             	testb  $0x2,(%edx)
f0104ff9:	0f 84 8a 00 00 00    	je     f0105089 <syscall+0x3e9>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f0104fff:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105002:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105006:	8b 55 18             	mov    0x18(%ebp),%edx
f0105009:	89 54 24 08          	mov    %edx,0x8(%esp)
f010500d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105011:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105014:	8b 40 60             	mov    0x60(%eax),%eax
f0105017:	89 04 24             	mov    %eax,(%esp)
f010501a:	e8 30 c2 ff ff       	call   f010124f <page_insert>
f010501f:	85 c0                	test   %eax,%eax
f0105021:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105026:	0f 4e d8             	cmovle %eax,%ebx
f0105029:	eb 5e                	jmp    f0105089 <syscall+0x3e9>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f010502b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105030:	eb 57                	jmp    f0105089 <syscall+0x3e9>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e =0;
f0105032:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0105039:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105040:	00 
f0105041:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105044:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105048:	89 1c 24             	mov    %ebx,(%esp)
f010504b:	e8 cd e5 ff ff       	call   f010361d <envid2env>
f0105050:	89 c3                	mov    %eax,%ebx
f0105052:	85 c0                	test   %eax,%eax
f0105054:	78 33                	js     f0105089 <syscall+0x3e9>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0105056:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	// LAB 4: Your code here.
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f010505b:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105061:	77 26                	ja     f0105089 <syscall+0x3e9>
f0105063:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105069:	75 1e                	jne    f0105089 <syscall+0x3e9>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f010506b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010506f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105072:	8b 40 60             	mov    0x60(%eax),%eax
f0105075:	89 04 24             	mov    %eax,(%esp)
f0105078:	e8 72 c1 ff ff       	call   f01011ef <page_remove>
	return 0;
f010507d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105082:	eb 05                	jmp    f0105089 <syscall+0x3e9>
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
		default:
			return -E_NO_SYS;
f0105084:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
	}
	return ret;
}
f0105089:	89 d8                	mov    %ebx,%eax
f010508b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010508e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105091:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105094:	89 ec                	mov    %ebp,%esp
f0105096:	5d                   	pop    %ebp
f0105097:	c3                   	ret    

f0105098 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105098:	55                   	push   %ebp
f0105099:	89 e5                	mov    %esp,%ebp
f010509b:	57                   	push   %edi
f010509c:	56                   	push   %esi
f010509d:	53                   	push   %ebx
f010509e:	83 ec 14             	sub    $0x14,%esp
f01050a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050a4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01050a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01050aa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01050ad:	8b 1a                	mov    (%edx),%ebx
f01050af:	8b 01                	mov    (%ecx),%eax
f01050b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01050b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01050bb:	e9 88 00 00 00       	jmp    f0105148 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01050c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050c3:	01 d8                	add    %ebx,%eax
f01050c5:	89 c7                	mov    %eax,%edi
f01050c7:	c1 ef 1f             	shr    $0x1f,%edi
f01050ca:	01 c7                	add    %eax,%edi
f01050cc:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050ce:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01050d1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050d4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01050d8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050da:	eb 03                	jmp    f01050df <stab_binsearch+0x47>
			m--;
f01050dc:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050df:	39 c3                	cmp    %eax,%ebx
f01050e1:	7f 1e                	jg     f0105101 <stab_binsearch+0x69>
f01050e3:	0f b6 0a             	movzbl (%edx),%ecx
f01050e6:	83 ea 0c             	sub    $0xc,%edx
f01050e9:	39 f1                	cmp    %esi,%ecx
f01050eb:	75 ef                	jne    f01050dc <stab_binsearch+0x44>
f01050ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01050f0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050f3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050f6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01050fa:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01050fd:	76 18                	jbe    f0105117 <stab_binsearch+0x7f>
f01050ff:	eb 05                	jmp    f0105106 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105101:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105104:	eb 42                	jmp    f0105148 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105106:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105109:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010510b:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010510e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105115:	eb 31                	jmp    f0105148 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105117:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010511a:	73 17                	jae    f0105133 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010511c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010511f:	83 e9 01             	sub    $0x1,%ecx
f0105122:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105125:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105128:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010512a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105131:	eb 15                	jmp    f0105148 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105133:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105136:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105139:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010513b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010513f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105141:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105148:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010514b:	0f 8e 6f ff ff ff    	jle    f01050c0 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105151:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105155:	75 0f                	jne    f0105166 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105157:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010515a:	8b 02                	mov    (%edx),%eax
f010515c:	83 e8 01             	sub    $0x1,%eax
f010515f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105162:	89 01                	mov    %eax,(%ecx)
f0105164:	eb 2c                	jmp    f0105192 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105166:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105169:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010516b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010516e:	8b 0a                	mov    (%edx),%ecx
f0105170:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105173:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105176:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010517a:	eb 03                	jmp    f010517f <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010517c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010517f:	39 c8                	cmp    %ecx,%eax
f0105181:	7e 0a                	jle    f010518d <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0105183:	0f b6 1a             	movzbl (%edx),%ebx
f0105186:	83 ea 0c             	sub    $0xc,%edx
f0105189:	39 f3                	cmp    %esi,%ebx
f010518b:	75 ef                	jne    f010517c <stab_binsearch+0xe4>
		     l--)
			/* do nothing */;
		*region_left = l;
f010518d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105190:	89 02                	mov    %eax,(%edx)
	}
}
f0105192:	83 c4 14             	add    $0x14,%esp
f0105195:	5b                   	pop    %ebx
f0105196:	5e                   	pop    %esi
f0105197:	5f                   	pop    %edi
f0105198:	5d                   	pop    %ebp
f0105199:	c3                   	ret    

f010519a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010519a:	55                   	push   %ebp
f010519b:	89 e5                	mov    %esp,%ebp
f010519d:	57                   	push   %edi
f010519e:	56                   	push   %esi
f010519f:	53                   	push   %ebx
f01051a0:	83 ec 5c             	sub    $0x5c,%esp
f01051a3:	8b 75 08             	mov    0x8(%ebp),%esi
f01051a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01051a9:	c7 03 0c 81 10 f0    	movl   $0xf010810c,(%ebx)
	info->eip_line = 0;
f01051af:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01051b6:	c7 43 08 0c 81 10 f0 	movl   $0xf010810c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01051bd:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01051c4:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01051c7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01051ce:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01051d4:	0f 87 d8 00 00 00    	ja     f01052b2 <debuginfo_eip+0x118>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01051da:	e8 15 11 00 00       	call   f01062f4 <cpunum>
f01051df:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01051e6:	00 
f01051e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01051ee:	00 
f01051ef:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01051f6:	00 
f01051f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01051fa:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105200:	89 04 24             	mov    %eax,(%esp)
f0105203:	e8 6f e2 ff ff       	call   f0103477 <user_mem_check>
f0105208:	89 c2                	mov    %eax,%edx
			return -1;
f010520a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010520f:	85 d2                	test   %edx,%edx
f0105211:	0f 85 47 02 00 00    	jne    f010545e <debuginfo_eip+0x2c4>
			return -1;

		stabs = usd->stabs;
f0105217:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010521d:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105220:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105226:	a1 08 00 20 00       	mov    0x200008,%eax
f010522b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010522e:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105234:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105237:	e8 b8 10 00 00       	call   f01062f4 <cpunum>
f010523c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105243:	00 
f0105244:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f010524b:	00 
f010524c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010524f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105253:	6b c0 74             	imul   $0x74,%eax,%eax
f0105256:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010525c:	89 04 24             	mov    %eax,(%esp)
f010525f:	e8 13 e2 ff ff       	call   f0103477 <user_mem_check>
f0105264:	89 c2                	mov    %eax,%edx
			return -1;
f0105266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010526b:	85 d2                	test   %edx,%edx
f010526d:	0f 85 eb 01 00 00    	jne    f010545e <debuginfo_eip+0x2c4>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105273:	e8 7c 10 00 00       	call   f01062f4 <cpunum>
f0105278:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010527f:	00 
f0105280:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105283:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105286:	89 54 24 08          	mov    %edx,0x8(%esp)
f010528a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010528d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105291:	6b c0 74             	imul   $0x74,%eax,%eax
f0105294:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010529a:	89 04 24             	mov    %eax,(%esp)
f010529d:	e8 d5 e1 ff ff       	call   f0103477 <user_mem_check>
f01052a2:	89 c2                	mov    %eax,%edx
			return -1;
f01052a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01052a9:	85 d2                	test   %edx,%edx
f01052ab:	74 1f                	je     f01052cc <debuginfo_eip+0x132>
f01052ad:	e9 ac 01 00 00       	jmp    f010545e <debuginfo_eip+0x2c4>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01052b2:	c7 45 c0 3a 66 11 f0 	movl   $0xf011663a,-0x40(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01052b9:	c7 45 bc 4d 2e 11 f0 	movl   $0xf0112e4d,-0x44(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01052c0:	bf 4c 2e 11 f0       	mov    $0xf0112e4c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01052c5:	c7 45 c4 ec 85 10 f0 	movl   $0xf01085ec,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01052cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01052d1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01052d4:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01052d7:	0f 83 81 01 00 00    	jae    f010545e <debuginfo_eip+0x2c4>
f01052dd:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01052e1:	0f 85 77 01 00 00    	jne    f010545e <debuginfo_eip+0x2c4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01052e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01052ee:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01052f1:	c1 ff 02             	sar    $0x2,%edi
f01052f4:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01052fa:	83 e8 01             	sub    $0x1,%eax
f01052fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105300:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105304:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010530b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010530e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105311:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105314:	e8 7f fd ff ff       	call   f0105098 <stab_binsearch>
	if (lfile == 0)
f0105319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010531c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0105321:	85 d2                	test   %edx,%edx
f0105323:	0f 84 35 01 00 00    	je     f010545e <debuginfo_eip+0x2c4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105329:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010532c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010532f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105332:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105336:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010533d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105340:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105343:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105346:	e8 4d fd ff ff       	call   f0105098 <stab_binsearch>

	if (lfun <= rfun) {
f010534b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010534e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105351:	39 d0                	cmp    %edx,%eax
f0105353:	7f 32                	jg     f0105387 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105355:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105358:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010535b:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010535e:	8b 39                	mov    (%ecx),%edi
f0105360:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105363:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105366:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105369:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010536c:	73 09                	jae    f0105377 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010536e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105371:	03 7d bc             	add    -0x44(%ebp),%edi
f0105374:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105377:	8b 49 08             	mov    0x8(%ecx),%ecx
f010537a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010537d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010537f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105382:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105385:	eb 0f                	jmp    f0105396 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105387:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010538a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010538d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105390:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105393:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105396:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010539d:	00 
f010539e:	8b 43 08             	mov    0x8(%ebx),%eax
f01053a1:	89 04 24             	mov    %eax,(%esp)
f01053a4:	e8 ce 08 00 00       	call   f0105c77 <strfind>
f01053a9:	2b 43 08             	sub    0x8(%ebx),%eax
f01053ac:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01053af:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053b3:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01053ba:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01053bd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01053c0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01053c3:	e8 d0 fc ff ff       	call   f0105098 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01053c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01053cb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01053ce:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01053d1:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01053d4:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01053d8:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01053db:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01053de:	83 c2 08             	add    $0x8,%edx
f01053e1:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01053e4:	eb 06                	jmp    f01053ec <debuginfo_eip+0x252>
f01053e6:	83 e8 01             	sub    $0x1,%eax
f01053e9:	83 ea 0c             	sub    $0xc,%edx
f01053ec:	89 c7                	mov    %eax,%edi
f01053ee:	39 c6                	cmp    %eax,%esi
f01053f0:	7f 22                	jg     f0105414 <debuginfo_eip+0x27a>
	       && stabs[lline].n_type != N_SOL
f01053f2:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
f01053f6:	80 f9 84             	cmp    $0x84,%cl
f01053f9:	74 6b                	je     f0105466 <debuginfo_eip+0x2cc>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01053fb:	80 f9 64             	cmp    $0x64,%cl
f01053fe:	75 e6                	jne    f01053e6 <debuginfo_eip+0x24c>
f0105400:	83 3a 00             	cmpl   $0x0,(%edx)
f0105403:	74 e1                	je     f01053e6 <debuginfo_eip+0x24c>
f0105405:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105408:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010540b:	eb 5f                	jmp    f010546c <debuginfo_eip+0x2d2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010540d:	03 45 bc             	add    -0x44(%ebp),%eax
f0105410:	89 03                	mov    %eax,(%ebx)
f0105412:	eb 03                	jmp    f0105417 <debuginfo_eip+0x27d>
f0105414:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105417:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010541a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010541d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105422:	39 ca                	cmp    %ecx,%edx
f0105424:	7d 38                	jge    f010545e <debuginfo_eip+0x2c4>
		for (lline = lfun + 1;
f0105426:	83 c2 01             	add    $0x1,%edx
f0105429:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010542c:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010542e:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105431:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105434:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105438:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010543a:	eb 04                	jmp    f0105440 <debuginfo_eip+0x2a6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010543c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105440:	39 f0                	cmp    %esi,%eax
f0105442:	7d 15                	jge    f0105459 <debuginfo_eip+0x2bf>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105444:	0f b6 0a             	movzbl (%edx),%ecx
f0105447:	83 c0 01             	add    $0x1,%eax
f010544a:	83 c2 0c             	add    $0xc,%edx
f010544d:	80 f9 a0             	cmp    $0xa0,%cl
f0105450:	74 ea                	je     f010543c <debuginfo_eip+0x2a2>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105452:	b8 00 00 00 00       	mov    $0x0,%eax
f0105457:	eb 05                	jmp    f010545e <debuginfo_eip+0x2c4>
f0105459:	b8 00 00 00 00       	mov    $0x0,%eax
f010545e:	83 c4 5c             	add    $0x5c,%esp
f0105461:	5b                   	pop    %ebx
f0105462:	5e                   	pop    %esi
f0105463:	5f                   	pop    %edi
f0105464:	5d                   	pop    %ebp
f0105465:	c3                   	ret    
f0105466:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105469:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010546c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010546f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105472:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105475:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105478:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010547b:	39 d0                	cmp    %edx,%eax
f010547d:	72 8e                	jb     f010540d <debuginfo_eip+0x273>
f010547f:	eb 96                	jmp    f0105417 <debuginfo_eip+0x27d>
	...

f0105490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105490:	55                   	push   %ebp
f0105491:	89 e5                	mov    %esp,%ebp
f0105493:	57                   	push   %edi
f0105494:	56                   	push   %esi
f0105495:	53                   	push   %ebx
f0105496:	83 ec 3c             	sub    $0x3c,%esp
f0105499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010549c:	89 d7                	mov    %edx,%edi
f010549e:	8b 45 08             	mov    0x8(%ebp),%eax
f01054a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01054a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01054ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01054b0:	85 c0                	test   %eax,%eax
f01054b2:	75 08                	jne    f01054bc <printnum+0x2c>
f01054b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054b7:	39 45 10             	cmp    %eax,0x10(%ebp)
f01054ba:	77 59                	ja     f0105515 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01054bc:	89 74 24 10          	mov    %esi,0x10(%esp)
f01054c0:	83 eb 01             	sub    $0x1,%ebx
f01054c3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01054c7:	8b 45 10             	mov    0x10(%ebp),%eax
f01054ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054ce:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01054d2:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01054d6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01054dd:	00 
f01054de:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054e1:	89 04 24             	mov    %eax,(%esp)
f01054e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054eb:	e8 70 12 00 00       	call   f0106760 <__udivdi3>
f01054f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01054f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01054f8:	89 04 24             	mov    %eax,(%esp)
f01054fb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01054ff:	89 fa                	mov    %edi,%edx
f0105501:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105504:	e8 87 ff ff ff       	call   f0105490 <printnum>
f0105509:	eb 11                	jmp    f010551c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010550b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010550f:	89 34 24             	mov    %esi,(%esp)
f0105512:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105515:	83 eb 01             	sub    $0x1,%ebx
f0105518:	85 db                	test   %ebx,%ebx
f010551a:	7f ef                	jg     f010550b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010551c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105520:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105524:	8b 45 10             	mov    0x10(%ebp),%eax
f0105527:	89 44 24 08          	mov    %eax,0x8(%esp)
f010552b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105532:	00 
f0105533:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105536:	89 04 24             	mov    %eax,(%esp)
f0105539:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010553c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105540:	e8 4b 13 00 00       	call   f0106890 <__umoddi3>
f0105545:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105549:	0f be 80 16 81 10 f0 	movsbl -0xfef7eea(%eax),%eax
f0105550:	89 04 24             	mov    %eax,(%esp)
f0105553:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105556:	83 c4 3c             	add    $0x3c,%esp
f0105559:	5b                   	pop    %ebx
f010555a:	5e                   	pop    %esi
f010555b:	5f                   	pop    %edi
f010555c:	5d                   	pop    %ebp
f010555d:	c3                   	ret    

f010555e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010555e:	55                   	push   %ebp
f010555f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105561:	83 fa 01             	cmp    $0x1,%edx
f0105564:	7e 0e                	jle    f0105574 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105566:	8b 10                	mov    (%eax),%edx
f0105568:	8d 4a 08             	lea    0x8(%edx),%ecx
f010556b:	89 08                	mov    %ecx,(%eax)
f010556d:	8b 02                	mov    (%edx),%eax
f010556f:	8b 52 04             	mov    0x4(%edx),%edx
f0105572:	eb 22                	jmp    f0105596 <getuint+0x38>
	else if (lflag)
f0105574:	85 d2                	test   %edx,%edx
f0105576:	74 10                	je     f0105588 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105578:	8b 10                	mov    (%eax),%edx
f010557a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010557d:	89 08                	mov    %ecx,(%eax)
f010557f:	8b 02                	mov    (%edx),%eax
f0105581:	ba 00 00 00 00       	mov    $0x0,%edx
f0105586:	eb 0e                	jmp    f0105596 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105588:	8b 10                	mov    (%eax),%edx
f010558a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010558d:	89 08                	mov    %ecx,(%eax)
f010558f:	8b 02                	mov    (%edx),%eax
f0105591:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105596:	5d                   	pop    %ebp
f0105597:	c3                   	ret    

f0105598 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105598:	55                   	push   %ebp
f0105599:	89 e5                	mov    %esp,%ebp
f010559b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010559e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01055a2:	8b 10                	mov    (%eax),%edx
f01055a4:	3b 50 04             	cmp    0x4(%eax),%edx
f01055a7:	73 0a                	jae    f01055b3 <sprintputch+0x1b>
		*b->buf++ = ch;
f01055a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055ac:	88 0a                	mov    %cl,(%edx)
f01055ae:	83 c2 01             	add    $0x1,%edx
f01055b1:	89 10                	mov    %edx,(%eax)
}
f01055b3:	5d                   	pop    %ebp
f01055b4:	c3                   	ret    

f01055b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01055b5:	55                   	push   %ebp
f01055b6:	89 e5                	mov    %esp,%ebp
f01055b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01055bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01055be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01055c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01055c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01055d3:	89 04 24             	mov    %eax,(%esp)
f01055d6:	e8 02 00 00 00       	call   f01055dd <vprintfmt>
	va_end(ap);
}
f01055db:	c9                   	leave  
f01055dc:	c3                   	ret    

f01055dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01055dd:	55                   	push   %ebp
f01055de:	89 e5                	mov    %esp,%ebp
f01055e0:	57                   	push   %edi
f01055e1:	56                   	push   %esi
f01055e2:	53                   	push   %ebx
f01055e3:	83 ec 4c             	sub    $0x4c,%esp
f01055e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01055e9:	8b 75 10             	mov    0x10(%ebp),%esi
f01055ec:	eb 12                	jmp    f0105600 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01055ee:	85 c0                	test   %eax,%eax
f01055f0:	0f 84 bf 03 00 00    	je     f01059b5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f01055f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055fa:	89 04 24             	mov    %eax,(%esp)
f01055fd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105600:	0f b6 06             	movzbl (%esi),%eax
f0105603:	83 c6 01             	add    $0x1,%esi
f0105606:	83 f8 25             	cmp    $0x25,%eax
f0105609:	75 e3                	jne    f01055ee <vprintfmt+0x11>
f010560b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f010560f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105616:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010561b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105622:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105627:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010562a:	eb 2b                	jmp    f0105657 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010562c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010562f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105633:	eb 22                	jmp    f0105657 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105638:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010563c:	eb 19                	jmp    f0105657 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010563e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105648:	eb 0d                	jmp    f0105657 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010564a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010564d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105650:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105657:	0f b6 16             	movzbl (%esi),%edx
f010565a:	0f b6 c2             	movzbl %dl,%eax
f010565d:	8d 7e 01             	lea    0x1(%esi),%edi
f0105660:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0105663:	83 ea 23             	sub    $0x23,%edx
f0105666:	80 fa 55             	cmp    $0x55,%dl
f0105669:	0f 87 28 03 00 00    	ja     f0105997 <vprintfmt+0x3ba>
f010566f:	0f b6 d2             	movzbl %dl,%edx
f0105672:	ff 24 95 e0 81 10 f0 	jmp    *-0xfef7e20(,%edx,4)
f0105679:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010567c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0105683:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105688:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010568b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010568f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105692:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105695:	83 fa 09             	cmp    $0x9,%edx
f0105698:	77 2f                	ja     f01056c9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010569a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010569d:	eb e9                	jmp    f0105688 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010569f:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a2:	8d 50 04             	lea    0x4(%eax),%edx
f01056a5:	89 55 14             	mov    %edx,0x14(%ebp)
f01056a8:	8b 00                	mov    (%eax),%eax
f01056aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01056b0:	eb 1a                	jmp    f01056cc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f01056b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01056b9:	79 9c                	jns    f0105657 <vprintfmt+0x7a>
f01056bb:	eb 81                	jmp    f010563e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01056c0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01056c7:	eb 8e                	jmp    f0105657 <vprintfmt+0x7a>
f01056c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f01056cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01056d0:	79 85                	jns    f0105657 <vprintfmt+0x7a>
f01056d2:	e9 73 ff ff ff       	jmp    f010564a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01056d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01056dd:	e9 75 ff ff ff       	jmp    f0105657 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01056e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e5:	8d 50 04             	lea    0x4(%eax),%edx
f01056e8:	89 55 14             	mov    %edx,0x14(%ebp)
f01056eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01056ef:	8b 00                	mov    (%eax),%eax
f01056f1:	89 04 24             	mov    %eax,(%esp)
f01056f4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01056fa:	e9 01 ff ff ff       	jmp    f0105600 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01056ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105702:	8d 50 04             	lea    0x4(%eax),%edx
f0105705:	89 55 14             	mov    %edx,0x14(%ebp)
f0105708:	8b 00                	mov    (%eax),%eax
f010570a:	89 c2                	mov    %eax,%edx
f010570c:	c1 fa 1f             	sar    $0x1f,%edx
f010570f:	31 d0                	xor    %edx,%eax
f0105711:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105713:	83 f8 09             	cmp    $0x9,%eax
f0105716:	7f 0b                	jg     f0105723 <vprintfmt+0x146>
f0105718:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f010571f:	85 d2                	test   %edx,%edx
f0105721:	75 23                	jne    f0105746 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f0105723:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105727:	c7 44 24 08 2e 81 10 	movl   $0xf010812e,0x8(%esp)
f010572e:	f0 
f010572f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105733:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105736:	89 3c 24             	mov    %edi,(%esp)
f0105739:	e8 77 fe ff ff       	call   f01055b5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010573e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105741:	e9 ba fe ff ff       	jmp    f0105600 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105746:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010574a:	c7 44 24 08 81 78 10 	movl   $0xf0107881,0x8(%esp)
f0105751:	f0 
f0105752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105756:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105759:	89 3c 24             	mov    %edi,(%esp)
f010575c:	e8 54 fe ff ff       	call   f01055b5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105761:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105764:	e9 97 fe ff ff       	jmp    f0105600 <vprintfmt+0x23>
f0105769:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010576c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010576f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105772:	8b 45 14             	mov    0x14(%ebp),%eax
f0105775:	8d 50 04             	lea    0x4(%eax),%edx
f0105778:	89 55 14             	mov    %edx,0x14(%ebp)
f010577b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010577d:	85 f6                	test   %esi,%esi
f010577f:	ba 27 81 10 f0       	mov    $0xf0108127,%edx
f0105784:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0105787:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010578b:	0f 8e 8c 00 00 00    	jle    f010581d <vprintfmt+0x240>
f0105791:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105795:	0f 84 82 00 00 00    	je     f010581d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f010579b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010579f:	89 34 24             	mov    %esi,(%esp)
f01057a2:	e8 81 03 00 00       	call   f0105b28 <strnlen>
f01057a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01057aa:	29 c2                	sub    %eax,%edx
f01057ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f01057af:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01057b3:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01057b6:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01057b9:	89 de                	mov    %ebx,%esi
f01057bb:	89 d3                	mov    %edx,%ebx
f01057bd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01057bf:	eb 0d                	jmp    f01057ce <vprintfmt+0x1f1>
					putch(padc, putdat);
f01057c1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057c5:	89 3c 24             	mov    %edi,(%esp)
f01057c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01057cb:	83 eb 01             	sub    $0x1,%ebx
f01057ce:	85 db                	test   %ebx,%ebx
f01057d0:	7f ef                	jg     f01057c1 <vprintfmt+0x1e4>
f01057d2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01057d5:	89 f3                	mov    %esi,%ebx
f01057d7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f01057da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01057de:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f01057e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01057ea:	29 c2                	sub    %eax,%edx
f01057ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01057ef:	eb 2c                	jmp    f010581d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01057f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01057f5:	74 18                	je     f010580f <vprintfmt+0x232>
f01057f7:	8d 50 e0             	lea    -0x20(%eax),%edx
f01057fa:	83 fa 5e             	cmp    $0x5e,%edx
f01057fd:	76 10                	jbe    f010580f <vprintfmt+0x232>
					putch('?', putdat);
f01057ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105803:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010580a:	ff 55 08             	call   *0x8(%ebp)
f010580d:	eb 0a                	jmp    f0105819 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f010580f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105813:	89 04 24             	mov    %eax,(%esp)
f0105816:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105819:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010581d:	0f be 06             	movsbl (%esi),%eax
f0105820:	83 c6 01             	add    $0x1,%esi
f0105823:	85 c0                	test   %eax,%eax
f0105825:	74 25                	je     f010584c <vprintfmt+0x26f>
f0105827:	85 ff                	test   %edi,%edi
f0105829:	78 c6                	js     f01057f1 <vprintfmt+0x214>
f010582b:	83 ef 01             	sub    $0x1,%edi
f010582e:	79 c1                	jns    f01057f1 <vprintfmt+0x214>
f0105830:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105833:	89 de                	mov    %ebx,%esi
f0105835:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105838:	eb 1a                	jmp    f0105854 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010583a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010583e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105845:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105847:	83 eb 01             	sub    $0x1,%ebx
f010584a:	eb 08                	jmp    f0105854 <vprintfmt+0x277>
f010584c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010584f:	89 de                	mov    %ebx,%esi
f0105851:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105854:	85 db                	test   %ebx,%ebx
f0105856:	7f e2                	jg     f010583a <vprintfmt+0x25d>
f0105858:	89 7d 08             	mov    %edi,0x8(%ebp)
f010585b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010585d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105860:	e9 9b fd ff ff       	jmp    f0105600 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105865:	83 f9 01             	cmp    $0x1,%ecx
f0105868:	7e 10                	jle    f010587a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f010586a:	8b 45 14             	mov    0x14(%ebp),%eax
f010586d:	8d 50 08             	lea    0x8(%eax),%edx
f0105870:	89 55 14             	mov    %edx,0x14(%ebp)
f0105873:	8b 30                	mov    (%eax),%esi
f0105875:	8b 78 04             	mov    0x4(%eax),%edi
f0105878:	eb 26                	jmp    f01058a0 <vprintfmt+0x2c3>
	else if (lflag)
f010587a:	85 c9                	test   %ecx,%ecx
f010587c:	74 12                	je     f0105890 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f010587e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105881:	8d 50 04             	lea    0x4(%eax),%edx
f0105884:	89 55 14             	mov    %edx,0x14(%ebp)
f0105887:	8b 30                	mov    (%eax),%esi
f0105889:	89 f7                	mov    %esi,%edi
f010588b:	c1 ff 1f             	sar    $0x1f,%edi
f010588e:	eb 10                	jmp    f01058a0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f0105890:	8b 45 14             	mov    0x14(%ebp),%eax
f0105893:	8d 50 04             	lea    0x4(%eax),%edx
f0105896:	89 55 14             	mov    %edx,0x14(%ebp)
f0105899:	8b 30                	mov    (%eax),%esi
f010589b:	89 f7                	mov    %esi,%edi
f010589d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01058a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01058a5:	85 ff                	test   %edi,%edi
f01058a7:	0f 89 ac 00 00 00    	jns    f0105959 <vprintfmt+0x37c>
				putch('-', putdat);
f01058ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01058b8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01058bb:	f7 de                	neg    %esi
f01058bd:	83 d7 00             	adc    $0x0,%edi
f01058c0:	f7 df                	neg    %edi
			}
			base = 10;
f01058c2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058c7:	e9 8d 00 00 00       	jmp    f0105959 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01058cc:	89 ca                	mov    %ecx,%edx
f01058ce:	8d 45 14             	lea    0x14(%ebp),%eax
f01058d1:	e8 88 fc ff ff       	call   f010555e <getuint>
f01058d6:	89 c6                	mov    %eax,%esi
f01058d8:	89 d7                	mov    %edx,%edi
			base = 10;
f01058da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01058df:	eb 78                	jmp    f0105959 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01058e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058e5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01058ec:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01058ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01058fa:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01058fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105901:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105908:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010590b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010590e:	e9 ed fc ff ff       	jmp    f0105600 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0105913:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105917:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010591e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105925:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010592c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010592f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105932:	8d 50 04             	lea    0x4(%eax),%edx
f0105935:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105938:	8b 30                	mov    (%eax),%esi
f010593a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010593f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105944:	eb 13                	jmp    f0105959 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105946:	89 ca                	mov    %ecx,%edx
f0105948:	8d 45 14             	lea    0x14(%ebp),%eax
f010594b:	e8 0e fc ff ff       	call   f010555e <getuint>
f0105950:	89 c6                	mov    %eax,%esi
f0105952:	89 d7                	mov    %edx,%edi
			base = 16;
f0105954:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105959:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f010595d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105961:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105964:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105968:	89 44 24 08          	mov    %eax,0x8(%esp)
f010596c:	89 34 24             	mov    %esi,(%esp)
f010596f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105973:	89 da                	mov    %ebx,%edx
f0105975:	8b 45 08             	mov    0x8(%ebp),%eax
f0105978:	e8 13 fb ff ff       	call   f0105490 <printnum>
			break;
f010597d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105980:	e9 7b fc ff ff       	jmp    f0105600 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105985:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105989:	89 04 24             	mov    %eax,(%esp)
f010598c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010598f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105992:	e9 69 fc ff ff       	jmp    f0105600 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105997:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010599b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01059a2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01059a5:	eb 03                	jmp    f01059aa <vprintfmt+0x3cd>
f01059a7:	83 ee 01             	sub    $0x1,%esi
f01059aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01059ae:	75 f7                	jne    f01059a7 <vprintfmt+0x3ca>
f01059b0:	e9 4b fc ff ff       	jmp    f0105600 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01059b5:	83 c4 4c             	add    $0x4c,%esp
f01059b8:	5b                   	pop    %ebx
f01059b9:	5e                   	pop    %esi
f01059ba:	5f                   	pop    %edi
f01059bb:	5d                   	pop    %ebp
f01059bc:	c3                   	ret    

f01059bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01059bd:	55                   	push   %ebp
f01059be:	89 e5                	mov    %esp,%ebp
f01059c0:	83 ec 28             	sub    $0x28,%esp
f01059c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01059c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01059c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01059cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01059d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01059d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01059da:	85 c0                	test   %eax,%eax
f01059dc:	74 30                	je     f0105a0e <vsnprintf+0x51>
f01059de:	85 d2                	test   %edx,%edx
f01059e0:	7e 2c                	jle    f0105a0e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01059e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01059e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01059ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01059f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059f7:	c7 04 24 98 55 10 f0 	movl   $0xf0105598,(%esp)
f01059fe:	e8 da fb ff ff       	call   f01055dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a0c:	eb 05                	jmp    f0105a13 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105a13:	c9                   	leave  
f0105a14:	c3                   	ret    

f0105a15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a15:	55                   	push   %ebp
f0105a16:	89 e5                	mov    %esp,%ebp
f0105a18:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a1b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a22:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a30:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a33:	89 04 24             	mov    %eax,(%esp)
f0105a36:	e8 82 ff ff ff       	call   f01059bd <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a3b:	c9                   	leave  
f0105a3c:	c3                   	ret    
f0105a3d:	00 00                	add    %al,(%eax)
	...

f0105a40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a40:	55                   	push   %ebp
f0105a41:	89 e5                	mov    %esp,%ebp
f0105a43:	57                   	push   %edi
f0105a44:	56                   	push   %esi
f0105a45:	53                   	push   %ebx
f0105a46:	83 ec 1c             	sub    $0x1c,%esp
f0105a49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105a4c:	85 c0                	test   %eax,%eax
f0105a4e:	74 10                	je     f0105a60 <readline+0x20>
		cprintf("%s", prompt);
f0105a50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a54:	c7 04 24 81 78 10 f0 	movl   $0xf0107881,(%esp)
f0105a5b:	e8 1e e5 ff ff       	call   f0103f7e <cprintf>

	i = 0;
	echoing = iscons(0);
f0105a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105a67:	e8 2f ad ff ff       	call   f010079b <iscons>
f0105a6c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105a6e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105a73:	e8 12 ad ff ff       	call   f010078a <getchar>
f0105a78:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105a7a:	85 c0                	test   %eax,%eax
f0105a7c:	79 17                	jns    f0105a95 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a82:	c7 04 24 68 83 10 f0 	movl   $0xf0108368,(%esp)
f0105a89:	e8 f0 e4 ff ff       	call   f0103f7e <cprintf>
			return NULL;
f0105a8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a93:	eb 6d                	jmp    f0105b02 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105a95:	83 f8 08             	cmp    $0x8,%eax
f0105a98:	74 05                	je     f0105a9f <readline+0x5f>
f0105a9a:	83 f8 7f             	cmp    $0x7f,%eax
f0105a9d:	75 19                	jne    f0105ab8 <readline+0x78>
f0105a9f:	85 f6                	test   %esi,%esi
f0105aa1:	7e 15                	jle    f0105ab8 <readline+0x78>
			if (echoing)
f0105aa3:	85 ff                	test   %edi,%edi
f0105aa5:	74 0c                	je     f0105ab3 <readline+0x73>
				cputchar('\b');
f0105aa7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105aae:	e8 c7 ac ff ff       	call   f010077a <cputchar>
			i--;
f0105ab3:	83 ee 01             	sub    $0x1,%esi
f0105ab6:	eb bb                	jmp    f0105a73 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ab8:	83 fb 1f             	cmp    $0x1f,%ebx
f0105abb:	7e 1f                	jle    f0105adc <readline+0x9c>
f0105abd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105ac3:	7f 17                	jg     f0105adc <readline+0x9c>
			if (echoing)
f0105ac5:	85 ff                	test   %edi,%edi
f0105ac7:	74 08                	je     f0105ad1 <readline+0x91>
				cputchar(c);
f0105ac9:	89 1c 24             	mov    %ebx,(%esp)
f0105acc:	e8 a9 ac ff ff       	call   f010077a <cputchar>
			buf[i++] = c;
f0105ad1:	88 9e 80 ca 22 f0    	mov    %bl,-0xfdd3580(%esi)
f0105ad7:	83 c6 01             	add    $0x1,%esi
f0105ada:	eb 97                	jmp    f0105a73 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105adc:	83 fb 0a             	cmp    $0xa,%ebx
f0105adf:	74 05                	je     f0105ae6 <readline+0xa6>
f0105ae1:	83 fb 0d             	cmp    $0xd,%ebx
f0105ae4:	75 8d                	jne    f0105a73 <readline+0x33>
			if (echoing)
f0105ae6:	85 ff                	test   %edi,%edi
f0105ae8:	74 0c                	je     f0105af6 <readline+0xb6>
				cputchar('\n');
f0105aea:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105af1:	e8 84 ac ff ff       	call   f010077a <cputchar>
			buf[i] = 0;
f0105af6:	c6 86 80 ca 22 f0 00 	movb   $0x0,-0xfdd3580(%esi)
			return buf;
f0105afd:	b8 80 ca 22 f0       	mov    $0xf022ca80,%eax
		}
	}
}
f0105b02:	83 c4 1c             	add    $0x1c,%esp
f0105b05:	5b                   	pop    %ebx
f0105b06:	5e                   	pop    %esi
f0105b07:	5f                   	pop    %edi
f0105b08:	5d                   	pop    %ebp
f0105b09:	c3                   	ret    
f0105b0a:	00 00                	add    %al,(%eax)
f0105b0c:	00 00                	add    %al,(%eax)
	...

f0105b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b10:	55                   	push   %ebp
f0105b11:	89 e5                	mov    %esp,%ebp
f0105b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b16:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b1b:	eb 03                	jmp    f0105b20 <strlen+0x10>
		n++;
f0105b1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b24:	75 f7                	jne    f0105b1d <strlen+0xd>
		n++;
	return n;
}
f0105b26:	5d                   	pop    %ebp
f0105b27:	c3                   	ret    

f0105b28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b28:	55                   	push   %ebp
f0105b29:	89 e5                	mov    %esp,%ebp
f0105b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b31:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b36:	eb 03                	jmp    f0105b3b <strnlen+0x13>
		n++;
f0105b38:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b3b:	39 d0                	cmp    %edx,%eax
f0105b3d:	74 06                	je     f0105b45 <strnlen+0x1d>
f0105b3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105b43:	75 f3                	jne    f0105b38 <strnlen+0x10>
		n++;
	return n;
}
f0105b45:	5d                   	pop    %ebp
f0105b46:	c3                   	ret    

f0105b47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105b47:	55                   	push   %ebp
f0105b48:	89 e5                	mov    %esp,%ebp
f0105b4a:	53                   	push   %ebx
f0105b4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105b51:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b56:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105b5a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105b5d:	83 c2 01             	add    $0x1,%edx
f0105b60:	84 c9                	test   %cl,%cl
f0105b62:	75 f2                	jne    f0105b56 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105b64:	5b                   	pop    %ebx
f0105b65:	5d                   	pop    %ebp
f0105b66:	c3                   	ret    

f0105b67 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105b67:	55                   	push   %ebp
f0105b68:	89 e5                	mov    %esp,%ebp
f0105b6a:	53                   	push   %ebx
f0105b6b:	83 ec 08             	sub    $0x8,%esp
f0105b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105b71:	89 1c 24             	mov    %ebx,(%esp)
f0105b74:	e8 97 ff ff ff       	call   f0105b10 <strlen>
	strcpy(dst + len, src);
f0105b79:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b80:	01 d8                	add    %ebx,%eax
f0105b82:	89 04 24             	mov    %eax,(%esp)
f0105b85:	e8 bd ff ff ff       	call   f0105b47 <strcpy>
	return dst;
}
f0105b8a:	89 d8                	mov    %ebx,%eax
f0105b8c:	83 c4 08             	add    $0x8,%esp
f0105b8f:	5b                   	pop    %ebx
f0105b90:	5d                   	pop    %ebp
f0105b91:	c3                   	ret    

f0105b92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105b92:	55                   	push   %ebp
f0105b93:	89 e5                	mov    %esp,%ebp
f0105b95:	56                   	push   %esi
f0105b96:	53                   	push   %ebx
f0105b97:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b9d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105ba5:	eb 0f                	jmp    f0105bb6 <strncpy+0x24>
		*dst++ = *src;
f0105ba7:	0f b6 1a             	movzbl (%edx),%ebx
f0105baa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105bad:	80 3a 01             	cmpb   $0x1,(%edx)
f0105bb0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105bb3:	83 c1 01             	add    $0x1,%ecx
f0105bb6:	39 f1                	cmp    %esi,%ecx
f0105bb8:	75 ed                	jne    f0105ba7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105bba:	5b                   	pop    %ebx
f0105bbb:	5e                   	pop    %esi
f0105bbc:	5d                   	pop    %ebp
f0105bbd:	c3                   	ret    

f0105bbe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105bbe:	55                   	push   %ebp
f0105bbf:	89 e5                	mov    %esp,%ebp
f0105bc1:	56                   	push   %esi
f0105bc2:	53                   	push   %ebx
f0105bc3:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105bc9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105bcc:	89 f0                	mov    %esi,%eax
f0105bce:	85 d2                	test   %edx,%edx
f0105bd0:	75 0a                	jne    f0105bdc <strlcpy+0x1e>
f0105bd2:	eb 1d                	jmp    f0105bf1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105bd4:	88 18                	mov    %bl,(%eax)
f0105bd6:	83 c0 01             	add    $0x1,%eax
f0105bd9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105bdc:	83 ea 01             	sub    $0x1,%edx
f0105bdf:	74 0b                	je     f0105bec <strlcpy+0x2e>
f0105be1:	0f b6 19             	movzbl (%ecx),%ebx
f0105be4:	84 db                	test   %bl,%bl
f0105be6:	75 ec                	jne    f0105bd4 <strlcpy+0x16>
f0105be8:	89 c2                	mov    %eax,%edx
f0105bea:	eb 02                	jmp    f0105bee <strlcpy+0x30>
f0105bec:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105bee:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105bf1:	29 f0                	sub    %esi,%eax
}
f0105bf3:	5b                   	pop    %ebx
f0105bf4:	5e                   	pop    %esi
f0105bf5:	5d                   	pop    %ebp
f0105bf6:	c3                   	ret    

f0105bf7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105bf7:	55                   	push   %ebp
f0105bf8:	89 e5                	mov    %esp,%ebp
f0105bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c00:	eb 06                	jmp    f0105c08 <strcmp+0x11>
		p++, q++;
f0105c02:	83 c1 01             	add    $0x1,%ecx
f0105c05:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105c08:	0f b6 01             	movzbl (%ecx),%eax
f0105c0b:	84 c0                	test   %al,%al
f0105c0d:	74 04                	je     f0105c13 <strcmp+0x1c>
f0105c0f:	3a 02                	cmp    (%edx),%al
f0105c11:	74 ef                	je     f0105c02 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c13:	0f b6 c0             	movzbl %al,%eax
f0105c16:	0f b6 12             	movzbl (%edx),%edx
f0105c19:	29 d0                	sub    %edx,%eax
}
f0105c1b:	5d                   	pop    %ebp
f0105c1c:	c3                   	ret    

f0105c1d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c1d:	55                   	push   %ebp
f0105c1e:	89 e5                	mov    %esp,%ebp
f0105c20:	53                   	push   %ebx
f0105c21:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c27:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105c2a:	eb 09                	jmp    f0105c35 <strncmp+0x18>
		n--, p++, q++;
f0105c2c:	83 ea 01             	sub    $0x1,%edx
f0105c2f:	83 c0 01             	add    $0x1,%eax
f0105c32:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c35:	85 d2                	test   %edx,%edx
f0105c37:	74 15                	je     f0105c4e <strncmp+0x31>
f0105c39:	0f b6 18             	movzbl (%eax),%ebx
f0105c3c:	84 db                	test   %bl,%bl
f0105c3e:	74 04                	je     f0105c44 <strncmp+0x27>
f0105c40:	3a 19                	cmp    (%ecx),%bl
f0105c42:	74 e8                	je     f0105c2c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c44:	0f b6 00             	movzbl (%eax),%eax
f0105c47:	0f b6 11             	movzbl (%ecx),%edx
f0105c4a:	29 d0                	sub    %edx,%eax
f0105c4c:	eb 05                	jmp    f0105c53 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105c4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105c53:	5b                   	pop    %ebx
f0105c54:	5d                   	pop    %ebp
f0105c55:	c3                   	ret    

f0105c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105c56:	55                   	push   %ebp
f0105c57:	89 e5                	mov    %esp,%ebp
f0105c59:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105c60:	eb 07                	jmp    f0105c69 <strchr+0x13>
		if (*s == c)
f0105c62:	38 ca                	cmp    %cl,%dl
f0105c64:	74 0f                	je     f0105c75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105c66:	83 c0 01             	add    $0x1,%eax
f0105c69:	0f b6 10             	movzbl (%eax),%edx
f0105c6c:	84 d2                	test   %dl,%dl
f0105c6e:	75 f2                	jne    f0105c62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c75:	5d                   	pop    %ebp
f0105c76:	c3                   	ret    

f0105c77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105c77:	55                   	push   %ebp
f0105c78:	89 e5                	mov    %esp,%ebp
f0105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105c81:	eb 07                	jmp    f0105c8a <strfind+0x13>
		if (*s == c)
f0105c83:	38 ca                	cmp    %cl,%dl
f0105c85:	74 0a                	je     f0105c91 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105c87:	83 c0 01             	add    $0x1,%eax
f0105c8a:	0f b6 10             	movzbl (%eax),%edx
f0105c8d:	84 d2                	test   %dl,%dl
f0105c8f:	75 f2                	jne    f0105c83 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105c91:	5d                   	pop    %ebp
f0105c92:	c3                   	ret    

f0105c93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105c93:	55                   	push   %ebp
f0105c94:	89 e5                	mov    %esp,%ebp
f0105c96:	83 ec 0c             	sub    $0xc,%esp
f0105c99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105c9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105c9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ca8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105cab:	85 c9                	test   %ecx,%ecx
f0105cad:	74 30                	je     f0105cdf <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105cb5:	75 25                	jne    f0105cdc <memset+0x49>
f0105cb7:	f6 c1 03             	test   $0x3,%cl
f0105cba:	75 20                	jne    f0105cdc <memset+0x49>
		c &= 0xFF;
f0105cbc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105cbf:	89 d3                	mov    %edx,%ebx
f0105cc1:	c1 e3 08             	shl    $0x8,%ebx
f0105cc4:	89 d6                	mov    %edx,%esi
f0105cc6:	c1 e6 18             	shl    $0x18,%esi
f0105cc9:	89 d0                	mov    %edx,%eax
f0105ccb:	c1 e0 10             	shl    $0x10,%eax
f0105cce:	09 f0                	or     %esi,%eax
f0105cd0:	09 d0                	or     %edx,%eax
f0105cd2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105cd4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105cd7:	fc                   	cld    
f0105cd8:	f3 ab                	rep stos %eax,%es:(%edi)
f0105cda:	eb 03                	jmp    f0105cdf <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105cdc:	fc                   	cld    
f0105cdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105cdf:	89 f8                	mov    %edi,%eax
f0105ce1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105ce4:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105ce7:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105cea:	89 ec                	mov    %ebp,%esp
f0105cec:	5d                   	pop    %ebp
f0105ced:	c3                   	ret    

f0105cee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105cee:	55                   	push   %ebp
f0105cef:	89 e5                	mov    %esp,%ebp
f0105cf1:	83 ec 08             	sub    $0x8,%esp
f0105cf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105cf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105cfa:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d03:	39 c6                	cmp    %eax,%esi
f0105d05:	73 36                	jae    f0105d3d <memmove+0x4f>
f0105d07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d0a:	39 d0                	cmp    %edx,%eax
f0105d0c:	73 2f                	jae    f0105d3d <memmove+0x4f>
		s += n;
		d += n;
f0105d0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d11:	f6 c2 03             	test   $0x3,%dl
f0105d14:	75 1b                	jne    f0105d31 <memmove+0x43>
f0105d16:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d1c:	75 13                	jne    f0105d31 <memmove+0x43>
f0105d1e:	f6 c1 03             	test   $0x3,%cl
f0105d21:	75 0e                	jne    f0105d31 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105d23:	83 ef 04             	sub    $0x4,%edi
f0105d26:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105d29:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105d2c:	fd                   	std    
f0105d2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d2f:	eb 09                	jmp    f0105d3a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105d31:	83 ef 01             	sub    $0x1,%edi
f0105d34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105d37:	fd                   	std    
f0105d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105d3a:	fc                   	cld    
f0105d3b:	eb 20                	jmp    f0105d5d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105d43:	75 13                	jne    f0105d58 <memmove+0x6a>
f0105d45:	a8 03                	test   $0x3,%al
f0105d47:	75 0f                	jne    f0105d58 <memmove+0x6a>
f0105d49:	f6 c1 03             	test   $0x3,%cl
f0105d4c:	75 0a                	jne    f0105d58 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105d4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105d51:	89 c7                	mov    %eax,%edi
f0105d53:	fc                   	cld    
f0105d54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d56:	eb 05                	jmp    f0105d5d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105d58:	89 c7                	mov    %eax,%edi
f0105d5a:	fc                   	cld    
f0105d5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105d5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105d60:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105d63:	89 ec                	mov    %ebp,%esp
f0105d65:	5d                   	pop    %ebp
f0105d66:	c3                   	ret    

f0105d67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105d67:	55                   	push   %ebp
f0105d68:	89 e5                	mov    %esp,%ebp
f0105d6a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105d6d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d70:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d7e:	89 04 24             	mov    %eax,(%esp)
f0105d81:	e8 68 ff ff ff       	call   f0105cee <memmove>
}
f0105d86:	c9                   	leave  
f0105d87:	c3                   	ret    

f0105d88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105d88:	55                   	push   %ebp
f0105d89:	89 e5                	mov    %esp,%ebp
f0105d8b:	57                   	push   %edi
f0105d8c:	56                   	push   %esi
f0105d8d:	53                   	push   %ebx
f0105d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d91:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105d97:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d9c:	eb 1a                	jmp    f0105db8 <memcmp+0x30>
		if (*s1 != *s2)
f0105d9e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0105da2:	83 c2 01             	add    $0x1,%edx
f0105da5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0105daa:	38 c8                	cmp    %cl,%al
f0105dac:	74 0a                	je     f0105db8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f0105dae:	0f b6 c0             	movzbl %al,%eax
f0105db1:	0f b6 c9             	movzbl %cl,%ecx
f0105db4:	29 c8                	sub    %ecx,%eax
f0105db6:	eb 09                	jmp    f0105dc1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105db8:	39 da                	cmp    %ebx,%edx
f0105dba:	75 e2                	jne    f0105d9e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dc1:	5b                   	pop    %ebx
f0105dc2:	5e                   	pop    %esi
f0105dc3:	5f                   	pop    %edi
f0105dc4:	5d                   	pop    %ebp
f0105dc5:	c3                   	ret    

f0105dc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105dc6:	55                   	push   %ebp
f0105dc7:	89 e5                	mov    %esp,%ebp
f0105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105dcf:	89 c2                	mov    %eax,%edx
f0105dd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105dd4:	eb 07                	jmp    f0105ddd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105dd6:	38 08                	cmp    %cl,(%eax)
f0105dd8:	74 07                	je     f0105de1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105dda:	83 c0 01             	add    $0x1,%eax
f0105ddd:	39 d0                	cmp    %edx,%eax
f0105ddf:	72 f5                	jb     f0105dd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105de1:	5d                   	pop    %ebp
f0105de2:	c3                   	ret    

f0105de3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105de3:	55                   	push   %ebp
f0105de4:	89 e5                	mov    %esp,%ebp
f0105de6:	57                   	push   %edi
f0105de7:	56                   	push   %esi
f0105de8:	53                   	push   %ebx
f0105de9:	8b 55 08             	mov    0x8(%ebp),%edx
f0105dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105def:	eb 03                	jmp    f0105df4 <strtol+0x11>
		s++;
f0105df1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105df4:	0f b6 02             	movzbl (%edx),%eax
f0105df7:	3c 20                	cmp    $0x20,%al
f0105df9:	74 f6                	je     f0105df1 <strtol+0xe>
f0105dfb:	3c 09                	cmp    $0x9,%al
f0105dfd:	74 f2                	je     f0105df1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105dff:	3c 2b                	cmp    $0x2b,%al
f0105e01:	75 0a                	jne    f0105e0d <strtol+0x2a>
		s++;
f0105e03:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e06:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e0b:	eb 10                	jmp    f0105e1d <strtol+0x3a>
f0105e0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105e12:	3c 2d                	cmp    $0x2d,%al
f0105e14:	75 07                	jne    f0105e1d <strtol+0x3a>
		s++, neg = 1;
f0105e16:	8d 52 01             	lea    0x1(%edx),%edx
f0105e19:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e1d:	85 db                	test   %ebx,%ebx
f0105e1f:	0f 94 c0             	sete   %al
f0105e22:	74 05                	je     f0105e29 <strtol+0x46>
f0105e24:	83 fb 10             	cmp    $0x10,%ebx
f0105e27:	75 15                	jne    f0105e3e <strtol+0x5b>
f0105e29:	80 3a 30             	cmpb   $0x30,(%edx)
f0105e2c:	75 10                	jne    f0105e3e <strtol+0x5b>
f0105e2e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105e32:	75 0a                	jne    f0105e3e <strtol+0x5b>
		s += 2, base = 16;
f0105e34:	83 c2 02             	add    $0x2,%edx
f0105e37:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105e3c:	eb 13                	jmp    f0105e51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105e3e:	84 c0                	test   %al,%al
f0105e40:	74 0f                	je     f0105e51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105e42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105e47:	80 3a 30             	cmpb   $0x30,(%edx)
f0105e4a:	75 05                	jne    f0105e51 <strtol+0x6e>
		s++, base = 8;
f0105e4c:	83 c2 01             	add    $0x1,%edx
f0105e4f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0105e51:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105e58:	0f b6 0a             	movzbl (%edx),%ecx
f0105e5b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105e5e:	80 fb 09             	cmp    $0x9,%bl
f0105e61:	77 08                	ja     f0105e6b <strtol+0x88>
			dig = *s - '0';
f0105e63:	0f be c9             	movsbl %cl,%ecx
f0105e66:	83 e9 30             	sub    $0x30,%ecx
f0105e69:	eb 1e                	jmp    f0105e89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105e6b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105e6e:	80 fb 19             	cmp    $0x19,%bl
f0105e71:	77 08                	ja     f0105e7b <strtol+0x98>
			dig = *s - 'a' + 10;
f0105e73:	0f be c9             	movsbl %cl,%ecx
f0105e76:	83 e9 57             	sub    $0x57,%ecx
f0105e79:	eb 0e                	jmp    f0105e89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105e7b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105e7e:	80 fb 19             	cmp    $0x19,%bl
f0105e81:	77 14                	ja     f0105e97 <strtol+0xb4>
			dig = *s - 'A' + 10;
f0105e83:	0f be c9             	movsbl %cl,%ecx
f0105e86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105e89:	39 f1                	cmp    %esi,%ecx
f0105e8b:	7d 0e                	jge    f0105e9b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f0105e8d:	83 c2 01             	add    $0x1,%edx
f0105e90:	0f af c6             	imul   %esi,%eax
f0105e93:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105e95:	eb c1                	jmp    f0105e58 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105e97:	89 c1                	mov    %eax,%ecx
f0105e99:	eb 02                	jmp    f0105e9d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105e9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105e9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ea1:	74 05                	je     f0105ea8 <strtol+0xc5>
		*endptr = (char *) s;
f0105ea3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ea6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105ea8:	89 ca                	mov    %ecx,%edx
f0105eaa:	f7 da                	neg    %edx
f0105eac:	85 ff                	test   %edi,%edi
f0105eae:	0f 45 c2             	cmovne %edx,%eax
}
f0105eb1:	5b                   	pop    %ebx
f0105eb2:	5e                   	pop    %esi
f0105eb3:	5f                   	pop    %edi
f0105eb4:	5d                   	pop    %ebp
f0105eb5:	c3                   	ret    
	...

f0105eb8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105eb8:	fa                   	cli    

	xorw    %ax, %ax
f0105eb9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105ebb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ebd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ebf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ec1:	0f 01 16             	lgdtl  (%esi)
f0105ec4:	74 70                	je     f0105f36 <mpentry_end+0x4>
	movl    %cr0, %eax
f0105ec6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105ec9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105ecd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105ed0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105ed6:	08 00                	or     %al,(%eax)

f0105ed8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105ed8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105edc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ede:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ee0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105ee2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105ee6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ee8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105eea:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105eef:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105ef2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105ef5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105efa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105efd:	8b 25 84 ce 22 f0    	mov    0xf022ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f03:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f08:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0105f0d:	ff d0                	call   *%eax

f0105f0f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f0f:	eb fe                	jmp    f0105f0f <spin>
f0105f11:	8d 76 00             	lea    0x0(%esi),%esi

f0105f14 <gdt>:
	...
f0105f1c:	ff                   	(bad)  
f0105f1d:	ff 00                	incl   (%eax)
f0105f1f:	00 00                	add    %al,(%eax)
f0105f21:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105f28:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105f2c <gdtdesc>:
f0105f2c:	17                   	pop    %ss
f0105f2d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105f32 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105f32:	90                   	nop
	...

f0105f40 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105f40:	55                   	push   %ebp
f0105f41:	89 e5                	mov    %esp,%ebp
f0105f43:	56                   	push   %esi
f0105f44:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0105f45:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105f4a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105f4f:	eb 09                	jmp    f0105f5a <sum+0x1a>
		sum += ((uint8_t *)addr)[i];
f0105f51:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105f55:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f57:	83 c1 01             	add    $0x1,%ecx
f0105f5a:	39 d1                	cmp    %edx,%ecx
f0105f5c:	7c f3                	jl     f0105f51 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105f5e:	89 d8                	mov    %ebx,%eax
f0105f60:	5b                   	pop    %ebx
f0105f61:	5e                   	pop    %esi
f0105f62:	5d                   	pop    %ebp
f0105f63:	c3                   	ret    

f0105f64 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105f64:	55                   	push   %ebp
f0105f65:	89 e5                	mov    %esp,%ebp
f0105f67:	56                   	push   %esi
f0105f68:	53                   	push   %ebx
f0105f69:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f6c:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f0105f72:	89 c3                	mov    %eax,%ebx
f0105f74:	c1 eb 0c             	shr    $0xc,%ebx
f0105f77:	39 cb                	cmp    %ecx,%ebx
f0105f79:	72 20                	jb     f0105f9b <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f7f:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0105f86:	f0 
f0105f87:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105f8e:	00 
f0105f8f:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f0105f96:	e8 a5 a0 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105f9b:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f9e:	89 f2                	mov    %esi,%edx
f0105fa0:	c1 ea 0c             	shr    $0xc,%edx
f0105fa3:	39 d1                	cmp    %edx,%ecx
f0105fa5:	77 20                	ja     f0105fc7 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fa7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105fab:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0105fb2:	f0 
f0105fb3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105fba:	00 
f0105fbb:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f0105fc2:	e8 79 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105fc7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105fcd:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105fd3:	eb 2f                	jmp    f0106004 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105fd5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105fdc:	00 
f0105fdd:	c7 44 24 04 15 85 10 	movl   $0xf0108515,0x4(%esp)
f0105fe4:	f0 
f0105fe5:	89 1c 24             	mov    %ebx,(%esp)
f0105fe8:	e8 9b fd ff ff       	call   f0105d88 <memcmp>
f0105fed:	85 c0                	test   %eax,%eax
f0105fef:	75 10                	jne    f0106001 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0105ff1:	ba 10 00 00 00       	mov    $0x10,%edx
f0105ff6:	89 d8                	mov    %ebx,%eax
f0105ff8:	e8 43 ff ff ff       	call   f0105f40 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ffd:	84 c0                	test   %al,%al
f0105fff:	74 0c                	je     f010600d <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106001:	83 c3 10             	add    $0x10,%ebx
f0106004:	39 f3                	cmp    %esi,%ebx
f0106006:	72 cd                	jb     f0105fd5 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106008:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010600d:	89 d8                	mov    %ebx,%eax
f010600f:	83 c4 10             	add    $0x10,%esp
f0106012:	5b                   	pop    %ebx
f0106013:	5e                   	pop    %esi
f0106014:	5d                   	pop    %ebp
f0106015:	c3                   	ret    

f0106016 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106016:	55                   	push   %ebp
f0106017:	89 e5                	mov    %esp,%ebp
f0106019:	57                   	push   %edi
f010601a:	56                   	push   %esi
f010601b:	53                   	push   %ebx
f010601c:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010601f:	c7 05 c0 d3 22 f0 20 	movl   $0xf022d020,0xf022d3c0
f0106026:	d0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106029:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f0106030:	75 24                	jne    f0106056 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106032:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106039:	00 
f010603a:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0106041:	f0 
f0106042:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106049:	00 
f010604a:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f0106051:	e8 ea 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106056:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010605d:	85 c0                	test   %eax,%eax
f010605f:	74 16                	je     f0106077 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106061:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106064:	ba 00 04 00 00       	mov    $0x400,%edx
f0106069:	e8 f6 fe ff ff       	call   f0105f64 <mpsearch1>
f010606e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106071:	85 c0                	test   %eax,%eax
f0106073:	75 3c                	jne    f01060b1 <mp_init+0x9b>
f0106075:	eb 20                	jmp    f0106097 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106077:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010607e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106081:	2d 00 04 00 00       	sub    $0x400,%eax
f0106086:	ba 00 04 00 00       	mov    $0x400,%edx
f010608b:	e8 d4 fe ff ff       	call   f0105f64 <mpsearch1>
f0106090:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106093:	85 c0                	test   %eax,%eax
f0106095:	75 1a                	jne    f01060b1 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106097:	ba 00 00 01 00       	mov    $0x10000,%edx
f010609c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01060a1:	e8 be fe ff ff       	call   f0105f64 <mpsearch1>
f01060a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01060a9:	85 c0                	test   %eax,%eax
f01060ab:	0f 84 21 02 00 00    	je     f01062d2 <mp_init+0x2bc>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01060b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060b4:	8b 78 04             	mov    0x4(%eax),%edi
f01060b7:	85 ff                	test   %edi,%edi
f01060b9:	74 06                	je     f01060c1 <mp_init+0xab>
f01060bb:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01060bf:	74 11                	je     f01060d2 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01060c1:	c7 04 24 78 83 10 f0 	movl   $0xf0108378,(%esp)
f01060c8:	e8 b1 de ff ff       	call   f0103f7e <cprintf>
f01060cd:	e9 00 02 00 00       	jmp    f01062d2 <mp_init+0x2bc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01060d2:	89 f8                	mov    %edi,%eax
f01060d4:	c1 e8 0c             	shr    $0xc,%eax
f01060d7:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01060dd:	72 20                	jb     f01060ff <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060df:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01060e3:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01060ea:	f0 
f01060eb:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01060f2:	00 
f01060f3:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f01060fa:	e8 41 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060ff:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106105:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010610c:	00 
f010610d:	c7 44 24 04 1a 85 10 	movl   $0xf010851a,0x4(%esp)
f0106114:	f0 
f0106115:	89 3c 24             	mov    %edi,(%esp)
f0106118:	e8 6b fc ff ff       	call   f0105d88 <memcmp>
f010611d:	85 c0                	test   %eax,%eax
f010611f:	74 11                	je     f0106132 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106121:	c7 04 24 a8 83 10 f0 	movl   $0xf01083a8,(%esp)
f0106128:	e8 51 de ff ff       	call   f0103f7e <cprintf>
f010612d:	e9 a0 01 00 00       	jmp    f01062d2 <mp_init+0x2bc>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106132:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106136:	0f b7 d3             	movzwl %bx,%edx
f0106139:	89 f8                	mov    %edi,%eax
f010613b:	e8 00 fe ff ff       	call   f0105f40 <sum>
f0106140:	84 c0                	test   %al,%al
f0106142:	74 11                	je     f0106155 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106144:	c7 04 24 dc 83 10 f0 	movl   $0xf01083dc,(%esp)
f010614b:	e8 2e de ff ff       	call   f0103f7e <cprintf>
f0106150:	e9 7d 01 00 00       	jmp    f01062d2 <mp_init+0x2bc>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106155:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106159:	3c 01                	cmp    $0x1,%al
f010615b:	74 1d                	je     f010617a <mp_init+0x164>
f010615d:	3c 04                	cmp    $0x4,%al
f010615f:	90                   	nop
f0106160:	74 18                	je     f010617a <mp_init+0x164>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106162:	0f b6 c0             	movzbl %al,%eax
f0106165:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106169:	c7 04 24 00 84 10 f0 	movl   $0xf0108400,(%esp)
f0106170:	e8 09 de ff ff       	call   f0103f7e <cprintf>
f0106175:	e9 58 01 00 00       	jmp    f01062d2 <mp_init+0x2bc>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010617a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010617e:	0f b7 db             	movzwl %bx,%ebx
f0106181:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0106184:	e8 b7 fd ff ff       	call   f0105f40 <sum>
f0106189:	02 47 2a             	add    0x2a(%edi),%al
f010618c:	84 c0                	test   %al,%al
f010618e:	74 11                	je     f01061a1 <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106190:	c7 04 24 20 84 10 f0 	movl   $0xf0108420,(%esp)
f0106197:	e8 e2 dd ff ff       	call   f0103f7e <cprintf>
f010619c:	e9 31 01 00 00       	jmp    f01062d2 <mp_init+0x2bc>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01061a1:	85 ff                	test   %edi,%edi
f01061a3:	0f 84 29 01 00 00    	je     f01062d2 <mp_init+0x2bc>
		return;
	ismp = 1;
f01061a9:	c7 05 00 d0 22 f0 01 	movl   $0x1,0xf022d000
f01061b0:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01061b3:	8b 47 24             	mov    0x24(%edi),%eax
f01061b6:	a3 00 e0 26 f0       	mov    %eax,0xf026e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01061bb:	8d 77 2c             	lea    0x2c(%edi),%esi
f01061be:	bb 00 00 00 00       	mov    $0x0,%ebx
f01061c3:	e9 83 00 00 00       	jmp    f010624b <mp_init+0x235>
		switch (*p) {
f01061c8:	0f b6 06             	movzbl (%esi),%eax
f01061cb:	84 c0                	test   %al,%al
f01061cd:	74 06                	je     f01061d5 <mp_init+0x1bf>
f01061cf:	3c 04                	cmp    $0x4,%al
f01061d1:	77 54                	ja     f0106227 <mp_init+0x211>
f01061d3:	eb 4d                	jmp    f0106222 <mp_init+0x20c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01061d5:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01061d9:	74 11                	je     f01061ec <mp_init+0x1d6>
				bootcpu = &cpus[ncpu];
f01061db:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f01061e2:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f01061e7:	a3 c0 d3 22 f0       	mov    %eax,0xf022d3c0
			if (ncpu < NCPU) {
f01061ec:	a1 c4 d3 22 f0       	mov    0xf022d3c4,%eax
f01061f1:	83 f8 07             	cmp    $0x7,%eax
f01061f4:	7f 13                	jg     f0106209 <mp_init+0x1f3>
				cpus[ncpu].cpu_id = ncpu;
f01061f6:	6b d0 74             	imul   $0x74,%eax,%edx
f01061f9:	88 82 20 d0 22 f0    	mov    %al,-0xfdd2fe0(%edx)
				ncpu++;
f01061ff:	83 c0 01             	add    $0x1,%eax
f0106202:	a3 c4 d3 22 f0       	mov    %eax,0xf022d3c4
f0106207:	eb 14                	jmp    f010621d <mp_init+0x207>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106209:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010620d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106211:	c7 04 24 50 84 10 f0 	movl   $0xf0108450,(%esp)
f0106218:	e8 61 dd ff ff       	call   f0103f7e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010621d:	83 c6 14             	add    $0x14,%esi
			continue;
f0106220:	eb 26                	jmp    f0106248 <mp_init+0x232>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106222:	83 c6 08             	add    $0x8,%esi
			continue;
f0106225:	eb 21                	jmp    f0106248 <mp_init+0x232>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106227:	0f b6 c0             	movzbl %al,%eax
f010622a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010622e:	c7 04 24 78 84 10 f0 	movl   $0xf0108478,(%esp)
f0106235:	e8 44 dd ff ff       	call   f0103f7e <cprintf>
			ismp = 0;
f010623a:	c7 05 00 d0 22 f0 00 	movl   $0x0,0xf022d000
f0106241:	00 00 00 
			i = conf->entry;
f0106244:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106248:	83 c3 01             	add    $0x1,%ebx
f010624b:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010624f:	39 c3                	cmp    %eax,%ebx
f0106251:	0f 82 71 ff ff ff    	jb     f01061c8 <mp_init+0x1b2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106257:	a1 c0 d3 22 f0       	mov    0xf022d3c0,%eax
f010625c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106263:	83 3d 00 d0 22 f0 00 	cmpl   $0x0,0xf022d000
f010626a:	75 22                	jne    f010628e <mp_init+0x278>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010626c:	c7 05 c4 d3 22 f0 01 	movl   $0x1,0xf022d3c4
f0106273:	00 00 00 
		lapicaddr = 0;
f0106276:	c7 05 00 e0 26 f0 00 	movl   $0x0,0xf026e000
f010627d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106280:	c7 04 24 98 84 10 f0 	movl   $0xf0108498,(%esp)
f0106287:	e8 f2 dc ff ff       	call   f0103f7e <cprintf>
		return;
f010628c:	eb 44                	jmp    f01062d2 <mp_init+0x2bc>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010628e:	8b 15 c4 d3 22 f0    	mov    0xf022d3c4,%edx
f0106294:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106298:	0f b6 00             	movzbl (%eax),%eax
f010629b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010629f:	c7 04 24 1f 85 10 f0 	movl   $0xf010851f,(%esp)
f01062a6:	e8 d3 dc ff ff       	call   f0103f7e <cprintf>

	if (mp->imcrp) {
f01062ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062ae:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01062b2:	74 1e                	je     f01062d2 <mp_init+0x2bc>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01062b4:	c7 04 24 c4 84 10 f0 	movl   $0xf01084c4,(%esp)
f01062bb:	e8 be dc ff ff       	call   f0103f7e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062c0:	ba 22 00 00 00       	mov    $0x22,%edx
f01062c5:	b8 70 00 00 00       	mov    $0x70,%eax
f01062ca:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01062cb:	b2 23                	mov    $0x23,%dl
f01062cd:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01062ce:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062d1:	ee                   	out    %al,(%dx)
	}
}
f01062d2:	83 c4 2c             	add    $0x2c,%esp
f01062d5:	5b                   	pop    %ebx
f01062d6:	5e                   	pop    %esi
f01062d7:	5f                   	pop    %edi
f01062d8:	5d                   	pop    %ebp
f01062d9:	c3                   	ret    
	...

f01062dc <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01062dc:	55                   	push   %ebp
f01062dd:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01062df:	c1 e0 02             	shl    $0x2,%eax
f01062e2:	03 05 04 e0 26 f0    	add    0xf026e004,%eax
f01062e8:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01062ea:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f01062ef:	8b 40 20             	mov    0x20(%eax),%eax
}
f01062f2:	5d                   	pop    %ebp
f01062f3:	c3                   	ret    

f01062f4 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01062f4:	55                   	push   %ebp
f01062f5:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01062f7:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
		return lapic[ID] >> 24;
	return 0;
f01062fd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106302:	85 d2                	test   %edx,%edx
f0106304:	74 06                	je     f010630c <cpunum+0x18>
		return lapic[ID] >> 24;
f0106306:	8b 42 20             	mov    0x20(%edx),%eax
f0106309:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010630c:	5d                   	pop    %ebp
f010630d:	c3                   	ret    

f010630e <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010630e:	55                   	push   %ebp
f010630f:	89 e5                	mov    %esp,%ebp
f0106311:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106314:	a1 00 e0 26 f0       	mov    0xf026e000,%eax
f0106319:	85 c0                	test   %eax,%eax
f010631b:	0f 84 1c 01 00 00    	je     f010643d <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106321:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106328:	00 
f0106329:	89 04 24             	mov    %eax,(%esp)
f010632c:	e8 bc af ff ff       	call   f01012ed <mmio_map_region>
f0106331:	a3 04 e0 26 f0       	mov    %eax,0xf026e004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106336:	ba 27 01 00 00       	mov    $0x127,%edx
f010633b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106340:	e8 97 ff ff ff       	call   f01062dc <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106345:	ba 0b 00 00 00       	mov    $0xb,%edx
f010634a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010634f:	e8 88 ff ff ff       	call   f01062dc <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106354:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106359:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010635e:	e8 79 ff ff ff       	call   f01062dc <lapicw>
	lapicw(TICR, 10000000); 
f0106363:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106368:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010636d:	e8 6a ff ff ff       	call   f01062dc <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106372:	e8 7d ff ff ff       	call   f01062f4 <cpunum>
f0106377:	6b c0 74             	imul   $0x74,%eax,%eax
f010637a:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f010637f:	39 05 c0 d3 22 f0    	cmp    %eax,0xf022d3c0
f0106385:	74 0f                	je     f0106396 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106387:	ba 00 00 01 00       	mov    $0x10000,%edx
f010638c:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106391:	e8 46 ff ff ff       	call   f01062dc <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106396:	ba 00 00 01 00       	mov    $0x10000,%edx
f010639b:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01063a0:	e8 37 ff ff ff       	call   f01062dc <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01063a5:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f01063aa:	8b 40 30             	mov    0x30(%eax),%eax
f01063ad:	c1 e8 10             	shr    $0x10,%eax
f01063b0:	3c 03                	cmp    $0x3,%al
f01063b2:	76 0f                	jbe    f01063c3 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01063b4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063b9:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01063be:	e8 19 ff ff ff       	call   f01062dc <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01063c3:	ba 33 00 00 00       	mov    $0x33,%edx
f01063c8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01063cd:	e8 0a ff ff ff       	call   f01062dc <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01063d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01063d7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01063dc:	e8 fb fe ff ff       	call   f01062dc <lapicw>
	lapicw(ESR, 0);
f01063e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01063e6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01063eb:	e8 ec fe ff ff       	call   f01062dc <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01063f0:	ba 00 00 00 00       	mov    $0x0,%edx
f01063f5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01063fa:	e8 dd fe ff ff       	call   f01062dc <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01063ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0106404:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106409:	e8 ce fe ff ff       	call   f01062dc <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010640e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106413:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106418:	e8 bf fe ff ff       	call   f01062dc <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010641d:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106423:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106429:	f6 c4 10             	test   $0x10,%ah
f010642c:	75 f5                	jne    f0106423 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010642e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106433:	b8 20 00 00 00       	mov    $0x20,%eax
f0106438:	e8 9f fe ff ff       	call   f01062dc <lapicw>
}
f010643d:	c9                   	leave  
f010643e:	c3                   	ret    

f010643f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010643f:	55                   	push   %ebp
f0106440:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106442:	83 3d 04 e0 26 f0 00 	cmpl   $0x0,0xf026e004
f0106449:	74 0f                	je     f010645a <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010644b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106450:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106455:	e8 82 fe ff ff       	call   f01062dc <lapicw>
}
f010645a:	5d                   	pop    %ebp
f010645b:	c3                   	ret    

f010645c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010645c:	55                   	push   %ebp
f010645d:	89 e5                	mov    %esp,%ebp
f010645f:	56                   	push   %esi
f0106460:	53                   	push   %ebx
f0106461:	83 ec 10             	sub    $0x10,%esp
f0106464:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106467:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f010646b:	ba 70 00 00 00       	mov    $0x70,%edx
f0106470:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106475:	ee                   	out    %al,(%dx)
f0106476:	b2 71                	mov    $0x71,%dl
f0106478:	b8 0a 00 00 00       	mov    $0xa,%eax
f010647d:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010647e:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f0106485:	75 24                	jne    f01064ab <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106487:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010648e:	00 
f010648f:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0106496:	f0 
f0106497:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010649e:	00 
f010649f:	c7 04 24 3c 85 10 f0 	movl   $0xf010853c,(%esp)
f01064a6:	e8 95 9b ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01064ab:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01064b2:	00 00 
	wrv[1] = addr >> 4;
f01064b4:	89 f0                	mov    %esi,%eax
f01064b6:	c1 e8 04             	shr    $0x4,%eax
f01064b9:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01064bf:	c1 e3 18             	shl    $0x18,%ebx
f01064c2:	89 da                	mov    %ebx,%edx
f01064c4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064c9:	e8 0e fe ff ff       	call   f01062dc <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01064ce:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01064d3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064d8:	e8 ff fd ff ff       	call   f01062dc <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01064dd:	ba 00 85 00 00       	mov    $0x8500,%edx
f01064e2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064e7:	e8 f0 fd ff ff       	call   f01062dc <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01064ec:	c1 ee 0c             	shr    $0xc,%esi
f01064ef:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01064f5:	89 da                	mov    %ebx,%edx
f01064f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064fc:	e8 db fd ff ff       	call   f01062dc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106501:	89 f2                	mov    %esi,%edx
f0106503:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106508:	e8 cf fd ff ff       	call   f01062dc <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010650d:	89 da                	mov    %ebx,%edx
f010650f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106514:	e8 c3 fd ff ff       	call   f01062dc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106519:	89 f2                	mov    %esi,%edx
f010651b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106520:	e8 b7 fd ff ff       	call   f01062dc <lapicw>
		microdelay(200);
	}
}
f0106525:	83 c4 10             	add    $0x10,%esp
f0106528:	5b                   	pop    %ebx
f0106529:	5e                   	pop    %esi
f010652a:	5d                   	pop    %ebp
f010652b:	c3                   	ret    

f010652c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010652c:	55                   	push   %ebp
f010652d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010652f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106532:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106538:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010653d:	e8 9a fd ff ff       	call   f01062dc <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106542:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106548:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010654e:	f6 c4 10             	test   $0x10,%ah
f0106551:	75 f5                	jne    f0106548 <lapic_ipi+0x1c>
		;
}
f0106553:	5d                   	pop    %ebp
f0106554:	c3                   	ret    
f0106555:	00 00                	add    %al,(%eax)
	...

f0106558 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106558:	55                   	push   %ebp
f0106559:	89 e5                	mov    %esp,%ebp
f010655b:	53                   	push   %ebx
f010655c:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010655f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106564:	83 38 00             	cmpl   $0x0,(%eax)
f0106567:	74 18                	je     f0106581 <holding+0x29>
f0106569:	8b 58 08             	mov    0x8(%eax),%ebx
f010656c:	e8 83 fd ff ff       	call   f01062f4 <cpunum>
f0106571:	6b c0 74             	imul   $0x74,%eax,%eax
f0106574:	05 20 d0 22 f0       	add    $0xf022d020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106579:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f010657b:	0f 94 c2             	sete   %dl
f010657e:	0f b6 d2             	movzbl %dl,%edx
}
f0106581:	89 d0                	mov    %edx,%eax
f0106583:	83 c4 04             	add    $0x4,%esp
f0106586:	5b                   	pop    %ebx
f0106587:	5d                   	pop    %ebp
f0106588:	c3                   	ret    

f0106589 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106589:	55                   	push   %ebp
f010658a:	89 e5                	mov    %esp,%ebp
f010658c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010658f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106595:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106598:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010659b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065a2:	5d                   	pop    %ebp
f01065a3:	c3                   	ret    

f01065a4 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01065a4:	55                   	push   %ebp
f01065a5:	89 e5                	mov    %esp,%ebp
f01065a7:	53                   	push   %ebx
f01065a8:	83 ec 24             	sub    $0x24,%esp
f01065ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01065ae:	89 d8                	mov    %ebx,%eax
f01065b0:	e8 a3 ff ff ff       	call   f0106558 <holding>
f01065b5:	85 c0                	test   %eax,%eax
f01065b7:	74 30                	je     f01065e9 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01065b9:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01065bc:	e8 33 fd ff ff       	call   f01062f4 <cpunum>
f01065c1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01065c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065c9:	c7 44 24 08 4c 85 10 	movl   $0xf010854c,0x8(%esp)
f01065d0:	f0 
f01065d1:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01065d8:	00 
f01065d9:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f01065e0:	e8 5b 9a ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01065e5:	f3 90                	pause  
f01065e7:	eb 05                	jmp    f01065ee <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01065e9:	ba 01 00 00 00       	mov    $0x1,%edx
f01065ee:	89 d0                	mov    %edx,%eax
f01065f0:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01065f3:	85 c0                	test   %eax,%eax
f01065f5:	75 ee                	jne    f01065e5 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01065f7:	e8 f8 fc ff ff       	call   f01062f4 <cpunum>
f01065fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01065ff:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106604:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106607:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010660a:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010660c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106611:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106617:	76 12                	jbe    f010662b <spin_lock+0x87>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106619:	8b 4a 04             	mov    0x4(%edx),%ecx
f010661c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010661f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106621:	83 c0 01             	add    $0x1,%eax
f0106624:	83 f8 0a             	cmp    $0xa,%eax
f0106627:	75 e8                	jne    f0106611 <spin_lock+0x6d>
f0106629:	eb 0f                	jmp    f010663a <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010662b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106632:	83 c0 01             	add    $0x1,%eax
f0106635:	83 f8 09             	cmp    $0x9,%eax
f0106638:	7e f1                	jle    f010662b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010663a:	83 c4 24             	add    $0x24,%esp
f010663d:	5b                   	pop    %ebx
f010663e:	5d                   	pop    %ebp
f010663f:	c3                   	ret    

f0106640 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106640:	55                   	push   %ebp
f0106641:	89 e5                	mov    %esp,%ebp
f0106643:	81 ec 88 00 00 00    	sub    $0x88,%esp
f0106649:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010664c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010664f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106652:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106655:	89 d8                	mov    %ebx,%eax
f0106657:	e8 fc fe ff ff       	call   f0106558 <holding>
f010665c:	85 c0                	test   %eax,%eax
f010665e:	0f 85 d3 00 00 00    	jne    f0106737 <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106664:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010666b:	00 
f010666c:	8d 43 0c             	lea    0xc(%ebx),%eax
f010666f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106673:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106676:	89 34 24             	mov    %esi,(%esp)
f0106679:	e8 70 f6 ff ff       	call   f0105cee <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010667e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106681:	0f b6 38             	movzbl (%eax),%edi
f0106684:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106687:	e8 68 fc ff ff       	call   f01062f4 <cpunum>
f010668c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106690:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106694:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106698:	c7 04 24 78 85 10 f0 	movl   $0xf0108578,(%esp)
f010669f:	e8 da d8 ff ff       	call   f0103f7e <cprintf>
f01066a4:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01066a6:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01066a9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066ac:	89 c7                	mov    %eax,%edi
f01066ae:	eb 63                	jmp    f0106713 <spin_unlock+0xd3>
f01066b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01066b4:	89 04 24             	mov    %eax,(%esp)
f01066b7:	e8 de ea ff ff       	call   f010519a <debuginfo_eip>
f01066bc:	85 c0                	test   %eax,%eax
f01066be:	78 39                	js     f01066f9 <spin_unlock+0xb9>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01066c0:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01066c2:	89 c2                	mov    %eax,%edx
f01066c4:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01066c7:	89 54 24 18          	mov    %edx,0x18(%esp)
f01066cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01066ce:	89 54 24 14          	mov    %edx,0x14(%esp)
f01066d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01066d5:	89 54 24 10          	mov    %edx,0x10(%esp)
f01066d9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01066dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01066e0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01066e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066eb:	c7 04 24 c0 85 10 f0 	movl   $0xf01085c0,(%esp)
f01066f2:	e8 87 d8 ff ff       	call   f0103f7e <cprintf>
f01066f7:	eb 12                	jmp    f010670b <spin_unlock+0xcb>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01066f9:	8b 06                	mov    (%esi),%eax
f01066fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066ff:	c7 04 24 d7 85 10 f0 	movl   $0xf01085d7,(%esp)
f0106706:	e8 73 d8 ff ff       	call   f0103f7e <cprintf>
f010670b:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010670e:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106711:	74 08                	je     f010671b <spin_unlock+0xdb>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106713:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106715:	8b 03                	mov    (%ebx),%eax
f0106717:	85 c0                	test   %eax,%eax
f0106719:	75 95                	jne    f01066b0 <spin_unlock+0x70>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010671b:	c7 44 24 08 df 85 10 	movl   $0xf01085df,0x8(%esp)
f0106722:	f0 
f0106723:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010672a:	00 
f010672b:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f0106732:	e8 09 99 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106737:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010673e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106745:	b8 00 00 00 00       	mov    $0x0,%eax
f010674a:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010674d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106750:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106753:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106756:	89 ec                	mov    %ebp,%esp
f0106758:	5d                   	pop    %ebp
f0106759:	c3                   	ret    
f010675a:	00 00                	add    %al,(%eax)
f010675c:	00 00                	add    %al,(%eax)
	...

f0106760 <__udivdi3>:
f0106760:	83 ec 1c             	sub    $0x1c,%esp
f0106763:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106767:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010676b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010676f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106773:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106777:	8b 74 24 24          	mov    0x24(%esp),%esi
f010677b:	85 ff                	test   %edi,%edi
f010677d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106781:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106785:	89 cd                	mov    %ecx,%ebp
f0106787:	89 44 24 04          	mov    %eax,0x4(%esp)
f010678b:	75 33                	jne    f01067c0 <__udivdi3+0x60>
f010678d:	39 f1                	cmp    %esi,%ecx
f010678f:	77 57                	ja     f01067e8 <__udivdi3+0x88>
f0106791:	85 c9                	test   %ecx,%ecx
f0106793:	75 0b                	jne    f01067a0 <__udivdi3+0x40>
f0106795:	b8 01 00 00 00       	mov    $0x1,%eax
f010679a:	31 d2                	xor    %edx,%edx
f010679c:	f7 f1                	div    %ecx
f010679e:	89 c1                	mov    %eax,%ecx
f01067a0:	89 f0                	mov    %esi,%eax
f01067a2:	31 d2                	xor    %edx,%edx
f01067a4:	f7 f1                	div    %ecx
f01067a6:	89 c6                	mov    %eax,%esi
f01067a8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01067ac:	f7 f1                	div    %ecx
f01067ae:	89 f2                	mov    %esi,%edx
f01067b0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01067b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01067b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01067bc:	83 c4 1c             	add    $0x1c,%esp
f01067bf:	c3                   	ret    
f01067c0:	31 d2                	xor    %edx,%edx
f01067c2:	31 c0                	xor    %eax,%eax
f01067c4:	39 f7                	cmp    %esi,%edi
f01067c6:	77 e8                	ja     f01067b0 <__udivdi3+0x50>
f01067c8:	0f bd cf             	bsr    %edi,%ecx
f01067cb:	83 f1 1f             	xor    $0x1f,%ecx
f01067ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01067d2:	75 2c                	jne    f0106800 <__udivdi3+0xa0>
f01067d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01067d8:	76 04                	jbe    f01067de <__udivdi3+0x7e>
f01067da:	39 f7                	cmp    %esi,%edi
f01067dc:	73 d2                	jae    f01067b0 <__udivdi3+0x50>
f01067de:	31 d2                	xor    %edx,%edx
f01067e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01067e5:	eb c9                	jmp    f01067b0 <__udivdi3+0x50>
f01067e7:	90                   	nop
f01067e8:	89 f2                	mov    %esi,%edx
f01067ea:	f7 f1                	div    %ecx
f01067ec:	31 d2                	xor    %edx,%edx
f01067ee:	8b 74 24 10          	mov    0x10(%esp),%esi
f01067f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01067f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01067fa:	83 c4 1c             	add    $0x1c,%esp
f01067fd:	c3                   	ret    
f01067fe:	66 90                	xchg   %ax,%ax
f0106800:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106805:	b8 20 00 00 00       	mov    $0x20,%eax
f010680a:	89 ea                	mov    %ebp,%edx
f010680c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106810:	d3 e7                	shl    %cl,%edi
f0106812:	89 c1                	mov    %eax,%ecx
f0106814:	d3 ea                	shr    %cl,%edx
f0106816:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010681b:	09 fa                	or     %edi,%edx
f010681d:	89 f7                	mov    %esi,%edi
f010681f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106823:	89 f2                	mov    %esi,%edx
f0106825:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106829:	d3 e5                	shl    %cl,%ebp
f010682b:	89 c1                	mov    %eax,%ecx
f010682d:	d3 ef                	shr    %cl,%edi
f010682f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106834:	d3 e2                	shl    %cl,%edx
f0106836:	89 c1                	mov    %eax,%ecx
f0106838:	d3 ee                	shr    %cl,%esi
f010683a:	09 d6                	or     %edx,%esi
f010683c:	89 fa                	mov    %edi,%edx
f010683e:	89 f0                	mov    %esi,%eax
f0106840:	f7 74 24 0c          	divl   0xc(%esp)
f0106844:	89 d7                	mov    %edx,%edi
f0106846:	89 c6                	mov    %eax,%esi
f0106848:	f7 e5                	mul    %ebp
f010684a:	39 d7                	cmp    %edx,%edi
f010684c:	72 22                	jb     f0106870 <__udivdi3+0x110>
f010684e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106852:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106857:	d3 e5                	shl    %cl,%ebp
f0106859:	39 c5                	cmp    %eax,%ebp
f010685b:	73 04                	jae    f0106861 <__udivdi3+0x101>
f010685d:	39 d7                	cmp    %edx,%edi
f010685f:	74 0f                	je     f0106870 <__udivdi3+0x110>
f0106861:	89 f0                	mov    %esi,%eax
f0106863:	31 d2                	xor    %edx,%edx
f0106865:	e9 46 ff ff ff       	jmp    f01067b0 <__udivdi3+0x50>
f010686a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106870:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106873:	31 d2                	xor    %edx,%edx
f0106875:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106879:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010687d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106881:	83 c4 1c             	add    $0x1c,%esp
f0106884:	c3                   	ret    
	...

f0106890 <__umoddi3>:
f0106890:	83 ec 1c             	sub    $0x1c,%esp
f0106893:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106897:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010689b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010689f:	89 74 24 10          	mov    %esi,0x10(%esp)
f01068a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01068a7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01068ab:	85 ed                	test   %ebp,%ebp
f01068ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01068b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01068b5:	89 cf                	mov    %ecx,%edi
f01068b7:	89 04 24             	mov    %eax,(%esp)
f01068ba:	89 f2                	mov    %esi,%edx
f01068bc:	75 1a                	jne    f01068d8 <__umoddi3+0x48>
f01068be:	39 f1                	cmp    %esi,%ecx
f01068c0:	76 4e                	jbe    f0106910 <__umoddi3+0x80>
f01068c2:	f7 f1                	div    %ecx
f01068c4:	89 d0                	mov    %edx,%eax
f01068c6:	31 d2                	xor    %edx,%edx
f01068c8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01068cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01068d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01068d4:	83 c4 1c             	add    $0x1c,%esp
f01068d7:	c3                   	ret    
f01068d8:	39 f5                	cmp    %esi,%ebp
f01068da:	77 54                	ja     f0106930 <__umoddi3+0xa0>
f01068dc:	0f bd c5             	bsr    %ebp,%eax
f01068df:	83 f0 1f             	xor    $0x1f,%eax
f01068e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068e6:	75 60                	jne    f0106948 <__umoddi3+0xb8>
f01068e8:	3b 0c 24             	cmp    (%esp),%ecx
f01068eb:	0f 87 07 01 00 00    	ja     f01069f8 <__umoddi3+0x168>
f01068f1:	89 f2                	mov    %esi,%edx
f01068f3:	8b 34 24             	mov    (%esp),%esi
f01068f6:	29 ce                	sub    %ecx,%esi
f01068f8:	19 ea                	sbb    %ebp,%edx
f01068fa:	89 34 24             	mov    %esi,(%esp)
f01068fd:	8b 04 24             	mov    (%esp),%eax
f0106900:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106904:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106908:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010690c:	83 c4 1c             	add    $0x1c,%esp
f010690f:	c3                   	ret    
f0106910:	85 c9                	test   %ecx,%ecx
f0106912:	75 0b                	jne    f010691f <__umoddi3+0x8f>
f0106914:	b8 01 00 00 00       	mov    $0x1,%eax
f0106919:	31 d2                	xor    %edx,%edx
f010691b:	f7 f1                	div    %ecx
f010691d:	89 c1                	mov    %eax,%ecx
f010691f:	89 f0                	mov    %esi,%eax
f0106921:	31 d2                	xor    %edx,%edx
f0106923:	f7 f1                	div    %ecx
f0106925:	8b 04 24             	mov    (%esp),%eax
f0106928:	f7 f1                	div    %ecx
f010692a:	eb 98                	jmp    f01068c4 <__umoddi3+0x34>
f010692c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106930:	89 f2                	mov    %esi,%edx
f0106932:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106936:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010693a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010693e:	83 c4 1c             	add    $0x1c,%esp
f0106941:	c3                   	ret    
f0106942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106948:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010694d:	89 e8                	mov    %ebp,%eax
f010694f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106954:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106958:	89 fa                	mov    %edi,%edx
f010695a:	d3 e0                	shl    %cl,%eax
f010695c:	89 e9                	mov    %ebp,%ecx
f010695e:	d3 ea                	shr    %cl,%edx
f0106960:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106965:	09 c2                	or     %eax,%edx
f0106967:	8b 44 24 08          	mov    0x8(%esp),%eax
f010696b:	89 14 24             	mov    %edx,(%esp)
f010696e:	89 f2                	mov    %esi,%edx
f0106970:	d3 e7                	shl    %cl,%edi
f0106972:	89 e9                	mov    %ebp,%ecx
f0106974:	d3 ea                	shr    %cl,%edx
f0106976:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010697b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010697f:	d3 e6                	shl    %cl,%esi
f0106981:	89 e9                	mov    %ebp,%ecx
f0106983:	d3 e8                	shr    %cl,%eax
f0106985:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010698a:	09 f0                	or     %esi,%eax
f010698c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106990:	f7 34 24             	divl   (%esp)
f0106993:	d3 e6                	shl    %cl,%esi
f0106995:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106999:	89 d6                	mov    %edx,%esi
f010699b:	f7 e7                	mul    %edi
f010699d:	39 d6                	cmp    %edx,%esi
f010699f:	89 c1                	mov    %eax,%ecx
f01069a1:	89 d7                	mov    %edx,%edi
f01069a3:	72 3f                	jb     f01069e4 <__umoddi3+0x154>
f01069a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01069a9:	72 35                	jb     f01069e0 <__umoddi3+0x150>
f01069ab:	8b 44 24 08          	mov    0x8(%esp),%eax
f01069af:	29 c8                	sub    %ecx,%eax
f01069b1:	19 fe                	sbb    %edi,%esi
f01069b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01069b8:	89 f2                	mov    %esi,%edx
f01069ba:	d3 e8                	shr    %cl,%eax
f01069bc:	89 e9                	mov    %ebp,%ecx
f01069be:	d3 e2                	shl    %cl,%edx
f01069c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01069c5:	09 d0                	or     %edx,%eax
f01069c7:	89 f2                	mov    %esi,%edx
f01069c9:	d3 ea                	shr    %cl,%edx
f01069cb:	8b 74 24 10          	mov    0x10(%esp),%esi
f01069cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01069d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01069d7:	83 c4 1c             	add    $0x1c,%esp
f01069da:	c3                   	ret    
f01069db:	90                   	nop
f01069dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069e0:	39 d6                	cmp    %edx,%esi
f01069e2:	75 c7                	jne    f01069ab <__umoddi3+0x11b>
f01069e4:	89 d7                	mov    %edx,%edi
f01069e6:	89 c1                	mov    %eax,%ecx
f01069e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01069ec:	1b 3c 24             	sbb    (%esp),%edi
f01069ef:	eb ba                	jmp    f01069ab <__umoddi3+0x11b>
f01069f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069f8:	39 f5                	cmp    %esi,%ebp
f01069fa:	0f 82 f1 fe ff ff    	jb     f01068f1 <__umoddi3+0x61>
f0106a00:	e9 f8 fe ff ff       	jmp    f01068fd <__umoddi3+0x6d>
