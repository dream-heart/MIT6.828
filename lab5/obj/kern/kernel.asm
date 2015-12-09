
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
f010004b:	83 3d 80 2e 1e f0 00 	cmpl   $0x0,0xf01e2e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 2e 1e f0    	mov    %esi,0xf01e2e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 d5 65 00 00       	call   f0106639 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 6d 10 f0 	movl   $0xf0106d20,(%esp)
f010007d:	e8 3f 3f 00 00       	call   f0103fc1 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 00 3f 00 00       	call   f0103f8e <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 84 7e 10 f0 	movl   $0xf0107e84,(%esp)
f0100095:	e8 27 3f 00 00       	call   f0103fc1 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 fb 08 00 00       	call   f01009a1 <monitor>
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
f01000af:	b8 08 40 22 f0       	mov    $0xf0224008,%eax
f01000b4:	2d 34 1c 1e f0       	sub    $0xf01e1c34,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 34 1c 1e f0 	movl   $0xf01e1c34,(%esp)
f01000cc:	e8 16 5f 00 00       	call   f0105fe7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 99 05 00 00       	call   f010066f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 8c 6d 10 f0 	movl   $0xf0106d8c,(%esp)
f01000e5:	e8 d7 3e 00 00       	call   f0103fc1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 9d 13 00 00       	call   f010148c <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 bd 36 00 00       	call   f01037b1 <env_init>
	trap_init();
f01000f4:	e8 b7 3f 00 00       	call   f01040b0 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 2c 62 00 00       	call   f010632a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 4f 65 00 00       	call   f0106654 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 e7 3d 00 00       	call   f0103ef1 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 a1 67 00 00       	call   f01068b7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 2e 1e f0 07 	cmpl   $0x7,0xf01e2e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 a7 6d 10 f0 	movl   $0xf0106da7,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 62 62 10 f0       	mov    $0xf0106262,%eax
f0100148:	2d e8 61 10 f0       	sub    $0xf01061e8,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 e8 61 10 	movl   $0xf01061e8,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 cf 5e 00 00       	call   f0106034 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 30 1e f0       	mov    $0xf01e3020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum())  // We've started already.
f010016c:	e8 c8 64 00 00       	call   f0106639 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 30 1e f0       	add    $0xf01e3020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 30 1e f0       	sub    $0xf01e3020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 c0 1e f0    	lea    -0xfe14000(%eax),%eax
f0100196:	a3 84 2e 1e f0       	mov    %eax,0xf01e2e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 f6 65 00 00       	call   f01067a4 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 33 1e f0 74 	imul   $0x74,0xf01e33c4,%eax
f01001c0:	05 20 30 1e f0       	add    $0xf01e3020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	// Start fs.
	//ENV_CREATE(fs_fs, ENV_TYPE_FS);

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 f1 69 17 f0 	movl   $0xf01769f1,(%esp)
f01001d8:	e8 ad 37 00 00       	call   f010398a <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001dd:	e8 31 04 00 00       	call   f0100613 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001e2:	e8 40 4b 00 00       	call   f0104d27 <sched_yield>

f01001e7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e7:	55                   	push   %ebp
f01001e8:	89 e5                	mov    %esp,%ebp
f01001ea:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001ed:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f7:	77 20                	ja     f0100219 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001fd:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0100204:	f0 
f0100205:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f010020c:	00 
f010020d:	c7 04 24 a7 6d 10 f0 	movl   $0xf0106da7,(%esp)
f0100214:	e8 27 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100219:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010021e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100221:	e8 13 64 00 00       	call   f0106639 <cpunum>
f0100226:	89 44 24 04          	mov    %eax,0x4(%esp)
f010022a:	c7 04 24 b3 6d 10 f0 	movl   $0xf0106db3,(%esp)
f0100231:	e8 8b 3d 00 00       	call   f0103fc1 <cprintf>

	lapic_init();
f0100236:	e8 19 64 00 00       	call   f0106654 <lapic_init>
	env_init_percpu();
f010023b:	e8 47 35 00 00       	call   f0103787 <env_init_percpu>
	trap_init_percpu();
f0100240:	e8 9b 3d 00 00       	call   f0103fe0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 ef 63 00 00       	call   f0106639 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 30 1e f0    	add    $0xf01e3020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	eb fe                	jmp    f010025c <mp_main+0x75>

f010025e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010025e:	55                   	push   %ebp
f010025f:	89 e5                	mov    %esp,%ebp
f0100261:	53                   	push   %ebx
f0100262:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100265:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100268:	8b 45 0c             	mov    0xc(%ebp),%eax
f010026b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010026f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100272:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100276:	c7 04 24 c9 6d 10 f0 	movl   $0xf0106dc9,(%esp)
f010027d:	e8 3f 3d 00 00       	call   f0103fc1 <cprintf>
	vcprintf(fmt, ap);
f0100282:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100286:	8b 45 10             	mov    0x10(%ebp),%eax
f0100289:	89 04 24             	mov    %eax,(%esp)
f010028c:	e8 fd 3c 00 00       	call   f0103f8e <vcprintf>
	cprintf("\n");
f0100291:	c7 04 24 84 7e 10 f0 	movl   $0xf0107e84,(%esp)
f0100298:	e8 24 3d 00 00       	call   f0103fc1 <cprintf>
	va_end(ap);
}
f010029d:	83 c4 14             	add    $0x14,%esp
f01002a0:	5b                   	pop    %ebx
f01002a1:	5d                   	pop    %ebp
f01002a2:	c3                   	ret    
f01002a3:	66 90                	xchg   %ax,%ax
f01002a5:	66 90                	xchg   %ax,%ax
f01002a7:	66 90                	xchg   %ax,%ax
f01002a9:	66 90                	xchg   %ax,%ax
f01002ab:	66 90                	xchg   %ax,%ax
f01002ad:	66 90                	xchg   %ax,%ax
f01002af:	90                   	nop

f01002b0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002b9:	a8 01                	test   $0x1,%al
f01002bb:	74 08                	je     f01002c5 <serial_proc_data+0x15>
f01002bd:	b2 f8                	mov    $0xf8,%dl
f01002bf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002c0:	0f b6 c0             	movzbl %al,%eax
f01002c3:	eb 05                	jmp    f01002ca <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ca:	5d                   	pop    %ebp
f01002cb:	c3                   	ret    

f01002cc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002cc:	55                   	push   %ebp
f01002cd:	89 e5                	mov    %esp,%ebp
f01002cf:	53                   	push   %ebx
f01002d0:	83 ec 04             	sub    $0x4,%esp
f01002d3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002d5:	eb 2a                	jmp    f0100301 <cons_intr+0x35>
		if (c == 0)
f01002d7:	85 d2                	test   %edx,%edx
f01002d9:	74 26                	je     f0100301 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002db:	a1 24 22 1e f0       	mov    0xf01e2224,%eax
f01002e0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002e3:	89 0d 24 22 1e f0    	mov    %ecx,0xf01e2224
f01002e9:	88 90 20 20 1e f0    	mov    %dl,-0xfe1dfe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ef:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002f5:	75 0a                	jne    f0100301 <cons_intr+0x35>
			cons.wpos = 0;
f01002f7:	c7 05 24 22 1e f0 00 	movl   $0x0,0xf01e2224
f01002fe:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100301:	ff d3                	call   *%ebx
f0100303:	89 c2                	mov    %eax,%edx
f0100305:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100308:	75 cd                	jne    f01002d7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010030a:	83 c4 04             	add    $0x4,%esp
f010030d:	5b                   	pop    %ebx
f010030e:	5d                   	pop    %ebp
f010030f:	c3                   	ret    

f0100310 <kbd_proc_data>:
f0100310:	ba 64 00 00 00       	mov    $0x64,%edx
f0100315:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100316:	a8 01                	test   $0x1,%al
f0100318:	0f 84 ef 00 00 00    	je     f010040d <kbd_proc_data+0xfd>
f010031e:	b2 60                	mov    $0x60,%dl
f0100320:	ec                   	in     (%dx),%al
f0100321:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100323:	3c e0                	cmp    $0xe0,%al
f0100325:	75 0d                	jne    f0100334 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100327:	83 0d 00 20 1e f0 40 	orl    $0x40,0xf01e2000
		return 0;
f010032e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100333:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100334:	55                   	push   %ebp
f0100335:	89 e5                	mov    %esp,%ebp
f0100337:	53                   	push   %ebx
f0100338:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010033b:	84 c0                	test   %al,%al
f010033d:	79 37                	jns    f0100376 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010033f:	8b 0d 00 20 1e f0    	mov    0xf01e2000,%ecx
f0100345:	89 cb                	mov    %ecx,%ebx
f0100347:	83 e3 40             	and    $0x40,%ebx
f010034a:	83 e0 7f             	and    $0x7f,%eax
f010034d:	85 db                	test   %ebx,%ebx
f010034f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100352:	0f b6 d2             	movzbl %dl,%edx
f0100355:	0f b6 82 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%eax
f010035c:	83 c8 40             	or     $0x40,%eax
f010035f:	0f b6 c0             	movzbl %al,%eax
f0100362:	f7 d0                	not    %eax
f0100364:	21 c1                	and    %eax,%ecx
f0100366:	89 0d 00 20 1e f0    	mov    %ecx,0xf01e2000
		return 0;
f010036c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100371:	e9 9d 00 00 00       	jmp    f0100413 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100376:	8b 0d 00 20 1e f0    	mov    0xf01e2000,%ecx
f010037c:	f6 c1 40             	test   $0x40,%cl
f010037f:	74 0e                	je     f010038f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100381:	83 c8 80             	or     $0xffffff80,%eax
f0100384:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100386:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100389:	89 0d 00 20 1e f0    	mov    %ecx,0xf01e2000
	}

	shift |= shiftcode[data];
f010038f:	0f b6 d2             	movzbl %dl,%edx
f0100392:	0f b6 82 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%eax
f0100399:	0b 05 00 20 1e f0    	or     0xf01e2000,%eax
	shift ^= togglecode[data];
f010039f:	0f b6 8a 40 6e 10 f0 	movzbl -0xfef91c0(%edx),%ecx
f01003a6:	31 c8                	xor    %ecx,%eax
f01003a8:	a3 00 20 1e f0       	mov    %eax,0xf01e2000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003ad:	89 c1                	mov    %eax,%ecx
f01003af:	83 e1 03             	and    $0x3,%ecx
f01003b2:	8b 0c 8d 20 6e 10 f0 	mov    -0xfef91e0(,%ecx,4),%ecx
f01003b9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003bd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003c0:	a8 08                	test   $0x8,%al
f01003c2:	74 1b                	je     f01003df <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003c4:	89 da                	mov    %ebx,%edx
f01003c6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003c9:	83 f9 19             	cmp    $0x19,%ecx
f01003cc:	77 05                	ja     f01003d3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003ce:	83 eb 20             	sub    $0x20,%ebx
f01003d1:	eb 0c                	jmp    f01003df <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003d3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003d6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003d9:	83 fa 19             	cmp    $0x19,%edx
f01003dc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003df:	f7 d0                	not    %eax
f01003e1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003e3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003e5:	f6 c2 06             	test   $0x6,%dl
f01003e8:	75 29                	jne    f0100413 <kbd_proc_data+0x103>
f01003ea:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003f0:	75 21                	jne    f0100413 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01003f2:	c7 04 24 e3 6d 10 f0 	movl   $0xf0106de3,(%esp)
f01003f9:	e8 c3 3b 00 00       	call   f0103fc1 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003fe:	ba 92 00 00 00       	mov    $0x92,%edx
f0100403:	b8 03 00 00 00       	mov    $0x3,%eax
f0100408:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100409:	89 d8                	mov    %ebx,%eax
f010040b:	eb 06                	jmp    f0100413 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010040d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100412:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100413:	83 c4 14             	add    $0x14,%esp
f0100416:	5b                   	pop    %ebx
f0100417:	5d                   	pop    %ebp
f0100418:	c3                   	ret    

f0100419 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100419:	55                   	push   %ebp
f010041a:	89 e5                	mov    %esp,%ebp
f010041c:	57                   	push   %edi
f010041d:	56                   	push   %esi
f010041e:	53                   	push   %ebx
f010041f:	83 ec 1c             	sub    $0x1c,%esp
f0100422:	89 c7                	mov    %eax,%edi
f0100424:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100429:	be fd 03 00 00       	mov    $0x3fd,%esi
f010042e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100433:	eb 06                	jmp    f010043b <cons_putc+0x22>
f0100435:	89 ca                	mov    %ecx,%edx
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	89 f2                	mov    %esi,%edx
f010043d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010043e:	a8 20                	test   $0x20,%al
f0100440:	75 05                	jne    f0100447 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100442:	83 eb 01             	sub    $0x1,%ebx
f0100445:	75 ee                	jne    f0100435 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100447:	89 f8                	mov    %edi,%eax
f0100449:	0f b6 c0             	movzbl %al,%eax
f010044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100454:	ee                   	out    %al,(%dx)
f0100455:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010045a:	be 79 03 00 00       	mov    $0x379,%esi
f010045f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100464:	eb 06                	jmp    f010046c <cons_putc+0x53>
f0100466:	89 ca                	mov    %ecx,%edx
f0100468:	ec                   	in     (%dx),%al
f0100469:	ec                   	in     (%dx),%al
f010046a:	ec                   	in     (%dx),%al
f010046b:	ec                   	in     (%dx),%al
f010046c:	89 f2                	mov    %esi,%edx
f010046e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010046f:	84 c0                	test   %al,%al
f0100471:	78 05                	js     f0100478 <cons_putc+0x5f>
f0100473:	83 eb 01             	sub    $0x1,%ebx
f0100476:	75 ee                	jne    f0100466 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100478:	ba 78 03 00 00       	mov    $0x378,%edx
f010047d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100481:	ee                   	out    %al,(%dx)
f0100482:	b2 7a                	mov    $0x7a,%dl
f0100484:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100489:	ee                   	out    %al,(%dx)
f010048a:	b8 08 00 00 00       	mov    $0x8,%eax
f010048f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100490:	89 fa                	mov    %edi,%edx
f0100492:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100498:	89 f8                	mov    %edi,%eax
f010049a:	80 cc 07             	or     $0x7,%ah
f010049d:	85 d2                	test   %edx,%edx
f010049f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004a2:	89 f8                	mov    %edi,%eax
f01004a4:	0f b6 c0             	movzbl %al,%eax
f01004a7:	83 f8 09             	cmp    $0x9,%eax
f01004aa:	74 76                	je     f0100522 <cons_putc+0x109>
f01004ac:	83 f8 09             	cmp    $0x9,%eax
f01004af:	7f 0a                	jg     f01004bb <cons_putc+0xa2>
f01004b1:	83 f8 08             	cmp    $0x8,%eax
f01004b4:	74 16                	je     f01004cc <cons_putc+0xb3>
f01004b6:	e9 9b 00 00 00       	jmp    f0100556 <cons_putc+0x13d>
f01004bb:	83 f8 0a             	cmp    $0xa,%eax
f01004be:	66 90                	xchg   %ax,%ax
f01004c0:	74 3a                	je     f01004fc <cons_putc+0xe3>
f01004c2:	83 f8 0d             	cmp    $0xd,%eax
f01004c5:	74 3d                	je     f0100504 <cons_putc+0xeb>
f01004c7:	e9 8a 00 00 00       	jmp    f0100556 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01004cc:	0f b7 05 28 22 1e f0 	movzwl 0xf01e2228,%eax
f01004d3:	66 85 c0             	test   %ax,%ax
f01004d6:	0f 84 e5 00 00 00    	je     f01005c1 <cons_putc+0x1a8>
			crt_pos--;
f01004dc:	83 e8 01             	sub    $0x1,%eax
f01004df:	66 a3 28 22 1e f0    	mov    %ax,0xf01e2228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ed:	83 cf 20             	or     $0x20,%edi
f01004f0:	8b 15 2c 22 1e f0    	mov    0xf01e222c,%edx
f01004f6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004fa:	eb 78                	jmp    f0100574 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004fc:	66 83 05 28 22 1e f0 	addw   $0x50,0xf01e2228
f0100503:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100504:	0f b7 05 28 22 1e f0 	movzwl 0xf01e2228,%eax
f010050b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100511:	c1 e8 16             	shr    $0x16,%eax
f0100514:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100517:	c1 e0 04             	shl    $0x4,%eax
f010051a:	66 a3 28 22 1e f0    	mov    %ax,0xf01e2228
f0100520:	eb 52                	jmp    f0100574 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100522:	b8 20 00 00 00       	mov    $0x20,%eax
f0100527:	e8 ed fe ff ff       	call   f0100419 <cons_putc>
		cons_putc(' ');
f010052c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100531:	e8 e3 fe ff ff       	call   f0100419 <cons_putc>
		cons_putc(' ');
f0100536:	b8 20 00 00 00       	mov    $0x20,%eax
f010053b:	e8 d9 fe ff ff       	call   f0100419 <cons_putc>
		cons_putc(' ');
f0100540:	b8 20 00 00 00       	mov    $0x20,%eax
f0100545:	e8 cf fe ff ff       	call   f0100419 <cons_putc>
		cons_putc(' ');
f010054a:	b8 20 00 00 00       	mov    $0x20,%eax
f010054f:	e8 c5 fe ff ff       	call   f0100419 <cons_putc>
f0100554:	eb 1e                	jmp    f0100574 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100556:	0f b7 05 28 22 1e f0 	movzwl 0xf01e2228,%eax
f010055d:	8d 50 01             	lea    0x1(%eax),%edx
f0100560:	66 89 15 28 22 1e f0 	mov    %dx,0xf01e2228
f0100567:	0f b7 c0             	movzwl %ax,%eax
f010056a:	8b 15 2c 22 1e f0    	mov    0xf01e222c,%edx
f0100570:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100574:	66 81 3d 28 22 1e f0 	cmpw   $0x7cf,0xf01e2228
f010057b:	cf 07 
f010057d:	76 42                	jbe    f01005c1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057f:	a1 2c 22 1e f0       	mov    0xf01e222c,%eax
f0100584:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010058b:	00 
f010058c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100592:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100596:	89 04 24             	mov    %eax,(%esp)
f0100599:	e8 96 5a 00 00       	call   f0106034 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010059e:	8b 15 2c 22 1e f0    	mov    0xf01e222c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005a9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005af:	83 c0 01             	add    $0x1,%eax
f01005b2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005b7:	75 f0                	jne    f01005a9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005b9:	66 83 2d 28 22 1e f0 	subw   $0x50,0xf01e2228
f01005c0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005c1:	8b 0d 30 22 1e f0    	mov    0xf01e2230,%ecx
f01005c7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005cc:	89 ca                	mov    %ecx,%edx
f01005ce:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005cf:	0f b7 1d 28 22 1e f0 	movzwl 0xf01e2228,%ebx
f01005d6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005d9:	89 d8                	mov    %ebx,%eax
f01005db:	66 c1 e8 08          	shr    $0x8,%ax
f01005df:	89 f2                	mov    %esi,%edx
f01005e1:	ee                   	out    %al,(%dx)
f01005e2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e7:	89 ca                	mov    %ecx,%edx
f01005e9:	ee                   	out    %al,(%dx)
f01005ea:	89 d8                	mov    %ebx,%eax
f01005ec:	89 f2                	mov    %esi,%edx
f01005ee:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ef:	83 c4 1c             	add    $0x1c,%esp
f01005f2:	5b                   	pop    %ebx
f01005f3:	5e                   	pop    %esi
f01005f4:	5f                   	pop    %edi
f01005f5:	5d                   	pop    %ebp
f01005f6:	c3                   	ret    

f01005f7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005f7:	80 3d 34 22 1e f0 00 	cmpb   $0x0,0xf01e2234
f01005fe:	74 11                	je     f0100611 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100606:	b8 b0 02 10 f0       	mov    $0xf01002b0,%eax
f010060b:	e8 bc fc ff ff       	call   f01002cc <cons_intr>
}
f0100610:	c9                   	leave  
f0100611:	f3 c3                	repz ret 

f0100613 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
f0100616:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100619:	b8 10 03 10 f0       	mov    $0xf0100310,%eax
f010061e:	e8 a9 fc ff ff       	call   f01002cc <cons_intr>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010062b:	e8 c7 ff ff ff       	call   f01005f7 <serial_intr>
	kbd_intr();
f0100630:	e8 de ff ff ff       	call   f0100613 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100635:	a1 20 22 1e f0       	mov    0xf01e2220,%eax
f010063a:	3b 05 24 22 1e f0    	cmp    0xf01e2224,%eax
f0100640:	74 26                	je     f0100668 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100642:	8d 50 01             	lea    0x1(%eax),%edx
f0100645:	89 15 20 22 1e f0    	mov    %edx,0xf01e2220
f010064b:	0f b6 88 20 20 1e f0 	movzbl -0xfe1dfe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100652:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100654:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065a:	75 11                	jne    f010066d <cons_getc+0x48>
			cons.rpos = 0;
f010065c:	c7 05 20 22 1e f0 00 	movl   $0x0,0xf01e2220
f0100663:	00 00 00 
f0100666:	eb 05                	jmp    f010066d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100668:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	57                   	push   %edi
f0100673:	56                   	push   %esi
f0100674:	53                   	push   %ebx
f0100675:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100678:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100686:	5a a5 
	if (*cp != 0xA55A) {
f0100688:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100693:	74 11                	je     f01006a6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100695:	c7 05 30 22 1e f0 b4 	movl   $0x3b4,0xf01e2230
f010069c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006a4:	eb 16                	jmp    f01006bc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ad:	c7 05 30 22 1e f0 d4 	movl   $0x3d4,0xf01e2230
f01006b4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006bc:	8b 0d 30 22 1e f0    	mov    0xf01e2230,%ecx
f01006c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c7:	89 ca                	mov    %ecx,%edx
f01006c9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 f0             	movzbl %al,%esi
f01006d3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006db:	89 ca                	mov    %ecx,%edx
f01006dd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006de:	89 da                	mov    %ebx,%edx
f01006e0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e1:	89 3d 2c 22 1e f0    	mov    %edi,0xf01e222c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e7:	0f b6 d8             	movzbl %al,%ebx
f01006ea:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ec:	66 89 35 28 22 1e f0 	mov    %si,0xf01e2228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f3:	e8 1b ff ff ff       	call   f0100613 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f8:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006ff:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100704:	89 04 24             	mov    %eax,(%esp)
f0100707:	e8 76 37 00 00       	call   f0103e82 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100711:	b8 00 00 00 00       	mov    $0x0,%eax
f0100716:	89 f2                	mov    %esi,%edx
f0100718:	ee                   	out    %al,(%dx)
f0100719:	b2 fb                	mov    $0xfb,%dl
f010071b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100720:	ee                   	out    %al,(%dx)
f0100721:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100726:	b8 0c 00 00 00       	mov    $0xc,%eax
f010072b:	89 da                	mov    %ebx,%edx
f010072d:	ee                   	out    %al,(%dx)
f010072e:	b2 f9                	mov    $0xf9,%dl
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	b2 fb                	mov    $0xfb,%dl
f0100738:	b8 03 00 00 00       	mov    $0x3,%eax
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 fc                	mov    $0xfc,%dl
f0100740:	b8 00 00 00 00       	mov    $0x0,%eax
f0100745:	ee                   	out    %al,(%dx)
f0100746:	b2 f9                	mov    $0xf9,%dl
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074e:	b2 fd                	mov    $0xfd,%dl
f0100750:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100751:	3c ff                	cmp    $0xff,%al
f0100753:	0f 95 c1             	setne  %cl
f0100756:	88 0d 34 22 1e f0    	mov    %cl,0xf01e2234
f010075c:	89 f2                	mov    %esi,%edx
f010075e:	ec                   	in     (%dx),%al
f010075f:	89 da                	mov    %ebx,%edx
f0100761:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100762:	84 c9                	test   %cl,%cl
f0100764:	74 1d                	je     f0100783 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100766:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010076d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100772:	89 04 24             	mov    %eax,(%esp)
f0100775:	e8 08 37 00 00       	call   f0103e82 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010077a:	80 3d 34 22 1e f0 00 	cmpb   $0x0,0xf01e2234
f0100781:	75 0c                	jne    f010078f <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f0100783:	c7 04 24 ef 6d 10 f0 	movl   $0xf0106def,(%esp)
f010078a:	e8 32 38 00 00       	call   f0103fc1 <cprintf>
}
f010078f:	83 c4 1c             	add    $0x1c,%esp
f0100792:	5b                   	pop    %ebx
f0100793:	5e                   	pop    %esi
f0100794:	5f                   	pop    %edi
f0100795:	5d                   	pop    %ebp
f0100796:	c3                   	ret    

f0100797 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100797:	55                   	push   %ebp
f0100798:	89 e5                	mov    %esp,%ebp
f010079a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079d:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a0:	e8 74 fc ff ff       	call   f0100419 <cons_putc>
}
f01007a5:	c9                   	leave  
f01007a6:	c3                   	ret    

f01007a7 <getchar>:

int
getchar(void)
{
f01007a7:	55                   	push   %ebp
f01007a8:	89 e5                	mov    %esp,%ebp
f01007aa:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ad:	e8 73 fe ff ff       	call   f0100625 <cons_getc>
f01007b2:	85 c0                	test   %eax,%eax
f01007b4:	74 f7                	je     f01007ad <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b6:	c9                   	leave  
f01007b7:	c3                   	ret    

f01007b8 <iscons>:

int
iscons(int fdnum)
{
f01007b8:	55                   	push   %ebp
f01007b9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c0:	5d                   	pop    %ebp
f01007c1:	c3                   	ret    
f01007c2:	66 90                	xchg   %ax,%ax
f01007c4:	66 90                	xchg   %ax,%ax
f01007c6:	66 90                	xchg   %ax,%ax
f01007c8:	66 90                	xchg   %ax,%ax
f01007ca:	66 90                	xchg   %ax,%ax
f01007cc:	66 90                	xchg   %ax,%ax
f01007ce:	66 90                	xchg   %ax,%ax

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
f01007d6:	c7 44 24 08 40 70 10 	movl   $0xf0107040,0x8(%esp)
f01007dd:	f0 
f01007de:	c7 44 24 04 5e 70 10 	movl   $0xf010705e,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 63 70 10 f0 	movl   $0xf0107063,(%esp)
f01007ed:	e8 cf 37 00 00       	call   f0103fc1 <cprintf>
f01007f2:	c7 44 24 08 00 71 10 	movl   $0xf0107100,0x8(%esp)
f01007f9:	f0 
f01007fa:	c7 44 24 04 6c 70 10 	movl   $0xf010706c,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 63 70 10 f0 	movl   $0xf0107063,(%esp)
f0100809:	e8 b3 37 00 00       	call   f0103fc1 <cprintf>
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
f010081b:	c7 04 24 75 70 10 f0 	movl   $0xf0107075,(%esp)
f0100822:	e8 9a 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100827:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010082e:	00 
f010082f:	c7 04 24 28 71 10 f0 	movl   $0xf0107128,(%esp)
f0100836:	e8 86 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010083b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100842:	00 
f0100843:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010084a:	f0 
f010084b:	c7 04 24 50 71 10 f0 	movl   $0xf0107150,(%esp)
f0100852:	e8 6a 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100857:	c7 44 24 08 07 6d 10 	movl   $0x106d07,0x8(%esp)
f010085e:	00 
f010085f:	c7 44 24 04 07 6d 10 	movl   $0xf0106d07,0x4(%esp)
f0100866:	f0 
f0100867:	c7 04 24 74 71 10 f0 	movl   $0xf0107174,(%esp)
f010086e:	e8 4e 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100873:	c7 44 24 08 34 1c 1e 	movl   $0x1e1c34,0x8(%esp)
f010087a:	00 
f010087b:	c7 44 24 04 34 1c 1e 	movl   $0xf01e1c34,0x4(%esp)
f0100882:	f0 
f0100883:	c7 04 24 98 71 10 f0 	movl   $0xf0107198,(%esp)
f010088a:	e8 32 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010088f:	c7 44 24 08 08 40 22 	movl   $0x224008,0x8(%esp)
f0100896:	00 
f0100897:	c7 44 24 04 08 40 22 	movl   $0xf0224008,0x4(%esp)
f010089e:	f0 
f010089f:	c7 04 24 bc 71 10 f0 	movl   $0xf01071bc,(%esp)
f01008a6:	e8 16 37 00 00       	call   f0103fc1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008ab:	b8 07 44 22 f0       	mov    $0xf0224407,%eax
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
f01008cc:	c7 04 24 e0 71 10 f0 	movl   $0xf01071e0,(%esp)
f01008d3:	e8 e9 36 00 00       	call   f0103fc1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008dd:	c9                   	leave  
f01008de:	c3                   	ret    

f01008df <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	struct Eipdebuginfo info;
f01008df:	55                   	push   %ebp
f01008e0:	89 e5                	mov    %esp,%ebp
f01008e2:	57                   	push   %edi
f01008e3:	56                   	push   %esi
f01008e4:	53                   	push   %ebx
f01008e5:	83 ec 5c             	sub    $0x5c,%esp
	unsigned int *ebp=(unsigned int *)read_ebp();
f01008e8:	89 eb                	mov    %ebp,%ebx

static __inline uint32_t
read_esp(void)
{
	uint32_t esp;
	__asm __volatile("movl %%esp,%0" : "=r" (esp));
f01008ea:	89 e0                	mov    %esp,%eax
	while(ebp)
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f01008ec:	8d 75 d0             	lea    -0x30(%ebp),%esi
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f01008ef:	e9 92 00 00 00       	jmp    f0100986 <mon_backtrace+0xa7>
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
f01008f4:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01008f8:	89 54 85 bc          	mov    %edx,-0x44(%ebp,%eax,4)
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
	{		
			for(i=0;i<5;i++)
f01008fc:	83 c0 01             	add    $0x1,%eax
f01008ff:	83 f8 05             	cmp    $0x5,%eax
f0100902:	75 f0                	jne    f01008f4 <mon_backtrace+0x15>
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f0100904:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100908:	8b 43 04             	mov    0x4(%ebx),%eax
f010090b:	89 04 24             	mov    %eax,(%esp)
f010090e:	e8 bb 4b 00 00       	call   f01054ce <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100913:	8b 43 04             	mov    0x4(%ebx),%eax
f0100916:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010091e:	c7 04 24 8e 70 10 f0 	movl   $0xf010708e,(%esp)
f0100925:	e8 97 36 00 00       	call   f0103fc1 <cprintf>
f010092a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010092d:	8b 07                	mov    (%edi),%eax
f010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100933:	c7 04 24 a9 70 10 f0 	movl   $0xf01070a9,(%esp)
f010093a:	e8 82 36 00 00       	call   f0103fc1 <cprintf>
f010093f:	83 c7 04             	add    $0x4,%edi
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
			for(i=0;i<5;++i)
f0100942:	39 f7                	cmp    %esi,%edi
f0100944:	75 e7                	jne    f010092d <mon_backtrace+0x4e>
			cprintf("%08x  ", arg[i]);
			cprintf("\n");
f0100946:	c7 04 24 84 7e 10 f0 	movl   $0xf0107e84,(%esp)
f010094d:	e8 6f 36 00 00       	call   f0103fc1 <cprintf>
			
			cprintf("\t\t%s:%u:%.*s+%u\n",
f0100952:	8b 43 04             	mov    0x4(%ebx),%eax
f0100955:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100958:	89 44 24 14          	mov    %eax,0x14(%esp)
f010095c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010095f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100963:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100966:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010096a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010096d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100971:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	c7 04 24 b0 70 10 f0 	movl   $0xf01070b0,(%esp)
f010097f:	e8 3d 36 00 00       	call   f0103fc1 <cprintf>
				info.eip_line,
				info.eip_fn_namelen,
				info.eip_fn_name,
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
f0100984:	8b 1b                	mov    (%ebx),%ebx
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f0100986:	85 db                	test   %ebx,%ebx
f0100988:	74 0a                	je     f0100994 <mon_backtrace+0xb5>
f010098a:	b8 00 00 00 00       	mov    $0x0,%eax
f010098f:	e9 60 ff ff ff       	jmp    f01008f4 <mon_backtrace+0x15>
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
	}
	return 0;
}
f0100994:	b8 00 00 00 00       	mov    $0x0,%eax
f0100999:	83 c4 5c             	add    $0x5c,%esp
f010099c:	5b                   	pop    %ebx
f010099d:	5e                   	pop    %esi
f010099e:	5f                   	pop    %edi
f010099f:	5d                   	pop    %ebp
f01009a0:	c3                   	ret    

f01009a1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009a1:	55                   	push   %ebp
f01009a2:	89 e5                	mov    %esp,%ebp
f01009a4:	57                   	push   %edi
f01009a5:	56                   	push   %esi
f01009a6:	53                   	push   %ebx
f01009a7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009aa:	c7 04 24 0c 72 10 f0 	movl   $0xf010720c,(%esp)
f01009b1:	e8 0b 36 00 00       	call   f0103fc1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009b6:	c7 04 24 30 72 10 f0 	movl   $0xf0107230,(%esp)
f01009bd:	e8 ff 35 00 00       	call   f0103fc1 <cprintf>

	if (tf != NULL)
f01009c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009c6:	74 0b                	je     f01009d3 <monitor+0x32>
		print_trapframe(tf);
f01009c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01009cb:	89 04 24             	mov    %eax,(%esp)
f01009ce:	e8 1a 3c 00 00       	call   f01045ed <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009d3:	c7 04 24 c1 70 10 f0 	movl   $0xf01070c1,(%esp)
f01009da:	e8 a1 53 00 00       	call   f0105d80 <readline>
f01009df:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009e1:	85 c0                	test   %eax,%eax
f01009e3:	74 ee                	je     f01009d3 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009e5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ec:	be 00 00 00 00       	mov    $0x0,%esi
f01009f1:	eb 0a                	jmp    f01009fd <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009f3:	c6 03 00             	movb   $0x0,(%ebx)
f01009f6:	89 f7                	mov    %esi,%edi
f01009f8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009fb:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009fd:	0f b6 03             	movzbl (%ebx),%eax
f0100a00:	84 c0                	test   %al,%al
f0100a02:	74 63                	je     f0100a67 <monitor+0xc6>
f0100a04:	0f be c0             	movsbl %al,%eax
f0100a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0b:	c7 04 24 c5 70 10 f0 	movl   $0xf01070c5,(%esp)
f0100a12:	e8 93 55 00 00       	call   f0105faa <strchr>
f0100a17:	85 c0                	test   %eax,%eax
f0100a19:	75 d8                	jne    f01009f3 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a1b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a1e:	74 47                	je     f0100a67 <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a20:	83 fe 0f             	cmp    $0xf,%esi
f0100a23:	75 16                	jne    f0100a3b <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a25:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a2c:	00 
f0100a2d:	c7 04 24 ca 70 10 f0 	movl   $0xf01070ca,(%esp)
f0100a34:	e8 88 35 00 00       	call   f0103fc1 <cprintf>
f0100a39:	eb 98                	jmp    f01009d3 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a3b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a3e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a42:	eb 03                	jmp    f0100a47 <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a44:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a47:	0f b6 03             	movzbl (%ebx),%eax
f0100a4a:	84 c0                	test   %al,%al
f0100a4c:	74 ad                	je     f01009fb <monitor+0x5a>
f0100a4e:	0f be c0             	movsbl %al,%eax
f0100a51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a55:	c7 04 24 c5 70 10 f0 	movl   $0xf01070c5,(%esp)
f0100a5c:	e8 49 55 00 00       	call   f0105faa <strchr>
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	74 df                	je     f0100a44 <monitor+0xa3>
f0100a65:	eb 94                	jmp    f01009fb <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100a67:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a6e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a6f:	85 f6                	test   %esi,%esi
f0100a71:	0f 84 5c ff ff ff    	je     f01009d3 <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a77:	c7 44 24 04 5e 70 10 	movl   $0xf010705e,0x4(%esp)
f0100a7e:	f0 
f0100a7f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a82:	89 04 24             	mov    %eax,(%esp)
f0100a85:	e8 c2 54 00 00       	call   f0105f4c <strcmp>
f0100a8a:	85 c0                	test   %eax,%eax
f0100a8c:	74 1b                	je     f0100aa9 <monitor+0x108>
f0100a8e:	c7 44 24 04 6c 70 10 	movl   $0xf010706c,0x4(%esp)
f0100a95:	f0 
f0100a96:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a99:	89 04 24             	mov    %eax,(%esp)
f0100a9c:	e8 ab 54 00 00       	call   f0105f4c <strcmp>
f0100aa1:	85 c0                	test   %eax,%eax
f0100aa3:	75 2f                	jne    f0100ad4 <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100aa5:	b0 01                	mov    $0x1,%al
f0100aa7:	eb 05                	jmp    f0100aae <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa9:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100aae:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100ab1:	01 d0                	add    %edx,%eax
f0100ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ab6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100aba:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100abd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ac1:	89 34 24             	mov    %esi,(%esp)
f0100ac4:	ff 14 85 60 72 10 f0 	call   *-0xfef8da0(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100acb:	85 c0                	test   %eax,%eax
f0100acd:	78 1d                	js     f0100aec <monitor+0x14b>
f0100acf:	e9 ff fe ff ff       	jmp    f01009d3 <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100adb:	c7 04 24 e7 70 10 f0 	movl   $0xf01070e7,(%esp)
f0100ae2:	e8 da 34 00 00       	call   f0103fc1 <cprintf>
f0100ae7:	e9 e7 fe ff ff       	jmp    f01009d3 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100aec:	83 c4 5c             	add    $0x5c,%esp
f0100aef:	5b                   	pop    %ebx
f0100af0:	5e                   	pop    %esi
f0100af1:	5f                   	pop    %edi
f0100af2:	5d                   	pop    %ebp
f0100af3:	c3                   	ret    
f0100af4:	66 90                	xchg   %ax,%ax
f0100af6:	66 90                	xchg   %ax,%ax
f0100af8:	66 90                	xchg   %ax,%ax
f0100afa:	66 90                	xchg   %ax,%ax
f0100afc:	66 90                	xchg   %ax,%ax
f0100afe:	66 90                	xchg   %ax,%ax

f0100b00 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b00:	55                   	push   %ebp
f0100b01:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b03:	83 3d 38 22 1e f0 00 	cmpl   $0x0,0xf01e2238
f0100b0a:	75 11                	jne    f0100b1d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b0c:	ba 07 50 22 f0       	mov    $0xf0225007,%edx
f0100b11:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b17:	89 15 38 22 1e f0    	mov    %edx,0xf01e2238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100b1d:	85 c0                	test   %eax,%eax
f0100b1f:	75 07                	jne    f0100b28 <boot_alloc+0x28>
		return nextfree;
f0100b21:	a1 38 22 1e f0       	mov    0xf01e2238,%eax
f0100b26:	eb 19                	jmp    f0100b41 <boot_alloc+0x41>
	result = nextfree;
f0100b28:	8b 15 38 22 1e f0    	mov    0xf01e2238,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100b2e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3a:	a3 38 22 1e f0       	mov    %eax,0xf01e2238
	
	// return the head address of the alloc pages;
	return result;
f0100b3f:	89 d0                	mov    %edx,%eax
}
f0100b41:	5d                   	pop    %ebp
f0100b42:	c3                   	ret    

f0100b43 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b43:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f0100b49:	c1 f8 03             	sar    $0x3,%eax
f0100b4c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b4f:	89 c2                	mov    %eax,%edx
f0100b51:	c1 ea 0c             	shr    $0xc,%edx
f0100b54:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f0100b5a:	72 26                	jb     f0100b82 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100b5c:	55                   	push   %ebp
f0100b5d:	89 e5                	mov    %esp,%ebp
f0100b5f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b66:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0100b6d:	f0 
f0100b6e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100b75:	00 
f0100b76:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0100b7d:	e8 be f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100b82:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100b87:	c3                   	ret    

f0100b88 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b88:	89 d1                	mov    %edx,%ecx
f0100b8a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b8d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b90:	a8 01                	test   $0x1,%al
f0100b92:	74 5d                	je     f0100bf1 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b99:	89 c1                	mov    %eax,%ecx
f0100b9b:	c1 e9 0c             	shr    $0xc,%ecx
f0100b9e:	3b 0d 88 2e 1e f0    	cmp    0xf01e2e88,%ecx
f0100ba4:	72 26                	jb     f0100bcc <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ba6:	55                   	push   %ebp
f0100ba7:	89 e5                	mov    %esp,%ebp
f0100ba9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bb0:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0100bb7:	f0 
f0100bb8:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0100bbf:	00 
f0100bc0:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100bc7:	e8 74 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100bcc:	c1 ea 0c             	shr    $0xc,%edx
f0100bcf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bd5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bdc:	89 c2                	mov    %eax,%edx
f0100bde:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100be1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100be6:	85 d2                	test   %edx,%edx
f0100be8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bed:	0f 44 c2             	cmove  %edx,%eax
f0100bf0:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bf6:	c3                   	ret    

f0100bf7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bf7:	55                   	push   %ebp
f0100bf8:	89 e5                	mov    %esp,%ebp
f0100bfa:	57                   	push   %edi
f0100bfb:	56                   	push   %esi
f0100bfc:	53                   	push   %ebx
f0100bfd:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c00:	84 c0                	test   %al,%al
f0100c02:	0f 85 31 03 00 00    	jne    f0100f39 <check_page_free_list+0x342>
f0100c08:	e9 3e 03 00 00       	jmp    f0100f4b <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100c0d:	c7 44 24 08 70 72 10 	movl   $0xf0107270,0x8(%esp)
f0100c14:	f0 
f0100c15:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100c1c:	00 
f0100c1d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100c24:	e8 17 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c29:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c2c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c2f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c32:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c35:	89 c2                	mov    %eax,%edx
f0100c37:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c3d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c43:	0f 95 c2             	setne  %dl
f0100c46:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c49:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c4d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c4f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c53:	8b 00                	mov    (%eax),%eax
f0100c55:	85 c0                	test   %eax,%eax
f0100c57:	75 dc                	jne    f0100c35 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c68:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c6d:	a3 40 22 1e f0       	mov    %eax,0xf01e2240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c72:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c77:	8b 1d 40 22 1e f0    	mov    0xf01e2240,%ebx
f0100c7d:	eb 63                	jmp    f0100ce2 <check_page_free_list+0xeb>
f0100c7f:	89 d8                	mov    %ebx,%eax
f0100c81:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f0100c87:	c1 f8 03             	sar    $0x3,%eax
f0100c8a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c8d:	89 c2                	mov    %eax,%edx
f0100c8f:	c1 ea 16             	shr    $0x16,%edx
f0100c92:	39 f2                	cmp    %esi,%edx
f0100c94:	73 4a                	jae    f0100ce0 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c96:	89 c2                	mov    %eax,%edx
f0100c98:	c1 ea 0c             	shr    $0xc,%edx
f0100c9b:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f0100ca1:	72 20                	jb     f0100cc3 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ca7:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0100cbe:	e8 7d f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100cc3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100cca:	00 
f0100ccb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100cd2:	00 
	return (void *)(pa + KERNBASE);
f0100cd3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cd8:	89 04 24             	mov    %eax,(%esp)
f0100cdb:	e8 07 53 00 00       	call   f0105fe7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ce0:	8b 1b                	mov    (%ebx),%ebx
f0100ce2:	85 db                	test   %ebx,%ebx
f0100ce4:	75 99                	jne    f0100c7f <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ce6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ceb:	e8 10 fe ff ff       	call   f0100b00 <boot_alloc>
f0100cf0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf3:	8b 15 40 22 1e f0    	mov    0xf01e2240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cf9:	8b 0d 90 2e 1e f0    	mov    0xf01e2e90,%ecx
		assert(pp < pages + npages);
f0100cff:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f0100d04:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d07:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d0a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d10:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d15:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d18:	e9 c4 01 00 00       	jmp    f0100ee1 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d1d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d20:	73 24                	jae    f0100d46 <check_page_free_list+0x14f>
f0100d22:	c7 44 24 0c a7 7b 10 	movl   $0xf0107ba7,0xc(%esp)
f0100d29:	f0 
f0100d2a:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100d31:	f0 
f0100d32:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100d39:	00 
f0100d3a:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100d41:	e8 fa f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d46:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d49:	72 24                	jb     f0100d6f <check_page_free_list+0x178>
f0100d4b:	c7 44 24 0c c8 7b 10 	movl   $0xf0107bc8,0xc(%esp)
f0100d52:	f0 
f0100d53:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100d5a:	f0 
f0100d5b:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100d62:	00 
f0100d63:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100d6a:	e8 d1 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d6f:	89 d0                	mov    %edx,%eax
f0100d71:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100d74:	a8 07                	test   $0x7,%al
f0100d76:	74 24                	je     f0100d9c <check_page_free_list+0x1a5>
f0100d78:	c7 44 24 0c 94 72 10 	movl   $0xf0107294,0xc(%esp)
f0100d7f:	f0 
f0100d80:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100d87:	f0 
f0100d88:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100d8f:	00 
f0100d90:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100d97:	e8 a4 f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d9c:	c1 f8 03             	sar    $0x3,%eax
f0100d9f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100da2:	85 c0                	test   %eax,%eax
f0100da4:	75 24                	jne    f0100dca <check_page_free_list+0x1d3>
f0100da6:	c7 44 24 0c dc 7b 10 	movl   $0xf0107bdc,0xc(%esp)
f0100dad:	f0 
f0100dae:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100db5:	f0 
f0100db6:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100dbd:	00 
f0100dbe:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100dc5:	e8 76 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dca:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dcf:	75 24                	jne    f0100df5 <check_page_free_list+0x1fe>
f0100dd1:	c7 44 24 0c ed 7b 10 	movl   $0xf0107bed,0xc(%esp)
f0100dd8:	f0 
f0100dd9:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100de0:	f0 
f0100de1:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0100de8:	00 
f0100de9:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100df0:	e8 4b f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100df5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dfa:	75 24                	jne    f0100e20 <check_page_free_list+0x229>
f0100dfc:	c7 44 24 0c c8 72 10 	movl   $0xf01072c8,0xc(%esp)
f0100e03:	f0 
f0100e04:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100e0b:	f0 
f0100e0c:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0100e13:	00 
f0100e14:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100e1b:	e8 20 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e20:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e25:	75 24                	jne    f0100e4b <check_page_free_list+0x254>
f0100e27:	c7 44 24 0c 06 7c 10 	movl   $0xf0107c06,0xc(%esp)
f0100e2e:	f0 
f0100e2f:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100e36:	f0 
f0100e37:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0100e3e:	00 
f0100e3f:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100e46:	e8 f5 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e4b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e50:	0f 86 1c 01 00 00    	jbe    f0100f72 <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e56:	89 c1                	mov    %eax,%ecx
f0100e58:	c1 e9 0c             	shr    $0xc,%ecx
f0100e5b:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100e5e:	77 20                	ja     f0100e80 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e64:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0100e6b:	f0 
f0100e6c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e73:	00 
f0100e74:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0100e7b:	e8 c0 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e80:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100e86:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e89:	0f 86 d3 00 00 00    	jbe    f0100f62 <check_page_free_list+0x36b>
f0100e8f:	c7 44 24 0c ec 72 10 	movl   $0xf01072ec,0xc(%esp)
f0100e96:	f0 
f0100e97:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100e9e:	f0 
f0100e9f:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0100ea6:	00 
f0100ea7:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100eb3:	c7 44 24 0c 20 7c 10 	movl   $0xf0107c20,0xc(%esp)
f0100eba:	f0 
f0100ebb:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100ec2:	f0 
f0100ec3:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0100eca:	00 
f0100ecb:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100ed2:	e8 69 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100ed7:	83 c3 01             	add    $0x1,%ebx
f0100eda:	eb 03                	jmp    f0100edf <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100edc:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100edf:	8b 12                	mov    (%edx),%edx
f0100ee1:	85 d2                	test   %edx,%edx
f0100ee3:	0f 85 34 fe ff ff    	jne    f0100d1d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ee9:	85 db                	test   %ebx,%ebx
f0100eeb:	7f 24                	jg     f0100f11 <check_page_free_list+0x31a>
f0100eed:	c7 44 24 0c 3d 7c 10 	movl   $0xf0107c3d,0xc(%esp)
f0100ef4:	f0 
f0100ef5:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100efc:	f0 
f0100efd:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0100f04:	00 
f0100f05:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100f0c:	e8 2f f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f11:	85 ff                	test   %edi,%edi
f0100f13:	7f 70                	jg     f0100f85 <check_page_free_list+0x38e>
f0100f15:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f0100f1c:	f0 
f0100f1d:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0100f24:	f0 
f0100f25:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0100f2c:	00 
f0100f2d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0100f34:	e8 07 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f39:	a1 40 22 1e f0       	mov    0xf01e2240,%eax
f0100f3e:	85 c0                	test   %eax,%eax
f0100f40:	0f 85 e3 fc ff ff    	jne    f0100c29 <check_page_free_list+0x32>
f0100f46:	e9 c2 fc ff ff       	jmp    f0100c0d <check_page_free_list+0x16>
f0100f4b:	83 3d 40 22 1e f0 00 	cmpl   $0x0,0xf01e2240
f0100f52:	0f 84 b5 fc ff ff    	je     f0100c0d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f58:	be 00 04 00 00       	mov    $0x400,%esi
f0100f5d:	e9 15 fd ff ff       	jmp    f0100c77 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f62:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f67:	0f 85 6f ff ff ff    	jne    f0100edc <check_page_free_list+0x2e5>
f0100f6d:	e9 41 ff ff ff       	jmp    f0100eb3 <check_page_free_list+0x2bc>
f0100f72:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f77:	0f 85 5a ff ff ff    	jne    f0100ed7 <check_page_free_list+0x2e0>
f0100f7d:	8d 76 00             	lea    0x0(%esi),%esi
f0100f80:	e9 2e ff ff ff       	jmp    f0100eb3 <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100f85:	83 c4 4c             	add    $0x4c,%esp
f0100f88:	5b                   	pop    %ebx
f0100f89:	5e                   	pop    %esi
f0100f8a:	5f                   	pop    %edi
f0100f8b:	5d                   	pop    %ebp
f0100f8c:	c3                   	ret    

f0100f8d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
f0100f90:	56                   	push   %esi
f0100f91:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f92:	be 00 00 00 00       	mov    $0x0,%esi
f0100f97:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f9c:	e9 e1 00 00 00       	jmp    f0101082 <page_init+0xf5>
		if(i == 0)
f0100fa1:	85 db                	test   %ebx,%ebx
f0100fa3:	75 16                	jne    f0100fbb <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100fa5:	a1 90 2e 1e f0       	mov    0xf01e2e90,%eax
f0100faa:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100fb6:	e9 c1 00 00 00       	jmp    f010107c <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100fbb:	83 fb 07             	cmp    $0x7,%ebx
f0100fbe:	75 17                	jne    f0100fd7 <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100fc0:	a1 90 2e 1e f0       	mov    0xf01e2e90,%eax
f0100fc5:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100fcb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100fd2:	e9 a5 00 00 00       	jmp    f010107c <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100fd7:	3b 1d 44 22 1e f0    	cmp    0xf01e2244,%ebx
f0100fdd:	73 25                	jae    f0101004 <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100fdf:	89 f0                	mov    %esi,%eax
f0100fe1:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f0100fe7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100fed:	8b 15 40 22 1e f0    	mov    0xf01e2240,%edx
f0100ff3:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100ff5:	89 f0                	mov    %esi,%eax
f0100ff7:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f0100ffd:	a3 40 22 1e f0       	mov    %eax,0xf01e2240
f0101002:	eb 78                	jmp    f010107c <page_init+0xef>
f0101004:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f010100a:	83 f8 5f             	cmp    $0x5f,%eax
f010100d:	77 16                	ja     f0101025 <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f010100f:	89 f0                	mov    %esi,%eax
f0101011:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f0101017:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f010101d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101023:	eb 57                	jmp    f010107c <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0101025:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010102b:	76 2c                	jbe    f0101059 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f010102d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101032:	e8 c9 fa ff ff       	call   f0100b00 <boot_alloc>
f0101037:	05 00 00 00 10       	add    $0x10000000,%eax
f010103c:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f010103f:	39 c3                	cmp    %eax,%ebx
f0101041:	73 16                	jae    f0101059 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0101043:	89 f0                	mov    %esi,%eax
f0101045:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f010104b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0101051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101057:	eb 23                	jmp    f010107c <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0101059:	89 f0                	mov    %esi,%eax
f010105b:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f0101061:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0101067:	8b 15 40 22 1e f0    	mov    0xf01e2240,%edx
f010106d:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f010106f:	89 f0                	mov    %esi,%eax
f0101071:	03 05 90 2e 1e f0    	add    0xf01e2e90,%eax
f0101077:	a3 40 22 1e f0       	mov    %eax,0xf01e2240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010107c:	83 c3 01             	add    $0x1,%ebx
f010107f:	83 c6 08             	add    $0x8,%esi
f0101082:	3b 1d 88 2e 1e f0    	cmp    0xf01e2e88,%ebx
f0101088:	0f 82 13 ff ff ff    	jb     f0100fa1 <page_init+0x14>
			page_free_list = &pages[i];
		}

	}

}
f010108e:	5b                   	pop    %ebx
f010108f:	5e                   	pop    %esi
f0101090:	5d                   	pop    %ebp
f0101091:	c3                   	ret    

f0101092 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101092:	55                   	push   %ebp
f0101093:	89 e5                	mov    %esp,%ebp
f0101095:	53                   	push   %ebx
f0101096:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0101099:	8b 1d 40 22 1e f0    	mov    0xf01e2240,%ebx
f010109f:	85 db                	test   %ebx,%ebx
f01010a1:	74 6f                	je     f0101112 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f01010a3:	8b 03                	mov    (%ebx),%eax
f01010a5:	a3 40 22 1e f0       	mov    %eax,0xf01e2240
	page->pp_link = 0;
f01010aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f01010b0:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f01010b2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010b6:	74 5f                	je     f0101117 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010b8:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f01010be:	c1 f8 03             	sar    $0x3,%eax
f01010c1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010c4:	89 c2                	mov    %eax,%edx
f01010c6:	c1 ea 0c             	shr    $0xc,%edx
f01010c9:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f01010cf:	72 20                	jb     f01010f1 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010d5:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01010dc:	f0 
f01010dd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010e4:	00 
f01010e5:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f01010ec:	e8 4f ef ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f01010f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01010f8:	00 
f01010f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101100:	00 
	return (void *)(pa + KERNBASE);
f0101101:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101106:	89 04 24             	mov    %eax,(%esp)
f0101109:	e8 d9 4e 00 00       	call   f0105fe7 <memset>
	return page;
f010110e:	89 d8                	mov    %ebx,%eax
f0101110:	eb 05                	jmp    f0101117 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0101112:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
	return 0;
}
f0101117:	83 c4 14             	add    $0x14,%esp
f010111a:	5b                   	pop    %ebx
f010111b:	5d                   	pop    %ebp
f010111c:	c3                   	ret    

f010111d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010111d:	55                   	push   %ebp
f010111e:	89 e5                	mov    %esp,%ebp
f0101120:	83 ec 18             	sub    $0x18,%esp
f0101123:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0101126:	83 38 00             	cmpl   $0x0,(%eax)
f0101129:	75 07                	jne    f0101132 <page_free+0x15>
f010112b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101130:	74 1c                	je     f010114e <page_free+0x31>
		panic("page_free is not right");
f0101132:	c7 44 24 08 60 7c 10 	movl   $0xf0107c60,0x8(%esp)
f0101139:	f0 
f010113a:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
f0101141:	00 
f0101142:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101149:	e8 f2 ee ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010114e:	8b 15 40 22 1e f0    	mov    0xf01e2240,%edx
f0101154:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101156:	a3 40 22 1e f0       	mov    %eax,0xf01e2240
	return; 
}
f010115b:	c9                   	leave  
f010115c:	c3                   	ret    

f010115d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010115d:	55                   	push   %ebp
f010115e:	89 e5                	mov    %esp,%ebp
f0101160:	83 ec 18             	sub    $0x18,%esp
f0101163:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101166:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010116a:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010116d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101171:	66 85 d2             	test   %dx,%dx
f0101174:	75 08                	jne    f010117e <page_decref+0x21>
		page_free(pp);
f0101176:	89 04 24             	mov    %eax,(%esp)
f0101179:	e8 9f ff ff ff       	call   f010111d <page_free>
}
f010117e:	c9                   	leave  
f010117f:	c3                   	ret    

f0101180 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101180:	55                   	push   %ebp
f0101181:	89 e5                	mov    %esp,%ebp
f0101183:	56                   	push   %esi
f0101184:	53                   	push   %ebx
f0101185:	83 ec 10             	sub    $0x10,%esp
f0101188:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f010118b:	89 f3                	mov    %esi,%ebx
f010118d:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f0101190:	c1 e3 02             	shl    $0x2,%ebx
f0101193:	03 5d 08             	add    0x8(%ebp),%ebx
f0101196:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101199:	75 2c                	jne    f01011c7 <pgdir_walk+0x47>
f010119b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010119f:	74 6c                	je     f010120d <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f01011a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01011a8:	e8 e5 fe ff ff       	call   f0101092 <page_alloc>
		if(page == NULL)
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	74 63                	je     f0101214 <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f01011b1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011b6:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f01011bc:	c1 f8 03             	sar    $0x3,%eax
f01011bf:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f01011c2:	83 c8 07             	or     $0x7,%eax
f01011c5:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f01011c7:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f01011c9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01011ce:	c1 ee 0c             	shr    $0xc,%esi
f01011d1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011d7:	89 c2                	mov    %eax,%edx
f01011d9:	c1 ea 0c             	shr    $0xc,%edx
f01011dc:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f01011e2:	72 20                	jb     f0101204 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011e8:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01011ef:	f0 
f01011f0:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
f01011f7:	00 
f01011f8:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01011ff:	e8 3c ee ff ff       	call   f0100040 <_panic>
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
f0101204:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010120b:	eb 0c                	jmp    f0101219 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f010120d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101212:	eb 05                	jmp    f0101219 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0101214:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f0101219:	83 c4 10             	add    $0x10,%esp
f010121c:	5b                   	pop    %ebx
f010121d:	5e                   	pop    %esi
f010121e:	5d                   	pop    %ebp
f010121f:	c3                   	ret    

f0101220 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101220:	55                   	push   %ebp
f0101221:	89 e5                	mov    %esp,%ebp
f0101223:	57                   	push   %edi
f0101224:	56                   	push   %esi
f0101225:	53                   	push   %ebx
f0101226:	83 ec 2c             	sub    $0x2c,%esp
f0101229:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010122c:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size)
f010122e:	89 d3                	mov    %edx,%ebx
f0101230:	8b 45 08             	mov    0x8(%ebp),%eax
f0101233:	29 d0                	sub    %edx,%eax
f0101235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0101238:	8b 45 0c             	mov    0xc(%ebp),%eax
f010123b:	83 c8 01             	or     $0x1,%eax
f010123e:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101241:	eb 2c                	jmp    f010126f <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101243:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010124a:	00 
f010124b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010124f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101252:	89 04 24             	mov    %eax,(%esp)
f0101255:	e8 26 ff ff ff       	call   f0101180 <pgdir_walk>
		if(pte == NULL)
f010125a:	85 c0                	test   %eax,%eax
f010125c:	74 1b                	je     f0101279 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f010125e:	0b 7d dc             	or     -0x24(%ebp),%edi
f0101261:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f0101263:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f0101269:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010126f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101272:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101275:	85 f6                	test   %esi,%esi
f0101277:	75 ca                	jne    f0101243 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f0101279:	83 c4 2c             	add    $0x2c,%esp
f010127c:	5b                   	pop    %ebx
f010127d:	5e                   	pop    %esi
f010127e:	5f                   	pop    %edi
f010127f:	5d                   	pop    %ebp
f0101280:	c3                   	ret    

f0101281 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101281:	55                   	push   %ebp
f0101282:	89 e5                	mov    %esp,%ebp
f0101284:	53                   	push   %ebx
f0101285:	83 ec 14             	sub    $0x14,%esp
f0101288:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f010128b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101292:	00 
f0101293:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101296:	89 44 24 04          	mov    %eax,0x4(%esp)
f010129a:	8b 45 08             	mov    0x8(%ebp),%eax
f010129d:	89 04 24             	mov    %eax,(%esp)
f01012a0:	e8 db fe ff ff       	call   f0101180 <pgdir_walk>
	if(pte == NULL)
f01012a5:	85 c0                	test   %eax,%eax
f01012a7:	74 42                	je     f01012eb <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f01012a9:	8b 10                	mov    (%eax),%edx
f01012ab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f01012b1:	85 db                	test   %ebx,%ebx
f01012b3:	74 02                	je     f01012b7 <page_lookup+0x36>
		*pte_store = pte ;
f01012b5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b7:	89 d0                	mov    %edx,%eax
f01012b9:	c1 e8 0c             	shr    $0xc,%eax
f01012bc:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f01012c2:	72 1c                	jb     f01012e0 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f01012c4:	c7 44 24 08 34 73 10 	movl   $0xf0107334,0x8(%esp)
f01012cb:	f0 
f01012cc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01012d3:	00 
f01012d4:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f01012db:	e8 60 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012e0:	8b 15 90 2e 1e f0    	mov    0xf01e2e90,%edx
f01012e6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f01012e9:	eb 05                	jmp    f01012f0 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f01012eb:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f01012f0:	83 c4 14             	add    $0x14,%esp
f01012f3:	5b                   	pop    %ebx
f01012f4:	5d                   	pop    %ebp
f01012f5:	c3                   	ret    

f01012f6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012f6:	55                   	push   %ebp
f01012f7:	89 e5                	mov    %esp,%ebp
f01012f9:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012fc:	e8 38 53 00 00       	call   f0106639 <cpunum>
f0101301:	6b c0 74             	imul   $0x74,%eax,%eax
f0101304:	83 b8 28 30 1e f0 00 	cmpl   $0x0,-0xfe1cfd8(%eax)
f010130b:	74 16                	je     f0101323 <tlb_invalidate+0x2d>
f010130d:	e8 27 53 00 00       	call   f0106639 <cpunum>
f0101312:	6b c0 74             	imul   $0x74,%eax,%eax
f0101315:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f010131b:	8b 55 08             	mov    0x8(%ebp),%edx
f010131e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101321:	75 06                	jne    f0101329 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101323:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101326:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101329:	c9                   	leave  
f010132a:	c3                   	ret    

f010132b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010132b:	55                   	push   %ebp
f010132c:	89 e5                	mov    %esp,%ebp
f010132e:	56                   	push   %esi
f010132f:	53                   	push   %ebx
f0101330:	83 ec 20             	sub    $0x20,%esp
f0101333:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101336:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101339:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010133c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101340:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101344:	89 1c 24             	mov    %ebx,(%esp)
f0101347:	e8 35 ff ff ff       	call   f0101281 <page_lookup>
	if(page == 0)
f010134c:	85 c0                	test   %eax,%eax
f010134e:	74 2d                	je     f010137d <page_remove+0x52>
		return;
	*pte = 0;
f0101350:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101353:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101359:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010135d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101360:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f0101364:	66 85 d2             	test   %dx,%dx
f0101367:	75 08                	jne    f0101371 <page_remove+0x46>
		page_free(page);
f0101369:	89 04 24             	mov    %eax,(%esp)
f010136c:	e8 ac fd ff ff       	call   f010111d <page_free>
	tlb_invalidate(pgdir, va);
f0101371:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101375:	89 1c 24             	mov    %ebx,(%esp)
f0101378:	e8 79 ff ff ff       	call   f01012f6 <tlb_invalidate>
}
f010137d:	83 c4 20             	add    $0x20,%esp
f0101380:	5b                   	pop    %ebx
f0101381:	5e                   	pop    %esi
f0101382:	5d                   	pop    %ebp
f0101383:	c3                   	ret    

f0101384 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101384:	55                   	push   %ebp
f0101385:	89 e5                	mov    %esp,%ebp
f0101387:	57                   	push   %edi
f0101388:	56                   	push   %esi
f0101389:	53                   	push   %ebx
f010138a:	83 ec 1c             	sub    $0x1c,%esp
f010138d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101390:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101393:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010139a:	00 
f010139b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010139f:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a2:	89 04 24             	mov    %eax,(%esp)
f01013a5:	e8 d6 fd ff ff       	call   f0101180 <pgdir_walk>
f01013aa:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f01013ac:	85 c0                	test   %eax,%eax
f01013ae:	74 5a                	je     f010140a <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f01013b0:	8b 00                	mov    (%eax),%eax
f01013b2:	89 c1                	mov    %eax,%ecx
f01013b4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ba:	89 da                	mov    %ebx,%edx
f01013bc:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f01013c2:	c1 fa 03             	sar    $0x3,%edx
f01013c5:	c1 e2 0c             	shl    $0xc,%edx
f01013c8:	39 d1                	cmp    %edx,%ecx
f01013ca:	75 07                	jne    f01013d3 <page_insert+0x4f>
		pp->pp_ref--;
f01013cc:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01013d1:	eb 13                	jmp    f01013e6 <page_insert+0x62>
	
	else if(*pte != 0)
f01013d3:	85 c0                	test   %eax,%eax
f01013d5:	74 0f                	je     f01013e6 <page_insert+0x62>
		page_remove(pgdir, va);
f01013d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013db:	8b 45 08             	mov    0x8(%ebp),%eax
f01013de:	89 04 24             	mov    %eax,(%esp)
f01013e1:	e8 45 ff ff ff       	call   f010132b <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01013e6:	8b 55 14             	mov    0x14(%ebp),%edx
f01013e9:	83 ca 01             	or     $0x1,%edx
f01013ec:	89 d8                	mov    %ebx,%eax
f01013ee:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f01013f4:	c1 f8 03             	sar    $0x3,%eax
f01013f7:	c1 e0 0c             	shl    $0xc,%eax
f01013fa:	09 d0                	or     %edx,%eax
f01013fc:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01013fe:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101403:	b8 00 00 00 00       	mov    $0x0,%eax
f0101408:	eb 05                	jmp    f010140f <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f010140a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010140f:	83 c4 1c             	add    $0x1c,%esp
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5f                   	pop    %edi
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    

f0101417 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	53                   	push   %ebx
f010141b:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010141e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101421:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101427:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010142d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101430:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if(size + base >= MMIOLIM)
f0101436:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010143c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010143f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101444:	76 1c                	jbe    f0101462 <mmio_map_region+0x4b>
		panic("mmio_map_region not implemented");
f0101446:	c7 44 24 08 54 73 10 	movl   $0xf0107354,0x8(%esp)
f010144d:	f0 
f010144e:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0101455:	00 
f0101456:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010145d:	e8 de eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101462:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101469:	00 
f010146a:	89 0c 24             	mov    %ecx,(%esp)
f010146d:	89 d9                	mov    %ebx,%ecx
f010146f:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101474:	e8 a7 fd ff ff       	call   f0101220 <boot_map_region>
	uintptr_t ret = base;
f0101479:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base +size;
f010147e:	01 c3                	add    %eax,%ebx
f0101480:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) ret;

}
f0101486:	83 c4 14             	add    $0x14,%esp
f0101489:	5b                   	pop    %ebx
f010148a:	5d                   	pop    %ebp
f010148b:	c3                   	ret    

f010148c <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010148c:	55                   	push   %ebp
f010148d:	89 e5                	mov    %esp,%ebp
f010148f:	57                   	push   %edi
f0101490:	56                   	push   %esi
f0101491:	53                   	push   %ebx
f0101492:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101495:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010149c:	e8 b7 29 00 00       	call   f0103e58 <mc146818_read>
f01014a1:	89 c3                	mov    %eax,%ebx
f01014a3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01014aa:	e8 a9 29 00 00       	call   f0103e58 <mc146818_read>
f01014af:	c1 e0 08             	shl    $0x8,%eax
f01014b2:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01014b4:	89 d8                	mov    %ebx,%eax
f01014b6:	c1 e0 0a             	shl    $0xa,%eax
f01014b9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	0f 48 c2             	cmovs  %edx,%eax
f01014c4:	c1 f8 0c             	sar    $0xc,%eax
f01014c7:	a3 44 22 1e f0       	mov    %eax,0xf01e2244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01014cc:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01014d3:	e8 80 29 00 00       	call   f0103e58 <mc146818_read>
f01014d8:	89 c3                	mov    %eax,%ebx
f01014da:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01014e1:	e8 72 29 00 00       	call   f0103e58 <mc146818_read>
f01014e6:	c1 e0 08             	shl    $0x8,%eax
f01014e9:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01014eb:	89 d8                	mov    %ebx,%eax
f01014ed:	c1 e0 0a             	shl    $0xa,%eax
f01014f0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	0f 48 c2             	cmovs  %edx,%eax
f01014fb:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01014fe:	85 c0                	test   %eax,%eax
f0101500:	74 0e                	je     f0101510 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101502:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101508:	89 15 88 2e 1e f0    	mov    %edx,0xf01e2e88
f010150e:	eb 0c                	jmp    f010151c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101510:	8b 15 44 22 1e f0    	mov    0xf01e2244,%edx
f0101516:	89 15 88 2e 1e f0    	mov    %edx,0xf01e2e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010151c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010151f:	c1 e8 0a             	shr    $0xa,%eax
f0101522:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101526:	a1 44 22 1e f0       	mov    0xf01e2244,%eax
f010152b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010152e:	c1 e8 0a             	shr    $0xa,%eax
f0101531:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101535:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f010153a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010153d:	c1 e8 0a             	shr    $0xa,%eax
f0101540:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101544:	c7 04 24 74 73 10 f0 	movl   $0xf0107374,(%esp)
f010154b:	e8 71 2a 00 00       	call   f0103fc1 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101550:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101555:	e8 a6 f5 ff ff       	call   f0100b00 <boot_alloc>
f010155a:	a3 8c 2e 1e f0       	mov    %eax,0xf01e2e8c
	memset(kern_pgdir, 0, PGSIZE);
f010155f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101566:	00 
f0101567:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010156e:	00 
f010156f:	89 04 24             	mov    %eax,(%esp)
f0101572:	e8 70 4a 00 00       	call   f0105fe7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101577:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010157c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101581:	77 20                	ja     f01015a3 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101583:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101587:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f010158e:	f0 
f010158f:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101596:	00 
f0101597:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010159e:	e8 9d ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01015a3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015a9:	83 ca 05             	or     $0x5,%edx
f01015ac:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f01015b2:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f01015b7:	c1 e0 03             	shl    $0x3,%eax
f01015ba:	e8 41 f5 ff ff       	call   f0100b00 <boot_alloc>
f01015bf:	a3 90 2e 1e f0       	mov    %eax,0xf01e2e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f01015c4:	8b 0d 88 2e 1e f0    	mov    0xf01e2e88,%ecx
f01015ca:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01015d1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01015d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015dc:	00 
f01015dd:	89 04 24             	mov    %eax,(%esp)
f01015e0:	e8 02 4a 00 00       	call   f0105fe7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f01015e5:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01015ea:	e8 11 f5 ff ff       	call   f0100b00 <boot_alloc>
f01015ef:	a3 48 22 1e f0       	mov    %eax,0xf01e2248
	memset(envs, 0, NENV*sizeof(struct Env) );
f01015f4:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01015fb:	00 
f01015fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101603:	00 
f0101604:	89 04 24             	mov    %eax,(%esp)
f0101607:	e8 db 49 00 00       	call   f0105fe7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010160c:	e8 7c f9 ff ff       	call   f0100f8d <page_init>

	check_page_free_list(1);
f0101611:	b8 01 00 00 00       	mov    $0x1,%eax
f0101616:	e8 dc f5 ff ff       	call   f0100bf7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010161b:	83 3d 90 2e 1e f0 00 	cmpl   $0x0,0xf01e2e90
f0101622:	75 1c                	jne    f0101640 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f0101624:	c7 44 24 08 77 7c 10 	movl   $0xf0107c77,0x8(%esp)
f010162b:	f0 
f010162c:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101633:	00 
f0101634:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010163b:	e8 00 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101640:	a1 40 22 1e f0       	mov    0xf01e2240,%eax
f0101645:	bb 00 00 00 00       	mov    $0x0,%ebx
f010164a:	eb 05                	jmp    f0101651 <mem_init+0x1c5>
		++nfree;
f010164c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010164f:	8b 00                	mov    (%eax),%eax
f0101651:	85 c0                	test   %eax,%eax
f0101653:	75 f7                	jne    f010164c <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101655:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010165c:	e8 31 fa ff ff       	call   f0101092 <page_alloc>
f0101661:	89 c7                	mov    %eax,%edi
f0101663:	85 c0                	test   %eax,%eax
f0101665:	75 24                	jne    f010168b <mem_init+0x1ff>
f0101667:	c7 44 24 0c 92 7c 10 	movl   $0xf0107c92,0xc(%esp)
f010166e:	f0 
f010166f:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101676:	f0 
f0101677:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f010167e:	00 
f010167f:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101686:	e8 b5 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010168b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101692:	e8 fb f9 ff ff       	call   f0101092 <page_alloc>
f0101697:	89 c6                	mov    %eax,%esi
f0101699:	85 c0                	test   %eax,%eax
f010169b:	75 24                	jne    f01016c1 <mem_init+0x235>
f010169d:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f01016a4:	f0 
f01016a5:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01016ac:	f0 
f01016ad:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01016b4:	00 
f01016b5:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01016bc:	e8 7f e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c8:	e8 c5 f9 ff ff       	call   f0101092 <page_alloc>
f01016cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016d0:	85 c0                	test   %eax,%eax
f01016d2:	75 24                	jne    f01016f8 <mem_init+0x26c>
f01016d4:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f01016db:	f0 
f01016dc:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01016e3:	f0 
f01016e4:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01016eb:	00 
f01016ec:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01016f3:	e8 48 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016f8:	39 f7                	cmp    %esi,%edi
f01016fa:	75 24                	jne    f0101720 <mem_init+0x294>
f01016fc:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f0101703:	f0 
f0101704:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010170b:	f0 
f010170c:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101713:	00 
f0101714:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010171b:	e8 20 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101720:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101723:	39 c6                	cmp    %eax,%esi
f0101725:	74 04                	je     f010172b <mem_init+0x29f>
f0101727:	39 c7                	cmp    %eax,%edi
f0101729:	75 24                	jne    f010174f <mem_init+0x2c3>
f010172b:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f0101732:	f0 
f0101733:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010173a:	f0 
f010173b:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101742:	00 
f0101743:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010174a:	e8 f1 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010174f:	8b 15 90 2e 1e f0    	mov    0xf01e2e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101755:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f010175a:	c1 e0 0c             	shl    $0xc,%eax
f010175d:	89 f9                	mov    %edi,%ecx
f010175f:	29 d1                	sub    %edx,%ecx
f0101761:	c1 f9 03             	sar    $0x3,%ecx
f0101764:	c1 e1 0c             	shl    $0xc,%ecx
f0101767:	39 c1                	cmp    %eax,%ecx
f0101769:	72 24                	jb     f010178f <mem_init+0x303>
f010176b:	c7 44 24 0c e6 7c 10 	movl   $0xf0107ce6,0xc(%esp)
f0101772:	f0 
f0101773:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010177a:	f0 
f010177b:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101782:	00 
f0101783:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010178a:	e8 b1 e8 ff ff       	call   f0100040 <_panic>
f010178f:	89 f1                	mov    %esi,%ecx
f0101791:	29 d1                	sub    %edx,%ecx
f0101793:	c1 f9 03             	sar    $0x3,%ecx
f0101796:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101799:	39 c8                	cmp    %ecx,%eax
f010179b:	77 24                	ja     f01017c1 <mem_init+0x335>
f010179d:	c7 44 24 0c 03 7d 10 	movl   $0xf0107d03,0xc(%esp)
f01017a4:	f0 
f01017a5:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01017ac:	f0 
f01017ad:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f01017b4:	00 
f01017b5:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01017bc:	e8 7f e8 ff ff       	call   f0100040 <_panic>
f01017c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01017c4:	29 d1                	sub    %edx,%ecx
f01017c6:	89 ca                	mov    %ecx,%edx
f01017c8:	c1 fa 03             	sar    $0x3,%edx
f01017cb:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01017ce:	39 d0                	cmp    %edx,%eax
f01017d0:	77 24                	ja     f01017f6 <mem_init+0x36a>
f01017d2:	c7 44 24 0c 20 7d 10 	movl   $0xf0107d20,0xc(%esp)
f01017d9:	f0 
f01017da:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01017e1:	f0 
f01017e2:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01017e9:	00 
f01017ea:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017f6:	a1 40 22 1e f0       	mov    0xf01e2240,%eax
f01017fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017fe:	c7 05 40 22 1e f0 00 	movl   $0x0,0xf01e2240
f0101805:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101808:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010180f:	e8 7e f8 ff ff       	call   f0101092 <page_alloc>
f0101814:	85 c0                	test   %eax,%eax
f0101816:	74 24                	je     f010183c <mem_init+0x3b0>
f0101818:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f010181f:	f0 
f0101820:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101827:	f0 
f0101828:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010182f:	00 
f0101830:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101837:	e8 04 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010183c:	89 3c 24             	mov    %edi,(%esp)
f010183f:	e8 d9 f8 ff ff       	call   f010111d <page_free>
	page_free(pp1);
f0101844:	89 34 24             	mov    %esi,(%esp)
f0101847:	e8 d1 f8 ff ff       	call   f010111d <page_free>
	page_free(pp2);
f010184c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010184f:	89 04 24             	mov    %eax,(%esp)
f0101852:	e8 c6 f8 ff ff       	call   f010111d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010185e:	e8 2f f8 ff ff       	call   f0101092 <page_alloc>
f0101863:	89 c6                	mov    %eax,%esi
f0101865:	85 c0                	test   %eax,%eax
f0101867:	75 24                	jne    f010188d <mem_init+0x401>
f0101869:	c7 44 24 0c 92 7c 10 	movl   $0xf0107c92,0xc(%esp)
f0101870:	f0 
f0101871:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101878:	f0 
f0101879:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101880:	00 
f0101881:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101888:	e8 b3 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010188d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101894:	e8 f9 f7 ff ff       	call   f0101092 <page_alloc>
f0101899:	89 c7                	mov    %eax,%edi
f010189b:	85 c0                	test   %eax,%eax
f010189d:	75 24                	jne    f01018c3 <mem_init+0x437>
f010189f:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f01018a6:	f0 
f01018a7:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01018ae:	f0 
f01018af:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01018b6:	00 
f01018b7:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01018be:	e8 7d e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ca:	e8 c3 f7 ff ff       	call   f0101092 <page_alloc>
f01018cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018d2:	85 c0                	test   %eax,%eax
f01018d4:	75 24                	jne    f01018fa <mem_init+0x46e>
f01018d6:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01018e5:	f0 
f01018e6:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01018ed:	00 
f01018ee:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01018f5:	e8 46 e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018fa:	39 fe                	cmp    %edi,%esi
f01018fc:	75 24                	jne    f0101922 <mem_init+0x496>
f01018fe:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f0101905:	f0 
f0101906:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010190d:	f0 
f010190e:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101915:	00 
f0101916:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010191d:	e8 1e e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101922:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101925:	39 c7                	cmp    %eax,%edi
f0101927:	74 04                	je     f010192d <mem_init+0x4a1>
f0101929:	39 c6                	cmp    %eax,%esi
f010192b:	75 24                	jne    f0101951 <mem_init+0x4c5>
f010192d:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f0101934:	f0 
f0101935:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010193c:	f0 
f010193d:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101944:	00 
f0101945:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010194c:	e8 ef e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101951:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101958:	e8 35 f7 ff ff       	call   f0101092 <page_alloc>
f010195d:	85 c0                	test   %eax,%eax
f010195f:	74 24                	je     f0101985 <mem_init+0x4f9>
f0101961:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101968:	f0 
f0101969:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101970:	f0 
f0101971:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101978:	00 
f0101979:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101980:	e8 bb e6 ff ff       	call   f0100040 <_panic>
f0101985:	89 f0                	mov    %esi,%eax
f0101987:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f010198d:	c1 f8 03             	sar    $0x3,%eax
f0101990:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101993:	89 c2                	mov    %eax,%edx
f0101995:	c1 ea 0c             	shr    $0xc,%edx
f0101998:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f010199e:	72 20                	jb     f01019c0 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019a4:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01019ab:	f0 
f01019ac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019b3:	00 
f01019b4:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f01019bb:	e8 80 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01019c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019c7:	00 
f01019c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01019cf:	00 
	return (void *)(pa + KERNBASE);
f01019d0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019d5:	89 04 24             	mov    %eax,(%esp)
f01019d8:	e8 0a 46 00 00       	call   f0105fe7 <memset>
	page_free(pp0);
f01019dd:	89 34 24             	mov    %esi,(%esp)
f01019e0:	e8 38 f7 ff ff       	call   f010111d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019ec:	e8 a1 f6 ff ff       	call   f0101092 <page_alloc>
f01019f1:	85 c0                	test   %eax,%eax
f01019f3:	75 24                	jne    f0101a19 <mem_init+0x58d>
f01019f5:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f01019fc:	f0 
f01019fd:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101a04:	f0 
f0101a05:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101a0c:	00 
f0101a0d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101a14:	e8 27 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a19:	39 c6                	cmp    %eax,%esi
f0101a1b:	74 24                	je     f0101a41 <mem_init+0x5b5>
f0101a1d:	c7 44 24 0c 6a 7d 10 	movl   $0xf0107d6a,0xc(%esp)
f0101a24:	f0 
f0101a25:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101a2c:	f0 
f0101a2d:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101a34:	00 
f0101a35:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101a3c:	e8 ff e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a41:	89 f0                	mov    %esi,%eax
f0101a43:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f0101a49:	c1 f8 03             	sar    $0x3,%eax
f0101a4c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a4f:	89 c2                	mov    %eax,%edx
f0101a51:	c1 ea 0c             	shr    $0xc,%edx
f0101a54:	3b 15 88 2e 1e f0    	cmp    0xf01e2e88,%edx
f0101a5a:	72 20                	jb     f0101a7c <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a60:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0101a67:	f0 
f0101a68:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a6f:	00 
f0101a70:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0101a77:	e8 c4 e5 ff ff       	call   f0100040 <_panic>
f0101a7c:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101a82:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a88:	80 38 00             	cmpb   $0x0,(%eax)
f0101a8b:	74 24                	je     f0101ab1 <mem_init+0x625>
f0101a8d:	c7 44 24 0c 7a 7d 10 	movl   $0xf0107d7a,0xc(%esp)
f0101a94:	f0 
f0101a95:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101a9c:	f0 
f0101a9d:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101aa4:	00 
f0101aa5:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101aac:	e8 8f e5 ff ff       	call   f0100040 <_panic>
f0101ab1:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ab4:	39 d0                	cmp    %edx,%eax
f0101ab6:	75 d0                	jne    f0101a88 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ab8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101abb:	a3 40 22 1e f0       	mov    %eax,0xf01e2240

	// free the pages we took
	page_free(pp0);
f0101ac0:	89 34 24             	mov    %esi,(%esp)
f0101ac3:	e8 55 f6 ff ff       	call   f010111d <page_free>
	page_free(pp1);
f0101ac8:	89 3c 24             	mov    %edi,(%esp)
f0101acb:	e8 4d f6 ff ff       	call   f010111d <page_free>
	page_free(pp2);
f0101ad0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad3:	89 04 24             	mov    %eax,(%esp)
f0101ad6:	e8 42 f6 ff ff       	call   f010111d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101adb:	a1 40 22 1e f0       	mov    0xf01e2240,%eax
f0101ae0:	eb 05                	jmp    f0101ae7 <mem_init+0x65b>
		--nfree;
f0101ae2:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ae5:	8b 00                	mov    (%eax),%eax
f0101ae7:	85 c0                	test   %eax,%eax
f0101ae9:	75 f7                	jne    f0101ae2 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f0101aeb:	85 db                	test   %ebx,%ebx
f0101aed:	74 24                	je     f0101b13 <mem_init+0x687>
f0101aef:	c7 44 24 0c 84 7d 10 	movl   $0xf0107d84,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101b0e:	e8 2d e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b13:	c7 04 24 d0 73 10 f0 	movl   $0xf01073d0,(%esp)
f0101b1a:	e8 a2 24 00 00       	call   f0103fc1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b26:	e8 67 f5 ff ff       	call   f0101092 <page_alloc>
f0101b2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	75 24                	jne    f0101b56 <mem_init+0x6ca>
f0101b32:	c7 44 24 0c 92 7c 10 	movl   $0xf0107c92,0xc(%esp)
f0101b39:	f0 
f0101b3a:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101b41:	f0 
f0101b42:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101b49:	00 
f0101b4a:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101b51:	e8 ea e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b5d:	e8 30 f5 ff ff       	call   f0101092 <page_alloc>
f0101b62:	89 c3                	mov    %eax,%ebx
f0101b64:	85 c0                	test   %eax,%eax
f0101b66:	75 24                	jne    f0101b8c <mem_init+0x700>
f0101b68:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f0101b6f:	f0 
f0101b70:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101b77:	f0 
f0101b78:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101b7f:	00 
f0101b80:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101b87:	e8 b4 e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b93:	e8 fa f4 ff ff       	call   f0101092 <page_alloc>
f0101b98:	89 c6                	mov    %eax,%esi
f0101b9a:	85 c0                	test   %eax,%eax
f0101b9c:	75 24                	jne    f0101bc2 <mem_init+0x736>
f0101b9e:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f0101ba5:	f0 
f0101ba6:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101bad:	f0 
f0101bae:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0101bb5:	00 
f0101bb6:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101bbd:	e8 7e e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bc2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101bc5:	75 24                	jne    f0101beb <mem_init+0x75f>
f0101bc7:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f0101bce:	f0 
f0101bcf:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101bd6:	f0 
f0101bd7:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101bde:	00 
f0101bdf:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101be6:	e8 55 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101beb:	39 c3                	cmp    %eax,%ebx
f0101bed:	74 05                	je     f0101bf4 <mem_init+0x768>
f0101bef:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101bf2:	75 24                	jne    f0101c18 <mem_init+0x78c>
f0101bf4:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101c13:	e8 28 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c18:	a1 40 22 1e f0       	mov    0xf01e2240,%eax
f0101c1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c20:	c7 05 40 22 1e f0 00 	movl   $0x0,0xf01e2240
f0101c27:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c31:	e8 5c f4 ff ff       	call   f0101092 <page_alloc>
f0101c36:	85 c0                	test   %eax,%eax
f0101c38:	74 24                	je     f0101c5e <mem_init+0x7d2>
f0101c3a:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101c41:	f0 
f0101c42:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101c49:	f0 
f0101c4a:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101c51:	00 
f0101c52:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101c59:	e8 e2 e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c6c:	00 
f0101c6d:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101c72:	89 04 24             	mov    %eax,(%esp)
f0101c75:	e8 07 f6 ff ff       	call   f0101281 <page_lookup>
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	74 24                	je     f0101ca2 <mem_init+0x816>
f0101c7e:	c7 44 24 0c f0 73 10 	movl   $0xf01073f0,0xc(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101c8d:	f0 
f0101c8e:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101c95:	00 
f0101c96:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101c9d:	e8 9e e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ca2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ca9:	00 
f0101caa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cb1:	00 
f0101cb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cb6:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101cbb:	89 04 24             	mov    %eax,(%esp)
f0101cbe:	e8 c1 f6 ff ff       	call   f0101384 <page_insert>
f0101cc3:	85 c0                	test   %eax,%eax
f0101cc5:	78 24                	js     f0101ceb <mem_init+0x85f>
f0101cc7:	c7 44 24 0c 28 74 10 	movl   $0xf0107428,0xc(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101cd6:	f0 
f0101cd7:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101cde:	00 
f0101cdf:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ceb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cee:	89 04 24             	mov    %eax,(%esp)
f0101cf1:	e8 27 f4 ff ff       	call   f010111d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cf6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cfd:	00 
f0101cfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d05:	00 
f0101d06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d0a:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101d0f:	89 04 24             	mov    %eax,(%esp)
f0101d12:	e8 6d f6 ff ff       	call   f0101384 <page_insert>
f0101d17:	85 c0                	test   %eax,%eax
f0101d19:	74 24                	je     f0101d3f <mem_init+0x8b3>
f0101d1b:	c7 44 24 0c 58 74 10 	movl   $0xf0107458,0xc(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101d32:	00 
f0101d33:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101d3a:	e8 01 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d3f:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d45:	a1 90 2e 1e f0       	mov    0xf01e2e90,%eax
f0101d4a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d4d:	8b 17                	mov    (%edi),%edx
f0101d4f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d55:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d58:	29 c1                	sub    %eax,%ecx
f0101d5a:	89 c8                	mov    %ecx,%eax
f0101d5c:	c1 f8 03             	sar    $0x3,%eax
f0101d5f:	c1 e0 0c             	shl    $0xc,%eax
f0101d62:	39 c2                	cmp    %eax,%edx
f0101d64:	74 24                	je     f0101d8a <mem_init+0x8fe>
f0101d66:	c7 44 24 0c 88 74 10 	movl   $0xf0107488,0xc(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101d75:	f0 
f0101d76:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101d7d:	00 
f0101d7e:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101d85:	e8 b6 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d8f:	89 f8                	mov    %edi,%eax
f0101d91:	e8 f2 ed ff ff       	call   f0100b88 <check_va2pa>
f0101d96:	89 da                	mov    %ebx,%edx
f0101d98:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101d9b:	c1 fa 03             	sar    $0x3,%edx
f0101d9e:	c1 e2 0c             	shl    $0xc,%edx
f0101da1:	39 d0                	cmp    %edx,%eax
f0101da3:	74 24                	je     f0101dc9 <mem_init+0x93d>
f0101da5:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f0101dac:	f0 
f0101dad:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101db4:	f0 
f0101db5:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101dbc:	00 
f0101dbd:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101dc4:	e8 77 e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101dc9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dce:	74 24                	je     f0101df4 <mem_init+0x968>
f0101dd0:	c7 44 24 0c 8f 7d 10 	movl   $0xf0107d8f,0xc(%esp)
f0101dd7:	f0 
f0101dd8:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101ddf:	f0 
f0101de0:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101de7:	00 
f0101de8:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101def:	e8 4c e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101df7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dfc:	74 24                	je     f0101e22 <mem_init+0x996>
f0101dfe:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101e15:	00 
f0101e16:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101e1d:	e8 1e e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e22:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e29:	00 
f0101e2a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e31:	00 
f0101e32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e36:	89 3c 24             	mov    %edi,(%esp)
f0101e39:	e8 46 f5 ff ff       	call   f0101384 <page_insert>
f0101e3e:	85 c0                	test   %eax,%eax
f0101e40:	74 24                	je     f0101e66 <mem_init+0x9da>
f0101e42:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f0101e49:	f0 
f0101e4a:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101e51:	f0 
f0101e52:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0101e59:	00 
f0101e5a:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101e61:	e8 da e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6b:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101e70:	e8 13 ed ff ff       	call   f0100b88 <check_va2pa>
f0101e75:	89 f2                	mov    %esi,%edx
f0101e77:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f0101e7d:	c1 fa 03             	sar    $0x3,%edx
f0101e80:	c1 e2 0c             	shl    $0xc,%edx
f0101e83:	39 d0                	cmp    %edx,%eax
f0101e85:	74 24                	je     f0101eab <mem_init+0xa1f>
f0101e87:	c7 44 24 0c 1c 75 10 	movl   $0xf010751c,0xc(%esp)
f0101e8e:	f0 
f0101e8f:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101e9e:	00 
f0101e9f:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101ea6:	e8 95 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101eab:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101eb0:	74 24                	je     f0101ed6 <mem_init+0xa4a>
f0101eb2:	c7 44 24 0c b1 7d 10 	movl   $0xf0107db1,0xc(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101ec1:	f0 
f0101ec2:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101ec9:	00 
f0101eca:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101ed1:	e8 6a e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101edd:	e8 b0 f1 ff ff       	call   f0101092 <page_alloc>
f0101ee2:	85 c0                	test   %eax,%eax
f0101ee4:	74 24                	je     f0101f0a <mem_init+0xa7e>
f0101ee6:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101eed:	f0 
f0101eee:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101ef5:	f0 
f0101ef6:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101efd:	00 
f0101efe:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101f05:	e8 36 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f0a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f11:	00 
f0101f12:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f19:	00 
f0101f1a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f1e:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101f23:	89 04 24             	mov    %eax,(%esp)
f0101f26:	e8 59 f4 ff ff       	call   f0101384 <page_insert>
f0101f2b:	85 c0                	test   %eax,%eax
f0101f2d:	74 24                	je     f0101f53 <mem_init+0xac7>
f0101f2f:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f0101f36:	f0 
f0101f37:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101f3e:	f0 
f0101f3f:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101f46:	00 
f0101f47:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101f4e:	e8 ed e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f53:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f58:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0101f5d:	e8 26 ec ff ff       	call   f0100b88 <check_va2pa>
f0101f62:	89 f2                	mov    %esi,%edx
f0101f64:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f0101f6a:	c1 fa 03             	sar    $0x3,%edx
f0101f6d:	c1 e2 0c             	shl    $0xc,%edx
f0101f70:	39 d0                	cmp    %edx,%eax
f0101f72:	74 24                	je     f0101f98 <mem_init+0xb0c>
f0101f74:	c7 44 24 0c 1c 75 10 	movl   $0xf010751c,0xc(%esp)
f0101f7b:	f0 
f0101f7c:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101f83:	f0 
f0101f84:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0101f8b:	00 
f0101f8c:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101f93:	e8 a8 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f98:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f9d:	74 24                	je     f0101fc3 <mem_init+0xb37>
f0101f9f:	c7 44 24 0c b1 7d 10 	movl   $0xf0107db1,0xc(%esp)
f0101fa6:	f0 
f0101fa7:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101fae:	f0 
f0101faf:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0101fb6:	00 
f0101fb7:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101fbe:	e8 7d e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fca:	e8 c3 f0 ff ff       	call   f0101092 <page_alloc>
f0101fcf:	85 c0                	test   %eax,%eax
f0101fd1:	74 24                	je     f0101ff7 <mem_init+0xb6b>
f0101fd3:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101fda:	f0 
f0101fdb:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0101fe2:	f0 
f0101fe3:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0101fea:	00 
f0101feb:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0101ff2:	e8 49 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ff7:	8b 15 8c 2e 1e f0    	mov    0xf01e2e8c,%edx
f0101ffd:	8b 02                	mov    (%edx),%eax
f0101fff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102004:	89 c1                	mov    %eax,%ecx
f0102006:	c1 e9 0c             	shr    $0xc,%ecx
f0102009:	3b 0d 88 2e 1e f0    	cmp    0xf01e2e88,%ecx
f010200f:	72 20                	jb     f0102031 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102011:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102015:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f010201c:	f0 
f010201d:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102024:	00 
f0102025:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010202c:	e8 0f e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102031:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102036:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102040:	00 
f0102041:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102048:	00 
f0102049:	89 14 24             	mov    %edx,(%esp)
f010204c:	e8 2f f1 ff ff       	call   f0101180 <pgdir_walk>
f0102051:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102054:	8d 51 04             	lea    0x4(%ecx),%edx
f0102057:	39 d0                	cmp    %edx,%eax
f0102059:	74 24                	je     f010207f <mem_init+0xbf3>
f010205b:	c7 44 24 0c 4c 75 10 	movl   $0xf010754c,0xc(%esp)
f0102062:	f0 
f0102063:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010206a:	f0 
f010206b:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102072:	00 
f0102073:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010207a:	e8 c1 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010207f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102086:	00 
f0102087:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010208e:	00 
f010208f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102093:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102098:	89 04 24             	mov    %eax,(%esp)
f010209b:	e8 e4 f2 ff ff       	call   f0101384 <page_insert>
f01020a0:	85 c0                	test   %eax,%eax
f01020a2:	74 24                	je     f01020c8 <mem_init+0xc3c>
f01020a4:	c7 44 24 0c 8c 75 10 	movl   $0xf010758c,0xc(%esp)
f01020ab:	f0 
f01020ac:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01020bb:	00 
f01020bc:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01020c3:	e8 78 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020c8:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
f01020ce:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020d3:	89 f8                	mov    %edi,%eax
f01020d5:	e8 ae ea ff ff       	call   f0100b88 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020da:	89 f2                	mov    %esi,%edx
f01020dc:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f01020e2:	c1 fa 03             	sar    $0x3,%edx
f01020e5:	c1 e2 0c             	shl    $0xc,%edx
f01020e8:	39 d0                	cmp    %edx,%eax
f01020ea:	74 24                	je     f0102110 <mem_init+0xc84>
f01020ec:	c7 44 24 0c 1c 75 10 	movl   $0xf010751c,0xc(%esp)
f01020f3:	f0 
f01020f4:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01020fb:	f0 
f01020fc:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102103:	00 
f0102104:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010210b:	e8 30 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102110:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102115:	74 24                	je     f010213b <mem_init+0xcaf>
f0102117:	c7 44 24 0c b1 7d 10 	movl   $0xf0107db1,0xc(%esp)
f010211e:	f0 
f010211f:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102126:	f0 
f0102127:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010212e:	00 
f010212f:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102136:	e8 05 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010213b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102142:	00 
f0102143:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010214a:	00 
f010214b:	89 3c 24             	mov    %edi,(%esp)
f010214e:	e8 2d f0 ff ff       	call   f0101180 <pgdir_walk>
f0102153:	f6 00 04             	testb  $0x4,(%eax)
f0102156:	75 24                	jne    f010217c <mem_init+0xcf0>
f0102158:	c7 44 24 0c cc 75 10 	movl   $0xf01075cc,0xc(%esp)
f010215f:	f0 
f0102160:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102167:	f0 
f0102168:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010216f:	00 
f0102170:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102177:	e8 c4 de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010217c:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102181:	f6 00 04             	testb  $0x4,(%eax)
f0102184:	75 24                	jne    f01021aa <mem_init+0xd1e>
f0102186:	c7 44 24 0c c2 7d 10 	movl   $0xf0107dc2,0xc(%esp)
f010218d:	f0 
f010218e:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102195:	f0 
f0102196:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010219d:	00 
f010219e:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01021a5:	e8 96 de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021b1:	00 
f01021b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021b9:	00 
f01021ba:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021be:	89 04 24             	mov    %eax,(%esp)
f01021c1:	e8 be f1 ff ff       	call   f0101384 <page_insert>
f01021c6:	85 c0                	test   %eax,%eax
f01021c8:	74 24                	je     f01021ee <mem_init+0xd62>
f01021ca:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f01021d1:	f0 
f01021d2:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01021d9:	f0 
f01021da:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f01021e1:	00 
f01021e2:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01021e9:	e8 52 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021f5:	00 
f01021f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021fd:	00 
f01021fe:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102203:	89 04 24             	mov    %eax,(%esp)
f0102206:	e8 75 ef ff ff       	call   f0101180 <pgdir_walk>
f010220b:	f6 00 02             	testb  $0x2,(%eax)
f010220e:	75 24                	jne    f0102234 <mem_init+0xda8>
f0102210:	c7 44 24 0c 00 76 10 	movl   $0xf0107600,0xc(%esp)
f0102217:	f0 
f0102218:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010221f:	f0 
f0102220:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102227:	00 
f0102228:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010222f:	e8 0c de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102234:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010223b:	00 
f010223c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102243:	00 
f0102244:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102249:	89 04 24             	mov    %eax,(%esp)
f010224c:	e8 2f ef ff ff       	call   f0101180 <pgdir_walk>
f0102251:	f6 00 04             	testb  $0x4,(%eax)
f0102254:	74 24                	je     f010227a <mem_init+0xdee>
f0102256:	c7 44 24 0c 34 76 10 	movl   $0xf0107634,0xc(%esp)
f010225d:	f0 
f010225e:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102265:	f0 
f0102266:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010226d:	00 
f010226e:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102275:	e8 c6 dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010227a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102281:	00 
f0102282:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102289:	00 
f010228a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102291:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102296:	89 04 24             	mov    %eax,(%esp)
f0102299:	e8 e6 f0 ff ff       	call   f0101384 <page_insert>
f010229e:	85 c0                	test   %eax,%eax
f01022a0:	78 24                	js     f01022c6 <mem_init+0xe3a>
f01022a2:	c7 44 24 0c 6c 76 10 	movl   $0xf010766c,0xc(%esp)
f01022a9:	f0 
f01022aa:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01022b1:	f0 
f01022b2:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01022b9:	00 
f01022ba:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01022c1:	e8 7a dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01022c6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022cd:	00 
f01022ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022d5:	00 
f01022d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022da:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f01022df:	89 04 24             	mov    %eax,(%esp)
f01022e2:	e8 9d f0 ff ff       	call   f0101384 <page_insert>
f01022e7:	85 c0                	test   %eax,%eax
f01022e9:	74 24                	je     f010230f <mem_init+0xe83>
f01022eb:	c7 44 24 0c a4 76 10 	movl   $0xf01076a4,0xc(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01022fa:	f0 
f01022fb:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102302:	00 
f0102303:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010230a:	e8 31 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010230f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102316:	00 
f0102317:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010231e:	00 
f010231f:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102324:	89 04 24             	mov    %eax,(%esp)
f0102327:	e8 54 ee ff ff       	call   f0101180 <pgdir_walk>
f010232c:	f6 00 04             	testb  $0x4,(%eax)
f010232f:	74 24                	je     f0102355 <mem_init+0xec9>
f0102331:	c7 44 24 0c 34 76 10 	movl   $0xf0107634,0xc(%esp)
f0102338:	f0 
f0102339:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102340:	f0 
f0102341:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102348:	00 
f0102349:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102350:	e8 eb dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102355:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
f010235b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102360:	89 f8                	mov    %edi,%eax
f0102362:	e8 21 e8 ff ff       	call   f0100b88 <check_va2pa>
f0102367:	89 c1                	mov    %eax,%ecx
f0102369:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010236c:	89 d8                	mov    %ebx,%eax
f010236e:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f0102374:	c1 f8 03             	sar    $0x3,%eax
f0102377:	c1 e0 0c             	shl    $0xc,%eax
f010237a:	39 c1                	cmp    %eax,%ecx
f010237c:	74 24                	je     f01023a2 <mem_init+0xf16>
f010237e:	c7 44 24 0c e0 76 10 	movl   $0xf01076e0,0xc(%esp)
f0102385:	f0 
f0102386:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010238d:	f0 
f010238e:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102395:	00 
f0102396:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010239d:	e8 9e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023a7:	89 f8                	mov    %edi,%eax
f01023a9:	e8 da e7 ff ff       	call   f0100b88 <check_va2pa>
f01023ae:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01023b1:	74 24                	je     f01023d7 <mem_init+0xf4b>
f01023b3:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f01023ba:	f0 
f01023bb:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01023c2:	f0 
f01023c3:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01023ca:	00 
f01023cb:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01023d2:	e8 69 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01023d7:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01023dc:	74 24                	je     f0102402 <mem_init+0xf76>
f01023de:	c7 44 24 0c d8 7d 10 	movl   $0xf0107dd8,0xc(%esp)
f01023e5:	f0 
f01023e6:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01023ed:	f0 
f01023ee:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01023f5:	00 
f01023f6:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01023fd:	e8 3e dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102402:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102407:	74 24                	je     f010242d <mem_init+0xfa1>
f0102409:	c7 44 24 0c e9 7d 10 	movl   $0xf0107de9,0xc(%esp)
f0102410:	f0 
f0102411:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102418:	f0 
f0102419:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102420:	00 
f0102421:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102428:	e8 13 dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010242d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102434:	e8 59 ec ff ff       	call   f0101092 <page_alloc>
f0102439:	85 c0                	test   %eax,%eax
f010243b:	74 04                	je     f0102441 <mem_init+0xfb5>
f010243d:	39 c6                	cmp    %eax,%esi
f010243f:	74 24                	je     f0102465 <mem_init+0xfd9>
f0102441:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f0102448:	f0 
f0102449:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102450:	f0 
f0102451:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102458:	00 
f0102459:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102460:	e8 db db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102465:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010246c:	00 
f010246d:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102472:	89 04 24             	mov    %eax,(%esp)
f0102475:	e8 b1 ee ff ff       	call   f010132b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010247a:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
f0102480:	ba 00 00 00 00       	mov    $0x0,%edx
f0102485:	89 f8                	mov    %edi,%eax
f0102487:	e8 fc e6 ff ff       	call   f0100b88 <check_va2pa>
f010248c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010248f:	74 24                	je     f01024b5 <mem_init+0x1029>
f0102491:	c7 44 24 0c 60 77 10 	movl   $0xf0107760,0xc(%esp)
f0102498:	f0 
f0102499:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01024a0:	f0 
f01024a1:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f01024a8:	00 
f01024a9:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01024b0:	e8 8b db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024b5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024ba:	89 f8                	mov    %edi,%eax
f01024bc:	e8 c7 e6 ff ff       	call   f0100b88 <check_va2pa>
f01024c1:	89 da                	mov    %ebx,%edx
f01024c3:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f01024c9:	c1 fa 03             	sar    $0x3,%edx
f01024cc:	c1 e2 0c             	shl    $0xc,%edx
f01024cf:	39 d0                	cmp    %edx,%eax
f01024d1:	74 24                	je     f01024f7 <mem_init+0x106b>
f01024d3:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f01024da:	f0 
f01024db:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01024e2:	f0 
f01024e3:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01024ea:	00 
f01024eb:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01024f2:	e8 49 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01024f7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01024fc:	74 24                	je     f0102522 <mem_init+0x1096>
f01024fe:	c7 44 24 0c 8f 7d 10 	movl   $0xf0107d8f,0xc(%esp)
f0102505:	f0 
f0102506:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010250d:	f0 
f010250e:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102515:	00 
f0102516:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010251d:	e8 1e db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102522:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102527:	74 24                	je     f010254d <mem_init+0x10c1>
f0102529:	c7 44 24 0c e9 7d 10 	movl   $0xf0107de9,0xc(%esp)
f0102530:	f0 
f0102531:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102538:	f0 
f0102539:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102540:	00 
f0102541:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102548:	e8 f3 da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010254d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102554:	00 
f0102555:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010255c:	00 
f010255d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102561:	89 3c 24             	mov    %edi,(%esp)
f0102564:	e8 1b ee ff ff       	call   f0101384 <page_insert>
f0102569:	85 c0                	test   %eax,%eax
f010256b:	74 24                	je     f0102591 <mem_init+0x1105>
f010256d:	c7 44 24 0c 84 77 10 	movl   $0xf0107784,0xc(%esp)
f0102574:	f0 
f0102575:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010257c:	f0 
f010257d:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102584:	00 
f0102585:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010258c:	e8 af da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102591:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102596:	75 24                	jne    f01025bc <mem_init+0x1130>
f0102598:	c7 44 24 0c fa 7d 10 	movl   $0xf0107dfa,0xc(%esp)
f010259f:	f0 
f01025a0:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01025a7:	f0 
f01025a8:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f01025af:	00 
f01025b0:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01025b7:	e8 84 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025bc:	83 3b 00             	cmpl   $0x0,(%ebx)
f01025bf:	74 24                	je     f01025e5 <mem_init+0x1159>
f01025c1:	c7 44 24 0c 06 7e 10 	movl   $0xf0107e06,0xc(%esp)
f01025c8:	f0 
f01025c9:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01025d0:	f0 
f01025d1:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f01025d8:	00 
f01025d9:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01025e0:	e8 5b da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025ec:	00 
f01025ed:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f01025f2:	89 04 24             	mov    %eax,(%esp)
f01025f5:	e8 31 ed ff ff       	call   f010132b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025fa:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
f0102600:	ba 00 00 00 00       	mov    $0x0,%edx
f0102605:	89 f8                	mov    %edi,%eax
f0102607:	e8 7c e5 ff ff       	call   f0100b88 <check_va2pa>
f010260c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010260f:	74 24                	je     f0102635 <mem_init+0x11a9>
f0102611:	c7 44 24 0c 60 77 10 	movl   $0xf0107760,0xc(%esp)
f0102618:	f0 
f0102619:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102620:	f0 
f0102621:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102628:	00 
f0102629:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102630:	e8 0b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102635:	ba 00 10 00 00       	mov    $0x1000,%edx
f010263a:	89 f8                	mov    %edi,%eax
f010263c:	e8 47 e5 ff ff       	call   f0100b88 <check_va2pa>
f0102641:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102644:	74 24                	je     f010266a <mem_init+0x11de>
f0102646:	c7 44 24 0c bc 77 10 	movl   $0xf01077bc,0xc(%esp)
f010264d:	f0 
f010264e:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102655:	f0 
f0102656:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f010265d:	00 
f010265e:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102665:	e8 d6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010266a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010266f:	74 24                	je     f0102695 <mem_init+0x1209>
f0102671:	c7 44 24 0c 1b 7e 10 	movl   $0xf0107e1b,0xc(%esp)
f0102678:	f0 
f0102679:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102680:	f0 
f0102681:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102688:	00 
f0102689:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102695:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010269a:	74 24                	je     f01026c0 <mem_init+0x1234>
f010269c:	c7 44 24 0c e9 7d 10 	movl   $0xf0107de9,0xc(%esp)
f01026a3:	f0 
f01026a4:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01026ab:	f0 
f01026ac:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01026b3:	00 
f01026b4:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01026bb:	e8 80 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026c7:	e8 c6 e9 ff ff       	call   f0101092 <page_alloc>
f01026cc:	85 c0                	test   %eax,%eax
f01026ce:	74 04                	je     f01026d4 <mem_init+0x1248>
f01026d0:	39 c3                	cmp    %eax,%ebx
f01026d2:	74 24                	je     f01026f8 <mem_init+0x126c>
f01026d4:	c7 44 24 0c e4 77 10 	movl   $0xf01077e4,0xc(%esp)
f01026db:	f0 
f01026dc:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01026e3:	f0 
f01026e4:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f01026eb:	00 
f01026ec:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01026f3:	e8 48 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ff:	e8 8e e9 ff ff       	call   f0101092 <page_alloc>
f0102704:	85 c0                	test   %eax,%eax
f0102706:	74 24                	je     f010272c <mem_init+0x12a0>
f0102708:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f010270f:	f0 
f0102710:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102717:	f0 
f0102718:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f010271f:	00 
f0102720:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102727:	e8 14 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010272c:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102731:	8b 08                	mov    (%eax),%ecx
f0102733:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102739:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010273c:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f0102742:	c1 fa 03             	sar    $0x3,%edx
f0102745:	c1 e2 0c             	shl    $0xc,%edx
f0102748:	39 d1                	cmp    %edx,%ecx
f010274a:	74 24                	je     f0102770 <mem_init+0x12e4>
f010274c:	c7 44 24 0c 88 74 10 	movl   $0xf0107488,0xc(%esp)
f0102753:	f0 
f0102754:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010275b:	f0 
f010275c:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102763:	00 
f0102764:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010276b:	e8 d0 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102770:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102776:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102779:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010277e:	74 24                	je     f01027a4 <mem_init+0x1318>
f0102780:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102787:	f0 
f0102788:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010278f:	f0 
f0102790:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102797:	00 
f0102798:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010279f:	e8 9c d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01027a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027a7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027ad:	89 04 24             	mov    %eax,(%esp)
f01027b0:	e8 68 e9 ff ff       	call   f010111d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027bc:	00 
f01027bd:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027c4:	00 
f01027c5:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f01027ca:	89 04 24             	mov    %eax,(%esp)
f01027cd:	e8 ae e9 ff ff       	call   f0101180 <pgdir_walk>
f01027d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027d8:	8b 15 8c 2e 1e f0    	mov    0xf01e2e8c,%edx
f01027de:	8b 7a 04             	mov    0x4(%edx),%edi
f01027e1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027e7:	8b 0d 88 2e 1e f0    	mov    0xf01e2e88,%ecx
f01027ed:	89 f8                	mov    %edi,%eax
f01027ef:	c1 e8 0c             	shr    $0xc,%eax
f01027f2:	39 c8                	cmp    %ecx,%eax
f01027f4:	72 20                	jb     f0102816 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027f6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01027fa:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0102801:	f0 
f0102802:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102809:	00 
f010280a:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102811:	e8 2a d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102816:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010281c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010281f:	74 24                	je     f0102845 <mem_init+0x13b9>
f0102821:	c7 44 24 0c 2c 7e 10 	movl   $0xf0107e2c,0xc(%esp)
f0102828:	f0 
f0102829:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102830:	f0 
f0102831:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102838:	00 
f0102839:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102840:	e8 fb d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102845:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f010284c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010284f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102855:	2b 05 90 2e 1e f0    	sub    0xf01e2e90,%eax
f010285b:	c1 f8 03             	sar    $0x3,%eax
f010285e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102861:	89 c2                	mov    %eax,%edx
f0102863:	c1 ea 0c             	shr    $0xc,%edx
f0102866:	39 d1                	cmp    %edx,%ecx
f0102868:	77 20                	ja     f010288a <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010286a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010286e:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0102875:	f0 
f0102876:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010287d:	00 
f010287e:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0102885:	e8 b6 d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010288a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102891:	00 
f0102892:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102899:	00 
	return (void *)(pa + KERNBASE);
f010289a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010289f:	89 04 24             	mov    %eax,(%esp)
f01028a2:	e8 40 37 00 00       	call   f0105fe7 <memset>
	page_free(pp0);
f01028a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028aa:	89 3c 24             	mov    %edi,(%esp)
f01028ad:	e8 6b e8 ff ff       	call   f010111d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028b9:	00 
f01028ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028c1:	00 
f01028c2:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f01028c7:	89 04 24             	mov    %eax,(%esp)
f01028ca:	e8 b1 e8 ff ff       	call   f0101180 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028cf:	89 fa                	mov    %edi,%edx
f01028d1:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f01028d7:	c1 fa 03             	sar    $0x3,%edx
f01028da:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028dd:	89 d0                	mov    %edx,%eax
f01028df:	c1 e8 0c             	shr    $0xc,%eax
f01028e2:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f01028e8:	72 20                	jb     f010290a <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028ee:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01028f5:	f0 
f01028f6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028fd:	00 
f01028fe:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0102905:	e8 36 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010290a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102910:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102913:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102919:	f6 00 01             	testb  $0x1,(%eax)
f010291c:	74 24                	je     f0102942 <mem_init+0x14b6>
f010291e:	c7 44 24 0c 44 7e 10 	movl   $0xf0107e44,0xc(%esp)
f0102925:	f0 
f0102926:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010292d:	f0 
f010292e:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102935:	00 
f0102936:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010293d:	e8 fe d6 ff ff       	call   f0100040 <_panic>
f0102942:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102945:	39 d0                	cmp    %edx,%eax
f0102947:	75 d0                	jne    f0102919 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102949:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f010294e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102954:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102957:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010295d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102960:	89 0d 40 22 1e f0    	mov    %ecx,0xf01e2240

	// free the pages we took
	page_free(pp0);
f0102966:	89 04 24             	mov    %eax,(%esp)
f0102969:	e8 af e7 ff ff       	call   f010111d <page_free>
	page_free(pp1);
f010296e:	89 1c 24             	mov    %ebx,(%esp)
f0102971:	e8 a7 e7 ff ff       	call   f010111d <page_free>
	page_free(pp2);
f0102976:	89 34 24             	mov    %esi,(%esp)
f0102979:	e8 9f e7 ff ff       	call   f010111d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010297e:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102985:	00 
f0102986:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010298d:	e8 85 ea ff ff       	call   f0101417 <mmio_map_region>
f0102992:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102994:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010299b:	00 
f010299c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029a3:	e8 6f ea ff ff       	call   f0101417 <mmio_map_region>
f01029a8:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01029aa:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01029b0:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01029b5:	77 08                	ja     f01029bf <mem_init+0x1533>
f01029b7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01029bd:	77 24                	ja     f01029e3 <mem_init+0x1557>
f01029bf:	c7 44 24 0c 08 78 10 	movl   $0xf0107808,0xc(%esp)
f01029c6:	f0 
f01029c7:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01029ce:	f0 
f01029cf:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f01029d6:	00 
f01029d7:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01029de:	e8 5d d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01029e3:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01029e9:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01029ef:	77 08                	ja     f01029f9 <mem_init+0x156d>
f01029f1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029f7:	77 24                	ja     f0102a1d <mem_init+0x1591>
f01029f9:	c7 44 24 0c 30 78 10 	movl   $0xf0107830,0xc(%esp)
f0102a00:	f0 
f0102a01:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102a08:	f0 
f0102a09:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0102a10:	00 
f0102a11:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102a18:	e8 23 d6 ff ff       	call   f0100040 <_panic>
f0102a1d:	89 da                	mov    %ebx,%edx
f0102a1f:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a21:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102a27:	74 24                	je     f0102a4d <mem_init+0x15c1>
f0102a29:	c7 44 24 0c 58 78 10 	movl   $0xf0107858,0xc(%esp)
f0102a30:	f0 
f0102a31:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102a38:	f0 
f0102a39:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102a40:	00 
f0102a41:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102a48:	e8 f3 d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a4d:	39 c6                	cmp    %eax,%esi
f0102a4f:	73 24                	jae    f0102a75 <mem_init+0x15e9>
f0102a51:	c7 44 24 0c 5b 7e 10 	movl   $0xf0107e5b,0xc(%esp)
f0102a58:	f0 
f0102a59:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102a60:	f0 
f0102a61:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0102a68:	00 
f0102a69:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102a70:	e8 cb d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a75:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi
f0102a7b:	89 da                	mov    %ebx,%edx
f0102a7d:	89 f8                	mov    %edi,%eax
f0102a7f:	e8 04 e1 ff ff       	call   f0100b88 <check_va2pa>
f0102a84:	85 c0                	test   %eax,%eax
f0102a86:	74 24                	je     f0102aac <mem_init+0x1620>
f0102a88:	c7 44 24 0c 80 78 10 	movl   $0xf0107880,0xc(%esp)
f0102a8f:	f0 
f0102a90:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102aa7:	e8 94 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102aac:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102ab2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ab5:	89 c2                	mov    %eax,%edx
f0102ab7:	89 f8                	mov    %edi,%eax
f0102ab9:	e8 ca e0 ff ff       	call   f0100b88 <check_va2pa>
f0102abe:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102ac3:	74 24                	je     f0102ae9 <mem_init+0x165d>
f0102ac5:	c7 44 24 0c a4 78 10 	movl   $0xf01078a4,0xc(%esp)
f0102acc:	f0 
f0102acd:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102ad4:	f0 
f0102ad5:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0102adc:	00 
f0102add:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102ae4:	e8 57 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102ae9:	89 f2                	mov    %esi,%edx
f0102aeb:	89 f8                	mov    %edi,%eax
f0102aed:	e8 96 e0 ff ff       	call   f0100b88 <check_va2pa>
f0102af2:	85 c0                	test   %eax,%eax
f0102af4:	74 24                	je     f0102b1a <mem_init+0x168e>
f0102af6:	c7 44 24 0c d4 78 10 	movl   $0xf01078d4,0xc(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102b0d:	00 
f0102b0e:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102b15:	e8 26 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102b1a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102b20:	89 f8                	mov    %edi,%eax
f0102b22:	e8 61 e0 ff ff       	call   f0100b88 <check_va2pa>
f0102b27:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b2a:	74 24                	je     f0102b50 <mem_init+0x16c4>
f0102b2c:	c7 44 24 0c f8 78 10 	movl   $0xf01078f8,0xc(%esp)
f0102b33:	f0 
f0102b34:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102b3b:	f0 
f0102b3c:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102b43:	00 
f0102b44:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102b4b:	e8 f0 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b57:	00 
f0102b58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b5c:	89 3c 24             	mov    %edi,(%esp)
f0102b5f:	e8 1c e6 ff ff       	call   f0101180 <pgdir_walk>
f0102b64:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b67:	75 24                	jne    f0102b8d <mem_init+0x1701>
f0102b69:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f0102b70:	f0 
f0102b71:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102b78:	f0 
f0102b79:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0102b80:	00 
f0102b81:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102b88:	e8 b3 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b94:	00 
f0102b95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b99:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102b9e:	89 04 24             	mov    %eax,(%esp)
f0102ba1:	e8 da e5 ff ff       	call   f0101180 <pgdir_walk>
f0102ba6:	f6 00 04             	testb  $0x4,(%eax)
f0102ba9:	74 24                	je     f0102bcf <mem_init+0x1743>
f0102bab:	c7 44 24 0c 68 79 10 	movl   $0xf0107968,0xc(%esp)
f0102bb2:	f0 
f0102bb3:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102bba:	f0 
f0102bbb:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102bc2:	00 
f0102bc3:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102bca:	e8 71 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102bcf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bd6:	00 
f0102bd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bdb:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102be0:	89 04 24             	mov    %eax,(%esp)
f0102be3:	e8 98 e5 ff ff       	call   f0101180 <pgdir_walk>
f0102be8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102bee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bf5:	00 
f0102bf6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bfd:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102c02:	89 04 24             	mov    %eax,(%esp)
f0102c05:	e8 76 e5 ff ff       	call   f0101180 <pgdir_walk>
f0102c0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102c10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c17:	00 
f0102c18:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c1c:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102c21:	89 04 24             	mov    %eax,(%esp)
f0102c24:	e8 57 e5 ff ff       	call   f0101180 <pgdir_walk>
f0102c29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102c2f:	c7 04 24 6d 7e 10 f0 	movl   $0xf0107e6d,(%esp)
f0102c36:	e8 86 13 00 00       	call   f0103fc1 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c3b:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f0102c40:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102c47:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102c4d:	a1 90 2e 1e f0       	mov    0xf01e2e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c52:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c57:	77 20                	ja     f0102c79 <mem_init+0x17ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c5d:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102c6c:	00 
f0102c6d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102c74:	e8 c7 d3 ff ff       	call   f0100040 <_panic>
f0102c79:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c80:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c81:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c86:	89 04 24             	mov    %eax,(%esp)
f0102c89:	89 d9                	mov    %ebx,%ecx
f0102c8b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c90:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102c95:	e8 86 e5 ff ff       	call   f0101220 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102c9a:	8b 15 90 2e 1e f0    	mov    0xf01e2e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ca0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ca6:	77 20                	ja     f0102cc8 <mem_init+0x183c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cac:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102cb3:	f0 
f0102cb4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102cbb:	00 
f0102cbc:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102cc3:	e8 78 d3 ff ff       	call   f0100040 <_panic>
f0102cc8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ccf:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cd0:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102cd6:	89 04 24             	mov    %eax,(%esp)
f0102cd9:	89 d9                	mov    %ebx,%ecx
f0102cdb:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102ce0:	e8 3b e5 ff ff       	call   f0101220 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102ce5:	a1 48 22 1e f0       	mov    0xf01e2248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cef:	77 20                	ja     f0102d11 <mem_init+0x1885>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cf5:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102cfc:	f0 
f0102cfd:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102d04:	00 
f0102d05:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102d0c:	e8 2f d3 ff ff       	call   f0100040 <_panic>
f0102d11:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d18:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d19:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d1e:	89 04 24             	mov    %eax,(%esp)
f0102d21:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d26:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d2b:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102d30:	e8 eb e4 ff ff       	call   f0101220 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102d35:	8b 15 48 22 1e f0    	mov    0xf01e2248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d3b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d41:	77 20                	ja     f0102d63 <mem_init+0x18d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d43:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d47:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102d56:	00 
f0102d57:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102d5e:	e8 dd d2 ff ff       	call   f0100040 <_panic>
f0102d63:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d6a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d6b:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102d71:	89 04 24             	mov    %eax,(%esp)
f0102d74:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d79:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102d7e:	e8 9d e4 ff ff       	call   f0101220 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d83:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102d88:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d8d:	77 20                	ja     f0102daf <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d93:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102d9a:	f0 
f0102d9b:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102da2:	00 
f0102da3:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102daa:	e8 91 d2 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102daf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102db6:	00 
f0102db7:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102dbe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dc3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102dc8:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102dcd:	e8 4e e4 ff ff       	call   f0101220 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102dd2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102dd9:	00 
f0102dda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102de1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102de6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102deb:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102df0:	e8 2b e4 ff ff       	call   f0101220 <boot_map_region>
f0102df5:	bf 00 40 22 f0       	mov    $0xf0224000,%edi
f0102dfa:	bb 00 40 1e f0       	mov    $0xf01e4000,%ebx
f0102dff:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e04:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e0a:	77 20                	ja     f0102e2c <mem_init+0x19a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e0c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e10:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102e17:	f0 
f0102e18:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0102e1f:	00 
f0102e20:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102e27:	e8 14 d2 ff ff       	call   f0100040 <_panic>
    for (i = 0; i < NCPU; i++)
    {
        kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        //boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)

        boot_map_region(kern_pgdir,
f0102e2c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e33:	00 
f0102e34:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102e3a:	89 04 24             	mov    %eax,(%esp)
f0102e3d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e42:	89 f2                	mov    %esi,%edx
f0102e44:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0102e49:	e8 d2 e3 ff ff       	call   f0101220 <boot_map_region>
f0102e4e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102e54:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:
	 int i = 0;
    uintptr_t kstacktop_i;
    
    for (i = 0; i < NCPU; i++)
f0102e5a:	39 fb                	cmp    %edi,%ebx
f0102e5c:	75 a6                	jne    f0102e04 <mem_init+0x1978>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e5e:	8b 3d 8c 2e 1e f0    	mov    0xf01e2e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e64:	a1 88 2e 1e f0       	mov    0xf01e2e88,%eax
f0102e69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e6c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102e73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e78:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e7b:	8b 35 90 2e 1e f0    	mov    0xf01e2e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e81:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102e84:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102e8a:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e92:	eb 6a                	jmp    f0102efe <mem_init+0x1a72>
f0102e94:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e9a:	89 f8                	mov    %edi,%eax
f0102e9c:	e8 e7 dc ff ff       	call   f0100b88 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ea1:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ea8:	77 20                	ja     f0102eca <mem_init+0x1a3e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eaa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102eae:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102eb5:	f0 
f0102eb6:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102ebd:	00 
f0102ebe:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102ec5:	e8 76 d1 ff ff       	call   f0100040 <_panic>
f0102eca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ecd:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102ed0:	39 d0                	cmp    %edx,%eax
f0102ed2:	74 24                	je     f0102ef8 <mem_init+0x1a6c>
f0102ed4:	c7 44 24 0c 9c 79 10 	movl   $0xf010799c,0xc(%esp)
f0102edb:	f0 
f0102edc:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102ee3:	f0 
f0102ee4:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102eeb:	00 
f0102eec:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102ef3:	e8 48 d1 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ef8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102efe:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102f01:	77 91                	ja     f0102e94 <mem_init+0x1a08>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f03:	8b 1d 48 22 1e f0    	mov    0xf01e2248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f09:	89 de                	mov    %ebx,%esi
f0102f0b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102f10:	89 f8                	mov    %edi,%eax
f0102f12:	e8 71 dc ff ff       	call   f0100b88 <check_va2pa>
f0102f17:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102f1d:	77 20                	ja     f0102f3f <mem_init+0x1ab3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f1f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102f23:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0102f2a:	f0 
f0102f2b:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102f32:	00 
f0102f33:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102f3a:	e8 01 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f3f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102f44:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102f4a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102f4d:	39 d0                	cmp    %edx,%eax
f0102f4f:	74 24                	je     f0102f75 <mem_init+0x1ae9>
f0102f51:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f0102f58:	f0 
f0102f59:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102f68:	00 
f0102f69:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102f70:	e8 cb d0 ff ff       	call   f0100040 <_panic>
f0102f75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f7b:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102f81:	0f 85 a8 05 00 00    	jne    f010352f <mem_init+0x20a3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f87:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102f8a:	c1 e6 0c             	shl    $0xc,%esi
f0102f8d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f92:	eb 3b                	jmp    f0102fcf <mem_init+0x1b43>
f0102f94:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f9a:	89 f8                	mov    %edi,%eax
f0102f9c:	e8 e7 db ff ff       	call   f0100b88 <check_va2pa>
f0102fa1:	39 c3                	cmp    %eax,%ebx
f0102fa3:	74 24                	je     f0102fc9 <mem_init+0x1b3d>
f0102fa5:	c7 44 24 0c 04 7a 10 	movl   $0xf0107a04,0xc(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0102fb4:	f0 
f0102fb5:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102fbc:	00 
f0102fbd:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0102fc4:	e8 77 d0 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102fc9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fcf:	39 f3                	cmp    %esi,%ebx
f0102fd1:	72 c1                	jb     f0102f94 <mem_init+0x1b08>
f0102fd3:	c7 45 d0 00 40 1e f0 	movl   $0xf01e4000,-0x30(%ebp)
f0102fda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102fe1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102fe6:	b8 00 40 1e f0       	mov    $0xf01e4000,%eax
f0102feb:	05 00 80 00 20       	add    $0x20008000,%eax
f0102ff0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102ff3:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102ff9:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ffc:	89 f2                	mov    %esi,%edx
f0102ffe:	89 f8                	mov    %edi,%eax
f0103000:	e8 83 db ff ff       	call   f0100b88 <check_va2pa>
f0103005:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103008:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010300e:	77 20                	ja     f0103030 <mem_init+0x1ba4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103010:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103014:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f010301b:	f0 
f010301c:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0103023:	00 
f0103024:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010302b:	e8 10 d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103030:	89 f3                	mov    %esi,%ebx
f0103032:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103035:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0103038:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010303b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010303e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0103041:	39 c2                	cmp    %eax,%edx
f0103043:	74 24                	je     f0103069 <mem_init+0x1bdd>
f0103045:	c7 44 24 0c 2c 7a 10 	movl   $0xf0107a2c,0xc(%esp)
f010304c:	f0 
f010304d:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103054:	f0 
f0103055:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f010305c:	00 
f010305d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103064:	e8 d7 cf ff ff       	call   f0100040 <_panic>
f0103069:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010306f:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0103072:	0f 85 a9 04 00 00    	jne    f0103521 <mem_init+0x2095>
f0103078:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010307e:	89 da                	mov    %ebx,%edx
f0103080:	89 f8                	mov    %edi,%eax
f0103082:	e8 01 db ff ff       	call   f0100b88 <check_va2pa>
f0103087:	83 f8 ff             	cmp    $0xffffffff,%eax
f010308a:	74 24                	je     f01030b0 <mem_init+0x1c24>
f010308c:	c7 44 24 0c 74 7a 10 	movl   $0xf0107a74,0xc(%esp)
f0103093:	f0 
f0103094:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010309b:	f0 
f010309c:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01030a3:	00 
f01030a4:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01030ab:	e8 90 cf ff ff       	call   f0100040 <_panic>
f01030b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01030b6:	39 de                	cmp    %ebx,%esi
f01030b8:	75 c4                	jne    f010307e <mem_init+0x1bf2>
f01030ba:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01030c0:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f01030c7:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01030ce:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01030d4:	0f 85 19 ff ff ff    	jne    f0102ff3 <mem_init+0x1b67>
f01030da:	b8 00 00 00 00       	mov    $0x0,%eax
f01030df:	e9 c2 00 00 00       	jmp    f01031a6 <mem_init+0x1d1a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01030e4:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01030ea:	83 fa 04             	cmp    $0x4,%edx
f01030ed:	77 2e                	ja     f010311d <mem_init+0x1c91>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01030ef:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01030f3:	0f 85 aa 00 00 00    	jne    f01031a3 <mem_init+0x1d17>
f01030f9:	c7 44 24 0c 86 7e 10 	movl   $0xf0107e86,0xc(%esp)
f0103100:	f0 
f0103101:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103108:	f0 
f0103109:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0103110:	00 
f0103111:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103118:	e8 23 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010311d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103122:	76 55                	jbe    f0103179 <mem_init+0x1ced>
				assert(pgdir[i] & PTE_P);
f0103124:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103127:	f6 c2 01             	test   $0x1,%dl
f010312a:	75 24                	jne    f0103150 <mem_init+0x1cc4>
f010312c:	c7 44 24 0c 86 7e 10 	movl   $0xf0107e86,0xc(%esp)
f0103133:	f0 
f0103134:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010313b:	f0 
f010313c:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0103143:	00 
f0103144:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010314b:	e8 f0 ce ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103150:	f6 c2 02             	test   $0x2,%dl
f0103153:	75 4e                	jne    f01031a3 <mem_init+0x1d17>
f0103155:	c7 44 24 0c 97 7e 10 	movl   $0xf0107e97,0xc(%esp)
f010315c:	f0 
f010315d:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103164:	f0 
f0103165:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f010316c:	00 
f010316d:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103174:	e8 c7 ce ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103179:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010317d:	74 24                	je     f01031a3 <mem_init+0x1d17>
f010317f:	c7 44 24 0c a8 7e 10 	movl   $0xf0107ea8,0xc(%esp)
f0103186:	f0 
f0103187:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010318e:	f0 
f010318f:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0103196:	00 
f0103197:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010319e:	e8 9d ce ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01031a3:	83 c0 01             	add    $0x1,%eax
f01031a6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01031ab:	0f 85 33 ff ff ff    	jne    f01030e4 <mem_init+0x1c58>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01031b1:	c7 04 24 98 7a 10 f0 	movl   $0xf0107a98,(%esp)
f01031b8:	e8 04 0e 00 00       	call   f0103fc1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01031bd:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f01031c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031c7:	77 20                	ja     f01031e9 <mem_init+0x1d5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031cd:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f01031d4:	f0 
f01031d5:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f01031dc:	00 
f01031dd:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01031e4:	e8 57 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031e9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031ee:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01031f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01031f6:	e8 fc d9 ff ff       	call   f0100bf7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01031fb:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01031fe:	83 e0 f3             	and    $0xfffffff3,%eax
f0103201:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103206:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103209:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103210:	e8 7d de ff ff       	call   f0101092 <page_alloc>
f0103215:	89 c3                	mov    %eax,%ebx
f0103217:	85 c0                	test   %eax,%eax
f0103219:	75 24                	jne    f010323f <mem_init+0x1db3>
f010321b:	c7 44 24 0c 92 7c 10 	movl   $0xf0107c92,0xc(%esp)
f0103222:	f0 
f0103223:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010322a:	f0 
f010322b:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f0103232:	00 
f0103233:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010323a:	e8 01 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010323f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103246:	e8 47 de ff ff       	call   f0101092 <page_alloc>
f010324b:	89 c7                	mov    %eax,%edi
f010324d:	85 c0                	test   %eax,%eax
f010324f:	75 24                	jne    f0103275 <mem_init+0x1de9>
f0103251:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f0103258:	f0 
f0103259:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103260:	f0 
f0103261:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103268:	00 
f0103269:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103270:	e8 cb cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103275:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010327c:	e8 11 de ff ff       	call   f0101092 <page_alloc>
f0103281:	89 c6                	mov    %eax,%esi
f0103283:	85 c0                	test   %eax,%eax
f0103285:	75 24                	jne    f01032ab <mem_init+0x1e1f>
f0103287:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f010328e:	f0 
f010328f:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103296:	f0 
f0103297:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f010329e:	00 
f010329f:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01032a6:	e8 95 cd ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01032ab:	89 1c 24             	mov    %ebx,(%esp)
f01032ae:	e8 6a de ff ff       	call   f010111d <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01032b3:	89 f8                	mov    %edi,%eax
f01032b5:	e8 89 d8 ff ff       	call   f0100b43 <page2kva>
f01032ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032c1:	00 
f01032c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01032c9:	00 
f01032ca:	89 04 24             	mov    %eax,(%esp)
f01032cd:	e8 15 2d 00 00       	call   f0105fe7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f01032d2:	89 f0                	mov    %esi,%eax
f01032d4:	e8 6a d8 ff ff       	call   f0100b43 <page2kva>
f01032d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032e0:	00 
f01032e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01032e8:	00 
f01032e9:	89 04 24             	mov    %eax,(%esp)
f01032ec:	e8 f6 2c 00 00       	call   f0105fe7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01032f1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032f8:	00 
f01032f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103300:	00 
f0103301:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103305:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f010330a:	89 04 24             	mov    %eax,(%esp)
f010330d:	e8 72 e0 ff ff       	call   f0101384 <page_insert>
	assert(pp1->pp_ref == 1);
f0103312:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103317:	74 24                	je     f010333d <mem_init+0x1eb1>
f0103319:	c7 44 24 0c 8f 7d 10 	movl   $0xf0107d8f,0xc(%esp)
f0103320:	f0 
f0103321:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103328:	f0 
f0103329:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f0103330:	00 
f0103331:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103338:	e8 03 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010333d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103344:	01 01 01 
f0103347:	74 24                	je     f010336d <mem_init+0x1ee1>
f0103349:	c7 44 24 0c b8 7a 10 	movl   $0xf0107ab8,0xc(%esp)
f0103350:	f0 
f0103351:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0103358:	f0 
f0103359:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103360:	00 
f0103361:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103368:	e8 d3 cc ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010336d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103374:	00 
f0103375:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010337c:	00 
f010337d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103381:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0103386:	89 04 24             	mov    %eax,(%esp)
f0103389:	e8 f6 df ff ff       	call   f0101384 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010338e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103395:	02 02 02 
f0103398:	74 24                	je     f01033be <mem_init+0x1f32>
f010339a:	c7 44 24 0c dc 7a 10 	movl   $0xf0107adc,0xc(%esp)
f01033a1:	f0 
f01033a2:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01033a9:	f0 
f01033aa:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01033b1:	00 
f01033b2:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01033b9:	e8 82 cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01033be:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01033c3:	74 24                	je     f01033e9 <mem_init+0x1f5d>
f01033c5:	c7 44 24 0c b1 7d 10 	movl   $0xf0107db1,0xc(%esp)
f01033cc:	f0 
f01033cd:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01033d4:	f0 
f01033d5:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f01033dc:	00 
f01033dd:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01033e4:	e8 57 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01033e9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01033ee:	74 24                	je     f0103414 <mem_init+0x1f88>
f01033f0:	c7 44 24 0c 1b 7e 10 	movl   $0xf0107e1b,0xc(%esp)
f01033f7:	f0 
f01033f8:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01033ff:	f0 
f0103400:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0103407:	00 
f0103408:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010340f:	e8 2c cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103414:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010341b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010341e:	89 f0                	mov    %esi,%eax
f0103420:	e8 1e d7 ff ff       	call   f0100b43 <page2kva>
f0103425:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010342b:	74 24                	je     f0103451 <mem_init+0x1fc5>
f010342d:	c7 44 24 0c 00 7b 10 	movl   $0xf0107b00,0xc(%esp)
f0103434:	f0 
f0103435:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010343c:	f0 
f010343d:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0103444:	00 
f0103445:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010344c:	e8 ef cb ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103451:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103458:	00 
f0103459:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f010345e:	89 04 24             	mov    %eax,(%esp)
f0103461:	e8 c5 de ff ff       	call   f010132b <page_remove>
	assert(pp2->pp_ref == 0);
f0103466:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010346b:	74 24                	je     f0103491 <mem_init+0x2005>
f010346d:	c7 44 24 0c e9 7d 10 	movl   $0xf0107de9,0xc(%esp)
f0103474:	f0 
f0103475:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f010347c:	f0 
f010347d:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0103484:	00 
f0103485:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f010348c:	e8 af cb ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103491:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0103496:	8b 08                	mov    (%eax),%ecx
f0103498:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010349e:	89 da                	mov    %ebx,%edx
f01034a0:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f01034a6:	c1 fa 03             	sar    $0x3,%edx
f01034a9:	c1 e2 0c             	shl    $0xc,%edx
f01034ac:	39 d1                	cmp    %edx,%ecx
f01034ae:	74 24                	je     f01034d4 <mem_init+0x2048>
f01034b0:	c7 44 24 0c 88 74 10 	movl   $0xf0107488,0xc(%esp)
f01034b7:	f0 
f01034b8:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01034bf:	f0 
f01034c0:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f01034c7:	00 
f01034c8:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f01034cf:	e8 6c cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01034d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01034da:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01034df:	74 24                	je     f0103505 <mem_init+0x2079>
f01034e1:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f01034e8:	f0 
f01034e9:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01034f0:	f0 
f01034f1:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f01034f8:	00 
f01034f9:	c7 04 24 9b 7b 10 f0 	movl   $0xf0107b9b,(%esp)
f0103500:	e8 3b cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103505:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010350b:	89 1c 24             	mov    %ebx,(%esp)
f010350e:	e8 0a dc ff ff       	call   f010111d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103513:	c7 04 24 2c 7b 10 f0 	movl   $0xf0107b2c,(%esp)
f010351a:	e8 a2 0a 00 00       	call   f0103fc1 <cprintf>
f010351f:	eb 1c                	jmp    f010353d <mem_init+0x20b1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103521:	89 da                	mov    %ebx,%edx
f0103523:	89 f8                	mov    %edi,%eax
f0103525:	e8 5e d6 ff ff       	call   f0100b88 <check_va2pa>
f010352a:	e9 0c fb ff ff       	jmp    f010303b <mem_init+0x1baf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010352f:	89 da                	mov    %ebx,%edx
f0103531:	89 f8                	mov    %edi,%eax
f0103533:	e8 50 d6 ff ff       	call   f0100b88 <check_va2pa>
f0103538:	e9 0d fa ff ff       	jmp    f0102f4a <mem_init+0x1abe>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010353d:	83 c4 4c             	add    $0x4c,%esp
f0103540:	5b                   	pop    %ebx
f0103541:	5e                   	pop    %esi
f0103542:	5f                   	pop    %edi
f0103543:	5d                   	pop    %ebp
f0103544:	c3                   	ret    

f0103545 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103545:	55                   	push   %ebp
f0103546:	89 e5                	mov    %esp,%ebp
f0103548:	57                   	push   %edi
f0103549:	56                   	push   %esi
f010354a:	53                   	push   %ebx
f010354b:	83 ec 1c             	sub    $0x1c,%esp
f010354e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103551:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103557:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010355d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103560:	03 45 10             	add    0x10(%ebp),%eax
f0103563:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103568:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010356d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f0103570:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103576:	76 5d                	jbe    f01035d5 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f0103578:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357b:	a3 3c 22 1e f0       	mov    %eax,0xf01e223c
        return -E_FAULT;
f0103580:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103585:	eb 58                	jmp    f01035df <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f0103587:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010358e:	00 
f010358f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103593:	8b 47 60             	mov    0x60(%edi),%eax
f0103596:	89 04 24             	mov    %eax,(%esp)
f0103599:	e8 e2 db ff ff       	call   f0101180 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f010359e:	85 c0                	test   %eax,%eax
f01035a0:	74 0c                	je     f01035ae <user_mem_check+0x69>
f01035a2:	8b 00                	mov    (%eax),%eax
f01035a4:	a8 01                	test   $0x1,%al
f01035a6:	74 06                	je     f01035ae <user_mem_check+0x69>
f01035a8:	21 f0                	and    %esi,%eax
f01035aa:	39 c6                	cmp    %eax,%esi
f01035ac:	74 21                	je     f01035cf <user_mem_check+0x8a>
        {
            if (addr < va)
f01035ae:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01035b1:	76 0f                	jbe    f01035c2 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b6:	a3 3c 22 1e f0       	mov    %eax,0xf01e223c
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01035bb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01035c0:	eb 1d                	jmp    f01035df <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f01035c2:	89 1d 3c 22 1e f0    	mov    %ebx,0xf01e223c
            }
            
            return -E_FAULT;
f01035c8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01035cd:	eb 10                	jmp    f01035df <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f01035cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035d5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01035d8:	72 ad                	jb     f0103587 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f01035da:	b8 00 00 00 00       	mov    $0x0,%eax

}
f01035df:	83 c4 1c             	add    $0x1c,%esp
f01035e2:	5b                   	pop    %ebx
f01035e3:	5e                   	pop    %esi
f01035e4:	5f                   	pop    %edi
f01035e5:	5d                   	pop    %ebp
f01035e6:	c3                   	ret    

f01035e7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01035e7:	55                   	push   %ebp
f01035e8:	89 e5                	mov    %esp,%ebp
f01035ea:	53                   	push   %ebx
f01035eb:	83 ec 14             	sub    $0x14,%esp
f01035ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01035f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01035f4:	83 c8 04             	or     $0x4,%eax
f01035f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035fb:	8b 45 10             	mov    0x10(%ebp),%eax
f01035fe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103602:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103605:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103609:	89 1c 24             	mov    %ebx,(%esp)
f010360c:	e8 34 ff ff ff       	call   f0103545 <user_mem_check>
f0103611:	85 c0                	test   %eax,%eax
f0103613:	79 24                	jns    f0103639 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103615:	a1 3c 22 1e f0       	mov    0xf01e223c,%eax
f010361a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010361e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103621:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103625:	c7 04 24 58 7b 10 f0 	movl   $0xf0107b58,(%esp)
f010362c:	e8 90 09 00 00       	call   f0103fc1 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103631:	89 1c 24             	mov    %ebx,(%esp)
f0103634:	e8 91 06 00 00       	call   f0103cca <env_destroy>
	}
}
f0103639:	83 c4 14             	add    $0x14,%esp
f010363c:	5b                   	pop    %ebx
f010363d:	5d                   	pop    %ebp
f010363e:	c3                   	ret    

f010363f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
f0103642:	57                   	push   %edi
f0103643:	56                   	push   %esi
f0103644:	53                   	push   %ebx
f0103645:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f0103648:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f010364b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103652:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103657:	89 d1                	mov    %edx,%ecx
f0103659:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010365f:	29 c8                	sub    %ecx,%eax
f0103661:	c1 e8 0c             	shr    $0xc,%eax
f0103664:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f0103667:	89 d6                	mov    %edx,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f0103669:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010366e:	eb 6d                	jmp    f01036dd <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f0103670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103677:	e8 16 da ff ff       	call   f0101092 <page_alloc>
		if(newPage == 0)
f010367c:	85 c0                	test   %eax,%eax
f010367e:	75 1c                	jne    f010369c <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f0103680:	c7 44 24 08 b8 7e 10 	movl   $0xf0107eb8,0x8(%esp)
f0103687:	f0 
f0103688:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f010368f:	00 
f0103690:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103697:	e8 a4 c9 ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f010369c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01036a3:	00 
f01036a4:	89 74 24 08          	mov    %esi,0x8(%esp)
f01036a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ac:	89 3c 24             	mov    %edi,(%esp)
f01036af:	e8 d0 dc ff ff       	call   f0101384 <page_insert>
f01036b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f01036ba:	85 c0                	test   %eax,%eax
f01036bc:	74 1c                	je     f01036da <region_alloc+0x9b>
			panic("page_insert fail\n");
f01036be:	c7 44 24 08 f2 7e 10 	movl   $0xf0107ef2,0x8(%esp)
f01036c5:	f0 
f01036c6:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f01036cd:	00 
f01036ce:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f01036d5:	e8 66 c9 ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f01036da:	83 c3 01             	add    $0x1,%ebx
f01036dd:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01036e0:	7c 8e                	jl     f0103670 <region_alloc+0x31>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
		if(ret)
			panic("page_insert fail\n");
	}
	return ;
}
f01036e2:	83 c4 2c             	add    $0x2c,%esp
f01036e5:	5b                   	pop    %ebx
f01036e6:	5e                   	pop    %esi
f01036e7:	5f                   	pop    %edi
f01036e8:	5d                   	pop    %ebp
f01036e9:	c3                   	ret    

f01036ea <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01036ea:	55                   	push   %ebp
f01036eb:	89 e5                	mov    %esp,%ebp
f01036ed:	56                   	push   %esi
f01036ee:	53                   	push   %ebx
f01036ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f2:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01036f5:	85 c0                	test   %eax,%eax
f01036f7:	75 1a                	jne    f0103713 <envid2env+0x29>
		*env_store = curenv;
f01036f9:	e8 3b 2f 00 00       	call   f0106639 <cpunum>
f01036fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103701:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010370a:	89 01                	mov    %eax,(%ecx)
		return 0;
f010370c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103711:	eb 70                	jmp    f0103783 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103713:	89 c3                	mov    %eax,%ebx
f0103715:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010371b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010371e:	03 1d 48 22 1e f0    	add    0xf01e2248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103724:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103728:	74 05                	je     f010372f <envid2env+0x45>
f010372a:	39 43 48             	cmp    %eax,0x48(%ebx)
f010372d:	74 10                	je     f010373f <envid2env+0x55>
		*env_store = 0;
f010372f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103732:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103738:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010373d:	eb 44                	jmp    f0103783 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010373f:	84 d2                	test   %dl,%dl
f0103741:	74 36                	je     f0103779 <envid2env+0x8f>
f0103743:	e8 f1 2e 00 00       	call   f0106639 <cpunum>
f0103748:	6b c0 74             	imul   $0x74,%eax,%eax
f010374b:	39 98 28 30 1e f0    	cmp    %ebx,-0xfe1cfd8(%eax)
f0103751:	74 26                	je     f0103779 <envid2env+0x8f>
f0103753:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103756:	e8 de 2e 00 00       	call   f0106639 <cpunum>
f010375b:	6b c0 74             	imul   $0x74,%eax,%eax
f010375e:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103764:	3b 70 48             	cmp    0x48(%eax),%esi
f0103767:	74 10                	je     f0103779 <envid2env+0x8f>
		*env_store = 0;
f0103769:	8b 45 0c             	mov    0xc(%ebp),%eax
f010376c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103772:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103777:	eb 0a                	jmp    f0103783 <envid2env+0x99>
	}

	*env_store = e;
f0103779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377c:	89 18                	mov    %ebx,(%eax)
	return 0;
f010377e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103783:	5b                   	pop    %ebx
f0103784:	5e                   	pop    %esi
f0103785:	5d                   	pop    %ebp
f0103786:	c3                   	ret    

f0103787 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103787:	55                   	push   %ebp
f0103788:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010378a:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f010378f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103792:	b8 23 00 00 00       	mov    $0x23,%eax
f0103797:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103799:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010379b:	b0 10                	mov    $0x10,%al
f010379d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010379f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01037a1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01037a3:	ea aa 37 10 f0 08 00 	ljmp   $0x8,$0xf01037aa
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01037aa:	b0 00                	mov    $0x0,%al
f01037ac:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01037af:	5d                   	pop    %ebp
f01037b0:	c3                   	ret    

f01037b1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01037b1:	55                   	push   %ebp
f01037b2:	89 e5                	mov    %esp,%ebp
f01037b4:	56                   	push   %esi
f01037b5:	53                   	push   %ebx
	// Set up envs array
	// LAB :fang :Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01037b6:	8b 35 48 22 1e f0    	mov    0xf01e2248,%esi
f01037bc:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01037c2:	ba 00 04 00 00       	mov    $0x400,%edx
f01037c7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037cc:	89 c3                	mov    %eax,%ebx
f01037ce:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01037d5:	89 48 44             	mov    %ecx,0x44(%eax)
f01037d8:	83 e8 7c             	sub    $0x7c,%eax
{
	// Set up envs array
	// LAB :fang :Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f01037db:	83 ea 01             	sub    $0x1,%edx
f01037de:	74 04                	je     f01037e4 <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01037e0:	89 d9                	mov    %ebx,%ecx
f01037e2:	eb e8                	jmp    f01037cc <env_init+0x1b>
f01037e4:	89 35 4c 22 1e f0    	mov    %esi,0xf01e224c
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01037ea:	e8 98 ff ff ff       	call   f0103787 <env_init_percpu>
}
f01037ef:	5b                   	pop    %ebx
f01037f0:	5e                   	pop    %esi
f01037f1:	5d                   	pop    %ebp
f01037f2:	c3                   	ret    

f01037f3 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01037f3:	55                   	push   %ebp
f01037f4:	89 e5                	mov    %esp,%ebp
f01037f6:	53                   	push   %ebx
f01037f7:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01037fa:	8b 1d 4c 22 1e f0    	mov    0xf01e224c,%ebx
f0103800:	85 db                	test   %ebx,%ebx
f0103802:	0f 84 70 01 00 00    	je     f0103978 <env_alloc+0x185>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103808:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010380f:	e8 7e d8 ff ff       	call   f0101092 <page_alloc>
f0103814:	85 c0                	test   %eax,%eax
f0103816:	0f 84 63 01 00 00    	je     f010397f <env_alloc+0x18c>
f010381c:	89 c2                	mov    %eax,%edx
f010381e:	2b 15 90 2e 1e f0    	sub    0xf01e2e90,%edx
f0103824:	c1 fa 03             	sar    $0x3,%edx
f0103827:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010382a:	89 d1                	mov    %edx,%ecx
f010382c:	c1 e9 0c             	shr    $0xc,%ecx
f010382f:	3b 0d 88 2e 1e f0    	cmp    0xf01e2e88,%ecx
f0103835:	72 20                	jb     f0103857 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103837:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010383b:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0103842:	f0 
f0103843:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010384a:	00 
f010384b:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0103852:	e8 e9 c7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103857:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010385d:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB :  Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f0103860:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103865:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010386c:	00 
f010386d:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
f0103872:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103876:	8b 43 60             	mov    0x60(%ebx),%eax
f0103879:	89 04 24             	mov    %eax,(%esp)
f010387c:	e8 1b 28 00 00       	call   f010609c <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f0103881:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f0103888:	00 
f0103889:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103890:	00 
f0103891:	8b 43 60             	mov    0x60(%ebx),%eax
f0103894:	89 04 24             	mov    %eax,(%esp)
f0103897:	e8 4b 27 00 00       	call   f0105fe7 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010389c:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010389f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038a4:	77 20                	ja     f01038c6 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038aa:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f01038b1:	f0 
f01038b2:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01038b9:	00 
f01038ba:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f01038c1:	e8 7a c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01038c6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01038cc:	83 ca 05             	or     $0x5,%edx
f01038cf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01038d5:	8b 43 48             	mov    0x48(%ebx),%eax
f01038d8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01038dd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01038e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01038e7:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01038ea:	89 da                	mov    %ebx,%edx
f01038ec:	2b 15 48 22 1e f0    	sub    0xf01e2248,%edx
f01038f2:	c1 fa 02             	sar    $0x2,%edx
f01038f5:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01038fb:	09 d0                	or     %edx,%eax
f01038fd:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103900:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103903:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103906:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010390d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103914:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010391b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103922:	00 
f0103923:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010392a:	00 
f010392b:	89 1c 24             	mov    %ebx,(%esp)
f010392e:	e8 b4 26 00 00       	call   f0105fe7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103933:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103939:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010393f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103945:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010394c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB : Your code here.
	// time clock
	e->env_tf.tf_eflags |= FL_IF;
f0103952:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103959:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103960:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103964:	8b 43 44             	mov    0x44(%ebx),%eax
f0103967:	a3 4c 22 1e f0       	mov    %eax,0xf01e224c
	*newenv_store = e;
f010396c:	8b 45 08             	mov    0x8(%ebp),%eax
f010396f:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103971:	b8 00 00 00 00       	mov    $0x0,%eax
f0103976:	eb 0c                	jmp    f0103984 <env_alloc+0x191>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103978:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010397d:	eb 05                	jmp    f0103984 <env_alloc+0x191>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010397f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103984:	83 c4 14             	add    $0x14,%esp
f0103987:	5b                   	pop    %ebx
f0103988:	5d                   	pop    %ebp
f0103989:	c3                   	ret    

f010398a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	57                   	push   %edi
f010398e:	56                   	push   %esi
f010398f:	53                   	push   %ebx
f0103990:	83 ec 3c             	sub    $0x3c,%esp
	// LAB : Your code here.
	struct Env* env=0;
f0103993:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f010399a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039a1:	00 
f01039a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01039a5:	89 04 24             	mov    %eax,(%esp)
f01039a8:	e8 46 fe ff ff       	call   f01037f3 <env_alloc>
	if(r < 0)
f01039ad:	85 c0                	test   %eax,%eax
f01039af:	79 1c                	jns    f01039cd <env_create+0x43>
		panic("env_create fault\n");
f01039b1:	c7 44 24 08 04 7f 10 	movl   $0xf0107f04,0x8(%esp)
f01039b8:	f0 
f01039b9:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f01039c0:	00 
f01039c1:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f01039c8:	e8 73 c6 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f01039cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB :  fang Your code here.
struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f01039d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d6:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01039dc:	74 1c                	je     f01039fa <env_create+0x70>
			panic("e_magic is not right\n");
f01039de:	c7 44 24 08 16 7f 10 	movl   $0xf0107f16,0x8(%esp)
f01039e5:	f0 
f01039e6:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f01039ed:	00 
f01039ee:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f01039f5:	e8 46 c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f01039fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039fd:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a00:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a05:	77 20                	ja     f0103a27 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a07:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a0b:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0103a12:	f0 
f0103a13:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0103a1a:	00 
f0103a1b:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103a22:	e8 19 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a27:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a2c:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f0103a2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a32:	89 c3                	mov    %eax,%ebx
f0103a34:	03 58 1c             	add    0x1c(%eax),%ebx
f0103a37:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f0103a3b:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f0103a3e:	be 01 00 00 00       	mov    $0x1,%esi
f0103a43:	eb 54                	jmp    f0103a99 <env_create+0x10f>
		int i=0;
		for(; i<num; i++){
			ph++;
f0103a45:	83 c3 20             	add    $0x20,%ebx
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f0103a48:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a4b:	75 49                	jne    f0103a96 <env_create+0x10c>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f0103a4d:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a50:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a56:	e8 e4 fb ff ff       	call   f010363f <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f0103a5b:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a65:	03 43 04             	add    0x4(%ebx),%eax
f0103a68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a6c:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a6f:	89 04 24             	mov    %eax,(%esp)
f0103a72:	e8 bd 25 00 00       	call   f0106034 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103a77:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a7a:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a7d:	29 c2                	sub    %eax,%edx
f0103a7f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a83:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a8a:	00 
f0103a8b:	03 43 08             	add    0x8(%ebx),%eax
f0103a8e:	89 04 24             	mov    %eax,(%esp)
f0103a91:	e8 51 25 00 00       	call   f0105fe7 <memset>
f0103a96:	83 c6 01             	add    $0x1,%esi

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a99:	39 fe                	cmp    %edi,%esi
f0103a9b:	75 a8                	jne    f0103a45 <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aa0:	8b 40 18             	mov    0x18(%eax),%eax
f0103aa3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103aa6:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB :  fang Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103aa9:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103aae:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103ab3:	89 f8                	mov    %edi,%eax
f0103ab5:	e8 85 fb ff ff       	call   f010363f <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103aba:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103abf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ac4:	77 20                	ja     f0103ae6 <env_create+0x15c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aca:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0103ad1:	f0 
f0103ad2:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0103ad9:	00 
f0103ada:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103ae1:	e8 5a c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ae6:	05 00 00 00 10       	add    $0x10000000,%eax
f0103aeb:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103af1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103af4:	89 50 50             	mov    %edx,0x50(%eax)
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
}
f0103af7:	83 c4 3c             	add    $0x3c,%esp
f0103afa:	5b                   	pop    %ebx
f0103afb:	5e                   	pop    %esi
f0103afc:	5f                   	pop    %edi
f0103afd:	5d                   	pop    %ebp
f0103afe:	c3                   	ret    

f0103aff <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103aff:	55                   	push   %ebp
f0103b00:	89 e5                	mov    %esp,%ebp
f0103b02:	57                   	push   %edi
f0103b03:	56                   	push   %esi
f0103b04:	53                   	push   %ebx
f0103b05:	83 ec 2c             	sub    $0x2c,%esp
f0103b08:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103b0b:	e8 29 2b 00 00       	call   f0106639 <cpunum>
f0103b10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b13:	39 b8 28 30 1e f0    	cmp    %edi,-0xfe1cfd8(%eax)
f0103b19:	74 09                	je     f0103b24 <env_free+0x25>
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103b1b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103b22:	eb 36                	jmp    f0103b5a <env_free+0x5b>

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));
f0103b24:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b2e:	77 20                	ja     f0103b50 <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b34:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0103b3b:	f0 
f0103b3c:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103b43:	00 
f0103b44:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103b4b:	e8 f0 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b50:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b55:	0f 22 d8             	mov    %eax,%cr3
f0103b58:	eb c1                	jmp    f0103b1b <env_free+0x1c>
f0103b5a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b5d:	89 c8                	mov    %ecx,%eax
f0103b5f:	c1 e0 02             	shl    $0x2,%eax
f0103b62:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b65:	8b 47 60             	mov    0x60(%edi),%eax
f0103b68:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b6b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b71:	0f 84 b7 00 00 00    	je     f0103c2e <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b77:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b7d:	89 f0                	mov    %esi,%eax
f0103b7f:	c1 e8 0c             	shr    $0xc,%eax
f0103b82:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b85:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f0103b8b:	72 20                	jb     f0103bad <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b8d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b91:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0103b98:	f0 
f0103b99:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f0103ba0:	00 
f0103ba1:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103ba8:	e8 93 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bb0:	c1 e0 16             	shl    $0x16,%eax
f0103bb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103bbb:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103bc2:	01 
f0103bc3:	74 17                	je     f0103bdc <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bc5:	89 d8                	mov    %ebx,%eax
f0103bc7:	c1 e0 0c             	shl    $0xc,%eax
f0103bca:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd1:	8b 47 60             	mov    0x60(%edi),%eax
f0103bd4:	89 04 24             	mov    %eax,(%esp)
f0103bd7:	e8 4f d7 ff ff       	call   f010132b <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bdc:	83 c3 01             	add    $0x1,%ebx
f0103bdf:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103be5:	75 d4                	jne    f0103bbb <env_free+0xbc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103be7:	8b 47 60             	mov    0x60(%edi),%eax
f0103bea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bed:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bf7:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f0103bfd:	72 1c                	jb     f0103c1b <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103bff:	c7 44 24 08 34 73 10 	movl   $0xf0107334,0x8(%esp)
f0103c06:	f0 
f0103c07:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c0e:	00 
f0103c0f:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0103c16:	e8 25 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c1b:	a1 90 2e 1e f0       	mov    0xf01e2e90,%eax
f0103c20:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c23:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103c26:	89 04 24             	mov    %eax,(%esp)
f0103c29:	e8 2f d5 ff ff       	call   f010115d <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c2e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103c32:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c39:	0f 85 1b ff ff ff    	jne    f0103b5a <env_free+0x5b>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c3f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c42:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c47:	77 20                	ja     f0103c69 <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c4d:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0103c54:	f0 
f0103c55:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f0103c5c:	00 
f0103c5d:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103c64:	e8 d7 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c69:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c70:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c75:	c1 e8 0c             	shr    $0xc,%eax
f0103c78:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f0103c7e:	72 1c                	jb     f0103c9c <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103c80:	c7 44 24 08 34 73 10 	movl   $0xf0107334,0x8(%esp)
f0103c87:	f0 
f0103c88:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c8f:	00 
f0103c90:	c7 04 24 8d 7b 10 f0 	movl   $0xf0107b8d,(%esp)
f0103c97:	e8 a4 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c9c:	8b 15 90 2e 1e f0    	mov    0xf01e2e90,%edx
f0103ca2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103ca5:	89 04 24             	mov    %eax,(%esp)
f0103ca8:	e8 b0 d4 ff ff       	call   f010115d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103cad:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103cb4:	a1 4c 22 1e f0       	mov    0xf01e224c,%eax
f0103cb9:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103cbc:	89 3d 4c 22 1e f0    	mov    %edi,0xf01e224c
}
f0103cc2:	83 c4 2c             	add    $0x2c,%esp
f0103cc5:	5b                   	pop    %ebx
f0103cc6:	5e                   	pop    %esi
f0103cc7:	5f                   	pop    %edi
f0103cc8:	5d                   	pop    %ebp
f0103cc9:	c3                   	ret    

f0103cca <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103cca:	55                   	push   %ebp
f0103ccb:	89 e5                	mov    %esp,%ebp
f0103ccd:	53                   	push   %ebx
f0103cce:	83 ec 14             	sub    $0x14,%esp
f0103cd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cd4:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103cd8:	75 19                	jne    f0103cf3 <env_destroy+0x29>
f0103cda:	e8 5a 29 00 00       	call   f0106639 <cpunum>
f0103cdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce2:	39 98 28 30 1e f0    	cmp    %ebx,-0xfe1cfd8(%eax)
f0103ce8:	74 09                	je     f0103cf3 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103cea:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cf1:	eb 2f                	jmp    f0103d22 <env_destroy+0x58>
	}

	env_free(e);
f0103cf3:	89 1c 24             	mov    %ebx,(%esp)
f0103cf6:	e8 04 fe ff ff       	call   f0103aff <env_free>

	if (curenv == e) {
f0103cfb:	e8 39 29 00 00       	call   f0106639 <cpunum>
f0103d00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d03:	39 98 28 30 1e f0    	cmp    %ebx,-0xfe1cfd8(%eax)
f0103d09:	75 17                	jne    f0103d22 <env_destroy+0x58>
		curenv = NULL;
f0103d0b:	e8 29 29 00 00       	call   f0106639 <cpunum>
f0103d10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d13:	c7 80 28 30 1e f0 00 	movl   $0x0,-0xfe1cfd8(%eax)
f0103d1a:	00 00 00 
		sched_yield();
f0103d1d:	e8 05 10 00 00       	call   f0104d27 <sched_yield>
	}
}
f0103d22:	83 c4 14             	add    $0x14,%esp
f0103d25:	5b                   	pop    %ebx
f0103d26:	5d                   	pop    %ebp
f0103d27:	c3                   	ret    

f0103d28 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d28:	55                   	push   %ebp
f0103d29:	89 e5                	mov    %esp,%ebp
f0103d2b:	53                   	push   %ebx
f0103d2c:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d2f:	e8 05 29 00 00       	call   f0106639 <cpunum>
f0103d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d37:	8b 98 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%ebx
f0103d3d:	e8 f7 28 00 00       	call   f0106639 <cpunum>
f0103d42:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d45:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d48:	61                   	popa   
f0103d49:	07                   	pop    %es
f0103d4a:	1f                   	pop    %ds
f0103d4b:	83 c4 08             	add    $0x8,%esp
f0103d4e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d4f:	c7 44 24 08 2c 7f 10 	movl   $0xf0107f2c,0x8(%esp)
f0103d56:	f0 
f0103d57:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f0103d5e:	00 
f0103d5f:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103d66:	e8 d5 c2 ff ff       	call   f0100040 <_panic>

f0103d6b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d6b:	55                   	push   %ebp
f0103d6c:	89 e5                	mov    %esp,%ebp
f0103d6e:	53                   	push   %ebx
f0103d6f:	83 ec 14             	sub    $0x14,%esp
f0103d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB : Your code here.
	if(curenv == 0)
f0103d75:	e8 bf 28 00 00       	call   f0106639 <cpunum>
f0103d7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7d:	83 b8 28 30 1e f0 00 	cmpl   $0x0,-0xfe1cfd8(%eax)
f0103d84:	75 10                	jne    f0103d96 <env_run+0x2b>
		curenv = e;
f0103d86:	e8 ae 28 00 00       	call   f0106639 <cpunum>
f0103d8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d8e:	89 98 28 30 1e f0    	mov    %ebx,-0xfe1cfd8(%eax)
f0103d94:	eb 29                	jmp    f0103dbf <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d96:	e8 9e 28 00 00       	call   f0106639 <cpunum>
f0103d9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d9e:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103da4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103da8:	75 15                	jne    f0103dbf <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103daa:	e8 8a 28 00 00       	call   f0106639 <cpunum>
f0103daf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db2:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103db8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103dbf:	e8 75 28 00 00       	call   f0106639 <cpunum>
f0103dc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc7:	89 98 28 30 1e f0    	mov    %ebx,-0xfe1cfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103dcd:	e8 67 28 00 00       	call   f0106639 <cpunum>
f0103dd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd5:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103ddb:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103de2:	e8 52 28 00 00       	call   f0106639 <cpunum>
f0103de7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dea:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103df0:	83 40 58 01          	addl   $0x1,0x58(%eax)
//	cprintf("the eip is %x\n", curenv->env_id);
	lcr3( PADDR(curenv->env_pgdir) );
f0103df4:	e8 40 28 00 00       	call   f0106639 <cpunum>
f0103df9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dfc:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103e02:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e05:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e0a:	77 20                	ja     f0103e2c <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e10:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0103e17:	f0 
f0103e18:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
f0103e1f:	00 
f0103e20:	c7 04 24 e7 7e 10 f0 	movl   $0xf0107ee7,(%esp)
f0103e27:	e8 14 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e2c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e31:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e34:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103e3b:	e8 23 2b 00 00       	call   f0106963 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e40:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103e42:	e8 f2 27 00 00       	call   f0106639 <cpunum>
f0103e47:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e4a:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0103e50:	89 04 24             	mov    %eax,(%esp)
f0103e53:	e8 d0 fe ff ff       	call   f0103d28 <env_pop_tf>

f0103e58 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e58:	55                   	push   %ebp
f0103e59:	89 e5                	mov    %esp,%ebp
f0103e5b:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e5f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e64:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e65:	b2 71                	mov    $0x71,%dl
f0103e67:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e68:	0f b6 c0             	movzbl %al,%eax
}
f0103e6b:	5d                   	pop    %ebp
f0103e6c:	c3                   	ret    

f0103e6d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e6d:	55                   	push   %ebp
f0103e6e:	89 e5                	mov    %esp,%ebp
f0103e70:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e74:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e79:	ee                   	out    %al,(%dx)
f0103e7a:	b2 71                	mov    $0x71,%dl
f0103e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e7f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e80:	5d                   	pop    %ebp
f0103e81:	c3                   	ret    

f0103e82 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e82:	55                   	push   %ebp
f0103e83:	89 e5                	mov    %esp,%ebp
f0103e85:	56                   	push   %esi
f0103e86:	53                   	push   %ebx
f0103e87:	83 ec 10             	sub    $0x10,%esp
f0103e8a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e8d:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e93:	80 3d 50 22 1e f0 00 	cmpb   $0x0,0xf01e2250
f0103e9a:	74 4e                	je     f0103eea <irq_setmask_8259A+0x68>
f0103e9c:	89 c6                	mov    %eax,%esi
f0103e9e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ea3:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103ea4:	66 c1 e8 08          	shr    $0x8,%ax
f0103ea8:	b2 a1                	mov    $0xa1,%dl
f0103eaa:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103eab:	c7 04 24 38 7f 10 f0 	movl   $0xf0107f38,(%esp)
f0103eb2:	e8 0a 01 00 00       	call   f0103fc1 <cprintf>
	for (i = 0; i < 16; i++)
f0103eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ebc:	0f b7 f6             	movzwl %si,%esi
f0103ebf:	f7 d6                	not    %esi
f0103ec1:	0f a3 de             	bt     %ebx,%esi
f0103ec4:	73 10                	jae    f0103ed6 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103ec6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eca:	c7 04 24 eb 83 10 f0 	movl   $0xf01083eb,(%esp)
f0103ed1:	e8 eb 00 00 00       	call   f0103fc1 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ed6:	83 c3 01             	add    $0x1,%ebx
f0103ed9:	83 fb 10             	cmp    $0x10,%ebx
f0103edc:	75 e3                	jne    f0103ec1 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103ede:	c7 04 24 84 7e 10 f0 	movl   $0xf0107e84,(%esp)
f0103ee5:	e8 d7 00 00 00       	call   f0103fc1 <cprintf>
}
f0103eea:	83 c4 10             	add    $0x10,%esp
f0103eed:	5b                   	pop    %ebx
f0103eee:	5e                   	pop    %esi
f0103eef:	5d                   	pop    %ebp
f0103ef0:	c3                   	ret    

f0103ef1 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103ef1:	c6 05 50 22 1e f0 01 	movb   $0x1,0xf01e2250
f0103ef8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f02:	ee                   	out    %al,(%dx)
f0103f03:	b2 a1                	mov    $0xa1,%dl
f0103f05:	ee                   	out    %al,(%dx)
f0103f06:	b2 20                	mov    $0x20,%dl
f0103f08:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b2 21                	mov    $0x21,%dl
f0103f10:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f15:	ee                   	out    %al,(%dx)
f0103f16:	b8 04 00 00 00       	mov    $0x4,%eax
f0103f1b:	ee                   	out    %al,(%dx)
f0103f1c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103f21:	ee                   	out    %al,(%dx)
f0103f22:	b2 a0                	mov    $0xa0,%dl
f0103f24:	b8 11 00 00 00       	mov    $0x11,%eax
f0103f29:	ee                   	out    %al,(%dx)
f0103f2a:	b2 a1                	mov    $0xa1,%dl
f0103f2c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103f31:	ee                   	out    %al,(%dx)
f0103f32:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f37:	ee                   	out    %al,(%dx)
f0103f38:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f3d:	ee                   	out    %al,(%dx)
f0103f3e:	b2 20                	mov    $0x20,%dl
f0103f40:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f45:	ee                   	out    %al,(%dx)
f0103f46:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f4b:	ee                   	out    %al,(%dx)
f0103f4c:	b2 a0                	mov    $0xa0,%dl
f0103f4e:	b8 68 00 00 00       	mov    $0x68,%eax
f0103f53:	ee                   	out    %al,(%dx)
f0103f54:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f59:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f5a:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f61:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f65:	74 12                	je     f0103f79 <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f67:	55                   	push   %ebp
f0103f68:	89 e5                	mov    %esp,%ebp
f0103f6a:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103f6d:	0f b7 c0             	movzwl %ax,%eax
f0103f70:	89 04 24             	mov    %eax,(%esp)
f0103f73:	e8 0a ff ff ff       	call   f0103e82 <irq_setmask_8259A>
}
f0103f78:	c9                   	leave  
f0103f79:	f3 c3                	repz ret 

f0103f7b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f7b:	55                   	push   %ebp
f0103f7c:	89 e5                	mov    %esp,%ebp
f0103f7e:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f81:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f84:	89 04 24             	mov    %eax,(%esp)
f0103f87:	e8 0b c8 ff ff       	call   f0100797 <cputchar>
	*cnt++;
}
f0103f8c:	c9                   	leave  
f0103f8d:	c3                   	ret    

f0103f8e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f8e:	55                   	push   %ebp
f0103f8f:	89 e5                	mov    %esp,%ebp
f0103f91:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103fac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fb0:	c7 04 24 7b 3f 10 f0 	movl   $0xf0103f7b,(%esp)
f0103fb7:	e8 d8 18 00 00       	call   f0105894 <vprintfmt>
	return cnt;
}
f0103fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fbf:	c9                   	leave  
f0103fc0:	c3                   	ret    

f0103fc1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103fc1:	55                   	push   %ebp
f0103fc2:	89 e5                	mov    %esp,%ebp
f0103fc4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103fc7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103fca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fce:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd1:	89 04 24             	mov    %eax,(%esp)
f0103fd4:	e8 b5 ff ff ff       	call   f0103f8e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103fd9:	c9                   	leave  
f0103fda:	c3                   	ret    
f0103fdb:	66 90                	xchg   %ax,%ax
f0103fdd:	66 90                	xchg   %ax,%ax
f0103fdf:	90                   	nop

f0103fe0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fe0:	55                   	push   %ebp
f0103fe1:	89 e5                	mov    %esp,%ebp
f0103fe3:	57                   	push   %edi
f0103fe4:	56                   	push   %esi
f0103fe5:	53                   	push   %ebx
f0103fe6:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB : Your code here:
int cpu_id = thiscpu->cpu_id;
f0103fe9:	e8 4b 26 00 00       	call   f0106639 <cpunum>
f0103fee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff1:	0f b6 98 20 30 1e f0 	movzbl -0xfe1cfe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103ff8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ffc:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f0104003:	e8 b9 ff ff ff       	call   f0103fc1 <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0104008:	e8 2c 26 00 00       	call   f0106639 <cpunum>
f010400d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104010:	89 da                	mov    %ebx,%edx
f0104012:	f7 da                	neg    %edx
f0104014:	c1 e2 10             	shl    $0x10,%edx
f0104017:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010401d:	89 90 30 30 1e f0    	mov    %edx,-0xfe1cfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104023:	e8 11 26 00 00       	call   f0106639 <cpunum>
f0104028:	6b c0 74             	imul   $0x74,%eax,%eax
f010402b:	66 c7 80 34 30 1e f0 	movw   $0x10,-0xfe1cfcc(%eax)
f0104032:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0104034:	83 c3 05             	add    $0x5,%ebx
f0104037:	e8 fd 25 00 00       	call   f0106639 <cpunum>
f010403c:	89 c7                	mov    %eax,%edi
f010403e:	e8 f6 25 00 00       	call   f0106639 <cpunum>
f0104043:	89 c6                	mov    %eax,%esi
f0104045:	e8 ef 25 00 00       	call   f0106639 <cpunum>
f010404a:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0104051:	f0 67 00 
f0104054:	6b ff 74             	imul   $0x74,%edi,%edi
f0104057:	81 c7 2c 30 1e f0    	add    $0xf01e302c,%edi
f010405d:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0104064:	f0 
f0104065:	6b d6 74             	imul   $0x74,%esi,%edx
f0104068:	81 c2 2c 30 1e f0    	add    $0xf01e302c,%edx
f010406e:	c1 ea 10             	shr    $0x10,%edx
f0104071:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104078:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010407f:	40 
f0104080:	6b c0 74             	imul   $0x74,%eax,%eax
f0104083:	05 2c 30 1e f0       	add    $0xf01e302c,%eax
f0104088:	c1 e8 18             	shr    $0x18,%eax
f010408b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104092:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0104099:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010409a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010409d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01040a0:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f01040a5:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f01040a8:	83 c4 1c             	add    $0x1c,%esp
f01040ab:	5b                   	pop    %ebx
f01040ac:	5e                   	pop    %esi
f01040ad:	5f                   	pop    %edi
f01040ae:	5d                   	pop    %ebp
f01040af:	c3                   	ret    

f01040b0 <trap_init>:
}


void
trap_init(void)
{
f01040b0:	55                   	push   %ebp
f01040b1:	89 e5                	mov    %esp,%ebp
f01040b3:	83 ec 08             	sub    $0x8,%esp
    void handlerIRQ7();
    void handlerIRQ14();
    void handlerIRQ19();
 

    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f01040b6:	b8 40 4b 10 f0       	mov    $0xf0104b40,%eax
f01040bb:	66 a3 60 22 1e f0    	mov    %ax,0xf01e2260
f01040c1:	66 c7 05 62 22 1e f0 	movw   $0x8,0xf01e2262
f01040c8:	08 00 
f01040ca:	c6 05 64 22 1e f0 00 	movb   $0x0,0xf01e2264
f01040d1:	c6 05 65 22 1e f0 8e 	movb   $0x8e,0xf01e2265
f01040d8:	c1 e8 10             	shr    $0x10,%eax
f01040db:	66 a3 66 22 1e f0    	mov    %ax,0xf01e2266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f01040e1:	b8 4a 4b 10 f0       	mov    $0xf0104b4a,%eax
f01040e6:	66 a3 68 22 1e f0    	mov    %ax,0xf01e2268
f01040ec:	66 c7 05 6a 22 1e f0 	movw   $0x8,0xf01e226a
f01040f3:	08 00 
f01040f5:	c6 05 6c 22 1e f0 00 	movb   $0x0,0xf01e226c
f01040fc:	c6 05 6d 22 1e f0 8e 	movb   $0x8e,0xf01e226d
f0104103:	c1 e8 10             	shr    $0x10,%eax
f0104106:	66 a3 6e 22 1e f0    	mov    %ax,0xf01e226e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f010410c:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f0104111:	66 a3 70 22 1e f0    	mov    %ax,0xf01e2270
f0104117:	66 c7 05 72 22 1e f0 	movw   $0x8,0xf01e2272
f010411e:	08 00 
f0104120:	c6 05 74 22 1e f0 00 	movb   $0x0,0xf01e2274
f0104127:	c6 05 75 22 1e f0 8e 	movb   $0x8e,0xf01e2275
f010412e:	c1 e8 10             	shr    $0x10,%eax
f0104131:	66 a3 76 22 1e f0    	mov    %ax,0xf01e2276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f0104137:	b8 5e 4b 10 f0       	mov    $0xf0104b5e,%eax
f010413c:	66 a3 78 22 1e f0    	mov    %ax,0xf01e2278
f0104142:	66 c7 05 7a 22 1e f0 	movw   $0x8,0xf01e227a
f0104149:	08 00 
f010414b:	c6 05 7c 22 1e f0 00 	movb   $0x0,0xf01e227c
f0104152:	c6 05 7d 22 1e f0 ee 	movb   $0xee,0xf01e227d
f0104159:	c1 e8 10             	shr    $0x10,%eax
f010415c:	66 a3 7e 22 1e f0    	mov    %ax,0xf01e227e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104162:	b8 68 4b 10 f0       	mov    $0xf0104b68,%eax
f0104167:	66 a3 80 22 1e f0    	mov    %ax,0xf01e2280
f010416d:	66 c7 05 82 22 1e f0 	movw   $0x8,0xf01e2282
f0104174:	08 00 
f0104176:	c6 05 84 22 1e f0 00 	movb   $0x0,0xf01e2284
f010417d:	c6 05 85 22 1e f0 8e 	movb   $0x8e,0xf01e2285
f0104184:	c1 e8 10             	shr    $0x10,%eax
f0104187:	66 a3 86 22 1e f0    	mov    %ax,0xf01e2286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010418d:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f0104192:	66 a3 88 22 1e f0    	mov    %ax,0xf01e2288
f0104198:	66 c7 05 8a 22 1e f0 	movw   $0x8,0xf01e228a
f010419f:	08 00 
f01041a1:	c6 05 8c 22 1e f0 00 	movb   $0x0,0xf01e228c
f01041a8:	c6 05 8d 22 1e f0 8e 	movb   $0x8e,0xf01e228d
f01041af:	c1 e8 10             	shr    $0x10,%eax
f01041b2:	66 a3 8e 22 1e f0    	mov    %ax,0xf01e228e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f01041b8:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f01041bd:	66 a3 90 22 1e f0    	mov    %ax,0xf01e2290
f01041c3:	66 c7 05 92 22 1e f0 	movw   $0x8,0xf01e2292
f01041ca:	08 00 
f01041cc:	c6 05 94 22 1e f0 00 	movb   $0x0,0xf01e2294
f01041d3:	c6 05 95 22 1e f0 8e 	movb   $0x8e,0xf01e2295
f01041da:	c1 e8 10             	shr    $0x10,%eax
f01041dd:	66 a3 96 22 1e f0    	mov    %ax,0xf01e2296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f01041e3:	b8 86 4b 10 f0       	mov    $0xf0104b86,%eax
f01041e8:	66 a3 98 22 1e f0    	mov    %ax,0xf01e2298
f01041ee:	66 c7 05 9a 22 1e f0 	movw   $0x8,0xf01e229a
f01041f5:	08 00 
f01041f7:	c6 05 9c 22 1e f0 00 	movb   $0x0,0xf01e229c
f01041fe:	c6 05 9d 22 1e f0 8e 	movb   $0x8e,0xf01e229d
f0104205:	c1 e8 10             	shr    $0x10,%eax
f0104208:	66 a3 9e 22 1e f0    	mov    %ax,0xf01e229e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f010420e:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f0104213:	66 a3 a0 22 1e f0    	mov    %ax,0xf01e22a0
f0104219:	66 c7 05 a2 22 1e f0 	movw   $0x8,0xf01e22a2
f0104220:	08 00 
f0104222:	c6 05 a4 22 1e f0 00 	movb   $0x0,0xf01e22a4
f0104229:	c6 05 a5 22 1e f0 8e 	movb   $0x8e,0xf01e22a5
f0104230:	c1 e8 10             	shr    $0x10,%eax
f0104233:	66 a3 a6 22 1e f0    	mov    %ax,0xf01e22a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f0104239:	b8 98 4b 10 f0       	mov    $0xf0104b98,%eax
f010423e:	66 a3 a8 22 1e f0    	mov    %ax,0xf01e22a8
f0104244:	66 c7 05 aa 22 1e f0 	movw   $0x8,0xf01e22aa
f010424b:	08 00 
f010424d:	c6 05 ac 22 1e f0 00 	movb   $0x0,0xf01e22ac
f0104254:	c6 05 ad 22 1e f0 8e 	movb   $0x8e,0xf01e22ad
f010425b:	c1 e8 10             	shr    $0x10,%eax
f010425e:	66 a3 ae 22 1e f0    	mov    %ax,0xf01e22ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104264:	b8 a2 4b 10 f0       	mov    $0xf0104ba2,%eax
f0104269:	66 a3 b0 22 1e f0    	mov    %ax,0xf01e22b0
f010426f:	66 c7 05 b2 22 1e f0 	movw   $0x8,0xf01e22b2
f0104276:	08 00 
f0104278:	c6 05 b4 22 1e f0 00 	movb   $0x0,0xf01e22b4
f010427f:	c6 05 b5 22 1e f0 8e 	movb   $0x8e,0xf01e22b5
f0104286:	c1 e8 10             	shr    $0x10,%eax
f0104289:	66 a3 b6 22 1e f0    	mov    %ax,0xf01e22b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010428f:	b8 aa 4b 10 f0       	mov    $0xf0104baa,%eax
f0104294:	66 a3 b8 22 1e f0    	mov    %ax,0xf01e22b8
f010429a:	66 c7 05 ba 22 1e f0 	movw   $0x8,0xf01e22ba
f01042a1:	08 00 
f01042a3:	c6 05 bc 22 1e f0 00 	movb   $0x0,0xf01e22bc
f01042aa:	c6 05 bd 22 1e f0 8e 	movb   $0x8e,0xf01e22bd
f01042b1:	c1 e8 10             	shr    $0x10,%eax
f01042b4:	66 a3 be 22 1e f0    	mov    %ax,0xf01e22be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f01042ba:	b8 b2 4b 10 f0       	mov    $0xf0104bb2,%eax
f01042bf:	66 a3 c0 22 1e f0    	mov    %ax,0xf01e22c0
f01042c5:	66 c7 05 c2 22 1e f0 	movw   $0x8,0xf01e22c2
f01042cc:	08 00 
f01042ce:	c6 05 c4 22 1e f0 00 	movb   $0x0,0xf01e22c4
f01042d5:	c6 05 c5 22 1e f0 8e 	movb   $0x8e,0xf01e22c5
f01042dc:	c1 e8 10             	shr    $0x10,%eax
f01042df:	66 a3 c6 22 1e f0    	mov    %ax,0xf01e22c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f01042e5:	b8 ba 4b 10 f0       	mov    $0xf0104bba,%eax
f01042ea:	66 a3 c8 22 1e f0    	mov    %ax,0xf01e22c8
f01042f0:	66 c7 05 ca 22 1e f0 	movw   $0x8,0xf01e22ca
f01042f7:	08 00 
f01042f9:	c6 05 cc 22 1e f0 00 	movb   $0x0,0xf01e22cc
f0104300:	c6 05 cd 22 1e f0 8e 	movb   $0x8e,0xf01e22cd
f0104307:	c1 e8 10             	shr    $0x10,%eax
f010430a:	66 a3 ce 22 1e f0    	mov    %ax,0xf01e22ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f0104310:	b8 c2 4b 10 f0       	mov    $0xf0104bc2,%eax
f0104315:	66 a3 d0 22 1e f0    	mov    %ax,0xf01e22d0
f010431b:	66 c7 05 d2 22 1e f0 	movw   $0x8,0xf01e22d2
f0104322:	08 00 
f0104324:	c6 05 d4 22 1e f0 00 	movb   $0x0,0xf01e22d4
f010432b:	c6 05 d5 22 1e f0 8e 	movb   $0x8e,0xf01e22d5
f0104332:	c1 e8 10             	shr    $0x10,%eax
f0104335:	66 a3 d6 22 1e f0    	mov    %ax,0xf01e22d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f010433b:	b8 ca 4b 10 f0       	mov    $0xf0104bca,%eax
f0104340:	66 a3 d8 22 1e f0    	mov    %ax,0xf01e22d8
f0104346:	66 c7 05 da 22 1e f0 	movw   $0x8,0xf01e22da
f010434d:	08 00 
f010434f:	c6 05 dc 22 1e f0 00 	movb   $0x0,0xf01e22dc
f0104356:	c6 05 dd 22 1e f0 8e 	movb   $0x8e,0xf01e22dd
f010435d:	c1 e8 10             	shr    $0x10,%eax
f0104360:	66 a3 de 22 1e f0    	mov    %ax,0xf01e22de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104366:	b8 d4 4b 10 f0       	mov    $0xf0104bd4,%eax
f010436b:	66 a3 e0 22 1e f0    	mov    %ax,0xf01e22e0
f0104371:	66 c7 05 e2 22 1e f0 	movw   $0x8,0xf01e22e2
f0104378:	08 00 
f010437a:	c6 05 e4 22 1e f0 00 	movb   $0x0,0xf01e22e4
f0104381:	c6 05 e5 22 1e f0 8e 	movb   $0x8e,0xf01e22e5
f0104388:	c1 e8 10             	shr    $0x10,%eax
f010438b:	66 a3 e6 22 1e f0    	mov    %ax,0xf01e22e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104391:	b8 de 4b 10 f0       	mov    $0xf0104bde,%eax
f0104396:	66 a3 e8 22 1e f0    	mov    %ax,0xf01e22e8
f010439c:	66 c7 05 ea 22 1e f0 	movw   $0x8,0xf01e22ea
f01043a3:	08 00 
f01043a5:	c6 05 ec 22 1e f0 00 	movb   $0x0,0xf01e22ec
f01043ac:	c6 05 ed 22 1e f0 8e 	movb   $0x8e,0xf01e22ed
f01043b3:	c1 e8 10             	shr    $0x10,%eax
f01043b6:	66 a3 ee 22 1e f0    	mov    %ax,0xf01e22ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f01043bc:	b8 e6 4b 10 f0       	mov    $0xf0104be6,%eax
f01043c1:	66 a3 f0 22 1e f0    	mov    %ax,0xf01e22f0
f01043c7:	66 c7 05 f2 22 1e f0 	movw   $0x8,0xf01e22f2
f01043ce:	08 00 
f01043d0:	c6 05 f4 22 1e f0 00 	movb   $0x0,0xf01e22f4
f01043d7:	c6 05 f5 22 1e f0 8e 	movb   $0x8e,0xf01e22f5
f01043de:	c1 e8 10             	shr    $0x10,%eax
f01043e1:	66 a3 f6 22 1e f0    	mov    %ax,0xf01e22f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f01043e7:	b8 f0 4b 10 f0       	mov    $0xf0104bf0,%eax
f01043ec:	66 a3 f8 22 1e f0    	mov    %ax,0xf01e22f8
f01043f2:	66 c7 05 fa 22 1e f0 	movw   $0x8,0xf01e22fa
f01043f9:	08 00 
f01043fb:	c6 05 fc 22 1e f0 00 	movb   $0x0,0xf01e22fc
f0104402:	c6 05 fd 22 1e f0 8e 	movb   $0x8e,0xf01e22fd
f0104409:	c1 e8 10             	shr    $0x10,%eax
f010440c:	66 a3 fe 22 1e f0    	mov    %ax,0xf01e22fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104412:	b8 fa 4b 10 f0       	mov    $0xf0104bfa,%eax
f0104417:	66 a3 e0 23 1e f0    	mov    %ax,0xf01e23e0
f010441d:	66 c7 05 e2 23 1e f0 	movw   $0x8,0xf01e23e2
f0104424:	08 00 
f0104426:	c6 05 e4 23 1e f0 00 	movb   $0x0,0xf01e23e4
f010442d:	c6 05 e5 23 1e f0 ee 	movb   $0xee,0xf01e23e5
f0104434:	c1 e8 10             	shr    $0x10,%eax
f0104437:	66 a3 e6 23 1e f0    	mov    %ax,0xf01e23e6

    //lab4
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 	0, GD_KT, handlerIRQ0, 0);
f010443d:	b8 04 4c 10 f0       	mov    $0xf0104c04,%eax
f0104442:	66 a3 60 23 1e f0    	mov    %ax,0xf01e2360
f0104448:	66 c7 05 62 23 1e f0 	movw   $0x8,0xf01e2362
f010444f:	08 00 
f0104451:	c6 05 64 23 1e f0 00 	movb   $0x0,0xf01e2364
f0104458:	c6 05 65 23 1e f0 8e 	movb   $0x8e,0xf01e2365
f010445f:	c1 e8 10             	shr    $0x10,%eax
f0104462:	66 a3 66 23 1e f0    	mov    %ax,0xf01e2366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 	0, GD_KT, handlerIRQ1, 0);
f0104468:	b8 0e 4c 10 f0       	mov    $0xf0104c0e,%eax
f010446d:	66 a3 68 23 1e f0    	mov    %ax,0xf01e2368
f0104473:	66 c7 05 6a 23 1e f0 	movw   $0x8,0xf01e236a
f010447a:	08 00 
f010447c:	c6 05 6c 23 1e f0 00 	movb   $0x0,0xf01e236c
f0104483:	c6 05 6d 23 1e f0 8e 	movb   $0x8e,0xf01e236d
f010448a:	c1 e8 10             	shr    $0x10,%eax
f010448d:	66 a3 6e 23 1e f0    	mov    %ax,0xf01e236e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, handlerIRQ4, 0);
f0104493:	b8 18 4c 10 f0       	mov    $0xf0104c18,%eax
f0104498:	66 a3 80 23 1e f0    	mov    %ax,0xf01e2380
f010449e:	66 c7 05 82 23 1e f0 	movw   $0x8,0xf01e2382
f01044a5:	08 00 
f01044a7:	c6 05 84 23 1e f0 00 	movb   $0x0,0xf01e2384
f01044ae:	c6 05 85 23 1e f0 8e 	movb   $0x8e,0xf01e2385
f01044b5:	c1 e8 10             	shr    $0x10,%eax
f01044b8:	66 a3 86 23 1e f0    	mov    %ax,0xf01e2386
    SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, handlerIRQ7, 0);
f01044be:	b8 22 4c 10 f0       	mov    $0xf0104c22,%eax
f01044c3:	66 a3 98 23 1e f0    	mov    %ax,0xf01e2398
f01044c9:	66 c7 05 9a 23 1e f0 	movw   $0x8,0xf01e239a
f01044d0:	08 00 
f01044d2:	c6 05 9c 23 1e f0 00 	movb   $0x0,0xf01e239c
f01044d9:	c6 05 9d 23 1e f0 8e 	movb   $0x8e,0xf01e239d
f01044e0:	c1 e8 10             	shr    $0x10,%eax
f01044e3:	66 a3 9e 23 1e f0    	mov    %ax,0xf01e239e
    SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 	0, GD_KT, handlerIRQ14, 0);
f01044e9:	b8 2c 4c 10 f0       	mov    $0xf0104c2c,%eax
f01044ee:	66 a3 d0 23 1e f0    	mov    %ax,0xf01e23d0
f01044f4:	66 c7 05 d2 23 1e f0 	movw   $0x8,0xf01e23d2
f01044fb:	08 00 
f01044fd:	c6 05 d4 23 1e f0 00 	movb   $0x0,0xf01e23d4
f0104504:	c6 05 d5 23 1e f0 8e 	movb   $0x8e,0xf01e23d5
f010450b:	c1 e8 10             	shr    $0x10,%eax
f010450e:	66 a3 d6 23 1e f0    	mov    %ax,0xf01e23d6
    SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 	0, GD_KT, handlerIRQ19, 0);
f0104514:	b8 36 4c 10 f0       	mov    $0xf0104c36,%eax
f0104519:	66 a3 f8 23 1e f0    	mov    %ax,0xf01e23f8
f010451f:	66 c7 05 fa 23 1e f0 	movw   $0x8,0xf01e23fa
f0104526:	08 00 
f0104528:	c6 05 fc 23 1e f0 00 	movb   $0x0,0xf01e23fc
f010452f:	c6 05 fd 23 1e f0 8e 	movb   $0x8e,0xf01e23fd
f0104536:	c1 e8 10             	shr    $0x10,%eax
f0104539:	66 a3 fe 23 1e f0    	mov    %ax,0xf01e23fe




	// Per-CPU setup 
	trap_init_percpu();
f010453f:	e8 9c fa ff ff       	call   f0103fe0 <trap_init_percpu>
}
f0104544:	c9                   	leave  
f0104545:	c3                   	ret    

f0104546 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104546:	55                   	push   %ebp
f0104547:	89 e5                	mov    %esp,%ebp
f0104549:	53                   	push   %ebx
f010454a:	83 ec 14             	sub    $0x14,%esp
f010454d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104550:	8b 03                	mov    (%ebx),%eax
f0104552:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104556:	c7 04 24 5a 7f 10 f0 	movl   $0xf0107f5a,(%esp)
f010455d:	e8 5f fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104562:	8b 43 04             	mov    0x4(%ebx),%eax
f0104565:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104569:	c7 04 24 69 7f 10 f0 	movl   $0xf0107f69,(%esp)
f0104570:	e8 4c fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104575:	8b 43 08             	mov    0x8(%ebx),%eax
f0104578:	89 44 24 04          	mov    %eax,0x4(%esp)
f010457c:	c7 04 24 78 7f 10 f0 	movl   $0xf0107f78,(%esp)
f0104583:	e8 39 fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104588:	8b 43 0c             	mov    0xc(%ebx),%eax
f010458b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458f:	c7 04 24 87 7f 10 f0 	movl   $0xf0107f87,(%esp)
f0104596:	e8 26 fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010459b:	8b 43 10             	mov    0x10(%ebx),%eax
f010459e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a2:	c7 04 24 96 7f 10 f0 	movl   $0xf0107f96,(%esp)
f01045a9:	e8 13 fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01045ae:	8b 43 14             	mov    0x14(%ebx),%eax
f01045b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b5:	c7 04 24 a5 7f 10 f0 	movl   $0xf0107fa5,(%esp)
f01045bc:	e8 00 fa ff ff       	call   f0103fc1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01045c1:	8b 43 18             	mov    0x18(%ebx),%eax
f01045c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c8:	c7 04 24 b4 7f 10 f0 	movl   $0xf0107fb4,(%esp)
f01045cf:	e8 ed f9 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01045d4:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01045d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045db:	c7 04 24 c3 7f 10 f0 	movl   $0xf0107fc3,(%esp)
f01045e2:	e8 da f9 ff ff       	call   f0103fc1 <cprintf>
}
f01045e7:	83 c4 14             	add    $0x14,%esp
f01045ea:	5b                   	pop    %ebx
f01045eb:	5d                   	pop    %ebp
f01045ec:	c3                   	ret    

f01045ed <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f01045ed:	55                   	push   %ebp
f01045ee:	89 e5                	mov    %esp,%ebp
f01045f0:	56                   	push   %esi
f01045f1:	53                   	push   %ebx
f01045f2:	83 ec 10             	sub    $0x10,%esp
f01045f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045f8:	e8 3c 20 00 00       	call   f0106639 <cpunum>
f01045fd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104601:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104605:	c7 04 24 27 80 10 f0 	movl   $0xf0108027,(%esp)
f010460c:	e8 b0 f9 ff ff       	call   f0103fc1 <cprintf>
	print_regs(&tf->tf_regs);
f0104611:	89 1c 24             	mov    %ebx,(%esp)
f0104614:	e8 2d ff ff ff       	call   f0104546 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104619:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010461d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104621:	c7 04 24 45 80 10 f0 	movl   $0xf0108045,(%esp)
f0104628:	e8 94 f9 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010462d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104631:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104635:	c7 04 24 58 80 10 f0 	movl   $0xf0108058,(%esp)
f010463c:	e8 80 f9 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104641:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104644:	83 f8 13             	cmp    $0x13,%eax
f0104647:	77 09                	ja     f0104652 <print_trapframe+0x65>
		return excnames[trapno];
f0104649:	8b 14 85 00 83 10 f0 	mov    -0xfef7d00(,%eax,4),%edx
f0104650:	eb 1f                	jmp    f0104671 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104652:	83 f8 30             	cmp    $0x30,%eax
f0104655:	74 15                	je     f010466c <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104657:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010465a:	83 fa 0f             	cmp    $0xf,%edx
f010465d:	ba de 7f 10 f0       	mov    $0xf0107fde,%edx
f0104662:	b9 f1 7f 10 f0       	mov    $0xf0107ff1,%ecx
f0104667:	0f 47 d1             	cmova  %ecx,%edx
f010466a:	eb 05                	jmp    f0104671 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010466c:	ba d2 7f 10 f0       	mov    $0xf0107fd2,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104671:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104675:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104679:	c7 04 24 6b 80 10 f0 	movl   $0xf010806b,(%esp)
f0104680:	e8 3c f9 ff ff       	call   f0103fc1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104685:	3b 1d 60 2a 1e f0    	cmp    0xf01e2a60,%ebx
f010468b:	75 19                	jne    f01046a6 <print_trapframe+0xb9>
f010468d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104691:	75 13                	jne    f01046a6 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104693:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104696:	89 44 24 04          	mov    %eax,0x4(%esp)
f010469a:	c7 04 24 7d 80 10 f0 	movl   $0xf010807d,(%esp)
f01046a1:	e8 1b f9 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01046a6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ad:	c7 04 24 8c 80 10 f0 	movl   $0xf010808c,(%esp)
f01046b4:	e8 08 f9 ff ff       	call   f0103fc1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01046b9:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01046bd:	75 51                	jne    f0104710 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01046bf:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01046c2:	89 c2                	mov    %eax,%edx
f01046c4:	83 e2 01             	and    $0x1,%edx
f01046c7:	ba 00 80 10 f0       	mov    $0xf0108000,%edx
f01046cc:	b9 0b 80 10 f0       	mov    $0xf010800b,%ecx
f01046d1:	0f 45 ca             	cmovne %edx,%ecx
f01046d4:	89 c2                	mov    %eax,%edx
f01046d6:	83 e2 02             	and    $0x2,%edx
f01046d9:	ba 17 80 10 f0       	mov    $0xf0108017,%edx
f01046de:	be 1d 80 10 f0       	mov    $0xf010801d,%esi
f01046e3:	0f 44 d6             	cmove  %esi,%edx
f01046e6:	83 e0 04             	and    $0x4,%eax
f01046e9:	b8 22 80 10 f0       	mov    $0xf0108022,%eax
f01046ee:	be 57 81 10 f0       	mov    $0xf0108157,%esi
f01046f3:	0f 44 c6             	cmove  %esi,%eax
f01046f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046fa:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104702:	c7 04 24 9a 80 10 f0 	movl   $0xf010809a,(%esp)
f0104709:	e8 b3 f8 ff ff       	call   f0103fc1 <cprintf>
f010470e:	eb 0c                	jmp    f010471c <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104710:	c7 04 24 84 7e 10 f0 	movl   $0xf0107e84,(%esp)
f0104717:	e8 a5 f8 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010471c:	8b 43 30             	mov    0x30(%ebx),%eax
f010471f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104723:	c7 04 24 a9 80 10 f0 	movl   $0xf01080a9,(%esp)
f010472a:	e8 92 f8 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010472f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104733:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104737:	c7 04 24 b8 80 10 f0 	movl   $0xf01080b8,(%esp)
f010473e:	e8 7e f8 ff ff       	call   f0103fc1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104743:	8b 43 38             	mov    0x38(%ebx),%eax
f0104746:	89 44 24 04          	mov    %eax,0x4(%esp)
f010474a:	c7 04 24 cb 80 10 f0 	movl   $0xf01080cb,(%esp)
f0104751:	e8 6b f8 ff ff       	call   f0103fc1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104756:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010475a:	74 27                	je     f0104783 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010475c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010475f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104763:	c7 04 24 da 80 10 f0 	movl   $0xf01080da,(%esp)
f010476a:	e8 52 f8 ff ff       	call   f0103fc1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010476f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104773:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104777:	c7 04 24 e9 80 10 f0 	movl   $0xf01080e9,(%esp)
f010477e:	e8 3e f8 ff ff       	call   f0103fc1 <cprintf>
	}
}
f0104783:	83 c4 10             	add    $0x10,%esp
f0104786:	5b                   	pop    %ebx
f0104787:	5e                   	pop    %esi
f0104788:	5d                   	pop    %ebp
f0104789:	c3                   	ret    

f010478a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010478a:	55                   	push   %ebp
f010478b:	89 e5                	mov    %esp,%ebp
f010478d:	57                   	push   %edi
f010478e:	56                   	push   %esi
f010478f:	53                   	push   %ebx
f0104790:	83 ec 5c             	sub    $0x5c,%esp
f0104793:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104796:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	 if(tf->tf_cs == GD_KT)
f0104799:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010479e:	75 1c                	jne    f01047bc <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f01047a0:	c7 44 24 08 a4 82 10 	movl   $0xf01082a4,0x8(%esp)
f01047a7:	f0 
f01047a8:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f01047af:	00 
f01047b0:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f01047b7:	e8 84 b8 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
f01047bc:	e8 78 1e 00 00       	call   f0106639 <cpunum>
f01047c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c4:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01047ca:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01047ce:	75 4a                	jne    f010481a <page_fault_handler+0x90>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01047d0:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f01047d3:	e8 61 1e 00 00       	call   f0106639 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01047d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01047dc:	89 7c 24 08          	mov    %edi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f01047e0:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01047e3:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01047e9:	8b 40 48             	mov    0x48(%eax),%eax
f01047ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f0:	c7 04 24 c8 82 10 f0 	movl   $0xf01082c8,(%esp)
f01047f7:	e8 c5 f7 ff ff       	call   f0103fc1 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f01047fc:	89 1c 24             	mov    %ebx,(%esp)
f01047ff:	e8 e9 fd ff ff       	call   f01045ed <print_trapframe>
		env_destroy(curenv);
f0104804:	e8 30 1e 00 00       	call   f0106639 <cpunum>
f0104809:	6b c0 74             	imul   $0x74,%eax,%eax
f010480c:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104812:	89 04 24             	mov    %eax,(%esp)
f0104815:	e8 b0 f4 ff ff       	call   f0103cca <env_destroy>

	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f010481a:	8b 73 3c             	mov    0x3c(%ebx),%esi
f010481d:	8d 86 00 10 40 11    	lea    0x11401000(%esi),%eax
		
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		//note: it is not like the requirement!!! there is two block
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -8;
f0104823:	83 ee 3c             	sub    $0x3c,%esi
f0104826:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f010482b:	b8 cc ff bf ee       	mov    $0xeebfffcc,%eax
f0104830:	0f 47 f0             	cmova  %eax,%esi
	
	user_mem_assert(curenv, (void*)newEsp, 0, PTE_U|PTE_W|PTE_P);
f0104833:	e8 01 1e 00 00       	call   f0106639 <cpunum>
f0104838:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f010483f:	00 
f0104840:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104847:	00 
f0104848:	89 74 24 04          	mov    %esi,0x4(%esp)
f010484c:	6b c0 74             	imul   $0x74,%eax,%eax
f010484f:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104855:	89 04 24             	mov    %eax,(%esp)
f0104858:	e8 8a ed ff ff       	call   f01035e7 <user_mem_assert>

	UT.utf_err = tf->tf_err;
f010485d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104860:	89 45 b8             	mov    %eax,-0x48(%ebp)
	UT.utf_regs = tf->tf_regs;
f0104863:	8b 03                	mov    (%ebx),%eax
f0104865:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0104868:	8b 43 04             	mov    0x4(%ebx),%eax
f010486b:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010486e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104871:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104874:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104877:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010487a:	8b 43 10             	mov    0x10(%ebx),%eax
f010487d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104880:	8b 43 14             	mov    0x14(%ebx),%eax
f0104883:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104886:	8b 43 18             	mov    0x18(%ebx),%eax
f0104889:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010488c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010488f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	UT.utf_eflags = tf->tf_eflags;
f0104892:	8b 43 38             	mov    0x38(%ebx),%eax
f0104895:	89 45 e0             	mov    %eax,-0x20(%ebp)
	UT.utf_eip = tf->tf_eip;
f0104898:	8b 43 30             	mov    0x30(%ebx),%eax
f010489b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	UT.utf_esp = tf->tf_esp;
f010489e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01048a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	UT.utf_fault_va = fault_va;
f01048a4:	89 7d b4             	mov    %edi,-0x4c(%ebp)

	user_mem_assert(curenv,(void*)newEsp, sizeof(struct UTrapframe),PTE_U|PTE_P|PTE_W );
f01048a7:	e8 8d 1d 00 00       	call   f0106639 <cpunum>
f01048ac:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01048b3:	00 
f01048b4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01048bb:	00 
f01048bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01048c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c3:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01048c9:	89 04 24             	mov    %eax,(%esp)
f01048cc:	e8 16 ed ff ff       	call   f01035e7 <user_mem_assert>
	memcpy((void*)newEsp, (&UT) ,sizeof(struct UTrapframe));
f01048d1:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01048d8:	00 
f01048d9:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f01048dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048e0:	89 34 24             	mov    %esi,(%esp)
f01048e3:	e8 b4 17 00 00       	call   f010609c <memcpy>
	tf->tf_esp = newEsp;
f01048e8:	89 73 3c             	mov    %esi,0x3c(%ebx)
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01048eb:	e8 49 1d 00 00       	call   f0106639 <cpunum>
f01048f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f3:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01048f9:	8b 40 64             	mov    0x64(%eax),%eax
f01048fc:	89 43 30             	mov    %eax,0x30(%ebx)
	env_run(curenv);
f01048ff:	e8 35 1d 00 00       	call   f0106639 <cpunum>
f0104904:	6b c0 74             	imul   $0x74,%eax,%eax
f0104907:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f010490d:	89 04 24             	mov    %eax,(%esp)
f0104910:	e8 56 f4 ff ff       	call   f0103d6b <env_run>

f0104915 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104915:	55                   	push   %ebp
f0104916:	89 e5                	mov    %esp,%ebp
f0104918:	57                   	push   %edi
f0104919:	56                   	push   %esi
f010491a:	83 ec 20             	sub    $0x20,%esp
f010491d:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104920:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104921:	83 3d 80 2e 1e f0 00 	cmpl   $0x0,0xf01e2e80
f0104928:	74 01                	je     f010492b <trap+0x16>
		asm volatile("hlt");
f010492a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010492b:	e8 09 1d 00 00       	call   f0106639 <cpunum>
f0104930:	6b d0 74             	imul   $0x74,%eax,%edx
f0104933:	81 c2 20 30 1e f0    	add    $0xf01e3020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104939:	b8 01 00 00 00       	mov    $0x1,%eax
f010493e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104942:	83 f8 02             	cmp    $0x2,%eax
f0104945:	75 0c                	jne    f0104953 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104947:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010494e:	e8 64 1f 00 00       	call   f01068b7 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104953:	9c                   	pushf  
f0104954:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104955:	f6 c4 02             	test   $0x2,%ah
f0104958:	74 24                	je     f010497e <trap+0x69>
f010495a:	c7 44 24 0c 08 81 10 	movl   $0xf0108108,0xc(%esp)
f0104961:	f0 
f0104962:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f0104969:	f0 
f010496a:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0104971:	00 
f0104972:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f0104979:	e8 c2 b6 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010497e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104982:	83 e0 03             	and    $0x3,%eax
f0104985:	66 83 f8 03          	cmp    $0x3,%ax
f0104989:	0f 85 a7 00 00 00    	jne    f0104a36 <trap+0x121>
f010498f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104996:	e8 1c 1f 00 00       	call   f01068b7 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB : Your code here.
		lock_kernel();
		assert(curenv);
f010499b:	e8 99 1c 00 00       	call   f0106639 <cpunum>
f01049a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a3:	83 b8 28 30 1e f0 00 	cmpl   $0x0,-0xfe1cfd8(%eax)
f01049aa:	75 24                	jne    f01049d0 <trap+0xbb>
f01049ac:	c7 44 24 0c 21 81 10 	movl   $0xf0108121,0xc(%esp)
f01049b3:	f0 
f01049b4:	c7 44 24 08 b3 7b 10 	movl   $0xf0107bb3,0x8(%esp)
f01049bb:	f0 
f01049bc:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f01049c3:	00 
f01049c4:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f01049cb:	e8 70 b6 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049d0:	e8 64 1c 00 00       	call   f0106639 <cpunum>
f01049d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d8:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01049de:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049e2:	75 2d                	jne    f0104a11 <trap+0xfc>
			env_free(curenv);
f01049e4:	e8 50 1c 00 00       	call   f0106639 <cpunum>
f01049e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ec:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01049f2:	89 04 24             	mov    %eax,(%esp)
f01049f5:	e8 05 f1 ff ff       	call   f0103aff <env_free>
			curenv = NULL;
f01049fa:	e8 3a 1c 00 00       	call   f0106639 <cpunum>
f01049ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a02:	c7 80 28 30 1e f0 00 	movl   $0x0,-0xfe1cfd8(%eax)
f0104a09:	00 00 00 
			sched_yield();
f0104a0c:	e8 16 03 00 00       	call   f0104d27 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104a11:	e8 23 1c 00 00       	call   f0106639 <cpunum>
f0104a16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a19:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104a1f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a24:	89 c7                	mov    %eax,%edi
f0104a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a28:	e8 0c 1c 00 00       	call   f0106639 <cpunum>
f0104a2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a30:	8b b0 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a36:	89 35 60 2a 1e f0    	mov    %esi,0xf01e2a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB : Your code here.
if(tf->tf_trapno == T_PGFLT){
f0104a3c:	8b 46 28             	mov    0x28(%esi),%eax
f0104a3f:	83 f8 0e             	cmp    $0xe,%eax
f0104a42:	75 08                	jne    f0104a4c <trap+0x137>
		page_fault_handler(tf);
f0104a44:	89 34 24             	mov    %esi,(%esp)
f0104a47:	e8 3e fd ff ff       	call   f010478a <page_fault_handler>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f0104a4c:	83 f8 03             	cmp    $0x3,%eax
f0104a4f:	75 0d                	jne    f0104a5e <trap+0x149>
		monitor(tf);
f0104a51:	89 34 24             	mov    %esi,(%esp)
f0104a54:	e8 48 bf ff ff       	call   f01009a1 <monitor>
f0104a59:	e9 a2 00 00 00       	jmp    f0104b00 <trap+0x1eb>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f0104a5e:	83 f8 30             	cmp    $0x30,%eax
f0104a61:	75 32                	jne    f0104a95 <trap+0x180>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104a63:	8b 46 04             	mov    0x4(%esi),%eax
f0104a66:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a6a:	8b 06                	mov    (%esi),%eax
f0104a6c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a70:	8b 46 10             	mov    0x10(%esi),%eax
f0104a73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a77:	8b 46 18             	mov    0x18(%esi),%eax
f0104a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a7e:	8b 46 14             	mov    0x14(%esi),%eax
f0104a81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a85:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a88:	89 04 24             	mov    %eax,(%esp)
f0104a8b:	e8 60 03 00 00       	call   f0104df0 <syscall>
f0104a90:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a93:	eb 6b                	jmp    f0104b00 <trap+0x1eb>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a95:	83 f8 27             	cmp    $0x27,%eax
f0104a98:	75 16                	jne    f0104ab0 <trap+0x19b>
		cprintf("Spurious interrupt on irq 7\n");
f0104a9a:	c7 04 24 28 81 10 f0 	movl   $0xf0108128,(%esp)
f0104aa1:	e8 1b f5 ff ff       	call   f0103fc1 <cprintf>
		print_trapframe(tf);
f0104aa6:	89 34 24             	mov    %esi,(%esp)
f0104aa9:	e8 3f fb ff ff       	call   f01045ed <print_trapframe>
f0104aae:	eb 50                	jmp    f0104b00 <trap+0x1eb>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB : Your code here.
	if(tf->tf_trapno == IRQ_TIMER + IRQ_OFFSET){
f0104ab0:	83 f8 20             	cmp    $0x20,%eax
f0104ab3:	75 0a                	jne    f0104abf <trap+0x1aa>
		//cprintf("The Irq_Time is also work\n");
		lapic_eoi();
f0104ab5:	e8 cc 1c 00 00       	call   f0106786 <lapic_eoi>
		sched_yield();
f0104aba:	e8 68 02 00 00       	call   f0104d27 <sched_yield>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104abf:	89 34 24             	mov    %esi,(%esp)
f0104ac2:	e8 26 fb ff ff       	call   f01045ed <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ac7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104acc:	75 1c                	jne    f0104aea <trap+0x1d5>
		panic("unhandled trap in kernel");
f0104ace:	c7 44 24 08 45 81 10 	movl   $0xf0108145,0x8(%esp)
f0104ad5:	f0 
f0104ad6:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0104add:	00 
f0104ade:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f0104ae5:	e8 56 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104aea:	e8 4a 1b 00 00       	call   f0106639 <cpunum>
f0104aef:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af2:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104af8:	89 04 24             	mov    %eax,(%esp)
f0104afb:	e8 ca f1 ff ff       	call   f0103cca <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b00:	e8 34 1b 00 00       	call   f0106639 <cpunum>
f0104b05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b08:	83 b8 28 30 1e f0 00 	cmpl   $0x0,-0xfe1cfd8(%eax)
f0104b0f:	74 2a                	je     f0104b3b <trap+0x226>
f0104b11:	e8 23 1b 00 00       	call   f0106639 <cpunum>
f0104b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b19:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104b1f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b23:	75 16                	jne    f0104b3b <trap+0x226>
		env_run(curenv);
f0104b25:	e8 0f 1b 00 00       	call   f0106639 <cpunum>
f0104b2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2d:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104b33:	89 04 24             	mov    %eax,(%esp)
f0104b36:	e8 30 f2 ff ff       	call   f0103d6b <env_run>
	else
		sched_yield();
f0104b3b:	e8 e7 01 00 00       	call   f0104d27 <sched_yield>

f0104b40 <handler0>:
.text

/*
 * Lab : Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104b40:	6a 00                	push   $0x0
f0104b42:	6a 00                	push   $0x0
f0104b44:	e9 f6 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b49:	90                   	nop

f0104b4a <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104b4a:	6a 00                	push   $0x0
f0104b4c:	6a 01                	push   $0x1
f0104b4e:	e9 ec 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b53:	90                   	nop

f0104b54 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f0104b54:	6a 00                	push   $0x0
f0104b56:	6a 02                	push   $0x2
f0104b58:	e9 e2 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b5d:	90                   	nop

f0104b5e <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104b5e:	6a 00                	push   $0x0
f0104b60:	6a 03                	push   $0x3
f0104b62:	e9 d8 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b67:	90                   	nop

f0104b68 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104b68:	6a 00                	push   $0x0
f0104b6a:	6a 04                	push   $0x4
f0104b6c:	e9 ce 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b71:	90                   	nop

f0104b72 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104b72:	6a 00                	push   $0x0
f0104b74:	6a 05                	push   $0x5
f0104b76:	e9 c4 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b7b:	90                   	nop

f0104b7c <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104b7c:	6a 00                	push   $0x0
f0104b7e:	6a 06                	push   $0x6
f0104b80:	e9 ba 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b85:	90                   	nop

f0104b86 <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104b86:	6a 00                	push   $0x0
f0104b88:	6a 07                	push   $0x7
f0104b8a:	e9 b0 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b8f:	90                   	nop

f0104b90 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104b90:	6a 08                	push   $0x8
f0104b92:	e9 a8 00 00 00       	jmp    f0104c3f <_alltraps>
f0104b97:	90                   	nop

f0104b98 <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104b98:	6a 00                	push   $0x0
f0104b9a:	6a 09                	push   $0x9
f0104b9c:	e9 9e 00 00 00       	jmp    f0104c3f <_alltraps>
f0104ba1:	90                   	nop

f0104ba2 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104ba2:	6a 0a                	push   $0xa
f0104ba4:	e9 96 00 00 00       	jmp    f0104c3f <_alltraps>
f0104ba9:	90                   	nop

f0104baa <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104baa:	6a 0b                	push   $0xb
f0104bac:	e9 8e 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bb1:	90                   	nop

f0104bb2 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104bb2:	6a 0c                	push   $0xc
f0104bb4:	e9 86 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bb9:	90                   	nop

f0104bba <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104bba:	6a 0d                	push   $0xd
f0104bbc:	e9 7e 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bc1:	90                   	nop

f0104bc2 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104bc2:	6a 0e                	push   $0xe
f0104bc4:	e9 76 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bc9:	90                   	nop

f0104bca <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104bca:	6a 00                	push   $0x0
f0104bcc:	6a 0f                	push   $0xf
f0104bce:	e9 6c 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bd3:	90                   	nop

f0104bd4 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104bd4:	6a 00                	push   $0x0
f0104bd6:	6a 10                	push   $0x10
f0104bd8:	e9 62 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bdd:	90                   	nop

f0104bde <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104bde:	6a 11                	push   $0x11
f0104be0:	e9 5a 00 00 00       	jmp    f0104c3f <_alltraps>
f0104be5:	90                   	nop

f0104be6 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104be6:	6a 00                	push   $0x0
f0104be8:	6a 12                	push   $0x12
f0104bea:	e9 50 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bef:	90                   	nop

f0104bf0 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104bf0:	6a 00                	push   $0x0
f0104bf2:	6a 13                	push   $0x13
f0104bf4:	e9 46 00 00 00       	jmp    f0104c3f <_alltraps>
f0104bf9:	90                   	nop

f0104bfa <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104bfa:	6a 00                	push   $0x0
f0104bfc:	6a 30                	push   $0x30
f0104bfe:	e9 3c 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c03:	90                   	nop

f0104c04 <handlerIRQ0>:

/*
* lab4
*/
	
TRAPHANDLER_NOEC(handlerIRQ0, IRQ_OFFSET+IRQ_TIMER)
f0104c04:	6a 00                	push   $0x0
f0104c06:	6a 20                	push   $0x20
f0104c08:	e9 32 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c0d:	90                   	nop

f0104c0e <handlerIRQ1>:
TRAPHANDLER_NOEC(handlerIRQ1, IRQ_OFFSET+IRQ_KBD)
f0104c0e:	6a 00                	push   $0x0
f0104c10:	6a 21                	push   $0x21
f0104c12:	e9 28 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c17:	90                   	nop

f0104c18 <handlerIRQ4>:
TRAPHANDLER_NOEC(handlerIRQ4, IRQ_OFFSET+IRQ_SERIAL)
f0104c18:	6a 00                	push   $0x0
f0104c1a:	6a 24                	push   $0x24
f0104c1c:	e9 1e 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c21:	90                   	nop

f0104c22 <handlerIRQ7>:
TRAPHANDLER_NOEC(handlerIRQ7, IRQ_OFFSET+IRQ_SPURIOUS)
f0104c22:	6a 00                	push   $0x0
f0104c24:	6a 27                	push   $0x27
f0104c26:	e9 14 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c2b:	90                   	nop

f0104c2c <handlerIRQ14>:
TRAPHANDLER_NOEC(handlerIRQ14, IRQ_OFFSET+IRQ_IDE)
f0104c2c:	6a 00                	push   $0x0
f0104c2e:	6a 2e                	push   $0x2e
f0104c30:	e9 0a 00 00 00       	jmp    f0104c3f <_alltraps>
f0104c35:	90                   	nop

f0104c36 <handlerIRQ19>:
TRAPHANDLER_NOEC(handlerIRQ19, IRQ_OFFSET+IRQ_ERROR)
f0104c36:	6a 00                	push   $0x0
f0104c38:	6a 33                	push   $0x33
f0104c3a:	e9 00 00 00 00       	jmp    f0104c3f <_alltraps>

f0104c3f <_alltraps>:
/*
 * Lab : Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104c3f:	1e                   	push   %ds
	pushl %es
f0104c40:	06                   	push   %es
	pushal
f0104c41:	60                   	pusha  
	movl $GD_KD, %eax
f0104c42:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104c47:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c49:	8e c0                	mov    %eax,%es

	pushl %esp
f0104c4b:	54                   	push   %esp
	call trap
f0104c4c:	e8 c4 fc ff ff       	call   f0104915 <trap>

f0104c51 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104c51:	55                   	push   %ebp
f0104c52:	89 e5                	mov    %esp,%ebp
f0104c54:	83 ec 18             	sub    $0x18,%esp
f0104c57:	8b 15 48 22 1e f0    	mov    0xf01e2248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c5d:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c62:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104c65:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c68:	83 f9 02             	cmp    $0x2,%ecx
f0104c6b:	76 0f                	jbe    f0104c7c <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c6d:	83 c0 01             	add    $0x1,%eax
f0104c70:	83 c2 7c             	add    $0x7c,%edx
f0104c73:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c78:	75 e8                	jne    f0104c62 <sched_halt+0x11>
f0104c7a:	eb 07                	jmp    f0104c83 <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c7c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c81:	75 1a                	jne    f0104c9d <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104c83:	c7 04 24 50 83 10 f0 	movl   $0xf0108350,(%esp)
f0104c8a:	e8 32 f3 ff ff       	call   f0103fc1 <cprintf>
		while (1)
			monitor(NULL);
f0104c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c96:	e8 06 bd ff ff       	call   f01009a1 <monitor>
f0104c9b:	eb f2                	jmp    f0104c8f <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c9d:	e8 97 19 00 00       	call   f0106639 <cpunum>
f0104ca2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca5:	c7 80 28 30 1e f0 00 	movl   $0x0,-0xfe1cfd8(%eax)
f0104cac:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104caf:	a1 8c 2e 1e f0       	mov    0xf01e2e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104cb4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104cb9:	77 20                	ja     f0104cdb <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104cbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104cbf:	c7 44 24 08 68 6d 10 	movl   $0xf0106d68,0x8(%esp)
f0104cc6:	f0 
f0104cc7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0104cce:	00 
f0104ccf:	c7 04 24 79 83 10 f0 	movl   $0xf0108379,(%esp)
f0104cd6:	e8 65 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104cdb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104ce0:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104ce3:	e8 51 19 00 00       	call   f0106639 <cpunum>
f0104ce8:	6b d0 74             	imul   $0x74,%eax,%edx
f0104ceb:	81 c2 20 30 1e f0    	add    $0xf01e3020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104cf1:	b8 02 00 00 00       	mov    $0x2,%eax
f0104cf6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104cfa:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104d01:	e8 5d 1c 00 00       	call   f0106963 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104d06:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104d08:	e8 2c 19 00 00       	call   f0106639 <cpunum>
f0104d0d:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104d10:	8b 80 30 30 1e f0    	mov    -0xfe1cfd0(%eax),%eax
f0104d16:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104d1b:	89 c4                	mov    %eax,%esp
f0104d1d:	6a 00                	push   $0x0
f0104d1f:	6a 00                	push   $0x0
f0104d21:	fb                   	sti    
f0104d22:	f4                   	hlt    
f0104d23:	eb fd                	jmp    f0104d22 <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104d25:	c9                   	leave  
f0104d26:	c3                   	ret    

f0104d27 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104d27:	55                   	push   %ebp
f0104d28:	89 e5                	mov    %esp,%ebp
f0104d2a:	57                   	push   %edi
f0104d2b:	56                   	push   %esi
f0104d2c:	53                   	push   %ebx
f0104d2d:	83 ec 1c             	sub    $0x1c,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB : Your code here.
struct Env *e = thiscpu->cpu_env;
f0104d30:	e8 04 19 00 00       	call   f0106639 <cpunum>
f0104d35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d38:	8b 98 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104d3e:	85 db                	test   %ebx,%ebx
f0104d40:	74 45                	je     f0104d87 <sched_yield+0x60>
		
		EnvID =  e-envs;
f0104d42:	89 de                	mov    %ebx,%esi
f0104d44:	2b 35 48 22 1e f0    	sub    0xf01e2248,%esi
f0104d4a:	c1 fe 02             	sar    $0x2,%esi
f0104d4d:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104d53:	89 f1                	mov    %esi,%ecx
		// maybe the env status is ENV_NOTRUNNABLE  so next if is important
		if(e->env_status ==ENV_RUNNING )
f0104d55:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104d59:	75 07                	jne    f0104d62 <sched_yield+0x3b>
		e->env_status = ENV_RUNNABLE;
f0104d5b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104d62:	83 c6 01             	add    $0x1,%esi
f0104d65:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104d6a:	89 f0                	mov    %esi,%eax
f0104d6c:	f7 ea                	imul   %edx
f0104d6e:	01 f2                	add    %esi,%edx
f0104d70:	c1 fa 09             	sar    $0x9,%edx
f0104d73:	89 f0                	mov    %esi,%eax
f0104d75:	c1 f8 1f             	sar    $0x1f,%eax
f0104d78:	29 c2                	sub    %eax,%edx
f0104d7a:	89 d0                	mov    %edx,%eax
f0104d7c:	c1 e0 0a             	shl    $0xa,%eax
f0104d7f:	29 d0                	sub    %edx,%eax
f0104d81:	89 f2                	mov    %esi,%edx
f0104d83:	29 c2                	sub    %eax,%edx
f0104d85:	eb 0a                	jmp    f0104d91 <sched_yield+0x6a>
	// below to halt the cpu.

	// LAB : Your code here.
struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
f0104d87:	ba 00 00 00 00       	mov    $0x0,%edx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB : Your code here.
struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104d91:	8b 3d 48 22 1e f0    	mov    0xf01e2248,%edi
f0104d97:	6b c2 7c             	imul   $0x7c,%edx,%eax
f0104d9a:	01 f8                	add    %edi,%eax
f0104d9c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104da0:	75 08                	jne    f0104daa <sched_yield+0x83>
			env_run(&envs[i]);
f0104da2:	89 04 24             	mov    %eax,(%esp)
f0104da5:	e8 c1 ef ff ff       	call   f0103d6b <env_run>
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104daa:	83 c2 01             	add    $0x1,%edx
f0104dad:	89 d6                	mov    %edx,%esi
f0104daf:	c1 fe 1f             	sar    $0x1f,%esi
f0104db2:	c1 ee 16             	shr    $0x16,%esi
f0104db5:	01 f2                	add    %esi,%edx
f0104db7:	89 d0                	mov    %edx,%eax
f0104db9:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104dbe:	29 f0                	sub    %esi,%eax
f0104dc0:	89 c2                	mov    %eax,%edx
f0104dc2:	39 c1                	cmp    %eax,%ecx
f0104dc4:	75 d1                	jne    f0104d97 <sched_yield+0x70>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e && e->env_status == ENV_RUNNING)
f0104dc6:	85 db                	test   %ebx,%ebx
f0104dc8:	74 0e                	je     f0104dd8 <sched_yield+0xb1>
f0104dca:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104dce:	75 08                	jne    f0104dd8 <sched_yield+0xb1>
		
		env_run(e);
f0104dd0:	89 1c 24             	mov    %ebx,(%esp)
f0104dd3:	e8 93 ef ff ff       	call   f0103d6b <env_run>
  
	// sched_halt never returns
	sched_halt();
f0104dd8:	e8 74 fe ff ff       	call   f0104c51 <sched_halt>
}
f0104ddd:	83 c4 1c             	add    $0x1c,%esp
f0104de0:	5b                   	pop    %ebx
f0104de1:	5e                   	pop    %esi
f0104de2:	5f                   	pop    %edi
f0104de3:	5d                   	pop    %ebp
f0104de4:	c3                   	ret    
f0104de5:	66 90                	xchg   %ax,%ax
f0104de7:	66 90                	xchg   %ax,%ax
f0104de9:	66 90                	xchg   %ax,%ax
f0104deb:	66 90                	xchg   %ax,%ax
f0104ded:	66 90                	xchg   %ax,%ax
f0104def:	90                   	nop

f0104df0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104df0:	55                   	push   %ebp
f0104df1:	89 e5                	mov    %esp,%ebp
f0104df3:	57                   	push   %edi
f0104df4:	56                   	push   %esi
f0104df5:	53                   	push   %ebx
f0104df6:	83 ec 2c             	sub    $0x2c,%esp
f0104df9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB : Your code here.

	int ret = 0;
	switch(syscallno){
f0104dfc:	83 f8 0d             	cmp    $0xd,%eax
f0104dff:	0f 87 b3 05 00 00    	ja     f01053b8 <syscall+0x5c8>
f0104e05:	ff 24 85 8c 83 10 f0 	jmp    *-0xfef7c74(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB : Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104e0c:	e8 28 18 00 00       	call   f0106639 <cpunum>
f0104e11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104e18:	00 
f0104e19:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e1c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2a:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104e30:	89 04 24             	mov    %eax,(%esp)
f0104e33:	e8 af e7 ff ff       	call   f01035e7 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104e38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e3f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e46:	c7 04 24 86 83 10 f0 	movl   $0xf0108386,(%esp)
f0104e4d:	e8 6f f1 ff ff       	call   f0103fc1 <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB : Your code here.

	int ret = 0;
f0104e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e57:	e9 68 05 00 00       	jmp    f01053c4 <syscall+0x5d4>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e5c:	e8 c4 b7 ff ff       	call   f0100625 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104e61:	e9 5e 05 00 00       	jmp    f01053c4 <syscall+0x5d4>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e66:	e8 ce 17 00 00       	call   f0106639 <cpunum>
f0104e6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e6e:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0104e74:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104e77:	e9 48 05 00 00       	jmp    f01053c4 <syscall+0x5d4>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e7c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e83:	00 
f0104e84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e8e:	89 04 24             	mov    %eax,(%esp)
f0104e91:	e8 54 e8 ff ff       	call   f01036ea <envid2env>
		return r;
f0104e96:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e98:	85 c0                	test   %eax,%eax
f0104e9a:	78 10                	js     f0104eac <syscall+0xbc>
		return r;
	env_destroy(e);
f0104e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9f:	89 04 24             	mov    %eax,(%esp)
f0104ea2:	e8 23 ee ff ff       	call   f0103cca <env_destroy>
	return 0;
f0104ea7:	ba 00 00 00 00       	mov    $0x0,%edx
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
f0104eac:	89 d0                	mov    %edx,%eax
						break;
f0104eae:	e9 11 05 00 00       	jmp    f01053c4 <syscall+0x5d4>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104eb3:	e8 6f fe ff ff       	call   f0104d27 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB : Your code here.
	struct Env* childEnv=0;
f0104eb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct Env* parentEnv = curenv;
f0104ebf:	e8 75 17 00 00       	call   f0106639 <cpunum>
f0104ec4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec7:	8b b0 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104ecd:	8b 46 48             	mov    0x48(%esi),%eax
f0104ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ed7:	89 04 24             	mov    %eax,(%esp)
f0104eda:	e8 14 e9 ff ff       	call   f01037f3 <env_alloc>
	if(r < 0)
f0104edf:	85 c0                	test   %eax,%eax
f0104ee1:	0f 88 dd 04 00 00    	js     f01053c4 <syscall+0x5d4>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104ee7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104eec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ef4:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104efb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104f02:	8b 40 48             	mov    0x48(%eax),%eax
f0104f05:	e9 ba 04 00 00       	jmp    f01053c4 <syscall+0x5d4>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB : Your code here.
	struct Env *e =0;
f0104f0a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f18:	00 
f0104f19:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f23:	89 04 24             	mov    %eax,(%esp)
f0104f26:	e8 bf e7 ff ff       	call   f01036ea <envid2env>
f0104f2b:	85 c0                	test   %eax,%eax
f0104f2d:	0f 88 91 04 00 00    	js     f01053c4 <syscall+0x5d4>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104f33:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104f37:	74 06                	je     f0104f3f <syscall+0x14f>
f0104f39:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104f3d:	75 13                	jne    f0104f52 <syscall+0x162>
		return -E_INVAL;
	e->env_status = status;
f0104f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f42:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f45:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104f48:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f4d:	e9 72 04 00 00       	jmp    f01053c4 <syscall+0x5d4>
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
f0104f57:	e9 68 04 00 00       	jmp    f01053c4 <syscall+0x5d4>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	
	struct Env *e =0;
f0104f5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f63:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f6a:	00 
f0104f6b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f75:	89 04 24             	mov    %eax,(%esp)
f0104f78:	e8 6d e7 ff ff       	call   f01036ea <envid2env>
f0104f7d:	85 c0                	test   %eax,%eax
f0104f7f:	78 6c                	js     f0104fed <syscall+0x1fd>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104f81:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f88:	77 67                	ja     f0104ff1 <syscall+0x201>
f0104f8a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f91:	75 65                	jne    f0104ff8 <syscall+0x208>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104f93:	8b 75 14             	mov    0x14(%ebp),%esi
f0104f96:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f0104f9c:	75 61                	jne    f0104fff <syscall+0x20f>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104f9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fa1:	83 e0 05             	and    $0x5,%eax
f0104fa4:	83 f8 05             	cmp    $0x5,%eax
f0104fa7:	75 5d                	jne    f0105006 <syscall+0x216>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104fa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104fb0:	e8 dd c0 ff ff       	call   f0101092 <page_alloc>
f0104fb5:	89 c3                	mov    %eax,%ebx
	if(page == 0)
f0104fb7:	85 c0                	test   %eax,%eax
f0104fb9:	74 52                	je     f010500d <syscall+0x21d>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104fbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fc2:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fd0:	8b 40 60             	mov    0x60(%eax),%eax
f0104fd3:	89 04 24             	mov    %eax,(%esp)
f0104fd6:	e8 a9 c3 ff ff       	call   f0101384 <page_insert>
f0104fdb:	89 c7                	mov    %eax,%edi
	if(r <0){
f0104fdd:	85 c0                	test   %eax,%eax
f0104fdf:	79 31                	jns    f0105012 <syscall+0x222>
		page_free(page);
f0104fe1:	89 1c 24             	mov    %ebx,(%esp)
f0104fe4:	e8 34 c1 ff ff       	call   f010111d <page_free>
		return r;
f0104fe9:	89 fe                	mov    %edi,%esi
f0104feb:	eb 25                	jmp    f0105012 <syscall+0x222>
	// LAB 4: Your code here.
	
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104fed:	89 c6                	mov    %eax,%esi
f0104fef:	eb 21                	jmp    f0105012 <syscall+0x222>
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104ff1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104ff6:	eb 1a                	jmp    f0105012 <syscall+0x222>
f0104ff8:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104ffd:	eb 13                	jmp    f0105012 <syscall+0x222>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0104fff:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105004:	eb 0c                	jmp    f0105012 <syscall+0x222>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0105006:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010500b:	eb 05                	jmp    f0105012 <syscall+0x222>
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f010500d:	be fc ff ff ff       	mov    $0xfffffffc,%esi

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
f0105012:	89 f0                	mov    %esi,%eax
						break;
f0105014:	e9 ab 03 00 00       	jmp    f01053c4 <syscall+0x5d4>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB : Your code here.
	struct Env *srcE=0, *destE = 0;
f0105019:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105020:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0105027:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010502e:	00 
f010502f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105032:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105036:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105039:	89 04 24             	mov    %eax,(%esp)
f010503c:	e8 a9 e6 ff ff       	call   f01036ea <envid2env>
		return r;
f0105041:	89 c2                	mov    %eax,%edx
	//   check the current permissions on the page.

	// LAB : Your code here.
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0105043:	85 c0                	test   %eax,%eax
f0105045:	0f 88 05 01 00 00    	js     f0105150 <syscall+0x360>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f010504b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105052:	00 
f0105053:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105056:	89 44 24 04          	mov    %eax,0x4(%esp)
f010505a:	8b 45 14             	mov    0x14(%ebp),%eax
f010505d:	89 04 24             	mov    %eax,(%esp)
f0105060:	e8 85 e6 ff ff       	call   f01036ea <envid2env>
f0105065:	85 c0                	test   %eax,%eax
f0105067:	0f 88 a9 00 00 00    	js     f0105116 <syscall+0x326>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f010506d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105074:	0f 87 a0 00 00 00    	ja     f010511a <syscall+0x32a>
f010507a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105081:	0f 85 9a 00 00 00    	jne    f0105121 <syscall+0x331>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f0105087:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010508e:	0f 87 94 00 00 00    	ja     f0105128 <syscall+0x338>
f0105094:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010509b:	0f 85 8e 00 00 00    	jne    f010512f <syscall+0x33f>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f01050a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f01050a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050af:	8b 45 10             	mov    0x10(%ebp),%eax
f01050b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050b9:	8b 40 60             	mov    0x60(%eax),%eax
f01050bc:	89 04 24             	mov    %eax,(%esp)
f01050bf:	e8 bd c1 ff ff       	call   f0101281 <page_lookup>
	if(page == 0)
f01050c4:	85 c0                	test   %eax,%eax
f01050c6:	74 6e                	je     f0105136 <syscall+0x346>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f01050c8:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01050cf:	75 6c                	jne    f010513d <syscall+0x34d>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f01050d1:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01050d4:	83 e2 05             	and    $0x5,%edx
f01050d7:	83 fa 05             	cmp    $0x5,%edx
f01050da:	75 68                	jne    f0105144 <syscall+0x354>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f01050dc:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01050e0:	74 08                	je     f01050ea <syscall+0x2fa>
f01050e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01050e5:	f6 02 02             	testb  $0x2,(%edx)
f01050e8:	74 61                	je     f010514b <syscall+0x35b>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f01050ea:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01050ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01050f1:	8b 7d 18             	mov    0x18(%ebp),%edi
f01050f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01050f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050ff:	8b 40 60             	mov    0x60(%eax),%eax
f0105102:	89 04 24             	mov    %eax,(%esp)
f0105105:	e8 7a c2 ff ff       	call   f0101384 <page_insert>
f010510a:	85 c0                	test   %eax,%eax
f010510c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105111:	0f 4e d0             	cmovle %eax,%edx
f0105114:	eb 3a                	jmp    f0105150 <syscall+0x360>
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
f0105116:	89 c2                	mov    %eax,%edx
f0105118:	eb 36                	jmp    f0105150 <syscall+0x360>
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f010511a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010511f:	eb 2f                	jmp    f0105150 <syscall+0x360>
f0105121:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105126:	eb 28                	jmp    f0105150 <syscall+0x360>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
f0105128:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010512d:	eb 21                	jmp    f0105150 <syscall+0x360>
f010512f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105134:	eb 1a                	jmp    f0105150 <syscall+0x360>
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f0105136:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010513b:	eb 13                	jmp    f0105150 <syscall+0x360>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f010513d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105142:	eb 0c                	jmp    f0105150 <syscall+0x360>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0105144:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105149:	eb 05                	jmp    f0105150 <syscall+0x360>
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
		return -E_INVAL;
f010514b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
f0105150:	89 d0                	mov    %edx,%eax
						break;
f0105152:	e9 6d 02 00 00       	jmp    f01053c4 <syscall+0x5d4>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB : Your code here.
	struct Env *e =0;
f0105157:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f010515e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105165:	00 
f0105166:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105169:	89 44 24 04          	mov    %eax,0x4(%esp)
f010516d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105170:	89 04 24             	mov    %eax,(%esp)
f0105173:	e8 72 e5 ff ff       	call   f01036ea <envid2env>
f0105178:	85 c0                	test   %eax,%eax
f010517a:	0f 88 44 02 00 00    	js     f01053c4 <syscall+0x5d4>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0105180:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105187:	77 28                	ja     f01051b1 <syscall+0x3c1>
f0105189:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105190:	75 29                	jne    f01051bb <syscall+0x3cb>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f0105192:	8b 45 10             	mov    0x10(%ebp),%eax
f0105195:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105199:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010519c:	8b 40 60             	mov    0x60(%eax),%eax
f010519f:	89 04 24             	mov    %eax,(%esp)
f01051a2:	e8 84 c1 ff ff       	call   f010132b <page_remove>
	return 0;
f01051a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01051ac:	e9 13 02 00 00       	jmp    f01053c4 <syscall+0x5d4>
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f01051b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051b6:	e9 09 02 00 00       	jmp    f01053c4 <syscall+0x5d4>
f01051bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
f01051c0:	e9 ff 01 00 00       	jmp    f01053c4 <syscall+0x5d4>
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB : Your code here.
	struct Env *e =0;
f01051c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f01051cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051d3:	00 
f01051d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051de:	89 04 24             	mov    %eax,(%esp)
f01051e1:	e8 04 e5 ff ff       	call   f01036ea <envid2env>
f01051e6:	85 c0                	test   %eax,%eax
f01051e8:	0f 88 d6 01 00 00    	js     f01053c4 <syscall+0x5d4>
		return r;
	e->env_pgfault_upcall = func;
f01051ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01051f4:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f01051f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01051fc:	e9 c3 01 00 00       	jmp    f01053c4 <syscall+0x5d4>
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB : Your code here.
	struct Env *env=0;
f0105201:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	pte_t * pte =0;
f0105208:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if((r = envid2env(envid, &env, 0)) < 0)
f010520f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105216:	00 
f0105217:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010521a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010521e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105221:	89 04 24             	mov    %eax,(%esp)
f0105224:	e8 c1 e4 ff ff       	call   f01036ea <envid2env>
f0105229:	85 c0                	test   %eax,%eax
f010522b:	0f 88 eb 00 00 00    	js     f010531c <syscall+0x52c>
		return -E_BAD_ENV;
	
	
	if(env->env_ipc_recving == 0)
f0105231:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105234:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105238:	0f 84 e5 00 00 00    	je     f0105323 <syscall+0x533>
		return -E_IPC_NOT_RECV;
	

	if((int)srcva < UTOP){
f010523e:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105245:	0f 87 92 00 00 00    	ja     f01052dd <syscall+0x4ed>

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
f010524b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105252:	0f 85 d2 00 00 00    	jne    f010532a <syscall+0x53a>
			return -E_INVAL;
			
		if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0105258:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010525f:	0f 85 cc 00 00 00    	jne    f0105331 <syscall+0x541>
			return  -E_INVAL;
			
		if(  (perm & PTE_P) ==0 )
f0105265:	f6 45 18 01          	testb  $0x1,0x18(%ebp)
f0105269:	0f 84 c9 00 00 00    	je     f0105338 <syscall+0x548>
			return  -E_INVAL;
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
f010526f:	e8 c5 13 00 00       	call   f0106639 <cpunum>
f0105274:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105277:	89 54 24 08          	mov    %edx,0x8(%esp)
f010527b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010527e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105282:	6b c0 74             	imul   $0x74,%eax,%eax
f0105285:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f010528b:	8b 40 60             	mov    0x60(%eax),%eax
f010528e:	89 04 24             	mov    %eax,(%esp)
f0105291:	e8 eb bf ff ff       	call   f0101281 <page_lookup>
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
f0105296:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010529a:	74 0c                	je     f01052a8 <syscall+0x4b8>
f010529c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010529f:	f6 02 02             	testb  $0x2,(%edx)
f01052a2:	0f 84 97 00 00 00    	je     f010533f <syscall+0x54f>
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f01052a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052ab:	8b 59 6c             	mov    0x6c(%ecx),%ebx
			return 0;
f01052ae:	ba 00 00 00 00       	mov    $0x0,%edx
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f01052b3:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01052b9:	0f 87 8c 00 00 00    	ja     f010534b <syscall+0x55b>
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
f01052bf:	8b 7d 18             	mov    0x18(%ebp),%edi
f01052c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01052c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01052ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052ce:	8b 41 60             	mov    0x60(%ecx),%eax
f01052d1:	89 04 24             	mov    %eax,(%esp)
f01052d4:	e8 ab c0 ff ff       	call   f0101384 <page_insert>
		if(r < 0)
f01052d9:	85 c0                	test   %eax,%eax
f01052db:	78 69                	js     f0105346 <syscall+0x556>
			return -E_NO_MEM;
			
		
	}

	env->env_ipc_value = value;
f01052dd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01052e3:	89 43 70             	mov    %eax,0x70(%ebx)
	env->env_ipc_from = curenv->env_id;
f01052e6:	e8 4e 13 00 00       	call   f0106639 <cpunum>
f01052eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ee:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01052f4:	8b 40 48             	mov    0x48(%eax),%eax
f01052f7:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_perm = perm;
f01052fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052fd:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105300:	89 48 78             	mov    %ecx,0x78(%eax)
	env->env_ipc_recving = 0;
f0105303:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_status = ENV_RUNNABLE;
f0105307:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f010530e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f0105315:	ba 00 00 00 00       	mov    $0x0,%edx
f010531a:	eb 2f                	jmp    f010534b <syscall+0x55b>
	// LAB : Your code here.
	struct Env *env=0;
	int r =0;
	pte_t * pte =0;
	if((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
f010531c:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0105321:	eb 28                	jmp    f010534b <syscall+0x55b>
	
	
	if(env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f0105323:	ba f9 ff ff ff       	mov    $0xfffffff9,%edx
f0105328:	eb 21                	jmp    f010534b <syscall+0x55b>
	

	if((int)srcva < UTOP){

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
			return -E_INVAL;
f010532a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010532f:	eb 1a                	jmp    f010534b <syscall+0x55b>
			
		if(  (perm & (~PTE_SYSCALL) ) !=0 )
			return  -E_INVAL;
f0105331:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105336:	eb 13                	jmp    f010534b <syscall+0x55b>
			
		if(  (perm & PTE_P) ==0 )
			return  -E_INVAL;
f0105338:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010533d:	eb 0c                	jmp    f010534b <syscall+0x55b>
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
			return  -E_INVAL;
f010533f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105344:	eb 05                	jmp    f010534b <syscall+0x55b>
			
		if((int)env->env_ipc_dstva >= UTOP)
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
		if(r < 0)
			return -E_NO_MEM;
f0105346:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
						break;
		case SYS_env_set_pgfault_upcall:
					ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
f010534b:	89 d0                	mov    %edx,%eax
						break;
f010534d:	eb 75                	jmp    f01053c4 <syscall+0x5d4>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB : Your code here.
	if((int)dstva >= UTOP)
f010534f:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105356:	76 17                	jbe    f010536f <syscall+0x57f>
		curenv->env_ipc_dstva = (void*)UTOP;
f0105358:	e8 dc 12 00 00       	call   f0106639 <cpunum>
f010535d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105360:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0105366:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
f010536d:	eb 1d                	jmp    f010538c <syscall+0x59c>
	else{
		if((int)dstva % PGSIZE != 0)
f010536f:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105376:	75 47                	jne    f01053bf <syscall+0x5cf>
			return -E_INVAL;
		else curenv->env_ipc_dstva = dstva;
f0105378:	e8 bc 12 00 00       	call   f0106639 <cpunum>
f010537d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105380:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0105386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105389:	89 58 6c             	mov    %ebx,0x6c(%eax)
	}
	
	curenv->env_status = ENV_NOT_RUNNABLE;
f010538c:	e8 a8 12 00 00       	call   f0106639 <cpunum>
f0105391:	6b c0 74             	imul   $0x74,%eax,%eax
f0105394:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f010539a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = 1;
f01053a1:	e8 93 12 00 00       	call   f0106639 <cpunum>
f01053a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01053a9:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01053af:	c6 40 68 01          	movb   $0x1,0x68(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01053b3:	e8 6f f9 ff ff       	call   f0104d27 <sched_yield>
					ret = sys_ipc_recv ( (void *)a1);
						break;

		default:
		//fang debug
			return -100;
f01053b8:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f01053bd:	eb 05                	jmp    f01053c4 <syscall+0x5d4>
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
						break;
		case  SYS_ipc_recv:	
					ret = sys_ipc_recv ( (void *)a1);
f01053bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		default:
		//fang debug
			return -100;
	}
	return ret;
}
f01053c4:	83 c4 2c             	add    $0x2c,%esp
f01053c7:	5b                   	pop    %ebx
f01053c8:	5e                   	pop    %esi
f01053c9:	5f                   	pop    %edi
f01053ca:	5d                   	pop    %ebp
f01053cb:	c3                   	ret    

f01053cc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01053cc:	55                   	push   %ebp
f01053cd:	89 e5                	mov    %esp,%ebp
f01053cf:	57                   	push   %edi
f01053d0:	56                   	push   %esi
f01053d1:	53                   	push   %ebx
f01053d2:	83 ec 14             	sub    $0x14,%esp
f01053d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01053db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01053de:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01053e1:	8b 1a                	mov    (%edx),%ebx
f01053e3:	8b 01                	mov    (%ecx),%eax
f01053e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01053e8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01053ef:	e9 88 00 00 00       	jmp    f010547c <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01053f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053f7:	01 d8                	add    %ebx,%eax
f01053f9:	89 c7                	mov    %eax,%edi
f01053fb:	c1 ef 1f             	shr    $0x1f,%edi
f01053fe:	01 c7                	add    %eax,%edi
f0105400:	d1 ff                	sar    %edi
f0105402:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105405:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105408:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010540b:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010540d:	eb 03                	jmp    f0105412 <stab_binsearch+0x46>
			m--;
f010540f:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105412:	39 c3                	cmp    %eax,%ebx
f0105414:	7f 1f                	jg     f0105435 <stab_binsearch+0x69>
f0105416:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010541a:	83 ea 0c             	sub    $0xc,%edx
f010541d:	39 f1                	cmp    %esi,%ecx
f010541f:	75 ee                	jne    f010540f <stab_binsearch+0x43>
f0105421:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105424:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105427:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010542a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010542e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105431:	76 18                	jbe    f010544b <stab_binsearch+0x7f>
f0105433:	eb 05                	jmp    f010543a <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105435:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105438:	eb 42                	jmp    f010547c <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010543a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010543d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010543f:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105442:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105449:	eb 31                	jmp    f010547c <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010544b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010544e:	73 17                	jae    f0105467 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105450:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105453:	83 e8 01             	sub    $0x1,%eax
f0105456:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105459:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010545c:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010545e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105465:	eb 15                	jmp    f010547c <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010546a:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010546d:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010546f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105473:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105475:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010547c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010547f:	0f 8e 6f ff ff ff    	jle    f01053f4 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105485:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105489:	75 0f                	jne    f010549a <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010548b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010548e:	8b 00                	mov    (%eax),%eax
f0105490:	83 e8 01             	sub    $0x1,%eax
f0105493:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105496:	89 07                	mov    %eax,(%edi)
f0105498:	eb 2c                	jmp    f01054c6 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010549a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010549d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010549f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054a2:	8b 0f                	mov    (%edi),%ecx
f01054a4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054a7:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01054aa:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054ad:	eb 03                	jmp    f01054b2 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01054af:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054b2:	39 c8                	cmp    %ecx,%eax
f01054b4:	7e 0b                	jle    f01054c1 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01054b6:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01054ba:	83 ea 0c             	sub    $0xc,%edx
f01054bd:	39 f3                	cmp    %esi,%ebx
f01054bf:	75 ee                	jne    f01054af <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01054c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054c4:	89 07                	mov    %eax,(%edi)
	}
}
f01054c6:	83 c4 14             	add    $0x14,%esp
f01054c9:	5b                   	pop    %ebx
f01054ca:	5e                   	pop    %esi
f01054cb:	5f                   	pop    %edi
f01054cc:	5d                   	pop    %ebp
f01054cd:	c3                   	ret    

f01054ce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01054ce:	55                   	push   %ebp
f01054cf:	89 e5                	mov    %esp,%ebp
f01054d1:	57                   	push   %edi
f01054d2:	56                   	push   %esi
f01054d3:	53                   	push   %ebx
f01054d4:	83 ec 3c             	sub    $0x3c,%esp
f01054d7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01054da:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01054dd:	c7 06 c4 83 10 f0    	movl   $0xf01083c4,(%esi)
	info->eip_line = 0;
f01054e3:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01054ea:	c7 46 08 c4 83 10 f0 	movl   $0xf01083c4,0x8(%esi)
	info->eip_fn_namelen = 9;
f01054f1:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01054f8:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01054fb:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105502:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105508:	0f 87 c1 00 00 00    	ja     f01055cf <debuginfo_eip+0x101>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB : Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010550e:	e8 26 11 00 00       	call   f0106639 <cpunum>
f0105513:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010551a:	00 
f010551b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105522:	00 
f0105523:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010552a:	00 
f010552b:	6b c0 74             	imul   $0x74,%eax,%eax
f010552e:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0105534:	89 04 24             	mov    %eax,(%esp)
f0105537:	e8 09 e0 ff ff       	call   f0103545 <user_mem_check>
f010553c:	85 c0                	test   %eax,%eax
f010553e:	0f 85 e1 01 00 00    	jne    f0105725 <debuginfo_eip+0x257>
			return -1;
		stabs = usd->stabs;
f0105544:	a1 00 00 20 00       	mov    0x200000,%eax
f0105549:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010554c:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0105552:	a1 08 00 20 00       	mov    0x200008,%eax
f0105557:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f010555a:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105560:	89 55 cc             	mov    %edx,-0x34(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3 Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105563:	e8 d1 10 00 00       	call   f0106639 <cpunum>
f0105568:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010556f:	00 
f0105570:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0105577:	00 
f0105578:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010557b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010557f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105582:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f0105588:	89 04 24             	mov    %eax,(%esp)
f010558b:	e8 b5 df ff ff       	call   f0103545 <user_mem_check>
f0105590:	85 c0                	test   %eax,%eax
f0105592:	0f 85 94 01 00 00    	jne    f010572c <debuginfo_eip+0x25e>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105598:	e8 9c 10 00 00       	call   f0106639 <cpunum>
f010559d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01055a4:	00 
f01055a5:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01055a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01055ab:	29 ca                	sub    %ecx,%edx
f01055ad:	89 54 24 08          	mov    %edx,0x8(%esp)
f01055b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01055b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01055b8:	8b 80 28 30 1e f0    	mov    -0xfe1cfd8(%eax),%eax
f01055be:	89 04 24             	mov    %eax,(%esp)
f01055c1:	e8 7f df ff ff       	call   f0103545 <user_mem_check>
f01055c6:	85 c0                	test   %eax,%eax
f01055c8:	74 1f                	je     f01055e9 <debuginfo_eip+0x11b>
f01055ca:	e9 64 01 00 00       	jmp    f0105733 <debuginfo_eip+0x265>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01055cf:	c7 45 cc 5b 68 11 f0 	movl   $0xf011685b,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01055d6:	c7 45 d0 4d 31 11 f0 	movl   $0xf011314d,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01055dd:	bb 4c 31 11 f0       	mov    $0xf011314c,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055e2:	c7 45 d4 70 89 10 f0 	movl   $0xf0108970,-0x2c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01055ec:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01055ef:	0f 83 45 01 00 00    	jae    f010573a <debuginfo_eip+0x26c>
f01055f5:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01055f9:	0f 85 42 01 00 00    	jne    f0105741 <debuginfo_eip+0x273>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105606:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0105609:	c1 fb 02             	sar    $0x2,%ebx
f010560c:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0105612:	83 e8 01             	sub    $0x1,%eax
f0105615:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105618:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010561c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105623:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105626:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105629:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010562c:	89 d8                	mov    %ebx,%eax
f010562e:	e8 99 fd ff ff       	call   f01053cc <stab_binsearch>
	if (lfile == 0)
f0105633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105636:	85 c0                	test   %eax,%eax
f0105638:	0f 84 0a 01 00 00    	je     f0105748 <debuginfo_eip+0x27a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010563e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105641:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105644:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105647:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010564b:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105652:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105655:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105658:	89 d8                	mov    %ebx,%eax
f010565a:	e8 6d fd ff ff       	call   f01053cc <stab_binsearch>

	if (lfun <= rfun) {
f010565f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105662:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0105665:	7f 23                	jg     f010568a <debuginfo_eip+0x1bc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105667:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010566a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010566d:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105670:	8b 10                	mov    (%eax),%edx
f0105672:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105675:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f0105678:	39 ca                	cmp    %ecx,%edx
f010567a:	73 06                	jae    f0105682 <debuginfo_eip+0x1b4>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010567c:	03 55 d0             	add    -0x30(%ebp),%edx
f010567f:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105682:	8b 40 08             	mov    0x8(%eax),%eax
f0105685:	89 46 10             	mov    %eax,0x10(%esi)
f0105688:	eb 06                	jmp    f0105690 <debuginfo_eip+0x1c2>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010568a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010568d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105690:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105697:	00 
f0105698:	8b 46 08             	mov    0x8(%esi),%eax
f010569b:	89 04 24             	mov    %eax,(%esp)
f010569e:	e8 28 09 00 00       	call   f0105fcb <strfind>
f01056a3:	2b 46 08             	sub    0x8(%esi),%eax
f01056a6:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056ac:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01056af:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01056b2:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01056b5:	eb 06                	jmp    f01056bd <debuginfo_eip+0x1ef>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01056b7:	83 eb 01             	sub    $0x1,%ebx
f01056ba:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056bd:	39 fb                	cmp    %edi,%ebx
f01056bf:	7c 2c                	jl     f01056ed <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f01056c1:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01056c5:	80 fa 84             	cmp    $0x84,%dl
f01056c8:	74 0b                	je     f01056d5 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01056ca:	80 fa 64             	cmp    $0x64,%dl
f01056cd:	75 e8                	jne    f01056b7 <debuginfo_eip+0x1e9>
f01056cf:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01056d3:	74 e2                	je     f01056b7 <debuginfo_eip+0x1e9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01056d5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01056d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01056db:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01056de:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01056e1:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01056e4:	39 d0                	cmp    %edx,%eax
f01056e6:	73 05                	jae    f01056ed <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01056e8:	03 45 d0             	add    -0x30(%ebp),%eax
f01056eb:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01056ed:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01056f0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01056f3:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01056f8:	39 cb                	cmp    %ecx,%ebx
f01056fa:	7d 58                	jge    f0105754 <debuginfo_eip+0x286>
		for (lline = lfun + 1;
f01056fc:	8d 53 01             	lea    0x1(%ebx),%edx
f01056ff:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105702:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105705:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105708:	eb 07                	jmp    f0105711 <debuginfo_eip+0x243>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010570a:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010570e:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105711:	39 ca                	cmp    %ecx,%edx
f0105713:	74 3a                	je     f010574f <debuginfo_eip+0x281>
f0105715:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105718:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f010571c:	74 ec                	je     f010570a <debuginfo_eip+0x23c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010571e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105723:	eb 2f                	jmp    f0105754 <debuginfo_eip+0x286>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB : Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0105725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010572a:	eb 28                	jmp    f0105754 <debuginfo_eip+0x286>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3 Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f010572c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105731:	eb 21                	jmp    f0105754 <debuginfo_eip+0x286>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0105733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105738:	eb 1a                	jmp    f0105754 <debuginfo_eip+0x286>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010573a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010573f:	eb 13                	jmp    f0105754 <debuginfo_eip+0x286>
f0105741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105746:	eb 0c                	jmp    f0105754 <debuginfo_eip+0x286>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010574d:	eb 05                	jmp    f0105754 <debuginfo_eip+0x286>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010574f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105754:	83 c4 3c             	add    $0x3c,%esp
f0105757:	5b                   	pop    %ebx
f0105758:	5e                   	pop    %esi
f0105759:	5f                   	pop    %edi
f010575a:	5d                   	pop    %ebp
f010575b:	c3                   	ret    
f010575c:	66 90                	xchg   %ax,%ax
f010575e:	66 90                	xchg   %ax,%ax

f0105760 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105760:	55                   	push   %ebp
f0105761:	89 e5                	mov    %esp,%ebp
f0105763:	57                   	push   %edi
f0105764:	56                   	push   %esi
f0105765:	53                   	push   %ebx
f0105766:	83 ec 3c             	sub    $0x3c,%esp
f0105769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010576c:	89 d7                	mov    %edx,%edi
f010576e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105771:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105774:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105777:	89 c3                	mov    %eax,%ebx
f0105779:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010577c:	8b 45 10             	mov    0x10(%ebp),%eax
f010577f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105782:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105787:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010578a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010578d:	39 d9                	cmp    %ebx,%ecx
f010578f:	72 05                	jb     f0105796 <printnum+0x36>
f0105791:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105794:	77 69                	ja     f01057ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105796:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105799:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010579d:	83 ee 01             	sub    $0x1,%esi
f01057a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01057a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057a8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01057ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01057b0:	89 c3                	mov    %eax,%ebx
f01057b2:	89 d6                	mov    %edx,%esi
f01057b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01057b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01057ba:	89 54 24 08          	mov    %edx,0x8(%esp)
f01057be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01057c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057c5:	89 04 24             	mov    %eax,(%esp)
f01057c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01057cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057cf:	e8 ac 12 00 00       	call   f0106a80 <__udivdi3>
f01057d4:	89 d9                	mov    %ebx,%ecx
f01057d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01057da:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01057de:	89 04 24             	mov    %eax,(%esp)
f01057e1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01057e5:	89 fa                	mov    %edi,%edx
f01057e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057ea:	e8 71 ff ff ff       	call   f0105760 <printnum>
f01057ef:	eb 1b                	jmp    f010580c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01057f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057f5:	8b 45 18             	mov    0x18(%ebp),%eax
f01057f8:	89 04 24             	mov    %eax,(%esp)
f01057fb:	ff d3                	call   *%ebx
f01057fd:	eb 03                	jmp    f0105802 <printnum+0xa2>
f01057ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105802:	83 ee 01             	sub    $0x1,%esi
f0105805:	85 f6                	test   %esi,%esi
f0105807:	7f e8                	jg     f01057f1 <printnum+0x91>
f0105809:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010580c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105810:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105814:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105817:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010581a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010581e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105822:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105825:	89 04 24             	mov    %eax,(%esp)
f0105828:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010582b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010582f:	e8 7c 13 00 00       	call   f0106bb0 <__umoddi3>
f0105834:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105838:	0f be 80 ce 83 10 f0 	movsbl -0xfef7c32(%eax),%eax
f010583f:	89 04 24             	mov    %eax,(%esp)
f0105842:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105845:	ff d0                	call   *%eax
}
f0105847:	83 c4 3c             	add    $0x3c,%esp
f010584a:	5b                   	pop    %ebx
f010584b:	5e                   	pop    %esi
f010584c:	5f                   	pop    %edi
f010584d:	5d                   	pop    %ebp
f010584e:	c3                   	ret    

f010584f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010584f:	55                   	push   %ebp
f0105850:	89 e5                	mov    %esp,%ebp
f0105852:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105855:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105859:	8b 10                	mov    (%eax),%edx
f010585b:	3b 50 04             	cmp    0x4(%eax),%edx
f010585e:	73 0a                	jae    f010586a <sprintputch+0x1b>
		*b->buf++ = ch;
f0105860:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105863:	89 08                	mov    %ecx,(%eax)
f0105865:	8b 45 08             	mov    0x8(%ebp),%eax
f0105868:	88 02                	mov    %al,(%edx)
}
f010586a:	5d                   	pop    %ebp
f010586b:	c3                   	ret    

f010586c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010586c:	55                   	push   %ebp
f010586d:	89 e5                	mov    %esp,%ebp
f010586f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105872:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105875:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105879:	8b 45 10             	mov    0x10(%ebp),%eax
f010587c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105880:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105883:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105887:	8b 45 08             	mov    0x8(%ebp),%eax
f010588a:	89 04 24             	mov    %eax,(%esp)
f010588d:	e8 02 00 00 00       	call   f0105894 <vprintfmt>
	va_end(ap);
}
f0105892:	c9                   	leave  
f0105893:	c3                   	ret    

f0105894 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105894:	55                   	push   %ebp
f0105895:	89 e5                	mov    %esp,%ebp
f0105897:	57                   	push   %edi
f0105898:	56                   	push   %esi
f0105899:	53                   	push   %ebx
f010589a:	83 ec 3c             	sub    $0x3c,%esp
f010589d:	8b 75 08             	mov    0x8(%ebp),%esi
f01058a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058a3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01058a6:	eb 11                	jmp    f01058b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01058a8:	85 c0                	test   %eax,%eax
f01058aa:	0f 84 48 04 00 00    	je     f0105cf8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01058b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058b4:	89 04 24             	mov    %eax,(%esp)
f01058b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01058b9:	83 c7 01             	add    $0x1,%edi
f01058bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01058c0:	83 f8 25             	cmp    $0x25,%eax
f01058c3:	75 e3                	jne    f01058a8 <vprintfmt+0x14>
f01058c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01058c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01058d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01058d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01058de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058e3:	eb 1f                	jmp    f0105904 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01058e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01058ec:	eb 16                	jmp    f0105904 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01058f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01058f5:	eb 0d                	jmp    f0105904 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01058f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01058fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01058fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105904:	8d 47 01             	lea    0x1(%edi),%eax
f0105907:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010590a:	0f b6 17             	movzbl (%edi),%edx
f010590d:	0f b6 c2             	movzbl %dl,%eax
f0105910:	83 ea 23             	sub    $0x23,%edx
f0105913:	80 fa 55             	cmp    $0x55,%dl
f0105916:	0f 87 bf 03 00 00    	ja     f0105cdb <vprintfmt+0x447>
f010591c:	0f b6 d2             	movzbl %dl,%edx
f010591f:	ff 24 95 20 85 10 f0 	jmp    *-0xfef7ae0(,%edx,4)
f0105926:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105929:	ba 00 00 00 00       	mov    $0x0,%edx
f010592e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105931:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105934:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105938:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010593b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010593e:	83 f9 09             	cmp    $0x9,%ecx
f0105941:	77 3c                	ja     f010597f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105943:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105946:	eb e9                	jmp    f0105931 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105948:	8b 45 14             	mov    0x14(%ebp),%eax
f010594b:	8b 00                	mov    (%eax),%eax
f010594d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105950:	8b 45 14             	mov    0x14(%ebp),%eax
f0105953:	8d 40 04             	lea    0x4(%eax),%eax
f0105956:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010595c:	eb 27                	jmp    f0105985 <vprintfmt+0xf1>
f010595e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105961:	85 d2                	test   %edx,%edx
f0105963:	b8 00 00 00 00       	mov    $0x0,%eax
f0105968:	0f 49 c2             	cmovns %edx,%eax
f010596b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010596e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105971:	eb 91                	jmp    f0105904 <vprintfmt+0x70>
f0105973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105976:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010597d:	eb 85                	jmp    f0105904 <vprintfmt+0x70>
f010597f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105982:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105985:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105989:	0f 89 75 ff ff ff    	jns    f0105904 <vprintfmt+0x70>
f010598f:	e9 63 ff ff ff       	jmp    f01058f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105994:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010599a:	e9 65 ff ff ff       	jmp    f0105904 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010599f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01059a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01059a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059aa:	8b 00                	mov    (%eax),%eax
f01059ac:	89 04 24             	mov    %eax,(%esp)
f01059af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01059b4:	e9 00 ff ff ff       	jmp    f01058b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01059bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01059c0:	8b 00                	mov    (%eax),%eax
f01059c2:	99                   	cltd   
f01059c3:	31 d0                	xor    %edx,%eax
f01059c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01059c7:	83 f8 0f             	cmp    $0xf,%eax
f01059ca:	7f 0b                	jg     f01059d7 <vprintfmt+0x143>
f01059cc:	8b 14 85 80 86 10 f0 	mov    -0xfef7980(,%eax,4),%edx
f01059d3:	85 d2                	test   %edx,%edx
f01059d5:	75 20                	jne    f01059f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f01059d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01059db:	c7 44 24 08 e6 83 10 	movl   $0xf01083e6,0x8(%esp)
f01059e2:	f0 
f01059e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059e7:	89 34 24             	mov    %esi,(%esp)
f01059ea:	e8 7d fe ff ff       	call   f010586c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01059f2:	e9 c2 fe ff ff       	jmp    f01058b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f01059f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01059fb:	c7 44 24 08 c5 7b 10 	movl   $0xf0107bc5,0x8(%esp)
f0105a02:	f0 
f0105a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a07:	89 34 24             	mov    %esi,(%esp)
f0105a0a:	e8 5d fe ff ff       	call   f010586c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a12:	e9 a2 fe ff ff       	jmp    f01058b9 <vprintfmt+0x25>
f0105a17:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a1a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105a1d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a20:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105a23:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105a27:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105a29:	85 ff                	test   %edi,%edi
f0105a2b:	b8 df 83 10 f0       	mov    $0xf01083df,%eax
f0105a30:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105a33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105a37:	0f 84 92 00 00 00    	je     f0105acf <vprintfmt+0x23b>
f0105a3d:	85 c9                	test   %ecx,%ecx
f0105a3f:	0f 8e 98 00 00 00    	jle    f0105add <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a49:	89 3c 24             	mov    %edi,(%esp)
f0105a4c:	e8 27 04 00 00       	call   f0105e78 <strnlen>
f0105a51:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105a54:	29 c1                	sub    %eax,%ecx
f0105a56:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0105a59:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a60:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105a63:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a65:	eb 0f                	jmp    f0105a76 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0105a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a6e:	89 04 24             	mov    %eax,(%esp)
f0105a71:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a73:	83 ef 01             	sub    $0x1,%edi
f0105a76:	85 ff                	test   %edi,%edi
f0105a78:	7f ed                	jg     f0105a67 <vprintfmt+0x1d3>
f0105a7a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105a7d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105a80:	85 c9                	test   %ecx,%ecx
f0105a82:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a87:	0f 49 c1             	cmovns %ecx,%eax
f0105a8a:	29 c1                	sub    %eax,%ecx
f0105a8c:	89 75 08             	mov    %esi,0x8(%ebp)
f0105a8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105a92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a95:	89 cb                	mov    %ecx,%ebx
f0105a97:	eb 50                	jmp    f0105ae9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a99:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105a9d:	74 1e                	je     f0105abd <vprintfmt+0x229>
f0105a9f:	0f be d2             	movsbl %dl,%edx
f0105aa2:	83 ea 20             	sub    $0x20,%edx
f0105aa5:	83 fa 5e             	cmp    $0x5e,%edx
f0105aa8:	76 13                	jbe    f0105abd <vprintfmt+0x229>
					putch('?', putdat);
f0105aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105aad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ab1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105ab8:	ff 55 08             	call   *0x8(%ebp)
f0105abb:	eb 0d                	jmp    f0105aca <vprintfmt+0x236>
				else
					putch(ch, putdat);
f0105abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ac0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ac4:	89 04 24             	mov    %eax,(%esp)
f0105ac7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105aca:	83 eb 01             	sub    $0x1,%ebx
f0105acd:	eb 1a                	jmp    f0105ae9 <vprintfmt+0x255>
f0105acf:	89 75 08             	mov    %esi,0x8(%ebp)
f0105ad2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105ad5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105ad8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105adb:	eb 0c                	jmp    f0105ae9 <vprintfmt+0x255>
f0105add:	89 75 08             	mov    %esi,0x8(%ebp)
f0105ae0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105ae3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105ae6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105ae9:	83 c7 01             	add    $0x1,%edi
f0105aec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0105af0:	0f be c2             	movsbl %dl,%eax
f0105af3:	85 c0                	test   %eax,%eax
f0105af5:	74 25                	je     f0105b1c <vprintfmt+0x288>
f0105af7:	85 f6                	test   %esi,%esi
f0105af9:	78 9e                	js     f0105a99 <vprintfmt+0x205>
f0105afb:	83 ee 01             	sub    $0x1,%esi
f0105afe:	79 99                	jns    f0105a99 <vprintfmt+0x205>
f0105b00:	89 df                	mov    %ebx,%edi
f0105b02:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b08:	eb 1a                	jmp    f0105b24 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105b0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b0e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105b15:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105b17:	83 ef 01             	sub    $0x1,%edi
f0105b1a:	eb 08                	jmp    f0105b24 <vprintfmt+0x290>
f0105b1c:	89 df                	mov    %ebx,%edi
f0105b1e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b24:	85 ff                	test   %edi,%edi
f0105b26:	7f e2                	jg     f0105b0a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105b2b:	e9 89 fd ff ff       	jmp    f01058b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105b30:	83 f9 01             	cmp    $0x1,%ecx
f0105b33:	7e 19                	jle    f0105b4e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0105b35:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b38:	8b 50 04             	mov    0x4(%eax),%edx
f0105b3b:	8b 00                	mov    (%eax),%eax
f0105b3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b40:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105b43:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b46:	8d 40 08             	lea    0x8(%eax),%eax
f0105b49:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b4c:	eb 38                	jmp    f0105b86 <vprintfmt+0x2f2>
	else if (lflag)
f0105b4e:	85 c9                	test   %ecx,%ecx
f0105b50:	74 1b                	je     f0105b6d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0105b52:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b55:	8b 00                	mov    (%eax),%eax
f0105b57:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b5a:	89 c1                	mov    %eax,%ecx
f0105b5c:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b5f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b62:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b65:	8d 40 04             	lea    0x4(%eax),%eax
f0105b68:	89 45 14             	mov    %eax,0x14(%ebp)
f0105b6b:	eb 19                	jmp    f0105b86 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f0105b6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b70:	8b 00                	mov    (%eax),%eax
f0105b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b75:	89 c1                	mov    %eax,%ecx
f0105b77:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b7a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b80:	8d 40 04             	lea    0x4(%eax),%eax
f0105b83:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105b86:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b89:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105b8c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105b91:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b95:	0f 89 04 01 00 00    	jns    f0105c9f <vprintfmt+0x40b>
				putch('-', putdat);
f0105b9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b9f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105ba6:	ff d6                	call   *%esi
				num = -(long long) num;
f0105ba8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105bab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105bae:	f7 da                	neg    %edx
f0105bb0:	83 d1 00             	adc    $0x0,%ecx
f0105bb3:	f7 d9                	neg    %ecx
f0105bb5:	e9 e5 00 00 00       	jmp    f0105c9f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105bba:	83 f9 01             	cmp    $0x1,%ecx
f0105bbd:	7e 10                	jle    f0105bcf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f0105bbf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bc2:	8b 10                	mov    (%eax),%edx
f0105bc4:	8b 48 04             	mov    0x4(%eax),%ecx
f0105bc7:	8d 40 08             	lea    0x8(%eax),%eax
f0105bca:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bcd:	eb 26                	jmp    f0105bf5 <vprintfmt+0x361>
	else if (lflag)
f0105bcf:	85 c9                	test   %ecx,%ecx
f0105bd1:	74 12                	je     f0105be5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0105bd3:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bd6:	8b 10                	mov    (%eax),%edx
f0105bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105bdd:	8d 40 04             	lea    0x4(%eax),%eax
f0105be0:	89 45 14             	mov    %eax,0x14(%ebp)
f0105be3:	eb 10                	jmp    f0105bf5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0105be5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be8:	8b 10                	mov    (%eax),%edx
f0105bea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105bef:	8d 40 04             	lea    0x4(%eax),%eax
f0105bf2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105bf5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0105bfa:	e9 a0 00 00 00       	jmp    f0105c9f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105bff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c03:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c0a:	ff d6                	call   *%esi
			putch('X', putdat);
f0105c0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c10:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c17:	ff d6                	call   *%esi
			putch('X', putdat);
f0105c19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c1d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c24:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105c29:	e9 8b fc ff ff       	jmp    f01058b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f0105c2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105c39:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c3f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105c46:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105c48:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c4b:	8b 10                	mov    (%eax),%edx
f0105c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0105c52:	8d 40 04             	lea    0x4(%eax),%eax
f0105c55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105c58:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f0105c5d:	eb 40                	jmp    f0105c9f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105c5f:	83 f9 01             	cmp    $0x1,%ecx
f0105c62:	7e 10                	jle    f0105c74 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0105c64:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c67:	8b 10                	mov    (%eax),%edx
f0105c69:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c6c:	8d 40 08             	lea    0x8(%eax),%eax
f0105c6f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105c72:	eb 26                	jmp    f0105c9a <vprintfmt+0x406>
	else if (lflag)
f0105c74:	85 c9                	test   %ecx,%ecx
f0105c76:	74 12                	je     f0105c8a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0105c78:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c7b:	8b 10                	mov    (%eax),%edx
f0105c7d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c82:	8d 40 04             	lea    0x4(%eax),%eax
f0105c85:	89 45 14             	mov    %eax,0x14(%ebp)
f0105c88:	eb 10                	jmp    f0105c9a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f0105c8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c8d:	8b 10                	mov    (%eax),%edx
f0105c8f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c94:	8d 40 04             	lea    0x4(%eax),%eax
f0105c97:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105c9a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105c9f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105ca3:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105cae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105cb2:	89 14 24             	mov    %edx,(%esp)
f0105cb5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105cb9:	89 da                	mov    %ebx,%edx
f0105cbb:	89 f0                	mov    %esi,%eax
f0105cbd:	e8 9e fa ff ff       	call   f0105760 <printnum>
			break;
f0105cc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105cc5:	e9 ef fb ff ff       	jmp    f01058b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105cca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cce:	89 04 24             	mov    %eax,(%esp)
f0105cd1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105cd6:	e9 de fb ff ff       	jmp    f01058b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105cdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cdf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105ce6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105ce8:	eb 03                	jmp    f0105ced <vprintfmt+0x459>
f0105cea:	83 ef 01             	sub    $0x1,%edi
f0105ced:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105cf1:	75 f7                	jne    f0105cea <vprintfmt+0x456>
f0105cf3:	e9 c1 fb ff ff       	jmp    f01058b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0105cf8:	83 c4 3c             	add    $0x3c,%esp
f0105cfb:	5b                   	pop    %ebx
f0105cfc:	5e                   	pop    %esi
f0105cfd:	5f                   	pop    %edi
f0105cfe:	5d                   	pop    %ebp
f0105cff:	c3                   	ret    

f0105d00 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d00:	55                   	push   %ebp
f0105d01:	89 e5                	mov    %esp,%ebp
f0105d03:	83 ec 28             	sub    $0x28,%esp
f0105d06:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d09:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d0f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d13:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d1d:	85 c0                	test   %eax,%eax
f0105d1f:	74 30                	je     f0105d51 <vsnprintf+0x51>
f0105d21:	85 d2                	test   %edx,%edx
f0105d23:	7e 2c                	jle    f0105d51 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d25:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d28:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d33:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d3a:	c7 04 24 4f 58 10 f0 	movl   $0xf010584f,(%esp)
f0105d41:	e8 4e fb ff ff       	call   f0105894 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d46:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d49:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d4f:	eb 05                	jmp    f0105d56 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105d51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105d56:	c9                   	leave  
f0105d57:	c3                   	ret    

f0105d58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d58:	55                   	push   %ebp
f0105d59:	89 e5                	mov    %esp,%ebp
f0105d5b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d5e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d65:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d68:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d73:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d76:	89 04 24             	mov    %eax,(%esp)
f0105d79:	e8 82 ff ff ff       	call   f0105d00 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105d7e:	c9                   	leave  
f0105d7f:	c3                   	ret    

f0105d80 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105d80:	55                   	push   %ebp
f0105d81:	89 e5                	mov    %esp,%ebp
f0105d83:	57                   	push   %edi
f0105d84:	56                   	push   %esi
f0105d85:	53                   	push   %ebx
f0105d86:	83 ec 1c             	sub    $0x1c,%esp
f0105d89:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105d8c:	85 c0                	test   %eax,%eax
f0105d8e:	74 10                	je     f0105da0 <readline+0x20>
		cprintf("%s", prompt);
f0105d90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d94:	c7 04 24 c5 7b 10 f0 	movl   $0xf0107bc5,(%esp)
f0105d9b:	e8 21 e2 ff ff       	call   f0103fc1 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105da0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105da7:	e8 0c aa ff ff       	call   f01007b8 <iscons>
f0105dac:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105dae:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105db3:	e8 ef a9 ff ff       	call   f01007a7 <getchar>
f0105db8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105dba:	85 c0                	test   %eax,%eax
f0105dbc:	79 25                	jns    f0105de3 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105dbe:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105dc3:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105dc6:	0f 84 89 00 00 00    	je     f0105e55 <readline+0xd5>
				cprintf("read error: %e\n", c);
f0105dcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105dd0:	c7 04 24 df 86 10 f0 	movl   $0xf01086df,(%esp)
f0105dd7:	e8 e5 e1 ff ff       	call   f0103fc1 <cprintf>
			return NULL;
f0105ddc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105de1:	eb 72                	jmp    f0105e55 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105de3:	83 f8 7f             	cmp    $0x7f,%eax
f0105de6:	74 05                	je     f0105ded <readline+0x6d>
f0105de8:	83 f8 08             	cmp    $0x8,%eax
f0105deb:	75 1a                	jne    f0105e07 <readline+0x87>
f0105ded:	85 f6                	test   %esi,%esi
f0105def:	90                   	nop
f0105df0:	7e 15                	jle    f0105e07 <readline+0x87>
			if (echoing)
f0105df2:	85 ff                	test   %edi,%edi
f0105df4:	74 0c                	je     f0105e02 <readline+0x82>
				cputchar('\b');
f0105df6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105dfd:	e8 95 a9 ff ff       	call   f0100797 <cputchar>
			i--;
f0105e02:	83 ee 01             	sub    $0x1,%esi
f0105e05:	eb ac                	jmp    f0105db3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e07:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e0d:	7f 1c                	jg     f0105e2b <readline+0xab>
f0105e0f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e12:	7e 17                	jle    f0105e2b <readline+0xab>
			if (echoing)
f0105e14:	85 ff                	test   %edi,%edi
f0105e16:	74 08                	je     f0105e20 <readline+0xa0>
				cputchar(c);
f0105e18:	89 1c 24             	mov    %ebx,(%esp)
f0105e1b:	e8 77 a9 ff ff       	call   f0100797 <cputchar>
			buf[i++] = c;
f0105e20:	88 9e 80 2a 1e f0    	mov    %bl,-0xfe1d580(%esi)
f0105e26:	8d 76 01             	lea    0x1(%esi),%esi
f0105e29:	eb 88                	jmp    f0105db3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105e2b:	83 fb 0d             	cmp    $0xd,%ebx
f0105e2e:	74 09                	je     f0105e39 <readline+0xb9>
f0105e30:	83 fb 0a             	cmp    $0xa,%ebx
f0105e33:	0f 85 7a ff ff ff    	jne    f0105db3 <readline+0x33>
			if (echoing)
f0105e39:	85 ff                	test   %edi,%edi
f0105e3b:	74 0c                	je     f0105e49 <readline+0xc9>
				cputchar('\n');
f0105e3d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105e44:	e8 4e a9 ff ff       	call   f0100797 <cputchar>
			buf[i] = 0;
f0105e49:	c6 86 80 2a 1e f0 00 	movb   $0x0,-0xfe1d580(%esi)
			return buf;
f0105e50:	b8 80 2a 1e f0       	mov    $0xf01e2a80,%eax
		}
	}
}
f0105e55:	83 c4 1c             	add    $0x1c,%esp
f0105e58:	5b                   	pop    %ebx
f0105e59:	5e                   	pop    %esi
f0105e5a:	5f                   	pop    %edi
f0105e5b:	5d                   	pop    %ebp
f0105e5c:	c3                   	ret    
f0105e5d:	66 90                	xchg   %ax,%ax
f0105e5f:	90                   	nop

f0105e60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e60:	55                   	push   %ebp
f0105e61:	89 e5                	mov    %esp,%ebp
f0105e63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e66:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e6b:	eb 03                	jmp    f0105e70 <strlen+0x10>
		n++;
f0105e6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105e74:	75 f7                	jne    f0105e6d <strlen+0xd>
		n++;
	return n;
}
f0105e76:	5d                   	pop    %ebp
f0105e77:	c3                   	ret    

f0105e78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105e78:	55                   	push   %ebp
f0105e79:	89 e5                	mov    %esp,%ebp
f0105e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e81:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e86:	eb 03                	jmp    f0105e8b <strnlen+0x13>
		n++;
f0105e88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e8b:	39 d0                	cmp    %edx,%eax
f0105e8d:	74 06                	je     f0105e95 <strnlen+0x1d>
f0105e8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105e93:	75 f3                	jne    f0105e88 <strnlen+0x10>
		n++;
	return n;
}
f0105e95:	5d                   	pop    %ebp
f0105e96:	c3                   	ret    

f0105e97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105e97:	55                   	push   %ebp
f0105e98:	89 e5                	mov    %esp,%ebp
f0105e9a:	53                   	push   %ebx
f0105e9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ea1:	89 c2                	mov    %eax,%edx
f0105ea3:	83 c2 01             	add    $0x1,%edx
f0105ea6:	83 c1 01             	add    $0x1,%ecx
f0105ea9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105ead:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105eb0:	84 db                	test   %bl,%bl
f0105eb2:	75 ef                	jne    f0105ea3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105eb4:	5b                   	pop    %ebx
f0105eb5:	5d                   	pop    %ebp
f0105eb6:	c3                   	ret    

f0105eb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105eb7:	55                   	push   %ebp
f0105eb8:	89 e5                	mov    %esp,%ebp
f0105eba:	53                   	push   %ebx
f0105ebb:	83 ec 08             	sub    $0x8,%esp
f0105ebe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ec1:	89 1c 24             	mov    %ebx,(%esp)
f0105ec4:	e8 97 ff ff ff       	call   f0105e60 <strlen>
	strcpy(dst + len, src);
f0105ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ecc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ed0:	01 d8                	add    %ebx,%eax
f0105ed2:	89 04 24             	mov    %eax,(%esp)
f0105ed5:	e8 bd ff ff ff       	call   f0105e97 <strcpy>
	return dst;
}
f0105eda:	89 d8                	mov    %ebx,%eax
f0105edc:	83 c4 08             	add    $0x8,%esp
f0105edf:	5b                   	pop    %ebx
f0105ee0:	5d                   	pop    %ebp
f0105ee1:	c3                   	ret    

f0105ee2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ee2:	55                   	push   %ebp
f0105ee3:	89 e5                	mov    %esp,%ebp
f0105ee5:	56                   	push   %esi
f0105ee6:	53                   	push   %ebx
f0105ee7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105eed:	89 f3                	mov    %esi,%ebx
f0105eef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ef2:	89 f2                	mov    %esi,%edx
f0105ef4:	eb 0f                	jmp    f0105f05 <strncpy+0x23>
		*dst++ = *src;
f0105ef6:	83 c2 01             	add    $0x1,%edx
f0105ef9:	0f b6 01             	movzbl (%ecx),%eax
f0105efc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105eff:	80 39 01             	cmpb   $0x1,(%ecx)
f0105f02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f05:	39 da                	cmp    %ebx,%edx
f0105f07:	75 ed                	jne    f0105ef6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105f09:	89 f0                	mov    %esi,%eax
f0105f0b:	5b                   	pop    %ebx
f0105f0c:	5e                   	pop    %esi
f0105f0d:	5d                   	pop    %ebp
f0105f0e:	c3                   	ret    

f0105f0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f0f:	55                   	push   %ebp
f0105f10:	89 e5                	mov    %esp,%ebp
f0105f12:	56                   	push   %esi
f0105f13:	53                   	push   %ebx
f0105f14:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f17:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105f1d:	89 f0                	mov    %esi,%eax
f0105f1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f23:	85 c9                	test   %ecx,%ecx
f0105f25:	75 0b                	jne    f0105f32 <strlcpy+0x23>
f0105f27:	eb 1d                	jmp    f0105f46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f29:	83 c0 01             	add    $0x1,%eax
f0105f2c:	83 c2 01             	add    $0x1,%edx
f0105f2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105f32:	39 d8                	cmp    %ebx,%eax
f0105f34:	74 0b                	je     f0105f41 <strlcpy+0x32>
f0105f36:	0f b6 0a             	movzbl (%edx),%ecx
f0105f39:	84 c9                	test   %cl,%cl
f0105f3b:	75 ec                	jne    f0105f29 <strlcpy+0x1a>
f0105f3d:	89 c2                	mov    %eax,%edx
f0105f3f:	eb 02                	jmp    f0105f43 <strlcpy+0x34>
f0105f41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105f43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105f46:	29 f0                	sub    %esi,%eax
}
f0105f48:	5b                   	pop    %ebx
f0105f49:	5e                   	pop    %esi
f0105f4a:	5d                   	pop    %ebp
f0105f4b:	c3                   	ret    

f0105f4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f4c:	55                   	push   %ebp
f0105f4d:	89 e5                	mov    %esp,%ebp
f0105f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105f55:	eb 06                	jmp    f0105f5d <strcmp+0x11>
		p++, q++;
f0105f57:	83 c1 01             	add    $0x1,%ecx
f0105f5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105f5d:	0f b6 01             	movzbl (%ecx),%eax
f0105f60:	84 c0                	test   %al,%al
f0105f62:	74 04                	je     f0105f68 <strcmp+0x1c>
f0105f64:	3a 02                	cmp    (%edx),%al
f0105f66:	74 ef                	je     f0105f57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f68:	0f b6 c0             	movzbl %al,%eax
f0105f6b:	0f b6 12             	movzbl (%edx),%edx
f0105f6e:	29 d0                	sub    %edx,%eax
}
f0105f70:	5d                   	pop    %ebp
f0105f71:	c3                   	ret    

f0105f72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105f72:	55                   	push   %ebp
f0105f73:	89 e5                	mov    %esp,%ebp
f0105f75:	53                   	push   %ebx
f0105f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f79:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f7c:	89 c3                	mov    %eax,%ebx
f0105f7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105f81:	eb 06                	jmp    f0105f89 <strncmp+0x17>
		n--, p++, q++;
f0105f83:	83 c0 01             	add    $0x1,%eax
f0105f86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105f89:	39 d8                	cmp    %ebx,%eax
f0105f8b:	74 15                	je     f0105fa2 <strncmp+0x30>
f0105f8d:	0f b6 08             	movzbl (%eax),%ecx
f0105f90:	84 c9                	test   %cl,%cl
f0105f92:	74 04                	je     f0105f98 <strncmp+0x26>
f0105f94:	3a 0a                	cmp    (%edx),%cl
f0105f96:	74 eb                	je     f0105f83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f98:	0f b6 00             	movzbl (%eax),%eax
f0105f9b:	0f b6 12             	movzbl (%edx),%edx
f0105f9e:	29 d0                	sub    %edx,%eax
f0105fa0:	eb 05                	jmp    f0105fa7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105fa2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105fa7:	5b                   	pop    %ebx
f0105fa8:	5d                   	pop    %ebp
f0105fa9:	c3                   	ret    

f0105faa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105faa:	55                   	push   %ebp
f0105fab:	89 e5                	mov    %esp,%ebp
f0105fad:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105fb4:	eb 07                	jmp    f0105fbd <strchr+0x13>
		if (*s == c)
f0105fb6:	38 ca                	cmp    %cl,%dl
f0105fb8:	74 0f                	je     f0105fc9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105fba:	83 c0 01             	add    $0x1,%eax
f0105fbd:	0f b6 10             	movzbl (%eax),%edx
f0105fc0:	84 d2                	test   %dl,%dl
f0105fc2:	75 f2                	jne    f0105fb6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105fc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105fc9:	5d                   	pop    %ebp
f0105fca:	c3                   	ret    

f0105fcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105fcb:	55                   	push   %ebp
f0105fcc:	89 e5                	mov    %esp,%ebp
f0105fce:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105fd5:	eb 07                	jmp    f0105fde <strfind+0x13>
		if (*s == c)
f0105fd7:	38 ca                	cmp    %cl,%dl
f0105fd9:	74 0a                	je     f0105fe5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105fdb:	83 c0 01             	add    $0x1,%eax
f0105fde:	0f b6 10             	movzbl (%eax),%edx
f0105fe1:	84 d2                	test   %dl,%dl
f0105fe3:	75 f2                	jne    f0105fd7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105fe5:	5d                   	pop    %ebp
f0105fe6:	c3                   	ret    

f0105fe7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105fe7:	55                   	push   %ebp
f0105fe8:	89 e5                	mov    %esp,%ebp
f0105fea:	57                   	push   %edi
f0105feb:	56                   	push   %esi
f0105fec:	53                   	push   %ebx
f0105fed:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ff0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ff3:	85 c9                	test   %ecx,%ecx
f0105ff5:	74 36                	je     f010602d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105ff7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105ffd:	75 28                	jne    f0106027 <memset+0x40>
f0105fff:	f6 c1 03             	test   $0x3,%cl
f0106002:	75 23                	jne    f0106027 <memset+0x40>
		c &= 0xFF;
f0106004:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106008:	89 d3                	mov    %edx,%ebx
f010600a:	c1 e3 08             	shl    $0x8,%ebx
f010600d:	89 d6                	mov    %edx,%esi
f010600f:	c1 e6 18             	shl    $0x18,%esi
f0106012:	89 d0                	mov    %edx,%eax
f0106014:	c1 e0 10             	shl    $0x10,%eax
f0106017:	09 f0                	or     %esi,%eax
f0106019:	09 c2                	or     %eax,%edx
f010601b:	89 d0                	mov    %edx,%eax
f010601d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010601f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106022:	fc                   	cld    
f0106023:	f3 ab                	rep stos %eax,%es:(%edi)
f0106025:	eb 06                	jmp    f010602d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106027:	8b 45 0c             	mov    0xc(%ebp),%eax
f010602a:	fc                   	cld    
f010602b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010602d:	89 f8                	mov    %edi,%eax
f010602f:	5b                   	pop    %ebx
f0106030:	5e                   	pop    %esi
f0106031:	5f                   	pop    %edi
f0106032:	5d                   	pop    %ebp
f0106033:	c3                   	ret    

f0106034 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106034:	55                   	push   %ebp
f0106035:	89 e5                	mov    %esp,%ebp
f0106037:	57                   	push   %edi
f0106038:	56                   	push   %esi
f0106039:	8b 45 08             	mov    0x8(%ebp),%eax
f010603c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010603f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106042:	39 c6                	cmp    %eax,%esi
f0106044:	73 35                	jae    f010607b <memmove+0x47>
f0106046:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106049:	39 d0                	cmp    %edx,%eax
f010604b:	73 2e                	jae    f010607b <memmove+0x47>
		s += n;
		d += n;
f010604d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106050:	89 d6                	mov    %edx,%esi
f0106052:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106054:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010605a:	75 13                	jne    f010606f <memmove+0x3b>
f010605c:	f6 c1 03             	test   $0x3,%cl
f010605f:	75 0e                	jne    f010606f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106061:	83 ef 04             	sub    $0x4,%edi
f0106064:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106067:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010606a:	fd                   	std    
f010606b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010606d:	eb 09                	jmp    f0106078 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010606f:	83 ef 01             	sub    $0x1,%edi
f0106072:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106075:	fd                   	std    
f0106076:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106078:	fc                   	cld    
f0106079:	eb 1d                	jmp    f0106098 <memmove+0x64>
f010607b:	89 f2                	mov    %esi,%edx
f010607d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010607f:	f6 c2 03             	test   $0x3,%dl
f0106082:	75 0f                	jne    f0106093 <memmove+0x5f>
f0106084:	f6 c1 03             	test   $0x3,%cl
f0106087:	75 0a                	jne    f0106093 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106089:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010608c:	89 c7                	mov    %eax,%edi
f010608e:	fc                   	cld    
f010608f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106091:	eb 05                	jmp    f0106098 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106093:	89 c7                	mov    %eax,%edi
f0106095:	fc                   	cld    
f0106096:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106098:	5e                   	pop    %esi
f0106099:	5f                   	pop    %edi
f010609a:	5d                   	pop    %ebp
f010609b:	c3                   	ret    

f010609c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010609c:	55                   	push   %ebp
f010609d:	89 e5                	mov    %esp,%ebp
f010609f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01060a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01060a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01060a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01060b3:	89 04 24             	mov    %eax,(%esp)
f01060b6:	e8 79 ff ff ff       	call   f0106034 <memmove>
}
f01060bb:	c9                   	leave  
f01060bc:	c3                   	ret    

f01060bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01060bd:	55                   	push   %ebp
f01060be:	89 e5                	mov    %esp,%ebp
f01060c0:	56                   	push   %esi
f01060c1:	53                   	push   %ebx
f01060c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01060c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01060c8:	89 d6                	mov    %edx,%esi
f01060ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01060cd:	eb 1a                	jmp    f01060e9 <memcmp+0x2c>
		if (*s1 != *s2)
f01060cf:	0f b6 02             	movzbl (%edx),%eax
f01060d2:	0f b6 19             	movzbl (%ecx),%ebx
f01060d5:	38 d8                	cmp    %bl,%al
f01060d7:	74 0a                	je     f01060e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01060d9:	0f b6 c0             	movzbl %al,%eax
f01060dc:	0f b6 db             	movzbl %bl,%ebx
f01060df:	29 d8                	sub    %ebx,%eax
f01060e1:	eb 0f                	jmp    f01060f2 <memcmp+0x35>
		s1++, s2++;
f01060e3:	83 c2 01             	add    $0x1,%edx
f01060e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01060e9:	39 f2                	cmp    %esi,%edx
f01060eb:	75 e2                	jne    f01060cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01060ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060f2:	5b                   	pop    %ebx
f01060f3:	5e                   	pop    %esi
f01060f4:	5d                   	pop    %ebp
f01060f5:	c3                   	ret    

f01060f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01060f6:	55                   	push   %ebp
f01060f7:	89 e5                	mov    %esp,%ebp
f01060f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01060ff:	89 c2                	mov    %eax,%edx
f0106101:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106104:	eb 07                	jmp    f010610d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106106:	38 08                	cmp    %cl,(%eax)
f0106108:	74 07                	je     f0106111 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010610a:	83 c0 01             	add    $0x1,%eax
f010610d:	39 d0                	cmp    %edx,%eax
f010610f:	72 f5                	jb     f0106106 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106111:	5d                   	pop    %ebp
f0106112:	c3                   	ret    

f0106113 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106113:	55                   	push   %ebp
f0106114:	89 e5                	mov    %esp,%ebp
f0106116:	57                   	push   %edi
f0106117:	56                   	push   %esi
f0106118:	53                   	push   %ebx
f0106119:	8b 55 08             	mov    0x8(%ebp),%edx
f010611c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010611f:	eb 03                	jmp    f0106124 <strtol+0x11>
		s++;
f0106121:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106124:	0f b6 0a             	movzbl (%edx),%ecx
f0106127:	80 f9 09             	cmp    $0x9,%cl
f010612a:	74 f5                	je     f0106121 <strtol+0xe>
f010612c:	80 f9 20             	cmp    $0x20,%cl
f010612f:	74 f0                	je     f0106121 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106131:	80 f9 2b             	cmp    $0x2b,%cl
f0106134:	75 0a                	jne    f0106140 <strtol+0x2d>
		s++;
f0106136:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106139:	bf 00 00 00 00       	mov    $0x0,%edi
f010613e:	eb 11                	jmp    f0106151 <strtol+0x3e>
f0106140:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106145:	80 f9 2d             	cmp    $0x2d,%cl
f0106148:	75 07                	jne    f0106151 <strtol+0x3e>
		s++, neg = 1;
f010614a:	8d 52 01             	lea    0x1(%edx),%edx
f010614d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106151:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0106156:	75 15                	jne    f010616d <strtol+0x5a>
f0106158:	80 3a 30             	cmpb   $0x30,(%edx)
f010615b:	75 10                	jne    f010616d <strtol+0x5a>
f010615d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106161:	75 0a                	jne    f010616d <strtol+0x5a>
		s += 2, base = 16;
f0106163:	83 c2 02             	add    $0x2,%edx
f0106166:	b8 10 00 00 00       	mov    $0x10,%eax
f010616b:	eb 10                	jmp    f010617d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010616d:	85 c0                	test   %eax,%eax
f010616f:	75 0c                	jne    f010617d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106171:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106173:	80 3a 30             	cmpb   $0x30,(%edx)
f0106176:	75 05                	jne    f010617d <strtol+0x6a>
		s++, base = 8;
f0106178:	83 c2 01             	add    $0x1,%edx
f010617b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010617d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106182:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106185:	0f b6 0a             	movzbl (%edx),%ecx
f0106188:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010618b:	89 f0                	mov    %esi,%eax
f010618d:	3c 09                	cmp    $0x9,%al
f010618f:	77 08                	ja     f0106199 <strtol+0x86>
			dig = *s - '0';
f0106191:	0f be c9             	movsbl %cl,%ecx
f0106194:	83 e9 30             	sub    $0x30,%ecx
f0106197:	eb 20                	jmp    f01061b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106199:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010619c:	89 f0                	mov    %esi,%eax
f010619e:	3c 19                	cmp    $0x19,%al
f01061a0:	77 08                	ja     f01061aa <strtol+0x97>
			dig = *s - 'a' + 10;
f01061a2:	0f be c9             	movsbl %cl,%ecx
f01061a5:	83 e9 57             	sub    $0x57,%ecx
f01061a8:	eb 0f                	jmp    f01061b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01061aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01061ad:	89 f0                	mov    %esi,%eax
f01061af:	3c 19                	cmp    $0x19,%al
f01061b1:	77 16                	ja     f01061c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01061b3:	0f be c9             	movsbl %cl,%ecx
f01061b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01061b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01061bc:	7d 0f                	jge    f01061cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01061be:	83 c2 01             	add    $0x1,%edx
f01061c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01061c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01061c7:	eb bc                	jmp    f0106185 <strtol+0x72>
f01061c9:	89 d8                	mov    %ebx,%eax
f01061cb:	eb 02                	jmp    f01061cf <strtol+0xbc>
f01061cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01061cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01061d3:	74 05                	je     f01061da <strtol+0xc7>
		*endptr = (char *) s;
f01061d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01061da:	f7 d8                	neg    %eax
f01061dc:	85 ff                	test   %edi,%edi
f01061de:	0f 44 c3             	cmove  %ebx,%eax
}
f01061e1:	5b                   	pop    %ebx
f01061e2:	5e                   	pop    %esi
f01061e3:	5f                   	pop    %edi
f01061e4:	5d                   	pop    %ebp
f01061e5:	c3                   	ret    
f01061e6:	66 90                	xchg   %ax,%ax

f01061e8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01061e8:	fa                   	cli    

	xorw    %ax, %ax
f01061e9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01061eb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061ed:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061ef:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01061f1:	0f 01 16             	lgdtl  (%esi)
f01061f4:	74 70                	je     f0106266 <mpentry_end+0x4>
	movl    %cr0, %eax
f01061f6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01061f9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01061fd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106200:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106206:	08 00                	or     %al,(%eax)

f0106208 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106208:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010620c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010620e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106210:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106212:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106216:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106218:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010621a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010621f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106222:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106225:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010622a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010622d:	8b 25 84 2e 1e f0    	mov    0xf01e2e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106233:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106238:	b8 e7 01 10 f0       	mov    $0xf01001e7,%eax
	call    *%eax
f010623d:	ff d0                	call   *%eax

f010623f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010623f:	eb fe                	jmp    f010623f <spin>
f0106241:	8d 76 00             	lea    0x0(%esi),%esi

f0106244 <gdt>:
	...
f010624c:	ff                   	(bad)  
f010624d:	ff 00                	incl   (%eax)
f010624f:	00 00                	add    %al,(%eax)
f0106251:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106258:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f010625c <gdtdesc>:
f010625c:	17                   	pop    %ss
f010625d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106262 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106262:	90                   	nop
f0106263:	66 90                	xchg   %ax,%ax
f0106265:	66 90                	xchg   %ax,%ax
f0106267:	66 90                	xchg   %ax,%ax
f0106269:	66 90                	xchg   %ax,%ax
f010626b:	66 90                	xchg   %ax,%ax
f010626d:	66 90                	xchg   %ax,%ax
f010626f:	90                   	nop

f0106270 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106270:	55                   	push   %ebp
f0106271:	89 e5                	mov    %esp,%ebp
f0106273:	56                   	push   %esi
f0106274:	53                   	push   %ebx
f0106275:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106278:	8b 0d 88 2e 1e f0    	mov    0xf01e2e88,%ecx
f010627e:	89 c3                	mov    %eax,%ebx
f0106280:	c1 eb 0c             	shr    $0xc,%ebx
f0106283:	39 cb                	cmp    %ecx,%ebx
f0106285:	72 20                	jb     f01062a7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106287:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010628b:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0106292:	f0 
f0106293:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010629a:	00 
f010629b:	c7 04 24 7d 88 10 f0 	movl   $0xf010887d,(%esp)
f01062a2:	e8 99 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01062a7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01062ad:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062af:	89 c2                	mov    %eax,%edx
f01062b1:	c1 ea 0c             	shr    $0xc,%edx
f01062b4:	39 d1                	cmp    %edx,%ecx
f01062b6:	77 20                	ja     f01062d8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01062bc:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01062c3:	f0 
f01062c4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01062cb:	00 
f01062cc:	c7 04 24 7d 88 10 f0 	movl   $0xf010887d,(%esp)
f01062d3:	e8 68 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01062d8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01062de:	eb 36                	jmp    f0106316 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062e0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01062e7:	00 
f01062e8:	c7 44 24 04 8d 88 10 	movl   $0xf010888d,0x4(%esp)
f01062ef:	f0 
f01062f0:	89 1c 24             	mov    %ebx,(%esp)
f01062f3:	e8 c5 fd ff ff       	call   f01060bd <memcmp>
f01062f8:	85 c0                	test   %eax,%eax
f01062fa:	75 17                	jne    f0106313 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01062fc:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106301:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106305:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106307:	83 c2 01             	add    $0x1,%edx
f010630a:	83 fa 10             	cmp    $0x10,%edx
f010630d:	75 f2                	jne    f0106301 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010630f:	84 c0                	test   %al,%al
f0106311:	74 0e                	je     f0106321 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106313:	83 c3 10             	add    $0x10,%ebx
f0106316:	39 f3                	cmp    %esi,%ebx
f0106318:	72 c6                	jb     f01062e0 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010631a:	b8 00 00 00 00       	mov    $0x0,%eax
f010631f:	eb 02                	jmp    f0106323 <mpsearch1+0xb3>
f0106321:	89 d8                	mov    %ebx,%eax
}
f0106323:	83 c4 10             	add    $0x10,%esp
f0106326:	5b                   	pop    %ebx
f0106327:	5e                   	pop    %esi
f0106328:	5d                   	pop    %ebp
f0106329:	c3                   	ret    

f010632a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010632a:	55                   	push   %ebp
f010632b:	89 e5                	mov    %esp,%ebp
f010632d:	57                   	push   %edi
f010632e:	56                   	push   %esi
f010632f:	53                   	push   %ebx
f0106330:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106333:	c7 05 c0 33 1e f0 20 	movl   $0xf01e3020,0xf01e33c0
f010633a:	30 1e f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010633d:	83 3d 88 2e 1e f0 00 	cmpl   $0x0,0xf01e2e88
f0106344:	75 24                	jne    f010636a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106346:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010634d:	00 
f010634e:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f0106355:	f0 
f0106356:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010635d:	00 
f010635e:	c7 04 24 7d 88 10 f0 	movl   $0xf010887d,(%esp)
f0106365:	e8 d6 9c ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010636a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106371:	85 c0                	test   %eax,%eax
f0106373:	74 16                	je     f010638b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106375:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106378:	ba 00 04 00 00       	mov    $0x400,%edx
f010637d:	e8 ee fe ff ff       	call   f0106270 <mpsearch1>
f0106382:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106385:	85 c0                	test   %eax,%eax
f0106387:	75 3c                	jne    f01063c5 <mp_init+0x9b>
f0106389:	eb 20                	jmp    f01063ab <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010638b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106392:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106395:	2d 00 04 00 00       	sub    $0x400,%eax
f010639a:	ba 00 04 00 00       	mov    $0x400,%edx
f010639f:	e8 cc fe ff ff       	call   f0106270 <mpsearch1>
f01063a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01063a7:	85 c0                	test   %eax,%eax
f01063a9:	75 1a                	jne    f01063c5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01063ab:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063b0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01063b5:	e8 b6 fe ff ff       	call   f0106270 <mpsearch1>
f01063ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01063bd:	85 c0                	test   %eax,%eax
f01063bf:	0f 84 54 02 00 00    	je     f0106619 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01063c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063c8:	8b 70 04             	mov    0x4(%eax),%esi
f01063cb:	85 f6                	test   %esi,%esi
f01063cd:	74 06                	je     f01063d5 <mp_init+0xab>
f01063cf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01063d3:	74 11                	je     f01063e6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01063d5:	c7 04 24 f0 86 10 f0 	movl   $0xf01086f0,(%esp)
f01063dc:	e8 e0 db ff ff       	call   f0103fc1 <cprintf>
f01063e1:	e9 33 02 00 00       	jmp    f0106619 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063e6:	89 f0                	mov    %esi,%eax
f01063e8:	c1 e8 0c             	shr    $0xc,%eax
f01063eb:	3b 05 88 2e 1e f0    	cmp    0xf01e2e88,%eax
f01063f1:	72 20                	jb     f0106413 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01063f7:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01063fe:	f0 
f01063ff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106406:	00 
f0106407:	c7 04 24 7d 88 10 f0 	movl   $0xf010887d,(%esp)
f010640e:	e8 2d 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106413:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106419:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106420:	00 
f0106421:	c7 44 24 04 92 88 10 	movl   $0xf0108892,0x4(%esp)
f0106428:	f0 
f0106429:	89 1c 24             	mov    %ebx,(%esp)
f010642c:	e8 8c fc ff ff       	call   f01060bd <memcmp>
f0106431:	85 c0                	test   %eax,%eax
f0106433:	74 11                	je     f0106446 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106435:	c7 04 24 20 87 10 f0 	movl   $0xf0108720,(%esp)
f010643c:	e8 80 db ff ff       	call   f0103fc1 <cprintf>
f0106441:	e9 d3 01 00 00       	jmp    f0106619 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106446:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010644a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010644e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106451:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106456:	b8 00 00 00 00       	mov    $0x0,%eax
f010645b:	eb 0d                	jmp    f010646a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f010645d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106464:	f0 
f0106465:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106467:	83 c0 01             	add    $0x1,%eax
f010646a:	39 c7                	cmp    %eax,%edi
f010646c:	7f ef                	jg     f010645d <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010646e:	84 d2                	test   %dl,%dl
f0106470:	74 11                	je     f0106483 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106472:	c7 04 24 54 87 10 f0 	movl   $0xf0108754,(%esp)
f0106479:	e8 43 db ff ff       	call   f0103fc1 <cprintf>
f010647e:	e9 96 01 00 00       	jmp    f0106619 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106483:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106487:	3c 04                	cmp    $0x4,%al
f0106489:	74 1f                	je     f01064aa <mp_init+0x180>
f010648b:	3c 01                	cmp    $0x1,%al
f010648d:	8d 76 00             	lea    0x0(%esi),%esi
f0106490:	74 18                	je     f01064aa <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106492:	0f b6 c0             	movzbl %al,%eax
f0106495:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106499:	c7 04 24 78 87 10 f0 	movl   $0xf0108778,(%esp)
f01064a0:	e8 1c db ff ff       	call   f0103fc1 <cprintf>
f01064a5:	e9 6f 01 00 00       	jmp    f0106619 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01064aa:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01064ae:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01064b2:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01064b4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01064b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01064be:	eb 09                	jmp    f01064c9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f01064c0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01064c4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01064c6:	83 c0 01             	add    $0x1,%eax
f01064c9:	39 c6                	cmp    %eax,%esi
f01064cb:	7f f3                	jg     f01064c0 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01064cd:	02 53 2a             	add    0x2a(%ebx),%dl
f01064d0:	84 d2                	test   %dl,%dl
f01064d2:	74 11                	je     f01064e5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01064d4:	c7 04 24 98 87 10 f0 	movl   $0xf0108798,(%esp)
f01064db:	e8 e1 da ff ff       	call   f0103fc1 <cprintf>
f01064e0:	e9 34 01 00 00       	jmp    f0106619 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01064e5:	85 db                	test   %ebx,%ebx
f01064e7:	0f 84 2c 01 00 00    	je     f0106619 <mp_init+0x2ef>
		return;
	ismp = 1;
f01064ed:	c7 05 00 30 1e f0 01 	movl   $0x1,0xf01e3000
f01064f4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01064f7:	8b 43 24             	mov    0x24(%ebx),%eax
f01064fa:	a3 00 40 22 f0       	mov    %eax,0xf0224000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01064ff:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106502:	be 00 00 00 00       	mov    $0x0,%esi
f0106507:	e9 86 00 00 00       	jmp    f0106592 <mp_init+0x268>
		switch (*p) {
f010650c:	0f b6 07             	movzbl (%edi),%eax
f010650f:	84 c0                	test   %al,%al
f0106511:	74 06                	je     f0106519 <mp_init+0x1ef>
f0106513:	3c 04                	cmp    $0x4,%al
f0106515:	77 57                	ja     f010656e <mp_init+0x244>
f0106517:	eb 50                	jmp    f0106569 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106519:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010651d:	8d 76 00             	lea    0x0(%esi),%esi
f0106520:	74 11                	je     f0106533 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106522:	6b 05 c4 33 1e f0 74 	imul   $0x74,0xf01e33c4,%eax
f0106529:	05 20 30 1e f0       	add    $0xf01e3020,%eax
f010652e:	a3 c0 33 1e f0       	mov    %eax,0xf01e33c0
			if (ncpu < NCPU) {
f0106533:	a1 c4 33 1e f0       	mov    0xf01e33c4,%eax
f0106538:	83 f8 07             	cmp    $0x7,%eax
f010653b:	7f 13                	jg     f0106550 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010653d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106540:	88 82 20 30 1e f0    	mov    %al,-0xfe1cfe0(%edx)
				ncpu++;
f0106546:	83 c0 01             	add    $0x1,%eax
f0106549:	a3 c4 33 1e f0       	mov    %eax,0xf01e33c4
f010654e:	eb 14                	jmp    f0106564 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106550:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106554:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106558:	c7 04 24 c8 87 10 f0 	movl   $0xf01087c8,(%esp)
f010655f:	e8 5d da ff ff       	call   f0103fc1 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106564:	83 c7 14             	add    $0x14,%edi
			continue;
f0106567:	eb 26                	jmp    f010658f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106569:	83 c7 08             	add    $0x8,%edi
			continue;
f010656c:	eb 21                	jmp    f010658f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010656e:	0f b6 c0             	movzbl %al,%eax
f0106571:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106575:	c7 04 24 f0 87 10 f0 	movl   $0xf01087f0,(%esp)
f010657c:	e8 40 da ff ff       	call   f0103fc1 <cprintf>
			ismp = 0;
f0106581:	c7 05 00 30 1e f0 00 	movl   $0x0,0xf01e3000
f0106588:	00 00 00 
			i = conf->entry;
f010658b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010658f:	83 c6 01             	add    $0x1,%esi
f0106592:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106596:	39 c6                	cmp    %eax,%esi
f0106598:	0f 82 6e ff ff ff    	jb     f010650c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010659e:	a1 c0 33 1e f0       	mov    0xf01e33c0,%eax
f01065a3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01065aa:	83 3d 00 30 1e f0 00 	cmpl   $0x0,0xf01e3000
f01065b1:	75 22                	jne    f01065d5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01065b3:	c7 05 c4 33 1e f0 01 	movl   $0x1,0xf01e33c4
f01065ba:	00 00 00 
		lapicaddr = 0;
f01065bd:	c7 05 00 40 22 f0 00 	movl   $0x0,0xf0224000
f01065c4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01065c7:	c7 04 24 10 88 10 f0 	movl   $0xf0108810,(%esp)
f01065ce:	e8 ee d9 ff ff       	call   f0103fc1 <cprintf>
		return;
f01065d3:	eb 44                	jmp    f0106619 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01065d5:	8b 15 c4 33 1e f0    	mov    0xf01e33c4,%edx
f01065db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01065df:	0f b6 00             	movzbl (%eax),%eax
f01065e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065e6:	c7 04 24 97 88 10 f0 	movl   $0xf0108897,(%esp)
f01065ed:	e8 cf d9 ff ff       	call   f0103fc1 <cprintf>

	if (mp->imcrp) {
f01065f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065f5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01065f9:	74 1e                	je     f0106619 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01065fb:	c7 04 24 3c 88 10 f0 	movl   $0xf010883c,(%esp)
f0106602:	e8 ba d9 ff ff       	call   f0103fc1 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106607:	ba 22 00 00 00       	mov    $0x22,%edx
f010660c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106611:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106612:	b2 23                	mov    $0x23,%dl
f0106614:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106615:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106618:	ee                   	out    %al,(%dx)
	}
}
f0106619:	83 c4 2c             	add    $0x2c,%esp
f010661c:	5b                   	pop    %ebx
f010661d:	5e                   	pop    %esi
f010661e:	5f                   	pop    %edi
f010661f:	5d                   	pop    %ebp
f0106620:	c3                   	ret    

f0106621 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106621:	55                   	push   %ebp
f0106622:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106624:	8b 0d 04 40 22 f0    	mov    0xf0224004,%ecx
f010662a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010662d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010662f:	a1 04 40 22 f0       	mov    0xf0224004,%eax
f0106634:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106637:	5d                   	pop    %ebp
f0106638:	c3                   	ret    

f0106639 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106639:	55                   	push   %ebp
f010663a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010663c:	a1 04 40 22 f0       	mov    0xf0224004,%eax
f0106641:	85 c0                	test   %eax,%eax
f0106643:	74 08                	je     f010664d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106645:	8b 40 20             	mov    0x20(%eax),%eax
f0106648:	c1 e8 18             	shr    $0x18,%eax
f010664b:	eb 05                	jmp    f0106652 <cpunum+0x19>
	return 0;
f010664d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106652:	5d                   	pop    %ebp
f0106653:	c3                   	ret    

f0106654 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106654:	a1 00 40 22 f0       	mov    0xf0224000,%eax
f0106659:	85 c0                	test   %eax,%eax
f010665b:	0f 84 23 01 00 00    	je     f0106784 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106661:	55                   	push   %ebp
f0106662:	89 e5                	mov    %esp,%ebp
f0106664:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106667:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010666e:	00 
f010666f:	89 04 24             	mov    %eax,(%esp)
f0106672:	e8 a0 ad ff ff       	call   f0101417 <mmio_map_region>
f0106677:	a3 04 40 22 f0       	mov    %eax,0xf0224004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010667c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106681:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106686:	e8 96 ff ff ff       	call   f0106621 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010668b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106690:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106695:	e8 87 ff ff ff       	call   f0106621 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010669a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010669f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01066a4:	e8 78 ff ff ff       	call   f0106621 <lapicw>
	lapicw(TICR, 10000000); 
f01066a9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01066ae:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01066b3:	e8 69 ff ff ff       	call   f0106621 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01066b8:	e8 7c ff ff ff       	call   f0106639 <cpunum>
f01066bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01066c0:	05 20 30 1e f0       	add    $0xf01e3020,%eax
f01066c5:	39 05 c0 33 1e f0    	cmp    %eax,0xf01e33c0
f01066cb:	74 0f                	je     f01066dc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01066cd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01066d2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01066d7:	e8 45 ff ff ff       	call   f0106621 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01066dc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01066e1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01066e6:	e8 36 ff ff ff       	call   f0106621 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01066eb:	a1 04 40 22 f0       	mov    0xf0224004,%eax
f01066f0:	8b 40 30             	mov    0x30(%eax),%eax
f01066f3:	c1 e8 10             	shr    $0x10,%eax
f01066f6:	3c 03                	cmp    $0x3,%al
f01066f8:	76 0f                	jbe    f0106709 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01066fa:	ba 00 00 01 00       	mov    $0x10000,%edx
f01066ff:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106704:	e8 18 ff ff ff       	call   f0106621 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106709:	ba 33 00 00 00       	mov    $0x33,%edx
f010670e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106713:	e8 09 ff ff ff       	call   f0106621 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106718:	ba 00 00 00 00       	mov    $0x0,%edx
f010671d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106722:	e8 fa fe ff ff       	call   f0106621 <lapicw>
	lapicw(ESR, 0);
f0106727:	ba 00 00 00 00       	mov    $0x0,%edx
f010672c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106731:	e8 eb fe ff ff       	call   f0106621 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106736:	ba 00 00 00 00       	mov    $0x0,%edx
f010673b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106740:	e8 dc fe ff ff       	call   f0106621 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106745:	ba 00 00 00 00       	mov    $0x0,%edx
f010674a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010674f:	e8 cd fe ff ff       	call   f0106621 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106754:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106759:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010675e:	e8 be fe ff ff       	call   f0106621 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106763:	8b 15 04 40 22 f0    	mov    0xf0224004,%edx
f0106769:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010676f:	f6 c4 10             	test   $0x10,%ah
f0106772:	75 f5                	jne    f0106769 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106774:	ba 00 00 00 00       	mov    $0x0,%edx
f0106779:	b8 20 00 00 00       	mov    $0x20,%eax
f010677e:	e8 9e fe ff ff       	call   f0106621 <lapicw>
}
f0106783:	c9                   	leave  
f0106784:	f3 c3                	repz ret 

f0106786 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106786:	83 3d 04 40 22 f0 00 	cmpl   $0x0,0xf0224004
f010678d:	74 13                	je     f01067a2 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010678f:	55                   	push   %ebp
f0106790:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106792:	ba 00 00 00 00       	mov    $0x0,%edx
f0106797:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010679c:	e8 80 fe ff ff       	call   f0106621 <lapicw>
}
f01067a1:	5d                   	pop    %ebp
f01067a2:	f3 c3                	repz ret 

f01067a4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01067a4:	55                   	push   %ebp
f01067a5:	89 e5                	mov    %esp,%ebp
f01067a7:	56                   	push   %esi
f01067a8:	53                   	push   %ebx
f01067a9:	83 ec 10             	sub    $0x10,%esp
f01067ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01067af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01067b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01067b7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01067bc:	ee                   	out    %al,(%dx)
f01067bd:	b2 71                	mov    $0x71,%dl
f01067bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01067c4:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067c5:	83 3d 88 2e 1e f0 00 	cmpl   $0x0,0xf01e2e88
f01067cc:	75 24                	jne    f01067f2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067ce:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01067d5:	00 
f01067d6:	c7 44 24 08 44 6d 10 	movl   $0xf0106d44,0x8(%esp)
f01067dd:	f0 
f01067de:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01067e5:	00 
f01067e6:	c7 04 24 b4 88 10 f0 	movl   $0xf01088b4,(%esp)
f01067ed:	e8 4e 98 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01067f2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01067f9:	00 00 
	wrv[1] = addr >> 4;
f01067fb:	89 f0                	mov    %esi,%eax
f01067fd:	c1 e8 04             	shr    $0x4,%eax
f0106800:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106806:	c1 e3 18             	shl    $0x18,%ebx
f0106809:	89 da                	mov    %ebx,%edx
f010680b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106810:	e8 0c fe ff ff       	call   f0106621 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106815:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010681a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010681f:	e8 fd fd ff ff       	call   f0106621 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106824:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106829:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010682e:	e8 ee fd ff ff       	call   f0106621 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106833:	c1 ee 0c             	shr    $0xc,%esi
f0106836:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010683c:	89 da                	mov    %ebx,%edx
f010683e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106843:	e8 d9 fd ff ff       	call   f0106621 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106848:	89 f2                	mov    %esi,%edx
f010684a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010684f:	e8 cd fd ff ff       	call   f0106621 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106854:	89 da                	mov    %ebx,%edx
f0106856:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010685b:	e8 c1 fd ff ff       	call   f0106621 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106860:	89 f2                	mov    %esi,%edx
f0106862:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106867:	e8 b5 fd ff ff       	call   f0106621 <lapicw>
		microdelay(200);
	}
}
f010686c:	83 c4 10             	add    $0x10,%esp
f010686f:	5b                   	pop    %ebx
f0106870:	5e                   	pop    %esi
f0106871:	5d                   	pop    %ebp
f0106872:	c3                   	ret    

f0106873 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106873:	55                   	push   %ebp
f0106874:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106876:	8b 55 08             	mov    0x8(%ebp),%edx
f0106879:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010687f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106884:	e8 98 fd ff ff       	call   f0106621 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106889:	8b 15 04 40 22 f0    	mov    0xf0224004,%edx
f010688f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106895:	f6 c4 10             	test   $0x10,%ah
f0106898:	75 f5                	jne    f010688f <lapic_ipi+0x1c>
		;
}
f010689a:	5d                   	pop    %ebp
f010689b:	c3                   	ret    

f010689c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010689c:	55                   	push   %ebp
f010689d:	89 e5                	mov    %esp,%ebp
f010689f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01068a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01068a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01068ab:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01068ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01068b5:	5d                   	pop    %ebp
f01068b6:	c3                   	ret    

f01068b7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01068b7:	55                   	push   %ebp
f01068b8:	89 e5                	mov    %esp,%ebp
f01068ba:	56                   	push   %esi
f01068bb:	53                   	push   %ebx
f01068bc:	83 ec 20             	sub    $0x20,%esp
f01068bf:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01068c2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01068c5:	75 07                	jne    f01068ce <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01068c7:	ba 01 00 00 00       	mov    $0x1,%edx
f01068cc:	eb 42                	jmp    f0106910 <spin_lock+0x59>
f01068ce:	8b 73 08             	mov    0x8(%ebx),%esi
f01068d1:	e8 63 fd ff ff       	call   f0106639 <cpunum>
f01068d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01068d9:	05 20 30 1e f0       	add    $0xf01e3020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01068de:	39 c6                	cmp    %eax,%esi
f01068e0:	75 e5                	jne    f01068c7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01068e2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01068e5:	e8 4f fd ff ff       	call   f0106639 <cpunum>
f01068ea:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01068ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01068f2:	c7 44 24 08 c4 88 10 	movl   $0xf01088c4,0x8(%esp)
f01068f9:	f0 
f01068fa:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106901:	00 
f0106902:	c7 04 24 28 89 10 f0 	movl   $0xf0108928,(%esp)
f0106909:	e8 32 97 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010690e:	f3 90                	pause  
f0106910:	89 d0                	mov    %edx,%eax
f0106912:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106915:	85 c0                	test   %eax,%eax
f0106917:	75 f5                	jne    f010690e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106919:	e8 1b fd ff ff       	call   f0106639 <cpunum>
f010691e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106921:	05 20 30 1e f0       	add    $0xf01e3020,%eax
f0106926:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106929:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010692c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010692e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106933:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106939:	76 12                	jbe    f010694d <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010693b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010693e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106941:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106943:	83 c0 01             	add    $0x1,%eax
f0106946:	83 f8 0a             	cmp    $0xa,%eax
f0106949:	75 e8                	jne    f0106933 <spin_lock+0x7c>
f010694b:	eb 0f                	jmp    f010695c <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010694d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106954:	83 c0 01             	add    $0x1,%eax
f0106957:	83 f8 09             	cmp    $0x9,%eax
f010695a:	7e f1                	jle    f010694d <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010695c:	83 c4 20             	add    $0x20,%esp
f010695f:	5b                   	pop    %ebx
f0106960:	5e                   	pop    %esi
f0106961:	5d                   	pop    %ebp
f0106962:	c3                   	ret    

f0106963 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106963:	55                   	push   %ebp
f0106964:	89 e5                	mov    %esp,%ebp
f0106966:	57                   	push   %edi
f0106967:	56                   	push   %esi
f0106968:	53                   	push   %ebx
f0106969:	83 ec 6c             	sub    $0x6c,%esp
f010696c:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010696f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106972:	74 18                	je     f010698c <spin_unlock+0x29>
f0106974:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106977:	e8 bd fc ff ff       	call   f0106639 <cpunum>
f010697c:	6b c0 74             	imul   $0x74,%eax,%eax
f010697f:	05 20 30 1e f0       	add    $0xf01e3020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106984:	39 c3                	cmp    %eax,%ebx
f0106986:	0f 84 ce 00 00 00    	je     f0106a5a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010698c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106993:	00 
f0106994:	8d 46 0c             	lea    0xc(%esi),%eax
f0106997:	89 44 24 04          	mov    %eax,0x4(%esp)
f010699b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010699e:	89 1c 24             	mov    %ebx,(%esp)
f01069a1:	e8 8e f6 ff ff       	call   f0106034 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01069a6:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01069a9:	0f b6 38             	movzbl (%eax),%edi
f01069ac:	8b 76 04             	mov    0x4(%esi),%esi
f01069af:	e8 85 fc ff ff       	call   f0106639 <cpunum>
f01069b4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069b8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01069bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069c0:	c7 04 24 f0 88 10 f0 	movl   $0xf01088f0,(%esp)
f01069c7:	e8 f5 d5 ff ff       	call   f0103fc1 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01069cc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01069cf:	eb 65                	jmp    f0106a36 <spin_unlock+0xd3>
f01069d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01069d5:	89 04 24             	mov    %eax,(%esp)
f01069d8:	e8 f1 ea ff ff       	call   f01054ce <debuginfo_eip>
f01069dd:	85 c0                	test   %eax,%eax
f01069df:	78 39                	js     f0106a1a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01069e1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01069e3:	89 c2                	mov    %eax,%edx
f01069e5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01069e8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01069ec:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01069ef:	89 54 24 14          	mov    %edx,0x14(%esp)
f01069f3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01069f6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01069fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01069fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106a01:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106a04:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106a08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a0c:	c7 04 24 38 89 10 f0 	movl   $0xf0108938,(%esp)
f0106a13:	e8 a9 d5 ff ff       	call   f0103fc1 <cprintf>
f0106a18:	eb 12                	jmp    f0106a2c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106a1a:	8b 06                	mov    (%esi),%eax
f0106a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a20:	c7 04 24 4f 89 10 f0 	movl   $0xf010894f,(%esp)
f0106a27:	e8 95 d5 ff ff       	call   f0103fc1 <cprintf>
f0106a2c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106a2f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106a32:	39 c3                	cmp    %eax,%ebx
f0106a34:	74 08                	je     f0106a3e <spin_unlock+0xdb>
f0106a36:	89 de                	mov    %ebx,%esi
f0106a38:	8b 03                	mov    (%ebx),%eax
f0106a3a:	85 c0                	test   %eax,%eax
f0106a3c:	75 93                	jne    f01069d1 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106a3e:	c7 44 24 08 57 89 10 	movl   $0xf0108957,0x8(%esp)
f0106a45:	f0 
f0106a46:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106a4d:	00 
f0106a4e:	c7 04 24 28 89 10 f0 	movl   $0xf0108928,(%esp)
f0106a55:	e8 e6 95 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106a5a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106a61:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106a68:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a6d:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106a70:	83 c4 6c             	add    $0x6c,%esp
f0106a73:	5b                   	pop    %ebx
f0106a74:	5e                   	pop    %esi
f0106a75:	5f                   	pop    %edi
f0106a76:	5d                   	pop    %ebp
f0106a77:	c3                   	ret    
f0106a78:	66 90                	xchg   %ax,%ax
f0106a7a:	66 90                	xchg   %ax,%ax
f0106a7c:	66 90                	xchg   %ax,%ax
f0106a7e:	66 90                	xchg   %ax,%ax

f0106a80 <__udivdi3>:
f0106a80:	55                   	push   %ebp
f0106a81:	57                   	push   %edi
f0106a82:	56                   	push   %esi
f0106a83:	83 ec 0c             	sub    $0xc,%esp
f0106a86:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106a8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106a8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106a92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106a96:	85 c0                	test   %eax,%eax
f0106a98:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106a9c:	89 ea                	mov    %ebp,%edx
f0106a9e:	89 0c 24             	mov    %ecx,(%esp)
f0106aa1:	75 2d                	jne    f0106ad0 <__udivdi3+0x50>
f0106aa3:	39 e9                	cmp    %ebp,%ecx
f0106aa5:	77 61                	ja     f0106b08 <__udivdi3+0x88>
f0106aa7:	85 c9                	test   %ecx,%ecx
f0106aa9:	89 ce                	mov    %ecx,%esi
f0106aab:	75 0b                	jne    f0106ab8 <__udivdi3+0x38>
f0106aad:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ab2:	31 d2                	xor    %edx,%edx
f0106ab4:	f7 f1                	div    %ecx
f0106ab6:	89 c6                	mov    %eax,%esi
f0106ab8:	31 d2                	xor    %edx,%edx
f0106aba:	89 e8                	mov    %ebp,%eax
f0106abc:	f7 f6                	div    %esi
f0106abe:	89 c5                	mov    %eax,%ebp
f0106ac0:	89 f8                	mov    %edi,%eax
f0106ac2:	f7 f6                	div    %esi
f0106ac4:	89 ea                	mov    %ebp,%edx
f0106ac6:	83 c4 0c             	add    $0xc,%esp
f0106ac9:	5e                   	pop    %esi
f0106aca:	5f                   	pop    %edi
f0106acb:	5d                   	pop    %ebp
f0106acc:	c3                   	ret    
f0106acd:	8d 76 00             	lea    0x0(%esi),%esi
f0106ad0:	39 e8                	cmp    %ebp,%eax
f0106ad2:	77 24                	ja     f0106af8 <__udivdi3+0x78>
f0106ad4:	0f bd e8             	bsr    %eax,%ebp
f0106ad7:	83 f5 1f             	xor    $0x1f,%ebp
f0106ada:	75 3c                	jne    f0106b18 <__udivdi3+0x98>
f0106adc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106ae0:	39 34 24             	cmp    %esi,(%esp)
f0106ae3:	0f 86 9f 00 00 00    	jbe    f0106b88 <__udivdi3+0x108>
f0106ae9:	39 d0                	cmp    %edx,%eax
f0106aeb:	0f 82 97 00 00 00    	jb     f0106b88 <__udivdi3+0x108>
f0106af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106af8:	31 d2                	xor    %edx,%edx
f0106afa:	31 c0                	xor    %eax,%eax
f0106afc:	83 c4 0c             	add    $0xc,%esp
f0106aff:	5e                   	pop    %esi
f0106b00:	5f                   	pop    %edi
f0106b01:	5d                   	pop    %ebp
f0106b02:	c3                   	ret    
f0106b03:	90                   	nop
f0106b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b08:	89 f8                	mov    %edi,%eax
f0106b0a:	f7 f1                	div    %ecx
f0106b0c:	31 d2                	xor    %edx,%edx
f0106b0e:	83 c4 0c             	add    $0xc,%esp
f0106b11:	5e                   	pop    %esi
f0106b12:	5f                   	pop    %edi
f0106b13:	5d                   	pop    %ebp
f0106b14:	c3                   	ret    
f0106b15:	8d 76 00             	lea    0x0(%esi),%esi
f0106b18:	89 e9                	mov    %ebp,%ecx
f0106b1a:	8b 3c 24             	mov    (%esp),%edi
f0106b1d:	d3 e0                	shl    %cl,%eax
f0106b1f:	89 c6                	mov    %eax,%esi
f0106b21:	b8 20 00 00 00       	mov    $0x20,%eax
f0106b26:	29 e8                	sub    %ebp,%eax
f0106b28:	89 c1                	mov    %eax,%ecx
f0106b2a:	d3 ef                	shr    %cl,%edi
f0106b2c:	89 e9                	mov    %ebp,%ecx
f0106b2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106b32:	8b 3c 24             	mov    (%esp),%edi
f0106b35:	09 74 24 08          	or     %esi,0x8(%esp)
f0106b39:	89 d6                	mov    %edx,%esi
f0106b3b:	d3 e7                	shl    %cl,%edi
f0106b3d:	89 c1                	mov    %eax,%ecx
f0106b3f:	89 3c 24             	mov    %edi,(%esp)
f0106b42:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106b46:	d3 ee                	shr    %cl,%esi
f0106b48:	89 e9                	mov    %ebp,%ecx
f0106b4a:	d3 e2                	shl    %cl,%edx
f0106b4c:	89 c1                	mov    %eax,%ecx
f0106b4e:	d3 ef                	shr    %cl,%edi
f0106b50:	09 d7                	or     %edx,%edi
f0106b52:	89 f2                	mov    %esi,%edx
f0106b54:	89 f8                	mov    %edi,%eax
f0106b56:	f7 74 24 08          	divl   0x8(%esp)
f0106b5a:	89 d6                	mov    %edx,%esi
f0106b5c:	89 c7                	mov    %eax,%edi
f0106b5e:	f7 24 24             	mull   (%esp)
f0106b61:	39 d6                	cmp    %edx,%esi
f0106b63:	89 14 24             	mov    %edx,(%esp)
f0106b66:	72 30                	jb     f0106b98 <__udivdi3+0x118>
f0106b68:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106b6c:	89 e9                	mov    %ebp,%ecx
f0106b6e:	d3 e2                	shl    %cl,%edx
f0106b70:	39 c2                	cmp    %eax,%edx
f0106b72:	73 05                	jae    f0106b79 <__udivdi3+0xf9>
f0106b74:	3b 34 24             	cmp    (%esp),%esi
f0106b77:	74 1f                	je     f0106b98 <__udivdi3+0x118>
f0106b79:	89 f8                	mov    %edi,%eax
f0106b7b:	31 d2                	xor    %edx,%edx
f0106b7d:	e9 7a ff ff ff       	jmp    f0106afc <__udivdi3+0x7c>
f0106b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b88:	31 d2                	xor    %edx,%edx
f0106b8a:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b8f:	e9 68 ff ff ff       	jmp    f0106afc <__udivdi3+0x7c>
f0106b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b98:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106b9b:	31 d2                	xor    %edx,%edx
f0106b9d:	83 c4 0c             	add    $0xc,%esp
f0106ba0:	5e                   	pop    %esi
f0106ba1:	5f                   	pop    %edi
f0106ba2:	5d                   	pop    %ebp
f0106ba3:	c3                   	ret    
f0106ba4:	66 90                	xchg   %ax,%ax
f0106ba6:	66 90                	xchg   %ax,%ax
f0106ba8:	66 90                	xchg   %ax,%ax
f0106baa:	66 90                	xchg   %ax,%ax
f0106bac:	66 90                	xchg   %ax,%ax
f0106bae:	66 90                	xchg   %ax,%ax

f0106bb0 <__umoddi3>:
f0106bb0:	55                   	push   %ebp
f0106bb1:	57                   	push   %edi
f0106bb2:	56                   	push   %esi
f0106bb3:	83 ec 14             	sub    $0x14,%esp
f0106bb6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106bba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106bbe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106bc2:	89 c7                	mov    %eax,%edi
f0106bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bc8:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106bcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106bd0:	89 34 24             	mov    %esi,(%esp)
f0106bd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106bd7:	85 c0                	test   %eax,%eax
f0106bd9:	89 c2                	mov    %eax,%edx
f0106bdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106bdf:	75 17                	jne    f0106bf8 <__umoddi3+0x48>
f0106be1:	39 fe                	cmp    %edi,%esi
f0106be3:	76 4b                	jbe    f0106c30 <__umoddi3+0x80>
f0106be5:	89 c8                	mov    %ecx,%eax
f0106be7:	89 fa                	mov    %edi,%edx
f0106be9:	f7 f6                	div    %esi
f0106beb:	89 d0                	mov    %edx,%eax
f0106bed:	31 d2                	xor    %edx,%edx
f0106bef:	83 c4 14             	add    $0x14,%esp
f0106bf2:	5e                   	pop    %esi
f0106bf3:	5f                   	pop    %edi
f0106bf4:	5d                   	pop    %ebp
f0106bf5:	c3                   	ret    
f0106bf6:	66 90                	xchg   %ax,%ax
f0106bf8:	39 f8                	cmp    %edi,%eax
f0106bfa:	77 54                	ja     f0106c50 <__umoddi3+0xa0>
f0106bfc:	0f bd e8             	bsr    %eax,%ebp
f0106bff:	83 f5 1f             	xor    $0x1f,%ebp
f0106c02:	75 5c                	jne    f0106c60 <__umoddi3+0xb0>
f0106c04:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106c08:	39 3c 24             	cmp    %edi,(%esp)
f0106c0b:	0f 87 e7 00 00 00    	ja     f0106cf8 <__umoddi3+0x148>
f0106c11:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c15:	29 f1                	sub    %esi,%ecx
f0106c17:	19 c7                	sbb    %eax,%edi
f0106c19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c21:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c25:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106c29:	83 c4 14             	add    $0x14,%esp
f0106c2c:	5e                   	pop    %esi
f0106c2d:	5f                   	pop    %edi
f0106c2e:	5d                   	pop    %ebp
f0106c2f:	c3                   	ret    
f0106c30:	85 f6                	test   %esi,%esi
f0106c32:	89 f5                	mov    %esi,%ebp
f0106c34:	75 0b                	jne    f0106c41 <__umoddi3+0x91>
f0106c36:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c3b:	31 d2                	xor    %edx,%edx
f0106c3d:	f7 f6                	div    %esi
f0106c3f:	89 c5                	mov    %eax,%ebp
f0106c41:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106c45:	31 d2                	xor    %edx,%edx
f0106c47:	f7 f5                	div    %ebp
f0106c49:	89 c8                	mov    %ecx,%eax
f0106c4b:	f7 f5                	div    %ebp
f0106c4d:	eb 9c                	jmp    f0106beb <__umoddi3+0x3b>
f0106c4f:	90                   	nop
f0106c50:	89 c8                	mov    %ecx,%eax
f0106c52:	89 fa                	mov    %edi,%edx
f0106c54:	83 c4 14             	add    $0x14,%esp
f0106c57:	5e                   	pop    %esi
f0106c58:	5f                   	pop    %edi
f0106c59:	5d                   	pop    %ebp
f0106c5a:	c3                   	ret    
f0106c5b:	90                   	nop
f0106c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c60:	8b 04 24             	mov    (%esp),%eax
f0106c63:	be 20 00 00 00       	mov    $0x20,%esi
f0106c68:	89 e9                	mov    %ebp,%ecx
f0106c6a:	29 ee                	sub    %ebp,%esi
f0106c6c:	d3 e2                	shl    %cl,%edx
f0106c6e:	89 f1                	mov    %esi,%ecx
f0106c70:	d3 e8                	shr    %cl,%eax
f0106c72:	89 e9                	mov    %ebp,%ecx
f0106c74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c78:	8b 04 24             	mov    (%esp),%eax
f0106c7b:	09 54 24 04          	or     %edx,0x4(%esp)
f0106c7f:	89 fa                	mov    %edi,%edx
f0106c81:	d3 e0                	shl    %cl,%eax
f0106c83:	89 f1                	mov    %esi,%ecx
f0106c85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106c89:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106c8d:	d3 ea                	shr    %cl,%edx
f0106c8f:	89 e9                	mov    %ebp,%ecx
f0106c91:	d3 e7                	shl    %cl,%edi
f0106c93:	89 f1                	mov    %esi,%ecx
f0106c95:	d3 e8                	shr    %cl,%eax
f0106c97:	89 e9                	mov    %ebp,%ecx
f0106c99:	09 f8                	or     %edi,%eax
f0106c9b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106c9f:	f7 74 24 04          	divl   0x4(%esp)
f0106ca3:	d3 e7                	shl    %cl,%edi
f0106ca5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106ca9:	89 d7                	mov    %edx,%edi
f0106cab:	f7 64 24 08          	mull   0x8(%esp)
f0106caf:	39 d7                	cmp    %edx,%edi
f0106cb1:	89 c1                	mov    %eax,%ecx
f0106cb3:	89 14 24             	mov    %edx,(%esp)
f0106cb6:	72 2c                	jb     f0106ce4 <__umoddi3+0x134>
f0106cb8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106cbc:	72 22                	jb     f0106ce0 <__umoddi3+0x130>
f0106cbe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106cc2:	29 c8                	sub    %ecx,%eax
f0106cc4:	19 d7                	sbb    %edx,%edi
f0106cc6:	89 e9                	mov    %ebp,%ecx
f0106cc8:	89 fa                	mov    %edi,%edx
f0106cca:	d3 e8                	shr    %cl,%eax
f0106ccc:	89 f1                	mov    %esi,%ecx
f0106cce:	d3 e2                	shl    %cl,%edx
f0106cd0:	89 e9                	mov    %ebp,%ecx
f0106cd2:	d3 ef                	shr    %cl,%edi
f0106cd4:	09 d0                	or     %edx,%eax
f0106cd6:	89 fa                	mov    %edi,%edx
f0106cd8:	83 c4 14             	add    $0x14,%esp
f0106cdb:	5e                   	pop    %esi
f0106cdc:	5f                   	pop    %edi
f0106cdd:	5d                   	pop    %ebp
f0106cde:	c3                   	ret    
f0106cdf:	90                   	nop
f0106ce0:	39 d7                	cmp    %edx,%edi
f0106ce2:	75 da                	jne    f0106cbe <__umoddi3+0x10e>
f0106ce4:	8b 14 24             	mov    (%esp),%edx
f0106ce7:	89 c1                	mov    %eax,%ecx
f0106ce9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106ced:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106cf1:	eb cb                	jmp    f0106cbe <__umoddi3+0x10e>
f0106cf3:	90                   	nop
f0106cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106cf8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106cfc:	0f 82 0f ff ff ff    	jb     f0106c11 <__umoddi3+0x61>
f0106d02:	e9 1a ff ff ff       	jmp    f0106c21 <__umoddi3+0x71>
