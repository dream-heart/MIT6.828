
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
f010005f:	e8 f0 62 00 00       	call   f0106354 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 60 6a 10 f0 	movl   $0xf0106a60,(%esp)
f010007d:	e8 0c 3f 00 00       	call   f0103f8e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 cd 3e 00 00       	call   f0103f5b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 80 7b 10 f0 	movl   $0xf0107b80,(%esp)
f0100095:	e8 f4 3e 00 00       	call   f0103f8e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 33 08 00 00       	call   f01008d9 <monitor>
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
f01000af:	b8 08 e0 26 f0       	mov    $0xf026e008,%eax
f01000b4:	2d c7 bc 22 f0       	sub    $0xf022bcc7,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 c7 bc 22 f0 	movl   $0xf022bcc7,(%esp)
f01000cc:	e8 22 5c 00 00       	call   f0105cf3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 a6 05 00 00       	call   f010067c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 cc 6a 10 f0 	movl   $0xf0106acc,(%esp)
f01000e5:	e8 a4 3e 00 00       	call   f0103f8e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 82 12 00 00       	call   f0101371 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 0b 36 00 00       	call   f01036ff <env_init>
	trap_init();
f01000f4:	e8 87 3f 00 00       	call   f0104080 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 78 5f 00 00       	call   f0106076 <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 69 62 00 00       	call   f010636e <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 b3 3d 00 00       	call   f0103ebd <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	spin_initlock(&kernel_lock);
f010010a:	c7 44 24 04 e7 6a 10 	movl   $0xf0106ae7,0x4(%esp)
f0100111:	f0 
f0100112:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100119:	e8 cb 64 00 00       	call   f01065e9 <__spin_initlock>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011e:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100125:	e8 da 64 00 00       	call   f0106604 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010012a:	83 3d 88 ce 22 f0 07 	cmpl   $0x7,0xf022ce88
f0100131:	77 24                	ja     f0100157 <i386_init+0xaf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100133:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f010013a:	00 
f010013b:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0100142:	f0 
f0100143:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 f4 6a 10 f0 	movl   $0xf0106af4,(%esp)
f0100152:	e8 e9 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100157:	b8 92 5f 10 f0       	mov    $0xf0105f92,%eax
f010015c:	2d 18 5f 10 f0       	sub    $0xf0105f18,%eax
f0100161:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100165:	c7 44 24 04 18 5f 10 	movl   $0xf0105f18,0x4(%esp)
f010016c:	f0 
f010016d:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100174:	e8 d5 5b 00 00       	call   f0105d4e <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100179:	bb 20 d0 22 f0       	mov    $0xf022d020,%ebx
f010017e:	eb 4d                	jmp    f01001cd <i386_init+0x125>
		if (c == cpus + cpunum())  // We've started already.
f0100180:	e8 cf 61 00 00       	call   f0106354 <cpunum>
f0100185:	6b c0 74             	imul   $0x74,%eax,%eax
f0100188:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f010018d:	39 c3                	cmp    %eax,%ebx
f010018f:	74 39                	je     f01001ca <i386_init+0x122>
f0100191:	89 d8                	mov    %ebx,%eax
f0100193:	2d 20 d0 22 f0       	sub    $0xf022d020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100198:	c1 f8 02             	sar    $0x2,%eax
f010019b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001a1:	c1 e0 0f             	shl    $0xf,%eax
f01001a4:	8d 80 00 60 23 f0    	lea    -0xfdca000(%eax),%eax
f01001aa:	a3 84 ce 22 f0       	mov    %eax,0xf022ce84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001af:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001b6:	00 
f01001b7:	0f b6 03             	movzbl (%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 fa 62 00 00       	call   f01064bc <lapic_startap>
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
f01001cd:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f01001d4:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f01001d9:	39 c3                	cmp    %eax,%ebx
f01001db:	72 a3                	jb     f0100180 <i386_init+0xd8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001e4:	00 
f01001e5:	c7 04 24 2c d1 1c f0 	movl   $0xf01cd12c,(%esp)
f01001ec:	e8 21 37 00 00       	call   f0103912 <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f01001f1:	e8 be 49 00 00       	call   f0104bb4 <sched_yield>

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
f01001fc:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100201:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100206:	77 20                	ja     f0100228 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100208:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010020c:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0100213:	f0 
f0100214:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f010021b:	00 
f010021c:	c7 04 24 f4 6a 10 f0 	movl   $0xf0106af4,(%esp)
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
f0100230:	e8 1f 61 00 00       	call   f0106354 <cpunum>
f0100235:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100239:	c7 04 24 00 6b 10 f0 	movl   $0xf0106b00,(%esp)
f0100240:	e8 49 3d 00 00       	call   f0103f8e <cprintf>

	lapic_init();
f0100245:	e8 24 61 00 00       	call   f010636e <lapic_init>
	env_init_percpu();
f010024a:	e8 86 34 00 00       	call   f01036d5 <env_init_percpu>
	trap_init_percpu();
f010024f:	90                   	nop
f0100250:	e8 5b 3d 00 00       	call   f0103fb0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100255:	e8 fa 60 00 00       	call   f0106354 <cpunum>
f010025a:	6b d0 74             	imul   $0x74,%eax,%edx
f010025d:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100263:	b8 01 00 00 00       	mov    $0x1,%eax
f0100268:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010026c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100273:	e8 8c 63 00 00       	call   f0106604 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100278:	e8 37 49 00 00       	call   f0104bb4 <sched_yield>

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
f0100295:	c7 04 24 16 6b 10 f0 	movl   $0xf0106b16,(%esp)
f010029c:	e8 ed 3c 00 00       	call   f0103f8e <cprintf>
	vcprintf(fmt, ap);
f01002a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a5:	8b 45 10             	mov    0x10(%ebp),%eax
f01002a8:	89 04 24             	mov    %eax,(%esp)
f01002ab:	e8 ab 3c 00 00       	call   f0103f5b <vcprintf>
	cprintf("\n");
f01002b0:	c7 04 24 80 7b 10 f0 	movl   $0xf0107b80,(%esp)
f01002b7:	e8 d2 3c 00 00       	call   f0103f8e <cprintf>
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

f01002d0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002dc:	5d                   	pop    %ebp
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002de:	55                   	push   %ebp
f01002df:	89 e5                	mov    %esp,%ebp
f01002e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002e7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002ec:	a8 01                	test   $0x1,%al
f01002ee:	74 06                	je     f01002f6 <serial_proc_data+0x18>
f01002f0:	b2 f8                	mov    $0xf8,%dl
f01002f2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f3:	0f b6 c8             	movzbl %al,%ecx
}
f01002f6:	89 c8                	mov    %ecx,%eax
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	53                   	push   %ebx
f01002fe:	83 ec 04             	sub    $0x4,%esp
f0100301:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	eb 25                	jmp    f010032a <cons_intr+0x30>
		if (c == 0)
f0100305:	85 c0                	test   %eax,%eax
f0100307:	74 21                	je     f010032a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	8b 15 24 c2 22 f0    	mov    0xf022c224,%edx
f010030f:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
f0100315:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100318:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010031d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100322:	0f 44 c2             	cmove  %edx,%eax
f0100325:	a3 24 c2 22 f0       	mov    %eax,0xf022c224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010032a:	ff d3                	call   *%ebx
f010032c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010032f:	75 d4                	jne    f0100305 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100331:	83 c4 04             	add    $0x4,%esp
f0100334:	5b                   	pop    %ebx
f0100335:	5d                   	pop    %ebp
f0100336:	c3                   	ret    

f0100337 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	57                   	push   %edi
f010033b:	56                   	push   %esi
f010033c:	53                   	push   %ebx
f010033d:	83 ec 2c             	sub    $0x2c,%esp
f0100340:	89 c7                	mov    %eax,%edi
f0100342:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100347:	be fd 03 00 00       	mov    $0x3fd,%esi
f010034c:	eb 05                	jmp    f0100353 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010034e:	e8 7d ff ff ff       	call   f01002d0 <delay>
f0100353:	89 f2                	mov    %esi,%edx
f0100355:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100356:	a8 20                	test   $0x20,%al
f0100358:	75 05                	jne    f010035f <cons_putc+0x28>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010035a:	83 eb 01             	sub    $0x1,%ebx
f010035d:	75 ef                	jne    f010034e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010035f:	89 fa                	mov    %edi,%edx
f0100361:	89 f8                	mov    %edi,%eax
f0100363:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100366:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010036b:	ee                   	out    %al,(%dx)
f010036c:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100371:	be 79 03 00 00       	mov    $0x379,%esi
f0100376:	eb 05                	jmp    f010037d <cons_putc+0x46>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100378:	e8 53 ff ff ff       	call   f01002d0 <delay>
f010037d:	89 f2                	mov    %esi,%edx
f010037f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100380:	84 c0                	test   %al,%al
f0100382:	78 05                	js     f0100389 <cons_putc+0x52>
f0100384:	83 eb 01             	sub    $0x1,%ebx
f0100387:	75 ef                	jne    f0100378 <cons_putc+0x41>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100389:	ba 78 03 00 00       	mov    $0x378,%edx
f010038e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b2 7a                	mov    $0x7a,%dl
f0100395:	b8 0d 00 00 00       	mov    $0xd,%eax
f010039a:	ee                   	out    %al,(%dx)
f010039b:	b8 08 00 00 00       	mov    $0x8,%eax
f01003a0:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003a1:	89 fa                	mov    %edi,%edx
f01003a3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a9:	89 f8                	mov    %edi,%eax
f01003ab:	80 cc 07             	or     $0x7,%ah
f01003ae:	85 d2                	test   %edx,%edx
f01003b0:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003b3:	89 f8                	mov    %edi,%eax
f01003b5:	25 ff 00 00 00       	and    $0xff,%eax
f01003ba:	83 f8 09             	cmp    $0x9,%eax
f01003bd:	74 79                	je     f0100438 <cons_putc+0x101>
f01003bf:	83 f8 09             	cmp    $0x9,%eax
f01003c2:	7f 0e                	jg     f01003d2 <cons_putc+0x9b>
f01003c4:	83 f8 08             	cmp    $0x8,%eax
f01003c7:	0f 85 9f 00 00 00    	jne    f010046c <cons_putc+0x135>
f01003cd:	8d 76 00             	lea    0x0(%esi),%esi
f01003d0:	eb 10                	jmp    f01003e2 <cons_putc+0xab>
f01003d2:	83 f8 0a             	cmp    $0xa,%eax
f01003d5:	74 3b                	je     f0100412 <cons_putc+0xdb>
f01003d7:	83 f8 0d             	cmp    $0xd,%eax
f01003da:	0f 85 8c 00 00 00    	jne    f010046c <cons_putc+0x135>
f01003e0:	eb 38                	jmp    f010041a <cons_putc+0xe3>
	case '\b':
		if (crt_pos > 0) {
f01003e2:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f01003e9:	66 85 c0             	test   %ax,%ax
f01003ec:	0f 84 e4 00 00 00    	je     f01004d6 <cons_putc+0x19f>
			crt_pos--;
f01003f2:	83 e8 01             	sub    $0x1,%eax
f01003f5:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003fb:	0f b7 c0             	movzwl %ax,%eax
f01003fe:	66 81 e7 00 ff       	and    $0xff00,%di
f0100403:	83 cf 20             	or     $0x20,%edi
f0100406:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
f010040c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100410:	eb 77                	jmp    f0100489 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100412:	66 83 05 34 c2 22 f0 	addw   $0x50,0xf022c234
f0100419:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010041a:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f0100421:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100427:	c1 e8 16             	shr    $0x16,%eax
f010042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010042d:	c1 e0 04             	shl    $0x4,%eax
f0100430:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
f0100436:	eb 51                	jmp    f0100489 <cons_putc+0x152>
		break;
	case '\t':
		cons_putc(' ');
f0100438:	b8 20 00 00 00       	mov    $0x20,%eax
f010043d:	e8 f5 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100442:	b8 20 00 00 00       	mov    $0x20,%eax
f0100447:	e8 eb fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010044c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100451:	e8 e1 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100456:	b8 20 00 00 00       	mov    $0x20,%eax
f010045b:	e8 d7 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100460:	b8 20 00 00 00       	mov    $0x20,%eax
f0100465:	e8 cd fe ff ff       	call   f0100337 <cons_putc>
f010046a:	eb 1d                	jmp    f0100489 <cons_putc+0x152>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010046c:	0f b7 05 34 c2 22 f0 	movzwl 0xf022c234,%eax
f0100473:	0f b7 c8             	movzwl %ax,%ecx
f0100476:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
f010047c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100480:	83 c0 01             	add    $0x1,%eax
f0100483:	66 a3 34 c2 22 f0    	mov    %ax,0xf022c234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100489:	66 81 3d 34 c2 22 f0 	cmpw   $0x7cf,0xf022c234
f0100490:	cf 07 
f0100492:	76 42                	jbe    f01004d6 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100494:	a1 30 c2 22 f0       	mov    0xf022c230,%eax
f0100499:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004a0:	00 
f01004a1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004a7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004ab:	89 04 24             	mov    %eax,(%esp)
f01004ae:	e8 9b 58 00 00       	call   f0105d4e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b3:	8b 15 30 c2 22 f0    	mov    0xf022c230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b9:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004be:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c4:	83 c0 01             	add    $0x1,%eax
f01004c7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004cc:	75 f0                	jne    f01004be <cons_putc+0x187>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ce:	66 83 2d 34 c2 22 f0 	subw   $0x50,0xf022c234
f01004d5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004d6:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
f01004dc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004e1:	89 ca                	mov    %ecx,%edx
f01004e3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e4:	0f b7 35 34 c2 22 f0 	movzwl 0xf022c234,%esi
f01004eb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ee:	89 f0                	mov    %esi,%eax
f01004f0:	66 c1 e8 08          	shr    $0x8,%ax
f01004f4:	89 da                	mov    %ebx,%edx
f01004f6:	ee                   	out    %al,(%dx)
f01004f7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004fc:	89 ca                	mov    %ecx,%edx
f01004fe:	ee                   	out    %al,(%dx)
f01004ff:	89 f0                	mov    %esi,%eax
f0100501:	89 da                	mov    %ebx,%edx
f0100503:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100504:	83 c4 2c             	add    $0x2c,%esp
f0100507:	5b                   	pop    %ebx
f0100508:	5e                   	pop    %esi
f0100509:	5f                   	pop    %edi
f010050a:	5d                   	pop    %ebp
f010050b:	c3                   	ret    

f010050c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010050c:	55                   	push   %ebp
f010050d:	89 e5                	mov    %esp,%ebp
f010050f:	53                   	push   %ebx
f0100510:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100513:	ba 64 00 00 00       	mov    $0x64,%edx
f0100518:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100519:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010051e:	a8 01                	test   $0x1,%al
f0100520:	0f 84 de 00 00 00    	je     f0100604 <kbd_proc_data+0xf8>
f0100526:	b2 60                	mov    $0x60,%dl
f0100528:	ec                   	in     (%dx),%al
f0100529:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010052b:	3c e0                	cmp    $0xe0,%al
f010052d:	75 11                	jne    f0100540 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010052f:	83 0d 28 c2 22 f0 40 	orl    $0x40,0xf022c228
		return 0;
f0100536:	bb 00 00 00 00       	mov    $0x0,%ebx
f010053b:	e9 c4 00 00 00       	jmp    f0100604 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100540:	84 c0                	test   %al,%al
f0100542:	79 37                	jns    f010057b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100544:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f010054a:	89 cb                	mov    %ecx,%ebx
f010054c:	83 e3 40             	and    $0x40,%ebx
f010054f:	83 e0 7f             	and    $0x7f,%eax
f0100552:	85 db                	test   %ebx,%ebx
f0100554:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100557:	0f b6 d2             	movzbl %dl,%edx
f010055a:	0f b6 82 60 6b 10 f0 	movzbl -0xfef94a0(%edx),%eax
f0100561:	83 c8 40             	or     $0x40,%eax
f0100564:	0f b6 c0             	movzbl %al,%eax
f0100567:	f7 d0                	not    %eax
f0100569:	21 c1                	and    %eax,%ecx
f010056b:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
		return 0;
f0100571:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100576:	e9 89 00 00 00       	jmp    f0100604 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010057b:	8b 0d 28 c2 22 f0    	mov    0xf022c228,%ecx
f0100581:	f6 c1 40             	test   $0x40,%cl
f0100584:	74 0e                	je     f0100594 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100586:	89 c2                	mov    %eax,%edx
f0100588:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010058b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010058e:	89 0d 28 c2 22 f0    	mov    %ecx,0xf022c228
	}

	shift |= shiftcode[data];
f0100594:	0f b6 d2             	movzbl %dl,%edx
f0100597:	0f b6 82 60 6b 10 f0 	movzbl -0xfef94a0(%edx),%eax
f010059e:	0b 05 28 c2 22 f0    	or     0xf022c228,%eax
	shift ^= togglecode[data];
f01005a4:	0f b6 8a 60 6c 10 f0 	movzbl -0xfef93a0(%edx),%ecx
f01005ab:	31 c8                	xor    %ecx,%eax
f01005ad:	a3 28 c2 22 f0       	mov    %eax,0xf022c228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005b2:	89 c1                	mov    %eax,%ecx
f01005b4:	83 e1 03             	and    $0x3,%ecx
f01005b7:	8b 0c 8d 60 6d 10 f0 	mov    -0xfef92a0(,%ecx,4),%ecx
f01005be:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005c2:	a8 08                	test   $0x8,%al
f01005c4:	74 19                	je     f01005df <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005c6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005c9:	83 fa 19             	cmp    $0x19,%edx
f01005cc:	77 05                	ja     f01005d3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005ce:	83 eb 20             	sub    $0x20,%ebx
f01005d1:	eb 0c                	jmp    f01005df <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005d3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01005d6:	8d 53 20             	lea    0x20(%ebx),%edx
f01005d9:	83 f9 19             	cmp    $0x19,%ecx
f01005dc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005df:	f7 d0                	not    %eax
f01005e1:	a8 06                	test   $0x6,%al
f01005e3:	75 1f                	jne    f0100604 <kbd_proc_data+0xf8>
f01005e5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005eb:	75 17                	jne    f0100604 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01005ed:	c7 04 24 30 6b 10 f0 	movl   $0xf0106b30,(%esp)
f01005f4:	e8 95 39 00 00       	call   f0103f8e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f9:	ba 92 00 00 00       	mov    $0x92,%edx
f01005fe:	b8 03 00 00 00       	mov    $0x3,%eax
f0100603:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100604:	89 d8                	mov    %ebx,%eax
f0100606:	83 c4 14             	add    $0x14,%esp
f0100609:	5b                   	pop    %ebx
f010060a:	5d                   	pop    %ebp
f010060b:	c3                   	ret    

f010060c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010060c:	55                   	push   %ebp
f010060d:	89 e5                	mov    %esp,%ebp
f010060f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100612:	80 3d 00 c0 22 f0 00 	cmpb   $0x0,0xf022c000
f0100619:	74 0a                	je     f0100625 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010061b:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f0100620:	e8 d5 fc ff ff       	call   f01002fa <cons_intr>
}
f0100625:	c9                   	leave  
f0100626:	c3                   	ret    

f0100627 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100627:	55                   	push   %ebp
f0100628:	89 e5                	mov    %esp,%ebp
f010062a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010062d:	b8 0c 05 10 f0       	mov    $0xf010050c,%eax
f0100632:	e8 c3 fc ff ff       	call   f01002fa <cons_intr>
}
f0100637:	c9                   	leave  
f0100638:	c3                   	ret    

f0100639 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010063f:	e8 c8 ff ff ff       	call   f010060c <serial_intr>
	kbd_intr();
f0100644:	e8 de ff ff ff       	call   f0100627 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100649:	8b 15 20 c2 22 f0    	mov    0xf022c220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010064f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100654:	3b 15 24 c2 22 f0    	cmp    0xf022c224,%edx
f010065a:	74 1e                	je     f010067a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010065c:	0f b6 82 20 c0 22 f0 	movzbl -0xfdd3fe0(%edx),%eax
f0100663:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100666:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010066c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100671:	0f 44 d1             	cmove  %ecx,%edx
f0100674:	89 15 20 c2 22 f0    	mov    %edx,0xf022c220
		return c;
	}
	return 0;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
f010067f:	57                   	push   %edi
f0100680:	56                   	push   %esi
f0100681:	53                   	push   %ebx
f0100682:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100685:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010068c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100693:	5a a5 
	if (*cp != 0xA55A) {
f0100695:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010069c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a0:	74 11                	je     f01006b3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006a2:	c7 05 2c c2 22 f0 b4 	movl   $0x3b4,0xf022c22c
f01006a9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ac:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006b1:	eb 16                	jmp    f01006c9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006b3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ba:	c7 05 2c c2 22 f0 d4 	movl   $0x3d4,0xf022c22c
f01006c1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c9:	8b 0d 2c c2 22 f0    	mov    0xf022c22c,%ecx
f01006cf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006d4:	89 ca                	mov    %ecx,%edx
f01006d6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006d7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ec                   	in     (%dx),%al
f01006dd:	0f b6 f8             	movzbl %al,%edi
f01006e0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006e8:	89 ca                	mov    %ecx,%edx
f01006ea:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006eb:	89 da                	mov    %ebx,%edx
f01006ed:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ee:	89 35 30 c2 22 f0    	mov    %esi,0xf022c230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006f4:	0f b6 d8             	movzbl %al,%ebx
f01006f7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006f9:	66 89 3d 34 c2 22 f0 	mov    %di,0xf022c234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100700:	e8 22 ff ff ff       	call   f0100627 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100705:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010070c:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100711:	89 04 24             	mov    %eax,(%esp)
f0100714:	e8 33 37 00 00       	call   f0103e4c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100719:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	89 da                	mov    %ebx,%edx
f0100725:	ee                   	out    %al,(%dx)
f0100726:	b2 fb                	mov    $0xfb,%dl
f0100728:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010072d:	ee                   	out    %al,(%dx)
f010072e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100733:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100738:	89 ca                	mov    %ecx,%edx
f010073a:	ee                   	out    %al,(%dx)
f010073b:	b2 f9                	mov    $0xf9,%dl
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	b2 fb                	mov    $0xfb,%dl
f0100745:	b8 03 00 00 00       	mov    $0x3,%eax
f010074a:	ee                   	out    %al,(%dx)
f010074b:	b2 fc                	mov    $0xfc,%dl
f010074d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100752:	ee                   	out    %al,(%dx)
f0100753:	b2 f9                	mov    $0xf9,%dl
f0100755:	b8 01 00 00 00       	mov    $0x1,%eax
f010075a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075b:	b2 fd                	mov    $0xfd,%dl
f010075d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010075e:	3c ff                	cmp    $0xff,%al
f0100760:	0f 95 c0             	setne  %al
f0100763:	89 c6                	mov    %eax,%esi
f0100765:	a2 00 c0 22 f0       	mov    %al,0xf022c000
f010076a:	89 da                	mov    %ebx,%edx
f010076c:	ec                   	in     (%dx),%al
f010076d:	89 ca                	mov    %ecx,%edx
f010076f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100770:	89 f0                	mov    %esi,%eax
f0100772:	84 c0                	test   %al,%al
f0100774:	75 0c                	jne    f0100782 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f0100776:	c7 04 24 3c 6b 10 f0 	movl   $0xf0106b3c,(%esp)
f010077d:	e8 0c 38 00 00       	call   f0103f8e <cprintf>
}
f0100782:	83 c4 1c             	add    $0x1c,%esp
f0100785:	5b                   	pop    %ebx
f0100786:	5e                   	pop    %esi
f0100787:	5f                   	pop    %edi
f0100788:	5d                   	pop    %ebp
f0100789:	c3                   	ret    

f010078a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100790:	8b 45 08             	mov    0x8(%ebp),%eax
f0100793:	e8 9f fb ff ff       	call   f0100337 <cons_putc>
}
f0100798:	c9                   	leave  
f0100799:	c3                   	ret    

f010079a <getchar>:

int
getchar(void)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a0:	e8 94 fe ff ff       	call   f0100639 <cons_getc>
f01007a5:	85 c0                	test   %eax,%eax
f01007a7:	74 f7                	je     f01007a0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <iscons>:

int
iscons(int fdnum)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b3:	5d                   	pop    %ebp
f01007b4:	c3                   	ret    
f01007b5:	66 90                	xchg   %ax,%ax
f01007b7:	66 90                	xchg   %ax,%ax
f01007b9:	66 90                	xchg   %ax,%ax
f01007bb:	66 90                	xchg   %ax,%ax
f01007bd:	66 90                	xchg   %ax,%ax
f01007bf:	90                   	nop

f01007c0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	c7 04 24 70 6d 10 f0 	movl   $0xf0106d70,(%esp)
f01007cd:	e8 bc 37 00 00       	call   f0103f8e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007d9:	00 
f01007da:	c7 04 24 fc 6d 10 f0 	movl   $0xf0106dfc,(%esp)
f01007e1:	e8 a8 37 00 00       	call   f0103f8e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007ed:	00 
f01007ee:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007f5:	f0 
f01007f6:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f01007fd:	e8 8c 37 00 00       	call   f0103f8e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100802:	c7 44 24 08 47 6a 10 	movl   $0x106a47,0x8(%esp)
f0100809:	00 
f010080a:	c7 44 24 04 47 6a 10 	movl   $0xf0106a47,0x4(%esp)
f0100811:	f0 
f0100812:	c7 04 24 48 6e 10 f0 	movl   $0xf0106e48,(%esp)
f0100819:	e8 70 37 00 00       	call   f0103f8e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081e:	c7 44 24 08 c7 bc 22 	movl   $0x22bcc7,0x8(%esp)
f0100825:	00 
f0100826:	c7 44 24 04 c7 bc 22 	movl   $0xf022bcc7,0x4(%esp)
f010082d:	f0 
f010082e:	c7 04 24 6c 6e 10 f0 	movl   $0xf0106e6c,(%esp)
f0100835:	e8 54 37 00 00       	call   f0103f8e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083a:	c7 44 24 08 08 e0 26 	movl   $0x26e008,0x8(%esp)
f0100841:	00 
f0100842:	c7 44 24 04 08 e0 26 	movl   $0xf026e008,0x4(%esp)
f0100849:	f0 
f010084a:	c7 04 24 90 6e 10 f0 	movl   $0xf0106e90,(%esp)
f0100851:	e8 38 37 00 00       	call   f0103f8e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100856:	b8 07 e4 26 f0       	mov    $0xf026e407,%eax
f010085b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100860:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100865:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010086b:	85 c0                	test   %eax,%eax
f010086d:	0f 48 c2             	cmovs  %edx,%eax
f0100870:	c1 f8 0a             	sar    $0xa,%eax
f0100873:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100877:	c7 04 24 b4 6e 10 f0 	movl   $0xf0106eb4,(%esp)
f010087e:	e8 0b 37 00 00       	call   f0103f8e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100883:	b8 00 00 00 00       	mov    $0x0,%eax
f0100888:	c9                   	leave  
f0100889:	c3                   	ret    

f010088a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010088a:	55                   	push   %ebp
f010088b:	89 e5                	mov    %esp,%ebp
f010088d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100890:	c7 44 24 08 89 6d 10 	movl   $0xf0106d89,0x8(%esp)
f0100897:	f0 
f0100898:	c7 44 24 04 a7 6d 10 	movl   $0xf0106da7,0x4(%esp)
f010089f:	f0 
f01008a0:	c7 04 24 ac 6d 10 f0 	movl   $0xf0106dac,(%esp)
f01008a7:	e8 e2 36 00 00       	call   f0103f8e <cprintf>
f01008ac:	c7 44 24 08 e0 6e 10 	movl   $0xf0106ee0,0x8(%esp)
f01008b3:	f0 
f01008b4:	c7 44 24 04 b5 6d 10 	movl   $0xf0106db5,0x4(%esp)
f01008bb:	f0 
f01008bc:	c7 04 24 ac 6d 10 f0 	movl   $0xf0106dac,(%esp)
f01008c3:	e8 c6 36 00 00       	call   f0103f8e <cprintf>
	return 0;
}
f01008c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008cd:	c9                   	leave  
f01008ce:	c3                   	ret    

f01008cf <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008cf:	55                   	push   %ebp
f01008d0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d7:	5d                   	pop    %ebp
f01008d8:	c3                   	ret    

f01008d9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d9:	55                   	push   %ebp
f01008da:	89 e5                	mov    %esp,%ebp
f01008dc:	57                   	push   %edi
f01008dd:	56                   	push   %esi
f01008de:	53                   	push   %ebx
f01008df:	83 ec 5c             	sub    $0x5c,%esp
f01008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008e5:	c7 04 24 08 6f 10 f0 	movl   $0xf0106f08,(%esp)
f01008ec:	e8 9d 36 00 00       	call   f0103f8e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008f1:	c7 04 24 2c 6f 10 f0 	movl   $0xf0106f2c,(%esp)
f01008f8:	e8 91 36 00 00       	call   f0103f8e <cprintf>

	if (tf != NULL)
f01008fd:	85 ff                	test   %edi,%edi
f01008ff:	74 08                	je     f0100909 <monitor+0x30>
		print_trapframe(tf);
f0100901:	89 3c 24             	mov    %edi,(%esp)
f0100904:	e8 b2 3b 00 00       	call   f01044bb <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100909:	c7 04 24 be 6d 10 f0 	movl   $0xf0106dbe,(%esp)
f0100910:	e8 8b 51 00 00       	call   f0105aa0 <readline>
f0100915:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100917:	85 c0                	test   %eax,%eax
f0100919:	74 ee                	je     f0100909 <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010091b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100922:	be 00 00 00 00       	mov    $0x0,%esi
f0100927:	eb 06                	jmp    f010092f <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100929:	c6 03 00             	movb   $0x0,(%ebx)
f010092c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010092f:	0f b6 03             	movzbl (%ebx),%eax
f0100932:	84 c0                	test   %al,%al
f0100934:	74 63                	je     f0100999 <monitor+0xc0>
f0100936:	0f be c0             	movsbl %al,%eax
f0100939:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093d:	c7 04 24 c2 6d 10 f0 	movl   $0xf0106dc2,(%esp)
f0100944:	e8 6d 53 00 00       	call   f0105cb6 <strchr>
f0100949:	85 c0                	test   %eax,%eax
f010094b:	75 dc                	jne    f0100929 <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f010094d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100950:	74 47                	je     f0100999 <monitor+0xc0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100952:	83 fe 0f             	cmp    $0xf,%esi
f0100955:	75 16                	jne    f010096d <monitor+0x94>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100957:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010095e:	00 
f010095f:	c7 04 24 c7 6d 10 f0 	movl   $0xf0106dc7,(%esp)
f0100966:	e8 23 36 00 00       	call   f0103f8e <cprintf>
f010096b:	eb 9c                	jmp    f0100909 <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f010096d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100971:	83 c6 01             	add    $0x1,%esi
f0100974:	eb 03                	jmp    f0100979 <monitor+0xa0>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100976:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100979:	0f b6 03             	movzbl (%ebx),%eax
f010097c:	84 c0                	test   %al,%al
f010097e:	74 af                	je     f010092f <monitor+0x56>
f0100980:	0f be c0             	movsbl %al,%eax
f0100983:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100987:	c7 04 24 c2 6d 10 f0 	movl   $0xf0106dc2,(%esp)
f010098e:	e8 23 53 00 00       	call   f0105cb6 <strchr>
f0100993:	85 c0                	test   %eax,%eax
f0100995:	74 df                	je     f0100976 <monitor+0x9d>
f0100997:	eb 96                	jmp    f010092f <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100999:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009a0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009a1:	85 f6                	test   %esi,%esi
f01009a3:	0f 84 60 ff ff ff    	je     f0100909 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009a9:	c7 44 24 04 a7 6d 10 	movl   $0xf0106da7,0x4(%esp)
f01009b0:	f0 
f01009b1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b4:	89 04 24             	mov    %eax,(%esp)
f01009b7:	e8 9b 52 00 00       	call   f0105c57 <strcmp>
f01009bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01009c1:	85 c0                	test   %eax,%eax
f01009c3:	74 1c                	je     f01009e1 <monitor+0x108>
f01009c5:	c7 44 24 04 b5 6d 10 	movl   $0xf0106db5,0x4(%esp)
f01009cc:	f0 
f01009cd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009d0:	89 04 24             	mov    %eax,(%esp)
f01009d3:	e8 7f 52 00 00       	call   f0105c57 <strcmp>
f01009d8:	85 c0                	test   %eax,%eax
f01009da:	75 28                	jne    f0100a04 <monitor+0x12b>
f01009dc:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01009e1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01009e4:	01 c2                	add    %eax,%edx
f01009e6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009ea:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f1:	89 34 24             	mov    %esi,(%esp)
f01009f4:	ff 14 95 5c 6f 10 f0 	call   *-0xfef90a4(,%edx,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009fb:	85 c0                	test   %eax,%eax
f01009fd:	78 1d                	js     f0100a1c <monitor+0x143>
f01009ff:	e9 05 ff ff ff       	jmp    f0100909 <monitor+0x30>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a04:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0b:	c7 04 24 e4 6d 10 f0 	movl   $0xf0106de4,(%esp)
f0100a12:	e8 77 35 00 00       	call   f0103f8e <cprintf>
f0100a17:	e9 ed fe ff ff       	jmp    f0100909 <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a1c:	83 c4 5c             	add    $0x5c,%esp
f0100a1f:	5b                   	pop    %ebx
f0100a20:	5e                   	pop    %esi
f0100a21:	5f                   	pop    %edi
f0100a22:	5d                   	pop    %ebp
f0100a23:	c3                   	ret    

f0100a24 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a24:	55                   	push   %ebp
f0100a25:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a27:	83 3d 3c c2 22 f0 00 	cmpl   $0x0,0xf022c23c
f0100a2e:	75 11                	jne    f0100a41 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a30:	ba 07 f0 26 f0       	mov    $0xf026f007,%edx
f0100a35:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a3b:	89 15 3c c2 22 f0    	mov    %edx,0xf022c23c
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
		return nextfree;
f0100a41:	8b 15 3c c2 22 f0    	mov    0xf022c23c,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	74 17                	je     f0100a62 <boot_alloc+0x3e>
		return nextfree;
	result = nextfree;
f0100a4b:	8b 15 3c c2 22 f0    	mov    0xf022c23c,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a51:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a5d:	a3 3c c2 22 f0       	mov    %eax,0xf022c23c
	
	// return the head address of the alloc pages;
	return result;
}
f0100a62:	89 d0                	mov    %edx,%eax
f0100a64:	5d                   	pop    %ebp
f0100a65:	c3                   	ret    

f0100a66 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a66:	55                   	push   %ebp
f0100a67:	89 e5                	mov    %esp,%ebp
f0100a69:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a6c:	89 d1                	mov    %edx,%ecx
f0100a6e:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a71:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a79:	f6 c1 01             	test   $0x1,%cl
f0100a7c:	74 57                	je     f0100ad5 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a7e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a84:	89 c8                	mov    %ecx,%eax
f0100a86:	c1 e8 0c             	shr    $0xc,%eax
f0100a89:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0100a8f:	72 20                	jb     f0100ab1 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a91:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a95:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0100a9c:	f0 
f0100a9d:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0100aa4:	00 
f0100aa5:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100aac:	e8 8f f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100ab1:	c1 ea 0c             	shr    $0xc,%edx
f0100ab4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100aba:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100ac1:	89 c2                	mov    %eax,%edx
f0100ac3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100acb:	85 d2                	test   %edx,%edx
f0100acd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ad2:	0f 44 c2             	cmove  %edx,%eax
}
f0100ad5:	c9                   	leave  
f0100ad6:	c3                   	ret    

f0100ad7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ad7:	55                   	push   %ebp
f0100ad8:	89 e5                	mov    %esp,%ebp
f0100ada:	83 ec 18             	sub    $0x18,%esp
f0100add:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ae0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ae3:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ae5:	89 04 24             	mov    %eax,(%esp)
f0100ae8:	e8 37 33 00 00       	call   f0103e24 <mc146818_read>
f0100aed:	89 c6                	mov    %eax,%esi
f0100aef:	83 c3 01             	add    $0x1,%ebx
f0100af2:	89 1c 24             	mov    %ebx,(%esp)
f0100af5:	e8 2a 33 00 00       	call   f0103e24 <mc146818_read>
f0100afa:	c1 e0 08             	shl    $0x8,%eax
f0100afd:	09 f0                	or     %esi,%eax
}
f0100aff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b02:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b05:	89 ec                	mov    %ebp,%esp
f0100b07:	5d                   	pop    %ebp
f0100b08:	c3                   	ret    

f0100b09 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b09:	55                   	push   %ebp
f0100b0a:	89 e5                	mov    %esp,%ebp
f0100b0c:	57                   	push   %edi
f0100b0d:	56                   	push   %esi
f0100b0e:	53                   	push   %ebx
f0100b0f:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b12:	3c 01                	cmp    $0x1,%al
f0100b14:	19 f6                	sbb    %esi,%esi
f0100b16:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b1c:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b1f:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100b25:	85 d2                	test   %edx,%edx
f0100b27:	75 1c                	jne    f0100b45 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100b29:	c7 44 24 08 6c 6f 10 	movl   $0xf0106f6c,0x8(%esp)
f0100b30:	f0 
f0100b31:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100b38:	00 
f0100b39:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100b40:	e8 fb f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100b45:	84 c0                	test   %al,%al
f0100b47:	74 4b                	je     f0100b94 <check_page_free_list+0x8b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b49:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b52:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b55:	89 d0                	mov    %edx,%eax
f0100b57:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100b5d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b60:	c1 e8 16             	shr    $0x16,%eax
f0100b63:	39 c6                	cmp    %eax,%esi
f0100b65:	0f 96 c0             	setbe  %al
f0100b68:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b6b:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100b6f:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b71:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b75:	8b 12                	mov    (%edx),%edx
f0100b77:	85 d2                	test   %edx,%edx
f0100b79:	75 da                	jne    f0100b55 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b84:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b8a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b8f:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b94:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f0100b9a:	eb 63                	jmp    f0100bff <check_page_free_list+0xf6>
f0100b9c:	89 d8                	mov    %ebx,%eax
f0100b9e:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100ba4:	c1 f8 03             	sar    $0x3,%eax
f0100ba7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100baa:	89 c2                	mov    %eax,%edx
f0100bac:	c1 ea 16             	shr    $0x16,%edx
f0100baf:	39 d6                	cmp    %edx,%esi
f0100bb1:	76 4a                	jbe    f0100bfd <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb3:	89 c2                	mov    %eax,%edx
f0100bb5:	c1 ea 0c             	shr    $0xc,%edx
f0100bb8:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0100bbe:	72 20                	jb     f0100be0 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bc4:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0100bcb:	f0 
f0100bcc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bd3:	00 
f0100bd4:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0100bdb:	e8 60 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100be0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100be7:	00 
f0100be8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100bef:	00 
	return (void *)(pa + KERNBASE);
f0100bf0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bf5:	89 04 24             	mov    %eax,(%esp)
f0100bf8:	e8 f6 50 00 00       	call   f0105cf3 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfd:	8b 1b                	mov    (%ebx),%ebx
f0100bff:	85 db                	test   %ebx,%ebx
f0100c01:	75 99                	jne    f0100b9c <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c08:	e8 17 fe ff ff       	call   f0100a24 <boot_alloc>
f0100c0d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c10:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c16:	8b 0d 90 ce 22 f0    	mov    0xf022ce90,%ecx
		assert(pp < pages + npages);
f0100c1c:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f0100c21:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c24:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c27:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c2a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c2d:	be 00 00 00 00       	mov    $0x0,%esi
f0100c32:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c35:	e9 ca 01 00 00       	jmp    f0100e04 <check_page_free_list+0x2fb>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c3a:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100c3d:	73 24                	jae    f0100c63 <check_page_free_list+0x15a>
f0100c3f:	c7 44 24 0c a3 78 10 	movl   $0xf01078a3,0xc(%esp)
f0100c46:	f0 
f0100c47:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100c4e:	f0 
f0100c4f:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0100c56:	00 
f0100c57:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100c5e:	e8 dd f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c63:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c66:	72 24                	jb     f0100c8c <check_page_free_list+0x183>
f0100c68:	c7 44 24 0c c4 78 10 	movl   $0xf01078c4,0xc(%esp)
f0100c6f:	f0 
f0100c70:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100c77:	f0 
f0100c78:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100c7f:	00 
f0100c80:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100c87:	e8 b4 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c8c:	89 d0                	mov    %edx,%eax
f0100c8e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c91:	a8 07                	test   $0x7,%al
f0100c93:	74 24                	je     f0100cb9 <check_page_free_list+0x1b0>
f0100c95:	c7 44 24 0c 90 6f 10 	movl   $0xf0106f90,0xc(%esp)
f0100c9c:	f0 
f0100c9d:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100ca4:	f0 
f0100ca5:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0100cac:	00 
f0100cad:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100cb4:	e8 87 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cb9:	c1 f8 03             	sar    $0x3,%eax
f0100cbc:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cbf:	85 c0                	test   %eax,%eax
f0100cc1:	75 24                	jne    f0100ce7 <check_page_free_list+0x1de>
f0100cc3:	c7 44 24 0c d8 78 10 	movl   $0xf01078d8,0xc(%esp)
f0100cca:	f0 
f0100ccb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100cd2:	f0 
f0100cd3:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100cda:	00 
f0100cdb:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100ce2:	e8 59 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ce7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cec:	75 24                	jne    f0100d12 <check_page_free_list+0x209>
f0100cee:	c7 44 24 0c e9 78 10 	movl   $0xf01078e9,0xc(%esp)
f0100cf5:	f0 
f0100cf6:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100cfd:	f0 
f0100cfe:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100d05:	00 
f0100d06:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100d0d:	e8 2e f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d12:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d17:	75 24                	jne    f0100d3d <check_page_free_list+0x234>
f0100d19:	c7 44 24 0c c4 6f 10 	movl   $0xf0106fc4,0xc(%esp)
f0100d20:	f0 
f0100d21:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100d28:	f0 
f0100d29:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d30:	00 
f0100d31:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100d38:	e8 03 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d3d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d42:	75 24                	jne    f0100d68 <check_page_free_list+0x25f>
f0100d44:	c7 44 24 0c 02 79 10 	movl   $0xf0107902,0xc(%esp)
f0100d4b:	f0 
f0100d4c:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100d53:	f0 
f0100d54:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d5b:	00 
f0100d5c:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100d63:	e8 d8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d68:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d6d:	76 59                	jbe    f0100dc8 <check_page_free_list+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d6f:	89 c1                	mov    %eax,%ecx
f0100d71:	c1 e9 0c             	shr    $0xc,%ecx
f0100d74:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100d77:	77 20                	ja     f0100d99 <check_page_free_list+0x290>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d7d:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0100d84:	f0 
f0100d85:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d8c:	00 
f0100d8d:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0100d94:	e8 a7 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d99:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d9f:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100da2:	76 24                	jbe    f0100dc8 <check_page_free_list+0x2bf>
f0100da4:	c7 44 24 0c e8 6f 10 	movl   $0xf0106fe8,0xc(%esp)
f0100dab:	f0 
f0100dac:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100db3:	f0 
f0100db4:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0100dbb:	00 
f0100dbc:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100dc3:	e8 78 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dc8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dcd:	75 24                	jne    f0100df3 <check_page_free_list+0x2ea>
f0100dcf:	c7 44 24 0c 1c 79 10 	movl   $0xf010791c,0xc(%esp)
f0100dd6:	f0 
f0100dd7:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100dde:	f0 
f0100ddf:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100de6:	00 
f0100de7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100dee:	e8 4d f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100df3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100df8:	77 05                	ja     f0100dff <check_page_free_list+0x2f6>
			++nfree_basemem;
f0100dfa:	83 c6 01             	add    $0x1,%esi
f0100dfd:	eb 03                	jmp    f0100e02 <check_page_free_list+0x2f9>
		else
			++nfree_extmem;
f0100dff:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e02:	8b 12                	mov    (%edx),%edx
f0100e04:	85 d2                	test   %edx,%edx
f0100e06:	0f 85 2e fe ff ff    	jne    f0100c3a <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e0c:	85 f6                	test   %esi,%esi
f0100e0e:	7f 24                	jg     f0100e34 <check_page_free_list+0x32b>
f0100e10:	c7 44 24 0c 39 79 10 	movl   $0xf0107939,0xc(%esp)
f0100e17:	f0 
f0100e18:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100e1f:	f0 
f0100e20:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0100e27:	00 
f0100e28:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100e2f:	e8 0c f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e34:	85 db                	test   %ebx,%ebx
f0100e36:	7f 24                	jg     f0100e5c <check_page_free_list+0x353>
f0100e38:	c7 44 24 0c 4b 79 10 	movl   $0xf010794b,0xc(%esp)
f0100e3f:	f0 
f0100e40:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0100e47:	f0 
f0100e48:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100e4f:	00 
f0100e50:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0100e57:	e8 e4 f1 ff ff       	call   f0100040 <_panic>
}
f0100e5c:	83 c4 4c             	add    $0x4c,%esp
f0100e5f:	5b                   	pop    %ebx
f0100e60:	5e                   	pop    %esi
f0100e61:	5f                   	pop    %edi
f0100e62:	5d                   	pop    %ebp
f0100e63:	c3                   	ret    

f0100e64 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e64:	55                   	push   %ebp
f0100e65:	89 e5                	mov    %esp,%ebp
f0100e67:	56                   	push   %esi
f0100e68:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e69:	be 00 00 00 00       	mov    $0x0,%esi
f0100e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e73:	e9 e1 00 00 00       	jmp    f0100f59 <page_init+0xf5>
		if(i == 0)
f0100e78:	85 db                	test   %ebx,%ebx
f0100e7a:	75 16                	jne    f0100e92 <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100e7c:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e81:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e8d:	e9 c1 00 00 00       	jmp    f0100f53 <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100e92:	83 fb 07             	cmp    $0x7,%ebx
f0100e95:	75 17                	jne    f0100eae <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100e97:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0100e9c:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100ea2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100ea9:	e9 a5 00 00 00       	jmp    f0100f53 <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100eae:	3b 1d 38 c2 22 f0    	cmp    0xf022c238,%ebx
f0100eb4:	73 25                	jae    f0100edb <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100eb6:	89 f0                	mov    %esi,%eax
f0100eb8:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100ebe:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100ec4:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100eca:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100ecc:	89 f0                	mov    %esi,%eax
f0100ece:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100ed4:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
f0100ed9:	eb 78                	jmp    f0100f53 <page_init+0xef>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100edb:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100ee1:	83 f8 5f             	cmp    $0x5f,%eax
f0100ee4:	77 16                	ja     f0100efc <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100ee6:	89 f0                	mov    %esi,%eax
f0100ee8:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100eee:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ef4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100efa:	eb 57                	jmp    f0100f53 <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100efc:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f02:	76 2c                	jbe    f0100f30 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100f04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f09:	e8 16 fb ff ff       	call   f0100a24 <boot_alloc>
f0100f0e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f13:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f16:	39 c3                	cmp    %eax,%ebx
f0100f18:	73 16                	jae    f0100f30 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100f1a:	89 f0                	mov    %esi,%eax
f0100f1c:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f22:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f2e:	eb 23                	jmp    f0100f53 <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f30:	89 f0                	mov    %esi,%eax
f0100f32:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f38:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f3e:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0100f44:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f46:	89 f0                	mov    %esi,%eax
f0100f48:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
f0100f4e:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f53:	83 c3 01             	add    $0x1,%ebx
f0100f56:	83 c6 08             	add    $0x8,%esi
f0100f59:	3b 1d 88 ce 22 f0    	cmp    0xf022ce88,%ebx
f0100f5f:	0f 82 13 ff ff ff    	jb     f0100e78 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100f65:	5b                   	pop    %ebx
f0100f66:	5e                   	pop    %esi
f0100f67:	5d                   	pop    %ebp
f0100f68:	c3                   	ret    

f0100f69 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f69:	55                   	push   %ebp
f0100f6a:	89 e5                	mov    %esp,%ebp
f0100f6c:	53                   	push   %ebx
f0100f6d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100f70:	8b 1d 40 c2 22 f0    	mov    0xf022c240,%ebx
f0100f76:	85 db                	test   %ebx,%ebx
f0100f78:	74 6b                	je     f0100fe5 <page_alloc+0x7c>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100f7a:	8b 03                	mov    (%ebx),%eax
f0100f7c:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	page->pp_link = 0;
f0100f81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f87:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f8b:	74 58                	je     f0100fe5 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f8d:	89 d8                	mov    %ebx,%eax
f0100f8f:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0100f95:	c1 f8 03             	sar    $0x3,%eax
f0100f98:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f9b:	89 c2                	mov    %eax,%edx
f0100f9d:	c1 ea 0c             	shr    $0xc,%edx
f0100fa0:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0100fa6:	72 20                	jb     f0100fc8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fac:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0100fb3:	f0 
f0100fb4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100fbb:	00 
f0100fbc:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0100fc3:	e8 78 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100fc8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fcf:	00 
f0100fd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fd7:	00 
	return (void *)(pa + KERNBASE);
f0100fd8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fdd:	89 04 24             	mov    %eax,(%esp)
f0100fe0:	e8 0e 4d 00 00       	call   f0105cf3 <memset>
	return page;
	return 0;
}
f0100fe5:	89 d8                	mov    %ebx,%eax
f0100fe7:	83 c4 14             	add    $0x14,%esp
f0100fea:	5b                   	pop    %ebx
f0100feb:	5d                   	pop    %ebp
f0100fec:	c3                   	ret    

f0100fed <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fed:	55                   	push   %ebp
f0100fee:	89 e5                	mov    %esp,%ebp
f0100ff0:	83 ec 18             	sub    $0x18,%esp
f0100ff3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0100ff6:	83 38 00             	cmpl   $0x0,(%eax)
f0100ff9:	75 07                	jne    f0101002 <page_free+0x15>
f0100ffb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101000:	74 1c                	je     f010101e <page_free+0x31>
		panic("page_free is not right");
f0101002:	c7 44 24 08 5c 79 10 	movl   $0xf010795c,0x8(%esp)
f0101009:	f0 
f010100a:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0101011:	00 
f0101012:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101019:	e8 22 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010101e:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0101024:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101026:	a3 40 c2 22 f0       	mov    %eax,0xf022c240
	return; 
}
f010102b:	c9                   	leave  
f010102c:	c3                   	ret    

f010102d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010102d:	55                   	push   %ebp
f010102e:	89 e5                	mov    %esp,%ebp
f0101030:	83 ec 18             	sub    $0x18,%esp
f0101033:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101036:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010103a:	83 ea 01             	sub    $0x1,%edx
f010103d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101041:	66 85 d2             	test   %dx,%dx
f0101044:	75 08                	jne    f010104e <page_decref+0x21>
		page_free(pp);
f0101046:	89 04 24             	mov    %eax,(%esp)
f0101049:	e8 9f ff ff ff       	call   f0100fed <page_free>
}
f010104e:	c9                   	leave  
f010104f:	c3                   	ret    

f0101050 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	56                   	push   %esi
f0101054:	53                   	push   %ebx
f0101055:	83 ec 10             	sub    $0x10,%esp
f0101058:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f010105b:	89 f3                	mov    %esi,%ebx
f010105d:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f0101060:	c1 e3 02             	shl    $0x2,%ebx
f0101063:	03 5d 08             	add    0x8(%ebp),%ebx
f0101066:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101069:	0f 94 c0             	sete   %al
f010106c:	75 06                	jne    f0101074 <pgdir_walk+0x24>
f010106e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101072:	74 70                	je     f01010e4 <pgdir_walk+0x94>
		return NULL;
	if(pgdir[pdeIndex] == 0){
f0101074:	84 c0                	test   %al,%al
f0101076:	74 26                	je     f010109e <pgdir_walk+0x4e>
		struct PageInfo* page = page_alloc(1);
f0101078:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010107f:	e8 e5 fe ff ff       	call   f0100f69 <page_alloc>
		if(page == NULL)
f0101084:	85 c0                	test   %eax,%eax
f0101086:	74 63                	je     f01010eb <pgdir_walk+0x9b>
			return NULL;
		page->pp_ref++;
f0101088:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010108d:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0101093:	c1 f8 03             	sar    $0x3,%eax
f0101096:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0101099:	83 c8 07             	or     $0x7,%eax
f010109c:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f010109e:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f01010a0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a5:	89 c2                	mov    %eax,%edx
f01010a7:	c1 ea 0c             	shr    $0xc,%edx
f01010aa:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f01010b0:	72 20                	jb     f01010d2 <pgdir_walk+0x82>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010b6:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01010bd:	f0 
f01010be:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f01010c5:	00 
f01010c6:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01010cd:	e8 6e ef ff ff       	call   f0100040 <_panic>
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01010d2:	c1 ee 0a             	shr    $0xa,%esi
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
f01010d5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010db:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
	return pte;
f01010e2:	eb 0c                	jmp    f01010f0 <pgdir_walk+0xa0>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f01010e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e9:	eb 05                	jmp    f01010f0 <pgdir_walk+0xa0>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f01010eb:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f01010f0:	83 c4 10             	add    $0x10,%esp
f01010f3:	5b                   	pop    %ebx
f01010f4:	5e                   	pop    %esi
f01010f5:	5d                   	pop    %ebp
f01010f6:	c3                   	ret    

f01010f7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010f7:	55                   	push   %ebp
f01010f8:	89 e5                	mov    %esp,%ebp
f01010fa:	57                   	push   %edi
f01010fb:	56                   	push   %esi
f01010fc:	53                   	push   %ebx
f01010fd:	83 ec 2c             	sub    $0x2c,%esp
f0101100:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101103:	89 d6                	mov    %edx,%esi
f0101105:	89 cb                	mov    %ecx,%ebx
f0101107:	8b 7d 08             	mov    0x8(%ebp),%edi
	while(size)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f010110a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010110d:	83 c8 01             	or     $0x1,%eax
f0101110:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101113:	eb 34                	jmp    f0101149 <boot_map_region+0x52>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101115:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010111c:	00 
f010111d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101124:	89 04 24             	mov    %eax,(%esp)
f0101127:	e8 24 ff ff ff       	call   f0101050 <pgdir_walk>
		if(pte == NULL)
f010112c:	85 c0                	test   %eax,%eax
f010112e:	74 1d                	je     f010114d <boot_map_region+0x56>
			return;
		*pte= pa |perm|PTE_P;
f0101130:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101133:	09 fa                	or     %edi,%edx
f0101135:	89 10                	mov    %edx,(%eax)
		
		size -= PGSIZE;
f0101137:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
		pa  += PGSIZE;
f010113d:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va  += PGSIZE;
f0101143:	81 c6 00 10 00 00    	add    $0x1000,%esi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101149:	85 db                	test   %ebx,%ebx
f010114b:	75 c8                	jne    f0101115 <boot_map_region+0x1e>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f010114d:	83 c4 2c             	add    $0x2c,%esp
f0101150:	5b                   	pop    %ebx
f0101151:	5e                   	pop    %esi
f0101152:	5f                   	pop    %edi
f0101153:	5d                   	pop    %ebp
f0101154:	c3                   	ret    

f0101155 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101155:	55                   	push   %ebp
f0101156:	89 e5                	mov    %esp,%ebp
f0101158:	53                   	push   %ebx
f0101159:	83 ec 14             	sub    $0x14,%esp
f010115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f010115f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101166:	00 
f0101167:	8b 45 0c             	mov    0xc(%ebp),%eax
f010116a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010116e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101171:	89 04 24             	mov    %eax,(%esp)
f0101174:	e8 d7 fe ff ff       	call   f0101050 <pgdir_walk>
	if(pte == NULL)
f0101179:	85 c0                	test   %eax,%eax
f010117b:	74 42                	je     f01011bf <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f010117d:	8b 10                	mov    (%eax),%edx
f010117f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f0101185:	85 db                	test   %ebx,%ebx
f0101187:	74 02                	je     f010118b <page_lookup+0x36>
		*pte_store = pte ;
f0101189:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010118b:	89 d0                	mov    %edx,%eax
f010118d:	c1 e8 0c             	shr    $0xc,%eax
f0101190:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0101196:	72 1c                	jb     f01011b4 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101198:	c7 44 24 08 30 70 10 	movl   $0xf0107030,0x8(%esp)
f010119f:	f0 
f01011a0:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01011a7:	00 
f01011a8:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f01011af:	e8 8c ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011b4:	c1 e0 03             	shl    $0x3,%eax
f01011b7:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
	return pa2page(pa);	
f01011bd:	eb 05                	jmp    f01011c4 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f01011bf:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f01011c4:	83 c4 14             	add    $0x14,%esp
f01011c7:	5b                   	pop    %ebx
f01011c8:	5d                   	pop    %ebp
f01011c9:	c3                   	ret    

f01011ca <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011ca:	55                   	push   %ebp
f01011cb:	89 e5                	mov    %esp,%ebp
f01011cd:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011d0:	e8 7f 51 00 00       	call   f0106354 <cpunum>
f01011d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d8:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01011df:	74 16                	je     f01011f7 <tlb_invalidate+0x2d>
f01011e1:	e8 6e 51 00 00       	call   f0106354 <cpunum>
f01011e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01011ef:	8b 55 08             	mov    0x8(%ebp),%edx
f01011f2:	39 50 60             	cmp    %edx,0x60(%eax)
f01011f5:	75 06                	jne    f01011fd <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011fa:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011fd:	c9                   	leave  
f01011fe:	c3                   	ret    

f01011ff <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011ff:	55                   	push   %ebp
f0101200:	89 e5                	mov    %esp,%ebp
f0101202:	83 ec 28             	sub    $0x28,%esp
f0101205:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101208:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010120b:	8b 75 08             	mov    0x8(%ebp),%esi
f010120e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101211:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101214:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010121c:	89 34 24             	mov    %esi,(%esp)
f010121f:	e8 31 ff ff ff       	call   f0101155 <page_lookup>
	if(page == 0)
f0101224:	85 c0                	test   %eax,%eax
f0101226:	74 2d                	je     f0101255 <page_remove+0x56>
		return;
	*pte = 0;
f0101228:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010122b:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101231:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101235:	83 ea 01             	sub    $0x1,%edx
f0101238:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f010123c:	66 85 d2             	test   %dx,%dx
f010123f:	75 08                	jne    f0101249 <page_remove+0x4a>
		page_free(page);
f0101241:	89 04 24             	mov    %eax,(%esp)
f0101244:	e8 a4 fd ff ff       	call   f0100fed <page_free>
	tlb_invalidate(pgdir, va);
f0101249:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010124d:	89 34 24             	mov    %esi,(%esp)
f0101250:	e8 75 ff ff ff       	call   f01011ca <tlb_invalidate>
}
f0101255:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101258:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010125b:	89 ec                	mov    %ebp,%esp
f010125d:	5d                   	pop    %ebp
f010125e:	c3                   	ret    

f010125f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010125f:	55                   	push   %ebp
f0101260:	89 e5                	mov    %esp,%ebp
f0101262:	83 ec 28             	sub    $0x28,%esp
f0101265:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101268:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010126b:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010126e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101271:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101274:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010127b:	00 
f010127c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101280:	8b 45 08             	mov    0x8(%ebp),%eax
f0101283:	89 04 24             	mov    %eax,(%esp)
f0101286:	e8 c5 fd ff ff       	call   f0101050 <pgdir_walk>
f010128b:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f010128d:	85 c0                	test   %eax,%eax
f010128f:	74 5a                	je     f01012eb <page_insert+0x8c>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f0101291:	8b 00                	mov    (%eax),%eax
f0101293:	89 c1                	mov    %eax,%ecx
f0101295:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010129b:	89 da                	mov    %ebx,%edx
f010129d:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01012a3:	c1 fa 03             	sar    $0x3,%edx
f01012a6:	c1 e2 0c             	shl    $0xc,%edx
f01012a9:	39 d1                	cmp    %edx,%ecx
f01012ab:	75 07                	jne    f01012b4 <page_insert+0x55>
		pp->pp_ref--;
f01012ad:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01012b2:	eb 13                	jmp    f01012c7 <page_insert+0x68>
	
	else if(*pte != 0)
f01012b4:	85 c0                	test   %eax,%eax
f01012b6:	74 0f                	je     f01012c7 <page_insert+0x68>
		page_remove(pgdir, va);
f01012b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bf:	89 04 24             	mov    %eax,(%esp)
f01012c2:	e8 38 ff ff ff       	call   f01011ff <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01012c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ca:	83 c8 01             	or     $0x1,%eax
f01012cd:	89 da                	mov    %ebx,%edx
f01012cf:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01012d5:	c1 fa 03             	sar    $0x3,%edx
f01012d8:	c1 e2 0c             	shl    $0xc,%edx
f01012db:	09 d0                	or     %edx,%eax
f01012dd:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01012df:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01012e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e9:	eb 05                	jmp    f01012f0 <page_insert+0x91>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f01012eb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f01012f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01012f3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01012f6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01012f9:	89 ec                	mov    %ebp,%esp
f01012fb:	5d                   	pop    %ebp
f01012fc:	c3                   	ret    

f01012fd <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	53                   	push   %ebx
f0101301:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f0101304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101307:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f010130d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	if(size + base >= MMIOLIM)
f0101313:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101319:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010131c:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101321:	76 1c                	jbe    f010133f <mmio_map_region+0x42>
		panic("mmio_map_region not implemented");
f0101323:	c7 44 24 08 50 70 10 	movl   $0xf0107050,0x8(%esp)
f010132a:	f0 
f010132b:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0101332:	00 
f0101333:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010133a:	e8 01 ed ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010133f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101346:	00 
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
	pa = ROUNDDOWN(pa, PGSIZE);
f0101347:	8b 45 08             	mov    0x8(%ebp),%eax
f010134a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if(size + base >= MMIOLIM)
		panic("mmio_map_region not implemented");
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010134f:	89 04 24             	mov    %eax,(%esp)
f0101352:	89 d9                	mov    %ebx,%ecx
f0101354:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101359:	e8 99 fd ff ff       	call   f01010f7 <boot_map_region>
	uintptr_t ret = base;
f010135e:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base +size;
f0101363:	01 c3                	add    %eax,%ebx
f0101365:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) ret;
}
f010136b:	83 c4 14             	add    $0x14,%esp
f010136e:	5b                   	pop    %ebx
f010136f:	5d                   	pop    %ebp
f0101370:	c3                   	ret    

f0101371 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101371:	55                   	push   %ebp
f0101372:	89 e5                	mov    %esp,%ebp
f0101374:	57                   	push   %edi
f0101375:	56                   	push   %esi
f0101376:	53                   	push   %ebx
f0101377:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010137a:	b8 15 00 00 00       	mov    $0x15,%eax
f010137f:	e8 53 f7 ff ff       	call   f0100ad7 <nvram_read>
f0101384:	c1 e0 0a             	shl    $0xa,%eax
f0101387:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010138d:	85 c0                	test   %eax,%eax
f010138f:	0f 48 c2             	cmovs  %edx,%eax
f0101392:	c1 f8 0c             	sar    $0xc,%eax
f0101395:	a3 38 c2 22 f0       	mov    %eax,0xf022c238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010139a:	b8 17 00 00 00       	mov    $0x17,%eax
f010139f:	e8 33 f7 ff ff       	call   f0100ad7 <nvram_read>
f01013a4:	c1 e0 0a             	shl    $0xa,%eax
f01013a7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013ad:	85 c0                	test   %eax,%eax
f01013af:	0f 48 c2             	cmovs  %edx,%eax
f01013b2:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01013b5:	85 c0                	test   %eax,%eax
f01013b7:	74 0e                	je     f01013c7 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01013b9:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013bf:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88
f01013c5:	eb 0c                	jmp    f01013d3 <mem_init+0x62>
	else
		npages = npages_basemem;
f01013c7:	8b 15 38 c2 22 f0    	mov    0xf022c238,%edx
f01013cd:	89 15 88 ce 22 f0    	mov    %edx,0xf022ce88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01013d3:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013d6:	c1 e8 0a             	shr    $0xa,%eax
f01013d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01013dd:	a1 38 c2 22 f0       	mov    0xf022c238,%eax
f01013e2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013e5:	c1 e8 0a             	shr    $0xa,%eax
f01013e8:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01013ec:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f01013f1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013f4:	c1 e8 0a             	shr    $0xa,%eax
f01013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013fb:	c7 04 24 70 70 10 f0 	movl   $0xf0107070,(%esp)
f0101402:	e8 87 2b 00 00       	call   f0103f8e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101407:	b8 00 10 00 00       	mov    $0x1000,%eax
f010140c:	e8 13 f6 ff ff       	call   f0100a24 <boot_alloc>
f0101411:	a3 8c ce 22 f0       	mov    %eax,0xf022ce8c
	memset(kern_pgdir, 0, PGSIZE);
f0101416:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010141d:	00 
f010141e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101425:	00 
f0101426:	89 04 24             	mov    %eax,(%esp)
f0101429:	e8 c5 48 00 00       	call   f0105cf3 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010142e:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101433:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101438:	77 20                	ja     f010145a <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010143a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010143e:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0101445:	f0 
f0101446:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f010144d:	00 
f010144e:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101455:	e8 e6 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010145a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101460:	83 ca 05             	or     $0x5,%edx
f0101463:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f0101469:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f010146e:	c1 e0 03             	shl    $0x3,%eax
f0101471:	e8 ae f5 ff ff       	call   f0100a24 <boot_alloc>
f0101476:	a3 90 ce 22 f0       	mov    %eax,0xf022ce90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f010147b:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
f0101481:	c1 e2 03             	shl    $0x3,%edx
f0101484:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010148f:	00 
f0101490:	89 04 24             	mov    %eax,(%esp)
f0101493:	e8 5b 48 00 00       	call   f0105cf3 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101498:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010149d:	e8 82 f5 ff ff       	call   f0100a24 <boot_alloc>
f01014a2:	a3 48 c2 22 f0       	mov    %eax,0xf022c248
	memset(envs, 0, NENV*sizeof(struct Env) );
f01014a7:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01014ae:	00 
f01014af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014b6:	00 
f01014b7:	89 04 24             	mov    %eax,(%esp)
f01014ba:	e8 34 48 00 00       	call   f0105cf3 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014bf:	e8 a0 f9 ff ff       	call   f0100e64 <page_init>

	check_page_free_list(1);
f01014c4:	b8 01 00 00 00       	mov    $0x1,%eax
f01014c9:	e8 3b f6 ff ff       	call   f0100b09 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014ce:	83 3d 90 ce 22 f0 00 	cmpl   $0x0,0xf022ce90
f01014d5:	75 1c                	jne    f01014f3 <mem_init+0x182>
		panic("'pages' is a null pointer!");
f01014d7:	c7 44 24 08 73 79 10 	movl   $0xf0107973,0x8(%esp)
f01014de:	f0 
f01014df:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01014e6:	00 
f01014e7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01014ee:	e8 4d eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014f3:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f01014f8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014fd:	eb 05                	jmp    f0101504 <mem_init+0x193>
		++nfree;
f01014ff:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101502:	8b 00                	mov    (%eax),%eax
f0101504:	85 c0                	test   %eax,%eax
f0101506:	75 f7                	jne    f01014ff <mem_init+0x18e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101508:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010150f:	e8 55 fa ff ff       	call   f0100f69 <page_alloc>
f0101514:	89 c6                	mov    %eax,%esi
f0101516:	85 c0                	test   %eax,%eax
f0101518:	75 24                	jne    f010153e <mem_init+0x1cd>
f010151a:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f0101521:	f0 
f0101522:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101529:	f0 
f010152a:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101531:	00 
f0101532:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101539:	e8 02 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010153e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101545:	e8 1f fa ff ff       	call   f0100f69 <page_alloc>
f010154a:	89 c7                	mov    %eax,%edi
f010154c:	85 c0                	test   %eax,%eax
f010154e:	75 24                	jne    f0101574 <mem_init+0x203>
f0101550:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0101557:	f0 
f0101558:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010155f:	f0 
f0101560:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101567:	00 
f0101568:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010156f:	e8 cc ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101574:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010157b:	e8 e9 f9 ff ff       	call   f0100f69 <page_alloc>
f0101580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101583:	85 c0                	test   %eax,%eax
f0101585:	75 24                	jne    f01015ab <mem_init+0x23a>
f0101587:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f010158e:	f0 
f010158f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101596:	f0 
f0101597:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010159e:	00 
f010159f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01015a6:	e8 95 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015ab:	39 fe                	cmp    %edi,%esi
f01015ad:	75 24                	jne    f01015d3 <mem_init+0x262>
f01015af:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f01015c6:	00 
f01015c7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01015ce:	e8 6d ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015d3:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01015d6:	74 05                	je     f01015dd <mem_init+0x26c>
f01015d8:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015db:	75 24                	jne    f0101601 <mem_init+0x290>
f01015dd:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f01015e4:	f0 
f01015e5:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01015ec:	f0 
f01015ed:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01015f4:	00 
f01015f5:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01015fc:	e8 3f ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101601:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101607:	a1 88 ce 22 f0       	mov    0xf022ce88,%eax
f010160c:	c1 e0 0c             	shl    $0xc,%eax
f010160f:	89 f1                	mov    %esi,%ecx
f0101611:	29 d1                	sub    %edx,%ecx
f0101613:	c1 f9 03             	sar    $0x3,%ecx
f0101616:	c1 e1 0c             	shl    $0xc,%ecx
f0101619:	39 c1                	cmp    %eax,%ecx
f010161b:	72 24                	jb     f0101641 <mem_init+0x2d0>
f010161d:	c7 44 24 0c e2 79 10 	movl   $0xf01079e2,0xc(%esp)
f0101624:	f0 
f0101625:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010162c:	f0 
f010162d:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101634:	00 
f0101635:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>
f0101641:	89 f9                	mov    %edi,%ecx
f0101643:	29 d1                	sub    %edx,%ecx
f0101645:	c1 f9 03             	sar    $0x3,%ecx
f0101648:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010164b:	39 c8                	cmp    %ecx,%eax
f010164d:	77 24                	ja     f0101673 <mem_init+0x302>
f010164f:	c7 44 24 0c ff 79 10 	movl   $0xf01079ff,0xc(%esp)
f0101656:	f0 
f0101657:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010165e:	f0 
f010165f:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101666:	00 
f0101667:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010166e:	e8 cd e9 ff ff       	call   f0100040 <_panic>
f0101673:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101676:	29 d1                	sub    %edx,%ecx
f0101678:	89 ca                	mov    %ecx,%edx
f010167a:	c1 fa 03             	sar    $0x3,%edx
f010167d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101680:	39 d0                	cmp    %edx,%eax
f0101682:	77 24                	ja     f01016a8 <mem_init+0x337>
f0101684:	c7 44 24 0c 1c 7a 10 	movl   $0xf0107a1c,0xc(%esp)
f010168b:	f0 
f010168c:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101693:	f0 
f0101694:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f010169b:	00 
f010169c:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01016a3:	e8 98 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016a8:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f01016ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016b0:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f01016b7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c1:	e8 a3 f8 ff ff       	call   f0100f69 <page_alloc>
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	74 24                	je     f01016ee <mem_init+0x37d>
f01016ca:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f01016d1:	f0 
f01016d2:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01016d9:	f0 
f01016da:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01016e1:	00 
f01016e2:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01016e9:	e8 52 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016ee:	89 34 24             	mov    %esi,(%esp)
f01016f1:	e8 f7 f8 ff ff       	call   f0100fed <page_free>
	page_free(pp1);
f01016f6:	89 3c 24             	mov    %edi,(%esp)
f01016f9:	e8 ef f8 ff ff       	call   f0100fed <page_free>
	page_free(pp2);
f01016fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101701:	89 04 24             	mov    %eax,(%esp)
f0101704:	e8 e4 f8 ff ff       	call   f0100fed <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101710:	e8 54 f8 ff ff       	call   f0100f69 <page_alloc>
f0101715:	89 c6                	mov    %eax,%esi
f0101717:	85 c0                	test   %eax,%eax
f0101719:	75 24                	jne    f010173f <mem_init+0x3ce>
f010171b:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f0101722:	f0 
f0101723:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010172a:	f0 
f010172b:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101732:	00 
f0101733:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010173a:	e8 01 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010173f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101746:	e8 1e f8 ff ff       	call   f0100f69 <page_alloc>
f010174b:	89 c7                	mov    %eax,%edi
f010174d:	85 c0                	test   %eax,%eax
f010174f:	75 24                	jne    f0101775 <mem_init+0x404>
f0101751:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0101758:	f0 
f0101759:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101760:	f0 
f0101761:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101768:	00 
f0101769:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101770:	e8 cb e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101775:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010177c:	e8 e8 f7 ff ff       	call   f0100f69 <page_alloc>
f0101781:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101784:	85 c0                	test   %eax,%eax
f0101786:	75 24                	jne    f01017ac <mem_init+0x43b>
f0101788:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f010178f:	f0 
f0101790:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101797:	f0 
f0101798:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010179f:	00 
f01017a0:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01017a7:	e8 94 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ac:	39 fe                	cmp    %edi,%esi
f01017ae:	75 24                	jne    f01017d4 <mem_init+0x463>
f01017b0:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f01017b7:	f0 
f01017b8:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01017bf:	f0 
f01017c0:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01017c7:	00 
f01017c8:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01017cf:	e8 6c e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017d7:	74 05                	je     f01017de <mem_init+0x46d>
f01017d9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017dc:	75 24                	jne    f0101802 <mem_init+0x491>
f01017de:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f01017e5:	f0 
f01017e6:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01017ed:	f0 
f01017ee:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f01017f5:	00 
f01017f6:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01017fd:	e8 3e e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101809:	e8 5b f7 ff ff       	call   f0100f69 <page_alloc>
f010180e:	85 c0                	test   %eax,%eax
f0101810:	74 24                	je     f0101836 <mem_init+0x4c5>
f0101812:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f0101819:	f0 
f010181a:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101821:	f0 
f0101822:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101829:	00 
f010182a:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101831:	e8 0a e8 ff ff       	call   f0100040 <_panic>
f0101836:	89 f0                	mov    %esi,%eax
f0101838:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f010183e:	c1 f8 03             	sar    $0x3,%eax
f0101841:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101844:	89 c2                	mov    %eax,%edx
f0101846:	c1 ea 0c             	shr    $0xc,%edx
f0101849:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f010184f:	72 20                	jb     f0101871 <mem_init+0x500>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101851:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101855:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f010185c:	f0 
f010185d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101864:	00 
f0101865:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f010186c:	e8 cf e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101871:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101878:	00 
f0101879:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101880:	00 
	return (void *)(pa + KERNBASE);
f0101881:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101886:	89 04 24             	mov    %eax,(%esp)
f0101889:	e8 65 44 00 00       	call   f0105cf3 <memset>
	page_free(pp0);
f010188e:	89 34 24             	mov    %esi,(%esp)
f0101891:	e8 57 f7 ff ff       	call   f0100fed <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101896:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010189d:	e8 c7 f6 ff ff       	call   f0100f69 <page_alloc>
f01018a2:	85 c0                	test   %eax,%eax
f01018a4:	75 24                	jne    f01018ca <mem_init+0x559>
f01018a6:	c7 44 24 0c 48 7a 10 	movl   $0xf0107a48,0xc(%esp)
f01018ad:	f0 
f01018ae:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01018b5:	f0 
f01018b6:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01018bd:	00 
f01018be:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01018c5:	e8 76 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018ca:	39 c6                	cmp    %eax,%esi
f01018cc:	74 24                	je     f01018f2 <mem_init+0x581>
f01018ce:	c7 44 24 0c 66 7a 10 	movl   $0xf0107a66,0xc(%esp)
f01018d5:	f0 
f01018d6:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01018e5:	00 
f01018e6:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01018ed:	e8 4e e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018f2:	89 f2                	mov    %esi,%edx
f01018f4:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01018fa:	c1 fa 03             	sar    $0x3,%edx
f01018fd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101900:	89 d0                	mov    %edx,%eax
f0101902:	c1 e8 0c             	shr    $0xc,%eax
f0101905:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f010190b:	72 20                	jb     f010192d <mem_init+0x5bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010190d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101911:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0101918:	f0 
f0101919:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101920:	00 
f0101921:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0101928:	e8 13 e7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010192d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101933:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101939:	80 38 00             	cmpb   $0x0,(%eax)
f010193c:	74 24                	je     f0101962 <mem_init+0x5f1>
f010193e:	c7 44 24 0c 76 7a 10 	movl   $0xf0107a76,0xc(%esp)
f0101945:	f0 
f0101946:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010194d:	f0 
f010194e:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101955:	00 
f0101956:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010195d:	e8 de e6 ff ff       	call   f0100040 <_panic>
f0101962:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101965:	39 d0                	cmp    %edx,%eax
f0101967:	75 d0                	jne    f0101939 <mem_init+0x5c8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101969:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010196c:	89 15 40 c2 22 f0    	mov    %edx,0xf022c240

	// free the pages we took
	page_free(pp0);
f0101972:	89 34 24             	mov    %esi,(%esp)
f0101975:	e8 73 f6 ff ff       	call   f0100fed <page_free>
	page_free(pp1);
f010197a:	89 3c 24             	mov    %edi,(%esp)
f010197d:	e8 6b f6 ff ff       	call   f0100fed <page_free>
	page_free(pp2);
f0101982:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101985:	89 04 24             	mov    %eax,(%esp)
f0101988:	e8 60 f6 ff ff       	call   f0100fed <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010198d:	a1 40 c2 22 f0       	mov    0xf022c240,%eax
f0101992:	eb 05                	jmp    f0101999 <mem_init+0x628>
		--nfree;
f0101994:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101997:	8b 00                	mov    (%eax),%eax
f0101999:	85 c0                	test   %eax,%eax
f010199b:	75 f7                	jne    f0101994 <mem_init+0x623>
		--nfree;
	assert(nfree == 0);
f010199d:	85 db                	test   %ebx,%ebx
f010199f:	74 24                	je     f01019c5 <mem_init+0x654>
f01019a1:	c7 44 24 0c 80 7a 10 	movl   $0xf0107a80,0xc(%esp)
f01019a8:	f0 
f01019a9:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01019b0:	f0 
f01019b1:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01019b8:	00 
f01019b9:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01019c0:	e8 7b e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019c5:	c7 04 24 cc 70 10 f0 	movl   $0xf01070cc,(%esp)
f01019cc:	e8 bd 25 00 00       	call   f0103f8e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019d8:	e8 8c f5 ff ff       	call   f0100f69 <page_alloc>
f01019dd:	89 c7                	mov    %eax,%edi
f01019df:	85 c0                	test   %eax,%eax
f01019e1:	75 24                	jne    f0101a07 <mem_init+0x696>
f01019e3:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f01019ea:	f0 
f01019eb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01019f2:	f0 
f01019f3:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01019fa:	00 
f01019fb:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101a02:	e8 39 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a0e:	e8 56 f5 ff ff       	call   f0100f69 <page_alloc>
f0101a13:	89 c6                	mov    %eax,%esi
f0101a15:	85 c0                	test   %eax,%eax
f0101a17:	75 24                	jne    f0101a3d <mem_init+0x6cc>
f0101a19:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0101a20:	f0 
f0101a21:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101a28:	f0 
f0101a29:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101a30:	00 
f0101a31:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101a38:	e8 03 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a44:	e8 20 f5 ff ff       	call   f0100f69 <page_alloc>
f0101a49:	89 c3                	mov    %eax,%ebx
f0101a4b:	85 c0                	test   %eax,%eax
f0101a4d:	75 24                	jne    f0101a73 <mem_init+0x702>
f0101a4f:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f0101a56:	f0 
f0101a57:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101a5e:	f0 
f0101a5f:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101a66:	00 
f0101a67:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101a6e:	e8 cd e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a73:	39 f7                	cmp    %esi,%edi
f0101a75:	75 24                	jne    f0101a9b <mem_init+0x72a>
f0101a77:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f0101a7e:	f0 
f0101a7f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101a86:	f0 
f0101a87:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101a8e:	00 
f0101a8f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101a96:	e8 a5 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a9b:	39 c6                	cmp    %eax,%esi
f0101a9d:	74 04                	je     f0101aa3 <mem_init+0x732>
f0101a9f:	39 c7                	cmp    %eax,%edi
f0101aa1:	75 24                	jne    f0101ac7 <mem_init+0x756>
f0101aa3:	c7 44 24 0c ac 70 10 	movl   $0xf01070ac,0xc(%esp)
f0101aaa:	f0 
f0101aab:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101aba:	00 
f0101abb:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ac7:	8b 15 40 c2 22 f0    	mov    0xf022c240,%edx
f0101acd:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101ad0:	c7 05 40 c2 22 f0 00 	movl   $0x0,0xf022c240
f0101ad7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ada:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae1:	e8 83 f4 ff ff       	call   f0100f69 <page_alloc>
f0101ae6:	85 c0                	test   %eax,%eax
f0101ae8:	74 24                	je     f0101b0e <mem_init+0x79d>
f0101aea:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f0101af1:	f0 
f0101af2:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101af9:	f0 
f0101afa:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101b01:	00 
f0101b02:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101b09:	e8 32 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b11:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b1c:	00 
f0101b1d:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101b22:	89 04 24             	mov    %eax,(%esp)
f0101b25:	e8 2b f6 ff ff       	call   f0101155 <page_lookup>
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	74 24                	je     f0101b52 <mem_init+0x7e1>
f0101b2e:	c7 44 24 0c ec 70 10 	movl   $0xf01070ec,0xc(%esp)
f0101b35:	f0 
f0101b36:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101b3d:	f0 
f0101b3e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101b45:	00 
f0101b46:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101b4d:	e8 ee e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b52:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b59:	00 
f0101b5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b61:	00 
f0101b62:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b66:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101b6b:	89 04 24             	mov    %eax,(%esp)
f0101b6e:	e8 ec f6 ff ff       	call   f010125f <page_insert>
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	78 24                	js     f0101b9b <mem_init+0x82a>
f0101b77:	c7 44 24 0c 24 71 10 	movl   $0xf0107124,0xc(%esp)
f0101b7e:	f0 
f0101b7f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101b86:	f0 
f0101b87:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101b8e:	00 
f0101b8f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101b96:	e8 a5 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b9b:	89 3c 24             	mov    %edi,(%esp)
f0101b9e:	e8 4a f4 ff ff       	call   f0100fed <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ba3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101baa:	00 
f0101bab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bb2:	00 
f0101bb3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bb7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101bbc:	89 04 24             	mov    %eax,(%esp)
f0101bbf:	e8 9b f6 ff ff       	call   f010125f <page_insert>
f0101bc4:	85 c0                	test   %eax,%eax
f0101bc6:	74 24                	je     f0101bec <mem_init+0x87b>
f0101bc8:	c7 44 24 0c 54 71 10 	movl   $0xf0107154,0xc(%esp)
f0101bcf:	f0 
f0101bd0:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101bd7:	f0 
f0101bd8:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101bdf:	00 
f0101be0:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101be7:	e8 54 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bec:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f0101bf2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bf5:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
f0101bfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bfd:	8b 11                	mov    (%ecx),%edx
f0101bff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c05:	89 f8                	mov    %edi,%eax
f0101c07:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101c0a:	c1 f8 03             	sar    $0x3,%eax
f0101c0d:	c1 e0 0c             	shl    $0xc,%eax
f0101c10:	39 c2                	cmp    %eax,%edx
f0101c12:	74 24                	je     f0101c38 <mem_init+0x8c7>
f0101c14:	c7 44 24 0c 84 71 10 	movl   $0xf0107184,0xc(%esp)
f0101c1b:	f0 
f0101c1c:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101c23:	f0 
f0101c24:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101c2b:	00 
f0101c2c:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101c33:	e8 08 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c38:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c40:	e8 21 ee ff ff       	call   f0100a66 <check_va2pa>
f0101c45:	89 f2                	mov    %esi,%edx
f0101c47:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c4a:	c1 fa 03             	sar    $0x3,%edx
f0101c4d:	c1 e2 0c             	shl    $0xc,%edx
f0101c50:	39 d0                	cmp    %edx,%eax
f0101c52:	74 24                	je     f0101c78 <mem_init+0x907>
f0101c54:	c7 44 24 0c ac 71 10 	movl   $0xf01071ac,0xc(%esp)
f0101c5b:	f0 
f0101c5c:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101c63:	f0 
f0101c64:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101c6b:	00 
f0101c6c:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101c73:	e8 c8 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c78:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c7d:	74 24                	je     f0101ca3 <mem_init+0x932>
f0101c7f:	c7 44 24 0c 8b 7a 10 	movl   $0xf0107a8b,0xc(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101c8e:	f0 
f0101c8f:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101c96:	00 
f0101c97:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ca3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ca8:	74 24                	je     f0101cce <mem_init+0x95d>
f0101caa:	c7 44 24 0c 9c 7a 10 	movl   $0xf0107a9c,0xc(%esp)
f0101cb1:	f0 
f0101cb2:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101cc1:	00 
f0101cc2:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101cc9:	e8 72 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cd5:	00 
f0101cd6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cdd:	00 
f0101cde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ce2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ce5:	89 14 24             	mov    %edx,(%esp)
f0101ce8:	e8 72 f5 ff ff       	call   f010125f <page_insert>
f0101ced:	85 c0                	test   %eax,%eax
f0101cef:	74 24                	je     f0101d15 <mem_init+0x9a4>
f0101cf1:	c7 44 24 0c dc 71 10 	movl   $0xf01071dc,0xc(%esp)
f0101cf8:	f0 
f0101cf9:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101d00:	f0 
f0101d01:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101d08:	00 
f0101d09:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101d10:	e8 2b e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d15:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d1a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101d1f:	e8 42 ed ff ff       	call   f0100a66 <check_va2pa>
f0101d24:	89 da                	mov    %ebx,%edx
f0101d26:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101d2c:	c1 fa 03             	sar    $0x3,%edx
f0101d2f:	c1 e2 0c             	shl    $0xc,%edx
f0101d32:	39 d0                	cmp    %edx,%eax
f0101d34:	74 24                	je     f0101d5a <mem_init+0x9e9>
f0101d36:	c7 44 24 0c 18 72 10 	movl   $0xf0107218,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101d55:	e8 e6 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d5f:	74 24                	je     f0101d85 <mem_init+0xa14>
f0101d61:	c7 44 24 0c ad 7a 10 	movl   $0xf0107aad,0xc(%esp)
f0101d68:	f0 
f0101d69:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101d70:	f0 
f0101d71:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101d78:	00 
f0101d79:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101d80:	e8 bb e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d8c:	e8 d8 f1 ff ff       	call   f0100f69 <page_alloc>
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	74 24                	je     f0101db9 <mem_init+0xa48>
f0101d95:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f0101d9c:	f0 
f0101d9d:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101da4:	f0 
f0101da5:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101dac:	00 
f0101dad:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101db4:	e8 87 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101db9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dc0:	00 
f0101dc1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dc8:	00 
f0101dc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dcd:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101dd2:	89 04 24             	mov    %eax,(%esp)
f0101dd5:	e8 85 f4 ff ff       	call   f010125f <page_insert>
f0101dda:	85 c0                	test   %eax,%eax
f0101ddc:	74 24                	je     f0101e02 <mem_init+0xa91>
f0101dde:	c7 44 24 0c dc 71 10 	movl   $0xf01071dc,0xc(%esp)
f0101de5:	f0 
f0101de6:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101df5:	00 
f0101df6:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101dfd:	e8 3e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e02:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e07:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101e0c:	e8 55 ec ff ff       	call   f0100a66 <check_va2pa>
f0101e11:	89 da                	mov    %ebx,%edx
f0101e13:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101e19:	c1 fa 03             	sar    $0x3,%edx
f0101e1c:	c1 e2 0c             	shl    $0xc,%edx
f0101e1f:	39 d0                	cmp    %edx,%eax
f0101e21:	74 24                	je     f0101e47 <mem_init+0xad6>
f0101e23:	c7 44 24 0c 18 72 10 	movl   $0xf0107218,0xc(%esp)
f0101e2a:	f0 
f0101e2b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101e32:	f0 
f0101e33:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101e3a:	00 
f0101e3b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101e42:	e8 f9 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e47:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e4c:	74 24                	je     f0101e72 <mem_init+0xb01>
f0101e4e:	c7 44 24 0c ad 7a 10 	movl   $0xf0107aad,0xc(%esp)
f0101e55:	f0 
f0101e56:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101e5d:	f0 
f0101e5e:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101e65:	00 
f0101e66:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101e6d:	e8 ce e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e79:	e8 eb f0 ff ff       	call   f0100f69 <page_alloc>
f0101e7e:	85 c0                	test   %eax,%eax
f0101e80:	74 24                	je     f0101ea6 <mem_init+0xb35>
f0101e82:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f0101e89:	f0 
f0101e8a:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101e91:	f0 
f0101e92:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101e99:	00 
f0101e9a:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101ea1:	e8 9a e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ea6:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0101eac:	8b 02                	mov    (%edx),%eax
f0101eae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101eb3:	89 c1                	mov    %eax,%ecx
f0101eb5:	c1 e9 0c             	shr    $0xc,%ecx
f0101eb8:	3b 0d 88 ce 22 f0    	cmp    0xf022ce88,%ecx
f0101ebe:	72 20                	jb     f0101ee0 <mem_init+0xb6f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ec0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ec4:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0101ecb:	f0 
f0101ecc:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0101ed3:	00 
f0101ed4:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101edb:	e8 60 e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101ee0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ee5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ee8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101eef:	00 
f0101ef0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ef7:	00 
f0101ef8:	89 14 24             	mov    %edx,(%esp)
f0101efb:	e8 50 f1 ff ff       	call   f0101050 <pgdir_walk>
f0101f00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f03:	83 c2 04             	add    $0x4,%edx
f0101f06:	39 d0                	cmp    %edx,%eax
f0101f08:	74 24                	je     f0101f2e <mem_init+0xbbd>
f0101f0a:	c7 44 24 0c 48 72 10 	movl   $0xf0107248,0xc(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101f19:	f0 
f0101f1a:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101f21:	00 
f0101f22:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101f29:	e8 12 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f35:	00 
f0101f36:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f3d:	00 
f0101f3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f42:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0101f47:	89 04 24             	mov    %eax,(%esp)
f0101f4a:	e8 10 f3 ff ff       	call   f010125f <page_insert>
f0101f4f:	85 c0                	test   %eax,%eax
f0101f51:	74 24                	je     f0101f77 <mem_init+0xc06>
f0101f53:	c7 44 24 0c 88 72 10 	movl   $0xf0107288,0xc(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101f62:	f0 
f0101f63:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101f6a:	00 
f0101f6b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101f72:	e8 c9 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f77:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f0101f7d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f80:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f85:	89 c8                	mov    %ecx,%eax
f0101f87:	e8 da ea ff ff       	call   f0100a66 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f8c:	89 da                	mov    %ebx,%edx
f0101f8e:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0101f94:	c1 fa 03             	sar    $0x3,%edx
f0101f97:	c1 e2 0c             	shl    $0xc,%edx
f0101f9a:	39 d0                	cmp    %edx,%eax
f0101f9c:	74 24                	je     f0101fc2 <mem_init+0xc51>
f0101f9e:	c7 44 24 0c 18 72 10 	movl   $0xf0107218,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fc2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fc7:	74 24                	je     f0101fed <mem_init+0xc7c>
f0101fc9:	c7 44 24 0c ad 7a 10 	movl   $0xf0107aad,0xc(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0101fd8:	f0 
f0101fd9:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101fe0:	00 
f0101fe1:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0101fe8:	e8 53 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ff4:	00 
f0101ff5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ffc:	00 
f0101ffd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102000:	89 04 24             	mov    %eax,(%esp)
f0102003:	e8 48 f0 ff ff       	call   f0101050 <pgdir_walk>
f0102008:	f6 00 04             	testb  $0x4,(%eax)
f010200b:	75 24                	jne    f0102031 <mem_init+0xcc0>
f010200d:	c7 44 24 0c c8 72 10 	movl   $0xf01072c8,0xc(%esp)
f0102014:	f0 
f0102015:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010201c:	f0 
f010201d:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102024:	00 
f0102025:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010202c:	e8 0f e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102031:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102036:	f6 00 04             	testb  $0x4,(%eax)
f0102039:	75 24                	jne    f010205f <mem_init+0xcee>
f010203b:	c7 44 24 0c be 7a 10 	movl   $0xf0107abe,0xc(%esp)
f0102042:	f0 
f0102043:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010204a:	f0 
f010204b:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102052:	00 
f0102053:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010205a:	e8 e1 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010205f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102066:	00 
f0102067:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010206e:	00 
f010206f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102073:	89 04 24             	mov    %eax,(%esp)
f0102076:	e8 e4 f1 ff ff       	call   f010125f <page_insert>
f010207b:	85 c0                	test   %eax,%eax
f010207d:	74 24                	je     f01020a3 <mem_init+0xd32>
f010207f:	c7 44 24 0c dc 71 10 	movl   $0xf01071dc,0xc(%esp)
f0102086:	f0 
f0102087:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010208e:	f0 
f010208f:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102096:	00 
f0102097:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010209e:	e8 9d df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020aa:	00 
f01020ab:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020b2:	00 
f01020b3:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01020b8:	89 04 24             	mov    %eax,(%esp)
f01020bb:	e8 90 ef ff ff       	call   f0101050 <pgdir_walk>
f01020c0:	f6 00 02             	testb  $0x2,(%eax)
f01020c3:	75 24                	jne    f01020e9 <mem_init+0xd78>
f01020c5:	c7 44 24 0c fc 72 10 	movl   $0xf01072fc,0xc(%esp)
f01020cc:	f0 
f01020cd:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01020d4:	f0 
f01020d5:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01020dc:	00 
f01020dd:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01020e4:	e8 57 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020f0:	00 
f01020f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020f8:	00 
f01020f9:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01020fe:	89 04 24             	mov    %eax,(%esp)
f0102101:	e8 4a ef ff ff       	call   f0101050 <pgdir_walk>
f0102106:	f6 00 04             	testb  $0x4,(%eax)
f0102109:	74 24                	je     f010212f <mem_init+0xdbe>
f010210b:	c7 44 24 0c 30 73 10 	movl   $0xf0107330,0xc(%esp)
f0102112:	f0 
f0102113:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010211a:	f0 
f010211b:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102122:	00 
f0102123:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010212f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102136:	00 
f0102137:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010213e:	00 
f010213f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102143:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102148:	89 04 24             	mov    %eax,(%esp)
f010214b:	e8 0f f1 ff ff       	call   f010125f <page_insert>
f0102150:	85 c0                	test   %eax,%eax
f0102152:	78 24                	js     f0102178 <mem_init+0xe07>
f0102154:	c7 44 24 0c 68 73 10 	movl   $0xf0107368,0xc(%esp)
f010215b:	f0 
f010215c:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102163:	f0 
f0102164:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f010216b:	00 
f010216c:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102173:	e8 c8 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102178:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010217f:	00 
f0102180:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102187:	00 
f0102188:	89 74 24 04          	mov    %esi,0x4(%esp)
f010218c:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102191:	89 04 24             	mov    %eax,(%esp)
f0102194:	e8 c6 f0 ff ff       	call   f010125f <page_insert>
f0102199:	85 c0                	test   %eax,%eax
f010219b:	74 24                	je     f01021c1 <mem_init+0xe50>
f010219d:	c7 44 24 0c a0 73 10 	movl   $0xf01073a0,0xc(%esp)
f01021a4:	f0 
f01021a5:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01021ac:	f0 
f01021ad:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01021b4:	00 
f01021b5:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01021bc:	e8 7f de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021c8:	00 
f01021c9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021d0:	00 
f01021d1:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01021d6:	89 04 24             	mov    %eax,(%esp)
f01021d9:	e8 72 ee ff ff       	call   f0101050 <pgdir_walk>
f01021de:	f6 00 04             	testb  $0x4,(%eax)
f01021e1:	74 24                	je     f0102207 <mem_init+0xe96>
f01021e3:	c7 44 24 0c 30 73 10 	movl   $0xf0107330,0xc(%esp)
f01021ea:	f0 
f01021eb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01021f2:	f0 
f01021f3:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01021fa:	00 
f01021fb:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102202:	e8 39 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102207:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010220c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010220f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102214:	e8 4d e8 ff ff       	call   f0100a66 <check_va2pa>
f0102219:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010221c:	89 f0                	mov    %esi,%eax
f010221e:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0102224:	c1 f8 03             	sar    $0x3,%eax
f0102227:	c1 e0 0c             	shl    $0xc,%eax
f010222a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010222d:	74 24                	je     f0102253 <mem_init+0xee2>
f010222f:	c7 44 24 0c dc 73 10 	movl   $0xf01073dc,0xc(%esp)
f0102236:	f0 
f0102237:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010223e:	f0 
f010223f:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102246:	00 
f0102247:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010224e:	e8 ed dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102253:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010225b:	e8 06 e8 ff ff       	call   f0100a66 <check_va2pa>
f0102260:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102263:	74 24                	je     f0102289 <mem_init+0xf18>
f0102265:	c7 44 24 0c 08 74 10 	movl   $0xf0107408,0xc(%esp)
f010226c:	f0 
f010226d:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102274:	f0 
f0102275:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010227c:	00 
f010227d:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102284:	e8 b7 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102289:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010228e:	74 24                	je     f01022b4 <mem_init+0xf43>
f0102290:	c7 44 24 0c d4 7a 10 	movl   $0xf0107ad4,0xc(%esp)
f0102297:	f0 
f0102298:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01022af:	e8 8c dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022b4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b9:	74 24                	je     f01022df <mem_init+0xf6e>
f01022bb:	c7 44 24 0c e5 7a 10 	movl   $0xf0107ae5,0xc(%esp)
f01022c2:	f0 
f01022c3:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01022ca:	f0 
f01022cb:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01022d2:	00 
f01022d3:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022e6:	e8 7e ec ff ff       	call   f0100f69 <page_alloc>
f01022eb:	85 c0                	test   %eax,%eax
f01022ed:	74 04                	je     f01022f3 <mem_init+0xf82>
f01022ef:	39 c3                	cmp    %eax,%ebx
f01022f1:	74 24                	je     f0102317 <mem_init+0xfa6>
f01022f3:	c7 44 24 0c 38 74 10 	movl   $0xf0107438,0xc(%esp)
f01022fa:	f0 
f01022fb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102302:	f0 
f0102303:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f010230a:	00 
f010230b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102312:	e8 29 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102317:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010231e:	00 
f010231f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102324:	89 04 24             	mov    %eax,(%esp)
f0102327:	e8 d3 ee ff ff       	call   f01011ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010232c:	8b 15 8c ce 22 f0    	mov    0xf022ce8c,%edx
f0102332:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102335:	ba 00 00 00 00       	mov    $0x0,%edx
f010233a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010233d:	e8 24 e7 ff ff       	call   f0100a66 <check_va2pa>
f0102342:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102345:	74 24                	je     f010236b <mem_init+0xffa>
f0102347:	c7 44 24 0c 5c 74 10 	movl   $0xf010745c,0xc(%esp)
f010234e:	f0 
f010234f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102356:	f0 
f0102357:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010235e:	00 
f010235f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102366:	e8 d5 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010236b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102370:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102373:	e8 ee e6 ff ff       	call   f0100a66 <check_va2pa>
f0102378:	89 f2                	mov    %esi,%edx
f010237a:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102380:	c1 fa 03             	sar    $0x3,%edx
f0102383:	c1 e2 0c             	shl    $0xc,%edx
f0102386:	39 d0                	cmp    %edx,%eax
f0102388:	74 24                	je     f01023ae <mem_init+0x103d>
f010238a:	c7 44 24 0c 08 74 10 	movl   $0xf0107408,0xc(%esp)
f0102391:	f0 
f0102392:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102399:	f0 
f010239a:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01023a1:	00 
f01023a2:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01023a9:	e8 92 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023ae:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023b3:	74 24                	je     f01023d9 <mem_init+0x1068>
f01023b5:	c7 44 24 0c 8b 7a 10 	movl   $0xf0107a8b,0xc(%esp)
f01023bc:	f0 
f01023bd:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01023c4:	f0 
f01023c5:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01023cc:	00 
f01023cd:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01023d4:	e8 67 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023d9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023de:	74 24                	je     f0102404 <mem_init+0x1093>
f01023e0:	c7 44 24 0c e5 7a 10 	movl   $0xf0107ae5,0xc(%esp)
f01023e7:	f0 
f01023e8:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01023ef:	f0 
f01023f0:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f01023f7:	00 
f01023f8:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01023ff:	e8 3c dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102404:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010240b:	00 
f010240c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102413:	00 
f0102414:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102418:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010241b:	89 0c 24             	mov    %ecx,(%esp)
f010241e:	e8 3c ee ff ff       	call   f010125f <page_insert>
f0102423:	85 c0                	test   %eax,%eax
f0102425:	74 24                	je     f010244b <mem_init+0x10da>
f0102427:	c7 44 24 0c 80 74 10 	movl   $0xf0107480,0xc(%esp)
f010242e:	f0 
f010242f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102436:	f0 
f0102437:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010243e:	00 
f010243f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102446:	e8 f5 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010244b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102450:	75 24                	jne    f0102476 <mem_init+0x1105>
f0102452:	c7 44 24 0c f6 7a 10 	movl   $0xf0107af6,0xc(%esp)
f0102459:	f0 
f010245a:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102461:	f0 
f0102462:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0102469:	00 
f010246a:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102471:	e8 ca db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102476:	83 3e 00             	cmpl   $0x0,(%esi)
f0102479:	74 24                	je     f010249f <mem_init+0x112e>
f010247b:	c7 44 24 0c 02 7b 10 	movl   $0xf0107b02,0xc(%esp)
f0102482:	f0 
f0102483:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010248a:	f0 
f010248b:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102492:	00 
f0102493:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010249a:	e8 a1 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010249f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024a6:	00 
f01024a7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01024ac:	89 04 24             	mov    %eax,(%esp)
f01024af:	e8 4b ed ff ff       	call   f01011ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024b4:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01024b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01024c1:	e8 a0 e5 ff ff       	call   f0100a66 <check_va2pa>
f01024c6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c9:	74 24                	je     f01024ef <mem_init+0x117e>
f01024cb:	c7 44 24 0c 5c 74 10 	movl   $0xf010745c,0xc(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01024da:	f0 
f01024db:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01024e2:	00 
f01024e3:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01024ea:	e8 51 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024ef:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f7:	e8 6a e5 ff ff       	call   f0100a66 <check_va2pa>
f01024fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024ff:	74 24                	je     f0102525 <mem_init+0x11b4>
f0102501:	c7 44 24 0c b8 74 10 	movl   $0xf01074b8,0xc(%esp)
f0102508:	f0 
f0102509:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102510:	f0 
f0102511:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0102518:	00 
f0102519:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102520:	e8 1b db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102525:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010252a:	74 24                	je     f0102550 <mem_init+0x11df>
f010252c:	c7 44 24 0c 17 7b 10 	movl   $0xf0107b17,0xc(%esp)
f0102533:	f0 
f0102534:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010253b:	f0 
f010253c:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102543:	00 
f0102544:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102550:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102555:	74 24                	je     f010257b <mem_init+0x120a>
f0102557:	c7 44 24 0c e5 7a 10 	movl   $0xf0107ae5,0xc(%esp)
f010255e:	f0 
f010255f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102566:	f0 
f0102567:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f010256e:	00 
f010256f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010257b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102582:	e8 e2 e9 ff ff       	call   f0100f69 <page_alloc>
f0102587:	85 c0                	test   %eax,%eax
f0102589:	74 04                	je     f010258f <mem_init+0x121e>
f010258b:	39 c6                	cmp    %eax,%esi
f010258d:	74 24                	je     f01025b3 <mem_init+0x1242>
f010258f:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f0102596:	f0 
f0102597:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010259e:	f0 
f010259f:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01025a6:	00 
f01025a7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01025b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025ba:	e8 aa e9 ff ff       	call   f0100f69 <page_alloc>
f01025bf:	85 c0                	test   %eax,%eax
f01025c1:	74 24                	je     f01025e7 <mem_init+0x1276>
f01025c3:	c7 44 24 0c 39 7a 10 	movl   $0xf0107a39,0xc(%esp)
f01025ca:	f0 
f01025cb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01025d2:	f0 
f01025d3:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01025da:	00 
f01025db:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025e7:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01025ec:	8b 08                	mov    (%eax),%ecx
f01025ee:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025f4:	89 fa                	mov    %edi,%edx
f01025f6:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01025fc:	c1 fa 03             	sar    $0x3,%edx
f01025ff:	c1 e2 0c             	shl    $0xc,%edx
f0102602:	39 d1                	cmp    %edx,%ecx
f0102604:	74 24                	je     f010262a <mem_init+0x12b9>
f0102606:	c7 44 24 0c 84 71 10 	movl   $0xf0107184,0xc(%esp)
f010260d:	f0 
f010260e:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102615:	f0 
f0102616:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f010261d:	00 
f010261e:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102625:	e8 16 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010262a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102630:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102635:	74 24                	je     f010265b <mem_init+0x12ea>
f0102637:	c7 44 24 0c 9c 7a 10 	movl   $0xf0107a9c,0xc(%esp)
f010263e:	f0 
f010263f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102646:	f0 
f0102647:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f010264e:	00 
f010264f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102656:	e8 e5 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010265b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102661:	89 3c 24             	mov    %edi,(%esp)
f0102664:	e8 84 e9 ff ff       	call   f0100fed <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102669:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102670:	00 
f0102671:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102678:	00 
f0102679:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010267e:	89 04 24             	mov    %eax,(%esp)
f0102681:	e8 ca e9 ff ff       	call   f0101050 <pgdir_walk>
f0102686:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102689:	8b 0d 8c ce 22 f0    	mov    0xf022ce8c,%ecx
f010268f:	8b 51 04             	mov    0x4(%ecx),%edx
f0102692:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102698:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010269b:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
f01026a1:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01026a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026a7:	c1 ea 0c             	shr    $0xc,%edx
f01026aa:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01026ad:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01026b0:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01026b3:	72 23                	jb     f01026d8 <mem_init+0x1367>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01026b8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01026bc:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01026c3:	f0 
f01026c4:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f01026cb:	00 
f01026cc:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01026d3:	e8 68 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026db:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01026e1:	39 d0                	cmp    %edx,%eax
f01026e3:	74 24                	je     f0102709 <mem_init+0x1398>
f01026e5:	c7 44 24 0c 28 7b 10 	movl   $0xf0107b28,0xc(%esp)
f01026ec:	f0 
f01026ed:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01026f4:	f0 
f01026f5:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f01026fc:	00 
f01026fd:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102704:	e8 37 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102709:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102710:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102716:	89 f8                	mov    %edi,%eax
f0102718:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f010271e:	c1 f8 03             	sar    $0x3,%eax
f0102721:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102724:	89 c1                	mov    %eax,%ecx
f0102726:	c1 e9 0c             	shr    $0xc,%ecx
f0102729:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010272c:	77 20                	ja     f010274e <mem_init+0x13dd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010272e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102732:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0102739:	f0 
f010273a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102741:	00 
f0102742:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0102749:	e8 f2 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010274e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102755:	00 
f0102756:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010275d:	00 
	return (void *)(pa + KERNBASE);
f010275e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102763:	89 04 24             	mov    %eax,(%esp)
f0102766:	e8 88 35 00 00       	call   f0105cf3 <memset>
	page_free(pp0);
f010276b:	89 3c 24             	mov    %edi,(%esp)
f010276e:	e8 7a e8 ff ff       	call   f0100fed <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102773:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010277a:	00 
f010277b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102782:	00 
f0102783:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102788:	89 04 24             	mov    %eax,(%esp)
f010278b:	e8 c0 e8 ff ff       	call   f0101050 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102790:	89 fa                	mov    %edi,%edx
f0102792:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0102798:	c1 fa 03             	sar    $0x3,%edx
f010279b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010279e:	89 d0                	mov    %edx,%eax
f01027a0:	c1 e8 0c             	shr    $0xc,%eax
f01027a3:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f01027a9:	72 20                	jb     f01027cb <mem_init+0x145a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027af:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01027b6:	f0 
f01027b7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027be:	00 
f01027bf:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f01027c6:	e8 75 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01027cb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01027d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027d4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01027da:	f6 00 01             	testb  $0x1,(%eax)
f01027dd:	74 24                	je     f0102803 <mem_init+0x1492>
f01027df:	c7 44 24 0c 40 7b 10 	movl   $0xf0107b40,0xc(%esp)
f01027e6:	f0 
f01027e7:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01027ee:	f0 
f01027ef:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01027f6:	00 
f01027f7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01027fe:	e8 3d d8 ff ff       	call   f0100040 <_panic>
f0102803:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102806:	39 d0                	cmp    %edx,%eax
f0102808:	75 d0                	jne    f01027da <mem_init+0x1469>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010280a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f010280f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102815:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010281b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010281e:	89 0d 40 c2 22 f0    	mov    %ecx,0xf022c240

	// free the pages we took
	page_free(pp0);
f0102824:	89 3c 24             	mov    %edi,(%esp)
f0102827:	e8 c1 e7 ff ff       	call   f0100fed <page_free>
	page_free(pp1);
f010282c:	89 34 24             	mov    %esi,(%esp)
f010282f:	e8 b9 e7 ff ff       	call   f0100fed <page_free>
	page_free(pp2);
f0102834:	89 1c 24             	mov    %ebx,(%esp)
f0102837:	e8 b1 e7 ff ff       	call   f0100fed <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010283c:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102843:	00 
f0102844:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010284b:	e8 ad ea ff ff       	call   f01012fd <mmio_map_region>
f0102850:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102852:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102859:	00 
f010285a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102861:	e8 97 ea ff ff       	call   f01012fd <mmio_map_region>
f0102866:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102868:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010286e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102874:	76 07                	jbe    f010287d <mem_init+0x150c>
f0102876:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010287b:	76 24                	jbe    f01028a1 <mem_init+0x1530>
f010287d:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f0102884:	f0 
f0102885:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010288c:	f0 
f010288d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102894:	00 
f0102895:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010289c:	e8 9f d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01028a1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01028a7:	76 0e                	jbe    f01028b7 <mem_init+0x1546>
f01028a9:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01028af:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01028b5:	76 24                	jbe    f01028db <mem_init+0x156a>
f01028b7:	c7 44 24 0c 2c 75 10 	movl   $0xf010752c,0xc(%esp)
f01028be:	f0 
f01028bf:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01028c6:	f0 
f01028c7:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028ce:	00 
f01028cf:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01028d6:	e8 65 d7 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028db:	89 da                	mov    %ebx,%edx
f01028dd:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028df:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01028e5:	74 24                	je     f010290b <mem_init+0x159a>
f01028e7:	c7 44 24 0c 54 75 10 	movl   $0xf0107554,0xc(%esp)
f01028ee:	f0 
f01028ef:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01028f6:	f0 
f01028f7:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01028fe:	00 
f01028ff:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102906:	e8 35 d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010290b:	39 c6                	cmp    %eax,%esi
f010290d:	73 24                	jae    f0102933 <mem_init+0x15c2>
f010290f:	c7 44 24 0c 57 7b 10 	movl   $0xf0107b57,0xc(%esp)
f0102916:	f0 
f0102917:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010291e:	f0 
f010291f:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102926:	00 
f0102927:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010292e:	e8 0d d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102933:	8b 3d 8c ce 22 f0    	mov    0xf022ce8c,%edi
f0102939:	89 da                	mov    %ebx,%edx
f010293b:	89 f8                	mov    %edi,%eax
f010293d:	e8 24 e1 ff ff       	call   f0100a66 <check_va2pa>
f0102942:	85 c0                	test   %eax,%eax
f0102944:	74 24                	je     f010296a <mem_init+0x15f9>
f0102946:	c7 44 24 0c 7c 75 10 	movl   $0xf010757c,0xc(%esp)
f010294d:	f0 
f010294e:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102955:	f0 
f0102956:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f010295d:	00 
f010295e:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102965:	e8 d6 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010296a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102970:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102973:	89 c2                	mov    %eax,%edx
f0102975:	89 f8                	mov    %edi,%eax
f0102977:	e8 ea e0 ff ff       	call   f0100a66 <check_va2pa>
f010297c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102981:	74 24                	je     f01029a7 <mem_init+0x1636>
f0102983:	c7 44 24 0c a0 75 10 	movl   $0xf01075a0,0xc(%esp)
f010298a:	f0 
f010298b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102992:	f0 
f0102993:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f010299a:	00 
f010299b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01029a2:	e8 99 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029a7:	89 f2                	mov    %esi,%edx
f01029a9:	89 f8                	mov    %edi,%eax
f01029ab:	e8 b6 e0 ff ff       	call   f0100a66 <check_va2pa>
f01029b0:	85 c0                	test   %eax,%eax
f01029b2:	74 24                	je     f01029d8 <mem_init+0x1667>
f01029b4:	c7 44 24 0c d0 75 10 	movl   $0xf01075d0,0xc(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01029c3:	f0 
f01029c4:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01029cb:	00 
f01029cc:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01029d3:	e8 68 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01029d8:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01029de:	89 f8                	mov    %edi,%eax
f01029e0:	e8 81 e0 ff ff       	call   f0100a66 <check_va2pa>
f01029e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e8:	74 24                	je     f0102a0e <mem_init+0x169d>
f01029ea:	c7 44 24 0c f4 75 10 	movl   $0xf01075f4,0xc(%esp)
f01029f1:	f0 
f01029f2:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01029f9:	f0 
f01029fa:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102a01:	00 
f0102a02:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102a09:	e8 32 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a15:	00 
f0102a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a1a:	89 3c 24             	mov    %edi,(%esp)
f0102a1d:	e8 2e e6 ff ff       	call   f0101050 <pgdir_walk>
f0102a22:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a25:	75 24                	jne    f0102a4b <mem_init+0x16da>
f0102a27:	c7 44 24 0c 20 76 10 	movl   $0xf0107620,0xc(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a3e:	00 
f0102a3f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102a46:	e8 f5 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a52:	00 
f0102a53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a57:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102a5c:	89 04 24             	mov    %eax,(%esp)
f0102a5f:	e8 ec e5 ff ff       	call   f0101050 <pgdir_walk>
f0102a64:	f6 00 04             	testb  $0x4,(%eax)
f0102a67:	74 24                	je     f0102a8d <mem_init+0x171c>
f0102a69:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f0102a70:	f0 
f0102a71:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a80:	00 
f0102a81:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102a88:	e8 b3 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a94:	00 
f0102a95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a99:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102a9e:	89 04 24             	mov    %eax,(%esp)
f0102aa1:	e8 aa e5 ff ff       	call   f0101050 <pgdir_walk>
f0102aa6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102aac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ab3:	00 
f0102ab4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102ab7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102abb:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102ac0:	89 04 24             	mov    %eax,(%esp)
f0102ac3:	e8 88 e5 ff ff       	call   f0101050 <pgdir_walk>
f0102ac8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102ace:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ad5:	00 
f0102ad6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ada:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102adf:	89 04 24             	mov    %eax,(%esp)
f0102ae2:	e8 69 e5 ff ff       	call   f0101050 <pgdir_walk>
f0102ae7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102aed:	c7 04 24 69 7b 10 f0 	movl   $0xf0107b69,(%esp)
f0102af4:	e8 95 14 00 00       	call   f0103f8e <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102af9:	8b 15 88 ce 22 f0    	mov    0xf022ce88,%edx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102aff:	a1 90 ce 22 f0       	mov    0xf022ce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b04:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b09:	77 20                	ja     f0102b2b <mem_init+0x17ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b0f:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102b16:	f0 
f0102b17:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102b1e:	00 
f0102b1f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102b26:	e8 15 d5 ff ff       	call   f0100040 <_panic>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b2b:	8d 1c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ebx
f0102b32:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b38:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102b3f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b40:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b45:	89 04 24             	mov    %eax,(%esp)
f0102b48:	89 d9                	mov    %ebx,%ecx
f0102b4a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b4f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102b54:	e8 9e e5 ff ff       	call   f01010f7 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102b59:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b5f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102b65:	77 20                	ja     f0102b87 <mem_init+0x1816>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b6b:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102b72:	f0 
f0102b73:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102b7a:	00 
f0102b7b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102b82:	e8 b9 d4 ff ff       	call   f0100040 <_panic>
f0102b87:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102b8e:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b8f:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102b95:	89 04 24             	mov    %eax,(%esp)
f0102b98:	89 d9                	mov    %ebx,%ecx
f0102b9a:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102b9f:	e8 53 e5 ff ff       	call   f01010f7 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102ba4:	a1 48 c2 22 f0       	mov    0xf022c248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ba9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bae:	77 20                	ja     f0102bd0 <mem_init+0x185f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bb4:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102bbb:	f0 
f0102bbc:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102bc3:	00 
f0102bc4:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102bcb:	e8 70 d4 ff ff       	call   f0100040 <_panic>
f0102bd0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bd7:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bd8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bdd:	89 04 24             	mov    %eax,(%esp)
f0102be0:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102be5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102bea:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102bef:	e8 03 e5 ff ff       	call   f01010f7 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102bf4:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bfa:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c00:	77 20                	ja     f0102c22 <mem_init+0x18b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c02:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c06:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102c0d:	f0 
f0102c0e:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102c15:	00 
f0102c16:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102c1d:	e8 1e d4 ff ff       	call   f0100040 <_panic>
f0102c22:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c29:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c2a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c30:	89 04 24             	mov    %eax,(%esp)
f0102c33:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c38:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102c3d:	e8 b5 e4 ff ff       	call   f01010f7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c42:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102c47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c4c:	77 20                	ja     f0102c6e <mem_init+0x18fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c52:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102c59:	f0 
f0102c5a:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102c61:	00 
f0102c62:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102c69:	e8 d2 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102c6e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c75:	00 
f0102c76:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102c7d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c82:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102c87:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102c8c:	e8 66 e4 ff ff       	call   f01010f7 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102c91:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c98:	00 
f0102c99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ca0:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ca5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102caa:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102caf:	e8 43 e4 ff ff       	call   f01010f7 <boot_map_region>
f0102cb4:	c7 45 cc 00 e0 22 f0 	movl   $0xf022e000,-0x34(%ebp)
f0102cbb:	bb 00 e0 22 f0       	mov    $0xf022e000,%ebx
f0102cc0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cc5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ccb:	77 20                	ja     f0102ced <mem_init+0x197c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ccd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cd1:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102cd8:	f0 
f0102cd9:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102ce0:	00 
f0102ce1:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102ce8:	e8 53 d3 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102ced:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102cf4:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cf5:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
		kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region(kern_pgdir,
f0102cfb:	89 04 24             	mov    %eax,(%esp)
f0102cfe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d03:	89 f2                	mov    %esi,%edx
f0102d05:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0102d0a:	e8 e8 e3 ff ff       	call   f01010f7 <boot_map_region>
f0102d0f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d15:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int kstacktop_i = 0;
	int  i = 0;
	for(; i<NCPU; ++i){
f0102d1b:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d21:	75 a2                	jne    f0102cc5 <mem_init+0x1954>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d23:	8b 1d 8c ce 22 f0    	mov    0xf022ce8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d29:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f0102d2f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d32:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d39:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d3f:	be 00 00 00 00       	mov    $0x0,%esi
f0102d44:	eb 70                	jmp    f0102db6 <mem_init+0x1a45>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d46:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d4c:	89 d8                	mov    %ebx,%eax
f0102d4e:	e8 13 dd ff ff       	call   f0100a66 <check_va2pa>
f0102d53:	8b 15 90 ce 22 f0    	mov    0xf022ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d59:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d5f:	77 20                	ja     f0102d81 <mem_init+0x1a10>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d61:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d65:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102d6c:	f0 
f0102d6d:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102d74:	00 
f0102d75:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102d7c:	e8 bf d2 ff ff       	call   f0100040 <_panic>
f0102d81:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d88:	39 d0                	cmp    %edx,%eax
f0102d8a:	74 24                	je     f0102db0 <mem_init+0x1a3f>
f0102d8c:	c7 44 24 0c 98 76 10 	movl   $0xf0107698,0xc(%esp)
f0102d93:	f0 
f0102d94:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102d9b:	f0 
f0102d9c:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102da3:	00 
f0102da4:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102dab:	e8 90 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102db0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102db6:	39 f7                	cmp    %esi,%edi
f0102db8:	77 8c                	ja     f0102d46 <mem_init+0x19d5>
f0102dba:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dbf:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102dc5:	89 d8                	mov    %ebx,%eax
f0102dc7:	e8 9a dc ff ff       	call   f0100a66 <check_va2pa>
f0102dcc:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102dd8:	77 20                	ja     f0102dfa <mem_init+0x1a89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dda:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102dde:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102de5:	f0 
f0102de6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ded:	00 
f0102dee:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102df5:	e8 46 d2 ff ff       	call   f0100040 <_panic>
f0102dfa:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102e01:	39 d0                	cmp    %edx,%eax
f0102e03:	74 24                	je     f0102e29 <mem_init+0x1ab8>
f0102e05:	c7 44 24 0c cc 76 10 	movl   $0xf01076cc,0xc(%esp)
f0102e0c:	f0 
f0102e0d:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102e14:	f0 
f0102e15:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e1c:	00 
f0102e1d:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102e24:	e8 17 d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e29:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e2f:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e35:	75 88                	jne    f0102dbf <mem_init+0x1a4e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e37:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e3a:	c1 e7 0c             	shl    $0xc,%edi
f0102e3d:	be 00 00 00 00       	mov    $0x0,%esi
f0102e42:	eb 3b                	jmp    f0102e7f <mem_init+0x1b0e>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e44:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e4a:	89 d8                	mov    %ebx,%eax
f0102e4c:	e8 15 dc ff ff       	call   f0100a66 <check_va2pa>
f0102e51:	39 c6                	cmp    %eax,%esi
f0102e53:	74 24                	je     f0102e79 <mem_init+0x1b08>
f0102e55:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f0102e5c:	f0 
f0102e5d:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102e64:	f0 
f0102e65:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102e6c:	00 
f0102e6d:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102e74:	e8 c7 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e79:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e7f:	39 fe                	cmp    %edi,%esi
f0102e81:	72 c1                	jb     f0102e44 <mem_init+0x1ad3>
f0102e83:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f0102e8a:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e8c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e8f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e92:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e95:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e9b:	89 c6                	mov    %eax,%esi
f0102e9d:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102ea3:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102ea6:	81 c2 00 00 01 00    	add    $0x10000,%edx
f0102eac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102eaf:	89 da                	mov    %ebx,%edx
f0102eb1:	89 f8                	mov    %edi,%eax
f0102eb3:	e8 ae db ff ff       	call   f0100a66 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eb8:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ebf:	77 23                	ja     f0102ee4 <mem_init+0x1b73>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ec4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ec8:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0102ecf:	f0 
f0102ed0:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102ed7:	00 
f0102ed8:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102edf:	e8 5c d1 ff ff       	call   f0100040 <_panic>
f0102ee4:	39 f0                	cmp    %esi,%eax
f0102ee6:	74 24                	je     f0102f0c <mem_init+0x1b9b>
f0102ee8:	c7 44 24 0c 28 77 10 	movl   $0xf0107728,0xc(%esp)
f0102eef:	f0 
f0102ef0:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102ef7:	f0 
f0102ef8:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102eff:	00 
f0102f00:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102f07:	e8 34 d1 ff ff       	call   f0100040 <_panic>
f0102f0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f12:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f18:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102f1b:	0f 85 58 05 00 00    	jne    f0103479 <mem_init+0x2108>
f0102f21:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f26:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f29:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f2c:	89 f8                	mov    %edi,%eax
f0102f2e:	e8 33 db ff ff       	call   f0100a66 <check_va2pa>
f0102f33:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f36:	74 24                	je     f0102f5c <mem_init+0x1beb>
f0102f38:	c7 44 24 0c 70 77 10 	movl   $0xf0107770,0xc(%esp)
f0102f3f:	f0 
f0102f40:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102f47:	f0 
f0102f48:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102f4f:	00 
f0102f50:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102f57:	e8 e4 d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f5c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f62:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f68:	75 bf                	jne    f0102f29 <mem_init+0x1bb8>
f0102f6a:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0102f71:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f78:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0102f7f:	0f 85 07 ff ff ff    	jne    f0102e8c <mem_init+0x1b1b>
f0102f85:	89 fb                	mov    %edi,%ebx
f0102f87:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f8c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f92:	83 fa 04             	cmp    $0x4,%edx
f0102f95:	77 2e                	ja     f0102fc5 <mem_init+0x1c54>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102f97:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f9b:	0f 85 aa 00 00 00    	jne    f010304b <mem_init+0x1cda>
f0102fa1:	c7 44 24 0c 82 7b 10 	movl   $0xf0107b82,0xc(%esp)
f0102fa8:	f0 
f0102fa9:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102fb0:	f0 
f0102fb1:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102fb8:	00 
f0102fb9:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102fc0:	e8 7b d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102fc5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fca:	76 55                	jbe    f0103021 <mem_init+0x1cb0>
				assert(pgdir[i] & PTE_P);
f0102fcc:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102fcf:	f6 c2 01             	test   $0x1,%dl
f0102fd2:	75 24                	jne    f0102ff8 <mem_init+0x1c87>
f0102fd4:	c7 44 24 0c 82 7b 10 	movl   $0xf0107b82,0xc(%esp)
f0102fdb:	f0 
f0102fdc:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0102fe3:	f0 
f0102fe4:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102feb:	00 
f0102fec:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0102ff3:	e8 48 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ff8:	f6 c2 02             	test   $0x2,%dl
f0102ffb:	75 4e                	jne    f010304b <mem_init+0x1cda>
f0102ffd:	c7 44 24 0c 93 7b 10 	movl   $0xf0107b93,0xc(%esp)
f0103004:	f0 
f0103005:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010300c:	f0 
f010300d:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0103014:	00 
f0103015:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010301c:	e8 1f d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103021:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103025:	74 24                	je     f010304b <mem_init+0x1cda>
f0103027:	c7 44 24 0c a4 7b 10 	movl   $0xf0107ba4,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010304b:	83 c0 01             	add    $0x1,%eax
f010304e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103053:	0f 85 33 ff ff ff    	jne    f0102f8c <mem_init+0x1c1b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103059:	c7 04 24 94 77 10 f0 	movl   $0xf0107794,(%esp)
f0103060:	e8 29 0f 00 00       	call   f0103f8e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103065:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010306a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010306f:	77 20                	ja     f0103091 <mem_init+0x1d20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103071:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103075:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f010307c:	f0 
f010307d:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103084:	00 
f0103085:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010308c:	e8 af cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103091:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103096:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103099:	b8 00 00 00 00       	mov    $0x0,%eax
f010309e:	e8 66 da ff ff       	call   f0100b09 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030a3:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01030a6:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030ab:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030ae:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030b8:	e8 ac de ff ff       	call   f0100f69 <page_alloc>
f01030bd:	89 c6                	mov    %eax,%esi
f01030bf:	85 c0                	test   %eax,%eax
f01030c1:	75 24                	jne    f01030e7 <mem_init+0x1d76>
f01030c3:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01030d2:	f0 
f01030d3:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01030da:	00 
f01030db:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01030e2:	e8 59 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030ee:	e8 76 de ff ff       	call   f0100f69 <page_alloc>
f01030f3:	89 c7                	mov    %eax,%edi
f01030f5:	85 c0                	test   %eax,%eax
f01030f7:	75 24                	jne    f010311d <mem_init+0x1dac>
f01030f9:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0103100:	f0 
f0103101:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103108:	f0 
f0103109:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103110:	00 
f0103111:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103118:	e8 23 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010311d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103124:	e8 40 de ff ff       	call   f0100f69 <page_alloc>
f0103129:	89 c3                	mov    %eax,%ebx
f010312b:	85 c0                	test   %eax,%eax
f010312d:	75 24                	jne    f0103153 <mem_init+0x1de2>
f010312f:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f0103136:	f0 
f0103137:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010313e:	f0 
f010313f:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0103146:	00 
f0103147:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010314e:	e8 ed ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103153:	89 34 24             	mov    %esi,(%esp)
f0103156:	e8 92 de ff ff       	call   f0100fed <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010315b:	89 f8                	mov    %edi,%eax
f010315d:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103163:	c1 f8 03             	sar    $0x3,%eax
f0103166:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103169:	89 c2                	mov    %eax,%edx
f010316b:	c1 ea 0c             	shr    $0xc,%edx
f010316e:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103174:	72 20                	jb     f0103196 <mem_init+0x1e25>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103176:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010317a:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0103181:	f0 
f0103182:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103189:	00 
f010318a:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0103191:	e8 aa ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103196:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010319d:	00 
f010319e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031a5:	00 
	return (void *)(pa + KERNBASE);
f01031a6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031ab:	89 04 24             	mov    %eax,(%esp)
f01031ae:	e8 40 2b 00 00       	call   f0105cf3 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031b3:	89 d8                	mov    %ebx,%eax
f01031b5:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f01031bb:	c1 f8 03             	sar    $0x3,%eax
f01031be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031c1:	89 c2                	mov    %eax,%edx
f01031c3:	c1 ea 0c             	shr    $0xc,%edx
f01031c6:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f01031cc:	72 20                	jb     f01031ee <mem_init+0x1e7d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031d2:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01031d9:	f0 
f01031da:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031e1:	00 
f01031e2:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f01031e9:	e8 52 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031ee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f5:	00 
f01031f6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031fd:	00 
	return (void *)(pa + KERNBASE);
f01031fe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103203:	89 04 24             	mov    %eax,(%esp)
f0103206:	e8 e8 2a 00 00       	call   f0105cf3 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010320b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103212:	00 
f0103213:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010321a:	00 
f010321b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010321f:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f0103224:	89 04 24             	mov    %eax,(%esp)
f0103227:	e8 33 e0 ff ff       	call   f010125f <page_insert>
	assert(pp1->pp_ref == 1);
f010322c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103231:	74 24                	je     f0103257 <mem_init+0x1ee6>
f0103233:	c7 44 24 0c 8b 7a 10 	movl   $0xf0107a8b,0xc(%esp)
f010323a:	f0 
f010323b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103242:	f0 
f0103243:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f010324a:	00 
f010324b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103252:	e8 e9 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103257:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010325e:	01 01 01 
f0103261:	74 24                	je     f0103287 <mem_init+0x1f16>
f0103263:	c7 44 24 0c b4 77 10 	movl   $0xf01077b4,0xc(%esp)
f010326a:	f0 
f010326b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103272:	f0 
f0103273:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f010327a:	00 
f010327b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103282:	e8 b9 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103287:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010328e:	00 
f010328f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103296:	00 
f0103297:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010329b:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01032a0:	89 04 24             	mov    %eax,(%esp)
f01032a3:	e8 b7 df ff ff       	call   f010125f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032a8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032af:	02 02 02 
f01032b2:	74 24                	je     f01032d8 <mem_init+0x1f67>
f01032b4:	c7 44 24 0c d8 77 10 	movl   $0xf01077d8,0xc(%esp)
f01032bb:	f0 
f01032bc:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01032c3:	f0 
f01032c4:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f01032cb:	00 
f01032cc:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01032d3:	e8 68 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032d8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032dd:	74 24                	je     f0103303 <mem_init+0x1f92>
f01032df:	c7 44 24 0c ad 7a 10 	movl   $0xf0107aad,0xc(%esp)
f01032e6:	f0 
f01032e7:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01032ee:	f0 
f01032ef:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f01032f6:	00 
f01032f7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01032fe:	e8 3d cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103303:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103308:	74 24                	je     f010332e <mem_init+0x1fbd>
f010330a:	c7 44 24 0c 17 7b 10 	movl   $0xf0107b17,0xc(%esp)
f0103311:	f0 
f0103312:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103319:	f0 
f010331a:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0103321:	00 
f0103322:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103329:	e8 12 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010332e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103335:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103338:	89 d8                	mov    %ebx,%eax
f010333a:	2b 05 90 ce 22 f0    	sub    0xf022ce90,%eax
f0103340:	c1 f8 03             	sar    $0x3,%eax
f0103343:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103346:	89 c2                	mov    %eax,%edx
f0103348:	c1 ea 0c             	shr    $0xc,%edx
f010334b:	3b 15 88 ce 22 f0    	cmp    0xf022ce88,%edx
f0103351:	72 20                	jb     f0103373 <mem_init+0x2002>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103353:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103357:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f010335e:	f0 
f010335f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103366:	00 
f0103367:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f010336e:	e8 cd cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103373:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010337a:	03 03 03 
f010337d:	74 24                	je     f01033a3 <mem_init+0x2032>
f010337f:	c7 44 24 0c fc 77 10 	movl   $0xf01077fc,0xc(%esp)
f0103386:	f0 
f0103387:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010338e:	f0 
f010338f:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103396:	00 
f0103397:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f010339e:	e8 9d cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033aa:	00 
f01033ab:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01033b0:	89 04 24             	mov    %eax,(%esp)
f01033b3:	e8 47 de ff ff       	call   f01011ff <page_remove>
	assert(pp2->pp_ref == 0);
f01033b8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033bd:	74 24                	je     f01033e3 <mem_init+0x2072>
f01033bf:	c7 44 24 0c e5 7a 10 	movl   $0xf0107ae5,0xc(%esp)
f01033c6:	f0 
f01033c7:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f01033ce:	f0 
f01033cf:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033d6:	00 
f01033d7:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f01033de:	e8 5d cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033e3:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01033e8:	8b 08                	mov    (%eax),%ecx
f01033ea:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033f0:	89 f2                	mov    %esi,%edx
f01033f2:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f01033f8:	c1 fa 03             	sar    $0x3,%edx
f01033fb:	c1 e2 0c             	shl    $0xc,%edx
f01033fe:	39 d1                	cmp    %edx,%ecx
f0103400:	74 24                	je     f0103426 <mem_init+0x20b5>
f0103402:	c7 44 24 0c 84 71 10 	movl   $0xf0107184,0xc(%esp)
f0103409:	f0 
f010340a:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103411:	f0 
f0103412:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0103419:	00 
f010341a:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103421:	e8 1a cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103426:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010342c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103431:	74 24                	je     f0103457 <mem_init+0x20e6>
f0103433:	c7 44 24 0c 9c 7a 10 	movl   $0xf0107a9c,0xc(%esp)
f010343a:	f0 
f010343b:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0103442:	f0 
f0103443:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f010344a:	00 
f010344b:	c7 04 24 89 78 10 f0 	movl   $0xf0107889,(%esp)
f0103452:	e8 e9 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103457:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010345d:	89 34 24             	mov    %esi,(%esp)
f0103460:	e8 88 db ff ff       	call   f0100fed <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103465:	c7 04 24 28 78 10 f0 	movl   $0xf0107828,(%esp)
f010346c:	e8 1d 0b 00 00       	call   f0103f8e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103471:	83 c4 3c             	add    $0x3c,%esp
f0103474:	5b                   	pop    %ebx
f0103475:	5e                   	pop    %esi
f0103476:	5f                   	pop    %edi
f0103477:	5d                   	pop    %ebp
f0103478:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103479:	89 da                	mov    %ebx,%edx
f010347b:	89 f8                	mov    %edi,%eax
f010347d:	e8 e4 d5 ff ff       	call   f0100a66 <check_va2pa>
f0103482:	e9 5d fa ff ff       	jmp    f0102ee4 <mem_init+0x1b73>

f0103487 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103487:	55                   	push   %ebp
f0103488:	89 e5                	mov    %esp,%ebp
f010348a:	57                   	push   %edi
f010348b:	56                   	push   %esi
f010348c:	53                   	push   %ebx
f010348d:	83 ec 2c             	sub    $0x2c,%esp
f0103490:	8b 75 08             	mov    0x8(%ebp),%esi
f0103493:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103499:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010349f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034a2:	03 45 10             	add    0x10(%ebp),%eax
f01034a5:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034af:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f01034b2:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034b8:	76 5d                	jbe    f0103517 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f01034ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034bd:	a3 44 c2 22 f0       	mov    %eax,0xf022c244
        return -E_FAULT;
f01034c2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034c7:	eb 58                	jmp    f0103521 <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034d0:	00 
f01034d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034d5:	8b 46 60             	mov    0x60(%esi),%eax
f01034d8:	89 04 24             	mov    %eax,(%esp)
f01034db:	e8 70 db ff ff       	call   f0101050 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034e0:	85 c0                	test   %eax,%eax
f01034e2:	74 0c                	je     f01034f0 <user_mem_check+0x69>
f01034e4:	8b 00                	mov    (%eax),%eax
f01034e6:	a8 01                	test   $0x1,%al
f01034e8:	74 06                	je     f01034f0 <user_mem_check+0x69>
f01034ea:	21 f8                	and    %edi,%eax
f01034ec:	39 c7                	cmp    %eax,%edi
f01034ee:	74 21                	je     f0103511 <user_mem_check+0x8a>
        {
            if (addr < va)
f01034f0:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034f3:	76 0f                	jbe    f0103504 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034f5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f8:	a3 44 c2 22 f0       	mov    %eax,0xf022c244
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034fd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103502:	eb 1d                	jmp    f0103521 <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f0103504:	89 1d 44 c2 22 f0    	mov    %ebx,0xf022c244
            }
            
            return -E_FAULT;
f010350a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010350f:	eb 10                	jmp    f0103521 <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f0103511:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103517:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010351a:	72 ad                	jb     f01034c9 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f010351c:	b8 00 00 00 00       	mov    $0x0,%eax

}
f0103521:	83 c4 2c             	add    $0x2c,%esp
f0103524:	5b                   	pop    %ebx
f0103525:	5e                   	pop    %esi
f0103526:	5f                   	pop    %edi
f0103527:	5d                   	pop    %ebp
f0103528:	c3                   	ret    

f0103529 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103529:	55                   	push   %ebp
f010352a:	89 e5                	mov    %esp,%ebp
f010352c:	53                   	push   %ebx
f010352d:	83 ec 14             	sub    $0x14,%esp
f0103530:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103533:	8b 45 14             	mov    0x14(%ebp),%eax
f0103536:	83 c8 04             	or     $0x4,%eax
f0103539:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010353d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103540:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103544:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103547:	89 44 24 04          	mov    %eax,0x4(%esp)
f010354b:	89 1c 24             	mov    %ebx,(%esp)
f010354e:	e8 34 ff ff ff       	call   f0103487 <user_mem_check>
f0103553:	85 c0                	test   %eax,%eax
f0103555:	79 24                	jns    f010357b <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103557:	a1 44 c2 22 f0       	mov    0xf022c244,%eax
f010355c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103560:	8b 43 48             	mov    0x48(%ebx),%eax
f0103563:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103567:	c7 04 24 54 78 10 f0 	movl   $0xf0107854,(%esp)
f010356e:	e8 1b 0a 00 00       	call   f0103f8e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103573:	89 1c 24             	mov    %ebx,(%esp)
f0103576:	e8 18 07 00 00       	call   f0103c93 <env_destroy>
	}
}
f010357b:	83 c4 14             	add    $0x14,%esp
f010357e:	5b                   	pop    %ebx
f010357f:	5d                   	pop    %ebp
f0103580:	c3                   	ret    
f0103581:	66 90                	xchg   %ax,%ax
f0103583:	90                   	nop

f0103584 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103584:	55                   	push   %ebp
f0103585:	89 e5                	mov    %esp,%ebp
f0103587:	57                   	push   %edi
f0103588:	56                   	push   %esi
f0103589:	53                   	push   %ebx
f010358a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f010358d:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f0103590:	89 d3                	mov    %edx,%ebx
f0103592:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103599:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010359e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01035a4:	29 d0                	sub    %edx,%eax
f01035a6:	c1 e8 0c             	shr    $0xc,%eax
f01035a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f01035ac:	be 00 00 00 00       	mov    $0x0,%esi
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01035b1:	eb 6d                	jmp    f0103620 <region_alloc+0x9c>
		struct PageInfo* newPage = page_alloc(0);
f01035b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035ba:	e8 aa d9 ff ff       	call   f0100f69 <page_alloc>
		if(newPage == 0)
f01035bf:	85 c0                	test   %eax,%eax
f01035c1:	75 1c                	jne    f01035df <region_alloc+0x5b>
			panic("there is no more page to region_alloc for env\n");
f01035c3:	c7 44 24 08 b4 7b 10 	movl   $0xf0107bb4,0x8(%esp)
f01035ca:	f0 
f01035cb:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01035d2:	00 
f01035d3:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f01035da:	e8 61 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035df:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035e6:	00 
f01035e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ef:	89 3c 24             	mov    %edi,(%esp)
f01035f2:	e8 68 dc ff ff       	call   f010125f <page_insert>
f01035f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		if(ret)
f01035fd:	85 c0                	test   %eax,%eax
f01035ff:	74 1c                	je     f010361d <region_alloc+0x99>
			panic("page_insert fail\n");
f0103601:	c7 44 24 08 ee 7b 10 	movl   $0xf0107bee,0x8(%esp)
f0103608:	f0 
f0103609:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0103610:	00 
f0103611:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103618:	e8 23 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010361d:	83 c6 01             	add    $0x1,%esi
f0103620:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103623:	7c 8e                	jl     f01035b3 <region_alloc+0x2f>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103625:	83 c4 2c             	add    $0x2c,%esp
f0103628:	5b                   	pop    %ebx
f0103629:	5e                   	pop    %esi
f010362a:	5f                   	pop    %edi
f010362b:	5d                   	pop    %ebp
f010362c:	c3                   	ret    

f010362d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010362d:	55                   	push   %ebp
f010362e:	89 e5                	mov    %esp,%ebp
f0103630:	83 ec 18             	sub    $0x18,%esp
f0103633:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103636:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103639:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010363c:	8b 45 08             	mov    0x8(%ebp),%eax
f010363f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103642:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103646:	85 c0                	test   %eax,%eax
f0103648:	75 17                	jne    f0103661 <envid2env+0x34>
		*env_store = curenv;
f010364a:	e8 05 2d 00 00       	call   f0106354 <cpunum>
f010364f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103652:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103658:	89 06                	mov    %eax,(%esi)
		return 0;
f010365a:	b8 00 00 00 00       	mov    $0x0,%eax
f010365f:	eb 67                	jmp    f01036c8 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103661:	89 c3                	mov    %eax,%ebx
f0103663:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103669:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010366c:	03 1d 48 c2 22 f0    	add    0xf022c248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103672:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103676:	74 05                	je     f010367d <envid2env+0x50>
f0103678:	39 43 48             	cmp    %eax,0x48(%ebx)
f010367b:	74 0d                	je     f010368a <envid2env+0x5d>
		*env_store = 0;
f010367d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103683:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103688:	eb 3e                	jmp    f01036c8 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010368a:	84 d2                	test   %dl,%dl
f010368c:	74 33                	je     f01036c1 <envid2env+0x94>
f010368e:	e8 c1 2c 00 00       	call   f0106354 <cpunum>
f0103693:	6b c0 74             	imul   $0x74,%eax,%eax
f0103696:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f010369c:	74 23                	je     f01036c1 <envid2env+0x94>
f010369e:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036a1:	e8 ae 2c 00 00       	call   f0106354 <cpunum>
f01036a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01036af:	3b 78 48             	cmp    0x48(%eax),%edi
f01036b2:	74 0d                	je     f01036c1 <envid2env+0x94>
		*env_store = 0;
f01036b4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036ba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036bf:	eb 07                	jmp    f01036c8 <envid2env+0x9b>
	}

	*env_store = e;
f01036c1:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01036cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01036ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01036d1:	89 ec                	mov    %ebp,%esp
f01036d3:	5d                   	pop    %ebp
f01036d4:	c3                   	ret    

f01036d5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036d5:	55                   	push   %ebp
f01036d6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036d8:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036dd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036e0:	b8 23 00 00 00       	mov    $0x23,%eax
f01036e5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036e7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036e9:	b0 10                	mov    $0x10,%al
f01036eb:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036ed:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036ef:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036f1:	ea f8 36 10 f0 08 00 	ljmp   $0x8,$0xf01036f8
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036f8:	b0 00                	mov    $0x0,%al
f01036fa:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036fd:	5d                   	pop    %ebp
f01036fe:	c3                   	ret    

f01036ff <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	56                   	push   %esi
f0103703:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f0103704:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010370a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103710:	b9 00 00 00 00       	mov    $0x0,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f0103715:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010371a:	eb 02                	jmp    f010371e <env_init+0x1f>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f010371c:	89 d9                	mov    %ebx,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f010371e:	89 c3                	mov    %eax,%ebx
f0103720:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103727:	89 48 44             	mov    %ecx,0x44(%eax)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f010372a:	83 ea 01             	sub    $0x1,%edx
f010372d:	83 e8 7c             	sub    $0x7c,%eax
f0103730:	83 fa ff             	cmp    $0xffffffff,%edx
f0103733:	75 e7                	jne    f010371c <env_init+0x1d>
f0103735:	89 35 4c c2 22 f0    	mov    %esi,0xf022c24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010373b:	e8 95 ff ff ff       	call   f01036d5 <env_init_percpu>
}
f0103740:	5b                   	pop    %ebx
f0103741:	5e                   	pop    %esi
f0103742:	5d                   	pop    %ebp
f0103743:	c3                   	ret    

f0103744 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103744:	55                   	push   %ebp
f0103745:	89 e5                	mov    %esp,%ebp
f0103747:	53                   	push   %ebx
f0103748:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010374b:	8b 1d 4c c2 22 f0    	mov    0xf022c24c,%ebx
f0103751:	85 db                	test   %ebx,%ebx
f0103753:	0f 84 a7 01 00 00    	je     f0103900 <env_alloc+0x1bc>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103759:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103760:	e8 04 d8 ff ff       	call   f0100f69 <page_alloc>
f0103765:	85 c0                	test   %eax,%eax
f0103767:	0f 84 9a 01 00 00    	je     f0103907 <env_alloc+0x1c3>
f010376d:	89 c2                	mov    %eax,%edx
f010376f:	2b 15 90 ce 22 f0    	sub    0xf022ce90,%edx
f0103775:	c1 fa 03             	sar    $0x3,%edx
f0103778:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010377b:	89 d1                	mov    %edx,%ecx
f010377d:	c1 e9 0c             	shr    $0xc,%ecx
f0103780:	3b 0d 88 ce 22 f0    	cmp    0xf022ce88,%ecx
f0103786:	72 20                	jb     f01037a8 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103788:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010378c:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0103793:	f0 
f0103794:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010379b:	00 
f010379c:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f01037a3:	e8 98 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037a8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01037ae:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f01037b1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037bd:	00 
f01037be:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
f01037c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037c7:	8b 43 60             	mov    0x60(%ebx),%eax
f01037ca:	89 04 24             	mov    %eax,(%esp)
f01037cd:	e8 f5 25 00 00       	call   f0105dc7 <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037d2:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037d9:	00 
f01037da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037e1:	00 
f01037e2:	8b 43 60             	mov    0x60(%ebx),%eax
f01037e5:	89 04 24             	mov    %eax,(%esp)
f01037e8:	e8 06 25 00 00       	call   f0105cf3 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037ed:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f5:	77 20                	ja     f0103817 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037fb:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0103802:	f0 
f0103803:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010380a:	00 
f010380b:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103812:	e8 29 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103817:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010381d:	83 ca 05             	or     $0x5,%edx
f0103820:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103826:	8b 43 48             	mov    0x48(%ebx),%eax
f0103829:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010382e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103833:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103838:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010383b:	89 da                	mov    %ebx,%edx
f010383d:	2b 15 48 c2 22 f0    	sub    0xf022c248,%edx
f0103843:	c1 fa 02             	sar    $0x2,%edx
f0103846:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010384c:	09 d0                	or     %edx,%eax
f010384e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103851:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103854:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103857:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010385e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103865:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010386c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103873:	00 
f0103874:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010387b:	00 
f010387c:	89 1c 24             	mov    %ebx,(%esp)
f010387f:	e8 6f 24 00 00       	call   f0105cf3 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103884:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010388a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103890:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103896:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010389d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038a3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038aa:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038ae:	8b 43 44             	mov    0x44(%ebx),%eax
f01038b1:	a3 4c c2 22 f0       	mov    %eax,0xf022c24c
	*newenv_store = e;
f01038b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01038b9:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038bb:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038be:	e8 91 2a 00 00       	call   f0106354 <cpunum>
f01038c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c6:	ba 00 00 00 00       	mov    $0x0,%edx
f01038cb:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01038d2:	74 11                	je     f01038e5 <env_alloc+0x1a1>
f01038d4:	e8 7b 2a 00 00       	call   f0106354 <cpunum>
f01038d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038dc:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01038e2:	8b 50 48             	mov    0x48(%eax),%edx
f01038e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038e9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038ed:	c7 04 24 00 7c 10 f0 	movl   $0xf0107c00,(%esp)
f01038f4:	e8 95 06 00 00       	call   f0103f8e <cprintf>
	return 0;
f01038f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01038fe:	eb 0c                	jmp    f010390c <env_alloc+0x1c8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103900:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103905:	eb 05                	jmp    f010390c <env_alloc+0x1c8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103907:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010390c:	83 c4 14             	add    $0x14,%esp
f010390f:	5b                   	pop    %ebx
f0103910:	5d                   	pop    %ebp
f0103911:	c3                   	ret    

f0103912 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103912:	55                   	push   %ebp
f0103913:	89 e5                	mov    %esp,%ebp
f0103915:	57                   	push   %edi
f0103916:	56                   	push   %esi
f0103917:	53                   	push   %ebx
f0103918:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f010391b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103922:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103929:	00 
f010392a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010392d:	89 04 24             	mov    %eax,(%esp)
f0103930:	e8 0f fe ff ff       	call   f0103744 <env_alloc>
	if(r < 0)
f0103935:	85 c0                	test   %eax,%eax
f0103937:	79 1c                	jns    f0103955 <env_create+0x43>
		panic("env_create fault\n");
f0103939:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103940:	f0 
f0103941:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0103948:	00 
f0103949:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103950:	e8 eb c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103958:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010395b:	8b 55 08             	mov    0x8(%ebp),%edx
f010395e:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103964:	74 1c                	je     f0103982 <env_create+0x70>
			panic("e_magic is not right\n");
f0103966:	c7 44 24 08 27 7c 10 	movl   $0xf0107c27,0x8(%esp)
f010396d:	f0 
f010396e:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0103975:	00 
f0103976:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f010397d:	e8 be c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103982:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103985:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103988:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010398d:	77 20                	ja     f01039af <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010398f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103993:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f010399a:	f0 
f010399b:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01039a2:	00 
f01039a3:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f01039aa:	e8 91 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039af:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039b4:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f01039b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039ba:	03 5b 1c             	add    0x1c(%ebx),%ebx
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
f01039bd:	83 c3 20             	add    $0x20,%ebx
f01039c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c3:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039c7:	83 c7 01             	add    $0x1,%edi
f01039ca:	be 01 00 00 00       	mov    $0x1,%esi
f01039cf:	eb 54                	jmp    f0103a25 <env_create+0x113>
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
			ph++;
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039d1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039d4:	75 49                	jne    f0103a1f <env_create+0x10d>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039d6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039d9:	8b 53 08             	mov    0x8(%ebx),%edx
f01039dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039df:	e8 a0 fb ff ff       	call   f0103584 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039e4:	8b 43 10             	mov    0x10(%ebx),%eax
f01039e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ee:	03 43 04             	add    0x4(%ebx),%eax
f01039f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039f5:	8b 43 08             	mov    0x8(%ebx),%eax
f01039f8:	89 04 24             	mov    %eax,(%esp)
f01039fb:	e8 4e 23 00 00       	call   f0105d4e <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103a00:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a03:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a06:	29 c2                	sub    %eax,%edx
f0103a08:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a13:	00 
f0103a14:	03 43 08             	add    0x8(%ebx),%eax
f0103a17:	89 04 24             	mov    %eax,(%esp)
f0103a1a:	e8 d4 22 00 00       	call   f0105cf3 <memset>
f0103a1f:	83 c6 01             	add    $0x1,%esi
f0103a22:	83 c3 20             	add    $0x20,%ebx

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a25:	39 fe                	cmp    %edi,%esi
f0103a27:	75 a8                	jne    f01039d1 <env_create+0xbf>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a29:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a2c:	8b 42 18             	mov    0x18(%edx),%eax
f0103a2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a32:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a35:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a3a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a42:	e8 3d fb ff ff       	call   f0103584 <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a47:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a4c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a51:	77 20                	ja     f0103a73 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a57:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0103a5e:	f0 
f0103a5f:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103a66:	00 
f0103a67:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103a6e:	e8 cd c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a73:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a78:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a81:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a84:	83 c4 3c             	add    $0x3c,%esp
f0103a87:	5b                   	pop    %ebx
f0103a88:	5e                   	pop    %esi
f0103a89:	5f                   	pop    %edi
f0103a8a:	5d                   	pop    %ebp
f0103a8b:	c3                   	ret    

f0103a8c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a8c:	55                   	push   %ebp
f0103a8d:	89 e5                	mov    %esp,%ebp
f0103a8f:	57                   	push   %edi
f0103a90:	56                   	push   %esi
f0103a91:	53                   	push   %ebx
f0103a92:	83 ec 2c             	sub    $0x2c,%esp
f0103a95:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a98:	e8 b7 28 00 00       	call   f0106354 <cpunum>
f0103a9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aa0:	39 b8 28 d0 22 f0    	cmp    %edi,-0xfdd2fd8(%eax)
f0103aa6:	75 34                	jne    f0103adc <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103aa8:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ab2:	77 20                	ja     f0103ad4 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ab4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ab8:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0103abf:	f0 
f0103ac0:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103ac7:	00 
f0103ac8:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103acf:	e8 6c c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ad4:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ad9:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103adc:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103adf:	e8 70 28 00 00       	call   f0106354 <cpunum>
f0103ae4:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ae7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103aec:	83 ba 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%edx)
f0103af3:	74 11                	je     f0103b06 <env_free+0x7a>
f0103af5:	e8 5a 28 00 00       	call   f0106354 <cpunum>
f0103afa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103afd:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103b03:	8b 40 48             	mov    0x48(%eax),%eax
f0103b06:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b0e:	c7 04 24 3d 7c 10 f0 	movl   $0xf0107c3d,(%esp)
f0103b15:	e8 74 04 00 00       	call   f0103f8e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b1a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b21:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b24:	c1 e0 02             	shl    $0x2,%eax
f0103b27:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b2a:	8b 47 60             	mov    0x60(%edi),%eax
f0103b2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b30:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103b33:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b39:	0f 84 b8 00 00 00    	je     f0103bf7 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b3f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b45:	89 f0                	mov    %esi,%eax
f0103b47:	c1 e8 0c             	shr    $0xc,%eax
f0103b4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b4d:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103b53:	72 20                	jb     f0103b75 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b55:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b59:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0103b60:	f0 
f0103b61:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103b68:	00 
f0103b69:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103b70:	e8 cb c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b75:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b78:	c1 e2 16             	shl    $0x16,%edx
f0103b7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b83:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b8a:	01 
f0103b8b:	74 17                	je     f0103ba4 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b8d:	89 d8                	mov    %ebx,%eax
f0103b8f:	c1 e0 0c             	shl    $0xc,%eax
f0103b92:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b99:	8b 47 60             	mov    0x60(%edi),%eax
f0103b9c:	89 04 24             	mov    %eax,(%esp)
f0103b9f:	e8 5b d6 ff ff       	call   f01011ff <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ba4:	83 c3 01             	add    $0x1,%ebx
f0103ba7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bad:	75 d4                	jne    f0103b83 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103baf:	8b 47 60             	mov    0x60(%edi),%eax
f0103bb2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bb5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bbf:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103bc5:	72 1c                	jb     f0103be3 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0103bc7:	c7 44 24 08 30 70 10 	movl   $0xf0107030,0x8(%esp)
f0103bce:	f0 
f0103bcf:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bd6:	00 
f0103bd7:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0103bde:	e8 5d c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103be3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103be6:	c1 e0 03             	shl    $0x3,%eax
f0103be9:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
		page_decref(pa2page(pa));
f0103bef:	89 04 24             	mov    %eax,(%esp)
f0103bf2:	e8 36 d4 ff ff       	call   f010102d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bf7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bfb:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c02:	0f 85 19 ff ff ff    	jne    f0103b21 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c08:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c0b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c10:	77 20                	ja     f0103c32 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c16:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0103c1d:	f0 
f0103c1e:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103c25:	00 
f0103c26:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103c2d:	e8 0e c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c32:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c39:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c3e:	c1 e8 0c             	shr    $0xc,%eax
f0103c41:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f0103c47:	72 1c                	jb     f0103c65 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f0103c49:	c7 44 24 08 30 70 10 	movl   $0xf0107030,0x8(%esp)
f0103c50:	f0 
f0103c51:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c58:	00 
f0103c59:	c7 04 24 95 78 10 f0 	movl   $0xf0107895,(%esp)
f0103c60:	e8 db c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c65:	c1 e0 03             	shl    $0x3,%eax
f0103c68:	03 05 90 ce 22 f0    	add    0xf022ce90,%eax
	page_decref(pa2page(pa));
f0103c6e:	89 04 24             	mov    %eax,(%esp)
f0103c71:	e8 b7 d3 ff ff       	call   f010102d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c76:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c7d:	a1 4c c2 22 f0       	mov    0xf022c24c,%eax
f0103c82:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c85:	89 3d 4c c2 22 f0    	mov    %edi,0xf022c24c
}
f0103c8b:	83 c4 2c             	add    $0x2c,%esp
f0103c8e:	5b                   	pop    %ebx
f0103c8f:	5e                   	pop    %esi
f0103c90:	5f                   	pop    %edi
f0103c91:	5d                   	pop    %ebp
f0103c92:	c3                   	ret    

f0103c93 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c93:	55                   	push   %ebp
f0103c94:	89 e5                	mov    %esp,%ebp
f0103c96:	53                   	push   %ebx
f0103c97:	83 ec 14             	sub    $0x14,%esp
f0103c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c9d:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ca1:	75 19                	jne    f0103cbc <env_destroy+0x29>
f0103ca3:	e8 ac 26 00 00       	call   f0106354 <cpunum>
f0103ca8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cab:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103cb1:	74 09                	je     f0103cbc <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103cb3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cba:	eb 2f                	jmp    f0103ceb <env_destroy+0x58>
	}

	env_free(e);
f0103cbc:	89 1c 24             	mov    %ebx,(%esp)
f0103cbf:	e8 c8 fd ff ff       	call   f0103a8c <env_free>

	if (curenv == e) {
f0103cc4:	e8 8b 26 00 00       	call   f0106354 <cpunum>
f0103cc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccc:	39 98 28 d0 22 f0    	cmp    %ebx,-0xfdd2fd8(%eax)
f0103cd2:	75 17                	jne    f0103ceb <env_destroy+0x58>
		curenv = NULL;
f0103cd4:	e8 7b 26 00 00       	call   f0106354 <cpunum>
f0103cd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cdc:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0103ce3:	00 00 00 
		sched_yield();
f0103ce6:	e8 c9 0e 00 00       	call   f0104bb4 <sched_yield>
	}
}
f0103ceb:	83 c4 14             	add    $0x14,%esp
f0103cee:	5b                   	pop    %ebx
f0103cef:	5d                   	pop    %ebp
f0103cf0:	c3                   	ret    

f0103cf1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cf1:	55                   	push   %ebp
f0103cf2:	89 e5                	mov    %esp,%ebp
f0103cf4:	53                   	push   %ebx
f0103cf5:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cf8:	e8 57 26 00 00       	call   f0106354 <cpunum>
f0103cfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d00:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
f0103d06:	e8 49 26 00 00       	call   f0106354 <cpunum>
f0103d0b:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d0e:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d11:	61                   	popa   
f0103d12:	07                   	pop    %es
f0103d13:	1f                   	pop    %ds
f0103d14:	83 c4 08             	add    $0x8,%esp
f0103d17:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d18:	c7 44 24 08 53 7c 10 	movl   $0xf0107c53,0x8(%esp)
f0103d1f:	f0 
f0103d20:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0103d27:	00 
f0103d28:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103d2f:	e8 0c c3 ff ff       	call   f0100040 <_panic>

f0103d34 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d34:	55                   	push   %ebp
f0103d35:	89 e5                	mov    %esp,%ebp
f0103d37:	53                   	push   %ebx
f0103d38:	83 ec 14             	sub    $0x14,%esp
f0103d3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d3e:	e8 11 26 00 00       	call   f0106354 <cpunum>
f0103d43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d46:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f0103d4d:	75 10                	jne    f0103d5f <env_run+0x2b>
		curenv = e;
f0103d4f:	e8 00 26 00 00       	call   f0106354 <cpunum>
f0103d54:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d57:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
f0103d5d:	eb 29                	jmp    f0103d88 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d5f:	e8 f0 25 00 00       	call   f0106354 <cpunum>
f0103d64:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d67:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103d6d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d71:	75 15                	jne    f0103d88 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d73:	e8 dc 25 00 00       	call   f0106354 <cpunum>
f0103d78:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7b:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103d81:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d88:	e8 c7 25 00 00       	call   f0106354 <cpunum>
f0103d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d90:	89 98 28 d0 22 f0    	mov    %ebx,-0xfdd2fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d96:	e8 b9 25 00 00       	call   f0106354 <cpunum>
f0103d9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d9e:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103da4:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103dab:	e8 a4 25 00 00       	call   f0106354 <cpunum>
f0103db0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103db9:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103dbd:	e8 92 25 00 00       	call   f0106354 <cpunum>
f0103dc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc5:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103dcb:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dd3:	77 20                	ja     f0103df5 <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dd9:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0103de0:	f0 
f0103de1:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0103de8:	00 
f0103de9:	c7 04 24 e3 7b 10 f0 	movl   $0xf0107be3,(%esp)
f0103df0:	e8 4b c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103df5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dfa:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dfd:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103e04:	e8 97 28 00 00       	call   f01066a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e09:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103e0b:	e8 44 25 00 00       	call   f0106354 <cpunum>
f0103e10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e13:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0103e19:	89 04 24             	mov    %eax,(%esp)
f0103e1c:	e8 d0 fe ff ff       	call   f0103cf1 <env_pop_tf>
f0103e21:	66 90                	xchg   %ax,%ax
f0103e23:	90                   	nop

f0103e24 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e27:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e2f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e30:	b2 71                	mov    $0x71,%dl
f0103e32:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e33:	0f b6 c0             	movzbl %al,%eax
}
f0103e36:	5d                   	pop    %ebp
f0103e37:	c3                   	ret    

f0103e38 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e38:	55                   	push   %ebp
f0103e39:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e3b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e40:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e43:	ee                   	out    %al,(%dx)
f0103e44:	b2 71                	mov    $0x71,%dl
f0103e46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e49:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e4a:	5d                   	pop    %ebp
f0103e4b:	c3                   	ret    

f0103e4c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e4c:	55                   	push   %ebp
f0103e4d:	89 e5                	mov    %esp,%ebp
f0103e4f:	56                   	push   %esi
f0103e50:	53                   	push   %ebx
f0103e51:	83 ec 10             	sub    $0x10,%esp
f0103e54:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e57:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e59:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e5f:	80 3d 50 c2 22 f0 00 	cmpb   $0x0,0xf022c250
f0103e66:	74 4e                	je     f0103eb6 <irq_setmask_8259A+0x6a>
f0103e68:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e6d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e6e:	89 f0                	mov    %esi,%eax
f0103e70:	66 c1 e8 08          	shr    $0x8,%ax
f0103e74:	b2 a1                	mov    $0xa1,%dl
f0103e76:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e77:	c7 04 24 5f 7c 10 f0 	movl   $0xf0107c5f,(%esp)
f0103e7e:	e8 0b 01 00 00       	call   f0103f8e <cprintf>
	for (i = 0; i < 16; i++)
f0103e83:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e88:	0f b7 f6             	movzwl %si,%esi
f0103e8b:	f7 d6                	not    %esi
f0103e8d:	0f a3 de             	bt     %ebx,%esi
f0103e90:	73 10                	jae    f0103ea2 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103e92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e96:	c7 04 24 3f 81 10 f0 	movl   $0xf010813f,(%esp)
f0103e9d:	e8 ec 00 00 00       	call   f0103f8e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ea2:	83 c3 01             	add    $0x1,%ebx
f0103ea5:	83 fb 10             	cmp    $0x10,%ebx
f0103ea8:	75 e3                	jne    f0103e8d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103eaa:	c7 04 24 80 7b 10 f0 	movl   $0xf0107b80,(%esp)
f0103eb1:	e8 d8 00 00 00       	call   f0103f8e <cprintf>
}
f0103eb6:	83 c4 10             	add    $0x10,%esp
f0103eb9:	5b                   	pop    %ebx
f0103eba:	5e                   	pop    %esi
f0103ebb:	5d                   	pop    %ebp
f0103ebc:	c3                   	ret    

f0103ebd <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ebd:	55                   	push   %ebp
f0103ebe:	89 e5                	mov    %esp,%ebp
f0103ec0:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103ec3:	c6 05 50 c2 22 f0 01 	movb   $0x1,0xf022c250
f0103eca:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ed4:	ee                   	out    %al,(%dx)
f0103ed5:	b2 a1                	mov    $0xa1,%dl
f0103ed7:	ee                   	out    %al,(%dx)
f0103ed8:	b2 20                	mov    $0x20,%dl
f0103eda:	b8 11 00 00 00       	mov    $0x11,%eax
f0103edf:	ee                   	out    %al,(%dx)
f0103ee0:	b2 21                	mov    $0x21,%dl
f0103ee2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ee7:	ee                   	out    %al,(%dx)
f0103ee8:	b8 04 00 00 00       	mov    $0x4,%eax
f0103eed:	ee                   	out    %al,(%dx)
f0103eee:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ef3:	ee                   	out    %al,(%dx)
f0103ef4:	b2 a0                	mov    $0xa0,%dl
f0103ef6:	b8 11 00 00 00       	mov    $0x11,%eax
f0103efb:	ee                   	out    %al,(%dx)
f0103efc:	b2 a1                	mov    $0xa1,%dl
f0103efe:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f03:	ee                   	out    %al,(%dx)
f0103f04:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f09:	ee                   	out    %al,(%dx)
f0103f0a:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f0f:	ee                   	out    %al,(%dx)
f0103f10:	b2 20                	mov    $0x20,%dl
f0103f12:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f17:	ee                   	out    %al,(%dx)
f0103f18:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f1d:	ee                   	out    %al,(%dx)
f0103f1e:	b2 a0                	mov    $0xa0,%dl
f0103f20:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f25:	ee                   	out    %al,(%dx)
f0103f26:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f2b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f2c:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f33:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f37:	74 0b                	je     f0103f44 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0103f39:	0f b7 c0             	movzwl %ax,%eax
f0103f3c:	89 04 24             	mov    %eax,(%esp)
f0103f3f:	e8 08 ff ff ff       	call   f0103e4c <irq_setmask_8259A>
}
f0103f44:	c9                   	leave  
f0103f45:	c3                   	ret    
f0103f46:	66 90                	xchg   %ax,%ax

f0103f48 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f48:	55                   	push   %ebp
f0103f49:	89 e5                	mov    %esp,%ebp
f0103f4b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f51:	89 04 24             	mov    %eax,(%esp)
f0103f54:	e8 31 c8 ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f0103f59:	c9                   	leave  
f0103f5a:	c3                   	ret    

f0103f5b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f5b:	55                   	push   %ebp
f0103f5c:	89 e5                	mov    %esp,%ebp
f0103f5e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f72:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f7d:	c7 04 24 48 3f 10 f0 	movl   $0xf0103f48,(%esp)
f0103f84:	e8 b4 16 00 00       	call   f010563d <vprintfmt>
	return cnt;
}
f0103f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f8c:	c9                   	leave  
f0103f8d:	c3                   	ret    

f0103f8e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f8e:	55                   	push   %ebp
f0103f8f:	89 e5                	mov    %esp,%ebp
f0103f91:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f94:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f97:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9e:	89 04 24             	mov    %eax,(%esp)
f0103fa1:	e8 b5 ff ff ff       	call   f0103f5b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fa6:	c9                   	leave  
f0103fa7:	c3                   	ret    
f0103fa8:	66 90                	xchg   %ax,%ax
f0103faa:	66 90                	xchg   %ax,%ax
f0103fac:	66 90                	xchg   %ax,%ax
f0103fae:	66 90                	xchg   %ax,%ax

f0103fb0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fb0:	55                   	push   %ebp
f0103fb1:	89 e5                	mov    %esp,%ebp
f0103fb3:	57                   	push   %edi
f0103fb4:	56                   	push   %esi
f0103fb5:	53                   	push   %ebx
f0103fb6:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103fb9:	e8 96 23 00 00       	call   f0106354 <cpunum>
f0103fbe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc1:	0f b6 98 20 d0 22 f0 	movzbl -0xfdd2fe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103fc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fcc:	c7 04 24 73 7c 10 f0 	movl   $0xf0107c73,(%esp)
f0103fd3:	e8 b6 ff ff ff       	call   f0103f8e <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fd8:	e8 77 23 00 00       	call   f0106354 <cpunum>
f0103fdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe0:	89 da                	mov    %ebx,%edx
f0103fe2:	f7 da                	neg    %edx
f0103fe4:	c1 e2 10             	shl    $0x10,%edx
f0103fe7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fed:	89 90 30 d0 22 f0    	mov    %edx,-0xfdd2fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103ff3:	e8 5c 23 00 00       	call   f0106354 <cpunum>
f0103ff8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ffb:	66 c7 80 34 d0 22 f0 	movw   $0x10,-0xfdd2fcc(%eax)
f0104002:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0104004:	83 c3 05             	add    $0x5,%ebx
f0104007:	e8 48 23 00 00       	call   f0106354 <cpunum>
f010400c:	89 c7                	mov    %eax,%edi
f010400e:	e8 41 23 00 00       	call   f0106354 <cpunum>
f0104013:	89 c6                	mov    %eax,%esi
f0104015:	e8 3a 23 00 00       	call   f0106354 <cpunum>
f010401a:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0104021:	f0 67 00 
f0104024:	6b ff 74             	imul   $0x74,%edi,%edi
f0104027:	81 c7 2c d0 22 f0    	add    $0xf022d02c,%edi
f010402d:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0104034:	f0 
f0104035:	6b d6 74             	imul   $0x74,%esi,%edx
f0104038:	81 c2 2c d0 22 f0    	add    $0xf022d02c,%edx
f010403e:	c1 ea 10             	shr    $0x10,%edx
f0104041:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104048:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010404f:	40 
f0104050:	6b c0 74             	imul   $0x74,%eax,%eax
f0104053:	05 2c d0 22 f0       	add    $0xf022d02c,%eax
f0104058:	c1 e8 18             	shr    $0x18,%eax
f010405b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104062:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0104069:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010406a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010406d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104070:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0104075:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104078:	83 c4 1c             	add    $0x1c,%esp
f010407b:	5b                   	pop    %ebx
f010407c:	5e                   	pop    %esi
f010407d:	5f                   	pop    %edi
f010407e:	5d                   	pop    %ebp
f010407f:	c3                   	ret    

f0104080 <trap_init>:
}


void
trap_init(void)
{
f0104080:	55                   	push   %ebp
f0104081:	89 e5                	mov    %esp,%ebp
f0104083:	83 ec 08             	sub    $0x8,%esp
    void handler19();

    void handler_syscall();


    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104086:	b8 04 4a 10 f0       	mov    $0xf0104a04,%eax
f010408b:	66 a3 60 c2 22 f0    	mov    %ax,0xf022c260
f0104091:	66 c7 05 62 c2 22 f0 	movw   $0x8,0xf022c262
f0104098:	08 00 
f010409a:	c6 05 64 c2 22 f0 00 	movb   $0x0,0xf022c264
f01040a1:	c6 05 65 c2 22 f0 8e 	movb   $0x8e,0xf022c265
f01040a8:	c1 e8 10             	shr    $0x10,%eax
f01040ab:	66 a3 66 c2 22 f0    	mov    %ax,0xf022c266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f01040b1:	b8 0e 4a 10 f0       	mov    $0xf0104a0e,%eax
f01040b6:	66 a3 68 c2 22 f0    	mov    %ax,0xf022c268
f01040bc:	66 c7 05 6a c2 22 f0 	movw   $0x8,0xf022c26a
f01040c3:	08 00 
f01040c5:	c6 05 6c c2 22 f0 00 	movb   $0x0,0xf022c26c
f01040cc:	c6 05 6d c2 22 f0 8e 	movb   $0x8e,0xf022c26d
f01040d3:	c1 e8 10             	shr    $0x10,%eax
f01040d6:	66 a3 6e c2 22 f0    	mov    %ax,0xf022c26e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040dc:	b8 18 4a 10 f0       	mov    $0xf0104a18,%eax
f01040e1:	66 a3 70 c2 22 f0    	mov    %ax,0xf022c270
f01040e7:	66 c7 05 72 c2 22 f0 	movw   $0x8,0xf022c272
f01040ee:	08 00 
f01040f0:	c6 05 74 c2 22 f0 00 	movb   $0x0,0xf022c274
f01040f7:	c6 05 75 c2 22 f0 8e 	movb   $0x8e,0xf022c275
f01040fe:	c1 e8 10             	shr    $0x10,%eax
f0104101:	66 a3 76 c2 22 f0    	mov    %ax,0xf022c276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f0104107:	b8 22 4a 10 f0       	mov    $0xf0104a22,%eax
f010410c:	66 a3 78 c2 22 f0    	mov    %ax,0xf022c278
f0104112:	66 c7 05 7a c2 22 f0 	movw   $0x8,0xf022c27a
f0104119:	08 00 
f010411b:	c6 05 7c c2 22 f0 00 	movb   $0x0,0xf022c27c
f0104122:	c6 05 7d c2 22 f0 ee 	movb   $0xee,0xf022c27d
f0104129:	c1 e8 10             	shr    $0x10,%eax
f010412c:	66 a3 7e c2 22 f0    	mov    %ax,0xf022c27e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104132:	b8 2c 4a 10 f0       	mov    $0xf0104a2c,%eax
f0104137:	66 a3 80 c2 22 f0    	mov    %ax,0xf022c280
f010413d:	66 c7 05 82 c2 22 f0 	movw   $0x8,0xf022c282
f0104144:	08 00 
f0104146:	c6 05 84 c2 22 f0 00 	movb   $0x0,0xf022c284
f010414d:	c6 05 85 c2 22 f0 8e 	movb   $0x8e,0xf022c285
f0104154:	c1 e8 10             	shr    $0x10,%eax
f0104157:	66 a3 86 c2 22 f0    	mov    %ax,0xf022c286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010415d:	b8 36 4a 10 f0       	mov    $0xf0104a36,%eax
f0104162:	66 a3 88 c2 22 f0    	mov    %ax,0xf022c288
f0104168:	66 c7 05 8a c2 22 f0 	movw   $0x8,0xf022c28a
f010416f:	08 00 
f0104171:	c6 05 8c c2 22 f0 00 	movb   $0x0,0xf022c28c
f0104178:	c6 05 8d c2 22 f0 8e 	movb   $0x8e,0xf022c28d
f010417f:	c1 e8 10             	shr    $0x10,%eax
f0104182:	66 a3 8e c2 22 f0    	mov    %ax,0xf022c28e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104188:	b8 40 4a 10 f0       	mov    $0xf0104a40,%eax
f010418d:	66 a3 90 c2 22 f0    	mov    %ax,0xf022c290
f0104193:	66 c7 05 92 c2 22 f0 	movw   $0x8,0xf022c292
f010419a:	08 00 
f010419c:	c6 05 94 c2 22 f0 00 	movb   $0x0,0xf022c294
f01041a3:	c6 05 95 c2 22 f0 8e 	movb   $0x8e,0xf022c295
f01041aa:	c1 e8 10             	shr    $0x10,%eax
f01041ad:	66 a3 96 c2 22 f0    	mov    %ax,0xf022c296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f01041b3:	b8 4a 4a 10 f0       	mov    $0xf0104a4a,%eax
f01041b8:	66 a3 98 c2 22 f0    	mov    %ax,0xf022c298
f01041be:	66 c7 05 9a c2 22 f0 	movw   $0x8,0xf022c29a
f01041c5:	08 00 
f01041c7:	c6 05 9c c2 22 f0 00 	movb   $0x0,0xf022c29c
f01041ce:	c6 05 9d c2 22 f0 8e 	movb   $0x8e,0xf022c29d
f01041d5:	c1 e8 10             	shr    $0x10,%eax
f01041d8:	66 a3 9e c2 22 f0    	mov    %ax,0xf022c29e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041de:	b8 54 4a 10 f0       	mov    $0xf0104a54,%eax
f01041e3:	66 a3 a0 c2 22 f0    	mov    %ax,0xf022c2a0
f01041e9:	66 c7 05 a2 c2 22 f0 	movw   $0x8,0xf022c2a2
f01041f0:	08 00 
f01041f2:	c6 05 a4 c2 22 f0 00 	movb   $0x0,0xf022c2a4
f01041f9:	c6 05 a5 c2 22 f0 8e 	movb   $0x8e,0xf022c2a5
f0104200:	c1 e8 10             	shr    $0x10,%eax
f0104203:	66 a3 a6 c2 22 f0    	mov    %ax,0xf022c2a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f0104209:	b8 5c 4a 10 f0       	mov    $0xf0104a5c,%eax
f010420e:	66 a3 a8 c2 22 f0    	mov    %ax,0xf022c2a8
f0104214:	66 c7 05 aa c2 22 f0 	movw   $0x8,0xf022c2aa
f010421b:	08 00 
f010421d:	c6 05 ac c2 22 f0 00 	movb   $0x0,0xf022c2ac
f0104224:	c6 05 ad c2 22 f0 8e 	movb   $0x8e,0xf022c2ad
f010422b:	c1 e8 10             	shr    $0x10,%eax
f010422e:	66 a3 ae c2 22 f0    	mov    %ax,0xf022c2ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104234:	b8 66 4a 10 f0       	mov    $0xf0104a66,%eax
f0104239:	66 a3 b0 c2 22 f0    	mov    %ax,0xf022c2b0
f010423f:	66 c7 05 b2 c2 22 f0 	movw   $0x8,0xf022c2b2
f0104246:	08 00 
f0104248:	c6 05 b4 c2 22 f0 00 	movb   $0x0,0xf022c2b4
f010424f:	c6 05 b5 c2 22 f0 8e 	movb   $0x8e,0xf022c2b5
f0104256:	c1 e8 10             	shr    $0x10,%eax
f0104259:	66 a3 b6 c2 22 f0    	mov    %ax,0xf022c2b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010425f:	b8 6e 4a 10 f0       	mov    $0xf0104a6e,%eax
f0104264:	66 a3 b8 c2 22 f0    	mov    %ax,0xf022c2b8
f010426a:	66 c7 05 ba c2 22 f0 	movw   $0x8,0xf022c2ba
f0104271:	08 00 
f0104273:	c6 05 bc c2 22 f0 00 	movb   $0x0,0xf022c2bc
f010427a:	c6 05 bd c2 22 f0 8e 	movb   $0x8e,0xf022c2bd
f0104281:	c1 e8 10             	shr    $0x10,%eax
f0104284:	66 a3 be c2 22 f0    	mov    %ax,0xf022c2be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010428a:	b8 76 4a 10 f0       	mov    $0xf0104a76,%eax
f010428f:	66 a3 c0 c2 22 f0    	mov    %ax,0xf022c2c0
f0104295:	66 c7 05 c2 c2 22 f0 	movw   $0x8,0xf022c2c2
f010429c:	08 00 
f010429e:	c6 05 c4 c2 22 f0 00 	movb   $0x0,0xf022c2c4
f01042a5:	c6 05 c5 c2 22 f0 8e 	movb   $0x8e,0xf022c2c5
f01042ac:	c1 e8 10             	shr    $0x10,%eax
f01042af:	66 a3 c6 c2 22 f0    	mov    %ax,0xf022c2c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f01042b5:	b8 7e 4a 10 f0       	mov    $0xf0104a7e,%eax
f01042ba:	66 a3 c8 c2 22 f0    	mov    %ax,0xf022c2c8
f01042c0:	66 c7 05 ca c2 22 f0 	movw   $0x8,0xf022c2ca
f01042c7:	08 00 
f01042c9:	c6 05 cc c2 22 f0 00 	movb   $0x0,0xf022c2cc
f01042d0:	c6 05 cd c2 22 f0 8e 	movb   $0x8e,0xf022c2cd
f01042d7:	c1 e8 10             	shr    $0x10,%eax
f01042da:	66 a3 ce c2 22 f0    	mov    %ax,0xf022c2ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042e0:	b8 86 4a 10 f0       	mov    $0xf0104a86,%eax
f01042e5:	66 a3 d0 c2 22 f0    	mov    %ax,0xf022c2d0
f01042eb:	66 c7 05 d2 c2 22 f0 	movw   $0x8,0xf022c2d2
f01042f2:	08 00 
f01042f4:	c6 05 d4 c2 22 f0 00 	movb   $0x0,0xf022c2d4
f01042fb:	c6 05 d5 c2 22 f0 8e 	movb   $0x8e,0xf022c2d5
f0104302:	c1 e8 10             	shr    $0x10,%eax
f0104305:	66 a3 d6 c2 22 f0    	mov    %ax,0xf022c2d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f010430b:	b8 8e 4a 10 f0       	mov    $0xf0104a8e,%eax
f0104310:	66 a3 d8 c2 22 f0    	mov    %ax,0xf022c2d8
f0104316:	66 c7 05 da c2 22 f0 	movw   $0x8,0xf022c2da
f010431d:	08 00 
f010431f:	c6 05 dc c2 22 f0 00 	movb   $0x0,0xf022c2dc
f0104326:	c6 05 dd c2 22 f0 8e 	movb   $0x8e,0xf022c2dd
f010432d:	c1 e8 10             	shr    $0x10,%eax
f0104330:	66 a3 de c2 22 f0    	mov    %ax,0xf022c2de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104336:	b8 98 4a 10 f0       	mov    $0xf0104a98,%eax
f010433b:	66 a3 e0 c2 22 f0    	mov    %ax,0xf022c2e0
f0104341:	66 c7 05 e2 c2 22 f0 	movw   $0x8,0xf022c2e2
f0104348:	08 00 
f010434a:	c6 05 e4 c2 22 f0 00 	movb   $0x0,0xf022c2e4
f0104351:	c6 05 e5 c2 22 f0 8e 	movb   $0x8e,0xf022c2e5
f0104358:	c1 e8 10             	shr    $0x10,%eax
f010435b:	66 a3 e6 c2 22 f0    	mov    %ax,0xf022c2e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104361:	b8 a2 4a 10 f0       	mov    $0xf0104aa2,%eax
f0104366:	66 a3 e8 c2 22 f0    	mov    %ax,0xf022c2e8
f010436c:	66 c7 05 ea c2 22 f0 	movw   $0x8,0xf022c2ea
f0104373:	08 00 
f0104375:	c6 05 ec c2 22 f0 00 	movb   $0x0,0xf022c2ec
f010437c:	c6 05 ed c2 22 f0 8e 	movb   $0x8e,0xf022c2ed
f0104383:	c1 e8 10             	shr    $0x10,%eax
f0104386:	66 a3 ee c2 22 f0    	mov    %ax,0xf022c2ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010438c:	b8 aa 4a 10 f0       	mov    $0xf0104aaa,%eax
f0104391:	66 a3 f0 c2 22 f0    	mov    %ax,0xf022c2f0
f0104397:	66 c7 05 f2 c2 22 f0 	movw   $0x8,0xf022c2f2
f010439e:	08 00 
f01043a0:	c6 05 f4 c2 22 f0 00 	movb   $0x0,0xf022c2f4
f01043a7:	c6 05 f5 c2 22 f0 8e 	movb   $0x8e,0xf022c2f5
f01043ae:	c1 e8 10             	shr    $0x10,%eax
f01043b1:	66 a3 f6 c2 22 f0    	mov    %ax,0xf022c2f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f01043b7:	b8 b4 4a 10 f0       	mov    $0xf0104ab4,%eax
f01043bc:	66 a3 f8 c2 22 f0    	mov    %ax,0xf022c2f8
f01043c2:	66 c7 05 fa c2 22 f0 	movw   $0x8,0xf022c2fa
f01043c9:	08 00 
f01043cb:	c6 05 fc c2 22 f0 00 	movb   $0x0,0xf022c2fc
f01043d2:	c6 05 fd c2 22 f0 8e 	movb   $0x8e,0xf022c2fd
f01043d9:	c1 e8 10             	shr    $0x10,%eax
f01043dc:	66 a3 fe c2 22 f0    	mov    %ax,0xf022c2fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043e2:	b8 be 4a 10 f0       	mov    $0xf0104abe,%eax
f01043e7:	66 a3 e0 c3 22 f0    	mov    %ax,0xf022c3e0
f01043ed:	66 c7 05 e2 c3 22 f0 	movw   $0x8,0xf022c3e2
f01043f4:	08 00 
f01043f6:	c6 05 e4 c3 22 f0 00 	movb   $0x0,0xf022c3e4
f01043fd:	c6 05 e5 c3 22 f0 ee 	movb   $0xee,0xf022c3e5
f0104404:	c1 e8 10             	shr    $0x10,%eax
f0104407:	66 a3 e6 c3 22 f0    	mov    %ax,0xf022c3e6




	// Per-CPU setup 
	trap_init_percpu();
f010440d:	e8 9e fb ff ff       	call   f0103fb0 <trap_init_percpu>
}
f0104412:	c9                   	leave  
f0104413:	c3                   	ret    

f0104414 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104414:	55                   	push   %ebp
f0104415:	89 e5                	mov    %esp,%ebp
f0104417:	53                   	push   %ebx
f0104418:	83 ec 14             	sub    $0x14,%esp
f010441b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010441e:	8b 03                	mov    (%ebx),%eax
f0104420:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104424:	c7 04 24 81 7c 10 f0 	movl   $0xf0107c81,(%esp)
f010442b:	e8 5e fb ff ff       	call   f0103f8e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104430:	8b 43 04             	mov    0x4(%ebx),%eax
f0104433:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104437:	c7 04 24 90 7c 10 f0 	movl   $0xf0107c90,(%esp)
f010443e:	e8 4b fb ff ff       	call   f0103f8e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104443:	8b 43 08             	mov    0x8(%ebx),%eax
f0104446:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444a:	c7 04 24 9f 7c 10 f0 	movl   $0xf0107c9f,(%esp)
f0104451:	e8 38 fb ff ff       	call   f0103f8e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104456:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104459:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445d:	c7 04 24 ae 7c 10 f0 	movl   $0xf0107cae,(%esp)
f0104464:	e8 25 fb ff ff       	call   f0103f8e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104469:	8b 43 10             	mov    0x10(%ebx),%eax
f010446c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104470:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0104477:	e8 12 fb ff ff       	call   f0103f8e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010447c:	8b 43 14             	mov    0x14(%ebx),%eax
f010447f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104483:	c7 04 24 cc 7c 10 f0 	movl   $0xf0107ccc,(%esp)
f010448a:	e8 ff fa ff ff       	call   f0103f8e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010448f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104492:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104496:	c7 04 24 db 7c 10 f0 	movl   $0xf0107cdb,(%esp)
f010449d:	e8 ec fa ff ff       	call   f0103f8e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01044a2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a9:	c7 04 24 ea 7c 10 f0 	movl   $0xf0107cea,(%esp)
f01044b0:	e8 d9 fa ff ff       	call   f0103f8e <cprintf>
}
f01044b5:	83 c4 14             	add    $0x14,%esp
f01044b8:	5b                   	pop    %ebx
f01044b9:	5d                   	pop    %ebp
f01044ba:	c3                   	ret    

f01044bb <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f01044bb:	55                   	push   %ebp
f01044bc:	89 e5                	mov    %esp,%ebp
f01044be:	56                   	push   %esi
f01044bf:	53                   	push   %ebx
f01044c0:	83 ec 10             	sub    $0x10,%esp
f01044c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044c6:	e8 89 1e 00 00       	call   f0106354 <cpunum>
f01044cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044d3:	c7 04 24 4e 7d 10 f0 	movl   $0xf0107d4e,(%esp)
f01044da:	e8 af fa ff ff       	call   f0103f8e <cprintf>
	print_regs(&tf->tf_regs);
f01044df:	89 1c 24             	mov    %ebx,(%esp)
f01044e2:	e8 2d ff ff ff       	call   f0104414 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044e7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ef:	c7 04 24 6c 7d 10 f0 	movl   $0xf0107d6c,(%esp)
f01044f6:	e8 93 fa ff ff       	call   f0103f8e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044fb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104503:	c7 04 24 7f 7d 10 f0 	movl   $0xf0107d7f,(%esp)
f010450a:	e8 7f fa ff ff       	call   f0103f8e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010450f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104512:	83 f8 13             	cmp    $0x13,%eax
f0104515:	77 09                	ja     f0104520 <print_trapframe+0x65>
		return excnames[trapno];
f0104517:	8b 14 85 20 80 10 f0 	mov    -0xfef7fe0(,%eax,4),%edx
f010451e:	eb 1f                	jmp    f010453f <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104520:	83 f8 30             	cmp    $0x30,%eax
f0104523:	74 15                	je     f010453a <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104525:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104528:	83 fa 0f             	cmp    $0xf,%edx
f010452b:	ba 05 7d 10 f0       	mov    $0xf0107d05,%edx
f0104530:	b9 18 7d 10 f0       	mov    $0xf0107d18,%ecx
f0104535:	0f 47 d1             	cmova  %ecx,%edx
f0104538:	eb 05                	jmp    f010453f <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010453a:	ba f9 7c 10 f0       	mov    $0xf0107cf9,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010453f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104543:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104547:	c7 04 24 92 7d 10 f0 	movl   $0xf0107d92,(%esp)
f010454e:	e8 3b fa ff ff       	call   f0103f8e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104553:	3b 1d 60 ca 22 f0    	cmp    0xf022ca60,%ebx
f0104559:	75 19                	jne    f0104574 <print_trapframe+0xb9>
f010455b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010455f:	75 13                	jne    f0104574 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104561:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104564:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104568:	c7 04 24 a4 7d 10 f0 	movl   $0xf0107da4,(%esp)
f010456f:	e8 1a fa ff ff       	call   f0103f8e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104574:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104577:	89 44 24 04          	mov    %eax,0x4(%esp)
f010457b:	c7 04 24 b3 7d 10 f0 	movl   $0xf0107db3,(%esp)
f0104582:	e8 07 fa ff ff       	call   f0103f8e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104587:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010458b:	75 51                	jne    f01045de <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010458d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104590:	89 c2                	mov    %eax,%edx
f0104592:	83 e2 01             	and    $0x1,%edx
f0104595:	ba 27 7d 10 f0       	mov    $0xf0107d27,%edx
f010459a:	b9 32 7d 10 f0       	mov    $0xf0107d32,%ecx
f010459f:	0f 45 ca             	cmovne %edx,%ecx
f01045a2:	89 c2                	mov    %eax,%edx
f01045a4:	83 e2 02             	and    $0x2,%edx
f01045a7:	ba 3e 7d 10 f0       	mov    $0xf0107d3e,%edx
f01045ac:	be 44 7d 10 f0       	mov    $0xf0107d44,%esi
f01045b1:	0f 44 d6             	cmove  %esi,%edx
f01045b4:	83 e0 04             	and    $0x4,%eax
f01045b7:	b8 49 7d 10 f0       	mov    $0xf0107d49,%eax
f01045bc:	be 7e 7e 10 f0       	mov    $0xf0107e7e,%esi
f01045c1:	0f 44 c6             	cmove  %esi,%eax
f01045c4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045c8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d0:	c7 04 24 c1 7d 10 f0 	movl   $0xf0107dc1,(%esp)
f01045d7:	e8 b2 f9 ff ff       	call   f0103f8e <cprintf>
f01045dc:	eb 0c                	jmp    f01045ea <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045de:	c7 04 24 80 7b 10 f0 	movl   $0xf0107b80,(%esp)
f01045e5:	e8 a4 f9 ff ff       	call   f0103f8e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045ea:	8b 43 30             	mov    0x30(%ebx),%eax
f01045ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f1:	c7 04 24 d0 7d 10 f0 	movl   $0xf0107dd0,(%esp)
f01045f8:	e8 91 f9 ff ff       	call   f0103f8e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045fd:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104601:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104605:	c7 04 24 df 7d 10 f0 	movl   $0xf0107ddf,(%esp)
f010460c:	e8 7d f9 ff ff       	call   f0103f8e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104611:	8b 43 38             	mov    0x38(%ebx),%eax
f0104614:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104618:	c7 04 24 f2 7d 10 f0 	movl   $0xf0107df2,(%esp)
f010461f:	e8 6a f9 ff ff       	call   f0103f8e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104624:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104628:	74 27                	je     f0104651 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010462a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010462d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104631:	c7 04 24 01 7e 10 f0 	movl   $0xf0107e01,(%esp)
f0104638:	e8 51 f9 ff ff       	call   f0103f8e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010463d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104641:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104645:	c7 04 24 10 7e 10 f0 	movl   $0xf0107e10,(%esp)
f010464c:	e8 3d f9 ff ff       	call   f0103f8e <cprintf>
	}
}
f0104651:	83 c4 10             	add    $0x10,%esp
f0104654:	5b                   	pop    %ebx
f0104655:	5e                   	pop    %esi
f0104656:	5d                   	pop    %ebp
f0104657:	c3                   	ret    

f0104658 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104658:	55                   	push   %ebp
f0104659:	89 e5                	mov    %esp,%ebp
f010465b:	57                   	push   %edi
f010465c:	56                   	push   %esi
f010465d:	53                   	push   %ebx
f010465e:	83 ec 5c             	sub    $0x5c,%esp
f0104661:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104664:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104667:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010466c:	75 1c                	jne    f010468a <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f010466e:	c7 44 24 08 c8 7f 10 	movl   $0xf0107fc8,0x8(%esp)
f0104675:	f0 
f0104676:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f010467d:	00 
f010467e:	c7 04 24 23 7e 10 f0 	movl   $0xf0107e23,(%esp)
f0104685:	e8 b6 b9 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
f010468a:	e8 c5 1c 00 00       	call   f0106354 <cpunum>
f010468f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104692:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104698:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010469c:	75 4a                	jne    f01046e8 <page_fault_handler+0x90>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010469e:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f01046a1:	e8 ae 1c 00 00       	call   f0106354 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01046aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f01046ae:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01046b1:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01046b7:	8b 40 48             	mov    0x48(%eax),%eax
f01046ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046be:	c7 04 24 ec 7f 10 f0 	movl   $0xf0107fec,(%esp)
f01046c5:	e8 c4 f8 ff ff       	call   f0103f8e <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f01046ca:	89 1c 24             	mov    %ebx,(%esp)
f01046cd:	e8 e9 fd ff ff       	call   f01044bb <print_trapframe>
		env_destroy(curenv);
f01046d2:	e8 7d 1c 00 00       	call   f0106354 <cpunum>
f01046d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046da:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01046e0:	89 04 24             	mov    %eax,(%esp)
f01046e3:	e8 ab f5 ff ff       	call   f0103c93 <env_destroy>
	}
	/************debug code*
	cprintf("the curenv->eid =  %d\n",curenv->env_id );

	*******debug code*******/
	user_mem_assert(curenv, (void*)(UXSTACKTOP-PGSIZE), PGSIZE, PTE_U|PTE_W|PTE_P);
f01046e8:	e8 67 1c 00 00       	call   f0106354 <cpunum>
f01046ed:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01046f4:	00 
f01046f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01046fc:	00 
f01046fd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
f0104704:	ee 
f0104705:	6b c0 74             	imul   $0x74,%eax,%eax
f0104708:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010470e:	89 04 24             	mov    %eax,(%esp)
f0104711:	e8 13 ee ff ff       	call   f0103529 <user_mem_assert>

	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f0104716:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104719:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		//note: it is not like the requirement!!! there is two block
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -8;
f010471f:	8d 70 c4             	lea    -0x3c(%eax),%esi
f0104722:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104728:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010472d:	0f 47 f2             	cmova  %edx,%esi
	
	UT.utf_err = tf->tf_err;
f0104730:	8b 53 2c             	mov    0x2c(%ebx),%edx
f0104733:	89 55 b8             	mov    %edx,-0x48(%ebp)
	UT.utf_regs = tf->tf_regs;
f0104736:	8b 13                	mov    (%ebx),%edx
f0104738:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010473b:	8b 53 04             	mov    0x4(%ebx),%edx
f010473e:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0104741:	8b 53 08             	mov    0x8(%ebx),%edx
f0104744:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104747:	8b 53 0c             	mov    0xc(%ebx),%edx
f010474a:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010474d:	8b 53 10             	mov    0x10(%ebx),%edx
f0104750:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104753:	8b 53 14             	mov    0x14(%ebx),%edx
f0104756:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104759:	8b 53 18             	mov    0x18(%ebx),%edx
f010475c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010475f:	8b 53 1c             	mov    0x1c(%ebx),%edx
f0104762:	89 55 d8             	mov    %edx,-0x28(%ebp)
	UT.utf_eflags = tf->tf_eflags;
f0104765:	8b 53 38             	mov    0x38(%ebx),%edx
f0104768:	89 55 e0             	mov    %edx,-0x20(%ebp)
	UT.utf_eip = tf->tf_eip;
f010476b:	8b 53 30             	mov    0x30(%ebx),%edx
f010476e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	UT.utf_esp = tf->tf_esp;
f0104771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	UT.utf_fault_va = fault_va;
f0104774:	89 7d b4             	mov    %edi,-0x4c(%ebp)

	user_mem_assert(curenv,(void*)newEsp, sizeof(struct UTrapframe),PTE_U|PTE_P|PTE_W );
f0104777:	e8 d8 1b 00 00       	call   f0106354 <cpunum>
f010477c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104783:	00 
f0104784:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010478b:	00 
f010478c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104790:	6b c0 74             	imul   $0x74,%eax,%eax
f0104793:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104799:	89 04 24             	mov    %eax,(%esp)
f010479c:	e8 88 ed ff ff       	call   f0103529 <user_mem_assert>
	memcpy((void*)newEsp, (&UT) ,sizeof(struct UTrapframe));
f01047a1:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047a8:	00 
f01047a9:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f01047ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047b0:	89 34 24             	mov    %esi,(%esp)
f01047b3:	e8 0f 16 00 00       	call   f0105dc7 <memcpy>
	tf->tf_esp = newEsp;
f01047b8:	89 73 3c             	mov    %esi,0x3c(%ebx)
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01047bb:	e8 94 1b 00 00       	call   f0106354 <cpunum>
f01047c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01047c9:	8b 40 64             	mov    0x64(%eax),%eax
f01047cc:	89 43 30             	mov    %eax,0x30(%ebx)
	env_run(curenv);
f01047cf:	e8 80 1b 00 00       	call   f0106354 <cpunum>
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d7:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01047dd:	89 04 24             	mov    %eax,(%esp)
f01047e0:	e8 4f f5 ff ff       	call   f0103d34 <env_run>

f01047e5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01047e5:	55                   	push   %ebp
f01047e6:	89 e5                	mov    %esp,%ebp
f01047e8:	57                   	push   %edi
f01047e9:	56                   	push   %esi
f01047ea:	83 ec 20             	sub    $0x20,%esp
f01047ed:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01047f0:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01047f1:	83 3d 80 ce 22 f0 00 	cmpl   $0x0,0xf022ce80
f01047f8:	74 01                	je     f01047fb <trap+0x16>
		asm volatile("hlt");
f01047fa:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047fb:	e8 54 1b 00 00       	call   f0106354 <cpunum>
f0104800:	6b d0 74             	imul   $0x74,%eax,%edx
f0104803:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104809:	b8 01 00 00 00       	mov    $0x1,%eax
f010480e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104812:	83 f8 02             	cmp    $0x2,%eax
f0104815:	75 0c                	jne    f0104823 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104817:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010481e:	e8 e1 1d 00 00       	call   f0106604 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104823:	9c                   	pushf  
f0104824:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104825:	f6 c4 02             	test   $0x2,%ah
f0104828:	74 24                	je     f010484e <trap+0x69>
f010482a:	c7 44 24 0c 2f 7e 10 	movl   $0xf0107e2f,0xc(%esp)
f0104831:	f0 
f0104832:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f0104839:	f0 
f010483a:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0104841:	00 
f0104842:	c7 04 24 23 7e 10 f0 	movl   $0xf0107e23,(%esp)
f0104849:	e8 f2 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010484e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104852:	83 e0 03             	and    $0x3,%eax
f0104855:	66 83 f8 03          	cmp    $0x3,%ax
f0104859:	0f 85 a7 00 00 00    	jne    f0104906 <trap+0x121>
f010485f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104866:	e8 99 1d 00 00       	call   f0106604 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010486b:	e8 e4 1a 00 00       	call   f0106354 <cpunum>
f0104870:	6b c0 74             	imul   $0x74,%eax,%eax
f0104873:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f010487a:	75 24                	jne    f01048a0 <trap+0xbb>
f010487c:	c7 44 24 0c 48 7e 10 	movl   $0xf0107e48,0xc(%esp)
f0104883:	f0 
f0104884:	c7 44 24 08 af 78 10 	movl   $0xf01078af,0x8(%esp)
f010488b:	f0 
f010488c:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f0104893:	00 
f0104894:	c7 04 24 23 7e 10 f0 	movl   $0xf0107e23,(%esp)
f010489b:	e8 a0 b7 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01048a0:	e8 af 1a 00 00       	call   f0106354 <cpunum>
f01048a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a8:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01048ae:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01048b2:	75 2d                	jne    f01048e1 <trap+0xfc>
			env_free(curenv);
f01048b4:	e8 9b 1a 00 00       	call   f0106354 <cpunum>
f01048b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048bc:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01048c2:	89 04 24             	mov    %eax,(%esp)
f01048c5:	e8 c2 f1 ff ff       	call   f0103a8c <env_free>
			curenv = NULL;
f01048ca:	e8 85 1a 00 00       	call   f0106354 <cpunum>
f01048cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d2:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f01048d9:	00 00 00 
			sched_yield();
f01048dc:	e8 d3 02 00 00       	call   f0104bb4 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01048e1:	e8 6e 1a 00 00       	call   f0106354 <cpunum>
f01048e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e9:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01048ef:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048f4:	89 c7                	mov    %eax,%edi
f01048f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01048f8:	e8 57 1a 00 00       	call   f0106354 <cpunum>
f01048fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104900:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104906:	89 35 60 ca 22 f0    	mov    %esi,0xf022ca60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f010490c:	8b 46 28             	mov    0x28(%esi),%eax
f010490f:	83 f8 0e             	cmp    $0xe,%eax
f0104912:	75 08                	jne    f010491c <trap+0x137>
		page_fault_handler(tf);
f0104914:	89 34 24             	mov    %esi,(%esp)
f0104917:	e8 3c fd ff ff       	call   f0104658 <page_fault_handler>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f010491c:	83 f8 03             	cmp    $0x3,%eax
f010491f:	75 0d                	jne    f010492e <trap+0x149>
		monitor(tf);
f0104921:	89 34 24             	mov    %esi,(%esp)
f0104924:	e8 b0 bf ff ff       	call   f01008d9 <monitor>
f0104929:	e9 93 00 00 00       	jmp    f01049c1 <trap+0x1dc>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f010492e:	83 f8 30             	cmp    $0x30,%eax
f0104931:	75 32                	jne    f0104965 <trap+0x180>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104933:	8b 46 04             	mov    0x4(%esi),%eax
f0104936:	89 44 24 14          	mov    %eax,0x14(%esp)
f010493a:	8b 06                	mov    (%esi),%eax
f010493c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104940:	8b 46 10             	mov    0x10(%esi),%eax
f0104943:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104947:	8b 46 18             	mov    0x18(%esi),%eax
f010494a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010494e:	8b 46 14             	mov    0x14(%esi),%eax
f0104951:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104955:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104958:	89 04 24             	mov    %eax,(%esp)
f010495b:	e8 20 03 00 00       	call   f0104c80 <syscall>
f0104960:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104963:	eb 5c                	jmp    f01049c1 <trap+0x1dc>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104965:	83 f8 27             	cmp    $0x27,%eax
f0104968:	75 16                	jne    f0104980 <trap+0x19b>
		cprintf("Spurious interrupt on irq 7\n");
f010496a:	c7 04 24 4f 7e 10 f0 	movl   $0xf0107e4f,(%esp)
f0104971:	e8 18 f6 ff ff       	call   f0103f8e <cprintf>
		print_trapframe(tf);
f0104976:	89 34 24             	mov    %esi,(%esp)
f0104979:	e8 3d fb ff ff       	call   f01044bb <print_trapframe>
f010497e:	eb 41                	jmp    f01049c1 <trap+0x1dc>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104980:	89 34 24             	mov    %esi,(%esp)
f0104983:	e8 33 fb ff ff       	call   f01044bb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104988:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010498d:	75 1c                	jne    f01049ab <trap+0x1c6>
		panic("unhandled trap in kernel");
f010498f:	c7 44 24 08 6c 7e 10 	movl   $0xf0107e6c,0x8(%esp)
f0104996:	f0 
f0104997:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
f010499e:	00 
f010499f:	c7 04 24 23 7e 10 f0 	movl   $0xf0107e23,(%esp)
f01049a6:	e8 95 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01049ab:	e8 a4 19 00 00       	call   f0106354 <cpunum>
f01049b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b3:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01049b9:	89 04 24             	mov    %eax,(%esp)
f01049bc:	e8 d2 f2 ff ff       	call   f0103c93 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049c1:	e8 8e 19 00 00       	call   f0106354 <cpunum>
f01049c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c9:	83 b8 28 d0 22 f0 00 	cmpl   $0x0,-0xfdd2fd8(%eax)
f01049d0:	74 2a                	je     f01049fc <trap+0x217>
f01049d2:	e8 7d 19 00 00       	call   f0106354 <cpunum>
f01049d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049da:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01049e0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049e4:	75 16                	jne    f01049fc <trap+0x217>
		env_run(curenv);
f01049e6:	e8 69 19 00 00       	call   f0106354 <cpunum>
f01049eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ee:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01049f4:	89 04 24             	mov    %eax,(%esp)
f01049f7:	e8 38 f3 ff ff       	call   f0103d34 <env_run>
	else
		sched_yield();
f01049fc:	e8 b3 01 00 00       	call   f0104bb4 <sched_yield>
f0104a01:	66 90                	xchg   %ax,%ax
f0104a03:	90                   	nop

f0104a04 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104a04:	6a 00                	push   $0x0
f0104a06:	6a 00                	push   $0x0
f0104a08:	e9 ba 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a0d:	90                   	nop

f0104a0e <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104a0e:	6a 00                	push   $0x0
f0104a10:	6a 01                	push   $0x1
f0104a12:	e9 b0 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a17:	90                   	nop

f0104a18 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f0104a18:	6a 00                	push   $0x0
f0104a1a:	6a 02                	push   $0x2
f0104a1c:	e9 a6 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a21:	90                   	nop

f0104a22 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104a22:	6a 00                	push   $0x0
f0104a24:	6a 03                	push   $0x3
f0104a26:	e9 9c 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a2b:	90                   	nop

f0104a2c <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104a2c:	6a 00                	push   $0x0
f0104a2e:	6a 04                	push   $0x4
f0104a30:	e9 92 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a35:	90                   	nop

f0104a36 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104a36:	6a 00                	push   $0x0
f0104a38:	6a 05                	push   $0x5
f0104a3a:	e9 88 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a3f:	90                   	nop

f0104a40 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104a40:	6a 00                	push   $0x0
f0104a42:	6a 06                	push   $0x6
f0104a44:	e9 7e 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a49:	90                   	nop

f0104a4a <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104a4a:	6a 00                	push   $0x0
f0104a4c:	6a 07                	push   $0x7
f0104a4e:	e9 74 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a53:	90                   	nop

f0104a54 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104a54:	6a 08                	push   $0x8
f0104a56:	e9 6c 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a5b:	90                   	nop

f0104a5c <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104a5c:	6a 00                	push   $0x0
f0104a5e:	6a 09                	push   $0x9
f0104a60:	e9 62 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a65:	90                   	nop

f0104a66 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104a66:	6a 0a                	push   $0xa
f0104a68:	e9 5a 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a6d:	90                   	nop

f0104a6e <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104a6e:	6a 0b                	push   $0xb
f0104a70:	e9 52 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a75:	90                   	nop

f0104a76 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104a76:	6a 0c                	push   $0xc
f0104a78:	e9 4a 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a7d:	90                   	nop

f0104a7e <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104a7e:	6a 0d                	push   $0xd
f0104a80:	e9 42 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a85:	90                   	nop

f0104a86 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104a86:	6a 0e                	push   $0xe
f0104a88:	e9 3a 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a8d:	90                   	nop

f0104a8e <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104a8e:	6a 00                	push   $0x0
f0104a90:	6a 0f                	push   $0xf
f0104a92:	e9 30 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104a97:	90                   	nop

f0104a98 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104a98:	6a 00                	push   $0x0
f0104a9a:	6a 10                	push   $0x10
f0104a9c:	e9 26 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104aa1:	90                   	nop

f0104aa2 <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104aa2:	6a 11                	push   $0x11
f0104aa4:	e9 1e 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104aa9:	90                   	nop

f0104aaa <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104aaa:	6a 00                	push   $0x0
f0104aac:	6a 12                	push   $0x12
f0104aae:	e9 14 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104ab3:	90                   	nop

f0104ab4 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104ab4:	6a 00                	push   $0x0
f0104ab6:	6a 13                	push   $0x13
f0104ab8:	e9 0a 00 00 00       	jmp    f0104ac7 <_alltraps>
f0104abd:	90                   	nop

f0104abe <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104abe:	6a 00                	push   $0x0
f0104ac0:	6a 30                	push   $0x30
f0104ac2:	e9 00 00 00 00       	jmp    f0104ac7 <_alltraps>

f0104ac7 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104ac7:	1e                   	push   %ds
	pushl %es
f0104ac8:	06                   	push   %es
	pushal
f0104ac9:	60                   	pusha  
	movl $GD_KD, %eax
f0104aca:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104acf:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104ad1:	8e c0                	mov    %eax,%es

	pushl %esp
f0104ad3:	54                   	push   %esp
	call trap
f0104ad4:	e8 0c fd ff ff       	call   f01047e5 <trap>
f0104ad9:	66 90                	xchg   %ax,%ax
f0104adb:	90                   	nop

f0104adc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104adc:	55                   	push   %ebp
f0104add:	89 e5                	mov    %esp,%ebp
f0104adf:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104ae2:	8b 15 48 c2 22 f0    	mov    0xf022c248,%edx
f0104ae8:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104aeb:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104af0:	8b 0a                	mov    (%edx),%ecx
f0104af2:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104af5:	83 f9 02             	cmp    $0x2,%ecx
f0104af8:	76 0f                	jbe    f0104b09 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104afa:	83 c0 01             	add    $0x1,%eax
f0104afd:	83 c2 7c             	add    $0x7c,%edx
f0104b00:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b05:	75 e9                	jne    f0104af0 <sched_halt+0x14>
f0104b07:	eb 07                	jmp    f0104b10 <sched_halt+0x34>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b09:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b0e:	75 1a                	jne    f0104b2a <sched_halt+0x4e>
		cprintf("No runnable environments in the system!\n");
f0104b10:	c7 04 24 70 80 10 f0 	movl   $0xf0108070,(%esp)
f0104b17:	e8 72 f4 ff ff       	call   f0103f8e <cprintf>
		while (1)
			monitor(NULL);
f0104b1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b23:	e8 b1 bd ff ff       	call   f01008d9 <monitor>
f0104b28:	eb f2                	jmp    f0104b1c <sched_halt+0x40>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b2a:	e8 25 18 00 00       	call   f0106354 <cpunum>
f0104b2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b32:	c7 80 28 d0 22 f0 00 	movl   $0x0,-0xfdd2fd8(%eax)
f0104b39:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b3c:	a1 8c ce 22 f0       	mov    0xf022ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b41:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104b46:	77 20                	ja     f0104b68 <sched_halt+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b4c:	c7 44 24 08 a8 6a 10 	movl   $0xf0106aa8,0x8(%esp)
f0104b53:	f0 
f0104b54:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f0104b5b:	00 
f0104b5c:	c7 04 24 99 80 10 f0 	movl   $0xf0108099,(%esp)
f0104b63:	e8 d8 b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b68:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104b6d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b70:	e8 df 17 00 00       	call   f0106354 <cpunum>
f0104b75:	6b d0 74             	imul   $0x74,%eax,%edx
f0104b78:	81 c2 20 d0 22 f0    	add    $0xf022d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104b7e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b83:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104b87:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104b8e:	e8 0d 1b 00 00       	call   f01066a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104b93:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104b95:	e8 ba 17 00 00       	call   f0106354 <cpunum>
f0104b9a:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104b9d:	8b 80 30 d0 22 f0    	mov    -0xfdd2fd0(%eax),%eax
f0104ba3:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ba8:	89 c4                	mov    %eax,%esp
f0104baa:	6a 00                	push   $0x0
f0104bac:	6a 00                	push   $0x0
f0104bae:	fb                   	sti    
f0104baf:	f4                   	hlt    
f0104bb0:	eb fd                	jmp    f0104baf <sched_halt+0xd3>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104bb2:	c9                   	leave  
f0104bb3:	c3                   	ret    

f0104bb4 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104bb4:	55                   	push   %ebp
f0104bb5:	89 e5                	mov    %esp,%ebp
f0104bb7:	57                   	push   %edi
f0104bb8:	56                   	push   %esi
f0104bb9:	53                   	push   %ebx
f0104bba:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
f0104bbd:	e8 92 17 00 00       	call   f0106354 <cpunum>
f0104bc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc5:	8b 98 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
f0104bcb:	b8 00 00 00 00       	mov    $0x0,%eax
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104bd5:	85 db                	test   %ebx,%ebx
f0104bd7:	74 3e                	je     f0104c17 <sched_yield+0x63>
			
		EnvID =  e-envs;
f0104bd9:	89 de                	mov    %ebx,%esi
f0104bdb:	2b 35 48 c2 22 f0    	sub    0xf022c248,%esi
f0104be1:	c1 fe 02             	sar    $0x2,%esi
f0104be4:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104bea:	89 f1                	mov    %esi,%ecx
		e->env_status = ENV_RUNNABLE;
f0104bec:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104bf3:	83 c6 01             	add    $0x1,%esi
f0104bf6:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104bfb:	89 f0                	mov    %esi,%eax
f0104bfd:	f7 ea                	imul   %edx
f0104bff:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104c02:	c1 f8 09             	sar    $0x9,%eax
f0104c05:	89 f7                	mov    %esi,%edi
f0104c07:	c1 ff 1f             	sar    $0x1f,%edi
f0104c0a:	29 f8                	sub    %edi,%eax
f0104c0c:	89 c2                	mov    %eax,%edx
f0104c0e:	c1 e2 0a             	shl    $0xa,%edx
f0104c11:	29 c2                	sub    %eax,%edx
f0104c13:	29 d6                	sub    %edx,%esi
f0104c15:	89 f0                	mov    %esi,%eax
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104c17:	8b 35 48 c2 22 f0    	mov    0xf022c248,%esi
	
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
f0104c1d:	ba 01 00 00 00       	mov    $0x1,%edx
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c22:	eb 2c                	jmp    f0104c50 <sched_yield+0x9c>
		if(envs[i].env_status == ENV_RUNNABLE){
f0104c24:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104c27:	01 f2                	add    %esi,%edx
f0104c29:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104c2d:	75 08                	jne    f0104c37 <sched_yield+0x83>
			//envs[i].env_cpunum = cpunum();
			env_run(&envs[i]);
f0104c2f:	89 14 24             	mov    %edx,(%esp)
f0104c32:	e8 fd f0 ff ff       	call   f0103d34 <env_run>
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c37:	83 c0 01             	add    $0x1,%eax
f0104c3a:	89 c2                	mov    %eax,%edx
f0104c3c:	c1 fa 1f             	sar    $0x1f,%edx
f0104c3f:	c1 ea 16             	shr    $0x16,%edx
f0104c42:	01 d0                	add    %edx,%eax
f0104c44:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104c49:	29 d0                	sub    %edx,%eax
		if(envs[i].env_status == ENV_RUNNABLE){
			//envs[i].env_cpunum = cpunum();
			env_run(&envs[i]);
		}
		firstEnv = false;
f0104c4b:	ba 00 00 00 00       	mov    $0x0,%edx
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104c50:	84 d2                	test   %dl,%dl
f0104c52:	75 d0                	jne    f0104c24 <sched_yield+0x70>
f0104c54:	39 c8                	cmp    %ecx,%eax
f0104c56:	75 cc                	jne    f0104c24 <sched_yield+0x70>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e)
f0104c58:	85 db                	test   %ebx,%ebx
f0104c5a:	74 08                	je     f0104c64 <sched_yield+0xb0>
		env_run(e);
f0104c5c:	89 1c 24             	mov    %ebx,(%esp)
f0104c5f:	e8 d0 f0 ff ff       	call   f0103d34 <env_run>
	


  
	// sched_halt never returns
	sched_halt();
f0104c64:	e8 73 fe ff ff       	call   f0104adc <sched_halt>
	}
f0104c69:	83 c4 1c             	add    $0x1c,%esp
f0104c6c:	5b                   	pop    %ebx
f0104c6d:	5e                   	pop    %esi
f0104c6e:	5f                   	pop    %edi
f0104c6f:	5d                   	pop    %ebp
f0104c70:	c3                   	ret    
f0104c71:	66 90                	xchg   %ax,%ax
f0104c73:	66 90                	xchg   %ax,%ax
f0104c75:	66 90                	xchg   %ax,%ax
f0104c77:	66 90                	xchg   %ax,%ax
f0104c79:	66 90                	xchg   %ax,%ax
f0104c7b:	66 90                	xchg   %ax,%ax
f0104c7d:	66 90                	xchg   %ax,%ax
f0104c7f:	90                   	nop

f0104c80 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104c80:	55                   	push   %ebp
f0104c81:	89 e5                	mov    %esp,%ebp
f0104c83:	57                   	push   %edi
f0104c84:	56                   	push   %esi
f0104c85:	53                   	push   %ebx
f0104c86:	83 ec 2c             	sub    $0x2c,%esp
f0104c89:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104c8c:	83 f8 0a             	cmp    $0xa,%eax
f0104c8f:	0f 87 62 04 00 00    	ja     f01050f7 <syscall+0x477>
f0104c95:	ff 24 85 ec 80 10 f0 	jmp    *-0xfef7f14(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	cprintf("let me see\n");
f0104c9c:	c7 04 24 a6 80 10 f0 	movl   $0xf01080a6,(%esp)
f0104ca3:	e8 e6 f2 ff ff       	call   f0103f8e <cprintf>
	user_mem_assert(curenv, s, len, PTE_U);
f0104ca8:	e8 a7 16 00 00       	call   f0106354 <cpunum>
f0104cad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104cb4:	00 
f0104cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104cb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104cbc:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104cbf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cc6:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104ccc:	89 04 24             	mov    %eax,(%esp)
f0104ccf:	e8 55 e8 ff ff       	call   f0103529 <user_mem_assert>
	cprintf("let me see\n");
f0104cd4:	c7 04 24 a6 80 10 f0 	movl   $0xf01080a6,(%esp)
f0104cdb:	e8 ae f2 ff ff       	call   f0103f8e <cprintf>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ce7:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cee:	c7 04 24 b2 80 10 f0 	movl   $0xf01080b2,(%esp)
f0104cf5:	e8 94 f2 ff ff       	call   f0103f8e <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104cfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cff:	e9 f8 03 00 00       	jmp    f01050fc <syscall+0x47c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d04:	e8 30 b9 ff ff       	call   f0100639 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104d09:	e9 ee 03 00 00       	jmp    f01050fc <syscall+0x47c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d0e:	66 90                	xchg   %ax,%ax
f0104d10:	e8 3f 16 00 00       	call   f0106354 <cpunum>
f0104d15:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d18:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d1e:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104d21:	e9 d6 03 00 00       	jmp    f01050fc <syscall+0x47c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d26:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d2d:	00 
f0104d2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d35:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d38:	89 04 24             	mov    %eax,(%esp)
f0104d3b:	e8 ed e8 ff ff       	call   f010362d <envid2env>
		return r;
f0104d40:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d42:	85 c0                	test   %eax,%eax
f0104d44:	78 6e                	js     f0104db4 <syscall+0x134>
		return r;
	if (e == curenv)
f0104d46:	e8 09 16 00 00       	call   f0106354 <cpunum>
f0104d4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d51:	39 90 28 d0 22 f0    	cmp    %edx,-0xfdd2fd8(%eax)
f0104d57:	75 23                	jne    f0104d7c <syscall+0xfc>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104d59:	e8 f6 15 00 00       	call   f0106354 <cpunum>
f0104d5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d61:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d67:	8b 40 48             	mov    0x48(%eax),%eax
f0104d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d6e:	c7 04 24 b7 80 10 f0 	movl   $0xf01080b7,(%esp)
f0104d75:	e8 14 f2 ff ff       	call   f0103f8e <cprintf>
f0104d7a:	eb 28                	jmp    f0104da4 <syscall+0x124>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104d7c:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104d7f:	e8 d0 15 00 00       	call   f0106354 <cpunum>
f0104d84:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d88:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d8b:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0104d91:	8b 40 48             	mov    0x48(%eax),%eax
f0104d94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d98:	c7 04 24 d2 80 10 f0 	movl   $0xf01080d2,(%esp)
f0104d9f:	e8 ea f1 ff ff       	call   f0103f8e <cprintf>
	env_destroy(e);
f0104da4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104da7:	89 04 24             	mov    %eax,(%esp)
f0104daa:	e8 e4 ee ff ff       	call   f0103c93 <env_destroy>
	return 0;
f0104daf:	ba 00 00 00 00       	mov    $0x0,%edx
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
f0104db4:	89 d0                	mov    %edx,%eax
						break;
f0104db6:	e9 41 03 00 00       	jmp    f01050fc <syscall+0x47c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104dbb:	e8 f4 fd ff ff       	call   f0104bb4 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	
	struct Env* childEnv=0;
f0104dc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct Env* parentEnv = curenv;
f0104dc7:	e8 88 15 00 00       	call   f0106354 <cpunum>
f0104dcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dcf:	8b b0 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104dd5:	8b 46 48             	mov    0x48(%esi),%eax
f0104dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ddc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ddf:	89 04 24             	mov    %eax,(%esp)
f0104de2:	e8 5d e9 ff ff       	call   f0103744 <env_alloc>
	if(r < 0)
f0104de7:	85 c0                	test   %eax,%eax
f0104de9:	0f 88 0d 03 00 00    	js     f01050fc <syscall+0x47c>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104def:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104df4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104df7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dfc:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104e03:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104e0a:	8b 40 48             	mov    0x48(%eax),%eax
f0104e0d:	e9 ea 02 00 00       	jmp    f01050fc <syscall+0x47c>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e =0;
f0104e12:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104e19:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e20:	00 
f0104e21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e2b:	89 04 24             	mov    %eax,(%esp)
f0104e2e:	e8 fa e7 ff ff       	call   f010362d <envid2env>
f0104e33:	85 c0                	test   %eax,%eax
f0104e35:	0f 88 c1 02 00 00    	js     f01050fc <syscall+0x47c>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104e3b:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104e3f:	74 06                	je     f0104e47 <syscall+0x1c7>
f0104e41:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104e45:	75 13                	jne    f0104e5a <syscall+0x1da>
		return -E_INVAL;
	e->env_status = status;
f0104e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e4d:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104e50:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e55:	e9 a2 02 00 00       	jmp    f01050fc <syscall+0x47c>
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104e5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
f0104e5f:	e9 98 02 00 00       	jmp    f01050fc <syscall+0x47c>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	
	struct Env *e =0;
f0104e64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104e6b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e72:	00 
f0104e73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e7d:	89 04 24             	mov    %eax,(%esp)
f0104e80:	e8 a8 e7 ff ff       	call   f010362d <envid2env>
f0104e85:	85 c0                	test   %eax,%eax
f0104e87:	78 6c                	js     f0104ef5 <syscall+0x275>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104e89:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e90:	77 67                	ja     f0104ef9 <syscall+0x279>
f0104e92:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e99:	75 67                	jne    f0104f02 <syscall+0x282>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104e9b:	8b 75 14             	mov    0x14(%ebp),%esi
f0104e9e:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f0104ea4:	75 63                	jne    f0104f09 <syscall+0x289>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104ea6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ea9:	83 e0 05             	and    $0x5,%eax
f0104eac:	83 f8 05             	cmp    $0x5,%eax
f0104eaf:	75 5f                	jne    f0104f10 <syscall+0x290>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104eb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104eb8:	e8 ac c0 ff ff       	call   f0100f69 <page_alloc>
f0104ebd:	89 c3                	mov    %eax,%ebx
	if(page == 0)
f0104ebf:	85 c0                	test   %eax,%eax
f0104ec1:	74 54                	je     f0104f17 <syscall+0x297>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104ec3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104eca:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ed1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ed8:	8b 40 60             	mov    0x60(%eax),%eax
f0104edb:	89 04 24             	mov    %eax,(%esp)
f0104ede:	e8 7c c3 ff ff       	call   f010125f <page_insert>
f0104ee3:	89 c7                	mov    %eax,%edi
	if(r <0){
f0104ee5:	85 c0                	test   %eax,%eax
f0104ee7:	79 33                	jns    f0104f1c <syscall+0x29c>
		page_free(page);
f0104ee9:	89 1c 24             	mov    %ebx,(%esp)
f0104eec:	e8 fc c0 ff ff       	call   f0100fed <page_free>
		return r;
f0104ef1:	89 fe                	mov    %edi,%esi
f0104ef3:	eb 27                	jmp    f0104f1c <syscall+0x29c>
	// LAB 4: Your code here.
	
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104ef5:	89 c6                	mov    %eax,%esi
f0104ef7:	eb 23                	jmp    f0104f1c <syscall+0x29c>
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104ef9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104efe:	66 90                	xchg   %ax,%ax
f0104f00:	eb 1a                	jmp    f0104f1c <syscall+0x29c>
f0104f02:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f07:	eb 13                	jmp    f0104f1c <syscall+0x29c>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0104f09:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f0e:	eb 0c                	jmp    f0104f1c <syscall+0x29c>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0104f10:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f15:	eb 05                	jmp    f0104f1c <syscall+0x29c>
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f0104f17:	be fc ff ff ff       	mov    $0xfffffffc,%esi

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
f0104f1c:	89 f0                	mov    %esi,%eax
						break;
f0104f1e:	e9 d9 01 00 00       	jmp    f01050fc <syscall+0x47c>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
f0104f23:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0104f2a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0104f31:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f38:	00 
f0104f39:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f40:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f43:	89 04 24             	mov    %eax,(%esp)
f0104f46:	e8 e2 e6 ff ff       	call   f010362d <envid2env>
		return r;
f0104f4b:	89 c2                	mov    %eax,%edx
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0104f4d:	85 c0                	test   %eax,%eax
f0104f4f:	0f 88 05 01 00 00    	js     f010505a <syscall+0x3da>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f0104f55:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f5c:	00 
f0104f5d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f64:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f67:	89 04 24             	mov    %eax,(%esp)
f0104f6a:	e8 be e6 ff ff       	call   f010362d <envid2env>
f0104f6f:	85 c0                	test   %eax,%eax
f0104f71:	0f 88 a9 00 00 00    	js     f0105020 <syscall+0x3a0>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f0104f77:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f7e:	0f 87 a0 00 00 00    	ja     f0105024 <syscall+0x3a4>
f0104f84:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f8b:	0f 85 9a 00 00 00    	jne    f010502b <syscall+0x3ab>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f0104f91:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f98:	0f 87 94 00 00 00    	ja     f0105032 <syscall+0x3b2>
f0104f9e:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104fa5:	0f 85 8e 00 00 00    	jne    f0105039 <syscall+0x3b9>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f0104fab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f0104fb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fb9:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104fc3:	8b 40 60             	mov    0x60(%eax),%eax
f0104fc6:	89 04 24             	mov    %eax,(%esp)
f0104fc9:	e8 87 c1 ff ff       	call   f0101155 <page_lookup>
	if(page == 0)
f0104fce:	85 c0                	test   %eax,%eax
f0104fd0:	74 6e                	je     f0105040 <syscall+0x3c0>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104fd2:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104fd9:	75 6c                	jne    f0105047 <syscall+0x3c7>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104fdb:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104fde:	83 e2 05             	and    $0x5,%edx
f0104fe1:	83 fa 05             	cmp    $0x5,%edx
f0104fe4:	75 68                	jne    f010504e <syscall+0x3ce>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f0104fe6:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104fea:	74 08                	je     f0104ff4 <syscall+0x374>
f0104fec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fef:	f6 02 02             	testb  $0x2,(%edx)
f0104ff2:	74 61                	je     f0105055 <syscall+0x3d5>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f0104ff4:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104ff7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104ffb:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104ffe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105002:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105006:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105009:	8b 40 60             	mov    0x60(%eax),%eax
f010500c:	89 04 24             	mov    %eax,(%esp)
f010500f:	e8 4b c2 ff ff       	call   f010125f <page_insert>
f0105014:	85 c0                	test   %eax,%eax
f0105016:	ba 00 00 00 00       	mov    $0x0,%edx
f010501b:	0f 4e d0             	cmovle %eax,%edx
f010501e:	eb 3a                	jmp    f010505a <syscall+0x3da>
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
f0105020:	89 c2                	mov    %eax,%edx
f0105022:	eb 36                	jmp    f010505a <syscall+0x3da>
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f0105024:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105029:	eb 2f                	jmp    f010505a <syscall+0x3da>
f010502b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105030:	eb 28                	jmp    f010505a <syscall+0x3da>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
f0105032:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105037:	eb 21                	jmp    f010505a <syscall+0x3da>
f0105039:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010503e:	eb 1a                	jmp    f010505a <syscall+0x3da>
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f0105040:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105045:	eb 13                	jmp    f010505a <syscall+0x3da>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0105047:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010504c:	eb 0c                	jmp    f010505a <syscall+0x3da>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f010504e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105053:	eb 05                	jmp    f010505a <syscall+0x3da>
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
		return -E_INVAL;
f0105055:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
f010505a:	89 d0                	mov    %edx,%eax
						break;
f010505c:	e9 9b 00 00 00       	jmp    f01050fc <syscall+0x47c>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e =0;
f0105061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0105068:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010506f:	00 
f0105070:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105073:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105077:	8b 45 0c             	mov    0xc(%ebp),%eax
f010507a:	89 04 24             	mov    %eax,(%esp)
f010507d:	e8 ab e5 ff ff       	call   f010362d <envid2env>
f0105082:	85 c0                	test   %eax,%eax
f0105084:	78 76                	js     f01050fc <syscall+0x47c>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0105086:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010508d:	77 25                	ja     f01050b4 <syscall+0x434>
f010508f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105096:	75 23                	jne    f01050bb <syscall+0x43b>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f0105098:	8b 45 10             	mov    0x10(%ebp),%eax
f010509b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010509f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050a2:	8b 40 60             	mov    0x60(%eax),%eax
f01050a5:	89 04 24             	mov    %eax,(%esp)
f01050a8:	e8 52 c1 ff ff       	call   f01011ff <page_remove>
	return 0;
f01050ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b2:	eb 48                	jmp    f01050fc <syscall+0x47c>
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f01050b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050b9:	eb 41                	jmp    f01050fc <syscall+0x47c>
f01050bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
f01050c0:	eb 3a                	jmp    f01050fc <syscall+0x47c>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{

	// LAB 4: Your code here.
	struct Env *e =0;
f01050c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f01050c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050d0:	00 
f01050d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050db:	89 04 24             	mov    %eax,(%esp)
f01050de:	e8 4a e5 ff ff       	call   f010362d <envid2env>
f01050e3:	85 c0                	test   %eax,%eax
f01050e5:	78 15                	js     f01050fc <syscall+0x47c>
		return r;
	e->env_pgfault_upcall = func;
f01050e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01050ed:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f01050f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01050f5:	eb 05                	jmp    f01050fc <syscall+0x47c>
		case SYS_env_set_pgfault_upcall:
								ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
						break;

		default:
			return -E_NO_SYS;
f01050f7:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
	return ret;
}
f01050fc:	83 c4 2c             	add    $0x2c,%esp
f01050ff:	5b                   	pop    %ebx
f0105100:	5e                   	pop    %esi
f0105101:	5f                   	pop    %edi
f0105102:	5d                   	pop    %ebp
f0105103:	c3                   	ret    

f0105104 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105104:	55                   	push   %ebp
f0105105:	89 e5                	mov    %esp,%ebp
f0105107:	57                   	push   %edi
f0105108:	56                   	push   %esi
f0105109:	53                   	push   %ebx
f010510a:	83 ec 14             	sub    $0x14,%esp
f010510d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105110:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105113:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105116:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105119:	8b 1a                	mov    (%edx),%ebx
f010511b:	8b 01                	mov    (%ecx),%eax
f010511d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105120:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105127:	e9 88 00 00 00       	jmp    f01051b4 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f010512c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010512f:	01 d8                	add    %ebx,%eax
f0105131:	89 c7                	mov    %eax,%edi
f0105133:	c1 ef 1f             	shr    $0x1f,%edi
f0105136:	01 c7                	add    %eax,%edi
f0105138:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010513a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010513d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105140:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105144:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105146:	eb 03                	jmp    f010514b <stab_binsearch+0x47>
			m--;
f0105148:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010514b:	39 c3                	cmp    %eax,%ebx
f010514d:	7f 1e                	jg     f010516d <stab_binsearch+0x69>
f010514f:	0f b6 0a             	movzbl (%edx),%ecx
f0105152:	83 ea 0c             	sub    $0xc,%edx
f0105155:	39 f1                	cmp    %esi,%ecx
f0105157:	75 ef                	jne    f0105148 <stab_binsearch+0x44>
f0105159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010515c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010515f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105162:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105166:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105169:	76 18                	jbe    f0105183 <stab_binsearch+0x7f>
f010516b:	eb 05                	jmp    f0105172 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010516d:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105170:	eb 42                	jmp    f01051b4 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105172:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105175:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0105177:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010517a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105181:	eb 31                	jmp    f01051b4 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105183:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105186:	73 17                	jae    f010519f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105188:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010518b:	83 e9 01             	sub    $0x1,%ecx
f010518e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105191:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105194:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105196:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010519d:	eb 15                	jmp    f01051b4 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010519f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01051a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01051a5:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01051a7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01051ab:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01051ad:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01051b4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01051b7:	0f 8e 6f ff ff ff    	jle    f010512c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01051bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01051c1:	75 0f                	jne    f01051d2 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01051c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01051c6:	8b 02                	mov    (%edx),%eax
f01051c8:	83 e8 01             	sub    $0x1,%eax
f01051cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051ce:	89 01                	mov    %eax,(%ecx)
f01051d0:	eb 2c                	jmp    f01051fe <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051d5:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01051d7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01051da:	8b 0a                	mov    (%edx),%ecx
f01051dc:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01051df:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01051e2:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051e6:	eb 03                	jmp    f01051eb <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01051e8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051eb:	39 c8                	cmp    %ecx,%eax
f01051ed:	7e 0a                	jle    f01051f9 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01051ef:	0f b6 1a             	movzbl (%edx),%ebx
f01051f2:	83 ea 0c             	sub    $0xc,%edx
f01051f5:	39 f3                	cmp    %esi,%ebx
f01051f7:	75 ef                	jne    f01051e8 <stab_binsearch+0xe4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01051f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01051fc:	89 02                	mov    %eax,(%edx)
	}
}
f01051fe:	83 c4 14             	add    $0x14,%esp
f0105201:	5b                   	pop    %ebx
f0105202:	5e                   	pop    %esi
f0105203:	5f                   	pop    %edi
f0105204:	5d                   	pop    %ebp
f0105205:	c3                   	ret    

f0105206 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105206:	55                   	push   %ebp
f0105207:	89 e5                	mov    %esp,%ebp
f0105209:	57                   	push   %edi
f010520a:	56                   	push   %esi
f010520b:	53                   	push   %ebx
f010520c:	83 ec 5c             	sub    $0x5c,%esp
f010520f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105215:	c7 03 18 81 10 f0    	movl   $0xf0108118,(%ebx)
	info->eip_line = 0;
f010521b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105222:	c7 43 08 18 81 10 f0 	movl   $0xf0108118,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105229:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105230:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105233:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010523a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105240:	0f 87 d8 00 00 00    	ja     f010531e <debuginfo_eip+0x118>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105246:	e8 09 11 00 00       	call   f0106354 <cpunum>
f010524b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105252:	00 
f0105253:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010525a:	00 
f010525b:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105262:	00 
f0105263:	6b c0 74             	imul   $0x74,%eax,%eax
f0105266:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f010526c:	89 04 24             	mov    %eax,(%esp)
f010526f:	e8 13 e2 ff ff       	call   f0103487 <user_mem_check>
f0105274:	89 c2                	mov    %eax,%edx
			return -1;
f0105276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010527b:	85 d2                	test   %edx,%edx
f010527d:	0f 85 47 02 00 00    	jne    f01054ca <debuginfo_eip+0x2c4>
			return -1;

		stabs = usd->stabs;
f0105283:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105289:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010528c:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105292:	a1 08 00 20 00       	mov    0x200008,%eax
f0105297:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010529a:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01052a0:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01052a3:	e8 ac 10 00 00       	call   f0106354 <cpunum>
f01052a8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01052af:	00 
f01052b0:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01052b7:	00 
f01052b8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01052bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01052bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01052c2:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f01052c8:	89 04 24             	mov    %eax,(%esp)
f01052cb:	e8 b7 e1 ff ff       	call   f0103487 <user_mem_check>
f01052d0:	89 c2                	mov    %eax,%edx
			return -1;
f01052d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01052d7:	85 d2                	test   %edx,%edx
f01052d9:	0f 85 eb 01 00 00    	jne    f01054ca <debuginfo_eip+0x2c4>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01052df:	e8 70 10 00 00       	call   f0106354 <cpunum>
f01052e4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01052eb:	00 
f01052ec:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01052ef:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01052f2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01052f6:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01052f9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01052fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105300:	8b 80 28 d0 22 f0    	mov    -0xfdd2fd8(%eax),%eax
f0105306:	89 04 24             	mov    %eax,(%esp)
f0105309:	e8 79 e1 ff ff       	call   f0103487 <user_mem_check>
f010530e:	89 c2                	mov    %eax,%edx
			return -1;
f0105310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105315:	85 d2                	test   %edx,%edx
f0105317:	74 1f                	je     f0105338 <debuginfo_eip+0x132>
f0105319:	e9 ac 01 00 00       	jmp    f01054ca <debuginfo_eip+0x2c4>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010531e:	c7 45 c0 6a 67 11 f0 	movl   $0xf011676a,-0x40(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105325:	c7 45 bc 25 2f 11 f0 	movl   $0xf0112f25,-0x44(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010532c:	bf 24 2f 11 f0       	mov    $0xf0112f24,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105331:	c7 45 c4 ec 85 10 f0 	movl   $0xf01085ec,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010533d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105340:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105343:	0f 83 81 01 00 00    	jae    f01054ca <debuginfo_eip+0x2c4>
f0105349:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010534d:	0f 85 77 01 00 00    	jne    f01054ca <debuginfo_eip+0x2c4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105353:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010535a:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f010535d:	c1 ff 02             	sar    $0x2,%edi
f0105360:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0105366:	83 e8 01             	sub    $0x1,%eax
f0105369:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010536c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105370:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105377:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010537a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010537d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105380:	e8 7f fd ff ff       	call   f0105104 <stab_binsearch>
	if (lfile == 0)
f0105385:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0105388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010538d:	85 d2                	test   %edx,%edx
f010538f:	0f 84 35 01 00 00    	je     f01054ca <debuginfo_eip+0x2c4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105395:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0105398:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010539b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010539e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053a2:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01053a9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01053ac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01053af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01053b2:	e8 4d fd ff ff       	call   f0105104 <stab_binsearch>

	if (lfun <= rfun) {
f01053b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01053bd:	39 d0                	cmp    %edx,%eax
f01053bf:	7f 32                	jg     f01053f3 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01053c1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01053c4:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01053c7:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01053ca:	8b 39                	mov    (%ecx),%edi
f01053cc:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01053cf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01053d2:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01053d5:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01053d8:	73 09                	jae    f01053e3 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01053da:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01053dd:	03 7d bc             	add    -0x44(%ebp),%edi
f01053e0:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01053e3:	8b 49 08             	mov    0x8(%ecx),%ecx
f01053e6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01053e9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01053eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01053ee:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01053f1:	eb 0f                	jmp    f0105402 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01053f3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01053f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01053fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105402:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105409:	00 
f010540a:	8b 43 08             	mov    0x8(%ebx),%eax
f010540d:	89 04 24             	mov    %eax,(%esp)
f0105410:	e8 c2 08 00 00       	call   f0105cd7 <strfind>
f0105415:	2b 43 08             	sub    0x8(%ebx),%eax
f0105418:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010541b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010541f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105426:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105429:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010542c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010542f:	e8 d0 fc ff ff       	call   f0105104 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105434:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105437:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010543a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010543d:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105440:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0105444:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105447:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010544a:	83 c2 08             	add    $0x8,%edx
f010544d:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105450:	eb 06                	jmp    f0105458 <debuginfo_eip+0x252>
f0105452:	83 e8 01             	sub    $0x1,%eax
f0105455:	83 ea 0c             	sub    $0xc,%edx
f0105458:	89 c7                	mov    %eax,%edi
f010545a:	39 c6                	cmp    %eax,%esi
f010545c:	7f 22                	jg     f0105480 <debuginfo_eip+0x27a>
	       && stabs[lline].n_type != N_SOL
f010545e:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
f0105462:	80 f9 84             	cmp    $0x84,%cl
f0105465:	74 6b                	je     f01054d2 <debuginfo_eip+0x2cc>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105467:	80 f9 64             	cmp    $0x64,%cl
f010546a:	75 e6                	jne    f0105452 <debuginfo_eip+0x24c>
f010546c:	83 3a 00             	cmpl   $0x0,(%edx)
f010546f:	74 e1                	je     f0105452 <debuginfo_eip+0x24c>
f0105471:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105474:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105477:	eb 5f                	jmp    f01054d8 <debuginfo_eip+0x2d2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105479:	03 45 bc             	add    -0x44(%ebp),%eax
f010547c:	89 03                	mov    %eax,(%ebx)
f010547e:	eb 03                	jmp    f0105483 <debuginfo_eip+0x27d>
f0105480:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105483:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105486:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105489:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010548e:	39 ca                	cmp    %ecx,%edx
f0105490:	7d 38                	jge    f01054ca <debuginfo_eip+0x2c4>
		for (lline = lfun + 1;
f0105492:	83 c2 01             	add    $0x1,%edx
f0105495:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105498:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010549a:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010549d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01054a0:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01054a4:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01054a6:	eb 04                	jmp    f01054ac <debuginfo_eip+0x2a6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01054a8:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01054ac:	39 f0                	cmp    %esi,%eax
f01054ae:	7d 15                	jge    f01054c5 <debuginfo_eip+0x2bf>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01054b0:	0f b6 0a             	movzbl (%edx),%ecx
f01054b3:	83 c0 01             	add    $0x1,%eax
f01054b6:	83 c2 0c             	add    $0xc,%edx
f01054b9:	80 f9 a0             	cmp    $0xa0,%cl
f01054bc:	74 ea                	je     f01054a8 <debuginfo_eip+0x2a2>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01054be:	b8 00 00 00 00       	mov    $0x0,%eax
f01054c3:	eb 05                	jmp    f01054ca <debuginfo_eip+0x2c4>
f01054c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01054ca:	83 c4 5c             	add    $0x5c,%esp
f01054cd:	5b                   	pop    %ebx
f01054ce:	5e                   	pop    %esi
f01054cf:	5f                   	pop    %edi
f01054d0:	5d                   	pop    %ebp
f01054d1:	c3                   	ret    
f01054d2:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01054d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01054d8:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01054db:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01054de:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01054e1:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01054e4:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01054e7:	39 d0                	cmp    %edx,%eax
f01054e9:	72 8e                	jb     f0105479 <debuginfo_eip+0x273>
f01054eb:	eb 96                	jmp    f0105483 <debuginfo_eip+0x27d>
f01054ed:	66 90                	xchg   %ax,%ax
f01054ef:	90                   	nop

f01054f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01054f0:	55                   	push   %ebp
f01054f1:	89 e5                	mov    %esp,%ebp
f01054f3:	57                   	push   %edi
f01054f4:	56                   	push   %esi
f01054f5:	53                   	push   %ebx
f01054f6:	83 ec 3c             	sub    $0x3c,%esp
f01054f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054fc:	89 d7                	mov    %edx,%edi
f01054fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105501:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105504:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105507:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010550a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010550d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105510:	85 c0                	test   %eax,%eax
f0105512:	75 08                	jne    f010551c <printnum+0x2c>
f0105514:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105517:	39 45 10             	cmp    %eax,0x10(%ebp)
f010551a:	77 59                	ja     f0105575 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010551c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105520:	83 eb 01             	sub    $0x1,%ebx
f0105523:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105527:	8b 45 10             	mov    0x10(%ebp),%eax
f010552a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010552e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105532:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105536:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010553d:	00 
f010553e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105541:	89 04 24             	mov    %eax,(%esp)
f0105544:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105547:	89 44 24 04          	mov    %eax,0x4(%esp)
f010554b:	e8 70 12 00 00       	call   f01067c0 <__udivdi3>
f0105550:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105554:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105558:	89 04 24             	mov    %eax,(%esp)
f010555b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010555f:	89 fa                	mov    %edi,%edx
f0105561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105564:	e8 87 ff ff ff       	call   f01054f0 <printnum>
f0105569:	eb 11                	jmp    f010557c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010556b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010556f:	89 34 24             	mov    %esi,(%esp)
f0105572:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105575:	83 eb 01             	sub    $0x1,%ebx
f0105578:	85 db                	test   %ebx,%ebx
f010557a:	7f ef                	jg     f010556b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010557c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105580:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105584:	8b 45 10             	mov    0x10(%ebp),%eax
f0105587:	89 44 24 08          	mov    %eax,0x8(%esp)
f010558b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105592:	00 
f0105593:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105596:	89 04 24             	mov    %eax,(%esp)
f0105599:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010559c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055a0:	e8 4b 13 00 00       	call   f01068f0 <__umoddi3>
f01055a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055a9:	0f be 80 22 81 10 f0 	movsbl -0xfef7ede(%eax),%eax
f01055b0:	89 04 24             	mov    %eax,(%esp)
f01055b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01055b6:	83 c4 3c             	add    $0x3c,%esp
f01055b9:	5b                   	pop    %ebx
f01055ba:	5e                   	pop    %esi
f01055bb:	5f                   	pop    %edi
f01055bc:	5d                   	pop    %ebp
f01055bd:	c3                   	ret    

f01055be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01055be:	55                   	push   %ebp
f01055bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01055c1:	83 fa 01             	cmp    $0x1,%edx
f01055c4:	7e 0e                	jle    f01055d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01055c6:	8b 10                	mov    (%eax),%edx
f01055c8:	8d 4a 08             	lea    0x8(%edx),%ecx
f01055cb:	89 08                	mov    %ecx,(%eax)
f01055cd:	8b 02                	mov    (%edx),%eax
f01055cf:	8b 52 04             	mov    0x4(%edx),%edx
f01055d2:	eb 22                	jmp    f01055f6 <getuint+0x38>
	else if (lflag)
f01055d4:	85 d2                	test   %edx,%edx
f01055d6:	74 10                	je     f01055e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01055d8:	8b 10                	mov    (%eax),%edx
f01055da:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055dd:	89 08                	mov    %ecx,(%eax)
f01055df:	8b 02                	mov    (%edx),%eax
f01055e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01055e6:	eb 0e                	jmp    f01055f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01055e8:	8b 10                	mov    (%eax),%edx
f01055ea:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055ed:	89 08                	mov    %ecx,(%eax)
f01055ef:	8b 02                	mov    (%edx),%eax
f01055f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01055f6:	5d                   	pop    %ebp
f01055f7:	c3                   	ret    

f01055f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01055f8:	55                   	push   %ebp
f01055f9:	89 e5                	mov    %esp,%ebp
f01055fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01055fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105602:	8b 10                	mov    (%eax),%edx
f0105604:	3b 50 04             	cmp    0x4(%eax),%edx
f0105607:	73 0a                	jae    f0105613 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105609:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010560c:	88 0a                	mov    %cl,(%edx)
f010560e:	83 c2 01             	add    $0x1,%edx
f0105611:	89 10                	mov    %edx,(%eax)
}
f0105613:	5d                   	pop    %ebp
f0105614:	c3                   	ret    

f0105615 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105615:	55                   	push   %ebp
f0105616:	89 e5                	mov    %esp,%ebp
f0105618:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010561b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010561e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105622:	8b 45 10             	mov    0x10(%ebp),%eax
f0105625:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105629:	8b 45 0c             	mov    0xc(%ebp),%eax
f010562c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105630:	8b 45 08             	mov    0x8(%ebp),%eax
f0105633:	89 04 24             	mov    %eax,(%esp)
f0105636:	e8 02 00 00 00       	call   f010563d <vprintfmt>
	va_end(ap);
}
f010563b:	c9                   	leave  
f010563c:	c3                   	ret    

f010563d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010563d:	55                   	push   %ebp
f010563e:	89 e5                	mov    %esp,%ebp
f0105640:	57                   	push   %edi
f0105641:	56                   	push   %esi
f0105642:	53                   	push   %ebx
f0105643:	83 ec 4c             	sub    $0x4c,%esp
f0105646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105649:	8b 75 10             	mov    0x10(%ebp),%esi
f010564c:	eb 12                	jmp    f0105660 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010564e:	85 c0                	test   %eax,%eax
f0105650:	0f 84 bf 03 00 00    	je     f0105a15 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f0105656:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010565a:	89 04 24             	mov    %eax,(%esp)
f010565d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105660:	0f b6 06             	movzbl (%esi),%eax
f0105663:	83 c6 01             	add    $0x1,%esi
f0105666:	83 f8 25             	cmp    $0x25,%eax
f0105669:	75 e3                	jne    f010564e <vprintfmt+0x11>
f010566b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f010566f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105676:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010567b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105682:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105687:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010568a:	eb 2b                	jmp    f01056b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010568c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010568f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105693:	eb 22                	jmp    f01056b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105695:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105698:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010569c:	eb 19                	jmp    f01056b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010569e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01056a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01056a8:	eb 0d                	jmp    f01056b7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01056aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01056b0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056b7:	0f b6 16             	movzbl (%esi),%edx
f01056ba:	0f b6 c2             	movzbl %dl,%eax
f01056bd:	8d 7e 01             	lea    0x1(%esi),%edi
f01056c0:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01056c3:	83 ea 23             	sub    $0x23,%edx
f01056c6:	80 fa 55             	cmp    $0x55,%dl
f01056c9:	0f 87 28 03 00 00    	ja     f01059f7 <vprintfmt+0x3ba>
f01056cf:	0f b6 d2             	movzbl %dl,%edx
f01056d2:	ff 24 95 e0 81 10 f0 	jmp    *-0xfef7e20(,%edx,4)
f01056d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01056dc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01056e3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01056e8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01056eb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01056ef:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01056f2:	8d 50 d0             	lea    -0x30(%eax),%edx
f01056f5:	83 fa 09             	cmp    $0x9,%edx
f01056f8:	77 2f                	ja     f0105729 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01056fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01056fd:	eb e9                	jmp    f01056e8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01056ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105702:	8d 50 04             	lea    0x4(%eax),%edx
f0105705:	89 55 14             	mov    %edx,0x14(%ebp)
f0105708:	8b 00                	mov    (%eax),%eax
f010570a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010570d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105710:	eb 1a                	jmp    f010572c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105712:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105715:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105719:	79 9c                	jns    f01056b7 <vprintfmt+0x7a>
f010571b:	eb 81                	jmp    f010569e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010571d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105720:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105727:	eb 8e                	jmp    f01056b7 <vprintfmt+0x7a>
f0105729:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f010572c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105730:	79 85                	jns    f01056b7 <vprintfmt+0x7a>
f0105732:	e9 73 ff ff ff       	jmp    f01056aa <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105737:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010573a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010573d:	e9 75 ff ff ff       	jmp    f01056b7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105742:	8b 45 14             	mov    0x14(%ebp),%eax
f0105745:	8d 50 04             	lea    0x4(%eax),%edx
f0105748:	89 55 14             	mov    %edx,0x14(%ebp)
f010574b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010574f:	8b 00                	mov    (%eax),%eax
f0105751:	89 04 24             	mov    %eax,(%esp)
f0105754:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105757:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010575a:	e9 01 ff ff ff       	jmp    f0105660 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010575f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105762:	8d 50 04             	lea    0x4(%eax),%edx
f0105765:	89 55 14             	mov    %edx,0x14(%ebp)
f0105768:	8b 00                	mov    (%eax),%eax
f010576a:	89 c2                	mov    %eax,%edx
f010576c:	c1 fa 1f             	sar    $0x1f,%edx
f010576f:	31 d0                	xor    %edx,%eax
f0105771:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105773:	83 f8 09             	cmp    $0x9,%eax
f0105776:	7f 0b                	jg     f0105783 <vprintfmt+0x146>
f0105778:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f010577f:	85 d2                	test   %edx,%edx
f0105781:	75 23                	jne    f01057a6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f0105783:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105787:	c7 44 24 08 3a 81 10 	movl   $0xf010813a,0x8(%esp)
f010578e:	f0 
f010578f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105793:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105796:	89 3c 24             	mov    %edi,(%esp)
f0105799:	e8 77 fe ff ff       	call   f0105615 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010579e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01057a1:	e9 ba fe ff ff       	jmp    f0105660 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01057a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01057aa:	c7 44 24 08 c1 78 10 	movl   $0xf01078c1,0x8(%esp)
f01057b1:	f0 
f01057b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057b6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01057b9:	89 3c 24             	mov    %edi,(%esp)
f01057bc:	e8 54 fe ff ff       	call   f0105615 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01057c4:	e9 97 fe ff ff       	jmp    f0105660 <vprintfmt+0x23>
f01057c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01057cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01057d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01057d5:	8d 50 04             	lea    0x4(%eax),%edx
f01057d8:	89 55 14             	mov    %edx,0x14(%ebp)
f01057db:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01057dd:	85 f6                	test   %esi,%esi
f01057df:	ba 33 81 10 f0       	mov    $0xf0108133,%edx
f01057e4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f01057e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01057eb:	0f 8e 8c 00 00 00    	jle    f010587d <vprintfmt+0x240>
f01057f1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01057f5:	0f 84 82 00 00 00    	je     f010587d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f01057fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057ff:	89 34 24             	mov    %esi,(%esp)
f0105802:	e8 81 03 00 00       	call   f0105b88 <strnlen>
f0105807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010580a:	29 c2                	sub    %eax,%edx
f010580c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f010580f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105813:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105816:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105819:	89 de                	mov    %ebx,%esi
f010581b:	89 d3                	mov    %edx,%ebx
f010581d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010581f:	eb 0d                	jmp    f010582e <vprintfmt+0x1f1>
					putch(padc, putdat);
f0105821:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105825:	89 3c 24             	mov    %edi,(%esp)
f0105828:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010582b:	83 eb 01             	sub    $0x1,%ebx
f010582e:	85 db                	test   %ebx,%ebx
f0105830:	7f ef                	jg     f0105821 <vprintfmt+0x1e4>
f0105832:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105835:	89 f3                	mov    %esi,%ebx
f0105837:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f010583a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010583e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105843:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0105847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010584a:	29 c2                	sub    %eax,%edx
f010584c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010584f:	eb 2c                	jmp    f010587d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105851:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105855:	74 18                	je     f010586f <vprintfmt+0x232>
f0105857:	8d 50 e0             	lea    -0x20(%eax),%edx
f010585a:	83 fa 5e             	cmp    $0x5e,%edx
f010585d:	76 10                	jbe    f010586f <vprintfmt+0x232>
					putch('?', putdat);
f010585f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105863:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010586a:	ff 55 08             	call   *0x8(%ebp)
f010586d:	eb 0a                	jmp    f0105879 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f010586f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105873:	89 04 24             	mov    %eax,(%esp)
f0105876:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105879:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010587d:	0f be 06             	movsbl (%esi),%eax
f0105880:	83 c6 01             	add    $0x1,%esi
f0105883:	85 c0                	test   %eax,%eax
f0105885:	74 25                	je     f01058ac <vprintfmt+0x26f>
f0105887:	85 ff                	test   %edi,%edi
f0105889:	78 c6                	js     f0105851 <vprintfmt+0x214>
f010588b:	83 ef 01             	sub    $0x1,%edi
f010588e:	79 c1                	jns    f0105851 <vprintfmt+0x214>
f0105890:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105893:	89 de                	mov    %ebx,%esi
f0105895:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105898:	eb 1a                	jmp    f01058b4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010589a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010589e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01058a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01058a7:	83 eb 01             	sub    $0x1,%ebx
f01058aa:	eb 08                	jmp    f01058b4 <vprintfmt+0x277>
f01058ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01058af:	89 de                	mov    %ebx,%esi
f01058b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01058b4:	85 db                	test   %ebx,%ebx
f01058b6:	7f e2                	jg     f010589a <vprintfmt+0x25d>
f01058b8:	89 7d 08             	mov    %edi,0x8(%ebp)
f01058bb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01058c0:	e9 9b fd ff ff       	jmp    f0105660 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01058c5:	83 f9 01             	cmp    $0x1,%ecx
f01058c8:	7e 10                	jle    f01058da <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f01058ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01058cd:	8d 50 08             	lea    0x8(%eax),%edx
f01058d0:	89 55 14             	mov    %edx,0x14(%ebp)
f01058d3:	8b 30                	mov    (%eax),%esi
f01058d5:	8b 78 04             	mov    0x4(%eax),%edi
f01058d8:	eb 26                	jmp    f0105900 <vprintfmt+0x2c3>
	else if (lflag)
f01058da:	85 c9                	test   %ecx,%ecx
f01058dc:	74 12                	je     f01058f0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f01058de:	8b 45 14             	mov    0x14(%ebp),%eax
f01058e1:	8d 50 04             	lea    0x4(%eax),%edx
f01058e4:	89 55 14             	mov    %edx,0x14(%ebp)
f01058e7:	8b 30                	mov    (%eax),%esi
f01058e9:	89 f7                	mov    %esi,%edi
f01058eb:	c1 ff 1f             	sar    $0x1f,%edi
f01058ee:	eb 10                	jmp    f0105900 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f01058f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f3:	8d 50 04             	lea    0x4(%eax),%edx
f01058f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01058f9:	8b 30                	mov    (%eax),%esi
f01058fb:	89 f7                	mov    %esi,%edi
f01058fd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105900:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105905:	85 ff                	test   %edi,%edi
f0105907:	0f 89 ac 00 00 00    	jns    f01059b9 <vprintfmt+0x37c>
				putch('-', putdat);
f010590d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105911:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105918:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010591b:	f7 de                	neg    %esi
f010591d:	83 d7 00             	adc    $0x0,%edi
f0105920:	f7 df                	neg    %edi
			}
			base = 10;
f0105922:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105927:	e9 8d 00 00 00       	jmp    f01059b9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010592c:	89 ca                	mov    %ecx,%edx
f010592e:	8d 45 14             	lea    0x14(%ebp),%eax
f0105931:	e8 88 fc ff ff       	call   f01055be <getuint>
f0105936:	89 c6                	mov    %eax,%esi
f0105938:	89 d7                	mov    %edx,%edi
			base = 10;
f010593a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010593f:	eb 78                	jmp    f01059b9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105941:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105945:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010594c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010594f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105953:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010595a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010595d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105961:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105968:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010596b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010596e:	e9 ed fc ff ff       	jmp    f0105660 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0105973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105977:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010597e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105981:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105985:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010598c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010598f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105992:	8d 50 04             	lea    0x4(%eax),%edx
f0105995:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105998:	8b 30                	mov    (%eax),%esi
f010599a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010599f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01059a4:	eb 13                	jmp    f01059b9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01059a6:	89 ca                	mov    %ecx,%edx
f01059a8:	8d 45 14             	lea    0x14(%ebp),%eax
f01059ab:	e8 0e fc ff ff       	call   f01055be <getuint>
f01059b0:	89 c6                	mov    %eax,%esi
f01059b2:	89 d7                	mov    %edx,%edi
			base = 16;
f01059b4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01059b9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01059bd:	89 54 24 10          	mov    %edx,0x10(%esp)
f01059c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01059c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01059c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059cc:	89 34 24             	mov    %esi,(%esp)
f01059cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059d3:	89 da                	mov    %ebx,%edx
f01059d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01059d8:	e8 13 fb ff ff       	call   f01054f0 <printnum>
			break;
f01059dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01059e0:	e9 7b fc ff ff       	jmp    f0105660 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01059e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059e9:	89 04 24             	mov    %eax,(%esp)
f01059ec:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01059f2:	e9 69 fc ff ff       	jmp    f0105660 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01059f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059fb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105a02:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a05:	eb 03                	jmp    f0105a0a <vprintfmt+0x3cd>
f0105a07:	83 ee 01             	sub    $0x1,%esi
f0105a0a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105a0e:	75 f7                	jne    f0105a07 <vprintfmt+0x3ca>
f0105a10:	e9 4b fc ff ff       	jmp    f0105660 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105a15:	83 c4 4c             	add    $0x4c,%esp
f0105a18:	5b                   	pop    %ebx
f0105a19:	5e                   	pop    %esi
f0105a1a:	5f                   	pop    %edi
f0105a1b:	5d                   	pop    %ebp
f0105a1c:	c3                   	ret    

f0105a1d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a1d:	55                   	push   %ebp
f0105a1e:	89 e5                	mov    %esp,%ebp
f0105a20:	83 ec 28             	sub    $0x28,%esp
f0105a23:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a26:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a2c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a30:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a3a:	85 c0                	test   %eax,%eax
f0105a3c:	74 30                	je     f0105a6e <vsnprintf+0x51>
f0105a3e:	85 d2                	test   %edx,%edx
f0105a40:	7e 2c                	jle    f0105a6e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a42:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a45:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a49:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a4c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a50:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a57:	c7 04 24 f8 55 10 f0 	movl   $0xf01055f8,(%esp)
f0105a5e:	e8 da fb ff ff       	call   f010563d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a66:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a6c:	eb 05                	jmp    f0105a73 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105a6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105a73:	c9                   	leave  
f0105a74:	c3                   	ret    

f0105a75 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a75:	55                   	push   %ebp
f0105a76:	89 e5                	mov    %esp,%ebp
f0105a78:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a7b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a82:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a90:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a93:	89 04 24             	mov    %eax,(%esp)
f0105a96:	e8 82 ff ff ff       	call   f0105a1d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a9b:	c9                   	leave  
f0105a9c:	c3                   	ret    
f0105a9d:	66 90                	xchg   %ax,%ax
f0105a9f:	90                   	nop

f0105aa0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105aa0:	55                   	push   %ebp
f0105aa1:	89 e5                	mov    %esp,%ebp
f0105aa3:	57                   	push   %edi
f0105aa4:	56                   	push   %esi
f0105aa5:	53                   	push   %ebx
f0105aa6:	83 ec 1c             	sub    $0x1c,%esp
f0105aa9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105aac:	85 c0                	test   %eax,%eax
f0105aae:	74 10                	je     f0105ac0 <readline+0x20>
		cprintf("%s", prompt);
f0105ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ab4:	c7 04 24 c1 78 10 f0 	movl   $0xf01078c1,(%esp)
f0105abb:	e8 ce e4 ff ff       	call   f0103f8e <cprintf>

	i = 0;
	echoing = iscons(0);
f0105ac0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105ac7:	e8 df ac ff ff       	call   f01007ab <iscons>
f0105acc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105ace:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105ad3:	e8 c2 ac ff ff       	call   f010079a <getchar>
f0105ad8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105ada:	85 c0                	test   %eax,%eax
f0105adc:	79 17                	jns    f0105af5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105ade:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ae2:	c7 04 24 68 83 10 f0 	movl   $0xf0108368,(%esp)
f0105ae9:	e8 a0 e4 ff ff       	call   f0103f8e <cprintf>
			return NULL;
f0105aee:	b8 00 00 00 00       	mov    $0x0,%eax
f0105af3:	eb 6d                	jmp    f0105b62 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105af5:	83 f8 08             	cmp    $0x8,%eax
f0105af8:	74 05                	je     f0105aff <readline+0x5f>
f0105afa:	83 f8 7f             	cmp    $0x7f,%eax
f0105afd:	75 19                	jne    f0105b18 <readline+0x78>
f0105aff:	85 f6                	test   %esi,%esi
f0105b01:	7e 15                	jle    f0105b18 <readline+0x78>
			if (echoing)
f0105b03:	85 ff                	test   %edi,%edi
f0105b05:	74 0c                	je     f0105b13 <readline+0x73>
				cputchar('\b');
f0105b07:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105b0e:	e8 77 ac ff ff       	call   f010078a <cputchar>
			i--;
f0105b13:	83 ee 01             	sub    $0x1,%esi
f0105b16:	eb bb                	jmp    f0105ad3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b18:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b1b:	7e 1f                	jle    f0105b3c <readline+0x9c>
f0105b1d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b23:	7f 17                	jg     f0105b3c <readline+0x9c>
			if (echoing)
f0105b25:	85 ff                	test   %edi,%edi
f0105b27:	74 08                	je     f0105b31 <readline+0x91>
				cputchar(c);
f0105b29:	89 1c 24             	mov    %ebx,(%esp)
f0105b2c:	e8 59 ac ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f0105b31:	88 9e 80 ca 22 f0    	mov    %bl,-0xfdd3580(%esi)
f0105b37:	83 c6 01             	add    $0x1,%esi
f0105b3a:	eb 97                	jmp    f0105ad3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105b3c:	83 fb 0a             	cmp    $0xa,%ebx
f0105b3f:	74 05                	je     f0105b46 <readline+0xa6>
f0105b41:	83 fb 0d             	cmp    $0xd,%ebx
f0105b44:	75 8d                	jne    f0105ad3 <readline+0x33>
			if (echoing)
f0105b46:	85 ff                	test   %edi,%edi
f0105b48:	74 0c                	je     f0105b56 <readline+0xb6>
				cputchar('\n');
f0105b4a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105b51:	e8 34 ac ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f0105b56:	c6 86 80 ca 22 f0 00 	movb   $0x0,-0xfdd3580(%esi)
			return buf;
f0105b5d:	b8 80 ca 22 f0       	mov    $0xf022ca80,%eax
		}
	}
}
f0105b62:	83 c4 1c             	add    $0x1c,%esp
f0105b65:	5b                   	pop    %ebx
f0105b66:	5e                   	pop    %esi
f0105b67:	5f                   	pop    %edi
f0105b68:	5d                   	pop    %ebp
f0105b69:	c3                   	ret    
f0105b6a:	66 90                	xchg   %ax,%ax
f0105b6c:	66 90                	xchg   %ax,%ax
f0105b6e:	66 90                	xchg   %ax,%ax

f0105b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b70:	55                   	push   %ebp
f0105b71:	89 e5                	mov    %esp,%ebp
f0105b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b7b:	eb 03                	jmp    f0105b80 <strlen+0x10>
		n++;
f0105b7d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b84:	75 f7                	jne    f0105b7d <strlen+0xd>
		n++;
	return n;
}
f0105b86:	5d                   	pop    %ebp
f0105b87:	c3                   	ret    

f0105b88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b88:	55                   	push   %ebp
f0105b89:	89 e5                	mov    %esp,%ebp
f0105b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b91:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b96:	eb 03                	jmp    f0105b9b <strnlen+0x13>
		n++;
f0105b98:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b9b:	39 d0                	cmp    %edx,%eax
f0105b9d:	74 06                	je     f0105ba5 <strnlen+0x1d>
f0105b9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105ba3:	75 f3                	jne    f0105b98 <strnlen+0x10>
		n++;
	return n;
}
f0105ba5:	5d                   	pop    %ebp
f0105ba6:	c3                   	ret    

f0105ba7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ba7:	55                   	push   %ebp
f0105ba8:	89 e5                	mov    %esp,%ebp
f0105baa:	53                   	push   %ebx
f0105bab:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105bb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bb6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105bba:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105bbd:	83 c2 01             	add    $0x1,%edx
f0105bc0:	84 c9                	test   %cl,%cl
f0105bc2:	75 f2                	jne    f0105bb6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105bc4:	5b                   	pop    %ebx
f0105bc5:	5d                   	pop    %ebp
f0105bc6:	c3                   	ret    

f0105bc7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105bc7:	55                   	push   %ebp
f0105bc8:	89 e5                	mov    %esp,%ebp
f0105bca:	53                   	push   %ebx
f0105bcb:	83 ec 08             	sub    $0x8,%esp
f0105bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105bd1:	89 1c 24             	mov    %ebx,(%esp)
f0105bd4:	e8 97 ff ff ff       	call   f0105b70 <strlen>
	strcpy(dst + len, src);
f0105bd9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bdc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105be0:	01 d8                	add    %ebx,%eax
f0105be2:	89 04 24             	mov    %eax,(%esp)
f0105be5:	e8 bd ff ff ff       	call   f0105ba7 <strcpy>
	return dst;
}
f0105bea:	89 d8                	mov    %ebx,%eax
f0105bec:	83 c4 08             	add    $0x8,%esp
f0105bef:	5b                   	pop    %ebx
f0105bf0:	5d                   	pop    %ebp
f0105bf1:	c3                   	ret    

f0105bf2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105bf2:	55                   	push   %ebp
f0105bf3:	89 e5                	mov    %esp,%ebp
f0105bf5:	56                   	push   %esi
f0105bf6:	53                   	push   %ebx
f0105bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bfd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c00:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c05:	eb 0f                	jmp    f0105c16 <strncpy+0x24>
		*dst++ = *src;
f0105c07:	0f b6 1a             	movzbl (%edx),%ebx
f0105c0a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c0d:	80 3a 01             	cmpb   $0x1,(%edx)
f0105c10:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c13:	83 c1 01             	add    $0x1,%ecx
f0105c16:	39 f1                	cmp    %esi,%ecx
f0105c18:	75 ed                	jne    f0105c07 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105c1a:	5b                   	pop    %ebx
f0105c1b:	5e                   	pop    %esi
f0105c1c:	5d                   	pop    %ebp
f0105c1d:	c3                   	ret    

f0105c1e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c1e:	55                   	push   %ebp
f0105c1f:	89 e5                	mov    %esp,%ebp
f0105c21:	56                   	push   %esi
f0105c22:	53                   	push   %ebx
f0105c23:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c29:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c2c:	89 f0                	mov    %esi,%eax
f0105c2e:	85 d2                	test   %edx,%edx
f0105c30:	75 0a                	jne    f0105c3c <strlcpy+0x1e>
f0105c32:	eb 1d                	jmp    f0105c51 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105c34:	88 18                	mov    %bl,(%eax)
f0105c36:	83 c0 01             	add    $0x1,%eax
f0105c39:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105c3c:	83 ea 01             	sub    $0x1,%edx
f0105c3f:	74 0b                	je     f0105c4c <strlcpy+0x2e>
f0105c41:	0f b6 19             	movzbl (%ecx),%ebx
f0105c44:	84 db                	test   %bl,%bl
f0105c46:	75 ec                	jne    f0105c34 <strlcpy+0x16>
f0105c48:	89 c2                	mov    %eax,%edx
f0105c4a:	eb 02                	jmp    f0105c4e <strlcpy+0x30>
f0105c4c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105c4e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105c51:	29 f0                	sub    %esi,%eax
}
f0105c53:	5b                   	pop    %ebx
f0105c54:	5e                   	pop    %esi
f0105c55:	5d                   	pop    %ebp
f0105c56:	c3                   	ret    

f0105c57 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c57:	55                   	push   %ebp
f0105c58:	89 e5                	mov    %esp,%ebp
f0105c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c60:	eb 06                	jmp    f0105c68 <strcmp+0x11>
		p++, q++;
f0105c62:	83 c1 01             	add    $0x1,%ecx
f0105c65:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105c68:	0f b6 01             	movzbl (%ecx),%eax
f0105c6b:	84 c0                	test   %al,%al
f0105c6d:	74 04                	je     f0105c73 <strcmp+0x1c>
f0105c6f:	3a 02                	cmp    (%edx),%al
f0105c71:	74 ef                	je     f0105c62 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c73:	0f b6 c0             	movzbl %al,%eax
f0105c76:	0f b6 12             	movzbl (%edx),%edx
f0105c79:	29 d0                	sub    %edx,%eax
}
f0105c7b:	5d                   	pop    %ebp
f0105c7c:	c3                   	ret    

f0105c7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c7d:	55                   	push   %ebp
f0105c7e:	89 e5                	mov    %esp,%ebp
f0105c80:	53                   	push   %ebx
f0105c81:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c87:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105c8a:	eb 09                	jmp    f0105c95 <strncmp+0x18>
		n--, p++, q++;
f0105c8c:	83 ea 01             	sub    $0x1,%edx
f0105c8f:	83 c0 01             	add    $0x1,%eax
f0105c92:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c95:	85 d2                	test   %edx,%edx
f0105c97:	74 15                	je     f0105cae <strncmp+0x31>
f0105c99:	0f b6 18             	movzbl (%eax),%ebx
f0105c9c:	84 db                	test   %bl,%bl
f0105c9e:	74 04                	je     f0105ca4 <strncmp+0x27>
f0105ca0:	3a 19                	cmp    (%ecx),%bl
f0105ca2:	74 e8                	je     f0105c8c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ca4:	0f b6 00             	movzbl (%eax),%eax
f0105ca7:	0f b6 11             	movzbl (%ecx),%edx
f0105caa:	29 d0                	sub    %edx,%eax
f0105cac:	eb 05                	jmp    f0105cb3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105cae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105cb3:	5b                   	pop    %ebx
f0105cb4:	5d                   	pop    %ebp
f0105cb5:	c3                   	ret    

f0105cb6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105cb6:	55                   	push   %ebp
f0105cb7:	89 e5                	mov    %esp,%ebp
f0105cb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105cc0:	eb 07                	jmp    f0105cc9 <strchr+0x13>
		if (*s == c)
f0105cc2:	38 ca                	cmp    %cl,%dl
f0105cc4:	74 0f                	je     f0105cd5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105cc6:	83 c0 01             	add    $0x1,%eax
f0105cc9:	0f b6 10             	movzbl (%eax),%edx
f0105ccc:	84 d2                	test   %dl,%dl
f0105cce:	75 f2                	jne    f0105cc2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cd5:	5d                   	pop    %ebp
f0105cd6:	c3                   	ret    

f0105cd7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105cd7:	55                   	push   %ebp
f0105cd8:	89 e5                	mov    %esp,%ebp
f0105cda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cdd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ce1:	eb 07                	jmp    f0105cea <strfind+0x13>
		if (*s == c)
f0105ce3:	38 ca                	cmp    %cl,%dl
f0105ce5:	74 0a                	je     f0105cf1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105ce7:	83 c0 01             	add    $0x1,%eax
f0105cea:	0f b6 10             	movzbl (%eax),%edx
f0105ced:	84 d2                	test   %dl,%dl
f0105cef:	75 f2                	jne    f0105ce3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105cf1:	5d                   	pop    %ebp
f0105cf2:	c3                   	ret    

f0105cf3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105cf3:	55                   	push   %ebp
f0105cf4:	89 e5                	mov    %esp,%ebp
f0105cf6:	83 ec 0c             	sub    $0xc,%esp
f0105cf9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105cfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105cff:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105d02:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d0b:	85 c9                	test   %ecx,%ecx
f0105d0d:	74 30                	je     f0105d3f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d15:	75 25                	jne    f0105d3c <memset+0x49>
f0105d17:	f6 c1 03             	test   $0x3,%cl
f0105d1a:	75 20                	jne    f0105d3c <memset+0x49>
		c &= 0xFF;
f0105d1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d1f:	89 d3                	mov    %edx,%ebx
f0105d21:	c1 e3 08             	shl    $0x8,%ebx
f0105d24:	89 d6                	mov    %edx,%esi
f0105d26:	c1 e6 18             	shl    $0x18,%esi
f0105d29:	89 d0                	mov    %edx,%eax
f0105d2b:	c1 e0 10             	shl    $0x10,%eax
f0105d2e:	09 f0                	or     %esi,%eax
f0105d30:	09 d0                	or     %edx,%eax
f0105d32:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d34:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105d37:	fc                   	cld    
f0105d38:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d3a:	eb 03                	jmp    f0105d3f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d3c:	fc                   	cld    
f0105d3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d3f:	89 f8                	mov    %edi,%eax
f0105d41:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105d44:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105d47:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105d4a:	89 ec                	mov    %ebp,%esp
f0105d4c:	5d                   	pop    %ebp
f0105d4d:	c3                   	ret    

f0105d4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d4e:	55                   	push   %ebp
f0105d4f:	89 e5                	mov    %esp,%ebp
f0105d51:	83 ec 08             	sub    $0x8,%esp
f0105d54:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105d57:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105d5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d5d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d63:	39 c6                	cmp    %eax,%esi
f0105d65:	73 36                	jae    f0105d9d <memmove+0x4f>
f0105d67:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d6a:	39 d0                	cmp    %edx,%eax
f0105d6c:	73 2f                	jae    f0105d9d <memmove+0x4f>
		s += n;
		d += n;
f0105d6e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d71:	f6 c2 03             	test   $0x3,%dl
f0105d74:	75 1b                	jne    f0105d91 <memmove+0x43>
f0105d76:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d7c:	75 13                	jne    f0105d91 <memmove+0x43>
f0105d7e:	f6 c1 03             	test   $0x3,%cl
f0105d81:	75 0e                	jne    f0105d91 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105d83:	83 ef 04             	sub    $0x4,%edi
f0105d86:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105d89:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105d8c:	fd                   	std    
f0105d8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d8f:	eb 09                	jmp    f0105d9a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105d91:	83 ef 01             	sub    $0x1,%edi
f0105d94:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105d97:	fd                   	std    
f0105d98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105d9a:	fc                   	cld    
f0105d9b:	eb 20                	jmp    f0105dbd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d9d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105da3:	75 13                	jne    f0105db8 <memmove+0x6a>
f0105da5:	a8 03                	test   $0x3,%al
f0105da7:	75 0f                	jne    f0105db8 <memmove+0x6a>
f0105da9:	f6 c1 03             	test   $0x3,%cl
f0105dac:	75 0a                	jne    f0105db8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105dae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105db1:	89 c7                	mov    %eax,%edi
f0105db3:	fc                   	cld    
f0105db4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105db6:	eb 05                	jmp    f0105dbd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105db8:	89 c7                	mov    %eax,%edi
f0105dba:	fc                   	cld    
f0105dbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105dbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105dc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105dc3:	89 ec                	mov    %ebp,%esp
f0105dc5:	5d                   	pop    %ebp
f0105dc6:	c3                   	ret    

f0105dc7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dc7:	55                   	push   %ebp
f0105dc8:	89 e5                	mov    %esp,%ebp
f0105dca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105dcd:	8b 45 10             	mov    0x10(%ebp),%eax
f0105dd0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dde:	89 04 24             	mov    %eax,(%esp)
f0105de1:	e8 68 ff ff ff       	call   f0105d4e <memmove>
}
f0105de6:	c9                   	leave  
f0105de7:	c3                   	ret    

f0105de8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105de8:	55                   	push   %ebp
f0105de9:	89 e5                	mov    %esp,%ebp
f0105deb:	57                   	push   %edi
f0105dec:	56                   	push   %esi
f0105ded:	53                   	push   %ebx
f0105dee:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105df1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105df7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dfc:	eb 1a                	jmp    f0105e18 <memcmp+0x30>
		if (*s1 != *s2)
f0105dfe:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0105e02:	83 c2 01             	add    $0x1,%edx
f0105e05:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0105e0a:	38 c8                	cmp    %cl,%al
f0105e0c:	74 0a                	je     f0105e18 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f0105e0e:	0f b6 c0             	movzbl %al,%eax
f0105e11:	0f b6 c9             	movzbl %cl,%ecx
f0105e14:	29 c8                	sub    %ecx,%eax
f0105e16:	eb 09                	jmp    f0105e21 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e18:	39 da                	cmp    %ebx,%edx
f0105e1a:	75 e2                	jne    f0105dfe <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e21:	5b                   	pop    %ebx
f0105e22:	5e                   	pop    %esi
f0105e23:	5f                   	pop    %edi
f0105e24:	5d                   	pop    %ebp
f0105e25:	c3                   	ret    

f0105e26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e26:	55                   	push   %ebp
f0105e27:	89 e5                	mov    %esp,%ebp
f0105e29:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105e2f:	89 c2                	mov    %eax,%edx
f0105e31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e34:	eb 07                	jmp    f0105e3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e36:	38 08                	cmp    %cl,(%eax)
f0105e38:	74 07                	je     f0105e41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e3a:	83 c0 01             	add    $0x1,%eax
f0105e3d:	39 d0                	cmp    %edx,%eax
f0105e3f:	72 f5                	jb     f0105e36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e41:	5d                   	pop    %ebp
f0105e42:	c3                   	ret    

f0105e43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e43:	55                   	push   %ebp
f0105e44:	89 e5                	mov    %esp,%ebp
f0105e46:	57                   	push   %edi
f0105e47:	56                   	push   %esi
f0105e48:	53                   	push   %ebx
f0105e49:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e4f:	eb 03                	jmp    f0105e54 <strtol+0x11>
		s++;
f0105e51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e54:	0f b6 02             	movzbl (%edx),%eax
f0105e57:	3c 20                	cmp    $0x20,%al
f0105e59:	74 f6                	je     f0105e51 <strtol+0xe>
f0105e5b:	3c 09                	cmp    $0x9,%al
f0105e5d:	74 f2                	je     f0105e51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105e5f:	3c 2b                	cmp    $0x2b,%al
f0105e61:	75 0a                	jne    f0105e6d <strtol+0x2a>
		s++;
f0105e63:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e66:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e6b:	eb 10                	jmp    f0105e7d <strtol+0x3a>
f0105e6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105e72:	3c 2d                	cmp    $0x2d,%al
f0105e74:	75 07                	jne    f0105e7d <strtol+0x3a>
		s++, neg = 1;
f0105e76:	8d 52 01             	lea    0x1(%edx),%edx
f0105e79:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e7d:	85 db                	test   %ebx,%ebx
f0105e7f:	0f 94 c0             	sete   %al
f0105e82:	74 05                	je     f0105e89 <strtol+0x46>
f0105e84:	83 fb 10             	cmp    $0x10,%ebx
f0105e87:	75 15                	jne    f0105e9e <strtol+0x5b>
f0105e89:	80 3a 30             	cmpb   $0x30,(%edx)
f0105e8c:	75 10                	jne    f0105e9e <strtol+0x5b>
f0105e8e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105e92:	75 0a                	jne    f0105e9e <strtol+0x5b>
		s += 2, base = 16;
f0105e94:	83 c2 02             	add    $0x2,%edx
f0105e97:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105e9c:	eb 13                	jmp    f0105eb1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105e9e:	84 c0                	test   %al,%al
f0105ea0:	74 0f                	je     f0105eb1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105ea2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105ea7:	80 3a 30             	cmpb   $0x30,(%edx)
f0105eaa:	75 05                	jne    f0105eb1 <strtol+0x6e>
		s++, base = 8;
f0105eac:	83 c2 01             	add    $0x1,%edx
f0105eaf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0105eb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105eb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105eb8:	0f b6 0a             	movzbl (%edx),%ecx
f0105ebb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105ebe:	80 fb 09             	cmp    $0x9,%bl
f0105ec1:	77 08                	ja     f0105ecb <strtol+0x88>
			dig = *s - '0';
f0105ec3:	0f be c9             	movsbl %cl,%ecx
f0105ec6:	83 e9 30             	sub    $0x30,%ecx
f0105ec9:	eb 1e                	jmp    f0105ee9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105ecb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105ece:	80 fb 19             	cmp    $0x19,%bl
f0105ed1:	77 08                	ja     f0105edb <strtol+0x98>
			dig = *s - 'a' + 10;
f0105ed3:	0f be c9             	movsbl %cl,%ecx
f0105ed6:	83 e9 57             	sub    $0x57,%ecx
f0105ed9:	eb 0e                	jmp    f0105ee9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105edb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105ede:	80 fb 19             	cmp    $0x19,%bl
f0105ee1:	77 14                	ja     f0105ef7 <strtol+0xb4>
			dig = *s - 'A' + 10;
f0105ee3:	0f be c9             	movsbl %cl,%ecx
f0105ee6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105ee9:	39 f1                	cmp    %esi,%ecx
f0105eeb:	7d 0e                	jge    f0105efb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f0105eed:	83 c2 01             	add    $0x1,%edx
f0105ef0:	0f af c6             	imul   %esi,%eax
f0105ef3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105ef5:	eb c1                	jmp    f0105eb8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105ef7:	89 c1                	mov    %eax,%ecx
f0105ef9:	eb 02                	jmp    f0105efd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105efb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105efd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f01:	74 05                	je     f0105f08 <strtol+0xc5>
		*endptr = (char *) s;
f0105f03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f06:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105f08:	89 ca                	mov    %ecx,%edx
f0105f0a:	f7 da                	neg    %edx
f0105f0c:	85 ff                	test   %edi,%edi
f0105f0e:	0f 45 c2             	cmovne %edx,%eax
}
f0105f11:	5b                   	pop    %ebx
f0105f12:	5e                   	pop    %esi
f0105f13:	5f                   	pop    %edi
f0105f14:	5d                   	pop    %ebp
f0105f15:	c3                   	ret    
f0105f16:	66 90                	xchg   %ax,%ax

f0105f18 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f18:	fa                   	cli    

	xorw    %ax, %ax
f0105f19:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f1b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f1d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f1f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f21:	0f 01 16             	lgdtl  (%esi)
f0105f24:	74 70                	je     f0105f96 <mpentry_end+0x4>
	movl    %cr0, %eax
f0105f26:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f29:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f2d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f30:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f36:	08 00                	or     %al,(%eax)

f0105f38 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f38:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f3c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f3e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f40:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f42:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f46:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f48:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f4a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105f4f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f52:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f55:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f5a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f5d:	8b 25 84 ce 22 f0    	mov    0xf022ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f63:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f68:	b8 f6 01 10 f0       	mov    $0xf01001f6,%eax
	call    *%eax
f0105f6d:	ff d0                	call   *%eax

f0105f6f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f6f:	eb fe                	jmp    f0105f6f <spin>
f0105f71:	8d 76 00             	lea    0x0(%esi),%esi

f0105f74 <gdt>:
	...
f0105f7c:	ff                   	(bad)  
f0105f7d:	ff 00                	incl   (%eax)
f0105f7f:	00 00                	add    %al,(%eax)
f0105f81:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105f88:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105f8c <gdtdesc>:
f0105f8c:	17                   	pop    %ss
f0105f8d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105f92 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105f92:	90                   	nop
f0105f93:	66 90                	xchg   %ax,%ax
f0105f95:	66 90                	xchg   %ax,%ax
f0105f97:	66 90                	xchg   %ax,%ax
f0105f99:	66 90                	xchg   %ax,%ax
f0105f9b:	66 90                	xchg   %ax,%ax
f0105f9d:	66 90                	xchg   %ax,%ax
f0105f9f:	90                   	nop

f0105fa0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105fa0:	55                   	push   %ebp
f0105fa1:	89 e5                	mov    %esp,%ebp
f0105fa3:	56                   	push   %esi
f0105fa4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0105fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105faa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105faf:	eb 09                	jmp    f0105fba <sum+0x1a>
		sum += ((uint8_t *)addr)[i];
f0105fb1:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105fb5:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105fb7:	83 c1 01             	add    $0x1,%ecx
f0105fba:	39 d1                	cmp    %edx,%ecx
f0105fbc:	7c f3                	jl     f0105fb1 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105fbe:	89 d8                	mov    %ebx,%eax
f0105fc0:	5b                   	pop    %ebx
f0105fc1:	5e                   	pop    %esi
f0105fc2:	5d                   	pop    %ebp
f0105fc3:	c3                   	ret    

f0105fc4 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fc4:	55                   	push   %ebp
f0105fc5:	89 e5                	mov    %esp,%ebp
f0105fc7:	56                   	push   %esi
f0105fc8:	53                   	push   %ebx
f0105fc9:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105fcc:	8b 0d 88 ce 22 f0    	mov    0xf022ce88,%ecx
f0105fd2:	89 c3                	mov    %eax,%ebx
f0105fd4:	c1 eb 0c             	shr    $0xc,%ebx
f0105fd7:	39 cb                	cmp    %ecx,%ebx
f0105fd9:	72 20                	jb     f0105ffb <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fdf:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0105fe6:	f0 
f0105fe7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105fee:	00 
f0105fef:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f0105ff6:	e8 45 a0 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105ffb:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ffe:	89 f2                	mov    %esi,%edx
f0106000:	c1 ea 0c             	shr    $0xc,%edx
f0106003:	39 d1                	cmp    %edx,%ecx
f0106005:	77 20                	ja     f0106027 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106007:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010600b:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f0106012:	f0 
f0106013:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010601a:	00 
f010601b:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f0106022:	e8 19 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106027:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010602d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106033:	eb 2f                	jmp    f0106064 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106035:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010603c:	00 
f010603d:	c7 44 24 04 15 85 10 	movl   $0xf0108515,0x4(%esp)
f0106044:	f0 
f0106045:	89 1c 24             	mov    %ebx,(%esp)
f0106048:	e8 9b fd ff ff       	call   f0105de8 <memcmp>
f010604d:	85 c0                	test   %eax,%eax
f010604f:	75 10                	jne    f0106061 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0106051:	ba 10 00 00 00       	mov    $0x10,%edx
f0106056:	89 d8                	mov    %ebx,%eax
f0106058:	e8 43 ff ff ff       	call   f0105fa0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010605d:	84 c0                	test   %al,%al
f010605f:	74 0c                	je     f010606d <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106061:	83 c3 10             	add    $0x10,%ebx
f0106064:	39 f3                	cmp    %esi,%ebx
f0106066:	72 cd                	jb     f0106035 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106068:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010606d:	89 d8                	mov    %ebx,%eax
f010606f:	83 c4 10             	add    $0x10,%esp
f0106072:	5b                   	pop    %ebx
f0106073:	5e                   	pop    %esi
f0106074:	5d                   	pop    %ebp
f0106075:	c3                   	ret    

f0106076 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106076:	55                   	push   %ebp
f0106077:	89 e5                	mov    %esp,%ebp
f0106079:	57                   	push   %edi
f010607a:	56                   	push   %esi
f010607b:	53                   	push   %ebx
f010607c:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010607f:	c7 05 c0 d3 22 f0 20 	movl   $0xf022d020,0xf022d3c0
f0106086:	d0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106089:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f0106090:	75 24                	jne    f01060b6 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106092:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106099:	00 
f010609a:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01060a1:	f0 
f01060a2:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01060a9:	00 
f01060aa:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f01060b1:	e8 8a 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060b6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060bd:	85 c0                	test   %eax,%eax
f01060bf:	74 16                	je     f01060d7 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01060c1:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01060c4:	ba 00 04 00 00       	mov    $0x400,%edx
f01060c9:	e8 f6 fe ff ff       	call   f0105fc4 <mpsearch1>
f01060ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060d1:	85 c0                	test   %eax,%eax
f01060d3:	75 3c                	jne    f0106111 <mp_init+0x9b>
f01060d5:	eb 20                	jmp    f01060f7 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01060d7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01060de:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01060e1:	2d 00 04 00 00       	sub    $0x400,%eax
f01060e6:	ba 00 04 00 00       	mov    $0x400,%edx
f01060eb:	e8 d4 fe ff ff       	call   f0105fc4 <mpsearch1>
f01060f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060f3:	85 c0                	test   %eax,%eax
f01060f5:	75 1a                	jne    f0106111 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01060f7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060fc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106101:	e8 be fe ff ff       	call   f0105fc4 <mpsearch1>
f0106106:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106109:	85 c0                	test   %eax,%eax
f010610b:	0f 84 21 02 00 00    	je     f0106332 <mp_init+0x2bc>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106114:	8b 78 04             	mov    0x4(%eax),%edi
f0106117:	85 ff                	test   %edi,%edi
f0106119:	74 06                	je     f0106121 <mp_init+0xab>
f010611b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010611f:	74 11                	je     f0106132 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106121:	c7 04 24 78 83 10 f0 	movl   $0xf0108378,(%esp)
f0106128:	e8 61 de ff ff       	call   f0103f8e <cprintf>
f010612d:	e9 00 02 00 00       	jmp    f0106332 <mp_init+0x2bc>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106132:	89 f8                	mov    %edi,%eax
f0106134:	c1 e8 0c             	shr    $0xc,%eax
f0106137:	3b 05 88 ce 22 f0    	cmp    0xf022ce88,%eax
f010613d:	72 20                	jb     f010615f <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010613f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106143:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f010614a:	f0 
f010614b:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106152:	00 
f0106153:	c7 04 24 05 85 10 f0 	movl   $0xf0108505,(%esp)
f010615a:	e8 e1 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010615f:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106165:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010616c:	00 
f010616d:	c7 44 24 04 1a 85 10 	movl   $0xf010851a,0x4(%esp)
f0106174:	f0 
f0106175:	89 3c 24             	mov    %edi,(%esp)
f0106178:	e8 6b fc ff ff       	call   f0105de8 <memcmp>
f010617d:	85 c0                	test   %eax,%eax
f010617f:	74 11                	je     f0106192 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106181:	c7 04 24 a8 83 10 f0 	movl   $0xf01083a8,(%esp)
f0106188:	e8 01 de ff ff       	call   f0103f8e <cprintf>
f010618d:	e9 a0 01 00 00       	jmp    f0106332 <mp_init+0x2bc>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106192:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106196:	0f b7 d3             	movzwl %bx,%edx
f0106199:	89 f8                	mov    %edi,%eax
f010619b:	e8 00 fe ff ff       	call   f0105fa0 <sum>
f01061a0:	84 c0                	test   %al,%al
f01061a2:	74 11                	je     f01061b5 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061a4:	c7 04 24 dc 83 10 f0 	movl   $0xf01083dc,(%esp)
f01061ab:	e8 de dd ff ff       	call   f0103f8e <cprintf>
f01061b0:	e9 7d 01 00 00       	jmp    f0106332 <mp_init+0x2bc>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01061b5:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01061b9:	3c 01                	cmp    $0x1,%al
f01061bb:	74 1d                	je     f01061da <mp_init+0x164>
f01061bd:	3c 04                	cmp    $0x4,%al
f01061bf:	90                   	nop
f01061c0:	74 18                	je     f01061da <mp_init+0x164>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061c2:	0f b6 c0             	movzbl %al,%eax
f01061c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061c9:	c7 04 24 00 84 10 f0 	movl   $0xf0108400,(%esp)
f01061d0:	e8 b9 dd ff ff       	call   f0103f8e <cprintf>
f01061d5:	e9 58 01 00 00       	jmp    f0106332 <mp_init+0x2bc>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01061da:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f01061de:	0f b7 db             	movzwl %bx,%ebx
f01061e1:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01061e4:	e8 b7 fd ff ff       	call   f0105fa0 <sum>
f01061e9:	02 47 2a             	add    0x2a(%edi),%al
f01061ec:	84 c0                	test   %al,%al
f01061ee:	74 11                	je     f0106201 <mp_init+0x18b>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01061f0:	c7 04 24 20 84 10 f0 	movl   $0xf0108420,(%esp)
f01061f7:	e8 92 dd ff ff       	call   f0103f8e <cprintf>
f01061fc:	e9 31 01 00 00       	jmp    f0106332 <mp_init+0x2bc>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106201:	85 ff                	test   %edi,%edi
f0106203:	0f 84 29 01 00 00    	je     f0106332 <mp_init+0x2bc>
		return;
	ismp = 1;
f0106209:	c7 05 00 d0 22 f0 01 	movl   $0x1,0xf022d000
f0106210:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106213:	8b 47 24             	mov    0x24(%edi),%eax
f0106216:	a3 00 e0 26 f0       	mov    %eax,0xf026e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010621b:	8d 77 2c             	lea    0x2c(%edi),%esi
f010621e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106223:	e9 83 00 00 00       	jmp    f01062ab <mp_init+0x235>
		switch (*p) {
f0106228:	0f b6 06             	movzbl (%esi),%eax
f010622b:	84 c0                	test   %al,%al
f010622d:	74 06                	je     f0106235 <mp_init+0x1bf>
f010622f:	3c 04                	cmp    $0x4,%al
f0106231:	77 54                	ja     f0106287 <mp_init+0x211>
f0106233:	eb 4d                	jmp    f0106282 <mp_init+0x20c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106235:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106239:	74 11                	je     f010624c <mp_init+0x1d6>
				bootcpu = &cpus[ncpu];
f010623b:	6b 05 c4 d3 22 f0 74 	imul   $0x74,0xf022d3c4,%eax
f0106242:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106247:	a3 c0 d3 22 f0       	mov    %eax,0xf022d3c0
			if (ncpu < NCPU) {
f010624c:	a1 c4 d3 22 f0       	mov    0xf022d3c4,%eax
f0106251:	83 f8 07             	cmp    $0x7,%eax
f0106254:	7f 13                	jg     f0106269 <mp_init+0x1f3>
				cpus[ncpu].cpu_id = ncpu;
f0106256:	6b d0 74             	imul   $0x74,%eax,%edx
f0106259:	88 82 20 d0 22 f0    	mov    %al,-0xfdd2fe0(%edx)
				ncpu++;
f010625f:	83 c0 01             	add    $0x1,%eax
f0106262:	a3 c4 d3 22 f0       	mov    %eax,0xf022d3c4
f0106267:	eb 14                	jmp    f010627d <mp_init+0x207>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106269:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010626d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106271:	c7 04 24 50 84 10 f0 	movl   $0xf0108450,(%esp)
f0106278:	e8 11 dd ff ff       	call   f0103f8e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010627d:	83 c6 14             	add    $0x14,%esi
			continue;
f0106280:	eb 26                	jmp    f01062a8 <mp_init+0x232>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106282:	83 c6 08             	add    $0x8,%esi
			continue;
f0106285:	eb 21                	jmp    f01062a8 <mp_init+0x232>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106287:	0f b6 c0             	movzbl %al,%eax
f010628a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010628e:	c7 04 24 78 84 10 f0 	movl   $0xf0108478,(%esp)
f0106295:	e8 f4 dc ff ff       	call   f0103f8e <cprintf>
			ismp = 0;
f010629a:	c7 05 00 d0 22 f0 00 	movl   $0x0,0xf022d000
f01062a1:	00 00 00 
			i = conf->entry;
f01062a4:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062a8:	83 c3 01             	add    $0x1,%ebx
f01062ab:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f01062af:	39 c3                	cmp    %eax,%ebx
f01062b1:	0f 82 71 ff ff ff    	jb     f0106228 <mp_init+0x1b2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062b7:	a1 c0 d3 22 f0       	mov    0xf022d3c0,%eax
f01062bc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062c3:	83 3d 00 d0 22 f0 00 	cmpl   $0x0,0xf022d000
f01062ca:	75 22                	jne    f01062ee <mp_init+0x278>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01062cc:	c7 05 c4 d3 22 f0 01 	movl   $0x1,0xf022d3c4
f01062d3:	00 00 00 
		lapicaddr = 0;
f01062d6:	c7 05 00 e0 26 f0 00 	movl   $0x0,0xf026e000
f01062dd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01062e0:	c7 04 24 98 84 10 f0 	movl   $0xf0108498,(%esp)
f01062e7:	e8 a2 dc ff ff       	call   f0103f8e <cprintf>
		return;
f01062ec:	eb 44                	jmp    f0106332 <mp_init+0x2bc>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01062ee:	8b 15 c4 d3 22 f0    	mov    0xf022d3c4,%edx
f01062f4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01062f8:	0f b6 00             	movzbl (%eax),%eax
f01062fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ff:	c7 04 24 1f 85 10 f0 	movl   $0xf010851f,(%esp)
f0106306:	e8 83 dc ff ff       	call   f0103f8e <cprintf>

	if (mp->imcrp) {
f010630b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010630e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106312:	74 1e                	je     f0106332 <mp_init+0x2bc>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106314:	c7 04 24 c4 84 10 f0 	movl   $0xf01084c4,(%esp)
f010631b:	e8 6e dc ff ff       	call   f0103f8e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106320:	ba 22 00 00 00       	mov    $0x22,%edx
f0106325:	b8 70 00 00 00       	mov    $0x70,%eax
f010632a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010632b:	b2 23                	mov    $0x23,%dl
f010632d:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010632e:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106331:	ee                   	out    %al,(%dx)
	}
}
f0106332:	83 c4 2c             	add    $0x2c,%esp
f0106335:	5b                   	pop    %ebx
f0106336:	5e                   	pop    %esi
f0106337:	5f                   	pop    %edi
f0106338:	5d                   	pop    %ebp
f0106339:	c3                   	ret    
f010633a:	66 90                	xchg   %ax,%ax

f010633c <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010633c:	55                   	push   %ebp
f010633d:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010633f:	c1 e0 02             	shl    $0x2,%eax
f0106342:	03 05 04 e0 26 f0    	add    0xf026e004,%eax
f0106348:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010634a:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f010634f:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106352:	5d                   	pop    %ebp
f0106353:	c3                   	ret    

f0106354 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106354:	55                   	push   %ebp
f0106355:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106357:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
		return lapic[ID] >> 24;
	return 0;
f010635d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106362:	85 d2                	test   %edx,%edx
f0106364:	74 06                	je     f010636c <cpunum+0x18>
		return lapic[ID] >> 24;
f0106366:	8b 42 20             	mov    0x20(%edx),%eax
f0106369:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010636c:	5d                   	pop    %ebp
f010636d:	c3                   	ret    

f010636e <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010636e:	55                   	push   %ebp
f010636f:	89 e5                	mov    %esp,%ebp
f0106371:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106374:	a1 00 e0 26 f0       	mov    0xf026e000,%eax
f0106379:	85 c0                	test   %eax,%eax
f010637b:	0f 84 1c 01 00 00    	je     f010649d <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106381:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106388:	00 
f0106389:	89 04 24             	mov    %eax,(%esp)
f010638c:	e8 6c af ff ff       	call   f01012fd <mmio_map_region>
f0106391:	a3 04 e0 26 f0       	mov    %eax,0xf026e004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106396:	ba 27 01 00 00       	mov    $0x127,%edx
f010639b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063a0:	e8 97 ff ff ff       	call   f010633c <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01063a5:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063aa:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063af:	e8 88 ff ff ff       	call   f010633c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063b4:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063b9:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063be:	e8 79 ff ff ff       	call   f010633c <lapicw>
	lapicw(TICR, 10000000); 
f01063c3:	ba 80 96 98 00       	mov    $0x989680,%edx
f01063c8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01063cd:	e8 6a ff ff ff       	call   f010633c <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01063d2:	e8 7d ff ff ff       	call   f0106354 <cpunum>
f01063d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01063da:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f01063df:	39 05 c0 d3 22 f0    	cmp    %eax,0xf022d3c0
f01063e5:	74 0f                	je     f01063f6 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01063e7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063ec:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01063f1:	e8 46 ff ff ff       	call   f010633c <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01063f6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063fb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106400:	e8 37 ff ff ff       	call   f010633c <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106405:	a1 04 e0 26 f0       	mov    0xf026e004,%eax
f010640a:	8b 40 30             	mov    0x30(%eax),%eax
f010640d:	c1 e8 10             	shr    $0x10,%eax
f0106410:	3c 03                	cmp    $0x3,%al
f0106412:	76 0f                	jbe    f0106423 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106414:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106419:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010641e:	e8 19 ff ff ff       	call   f010633c <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106423:	ba 33 00 00 00       	mov    $0x33,%edx
f0106428:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010642d:	e8 0a ff ff ff       	call   f010633c <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106432:	ba 00 00 00 00       	mov    $0x0,%edx
f0106437:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010643c:	e8 fb fe ff ff       	call   f010633c <lapicw>
	lapicw(ESR, 0);
f0106441:	ba 00 00 00 00       	mov    $0x0,%edx
f0106446:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010644b:	e8 ec fe ff ff       	call   f010633c <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106450:	ba 00 00 00 00       	mov    $0x0,%edx
f0106455:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010645a:	e8 dd fe ff ff       	call   f010633c <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010645f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106464:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106469:	e8 ce fe ff ff       	call   f010633c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010646e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106473:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106478:	e8 bf fe ff ff       	call   f010633c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010647d:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f0106483:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106489:	f6 c4 10             	test   $0x10,%ah
f010648c:	75 f5                	jne    f0106483 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010648e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106493:	b8 20 00 00 00       	mov    $0x20,%eax
f0106498:	e8 9f fe ff ff       	call   f010633c <lapicw>
}
f010649d:	c9                   	leave  
f010649e:	c3                   	ret    

f010649f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010649f:	55                   	push   %ebp
f01064a0:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01064a2:	83 3d 04 e0 26 f0 00 	cmpl   $0x0,0xf026e004
f01064a9:	74 0f                	je     f01064ba <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01064ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b0:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064b5:	e8 82 fe ff ff       	call   f010633c <lapicw>
}
f01064ba:	5d                   	pop    %ebp
f01064bb:	c3                   	ret    

f01064bc <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064bc:	55                   	push   %ebp
f01064bd:	89 e5                	mov    %esp,%ebp
f01064bf:	56                   	push   %esi
f01064c0:	53                   	push   %ebx
f01064c1:	83 ec 10             	sub    $0x10,%esp
f01064c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01064c7:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01064cb:	ba 70 00 00 00       	mov    $0x70,%edx
f01064d0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01064d5:	ee                   	out    %al,(%dx)
f01064d6:	b2 71                	mov    $0x71,%dl
f01064d8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01064dd:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064de:	83 3d 88 ce 22 f0 00 	cmpl   $0x0,0xf022ce88
f01064e5:	75 24                	jne    f010650b <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064e7:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01064ee:	00 
f01064ef:	c7 44 24 08 84 6a 10 	movl   $0xf0106a84,0x8(%esp)
f01064f6:	f0 
f01064f7:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01064fe:	00 
f01064ff:	c7 04 24 3c 85 10 f0 	movl   $0xf010853c,(%esp)
f0106506:	e8 35 9b ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010650b:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106512:	00 00 
	wrv[1] = addr >> 4;
f0106514:	89 f0                	mov    %esi,%eax
f0106516:	c1 e8 04             	shr    $0x4,%eax
f0106519:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010651f:	c1 e3 18             	shl    $0x18,%ebx
f0106522:	89 da                	mov    %ebx,%edx
f0106524:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106529:	e8 0e fe ff ff       	call   f010633c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010652e:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106533:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106538:	e8 ff fd ff ff       	call   f010633c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010653d:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106542:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106547:	e8 f0 fd ff ff       	call   f010633c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010654c:	c1 ee 0c             	shr    $0xc,%esi
f010654f:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106555:	89 da                	mov    %ebx,%edx
f0106557:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010655c:	e8 db fd ff ff       	call   f010633c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106561:	89 f2                	mov    %esi,%edx
f0106563:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106568:	e8 cf fd ff ff       	call   f010633c <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010656d:	89 da                	mov    %ebx,%edx
f010656f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106574:	e8 c3 fd ff ff       	call   f010633c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106579:	89 f2                	mov    %esi,%edx
f010657b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106580:	e8 b7 fd ff ff       	call   f010633c <lapicw>
		microdelay(200);
	}
}
f0106585:	83 c4 10             	add    $0x10,%esp
f0106588:	5b                   	pop    %ebx
f0106589:	5e                   	pop    %esi
f010658a:	5d                   	pop    %ebp
f010658b:	c3                   	ret    

f010658c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010658c:	55                   	push   %ebp
f010658d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010658f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106592:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106598:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010659d:	e8 9a fd ff ff       	call   f010633c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065a2:	8b 15 04 e0 26 f0    	mov    0xf026e004,%edx
f01065a8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065ae:	f6 c4 10             	test   $0x10,%ah
f01065b1:	75 f5                	jne    f01065a8 <lapic_ipi+0x1c>
		;
}
f01065b3:	5d                   	pop    %ebp
f01065b4:	c3                   	ret    
f01065b5:	66 90                	xchg   %ax,%ax
f01065b7:	90                   	nop

f01065b8 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01065b8:	55                   	push   %ebp
f01065b9:	89 e5                	mov    %esp,%ebp
f01065bb:	53                   	push   %ebx
f01065bc:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01065bf:	ba 00 00 00 00       	mov    $0x0,%edx
f01065c4:	83 38 00             	cmpl   $0x0,(%eax)
f01065c7:	74 18                	je     f01065e1 <holding+0x29>
f01065c9:	8b 58 08             	mov    0x8(%eax),%ebx
f01065cc:	e8 83 fd ff ff       	call   f0106354 <cpunum>
f01065d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01065d4:	05 20 d0 22 f0       	add    $0xf022d020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01065d9:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01065db:	0f 94 c2             	sete   %dl
f01065de:	0f b6 d2             	movzbl %dl,%edx
}
f01065e1:	89 d0                	mov    %edx,%eax
f01065e3:	83 c4 04             	add    $0x4,%esp
f01065e6:	5b                   	pop    %ebx
f01065e7:	5d                   	pop    %ebp
f01065e8:	c3                   	ret    

f01065e9 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065e9:	55                   	push   %ebp
f01065ea:	89 e5                	mov    %esp,%ebp
f01065ec:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065f8:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106602:	5d                   	pop    %ebp
f0106603:	c3                   	ret    

f0106604 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106604:	55                   	push   %ebp
f0106605:	89 e5                	mov    %esp,%ebp
f0106607:	53                   	push   %ebx
f0106608:	83 ec 24             	sub    $0x24,%esp
f010660b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010660e:	89 d8                	mov    %ebx,%eax
f0106610:	e8 a3 ff ff ff       	call   f01065b8 <holding>
f0106615:	85 c0                	test   %eax,%eax
f0106617:	74 30                	je     f0106649 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106619:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010661c:	e8 33 fd ff ff       	call   f0106354 <cpunum>
f0106621:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106625:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106629:	c7 44 24 08 4c 85 10 	movl   $0xf010854c,0x8(%esp)
f0106630:	f0 
f0106631:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106638:	00 
f0106639:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f0106640:	e8 fb 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106645:	f3 90                	pause  
f0106647:	eb 05                	jmp    f010664e <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106649:	ba 01 00 00 00       	mov    $0x1,%edx
f010664e:	89 d0                	mov    %edx,%eax
f0106650:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106653:	85 c0                	test   %eax,%eax
f0106655:	75 ee                	jne    f0106645 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106657:	e8 f8 fc ff ff       	call   f0106354 <cpunum>
f010665c:	6b c0 74             	imul   $0x74,%eax,%eax
f010665f:	05 20 d0 22 f0       	add    $0xf022d020,%eax
f0106664:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106667:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010666a:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010666c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106671:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106677:	76 12                	jbe    f010668b <spin_lock+0x87>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106679:	8b 4a 04             	mov    0x4(%edx),%ecx
f010667c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010667f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106681:	83 c0 01             	add    $0x1,%eax
f0106684:	83 f8 0a             	cmp    $0xa,%eax
f0106687:	75 e8                	jne    f0106671 <spin_lock+0x6d>
f0106689:	eb 0f                	jmp    f010669a <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010668b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106692:	83 c0 01             	add    $0x1,%eax
f0106695:	83 f8 09             	cmp    $0x9,%eax
f0106698:	7e f1                	jle    f010668b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010669a:	83 c4 24             	add    $0x24,%esp
f010669d:	5b                   	pop    %ebx
f010669e:	5d                   	pop    %ebp
f010669f:	c3                   	ret    

f01066a0 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01066a0:	55                   	push   %ebp
f01066a1:	89 e5                	mov    %esp,%ebp
f01066a3:	81 ec 88 00 00 00    	sub    $0x88,%esp
f01066a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01066ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01066af:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01066b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01066b5:	89 d8                	mov    %ebx,%eax
f01066b7:	e8 fc fe ff ff       	call   f01065b8 <holding>
f01066bc:	85 c0                	test   %eax,%eax
f01066be:	0f 85 d3 00 00 00    	jne    f0106797 <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066c4:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01066cb:	00 
f01066cc:	8d 43 0c             	lea    0xc(%ebx),%eax
f01066cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066d3:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01066d6:	89 34 24             	mov    %esi,(%esp)
f01066d9:	e8 70 f6 ff ff       	call   f0105d4e <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066de:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066e1:	0f b6 38             	movzbl (%eax),%edi
f01066e4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066e7:	e8 68 fc ff ff       	call   f0106354 <cpunum>
f01066ec:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01066f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066f8:	c7 04 24 78 85 10 f0 	movl   $0xf0108578,(%esp)
f01066ff:	e8 8a d8 ff ff       	call   f0103f8e <cprintf>
f0106704:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106706:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106709:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010670c:	89 c7                	mov    %eax,%edi
f010670e:	eb 63                	jmp    f0106773 <spin_unlock+0xd3>
f0106710:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106714:	89 04 24             	mov    %eax,(%esp)
f0106717:	e8 ea ea ff ff       	call   f0105206 <debuginfo_eip>
f010671c:	85 c0                	test   %eax,%eax
f010671e:	78 39                	js     f0106759 <spin_unlock+0xb9>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106720:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106722:	89 c2                	mov    %eax,%edx
f0106724:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106727:	89 54 24 18          	mov    %edx,0x18(%esp)
f010672b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010672e:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106732:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106735:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106739:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010673c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106740:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106743:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106747:	89 44 24 04          	mov    %eax,0x4(%esp)
f010674b:	c7 04 24 c0 85 10 f0 	movl   $0xf01085c0,(%esp)
f0106752:	e8 37 d8 ff ff       	call   f0103f8e <cprintf>
f0106757:	eb 12                	jmp    f010676b <spin_unlock+0xcb>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106759:	8b 06                	mov    (%esi),%eax
f010675b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010675f:	c7 04 24 d7 85 10 f0 	movl   $0xf01085d7,(%esp)
f0106766:	e8 23 d8 ff ff       	call   f0103f8e <cprintf>
f010676b:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010676e:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106771:	74 08                	je     f010677b <spin_unlock+0xdb>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106773:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106775:	8b 03                	mov    (%ebx),%eax
f0106777:	85 c0                	test   %eax,%eax
f0106779:	75 95                	jne    f0106710 <spin_unlock+0x70>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010677b:	c7 44 24 08 df 85 10 	movl   $0xf01085df,0x8(%esp)
f0106782:	f0 
f0106783:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010678a:	00 
f010678b:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f0106792:	e8 a9 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106797:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010679e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f01067a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01067aa:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01067ad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01067b0:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01067b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01067b6:	89 ec                	mov    %ebp,%esp
f01067b8:	5d                   	pop    %ebp
f01067b9:	c3                   	ret    
f01067ba:	66 90                	xchg   %ax,%ax
f01067bc:	66 90                	xchg   %ax,%ax
f01067be:	66 90                	xchg   %ax,%ax

f01067c0 <__udivdi3>:
f01067c0:	55                   	push   %ebp
f01067c1:	57                   	push   %edi
f01067c2:	56                   	push   %esi
f01067c3:	83 ec 0c             	sub    $0xc,%esp
f01067c6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01067ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01067ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01067d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01067d6:	85 c0                	test   %eax,%eax
f01067d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01067dc:	89 ea                	mov    %ebp,%edx
f01067de:	89 0c 24             	mov    %ecx,(%esp)
f01067e1:	75 2d                	jne    f0106810 <__udivdi3+0x50>
f01067e3:	39 e9                	cmp    %ebp,%ecx
f01067e5:	77 61                	ja     f0106848 <__udivdi3+0x88>
f01067e7:	85 c9                	test   %ecx,%ecx
f01067e9:	89 ce                	mov    %ecx,%esi
f01067eb:	75 0b                	jne    f01067f8 <__udivdi3+0x38>
f01067ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01067f2:	31 d2                	xor    %edx,%edx
f01067f4:	f7 f1                	div    %ecx
f01067f6:	89 c6                	mov    %eax,%esi
f01067f8:	31 d2                	xor    %edx,%edx
f01067fa:	89 e8                	mov    %ebp,%eax
f01067fc:	f7 f6                	div    %esi
f01067fe:	89 c5                	mov    %eax,%ebp
f0106800:	89 f8                	mov    %edi,%eax
f0106802:	f7 f6                	div    %esi
f0106804:	89 ea                	mov    %ebp,%edx
f0106806:	83 c4 0c             	add    $0xc,%esp
f0106809:	5e                   	pop    %esi
f010680a:	5f                   	pop    %edi
f010680b:	5d                   	pop    %ebp
f010680c:	c3                   	ret    
f010680d:	8d 76 00             	lea    0x0(%esi),%esi
f0106810:	39 e8                	cmp    %ebp,%eax
f0106812:	77 24                	ja     f0106838 <__udivdi3+0x78>
f0106814:	0f bd e8             	bsr    %eax,%ebp
f0106817:	83 f5 1f             	xor    $0x1f,%ebp
f010681a:	75 3c                	jne    f0106858 <__udivdi3+0x98>
f010681c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106820:	39 34 24             	cmp    %esi,(%esp)
f0106823:	0f 86 9f 00 00 00    	jbe    f01068c8 <__udivdi3+0x108>
f0106829:	39 d0                	cmp    %edx,%eax
f010682b:	0f 82 97 00 00 00    	jb     f01068c8 <__udivdi3+0x108>
f0106831:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106838:	31 d2                	xor    %edx,%edx
f010683a:	31 c0                	xor    %eax,%eax
f010683c:	83 c4 0c             	add    $0xc,%esp
f010683f:	5e                   	pop    %esi
f0106840:	5f                   	pop    %edi
f0106841:	5d                   	pop    %ebp
f0106842:	c3                   	ret    
f0106843:	90                   	nop
f0106844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106848:	89 f8                	mov    %edi,%eax
f010684a:	f7 f1                	div    %ecx
f010684c:	31 d2                	xor    %edx,%edx
f010684e:	83 c4 0c             	add    $0xc,%esp
f0106851:	5e                   	pop    %esi
f0106852:	5f                   	pop    %edi
f0106853:	5d                   	pop    %ebp
f0106854:	c3                   	ret    
f0106855:	8d 76 00             	lea    0x0(%esi),%esi
f0106858:	89 e9                	mov    %ebp,%ecx
f010685a:	8b 3c 24             	mov    (%esp),%edi
f010685d:	d3 e0                	shl    %cl,%eax
f010685f:	89 c6                	mov    %eax,%esi
f0106861:	b8 20 00 00 00       	mov    $0x20,%eax
f0106866:	29 e8                	sub    %ebp,%eax
f0106868:	89 c1                	mov    %eax,%ecx
f010686a:	d3 ef                	shr    %cl,%edi
f010686c:	89 e9                	mov    %ebp,%ecx
f010686e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106872:	8b 3c 24             	mov    (%esp),%edi
f0106875:	09 74 24 08          	or     %esi,0x8(%esp)
f0106879:	89 d6                	mov    %edx,%esi
f010687b:	d3 e7                	shl    %cl,%edi
f010687d:	89 c1                	mov    %eax,%ecx
f010687f:	89 3c 24             	mov    %edi,(%esp)
f0106882:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106886:	d3 ee                	shr    %cl,%esi
f0106888:	89 e9                	mov    %ebp,%ecx
f010688a:	d3 e2                	shl    %cl,%edx
f010688c:	89 c1                	mov    %eax,%ecx
f010688e:	d3 ef                	shr    %cl,%edi
f0106890:	09 d7                	or     %edx,%edi
f0106892:	89 f2                	mov    %esi,%edx
f0106894:	89 f8                	mov    %edi,%eax
f0106896:	f7 74 24 08          	divl   0x8(%esp)
f010689a:	89 d6                	mov    %edx,%esi
f010689c:	89 c7                	mov    %eax,%edi
f010689e:	f7 24 24             	mull   (%esp)
f01068a1:	39 d6                	cmp    %edx,%esi
f01068a3:	89 14 24             	mov    %edx,(%esp)
f01068a6:	72 30                	jb     f01068d8 <__udivdi3+0x118>
f01068a8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01068ac:	89 e9                	mov    %ebp,%ecx
f01068ae:	d3 e2                	shl    %cl,%edx
f01068b0:	39 c2                	cmp    %eax,%edx
f01068b2:	73 05                	jae    f01068b9 <__udivdi3+0xf9>
f01068b4:	3b 34 24             	cmp    (%esp),%esi
f01068b7:	74 1f                	je     f01068d8 <__udivdi3+0x118>
f01068b9:	89 f8                	mov    %edi,%eax
f01068bb:	31 d2                	xor    %edx,%edx
f01068bd:	e9 7a ff ff ff       	jmp    f010683c <__udivdi3+0x7c>
f01068c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01068c8:	31 d2                	xor    %edx,%edx
f01068ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01068cf:	e9 68 ff ff ff       	jmp    f010683c <__udivdi3+0x7c>
f01068d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068d8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01068db:	31 d2                	xor    %edx,%edx
f01068dd:	83 c4 0c             	add    $0xc,%esp
f01068e0:	5e                   	pop    %esi
f01068e1:	5f                   	pop    %edi
f01068e2:	5d                   	pop    %ebp
f01068e3:	c3                   	ret    
f01068e4:	66 90                	xchg   %ax,%ax
f01068e6:	66 90                	xchg   %ax,%ax
f01068e8:	66 90                	xchg   %ax,%ax
f01068ea:	66 90                	xchg   %ax,%ax
f01068ec:	66 90                	xchg   %ax,%ax
f01068ee:	66 90                	xchg   %ax,%ax

f01068f0 <__umoddi3>:
f01068f0:	55                   	push   %ebp
f01068f1:	57                   	push   %edi
f01068f2:	56                   	push   %esi
f01068f3:	83 ec 14             	sub    $0x14,%esp
f01068f6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01068fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01068fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106902:	89 c7                	mov    %eax,%edi
f0106904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106908:	8b 44 24 30          	mov    0x30(%esp),%eax
f010690c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106910:	89 34 24             	mov    %esi,(%esp)
f0106913:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106917:	85 c0                	test   %eax,%eax
f0106919:	89 c2                	mov    %eax,%edx
f010691b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010691f:	75 17                	jne    f0106938 <__umoddi3+0x48>
f0106921:	39 fe                	cmp    %edi,%esi
f0106923:	76 4b                	jbe    f0106970 <__umoddi3+0x80>
f0106925:	89 c8                	mov    %ecx,%eax
f0106927:	89 fa                	mov    %edi,%edx
f0106929:	f7 f6                	div    %esi
f010692b:	89 d0                	mov    %edx,%eax
f010692d:	31 d2                	xor    %edx,%edx
f010692f:	83 c4 14             	add    $0x14,%esp
f0106932:	5e                   	pop    %esi
f0106933:	5f                   	pop    %edi
f0106934:	5d                   	pop    %ebp
f0106935:	c3                   	ret    
f0106936:	66 90                	xchg   %ax,%ax
f0106938:	39 f8                	cmp    %edi,%eax
f010693a:	77 54                	ja     f0106990 <__umoddi3+0xa0>
f010693c:	0f bd e8             	bsr    %eax,%ebp
f010693f:	83 f5 1f             	xor    $0x1f,%ebp
f0106942:	75 5c                	jne    f01069a0 <__umoddi3+0xb0>
f0106944:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106948:	39 3c 24             	cmp    %edi,(%esp)
f010694b:	0f 87 e7 00 00 00    	ja     f0106a38 <__umoddi3+0x148>
f0106951:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106955:	29 f1                	sub    %esi,%ecx
f0106957:	19 c7                	sbb    %eax,%edi
f0106959:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010695d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106961:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106965:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106969:	83 c4 14             	add    $0x14,%esp
f010696c:	5e                   	pop    %esi
f010696d:	5f                   	pop    %edi
f010696e:	5d                   	pop    %ebp
f010696f:	c3                   	ret    
f0106970:	85 f6                	test   %esi,%esi
f0106972:	89 f5                	mov    %esi,%ebp
f0106974:	75 0b                	jne    f0106981 <__umoddi3+0x91>
f0106976:	b8 01 00 00 00       	mov    $0x1,%eax
f010697b:	31 d2                	xor    %edx,%edx
f010697d:	f7 f6                	div    %esi
f010697f:	89 c5                	mov    %eax,%ebp
f0106981:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106985:	31 d2                	xor    %edx,%edx
f0106987:	f7 f5                	div    %ebp
f0106989:	89 c8                	mov    %ecx,%eax
f010698b:	f7 f5                	div    %ebp
f010698d:	eb 9c                	jmp    f010692b <__umoddi3+0x3b>
f010698f:	90                   	nop
f0106990:	89 c8                	mov    %ecx,%eax
f0106992:	89 fa                	mov    %edi,%edx
f0106994:	83 c4 14             	add    $0x14,%esp
f0106997:	5e                   	pop    %esi
f0106998:	5f                   	pop    %edi
f0106999:	5d                   	pop    %ebp
f010699a:	c3                   	ret    
f010699b:	90                   	nop
f010699c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069a0:	8b 04 24             	mov    (%esp),%eax
f01069a3:	be 20 00 00 00       	mov    $0x20,%esi
f01069a8:	89 e9                	mov    %ebp,%ecx
f01069aa:	29 ee                	sub    %ebp,%esi
f01069ac:	d3 e2                	shl    %cl,%edx
f01069ae:	89 f1                	mov    %esi,%ecx
f01069b0:	d3 e8                	shr    %cl,%eax
f01069b2:	89 e9                	mov    %ebp,%ecx
f01069b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069b8:	8b 04 24             	mov    (%esp),%eax
f01069bb:	09 54 24 04          	or     %edx,0x4(%esp)
f01069bf:	89 fa                	mov    %edi,%edx
f01069c1:	d3 e0                	shl    %cl,%eax
f01069c3:	89 f1                	mov    %esi,%ecx
f01069c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01069c9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01069cd:	d3 ea                	shr    %cl,%edx
f01069cf:	89 e9                	mov    %ebp,%ecx
f01069d1:	d3 e7                	shl    %cl,%edi
f01069d3:	89 f1                	mov    %esi,%ecx
f01069d5:	d3 e8                	shr    %cl,%eax
f01069d7:	89 e9                	mov    %ebp,%ecx
f01069d9:	09 f8                	or     %edi,%eax
f01069db:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01069df:	f7 74 24 04          	divl   0x4(%esp)
f01069e3:	d3 e7                	shl    %cl,%edi
f01069e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069e9:	89 d7                	mov    %edx,%edi
f01069eb:	f7 64 24 08          	mull   0x8(%esp)
f01069ef:	39 d7                	cmp    %edx,%edi
f01069f1:	89 c1                	mov    %eax,%ecx
f01069f3:	89 14 24             	mov    %edx,(%esp)
f01069f6:	72 2c                	jb     f0106a24 <__umoddi3+0x134>
f01069f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f01069fc:	72 22                	jb     f0106a20 <__umoddi3+0x130>
f01069fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106a02:	29 c8                	sub    %ecx,%eax
f0106a04:	19 d7                	sbb    %edx,%edi
f0106a06:	89 e9                	mov    %ebp,%ecx
f0106a08:	89 fa                	mov    %edi,%edx
f0106a0a:	d3 e8                	shr    %cl,%eax
f0106a0c:	89 f1                	mov    %esi,%ecx
f0106a0e:	d3 e2                	shl    %cl,%edx
f0106a10:	89 e9                	mov    %ebp,%ecx
f0106a12:	d3 ef                	shr    %cl,%edi
f0106a14:	09 d0                	or     %edx,%eax
f0106a16:	89 fa                	mov    %edi,%edx
f0106a18:	83 c4 14             	add    $0x14,%esp
f0106a1b:	5e                   	pop    %esi
f0106a1c:	5f                   	pop    %edi
f0106a1d:	5d                   	pop    %ebp
f0106a1e:	c3                   	ret    
f0106a1f:	90                   	nop
f0106a20:	39 d7                	cmp    %edx,%edi
f0106a22:	75 da                	jne    f01069fe <__umoddi3+0x10e>
f0106a24:	8b 14 24             	mov    (%esp),%edx
f0106a27:	89 c1                	mov    %eax,%ecx
f0106a29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106a2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106a31:	eb cb                	jmp    f01069fe <__umoddi3+0x10e>
f0106a33:	90                   	nop
f0106a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106a3c:	0f 82 0f ff ff ff    	jb     f0106951 <__umoddi3+0x61>
f0106a42:	e9 1a ff ff ff       	jmp    f0106961 <__umoddi3+0x71>
