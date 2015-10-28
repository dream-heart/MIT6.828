
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
f010004b:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 2e 23 f0    	mov    %esi,0xf0232e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 70 65 00 00       	call   f01065d4 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 6d 10 f0 	movl   $0xf0106d00,(%esp)
f010007d:	e8 ec 3e 00 00       	call   f0103f6e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 ad 3e 00 00       	call   f0103f3b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 20 7e 10 f0 	movl   $0xf0107e20,(%esp)
f0100095:	e8 d4 3e 00 00       	call   f0103f6e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 13 08 00 00       	call   f01008b9 <monitor>
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
f01000ae:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 6d 10 f0 	movl   $0xf0106d6b,(%esp)
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
f01000e2:	e8 ed 64 00 00       	call   f01065d4 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 6d 10 f0 	movl   $0xf0106d77,(%esp)
f01000f2:	e8 77 3e 00 00       	call   f0103f6e <cprintf>

	lapic_init();
f01000f7:	e8 f2 64 00 00       	call   f01065ee <lapic_init>
	env_init_percpu();
f01000fc:	e8 b4 35 00 00       	call   f01036b5 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 8a 3e 00 00       	call   f0103f90 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 c9 64 00 00       	call   f01065d4 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 30 23 f0    	add    $0xf0233020,%edx
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
f0100124:	e8 5b 67 00 00       	call   f0106884 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100129:	e8 ae 4b 00 00       	call   f0104cdc <sched_yield>

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
f0100135:	b8 08 40 27 f0       	mov    $0xf0274008,%eax
f010013a:	2d 18 1b 23 f0       	sub    $0xf0231b18,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 18 1b 23 f0 	movl   $0xf0231b18,(%esp)
f0100152:	e8 1c 5e 00 00       	call   f0105f73 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 00 05 00 00       	call   f010065c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 8d 6d 10 f0 	movl   $0xf0106d8d,(%esp)
f010016b:	e8 fe 3d 00 00       	call   f0103f6e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 dc 11 00 00       	call   f0101351 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 65 35 00 00       	call   f01036df <env_init>
	trap_init();
f010017a:	e8 e1 3e 00 00       	call   f0104060 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 71 61 00 00       	call   f01062f6 <mp_init>
	lapic_init();
f0100185:	e8 64 64 00 00       	call   f01065ee <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 0e 3d 00 00       	call   f0103e9d <pic_init>
f010018f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100196:	e8 e9 66 00 00       	call   f0106884 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 2e 23 f0 07 	cmpl   $0x7,0xf0232e88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 6b 6d 10 f0 	movl   $0xf0106d6b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 12 62 10 f0       	mov    $0xf0106212,%eax
f01001cd:	2d 98 61 10 f0       	sub    $0xf0106198,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 98 61 10 	movl   $0xf0106198,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 e4 5d 00 00       	call   f0105fce <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f01001ef:	eb 4d                	jmp    f010023e <i386_init+0x110>
		if (c == cpus + cpunum())  // We've started already.
f01001f1:	e8 de 63 00 00       	call   f01065d4 <cpunum>
f01001f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01001f9:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01001fe:	39 c3                	cmp    %eax,%ebx
f0100200:	74 39                	je     f010023b <i386_init+0x10d>

static void boot_aps(void);


void
i386_init(void)
f0100202:	89 d8                	mov    %ebx,%eax
f0100204:	2d 20 30 23 f0       	sub    $0xf0233020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100209:	c1 f8 02             	sar    $0x2,%eax
f010020c:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100212:	c1 e0 0f             	shl    $0xf,%eax
f0100215:	8d 80 00 c0 23 f0    	lea    -0xfdc4000(%eax),%eax
f010021b:	a3 84 2e 23 f0       	mov    %eax,0xf0232e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100220:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100227:	00 
f0100228:	0f b6 03             	movzbl (%ebx),%eax
f010022b:	89 04 24             	mov    %eax,(%esp)
f010022e:	e8 09 65 00 00       	call   f010673c <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100233:	8b 43 04             	mov    0x4(%ebx),%eax
f0100236:	83 f8 01             	cmp    $0x1,%eax
f0100239:	75 f8                	jne    f0100233 <i386_init+0x105>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010023b:	83 c3 74             	add    $0x74,%ebx
f010023e:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f0100245:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010024a:	39 c3                	cmp    %eax,%ebx
f010024c:	72 a3                	jb     f01001f1 <i386_init+0xc3>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010024e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100255:	00 
f0100256:	c7 04 24 a4 80 22 f0 	movl   $0xf02280a4,(%esp)
f010025d:	e8 93 36 00 00       	call   f01038f5 <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f0100262:	e8 75 4a 00 00       	call   f0104cdc <sched_yield>

f0100267 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100267:	55                   	push   %ebp
f0100268:	89 e5                	mov    %esp,%ebp
f010026a:	53                   	push   %ebx
f010026b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010026e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100271:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100274:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100278:	8b 45 08             	mov    0x8(%ebp),%eax
f010027b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010027f:	c7 04 24 a8 6d 10 f0 	movl   $0xf0106da8,(%esp)
f0100286:	e8 e3 3c 00 00       	call   f0103f6e <cprintf>
	vcprintf(fmt, ap);
f010028b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010028f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100292:	89 04 24             	mov    %eax,(%esp)
f0100295:	e8 a1 3c 00 00       	call   f0103f3b <vcprintf>
	cprintf("\n");
f010029a:	c7 04 24 20 7e 10 f0 	movl   $0xf0107e20,(%esp)
f01002a1:	e8 c8 3c 00 00       	call   f0103f6e <cprintf>
	va_end(ap);
}
f01002a6:	83 c4 14             	add    $0x14,%esp
f01002a9:	5b                   	pop    %ebx
f01002aa:	5d                   	pop    %ebp
f01002ab:	c3                   	ret    
f01002ac:	00 00                	add    %al,(%eax)
	...

f01002b0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002b8:	ec                   	in     (%dx),%al
f01002b9:	ec                   	in     (%dx),%al
f01002ba:	ec                   	in     (%dx),%al
f01002bb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002be:	55                   	push   %ebp
f01002bf:	89 e5                	mov    %esp,%ebp
f01002c1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002c7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002cc:	a8 01                	test   $0x1,%al
f01002ce:	74 06                	je     f01002d6 <serial_proc_data+0x18>
f01002d0:	b2 f8                	mov    $0xf8,%dl
f01002d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d3:	0f b6 c8             	movzbl %al,%ecx
}
f01002d6:	89 c8                	mov    %ecx,%eax
f01002d8:	5d                   	pop    %ebp
f01002d9:	c3                   	ret    

f01002da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	53                   	push   %ebx
f01002de:	83 ec 04             	sub    $0x4,%esp
f01002e1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e3:	eb 25                	jmp    f010030a <cons_intr+0x30>
		if (c == 0)
f01002e5:	85 c0                	test   %eax,%eax
f01002e7:	74 21                	je     f010030a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01002e9:	8b 15 24 22 23 f0    	mov    0xf0232224,%edx
f01002ef:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
f01002f5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002f8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0100302:	0f 44 c2             	cmove  %edx,%eax
f0100305:	a3 24 22 23 f0       	mov    %eax,0xf0232224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010030a:	ff d3                	call   *%ebx
f010030c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010030f:	75 d4                	jne    f01002e5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100311:	83 c4 04             	add    $0x4,%esp
f0100314:	5b                   	pop    %ebx
f0100315:	5d                   	pop    %ebp
f0100316:	c3                   	ret    

f0100317 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100317:	55                   	push   %ebp
f0100318:	89 e5                	mov    %esp,%ebp
f010031a:	57                   	push   %edi
f010031b:	56                   	push   %esi
f010031c:	53                   	push   %ebx
f010031d:	83 ec 2c             	sub    $0x2c,%esp
f0100320:	89 c7                	mov    %eax,%edi
f0100322:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100327:	be fd 03 00 00       	mov    $0x3fd,%esi
f010032c:	eb 05                	jmp    f0100333 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010032e:	e8 7d ff ff ff       	call   f01002b0 <delay>
f0100333:	89 f2                	mov    %esi,%edx
f0100335:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100336:	a8 20                	test   $0x20,%al
f0100338:	75 05                	jne    f010033f <cons_putc+0x28>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033a:	83 eb 01             	sub    $0x1,%ebx
f010033d:	75 ef                	jne    f010032e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010033f:	89 fa                	mov    %edi,%edx
f0100341:	89 f8                	mov    %edi,%eax
f0100343:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100346:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010034b:	ee                   	out    %al,(%dx)
f010034c:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100351:	be 79 03 00 00       	mov    $0x379,%esi
f0100356:	eb 05                	jmp    f010035d <cons_putc+0x46>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100358:	e8 53 ff ff ff       	call   f01002b0 <delay>
f010035d:	89 f2                	mov    %esi,%edx
f010035f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100360:	84 c0                	test   %al,%al
f0100362:	78 05                	js     f0100369 <cons_putc+0x52>
f0100364:	83 eb 01             	sub    $0x1,%ebx
f0100367:	75 ef                	jne    f0100358 <cons_putc+0x41>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100369:	ba 78 03 00 00       	mov    $0x378,%edx
f010036e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100372:	ee                   	out    %al,(%dx)
f0100373:	b2 7a                	mov    $0x7a,%dl
f0100375:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037a:	ee                   	out    %al,(%dx)
f010037b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100380:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100381:	89 fa                	mov    %edi,%edx
f0100383:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100389:	89 f8                	mov    %edi,%eax
f010038b:	80 cc 07             	or     $0x7,%ah
f010038e:	85 d2                	test   %edx,%edx
f0100390:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100393:	89 f8                	mov    %edi,%eax
f0100395:	25 ff 00 00 00       	and    $0xff,%eax
f010039a:	83 f8 09             	cmp    $0x9,%eax
f010039d:	74 79                	je     f0100418 <cons_putc+0x101>
f010039f:	83 f8 09             	cmp    $0x9,%eax
f01003a2:	7f 0e                	jg     f01003b2 <cons_putc+0x9b>
f01003a4:	83 f8 08             	cmp    $0x8,%eax
f01003a7:	0f 85 9f 00 00 00    	jne    f010044c <cons_putc+0x135>
f01003ad:	8d 76 00             	lea    0x0(%esi),%esi
f01003b0:	eb 10                	jmp    f01003c2 <cons_putc+0xab>
f01003b2:	83 f8 0a             	cmp    $0xa,%eax
f01003b5:	74 3b                	je     f01003f2 <cons_putc+0xdb>
f01003b7:	83 f8 0d             	cmp    $0xd,%eax
f01003ba:	0f 85 8c 00 00 00    	jne    f010044c <cons_putc+0x135>
f01003c0:	eb 38                	jmp    f01003fa <cons_putc+0xe3>
	case '\b':
		if (crt_pos > 0) {
f01003c2:	0f b7 05 34 22 23 f0 	movzwl 0xf0232234,%eax
f01003c9:	66 85 c0             	test   %ax,%ax
f01003cc:	0f 84 e4 00 00 00    	je     f01004b6 <cons_putc+0x19f>
			crt_pos--;
f01003d2:	83 e8 01             	sub    $0x1,%eax
f01003d5:	66 a3 34 22 23 f0    	mov    %ax,0xf0232234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003db:	0f b7 c0             	movzwl %ax,%eax
f01003de:	66 81 e7 00 ff       	and    $0xff00,%di
f01003e3:	83 cf 20             	or     $0x20,%edi
f01003e6:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
f01003ec:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003f0:	eb 77                	jmp    f0100469 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003f2:	66 83 05 34 22 23 f0 	addw   $0x50,0xf0232234
f01003f9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003fa:	0f b7 05 34 22 23 f0 	movzwl 0xf0232234,%eax
f0100401:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100407:	c1 e8 16             	shr    $0x16,%eax
f010040a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010040d:	c1 e0 04             	shl    $0x4,%eax
f0100410:	66 a3 34 22 23 f0    	mov    %ax,0xf0232234
f0100416:	eb 51                	jmp    f0100469 <cons_putc+0x152>
		break;
	case '\t':
		cons_putc(' ');
f0100418:	b8 20 00 00 00       	mov    $0x20,%eax
f010041d:	e8 f5 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f0100422:	b8 20 00 00 00       	mov    $0x20,%eax
f0100427:	e8 eb fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f010042c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100431:	e8 e1 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f0100436:	b8 20 00 00 00       	mov    $0x20,%eax
f010043b:	e8 d7 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 cd fe ff ff       	call   f0100317 <cons_putc>
f010044a:	eb 1d                	jmp    f0100469 <cons_putc+0x152>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010044c:	0f b7 05 34 22 23 f0 	movzwl 0xf0232234,%eax
f0100453:	0f b7 c8             	movzwl %ax,%ecx
f0100456:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
f010045c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100460:	83 c0 01             	add    $0x1,%eax
f0100463:	66 a3 34 22 23 f0    	mov    %ax,0xf0232234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100469:	66 81 3d 34 22 23 f0 	cmpw   $0x7cf,0xf0232234
f0100470:	cf 07 
f0100472:	76 42                	jbe    f01004b6 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100474:	a1 30 22 23 f0       	mov    0xf0232230,%eax
f0100479:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100480:	00 
f0100481:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100487:	89 54 24 04          	mov    %edx,0x4(%esp)
f010048b:	89 04 24             	mov    %eax,(%esp)
f010048e:	e8 3b 5b 00 00       	call   f0105fce <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100493:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010049e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a4:	83 c0 01             	add    $0x1,%eax
f01004a7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004ac:	75 f0                	jne    f010049e <cons_putc+0x187>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ae:	66 83 2d 34 22 23 f0 	subw   $0x50,0xf0232234
f01004b5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b6:	8b 0d 2c 22 23 f0    	mov    0xf023222c,%ecx
f01004bc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c1:	89 ca                	mov    %ecx,%edx
f01004c3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c4:	0f b7 35 34 22 23 f0 	movzwl 0xf0232234,%esi
f01004cb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ce:	89 f0                	mov    %esi,%eax
f01004d0:	66 c1 e8 08          	shr    $0x8,%ax
f01004d4:	89 da                	mov    %ebx,%edx
f01004d6:	ee                   	out    %al,(%dx)
f01004d7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004dc:	89 ca                	mov    %ecx,%edx
f01004de:	ee                   	out    %al,(%dx)
f01004df:	89 f0                	mov    %esi,%eax
f01004e1:	89 da                	mov    %ebx,%edx
f01004e3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e4:	83 c4 2c             	add    $0x2c,%esp
f01004e7:	5b                   	pop    %ebx
f01004e8:	5e                   	pop    %esi
f01004e9:	5f                   	pop    %edi
f01004ea:	5d                   	pop    %ebp
f01004eb:	c3                   	ret    

f01004ec <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004ec:	55                   	push   %ebp
f01004ed:	89 e5                	mov    %esp,%ebp
f01004ef:	53                   	push   %ebx
f01004f0:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f3:	ba 64 00 00 00       	mov    $0x64,%edx
f01004f8:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004f9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01004fe:	a8 01                	test   $0x1,%al
f0100500:	0f 84 de 00 00 00    	je     f01005e4 <kbd_proc_data+0xf8>
f0100506:	b2 60                	mov    $0x60,%dl
f0100508:	ec                   	in     (%dx),%al
f0100509:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010050b:	3c e0                	cmp    $0xe0,%al
f010050d:	75 11                	jne    f0100520 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010050f:	83 0d 28 22 23 f0 40 	orl    $0x40,0xf0232228
		return 0;
f0100516:	bb 00 00 00 00       	mov    $0x0,%ebx
f010051b:	e9 c4 00 00 00       	jmp    f01005e4 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100520:	84 c0                	test   %al,%al
f0100522:	79 37                	jns    f010055b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100524:	8b 0d 28 22 23 f0    	mov    0xf0232228,%ecx
f010052a:	89 cb                	mov    %ecx,%ebx
f010052c:	83 e3 40             	and    $0x40,%ebx
f010052f:	83 e0 7f             	and    $0x7f,%eax
f0100532:	85 db                	test   %ebx,%ebx
f0100534:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100537:	0f b6 d2             	movzbl %dl,%edx
f010053a:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f0100541:	83 c8 40             	or     $0x40,%eax
f0100544:	0f b6 c0             	movzbl %al,%eax
f0100547:	f7 d0                	not    %eax
f0100549:	21 c1                	and    %eax,%ecx
f010054b:	89 0d 28 22 23 f0    	mov    %ecx,0xf0232228
		return 0;
f0100551:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100556:	e9 89 00 00 00       	jmp    f01005e4 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010055b:	8b 0d 28 22 23 f0    	mov    0xf0232228,%ecx
f0100561:	f6 c1 40             	test   $0x40,%cl
f0100564:	74 0e                	je     f0100574 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100566:	89 c2                	mov    %eax,%edx
f0100568:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010056b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010056e:	89 0d 28 22 23 f0    	mov    %ecx,0xf0232228
	}

	shift |= shiftcode[data];
f0100574:	0f b6 d2             	movzbl %dl,%edx
f0100577:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f010057e:	0b 05 28 22 23 f0    	or     0xf0232228,%eax
	shift ^= togglecode[data];
f0100584:	0f b6 8a 00 6f 10 f0 	movzbl -0xfef9100(%edx),%ecx
f010058b:	31 c8                	xor    %ecx,%eax
f010058d:	a3 28 22 23 f0       	mov    %eax,0xf0232228

	c = charcode[shift & (CTL | SHIFT)][data];
f0100592:	89 c1                	mov    %eax,%ecx
f0100594:	83 e1 03             	and    $0x3,%ecx
f0100597:	8b 0c 8d 00 70 10 f0 	mov    -0xfef9000(,%ecx,4),%ecx
f010059e:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005a2:	a8 08                	test   $0x8,%al
f01005a4:	74 19                	je     f01005bf <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005a6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005a9:	83 fa 19             	cmp    $0x19,%edx
f01005ac:	77 05                	ja     f01005b3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005ae:	83 eb 20             	sub    $0x20,%ebx
f01005b1:	eb 0c                	jmp    f01005bf <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005b3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01005b6:	8d 53 20             	lea    0x20(%ebx),%edx
f01005b9:	83 f9 19             	cmp    $0x19,%ecx
f01005bc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005bf:	f7 d0                	not    %eax
f01005c1:	a8 06                	test   $0x6,%al
f01005c3:	75 1f                	jne    f01005e4 <kbd_proc_data+0xf8>
f01005c5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005cb:	75 17                	jne    f01005e4 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01005cd:	c7 04 24 c2 6d 10 f0 	movl   $0xf0106dc2,(%esp)
f01005d4:	e8 95 39 00 00       	call   f0103f6e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d9:	ba 92 00 00 00       	mov    $0x92,%edx
f01005de:	b8 03 00 00 00       	mov    $0x3,%eax
f01005e3:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005e4:	89 d8                	mov    %ebx,%eax
f01005e6:	83 c4 14             	add    $0x14,%esp
f01005e9:	5b                   	pop    %ebx
f01005ea:	5d                   	pop    %ebp
f01005eb:	c3                   	ret    

f01005ec <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005ec:	55                   	push   %ebp
f01005ed:	89 e5                	mov    %esp,%ebp
f01005ef:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01005f2:	80 3d 00 20 23 f0 00 	cmpb   $0x0,0xf0232000
f01005f9:	74 0a                	je     f0100605 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01005fb:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f0100600:	e8 d5 fc ff ff       	call   f01002da <cons_intr>
}
f0100605:	c9                   	leave  
f0100606:	c3                   	ret    

f0100607 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
f010060a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010060d:	b8 ec 04 10 f0       	mov    $0xf01004ec,%eax
f0100612:	e8 c3 fc ff ff       	call   f01002da <cons_intr>
}
f0100617:	c9                   	leave  
f0100618:	c3                   	ret    

f0100619 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100619:	55                   	push   %ebp
f010061a:	89 e5                	mov    %esp,%ebp
f010061c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061f:	e8 c8 ff ff ff       	call   f01005ec <serial_intr>
	kbd_intr();
f0100624:	e8 de ff ff ff       	call   f0100607 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100629:	8b 15 20 22 23 f0    	mov    0xf0232220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010062f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100634:	3b 15 24 22 23 f0    	cmp    0xf0232224,%edx
f010063a:	74 1e                	je     f010065a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010063c:	0f b6 82 20 20 23 f0 	movzbl -0xfdcdfe0(%edx),%eax
f0100643:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100646:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010064c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100651:	0f 44 d1             	cmove  %ecx,%edx
f0100654:	89 15 20 22 23 f0    	mov    %edx,0xf0232220
		return c;
	}
	return 0;
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
f010065f:	57                   	push   %edi
f0100660:	56                   	push   %esi
f0100661:	53                   	push   %ebx
f0100662:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100665:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100673:	5a a5 
	if (*cp != 0xA55A) {
f0100675:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100680:	74 11                	je     f0100693 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100682:	c7 05 2c 22 23 f0 b4 	movl   $0x3b4,0xf023222c
f0100689:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100691:	eb 16                	jmp    f01006a9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100693:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069a:	c7 05 2c 22 23 f0 d4 	movl   $0x3d4,0xf023222c
f01006a1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a9:	8b 0d 2c 22 23 f0    	mov    0xf023222c,%ecx
f01006af:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006b4:	89 ca                	mov    %ecx,%edx
f01006b6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ba:	89 da                	mov    %ebx,%edx
f01006bc:	ec                   	in     (%dx),%al
f01006bd:	0f b6 f8             	movzbl %al,%edi
f01006c0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c8:	89 ca                	mov    %ecx,%edx
f01006ca:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cb:	89 da                	mov    %ebx,%edx
f01006cd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ce:	89 35 30 22 23 f0    	mov    %esi,0xf0232230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006d4:	0f b6 d8             	movzbl %al,%ebx
f01006d7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006d9:	66 89 3d 34 22 23 f0 	mov    %di,0xf0232234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006e0:	e8 22 ff ff ff       	call   f0100607 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006e5:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006ec:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f1:	89 04 24             	mov    %eax,(%esp)
f01006f4:	e8 33 37 00 00       	call   f0103e2c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100703:	89 da                	mov    %ebx,%edx
f0100705:	ee                   	out    %al,(%dx)
f0100706:	b2 fb                	mov    $0xfb,%dl
f0100708:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010070d:	ee                   	out    %al,(%dx)
f010070e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100713:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100718:	89 ca                	mov    %ecx,%edx
f010071a:	ee                   	out    %al,(%dx)
f010071b:	b2 f9                	mov    $0xf9,%dl
f010071d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100722:	ee                   	out    %al,(%dx)
f0100723:	b2 fb                	mov    $0xfb,%dl
f0100725:	b8 03 00 00 00       	mov    $0x3,%eax
f010072a:	ee                   	out    %al,(%dx)
f010072b:	b2 fc                	mov    $0xfc,%dl
f010072d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100732:	ee                   	out    %al,(%dx)
f0100733:	b2 f9                	mov    $0xf9,%dl
f0100735:	b8 01 00 00 00       	mov    $0x1,%eax
f010073a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073b:	b2 fd                	mov    $0xfd,%dl
f010073d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073e:	3c ff                	cmp    $0xff,%al
f0100740:	0f 95 c0             	setne  %al
f0100743:	89 c6                	mov    %eax,%esi
f0100745:	a2 00 20 23 f0       	mov    %al,0xf0232000
f010074a:	89 da                	mov    %ebx,%edx
f010074c:	ec                   	in     (%dx),%al
f010074d:	89 ca                	mov    %ecx,%edx
f010074f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100750:	89 f0                	mov    %esi,%eax
f0100752:	84 c0                	test   %al,%al
f0100754:	75 0c                	jne    f0100762 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f0100756:	c7 04 24 ce 6d 10 f0 	movl   $0xf0106dce,(%esp)
f010075d:	e8 0c 38 00 00       	call   f0103f6e <cprintf>
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
f0100773:	e8 9f fb ff ff       	call   f0100317 <cons_putc>
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
f0100780:	e8 94 fe ff ff       	call   f0100619 <cons_getc>
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
	...

f01007a0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007a6:	c7 04 24 10 70 10 f0 	movl   $0xf0107010,(%esp)
f01007ad:	e8 bc 37 00 00       	call   f0103f6e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007b2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007b9:	00 
f01007ba:	c7 04 24 9c 70 10 f0 	movl   $0xf010709c,(%esp)
f01007c1:	e8 a8 37 00 00       	call   f0103f6e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007c6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007cd:	00 
f01007ce:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007d5:	f0 
f01007d6:	c7 04 24 c4 70 10 f0 	movl   $0xf01070c4,(%esp)
f01007dd:	e8 8c 37 00 00       	call   f0103f6e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007e2:	c7 44 24 08 e5 6c 10 	movl   $0x106ce5,0x8(%esp)
f01007e9:	00 
f01007ea:	c7 44 24 04 e5 6c 10 	movl   $0xf0106ce5,0x4(%esp)
f01007f1:	f0 
f01007f2:	c7 04 24 e8 70 10 f0 	movl   $0xf01070e8,(%esp)
f01007f9:	e8 70 37 00 00       	call   f0103f6e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007fe:	c7 44 24 08 18 1b 23 	movl   $0x231b18,0x8(%esp)
f0100805:	00 
f0100806:	c7 44 24 04 18 1b 23 	movl   $0xf0231b18,0x4(%esp)
f010080d:	f0 
f010080e:	c7 04 24 0c 71 10 f0 	movl   $0xf010710c,(%esp)
f0100815:	e8 54 37 00 00       	call   f0103f6e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010081a:	c7 44 24 08 08 40 27 	movl   $0x274008,0x8(%esp)
f0100821:	00 
f0100822:	c7 44 24 04 08 40 27 	movl   $0xf0274008,0x4(%esp)
f0100829:	f0 
f010082a:	c7 04 24 30 71 10 f0 	movl   $0xf0107130,(%esp)
f0100831:	e8 38 37 00 00       	call   f0103f6e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100836:	b8 07 44 27 f0       	mov    $0xf0274407,%eax
f010083b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100840:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100845:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010084b:	85 c0                	test   %eax,%eax
f010084d:	0f 48 c2             	cmovs  %edx,%eax
f0100850:	c1 f8 0a             	sar    $0xa,%eax
f0100853:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100857:	c7 04 24 54 71 10 f0 	movl   $0xf0107154,(%esp)
f010085e:	e8 0b 37 00 00       	call   f0103f6e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100863:	b8 00 00 00 00       	mov    $0x0,%eax
f0100868:	c9                   	leave  
f0100869:	c3                   	ret    

f010086a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010086a:	55                   	push   %ebp
f010086b:	89 e5                	mov    %esp,%ebp
f010086d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100870:	c7 44 24 08 29 70 10 	movl   $0xf0107029,0x8(%esp)
f0100877:	f0 
f0100878:	c7 44 24 04 47 70 10 	movl   $0xf0107047,0x4(%esp)
f010087f:	f0 
f0100880:	c7 04 24 4c 70 10 f0 	movl   $0xf010704c,(%esp)
f0100887:	e8 e2 36 00 00       	call   f0103f6e <cprintf>
f010088c:	c7 44 24 08 80 71 10 	movl   $0xf0107180,0x8(%esp)
f0100893:	f0 
f0100894:	c7 44 24 04 55 70 10 	movl   $0xf0107055,0x4(%esp)
f010089b:	f0 
f010089c:	c7 04 24 4c 70 10 f0 	movl   $0xf010704c,(%esp)
f01008a3:	e8 c6 36 00 00       	call   f0103f6e <cprintf>
	return 0;
}
f01008a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ad:	c9                   	leave  
f01008ae:	c3                   	ret    

f01008af <mon_backtrace>:
	return 0;
}

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
f01008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008c5:	c7 04 24 a8 71 10 f0 	movl   $0xf01071a8,(%esp)
f01008cc:	e8 9d 36 00 00       	call   f0103f6e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008d1:	c7 04 24 cc 71 10 f0 	movl   $0xf01071cc,(%esp)
f01008d8:	e8 91 36 00 00       	call   f0103f6e <cprintf>

	if (tf != NULL)
f01008dd:	85 ff                	test   %edi,%edi
f01008df:	74 08                	je     f01008e9 <monitor+0x30>
		print_trapframe(tf);
f01008e1:	89 3c 24             	mov    %edi,(%esp)
f01008e4:	e8 b4 3c 00 00       	call   f010459d <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01008e9:	c7 04 24 5e 70 10 f0 	movl   $0xf010705e,(%esp)
f01008f0:	e8 2b 54 00 00       	call   f0105d20 <readline>
f01008f5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008f7:	85 c0                	test   %eax,%eax
f01008f9:	74 ee                	je     f01008e9 <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008fb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100902:	be 00 00 00 00       	mov    $0x0,%esi
f0100907:	eb 06                	jmp    f010090f <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100909:	c6 03 00             	movb   $0x0,(%ebx)
f010090c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010090f:	0f b6 03             	movzbl (%ebx),%eax
f0100912:	84 c0                	test   %al,%al
f0100914:	74 63                	je     f0100979 <monitor+0xc0>
f0100916:	0f be c0             	movsbl %al,%eax
f0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091d:	c7 04 24 62 70 10 f0 	movl   $0xf0107062,(%esp)
f0100924:	e8 0d 56 00 00       	call   f0105f36 <strchr>
f0100929:	85 c0                	test   %eax,%eax
f010092b:	75 dc                	jne    f0100909 <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f010092d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100930:	74 47                	je     f0100979 <monitor+0xc0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100932:	83 fe 0f             	cmp    $0xf,%esi
f0100935:	75 16                	jne    f010094d <monitor+0x94>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100937:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010093e:	00 
f010093f:	c7 04 24 67 70 10 f0 	movl   $0xf0107067,(%esp)
f0100946:	e8 23 36 00 00       	call   f0103f6e <cprintf>
f010094b:	eb 9c                	jmp    f01008e9 <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f010094d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100951:	83 c6 01             	add    $0x1,%esi
f0100954:	eb 03                	jmp    f0100959 <monitor+0xa0>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100956:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100959:	0f b6 03             	movzbl (%ebx),%eax
f010095c:	84 c0                	test   %al,%al
f010095e:	74 af                	je     f010090f <monitor+0x56>
f0100960:	0f be c0             	movsbl %al,%eax
f0100963:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100967:	c7 04 24 62 70 10 f0 	movl   $0xf0107062,(%esp)
f010096e:	e8 c3 55 00 00       	call   f0105f36 <strchr>
f0100973:	85 c0                	test   %eax,%eax
f0100975:	74 df                	je     f0100956 <monitor+0x9d>
f0100977:	eb 96                	jmp    f010090f <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100979:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100980:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100981:	85 f6                	test   %esi,%esi
f0100983:	0f 84 60 ff ff ff    	je     f01008e9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100989:	c7 44 24 04 47 70 10 	movl   $0xf0107047,0x4(%esp)
f0100990:	f0 
f0100991:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100994:	89 04 24             	mov    %eax,(%esp)
f0100997:	e8 3b 55 00 00       	call   f0105ed7 <strcmp>
f010099c:	ba 00 00 00 00       	mov    $0x0,%edx
f01009a1:	85 c0                	test   %eax,%eax
f01009a3:	74 1c                	je     f01009c1 <monitor+0x108>
f01009a5:	c7 44 24 04 55 70 10 	movl   $0xf0107055,0x4(%esp)
f01009ac:	f0 
f01009ad:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b0:	89 04 24             	mov    %eax,(%esp)
f01009b3:	e8 1f 55 00 00       	call   f0105ed7 <strcmp>
f01009b8:	85 c0                	test   %eax,%eax
f01009ba:	75 28                	jne    f01009e4 <monitor+0x12b>
f01009bc:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01009c1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01009c4:	01 c2                	add    %eax,%edx
f01009c6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009ca:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d1:	89 34 24             	mov    %esi,(%esp)
f01009d4:	ff 14 95 fc 71 10 f0 	call   *-0xfef8e04(,%edx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009db:	85 c0                	test   %eax,%eax
f01009dd:	78 1d                	js     f01009fc <monitor+0x143>
f01009df:	e9 05 ff ff ff       	jmp    f01008e9 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009e4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009eb:	c7 04 24 84 70 10 f0 	movl   $0xf0107084,(%esp)
f01009f2:	e8 77 35 00 00       	call   f0103f6e <cprintf>
f01009f7:	e9 ed fe ff ff       	jmp    f01008e9 <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009fc:	83 c4 5c             	add    $0x5c,%esp
f01009ff:	5b                   	pop    %ebx
f0100a00:	5e                   	pop    %esi
f0100a01:	5f                   	pop    %edi
f0100a02:	5d                   	pop    %ebp
f0100a03:	c3                   	ret    

f0100a04 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a04:	55                   	push   %ebp
f0100a05:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a07:	83 3d 3c 22 23 f0 00 	cmpl   $0x0,0xf023223c
f0100a0e:	75 11                	jne    f0100a21 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a10:	ba 07 50 27 f0       	mov    $0xf0275007,%edx
f0100a15:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a1b:	89 15 3c 22 23 f0    	mov    %edx,0xf023223c
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
		return nextfree;
f0100a21:	8b 15 3c 22 23 f0    	mov    0xf023223c,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a27:	85 c0                	test   %eax,%eax
f0100a29:	74 17                	je     f0100a42 <boot_alloc+0x3e>
		return nextfree;
	result = nextfree;
f0100a2b:	8b 15 3c 22 23 f0    	mov    0xf023223c,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a31:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a3d:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
	
	// return the head address of the alloc pages;
	return result;
}
f0100a42:	89 d0                	mov    %edx,%eax
f0100a44:	5d                   	pop    %ebp
f0100a45:	c3                   	ret    

f0100a46 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a46:	55                   	push   %ebp
f0100a47:	89 e5                	mov    %esp,%ebp
f0100a49:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a4c:	89 d1                	mov    %edx,%ecx
f0100a4e:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a51:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a59:	f6 c1 01             	test   $0x1,%cl
f0100a5c:	74 57                	je     f0100ab5 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a5e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a64:	89 c8                	mov    %ecx,%eax
f0100a66:	c1 e8 0c             	shr    $0xc,%eax
f0100a69:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0100a6f:	72 20                	jb     f0100a91 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a75:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0100a7c:	f0 
f0100a7d:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0100a84:	00 
f0100a85:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100a8c:	e8 af f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100a91:	c1 ea 0c             	shr    $0xc,%edx
f0100a94:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a9a:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100aa1:	89 c2                	mov    %eax,%edx
f0100aa3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100aa6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aab:	85 d2                	test   %edx,%edx
f0100aad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ab2:	0f 44 c2             	cmove  %edx,%eax
}
f0100ab5:	c9                   	leave  
f0100ab6:	c3                   	ret    

f0100ab7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ab7:	55                   	push   %ebp
f0100ab8:	89 e5                	mov    %esp,%ebp
f0100aba:	83 ec 18             	sub    $0x18,%esp
f0100abd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ac0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ac3:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac5:	89 04 24             	mov    %eax,(%esp)
f0100ac8:	e8 37 33 00 00       	call   f0103e04 <mc146818_read>
f0100acd:	89 c6                	mov    %eax,%esi
f0100acf:	83 c3 01             	add    $0x1,%ebx
f0100ad2:	89 1c 24             	mov    %ebx,(%esp)
f0100ad5:	e8 2a 33 00 00       	call   f0103e04 <mc146818_read>
f0100ada:	c1 e0 08             	shl    $0x8,%eax
f0100add:	09 f0                	or     %esi,%eax
}
f0100adf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100ae2:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100ae5:	89 ec                	mov    %ebp,%esp
f0100ae7:	5d                   	pop    %ebp
f0100ae8:	c3                   	ret    

f0100ae9 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ae9:	55                   	push   %ebp
f0100aea:	89 e5                	mov    %esp,%ebp
f0100aec:	57                   	push   %edi
f0100aed:	56                   	push   %esi
f0100aee:	53                   	push   %ebx
f0100aef:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100af2:	3c 01                	cmp    $0x1,%al
f0100af4:	19 f6                	sbb    %esi,%esi
f0100af6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100afc:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100aff:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
f0100b05:	85 d2                	test   %edx,%edx
f0100b07:	75 1c                	jne    f0100b25 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100b09:	c7 44 24 08 0c 72 10 	movl   $0xf010720c,0x8(%esp)
f0100b10:	f0 
f0100b11:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0100b18:	00 
f0100b19:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100b20:	e8 1b f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100b25:	84 c0                	test   %al,%al
f0100b27:	74 4b                	je     f0100b74 <check_page_free_list+0x8b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b29:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b32:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b35:	89 d0                	mov    %edx,%eax
f0100b37:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100b3d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b40:	c1 e8 16             	shr    $0x16,%eax
f0100b43:	39 c6                	cmp    %eax,%esi
f0100b45:	0f 96 c0             	setbe  %al
f0100b48:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b4b:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100b4f:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b51:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b55:	8b 12                	mov    (%edx),%edx
f0100b57:	85 d2                	test   %edx,%edx
f0100b59:	75 da                	jne    f0100b35 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b64:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b6a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b6f:	a3 40 22 23 f0       	mov    %eax,0xf0232240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b74:	8b 1d 40 22 23 f0    	mov    0xf0232240,%ebx
f0100b7a:	eb 63                	jmp    f0100bdf <check_page_free_list+0xf6>
f0100b7c:	89 d8                	mov    %ebx,%eax
f0100b7e:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100b84:	c1 f8 03             	sar    $0x3,%eax
f0100b87:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b8a:	89 c2                	mov    %eax,%edx
f0100b8c:	c1 ea 16             	shr    $0x16,%edx
f0100b8f:	39 d6                	cmp    %edx,%esi
f0100b91:	76 4a                	jbe    f0100bdd <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b93:	89 c2                	mov    %eax,%edx
f0100b95:	c1 ea 0c             	shr    $0xc,%edx
f0100b98:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100b9e:	72 20                	jb     f0100bc0 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ba4:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0100bab:	f0 
f0100bac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bb3:	00 
f0100bb4:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0100bbb:	e8 80 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bc0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100bc7:	00 
f0100bc8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100bcf:	00 
	return (void *)(pa + KERNBASE);
f0100bd0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd5:	89 04 24             	mov    %eax,(%esp)
f0100bd8:	e8 96 53 00 00       	call   f0105f73 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bdd:	8b 1b                	mov    (%ebx),%ebx
f0100bdf:	85 db                	test   %ebx,%ebx
f0100be1:	75 99                	jne    f0100b7c <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100be3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be8:	e8 17 fe ff ff       	call   f0100a04 <boot_alloc>
f0100bed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf0:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bf6:	8b 0d 90 2e 23 f0    	mov    0xf0232e90,%ecx
		assert(pp < pages + npages);
f0100bfc:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0100c01:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c04:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c0a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c0d:	be 00 00 00 00       	mov    $0x0,%esi
f0100c12:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c15:	e9 ca 01 00 00       	jmp    f0100de4 <check_page_free_list+0x2fb>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c1a:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100c1d:	73 24                	jae    f0100c43 <check_page_free_list+0x15a>
f0100c1f:	c7 44 24 0c 43 7b 10 	movl   $0xf0107b43,0xc(%esp)
f0100c26:	f0 
f0100c27:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100c2e:	f0 
f0100c2f:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0100c36:	00 
f0100c37:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100c3e:	e8 fd f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c43:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c46:	72 24                	jb     f0100c6c <check_page_free_list+0x183>
f0100c48:	c7 44 24 0c 64 7b 10 	movl   $0xf0107b64,0xc(%esp)
f0100c4f:	f0 
f0100c50:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100c57:	f0 
f0100c58:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0100c5f:	00 
f0100c60:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100c67:	e8 d4 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c6c:	89 d0                	mov    %edx,%eax
f0100c6e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c71:	a8 07                	test   $0x7,%al
f0100c73:	74 24                	je     f0100c99 <check_page_free_list+0x1b0>
f0100c75:	c7 44 24 0c 30 72 10 	movl   $0xf0107230,0xc(%esp)
f0100c7c:	f0 
f0100c7d:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100c84:	f0 
f0100c85:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0100c8c:	00 
f0100c8d:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100c94:	e8 a7 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c99:	c1 f8 03             	sar    $0x3,%eax
f0100c9c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c9f:	85 c0                	test   %eax,%eax
f0100ca1:	75 24                	jne    f0100cc7 <check_page_free_list+0x1de>
f0100ca3:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100cb2:	f0 
f0100cb3:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0100cba:	00 
f0100cbb:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100cc2:	e8 79 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ccc:	75 24                	jne    f0100cf2 <check_page_free_list+0x209>
f0100cce:	c7 44 24 0c 89 7b 10 	movl   $0xf0107b89,0xc(%esp)
f0100cd5:	f0 
f0100cd6:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100cdd:	f0 
f0100cde:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0100ce5:	00 
f0100ce6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100ced:	e8 4e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cf2:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cf7:	75 24                	jne    f0100d1d <check_page_free_list+0x234>
f0100cf9:	c7 44 24 0c 64 72 10 	movl   $0xf0107264,0xc(%esp)
f0100d00:	f0 
f0100d01:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100d08:	f0 
f0100d09:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0100d10:	00 
f0100d11:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100d18:	e8 23 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d1d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d22:	75 24                	jne    f0100d48 <check_page_free_list+0x25f>
f0100d24:	c7 44 24 0c a2 7b 10 	movl   $0xf0107ba2,0xc(%esp)
f0100d2b:	f0 
f0100d2c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100d33:	f0 
f0100d34:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0100d3b:	00 
f0100d3c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100d43:	e8 f8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d48:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d4d:	76 59                	jbe    f0100da8 <check_page_free_list+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d4f:	89 c1                	mov    %eax,%ecx
f0100d51:	c1 e9 0c             	shr    $0xc,%ecx
f0100d54:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100d57:	77 20                	ja     f0100d79 <check_page_free_list+0x290>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d5d:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0100d64:	f0 
f0100d65:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d6c:	00 
f0100d6d:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0100d74:	e8 c7 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d79:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d7f:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100d82:	76 24                	jbe    f0100da8 <check_page_free_list+0x2bf>
f0100d84:	c7 44 24 0c 88 72 10 	movl   $0xf0107288,0xc(%esp)
f0100d8b:	f0 
f0100d8c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100d93:	f0 
f0100d94:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0100d9b:	00 
f0100d9c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100da3:	e8 98 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100da8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dad:	75 24                	jne    f0100dd3 <check_page_free_list+0x2ea>
f0100daf:	c7 44 24 0c bc 7b 10 	movl   $0xf0107bbc,0xc(%esp)
f0100db6:	f0 
f0100db7:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100dbe:	f0 
f0100dbf:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0100dc6:	00 
f0100dc7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100dce:	e8 6d f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100dd3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dd8:	77 05                	ja     f0100ddf <check_page_free_list+0x2f6>
			++nfree_basemem;
f0100dda:	83 c6 01             	add    $0x1,%esi
f0100ddd:	eb 03                	jmp    f0100de2 <check_page_free_list+0x2f9>
		else
			++nfree_extmem;
f0100ddf:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de2:	8b 12                	mov    (%edx),%edx
f0100de4:	85 d2                	test   %edx,%edx
f0100de6:	0f 85 2e fe ff ff    	jne    f0100c1a <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dec:	85 f6                	test   %esi,%esi
f0100dee:	7f 24                	jg     f0100e14 <check_page_free_list+0x32b>
f0100df0:	c7 44 24 0c d9 7b 10 	movl   $0xf0107bd9,0xc(%esp)
f0100df7:	f0 
f0100df8:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100dff:	f0 
f0100e00:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0100e07:	00 
f0100e08:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100e0f:	e8 2c f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e14:	85 db                	test   %ebx,%ebx
f0100e16:	7f 24                	jg     f0100e3c <check_page_free_list+0x353>
f0100e18:	c7 44 24 0c eb 7b 10 	movl   $0xf0107beb,0xc(%esp)
f0100e1f:	f0 
f0100e20:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0100e27:	f0 
f0100e28:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100e2f:	00 
f0100e30:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100e37:	e8 04 f2 ff ff       	call   f0100040 <_panic>
}
f0100e3c:	83 c4 4c             	add    $0x4c,%esp
f0100e3f:	5b                   	pop    %ebx
f0100e40:	5e                   	pop    %esi
f0100e41:	5f                   	pop    %edi
f0100e42:	5d                   	pop    %ebp
f0100e43:	c3                   	ret    

f0100e44 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e44:	55                   	push   %ebp
f0100e45:	89 e5                	mov    %esp,%ebp
f0100e47:	56                   	push   %esi
f0100e48:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e49:	be 00 00 00 00       	mov    $0x0,%esi
f0100e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e53:	e9 e1 00 00 00       	jmp    f0100f39 <page_init+0xf5>
		if(i == 0)
f0100e58:	85 db                	test   %ebx,%ebx
f0100e5a:	75 16                	jne    f0100e72 <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100e5c:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0100e61:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100e67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e6d:	e9 c1 00 00 00       	jmp    f0100f33 <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100e72:	83 fb 07             	cmp    $0x7,%ebx
f0100e75:	75 17                	jne    f0100e8e <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100e77:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0100e7c:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100e82:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100e89:	e9 a5 00 00 00       	jmp    f0100f33 <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100e8e:	3b 1d 38 22 23 f0    	cmp    0xf0232238,%ebx
f0100e94:	73 25                	jae    f0100ebb <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100e96:	89 f0                	mov    %esi,%eax
f0100e98:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100e9e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100ea4:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
f0100eaa:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100eac:	89 f0                	mov    %esi,%eax
f0100eae:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100eb4:	a3 40 22 23 f0       	mov    %eax,0xf0232240
f0100eb9:	eb 78                	jmp    f0100f33 <page_init+0xef>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100ebb:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100ec1:	83 f8 5f             	cmp    $0x5f,%eax
f0100ec4:	77 16                	ja     f0100edc <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100ec6:	89 f0                	mov    %esi,%eax
f0100ec8:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100ece:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ed4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100eda:	eb 57                	jmp    f0100f33 <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100edc:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100ee2:	76 2c                	jbe    f0100f10 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100ee4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee9:	e8 16 fb ff ff       	call   f0100a04 <boot_alloc>
f0100eee:	05 00 00 00 10       	add    $0x10000000,%eax
f0100ef3:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100ef6:	39 c3                	cmp    %eax,%ebx
f0100ef8:	73 16                	jae    f0100f10 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100efa:	89 f0                	mov    %esi,%eax
f0100efc:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100f02:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f0e:	eb 23                	jmp    f0100f33 <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f10:	89 f0                	mov    %esi,%eax
f0100f12:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100f18:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f1e:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
f0100f24:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f26:	89 f0                	mov    %esi,%eax
f0100f28:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0100f2e:	a3 40 22 23 f0       	mov    %eax,0xf0232240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f33:	83 c3 01             	add    $0x1,%ebx
f0100f36:	83 c6 08             	add    $0x8,%esi
f0100f39:	3b 1d 88 2e 23 f0    	cmp    0xf0232e88,%ebx
f0100f3f:	0f 82 13 ff ff ff    	jb     f0100e58 <page_init+0x14>
			page_free_list = &pages[i];
		}

	}

}
f0100f45:	5b                   	pop    %ebx
f0100f46:	5e                   	pop    %esi
f0100f47:	5d                   	pop    %ebp
f0100f48:	c3                   	ret    

f0100f49 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f49:	55                   	push   %ebp
f0100f4a:	89 e5                	mov    %esp,%ebp
f0100f4c:	53                   	push   %ebx
f0100f4d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100f50:	8b 1d 40 22 23 f0    	mov    0xf0232240,%ebx
f0100f56:	85 db                	test   %ebx,%ebx
f0100f58:	74 6b                	je     f0100fc5 <page_alloc+0x7c>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100f5a:	8b 03                	mov    (%ebx),%eax
f0100f5c:	a3 40 22 23 f0       	mov    %eax,0xf0232240
	page->pp_link = 0;
f0100f61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f67:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f6b:	74 58                	je     f0100fc5 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f6d:	89 d8                	mov    %ebx,%eax
f0100f6f:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100f75:	c1 f8 03             	sar    $0x3,%eax
f0100f78:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f7b:	89 c2                	mov    %eax,%edx
f0100f7d:	c1 ea 0c             	shr    $0xc,%edx
f0100f80:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100f86:	72 20                	jb     f0100fa8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f88:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f8c:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0100f93:	f0 
f0100f94:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f9b:	00 
f0100f9c:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0100fa3:	e8 98 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100fa8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100faf:	00 
f0100fb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fb7:	00 
	return (void *)(pa + KERNBASE);
f0100fb8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fbd:	89 04 24             	mov    %eax,(%esp)
f0100fc0:	e8 ae 4f 00 00       	call   f0105f73 <memset>
	return page;
	return 0;
}
f0100fc5:	89 d8                	mov    %ebx,%eax
f0100fc7:	83 c4 14             	add    $0x14,%esp
f0100fca:	5b                   	pop    %ebx
f0100fcb:	5d                   	pop    %ebp
f0100fcc:	c3                   	ret    

f0100fcd <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fcd:	55                   	push   %ebp
f0100fce:	89 e5                	mov    %esp,%ebp
f0100fd0:	83 ec 18             	sub    $0x18,%esp
f0100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0100fd6:	83 38 00             	cmpl   $0x0,(%eax)
f0100fd9:	75 07                	jne    f0100fe2 <page_free+0x15>
f0100fdb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fe0:	74 1c                	je     f0100ffe <page_free+0x31>
		panic("page_free is not right");
f0100fe2:	c7 44 24 08 fc 7b 10 	movl   $0xf0107bfc,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0100ff9:	e8 42 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0100ffe:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
f0101004:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101006:	a3 40 22 23 f0       	mov    %eax,0xf0232240
	return; 
}
f010100b:	c9                   	leave  
f010100c:	c3                   	ret    

f010100d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
f0101010:	83 ec 18             	sub    $0x18,%esp
f0101013:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101016:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010101a:	83 ea 01             	sub    $0x1,%edx
f010101d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101021:	66 85 d2             	test   %dx,%dx
f0101024:	75 08                	jne    f010102e <page_decref+0x21>
		page_free(pp);
f0101026:	89 04 24             	mov    %eax,(%esp)
f0101029:	e8 9f ff ff ff       	call   f0100fcd <page_free>
}
f010102e:	c9                   	leave  
f010102f:	c3                   	ret    

f0101030 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101030:	55                   	push   %ebp
f0101031:	89 e5                	mov    %esp,%ebp
f0101033:	56                   	push   %esi
f0101034:	53                   	push   %ebx
f0101035:	83 ec 10             	sub    $0x10,%esp
f0101038:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f010103b:	89 f3                	mov    %esi,%ebx
f010103d:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f0101040:	c1 e3 02             	shl    $0x2,%ebx
f0101043:	03 5d 08             	add    0x8(%ebp),%ebx
f0101046:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101049:	0f 94 c0             	sete   %al
f010104c:	75 06                	jne    f0101054 <pgdir_walk+0x24>
f010104e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101052:	74 70                	je     f01010c4 <pgdir_walk+0x94>
		return NULL;
	if(pgdir[pdeIndex] == 0){
f0101054:	84 c0                	test   %al,%al
f0101056:	74 26                	je     f010107e <pgdir_walk+0x4e>
		struct PageInfo* page = page_alloc(1);
f0101058:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010105f:	e8 e5 fe ff ff       	call   f0100f49 <page_alloc>
		if(page == NULL)
f0101064:	85 c0                	test   %eax,%eax
f0101066:	74 63                	je     f01010cb <pgdir_walk+0x9b>
			return NULL;
		page->pp_ref++;
f0101068:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010106d:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101073:	c1 f8 03             	sar    $0x3,%eax
f0101076:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0101079:	83 c8 07             	or     $0x7,%eax
f010107c:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f010107e:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f0101080:	25 00 fc ff ff       	and    $0xfffffc00,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101085:	89 c2                	mov    %eax,%edx
f0101087:	c1 ea 0c             	shr    $0xc,%edx
f010108a:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101090:	72 20                	jb     f01010b2 <pgdir_walk+0x82>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101092:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101096:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f010109d:	f0 
f010109e:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
f01010a5:	00 
f01010a6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01010ad:	e8 8e ef ff ff       	call   f0100040 <_panic>
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01010b2:	c1 ee 0a             	shr    $0xa,%esi
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
f01010b5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010bb:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
	return pte;
f01010c2:	eb 0c                	jmp    f01010d0 <pgdir_walk+0xa0>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f01010c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c9:	eb 05                	jmp    f01010d0 <pgdir_walk+0xa0>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f01010cb:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f01010d0:	83 c4 10             	add    $0x10,%esp
f01010d3:	5b                   	pop    %ebx
f01010d4:	5e                   	pop    %esi
f01010d5:	5d                   	pop    %ebp
f01010d6:	c3                   	ret    

f01010d7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010d7:	55                   	push   %ebp
f01010d8:	89 e5                	mov    %esp,%ebp
f01010da:	57                   	push   %edi
f01010db:	56                   	push   %esi
f01010dc:	53                   	push   %ebx
f01010dd:	83 ec 2c             	sub    $0x2c,%esp
f01010e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010e3:	89 d6                	mov    %edx,%esi
f01010e5:	89 cb                	mov    %ecx,%ebx
f01010e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	while(size)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f01010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010ed:	83 c8 01             	or     $0x1,%eax
f01010f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f01010f3:	eb 34                	jmp    f0101129 <boot_map_region+0x52>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f01010f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010fc:	00 
f01010fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101104:	89 04 24             	mov    %eax,(%esp)
f0101107:	e8 24 ff ff ff       	call   f0101030 <pgdir_walk>
		if(pte == NULL)
f010110c:	85 c0                	test   %eax,%eax
f010110e:	74 1d                	je     f010112d <boot_map_region+0x56>
			return;
		*pte= pa |perm|PTE_P;
f0101110:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101113:	09 fa                	or     %edi,%edx
f0101115:	89 10                	mov    %edx,(%eax)
		
		size -= PGSIZE;
f0101117:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
		pa  += PGSIZE;
f010111d:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va  += PGSIZE;
f0101123:	81 c6 00 10 00 00    	add    $0x1000,%esi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101129:	85 db                	test   %ebx,%ebx
f010112b:	75 c8                	jne    f01010f5 <boot_map_region+0x1e>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f010112d:	83 c4 2c             	add    $0x2c,%esp
f0101130:	5b                   	pop    %ebx
f0101131:	5e                   	pop    %esi
f0101132:	5f                   	pop    %edi
f0101133:	5d                   	pop    %ebp
f0101134:	c3                   	ret    

f0101135 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101135:	55                   	push   %ebp
f0101136:	89 e5                	mov    %esp,%ebp
f0101138:	53                   	push   %ebx
f0101139:	83 ec 14             	sub    $0x14,%esp
f010113c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f010113f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101146:	00 
f0101147:	8b 45 0c             	mov    0xc(%ebp),%eax
f010114a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010114e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101151:	89 04 24             	mov    %eax,(%esp)
f0101154:	e8 d7 fe ff ff       	call   f0101030 <pgdir_walk>
	if(pte == NULL)
f0101159:	85 c0                	test   %eax,%eax
f010115b:	74 42                	je     f010119f <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f010115d:	8b 10                	mov    (%eax),%edx
f010115f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f0101165:	85 db                	test   %ebx,%ebx
f0101167:	74 02                	je     f010116b <page_lookup+0x36>
		*pte_store = pte ;
f0101169:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116b:	89 d0                	mov    %edx,%eax
f010116d:	c1 e8 0c             	shr    $0xc,%eax
f0101170:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0101176:	72 1c                	jb     f0101194 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101178:	c7 44 24 08 d0 72 10 	movl   $0xf01072d0,0x8(%esp)
f010117f:	f0 
f0101180:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101187:	00 
f0101188:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f010118f:	e8 ac ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101194:	c1 e0 03             	shl    $0x3,%eax
f0101197:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
	return pa2page(pa);	
f010119d:	eb 05                	jmp    f01011a4 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f010119f:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f01011a4:	83 c4 14             	add    $0x14,%esp
f01011a7:	5b                   	pop    %ebx
f01011a8:	5d                   	pop    %ebp
f01011a9:	c3                   	ret    

f01011aa <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011aa:	55                   	push   %ebp
f01011ab:	89 e5                	mov    %esp,%ebp
f01011ad:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011b0:	e8 1f 54 00 00       	call   f01065d4 <cpunum>
f01011b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01011b8:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f01011bf:	74 16                	je     f01011d7 <tlb_invalidate+0x2d>
f01011c1:	e8 0e 54 00 00       	call   f01065d4 <cpunum>
f01011c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01011c9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01011cf:	8b 55 08             	mov    0x8(%ebp),%edx
f01011d2:	39 50 60             	cmp    %edx,0x60(%eax)
f01011d5:	75 06                	jne    f01011dd <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011da:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011dd:	c9                   	leave  
f01011de:	c3                   	ret    

f01011df <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011df:	55                   	push   %ebp
f01011e0:	89 e5                	mov    %esp,%ebp
f01011e2:	83 ec 28             	sub    $0x28,%esp
f01011e5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01011e8:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01011eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f01011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011fc:	89 34 24             	mov    %esi,(%esp)
f01011ff:	e8 31 ff ff ff       	call   f0101135 <page_lookup>
	if(page == 0)
f0101204:	85 c0                	test   %eax,%eax
f0101206:	74 2d                	je     f0101235 <page_remove+0x56>
		return;
	*pte = 0;
f0101208:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010120b:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101211:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101215:	83 ea 01             	sub    $0x1,%edx
f0101218:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f010121c:	66 85 d2             	test   %dx,%dx
f010121f:	75 08                	jne    f0101229 <page_remove+0x4a>
		page_free(page);
f0101221:	89 04 24             	mov    %eax,(%esp)
f0101224:	e8 a4 fd ff ff       	call   f0100fcd <page_free>
	tlb_invalidate(pgdir, va);
f0101229:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010122d:	89 34 24             	mov    %esi,(%esp)
f0101230:	e8 75 ff ff ff       	call   f01011aa <tlb_invalidate>
}
f0101235:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101238:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010123b:	89 ec                	mov    %ebp,%esp
f010123d:	5d                   	pop    %ebp
f010123e:	c3                   	ret    

f010123f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010123f:	55                   	push   %ebp
f0101240:	89 e5                	mov    %esp,%ebp
f0101242:	83 ec 28             	sub    $0x28,%esp
f0101245:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101248:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010124b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101251:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101254:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010125b:	00 
f010125c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101260:	8b 45 08             	mov    0x8(%ebp),%eax
f0101263:	89 04 24             	mov    %eax,(%esp)
f0101266:	e8 c5 fd ff ff       	call   f0101030 <pgdir_walk>
f010126b:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f010126d:	85 c0                	test   %eax,%eax
f010126f:	74 5a                	je     f01012cb <page_insert+0x8c>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f0101271:	8b 00                	mov    (%eax),%eax
f0101273:	89 c1                	mov    %eax,%ecx
f0101275:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010127b:	89 da                	mov    %ebx,%edx
f010127d:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101283:	c1 fa 03             	sar    $0x3,%edx
f0101286:	c1 e2 0c             	shl    $0xc,%edx
f0101289:	39 d1                	cmp    %edx,%ecx
f010128b:	75 07                	jne    f0101294 <page_insert+0x55>
		pp->pp_ref--;
f010128d:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101292:	eb 13                	jmp    f01012a7 <page_insert+0x68>
	
	else if(*pte != 0)
f0101294:	85 c0                	test   %eax,%eax
f0101296:	74 0f                	je     f01012a7 <page_insert+0x68>
		page_remove(pgdir, va);
f0101298:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010129c:	8b 45 08             	mov    0x8(%ebp),%eax
f010129f:	89 04 24             	mov    %eax,(%esp)
f01012a2:	e8 38 ff ff ff       	call   f01011df <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01012a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012aa:	83 c8 01             	or     $0x1,%eax
f01012ad:	89 da                	mov    %ebx,%edx
f01012af:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01012b5:	c1 fa 03             	sar    $0x3,%edx
f01012b8:	c1 e2 0c             	shl    $0xc,%edx
f01012bb:	09 d0                	or     %edx,%eax
f01012bd:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01012bf:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01012c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c9:	eb 05                	jmp    f01012d0 <page_insert+0x91>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f01012cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f01012d0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01012d3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01012d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01012d9:	89 ec                	mov    %ebp,%esp
f01012db:	5d                   	pop    %ebp
f01012dc:	c3                   	ret    

f01012dd <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012dd:	55                   	push   %ebp
f01012de:	89 e5                	mov    %esp,%ebp
f01012e0:	53                   	push   %ebx
f01012e1:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f01012e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012e7:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01012ed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	if(size + base >= MMIOLIM)
f01012f3:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01012f9:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012fc:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101301:	76 1c                	jbe    f010131f <mmio_map_region+0x42>
		panic("mmio_map_region not implemented");
f0101303:	c7 44 24 08 f0 72 10 	movl   $0xf01072f0,0x8(%esp)
f010130a:	f0 
f010130b:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0101312:	00 
f0101313:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010131a:	e8 21 ed ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010131f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101326:	00 
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
	pa = ROUNDDOWN(pa, PGSIZE);
f0101327:	8b 45 08             	mov    0x8(%ebp),%eax
f010132a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if(size + base >= MMIOLIM)
		panic("mmio_map_region not implemented");
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010132f:	89 04 24             	mov    %eax,(%esp)
f0101332:	89 d9                	mov    %ebx,%ecx
f0101334:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101339:	e8 99 fd ff ff       	call   f01010d7 <boot_map_region>
	uintptr_t ret = base;
f010133e:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base +size;
f0101343:	01 c3                	add    %eax,%ebx
f0101345:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) ret;

}
f010134b:	83 c4 14             	add    $0x14,%esp
f010134e:	5b                   	pop    %ebx
f010134f:	5d                   	pop    %ebp
f0101350:	c3                   	ret    

f0101351 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101351:	55                   	push   %ebp
f0101352:	89 e5                	mov    %esp,%ebp
f0101354:	57                   	push   %edi
f0101355:	56                   	push   %esi
f0101356:	53                   	push   %ebx
f0101357:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010135a:	b8 15 00 00 00       	mov    $0x15,%eax
f010135f:	e8 53 f7 ff ff       	call   f0100ab7 <nvram_read>
f0101364:	c1 e0 0a             	shl    $0xa,%eax
f0101367:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010136d:	85 c0                	test   %eax,%eax
f010136f:	0f 48 c2             	cmovs  %edx,%eax
f0101372:	c1 f8 0c             	sar    $0xc,%eax
f0101375:	a3 38 22 23 f0       	mov    %eax,0xf0232238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010137a:	b8 17 00 00 00       	mov    $0x17,%eax
f010137f:	e8 33 f7 ff ff       	call   f0100ab7 <nvram_read>
f0101384:	c1 e0 0a             	shl    $0xa,%eax
f0101387:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010138d:	85 c0                	test   %eax,%eax
f010138f:	0f 48 c2             	cmovs  %edx,%eax
f0101392:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101395:	85 c0                	test   %eax,%eax
f0101397:	74 0e                	je     f01013a7 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101399:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010139f:	89 15 88 2e 23 f0    	mov    %edx,0xf0232e88
f01013a5:	eb 0c                	jmp    f01013b3 <mem_init+0x62>
	else
		npages = npages_basemem;
f01013a7:	8b 15 38 22 23 f0    	mov    0xf0232238,%edx
f01013ad:	89 15 88 2e 23 f0    	mov    %edx,0xf0232e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01013b3:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b6:	c1 e8 0a             	shr    $0xa,%eax
f01013b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01013bd:	a1 38 22 23 f0       	mov    0xf0232238,%eax
f01013c2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013c5:	c1 e8 0a             	shr    $0xa,%eax
f01013c8:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01013cc:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f01013d1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013d4:	c1 e8 0a             	shr    $0xa,%eax
f01013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013db:	c7 04 24 10 73 10 f0 	movl   $0xf0107310,(%esp)
f01013e2:	e8 87 2b 00 00       	call   f0103f6e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013e7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ec:	e8 13 f6 ff ff       	call   f0100a04 <boot_alloc>
f01013f1:	a3 8c 2e 23 f0       	mov    %eax,0xf0232e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013fd:	00 
f01013fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101405:	00 
f0101406:	89 04 24             	mov    %eax,(%esp)
f0101409:	e8 65 4b 00 00       	call   f0105f73 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010140e:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101413:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101418:	77 20                	ja     f010143a <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010141a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010141e:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101435:	e8 06 ec ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010143a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101440:	83 ca 05             	or     $0x5,%edx
f0101443:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f0101449:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f010144e:	c1 e0 03             	shl    $0x3,%eax
f0101451:	e8 ae f5 ff ff       	call   f0100a04 <boot_alloc>
f0101456:	a3 90 2e 23 f0       	mov    %eax,0xf0232e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f010145b:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f0101461:	c1 e2 03             	shl    $0x3,%edx
f0101464:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101468:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010146f:	00 
f0101470:	89 04 24             	mov    %eax,(%esp)
f0101473:	e8 fb 4a 00 00       	call   f0105f73 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101478:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010147d:	e8 82 f5 ff ff       	call   f0100a04 <boot_alloc>
f0101482:	a3 48 22 23 f0       	mov    %eax,0xf0232248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101487:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010148e:	00 
f010148f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101496:	00 
f0101497:	89 04 24             	mov    %eax,(%esp)
f010149a:	e8 d4 4a 00 00       	call   f0105f73 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010149f:	e8 a0 f9 ff ff       	call   f0100e44 <page_init>

	check_page_free_list(1);
f01014a4:	b8 01 00 00 00       	mov    $0x1,%eax
f01014a9:	e8 3b f6 ff ff       	call   f0100ae9 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014ae:	83 3d 90 2e 23 f0 00 	cmpl   $0x0,0xf0232e90
f01014b5:	75 1c                	jne    f01014d3 <mem_init+0x182>
		panic("'pages' is a null pointer!");
f01014b7:	c7 44 24 08 13 7c 10 	movl   $0xf0107c13,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01014ce:	e8 6d eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014d3:	a1 40 22 23 f0       	mov    0xf0232240,%eax
f01014d8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014dd:	eb 05                	jmp    f01014e4 <mem_init+0x193>
		++nfree;
f01014df:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014e2:	8b 00                	mov    (%eax),%eax
f01014e4:	85 c0                	test   %eax,%eax
f01014e6:	75 f7                	jne    f01014df <mem_init+0x18e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ef:	e8 55 fa ff ff       	call   f0100f49 <page_alloc>
f01014f4:	89 c6                	mov    %eax,%esi
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	75 24                	jne    f010151e <mem_init+0x1cd>
f01014fa:	c7 44 24 0c 2e 7c 10 	movl   $0xf0107c2e,0xc(%esp)
f0101501:	f0 
f0101502:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101509:	f0 
f010150a:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101511:	00 
f0101512:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101519:	e8 22 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010151e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101525:	e8 1f fa ff ff       	call   f0100f49 <page_alloc>
f010152a:	89 c7                	mov    %eax,%edi
f010152c:	85 c0                	test   %eax,%eax
f010152e:	75 24                	jne    f0101554 <mem_init+0x203>
f0101530:	c7 44 24 0c 44 7c 10 	movl   $0xf0107c44,0xc(%esp)
f0101537:	f0 
f0101538:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010153f:	f0 
f0101540:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101547:	00 
f0101548:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010154f:	e8 ec ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101554:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155b:	e8 e9 f9 ff ff       	call   f0100f49 <page_alloc>
f0101560:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101563:	85 c0                	test   %eax,%eax
f0101565:	75 24                	jne    f010158b <mem_init+0x23a>
f0101567:	c7 44 24 0c 5a 7c 10 	movl   $0xf0107c5a,0xc(%esp)
f010156e:	f0 
f010156f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101576:	f0 
f0101577:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f010157e:	00 
f010157f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101586:	e8 b5 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010158b:	39 fe                	cmp    %edi,%esi
f010158d:	75 24                	jne    f01015b3 <mem_init+0x262>
f010158f:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f0101596:	f0 
f0101597:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010159e:	f0 
f010159f:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01015a6:	00 
f01015a7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01015ae:	e8 8d ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b3:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01015b6:	74 05                	je     f01015bd <mem_init+0x26c>
f01015b8:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015bb:	75 24                	jne    f01015e1 <mem_init+0x290>
f01015bd:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f01015c4:	f0 
f01015c5:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01015cc:	f0 
f01015cd:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f01015d4:	00 
f01015d5:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01015dc:	e8 5f ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015e1:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015e7:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f01015ec:	c1 e0 0c             	shl    $0xc,%eax
f01015ef:	89 f1                	mov    %esi,%ecx
f01015f1:	29 d1                	sub    %edx,%ecx
f01015f3:	c1 f9 03             	sar    $0x3,%ecx
f01015f6:	c1 e1 0c             	shl    $0xc,%ecx
f01015f9:	39 c1                	cmp    %eax,%ecx
f01015fb:	72 24                	jb     f0101621 <mem_init+0x2d0>
f01015fd:	c7 44 24 0c 82 7c 10 	movl   $0xf0107c82,0xc(%esp)
f0101604:	f0 
f0101605:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010160c:	f0 
f010160d:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101614:	00 
f0101615:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010161c:	e8 1f ea ff ff       	call   f0100040 <_panic>
f0101621:	89 f9                	mov    %edi,%ecx
f0101623:	29 d1                	sub    %edx,%ecx
f0101625:	c1 f9 03             	sar    $0x3,%ecx
f0101628:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010162b:	39 c8                	cmp    %ecx,%eax
f010162d:	77 24                	ja     f0101653 <mem_init+0x302>
f010162f:	c7 44 24 0c 9f 7c 10 	movl   $0xf0107c9f,0xc(%esp)
f0101636:	f0 
f0101637:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010163e:	f0 
f010163f:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101646:	00 
f0101647:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010164e:	e8 ed e9 ff ff       	call   f0100040 <_panic>
f0101653:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101656:	29 d1                	sub    %edx,%ecx
f0101658:	89 ca                	mov    %ecx,%edx
f010165a:	c1 fa 03             	sar    $0x3,%edx
f010165d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101660:	39 d0                	cmp    %edx,%eax
f0101662:	77 24                	ja     f0101688 <mem_init+0x337>
f0101664:	c7 44 24 0c bc 7c 10 	movl   $0xf0107cbc,0xc(%esp)
f010166b:	f0 
f010166c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101673:	f0 
f0101674:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010167b:	00 
f010167c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101683:	e8 b8 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101688:	a1 40 22 23 f0       	mov    0xf0232240,%eax
f010168d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101690:	c7 05 40 22 23 f0 00 	movl   $0x0,0xf0232240
f0101697:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010169a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016a1:	e8 a3 f8 ff ff       	call   f0100f49 <page_alloc>
f01016a6:	85 c0                	test   %eax,%eax
f01016a8:	74 24                	je     f01016ce <mem_init+0x37d>
f01016aa:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f01016b1:	f0 
f01016b2:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01016b9:	f0 
f01016ba:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f01016c1:	00 
f01016c2:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01016c9:	e8 72 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016ce:	89 34 24             	mov    %esi,(%esp)
f01016d1:	e8 f7 f8 ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f01016d6:	89 3c 24             	mov    %edi,(%esp)
f01016d9:	e8 ef f8 ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f01016de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016e1:	89 04 24             	mov    %eax,(%esp)
f01016e4:	e8 e4 f8 ff ff       	call   f0100fcd <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016f0:	e8 54 f8 ff ff       	call   f0100f49 <page_alloc>
f01016f5:	89 c6                	mov    %eax,%esi
f01016f7:	85 c0                	test   %eax,%eax
f01016f9:	75 24                	jne    f010171f <mem_init+0x3ce>
f01016fb:	c7 44 24 0c 2e 7c 10 	movl   $0xf0107c2e,0xc(%esp)
f0101702:	f0 
f0101703:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010170a:	f0 
f010170b:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101712:	00 
f0101713:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010171a:	e8 21 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010171f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101726:	e8 1e f8 ff ff       	call   f0100f49 <page_alloc>
f010172b:	89 c7                	mov    %eax,%edi
f010172d:	85 c0                	test   %eax,%eax
f010172f:	75 24                	jne    f0101755 <mem_init+0x404>
f0101731:	c7 44 24 0c 44 7c 10 	movl   $0xf0107c44,0xc(%esp)
f0101738:	f0 
f0101739:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101740:	f0 
f0101741:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101748:	00 
f0101749:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101750:	e8 eb e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101755:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010175c:	e8 e8 f7 ff ff       	call   f0100f49 <page_alloc>
f0101761:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101764:	85 c0                	test   %eax,%eax
f0101766:	75 24                	jne    f010178c <mem_init+0x43b>
f0101768:	c7 44 24 0c 5a 7c 10 	movl   $0xf0107c5a,0xc(%esp)
f010176f:	f0 
f0101770:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101777:	f0 
f0101778:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010177f:	00 
f0101780:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101787:	e8 b4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010178c:	39 fe                	cmp    %edi,%esi
f010178e:	75 24                	jne    f01017b4 <mem_init+0x463>
f0101790:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f0101797:	f0 
f0101798:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010179f:	f0 
f01017a0:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01017a7:	00 
f01017a8:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01017af:	e8 8c e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017b7:	74 05                	je     f01017be <mem_init+0x46d>
f01017b9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017bc:	75 24                	jne    f01017e2 <mem_init+0x491>
f01017be:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f01017c5:	f0 
f01017c6:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01017cd:	f0 
f01017ce:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f01017d5:	00 
f01017d6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01017dd:	e8 5e e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017e9:	e8 5b f7 ff ff       	call   f0100f49 <page_alloc>
f01017ee:	85 c0                	test   %eax,%eax
f01017f0:	74 24                	je     f0101816 <mem_init+0x4c5>
f01017f2:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f01017f9:	f0 
f01017fa:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101801:	f0 
f0101802:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101809:	00 
f010180a:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101811:	e8 2a e8 ff ff       	call   f0100040 <_panic>
f0101816:	89 f0                	mov    %esi,%eax
f0101818:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f010181e:	c1 f8 03             	sar    $0x3,%eax
f0101821:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101824:	89 c2                	mov    %eax,%edx
f0101826:	c1 ea 0c             	shr    $0xc,%edx
f0101829:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f010182f:	72 20                	jb     f0101851 <mem_init+0x500>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101831:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101835:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f010183c:	f0 
f010183d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101844:	00 
f0101845:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f010184c:	e8 ef e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101851:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101858:	00 
f0101859:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101860:	00 
	return (void *)(pa + KERNBASE);
f0101861:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101866:	89 04 24             	mov    %eax,(%esp)
f0101869:	e8 05 47 00 00       	call   f0105f73 <memset>
	page_free(pp0);
f010186e:	89 34 24             	mov    %esi,(%esp)
f0101871:	e8 57 f7 ff ff       	call   f0100fcd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101876:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010187d:	e8 c7 f6 ff ff       	call   f0100f49 <page_alloc>
f0101882:	85 c0                	test   %eax,%eax
f0101884:	75 24                	jne    f01018aa <mem_init+0x559>
f0101886:	c7 44 24 0c e8 7c 10 	movl   $0xf0107ce8,0xc(%esp)
f010188d:	f0 
f010188e:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01018a5:	e8 96 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018aa:	39 c6                	cmp    %eax,%esi
f01018ac:	74 24                	je     f01018d2 <mem_init+0x581>
f01018ae:	c7 44 24 0c 06 7d 10 	movl   $0xf0107d06,0xc(%esp)
f01018b5:	f0 
f01018b6:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01018bd:	f0 
f01018be:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01018c5:	00 
f01018c6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01018cd:	e8 6e e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018d2:	89 f2                	mov    %esi,%edx
f01018d4:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01018da:	c1 fa 03             	sar    $0x3,%edx
f01018dd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018e0:	89 d0                	mov    %edx,%eax
f01018e2:	c1 e8 0c             	shr    $0xc,%eax
f01018e5:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f01018eb:	72 20                	jb     f010190d <mem_init+0x5bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018f1:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f01018f8:	f0 
f01018f9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101900:	00 
f0101901:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0101908:	e8 33 e7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010190d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101913:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101919:	80 38 00             	cmpb   $0x0,(%eax)
f010191c:	74 24                	je     f0101942 <mem_init+0x5f1>
f010191e:	c7 44 24 0c 16 7d 10 	movl   $0xf0107d16,0xc(%esp)
f0101925:	f0 
f0101926:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010192d:	f0 
f010192e:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101935:	00 
f0101936:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010193d:	e8 fe e6 ff ff       	call   f0100040 <_panic>
f0101942:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101945:	39 d0                	cmp    %edx,%eax
f0101947:	75 d0                	jne    f0101919 <mem_init+0x5c8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101949:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010194c:	89 15 40 22 23 f0    	mov    %edx,0xf0232240

	// free the pages we took
	page_free(pp0);
f0101952:	89 34 24             	mov    %esi,(%esp)
f0101955:	e8 73 f6 ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f010195a:	89 3c 24             	mov    %edi,(%esp)
f010195d:	e8 6b f6 ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f0101962:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101965:	89 04 24             	mov    %eax,(%esp)
f0101968:	e8 60 f6 ff ff       	call   f0100fcd <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010196d:	a1 40 22 23 f0       	mov    0xf0232240,%eax
f0101972:	eb 05                	jmp    f0101979 <mem_init+0x628>
		--nfree;
f0101974:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101977:	8b 00                	mov    (%eax),%eax
f0101979:	85 c0                	test   %eax,%eax
f010197b:	75 f7                	jne    f0101974 <mem_init+0x623>
		--nfree;
	assert(nfree == 0);
f010197d:	85 db                	test   %ebx,%ebx
f010197f:	74 24                	je     f01019a5 <mem_init+0x654>
f0101981:	c7 44 24 0c 20 7d 10 	movl   $0xf0107d20,0xc(%esp)
f0101988:	f0 
f0101989:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101990:	f0 
f0101991:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0101998:	00 
f0101999:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01019a0:	e8 9b e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019a5:	c7 04 24 6c 73 10 f0 	movl   $0xf010736c,(%esp)
f01019ac:	e8 bd 25 00 00       	call   f0103f6e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019b8:	e8 8c f5 ff ff       	call   f0100f49 <page_alloc>
f01019bd:	89 c7                	mov    %eax,%edi
f01019bf:	85 c0                	test   %eax,%eax
f01019c1:	75 24                	jne    f01019e7 <mem_init+0x696>
f01019c3:	c7 44 24 0c 2e 7c 10 	movl   $0xf0107c2e,0xc(%esp)
f01019ca:	f0 
f01019cb:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01019d2:	f0 
f01019d3:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01019da:	00 
f01019db:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01019e2:	e8 59 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019ee:	e8 56 f5 ff ff       	call   f0100f49 <page_alloc>
f01019f3:	89 c6                	mov    %eax,%esi
f01019f5:	85 c0                	test   %eax,%eax
f01019f7:	75 24                	jne    f0101a1d <mem_init+0x6cc>
f01019f9:	c7 44 24 0c 44 7c 10 	movl   $0xf0107c44,0xc(%esp)
f0101a00:	f0 
f0101a01:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101a08:	f0 
f0101a09:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101a10:	00 
f0101a11:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101a18:	e8 23 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a24:	e8 20 f5 ff ff       	call   f0100f49 <page_alloc>
f0101a29:	89 c3                	mov    %eax,%ebx
f0101a2b:	85 c0                	test   %eax,%eax
f0101a2d:	75 24                	jne    f0101a53 <mem_init+0x702>
f0101a2f:	c7 44 24 0c 5a 7c 10 	movl   $0xf0107c5a,0xc(%esp)
f0101a36:	f0 
f0101a37:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101a46:	00 
f0101a47:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101a4e:	e8 ed e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a53:	39 f7                	cmp    %esi,%edi
f0101a55:	75 24                	jne    f0101a7b <mem_init+0x72a>
f0101a57:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f0101a5e:	f0 
f0101a5f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101a66:	f0 
f0101a67:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0101a6e:	00 
f0101a6f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101a76:	e8 c5 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a7b:	39 c6                	cmp    %eax,%esi
f0101a7d:	74 04                	je     f0101a83 <mem_init+0x732>
f0101a7f:	39 c7                	cmp    %eax,%edi
f0101a81:	75 24                	jne    f0101aa7 <mem_init+0x756>
f0101a83:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f0101a8a:	f0 
f0101a8b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101a92:	f0 
f0101a93:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101a9a:	00 
f0101a9b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa7:	8b 15 40 22 23 f0    	mov    0xf0232240,%edx
f0101aad:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101ab0:	c7 05 40 22 23 f0 00 	movl   $0x0,0xf0232240
f0101ab7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101aba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ac1:	e8 83 f4 ff ff       	call   f0100f49 <page_alloc>
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	74 24                	je     f0101aee <mem_init+0x79d>
f0101aca:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f0101ad1:	f0 
f0101ad2:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101ad9:	f0 
f0101ada:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101ae1:	00 
f0101ae2:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101ae9:	e8 52 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101af1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101af5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101afc:	00 
f0101afd:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101b02:	89 04 24             	mov    %eax,(%esp)
f0101b05:	e8 2b f6 ff ff       	call   f0101135 <page_lookup>
f0101b0a:	85 c0                	test   %eax,%eax
f0101b0c:	74 24                	je     f0101b32 <mem_init+0x7e1>
f0101b0e:	c7 44 24 0c 8c 73 10 	movl   $0xf010738c,0xc(%esp)
f0101b15:	f0 
f0101b16:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101b25:	00 
f0101b26:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101b2d:	e8 0e e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b32:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b39:	00 
f0101b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b41:	00 
f0101b42:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b46:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101b4b:	89 04 24             	mov    %eax,(%esp)
f0101b4e:	e8 ec f6 ff ff       	call   f010123f <page_insert>
f0101b53:	85 c0                	test   %eax,%eax
f0101b55:	78 24                	js     f0101b7b <mem_init+0x82a>
f0101b57:	c7 44 24 0c c4 73 10 	movl   $0xf01073c4,0xc(%esp)
f0101b5e:	f0 
f0101b5f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101b66:	f0 
f0101b67:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101b6e:	00 
f0101b6f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101b76:	e8 c5 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b7b:	89 3c 24             	mov    %edi,(%esp)
f0101b7e:	e8 4a f4 ff ff       	call   f0100fcd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b83:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b8a:	00 
f0101b8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b92:	00 
f0101b93:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b97:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101b9c:	89 04 24             	mov    %eax,(%esp)
f0101b9f:	e8 9b f6 ff ff       	call   f010123f <page_insert>
f0101ba4:	85 c0                	test   %eax,%eax
f0101ba6:	74 24                	je     f0101bcc <mem_init+0x87b>
f0101ba8:	c7 44 24 0c f4 73 10 	movl   $0xf01073f4,0xc(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101bb7:	f0 
f0101bb8:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101bbf:	00 
f0101bc0:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101bc7:	e8 74 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bcc:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0101bd2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bd5:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0101bda:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bdd:	8b 11                	mov    (%ecx),%edx
f0101bdf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101be5:	89 f8                	mov    %edi,%eax
f0101be7:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101bea:	c1 f8 03             	sar    $0x3,%eax
f0101bed:	c1 e0 0c             	shl    $0xc,%eax
f0101bf0:	39 c2                	cmp    %eax,%edx
f0101bf2:	74 24                	je     f0101c18 <mem_init+0x8c7>
f0101bf4:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101c13:	e8 28 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c18:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c20:	e8 21 ee ff ff       	call   f0100a46 <check_va2pa>
f0101c25:	89 f2                	mov    %esi,%edx
f0101c27:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c2a:	c1 fa 03             	sar    $0x3,%edx
f0101c2d:	c1 e2 0c             	shl    $0xc,%edx
f0101c30:	39 d0                	cmp    %edx,%eax
f0101c32:	74 24                	je     f0101c58 <mem_init+0x907>
f0101c34:	c7 44 24 0c 4c 74 10 	movl   $0xf010744c,0xc(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101c43:	f0 
f0101c44:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101c4b:	00 
f0101c4c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101c53:	e8 e8 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c58:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c5d:	74 24                	je     f0101c83 <mem_init+0x932>
f0101c5f:	c7 44 24 0c 2b 7d 10 	movl   $0xf0107d2b,0xc(%esp)
f0101c66:	f0 
f0101c67:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101c6e:	f0 
f0101c6f:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101c76:	00 
f0101c77:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101c7e:	e8 bd e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c83:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c88:	74 24                	je     f0101cae <mem_init+0x95d>
f0101c8a:	c7 44 24 0c 3c 7d 10 	movl   $0xf0107d3c,0xc(%esp)
f0101c91:	f0 
f0101c92:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101c99:	f0 
f0101c9a:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0101ca1:	00 
f0101ca2:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cae:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cb5:	00 
f0101cb6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cbd:	00 
f0101cbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cc2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101cc5:	89 14 24             	mov    %edx,(%esp)
f0101cc8:	e8 72 f5 ff ff       	call   f010123f <page_insert>
f0101ccd:	85 c0                	test   %eax,%eax
f0101ccf:	74 24                	je     f0101cf5 <mem_init+0x9a4>
f0101cd1:	c7 44 24 0c 7c 74 10 	movl   $0xf010747c,0xc(%esp)
f0101cd8:	f0 
f0101cd9:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101ce0:	f0 
f0101ce1:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0101ce8:	00 
f0101ce9:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101cf0:	e8 4b e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cf5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cfa:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101cff:	e8 42 ed ff ff       	call   f0100a46 <check_va2pa>
f0101d04:	89 da                	mov    %ebx,%edx
f0101d06:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101d0c:	c1 fa 03             	sar    $0x3,%edx
f0101d0f:	c1 e2 0c             	shl    $0xc,%edx
f0101d12:	39 d0                	cmp    %edx,%eax
f0101d14:	74 24                	je     f0101d3a <mem_init+0x9e9>
f0101d16:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f0101d1d:	f0 
f0101d1e:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101d25:	f0 
f0101d26:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101d2d:	00 
f0101d2e:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101d35:	e8 06 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d3a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d3f:	74 24                	je     f0101d65 <mem_init+0xa14>
f0101d41:	c7 44 24 0c 4d 7d 10 	movl   $0xf0107d4d,0xc(%esp)
f0101d48:	f0 
f0101d49:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101d58:	00 
f0101d59:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101d60:	e8 db e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d6c:	e8 d8 f1 ff ff       	call   f0100f49 <page_alloc>
f0101d71:	85 c0                	test   %eax,%eax
f0101d73:	74 24                	je     f0101d99 <mem_init+0xa48>
f0101d75:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f0101d7c:	f0 
f0101d7d:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101d84:	f0 
f0101d85:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101d8c:	00 
f0101d8d:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101d94:	e8 a7 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d99:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101da0:	00 
f0101da1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101da8:	00 
f0101da9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dad:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101db2:	89 04 24             	mov    %eax,(%esp)
f0101db5:	e8 85 f4 ff ff       	call   f010123f <page_insert>
f0101dba:	85 c0                	test   %eax,%eax
f0101dbc:	74 24                	je     f0101de2 <mem_init+0xa91>
f0101dbe:	c7 44 24 0c 7c 74 10 	movl   $0xf010747c,0xc(%esp)
f0101dc5:	f0 
f0101dc6:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101dcd:	f0 
f0101dce:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0101dd5:	00 
f0101dd6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101ddd:	e8 5e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101de2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de7:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101dec:	e8 55 ec ff ff       	call   f0100a46 <check_va2pa>
f0101df1:	89 da                	mov    %ebx,%edx
f0101df3:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101df9:	c1 fa 03             	sar    $0x3,%edx
f0101dfc:	c1 e2 0c             	shl    $0xc,%edx
f0101dff:	39 d0                	cmp    %edx,%eax
f0101e01:	74 24                	je     f0101e27 <mem_init+0xad6>
f0101e03:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f0101e0a:	f0 
f0101e0b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101e12:	f0 
f0101e13:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0101e1a:	00 
f0101e1b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101e22:	e8 19 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e27:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e2c:	74 24                	je     f0101e52 <mem_init+0xb01>
f0101e2e:	c7 44 24 0c 4d 7d 10 	movl   $0xf0107d4d,0xc(%esp)
f0101e35:	f0 
f0101e36:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101e3d:	f0 
f0101e3e:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0101e45:	00 
f0101e46:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101e4d:	e8 ee e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e59:	e8 eb f0 ff ff       	call   f0100f49 <page_alloc>
f0101e5e:	85 c0                	test   %eax,%eax
f0101e60:	74 24                	je     f0101e86 <mem_init+0xb35>
f0101e62:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101e71:	f0 
f0101e72:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0101e79:	00 
f0101e7a:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101e81:	e8 ba e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e86:	8b 15 8c 2e 23 f0    	mov    0xf0232e8c,%edx
f0101e8c:	8b 02                	mov    (%edx),%eax
f0101e8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e93:	89 c1                	mov    %eax,%ecx
f0101e95:	c1 e9 0c             	shr    $0xc,%ecx
f0101e98:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f0101e9e:	72 20                	jb     f0101ec0 <mem_init+0xb6f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ea0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ea4:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0101eab:	f0 
f0101eac:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0101eb3:	00 
f0101eb4:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101ebb:	e8 80 e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101ec0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ec5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ec8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ecf:	00 
f0101ed0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ed7:	00 
f0101ed8:	89 14 24             	mov    %edx,(%esp)
f0101edb:	e8 50 f1 ff ff       	call   f0101030 <pgdir_walk>
f0101ee0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ee3:	83 c2 04             	add    $0x4,%edx
f0101ee6:	39 d0                	cmp    %edx,%eax
f0101ee8:	74 24                	je     f0101f0e <mem_init+0xbbd>
f0101eea:	c7 44 24 0c e8 74 10 	movl   $0xf01074e8,0xc(%esp)
f0101ef1:	f0 
f0101ef2:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101ef9:	f0 
f0101efa:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0101f01:	00 
f0101f02:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f0e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f15:	00 
f0101f16:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f1d:	00 
f0101f1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f22:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101f27:	89 04 24             	mov    %eax,(%esp)
f0101f2a:	e8 10 f3 ff ff       	call   f010123f <page_insert>
f0101f2f:	85 c0                	test   %eax,%eax
f0101f31:	74 24                	je     f0101f57 <mem_init+0xc06>
f0101f33:	c7 44 24 0c 28 75 10 	movl   $0xf0107528,0xc(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101f42:	f0 
f0101f43:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0101f4a:	00 
f0101f4b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f57:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0101f5d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f65:	89 c8                	mov    %ecx,%eax
f0101f67:	e8 da ea ff ff       	call   f0100a46 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f6c:	89 da                	mov    %ebx,%edx
f0101f6e:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101f74:	c1 fa 03             	sar    $0x3,%edx
f0101f77:	c1 e2 0c             	shl    $0xc,%edx
f0101f7a:	39 d0                	cmp    %edx,%eax
f0101f7c:	74 24                	je     f0101fa2 <mem_init+0xc51>
f0101f7e:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f0101f85:	f0 
f0101f86:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101f8d:	f0 
f0101f8e:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0101f95:	00 
f0101f96:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101f9d:	e8 9e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fa2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fa7:	74 24                	je     f0101fcd <mem_init+0xc7c>
f0101fa9:	c7 44 24 0c 4d 7d 10 	movl   $0xf0107d4d,0xc(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101fb8:	f0 
f0101fb9:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0101fc0:	00 
f0101fc1:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0101fc8:	e8 73 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fd4:	00 
f0101fd5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fdc:	00 
f0101fdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe0:	89 04 24             	mov    %eax,(%esp)
f0101fe3:	e8 48 f0 ff ff       	call   f0101030 <pgdir_walk>
f0101fe8:	f6 00 04             	testb  $0x4,(%eax)
f0101feb:	75 24                	jne    f0102011 <mem_init+0xcc0>
f0101fed:	c7 44 24 0c 68 75 10 	movl   $0xf0107568,0xc(%esp)
f0101ff4:	f0 
f0101ff5:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0101ffc:	f0 
f0101ffd:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102004:	00 
f0102005:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010200c:	e8 2f e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102011:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102016:	f6 00 04             	testb  $0x4,(%eax)
f0102019:	75 24                	jne    f010203f <mem_init+0xcee>
f010201b:	c7 44 24 0c 5e 7d 10 	movl   $0xf0107d5e,0xc(%esp)
f0102022:	f0 
f0102023:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010202a:	f0 
f010202b:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102032:	00 
f0102033:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010203a:	e8 01 e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010203f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102046:	00 
f0102047:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010204e:	00 
f010204f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102053:	89 04 24             	mov    %eax,(%esp)
f0102056:	e8 e4 f1 ff ff       	call   f010123f <page_insert>
f010205b:	85 c0                	test   %eax,%eax
f010205d:	74 24                	je     f0102083 <mem_init+0xd32>
f010205f:	c7 44 24 0c 7c 74 10 	movl   $0xf010747c,0xc(%esp)
f0102066:	f0 
f0102067:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010206e:	f0 
f010206f:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102076:	00 
f0102077:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010207e:	e8 bd df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102083:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010208a:	00 
f010208b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102092:	00 
f0102093:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102098:	89 04 24             	mov    %eax,(%esp)
f010209b:	e8 90 ef ff ff       	call   f0101030 <pgdir_walk>
f01020a0:	f6 00 02             	testb  $0x2,(%eax)
f01020a3:	75 24                	jne    f01020c9 <mem_init+0xd78>
f01020a5:	c7 44 24 0c 9c 75 10 	movl   $0xf010759c,0xc(%esp)
f01020ac:	f0 
f01020ad:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01020b4:	f0 
f01020b5:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f01020bc:	00 
f01020bd:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01020c4:	e8 77 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020d0:	00 
f01020d1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020d8:	00 
f01020d9:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01020de:	89 04 24             	mov    %eax,(%esp)
f01020e1:	e8 4a ef ff ff       	call   f0101030 <pgdir_walk>
f01020e6:	f6 00 04             	testb  $0x4,(%eax)
f01020e9:	74 24                	je     f010210f <mem_init+0xdbe>
f01020eb:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f01020f2:	f0 
f01020f3:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01020fa:	f0 
f01020fb:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102102:	00 
f0102103:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010210a:	e8 31 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010210f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102116:	00 
f0102117:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010211e:	00 
f010211f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102123:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102128:	89 04 24             	mov    %eax,(%esp)
f010212b:	e8 0f f1 ff ff       	call   f010123f <page_insert>
f0102130:	85 c0                	test   %eax,%eax
f0102132:	78 24                	js     f0102158 <mem_init+0xe07>
f0102134:	c7 44 24 0c 08 76 10 	movl   $0xf0107608,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102153:	e8 e8 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102158:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010215f:	00 
f0102160:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102167:	00 
f0102168:	89 74 24 04          	mov    %esi,0x4(%esp)
f010216c:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102171:	89 04 24             	mov    %eax,(%esp)
f0102174:	e8 c6 f0 ff ff       	call   f010123f <page_insert>
f0102179:	85 c0                	test   %eax,%eax
f010217b:	74 24                	je     f01021a1 <mem_init+0xe50>
f010217d:	c7 44 24 0c 40 76 10 	movl   $0xf0107640,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010219c:	e8 9f de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021a8:	00 
f01021a9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021b0:	00 
f01021b1:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01021b6:	89 04 24             	mov    %eax,(%esp)
f01021b9:	e8 72 ee ff ff       	call   f0101030 <pgdir_walk>
f01021be:	f6 00 04             	testb  $0x4,(%eax)
f01021c1:	74 24                	je     f01021e7 <mem_init+0xe96>
f01021c3:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f01021ca:	f0 
f01021cb:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01021d2:	f0 
f01021d3:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01021da:	00 
f01021db:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01021e2:	e8 59 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021e7:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01021ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01021f4:	e8 4d e8 ff ff       	call   f0100a46 <check_va2pa>
f01021f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021fc:	89 f0                	mov    %esi,%eax
f01021fe:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102204:	c1 f8 03             	sar    $0x3,%eax
f0102207:	c1 e0 0c             	shl    $0xc,%eax
f010220a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010220d:	74 24                	je     f0102233 <mem_init+0xee2>
f010220f:	c7 44 24 0c 7c 76 10 	movl   $0xf010767c,0xc(%esp)
f0102216:	f0 
f0102217:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010221e:	f0 
f010221f:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102226:	00 
f0102227:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102233:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010223b:	e8 06 e8 ff ff       	call   f0100a46 <check_va2pa>
f0102240:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102243:	74 24                	je     f0102269 <mem_init+0xf18>
f0102245:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f010224c:	f0 
f010224d:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102254:	f0 
f0102255:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010225c:	00 
f010225d:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102264:	e8 d7 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102269:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010226e:	74 24                	je     f0102294 <mem_init+0xf43>
f0102270:	c7 44 24 0c 74 7d 10 	movl   $0xf0107d74,0xc(%esp)
f0102277:	f0 
f0102278:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010227f:	f0 
f0102280:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102287:	00 
f0102288:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010228f:	e8 ac dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102294:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102299:	74 24                	je     f01022bf <mem_init+0xf6e>
f010229b:	c7 44 24 0c 85 7d 10 	movl   $0xf0107d85,0xc(%esp)
f01022a2:	f0 
f01022a3:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f01022b2:	00 
f01022b3:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01022ba:	e8 81 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022c6:	e8 7e ec ff ff       	call   f0100f49 <page_alloc>
f01022cb:	85 c0                	test   %eax,%eax
f01022cd:	74 04                	je     f01022d3 <mem_init+0xf82>
f01022cf:	39 c3                	cmp    %eax,%ebx
f01022d1:	74 24                	je     f01022f7 <mem_init+0xfa6>
f01022d3:	c7 44 24 0c d8 76 10 	movl   $0xf01076d8,0xc(%esp)
f01022da:	f0 
f01022db:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01022ea:	00 
f01022eb:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01022f2:	e8 49 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022fe:	00 
f01022ff:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102304:	89 04 24             	mov    %eax,(%esp)
f0102307:	e8 d3 ee ff ff       	call   f01011df <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010230c:	8b 15 8c 2e 23 f0    	mov    0xf0232e8c,%edx
f0102312:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102315:	ba 00 00 00 00       	mov    $0x0,%edx
f010231a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010231d:	e8 24 e7 ff ff       	call   f0100a46 <check_va2pa>
f0102322:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102325:	74 24                	je     f010234b <mem_init+0xffa>
f0102327:	c7 44 24 0c fc 76 10 	movl   $0xf01076fc,0xc(%esp)
f010232e:	f0 
f010232f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102336:	f0 
f0102337:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010233e:	00 
f010233f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102346:	e8 f5 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010234b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102350:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102353:	e8 ee e6 ff ff       	call   f0100a46 <check_va2pa>
f0102358:	89 f2                	mov    %esi,%edx
f010235a:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102360:	c1 fa 03             	sar    $0x3,%edx
f0102363:	c1 e2 0c             	shl    $0xc,%edx
f0102366:	39 d0                	cmp    %edx,%eax
f0102368:	74 24                	je     f010238e <mem_init+0x103d>
f010236a:	c7 44 24 0c a8 76 10 	movl   $0xf01076a8,0xc(%esp)
f0102371:	f0 
f0102372:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102379:	f0 
f010237a:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0102381:	00 
f0102382:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102389:	e8 b2 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010238e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102393:	74 24                	je     f01023b9 <mem_init+0x1068>
f0102395:	c7 44 24 0c 2b 7d 10 	movl   $0xf0107d2b,0xc(%esp)
f010239c:	f0 
f010239d:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01023a4:	f0 
f01023a5:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01023ac:	00 
f01023ad:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01023b4:	e8 87 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023b9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023be:	74 24                	je     f01023e4 <mem_init+0x1093>
f01023c0:	c7 44 24 0c 85 7d 10 	movl   $0xf0107d85,0xc(%esp)
f01023c7:	f0 
f01023c8:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01023cf:	f0 
f01023d0:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f01023d7:	00 
f01023d8:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01023df:	e8 5c dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01023e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01023eb:	00 
f01023ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023f3:	00 
f01023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023fb:	89 0c 24             	mov    %ecx,(%esp)
f01023fe:	e8 3c ee ff ff       	call   f010123f <page_insert>
f0102403:	85 c0                	test   %eax,%eax
f0102405:	74 24                	je     f010242b <mem_init+0x10da>
f0102407:	c7 44 24 0c 20 77 10 	movl   $0xf0107720,0xc(%esp)
f010240e:	f0 
f010240f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102416:	f0 
f0102417:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f010241e:	00 
f010241f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102426:	e8 15 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010242b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102430:	75 24                	jne    f0102456 <mem_init+0x1105>
f0102432:	c7 44 24 0c 96 7d 10 	movl   $0xf0107d96,0xc(%esp)
f0102439:	f0 
f010243a:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102441:	f0 
f0102442:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102449:	00 
f010244a:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102451:	e8 ea db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102456:	83 3e 00             	cmpl   $0x0,(%esi)
f0102459:	74 24                	je     f010247f <mem_init+0x112e>
f010245b:	c7 44 24 0c a2 7d 10 	movl   $0xf0107da2,0xc(%esp)
f0102462:	f0 
f0102463:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010246a:	f0 
f010246b:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102472:	00 
f0102473:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010247f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102486:	00 
f0102487:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010248c:	89 04 24             	mov    %eax,(%esp)
f010248f:	e8 4b ed ff ff       	call   f01011df <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102494:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102499:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010249c:	ba 00 00 00 00       	mov    $0x0,%edx
f01024a1:	e8 a0 e5 ff ff       	call   f0100a46 <check_va2pa>
f01024a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024a9:	74 24                	je     f01024cf <mem_init+0x117e>
f01024ab:	c7 44 24 0c fc 76 10 	movl   $0xf01076fc,0xc(%esp)
f01024b2:	f0 
f01024b3:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01024c2:	00 
f01024c3:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01024ca:	e8 71 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024cf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024d7:	e8 6a e5 ff ff       	call   f0100a46 <check_va2pa>
f01024dc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024df:	74 24                	je     f0102505 <mem_init+0x11b4>
f01024e1:	c7 44 24 0c 58 77 10 	movl   $0xf0107758,0xc(%esp)
f01024e8:	f0 
f01024e9:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01024f0:	f0 
f01024f1:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01024f8:	00 
f01024f9:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102500:	e8 3b db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102505:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010250a:	74 24                	je     f0102530 <mem_init+0x11df>
f010250c:	c7 44 24 0c b7 7d 10 	movl   $0xf0107db7,0xc(%esp)
f0102513:	f0 
f0102514:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010251b:	f0 
f010251c:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102523:	00 
f0102524:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010252b:	e8 10 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102530:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102535:	74 24                	je     f010255b <mem_init+0x120a>
f0102537:	c7 44 24 0c 85 7d 10 	movl   $0xf0107d85,0xc(%esp)
f010253e:	f0 
f010253f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102546:	f0 
f0102547:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010254e:	00 
f010254f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102556:	e8 e5 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010255b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102562:	e8 e2 e9 ff ff       	call   f0100f49 <page_alloc>
f0102567:	85 c0                	test   %eax,%eax
f0102569:	74 04                	je     f010256f <mem_init+0x121e>
f010256b:	39 c6                	cmp    %eax,%esi
f010256d:	74 24                	je     f0102593 <mem_init+0x1242>
f010256f:	c7 44 24 0c 80 77 10 	movl   $0xf0107780,0xc(%esp)
f0102576:	f0 
f0102577:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010257e:	f0 
f010257f:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102586:	00 
f0102587:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010258e:	e8 ad da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010259a:	e8 aa e9 ff ff       	call   f0100f49 <page_alloc>
f010259f:	85 c0                	test   %eax,%eax
f01025a1:	74 24                	je     f01025c7 <mem_init+0x1276>
f01025a3:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f01025aa:	f0 
f01025ab:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01025b2:	f0 
f01025b3:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f01025ba:	00 
f01025bb:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01025c2:	e8 79 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025c7:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01025cc:	8b 08                	mov    (%eax),%ecx
f01025ce:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025d4:	89 fa                	mov    %edi,%edx
f01025d6:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01025dc:	c1 fa 03             	sar    $0x3,%edx
f01025df:	c1 e2 0c             	shl    $0xc,%edx
f01025e2:	39 d1                	cmp    %edx,%ecx
f01025e4:	74 24                	je     f010260a <mem_init+0x12b9>
f01025e6:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f01025ed:	f0 
f01025ee:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f01025fd:	00 
f01025fe:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102605:	e8 36 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010260a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102610:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102615:	74 24                	je     f010263b <mem_init+0x12ea>
f0102617:	c7 44 24 0c 3c 7d 10 	movl   $0xf0107d3c,0xc(%esp)
f010261e:	f0 
f010261f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102626:	f0 
f0102627:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f010262e:	00 
f010262f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102636:	e8 05 da ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010263b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102641:	89 3c 24             	mov    %edi,(%esp)
f0102644:	e8 84 e9 ff ff       	call   f0100fcd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102649:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102650:	00 
f0102651:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102658:	00 
f0102659:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010265e:	89 04 24             	mov    %eax,(%esp)
f0102661:	e8 ca e9 ff ff       	call   f0101030 <pgdir_walk>
f0102666:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102669:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f010266f:	8b 51 04             	mov    0x4(%ecx),%edx
f0102672:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102678:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010267b:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f0102681:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102684:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102687:	c1 ea 0c             	shr    $0xc,%edx
f010268a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010268d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102690:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102693:	72 23                	jb     f01026b8 <mem_init+0x1367>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102695:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102698:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010269c:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f01026a3:	f0 
f01026a4:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01026ab:	00 
f01026ac:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01026b3:	e8 88 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026bb:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01026c1:	39 d0                	cmp    %edx,%eax
f01026c3:	74 24                	je     f01026e9 <mem_init+0x1398>
f01026c5:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f01026cc:	f0 
f01026cd:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01026d4:	f0 
f01026d5:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f01026dc:	00 
f01026dd:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01026e4:	e8 57 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01026e9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01026f0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026f6:	89 f8                	mov    %edi,%eax
f01026f8:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f01026fe:	c1 f8 03             	sar    $0x3,%eax
f0102701:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102704:	89 c1                	mov    %eax,%ecx
f0102706:	c1 e9 0c             	shr    $0xc,%ecx
f0102709:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010270c:	77 20                	ja     f010272e <mem_init+0x13dd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010270e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102712:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0102719:	f0 
f010271a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102721:	00 
f0102722:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0102729:	e8 12 d9 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010272e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102735:	00 
f0102736:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010273d:	00 
	return (void *)(pa + KERNBASE);
f010273e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102743:	89 04 24             	mov    %eax,(%esp)
f0102746:	e8 28 38 00 00       	call   f0105f73 <memset>
	page_free(pp0);
f010274b:	89 3c 24             	mov    %edi,(%esp)
f010274e:	e8 7a e8 ff ff       	call   f0100fcd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102753:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010275a:	00 
f010275b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102762:	00 
f0102763:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102768:	89 04 24             	mov    %eax,(%esp)
f010276b:	e8 c0 e8 ff ff       	call   f0101030 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102770:	89 fa                	mov    %edi,%edx
f0102772:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102778:	c1 fa 03             	sar    $0x3,%edx
f010277b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010277e:	89 d0                	mov    %edx,%eax
f0102780:	c1 e8 0c             	shr    $0xc,%eax
f0102783:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0102789:	72 20                	jb     f01027ab <mem_init+0x145a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010278b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010278f:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0102796:	f0 
f0102797:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010279e:	00 
f010279f:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f01027a6:	e8 95 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01027ab:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01027b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027b4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01027ba:	f6 00 01             	testb  $0x1,(%eax)
f01027bd:	74 24                	je     f01027e3 <mem_init+0x1492>
f01027bf:	c7 44 24 0c e0 7d 10 	movl   $0xf0107de0,0xc(%esp)
f01027c6:	f0 
f01027c7:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01027ce:	f0 
f01027cf:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01027d6:	00 
f01027d7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01027de:	e8 5d d8 ff ff       	call   f0100040 <_panic>
f01027e3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01027e6:	39 d0                	cmp    %edx,%eax
f01027e8:	75 d0                	jne    f01027ba <mem_init+0x1469>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01027ea:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01027ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027f5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01027fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01027fe:	89 0d 40 22 23 f0    	mov    %ecx,0xf0232240

	// free the pages we took
	page_free(pp0);
f0102804:	89 3c 24             	mov    %edi,(%esp)
f0102807:	e8 c1 e7 ff ff       	call   f0100fcd <page_free>
	page_free(pp1);
f010280c:	89 34 24             	mov    %esi,(%esp)
f010280f:	e8 b9 e7 ff ff       	call   f0100fcd <page_free>
	page_free(pp2);
f0102814:	89 1c 24             	mov    %ebx,(%esp)
f0102817:	e8 b1 e7 ff ff       	call   f0100fcd <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010281c:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102823:	00 
f0102824:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010282b:	e8 ad ea ff ff       	call   f01012dd <mmio_map_region>
f0102830:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102832:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102839:	00 
f010283a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102841:	e8 97 ea ff ff       	call   f01012dd <mmio_map_region>
f0102846:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102848:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010284e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102854:	76 07                	jbe    f010285d <mem_init+0x150c>
f0102856:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010285b:	76 24                	jbe    f0102881 <mem_init+0x1530>
f010285d:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f0102864:	f0 
f0102865:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010286c:	f0 
f010286d:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102874:	00 
f0102875:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010287c:	e8 bf d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102881:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102887:	76 0e                	jbe    f0102897 <mem_init+0x1546>
f0102889:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010288f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102895:	76 24                	jbe    f01028bb <mem_init+0x156a>
f0102897:	c7 44 24 0c cc 77 10 	movl   $0xf01077cc,0xc(%esp)
f010289e:	f0 
f010289f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f01028ae:	00 
f01028af:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01028b6:	e8 85 d7 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028bb:	89 da                	mov    %ebx,%edx
f01028bd:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028bf:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01028c5:	74 24                	je     f01028eb <mem_init+0x159a>
f01028c7:	c7 44 24 0c f4 77 10 	movl   $0xf01077f4,0xc(%esp)
f01028ce:	f0 
f01028cf:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01028d6:	f0 
f01028d7:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f01028de:	00 
f01028df:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01028e6:	e8 55 d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01028eb:	39 c6                	cmp    %eax,%esi
f01028ed:	73 24                	jae    f0102913 <mem_init+0x15c2>
f01028ef:	c7 44 24 0c f7 7d 10 	movl   $0xf0107df7,0xc(%esp)
f01028f6:	f0 
f01028f7:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01028fe:	f0 
f01028ff:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0102906:	00 
f0102907:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010290e:	e8 2d d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102913:	8b 3d 8c 2e 23 f0    	mov    0xf0232e8c,%edi
f0102919:	89 da                	mov    %ebx,%edx
f010291b:	89 f8                	mov    %edi,%eax
f010291d:	e8 24 e1 ff ff       	call   f0100a46 <check_va2pa>
f0102922:	85 c0                	test   %eax,%eax
f0102924:	74 24                	je     f010294a <mem_init+0x15f9>
f0102926:	c7 44 24 0c 1c 78 10 	movl   $0xf010781c,0xc(%esp)
f010292d:	f0 
f010292e:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102935:	f0 
f0102936:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f010293d:	00 
f010293e:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102945:	e8 f6 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010294a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102950:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102953:	89 c2                	mov    %eax,%edx
f0102955:	89 f8                	mov    %edi,%eax
f0102957:	e8 ea e0 ff ff       	call   f0100a46 <check_va2pa>
f010295c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102961:	74 24                	je     f0102987 <mem_init+0x1636>
f0102963:	c7 44 24 0c 40 78 10 	movl   $0xf0107840,0xc(%esp)
f010296a:	f0 
f010296b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102972:	f0 
f0102973:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f010297a:	00 
f010297b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102982:	e8 b9 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102987:	89 f2                	mov    %esi,%edx
f0102989:	89 f8                	mov    %edi,%eax
f010298b:	e8 b6 e0 ff ff       	call   f0100a46 <check_va2pa>
f0102990:	85 c0                	test   %eax,%eax
f0102992:	74 24                	je     f01029b8 <mem_init+0x1667>
f0102994:	c7 44 24 0c 70 78 10 	movl   $0xf0107870,0xc(%esp)
f010299b:	f0 
f010299c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01029a3:	f0 
f01029a4:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01029ab:	00 
f01029ac:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01029b3:	e8 88 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01029b8:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01029be:	89 f8                	mov    %edi,%eax
f01029c0:	e8 81 e0 ff ff       	call   f0100a46 <check_va2pa>
f01029c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029c8:	74 24                	je     f01029ee <mem_init+0x169d>
f01029ca:	c7 44 24 0c 94 78 10 	movl   $0xf0107894,0xc(%esp)
f01029d1:	f0 
f01029d2:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01029d9:	f0 
f01029da:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f01029e1:	00 
f01029e2:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01029e9:	e8 52 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01029ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029f5:	00 
f01029f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01029fa:	89 3c 24             	mov    %edi,(%esp)
f01029fd:	e8 2e e6 ff ff       	call   f0101030 <pgdir_walk>
f0102a02:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a05:	75 24                	jne    f0102a2b <mem_init+0x16da>
f0102a07:	c7 44 24 0c c0 78 10 	movl   $0xf01078c0,0xc(%esp)
f0102a0e:	f0 
f0102a0f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102a16:	f0 
f0102a17:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0102a1e:	00 
f0102a1f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102a26:	e8 15 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a32:	00 
f0102a33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a37:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102a3c:	89 04 24             	mov    %eax,(%esp)
f0102a3f:	e8 ec e5 ff ff       	call   f0101030 <pgdir_walk>
f0102a44:	f6 00 04             	testb  $0x4,(%eax)
f0102a47:	74 24                	je     f0102a6d <mem_init+0x171c>
f0102a49:	c7 44 24 0c 04 79 10 	movl   $0xf0107904,0xc(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102a58:	f0 
f0102a59:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0102a60:	00 
f0102a61:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102a68:	e8 d3 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a74:	00 
f0102a75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a79:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102a7e:	89 04 24             	mov    %eax,(%esp)
f0102a81:	e8 aa e5 ff ff       	call   f0101030 <pgdir_walk>
f0102a86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a93:	00 
f0102a94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a97:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102a9b:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102aa0:	89 04 24             	mov    %eax,(%esp)
f0102aa3:	e8 88 e5 ff ff       	call   f0101030 <pgdir_walk>
f0102aa8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102aae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ab5:	00 
f0102ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102aba:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102abf:	89 04 24             	mov    %eax,(%esp)
f0102ac2:	e8 69 e5 ff ff       	call   f0101030 <pgdir_walk>
f0102ac7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102acd:	c7 04 24 09 7e 10 f0 	movl   $0xf0107e09,(%esp)
f0102ad4:	e8 95 14 00 00       	call   f0103f6e <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ad9:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102adf:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae9:	77 20                	ja     f0102b0b <mem_init+0x17ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102aef:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102af6:	f0 
f0102af7:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102afe:	00 
f0102aff:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102b06:	e8 35 d5 ff ff       	call   f0100040 <_panic>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b0b:	8d 1c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ebx
f0102b12:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b18:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b1f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b20:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b25:	89 04 24             	mov    %eax,(%esp)
f0102b28:	89 d9                	mov    %ebx,%ecx
f0102b2a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b2f:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102b34:	e8 9e e5 ff ff       	call   f01010d7 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102b39:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b3f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102b45:	77 20                	ja     f0102b67 <mem_init+0x1816>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b47:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b4b:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102b52:	f0 
f0102b53:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102b5a:	00 
f0102b5b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102b62:	e8 d9 d4 ff ff       	call   f0100040 <_panic>
f0102b67:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102b6e:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b6f:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102b75:	89 04 24             	mov    %eax,(%esp)
f0102b78:	89 d9                	mov    %ebx,%ecx
f0102b7a:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102b7f:	e8 53 e5 ff ff       	call   f01010d7 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102b84:	a1 48 22 23 f0       	mov    0xf0232248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b89:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b8e:	77 20                	ja     f0102bb0 <mem_init+0x185f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b94:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102b9b:	f0 
f0102b9c:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102ba3:	00 
f0102ba4:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102bab:	e8 90 d4 ff ff       	call   f0100040 <_panic>
f0102bb0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bb7:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bb8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bbd:	89 04 24             	mov    %eax,(%esp)
f0102bc0:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102bc5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102bca:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102bcf:	e8 03 e5 ff ff       	call   f01010d7 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102bd4:	8b 15 48 22 23 f0    	mov    0xf0232248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bda:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102be0:	77 20                	ja     f0102c02 <mem_init+0x18b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102be6:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102bed:	f0 
f0102bee:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102bf5:	00 
f0102bf6:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102bfd:	e8 3e d4 ff ff       	call   f0100040 <_panic>
f0102c02:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c09:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c0a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c10:	89 04 24             	mov    %eax,(%esp)
f0102c13:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c18:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102c1d:	e8 b5 e4 ff ff       	call   f01010d7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c22:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102c27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c2c:	77 20                	ja     f0102c4e <mem_init+0x18fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c32:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102c39:	f0 
f0102c3a:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102c41:	00 
f0102c42:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102c49:	e8 f2 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102c4e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c55:	00 
f0102c56:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102c5d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c62:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102c67:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102c6c:	e8 66 e4 ff ff       	call   f01010d7 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102c71:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c78:	00 
f0102c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c80:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102c85:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c8a:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102c8f:	e8 43 e4 ff ff       	call   f01010d7 <boot_map_region>
f0102c94:	c7 45 cc 00 40 23 f0 	movl   $0xf0234000,-0x34(%ebp)
f0102c9b:	bb 00 40 23 f0       	mov    $0xf0234000,%ebx
f0102ca0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ca5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102cab:	77 20                	ja     f0102ccd <mem_init+0x197c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cb1:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102cb8:	f0 
f0102cb9:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0102cc0:	00 
f0102cc1:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102cc8:	e8 73 d3 ff ff       	call   f0100040 <_panic>
    uintptr_t kstacktop_i;

    for (i = 0; i < NCPU; i++)
    {
        kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        boot_map_region(kern_pgdir,
f0102ccd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cd4:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cd5:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
    uintptr_t kstacktop_i;

    for (i = 0; i < NCPU; i++)
    {
        kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        boot_map_region(kern_pgdir,
f0102cdb:	89 04 24             	mov    %eax,(%esp)
f0102cde:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102ce3:	89 f2                	mov    %esi,%edx
f0102ce5:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102cea:	e8 e8 e3 ff ff       	call   f01010d7 <boot_map_region>
f0102cef:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102cf5:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	return ;
	*/
	 int i = 0;
    uintptr_t kstacktop_i;

    for (i = 0; i < NCPU; i++)
f0102cfb:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d01:	75 a2                	jne    f0102ca5 <mem_init+0x1954>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d03:	8b 1d 8c 2e 23 f0    	mov    0xf0232e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d09:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f0102d0f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d12:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d19:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d1f:	be 00 00 00 00       	mov    $0x0,%esi
f0102d24:	eb 70                	jmp    f0102d96 <mem_init+0x1a45>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d26:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d2c:	89 d8                	mov    %ebx,%eax
f0102d2e:	e8 13 dd ff ff       	call   f0100a46 <check_va2pa>
f0102d33:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d39:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d3f:	77 20                	ja     f0102d61 <mem_init+0x1a10>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d41:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d45:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102d4c:	f0 
f0102d4d:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102d54:	00 
f0102d55:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102d5c:	e8 df d2 ff ff       	call   f0100040 <_panic>
f0102d61:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d68:	39 d0                	cmp    %edx,%eax
f0102d6a:	74 24                	je     f0102d90 <mem_init+0x1a3f>
f0102d6c:	c7 44 24 0c 38 79 10 	movl   $0xf0107938,0xc(%esp)
f0102d73:	f0 
f0102d74:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102d7b:	f0 
f0102d7c:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102d83:	00 
f0102d84:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102d8b:	e8 b0 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d90:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d96:	39 f7                	cmp    %esi,%edi
f0102d98:	77 8c                	ja     f0102d26 <mem_init+0x19d5>
f0102d9a:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d9f:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102da5:	89 d8                	mov    %ebx,%eax
f0102da7:	e8 9a dc ff ff       	call   f0100a46 <check_va2pa>
f0102dac:	8b 15 48 22 23 f0    	mov    0xf0232248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102db8:	77 20                	ja     f0102dda <mem_init+0x1a89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dba:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102dbe:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102dd5:	e8 66 d2 ff ff       	call   f0100040 <_panic>
f0102dda:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102de1:	39 d0                	cmp    %edx,%eax
f0102de3:	74 24                	je     f0102e09 <mem_init+0x1ab8>
f0102de5:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f0102dec:	f0 
f0102ded:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102df4:	f0 
f0102df5:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102dfc:	00 
f0102dfd:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e09:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e0f:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e15:	75 88                	jne    f0102d9f <mem_init+0x1a4e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e17:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e1a:	c1 e7 0c             	shl    $0xc,%edi
f0102e1d:	be 00 00 00 00       	mov    $0x0,%esi
f0102e22:	eb 3b                	jmp    f0102e5f <mem_init+0x1b0e>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e24:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e2a:	89 d8                	mov    %ebx,%eax
f0102e2c:	e8 15 dc ff ff       	call   f0100a46 <check_va2pa>
f0102e31:	39 c6                	cmp    %eax,%esi
f0102e33:	74 24                	je     f0102e59 <mem_init+0x1b08>
f0102e35:	c7 44 24 0c a0 79 10 	movl   $0xf01079a0,0xc(%esp)
f0102e3c:	f0 
f0102e3d:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102e44:	f0 
f0102e45:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102e4c:	00 
f0102e4d:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102e54:	e8 e7 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e59:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e5f:	39 fe                	cmp    %edi,%esi
f0102e61:	72 c1                	jb     f0102e24 <mem_init+0x1ad3>
f0102e63:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f0102e6a:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e6c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e6f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e72:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e75:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e7b:	89 c6                	mov    %eax,%esi
f0102e7d:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102e83:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102e86:	81 c2 00 00 01 00    	add    $0x10000,%edx
f0102e8c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e8f:	89 da                	mov    %ebx,%edx
f0102e91:	89 f8                	mov    %edi,%eax
f0102e93:	e8 ae db ff ff       	call   f0100a46 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e98:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e9f:	77 23                	ja     f0102ec4 <mem_init+0x1b73>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ea4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ea8:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0102eaf:	f0 
f0102eb0:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102eb7:	00 
f0102eb8:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102ebf:	e8 7c d1 ff ff       	call   f0100040 <_panic>
f0102ec4:	39 f0                	cmp    %esi,%eax
f0102ec6:	74 24                	je     f0102eec <mem_init+0x1b9b>
f0102ec8:	c7 44 24 0c c8 79 10 	movl   $0xf01079c8,0xc(%esp)
f0102ecf:	f0 
f0102ed0:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102ed7:	f0 
f0102ed8:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102edf:	00 
f0102ee0:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102ee7:	e8 54 d1 ff ff       	call   f0100040 <_panic>
f0102eec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ef2:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ef8:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102efb:	0f 85 58 05 00 00    	jne    f0103459 <mem_init+0x2108>
f0102f01:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f06:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f09:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f0c:	89 f8                	mov    %edi,%eax
f0102f0e:	e8 33 db ff ff       	call   f0100a46 <check_va2pa>
f0102f13:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f16:	74 24                	je     f0102f3c <mem_init+0x1beb>
f0102f18:	c7 44 24 0c 10 7a 10 	movl   $0xf0107a10,0xc(%esp)
f0102f1f:	f0 
f0102f20:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102f27:	f0 
f0102f28:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102f2f:	00 
f0102f30:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102f37:	e8 04 d1 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f42:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f48:	75 bf                	jne    f0102f09 <mem_init+0x1bb8>
f0102f4a:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0102f51:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f58:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0102f5f:	0f 85 07 ff ff ff    	jne    f0102e6c <mem_init+0x1b1b>
f0102f65:	89 fb                	mov    %edi,%ebx
f0102f67:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f6c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f72:	83 fa 04             	cmp    $0x4,%edx
f0102f75:	77 2e                	ja     f0102fa5 <mem_init+0x1c54>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102f77:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f7b:	0f 85 aa 00 00 00    	jne    f010302b <mem_init+0x1cda>
f0102f81:	c7 44 24 0c 22 7e 10 	movl   $0xf0107e22,0xc(%esp)
f0102f88:	f0 
f0102f89:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102f90:	f0 
f0102f91:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102f98:	00 
f0102f99:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102fa0:	e8 9b d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102fa5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102faa:	76 55                	jbe    f0103001 <mem_init+0x1cb0>
				assert(pgdir[i] & PTE_P);
f0102fac:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102faf:	f6 c2 01             	test   $0x1,%dl
f0102fb2:	75 24                	jne    f0102fd8 <mem_init+0x1c87>
f0102fb4:	c7 44 24 0c 22 7e 10 	movl   $0xf0107e22,0xc(%esp)
f0102fbb:	f0 
f0102fbc:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102fc3:	f0 
f0102fc4:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102fcb:	00 
f0102fcc:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102fd3:	e8 68 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102fd8:	f6 c2 02             	test   $0x2,%dl
f0102fdb:	75 4e                	jne    f010302b <mem_init+0x1cda>
f0102fdd:	c7 44 24 0c 33 7e 10 	movl   $0xf0107e33,0xc(%esp)
f0102fe4:	f0 
f0102fe5:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0102fec:	f0 
f0102fed:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102ff4:	00 
f0102ff5:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0102ffc:	e8 3f d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103001:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103005:	74 24                	je     f010302b <mem_init+0x1cda>
f0103007:	c7 44 24 0c 44 7e 10 	movl   $0xf0107e44,0xc(%esp)
f010300e:	f0 
f010300f:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0103016:	f0 
f0103017:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f010301e:	00 
f010301f:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103026:	e8 15 d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010302b:	83 c0 01             	add    $0x1,%eax
f010302e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103033:	0f 85 33 ff ff ff    	jne    f0102f6c <mem_init+0x1c1b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103039:	c7 04 24 34 7a 10 f0 	movl   $0xf0107a34,(%esp)
f0103040:	e8 29 0f 00 00       	call   f0103f6e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103045:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010304a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010304f:	77 20                	ja     f0103071 <mem_init+0x1d20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103051:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103055:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f010305c:	f0 
f010305d:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103064:	00 
f0103065:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010306c:	e8 cf cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103071:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103076:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103079:	b8 00 00 00 00       	mov    $0x0,%eax
f010307e:	e8 66 da ff ff       	call   f0100ae9 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103083:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103086:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010308b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010308e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103098:	e8 ac de ff ff       	call   f0100f49 <page_alloc>
f010309d:	89 c6                	mov    %eax,%esi
f010309f:	85 c0                	test   %eax,%eax
f01030a1:	75 24                	jne    f01030c7 <mem_init+0x1d76>
f01030a3:	c7 44 24 0c 2e 7c 10 	movl   $0xf0107c2e,0xc(%esp)
f01030aa:	f0 
f01030ab:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01030b2:	f0 
f01030b3:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01030ba:	00 
f01030bb:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01030c2:	e8 79 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030ce:	e8 76 de ff ff       	call   f0100f49 <page_alloc>
f01030d3:	89 c7                	mov    %eax,%edi
f01030d5:	85 c0                	test   %eax,%eax
f01030d7:	75 24                	jne    f01030fd <mem_init+0x1dac>
f01030d9:	c7 44 24 0c 44 7c 10 	movl   $0xf0107c44,0xc(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01030e8:	f0 
f01030e9:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f01030f0:	00 
f01030f1:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01030f8:	e8 43 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01030fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103104:	e8 40 de ff ff       	call   f0100f49 <page_alloc>
f0103109:	89 c3                	mov    %eax,%ebx
f010310b:	85 c0                	test   %eax,%eax
f010310d:	75 24                	jne    f0103133 <mem_init+0x1de2>
f010310f:	c7 44 24 0c 5a 7c 10 	movl   $0xf0107c5a,0xc(%esp)
f0103116:	f0 
f0103117:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010311e:	f0 
f010311f:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0103126:	00 
f0103127:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010312e:	e8 0d cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103133:	89 34 24             	mov    %esi,(%esp)
f0103136:	e8 92 de ff ff       	call   f0100fcd <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010313b:	89 f8                	mov    %edi,%eax
f010313d:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0103143:	c1 f8 03             	sar    $0x3,%eax
f0103146:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103149:	89 c2                	mov    %eax,%edx
f010314b:	c1 ea 0c             	shr    $0xc,%edx
f010314e:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0103154:	72 20                	jb     f0103176 <mem_init+0x1e25>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103156:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010315a:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0103161:	f0 
f0103162:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103169:	00 
f010316a:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0103171:	e8 ca ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103176:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010317d:	00 
f010317e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103185:	00 
	return (void *)(pa + KERNBASE);
f0103186:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010318b:	89 04 24             	mov    %eax,(%esp)
f010318e:	e8 e0 2d 00 00       	call   f0105f73 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103193:	89 d8                	mov    %ebx,%eax
f0103195:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f010319b:	c1 f8 03             	sar    $0x3,%eax
f010319e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031a1:	89 c2                	mov    %eax,%edx
f01031a3:	c1 ea 0c             	shr    $0xc,%edx
f01031a6:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f01031ac:	72 20                	jb     f01031ce <mem_init+0x1e7d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b2:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f01031b9:	f0 
f01031ba:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031c1:	00 
f01031c2:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f01031c9:	e8 72 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031d5:	00 
f01031d6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031dd:	00 
	return (void *)(pa + KERNBASE);
f01031de:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031e3:	89 04 24             	mov    %eax,(%esp)
f01031e6:	e8 88 2d 00 00       	call   f0105f73 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031eb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031f2:	00 
f01031f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031fa:	00 
f01031fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01031ff:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103204:	89 04 24             	mov    %eax,(%esp)
f0103207:	e8 33 e0 ff ff       	call   f010123f <page_insert>
	assert(pp1->pp_ref == 1);
f010320c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103211:	74 24                	je     f0103237 <mem_init+0x1ee6>
f0103213:	c7 44 24 0c 2b 7d 10 	movl   $0xf0107d2b,0xc(%esp)
f010321a:	f0 
f010321b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0103222:	f0 
f0103223:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f010322a:	00 
f010322b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103232:	e8 09 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103237:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010323e:	01 01 01 
f0103241:	74 24                	je     f0103267 <mem_init+0x1f16>
f0103243:	c7 44 24 0c 54 7a 10 	movl   $0xf0107a54,0xc(%esp)
f010324a:	f0 
f010324b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0103252:	f0 
f0103253:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f010325a:	00 
f010325b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103262:	e8 d9 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103267:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010326e:	00 
f010326f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103276:	00 
f0103277:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010327b:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103280:	89 04 24             	mov    %eax,(%esp)
f0103283:	e8 b7 df ff ff       	call   f010123f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103288:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010328f:	02 02 02 
f0103292:	74 24                	je     f01032b8 <mem_init+0x1f67>
f0103294:	c7 44 24 0c 78 7a 10 	movl   $0xf0107a78,0xc(%esp)
f010329b:	f0 
f010329c:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01032a3:	f0 
f01032a4:	c7 44 24 04 8b 04 00 	movl   $0x48b,0x4(%esp)
f01032ab:	00 
f01032ac:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01032b3:	e8 88 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032b8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032bd:	74 24                	je     f01032e3 <mem_init+0x1f92>
f01032bf:	c7 44 24 0c 4d 7d 10 	movl   $0xf0107d4d,0xc(%esp)
f01032c6:	f0 
f01032c7:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01032ce:	f0 
f01032cf:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f01032d6:	00 
f01032d7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01032de:	e8 5d cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032e3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032e8:	74 24                	je     f010330e <mem_init+0x1fbd>
f01032ea:	c7 44 24 0c b7 7d 10 	movl   $0xf0107db7,0xc(%esp)
f01032f1:	f0 
f01032f2:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01032f9:	f0 
f01032fa:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0103301:	00 
f0103302:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103309:	e8 32 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010330e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103315:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103318:	89 d8                	mov    %ebx,%eax
f010331a:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0103320:	c1 f8 03             	sar    $0x3,%eax
f0103323:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103326:	89 c2                	mov    %eax,%edx
f0103328:	c1 ea 0c             	shr    $0xc,%edx
f010332b:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0103331:	72 20                	jb     f0103353 <mem_init+0x2002>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103333:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103337:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f010333e:	f0 
f010333f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103346:	00 
f0103347:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f010334e:	e8 ed cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103353:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010335a:	03 03 03 
f010335d:	74 24                	je     f0103383 <mem_init+0x2032>
f010335f:	c7 44 24 0c 9c 7a 10 	movl   $0xf0107a9c,0xc(%esp)
f0103366:	f0 
f0103367:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f010336e:	f0 
f010336f:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0103376:	00 
f0103377:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010337e:	e8 bd cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103383:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010338a:	00 
f010338b:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103390:	89 04 24             	mov    %eax,(%esp)
f0103393:	e8 47 de ff ff       	call   f01011df <page_remove>
	assert(pp2->pp_ref == 0);
f0103398:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010339d:	74 24                	je     f01033c3 <mem_init+0x2072>
f010339f:	c7 44 24 0c 85 7d 10 	movl   $0xf0107d85,0xc(%esp)
f01033a6:	f0 
f01033a7:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01033ae:	f0 
f01033af:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f01033b6:	00 
f01033b7:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f01033be:	e8 7d cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033c3:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01033c8:	8b 08                	mov    (%eax),%ecx
f01033ca:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033d0:	89 f2                	mov    %esi,%edx
f01033d2:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01033d8:	c1 fa 03             	sar    $0x3,%edx
f01033db:	c1 e2 0c             	shl    $0xc,%edx
f01033de:	39 d1                	cmp    %edx,%ecx
f01033e0:	74 24                	je     f0103406 <mem_init+0x20b5>
f01033e2:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f01033e9:	f0 
f01033ea:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f01033f1:	f0 
f01033f2:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f01033f9:	00 
f01033fa:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103401:	e8 3a cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103406:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010340c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103411:	74 24                	je     f0103437 <mem_init+0x20e6>
f0103413:	c7 44 24 0c 3c 7d 10 	movl   $0xf0107d3c,0xc(%esp)
f010341a:	f0 
f010341b:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0103422:	f0 
f0103423:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f010342a:	00 
f010342b:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f0103432:	e8 09 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103437:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010343d:	89 34 24             	mov    %esi,(%esp)
f0103440:	e8 88 db ff ff       	call   f0100fcd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103445:	c7 04 24 c8 7a 10 f0 	movl   $0xf0107ac8,(%esp)
f010344c:	e8 1d 0b 00 00       	call   f0103f6e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103451:	83 c4 3c             	add    $0x3c,%esp
f0103454:	5b                   	pop    %ebx
f0103455:	5e                   	pop    %esi
f0103456:	5f                   	pop    %edi
f0103457:	5d                   	pop    %ebp
f0103458:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103459:	89 da                	mov    %ebx,%edx
f010345b:	89 f8                	mov    %edi,%eax
f010345d:	e8 e4 d5 ff ff       	call   f0100a46 <check_va2pa>
f0103462:	e9 5d fa ff ff       	jmp    f0102ec4 <mem_init+0x1b73>

f0103467 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103467:	55                   	push   %ebp
f0103468:	89 e5                	mov    %esp,%ebp
f010346a:	57                   	push   %edi
f010346b:	56                   	push   %esi
f010346c:	53                   	push   %ebx
f010346d:	83 ec 2c             	sub    $0x2c,%esp
f0103470:	8b 75 08             	mov    0x8(%ebp),%esi
f0103473:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103479:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010347f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103482:	03 45 10             	add    0x10(%ebp),%eax
f0103485:	05 ff 0f 00 00       	add    $0xfff,%eax
f010348a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010348f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f0103492:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103498:	76 5d                	jbe    f01034f7 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f010349a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010349d:	a3 44 22 23 f0       	mov    %eax,0xf0232244
        return -E_FAULT;
f01034a2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034a7:	eb 58                	jmp    f0103501 <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034b0:	00 
f01034b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034b5:	8b 46 60             	mov    0x60(%esi),%eax
f01034b8:	89 04 24             	mov    %eax,(%esp)
f01034bb:	e8 70 db ff ff       	call   f0101030 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034c0:	85 c0                	test   %eax,%eax
f01034c2:	74 0c                	je     f01034d0 <user_mem_check+0x69>
f01034c4:	8b 00                	mov    (%eax),%eax
f01034c6:	a8 01                	test   $0x1,%al
f01034c8:	74 06                	je     f01034d0 <user_mem_check+0x69>
f01034ca:	21 f8                	and    %edi,%eax
f01034cc:	39 c7                	cmp    %eax,%edi
f01034ce:	74 21                	je     f01034f1 <user_mem_check+0x8a>
        {
            if (addr < va)
f01034d0:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034d3:	76 0f                	jbe    f01034e4 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034d8:	a3 44 22 23 f0       	mov    %eax,0xf0232244
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034dd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034e2:	eb 1d                	jmp    f0103501 <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f01034e4:	89 1d 44 22 23 f0    	mov    %ebx,0xf0232244
            }
            
            return -E_FAULT;
f01034ea:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034ef:	eb 10                	jmp    f0103501 <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f01034f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034f7:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01034fa:	72 ad                	jb     f01034a9 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f01034fc:	b8 00 00 00 00       	mov    $0x0,%eax

}
f0103501:	83 c4 2c             	add    $0x2c,%esp
f0103504:	5b                   	pop    %ebx
f0103505:	5e                   	pop    %esi
f0103506:	5f                   	pop    %edi
f0103507:	5d                   	pop    %ebp
f0103508:	c3                   	ret    

f0103509 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103509:	55                   	push   %ebp
f010350a:	89 e5                	mov    %esp,%ebp
f010350c:	53                   	push   %ebx
f010350d:	83 ec 14             	sub    $0x14,%esp
f0103510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103513:	8b 45 14             	mov    0x14(%ebp),%eax
f0103516:	83 c8 04             	or     $0x4,%eax
f0103519:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010351d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103520:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103524:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103527:	89 44 24 04          	mov    %eax,0x4(%esp)
f010352b:	89 1c 24             	mov    %ebx,(%esp)
f010352e:	e8 34 ff ff ff       	call   f0103467 <user_mem_check>
f0103533:	85 c0                	test   %eax,%eax
f0103535:	79 24                	jns    f010355b <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103537:	a1 44 22 23 f0       	mov    0xf0232244,%eax
f010353c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103540:	8b 43 48             	mov    0x48(%ebx),%eax
f0103543:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103547:	c7 04 24 f4 7a 10 f0 	movl   $0xf0107af4,(%esp)
f010354e:	e8 1b 0a 00 00       	call   f0103f6e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103553:	89 1c 24             	mov    %ebx,(%esp)
f0103556:	e8 1b 07 00 00       	call   f0103c76 <env_destroy>
	}
}
f010355b:	83 c4 14             	add    $0x14,%esp
f010355e:	5b                   	pop    %ebx
f010355f:	5d                   	pop    %ebp
f0103560:	c3                   	ret    
f0103561:	00 00                	add    %al,(%eax)
	...

f0103564 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103564:	55                   	push   %ebp
f0103565:	89 e5                	mov    %esp,%ebp
f0103567:	57                   	push   %edi
f0103568:	56                   	push   %esi
f0103569:	53                   	push   %ebx
f010356a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f010356d:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f0103570:	89 d3                	mov    %edx,%ebx
f0103572:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103579:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010357e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103584:	29 d0                	sub    %edx,%eax
f0103586:	c1 e8 0c             	shr    $0xc,%eax
f0103589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f010358c:	be 00 00 00 00       	mov    $0x0,%esi
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0103591:	eb 6d                	jmp    f0103600 <region_alloc+0x9c>
		struct PageInfo* newPage = page_alloc(0);
f0103593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010359a:	e8 aa d9 ff ff       	call   f0100f49 <page_alloc>
		if(newPage == 0)
f010359f:	85 c0                	test   %eax,%eax
f01035a1:	75 1c                	jne    f01035bf <region_alloc+0x5b>
			panic("there is no more page to region_alloc for env\n");
f01035a3:	c7 44 24 08 54 7e 10 	movl   $0xf0107e54,0x8(%esp)
f01035aa:	f0 
f01035ab:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01035b2:	00 
f01035b3:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f01035ba:	e8 81 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035bf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035c6:	00 
f01035c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035cf:	89 3c 24             	mov    %edi,(%esp)
f01035d2:	e8 68 dc ff ff       	call   f010123f <page_insert>
f01035d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if(ret)
f01035dd:	85 c0                	test   %eax,%eax
f01035df:	74 1c                	je     f01035fd <region_alloc+0x99>
			panic("page_insert fail\n");
f01035e1:	c7 44 24 08 8e 7e 10 	movl   $0xf0107e8e,0x8(%esp)
f01035e8:	f0 
f01035e9:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01035f0:	00 
f01035f1:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f01035f8:	e8 43 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035fd:	83 c6 01             	add    $0x1,%esi
f0103600:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103603:	7c 8e                	jl     f0103593 <region_alloc+0x2f>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103605:	83 c4 2c             	add    $0x2c,%esp
f0103608:	5b                   	pop    %ebx
f0103609:	5e                   	pop    %esi
f010360a:	5f                   	pop    %edi
f010360b:	5d                   	pop    %ebp
f010360c:	c3                   	ret    

f010360d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010360d:	55                   	push   %ebp
f010360e:	89 e5                	mov    %esp,%ebp
f0103610:	83 ec 18             	sub    $0x18,%esp
f0103613:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103616:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103619:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010361c:	8b 45 08             	mov    0x8(%ebp),%eax
f010361f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103622:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103626:	85 c0                	test   %eax,%eax
f0103628:	75 17                	jne    f0103641 <envid2env+0x34>
		*env_store = curenv;
f010362a:	e8 a5 2f 00 00       	call   f01065d4 <cpunum>
f010362f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103632:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103638:	89 06                	mov    %eax,(%esi)
		return 0;
f010363a:	b8 00 00 00 00       	mov    $0x0,%eax
f010363f:	eb 67                	jmp    f01036a8 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103641:	89 c3                	mov    %eax,%ebx
f0103643:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103649:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010364c:	03 1d 48 22 23 f0    	add    0xf0232248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103652:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103656:	74 05                	je     f010365d <envid2env+0x50>
f0103658:	39 43 48             	cmp    %eax,0x48(%ebx)
f010365b:	74 0d                	je     f010366a <envid2env+0x5d>
		// debug code
		//cprintf("the e->env_id =0x%x,  envid = 0x%x \n", e->env_id, envid);
		//cprintf("debug code\n\n");

		*env_store = 0;
f010365d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103663:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103668:	eb 3e                	jmp    f01036a8 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010366a:	84 d2                	test   %dl,%dl
f010366c:	74 33                	je     f01036a1 <envid2env+0x94>
f010366e:	e8 61 2f 00 00       	call   f01065d4 <cpunum>
f0103673:	6b c0 74             	imul   $0x74,%eax,%eax
f0103676:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f010367c:	74 23                	je     f01036a1 <envid2env+0x94>
f010367e:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103681:	e8 4e 2f 00 00       	call   f01065d4 <cpunum>
f0103686:	6b c0 74             	imul   $0x74,%eax,%eax
f0103689:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010368f:	3b 78 48             	cmp    0x48(%eax),%edi
f0103692:	74 0d                	je     f01036a1 <envid2env+0x94>
		*env_store = 0;
f0103694:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010369a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010369f:	eb 07                	jmp    f01036a8 <envid2env+0x9b>
	}

	*env_store = e;
f01036a1:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01036ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01036ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01036b1:	89 ec                	mov    %ebp,%esp
f01036b3:	5d                   	pop    %ebp
f01036b4:	c3                   	ret    

f01036b5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036b5:	55                   	push   %ebp
f01036b6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036b8:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036bd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036c0:	b8 23 00 00 00       	mov    $0x23,%eax
f01036c5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036c7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036c9:	b0 10                	mov    $0x10,%al
f01036cb:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036cd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036cf:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036d1:	ea d8 36 10 f0 08 00 	ljmp   $0x8,$0xf01036d8
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036d8:	b0 00                	mov    $0x0,%al
f01036da:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036dd:	5d                   	pop    %ebp
f01036de:	c3                   	ret    

f01036df <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036df:	55                   	push   %ebp
f01036e0:	89 e5                	mov    %esp,%ebp
f01036e2:	56                   	push   %esi
f01036e3:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036e4:	8b 35 48 22 23 f0    	mov    0xf0232248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01036ea:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01036f0:	b9 00 00 00 00       	mov    $0x0,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f01036f5:	ba ff 03 00 00       	mov    $0x3ff,%edx
f01036fa:	eb 02                	jmp    f01036fe <env_init+0x1f>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01036fc:	89 d9                	mov    %ebx,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036fe:	89 c3                	mov    %eax,%ebx
f0103700:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103707:	89 48 44             	mov    %ecx,0x44(%eax)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f010370a:	83 ea 01             	sub    $0x1,%edx
f010370d:	83 e8 7c             	sub    $0x7c,%eax
f0103710:	83 fa ff             	cmp    $0xffffffff,%edx
f0103713:	75 e7                	jne    f01036fc <env_init+0x1d>
f0103715:	89 35 4c 22 23 f0    	mov    %esi,0xf023224c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010371b:	e8 95 ff ff ff       	call   f01036b5 <env_init_percpu>
}
f0103720:	5b                   	pop    %ebx
f0103721:	5e                   	pop    %esi
f0103722:	5d                   	pop    %ebp
f0103723:	c3                   	ret    

f0103724 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103724:	55                   	push   %ebp
f0103725:	89 e5                	mov    %esp,%ebp
f0103727:	53                   	push   %ebx
f0103728:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010372b:	8b 1d 4c 22 23 f0    	mov    0xf023224c,%ebx
f0103731:	85 db                	test   %ebx,%ebx
f0103733:	0f 84 aa 01 00 00    	je     f01038e3 <env_alloc+0x1bf>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103739:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103740:	e8 04 d8 ff ff       	call   f0100f49 <page_alloc>
f0103745:	85 c0                	test   %eax,%eax
f0103747:	0f 84 9d 01 00 00    	je     f01038ea <env_alloc+0x1c6>
f010374d:	89 c2                	mov    %eax,%edx
f010374f:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0103755:	c1 fa 03             	sar    $0x3,%edx
f0103758:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010375b:	89 d1                	mov    %edx,%ecx
f010375d:	c1 e9 0c             	shr    $0xc,%ecx
f0103760:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f0103766:	72 20                	jb     f0103788 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103768:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010376c:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0103773:	f0 
f0103774:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010377b:	00 
f010377c:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0103783:	e8 b8 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103788:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010378e:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f0103791:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103796:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010379d:	00 
f010379e:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01037a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037a7:	8b 43 60             	mov    0x60(%ebx),%eax
f01037aa:	89 04 24             	mov    %eax,(%esp)
f01037ad:	e8 95 28 00 00       	call   f0106047 <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037b2:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037b9:	00 
f01037ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037c1:	00 
f01037c2:	8b 43 60             	mov    0x60(%ebx),%eax
f01037c5:	89 04 24             	mov    %eax,(%esp)
f01037c8:	e8 a6 27 00 00       	call   f0105f73 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037cd:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037d5:	77 20                	ja     f01037f7 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037db:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f01037e2:	f0 
f01037e3:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f01037ea:	00 
f01037eb:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f01037f2:	e8 49 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037f7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037fd:	83 ca 05             	or     $0x5,%edx
f0103800:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103806:	8b 43 48             	mov    0x48(%ebx),%eax
f0103809:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010380e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103813:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103818:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010381b:	89 da                	mov    %ebx,%edx
f010381d:	2b 15 48 22 23 f0    	sub    0xf0232248,%edx
f0103823:	c1 fa 02             	sar    $0x2,%edx
f0103826:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010382c:	09 d0                	or     %edx,%eax
f010382e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103831:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103834:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103837:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010383e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103845:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010384c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103853:	00 
f0103854:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010385b:	00 
f010385c:	89 1c 24             	mov    %ebx,(%esp)
f010385f:	e8 0f 27 00 00       	call   f0105f73 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103864:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010386a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103870:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103876:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010387d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	// time clock
	e->env_tf.tf_eflags |= FL_IF;
f0103883:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010388a:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	//e->env_ipc_recving = 0;

	// commit the allocation
	env_free_list = e->env_link;
f0103891:	8b 43 44             	mov    0x44(%ebx),%eax
f0103894:	a3 4c 22 23 f0       	mov    %eax,0xf023224c
	*newenv_store = e;
f0103899:	8b 45 08             	mov    0x8(%ebp),%eax
f010389c:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010389e:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038a1:	e8 2e 2d 00 00       	call   f01065d4 <cpunum>
f01038a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ae:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f01038b5:	74 11                	je     f01038c8 <env_alloc+0x1a4>
f01038b7:	e8 18 2d 00 00       	call   f01065d4 <cpunum>
f01038bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bf:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01038c5:	8b 50 48             	mov    0x48(%eax),%edx
f01038c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038d0:	c7 04 24 a0 7e 10 f0 	movl   $0xf0107ea0,(%esp)
f01038d7:	e8 92 06 00 00       	call   f0103f6e <cprintf>
	return 0;
f01038dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e1:	eb 0c                	jmp    f01038ef <env_alloc+0x1cb>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038e3:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038e8:	eb 05                	jmp    f01038ef <env_alloc+0x1cb>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038ea:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038ef:	83 c4 14             	add    $0x14,%esp
f01038f2:	5b                   	pop    %ebx
f01038f3:	5d                   	pop    %ebp
f01038f4:	c3                   	ret    

f01038f5 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038f5:	55                   	push   %ebp
f01038f6:	89 e5                	mov    %esp,%ebp
f01038f8:	57                   	push   %edi
f01038f9:	56                   	push   %esi
f01038fa:	53                   	push   %ebx
f01038fb:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f01038fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103905:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010390c:	00 
f010390d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103910:	89 04 24             	mov    %eax,(%esp)
f0103913:	e8 0c fe ff ff       	call   f0103724 <env_alloc>
	if(r < 0)
f0103918:	85 c0                	test   %eax,%eax
f010391a:	79 1c                	jns    f0103938 <env_create+0x43>
		panic("env_create fault\n");
f010391c:	c7 44 24 08 b5 7e 10 	movl   $0xf0107eb5,0x8(%esp)
f0103923:	f0 
f0103924:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f010392b:	00 
f010392c:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103933:	e8 08 c7 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010393b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010393e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103941:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103947:	74 1c                	je     f0103965 <env_create+0x70>
			panic("e_magic is not right\n");
f0103949:	c7 44 24 08 c7 7e 10 	movl   $0xf0107ec7,0x8(%esp)
f0103950:	f0 
f0103951:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f0103958:	00 
f0103959:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103960:	e8 db c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103965:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103968:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010396b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103970:	77 20                	ja     f0103992 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103972:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103976:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f010397d:	f0 
f010397e:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0103985:	00 
f0103986:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f010398d:	e8 ae c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103992:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103997:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f010399a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010399d:	03 5b 1c             	add    0x1c(%ebx),%ebx
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
f01039a0:	83 c3 20             	add    $0x20,%ebx
f01039a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a6:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039aa:	83 c7 01             	add    $0x1,%edi
f01039ad:	be 01 00 00 00       	mov    $0x1,%esi
f01039b2:	eb 54                	jmp    f0103a08 <env_create+0x113>
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
			ph++;
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039b4:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039b7:	75 49                	jne    f0103a02 <env_create+0x10d>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039b9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039bc:	8b 53 08             	mov    0x8(%ebx),%edx
f01039bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039c2:	e8 9d fb ff ff       	call   f0103564 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039c7:	8b 43 10             	mov    0x10(%ebx),%eax
f01039ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d1:	03 43 04             	add    0x4(%ebx),%eax
f01039d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d8:	8b 43 08             	mov    0x8(%ebx),%eax
f01039db:	89 04 24             	mov    %eax,(%esp)
f01039de:	e8 eb 25 00 00       	call   f0105fce <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01039e3:	8b 43 10             	mov    0x10(%ebx),%eax
f01039e6:	8b 53 14             	mov    0x14(%ebx),%edx
f01039e9:	29 c2                	sub    %eax,%edx
f01039eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039f6:	00 
f01039f7:	03 43 08             	add    0x8(%ebx),%eax
f01039fa:	89 04 24             	mov    %eax,(%esp)
f01039fd:	e8 71 25 00 00       	call   f0105f73 <memset>
f0103a02:	83 c6 01             	add    $0x1,%esi
f0103a05:	83 c3 20             	add    $0x20,%ebx

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a08:	39 fe                	cmp    %edi,%esi
f0103a0a:	75 a8                	jne    f01039b4 <env_create+0xbf>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a0c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a0f:	8b 42 18             	mov    0x18(%edx),%eax
f0103a12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a15:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a18:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a1d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a25:	e8 3a fb ff ff       	call   f0103564 <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a2a:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a34:	77 20                	ja     f0103a56 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a3a:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0103a41:	f0 
f0103a42:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0103a49:	00 
f0103a4a:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103a51:	e8 ea c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a56:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a5b:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a64:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a67:	83 c4 3c             	add    $0x3c,%esp
f0103a6a:	5b                   	pop    %ebx
f0103a6b:	5e                   	pop    %esi
f0103a6c:	5f                   	pop    %edi
f0103a6d:	5d                   	pop    %ebp
f0103a6e:	c3                   	ret    

f0103a6f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a6f:	55                   	push   %ebp
f0103a70:	89 e5                	mov    %esp,%ebp
f0103a72:	57                   	push   %edi
f0103a73:	56                   	push   %esi
f0103a74:	53                   	push   %ebx
f0103a75:	83 ec 2c             	sub    $0x2c,%esp
f0103a78:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a7b:	e8 54 2b 00 00       	call   f01065d4 <cpunum>
f0103a80:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a83:	39 b8 28 30 23 f0    	cmp    %edi,-0xfdccfd8(%eax)
f0103a89:	75 34                	jne    f0103abf <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a8b:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a90:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a95:	77 20                	ja     f0103ab7 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a9b:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0103aa2:	f0 
f0103aa3:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0103aaa:	00 
f0103aab:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103ab2:	e8 89 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ab7:	05 00 00 00 10       	add    $0x10000000,%eax
f0103abc:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103abf:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103ac2:	e8 0d 2b 00 00       	call   f01065d4 <cpunum>
f0103ac7:	6b d0 74             	imul   $0x74,%eax,%edx
f0103aca:	b8 00 00 00 00       	mov    $0x0,%eax
f0103acf:	83 ba 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%edx)
f0103ad6:	74 11                	je     f0103ae9 <env_free+0x7a>
f0103ad8:	e8 f7 2a 00 00       	call   f01065d4 <cpunum>
f0103add:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae0:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103ae6:	8b 40 48             	mov    0x48(%eax),%eax
f0103ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103aed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af1:	c7 04 24 dd 7e 10 f0 	movl   $0xf0107edd,(%esp)
f0103af8:	e8 71 04 00 00       	call   f0103f6e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103afd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b07:	c1 e0 02             	shl    $0x2,%eax
f0103b0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b0d:	8b 47 60             	mov    0x60(%edi),%eax
f0103b10:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b13:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103b16:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b1c:	0f 84 b8 00 00 00    	je     f0103bda <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b22:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b28:	89 f0                	mov    %esi,%eax
f0103b2a:	c1 e8 0c             	shr    $0xc,%eax
f0103b2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b30:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103b36:	72 20                	jb     f0103b58 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b38:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b3c:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0103b43:	f0 
f0103b44:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f0103b4b:	00 
f0103b4c:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103b53:	e8 e8 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b58:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b5b:	c1 e2 16             	shl    $0x16,%edx
f0103b5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b61:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b66:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b6d:	01 
f0103b6e:	74 17                	je     f0103b87 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b70:	89 d8                	mov    %ebx,%eax
f0103b72:	c1 e0 0c             	shl    $0xc,%eax
f0103b75:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b7c:	8b 47 60             	mov    0x60(%edi),%eax
f0103b7f:	89 04 24             	mov    %eax,(%esp)
f0103b82:	e8 58 d6 ff ff       	call   f01011df <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b87:	83 c3 01             	add    $0x1,%ebx
f0103b8a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b90:	75 d4                	jne    f0103b66 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b92:	8b 47 60             	mov    0x60(%edi),%eax
f0103b95:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b98:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103ba2:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103ba8:	72 1c                	jb     f0103bc6 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0103baa:	c7 44 24 08 d0 72 10 	movl   $0xf01072d0,0x8(%esp)
f0103bb1:	f0 
f0103bb2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bb9:	00 
f0103bba:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0103bc1:	e8 7a c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bc9:	c1 e0 03             	shl    $0x3,%eax
f0103bcc:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
		page_decref(pa2page(pa));
f0103bd2:	89 04 24             	mov    %eax,(%esp)
f0103bd5:	e8 33 d4 ff ff       	call   f010100d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bda:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bde:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103be5:	0f 85 19 ff ff ff    	jne    f0103b04 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103beb:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bf3:	77 20                	ja     f0103c15 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bf9:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0103c00:	f0 
f0103c01:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
f0103c08:	00 
f0103c09:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103c10:	e8 2b c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c15:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c1c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c21:	c1 e8 0c             	shr    $0xc,%eax
f0103c24:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103c2a:	72 1c                	jb     f0103c48 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f0103c2c:	c7 44 24 08 d0 72 10 	movl   $0xf01072d0,0x8(%esp)
f0103c33:	f0 
f0103c34:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c3b:	00 
f0103c3c:	c7 04 24 35 7b 10 f0 	movl   $0xf0107b35,(%esp)
f0103c43:	e8 f8 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c48:	c1 e0 03             	shl    $0x3,%eax
f0103c4b:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
	page_decref(pa2page(pa));
f0103c51:	89 04 24             	mov    %eax,(%esp)
f0103c54:	e8 b4 d3 ff ff       	call   f010100d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c59:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c60:	a1 4c 22 23 f0       	mov    0xf023224c,%eax
f0103c65:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c68:	89 3d 4c 22 23 f0    	mov    %edi,0xf023224c
}
f0103c6e:	83 c4 2c             	add    $0x2c,%esp
f0103c71:	5b                   	pop    %ebx
f0103c72:	5e                   	pop    %esi
f0103c73:	5f                   	pop    %edi
f0103c74:	5d                   	pop    %ebp
f0103c75:	c3                   	ret    

f0103c76 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c76:	55                   	push   %ebp
f0103c77:	89 e5                	mov    %esp,%ebp
f0103c79:	53                   	push   %ebx
f0103c7a:	83 ec 14             	sub    $0x14,%esp
f0103c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c80:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c84:	75 19                	jne    f0103c9f <env_destroy+0x29>
f0103c86:	e8 49 29 00 00       	call   f01065d4 <cpunum>
f0103c8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c8e:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f0103c94:	74 09                	je     f0103c9f <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c96:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c9d:	eb 2f                	jmp    f0103cce <env_destroy+0x58>
	}

	env_free(e);
f0103c9f:	89 1c 24             	mov    %ebx,(%esp)
f0103ca2:	e8 c8 fd ff ff       	call   f0103a6f <env_free>

	if (curenv == e) {
f0103ca7:	e8 28 29 00 00       	call   f01065d4 <cpunum>
f0103cac:	6b c0 74             	imul   $0x74,%eax,%eax
f0103caf:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f0103cb5:	75 17                	jne    f0103cce <env_destroy+0x58>
		curenv = NULL;
f0103cb7:	e8 18 29 00 00       	call   f01065d4 <cpunum>
f0103cbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbf:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f0103cc6:	00 00 00 
		sched_yield();
f0103cc9:	e8 0e 10 00 00       	call   f0104cdc <sched_yield>
	}
}
f0103cce:	83 c4 14             	add    $0x14,%esp
f0103cd1:	5b                   	pop    %ebx
f0103cd2:	5d                   	pop    %ebp
f0103cd3:	c3                   	ret    

f0103cd4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cd4:	55                   	push   %ebp
f0103cd5:	89 e5                	mov    %esp,%ebp
f0103cd7:	53                   	push   %ebx
f0103cd8:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cdb:	e8 f4 28 00 00       	call   f01065d4 <cpunum>
f0103ce0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce3:	8b 98 28 30 23 f0    	mov    -0xfdccfd8(%eax),%ebx
f0103ce9:	e8 e6 28 00 00       	call   f01065d4 <cpunum>
f0103cee:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103cf1:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cf4:	61                   	popa   
f0103cf5:	07                   	pop    %es
f0103cf6:	1f                   	pop    %ds
f0103cf7:	83 c4 08             	add    $0x8,%esp
f0103cfa:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cfb:	c7 44 24 08 f3 7e 10 	movl   $0xf0107ef3,0x8(%esp)
f0103d02:	f0 
f0103d03:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0103d0a:	00 
f0103d0b:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103d12:	e8 29 c3 ff ff       	call   f0100040 <_panic>

f0103d17 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d17:	55                   	push   %ebp
f0103d18:	89 e5                	mov    %esp,%ebp
f0103d1a:	53                   	push   %ebx
f0103d1b:	83 ec 14             	sub    $0x14,%esp
f0103d1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d21:	e8 ae 28 00 00       	call   f01065d4 <cpunum>
f0103d26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d29:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0103d30:	75 10                	jne    f0103d42 <env_run+0x2b>
		curenv = e;
f0103d32:	e8 9d 28 00 00       	call   f01065d4 <cpunum>
f0103d37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3a:	89 98 28 30 23 f0    	mov    %ebx,-0xfdccfd8(%eax)
f0103d40:	eb 29                	jmp    f0103d6b <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d42:	e8 8d 28 00 00       	call   f01065d4 <cpunum>
f0103d47:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d4a:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103d50:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d54:	75 15                	jne    f0103d6b <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d56:	e8 79 28 00 00       	call   f01065d4 <cpunum>
f0103d5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5e:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103d64:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d6b:	e8 64 28 00 00       	call   f01065d4 <cpunum>
f0103d70:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d73:	89 98 28 30 23 f0    	mov    %ebx,-0xfdccfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d79:	e8 56 28 00 00       	call   f01065d4 <cpunum>
f0103d7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d81:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103d87:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d8e:	e8 41 28 00 00       	call   f01065d4 <cpunum>
f0103d93:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d96:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103d9c:	83 40 58 01          	addl   $0x1,0x58(%eax)
//	cprintf("the eip is %x\n", curenv->env_id);
	lcr3( PADDR(curenv->env_pgdir) );
f0103da0:	e8 2f 28 00 00       	call   f01065d4 <cpunum>
f0103da5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da8:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103dae:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103db1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103db6:	77 20                	ja     f0103dd8 <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103db8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dbc:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0103dc3:	f0 
f0103dc4:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
f0103dcb:	00 
f0103dcc:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0103dd3:	e8 68 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103dd8:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ddd:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103de0:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103de7:	e8 34 2b 00 00       	call   f0106920 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103dec:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103dee:	e8 e1 27 00 00       	call   f01065d4 <cpunum>
f0103df3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df6:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103dfc:	89 04 24             	mov    %eax,(%esp)
f0103dff:	e8 d0 fe ff ff       	call   f0103cd4 <env_pop_tf>

f0103e04 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e04:	55                   	push   %ebp
f0103e05:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e07:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e0f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e10:	b2 71                	mov    $0x71,%dl
f0103e12:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e13:	0f b6 c0             	movzbl %al,%eax
}
f0103e16:	5d                   	pop    %ebp
f0103e17:	c3                   	ret    

f0103e18 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e18:	55                   	push   %ebp
f0103e19:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e1b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e20:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e23:	ee                   	out    %al,(%dx)
f0103e24:	b2 71                	mov    $0x71,%dl
f0103e26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e29:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e2a:	5d                   	pop    %ebp
f0103e2b:	c3                   	ret    

f0103e2c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e2c:	55                   	push   %ebp
f0103e2d:	89 e5                	mov    %esp,%ebp
f0103e2f:	56                   	push   %esi
f0103e30:	53                   	push   %ebx
f0103e31:	83 ec 10             	sub    $0x10,%esp
f0103e34:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e37:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e39:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e3f:	80 3d 50 22 23 f0 00 	cmpb   $0x0,0xf0232250
f0103e46:	74 4e                	je     f0103e96 <irq_setmask_8259A+0x6a>
f0103e48:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e4d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e4e:	89 f0                	mov    %esi,%eax
f0103e50:	66 c1 e8 08          	shr    $0x8,%ax
f0103e54:	b2 a1                	mov    $0xa1,%dl
f0103e56:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e57:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f0103e5e:	e8 0b 01 00 00       	call   f0103f6e <cprintf>
	for (i = 0; i < 16; i++)
f0103e63:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e68:	0f b7 f6             	movzwl %si,%esi
f0103e6b:	f7 d6                	not    %esi
f0103e6d:	0f a3 de             	bt     %ebx,%esi
f0103e70:	73 10                	jae    f0103e82 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103e72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e76:	c7 04 24 db 83 10 f0 	movl   $0xf01083db,(%esp)
f0103e7d:	e8 ec 00 00 00       	call   f0103f6e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e82:	83 c3 01             	add    $0x1,%ebx
f0103e85:	83 fb 10             	cmp    $0x10,%ebx
f0103e88:	75 e3                	jne    f0103e6d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e8a:	c7 04 24 20 7e 10 f0 	movl   $0xf0107e20,(%esp)
f0103e91:	e8 d8 00 00 00       	call   f0103f6e <cprintf>
}
f0103e96:	83 c4 10             	add    $0x10,%esp
f0103e99:	5b                   	pop    %ebx
f0103e9a:	5e                   	pop    %esi
f0103e9b:	5d                   	pop    %ebp
f0103e9c:	c3                   	ret    

f0103e9d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e9d:	55                   	push   %ebp
f0103e9e:	89 e5                	mov    %esp,%ebp
f0103ea0:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103ea3:	c6 05 50 22 23 f0 01 	movb   $0x1,0xf0232250
f0103eaa:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103eb4:	ee                   	out    %al,(%dx)
f0103eb5:	b2 a1                	mov    $0xa1,%dl
f0103eb7:	ee                   	out    %al,(%dx)
f0103eb8:	b2 20                	mov    $0x20,%dl
f0103eba:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ebf:	ee                   	out    %al,(%dx)
f0103ec0:	b2 21                	mov    $0x21,%dl
f0103ec2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ec7:	ee                   	out    %al,(%dx)
f0103ec8:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ecd:	ee                   	out    %al,(%dx)
f0103ece:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ed3:	ee                   	out    %al,(%dx)
f0103ed4:	b2 a0                	mov    $0xa0,%dl
f0103ed6:	b8 11 00 00 00       	mov    $0x11,%eax
f0103edb:	ee                   	out    %al,(%dx)
f0103edc:	b2 a1                	mov    $0xa1,%dl
f0103ede:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ee3:	ee                   	out    %al,(%dx)
f0103ee4:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ee9:	ee                   	out    %al,(%dx)
f0103eea:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eef:	ee                   	out    %al,(%dx)
f0103ef0:	b2 20                	mov    $0x20,%dl
f0103ef2:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ef7:	ee                   	out    %al,(%dx)
f0103ef8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103efd:	ee                   	out    %al,(%dx)
f0103efe:	b2 a0                	mov    $0xa0,%dl
f0103f00:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f05:	ee                   	out    %al,(%dx)
f0103f06:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f0b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f0c:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f13:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f17:	74 0b                	je     f0103f24 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0103f19:	0f b7 c0             	movzwl %ax,%eax
f0103f1c:	89 04 24             	mov    %eax,(%esp)
f0103f1f:	e8 08 ff ff ff       	call   f0103e2c <irq_setmask_8259A>
}
f0103f24:	c9                   	leave  
f0103f25:	c3                   	ret    
	...

f0103f28 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f28:	55                   	push   %ebp
f0103f29:	89 e5                	mov    %esp,%ebp
f0103f2b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f31:	89 04 24             	mov    %eax,(%esp)
f0103f34:	e8 31 c8 ff ff       	call   f010076a <cputchar>
	*cnt++;
}
f0103f39:	c9                   	leave  
f0103f3a:	c3                   	ret    

f0103f3b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f3b:	55                   	push   %ebp
f0103f3c:	89 e5                	mov    %esp,%ebp
f0103f3e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f52:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f56:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f5d:	c7 04 24 28 3f 10 f0 	movl   $0xf0103f28,(%esp)
f0103f64:	e8 54 19 00 00       	call   f01058bd <vprintfmt>
	return cnt;
}
f0103f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f6c:	c9                   	leave  
f0103f6d:	c3                   	ret    

f0103f6e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f6e:	55                   	push   %ebp
f0103f6f:	89 e5                	mov    %esp,%ebp
f0103f71:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f74:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f7e:	89 04 24             	mov    %eax,(%esp)
f0103f81:	e8 b5 ff ff ff       	call   f0103f3b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f86:	c9                   	leave  
f0103f87:	c3                   	ret    
	...

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
f0103f99:	e8 36 26 00 00       	call   f01065d4 <cpunum>
f0103f9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa1:	0f b6 98 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103fa8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fac:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103fb3:	e8 b6 ff ff ff       	call   f0103f6e <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fb8:	e8 17 26 00 00       	call   f01065d4 <cpunum>
f0103fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc0:	89 da                	mov    %ebx,%edx
f0103fc2:	f7 da                	neg    %edx
f0103fc4:	c1 e2 10             	shl    $0x10,%edx
f0103fc7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fcd:	89 90 30 30 23 f0    	mov    %edx,-0xfdccfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fd3:	e8 fc 25 00 00       	call   f01065d4 <cpunum>
f0103fd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdb:	66 c7 80 34 30 23 f0 	movw   $0x10,-0xfdccfcc(%eax)
f0103fe2:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0103fe4:	83 c3 05             	add    $0x5,%ebx
f0103fe7:	e8 e8 25 00 00       	call   f01065d4 <cpunum>
f0103fec:	89 c6                	mov    %eax,%esi
f0103fee:	e8 e1 25 00 00       	call   f01065d4 <cpunum>
f0103ff3:	89 c7                	mov    %eax,%edi
f0103ff5:	e8 da 25 00 00       	call   f01065d4 <cpunum>
f0103ffa:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0104001:	f0 67 00 
f0104004:	6b f6 74             	imul   $0x74,%esi,%esi
f0104007:	81 c6 2c 30 23 f0    	add    $0xf023302c,%esi
f010400d:	66 89 34 dd 42 13 12 	mov    %si,-0xfedecbe(,%ebx,8)
f0104014:	f0 
f0104015:	6b d7 74             	imul   $0x74,%edi,%edx
f0104018:	81 c2 2c 30 23 f0    	add    $0xf023302c,%edx
f010401e:	c1 ea 10             	shr    $0x10,%edx
f0104021:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104028:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010402f:	40 
f0104030:	6b c0 74             	imul   $0x74,%eax,%eax
f0104033:	05 2c 30 23 f0       	add    $0xf023302c,%eax
f0104038:	c1 e8 18             	shr    $0x18,%eax
f010403b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104042:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
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
f0104050:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
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
    void handlerIRQ7();
    void handlerIRQ14();
    void handlerIRQ19();
 

    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104066:	b8 f0 4a 10 f0       	mov    $0xf0104af0,%eax
f010406b:	66 a3 60 22 23 f0    	mov    %ax,0xf0232260
f0104071:	66 c7 05 62 22 23 f0 	movw   $0x8,0xf0232262
f0104078:	08 00 
f010407a:	c6 05 64 22 23 f0 00 	movb   $0x0,0xf0232264
f0104081:	c6 05 65 22 23 f0 8e 	movb   $0x8e,0xf0232265
f0104088:	c1 e8 10             	shr    $0x10,%eax
f010408b:	66 a3 66 22 23 f0    	mov    %ax,0xf0232266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f0104091:	b8 fa 4a 10 f0       	mov    $0xf0104afa,%eax
f0104096:	66 a3 68 22 23 f0    	mov    %ax,0xf0232268
f010409c:	66 c7 05 6a 22 23 f0 	movw   $0x8,0xf023226a
f01040a3:	08 00 
f01040a5:	c6 05 6c 22 23 f0 00 	movb   $0x0,0xf023226c
f01040ac:	c6 05 6d 22 23 f0 8e 	movb   $0x8e,0xf023226d
f01040b3:	c1 e8 10             	shr    $0x10,%eax
f01040b6:	66 a3 6e 22 23 f0    	mov    %ax,0xf023226e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040bc:	b8 04 4b 10 f0       	mov    $0xf0104b04,%eax
f01040c1:	66 a3 70 22 23 f0    	mov    %ax,0xf0232270
f01040c7:	66 c7 05 72 22 23 f0 	movw   $0x8,0xf0232272
f01040ce:	08 00 
f01040d0:	c6 05 74 22 23 f0 00 	movb   $0x0,0xf0232274
f01040d7:	c6 05 75 22 23 f0 8e 	movb   $0x8e,0xf0232275
f01040de:	c1 e8 10             	shr    $0x10,%eax
f01040e1:	66 a3 76 22 23 f0    	mov    %ax,0xf0232276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01040e7:	b8 0e 4b 10 f0       	mov    $0xf0104b0e,%eax
f01040ec:	66 a3 78 22 23 f0    	mov    %ax,0xf0232278
f01040f2:	66 c7 05 7a 22 23 f0 	movw   $0x8,0xf023227a
f01040f9:	08 00 
f01040fb:	c6 05 7c 22 23 f0 00 	movb   $0x0,0xf023227c
f0104102:	c6 05 7d 22 23 f0 ee 	movb   $0xee,0xf023227d
f0104109:	c1 e8 10             	shr    $0x10,%eax
f010410c:	66 a3 7e 22 23 f0    	mov    %ax,0xf023227e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104112:	b8 18 4b 10 f0       	mov    $0xf0104b18,%eax
f0104117:	66 a3 80 22 23 f0    	mov    %ax,0xf0232280
f010411d:	66 c7 05 82 22 23 f0 	movw   $0x8,0xf0232282
f0104124:	08 00 
f0104126:	c6 05 84 22 23 f0 00 	movb   $0x0,0xf0232284
f010412d:	c6 05 85 22 23 f0 8e 	movb   $0x8e,0xf0232285
f0104134:	c1 e8 10             	shr    $0x10,%eax
f0104137:	66 a3 86 22 23 f0    	mov    %ax,0xf0232286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010413d:	b8 22 4b 10 f0       	mov    $0xf0104b22,%eax
f0104142:	66 a3 88 22 23 f0    	mov    %ax,0xf0232288
f0104148:	66 c7 05 8a 22 23 f0 	movw   $0x8,0xf023228a
f010414f:	08 00 
f0104151:	c6 05 8c 22 23 f0 00 	movb   $0x0,0xf023228c
f0104158:	c6 05 8d 22 23 f0 8e 	movb   $0x8e,0xf023228d
f010415f:	c1 e8 10             	shr    $0x10,%eax
f0104162:	66 a3 8e 22 23 f0    	mov    %ax,0xf023228e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104168:	b8 2c 4b 10 f0       	mov    $0xf0104b2c,%eax
f010416d:	66 a3 90 22 23 f0    	mov    %ax,0xf0232290
f0104173:	66 c7 05 92 22 23 f0 	movw   $0x8,0xf0232292
f010417a:	08 00 
f010417c:	c6 05 94 22 23 f0 00 	movb   $0x0,0xf0232294
f0104183:	c6 05 95 22 23 f0 8e 	movb   $0x8e,0xf0232295
f010418a:	c1 e8 10             	shr    $0x10,%eax
f010418d:	66 a3 96 22 23 f0    	mov    %ax,0xf0232296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f0104193:	b8 36 4b 10 f0       	mov    $0xf0104b36,%eax
f0104198:	66 a3 98 22 23 f0    	mov    %ax,0xf0232298
f010419e:	66 c7 05 9a 22 23 f0 	movw   $0x8,0xf023229a
f01041a5:	08 00 
f01041a7:	c6 05 9c 22 23 f0 00 	movb   $0x0,0xf023229c
f01041ae:	c6 05 9d 22 23 f0 8e 	movb   $0x8e,0xf023229d
f01041b5:	c1 e8 10             	shr    $0x10,%eax
f01041b8:	66 a3 9e 22 23 f0    	mov    %ax,0xf023229e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041be:	b8 40 4b 10 f0       	mov    $0xf0104b40,%eax
f01041c3:	66 a3 a0 22 23 f0    	mov    %ax,0xf02322a0
f01041c9:	66 c7 05 a2 22 23 f0 	movw   $0x8,0xf02322a2
f01041d0:	08 00 
f01041d2:	c6 05 a4 22 23 f0 00 	movb   $0x0,0xf02322a4
f01041d9:	c6 05 a5 22 23 f0 8e 	movb   $0x8e,0xf02322a5
f01041e0:	c1 e8 10             	shr    $0x10,%eax
f01041e3:	66 a3 a6 22 23 f0    	mov    %ax,0xf02322a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01041e9:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f01041ee:	66 a3 a8 22 23 f0    	mov    %ax,0xf02322a8
f01041f4:	66 c7 05 aa 22 23 f0 	movw   $0x8,0xf02322aa
f01041fb:	08 00 
f01041fd:	c6 05 ac 22 23 f0 00 	movb   $0x0,0xf02322ac
f0104204:	c6 05 ad 22 23 f0 8e 	movb   $0x8e,0xf02322ad
f010420b:	c1 e8 10             	shr    $0x10,%eax
f010420e:	66 a3 ae 22 23 f0    	mov    %ax,0xf02322ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104214:	b8 52 4b 10 f0       	mov    $0xf0104b52,%eax
f0104219:	66 a3 b0 22 23 f0    	mov    %ax,0xf02322b0
f010421f:	66 c7 05 b2 22 23 f0 	movw   $0x8,0xf02322b2
f0104226:	08 00 
f0104228:	c6 05 b4 22 23 f0 00 	movb   $0x0,0xf02322b4
f010422f:	c6 05 b5 22 23 f0 8e 	movb   $0x8e,0xf02322b5
f0104236:	c1 e8 10             	shr    $0x10,%eax
f0104239:	66 a3 b6 22 23 f0    	mov    %ax,0xf02322b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010423f:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f0104244:	66 a3 b8 22 23 f0    	mov    %ax,0xf02322b8
f010424a:	66 c7 05 ba 22 23 f0 	movw   $0x8,0xf02322ba
f0104251:	08 00 
f0104253:	c6 05 bc 22 23 f0 00 	movb   $0x0,0xf02322bc
f010425a:	c6 05 bd 22 23 f0 8e 	movb   $0x8e,0xf02322bd
f0104261:	c1 e8 10             	shr    $0x10,%eax
f0104264:	66 a3 be 22 23 f0    	mov    %ax,0xf02322be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010426a:	b8 62 4b 10 f0       	mov    $0xf0104b62,%eax
f010426f:	66 a3 c0 22 23 f0    	mov    %ax,0xf02322c0
f0104275:	66 c7 05 c2 22 23 f0 	movw   $0x8,0xf02322c2
f010427c:	08 00 
f010427e:	c6 05 c4 22 23 f0 00 	movb   $0x0,0xf02322c4
f0104285:	c6 05 c5 22 23 f0 8e 	movb   $0x8e,0xf02322c5
f010428c:	c1 e8 10             	shr    $0x10,%eax
f010428f:	66 a3 c6 22 23 f0    	mov    %ax,0xf02322c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f0104295:	b8 6a 4b 10 f0       	mov    $0xf0104b6a,%eax
f010429a:	66 a3 c8 22 23 f0    	mov    %ax,0xf02322c8
f01042a0:	66 c7 05 ca 22 23 f0 	movw   $0x8,0xf02322ca
f01042a7:	08 00 
f01042a9:	c6 05 cc 22 23 f0 00 	movb   $0x0,0xf02322cc
f01042b0:	c6 05 cd 22 23 f0 8e 	movb   $0x8e,0xf02322cd
f01042b7:	c1 e8 10             	shr    $0x10,%eax
f01042ba:	66 a3 ce 22 23 f0    	mov    %ax,0xf02322ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042c0:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f01042c5:	66 a3 d0 22 23 f0    	mov    %ax,0xf02322d0
f01042cb:	66 c7 05 d2 22 23 f0 	movw   $0x8,0xf02322d2
f01042d2:	08 00 
f01042d4:	c6 05 d4 22 23 f0 00 	movb   $0x0,0xf02322d4
f01042db:	c6 05 d5 22 23 f0 8e 	movb   $0x8e,0xf02322d5
f01042e2:	c1 e8 10             	shr    $0x10,%eax
f01042e5:	66 a3 d6 22 23 f0    	mov    %ax,0xf02322d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01042eb:	b8 7a 4b 10 f0       	mov    $0xf0104b7a,%eax
f01042f0:	66 a3 d8 22 23 f0    	mov    %ax,0xf02322d8
f01042f6:	66 c7 05 da 22 23 f0 	movw   $0x8,0xf02322da
f01042fd:	08 00 
f01042ff:	c6 05 dc 22 23 f0 00 	movb   $0x0,0xf02322dc
f0104306:	c6 05 dd 22 23 f0 8e 	movb   $0x8e,0xf02322dd
f010430d:	c1 e8 10             	shr    $0x10,%eax
f0104310:	66 a3 de 22 23 f0    	mov    %ax,0xf02322de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104316:	b8 84 4b 10 f0       	mov    $0xf0104b84,%eax
f010431b:	66 a3 e0 22 23 f0    	mov    %ax,0xf02322e0
f0104321:	66 c7 05 e2 22 23 f0 	movw   $0x8,0xf02322e2
f0104328:	08 00 
f010432a:	c6 05 e4 22 23 f0 00 	movb   $0x0,0xf02322e4
f0104331:	c6 05 e5 22 23 f0 8e 	movb   $0x8e,0xf02322e5
f0104338:	c1 e8 10             	shr    $0x10,%eax
f010433b:	66 a3 e6 22 23 f0    	mov    %ax,0xf02322e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104341:	b8 8e 4b 10 f0       	mov    $0xf0104b8e,%eax
f0104346:	66 a3 e8 22 23 f0    	mov    %ax,0xf02322e8
f010434c:	66 c7 05 ea 22 23 f0 	movw   $0x8,0xf02322ea
f0104353:	08 00 
f0104355:	c6 05 ec 22 23 f0 00 	movb   $0x0,0xf02322ec
f010435c:	c6 05 ed 22 23 f0 8e 	movb   $0x8e,0xf02322ed
f0104363:	c1 e8 10             	shr    $0x10,%eax
f0104366:	66 a3 ee 22 23 f0    	mov    %ax,0xf02322ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010436c:	b8 96 4b 10 f0       	mov    $0xf0104b96,%eax
f0104371:	66 a3 f0 22 23 f0    	mov    %ax,0xf02322f0
f0104377:	66 c7 05 f2 22 23 f0 	movw   $0x8,0xf02322f2
f010437e:	08 00 
f0104380:	c6 05 f4 22 23 f0 00 	movb   $0x0,0xf02322f4
f0104387:	c6 05 f5 22 23 f0 8e 	movb   $0x8e,0xf02322f5
f010438e:	c1 e8 10             	shr    $0x10,%eax
f0104391:	66 a3 f6 22 23 f0    	mov    %ax,0xf02322f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f0104397:	b8 a0 4b 10 f0       	mov    $0xf0104ba0,%eax
f010439c:	66 a3 f8 22 23 f0    	mov    %ax,0xf02322f8
f01043a2:	66 c7 05 fa 22 23 f0 	movw   $0x8,0xf02322fa
f01043a9:	08 00 
f01043ab:	c6 05 fc 22 23 f0 00 	movb   $0x0,0xf02322fc
f01043b2:	c6 05 fd 22 23 f0 8e 	movb   $0x8e,0xf02322fd
f01043b9:	c1 e8 10             	shr    $0x10,%eax
f01043bc:	66 a3 fe 22 23 f0    	mov    %ax,0xf02322fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043c2:	b8 aa 4b 10 f0       	mov    $0xf0104baa,%eax
f01043c7:	66 a3 e0 23 23 f0    	mov    %ax,0xf02323e0
f01043cd:	66 c7 05 e2 23 23 f0 	movw   $0x8,0xf02323e2
f01043d4:	08 00 
f01043d6:	c6 05 e4 23 23 f0 00 	movb   $0x0,0xf02323e4
f01043dd:	c6 05 e5 23 23 f0 ee 	movb   $0xee,0xf02323e5
f01043e4:	c1 e8 10             	shr    $0x10,%eax
f01043e7:	66 a3 e6 23 23 f0    	mov    %ax,0xf02323e6

    //lab4
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 	0, GD_KT, handlerIRQ0, 0);
f01043ed:	b8 b4 4b 10 f0       	mov    $0xf0104bb4,%eax
f01043f2:	66 a3 60 23 23 f0    	mov    %ax,0xf0232360
f01043f8:	66 c7 05 62 23 23 f0 	movw   $0x8,0xf0232362
f01043ff:	08 00 
f0104401:	c6 05 64 23 23 f0 00 	movb   $0x0,0xf0232364
f0104408:	c6 05 65 23 23 f0 8e 	movb   $0x8e,0xf0232365
f010440f:	c1 e8 10             	shr    $0x10,%eax
f0104412:	66 a3 66 23 23 f0    	mov    %ax,0xf0232366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 	0, GD_KT, handlerIRQ1, 0);
f0104418:	b8 be 4b 10 f0       	mov    $0xf0104bbe,%eax
f010441d:	66 a3 68 23 23 f0    	mov    %ax,0xf0232368
f0104423:	66 c7 05 6a 23 23 f0 	movw   $0x8,0xf023236a
f010442a:	08 00 
f010442c:	c6 05 6c 23 23 f0 00 	movb   $0x0,0xf023236c
f0104433:	c6 05 6d 23 23 f0 8e 	movb   $0x8e,0xf023236d
f010443a:	c1 e8 10             	shr    $0x10,%eax
f010443d:	66 a3 6e 23 23 f0    	mov    %ax,0xf023236e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, handlerIRQ4, 0);
f0104443:	b8 c8 4b 10 f0       	mov    $0xf0104bc8,%eax
f0104448:	66 a3 80 23 23 f0    	mov    %ax,0xf0232380
f010444e:	66 c7 05 82 23 23 f0 	movw   $0x8,0xf0232382
f0104455:	08 00 
f0104457:	c6 05 84 23 23 f0 00 	movb   $0x0,0xf0232384
f010445e:	c6 05 85 23 23 f0 8e 	movb   $0x8e,0xf0232385
f0104465:	c1 e8 10             	shr    $0x10,%eax
f0104468:	66 a3 86 23 23 f0    	mov    %ax,0xf0232386
    SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, handlerIRQ7, 0);
f010446e:	b8 d2 4b 10 f0       	mov    $0xf0104bd2,%eax
f0104473:	66 a3 98 23 23 f0    	mov    %ax,0xf0232398
f0104479:	66 c7 05 9a 23 23 f0 	movw   $0x8,0xf023239a
f0104480:	08 00 
f0104482:	c6 05 9c 23 23 f0 00 	movb   $0x0,0xf023239c
f0104489:	c6 05 9d 23 23 f0 8e 	movb   $0x8e,0xf023239d
f0104490:	c1 e8 10             	shr    $0x10,%eax
f0104493:	66 a3 9e 23 23 f0    	mov    %ax,0xf023239e
    SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 	0, GD_KT, handlerIRQ14, 0);
f0104499:	b8 dc 4b 10 f0       	mov    $0xf0104bdc,%eax
f010449e:	66 a3 d0 23 23 f0    	mov    %ax,0xf02323d0
f01044a4:	66 c7 05 d2 23 23 f0 	movw   $0x8,0xf02323d2
f01044ab:	08 00 
f01044ad:	c6 05 d4 23 23 f0 00 	movb   $0x0,0xf02323d4
f01044b4:	c6 05 d5 23 23 f0 8e 	movb   $0x8e,0xf02323d5
f01044bb:	c1 e8 10             	shr    $0x10,%eax
f01044be:	66 a3 d6 23 23 f0    	mov    %ax,0xf02323d6
    SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 	0, GD_KT, handlerIRQ19, 0);
f01044c4:	b8 e6 4b 10 f0       	mov    $0xf0104be6,%eax
f01044c9:	66 a3 f8 23 23 f0    	mov    %ax,0xf02323f8
f01044cf:	66 c7 05 fa 23 23 f0 	movw   $0x8,0xf02323fa
f01044d6:	08 00 
f01044d8:	c6 05 fc 23 23 f0 00 	movb   $0x0,0xf02323fc
f01044df:	c6 05 fd 23 23 f0 8e 	movb   $0x8e,0xf02323fd
f01044e6:	c1 e8 10             	shr    $0x10,%eax
f01044e9:	66 a3 fe 23 23 f0    	mov    %ax,0xf02323fe




	// Per-CPU setup 
	trap_init_percpu();
f01044ef:	e8 9c fa ff ff       	call   f0103f90 <trap_init_percpu>
}
f01044f4:	c9                   	leave  
f01044f5:	c3                   	ret    

f01044f6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044f6:	55                   	push   %ebp
f01044f7:	89 e5                	mov    %esp,%ebp
f01044f9:	53                   	push   %ebx
f01044fa:	83 ec 14             	sub    $0x14,%esp
f01044fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104500:	8b 03                	mov    (%ebx),%eax
f0104502:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104506:	c7 04 24 21 7f 10 f0 	movl   $0xf0107f21,(%esp)
f010450d:	e8 5c fa ff ff       	call   f0103f6e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104512:	8b 43 04             	mov    0x4(%ebx),%eax
f0104515:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104519:	c7 04 24 30 7f 10 f0 	movl   $0xf0107f30,(%esp)
f0104520:	e8 49 fa ff ff       	call   f0103f6e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104525:	8b 43 08             	mov    0x8(%ebx),%eax
f0104528:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452c:	c7 04 24 3f 7f 10 f0 	movl   $0xf0107f3f,(%esp)
f0104533:	e8 36 fa ff ff       	call   f0103f6e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104538:	8b 43 0c             	mov    0xc(%ebx),%eax
f010453b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010453f:	c7 04 24 4e 7f 10 f0 	movl   $0xf0107f4e,(%esp)
f0104546:	e8 23 fa ff ff       	call   f0103f6e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010454b:	8b 43 10             	mov    0x10(%ebx),%eax
f010454e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104552:	c7 04 24 5d 7f 10 f0 	movl   $0xf0107f5d,(%esp)
f0104559:	e8 10 fa ff ff       	call   f0103f6e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010455e:	8b 43 14             	mov    0x14(%ebx),%eax
f0104561:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104565:	c7 04 24 6c 7f 10 f0 	movl   $0xf0107f6c,(%esp)
f010456c:	e8 fd f9 ff ff       	call   f0103f6e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104571:	8b 43 18             	mov    0x18(%ebx),%eax
f0104574:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104578:	c7 04 24 7b 7f 10 f0 	movl   $0xf0107f7b,(%esp)
f010457f:	e8 ea f9 ff ff       	call   f0103f6e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104584:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104587:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458b:	c7 04 24 8a 7f 10 f0 	movl   $0xf0107f8a,(%esp)
f0104592:	e8 d7 f9 ff ff       	call   f0103f6e <cprintf>
}
f0104597:	83 c4 14             	add    $0x14,%esp
f010459a:	5b                   	pop    %ebx
f010459b:	5d                   	pop    %ebp
f010459c:	c3                   	ret    

f010459d <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f010459d:	55                   	push   %ebp
f010459e:	89 e5                	mov    %esp,%ebp
f01045a0:	56                   	push   %esi
f01045a1:	53                   	push   %ebx
f01045a2:	83 ec 10             	sub    $0x10,%esp
f01045a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045a8:	e8 27 20 00 00       	call   f01065d4 <cpunum>
f01045ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045b5:	c7 04 24 ee 7f 10 f0 	movl   $0xf0107fee,(%esp)
f01045bc:	e8 ad f9 ff ff       	call   f0103f6e <cprintf>
	print_regs(&tf->tf_regs);
f01045c1:	89 1c 24             	mov    %ebx,(%esp)
f01045c4:	e8 2d ff ff ff       	call   f01044f6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045c9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d1:	c7 04 24 0c 80 10 f0 	movl   $0xf010800c,(%esp)
f01045d8:	e8 91 f9 ff ff       	call   f0103f6e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045dd:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e5:	c7 04 24 1f 80 10 f0 	movl   $0xf010801f,(%esp)
f01045ec:	e8 7d f9 ff ff       	call   f0103f6e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045f1:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045f4:	83 f8 13             	cmp    $0x13,%eax
f01045f7:	77 09                	ja     f0104602 <print_trapframe+0x65>
		return excnames[trapno];
f01045f9:	8b 14 85 c0 82 10 f0 	mov    -0xfef7d40(,%eax,4),%edx
f0104600:	eb 1d                	jmp    f010461f <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f0104602:	ba 99 7f 10 f0       	mov    $0xf0107f99,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104607:	83 f8 30             	cmp    $0x30,%eax
f010460a:	74 13                	je     f010461f <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010460c:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010460f:	83 fa 0f             	cmp    $0xf,%edx
f0104612:	ba a5 7f 10 f0       	mov    $0xf0107fa5,%edx
f0104617:	b9 b8 7f 10 f0       	mov    $0xf0107fb8,%ecx
f010461c:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010461f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104623:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104627:	c7 04 24 32 80 10 f0 	movl   $0xf0108032,(%esp)
f010462e:	e8 3b f9 ff ff       	call   f0103f6e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104633:	3b 1d 60 2a 23 f0    	cmp    0xf0232a60,%ebx
f0104639:	75 19                	jne    f0104654 <print_trapframe+0xb7>
f010463b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010463f:	75 13                	jne    f0104654 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104641:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104644:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104648:	c7 04 24 44 80 10 f0 	movl   $0xf0108044,(%esp)
f010464f:	e8 1a f9 ff ff       	call   f0103f6e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104654:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104657:	89 44 24 04          	mov    %eax,0x4(%esp)
f010465b:	c7 04 24 53 80 10 f0 	movl   $0xf0108053,(%esp)
f0104662:	e8 07 f9 ff ff       	call   f0103f6e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104667:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010466b:	75 51                	jne    f01046be <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010466d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104670:	89 c2                	mov    %eax,%edx
f0104672:	83 e2 01             	and    $0x1,%edx
f0104675:	ba c7 7f 10 f0       	mov    $0xf0107fc7,%edx
f010467a:	b9 d2 7f 10 f0       	mov    $0xf0107fd2,%ecx
f010467f:	0f 45 ca             	cmovne %edx,%ecx
f0104682:	89 c2                	mov    %eax,%edx
f0104684:	83 e2 02             	and    $0x2,%edx
f0104687:	ba de 7f 10 f0       	mov    $0xf0107fde,%edx
f010468c:	be e4 7f 10 f0       	mov    $0xf0107fe4,%esi
f0104691:	0f 44 d6             	cmove  %esi,%edx
f0104694:	83 e0 04             	and    $0x4,%eax
f0104697:	b8 e9 7f 10 f0       	mov    $0xf0107fe9,%eax
f010469c:	be 1e 81 10 f0       	mov    $0xf010811e,%esi
f01046a1:	0f 44 c6             	cmove  %esi,%eax
f01046a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046a8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b0:	c7 04 24 61 80 10 f0 	movl   $0xf0108061,(%esp)
f01046b7:	e8 b2 f8 ff ff       	call   f0103f6e <cprintf>
f01046bc:	eb 0c                	jmp    f01046ca <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01046be:	c7 04 24 20 7e 10 f0 	movl   $0xf0107e20,(%esp)
f01046c5:	e8 a4 f8 ff ff       	call   f0103f6e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046ca:	8b 43 30             	mov    0x30(%ebx),%eax
f01046cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d1:	c7 04 24 70 80 10 f0 	movl   $0xf0108070,(%esp)
f01046d8:	e8 91 f8 ff ff       	call   f0103f6e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046dd:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e5:	c7 04 24 7f 80 10 f0 	movl   $0xf010807f,(%esp)
f01046ec:	e8 7d f8 ff ff       	call   f0103f6e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046f1:	8b 43 38             	mov    0x38(%ebx),%eax
f01046f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f8:	c7 04 24 92 80 10 f0 	movl   $0xf0108092,(%esp)
f01046ff:	e8 6a f8 ff ff       	call   f0103f6e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104704:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104708:	74 27                	je     f0104731 <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010470a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010470d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104711:	c7 04 24 a1 80 10 f0 	movl   $0xf01080a1,(%esp)
f0104718:	e8 51 f8 ff ff       	call   f0103f6e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010471d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104721:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104725:	c7 04 24 b0 80 10 f0 	movl   $0xf01080b0,(%esp)
f010472c:	e8 3d f8 ff ff       	call   f0103f6e <cprintf>
	}
}
f0104731:	83 c4 10             	add    $0x10,%esp
f0104734:	5b                   	pop    %ebx
f0104735:	5e                   	pop    %esi
f0104736:	5d                   	pop    %ebp
f0104737:	c3                   	ret    

f0104738 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104738:	55                   	push   %ebp
f0104739:	89 e5                	mov    %esp,%ebp
f010473b:	57                   	push   %edi
f010473c:	56                   	push   %esi
f010473d:	53                   	push   %ebx
f010473e:	83 ec 5c             	sub    $0x5c,%esp
f0104741:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104744:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104747:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010474c:	75 1c                	jne    f010476a <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f010474e:	c7 44 24 08 68 82 10 	movl   $0xf0108268,0x8(%esp)
f0104755:	f0 
f0104756:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f010475d:	00 
f010475e:	c7 04 24 c3 80 10 f0 	movl   $0xf01080c3,(%esp)
f0104765:	e8 d6 b8 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
f010476a:	e8 65 1e 00 00       	call   f01065d4 <cpunum>
f010476f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104772:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104778:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010477c:	75 4a                	jne    f01047c8 <page_fault_handler+0x90>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010477e:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104781:	e8 4e 1e 00 00       	call   f01065d4 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104786:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010478a:	89 7c 24 08          	mov    %edi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f010478e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104791:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104797:	8b 40 48             	mov    0x48(%eax),%eax
f010479a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010479e:	c7 04 24 8c 82 10 f0 	movl   $0xf010828c,(%esp)
f01047a5:	e8 c4 f7 ff ff       	call   f0103f6e <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f01047aa:	89 1c 24             	mov    %ebx,(%esp)
f01047ad:	e8 eb fd ff ff       	call   f010459d <print_trapframe>
		env_destroy(curenv);
f01047b2:	e8 1d 1e 00 00       	call   f01065d4 <cpunum>
f01047b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ba:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01047c0:	89 04 24             	mov    %eax,(%esp)
f01047c3:	e8 ae f4 ff ff       	call   f0103c76 <env_destroy>

	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f01047c8:	8b 73 3c             	mov    0x3c(%ebx),%esi
f01047cb:	8d 86 00 10 40 11    	lea    0x11401000(%esi),%eax
		
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		//note: it is not like the requirement!!! there is two block
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -8;
f01047d1:	83 ee 3c             	sub    $0x3c,%esi
f01047d4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01047d9:	b8 cc ff bf ee       	mov    $0xeebfffcc,%eax
f01047de:	0f 47 f0             	cmova  %eax,%esi
	
	user_mem_assert(curenv, (void*)newEsp, 0, PTE_U|PTE_W|PTE_P);
f01047e1:	e8 ee 1d 00 00       	call   f01065d4 <cpunum>
f01047e6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01047ed:	00 
f01047ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01047f5:	00 
f01047f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fd:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104803:	89 04 24             	mov    %eax,(%esp)
f0104806:	e8 fe ec ff ff       	call   f0103509 <user_mem_assert>

	UT.utf_err = tf->tf_err;
f010480b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010480e:	89 45 b8             	mov    %eax,-0x48(%ebp)
	UT.utf_regs = tf->tf_regs;
f0104811:	8b 03                	mov    (%ebx),%eax
f0104813:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0104816:	8b 43 04             	mov    0x4(%ebx),%eax
f0104819:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010481c:	8b 43 08             	mov    0x8(%ebx),%eax
f010481f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104822:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104825:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104828:	8b 43 10             	mov    0x10(%ebx),%eax
f010482b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010482e:	8b 43 14             	mov    0x14(%ebx),%eax
f0104831:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104834:	8b 43 18             	mov    0x18(%ebx),%eax
f0104837:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010483a:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010483d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	UT.utf_eflags = tf->tf_eflags;
f0104840:	8b 43 38             	mov    0x38(%ebx),%eax
f0104843:	89 45 e0             	mov    %eax,-0x20(%ebp)
	UT.utf_eip = tf->tf_eip;
f0104846:	8b 43 30             	mov    0x30(%ebx),%eax
f0104849:	89 45 dc             	mov    %eax,-0x24(%ebp)
	UT.utf_esp = tf->tf_esp;
f010484c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010484f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	UT.utf_fault_va = fault_va;
f0104852:	89 7d b4             	mov    %edi,-0x4c(%ebp)

	user_mem_assert(curenv,(void*)newEsp, sizeof(struct UTrapframe),PTE_U|PTE_P|PTE_W );
f0104855:	e8 7a 1d 00 00       	call   f01065d4 <cpunum>
f010485a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104861:	00 
f0104862:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104869:	00 
f010486a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010486e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104871:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104877:	89 04 24             	mov    %eax,(%esp)
f010487a:	e8 8a ec ff ff       	call   f0103509 <user_mem_assert>
	memcpy((void*)newEsp, (&UT) ,sizeof(struct UTrapframe));
f010487f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104886:	00 
f0104887:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f010488a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010488e:	89 34 24             	mov    %esi,(%esp)
f0104891:	e8 b1 17 00 00       	call   f0106047 <memcpy>
	tf->tf_esp = newEsp;
f0104896:	89 73 3c             	mov    %esi,0x3c(%ebx)
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104899:	e8 36 1d 00 00       	call   f01065d4 <cpunum>
f010489e:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a1:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01048a7:	8b 40 64             	mov    0x64(%eax),%eax
f01048aa:	89 43 30             	mov    %eax,0x30(%ebx)
	env_run(curenv);
f01048ad:	e8 22 1d 00 00       	call   f01065d4 <cpunum>
f01048b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b5:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01048bb:	89 04 24             	mov    %eax,(%esp)
f01048be:	e8 54 f4 ff ff       	call   f0103d17 <env_run>

f01048c3 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048c3:	55                   	push   %ebp
f01048c4:	89 e5                	mov    %esp,%ebp
f01048c6:	57                   	push   %edi
f01048c7:	56                   	push   %esi
f01048c8:	83 ec 20             	sub    $0x20,%esp
f01048cb:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01048ce:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01048cf:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f01048d6:	74 01                	je     f01048d9 <trap+0x16>
		asm volatile("hlt");
f01048d8:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048d9:	e8 f6 1c 00 00       	call   f01065d4 <cpunum>
f01048de:	6b d0 74             	imul   $0x74,%eax,%edx
f01048e1:	81 c2 20 30 23 f0    	add    $0xf0233020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048e7:	b8 01 00 00 00       	mov    $0x1,%eax
f01048ec:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01048f0:	83 f8 02             	cmp    $0x2,%eax
f01048f3:	75 0c                	jne    f0104901 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01048f5:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01048fc:	e8 83 1f 00 00       	call   f0106884 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104901:	9c                   	pushf  
f0104902:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104903:	f6 c4 02             	test   $0x2,%ah
f0104906:	74 24                	je     f010492c <trap+0x69>
f0104908:	c7 44 24 0c cf 80 10 	movl   $0xf01080cf,0xc(%esp)
f010490f:	f0 
f0104910:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0104917:	f0 
f0104918:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f010491f:	00 
f0104920:	c7 04 24 c3 80 10 f0 	movl   $0xf01080c3,(%esp)
f0104927:	e8 14 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010492c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104930:	83 e0 03             	and    $0x3,%eax
f0104933:	83 f8 03             	cmp    $0x3,%eax
f0104936:	0f 85 a7 00 00 00    	jne    f01049e3 <trap+0x120>
f010493c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104943:	e8 3c 1f 00 00       	call   f0106884 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104948:	e8 87 1c 00 00       	call   f01065d4 <cpunum>
f010494d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104950:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0104957:	75 24                	jne    f010497d <trap+0xba>
f0104959:	c7 44 24 0c e8 80 10 	movl   $0xf01080e8,0xc(%esp)
f0104960:	f0 
f0104961:	c7 44 24 08 4f 7b 10 	movl   $0xf0107b4f,0x8(%esp)
f0104968:	f0 
f0104969:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0104970:	00 
f0104971:	c7 04 24 c3 80 10 f0 	movl   $0xf01080c3,(%esp)
f0104978:	e8 c3 b6 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010497d:	e8 52 1c 00 00       	call   f01065d4 <cpunum>
f0104982:	6b c0 74             	imul   $0x74,%eax,%eax
f0104985:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010498b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010498f:	75 2d                	jne    f01049be <trap+0xfb>
			env_free(curenv);
f0104991:	e8 3e 1c 00 00       	call   f01065d4 <cpunum>
f0104996:	6b c0 74             	imul   $0x74,%eax,%eax
f0104999:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010499f:	89 04 24             	mov    %eax,(%esp)
f01049a2:	e8 c8 f0 ff ff       	call   f0103a6f <env_free>
			curenv = NULL;
f01049a7:	e8 28 1c 00 00       	call   f01065d4 <cpunum>
f01049ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01049af:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f01049b6:	00 00 00 
			sched_yield();
f01049b9:	e8 1e 03 00 00       	call   f0104cdc <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049be:	e8 11 1c 00 00       	call   f01065d4 <cpunum>
f01049c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c6:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01049cc:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049d1:	89 c7                	mov    %eax,%edi
f01049d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01049d5:	e8 fa 1b 00 00       	call   f01065d4 <cpunum>
f01049da:	6b c0 74             	imul   $0x74,%eax,%eax
f01049dd:	8b b0 28 30 23 f0    	mov    -0xfdccfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01049e3:	89 35 60 2a 23 f0    	mov    %esi,0xf0232a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f01049e9:	8b 46 28             	mov    0x28(%esi),%eax
f01049ec:	83 f8 0e             	cmp    $0xe,%eax
f01049ef:	75 08                	jne    f01049f9 <trap+0x136>
		page_fault_handler(tf);
f01049f1:	89 34 24             	mov    %esi,(%esp)
f01049f4:	e8 3f fd ff ff       	call   f0104738 <page_fault_handler>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f01049f9:	83 f8 03             	cmp    $0x3,%eax
f01049fc:	75 0d                	jne    f0104a0b <trap+0x148>
		monitor(tf);
f01049fe:	89 34 24             	mov    %esi,(%esp)
f0104a01:	e8 b3 be ff ff       	call   f01008b9 <monitor>
f0104a06:	e9 a4 00 00 00       	jmp    f0104aaf <trap+0x1ec>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f0104a0b:	83 f8 30             	cmp    $0x30,%eax
f0104a0e:	66 90                	xchg   %ax,%ax
f0104a10:	75 32                	jne    f0104a44 <trap+0x181>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104a12:	8b 46 04             	mov    0x4(%esi),%eax
f0104a15:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a19:	8b 06                	mov    (%esi),%eax
f0104a1b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a1f:	8b 46 10             	mov    0x10(%esi),%eax
f0104a22:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a26:	8b 46 18             	mov    0x18(%esi),%eax
f0104a29:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a2d:	8b 46 14             	mov    0x14(%esi),%eax
f0104a30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a34:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a37:	89 04 24             	mov    %eax,(%esp)
f0104a3a:	e8 6c 03 00 00       	call   f0104dab <syscall>
f0104a3f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a42:	eb 6b                	jmp    f0104aaf <trap+0x1ec>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a44:	83 f8 27             	cmp    $0x27,%eax
f0104a47:	75 16                	jne    f0104a5f <trap+0x19c>
		cprintf("Spurious interrupt on irq 7\n");
f0104a49:	c7 04 24 ef 80 10 f0 	movl   $0xf01080ef,(%esp)
f0104a50:	e8 19 f5 ff ff       	call   f0103f6e <cprintf>
		print_trapframe(tf);
f0104a55:	89 34 24             	mov    %esi,(%esp)
f0104a58:	e8 40 fb ff ff       	call   f010459d <print_trapframe>
f0104a5d:	eb 50                	jmp    f0104aaf <trap+0x1ec>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_TIMER + IRQ_OFFSET){
f0104a5f:	83 f8 20             	cmp    $0x20,%eax
f0104a62:	75 0a                	jne    f0104a6e <trap+0x1ab>
		//cprintf("The Irq_Time is also work\n");
		lapic_eoi();
f0104a64:	e8 b6 1c 00 00       	call   f010671f <lapic_eoi>
		sched_yield();
f0104a69:	e8 6e 02 00 00       	call   f0104cdc <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a6e:	89 34 24             	mov    %esi,(%esp)
f0104a71:	e8 27 fb ff ff       	call   f010459d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a76:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a7b:	75 1c                	jne    f0104a99 <trap+0x1d6>
		panic("unhandled trap in kernel");
f0104a7d:	c7 44 24 08 0c 81 10 	movl   $0xf010810c,0x8(%esp)
f0104a84:	f0 
f0104a85:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0104a8c:	00 
f0104a8d:	c7 04 24 c3 80 10 f0 	movl   $0xf01080c3,(%esp)
f0104a94:	e8 a7 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104a99:	e8 36 1b 00 00       	call   f01065d4 <cpunum>
f0104a9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa1:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104aa7:	89 04 24             	mov    %eax,(%esp)
f0104aaa:	e8 c7 f1 ff ff       	call   f0103c76 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104aaf:	e8 20 1b 00 00       	call   f01065d4 <cpunum>
f0104ab4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab7:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0104abe:	74 2a                	je     f0104aea <trap+0x227>
f0104ac0:	e8 0f 1b 00 00       	call   f01065d4 <cpunum>
f0104ac5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac8:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104ace:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ad2:	75 16                	jne    f0104aea <trap+0x227>
		env_run(curenv);
f0104ad4:	e8 fb 1a 00 00       	call   f01065d4 <cpunum>
f0104ad9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104adc:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104ae2:	89 04 24             	mov    %eax,(%esp)
f0104ae5:	e8 2d f2 ff ff       	call   f0103d17 <env_run>
	else
		sched_yield();
f0104aea:	e8 ed 01 00 00       	call   f0104cdc <sched_yield>
	...

f0104af0 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104af0:	6a 00                	push   $0x0
f0104af2:	6a 00                	push   $0x0
f0104af4:	e9 f6 00 00 00       	jmp    f0104bef <_alltraps>
f0104af9:	90                   	nop

f0104afa <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104afa:	6a 00                	push   $0x0
f0104afc:	6a 01                	push   $0x1
f0104afe:	e9 ec 00 00 00       	jmp    f0104bef <_alltraps>
f0104b03:	90                   	nop

f0104b04 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f0104b04:	6a 00                	push   $0x0
f0104b06:	6a 02                	push   $0x2
f0104b08:	e9 e2 00 00 00       	jmp    f0104bef <_alltraps>
f0104b0d:	90                   	nop

f0104b0e <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104b0e:	6a 00                	push   $0x0
f0104b10:	6a 03                	push   $0x3
f0104b12:	e9 d8 00 00 00       	jmp    f0104bef <_alltraps>
f0104b17:	90                   	nop

f0104b18 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104b18:	6a 00                	push   $0x0
f0104b1a:	6a 04                	push   $0x4
f0104b1c:	e9 ce 00 00 00       	jmp    f0104bef <_alltraps>
f0104b21:	90                   	nop

f0104b22 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104b22:	6a 00                	push   $0x0
f0104b24:	6a 05                	push   $0x5
f0104b26:	e9 c4 00 00 00       	jmp    f0104bef <_alltraps>
f0104b2b:	90                   	nop

f0104b2c <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104b2c:	6a 00                	push   $0x0
f0104b2e:	6a 06                	push   $0x6
f0104b30:	e9 ba 00 00 00       	jmp    f0104bef <_alltraps>
f0104b35:	90                   	nop

f0104b36 <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104b36:	6a 00                	push   $0x0
f0104b38:	6a 07                	push   $0x7
f0104b3a:	e9 b0 00 00 00       	jmp    f0104bef <_alltraps>
f0104b3f:	90                   	nop

f0104b40 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104b40:	6a 08                	push   $0x8
f0104b42:	e9 a8 00 00 00       	jmp    f0104bef <_alltraps>
f0104b47:	90                   	nop

f0104b48 <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 09                	push   $0x9
f0104b4c:	e9 9e 00 00 00       	jmp    f0104bef <_alltraps>
f0104b51:	90                   	nop

f0104b52 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104b52:	6a 0a                	push   $0xa
f0104b54:	e9 96 00 00 00       	jmp    f0104bef <_alltraps>
f0104b59:	90                   	nop

f0104b5a <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104b5a:	6a 0b                	push   $0xb
f0104b5c:	e9 8e 00 00 00       	jmp    f0104bef <_alltraps>
f0104b61:	90                   	nop

f0104b62 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104b62:	6a 0c                	push   $0xc
f0104b64:	e9 86 00 00 00       	jmp    f0104bef <_alltraps>
f0104b69:	90                   	nop

f0104b6a <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104b6a:	6a 0d                	push   $0xd
f0104b6c:	e9 7e 00 00 00       	jmp    f0104bef <_alltraps>
f0104b71:	90                   	nop

f0104b72 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104b72:	6a 0e                	push   $0xe
f0104b74:	e9 76 00 00 00       	jmp    f0104bef <_alltraps>
f0104b79:	90                   	nop

f0104b7a <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104b7a:	6a 00                	push   $0x0
f0104b7c:	6a 0f                	push   $0xf
f0104b7e:	e9 6c 00 00 00       	jmp    f0104bef <_alltraps>
f0104b83:	90                   	nop

f0104b84 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104b84:	6a 00                	push   $0x0
f0104b86:	6a 10                	push   $0x10
f0104b88:	e9 62 00 00 00       	jmp    f0104bef <_alltraps>
f0104b8d:	90                   	nop

f0104b8e <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104b8e:	6a 11                	push   $0x11
f0104b90:	e9 5a 00 00 00       	jmp    f0104bef <_alltraps>
f0104b95:	90                   	nop

f0104b96 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104b96:	6a 00                	push   $0x0
f0104b98:	6a 12                	push   $0x12
f0104b9a:	e9 50 00 00 00       	jmp    f0104bef <_alltraps>
f0104b9f:	90                   	nop

f0104ba0 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104ba0:	6a 00                	push   $0x0
f0104ba2:	6a 13                	push   $0x13
f0104ba4:	e9 46 00 00 00       	jmp    f0104bef <_alltraps>
f0104ba9:	90                   	nop

f0104baa <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104baa:	6a 00                	push   $0x0
f0104bac:	6a 30                	push   $0x30
f0104bae:	e9 3c 00 00 00       	jmp    f0104bef <_alltraps>
f0104bb3:	90                   	nop

f0104bb4 <handlerIRQ0>:

/*
* lab4
*/
	
TRAPHANDLER_NOEC(handlerIRQ0, IRQ_OFFSET+IRQ_TIMER)
f0104bb4:	6a 00                	push   $0x0
f0104bb6:	6a 20                	push   $0x20
f0104bb8:	e9 32 00 00 00       	jmp    f0104bef <_alltraps>
f0104bbd:	90                   	nop

f0104bbe <handlerIRQ1>:
TRAPHANDLER_NOEC(handlerIRQ1, IRQ_OFFSET+IRQ_KBD)
f0104bbe:	6a 00                	push   $0x0
f0104bc0:	6a 21                	push   $0x21
f0104bc2:	e9 28 00 00 00       	jmp    f0104bef <_alltraps>
f0104bc7:	90                   	nop

f0104bc8 <handlerIRQ4>:
TRAPHANDLER_NOEC(handlerIRQ4, IRQ_OFFSET+IRQ_SERIAL)
f0104bc8:	6a 00                	push   $0x0
f0104bca:	6a 24                	push   $0x24
f0104bcc:	e9 1e 00 00 00       	jmp    f0104bef <_alltraps>
f0104bd1:	90                   	nop

f0104bd2 <handlerIRQ7>:
TRAPHANDLER_NOEC(handlerIRQ7, IRQ_OFFSET+IRQ_SPURIOUS)
f0104bd2:	6a 00                	push   $0x0
f0104bd4:	6a 27                	push   $0x27
f0104bd6:	e9 14 00 00 00       	jmp    f0104bef <_alltraps>
f0104bdb:	90                   	nop

f0104bdc <handlerIRQ14>:
TRAPHANDLER_NOEC(handlerIRQ14, IRQ_OFFSET+IRQ_IDE)
f0104bdc:	6a 00                	push   $0x0
f0104bde:	6a 2e                	push   $0x2e
f0104be0:	e9 0a 00 00 00       	jmp    f0104bef <_alltraps>
f0104be5:	90                   	nop

f0104be6 <handlerIRQ19>:
TRAPHANDLER_NOEC(handlerIRQ19, IRQ_OFFSET+IRQ_ERROR)
f0104be6:	6a 00                	push   $0x0
f0104be8:	6a 33                	push   $0x33
f0104bea:	e9 00 00 00 00       	jmp    f0104bef <_alltraps>

f0104bef <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104bef:	1e                   	push   %ds
	pushl %es
f0104bf0:	06                   	push   %es
	pushal
f0104bf1:	60                   	pusha  
	movl $GD_KD, %eax
f0104bf2:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104bf7:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104bf9:	8e c0                	mov    %eax,%es

	pushl %esp
f0104bfb:	54                   	push   %esp
	call trap
f0104bfc:	e8 c2 fc ff ff       	call   f01048c3 <trap>
f0104c01:	00 00                	add    %al,(%eax)
	...

f0104c04 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104c04:	55                   	push   %ebp
f0104c05:	89 e5                	mov    %esp,%ebp
f0104c07:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104c0a:	8b 15 48 22 23 f0    	mov    0xf0232248,%edx
f0104c10:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c13:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c18:	8b 0a                	mov    (%edx),%ecx
f0104c1a:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c1d:	83 f9 02             	cmp    $0x2,%ecx
f0104c20:	76 0f                	jbe    f0104c31 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c22:	83 c0 01             	add    $0x1,%eax
f0104c25:	83 c2 7c             	add    $0x7c,%edx
f0104c28:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c2d:	75 e9                	jne    f0104c18 <sched_halt+0x14>
f0104c2f:	eb 07                	jmp    f0104c38 <sched_halt+0x34>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c31:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c36:	75 1a                	jne    f0104c52 <sched_halt+0x4e>
		cprintf("No runnable environments in the system!\n");
f0104c38:	c7 04 24 10 83 10 f0 	movl   $0xf0108310,(%esp)
f0104c3f:	e8 2a f3 ff ff       	call   f0103f6e <cprintf>
		while (1)
			monitor(NULL);
f0104c44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c4b:	e8 69 bc ff ff       	call   f01008b9 <monitor>
f0104c50:	eb f2                	jmp    f0104c44 <sched_halt+0x40>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c52:	e8 7d 19 00 00       	call   f01065d4 <cpunum>
f0104c57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c5a:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f0104c61:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c64:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c69:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c6e:	77 20                	ja     f0104c90 <sched_halt+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c70:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c74:	c7 44 24 08 24 6d 10 	movl   $0xf0106d24,0x8(%esp)
f0104c7b:	f0 
f0104c7c:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
f0104c83:	00 
f0104c84:	c7 04 24 39 83 10 f0 	movl   $0xf0108339,(%esp)
f0104c8b:	e8 b0 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c90:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c95:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c98:	e8 37 19 00 00       	call   f01065d4 <cpunum>
f0104c9d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104ca0:	81 c2 20 30 23 f0    	add    $0xf0233020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104ca6:	b8 02 00 00 00       	mov    $0x2,%eax
f0104cab:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104caf:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104cb6:	e8 65 1c 00 00       	call   f0106920 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104cbb:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104cbd:	e8 12 19 00 00       	call   f01065d4 <cpunum>
f0104cc2:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104cc5:	8b 80 30 30 23 f0    	mov    -0xfdccfd0(%eax),%eax
f0104ccb:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104cd0:	89 c4                	mov    %eax,%esp
f0104cd2:	6a 00                	push   $0x0
f0104cd4:	6a 00                	push   $0x0
f0104cd6:	fb                   	sti    
f0104cd7:	f4                   	hlt    
f0104cd8:	eb fd                	jmp    f0104cd7 <sched_halt+0xd3>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104cda:	c9                   	leave  
f0104cdb:	c3                   	ret    

f0104cdc <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104cdc:	55                   	push   %ebp
f0104cdd:	89 e5                	mov    %esp,%ebp
f0104cdf:	57                   	push   %edi
f0104ce0:	56                   	push   %esi
f0104ce1:	53                   	push   %ebx
f0104ce2:	83 ec 1c             	sub    $0x1c,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
f0104ce5:	e8 ea 18 00 00       	call   f01065d4 <cpunum>
f0104cea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ced:	8b 98 28 30 23 f0    	mov    -0xfdccfd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
f0104cf3:	b8 00 00 00 00       	mov    $0x0,%eax
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104cfd:	85 db                	test   %ebx,%ebx
f0104cff:	74 44                	je     f0104d45 <sched_yield+0x69>
		
		EnvID =  e-envs;
f0104d01:	89 de                	mov    %ebx,%esi
f0104d03:	2b 35 48 22 23 f0    	sub    0xf0232248,%esi
f0104d09:	c1 fe 02             	sar    $0x2,%esi
f0104d0c:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104d12:	89 f1                	mov    %esi,%ecx
		// maybe the env status is ENV_NOTRUNNABLE  so next if is important
		if(e->env_status == ENV_RUNNING)
f0104d14:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104d18:	75 07                	jne    f0104d21 <sched_yield+0x45>
			e->env_status = ENV_RUNNABLE;
f0104d1a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104d21:	83 c6 01             	add    $0x1,%esi
f0104d24:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104d29:	89 f0                	mov    %esi,%eax
f0104d2b:	f7 ea                	imul   %edx
f0104d2d:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104d30:	c1 f8 09             	sar    $0x9,%eax
f0104d33:	89 f7                	mov    %esi,%edi
f0104d35:	c1 ff 1f             	sar    $0x1f,%edi
f0104d38:	29 f8                	sub    %edi,%eax
f0104d3a:	89 c2                	mov    %eax,%edx
f0104d3c:	c1 e2 0a             	shl    $0xa,%edx
f0104d3f:	29 c2                	sub    %eax,%edx
f0104d41:	29 d6                	sub    %edx,%esi
f0104d43:	89 f0                	mov    %esi,%eax
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104d45:	8b 35 48 22 23 f0    	mov    0xf0232248,%esi
	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
f0104d4b:	ba 01 00 00 00       	mov    $0x1,%edx
			e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104d50:	eb 2c                	jmp    f0104d7e <sched_yield+0xa2>
		if(envs[i].env_status == ENV_RUNNABLE){
f0104d52:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104d55:	01 f2                	add    %esi,%edx
f0104d57:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104d5b:	75 08                	jne    f0104d65 <sched_yield+0x89>
			env_run(&envs[i]);
f0104d5d:	89 14 24             	mov    %edx,(%esp)
f0104d60:	e8 b2 ef ff ff       	call   f0103d17 <env_run>
			e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104d65:	83 c0 01             	add    $0x1,%eax
f0104d68:	89 c2                	mov    %eax,%edx
f0104d6a:	c1 fa 1f             	sar    $0x1f,%edx
f0104d6d:	c1 ea 16             	shr    $0x16,%edx
f0104d70:	01 d0                	add    %edx,%eax
f0104d72:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104d77:	29 d0                	sub    %edx,%eax
		if(envs[i].env_status == ENV_RUNNABLE){
			env_run(&envs[i]);
		}
		firstEnv = false;
f0104d79:	ba 00 00 00 00       	mov    $0x0,%edx
			e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104d7e:	84 d2                	test   %dl,%dl
f0104d80:	75 d0                	jne    f0104d52 <sched_yield+0x76>
f0104d82:	39 c8                	cmp    %ecx,%eax
f0104d84:	75 cc                	jne    f0104d52 <sched_yield+0x76>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e )
f0104d86:	85 db                	test   %ebx,%ebx
f0104d88:	74 08                	je     f0104d92 <sched_yield+0xb6>
	//&& e->env_status == ENV_RUNNING)
		
		env_run(e);
f0104d8a:	89 1c 24             	mov    %ebx,(%esp)
f0104d8d:	e8 85 ef ff ff       	call   f0103d17 <env_run>
  
	// sched_halt never returns
	sched_halt();
f0104d92:	e8 6d fe ff ff       	call   f0104c04 <sched_halt>
    }

	// sched_halt never returns
	sched_halt();
	*/
}
f0104d97:	83 c4 1c             	add    $0x1c,%esp
f0104d9a:	5b                   	pop    %ebx
f0104d9b:	5e                   	pop    %esi
f0104d9c:	5f                   	pop    %edi
f0104d9d:	5d                   	pop    %ebp
f0104d9e:	c3                   	ret    
	...

f0104da0 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104da0:	55                   	push   %ebp
f0104da1:	89 e5                	mov    %esp,%ebp
f0104da3:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104da6:	e8 31 ff ff ff       	call   f0104cdc <sched_yield>

f0104dab <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104dab:	55                   	push   %ebp
f0104dac:	89 e5                	mov    %esp,%ebp
f0104dae:	83 ec 38             	sub    $0x38,%esp
f0104db1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104db4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104db7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104dba:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dbd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104dc0:	8b 7d 10             	mov    0x10(%ebp),%edi
		case  SYS_ipc_recv:	
					ret = sys_ipc_recv ( (void *)a1);
						break;

		default:
			return -E_NO_SYS;
f0104dc3:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104dc8:	83 f8 0c             	cmp    $0xc,%eax
f0104dcb:	0f 87 a4 05 00 00    	ja     f0105375 <syscall+0x5ca>
f0104dd1:	ff 24 85 80 83 10 f0 	jmp    *-0xfef7c80(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104dd8:	e8 f7 17 00 00       	call   f01065d4 <cpunum>
f0104ddd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104de4:	00 
f0104de5:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104de9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ded:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df0:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104df6:	89 04 24             	mov    %eax,(%esp)
f0104df9:	e8 0b e7 ff ff       	call   f0103509 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104dfe:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104e02:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e06:	c7 04 24 46 83 10 f0 	movl   $0xf0108346,(%esp)
f0104e0d:	e8 5c f1 ff ff       	call   f0103f6e <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104e12:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e17:	e9 59 05 00 00       	jmp    f0105375 <syscall+0x5ca>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e1c:	e8 f8 b7 ff ff       	call   f0100619 <cons_getc>
f0104e21:	89 c3                	mov    %eax,%ebx
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104e23:	e9 4d 05 00 00       	jmp    f0105375 <syscall+0x5ca>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e28:	e8 a7 17 00 00       	call   f01065d4 <cpunum>
f0104e2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e30:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104e36:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104e39:	e9 37 05 00 00       	jmp    f0105375 <syscall+0x5ca>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e3e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e45:	00 
f0104e46:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e4d:	89 34 24             	mov    %esi,(%esp)
f0104e50:	e8 b8 e7 ff ff       	call   f010360d <envid2env>
f0104e55:	89 c3                	mov    %eax,%ebx
f0104e57:	85 c0                	test   %eax,%eax
f0104e59:	0f 88 16 05 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	if (e == curenv)
f0104e5f:	e8 70 17 00 00       	call   f01065d4 <cpunum>
f0104e64:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e6a:	39 90 28 30 23 f0    	cmp    %edx,-0xfdccfd8(%eax)
f0104e70:	75 23                	jne    f0104e95 <syscall+0xea>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e72:	e8 5d 17 00 00       	call   f01065d4 <cpunum>
f0104e77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7a:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104e80:	8b 40 48             	mov    0x48(%eax),%eax
f0104e83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e87:	c7 04 24 4b 83 10 f0 	movl   $0xf010834b,(%esp)
f0104e8e:	e8 db f0 ff ff       	call   f0103f6e <cprintf>
f0104e93:	eb 28                	jmp    f0104ebd <syscall+0x112>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e95:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e98:	e8 37 17 00 00       	call   f01065d4 <cpunum>
f0104e9d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ea1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea4:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104eaa:	8b 40 48             	mov    0x48(%eax),%eax
f0104ead:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eb1:	c7 04 24 66 83 10 f0 	movl   $0xf0108366,(%esp)
f0104eb8:	e8 b1 f0 ff ff       	call   f0103f6e <cprintf>
	env_destroy(e);
f0104ebd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ec0:	89 04 24             	mov    %eax,(%esp)
f0104ec3:	e8 ae ed ff ff       	call   f0103c76 <env_destroy>
	return 0;
f0104ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
						break;
f0104ecd:	e9 a3 04 00 00       	jmp    f0105375 <syscall+0x5ca>
		case SYS_yield:      	sys_yield();	
f0104ed2:	e8 c9 fe ff ff       	call   f0104da0 <sys_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env* childEnv=0;
f0104ed7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	struct Env* parentEnv = curenv;
f0104ede:	e8 f1 16 00 00       	call   f01065d4 <cpunum>
f0104ee3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee6:	8b b0 28 30 23 f0    	mov    -0xfdccfd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104eec:	8b 46 48             	mov    0x48(%esi),%eax
f0104eef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ef3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ef6:	89 04 24             	mov    %eax,(%esp)
f0104ef9:	e8 26 e8 ff ff       	call   f0103724 <env_alloc>
f0104efe:	89 c3                	mov    %eax,%ebx
	if(r < 0)
f0104f00:	85 c0                	test   %eax,%eax
f0104f02:	0f 88 6d 04 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104f08:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f0b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104f10:	89 c7                	mov    %eax,%edi
f0104f12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104f14:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f17:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104f1e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104f25:	8b 58 48             	mov    0x48(%eax),%ebx
						break;
		case SYS_yield:      	sys_yield();	
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
f0104f28:	e9 48 04 00 00       	jmp    f0105375 <syscall+0x5ca>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e =0;
f0104f2d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f34:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f3b:	00 
f0104f3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f43:	89 34 24             	mov    %esi,(%esp)
f0104f46:	e8 c2 e6 ff ff       	call   f010360d <envid2env>
f0104f4b:	89 c3                	mov    %eax,%ebx
f0104f4d:	85 c0                	test   %eax,%eax
f0104f4f:	0f 88 20 04 00 00    	js     f0105375 <syscall+0x5ca>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104f55:	83 ff 02             	cmp    $0x2,%edi
f0104f58:	74 0e                	je     f0104f68 <syscall+0x1bd>
		return -E_INVAL;
f0104f5a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104f5f:	83 ff 04             	cmp    $0x4,%edi
f0104f62:	0f 85 0d 04 00 00    	jne    f0105375 <syscall+0x5ca>
		return -E_INVAL;
	e->env_status = status;
f0104f68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f6b:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f73:	e9 fd 03 00 00       	jmp    f0105375 <syscall+0x5ca>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	
	struct Env *e =0;
f0104f78:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f7f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f86:	00 
f0104f87:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f8e:	89 34 24             	mov    %esi,(%esp)
f0104f91:	e8 77 e6 ff ff       	call   f010360d <envid2env>
f0104f96:	89 c3                	mov    %eax,%ebx
f0104f98:	85 c0                	test   %eax,%eax
f0104f9a:	0f 88 d5 03 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104fa0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104fa5:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104fab:	0f 87 c4 03 00 00    	ja     f0105375 <syscall+0x5ca>
f0104fb1:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104fb7:	0f 85 b8 03 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104fbd:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104fc4:	0f 85 ab 03 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104fca:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fcd:	83 e0 05             	and    $0x5,%eax
f0104fd0:	83 f8 05             	cmp    $0x5,%eax
f0104fd3:	0f 85 9c 03 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104fd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104fe0:	e8 64 bf ff ff       	call   f0100f49 <page_alloc>
f0104fe5:	89 c6                	mov    %eax,%esi
	if(page == 0)
f0104fe7:	85 c0                	test   %eax,%eax
f0104fe9:	74 30                	je     f010501b <syscall+0x270>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104feb:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104fee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104ff2:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ffa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ffd:	8b 40 60             	mov    0x60(%eax),%eax
f0105000:	89 04 24             	mov    %eax,(%esp)
f0105003:	e8 37 c2 ff ff       	call   f010123f <page_insert>
f0105008:	89 c3                	mov    %eax,%ebx
	if(r <0){
f010500a:	85 c0                	test   %eax,%eax
f010500c:	79 17                	jns    f0105025 <syscall+0x27a>
		page_free(page);
f010500e:	89 34 24             	mov    %esi,(%esp)
f0105011:	e8 b7 bf ff ff       	call   f0100fcd <page_free>
f0105016:	e9 5a 03 00 00       	jmp    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f010501b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0105020:	e9 50 03 00 00       	jmp    f0105375 <syscall+0x5ca>
	r = page_insert(e->env_pgdir, page, va,perm);
	if(r <0){
		page_free(page);
		return r;
	}
	return 0;
f0105025:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
f010502a:	e9 46 03 00 00       	jmp    f0105375 <syscall+0x5ca>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
f010502f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105036:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f010503d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105044:	00 
f0105045:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105048:	89 44 24 04          	mov    %eax,0x4(%esp)
f010504c:	89 34 24             	mov    %esi,(%esp)
f010504f:	e8 b9 e5 ff ff       	call   f010360d <envid2env>
f0105054:	89 c3                	mov    %eax,%ebx
f0105056:	85 c0                	test   %eax,%eax
f0105058:	0f 88 17 03 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f010505e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105065:	00 
f0105066:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010506d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105070:	89 1c 24             	mov    %ebx,(%esp)
f0105073:	e8 95 e5 ff ff       	call   f010360d <envid2env>
f0105078:	89 c3                	mov    %eax,%ebx
f010507a:	85 c0                	test   %eax,%eax
f010507c:	0f 88 f3 02 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f0105082:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f0105087:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010508d:	0f 87 e2 02 00 00    	ja     f0105375 <syscall+0x5ca>
f0105093:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105099:	0f 85 d6 02 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f010509f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01050a6:	0f 87 c9 02 00 00    	ja     f0105375 <syscall+0x5ca>
f01050ac:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01050b3:	0f 85 bc 02 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f01050b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f01050c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050ce:	8b 40 60             	mov    0x60(%eax),%eax
f01050d1:	89 04 24             	mov    %eax,(%esp)
f01050d4:	e8 5c c0 ff ff       	call   f0101135 <page_lookup>
	if(page == 0)
f01050d9:	85 c0                	test   %eax,%eax
f01050db:	74 5d                	je     f010513a <syscall+0x38f>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f01050dd:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01050e4:	0f 85 8b 02 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f01050ea:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01050ed:	83 e2 05             	and    $0x5,%edx
f01050f0:	83 fa 05             	cmp    $0x5,%edx
f01050f3:	0f 85 7c 02 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f01050f9:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01050fd:	74 0c                	je     f010510b <syscall+0x360>
f01050ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105102:	f6 02 02             	testb  $0x2,(%edx)
f0105105:	0f 84 6a 02 00 00    	je     f0105375 <syscall+0x5ca>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f010510b:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f010510e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105112:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105115:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105120:	8b 40 60             	mov    0x60(%eax),%eax
f0105123:	89 04 24             	mov    %eax,(%esp)
f0105126:	e8 14 c1 ff ff       	call   f010123f <page_insert>
f010512b:	85 c0                	test   %eax,%eax
f010512d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105132:	0f 4e d8             	cmovle %eax,%ebx
f0105135:	e9 3b 02 00 00       	jmp    f0105375 <syscall+0x5ca>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f010513a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010513f:	e9 31 02 00 00       	jmp    f0105375 <syscall+0x5ca>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e =0;
f0105144:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f010514b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105152:	00 
f0105153:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105156:	89 44 24 04          	mov    %eax,0x4(%esp)
f010515a:	89 34 24             	mov    %esi,(%esp)
f010515d:	e8 ab e4 ff ff       	call   f010360d <envid2env>
f0105162:	89 c3                	mov    %eax,%ebx
f0105164:	85 c0                	test   %eax,%eax
f0105166:	0f 88 09 02 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f010516c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	// LAB 4: Your code here.
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0105171:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105177:	0f 87 f8 01 00 00    	ja     f0105375 <syscall+0x5ca>
f010517d:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105183:	0f 85 ec 01 00 00    	jne    f0105375 <syscall+0x5ca>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f0105189:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010518d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105190:	8b 40 60             	mov    0x60(%eax),%eax
f0105193:	89 04 24             	mov    %eax,(%esp)
f0105196:	e8 44 c0 ff ff       	call   f01011df <page_remove>
	return 0;
f010519b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01051a0:	e9 d0 01 00 00       	jmp    f0105375 <syscall+0x5ca>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{

	// LAB 4: Your code here.
	struct Env *e =0;
f01051a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f01051ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051b3:	00 
f01051b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051bb:	89 34 24             	mov    %esi,(%esp)
f01051be:	e8 4a e4 ff ff       	call   f010360d <envid2env>
f01051c3:	89 c3                	mov    %eax,%ebx
f01051c5:	85 c0                	test   %eax,%eax
f01051c7:	0f 88 a8 01 00 00    	js     f0105375 <syscall+0x5ca>
		return r;
	e->env_pgfault_upcall = func;
f01051cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051d0:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f01051d3:	bb 00 00 00 00       	mov    $0x0,%ebx
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
		case SYS_env_set_pgfault_upcall:
					ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
						break;
f01051d8:	e9 98 01 00 00       	jmp    f0105375 <syscall+0x5ca>
	
	// LAB 4: Your code here.

	//if(envid == 0x1004)
	//	cprintf("when the envid =0x1004, the value is %d\n", value);
	struct Env *env=0;
f01051dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	pte_t * pte =0;
f01051e4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if((r = envid2env(envid, &env, 0)) < 0)
f01051eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01051f2:	00 
f01051f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051fa:	89 34 24             	mov    %esi,(%esp)
f01051fd:	e8 0b e4 ff ff       	call   f010360d <envid2env>
f0105202:	85 c0                	test   %eax,%eax
f0105204:	0f 88 f4 00 00 00    	js     f01052fe <syscall+0x553>
		return -E_BAD_ENV;
	
	
	if(env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f010520a:	bb f8 ff ff ff       	mov    $0xfffffff8,%ebx
	pte_t * pte =0;
	if((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
	
	
	if(env->env_ipc_recving == 0)
f010520f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105212:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105216:	0f 84 59 01 00 00    	je     f0105375 <syscall+0x5ca>
		return -E_IPC_NOT_RECV;
	

	if((int)srcva < UTOP){
f010521c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105223:	0f 87 99 00 00 00    	ja     f01052c2 <syscall+0x517>

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
			return -E_INVAL;
f0105229:	b3 fd                	mov    $0xfd,%bl
		return -E_IPC_NOT_RECV;
	

	if((int)srcva < UTOP){

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
f010522b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105232:	0f 85 3d 01 00 00    	jne    f0105375 <syscall+0x5ca>
			return -E_INVAL;
			
		if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0105238:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010523f:	0f 85 30 01 00 00    	jne    f0105375 <syscall+0x5ca>
			return  -E_INVAL;
			
		if(  (perm & PTE_P) ==0 )
f0105245:	f6 45 18 01          	testb  $0x1,0x18(%ebp)
f0105249:	0f 84 26 01 00 00    	je     f0105375 <syscall+0x5ca>
			return  -E_INVAL;
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
f010524f:	e8 80 13 00 00       	call   f01065d4 <cpunum>
f0105254:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105257:	89 54 24 08          	mov    %edx,0x8(%esp)
f010525b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010525e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105262:	6b c0 74             	imul   $0x74,%eax,%eax
f0105265:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010526b:	8b 40 60             	mov    0x60(%eax),%eax
f010526e:	89 04 24             	mov    %eax,(%esp)
f0105271:	e8 bf be ff ff       	call   f0101135 <page_lookup>
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
f0105276:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010527a:	74 11                	je     f010528d <syscall+0x4e2>
			return  -E_INVAL;
f010527c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			
		if(  (perm & PTE_P) ==0 )
			return  -E_INVAL;
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
f0105281:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105284:	f6 02 02             	testb  $0x2,(%edx)
f0105287:	0f 84 e8 00 00 00    	je     f0105375 <syscall+0x5ca>
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f010528d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105290:	8b 4a 6c             	mov    0x6c(%edx),%ecx
			return 0;
f0105293:	bb 00 00 00 00       	mov    $0x0,%ebx
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f0105298:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010529e:	0f 87 d1 00 00 00    	ja     f0105375 <syscall+0x5ca>
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
f01052a4:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01052a7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01052ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b3:	8b 42 60             	mov    0x60(%edx),%eax
f01052b6:	89 04 24             	mov    %eax,(%esp)
f01052b9:	e8 81 bf ff ff       	call   f010123f <page_insert>
		if(r < 0)
f01052be:	85 c0                	test   %eax,%eax
f01052c0:	78 43                	js     f0105305 <syscall+0x55a>
			return -E_NO_MEM;
			
		
	}

	env->env_ipc_value = value;
f01052c2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01052c5:	89 7b 70             	mov    %edi,0x70(%ebx)
	env->env_ipc_from = curenv->env_id;
f01052c8:	e8 07 13 00 00       	call   f01065d4 <cpunum>
f01052cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d0:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01052d6:	8b 40 48             	mov    0x48(%eax),%eax
f01052d9:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_perm = perm;
f01052dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052df:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01052e2:	89 58 78             	mov    %ebx,0x78(%eax)
	env->env_ipc_recving = 0;
f01052e5:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_status = ENV_RUNNABLE;
f01052e9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f01052f0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f01052f7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052fc:	eb 77                	jmp    f0105375 <syscall+0x5ca>
	//	cprintf("when the envid =0x1004, the value is %d\n", value);
	struct Env *env=0;
	int r =0;
	pte_t * pte =0;
	if((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
f01052fe:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105303:	eb 70                	jmp    f0105375 <syscall+0x5ca>
			
		if((int)env->env_ipc_dstva >= UTOP)
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
		if(r < 0)
			return -E_NO_MEM;
f0105305:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_env_set_pgfault_upcall:
					ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
						break;
f010530a:	eb 69                	jmp    f0105375 <syscall+0x5ca>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	if((int)dstva >= UTOP)
f010530c:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105312:	76 17                	jbe    f010532b <syscall+0x580>
		curenv->env_ipc_dstva = (void*)UTOP;
f0105314:	e8 bb 12 00 00       	call   f01065d4 <cpunum>
f0105319:	6b c0 74             	imul   $0x74,%eax,%eax
f010531c:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105322:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
f0105329:	eb 19                	jmp    f0105344 <syscall+0x599>
	else{
		if((int)dstva % PGSIZE != 0)
f010532b:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0105331:	75 3d                	jne    f0105370 <syscall+0x5c5>
			return -E_INVAL;
		else curenv->env_ipc_dstva = dstva;
f0105333:	e8 9c 12 00 00       	call   f01065d4 <cpunum>
f0105338:	6b c0 74             	imul   $0x74,%eax,%eax
f010533b:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105341:	89 70 6c             	mov    %esi,0x6c(%eax)
	}
	
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105344:	e8 8b 12 00 00       	call   f01065d4 <cpunum>
f0105349:	6b c0 74             	imul   $0x74,%eax,%eax
f010534c:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105352:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = 1;
f0105359:	e8 76 12 00 00       	call   f01065d4 <cpunum>
f010535e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105361:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105367:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	sys_yield();
f010536b:	e8 30 fa ff ff       	call   f0104da0 <sys_yield>
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
						break;
		case  SYS_ipc_recv:	
					ret = sys_ipc_recv ( (void *)a1);
f0105370:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx

		default:
			return -E_NO_SYS;
	}
	return ret;
}
f0105375:	89 d8                	mov    %ebx,%eax
f0105377:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010537a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010537d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105380:	89 ec                	mov    %ebp,%esp
f0105382:	5d                   	pop    %ebp
f0105383:	c3                   	ret    

f0105384 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105384:	55                   	push   %ebp
f0105385:	89 e5                	mov    %esp,%ebp
f0105387:	57                   	push   %edi
f0105388:	56                   	push   %esi
f0105389:	53                   	push   %ebx
f010538a:	83 ec 14             	sub    $0x14,%esp
f010538d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105390:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105393:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105396:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105399:	8b 1a                	mov    (%edx),%ebx
f010539b:	8b 01                	mov    (%ecx),%eax
f010539d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01053a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01053a7:	e9 88 00 00 00       	jmp    f0105434 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01053ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053af:	01 d8                	add    %ebx,%eax
f01053b1:	89 c7                	mov    %eax,%edi
f01053b3:	c1 ef 1f             	shr    $0x1f,%edi
f01053b6:	01 c7                	add    %eax,%edi
f01053b8:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053ba:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01053bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053c0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01053c4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053c6:	eb 03                	jmp    f01053cb <stab_binsearch+0x47>
			m--;
f01053c8:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053cb:	39 c3                	cmp    %eax,%ebx
f01053cd:	7f 1e                	jg     f01053ed <stab_binsearch+0x69>
f01053cf:	0f b6 0a             	movzbl (%edx),%ecx
f01053d2:	83 ea 0c             	sub    $0xc,%edx
f01053d5:	39 f1                	cmp    %esi,%ecx
f01053d7:	75 ef                	jne    f01053c8 <stab_binsearch+0x44>
f01053d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01053dc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01053df:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053e2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01053e6:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053e9:	76 18                	jbe    f0105403 <stab_binsearch+0x7f>
f01053eb:	eb 05                	jmp    f01053f2 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01053ed:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01053f0:	eb 42                	jmp    f0105434 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01053f2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053f5:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01053f7:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01053fa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105401:	eb 31                	jmp    f0105434 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105403:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105406:	73 17                	jae    f010541f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105408:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010540b:	83 e9 01             	sub    $0x1,%ecx
f010540e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105411:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105414:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105416:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010541d:	eb 15                	jmp    f0105434 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010541f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105422:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105425:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0105427:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010542b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010542d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105434:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105437:	0f 8e 6f ff ff ff    	jle    f01053ac <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010543d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105441:	75 0f                	jne    f0105452 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105443:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105446:	8b 02                	mov    (%edx),%eax
f0105448:	83 e8 01             	sub    $0x1,%eax
f010544b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010544e:	89 01                	mov    %eax,(%ecx)
f0105450:	eb 2c                	jmp    f010547e <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105452:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105455:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105457:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010545a:	8b 0a                	mov    (%edx),%ecx
f010545c:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010545f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105462:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105466:	eb 03                	jmp    f010546b <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105468:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010546b:	39 c8                	cmp    %ecx,%eax
f010546d:	7e 0a                	jle    f0105479 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f010546f:	0f b6 1a             	movzbl (%edx),%ebx
f0105472:	83 ea 0c             	sub    $0xc,%edx
f0105475:	39 f3                	cmp    %esi,%ebx
f0105477:	75 ef                	jne    f0105468 <stab_binsearch+0xe4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105479:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010547c:	89 02                	mov    %eax,(%edx)
	}
}
f010547e:	83 c4 14             	add    $0x14,%esp
f0105481:	5b                   	pop    %ebx
f0105482:	5e                   	pop    %esi
f0105483:	5f                   	pop    %edi
f0105484:	5d                   	pop    %ebp
f0105485:	c3                   	ret    

f0105486 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105486:	55                   	push   %ebp
f0105487:	89 e5                	mov    %esp,%ebp
f0105489:	57                   	push   %edi
f010548a:	56                   	push   %esi
f010548b:	53                   	push   %ebx
f010548c:	83 ec 5c             	sub    $0x5c,%esp
f010548f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105495:	c7 03 b4 83 10 f0    	movl   $0xf01083b4,(%ebx)
	info->eip_line = 0;
f010549b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01054a2:	c7 43 08 b4 83 10 f0 	movl   $0xf01083b4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01054a9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01054b0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01054b3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01054ba:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01054c0:	0f 87 d8 00 00 00    	ja     f010559e <debuginfo_eip+0x118>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01054c6:	e8 09 11 00 00       	call   f01065d4 <cpunum>
f01054cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01054d2:	00 
f01054d3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01054da:	00 
f01054db:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01054e2:	00 
f01054e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01054e6:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01054ec:	89 04 24             	mov    %eax,(%esp)
f01054ef:	e8 73 df ff ff       	call   f0103467 <user_mem_check>
f01054f4:	89 c2                	mov    %eax,%edx
			return -1;
f01054f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01054fb:	85 d2                	test   %edx,%edx
f01054fd:	0f 85 47 02 00 00    	jne    f010574a <debuginfo_eip+0x2c4>
			return -1;

		stabs = usd->stabs;
f0105503:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105509:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010550c:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105512:	a1 08 00 20 00       	mov    0x200008,%eax
f0105517:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010551a:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105520:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105523:	e8 ac 10 00 00       	call   f01065d4 <cpunum>
f0105528:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010552f:	00 
f0105530:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0105537:	00 
f0105538:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010553b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010553f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105542:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105548:	89 04 24             	mov    %eax,(%esp)
f010554b:	e8 17 df ff ff       	call   f0103467 <user_mem_check>
f0105550:	89 c2                	mov    %eax,%edx
			return -1;
f0105552:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105557:	85 d2                	test   %edx,%edx
f0105559:	0f 85 eb 01 00 00    	jne    f010574a <debuginfo_eip+0x2c4>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010555f:	e8 70 10 00 00       	call   f01065d4 <cpunum>
f0105564:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010556b:	00 
f010556c:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010556f:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105572:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105576:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105579:	89 54 24 04          	mov    %edx,0x4(%esp)
f010557d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105580:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105586:	89 04 24             	mov    %eax,(%esp)
f0105589:	e8 d9 de ff ff       	call   f0103467 <user_mem_check>
f010558e:	89 c2                	mov    %eax,%edx
			return -1;
f0105590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105595:	85 d2                	test   %edx,%edx
f0105597:	74 1f                	je     f01055b8 <debuginfo_eip+0x132>
f0105599:	e9 ac 01 00 00       	jmp    f010574a <debuginfo_eip+0x2c4>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010559e:	c7 45 c0 d4 6b 11 f0 	movl   $0xf0116bd4,-0x40(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01055a5:	c7 45 bc e1 33 11 f0 	movl   $0xf01133e1,-0x44(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01055ac:	bf e0 33 11 f0       	mov    $0xf01133e0,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055b1:	c7 45 c4 98 88 10 f0 	movl   $0xf0108898,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01055b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055bd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055c0:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01055c3:	0f 83 81 01 00 00    	jae    f010574a <debuginfo_eip+0x2c4>
f01055c9:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01055cd:	0f 85 77 01 00 00    	jne    f010574a <debuginfo_eip+0x2c4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01055da:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01055dd:	c1 ff 02             	sar    $0x2,%edi
f01055e0:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01055e6:	83 e8 01             	sub    $0x1,%eax
f01055e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01055ec:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055f0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01055f7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01055fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01055fd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105600:	e8 7f fd ff ff       	call   f0105384 <stab_binsearch>
	if (lfile == 0)
f0105605:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0105608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010560d:	85 d2                	test   %edx,%edx
f010560f:	0f 84 35 01 00 00    	je     f010574a <debuginfo_eip+0x2c4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105615:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105618:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010561b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010561e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105622:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105629:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010562c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010562f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105632:	e8 4d fd ff ff       	call   f0105384 <stab_binsearch>

	if (lfun <= rfun) {
f0105637:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010563a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010563d:	39 d0                	cmp    %edx,%eax
f010563f:	7f 32                	jg     f0105673 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105641:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105644:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105647:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010564a:	8b 39                	mov    (%ecx),%edi
f010564c:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f010564f:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105652:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105655:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105658:	73 09                	jae    f0105663 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010565a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010565d:	03 7d bc             	add    -0x44(%ebp),%edi
f0105660:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105663:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105666:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105669:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010566b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010566e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105671:	eb 0f                	jmp    f0105682 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105673:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105679:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010567c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105682:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105689:	00 
f010568a:	8b 43 08             	mov    0x8(%ebx),%eax
f010568d:	89 04 24             	mov    %eax,(%esp)
f0105690:	e8 c2 08 00 00       	call   f0105f57 <strfind>
f0105695:	2b 43 08             	sub    0x8(%ebx),%eax
f0105698:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010569b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010569f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01056a6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056a9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056ac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01056af:	e8 d0 fc ff ff       	call   f0105384 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01056b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056b7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056ba:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01056bd:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01056c0:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01056c4:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056c7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01056ca:	83 c2 08             	add    $0x8,%edx
f01056cd:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056d0:	eb 06                	jmp    f01056d8 <debuginfo_eip+0x252>
f01056d2:	83 e8 01             	sub    $0x1,%eax
f01056d5:	83 ea 0c             	sub    $0xc,%edx
f01056d8:	89 c7                	mov    %eax,%edi
f01056da:	39 c6                	cmp    %eax,%esi
f01056dc:	7f 22                	jg     f0105700 <debuginfo_eip+0x27a>
	       && stabs[lline].n_type != N_SOL
f01056de:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
f01056e2:	80 f9 84             	cmp    $0x84,%cl
f01056e5:	74 6b                	je     f0105752 <debuginfo_eip+0x2cc>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01056e7:	80 f9 64             	cmp    $0x64,%cl
f01056ea:	75 e6                	jne    f01056d2 <debuginfo_eip+0x24c>
f01056ec:	83 3a 00             	cmpl   $0x0,(%edx)
f01056ef:	74 e1                	je     f01056d2 <debuginfo_eip+0x24c>
f01056f1:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01056f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01056f7:	eb 5f                	jmp    f0105758 <debuginfo_eip+0x2d2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01056f9:	03 45 bc             	add    -0x44(%ebp),%eax
f01056fc:	89 03                	mov    %eax,(%ebx)
f01056fe:	eb 03                	jmp    f0105703 <debuginfo_eip+0x27d>
f0105700:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105703:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105706:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105709:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010570e:	39 ca                	cmp    %ecx,%edx
f0105710:	7d 38                	jge    f010574a <debuginfo_eip+0x2c4>
		for (lline = lfun + 1;
f0105712:	83 c2 01             	add    $0x1,%edx
f0105715:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105718:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010571a:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010571d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105720:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105724:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105726:	eb 04                	jmp    f010572c <debuginfo_eip+0x2a6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105728:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010572c:	39 f0                	cmp    %esi,%eax
f010572e:	7d 15                	jge    f0105745 <debuginfo_eip+0x2bf>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105730:	0f b6 0a             	movzbl (%edx),%ecx
f0105733:	83 c0 01             	add    $0x1,%eax
f0105736:	83 c2 0c             	add    $0xc,%edx
f0105739:	80 f9 a0             	cmp    $0xa0,%cl
f010573c:	74 ea                	je     f0105728 <debuginfo_eip+0x2a2>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010573e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105743:	eb 05                	jmp    f010574a <debuginfo_eip+0x2c4>
f0105745:	b8 00 00 00 00       	mov    $0x0,%eax
f010574a:	83 c4 5c             	add    $0x5c,%esp
f010574d:	5b                   	pop    %ebx
f010574e:	5e                   	pop    %esi
f010574f:	5f                   	pop    %edi
f0105750:	5d                   	pop    %ebp
f0105751:	c3                   	ret    
f0105752:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105755:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105758:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010575b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010575e:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105761:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105764:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105767:	39 d0                	cmp    %edx,%eax
f0105769:	72 8e                	jb     f01056f9 <debuginfo_eip+0x273>
f010576b:	eb 96                	jmp    f0105703 <debuginfo_eip+0x27d>
f010576d:	00 00                	add    %al,(%eax)
	...

f0105770 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105770:	55                   	push   %ebp
f0105771:	89 e5                	mov    %esp,%ebp
f0105773:	57                   	push   %edi
f0105774:	56                   	push   %esi
f0105775:	53                   	push   %ebx
f0105776:	83 ec 3c             	sub    $0x3c,%esp
f0105779:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010577c:	89 d7                	mov    %edx,%edi
f010577e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105781:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105784:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105787:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010578a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010578d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105790:	85 c0                	test   %eax,%eax
f0105792:	75 08                	jne    f010579c <printnum+0x2c>
f0105794:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105797:	39 45 10             	cmp    %eax,0x10(%ebp)
f010579a:	77 59                	ja     f01057f5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010579c:	89 74 24 10          	mov    %esi,0x10(%esp)
f01057a0:	83 eb 01             	sub    $0x1,%ebx
f01057a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01057a7:	8b 45 10             	mov    0x10(%ebp),%eax
f01057aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057ae:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01057b2:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01057b6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01057bd:	00 
f01057be:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01057c1:	89 04 24             	mov    %eax,(%esp)
f01057c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057cb:	e8 70 12 00 00       	call   f0106a40 <__udivdi3>
f01057d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01057d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01057d8:	89 04 24             	mov    %eax,(%esp)
f01057db:	89 54 24 04          	mov    %edx,0x4(%esp)
f01057df:	89 fa                	mov    %edi,%edx
f01057e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057e4:	e8 87 ff ff ff       	call   f0105770 <printnum>
f01057e9:	eb 11                	jmp    f01057fc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01057eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057ef:	89 34 24             	mov    %esi,(%esp)
f01057f2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01057f5:	83 eb 01             	sub    $0x1,%ebx
f01057f8:	85 db                	test   %ebx,%ebx
f01057fa:	7f ef                	jg     f01057eb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01057fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105800:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105804:	8b 45 10             	mov    0x10(%ebp),%eax
f0105807:	89 44 24 08          	mov    %eax,0x8(%esp)
f010580b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105812:	00 
f0105813:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105816:	89 04 24             	mov    %eax,(%esp)
f0105819:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010581c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105820:	e8 4b 13 00 00       	call   f0106b70 <__umoddi3>
f0105825:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105829:	0f be 80 be 83 10 f0 	movsbl -0xfef7c42(%eax),%eax
f0105830:	89 04 24             	mov    %eax,(%esp)
f0105833:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105836:	83 c4 3c             	add    $0x3c,%esp
f0105839:	5b                   	pop    %ebx
f010583a:	5e                   	pop    %esi
f010583b:	5f                   	pop    %edi
f010583c:	5d                   	pop    %ebp
f010583d:	c3                   	ret    

f010583e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010583e:	55                   	push   %ebp
f010583f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105841:	83 fa 01             	cmp    $0x1,%edx
f0105844:	7e 0e                	jle    f0105854 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105846:	8b 10                	mov    (%eax),%edx
f0105848:	8d 4a 08             	lea    0x8(%edx),%ecx
f010584b:	89 08                	mov    %ecx,(%eax)
f010584d:	8b 02                	mov    (%edx),%eax
f010584f:	8b 52 04             	mov    0x4(%edx),%edx
f0105852:	eb 22                	jmp    f0105876 <getuint+0x38>
	else if (lflag)
f0105854:	85 d2                	test   %edx,%edx
f0105856:	74 10                	je     f0105868 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105858:	8b 10                	mov    (%eax),%edx
f010585a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010585d:	89 08                	mov    %ecx,(%eax)
f010585f:	8b 02                	mov    (%edx),%eax
f0105861:	ba 00 00 00 00       	mov    $0x0,%edx
f0105866:	eb 0e                	jmp    f0105876 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105868:	8b 10                	mov    (%eax),%edx
f010586a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010586d:	89 08                	mov    %ecx,(%eax)
f010586f:	8b 02                	mov    (%edx),%eax
f0105871:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105876:	5d                   	pop    %ebp
f0105877:	c3                   	ret    

f0105878 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105878:	55                   	push   %ebp
f0105879:	89 e5                	mov    %esp,%ebp
f010587b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010587e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105882:	8b 10                	mov    (%eax),%edx
f0105884:	3b 50 04             	cmp    0x4(%eax),%edx
f0105887:	73 0a                	jae    f0105893 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105889:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010588c:	88 0a                	mov    %cl,(%edx)
f010588e:	83 c2 01             	add    $0x1,%edx
f0105891:	89 10                	mov    %edx,(%eax)
}
f0105893:	5d                   	pop    %ebp
f0105894:	c3                   	ret    

f0105895 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105895:	55                   	push   %ebp
f0105896:	89 e5                	mov    %esp,%ebp
f0105898:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010589b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010589e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01058a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01058a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b3:	89 04 24             	mov    %eax,(%esp)
f01058b6:	e8 02 00 00 00       	call   f01058bd <vprintfmt>
	va_end(ap);
}
f01058bb:	c9                   	leave  
f01058bc:	c3                   	ret    

f01058bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01058bd:	55                   	push   %ebp
f01058be:	89 e5                	mov    %esp,%ebp
f01058c0:	57                   	push   %edi
f01058c1:	56                   	push   %esi
f01058c2:	53                   	push   %ebx
f01058c3:	83 ec 4c             	sub    $0x4c,%esp
f01058c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058c9:	8b 75 10             	mov    0x10(%ebp),%esi
f01058cc:	eb 12                	jmp    f01058e0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01058ce:	85 c0                	test   %eax,%eax
f01058d0:	0f 84 bf 03 00 00    	je     f0105c95 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f01058d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058da:	89 04 24             	mov    %eax,(%esp)
f01058dd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01058e0:	0f b6 06             	movzbl (%esi),%eax
f01058e3:	83 c6 01             	add    $0x1,%esi
f01058e6:	83 f8 25             	cmp    $0x25,%eax
f01058e9:	75 e3                	jne    f01058ce <vprintfmt+0x11>
f01058eb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01058ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01058f6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01058fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105902:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105907:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010590a:	eb 2b                	jmp    f0105937 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010590c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010590f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105913:	eb 22                	jmp    f0105937 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105915:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105918:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010591c:	eb 19                	jmp    f0105937 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010591e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105921:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105928:	eb 0d                	jmp    f0105937 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010592a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010592d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105930:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105937:	0f b6 16             	movzbl (%esi),%edx
f010593a:	0f b6 c2             	movzbl %dl,%eax
f010593d:	8d 7e 01             	lea    0x1(%esi),%edi
f0105940:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0105943:	83 ea 23             	sub    $0x23,%edx
f0105946:	80 fa 55             	cmp    $0x55,%dl
f0105949:	0f 87 28 03 00 00    	ja     f0105c77 <vprintfmt+0x3ba>
f010594f:	0f b6 d2             	movzbl %dl,%edx
f0105952:	ff 24 95 80 84 10 f0 	jmp    *-0xfef7b80(,%edx,4)
f0105959:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010595c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0105963:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105968:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010596b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010596f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105972:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105975:	83 fa 09             	cmp    $0x9,%edx
f0105978:	77 2f                	ja     f01059a9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010597a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010597d:	eb e9                	jmp    f0105968 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010597f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105982:	8d 50 04             	lea    0x4(%eax),%edx
f0105985:	89 55 14             	mov    %edx,0x14(%ebp)
f0105988:	8b 00                	mov    (%eax),%eax
f010598a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010598d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105990:	eb 1a                	jmp    f01059ac <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105992:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105995:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105999:	79 9c                	jns    f0105937 <vprintfmt+0x7a>
f010599b:	eb 81                	jmp    f010591e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010599d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01059a0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01059a7:	eb 8e                	jmp    f0105937 <vprintfmt+0x7a>
f01059a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f01059ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01059b0:	79 85                	jns    f0105937 <vprintfmt+0x7a>
f01059b2:	e9 73 ff ff ff       	jmp    f010592a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01059b7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01059bd:	e9 75 ff ff ff       	jmp    f0105937 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01059c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c5:	8d 50 04             	lea    0x4(%eax),%edx
f01059c8:	89 55 14             	mov    %edx,0x14(%ebp)
f01059cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059cf:	8b 00                	mov    (%eax),%eax
f01059d1:	89 04 24             	mov    %eax,(%esp)
f01059d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01059da:	e9 01 ff ff ff       	jmp    f01058e0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01059df:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e2:	8d 50 04             	lea    0x4(%eax),%edx
f01059e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01059e8:	8b 00                	mov    (%eax),%eax
f01059ea:	89 c2                	mov    %eax,%edx
f01059ec:	c1 fa 1f             	sar    $0x1f,%edx
f01059ef:	31 d0                	xor    %edx,%eax
f01059f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01059f3:	83 f8 09             	cmp    $0x9,%eax
f01059f6:	7f 0b                	jg     f0105a03 <vprintfmt+0x146>
f01059f8:	8b 14 85 e0 85 10 f0 	mov    -0xfef7a20(,%eax,4),%edx
f01059ff:	85 d2                	test   %edx,%edx
f0105a01:	75 23                	jne    f0105a26 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f0105a03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a07:	c7 44 24 08 d6 83 10 	movl   $0xf01083d6,0x8(%esp)
f0105a0e:	f0 
f0105a0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a13:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a16:	89 3c 24             	mov    %edi,(%esp)
f0105a19:	e8 77 fe ff ff       	call   f0105895 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a1e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105a21:	e9 ba fe ff ff       	jmp    f01058e0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105a26:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105a2a:	c7 44 24 08 61 7b 10 	movl   $0xf0107b61,0x8(%esp)
f0105a31:	f0 
f0105a32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a36:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a39:	89 3c 24             	mov    %edi,(%esp)
f0105a3c:	e8 54 fe ff ff       	call   f0105895 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a41:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105a44:	e9 97 fe ff ff       	jmp    f01058e0 <vprintfmt+0x23>
f0105a49:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105a4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105a52:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a55:	8d 50 04             	lea    0x4(%eax),%edx
f0105a58:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a5b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105a5d:	85 f6                	test   %esi,%esi
f0105a5f:	ba cf 83 10 f0       	mov    $0xf01083cf,%edx
f0105a64:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0105a67:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105a6b:	0f 8e 8c 00 00 00    	jle    f0105afd <vprintfmt+0x240>
f0105a71:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105a75:	0f 84 82 00 00 00    	je     f0105afd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a7b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a7f:	89 34 24             	mov    %esi,(%esp)
f0105a82:	e8 81 03 00 00       	call   f0105e08 <strnlen>
f0105a87:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105a8a:	29 c2                	sub    %eax,%edx
f0105a8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105a8f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105a93:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105a96:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105a99:	89 de                	mov    %ebx,%esi
f0105a9b:	89 d3                	mov    %edx,%ebx
f0105a9d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a9f:	eb 0d                	jmp    f0105aae <vprintfmt+0x1f1>
					putch(padc, putdat);
f0105aa1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105aa5:	89 3c 24             	mov    %edi,(%esp)
f0105aa8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105aab:	83 eb 01             	sub    $0x1,%ebx
f0105aae:	85 db                	test   %ebx,%ebx
f0105ab0:	7f ef                	jg     f0105aa1 <vprintfmt+0x1e4>
f0105ab2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105ab5:	89 f3                	mov    %esi,%ebx
f0105ab7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105aba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105abe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ac3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0105ac7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105aca:	29 c2                	sub    %eax,%edx
f0105acc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105acf:	eb 2c                	jmp    f0105afd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105ad1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105ad5:	74 18                	je     f0105aef <vprintfmt+0x232>
f0105ad7:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105ada:	83 fa 5e             	cmp    $0x5e,%edx
f0105add:	76 10                	jbe    f0105aef <vprintfmt+0x232>
					putch('?', putdat);
f0105adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ae3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105aea:	ff 55 08             	call   *0x8(%ebp)
f0105aed:	eb 0a                	jmp    f0105af9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f0105aef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105af3:	89 04 24             	mov    %eax,(%esp)
f0105af6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105af9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0105afd:	0f be 06             	movsbl (%esi),%eax
f0105b00:	83 c6 01             	add    $0x1,%esi
f0105b03:	85 c0                	test   %eax,%eax
f0105b05:	74 25                	je     f0105b2c <vprintfmt+0x26f>
f0105b07:	85 ff                	test   %edi,%edi
f0105b09:	78 c6                	js     f0105ad1 <vprintfmt+0x214>
f0105b0b:	83 ef 01             	sub    $0x1,%edi
f0105b0e:	79 c1                	jns    f0105ad1 <vprintfmt+0x214>
f0105b10:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b13:	89 de                	mov    %ebx,%esi
f0105b15:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105b18:	eb 1a                	jmp    f0105b34 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105b1a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b1e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105b25:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105b27:	83 eb 01             	sub    $0x1,%ebx
f0105b2a:	eb 08                	jmp    f0105b34 <vprintfmt+0x277>
f0105b2c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b2f:	89 de                	mov    %ebx,%esi
f0105b31:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105b34:	85 db                	test   %ebx,%ebx
f0105b36:	7f e2                	jg     f0105b1a <vprintfmt+0x25d>
f0105b38:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105b3b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b3d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b40:	e9 9b fd ff ff       	jmp    f01058e0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105b45:	83 f9 01             	cmp    $0x1,%ecx
f0105b48:	7e 10                	jle    f0105b5a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f0105b4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b4d:	8d 50 08             	lea    0x8(%eax),%edx
f0105b50:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b53:	8b 30                	mov    (%eax),%esi
f0105b55:	8b 78 04             	mov    0x4(%eax),%edi
f0105b58:	eb 26                	jmp    f0105b80 <vprintfmt+0x2c3>
	else if (lflag)
f0105b5a:	85 c9                	test   %ecx,%ecx
f0105b5c:	74 12                	je     f0105b70 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f0105b5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b61:	8d 50 04             	lea    0x4(%eax),%edx
f0105b64:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b67:	8b 30                	mov    (%eax),%esi
f0105b69:	89 f7                	mov    %esi,%edi
f0105b6b:	c1 ff 1f             	sar    $0x1f,%edi
f0105b6e:	eb 10                	jmp    f0105b80 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f0105b70:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b73:	8d 50 04             	lea    0x4(%eax),%edx
f0105b76:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b79:	8b 30                	mov    (%eax),%esi
f0105b7b:	89 f7                	mov    %esi,%edi
f0105b7d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105b80:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105b85:	85 ff                	test   %edi,%edi
f0105b87:	0f 89 ac 00 00 00    	jns    f0105c39 <vprintfmt+0x37c>
				putch('-', putdat);
f0105b8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b91:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105b98:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105b9b:	f7 de                	neg    %esi
f0105b9d:	83 d7 00             	adc    $0x0,%edi
f0105ba0:	f7 df                	neg    %edi
			}
			base = 10;
f0105ba2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ba7:	e9 8d 00 00 00       	jmp    f0105c39 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105bac:	89 ca                	mov    %ecx,%edx
f0105bae:	8d 45 14             	lea    0x14(%ebp),%eax
f0105bb1:	e8 88 fc ff ff       	call   f010583e <getuint>
f0105bb6:	89 c6                	mov    %eax,%esi
f0105bb8:	89 d7                	mov    %edx,%edi
			base = 10;
f0105bba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105bbf:	eb 78                	jmp    f0105c39 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105bc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bc5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105bcc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0105bcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bd3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105bda:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0105bdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105be1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105be8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105beb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105bee:	e9 ed fc ff ff       	jmp    f01058e0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0105bf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bf7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105bfe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105c01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c05:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105c0c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105c0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c12:	8d 50 04             	lea    0x4(%eax),%edx
f0105c15:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105c18:	8b 30                	mov    (%eax),%esi
f0105c1a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105c1f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105c24:	eb 13                	jmp    f0105c39 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105c26:	89 ca                	mov    %ecx,%edx
f0105c28:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c2b:	e8 0e fc ff ff       	call   f010583e <getuint>
f0105c30:	89 c6                	mov    %eax,%esi
f0105c32:	89 d7                	mov    %edx,%edi
			base = 16;
f0105c34:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105c39:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105c3d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105c41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105c44:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105c48:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c4c:	89 34 24             	mov    %esi,(%esp)
f0105c4f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c53:	89 da                	mov    %ebx,%edx
f0105c55:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c58:	e8 13 fb ff ff       	call   f0105770 <printnum>
			break;
f0105c5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c60:	e9 7b fc ff ff       	jmp    f01058e0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105c65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c69:	89 04 24             	mov    %eax,(%esp)
f0105c6c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c6f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105c72:	e9 69 fc ff ff       	jmp    f01058e0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105c77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c7b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105c82:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105c85:	eb 03                	jmp    f0105c8a <vprintfmt+0x3cd>
f0105c87:	83 ee 01             	sub    $0x1,%esi
f0105c8a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105c8e:	75 f7                	jne    f0105c87 <vprintfmt+0x3ca>
f0105c90:	e9 4b fc ff ff       	jmp    f01058e0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105c95:	83 c4 4c             	add    $0x4c,%esp
f0105c98:	5b                   	pop    %ebx
f0105c99:	5e                   	pop    %esi
f0105c9a:	5f                   	pop    %edi
f0105c9b:	5d                   	pop    %ebp
f0105c9c:	c3                   	ret    

f0105c9d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105c9d:	55                   	push   %ebp
f0105c9e:	89 e5                	mov    %esp,%ebp
f0105ca0:	83 ec 28             	sub    $0x28,%esp
f0105ca3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105ca9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105cac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105cb0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105cb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105cba:	85 c0                	test   %eax,%eax
f0105cbc:	74 30                	je     f0105cee <vsnprintf+0x51>
f0105cbe:	85 d2                	test   %edx,%edx
f0105cc0:	7e 2c                	jle    f0105cee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105cc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105cc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105cd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cd7:	c7 04 24 78 58 10 f0 	movl   $0xf0105878,(%esp)
f0105cde:	e8 da fb ff ff       	call   f01058bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105ce3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105ce6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105cec:	eb 05                	jmp    f0105cf3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105cee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105cf3:	c9                   	leave  
f0105cf4:	c3                   	ret    

f0105cf5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105cf5:	55                   	push   %ebp
f0105cf6:	89 e5                	mov    %esp,%ebp
f0105cf8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105cfb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d02:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d05:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d09:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d10:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d13:	89 04 24             	mov    %eax,(%esp)
f0105d16:	e8 82 ff ff ff       	call   f0105c9d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105d1b:	c9                   	leave  
f0105d1c:	c3                   	ret    
f0105d1d:	00 00                	add    %al,(%eax)
	...

f0105d20 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105d20:	55                   	push   %ebp
f0105d21:	89 e5                	mov    %esp,%ebp
f0105d23:	57                   	push   %edi
f0105d24:	56                   	push   %esi
f0105d25:	53                   	push   %ebx
f0105d26:	83 ec 1c             	sub    $0x1c,%esp
f0105d29:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105d2c:	85 c0                	test   %eax,%eax
f0105d2e:	74 10                	je     f0105d40 <readline+0x20>
		cprintf("%s", prompt);
f0105d30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d34:	c7 04 24 61 7b 10 f0 	movl   $0xf0107b61,(%esp)
f0105d3b:	e8 2e e2 ff ff       	call   f0103f6e <cprintf>

	i = 0;
	echoing = iscons(0);
f0105d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105d47:	e8 3f aa ff ff       	call   f010078b <iscons>
f0105d4c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105d4e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105d53:	e8 22 aa ff ff       	call   f010077a <getchar>
f0105d58:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105d5a:	85 c0                	test   %eax,%eax
f0105d5c:	79 17                	jns    f0105d75 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d62:	c7 04 24 08 86 10 f0 	movl   $0xf0108608,(%esp)
f0105d69:	e8 00 e2 ff ff       	call   f0103f6e <cprintf>
			return NULL;
f0105d6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d73:	eb 6d                	jmp    f0105de2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d75:	83 f8 08             	cmp    $0x8,%eax
f0105d78:	74 05                	je     f0105d7f <readline+0x5f>
f0105d7a:	83 f8 7f             	cmp    $0x7f,%eax
f0105d7d:	75 19                	jne    f0105d98 <readline+0x78>
f0105d7f:	85 f6                	test   %esi,%esi
f0105d81:	7e 15                	jle    f0105d98 <readline+0x78>
			if (echoing)
f0105d83:	85 ff                	test   %edi,%edi
f0105d85:	74 0c                	je     f0105d93 <readline+0x73>
				cputchar('\b');
f0105d87:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105d8e:	e8 d7 a9 ff ff       	call   f010076a <cputchar>
			i--;
f0105d93:	83 ee 01             	sub    $0x1,%esi
f0105d96:	eb bb                	jmp    f0105d53 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105d98:	83 fb 1f             	cmp    $0x1f,%ebx
f0105d9b:	7e 1f                	jle    f0105dbc <readline+0x9c>
f0105d9d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105da3:	7f 17                	jg     f0105dbc <readline+0x9c>
			if (echoing)
f0105da5:	85 ff                	test   %edi,%edi
f0105da7:	74 08                	je     f0105db1 <readline+0x91>
				cputchar(c);
f0105da9:	89 1c 24             	mov    %ebx,(%esp)
f0105dac:	e8 b9 a9 ff ff       	call   f010076a <cputchar>
			buf[i++] = c;
f0105db1:	88 9e 80 2a 23 f0    	mov    %bl,-0xfdcd580(%esi)
f0105db7:	83 c6 01             	add    $0x1,%esi
f0105dba:	eb 97                	jmp    f0105d53 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105dbc:	83 fb 0a             	cmp    $0xa,%ebx
f0105dbf:	74 05                	je     f0105dc6 <readline+0xa6>
f0105dc1:	83 fb 0d             	cmp    $0xd,%ebx
f0105dc4:	75 8d                	jne    f0105d53 <readline+0x33>
			if (echoing)
f0105dc6:	85 ff                	test   %edi,%edi
f0105dc8:	74 0c                	je     f0105dd6 <readline+0xb6>
				cputchar('\n');
f0105dca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105dd1:	e8 94 a9 ff ff       	call   f010076a <cputchar>
			buf[i] = 0;
f0105dd6:	c6 86 80 2a 23 f0 00 	movb   $0x0,-0xfdcd580(%esi)
			return buf;
f0105ddd:	b8 80 2a 23 f0       	mov    $0xf0232a80,%eax
		}
	}
}
f0105de2:	83 c4 1c             	add    $0x1c,%esp
f0105de5:	5b                   	pop    %ebx
f0105de6:	5e                   	pop    %esi
f0105de7:	5f                   	pop    %edi
f0105de8:	5d                   	pop    %ebp
f0105de9:	c3                   	ret    
f0105dea:	00 00                	add    %al,(%eax)
f0105dec:	00 00                	add    %al,(%eax)
	...

f0105df0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105df0:	55                   	push   %ebp
f0105df1:	89 e5                	mov    %esp,%ebp
f0105df3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105df6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dfb:	eb 03                	jmp    f0105e00 <strlen+0x10>
		n++;
f0105dfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105e04:	75 f7                	jne    f0105dfd <strlen+0xd>
		n++;
	return n;
}
f0105e06:	5d                   	pop    %ebp
f0105e07:	c3                   	ret    

f0105e08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105e08:	55                   	push   %ebp
f0105e09:	89 e5                	mov    %esp,%ebp
f0105e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e11:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e16:	eb 03                	jmp    f0105e1b <strnlen+0x13>
		n++;
f0105e18:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e1b:	39 d0                	cmp    %edx,%eax
f0105e1d:	74 06                	je     f0105e25 <strnlen+0x1d>
f0105e1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105e23:	75 f3                	jne    f0105e18 <strnlen+0x10>
		n++;
	return n;
}
f0105e25:	5d                   	pop    %ebp
f0105e26:	c3                   	ret    

f0105e27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105e27:	55                   	push   %ebp
f0105e28:	89 e5                	mov    %esp,%ebp
f0105e2a:	53                   	push   %ebx
f0105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105e31:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e36:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105e3a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105e3d:	83 c2 01             	add    $0x1,%edx
f0105e40:	84 c9                	test   %cl,%cl
f0105e42:	75 f2                	jne    f0105e36 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105e44:	5b                   	pop    %ebx
f0105e45:	5d                   	pop    %ebp
f0105e46:	c3                   	ret    

f0105e47 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105e47:	55                   	push   %ebp
f0105e48:	89 e5                	mov    %esp,%ebp
f0105e4a:	53                   	push   %ebx
f0105e4b:	83 ec 08             	sub    $0x8,%esp
f0105e4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105e51:	89 1c 24             	mov    %ebx,(%esp)
f0105e54:	e8 97 ff ff ff       	call   f0105df0 <strlen>
	strcpy(dst + len, src);
f0105e59:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e60:	01 d8                	add    %ebx,%eax
f0105e62:	89 04 24             	mov    %eax,(%esp)
f0105e65:	e8 bd ff ff ff       	call   f0105e27 <strcpy>
	return dst;
}
f0105e6a:	89 d8                	mov    %ebx,%eax
f0105e6c:	83 c4 08             	add    $0x8,%esp
f0105e6f:	5b                   	pop    %ebx
f0105e70:	5d                   	pop    %ebp
f0105e71:	c3                   	ret    

f0105e72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105e72:	55                   	push   %ebp
f0105e73:	89 e5                	mov    %esp,%ebp
f0105e75:	56                   	push   %esi
f0105e76:	53                   	push   %ebx
f0105e77:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e7d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e80:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105e85:	eb 0f                	jmp    f0105e96 <strncpy+0x24>
		*dst++ = *src;
f0105e87:	0f b6 1a             	movzbl (%edx),%ebx
f0105e8a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105e8d:	80 3a 01             	cmpb   $0x1,(%edx)
f0105e90:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e93:	83 c1 01             	add    $0x1,%ecx
f0105e96:	39 f1                	cmp    %esi,%ecx
f0105e98:	75 ed                	jne    f0105e87 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105e9a:	5b                   	pop    %ebx
f0105e9b:	5e                   	pop    %esi
f0105e9c:	5d                   	pop    %ebp
f0105e9d:	c3                   	ret    

f0105e9e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105e9e:	55                   	push   %ebp
f0105e9f:	89 e5                	mov    %esp,%ebp
f0105ea1:	56                   	push   %esi
f0105ea2:	53                   	push   %ebx
f0105ea3:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ea9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105eac:	89 f0                	mov    %esi,%eax
f0105eae:	85 d2                	test   %edx,%edx
f0105eb0:	75 0a                	jne    f0105ebc <strlcpy+0x1e>
f0105eb2:	eb 1d                	jmp    f0105ed1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105eb4:	88 18                	mov    %bl,(%eax)
f0105eb6:	83 c0 01             	add    $0x1,%eax
f0105eb9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105ebc:	83 ea 01             	sub    $0x1,%edx
f0105ebf:	74 0b                	je     f0105ecc <strlcpy+0x2e>
f0105ec1:	0f b6 19             	movzbl (%ecx),%ebx
f0105ec4:	84 db                	test   %bl,%bl
f0105ec6:	75 ec                	jne    f0105eb4 <strlcpy+0x16>
f0105ec8:	89 c2                	mov    %eax,%edx
f0105eca:	eb 02                	jmp    f0105ece <strlcpy+0x30>
f0105ecc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105ece:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105ed1:	29 f0                	sub    %esi,%eax
}
f0105ed3:	5b                   	pop    %ebx
f0105ed4:	5e                   	pop    %esi
f0105ed5:	5d                   	pop    %ebp
f0105ed6:	c3                   	ret    

f0105ed7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105ed7:	55                   	push   %ebp
f0105ed8:	89 e5                	mov    %esp,%ebp
f0105eda:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105edd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ee0:	eb 06                	jmp    f0105ee8 <strcmp+0x11>
		p++, q++;
f0105ee2:	83 c1 01             	add    $0x1,%ecx
f0105ee5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105ee8:	0f b6 01             	movzbl (%ecx),%eax
f0105eeb:	84 c0                	test   %al,%al
f0105eed:	74 04                	je     f0105ef3 <strcmp+0x1c>
f0105eef:	3a 02                	cmp    (%edx),%al
f0105ef1:	74 ef                	je     f0105ee2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ef3:	0f b6 c0             	movzbl %al,%eax
f0105ef6:	0f b6 12             	movzbl (%edx),%edx
f0105ef9:	29 d0                	sub    %edx,%eax
}
f0105efb:	5d                   	pop    %ebp
f0105efc:	c3                   	ret    

f0105efd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105efd:	55                   	push   %ebp
f0105efe:	89 e5                	mov    %esp,%ebp
f0105f00:	53                   	push   %ebx
f0105f01:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f07:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105f0a:	eb 09                	jmp    f0105f15 <strncmp+0x18>
		n--, p++, q++;
f0105f0c:	83 ea 01             	sub    $0x1,%edx
f0105f0f:	83 c0 01             	add    $0x1,%eax
f0105f12:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105f15:	85 d2                	test   %edx,%edx
f0105f17:	74 15                	je     f0105f2e <strncmp+0x31>
f0105f19:	0f b6 18             	movzbl (%eax),%ebx
f0105f1c:	84 db                	test   %bl,%bl
f0105f1e:	74 04                	je     f0105f24 <strncmp+0x27>
f0105f20:	3a 19                	cmp    (%ecx),%bl
f0105f22:	74 e8                	je     f0105f0c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f24:	0f b6 00             	movzbl (%eax),%eax
f0105f27:	0f b6 11             	movzbl (%ecx),%edx
f0105f2a:	29 d0                	sub    %edx,%eax
f0105f2c:	eb 05                	jmp    f0105f33 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105f33:	5b                   	pop    %ebx
f0105f34:	5d                   	pop    %ebp
f0105f35:	c3                   	ret    

f0105f36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105f36:	55                   	push   %ebp
f0105f37:	89 e5                	mov    %esp,%ebp
f0105f39:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f40:	eb 07                	jmp    f0105f49 <strchr+0x13>
		if (*s == c)
f0105f42:	38 ca                	cmp    %cl,%dl
f0105f44:	74 0f                	je     f0105f55 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105f46:	83 c0 01             	add    $0x1,%eax
f0105f49:	0f b6 10             	movzbl (%eax),%edx
f0105f4c:	84 d2                	test   %dl,%dl
f0105f4e:	75 f2                	jne    f0105f42 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f55:	5d                   	pop    %ebp
f0105f56:	c3                   	ret    

f0105f57 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105f57:	55                   	push   %ebp
f0105f58:	89 e5                	mov    %esp,%ebp
f0105f5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f61:	eb 07                	jmp    f0105f6a <strfind+0x13>
		if (*s == c)
f0105f63:	38 ca                	cmp    %cl,%dl
f0105f65:	74 0a                	je     f0105f71 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105f67:	83 c0 01             	add    $0x1,%eax
f0105f6a:	0f b6 10             	movzbl (%eax),%edx
f0105f6d:	84 d2                	test   %dl,%dl
f0105f6f:	75 f2                	jne    f0105f63 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105f71:	5d                   	pop    %ebp
f0105f72:	c3                   	ret    

f0105f73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105f73:	55                   	push   %ebp
f0105f74:	89 e5                	mov    %esp,%ebp
f0105f76:	83 ec 0c             	sub    $0xc,%esp
f0105f79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105f7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105f7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105f82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105f8b:	85 c9                	test   %ecx,%ecx
f0105f8d:	74 30                	je     f0105fbf <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f95:	75 25                	jne    f0105fbc <memset+0x49>
f0105f97:	f6 c1 03             	test   $0x3,%cl
f0105f9a:	75 20                	jne    f0105fbc <memset+0x49>
		c &= 0xFF;
f0105f9c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105f9f:	89 d3                	mov    %edx,%ebx
f0105fa1:	c1 e3 08             	shl    $0x8,%ebx
f0105fa4:	89 d6                	mov    %edx,%esi
f0105fa6:	c1 e6 18             	shl    $0x18,%esi
f0105fa9:	89 d0                	mov    %edx,%eax
f0105fab:	c1 e0 10             	shl    $0x10,%eax
f0105fae:	09 f0                	or     %esi,%eax
f0105fb0:	09 d0                	or     %edx,%eax
f0105fb2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105fb4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105fb7:	fc                   	cld    
f0105fb8:	f3 ab                	rep stos %eax,%es:(%edi)
f0105fba:	eb 03                	jmp    f0105fbf <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105fbc:	fc                   	cld    
f0105fbd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105fbf:	89 f8                	mov    %edi,%eax
f0105fc1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105fc4:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105fc7:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105fca:	89 ec                	mov    %ebp,%esp
f0105fcc:	5d                   	pop    %ebp
f0105fcd:	c3                   	ret    

f0105fce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105fce:	55                   	push   %ebp
f0105fcf:	89 e5                	mov    %esp,%ebp
f0105fd1:	83 ec 08             	sub    $0x8,%esp
f0105fd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105fd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105fda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fdd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fe0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105fe3:	39 c6                	cmp    %eax,%esi
f0105fe5:	73 36                	jae    f010601d <memmove+0x4f>
f0105fe7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105fea:	39 d0                	cmp    %edx,%eax
f0105fec:	73 2f                	jae    f010601d <memmove+0x4f>
		s += n;
		d += n;
f0105fee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ff1:	f6 c2 03             	test   $0x3,%dl
f0105ff4:	75 1b                	jne    f0106011 <memmove+0x43>
f0105ff6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105ffc:	75 13                	jne    f0106011 <memmove+0x43>
f0105ffe:	f6 c1 03             	test   $0x3,%cl
f0106001:	75 0e                	jne    f0106011 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106003:	83 ef 04             	sub    $0x4,%edi
f0106006:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106009:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010600c:	fd                   	std    
f010600d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010600f:	eb 09                	jmp    f010601a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106011:	83 ef 01             	sub    $0x1,%edi
f0106014:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106017:	fd                   	std    
f0106018:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010601a:	fc                   	cld    
f010601b:	eb 20                	jmp    f010603d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010601d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106023:	75 13                	jne    f0106038 <memmove+0x6a>
f0106025:	a8 03                	test   $0x3,%al
f0106027:	75 0f                	jne    f0106038 <memmove+0x6a>
f0106029:	f6 c1 03             	test   $0x3,%cl
f010602c:	75 0a                	jne    f0106038 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010602e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106031:	89 c7                	mov    %eax,%edi
f0106033:	fc                   	cld    
f0106034:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106036:	eb 05                	jmp    f010603d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106038:	89 c7                	mov    %eax,%edi
f010603a:	fc                   	cld    
f010603b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010603d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106040:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106043:	89 ec                	mov    %ebp,%esp
f0106045:	5d                   	pop    %ebp
f0106046:	c3                   	ret    

f0106047 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106047:	55                   	push   %ebp
f0106048:	89 e5                	mov    %esp,%ebp
f010604a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010604d:	8b 45 10             	mov    0x10(%ebp),%eax
f0106050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106054:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106057:	89 44 24 04          	mov    %eax,0x4(%esp)
f010605b:	8b 45 08             	mov    0x8(%ebp),%eax
f010605e:	89 04 24             	mov    %eax,(%esp)
f0106061:	e8 68 ff ff ff       	call   f0105fce <memmove>
}
f0106066:	c9                   	leave  
f0106067:	c3                   	ret    

f0106068 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106068:	55                   	push   %ebp
f0106069:	89 e5                	mov    %esp,%ebp
f010606b:	57                   	push   %edi
f010606c:	56                   	push   %esi
f010606d:	53                   	push   %ebx
f010606e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106071:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106074:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106077:	ba 00 00 00 00       	mov    $0x0,%edx
f010607c:	eb 1a                	jmp    f0106098 <memcmp+0x30>
		if (*s1 != *s2)
f010607e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0106082:	83 c2 01             	add    $0x1,%edx
f0106085:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f010608a:	38 c8                	cmp    %cl,%al
f010608c:	74 0a                	je     f0106098 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f010608e:	0f b6 c0             	movzbl %al,%eax
f0106091:	0f b6 c9             	movzbl %cl,%ecx
f0106094:	29 c8                	sub    %ecx,%eax
f0106096:	eb 09                	jmp    f01060a1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106098:	39 da                	cmp    %ebx,%edx
f010609a:	75 e2                	jne    f010607e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010609c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060a1:	5b                   	pop    %ebx
f01060a2:	5e                   	pop    %esi
f01060a3:	5f                   	pop    %edi
f01060a4:	5d                   	pop    %ebp
f01060a5:	c3                   	ret    

f01060a6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01060a6:	55                   	push   %ebp
f01060a7:	89 e5                	mov    %esp,%ebp
f01060a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01060af:	89 c2                	mov    %eax,%edx
f01060b1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01060b4:	eb 07                	jmp    f01060bd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01060b6:	38 08                	cmp    %cl,(%eax)
f01060b8:	74 07                	je     f01060c1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060ba:	83 c0 01             	add    $0x1,%eax
f01060bd:	39 d0                	cmp    %edx,%eax
f01060bf:	72 f5                	jb     f01060b6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01060c1:	5d                   	pop    %ebp
f01060c2:	c3                   	ret    

f01060c3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01060c3:	55                   	push   %ebp
f01060c4:	89 e5                	mov    %esp,%ebp
f01060c6:	57                   	push   %edi
f01060c7:	56                   	push   %esi
f01060c8:	53                   	push   %ebx
f01060c9:	8b 55 08             	mov    0x8(%ebp),%edx
f01060cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060cf:	eb 03                	jmp    f01060d4 <strtol+0x11>
		s++;
f01060d1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060d4:	0f b6 02             	movzbl (%edx),%eax
f01060d7:	3c 20                	cmp    $0x20,%al
f01060d9:	74 f6                	je     f01060d1 <strtol+0xe>
f01060db:	3c 09                	cmp    $0x9,%al
f01060dd:	74 f2                	je     f01060d1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01060df:	3c 2b                	cmp    $0x2b,%al
f01060e1:	75 0a                	jne    f01060ed <strtol+0x2a>
		s++;
f01060e3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01060e6:	bf 00 00 00 00       	mov    $0x0,%edi
f01060eb:	eb 10                	jmp    f01060fd <strtol+0x3a>
f01060ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01060f2:	3c 2d                	cmp    $0x2d,%al
f01060f4:	75 07                	jne    f01060fd <strtol+0x3a>
		s++, neg = 1;
f01060f6:	8d 52 01             	lea    0x1(%edx),%edx
f01060f9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01060fd:	85 db                	test   %ebx,%ebx
f01060ff:	0f 94 c0             	sete   %al
f0106102:	74 05                	je     f0106109 <strtol+0x46>
f0106104:	83 fb 10             	cmp    $0x10,%ebx
f0106107:	75 15                	jne    f010611e <strtol+0x5b>
f0106109:	80 3a 30             	cmpb   $0x30,(%edx)
f010610c:	75 10                	jne    f010611e <strtol+0x5b>
f010610e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106112:	75 0a                	jne    f010611e <strtol+0x5b>
		s += 2, base = 16;
f0106114:	83 c2 02             	add    $0x2,%edx
f0106117:	bb 10 00 00 00       	mov    $0x10,%ebx
f010611c:	eb 13                	jmp    f0106131 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010611e:	84 c0                	test   %al,%al
f0106120:	74 0f                	je     f0106131 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106122:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106127:	80 3a 30             	cmpb   $0x30,(%edx)
f010612a:	75 05                	jne    f0106131 <strtol+0x6e>
		s++, base = 8;
f010612c:	83 c2 01             	add    $0x1,%edx
f010612f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0106131:	b8 00 00 00 00       	mov    $0x0,%eax
f0106136:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106138:	0f b6 0a             	movzbl (%edx),%ecx
f010613b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010613e:	80 fb 09             	cmp    $0x9,%bl
f0106141:	77 08                	ja     f010614b <strtol+0x88>
			dig = *s - '0';
f0106143:	0f be c9             	movsbl %cl,%ecx
f0106146:	83 e9 30             	sub    $0x30,%ecx
f0106149:	eb 1e                	jmp    f0106169 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f010614b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010614e:	80 fb 19             	cmp    $0x19,%bl
f0106151:	77 08                	ja     f010615b <strtol+0x98>
			dig = *s - 'a' + 10;
f0106153:	0f be c9             	movsbl %cl,%ecx
f0106156:	83 e9 57             	sub    $0x57,%ecx
f0106159:	eb 0e                	jmp    f0106169 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010615b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010615e:	80 fb 19             	cmp    $0x19,%bl
f0106161:	77 14                	ja     f0106177 <strtol+0xb4>
			dig = *s - 'A' + 10;
f0106163:	0f be c9             	movsbl %cl,%ecx
f0106166:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106169:	39 f1                	cmp    %esi,%ecx
f010616b:	7d 0e                	jge    f010617b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f010616d:	83 c2 01             	add    $0x1,%edx
f0106170:	0f af c6             	imul   %esi,%eax
f0106173:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0106175:	eb c1                	jmp    f0106138 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106177:	89 c1                	mov    %eax,%ecx
f0106179:	eb 02                	jmp    f010617d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010617b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010617d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106181:	74 05                	je     f0106188 <strtol+0xc5>
		*endptr = (char *) s;
f0106183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106186:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106188:	89 ca                	mov    %ecx,%edx
f010618a:	f7 da                	neg    %edx
f010618c:	85 ff                	test   %edi,%edi
f010618e:	0f 45 c2             	cmovne %edx,%eax
}
f0106191:	5b                   	pop    %ebx
f0106192:	5e                   	pop    %esi
f0106193:	5f                   	pop    %edi
f0106194:	5d                   	pop    %ebp
f0106195:	c3                   	ret    
	...

f0106198 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106198:	fa                   	cli    

	xorw    %ax, %ax
f0106199:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010619b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010619d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010619f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01061a1:	0f 01 16             	lgdtl  (%esi)
f01061a4:	74 70                	je     f0106216 <mpentry_end+0x4>
	movl    %cr0, %eax
f01061a6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01061a9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01061ad:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01061b0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01061b6:	08 00                	or     %al,(%eax)

f01061b8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01061b8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01061bc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061be:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061c0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01061c2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01061c6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01061c8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01061ca:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f01061cf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01061d2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01061d5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01061da:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01061dd:	8b 25 84 2e 23 f0    	mov    0xf0232e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01061e3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01061e8:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01061ed:	ff d0                	call   *%eax

f01061ef <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01061ef:	eb fe                	jmp    f01061ef <spin>
f01061f1:	8d 76 00             	lea    0x0(%esi),%esi

f01061f4 <gdt>:
	...
f01061fc:	ff                   	(bad)  
f01061fd:	ff 00                	incl   (%eax)
f01061ff:	00 00                	add    %al,(%eax)
f0106201:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106208:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f010620c <gdtdesc>:
f010620c:	17                   	pop    %ss
f010620d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106212 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106212:	90                   	nop
	...

f0106220 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106220:	55                   	push   %ebp
f0106221:	89 e5                	mov    %esp,%ebp
f0106223:	56                   	push   %esi
f0106224:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106225:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010622a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010622f:	eb 09                	jmp    f010623a <sum+0x1a>
		sum += ((uint8_t *)addr)[i];
f0106231:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106235:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106237:	83 c1 01             	add    $0x1,%ecx
f010623a:	39 d1                	cmp    %edx,%ecx
f010623c:	7c f3                	jl     f0106231 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f010623e:	89 d8                	mov    %ebx,%eax
f0106240:	5b                   	pop    %ebx
f0106241:	5e                   	pop    %esi
f0106242:	5d                   	pop    %ebp
f0106243:	c3                   	ret    

f0106244 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106244:	55                   	push   %ebp
f0106245:	89 e5                	mov    %esp,%ebp
f0106247:	56                   	push   %esi
f0106248:	53                   	push   %ebx
f0106249:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010624c:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f0106252:	89 c3                	mov    %eax,%ebx
f0106254:	c1 eb 0c             	shr    $0xc,%ebx
f0106257:	39 cb                	cmp    %ecx,%ebx
f0106259:	72 20                	jb     f010627b <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010625b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010625f:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0106266:	f0 
f0106267:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010626e:	00 
f010626f:	c7 04 24 a5 87 10 f0 	movl   $0xf01087a5,(%esp)
f0106276:	e8 c5 9d ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010627b:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010627e:	89 f2                	mov    %esi,%edx
f0106280:	c1 ea 0c             	shr    $0xc,%edx
f0106283:	39 d1                	cmp    %edx,%ecx
f0106285:	77 20                	ja     f01062a7 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106287:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010628b:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0106292:	f0 
f0106293:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010629a:	00 
f010629b:	c7 04 24 a5 87 10 f0 	movl   $0xf01087a5,(%esp)
f01062a2:	e8 99 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01062a7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01062ad:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01062b3:	eb 2f                	jmp    f01062e4 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062b5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01062bc:	00 
f01062bd:	c7 44 24 04 b5 87 10 	movl   $0xf01087b5,0x4(%esp)
f01062c4:	f0 
f01062c5:	89 1c 24             	mov    %ebx,(%esp)
f01062c8:	e8 9b fd ff ff       	call   f0106068 <memcmp>
f01062cd:	85 c0                	test   %eax,%eax
f01062cf:	75 10                	jne    f01062e1 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f01062d1:	ba 10 00 00 00       	mov    $0x10,%edx
f01062d6:	89 d8                	mov    %ebx,%eax
f01062d8:	e8 43 ff ff ff       	call   f0106220 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062dd:	84 c0                	test   %al,%al
f01062df:	74 0c                	je     f01062ed <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01062e1:	83 c3 10             	add    $0x10,%ebx
f01062e4:	39 f3                	cmp    %esi,%ebx
f01062e6:	72 cd                	jb     f01062b5 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01062e8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01062ed:	89 d8                	mov    %ebx,%eax
f01062ef:	83 c4 10             	add    $0x10,%esp
f01062f2:	5b                   	pop    %ebx
f01062f3:	5e                   	pop    %esi
f01062f4:	5d                   	pop    %ebp
f01062f5:	c3                   	ret    

f01062f6 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01062f6:	55                   	push   %ebp
f01062f7:	89 e5                	mov    %esp,%ebp
f01062f9:	57                   	push   %edi
f01062fa:	56                   	push   %esi
f01062fb:	53                   	push   %ebx
f01062fc:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01062ff:	c7 05 c0 33 23 f0 20 	movl   $0xf0233020,0xf02333c0
f0106306:	30 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106309:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f0106310:	75 24                	jne    f0106336 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106312:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106319:	00 
f010631a:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0106321:	f0 
f0106322:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106329:	00 
f010632a:	c7 04 24 a5 87 10 f0 	movl   $0xf01087a5,(%esp)
f0106331:	e8 0a 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106336:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010633d:	85 c0                	test   %eax,%eax
f010633f:	74 16                	je     f0106357 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106341:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106344:	ba 00 04 00 00       	mov    $0x400,%edx
f0106349:	e8 f6 fe ff ff       	call   f0106244 <mpsearch1>
f010634e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106351:	85 c0                	test   %eax,%eax
f0106353:	75 3c                	jne    f0106391 <mp_init+0x9b>
f0106355:	eb 20                	jmp    f0106377 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106357:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010635e:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106361:	2d 00 04 00 00       	sub    $0x400,%eax
f0106366:	ba 00 04 00 00       	mov    $0x400,%edx
f010636b:	e8 d4 fe ff ff       	call   f0106244 <mpsearch1>
f0106370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106373:	85 c0                	test   %eax,%eax
f0106375:	75 1a                	jne    f0106391 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106377:	ba 00 00 01 00       	mov    $0x10000,%edx
f010637c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106381:	e8 be fe ff ff       	call   f0106244 <mpsearch1>
f0106386:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106389:	85 c0                	test   %eax,%eax
f010638b:	0f 84 21 02 00 00    	je     f01065b2 <mp_init+0x2bc>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106394:	8b 78 04             	mov    0x4(%eax),%edi
f0106397:	85 ff                	test   %edi,%edi
f0106399:	74 06                	je     f01063a1 <mp_init+0xab>
f010639b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010639f:	74 11                	je     f01063b2 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01063a1:	c7 04 24 18 86 10 f0 	movl   $0xf0108618,(%esp)
f01063a8:	e8 c1 db ff ff       	call   f0103f6e <cprintf>
f01063ad:	e9 00 02 00 00       	jmp    f01065b2 <mp_init+0x2bc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063b2:	89 f8                	mov    %edi,%eax
f01063b4:	c1 e8 0c             	shr    $0xc,%eax
f01063b7:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f01063bd:	72 20                	jb     f01063df <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063bf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01063c3:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f01063ca:	f0 
f01063cb:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01063d2:	00 
f01063d3:	c7 04 24 a5 87 10 f0 	movl   $0xf01087a5,(%esp)
f01063da:	e8 61 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063df:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01063e5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063ec:	00 
f01063ed:	c7 44 24 04 ba 87 10 	movl   $0xf01087ba,0x4(%esp)
f01063f4:	f0 
f01063f5:	89 3c 24             	mov    %edi,(%esp)
f01063f8:	e8 6b fc ff ff       	call   f0106068 <memcmp>
f01063fd:	85 c0                	test   %eax,%eax
f01063ff:	74 11                	je     f0106412 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106401:	c7 04 24 48 86 10 f0 	movl   $0xf0108648,(%esp)
f0106408:	e8 61 db ff ff       	call   f0103f6e <cprintf>
f010640d:	e9 a0 01 00 00       	jmp    f01065b2 <mp_init+0x2bc>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106412:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106416:	0f b7 d3             	movzwl %bx,%edx
f0106419:	89 f8                	mov    %edi,%eax
f010641b:	e8 00 fe ff ff       	call   f0106220 <sum>
f0106420:	84 c0                	test   %al,%al
f0106422:	74 11                	je     f0106435 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106424:	c7 04 24 7c 86 10 f0 	movl   $0xf010867c,(%esp)
f010642b:	e8 3e db ff ff       	call   f0103f6e <cprintf>
f0106430:	e9 7d 01 00 00       	jmp    f01065b2 <mp_init+0x2bc>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106435:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106439:	3c 01                	cmp    $0x1,%al
f010643b:	74 1d                	je     f010645a <mp_init+0x164>
f010643d:	3c 04                	cmp    $0x4,%al
f010643f:	90                   	nop
f0106440:	74 18                	je     f010645a <mp_init+0x164>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106442:	0f b6 c0             	movzbl %al,%eax
f0106445:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106449:	c7 04 24 a0 86 10 f0 	movl   $0xf01086a0,(%esp)
f0106450:	e8 19 db ff ff       	call   f0103f6e <cprintf>
f0106455:	e9 58 01 00 00       	jmp    f01065b2 <mp_init+0x2bc>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010645a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010645e:	0f b7 db             	movzwl %bx,%ebx
f0106461:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0106464:	e8 b7 fd ff ff       	call   f0106220 <sum>
f0106469:	02 47 2a             	add    0x2a(%edi),%al
f010646c:	84 c0                	test   %al,%al
f010646e:	74 11                	je     f0106481 <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106470:	c7 04 24 c0 86 10 f0 	movl   $0xf01086c0,(%esp)
f0106477:	e8 f2 da ff ff       	call   f0103f6e <cprintf>
f010647c:	e9 31 01 00 00       	jmp    f01065b2 <mp_init+0x2bc>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106481:	85 ff                	test   %edi,%edi
f0106483:	0f 84 29 01 00 00    	je     f01065b2 <mp_init+0x2bc>
		return;
	ismp = 1;
f0106489:	c7 05 00 30 23 f0 01 	movl   $0x1,0xf0233000
f0106490:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106493:	8b 47 24             	mov    0x24(%edi),%eax
f0106496:	a3 00 40 27 f0       	mov    %eax,0xf0274000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010649b:	8d 77 2c             	lea    0x2c(%edi),%esi
f010649e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01064a3:	e9 83 00 00 00       	jmp    f010652b <mp_init+0x235>
		switch (*p) {
f01064a8:	0f b6 06             	movzbl (%esi),%eax
f01064ab:	84 c0                	test   %al,%al
f01064ad:	74 06                	je     f01064b5 <mp_init+0x1bf>
f01064af:	3c 04                	cmp    $0x4,%al
f01064b1:	77 54                	ja     f0106507 <mp_init+0x211>
f01064b3:	eb 4d                	jmp    f0106502 <mp_init+0x20c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01064b5:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01064b9:	74 11                	je     f01064cc <mp_init+0x1d6>
				bootcpu = &cpus[ncpu];
f01064bb:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f01064c2:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01064c7:	a3 c0 33 23 f0       	mov    %eax,0xf02333c0
			if (ncpu < NCPU) {
f01064cc:	a1 c4 33 23 f0       	mov    0xf02333c4,%eax
f01064d1:	83 f8 07             	cmp    $0x7,%eax
f01064d4:	7f 13                	jg     f01064e9 <mp_init+0x1f3>
				cpus[ncpu].cpu_id = ncpu;
f01064d6:	6b d0 74             	imul   $0x74,%eax,%edx
f01064d9:	88 82 20 30 23 f0    	mov    %al,-0xfdccfe0(%edx)
				ncpu++;
f01064df:	83 c0 01             	add    $0x1,%eax
f01064e2:	a3 c4 33 23 f0       	mov    %eax,0xf02333c4
f01064e7:	eb 14                	jmp    f01064fd <mp_init+0x207>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01064e9:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01064ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064f1:	c7 04 24 f0 86 10 f0 	movl   $0xf01086f0,(%esp)
f01064f8:	e8 71 da ff ff       	call   f0103f6e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01064fd:	83 c6 14             	add    $0x14,%esi
			continue;
f0106500:	eb 26                	jmp    f0106528 <mp_init+0x232>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106502:	83 c6 08             	add    $0x8,%esi
			continue;
f0106505:	eb 21                	jmp    f0106528 <mp_init+0x232>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106507:	0f b6 c0             	movzbl %al,%eax
f010650a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010650e:	c7 04 24 18 87 10 f0 	movl   $0xf0108718,(%esp)
f0106515:	e8 54 da ff ff       	call   f0103f6e <cprintf>
			ismp = 0;
f010651a:	c7 05 00 30 23 f0 00 	movl   $0x0,0xf0233000
f0106521:	00 00 00 
			i = conf->entry;
f0106524:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106528:	83 c3 01             	add    $0x1,%ebx
f010652b:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010652f:	39 c3                	cmp    %eax,%ebx
f0106531:	0f 82 71 ff ff ff    	jb     f01064a8 <mp_init+0x1b2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106537:	a1 c0 33 23 f0       	mov    0xf02333c0,%eax
f010653c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106543:	83 3d 00 30 23 f0 00 	cmpl   $0x0,0xf0233000
f010654a:	75 22                	jne    f010656e <mp_init+0x278>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010654c:	c7 05 c4 33 23 f0 01 	movl   $0x1,0xf02333c4
f0106553:	00 00 00 
		lapicaddr = 0;
f0106556:	c7 05 00 40 27 f0 00 	movl   $0x0,0xf0274000
f010655d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106560:	c7 04 24 38 87 10 f0 	movl   $0xf0108738,(%esp)
f0106567:	e8 02 da ff ff       	call   f0103f6e <cprintf>
		return;
f010656c:	eb 44                	jmp    f01065b2 <mp_init+0x2bc>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010656e:	8b 15 c4 33 23 f0    	mov    0xf02333c4,%edx
f0106574:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106578:	0f b6 00             	movzbl (%eax),%eax
f010657b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010657f:	c7 04 24 bf 87 10 f0 	movl   $0xf01087bf,(%esp)
f0106586:	e8 e3 d9 ff ff       	call   f0103f6e <cprintf>

	if (mp->imcrp) {
f010658b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010658e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106592:	74 1e                	je     f01065b2 <mp_init+0x2bc>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106594:	c7 04 24 64 87 10 f0 	movl   $0xf0108764,(%esp)
f010659b:	e8 ce d9 ff ff       	call   f0103f6e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065a0:	ba 22 00 00 00       	mov    $0x22,%edx
f01065a5:	b8 70 00 00 00       	mov    $0x70,%eax
f01065aa:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01065ab:	b2 23                	mov    $0x23,%dl
f01065ad:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01065ae:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065b1:	ee                   	out    %al,(%dx)
	}
}
f01065b2:	83 c4 2c             	add    $0x2c,%esp
f01065b5:	5b                   	pop    %ebx
f01065b6:	5e                   	pop    %esi
f01065b7:	5f                   	pop    %edi
f01065b8:	5d                   	pop    %ebp
f01065b9:	c3                   	ret    
	...

f01065bc <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01065bc:	55                   	push   %ebp
f01065bd:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01065bf:	c1 e0 02             	shl    $0x2,%eax
f01065c2:	03 05 04 40 27 f0    	add    0xf0274004,%eax
f01065c8:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01065ca:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f01065cf:	8b 40 20             	mov    0x20(%eax),%eax
}
f01065d2:	5d                   	pop    %ebp
f01065d3:	c3                   	ret    

f01065d4 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01065d4:	55                   	push   %ebp
f01065d5:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065d7:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
		return lapic[ID] >> 24;
	return 0;
f01065dd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f01065e2:	85 d2                	test   %edx,%edx
f01065e4:	74 06                	je     f01065ec <cpunum+0x18>
		return lapic[ID] >> 24;
f01065e6:	8b 42 20             	mov    0x20(%edx),%eax
f01065e9:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01065ec:	5d                   	pop    %ebp
f01065ed:	c3                   	ret    

f01065ee <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01065ee:	55                   	push   %ebp
f01065ef:	89 e5                	mov    %esp,%ebp
f01065f1:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01065f4:	a1 00 40 27 f0       	mov    0xf0274000,%eax
f01065f9:	85 c0                	test   %eax,%eax
f01065fb:	0f 84 1c 01 00 00    	je     f010671d <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106601:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106608:	00 
f0106609:	89 04 24             	mov    %eax,(%esp)
f010660c:	e8 cc ac ff ff       	call   f01012dd <mmio_map_region>
f0106611:	a3 04 40 27 f0       	mov    %eax,0xf0274004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106616:	ba 27 01 00 00       	mov    $0x127,%edx
f010661b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106620:	e8 97 ff ff ff       	call   f01065bc <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106625:	ba 0b 00 00 00       	mov    $0xb,%edx
f010662a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010662f:	e8 88 ff ff ff       	call   f01065bc <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106634:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106639:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010663e:	e8 79 ff ff ff       	call   f01065bc <lapicw>
	lapicw(TICR, 10000000); 
f0106643:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106648:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010664d:	e8 6a ff ff ff       	call   f01065bc <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106652:	e8 7d ff ff ff       	call   f01065d4 <cpunum>
f0106657:	6b c0 74             	imul   $0x74,%eax,%eax
f010665a:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010665f:	39 05 c0 33 23 f0    	cmp    %eax,0xf02333c0
f0106665:	74 0f                	je     f0106676 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106667:	ba 00 00 01 00       	mov    $0x10000,%edx
f010666c:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106671:	e8 46 ff ff ff       	call   f01065bc <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106676:	ba 00 00 01 00       	mov    $0x10000,%edx
f010667b:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106680:	e8 37 ff ff ff       	call   f01065bc <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106685:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f010668a:	8b 40 30             	mov    0x30(%eax),%eax
f010668d:	c1 e8 10             	shr    $0x10,%eax
f0106690:	3c 03                	cmp    $0x3,%al
f0106692:	76 0f                	jbe    f01066a3 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106694:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106699:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010669e:	e8 19 ff ff ff       	call   f01065bc <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01066a3:	ba 33 00 00 00       	mov    $0x33,%edx
f01066a8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01066ad:	e8 0a ff ff ff       	call   f01065bc <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01066b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01066b7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066bc:	e8 fb fe ff ff       	call   f01065bc <lapicw>
	lapicw(ESR, 0);
f01066c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01066c6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066cb:	e8 ec fe ff ff       	call   f01065bc <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01066d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01066d5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01066da:	e8 dd fe ff ff       	call   f01065bc <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01066df:	ba 00 00 00 00       	mov    $0x0,%edx
f01066e4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066e9:	e8 ce fe ff ff       	call   f01065bc <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01066ee:	ba 00 85 08 00       	mov    $0x88500,%edx
f01066f3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066f8:	e8 bf fe ff ff       	call   f01065bc <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01066fd:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f0106703:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106709:	f6 c4 10             	test   $0x10,%ah
f010670c:	75 f5                	jne    f0106703 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010670e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106713:	b8 20 00 00 00       	mov    $0x20,%eax
f0106718:	e8 9f fe ff ff       	call   f01065bc <lapicw>
}
f010671d:	c9                   	leave  
f010671e:	c3                   	ret    

f010671f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010671f:	55                   	push   %ebp
f0106720:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106722:	83 3d 04 40 27 f0 00 	cmpl   $0x0,0xf0274004
f0106729:	74 0f                	je     f010673a <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010672b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106730:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106735:	e8 82 fe ff ff       	call   f01065bc <lapicw>
}
f010673a:	5d                   	pop    %ebp
f010673b:	c3                   	ret    

f010673c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010673c:	55                   	push   %ebp
f010673d:	89 e5                	mov    %esp,%ebp
f010673f:	56                   	push   %esi
f0106740:	53                   	push   %ebx
f0106741:	83 ec 10             	sub    $0x10,%esp
f0106744:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106747:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f010674b:	ba 70 00 00 00       	mov    $0x70,%edx
f0106750:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106755:	ee                   	out    %al,(%dx)
f0106756:	b2 71                	mov    $0x71,%dl
f0106758:	b8 0a 00 00 00       	mov    $0xa,%eax
f010675d:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010675e:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f0106765:	75 24                	jne    f010678b <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106767:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010676e:	00 
f010676f:	c7 44 24 08 48 6d 10 	movl   $0xf0106d48,0x8(%esp)
f0106776:	f0 
f0106777:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010677e:	00 
f010677f:	c7 04 24 dc 87 10 f0 	movl   $0xf01087dc,(%esp)
f0106786:	e8 b5 98 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010678b:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106792:	00 00 
	wrv[1] = addr >> 4;
f0106794:	89 f0                	mov    %esi,%eax
f0106796:	c1 e8 04             	shr    $0x4,%eax
f0106799:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010679f:	c1 e3 18             	shl    $0x18,%ebx
f01067a2:	89 da                	mov    %ebx,%edx
f01067a4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067a9:	e8 0e fe ff ff       	call   f01065bc <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01067ae:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01067b3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067b8:	e8 ff fd ff ff       	call   f01065bc <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01067bd:	ba 00 85 00 00       	mov    $0x8500,%edx
f01067c2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067c7:	e8 f0 fd ff ff       	call   f01065bc <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067cc:	c1 ee 0c             	shr    $0xc,%esi
f01067cf:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067d5:	89 da                	mov    %ebx,%edx
f01067d7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067dc:	e8 db fd ff ff       	call   f01065bc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067e1:	89 f2                	mov    %esi,%edx
f01067e3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067e8:	e8 cf fd ff ff       	call   f01065bc <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067ed:	89 da                	mov    %ebx,%edx
f01067ef:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067f4:	e8 c3 fd ff ff       	call   f01065bc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067f9:	89 f2                	mov    %esi,%edx
f01067fb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106800:	e8 b7 fd ff ff       	call   f01065bc <lapicw>
		microdelay(200);
	}
}
f0106805:	83 c4 10             	add    $0x10,%esp
f0106808:	5b                   	pop    %ebx
f0106809:	5e                   	pop    %esi
f010680a:	5d                   	pop    %ebp
f010680b:	c3                   	ret    

f010680c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010680c:	55                   	push   %ebp
f010680d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010680f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106812:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106818:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010681d:	e8 9a fd ff ff       	call   f01065bc <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106822:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f0106828:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010682e:	f6 c4 10             	test   $0x10,%ah
f0106831:	75 f5                	jne    f0106828 <lapic_ipi+0x1c>
		;
}
f0106833:	5d                   	pop    %ebp
f0106834:	c3                   	ret    
f0106835:	00 00                	add    %al,(%eax)
	...

f0106838 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106838:	55                   	push   %ebp
f0106839:	89 e5                	mov    %esp,%ebp
f010683b:	53                   	push   %ebx
f010683c:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010683f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106844:	83 38 00             	cmpl   $0x0,(%eax)
f0106847:	74 18                	je     f0106861 <holding+0x29>
f0106849:	8b 58 08             	mov    0x8(%eax),%ebx
f010684c:	e8 83 fd ff ff       	call   f01065d4 <cpunum>
f0106851:	6b c0 74             	imul   $0x74,%eax,%eax
f0106854:	05 20 30 23 f0       	add    $0xf0233020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106859:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f010685b:	0f 94 c2             	sete   %dl
f010685e:	0f b6 d2             	movzbl %dl,%edx
}
f0106861:	89 d0                	mov    %edx,%eax
f0106863:	83 c4 04             	add    $0x4,%esp
f0106866:	5b                   	pop    %ebx
f0106867:	5d                   	pop    %ebp
f0106868:	c3                   	ret    

f0106869 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106869:	55                   	push   %ebp
f010686a:	89 e5                	mov    %esp,%ebp
f010686c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010686f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106875:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106878:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010687b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106882:	5d                   	pop    %ebp
f0106883:	c3                   	ret    

f0106884 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106884:	55                   	push   %ebp
f0106885:	89 e5                	mov    %esp,%ebp
f0106887:	53                   	push   %ebx
f0106888:	83 ec 24             	sub    $0x24,%esp
f010688b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010688e:	89 d8                	mov    %ebx,%eax
f0106890:	e8 a3 ff ff ff       	call   f0106838 <holding>
f0106895:	85 c0                	test   %eax,%eax
f0106897:	74 30                	je     f01068c9 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106899:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010689c:	e8 33 fd ff ff       	call   f01065d4 <cpunum>
f01068a1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01068a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01068a9:	c7 44 24 08 ec 87 10 	movl   $0xf01087ec,0x8(%esp)
f01068b0:	f0 
f01068b1:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01068b8:	00 
f01068b9:	c7 04 24 50 88 10 f0 	movl   $0xf0108850,(%esp)
f01068c0:	e8 7b 97 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01068c5:	f3 90                	pause  
f01068c7:	eb 05                	jmp    f01068ce <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01068c9:	ba 01 00 00 00       	mov    $0x1,%edx
f01068ce:	89 d0                	mov    %edx,%eax
f01068d0:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01068d3:	85 c0                	test   %eax,%eax
f01068d5:	75 ee                	jne    f01068c5 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01068d7:	e8 f8 fc ff ff       	call   f01065d4 <cpunum>
f01068dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01068df:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01068e4:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01068e7:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01068ea:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01068ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01068f1:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01068f7:	76 12                	jbe    f010690b <spin_lock+0x87>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068f9:	8b 4a 04             	mov    0x4(%edx),%ecx
f01068fc:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01068ff:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106901:	83 c0 01             	add    $0x1,%eax
f0106904:	83 f8 0a             	cmp    $0xa,%eax
f0106907:	75 e8                	jne    f01068f1 <spin_lock+0x6d>
f0106909:	eb 0f                	jmp    f010691a <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010690b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106912:	83 c0 01             	add    $0x1,%eax
f0106915:	83 f8 09             	cmp    $0x9,%eax
f0106918:	7e f1                	jle    f010690b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010691a:	83 c4 24             	add    $0x24,%esp
f010691d:	5b                   	pop    %ebx
f010691e:	5d                   	pop    %ebp
f010691f:	c3                   	ret    

f0106920 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106920:	55                   	push   %ebp
f0106921:	89 e5                	mov    %esp,%ebp
f0106923:	81 ec 88 00 00 00    	sub    $0x88,%esp
f0106929:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010692c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010692f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106932:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106935:	89 d8                	mov    %ebx,%eax
f0106937:	e8 fc fe ff ff       	call   f0106838 <holding>
f010693c:	85 c0                	test   %eax,%eax
f010693e:	0f 85 d3 00 00 00    	jne    f0106a17 <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106944:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010694b:	00 
f010694c:	8d 43 0c             	lea    0xc(%ebx),%eax
f010694f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106953:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106956:	89 34 24             	mov    %esi,(%esp)
f0106959:	e8 70 f6 ff ff       	call   f0105fce <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010695e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106961:	0f b6 38             	movzbl (%eax),%edi
f0106964:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106967:	e8 68 fc ff ff       	call   f01065d4 <cpunum>
f010696c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106970:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106978:	c7 04 24 18 88 10 f0 	movl   $0xf0108818,(%esp)
f010697f:	e8 ea d5 ff ff       	call   f0103f6e <cprintf>
f0106984:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106986:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106989:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010698c:	89 c7                	mov    %eax,%edi
f010698e:	eb 63                	jmp    f01069f3 <spin_unlock+0xd3>
f0106990:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106994:	89 04 24             	mov    %eax,(%esp)
f0106997:	e8 ea ea ff ff       	call   f0105486 <debuginfo_eip>
f010699c:	85 c0                	test   %eax,%eax
f010699e:	78 39                	js     f01069d9 <spin_unlock+0xb9>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01069a0:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01069a2:	89 c2                	mov    %eax,%edx
f01069a4:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01069a7:	89 54 24 18          	mov    %edx,0x18(%esp)
f01069ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01069ae:	89 54 24 14          	mov    %edx,0x14(%esp)
f01069b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01069b5:	89 54 24 10          	mov    %edx,0x10(%esp)
f01069b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01069bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01069c0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01069c3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01069c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069cb:	c7 04 24 60 88 10 f0 	movl   $0xf0108860,(%esp)
f01069d2:	e8 97 d5 ff ff       	call   f0103f6e <cprintf>
f01069d7:	eb 12                	jmp    f01069eb <spin_unlock+0xcb>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01069d9:	8b 06                	mov    (%esi),%eax
f01069db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069df:	c7 04 24 77 88 10 f0 	movl   $0xf0108877,(%esp)
f01069e6:	e8 83 d5 ff ff       	call   f0103f6e <cprintf>
f01069eb:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01069ee:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f01069f1:	74 08                	je     f01069fb <spin_unlock+0xdb>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01069f3:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01069f5:	8b 03                	mov    (%ebx),%eax
f01069f7:	85 c0                	test   %eax,%eax
f01069f9:	75 95                	jne    f0106990 <spin_unlock+0x70>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01069fb:	c7 44 24 08 7f 88 10 	movl   $0xf010887f,0x8(%esp)
f0106a02:	f0 
f0106a03:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106a0a:	00 
f0106a0b:	c7 04 24 50 88 10 f0 	movl   $0xf0108850,(%esp)
f0106a12:	e8 29 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106a17:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106a1e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106a25:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a2a:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106a2d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106a30:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106a33:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106a36:	89 ec                	mov    %ebp,%esp
f0106a38:	5d                   	pop    %ebp
f0106a39:	c3                   	ret    
f0106a3a:	00 00                	add    %al,(%eax)
f0106a3c:	00 00                	add    %al,(%eax)
	...

f0106a40 <__udivdi3>:
f0106a40:	83 ec 1c             	sub    $0x1c,%esp
f0106a43:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106a47:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0106a4b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106a4f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106a53:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106a57:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106a5b:	85 ff                	test   %edi,%edi
f0106a5d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106a61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a65:	89 cd                	mov    %ecx,%ebp
f0106a67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a6b:	75 33                	jne    f0106aa0 <__udivdi3+0x60>
f0106a6d:	39 f1                	cmp    %esi,%ecx
f0106a6f:	77 57                	ja     f0106ac8 <__udivdi3+0x88>
f0106a71:	85 c9                	test   %ecx,%ecx
f0106a73:	75 0b                	jne    f0106a80 <__udivdi3+0x40>
f0106a75:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a7a:	31 d2                	xor    %edx,%edx
f0106a7c:	f7 f1                	div    %ecx
f0106a7e:	89 c1                	mov    %eax,%ecx
f0106a80:	89 f0                	mov    %esi,%eax
f0106a82:	31 d2                	xor    %edx,%edx
f0106a84:	f7 f1                	div    %ecx
f0106a86:	89 c6                	mov    %eax,%esi
f0106a88:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106a8c:	f7 f1                	div    %ecx
f0106a8e:	89 f2                	mov    %esi,%edx
f0106a90:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106a94:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106a98:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106a9c:	83 c4 1c             	add    $0x1c,%esp
f0106a9f:	c3                   	ret    
f0106aa0:	31 d2                	xor    %edx,%edx
f0106aa2:	31 c0                	xor    %eax,%eax
f0106aa4:	39 f7                	cmp    %esi,%edi
f0106aa6:	77 e8                	ja     f0106a90 <__udivdi3+0x50>
f0106aa8:	0f bd cf             	bsr    %edi,%ecx
f0106aab:	83 f1 1f             	xor    $0x1f,%ecx
f0106aae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106ab2:	75 2c                	jne    f0106ae0 <__udivdi3+0xa0>
f0106ab4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0106ab8:	76 04                	jbe    f0106abe <__udivdi3+0x7e>
f0106aba:	39 f7                	cmp    %esi,%edi
f0106abc:	73 d2                	jae    f0106a90 <__udivdi3+0x50>
f0106abe:	31 d2                	xor    %edx,%edx
f0106ac0:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ac5:	eb c9                	jmp    f0106a90 <__udivdi3+0x50>
f0106ac7:	90                   	nop
f0106ac8:	89 f2                	mov    %esi,%edx
f0106aca:	f7 f1                	div    %ecx
f0106acc:	31 d2                	xor    %edx,%edx
f0106ace:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106ad2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106ad6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106ada:	83 c4 1c             	add    $0x1c,%esp
f0106add:	c3                   	ret    
f0106ade:	66 90                	xchg   %ax,%ax
f0106ae0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106ae5:	b8 20 00 00 00       	mov    $0x20,%eax
f0106aea:	89 ea                	mov    %ebp,%edx
f0106aec:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106af0:	d3 e7                	shl    %cl,%edi
f0106af2:	89 c1                	mov    %eax,%ecx
f0106af4:	d3 ea                	shr    %cl,%edx
f0106af6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106afb:	09 fa                	or     %edi,%edx
f0106afd:	89 f7                	mov    %esi,%edi
f0106aff:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b03:	89 f2                	mov    %esi,%edx
f0106b05:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106b09:	d3 e5                	shl    %cl,%ebp
f0106b0b:	89 c1                	mov    %eax,%ecx
f0106b0d:	d3 ef                	shr    %cl,%edi
f0106b0f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106b14:	d3 e2                	shl    %cl,%edx
f0106b16:	89 c1                	mov    %eax,%ecx
f0106b18:	d3 ee                	shr    %cl,%esi
f0106b1a:	09 d6                	or     %edx,%esi
f0106b1c:	89 fa                	mov    %edi,%edx
f0106b1e:	89 f0                	mov    %esi,%eax
f0106b20:	f7 74 24 0c          	divl   0xc(%esp)
f0106b24:	89 d7                	mov    %edx,%edi
f0106b26:	89 c6                	mov    %eax,%esi
f0106b28:	f7 e5                	mul    %ebp
f0106b2a:	39 d7                	cmp    %edx,%edi
f0106b2c:	72 22                	jb     f0106b50 <__udivdi3+0x110>
f0106b2e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106b32:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106b37:	d3 e5                	shl    %cl,%ebp
f0106b39:	39 c5                	cmp    %eax,%ebp
f0106b3b:	73 04                	jae    f0106b41 <__udivdi3+0x101>
f0106b3d:	39 d7                	cmp    %edx,%edi
f0106b3f:	74 0f                	je     f0106b50 <__udivdi3+0x110>
f0106b41:	89 f0                	mov    %esi,%eax
f0106b43:	31 d2                	xor    %edx,%edx
f0106b45:	e9 46 ff ff ff       	jmp    f0106a90 <__udivdi3+0x50>
f0106b4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b50:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106b53:	31 d2                	xor    %edx,%edx
f0106b55:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106b59:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106b5d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106b61:	83 c4 1c             	add    $0x1c,%esp
f0106b64:	c3                   	ret    
	...

f0106b70 <__umoddi3>:
f0106b70:	83 ec 1c             	sub    $0x1c,%esp
f0106b73:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106b77:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0106b7b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0106b7f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106b83:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106b87:	8b 74 24 24          	mov    0x24(%esp),%esi
f0106b8b:	85 ed                	test   %ebp,%ebp
f0106b8d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106b91:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106b95:	89 cf                	mov    %ecx,%edi
f0106b97:	89 04 24             	mov    %eax,(%esp)
f0106b9a:	89 f2                	mov    %esi,%edx
f0106b9c:	75 1a                	jne    f0106bb8 <__umoddi3+0x48>
f0106b9e:	39 f1                	cmp    %esi,%ecx
f0106ba0:	76 4e                	jbe    f0106bf0 <__umoddi3+0x80>
f0106ba2:	f7 f1                	div    %ecx
f0106ba4:	89 d0                	mov    %edx,%eax
f0106ba6:	31 d2                	xor    %edx,%edx
f0106ba8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106bac:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106bb0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106bb4:	83 c4 1c             	add    $0x1c,%esp
f0106bb7:	c3                   	ret    
f0106bb8:	39 f5                	cmp    %esi,%ebp
f0106bba:	77 54                	ja     f0106c10 <__umoddi3+0xa0>
f0106bbc:	0f bd c5             	bsr    %ebp,%eax
f0106bbf:	83 f0 1f             	xor    $0x1f,%eax
f0106bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bc6:	75 60                	jne    f0106c28 <__umoddi3+0xb8>
f0106bc8:	3b 0c 24             	cmp    (%esp),%ecx
f0106bcb:	0f 87 07 01 00 00    	ja     f0106cd8 <__umoddi3+0x168>
f0106bd1:	89 f2                	mov    %esi,%edx
f0106bd3:	8b 34 24             	mov    (%esp),%esi
f0106bd6:	29 ce                	sub    %ecx,%esi
f0106bd8:	19 ea                	sbb    %ebp,%edx
f0106bda:	89 34 24             	mov    %esi,(%esp)
f0106bdd:	8b 04 24             	mov    (%esp),%eax
f0106be0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106be4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106be8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106bec:	83 c4 1c             	add    $0x1c,%esp
f0106bef:	c3                   	ret    
f0106bf0:	85 c9                	test   %ecx,%ecx
f0106bf2:	75 0b                	jne    f0106bff <__umoddi3+0x8f>
f0106bf4:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bf9:	31 d2                	xor    %edx,%edx
f0106bfb:	f7 f1                	div    %ecx
f0106bfd:	89 c1                	mov    %eax,%ecx
f0106bff:	89 f0                	mov    %esi,%eax
f0106c01:	31 d2                	xor    %edx,%edx
f0106c03:	f7 f1                	div    %ecx
f0106c05:	8b 04 24             	mov    (%esp),%eax
f0106c08:	f7 f1                	div    %ecx
f0106c0a:	eb 98                	jmp    f0106ba4 <__umoddi3+0x34>
f0106c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c10:	89 f2                	mov    %esi,%edx
f0106c12:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106c16:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106c1a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106c1e:	83 c4 1c             	add    $0x1c,%esp
f0106c21:	c3                   	ret    
f0106c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106c28:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c2d:	89 e8                	mov    %ebp,%eax
f0106c2f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106c34:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106c38:	89 fa                	mov    %edi,%edx
f0106c3a:	d3 e0                	shl    %cl,%eax
f0106c3c:	89 e9                	mov    %ebp,%ecx
f0106c3e:	d3 ea                	shr    %cl,%edx
f0106c40:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c45:	09 c2                	or     %eax,%edx
f0106c47:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c4b:	89 14 24             	mov    %edx,(%esp)
f0106c4e:	89 f2                	mov    %esi,%edx
f0106c50:	d3 e7                	shl    %cl,%edi
f0106c52:	89 e9                	mov    %ebp,%ecx
f0106c54:	d3 ea                	shr    %cl,%edx
f0106c56:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c5f:	d3 e6                	shl    %cl,%esi
f0106c61:	89 e9                	mov    %ebp,%ecx
f0106c63:	d3 e8                	shr    %cl,%eax
f0106c65:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c6a:	09 f0                	or     %esi,%eax
f0106c6c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106c70:	f7 34 24             	divl   (%esp)
f0106c73:	d3 e6                	shl    %cl,%esi
f0106c75:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106c79:	89 d6                	mov    %edx,%esi
f0106c7b:	f7 e7                	mul    %edi
f0106c7d:	39 d6                	cmp    %edx,%esi
f0106c7f:	89 c1                	mov    %eax,%ecx
f0106c81:	89 d7                	mov    %edx,%edi
f0106c83:	72 3f                	jb     f0106cc4 <__umoddi3+0x154>
f0106c85:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106c89:	72 35                	jb     f0106cc0 <__umoddi3+0x150>
f0106c8b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c8f:	29 c8                	sub    %ecx,%eax
f0106c91:	19 fe                	sbb    %edi,%esi
f0106c93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106c98:	89 f2                	mov    %esi,%edx
f0106c9a:	d3 e8                	shr    %cl,%eax
f0106c9c:	89 e9                	mov    %ebp,%ecx
f0106c9e:	d3 e2                	shl    %cl,%edx
f0106ca0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106ca5:	09 d0                	or     %edx,%eax
f0106ca7:	89 f2                	mov    %esi,%edx
f0106ca9:	d3 ea                	shr    %cl,%edx
f0106cab:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106caf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106cb3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106cb7:	83 c4 1c             	add    $0x1c,%esp
f0106cba:	c3                   	ret    
f0106cbb:	90                   	nop
f0106cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106cc0:	39 d6                	cmp    %edx,%esi
f0106cc2:	75 c7                	jne    f0106c8b <__umoddi3+0x11b>
f0106cc4:	89 d7                	mov    %edx,%edi
f0106cc6:	89 c1                	mov    %eax,%ecx
f0106cc8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0106ccc:	1b 3c 24             	sbb    (%esp),%edi
f0106ccf:	eb ba                	jmp    f0106c8b <__umoddi3+0x11b>
f0106cd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106cd8:	39 f5                	cmp    %esi,%ebp
f0106cda:	0f 82 f1 fe ff ff    	jb     f0106bd1 <__umoddi3+0x61>
f0106ce0:	e9 f8 fe ff ff       	jmp    f0106bdd <__umoddi3+0x6d>
