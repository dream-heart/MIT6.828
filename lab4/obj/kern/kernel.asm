
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
f010004b:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 0e 23 f0    	mov    %esi,0xf0230e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 35 66 00 00       	call   f0106699 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 80 6d 10 f0 	movl   $0xf0106d80,(%esp)
f010007d:	e8 e3 3e 00 00       	call   f0103f65 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 a4 3e 00 00       	call   f0103f32 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b0 7e 10 f0 	movl   $0xf0107eb0,(%esp)
f0100095:	e8 cb 3e 00 00       	call   f0103f65 <cprintf>
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
f01000af:	b8 08 20 27 f0       	mov    $0xf0272008,%eax
f01000b4:	2d 00 fe 22 f0       	sub    $0xf022fe00,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 fe 22 f0 	movl   $0xf022fe00,(%esp)
f01000cc:	e8 76 5f 00 00       	call   f0106047 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d1:	e8 a9 05 00 00       	call   f010067f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 ec 6d 10 f0 	movl   $0xf0106dec,(%esp)
f01000e5:	e8 7b 3e 00 00       	call   f0103f65 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ea:	e8 cd 12 00 00       	call   f01013bc <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000ef:	e8 ed 35 00 00       	call   f01036e1 <env_init>
	trap_init();
f01000f4:	e8 57 3f 00 00       	call   f0104050 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000f9:	e8 8c 62 00 00       	call   f010638a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 af 65 00 00       	call   f01066b4 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100105:	e8 8b 3d 00 00       	call   f0103e95 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 01 68 00 00       	call   f0106917 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 0e 23 f0 07 	cmpl   $0x7,0xf0230e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 07 6e 10 f0 	movl   $0xf0106e07,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 c2 62 10 f0       	mov    $0xf01062c2,%eax
f0100148:	2d 48 62 10 f0       	sub    $0xf0106248,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 48 62 10 	movl   $0xf0106248,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 2f 5f 00 00       	call   f0106094 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100165:	bb 20 10 23 f0       	mov    $0xf0231020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum())  // We've started already.
f010016c:	e8 28 65 00 00       	call   f0106699 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 10 23 f0       	sub    $0xf0231020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 a0 23 f0    	lea    -0xfdc6000(%eax),%eax
f0100196:	a3 84 0e 23 f0       	mov    %eax,0xf0230e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 56 66 00 00       	call   f0106804 <lapic_startap>
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
f01001b9:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f01001c0:	05 20 10 23 f0       	add    $0xf0231020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 74 63 22 f0 	movl   $0xf0226374,(%esp)
f01001d8:	e8 17 37 00 00       	call   f01038f4 <env_create>
														envs[2].env_status
														);
*/

	// Schedule and run the first user environment!
	sched_yield();
f01001dd:	e8 e5 4a 00 00       	call   f0104cc7 <sched_yield>

f01001e2 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e2:	55                   	push   %ebp
f01001e3:	89 e5                	mov    %esp,%ebp
f01001e5:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001e8:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f2:	77 20                	ja     f0100214 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001f8:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f01001ff:	f0 
f0100200:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f0100207:	00 
f0100208:	c7 04 24 07 6e 10 f0 	movl   $0xf0106e07,(%esp)
f010020f:	e8 2c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100214:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100219:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010021c:	e8 78 64 00 00       	call   f0106699 <cpunum>
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	c7 04 24 13 6e 10 f0 	movl   $0xf0106e13,(%esp)
f010022c:	e8 34 3d 00 00       	call   f0103f65 <cprintf>

	lapic_init();
f0100231:	e8 7e 64 00 00       	call   f01066b4 <lapic_init>
	env_init_percpu();
f0100236:	e8 7c 34 00 00       	call   f01036b7 <env_init_percpu>
	trap_init_percpu();
f010023b:	90                   	nop
f010023c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100240:	e8 3b 3d 00 00       	call   f0103f80 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 4f 64 00 00       	call   f0106699 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100263:	e8 af 66 00 00       	call   f0106917 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
		lock_kernel();
		sched_yield();
f0100268:	e8 5a 4a 00 00       	call   f0104cc7 <sched_yield>

f010026d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010026d:	55                   	push   %ebp
f010026e:	89 e5                	mov    %esp,%ebp
f0100270:	53                   	push   %ebx
f0100271:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100274:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100277:	8b 45 0c             	mov    0xc(%ebp),%eax
f010027a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100281:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100285:	c7 04 24 29 6e 10 f0 	movl   $0xf0106e29,(%esp)
f010028c:	e8 d4 3c 00 00       	call   f0103f65 <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 92 3c 00 00       	call   f0103f32 <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 b0 7e 10 f0 	movl   $0xf0107eb0,(%esp)
f01002a7:	e8 b9 3c 00 00       	call   f0103f65 <cprintf>
	va_end(ap);
}
f01002ac:	83 c4 14             	add    $0x14,%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5d                   	pop    %ebp
f01002b1:	c3                   	ret    
f01002b2:	66 90                	xchg   %ax,%ax
f01002b4:	66 90                	xchg   %ax,%ax
f01002b6:	66 90                	xchg   %ax,%ax
f01002b8:	66 90                	xchg   %ax,%ax
f01002ba:	66 90                	xchg   %ax,%ax
f01002bc:	66 90                	xchg   %ax,%ax
f01002be:	66 90                	xchg   %ax,%ax

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 08                	je     f01002d5 <serial_proc_data+0x15>
f01002cd:	b2 f8                	mov    $0xf8,%dl
f01002cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d0:	0f b6 c0             	movzbl %al,%eax
f01002d3:	eb 05                	jmp    f01002da <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002dc:	55                   	push   %ebp
f01002dd:	89 e5                	mov    %esp,%ebp
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 04             	sub    $0x4,%esp
f01002e3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e5:	eb 2a                	jmp    f0100311 <cons_intr+0x35>
		if (c == 0)
f01002e7:	85 d2                	test   %edx,%edx
f01002e9:	74 26                	je     f0100311 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002eb:	a1 24 02 23 f0       	mov    0xf0230224,%eax
f01002f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002f3:	89 0d 24 02 23 f0    	mov    %ecx,0xf0230224
f01002f9:	88 90 20 00 23 f0    	mov    %dl,-0xfdcffe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100305:	75 0a                	jne    f0100311 <cons_intr+0x35>
			cons.wpos = 0;
f0100307:	c7 05 24 02 23 f0 00 	movl   $0x0,0xf0230224
f010030e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100311:	ff d3                	call   *%ebx
f0100313:	89 c2                	mov    %eax,%edx
f0100315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100318:	75 cd                	jne    f01002e7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010031a:	83 c4 04             	add    $0x4,%esp
f010031d:	5b                   	pop    %ebx
f010031e:	5d                   	pop    %ebp
f010031f:	c3                   	ret    

f0100320 <kbd_proc_data>:
f0100320:	ba 64 00 00 00       	mov    $0x64,%edx
f0100325:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100326:	a8 01                	test   $0x1,%al
f0100328:	0f 84 ef 00 00 00    	je     f010041d <kbd_proc_data+0xfd>
f010032e:	b2 60                	mov    $0x60,%dl
f0100330:	ec                   	in     (%dx),%al
f0100331:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100333:	3c e0                	cmp    $0xe0,%al
f0100335:	75 0d                	jne    f0100344 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100337:	83 0d 00 00 23 f0 40 	orl    $0x40,0xf0230000
		return 0;
f010033e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100343:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100344:	55                   	push   %ebp
f0100345:	89 e5                	mov    %esp,%ebp
f0100347:	53                   	push   %ebx
f0100348:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010034b:	84 c0                	test   %al,%al
f010034d:	79 37                	jns    f0100386 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010034f:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f0100355:	89 cb                	mov    %ecx,%ebx
f0100357:	83 e3 40             	and    $0x40,%ebx
f010035a:	83 e0 7f             	and    $0x7f,%eax
f010035d:	85 db                	test   %ebx,%ebx
f010035f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100362:	0f b6 d2             	movzbl %dl,%edx
f0100365:	0f b6 82 a0 6f 10 f0 	movzbl -0xfef9060(%edx),%eax
f010036c:	83 c8 40             	or     $0x40,%eax
f010036f:	0f b6 c0             	movzbl %al,%eax
f0100372:	f7 d0                	not    %eax
f0100374:	21 c1                	and    %eax,%ecx
f0100376:	89 0d 00 00 23 f0    	mov    %ecx,0xf0230000
		return 0;
f010037c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100381:	e9 9d 00 00 00       	jmp    f0100423 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100386:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f010038c:	f6 c1 40             	test   $0x40,%cl
f010038f:	74 0e                	je     f010039f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100391:	83 c8 80             	or     $0xffffff80,%eax
f0100394:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100396:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100399:	89 0d 00 00 23 f0    	mov    %ecx,0xf0230000
	}

	shift |= shiftcode[data];
f010039f:	0f b6 d2             	movzbl %dl,%edx
f01003a2:	0f b6 82 a0 6f 10 f0 	movzbl -0xfef9060(%edx),%eax
f01003a9:	0b 05 00 00 23 f0    	or     0xf0230000,%eax
	shift ^= togglecode[data];
f01003af:	0f b6 8a a0 6e 10 f0 	movzbl -0xfef9160(%edx),%ecx
f01003b6:	31 c8                	xor    %ecx,%eax
f01003b8:	a3 00 00 23 f0       	mov    %eax,0xf0230000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003bd:	89 c1                	mov    %eax,%ecx
f01003bf:	83 e1 03             	and    $0x3,%ecx
f01003c2:	8b 0c 8d 80 6e 10 f0 	mov    -0xfef9180(,%ecx,4),%ecx
f01003c9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003cd:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d0:	a8 08                	test   $0x8,%al
f01003d2:	74 1b                	je     f01003ef <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01003d4:	89 da                	mov    %ebx,%edx
f01003d6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003d9:	83 f9 19             	cmp    $0x19,%ecx
f01003dc:	77 05                	ja     f01003e3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01003de:	83 eb 20             	sub    $0x20,%ebx
f01003e1:	eb 0c                	jmp    f01003ef <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01003e3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003e6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003e9:	83 fa 19             	cmp    $0x19,%edx
f01003ec:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ef:	f7 d0                	not    %eax
f01003f1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f5:	f6 c2 06             	test   $0x6,%dl
f01003f8:	75 29                	jne    f0100423 <kbd_proc_data+0x103>
f01003fa:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100400:	75 21                	jne    f0100423 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100402:	c7 04 24 43 6e 10 f0 	movl   $0xf0106e43,(%esp)
f0100409:	e8 57 3b 00 00       	call   f0103f65 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100413:	b8 03 00 00 00       	mov    $0x3,%eax
f0100418:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100419:	89 d8                	mov    %ebx,%eax
f010041b:	eb 06                	jmp    f0100423 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010041d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100422:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100423:	83 c4 14             	add    $0x14,%esp
f0100426:	5b                   	pop    %ebx
f0100427:	5d                   	pop    %ebp
f0100428:	c3                   	ret    

f0100429 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100429:	55                   	push   %ebp
f010042a:	89 e5                	mov    %esp,%ebp
f010042c:	57                   	push   %edi
f010042d:	56                   	push   %esi
f010042e:	53                   	push   %ebx
f010042f:	83 ec 1c             	sub    $0x1c,%esp
f0100432:	89 c7                	mov    %eax,%edi
f0100434:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100439:	be fd 03 00 00       	mov    $0x3fd,%esi
f010043e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100443:	eb 06                	jmp    f010044b <cons_putc+0x22>
f0100445:	89 ca                	mov    %ecx,%edx
f0100447:	ec                   	in     (%dx),%al
f0100448:	ec                   	in     (%dx),%al
f0100449:	ec                   	in     (%dx),%al
f010044a:	ec                   	in     (%dx),%al
f010044b:	89 f2                	mov    %esi,%edx
f010044d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010044e:	a8 20                	test   $0x20,%al
f0100450:	75 05                	jne    f0100457 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100452:	83 eb 01             	sub    $0x1,%ebx
f0100455:	75 ee                	jne    f0100445 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100457:	89 f8                	mov    %edi,%eax
f0100459:	0f b6 c0             	movzbl %al,%eax
f010045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010046a:	be 79 03 00 00       	mov    $0x379,%esi
f010046f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100474:	eb 06                	jmp    f010047c <cons_putc+0x53>
f0100476:	89 ca                	mov    %ecx,%edx
f0100478:	ec                   	in     (%dx),%al
f0100479:	ec                   	in     (%dx),%al
f010047a:	ec                   	in     (%dx),%al
f010047b:	ec                   	in     (%dx),%al
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010047f:	84 c0                	test   %al,%al
f0100481:	78 05                	js     f0100488 <cons_putc+0x5f>
f0100483:	83 eb 01             	sub    $0x1,%ebx
f0100486:	75 ee                	jne    f0100476 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100488:	ba 78 03 00 00       	mov    $0x378,%edx
f010048d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b2 7a                	mov    $0x7a,%dl
f0100494:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100499:	ee                   	out    %al,(%dx)
f010049a:	b8 08 00 00 00       	mov    $0x8,%eax
f010049f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004a0:	89 fa                	mov    %edi,%edx
f01004a2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004a8:	89 f8                	mov    %edi,%eax
f01004aa:	80 cc 07             	or     $0x7,%ah
f01004ad:	85 d2                	test   %edx,%edx
f01004af:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004b2:	89 f8                	mov    %edi,%eax
f01004b4:	0f b6 c0             	movzbl %al,%eax
f01004b7:	83 f8 09             	cmp    $0x9,%eax
f01004ba:	74 76                	je     f0100532 <cons_putc+0x109>
f01004bc:	83 f8 09             	cmp    $0x9,%eax
f01004bf:	7f 0a                	jg     f01004cb <cons_putc+0xa2>
f01004c1:	83 f8 08             	cmp    $0x8,%eax
f01004c4:	74 16                	je     f01004dc <cons_putc+0xb3>
f01004c6:	e9 9b 00 00 00       	jmp    f0100566 <cons_putc+0x13d>
f01004cb:	83 f8 0a             	cmp    $0xa,%eax
f01004ce:	66 90                	xchg   %ax,%ax
f01004d0:	74 3a                	je     f010050c <cons_putc+0xe3>
f01004d2:	83 f8 0d             	cmp    $0xd,%eax
f01004d5:	74 3d                	je     f0100514 <cons_putc+0xeb>
f01004d7:	e9 8a 00 00 00       	jmp    f0100566 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f01004dc:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	0f 84 e5 00 00 00    	je     f01005d1 <cons_putc+0x1a8>
			crt_pos--;
f01004ec:	83 e8 01             	sub    $0x1,%eax
f01004ef:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f5:	0f b7 c0             	movzwl %ax,%eax
f01004f8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004fd:	83 cf 20             	or     $0x20,%edi
f0100500:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f0100506:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010050a:	eb 78                	jmp    f0100584 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010050c:	66 83 05 28 02 23 f0 	addw   $0x50,0xf0230228
f0100513:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100514:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f010051b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100521:	c1 e8 16             	shr    $0x16,%eax
f0100524:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100527:	c1 e0 04             	shl    $0x4,%eax
f010052a:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
f0100530:	eb 52                	jmp    f0100584 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f0100532:	b8 20 00 00 00       	mov    $0x20,%eax
f0100537:	e8 ed fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 e3 fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 d9 fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f0100550:	b8 20 00 00 00       	mov    $0x20,%eax
f0100555:	e8 cf fe ff ff       	call   f0100429 <cons_putc>
		cons_putc(' ');
f010055a:	b8 20 00 00 00       	mov    $0x20,%eax
f010055f:	e8 c5 fe ff ff       	call   f0100429 <cons_putc>
f0100564:	eb 1e                	jmp    f0100584 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100566:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f010056d:	8d 50 01             	lea    0x1(%eax),%edx
f0100570:	66 89 15 28 02 23 f0 	mov    %dx,0xf0230228
f0100577:	0f b7 c0             	movzwl %ax,%eax
f010057a:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f0100580:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100584:	66 81 3d 28 02 23 f0 	cmpw   $0x7cf,0xf0230228
f010058b:	cf 07 
f010058d:	76 42                	jbe    f01005d1 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010058f:	a1 2c 02 23 f0       	mov    0xf023022c,%eax
f0100594:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010059b:	00 
f010059c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005a6:	89 04 24             	mov    %eax,(%esp)
f01005a9:	e8 e6 5a 00 00       	call   f0106094 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005ae:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005b9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005bf:	83 c0 01             	add    $0x1,%eax
f01005c2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005c7:	75 f0                	jne    f01005b9 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005c9:	66 83 2d 28 02 23 f0 	subw   $0x50,0xf0230228
f01005d0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005d1:	8b 0d 30 02 23 f0    	mov    0xf0230230,%ecx
f01005d7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005dc:	89 ca                	mov    %ecx,%edx
f01005de:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005df:	0f b7 1d 28 02 23 f0 	movzwl 0xf0230228,%ebx
f01005e6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005e9:	89 d8                	mov    %ebx,%eax
f01005eb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ef:	89 f2                	mov    %esi,%edx
f01005f1:	ee                   	out    %al,(%dx)
f01005f2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005f7:	89 ca                	mov    %ecx,%edx
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	89 d8                	mov    %ebx,%eax
f01005fc:	89 f2                	mov    %esi,%edx
f01005fe:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ff:	83 c4 1c             	add    $0x1c,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100607:	80 3d 34 02 23 f0 00 	cmpb   $0x0,0xf0230234
f010060e:	74 11                	je     f0100621 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100616:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010061b:	e8 bc fc ff ff       	call   f01002dc <cons_intr>
}
f0100620:	c9                   	leave  
f0100621:	f3 c3                	repz ret 

f0100623 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
f0100626:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100629:	b8 20 03 10 f0       	mov    $0xf0100320,%eax
f010062e:	e8 a9 fc ff ff       	call   f01002dc <cons_intr>
}
f0100633:	c9                   	leave  
f0100634:	c3                   	ret    

f0100635 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100635:	55                   	push   %ebp
f0100636:	89 e5                	mov    %esp,%ebp
f0100638:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010063b:	e8 c7 ff ff ff       	call   f0100607 <serial_intr>
	kbd_intr();
f0100640:	e8 de ff ff ff       	call   f0100623 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100645:	a1 20 02 23 f0       	mov    0xf0230220,%eax
f010064a:	3b 05 24 02 23 f0    	cmp    0xf0230224,%eax
f0100650:	74 26                	je     f0100678 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100652:	8d 50 01             	lea    0x1(%eax),%edx
f0100655:	89 15 20 02 23 f0    	mov    %edx,0xf0230220
f010065b:	0f b6 88 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100662:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100664:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010066a:	75 11                	jne    f010067d <cons_getc+0x48>
			cons.rpos = 0;
f010066c:	c7 05 20 02 23 f0 00 	movl   $0x0,0xf0230220
f0100673:	00 00 00 
f0100676:	eb 05                	jmp    f010067d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100678:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010067d:	c9                   	leave  
f010067e:	c3                   	ret    

f010067f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010067f:	55                   	push   %ebp
f0100680:	89 e5                	mov    %esp,%ebp
f0100682:	57                   	push   %edi
f0100683:	56                   	push   %esi
f0100684:	53                   	push   %ebx
f0100685:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100688:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010068f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100696:	5a a5 
	if (*cp != 0xA55A) {
f0100698:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010069f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a3:	74 11                	je     f01006b6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006a5:	c7 05 30 02 23 f0 b4 	movl   $0x3b4,0xf0230230
f01006ac:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006af:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006b4:	eb 16                	jmp    f01006cc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006b6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006bd:	c7 05 30 02 23 f0 d4 	movl   $0x3d4,0xf0230230
f01006c4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006cc:	8b 0d 30 02 23 f0    	mov    0xf0230230,%ecx
f01006d2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006d7:	89 ca                	mov    %ecx,%edx
f01006d9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006da:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006dd:	89 da                	mov    %ebx,%edx
f01006df:	ec                   	in     (%dx),%al
f01006e0:	0f b6 f0             	movzbl %al,%esi
f01006e3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006eb:	89 ca                	mov    %ecx,%edx
f01006ed:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ee:	89 da                	mov    %ebx,%edx
f01006f0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006f1:	89 3d 2c 02 23 f0    	mov    %edi,0xf023022c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006f7:	0f b6 d8             	movzbl %al,%ebx
f01006fa:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006fc:	66 89 35 28 02 23 f0 	mov    %si,0xf0230228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100703:	e8 1b ff ff ff       	call   f0100623 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100708:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010070f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100714:	89 04 24             	mov    %eax,(%esp)
f0100717:	e8 0a 37 00 00       	call   f0103e26 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010071c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100721:	b8 00 00 00 00       	mov    $0x0,%eax
f0100726:	89 f2                	mov    %esi,%edx
f0100728:	ee                   	out    %al,(%dx)
f0100729:	b2 fb                	mov    $0xfb,%dl
f010072b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100730:	ee                   	out    %al,(%dx)
f0100731:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100736:	b8 0c 00 00 00       	mov    $0xc,%eax
f010073b:	89 da                	mov    %ebx,%edx
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 f9                	mov    $0xf9,%dl
f0100740:	b8 00 00 00 00       	mov    $0x0,%eax
f0100745:	ee                   	out    %al,(%dx)
f0100746:	b2 fb                	mov    $0xfb,%dl
f0100748:	b8 03 00 00 00       	mov    $0x3,%eax
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 fc                	mov    $0xfc,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 f9                	mov    $0xf9,%dl
f0100758:	b8 01 00 00 00       	mov    $0x1,%eax
f010075d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075e:	b2 fd                	mov    $0xfd,%dl
f0100760:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100761:	3c ff                	cmp    $0xff,%al
f0100763:	0f 95 c1             	setne  %cl
f0100766:	88 0d 34 02 23 f0    	mov    %cl,0xf0230234
f010076c:	89 f2                	mov    %esi,%edx
f010076e:	ec                   	in     (%dx),%al
f010076f:	89 da                	mov    %ebx,%edx
f0100771:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100772:	84 c9                	test   %cl,%cl
f0100774:	75 0c                	jne    f0100782 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100776:	c7 04 24 4f 6e 10 f0 	movl   $0xf0106e4f,(%esp)
f010077d:	e8 e3 37 00 00       	call   f0103f65 <cprintf>
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
f0100793:	e8 91 fc ff ff       	call   f0100429 <cons_putc>
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
f01007a0:	e8 90 fe ff ff       	call   f0100635 <cons_getc>
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

f01007c0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c6:	c7 44 24 08 a0 70 10 	movl   $0xf01070a0,0x8(%esp)
f01007cd:	f0 
f01007ce:	c7 44 24 04 be 70 10 	movl   $0xf01070be,0x4(%esp)
f01007d5:	f0 
f01007d6:	c7 04 24 c3 70 10 f0 	movl   $0xf01070c3,(%esp)
f01007dd:	e8 83 37 00 00       	call   f0103f65 <cprintf>
f01007e2:	c7 44 24 08 2c 71 10 	movl   $0xf010712c,0x8(%esp)
f01007e9:	f0 
f01007ea:	c7 44 24 04 cc 70 10 	movl   $0xf01070cc,0x4(%esp)
f01007f1:	f0 
f01007f2:	c7 04 24 c3 70 10 f0 	movl   $0xf01070c3,(%esp)
f01007f9:	e8 67 37 00 00       	call   f0103f65 <cprintf>
	return 0;
}
f01007fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100803:	c9                   	leave  
f0100804:	c3                   	ret    

f0100805 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	c7 04 24 d5 70 10 f0 	movl   $0xf01070d5,(%esp)
f0100812:	e8 4e 37 00 00       	call   f0103f65 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100817:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010081e:	00 
f010081f:	c7 04 24 54 71 10 f0 	movl   $0xf0107154,(%esp)
f0100826:	e8 3a 37 00 00       	call   f0103f65 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100832:	00 
f0100833:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010083a:	f0 
f010083b:	c7 04 24 7c 71 10 f0 	movl   $0xf010717c,(%esp)
f0100842:	e8 1e 37 00 00       	call   f0103f65 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100847:	c7 44 24 08 67 6d 10 	movl   $0x106d67,0x8(%esp)
f010084e:	00 
f010084f:	c7 44 24 04 67 6d 10 	movl   $0xf0106d67,0x4(%esp)
f0100856:	f0 
f0100857:	c7 04 24 a0 71 10 f0 	movl   $0xf01071a0,(%esp)
f010085e:	e8 02 37 00 00       	call   f0103f65 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	c7 44 24 08 00 fe 22 	movl   $0x22fe00,0x8(%esp)
f010086a:	00 
f010086b:	c7 44 24 04 00 fe 22 	movl   $0xf022fe00,0x4(%esp)
f0100872:	f0 
f0100873:	c7 04 24 c4 71 10 f0 	movl   $0xf01071c4,(%esp)
f010087a:	e8 e6 36 00 00       	call   f0103f65 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087f:	c7 44 24 08 08 20 27 	movl   $0x272008,0x8(%esp)
f0100886:	00 
f0100887:	c7 44 24 04 08 20 27 	movl   $0xf0272008,0x4(%esp)
f010088e:	f0 
f010088f:	c7 04 24 e8 71 10 f0 	movl   $0xf01071e8,(%esp)
f0100896:	e8 ca 36 00 00       	call   f0103f65 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010089b:	b8 07 24 27 f0       	mov    $0xf0272407,%eax
f01008a0:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008a5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008aa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	0f 48 c2             	cmovs  %edx,%eax
f01008b5:	c1 f8 0a             	sar    $0xa,%eax
f01008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bc:	c7 04 24 0c 72 10 f0 	movl   $0xf010720c,(%esp)
f01008c3:	e8 9d 36 00 00       	call   f0103f65 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008cd:	c9                   	leave  
f01008ce:	c3                   	ret    

f01008cf <mon_backtrace>:

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
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008e2:	c7 04 24 38 72 10 f0 	movl   $0xf0107238,(%esp)
f01008e9:	e8 77 36 00 00       	call   f0103f65 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ee:	c7 04 24 5c 72 10 f0 	movl   $0xf010725c,(%esp)
f01008f5:	e8 6b 36 00 00       	call   f0103f65 <cprintf>

	if (tf != NULL)
f01008fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008fe:	74 0b                	je     f010090b <monitor+0x32>
		print_trapframe(tf);
f0100900:	8b 45 08             	mov    0x8(%ebp),%eax
f0100903:	89 04 24             	mov    %eax,(%esp)
f0100906:	e8 82 3c 00 00       	call   f010458d <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010090b:	c7 04 24 ee 70 10 f0 	movl   $0xf01070ee,(%esp)
f0100912:	e8 d9 54 00 00       	call   f0105df0 <readline>
f0100917:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100919:	85 c0                	test   %eax,%eax
f010091b:	74 ee                	je     f010090b <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010091d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100924:	be 00 00 00 00       	mov    $0x0,%esi
f0100929:	eb 0a                	jmp    f0100935 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010092b:	c6 03 00             	movb   $0x0,(%ebx)
f010092e:	89 f7                	mov    %esi,%edi
f0100930:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100933:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100935:	0f b6 03             	movzbl (%ebx),%eax
f0100938:	84 c0                	test   %al,%al
f010093a:	74 63                	je     f010099f <monitor+0xc6>
f010093c:	0f be c0             	movsbl %al,%eax
f010093f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100943:	c7 04 24 f2 70 10 f0 	movl   $0xf01070f2,(%esp)
f010094a:	e8 bb 56 00 00       	call   f010600a <strchr>
f010094f:	85 c0                	test   %eax,%eax
f0100951:	75 d8                	jne    f010092b <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100953:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100956:	74 47                	je     f010099f <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100958:	83 fe 0f             	cmp    $0xf,%esi
f010095b:	75 16                	jne    f0100973 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010095d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100964:	00 
f0100965:	c7 04 24 f7 70 10 f0 	movl   $0xf01070f7,(%esp)
f010096c:	e8 f4 35 00 00       	call   f0103f65 <cprintf>
f0100971:	eb 98                	jmp    f010090b <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100973:	8d 7e 01             	lea    0x1(%esi),%edi
f0100976:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010097a:	eb 03                	jmp    f010097f <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010097c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010097f:	0f b6 03             	movzbl (%ebx),%eax
f0100982:	84 c0                	test   %al,%al
f0100984:	74 ad                	je     f0100933 <monitor+0x5a>
f0100986:	0f be c0             	movsbl %al,%eax
f0100989:	89 44 24 04          	mov    %eax,0x4(%esp)
f010098d:	c7 04 24 f2 70 10 f0 	movl   $0xf01070f2,(%esp)
f0100994:	e8 71 56 00 00       	call   f010600a <strchr>
f0100999:	85 c0                	test   %eax,%eax
f010099b:	74 df                	je     f010097c <monitor+0xa3>
f010099d:	eb 94                	jmp    f0100933 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f010099f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009a6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009a7:	85 f6                	test   %esi,%esi
f01009a9:	0f 84 5c ff ff ff    	je     f010090b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009af:	c7 44 24 04 be 70 10 	movl   $0xf01070be,0x4(%esp)
f01009b6:	f0 
f01009b7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ba:	89 04 24             	mov    %eax,(%esp)
f01009bd:	e8 ea 55 00 00       	call   f0105fac <strcmp>
f01009c2:	85 c0                	test   %eax,%eax
f01009c4:	74 1b                	je     f01009e1 <monitor+0x108>
f01009c6:	c7 44 24 04 cc 70 10 	movl   $0xf01070cc,0x4(%esp)
f01009cd:	f0 
f01009ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009d1:	89 04 24             	mov    %eax,(%esp)
f01009d4:	e8 d3 55 00 00       	call   f0105fac <strcmp>
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	75 2f                	jne    f0100a0c <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009dd:	b0 01                	mov    $0x1,%al
f01009df:	eb 05                	jmp    f01009e6 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e1:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009e6:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009e9:	01 d0                	add    %edx,%eax
f01009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01009ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01009f2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009f5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009f9:	89 34 24             	mov    %esi,(%esp)
f01009fc:	ff 14 85 8c 72 10 f0 	call   *-0xfef8d74(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	78 1d                	js     f0100a24 <monitor+0x14b>
f0100a07:	e9 ff fe ff ff       	jmp    f010090b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a0c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a13:	c7 04 24 14 71 10 f0 	movl   $0xf0107114,(%esp)
f0100a1a:	e8 46 35 00 00       	call   f0103f65 <cprintf>
f0100a1f:	e9 e7 fe ff ff       	jmp    f010090b <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a24:	83 c4 5c             	add    $0x5c,%esp
f0100a27:	5b                   	pop    %ebx
f0100a28:	5e                   	pop    %esi
f0100a29:	5f                   	pop    %edi
f0100a2a:	5d                   	pop    %ebp
f0100a2b:	c3                   	ret    
f0100a2c:	66 90                	xchg   %ax,%ax
f0100a2e:	66 90                	xchg   %ax,%ax

f0100a30 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a30:	55                   	push   %ebp
f0100a31:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a33:	83 3d 38 02 23 f0 00 	cmpl   $0x0,0xf0230238
f0100a3a:	75 11                	jne    f0100a4d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a3c:	ba 07 30 27 f0       	mov    $0xf0273007,%edx
f0100a41:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a47:	89 15 38 02 23 f0    	mov    %edx,0xf0230238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	75 07                	jne    f0100a58 <boot_alloc+0x28>
		return nextfree;
f0100a51:	a1 38 02 23 f0       	mov    0xf0230238,%eax
f0100a56:	eb 19                	jmp    f0100a71 <boot_alloc+0x41>
	result = nextfree;
f0100a58:	8b 15 38 02 23 f0    	mov    0xf0230238,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a5e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a6a:	a3 38 02 23 f0       	mov    %eax,0xf0230238
	
	// return the head address of the alloc pages;
	return result;
f0100a6f:	89 d0                	mov    %edx,%eax
}
f0100a71:	5d                   	pop    %ebp
f0100a72:	c3                   	ret    

f0100a73 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a73:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100a79:	c1 f8 03             	sar    $0x3,%eax
f0100a7c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a7f:	89 c2                	mov    %eax,%edx
f0100a81:	c1 ea 0c             	shr    $0xc,%edx
f0100a84:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100a8a:	72 26                	jb     f0100ab2 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100a8c:	55                   	push   %ebp
f0100a8d:	89 e5                	mov    %esp,%ebp
f0100a8f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a96:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0100a9d:	f0 
f0100a9e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100aa5:	00 
f0100aa6:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0100aad:	e8 8e f5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ab2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ab7:	c3                   	ret    

f0100ab8 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ab8:	89 d1                	mov    %edx,%ecx
f0100aba:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100abd:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ac0:	a8 01                	test   $0x1,%al
f0100ac2:	74 5d                	je     f0100b21 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ac4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac9:	89 c1                	mov    %eax,%ecx
f0100acb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ace:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0100ad4:	72 26                	jb     f0100afc <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ad6:	55                   	push   %ebp
f0100ad7:	89 e5                	mov    %esp,%ebp
f0100ad9:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100adc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ae0:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0100ae7:	f0 
f0100ae8:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0100aef:	00 
f0100af0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100af7:	e8 44 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100afc:	c1 ea 0c             	shr    $0xc,%edx
f0100aff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b05:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b0c:	89 c2                	mov    %eax,%edx
f0100b0e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b16:	85 d2                	test   %edx,%edx
f0100b18:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b1d:	0f 44 c2             	cmove  %edx,%eax
f0100b20:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b26:	c3                   	ret    

f0100b27 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b27:	55                   	push   %ebp
f0100b28:	89 e5                	mov    %esp,%ebp
f0100b2a:	57                   	push   %edi
f0100b2b:	56                   	push   %esi
f0100b2c:	53                   	push   %ebx
f0100b2d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b30:	84 c0                	test   %al,%al
f0100b32:	0f 85 31 03 00 00    	jne    f0100e69 <check_page_free_list+0x342>
f0100b38:	e9 3e 03 00 00       	jmp    f0100e7b <check_page_free_list+0x354>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b3d:	c7 44 24 08 9c 72 10 	movl   $0xf010729c,0x8(%esp)
f0100b44:	f0 
f0100b45:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100b4c:	00 
f0100b4d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100b54:	e8 e7 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b59:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b5c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b65:	89 c2                	mov    %eax,%edx
f0100b67:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b6d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b73:	0f 95 c2             	setne  %dl
f0100b76:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b79:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b7d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b7f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b83:	8b 00                	mov    (%eax),%eax
f0100b85:	85 c0                	test   %eax,%eax
f0100b87:	75 dc                	jne    f0100b65 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b95:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b98:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b9a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b9d:	a3 40 02 23 f0       	mov    %eax,0xf0230240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ba7:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f0100bad:	eb 63                	jmp    f0100c12 <check_page_free_list+0xeb>
f0100baf:	89 d8                	mov    %ebx,%eax
f0100bb1:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100bb7:	c1 f8 03             	sar    $0x3,%eax
f0100bba:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bbd:	89 c2                	mov    %eax,%edx
f0100bbf:	c1 ea 16             	shr    $0x16,%edx
f0100bc2:	39 f2                	cmp    %esi,%edx
f0100bc4:	73 4a                	jae    f0100c10 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bc6:	89 c2                	mov    %eax,%edx
f0100bc8:	c1 ea 0c             	shr    $0xc,%edx
f0100bcb:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100bd1:	72 20                	jb     f0100bf3 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bd7:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0100bde:	f0 
f0100bdf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100be6:	00 
f0100be7:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0100bee:	e8 4d f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bf3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100bfa:	00 
f0100bfb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c02:	00 
	return (void *)(pa + KERNBASE);
f0100c03:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c08:	89 04 24             	mov    %eax,(%esp)
f0100c0b:	e8 37 54 00 00       	call   f0106047 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c10:	8b 1b                	mov    (%ebx),%ebx
f0100c12:	85 db                	test   %ebx,%ebx
f0100c14:	75 99                	jne    f0100baf <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c16:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1b:	e8 10 fe ff ff       	call   f0100a30 <boot_alloc>
f0100c20:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c23:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c29:	8b 0d 90 0e 23 f0    	mov    0xf0230e90,%ecx
		assert(pp < pages + npages);
f0100c2f:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0100c34:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c37:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c40:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c45:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c48:	e9 c4 01 00 00       	jmp    f0100e11 <check_page_free_list+0x2ea>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c4d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c50:	73 24                	jae    f0100c76 <check_page_free_list+0x14f>
f0100c52:	c7 44 24 0c d3 7b 10 	movl   $0xf0107bd3,0xc(%esp)
f0100c59:	f0 
f0100c5a:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100c61:	f0 
f0100c62:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100c69:	00 
f0100c6a:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100c71:	e8 ca f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c76:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c79:	72 24                	jb     f0100c9f <check_page_free_list+0x178>
f0100c7b:	c7 44 24 0c f4 7b 10 	movl   $0xf0107bf4,0xc(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100c8a:	f0 
f0100c8b:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0100c92:	00 
f0100c93:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100c9a:	e8 a1 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c9f:	89 d0                	mov    %edx,%eax
f0100ca1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100ca4:	a8 07                	test   $0x7,%al
f0100ca6:	74 24                	je     f0100ccc <check_page_free_list+0x1a5>
f0100ca8:	c7 44 24 0c c0 72 10 	movl   $0xf01072c0,0xc(%esp)
f0100caf:	f0 
f0100cb0:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100cb7:	f0 
f0100cb8:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0100cbf:	00 
f0100cc0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100cc7:	e8 74 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ccc:	c1 f8 03             	sar    $0x3,%eax
f0100ccf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cd2:	85 c0                	test   %eax,%eax
f0100cd4:	75 24                	jne    f0100cfa <check_page_free_list+0x1d3>
f0100cd6:	c7 44 24 0c 08 7c 10 	movl   $0xf0107c08,0xc(%esp)
f0100cdd:	f0 
f0100cde:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100ce5:	f0 
f0100ce6:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0100ced:	00 
f0100cee:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100cf5:	e8 46 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cfa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cff:	75 24                	jne    f0100d25 <check_page_free_list+0x1fe>
f0100d01:	c7 44 24 0c 19 7c 10 	movl   $0xf0107c19,0xc(%esp)
f0100d08:	f0 
f0100d09:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100d10:	f0 
f0100d11:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0100d18:	00 
f0100d19:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100d20:	e8 1b f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d25:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d2a:	75 24                	jne    f0100d50 <check_page_free_list+0x229>
f0100d2c:	c7 44 24 0c f4 72 10 	movl   $0xf01072f4,0xc(%esp)
f0100d33:	f0 
f0100d34:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0100d43:	00 
f0100d44:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100d4b:	e8 f0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d50:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d55:	75 24                	jne    f0100d7b <check_page_free_list+0x254>
f0100d57:	c7 44 24 0c 32 7c 10 	movl   $0xf0107c32,0xc(%esp)
f0100d5e:	f0 
f0100d5f:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100d66:	f0 
f0100d67:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0100d6e:	00 
f0100d6f:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100d76:	e8 c5 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d7b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d80:	0f 86 1c 01 00 00    	jbe    f0100ea2 <check_page_free_list+0x37b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d86:	89 c1                	mov    %eax,%ecx
f0100d88:	c1 e9 0c             	shr    $0xc,%ecx
f0100d8b:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100d8e:	77 20                	ja     f0100db0 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d94:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0100d9b:	f0 
f0100d9c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100da3:	00 
f0100da4:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0100dab:	e8 90 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100db0:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100db6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100db9:	0f 86 d3 00 00 00    	jbe    f0100e92 <check_page_free_list+0x36b>
f0100dbf:	c7 44 24 0c 18 73 10 	movl   $0xf0107318,0xc(%esp)
f0100dc6:	f0 
f0100dc7:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100dce:	f0 
f0100dcf:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0100dd6:	00 
f0100dd7:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100dde:	e8 5d f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100de3:	c7 44 24 0c 4c 7c 10 	movl   $0xf0107c4c,0xc(%esp)
f0100dea:	f0 
f0100deb:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100df2:	f0 
f0100df3:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0100dfa:	00 
f0100dfb:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100e02:	e8 39 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e07:	83 c3 01             	add    $0x1,%ebx
f0100e0a:	eb 03                	jmp    f0100e0f <check_page_free_list+0x2e8>
		else
			++nfree_extmem;
f0100e0c:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e0f:	8b 12                	mov    (%edx),%edx
f0100e11:	85 d2                	test   %edx,%edx
f0100e13:	0f 85 34 fe ff ff    	jne    f0100c4d <check_page_free_list+0x126>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e19:	85 db                	test   %ebx,%ebx
f0100e1b:	7f 24                	jg     f0100e41 <check_page_free_list+0x31a>
f0100e1d:	c7 44 24 0c 69 7c 10 	movl   $0xf0107c69,0xc(%esp)
f0100e24:	f0 
f0100e25:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100e2c:	f0 
f0100e2d:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0100e34:	00 
f0100e35:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100e3c:	e8 ff f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e41:	85 ff                	test   %edi,%edi
f0100e43:	7f 70                	jg     f0100eb5 <check_page_free_list+0x38e>
f0100e45:	c7 44 24 0c 7b 7c 10 	movl   $0xf0107c7b,0xc(%esp)
f0100e4c:	f0 
f0100e4d:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100e64:	e8 d7 f1 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e69:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0100e6e:	85 c0                	test   %eax,%eax
f0100e70:	0f 85 e3 fc ff ff    	jne    f0100b59 <check_page_free_list+0x32>
f0100e76:	e9 c2 fc ff ff       	jmp    f0100b3d <check_page_free_list+0x16>
f0100e7b:	83 3d 40 02 23 f0 00 	cmpl   $0x0,0xf0230240
f0100e82:	0f 84 b5 fc ff ff    	je     f0100b3d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e88:	be 00 04 00 00       	mov    $0x400,%esi
f0100e8d:	e9 15 fd ff ff       	jmp    f0100ba7 <check_page_free_list+0x80>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e92:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e97:	0f 85 6f ff ff ff    	jne    f0100e0c <check_page_free_list+0x2e5>
f0100e9d:	e9 41 ff ff ff       	jmp    f0100de3 <check_page_free_list+0x2bc>
f0100ea2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ea7:	0f 85 5a ff ff ff    	jne    f0100e07 <check_page_free_list+0x2e0>
f0100ead:	8d 76 00             	lea    0x0(%esi),%esi
f0100eb0:	e9 2e ff ff ff       	jmp    f0100de3 <check_page_free_list+0x2bc>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100eb5:	83 c4 4c             	add    $0x4c,%esp
f0100eb8:	5b                   	pop    %ebx
f0100eb9:	5e                   	pop    %esi
f0100eba:	5f                   	pop    %edi
f0100ebb:	5d                   	pop    %ebp
f0100ebc:	c3                   	ret    

f0100ebd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ebd:	55                   	push   %ebp
f0100ebe:	89 e5                	mov    %esp,%ebp
f0100ec0:	56                   	push   %esi
f0100ec1:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ec2:	be 00 00 00 00       	mov    $0x0,%esi
f0100ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ecc:	e9 e1 00 00 00       	jmp    f0100fb2 <page_init+0xf5>
		if(i == 0)
f0100ed1:	85 db                	test   %ebx,%ebx
f0100ed3:	75 16                	jne    f0100eeb <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100ed5:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0100eda:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100ee0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ee6:	e9 c1 00 00 00       	jmp    f0100fac <page_init+0xef>
			}
		else if(i == MPENTRY_PADDR/PGSIZE){
f0100eeb:	83 fb 07             	cmp    $0x7,%ebx
f0100eee:	75 17                	jne    f0100f07 <page_init+0x4a>
				pages[i].pp_ref = 1;
f0100ef0:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0100ef5:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f0100efb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f02:	e9 a5 00 00 00       	jmp    f0100fac <page_init+0xef>
		}
		else if(i>=1 && i<npages_basemem)
f0100f07:	3b 1d 44 02 23 f0    	cmp    0xf0230244,%ebx
f0100f0d:	73 25                	jae    f0100f34 <page_init+0x77>
		{
			pages[i].pp_ref = 0;
f0100f0f:	89 f0                	mov    %esi,%eax
f0100f11:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100f17:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100f1d:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f0100f23:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f25:	89 f0                	mov    %esi,%eax
f0100f27:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100f2d:	a3 40 02 23 f0       	mov    %eax,0xf0230240
f0100f32:	eb 78                	jmp    f0100fac <page_init+0xef>
f0100f34:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100f3a:	83 f8 5f             	cmp    $0x5f,%eax
f0100f3d:	77 16                	ja     f0100f55 <page_init+0x98>
		{
			pages[i].pp_ref = 1;
f0100f3f:	89 f0                	mov    %esi,%eax
f0100f41:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100f47:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100f4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f53:	eb 57                	jmp    f0100fac <page_init+0xef>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f55:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f5b:	76 2c                	jbe    f0100f89 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100f5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f62:	e8 c9 fa ff ff       	call   f0100a30 <boot_alloc>
f0100f67:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f6c:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100f6f:	39 c3                	cmp    %eax,%ebx
f0100f71:	73 16                	jae    f0100f89 <page_init+0xcc>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100f73:	89 f0                	mov    %esi,%eax
f0100f75:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100f7b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100f81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f87:	eb 23                	jmp    f0100fac <page_init+0xef>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100f89:	89 f0                	mov    %esi,%eax
f0100f8b:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100f91:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f97:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f0100f9d:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100f9f:	89 f0                	mov    %esi,%eax
f0100fa1:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100fa7:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100fac:	83 c3 01             	add    $0x1,%ebx
f0100faf:	83 c6 08             	add    $0x8,%esi
f0100fb2:	3b 1d 88 0e 23 f0    	cmp    0xf0230e88,%ebx
f0100fb8:	0f 82 13 ff ff ff    	jb     f0100ed1 <page_init+0x14>
			page_free_list = &pages[i];
		}

	}

}
f0100fbe:	5b                   	pop    %ebx
f0100fbf:	5e                   	pop    %esi
f0100fc0:	5d                   	pop    %ebp
f0100fc1:	c3                   	ret    

f0100fc2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fc2:	55                   	push   %ebp
f0100fc3:	89 e5                	mov    %esp,%ebp
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100fc9:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f0100fcf:	85 db                	test   %ebx,%ebx
f0100fd1:	74 6f                	je     f0101042 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100fd3:	8b 03                	mov    (%ebx),%eax
f0100fd5:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	page->pp_link = 0;
f0100fda:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f0100fe0:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f0100fe2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fe6:	74 5f                	je     f0101047 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fe8:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100fee:	c1 f8 03             	sar    $0x3,%eax
f0100ff1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff4:	89 c2                	mov    %eax,%edx
f0100ff6:	c1 ea 0c             	shr    $0xc,%edx
f0100ff9:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100fff:	72 20                	jb     f0101021 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101001:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101005:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f010100c:	f0 
f010100d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101014:	00 
f0101015:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f010101c:	e8 1f f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0101021:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101028:	00 
f0101029:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101030:	00 
	return (void *)(pa + KERNBASE);
f0101031:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101036:	89 04 24             	mov    %eax,(%esp)
f0101039:	e8 09 50 00 00       	call   f0106047 <memset>
	return page;
f010103e:	89 d8                	mov    %ebx,%eax
f0101040:	eb 05                	jmp    f0101047 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0101042:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
	return 0;
}
f0101047:	83 c4 14             	add    $0x14,%esp
f010104a:	5b                   	pop    %ebx
f010104b:	5d                   	pop    %ebp
f010104c:	c3                   	ret    

f010104d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010104d:	55                   	push   %ebp
f010104e:	89 e5                	mov    %esp,%ebp
f0101050:	83 ec 18             	sub    $0x18,%esp
f0101053:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0101056:	83 38 00             	cmpl   $0x0,(%eax)
f0101059:	75 07                	jne    f0101062 <page_free+0x15>
f010105b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101060:	74 1c                	je     f010107e <page_free+0x31>
		panic("page_free is not right");
f0101062:	c7 44 24 08 8c 7c 10 	movl   $0xf0107c8c,0x8(%esp)
f0101069:	f0 
f010106a:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
f0101071:	00 
f0101072:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101079:	e8 c2 ef ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010107e:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f0101084:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101086:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	return; 
}
f010108b:	c9                   	leave  
f010108c:	c3                   	ret    

f010108d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010108d:	55                   	push   %ebp
f010108e:	89 e5                	mov    %esp,%ebp
f0101090:	83 ec 18             	sub    $0x18,%esp
f0101093:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101096:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010109a:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010109d:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010a1:	66 85 d2             	test   %dx,%dx
f01010a4:	75 08                	jne    f01010ae <page_decref+0x21>
		page_free(pp);
f01010a6:	89 04 24             	mov    %eax,(%esp)
f01010a9:	e8 9f ff ff ff       	call   f010104d <page_free>
}
f01010ae:	c9                   	leave  
f01010af:	c3                   	ret    

f01010b0 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010b0:	55                   	push   %ebp
f01010b1:	89 e5                	mov    %esp,%ebp
f01010b3:	56                   	push   %esi
f01010b4:	53                   	push   %ebx
f01010b5:	83 ec 10             	sub    $0x10,%esp
f01010b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f01010bb:	89 f3                	mov    %esi,%ebx
f01010bd:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f01010c0:	c1 e3 02             	shl    $0x2,%ebx
f01010c3:	03 5d 08             	add    0x8(%ebp),%ebx
f01010c6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010c9:	75 2c                	jne    f01010f7 <pgdir_walk+0x47>
f01010cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010cf:	74 6c                	je     f010113d <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f01010d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010d8:	e8 e5 fe ff ff       	call   f0100fc2 <page_alloc>
		if(page == NULL)
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	74 63                	je     f0101144 <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f01010e1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010e6:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f01010ec:	c1 f8 03             	sar    $0x3,%eax
f01010ef:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f01010f2:	83 c8 07             	or     $0x7,%eax
f01010f5:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f01010f7:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd & (~0x3ff);
f01010f9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f01010fe:	c1 ee 0c             	shr    $0xc,%esi
f0101101:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101107:	89 c2                	mov    %eax,%edx
f0101109:	c1 ea 0c             	shr    $0xc,%edx
f010110c:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0101112:	72 20                	jb     f0101134 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101114:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101118:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f010111f:	f0 
f0101120:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
f0101127:	00 
f0101128:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010112f:	e8 0c ef ff ff       	call   f0100040 <_panic>
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
f0101134:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010113b:	eb 0c                	jmp    f0101149 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f010113d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101142:	eb 05                	jmp    f0101149 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0101144:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd & (~0x3ff);
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t* pte = (pte_t *)KADDR(pgAdd) + pteIndex;
	return pte;
}
f0101149:	83 c4 10             	add    $0x10,%esp
f010114c:	5b                   	pop    %ebx
f010114d:	5e                   	pop    %esi
f010114e:	5d                   	pop    %ebp
f010114f:	c3                   	ret    

f0101150 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	57                   	push   %edi
f0101154:	56                   	push   %esi
f0101155:	53                   	push   %ebx
f0101156:	83 ec 2c             	sub    $0x2c,%esp
f0101159:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010115c:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size)
f010115e:	89 d3                	mov    %edx,%ebx
f0101160:	8b 45 08             	mov    0x8(%ebp),%eax
f0101163:	29 d0                	sub    %edx,%eax
f0101165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0101168:	8b 45 0c             	mov    0xc(%ebp),%eax
f010116b:	83 c8 01             	or     $0x1,%eax
f010116e:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0101171:	eb 2c                	jmp    f010119f <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0101173:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010117a:	00 
f010117b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010117f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101182:	89 04 24             	mov    %eax,(%esp)
f0101185:	e8 26 ff ff ff       	call   f01010b0 <pgdir_walk>
		if(pte == NULL)
f010118a:	85 c0                	test   %eax,%eax
f010118c:	74 1b                	je     f01011a9 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f010118e:	0b 7d dc             	or     -0x24(%ebp),%edi
f0101191:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f0101193:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f0101199:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010119f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011a2:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f01011a5:	85 f6                	test   %esi,%esi
f01011a7:	75 ca                	jne    f0101173 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f01011a9:	83 c4 2c             	add    $0x2c,%esp
f01011ac:	5b                   	pop    %ebx
f01011ad:	5e                   	pop    %esi
f01011ae:	5f                   	pop    %edi
f01011af:	5d                   	pop    %ebp
f01011b0:	c3                   	ret    

f01011b1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011b1:	55                   	push   %ebp
f01011b2:	89 e5                	mov    %esp,%ebp
f01011b4:	53                   	push   %ebx
f01011b5:	83 ec 14             	sub    $0x14,%esp
f01011b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f01011bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011c2:	00 
f01011c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01011cd:	89 04 24             	mov    %eax,(%esp)
f01011d0:	e8 db fe ff ff       	call   f01010b0 <pgdir_walk>
	if(pte == NULL)
f01011d5:	85 c0                	test   %eax,%eax
f01011d7:	74 42                	je     f010121b <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f01011d9:	8b 10                	mov    (%eax),%edx
f01011db:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f01011e1:	85 db                	test   %ebx,%ebx
f01011e3:	74 02                	je     f01011e7 <page_lookup+0x36>
		*pte_store = pte ;
f01011e5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e7:	89 d0                	mov    %edx,%eax
f01011e9:	c1 e8 0c             	shr    $0xc,%eax
f01011ec:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f01011f2:	72 1c                	jb     f0101210 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f01011f4:	c7 44 24 08 60 73 10 	movl   $0xf0107360,0x8(%esp)
f01011fb:	f0 
f01011fc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101203:	00 
f0101204:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f010120b:	e8 30 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101210:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0101216:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f0101219:	eb 05                	jmp    f0101220 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f010121b:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f0101220:	83 c4 14             	add    $0x14,%esp
f0101223:	5b                   	pop    %ebx
f0101224:	5d                   	pop    %ebp
f0101225:	c3                   	ret    

f0101226 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101226:	55                   	push   %ebp
f0101227:	89 e5                	mov    %esp,%ebp
f0101229:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010122c:	e8 68 54 00 00       	call   f0106699 <cpunum>
f0101231:	6b c0 74             	imul   $0x74,%eax,%eax
f0101234:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010123b:	74 16                	je     f0101253 <tlb_invalidate+0x2d>
f010123d:	e8 57 54 00 00       	call   f0106699 <cpunum>
f0101242:	6b c0 74             	imul   $0x74,%eax,%eax
f0101245:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010124b:	8b 55 08             	mov    0x8(%ebp),%edx
f010124e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101251:	75 06                	jne    f0101259 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101253:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101256:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101259:	c9                   	leave  
f010125a:	c3                   	ret    

f010125b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	56                   	push   %esi
f010125f:	53                   	push   %ebx
f0101260:	83 ec 20             	sub    $0x20,%esp
f0101263:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101266:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101269:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010126c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101270:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101274:	89 1c 24             	mov    %ebx,(%esp)
f0101277:	e8 35 ff ff ff       	call   f01011b1 <page_lookup>
	if(page == 0)
f010127c:	85 c0                	test   %eax,%eax
f010127e:	74 2d                	je     f01012ad <page_remove+0x52>
		return;
	*pte = 0;
f0101280:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101283:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f0101289:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010128d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101290:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f0101294:	66 85 d2             	test   %dx,%dx
f0101297:	75 08                	jne    f01012a1 <page_remove+0x46>
		page_free(page);
f0101299:	89 04 24             	mov    %eax,(%esp)
f010129c:	e8 ac fd ff ff       	call   f010104d <page_free>
	tlb_invalidate(pgdir, va);
f01012a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012a5:	89 1c 24             	mov    %ebx,(%esp)
f01012a8:	e8 79 ff ff ff       	call   f0101226 <tlb_invalidate>
}
f01012ad:	83 c4 20             	add    $0x20,%esp
f01012b0:	5b                   	pop    %ebx
f01012b1:	5e                   	pop    %esi
f01012b2:	5d                   	pop    %ebp
f01012b3:	c3                   	ret    

f01012b4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012b4:	55                   	push   %ebp
f01012b5:	89 e5                	mov    %esp,%ebp
f01012b7:	57                   	push   %edi
f01012b8:	56                   	push   %esi
f01012b9:	53                   	push   %ebx
f01012ba:	83 ec 1c             	sub    $0x1c,%esp
f01012bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012c0:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01012c3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012ca:	00 
f01012cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01012d2:	89 04 24             	mov    %eax,(%esp)
f01012d5:	e8 d6 fd ff ff       	call   f01010b0 <pgdir_walk>
f01012da:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f01012dc:	85 c0                	test   %eax,%eax
f01012de:	74 5a                	je     f010133a <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f01012e0:	8b 00                	mov    (%eax),%eax
f01012e2:	89 c1                	mov    %eax,%ecx
f01012e4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012ea:	89 da                	mov    %ebx,%edx
f01012ec:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01012f2:	c1 fa 03             	sar    $0x3,%edx
f01012f5:	c1 e2 0c             	shl    $0xc,%edx
f01012f8:	39 d1                	cmp    %edx,%ecx
f01012fa:	75 07                	jne    f0101303 <page_insert+0x4f>
		pp->pp_ref--;
f01012fc:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101301:	eb 13                	jmp    f0101316 <page_insert+0x62>
	
	else if(*pte != 0)
f0101303:	85 c0                	test   %eax,%eax
f0101305:	74 0f                	je     f0101316 <page_insert+0x62>
		page_remove(pgdir, va);
f0101307:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010130b:	8b 45 08             	mov    0x8(%ebp),%eax
f010130e:	89 04 24             	mov    %eax,(%esp)
f0101311:	e8 45 ff ff ff       	call   f010125b <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f0101316:	8b 55 14             	mov    0x14(%ebp),%edx
f0101319:	83 ca 01             	or     $0x1,%edx
f010131c:	89 d8                	mov    %ebx,%eax
f010131e:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0101324:	c1 f8 03             	sar    $0x3,%eax
f0101327:	c1 e0 0c             	shl    $0xc,%eax
f010132a:	09 d0                	or     %edx,%eax
f010132c:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010132e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101333:	b8 00 00 00 00       	mov    $0x0,%eax
f0101338:	eb 05                	jmp    f010133f <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f010133a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010133f:	83 c4 1c             	add    $0x1c,%esp
f0101342:	5b                   	pop    %ebx
f0101343:	5e                   	pop    %esi
f0101344:	5f                   	pop    %edi
f0101345:	5d                   	pop    %ebp
f0101346:	c3                   	ret    

f0101347 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101347:	55                   	push   %ebp
f0101348:	89 e5                	mov    %esp,%ebp
f010134a:	53                   	push   %ebx
f010134b:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010134e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101351:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101357:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010135d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101360:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if(size + base >= MMIOLIM)
f0101366:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010136c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010136f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101374:	76 1c                	jbe    f0101392 <mmio_map_region+0x4b>
		panic("mmio_map_region not implemented");
f0101376:	c7 44 24 08 80 73 10 	movl   $0xf0107380,0x8(%esp)
f010137d:	f0 
f010137e:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0101385:	00 
f0101386:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010138d:	e8 ae ec ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101392:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101399:	00 
f010139a:	89 0c 24             	mov    %ecx,(%esp)
f010139d:	89 d9                	mov    %ebx,%ecx
f010139f:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01013a4:	e8 a7 fd ff ff       	call   f0101150 <boot_map_region>
	uintptr_t ret = base;
f01013a9:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base +size;
f01013ae:	01 c3                	add    %eax,%ebx
f01013b0:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) ret;

}
f01013b6:	83 c4 14             	add    $0x14,%esp
f01013b9:	5b                   	pop    %ebx
f01013ba:	5d                   	pop    %ebp
f01013bb:	c3                   	ret    

f01013bc <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013bc:	55                   	push   %ebp
f01013bd:	89 e5                	mov    %esp,%ebp
f01013bf:	57                   	push   %edi
f01013c0:	56                   	push   %esi
f01013c1:	53                   	push   %ebx
f01013c2:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013c5:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01013cc:	e8 2b 2a 00 00       	call   f0103dfc <mc146818_read>
f01013d1:	89 c3                	mov    %eax,%ebx
f01013d3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013da:	e8 1d 2a 00 00       	call   f0103dfc <mc146818_read>
f01013df:	c1 e0 08             	shl    $0x8,%eax
f01013e2:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013e4:	89 d8                	mov    %ebx,%eax
f01013e6:	c1 e0 0a             	shl    $0xa,%eax
f01013e9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013ef:	85 c0                	test   %eax,%eax
f01013f1:	0f 48 c2             	cmovs  %edx,%eax
f01013f4:	c1 f8 0c             	sar    $0xc,%eax
f01013f7:	a3 44 02 23 f0       	mov    %eax,0xf0230244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013fc:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101403:	e8 f4 29 00 00       	call   f0103dfc <mc146818_read>
f0101408:	89 c3                	mov    %eax,%ebx
f010140a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101411:	e8 e6 29 00 00       	call   f0103dfc <mc146818_read>
f0101416:	c1 e0 08             	shl    $0x8,%eax
f0101419:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010141b:	89 d8                	mov    %ebx,%eax
f010141d:	c1 e0 0a             	shl    $0xa,%eax
f0101420:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101426:	85 c0                	test   %eax,%eax
f0101428:	0f 48 c2             	cmovs  %edx,%eax
f010142b:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010142e:	85 c0                	test   %eax,%eax
f0101430:	74 0e                	je     f0101440 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101432:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101438:	89 15 88 0e 23 f0    	mov    %edx,0xf0230e88
f010143e:	eb 0c                	jmp    f010144c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101440:	8b 15 44 02 23 f0    	mov    0xf0230244,%edx
f0101446:	89 15 88 0e 23 f0    	mov    %edx,0xf0230e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010144c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010144f:	c1 e8 0a             	shr    $0xa,%eax
f0101452:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101456:	a1 44 02 23 f0       	mov    0xf0230244,%eax
f010145b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010145e:	c1 e8 0a             	shr    $0xa,%eax
f0101461:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101465:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f010146a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010146d:	c1 e8 0a             	shr    $0xa,%eax
f0101470:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101474:	c7 04 24 a0 73 10 f0 	movl   $0xf01073a0,(%esp)
f010147b:	e8 e5 2a 00 00       	call   f0103f65 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101480:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101485:	e8 a6 f5 ff ff       	call   f0100a30 <boot_alloc>
f010148a:	a3 8c 0e 23 f0       	mov    %eax,0xf0230e8c
	memset(kern_pgdir, 0, PGSIZE);
f010148f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101496:	00 
f0101497:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010149e:	00 
f010149f:	89 04 24             	mov    %eax,(%esp)
f01014a2:	e8 a0 4b 00 00       	call   f0106047 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014a7:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014b1:	77 20                	ja     f01014d3 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014b7:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01014ce:	e8 6d eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01014d3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014d9:	83 ca 05             	or     $0x5,%edx
f01014dc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f01014e2:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f01014e7:	c1 e0 03             	shl    $0x3,%eax
f01014ea:	e8 41 f5 ff ff       	call   f0100a30 <boot_alloc>
f01014ef:	a3 90 0e 23 f0       	mov    %eax,0xf0230e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f01014f4:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f01014fa:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101501:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101505:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010150c:	00 
f010150d:	89 04 24             	mov    %eax,(%esp)
f0101510:	e8 32 4b 00 00       	call   f0106047 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101515:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010151a:	e8 11 f5 ff ff       	call   f0100a30 <boot_alloc>
f010151f:	a3 48 02 23 f0       	mov    %eax,0xf0230248
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101524:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010152b:	00 
f010152c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101533:	00 
f0101534:	89 04 24             	mov    %eax,(%esp)
f0101537:	e8 0b 4b 00 00       	call   f0106047 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010153c:	e8 7c f9 ff ff       	call   f0100ebd <page_init>

	check_page_free_list(1);
f0101541:	b8 01 00 00 00       	mov    $0x1,%eax
f0101546:	e8 dc f5 ff ff       	call   f0100b27 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010154b:	83 3d 90 0e 23 f0 00 	cmpl   $0x0,0xf0230e90
f0101552:	75 1c                	jne    f0101570 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f0101554:	c7 44 24 08 a3 7c 10 	movl   $0xf0107ca3,0x8(%esp)
f010155b:	f0 
f010155c:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101563:	00 
f0101564:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010156b:	e8 d0 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101570:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101575:	bb 00 00 00 00       	mov    $0x0,%ebx
f010157a:	eb 05                	jmp    f0101581 <mem_init+0x1c5>
		++nfree;
f010157c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010157f:	8b 00                	mov    (%eax),%eax
f0101581:	85 c0                	test   %eax,%eax
f0101583:	75 f7                	jne    f010157c <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158c:	e8 31 fa ff ff       	call   f0100fc2 <page_alloc>
f0101591:	89 c7                	mov    %eax,%edi
f0101593:	85 c0                	test   %eax,%eax
f0101595:	75 24                	jne    f01015bb <mem_init+0x1ff>
f0101597:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f010159e:	f0 
f010159f:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01015a6:	f0 
f01015a7:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01015ae:	00 
f01015af:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01015b6:	e8 85 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c2:	e8 fb f9 ff ff       	call   f0100fc2 <page_alloc>
f01015c7:	89 c6                	mov    %eax,%esi
f01015c9:	85 c0                	test   %eax,%eax
f01015cb:	75 24                	jne    f01015f1 <mem_init+0x235>
f01015cd:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f01015d4:	f0 
f01015d5:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01015dc:	f0 
f01015dd:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01015e4:	00 
f01015e5:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01015ec:	e8 4f ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f8:	e8 c5 f9 ff ff       	call   f0100fc2 <page_alloc>
f01015fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101600:	85 c0                	test   %eax,%eax
f0101602:	75 24                	jne    f0101628 <mem_init+0x26c>
f0101604:	c7 44 24 0c ea 7c 10 	movl   $0xf0107cea,0xc(%esp)
f010160b:	f0 
f010160c:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101613:	f0 
f0101614:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f010161b:	00 
f010161c:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101623:	e8 18 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101628:	39 f7                	cmp    %esi,%edi
f010162a:	75 24                	jne    f0101650 <mem_init+0x294>
f010162c:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f0101633:	f0 
f0101634:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010163b:	f0 
f010163c:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101643:	00 
f0101644:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010164b:	e8 f0 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101653:	39 c6                	cmp    %eax,%esi
f0101655:	74 04                	je     f010165b <mem_init+0x29f>
f0101657:	39 c7                	cmp    %eax,%edi
f0101659:	75 24                	jne    f010167f <mem_init+0x2c3>
f010165b:	c7 44 24 0c dc 73 10 	movl   $0xf01073dc,0xc(%esp)
f0101662:	f0 
f0101663:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010166a:	f0 
f010166b:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101672:	00 
f0101673:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010167a:	e8 c1 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010167f:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101685:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f010168a:	c1 e0 0c             	shl    $0xc,%eax
f010168d:	89 f9                	mov    %edi,%ecx
f010168f:	29 d1                	sub    %edx,%ecx
f0101691:	c1 f9 03             	sar    $0x3,%ecx
f0101694:	c1 e1 0c             	shl    $0xc,%ecx
f0101697:	39 c1                	cmp    %eax,%ecx
f0101699:	72 24                	jb     f01016bf <mem_init+0x303>
f010169b:	c7 44 24 0c 12 7d 10 	movl   $0xf0107d12,0xc(%esp)
f01016a2:	f0 
f01016a3:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01016aa:	f0 
f01016ab:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f01016b2:	00 
f01016b3:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
f01016bf:	89 f1                	mov    %esi,%ecx
f01016c1:	29 d1                	sub    %edx,%ecx
f01016c3:	c1 f9 03             	sar    $0x3,%ecx
f01016c6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016c9:	39 c8                	cmp    %ecx,%eax
f01016cb:	77 24                	ja     f01016f1 <mem_init+0x335>
f01016cd:	c7 44 24 0c 2f 7d 10 	movl   $0xf0107d2f,0xc(%esp)
f01016d4:	f0 
f01016d5:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01016dc:	f0 
f01016dd:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f01016e4:	00 
f01016e5:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01016ec:	e8 4f e9 ff ff       	call   f0100040 <_panic>
f01016f1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016f4:	29 d1                	sub    %edx,%ecx
f01016f6:	89 ca                	mov    %ecx,%edx
f01016f8:	c1 fa 03             	sar    $0x3,%edx
f01016fb:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01016fe:	39 d0                	cmp    %edx,%eax
f0101700:	77 24                	ja     f0101726 <mem_init+0x36a>
f0101702:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f0101709:	f0 
f010170a:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101711:	f0 
f0101712:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0101719:	00 
f010171a:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101721:	e8 1a e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101726:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f010172b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010172e:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f0101735:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010173f:	e8 7e f8 ff ff       	call   f0100fc2 <page_alloc>
f0101744:	85 c0                	test   %eax,%eax
f0101746:	74 24                	je     f010176c <mem_init+0x3b0>
f0101748:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f010174f:	f0 
f0101750:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101757:	f0 
f0101758:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010175f:	00 
f0101760:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101767:	e8 d4 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010176c:	89 3c 24             	mov    %edi,(%esp)
f010176f:	e8 d9 f8 ff ff       	call   f010104d <page_free>
	page_free(pp1);
f0101774:	89 34 24             	mov    %esi,(%esp)
f0101777:	e8 d1 f8 ff ff       	call   f010104d <page_free>
	page_free(pp2);
f010177c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010177f:	89 04 24             	mov    %eax,(%esp)
f0101782:	e8 c6 f8 ff ff       	call   f010104d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010178e:	e8 2f f8 ff ff       	call   f0100fc2 <page_alloc>
f0101793:	89 c6                	mov    %eax,%esi
f0101795:	85 c0                	test   %eax,%eax
f0101797:	75 24                	jne    f01017bd <mem_init+0x401>
f0101799:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f01017a0:	f0 
f01017a1:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01017a8:	f0 
f01017a9:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01017b0:	00 
f01017b1:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01017b8:	e8 83 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c4:	e8 f9 f7 ff ff       	call   f0100fc2 <page_alloc>
f01017c9:	89 c7                	mov    %eax,%edi
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	75 24                	jne    f01017f3 <mem_init+0x437>
f01017cf:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01017de:	f0 
f01017df:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01017e6:	00 
f01017e7:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01017ee:	e8 4d e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017fa:	e8 c3 f7 ff ff       	call   f0100fc2 <page_alloc>
f01017ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101802:	85 c0                	test   %eax,%eax
f0101804:	75 24                	jne    f010182a <mem_init+0x46e>
f0101806:	c7 44 24 0c ea 7c 10 	movl   $0xf0107cea,0xc(%esp)
f010180d:	f0 
f010180e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101815:	f0 
f0101816:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010181d:	00 
f010181e:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101825:	e8 16 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010182a:	39 fe                	cmp    %edi,%esi
f010182c:	75 24                	jne    f0101852 <mem_init+0x496>
f010182e:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010184d:	e8 ee e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101852:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101855:	39 c7                	cmp    %eax,%edi
f0101857:	74 04                	je     f010185d <mem_init+0x4a1>
f0101859:	39 c6                	cmp    %eax,%esi
f010185b:	75 24                	jne    f0101881 <mem_init+0x4c5>
f010185d:	c7 44 24 0c dc 73 10 	movl   $0xf01073dc,0xc(%esp)
f0101864:	f0 
f0101865:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010186c:	f0 
f010186d:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101874:	00 
f0101875:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010187c:	e8 bf e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101881:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101888:	e8 35 f7 ff ff       	call   f0100fc2 <page_alloc>
f010188d:	85 c0                	test   %eax,%eax
f010188f:	74 24                	je     f01018b5 <mem_init+0x4f9>
f0101891:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101898:	f0 
f0101899:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01018a0:	f0 
f01018a1:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01018a8:	00 
f01018a9:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01018b0:	e8 8b e7 ff ff       	call   f0100040 <_panic>
f01018b5:	89 f0                	mov    %esi,%eax
f01018b7:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f01018bd:	c1 f8 03             	sar    $0x3,%eax
f01018c0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c3:	89 c2                	mov    %eax,%edx
f01018c5:	c1 ea 0c             	shr    $0xc,%edx
f01018c8:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f01018ce:	72 20                	jb     f01018f0 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018d4:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f01018db:	f0 
f01018dc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018e3:	00 
f01018e4:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f01018eb:	e8 50 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018f7:	00 
f01018f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01018ff:	00 
	return (void *)(pa + KERNBASE);
f0101900:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101905:	89 04 24             	mov    %eax,(%esp)
f0101908:	e8 3a 47 00 00       	call   f0106047 <memset>
	page_free(pp0);
f010190d:	89 34 24             	mov    %esi,(%esp)
f0101910:	e8 38 f7 ff ff       	call   f010104d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101915:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010191c:	e8 a1 f6 ff ff       	call   f0100fc2 <page_alloc>
f0101921:	85 c0                	test   %eax,%eax
f0101923:	75 24                	jne    f0101949 <mem_init+0x58d>
f0101925:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f010192c:	f0 
f010192d:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101934:	f0 
f0101935:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f010193c:	00 
f010193d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101944:	e8 f7 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101949:	39 c6                	cmp    %eax,%esi
f010194b:	74 24                	je     f0101971 <mem_init+0x5b5>
f010194d:	c7 44 24 0c 96 7d 10 	movl   $0xf0107d96,0xc(%esp)
f0101954:	f0 
f0101955:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010195c:	f0 
f010195d:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101964:	00 
f0101965:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010196c:	e8 cf e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101971:	89 f0                	mov    %esi,%eax
f0101973:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0101979:	c1 f8 03             	sar    $0x3,%eax
f010197c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010197f:	89 c2                	mov    %eax,%edx
f0101981:	c1 ea 0c             	shr    $0xc,%edx
f0101984:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f010198a:	72 20                	jb     f01019ac <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010198c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101990:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0101997:	f0 
f0101998:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010199f:	00 
f01019a0:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f01019a7:	e8 94 e6 ff ff       	call   f0100040 <_panic>
f01019ac:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01019b2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01019b8:	80 38 00             	cmpb   $0x0,(%eax)
f01019bb:	74 24                	je     f01019e1 <mem_init+0x625>
f01019bd:	c7 44 24 0c a6 7d 10 	movl   $0xf0107da6,0xc(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01019cc:	f0 
f01019cd:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f01019d4:	00 
f01019d5:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01019dc:	e8 5f e6 ff ff       	call   f0100040 <_panic>
f01019e1:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01019e4:	39 d0                	cmp    %edx,%eax
f01019e6:	75 d0                	jne    f01019b8 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01019e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019eb:	a3 40 02 23 f0       	mov    %eax,0xf0230240

	// free the pages we took
	page_free(pp0);
f01019f0:	89 34 24             	mov    %esi,(%esp)
f01019f3:	e8 55 f6 ff ff       	call   f010104d <page_free>
	page_free(pp1);
f01019f8:	89 3c 24             	mov    %edi,(%esp)
f01019fb:	e8 4d f6 ff ff       	call   f010104d <page_free>
	page_free(pp2);
f0101a00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a03:	89 04 24             	mov    %eax,(%esp)
f0101a06:	e8 42 f6 ff ff       	call   f010104d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a0b:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101a10:	eb 05                	jmp    f0101a17 <mem_init+0x65b>
		--nfree;
f0101a12:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a15:	8b 00                	mov    (%eax),%eax
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	75 f7                	jne    f0101a12 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f0101a1b:	85 db                	test   %ebx,%ebx
f0101a1d:	74 24                	je     f0101a43 <mem_init+0x687>
f0101a1f:	c7 44 24 0c b0 7d 10 	movl   $0xf0107db0,0xc(%esp)
f0101a26:	f0 
f0101a27:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101a2e:	f0 
f0101a2f:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101a36:	00 
f0101a37:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101a3e:	e8 fd e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a43:	c7 04 24 fc 73 10 f0 	movl   $0xf01073fc,(%esp)
f0101a4a:	e8 16 25 00 00       	call   f0103f65 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a56:	e8 67 f5 ff ff       	call   f0100fc2 <page_alloc>
f0101a5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a5e:	85 c0                	test   %eax,%eax
f0101a60:	75 24                	jne    f0101a86 <mem_init+0x6ca>
f0101a62:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101a81:	e8 ba e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a8d:	e8 30 f5 ff ff       	call   f0100fc2 <page_alloc>
f0101a92:	89 c3                	mov    %eax,%ebx
f0101a94:	85 c0                	test   %eax,%eax
f0101a96:	75 24                	jne    f0101abc <mem_init+0x700>
f0101a98:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101aa7:	f0 
f0101aa8:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101aaf:	00 
f0101ab0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101ab7:	e8 84 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101abc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ac3:	e8 fa f4 ff ff       	call   f0100fc2 <page_alloc>
f0101ac8:	89 c6                	mov    %eax,%esi
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	75 24                	jne    f0101af2 <mem_init+0x736>
f0101ace:	c7 44 24 0c ea 7c 10 	movl   $0xf0107cea,0xc(%esp)
f0101ad5:	f0 
f0101ad6:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101add:	f0 
f0101ade:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0101ae5:	00 
f0101ae6:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101aed:	e8 4e e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101af2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101af5:	75 24                	jne    f0101b1b <mem_init+0x75f>
f0101af7:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101b06:	f0 
f0101b07:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101b0e:	00 
f0101b0f:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101b16:	e8 25 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b1b:	39 c3                	cmp    %eax,%ebx
f0101b1d:	74 05                	je     f0101b24 <mem_init+0x768>
f0101b1f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b22:	75 24                	jne    f0101b48 <mem_init+0x78c>
f0101b24:	c7 44 24 0c dc 73 10 	movl   $0xf01073dc,0xc(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101b33:	f0 
f0101b34:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101b3b:	00 
f0101b3c:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101b43:	e8 f8 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b48:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101b4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b50:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f0101b57:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b61:	e8 5c f4 ff ff       	call   f0100fc2 <page_alloc>
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	74 24                	je     f0101b8e <mem_init+0x7d2>
f0101b6a:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101b71:	f0 
f0101b72:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101b79:	f0 
f0101b7a:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101b81:	00 
f0101b82:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101b89:	e8 b2 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b91:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b9c:	00 
f0101b9d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101ba2:	89 04 24             	mov    %eax,(%esp)
f0101ba5:	e8 07 f6 ff ff       	call   f01011b1 <page_lookup>
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	74 24                	je     f0101bd2 <mem_init+0x816>
f0101bae:	c7 44 24 0c 1c 74 10 	movl   $0xf010741c,0xc(%esp)
f0101bb5:	f0 
f0101bb6:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101bbd:	f0 
f0101bbe:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101bc5:	00 
f0101bc6:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101bcd:	e8 6e e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bd2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bd9:	00 
f0101bda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101be1:	00 
f0101be2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101be6:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101beb:	89 04 24             	mov    %eax,(%esp)
f0101bee:	e8 c1 f6 ff ff       	call   f01012b4 <page_insert>
f0101bf3:	85 c0                	test   %eax,%eax
f0101bf5:	78 24                	js     f0101c1b <mem_init+0x85f>
f0101bf7:	c7 44 24 0c 54 74 10 	movl   $0xf0107454,0xc(%esp)
f0101bfe:	f0 
f0101bff:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101c06:	f0 
f0101c07:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101c0e:	00 
f0101c0f:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101c16:	e8 25 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c1e:	89 04 24             	mov    %eax,(%esp)
f0101c21:	e8 27 f4 ff ff       	call   f010104d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c26:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c2d:	00 
f0101c2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c35:	00 
f0101c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c3a:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101c3f:	89 04 24             	mov    %eax,(%esp)
f0101c42:	e8 6d f6 ff ff       	call   f01012b4 <page_insert>
f0101c47:	85 c0                	test   %eax,%eax
f0101c49:	74 24                	je     f0101c6f <mem_init+0x8b3>
f0101c4b:	c7 44 24 0c 84 74 10 	movl   $0xf0107484,0xc(%esp)
f0101c52:	f0 
f0101c53:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101c5a:	f0 
f0101c5b:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101c62:	00 
f0101c63:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101c6a:	e8 d1 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c6f:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c75:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0101c7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c7d:	8b 17                	mov    (%edi),%edx
f0101c7f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c85:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c88:	29 c1                	sub    %eax,%ecx
f0101c8a:	89 c8                	mov    %ecx,%eax
f0101c8c:	c1 f8 03             	sar    $0x3,%eax
f0101c8f:	c1 e0 0c             	shl    $0xc,%eax
f0101c92:	39 c2                	cmp    %eax,%edx
f0101c94:	74 24                	je     f0101cba <mem_init+0x8fe>
f0101c96:	c7 44 24 0c b4 74 10 	movl   $0xf01074b4,0xc(%esp)
f0101c9d:	f0 
f0101c9e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101ca5:	f0 
f0101ca6:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101cad:	00 
f0101cae:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101cb5:	e8 86 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cba:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cbf:	89 f8                	mov    %edi,%eax
f0101cc1:	e8 f2 ed ff ff       	call   f0100ab8 <check_va2pa>
f0101cc6:	89 da                	mov    %ebx,%edx
f0101cc8:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ccb:	c1 fa 03             	sar    $0x3,%edx
f0101cce:	c1 e2 0c             	shl    $0xc,%edx
f0101cd1:	39 d0                	cmp    %edx,%eax
f0101cd3:	74 24                	je     f0101cf9 <mem_init+0x93d>
f0101cd5:	c7 44 24 0c dc 74 10 	movl   $0xf01074dc,0xc(%esp)
f0101cdc:	f0 
f0101cdd:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0101cec:	00 
f0101ced:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101cf4:	e8 47 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101cf9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cfe:	74 24                	je     f0101d24 <mem_init+0x968>
f0101d00:	c7 44 24 0c bb 7d 10 	movl   $0xf0107dbb,0xc(%esp)
f0101d07:	f0 
f0101d08:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101d0f:	f0 
f0101d10:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101d17:	00 
f0101d18:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101d1f:	e8 1c e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d27:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d2c:	74 24                	je     f0101d52 <mem_init+0x996>
f0101d2e:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f0101d35:	f0 
f0101d36:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101d45:	00 
f0101d46:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101d4d:	e8 ee e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d52:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d59:	00 
f0101d5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d61:	00 
f0101d62:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d66:	89 3c 24             	mov    %edi,(%esp)
f0101d69:	e8 46 f5 ff ff       	call   f01012b4 <page_insert>
f0101d6e:	85 c0                	test   %eax,%eax
f0101d70:	74 24                	je     f0101d96 <mem_init+0x9da>
f0101d72:	c7 44 24 0c 0c 75 10 	movl   $0xf010750c,0xc(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101d81:	f0 
f0101d82:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0101d89:	00 
f0101d8a:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101d91:	e8 aa e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d96:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d9b:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101da0:	e8 13 ed ff ff       	call   f0100ab8 <check_va2pa>
f0101da5:	89 f2                	mov    %esi,%edx
f0101da7:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101dad:	c1 fa 03             	sar    $0x3,%edx
f0101db0:	c1 e2 0c             	shl    $0xc,%edx
f0101db3:	39 d0                	cmp    %edx,%eax
f0101db5:	74 24                	je     f0101ddb <mem_init+0xa1f>
f0101db7:	c7 44 24 0c 48 75 10 	movl   $0xf0107548,0xc(%esp)
f0101dbe:	f0 
f0101dbf:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101dc6:	f0 
f0101dc7:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101dce:	00 
f0101dcf:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101dd6:	e8 65 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ddb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101de0:	74 24                	je     f0101e06 <mem_init+0xa4a>
f0101de2:	c7 44 24 0c dd 7d 10 	movl   $0xf0107ddd,0xc(%esp)
f0101de9:	f0 
f0101dea:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101df9:	00 
f0101dfa:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101e01:	e8 3a e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e0d:	e8 b0 f1 ff ff       	call   f0100fc2 <page_alloc>
f0101e12:	85 c0                	test   %eax,%eax
f0101e14:	74 24                	je     f0101e3a <mem_init+0xa7e>
f0101e16:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101e35:	e8 06 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e3a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e41:	00 
f0101e42:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e49:	00 
f0101e4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e4e:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101e53:	89 04 24             	mov    %eax,(%esp)
f0101e56:	e8 59 f4 ff ff       	call   f01012b4 <page_insert>
f0101e5b:	85 c0                	test   %eax,%eax
f0101e5d:	74 24                	je     f0101e83 <mem_init+0xac7>
f0101e5f:	c7 44 24 0c 0c 75 10 	movl   $0xf010750c,0xc(%esp)
f0101e66:	f0 
f0101e67:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101e6e:	f0 
f0101e6f:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101e76:	00 
f0101e77:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101e7e:	e8 bd e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e83:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e88:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101e8d:	e8 26 ec ff ff       	call   f0100ab8 <check_va2pa>
f0101e92:	89 f2                	mov    %esi,%edx
f0101e94:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101e9a:	c1 fa 03             	sar    $0x3,%edx
f0101e9d:	c1 e2 0c             	shl    $0xc,%edx
f0101ea0:	39 d0                	cmp    %edx,%eax
f0101ea2:	74 24                	je     f0101ec8 <mem_init+0xb0c>
f0101ea4:	c7 44 24 0c 48 75 10 	movl   $0xf0107548,0xc(%esp)
f0101eab:	f0 
f0101eac:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101eb3:	f0 
f0101eb4:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0101ebb:	00 
f0101ebc:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101ec3:	e8 78 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ec8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ecd:	74 24                	je     f0101ef3 <mem_init+0xb37>
f0101ecf:	c7 44 24 0c dd 7d 10 	movl   $0xf0107ddd,0xc(%esp)
f0101ed6:	f0 
f0101ed7:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0101ee6:	00 
f0101ee7:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101eee:	e8 4d e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101efa:	e8 c3 f0 ff ff       	call   f0100fc2 <page_alloc>
f0101eff:	85 c0                	test   %eax,%eax
f0101f01:	74 24                	je     f0101f27 <mem_init+0xb6b>
f0101f03:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101f0a:	f0 
f0101f0b:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101f12:	f0 
f0101f13:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0101f1a:	00 
f0101f1b:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101f22:	e8 19 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f27:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f0101f2d:	8b 02                	mov    (%edx),%eax
f0101f2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f34:	89 c1                	mov    %eax,%ecx
f0101f36:	c1 e9 0c             	shr    $0xc,%ecx
f0101f39:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0101f3f:	72 20                	jb     f0101f61 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f45:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101f54:	00 
f0101f55:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101f5c:	e8 df e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f61:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f70:	00 
f0101f71:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f78:	00 
f0101f79:	89 14 24             	mov    %edx,(%esp)
f0101f7c:	e8 2f f1 ff ff       	call   f01010b0 <pgdir_walk>
f0101f81:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101f84:	8d 51 04             	lea    0x4(%ecx),%edx
f0101f87:	39 d0                	cmp    %edx,%eax
f0101f89:	74 24                	je     f0101faf <mem_init+0xbf3>
f0101f8b:	c7 44 24 0c 78 75 10 	movl   $0xf0107578,0xc(%esp)
f0101f92:	f0 
f0101f93:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0101fa2:	00 
f0101fa3:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101faa:	e8 91 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101faf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101fb6:	00 
f0101fb7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fbe:	00 
f0101fbf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fc3:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101fc8:	89 04 24             	mov    %eax,(%esp)
f0101fcb:	e8 e4 f2 ff ff       	call   f01012b4 <page_insert>
f0101fd0:	85 c0                	test   %eax,%eax
f0101fd2:	74 24                	je     f0101ff8 <mem_init+0xc3c>
f0101fd4:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f0101fdb:	f0 
f0101fdc:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0101fe3:	f0 
f0101fe4:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0101feb:	00 
f0101fec:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0101ff3:	e8 48 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ff8:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0101ffe:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102003:	89 f8                	mov    %edi,%eax
f0102005:	e8 ae ea ff ff       	call   f0100ab8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010200a:	89 f2                	mov    %esi,%edx
f010200c:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0102012:	c1 fa 03             	sar    $0x3,%edx
f0102015:	c1 e2 0c             	shl    $0xc,%edx
f0102018:	39 d0                	cmp    %edx,%eax
f010201a:	74 24                	je     f0102040 <mem_init+0xc84>
f010201c:	c7 44 24 0c 48 75 10 	movl   $0xf0107548,0xc(%esp)
f0102023:	f0 
f0102024:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010202b:	f0 
f010202c:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102033:	00 
f0102034:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010203b:	e8 00 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102040:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102045:	74 24                	je     f010206b <mem_init+0xcaf>
f0102047:	c7 44 24 0c dd 7d 10 	movl   $0xf0107ddd,0xc(%esp)
f010204e:	f0 
f010204f:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102056:	f0 
f0102057:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010205e:	00 
f010205f:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102066:	e8 d5 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010206b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102072:	00 
f0102073:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010207a:	00 
f010207b:	89 3c 24             	mov    %edi,(%esp)
f010207e:	e8 2d f0 ff ff       	call   f01010b0 <pgdir_walk>
f0102083:	f6 00 04             	testb  $0x4,(%eax)
f0102086:	75 24                	jne    f01020ac <mem_init+0xcf0>
f0102088:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f010208f:	f0 
f0102090:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102097:	f0 
f0102098:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010209f:	00 
f01020a0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01020a7:	e8 94 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020ac:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01020b1:	f6 00 04             	testb  $0x4,(%eax)
f01020b4:	75 24                	jne    f01020da <mem_init+0xd1e>
f01020b6:	c7 44 24 0c ee 7d 10 	movl   $0xf0107dee,0xc(%esp)
f01020bd:	f0 
f01020be:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01020c5:	f0 
f01020c6:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f01020cd:	00 
f01020ce:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01020d5:	e8 66 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020da:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020e1:	00 
f01020e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020e9:	00 
f01020ea:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020ee:	89 04 24             	mov    %eax,(%esp)
f01020f1:	e8 be f1 ff ff       	call   f01012b4 <page_insert>
f01020f6:	85 c0                	test   %eax,%eax
f01020f8:	74 24                	je     f010211e <mem_init+0xd62>
f01020fa:	c7 44 24 0c 0c 75 10 	movl   $0xf010750c,0xc(%esp)
f0102101:	f0 
f0102102:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102109:	f0 
f010210a:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102111:	00 
f0102112:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102119:	e8 22 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010211e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102125:	00 
f0102126:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010212d:	00 
f010212e:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102133:	89 04 24             	mov    %eax,(%esp)
f0102136:	e8 75 ef ff ff       	call   f01010b0 <pgdir_walk>
f010213b:	f6 00 02             	testb  $0x2,(%eax)
f010213e:	75 24                	jne    f0102164 <mem_init+0xda8>
f0102140:	c7 44 24 0c 2c 76 10 	movl   $0xf010762c,0xc(%esp)
f0102147:	f0 
f0102148:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010214f:	f0 
f0102150:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102157:	00 
f0102158:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010215f:	e8 dc de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010216b:	00 
f010216c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102173:	00 
f0102174:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102179:	89 04 24             	mov    %eax,(%esp)
f010217c:	e8 2f ef ff ff       	call   f01010b0 <pgdir_walk>
f0102181:	f6 00 04             	testb  $0x4,(%eax)
f0102184:	74 24                	je     f01021aa <mem_init+0xdee>
f0102186:	c7 44 24 0c 60 76 10 	movl   $0xf0107660,0xc(%esp)
f010218d:	f0 
f010218e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102195:	f0 
f0102196:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010219d:	00 
f010219e:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01021a5:	e8 96 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021b1:	00 
f01021b2:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01021b9:	00 
f01021ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01021c1:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01021c6:	89 04 24             	mov    %eax,(%esp)
f01021c9:	e8 e6 f0 ff ff       	call   f01012b4 <page_insert>
f01021ce:	85 c0                	test   %eax,%eax
f01021d0:	78 24                	js     f01021f6 <mem_init+0xe3a>
f01021d2:	c7 44 24 0c 98 76 10 	movl   $0xf0107698,0xc(%esp)
f01021d9:	f0 
f01021da:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01021e1:	f0 
f01021e2:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01021e9:	00 
f01021ea:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01021f1:	e8 4a de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021f6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021fd:	00 
f01021fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102205:	00 
f0102206:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010220a:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010220f:	89 04 24             	mov    %eax,(%esp)
f0102212:	e8 9d f0 ff ff       	call   f01012b4 <page_insert>
f0102217:	85 c0                	test   %eax,%eax
f0102219:	74 24                	je     f010223f <mem_init+0xe83>
f010221b:	c7 44 24 0c d0 76 10 	movl   $0xf01076d0,0xc(%esp)
f0102222:	f0 
f0102223:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010222a:	f0 
f010222b:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102232:	00 
f0102233:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010223a:	e8 01 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010223f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102246:	00 
f0102247:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010224e:	00 
f010224f:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102254:	89 04 24             	mov    %eax,(%esp)
f0102257:	e8 54 ee ff ff       	call   f01010b0 <pgdir_walk>
f010225c:	f6 00 04             	testb  $0x4,(%eax)
f010225f:	74 24                	je     f0102285 <mem_init+0xec9>
f0102261:	c7 44 24 0c 60 76 10 	movl   $0xf0107660,0xc(%esp)
f0102268:	f0 
f0102269:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102270:	f0 
f0102271:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102278:	00 
f0102279:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102280:	e8 bb dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102285:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f010228b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102290:	89 f8                	mov    %edi,%eax
f0102292:	e8 21 e8 ff ff       	call   f0100ab8 <check_va2pa>
f0102297:	89 c1                	mov    %eax,%ecx
f0102299:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010229c:	89 d8                	mov    %ebx,%eax
f010229e:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f01022a4:	c1 f8 03             	sar    $0x3,%eax
f01022a7:	c1 e0 0c             	shl    $0xc,%eax
f01022aa:	39 c1                	cmp    %eax,%ecx
f01022ac:	74 24                	je     f01022d2 <mem_init+0xf16>
f01022ae:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f01022b5:	f0 
f01022b6:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01022bd:	f0 
f01022be:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f01022c5:	00 
f01022c6:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01022cd:	e8 6e dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022d2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022d7:	89 f8                	mov    %edi,%eax
f01022d9:	e8 da e7 ff ff       	call   f0100ab8 <check_va2pa>
f01022de:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01022e1:	74 24                	je     f0102307 <mem_init+0xf4b>
f01022e3:	c7 44 24 0c 38 77 10 	movl   $0xf0107738,0xc(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01022fa:	00 
f01022fb:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102302:	e8 39 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102307:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010230c:	74 24                	je     f0102332 <mem_init+0xf76>
f010230e:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f0102315:	f0 
f0102316:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010231d:	f0 
f010231e:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0102325:	00 
f0102326:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010232d:	e8 0e dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102332:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102337:	74 24                	je     f010235d <mem_init+0xfa1>
f0102339:	c7 44 24 0c 15 7e 10 	movl   $0xf0107e15,0xc(%esp)
f0102340:	f0 
f0102341:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102348:	f0 
f0102349:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102350:	00 
f0102351:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102358:	e8 e3 dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010235d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102364:	e8 59 ec ff ff       	call   f0100fc2 <page_alloc>
f0102369:	85 c0                	test   %eax,%eax
f010236b:	74 04                	je     f0102371 <mem_init+0xfb5>
f010236d:	39 c6                	cmp    %eax,%esi
f010236f:	74 24                	je     f0102395 <mem_init+0xfd9>
f0102371:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f0102378:	f0 
f0102379:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102380:	f0 
f0102381:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102388:	00 
f0102389:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102390:	e8 ab dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102395:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010239c:	00 
f010239d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01023a2:	89 04 24             	mov    %eax,(%esp)
f01023a5:	e8 b1 ee ff ff       	call   f010125b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023aa:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f01023b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01023b5:	89 f8                	mov    %edi,%eax
f01023b7:	e8 fc e6 ff ff       	call   f0100ab8 <check_va2pa>
f01023bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023bf:	74 24                	je     f01023e5 <mem_init+0x1029>
f01023c1:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f01023c8:	f0 
f01023c9:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01023d0:	f0 
f01023d1:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f01023d8:	00 
f01023d9:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01023e0:	e8 5b dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023e5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ea:	89 f8                	mov    %edi,%eax
f01023ec:	e8 c7 e6 ff ff       	call   f0100ab8 <check_va2pa>
f01023f1:	89 da                	mov    %ebx,%edx
f01023f3:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01023f9:	c1 fa 03             	sar    $0x3,%edx
f01023fc:	c1 e2 0c             	shl    $0xc,%edx
f01023ff:	39 d0                	cmp    %edx,%eax
f0102401:	74 24                	je     f0102427 <mem_init+0x106b>
f0102403:	c7 44 24 0c 38 77 10 	movl   $0xf0107738,0xc(%esp)
f010240a:	f0 
f010240b:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102412:	f0 
f0102413:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f010241a:	00 
f010241b:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102422:	e8 19 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102427:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010242c:	74 24                	je     f0102452 <mem_init+0x1096>
f010242e:	c7 44 24 0c bb 7d 10 	movl   $0xf0107dbb,0xc(%esp)
f0102435:	f0 
f0102436:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010243d:	f0 
f010243e:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f0102445:	00 
f0102446:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010244d:	e8 ee db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102452:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102457:	74 24                	je     f010247d <mem_init+0x10c1>
f0102459:	c7 44 24 0c 15 7e 10 	movl   $0xf0107e15,0xc(%esp)
f0102460:	f0 
f0102461:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102468:	f0 
f0102469:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102470:	00 
f0102471:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102478:	e8 c3 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010247d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102484:	00 
f0102485:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010248c:	00 
f010248d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102491:	89 3c 24             	mov    %edi,(%esp)
f0102494:	e8 1b ee ff ff       	call   f01012b4 <page_insert>
f0102499:	85 c0                	test   %eax,%eax
f010249b:	74 24                	je     f01024c1 <mem_init+0x1105>
f010249d:	c7 44 24 0c b0 77 10 	movl   $0xf01077b0,0xc(%esp)
f01024a4:	f0 
f01024a5:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01024ac:	f0 
f01024ad:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01024b4:	00 
f01024b5:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01024bc:	e8 7f db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024c1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024c6:	75 24                	jne    f01024ec <mem_init+0x1130>
f01024c8:	c7 44 24 0c 26 7e 10 	movl   $0xf0107e26,0xc(%esp)
f01024cf:	f0 
f01024d0:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01024d7:	f0 
f01024d8:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f01024df:	00 
f01024e0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01024e7:	e8 54 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01024ec:	83 3b 00             	cmpl   $0x0,(%ebx)
f01024ef:	74 24                	je     f0102515 <mem_init+0x1159>
f01024f1:	c7 44 24 0c 32 7e 10 	movl   $0xf0107e32,0xc(%esp)
f01024f8:	f0 
f01024f9:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102500:	f0 
f0102501:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102508:	00 
f0102509:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102510:	e8 2b db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102515:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010251c:	00 
f010251d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102522:	89 04 24             	mov    %eax,(%esp)
f0102525:	e8 31 ed ff ff       	call   f010125b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010252a:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102530:	ba 00 00 00 00       	mov    $0x0,%edx
f0102535:	89 f8                	mov    %edi,%eax
f0102537:	e8 7c e5 ff ff       	call   f0100ab8 <check_va2pa>
f010253c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010253f:	74 24                	je     f0102565 <mem_init+0x11a9>
f0102541:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0102548:	f0 
f0102549:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102550:	f0 
f0102551:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102558:	00 
f0102559:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102560:	e8 db da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102565:	ba 00 10 00 00       	mov    $0x1000,%edx
f010256a:	89 f8                	mov    %edi,%eax
f010256c:	e8 47 e5 ff ff       	call   f0100ab8 <check_va2pa>
f0102571:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102574:	74 24                	je     f010259a <mem_init+0x11de>
f0102576:	c7 44 24 0c e8 77 10 	movl   $0xf01077e8,0xc(%esp)
f010257d:	f0 
f010257e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102585:	f0 
f0102586:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f010258d:	00 
f010258e:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102595:	e8 a6 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010259a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010259f:	74 24                	je     f01025c5 <mem_init+0x1209>
f01025a1:	c7 44 24 0c 47 7e 10 	movl   $0xf0107e47,0xc(%esp)
f01025a8:	f0 
f01025a9:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01025b0:	f0 
f01025b1:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f01025b8:	00 
f01025b9:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01025c0:	e8 7b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025c5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025ca:	74 24                	je     f01025f0 <mem_init+0x1234>
f01025cc:	c7 44 24 0c 15 7e 10 	movl   $0xf0107e15,0xc(%esp)
f01025d3:	f0 
f01025d4:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01025db:	f0 
f01025dc:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f01025e3:	00 
f01025e4:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01025eb:	e8 50 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01025f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025f7:	e8 c6 e9 ff ff       	call   f0100fc2 <page_alloc>
f01025fc:	85 c0                	test   %eax,%eax
f01025fe:	74 04                	je     f0102604 <mem_init+0x1248>
f0102600:	39 c3                	cmp    %eax,%ebx
f0102602:	74 24                	je     f0102628 <mem_init+0x126c>
f0102604:	c7 44 24 0c 10 78 10 	movl   $0xf0107810,0xc(%esp)
f010260b:	f0 
f010260c:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102613:	f0 
f0102614:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f010261b:	00 
f010261c:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102623:	e8 18 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102628:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010262f:	e8 8e e9 ff ff       	call   f0100fc2 <page_alloc>
f0102634:	85 c0                	test   %eax,%eax
f0102636:	74 24                	je     f010265c <mem_init+0x12a0>
f0102638:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f010263f:	f0 
f0102640:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102647:	f0 
f0102648:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f010264f:	00 
f0102650:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102657:	e8 e4 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010265c:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102661:	8b 08                	mov    (%eax),%ecx
f0102663:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102669:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010266c:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0102672:	c1 fa 03             	sar    $0x3,%edx
f0102675:	c1 e2 0c             	shl    $0xc,%edx
f0102678:	39 d1                	cmp    %edx,%ecx
f010267a:	74 24                	je     f01026a0 <mem_init+0x12e4>
f010267c:	c7 44 24 0c b4 74 10 	movl   $0xf01074b4,0xc(%esp)
f0102683:	f0 
f0102684:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010268b:	f0 
f010268c:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102693:	00 
f0102694:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010269b:	e8 a0 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01026a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01026a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026a9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026ae:	74 24                	je     f01026d4 <mem_init+0x1318>
f01026b0:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f01026b7:	f0 
f01026b8:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01026bf:	f0 
f01026c0:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01026c7:	00 
f01026c8:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01026cf:	e8 6c d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01026d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026d7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01026dd:	89 04 24             	mov    %eax,(%esp)
f01026e0:	e8 68 e9 ff ff       	call   f010104d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01026e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026ec:	00 
f01026ed:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01026f4:	00 
f01026f5:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01026fa:	89 04 24             	mov    %eax,(%esp)
f01026fd:	e8 ae e9 ff ff       	call   f01010b0 <pgdir_walk>
f0102702:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102708:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f010270e:	8b 7a 04             	mov    0x4(%edx),%edi
f0102711:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102717:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f010271d:	89 f8                	mov    %edi,%eax
f010271f:	c1 e8 0c             	shr    $0xc,%eax
f0102722:	39 c8                	cmp    %ecx,%eax
f0102724:	72 20                	jb     f0102746 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102726:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010272a:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0102731:	f0 
f0102732:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102739:	00 
f010273a:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102741:	e8 fa d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102746:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010274c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010274f:	74 24                	je     f0102775 <mem_init+0x13b9>
f0102751:	c7 44 24 0c 58 7e 10 	movl   $0xf0107e58,0xc(%esp)
f0102758:	f0 
f0102759:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102760:	f0 
f0102761:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102768:	00 
f0102769:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102770:	e8 cb d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102775:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f010277c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010277f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102785:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010278b:	c1 f8 03             	sar    $0x3,%eax
f010278e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102791:	89 c2                	mov    %eax,%edx
f0102793:	c1 ea 0c             	shr    $0xc,%edx
f0102796:	39 d1                	cmp    %edx,%ecx
f0102798:	77 20                	ja     f01027ba <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010279a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010279e:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027ad:	00 
f01027ae:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f01027b5:	e8 86 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027c1:	00 
f01027c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01027c9:	00 
	return (void *)(pa + KERNBASE);
f01027ca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027cf:	89 04 24             	mov    %eax,(%esp)
f01027d2:	e8 70 38 00 00       	call   f0106047 <memset>
	page_free(pp0);
f01027d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027da:	89 3c 24             	mov    %edi,(%esp)
f01027dd:	e8 6b e8 ff ff       	call   f010104d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027e2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027e9:	00 
f01027ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027f1:	00 
f01027f2:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01027f7:	89 04 24             	mov    %eax,(%esp)
f01027fa:	e8 b1 e8 ff ff       	call   f01010b0 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027ff:	89 fa                	mov    %edi,%edx
f0102801:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0102807:	c1 fa 03             	sar    $0x3,%edx
f010280a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010280d:	89 d0                	mov    %edx,%eax
f010280f:	c1 e8 0c             	shr    $0xc,%eax
f0102812:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0102818:	72 20                	jb     f010283a <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010281a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010281e:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0102825:	f0 
f0102826:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010282d:	00 
f010282e:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0102835:	e8 06 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010283a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102840:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102843:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102849:	f6 00 01             	testb  $0x1,(%eax)
f010284c:	74 24                	je     f0102872 <mem_init+0x14b6>
f010284e:	c7 44 24 0c 70 7e 10 	movl   $0xf0107e70,0xc(%esp)
f0102855:	f0 
f0102856:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010285d:	f0 
f010285e:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102865:	00 
f0102866:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010286d:	e8 ce d7 ff ff       	call   f0100040 <_panic>
f0102872:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102875:	39 d0                	cmp    %edx,%eax
f0102877:	75 d0                	jne    f0102849 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102879:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010287e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102884:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102887:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010288d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102890:	89 0d 40 02 23 f0    	mov    %ecx,0xf0230240

	// free the pages we took
	page_free(pp0);
f0102896:	89 04 24             	mov    %eax,(%esp)
f0102899:	e8 af e7 ff ff       	call   f010104d <page_free>
	page_free(pp1);
f010289e:	89 1c 24             	mov    %ebx,(%esp)
f01028a1:	e8 a7 e7 ff ff       	call   f010104d <page_free>
	page_free(pp2);
f01028a6:	89 34 24             	mov    %esi,(%esp)
f01028a9:	e8 9f e7 ff ff       	call   f010104d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028ae:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01028b5:	00 
f01028b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028bd:	e8 85 ea ff ff       	call   f0101347 <mmio_map_region>
f01028c2:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028c4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028cb:	00 
f01028cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028d3:	e8 6f ea ff ff       	call   f0101347 <mmio_map_region>
f01028d8:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01028da:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01028e0:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01028e5:	77 08                	ja     f01028ef <mem_init+0x1533>
f01028e7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028ed:	77 24                	ja     f0102913 <mem_init+0x1557>
f01028ef:	c7 44 24 0c 34 78 10 	movl   $0xf0107834,0xc(%esp)
f01028f6:	f0 
f01028f7:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01028fe:	f0 
f01028ff:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0102906:	00 
f0102907:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010290e:	e8 2d d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102913:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102919:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010291f:	77 08                	ja     f0102929 <mem_init+0x156d>
f0102921:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102927:	77 24                	ja     f010294d <mem_init+0x1591>
f0102929:	c7 44 24 0c 5c 78 10 	movl   $0xf010785c,0xc(%esp)
f0102930:	f0 
f0102931:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102938:	f0 
f0102939:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0102940:	00 
f0102941:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102948:	e8 f3 d6 ff ff       	call   f0100040 <_panic>
f010294d:	89 da                	mov    %ebx,%edx
f010294f:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102951:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102957:	74 24                	je     f010297d <mem_init+0x15c1>
f0102959:	c7 44 24 0c 84 78 10 	movl   $0xf0107884,0xc(%esp)
f0102960:	f0 
f0102961:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102968:	f0 
f0102969:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102970:	00 
f0102971:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102978:	e8 c3 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010297d:	39 c6                	cmp    %eax,%esi
f010297f:	73 24                	jae    f01029a5 <mem_init+0x15e9>
f0102981:	c7 44 24 0c 87 7e 10 	movl   $0xf0107e87,0xc(%esp)
f0102988:	f0 
f0102989:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102990:	f0 
f0102991:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0102998:	00 
f0102999:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01029a0:	e8 9b d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029a5:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f01029ab:	89 da                	mov    %ebx,%edx
f01029ad:	89 f8                	mov    %edi,%eax
f01029af:	e8 04 e1 ff ff       	call   f0100ab8 <check_va2pa>
f01029b4:	85 c0                	test   %eax,%eax
f01029b6:	74 24                	je     f01029dc <mem_init+0x1620>
f01029b8:	c7 44 24 0c ac 78 10 	movl   $0xf01078ac,0xc(%esp)
f01029bf:	f0 
f01029c0:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f01029cf:	00 
f01029d0:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01029d7:	e8 64 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029dc:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01029e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029e5:	89 c2                	mov    %eax,%edx
f01029e7:	89 f8                	mov    %edi,%eax
f01029e9:	e8 ca e0 ff ff       	call   f0100ab8 <check_va2pa>
f01029ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029f3:	74 24                	je     f0102a19 <mem_init+0x165d>
f01029f5:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102a04:	f0 
f0102a05:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0102a0c:	00 
f0102a0d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102a14:	e8 27 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a19:	89 f2                	mov    %esi,%edx
f0102a1b:	89 f8                	mov    %edi,%eax
f0102a1d:	e8 96 e0 ff ff       	call   f0100ab8 <check_va2pa>
f0102a22:	85 c0                	test   %eax,%eax
f0102a24:	74 24                	je     f0102a4a <mem_init+0x168e>
f0102a26:	c7 44 24 0c 00 79 10 	movl   $0xf0107900,0xc(%esp)
f0102a2d:	f0 
f0102a2e:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102a35:	f0 
f0102a36:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102a3d:	00 
f0102a3e:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102a45:	e8 f6 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a4a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a50:	89 f8                	mov    %edi,%eax
f0102a52:	e8 61 e0 ff ff       	call   f0100ab8 <check_va2pa>
f0102a57:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a5a:	74 24                	je     f0102a80 <mem_init+0x16c4>
f0102a5c:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f0102a63:	f0 
f0102a64:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102a6b:	f0 
f0102a6c:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102a73:	00 
f0102a74:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102a7b:	e8 c0 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a87:	00 
f0102a88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a8c:	89 3c 24             	mov    %edi,(%esp)
f0102a8f:	e8 1c e6 ff ff       	call   f01010b0 <pgdir_walk>
f0102a94:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a97:	75 24                	jne    f0102abd <mem_init+0x1701>
f0102a99:	c7 44 24 0c 50 79 10 	movl   $0xf0107950,0xc(%esp)
f0102aa0:	f0 
f0102aa1:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102aa8:	f0 
f0102aa9:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0102ab0:	00 
f0102ab1:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102ab8:	e8 83 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102abd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ac4:	00 
f0102ac5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ac9:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102ace:	89 04 24             	mov    %eax,(%esp)
f0102ad1:	e8 da e5 ff ff       	call   f01010b0 <pgdir_walk>
f0102ad6:	f6 00 04             	testb  $0x4,(%eax)
f0102ad9:	74 24                	je     f0102aff <mem_init+0x1743>
f0102adb:	c7 44 24 0c 94 79 10 	movl   $0xf0107994,0xc(%esp)
f0102ae2:	f0 
f0102ae3:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102aea:	f0 
f0102aeb:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102af2:	00 
f0102af3:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102afa:	e8 41 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b06:	00 
f0102b07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b0b:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102b10:	89 04 24             	mov    %eax,(%esp)
f0102b13:	e8 98 e5 ff ff       	call   f01010b0 <pgdir_walk>
f0102b18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b25:	00 
f0102b26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b2d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102b32:	89 04 24             	mov    %eax,(%esp)
f0102b35:	e8 76 e5 ff ff       	call   f01010b0 <pgdir_walk>
f0102b3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b47:	00 
f0102b48:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b4c:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102b51:	89 04 24             	mov    %eax,(%esp)
f0102b54:	e8 57 e5 ff ff       	call   f01010b0 <pgdir_walk>
f0102b59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b5f:	c7 04 24 99 7e 10 f0 	movl   $0xf0107e99,(%esp)
f0102b66:	e8 fa 13 00 00       	call   f0103f65 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b6b:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0102b70:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102b77:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f0102b7d:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b82:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b87:	77 20                	ja     f0102ba9 <mem_init+0x17ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b8d:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102b94:	f0 
f0102b95:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102b9c:	00 
f0102b9d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102ba4:	e8 97 d4 ff ff       	call   f0100040 <_panic>
f0102ba9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bb0:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bb1:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bb6:	89 04 24             	mov    %eax,(%esp)
f0102bb9:	89 d9                	mov    %ebx,%ecx
f0102bbb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102bc0:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102bc5:	e8 86 e5 ff ff       	call   f0101150 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f0102bca:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bd0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102bd6:	77 20                	ja     f0102bf8 <mem_init+0x183c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bd8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bdc:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102be3:	f0 
f0102be4:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102beb:	00 
f0102bec:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102bf3:	e8 48 d4 ff ff       	call   f0100040 <_panic>
f0102bf8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102bff:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c00:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102c06:	89 04 24             	mov    %eax,(%esp)
f0102c09:	89 d9                	mov    %ebx,%ecx
f0102c0b:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102c10:	e8 3b e5 ff ff       	call   f0101150 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	 perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102c15:	a1 48 02 23 f0       	mov    0xf0230248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c1a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c1f:	77 20                	ja     f0102c41 <mem_init+0x1885>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c21:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c25:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102c2c:	f0 
f0102c2d:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102c34:	00 
f0102c35:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102c3c:	e8 ff d3 ff ff       	call   f0100040 <_panic>
f0102c41:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c48:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c49:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c4e:	89 04 24             	mov    %eax,(%esp)
f0102c51:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c56:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c5b:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102c60:	e8 eb e4 ff ff       	call   f0101150 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102c65:	8b 15 48 02 23 f0    	mov    0xf0230248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c6b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c71:	77 20                	ja     f0102c93 <mem_init+0x18d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c77:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102c7e:	f0 
f0102c7f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0102c86:	00 
f0102c87:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102c8e:	e8 ad d3 ff ff       	call   f0100040 <_panic>
f0102c93:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102c9a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c9b:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102ca1:	89 04 24             	mov    %eax,(%esp)
f0102ca4:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ca9:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102cae:	e8 9d e4 ff ff       	call   f0101150 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb3:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102cb8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cbd:	77 20                	ja     f0102cdf <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cc3:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102cca:	f0 
f0102ccb:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102cd2:	00 
f0102cd3:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102cda:	e8 61 d3 ff ff       	call   f0100040 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102cdf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ce6:	00 
f0102ce7:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102cee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cf3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102cf8:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102cfd:	e8 4e e4 ff ff       	call   f0101150 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102d02:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d09:	00 
f0102d0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d11:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102d16:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d1b:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102d20:	e8 2b e4 ff ff       	call   f0101150 <boot_map_region>
f0102d25:	bf 00 20 27 f0       	mov    $0xf0272000,%edi
f0102d2a:	bb 00 20 23 f0       	mov    $0xf0232000,%ebx
f0102d2f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d34:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d3a:	77 20                	ja     f0102d5c <mem_init+0x19a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d3c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d40:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102d47:	f0 
f0102d48:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0102d4f:	00 
f0102d50:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102d57:	e8 e4 d2 ff ff       	call   f0100040 <_panic>
    for (i = 0; i < NCPU; i++)
    {
        kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        //boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)

        boot_map_region(kern_pgdir,
f0102d5c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d63:	00 
f0102d64:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d6a:	89 04 24             	mov    %eax,(%esp)
f0102d6d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d72:	89 f2                	mov    %esi,%edx
f0102d74:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102d79:	e8 d2 e3 ff ff       	call   f0101150 <boot_map_region>
f0102d7e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d84:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:
	 int i = 0;
    uintptr_t kstacktop_i;
    
    for (i = 0; i < NCPU; i++)
f0102d8a:	39 fb                	cmp    %edi,%ebx
f0102d8c:	75 a6                	jne    f0102d34 <mem_init+0x1978>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d8e:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d94:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0102d99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d9c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102da3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102da8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dab:	8b 35 90 0e 23 f0    	mov    0xf0230e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db1:	89 75 cc             	mov    %esi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102db4:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102dba:	89 45 c8             	mov    %eax,-0x38(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102dc2:	eb 6a                	jmp    f0102e2e <mem_init+0x1a72>
f0102dc4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dca:	89 f8                	mov    %edi,%eax
f0102dcc:	e8 e7 dc ff ff       	call   f0100ab8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd1:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102dd8:	77 20                	ja     f0102dfa <mem_init+0x1a3e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dda:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dde:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102de5:	f0 
f0102de6:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102ded:	00 
f0102dee:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102df5:	e8 46 d2 ff ff       	call   f0100040 <_panic>
f0102dfa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102dfd:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e00:	39 d0                	cmp    %edx,%eax
f0102e02:	74 24                	je     f0102e28 <mem_init+0x1a6c>
f0102e04:	c7 44 24 0c c8 79 10 	movl   $0xf01079c8,0xc(%esp)
f0102e0b:	f0 
f0102e0c:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102e13:	f0 
f0102e14:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102e1b:	00 
f0102e1c:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102e23:	e8 18 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e28:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e2e:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e31:	77 91                	ja     f0102dc4 <mem_init+0x1a08>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e33:	8b 1d 48 02 23 f0    	mov    0xf0230248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e39:	89 de                	mov    %ebx,%esi
f0102e3b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e40:	89 f8                	mov    %edi,%eax
f0102e42:	e8 71 dc ff ff       	call   f0100ab8 <check_va2pa>
f0102e47:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e4d:	77 20                	ja     f0102e6f <mem_init+0x1ab3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e4f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e53:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102e5a:	f0 
f0102e5b:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102e62:	00 
f0102e63:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102e6a:	e8 d1 d1 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e6f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102e74:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102e7a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102e7d:	39 d0                	cmp    %edx,%eax
f0102e7f:	74 24                	je     f0102ea5 <mem_init+0x1ae9>
f0102e81:	c7 44 24 0c fc 79 10 	movl   $0xf01079fc,0xc(%esp)
f0102e88:	f0 
f0102e89:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102e90:	f0 
f0102e91:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102e98:	00 
f0102e99:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102ea0:	e8 9b d1 ff ff       	call   f0100040 <_panic>
f0102ea5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102eab:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102eb1:	0f 85 a8 05 00 00    	jne    f010345f <mem_init+0x20a3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102eb7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102eba:	c1 e6 0c             	shl    $0xc,%esi
f0102ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ec2:	eb 3b                	jmp    f0102eff <mem_init+0x1b43>
f0102ec4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eca:	89 f8                	mov    %edi,%eax
f0102ecc:	e8 e7 db ff ff       	call   f0100ab8 <check_va2pa>
f0102ed1:	39 c3                	cmp    %eax,%ebx
f0102ed3:	74 24                	je     f0102ef9 <mem_init+0x1b3d>
f0102ed5:	c7 44 24 0c 30 7a 10 	movl   $0xf0107a30,0xc(%esp)
f0102edc:	f0 
f0102edd:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102ee4:	f0 
f0102ee5:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102eec:	00 
f0102eed:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102ef4:	e8 47 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ef9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102eff:	39 f3                	cmp    %esi,%ebx
f0102f01:	72 c1                	jb     f0102ec4 <mem_init+0x1b08>
f0102f03:	c7 45 d0 00 20 23 f0 	movl   $0xf0232000,-0x30(%ebp)
f0102f0a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f11:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f16:	b8 00 20 23 f0       	mov    $0xf0232000,%eax
f0102f1b:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f20:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f23:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f29:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f2c:	89 f2                	mov    %esi,%edx
f0102f2e:	89 f8                	mov    %edi,%eax
f0102f30:	e8 83 db ff ff       	call   f0100ab8 <check_va2pa>
f0102f35:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f38:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f3e:	77 20                	ja     f0102f60 <mem_init+0x1ba4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f40:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f44:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0102f4b:	f0 
f0102f4c:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102f53:	00 
f0102f54:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102f5b:	e8 e0 d0 ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f60:	89 f3                	mov    %esi,%ebx
f0102f62:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102f65:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102f68:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f6b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f6e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102f71:	39 c2                	cmp    %eax,%edx
f0102f73:	74 24                	je     f0102f99 <mem_init+0x1bdd>
f0102f75:	c7 44 24 0c 58 7a 10 	movl   $0xf0107a58,0xc(%esp)
f0102f7c:	f0 
f0102f7d:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102f84:	f0 
f0102f85:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102f8c:	00 
f0102f8d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102f94:	e8 a7 d0 ff ff       	call   f0100040 <_panic>
f0102f99:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f9f:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fa2:	0f 85 a9 04 00 00    	jne    f0103451 <mem_init+0x2095>
f0102fa8:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102fae:	89 da                	mov    %ebx,%edx
f0102fb0:	89 f8                	mov    %edi,%eax
f0102fb2:	e8 01 db ff ff       	call   f0100ab8 <check_va2pa>
f0102fb7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fba:	74 24                	je     f0102fe0 <mem_init+0x1c24>
f0102fbc:	c7 44 24 0c a0 7a 10 	movl   $0xf0107aa0,0xc(%esp)
f0102fc3:	f0 
f0102fc4:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0102fcb:	f0 
f0102fcc:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102fd3:	00 
f0102fd4:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0102fdb:	e8 60 d0 ff ff       	call   f0100040 <_panic>
f0102fe0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fe6:	39 de                	cmp    %ebx,%esi
f0102fe8:	75 c4                	jne    f0102fae <mem_init+0x1bf2>
f0102fea:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102ff0:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0102ff7:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102ffe:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103004:	0f 85 19 ff ff ff    	jne    f0102f23 <mem_init+0x1b67>
f010300a:	b8 00 00 00 00       	mov    $0x0,%eax
f010300f:	e9 c2 00 00 00       	jmp    f01030d6 <mem_init+0x1d1a>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103014:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010301a:	83 fa 04             	cmp    $0x4,%edx
f010301d:	77 2e                	ja     f010304d <mem_init+0x1c91>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010301f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103023:	0f 85 aa 00 00 00    	jne    f01030d3 <mem_init+0x1d17>
f0103029:	c7 44 24 0c b2 7e 10 	movl   $0xf0107eb2,0xc(%esp)
f0103030:	f0 
f0103031:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103038:	f0 
f0103039:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0103040:	00 
f0103041:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103048:	e8 f3 cf ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010304d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103052:	76 55                	jbe    f01030a9 <mem_init+0x1ced>
				assert(pgdir[i] & PTE_P);
f0103054:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103057:	f6 c2 01             	test   $0x1,%dl
f010305a:	75 24                	jne    f0103080 <mem_init+0x1cc4>
f010305c:	c7 44 24 0c b2 7e 10 	movl   $0xf0107eb2,0xc(%esp)
f0103063:	f0 
f0103064:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010306b:	f0 
f010306c:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0103073:	00 
f0103074:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010307b:	e8 c0 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103080:	f6 c2 02             	test   $0x2,%dl
f0103083:	75 4e                	jne    f01030d3 <mem_init+0x1d17>
f0103085:	c7 44 24 0c c3 7e 10 	movl   $0xf0107ec3,0xc(%esp)
f010308c:	f0 
f010308d:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01030a4:	e8 97 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01030a9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030ad:	74 24                	je     f01030d3 <mem_init+0x1d17>
f01030af:	c7 44 24 0c d4 7e 10 	movl   $0xf0107ed4,0xc(%esp)
f01030b6:	f0 
f01030b7:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01030be:	f0 
f01030bf:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01030c6:	00 
f01030c7:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01030ce:	e8 6d cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01030d3:	83 c0 01             	add    $0x1,%eax
f01030d6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030db:	0f 85 33 ff ff ff    	jne    f0103014 <mem_init+0x1c58>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01030e1:	c7 04 24 c4 7a 10 f0 	movl   $0xf0107ac4,(%esp)
f01030e8:	e8 78 0e 00 00       	call   f0103f65 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01030ed:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01030f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030f7:	77 20                	ja     f0103119 <mem_init+0x1d5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030fd:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0103104:	f0 
f0103105:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f010310c:	00 
f010310d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103114:	e8 27 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103119:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010311e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103121:	b8 00 00 00 00       	mov    $0x0,%eax
f0103126:	e8 fc d9 ff ff       	call   f0100b27 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010312b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010312e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103131:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103136:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103139:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103140:	e8 7d de ff ff       	call   f0100fc2 <page_alloc>
f0103145:	89 c3                	mov    %eax,%ebx
f0103147:	85 c0                	test   %eax,%eax
f0103149:	75 24                	jne    f010316f <mem_init+0x1db3>
f010314b:	c7 44 24 0c be 7c 10 	movl   $0xf0107cbe,0xc(%esp)
f0103152:	f0 
f0103153:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010315a:	f0 
f010315b:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f0103162:	00 
f0103163:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010316a:	e8 d1 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010316f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103176:	e8 47 de ff ff       	call   f0100fc2 <page_alloc>
f010317b:	89 c7                	mov    %eax,%edi
f010317d:	85 c0                	test   %eax,%eax
f010317f:	75 24                	jne    f01031a5 <mem_init+0x1de9>
f0103181:	c7 44 24 0c d4 7c 10 	movl   $0xf0107cd4,0xc(%esp)
f0103188:	f0 
f0103189:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103190:	f0 
f0103191:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103198:	00 
f0103199:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01031a0:	e8 9b ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031ac:	e8 11 de ff ff       	call   f0100fc2 <page_alloc>
f01031b1:	89 c6                	mov    %eax,%esi
f01031b3:	85 c0                	test   %eax,%eax
f01031b5:	75 24                	jne    f01031db <mem_init+0x1e1f>
f01031b7:	c7 44 24 0c ea 7c 10 	movl   $0xf0107cea,0xc(%esp)
f01031be:	f0 
f01031bf:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01031c6:	f0 
f01031c7:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01031ce:	00 
f01031cf:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01031d6:	e8 65 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031db:	89 1c 24             	mov    %ebx,(%esp)
f01031de:	e8 6a de ff ff       	call   f010104d <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f01031e3:	89 f8                	mov    %edi,%eax
f01031e5:	e8 89 d8 ff ff       	call   f0100a73 <page2kva>
f01031ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f1:	00 
f01031f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031f9:	00 
f01031fa:	89 04 24             	mov    %eax,(%esp)
f01031fd:	e8 45 2e 00 00       	call   f0106047 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103202:	89 f0                	mov    %esi,%eax
f0103204:	e8 6a d8 ff ff       	call   f0100a73 <page2kva>
f0103209:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103210:	00 
f0103211:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103218:	00 
f0103219:	89 04 24             	mov    %eax,(%esp)
f010321c:	e8 26 2e 00 00       	call   f0106047 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103221:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103228:	00 
f0103229:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103230:	00 
f0103231:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103235:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010323a:	89 04 24             	mov    %eax,(%esp)
f010323d:	e8 72 e0 ff ff       	call   f01012b4 <page_insert>
	assert(pp1->pp_ref == 1);
f0103242:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103247:	74 24                	je     f010326d <mem_init+0x1eb1>
f0103249:	c7 44 24 0c bb 7d 10 	movl   $0xf0107dbb,0xc(%esp)
f0103250:	f0 
f0103251:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103258:	f0 
f0103259:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f0103260:	00 
f0103261:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103268:	e8 d3 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010326d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103274:	01 01 01 
f0103277:	74 24                	je     f010329d <mem_init+0x1ee1>
f0103279:	c7 44 24 0c e4 7a 10 	movl   $0xf0107ae4,0xc(%esp)
f0103280:	f0 
f0103281:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103288:	f0 
f0103289:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0103290:	00 
f0103291:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103298:	e8 a3 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010329d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032a4:	00 
f01032a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032ac:	00 
f01032ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032b1:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01032b6:	89 04 24             	mov    %eax,(%esp)
f01032b9:	e8 f6 df ff ff       	call   f01012b4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032be:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032c5:	02 02 02 
f01032c8:	74 24                	je     f01032ee <mem_init+0x1f32>
f01032ca:	c7 44 24 0c 08 7b 10 	movl   $0xf0107b08,0xc(%esp)
f01032d1:	f0 
f01032d2:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01032d9:	f0 
f01032da:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f01032e1:	00 
f01032e2:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01032e9:	e8 52 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032ee:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01032f3:	74 24                	je     f0103319 <mem_init+0x1f5d>
f01032f5:	c7 44 24 0c dd 7d 10 	movl   $0xf0107ddd,0xc(%esp)
f01032fc:	f0 
f01032fd:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103304:	f0 
f0103305:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f010330c:	00 
f010330d:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103314:	e8 27 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103319:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010331e:	74 24                	je     f0103344 <mem_init+0x1f88>
f0103320:	c7 44 24 0c 47 7e 10 	movl   $0xf0107e47,0xc(%esp)
f0103327:	f0 
f0103328:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010332f:	f0 
f0103330:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0103337:	00 
f0103338:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010333f:	e8 fc cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103344:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010334b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010334e:	89 f0                	mov    %esi,%eax
f0103350:	e8 1e d7 ff ff       	call   f0100a73 <page2kva>
f0103355:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010335b:	74 24                	je     f0103381 <mem_init+0x1fc5>
f010335d:	c7 44 24 0c 2c 7b 10 	movl   $0xf0107b2c,0xc(%esp)
f0103364:	f0 
f0103365:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010336c:	f0 
f010336d:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0103374:	00 
f0103375:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f010337c:	e8 bf cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103381:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103388:	00 
f0103389:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010338e:	89 04 24             	mov    %eax,(%esp)
f0103391:	e8 c5 de ff ff       	call   f010125b <page_remove>
	assert(pp2->pp_ref == 0);
f0103396:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010339b:	74 24                	je     f01033c1 <mem_init+0x2005>
f010339d:	c7 44 24 0c 15 7e 10 	movl   $0xf0107e15,0xc(%esp)
f01033a4:	f0 
f01033a5:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01033ac:	f0 
f01033ad:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f01033b4:	00 
f01033b5:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01033bc:	e8 7f cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033c1:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01033c6:	8b 08                	mov    (%eax),%ecx
f01033c8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033ce:	89 da                	mov    %ebx,%edx
f01033d0:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01033d6:	c1 fa 03             	sar    $0x3,%edx
f01033d9:	c1 e2 0c             	shl    $0xc,%edx
f01033dc:	39 d1                	cmp    %edx,%ecx
f01033de:	74 24                	je     f0103404 <mem_init+0x2048>
f01033e0:	c7 44 24 0c b4 74 10 	movl   $0xf01074b4,0xc(%esp)
f01033e7:	f0 
f01033e8:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f01033ef:	f0 
f01033f0:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f01033f7:	00 
f01033f8:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f01033ff:	e8 3c cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103404:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010340a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010340f:	74 24                	je     f0103435 <mem_init+0x2079>
f0103411:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f0103418:	f0 
f0103419:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0103420:	f0 
f0103421:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0103428:	00 
f0103429:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0103430:	e8 0b cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103435:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010343b:	89 1c 24             	mov    %ebx,(%esp)
f010343e:	e8 0a dc ff ff       	call   f010104d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103443:	c7 04 24 58 7b 10 f0 	movl   $0xf0107b58,(%esp)
f010344a:	e8 16 0b 00 00       	call   f0103f65 <cprintf>
f010344f:	eb 1c                	jmp    f010346d <mem_init+0x20b1>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103451:	89 da                	mov    %ebx,%edx
f0103453:	89 f8                	mov    %edi,%eax
f0103455:	e8 5e d6 ff ff       	call   f0100ab8 <check_va2pa>
f010345a:	e9 0c fb ff ff       	jmp    f0102f6b <mem_init+0x1baf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010345f:	89 da                	mov    %ebx,%edx
f0103461:	89 f8                	mov    %edi,%eax
f0103463:	e8 50 d6 ff ff       	call   f0100ab8 <check_va2pa>
f0103468:	e9 0d fa ff ff       	jmp    f0102e7a <mem_init+0x1abe>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010346d:	83 c4 4c             	add    $0x4c,%esp
f0103470:	5b                   	pop    %ebx
f0103471:	5e                   	pop    %esi
f0103472:	5f                   	pop    %edi
f0103473:	5d                   	pop    %ebp
f0103474:	c3                   	ret    

f0103475 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103475:	55                   	push   %ebp
f0103476:	89 e5                	mov    %esp,%ebp
f0103478:	57                   	push   %edi
f0103479:	56                   	push   %esi
f010347a:	53                   	push   %ebx
f010347b:	83 ec 1c             	sub    $0x1c,%esp
f010347e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103481:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
pte_t * pte;
    	void * addr, *end;

    	addr = ROUNDDOWN((void *)va, PGSIZE);
f0103484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103487:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	end = ROUNDUP((void *)(va + len), PGSIZE);
f010348d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103490:	03 45 10             	add    0x10(%ebp),%eax
f0103493:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103498:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010349d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (addr >= (void *)ULIM)
f01034a0:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034a6:	76 5d                	jbe    f0103505 <user_mem_check+0x90>
    {
        user_mem_check_addr = (uintptr_t)va;
f01034a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034ab:	a3 3c 02 23 f0       	mov    %eax,0xf023023c
        return -E_FAULT;
f01034b0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b5:	eb 58                	jmp    f010350f <user_mem_check+0x9a>
    }

    for (; addr < end; addr += PGSIZE) {
        pte = pgdir_walk(env->env_pgdir, addr, 0);
f01034b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034be:	00 
f01034bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034c3:	8b 47 60             	mov    0x60(%edi),%eax
f01034c6:	89 04 24             	mov    %eax,(%esp)
f01034c9:	e8 e2 db ff ff       	call   f01010b0 <pgdir_walk>
        if (!pte || !(*pte & PTE_P) || (*pte & perm) != perm)
f01034ce:	85 c0                	test   %eax,%eax
f01034d0:	74 0c                	je     f01034de <user_mem_check+0x69>
f01034d2:	8b 00                	mov    (%eax),%eax
f01034d4:	a8 01                	test   $0x1,%al
f01034d6:	74 06                	je     f01034de <user_mem_check+0x69>
f01034d8:	21 f0                	and    %esi,%eax
f01034da:	39 c6                	cmp    %eax,%esi
f01034dc:	74 21                	je     f01034ff <user_mem_check+0x8a>
        {
            if (addr < va)
f01034de:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f01034e1:	76 0f                	jbe    f01034f2 <user_mem_check+0x7d>
            {
                user_mem_check_addr = (uintptr_t)va;
f01034e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034e6:	a3 3c 02 23 f0       	mov    %eax,0xf023023c
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
            }
            
            return -E_FAULT;
f01034eb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034f0:	eb 1d                	jmp    f010350f <user_mem_check+0x9a>
            {
                user_mem_check_addr = (uintptr_t)va;
            }
            else
            {
                user_mem_check_addr = (uintptr_t)addr;
f01034f2:	89 1d 3c 02 23 f0    	mov    %ebx,0xf023023c
            }
            
            return -E_FAULT;
f01034f8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034fd:	eb 10                	jmp    f010350f <user_mem_check+0x9a>
    {
        user_mem_check_addr = (uintptr_t)va;
        return -E_FAULT;
    }

    for (; addr < end; addr += PGSIZE) {
f01034ff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103505:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103508:	72 ad                	jb     f01034b7 <user_mem_check+0x42>
            
            return -E_FAULT;
        }
    }

	return 0;
f010350a:	b8 00 00 00 00       	mov    $0x0,%eax

}
f010350f:	83 c4 1c             	add    $0x1c,%esp
f0103512:	5b                   	pop    %ebx
f0103513:	5e                   	pop    %esi
f0103514:	5f                   	pop    %edi
f0103515:	5d                   	pop    %ebp
f0103516:	c3                   	ret    

f0103517 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103517:	55                   	push   %ebp
f0103518:	89 e5                	mov    %esp,%ebp
f010351a:	53                   	push   %ebx
f010351b:	83 ec 14             	sub    $0x14,%esp
f010351e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103521:	8b 45 14             	mov    0x14(%ebp),%eax
f0103524:	83 c8 04             	or     $0x4,%eax
f0103527:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010352b:	8b 45 10             	mov    0x10(%ebp),%eax
f010352e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103532:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103535:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103539:	89 1c 24             	mov    %ebx,(%esp)
f010353c:	e8 34 ff ff ff       	call   f0103475 <user_mem_check>
f0103541:	85 c0                	test   %eax,%eax
f0103543:	79 24                	jns    f0103569 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103545:	a1 3c 02 23 f0       	mov    0xf023023c,%eax
f010354a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010354e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103551:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103555:	c7 04 24 84 7b 10 f0 	movl   $0xf0107b84,(%esp)
f010355c:	e8 04 0a 00 00       	call   f0103f65 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103561:	89 1c 24             	mov    %ebx,(%esp)
f0103564:	e8 05 07 00 00       	call   f0103c6e <env_destroy>
	}
}
f0103569:	83 c4 14             	add    $0x14,%esp
f010356c:	5b                   	pop    %ebx
f010356d:	5d                   	pop    %ebp
f010356e:	c3                   	ret    

f010356f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010356f:	55                   	push   %ebp
f0103570:	89 e5                	mov    %esp,%ebp
f0103572:	57                   	push   %edi
f0103573:	56                   	push   %esi
f0103574:	53                   	push   %ebx
f0103575:	83 ec 2c             	sub    $0x2c,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
f0103578:	8b 78 60             	mov    0x60(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f010357b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103582:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103587:	89 d1                	mov    %edx,%ecx
f0103589:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010358f:	29 c8                	sub    %ecx,%eax
f0103591:	c1 e8 0c             	shr    $0xc,%eax
f0103594:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f0103597:	89 d6                	mov    %edx,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	pde_t* pgdir = e->env_pgdir;
	int i=0;
f0103599:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010359e:	eb 6d                	jmp    f010360d <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f01035a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035a7:	e8 16 da ff ff       	call   f0100fc2 <page_alloc>
		if(newPage == 0)
f01035ac:	85 c0                	test   %eax,%eax
f01035ae:	75 1c                	jne    f01035cc <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f01035b0:	c7 44 24 08 e4 7e 10 	movl   $0xf0107ee4,0x8(%esp)
f01035b7:	f0 
f01035b8:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01035bf:	00 
f01035c0:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f01035c7:	e8 74 ca ff ff       	call   f0100040 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f01035cc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035d3:	00 
f01035d4:	89 74 24 08          	mov    %esi,0x8(%esp)
f01035d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035dc:	89 3c 24             	mov    %edi,(%esp)
f01035df:	e8 d0 dc ff ff       	call   f01012b4 <page_insert>
f01035e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f01035ea:	85 c0                	test   %eax,%eax
f01035ec:	74 1c                	je     f010360a <region_alloc+0x9b>
			panic("page_insert fail\n");
f01035ee:	c7 44 24 08 1e 7f 10 	movl   $0xf0107f1e,0x8(%esp)
f01035f5:	f0 
f01035f6:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01035fd:	00 
f01035fe:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103605:	e8 36 ca ff ff       	call   f0100040 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f010360a:	83 c3 01             	add    $0x1,%ebx
f010360d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103610:	7c 8e                	jl     f01035a0 <region_alloc+0x31>
		if(ret)
			panic("page_insert fail\n");
	}
	return ;

}
f0103612:	83 c4 2c             	add    $0x2c,%esp
f0103615:	5b                   	pop    %ebx
f0103616:	5e                   	pop    %esi
f0103617:	5f                   	pop    %edi
f0103618:	5d                   	pop    %ebp
f0103619:	c3                   	ret    

f010361a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010361a:	55                   	push   %ebp
f010361b:	89 e5                	mov    %esp,%ebp
f010361d:	56                   	push   %esi
f010361e:	53                   	push   %ebx
f010361f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103622:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103625:	85 c0                	test   %eax,%eax
f0103627:	75 1a                	jne    f0103643 <envid2env+0x29>
		*env_store = curenv;
f0103629:	e8 6b 30 00 00       	call   f0106699 <cpunum>
f010362e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103631:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103637:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010363a:	89 01                	mov    %eax,(%ecx)
		return 0;
f010363c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103641:	eb 70                	jmp    f01036b3 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103643:	89 c3                	mov    %eax,%ebx
f0103645:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010364b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010364e:	03 1d 48 02 23 f0    	add    0xf0230248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103654:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103658:	74 05                	je     f010365f <envid2env+0x45>
f010365a:	39 43 48             	cmp    %eax,0x48(%ebx)
f010365d:	74 10                	je     f010366f <envid2env+0x55>
		// debug code
		//cprintf("the e->env_id =0x%x,  envid = 0x%x \n", e->env_id, envid);
		//cprintf("debug code\n\n");

		*env_store = 0;
f010365f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103662:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103668:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010366d:	eb 44                	jmp    f01036b3 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010366f:	84 d2                	test   %dl,%dl
f0103671:	74 36                	je     f01036a9 <envid2env+0x8f>
f0103673:	e8 21 30 00 00       	call   f0106699 <cpunum>
f0103678:	6b c0 74             	imul   $0x74,%eax,%eax
f010367b:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103681:	74 26                	je     f01036a9 <envid2env+0x8f>
f0103683:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103686:	e8 0e 30 00 00       	call   f0106699 <cpunum>
f010368b:	6b c0 74             	imul   $0x74,%eax,%eax
f010368e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103694:	3b 70 48             	cmp    0x48(%eax),%esi
f0103697:	74 10                	je     f01036a9 <envid2env+0x8f>
		*env_store = 0;
f0103699:	8b 45 0c             	mov    0xc(%ebp),%eax
f010369c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036a2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036a7:	eb 0a                	jmp    f01036b3 <envid2env+0x99>
	}

	*env_store = e;
f01036a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ac:	89 18                	mov    %ebx,(%eax)
	return 0;
f01036ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036b3:	5b                   	pop    %ebx
f01036b4:	5e                   	pop    %esi
f01036b5:	5d                   	pop    %ebp
f01036b6:	c3                   	ret    

f01036b7 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036b7:	55                   	push   %ebp
f01036b8:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036ba:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036bf:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036c2:	b8 23 00 00 00       	mov    $0x23,%eax
f01036c7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036c9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036cb:	b0 10                	mov    $0x10,%al
f01036cd:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036cf:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036d1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036d3:	ea da 36 10 f0 08 00 	ljmp   $0x8,$0xf01036da
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036da:	b0 00                	mov    $0x0,%al
f01036dc:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036df:	5d                   	pop    %ebp
f01036e0:	c3                   	ret    

f01036e1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036e1:	55                   	push   %ebp
f01036e2:	89 e5                	mov    %esp,%ebp
f01036e4:	56                   	push   %esi
f01036e5:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f01036e6:	8b 35 48 02 23 f0    	mov    0xf0230248,%esi
f01036ec:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01036f2:	ba 00 04 00 00       	mov    $0x400,%edx
f01036f7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01036fc:	89 c3                	mov    %eax,%ebx
f01036fe:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103705:	89 48 44             	mov    %ecx,0x44(%eax)
f0103708:	83 e8 7c             	sub    $0x7c,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f010370b:	83 ea 01             	sub    $0x1,%edx
f010370e:	74 04                	je     f0103714 <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103710:	89 d9                	mov    %ebx,%ecx
f0103712:	eb e8                	jmp    f01036fc <env_init+0x1b>
f0103714:	89 35 4c 02 23 f0    	mov    %esi,0xf023024c
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010371a:	e8 98 ff ff ff       	call   f01036b7 <env_init_percpu>
}
f010371f:	5b                   	pop    %ebx
f0103720:	5e                   	pop    %esi
f0103721:	5d                   	pop    %ebp
f0103722:	c3                   	ret    

f0103723 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103723:	55                   	push   %ebp
f0103724:	89 e5                	mov    %esp,%ebp
f0103726:	53                   	push   %ebx
f0103727:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010372a:	8b 1d 4c 02 23 f0    	mov    0xf023024c,%ebx
f0103730:	85 db                	test   %ebx,%ebx
f0103732:	0f 84 aa 01 00 00    	je     f01038e2 <env_alloc+0x1bf>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103738:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010373f:	e8 7e d8 ff ff       	call   f0100fc2 <page_alloc>
f0103744:	85 c0                	test   %eax,%eax
f0103746:	0f 84 9d 01 00 00    	je     f01038e9 <env_alloc+0x1c6>
f010374c:	89 c2                	mov    %eax,%edx
f010374e:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0103754:	c1 fa 03             	sar    $0x3,%edx
f0103757:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010375a:	89 d1                	mov    %edx,%ecx
f010375c:	c1 e9 0c             	shr    $0xc,%ecx
f010375f:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0103765:	72 20                	jb     f0103787 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103767:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010376b:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0103772:	f0 
f0103773:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010377a:	00 
f010377b:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0103782:	e8 b9 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103787:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010378d:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f0103790:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103795:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010379c:	00 
f010379d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01037a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037a6:	8b 43 60             	mov    0x60(%ebx),%eax
f01037a9:	89 04 24             	mov    %eax,(%esp)
f01037ac:	e8 4b 29 00 00       	call   f01060fc <memcpy>
	memset(e->env_pgdir, 0, UTOP>>PTSHIFT);
f01037b1:	c7 44 24 08 bb 03 00 	movl   $0x3bb,0x8(%esp)
f01037b8:	00 
f01037b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037c0:	00 
f01037c1:	8b 43 60             	mov    0x60(%ebx),%eax
f01037c4:	89 04 24             	mov    %eax,(%esp)
f01037c7:	e8 7b 28 00 00       	call   f0106047 <memset>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037cc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037d4:	77 20                	ja     f01037f6 <env_alloc+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037da:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f01037e1:	f0 
f01037e2:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f01037e9:	00 
f01037ea:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f01037f1:	e8 4a c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037f6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037fc:	83 ca 05             	or     $0x5,%edx
f01037ff:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103805:	8b 43 48             	mov    0x48(%ebx),%eax
f0103808:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010380d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103812:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103817:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010381a:	89 da                	mov    %ebx,%edx
f010381c:	2b 15 48 02 23 f0    	sub    0xf0230248,%edx
f0103822:	c1 fa 02             	sar    $0x2,%edx
f0103825:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010382b:	09 d0                	or     %edx,%eax
f010382d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103830:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103833:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103836:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010383d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103844:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010384b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103852:	00 
f0103853:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010385a:	00 
f010385b:	89 1c 24             	mov    %ebx,(%esp)
f010385e:	e8 e4 27 00 00       	call   f0106047 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103863:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103869:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010386f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103875:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010387c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	// time clock
	e->env_tf.tf_eflags |= FL_IF;
f0103882:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103889:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	//e->env_ipc_recving = 0;

	// commit the allocation
	env_free_list = e->env_link;
f0103890:	8b 43 44             	mov    0x44(%ebx),%eax
f0103893:	a3 4c 02 23 f0       	mov    %eax,0xf023024c
	*newenv_store = e;
f0103898:	8b 45 08             	mov    0x8(%ebp),%eax
f010389b:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010389d:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038a0:	e8 f4 2d 00 00       	call   f0106699 <cpunum>
f01038a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ad:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f01038b4:	74 11                	je     f01038c7 <env_alloc+0x1a4>
f01038b6:	e8 de 2d 00 00       	call   f0106699 <cpunum>
f01038bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038be:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01038c4:	8b 50 48             	mov    0x48(%eax),%edx
f01038c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038cb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038cf:	c7 04 24 30 7f 10 f0 	movl   $0xf0107f30,(%esp)
f01038d6:	e8 8a 06 00 00       	call   f0103f65 <cprintf>
	return 0;
f01038db:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e0:	eb 0c                	jmp    f01038ee <env_alloc+0x1cb>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038e2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038e7:	eb 05                	jmp    f01038ee <env_alloc+0x1cb>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038e9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038ee:	83 c4 14             	add    $0x14,%esp
f01038f1:	5b                   	pop    %ebx
f01038f2:	5d                   	pop    %ebp
f01038f3:	c3                   	ret    

f01038f4 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038f4:	55                   	push   %ebp
f01038f5:	89 e5                	mov    %esp,%ebp
f01038f7:	57                   	push   %edi
f01038f8:	56                   	push   %esi
f01038f9:	53                   	push   %ebx
f01038fa:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env* env=0;
f01038fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103904:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010390b:	00 
f010390c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010390f:	89 04 24             	mov    %eax,(%esp)
f0103912:	e8 0c fe ff ff       	call   f0103723 <env_alloc>
	if(r < 0)
f0103917:	85 c0                	test   %eax,%eax
f0103919:	79 1c                	jns    f0103937 <env_create+0x43>
		panic("env_create fault\n");
f010391b:	c7 44 24 08 45 7f 10 	movl   $0xf0107f45,0x8(%esp)
f0103922:	f0 
f0103923:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f010392a:	00 
f010392b:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103932:	e8 09 c7 ff ff       	call   f0100040 <_panic>
	load_icode(env, binary);
f0103937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010393a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010393d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103940:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103946:	74 1c                	je     f0103964 <env_create+0x70>
			panic("e_magic is not right\n");
f0103948:	c7 44 24 08 57 7f 10 	movl   $0xf0107f57,0x8(%esp)
f010394f:	f0 
f0103950:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f0103957:	00 
f0103958:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f010395f:	e8 dc c6 ff ff       	call   f0100040 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f0103964:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103967:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010396a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010396f:	77 20                	ja     f0103991 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103971:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103975:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f010397c:	f0 
f010397d:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0103984:	00 
f0103985:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f010398c:	e8 af c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103991:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103996:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f0103999:	8b 45 08             	mov    0x8(%ebp),%eax
f010399c:	89 c3                	mov    %eax,%ebx
f010399e:	03 58 1c             	add    0x1c(%eax),%ebx
f01039a1:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01039a5:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f01039a8:	be 01 00 00 00       	mov    $0x1,%esi
f01039ad:	eb 54                	jmp    f0103a03 <env_create+0x10f>
		int i=0;
		for(; i<num; i++){
			ph++;
f01039af:	83 c3 20             	add    $0x20,%ebx
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f01039b2:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039b5:	75 49                	jne    f0103a00 <env_create+0x10c>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f01039b7:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039ba:	8b 53 08             	mov    0x8(%ebx),%edx
f01039bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039c0:	e8 aa fb ff ff       	call   f010356f <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f01039c5:	8b 43 10             	mov    0x10(%ebx),%eax
f01039c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01039cf:	03 43 04             	add    0x4(%ebx),%eax
f01039d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d6:	8b 43 08             	mov    0x8(%ebx),%eax
f01039d9:	89 04 24             	mov    %eax,(%esp)
f01039dc:	e8 b3 26 00 00       	call   f0106094 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01039e1:	8b 43 10             	mov    0x10(%ebx),%eax
f01039e4:	8b 53 14             	mov    0x14(%ebx),%edx
f01039e7:	29 c2                	sub    %eax,%edx
f01039e9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039f4:	00 
f01039f5:	03 43 08             	add    0x8(%ebx),%eax
f01039f8:	89 04 24             	mov    %eax,(%esp)
f01039fb:	e8 47 26 00 00       	call   f0106047 <memset>
f0103a00:	83 c6 01             	add    $0x1,%esi

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103a03:	39 fe                	cmp    %edi,%esi
f0103a05:	75 a8                	jne    f01039af <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103a07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a0a:	8b 40 18             	mov    0x18(%eax),%eax
f0103a0d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a10:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103a13:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a18:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a1d:	89 f8                	mov    %edi,%eax
f0103a1f:	e8 4b fb ff ff       	call   f010356f <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f0103a24:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a2e:	77 20                	ja     f0103a50 <env_create+0x15c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a34:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0103a3b:	f0 
f0103a3c:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
f0103a43:	00 
f0103a44:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103a4b:	e8 f0 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a50:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a55:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f0103a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a5e:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a61:	83 c4 3c             	add    $0x3c,%esp
f0103a64:	5b                   	pop    %ebx
f0103a65:	5e                   	pop    %esi
f0103a66:	5f                   	pop    %edi
f0103a67:	5d                   	pop    %ebp
f0103a68:	c3                   	ret    

f0103a69 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a69:	55                   	push   %ebp
f0103a6a:	89 e5                	mov    %esp,%ebp
f0103a6c:	57                   	push   %edi
f0103a6d:	56                   	push   %esi
f0103a6e:	53                   	push   %ebx
f0103a6f:	83 ec 2c             	sub    $0x2c,%esp
f0103a72:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a75:	e8 1f 2c 00 00       	call   f0106699 <cpunum>
f0103a7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a7d:	39 b8 28 10 23 f0    	cmp    %edi,-0xfdcefd8(%eax)
f0103a83:	75 34                	jne    f0103ab9 <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a85:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a8a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a8f:	77 20                	ja     f0103ab1 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a95:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0103a9c:	f0 
f0103a9d:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0103aa4:	00 
f0103aa5:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103aac:	e8 8f c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ab1:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ab6:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ab9:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103abc:	e8 d8 2b 00 00       	call   f0106699 <cpunum>
f0103ac1:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ac4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ac9:	83 ba 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%edx)
f0103ad0:	74 11                	je     f0103ae3 <env_free+0x7a>
f0103ad2:	e8 c2 2b 00 00       	call   f0106699 <cpunum>
f0103ad7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ada:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103ae0:	8b 40 48             	mov    0x48(%eax),%eax
f0103ae3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aeb:	c7 04 24 6d 7f 10 f0 	movl   $0xf0107f6d,(%esp)
f0103af2:	e8 6e 04 00 00       	call   f0103f65 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103af7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103afe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b01:	89 c8                	mov    %ecx,%eax
f0103b03:	c1 e0 02             	shl    $0x2,%eax
f0103b06:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b09:	8b 47 60             	mov    0x60(%edi),%eax
f0103b0c:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b0f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b15:	0f 84 b7 00 00 00    	je     f0103bd2 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b1b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b21:	89 f0                	mov    %esi,%eax
f0103b23:	c1 e8 0c             	shr    $0xc,%eax
f0103b26:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b29:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103b2f:	72 20                	jb     f0103b51 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b31:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b35:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0103b3c:	f0 
f0103b3d:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f0103b44:	00 
f0103b45:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103b4c:	e8 ef c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b54:	c1 e0 16             	shl    $0x16,%eax
f0103b57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b5a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b5f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b66:	01 
f0103b67:	74 17                	je     f0103b80 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b69:	89 d8                	mov    %ebx,%eax
f0103b6b:	c1 e0 0c             	shl    $0xc,%eax
f0103b6e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b75:	8b 47 60             	mov    0x60(%edi),%eax
f0103b78:	89 04 24             	mov    %eax,(%esp)
f0103b7b:	e8 db d6 ff ff       	call   f010125b <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b80:	83 c3 01             	add    $0x1,%ebx
f0103b83:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b89:	75 d4                	jne    f0103b5f <env_free+0xf6>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b8b:	8b 47 60             	mov    0x60(%edi),%eax
f0103b8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b91:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b98:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b9b:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103ba1:	72 1c                	jb     f0103bbf <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103ba3:	c7 44 24 08 60 73 10 	movl   $0xf0107360,0x8(%esp)
f0103baa:	f0 
f0103bab:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bb2:	00 
f0103bb3:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0103bba:	e8 81 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bbf:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0103bc4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bc7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103bca:	89 04 24             	mov    %eax,(%esp)
f0103bcd:	e8 bb d4 ff ff       	call   f010108d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bd2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bd6:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bdd:	0f 85 1b ff ff ff    	jne    f0103afe <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103be3:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103be6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103beb:	77 20                	ja     f0103c0d <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bf1:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0103bf8:	f0 
f0103bf9:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
f0103c00:	00 
f0103c01:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103c08:	e8 33 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c0d:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c14:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c19:	c1 e8 0c             	shr    $0xc,%eax
f0103c1c:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103c22:	72 1c                	jb     f0103c40 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103c24:	c7 44 24 08 60 73 10 	movl   $0xf0107360,0x8(%esp)
f0103c2b:	f0 
f0103c2c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c33:	00 
f0103c34:	c7 04 24 b9 7b 10 f0 	movl   $0xf0107bb9,(%esp)
f0103c3b:	e8 00 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c40:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0103c46:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c49:	89 04 24             	mov    %eax,(%esp)
f0103c4c:	e8 3c d4 ff ff       	call   f010108d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c51:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c58:	a1 4c 02 23 f0       	mov    0xf023024c,%eax
f0103c5d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c60:	89 3d 4c 02 23 f0    	mov    %edi,0xf023024c
}
f0103c66:	83 c4 2c             	add    $0x2c,%esp
f0103c69:	5b                   	pop    %ebx
f0103c6a:	5e                   	pop    %esi
f0103c6b:	5f                   	pop    %edi
f0103c6c:	5d                   	pop    %ebp
f0103c6d:	c3                   	ret    

f0103c6e <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c6e:	55                   	push   %ebp
f0103c6f:	89 e5                	mov    %esp,%ebp
f0103c71:	53                   	push   %ebx
f0103c72:	83 ec 14             	sub    $0x14,%esp
f0103c75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c78:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c7c:	75 19                	jne    f0103c97 <env_destroy+0x29>
f0103c7e:	e8 16 2a 00 00       	call   f0106699 <cpunum>
f0103c83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c86:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103c8c:	74 09                	je     f0103c97 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c8e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c95:	eb 2f                	jmp    f0103cc6 <env_destroy+0x58>
	}

	env_free(e);
f0103c97:	89 1c 24             	mov    %ebx,(%esp)
f0103c9a:	e8 ca fd ff ff       	call   f0103a69 <env_free>

	if (curenv == e) {
f0103c9f:	e8 f5 29 00 00       	call   f0106699 <cpunum>
f0103ca4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ca7:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103cad:	75 17                	jne    f0103cc6 <env_destroy+0x58>
		curenv = NULL;
f0103caf:	e8 e5 29 00 00       	call   f0106699 <cpunum>
f0103cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb7:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0103cbe:	00 00 00 
		sched_yield();
f0103cc1:	e8 01 10 00 00       	call   f0104cc7 <sched_yield>
	}
}
f0103cc6:	83 c4 14             	add    $0x14,%esp
f0103cc9:	5b                   	pop    %ebx
f0103cca:	5d                   	pop    %ebp
f0103ccb:	c3                   	ret    

f0103ccc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ccc:	55                   	push   %ebp
f0103ccd:	89 e5                	mov    %esp,%ebp
f0103ccf:	53                   	push   %ebx
f0103cd0:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cd3:	e8 c1 29 00 00       	call   f0106699 <cpunum>
f0103cd8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cdb:	8b 98 28 10 23 f0    	mov    -0xfdcefd8(%eax),%ebx
f0103ce1:	e8 b3 29 00 00       	call   f0106699 <cpunum>
f0103ce6:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103ce9:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cec:	61                   	popa   
f0103ced:	07                   	pop    %es
f0103cee:	1f                   	pop    %ds
f0103cef:	83 c4 08             	add    $0x8,%esp
f0103cf2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cf3:	c7 44 24 08 83 7f 10 	movl   $0xf0107f83,0x8(%esp)
f0103cfa:	f0 
f0103cfb:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0103d02:	00 
f0103d03:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103d0a:	e8 31 c3 ff ff       	call   f0100040 <_panic>

f0103d0f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d0f:	55                   	push   %ebp
f0103d10:	89 e5                	mov    %esp,%ebp
f0103d12:	53                   	push   %ebx
f0103d13:	83 ec 14             	sub    $0x14,%esp
f0103d16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103d19:	e8 7b 29 00 00       	call   f0106699 <cpunum>
f0103d1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d21:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0103d28:	75 10                	jne    f0103d3a <env_run+0x2b>
		curenv = e;
f0103d2a:	e8 6a 29 00 00       	call   f0106699 <cpunum>
f0103d2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d32:	89 98 28 10 23 f0    	mov    %ebx,-0xfdcefd8(%eax)
f0103d38:	eb 29                	jmp    f0103d63 <env_run+0x54>
	else if(curenv->env_status == ENV_RUNNING)
f0103d3a:	e8 5a 29 00 00       	call   f0106699 <cpunum>
f0103d3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d42:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d48:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d4c:	75 15                	jne    f0103d63 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d4e:	e8 46 29 00 00       	call   f0106699 <cpunum>
f0103d53:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d56:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d5c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103d63:	e8 31 29 00 00       	call   f0106699 <cpunum>
f0103d68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6b:	89 98 28 10 23 f0    	mov    %ebx,-0xfdcefd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103d71:	e8 23 29 00 00       	call   f0106699 <cpunum>
f0103d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d79:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d7f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d86:	e8 0e 29 00 00       	call   f0106699 <cpunum>
f0103d8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d8e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d94:	83 40 58 01          	addl   $0x1,0x58(%eax)
//	cprintf("the eip is %x\n", curenv->env_id);
	lcr3( PADDR(curenv->env_pgdir) );
f0103d98:	e8 fc 28 00 00       	call   f0106699 <cpunum>
f0103d9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da0:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103da6:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103da9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dae:	77 20                	ja     f0103dd0 <env_run+0xc1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103db0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103db4:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0103dbb:	f0 
f0103dbc:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
f0103dc3:	00 
f0103dc4:	c7 04 24 13 7f 10 f0 	movl   $0xf0107f13,(%esp)
f0103dcb:	e8 70 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103dd0:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dd5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dd8:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103ddf:	e8 df 2b 00 00       	call   f01069c3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103de4:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(& (curenv->env_tf) );
f0103de6:	e8 ae 28 00 00       	call   f0106699 <cpunum>
f0103deb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dee:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103df4:	89 04 24             	mov    %eax,(%esp)
f0103df7:	e8 d0 fe ff ff       	call   f0103ccc <env_pop_tf>

f0103dfc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dfc:	55                   	push   %ebp
f0103dfd:	89 e5                	mov    %esp,%ebp
f0103dff:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e03:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e08:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e09:	b2 71                	mov    $0x71,%dl
f0103e0b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e0c:	0f b6 c0             	movzbl %al,%eax
}
f0103e0f:	5d                   	pop    %ebp
f0103e10:	c3                   	ret    

f0103e11 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e11:	55                   	push   %ebp
f0103e12:	89 e5                	mov    %esp,%ebp
f0103e14:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e18:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e1d:	ee                   	out    %al,(%dx)
f0103e1e:	b2 71                	mov    $0x71,%dl
f0103e20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e23:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e24:	5d                   	pop    %ebp
f0103e25:	c3                   	ret    

f0103e26 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e26:	55                   	push   %ebp
f0103e27:	89 e5                	mov    %esp,%ebp
f0103e29:	56                   	push   %esi
f0103e2a:	53                   	push   %ebx
f0103e2b:	83 ec 10             	sub    $0x10,%esp
f0103e2e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103e31:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103e37:	80 3d 50 02 23 f0 00 	cmpb   $0x0,0xf0230250
f0103e3e:	74 4e                	je     f0103e8e <irq_setmask_8259A+0x68>
f0103e40:	89 c6                	mov    %eax,%esi
f0103e42:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e47:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e48:	66 c1 e8 08          	shr    $0x8,%ax
f0103e4c:	b2 a1                	mov    $0xa1,%dl
f0103e4e:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e4f:	c7 04 24 8f 7f 10 f0 	movl   $0xf0107f8f,(%esp)
f0103e56:	e8 0a 01 00 00       	call   f0103f65 <cprintf>
	for (i = 0; i < 16; i++)
f0103e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e60:	0f b7 f6             	movzwl %si,%esi
f0103e63:	f7 d6                	not    %esi
f0103e65:	0f a3 de             	bt     %ebx,%esi
f0103e68:	73 10                	jae    f0103e7a <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103e6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e6e:	c7 04 24 5b 84 10 f0 	movl   $0xf010845b,(%esp)
f0103e75:	e8 eb 00 00 00       	call   f0103f65 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e7a:	83 c3 01             	add    $0x1,%ebx
f0103e7d:	83 fb 10             	cmp    $0x10,%ebx
f0103e80:	75 e3                	jne    f0103e65 <irq_setmask_8259A+0x3f>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e82:	c7 04 24 b0 7e 10 f0 	movl   $0xf0107eb0,(%esp)
f0103e89:	e8 d7 00 00 00       	call   f0103f65 <cprintf>
}
f0103e8e:	83 c4 10             	add    $0x10,%esp
f0103e91:	5b                   	pop    %ebx
f0103e92:	5e                   	pop    %esi
f0103e93:	5d                   	pop    %ebp
f0103e94:	c3                   	ret    

f0103e95 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103e95:	c6 05 50 02 23 f0 01 	movb   $0x1,0xf0230250
f0103e9c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ea6:	ee                   	out    %al,(%dx)
f0103ea7:	b2 a1                	mov    $0xa1,%dl
f0103ea9:	ee                   	out    %al,(%dx)
f0103eaa:	b2 20                	mov    $0x20,%dl
f0103eac:	b8 11 00 00 00       	mov    $0x11,%eax
f0103eb1:	ee                   	out    %al,(%dx)
f0103eb2:	b2 21                	mov    $0x21,%dl
f0103eb4:	b8 20 00 00 00       	mov    $0x20,%eax
f0103eb9:	ee                   	out    %al,(%dx)
f0103eba:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ebf:	ee                   	out    %al,(%dx)
f0103ec0:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ec5:	ee                   	out    %al,(%dx)
f0103ec6:	b2 a0                	mov    $0xa0,%dl
f0103ec8:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ecd:	ee                   	out    %al,(%dx)
f0103ece:	b2 a1                	mov    $0xa1,%dl
f0103ed0:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ed5:	ee                   	out    %al,(%dx)
f0103ed6:	b8 02 00 00 00       	mov    $0x2,%eax
f0103edb:	ee                   	out    %al,(%dx)
f0103edc:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ee1:	ee                   	out    %al,(%dx)
f0103ee2:	b2 20                	mov    $0x20,%dl
f0103ee4:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ee9:	ee                   	out    %al,(%dx)
f0103eea:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103eef:	ee                   	out    %al,(%dx)
f0103ef0:	b2 a0                	mov    $0xa0,%dl
f0103ef2:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ef7:	ee                   	out    %al,(%dx)
f0103ef8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103efd:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103efe:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103f05:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103f09:	74 12                	je     f0103f1d <pic_init+0x88>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f0b:	55                   	push   %ebp
f0103f0c:	89 e5                	mov    %esp,%ebp
f0103f0e:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103f11:	0f b7 c0             	movzwl %ax,%eax
f0103f14:	89 04 24             	mov    %eax,(%esp)
f0103f17:	e8 0a ff ff ff       	call   f0103e26 <irq_setmask_8259A>
}
f0103f1c:	c9                   	leave  
f0103f1d:	f3 c3                	repz ret 

f0103f1f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f1f:	55                   	push   %ebp
f0103f20:	89 e5                	mov    %esp,%ebp
f0103f22:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f25:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f28:	89 04 24             	mov    %eax,(%esp)
f0103f2b:	e8 5a c8 ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f0103f30:	c9                   	leave  
f0103f31:	c3                   	ret    

f0103f32 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f32:	55                   	push   %ebp
f0103f33:	89 e5                	mov    %esp,%ebp
f0103f35:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f46:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f49:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f54:	c7 04 24 1f 3f 10 f0 	movl   $0xf0103f1f,(%esp)
f0103f5b:	e8 a4 19 00 00       	call   f0105904 <vprintfmt>
	return cnt;
}
f0103f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f63:	c9                   	leave  
f0103f64:	c3                   	ret    

f0103f65 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f65:	55                   	push   %ebp
f0103f66:	89 e5                	mov    %esp,%ebp
f0103f68:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f6b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f72:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f75:	89 04 24             	mov    %eax,(%esp)
f0103f78:	e8 b5 ff ff ff       	call   f0103f32 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f7d:	c9                   	leave  
f0103f7e:	c3                   	ret    
f0103f7f:	90                   	nop

f0103f80 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f80:	55                   	push   %ebp
f0103f81:	89 e5                	mov    %esp,%ebp
f0103f83:	57                   	push   %edi
f0103f84:	56                   	push   %esi
f0103f85:	53                   	push   %ebx
f0103f86:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int cpu_id = thiscpu->cpu_id;
f0103f89:	e8 0b 27 00 00       	call   f0106699 <cpunum>
f0103f8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f91:	0f b6 98 20 10 23 f0 	movzbl -0xfdcefe0(%eax),%ebx
	cprintf("cpu_id == %d\n",cpu_id );
f0103f98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f9c:	c7 04 24 a3 7f 10 f0 	movl   $0xf0107fa3,(%esp)
f0103fa3:	e8 bd ff ff ff       	call   f0103f65 <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103fa8:	e8 ec 26 00 00       	call   f0106699 <cpunum>
f0103fad:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb0:	89 da                	mov    %ebx,%edx
f0103fb2:	f7 da                	neg    %edx
f0103fb4:	c1 e2 10             	shl    $0x10,%edx
f0103fb7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fbd:	89 90 30 10 23 f0    	mov    %edx,-0xfdcefd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fc3:	e8 d1 26 00 00       	call   f0106699 <cpunum>
f0103fc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fcb:	66 c7 80 34 10 23 f0 	movw   $0x10,-0xfdcefcc(%eax)
f0103fd2:	10 00 
	gdt[ (GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts) ),
f0103fd4:	83 c3 05             	add    $0x5,%ebx
f0103fd7:	e8 bd 26 00 00       	call   f0106699 <cpunum>
f0103fdc:	89 c7                	mov    %eax,%edi
f0103fde:	e8 b6 26 00 00       	call   f0106699 <cpunum>
f0103fe3:	89 c6                	mov    %eax,%esi
f0103fe5:	e8 af 26 00 00       	call   f0106699 <cpunum>
f0103fea:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0103ff1:	f0 67 00 
f0103ff4:	6b ff 74             	imul   $0x74,%edi,%edi
f0103ff7:	81 c7 2c 10 23 f0    	add    $0xf023102c,%edi
f0103ffd:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0104004:	f0 
f0104005:	6b d6 74             	imul   $0x74,%esi,%edx
f0104008:	81 c2 2c 10 23 f0    	add    $0xf023102c,%edx
f010400e:	c1 ea 10             	shr    $0x10,%edx
f0104011:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0104018:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010401f:	40 
f0104020:	6b c0 74             	imul   $0x74,%eax,%eax
f0104023:	05 2c 10 23 f0       	add    $0xf023102c,%eax
f0104028:	c1 e8 18             	shr    $0x18,%eax
f010402b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0104032:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0104039:	89 
	ltr(GD_TSS0 + 8*cpu_id);
f010403a:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010403d:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104040:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f0104045:	0f 01 18             	lidtl  (%eax)
	// Load the IDT
	lidt(&idt_pd);
	*/


}
f0104048:	83 c4 1c             	add    $0x1c,%esp
f010404b:	5b                   	pop    %ebx
f010404c:	5e                   	pop    %esi
f010404d:	5f                   	pop    %edi
f010404e:	5d                   	pop    %ebp
f010404f:	c3                   	ret    

f0104050 <trap_init>:
}


void
trap_init(void)
{
f0104050:	55                   	push   %ebp
f0104051:	89 e5                	mov    %esp,%ebp
f0104053:	83 ec 08             	sub    $0x8,%esp
    void handlerIRQ7();
    void handlerIRQ14();
    void handlerIRQ19();
 

    SETGATE(idt[0], 0, GD_KT, handler0, 0);
f0104056:	b8 e0 4a 10 f0       	mov    $0xf0104ae0,%eax
f010405b:	66 a3 60 02 23 f0    	mov    %ax,0xf0230260
f0104061:	66 c7 05 62 02 23 f0 	movw   $0x8,0xf0230262
f0104068:	08 00 
f010406a:	c6 05 64 02 23 f0 00 	movb   $0x0,0xf0230264
f0104071:	c6 05 65 02 23 f0 8e 	movb   $0x8e,0xf0230265
f0104078:	c1 e8 10             	shr    $0x10,%eax
f010407b:	66 a3 66 02 23 f0    	mov    %ax,0xf0230266
    SETGATE(idt[1], 0, GD_KT, handler1, 0);
f0104081:	b8 ea 4a 10 f0       	mov    $0xf0104aea,%eax
f0104086:	66 a3 68 02 23 f0    	mov    %ax,0xf0230268
f010408c:	66 c7 05 6a 02 23 f0 	movw   $0x8,0xf023026a
f0104093:	08 00 
f0104095:	c6 05 6c 02 23 f0 00 	movb   $0x0,0xf023026c
f010409c:	c6 05 6d 02 23 f0 8e 	movb   $0x8e,0xf023026d
f01040a3:	c1 e8 10             	shr    $0x10,%eax
f01040a6:	66 a3 6e 02 23 f0    	mov    %ax,0xf023026e
    SETGATE(idt[2], 0, GD_KT, handler2, 0);
f01040ac:	b8 f4 4a 10 f0       	mov    $0xf0104af4,%eax
f01040b1:	66 a3 70 02 23 f0    	mov    %ax,0xf0230270
f01040b7:	66 c7 05 72 02 23 f0 	movw   $0x8,0xf0230272
f01040be:	08 00 
f01040c0:	c6 05 74 02 23 f0 00 	movb   $0x0,0xf0230274
f01040c7:	c6 05 75 02 23 f0 8e 	movb   $0x8e,0xf0230275
f01040ce:	c1 e8 10             	shr    $0x10,%eax
f01040d1:	66 a3 76 02 23 f0    	mov    %ax,0xf0230276
    SETGATE(idt[3], 0, GD_KT, handler3, 3);
f01040d7:	b8 fe 4a 10 f0       	mov    $0xf0104afe,%eax
f01040dc:	66 a3 78 02 23 f0    	mov    %ax,0xf0230278
f01040e2:	66 c7 05 7a 02 23 f0 	movw   $0x8,0xf023027a
f01040e9:	08 00 
f01040eb:	c6 05 7c 02 23 f0 00 	movb   $0x0,0xf023027c
f01040f2:	c6 05 7d 02 23 f0 ee 	movb   $0xee,0xf023027d
f01040f9:	c1 e8 10             	shr    $0x10,%eax
f01040fc:	66 a3 7e 02 23 f0    	mov    %ax,0xf023027e
    SETGATE(idt[4], 0, GD_KT, handler4, 0);
f0104102:	b8 08 4b 10 f0       	mov    $0xf0104b08,%eax
f0104107:	66 a3 80 02 23 f0    	mov    %ax,0xf0230280
f010410d:	66 c7 05 82 02 23 f0 	movw   $0x8,0xf0230282
f0104114:	08 00 
f0104116:	c6 05 84 02 23 f0 00 	movb   $0x0,0xf0230284
f010411d:	c6 05 85 02 23 f0 8e 	movb   $0x8e,0xf0230285
f0104124:	c1 e8 10             	shr    $0x10,%eax
f0104127:	66 a3 86 02 23 f0    	mov    %ax,0xf0230286
    SETGATE(idt[5], 0, GD_KT, handler5, 0);
f010412d:	b8 12 4b 10 f0       	mov    $0xf0104b12,%eax
f0104132:	66 a3 88 02 23 f0    	mov    %ax,0xf0230288
f0104138:	66 c7 05 8a 02 23 f0 	movw   $0x8,0xf023028a
f010413f:	08 00 
f0104141:	c6 05 8c 02 23 f0 00 	movb   $0x0,0xf023028c
f0104148:	c6 05 8d 02 23 f0 8e 	movb   $0x8e,0xf023028d
f010414f:	c1 e8 10             	shr    $0x10,%eax
f0104152:	66 a3 8e 02 23 f0    	mov    %ax,0xf023028e
    SETGATE(idt[6], 0, GD_KT, handler6, 0);
f0104158:	b8 1c 4b 10 f0       	mov    $0xf0104b1c,%eax
f010415d:	66 a3 90 02 23 f0    	mov    %ax,0xf0230290
f0104163:	66 c7 05 92 02 23 f0 	movw   $0x8,0xf0230292
f010416a:	08 00 
f010416c:	c6 05 94 02 23 f0 00 	movb   $0x0,0xf0230294
f0104173:	c6 05 95 02 23 f0 8e 	movb   $0x8e,0xf0230295
f010417a:	c1 e8 10             	shr    $0x10,%eax
f010417d:	66 a3 96 02 23 f0    	mov    %ax,0xf0230296
    SETGATE(idt[7], 0, GD_KT, handler7, 0);
f0104183:	b8 26 4b 10 f0       	mov    $0xf0104b26,%eax
f0104188:	66 a3 98 02 23 f0    	mov    %ax,0xf0230298
f010418e:	66 c7 05 9a 02 23 f0 	movw   $0x8,0xf023029a
f0104195:	08 00 
f0104197:	c6 05 9c 02 23 f0 00 	movb   $0x0,0xf023029c
f010419e:	c6 05 9d 02 23 f0 8e 	movb   $0x8e,0xf023029d
f01041a5:	c1 e8 10             	shr    $0x10,%eax
f01041a8:	66 a3 9e 02 23 f0    	mov    %ax,0xf023029e
    SETGATE(idt[8], 0, GD_KT, handler8, 0);
f01041ae:	b8 30 4b 10 f0       	mov    $0xf0104b30,%eax
f01041b3:	66 a3 a0 02 23 f0    	mov    %ax,0xf02302a0
f01041b9:	66 c7 05 a2 02 23 f0 	movw   $0x8,0xf02302a2
f01041c0:	08 00 
f01041c2:	c6 05 a4 02 23 f0 00 	movb   $0x0,0xf02302a4
f01041c9:	c6 05 a5 02 23 f0 8e 	movb   $0x8e,0xf02302a5
f01041d0:	c1 e8 10             	shr    $0x10,%eax
f01041d3:	66 a3 a6 02 23 f0    	mov    %ax,0xf02302a6
    SETGATE(idt[9], 0, GD_KT, handler9, 0);
f01041d9:	b8 38 4b 10 f0       	mov    $0xf0104b38,%eax
f01041de:	66 a3 a8 02 23 f0    	mov    %ax,0xf02302a8
f01041e4:	66 c7 05 aa 02 23 f0 	movw   $0x8,0xf02302aa
f01041eb:	08 00 
f01041ed:	c6 05 ac 02 23 f0 00 	movb   $0x0,0xf02302ac
f01041f4:	c6 05 ad 02 23 f0 8e 	movb   $0x8e,0xf02302ad
f01041fb:	c1 e8 10             	shr    $0x10,%eax
f01041fe:	66 a3 ae 02 23 f0    	mov    %ax,0xf02302ae
    SETGATE(idt[10], 0, GD_KT, handler10, 0);
f0104204:	b8 42 4b 10 f0       	mov    $0xf0104b42,%eax
f0104209:	66 a3 b0 02 23 f0    	mov    %ax,0xf02302b0
f010420f:	66 c7 05 b2 02 23 f0 	movw   $0x8,0xf02302b2
f0104216:	08 00 
f0104218:	c6 05 b4 02 23 f0 00 	movb   $0x0,0xf02302b4
f010421f:	c6 05 b5 02 23 f0 8e 	movb   $0x8e,0xf02302b5
f0104226:	c1 e8 10             	shr    $0x10,%eax
f0104229:	66 a3 b6 02 23 f0    	mov    %ax,0xf02302b6
    SETGATE(idt[11], 0, GD_KT, handler11, 0);
f010422f:	b8 4a 4b 10 f0       	mov    $0xf0104b4a,%eax
f0104234:	66 a3 b8 02 23 f0    	mov    %ax,0xf02302b8
f010423a:	66 c7 05 ba 02 23 f0 	movw   $0x8,0xf02302ba
f0104241:	08 00 
f0104243:	c6 05 bc 02 23 f0 00 	movb   $0x0,0xf02302bc
f010424a:	c6 05 bd 02 23 f0 8e 	movb   $0x8e,0xf02302bd
f0104251:	c1 e8 10             	shr    $0x10,%eax
f0104254:	66 a3 be 02 23 f0    	mov    %ax,0xf02302be
    SETGATE(idt[12], 0, GD_KT, handler12, 0);
f010425a:	b8 52 4b 10 f0       	mov    $0xf0104b52,%eax
f010425f:	66 a3 c0 02 23 f0    	mov    %ax,0xf02302c0
f0104265:	66 c7 05 c2 02 23 f0 	movw   $0x8,0xf02302c2
f010426c:	08 00 
f010426e:	c6 05 c4 02 23 f0 00 	movb   $0x0,0xf02302c4
f0104275:	c6 05 c5 02 23 f0 8e 	movb   $0x8e,0xf02302c5
f010427c:	c1 e8 10             	shr    $0x10,%eax
f010427f:	66 a3 c6 02 23 f0    	mov    %ax,0xf02302c6
    SETGATE(idt[13], 0, GD_KT, handler13, 0);
f0104285:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f010428a:	66 a3 c8 02 23 f0    	mov    %ax,0xf02302c8
f0104290:	66 c7 05 ca 02 23 f0 	movw   $0x8,0xf02302ca
f0104297:	08 00 
f0104299:	c6 05 cc 02 23 f0 00 	movb   $0x0,0xf02302cc
f01042a0:	c6 05 cd 02 23 f0 8e 	movb   $0x8e,0xf02302cd
f01042a7:	c1 e8 10             	shr    $0x10,%eax
f01042aa:	66 a3 ce 02 23 f0    	mov    %ax,0xf02302ce
    SETGATE(idt[14], 0, GD_KT, handler14, 0);
f01042b0:	b8 62 4b 10 f0       	mov    $0xf0104b62,%eax
f01042b5:	66 a3 d0 02 23 f0    	mov    %ax,0xf02302d0
f01042bb:	66 c7 05 d2 02 23 f0 	movw   $0x8,0xf02302d2
f01042c2:	08 00 
f01042c4:	c6 05 d4 02 23 f0 00 	movb   $0x0,0xf02302d4
f01042cb:	c6 05 d5 02 23 f0 8e 	movb   $0x8e,0xf02302d5
f01042d2:	c1 e8 10             	shr    $0x10,%eax
f01042d5:	66 a3 d6 02 23 f0    	mov    %ax,0xf02302d6
    SETGATE(idt[15], 0, GD_KT, handler15, 0);
f01042db:	b8 6a 4b 10 f0       	mov    $0xf0104b6a,%eax
f01042e0:	66 a3 d8 02 23 f0    	mov    %ax,0xf02302d8
f01042e6:	66 c7 05 da 02 23 f0 	movw   $0x8,0xf02302da
f01042ed:	08 00 
f01042ef:	c6 05 dc 02 23 f0 00 	movb   $0x0,0xf02302dc
f01042f6:	c6 05 dd 02 23 f0 8e 	movb   $0x8e,0xf02302dd
f01042fd:	c1 e8 10             	shr    $0x10,%eax
f0104300:	66 a3 de 02 23 f0    	mov    %ax,0xf02302de
    SETGATE(idt[16], 0, GD_KT, handler16, 0);
f0104306:	b8 74 4b 10 f0       	mov    $0xf0104b74,%eax
f010430b:	66 a3 e0 02 23 f0    	mov    %ax,0xf02302e0
f0104311:	66 c7 05 e2 02 23 f0 	movw   $0x8,0xf02302e2
f0104318:	08 00 
f010431a:	c6 05 e4 02 23 f0 00 	movb   $0x0,0xf02302e4
f0104321:	c6 05 e5 02 23 f0 8e 	movb   $0x8e,0xf02302e5
f0104328:	c1 e8 10             	shr    $0x10,%eax
f010432b:	66 a3 e6 02 23 f0    	mov    %ax,0xf02302e6
    SETGATE(idt[17], 0, GD_KT, handler17, 0);
f0104331:	b8 7e 4b 10 f0       	mov    $0xf0104b7e,%eax
f0104336:	66 a3 e8 02 23 f0    	mov    %ax,0xf02302e8
f010433c:	66 c7 05 ea 02 23 f0 	movw   $0x8,0xf02302ea
f0104343:	08 00 
f0104345:	c6 05 ec 02 23 f0 00 	movb   $0x0,0xf02302ec
f010434c:	c6 05 ed 02 23 f0 8e 	movb   $0x8e,0xf02302ed
f0104353:	c1 e8 10             	shr    $0x10,%eax
f0104356:	66 a3 ee 02 23 f0    	mov    %ax,0xf02302ee
    SETGATE(idt[18], 0, GD_KT, handler18, 0);
f010435c:	b8 86 4b 10 f0       	mov    $0xf0104b86,%eax
f0104361:	66 a3 f0 02 23 f0    	mov    %ax,0xf02302f0
f0104367:	66 c7 05 f2 02 23 f0 	movw   $0x8,0xf02302f2
f010436e:	08 00 
f0104370:	c6 05 f4 02 23 f0 00 	movb   $0x0,0xf02302f4
f0104377:	c6 05 f5 02 23 f0 8e 	movb   $0x8e,0xf02302f5
f010437e:	c1 e8 10             	shr    $0x10,%eax
f0104381:	66 a3 f6 02 23 f0    	mov    %ax,0xf02302f6
    SETGATE(idt[19], 0, GD_KT, handler19, 0);
f0104387:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f010438c:	66 a3 f8 02 23 f0    	mov    %ax,0xf02302f8
f0104392:	66 c7 05 fa 02 23 f0 	movw   $0x8,0xf02302fa
f0104399:	08 00 
f010439b:	c6 05 fc 02 23 f0 00 	movb   $0x0,0xf02302fc
f01043a2:	c6 05 fd 02 23 f0 8e 	movb   $0x8e,0xf02302fd
f01043a9:	c1 e8 10             	shr    $0x10,%eax
f01043ac:	66 a3 fe 02 23 f0    	mov    %ax,0xf02302fe

    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f01043b2:	b8 9a 4b 10 f0       	mov    $0xf0104b9a,%eax
f01043b7:	66 a3 e0 03 23 f0    	mov    %ax,0xf02303e0
f01043bd:	66 c7 05 e2 03 23 f0 	movw   $0x8,0xf02303e2
f01043c4:	08 00 
f01043c6:	c6 05 e4 03 23 f0 00 	movb   $0x0,0xf02303e4
f01043cd:	c6 05 e5 03 23 f0 ee 	movb   $0xee,0xf02303e5
f01043d4:	c1 e8 10             	shr    $0x10,%eax
f01043d7:	66 a3 e6 03 23 f0    	mov    %ax,0xf02303e6

    //lab4
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 	0, GD_KT, handlerIRQ0, 0);
f01043dd:	b8 a4 4b 10 f0       	mov    $0xf0104ba4,%eax
f01043e2:	66 a3 60 03 23 f0    	mov    %ax,0xf0230360
f01043e8:	66 c7 05 62 03 23 f0 	movw   $0x8,0xf0230362
f01043ef:	08 00 
f01043f1:	c6 05 64 03 23 f0 00 	movb   $0x0,0xf0230364
f01043f8:	c6 05 65 03 23 f0 8e 	movb   $0x8e,0xf0230365
f01043ff:	c1 e8 10             	shr    $0x10,%eax
f0104402:	66 a3 66 03 23 f0    	mov    %ax,0xf0230366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 	0, GD_KT, handlerIRQ1, 0);
f0104408:	b8 ae 4b 10 f0       	mov    $0xf0104bae,%eax
f010440d:	66 a3 68 03 23 f0    	mov    %ax,0xf0230368
f0104413:	66 c7 05 6a 03 23 f0 	movw   $0x8,0xf023036a
f010441a:	08 00 
f010441c:	c6 05 6c 03 23 f0 00 	movb   $0x0,0xf023036c
f0104423:	c6 05 6d 03 23 f0 8e 	movb   $0x8e,0xf023036d
f010442a:	c1 e8 10             	shr    $0x10,%eax
f010442d:	66 a3 6e 03 23 f0    	mov    %ax,0xf023036e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, handlerIRQ4, 0);
f0104433:	b8 b8 4b 10 f0       	mov    $0xf0104bb8,%eax
f0104438:	66 a3 80 03 23 f0    	mov    %ax,0xf0230380
f010443e:	66 c7 05 82 03 23 f0 	movw   $0x8,0xf0230382
f0104445:	08 00 
f0104447:	c6 05 84 03 23 f0 00 	movb   $0x0,0xf0230384
f010444e:	c6 05 85 03 23 f0 8e 	movb   $0x8e,0xf0230385
f0104455:	c1 e8 10             	shr    $0x10,%eax
f0104458:	66 a3 86 03 23 f0    	mov    %ax,0xf0230386
    SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, handlerIRQ7, 0);
f010445e:	b8 c2 4b 10 f0       	mov    $0xf0104bc2,%eax
f0104463:	66 a3 98 03 23 f0    	mov    %ax,0xf0230398
f0104469:	66 c7 05 9a 03 23 f0 	movw   $0x8,0xf023039a
f0104470:	08 00 
f0104472:	c6 05 9c 03 23 f0 00 	movb   $0x0,0xf023039c
f0104479:	c6 05 9d 03 23 f0 8e 	movb   $0x8e,0xf023039d
f0104480:	c1 e8 10             	shr    $0x10,%eax
f0104483:	66 a3 9e 03 23 f0    	mov    %ax,0xf023039e
    SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 	0, GD_KT, handlerIRQ14, 0);
f0104489:	b8 cc 4b 10 f0       	mov    $0xf0104bcc,%eax
f010448e:	66 a3 d0 03 23 f0    	mov    %ax,0xf02303d0
f0104494:	66 c7 05 d2 03 23 f0 	movw   $0x8,0xf02303d2
f010449b:	08 00 
f010449d:	c6 05 d4 03 23 f0 00 	movb   $0x0,0xf02303d4
f01044a4:	c6 05 d5 03 23 f0 8e 	movb   $0x8e,0xf02303d5
f01044ab:	c1 e8 10             	shr    $0x10,%eax
f01044ae:	66 a3 d6 03 23 f0    	mov    %ax,0xf02303d6
    SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 	0, GD_KT, handlerIRQ19, 0);
f01044b4:	b8 d6 4b 10 f0       	mov    $0xf0104bd6,%eax
f01044b9:	66 a3 f8 03 23 f0    	mov    %ax,0xf02303f8
f01044bf:	66 c7 05 fa 03 23 f0 	movw   $0x8,0xf02303fa
f01044c6:	08 00 
f01044c8:	c6 05 fc 03 23 f0 00 	movb   $0x0,0xf02303fc
f01044cf:	c6 05 fd 03 23 f0 8e 	movb   $0x8e,0xf02303fd
f01044d6:	c1 e8 10             	shr    $0x10,%eax
f01044d9:	66 a3 fe 03 23 f0    	mov    %ax,0xf02303fe




	// Per-CPU setup 
	trap_init_percpu();
f01044df:	e8 9c fa ff ff       	call   f0103f80 <trap_init_percpu>
}
f01044e4:	c9                   	leave  
f01044e5:	c3                   	ret    

f01044e6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044e6:	55                   	push   %ebp
f01044e7:	89 e5                	mov    %esp,%ebp
f01044e9:	53                   	push   %ebx
f01044ea:	83 ec 14             	sub    $0x14,%esp
f01044ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044f0:	8b 03                	mov    (%ebx),%eax
f01044f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f6:	c7 04 24 b1 7f 10 f0 	movl   $0xf0107fb1,(%esp)
f01044fd:	e8 63 fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104502:	8b 43 04             	mov    0x4(%ebx),%eax
f0104505:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104509:	c7 04 24 c0 7f 10 f0 	movl   $0xf0107fc0,(%esp)
f0104510:	e8 50 fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104515:	8b 43 08             	mov    0x8(%ebx),%eax
f0104518:	89 44 24 04          	mov    %eax,0x4(%esp)
f010451c:	c7 04 24 cf 7f 10 f0 	movl   $0xf0107fcf,(%esp)
f0104523:	e8 3d fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104528:	8b 43 0c             	mov    0xc(%ebx),%eax
f010452b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452f:	c7 04 24 de 7f 10 f0 	movl   $0xf0107fde,(%esp)
f0104536:	e8 2a fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010453b:	8b 43 10             	mov    0x10(%ebx),%eax
f010453e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104542:	c7 04 24 ed 7f 10 f0 	movl   $0xf0107fed,(%esp)
f0104549:	e8 17 fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010454e:	8b 43 14             	mov    0x14(%ebx),%eax
f0104551:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104555:	c7 04 24 fc 7f 10 f0 	movl   $0xf0107ffc,(%esp)
f010455c:	e8 04 fa ff ff       	call   f0103f65 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104561:	8b 43 18             	mov    0x18(%ebx),%eax
f0104564:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104568:	c7 04 24 0b 80 10 f0 	movl   $0xf010800b,(%esp)
f010456f:	e8 f1 f9 ff ff       	call   f0103f65 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104574:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104577:	89 44 24 04          	mov    %eax,0x4(%esp)
f010457b:	c7 04 24 1a 80 10 f0 	movl   $0xf010801a,(%esp)
f0104582:	e8 de f9 ff ff       	call   f0103f65 <cprintf>
}
f0104587:	83 c4 14             	add    $0x14,%esp
f010458a:	5b                   	pop    %ebx
f010458b:	5d                   	pop    %ebp
f010458c:	c3                   	ret    

f010458d <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f010458d:	55                   	push   %ebp
f010458e:	89 e5                	mov    %esp,%ebp
f0104590:	56                   	push   %esi
f0104591:	53                   	push   %ebx
f0104592:	83 ec 10             	sub    $0x10,%esp
f0104595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104598:	e8 fc 20 00 00       	call   f0106699 <cpunum>
f010459d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045a5:	c7 04 24 7e 80 10 f0 	movl   $0xf010807e,(%esp)
f01045ac:	e8 b4 f9 ff ff       	call   f0103f65 <cprintf>
	print_regs(&tf->tf_regs);
f01045b1:	89 1c 24             	mov    %ebx,(%esp)
f01045b4:	e8 2d ff ff ff       	call   f01044e6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045b9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c1:	c7 04 24 9c 80 10 f0 	movl   $0xf010809c,(%esp)
f01045c8:	e8 98 f9 ff ff       	call   f0103f65 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045cd:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d5:	c7 04 24 af 80 10 f0 	movl   $0xf01080af,(%esp)
f01045dc:	e8 84 f9 ff ff       	call   f0103f65 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045e1:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045e4:	83 f8 13             	cmp    $0x13,%eax
f01045e7:	77 09                	ja     f01045f2 <print_trapframe+0x65>
		return excnames[trapno];
f01045e9:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f01045f0:	eb 1f                	jmp    f0104611 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045f2:	83 f8 30             	cmp    $0x30,%eax
f01045f5:	74 15                	je     f010460c <print_trapframe+0x7f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045f7:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01045fa:	83 fa 0f             	cmp    $0xf,%edx
f01045fd:	ba 35 80 10 f0       	mov    $0xf0108035,%edx
f0104602:	b9 48 80 10 f0       	mov    $0xf0108048,%ecx
f0104607:	0f 47 d1             	cmova  %ecx,%edx
f010460a:	eb 05                	jmp    f0104611 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010460c:	ba 29 80 10 f0       	mov    $0xf0108029,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104611:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104615:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104619:	c7 04 24 c2 80 10 f0 	movl   $0xf01080c2,(%esp)
f0104620:	e8 40 f9 ff ff       	call   f0103f65 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104625:	3b 1d 60 0a 23 f0    	cmp    0xf0230a60,%ebx
f010462b:	75 19                	jne    f0104646 <print_trapframe+0xb9>
f010462d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104631:	75 13                	jne    f0104646 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104633:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104636:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463a:	c7 04 24 d4 80 10 f0 	movl   $0xf01080d4,(%esp)
f0104641:	e8 1f f9 ff ff       	call   f0103f65 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104646:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104649:	89 44 24 04          	mov    %eax,0x4(%esp)
f010464d:	c7 04 24 e3 80 10 f0 	movl   $0xf01080e3,(%esp)
f0104654:	e8 0c f9 ff ff       	call   f0103f65 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104659:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010465d:	75 51                	jne    f01046b0 <print_trapframe+0x123>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010465f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104662:	89 c2                	mov    %eax,%edx
f0104664:	83 e2 01             	and    $0x1,%edx
f0104667:	ba 57 80 10 f0       	mov    $0xf0108057,%edx
f010466c:	b9 62 80 10 f0       	mov    $0xf0108062,%ecx
f0104671:	0f 45 ca             	cmovne %edx,%ecx
f0104674:	89 c2                	mov    %eax,%edx
f0104676:	83 e2 02             	and    $0x2,%edx
f0104679:	ba 6e 80 10 f0       	mov    $0xf010806e,%edx
f010467e:	be 74 80 10 f0       	mov    $0xf0108074,%esi
f0104683:	0f 44 d6             	cmove  %esi,%edx
f0104686:	83 e0 04             	and    $0x4,%eax
f0104689:	b8 79 80 10 f0       	mov    $0xf0108079,%eax
f010468e:	be ae 81 10 f0       	mov    $0xf01081ae,%esi
f0104693:	0f 44 c6             	cmove  %esi,%eax
f0104696:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010469a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010469e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a2:	c7 04 24 f1 80 10 f0 	movl   $0xf01080f1,(%esp)
f01046a9:	e8 b7 f8 ff ff       	call   f0103f65 <cprintf>
f01046ae:	eb 0c                	jmp    f01046bc <print_trapframe+0x12f>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01046b0:	c7 04 24 b0 7e 10 f0 	movl   $0xf0107eb0,(%esp)
f01046b7:	e8 a9 f8 ff ff       	call   f0103f65 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046bc:	8b 43 30             	mov    0x30(%ebx),%eax
f01046bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c3:	c7 04 24 00 81 10 f0 	movl   $0xf0108100,(%esp)
f01046ca:	e8 96 f8 ff ff       	call   f0103f65 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046cf:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d7:	c7 04 24 0f 81 10 f0 	movl   $0xf010810f,(%esp)
f01046de:	e8 82 f8 ff ff       	call   f0103f65 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046e3:	8b 43 38             	mov    0x38(%ebx),%eax
f01046e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ea:	c7 04 24 22 81 10 f0 	movl   $0xf0108122,(%esp)
f01046f1:	e8 6f f8 ff ff       	call   f0103f65 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046f6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046fa:	74 27                	je     f0104723 <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046fc:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104703:	c7 04 24 31 81 10 f0 	movl   $0xf0108131,(%esp)
f010470a:	e8 56 f8 ff ff       	call   f0103f65 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010470f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104713:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104717:	c7 04 24 40 81 10 f0 	movl   $0xf0108140,(%esp)
f010471e:	e8 42 f8 ff ff       	call   f0103f65 <cprintf>
	}
}
f0104723:	83 c4 10             	add    $0x10,%esp
f0104726:	5b                   	pop    %ebx
f0104727:	5e                   	pop    %esi
f0104728:	5d                   	pop    %ebp
f0104729:	c3                   	ret    

f010472a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010472a:	55                   	push   %ebp
f010472b:	89 e5                	mov    %esp,%ebp
f010472d:	57                   	push   %edi
f010472e:	56                   	push   %esi
f010472f:	53                   	push   %ebx
f0104730:	83 ec 5c             	sub    $0x5c,%esp
f0104733:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104736:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0104739:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010473e:	75 1c                	jne    f010475c <page_fault_handler+0x32>
		panic("page fault happens in the kern mode");
f0104740:	c7 44 24 08 f8 82 10 	movl   $0xf01082f8,0x8(%esp)
f0104747:	f0 
f0104748:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f010474f:	00 
f0104750:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f0104757:	e8 e4 b8 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
f010475c:	e8 38 1f 00 00       	call   f0106699 <cpunum>
f0104761:	6b c0 74             	imul   $0x74,%eax,%eax
f0104764:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010476a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010476e:	75 4a                	jne    f01047ba <page_fault_handler+0x90>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104770:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104773:	e8 21 1f 00 00       	call   f0106699 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104778:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010477c:	89 7c 24 08          	mov    %edi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104780:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(!curenv->env_pgfault_upcall){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104783:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104789:	8b 40 48             	mov    0x48(%eax),%eax
f010478c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104790:	c7 04 24 1c 83 10 f0 	movl   $0xf010831c,(%esp)
f0104797:	e8 c9 f7 ff ff       	call   f0103f65 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f010479c:	89 1c 24             	mov    %ebx,(%esp)
f010479f:	e8 e9 fd ff ff       	call   f010458d <print_trapframe>
		env_destroy(curenv);
f01047a4:	e8 f0 1e 00 00       	call   f0106699 <cpunum>
f01047a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ac:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01047b2:	89 04 24             	mov    %eax,(%esp)
f01047b5:	e8 b4 f4 ff ff       	call   f0103c6e <env_destroy>

	unsigned int newEsp=0;
	struct UTrapframe UT;
	
	//the Exception has not been built
	if( tf->tf_esp < UXSTACKTOP-PGSIZE || tf->tf_esp >= UXSTACKTOP) {
f01047ba:	8b 73 3c             	mov    0x3c(%ebx),%esi
f01047bd:	8d 86 00 10 40 11    	lea    0x11401000(%esi),%eax
		
		newEsp = UXSTACKTOP - sizeof(struct UTrapframe);
	}
	else
		//note: it is not like the requirement!!! there is two block
		newEsp = tf->tf_esp - sizeof(struct UTrapframe) -8;
f01047c3:	83 ee 3c             	sub    $0x3c,%esi
f01047c6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01047cb:	b8 cc ff bf ee       	mov    $0xeebfffcc,%eax
f01047d0:	0f 47 f0             	cmova  %eax,%esi
	
	user_mem_assert(curenv, (void*)newEsp, 0, PTE_U|PTE_W|PTE_P);
f01047d3:	e8 c1 1e 00 00       	call   f0106699 <cpunum>
f01047d8:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01047df:	00 
f01047e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01047e7:	00 
f01047e8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ef:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01047f5:	89 04 24             	mov    %eax,(%esp)
f01047f8:	e8 1a ed ff ff       	call   f0103517 <user_mem_assert>

	UT.utf_err = tf->tf_err;
f01047fd:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104800:	89 45 b8             	mov    %eax,-0x48(%ebp)
	UT.utf_regs = tf->tf_regs;
f0104803:	8b 03                	mov    (%ebx),%eax
f0104805:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0104808:	8b 43 04             	mov    0x4(%ebx),%eax
f010480b:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010480e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104811:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104814:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104817:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010481a:	8b 43 10             	mov    0x10(%ebx),%eax
f010481d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104820:	8b 43 14             	mov    0x14(%ebx),%eax
f0104823:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104826:	8b 43 18             	mov    0x18(%ebx),%eax
f0104829:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010482c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010482f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	UT.utf_eflags = tf->tf_eflags;
f0104832:	8b 43 38             	mov    0x38(%ebx),%eax
f0104835:	89 45 e0             	mov    %eax,-0x20(%ebp)
	UT.utf_eip = tf->tf_eip;
f0104838:	8b 43 30             	mov    0x30(%ebx),%eax
f010483b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	UT.utf_esp = tf->tf_esp;
f010483e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	UT.utf_fault_va = fault_va;
f0104844:	89 7d b4             	mov    %edi,-0x4c(%ebp)

	user_mem_assert(curenv,(void*)newEsp, sizeof(struct UTrapframe),PTE_U|PTE_P|PTE_W );
f0104847:	e8 4d 1e 00 00       	call   f0106699 <cpunum>
f010484c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104853:	00 
f0104854:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010485b:	00 
f010485c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104860:	6b c0 74             	imul   $0x74,%eax,%eax
f0104863:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104869:	89 04 24             	mov    %eax,(%esp)
f010486c:	e8 a6 ec ff ff       	call   f0103517 <user_mem_assert>
	memcpy((void*)newEsp, (&UT) ,sizeof(struct UTrapframe));
f0104871:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104878:	00 
f0104879:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f010487c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104880:	89 34 24             	mov    %esi,(%esp)
f0104883:	e8 74 18 00 00       	call   f01060fc <memcpy>
	tf->tf_esp = newEsp;
f0104888:	89 73 3c             	mov    %esi,0x3c(%ebx)
	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010488b:	e8 09 1e 00 00       	call   f0106699 <cpunum>
f0104890:	6b c0 74             	imul   $0x74,%eax,%eax
f0104893:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104899:	8b 40 64             	mov    0x64(%eax),%eax
f010489c:	89 43 30             	mov    %eax,0x30(%ebx)
	env_run(curenv);
f010489f:	e8 f5 1d 00 00       	call   f0106699 <cpunum>
f01048a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a7:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01048ad:	89 04 24             	mov    %eax,(%esp)
f01048b0:	e8 5a f4 ff ff       	call   f0103d0f <env_run>

f01048b5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048b5:	55                   	push   %ebp
f01048b6:	89 e5                	mov    %esp,%ebp
f01048b8:	57                   	push   %edi
f01048b9:	56                   	push   %esi
f01048ba:	83 ec 20             	sub    $0x20,%esp
f01048bd:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01048c0:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01048c1:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f01048c8:	74 01                	je     f01048cb <trap+0x16>
		asm volatile("hlt");
f01048ca:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048cb:	e8 c9 1d 00 00       	call   f0106699 <cpunum>
f01048d0:	6b d0 74             	imul   $0x74,%eax,%edx
f01048d3:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01048de:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01048e2:	83 f8 02             	cmp    $0x2,%eax
f01048e5:	75 0c                	jne    f01048f3 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01048e7:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01048ee:	e8 24 20 00 00       	call   f0106917 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01048f3:	9c                   	pushf  
f01048f4:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01048f5:	f6 c4 02             	test   $0x2,%ah
f01048f8:	74 24                	je     f010491e <trap+0x69>
f01048fa:	c7 44 24 0c 5f 81 10 	movl   $0xf010815f,0xc(%esp)
f0104901:	f0 
f0104902:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f0104909:	f0 
f010490a:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f0104911:	00 
f0104912:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f0104919:	e8 22 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010491e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104922:	83 e0 03             	and    $0x3,%eax
f0104925:	66 83 f8 03          	cmp    $0x3,%ax
f0104929:	0f 85 a7 00 00 00    	jne    f01049d6 <trap+0x121>
f010492f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104936:	e8 dc 1f 00 00       	call   f0106917 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010493b:	e8 59 1d 00 00       	call   f0106699 <cpunum>
f0104940:	6b c0 74             	imul   $0x74,%eax,%eax
f0104943:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010494a:	75 24                	jne    f0104970 <trap+0xbb>
f010494c:	c7 44 24 0c 78 81 10 	movl   $0xf0108178,0xc(%esp)
f0104953:	f0 
f0104954:	c7 44 24 08 df 7b 10 	movl   $0xf0107bdf,0x8(%esp)
f010495b:	f0 
f010495c:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0104963:	00 
f0104964:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f010496b:	e8 d0 b6 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104970:	e8 24 1d 00 00       	call   f0106699 <cpunum>
f0104975:	6b c0 74             	imul   $0x74,%eax,%eax
f0104978:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010497e:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104982:	75 2d                	jne    f01049b1 <trap+0xfc>
			env_free(curenv);
f0104984:	e8 10 1d 00 00       	call   f0106699 <cpunum>
f0104989:	6b c0 74             	imul   $0x74,%eax,%eax
f010498c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104992:	89 04 24             	mov    %eax,(%esp)
f0104995:	e8 cf f0 ff ff       	call   f0103a69 <env_free>
			curenv = NULL;
f010499a:	e8 fa 1c 00 00       	call   f0106699 <cpunum>
f010499f:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a2:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f01049a9:	00 00 00 
			sched_yield();
f01049ac:	e8 16 03 00 00       	call   f0104cc7 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049b1:	e8 e3 1c 00 00       	call   f0106699 <cpunum>
f01049b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b9:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01049bf:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049c4:	89 c7                	mov    %eax,%edi
f01049c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01049c8:	e8 cc 1c 00 00       	call   f0106699 <cpunum>
f01049cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d0:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01049d6:	89 35 60 0a 23 f0    	mov    %esi,0xf0230a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f01049dc:	8b 46 28             	mov    0x28(%esi),%eax
f01049df:	83 f8 0e             	cmp    $0xe,%eax
f01049e2:	75 08                	jne    f01049ec <trap+0x137>
		page_fault_handler(tf);
f01049e4:	89 34 24             	mov    %esi,(%esp)
f01049e7:	e8 3e fd ff ff       	call   f010472a <page_fault_handler>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f01049ec:	83 f8 03             	cmp    $0x3,%eax
f01049ef:	75 0d                	jne    f01049fe <trap+0x149>
		monitor(tf);
f01049f1:	89 34 24             	mov    %esi,(%esp)
f01049f4:	e8 e0 be ff ff       	call   f01008d9 <monitor>
f01049f9:	e9 a2 00 00 00       	jmp    f0104aa0 <trap+0x1eb>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f01049fe:	83 f8 30             	cmp    $0x30,%eax
f0104a01:	75 32                	jne    f0104a35 <trap+0x180>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0104a03:	8b 46 04             	mov    0x4(%esi),%eax
f0104a06:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a0a:	8b 06                	mov    (%esi),%eax
f0104a0c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a10:	8b 46 10             	mov    0x10(%esi),%eax
f0104a13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a17:	8b 46 18             	mov    0x18(%esi),%eax
f0104a1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a1e:	8b 46 14             	mov    0x14(%esi),%eax
f0104a21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a25:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a28:	89 04 24             	mov    %eax,(%esp)
f0104a2b:	e8 60 03 00 00       	call   f0104d90 <syscall>
f0104a30:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a33:	eb 6b                	jmp    f0104aa0 <trap+0x1eb>
                            return;	
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a35:	83 f8 27             	cmp    $0x27,%eax
f0104a38:	75 16                	jne    f0104a50 <trap+0x19b>
		cprintf("Spurious interrupt on irq 7\n");
f0104a3a:	c7 04 24 7f 81 10 f0 	movl   $0xf010817f,(%esp)
f0104a41:	e8 1f f5 ff ff       	call   f0103f65 <cprintf>
		print_trapframe(tf);
f0104a46:	89 34 24             	mov    %esi,(%esp)
f0104a49:	e8 3f fb ff ff       	call   f010458d <print_trapframe>
f0104a4e:	eb 50                	jmp    f0104aa0 <trap+0x1eb>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_TIMER + IRQ_OFFSET){
f0104a50:	83 f8 20             	cmp    $0x20,%eax
f0104a53:	75 0a                	jne    f0104a5f <trap+0x1aa>
		//cprintf("The Irq_Time is also work\n");
		lapic_eoi();
f0104a55:	e8 8c 1d 00 00       	call   f01067e6 <lapic_eoi>
		sched_yield();
f0104a5a:	e8 68 02 00 00       	call   f0104cc7 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a5f:	89 34 24             	mov    %esi,(%esp)
f0104a62:	e8 26 fb ff ff       	call   f010458d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a67:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a6c:	75 1c                	jne    f0104a8a <trap+0x1d5>
		panic("unhandled trap in kernel");
f0104a6e:	c7 44 24 08 9c 81 10 	movl   $0xf010819c,0x8(%esp)
f0104a75:	f0 
f0104a76:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0104a7d:	00 
f0104a7e:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f0104a85:	e8 b6 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104a8a:	e8 0a 1c 00 00       	call   f0106699 <cpunum>
f0104a8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a92:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104a98:	89 04 24             	mov    %eax,(%esp)
f0104a9b:	e8 ce f1 ff ff       	call   f0103c6e <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104aa0:	e8 f4 1b 00 00       	call   f0106699 <cpunum>
f0104aa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa8:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0104aaf:	74 2a                	je     f0104adb <trap+0x226>
f0104ab1:	e8 e3 1b 00 00       	call   f0106699 <cpunum>
f0104ab6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab9:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104abf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ac3:	75 16                	jne    f0104adb <trap+0x226>
		env_run(curenv);
f0104ac5:	e8 cf 1b 00 00       	call   f0106699 <cpunum>
f0104aca:	6b c0 74             	imul   $0x74,%eax,%eax
f0104acd:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ad3:	89 04 24             	mov    %eax,(%esp)
f0104ad6:	e8 34 f2 ff ff       	call   f0103d0f <env_run>
	else
		sched_yield();
f0104adb:	e8 e7 01 00 00       	call   f0104cc7 <sched_yield>

f0104ae0 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104ae0:	6a 00                	push   $0x0
f0104ae2:	6a 00                	push   $0x0
f0104ae4:	e9 f6 00 00 00       	jmp    f0104bdf <_alltraps>
f0104ae9:	90                   	nop

f0104aea <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104aea:	6a 00                	push   $0x0
f0104aec:	6a 01                	push   $0x1
f0104aee:	e9 ec 00 00 00       	jmp    f0104bdf <_alltraps>
f0104af3:	90                   	nop

f0104af4 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f0104af4:	6a 00                	push   $0x0
f0104af6:	6a 02                	push   $0x2
f0104af8:	e9 e2 00 00 00       	jmp    f0104bdf <_alltraps>
f0104afd:	90                   	nop

f0104afe <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104afe:	6a 00                	push   $0x0
f0104b00:	6a 03                	push   $0x3
f0104b02:	e9 d8 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b07:	90                   	nop

f0104b08 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104b08:	6a 00                	push   $0x0
f0104b0a:	6a 04                	push   $0x4
f0104b0c:	e9 ce 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b11:	90                   	nop

f0104b12 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f0104b12:	6a 00                	push   $0x0
f0104b14:	6a 05                	push   $0x5
f0104b16:	e9 c4 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b1b:	90                   	nop

f0104b1c <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104b1c:	6a 00                	push   $0x0
f0104b1e:	6a 06                	push   $0x6
f0104b20:	e9 ba 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b25:	90                   	nop

f0104b26 <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f0104b26:	6a 00                	push   $0x0
f0104b28:	6a 07                	push   $0x7
f0104b2a:	e9 b0 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b2f:	90                   	nop

f0104b30 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104b30:	6a 08                	push   $0x8
f0104b32:	e9 a8 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b37:	90                   	nop

f0104b38 <handler9>:
TRAPHANDLER_NOEC(handler9, T_COPROC) /* reserved */
f0104b38:	6a 00                	push   $0x0
f0104b3a:	6a 09                	push   $0x9
f0104b3c:	e9 9e 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b41:	90                   	nop

f0104b42 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104b42:	6a 0a                	push   $0xa
f0104b44:	e9 96 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b49:	90                   	nop

f0104b4a <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104b4a:	6a 0b                	push   $0xb
f0104b4c:	e9 8e 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b51:	90                   	nop

f0104b52 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f0104b52:	6a 0c                	push   $0xc
f0104b54:	e9 86 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b59:	90                   	nop

f0104b5a <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104b5a:	6a 0d                	push   $0xd
f0104b5c:	e9 7e 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b61:	90                   	nop

f0104b62 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104b62:	6a 0e                	push   $0xe
f0104b64:	e9 76 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b69:	90                   	nop

f0104b6a <handler15>:
TRAPHANDLER_NOEC(handler15, T_RES)  /* reserved */
f0104b6a:	6a 00                	push   $0x0
f0104b6c:	6a 0f                	push   $0xf
f0104b6e:	e9 6c 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b73:	90                   	nop

f0104b74 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104b74:	6a 00                	push   $0x0
f0104b76:	6a 10                	push   $0x10
f0104b78:	e9 62 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b7d:	90                   	nop

f0104b7e <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104b7e:	6a 11                	push   $0x11
f0104b80:	e9 5a 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b85:	90                   	nop

f0104b86 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104b86:	6a 00                	push   $0x0
f0104b88:	6a 12                	push   $0x12
f0104b8a:	e9 50 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b8f:	90                   	nop

f0104b90 <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f0104b90:	6a 00                	push   $0x0
f0104b92:	6a 13                	push   $0x13
f0104b94:	e9 46 00 00 00       	jmp    f0104bdf <_alltraps>
f0104b99:	90                   	nop

f0104b9a <handler_syscall>:

TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0104b9a:	6a 00                	push   $0x0
f0104b9c:	6a 30                	push   $0x30
f0104b9e:	e9 3c 00 00 00       	jmp    f0104bdf <_alltraps>
f0104ba3:	90                   	nop

f0104ba4 <handlerIRQ0>:

/*
* lab4
*/
	
TRAPHANDLER_NOEC(handlerIRQ0, IRQ_OFFSET+IRQ_TIMER)
f0104ba4:	6a 00                	push   $0x0
f0104ba6:	6a 20                	push   $0x20
f0104ba8:	e9 32 00 00 00       	jmp    f0104bdf <_alltraps>
f0104bad:	90                   	nop

f0104bae <handlerIRQ1>:
TRAPHANDLER_NOEC(handlerIRQ1, IRQ_OFFSET+IRQ_KBD)
f0104bae:	6a 00                	push   $0x0
f0104bb0:	6a 21                	push   $0x21
f0104bb2:	e9 28 00 00 00       	jmp    f0104bdf <_alltraps>
f0104bb7:	90                   	nop

f0104bb8 <handlerIRQ4>:
TRAPHANDLER_NOEC(handlerIRQ4, IRQ_OFFSET+IRQ_SERIAL)
f0104bb8:	6a 00                	push   $0x0
f0104bba:	6a 24                	push   $0x24
f0104bbc:	e9 1e 00 00 00       	jmp    f0104bdf <_alltraps>
f0104bc1:	90                   	nop

f0104bc2 <handlerIRQ7>:
TRAPHANDLER_NOEC(handlerIRQ7, IRQ_OFFSET+IRQ_SPURIOUS)
f0104bc2:	6a 00                	push   $0x0
f0104bc4:	6a 27                	push   $0x27
f0104bc6:	e9 14 00 00 00       	jmp    f0104bdf <_alltraps>
f0104bcb:	90                   	nop

f0104bcc <handlerIRQ14>:
TRAPHANDLER_NOEC(handlerIRQ14, IRQ_OFFSET+IRQ_IDE)
f0104bcc:	6a 00                	push   $0x0
f0104bce:	6a 2e                	push   $0x2e
f0104bd0:	e9 0a 00 00 00       	jmp    f0104bdf <_alltraps>
f0104bd5:	90                   	nop

f0104bd6 <handlerIRQ19>:
TRAPHANDLER_NOEC(handlerIRQ19, IRQ_OFFSET+IRQ_ERROR)
f0104bd6:	6a 00                	push   $0x0
f0104bd8:	6a 33                	push   $0x33
f0104bda:	e9 00 00 00 00       	jmp    f0104bdf <_alltraps>

f0104bdf <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0104bdf:	1e                   	push   %ds
	pushl %es
f0104be0:	06                   	push   %es
	pushal
f0104be1:	60                   	pusha  
	movl $GD_KD, %eax
f0104be2:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104be7:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104be9:	8e c0                	mov    %eax,%es

	pushl %esp
f0104beb:	54                   	push   %esp
	call trap
f0104bec:	e8 c4 fc ff ff       	call   f01048b5 <trap>

f0104bf1 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104bf1:	55                   	push   %ebp
f0104bf2:	89 e5                	mov    %esp,%ebp
f0104bf4:	83 ec 18             	sub    $0x18,%esp
f0104bf7:	8b 15 48 02 23 f0    	mov    0xf0230248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c02:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104c05:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c08:	83 f9 02             	cmp    $0x2,%ecx
f0104c0b:	76 0f                	jbe    f0104c1c <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c0d:	83 c0 01             	add    $0x1,%eax
f0104c10:	83 c2 7c             	add    $0x7c,%edx
f0104c13:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c18:	75 e8                	jne    f0104c02 <sched_halt+0x11>
f0104c1a:	eb 07                	jmp    f0104c23 <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c1c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c21:	75 1a                	jne    f0104c3d <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104c23:	c7 04 24 90 83 10 f0 	movl   $0xf0108390,(%esp)
f0104c2a:	e8 36 f3 ff ff       	call   f0103f65 <cprintf>
		while (1)
			monitor(NULL);
f0104c2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c36:	e8 9e bc ff ff       	call   f01008d9 <monitor>
f0104c3b:	eb f2                	jmp    f0104c2f <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c3d:	e8 57 1a 00 00       	call   f0106699 <cpunum>
f0104c42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c45:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0104c4c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c4f:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c54:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c59:	77 20                	ja     f0104c7b <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c5f:	c7 44 24 08 c8 6d 10 	movl   $0xf0106dc8,0x8(%esp)
f0104c66:	f0 
f0104c67:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f0104c6e:	00 
f0104c6f:	c7 04 24 b9 83 10 f0 	movl   $0xf01083b9,(%esp)
f0104c76:	e8 c5 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c7b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c80:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c83:	e8 11 1a 00 00       	call   f0106699 <cpunum>
f0104c88:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c8b:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c91:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c96:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104c9a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104ca1:	e8 1d 1d 00 00       	call   f01069c3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104ca6:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104ca8:	e8 ec 19 00 00       	call   f0106699 <cpunum>
f0104cad:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104cb0:	8b 80 30 10 23 f0    	mov    -0xfdcefd0(%eax),%eax
f0104cb6:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104cbb:	89 c4                	mov    %eax,%esp
f0104cbd:	6a 00                	push   $0x0
f0104cbf:	6a 00                	push   $0x0
f0104cc1:	fb                   	sti    
f0104cc2:	f4                   	hlt    
f0104cc3:	eb fd                	jmp    f0104cc2 <sched_halt+0xd1>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104cc5:	c9                   	leave  
f0104cc6:	c3                   	ret    

f0104cc7 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104cc7:	55                   	push   %ebp
f0104cc8:	89 e5                	mov    %esp,%ebp
f0104cca:	57                   	push   %edi
f0104ccb:	56                   	push   %esi
f0104ccc:	53                   	push   %ebx
f0104ccd:	83 ec 1c             	sub    $0x1c,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
f0104cd0:	e8 c4 19 00 00       	call   f0106699 <cpunum>
f0104cd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd8:	8b 98 28 10 23 f0    	mov    -0xfdcefd8(%eax),%ebx
	int EnvID = 0;
	int startID = 0;
	int i=0;
	bool firstEnv = true;
	if(e != NULL){
f0104cde:	85 db                	test   %ebx,%ebx
f0104ce0:	74 45                	je     f0104d27 <sched_yield+0x60>
		
		EnvID =  e-envs;
f0104ce2:	89 de                	mov    %ebx,%esi
f0104ce4:	2b 35 48 02 23 f0    	sub    0xf0230248,%esi
f0104cea:	c1 fe 02             	sar    $0x2,%esi
f0104ced:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
f0104cf3:	89 f1                	mov    %esi,%ecx
		// maybe the env status is ENV_NOTRUNNABLE  so next if is important
		if(e->env_status ==ENV_RUNNING )
f0104cf5:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104cf9:	75 07                	jne    f0104d02 <sched_yield+0x3b>
		e->env_status = ENV_RUNNABLE;
f0104cfb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
		startID = (EnvID+1) % (NENV-1);
f0104d02:	83 c6 01             	add    $0x1,%esi
f0104d05:	ba 03 08 20 80       	mov    $0x80200803,%edx
f0104d0a:	89 f0                	mov    %esi,%eax
f0104d0c:	f7 ea                	imul   %edx
f0104d0e:	01 f2                	add    %esi,%edx
f0104d10:	c1 fa 09             	sar    $0x9,%edx
f0104d13:	89 f0                	mov    %esi,%eax
f0104d15:	c1 f8 1f             	sar    $0x1f,%eax
f0104d18:	29 c2                	sub    %eax,%edx
f0104d1a:	89 d0                	mov    %edx,%eax
f0104d1c:	c1 e0 0a             	shl    $0xa,%eax
f0104d1f:	29 d0                	sub    %edx,%eax
f0104d21:	89 f2                	mov    %esi,%edx
f0104d23:	29 c2                	sub    %eax,%edx
f0104d25:	eb 0a                	jmp    f0104d31 <sched_yield+0x6a>
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
	int startID = 0;
f0104d27:	ba 00 00 00 00       	mov    $0x0,%edx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e = thiscpu->cpu_env;
	int EnvID = 0;
f0104d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
		if(envs[i].env_status == ENV_RUNNABLE){
f0104d31:	8b 3d 48 02 23 f0    	mov    0xf0230248,%edi
f0104d37:	6b c2 7c             	imul   $0x7c,%edx,%eax
f0104d3a:	01 f8                	add    %edi,%eax
f0104d3c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104d40:	75 08                	jne    f0104d4a <sched_yield+0x83>
			env_run(&envs[i]);
f0104d42:	89 04 24             	mov    %eax,(%esp)
f0104d45:	e8 c5 ef ff ff       	call   f0103d0f <env_run>
		e->env_status = ENV_RUNNABLE;
		startID = (EnvID+1) % (NENV-1);
	}

	//cprintf("startID = %d, EnvID = %d\n", startID, EnvID);
	for(i = startID; firstEnv || i != EnvID; i = (i+1)%(NENV) ){
f0104d4a:	83 c2 01             	add    $0x1,%edx
f0104d4d:	89 d6                	mov    %edx,%esi
f0104d4f:	c1 fe 1f             	sar    $0x1f,%esi
f0104d52:	c1 ee 16             	shr    $0x16,%esi
f0104d55:	01 f2                	add    %esi,%edx
f0104d57:	89 d0                	mov    %edx,%eax
f0104d59:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104d5e:	29 f0                	sub    %esi,%eax
f0104d60:	89 c2                	mov    %eax,%edx
f0104d62:	39 c1                	cmp    %eax,%ecx
f0104d64:	75 d1                	jne    f0104d37 <sched_yield+0x70>
			env_run(&envs[i]);
		}
		firstEnv = false;
	}

	if(e && e->env_status == ENV_RUNNING)
f0104d66:	85 db                	test   %ebx,%ebx
f0104d68:	74 0e                	je     f0104d78 <sched_yield+0xb1>
f0104d6a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104d6e:	75 08                	jne    f0104d78 <sched_yield+0xb1>
		
		env_run(e);
f0104d70:	89 1c 24             	mov    %ebx,(%esp)
f0104d73:	e8 97 ef ff ff       	call   f0103d0f <env_run>
  
	// sched_halt never returns
	sched_halt();
f0104d78:	e8 74 fe ff ff       	call   f0104bf1 <sched_halt>
    }

	// sched_halt never returns
	sched_halt();
	*/
}
f0104d7d:	83 c4 1c             	add    $0x1c,%esp
f0104d80:	5b                   	pop    %ebx
f0104d81:	5e                   	pop    %esi
f0104d82:	5f                   	pop    %edi
f0104d83:	5d                   	pop    %ebp
f0104d84:	c3                   	ret    
f0104d85:	66 90                	xchg   %ax,%ax
f0104d87:	66 90                	xchg   %ax,%ax
f0104d89:	66 90                	xchg   %ax,%ax
f0104d8b:	66 90                	xchg   %ax,%ax
f0104d8d:	66 90                	xchg   %ax,%ax
f0104d8f:	90                   	nop

f0104d90 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d90:	55                   	push   %ebp
f0104d91:	89 e5                	mov    %esp,%ebp
f0104d93:	57                   	push   %edi
f0104d94:	56                   	push   %esi
f0104d95:	53                   	push   %ebx
f0104d96:	83 ec 2c             	sub    $0x2c,%esp
f0104d99:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
	switch(syscallno){
f0104d9c:	83 f8 0c             	cmp    $0xc,%eax
f0104d9f:	0f 87 11 06 00 00    	ja     f01053b6 <syscall+0x626>
f0104da5:	ff 24 85 00 84 10 f0 	jmp    *-0xfef7c00(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104dac:	e8 e8 18 00 00       	call   f0106699 <cpunum>
f0104db1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104db8:	00 
f0104db9:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104dbc:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104dc3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104dc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dca:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104dd0:	89 04 24             	mov    %eax,(%esp)
f0104dd3:	e8 3f e7 ff ff       	call   f0103517 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ddf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104de2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de6:	c7 04 24 c6 83 10 f0 	movl   $0xf01083c6,(%esp)
f0104ded:	e8 73 f1 ff ff       	call   f0103f65 <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	int ret = 0;
f0104df2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104df7:	e9 c6 05 00 00       	jmp    f01053c2 <syscall+0x632>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104dfc:	e8 34 b8 ff ff       	call   f0100635 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104e01:	e9 bc 05 00 00       	jmp    f01053c2 <syscall+0x632>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e06:	e8 8e 18 00 00       	call   f0106699 <cpunum>
f0104e0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e0e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104e14:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f0104e17:	e9 a6 05 00 00       	jmp    f01053c2 <syscall+0x632>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e23:	00 
f0104e24:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e2e:	89 04 24             	mov    %eax,(%esp)
f0104e31:	e8 e4 e7 ff ff       	call   f010361a <envid2env>
		return r;
f0104e36:	89 c2                	mov    %eax,%edx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e38:	85 c0                	test   %eax,%eax
f0104e3a:	78 6e                	js     f0104eaa <syscall+0x11a>
		return r;
	if (e == curenv)
f0104e3c:	e8 58 18 00 00       	call   f0106699 <cpunum>
f0104e41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e47:	39 90 28 10 23 f0    	cmp    %edx,-0xfdcefd8(%eax)
f0104e4d:	75 23                	jne    f0104e72 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e4f:	e8 45 18 00 00       	call   f0106699 <cpunum>
f0104e54:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e57:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104e5d:	8b 40 48             	mov    0x48(%eax),%eax
f0104e60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e64:	c7 04 24 cb 83 10 f0 	movl   $0xf01083cb,(%esp)
f0104e6b:	e8 f5 f0 ff ff       	call   f0103f65 <cprintf>
f0104e70:	eb 28                	jmp    f0104e9a <syscall+0x10a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e72:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e75:	e8 1f 18 00 00       	call   f0106699 <cpunum>
f0104e7a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e81:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104e87:	8b 40 48             	mov    0x48(%eax),%eax
f0104e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8e:	c7 04 24 e6 83 10 f0 	movl   $0xf01083e6,(%esp)
f0104e95:	e8 cb f0 ff ff       	call   f0103f65 <cprintf>
	env_destroy(e);
f0104e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e9d:	89 04 24             	mov    %eax,(%esp)
f0104ea0:	e8 c9 ed ff ff       	call   f0103c6e <env_destroy>
	return 0;
f0104ea5:	ba 00 00 00 00       	mov    $0x0,%edx
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
f0104eaa:	89 d0                	mov    %edx,%eax
						break;
f0104eac:	e9 11 05 00 00       	jmp    f01053c2 <syscall+0x632>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104eb1:	e8 11 fe ff ff       	call   f0104cc7 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env* childEnv=0;
f0104eb6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct Env* parentEnv = curenv;
f0104ebd:	e8 d7 17 00 00       	call   f0106699 <cpunum>
f0104ec2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec5:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
	int r = env_alloc(&childEnv, parentEnv->env_id);
f0104ecb:	8b 46 48             	mov    0x48(%esi),%eax
f0104ece:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ed5:	89 04 24             	mov    %eax,(%esp)
f0104ed8:	e8 46 e8 ff ff       	call   f0103723 <env_alloc>
	if(r < 0)
f0104edd:	85 c0                	test   %eax,%eax
f0104edf:	0f 88 dd 04 00 00    	js     f01053c2 <syscall+0x632>
		return r;
	//init the childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104ee5:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104eea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f0104eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ef2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104ef9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return childEnv->env_id;
f0104f00:	8b 40 48             	mov    0x48(%eax),%eax
f0104f03:	e9 ba 04 00 00       	jmp    f01053c2 <syscall+0x632>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e =0;
f0104f08:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f0f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f16:	00 
f0104f17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f21:	89 04 24             	mov    %eax,(%esp)
f0104f24:	e8 f1 e6 ff ff       	call   f010361a <envid2env>
f0104f29:	85 c0                	test   %eax,%eax
f0104f2b:	0f 88 91 04 00 00    	js     f01053c2 <syscall+0x632>
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104f31:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104f35:	74 06                	je     f0104f3d <syscall+0x1ad>
f0104f37:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104f3b:	75 13                	jne    f0104f50 <syscall+0x1c0>
		return -E_INVAL;
	e->env_status = status;
f0104f3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f40:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f43:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104f46:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f4b:	e9 72 04 00 00       	jmp    f01053c2 <syscall+0x632>
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
						break;

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
f0104f55:	e9 68 04 00 00       	jmp    f01053c2 <syscall+0x632>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	
	struct Env *e =0;
f0104f5a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f0104f61:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f68:	00 
f0104f69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f73:	89 04 24             	mov    %eax,(%esp)
f0104f76:	e8 9f e6 ff ff       	call   f010361a <envid2env>
f0104f7b:	85 c0                	test   %eax,%eax
f0104f7d:	78 6c                	js     f0104feb <syscall+0x25b>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f0104f7f:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f86:	77 67                	ja     f0104fef <syscall+0x25f>
f0104f88:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f8f:	75 65                	jne    f0104ff6 <syscall+0x266>
		return  -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0104f91:	8b 75 14             	mov    0x14(%ebp),%esi
f0104f94:	81 e6 f8 f1 ff ff    	and    $0xfffff1f8,%esi
f0104f9a:	75 61                	jne    f0104ffd <syscall+0x26d>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f0104f9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f9f:	83 e0 05             	and    $0x5,%eax
f0104fa2:	83 f8 05             	cmp    $0x5,%eax
f0104fa5:	75 5d                	jne    f0105004 <syscall+0x274>
		return  -E_INVAL;
	struct PageInfo * page = page_alloc(1);
f0104fa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104fae:	e8 0f c0 ff ff       	call   f0100fc2 <page_alloc>
f0104fb3:	89 c3                	mov    %eax,%ebx
	if(page == 0)
f0104fb5:	85 c0                	test   %eax,%eax
f0104fb7:	74 52                	je     f010500b <syscall+0x27b>
		return -E_NO_MEM ;
	r = page_insert(e->env_pgdir, page, va,perm);
f0104fb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fc0:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fce:	8b 40 60             	mov    0x60(%eax),%eax
f0104fd1:	89 04 24             	mov    %eax,(%esp)
f0104fd4:	e8 db c2 ff ff       	call   f01012b4 <page_insert>
f0104fd9:	89 c7                	mov    %eax,%edi
	if(r <0){
f0104fdb:	85 c0                	test   %eax,%eax
f0104fdd:	79 31                	jns    f0105010 <syscall+0x280>
		page_free(page);
f0104fdf:	89 1c 24             	mov    %ebx,(%esp)
f0104fe2:	e8 66 c0 ff ff       	call   f010104d <page_free>
		return r;
f0104fe7:	89 fe                	mov    %edi,%esi
f0104fe9:	eb 25                	jmp    f0105010 <syscall+0x280>
	// LAB 4: Your code here.
	
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104feb:	89 c6                	mov    %eax,%esi
f0104fed:	eb 21                	jmp    f0105010 <syscall+0x280>
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f0104fef:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104ff4:	eb 1a                	jmp    f0105010 <syscall+0x280>
f0104ff6:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104ffb:	eb 13                	jmp    f0105010 <syscall+0x280>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f0104ffd:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105002:	eb 0c                	jmp    f0105010 <syscall+0x280>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0105004:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105009:	eb 05                	jmp    f0105010 <syscall+0x280>
	struct PageInfo * page = page_alloc(1);
	if(page == 0)
		return -E_NO_MEM ;
f010500b:	be fc ff ff ff       	mov    $0xfffffffc,%esi

		case SYS_exofork: 	ret = sys_exofork();
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
f0105010:	89 f0                	mov    %esi,%eax
						break;
f0105012:	e9 ab 03 00 00       	jmp    f01053c2 <syscall+0x632>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
f0105017:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010501e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0105025:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010502c:	00 
f010502d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105034:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105037:	89 04 24             	mov    %eax,(%esp)
f010503a:	e8 db e5 ff ff       	call   f010361a <envid2env>
		return r;
f010503f:	89 c2                	mov    %eax,%edx
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
f0105041:	85 c0                	test   %eax,%eax
f0105043:	0f 88 05 01 00 00    	js     f010514e <syscall+0x3be>
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
f0105049:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105050:	00 
f0105051:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105058:	8b 45 14             	mov    0x14(%ebp),%eax
f010505b:	89 04 24             	mov    %eax,(%esp)
f010505e:	e8 b7 e5 ff ff       	call   f010361a <envid2env>
f0105063:	85 c0                	test   %eax,%eax
f0105065:	0f 88 a9 00 00 00    	js     f0105114 <syscall+0x384>
		return r;
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
f010506b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105072:	0f 87 a0 00 00 00    	ja     f0105118 <syscall+0x388>
f0105078:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010507f:	0f 85 9a 00 00 00    	jne    f010511f <syscall+0x38f>
		return  -E_INVAL;
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
f0105085:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010508c:	0f 87 94 00 00 00    	ja     f0105126 <syscall+0x396>
f0105092:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105099:	0f 85 8e 00 00 00    	jne    f010512d <syscall+0x39d>
		return  -E_INVAL;
	pte_t * srcPTE=0;
f010509f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
f01050a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050ad:	8b 45 10             	mov    0x10(%ebp),%eax
f01050b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050b7:	8b 40 60             	mov    0x60(%eax),%eax
f01050ba:	89 04 24             	mov    %eax,(%esp)
f01050bd:	e8 ef c0 ff ff       	call   f01011b1 <page_lookup>
	if(page == 0)
f01050c2:	85 c0                	test   %eax,%eax
f01050c4:	74 6e                	je     f0105134 <syscall+0x3a4>
		return -E_INVAL;
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
f01050c6:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01050cd:	75 6c                	jne    f010513b <syscall+0x3ab>
		return  -E_INVAL;
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
f01050cf:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01050d2:	83 e2 05             	and    $0x5,%edx
f01050d5:	83 fa 05             	cmp    $0x5,%edx
f01050d8:	75 68                	jne    f0105142 <syscall+0x3b2>
		return  -E_INVAL;
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
f01050da:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01050de:	74 08                	je     f01050e8 <syscall+0x358>
f01050e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01050e3:	f6 02 02             	testb  $0x2,(%edx)
f01050e6:	74 61                	je     f0105149 <syscall+0x3b9>
		return -E_INVAL;

	r = page_insert(destE->env_pgdir, page, dstva,perm);
f01050e8:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f01050eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01050ef:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01050f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01050f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050fd:	8b 40 60             	mov    0x60(%eax),%eax
f0105100:	89 04 24             	mov    %eax,(%esp)
f0105103:	e8 ac c1 ff ff       	call   f01012b4 <page_insert>
f0105108:	85 c0                	test   %eax,%eax
f010510a:	ba 00 00 00 00       	mov    $0x0,%edx
f010510f:	0f 4e d0             	cmovle %eax,%edx
f0105112:	eb 3a                	jmp    f010514e <syscall+0x3be>
	struct Env *srcE=0, *destE = 0;
	int r =0;
	if((r = envid2env(srcenvid, &srcE, 1)) < 0)
		return r;
	if((r = envid2env(dstenvid, &destE, 1)) < 0)
		return r;
f0105114:	89 c2                	mov    %eax,%edx
f0105116:	eb 36                	jmp    f010514e <syscall+0x3be>
	if( (int)srcva >= UTOP || ( (int)srcva % PGSIZE) != 0)
		return  -E_INVAL;
f0105118:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010511d:	eb 2f                	jmp    f010514e <syscall+0x3be>
f010511f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105124:	eb 28                	jmp    f010514e <syscall+0x3be>
	if( (int)dstva >= UTOP || ( (int)dstva % PGSIZE) != 0)
		return  -E_INVAL;
f0105126:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010512b:	eb 21                	jmp    f010514e <syscall+0x3be>
f010512d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105132:	eb 1a                	jmp    f010514e <syscall+0x3be>
	pte_t * srcPTE=0;
	struct PageInfo *page = page_lookup(srcE->env_pgdir, srcva, &srcPTE);
	if(page == 0)
		return -E_INVAL;
f0105134:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105139:	eb 13                	jmp    f010514e <syscall+0x3be>
	if(  (perm & (~PTE_SYSCALL) ) !=0 )
		return  -E_INVAL;
f010513b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105140:	eb 0c                	jmp    f010514e <syscall+0x3be>
	if( (perm & PTE_U )== 0 || (perm& PTE_P) ==0)
		return  -E_INVAL;
f0105142:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105147:	eb 05                	jmp    f010514e <syscall+0x3be>
	if ( (perm & PTE_W) && ( (*srcPTE & PTE_W )== 0) )
		return -E_INVAL;
f0105149:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
						break;
		case SYS_env_set_status: ret = sys_env_set_status(a1, a2);
						break;
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
f010514e:	89 d0                	mov    %edx,%eax
						break;
f0105150:	e9 6d 02 00 00       	jmp    f01053c2 <syscall+0x632>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e =0;
f0105155:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f010515c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105163:	00 
f0105164:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105167:	89 44 24 04          	mov    %eax,0x4(%esp)
f010516b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010516e:	89 04 24             	mov    %eax,(%esp)
f0105171:	e8 a4 e4 ff ff       	call   f010361a <envid2env>
f0105176:	85 c0                	test   %eax,%eax
f0105178:	0f 88 44 02 00 00    	js     f01053c2 <syscall+0x632>
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
f010517e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105185:	77 28                	ja     f01051af <syscall+0x41f>
f0105187:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010518e:	75 29                	jne    f01051b9 <syscall+0x429>
		return  -E_INVAL;
	page_remove(e->env_pgdir, va);
f0105190:	8b 45 10             	mov    0x10(%ebp),%eax
f0105193:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010519a:	8b 40 60             	mov    0x60(%eax),%eax
f010519d:	89 04 24             	mov    %eax,(%esp)
f01051a0:	e8 b6 c0 ff ff       	call   f010125b <page_remove>
	return 0;
f01051a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01051aa:	e9 13 02 00 00       	jmp    f01053c2 <syscall+0x632>
	struct Env *e =0;
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if( (int)va >= UTOP || ( (int)va % PGSIZE) != 0)
		return  -E_INVAL;
f01051af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051b4:	e9 09 02 00 00       	jmp    f01053c2 <syscall+0x632>
f01051b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc: 	ret = sys_page_alloc(a1, (void*) a2, a3);
						break;
		case SYS_page_map:	ret = sys_page_map(a1,(void*)a2, a3, (void*)a4, a5);
						break;
		case SYS_page_unmap:	ret = sys_page_unmap(a1, (void*) a2);
						break;
f01051be:	e9 ff 01 00 00       	jmp    f01053c2 <syscall+0x632>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{

	// LAB 4: Your code here.
	struct Env *e =0;
f01051c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r =0;
	if((r = envid2env(envid, &e, 1)) < 0)
f01051ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051d1:	00 
f01051d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051dc:	89 04 24             	mov    %eax,(%esp)
f01051df:	e8 36 e4 ff ff       	call   f010361a <envid2env>
f01051e4:	85 c0                	test   %eax,%eax
f01051e6:	0f 88 d6 01 00 00    	js     f01053c2 <syscall+0x632>
		return r;
	e->env_pgfault_upcall = func;
f01051ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ef:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051f2:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f01051f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01051fa:	e9 c3 01 00 00       	jmp    f01053c2 <syscall+0x632>
	
	// LAB 4: Your code here.

	//if(envid == 0x1004)
	//	cprintf("when the envid =0x1004, the value is %d\n", value);
	struct Env *env=0;
f01051ff:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int r =0;
	pte_t * pte =0;
f0105206:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if((r = envid2env(envid, &env, 0)) < 0)
f010520d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105214:	00 
f0105215:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105218:	89 44 24 04          	mov    %eax,0x4(%esp)
f010521c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010521f:	89 04 24             	mov    %eax,(%esp)
f0105222:	e8 f3 e3 ff ff       	call   f010361a <envid2env>
f0105227:	85 c0                	test   %eax,%eax
f0105229:	0f 88 eb 00 00 00    	js     f010531a <syscall+0x58a>
		return -E_BAD_ENV;
	
	
	if(env->env_ipc_recving == 0)
f010522f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105232:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105236:	0f 84 e5 00 00 00    	je     f0105321 <syscall+0x591>
		return -E_IPC_NOT_RECV;
	

	if((int)srcva < UTOP){
f010523c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105243:	0f 87 92 00 00 00    	ja     f01052db <syscall+0x54b>

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
f0105249:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105250:	0f 85 d2 00 00 00    	jne    f0105328 <syscall+0x598>
			return -E_INVAL;
			
		if(  (perm & (~PTE_SYSCALL) ) !=0 )
f0105256:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010525d:	0f 85 cc 00 00 00    	jne    f010532f <syscall+0x59f>
			return  -E_INVAL;
			
		if(  (perm & PTE_P) ==0 )
f0105263:	f6 45 18 01          	testb  $0x1,0x18(%ebp)
f0105267:	0f 84 c9 00 00 00    	je     f0105336 <syscall+0x5a6>
			return  -E_INVAL;
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
f010526d:	e8 27 14 00 00       	call   f0106699 <cpunum>
f0105272:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105275:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105279:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010527c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105280:	6b c0 74             	imul   $0x74,%eax,%eax
f0105283:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105289:	8b 40 60             	mov    0x60(%eax),%eax
f010528c:	89 04 24             	mov    %eax,(%esp)
f010528f:	e8 1d bf ff ff       	call   f01011b1 <page_lookup>
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
f0105294:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105298:	74 0c                	je     f01052a6 <syscall+0x516>
f010529a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010529d:	f6 02 02             	testb  $0x2,(%edx)
f01052a0:	0f 84 97 00 00 00    	je     f010533d <syscall+0x5ad>
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f01052a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052a9:	8b 59 6c             	mov    0x6c(%ecx),%ebx
			return 0;
f01052ac:	ba 00 00 00 00       	mov    $0x0,%edx
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
			return  -E_INVAL;
			
		if((int)env->env_ipc_dstva >= UTOP)
f01052b1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01052b7:	0f 87 8c 00 00 00    	ja     f0105349 <syscall+0x5b9>
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
f01052bd:	8b 7d 18             	mov    0x18(%ebp),%edi
f01052c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01052c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01052c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052cc:	8b 41 60             	mov    0x60(%ecx),%eax
f01052cf:	89 04 24             	mov    %eax,(%esp)
f01052d2:	e8 dd bf ff ff       	call   f01012b4 <page_insert>
		if(r < 0)
f01052d7:	85 c0                	test   %eax,%eax
f01052d9:	78 69                	js     f0105344 <syscall+0x5b4>
			return -E_NO_MEM;
			
		
	}

	env->env_ipc_value = value;
f01052db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052de:	8b 45 10             	mov    0x10(%ebp),%eax
f01052e1:	89 43 70             	mov    %eax,0x70(%ebx)
	env->env_ipc_from = curenv->env_id;
f01052e4:	e8 b0 13 00 00       	call   f0106699 <cpunum>
f01052e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ec:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01052f2:	8b 40 48             	mov    0x48(%eax),%eax
f01052f5:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_perm = perm;
f01052f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052fb:	8b 7d 18             	mov    0x18(%ebp),%edi
f01052fe:	89 78 78             	mov    %edi,0x78(%eax)
	env->env_ipc_recving = 0;
f0105301:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_status = ENV_RUNNABLE;
f0105305:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f010530c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f0105313:	ba 00 00 00 00       	mov    $0x0,%edx
f0105318:	eb 2f                	jmp    f0105349 <syscall+0x5b9>
	//	cprintf("when the envid =0x1004, the value is %d\n", value);
	struct Env *env=0;
	int r =0;
	pte_t * pte =0;
	if((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
f010531a:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f010531f:	eb 28                	jmp    f0105349 <syscall+0x5b9>
	
	
	if(env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f0105321:	ba f8 ff ff ff       	mov    $0xfffffff8,%edx
f0105326:	eb 21                	jmp    f0105349 <syscall+0x5b9>
	

	if((int)srcva < UTOP){

		if ( (int)srcva < UTOP &&  ((int)srcva % PGSIZE != 0) )
			return -E_INVAL;
f0105328:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010532d:	eb 1a                	jmp    f0105349 <syscall+0x5b9>
			
		if(  (perm & (~PTE_SYSCALL) ) !=0 )
			return  -E_INVAL;
f010532f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105334:	eb 13                	jmp    f0105349 <syscall+0x5b9>
			
		if(  (perm & PTE_P) ==0 )
			return  -E_INVAL;
f0105336:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010533b:	eb 0c                	jmp    f0105349 <syscall+0x5b9>
			
		struct PageInfo *page  = page_lookup(curenv->env_pgdir, srcva, &pte);
		if( (perm & PTE_W) && ( (*pte & PTE_W) == 0) )
			return  -E_INVAL;
f010533d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105342:	eb 05                	jmp    f0105349 <syscall+0x5b9>
			
		if((int)env->env_ipc_dstva >= UTOP)
			return 0;
		r = page_insert(env->env_pgdir, page, env->env_ipc_dstva ,perm);
		if(r < 0)
			return -E_NO_MEM;
f0105344:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
						break;
		case SYS_env_set_pgfault_upcall:
					ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105349:	89 d0                	mov    %edx,%eax
						break;
f010534b:	eb 75                	jmp    f01053c2 <syscall+0x632>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	if((int)dstva >= UTOP)
f010534d:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105354:	76 17                	jbe    f010536d <syscall+0x5dd>
		curenv->env_ipc_dstva = (void*)UTOP;
f0105356:	e8 3e 13 00 00       	call   f0106699 <cpunum>
f010535b:	6b c0 74             	imul   $0x74,%eax,%eax
f010535e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105364:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
f010536b:	eb 1d                	jmp    f010538a <syscall+0x5fa>
	else{
		if((int)dstva % PGSIZE != 0)
f010536d:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105374:	75 47                	jne    f01053bd <syscall+0x62d>
			return -E_INVAL;
		else curenv->env_ipc_dstva = dstva;
f0105376:	e8 1e 13 00 00       	call   f0106699 <cpunum>
f010537b:	6b c0 74             	imul   $0x74,%eax,%eax
f010537e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105387:	89 48 6c             	mov    %ecx,0x6c(%eax)
	}
	
	curenv->env_status = ENV_NOT_RUNNABLE;
f010538a:	e8 0a 13 00 00       	call   f0106699 <cpunum>
f010538f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105392:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105398:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = 1;
f010539f:	e8 f5 12 00 00       	call   f0106699 <cpunum>
f01053a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01053a7:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01053ad:	c6 40 68 01          	movb   $0x1,0x68(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01053b1:	e8 11 f9 ff ff       	call   f0104cc7 <sched_yield>
		case  SYS_ipc_recv:	
					ret = sys_ipc_recv ( (void *)a1);
						break;

		default:
			return -E_NO_SYS;
f01053b6:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01053bb:	eb 05                	jmp    f01053c2 <syscall+0x632>
						break;
		case SYS_ipc_try_send:
					ret = sys_ipc_try_send(a1, a2, (void*)a3, a4);
						break;
		case  SYS_ipc_recv:	
					ret = sys_ipc_recv ( (void *)a1);
f01053bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

		default:
			return -E_NO_SYS;
	}
	return ret;
}
f01053c2:	83 c4 2c             	add    $0x2c,%esp
f01053c5:	5b                   	pop    %ebx
f01053c6:	5e                   	pop    %esi
f01053c7:	5f                   	pop    %edi
f01053c8:	5d                   	pop    %ebp
f01053c9:	c3                   	ret    

f01053ca <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01053ca:	55                   	push   %ebp
f01053cb:	89 e5                	mov    %esp,%ebp
f01053cd:	57                   	push   %edi
f01053ce:	56                   	push   %esi
f01053cf:	53                   	push   %ebx
f01053d0:	83 ec 14             	sub    $0x14,%esp
f01053d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01053d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01053dc:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01053df:	8b 1a                	mov    (%edx),%ebx
f01053e1:	8b 01                	mov    (%ecx),%eax
f01053e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01053e6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01053ed:	e9 88 00 00 00       	jmp    f010547a <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01053f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053f5:	01 d8                	add    %ebx,%eax
f01053f7:	89 c7                	mov    %eax,%edi
f01053f9:	c1 ef 1f             	shr    $0x1f,%edi
f01053fc:	01 c7                	add    %eax,%edi
f01053fe:	d1 ff                	sar    %edi
f0105400:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105403:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105406:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105409:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010540b:	eb 03                	jmp    f0105410 <stab_binsearch+0x46>
			m--;
f010540d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105410:	39 c3                	cmp    %eax,%ebx
f0105412:	7f 1f                	jg     f0105433 <stab_binsearch+0x69>
f0105414:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105418:	83 ea 0c             	sub    $0xc,%edx
f010541b:	39 f1                	cmp    %esi,%ecx
f010541d:	75 ee                	jne    f010540d <stab_binsearch+0x43>
f010541f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105422:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105425:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105428:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010542c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010542f:	76 18                	jbe    f0105449 <stab_binsearch+0x7f>
f0105431:	eb 05                	jmp    f0105438 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105433:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105436:	eb 42                	jmp    f010547a <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105438:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010543b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010543d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105440:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105447:	eb 31                	jmp    f010547a <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105449:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010544c:	73 17                	jae    f0105465 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010544e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105451:	83 e8 01             	sub    $0x1,%eax
f0105454:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105457:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010545a:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010545c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105463:	eb 15                	jmp    f010547a <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105468:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010546b:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010546d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105471:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105473:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010547a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010547d:	0f 8e 6f ff ff ff    	jle    f01053f2 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105483:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105487:	75 0f                	jne    f0105498 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010548c:	8b 00                	mov    (%eax),%eax
f010548e:	83 e8 01             	sub    $0x1,%eax
f0105491:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105494:	89 07                	mov    %eax,(%edi)
f0105496:	eb 2c                	jmp    f01054c4 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105498:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010549b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010549d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054a0:	8b 0f                	mov    (%edi),%ecx
f01054a2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054a5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01054a8:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054ab:	eb 03                	jmp    f01054b0 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01054ad:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054b0:	39 c8                	cmp    %ecx,%eax
f01054b2:	7e 0b                	jle    f01054bf <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01054b4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01054b8:	83 ea 0c             	sub    $0xc,%edx
f01054bb:	39 f3                	cmp    %esi,%ebx
f01054bd:	75 ee                	jne    f01054ad <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01054bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054c2:	89 07                	mov    %eax,(%edi)
	}
}
f01054c4:	83 c4 14             	add    $0x14,%esp
f01054c7:	5b                   	pop    %ebx
f01054c8:	5e                   	pop    %esi
f01054c9:	5f                   	pop    %edi
f01054ca:	5d                   	pop    %ebp
f01054cb:	c3                   	ret    

f01054cc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01054cc:	55                   	push   %ebp
f01054cd:	89 e5                	mov    %esp,%ebp
f01054cf:	57                   	push   %edi
f01054d0:	56                   	push   %esi
f01054d1:	53                   	push   %ebx
f01054d2:	83 ec 4c             	sub    $0x4c,%esp
f01054d5:	8b 75 08             	mov    0x8(%ebp),%esi
f01054d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01054db:	c7 07 34 84 10 f0    	movl   $0xf0108434,(%edi)
	info->eip_line = 0;
f01054e1:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01054e8:	c7 47 08 34 84 10 f0 	movl   $0xf0108434,0x8(%edi)
	info->eip_fn_namelen = 9;
f01054ef:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01054f6:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f01054f9:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105500:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105506:	0f 87 c1 00 00 00    	ja     f01055cd <debuginfo_eip+0x101>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010550c:	e8 88 11 00 00       	call   f0106699 <cpunum>
f0105511:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105518:	00 
f0105519:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105520:	00 
f0105521:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105528:	00 
f0105529:	6b c0 74             	imul   $0x74,%eax,%eax
f010552c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105532:	89 04 24             	mov    %eax,(%esp)
f0105535:	e8 3b df ff ff       	call   f0103475 <user_mem_check>
f010553a:	85 c0                	test   %eax,%eax
f010553c:	0f 85 49 02 00 00    	jne    f010578b <debuginfo_eip+0x2bf>
			return -1;

		stabs = usd->stabs;
f0105542:	a1 00 00 20 00       	mov    0x200000,%eax
f0105547:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010554a:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0105550:	a1 08 00 20 00       	mov    0x200008,%eax
f0105555:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105558:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010555e:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105561:	e8 33 11 00 00       	call   f0106699 <cpunum>
f0105566:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010556d:	00 
f010556e:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0105575:	00 
f0105576:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105579:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010557d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105580:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105586:	89 04 24             	mov    %eax,(%esp)
f0105589:	e8 e7 de ff ff       	call   f0103475 <user_mem_check>
f010558e:	85 c0                	test   %eax,%eax
f0105590:	0f 85 fc 01 00 00    	jne    f0105792 <debuginfo_eip+0x2c6>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105596:	e8 fe 10 00 00       	call   f0106699 <cpunum>
f010559b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01055a2:	00 
f01055a3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01055a6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055a9:	29 ca                	sub    %ecx,%edx
f01055ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01055af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01055b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01055b6:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01055bc:	89 04 24             	mov    %eax,(%esp)
f01055bf:	e8 b1 de ff ff       	call   f0103475 <user_mem_check>
f01055c4:	85 c0                	test   %eax,%eax
f01055c6:	74 1f                	je     f01055e7 <debuginfo_eip+0x11b>
f01055c8:	e9 cc 01 00 00       	jmp    f0105799 <debuginfo_eip+0x2cd>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01055cd:	c7 45 bc da 66 11 f0 	movl   $0xf01166da,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01055d4:	c7 45 c0 71 30 11 f0 	movl   $0xf0113071,-0x40(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01055db:	bb 70 30 11 f0       	mov    $0xf0113070,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055e0:	c7 45 c4 18 89 10 f0 	movl   $0xf0108918,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055e7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01055ea:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01055ed:	0f 83 ad 01 00 00    	jae    f01057a0 <debuginfo_eip+0x2d4>
f01055f3:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01055f7:	0f 85 aa 01 00 00    	jne    f01057a7 <debuginfo_eip+0x2db>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105604:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f0105607:	c1 fb 02             	sar    $0x2,%ebx
f010560a:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0105610:	83 e8 01             	sub    $0x1,%eax
f0105613:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105616:	89 74 24 04          	mov    %esi,0x4(%esp)
f010561a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105621:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105624:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105627:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010562a:	89 d8                	mov    %ebx,%eax
f010562c:	e8 99 fd ff ff       	call   f01053ca <stab_binsearch>
	if (lfile == 0)
f0105631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105634:	85 c0                	test   %eax,%eax
f0105636:	0f 84 72 01 00 00    	je     f01057ae <debuginfo_eip+0x2e2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010563c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010563f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105642:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105645:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105649:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105650:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105653:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105656:	89 d8                	mov    %ebx,%eax
f0105658:	e8 6d fd ff ff       	call   f01053ca <stab_binsearch>

	if (lfun <= rfun) {
f010565d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105660:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105663:	39 d8                	cmp    %ebx,%eax
f0105665:	7f 32                	jg     f0105699 <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105667:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010566a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010566d:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105670:	8b 0a                	mov    (%edx),%ecx
f0105672:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105675:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105678:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f010567b:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010567e:	73 09                	jae    f0105689 <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105680:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105683:	03 4d c0             	add    -0x40(%ebp),%ecx
f0105686:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105689:	8b 52 08             	mov    0x8(%edx),%edx
f010568c:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f010568f:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105691:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105694:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0105697:	eb 0f                	jmp    f01056a8 <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105699:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f010569c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010569f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01056a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056a8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01056af:	00 
f01056b0:	8b 47 08             	mov    0x8(%edi),%eax
f01056b3:	89 04 24             	mov    %eax,(%esp)
f01056b6:	e8 70 09 00 00       	call   f010602b <strfind>
f01056bb:	2b 47 08             	sub    0x8(%edi),%eax
f01056be:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01056c1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01056c5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01056cc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01056cf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056d2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01056d5:	89 f0                	mov    %esi,%eax
f01056d7:	e8 ee fc ff ff       	call   f01053ca <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01056dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01056df:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01056e2:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f01056e5:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01056ea:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056f0:	89 c3                	mov    %eax,%ebx
f01056f2:	89 d0                	mov    %edx,%eax
f01056f4:	01 ca                	add    %ecx,%edx
f01056f6:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01056f9:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01056fc:	89 df                	mov    %ebx,%edi
f01056fe:	eb 06                	jmp    f0105706 <debuginfo_eip+0x23a>
f0105700:	83 e8 01             	sub    $0x1,%eax
f0105703:	83 ea 0c             	sub    $0xc,%edx
f0105706:	89 c6                	mov    %eax,%esi
f0105708:	39 c7                	cmp    %eax,%edi
f010570a:	7f 3c                	jg     f0105748 <debuginfo_eip+0x27c>
	       && stabs[lline].n_type != N_SOL
f010570c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105710:	80 f9 84             	cmp    $0x84,%cl
f0105713:	75 08                	jne    f010571d <debuginfo_eip+0x251>
f0105715:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105718:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010571b:	eb 11                	jmp    f010572e <debuginfo_eip+0x262>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010571d:	80 f9 64             	cmp    $0x64,%cl
f0105720:	75 de                	jne    f0105700 <debuginfo_eip+0x234>
f0105722:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105726:	74 d8                	je     f0105700 <debuginfo_eip+0x234>
f0105728:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010572b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010572e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105731:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105734:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105737:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010573a:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010573d:	39 d0                	cmp    %edx,%eax
f010573f:	73 0a                	jae    f010574b <debuginfo_eip+0x27f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105741:	03 45 c0             	add    -0x40(%ebp),%eax
f0105744:	89 07                	mov    %eax,(%edi)
f0105746:	eb 03                	jmp    f010574b <debuginfo_eip+0x27f>
f0105748:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010574b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010574e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105751:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105756:	39 da                	cmp    %ebx,%edx
f0105758:	7d 60                	jge    f01057ba <debuginfo_eip+0x2ee>
		for (lline = lfun + 1;
f010575a:	83 c2 01             	add    $0x1,%edx
f010575d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105760:	89 d0                	mov    %edx,%eax
f0105762:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105765:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105768:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010576b:	eb 04                	jmp    f0105771 <debuginfo_eip+0x2a5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010576d:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105771:	39 c3                	cmp    %eax,%ebx
f0105773:	7e 40                	jle    f01057b5 <debuginfo_eip+0x2e9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105775:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105779:	83 c0 01             	add    $0x1,%eax
f010577c:	83 c2 0c             	add    $0xc,%edx
f010577f:	80 f9 a0             	cmp    $0xa0,%cl
f0105782:	74 e9                	je     f010576d <debuginfo_eip+0x2a1>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105784:	b8 00 00 00 00       	mov    $0x0,%eax
f0105789:	eb 2f                	jmp    f01057ba <debuginfo_eip+0x2ee>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f010578b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105790:	eb 28                	jmp    f01057ba <debuginfo_eip+0x2ee>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105797:	eb 21                	jmp    f01057ba <debuginfo_eip+0x2ee>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0105799:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010579e:	eb 1a                	jmp    f01057ba <debuginfo_eip+0x2ee>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01057a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057a5:	eb 13                	jmp    f01057ba <debuginfo_eip+0x2ee>
f01057a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057ac:	eb 0c                	jmp    f01057ba <debuginfo_eip+0x2ee>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01057ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057b3:	eb 05                	jmp    f01057ba <debuginfo_eip+0x2ee>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01057ba:	83 c4 4c             	add    $0x4c,%esp
f01057bd:	5b                   	pop    %ebx
f01057be:	5e                   	pop    %esi
f01057bf:	5f                   	pop    %edi
f01057c0:	5d                   	pop    %ebp
f01057c1:	c3                   	ret    
f01057c2:	66 90                	xchg   %ax,%ax
f01057c4:	66 90                	xchg   %ax,%ax
f01057c6:	66 90                	xchg   %ax,%ax
f01057c8:	66 90                	xchg   %ax,%ax
f01057ca:	66 90                	xchg   %ax,%ax
f01057cc:	66 90                	xchg   %ax,%ax
f01057ce:	66 90                	xchg   %ax,%ax

f01057d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01057d0:	55                   	push   %ebp
f01057d1:	89 e5                	mov    %esp,%ebp
f01057d3:	57                   	push   %edi
f01057d4:	56                   	push   %esi
f01057d5:	53                   	push   %ebx
f01057d6:	83 ec 3c             	sub    $0x3c,%esp
f01057d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057dc:	89 d7                	mov    %edx,%edi
f01057de:	8b 45 08             	mov    0x8(%ebp),%eax
f01057e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01057e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057e7:	89 c3                	mov    %eax,%ebx
f01057e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01057ec:	8b 45 10             	mov    0x10(%ebp),%eax
f01057ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01057f2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01057fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01057fd:	39 d9                	cmp    %ebx,%ecx
f01057ff:	72 05                	jb     f0105806 <printnum+0x36>
f0105801:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105804:	77 69                	ja     f010586f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105806:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105809:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010580d:	83 ee 01             	sub    $0x1,%esi
f0105810:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105814:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105818:	8b 44 24 08          	mov    0x8(%esp),%eax
f010581c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105820:	89 c3                	mov    %eax,%ebx
f0105822:	89 d6                	mov    %edx,%esi
f0105824:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105827:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010582a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010582e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105832:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105835:	89 04 24             	mov    %eax,(%esp)
f0105838:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010583b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010583f:	e8 9c 12 00 00       	call   f0106ae0 <__udivdi3>
f0105844:	89 d9                	mov    %ebx,%ecx
f0105846:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010584a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010584e:	89 04 24             	mov    %eax,(%esp)
f0105851:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105855:	89 fa                	mov    %edi,%edx
f0105857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010585a:	e8 71 ff ff ff       	call   f01057d0 <printnum>
f010585f:	eb 1b                	jmp    f010587c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105861:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105865:	8b 45 18             	mov    0x18(%ebp),%eax
f0105868:	89 04 24             	mov    %eax,(%esp)
f010586b:	ff d3                	call   *%ebx
f010586d:	eb 03                	jmp    f0105872 <printnum+0xa2>
f010586f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105872:	83 ee 01             	sub    $0x1,%esi
f0105875:	85 f6                	test   %esi,%esi
f0105877:	7f e8                	jg     f0105861 <printnum+0x91>
f0105879:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010587c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105880:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105884:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105887:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010588a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010588e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105892:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105895:	89 04 24             	mov    %eax,(%esp)
f0105898:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010589b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010589f:	e8 6c 13 00 00       	call   f0106c10 <__umoddi3>
f01058a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058a8:	0f be 80 3e 84 10 f0 	movsbl -0xfef7bc2(%eax),%eax
f01058af:	89 04 24             	mov    %eax,(%esp)
f01058b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058b5:	ff d0                	call   *%eax
}
f01058b7:	83 c4 3c             	add    $0x3c,%esp
f01058ba:	5b                   	pop    %ebx
f01058bb:	5e                   	pop    %esi
f01058bc:	5f                   	pop    %edi
f01058bd:	5d                   	pop    %ebp
f01058be:	c3                   	ret    

f01058bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01058bf:	55                   	push   %ebp
f01058c0:	89 e5                	mov    %esp,%ebp
f01058c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01058c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01058c9:	8b 10                	mov    (%eax),%edx
f01058cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01058ce:	73 0a                	jae    f01058da <sprintputch+0x1b>
		*b->buf++ = ch;
f01058d0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01058d3:	89 08                	mov    %ecx,(%eax)
f01058d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01058d8:	88 02                	mov    %al,(%edx)
}
f01058da:	5d                   	pop    %ebp
f01058db:	c3                   	ret    

f01058dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01058dc:	55                   	push   %ebp
f01058dd:	89 e5                	mov    %esp,%ebp
f01058df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01058e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01058e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01058ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01058f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01058fa:	89 04 24             	mov    %eax,(%esp)
f01058fd:	e8 02 00 00 00       	call   f0105904 <vprintfmt>
	va_end(ap);
}
f0105902:	c9                   	leave  
f0105903:	c3                   	ret    

f0105904 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105904:	55                   	push   %ebp
f0105905:	89 e5                	mov    %esp,%ebp
f0105907:	57                   	push   %edi
f0105908:	56                   	push   %esi
f0105909:	53                   	push   %ebx
f010590a:	83 ec 3c             	sub    $0x3c,%esp
f010590d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105910:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105913:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105916:	eb 11                	jmp    f0105929 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105918:	85 c0                	test   %eax,%eax
f010591a:	0f 84 48 04 00 00    	je     f0105d68 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0105920:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105924:	89 04 24             	mov    %eax,(%esp)
f0105927:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105929:	83 c7 01             	add    $0x1,%edi
f010592c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105930:	83 f8 25             	cmp    $0x25,%eax
f0105933:	75 e3                	jne    f0105918 <vprintfmt+0x14>
f0105935:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105939:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105940:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105947:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010594e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105953:	eb 1f                	jmp    f0105974 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105955:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105958:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010595c:	eb 16                	jmp    f0105974 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010595e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105961:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105965:	eb 0d                	jmp    f0105974 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105967:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010596a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010596d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105974:	8d 47 01             	lea    0x1(%edi),%eax
f0105977:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010597a:	0f b6 17             	movzbl (%edi),%edx
f010597d:	0f b6 c2             	movzbl %dl,%eax
f0105980:	83 ea 23             	sub    $0x23,%edx
f0105983:	80 fa 55             	cmp    $0x55,%dl
f0105986:	0f 87 bf 03 00 00    	ja     f0105d4b <vprintfmt+0x447>
f010598c:	0f b6 d2             	movzbl %dl,%edx
f010598f:	ff 24 95 00 85 10 f0 	jmp    *-0xfef7b00(,%edx,4)
f0105996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105999:	ba 00 00 00 00       	mov    $0x0,%edx
f010599e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01059a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01059a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01059a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f01059ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01059ae:	83 f9 09             	cmp    $0x9,%ecx
f01059b1:	77 3c                	ja     f01059ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01059b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01059b6:	eb e9                	jmp    f01059a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01059b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059bb:	8b 00                	mov    (%eax),%eax
f01059bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01059c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c3:	8d 40 04             	lea    0x4(%eax),%eax
f01059c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01059cc:	eb 27                	jmp    f01059f5 <vprintfmt+0xf1>
f01059ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01059d1:	85 d2                	test   %edx,%edx
f01059d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d8:	0f 49 c2             	cmovns %edx,%eax
f01059db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059e1:	eb 91                	jmp    f0105974 <vprintfmt+0x70>
f01059e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01059e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01059ed:	eb 85                	jmp    f0105974 <vprintfmt+0x70>
f01059ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01059f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01059f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01059f9:	0f 89 75 ff ff ff    	jns    f0105974 <vprintfmt+0x70>
f01059ff:	e9 63 ff ff ff       	jmp    f0105967 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105a04:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105a0a:	e9 65 ff ff ff       	jmp    f0105974 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a0f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105a12:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a1a:	8b 00                	mov    (%eax),%eax
f0105a1c:	89 04 24             	mov    %eax,(%esp)
f0105a1f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105a24:	e9 00 ff ff ff       	jmp    f0105929 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a29:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105a2c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105a30:	8b 00                	mov    (%eax),%eax
f0105a32:	99                   	cltd   
f0105a33:	31 d0                	xor    %edx,%eax
f0105a35:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105a37:	83 f8 09             	cmp    $0x9,%eax
f0105a3a:	7f 0b                	jg     f0105a47 <vprintfmt+0x143>
f0105a3c:	8b 14 85 60 86 10 f0 	mov    -0xfef79a0(,%eax,4),%edx
f0105a43:	85 d2                	test   %edx,%edx
f0105a45:	75 20                	jne    f0105a67 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0105a47:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a4b:	c7 44 24 08 56 84 10 	movl   $0xf0108456,0x8(%esp)
f0105a52:	f0 
f0105a53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a57:	89 34 24             	mov    %esi,(%esp)
f0105a5a:	e8 7d fe ff ff       	call   f01058dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105a62:	e9 c2 fe ff ff       	jmp    f0105929 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105a67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105a6b:	c7 44 24 08 f1 7b 10 	movl   $0xf0107bf1,0x8(%esp)
f0105a72:	f0 
f0105a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a77:	89 34 24             	mov    %esi,(%esp)
f0105a7a:	e8 5d fe ff ff       	call   f01058dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a82:	e9 a2 fe ff ff       	jmp    f0105929 <vprintfmt+0x25>
f0105a87:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a8a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105a8d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a90:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105a93:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0105a97:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105a99:	85 ff                	test   %edi,%edi
f0105a9b:	b8 4f 84 10 f0       	mov    $0xf010844f,%eax
f0105aa0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105aa3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105aa7:	0f 84 92 00 00 00    	je     f0105b3f <vprintfmt+0x23b>
f0105aad:	85 c9                	test   %ecx,%ecx
f0105aaf:	0f 8e 98 00 00 00    	jle    f0105b4d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ab9:	89 3c 24             	mov    %edi,(%esp)
f0105abc:	e8 17 04 00 00       	call   f0105ed8 <strnlen>
f0105ac1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105ac4:	29 c1                	sub    %eax,%ecx
f0105ac6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0105ac9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ad0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105ad3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ad5:	eb 0f                	jmp    f0105ae6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0105ad7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105adb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ade:	89 04 24             	mov    %eax,(%esp)
f0105ae1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ae3:	83 ef 01             	sub    $0x1,%edi
f0105ae6:	85 ff                	test   %edi,%edi
f0105ae8:	7f ed                	jg     f0105ad7 <vprintfmt+0x1d3>
f0105aea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105aed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105af0:	85 c9                	test   %ecx,%ecx
f0105af2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105af7:	0f 49 c1             	cmovns %ecx,%eax
f0105afa:	29 c1                	sub    %eax,%ecx
f0105afc:	89 75 08             	mov    %esi,0x8(%ebp)
f0105aff:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b02:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b05:	89 cb                	mov    %ecx,%ebx
f0105b07:	eb 50                	jmp    f0105b59 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105b09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105b0d:	74 1e                	je     f0105b2d <vprintfmt+0x229>
f0105b0f:	0f be d2             	movsbl %dl,%edx
f0105b12:	83 ea 20             	sub    $0x20,%edx
f0105b15:	83 fa 5e             	cmp    $0x5e,%edx
f0105b18:	76 13                	jbe    f0105b2d <vprintfmt+0x229>
					putch('?', putdat);
f0105b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b21:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105b28:	ff 55 08             	call   *0x8(%ebp)
f0105b2b:	eb 0d                	jmp    f0105b3a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f0105b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105b30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b34:	89 04 24             	mov    %eax,(%esp)
f0105b37:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b3a:	83 eb 01             	sub    $0x1,%ebx
f0105b3d:	eb 1a                	jmp    f0105b59 <vprintfmt+0x255>
f0105b3f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b42:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b45:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b48:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b4b:	eb 0c                	jmp    f0105b59 <vprintfmt+0x255>
f0105b4d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b50:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b53:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b56:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b59:	83 c7 01             	add    $0x1,%edi
f0105b5c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0105b60:	0f be c2             	movsbl %dl,%eax
f0105b63:	85 c0                	test   %eax,%eax
f0105b65:	74 25                	je     f0105b8c <vprintfmt+0x288>
f0105b67:	85 f6                	test   %esi,%esi
f0105b69:	78 9e                	js     f0105b09 <vprintfmt+0x205>
f0105b6b:	83 ee 01             	sub    $0x1,%esi
f0105b6e:	79 99                	jns    f0105b09 <vprintfmt+0x205>
f0105b70:	89 df                	mov    %ebx,%edi
f0105b72:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b78:	eb 1a                	jmp    f0105b94 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105b7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b7e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105b85:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105b87:	83 ef 01             	sub    $0x1,%edi
f0105b8a:	eb 08                	jmp    f0105b94 <vprintfmt+0x290>
f0105b8c:	89 df                	mov    %ebx,%edi
f0105b8e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b94:	85 ff                	test   %edi,%edi
f0105b96:	7f e2                	jg     f0105b7a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105b9b:	e9 89 fd ff ff       	jmp    f0105929 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105ba0:	83 f9 01             	cmp    $0x1,%ecx
f0105ba3:	7e 19                	jle    f0105bbe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0105ba5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ba8:	8b 50 04             	mov    0x4(%eax),%edx
f0105bab:	8b 00                	mov    (%eax),%eax
f0105bad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bb0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105bb3:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bb6:	8d 40 08             	lea    0x8(%eax),%eax
f0105bb9:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bbc:	eb 38                	jmp    f0105bf6 <vprintfmt+0x2f2>
	else if (lflag)
f0105bbe:	85 c9                	test   %ecx,%ecx
f0105bc0:	74 1b                	je     f0105bdd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0105bc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bc5:	8b 00                	mov    (%eax),%eax
f0105bc7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bca:	89 c1                	mov    %eax,%ecx
f0105bcc:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bcf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105bd2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bd5:	8d 40 04             	lea    0x4(%eax),%eax
f0105bd8:	89 45 14             	mov    %eax,0x14(%ebp)
f0105bdb:	eb 19                	jmp    f0105bf6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f0105bdd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be0:	8b 00                	mov    (%eax),%eax
f0105be2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105be5:	89 c1                	mov    %eax,%ecx
f0105be7:	c1 f9 1f             	sar    $0x1f,%ecx
f0105bea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105bed:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bf0:	8d 40 04             	lea    0x4(%eax),%eax
f0105bf3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105bf6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105bf9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105bfc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105c01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c05:	0f 89 04 01 00 00    	jns    f0105d0f <vprintfmt+0x40b>
				putch('-', putdat);
f0105c0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c0f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105c16:	ff d6                	call   *%esi
				num = -(long long) num;
f0105c18:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105c1b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105c1e:	f7 da                	neg    %edx
f0105c20:	83 d1 00             	adc    $0x0,%ecx
f0105c23:	f7 d9                	neg    %ecx
f0105c25:	e9 e5 00 00 00       	jmp    f0105d0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105c2a:	83 f9 01             	cmp    $0x1,%ecx
f0105c2d:	7e 10                	jle    f0105c3f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f0105c2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c32:	8b 10                	mov    (%eax),%edx
f0105c34:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c37:	8d 40 08             	lea    0x8(%eax),%eax
f0105c3a:	89 45 14             	mov    %eax,0x14(%ebp)
f0105c3d:	eb 26                	jmp    f0105c65 <vprintfmt+0x361>
	else if (lflag)
f0105c3f:	85 c9                	test   %ecx,%ecx
f0105c41:	74 12                	je     f0105c55 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0105c43:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c46:	8b 10                	mov    (%eax),%edx
f0105c48:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c4d:	8d 40 04             	lea    0x4(%eax),%eax
f0105c50:	89 45 14             	mov    %eax,0x14(%ebp)
f0105c53:	eb 10                	jmp    f0105c65 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0105c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c58:	8b 10                	mov    (%eax),%edx
f0105c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c5f:	8d 40 04             	lea    0x4(%eax),%eax
f0105c62:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105c65:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0105c6a:	e9 a0 00 00 00       	jmp    f0105d0f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105c6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c73:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c7a:	ff d6                	call   *%esi
			putch('X', putdat);
f0105c7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c80:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c87:	ff d6                	call   *%esi
			putch('X', putdat);
f0105c89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c8d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105c94:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105c99:	e9 8b fc ff ff       	jmp    f0105929 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f0105c9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ca2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105ca9:	ff d6                	call   *%esi
			putch('x', putdat);
f0105cab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105caf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105cb6:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105cb8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cbb:	8b 10                	mov    (%eax),%edx
f0105cbd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0105cc2:	8d 40 04             	lea    0x4(%eax),%eax
f0105cc5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105cc8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f0105ccd:	eb 40                	jmp    f0105d0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105ccf:	83 f9 01             	cmp    $0x1,%ecx
f0105cd2:	7e 10                	jle    f0105ce4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0105cd4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cd7:	8b 10                	mov    (%eax),%edx
f0105cd9:	8b 48 04             	mov    0x4(%eax),%ecx
f0105cdc:	8d 40 08             	lea    0x8(%eax),%eax
f0105cdf:	89 45 14             	mov    %eax,0x14(%ebp)
f0105ce2:	eb 26                	jmp    f0105d0a <vprintfmt+0x406>
	else if (lflag)
f0105ce4:	85 c9                	test   %ecx,%ecx
f0105ce6:	74 12                	je     f0105cfa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0105ce8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ceb:	8b 10                	mov    (%eax),%edx
f0105ced:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cf2:	8d 40 04             	lea    0x4(%eax),%eax
f0105cf5:	89 45 14             	mov    %eax,0x14(%ebp)
f0105cf8:	eb 10                	jmp    f0105d0a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f0105cfa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cfd:	8b 10                	mov    (%eax),%edx
f0105cff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d04:	8d 40 04             	lea    0x4(%eax),%eax
f0105d07:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105d0a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105d0f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105d13:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105d17:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105d22:	89 14 24             	mov    %edx,(%esp)
f0105d25:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105d29:	89 da                	mov    %ebx,%edx
f0105d2b:	89 f0                	mov    %esi,%eax
f0105d2d:	e8 9e fa ff ff       	call   f01057d0 <printnum>
			break;
f0105d32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105d35:	e9 ef fb ff ff       	jmp    f0105929 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105d3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d3e:	89 04 24             	mov    %eax,(%esp)
f0105d41:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105d46:	e9 de fb ff ff       	jmp    f0105929 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105d4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d4f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105d56:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d58:	eb 03                	jmp    f0105d5d <vprintfmt+0x459>
f0105d5a:	83 ef 01             	sub    $0x1,%edi
f0105d5d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105d61:	75 f7                	jne    f0105d5a <vprintfmt+0x456>
f0105d63:	e9 c1 fb ff ff       	jmp    f0105929 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0105d68:	83 c4 3c             	add    $0x3c,%esp
f0105d6b:	5b                   	pop    %ebx
f0105d6c:	5e                   	pop    %esi
f0105d6d:	5f                   	pop    %edi
f0105d6e:	5d                   	pop    %ebp
f0105d6f:	c3                   	ret    

f0105d70 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d70:	55                   	push   %ebp
f0105d71:	89 e5                	mov    %esp,%ebp
f0105d73:	83 ec 28             	sub    $0x28,%esp
f0105d76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d79:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d7f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d83:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d8d:	85 c0                	test   %eax,%eax
f0105d8f:	74 30                	je     f0105dc1 <vsnprintf+0x51>
f0105d91:	85 d2                	test   %edx,%edx
f0105d93:	7e 2c                	jle    f0105dc1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d95:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d98:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d9c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105da3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105da6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105daa:	c7 04 24 bf 58 10 f0 	movl   $0xf01058bf,(%esp)
f0105db1:	e8 4e fb ff ff       	call   f0105904 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105db6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105db9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105dbf:	eb 05                	jmp    f0105dc6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105dc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105dc6:	c9                   	leave  
f0105dc7:	c3                   	ret    

f0105dc8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105dc8:	55                   	push   %ebp
f0105dc9:	89 e5                	mov    %esp,%ebp
f0105dcb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105dce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105dd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105dd5:	8b 45 10             	mov    0x10(%ebp),%eax
f0105dd8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105de3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105de6:	89 04 24             	mov    %eax,(%esp)
f0105de9:	e8 82 ff ff ff       	call   f0105d70 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105dee:	c9                   	leave  
f0105def:	c3                   	ret    

f0105df0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105df0:	55                   	push   %ebp
f0105df1:	89 e5                	mov    %esp,%ebp
f0105df3:	57                   	push   %edi
f0105df4:	56                   	push   %esi
f0105df5:	53                   	push   %ebx
f0105df6:	83 ec 1c             	sub    $0x1c,%esp
f0105df9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105dfc:	85 c0                	test   %eax,%eax
f0105dfe:	74 10                	je     f0105e10 <readline+0x20>
		cprintf("%s", prompt);
f0105e00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e04:	c7 04 24 f1 7b 10 f0 	movl   $0xf0107bf1,(%esp)
f0105e0b:	e8 55 e1 ff ff       	call   f0103f65 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105e17:	e8 8f a9 ff ff       	call   f01007ab <iscons>
f0105e1c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105e1e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105e23:	e8 72 a9 ff ff       	call   f010079a <getchar>
f0105e28:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e2a:	85 c0                	test   %eax,%eax
f0105e2c:	79 17                	jns    f0105e45 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e32:	c7 04 24 88 86 10 f0 	movl   $0xf0108688,(%esp)
f0105e39:	e8 27 e1 ff ff       	call   f0103f65 <cprintf>
			return NULL;
f0105e3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e43:	eb 6d                	jmp    f0105eb2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e45:	83 f8 7f             	cmp    $0x7f,%eax
f0105e48:	74 05                	je     f0105e4f <readline+0x5f>
f0105e4a:	83 f8 08             	cmp    $0x8,%eax
f0105e4d:	75 19                	jne    f0105e68 <readline+0x78>
f0105e4f:	85 f6                	test   %esi,%esi
f0105e51:	7e 15                	jle    f0105e68 <readline+0x78>
			if (echoing)
f0105e53:	85 ff                	test   %edi,%edi
f0105e55:	74 0c                	je     f0105e63 <readline+0x73>
				cputchar('\b');
f0105e57:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105e5e:	e8 27 a9 ff ff       	call   f010078a <cputchar>
			i--;
f0105e63:	83 ee 01             	sub    $0x1,%esi
f0105e66:	eb bb                	jmp    f0105e23 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e68:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e6e:	7f 1c                	jg     f0105e8c <readline+0x9c>
f0105e70:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e73:	7e 17                	jle    f0105e8c <readline+0x9c>
			if (echoing)
f0105e75:	85 ff                	test   %edi,%edi
f0105e77:	74 08                	je     f0105e81 <readline+0x91>
				cputchar(c);
f0105e79:	89 1c 24             	mov    %ebx,(%esp)
f0105e7c:	e8 09 a9 ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f0105e81:	88 9e 80 0a 23 f0    	mov    %bl,-0xfdcf580(%esi)
f0105e87:	8d 76 01             	lea    0x1(%esi),%esi
f0105e8a:	eb 97                	jmp    f0105e23 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105e8c:	83 fb 0d             	cmp    $0xd,%ebx
f0105e8f:	74 05                	je     f0105e96 <readline+0xa6>
f0105e91:	83 fb 0a             	cmp    $0xa,%ebx
f0105e94:	75 8d                	jne    f0105e23 <readline+0x33>
			if (echoing)
f0105e96:	85 ff                	test   %edi,%edi
f0105e98:	74 0c                	je     f0105ea6 <readline+0xb6>
				cputchar('\n');
f0105e9a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105ea1:	e8 e4 a8 ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f0105ea6:	c6 86 80 0a 23 f0 00 	movb   $0x0,-0xfdcf580(%esi)
			return buf;
f0105ead:	b8 80 0a 23 f0       	mov    $0xf0230a80,%eax
		}
	}
}
f0105eb2:	83 c4 1c             	add    $0x1c,%esp
f0105eb5:	5b                   	pop    %ebx
f0105eb6:	5e                   	pop    %esi
f0105eb7:	5f                   	pop    %edi
f0105eb8:	5d                   	pop    %ebp
f0105eb9:	c3                   	ret    
f0105eba:	66 90                	xchg   %ax,%ax
f0105ebc:	66 90                	xchg   %ax,%ax
f0105ebe:	66 90                	xchg   %ax,%ax

f0105ec0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105ec0:	55                   	push   %ebp
f0105ec1:	89 e5                	mov    %esp,%ebp
f0105ec3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ec6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ecb:	eb 03                	jmp    f0105ed0 <strlen+0x10>
		n++;
f0105ecd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ed0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ed4:	75 f7                	jne    f0105ecd <strlen+0xd>
		n++;
	return n;
}
f0105ed6:	5d                   	pop    %ebp
f0105ed7:	c3                   	ret    

f0105ed8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ed8:	55                   	push   %ebp
f0105ed9:	89 e5                	mov    %esp,%ebp
f0105edb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ede:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ee1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ee6:	eb 03                	jmp    f0105eeb <strnlen+0x13>
		n++;
f0105ee8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105eeb:	39 d0                	cmp    %edx,%eax
f0105eed:	74 06                	je     f0105ef5 <strnlen+0x1d>
f0105eef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105ef3:	75 f3                	jne    f0105ee8 <strnlen+0x10>
		n++;
	return n;
}
f0105ef5:	5d                   	pop    %ebp
f0105ef6:	c3                   	ret    

f0105ef7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ef7:	55                   	push   %ebp
f0105ef8:	89 e5                	mov    %esp,%ebp
f0105efa:	53                   	push   %ebx
f0105efb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105f01:	89 c2                	mov    %eax,%edx
f0105f03:	83 c2 01             	add    $0x1,%edx
f0105f06:	83 c1 01             	add    $0x1,%ecx
f0105f09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105f0d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105f10:	84 db                	test   %bl,%bl
f0105f12:	75 ef                	jne    f0105f03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105f14:	5b                   	pop    %ebx
f0105f15:	5d                   	pop    %ebp
f0105f16:	c3                   	ret    

f0105f17 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f17:	55                   	push   %ebp
f0105f18:	89 e5                	mov    %esp,%ebp
f0105f1a:	53                   	push   %ebx
f0105f1b:	83 ec 08             	sub    $0x8,%esp
f0105f1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f21:	89 1c 24             	mov    %ebx,(%esp)
f0105f24:	e8 97 ff ff ff       	call   f0105ec0 <strlen>
	strcpy(dst + len, src);
f0105f29:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f2c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f30:	01 d8                	add    %ebx,%eax
f0105f32:	89 04 24             	mov    %eax,(%esp)
f0105f35:	e8 bd ff ff ff       	call   f0105ef7 <strcpy>
	return dst;
}
f0105f3a:	89 d8                	mov    %ebx,%eax
f0105f3c:	83 c4 08             	add    $0x8,%esp
f0105f3f:	5b                   	pop    %ebx
f0105f40:	5d                   	pop    %ebp
f0105f41:	c3                   	ret    

f0105f42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f42:	55                   	push   %ebp
f0105f43:	89 e5                	mov    %esp,%ebp
f0105f45:	56                   	push   %esi
f0105f46:	53                   	push   %ebx
f0105f47:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105f4d:	89 f3                	mov    %esi,%ebx
f0105f4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f52:	89 f2                	mov    %esi,%edx
f0105f54:	eb 0f                	jmp    f0105f65 <strncpy+0x23>
		*dst++ = *src;
f0105f56:	83 c2 01             	add    $0x1,%edx
f0105f59:	0f b6 01             	movzbl (%ecx),%eax
f0105f5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f5f:	80 39 01             	cmpb   $0x1,(%ecx)
f0105f62:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f65:	39 da                	cmp    %ebx,%edx
f0105f67:	75 ed                	jne    f0105f56 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105f69:	89 f0                	mov    %esi,%eax
f0105f6b:	5b                   	pop    %ebx
f0105f6c:	5e                   	pop    %esi
f0105f6d:	5d                   	pop    %ebp
f0105f6e:	c3                   	ret    

f0105f6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f6f:	55                   	push   %ebp
f0105f70:	89 e5                	mov    %esp,%ebp
f0105f72:	56                   	push   %esi
f0105f73:	53                   	push   %ebx
f0105f74:	8b 75 08             	mov    0x8(%ebp),%esi
f0105f77:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105f7d:	89 f0                	mov    %esi,%eax
f0105f7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f83:	85 c9                	test   %ecx,%ecx
f0105f85:	75 0b                	jne    f0105f92 <strlcpy+0x23>
f0105f87:	eb 1d                	jmp    f0105fa6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f89:	83 c0 01             	add    $0x1,%eax
f0105f8c:	83 c2 01             	add    $0x1,%edx
f0105f8f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105f92:	39 d8                	cmp    %ebx,%eax
f0105f94:	74 0b                	je     f0105fa1 <strlcpy+0x32>
f0105f96:	0f b6 0a             	movzbl (%edx),%ecx
f0105f99:	84 c9                	test   %cl,%cl
f0105f9b:	75 ec                	jne    f0105f89 <strlcpy+0x1a>
f0105f9d:	89 c2                	mov    %eax,%edx
f0105f9f:	eb 02                	jmp    f0105fa3 <strlcpy+0x34>
f0105fa1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105fa3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105fa6:	29 f0                	sub    %esi,%eax
}
f0105fa8:	5b                   	pop    %ebx
f0105fa9:	5e                   	pop    %esi
f0105faa:	5d                   	pop    %ebp
f0105fab:	c3                   	ret    

f0105fac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105fac:	55                   	push   %ebp
f0105fad:	89 e5                	mov    %esp,%ebp
f0105faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105fb5:	eb 06                	jmp    f0105fbd <strcmp+0x11>
		p++, q++;
f0105fb7:	83 c1 01             	add    $0x1,%ecx
f0105fba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105fbd:	0f b6 01             	movzbl (%ecx),%eax
f0105fc0:	84 c0                	test   %al,%al
f0105fc2:	74 04                	je     f0105fc8 <strcmp+0x1c>
f0105fc4:	3a 02                	cmp    (%edx),%al
f0105fc6:	74 ef                	je     f0105fb7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fc8:	0f b6 c0             	movzbl %al,%eax
f0105fcb:	0f b6 12             	movzbl (%edx),%edx
f0105fce:	29 d0                	sub    %edx,%eax
}
f0105fd0:	5d                   	pop    %ebp
f0105fd1:	c3                   	ret    

f0105fd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fd2:	55                   	push   %ebp
f0105fd3:	89 e5                	mov    %esp,%ebp
f0105fd5:	53                   	push   %ebx
f0105fd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fdc:	89 c3                	mov    %eax,%ebx
f0105fde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105fe1:	eb 06                	jmp    f0105fe9 <strncmp+0x17>
		n--, p++, q++;
f0105fe3:	83 c0 01             	add    $0x1,%eax
f0105fe6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105fe9:	39 d8                	cmp    %ebx,%eax
f0105feb:	74 15                	je     f0106002 <strncmp+0x30>
f0105fed:	0f b6 08             	movzbl (%eax),%ecx
f0105ff0:	84 c9                	test   %cl,%cl
f0105ff2:	74 04                	je     f0105ff8 <strncmp+0x26>
f0105ff4:	3a 0a                	cmp    (%edx),%cl
f0105ff6:	74 eb                	je     f0105fe3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ff8:	0f b6 00             	movzbl (%eax),%eax
f0105ffb:	0f b6 12             	movzbl (%edx),%edx
f0105ffe:	29 d0                	sub    %edx,%eax
f0106000:	eb 05                	jmp    f0106007 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106002:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106007:	5b                   	pop    %ebx
f0106008:	5d                   	pop    %ebp
f0106009:	c3                   	ret    

f010600a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010600a:	55                   	push   %ebp
f010600b:	89 e5                	mov    %esp,%ebp
f010600d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106010:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106014:	eb 07                	jmp    f010601d <strchr+0x13>
		if (*s == c)
f0106016:	38 ca                	cmp    %cl,%dl
f0106018:	74 0f                	je     f0106029 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010601a:	83 c0 01             	add    $0x1,%eax
f010601d:	0f b6 10             	movzbl (%eax),%edx
f0106020:	84 d2                	test   %dl,%dl
f0106022:	75 f2                	jne    f0106016 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0106024:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106029:	5d                   	pop    %ebp
f010602a:	c3                   	ret    

f010602b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010602b:	55                   	push   %ebp
f010602c:	89 e5                	mov    %esp,%ebp
f010602e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106031:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106035:	eb 07                	jmp    f010603e <strfind+0x13>
		if (*s == c)
f0106037:	38 ca                	cmp    %cl,%dl
f0106039:	74 0a                	je     f0106045 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010603b:	83 c0 01             	add    $0x1,%eax
f010603e:	0f b6 10             	movzbl (%eax),%edx
f0106041:	84 d2                	test   %dl,%dl
f0106043:	75 f2                	jne    f0106037 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0106045:	5d                   	pop    %ebp
f0106046:	c3                   	ret    

f0106047 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106047:	55                   	push   %ebp
f0106048:	89 e5                	mov    %esp,%ebp
f010604a:	57                   	push   %edi
f010604b:	56                   	push   %esi
f010604c:	53                   	push   %ebx
f010604d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106050:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106053:	85 c9                	test   %ecx,%ecx
f0106055:	74 36                	je     f010608d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106057:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010605d:	75 28                	jne    f0106087 <memset+0x40>
f010605f:	f6 c1 03             	test   $0x3,%cl
f0106062:	75 23                	jne    f0106087 <memset+0x40>
		c &= 0xFF;
f0106064:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106068:	89 d3                	mov    %edx,%ebx
f010606a:	c1 e3 08             	shl    $0x8,%ebx
f010606d:	89 d6                	mov    %edx,%esi
f010606f:	c1 e6 18             	shl    $0x18,%esi
f0106072:	89 d0                	mov    %edx,%eax
f0106074:	c1 e0 10             	shl    $0x10,%eax
f0106077:	09 f0                	or     %esi,%eax
f0106079:	09 c2                	or     %eax,%edx
f010607b:	89 d0                	mov    %edx,%eax
f010607d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010607f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106082:	fc                   	cld    
f0106083:	f3 ab                	rep stos %eax,%es:(%edi)
f0106085:	eb 06                	jmp    f010608d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106087:	8b 45 0c             	mov    0xc(%ebp),%eax
f010608a:	fc                   	cld    
f010608b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010608d:	89 f8                	mov    %edi,%eax
f010608f:	5b                   	pop    %ebx
f0106090:	5e                   	pop    %esi
f0106091:	5f                   	pop    %edi
f0106092:	5d                   	pop    %ebp
f0106093:	c3                   	ret    

f0106094 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106094:	55                   	push   %ebp
f0106095:	89 e5                	mov    %esp,%ebp
f0106097:	57                   	push   %edi
f0106098:	56                   	push   %esi
f0106099:	8b 45 08             	mov    0x8(%ebp),%eax
f010609c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010609f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01060a2:	39 c6                	cmp    %eax,%esi
f01060a4:	73 35                	jae    f01060db <memmove+0x47>
f01060a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01060a9:	39 d0                	cmp    %edx,%eax
f01060ab:	73 2e                	jae    f01060db <memmove+0x47>
		s += n;
		d += n;
f01060ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01060b0:	89 d6                	mov    %edx,%esi
f01060b2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01060ba:	75 13                	jne    f01060cf <memmove+0x3b>
f01060bc:	f6 c1 03             	test   $0x3,%cl
f01060bf:	75 0e                	jne    f01060cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01060c1:	83 ef 04             	sub    $0x4,%edi
f01060c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01060c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01060ca:	fd                   	std    
f01060cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060cd:	eb 09                	jmp    f01060d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01060cf:	83 ef 01             	sub    $0x1,%edi
f01060d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01060d5:	fd                   	std    
f01060d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01060d8:	fc                   	cld    
f01060d9:	eb 1d                	jmp    f01060f8 <memmove+0x64>
f01060db:	89 f2                	mov    %esi,%edx
f01060dd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060df:	f6 c2 03             	test   $0x3,%dl
f01060e2:	75 0f                	jne    f01060f3 <memmove+0x5f>
f01060e4:	f6 c1 03             	test   $0x3,%cl
f01060e7:	75 0a                	jne    f01060f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01060e9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01060ec:	89 c7                	mov    %eax,%edi
f01060ee:	fc                   	cld    
f01060ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060f1:	eb 05                	jmp    f01060f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01060f3:	89 c7                	mov    %eax,%edi
f01060f5:	fc                   	cld    
f01060f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01060f8:	5e                   	pop    %esi
f01060f9:	5f                   	pop    %edi
f01060fa:	5d                   	pop    %ebp
f01060fb:	c3                   	ret    

f01060fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01060fc:	55                   	push   %ebp
f01060fd:	89 e5                	mov    %esp,%ebp
f01060ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106102:	8b 45 10             	mov    0x10(%ebp),%eax
f0106105:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106109:	8b 45 0c             	mov    0xc(%ebp),%eax
f010610c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106110:	8b 45 08             	mov    0x8(%ebp),%eax
f0106113:	89 04 24             	mov    %eax,(%esp)
f0106116:	e8 79 ff ff ff       	call   f0106094 <memmove>
}
f010611b:	c9                   	leave  
f010611c:	c3                   	ret    

f010611d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010611d:	55                   	push   %ebp
f010611e:	89 e5                	mov    %esp,%ebp
f0106120:	56                   	push   %esi
f0106121:	53                   	push   %ebx
f0106122:	8b 55 08             	mov    0x8(%ebp),%edx
f0106125:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106128:	89 d6                	mov    %edx,%esi
f010612a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010612d:	eb 1a                	jmp    f0106149 <memcmp+0x2c>
		if (*s1 != *s2)
f010612f:	0f b6 02             	movzbl (%edx),%eax
f0106132:	0f b6 19             	movzbl (%ecx),%ebx
f0106135:	38 d8                	cmp    %bl,%al
f0106137:	74 0a                	je     f0106143 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0106139:	0f b6 c0             	movzbl %al,%eax
f010613c:	0f b6 db             	movzbl %bl,%ebx
f010613f:	29 d8                	sub    %ebx,%eax
f0106141:	eb 0f                	jmp    f0106152 <memcmp+0x35>
		s1++, s2++;
f0106143:	83 c2 01             	add    $0x1,%edx
f0106146:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106149:	39 f2                	cmp    %esi,%edx
f010614b:	75 e2                	jne    f010612f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010614d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106152:	5b                   	pop    %ebx
f0106153:	5e                   	pop    %esi
f0106154:	5d                   	pop    %ebp
f0106155:	c3                   	ret    

f0106156 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106156:	55                   	push   %ebp
f0106157:	89 e5                	mov    %esp,%ebp
f0106159:	8b 45 08             	mov    0x8(%ebp),%eax
f010615c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010615f:	89 c2                	mov    %eax,%edx
f0106161:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106164:	eb 07                	jmp    f010616d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106166:	38 08                	cmp    %cl,(%eax)
f0106168:	74 07                	je     f0106171 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010616a:	83 c0 01             	add    $0x1,%eax
f010616d:	39 d0                	cmp    %edx,%eax
f010616f:	72 f5                	jb     f0106166 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106171:	5d                   	pop    %ebp
f0106172:	c3                   	ret    

f0106173 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106173:	55                   	push   %ebp
f0106174:	89 e5                	mov    %esp,%ebp
f0106176:	57                   	push   %edi
f0106177:	56                   	push   %esi
f0106178:	53                   	push   %ebx
f0106179:	8b 55 08             	mov    0x8(%ebp),%edx
f010617c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010617f:	eb 03                	jmp    f0106184 <strtol+0x11>
		s++;
f0106181:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106184:	0f b6 0a             	movzbl (%edx),%ecx
f0106187:	80 f9 09             	cmp    $0x9,%cl
f010618a:	74 f5                	je     f0106181 <strtol+0xe>
f010618c:	80 f9 20             	cmp    $0x20,%cl
f010618f:	74 f0                	je     f0106181 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106191:	80 f9 2b             	cmp    $0x2b,%cl
f0106194:	75 0a                	jne    f01061a0 <strtol+0x2d>
		s++;
f0106196:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106199:	bf 00 00 00 00       	mov    $0x0,%edi
f010619e:	eb 11                	jmp    f01061b1 <strtol+0x3e>
f01061a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01061a5:	80 f9 2d             	cmp    $0x2d,%cl
f01061a8:	75 07                	jne    f01061b1 <strtol+0x3e>
		s++, neg = 1;
f01061aa:	8d 52 01             	lea    0x1(%edx),%edx
f01061ad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01061b1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01061b6:	75 15                	jne    f01061cd <strtol+0x5a>
f01061b8:	80 3a 30             	cmpb   $0x30,(%edx)
f01061bb:	75 10                	jne    f01061cd <strtol+0x5a>
f01061bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01061c1:	75 0a                	jne    f01061cd <strtol+0x5a>
		s += 2, base = 16;
f01061c3:	83 c2 02             	add    $0x2,%edx
f01061c6:	b8 10 00 00 00       	mov    $0x10,%eax
f01061cb:	eb 10                	jmp    f01061dd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f01061cd:	85 c0                	test   %eax,%eax
f01061cf:	75 0c                	jne    f01061dd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01061d1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01061d3:	80 3a 30             	cmpb   $0x30,(%edx)
f01061d6:	75 05                	jne    f01061dd <strtol+0x6a>
		s++, base = 8;
f01061d8:	83 c2 01             	add    $0x1,%edx
f01061db:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f01061dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01061e2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01061e5:	0f b6 0a             	movzbl (%edx),%ecx
f01061e8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01061eb:	89 f0                	mov    %esi,%eax
f01061ed:	3c 09                	cmp    $0x9,%al
f01061ef:	77 08                	ja     f01061f9 <strtol+0x86>
			dig = *s - '0';
f01061f1:	0f be c9             	movsbl %cl,%ecx
f01061f4:	83 e9 30             	sub    $0x30,%ecx
f01061f7:	eb 20                	jmp    f0106219 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01061f9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01061fc:	89 f0                	mov    %esi,%eax
f01061fe:	3c 19                	cmp    $0x19,%al
f0106200:	77 08                	ja     f010620a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106202:	0f be c9             	movsbl %cl,%ecx
f0106205:	83 e9 57             	sub    $0x57,%ecx
f0106208:	eb 0f                	jmp    f0106219 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010620a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010620d:	89 f0                	mov    %esi,%eax
f010620f:	3c 19                	cmp    $0x19,%al
f0106211:	77 16                	ja     f0106229 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106213:	0f be c9             	movsbl %cl,%ecx
f0106216:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106219:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010621c:	7d 0f                	jge    f010622d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010621e:	83 c2 01             	add    $0x1,%edx
f0106221:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106225:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106227:	eb bc                	jmp    f01061e5 <strtol+0x72>
f0106229:	89 d8                	mov    %ebx,%eax
f010622b:	eb 02                	jmp    f010622f <strtol+0xbc>
f010622d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010622f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106233:	74 05                	je     f010623a <strtol+0xc7>
		*endptr = (char *) s;
f0106235:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106238:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010623a:	f7 d8                	neg    %eax
f010623c:	85 ff                	test   %edi,%edi
f010623e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106241:	5b                   	pop    %ebx
f0106242:	5e                   	pop    %esi
f0106243:	5f                   	pop    %edi
f0106244:	5d                   	pop    %ebp
f0106245:	c3                   	ret    
f0106246:	66 90                	xchg   %ax,%ax

f0106248 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106248:	fa                   	cli    

	xorw    %ax, %ax
f0106249:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010624b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010624d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010624f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106251:	0f 01 16             	lgdtl  (%esi)
f0106254:	74 70                	je     f01062c6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106256:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106259:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010625d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106260:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106266:	08 00                	or     %al,(%eax)

f0106268 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106268:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010626c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010626e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106270:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106272:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106276:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106278:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010627a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010627f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106282:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106285:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010628a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010628d:	8b 25 84 0e 23 f0    	mov    0xf0230e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106293:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106298:	b8 e2 01 10 f0       	mov    $0xf01001e2,%eax
	call    *%eax
f010629d:	ff d0                	call   *%eax

f010629f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010629f:	eb fe                	jmp    f010629f <spin>
f01062a1:	8d 76 00             	lea    0x0(%esi),%esi

f01062a4 <gdt>:
	...
f01062ac:	ff                   	(bad)  
f01062ad:	ff 00                	incl   (%eax)
f01062af:	00 00                	add    %al,(%eax)
f01062b1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01062b8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01062bc <gdtdesc>:
f01062bc:	17                   	pop    %ss
f01062bd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01062c2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01062c2:	90                   	nop
f01062c3:	66 90                	xchg   %ax,%ax
f01062c5:	66 90                	xchg   %ax,%ax
f01062c7:	66 90                	xchg   %ax,%ax
f01062c9:	66 90                	xchg   %ax,%ax
f01062cb:	66 90                	xchg   %ax,%ax
f01062cd:	66 90                	xchg   %ax,%ax
f01062cf:	90                   	nop

f01062d0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01062d0:	55                   	push   %ebp
f01062d1:	89 e5                	mov    %esp,%ebp
f01062d3:	56                   	push   %esi
f01062d4:	53                   	push   %ebx
f01062d5:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062d8:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f01062de:	89 c3                	mov    %eax,%ebx
f01062e0:	c1 eb 0c             	shr    $0xc,%ebx
f01062e3:	39 cb                	cmp    %ecx,%ebx
f01062e5:	72 20                	jb     f0106307 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01062eb:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f01062f2:	f0 
f01062f3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01062fa:	00 
f01062fb:	c7 04 24 25 88 10 f0 	movl   $0xf0108825,(%esp)
f0106302:	e8 39 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106307:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010630d:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010630f:	89 c2                	mov    %eax,%edx
f0106311:	c1 ea 0c             	shr    $0xc,%edx
f0106314:	39 d1                	cmp    %edx,%ecx
f0106316:	77 20                	ja     f0106338 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106318:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010631c:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f0106323:	f0 
f0106324:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010632b:	00 
f010632c:	c7 04 24 25 88 10 f0 	movl   $0xf0108825,(%esp)
f0106333:	e8 08 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106338:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010633e:	eb 36                	jmp    f0106376 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106340:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106347:	00 
f0106348:	c7 44 24 04 35 88 10 	movl   $0xf0108835,0x4(%esp)
f010634f:	f0 
f0106350:	89 1c 24             	mov    %ebx,(%esp)
f0106353:	e8 c5 fd ff ff       	call   f010611d <memcmp>
f0106358:	85 c0                	test   %eax,%eax
f010635a:	75 17                	jne    f0106373 <mpsearch1+0xa3>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010635c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106361:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106365:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106367:	83 c2 01             	add    $0x1,%edx
f010636a:	83 fa 10             	cmp    $0x10,%edx
f010636d:	75 f2                	jne    f0106361 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010636f:	84 c0                	test   %al,%al
f0106371:	74 0e                	je     f0106381 <mpsearch1+0xb1>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106373:	83 c3 10             	add    $0x10,%ebx
f0106376:	39 f3                	cmp    %esi,%ebx
f0106378:	72 c6                	jb     f0106340 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010637a:	b8 00 00 00 00       	mov    $0x0,%eax
f010637f:	eb 02                	jmp    f0106383 <mpsearch1+0xb3>
f0106381:	89 d8                	mov    %ebx,%eax
}
f0106383:	83 c4 10             	add    $0x10,%esp
f0106386:	5b                   	pop    %ebx
f0106387:	5e                   	pop    %esi
f0106388:	5d                   	pop    %ebp
f0106389:	c3                   	ret    

f010638a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010638a:	55                   	push   %ebp
f010638b:	89 e5                	mov    %esp,%ebp
f010638d:	57                   	push   %edi
f010638e:	56                   	push   %esi
f010638f:	53                   	push   %ebx
f0106390:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106393:	c7 05 c0 13 23 f0 20 	movl   $0xf0231020,0xf02313c0
f010639a:	10 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010639d:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f01063a4:	75 24                	jne    f01063ca <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063a6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01063ad:	00 
f01063ae:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f01063b5:	f0 
f01063b6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01063bd:	00 
f01063be:	c7 04 24 25 88 10 f0 	movl   $0xf0108825,(%esp)
f01063c5:	e8 76 9c ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01063ca:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01063d1:	85 c0                	test   %eax,%eax
f01063d3:	74 16                	je     f01063eb <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01063d5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01063d8:	ba 00 04 00 00       	mov    $0x400,%edx
f01063dd:	e8 ee fe ff ff       	call   f01062d0 <mpsearch1>
f01063e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01063e5:	85 c0                	test   %eax,%eax
f01063e7:	75 3c                	jne    f0106425 <mp_init+0x9b>
f01063e9:	eb 20                	jmp    f010640b <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01063eb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01063f2:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01063f5:	2d 00 04 00 00       	sub    $0x400,%eax
f01063fa:	ba 00 04 00 00       	mov    $0x400,%edx
f01063ff:	e8 cc fe ff ff       	call   f01062d0 <mpsearch1>
f0106404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106407:	85 c0                	test   %eax,%eax
f0106409:	75 1a                	jne    f0106425 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010640b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106410:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106415:	e8 b6 fe ff ff       	call   f01062d0 <mpsearch1>
f010641a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010641d:	85 c0                	test   %eax,%eax
f010641f:	0f 84 54 02 00 00    	je     f0106679 <mp_init+0x2ef>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106428:	8b 70 04             	mov    0x4(%eax),%esi
f010642b:	85 f6                	test   %esi,%esi
f010642d:	74 06                	je     f0106435 <mp_init+0xab>
f010642f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106433:	74 11                	je     f0106446 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106435:	c7 04 24 98 86 10 f0 	movl   $0xf0108698,(%esp)
f010643c:	e8 24 db ff ff       	call   f0103f65 <cprintf>
f0106441:	e9 33 02 00 00       	jmp    f0106679 <mp_init+0x2ef>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106446:	89 f0                	mov    %esi,%eax
f0106448:	c1 e8 0c             	shr    $0xc,%eax
f010644b:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0106451:	72 20                	jb     f0106473 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106453:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106457:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f010645e:	f0 
f010645f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106466:	00 
f0106467:	c7 04 24 25 88 10 f0 	movl   $0xf0108825,(%esp)
f010646e:	e8 cd 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106473:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106479:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106480:	00 
f0106481:	c7 44 24 04 3a 88 10 	movl   $0xf010883a,0x4(%esp)
f0106488:	f0 
f0106489:	89 1c 24             	mov    %ebx,(%esp)
f010648c:	e8 8c fc ff ff       	call   f010611d <memcmp>
f0106491:	85 c0                	test   %eax,%eax
f0106493:	74 11                	je     f01064a6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106495:	c7 04 24 c8 86 10 f0 	movl   $0xf01086c8,(%esp)
f010649c:	e8 c4 da ff ff       	call   f0103f65 <cprintf>
f01064a1:	e9 d3 01 00 00       	jmp    f0106679 <mp_init+0x2ef>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01064a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01064aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01064ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01064b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01064b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01064bb:	eb 0d                	jmp    f01064ca <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f01064bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01064c4:	f0 
f01064c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01064c7:	83 c0 01             	add    $0x1,%eax
f01064ca:	39 c7                	cmp    %eax,%edi
f01064cc:	7f ef                	jg     f01064bd <mp_init+0x133>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01064ce:	84 d2                	test   %dl,%dl
f01064d0:	74 11                	je     f01064e3 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f01064d2:	c7 04 24 fc 86 10 f0 	movl   $0xf01086fc,(%esp)
f01064d9:	e8 87 da ff ff       	call   f0103f65 <cprintf>
f01064de:	e9 96 01 00 00       	jmp    f0106679 <mp_init+0x2ef>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01064e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01064e7:	3c 04                	cmp    $0x4,%al
f01064e9:	74 1f                	je     f010650a <mp_init+0x180>
f01064eb:	3c 01                	cmp    $0x1,%al
f01064ed:	8d 76 00             	lea    0x0(%esi),%esi
f01064f0:	74 18                	je     f010650a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01064f2:	0f b6 c0             	movzbl %al,%eax
f01064f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064f9:	c7 04 24 20 87 10 f0 	movl   $0xf0108720,(%esp)
f0106500:	e8 60 da ff ff       	call   f0103f65 <cprintf>
f0106505:	e9 6f 01 00 00       	jmp    f0106679 <mp_init+0x2ef>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010650a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010650e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106512:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106514:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106519:	b8 00 00 00 00       	mov    $0x0,%eax
f010651e:	eb 09                	jmp    f0106529 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106520:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106524:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106526:	83 c0 01             	add    $0x1,%eax
f0106529:	39 c6                	cmp    %eax,%esi
f010652b:	7f f3                	jg     f0106520 <mp_init+0x196>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010652d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106530:	84 d2                	test   %dl,%dl
f0106532:	74 11                	je     f0106545 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106534:	c7 04 24 40 87 10 f0 	movl   $0xf0108740,(%esp)
f010653b:	e8 25 da ff ff       	call   f0103f65 <cprintf>
f0106540:	e9 34 01 00 00       	jmp    f0106679 <mp_init+0x2ef>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106545:	85 db                	test   %ebx,%ebx
f0106547:	0f 84 2c 01 00 00    	je     f0106679 <mp_init+0x2ef>
		return;
	ismp = 1;
f010654d:	c7 05 00 10 23 f0 01 	movl   $0x1,0xf0231000
f0106554:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106557:	8b 43 24             	mov    0x24(%ebx),%eax
f010655a:	a3 00 20 27 f0       	mov    %eax,0xf0272000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010655f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106562:	be 00 00 00 00       	mov    $0x0,%esi
f0106567:	e9 86 00 00 00       	jmp    f01065f2 <mp_init+0x268>
		switch (*p) {
f010656c:	0f b6 07             	movzbl (%edi),%eax
f010656f:	84 c0                	test   %al,%al
f0106571:	74 06                	je     f0106579 <mp_init+0x1ef>
f0106573:	3c 04                	cmp    $0x4,%al
f0106575:	77 57                	ja     f01065ce <mp_init+0x244>
f0106577:	eb 50                	jmp    f01065c9 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106579:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010657d:	8d 76 00             	lea    0x0(%esi),%esi
f0106580:	74 11                	je     f0106593 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106582:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f0106589:	05 20 10 23 f0       	add    $0xf0231020,%eax
f010658e:	a3 c0 13 23 f0       	mov    %eax,0xf02313c0
			if (ncpu < NCPU) {
f0106593:	a1 c4 13 23 f0       	mov    0xf02313c4,%eax
f0106598:	83 f8 07             	cmp    $0x7,%eax
f010659b:	7f 13                	jg     f01065b0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010659d:	6b d0 74             	imul   $0x74,%eax,%edx
f01065a0:	88 82 20 10 23 f0    	mov    %al,-0xfdcefe0(%edx)
				ncpu++;
f01065a6:	83 c0 01             	add    $0x1,%eax
f01065a9:	a3 c4 13 23 f0       	mov    %eax,0xf02313c4
f01065ae:	eb 14                	jmp    f01065c4 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01065b0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01065b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065b8:	c7 04 24 70 87 10 f0 	movl   $0xf0108770,(%esp)
f01065bf:	e8 a1 d9 ff ff       	call   f0103f65 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01065c4:	83 c7 14             	add    $0x14,%edi
			continue;
f01065c7:	eb 26                	jmp    f01065ef <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01065c9:	83 c7 08             	add    $0x8,%edi
			continue;
f01065cc:	eb 21                	jmp    f01065ef <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01065ce:	0f b6 c0             	movzbl %al,%eax
f01065d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065d5:	c7 04 24 98 87 10 f0 	movl   $0xf0108798,(%esp)
f01065dc:	e8 84 d9 ff ff       	call   f0103f65 <cprintf>
			ismp = 0;
f01065e1:	c7 05 00 10 23 f0 00 	movl   $0x0,0xf0231000
f01065e8:	00 00 00 
			i = conf->entry;
f01065eb:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065ef:	83 c6 01             	add    $0x1,%esi
f01065f2:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01065f6:	39 c6                	cmp    %eax,%esi
f01065f8:	0f 82 6e ff ff ff    	jb     f010656c <mp_init+0x1e2>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01065fe:	a1 c0 13 23 f0       	mov    0xf02313c0,%eax
f0106603:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010660a:	83 3d 00 10 23 f0 00 	cmpl   $0x0,0xf0231000
f0106611:	75 22                	jne    f0106635 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106613:	c7 05 c4 13 23 f0 01 	movl   $0x1,0xf02313c4
f010661a:	00 00 00 
		lapicaddr = 0;
f010661d:	c7 05 00 20 27 f0 00 	movl   $0x0,0xf0272000
f0106624:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106627:	c7 04 24 b8 87 10 f0 	movl   $0xf01087b8,(%esp)
f010662e:	e8 32 d9 ff ff       	call   f0103f65 <cprintf>
		return;
f0106633:	eb 44                	jmp    f0106679 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106635:	8b 15 c4 13 23 f0    	mov    0xf02313c4,%edx
f010663b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010663f:	0f b6 00             	movzbl (%eax),%eax
f0106642:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106646:	c7 04 24 3f 88 10 f0 	movl   $0xf010883f,(%esp)
f010664d:	e8 13 d9 ff ff       	call   f0103f65 <cprintf>

	if (mp->imcrp) {
f0106652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106655:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106659:	74 1e                	je     f0106679 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010665b:	c7 04 24 e4 87 10 f0 	movl   $0xf01087e4,(%esp)
f0106662:	e8 fe d8 ff ff       	call   f0103f65 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106667:	ba 22 00 00 00       	mov    $0x22,%edx
f010666c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106671:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106672:	b2 23                	mov    $0x23,%dl
f0106674:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106675:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106678:	ee                   	out    %al,(%dx)
	}
}
f0106679:	83 c4 2c             	add    $0x2c,%esp
f010667c:	5b                   	pop    %ebx
f010667d:	5e                   	pop    %esi
f010667e:	5f                   	pop    %edi
f010667f:	5d                   	pop    %ebp
f0106680:	c3                   	ret    

f0106681 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106681:	55                   	push   %ebp
f0106682:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106684:	8b 0d 04 20 27 f0    	mov    0xf0272004,%ecx
f010668a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010668d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010668f:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f0106694:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106697:	5d                   	pop    %ebp
f0106698:	c3                   	ret    

f0106699 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106699:	55                   	push   %ebp
f010669a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010669c:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f01066a1:	85 c0                	test   %eax,%eax
f01066a3:	74 08                	je     f01066ad <cpunum+0x14>
		return lapic[ID] >> 24;
f01066a5:	8b 40 20             	mov    0x20(%eax),%eax
f01066a8:	c1 e8 18             	shr    $0x18,%eax
f01066ab:	eb 05                	jmp    f01066b2 <cpunum+0x19>
	return 0;
f01066ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01066b2:	5d                   	pop    %ebp
f01066b3:	c3                   	ret    

f01066b4 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01066b4:	a1 00 20 27 f0       	mov    0xf0272000,%eax
f01066b9:	85 c0                	test   %eax,%eax
f01066bb:	0f 84 23 01 00 00    	je     f01067e4 <lapic_init+0x130>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01066c1:	55                   	push   %ebp
f01066c2:	89 e5                	mov    %esp,%ebp
f01066c4:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01066c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01066ce:	00 
f01066cf:	89 04 24             	mov    %eax,(%esp)
f01066d2:	e8 70 ac ff ff       	call   f0101347 <mmio_map_region>
f01066d7:	a3 04 20 27 f0       	mov    %eax,0xf0272004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01066dc:	ba 27 01 00 00       	mov    $0x127,%edx
f01066e1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01066e6:	e8 96 ff ff ff       	call   f0106681 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01066eb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01066f0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01066f5:	e8 87 ff ff ff       	call   f0106681 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01066fa:	ba 20 00 02 00       	mov    $0x20020,%edx
f01066ff:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106704:	e8 78 ff ff ff       	call   f0106681 <lapicw>
	lapicw(TICR, 10000000); 
f0106709:	ba 80 96 98 00       	mov    $0x989680,%edx
f010670e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106713:	e8 69 ff ff ff       	call   f0106681 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106718:	e8 7c ff ff ff       	call   f0106699 <cpunum>
f010671d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106720:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0106725:	39 05 c0 13 23 f0    	cmp    %eax,0xf02313c0
f010672b:	74 0f                	je     f010673c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f010672d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106732:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106737:	e8 45 ff ff ff       	call   f0106681 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010673c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106741:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106746:	e8 36 ff ff ff       	call   f0106681 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010674b:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f0106750:	8b 40 30             	mov    0x30(%eax),%eax
f0106753:	c1 e8 10             	shr    $0x10,%eax
f0106756:	3c 03                	cmp    $0x3,%al
f0106758:	76 0f                	jbe    f0106769 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010675a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010675f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106764:	e8 18 ff ff ff       	call   f0106681 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106769:	ba 33 00 00 00       	mov    $0x33,%edx
f010676e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106773:	e8 09 ff ff ff       	call   f0106681 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106778:	ba 00 00 00 00       	mov    $0x0,%edx
f010677d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106782:	e8 fa fe ff ff       	call   f0106681 <lapicw>
	lapicw(ESR, 0);
f0106787:	ba 00 00 00 00       	mov    $0x0,%edx
f010678c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106791:	e8 eb fe ff ff       	call   f0106681 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106796:	ba 00 00 00 00       	mov    $0x0,%edx
f010679b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01067a0:	e8 dc fe ff ff       	call   f0106681 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01067a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01067aa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067af:	e8 cd fe ff ff       	call   f0106681 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01067b4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01067b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067be:	e8 be fe ff ff       	call   f0106681 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01067c3:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f01067c9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01067cf:	f6 c4 10             	test   $0x10,%ah
f01067d2:	75 f5                	jne    f01067c9 <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01067d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01067d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01067de:	e8 9e fe ff ff       	call   f0106681 <lapicw>
}
f01067e3:	c9                   	leave  
f01067e4:	f3 c3                	repz ret 

f01067e6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01067e6:	83 3d 04 20 27 f0 00 	cmpl   $0x0,0xf0272004
f01067ed:	74 13                	je     f0106802 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01067ef:	55                   	push   %ebp
f01067f0:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01067f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01067f7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01067fc:	e8 80 fe ff ff       	call   f0106681 <lapicw>
}
f0106801:	5d                   	pop    %ebp
f0106802:	f3 c3                	repz ret 

f0106804 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106804:	55                   	push   %ebp
f0106805:	89 e5                	mov    %esp,%ebp
f0106807:	56                   	push   %esi
f0106808:	53                   	push   %ebx
f0106809:	83 ec 10             	sub    $0x10,%esp
f010680c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010680f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106812:	ba 70 00 00 00       	mov    $0x70,%edx
f0106817:	b8 0f 00 00 00       	mov    $0xf,%eax
f010681c:	ee                   	out    %al,(%dx)
f010681d:	b2 71                	mov    $0x71,%dl
f010681f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106824:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106825:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f010682c:	75 24                	jne    f0106852 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010682e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106835:	00 
f0106836:	c7 44 24 08 a4 6d 10 	movl   $0xf0106da4,0x8(%esp)
f010683d:	f0 
f010683e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106845:	00 
f0106846:	c7 04 24 5c 88 10 f0 	movl   $0xf010885c,(%esp)
f010684d:	e8 ee 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106852:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106859:	00 00 
	wrv[1] = addr >> 4;
f010685b:	89 f0                	mov    %esi,%eax
f010685d:	c1 e8 04             	shr    $0x4,%eax
f0106860:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106866:	c1 e3 18             	shl    $0x18,%ebx
f0106869:	89 da                	mov    %ebx,%edx
f010686b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106870:	e8 0c fe ff ff       	call   f0106681 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106875:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010687a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010687f:	e8 fd fd ff ff       	call   f0106681 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106884:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106889:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010688e:	e8 ee fd ff ff       	call   f0106681 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106893:	c1 ee 0c             	shr    $0xc,%esi
f0106896:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010689c:	89 da                	mov    %ebx,%edx
f010689e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068a3:	e8 d9 fd ff ff       	call   f0106681 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068a8:	89 f2                	mov    %esi,%edx
f01068aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068af:	e8 cd fd ff ff       	call   f0106681 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01068b4:	89 da                	mov    %ebx,%edx
f01068b6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068bb:	e8 c1 fd ff ff       	call   f0106681 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068c0:	89 f2                	mov    %esi,%edx
f01068c2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068c7:	e8 b5 fd ff ff       	call   f0106681 <lapicw>
		microdelay(200);
	}
}
f01068cc:	83 c4 10             	add    $0x10,%esp
f01068cf:	5b                   	pop    %ebx
f01068d0:	5e                   	pop    %esi
f01068d1:	5d                   	pop    %ebp
f01068d2:	c3                   	ret    

f01068d3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01068d3:	55                   	push   %ebp
f01068d4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01068d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01068d9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01068df:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068e4:	e8 98 fd ff ff       	call   f0106681 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01068e9:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f01068ef:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01068f5:	f6 c4 10             	test   $0x10,%ah
f01068f8:	75 f5                	jne    f01068ef <lapic_ipi+0x1c>
		;
}
f01068fa:	5d                   	pop    %ebp
f01068fb:	c3                   	ret    

f01068fc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01068fc:	55                   	push   %ebp
f01068fd:	89 e5                	mov    %esp,%ebp
f01068ff:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106902:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106908:	8b 55 0c             	mov    0xc(%ebp),%edx
f010690b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010690e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106915:	5d                   	pop    %ebp
f0106916:	c3                   	ret    

f0106917 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106917:	55                   	push   %ebp
f0106918:	89 e5                	mov    %esp,%ebp
f010691a:	56                   	push   %esi
f010691b:	53                   	push   %ebx
f010691c:	83 ec 20             	sub    $0x20,%esp
f010691f:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106922:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106925:	75 07                	jne    f010692e <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106927:	ba 01 00 00 00       	mov    $0x1,%edx
f010692c:	eb 42                	jmp    f0106970 <spin_lock+0x59>
f010692e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106931:	e8 63 fd ff ff       	call   f0106699 <cpunum>
f0106936:	6b c0 74             	imul   $0x74,%eax,%eax
f0106939:	05 20 10 23 f0       	add    $0xf0231020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010693e:	39 c6                	cmp    %eax,%esi
f0106940:	75 e5                	jne    f0106927 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106942:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106945:	e8 4f fd ff ff       	call   f0106699 <cpunum>
f010694a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010694e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106952:	c7 44 24 08 6c 88 10 	movl   $0xf010886c,0x8(%esp)
f0106959:	f0 
f010695a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106961:	00 
f0106962:	c7 04 24 d0 88 10 f0 	movl   $0xf01088d0,(%esp)
f0106969:	e8 d2 96 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010696e:	f3 90                	pause  
f0106970:	89 d0                	mov    %edx,%eax
f0106972:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106975:	85 c0                	test   %eax,%eax
f0106977:	75 f5                	jne    f010696e <spin_lock+0x57>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106979:	e8 1b fd ff ff       	call   f0106699 <cpunum>
f010697e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106981:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0106986:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106989:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010698c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010698e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106993:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106999:	76 12                	jbe    f01069ad <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010699b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010699e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01069a1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01069a3:	83 c0 01             	add    $0x1,%eax
f01069a6:	83 f8 0a             	cmp    $0xa,%eax
f01069a9:	75 e8                	jne    f0106993 <spin_lock+0x7c>
f01069ab:	eb 0f                	jmp    f01069bc <spin_lock+0xa5>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01069ad:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01069b4:	83 c0 01             	add    $0x1,%eax
f01069b7:	83 f8 09             	cmp    $0x9,%eax
f01069ba:	7e f1                	jle    f01069ad <spin_lock+0x96>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01069bc:	83 c4 20             	add    $0x20,%esp
f01069bf:	5b                   	pop    %ebx
f01069c0:	5e                   	pop    %esi
f01069c1:	5d                   	pop    %ebp
f01069c2:	c3                   	ret    

f01069c3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01069c3:	55                   	push   %ebp
f01069c4:	89 e5                	mov    %esp,%ebp
f01069c6:	57                   	push   %edi
f01069c7:	56                   	push   %esi
f01069c8:	53                   	push   %ebx
f01069c9:	83 ec 6c             	sub    $0x6c,%esp
f01069cc:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01069cf:	83 3e 00             	cmpl   $0x0,(%esi)
f01069d2:	74 18                	je     f01069ec <spin_unlock+0x29>
f01069d4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01069d7:	e8 bd fc ff ff       	call   f0106699 <cpunum>
f01069dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01069df:	05 20 10 23 f0       	add    $0xf0231020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01069e4:	39 c3                	cmp    %eax,%ebx
f01069e6:	0f 84 ce 00 00 00    	je     f0106aba <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01069ec:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01069f3:	00 
f01069f4:	8d 46 0c             	lea    0xc(%esi),%eax
f01069f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069fb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01069fe:	89 1c 24             	mov    %ebx,(%esp)
f0106a01:	e8 8e f6 ff ff       	call   f0106094 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106a06:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106a09:	0f b6 38             	movzbl (%eax),%edi
f0106a0c:	8b 76 04             	mov    0x4(%esi),%esi
f0106a0f:	e8 85 fc ff ff       	call   f0106699 <cpunum>
f0106a14:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a18:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a20:	c7 04 24 98 88 10 f0 	movl   $0xf0108898,(%esp)
f0106a27:	e8 39 d5 ff ff       	call   f0103f65 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106a2c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106a2f:	eb 65                	jmp    f0106a96 <spin_unlock+0xd3>
f0106a31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106a35:	89 04 24             	mov    %eax,(%esp)
f0106a38:	e8 8f ea ff ff       	call   f01054cc <debuginfo_eip>
f0106a3d:	85 c0                	test   %eax,%eax
f0106a3f:	78 39                	js     f0106a7a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106a41:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106a43:	89 c2                	mov    %eax,%edx
f0106a45:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106a48:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106a4c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106a4f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106a53:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106a56:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106a5a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106a5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106a61:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106a64:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106a68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a6c:	c7 04 24 e0 88 10 f0 	movl   $0xf01088e0,(%esp)
f0106a73:	e8 ed d4 ff ff       	call   f0103f65 <cprintf>
f0106a78:	eb 12                	jmp    f0106a8c <spin_unlock+0xc9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106a7a:	8b 06                	mov    (%esi),%eax
f0106a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a80:	c7 04 24 f7 88 10 f0 	movl   $0xf01088f7,(%esp)
f0106a87:	e8 d9 d4 ff ff       	call   f0103f65 <cprintf>
f0106a8c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106a8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106a92:	39 c3                	cmp    %eax,%ebx
f0106a94:	74 08                	je     f0106a9e <spin_unlock+0xdb>
f0106a96:	89 de                	mov    %ebx,%esi
f0106a98:	8b 03                	mov    (%ebx),%eax
f0106a9a:	85 c0                	test   %eax,%eax
f0106a9c:	75 93                	jne    f0106a31 <spin_unlock+0x6e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106a9e:	c7 44 24 08 ff 88 10 	movl   $0xf01088ff,0x8(%esp)
f0106aa5:	f0 
f0106aa6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106aad:	00 
f0106aae:	c7 04 24 d0 88 10 f0 	movl   $0xf01088d0,(%esp)
f0106ab5:	e8 86 95 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106aba:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106ac1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0106acd:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106ad0:	83 c4 6c             	add    $0x6c,%esp
f0106ad3:	5b                   	pop    %ebx
f0106ad4:	5e                   	pop    %esi
f0106ad5:	5f                   	pop    %edi
f0106ad6:	5d                   	pop    %ebp
f0106ad7:	c3                   	ret    
f0106ad8:	66 90                	xchg   %ax,%ax
f0106ada:	66 90                	xchg   %ax,%ax
f0106adc:	66 90                	xchg   %ax,%ax
f0106ade:	66 90                	xchg   %ax,%ax

f0106ae0 <__udivdi3>:
f0106ae0:	55                   	push   %ebp
f0106ae1:	57                   	push   %edi
f0106ae2:	56                   	push   %esi
f0106ae3:	83 ec 0c             	sub    $0xc,%esp
f0106ae6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106aea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106aee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106af2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106af6:	85 c0                	test   %eax,%eax
f0106af8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106afc:	89 ea                	mov    %ebp,%edx
f0106afe:	89 0c 24             	mov    %ecx,(%esp)
f0106b01:	75 2d                	jne    f0106b30 <__udivdi3+0x50>
f0106b03:	39 e9                	cmp    %ebp,%ecx
f0106b05:	77 61                	ja     f0106b68 <__udivdi3+0x88>
f0106b07:	85 c9                	test   %ecx,%ecx
f0106b09:	89 ce                	mov    %ecx,%esi
f0106b0b:	75 0b                	jne    f0106b18 <__udivdi3+0x38>
f0106b0d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b12:	31 d2                	xor    %edx,%edx
f0106b14:	f7 f1                	div    %ecx
f0106b16:	89 c6                	mov    %eax,%esi
f0106b18:	31 d2                	xor    %edx,%edx
f0106b1a:	89 e8                	mov    %ebp,%eax
f0106b1c:	f7 f6                	div    %esi
f0106b1e:	89 c5                	mov    %eax,%ebp
f0106b20:	89 f8                	mov    %edi,%eax
f0106b22:	f7 f6                	div    %esi
f0106b24:	89 ea                	mov    %ebp,%edx
f0106b26:	83 c4 0c             	add    $0xc,%esp
f0106b29:	5e                   	pop    %esi
f0106b2a:	5f                   	pop    %edi
f0106b2b:	5d                   	pop    %ebp
f0106b2c:	c3                   	ret    
f0106b2d:	8d 76 00             	lea    0x0(%esi),%esi
f0106b30:	39 e8                	cmp    %ebp,%eax
f0106b32:	77 24                	ja     f0106b58 <__udivdi3+0x78>
f0106b34:	0f bd e8             	bsr    %eax,%ebp
f0106b37:	83 f5 1f             	xor    $0x1f,%ebp
f0106b3a:	75 3c                	jne    f0106b78 <__udivdi3+0x98>
f0106b3c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106b40:	39 34 24             	cmp    %esi,(%esp)
f0106b43:	0f 86 9f 00 00 00    	jbe    f0106be8 <__udivdi3+0x108>
f0106b49:	39 d0                	cmp    %edx,%eax
f0106b4b:	0f 82 97 00 00 00    	jb     f0106be8 <__udivdi3+0x108>
f0106b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b58:	31 d2                	xor    %edx,%edx
f0106b5a:	31 c0                	xor    %eax,%eax
f0106b5c:	83 c4 0c             	add    $0xc,%esp
f0106b5f:	5e                   	pop    %esi
f0106b60:	5f                   	pop    %edi
f0106b61:	5d                   	pop    %ebp
f0106b62:	c3                   	ret    
f0106b63:	90                   	nop
f0106b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b68:	89 f8                	mov    %edi,%eax
f0106b6a:	f7 f1                	div    %ecx
f0106b6c:	31 d2                	xor    %edx,%edx
f0106b6e:	83 c4 0c             	add    $0xc,%esp
f0106b71:	5e                   	pop    %esi
f0106b72:	5f                   	pop    %edi
f0106b73:	5d                   	pop    %ebp
f0106b74:	c3                   	ret    
f0106b75:	8d 76 00             	lea    0x0(%esi),%esi
f0106b78:	89 e9                	mov    %ebp,%ecx
f0106b7a:	8b 3c 24             	mov    (%esp),%edi
f0106b7d:	d3 e0                	shl    %cl,%eax
f0106b7f:	89 c6                	mov    %eax,%esi
f0106b81:	b8 20 00 00 00       	mov    $0x20,%eax
f0106b86:	29 e8                	sub    %ebp,%eax
f0106b88:	89 c1                	mov    %eax,%ecx
f0106b8a:	d3 ef                	shr    %cl,%edi
f0106b8c:	89 e9                	mov    %ebp,%ecx
f0106b8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106b92:	8b 3c 24             	mov    (%esp),%edi
f0106b95:	09 74 24 08          	or     %esi,0x8(%esp)
f0106b99:	89 d6                	mov    %edx,%esi
f0106b9b:	d3 e7                	shl    %cl,%edi
f0106b9d:	89 c1                	mov    %eax,%ecx
f0106b9f:	89 3c 24             	mov    %edi,(%esp)
f0106ba2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106ba6:	d3 ee                	shr    %cl,%esi
f0106ba8:	89 e9                	mov    %ebp,%ecx
f0106baa:	d3 e2                	shl    %cl,%edx
f0106bac:	89 c1                	mov    %eax,%ecx
f0106bae:	d3 ef                	shr    %cl,%edi
f0106bb0:	09 d7                	or     %edx,%edi
f0106bb2:	89 f2                	mov    %esi,%edx
f0106bb4:	89 f8                	mov    %edi,%eax
f0106bb6:	f7 74 24 08          	divl   0x8(%esp)
f0106bba:	89 d6                	mov    %edx,%esi
f0106bbc:	89 c7                	mov    %eax,%edi
f0106bbe:	f7 24 24             	mull   (%esp)
f0106bc1:	39 d6                	cmp    %edx,%esi
f0106bc3:	89 14 24             	mov    %edx,(%esp)
f0106bc6:	72 30                	jb     f0106bf8 <__udivdi3+0x118>
f0106bc8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106bcc:	89 e9                	mov    %ebp,%ecx
f0106bce:	d3 e2                	shl    %cl,%edx
f0106bd0:	39 c2                	cmp    %eax,%edx
f0106bd2:	73 05                	jae    f0106bd9 <__udivdi3+0xf9>
f0106bd4:	3b 34 24             	cmp    (%esp),%esi
f0106bd7:	74 1f                	je     f0106bf8 <__udivdi3+0x118>
f0106bd9:	89 f8                	mov    %edi,%eax
f0106bdb:	31 d2                	xor    %edx,%edx
f0106bdd:	e9 7a ff ff ff       	jmp    f0106b5c <__udivdi3+0x7c>
f0106be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106be8:	31 d2                	xor    %edx,%edx
f0106bea:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bef:	e9 68 ff ff ff       	jmp    f0106b5c <__udivdi3+0x7c>
f0106bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bf8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0106bfb:	31 d2                	xor    %edx,%edx
f0106bfd:	83 c4 0c             	add    $0xc,%esp
f0106c00:	5e                   	pop    %esi
f0106c01:	5f                   	pop    %edi
f0106c02:	5d                   	pop    %ebp
f0106c03:	c3                   	ret    
f0106c04:	66 90                	xchg   %ax,%ax
f0106c06:	66 90                	xchg   %ax,%ax
f0106c08:	66 90                	xchg   %ax,%ax
f0106c0a:	66 90                	xchg   %ax,%ax
f0106c0c:	66 90                	xchg   %ax,%ax
f0106c0e:	66 90                	xchg   %ax,%ax

f0106c10 <__umoddi3>:
f0106c10:	55                   	push   %ebp
f0106c11:	57                   	push   %edi
f0106c12:	56                   	push   %esi
f0106c13:	83 ec 14             	sub    $0x14,%esp
f0106c16:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106c1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106c1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106c22:	89 c7                	mov    %eax,%edi
f0106c24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c28:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106c2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106c30:	89 34 24             	mov    %esi,(%esp)
f0106c33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c37:	85 c0                	test   %eax,%eax
f0106c39:	89 c2                	mov    %eax,%edx
f0106c3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c3f:	75 17                	jne    f0106c58 <__umoddi3+0x48>
f0106c41:	39 fe                	cmp    %edi,%esi
f0106c43:	76 4b                	jbe    f0106c90 <__umoddi3+0x80>
f0106c45:	89 c8                	mov    %ecx,%eax
f0106c47:	89 fa                	mov    %edi,%edx
f0106c49:	f7 f6                	div    %esi
f0106c4b:	89 d0                	mov    %edx,%eax
f0106c4d:	31 d2                	xor    %edx,%edx
f0106c4f:	83 c4 14             	add    $0x14,%esp
f0106c52:	5e                   	pop    %esi
f0106c53:	5f                   	pop    %edi
f0106c54:	5d                   	pop    %ebp
f0106c55:	c3                   	ret    
f0106c56:	66 90                	xchg   %ax,%ax
f0106c58:	39 f8                	cmp    %edi,%eax
f0106c5a:	77 54                	ja     f0106cb0 <__umoddi3+0xa0>
f0106c5c:	0f bd e8             	bsr    %eax,%ebp
f0106c5f:	83 f5 1f             	xor    $0x1f,%ebp
f0106c62:	75 5c                	jne    f0106cc0 <__umoddi3+0xb0>
f0106c64:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106c68:	39 3c 24             	cmp    %edi,(%esp)
f0106c6b:	0f 87 e7 00 00 00    	ja     f0106d58 <__umoddi3+0x148>
f0106c71:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c75:	29 f1                	sub    %esi,%ecx
f0106c77:	19 c7                	sbb    %eax,%edi
f0106c79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c81:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106c85:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106c89:	83 c4 14             	add    $0x14,%esp
f0106c8c:	5e                   	pop    %esi
f0106c8d:	5f                   	pop    %edi
f0106c8e:	5d                   	pop    %ebp
f0106c8f:	c3                   	ret    
f0106c90:	85 f6                	test   %esi,%esi
f0106c92:	89 f5                	mov    %esi,%ebp
f0106c94:	75 0b                	jne    f0106ca1 <__umoddi3+0x91>
f0106c96:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c9b:	31 d2                	xor    %edx,%edx
f0106c9d:	f7 f6                	div    %esi
f0106c9f:	89 c5                	mov    %eax,%ebp
f0106ca1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106ca5:	31 d2                	xor    %edx,%edx
f0106ca7:	f7 f5                	div    %ebp
f0106ca9:	89 c8                	mov    %ecx,%eax
f0106cab:	f7 f5                	div    %ebp
f0106cad:	eb 9c                	jmp    f0106c4b <__umoddi3+0x3b>
f0106caf:	90                   	nop
f0106cb0:	89 c8                	mov    %ecx,%eax
f0106cb2:	89 fa                	mov    %edi,%edx
f0106cb4:	83 c4 14             	add    $0x14,%esp
f0106cb7:	5e                   	pop    %esi
f0106cb8:	5f                   	pop    %edi
f0106cb9:	5d                   	pop    %ebp
f0106cba:	c3                   	ret    
f0106cbb:	90                   	nop
f0106cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106cc0:	8b 04 24             	mov    (%esp),%eax
f0106cc3:	be 20 00 00 00       	mov    $0x20,%esi
f0106cc8:	89 e9                	mov    %ebp,%ecx
f0106cca:	29 ee                	sub    %ebp,%esi
f0106ccc:	d3 e2                	shl    %cl,%edx
f0106cce:	89 f1                	mov    %esi,%ecx
f0106cd0:	d3 e8                	shr    %cl,%eax
f0106cd2:	89 e9                	mov    %ebp,%ecx
f0106cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cd8:	8b 04 24             	mov    (%esp),%eax
f0106cdb:	09 54 24 04          	or     %edx,0x4(%esp)
f0106cdf:	89 fa                	mov    %edi,%edx
f0106ce1:	d3 e0                	shl    %cl,%eax
f0106ce3:	89 f1                	mov    %esi,%ecx
f0106ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ce9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106ced:	d3 ea                	shr    %cl,%edx
f0106cef:	89 e9                	mov    %ebp,%ecx
f0106cf1:	d3 e7                	shl    %cl,%edi
f0106cf3:	89 f1                	mov    %esi,%ecx
f0106cf5:	d3 e8                	shr    %cl,%eax
f0106cf7:	89 e9                	mov    %ebp,%ecx
f0106cf9:	09 f8                	or     %edi,%eax
f0106cfb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106cff:	f7 74 24 04          	divl   0x4(%esp)
f0106d03:	d3 e7                	shl    %cl,%edi
f0106d05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d09:	89 d7                	mov    %edx,%edi
f0106d0b:	f7 64 24 08          	mull   0x8(%esp)
f0106d0f:	39 d7                	cmp    %edx,%edi
f0106d11:	89 c1                	mov    %eax,%ecx
f0106d13:	89 14 24             	mov    %edx,(%esp)
f0106d16:	72 2c                	jb     f0106d44 <__umoddi3+0x134>
f0106d18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106d1c:	72 22                	jb     f0106d40 <__umoddi3+0x130>
f0106d1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d22:	29 c8                	sub    %ecx,%eax
f0106d24:	19 d7                	sbb    %edx,%edi
f0106d26:	89 e9                	mov    %ebp,%ecx
f0106d28:	89 fa                	mov    %edi,%edx
f0106d2a:	d3 e8                	shr    %cl,%eax
f0106d2c:	89 f1                	mov    %esi,%ecx
f0106d2e:	d3 e2                	shl    %cl,%edx
f0106d30:	89 e9                	mov    %ebp,%ecx
f0106d32:	d3 ef                	shr    %cl,%edi
f0106d34:	09 d0                	or     %edx,%eax
f0106d36:	89 fa                	mov    %edi,%edx
f0106d38:	83 c4 14             	add    $0x14,%esp
f0106d3b:	5e                   	pop    %esi
f0106d3c:	5f                   	pop    %edi
f0106d3d:	5d                   	pop    %ebp
f0106d3e:	c3                   	ret    
f0106d3f:	90                   	nop
f0106d40:	39 d7                	cmp    %edx,%edi
f0106d42:	75 da                	jne    f0106d1e <__umoddi3+0x10e>
f0106d44:	8b 14 24             	mov    (%esp),%edx
f0106d47:	89 c1                	mov    %eax,%ecx
f0106d49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106d4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106d51:	eb cb                	jmp    f0106d1e <__umoddi3+0x10e>
f0106d53:	90                   	nop
f0106d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106d58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106d5c:	0f 82 0f ff ff ff    	jb     f0106c71 <__umoddi3+0x61>
f0106d62:	e9 1a ff ff ff       	jmp    f0106c81 <__umoddi3+0x71>
