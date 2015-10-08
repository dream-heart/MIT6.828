
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
f010005f:	e8 c5 5d 00 00       	call   f0105e29 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 65 10 f0 	movl   $0xf0106520,(%esp)
f010007d:	e8 24 3f 00 00       	call   f0103fa6 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 e5 3e 00 00       	call   f0103f73 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 50 76 10 f0 	movl   $0xf0107650,(%esp)
f0100095:	e8 0c 3f 00 00       	call   f0103fa6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 63 08 00 00       	call   f0100909 <monitor>
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
f01000ae:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 8b 65 10 f0 	movl   $0xf010658b,(%esp)
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
f01000e2:	e8 42 5d 00 00       	call   f0105e29 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 97 65 10 f0 	movl   $0xf0106597,(%esp)
f01000f2:	e8 af 3e 00 00       	call   f0103fa6 <cprintf>

	lapic_init();
f01000f7:	e8 48 5d 00 00       	call   f0105e44 <lapic_init>
	env_init_percpu();
f01000fc:	e8 f0 35 00 00       	call   f01036f1 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 ba 3e 00 00       	call   f0103fc0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 1e 5d 00 00       	call   f0105e29 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
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
f010011d:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100124:	e8 7e 5f 00 00       	call   f01060a7 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100129:	e8 96 49 00 00       	call   f0104ac4 <sched_yield>

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
f0100135:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f010013a:	2d 8f a3 22 f0       	sub    $0xf022a38f,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 8f a3 22 f0 	movl   $0xf022a38f,(%esp)
f0100152:	e8 80 56 00 00       	call   f01057d7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 53 05 00 00       	call   f01006af <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 ad 65 10 f0 	movl   $0xf01065ad,(%esp)
f010016b:	e8 36 3e 00 00       	call   f0103fa6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 77 12 00 00       	call   f01013ec <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 a1 35 00 00       	call   f010371b <env_init>
	trap_init();
f010017a:	e8 11 3f 00 00       	call   f0104090 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 95 59 00 00       	call   f0105b1a <mp_init>
	lapic_init();
f0100185:	e8 ba 5c 00 00       	call   f0105e44 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 47 3d 00 00       	call   f0103ed6 <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	spin_initlock(&kernel_lock);
f010018f:	c7 44 24 04 c8 65 10 	movl   $0xf01065c8,0x4(%esp)
f0100196:	f0 
f0100197:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010019e:	e8 e9 5e 00 00       	call   f010608c <__spin_initlock>
f01001a3:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01001aa:	e8 f8 5e 00 00       	call   f01060a7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001af:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f01001b6:	77 24                	ja     f01001dc <i386_init+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b8:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001bf:	00 
f01001c0:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f01001c7:	f0 
f01001c8:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
f01001cf:	00 
f01001d0:	c7 04 24 8b 65 10 f0 	movl   $0xf010658b,(%esp)
f01001d7:	e8 64 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001dc:	b8 52 5a 10 f0       	mov    $0xf0105a52,%eax
f01001e1:	2d d8 59 10 f0       	sub    $0xf01059d8,%eax
f01001e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001ea:	c7 44 24 04 d8 59 10 	movl   $0xf01059d8,0x4(%esp)
f01001f1:	f0 
f01001f2:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001f9:	e8 26 56 00 00       	call   f0105824 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001fe:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f0100203:	eb 4d                	jmp    f0100252 <i386_init+0x124>
		if (c == cpus + cpunum())  // We've started already.
f0100205:	e8 1f 5c 00 00       	call   f0105e29 <cpunum>
f010020a:	6b c0 74             	imul   $0x74,%eax,%eax
f010020d:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0100212:	39 c3                	cmp    %eax,%ebx
f0100214:	74 39                	je     f010024f <i386_init+0x121>

static void boot_aps(void);


void
i386_init(void)
f0100216:	89 d8                	mov    %ebx,%eax
f0100218:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021d:	c1 f8 02             	sar    $0x2,%eax
f0100220:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100226:	c1 e0 0f             	shl    $0xf,%eax
f0100229:	8d 80 00 50 23 f0    	lea    -0xfdcb000(%eax),%eax
f010022f:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100234:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010023b:	00 
f010023c:	0f b6 03             	movzbl (%ebx),%eax
f010023f:	89 04 24             	mov    %eax,(%esp)
f0100242:	e8 4d 5d 00 00       	call   f0105f94 <lapic_startap>
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
f0100252:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0100259:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010025e:	39 c3                	cmp    %eax,%ebx
f0100260:	72 a3                	jb     f0100205 <i386_init+0xd7>
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
//	ENV_CREATE(user_idle, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100262:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100269:	00 
f010026a:	c7 04 24 a2 82 19 f0 	movl   $0xf01982a2,(%esp)
f0100271:	e8 b8 36 00 00       	call   f010392e <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100276:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010027d:	00 
f010027e:	c7 04 24 a2 82 19 f0 	movl   $0xf01982a2,(%esp)
f0100285:	e8 a4 36 00 00       	call   f010392e <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010028a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100291:	00 
f0100292:	c7 04 24 a2 82 19 f0 	movl   $0xf01982a2,(%esp)
f0100299:	e8 90 36 00 00       	call   f010392e <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f010029e:	e8 21 48 00 00       	call   f0104ac4 <sched_yield>

f01002a3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002a3:	55                   	push   %ebp
f01002a4:	89 e5                	mov    %esp,%ebp
f01002a6:	53                   	push   %ebx
f01002a7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002aa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01002b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002bb:	c7 04 24 d5 65 10 f0 	movl   $0xf01065d5,(%esp)
f01002c2:	e8 df 3c 00 00       	call   f0103fa6 <cprintf>
	vcprintf(fmt, ap);
f01002c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002cb:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ce:	89 04 24             	mov    %eax,(%esp)
f01002d1:	e8 9d 3c 00 00       	call   f0103f73 <vcprintf>
	cprintf("\n");
f01002d6:	c7 04 24 50 76 10 f0 	movl   $0xf0107650,(%esp)
f01002dd:	e8 c4 3c 00 00       	call   f0103fa6 <cprintf>
	va_end(ap);
}
f01002e2:	83 c4 14             	add    $0x14,%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5d                   	pop    %ebp
f01002e7:	c3                   	ret    
	...

f01002f0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002f8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002f9:	a8 01                	test   $0x1,%al
f01002fb:	74 08                	je     f0100305 <serial_proc_data+0x15>
f01002fd:	b2 f8                	mov    $0xf8,%dl
f01002ff:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100300:	0f b6 c0             	movzbl %al,%eax
f0100303:	eb 05                	jmp    f010030a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010030a:	5d                   	pop    %ebp
f010030b:	c3                   	ret    

f010030c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030c:	55                   	push   %ebp
f010030d:	89 e5                	mov    %esp,%ebp
f010030f:	53                   	push   %ebx
f0100310:	83 ec 04             	sub    $0x4,%esp
f0100313:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100315:	eb 2a                	jmp    f0100341 <cons_intr+0x35>
		if (c == 0)
f0100317:	85 d2                	test   %edx,%edx
f0100319:	74 26                	je     f0100341 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010031b:	a1 24 b2 22 f0       	mov    0xf022b224,%eax
f0100320:	8d 48 01             	lea    0x1(%eax),%ecx
f0100323:	89 0d 24 b2 22 f0    	mov    %ecx,0xf022b224
f0100329:	88 90 20 b0 22 f0    	mov    %dl,-0xfdd4fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010032f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100335:	75 0a                	jne    f0100341 <cons_intr+0x35>
			cons.wpos = 0;
f0100337:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
f010033e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100341:	ff d3                	call   *%ebx
f0100343:	89 c2                	mov    %eax,%edx
f0100345:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100348:	75 cd                	jne    f0100317 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010034a:	83 c4 04             	add    $0x4,%esp
f010034d:	5b                   	pop    %ebx
f010034e:	5d                   	pop    %ebp
f010034f:	c3                   	ret    

f0100350 <kbd_proc_data>:
f0100350:	ba 64 00 00 00       	mov    $0x64,%edx
f0100355:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100356:	a8 01                	test   $0x1,%al
f0100358:	0f 84 ef 00 00 00    	je     f010044d <kbd_proc_data+0xfd>
f010035e:	b2 60                	mov    $0x60,%dl
f0100360:	ec                   	in     (%dx),%al
f0100361:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100363:	3c e0                	cmp    $0xe0,%al
f0100365:	75 0d                	jne    f0100374 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100367:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
		return 0;
f010036e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100373:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100374:	55                   	push   %ebp
f0100375:	89 e5                	mov    %esp,%ebp
f0100377:	53                   	push   %ebx
f0100378:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010037b:	84 c0                	test   %al,%al
f010037d:	79 37                	jns    f01003b6 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010037f:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100385:	89 cb                	mov    %ecx,%ebx
f0100387:	83 e3 40             	and    $0x40,%ebx
f010038a:	83 e0 7f             	and    $0x7f,%eax
f010038d:	85 db                	test   %ebx,%ebx
f010038f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100392:	0f b6 d2             	movzbl %dl,%edx
f0100395:	0f b6 82 40 67 10 f0 	movzbl -0xfef98c0(%edx),%eax
f010039c:	83 c8 40             	or     $0x40,%eax
f010039f:	0f b6 c0             	movzbl %al,%eax
f01003a2:	f7 d0                	not    %eax
f01003a4:	21 c1                	and    %eax,%ecx
f01003a6:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
		return 0;
f01003ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01003b1:	e9 9d 00 00 00       	jmp    f0100453 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f01003b6:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f01003bc:	f6 c1 40             	test   $0x40,%cl
f01003bf:	74 0e                	je     f01003cf <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c1:	83 c8 80             	or     $0xffffff80,%eax
f01003c4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003c6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003c9:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f01003cf:	0f b6 d2             	movzbl %dl,%edx
f01003d2:	0f b6 82 40 67 10 f0 	movzbl -0xfef98c0(%edx),%eax
f01003d9:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
	shift ^= togglecode[data];
f01003df:	0f b6 8a 40 66 10 f0 	movzbl -0xfef99c0(%edx),%ecx
f01003e6:	31 c8                	xor    %ecx,%eax
f01003e8:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003ed:	89 c1                	mov    %eax,%ecx
f01003ef:	83 e1 03             	and    $0x3,%ecx
f01003f2:	8b 0c 8d 20 66 10 f0 	mov    -0xfef99e0(,%ecx,4),%ecx
f01003f9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003fd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100400:	a8 08                	test   $0x8,%al
f0100402:	74 1b                	je     f010041f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100404:	89 da                	mov    %ebx,%edx
f0100406:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100409:	83 f9 19             	cmp    $0x19,%ecx
f010040c:	77 05                	ja     f0100413 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010040e:	83 eb 20             	sub    $0x20,%ebx
f0100411:	eb 0c                	jmp    f010041f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100413:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100416:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100419:	83 fa 19             	cmp    $0x19,%edx
f010041c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010041f:	f7 d0                	not    %eax
f0100421:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100423:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100425:	f6 c2 06             	test   $0x6,%dl
f0100428:	75 29                	jne    f0100453 <kbd_proc_data+0x103>
f010042a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100430:	75 21                	jne    f0100453 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100432:	c7 04 24 ef 65 10 f0 	movl   $0xf01065ef,(%esp)
f0100439:	e8 68 3b 00 00       	call   f0103fa6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100443:	b8 03 00 00 00       	mov    $0x3,%eax
f0100448:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100449:	89 d8                	mov    %ebx,%eax
f010044b:	eb 06                	jmp    f0100453 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010044d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100452:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100453:	83 c4 14             	add    $0x14,%esp
f0100456:	5b                   	pop    %ebx
f0100457:	5d                   	pop    %ebp
f0100458:	c3                   	ret    

f0100459 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100459:	55                   	push   %ebp
f010045a:	89 e5                	mov    %esp,%ebp
f010045c:	57                   	push   %edi
f010045d:	56                   	push   %esi
f010045e:	53                   	push   %ebx
f010045f:	83 ec 1c             	sub    $0x1c,%esp
f0100462:	89 c7                	mov    %eax,%edi
f0100464:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100469:	be fd 03 00 00       	mov    $0x3fd,%esi
f010046e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100473:	eb 06                	jmp    f010047b <cons_putc+0x22>
f0100475:	89 ca                	mov    %ecx,%edx
f0100477:	ec                   	in     (%dx),%al
f0100478:	ec                   	in     (%dx),%al
f0100479:	ec                   	in     (%dx),%al
f010047a:	ec                   	in     (%dx),%al
f010047b:	89 f2                	mov    %esi,%edx
f010047d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010047e:	a8 20                	test   $0x20,%al
f0100480:	75 05                	jne    f0100487 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100482:	83 eb 01             	sub    $0x1,%ebx
f0100485:	75 ee                	jne    f0100475 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100487:	89 f8                	mov    %edi,%eax
f0100489:	0f b6 c0             	movzbl %al,%eax
f010048c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010048f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100494:	ee                   	out    %al,(%dx)
f0100495:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010049a:	be 79 03 00 00       	mov    $0x379,%esi
f010049f:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004a4:	eb 06                	jmp    f01004ac <cons_putc+0x53>
f01004a6:	89 ca                	mov    %ecx,%edx
f01004a8:	ec                   	in     (%dx),%al
f01004a9:	ec                   	in     (%dx),%al
f01004aa:	ec                   	in     (%dx),%al
f01004ab:	ec                   	in     (%dx),%al
f01004ac:	89 f2                	mov    %esi,%edx
f01004ae:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004af:	84 c0                	test   %al,%al
f01004b1:	78 05                	js     f01004b8 <cons_putc+0x5f>
f01004b3:	83 eb 01             	sub    $0x1,%ebx
f01004b6:	75 ee                	jne    f01004a6 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b8:	ba 78 03 00 00       	mov    $0x378,%edx
f01004bd:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	b2 7a                	mov    $0x7a,%dl
f01004c4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004c9:	ee                   	out    %al,(%dx)
f01004ca:	b8 08 00 00 00       	mov    $0x8,%eax
f01004cf:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004d0:	89 fa                	mov    %edi,%edx
f01004d2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004d8:	89 f8                	mov    %edi,%eax
f01004da:	80 cc 07             	or     $0x7,%ah
f01004dd:	85 d2                	test   %edx,%edx
f01004df:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004e2:	89 f8                	mov    %edi,%eax
f01004e4:	0f b6 c0             	movzbl %al,%eax
f01004e7:	83 f8 09             	cmp    $0x9,%eax
f01004ea:	74 76                	je     f0100562 <cons_putc+0x109>
f01004ec:	83 f8 09             	cmp    $0x9,%eax
f01004ef:	7f 0a                	jg     f01004fb <cons_putc+0xa2>
f01004f1:	83 f8 08             	cmp    $0x8,%eax
f01004f4:	74 16                	je     f010050c <cons_putc+0xb3>
f01004f6:	e9 9b 00 00 00       	jmp    f0100596 <cons_putc+0x13d>
f01004fb:	83 f8 0a             	cmp    $0xa,%eax
f01004fe:	66 90                	xchg   %ax,%ax
f0100500:	74 3a                	je     f010053c <cons_putc+0xe3>
f0100502:	83 f8 0d             	cmp    $0xd,%eax
f0100505:	74 3d                	je     f0100544 <cons_putc+0xeb>
f0100507:	e9 8a 00 00 00       	jmp    f0100596 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010050c:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100513:	66 85 c0             	test   %ax,%ax
f0100516:	0f 84 e5 00 00 00    	je     f0100601 <cons_putc+0x1a8>
			crt_pos--;
f010051c:	83 e8 01             	sub    $0x1,%eax
f010051f:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100525:	0f b7 c0             	movzwl %ax,%eax
f0100528:	66 81 e7 00 ff       	and    $0xff00,%di
f010052d:	83 cf 20             	or     $0x20,%edi
f0100530:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100536:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010053a:	eb 78                	jmp    f01005b4 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010053c:	66 83 05 28 b2 22 f0 	addw   $0x50,0xf022b228
f0100543:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100544:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010054b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100551:	c1 e8 16             	shr    $0x16,%eax
f0100554:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100557:	c1 e0 04             	shl    $0x4,%eax
f010055a:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
f0100560:	eb 52                	jmp    f01005b4 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100562:	b8 20 00 00 00       	mov    $0x20,%eax
f0100567:	e8 ed fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f010056c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100571:	e8 e3 fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f0100576:	b8 20 00 00 00       	mov    $0x20,%eax
f010057b:	e8 d9 fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f0100580:	b8 20 00 00 00       	mov    $0x20,%eax
f0100585:	e8 cf fe ff ff       	call   f0100459 <cons_putc>
		cons_putc(' ');
f010058a:	b8 20 00 00 00       	mov    $0x20,%eax
f010058f:	e8 c5 fe ff ff       	call   f0100459 <cons_putc>
f0100594:	eb 1e                	jmp    f01005b4 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100596:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010059d:	8d 50 01             	lea    0x1(%eax),%edx
f01005a0:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f01005a7:	0f b7 c0             	movzwl %ax,%eax
f01005aa:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01005b0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005b4:	66 81 3d 28 b2 22 f0 	cmpw   $0x7cf,0xf022b228
f01005bb:	cf 07 
f01005bd:	76 42                	jbe    f0100601 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005bf:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f01005c4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005cb:	00 
f01005cc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005d2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005d6:	89 04 24             	mov    %eax,(%esp)
f01005d9:	e8 46 52 00 00       	call   f0105824 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005de:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005e4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005e9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ef:	83 c0 01             	add    $0x1,%eax
f01005f2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005f7:	75 f0                	jne    f01005e9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005f9:	66 83 2d 28 b2 22 f0 	subw   $0x50,0xf022b228
f0100600:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100601:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f0100607:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060c:	89 ca                	mov    %ecx,%edx
f010060e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010060f:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
f0100616:	8d 71 01             	lea    0x1(%ecx),%esi
f0100619:	89 d8                	mov    %ebx,%eax
f010061b:	66 c1 e8 08          	shr    $0x8,%ax
f010061f:	89 f2                	mov    %esi,%edx
f0100621:	ee                   	out    %al,(%dx)
f0100622:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100627:	89 ca                	mov    %ecx,%edx
f0100629:	ee                   	out    %al,(%dx)
f010062a:	89 d8                	mov    %ebx,%eax
f010062c:	89 f2                	mov    %esi,%edx
f010062e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010062f:	83 c4 1c             	add    $0x1c,%esp
f0100632:	5b                   	pop    %ebx
f0100633:	5e                   	pop    %esi
f0100634:	5f                   	pop    %edi
f0100635:	5d                   	pop    %ebp
f0100636:	c3                   	ret    

f0100637 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100637:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
f010063e:	74 11                	je     f0100651 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100646:	b8 f0 02 10 f0       	mov    $0xf01002f0,%eax
f010064b:	e8 bc fc ff ff       	call   f010030c <cons_intr>
}
f0100650:	c9                   	leave  
f0100651:	f3 c3                	repz ret 

f0100653 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100653:	55                   	push   %ebp
f0100654:	89 e5                	mov    %esp,%ebp
f0100656:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100659:	b8 50 03 10 f0       	mov    $0xf0100350,%eax
f010065e:	e8 a9 fc ff ff       	call   f010030c <cons_intr>
}
f0100663:	c9                   	leave  
f0100664:	c3                   	ret    

f0100665 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100665:	55                   	push   %ebp
f0100666:	89 e5                	mov    %esp,%ebp
f0100668:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010066b:	e8 c7 ff ff ff       	call   f0100637 <serial_intr>
	kbd_intr();
f0100670:	e8 de ff ff ff       	call   f0100653 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100675:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f010067a:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f0100680:	74 26                	je     f01006a8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100682:	8d 50 01             	lea    0x1(%eax),%edx
f0100685:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f010068b:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100692:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100694:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010069a:	75 11                	jne    f01006ad <cons_getc+0x48>
			cons.rpos = 0;
f010069c:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
f01006a3:	00 00 00 
f01006a6:	eb 05                	jmp    f01006ad <cons_getc+0x48>
		return c;
	}
	return 0;
f01006a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006ad:	c9                   	leave  
f01006ae:	c3                   	ret    

f01006af <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006af:	55                   	push   %ebp
f01006b0:	89 e5                	mov    %esp,%ebp
f01006b2:	57                   	push   %edi
f01006b3:	56                   	push   %esi
f01006b4:	53                   	push   %ebx
f01006b5:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006b8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006bf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006c6:	5a a5 
	if (*cp != 0xA55A) {
f01006c8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006cf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006d3:	74 11                	je     f01006e6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006d5:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
f01006dc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006df:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006e4:	eb 16                	jmp    f01006fc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006e6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ed:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
f01006f4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006f7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006fc:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f0100702:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100707:	89 ca                	mov    %ecx,%edx
f0100709:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010070a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070d:	89 da                	mov    %ebx,%edx
f010070f:	ec                   	in     (%dx),%al
f0100710:	0f b6 f0             	movzbl %al,%esi
f0100713:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100716:	b8 0f 00 00 00       	mov    $0xf,%eax
f010071b:	89 ca                	mov    %ecx,%edx
f010071d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071e:	89 da                	mov    %ebx,%edx
f0100720:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100721:	89 3d 2c b2 22 f0    	mov    %edi,0xf022b22c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100727:	0f b6 d8             	movzbl %al,%ebx
f010072a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010072c:	66 89 35 28 b2 22 f0 	mov    %si,0xf022b228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100733:	e8 1b ff ff ff       	call   f0100653 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100738:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010073f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100744:	89 04 24             	mov    %eax,(%esp)
f0100747:	e8 1b 37 00 00       	call   f0103e67 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010074c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100751:	b8 00 00 00 00       	mov    $0x0,%eax
f0100756:	89 f2                	mov    %esi,%edx
f0100758:	ee                   	out    %al,(%dx)
f0100759:	b2 fb                	mov    $0xfb,%dl
f010075b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100760:	ee                   	out    %al,(%dx)
f0100761:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100766:	b8 0c 00 00 00       	mov    $0xc,%eax
f010076b:	89 da                	mov    %ebx,%edx
f010076d:	ee                   	out    %al,(%dx)
f010076e:	b2 f9                	mov    $0xf9,%dl
f0100770:	b8 00 00 00 00       	mov    $0x0,%eax
f0100775:	ee                   	out    %al,(%dx)
f0100776:	b2 fb                	mov    $0xfb,%dl
f0100778:	b8 03 00 00 00       	mov    $0x3,%eax
f010077d:	ee                   	out    %al,(%dx)
f010077e:	b2 fc                	mov    $0xfc,%dl
f0100780:	b8 00 00 00 00       	mov    $0x0,%eax
f0100785:	ee                   	out    %al,(%dx)
f0100786:	b2 f9                	mov    $0xf9,%dl
f0100788:	b8 01 00 00 00       	mov    $0x1,%eax
f010078d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010078e:	b2 fd                	mov    $0xfd,%dl
f0100790:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100791:	3c ff                	cmp    $0xff,%al
f0100793:	0f 95 c1             	setne  %cl
f0100796:	88 0d 34 b2 22 f0    	mov    %cl,0xf022b234
f010079c:	89 f2                	mov    %esi,%edx
f010079e:	ec                   	in     (%dx),%al
f010079f:	89 da                	mov    %ebx,%edx
f01007a1:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007a2:	84 c9                	test   %cl,%cl
f01007a4:	75 0c                	jne    f01007b2 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f01007a6:	c7 04 24 fb 65 10 f0 	movl   $0xf01065fb,(%esp)
f01007ad:	e8 f4 37 00 00       	call   f0103fa6 <cprintf>
}
f01007b2:	83 c4 1c             	add    $0x1c,%esp
f01007b5:	5b                   	pop    %ebx
f01007b6:	5e                   	pop    %esi
f01007b7:	5f                   	pop    %edi
f01007b8:	5d                   	pop    %ebp
f01007b9:	c3                   	ret    

f01007ba <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
f01007bd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007c3:	e8 91 fc ff ff       	call   f0100459 <cons_putc>
}
f01007c8:	c9                   	leave  
f01007c9:	c3                   	ret    

f01007ca <getchar>:

int
getchar(void)
{
f01007ca:	55                   	push   %ebp
f01007cb:	89 e5                	mov    %esp,%ebp
f01007cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007d0:	e8 90 fe ff ff       	call   f0100665 <cons_getc>
f01007d5:	85 c0                	test   %eax,%eax
f01007d7:	74 f7                	je     f01007d0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007d9:	c9                   	leave  
f01007da:	c3                   	ret    

f01007db <iscons>:

int
iscons(int fdnum)
{
f01007db:	55                   	push   %ebp
f01007dc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007de:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e3:	5d                   	pop    %ebp
f01007e4:	c3                   	ret    
	...

f01007f0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007f6:	c7 44 24 08 40 68 10 	movl   $0xf0106840,0x8(%esp)
f01007fd:	f0 
f01007fe:	c7 44 24 04 5e 68 10 	movl   $0xf010685e,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 63 68 10 f0 	movl   $0xf0106863,(%esp)
f010080d:	e8 94 37 00 00       	call   f0103fa6 <cprintf>
f0100812:	c7 44 24 08 cc 68 10 	movl   $0xf01068cc,0x8(%esp)
f0100819:	f0 
f010081a:	c7 44 24 04 6c 68 10 	movl   $0xf010686c,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 63 68 10 f0 	movl   $0xf0106863,(%esp)
f0100829:	e8 78 37 00 00       	call   f0103fa6 <cprintf>
	return 0;
}
f010082e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100833:	c9                   	leave  
f0100834:	c3                   	ret    

f0100835 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100835:	55                   	push   %ebp
f0100836:	89 e5                	mov    %esp,%ebp
f0100838:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010083b:	c7 04 24 75 68 10 f0 	movl   $0xf0106875,(%esp)
f0100842:	e8 5f 37 00 00       	call   f0103fa6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100847:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010084e:	00 
f010084f:	c7 04 24 f4 68 10 f0 	movl   $0xf01068f4,(%esp)
f0100856:	e8 4b 37 00 00       	call   f0103fa6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010085b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100862:	00 
f0100863:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010086a:	f0 
f010086b:	c7 04 24 1c 69 10 f0 	movl   $0xf010691c,(%esp)
f0100872:	e8 2f 37 00 00       	call   f0103fa6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100877:	c7 44 24 08 15 65 10 	movl   $0x106515,0x8(%esp)
f010087e:	00 
f010087f:	c7 44 24 04 15 65 10 	movl   $0xf0106515,0x4(%esp)
f0100886:	f0 
f0100887:	c7 04 24 40 69 10 f0 	movl   $0xf0106940,(%esp)
f010088e:	e8 13 37 00 00       	call   f0103fa6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100893:	c7 44 24 08 8f a3 22 	movl   $0x22a38f,0x8(%esp)
f010089a:	00 
f010089b:	c7 44 24 04 8f a3 22 	movl   $0xf022a38f,0x4(%esp)
f01008a2:	f0 
f01008a3:	c7 04 24 64 69 10 f0 	movl   $0xf0106964,(%esp)
f01008aa:	e8 f7 36 00 00       	call   f0103fa6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008af:	c7 44 24 08 08 d0 26 	movl   $0x26d008,0x8(%esp)
f01008b6:	00 
f01008b7:	c7 44 24 04 08 d0 26 	movl   $0xf026d008,0x4(%esp)
f01008be:	f0 
f01008bf:	c7 04 24 88 69 10 f0 	movl   $0xf0106988,(%esp)
f01008c6:	e8 db 36 00 00       	call   f0103fa6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008cb:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f01008d0:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008d5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008da:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	0f 48 c2             	cmovs  %edx,%eax
f01008e5:	c1 f8 0a             	sar    $0xa,%eax
f01008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ec:	c7 04 24 ac 69 10 f0 	movl   $0xf01069ac,(%esp)
f01008f3:	e8 ae 36 00 00       	call   f0103fa6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fd:	c9                   	leave  
f01008fe:	c3                   	ret    

f01008ff <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ff:	55                   	push   %ebp
f0100900:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100902:	b8 00 00 00 00       	mov    $0x0,%eax
f0100907:	5d                   	pop    %ebp
f0100908:	c3                   	ret    

f0100909 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100909:	55                   	push   %ebp
f010090a:	89 e5                	mov    %esp,%ebp
f010090c:	57                   	push   %edi
f010090d:	56                   	push   %esi
f010090e:	53                   	push   %ebx
f010090f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100912:	c7 04 24 d8 69 10 f0 	movl   $0xf01069d8,(%esp)
f0100919:	e8 88 36 00 00       	call   f0103fa6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010091e:	c7 04 24 fc 69 10 f0 	movl   $0xf01069fc,(%esp)
f0100925:	e8 7c 36 00 00       	call   f0103fa6 <cprintf>

	if (tf != NULL)
f010092a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010092e:	74 0b                	je     f010093b <monitor+0x32>
		print_trapframe(tf);
f0100930:	8b 45 08             	mov    0x8(%ebp),%eax
f0100933:	89 04 24             	mov    %eax,(%esp)
f0100936:	e8 90 3b 00 00       	call   f01044cb <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010093b:	c7 04 24 8e 68 10 f0 	movl   $0xf010688e,(%esp)
f0100942:	e8 39 4c 00 00       	call   f0105580 <readline>
f0100947:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100949:	85 c0                	test   %eax,%eax
f010094b:	74 ee                	je     f010093b <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010094d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100954:	be 00 00 00 00       	mov    $0x0,%esi
f0100959:	eb 0a                	jmp    f0100965 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010095b:	c6 03 00             	movb   $0x0,(%ebx)
f010095e:	89 f7                	mov    %esi,%edi
f0100960:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100963:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100965:	0f b6 03             	movzbl (%ebx),%eax
f0100968:	84 c0                	test   %al,%al
f010096a:	74 63                	je     f01009cf <monitor+0xc6>
f010096c:	0f be c0             	movsbl %al,%eax
f010096f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100973:	c7 04 24 92 68 10 f0 	movl   $0xf0106892,(%esp)
f010097a:	e8 1b 4e 00 00       	call   f010579a <strchr>
f010097f:	85 c0                	test   %eax,%eax
f0100981:	75 d8                	jne    f010095b <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100983:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100986:	74 47                	je     f01009cf <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100988:	83 fe 0f             	cmp    $0xf,%esi
f010098b:	75 16                	jne    f01009a3 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010098d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100994:	00 
f0100995:	c7 04 24 97 68 10 f0 	movl   $0xf0106897,(%esp)
f010099c:	e8 05 36 00 00       	call   f0103fa6 <cprintf>
f01009a1:	eb 98                	jmp    f010093b <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01009a3:	8d 7e 01             	lea    0x1(%esi),%edi
f01009a6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009aa:	eb 03                	jmp    f01009af <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009ac:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009af:	0f b6 03             	movzbl (%ebx),%eax
f01009b2:	84 c0                	test   %al,%al
f01009b4:	74 ad                	je     f0100963 <monitor+0x5a>
f01009b6:	0f be c0             	movsbl %al,%eax
f01009b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009bd:	c7 04 24 92 68 10 f0 	movl   $0xf0106892,(%esp)
f01009c4:	e8 d1 4d 00 00       	call   f010579a <strchr>
f01009c9:	85 c0                	test   %eax,%eax
f01009cb:	74 df                	je     f01009ac <monitor+0xa3>
f01009cd:	eb 94                	jmp    f0100963 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f01009cf:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009d6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009d7:	85 f6                	test   %esi,%esi
f01009d9:	0f 84 5c ff ff ff    	je     f010093b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009df:	c7 44 24 04 5e 68 10 	movl   $0xf010685e,0x4(%esp)
f01009e6:	f0 
f01009e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ea:	89 04 24             	mov    %eax,(%esp)
f01009ed:	e8 4a 4d 00 00       	call   f010573c <strcmp>
f01009f2:	85 c0                	test   %eax,%eax
f01009f4:	74 1b                	je     f0100a11 <monitor+0x108>
f01009f6:	c7 44 24 04 6c 68 10 	movl   $0xf010686c,0x4(%esp)
f01009fd:	f0 
f01009fe:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a01:	89 04 24             	mov    %eax,(%esp)
f0100a04:	e8 33 4d 00 00       	call   f010573c <strcmp>
f0100a09:	85 c0                	test   %eax,%eax
f0100a0b:	75 2f                	jne    f0100a3c <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a0d:	b0 01                	mov    $0x1,%al
f0100a0f:	eb 05                	jmp    f0100a16 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a11:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100a16:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a19:	01 d0                	add    %edx,%eax
f0100a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100a1e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a22:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a29:	89 34 24             	mov    %esi,(%esp)
f0100a2c:	ff 14 85 2c 6a 10 f0 	call   *-0xfef95d4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a33:	85 c0                	test   %eax,%eax
f0100a35:	78 1d                	js     f0100a54 <monitor+0x14b>
f0100a37:	e9 ff fe ff ff       	jmp    f010093b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a3c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a43:	c7 04 24 b4 68 10 f0 	movl   $0xf01068b4,(%esp)
f0100a4a:	e8 57 35 00 00       	call   f0103fa6 <cprintf>
f0100a4f:	e9 e7 fe ff ff       	jmp    f010093b <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a54:	83 c4 5c             	add    $0x5c,%esp
f0100a57:	5b                   	pop    %ebx
f0100a58:	5e                   	pop    %esi
f0100a59:	5f                   	pop    %edi
f0100a5a:	5d                   	pop    %ebp
f0100a5b:	c3                   	ret    
f0100a5c:	00 00                	add    %al,(%eax)
	...

f0100a60 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a63:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100a6a:	75 11                	jne    f0100a7d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a6c:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100a71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a77:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	75 07                	jne    f0100a88 <boot_alloc+0x28>
		return nextfree;
f0100a81:	a1 38 b2 22 f0       	mov    0xf022b238,%eax
f0100a86:	eb 19                	jmp    f0100aa1 <boot_alloc+0x41>
	result = nextfree;
f0100a88:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a8e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a9a:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
	
	// return the head address of the alloc pages;
	return result;
f0100a9f:	89 d0                	mov    %edx,%eax
}
f0100aa1:	5d                   	pop    %ebp
f0100aa2:	c3                   	ret    

f0100aa3 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100aa3:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100aa9:	c1 f8 03             	sar    $0x3,%eax
f0100aac:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aaf:	89 c2                	mov    %eax,%edx
f0100ab1:	c1 ea 0c             	shr    $0xc,%edx
f0100ab4:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100aba:	72 26                	jb     f0100ae2 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ac2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ac6:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0100acd:	f0 
f0100ace:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ad5:	00 
f0100ad6:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0100add:	e8 5e f5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ae2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ae7:	c3                   	ret    

f0100ae8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ae8:	89 d1                	mov    %edx,%ecx
f0100aea:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100aed:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af0:	a8 01                	test   $0x1,%al
f0100af2:	74 5d                	je     f0100b51 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100af4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af9:	89 c1                	mov    %eax,%ecx
f0100afb:	c1 e9 0c             	shr    $0xc,%ecx
f0100afe:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0100b04:	72 26                	jb     f0100b2c <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b06:	55                   	push   %ebp
f0100b07:	89 e5                	mov    %esp,%ebp
f0100b09:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b10:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0100b17:	f0 
f0100b18:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0100b1f:	00 
f0100b20:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100b27:	e8 14 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b2c:	c1 ea 0c             	shr    $0xc,%edx
f0100b2f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b35:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b3c:	89 c2                	mov    %eax,%edx
f0100b3e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b46:	85 d2                	test   %edx,%edx
f0100b48:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b4d:	0f 44 c2             	cmove  %edx,%eax
f0100b50:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b56:	c3                   	ret    

f0100b57 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b57:	55                   	push   %ebp
f0100b58:	89 e5                	mov    %esp,%ebp
f0100b5a:	57                   	push   %edi
f0100b5b:	56                   	push   %esi
f0100b5c:	53                   	push   %ebx
f0100b5d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b60:	84 c0                	test   %al,%al
f0100b62:	0f 85 31 03 00 00    	jne    f0100e99 <check_page_free_list+0x342>
f0100b68:	e9 3e 03 00 00       	jmp    f0100eab <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b6d:	c7 44 24 08 3c 6a 10 	movl   $0xf0106a3c,0x8(%esp)
f0100b74:	f0 
f0100b75:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100b7c:	00 
f0100b7d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100b84:	e8 b7 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b89:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b8c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b8f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b95:	89 c2                	mov    %eax,%edx
f0100b97:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b9d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ba3:	0f 95 c2             	setne  %dl
f0100ba6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ba9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bad:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100baf:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb3:	8b 00                	mov    (%eax),%eax
f0100bb5:	85 c0                	test   %eax,%eax
f0100bb7:	75 dc                	jne    f0100b95 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bc8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bca:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bcd:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bd7:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100bdd:	eb 63                	jmp    f0100c42 <check_page_free_list+0xeb>
f0100bdf:	89 d8                	mov    %ebx,%eax
f0100be1:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100be7:	c1 f8 03             	sar    $0x3,%eax
f0100bea:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bed:	89 c2                	mov    %eax,%edx
f0100bef:	c1 ea 16             	shr    $0x16,%edx
f0100bf2:	39 f2                	cmp    %esi,%edx
f0100bf4:	73 4a                	jae    f0100c40 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bf6:	89 c2                	mov    %eax,%edx
f0100bf8:	c1 ea 0c             	shr    $0xc,%edx
f0100bfb:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100c01:	72 20                	jb     f0100c23 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c07:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0100c0e:	f0 
f0100c0f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c16:	00 
f0100c17:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0100c1e:	e8 1d f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c23:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c2a:	00 
f0100c2b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c32:	00 
	return (void *)(pa + KERNBASE);
f0100c33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c38:	89 04 24             	mov    %eax,(%esp)
f0100c3b:	e8 97 4b 00 00       	call   f01057d7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c40:	8b 1b                	mov    (%ebx),%ebx
f0100c42:	85 db                	test   %ebx,%ebx
f0100c44:	75 99                	jne    f0100bdf <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c46:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c4b:	e8 10 fe ff ff       	call   f0100a60 <boot_alloc>
f0100c50:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c53:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c59:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
		assert(pp < pages + npages);
f0100c5f:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0100c64:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c67:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c6d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c70:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c75:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c78:	e9 c4 01 00 00       	jmp    f0100e41 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c7d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c80:	73 24                	jae    f0100ca6 <check_page_free_list+0x14f>
f0100c82:	c7 44 24 0c 73 73 10 	movl   $0xf0107373,0xc(%esp)
f0100c89:	f0 
f0100c8a:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100c91:	f0 
f0100c92:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0100c99:	00 
f0100c9a:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100ca1:	e8 9a f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100ca6:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100ca9:	72 24                	jb     f0100ccf <check_page_free_list+0x178>
f0100cab:	c7 44 24 0c 94 73 10 	movl   $0xf0107394,0xc(%esp)
f0100cb2:	f0 
f0100cb3:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100cba:	f0 
f0100cbb:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100cc2:	00 
f0100cc3:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100cca:	e8 71 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ccf:	89 d0                	mov    %edx,%eax
f0100cd1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100cd4:	a8 07                	test   $0x7,%al
f0100cd6:	74 24                	je     f0100cfc <check_page_free_list+0x1a5>
f0100cd8:	c7 44 24 0c 60 6a 10 	movl   $0xf0106a60,0xc(%esp)
f0100cdf:	f0 
f0100ce0:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100ce7:	f0 
f0100ce8:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0100cef:	00 
f0100cf0:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100cf7:	e8 44 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cfc:	c1 f8 03             	sar    $0x3,%eax
f0100cff:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d02:	85 c0                	test   %eax,%eax
f0100d04:	75 24                	jne    f0100d2a <check_page_free_list+0x1d3>
f0100d06:	c7 44 24 0c a8 73 10 	movl   $0xf01073a8,0xc(%esp)
f0100d0d:	f0 
f0100d0e:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100d15:	f0 
f0100d16:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100d1d:	00 
f0100d1e:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100d25:	e8 16 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d2a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d2f:	75 24                	jne    f0100d55 <check_page_free_list+0x1fe>
f0100d31:	c7 44 24 0c b9 73 10 	movl   $0xf01073b9,0xc(%esp)
f0100d38:	f0 
f0100d39:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100d40:	f0 
f0100d41:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100d48:	00 
f0100d49:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100d50:	e8 eb f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d55:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d5a:	75 24                	jne    f0100d80 <check_page_free_list+0x229>
f0100d5c:	c7 44 24 0c 94 6a 10 	movl   $0xf0106a94,0xc(%esp)
f0100d63:	f0 
f0100d64:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100d6b:	f0 
f0100d6c:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d73:	00 
f0100d74:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100d7b:	e8 c0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d80:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d85:	75 24                	jne    f0100dab <check_page_free_list+0x254>
f0100d87:	c7 44 24 0c d2 73 10 	movl   $0xf01073d2,0xc(%esp)
f0100d8e:	f0 
f0100d8f:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100d96:	f0 
f0100d97:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d9e:	00 
f0100d9f:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100da6:	e8 95 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dab:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100db0:	0f 86 1c 01 00 00    	jbe    f0100ed2 <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100db6:	89 c1                	mov    %eax,%ecx
f0100db8:	c1 e9 0c             	shr    $0xc,%ecx
f0100dbb:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100dbe:	77 20                	ja     f0100de0 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc4:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0100dcb:	f0 
f0100dcc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100dd3:	00 
f0100dd4:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0100ddb:	e8 60 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100de0:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100de6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100de9:	0f 86 d3 00 00 00    	jbe    f0100ec2 <check_page_free_list+0x36b>
f0100def:	c7 44 24 0c b8 6a 10 	movl   $0xf0106ab8,0xc(%esp)
f0100df6:	f0 
f0100df7:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100dfe:	f0 
f0100dff:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0100e06:	00 
f0100e07:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100e0e:	e8 2d f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e13:	c7 44 24 0c ec 73 10 	movl   $0xf01073ec,0xc(%esp)
f0100e1a:	f0 
f0100e1b:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100e22:	f0 
f0100e23:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100e2a:	00 
f0100e2b:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100e32:	e8 09 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e37:	83 c3 01             	add    $0x1,%ebx
f0100e3a:	eb 03                	jmp    f0100e3f <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100e3c:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e3f:	8b 12                	mov    (%edx),%edx
f0100e41:	85 d2                	test   %edx,%edx
f0100e43:	0f 85 34 fe ff ff    	jne    f0100c7d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e49:	85 db                	test   %ebx,%ebx
f0100e4b:	7f 24                	jg     f0100e71 <check_page_free_list+0x31a>
f0100e4d:	c7 44 24 0c 09 74 10 	movl   $0xf0107409,0xc(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100e5c:	f0 
f0100e5d:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0100e64:	00 
f0100e65:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100e6c:	e8 cf f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e71:	85 ff                	test   %edi,%edi
f0100e73:	7f 70                	jg     f0100ee5 <check_page_free_list+0x38e>
f0100e75:	c7 44 24 0c 1b 74 10 	movl   $0xf010741b,0xc(%esp)
f0100e7c:	f0 
f0100e7d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0100e94:	e8 a7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e99:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	0f 85 e3 fc ff ff    	jne    f0100b89 <check_page_free_list+0x32>
f0100ea6:	e9 c2 fc ff ff       	jmp    f0100b6d <check_page_free_list+0x16>
f0100eab:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f0100eb2:	0f 84 b5 fc ff ff    	je     f0100b6d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eb8:	be 00 04 00 00       	mov    $0x400,%esi
f0100ebd:	e9 15 fd ff ff       	jmp    f0100bd7 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ec2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ec7:	0f 85 6f ff ff ff    	jne    f0100e3c <check_page_free_list+0x2e5>
f0100ecd:	e9 41 ff ff ff       	jmp    f0100e13 <check_page_free_list+0x2bc>
f0100ed2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ed7:	0f 85 5a ff ff ff    	jne    f0100e37 <check_page_free_list+0x2e0>
f0100edd:	8d 76 00             	lea    0x0(%esi),%esi
f0100ee0:	e9 2e ff ff ff       	jmp    f0100e13 <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ee5:	83 c4 4c             	add    $0x4c,%esp
f0100ee8:	5b                   	pop    %ebx
f0100ee9:	5e                   	pop    %esi
f0100eea:	5f                   	pop    %edi
f0100eeb:	5d                   	pop    %ebp
f0100eec:	c3                   	ret    

f0100eed <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eed:	55                   	push   %ebp
f0100eee:	89 e5                	mov    %esp,%ebp
f0100ef0:	56                   	push   %esi
f0100ef1:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ef2:	be 00 00 00 00       	mov    $0x0,%esi
f0100ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100efc:	e9 e1 00 00 00       	jmp    f0100fe2 <page_init+0xf5>
		if(i == 0)
f0100f01:	85 db                	test   %ebx,%ebx
f0100f03:	75 16                	jne    f0100f1b <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100f05:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100f0a:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100f10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f16:	e9 c1 00 00 00       	jmp    f0100fdc <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100f1b:	83 fb 07             	cmp    $0x7,%ebx
f0100f1e:	75 17                	jne    f0100f37 <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100f20:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100f25:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100f2b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f32:	e9 a5 00 00 00       	jmp    f0100fdc <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100f37:	3b 1d 44 b2 22 f0    	cmp    0xf022b244,%ebx
f0100f3d:	73 25                	jae    f0100f64 <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100f3f:	89 f0                	mov    %esi,%eax
f0100f41:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f47:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100f4d:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0100f53:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f55:	89 f0                	mov    %esi,%eax
f0100f57:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f5d:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
f0100f62:	eb 78                	jmp    f0100fdc <page_init+0xef>
f0100f64:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100f6a:	83 f8 5f             	cmp    $0x5f,%eax
f0100f6d:	77 16                	ja     f0100f85 <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100f6f:	89 f0                	mov    %esi,%eax
f0100f71:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100f77:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f83:	eb 57                	jmp    f0100fdc <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f85:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f8b:	76 2c                	jbe    f0100fb9 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100f8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f92:	e8 c9 fa ff ff       	call   f0100a60 <boot_alloc>
f0100f97:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f9c:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f9f:	39 c3                	cmp    %eax,%ebx
f0100fa1:	73 16                	jae    f0100fb9 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100fa3:	89 f0                	mov    %esi,%eax
f0100fa5:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fab:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100fb1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100fb7:	eb 23                	jmp    f0100fdc <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100fb9:	89 f0                	mov    %esi,%eax
f0100fbb:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fc1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100fc7:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f0100fcd:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100fcf:	89 f0                	mov    %esi,%eax
f0100fd1:	03 05 90 be 22 f0    	add    0xf022be90,%eax
f0100fd7:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100fdc:	83 c3 01             	add    $0x1,%ebx
f0100fdf:	83 c6 08             	add    $0x8,%esi
f0100fe2:	3b 1d 88 be 22 f0    	cmp    0xf022be88,%ebx
f0100fe8:	0f 82 13 ff ff ff    	jb     f0100f01 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100fee:	5b                   	pop    %ebx
f0100fef:	5e                   	pop    %esi
f0100ff0:	5d                   	pop    %ebp
f0100ff1:	c3                   	ret    

f0100ff2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ff2:	55                   	push   %ebp
f0100ff3:	89 e5                	mov    %esp,%ebp
f0100ff5:	53                   	push   %ebx
f0100ff6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100ff9:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100fff:	85 db                	test   %ebx,%ebx
f0101001:	74 6f                	je     f0101072 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0101003:	8b 03                	mov    (%ebx),%eax
f0101005:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	page->pp_link = 0;
f010100a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f0101010:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f0101012:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101016:	74 5f                	je     f0101077 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101018:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010101e:	c1 f8 03             	sar    $0x3,%eax
f0101021:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101024:	89 c2                	mov    %eax,%edx
f0101026:	c1 ea 0c             	shr    $0xc,%edx
f0101029:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010102f:	72 20                	jb     f0101051 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101031:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101035:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f010103c:	f0 
f010103d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101044:	00 
f0101045:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f010104c:	e8 ef ef ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0101051:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101058:	00 
f0101059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101060:	00 
	return (void *)(pa + KERNBASE);
f0101061:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101066:	89 04 24             	mov    %eax,(%esp)
f0101069:	e8 69 47 00 00       	call   f01057d7 <memset>
	return page;
f010106e:	89 d8                	mov    %ebx,%eax
f0101070:	eb 05                	jmp    f0101077 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0101072:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
	return 0;
}
f0101077:	83 c4 14             	add    $0x14,%esp
f010107a:	5b                   	pop    %ebx
f010107b:	5d                   	pop    %ebp
f010107c:	c3                   	ret    

f010107d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010107d:	55                   	push   %ebp
f010107e:	89 e5                	mov    %esp,%ebp
f0101080:	83 ec 18             	sub    $0x18,%esp
f0101083:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0101086:	83 38 00             	cmpl   $0x0,(%eax)
f0101089:	75 07                	jne    f0101092 <page_free+0x15>
f010108b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101090:	74 1c                	je     f01010ae <page_free+0x31>
		panic("page_free is not right");
f0101092:	c7 44 24 08 2c 74 10 	movl   $0xf010742c,0x8(%esp)
f0101099:	f0 
f010109a:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f01010a1:	00 
f01010a2:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01010a9:	e8 92 ef ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f01010ae:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
f01010b4:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010b6:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
	return; 
}
f01010bb:	c9                   	leave  
f01010bc:	c3                   	ret    

f01010bd <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010bd:	55                   	push   %ebp
f01010be:	89 e5                	mov    %esp,%ebp
f01010c0:	83 ec 18             	sub    $0x18,%esp
f01010c3:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010c6:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01010ca:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01010cd:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010d1:	66 85 d2             	test   %dx,%dx
f01010d4:	75 08                	jne    f01010de <page_decref+0x21>
		page_free(pp);
f01010d6:	89 04 24             	mov    %eax,(%esp)
f01010d9:	e8 9f ff ff ff       	call   f010107d <page_free>
}
f01010de:	c9                   	leave  
f01010df:	c3                   	ret    

f01010e0 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010e0:	55                   	push   %ebp
f01010e1:	89 e5                	mov    %esp,%ebp
f01010e3:	56                   	push   %esi
f01010e4:	53                   	push   %ebx
f01010e5:	83 ec 10             	sub    $0x10,%esp
f01010e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f01010eb:	89 f3                	mov    %esi,%ebx
f01010ed:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f01010f0:	c1 e3 02             	shl    $0x2,%ebx
f01010f3:	03 5d 08             	add    0x8(%ebp),%ebx
f01010f6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010f9:	75 2c                	jne    f0101127 <pgdir_walk+0x47>
f01010fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010ff:	74 6c                	je     f010116d <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f0101101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101108:	e8 e5 fe ff ff       	call   f0100ff2 <page_alloc>
		if(page == NULL)
f010110d:	85 c0                	test   %eax,%eax
f010110f:	74 63                	je     f0101174 <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f0101111:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101116:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010111c:	c1 f8 03             	sar    $0x3,%eax
f010111f:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0101122:	83 c8 07             	or     $0x7,%eax
f0101125:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f0101127:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f0101129:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f010112e:	c1 ee 0c             	shr    $0xc,%esi
f0101131:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101137:	89 c2                	mov    %eax,%edx
f0101139:	c1 ea 0c             	shr    $0xc,%edx
f010113c:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101142:	72 20                	jb     f0101164 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101144:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101148:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f010114f:	f0 
f0101150:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0101157:	00 
f0101158:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010115f:	e8 dc ee ff ff       	call   f0100040 <_panic>
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
f0101164:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010116b:	eb 0c                	jmp    f0101179 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f010116d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101172:	eb 05                	jmp    f0101179 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0101174:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f0101179:	83 c4 10             	add    $0x10,%esp
f010117c:	5b                   	pop    %ebx
f010117d:	5e                   	pop    %esi
f010117e:	5d                   	pop    %ebp
f010117f:	c3                   	ret    

f0101180 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101180:	55                   	push   %ebp
f0101181:	89 e5                	mov    %esp,%ebp
f0101183:	57                   	push   %edi
f0101184:	56                   	push   %esi
f0101185:	53                   	push   %ebx
f0101186:	83 ec 2c             	sub    $0x2c,%esp
f0101189:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010118c:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size)
f010118e:	89 d3                	mov    %edx,%ebx
f0101190:	8b 45 08             	mov    0x8(%ebp),%eax
f0101193:	29 d0                	sub    %edx,%eax
f0101195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0101198:	8b 45 0c             	mov    0xc(%ebp),%eax
f010119b:	83 c8 01             	or     $0x1,%eax
f010119e:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f01011a1:	eb 2c                	jmp    f01011cf <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f01011a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011aa:	00 
f01011ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011b2:	89 04 24             	mov    %eax,(%esp)
f01011b5:	e8 26 ff ff ff       	call   f01010e0 <pgdir_walk>
		if(pte == NULL)
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	74 1b                	je     f01011d9 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f01011be:	0b 7d dc             	or     -0x24(%ebp),%edi
f01011c1:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f01011c3:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f01011c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011d2:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f01011d5:	85 f6                	test   %esi,%esi
f01011d7:	75 ca                	jne    f01011a3 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f01011d9:	83 c4 2c             	add    $0x2c,%esp
f01011dc:	5b                   	pop    %ebx
f01011dd:	5e                   	pop    %esi
f01011de:	5f                   	pop    %edi
f01011df:	5d                   	pop    %ebp
f01011e0:	c3                   	ret    

f01011e1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011e1:	55                   	push   %ebp
f01011e2:	89 e5                	mov    %esp,%ebp
f01011e4:	53                   	push   %ebx
f01011e5:	83 ec 14             	sub    $0x14,%esp
f01011e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f01011eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011f2:	00 
f01011f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01011fd:	89 04 24             	mov    %eax,(%esp)
f0101200:	e8 db fe ff ff       	call   f01010e0 <pgdir_walk>
	if(pte == NULL)
f0101205:	85 c0                	test   %eax,%eax
f0101207:	74 42                	je     f010124b <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f0101209:	8b 10                	mov    (%eax),%edx
f010120b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f0101211:	85 db                	test   %ebx,%ebx
f0101213:	74 02                	je     f0101217 <page_lookup+0x36>
		*pte_store = pte ;
f0101215:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101217:	89 d0                	mov    %edx,%eax
f0101219:	c1 e8 0c             	shr    $0xc,%eax
f010121c:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0101222:	72 1c                	jb     f0101240 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101224:	c7 44 24 08 00 6b 10 	movl   $0xf0106b00,0x8(%esp)
f010122b:	f0 
f010122c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101233:	00 
f0101234:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f010123b:	e8 00 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101240:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0101246:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f0101249:	eb 05                	jmp    f0101250 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f010124b:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f0101250:	83 c4 14             	add    $0x14,%esp
f0101253:	5b                   	pop    %ebx
f0101254:	5d                   	pop    %ebp
f0101255:	c3                   	ret    

f0101256 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101256:	55                   	push   %ebp
f0101257:	89 e5                	mov    %esp,%ebp
f0101259:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010125c:	e8 c8 4b 00 00       	call   f0105e29 <cpunum>
f0101261:	6b c0 74             	imul   $0x74,%eax,%eax
f0101264:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010126b:	74 16                	je     f0101283 <tlb_invalidate+0x2d>
f010126d:	e8 b7 4b 00 00       	call   f0105e29 <cpunum>
f0101272:	6b c0 74             	imul   $0x74,%eax,%eax
f0101275:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010127b:	8b 55 08             	mov    0x8(%ebp),%edx
f010127e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101281:	75 06                	jne    f0101289 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101283:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101286:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101289:	c9                   	leave  
f010128a:	c3                   	ret    

f010128b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010128b:	55                   	push   %ebp
f010128c:	89 e5                	mov    %esp,%ebp
f010128e:	56                   	push   %esi
f010128f:	53                   	push   %ebx
f0101290:	83 ec 20             	sub    $0x20,%esp
f0101293:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101296:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101299:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010129c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012a0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012a4:	89 1c 24             	mov    %ebx,(%esp)
f01012a7:	e8 35 ff ff ff       	call   f01011e1 <page_lookup>
	if(page == 0)
f01012ac:	85 c0                	test   %eax,%eax
f01012ae:	74 2d                	je     f01012dd <page_remove+0x52>
		return;
	*pte = 0;
f01012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012b3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f01012b9:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01012bd:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01012c0:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f01012c4:	66 85 d2             	test   %dx,%dx
f01012c7:	75 08                	jne    f01012d1 <page_remove+0x46>
		page_free(page);
f01012c9:	89 04 24             	mov    %eax,(%esp)
f01012cc:	e8 ac fd ff ff       	call   f010107d <page_free>
	tlb_invalidate(pgdir, va);
f01012d1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012d5:	89 1c 24             	mov    %ebx,(%esp)
f01012d8:	e8 79 ff ff ff       	call   f0101256 <tlb_invalidate>
}
f01012dd:	83 c4 20             	add    $0x20,%esp
f01012e0:	5b                   	pop    %ebx
f01012e1:	5e                   	pop    %esi
f01012e2:	5d                   	pop    %ebp
f01012e3:	c3                   	ret    

f01012e4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012e4:	55                   	push   %ebp
f01012e5:	89 e5                	mov    %esp,%ebp
f01012e7:	57                   	push   %edi
f01012e8:	56                   	push   %esi
f01012e9:	53                   	push   %ebx
f01012ea:	83 ec 1c             	sub    $0x1c,%esp
f01012ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012f0:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01012f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012fa:	00 
f01012fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101302:	89 04 24             	mov    %eax,(%esp)
f0101305:	e8 d6 fd ff ff       	call   f01010e0 <pgdir_walk>
f010130a:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f010130c:	85 c0                	test   %eax,%eax
f010130e:	74 5a                	je     f010136a <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f0101310:	8b 00                	mov    (%eax),%eax
f0101312:	89 c1                	mov    %eax,%ecx
f0101314:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010131a:	89 da                	mov    %ebx,%edx
f010131c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101322:	c1 fa 03             	sar    $0x3,%edx
f0101325:	c1 e2 0c             	shl    $0xc,%edx
f0101328:	39 d1                	cmp    %edx,%ecx
f010132a:	75 07                	jne    f0101333 <page_insert+0x4f>
		pp->pp_ref--;
f010132c:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101331:	eb 13                	jmp    f0101346 <page_insert+0x62>
	
	else if(*pte != 0)
f0101333:	85 c0                	test   %eax,%eax
f0101335:	74 0f                	je     f0101346 <page_insert+0x62>
		page_remove(pgdir, va);
f0101337:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010133b:	8b 45 08             	mov    0x8(%ebp),%eax
f010133e:	89 04 24             	mov    %eax,(%esp)
f0101341:	e8 45 ff ff ff       	call   f010128b <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f0101346:	8b 55 14             	mov    0x14(%ebp),%edx
f0101349:	83 ca 01             	or     $0x1,%edx
f010134c:	89 d8                	mov    %ebx,%eax
f010134e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101354:	c1 f8 03             	sar    $0x3,%eax
f0101357:	c1 e0 0c             	shl    $0xc,%eax
f010135a:	09 d0                	or     %edx,%eax
f010135c:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010135e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101363:	b8 00 00 00 00       	mov    $0x0,%eax
f0101368:	eb 05                	jmp    f010136f <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f010136a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010136f:	83 c4 1c             	add    $0x1c,%esp
f0101372:	5b                   	pop    %ebx
f0101373:	5e                   	pop    %esi
f0101374:	5f                   	pop    %edi
f0101375:	5d                   	pop    %ebp
f0101376:	c3                   	ret    

f0101377 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101377:	55                   	push   %ebp
f0101378:	89 e5                	mov    %esp,%ebp
f010137a:	53                   	push   %ebx
f010137b:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010137e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101381:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101387:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010138d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101390:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if(size + base >= MMIOLIM)
f0101396:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010139c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010139f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01013a4:	76 1c                	jbe    f01013c2 <mmio_map_region+0x4b>
		panic("mmio_map_region not implemented");
f01013a6:	c7 44 24 08 20 6b 10 	movl   $0xf0106b20,0x8(%esp)
f01013ad:	f0 
f01013ae:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f01013b5:	00 
f01013b6:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01013bd:	e8 7e ec ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01013c2:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01013c9:	00 
f01013ca:	89 0c 24             	mov    %ecx,(%esp)
f01013cd:	89 d9                	mov    %ebx,%ecx
f01013cf:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01013d4:	e8 a7 fd ff ff       	call   f0101180 <boot_map_region>
	uintptr_t ret = base;
f01013d9:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base = base +size;
f01013de:	01 c3                	add    %eax,%ebx
f01013e0:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void*) ret;
}
f01013e6:	83 c4 14             	add    $0x14,%esp
f01013e9:	5b                   	pop    %ebx
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    

f01013ec <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013ec:	55                   	push   %ebp
f01013ed:	89 e5                	mov    %esp,%ebp
f01013ef:	57                   	push   %edi
f01013f0:	56                   	push   %esi
f01013f1:	53                   	push   %ebx
f01013f2:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013f5:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01013fc:	e8 3c 2a 00 00       	call   f0103e3d <mc146818_read>
f0101401:	89 c3                	mov    %eax,%ebx
f0101403:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010140a:	e8 2e 2a 00 00       	call   f0103e3d <mc146818_read>
f010140f:	c1 e0 08             	shl    $0x8,%eax
f0101412:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101414:	89 d8                	mov    %ebx,%eax
f0101416:	c1 e0 0a             	shl    $0xa,%eax
f0101419:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010141f:	85 c0                	test   %eax,%eax
f0101421:	0f 48 c2             	cmovs  %edx,%eax
f0101424:	c1 f8 0c             	sar    $0xc,%eax
f0101427:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010142c:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101433:	e8 05 2a 00 00       	call   f0103e3d <mc146818_read>
f0101438:	89 c3                	mov    %eax,%ebx
f010143a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101441:	e8 f7 29 00 00       	call   f0103e3d <mc146818_read>
f0101446:	c1 e0 08             	shl    $0x8,%eax
f0101449:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010144b:	89 d8                	mov    %ebx,%eax
f010144d:	c1 e0 0a             	shl    $0xa,%eax
f0101450:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101456:	85 c0                	test   %eax,%eax
f0101458:	0f 48 c2             	cmovs  %edx,%eax
f010145b:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010145e:	85 c0                	test   %eax,%eax
f0101460:	74 0e                	je     f0101470 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101462:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101468:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
f010146e:	eb 0c                	jmp    f010147c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101470:	8b 15 44 b2 22 f0    	mov    0xf022b244,%edx
f0101476:	89 15 88 be 22 f0    	mov    %edx,0xf022be88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010147c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010147f:	c1 e8 0a             	shr    $0xa,%eax
f0101482:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101486:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f010148b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010148e:	c1 e8 0a             	shr    $0xa,%eax
f0101491:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101495:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010149a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010149d:	c1 e8 0a             	shr    $0xa,%eax
f01014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014a4:	c7 04 24 40 6b 10 f0 	movl   $0xf0106b40,(%esp)
f01014ab:	e8 f6 2a 00 00       	call   f0103fa6 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014b0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014b5:	e8 a6 f5 ff ff       	call   f0100a60 <boot_alloc>
f01014ba:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f01014bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014c6:	00 
f01014c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ce:	00 
f01014cf:	89 04 24             	mov    %eax,(%esp)
f01014d2:	e8 00 43 00 00       	call   f01057d7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014d7:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014e1:	77 20                	ja     f0101503 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014e7:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f01014ee:	f0 
f01014ef:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014f6:	00 
f01014f7:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01014fe:	e8 3d eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101503:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101509:	83 ca 05             	or     $0x5,%edx
f010150c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f0101512:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101517:	c1 e0 03             	shl    $0x3,%eax
f010151a:	e8 41 f5 ff ff       	call   f0100a60 <boot_alloc>
f010151f:	a3 90 be 22 f0       	mov    %eax,0xf022be90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101524:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f010152a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101531:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101535:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010153c:	00 
f010153d:	89 04 24             	mov    %eax,(%esp)
f0101540:	e8 92 42 00 00       	call   f01057d7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101545:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010154a:	e8 11 f5 ff ff       	call   f0100a60 <boot_alloc>
f010154f:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101554:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010155b:	00 
f010155c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101563:	00 
f0101564:	89 04 24             	mov    %eax,(%esp)
f0101567:	e8 6b 42 00 00       	call   f01057d7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010156c:	e8 7c f9 ff ff       	call   f0100eed <page_init>

	check_page_free_list(1);
f0101571:	b8 01 00 00 00       	mov    $0x1,%eax
f0101576:	e8 dc f5 ff ff       	call   f0100b57 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010157b:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101582:	75 1c                	jne    f01015a0 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f0101584:	c7 44 24 08 43 74 10 	movl   $0xf0107443,0x8(%esp)
f010158b:	f0 
f010158c:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101593:	00 
f0101594:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010159b:	e8 a0 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015a0:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f01015a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015aa:	eb 05                	jmp    f01015b1 <mem_init+0x1c5>
		++nfree;
f01015ac:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015af:	8b 00                	mov    (%eax),%eax
f01015b1:	85 c0                	test   %eax,%eax
f01015b3:	75 f7                	jne    f01015ac <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015bc:	e8 31 fa ff ff       	call   f0100ff2 <page_alloc>
f01015c1:	89 c7                	mov    %eax,%edi
f01015c3:	85 c0                	test   %eax,%eax
f01015c5:	75 24                	jne    f01015eb <mem_init+0x1ff>
f01015c7:	c7 44 24 0c 5e 74 10 	movl   $0xf010745e,0xc(%esp)
f01015ce:	f0 
f01015cf:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01015d6:	f0 
f01015d7:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01015de:	00 
f01015df:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01015e6:	e8 55 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f2:	e8 fb f9 ff ff       	call   f0100ff2 <page_alloc>
f01015f7:	89 c6                	mov    %eax,%esi
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	75 24                	jne    f0101621 <mem_init+0x235>
f01015fd:	c7 44 24 0c 74 74 10 	movl   $0xf0107474,0xc(%esp)
f0101604:	f0 
f0101605:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010160c:	f0 
f010160d:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101614:	00 
f0101615:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010161c:	e8 1f ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101628:	e8 c5 f9 ff ff       	call   f0100ff2 <page_alloc>
f010162d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101630:	85 c0                	test   %eax,%eax
f0101632:	75 24                	jne    f0101658 <mem_init+0x26c>
f0101634:	c7 44 24 0c 8a 74 10 	movl   $0xf010748a,0xc(%esp)
f010163b:	f0 
f010163c:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101643:	f0 
f0101644:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010164b:	00 
f010164c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101658:	39 f7                	cmp    %esi,%edi
f010165a:	75 24                	jne    f0101680 <mem_init+0x294>
f010165c:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0101663:	f0 
f0101664:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010166b:	f0 
f010166c:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101673:	00 
f0101674:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010167b:	e8 c0 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101680:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101683:	39 c6                	cmp    %eax,%esi
f0101685:	74 04                	je     f010168b <mem_init+0x29f>
f0101687:	39 c7                	cmp    %eax,%edi
f0101689:	75 24                	jne    f01016af <mem_init+0x2c3>
f010168b:	c7 44 24 0c 7c 6b 10 	movl   $0xf0106b7c,0xc(%esp)
f0101692:	f0 
f0101693:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010169a:	f0 
f010169b:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01016a2:	00 
f01016a3:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01016aa:	e8 91 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016af:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016b5:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01016ba:	c1 e0 0c             	shl    $0xc,%eax
f01016bd:	89 f9                	mov    %edi,%ecx
f01016bf:	29 d1                	sub    %edx,%ecx
f01016c1:	c1 f9 03             	sar    $0x3,%ecx
f01016c4:	c1 e1 0c             	shl    $0xc,%ecx
f01016c7:	39 c1                	cmp    %eax,%ecx
f01016c9:	72 24                	jb     f01016ef <mem_init+0x303>
f01016cb:	c7 44 24 0c b2 74 10 	movl   $0xf01074b2,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01016ea:	e8 51 e9 ff ff       	call   f0100040 <_panic>
f01016ef:	89 f1                	mov    %esi,%ecx
f01016f1:	29 d1                	sub    %edx,%ecx
f01016f3:	c1 f9 03             	sar    $0x3,%ecx
f01016f6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f9:	39 c8                	cmp    %ecx,%eax
f01016fb:	77 24                	ja     f0101721 <mem_init+0x335>
f01016fd:	c7 44 24 0c cf 74 10 	movl   $0xf01074cf,0xc(%esp)
f0101704:	f0 
f0101705:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010170c:	f0 
f010170d:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101714:	00 
f0101715:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010171c:	e8 1f e9 ff ff       	call   f0100040 <_panic>
f0101721:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101724:	29 d1                	sub    %edx,%ecx
f0101726:	89 ca                	mov    %ecx,%edx
f0101728:	c1 fa 03             	sar    $0x3,%edx
f010172b:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010172e:	39 d0                	cmp    %edx,%eax
f0101730:	77 24                	ja     f0101756 <mem_init+0x36a>
f0101732:	c7 44 24 0c ec 74 10 	movl   $0xf01074ec,0xc(%esp)
f0101739:	f0 
f010173a:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101741:	f0 
f0101742:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101749:	00 
f010174a:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101751:	e8 ea e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101756:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010175b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010175e:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101765:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101768:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176f:	e8 7e f8 ff ff       	call   f0100ff2 <page_alloc>
f0101774:	85 c0                	test   %eax,%eax
f0101776:	74 24                	je     f010179c <mem_init+0x3b0>
f0101778:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f010177f:	f0 
f0101780:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101787:	f0 
f0101788:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f010178f:	00 
f0101790:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010179c:	89 3c 24             	mov    %edi,(%esp)
f010179f:	e8 d9 f8 ff ff       	call   f010107d <page_free>
	page_free(pp1);
f01017a4:	89 34 24             	mov    %esi,(%esp)
f01017a7:	e8 d1 f8 ff ff       	call   f010107d <page_free>
	page_free(pp2);
f01017ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017af:	89 04 24             	mov    %eax,(%esp)
f01017b2:	e8 c6 f8 ff ff       	call   f010107d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017be:	e8 2f f8 ff ff       	call   f0100ff2 <page_alloc>
f01017c3:	89 c6                	mov    %eax,%esi
f01017c5:	85 c0                	test   %eax,%eax
f01017c7:	75 24                	jne    f01017ed <mem_init+0x401>
f01017c9:	c7 44 24 0c 5e 74 10 	movl   $0xf010745e,0xc(%esp)
f01017d0:	f0 
f01017d1:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01017d8:	f0 
f01017d9:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01017e0:	00 
f01017e1:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01017e8:	e8 53 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f4:	e8 f9 f7 ff ff       	call   f0100ff2 <page_alloc>
f01017f9:	89 c7                	mov    %eax,%edi
f01017fb:	85 c0                	test   %eax,%eax
f01017fd:	75 24                	jne    f0101823 <mem_init+0x437>
f01017ff:	c7 44 24 0c 74 74 10 	movl   $0xf0107474,0xc(%esp)
f0101806:	f0 
f0101807:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010180e:	f0 
f010180f:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101816:	00 
f0101817:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010181e:	e8 1d e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010182a:	e8 c3 f7 ff ff       	call   f0100ff2 <page_alloc>
f010182f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101832:	85 c0                	test   %eax,%eax
f0101834:	75 24                	jne    f010185a <mem_init+0x46e>
f0101836:	c7 44 24 0c 8a 74 10 	movl   $0xf010748a,0xc(%esp)
f010183d:	f0 
f010183e:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101845:	f0 
f0101846:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010184d:	00 
f010184e:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101855:	e8 e6 e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010185a:	39 fe                	cmp    %edi,%esi
f010185c:	75 24                	jne    f0101882 <mem_init+0x496>
f010185e:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0101865:	f0 
f0101866:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010186d:	f0 
f010186e:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101875:	00 
f0101876:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010187d:	e8 be e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101885:	39 c7                	cmp    %eax,%edi
f0101887:	74 04                	je     f010188d <mem_init+0x4a1>
f0101889:	39 c6                	cmp    %eax,%esi
f010188b:	75 24                	jne    f01018b1 <mem_init+0x4c5>
f010188d:	c7 44 24 0c 7c 6b 10 	movl   $0xf0106b7c,0xc(%esp)
f0101894:	f0 
f0101895:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010189c:	f0 
f010189d:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f01018a4:	00 
f01018a5:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01018ac:	e8 8f e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018b8:	e8 35 f7 ff ff       	call   f0100ff2 <page_alloc>
f01018bd:	85 c0                	test   %eax,%eax
f01018bf:	74 24                	je     f01018e5 <mem_init+0x4f9>
f01018c1:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f01018c8:	f0 
f01018c9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01018d0:	f0 
f01018d1:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01018d8:	00 
f01018d9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01018e0:	e8 5b e7 ff ff       	call   f0100040 <_panic>
f01018e5:	89 f0                	mov    %esi,%eax
f01018e7:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01018ed:	c1 f8 03             	sar    $0x3,%eax
f01018f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f3:	89 c2                	mov    %eax,%edx
f01018f5:	c1 ea 0c             	shr    $0xc,%edx
f01018f8:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01018fe:	72 20                	jb     f0101920 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101900:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101904:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f010190b:	f0 
f010190c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101913:	00 
f0101914:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f010191b:	e8 20 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101920:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101927:	00 
f0101928:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010192f:	00 
	return (void *)(pa + KERNBASE);
f0101930:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101935:	89 04 24             	mov    %eax,(%esp)
f0101938:	e8 9a 3e 00 00       	call   f01057d7 <memset>
	page_free(pp0);
f010193d:	89 34 24             	mov    %esi,(%esp)
f0101940:	e8 38 f7 ff ff       	call   f010107d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101945:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010194c:	e8 a1 f6 ff ff       	call   f0100ff2 <page_alloc>
f0101951:	85 c0                	test   %eax,%eax
f0101953:	75 24                	jne    f0101979 <mem_init+0x58d>
f0101955:	c7 44 24 0c 18 75 10 	movl   $0xf0107518,0xc(%esp)
f010195c:	f0 
f010195d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101964:	f0 
f0101965:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010196c:	00 
f010196d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101974:	e8 c7 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101979:	39 c6                	cmp    %eax,%esi
f010197b:	74 24                	je     f01019a1 <mem_init+0x5b5>
f010197d:	c7 44 24 0c 36 75 10 	movl   $0xf0107536,0xc(%esp)
f0101984:	f0 
f0101985:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010198c:	f0 
f010198d:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101994:	00 
f0101995:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010199c:	e8 9f e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019a1:	89 f0                	mov    %esi,%eax
f01019a3:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01019a9:	c1 f8 03             	sar    $0x3,%eax
f01019ac:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019af:	89 c2                	mov    %eax,%edx
f01019b1:	c1 ea 0c             	shr    $0xc,%edx
f01019b4:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01019ba:	72 20                	jb     f01019dc <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019c0:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f01019c7:	f0 
f01019c8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019cf:	00 
f01019d0:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f01019d7:	e8 64 e6 ff ff       	call   f0100040 <_panic>
f01019dc:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01019e2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01019e8:	80 38 00             	cmpb   $0x0,(%eax)
f01019eb:	74 24                	je     f0101a11 <mem_init+0x625>
f01019ed:	c7 44 24 0c 46 75 10 	movl   $0xf0107546,0xc(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01019fc:	f0 
f01019fd:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101a04:	00 
f0101a05:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101a0c:	e8 2f e6 ff ff       	call   f0100040 <_panic>
f0101a11:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a14:	39 d0                	cmp    %edx,%eax
f0101a16:	75 d0                	jne    f01019e8 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a18:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a1b:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101a20:	89 34 24             	mov    %esi,(%esp)
f0101a23:	e8 55 f6 ff ff       	call   f010107d <page_free>
	page_free(pp1);
f0101a28:	89 3c 24             	mov    %edi,(%esp)
f0101a2b:	e8 4d f6 ff ff       	call   f010107d <page_free>
	page_free(pp2);
f0101a30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a33:	89 04 24             	mov    %eax,(%esp)
f0101a36:	e8 42 f6 ff ff       	call   f010107d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a3b:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101a40:	eb 05                	jmp    f0101a47 <mem_init+0x65b>
		--nfree;
f0101a42:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a45:	8b 00                	mov    (%eax),%eax
f0101a47:	85 c0                	test   %eax,%eax
f0101a49:	75 f7                	jne    f0101a42 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f0101a4b:	85 db                	test   %ebx,%ebx
f0101a4d:	74 24                	je     f0101a73 <mem_init+0x687>
f0101a4f:	c7 44 24 0c 50 75 10 	movl   $0xf0107550,0xc(%esp)
f0101a56:	f0 
f0101a57:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101a5e:	f0 
f0101a5f:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a66:	00 
f0101a67:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101a6e:	e8 cd e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a73:	c7 04 24 9c 6b 10 f0 	movl   $0xf0106b9c,(%esp)
f0101a7a:	e8 27 25 00 00       	call   f0103fa6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a86:	e8 67 f5 ff ff       	call   f0100ff2 <page_alloc>
f0101a8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a8e:	85 c0                	test   %eax,%eax
f0101a90:	75 24                	jne    f0101ab6 <mem_init+0x6ca>
f0101a92:	c7 44 24 0c 5e 74 10 	movl   $0xf010745e,0xc(%esp)
f0101a99:	f0 
f0101a9a:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101aa1:	f0 
f0101aa2:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0101aa9:	00 
f0101aaa:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101ab1:	e8 8a e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ab6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101abd:	e8 30 f5 ff ff       	call   f0100ff2 <page_alloc>
f0101ac2:	89 c3                	mov    %eax,%ebx
f0101ac4:	85 c0                	test   %eax,%eax
f0101ac6:	75 24                	jne    f0101aec <mem_init+0x700>
f0101ac8:	c7 44 24 0c 74 74 10 	movl   $0xf0107474,0xc(%esp)
f0101acf:	f0 
f0101ad0:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101ad7:	f0 
f0101ad8:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101adf:	00 
f0101ae0:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101ae7:	e8 54 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101aec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101af3:	e8 fa f4 ff ff       	call   f0100ff2 <page_alloc>
f0101af8:	89 c6                	mov    %eax,%esi
f0101afa:	85 c0                	test   %eax,%eax
f0101afc:	75 24                	jne    f0101b22 <mem_init+0x736>
f0101afe:	c7 44 24 0c 8a 74 10 	movl   $0xf010748a,0xc(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101b0d:	f0 
f0101b0e:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101b15:	00 
f0101b16:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101b1d:	e8 1e e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b22:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101b25:	75 24                	jne    f0101b4b <mem_init+0x75f>
f0101b27:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101b3e:	00 
f0101b3f:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b4b:	39 c3                	cmp    %eax,%ebx
f0101b4d:	74 05                	je     f0101b54 <mem_init+0x768>
f0101b4f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b52:	75 24                	jne    f0101b78 <mem_init+0x78c>
f0101b54:	c7 44 24 0c 7c 6b 10 	movl   $0xf0106b7c,0xc(%esp)
f0101b5b:	f0 
f0101b5c:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101b63:	f0 
f0101b64:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b6b:	00 
f0101b6c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101b73:	e8 c8 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b78:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101b7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b80:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101b87:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b91:	e8 5c f4 ff ff       	call   f0100ff2 <page_alloc>
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	74 24                	je     f0101bbe <mem_init+0x7d2>
f0101b9a:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f0101ba1:	f0 
f0101ba2:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101ba9:	f0 
f0101baa:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101bb1:	00 
f0101bb2:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101bb9:	e8 82 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bcc:	00 
f0101bcd:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101bd2:	89 04 24             	mov    %eax,(%esp)
f0101bd5:	e8 07 f6 ff ff       	call   f01011e1 <page_lookup>
f0101bda:	85 c0                	test   %eax,%eax
f0101bdc:	74 24                	je     f0101c02 <mem_init+0x816>
f0101bde:	c7 44 24 0c bc 6b 10 	movl   $0xf0106bbc,0xc(%esp)
f0101be5:	f0 
f0101be6:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101bed:	f0 
f0101bee:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101bf5:	00 
f0101bf6:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101bfd:	e8 3e e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c02:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c09:	00 
f0101c0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c11:	00 
f0101c12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c16:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101c1b:	89 04 24             	mov    %eax,(%esp)
f0101c1e:	e8 c1 f6 ff ff       	call   f01012e4 <page_insert>
f0101c23:	85 c0                	test   %eax,%eax
f0101c25:	78 24                	js     f0101c4b <mem_init+0x85f>
f0101c27:	c7 44 24 0c f4 6b 10 	movl   $0xf0106bf4,0xc(%esp)
f0101c2e:	f0 
f0101c2f:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101c36:	f0 
f0101c37:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101c3e:	00 
f0101c3f:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101c46:	e8 f5 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c4e:	89 04 24             	mov    %eax,(%esp)
f0101c51:	e8 27 f4 ff ff       	call   f010107d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c56:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c5d:	00 
f0101c5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c65:	00 
f0101c66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c6a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101c6f:	89 04 24             	mov    %eax,(%esp)
f0101c72:	e8 6d f6 ff ff       	call   f01012e4 <page_insert>
f0101c77:	85 c0                	test   %eax,%eax
f0101c79:	74 24                	je     f0101c9f <mem_init+0x8b3>
f0101c7b:	c7 44 24 0c 24 6c 10 	movl   $0xf0106c24,0xc(%esp)
f0101c82:	f0 
f0101c83:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101c8a:	f0 
f0101c8b:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101c92:	00 
f0101c93:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101c9a:	e8 a1 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c9f:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ca5:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101caa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cad:	8b 17                	mov    (%edi),%edx
f0101caf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cb5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101cb8:	29 c1                	sub    %eax,%ecx
f0101cba:	89 c8                	mov    %ecx,%eax
f0101cbc:	c1 f8 03             	sar    $0x3,%eax
f0101cbf:	c1 e0 0c             	shl    $0xc,%eax
f0101cc2:	39 c2                	cmp    %eax,%edx
f0101cc4:	74 24                	je     f0101cea <mem_init+0x8fe>
f0101cc6:	c7 44 24 0c 54 6c 10 	movl   $0xf0106c54,0xc(%esp)
f0101ccd:	f0 
f0101cce:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101cd5:	f0 
f0101cd6:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101cdd:	00 
f0101cde:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101ce5:	e8 56 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cea:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cef:	89 f8                	mov    %edi,%eax
f0101cf1:	e8 f2 ed ff ff       	call   f0100ae8 <check_va2pa>
f0101cf6:	89 da                	mov    %ebx,%edx
f0101cf8:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101cfb:	c1 fa 03             	sar    $0x3,%edx
f0101cfe:	c1 e2 0c             	shl    $0xc,%edx
f0101d01:	39 d0                	cmp    %edx,%eax
f0101d03:	74 24                	je     f0101d29 <mem_init+0x93d>
f0101d05:	c7 44 24 0c 7c 6c 10 	movl   $0xf0106c7c,0xc(%esp)
f0101d0c:	f0 
f0101d0d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101d14:	f0 
f0101d15:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101d1c:	00 
f0101d1d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101d24:	e8 17 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d29:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d2e:	74 24                	je     f0101d54 <mem_init+0x968>
f0101d30:	c7 44 24 0c 5b 75 10 	movl   $0xf010755b,0xc(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101d3f:	f0 
f0101d40:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101d47:	00 
f0101d48:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101d4f:	e8 ec e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d57:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d5c:	74 24                	je     f0101d82 <mem_init+0x996>
f0101d5e:	c7 44 24 0c 6c 75 10 	movl   $0xf010756c,0xc(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101d75:	00 
f0101d76:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101d7d:	e8 be e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d82:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d89:	00 
f0101d8a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d91:	00 
f0101d92:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d96:	89 3c 24             	mov    %edi,(%esp)
f0101d99:	e8 46 f5 ff ff       	call   f01012e4 <page_insert>
f0101d9e:	85 c0                	test   %eax,%eax
f0101da0:	74 24                	je     f0101dc6 <mem_init+0x9da>
f0101da2:	c7 44 24 0c ac 6c 10 	movl   $0xf0106cac,0xc(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101db9:	00 
f0101dba:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101dc1:	e8 7a e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dc6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dcb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101dd0:	e8 13 ed ff ff       	call   f0100ae8 <check_va2pa>
f0101dd5:	89 f2                	mov    %esi,%edx
f0101dd7:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101ddd:	c1 fa 03             	sar    $0x3,%edx
f0101de0:	c1 e2 0c             	shl    $0xc,%edx
f0101de3:	39 d0                	cmp    %edx,%eax
f0101de5:	74 24                	je     f0101e0b <mem_init+0xa1f>
f0101de7:	c7 44 24 0c e8 6c 10 	movl   $0xf0106ce8,0xc(%esp)
f0101dee:	f0 
f0101def:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101df6:	f0 
f0101df7:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101dfe:	00 
f0101dff:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101e06:	e8 35 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e0b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e10:	74 24                	je     f0101e36 <mem_init+0xa4a>
f0101e12:	c7 44 24 0c 7d 75 10 	movl   $0xf010757d,0xc(%esp)
f0101e19:	f0 
f0101e1a:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101e31:	e8 0a e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e3d:	e8 b0 f1 ff ff       	call   f0100ff2 <page_alloc>
f0101e42:	85 c0                	test   %eax,%eax
f0101e44:	74 24                	je     f0101e6a <mem_init+0xa7e>
f0101e46:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101e55:	f0 
f0101e56:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101e5d:	00 
f0101e5e:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101e65:	e8 d6 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e6a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e71:	00 
f0101e72:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e79:	00 
f0101e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e83:	89 04 24             	mov    %eax,(%esp)
f0101e86:	e8 59 f4 ff ff       	call   f01012e4 <page_insert>
f0101e8b:	85 c0                	test   %eax,%eax
f0101e8d:	74 24                	je     f0101eb3 <mem_init+0xac7>
f0101e8f:	c7 44 24 0c ac 6c 10 	movl   $0xf0106cac,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101eae:	e8 8d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eb3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eb8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101ebd:	e8 26 ec ff ff       	call   f0100ae8 <check_va2pa>
f0101ec2:	89 f2                	mov    %esi,%edx
f0101ec4:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101eca:	c1 fa 03             	sar    $0x3,%edx
f0101ecd:	c1 e2 0c             	shl    $0xc,%edx
f0101ed0:	39 d0                	cmp    %edx,%eax
f0101ed2:	74 24                	je     f0101ef8 <mem_init+0xb0c>
f0101ed4:	c7 44 24 0c e8 6c 10 	movl   $0xf0106ce8,0xc(%esp)
f0101edb:	f0 
f0101edc:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101ee3:	f0 
f0101ee4:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101eeb:	00 
f0101eec:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101ef3:	e8 48 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ef8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101efd:	74 24                	je     f0101f23 <mem_init+0xb37>
f0101eff:	c7 44 24 0c 7d 75 10 	movl   $0xf010757d,0xc(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101f0e:	f0 
f0101f0f:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101f16:	00 
f0101f17:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101f1e:	e8 1d e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2a:	e8 c3 f0 ff ff       	call   f0100ff2 <page_alloc>
f0101f2f:	85 c0                	test   %eax,%eax
f0101f31:	74 24                	je     f0101f57 <mem_init+0xb6b>
f0101f33:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101f42:	f0 
f0101f43:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101f4a:	00 
f0101f4b:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f57:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0101f5d:	8b 02                	mov    (%edx),%eax
f0101f5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f64:	89 c1                	mov    %eax,%ecx
f0101f66:	c1 e9 0c             	shr    $0xc,%ecx
f0101f69:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0101f6f:	72 20                	jb     f0101f91 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f75:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0101f7c:	f0 
f0101f7d:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101f84:	00 
f0101f85:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f91:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa0:	00 
f0101fa1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fa8:	00 
f0101fa9:	89 14 24             	mov    %edx,(%esp)
f0101fac:	e8 2f f1 ff ff       	call   f01010e0 <pgdir_walk>
f0101fb1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fb4:	8d 51 04             	lea    0x4(%ecx),%edx
f0101fb7:	39 d0                	cmp    %edx,%eax
f0101fb9:	74 24                	je     f0101fdf <mem_init+0xbf3>
f0101fbb:	c7 44 24 0c 18 6d 10 	movl   $0xf0106d18,0xc(%esp)
f0101fc2:	f0 
f0101fc3:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101fd2:	00 
f0101fd3:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0101fda:	e8 61 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fdf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101fe6:	00 
f0101fe7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fee:	00 
f0101fef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ff3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101ff8:	89 04 24             	mov    %eax,(%esp)
f0101ffb:	e8 e4 f2 ff ff       	call   f01012e4 <page_insert>
f0102000:	85 c0                	test   %eax,%eax
f0102002:	74 24                	je     f0102028 <mem_init+0xc3c>
f0102004:	c7 44 24 0c 58 6d 10 	movl   $0xf0106d58,0xc(%esp)
f010200b:	f0 
f010200c:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102013:	f0 
f0102014:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010201b:	00 
f010201c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102023:	e8 18 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102028:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f010202e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102033:	89 f8                	mov    %edi,%eax
f0102035:	e8 ae ea ff ff       	call   f0100ae8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010203a:	89 f2                	mov    %esi,%edx
f010203c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102042:	c1 fa 03             	sar    $0x3,%edx
f0102045:	c1 e2 0c             	shl    $0xc,%edx
f0102048:	39 d0                	cmp    %edx,%eax
f010204a:	74 24                	je     f0102070 <mem_init+0xc84>
f010204c:	c7 44 24 0c e8 6c 10 	movl   $0xf0106ce8,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010206b:	e8 d0 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102070:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102075:	74 24                	je     f010209b <mem_init+0xcaf>
f0102077:	c7 44 24 0c 7d 75 10 	movl   $0xf010757d,0xc(%esp)
f010207e:	f0 
f010207f:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102086:	f0 
f0102087:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010208e:	00 
f010208f:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102096:	e8 a5 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010209b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020a2:	00 
f01020a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020aa:	00 
f01020ab:	89 3c 24             	mov    %edi,(%esp)
f01020ae:	e8 2d f0 ff ff       	call   f01010e0 <pgdir_walk>
f01020b3:	f6 00 04             	testb  $0x4,(%eax)
f01020b6:	75 24                	jne    f01020dc <mem_init+0xcf0>
f01020b8:	c7 44 24 0c 98 6d 10 	movl   $0xf0106d98,0xc(%esp)
f01020bf:	f0 
f01020c0:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f01020cf:	00 
f01020d0:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01020d7:	e8 64 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020dc:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01020e1:	f6 00 04             	testb  $0x4,(%eax)
f01020e4:	75 24                	jne    f010210a <mem_init+0xd1e>
f01020e6:	c7 44 24 0c 8e 75 10 	movl   $0xf010758e,0xc(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01020fd:	00 
f01020fe:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102105:	e8 36 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010210a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102111:	00 
f0102112:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102119:	00 
f010211a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010211e:	89 04 24             	mov    %eax,(%esp)
f0102121:	e8 be f1 ff ff       	call   f01012e4 <page_insert>
f0102126:	85 c0                	test   %eax,%eax
f0102128:	74 24                	je     f010214e <mem_init+0xd62>
f010212a:	c7 44 24 0c ac 6c 10 	movl   $0xf0106cac,0xc(%esp)
f0102131:	f0 
f0102132:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102139:	f0 
f010213a:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102141:	00 
f0102142:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102149:	e8 f2 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010214e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102155:	00 
f0102156:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010215d:	00 
f010215e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102163:	89 04 24             	mov    %eax,(%esp)
f0102166:	e8 75 ef ff ff       	call   f01010e0 <pgdir_walk>
f010216b:	f6 00 02             	testb  $0x2,(%eax)
f010216e:	75 24                	jne    f0102194 <mem_init+0xda8>
f0102170:	c7 44 24 0c cc 6d 10 	movl   $0xf0106dcc,0xc(%esp)
f0102177:	f0 
f0102178:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010217f:	f0 
f0102180:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102187:	00 
f0102188:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010218f:	e8 ac de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102194:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010219b:	00 
f010219c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021a3:	00 
f01021a4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01021a9:	89 04 24             	mov    %eax,(%esp)
f01021ac:	e8 2f ef ff ff       	call   f01010e0 <pgdir_walk>
f01021b1:	f6 00 04             	testb  $0x4,(%eax)
f01021b4:	74 24                	je     f01021da <mem_init+0xdee>
f01021b6:	c7 44 24 0c 00 6e 10 	movl   $0xf0106e00,0xc(%esp)
f01021bd:	f0 
f01021be:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01021c5:	f0 
f01021c6:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01021cd:	00 
f01021ce:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01021d5:	e8 66 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021da:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021e1:	00 
f01021e2:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01021e9:	00 
f01021ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021f1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01021f6:	89 04 24             	mov    %eax,(%esp)
f01021f9:	e8 e6 f0 ff ff       	call   f01012e4 <page_insert>
f01021fe:	85 c0                	test   %eax,%eax
f0102200:	78 24                	js     f0102226 <mem_init+0xe3a>
f0102202:	c7 44 24 0c 38 6e 10 	movl   $0xf0106e38,0xc(%esp)
f0102209:	f0 
f010220a:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102211:	f0 
f0102212:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102219:	00 
f010221a:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102221:	e8 1a de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102226:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010222d:	00 
f010222e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102235:	00 
f0102236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010223a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010223f:	89 04 24             	mov    %eax,(%esp)
f0102242:	e8 9d f0 ff ff       	call   f01012e4 <page_insert>
f0102247:	85 c0                	test   %eax,%eax
f0102249:	74 24                	je     f010226f <mem_init+0xe83>
f010224b:	c7 44 24 0c 70 6e 10 	movl   $0xf0106e70,0xc(%esp)
f0102252:	f0 
f0102253:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010225a:	f0 
f010225b:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102262:	00 
f0102263:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010226a:	e8 d1 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010226f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102276:	00 
f0102277:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010227e:	00 
f010227f:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102284:	89 04 24             	mov    %eax,(%esp)
f0102287:	e8 54 ee ff ff       	call   f01010e0 <pgdir_walk>
f010228c:	f6 00 04             	testb  $0x4,(%eax)
f010228f:	74 24                	je     f01022b5 <mem_init+0xec9>
f0102291:	c7 44 24 0c 00 6e 10 	movl   $0xf0106e00,0xc(%esp)
f0102298:	f0 
f0102299:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01022a0:	f0 
f01022a1:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01022a8:	00 
f01022a9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01022b0:	e8 8b dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022b5:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01022bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01022c0:	89 f8                	mov    %edi,%eax
f01022c2:	e8 21 e8 ff ff       	call   f0100ae8 <check_va2pa>
f01022c7:	89 c1                	mov    %eax,%ecx
f01022c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022cc:	89 d8                	mov    %ebx,%eax
f01022ce:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01022d4:	c1 f8 03             	sar    $0x3,%eax
f01022d7:	c1 e0 0c             	shl    $0xc,%eax
f01022da:	39 c1                	cmp    %eax,%ecx
f01022dc:	74 24                	je     f0102302 <mem_init+0xf16>
f01022de:	c7 44 24 0c ac 6e 10 	movl   $0xf0106eac,0xc(%esp)
f01022e5:	f0 
f01022e6:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01022ed:	f0 
f01022ee:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f01022f5:	00 
f01022f6:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01022fd:	e8 3e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102302:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102307:	89 f8                	mov    %edi,%eax
f0102309:	e8 da e7 ff ff       	call   f0100ae8 <check_va2pa>
f010230e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102311:	74 24                	je     f0102337 <mem_init+0xf4b>
f0102313:	c7 44 24 0c d8 6e 10 	movl   $0xf0106ed8,0xc(%esp)
f010231a:	f0 
f010231b:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102322:	f0 
f0102323:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010232a:	00 
f010232b:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102337:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010233c:	74 24                	je     f0102362 <mem_init+0xf76>
f010233e:	c7 44 24 0c a4 75 10 	movl   $0xf01075a4,0xc(%esp)
f0102345:	f0 
f0102346:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010234d:	f0 
f010234e:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102355:	00 
f0102356:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010235d:	e8 de dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102362:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102367:	74 24                	je     f010238d <mem_init+0xfa1>
f0102369:	c7 44 24 0c b5 75 10 	movl   $0xf01075b5,0xc(%esp)
f0102370:	f0 
f0102371:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102378:	f0 
f0102379:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102380:	00 
f0102381:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010238d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102394:	e8 59 ec ff ff       	call   f0100ff2 <page_alloc>
f0102399:	85 c0                	test   %eax,%eax
f010239b:	74 04                	je     f01023a1 <mem_init+0xfb5>
f010239d:	39 c6                	cmp    %eax,%esi
f010239f:	74 24                	je     f01023c5 <mem_init+0xfd9>
f01023a1:	c7 44 24 0c 08 6f 10 	movl   $0xf0106f08,0xc(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01023b8:	00 
f01023b9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01023c0:	e8 7b dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01023cc:	00 
f01023cd:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01023d2:	89 04 24             	mov    %eax,(%esp)
f01023d5:	e8 b1 ee ff ff       	call   f010128b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023da:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01023e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01023e5:	89 f8                	mov    %edi,%eax
f01023e7:	e8 fc e6 ff ff       	call   f0100ae8 <check_va2pa>
f01023ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023ef:	74 24                	je     f0102415 <mem_init+0x1029>
f01023f1:	c7 44 24 0c 2c 6f 10 	movl   $0xf0106f2c,0xc(%esp)
f01023f8:	f0 
f01023f9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102400:	f0 
f0102401:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102408:	00 
f0102409:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102410:	e8 2b dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102415:	ba 00 10 00 00       	mov    $0x1000,%edx
f010241a:	89 f8                	mov    %edi,%eax
f010241c:	e8 c7 e6 ff ff       	call   f0100ae8 <check_va2pa>
f0102421:	89 da                	mov    %ebx,%edx
f0102423:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102429:	c1 fa 03             	sar    $0x3,%edx
f010242c:	c1 e2 0c             	shl    $0xc,%edx
f010242f:	39 d0                	cmp    %edx,%eax
f0102431:	74 24                	je     f0102457 <mem_init+0x106b>
f0102433:	c7 44 24 0c d8 6e 10 	movl   $0xf0106ed8,0xc(%esp)
f010243a:	f0 
f010243b:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102442:	f0 
f0102443:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f010244a:	00 
f010244b:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102452:	e8 e9 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102457:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010245c:	74 24                	je     f0102482 <mem_init+0x1096>
f010245e:	c7 44 24 0c 5b 75 10 	movl   $0xf010755b,0xc(%esp)
f0102465:	f0 
f0102466:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010246d:	f0 
f010246e:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102475:	00 
f0102476:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010247d:	e8 be db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102482:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102487:	74 24                	je     f01024ad <mem_init+0x10c1>
f0102489:	c7 44 24 0c b5 75 10 	movl   $0xf01075b5,0xc(%esp)
f0102490:	f0 
f0102491:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102498:	f0 
f0102499:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f01024a0:	00 
f01024a1:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01024a8:	e8 93 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01024b4:	00 
f01024b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024bc:	00 
f01024bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024c1:	89 3c 24             	mov    %edi,(%esp)
f01024c4:	e8 1b ee ff ff       	call   f01012e4 <page_insert>
f01024c9:	85 c0                	test   %eax,%eax
f01024cb:	74 24                	je     f01024f1 <mem_init+0x1105>
f01024cd:	c7 44 24 0c 50 6f 10 	movl   $0xf0106f50,0xc(%esp)
f01024d4:	f0 
f01024d5:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01024dc:	f0 
f01024dd:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f01024e4:	00 
f01024e5:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01024ec:	e8 4f db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024f1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024f6:	75 24                	jne    f010251c <mem_init+0x1130>
f01024f8:	c7 44 24 0c c6 75 10 	movl   $0xf01075c6,0xc(%esp)
f01024ff:	f0 
f0102500:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102507:	f0 
f0102508:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f010250f:	00 
f0102510:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102517:	e8 24 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010251c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010251f:	74 24                	je     f0102545 <mem_init+0x1159>
f0102521:	c7 44 24 0c d2 75 10 	movl   $0xf01075d2,0xc(%esp)
f0102528:	f0 
f0102529:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102530:	f0 
f0102531:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102538:	00 
f0102539:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102540:	e8 fb da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102545:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010254c:	00 
f010254d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102552:	89 04 24             	mov    %eax,(%esp)
f0102555:	e8 31 ed ff ff       	call   f010128b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010255a:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102560:	ba 00 00 00 00       	mov    $0x0,%edx
f0102565:	89 f8                	mov    %edi,%eax
f0102567:	e8 7c e5 ff ff       	call   f0100ae8 <check_va2pa>
f010256c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010256f:	74 24                	je     f0102595 <mem_init+0x11a9>
f0102571:	c7 44 24 0c 2c 6f 10 	movl   $0xf0106f2c,0xc(%esp)
f0102578:	f0 
f0102579:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102580:	f0 
f0102581:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102588:	00 
f0102589:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102590:	e8 ab da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102595:	ba 00 10 00 00       	mov    $0x1000,%edx
f010259a:	89 f8                	mov    %edi,%eax
f010259c:	e8 47 e5 ff ff       	call   f0100ae8 <check_va2pa>
f01025a1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025a4:	74 24                	je     f01025ca <mem_init+0x11de>
f01025a6:	c7 44 24 0c 88 6f 10 	movl   $0xf0106f88,0xc(%esp)
f01025ad:	f0 
f01025ae:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01025b5:	f0 
f01025b6:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f01025bd:	00 
f01025be:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01025ca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025cf:	74 24                	je     f01025f5 <mem_init+0x1209>
f01025d1:	c7 44 24 0c e7 75 10 	movl   $0xf01075e7,0xc(%esp)
f01025d8:	f0 
f01025d9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01025e0:	f0 
f01025e1:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f01025e8:	00 
f01025e9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01025f0:	e8 4b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025f5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025fa:	74 24                	je     f0102620 <mem_init+0x1234>
f01025fc:	c7 44 24 0c b5 75 10 	movl   $0xf01075b5,0xc(%esp)
f0102603:	f0 
f0102604:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010260b:	f0 
f010260c:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102613:	00 
f0102614:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010261b:	e8 20 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102627:	e8 c6 e9 ff ff       	call   f0100ff2 <page_alloc>
f010262c:	85 c0                	test   %eax,%eax
f010262e:	74 04                	je     f0102634 <mem_init+0x1248>
f0102630:	39 c3                	cmp    %eax,%ebx
f0102632:	74 24                	je     f0102658 <mem_init+0x126c>
f0102634:	c7 44 24 0c b0 6f 10 	movl   $0xf0106fb0,0xc(%esp)
f010263b:	f0 
f010263c:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102643:	f0 
f0102644:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010264b:	00 
f010264c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102653:	e8 e8 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010265f:	e8 8e e9 ff ff       	call   f0100ff2 <page_alloc>
f0102664:	85 c0                	test   %eax,%eax
f0102666:	74 24                	je     f010268c <mem_init+0x12a0>
f0102668:	c7 44 24 0c 09 75 10 	movl   $0xf0107509,0xc(%esp)
f010266f:	f0 
f0102670:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102677:	f0 
f0102678:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010267f:	00 
f0102680:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102687:	e8 b4 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010268c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102691:	8b 08                	mov    (%eax),%ecx
f0102693:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102699:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010269c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01026a2:	c1 fa 03             	sar    $0x3,%edx
f01026a5:	c1 e2 0c             	shl    $0xc,%edx
f01026a8:	39 d1                	cmp    %edx,%ecx
f01026aa:	74 24                	je     f01026d0 <mem_init+0x12e4>
f01026ac:	c7 44 24 0c 54 6c 10 	movl   $0xf0106c54,0xc(%esp)
f01026b3:	f0 
f01026b4:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01026bb:	f0 
f01026bc:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f01026c3:	00 
f01026c4:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01026cb:	e8 70 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01026d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01026d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026d9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026de:	74 24                	je     f0102704 <mem_init+0x1318>
f01026e0:	c7 44 24 0c 6c 75 10 	movl   $0xf010756c,0xc(%esp)
f01026e7:	f0 
f01026e8:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01026ef:	f0 
f01026f0:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01026f7:	00 
f01026f8:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01026ff:	e8 3c d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102704:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102707:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010270d:	89 04 24             	mov    %eax,(%esp)
f0102710:	e8 68 e9 ff ff       	call   f010107d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102715:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010271c:	00 
f010271d:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102724:	00 
f0102725:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010272a:	89 04 24             	mov    %eax,(%esp)
f010272d:	e8 ae e9 ff ff       	call   f01010e0 <pgdir_walk>
f0102732:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102738:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f010273e:	8b 7a 04             	mov    0x4(%edx),%edi
f0102741:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102747:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f010274d:	89 f8                	mov    %edi,%eax
f010274f:	c1 e8 0c             	shr    $0xc,%eax
f0102752:	39 c8                	cmp    %ecx,%eax
f0102754:	72 20                	jb     f0102776 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102756:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010275a:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0102761:	f0 
f0102762:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102769:	00 
f010276a:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102771:	e8 ca d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102776:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010277c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010277f:	74 24                	je     f01027a5 <mem_init+0x13b9>
f0102781:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f0102788:	f0 
f0102789:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102790:	f0 
f0102791:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102798:	00 
f0102799:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01027a0:	e8 9b d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027a5:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f01027ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027af:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027b5:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01027bb:	c1 f8 03             	sar    $0x3,%eax
f01027be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027c1:	89 c2                	mov    %eax,%edx
f01027c3:	c1 ea 0c             	shr    $0xc,%edx
f01027c6:	39 d1                	cmp    %edx,%ecx
f01027c8:	77 20                	ja     f01027ea <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027ce:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f01027d5:	f0 
f01027d6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027dd:	00 
f01027de:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f01027e5:	e8 56 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027f1:	00 
f01027f2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01027f9:	00 
	return (void *)(pa + KERNBASE);
f01027fa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027ff:	89 04 24             	mov    %eax,(%esp)
f0102802:	e8 d0 2f 00 00       	call   f01057d7 <memset>
	page_free(pp0);
f0102807:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010280a:	89 3c 24             	mov    %edi,(%esp)
f010280d:	e8 6b e8 ff ff       	call   f010107d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102812:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102819:	00 
f010281a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102821:	00 
f0102822:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102827:	89 04 24             	mov    %eax,(%esp)
f010282a:	e8 b1 e8 ff ff       	call   f01010e0 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010282f:	89 fa                	mov    %edi,%edx
f0102831:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102837:	c1 fa 03             	sar    $0x3,%edx
f010283a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010283d:	89 d0                	mov    %edx,%eax
f010283f:	c1 e8 0c             	shr    $0xc,%eax
f0102842:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0102848:	72 20                	jb     f010286a <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010284a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010284e:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0102855:	f0 
f0102856:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010285d:	00 
f010285e:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0102865:	e8 d6 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010286a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102873:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102879:	f6 00 01             	testb  $0x1,(%eax)
f010287c:	74 24                	je     f01028a2 <mem_init+0x14b6>
f010287e:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f0102885:	f0 
f0102886:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010288d:	f0 
f010288e:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102895:	00 
f0102896:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010289d:	e8 9e d7 ff ff       	call   f0100040 <_panic>
f01028a2:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028a5:	39 d0                	cmp    %edx,%eax
f01028a7:	75 d0                	jne    f0102879 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028a9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01028ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01028bd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028c0:	89 0d 40 b2 22 f0    	mov    %ecx,0xf022b240

	// free the pages we took
	page_free(pp0);
f01028c6:	89 04 24             	mov    %eax,(%esp)
f01028c9:	e8 af e7 ff ff       	call   f010107d <page_free>
	page_free(pp1);
f01028ce:	89 1c 24             	mov    %ebx,(%esp)
f01028d1:	e8 a7 e7 ff ff       	call   f010107d <page_free>
	page_free(pp2);
f01028d6:	89 34 24             	mov    %esi,(%esp)
f01028d9:	e8 9f e7 ff ff       	call   f010107d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028de:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01028e5:	00 
f01028e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028ed:	e8 85 ea ff ff       	call   f0101377 <mmio_map_region>
f01028f2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028fb:	00 
f01028fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102903:	e8 6f ea ff ff       	call   f0101377 <mmio_map_region>
f0102908:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010290a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102910:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102915:	77 08                	ja     f010291f <mem_init+0x1533>
f0102917:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010291d:	77 24                	ja     f0102943 <mem_init+0x1557>
f010291f:	c7 44 24 0c d4 6f 10 	movl   $0xf0106fd4,0xc(%esp)
f0102926:	f0 
f0102927:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010292e:	f0 
f010292f:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102936:	00 
f0102937:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010293e:	e8 fd d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102943:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102949:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010294f:	77 08                	ja     f0102959 <mem_init+0x156d>
f0102951:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102957:	77 24                	ja     f010297d <mem_init+0x1591>
f0102959:	c7 44 24 0c fc 6f 10 	movl   $0xf0106ffc,0xc(%esp)
f0102960:	f0 
f0102961:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102968:	f0 
f0102969:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102970:	00 
f0102971:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
f010297d:	89 da                	mov    %ebx,%edx
f010297f:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102981:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102987:	74 24                	je     f01029ad <mem_init+0x15c1>
f0102989:	c7 44 24 0c 24 70 10 	movl   $0xf0107024,0xc(%esp)
f0102990:	f0 
f0102991:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102998:	f0 
f0102999:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01029a0:	00 
f01029a1:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01029a8:	e8 93 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01029ad:	39 c6                	cmp    %eax,%esi
f01029af:	73 24                	jae    f01029d5 <mem_init+0x15e9>
f01029b1:	c7 44 24 0c 27 76 10 	movl   $0xf0107627,0xc(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01029c0:	f0 
f01029c1:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01029c8:	00 
f01029c9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01029d0:	e8 6b d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029d5:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f01029db:	89 da                	mov    %ebx,%edx
f01029dd:	89 f8                	mov    %edi,%eax
f01029df:	e8 04 e1 ff ff       	call   f0100ae8 <check_va2pa>
f01029e4:	85 c0                	test   %eax,%eax
f01029e6:	74 24                	je     f0102a0c <mem_init+0x1620>
f01029e8:	c7 44 24 0c 4c 70 10 	movl   $0xf010704c,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a0c:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a12:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a15:	89 c2                	mov    %eax,%edx
f0102a17:	89 f8                	mov    %edi,%eax
f0102a19:	e8 ca e0 ff ff       	call   f0100ae8 <check_va2pa>
f0102a1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a23:	74 24                	je     f0102a49 <mem_init+0x165d>
f0102a25:	c7 44 24 0c 70 70 10 	movl   $0xf0107070,0xc(%esp)
f0102a2c:	f0 
f0102a2d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102a34:	f0 
f0102a35:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102a3c:	00 
f0102a3d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102a44:	e8 f7 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a49:	89 f2                	mov    %esi,%edx
f0102a4b:	89 f8                	mov    %edi,%eax
f0102a4d:	e8 96 e0 ff ff       	call   f0100ae8 <check_va2pa>
f0102a52:	85 c0                	test   %eax,%eax
f0102a54:	74 24                	je     f0102a7a <mem_init+0x168e>
f0102a56:	c7 44 24 0c a0 70 10 	movl   $0xf01070a0,0xc(%esp)
f0102a5d:	f0 
f0102a5e:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102a6d:	00 
f0102a6e:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102a75:	e8 c6 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a7a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a80:	89 f8                	mov    %edi,%eax
f0102a82:	e8 61 e0 ff ff       	call   f0100ae8 <check_va2pa>
f0102a87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a8a:	74 24                	je     f0102ab0 <mem_init+0x16c4>
f0102a8c:	c7 44 24 0c c4 70 10 	movl   $0xf01070c4,0xc(%esp)
f0102a93:	f0 
f0102a94:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102a9b:	f0 
f0102a9c:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102aa3:	00 
f0102aa4:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102aab:	e8 90 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102ab0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ab7:	00 
f0102ab8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102abc:	89 3c 24             	mov    %edi,(%esp)
f0102abf:	e8 1c e6 ff ff       	call   f01010e0 <pgdir_walk>
f0102ac4:	f6 00 1a             	testb  $0x1a,(%eax)
f0102ac7:	75 24                	jne    f0102aed <mem_init+0x1701>
f0102ac9:	c7 44 24 0c f0 70 10 	movl   $0xf01070f0,0xc(%esp)
f0102ad0:	f0 
f0102ad1:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102ad8:	f0 
f0102ad9:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102ae0:	00 
f0102ae1:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102ae8:	e8 53 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102aed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102af4:	00 
f0102af5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102af9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102afe:	89 04 24             	mov    %eax,(%esp)
f0102b01:	e8 da e5 ff ff       	call   f01010e0 <pgdir_walk>
f0102b06:	f6 00 04             	testb  $0x4,(%eax)
f0102b09:	74 24                	je     f0102b2f <mem_init+0x1743>
f0102b0b:	c7 44 24 0c 34 71 10 	movl   $0xf0107134,0xc(%esp)
f0102b12:	f0 
f0102b13:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102b1a:	f0 
f0102b1b:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102b22:	00 
f0102b23:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102b2a:	e8 11 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b36:	00 
f0102b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b3b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b40:	89 04 24             	mov    %eax,(%esp)
f0102b43:	e8 98 e5 ff ff       	call   f01010e0 <pgdir_walk>
f0102b48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b55:	00 
f0102b56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b5d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b62:	89 04 24             	mov    %eax,(%esp)
f0102b65:	e8 76 e5 ff ff       	call   f01010e0 <pgdir_walk>
f0102b6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b77:	00 
f0102b78:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b7c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102b81:	89 04 24             	mov    %eax,(%esp)
f0102b84:	e8 57 e5 ff ff       	call   f01010e0 <pgdir_walk>
f0102b89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b8f:	c7 04 24 39 76 10 f0 	movl   $0xf0107639,(%esp)
f0102b96:	e8 0b 14 00 00       	call   f0103fa6 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b9b:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0102ba0:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102ba7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102bad:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bb7:	77 20                	ja     f0102bd9 <mem_init+0x17ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bbd:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102bc4:	f0 
f0102bc5:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102bcc:	00 
f0102bcd:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102bd4:	e8 67 d4 ff ff       	call   f0100040 <_panic>
f0102bd9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102be0:	00 
	return (physaddr_t)kva - KERNBASE;
f0102be1:	05 00 00 00 10       	add    $0x10000000,%eax
f0102be6:	89 04 24             	mov    %eax,(%esp)
f0102be9:	89 d9                	mov    %ebx,%ecx
f0102beb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102bf0:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102bf5:	e8 86 e5 ff ff       	call   f0101180 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102bfa:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c00:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c06:	77 20                	ja     f0102c28 <mem_init+0x183c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c08:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c0c:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102c13:	f0 
f0102c14:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102c1b:	00 
f0102c1c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102c23:	e8 18 d4 ff ff       	call   f0100040 <_panic>
f0102c28:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c2f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c30:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c36:	89 04 24             	mov    %eax,(%esp)
f0102c39:	89 d9                	mov    %ebx,%ecx
f0102c3b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c40:	e8 3b e5 ff ff       	call   f0101180 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102c45:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c4a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c4f:	77 20                	ja     f0102c71 <mem_init+0x1885>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c55:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102c5c:	f0 
f0102c5d:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102c64:	00 
f0102c65:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102c6c:	e8 cf d3 ff ff       	call   f0100040 <_panic>
f0102c71:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c78:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c79:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c7e:	89 04 24             	mov    %eax,(%esp)
f0102c81:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c86:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c8b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102c90:	e8 eb e4 ff ff       	call   f0101180 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102c95:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c9b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ca1:	77 20                	ja     f0102cc3 <mem_init+0x18d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ca7:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102cae:	f0 
f0102caf:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102cb6:	00 
f0102cb7:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102cbe:	e8 7d d3 ff ff       	call   f0100040 <_panic>
f0102cc3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102cca:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ccb:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102cd1:	89 04 24             	mov    %eax,(%esp)
f0102cd4:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102cd9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102cde:	e8 9d e4 ff ff       	call   f0101180 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ce3:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102ce8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ced:	77 20                	ja     f0102d0f <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cf3:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102cfa:	f0 
f0102cfb:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102d02:	00 
f0102d03:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102d0a:	e8 31 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102d0f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d16:	00 
f0102d17:	c7 04 24 00 60 11 00 	movl   $0x116000,(%esp)
f0102d1e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d23:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d28:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d2d:	e8 4e e4 ff ff       	call   f0101180 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102d32:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d39:	00 
f0102d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d41:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102d46:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d4b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102d50:	e8 2b e4 ff ff       	call   f0101180 <boot_map_region>
f0102d55:	bf 00 d0 26 f0       	mov    $0xf026d000,%edi
f0102d5a:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f0102d5f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d64:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d6a:	77 20                	ja     f0102d8c <mem_init+0x19a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d70:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102d7f:	00 
f0102d80:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102d87:	e8 b4 d2 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102d8c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d93:	00 
f0102d94:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d9a:	89 04 24             	mov    %eax,(%esp)
f0102d9d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102da2:	89 f2                	mov    %esi,%edx
f0102da4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102da9:	e8 d2 e3 ff ff       	call   f0101180 <boot_map_region>
f0102dae:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102db4:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
f0102dba:	39 fb                	cmp    %edi,%ebx
f0102dbc:	75 a6                	jne    f0102d64 <mem_init+0x1978>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102dbe:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102dc4:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0102dc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102dcc:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102dd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ddb:	8b 35 90 be 22 f0    	mov    0xf022be90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102de1:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102de4:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102dea:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ded:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102df2:	eb 6a                	jmp    f0102e5e <mem_init+0x1a72>
f0102df4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dfa:	89 f8                	mov    %edi,%eax
f0102dfc:	e8 e7 dc ff ff       	call   f0100ae8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e01:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e08:	77 20                	ja     f0102e2a <mem_init+0x1a3e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e0a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e0e:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102e15:	f0 
f0102e16:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102e1d:	00 
f0102e1e:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102e25:	e8 16 d2 ff ff       	call   f0100040 <_panic>
f0102e2a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e2d:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e30:	39 d0                	cmp    %edx,%eax
f0102e32:	74 24                	je     f0102e58 <mem_init+0x1a6c>
f0102e34:	c7 44 24 0c 68 71 10 	movl   $0xf0107168,0xc(%esp)
f0102e3b:	f0 
f0102e3c:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102e43:	f0 
f0102e44:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102e4b:	00 
f0102e4c:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102e53:	e8 e8 d1 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e58:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e5e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e61:	77 91                	ja     f0102df4 <mem_init+0x1a08>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e63:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e69:	89 de                	mov    %ebx,%esi
f0102e6b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e70:	89 f8                	mov    %edi,%eax
f0102e72:	e8 71 dc ff ff       	call   f0100ae8 <check_va2pa>
f0102e77:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e7d:	77 20                	ja     f0102e9f <mem_init+0x1ab3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e83:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102e8a:	f0 
f0102e8b:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e92:	00 
f0102e93:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102ea4:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102eaa:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ead:	39 d0                	cmp    %edx,%eax
f0102eaf:	74 24                	je     f0102ed5 <mem_init+0x1ae9>
f0102eb1:	c7 44 24 0c 9c 71 10 	movl   $0xf010719c,0xc(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ec8:	00 
f0102ec9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102ed0:	e8 6b d1 ff ff       	call   f0100040 <_panic>
f0102ed5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102edb:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102ee1:	0f 85 a8 05 00 00    	jne    f010348f <mem_init+0x20a3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ee7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102eea:	c1 e6 0c             	shl    $0xc,%esi
f0102eed:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ef2:	eb 3b                	jmp    f0102f2f <mem_init+0x1b43>
f0102ef4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102efa:	89 f8                	mov    %edi,%eax
f0102efc:	e8 e7 db ff ff       	call   f0100ae8 <check_va2pa>
f0102f01:	39 c3                	cmp    %eax,%ebx
f0102f03:	74 24                	je     f0102f29 <mem_init+0x1b3d>
f0102f05:	c7 44 24 0c d0 71 10 	movl   $0xf01071d0,0xc(%esp)
f0102f0c:	f0 
f0102f0d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102f14:	f0 
f0102f15:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102f1c:	00 
f0102f1d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102f24:	e8 17 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f29:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f2f:	39 f3                	cmp    %esi,%ebx
f0102f31:	72 c1                	jb     f0102ef4 <mem_init+0x1b08>
f0102f33:	c7 45 d0 00 d0 22 f0 	movl   $0xf022d000,-0x30(%ebp)
f0102f3a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f41:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f46:	b8 00 d0 22 f0       	mov    $0xf022d000,%eax
f0102f4b:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f50:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f53:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f59:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f5c:	89 f2                	mov    %esi,%edx
f0102f5e:	89 f8                	mov    %edi,%eax
f0102f60:	e8 83 db ff ff       	call   f0100ae8 <check_va2pa>
f0102f65:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f68:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f6e:	77 20                	ja     f0102f90 <mem_init+0x1ba4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f70:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f74:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0102f7b:	f0 
f0102f7c:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f83:	00 
f0102f84:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102f8b:	e8 b0 d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f90:	89 f3                	mov    %esi,%ebx
f0102f92:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102f95:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102f98:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f9b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f9e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102fa1:	39 c2                	cmp    %eax,%edx
f0102fa3:	74 24                	je     f0102fc9 <mem_init+0x1bdd>
f0102fa5:	c7 44 24 0c f8 71 10 	movl   $0xf01071f8,0xc(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102fb4:	f0 
f0102fb5:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102fbc:	00 
f0102fbd:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0102fc4:	e8 77 d0 ff ff       	call   f0100040 <_panic>
f0102fc9:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fcf:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fd2:	0f 85 a9 04 00 00    	jne    f0103481 <mem_init+0x2095>
f0102fd8:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102fde:	89 da                	mov    %ebx,%edx
f0102fe0:	89 f8                	mov    %edi,%eax
f0102fe2:	e8 01 db ff ff       	call   f0100ae8 <check_va2pa>
f0102fe7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fea:	74 24                	je     f0103010 <mem_init+0x1c24>
f0102fec:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f0102ff3:	f0 
f0102ff4:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0102ffb:	f0 
f0102ffc:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0103003:	00 
f0103004:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010300b:	e8 30 d0 ff ff       	call   f0100040 <_panic>
f0103010:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103016:	39 de                	cmp    %ebx,%esi
f0103018:	75 c4                	jne    f0102fde <mem_init+0x1bf2>
f010301a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103020:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0103027:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010302e:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103034:	0f 85 19 ff ff ff    	jne    f0102f53 <mem_init+0x1b67>
f010303a:	b8 00 00 00 00       	mov    $0x0,%eax
f010303f:	e9 c2 00 00 00       	jmp    f0103106 <mem_init+0x1d1a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103044:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010304a:	83 fa 04             	cmp    $0x4,%edx
f010304d:	77 2e                	ja     f010307d <mem_init+0x1c91>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010304f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103053:	0f 85 aa 00 00 00    	jne    f0103103 <mem_init+0x1d17>
f0103059:	c7 44 24 0c 52 76 10 	movl   $0xf0107652,0xc(%esp)
f0103060:	f0 
f0103061:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0103068:	f0 
f0103069:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103070:	00 
f0103071:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103078:	e8 c3 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010307d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103082:	76 55                	jbe    f01030d9 <mem_init+0x1ced>
				assert(pgdir[i] & PTE_P);
f0103084:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103087:	f6 c2 01             	test   $0x1,%dl
f010308a:	75 24                	jne    f01030b0 <mem_init+0x1cc4>
f010308c:	c7 44 24 0c 52 76 10 	movl   $0xf0107652,0xc(%esp)
f0103093:	f0 
f0103094:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010309b:	f0 
f010309c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f01030a3:	00 
f01030a4:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01030ab:	e8 90 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01030b0:	f6 c2 02             	test   $0x2,%dl
f01030b3:	75 4e                	jne    f0103103 <mem_init+0x1d17>
f01030b5:	c7 44 24 0c 63 76 10 	movl   $0xf0107663,0xc(%esp)
f01030bc:	f0 
f01030bd:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01030c4:	f0 
f01030c5:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01030cc:	00 
f01030cd:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01030d4:	e8 67 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01030d9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030dd:	74 24                	je     f0103103 <mem_init+0x1d17>
f01030df:	c7 44 24 0c 74 76 10 	movl   $0xf0107674,0xc(%esp)
f01030e6:	f0 
f01030e7:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01030ee:	f0 
f01030ef:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01030f6:	00 
f01030f7:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01030fe:	e8 3d cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103103:	83 c0 01             	add    $0x1,%eax
f0103106:	3d 00 04 00 00       	cmp    $0x400,%eax
f010310b:	0f 85 33 ff ff ff    	jne    f0103044 <mem_init+0x1c58>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103111:	c7 04 24 64 72 10 f0 	movl   $0xf0107264,(%esp)
f0103118:	e8 89 0e 00 00       	call   f0103fa6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010311d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0103122:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103127:	77 20                	ja     f0103149 <mem_init+0x1d5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103129:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010312d:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0103134:	f0 
f0103135:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f010313c:	00 
f010313d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103144:	e8 f7 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103149:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010314e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103151:	b8 00 00 00 00       	mov    $0x0,%eax
f0103156:	e8 fc d9 ff ff       	call   f0100b57 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010315b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010315e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103161:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103166:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103170:	e8 7d de ff ff       	call   f0100ff2 <page_alloc>
f0103175:	89 c3                	mov    %eax,%ebx
f0103177:	85 c0                	test   %eax,%eax
f0103179:	75 24                	jne    f010319f <mem_init+0x1db3>
f010317b:	c7 44 24 0c 5e 74 10 	movl   $0xf010745e,0xc(%esp)
f0103182:	f0 
f0103183:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010318a:	f0 
f010318b:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103192:	00 
f0103193:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010319a:	e8 a1 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010319f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031a6:	e8 47 de ff ff       	call   f0100ff2 <page_alloc>
f01031ab:	89 c7                	mov    %eax,%edi
f01031ad:	85 c0                	test   %eax,%eax
f01031af:	75 24                	jne    f01031d5 <mem_init+0x1de9>
f01031b1:	c7 44 24 0c 74 74 10 	movl   $0xf0107474,0xc(%esp)
f01031b8:	f0 
f01031b9:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01031c0:	f0 
f01031c1:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f01031c8:	00 
f01031c9:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01031d0:	e8 6b ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031dc:	e8 11 de ff ff       	call   f0100ff2 <page_alloc>
f01031e1:	89 c6                	mov    %eax,%esi
f01031e3:	85 c0                	test   %eax,%eax
f01031e5:	75 24                	jne    f010320b <mem_init+0x1e1f>
f01031e7:	c7 44 24 0c 8a 74 10 	movl   $0xf010748a,0xc(%esp)
f01031ee:	f0 
f01031ef:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01031f6:	f0 
f01031f7:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01031fe:	00 
f01031ff:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103206:	e8 35 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010320b:	89 1c 24             	mov    %ebx,(%esp)
f010320e:	e8 6a de ff ff       	call   f010107d <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103213:	89 f8                	mov    %edi,%eax
f0103215:	e8 89 d8 ff ff       	call   f0100aa3 <page2kva>
f010321a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103221:	00 
f0103222:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103229:	00 
f010322a:	89 04 24             	mov    %eax,(%esp)
f010322d:	e8 a5 25 00 00       	call   f01057d7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103232:	89 f0                	mov    %esi,%eax
f0103234:	e8 6a d8 ff ff       	call   f0100aa3 <page2kva>
f0103239:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103240:	00 
f0103241:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103248:	00 
f0103249:	89 04 24             	mov    %eax,(%esp)
f010324c:	e8 86 25 00 00       	call   f01057d7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103251:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103258:	00 
f0103259:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103260:	00 
f0103261:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103265:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010326a:	89 04 24             	mov    %eax,(%esp)
f010326d:	e8 72 e0 ff ff       	call   f01012e4 <page_insert>
	assert(pp1->pp_ref == 1);
f0103272:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103277:	74 24                	je     f010329d <mem_init+0x1eb1>
f0103279:	c7 44 24 0c 5b 75 10 	movl   $0xf010755b,0xc(%esp)
f0103280:	f0 
f0103281:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0103288:	f0 
f0103289:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103290:	00 
f0103291:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103298:	e8 a3 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010329d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032a4:	01 01 01 
f01032a7:	74 24                	je     f01032cd <mem_init+0x1ee1>
f01032a9:	c7 44 24 0c 84 72 10 	movl   $0xf0107284,0xc(%esp)
f01032b0:	f0 
f01032b1:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01032b8:	f0 
f01032b9:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01032c0:	00 
f01032c1:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01032c8:	e8 73 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01032cd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032d4:	00 
f01032d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032dc:	00 
f01032dd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032e1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01032e6:	89 04 24             	mov    %eax,(%esp)
f01032e9:	e8 f6 df ff ff       	call   f01012e4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032ee:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032f5:	02 02 02 
f01032f8:	74 24                	je     f010331e <mem_init+0x1f32>
f01032fa:	c7 44 24 0c a8 72 10 	movl   $0xf01072a8,0xc(%esp)
f0103301:	f0 
f0103302:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0103309:	f0 
f010330a:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0103311:	00 
f0103312:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103319:	e8 22 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010331e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103323:	74 24                	je     f0103349 <mem_init+0x1f5d>
f0103325:	c7 44 24 0c 7d 75 10 	movl   $0xf010757d,0xc(%esp)
f010332c:	f0 
f010332d:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0103334:	f0 
f0103335:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010333c:	00 
f010333d:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103344:	e8 f7 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103349:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010334e:	74 24                	je     f0103374 <mem_init+0x1f88>
f0103350:	c7 44 24 0c e7 75 10 	movl   $0xf01075e7,0xc(%esp)
f0103357:	f0 
f0103358:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010335f:	f0 
f0103360:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103367:	00 
f0103368:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010336f:	e8 cc cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103374:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010337b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010337e:	89 f0                	mov    %esi,%eax
f0103380:	e8 1e d7 ff ff       	call   f0100aa3 <page2kva>
f0103385:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010338b:	74 24                	je     f01033b1 <mem_init+0x1fc5>
f010338d:	c7 44 24 0c cc 72 10 	movl   $0xf01072cc,0xc(%esp)
f0103394:	f0 
f0103395:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010339c:	f0 
f010339d:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f01033a4:	00 
f01033a5:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01033ac:	e8 8f cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033b1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033b8:	00 
f01033b9:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033be:	89 04 24             	mov    %eax,(%esp)
f01033c1:	e8 c5 de ff ff       	call   f010128b <page_remove>
	assert(pp2->pp_ref == 0);
f01033c6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01033cb:	74 24                	je     f01033f1 <mem_init+0x2005>
f01033cd:	c7 44 24 0c b5 75 10 	movl   $0xf01075b5,0xc(%esp)
f01033d4:	f0 
f01033d5:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f01033dc:	f0 
f01033dd:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033e4:	00 
f01033e5:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f01033ec:	e8 4f cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033f1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01033f6:	8b 08                	mov    (%eax),%ecx
f01033f8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033fe:	89 da                	mov    %ebx,%edx
f0103400:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103406:	c1 fa 03             	sar    $0x3,%edx
f0103409:	c1 e2 0c             	shl    $0xc,%edx
f010340c:	39 d1                	cmp    %edx,%ecx
f010340e:	74 24                	je     f0103434 <mem_init+0x2048>
f0103410:	c7 44 24 0c 54 6c 10 	movl   $0xf0106c54,0xc(%esp)
f0103417:	f0 
f0103418:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103434:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010343a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010343f:	74 24                	je     f0103465 <mem_init+0x2079>
f0103441:	c7 44 24 0c 6c 75 10 	movl   $0xf010756c,0xc(%esp)
f0103448:	f0 
f0103449:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0103450:	f0 
f0103451:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0103458:	00 
f0103459:	c7 04 24 67 73 10 f0 	movl   $0xf0107367,(%esp)
f0103460:	e8 db cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103465:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010346b:	89 1c 24             	mov    %ebx,(%esp)
f010346e:	e8 0a dc ff ff       	call   f010107d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103473:	c7 04 24 f8 72 10 f0 	movl   $0xf01072f8,(%esp)
f010347a:	e8 27 0b 00 00       	call   f0103fa6 <cprintf>
f010347f:	eb 1c                	jmp    f010349d <mem_init+0x20b1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103481:	89 da                	mov    %ebx,%edx
f0103483:	89 f8                	mov    %edi,%eax
f0103485:	e8 5e d6 ff ff       	call   f0100ae8 <check_va2pa>
f010348a:	e9 0c fb ff ff       	jmp    f0102f9b <mem_init+0x1baf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010348f:	89 da                	mov    %ebx,%edx
f0103491:	89 f8                	mov    %edi,%eax
f0103493:	e8 50 d6 ff ff       	call   f0100ae8 <check_va2pa>
f0103498:	e9 0d fa ff ff       	jmp    f0102eaa <mem_init+0x1abe>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010349d:	83 c4 4c             	add    $0x4c,%esp
f01034a0:	5b                   	pop    %ebx
f01034a1:	5e                   	pop    %esi
f01034a2:	5f                   	pop    %edi
f01034a3:	5d                   	pop    %ebp
f01034a4:	c3                   	ret    

f01034a5 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01034a5:	55                   	push   %ebp
f01034a6:	89 e5                	mov    %esp,%ebp
f01034a8:	57                   	push   %edi
f01034a9:	56                   	push   %esi
f01034aa:	53                   	push   %ebx
f01034ab:	83 ec 1c             	sub    $0x1c,%esp
f01034ae:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034b1:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f01034b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034b7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f01034bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034c0:	03 45 10             	add    0x10(%ebp),%eax
f01034c3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f01034d0:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034d6:	76 5d                	jbe    f0103535 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f01034d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034db:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
        return -E_FAULT;
f01034e0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034e5:	eb 58                	jmp    f010353f <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034ee:	00 
f01034ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034f3:	8b 47 60             	mov    0x60(%edi),%eax
f01034f6:	89 04 24             	mov    %eax,(%esp)
f01034f9:	e8 e2 db ff ff       	call   f01010e0 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034fe:	85 c0                	test   %eax,%eax
f0103500:	74 0c                	je     f010350e <user_mem_check+0x69>
f0103502:	8b 00                	mov    (%eax),%eax
f0103504:	a8 01                	test   $0x1,%al
f0103506:	74 06                	je     f010350e <user_mem_check+0x69>
f0103508:	21 f0                	and    %esi,%eax
f010350a:	39 c6                	cmp    %eax,%esi
f010350c:	74 21                	je     f010352f <user_mem_check+0x8a>
        {
            if (addr < va)
f010350e:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0103511:	76 0f                	jbe    f0103522 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f0103513:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103516:	a3 3c b2 22 f0       	mov    %eax,0xf022b23c
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f010351b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103520:	eb 1d                	jmp    f010353f <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f0103522:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
            }
            
            return -E_FAULT;
f0103528:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010352d:	eb 10                	jmp    f010353f <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f010352f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103535:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103538:	72 ad                	jb     f01034e7 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f010353a:	b8 00 00 00 00       	mov    $0x0,%eax

}
f010353f:	83 c4 1c             	add    $0x1c,%esp
f0103542:	5b                   	pop    %ebx
f0103543:	5e                   	pop    %esi
f0103544:	5f                   	pop    %edi
f0103545:	5d                   	pop    %ebp
f0103546:	c3                   	ret    

f0103547 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103547:	55                   	push   %ebp
f0103548:	89 e5                	mov    %esp,%ebp
f010354a:	53                   	push   %ebx
f010354b:	83 ec 14             	sub    $0x14,%esp
f010354e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103551:	8b 45 14             	mov    0x14(%ebp),%eax
f0103554:	83 c8 04             	or     $0x4,%eax
f0103557:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010355b:	8b 45 10             	mov    0x10(%ebp),%eax
f010355e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103562:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103565:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103569:	89 1c 24             	mov    %ebx,(%esp)
f010356c:	e8 34 ff ff ff       	call   f01034a5 <user_mem_check>
f0103571:	85 c0                	test   %eax,%eax
f0103573:	79 24                	jns    f0103599 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103575:	a1 3c b2 22 f0       	mov    0xf022b23c,%eax
f010357a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010357e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103581:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103585:	c7 04 24 24 73 10 f0 	movl   $0xf0107324,(%esp)
f010358c:	e8 15 0a 00 00       	call   f0103fa6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103591:	89 1c 24             	mov    %ebx,(%esp)
f0103594:	e8 16 07 00 00       	call   f0103caf <env_destroy>
	}
}
f0103599:	83 c4 14             	add    $0x14,%esp
f010359c:	5b                   	pop    %ebx
f010359d:	5d                   	pop    %ebp
f010359e:	c3                   	ret    
	...

f01035a0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
f01035a3:	57                   	push   %edi
f01035a4:	56                   	push   %esi
f01035a5:	53                   	push   %ebx
f01035a6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f01035a9:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f01035ac:	89 d3                	mov    %edx,%ebx
f01035ae:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01035b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01035ba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01035c0:	29 d0                	sub    %edx,%eax
f01035c2:	c1 e8 0c             	shr    $0xc,%eax
f01035c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f01035c8:	be 00 00 00 00       	mov    $0x0,%esi
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035cd:	eb 6d                	jmp    f010363c <region_alloc+0x9c>
		struct PageInfo* newPage = page_alloc(0);
f01035cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035d6:	e8 17 da ff ff       	call   f0100ff2 <page_alloc>
		if(newPage == 0)
f01035db:	85 c0                	test   %eax,%eax
f01035dd:	75 1c                	jne    f01035fb <region_alloc+0x5b>
			panic("there is no more page to region_alloc for env\n");
f01035df:	c7 44 24 08 84 76 10 	movl   $0xf0107684,0x8(%esp)
f01035e6:	f0 
f01035e7:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01035ee:	00 
f01035ef:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f01035f6:	e8 45 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035fb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103602:	00 
f0103603:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103607:	89 44 24 04          	mov    %eax,0x4(%esp)
f010360b:	89 3c 24             	mov    %edi,(%esp)
f010360e:	e8 d1 dc ff ff       	call   f01012e4 <page_insert>
f0103613:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if(ret)
f0103619:	85 c0                	test   %eax,%eax
f010361b:	74 1c                	je     f0103639 <region_alloc+0x99>
			panic("page_insert fail\n");
f010361d:	c7 44 24 08 be 76 10 	movl   $0xf01076be,0x8(%esp)
f0103624:	f0 
f0103625:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f010362c:	00 
f010362d:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103634:	e8 07 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0103639:	83 c6 01             	add    $0x1,%esi
f010363c:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010363f:	7c 8e                	jl     f01035cf <region_alloc+0x2f>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103641:	83 c4 2c             	add    $0x2c,%esp
f0103644:	5b                   	pop    %ebx
f0103645:	5e                   	pop    %esi
f0103646:	5f                   	pop    %edi
f0103647:	5d                   	pop    %ebp
f0103648:	c3                   	ret    

f0103649 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103649:	55                   	push   %ebp
f010364a:	89 e5                	mov    %esp,%ebp
f010364c:	83 ec 18             	sub    $0x18,%esp
f010364f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103652:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103655:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103658:	8b 45 08             	mov    0x8(%ebp),%eax
f010365b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010365e:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103662:	85 c0                	test   %eax,%eax
f0103664:	75 17                	jne    f010367d <envid2env+0x34>
		*env_store = curenv;
f0103666:	e8 be 27 00 00       	call   f0105e29 <cpunum>
f010366b:	6b c0 74             	imul   $0x74,%eax,%eax
f010366e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103674:	89 06                	mov    %eax,(%esi)
		return 0;
f0103676:	b8 00 00 00 00       	mov    $0x0,%eax
f010367b:	eb 67                	jmp    f01036e4 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010367d:	89 c3                	mov    %eax,%ebx
f010367f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103685:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103688:	03 1d 48 b2 22 f0    	add    0xf022b248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010368e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103692:	74 05                	je     f0103699 <envid2env+0x50>
f0103694:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103697:	74 0d                	je     f01036a6 <envid2env+0x5d>
		*env_store = 0;
f0103699:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010369f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036a4:	eb 3e                	jmp    f01036e4 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01036a6:	84 d2                	test   %dl,%dl
f01036a8:	74 33                	je     f01036dd <envid2env+0x94>
f01036aa:	e8 7a 27 00 00       	call   f0105e29 <cpunum>
f01036af:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b2:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f01036b8:	74 23                	je     f01036dd <envid2env+0x94>
f01036ba:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036bd:	e8 67 27 00 00       	call   f0105e29 <cpunum>
f01036c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01036cb:	3b 78 48             	cmp    0x48(%eax),%edi
f01036ce:	74 0d                	je     f01036dd <envid2env+0x94>
		*env_store = 0;
f01036d0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036d6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036db:	eb 07                	jmp    f01036e4 <envid2env+0x9b>
	}

	*env_store = e;
f01036dd:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036df:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01036e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01036ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01036ed:	89 ec                	mov    %ebp,%esp
f01036ef:	5d                   	pop    %ebp
f01036f0:	c3                   	ret    

f01036f1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036f1:	55                   	push   %ebp
f01036f2:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036f4:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f01036f9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036fc:	b8 23 00 00 00       	mov    $0x23,%eax
f0103701:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103703:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103705:	b0 10                	mov    $0x10,%al
f0103707:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103709:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010370b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010370d:	ea 14 37 10 f0 08 00 	ljmp   $0x8,$0xf0103714
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103714:	b0 00                	mov    $0x0,%al
f0103716:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103719:	5d                   	pop    %ebp
f010371a:	c3                   	ret    

f010371b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010371b:	55                   	push   %ebp
f010371c:	89 e5                	mov    %esp,%ebp
f010371e:	56                   	push   %esi
f010371f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f0103720:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103726:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010372c:	b9 00 00 00 00       	mov    $0x0,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f0103731:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103736:	eb 02                	jmp    f010373a <env_init+0x1f>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103738:	89 d9                	mov    %ebx,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f010373a:	89 c3                	mov    %eax,%ebx
f010373c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103743:	89 48 44             	mov    %ecx,0x44(%eax)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f0103746:	83 ea 01             	sub    $0x1,%edx
f0103749:	83 e8 7c             	sub    $0x7c,%eax
f010374c:	83 fa ff             	cmp    $0xffffffff,%edx
f010374f:	75 e7                	jne    f0103738 <env_init+0x1d>
f0103751:	89 35 4c b2 22 f0    	mov    %esi,0xf022b24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103757:	e8 95 ff ff ff       	call   f01036f1 <env_init_percpu>
}
f010375c:	5b                   	pop    %ebx
f010375d:	5e                   	pop    %esi
f010375e:	5d                   	pop    %ebp
f010375f:	c3                   	ret    

f0103760 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103760:	55                   	push   %ebp
f0103761:	89 e5                	mov    %esp,%ebp
f0103763:	53                   	push   %ebx
f0103764:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103767:	8b 1d 4c b2 22 f0    	mov    0xf022b24c,%ebx
f010376d:	85 db                	test   %ebx,%ebx
f010376f:	0f 84 a7 01 00 00    	je     f010391c <env_alloc+0x1bc>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103775:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010377c:	e8 71 d8 ff ff       	call   f0100ff2 <page_alloc>
f0103781:	85 c0                	test   %eax,%eax
f0103783:	0f 84 9a 01 00 00    	je     f0103923 <env_alloc+0x1c3>
f0103789:	89 c2                	mov    %eax,%edx
f010378b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0103791:	c1 fa 03             	sar    $0x3,%edx
f0103794:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103797:	89 d1                	mov    %edx,%ecx
f0103799:	c1 e9 0c             	shr    $0xc,%ecx
f010379c:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f01037a2:	72 20                	jb     f01037c4 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01037a8:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f01037af:	f0 
f01037b0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037b7:	00 
f01037b8:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f01037bf:	e8 7c c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037c4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01037ca:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f01037cd:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037d2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037d9:	00 
f01037da:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01037df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037e3:	8b 43 60             	mov    0x60(%ebx),%eax
f01037e6:	89 04 24             	mov    %eax,(%esp)
f01037e9:	e8 9e 20 00 00       	call   f010588c <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037ee:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037f5:	00 
f01037f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037fd:	00 
f01037fe:	8b 43 60             	mov    0x60(%ebx),%eax
f0103801:	89 04 24             	mov    %eax,(%esp)
f0103804:	e8 ce 1f 00 00       	call   f01057d7 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103809:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010380c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103811:	77 20                	ja     f0103833 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103813:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103817:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f010381e:	f0 
f010381f:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0103826:	00 
f0103827:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f010382e:	e8 0d c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103833:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103839:	83 ca 05             	or     $0x5,%edx
f010383c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103842:	8b 43 48             	mov    0x48(%ebx),%eax
f0103845:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010384a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010384f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103854:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103857:	89 da                	mov    %ebx,%edx
f0103859:	2b 15 48 b2 22 f0    	sub    0xf022b248,%edx
f010385f:	c1 fa 02             	sar    $0x2,%edx
f0103862:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103868:	09 d0                	or     %edx,%eax
f010386a:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010386d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103870:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103873:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010387a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103881:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103888:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010388f:	00 
f0103890:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103897:	00 
f0103898:	89 1c 24             	mov    %ebx,(%esp)
f010389b:	e8 37 1f 00 00       	call   f01057d7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01038a0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01038a6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01038ac:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038b2:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038b9:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038bf:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038c6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038ca:	8b 43 44             	mov    0x44(%ebx),%eax
f01038cd:	a3 4c b2 22 f0       	mov    %eax,0xf022b24c
	*newenv_store = e;
f01038d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d5:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038d7:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038da:	e8 4a 25 00 00       	call   f0105e29 <cpunum>
f01038df:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01038e7:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01038ee:	74 11                	je     f0103901 <env_alloc+0x1a1>
f01038f0:	e8 34 25 00 00       	call   f0105e29 <cpunum>
f01038f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01038fe:	8b 50 48             	mov    0x48(%eax),%edx
f0103901:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103905:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103909:	c7 04 24 d0 76 10 f0 	movl   $0xf01076d0,(%esp)
f0103910:	e8 91 06 00 00       	call   f0103fa6 <cprintf>
	return 0;
f0103915:	b8 00 00 00 00       	mov    $0x0,%eax
f010391a:	eb 0c                	jmp    f0103928 <env_alloc+0x1c8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010391c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103921:	eb 05                	jmp    f0103928 <env_alloc+0x1c8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103923:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103928:	83 c4 14             	add    $0x14,%esp
f010392b:	5b                   	pop    %ebx
f010392c:	5d                   	pop    %ebp
f010392d:	c3                   	ret    

f010392e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010392e:	55                   	push   %ebp
f010392f:	89 e5                	mov    %esp,%ebp
f0103931:	57                   	push   %edi
f0103932:	56                   	push   %esi
f0103933:	53                   	push   %ebx
f0103934:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f0103937:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f010393e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103945:	00 
f0103946:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103949:	89 04 24             	mov    %eax,(%esp)
f010394c:	e8 0f fe ff ff       	call   f0103760 <env_alloc>
	if(r < 0)
f0103951:	85 c0                	test   %eax,%eax
f0103953:	79 1c                	jns    f0103971 <env_create+0x43>
		panic("env_create fault\n");
f0103955:	c7 44 24 08 e5 76 10 	movl   $0xf01076e5,0x8(%esp)
f010395c:	f0 
f010395d:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0103964:	00 
f0103965:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f010396c:	e8 cf c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103974:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f0103977:	8b 55 08             	mov    0x8(%ebp),%edx
f010397a:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103980:	74 1c                	je     f010399e <env_create+0x70>
			panic("e_magic is not right\n");
f0103982:	c7 44 24 08 f7 76 10 	movl   $0xf01076f7,0x8(%esp)
f0103989:	f0 
f010398a:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103991:	00 
f0103992:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103999:	e8 a2 c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f010399e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039a1:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039a9:	77 20                	ja     f01039cb <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039af:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f01039b6:	f0 
f01039b7:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01039be:	00 
f01039bf:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f01039c6:	e8 75 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039cb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039d0:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f01039d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039d6:	03 5b 1c             	add    0x1c(%ebx),%ebx
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
f01039d9:	83 c3 20             	add    $0x20,%ebx
f01039dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01039df:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039e3:	83 c7 01             	add    $0x1,%edi
f01039e6:	be 01 00 00 00       	mov    $0x1,%esi
f01039eb:	eb 54                	jmp    f0103a41 <env_create+0x113>
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
			ph++;
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039ed:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039f0:	75 49                	jne    f0103a3b <env_create+0x10d>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039f2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039f5:	8b 53 08             	mov    0x8(%ebx),%edx
f01039f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039fb:	e8 a0 fb ff ff       	call   f01035a0 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f0103a00:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a0a:	03 43 04             	add    0x4(%ebx),%eax
f0103a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a11:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a14:	89 04 24             	mov    %eax,(%esp)
f0103a17:	e8 08 1e 00 00       	call   f0105824 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103a1c:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a1f:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a22:	29 c2                	sub    %eax,%edx
f0103a24:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a2f:	00 
f0103a30:	03 43 08             	add    0x8(%ebx),%eax
f0103a33:	89 04 24             	mov    %eax,(%esp)
f0103a36:	e8 9c 1d 00 00       	call   f01057d7 <memset>
f0103a3b:	83 c6 01             	add    $0x1,%esi
f0103a3e:	83 c3 20             	add    $0x20,%ebx

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a41:	39 fe                	cmp    %edi,%esi
f0103a43:	75 a8                	jne    f01039ed <env_create+0xbf>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a45:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a48:	8b 42 18             	mov    0x18(%edx),%eax
f0103a4b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a4e:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a51:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a56:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a5e:	e8 3d fb ff ff       	call   f01035a0 <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a63:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a6d:	77 20                	ja     f0103a8f <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a73:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0103a7a:	f0 
f0103a7b:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103a82:	00 
f0103a83:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103a8a:	e8 b1 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a8f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a94:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a9d:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103aa0:	83 c4 3c             	add    $0x3c,%esp
f0103aa3:	5b                   	pop    %ebx
f0103aa4:	5e                   	pop    %esi
f0103aa5:	5f                   	pop    %edi
f0103aa6:	5d                   	pop    %ebp
f0103aa7:	c3                   	ret    

f0103aa8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103aa8:	55                   	push   %ebp
f0103aa9:	89 e5                	mov    %esp,%ebp
f0103aab:	57                   	push   %edi
f0103aac:	56                   	push   %esi
f0103aad:	53                   	push   %ebx
f0103aae:	83 ec 2c             	sub    $0x2c,%esp
f0103ab1:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ab4:	e8 70 23 00 00       	call   f0105e29 <cpunum>
f0103ab9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103abc:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0103ac2:	75 34                	jne    f0103af8 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103ac4:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ac9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ace:	77 20                	ja     f0103af0 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ad4:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0103adb:	f0 
f0103adc:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103ae3:	00 
f0103ae4:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103aeb:	e8 50 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103af0:	05 00 00 00 10       	add    $0x10000000,%eax
f0103af5:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103af8:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103afb:	e8 29 23 00 00       	call   f0105e29 <cpunum>
f0103b00:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b03:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b08:	83 ba 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%edx)
f0103b0f:	74 11                	je     f0103b22 <env_free+0x7a>
f0103b11:	e8 13 23 00 00       	call   f0105e29 <cpunum>
f0103b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b19:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103b1f:	8b 40 48             	mov    0x48(%eax),%eax
f0103b22:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2a:	c7 04 24 0d 77 10 f0 	movl   $0xf010770d,(%esp)
f0103b31:	e8 70 04 00 00       	call   f0103fa6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b36:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b40:	c1 e0 02             	shl    $0x2,%eax
f0103b43:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b46:	8b 47 60             	mov    0x60(%edi),%eax
f0103b49:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b4c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103b4f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b55:	0f 84 b8 00 00 00    	je     f0103c13 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b5b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b61:	89 f0                	mov    %esi,%eax
f0103b63:	c1 e8 0c             	shr    $0xc,%eax
f0103b66:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b69:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103b6f:	72 20                	jb     f0103b91 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b71:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b75:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0103b7c:	f0 
f0103b7d:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103b84:	00 
f0103b85:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103b8c:	e8 af c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b91:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b94:	c1 e2 16             	shl    $0x16,%edx
f0103b97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b9a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b9f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103ba6:	01 
f0103ba7:	74 17                	je     f0103bc0 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ba9:	89 d8                	mov    %ebx,%eax
f0103bab:	c1 e0 0c             	shl    $0xc,%eax
f0103bae:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bb5:	8b 47 60             	mov    0x60(%edi),%eax
f0103bb8:	89 04 24             	mov    %eax,(%esp)
f0103bbb:	e8 cb d6 ff ff       	call   f010128b <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bc0:	83 c3 01             	add    $0x1,%ebx
f0103bc3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bc9:	75 d4                	jne    f0103b9f <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bcb:	8b 47 60             	mov    0x60(%edi),%eax
f0103bce:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bd1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bdb:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103be1:	72 1c                	jb     f0103bff <env_free+0x157>
		panic("pa2page called with invalid pa");
f0103be3:	c7 44 24 08 00 6b 10 	movl   $0xf0106b00,0x8(%esp)
f0103bea:	f0 
f0103beb:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bf2:	00 
f0103bf3:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0103bfa:	e8 41 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c02:	c1 e0 03             	shl    $0x3,%eax
f0103c05:	03 05 90 be 22 f0    	add    0xf022be90,%eax
		page_decref(pa2page(pa));
f0103c0b:	89 04 24             	mov    %eax,(%esp)
f0103c0e:	e8 aa d4 ff ff       	call   f01010bd <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c13:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103c17:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c1e:	0f 85 19 ff ff ff    	jne    f0103b3d <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c24:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c2c:	77 20                	ja     f0103c4e <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c32:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0103c39:	f0 
f0103c3a:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103c41:	00 
f0103c42:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103c49:	e8 f2 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c4e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c55:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c5a:	c1 e8 0c             	shr    $0xc,%eax
f0103c5d:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103c63:	72 1c                	jb     f0103c81 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f0103c65:	c7 44 24 08 00 6b 10 	movl   $0xf0106b00,0x8(%esp)
f0103c6c:	f0 
f0103c6d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c74:	00 
f0103c75:	c7 04 24 59 73 10 f0 	movl   $0xf0107359,(%esp)
f0103c7c:	e8 bf c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c81:	c1 e0 03             	shl    $0x3,%eax
f0103c84:	03 05 90 be 22 f0    	add    0xf022be90,%eax
	page_decref(pa2page(pa));
f0103c8a:	89 04 24             	mov    %eax,(%esp)
f0103c8d:	e8 2b d4 ff ff       	call   f01010bd <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c92:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c99:	a1 4c b2 22 f0       	mov    0xf022b24c,%eax
f0103c9e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ca1:	89 3d 4c b2 22 f0    	mov    %edi,0xf022b24c
}
f0103ca7:	83 c4 2c             	add    $0x2c,%esp
f0103caa:	5b                   	pop    %ebx
f0103cab:	5e                   	pop    %esi
f0103cac:	5f                   	pop    %edi
f0103cad:	5d                   	pop    %ebp
f0103cae:	c3                   	ret    

f0103caf <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103caf:	55                   	push   %ebp
f0103cb0:	89 e5                	mov    %esp,%ebp
f0103cb2:	53                   	push   %ebx
f0103cb3:	83 ec 14             	sub    $0x14,%esp
f0103cb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cb9:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103cbd:	75 19                	jne    f0103cd8 <env_destroy+0x29>
f0103cbf:	e8 65 21 00 00       	call   f0105e29 <cpunum>
f0103cc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc7:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103ccd:	74 09                	je     f0103cd8 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103ccf:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cd6:	eb 2f                	jmp    f0103d07 <env_destroy+0x58>
	}

	env_free(e);
f0103cd8:	89 1c 24             	mov    %ebx,(%esp)
f0103cdb:	e8 c8 fd ff ff       	call   f0103aa8 <env_free>

	if (curenv == e) {
f0103ce0:	e8 44 21 00 00       	call   f0105e29 <cpunum>
f0103ce5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce8:	39 98 28 c0 22 f0    	cmp    %ebx,-0xfdd3fd8(%eax)
f0103cee:	75 17                	jne    f0103d07 <env_destroy+0x58>
		curenv = NULL;
f0103cf0:	e8 34 21 00 00       	call   f0105e29 <cpunum>
f0103cf5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf8:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0103cff:	00 00 00 
		sched_yield();
f0103d02:	e8 bd 0d 00 00       	call   f0104ac4 <sched_yield>
	}
}
f0103d07:	83 c4 14             	add    $0x14,%esp
f0103d0a:	5b                   	pop    %ebx
f0103d0b:	5d                   	pop    %ebp
f0103d0c:	c3                   	ret    

f0103d0d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d0d:	55                   	push   %ebp
f0103d0e:	89 e5                	mov    %esp,%ebp
f0103d10:	53                   	push   %ebx
f0103d11:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d14:	e8 10 21 00 00       	call   f0105e29 <cpunum>
f0103d19:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1c:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103d22:	e8 02 21 00 00       	call   f0105e29 <cpunum>
f0103d27:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d2a:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d2d:	61                   	popa   
f0103d2e:	07                   	pop    %es
f0103d2f:	1f                   	pop    %ds
f0103d30:	83 c4 08             	add    $0x8,%esp
f0103d33:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d34:	c7 44 24 08 23 77 10 	movl   $0xf0107723,0x8(%esp)
f0103d3b:	f0 
f0103d3c:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0103d43:	00 
f0103d44:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103d4b:	e8 f0 c2 ff ff       	call   f0100040 <_panic>

f0103d50 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d50:	55                   	push   %ebp
f0103d51:	89 e5                	mov    %esp,%ebp
f0103d53:	53                   	push   %ebx
f0103d54:	83 ec 14             	sub    $0x14,%esp
f0103d57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d5a:	e8 ca 20 00 00       	call   f0105e29 <cpunum>
f0103d5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d62:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103d69:	75 10                	jne    f0103d7b <env_run+0x2b>
		curenv = e;
f0103d6b:	e8 b9 20 00 00       	call   f0105e29 <cpunum>
f0103d70:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d73:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
f0103d79:	eb 29                	jmp    f0103da4 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d7b:	e8 a9 20 00 00       	call   f0105e29 <cpunum>
f0103d80:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d83:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d89:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d8d:	75 15                	jne    f0103da4 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d8f:	e8 95 20 00 00       	call   f0105e29 <cpunum>
f0103d94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d97:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103d9d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103da4:	e8 80 20 00 00       	call   f0105e29 <cpunum>
f0103da9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dac:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103db2:	e8 72 20 00 00       	call   f0105e29 <cpunum>
f0103db7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dba:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103dc0:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103dc7:	e8 5d 20 00 00       	call   f0105e29 <cpunum>
f0103dcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dcf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103dd5:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103dd9:	e8 4b 20 00 00       	call   f0105e29 <cpunum>
f0103dde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de1:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103de7:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103def:	77 20                	ja     f0103e11 <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103df5:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0103dfc:	f0 
f0103dfd:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0103e04:	00 
f0103e05:	c7 04 24 b3 76 10 f0 	movl   $0xf01076b3,(%esp)
f0103e0c:	e8 2f c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e11:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e16:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e19:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0103e20:	e8 2e 23 00 00       	call   f0106153 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e25:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103e27:	e8 fd 1f 00 00       	call   f0105e29 <cpunum>
f0103e2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e2f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103e35:	89 04 24             	mov    %eax,(%esp)
f0103e38:	e8 d0 fe ff ff       	call   f0103d0d <env_pop_tf>

f0103e3d <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e3d:	55                   	push   %ebp
f0103e3e:	89 e5                	mov    %esp,%ebp
f0103e40:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e44:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e49:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e4a:	b2 71                	mov    $0x71,%dl
f0103e4c:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e4d:	0f b6 c0             	movzbl %al,%eax
}
f0103e50:	5d                   	pop    %ebp
f0103e51:	c3                   	ret    

f0103e52 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e52:	55                   	push   %ebp
f0103e53:	89 e5                	mov    %esp,%ebp
f0103e55:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e59:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e5e:	ee                   	out    %al,(%dx)
f0103e5f:	b2 71                	mov    $0x71,%dl
f0103e61:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e64:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e65:	5d                   	pop    %ebp
f0103e66:	c3                   	ret    

f0103e67 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e67:	55                   	push   %ebp
f0103e68:	89 e5                	mov    %esp,%ebp
f0103e6a:	56                   	push   %esi
f0103e6b:	53                   	push   %ebx
f0103e6c:	83 ec 10             	sub    $0x10,%esp
f0103e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e72:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103e78:	80 3d 50 b2 22 f0 00 	cmpb   $0x0,0xf022b250
f0103e7f:	74 4e                	je     f0103ecf <irq_setmask_8259A+0x68>
f0103e81:	89 c6                	mov    %eax,%esi
f0103e83:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e88:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e89:	66 c1 e8 08          	shr    $0x8,%ax
f0103e8d:	b2 a1                	mov    $0xa1,%dl
f0103e8f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e90:	c7 04 24 2f 77 10 f0 	movl   $0xf010772f,(%esp)
f0103e97:	e8 0a 01 00 00       	call   f0103fa6 <cprintf>
	for (i = 0; i < 16; i++)
f0103e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ea1:	0f b7 f6             	movzwl %si,%esi
f0103ea4:	f7 d6                	not    %esi
f0103ea6:	0f a3 de             	bt     %ebx,%esi
f0103ea9:	73 10                	jae    f0103ebb <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103eab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eaf:	c7 04 24 f3 7b 10 f0 	movl   $0xf0107bf3,(%esp)
f0103eb6:	e8 eb 00 00 00       	call   f0103fa6 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ebb:	83 c3 01             	add    $0x1,%ebx
f0103ebe:	83 fb 10             	cmp    $0x10,%ebx
f0103ec1:	75 e3                	jne    f0103ea6 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103ec3:	c7 04 24 50 76 10 f0 	movl   $0xf0107650,(%esp)
f0103eca:	e8 d7 00 00 00       	call   f0103fa6 <cprintf>
}
f0103ecf:	83 c4 10             	add    $0x10,%esp
f0103ed2:	5b                   	pop    %ebx
f0103ed3:	5e                   	pop    %esi
f0103ed4:	5d                   	pop    %ebp
f0103ed5:	c3                   	ret    

f0103ed6 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103ed6:	c6 05 50 b2 22 f0 01 	movb   $0x1,0xf022b250
f0103edd:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ee7:	ee                   	out    %al,(%dx)
f0103ee8:	b2 a1                	mov    $0xa1,%dl
f0103eea:	ee                   	out    %al,(%dx)
f0103eeb:	b2 20                	mov    $0x20,%dl
f0103eed:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ef2:	ee                   	out    %al,(%dx)
f0103ef3:	b2 21                	mov    $0x21,%dl
f0103ef5:	b8 20 00 00 00       	mov    $0x20,%eax
f0103efa:	ee                   	out    %al,(%dx)
f0103efb:	b8 04 00 00 00       	mov    $0x4,%eax
f0103f00:	ee                   	out    %al,(%dx)
f0103f01:	b8 03 00 00 00       	mov    $0x3,%eax
f0103f06:	ee                   	out    %al,(%dx)
f0103f07:	b2 a0                	mov    $0xa0,%dl
f0103f09:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f0e:	ee                   	out    %al,(%dx)
f0103f0f:	b2 a1                	mov    $0xa1,%dl
f0103f11:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f16:	ee                   	out    %al,(%dx)
f0103f17:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f1c:	ee                   	out    %al,(%dx)
f0103f1d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f22:	ee                   	out    %al,(%dx)
f0103f23:	b2 20                	mov    $0x20,%dl
f0103f25:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f2a:	ee                   	out    %al,(%dx)
f0103f2b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f30:	ee                   	out    %al,(%dx)
f0103f31:	b2 a0                	mov    $0xa0,%dl
f0103f33:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f38:	ee                   	out    %al,(%dx)
f0103f39:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f3e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f3f:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103f46:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f4a:	74 12                	je     f0103f5e <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f4c:	55                   	push   %ebp
f0103f4d:	89 e5                	mov    %esp,%ebp
f0103f4f:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103f52:	0f b7 c0             	movzwl %ax,%eax
f0103f55:	89 04 24             	mov    %eax,(%esp)
f0103f58:	e8 0a ff ff ff       	call   f0103e67 <irq_setmask_8259A>
}
f0103f5d:	c9                   	leave  
f0103f5e:	f3 c3                	repz ret 

f0103f60 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f60:	55                   	push   %ebp
f0103f61:	89 e5                	mov    %esp,%ebp
f0103f63:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f66:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f69:	89 04 24             	mov    %eax,(%esp)
f0103f6c:	e8 49 c8 ff ff       	call   f01007ba <cputchar>
	*cnt++;
}
f0103f71:	c9                   	leave  
f0103f72:	c3                   	ret    

f0103f73 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f73:	55                   	push   %ebp
f0103f74:	89 e5                	mov    %esp,%ebp
f0103f76:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f83:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f87:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f95:	c7 04 24 60 3f 10 f0 	movl   $0xf0103f60,(%esp)
f0103f9c:	e8 f3 10 00 00       	call   f0105094 <vprintfmt>
	return cnt;
}
f0103fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fa4:	c9                   	leave  
f0103fa5:	c3                   	ret    

f0103fa6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103fa6:	55                   	push   %ebp
f0103fa7:	89 e5                	mov    %esp,%ebp
f0103fa9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103fac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103faf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fb6:	89 04 24             	mov    %eax,(%esp)
f0103fb9:	e8 b5 ff ff ff       	call   f0103f73 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fbe:	c9                   	leave  
f0103fbf:	c3                   	ret    

f0103fc0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fc0:	55                   	push   %ebp
f0103fc1:	89 e5                	mov    %esp,%ebp
f0103fc3:	57                   	push   %edi
f0103fc4:	56                   	push   %esi
f0103fc5:	53                   	push   %ebx
f0103fc6:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103fc9:	e8 5b 1e 00 00       	call   f0105e29 <cpunum>
f0103fce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd1:	0f b6 98 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103fd8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fdc:	c7 04 24 43 77 10 f0 	movl   $0xf0107743,(%esp)
f0103fe3:	e8 be ff ff ff       	call   f0103fa6 <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fe8:	e8 3c 1e 00 00       	call   f0105e29 <cpunum>
f0103fed:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff0:	89 da                	mov    %ebx,%edx
f0103ff2:	f7 da                	neg    %edx
f0103ff4:	c1 e2 10             	shl    $0x10,%edx
f0103ff7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103ffd:	89 90 30 c0 22 f0    	mov    %edx,-0xfdd3fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104003:	e8 21 1e 00 00       	call   f0105e29 <cpunum>
f0104008:	6b c0 74             	imul   $0x74,%eax,%eax
f010400b:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f0104012:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0104014:	83 c3 05             	add    $0x5,%ebx
f0104017:	e8 0d 1e 00 00       	call   f0105e29 <cpunum>
f010401c:	89 c6                	mov    %eax,%esi
f010401e:	e8 06 1e 00 00       	call   f0105e29 <cpunum>
f0104023:	89 c7                	mov    %eax,%edi
f0104025:	e8 ff 1d 00 00       	call   f0105e29 <cpunum>
f010402a:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0104031:	f0 67 00 
f0104034:	6b f6 74             	imul   $0x74,%esi,%esi
f0104037:	81 c6 2c c0 22 f0    	add    $0xf022c02c,%esi
f010403d:	66 89 34 dd 42 03 12 	mov    %si,-0xfedfcbe(,%ebx,8)
f0104044:	f0 
f0104045:	6b d7 74             	imul   $0x74,%edi,%edx
f0104048:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f010404e:	c1 ea 10             	shr    $0x10,%edx
f0104051:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0104058:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010405f:	40 
f0104060:	6b c0 74             	imul   $0x74,%eax,%eax
f0104063:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f0104068:	c1 e8 18             	shr    $0x18,%eax
f010406b:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104072:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f0104079:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010407a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010407d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104080:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0104085:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104088:	83 c4 1c             	add    $0x1c,%esp
f010408b:	5b                   	pop    %ebx
f010408c:	5e                   	pop    %esi
f010408d:	5f                   	pop    %edi
f010408e:	5d                   	pop    %ebp
f010408f:	c3                   	ret    

f0104090 <trap_init>:
}


void
trap_init(void)
{
f0104090:	55                   	push   %ebp
f0104091:	89 e5                	mov    %esp,%ebp
f0104093:	83 ec 08             	sub    $0x8,%esp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104096:	b8 16 49 10 f0       	mov    $0xf0104916,%eax
f010409b:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f01040a1:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f01040a8:	08 00 
f01040aa:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f01040b1:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f01040b8:	c1 e8 10             	shr    $0x10,%eax
f01040bb:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f01040c1:	b8 20 49 10 f0       	mov    $0xf0104920,%eax
f01040c6:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f01040cc:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01040d3:	08 00 
f01040d5:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01040dc:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01040e3:	c1 e8 10             	shr    $0x10,%eax
f01040e6:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040ec:	b8 2a 49 10 f0       	mov    $0xf010492a,%eax
f01040f1:	66 a3 70 b2 22 f0    	mov    %ax,0xf022b270
f01040f7:	66 c7 05 72 b2 22 f0 	movw   $0x8,0xf022b272
f01040fe:	08 00 
f0104100:	c6 05 74 b2 22 f0 00 	movb   $0x0,0xf022b274
f0104107:	c6 05 75 b2 22 f0 8e 	movb   $0x8e,0xf022b275
f010410e:	c1 e8 10             	shr    $0x10,%eax
f0104111:	66 a3 76 b2 22 f0    	mov    %ax,0xf022b276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f0104117:	b8 34 49 10 f0       	mov    $0xf0104934,%eax
f010411c:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f0104122:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f0104129:	08 00 
f010412b:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f0104132:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f0104139:	c1 e8 10             	shr    $0x10,%eax
f010413c:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104142:	b8 3e 49 10 f0       	mov    $0xf010493e,%eax
f0104147:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f010414d:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0104154:	08 00 
f0104156:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f010415d:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0104164:	c1 e8 10             	shr    $0x10,%eax
f0104167:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010416d:	b8 48 49 10 f0       	mov    $0xf0104948,%eax
f0104172:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0104178:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f010417f:	08 00 
f0104181:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0104188:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f010418f:	c1 e8 10             	shr    $0x10,%eax
f0104192:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104198:	b8 52 49 10 f0       	mov    $0xf0104952,%eax
f010419d:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f01041a3:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f01041aa:	08 00 
f01041ac:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f01041b3:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f01041ba:	c1 e8 10             	shr    $0x10,%eax
f01041bd:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f01041c3:	b8 5c 49 10 f0       	mov    $0xf010495c,%eax
f01041c8:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f01041ce:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f01041d5:	08 00 
f01041d7:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f01041de:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f01041e5:	c1 e8 10             	shr    $0x10,%eax
f01041e8:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041ee:	b8 66 49 10 f0       	mov    $0xf0104966,%eax
f01041f3:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f01041f9:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f0104200:	08 00 
f0104202:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f0104209:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f0104210:	c1 e8 10             	shr    $0x10,%eax
f0104213:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f0104219:	b8 6e 49 10 f0       	mov    $0xf010496e,%eax
f010421e:	66 a3 a8 b2 22 f0    	mov    %ax,0xf022b2a8
f0104224:	66 c7 05 aa b2 22 f0 	movw   $0x8,0xf022b2aa
f010422b:	08 00 
f010422d:	c6 05 ac b2 22 f0 00 	movb   $0x0,0xf022b2ac
f0104234:	c6 05 ad b2 22 f0 8e 	movb   $0x8e,0xf022b2ad
f010423b:	c1 e8 10             	shr    $0x10,%eax
f010423e:	66 a3 ae b2 22 f0    	mov    %ax,0xf022b2ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104244:	b8 78 49 10 f0       	mov    $0xf0104978,%eax
f0104249:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f010424f:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0104256:	08 00 
f0104258:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f010425f:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0104266:	c1 e8 10             	shr    $0x10,%eax
f0104269:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010426f:	b8 80 49 10 f0       	mov    $0xf0104980,%eax
f0104274:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f010427a:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0104281:	08 00 
f0104283:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f010428a:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0104291:	c1 e8 10             	shr    $0x10,%eax
f0104294:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010429a:	b8 88 49 10 f0       	mov    $0xf0104988,%eax
f010429f:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f01042a5:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f01042ac:	08 00 
f01042ae:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f01042b5:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f01042bc:	c1 e8 10             	shr    $0x10,%eax
f01042bf:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f01042c5:	b8 90 49 10 f0       	mov    $0xf0104990,%eax
f01042ca:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f01042d0:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f01042d7:	08 00 
f01042d9:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f01042e0:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f01042e7:	c1 e8 10             	shr    $0x10,%eax
f01042ea:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042f0:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f01042f5:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f01042fb:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f0104302:	08 00 
f0104304:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f010430b:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f0104312:	c1 e8 10             	shr    $0x10,%eax
f0104315:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f010431b:	b8 a0 49 10 f0       	mov    $0xf01049a0,%eax
f0104320:	66 a3 d8 b2 22 f0    	mov    %ax,0xf022b2d8
f0104326:	66 c7 05 da b2 22 f0 	movw   $0x8,0xf022b2da
f010432d:	08 00 
f010432f:	c6 05 dc b2 22 f0 00 	movb   $0x0,0xf022b2dc
f0104336:	c6 05 dd b2 22 f0 8e 	movb   $0x8e,0xf022b2dd
f010433d:	c1 e8 10             	shr    $0x10,%eax
f0104340:	66 a3 de b2 22 f0    	mov    %ax,0xf022b2de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104346:	b8 aa 49 10 f0       	mov    $0xf01049aa,%eax
f010434b:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0104351:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0104358:	08 00 
f010435a:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0104361:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0104368:	c1 e8 10             	shr    $0x10,%eax
f010436b:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104371:	b8 b4 49 10 f0       	mov    $0xf01049b4,%eax
f0104376:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f010437c:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0104383:	08 00 
f0104385:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f010438c:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0104393:	c1 e8 10             	shr    $0x10,%eax
f0104396:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010439c:	b8 bc 49 10 f0       	mov    $0xf01049bc,%eax
f01043a1:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f01043a7:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f01043ae:	08 00 
f01043b0:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f01043b7:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f01043be:	c1 e8 10             	shr    $0x10,%eax
f01043c1:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f01043c7:	b8 c6 49 10 f0       	mov    $0xf01049c6,%eax
f01043cc:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f01043d2:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f01043d9:	08 00 
f01043db:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f01043e2:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f01043e9:	c1 e8 10             	shr    $0x10,%eax
f01043ec:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043f2:	b8 d0 49 10 f0       	mov    $0xf01049d0,%eax
f01043f7:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f01043fd:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0104404:	08 00 
f0104406:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f010440d:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0104414:	c1 e8 10             	shr    $0x10,%eax
f0104417:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6




	// Per-CPU setup 
	trap_init_percpu();
f010441d:	e8 9e fb ff ff       	call   f0103fc0 <trap_init_percpu>
}
f0104422:	c9                   	leave  
f0104423:	c3                   	ret    

f0104424 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104424:	55                   	push   %ebp
f0104425:	89 e5                	mov    %esp,%ebp
f0104427:	53                   	push   %ebx
f0104428:	83 ec 14             	sub    $0x14,%esp
f010442b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010442e:	8b 03                	mov    (%ebx),%eax
f0104430:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104434:	c7 04 24 51 77 10 f0 	movl   $0xf0107751,(%esp)
f010443b:	e8 66 fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104440:	8b 43 04             	mov    0x4(%ebx),%eax
f0104443:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104447:	c7 04 24 60 77 10 f0 	movl   $0xf0107760,(%esp)
f010444e:	e8 53 fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104453:	8b 43 08             	mov    0x8(%ebx),%eax
f0104456:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445a:	c7 04 24 6f 77 10 f0 	movl   $0xf010776f,(%esp)
f0104461:	e8 40 fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104466:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104469:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446d:	c7 04 24 7e 77 10 f0 	movl   $0xf010777e,(%esp)
f0104474:	e8 2d fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104479:	8b 43 10             	mov    0x10(%ebx),%eax
f010447c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104480:	c7 04 24 8d 77 10 f0 	movl   $0xf010778d,(%esp)
f0104487:	e8 1a fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010448c:	8b 43 14             	mov    0x14(%ebx),%eax
f010448f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104493:	c7 04 24 9c 77 10 f0 	movl   $0xf010779c,(%esp)
f010449a:	e8 07 fb ff ff       	call   f0103fa6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010449f:	8b 43 18             	mov    0x18(%ebx),%eax
f01044a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a6:	c7 04 24 ab 77 10 f0 	movl   $0xf01077ab,(%esp)
f01044ad:	e8 f4 fa ff ff       	call   f0103fa6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01044b2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044b9:	c7 04 24 ba 77 10 f0 	movl   $0xf01077ba,(%esp)
f01044c0:	e8 e1 fa ff ff       	call   f0103fa6 <cprintf>
}
f01044c5:	83 c4 14             	add    $0x14,%esp
f01044c8:	5b                   	pop    %ebx
f01044c9:	5d                   	pop    %ebp
f01044ca:	c3                   	ret    

f01044cb <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f01044cb:	55                   	push   %ebp
f01044cc:	89 e5                	mov    %esp,%ebp
f01044ce:	56                   	push   %esi
f01044cf:	53                   	push   %ebx
f01044d0:	83 ec 10             	sub    $0x10,%esp
f01044d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044d6:	e8 4e 19 00 00       	call   f0105e29 <cpunum>
f01044db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044e3:	c7 04 24 1e 78 10 f0 	movl   $0xf010781e,(%esp)
f01044ea:	e8 b7 fa ff ff       	call   f0103fa6 <cprintf>
	print_regs(&tf->tf_regs);
f01044ef:	89 1c 24             	mov    %ebx,(%esp)
f01044f2:	e8 2d ff ff ff       	call   f0104424 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044f7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ff:	c7 04 24 3c 78 10 f0 	movl   $0xf010783c,(%esp)
f0104506:	e8 9b fa ff ff       	call   f0103fa6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010450b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010450f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104513:	c7 04 24 4f 78 10 f0 	movl   $0xf010784f,(%esp)
f010451a:	e8 87 fa ff ff       	call   f0103fa6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010451f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104522:	83 f8 13             	cmp    $0x13,%eax
f0104525:	77 09                	ja     f0104530 <print_trapframe+0x65>
		return excnames[trapno];
f0104527:	8b 14 85 e0 7a 10 f0 	mov    -0xfef8520(,%eax,4),%edx
f010452e:	eb 1d                	jmp    f010454d <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f0104530:	ba c9 77 10 f0       	mov    $0xf01077c9,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104535:	83 f8 30             	cmp    $0x30,%eax
f0104538:	74 13                	je     f010454d <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010453a:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010453d:	83 fa 0f             	cmp    $0xf,%edx
f0104540:	ba d5 77 10 f0       	mov    $0xf01077d5,%edx
f0104545:	b9 e8 77 10 f0       	mov    $0xf01077e8,%ecx
f010454a:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010454d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104551:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104555:	c7 04 24 62 78 10 f0 	movl   $0xf0107862,(%esp)
f010455c:	e8 45 fa ff ff       	call   f0103fa6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104561:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0104567:	75 19                	jne    f0104582 <print_trapframe+0xb7>
f0104569:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010456d:	75 13                	jne    f0104582 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010456f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104572:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104576:	c7 04 24 74 78 10 f0 	movl   $0xf0107874,(%esp)
f010457d:	e8 24 fa ff ff       	call   f0103fa6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104582:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104585:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104589:	c7 04 24 83 78 10 f0 	movl   $0xf0107883,(%esp)
f0104590:	e8 11 fa ff ff       	call   f0103fa6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104595:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104599:	75 51                	jne    f01045ec <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010459b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010459e:	89 c2                	mov    %eax,%edx
f01045a0:	83 e2 01             	and    $0x1,%edx
f01045a3:	ba f7 77 10 f0       	mov    $0xf01077f7,%edx
f01045a8:	b9 02 78 10 f0       	mov    $0xf0107802,%ecx
f01045ad:	0f 45 ca             	cmovne %edx,%ecx
f01045b0:	89 c2                	mov    %eax,%edx
f01045b2:	83 e2 02             	and    $0x2,%edx
f01045b5:	ba 0e 78 10 f0       	mov    $0xf010780e,%edx
f01045ba:	be 14 78 10 f0       	mov    $0xf0107814,%esi
f01045bf:	0f 44 d6             	cmove  %esi,%edx
f01045c2:	83 e0 04             	and    $0x4,%eax
f01045c5:	b8 19 78 10 f0       	mov    $0xf0107819,%eax
f01045ca:	be 4e 79 10 f0       	mov    $0xf010794e,%esi
f01045cf:	0f 44 c6             	cmove  %esi,%eax
f01045d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045d6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045de:	c7 04 24 91 78 10 f0 	movl   $0xf0107891,(%esp)
f01045e5:	e8 bc f9 ff ff       	call   f0103fa6 <cprintf>
f01045ea:	eb 0c                	jmp    f01045f8 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045ec:	c7 04 24 50 76 10 f0 	movl   $0xf0107650,(%esp)
f01045f3:	e8 ae f9 ff ff       	call   f0103fa6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045f8:	8b 43 30             	mov    0x30(%ebx),%eax
f01045fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ff:	c7 04 24 a0 78 10 f0 	movl   $0xf01078a0,(%esp)
f0104606:	e8 9b f9 ff ff       	call   f0103fa6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010460b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010460f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104613:	c7 04 24 af 78 10 f0 	movl   $0xf01078af,(%esp)
f010461a:	e8 87 f9 ff ff       	call   f0103fa6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010461f:	8b 43 38             	mov    0x38(%ebx),%eax
f0104622:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104626:	c7 04 24 c2 78 10 f0 	movl   $0xf01078c2,(%esp)
f010462d:	e8 74 f9 ff ff       	call   f0103fa6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104632:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104636:	74 27                	je     f010465f <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104638:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010463b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463f:	c7 04 24 d1 78 10 f0 	movl   $0xf01078d1,(%esp)
f0104646:	e8 5b f9 ff ff       	call   f0103fa6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010464b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010464f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104653:	c7 04 24 e0 78 10 f0 	movl   $0xf01078e0,(%esp)
f010465a:	e8 47 f9 ff ff       	call   f0103fa6 <cprintf>
	}
}
f010465f:	83 c4 10             	add    $0x10,%esp
f0104662:	5b                   	pop    %ebx
f0104663:	5e                   	pop    %esi
f0104664:	5d                   	pop    %ebp
f0104665:	c3                   	ret    

f0104666 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104666:	55                   	push   %ebp
f0104667:	89 e5                	mov    %esp,%ebp
f0104669:	83 ec 28             	sub    $0x28,%esp
f010466c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010466f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104672:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104675:	8b 75 08             	mov    0x8(%ebp),%esi
f0104678:	0f 20 d3             	mov    %cr2,%ebx
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f010467b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104680:	75 1c                	jne    f010469e <page_fault_handler+0x38>
		panic("page fault happens in the kern mode");
f0104682:	c7 44 24 08 98 7a 10 	movl   $0xf0107a98,0x8(%esp)
f0104689:	f0 
f010468a:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f0104691:	00 
f0104692:	c7 04 24 f3 78 10 f0 	movl   $0xf01078f3,(%esp)
f0104699:	e8 a2 b9 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010469e:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01046a1:	e8 83 17 00 00       	call   f0105e29 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01046a6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01046aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01046ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b1:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01046b7:	8b 40 48             	mov    0x48(%eax),%eax
f01046ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046be:	c7 04 24 bc 7a 10 f0 	movl   $0xf0107abc,(%esp)
f01046c5:	e8 dc f8 ff ff       	call   f0103fa6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01046ca:	89 34 24             	mov    %esi,(%esp)
f01046cd:	e8 f9 fd ff ff       	call   f01044cb <print_trapframe>
	env_destroy(curenv);
f01046d2:	e8 52 17 00 00       	call   f0105e29 <cpunum>
f01046d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046da:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01046e0:	89 04 24             	mov    %eax,(%esp)
f01046e3:	e8 c7 f5 ff ff       	call   f0103caf <env_destroy>
}
f01046e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01046eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01046ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01046f1:	89 ec                	mov    %ebp,%esp
f01046f3:	5d                   	pop    %ebp
f01046f4:	c3                   	ret    

f01046f5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01046f5:	55                   	push   %ebp
f01046f6:	89 e5                	mov    %esp,%ebp
f01046f8:	57                   	push   %edi
f01046f9:	56                   	push   %esi
f01046fa:	83 ec 20             	sub    $0x20,%esp
f01046fd:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104700:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104701:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0104708:	74 01                	je     f010470b <trap+0x16>
		asm volatile("hlt");
f010470a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010470b:	e8 19 17 00 00       	call   f0105e29 <cpunum>
f0104710:	6b d0 74             	imul   $0x74,%eax,%edx
f0104713:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104719:	b8 01 00 00 00       	mov    $0x1,%eax
f010471e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104722:	83 f8 02             	cmp    $0x2,%eax
f0104725:	75 0c                	jne    f0104733 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104727:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010472e:	e8 74 19 00 00       	call   f01060a7 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104733:	9c                   	pushf  
f0104734:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104735:	f6 c4 02             	test   $0x2,%ah
f0104738:	74 24                	je     f010475e <trap+0x69>
f010473a:	c7 44 24 0c ff 78 10 	movl   $0xf01078ff,0xc(%esp)
f0104741:	f0 
f0104742:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f0104749:	f0 
f010474a:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0104751:	00 
f0104752:	c7 04 24 f3 78 10 f0 	movl   $0xf01078f3,(%esp)
f0104759:	e8 e2 b8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010475e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104762:	83 e0 03             	and    $0x3,%eax
f0104765:	83 f8 03             	cmp    $0x3,%eax
f0104768:	0f 85 a7 00 00 00    	jne    f0104815 <trap+0x120>
f010476e:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0104775:	e8 2d 19 00 00       	call   f01060a7 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010477a:	e8 aa 16 00 00       	call   f0105e29 <cpunum>
f010477f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104782:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104789:	75 24                	jne    f01047af <trap+0xba>
f010478b:	c7 44 24 0c 18 79 10 	movl   $0xf0107918,0xc(%esp)
f0104792:	f0 
f0104793:	c7 44 24 08 7f 73 10 	movl   $0xf010737f,0x8(%esp)
f010479a:	f0 
f010479b:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01047a2:	00 
f01047a3:	c7 04 24 f3 78 10 f0 	movl   $0xf01078f3,(%esp)
f01047aa:	e8 91 b8 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01047af:	e8 75 16 00 00       	call   f0105e29 <cpunum>
f01047b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01047bd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01047c1:	75 2d                	jne    f01047f0 <trap+0xfb>
			env_free(curenv);
f01047c3:	e8 61 16 00 00       	call   f0105e29 <cpunum>
f01047c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cb:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01047d1:	89 04 24             	mov    %eax,(%esp)
f01047d4:	e8 cf f2 ff ff       	call   f0103aa8 <env_free>
			curenv = NULL;
f01047d9:	e8 4b 16 00 00       	call   f0105e29 <cpunum>
f01047de:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e1:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01047e8:	00 00 00 
			sched_yield();
f01047eb:	e8 d4 02 00 00       	call   f0104ac4 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01047f0:	e8 34 16 00 00       	call   f0105e29 <cpunum>
f01047f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01047fe:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104803:	89 c7                	mov    %eax,%edi
f0104805:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104807:	e8 1d 16 00 00       	call   f0105e29 <cpunum>
f010480c:	6b c0 74             	imul   $0x74,%eax,%eax
f010480f:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104815:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f010481b:	8b 46 28             	mov    0x28(%esi),%eax
f010481e:	83 f8 0e             	cmp    $0xe,%eax
f0104821:	75 0d                	jne    f0104830 <trap+0x13b>
		page_fault_handler(tf);
f0104823:	89 34 24             	mov    %esi,(%esp)
f0104826:	e8 3b fe ff ff       	call   f0104666 <page_fault_handler>
f010482b:	e9 a5 00 00 00       	jmp    f01048d5 <trap+0x1e0>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f0104830:	83 f8 03             	cmp    $0x3,%eax
f0104833:	75 0d                	jne    f0104842 <trap+0x14d>
		monitor(tf);
f0104835:	89 34 24             	mov    %esi,(%esp)
f0104838:	e8 cc c0 ff ff       	call   f0100909 <monitor>
f010483d:	e9 93 00 00 00       	jmp    f01048d5 <trap+0x1e0>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f0104842:	83 f8 30             	cmp    $0x30,%eax
f0104845:	75 32                	jne    f0104879 <trap+0x184>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104847:	8b 46 04             	mov    0x4(%esi),%eax
f010484a:	89 44 24 14          	mov    %eax,0x14(%esp)
f010484e:	8b 06                	mov    (%esi),%eax
f0104850:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104854:	8b 46 10             	mov    0x10(%esi),%eax
f0104857:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010485b:	8b 46 18             	mov    0x18(%esi),%eax
f010485e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104862:	8b 46 14             	mov    0x14(%esi),%eax
f0104865:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104869:	8b 46 1c             	mov    0x1c(%esi),%eax
f010486c:	89 04 24             	mov    %eax,(%esp)
f010486f:	e8 0c 03 00 00       	call   f0104b80 <syscall>
f0104874:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104877:	eb 5c                	jmp    f01048d5 <trap+0x1e0>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104879:	83 f8 27             	cmp    $0x27,%eax
f010487c:	75 16                	jne    f0104894 <trap+0x19f>
		cprintf("Spurious interrupt on irq 7\n");
f010487e:	c7 04 24 1f 79 10 f0 	movl   $0xf010791f,(%esp)
f0104885:	e8 1c f7 ff ff       	call   f0103fa6 <cprintf>
		print_trapframe(tf);
f010488a:	89 34 24             	mov    %esi,(%esp)
f010488d:	e8 39 fc ff ff       	call   f01044cb <print_trapframe>
f0104892:	eb 41                	jmp    f01048d5 <trap+0x1e0>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104894:	89 34 24             	mov    %esi,(%esp)
f0104897:	e8 2f fc ff ff       	call   f01044cb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010489c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01048a1:	75 1c                	jne    f01048bf <trap+0x1ca>
		panic("unhandled trap in kernel");
f01048a3:	c7 44 24 08 3c 79 10 	movl   $0xf010793c,0x8(%esp)
f01048aa:	f0 
f01048ab:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f01048b2:	00 
f01048b3:	c7 04 24 f3 78 10 f0 	movl   $0xf01078f3,(%esp)
f01048ba:	e8 81 b7 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01048bf:	e8 65 15 00 00       	call   f0105e29 <cpunum>
f01048c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01048cd:	89 04 24             	mov    %eax,(%esp)
f01048d0:	e8 da f3 ff ff       	call   f0103caf <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01048d5:	e8 4f 15 00 00       	call   f0105e29 <cpunum>
f01048da:	6b c0 74             	imul   $0x74,%eax,%eax
f01048dd:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01048e4:	74 2a                	je     f0104910 <trap+0x21b>
f01048e6:	e8 3e 15 00 00       	call   f0105e29 <cpunum>
f01048eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ee:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01048f4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048f8:	75 16                	jne    f0104910 <trap+0x21b>
		env_run(curenv);
f01048fa:	e8 2a 15 00 00       	call   f0105e29 <cpunum>
f01048ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104902:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104908:	89 04 24             	mov    %eax,(%esp)
f010490b:	e8 40 f4 ff ff       	call   f0103d50 <env_run>
	else
		sched_yield();
f0104910:	e8 af 01 00 00       	call   f0104ac4 <sched_yield>
	...

f0104916 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104916:	6a 00                	push   $0x0
f0104918:	6a 00                	push   $0x0
f010491a:	e9 ba 00 00 00       	jmp    f01049d9 <_alltraps>
f010491f:	90                   	nop

f0104920 <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104920:	6a 00                	push   $0x0
f0104922:	6a 01                	push   $0x1
f0104924:	e9 b0 00 00 00       	jmp    f01049d9 <_alltraps>
f0104929:	90                   	nop

f010492a <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f010492a:	6a 00                	push   $0x0
f010492c:	6a 02                	push   $0x2
f010492e:	e9 a6 00 00 00       	jmp    f01049d9 <_alltraps>
f0104933:	90                   	nop

f0104934 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104934:	6a 00                	push   $0x0
f0104936:	6a 03                	push   $0x3
f0104938:	e9 9c 00 00 00       	jmp    f01049d9 <_alltraps>
f010493d:	90                   	nop

f010493e <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f010493e:	6a 00                	push   $0x0
f0104940:	6a 04                	push   $0x4
f0104942:	e9 92 00 00 00       	jmp    f01049d9 <_alltraps>
f0104947:	90                   	nop

f0104948 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104948:	6a 00                	push   $0x0
f010494a:	6a 05                	push   $0x5
f010494c:	e9 88 00 00 00       	jmp    f01049d9 <_alltraps>
f0104951:	90                   	nop

f0104952 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104952:	6a 00                	push   $0x0
f0104954:	6a 06                	push   $0x6
f0104956:	e9 7e 00 00 00       	jmp    f01049d9 <_alltraps>
f010495b:	90                   	nop

f010495c <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f010495c:	6a 00                	push   $0x0
f010495e:	6a 07                	push   $0x7
f0104960:	e9 74 00 00 00       	jmp    f01049d9 <_alltraps>
f0104965:	90                   	nop

f0104966 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104966:	6a 08                	push   $0x8
f0104968:	e9 6c 00 00 00       	jmp    f01049d9 <_alltraps>
f010496d:	90                   	nop

f010496e <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f010496e:	6a 00                	push   $0x0
f0104970:	6a 09                	push   $0x9
f0104972:	e9 62 00 00 00       	jmp    f01049d9 <_alltraps>
f0104977:	90                   	nop

f0104978 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104978:	6a 0a                	push   $0xa
f010497a:	e9 5a 00 00 00       	jmp    f01049d9 <_alltraps>
f010497f:	90                   	nop

f0104980 <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104980:	6a 0b                	push   $0xb
f0104982:	e9 52 00 00 00       	jmp    f01049d9 <_alltraps>
f0104987:	90                   	nop

f0104988 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104988:	6a 0c                	push   $0xc
f010498a:	e9 4a 00 00 00       	jmp    f01049d9 <_alltraps>
f010498f:	90                   	nop

f0104990 <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104990:	6a 0d                	push   $0xd
f0104992:	e9 42 00 00 00       	jmp    f01049d9 <_alltraps>
f0104997:	90                   	nop

f0104998 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104998:	6a 0e                	push   $0xe
f010499a:	e9 3a 00 00 00       	jmp    f01049d9 <_alltraps>
f010499f:	90                   	nop

f01049a0 <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f01049a0:	6a 00                	push   $0x0
f01049a2:	6a 0f                	push   $0xf
f01049a4:	e9 30 00 00 00       	jmp    f01049d9 <_alltraps>
f01049a9:	90                   	nop

f01049aa <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f01049aa:	6a 00                	push   $0x0
f01049ac:	6a 10                	push   $0x10
f01049ae:	e9 26 00 00 00       	jmp    f01049d9 <_alltraps>
f01049b3:	90                   	nop

f01049b4 <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f01049b4:	6a 11                	push   $0x11
f01049b6:	e9 1e 00 00 00       	jmp    f01049d9 <_alltraps>
f01049bb:	90                   	nop

f01049bc <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f01049bc:	6a 00                	push   $0x0
f01049be:	6a 12                	push   $0x12
f01049c0:	e9 14 00 00 00       	jmp    f01049d9 <_alltraps>
f01049c5:	90                   	nop

f01049c6 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f01049c6:	6a 00                	push   $0x0
f01049c8:	6a 13                	push   $0x13
f01049ca:	e9 0a 00 00 00       	jmp    f01049d9 <_alltraps>
f01049cf:	90                   	nop

f01049d0 <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f01049d0:	6a 00                	push   $0x0
f01049d2:	6a 30                	push   $0x30
f01049d4:	e9 00 00 00 00       	jmp    f01049d9 <_alltraps>

f01049d9 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f01049d9:	1e                   	push   %ds
	pushl %es
f01049da:	06                   	push   %es
	pushal
f01049db:	60                   	pusha  
	movl $GD_KD, %eax
f01049dc:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01049e1:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01049e3:	8e c0                	mov    %eax,%es

	pushl %esp
f01049e5:	54                   	push   %esp
	call trap
f01049e6:	e8 0a fd ff ff       	call   f01046f5 <trap>
	...

f01049ec <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01049ec:	55                   	push   %ebp
f01049ed:	89 e5                	mov    %esp,%ebp
f01049ef:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f01049f2:	8b 15 48 b2 22 f0    	mov    0xf022b248,%edx
f01049f8:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01049fb:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104a00:	8b 0a                	mov    (%edx),%ecx
f0104a02:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a05:	83 f9 02             	cmp    $0x2,%ecx
f0104a08:	76 0f                	jbe    f0104a19 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a0a:	83 c0 01             	add    $0x1,%eax
f0104a0d:	83 c2 7c             	add    $0x7c,%edx
f0104a10:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a15:	75 e9                	jne    f0104a00 <sched_halt+0x14>
f0104a17:	eb 07                	jmp    f0104a20 <sched_halt+0x34>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104a19:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a1e:	75 1a                	jne    f0104a3a <sched_halt+0x4e>
		cprintf("No runnable environments in the system!\n");
f0104a20:	c7 04 24 30 7b 10 f0 	movl   $0xf0107b30,(%esp)
f0104a27:	e8 7a f5 ff ff       	call   f0103fa6 <cprintf>
		while (1)
			monitor(NULL);
f0104a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104a33:	e8 d1 be ff ff       	call   f0100909 <monitor>
f0104a38:	eb f2                	jmp    f0104a2c <sched_halt+0x40>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a3a:	e8 ea 13 00 00       	call   f0105e29 <cpunum>
f0104a3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a42:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104a49:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a4c:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104a51:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a56:	77 20                	ja     f0104a78 <sched_halt+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a5c:	c7 44 24 08 44 65 10 	movl   $0xf0106544,0x8(%esp)
f0104a63:	f0 
f0104a64:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0104a6b:	00 
f0104a6c:	c7 04 24 59 7b 10 f0 	movl   $0xf0107b59,(%esp)
f0104a73:	e8 c8 b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104a78:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104a7d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a80:	e8 a4 13 00 00       	call   f0105e29 <cpunum>
f0104a85:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a88:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104a8e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104a93:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104a97:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0104a9e:	e8 b0 16 00 00       	call   f0106153 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104aa3:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104aa5:	e8 7f 13 00 00       	call   f0105e29 <cpunum>
f0104aaa:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104aad:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104ab3:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ab8:	89 c4                	mov    %eax,%esp
f0104aba:	6a 00                	push   $0x0
f0104abc:	6a 00                	push   $0x0
f0104abe:	fb                   	sti    
f0104abf:	f4                   	hlt    
f0104ac0:	eb fd                	jmp    f0104abf <sched_halt+0xd3>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104ac2:	c9                   	leave  
f0104ac3:	c3                   	ret    

f0104ac4 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104ac4:	55                   	push   %ebp
f0104ac5:	89 e5                	mov    %esp,%ebp
f0104ac7:	57                   	push   %edi
f0104ac8:	56                   	push   %esi
f0104ac9:	53                   	push   %ebx
f0104aca:	83 ec 2c             	sub    $0x2c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
f0104acd:	e8 57 13 00 00       	call   f0105e29 <cpunum>
f0104ad2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104adb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int EnvID = 0;
f0104ade:	bb 00 00 00 00       	mov    $0x0,%ebx
	int startID = 0;
	int i=0;
	if(e != NULL){	
f0104ae3:	85 c0                	test   %eax,%eax
f0104ae5:	74 0a                	je     f0104af1 <sched_yield+0x2d>
		EnvID =  e->env_id;
f0104ae7:	8b 58 48             	mov    0x48(%eax),%ebx
		e->env_status = ENV_RUNNABLE;
f0104aea:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	startID = (EnvID+1) % (NENV-1);
f0104af1:	8d 4b 01             	lea    0x1(%ebx),%ecx
f0104af4:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104af9:	89 c8                	mov    %ecx,%eax
f0104afb:	f7 ea                	imul   %edx
f0104afd:	01 ca                	add    %ecx,%edx
f0104aff:	c1 fa 09             	sar    $0x9,%edx
f0104b02:	89 c8                	mov    %ecx,%eax
f0104b04:	c1 f8 1f             	sar    $0x1f,%eax
f0104b07:	29 c2                	sub    %eax,%edx
f0104b09:	89 d0                	mov    %edx,%eax
f0104b0b:	c1 e0 0a             	shl    $0xa,%eax
f0104b0e:	29 d0                	sub    %edx,%eax
	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; i != EnvID; i = (i+1)%(NENV-1) ){
		if(envs[i].env_status == ENV_RUNNABLE)
f0104b10:	8b 35 48 b2 22 f0    	mov    0xf022b248,%esi
		EnvID =  e->env_id;
		e->env_status = ENV_RUNNABLE;
	}
	startID = (EnvID+1) % (NENV-1);
	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; i != EnvID; i = (i+1)%(NENV-1) ){
f0104b16:	89 ca                	mov    %ecx,%edx
f0104b18:	29 c2                	sub    %eax,%edx
f0104b1a:	bf 03 08 20 80       	mov    $0x80200803,%edi
f0104b1f:	eb 31                	jmp    f0104b52 <sched_yield+0x8e>
		if(envs[i].env_status == ENV_RUNNABLE)
f0104b21:	6b c2 7c             	imul   $0x7c,%edx,%eax
f0104b24:	01 f0                	add    %esi,%eax
f0104b26:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104b2a:	75 08                	jne    f0104b34 <sched_yield+0x70>
			env_run(&envs[i]);
f0104b2c:	89 04 24             	mov    %eax,(%esp)
f0104b2f:	e8 1c f2 ff ff       	call   f0103d50 <env_run>
		EnvID =  e->env_id;
		e->env_status = ENV_RUNNABLE;
	}
	startID = (EnvID+1) % (NENV-1);
	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; i != EnvID; i = (i+1)%(NENV-1) ){
f0104b34:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104b37:	89 c8                	mov    %ecx,%eax
f0104b39:	f7 ef                	imul   %edi
f0104b3b:	01 ca                	add    %ecx,%edx
f0104b3d:	c1 fa 09             	sar    $0x9,%edx
f0104b40:	89 c8                	mov    %ecx,%eax
f0104b42:	c1 f8 1f             	sar    $0x1f,%eax
f0104b45:	29 c2                	sub    %eax,%edx
f0104b47:	89 d0                	mov    %edx,%eax
f0104b49:	c1 e0 0a             	shl    $0xa,%eax
f0104b4c:	29 d0                	sub    %edx,%eax
f0104b4e:	89 ca                	mov    %ecx,%edx
f0104b50:	29 c2                	sub    %eax,%edx
f0104b52:	39 da                	cmp    %ebx,%edx
f0104b54:	75 cb                	jne    f0104b21 <sched_yield+0x5d>
		if(envs[i].env_status == ENV_RUNNABLE)
			env_run(&envs[i]);
	}

	if(e)
f0104b56:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b5a:	74 0b                	je     f0104b67 <sched_yield+0xa3>
		env_run(e);
f0104b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b5f:	89 04 24             	mov    %eax,(%esp)
f0104b62:	e8 e9 f1 ff ff       	call   f0103d50 <env_run>

	// sched_halt never returns
	sched_halt();
f0104b67:	e8 80 fe ff ff       	call   f01049ec <sched_halt>
	}
f0104b6c:	83 c4 2c             	add    $0x2c,%esp
f0104b6f:	5b                   	pop    %ebx
f0104b70:	5e                   	pop    %esi
f0104b71:	5f                   	pop    %edi
f0104b72:	5d                   	pop    %ebp
f0104b73:	c3                   	ret    
	...

f0104b80 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104b80:	55                   	push   %ebp
f0104b81:	89 e5                	mov    %esp,%ebp
f0104b83:	53                   	push   %ebx
f0104b84:	83 ec 24             	sub    $0x24,%esp
f0104b87:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104b8d:	83 f8 0a             	cmp    $0xa,%eax
f0104b90:	0f 87 e0 00 00 00    	ja     f0104c76 <syscall+0xf6>
f0104b96:	ff 24 85 a0 7b 10 f0 	jmp    *-0xfef8460(,%eax,4)
	// Destroy the environment if not.

	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104b9d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104ba1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ba8:	c7 04 24 66 7b 10 f0 	movl   $0xf0107b66,(%esp)
f0104baf:	e8 f2 f3 ff ff       	call   f0103fa6 <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104bb4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bb9:	e9 bd 00 00 00       	jmp    f0104c7b <syscall+0xfb>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104bbe:	e8 a2 ba ff ff       	call   f0100665 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104bc3:	e9 b3 00 00 00       	jmp    f0104c7b <syscall+0xfb>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104bc8:	90                   	nop
f0104bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104bd0:	e8 54 12 00 00       	call   f0105e29 <cpunum>
f0104bd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104bde:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104be1:	e9 95 00 00 00       	jmp    f0104c7b <syscall+0xfb>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104be6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104bed:	00 
f0104bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bf5:	89 14 24             	mov    %edx,(%esp)
f0104bf8:	e8 4c ea ff ff       	call   f0103649 <envid2env>
f0104bfd:	85 c0                	test   %eax,%eax
f0104bff:	78 7a                	js     f0104c7b <syscall+0xfb>
		return r;
	if (e == curenv)
f0104c01:	e8 23 12 00 00       	call   f0105e29 <cpunum>
f0104c06:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104c09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0c:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104c12:	75 23                	jne    f0104c37 <syscall+0xb7>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104c14:	e8 10 12 00 00       	call   f0105e29 <cpunum>
f0104c19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c22:	8b 40 48             	mov    0x48(%eax),%eax
f0104c25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c29:	c7 04 24 6b 7b 10 f0 	movl   $0xf0107b6b,(%esp)
f0104c30:	e8 71 f3 ff ff       	call   f0103fa6 <cprintf>
f0104c35:	eb 28                	jmp    f0104c5f <syscall+0xdf>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104c37:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104c3a:	e8 ea 11 00 00       	call   f0105e29 <cpunum>
f0104c3f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104c43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c46:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104c4c:	8b 40 48             	mov    0x48(%eax),%eax
f0104c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c53:	c7 04 24 86 7b 10 f0 	movl   $0xf0107b86,(%esp)
f0104c5a:	e8 47 f3 ff ff       	call   f0103fa6 <cprintf>
	env_destroy(e);
f0104c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c62:	89 04 24             	mov    %eax,(%esp)
f0104c65:	e8 45 f0 ff ff       	call   f0103caf <env_destroy>
	return 0;
f0104c6a:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
						break;
f0104c6f:	eb 0a                	jmp    f0104c7b <syscall+0xfb>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c71:	e8 4e fe ff ff       	call   f0104ac4 <sched_yield>
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
						break;
		case SYS_yield:      sys_yield();
		default:
			return -E_NO_SYS;
f0104c76:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
	return ret;
}
f0104c7b:	83 c4 24             	add    $0x24,%esp
f0104c7e:	5b                   	pop    %ebx
f0104c7f:	5d                   	pop    %ebp
f0104c80:	c3                   	ret    

f0104c81 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c81:	55                   	push   %ebp
f0104c82:	89 e5                	mov    %esp,%ebp
f0104c84:	57                   	push   %edi
f0104c85:	56                   	push   %esi
f0104c86:	53                   	push   %ebx
f0104c87:	83 ec 14             	sub    $0x14,%esp
f0104c8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c90:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c93:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c96:	8b 1a                	mov    (%edx),%ebx
f0104c98:	8b 01                	mov    (%ecx),%eax
f0104c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c9d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ca4:	e9 88 00 00 00       	jmp    f0104d31 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104cac:	01 d8                	add    %ebx,%eax
f0104cae:	89 c7                	mov    %eax,%edi
f0104cb0:	c1 ef 1f             	shr    $0x1f,%edi
f0104cb3:	01 c7                	add    %eax,%edi
f0104cb5:	d1 ff                	sar    %edi
f0104cb7:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104cba:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cbd:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104cc0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cc2:	eb 03                	jmp    f0104cc7 <stab_binsearch+0x46>
			m--;
f0104cc4:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cc7:	39 c3                	cmp    %eax,%ebx
f0104cc9:	7f 1f                	jg     f0104cea <stab_binsearch+0x69>
f0104ccb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ccf:	83 ea 0c             	sub    $0xc,%edx
f0104cd2:	39 f1                	cmp    %esi,%ecx
f0104cd4:	75 ee                	jne    f0104cc4 <stab_binsearch+0x43>
f0104cd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cd9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cdc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cdf:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ce3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ce6:	76 18                	jbe    f0104d00 <stab_binsearch+0x7f>
f0104ce8:	eb 05                	jmp    f0104cef <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cea:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104ced:	eb 42                	jmp    f0104d31 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104cef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cf2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104cf4:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cf7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104cfe:	eb 31                	jmp    f0104d31 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104d00:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104d03:	73 17                	jae    f0104d1c <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104d08:	83 e8 01             	sub    $0x1,%eax
f0104d0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d0e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d11:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d13:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d1a:	eb 15                	jmp    f0104d31 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d1f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104d22:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0104d24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d28:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d2a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d31:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d34:	0f 8e 6f ff ff ff    	jle    f0104ca9 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d3a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d3e:	75 0f                	jne    f0104d4f <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d43:	8b 00                	mov    (%eax),%eax
f0104d45:	83 e8 01             	sub    $0x1,%eax
f0104d48:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d4b:	89 07                	mov    %eax,(%edi)
f0104d4d:	eb 2c                	jmp    f0104d7b <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d52:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d57:	8b 0f                	mov    (%edi),%ecx
f0104d59:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d5c:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104d5f:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d62:	eb 03                	jmp    f0104d67 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d64:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d67:	39 c8                	cmp    %ecx,%eax
f0104d69:	7e 0b                	jle    f0104d76 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104d6b:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104d6f:	83 ea 0c             	sub    $0xc,%edx
f0104d72:	39 f3                	cmp    %esi,%ebx
f0104d74:	75 ee                	jne    f0104d64 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d79:	89 07                	mov    %eax,(%edi)
	}
}
f0104d7b:	83 c4 14             	add    $0x14,%esp
f0104d7e:	5b                   	pop    %ebx
f0104d7f:	5e                   	pop    %esi
f0104d80:	5f                   	pop    %edi
f0104d81:	5d                   	pop    %ebp
f0104d82:	c3                   	ret    

f0104d83 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d83:	55                   	push   %ebp
f0104d84:	89 e5                	mov    %esp,%ebp
f0104d86:	57                   	push   %edi
f0104d87:	56                   	push   %esi
f0104d88:	53                   	push   %ebx
f0104d89:	83 ec 3c             	sub    $0x3c,%esp
f0104d8c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d92:	c7 06 cc 7b 10 f0    	movl   $0xf0107bcc,(%esi)
	info->eip_line = 0;
f0104d98:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104d9f:	c7 46 08 cc 7b 10 f0 	movl   $0xf0107bcc,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104da6:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104dad:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104db0:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104db7:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104dbd:	77 21                	ja     f0104de0 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104dbf:	a1 00 00 20 00       	mov    0x200000,%eax
f0104dc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104dc7:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104dcc:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0104dd2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f0104dd5:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0104ddb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104dde:	eb 1a                	jmp    f0104dfa <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104de0:	c7 45 cc 4a 56 11 f0 	movl   $0xf011564a,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104de7:	c7 45 d0 d1 1f 11 f0 	movl   $0xf0111fd1,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104dee:	b8 d0 1f 11 f0       	mov    $0xf0111fd0,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104df3:	c7 45 d4 ac 80 10 f0 	movl   $0xf01080ac,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104dfa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104dfd:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0104e00:	0f 83 2f 01 00 00    	jae    f0104f35 <debuginfo_eip+0x1b2>
f0104e06:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e0a:	0f 85 2c 01 00 00    	jne    f0104f3c <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e10:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104e1a:	29 d8                	sub    %ebx,%eax
f0104e1c:	c1 f8 02             	sar    $0x2,%eax
f0104e1f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104e25:	83 e8 01             	sub    $0x1,%eax
f0104e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e2f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104e36:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104e39:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e3c:	89 d8                	mov    %ebx,%eax
f0104e3e:	e8 3e fe ff ff       	call   f0104c81 <stab_binsearch>
	if (lfile == 0)
f0104e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e46:	85 c0                	test   %eax,%eax
f0104e48:	0f 84 f5 00 00 00    	je     f0104f43 <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e54:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e57:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e5b:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104e62:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104e65:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e68:	89 d8                	mov    %ebx,%eax
f0104e6a:	e8 12 fe ff ff       	call   f0104c81 <stab_binsearch>

	if (lfun <= rfun) {
f0104e6f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e72:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104e75:	7f 23                	jg     f0104e9a <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e77:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e7a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e7d:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104e80:	8b 10                	mov    (%eax),%edx
f0104e82:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e85:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f0104e88:	39 ca                	cmp    %ecx,%edx
f0104e8a:	73 06                	jae    f0104e92 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e8c:	03 55 d0             	add    -0x30(%ebp),%edx
f0104e8f:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e92:	8b 40 08             	mov    0x8(%eax),%eax
f0104e95:	89 46 10             	mov    %eax,0x10(%esi)
f0104e98:	eb 06                	jmp    f0104ea0 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e9a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104e9d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ea0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104ea7:	00 
f0104ea8:	8b 46 08             	mov    0x8(%esi),%eax
f0104eab:	89 04 24             	mov    %eax,(%esp)
f0104eae:	e8 08 09 00 00       	call   f01057bb <strfind>
f0104eb3:	2b 46 08             	sub    0x8(%esi),%eax
f0104eb6:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104eb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ebc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ebf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104ec2:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104ec5:	eb 06                	jmp    f0104ecd <debuginfo_eip+0x14a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104ec7:	83 eb 01             	sub    $0x1,%ebx
f0104eca:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ecd:	39 fb                	cmp    %edi,%ebx
f0104ecf:	7c 2c                	jl     f0104efd <debuginfo_eip+0x17a>
	       && stabs[lline].n_type != N_SOL
f0104ed1:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104ed5:	80 fa 84             	cmp    $0x84,%dl
f0104ed8:	74 0b                	je     f0104ee5 <debuginfo_eip+0x162>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104eda:	80 fa 64             	cmp    $0x64,%dl
f0104edd:	75 e8                	jne    f0104ec7 <debuginfo_eip+0x144>
f0104edf:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104ee3:	74 e2                	je     f0104ec7 <debuginfo_eip+0x144>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ee5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ee8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104eeb:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0104eee:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104ef1:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0104ef4:	39 d0                	cmp    %edx,%eax
f0104ef6:	73 05                	jae    f0104efd <debuginfo_eip+0x17a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ef8:	03 45 d0             	add    -0x30(%ebp),%eax
f0104efb:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104efd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104f00:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f03:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f08:	39 cb                	cmp    %ecx,%ebx
f0104f0a:	7d 43                	jge    f0104f4f <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f0104f0c:	8d 53 01             	lea    0x1(%ebx),%edx
f0104f0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104f12:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104f15:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104f18:	eb 07                	jmp    f0104f21 <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f1a:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104f1e:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f21:	39 ca                	cmp    %ecx,%edx
f0104f23:	74 25                	je     f0104f4a <debuginfo_eip+0x1c7>
f0104f25:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f28:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104f2c:	74 ec                	je     f0104f1a <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f33:	eb 1a                	jmp    f0104f4f <debuginfo_eip+0x1cc>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f3a:	eb 13                	jmp    f0104f4f <debuginfo_eip+0x1cc>
f0104f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f41:	eb 0c                	jmp    f0104f4f <debuginfo_eip+0x1cc>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f48:	eb 05                	jmp    f0104f4f <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f4f:	83 c4 3c             	add    $0x3c,%esp
f0104f52:	5b                   	pop    %ebx
f0104f53:	5e                   	pop    %esi
f0104f54:	5f                   	pop    %edi
f0104f55:	5d                   	pop    %ebp
f0104f56:	c3                   	ret    
	...

f0104f60 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f60:	55                   	push   %ebp
f0104f61:	89 e5                	mov    %esp,%ebp
f0104f63:	57                   	push   %edi
f0104f64:	56                   	push   %esi
f0104f65:	53                   	push   %ebx
f0104f66:	83 ec 3c             	sub    $0x3c,%esp
f0104f69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f6c:	89 d7                	mov    %edx,%edi
f0104f6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f71:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f77:	89 c3                	mov    %eax,%ebx
f0104f79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104f7c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f7f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f82:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f87:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f8d:	39 d9                	cmp    %ebx,%ecx
f0104f8f:	72 05                	jb     f0104f96 <printnum+0x36>
f0104f91:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0104f94:	77 69                	ja     f0104fff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f96:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104f99:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104f9d:	83 ee 01             	sub    $0x1,%esi
f0104fa0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104fa4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fa8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104fac:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104fb0:	89 c3                	mov    %eax,%ebx
f0104fb2:	89 d6                	mov    %edx,%esi
f0104fb4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104fb7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104fba:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104fbe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fc5:	89 04 24             	mov    %eax,(%esp)
f0104fc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fcf:	e8 9c 12 00 00       	call   f0106270 <__udivdi3>
f0104fd4:	89 d9                	mov    %ebx,%ecx
f0104fd6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fda:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104fde:	89 04 24             	mov    %eax,(%esp)
f0104fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104fe5:	89 fa                	mov    %edi,%edx
f0104fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fea:	e8 71 ff ff ff       	call   f0104f60 <printnum>
f0104fef:	eb 1b                	jmp    f010500c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ff1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ff5:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ff8:	89 04 24             	mov    %eax,(%esp)
f0104ffb:	ff d3                	call   *%ebx
f0104ffd:	eb 03                	jmp    f0105002 <printnum+0xa2>
f0104fff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105002:	83 ee 01             	sub    $0x1,%esi
f0105005:	85 f6                	test   %esi,%esi
f0105007:	7f e8                	jg     f0104ff1 <printnum+0x91>
f0105009:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010500c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105010:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105014:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105017:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010501a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010501e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105022:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105025:	89 04 24             	mov    %eax,(%esp)
f0105028:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010502b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010502f:	e8 6c 13 00 00       	call   f01063a0 <__umoddi3>
f0105034:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105038:	0f be 80 d6 7b 10 f0 	movsbl -0xfef842a(%eax),%eax
f010503f:	89 04 24             	mov    %eax,(%esp)
f0105042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105045:	ff d0                	call   *%eax
}
f0105047:	83 c4 3c             	add    $0x3c,%esp
f010504a:	5b                   	pop    %ebx
f010504b:	5e                   	pop    %esi
f010504c:	5f                   	pop    %edi
f010504d:	5d                   	pop    %ebp
f010504e:	c3                   	ret    

f010504f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010504f:	55                   	push   %ebp
f0105050:	89 e5                	mov    %esp,%ebp
f0105052:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105055:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105059:	8b 10                	mov    (%eax),%edx
f010505b:	3b 50 04             	cmp    0x4(%eax),%edx
f010505e:	73 0a                	jae    f010506a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105060:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105063:	89 08                	mov    %ecx,(%eax)
f0105065:	8b 45 08             	mov    0x8(%ebp),%eax
f0105068:	88 02                	mov    %al,(%edx)
}
f010506a:	5d                   	pop    %ebp
f010506b:	c3                   	ret    

f010506c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010506c:	55                   	push   %ebp
f010506d:	89 e5                	mov    %esp,%ebp
f010506f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105072:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105075:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105079:	8b 45 10             	mov    0x10(%ebp),%eax
f010507c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105080:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105083:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105087:	8b 45 08             	mov    0x8(%ebp),%eax
f010508a:	89 04 24             	mov    %eax,(%esp)
f010508d:	e8 02 00 00 00       	call   f0105094 <vprintfmt>
	va_end(ap);
}
f0105092:	c9                   	leave  
f0105093:	c3                   	ret    

f0105094 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105094:	55                   	push   %ebp
f0105095:	89 e5                	mov    %esp,%ebp
f0105097:	57                   	push   %edi
f0105098:	56                   	push   %esi
f0105099:	53                   	push   %ebx
f010509a:	83 ec 3c             	sub    $0x3c,%esp
f010509d:	8b 75 08             	mov    0x8(%ebp),%esi
f01050a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050a3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01050a6:	eb 11                	jmp    f01050b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01050a8:	85 c0                	test   %eax,%eax
f01050aa:	0f 84 48 04 00 00    	je     f01054f8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01050b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050b4:	89 04 24             	mov    %eax,(%esp)
f01050b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01050b9:	83 c7 01             	add    $0x1,%edi
f01050bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050c0:	83 f8 25             	cmp    $0x25,%eax
f01050c3:	75 e3                	jne    f01050a8 <vprintfmt+0x14>
f01050c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01050c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01050d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01050d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01050de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01050e3:	eb 1f                	jmp    f0105104 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01050e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01050ec:	eb 16                	jmp    f0105104 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01050f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01050f5:	eb 0d                	jmp    f0105104 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01050f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01050fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105104:	8d 47 01             	lea    0x1(%edi),%eax
f0105107:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010510a:	0f b6 17             	movzbl (%edi),%edx
f010510d:	0f b6 c2             	movzbl %dl,%eax
f0105110:	83 ea 23             	sub    $0x23,%edx
f0105113:	80 fa 55             	cmp    $0x55,%dl
f0105116:	0f 87 bf 03 00 00    	ja     f01054db <vprintfmt+0x447>
f010511c:	0f b6 d2             	movzbl %dl,%edx
f010511f:	ff 24 95 a0 7c 10 f0 	jmp    *-0xfef8360(,%edx,4)
f0105126:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105129:	ba 00 00 00 00       	mov    $0x0,%edx
f010512e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105131:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105134:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105138:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010513b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010513e:	83 f9 09             	cmp    $0x9,%ecx
f0105141:	77 3c                	ja     f010517f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105143:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105146:	eb e9                	jmp    f0105131 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105148:	8b 45 14             	mov    0x14(%ebp),%eax
f010514b:	8b 00                	mov    (%eax),%eax
f010514d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105150:	8b 45 14             	mov    0x14(%ebp),%eax
f0105153:	8d 40 04             	lea    0x4(%eax),%eax
f0105156:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105159:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010515c:	eb 27                	jmp    f0105185 <vprintfmt+0xf1>
f010515e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105161:	85 d2                	test   %edx,%edx
f0105163:	b8 00 00 00 00       	mov    $0x0,%eax
f0105168:	0f 49 c2             	cmovns %edx,%eax
f010516b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010516e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105171:	eb 91                	jmp    f0105104 <vprintfmt+0x70>
f0105173:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105176:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010517d:	eb 85                	jmp    f0105104 <vprintfmt+0x70>
f010517f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105182:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105185:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105189:	0f 89 75 ff ff ff    	jns    f0105104 <vprintfmt+0x70>
f010518f:	e9 63 ff ff ff       	jmp    f01050f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105194:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105197:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010519a:	e9 65 ff ff ff       	jmp    f0105104 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01051a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01051a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051aa:	8b 00                	mov    (%eax),%eax
f01051ac:	89 04 24             	mov    %eax,(%esp)
f01051af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01051b4:	e9 00 ff ff ff       	jmp    f01050b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01051bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01051c0:	8b 00                	mov    (%eax),%eax
f01051c2:	99                   	cltd   
f01051c3:	31 d0                	xor    %edx,%eax
f01051c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01051c7:	83 f8 09             	cmp    $0x9,%eax
f01051ca:	7f 0b                	jg     f01051d7 <vprintfmt+0x143>
f01051cc:	8b 14 85 00 7e 10 f0 	mov    -0xfef8200(,%eax,4),%edx
f01051d3:	85 d2                	test   %edx,%edx
f01051d5:	75 20                	jne    f01051f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f01051d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01051db:	c7 44 24 08 ee 7b 10 	movl   $0xf0107bee,0x8(%esp)
f01051e2:	f0 
f01051e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051e7:	89 34 24             	mov    %esi,(%esp)
f01051ea:	e8 7d fe ff ff       	call   f010506c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01051f2:	e9 c2 fe ff ff       	jmp    f01050b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f01051f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01051fb:	c7 44 24 08 91 73 10 	movl   $0xf0107391,0x8(%esp)
f0105202:	f0 
f0105203:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105207:	89 34 24             	mov    %esi,(%esp)
f010520a:	e8 5d fe ff ff       	call   f010506c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010520f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105212:	e9 a2 fe ff ff       	jmp    f01050b9 <vprintfmt+0x25>
f0105217:	8b 45 14             	mov    0x14(%ebp),%eax
f010521a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010521d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105220:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105223:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105227:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105229:	85 ff                	test   %edi,%edi
f010522b:	b8 e7 7b 10 f0       	mov    $0xf0107be7,%eax
f0105230:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105233:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105237:	0f 84 92 00 00 00    	je     f01052cf <vprintfmt+0x23b>
f010523d:	85 c9                	test   %ecx,%ecx
f010523f:	0f 8e 98 00 00 00    	jle    f01052dd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105245:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105249:	89 3c 24             	mov    %edi,(%esp)
f010524c:	e8 17 04 00 00       	call   f0105668 <strnlen>
f0105251:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105254:	29 c1                	sub    %eax,%ecx
f0105256:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0105259:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010525d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105260:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105263:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105265:	eb 0f                	jmp    f0105276 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0105267:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010526b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010526e:	89 04 24             	mov    %eax,(%esp)
f0105271:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105273:	83 ef 01             	sub    $0x1,%edi
f0105276:	85 ff                	test   %edi,%edi
f0105278:	7f ed                	jg     f0105267 <vprintfmt+0x1d3>
f010527a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010527d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105280:	85 c9                	test   %ecx,%ecx
f0105282:	b8 00 00 00 00       	mov    $0x0,%eax
f0105287:	0f 49 c1             	cmovns %ecx,%eax
f010528a:	29 c1                	sub    %eax,%ecx
f010528c:	89 75 08             	mov    %esi,0x8(%ebp)
f010528f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105292:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105295:	89 cb                	mov    %ecx,%ebx
f0105297:	eb 50                	jmp    f01052e9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105299:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010529d:	74 1e                	je     f01052bd <vprintfmt+0x229>
f010529f:	0f be d2             	movsbl %dl,%edx
f01052a2:	83 ea 20             	sub    $0x20,%edx
f01052a5:	83 fa 5e             	cmp    $0x5e,%edx
f01052a8:	76 13                	jbe    f01052bd <vprintfmt+0x229>
					putch('?', putdat);
f01052aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01052b8:	ff 55 08             	call   *0x8(%ebp)
f01052bb:	eb 0d                	jmp    f01052ca <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01052bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01052c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01052c4:	89 04 24             	mov    %eax,(%esp)
f01052c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052ca:	83 eb 01             	sub    $0x1,%ebx
f01052cd:	eb 1a                	jmp    f01052e9 <vprintfmt+0x255>
f01052cf:	89 75 08             	mov    %esi,0x8(%ebp)
f01052d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052db:	eb 0c                	jmp    f01052e9 <vprintfmt+0x255>
f01052dd:	89 75 08             	mov    %esi,0x8(%ebp)
f01052e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052e9:	83 c7 01             	add    $0x1,%edi
f01052ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01052f0:	0f be c2             	movsbl %dl,%eax
f01052f3:	85 c0                	test   %eax,%eax
f01052f5:	74 25                	je     f010531c <vprintfmt+0x288>
f01052f7:	85 f6                	test   %esi,%esi
f01052f9:	78 9e                	js     f0105299 <vprintfmt+0x205>
f01052fb:	83 ee 01             	sub    $0x1,%esi
f01052fe:	79 99                	jns    f0105299 <vprintfmt+0x205>
f0105300:	89 df                	mov    %ebx,%edi
f0105302:	8b 75 08             	mov    0x8(%ebp),%esi
f0105305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105308:	eb 1a                	jmp    f0105324 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010530a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010530e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105315:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105317:	83 ef 01             	sub    $0x1,%edi
f010531a:	eb 08                	jmp    f0105324 <vprintfmt+0x290>
f010531c:	89 df                	mov    %ebx,%edi
f010531e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105324:	85 ff                	test   %edi,%edi
f0105326:	7f e2                	jg     f010530a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010532b:	e9 89 fd ff ff       	jmp    f01050b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105330:	83 f9 01             	cmp    $0x1,%ecx
f0105333:	7e 19                	jle    f010534e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0105335:	8b 45 14             	mov    0x14(%ebp),%eax
f0105338:	8b 50 04             	mov    0x4(%eax),%edx
f010533b:	8b 00                	mov    (%eax),%eax
f010533d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105340:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105343:	8b 45 14             	mov    0x14(%ebp),%eax
f0105346:	8d 40 08             	lea    0x8(%eax),%eax
f0105349:	89 45 14             	mov    %eax,0x14(%ebp)
f010534c:	eb 38                	jmp    f0105386 <vprintfmt+0x2f2>
	else if (lflag)
f010534e:	85 c9                	test   %ecx,%ecx
f0105350:	74 1b                	je     f010536d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0105352:	8b 45 14             	mov    0x14(%ebp),%eax
f0105355:	8b 00                	mov    (%eax),%eax
f0105357:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010535a:	89 c1                	mov    %eax,%ecx
f010535c:	c1 f9 1f             	sar    $0x1f,%ecx
f010535f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105362:	8b 45 14             	mov    0x14(%ebp),%eax
f0105365:	8d 40 04             	lea    0x4(%eax),%eax
f0105368:	89 45 14             	mov    %eax,0x14(%ebp)
f010536b:	eb 19                	jmp    f0105386 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010536d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105370:	8b 00                	mov    (%eax),%eax
f0105372:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105375:	89 c1                	mov    %eax,%ecx
f0105377:	c1 f9 1f             	sar    $0x1f,%ecx
f010537a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010537d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105380:	8d 40 04             	lea    0x4(%eax),%eax
f0105383:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105386:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105389:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010538c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105391:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105395:	0f 89 04 01 00 00    	jns    f010549f <vprintfmt+0x40b>
				putch('-', putdat);
f010539b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010539f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01053a6:	ff d6                	call   *%esi
				num = -(long long) num;
f01053a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01053ae:	f7 da                	neg    %edx
f01053b0:	83 d1 00             	adc    $0x0,%ecx
f01053b3:	f7 d9                	neg    %ecx
f01053b5:	e9 e5 00 00 00       	jmp    f010549f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01053ba:	83 f9 01             	cmp    $0x1,%ecx
f01053bd:	7e 10                	jle    f01053cf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01053bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c2:	8b 10                	mov    (%eax),%edx
f01053c4:	8b 48 04             	mov    0x4(%eax),%ecx
f01053c7:	8d 40 08             	lea    0x8(%eax),%eax
f01053ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01053cd:	eb 26                	jmp    f01053f5 <vprintfmt+0x361>
	else if (lflag)
f01053cf:	85 c9                	test   %ecx,%ecx
f01053d1:	74 12                	je     f01053e5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f01053d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01053d6:	8b 10                	mov    (%eax),%edx
f01053d8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053dd:	8d 40 04             	lea    0x4(%eax),%eax
f01053e0:	89 45 14             	mov    %eax,0x14(%ebp)
f01053e3:	eb 10                	jmp    f01053f5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f01053e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e8:	8b 10                	mov    (%eax),%edx
f01053ea:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053ef:	8d 40 04             	lea    0x4(%eax),%eax
f01053f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01053f5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f01053fa:	e9 a0 00 00 00       	jmp    f010549f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01053ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105403:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010540a:	ff d6                	call   *%esi
			putch('X', putdat);
f010540c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105410:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105417:	ff d6                	call   *%esi
			putch('X', putdat);
f0105419:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010541d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105424:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105429:	e9 8b fc ff ff       	jmp    f01050b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010542e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105432:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105439:	ff d6                	call   *%esi
			putch('x', putdat);
f010543b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010543f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105446:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105448:	8b 45 14             	mov    0x14(%ebp),%eax
f010544b:	8b 10                	mov    (%eax),%edx
f010544d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0105452:	8d 40 04             	lea    0x4(%eax),%eax
f0105455:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105458:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010545d:	eb 40                	jmp    f010549f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010545f:	83 f9 01             	cmp    $0x1,%ecx
f0105462:	7e 10                	jle    f0105474 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0105464:	8b 45 14             	mov    0x14(%ebp),%eax
f0105467:	8b 10                	mov    (%eax),%edx
f0105469:	8b 48 04             	mov    0x4(%eax),%ecx
f010546c:	8d 40 08             	lea    0x8(%eax),%eax
f010546f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105472:	eb 26                	jmp    f010549a <vprintfmt+0x406>
	else if (lflag)
f0105474:	85 c9                	test   %ecx,%ecx
f0105476:	74 12                	je     f010548a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0105478:	8b 45 14             	mov    0x14(%ebp),%eax
f010547b:	8b 10                	mov    (%eax),%edx
f010547d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105482:	8d 40 04             	lea    0x4(%eax),%eax
f0105485:	89 45 14             	mov    %eax,0x14(%ebp)
f0105488:	eb 10                	jmp    f010549a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f010548a:	8b 45 14             	mov    0x14(%ebp),%eax
f010548d:	8b 10                	mov    (%eax),%edx
f010548f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105494:	8d 40 04             	lea    0x4(%eax),%eax
f0105497:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010549a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010549f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01054a3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01054a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01054ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01054b2:	89 14 24             	mov    %edx,(%esp)
f01054b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01054b9:	89 da                	mov    %ebx,%edx
f01054bb:	89 f0                	mov    %esi,%eax
f01054bd:	e8 9e fa ff ff       	call   f0104f60 <printnum>
			break;
f01054c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054c5:	e9 ef fb ff ff       	jmp    f01050b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01054ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054ce:	89 04 24             	mov    %eax,(%esp)
f01054d1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01054d6:	e9 de fb ff ff       	jmp    f01050b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01054db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01054e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01054e8:	eb 03                	jmp    f01054ed <vprintfmt+0x459>
f01054ea:	83 ef 01             	sub    $0x1,%edi
f01054ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01054f1:	75 f7                	jne    f01054ea <vprintfmt+0x456>
f01054f3:	e9 c1 fb ff ff       	jmp    f01050b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01054f8:	83 c4 3c             	add    $0x3c,%esp
f01054fb:	5b                   	pop    %ebx
f01054fc:	5e                   	pop    %esi
f01054fd:	5f                   	pop    %edi
f01054fe:	5d                   	pop    %ebp
f01054ff:	c3                   	ret    

f0105500 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105500:	55                   	push   %ebp
f0105501:	89 e5                	mov    %esp,%ebp
f0105503:	83 ec 28             	sub    $0x28,%esp
f0105506:	8b 45 08             	mov    0x8(%ebp),%eax
f0105509:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010550c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010550f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105513:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010551d:	85 c0                	test   %eax,%eax
f010551f:	74 30                	je     f0105551 <vsnprintf+0x51>
f0105521:	85 d2                	test   %edx,%edx
f0105523:	7e 2c                	jle    f0105551 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105525:	8b 45 14             	mov    0x14(%ebp),%eax
f0105528:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010552c:	8b 45 10             	mov    0x10(%ebp),%eax
f010552f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105533:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105536:	89 44 24 04          	mov    %eax,0x4(%esp)
f010553a:	c7 04 24 4f 50 10 f0 	movl   $0xf010504f,(%esp)
f0105541:	e8 4e fb ff ff       	call   f0105094 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105546:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105549:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010554f:	eb 05                	jmp    f0105556 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105551:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105556:	c9                   	leave  
f0105557:	c3                   	ret    

f0105558 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105558:	55                   	push   %ebp
f0105559:	89 e5                	mov    %esp,%ebp
f010555b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010555e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105561:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105565:	8b 45 10             	mov    0x10(%ebp),%eax
f0105568:	89 44 24 08          	mov    %eax,0x8(%esp)
f010556c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010556f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105573:	8b 45 08             	mov    0x8(%ebp),%eax
f0105576:	89 04 24             	mov    %eax,(%esp)
f0105579:	e8 82 ff ff ff       	call   f0105500 <vsnprintf>
	va_end(ap);

	return rc;
}
f010557e:	c9                   	leave  
f010557f:	c3                   	ret    

f0105580 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105580:	55                   	push   %ebp
f0105581:	89 e5                	mov    %esp,%ebp
f0105583:	57                   	push   %edi
f0105584:	56                   	push   %esi
f0105585:	53                   	push   %ebx
f0105586:	83 ec 1c             	sub    $0x1c,%esp
f0105589:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010558c:	85 c0                	test   %eax,%eax
f010558e:	74 10                	je     f01055a0 <readline+0x20>
		cprintf("%s", prompt);
f0105590:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105594:	c7 04 24 91 73 10 f0 	movl   $0xf0107391,(%esp)
f010559b:	e8 06 ea ff ff       	call   f0103fa6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01055a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01055a7:	e8 2f b2 ff ff       	call   f01007db <iscons>
f01055ac:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01055ae:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01055b3:	e8 12 b2 ff ff       	call   f01007ca <getchar>
f01055b8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055ba:	85 c0                	test   %eax,%eax
f01055bc:	79 17                	jns    f01055d5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01055be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055c2:	c7 04 24 28 7e 10 f0 	movl   $0xf0107e28,(%esp)
f01055c9:	e8 d8 e9 ff ff       	call   f0103fa6 <cprintf>
			return NULL;
f01055ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d3:	eb 6d                	jmp    f0105642 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01055d5:	83 f8 7f             	cmp    $0x7f,%eax
f01055d8:	74 05                	je     f01055df <readline+0x5f>
f01055da:	83 f8 08             	cmp    $0x8,%eax
f01055dd:	75 19                	jne    f01055f8 <readline+0x78>
f01055df:	85 f6                	test   %esi,%esi
f01055e1:	7e 15                	jle    f01055f8 <readline+0x78>
			if (echoing)
f01055e3:	85 ff                	test   %edi,%edi
f01055e5:	74 0c                	je     f01055f3 <readline+0x73>
				cputchar('\b');
f01055e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01055ee:	e8 c7 b1 ff ff       	call   f01007ba <cputchar>
			i--;
f01055f3:	83 ee 01             	sub    $0x1,%esi
f01055f6:	eb bb                	jmp    f01055b3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055f8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055fe:	7f 1c                	jg     f010561c <readline+0x9c>
f0105600:	83 fb 1f             	cmp    $0x1f,%ebx
f0105603:	7e 17                	jle    f010561c <readline+0x9c>
			if (echoing)
f0105605:	85 ff                	test   %edi,%edi
f0105607:	74 08                	je     f0105611 <readline+0x91>
				cputchar(c);
f0105609:	89 1c 24             	mov    %ebx,(%esp)
f010560c:	e8 a9 b1 ff ff       	call   f01007ba <cputchar>
			buf[i++] = c;
f0105611:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f0105617:	8d 76 01             	lea    0x1(%esi),%esi
f010561a:	eb 97                	jmp    f01055b3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010561c:	83 fb 0d             	cmp    $0xd,%ebx
f010561f:	74 05                	je     f0105626 <readline+0xa6>
f0105621:	83 fb 0a             	cmp    $0xa,%ebx
f0105624:	75 8d                	jne    f01055b3 <readline+0x33>
			if (echoing)
f0105626:	85 ff                	test   %edi,%edi
f0105628:	74 0c                	je     f0105636 <readline+0xb6>
				cputchar('\n');
f010562a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105631:	e8 84 b1 ff ff       	call   f01007ba <cputchar>
			buf[i] = 0;
f0105636:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f010563d:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f0105642:	83 c4 1c             	add    $0x1c,%esp
f0105645:	5b                   	pop    %ebx
f0105646:	5e                   	pop    %esi
f0105647:	5f                   	pop    %edi
f0105648:	5d                   	pop    %ebp
f0105649:	c3                   	ret    
f010564a:	00 00                	add    %al,(%eax)
f010564c:	00 00                	add    %al,(%eax)
	...

f0105650 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105650:	55                   	push   %ebp
f0105651:	89 e5                	mov    %esp,%ebp
f0105653:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105656:	b8 00 00 00 00       	mov    $0x0,%eax
f010565b:	eb 03                	jmp    f0105660 <strlen+0x10>
		n++;
f010565d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105660:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105664:	75 f7                	jne    f010565d <strlen+0xd>
		n++;
	return n;
}
f0105666:	5d                   	pop    %ebp
f0105667:	c3                   	ret    

f0105668 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105668:	55                   	push   %ebp
f0105669:	89 e5                	mov    %esp,%ebp
f010566b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010566e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105671:	b8 00 00 00 00       	mov    $0x0,%eax
f0105676:	eb 03                	jmp    f010567b <strnlen+0x13>
		n++;
f0105678:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010567b:	39 d0                	cmp    %edx,%eax
f010567d:	74 06                	je     f0105685 <strnlen+0x1d>
f010567f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105683:	75 f3                	jne    f0105678 <strnlen+0x10>
		n++;
	return n;
}
f0105685:	5d                   	pop    %ebp
f0105686:	c3                   	ret    

f0105687 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105687:	55                   	push   %ebp
f0105688:	89 e5                	mov    %esp,%ebp
f010568a:	53                   	push   %ebx
f010568b:	8b 45 08             	mov    0x8(%ebp),%eax
f010568e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105691:	89 c2                	mov    %eax,%edx
f0105693:	83 c2 01             	add    $0x1,%edx
f0105696:	83 c1 01             	add    $0x1,%ecx
f0105699:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010569d:	88 5a ff             	mov    %bl,-0x1(%edx)
f01056a0:	84 db                	test   %bl,%bl
f01056a2:	75 ef                	jne    f0105693 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01056a4:	5b                   	pop    %ebx
f01056a5:	5d                   	pop    %ebp
f01056a6:	c3                   	ret    

f01056a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056a7:	55                   	push   %ebp
f01056a8:	89 e5                	mov    %esp,%ebp
f01056aa:	53                   	push   %ebx
f01056ab:	83 ec 08             	sub    $0x8,%esp
f01056ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056b1:	89 1c 24             	mov    %ebx,(%esp)
f01056b4:	e8 97 ff ff ff       	call   f0105650 <strlen>
	strcpy(dst + len, src);
f01056b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056c0:	01 d8                	add    %ebx,%eax
f01056c2:	89 04 24             	mov    %eax,(%esp)
f01056c5:	e8 bd ff ff ff       	call   f0105687 <strcpy>
	return dst;
}
f01056ca:	89 d8                	mov    %ebx,%eax
f01056cc:	83 c4 08             	add    $0x8,%esp
f01056cf:	5b                   	pop    %ebx
f01056d0:	5d                   	pop    %ebp
f01056d1:	c3                   	ret    

f01056d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01056d2:	55                   	push   %ebp
f01056d3:	89 e5                	mov    %esp,%ebp
f01056d5:	56                   	push   %esi
f01056d6:	53                   	push   %ebx
f01056d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01056da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056dd:	89 f3                	mov    %esi,%ebx
f01056df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056e2:	89 f2                	mov    %esi,%edx
f01056e4:	eb 0f                	jmp    f01056f5 <strncpy+0x23>
		*dst++ = *src;
f01056e6:	83 c2 01             	add    $0x1,%edx
f01056e9:	0f b6 01             	movzbl (%ecx),%eax
f01056ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01056ef:	80 39 01             	cmpb   $0x1,(%ecx)
f01056f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01056f5:	39 da                	cmp    %ebx,%edx
f01056f7:	75 ed                	jne    f01056e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01056f9:	89 f0                	mov    %esi,%eax
f01056fb:	5b                   	pop    %ebx
f01056fc:	5e                   	pop    %esi
f01056fd:	5d                   	pop    %ebp
f01056fe:	c3                   	ret    

f01056ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01056ff:	55                   	push   %ebp
f0105700:	89 e5                	mov    %esp,%ebp
f0105702:	56                   	push   %esi
f0105703:	53                   	push   %ebx
f0105704:	8b 75 08             	mov    0x8(%ebp),%esi
f0105707:	8b 55 0c             	mov    0xc(%ebp),%edx
f010570a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010570d:	89 f0                	mov    %esi,%eax
f010570f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105713:	85 c9                	test   %ecx,%ecx
f0105715:	75 0b                	jne    f0105722 <strlcpy+0x23>
f0105717:	eb 1d                	jmp    f0105736 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105719:	83 c0 01             	add    $0x1,%eax
f010571c:	83 c2 01             	add    $0x1,%edx
f010571f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105722:	39 d8                	cmp    %ebx,%eax
f0105724:	74 0b                	je     f0105731 <strlcpy+0x32>
f0105726:	0f b6 0a             	movzbl (%edx),%ecx
f0105729:	84 c9                	test   %cl,%cl
f010572b:	75 ec                	jne    f0105719 <strlcpy+0x1a>
f010572d:	89 c2                	mov    %eax,%edx
f010572f:	eb 02                	jmp    f0105733 <strlcpy+0x34>
f0105731:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105733:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105736:	29 f0                	sub    %esi,%eax
}
f0105738:	5b                   	pop    %ebx
f0105739:	5e                   	pop    %esi
f010573a:	5d                   	pop    %ebp
f010573b:	c3                   	ret    

f010573c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010573c:	55                   	push   %ebp
f010573d:	89 e5                	mov    %esp,%ebp
f010573f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105742:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105745:	eb 06                	jmp    f010574d <strcmp+0x11>
		p++, q++;
f0105747:	83 c1 01             	add    $0x1,%ecx
f010574a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010574d:	0f b6 01             	movzbl (%ecx),%eax
f0105750:	84 c0                	test   %al,%al
f0105752:	74 04                	je     f0105758 <strcmp+0x1c>
f0105754:	3a 02                	cmp    (%edx),%al
f0105756:	74 ef                	je     f0105747 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105758:	0f b6 c0             	movzbl %al,%eax
f010575b:	0f b6 12             	movzbl (%edx),%edx
f010575e:	29 d0                	sub    %edx,%eax
}
f0105760:	5d                   	pop    %ebp
f0105761:	c3                   	ret    

f0105762 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105762:	55                   	push   %ebp
f0105763:	89 e5                	mov    %esp,%ebp
f0105765:	53                   	push   %ebx
f0105766:	8b 45 08             	mov    0x8(%ebp),%eax
f0105769:	8b 55 0c             	mov    0xc(%ebp),%edx
f010576c:	89 c3                	mov    %eax,%ebx
f010576e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105771:	eb 06                	jmp    f0105779 <strncmp+0x17>
		n--, p++, q++;
f0105773:	83 c0 01             	add    $0x1,%eax
f0105776:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105779:	39 d8                	cmp    %ebx,%eax
f010577b:	74 15                	je     f0105792 <strncmp+0x30>
f010577d:	0f b6 08             	movzbl (%eax),%ecx
f0105780:	84 c9                	test   %cl,%cl
f0105782:	74 04                	je     f0105788 <strncmp+0x26>
f0105784:	3a 0a                	cmp    (%edx),%cl
f0105786:	74 eb                	je     f0105773 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105788:	0f b6 00             	movzbl (%eax),%eax
f010578b:	0f b6 12             	movzbl (%edx),%edx
f010578e:	29 d0                	sub    %edx,%eax
f0105790:	eb 05                	jmp    f0105797 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105792:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105797:	5b                   	pop    %ebx
f0105798:	5d                   	pop    %ebp
f0105799:	c3                   	ret    

f010579a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010579a:	55                   	push   %ebp
f010579b:	89 e5                	mov    %esp,%ebp
f010579d:	8b 45 08             	mov    0x8(%ebp),%eax
f01057a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057a4:	eb 07                	jmp    f01057ad <strchr+0x13>
		if (*s == c)
f01057a6:	38 ca                	cmp    %cl,%dl
f01057a8:	74 0f                	je     f01057b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01057aa:	83 c0 01             	add    $0x1,%eax
f01057ad:	0f b6 10             	movzbl (%eax),%edx
f01057b0:	84 d2                	test   %dl,%dl
f01057b2:	75 f2                	jne    f01057a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01057b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057b9:	5d                   	pop    %ebp
f01057ba:	c3                   	ret    

f01057bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01057bb:	55                   	push   %ebp
f01057bc:	89 e5                	mov    %esp,%ebp
f01057be:	8b 45 08             	mov    0x8(%ebp),%eax
f01057c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01057c5:	eb 07                	jmp    f01057ce <strfind+0x13>
		if (*s == c)
f01057c7:	38 ca                	cmp    %cl,%dl
f01057c9:	74 0a                	je     f01057d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01057cb:	83 c0 01             	add    $0x1,%eax
f01057ce:	0f b6 10             	movzbl (%eax),%edx
f01057d1:	84 d2                	test   %dl,%dl
f01057d3:	75 f2                	jne    f01057c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01057d5:	5d                   	pop    %ebp
f01057d6:	c3                   	ret    

f01057d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01057d7:	55                   	push   %ebp
f01057d8:	89 e5                	mov    %esp,%ebp
f01057da:	57                   	push   %edi
f01057db:	56                   	push   %esi
f01057dc:	53                   	push   %ebx
f01057dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057e3:	85 c9                	test   %ecx,%ecx
f01057e5:	74 36                	je     f010581d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057ed:	75 28                	jne    f0105817 <memset+0x40>
f01057ef:	f6 c1 03             	test   $0x3,%cl
f01057f2:	75 23                	jne    f0105817 <memset+0x40>
		c &= 0xFF;
f01057f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057f8:	89 d3                	mov    %edx,%ebx
f01057fa:	c1 e3 08             	shl    $0x8,%ebx
f01057fd:	89 d6                	mov    %edx,%esi
f01057ff:	c1 e6 18             	shl    $0x18,%esi
f0105802:	89 d0                	mov    %edx,%eax
f0105804:	c1 e0 10             	shl    $0x10,%eax
f0105807:	09 f0                	or     %esi,%eax
f0105809:	09 c2                	or     %eax,%edx
f010580b:	89 d0                	mov    %edx,%eax
f010580d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010580f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105812:	fc                   	cld    
f0105813:	f3 ab                	rep stos %eax,%es:(%edi)
f0105815:	eb 06                	jmp    f010581d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105817:	8b 45 0c             	mov    0xc(%ebp),%eax
f010581a:	fc                   	cld    
f010581b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010581d:	89 f8                	mov    %edi,%eax
f010581f:	5b                   	pop    %ebx
f0105820:	5e                   	pop    %esi
f0105821:	5f                   	pop    %edi
f0105822:	5d                   	pop    %ebp
f0105823:	c3                   	ret    

f0105824 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105824:	55                   	push   %ebp
f0105825:	89 e5                	mov    %esp,%ebp
f0105827:	57                   	push   %edi
f0105828:	56                   	push   %esi
f0105829:	8b 45 08             	mov    0x8(%ebp),%eax
f010582c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010582f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105832:	39 c6                	cmp    %eax,%esi
f0105834:	73 35                	jae    f010586b <memmove+0x47>
f0105836:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105839:	39 d0                	cmp    %edx,%eax
f010583b:	73 2e                	jae    f010586b <memmove+0x47>
		s += n;
		d += n;
f010583d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105840:	89 d6                	mov    %edx,%esi
f0105842:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105844:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010584a:	75 13                	jne    f010585f <memmove+0x3b>
f010584c:	f6 c1 03             	test   $0x3,%cl
f010584f:	75 0e                	jne    f010585f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105851:	83 ef 04             	sub    $0x4,%edi
f0105854:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105857:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010585a:	fd                   	std    
f010585b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010585d:	eb 09                	jmp    f0105868 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010585f:	83 ef 01             	sub    $0x1,%edi
f0105862:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105865:	fd                   	std    
f0105866:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105868:	fc                   	cld    
f0105869:	eb 1d                	jmp    f0105888 <memmove+0x64>
f010586b:	89 f2                	mov    %esi,%edx
f010586d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010586f:	f6 c2 03             	test   $0x3,%dl
f0105872:	75 0f                	jne    f0105883 <memmove+0x5f>
f0105874:	f6 c1 03             	test   $0x3,%cl
f0105877:	75 0a                	jne    f0105883 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105879:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010587c:	89 c7                	mov    %eax,%edi
f010587e:	fc                   	cld    
f010587f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105881:	eb 05                	jmp    f0105888 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105883:	89 c7                	mov    %eax,%edi
f0105885:	fc                   	cld    
f0105886:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105888:	5e                   	pop    %esi
f0105889:	5f                   	pop    %edi
f010588a:	5d                   	pop    %ebp
f010588b:	c3                   	ret    

f010588c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010588c:	55                   	push   %ebp
f010588d:	89 e5                	mov    %esp,%ebp
f010588f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105892:	8b 45 10             	mov    0x10(%ebp),%eax
f0105895:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105899:	8b 45 0c             	mov    0xc(%ebp),%eax
f010589c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a3:	89 04 24             	mov    %eax,(%esp)
f01058a6:	e8 79 ff ff ff       	call   f0105824 <memmove>
}
f01058ab:	c9                   	leave  
f01058ac:	c3                   	ret    

f01058ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01058ad:	55                   	push   %ebp
f01058ae:	89 e5                	mov    %esp,%ebp
f01058b0:	56                   	push   %esi
f01058b1:	53                   	push   %ebx
f01058b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01058b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01058b8:	89 d6                	mov    %edx,%esi
f01058ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058bd:	eb 1a                	jmp    f01058d9 <memcmp+0x2c>
		if (*s1 != *s2)
f01058bf:	0f b6 02             	movzbl (%edx),%eax
f01058c2:	0f b6 19             	movzbl (%ecx),%ebx
f01058c5:	38 d8                	cmp    %bl,%al
f01058c7:	74 0a                	je     f01058d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01058c9:	0f b6 c0             	movzbl %al,%eax
f01058cc:	0f b6 db             	movzbl %bl,%ebx
f01058cf:	29 d8                	sub    %ebx,%eax
f01058d1:	eb 0f                	jmp    f01058e2 <memcmp+0x35>
		s1++, s2++;
f01058d3:	83 c2 01             	add    $0x1,%edx
f01058d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058d9:	39 f2                	cmp    %esi,%edx
f01058db:	75 e2                	jne    f01058bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01058dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058e2:	5b                   	pop    %ebx
f01058e3:	5e                   	pop    %esi
f01058e4:	5d                   	pop    %ebp
f01058e5:	c3                   	ret    

f01058e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058e6:	55                   	push   %ebp
f01058e7:	89 e5                	mov    %esp,%ebp
f01058e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01058ef:	89 c2                	mov    %eax,%edx
f01058f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058f4:	eb 07                	jmp    f01058fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058f6:	38 08                	cmp    %cl,(%eax)
f01058f8:	74 07                	je     f0105901 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058fa:	83 c0 01             	add    $0x1,%eax
f01058fd:	39 d0                	cmp    %edx,%eax
f01058ff:	72 f5                	jb     f01058f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105901:	5d                   	pop    %ebp
f0105902:	c3                   	ret    

f0105903 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105903:	55                   	push   %ebp
f0105904:	89 e5                	mov    %esp,%ebp
f0105906:	57                   	push   %edi
f0105907:	56                   	push   %esi
f0105908:	53                   	push   %ebx
f0105909:	8b 55 08             	mov    0x8(%ebp),%edx
f010590c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010590f:	eb 03                	jmp    f0105914 <strtol+0x11>
		s++;
f0105911:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105914:	0f b6 0a             	movzbl (%edx),%ecx
f0105917:	80 f9 09             	cmp    $0x9,%cl
f010591a:	74 f5                	je     f0105911 <strtol+0xe>
f010591c:	80 f9 20             	cmp    $0x20,%cl
f010591f:	74 f0                	je     f0105911 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105921:	80 f9 2b             	cmp    $0x2b,%cl
f0105924:	75 0a                	jne    f0105930 <strtol+0x2d>
		s++;
f0105926:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105929:	bf 00 00 00 00       	mov    $0x0,%edi
f010592e:	eb 11                	jmp    f0105941 <strtol+0x3e>
f0105930:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105935:	80 f9 2d             	cmp    $0x2d,%cl
f0105938:	75 07                	jne    f0105941 <strtol+0x3e>
		s++, neg = 1;
f010593a:	8d 52 01             	lea    0x1(%edx),%edx
f010593d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105941:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105946:	75 15                	jne    f010595d <strtol+0x5a>
f0105948:	80 3a 30             	cmpb   $0x30,(%edx)
f010594b:	75 10                	jne    f010595d <strtol+0x5a>
f010594d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105951:	75 0a                	jne    f010595d <strtol+0x5a>
		s += 2, base = 16;
f0105953:	83 c2 02             	add    $0x2,%edx
f0105956:	b8 10 00 00 00       	mov    $0x10,%eax
f010595b:	eb 10                	jmp    f010596d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010595d:	85 c0                	test   %eax,%eax
f010595f:	75 0c                	jne    f010596d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105961:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105963:	80 3a 30             	cmpb   $0x30,(%edx)
f0105966:	75 05                	jne    f010596d <strtol+0x6a>
		s++, base = 8;
f0105968:	83 c2 01             	add    $0x1,%edx
f010596b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010596d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105972:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105975:	0f b6 0a             	movzbl (%edx),%ecx
f0105978:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010597b:	89 f0                	mov    %esi,%eax
f010597d:	3c 09                	cmp    $0x9,%al
f010597f:	77 08                	ja     f0105989 <strtol+0x86>
			dig = *s - '0';
f0105981:	0f be c9             	movsbl %cl,%ecx
f0105984:	83 e9 30             	sub    $0x30,%ecx
f0105987:	eb 20                	jmp    f01059a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105989:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010598c:	89 f0                	mov    %esi,%eax
f010598e:	3c 19                	cmp    $0x19,%al
f0105990:	77 08                	ja     f010599a <strtol+0x97>
			dig = *s - 'a' + 10;
f0105992:	0f be c9             	movsbl %cl,%ecx
f0105995:	83 e9 57             	sub    $0x57,%ecx
f0105998:	eb 0f                	jmp    f01059a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010599a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010599d:	89 f0                	mov    %esi,%eax
f010599f:	3c 19                	cmp    $0x19,%al
f01059a1:	77 16                	ja     f01059b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01059a3:	0f be c9             	movsbl %cl,%ecx
f01059a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01059a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01059ac:	7d 0f                	jge    f01059bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01059ae:	83 c2 01             	add    $0x1,%edx
f01059b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01059b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01059b7:	eb bc                	jmp    f0105975 <strtol+0x72>
f01059b9:	89 d8                	mov    %ebx,%eax
f01059bb:	eb 02                	jmp    f01059bf <strtol+0xbc>
f01059bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01059bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059c3:	74 05                	je     f01059ca <strtol+0xc7>
		*endptr = (char *) s;
f01059c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01059c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01059ca:	f7 d8                	neg    %eax
f01059cc:	85 ff                	test   %edi,%edi
f01059ce:	0f 44 c3             	cmove  %ebx,%eax
}
f01059d1:	5b                   	pop    %ebx
f01059d2:	5e                   	pop    %esi
f01059d3:	5f                   	pop    %edi
f01059d4:	5d                   	pop    %ebp
f01059d5:	c3                   	ret    
	...

f01059d8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059d8:	fa                   	cli    

	xorw    %ax, %ax
f01059d9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059db:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059dd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059df:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059e1:	0f 01 16             	lgdtl  (%esi)
f01059e4:	74 70                	je     f0105a56 <mpentry_end+0x4>
	movl    %cr0, %eax
f01059e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059e9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01059ed:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059f0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059f6:	08 00                	or     %al,(%eax)

f01059f8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059f8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059fc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059fe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a00:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a02:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a06:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a08:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a0a:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105a0f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a12:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a15:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a1a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a1d:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a23:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a28:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0105a2d:	ff d0                	call   *%eax

f0105a2f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a2f:	eb fe                	jmp    f0105a2f <spin>
f0105a31:	8d 76 00             	lea    0x0(%esi),%esi

f0105a34 <gdt>:
	...
f0105a3c:	ff                   	(bad)  
f0105a3d:	ff 00                	incl   (%eax)
f0105a3f:	00 00                	add    %al,(%eax)
f0105a41:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a48:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105a4c <gdtdesc>:
f0105a4c:	17                   	pop    %ss
f0105a4d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a52 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a52:	90                   	nop
	...

f0105a60 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a60:	55                   	push   %ebp
f0105a61:	89 e5                	mov    %esp,%ebp
f0105a63:	56                   	push   %esi
f0105a64:	53                   	push   %ebx
f0105a65:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a68:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0105a6e:	89 c3                	mov    %eax,%ebx
f0105a70:	c1 eb 0c             	shr    $0xc,%ebx
f0105a73:	39 cb                	cmp    %ecx,%ebx
f0105a75:	72 20                	jb     f0105a97 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a7b:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0105a82:	f0 
f0105a83:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105a8a:	00 
f0105a8b:	c7 04 24 c5 7f 10 f0 	movl   $0xf0107fc5,(%esp)
f0105a92:	e8 a9 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105a97:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a9d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a9f:	89 c2                	mov    %eax,%edx
f0105aa1:	c1 ea 0c             	shr    $0xc,%edx
f0105aa4:	39 d1                	cmp    %edx,%ecx
f0105aa6:	77 20                	ja     f0105ac8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105aac:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0105ab3:	f0 
f0105ab4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105abb:	00 
f0105abc:	c7 04 24 c5 7f 10 f0 	movl   $0xf0107fc5,(%esp)
f0105ac3:	e8 78 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ac8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105ace:	eb 36                	jmp    f0105b06 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ad0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105ad7:	00 
f0105ad8:	c7 44 24 04 d5 7f 10 	movl   $0xf0107fd5,0x4(%esp)
f0105adf:	f0 
f0105ae0:	89 1c 24             	mov    %ebx,(%esp)
f0105ae3:	e8 c5 fd ff ff       	call   f01058ad <memcmp>
f0105ae8:	85 c0                	test   %eax,%eax
f0105aea:	75 17                	jne    f0105b03 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aec:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0105af1:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105af5:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105af7:	83 c2 01             	add    $0x1,%edx
f0105afa:	83 fa 10             	cmp    $0x10,%edx
f0105afd:	75 f2                	jne    f0105af1 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105aff:	84 c0                	test   %al,%al
f0105b01:	74 0e                	je     f0105b11 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105b03:	83 c3 10             	add    $0x10,%ebx
f0105b06:	39 f3                	cmp    %esi,%ebx
f0105b08:	72 c6                	jb     f0105ad0 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105b0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b0f:	eb 02                	jmp    f0105b13 <mpsearch1+0xb3>
f0105b11:	89 d8                	mov    %ebx,%eax
}
f0105b13:	83 c4 10             	add    $0x10,%esp
f0105b16:	5b                   	pop    %ebx
f0105b17:	5e                   	pop    %esi
f0105b18:	5d                   	pop    %ebp
f0105b19:	c3                   	ret    

f0105b1a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b1a:	55                   	push   %ebp
f0105b1b:	89 e5                	mov    %esp,%ebp
f0105b1d:	57                   	push   %edi
f0105b1e:	56                   	push   %esi
f0105b1f:	53                   	push   %ebx
f0105b20:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b23:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f0105b2a:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b2d:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105b34:	75 24                	jne    f0105b5a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b36:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0105b3d:	00 
f0105b3e:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0105b45:	f0 
f0105b46:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0105b4d:	00 
f0105b4e:	c7 04 24 c5 7f 10 f0 	movl   $0xf0107fc5,(%esp)
f0105b55:	e8 e6 a4 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b5a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b61:	85 c0                	test   %eax,%eax
f0105b63:	74 16                	je     f0105b7b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0105b65:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b68:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b6d:	e8 ee fe ff ff       	call   f0105a60 <mpsearch1>
f0105b72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b75:	85 c0                	test   %eax,%eax
f0105b77:	75 3c                	jne    f0105bb5 <mp_init+0x9b>
f0105b79:	eb 20                	jmp    f0105b9b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105b7b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b82:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b85:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b8a:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b8f:	e8 cc fe ff ff       	call   f0105a60 <mpsearch1>
f0105b94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b97:	85 c0                	test   %eax,%eax
f0105b99:	75 1a                	jne    f0105bb5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b9b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ba0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ba5:	e8 b6 fe ff ff       	call   f0105a60 <mpsearch1>
f0105baa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105bad:	85 c0                	test   %eax,%eax
f0105baf:	0f 84 54 02 00 00    	je     f0105e09 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105bb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bb8:	8b 70 04             	mov    0x4(%eax),%esi
f0105bbb:	85 f6                	test   %esi,%esi
f0105bbd:	74 06                	je     f0105bc5 <mp_init+0xab>
f0105bbf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105bc3:	74 11                	je     f0105bd6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0105bc5:	c7 04 24 38 7e 10 f0 	movl   $0xf0107e38,(%esp)
f0105bcc:	e8 d5 e3 ff ff       	call   f0103fa6 <cprintf>
f0105bd1:	e9 33 02 00 00       	jmp    f0105e09 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105bd6:	89 f0                	mov    %esi,%eax
f0105bd8:	c1 e8 0c             	shr    $0xc,%eax
f0105bdb:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0105be1:	72 20                	jb     f0105c03 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105be3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105be7:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0105bee:	f0 
f0105bef:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0105bf6:	00 
f0105bf7:	c7 04 24 c5 7f 10 f0 	movl   $0xf0107fc5,(%esp)
f0105bfe:	e8 3d a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105c03:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c09:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105c10:	00 
f0105c11:	c7 44 24 04 da 7f 10 	movl   $0xf0107fda,0x4(%esp)
f0105c18:	f0 
f0105c19:	89 1c 24             	mov    %ebx,(%esp)
f0105c1c:	e8 8c fc ff ff       	call   f01058ad <memcmp>
f0105c21:	85 c0                	test   %eax,%eax
f0105c23:	74 11                	je     f0105c36 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c25:	c7 04 24 68 7e 10 f0 	movl   $0xf0107e68,(%esp)
f0105c2c:	e8 75 e3 ff ff       	call   f0103fa6 <cprintf>
f0105c31:	e9 d3 01 00 00       	jmp    f0105e09 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c36:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105c3a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105c3e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105c41:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105c46:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c4b:	eb 0d                	jmp    f0105c5a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f0105c4d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105c54:	f0 
f0105c55:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105c57:	83 c0 01             	add    $0x1,%eax
f0105c5a:	39 c7                	cmp    %eax,%edi
f0105c5c:	7f ef                	jg     f0105c4d <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c5e:	84 d2                	test   %dl,%dl
f0105c60:	74 11                	je     f0105c73 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c62:	c7 04 24 9c 7e 10 f0 	movl   $0xf0107e9c,(%esp)
f0105c69:	e8 38 e3 ff ff       	call   f0103fa6 <cprintf>
f0105c6e:	e9 96 01 00 00       	jmp    f0105e09 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c73:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c77:	3c 04                	cmp    $0x4,%al
f0105c79:	74 1f                	je     f0105c9a <mp_init+0x180>
f0105c7b:	3c 01                	cmp    $0x1,%al
f0105c7d:	8d 76 00             	lea    0x0(%esi),%esi
f0105c80:	74 18                	je     f0105c9a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c82:	0f b6 c0             	movzbl %al,%eax
f0105c85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c89:	c7 04 24 c0 7e 10 f0 	movl   $0xf0107ec0,(%esp)
f0105c90:	e8 11 e3 ff ff       	call   f0103fa6 <cprintf>
f0105c95:	e9 6f 01 00 00       	jmp    f0105e09 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c9a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f0105c9e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0105ca2:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ca4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cae:	eb 09                	jmp    f0105cb9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0105cb0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0105cb4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105cb6:	83 c0 01             	add    $0x1,%eax
f0105cb9:	39 c6                	cmp    %eax,%esi
f0105cbb:	7f f3                	jg     f0105cb0 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105cbd:	02 53 2a             	add    0x2a(%ebx),%dl
f0105cc0:	84 d2                	test   %dl,%dl
f0105cc2:	74 11                	je     f0105cd5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105cc4:	c7 04 24 e0 7e 10 f0 	movl   $0xf0107ee0,(%esp)
f0105ccb:	e8 d6 e2 ff ff       	call   f0103fa6 <cprintf>
f0105cd0:	e9 34 01 00 00       	jmp    f0105e09 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105cd5:	85 db                	test   %ebx,%ebx
f0105cd7:	0f 84 2c 01 00 00    	je     f0105e09 <mp_init+0x2ef>
		return;
	ismp = 1;
f0105cdd:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f0105ce4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ce7:	8b 43 24             	mov    0x24(%ebx),%eax
f0105cea:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cef:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105cf2:	be 00 00 00 00       	mov    $0x0,%esi
f0105cf7:	e9 86 00 00 00       	jmp    f0105d82 <mp_init+0x268>
		switch (*p) {
f0105cfc:	0f b6 07             	movzbl (%edi),%eax
f0105cff:	84 c0                	test   %al,%al
f0105d01:	74 06                	je     f0105d09 <mp_init+0x1ef>
f0105d03:	3c 04                	cmp    $0x4,%al
f0105d05:	77 57                	ja     f0105d5e <mp_init+0x244>
f0105d07:	eb 50                	jmp    f0105d59 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105d09:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105d0d:	8d 76 00             	lea    0x0(%esi),%esi
f0105d10:	74 11                	je     f0105d23 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0105d12:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0105d19:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105d1e:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f0105d23:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f0105d28:	83 f8 07             	cmp    $0x7,%eax
f0105d2b:	7f 13                	jg     f0105d40 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0105d2d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d30:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0105d36:	83 c0 01             	add    $0x1,%eax
f0105d39:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f0105d3e:	eb 14                	jmp    f0105d54 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d40:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105d44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d48:	c7 04 24 10 7f 10 f0 	movl   $0xf0107f10,(%esp)
f0105d4f:	e8 52 e2 ff ff       	call   f0103fa6 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d54:	83 c7 14             	add    $0x14,%edi
			continue;
f0105d57:	eb 26                	jmp    f0105d7f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d59:	83 c7 08             	add    $0x8,%edi
			continue;
f0105d5c:	eb 21                	jmp    f0105d7f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d5e:	0f b6 c0             	movzbl %al,%eax
f0105d61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d65:	c7 04 24 38 7f 10 f0 	movl   $0xf0107f38,(%esp)
f0105d6c:	e8 35 e2 ff ff       	call   f0103fa6 <cprintf>
			ismp = 0;
f0105d71:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f0105d78:	00 00 00 
			i = conf->entry;
f0105d7b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d7f:	83 c6 01             	add    $0x1,%esi
f0105d82:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105d86:	39 c6                	cmp    %eax,%esi
f0105d88:	0f 82 6e ff ff ff    	jb     f0105cfc <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d8e:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f0105d93:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d9a:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0105da1:	75 22                	jne    f0105dc5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105da3:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0105daa:	00 00 00 
		lapicaddr = 0;
f0105dad:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f0105db4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105db7:	c7 04 24 58 7f 10 f0 	movl   $0xf0107f58,(%esp)
f0105dbe:	e8 e3 e1 ff ff       	call   f0103fa6 <cprintf>
		return;
f0105dc3:	eb 44                	jmp    f0105e09 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105dc5:	8b 15 c4 c3 22 f0    	mov    0xf022c3c4,%edx
f0105dcb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105dcf:	0f b6 00             	movzbl (%eax),%eax
f0105dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd6:	c7 04 24 df 7f 10 f0 	movl   $0xf0107fdf,(%esp)
f0105ddd:	e8 c4 e1 ff ff       	call   f0103fa6 <cprintf>

	if (mp->imcrp) {
f0105de2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105de5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105de9:	74 1e                	je     f0105e09 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105deb:	c7 04 24 84 7f 10 f0 	movl   $0xf0107f84,(%esp)
f0105df2:	e8 af e1 ff ff       	call   f0103fa6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105df7:	ba 22 00 00 00       	mov    $0x22,%edx
f0105dfc:	b8 70 00 00 00       	mov    $0x70,%eax
f0105e01:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105e02:	b2 23                	mov    $0x23,%dl
f0105e04:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e05:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e08:	ee                   	out    %al,(%dx)
	}
}
f0105e09:	83 c4 2c             	add    $0x2c,%esp
f0105e0c:	5b                   	pop    %ebx
f0105e0d:	5e                   	pop    %esi
f0105e0e:	5f                   	pop    %edi
f0105e0f:	5d                   	pop    %ebp
f0105e10:	c3                   	ret    

f0105e11 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105e11:	55                   	push   %ebp
f0105e12:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105e14:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f0105e1a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105e1d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e1f:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105e24:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e27:	5d                   	pop    %ebp
f0105e28:	c3                   	ret    

f0105e29 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e29:	55                   	push   %ebp
f0105e2a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e2c:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105e31:	85 c0                	test   %eax,%eax
f0105e33:	74 08                	je     f0105e3d <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e35:	8b 40 20             	mov    0x20(%eax),%eax
f0105e38:	c1 e8 18             	shr    $0x18,%eax
f0105e3b:	eb 05                	jmp    f0105e42 <cpunum+0x19>
	return 0;
f0105e3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e42:	5d                   	pop    %ebp
f0105e43:	c3                   	ret    

f0105e44 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105e44:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0105e49:	85 c0                	test   %eax,%eax
f0105e4b:	0f 84 23 01 00 00    	je     f0105f74 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e51:	55                   	push   %ebp
f0105e52:	89 e5                	mov    %esp,%ebp
f0105e54:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105e57:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0105e5e:	00 
f0105e5f:	89 04 24             	mov    %eax,(%esp)
f0105e62:	e8 10 b5 ff ff       	call   f0101377 <mmio_map_region>
f0105e67:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105e6c:	ba 27 01 00 00       	mov    $0x127,%edx
f0105e71:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105e76:	e8 96 ff ff ff       	call   f0105e11 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e7b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e80:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e85:	e8 87 ff ff ff       	call   f0105e11 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e8a:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e8f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e94:	e8 78 ff ff ff       	call   f0105e11 <lapicw>
	lapicw(TICR, 10000000); 
f0105e99:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e9e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105ea3:	e8 69 ff ff ff       	call   f0105e11 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105ea8:	e8 7c ff ff ff       	call   f0105e29 <cpunum>
f0105ead:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb0:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105eb5:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0105ebb:	74 0f                	je     f0105ecc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0105ebd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ec2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105ec7:	e8 45 ff ff ff       	call   f0105e11 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105ecc:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ed1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ed6:	e8 36 ff ff ff       	call   f0105e11 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105edb:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f0105ee0:	8b 40 30             	mov    0x30(%eax),%eax
f0105ee3:	c1 e8 10             	shr    $0x10,%eax
f0105ee6:	3c 03                	cmp    $0x3,%al
f0105ee8:	76 0f                	jbe    f0105ef9 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0105eea:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eef:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105ef4:	e8 18 ff ff ff       	call   f0105e11 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ef9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105efe:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105f03:	e8 09 ff ff ff       	call   f0105e11 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105f08:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f0d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f12:	e8 fa fe ff ff       	call   f0105e11 <lapicw>
	lapicw(ESR, 0);
f0105f17:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f1c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f21:	e8 eb fe ff ff       	call   f0105e11 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105f26:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f2b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f30:	e8 dc fe ff ff       	call   f0105e11 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105f35:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f3a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f3f:	e8 cd fe ff ff       	call   f0105e11 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105f44:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105f49:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f4e:	e8 be fe ff ff       	call   f0105e11 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105f53:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105f59:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f5f:	f6 c4 10             	test   $0x10,%ah
f0105f62:	75 f5                	jne    f0105f59 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f69:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f6e:	e8 9e fe ff ff       	call   f0105e11 <lapicw>
}
f0105f73:	c9                   	leave  
f0105f74:	f3 c3                	repz ret 

f0105f76 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105f76:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0105f7d:	74 13                	je     f0105f92 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f7f:	55                   	push   %ebp
f0105f80:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105f82:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f87:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f8c:	e8 80 fe ff ff       	call   f0105e11 <lapicw>
}
f0105f91:	5d                   	pop    %ebp
f0105f92:	f3 c3                	repz ret 

f0105f94 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f94:	55                   	push   %ebp
f0105f95:	89 e5                	mov    %esp,%ebp
f0105f97:	56                   	push   %esi
f0105f98:	53                   	push   %ebx
f0105f99:	83 ec 10             	sub    $0x10,%esp
f0105f9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105f9f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fa2:	ba 70 00 00 00       	mov    $0x70,%edx
f0105fa7:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105fac:	ee                   	out    %al,(%dx)
f0105fad:	b2 71                	mov    $0x71,%dl
f0105faf:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105fb4:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105fb5:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105fbc:	75 24                	jne    f0105fe2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fbe:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0105fc5:	00 
f0105fc6:	c7 44 24 08 68 65 10 	movl   $0xf0106568,0x8(%esp)
f0105fcd:	f0 
f0105fce:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0105fd5:	00 
f0105fd6:	c7 04 24 fc 7f 10 f0 	movl   $0xf0107ffc,(%esp)
f0105fdd:	e8 5e a0 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105fe2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105fe9:	00 00 
	wrv[1] = addr >> 4;
f0105feb:	89 f0                	mov    %esi,%eax
f0105fed:	c1 e8 04             	shr    $0x4,%eax
f0105ff0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105ff6:	c1 e3 18             	shl    $0x18,%ebx
f0105ff9:	89 da                	mov    %ebx,%edx
f0105ffb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106000:	e8 0c fe ff ff       	call   f0105e11 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106005:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010600a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010600f:	e8 fd fd ff ff       	call   f0105e11 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106014:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106019:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010601e:	e8 ee fd ff ff       	call   f0105e11 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106023:	c1 ee 0c             	shr    $0xc,%esi
f0106026:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010602c:	89 da                	mov    %ebx,%edx
f010602e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106033:	e8 d9 fd ff ff       	call   f0105e11 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106038:	89 f2                	mov    %esi,%edx
f010603a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010603f:	e8 cd fd ff ff       	call   f0105e11 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106044:	89 da                	mov    %ebx,%edx
f0106046:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010604b:	e8 c1 fd ff ff       	call   f0105e11 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106050:	89 f2                	mov    %esi,%edx
f0106052:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106057:	e8 b5 fd ff ff       	call   f0105e11 <lapicw>
		microdelay(200);
	}
}
f010605c:	83 c4 10             	add    $0x10,%esp
f010605f:	5b                   	pop    %ebx
f0106060:	5e                   	pop    %esi
f0106061:	5d                   	pop    %ebp
f0106062:	c3                   	ret    

f0106063 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106063:	55                   	push   %ebp
f0106064:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106066:	8b 55 08             	mov    0x8(%ebp),%edx
f0106069:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010606f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106074:	e8 98 fd ff ff       	call   f0105e11 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106079:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f010607f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106085:	f6 c4 10             	test   $0x10,%ah
f0106088:	75 f5                	jne    f010607f <lapic_ipi+0x1c>
		;
}
f010608a:	5d                   	pop    %ebp
f010608b:	c3                   	ret    

f010608c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010608c:	55                   	push   %ebp
f010608d:	89 e5                	mov    %esp,%ebp
f010608f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106092:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106098:	8b 55 0c             	mov    0xc(%ebp),%edx
f010609b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010609e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01060a5:	5d                   	pop    %ebp
f01060a6:	c3                   	ret    

f01060a7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01060a7:	55                   	push   %ebp
f01060a8:	89 e5                	mov    %esp,%ebp
f01060aa:	56                   	push   %esi
f01060ab:	53                   	push   %ebx
f01060ac:	83 ec 20             	sub    $0x20,%esp
f01060af:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01060b2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01060b5:	75 07                	jne    f01060be <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01060b7:	ba 01 00 00 00       	mov    $0x1,%edx
f01060bc:	eb 42                	jmp    f0106100 <spin_lock+0x59>
f01060be:	8b 73 08             	mov    0x8(%ebx),%esi
f01060c1:	e8 63 fd ff ff       	call   f0105e29 <cpunum>
f01060c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01060c9:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01060ce:	39 c6                	cmp    %eax,%esi
f01060d0:	75 e5                	jne    f01060b7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01060d2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01060d5:	e8 4f fd ff ff       	call   f0105e29 <cpunum>
f01060da:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01060de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060e2:	c7 44 24 08 0c 80 10 	movl   $0xf010800c,0x8(%esp)
f01060e9:	f0 
f01060ea:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01060f1:	00 
f01060f2:	c7 04 24 70 80 10 f0 	movl   $0xf0108070,(%esp)
f01060f9:	e8 42 9f ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060fe:	f3 90                	pause  
f0106100:	89 d0                	mov    %edx,%eax
f0106102:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106105:	85 c0                	test   %eax,%eax
f0106107:	75 f5                	jne    f01060fe <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106109:	e8 1b fd ff ff       	call   f0105e29 <cpunum>
f010610e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106111:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0106116:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106119:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010611c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010611e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106123:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106129:	76 12                	jbe    f010613d <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010612b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010612e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106131:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106133:	83 c0 01             	add    $0x1,%eax
f0106136:	83 f8 0a             	cmp    $0xa,%eax
f0106139:	75 e8                	jne    f0106123 <spin_lock+0x7c>
f010613b:	eb 0f                	jmp    f010614c <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010613d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106144:	83 c0 01             	add    $0x1,%eax
f0106147:	83 f8 09             	cmp    $0x9,%eax
f010614a:	7e f1                	jle    f010613d <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010614c:	83 c4 20             	add    $0x20,%esp
f010614f:	5b                   	pop    %ebx
f0106150:	5e                   	pop    %esi
f0106151:	5d                   	pop    %ebp
f0106152:	c3                   	ret    

f0106153 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106153:	55                   	push   %ebp
f0106154:	89 e5                	mov    %esp,%ebp
f0106156:	57                   	push   %edi
f0106157:	56                   	push   %esi
f0106158:	53                   	push   %ebx
f0106159:	83 ec 6c             	sub    $0x6c,%esp
f010615c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010615f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106162:	74 18                	je     f010617c <spin_unlock+0x29>
f0106164:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106167:	e8 bd fc ff ff       	call   f0105e29 <cpunum>
f010616c:	6b c0 74             	imul   $0x74,%eax,%eax
f010616f:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106174:	39 c3                	cmp    %eax,%ebx
f0106176:	0f 84 ce 00 00 00    	je     f010624a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010617c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106183:	00 
f0106184:	8d 46 0c             	lea    0xc(%esi),%eax
f0106187:	89 44 24 04          	mov    %eax,0x4(%esp)
f010618b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010618e:	89 1c 24             	mov    %ebx,(%esp)
f0106191:	e8 8e f6 ff ff       	call   f0105824 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106196:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106199:	0f b6 38             	movzbl (%eax),%edi
f010619c:	8b 76 04             	mov    0x4(%esi),%esi
f010619f:	e8 85 fc ff ff       	call   f0105e29 <cpunum>
f01061a4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01061a8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01061ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061b0:	c7 04 24 38 80 10 f0 	movl   $0xf0108038,(%esp)
f01061b7:	e8 ea dd ff ff       	call   f0103fa6 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01061bc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01061bf:	eb 65                	jmp    f0106226 <spin_unlock+0xd3>
f01061c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061c5:	89 04 24             	mov    %eax,(%esp)
f01061c8:	e8 b6 eb ff ff       	call   f0104d83 <debuginfo_eip>
f01061cd:	85 c0                	test   %eax,%eax
f01061cf:	78 39                	js     f010620a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01061d1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01061d3:	89 c2                	mov    %eax,%edx
f01061d5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01061d8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01061dc:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01061df:	89 54 24 14          	mov    %edx,0x14(%esp)
f01061e3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01061e6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01061ea:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01061ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01061f1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f01061f4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01061f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061fc:	c7 04 24 80 80 10 f0 	movl   $0xf0108080,(%esp)
f0106203:	e8 9e dd ff ff       	call   f0103fa6 <cprintf>
f0106208:	eb 12                	jmp    f010621c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010620a:	8b 06                	mov    (%esi),%eax
f010620c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106210:	c7 04 24 97 80 10 f0 	movl   $0xf0108097,(%esp)
f0106217:	e8 8a dd ff ff       	call   f0103fa6 <cprintf>
f010621c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010621f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106222:	39 c3                	cmp    %eax,%ebx
f0106224:	74 08                	je     f010622e <spin_unlock+0xdb>
f0106226:	89 de                	mov    %ebx,%esi
f0106228:	8b 03                	mov    (%ebx),%eax
f010622a:	85 c0                	test   %eax,%eax
f010622c:	75 93                	jne    f01061c1 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010622e:	c7 44 24 08 9f 80 10 	movl   $0xf010809f,0x8(%esp)
f0106235:	f0 
f0106236:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010623d:	00 
f010623e:	c7 04 24 70 80 10 f0 	movl   $0xf0108070,(%esp)
f0106245:	e8 f6 9d ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010624a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106251:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106258:	b8 00 00 00 00       	mov    $0x0,%eax
f010625d:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106260:	83 c4 6c             	add    $0x6c,%esp
f0106263:	5b                   	pop    %ebx
f0106264:	5e                   	pop    %esi
f0106265:	5f                   	pop    %edi
f0106266:	5d                   	pop    %ebp
f0106267:	c3                   	ret    
	...

f0106270 <__udivdi3>:
f0106270:	83 ec 1c             	sub    $0x1c,%esp
f0106273:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106277:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010627b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010627f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106283:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106287:	8b 74 24 24          	mov    0x24(%esp),%esi
f010628b:	85 ff                	test   %edi,%edi
f010628d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106291:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106295:	89 cd                	mov    %ecx,%ebp
f0106297:	89 44 24 04          	mov    %eax,0x4(%esp)
f010629b:	75 33                	jne    f01062d0 <__udivdi3+0x60>
f010629d:	39 f1                	cmp    %esi,%ecx
f010629f:	77 57                	ja     f01062f8 <__udivdi3+0x88>
f01062a1:	85 c9                	test   %ecx,%ecx
f01062a3:	75 0b                	jne    f01062b0 <__udivdi3+0x40>
f01062a5:	b8 01 00 00 00       	mov    $0x1,%eax
f01062aa:	31 d2                	xor    %edx,%edx
f01062ac:	f7 f1                	div    %ecx
f01062ae:	89 c1                	mov    %eax,%ecx
f01062b0:	89 f0                	mov    %esi,%eax
f01062b2:	31 d2                	xor    %edx,%edx
f01062b4:	f7 f1                	div    %ecx
f01062b6:	89 c6                	mov    %eax,%esi
f01062b8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01062bc:	f7 f1                	div    %ecx
f01062be:	89 f2                	mov    %esi,%edx
f01062c0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01062c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01062c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01062cc:	83 c4 1c             	add    $0x1c,%esp
f01062cf:	c3                   	ret    
f01062d0:	31 d2                	xor    %edx,%edx
f01062d2:	31 c0                	xor    %eax,%eax
f01062d4:	39 f7                	cmp    %esi,%edi
f01062d6:	77 e8                	ja     f01062c0 <__udivdi3+0x50>
f01062d8:	0f bd cf             	bsr    %edi,%ecx
f01062db:	83 f1 1f             	xor    $0x1f,%ecx
f01062de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01062e2:	75 2c                	jne    f0106310 <__udivdi3+0xa0>
f01062e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01062e8:	76 04                	jbe    f01062ee <__udivdi3+0x7e>
f01062ea:	39 f7                	cmp    %esi,%edi
f01062ec:	73 d2                	jae    f01062c0 <__udivdi3+0x50>
f01062ee:	31 d2                	xor    %edx,%edx
f01062f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01062f5:	eb c9                	jmp    f01062c0 <__udivdi3+0x50>
f01062f7:	90                   	nop
f01062f8:	89 f2                	mov    %esi,%edx
f01062fa:	f7 f1                	div    %ecx
f01062fc:	31 d2                	xor    %edx,%edx
f01062fe:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106302:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106306:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010630a:	83 c4 1c             	add    $0x1c,%esp
f010630d:	c3                   	ret    
f010630e:	66 90                	xchg   %ax,%ax
f0106310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106315:	b8 20 00 00 00       	mov    $0x20,%eax
f010631a:	89 ea                	mov    %ebp,%edx
f010631c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106320:	d3 e7                	shl    %cl,%edi
f0106322:	89 c1                	mov    %eax,%ecx
f0106324:	d3 ea                	shr    %cl,%edx
f0106326:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010632b:	09 fa                	or     %edi,%edx
f010632d:	89 f7                	mov    %esi,%edi
f010632f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106333:	89 f2                	mov    %esi,%edx
f0106335:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106339:	d3 e5                	shl    %cl,%ebp
f010633b:	89 c1                	mov    %eax,%ecx
f010633d:	d3 ef                	shr    %cl,%edi
f010633f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106344:	d3 e2                	shl    %cl,%edx
f0106346:	89 c1                	mov    %eax,%ecx
f0106348:	d3 ee                	shr    %cl,%esi
f010634a:	09 d6                	or     %edx,%esi
f010634c:	89 fa                	mov    %edi,%edx
f010634e:	89 f0                	mov    %esi,%eax
f0106350:	f7 74 24 0c          	divl   0xc(%esp)
f0106354:	89 d7                	mov    %edx,%edi
f0106356:	89 c6                	mov    %eax,%esi
f0106358:	f7 e5                	mul    %ebp
f010635a:	39 d7                	cmp    %edx,%edi
f010635c:	72 22                	jb     f0106380 <__udivdi3+0x110>
f010635e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106362:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106367:	d3 e5                	shl    %cl,%ebp
f0106369:	39 c5                	cmp    %eax,%ebp
f010636b:	73 04                	jae    f0106371 <__udivdi3+0x101>
f010636d:	39 d7                	cmp    %edx,%edi
f010636f:	74 0f                	je     f0106380 <__udivdi3+0x110>
f0106371:	89 f0                	mov    %esi,%eax
f0106373:	31 d2                	xor    %edx,%edx
f0106375:	e9 46 ff ff ff       	jmp    f01062c0 <__udivdi3+0x50>
f010637a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106380:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106383:	31 d2                	xor    %edx,%edx
f0106385:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106389:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010638d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106391:	83 c4 1c             	add    $0x1c,%esp
f0106394:	c3                   	ret    
	...

f01063a0 <__umoddi3>:
f01063a0:	83 ec 1c             	sub    $0x1c,%esp
f01063a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01063a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f01063ab:	8b 44 24 20          	mov    0x20(%esp),%eax
f01063af:	89 74 24 10          	mov    %esi,0x10(%esp)
f01063b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01063b7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01063bb:	85 ed                	test   %ebp,%ebp
f01063bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01063c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01063c5:	89 cf                	mov    %ecx,%edi
f01063c7:	89 04 24             	mov    %eax,(%esp)
f01063ca:	89 f2                	mov    %esi,%edx
f01063cc:	75 1a                	jne    f01063e8 <__umoddi3+0x48>
f01063ce:	39 f1                	cmp    %esi,%ecx
f01063d0:	76 4e                	jbe    f0106420 <__umoddi3+0x80>
f01063d2:	f7 f1                	div    %ecx
f01063d4:	89 d0                	mov    %edx,%eax
f01063d6:	31 d2                	xor    %edx,%edx
f01063d8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01063dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01063e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01063e4:	83 c4 1c             	add    $0x1c,%esp
f01063e7:	c3                   	ret    
f01063e8:	39 f5                	cmp    %esi,%ebp
f01063ea:	77 54                	ja     f0106440 <__umoddi3+0xa0>
f01063ec:	0f bd c5             	bsr    %ebp,%eax
f01063ef:	83 f0 1f             	xor    $0x1f,%eax
f01063f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063f6:	75 60                	jne    f0106458 <__umoddi3+0xb8>
f01063f8:	3b 0c 24             	cmp    (%esp),%ecx
f01063fb:	0f 87 07 01 00 00    	ja     f0106508 <__umoddi3+0x168>
f0106401:	89 f2                	mov    %esi,%edx
f0106403:	8b 34 24             	mov    (%esp),%esi
f0106406:	29 ce                	sub    %ecx,%esi
f0106408:	19 ea                	sbb    %ebp,%edx
f010640a:	89 34 24             	mov    %esi,(%esp)
f010640d:	8b 04 24             	mov    (%esp),%eax
f0106410:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106414:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106418:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010641c:	83 c4 1c             	add    $0x1c,%esp
f010641f:	c3                   	ret    
f0106420:	85 c9                	test   %ecx,%ecx
f0106422:	75 0b                	jne    f010642f <__umoddi3+0x8f>
f0106424:	b8 01 00 00 00       	mov    $0x1,%eax
f0106429:	31 d2                	xor    %edx,%edx
f010642b:	f7 f1                	div    %ecx
f010642d:	89 c1                	mov    %eax,%ecx
f010642f:	89 f0                	mov    %esi,%eax
f0106431:	31 d2                	xor    %edx,%edx
f0106433:	f7 f1                	div    %ecx
f0106435:	8b 04 24             	mov    (%esp),%eax
f0106438:	f7 f1                	div    %ecx
f010643a:	eb 98                	jmp    f01063d4 <__umoddi3+0x34>
f010643c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106440:	89 f2                	mov    %esi,%edx
f0106442:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106446:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010644a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010644e:	83 c4 1c             	add    $0x1c,%esp
f0106451:	c3                   	ret    
f0106452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106458:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010645d:	89 e8                	mov    %ebp,%eax
f010645f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106464:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106468:	89 fa                	mov    %edi,%edx
f010646a:	d3 e0                	shl    %cl,%eax
f010646c:	89 e9                	mov    %ebp,%ecx
f010646e:	d3 ea                	shr    %cl,%edx
f0106470:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106475:	09 c2                	or     %eax,%edx
f0106477:	8b 44 24 08          	mov    0x8(%esp),%eax
f010647b:	89 14 24             	mov    %edx,(%esp)
f010647e:	89 f2                	mov    %esi,%edx
f0106480:	d3 e7                	shl    %cl,%edi
f0106482:	89 e9                	mov    %ebp,%ecx
f0106484:	d3 ea                	shr    %cl,%edx
f0106486:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010648b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010648f:	d3 e6                	shl    %cl,%esi
f0106491:	89 e9                	mov    %ebp,%ecx
f0106493:	d3 e8                	shr    %cl,%eax
f0106495:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010649a:	09 f0                	or     %esi,%eax
f010649c:	8b 74 24 08          	mov    0x8(%esp),%esi
f01064a0:	f7 34 24             	divl   (%esp)
f01064a3:	d3 e6                	shl    %cl,%esi
f01064a5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01064a9:	89 d6                	mov    %edx,%esi
f01064ab:	f7 e7                	mul    %edi
f01064ad:	39 d6                	cmp    %edx,%esi
f01064af:	89 c1                	mov    %eax,%ecx
f01064b1:	89 d7                	mov    %edx,%edi
f01064b3:	72 3f                	jb     f01064f4 <__umoddi3+0x154>
f01064b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01064b9:	72 35                	jb     f01064f0 <__umoddi3+0x150>
f01064bb:	8b 44 24 08          	mov    0x8(%esp),%eax
f01064bf:	29 c8                	sub    %ecx,%eax
f01064c1:	19 fe                	sbb    %edi,%esi
f01064c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01064c8:	89 f2                	mov    %esi,%edx
f01064ca:	d3 e8                	shr    %cl,%eax
f01064cc:	89 e9                	mov    %ebp,%ecx
f01064ce:	d3 e2                	shl    %cl,%edx
f01064d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01064d5:	09 d0                	or     %edx,%eax
f01064d7:	89 f2                	mov    %esi,%edx
f01064d9:	d3 ea                	shr    %cl,%edx
f01064db:	8b 74 24 10          	mov    0x10(%esp),%esi
f01064df:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01064e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01064e7:	83 c4 1c             	add    $0x1c,%esp
f01064ea:	c3                   	ret    
f01064eb:	90                   	nop
f01064ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01064f0:	39 d6                	cmp    %edx,%esi
f01064f2:	75 c7                	jne    f01064bb <__umoddi3+0x11b>
f01064f4:	89 d7                	mov    %edx,%edi
f01064f6:	89 c1                	mov    %eax,%ecx
f01064f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01064fc:	1b 3c 24             	sbb    (%esp),%edi
f01064ff:	eb ba                	jmp    f01064bb <__umoddi3+0x11b>
f0106501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106508:	39 f5                	cmp    %esi,%ebp
f010650a:	0f 82 f1 fe ff ff    	jb     f0106401 <__umoddi3+0x61>
f0106510:	e9 f8 fe ff ff       	jmp    f010640d <__umoddi3+0x6d>
