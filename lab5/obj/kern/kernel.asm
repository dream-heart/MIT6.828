
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 a0 19 10 f0 	movl   $0xf01019a0,(%esp)
f0100055:	e8 70 09 00 00       	call   f01009ca <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 f8 06 00 00       	call   f010077f <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 bc 19 10 f0 	movl   $0xf01019bc,(%esp)
f0100092:	e8 33 09 00 00       	call   f01009ca <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a8:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01000c0:	e8 ee 13 00 00       	call   f01014b3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 82 04 00 00       	call   f010054c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 d7 19 10 f0 	movl   $0xf01019d7,(%esp)
f01000d9:	e8 ec 08 00 00       	call   f01009ca <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 4f 07 00 00       	call   f0100845 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 f2 19 10 f0 	movl   $0xf01019f2,(%esp)
f010012c:	e8 99 08 00 00       	call   f01009ca <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 5a 08 00 00       	call   f0100997 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100144:	e8 81 08 00 00       	call   f01009ca <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 f0 06 00 00       	call   f0100845 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 0a 1a 10 f0 	movl   $0xf0101a0a,(%esp)
f0100176:	e8 4f 08 00 00       	call   f01009ca <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 0d 08 00 00       	call   f0100997 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100191:	e8 34 08 00 00       	call   f01009ca <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    
f010019c:	00 00                	add    %al,(%eax)
	...

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	74 06                	je     f01001c6 <serial_proc_data+0x18>
f01001c0:	b2 f8                	mov    $0xf8,%dl
f01001c2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c3:	0f b6 c8             	movzbl %al,%ecx
}
f01001c6:	89 c8                	mov    %ecx,%eax
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    

f01001ca <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ca:	55                   	push   %ebp
f01001cb:	89 e5                	mov    %esp,%ebp
f01001cd:	53                   	push   %ebx
f01001ce:	83 ec 04             	sub    $0x4,%esp
f01001d1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001d3:	eb 25                	jmp    f01001fa <cons_intr+0x30>
		if (c == 0)
f01001d5:	85 c0                	test   %eax,%eax
f01001d7:	74 21                	je     f01001fa <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01001d9:	8b 15 24 25 11 f0    	mov    0xf0112524,%edx
f01001df:	88 82 20 23 11 f0    	mov    %al,-0xfeedce0(%edx)
f01001e5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001e8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01001f2:	0f 44 c2             	cmove  %edx,%eax
f01001f5:	a3 24 25 11 f0       	mov    %eax,0xf0112524
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fa:	ff d3                	call   *%ebx
f01001fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ff:	75 d4                	jne    f01001d5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100201:	83 c4 04             	add    $0x4,%esp
f0100204:	5b                   	pop    %ebx
f0100205:	5d                   	pop    %ebp
f0100206:	c3                   	ret    

f0100207 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	57                   	push   %edi
f010020b:	56                   	push   %esi
f010020c:	53                   	push   %ebx
f010020d:	83 ec 2c             	sub    $0x2c,%esp
f0100210:	89 c7                	mov    %eax,%edi
f0100212:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100217:	be fd 03 00 00       	mov    $0x3fd,%esi
f010021c:	eb 05                	jmp    f0100223 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010021e:	e8 7d ff ff ff       	call   f01001a0 <delay>
f0100223:	89 f2                	mov    %esi,%edx
f0100225:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100226:	a8 20                	test   $0x20,%al
f0100228:	75 05                	jne    f010022f <cons_putc+0x28>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010022a:	83 eb 01             	sub    $0x1,%ebx
f010022d:	75 ef                	jne    f010021e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010022f:	89 fa                	mov    %edi,%edx
f0100231:	89 f8                	mov    %edi,%eax
f0100233:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100236:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010023b:	ee                   	out    %al,(%dx)
f010023c:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100241:	be 79 03 00 00       	mov    $0x379,%esi
f0100246:	eb 05                	jmp    f010024d <cons_putc+0x46>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100248:	e8 53 ff ff ff       	call   f01001a0 <delay>
f010024d:	89 f2                	mov    %esi,%edx
f010024f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100250:	84 c0                	test   %al,%al
f0100252:	78 05                	js     f0100259 <cons_putc+0x52>
f0100254:	83 eb 01             	sub    $0x1,%ebx
f0100257:	75 ef                	jne    f0100248 <cons_putc+0x41>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100259:	ba 78 03 00 00       	mov    $0x378,%edx
f010025e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100262:	ee                   	out    %al,(%dx)
f0100263:	b2 7a                	mov    $0x7a,%dl
f0100265:	b8 0d 00 00 00       	mov    $0xd,%eax
f010026a:	ee                   	out    %al,(%dx)
f010026b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100270:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100271:	89 fa                	mov    %edi,%edx
f0100273:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100279:	89 f8                	mov    %edi,%eax
f010027b:	80 cc 07             	or     $0x7,%ah
f010027e:	85 d2                	test   %edx,%edx
f0100280:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100283:	89 f8                	mov    %edi,%eax
f0100285:	25 ff 00 00 00       	and    $0xff,%eax
f010028a:	83 f8 09             	cmp    $0x9,%eax
f010028d:	74 79                	je     f0100308 <cons_putc+0x101>
f010028f:	83 f8 09             	cmp    $0x9,%eax
f0100292:	7f 0e                	jg     f01002a2 <cons_putc+0x9b>
f0100294:	83 f8 08             	cmp    $0x8,%eax
f0100297:	0f 85 9f 00 00 00    	jne    f010033c <cons_putc+0x135>
f010029d:	8d 76 00             	lea    0x0(%esi),%esi
f01002a0:	eb 10                	jmp    f01002b2 <cons_putc+0xab>
f01002a2:	83 f8 0a             	cmp    $0xa,%eax
f01002a5:	74 3b                	je     f01002e2 <cons_putc+0xdb>
f01002a7:	83 f8 0d             	cmp    $0xd,%eax
f01002aa:	0f 85 8c 00 00 00    	jne    f010033c <cons_putc+0x135>
f01002b0:	eb 38                	jmp    f01002ea <cons_putc+0xe3>
	case '\b':
		if (crt_pos > 0) {
f01002b2:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f01002b9:	66 85 c0             	test   %ax,%ax
f01002bc:	0f 84 e4 00 00 00    	je     f01003a6 <cons_putc+0x19f>
			crt_pos--;
f01002c2:	83 e8 01             	sub    $0x1,%eax
f01002c5:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002cb:	0f b7 c0             	movzwl %ax,%eax
f01002ce:	66 81 e7 00 ff       	and    $0xff00,%di
f01002d3:	83 cf 20             	or     $0x20,%edi
f01002d6:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
f01002dc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01002e0:	eb 77                	jmp    f0100359 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002e2:	66 83 05 34 25 11 f0 	addw   $0x50,0xf0112534
f01002e9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002ea:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f01002f1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002f7:	c1 e8 16             	shr    $0x16,%eax
f01002fa:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002fd:	c1 e0 04             	shl    $0x4,%eax
f0100300:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
f0100306:	eb 51                	jmp    f0100359 <cons_putc+0x152>
		break;
	case '\t':
		cons_putc(' ');
f0100308:	b8 20 00 00 00       	mov    $0x20,%eax
f010030d:	e8 f5 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100312:	b8 20 00 00 00       	mov    $0x20,%eax
f0100317:	e8 eb fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010031c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100321:	e8 e1 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100326:	b8 20 00 00 00       	mov    $0x20,%eax
f010032b:	e8 d7 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100330:	b8 20 00 00 00       	mov    $0x20,%eax
f0100335:	e8 cd fe ff ff       	call   f0100207 <cons_putc>
f010033a:	eb 1d                	jmp    f0100359 <cons_putc+0x152>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010033c:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f0100343:	0f b7 c8             	movzwl %ax,%ecx
f0100346:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
f010034c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100350:	83 c0 01             	add    $0x1,%eax
f0100353:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100359:	66 81 3d 34 25 11 f0 	cmpw   $0x7cf,0xf0112534
f0100360:	cf 07 
f0100362:	76 42                	jbe    f01003a6 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100364:	a1 30 25 11 f0       	mov    0xf0112530,%eax
f0100369:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100370:	00 
f0100371:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100377:	89 54 24 04          	mov    %edx,0x4(%esp)
f010037b:	89 04 24             	mov    %eax,(%esp)
f010037e:	e8 8b 11 00 00       	call   f010150e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100383:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100389:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010038e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100394:	83 c0 01             	add    $0x1,%eax
f0100397:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010039c:	75 f0                	jne    f010038e <cons_putc+0x187>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010039e:	66 83 2d 34 25 11 f0 	subw   $0x50,0xf0112534
f01003a5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003a6:	8b 0d 2c 25 11 f0    	mov    0xf011252c,%ecx
f01003ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003b1:	89 ca                	mov    %ecx,%edx
f01003b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003b4:	0f b7 35 34 25 11 f0 	movzwl 0xf0112534,%esi
f01003bb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003be:	89 f0                	mov    %esi,%eax
f01003c0:	66 c1 e8 08          	shr    $0x8,%ax
f01003c4:	89 da                	mov    %ebx,%edx
f01003c6:	ee                   	out    %al,(%dx)
f01003c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003cc:	89 ca                	mov    %ecx,%edx
f01003ce:	ee                   	out    %al,(%dx)
f01003cf:	89 f0                	mov    %esi,%eax
f01003d1:	89 da                	mov    %ebx,%edx
f01003d3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003d4:	83 c4 2c             	add    $0x2c,%esp
f01003d7:	5b                   	pop    %ebx
f01003d8:	5e                   	pop    %esi
f01003d9:	5f                   	pop    %edi
f01003da:	5d                   	pop    %ebp
f01003db:	c3                   	ret    

f01003dc <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003dc:	55                   	push   %ebp
f01003dd:	89 e5                	mov    %esp,%ebp
f01003df:	53                   	push   %ebx
f01003e0:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e3:	ba 64 00 00 00       	mov    $0x64,%edx
f01003e8:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003e9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003ee:	a8 01                	test   $0x1,%al
f01003f0:	0f 84 de 00 00 00    	je     f01004d4 <kbd_proc_data+0xf8>
f01003f6:	b2 60                	mov    $0x60,%dl
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003fb:	3c e0                	cmp    $0xe0,%al
f01003fd:	75 11                	jne    f0100410 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f01003ff:	83 0d 28 25 11 f0 40 	orl    $0x40,0xf0112528
		return 0;
f0100406:	bb 00 00 00 00       	mov    $0x0,%ebx
f010040b:	e9 c4 00 00 00       	jmp    f01004d4 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100410:	84 c0                	test   %al,%al
f0100412:	79 37                	jns    f010044b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100414:	8b 0d 28 25 11 f0    	mov    0xf0112528,%ecx
f010041a:	89 cb                	mov    %ecx,%ebx
f010041c:	83 e3 40             	and    $0x40,%ebx
f010041f:	83 e0 7f             	and    $0x7f,%eax
f0100422:	85 db                	test   %ebx,%ebx
f0100424:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100427:	0f b6 d2             	movzbl %dl,%edx
f010042a:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f0100431:	83 c8 40             	or     $0x40,%eax
f0100434:	0f b6 c0             	movzbl %al,%eax
f0100437:	f7 d0                	not    %eax
f0100439:	21 c1                	and    %eax,%ecx
f010043b:	89 0d 28 25 11 f0    	mov    %ecx,0xf0112528
		return 0;
f0100441:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100446:	e9 89 00 00 00       	jmp    f01004d4 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010044b:	8b 0d 28 25 11 f0    	mov    0xf0112528,%ecx
f0100451:	f6 c1 40             	test   $0x40,%cl
f0100454:	74 0e                	je     f0100464 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100456:	89 c2                	mov    %eax,%edx
f0100458:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010045b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010045e:	89 0d 28 25 11 f0    	mov    %ecx,0xf0112528
	}

	shift |= shiftcode[data];
f0100464:	0f b6 d2             	movzbl %dl,%edx
f0100467:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f010046e:	0b 05 28 25 11 f0    	or     0xf0112528,%eax
	shift ^= togglecode[data];
f0100474:	0f b6 8a 60 1b 10 f0 	movzbl -0xfefe4a0(%edx),%ecx
f010047b:	31 c8                	xor    %ecx,%eax
f010047d:	a3 28 25 11 f0       	mov    %eax,0xf0112528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100482:	89 c1                	mov    %eax,%ecx
f0100484:	83 e1 03             	and    $0x3,%ecx
f0100487:	8b 0c 8d 60 1c 10 f0 	mov    -0xfefe3a0(,%ecx,4),%ecx
f010048e:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100492:	a8 08                	test   $0x8,%al
f0100494:	74 19                	je     f01004af <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100496:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100499:	83 fa 19             	cmp    $0x19,%edx
f010049c:	77 05                	ja     f01004a3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010049e:	83 eb 20             	sub    $0x20,%ebx
f01004a1:	eb 0c                	jmp    f01004af <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01004a3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01004a6:	8d 53 20             	lea    0x20(%ebx),%edx
f01004a9:	83 f9 19             	cmp    $0x19,%ecx
f01004ac:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004af:	f7 d0                	not    %eax
f01004b1:	a8 06                	test   $0x6,%al
f01004b3:	75 1f                	jne    f01004d4 <kbd_proc_data+0xf8>
f01004b5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004bb:	75 17                	jne    f01004d4 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01004bd:	c7 04 24 24 1a 10 f0 	movl   $0xf0101a24,(%esp)
f01004c4:	e8 01 05 00 00       	call   f01009ca <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c9:	ba 92 00 00 00       	mov    $0x92,%edx
f01004ce:	b8 03 00 00 00       	mov    $0x3,%eax
f01004d3:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004d4:	89 d8                	mov    %ebx,%eax
f01004d6:	83 c4 14             	add    $0x14,%esp
f01004d9:	5b                   	pop    %ebx
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    

f01004dc <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004dc:	55                   	push   %ebp
f01004dd:	89 e5                	mov    %esp,%ebp
f01004df:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004e2:	80 3d 00 23 11 f0 00 	cmpb   $0x0,0xf0112300
f01004e9:	74 0a                	je     f01004f5 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004eb:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f01004f0:	e8 d5 fc ff ff       	call   f01001ca <cons_intr>
}
f01004f5:	c9                   	leave  
f01004f6:	c3                   	ret    

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 dc 03 10 f0       	mov    $0xf01003dc,%eax
f0100502:	e8 c3 fc ff ff       	call   f01001ca <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c8 ff ff ff       	call   f01004dc <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010051f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100524:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f010052a:	74 1e                	je     f010054a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010052c:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
f0100533:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100536:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100541:	0f 44 d1             	cmove  %ecx,%edx
f0100544:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
		return c;
	}
	return 0;
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	57                   	push   %edi
f0100550:	56                   	push   %esi
f0100551:	53                   	push   %ebx
f0100552:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100555:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010055c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100563:	5a a5 
	if (*cp != 0xA55A) {
f0100565:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010056c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100570:	74 11                	je     f0100583 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100572:	c7 05 2c 25 11 f0 b4 	movl   $0x3b4,0xf011252c
f0100579:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010057c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100581:	eb 16                	jmp    f0100599 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100583:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010058a:	c7 05 2c 25 11 f0 d4 	movl   $0x3d4,0xf011252c
f0100591:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100594:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100599:	8b 0d 2c 25 11 f0    	mov    0xf011252c,%ecx
f010059f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a4:	89 ca                	mov    %ecx,%edx
f01005a6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005a7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005aa:	89 da                	mov    %ebx,%edx
f01005ac:	ec                   	in     (%dx),%al
f01005ad:	0f b6 f8             	movzbl %al,%edi
f01005b0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b8:	89 ca                	mov    %ecx,%edx
f01005ba:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bb:	89 da                	mov    %ebx,%edx
f01005bd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005be:	89 35 30 25 11 f0    	mov    %esi,0xf0112530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005c4:	0f b6 d8             	movzbl %al,%ebx
f01005c7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005c9:	66 89 3d 34 25 11 f0 	mov    %di,0xf0112534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005da:	89 da                	mov    %ebx,%edx
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	b2 fb                	mov    $0xfb,%dl
f01005df:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005e4:	ee                   	out    %al,(%dx)
f01005e5:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005ea:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ef:	89 ca                	mov    %ecx,%edx
f01005f1:	ee                   	out    %al,(%dx)
f01005f2:	b2 f9                	mov    $0xf9,%dl
f01005f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	b2 fb                	mov    $0xfb,%dl
f01005fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b2 fc                	mov    $0xfc,%dl
f0100604:	b8 00 00 00 00       	mov    $0x0,%eax
f0100609:	ee                   	out    %al,(%dx)
f010060a:	b2 f9                	mov    $0xf9,%dl
f010060c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100611:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100612:	b2 fd                	mov    $0xfd,%dl
f0100614:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100615:	3c ff                	cmp    $0xff,%al
f0100617:	0f 95 c0             	setne  %al
f010061a:	89 c6                	mov    %eax,%esi
f010061c:	a2 00 23 11 f0       	mov    %al,0xf0112300
f0100621:	89 da                	mov    %ebx,%edx
f0100623:	ec                   	in     (%dx),%al
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100627:	89 f0                	mov    %esi,%eax
f0100629:	84 c0                	test   %al,%al
f010062b:	75 0c                	jne    f0100639 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010062d:	c7 04 24 30 1a 10 f0 	movl   $0xf0101a30,(%esp)
f0100634:	e8 91 03 00 00       	call   f01009ca <cprintf>
}
f0100639:	83 c4 1c             	add    $0x1c,%esp
f010063c:	5b                   	pop    %ebx
f010063d:	5e                   	pop    %esi
f010063e:	5f                   	pop    %edi
f010063f:	5d                   	pop    %ebp
f0100640:	c3                   	ret    

f0100641 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100641:	55                   	push   %ebp
f0100642:	89 e5                	mov    %esp,%ebp
f0100644:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100647:	8b 45 08             	mov    0x8(%ebp),%eax
f010064a:	e8 b8 fb ff ff       	call   f0100207 <cons_putc>
}
f010064f:	c9                   	leave  
f0100650:	c3                   	ret    

f0100651 <getchar>:

int
getchar(void)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100657:	e8 ad fe ff ff       	call   f0100509 <cons_getc>
f010065c:	85 c0                	test   %eax,%eax
f010065e:	74 f7                	je     f0100657 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100660:	c9                   	leave  
f0100661:	c3                   	ret    

f0100662 <iscons>:

int
iscons(int fdnum)
{
f0100662:	55                   	push   %ebp
f0100663:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100665:	b8 01 00 00 00       	mov    $0x1,%eax
f010066a:	5d                   	pop    %ebp
f010066b:	c3                   	ret    
f010066c:	00 00                	add    %al,(%eax)
	...

f0100670 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100670:	55                   	push   %ebp
f0100671:	89 e5                	mov    %esp,%ebp
f0100673:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100676:	c7 04 24 70 1c 10 f0 	movl   $0xf0101c70,(%esp)
f010067d:	e8 48 03 00 00       	call   f01009ca <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100682:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100689:	00 
f010068a:	c7 04 24 30 1d 10 f0 	movl   $0xf0101d30,(%esp)
f0100691:	e8 34 03 00 00       	call   f01009ca <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100696:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010069d:	00 
f010069e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006a5:	f0 
f01006a6:	c7 04 24 58 1d 10 f0 	movl   $0xf0101d58,(%esp)
f01006ad:	e8 18 03 00 00       	call   f01009ca <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b2:	c7 44 24 08 85 19 10 	movl   $0x101985,0x8(%esp)
f01006b9:	00 
f01006ba:	c7 44 24 04 85 19 10 	movl   $0xf0101985,0x4(%esp)
f01006c1:	f0 
f01006c2:	c7 04 24 7c 1d 10 f0 	movl   $0xf0101d7c,(%esp)
f01006c9:	e8 fc 02 00 00       	call   f01009ca <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ce:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f01006d5:	00 
f01006d6:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f01006dd:	f0 
f01006de:	c7 04 24 a0 1d 10 f0 	movl   $0xf0101da0,(%esp)
f01006e5:	e8 e0 02 00 00       	call   f01009ca <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ea:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f01006f1:	00 
f01006f2:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f01006f9:	f0 
f01006fa:	c7 04 24 c4 1d 10 f0 	movl   $0xf0101dc4,(%esp)
f0100701:	e8 c4 02 00 00       	call   f01009ca <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100706:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010070b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100710:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100715:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010071b:	85 c0                	test   %eax,%eax
f010071d:	0f 48 c2             	cmovs  %edx,%eax
f0100720:	c1 f8 0a             	sar    $0xa,%eax
f0100723:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100727:	c7 04 24 e8 1d 10 f0 	movl   $0xf0101de8,(%esp)
f010072e:	e8 97 02 00 00       	call   f01009ca <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100733:	b8 00 00 00 00       	mov    $0x0,%eax
f0100738:	c9                   	leave  
f0100739:	c3                   	ret    

f010073a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010073a:	55                   	push   %ebp
f010073b:	89 e5                	mov    %esp,%ebp
f010073d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100740:	c7 44 24 08 89 1c 10 	movl   $0xf0101c89,0x8(%esp)
f0100747:	f0 
f0100748:	c7 44 24 04 a7 1c 10 	movl   $0xf0101ca7,0x4(%esp)
f010074f:	f0 
f0100750:	c7 04 24 ac 1c 10 f0 	movl   $0xf0101cac,(%esp)
f0100757:	e8 6e 02 00 00       	call   f01009ca <cprintf>
f010075c:	c7 44 24 08 14 1e 10 	movl   $0xf0101e14,0x8(%esp)
f0100763:	f0 
f0100764:	c7 44 24 04 b5 1c 10 	movl   $0xf0101cb5,0x4(%esp)
f010076b:	f0 
f010076c:	c7 04 24 ac 1c 10 f0 	movl   $0xf0101cac,(%esp)
f0100773:	e8 52 02 00 00       	call   f01009ca <cprintf>
	return 0;
}
f0100778:	b8 00 00 00 00       	mov    $0x0,%eax
f010077d:	c9                   	leave  
f010077e:	c3                   	ret    

f010077f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	struct Eipdebuginfo info;
f010077f:	55                   	push   %ebp
f0100780:	89 e5                	mov    %esp,%ebp
f0100782:	57                   	push   %edi
f0100783:	56                   	push   %esi
f0100784:	53                   	push   %ebx
f0100785:	83 ec 5c             	sub    $0x5c,%esp
	unsigned int *ebp=(unsigned int *)read_ebp();
f0100788:	89 ee                	mov    %ebp,%esi

static __inline uint32_t
read_esp(void)
{
	uint32_t esp;
	__asm __volatile("movl %%esp,%0" : "=r" (esp));
f010078a:	89 e0                	mov    %esp,%eax
	while(ebp)
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f010078c:	8d 7d d0             	lea    -0x30(%ebp),%edi
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	//esp=ebp+2;
	//ebp=(unsigned int *)*ebp;
	while(ebp)
f010078f:	e9 9c 00 00 00       	jmp    f0100830 <mon_backtrace+0xb1>
f0100794:	b8 00 00 00 00       	mov    $0x0,%eax
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
f0100799:	8b 54 86 08          	mov    0x8(%esi,%eax,4),%edx
f010079d:	89 54 85 bc          	mov    %edx,-0x44(%ebp,%eax,4)
	int i=0;
	//esp=ebp+2;
	//ebp=(unsigned int *)*ebp;
	while(ebp)
	{		
			for(i=0;i<5;i++)
f01007a1:	83 c0 01             	add    $0x1,%eax
f01007a4:	83 f8 05             	cmp    $0x5,%eax
f01007a7:	75 f0                	jne    f0100799 <mon_backtrace+0x1a>
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f01007a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01007ad:	8b 46 04             	mov    0x4(%esi),%eax
f01007b0:	89 04 24             	mov    %eax,(%esp)
f01007b3:	e8 18 03 00 00       	call   f0100ad0 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f01007b8:	8b 46 04             	mov    0x4(%esi),%eax
f01007bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007bf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007c3:	c7 04 24 be 1c 10 f0 	movl   $0xf0101cbe,(%esp)
f01007ca:	e8 fb 01 00 00       	call   f01009ca <cprintf>
			for(i=0;i<5;++i)
f01007cf:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%08x  ", arg[i]);
f01007d4:	8b 44 9d bc          	mov    -0x44(%ebp,%ebx,4),%eax
f01007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007dc:	c7 04 24 d9 1c 10 f0 	movl   $0xf0101cd9,(%esp)
f01007e3:	e8 e2 01 00 00       	call   f01009ca <cprintf>
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
			for(i=0;i<5;++i)
f01007e8:	83 c3 01             	add    $0x1,%ebx
f01007eb:	83 fb 05             	cmp    $0x5,%ebx
f01007ee:	75 e4                	jne    f01007d4 <mon_backtrace+0x55>
			cprintf("%08x  ", arg[i]);
			cprintf("\n");
f01007f0:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f01007f7:	e8 ce 01 00 00       	call   f01009ca <cprintf>
			
			cprintf("\t\t%s:%u:%.*s+%u\n",
f01007fc:	8b 46 04             	mov    0x4(%esi),%eax
f01007ff:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100802:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100806:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100809:	89 44 24 10          	mov    %eax,0x10(%esp)
f010080d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100810:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100814:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100817:	89 44 24 08          	mov    %eax,0x8(%esp)
f010081b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010081e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100822:	c7 04 24 e0 1c 10 f0 	movl   $0xf0101ce0,(%esp)
f0100829:	e8 9c 01 00 00       	call   f01009ca <cprintf>
				info.eip_line,
				info.eip_fn_namelen,
				info.eip_fn_name,
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
f010082e:	8b 36                	mov    (%esi),%esi
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	//esp=ebp+2;
	//ebp=(unsigned int *)*ebp;
	while(ebp)
f0100830:	85 f6                	test   %esi,%esi
f0100832:	0f 85 5c ff ff ff    	jne    f0100794 <mon_backtrace+0x15>
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
	}
	return 0;
}
f0100838:	b8 00 00 00 00       	mov    $0x0,%eax
f010083d:	83 c4 5c             	add    $0x5c,%esp
f0100840:	5b                   	pop    %ebx
f0100841:	5e                   	pop    %esi
f0100842:	5f                   	pop    %edi
f0100843:	5d                   	pop    %ebp
f0100844:	c3                   	ret    

f0100845 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100845:	55                   	push   %ebp
f0100846:	89 e5                	mov    %esp,%ebp
f0100848:	57                   	push   %edi
f0100849:	56                   	push   %esi
f010084a:	53                   	push   %ebx
f010084b:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010084e:	c7 04 24 3c 1e 10 f0 	movl   $0xf0101e3c,(%esp)
f0100855:	e8 70 01 00 00       	call   f01009ca <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010085a:	c7 04 24 60 1e 10 f0 	movl   $0xf0101e60,(%esp)
f0100861:	e8 64 01 00 00       	call   f01009ca <cprintf>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100866:	8d 7d a8             	lea    -0x58(%ebp),%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100869:	c7 04 24 f1 1c 10 f0 	movl   $0xf0101cf1,(%esp)
f0100870:	e8 eb 09 00 00       	call   f0101260 <readline>
f0100875:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100877:	85 c0                	test   %eax,%eax
f0100879:	74 ee                	je     f0100869 <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010087b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100882:	be 00 00 00 00       	mov    $0x0,%esi
f0100887:	eb 06                	jmp    f010088f <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100889:	c6 03 00             	movb   $0x0,(%ebx)
f010088c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010088f:	0f b6 03             	movzbl (%ebx),%eax
f0100892:	84 c0                	test   %al,%al
f0100894:	74 63                	je     f01008f9 <monitor+0xb4>
f0100896:	0f be c0             	movsbl %al,%eax
f0100899:	89 44 24 04          	mov    %eax,0x4(%esp)
f010089d:	c7 04 24 f5 1c 10 f0 	movl   $0xf0101cf5,(%esp)
f01008a4:	e8 cd 0b 00 00       	call   f0101476 <strchr>
f01008a9:	85 c0                	test   %eax,%eax
f01008ab:	75 dc                	jne    f0100889 <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f01008ad:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008b0:	74 47                	je     f01008f9 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008b2:	83 fe 0f             	cmp    $0xf,%esi
f01008b5:	75 16                	jne    f01008cd <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008b7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008be:	00 
f01008bf:	c7 04 24 fa 1c 10 f0 	movl   $0xf0101cfa,(%esp)
f01008c6:	e8 ff 00 00 00       	call   f01009ca <cprintf>
f01008cb:	eb 9c                	jmp    f0100869 <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f01008cd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008d1:	83 c6 01             	add    $0x1,%esi
f01008d4:	eb 03                	jmp    f01008d9 <monitor+0x94>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008d6:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008d9:	0f b6 03             	movzbl (%ebx),%eax
f01008dc:	84 c0                	test   %al,%al
f01008de:	74 af                	je     f010088f <monitor+0x4a>
f01008e0:	0f be c0             	movsbl %al,%eax
f01008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e7:	c7 04 24 f5 1c 10 f0 	movl   $0xf0101cf5,(%esp)
f01008ee:	e8 83 0b 00 00       	call   f0101476 <strchr>
f01008f3:	85 c0                	test   %eax,%eax
f01008f5:	74 df                	je     f01008d6 <monitor+0x91>
f01008f7:	eb 96                	jmp    f010088f <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f01008f9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100900:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100901:	85 f6                	test   %esi,%esi
f0100903:	0f 84 60 ff ff ff    	je     f0100869 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100909:	c7 44 24 04 a7 1c 10 	movl   $0xf0101ca7,0x4(%esp)
f0100910:	f0 
f0100911:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100914:	89 04 24             	mov    %eax,(%esp)
f0100917:	e8 fb 0a 00 00       	call   f0101417 <strcmp>
f010091c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100921:	85 c0                	test   %eax,%eax
f0100923:	74 1c                	je     f0100941 <monitor+0xfc>
f0100925:	c7 44 24 04 b5 1c 10 	movl   $0xf0101cb5,0x4(%esp)
f010092c:	f0 
f010092d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100930:	89 04 24             	mov    %eax,(%esp)
f0100933:	e8 df 0a 00 00       	call   f0101417 <strcmp>
f0100938:	85 c0                	test   %eax,%eax
f010093a:	75 28                	jne    f0100964 <monitor+0x11f>
f010093c:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100941:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100944:	01 c2                	add    %eax,%edx
f0100946:	8b 45 08             	mov    0x8(%ebp),%eax
f0100949:	89 44 24 08          	mov    %eax,0x8(%esp)
f010094d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100951:	89 34 24             	mov    %esi,(%esp)
f0100954:	ff 14 95 90 1e 10 f0 	call   *-0xfefe170(,%edx,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010095b:	85 c0                	test   %eax,%eax
f010095d:	78 1d                	js     f010097c <monitor+0x137>
f010095f:	e9 05 ff ff ff       	jmp    f0100869 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100964:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100967:	89 44 24 04          	mov    %eax,0x4(%esp)
f010096b:	c7 04 24 17 1d 10 f0 	movl   $0xf0101d17,(%esp)
f0100972:	e8 53 00 00 00       	call   f01009ca <cprintf>
f0100977:	e9 ed fe ff ff       	jmp    f0100869 <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010097c:	83 c4 5c             	add    $0x5c,%esp
f010097f:	5b                   	pop    %ebx
f0100980:	5e                   	pop    %esi
f0100981:	5f                   	pop    %edi
f0100982:	5d                   	pop    %ebp
f0100983:	c3                   	ret    

f0100984 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100984:	55                   	push   %ebp
f0100985:	89 e5                	mov    %esp,%ebp
f0100987:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010098a:	8b 45 08             	mov    0x8(%ebp),%eax
f010098d:	89 04 24             	mov    %eax,(%esp)
f0100990:	e8 ac fc ff ff       	call   f0100641 <cputchar>
	*cnt++;
}
f0100995:	c9                   	leave  
f0100996:	c3                   	ret    

f0100997 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100997:	55                   	push   %ebp
f0100998:	89 e5                	mov    %esp,%ebp
f010099a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010099d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01009ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b9:	c7 04 24 84 09 10 f0 	movl   $0xf0100984,(%esp)
f01009c0:	e8 38 04 00 00       	call   f0100dfd <vprintfmt>
	return cnt;
}
f01009c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009c8:	c9                   	leave  
f01009c9:	c3                   	ret    

f01009ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009ca:	55                   	push   %ebp
f01009cb:	89 e5                	mov    %esp,%ebp
f01009cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01009da:	89 04 24             	mov    %eax,(%esp)
f01009dd:	e8 b5 ff ff ff       	call   f0100997 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009e2:	c9                   	leave  
f01009e3:	c3                   	ret    
	...

f01009f0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	57                   	push   %edi
f01009f4:	56                   	push   %esi
f01009f5:	53                   	push   %ebx
f01009f6:	83 ec 10             	sub    $0x10,%esp
f01009f9:	89 c3                	mov    %eax,%ebx
f01009fb:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01009fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100a01:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a04:	8b 0a                	mov    (%edx),%ecx
f0100a06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a09:	8b 00                	mov    (%eax),%eax
f0100a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a0e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100a15:	eb 77                	jmp    f0100a8e <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a1a:	01 c8                	add    %ecx,%eax
f0100a1c:	bf 02 00 00 00       	mov    $0x2,%edi
f0100a21:	99                   	cltd   
f0100a22:	f7 ff                	idiv   %edi
f0100a24:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a26:	eb 01                	jmp    f0100a29 <stab_binsearch+0x39>
			m--;
f0100a28:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a29:	39 ca                	cmp    %ecx,%edx
f0100a2b:	7c 1d                	jl     f0100a4a <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a2d:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a30:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100a35:	39 f7                	cmp    %esi,%edi
f0100a37:	75 ef                	jne    f0100a28 <stab_binsearch+0x38>
f0100a39:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a3c:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100a3f:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100a43:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a46:	73 18                	jae    f0100a60 <stab_binsearch+0x70>
f0100a48:	eb 05                	jmp    f0100a4f <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a4a:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100a4d:	eb 3f                	jmp    f0100a8e <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100a52:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100a54:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a57:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a5e:	eb 2e                	jmp    f0100a8e <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a60:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a63:	76 15                	jbe    f0100a7a <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100a65:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100a68:	4f                   	dec    %edi
f0100a69:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a6f:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a71:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a78:	eb 14                	jmp    f0100a8e <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a7a:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100a7d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100a80:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100a82:	ff 45 0c             	incl   0xc(%ebp)
f0100a85:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a87:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a8e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100a91:	7e 84                	jle    f0100a17 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a93:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100a97:	75 0d                	jne    f0100aa6 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100a99:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a9c:	8b 02                	mov    (%edx),%eax
f0100a9e:	48                   	dec    %eax
f0100a9f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100aa2:	89 01                	mov    %eax,(%ecx)
f0100aa4:	eb 22                	jmp    f0100ac8 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100aa6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100aa9:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100aab:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100aae:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab0:	eb 01                	jmp    f0100ab3 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100ab2:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab3:	39 c1                	cmp    %eax,%ecx
f0100ab5:	7d 0c                	jge    f0100ac3 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100ab7:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100aba:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100abf:	39 f2                	cmp    %esi,%edx
f0100ac1:	75 ef                	jne    f0100ab2 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ac3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100ac6:	89 02                	mov    %eax,(%edx)
	}
}
f0100ac8:	83 c4 10             	add    $0x10,%esp
f0100acb:	5b                   	pop    %ebx
f0100acc:	5e                   	pop    %esi
f0100acd:	5f                   	pop    %edi
f0100ace:	5d                   	pop    %ebp
f0100acf:	c3                   	ret    

f0100ad0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	83 ec 38             	sub    $0x38,%esp
f0100ad6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100ad9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100adc:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100adf:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ae5:	c7 03 a0 1e 10 f0    	movl   $0xf0101ea0,(%ebx)
	info->eip_line = 0;
f0100aeb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100af2:	c7 43 08 a0 1e 10 f0 	movl   $0xf0101ea0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100af9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b00:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b03:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b0a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b10:	76 12                	jbe    f0100b24 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b12:	b8 e2 75 10 f0       	mov    $0xf01075e2,%eax
f0100b17:	3d 85 5c 10 f0       	cmp    $0xf0105c85,%eax
f0100b1c:	0f 86 5a 01 00 00    	jbe    f0100c7c <debuginfo_eip+0x1ac>
f0100b22:	eb 1c                	jmp    f0100b40 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b24:	c7 44 24 08 aa 1e 10 	movl   $0xf0101eaa,0x8(%esp)
f0100b2b:	f0 
f0100b2c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100b33:	00 
f0100b34:	c7 04 24 b7 1e 10 f0 	movl   $0xf0101eb7,(%esp)
f0100b3b:	e8 b8 f5 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b45:	80 3d e1 75 10 f0 00 	cmpb   $0x0,0xf01075e1
f0100b4c:	0f 85 36 01 00 00    	jne    f0100c88 <debuginfo_eip+0x1b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b59:	b8 84 5c 10 f0       	mov    $0xf0105c84,%eax
f0100b5e:	2d f0 20 10 f0       	sub    $0xf01020f0,%eax
f0100b63:	c1 f8 02             	sar    $0x2,%eax
f0100b66:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b6c:	83 e8 01             	sub    $0x1,%eax
f0100b6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b76:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100b7d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b80:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b83:	b8 f0 20 10 f0       	mov    $0xf01020f0,%eax
f0100b88:	e8 63 fe ff ff       	call   f01009f0 <stab_binsearch>
	if (lfile == 0)
f0100b8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100b95:	85 d2                	test   %edx,%edx
f0100b97:	0f 84 eb 00 00 00    	je     f0100c88 <debuginfo_eip+0x1b8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100ba0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ba6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100baa:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100bb1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb7:	b8 f0 20 10 f0       	mov    $0xf01020f0,%eax
f0100bbc:	e8 2f fe ff ff       	call   f01009f0 <stab_binsearch>

	if (lfun <= rfun) {
f0100bc1:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100bc4:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100bc7:	7f 2e                	jg     f0100bf7 <debuginfo_eip+0x127>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bc9:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100bcc:	8d 90 f0 20 10 f0    	lea    -0xfefdf10(%eax),%edx
f0100bd2:	8b 80 f0 20 10 f0    	mov    -0xfefdf10(%eax),%eax
f0100bd8:	b9 e2 75 10 f0       	mov    $0xf01075e2,%ecx
f0100bdd:	81 e9 85 5c 10 f0    	sub    $0xf0105c85,%ecx
f0100be3:	39 c8                	cmp    %ecx,%eax
f0100be5:	73 08                	jae    f0100bef <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100be7:	05 85 5c 10 f0       	add    $0xf0105c85,%eax
f0100bec:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bef:	8b 42 08             	mov    0x8(%edx),%eax
f0100bf2:	89 43 10             	mov    %eax,0x10(%ebx)
f0100bf5:	eb 06                	jmp    f0100bfd <debuginfo_eip+0x12d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bf7:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bfd:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100c04:	00 
f0100c05:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c08:	89 04 24             	mov    %eax,(%esp)
f0100c0b:	e8 87 08 00 00       	call   f0101497 <strfind>
f0100c10:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c13:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100c19:	eb 03                	jmp    f0100c1e <debuginfo_eip+0x14e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100c1b:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c1e:	39 cf                	cmp    %ecx,%edi
f0100c20:	7c 27                	jl     f0100c49 <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f0100c22:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100c25:	8d 14 85 f0 20 10 f0 	lea    -0xfefdf10(,%eax,4),%edx
f0100c2c:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100c30:	3c 84                	cmp    $0x84,%al
f0100c32:	74 61                	je     f0100c95 <debuginfo_eip+0x1c5>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c34:	3c 64                	cmp    $0x64,%al
f0100c36:	75 e3                	jne    f0100c1b <debuginfo_eip+0x14b>
f0100c38:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100c3c:	74 dd                	je     f0100c1b <debuginfo_eip+0x14b>
f0100c3e:	66 90                	xchg   %ax,%ax
f0100c40:	eb 53                	jmp    f0100c95 <debuginfo_eip+0x1c5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c42:	05 85 5c 10 f0       	add    $0xf0105c85,%eax
f0100c47:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c49:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c4f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c54:	39 d1                	cmp    %edx,%ecx
f0100c56:	7d 30                	jge    f0100c88 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
f0100c58:	8d 41 01             	lea    0x1(%ecx),%eax
f0100c5b:	eb 07                	jmp    f0100c64 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c5d:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100c61:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c64:	39 d0                	cmp    %edx,%eax
f0100c66:	74 1b                	je     f0100c83 <debuginfo_eip+0x1b3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c68:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100c6b:	80 3c 8d f4 20 10 f0 	cmpb   $0xa0,-0xfefdf0c(,%ecx,4)
f0100c72:	a0 
f0100c73:	74 e8                	je     f0100c5d <debuginfo_eip+0x18d>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c75:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7a:	eb 0c                	jmp    f0100c88 <debuginfo_eip+0x1b8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c81:	eb 05                	jmp    f0100c88 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c88:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100c8b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100c8e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100c91:	89 ec                	mov    %ebp,%esp
f0100c93:	5d                   	pop    %ebp
f0100c94:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c95:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c98:	8b 87 f0 20 10 f0    	mov    -0xfefdf10(%edi),%eax
f0100c9e:	ba e2 75 10 f0       	mov    $0xf01075e2,%edx
f0100ca3:	81 ea 85 5c 10 f0    	sub    $0xf0105c85,%edx
f0100ca9:	39 d0                	cmp    %edx,%eax
f0100cab:	72 95                	jb     f0100c42 <debuginfo_eip+0x172>
f0100cad:	eb 9a                	jmp    f0100c49 <debuginfo_eip+0x179>
	...

f0100cb0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cb0:	55                   	push   %ebp
f0100cb1:	89 e5                	mov    %esp,%ebp
f0100cb3:	57                   	push   %edi
f0100cb4:	56                   	push   %esi
f0100cb5:	53                   	push   %ebx
f0100cb6:	83 ec 3c             	sub    $0x3c,%esp
f0100cb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cbc:	89 d7                	mov    %edx,%edi
f0100cbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cc1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cca:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100ccd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	75 08                	jne    f0100cdc <printnum+0x2c>
f0100cd4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd7:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cda:	77 59                	ja     f0100d35 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cdc:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100ce0:	83 eb 01             	sub    $0x1,%ebx
f0100ce3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100ce7:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cea:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cee:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100cf2:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100cf6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100cfd:	00 
f0100cfe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d01:	89 04 24             	mov    %eax,(%esp)
f0100d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d0b:	e8 d0 09 00 00       	call   f01016e0 <__udivdi3>
f0100d10:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100d14:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d18:	89 04 24             	mov    %eax,(%esp)
f0100d1b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d1f:	89 fa                	mov    %edi,%edx
f0100d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d24:	e8 87 ff ff ff       	call   f0100cb0 <printnum>
f0100d29:	eb 11                	jmp    f0100d3c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d2f:	89 34 24             	mov    %esi,(%esp)
f0100d32:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d35:	83 eb 01             	sub    $0x1,%ebx
f0100d38:	85 db                	test   %ebx,%ebx
f0100d3a:	7f ef                	jg     f0100d2b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d40:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100d44:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d47:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d4b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100d52:	00 
f0100d53:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d56:	89 04 24             	mov    %eax,(%esp)
f0100d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d60:	e8 ab 0a 00 00       	call   f0101810 <__umoddi3>
f0100d65:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d69:	0f be 80 c5 1e 10 f0 	movsbl -0xfefe13b(%eax),%eax
f0100d70:	89 04 24             	mov    %eax,(%esp)
f0100d73:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d76:	83 c4 3c             	add    $0x3c,%esp
f0100d79:	5b                   	pop    %ebx
f0100d7a:	5e                   	pop    %esi
f0100d7b:	5f                   	pop    %edi
f0100d7c:	5d                   	pop    %ebp
f0100d7d:	c3                   	ret    

f0100d7e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d7e:	55                   	push   %ebp
f0100d7f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d81:	83 fa 01             	cmp    $0x1,%edx
f0100d84:	7e 0e                	jle    f0100d94 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d86:	8b 10                	mov    (%eax),%edx
f0100d88:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d8b:	89 08                	mov    %ecx,(%eax)
f0100d8d:	8b 02                	mov    (%edx),%eax
f0100d8f:	8b 52 04             	mov    0x4(%edx),%edx
f0100d92:	eb 22                	jmp    f0100db6 <getuint+0x38>
	else if (lflag)
f0100d94:	85 d2                	test   %edx,%edx
f0100d96:	74 10                	je     f0100da8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d98:	8b 10                	mov    (%eax),%edx
f0100d9a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d9d:	89 08                	mov    %ecx,(%eax)
f0100d9f:	8b 02                	mov    (%edx),%eax
f0100da1:	ba 00 00 00 00       	mov    $0x0,%edx
f0100da6:	eb 0e                	jmp    f0100db6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100da8:	8b 10                	mov    (%eax),%edx
f0100daa:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dad:	89 08                	mov    %ecx,(%eax)
f0100daf:	8b 02                	mov    (%edx),%eax
f0100db1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100db6:	5d                   	pop    %ebp
f0100db7:	c3                   	ret    

f0100db8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100db8:	55                   	push   %ebp
f0100db9:	89 e5                	mov    %esp,%ebp
f0100dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dbe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dc2:	8b 10                	mov    (%eax),%edx
f0100dc4:	3b 50 04             	cmp    0x4(%eax),%edx
f0100dc7:	73 0a                	jae    f0100dd3 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100dcc:	88 0a                	mov    %cl,(%edx)
f0100dce:	83 c2 01             	add    $0x1,%edx
f0100dd1:	89 10                	mov    %edx,(%eax)
}
f0100dd3:	5d                   	pop    %ebp
f0100dd4:	c3                   	ret    

f0100dd5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100dd5:	55                   	push   %ebp
f0100dd6:	89 e5                	mov    %esp,%ebp
f0100dd8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100ddb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dde:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100de2:	8b 45 10             	mov    0x10(%ebp),%eax
f0100de5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100de9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100df0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100df3:	89 04 24             	mov    %eax,(%esp)
f0100df6:	e8 02 00 00 00       	call   f0100dfd <vprintfmt>
	va_end(ap);
}
f0100dfb:	c9                   	leave  
f0100dfc:	c3                   	ret    

f0100dfd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dfd:	55                   	push   %ebp
f0100dfe:	89 e5                	mov    %esp,%ebp
f0100e00:	57                   	push   %edi
f0100e01:	56                   	push   %esi
f0100e02:	53                   	push   %ebx
f0100e03:	83 ec 4c             	sub    $0x4c,%esp
f0100e06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e09:	8b 75 10             	mov    0x10(%ebp),%esi
f0100e0c:	eb 12                	jmp    f0100e20 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e0e:	85 c0                	test   %eax,%eax
f0100e10:	0f 84 bf 03 00 00    	je     f01011d5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f0100e16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e1a:	89 04 24             	mov    %eax,(%esp)
f0100e1d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e20:	0f b6 06             	movzbl (%esi),%eax
f0100e23:	83 c6 01             	add    $0x1,%esi
f0100e26:	83 f8 25             	cmp    $0x25,%eax
f0100e29:	75 e3                	jne    f0100e0e <vprintfmt+0x11>
f0100e2b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100e2f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100e36:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100e3b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100e42:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e47:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e4a:	eb 2b                	jmp    f0100e77 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e4f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100e53:	eb 22                	jmp    f0100e77 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e55:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e58:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100e5c:	eb 19                	jmp    f0100e77 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100e61:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e68:	eb 0d                	jmp    f0100e77 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100e6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e70:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e77:	0f b6 16             	movzbl (%esi),%edx
f0100e7a:	0f b6 c2             	movzbl %dl,%eax
f0100e7d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e80:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100e83:	83 ea 23             	sub    $0x23,%edx
f0100e86:	80 fa 55             	cmp    $0x55,%dl
f0100e89:	0f 87 28 03 00 00    	ja     f01011b7 <vprintfmt+0x3ba>
f0100e8f:	0f b6 d2             	movzbl %dl,%edx
f0100e92:	ff 24 95 60 1f 10 f0 	jmp    *-0xfefe0a0(,%edx,4)
f0100e99:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e9c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100ea3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100ea8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100eab:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100eaf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100eb2:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100eb5:	83 fa 09             	cmp    $0x9,%edx
f0100eb8:	77 2f                	ja     f0100ee9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100eba:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ebd:	eb e9                	jmp    f0100ea8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100ebf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ec2:	8d 50 04             	lea    0x4(%eax),%edx
f0100ec5:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ec8:	8b 00                	mov    (%eax),%eax
f0100eca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ed0:	eb 1a                	jmp    f0100eec <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0100ed5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ed9:	79 9c                	jns    f0100e77 <vprintfmt+0x7a>
f0100edb:	eb 81                	jmp    f0100e5e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100edd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ee0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100ee7:	eb 8e                	jmp    f0100e77 <vprintfmt+0x7a>
f0100ee9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0100eec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ef0:	79 85                	jns    f0100e77 <vprintfmt+0x7a>
f0100ef2:	e9 73 ff ff ff       	jmp    f0100e6a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ef7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100efa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100efd:	e9 75 ff ff ff       	jmp    f0100e77 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f02:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f05:	8d 50 04             	lea    0x4(%eax),%edx
f0100f08:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f0f:	8b 00                	mov    (%eax),%eax
f0100f11:	89 04 24             	mov    %eax,(%esp)
f0100f14:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f17:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f1a:	e9 01 ff ff ff       	jmp    f0100e20 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f22:	8d 50 04             	lea    0x4(%eax),%edx
f0100f25:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f28:	8b 00                	mov    (%eax),%eax
f0100f2a:	89 c2                	mov    %eax,%edx
f0100f2c:	c1 fa 1f             	sar    $0x1f,%edx
f0100f2f:	31 d0                	xor    %edx,%eax
f0100f31:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f33:	83 f8 07             	cmp    $0x7,%eax
f0100f36:	7f 0b                	jg     f0100f43 <vprintfmt+0x146>
f0100f38:	8b 14 85 c0 20 10 f0 	mov    -0xfefdf40(,%eax,4),%edx
f0100f3f:	85 d2                	test   %edx,%edx
f0100f41:	75 23                	jne    f0100f66 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f0100f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f47:	c7 44 24 08 dd 1e 10 	movl   $0xf0101edd,0x8(%esp)
f0100f4e:	f0 
f0100f4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f53:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f56:	89 3c 24             	mov    %edi,(%esp)
f0100f59:	e8 77 fe ff ff       	call   f0100dd5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f61:	e9 ba fe ff ff       	jmp    f0100e20 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100f66:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f6a:	c7 44 24 08 e6 1e 10 	movl   $0xf0101ee6,0x8(%esp)
f0100f71:	f0 
f0100f72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f76:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f79:	89 3c 24             	mov    %edi,(%esp)
f0100f7c:	e8 54 fe ff ff       	call   f0100dd5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f81:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f84:	e9 97 fe ff ff       	jmp    f0100e20 <vprintfmt+0x23>
f0100f89:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f92:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f95:	8d 50 04             	lea    0x4(%eax),%edx
f0100f98:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f9b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100f9d:	85 f6                	test   %esi,%esi
f0100f9f:	ba d6 1e 10 f0       	mov    $0xf0101ed6,%edx
f0100fa4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0100fa7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100fab:	0f 8e 8c 00 00 00    	jle    f010103d <vprintfmt+0x240>
f0100fb1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100fb5:	0f 84 82 00 00 00    	je     f010103d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fbb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fbf:	89 34 24             	mov    %esi,(%esp)
f0100fc2:	e8 81 03 00 00       	call   f0101348 <strnlen>
f0100fc7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100fca:	29 c2                	sub    %eax,%edx
f0100fcc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0100fcf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100fd3:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0100fd6:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0100fd9:	89 de                	mov    %ebx,%esi
f0100fdb:	89 d3                	mov    %edx,%ebx
f0100fdd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fdf:	eb 0d                	jmp    f0100fee <vprintfmt+0x1f1>
					putch(padc, putdat);
f0100fe1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fe5:	89 3c 24             	mov    %edi,(%esp)
f0100fe8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100feb:	83 eb 01             	sub    $0x1,%ebx
f0100fee:	85 db                	test   %ebx,%ebx
f0100ff0:	7f ef                	jg     f0100fe1 <vprintfmt+0x1e4>
f0100ff2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0100ff5:	89 f3                	mov    %esi,%ebx
f0100ff7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0100ffa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ffe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101003:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0101007:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010100a:	29 c2                	sub    %eax,%edx
f010100c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010100f:	eb 2c                	jmp    f010103d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101011:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101015:	74 18                	je     f010102f <vprintfmt+0x232>
f0101017:	8d 50 e0             	lea    -0x20(%eax),%edx
f010101a:	83 fa 5e             	cmp    $0x5e,%edx
f010101d:	76 10                	jbe    f010102f <vprintfmt+0x232>
					putch('?', putdat);
f010101f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101023:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010102a:	ff 55 08             	call   *0x8(%ebp)
f010102d:	eb 0a                	jmp    f0101039 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f010102f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101033:	89 04 24             	mov    %eax,(%esp)
f0101036:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101039:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010103d:	0f be 06             	movsbl (%esi),%eax
f0101040:	83 c6 01             	add    $0x1,%esi
f0101043:	85 c0                	test   %eax,%eax
f0101045:	74 25                	je     f010106c <vprintfmt+0x26f>
f0101047:	85 ff                	test   %edi,%edi
f0101049:	78 c6                	js     f0101011 <vprintfmt+0x214>
f010104b:	83 ef 01             	sub    $0x1,%edi
f010104e:	79 c1                	jns    f0101011 <vprintfmt+0x214>
f0101050:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101053:	89 de                	mov    %ebx,%esi
f0101055:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101058:	eb 1a                	jmp    f0101074 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010105a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010105e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101065:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101067:	83 eb 01             	sub    $0x1,%ebx
f010106a:	eb 08                	jmp    f0101074 <vprintfmt+0x277>
f010106c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010106f:	89 de                	mov    %ebx,%esi
f0101071:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101074:	85 db                	test   %ebx,%ebx
f0101076:	7f e2                	jg     f010105a <vprintfmt+0x25d>
f0101078:	89 7d 08             	mov    %edi,0x8(%ebp)
f010107b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010107d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101080:	e9 9b fd ff ff       	jmp    f0100e20 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101085:	83 f9 01             	cmp    $0x1,%ecx
f0101088:	7e 10                	jle    f010109a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f010108a:	8b 45 14             	mov    0x14(%ebp),%eax
f010108d:	8d 50 08             	lea    0x8(%eax),%edx
f0101090:	89 55 14             	mov    %edx,0x14(%ebp)
f0101093:	8b 30                	mov    (%eax),%esi
f0101095:	8b 78 04             	mov    0x4(%eax),%edi
f0101098:	eb 26                	jmp    f01010c0 <vprintfmt+0x2c3>
	else if (lflag)
f010109a:	85 c9                	test   %ecx,%ecx
f010109c:	74 12                	je     f01010b0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f010109e:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a1:	8d 50 04             	lea    0x4(%eax),%edx
f01010a4:	89 55 14             	mov    %edx,0x14(%ebp)
f01010a7:	8b 30                	mov    (%eax),%esi
f01010a9:	89 f7                	mov    %esi,%edi
f01010ab:	c1 ff 1f             	sar    $0x1f,%edi
f01010ae:	eb 10                	jmp    f01010c0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f01010b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b3:	8d 50 04             	lea    0x4(%eax),%edx
f01010b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01010b9:	8b 30                	mov    (%eax),%esi
f01010bb:	89 f7                	mov    %esi,%edi
f01010bd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010c5:	85 ff                	test   %edi,%edi
f01010c7:	0f 89 ac 00 00 00    	jns    f0101179 <vprintfmt+0x37c>
				putch('-', putdat);
f01010cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010d1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01010d8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01010db:	f7 de                	neg    %esi
f01010dd:	83 d7 00             	adc    $0x0,%edi
f01010e0:	f7 df                	neg    %edi
			}
			base = 10;
f01010e2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010e7:	e9 8d 00 00 00       	jmp    f0101179 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010ec:	89 ca                	mov    %ecx,%edx
f01010ee:	8d 45 14             	lea    0x14(%ebp),%eax
f01010f1:	e8 88 fc ff ff       	call   f0100d7e <getuint>
f01010f6:	89 c6                	mov    %eax,%esi
f01010f8:	89 d7                	mov    %edx,%edi
			base = 10;
f01010fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01010ff:	eb 78                	jmp    f0101179 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101101:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101105:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010110c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010110f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101113:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010111a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010111d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101121:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101128:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010112b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010112e:	e9 ed fc ff ff       	jmp    f0100e20 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0101133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101137:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010113e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101145:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010114c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010114f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101152:	8d 50 04             	lea    0x4(%eax),%edx
f0101155:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101158:	8b 30                	mov    (%eax),%esi
f010115a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010115f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101164:	eb 13                	jmp    f0101179 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101166:	89 ca                	mov    %ecx,%edx
f0101168:	8d 45 14             	lea    0x14(%ebp),%eax
f010116b:	e8 0e fc ff ff       	call   f0100d7e <getuint>
f0101170:	89 c6                	mov    %eax,%esi
f0101172:	89 d7                	mov    %edx,%edi
			base = 16;
f0101174:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101179:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f010117d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101181:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101184:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101188:	89 44 24 08          	mov    %eax,0x8(%esp)
f010118c:	89 34 24             	mov    %esi,(%esp)
f010118f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101193:	89 da                	mov    %ebx,%edx
f0101195:	8b 45 08             	mov    0x8(%ebp),%eax
f0101198:	e8 13 fb ff ff       	call   f0100cb0 <printnum>
			break;
f010119d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01011a0:	e9 7b fc ff ff       	jmp    f0100e20 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011a9:	89 04 24             	mov    %eax,(%esp)
f01011ac:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01011b2:	e9 69 fc ff ff       	jmp    f0100e20 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011bb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01011c2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011c5:	eb 03                	jmp    f01011ca <vprintfmt+0x3cd>
f01011c7:	83 ee 01             	sub    $0x1,%esi
f01011ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01011ce:	75 f7                	jne    f01011c7 <vprintfmt+0x3ca>
f01011d0:	e9 4b fc ff ff       	jmp    f0100e20 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01011d5:	83 c4 4c             	add    $0x4c,%esp
f01011d8:	5b                   	pop    %ebx
f01011d9:	5e                   	pop    %esi
f01011da:	5f                   	pop    %edi
f01011db:	5d                   	pop    %ebp
f01011dc:	c3                   	ret    

f01011dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011dd:	55                   	push   %ebp
f01011de:	89 e5                	mov    %esp,%ebp
f01011e0:	83 ec 28             	sub    $0x28,%esp
f01011e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011fa:	85 c0                	test   %eax,%eax
f01011fc:	74 30                	je     f010122e <vsnprintf+0x51>
f01011fe:	85 d2                	test   %edx,%edx
f0101200:	7e 2c                	jle    f010122e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101202:	8b 45 14             	mov    0x14(%ebp),%eax
f0101205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101209:	8b 45 10             	mov    0x10(%ebp),%eax
f010120c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101210:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101213:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101217:	c7 04 24 b8 0d 10 f0 	movl   $0xf0100db8,(%esp)
f010121e:	e8 da fb ff ff       	call   f0100dfd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101223:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101226:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101229:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010122c:	eb 05                	jmp    f0101233 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101233:	c9                   	leave  
f0101234:	c3                   	ret    

f0101235 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101235:	55                   	push   %ebp
f0101236:	89 e5                	mov    %esp,%ebp
f0101238:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010123b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010123e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101242:	8b 45 10             	mov    0x10(%ebp),%eax
f0101245:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101249:	8b 45 0c             	mov    0xc(%ebp),%eax
f010124c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101250:	8b 45 08             	mov    0x8(%ebp),%eax
f0101253:	89 04 24             	mov    %eax,(%esp)
f0101256:	e8 82 ff ff ff       	call   f01011dd <vsnprintf>
	va_end(ap);

	return rc;
}
f010125b:	c9                   	leave  
f010125c:	c3                   	ret    
f010125d:	00 00                	add    %al,(%eax)
	...

f0101260 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101260:	55                   	push   %ebp
f0101261:	89 e5                	mov    %esp,%ebp
f0101263:	57                   	push   %edi
f0101264:	56                   	push   %esi
f0101265:	53                   	push   %ebx
f0101266:	83 ec 1c             	sub    $0x1c,%esp
f0101269:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010126c:	85 c0                	test   %eax,%eax
f010126e:	74 10                	je     f0101280 <readline+0x20>
		cprintf("%s", prompt);
f0101270:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101274:	c7 04 24 e6 1e 10 f0 	movl   $0xf0101ee6,(%esp)
f010127b:	e8 4a f7 ff ff       	call   f01009ca <cprintf>

	i = 0;
	echoing = iscons(0);
f0101280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101287:	e8 d6 f3 ff ff       	call   f0100662 <iscons>
f010128c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010128e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101293:	e8 b9 f3 ff ff       	call   f0100651 <getchar>
f0101298:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010129a:	85 c0                	test   %eax,%eax
f010129c:	79 17                	jns    f01012b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010129e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012a2:	c7 04 24 e0 20 10 f0 	movl   $0xf01020e0,(%esp)
f01012a9:	e8 1c f7 ff ff       	call   f01009ca <cprintf>
			return NULL;
f01012ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b3:	eb 6d                	jmp    f0101322 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012b5:	83 f8 08             	cmp    $0x8,%eax
f01012b8:	74 05                	je     f01012bf <readline+0x5f>
f01012ba:	83 f8 7f             	cmp    $0x7f,%eax
f01012bd:	75 19                	jne    f01012d8 <readline+0x78>
f01012bf:	85 f6                	test   %esi,%esi
f01012c1:	7e 15                	jle    f01012d8 <readline+0x78>
			if (echoing)
f01012c3:	85 ff                	test   %edi,%edi
f01012c5:	74 0c                	je     f01012d3 <readline+0x73>
				cputchar('\b');
f01012c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01012ce:	e8 6e f3 ff ff       	call   f0100641 <cputchar>
			i--;
f01012d3:	83 ee 01             	sub    $0x1,%esi
f01012d6:	eb bb                	jmp    f0101293 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012d8:	83 fb 1f             	cmp    $0x1f,%ebx
f01012db:	7e 1f                	jle    f01012fc <readline+0x9c>
f01012dd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012e3:	7f 17                	jg     f01012fc <readline+0x9c>
			if (echoing)
f01012e5:	85 ff                	test   %edi,%edi
f01012e7:	74 08                	je     f01012f1 <readline+0x91>
				cputchar(c);
f01012e9:	89 1c 24             	mov    %ebx,(%esp)
f01012ec:	e8 50 f3 ff ff       	call   f0100641 <cputchar>
			buf[i++] = c;
f01012f1:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012f7:	83 c6 01             	add    $0x1,%esi
f01012fa:	eb 97                	jmp    f0101293 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01012fc:	83 fb 0a             	cmp    $0xa,%ebx
f01012ff:	74 05                	je     f0101306 <readline+0xa6>
f0101301:	83 fb 0d             	cmp    $0xd,%ebx
f0101304:	75 8d                	jne    f0101293 <readline+0x33>
			if (echoing)
f0101306:	85 ff                	test   %edi,%edi
f0101308:	74 0c                	je     f0101316 <readline+0xb6>
				cputchar('\n');
f010130a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101311:	e8 2b f3 ff ff       	call   f0100641 <cputchar>
			buf[i] = 0;
f0101316:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010131d:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101322:	83 c4 1c             	add    $0x1c,%esp
f0101325:	5b                   	pop    %ebx
f0101326:	5e                   	pop    %esi
f0101327:	5f                   	pop    %edi
f0101328:	5d                   	pop    %ebp
f0101329:	c3                   	ret    
f010132a:	00 00                	add    %al,(%eax)
f010132c:	00 00                	add    %al,(%eax)
	...

f0101330 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101330:	55                   	push   %ebp
f0101331:	89 e5                	mov    %esp,%ebp
f0101333:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101336:	b8 00 00 00 00       	mov    $0x0,%eax
f010133b:	eb 03                	jmp    f0101340 <strlen+0x10>
		n++;
f010133d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101340:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101344:	75 f7                	jne    f010133d <strlen+0xd>
		n++;
	return n;
}
f0101346:	5d                   	pop    %ebp
f0101347:	c3                   	ret    

f0101348 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101348:	55                   	push   %ebp
f0101349:	89 e5                	mov    %esp,%ebp
f010134b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f010134e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101351:	b8 00 00 00 00       	mov    $0x0,%eax
f0101356:	eb 03                	jmp    f010135b <strnlen+0x13>
		n++;
f0101358:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010135b:	39 d0                	cmp    %edx,%eax
f010135d:	74 06                	je     f0101365 <strnlen+0x1d>
f010135f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101363:	75 f3                	jne    f0101358 <strnlen+0x10>
		n++;
	return n;
}
f0101365:	5d                   	pop    %ebp
f0101366:	c3                   	ret    

f0101367 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101367:	55                   	push   %ebp
f0101368:	89 e5                	mov    %esp,%ebp
f010136a:	53                   	push   %ebx
f010136b:	8b 45 08             	mov    0x8(%ebp),%eax
f010136e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101371:	ba 00 00 00 00       	mov    $0x0,%edx
f0101376:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010137a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010137d:	83 c2 01             	add    $0x1,%edx
f0101380:	84 c9                	test   %cl,%cl
f0101382:	75 f2                	jne    f0101376 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101384:	5b                   	pop    %ebx
f0101385:	5d                   	pop    %ebp
f0101386:	c3                   	ret    

f0101387 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101387:	55                   	push   %ebp
f0101388:	89 e5                	mov    %esp,%ebp
f010138a:	53                   	push   %ebx
f010138b:	83 ec 08             	sub    $0x8,%esp
f010138e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101391:	89 1c 24             	mov    %ebx,(%esp)
f0101394:	e8 97 ff ff ff       	call   f0101330 <strlen>
	strcpy(dst + len, src);
f0101399:	8b 55 0c             	mov    0xc(%ebp),%edx
f010139c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013a0:	01 d8                	add    %ebx,%eax
f01013a2:	89 04 24             	mov    %eax,(%esp)
f01013a5:	e8 bd ff ff ff       	call   f0101367 <strcpy>
	return dst;
}
f01013aa:	89 d8                	mov    %ebx,%eax
f01013ac:	83 c4 08             	add    $0x8,%esp
f01013af:	5b                   	pop    %ebx
f01013b0:	5d                   	pop    %ebp
f01013b1:	c3                   	ret    

f01013b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013b2:	55                   	push   %ebp
f01013b3:	89 e5                	mov    %esp,%ebp
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ba:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013c0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013c5:	eb 0f                	jmp    f01013d6 <strncpy+0x24>
		*dst++ = *src;
f01013c7:	0f b6 1a             	movzbl (%edx),%ebx
f01013ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013cd:	80 3a 01             	cmpb   $0x1,(%edx)
f01013d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013d3:	83 c1 01             	add    $0x1,%ecx
f01013d6:	39 f1                	cmp    %esi,%ecx
f01013d8:	75 ed                	jne    f01013c7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013da:	5b                   	pop    %ebx
f01013db:	5e                   	pop    %esi
f01013dc:	5d                   	pop    %ebp
f01013dd:	c3                   	ret    

f01013de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013de:	55                   	push   %ebp
f01013df:	89 e5                	mov    %esp,%ebp
f01013e1:	56                   	push   %esi
f01013e2:	53                   	push   %ebx
f01013e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01013e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013e9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013ec:	89 f0                	mov    %esi,%eax
f01013ee:	85 d2                	test   %edx,%edx
f01013f0:	75 0a                	jne    f01013fc <strlcpy+0x1e>
f01013f2:	eb 1d                	jmp    f0101411 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013f4:	88 18                	mov    %bl,(%eax)
f01013f6:	83 c0 01             	add    $0x1,%eax
f01013f9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013fc:	83 ea 01             	sub    $0x1,%edx
f01013ff:	74 0b                	je     f010140c <strlcpy+0x2e>
f0101401:	0f b6 19             	movzbl (%ecx),%ebx
f0101404:	84 db                	test   %bl,%bl
f0101406:	75 ec                	jne    f01013f4 <strlcpy+0x16>
f0101408:	89 c2                	mov    %eax,%edx
f010140a:	eb 02                	jmp    f010140e <strlcpy+0x30>
f010140c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010140e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101411:	29 f0                	sub    %esi,%eax
}
f0101413:	5b                   	pop    %ebx
f0101414:	5e                   	pop    %esi
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    

f0101417 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010141d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101420:	eb 06                	jmp    f0101428 <strcmp+0x11>
		p++, q++;
f0101422:	83 c1 01             	add    $0x1,%ecx
f0101425:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101428:	0f b6 01             	movzbl (%ecx),%eax
f010142b:	84 c0                	test   %al,%al
f010142d:	74 04                	je     f0101433 <strcmp+0x1c>
f010142f:	3a 02                	cmp    (%edx),%al
f0101431:	74 ef                	je     f0101422 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101433:	0f b6 c0             	movzbl %al,%eax
f0101436:	0f b6 12             	movzbl (%edx),%edx
f0101439:	29 d0                	sub    %edx,%eax
}
f010143b:	5d                   	pop    %ebp
f010143c:	c3                   	ret    

f010143d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010143d:	55                   	push   %ebp
f010143e:	89 e5                	mov    %esp,%ebp
f0101440:	53                   	push   %ebx
f0101441:	8b 45 08             	mov    0x8(%ebp),%eax
f0101444:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101447:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f010144a:	eb 09                	jmp    f0101455 <strncmp+0x18>
		n--, p++, q++;
f010144c:	83 ea 01             	sub    $0x1,%edx
f010144f:	83 c0 01             	add    $0x1,%eax
f0101452:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101455:	85 d2                	test   %edx,%edx
f0101457:	74 15                	je     f010146e <strncmp+0x31>
f0101459:	0f b6 18             	movzbl (%eax),%ebx
f010145c:	84 db                	test   %bl,%bl
f010145e:	74 04                	je     f0101464 <strncmp+0x27>
f0101460:	3a 19                	cmp    (%ecx),%bl
f0101462:	74 e8                	je     f010144c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101464:	0f b6 00             	movzbl (%eax),%eax
f0101467:	0f b6 11             	movzbl (%ecx),%edx
f010146a:	29 d0                	sub    %edx,%eax
f010146c:	eb 05                	jmp    f0101473 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010146e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101473:	5b                   	pop    %ebx
f0101474:	5d                   	pop    %ebp
f0101475:	c3                   	ret    

f0101476 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	8b 45 08             	mov    0x8(%ebp),%eax
f010147c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101480:	eb 07                	jmp    f0101489 <strchr+0x13>
		if (*s == c)
f0101482:	38 ca                	cmp    %cl,%dl
f0101484:	74 0f                	je     f0101495 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101486:	83 c0 01             	add    $0x1,%eax
f0101489:	0f b6 10             	movzbl (%eax),%edx
f010148c:	84 d2                	test   %dl,%dl
f010148e:	75 f2                	jne    f0101482 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101490:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101495:	5d                   	pop    %ebp
f0101496:	c3                   	ret    

f0101497 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101497:	55                   	push   %ebp
f0101498:	89 e5                	mov    %esp,%ebp
f010149a:	8b 45 08             	mov    0x8(%ebp),%eax
f010149d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014a1:	eb 07                	jmp    f01014aa <strfind+0x13>
		if (*s == c)
f01014a3:	38 ca                	cmp    %cl,%dl
f01014a5:	74 0a                	je     f01014b1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01014a7:	83 c0 01             	add    $0x1,%eax
f01014aa:	0f b6 10             	movzbl (%eax),%edx
f01014ad:	84 d2                	test   %dl,%dl
f01014af:	75 f2                	jne    f01014a3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01014b1:	5d                   	pop    %ebp
f01014b2:	c3                   	ret    

f01014b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014b3:	55                   	push   %ebp
f01014b4:	89 e5                	mov    %esp,%ebp
f01014b6:	83 ec 0c             	sub    $0xc,%esp
f01014b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014c2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014cb:	85 c9                	test   %ecx,%ecx
f01014cd:	74 30                	je     f01014ff <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014d5:	75 25                	jne    f01014fc <memset+0x49>
f01014d7:	f6 c1 03             	test   $0x3,%cl
f01014da:	75 20                	jne    f01014fc <memset+0x49>
		c &= 0xFF;
f01014dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014df:	89 d3                	mov    %edx,%ebx
f01014e1:	c1 e3 08             	shl    $0x8,%ebx
f01014e4:	89 d6                	mov    %edx,%esi
f01014e6:	c1 e6 18             	shl    $0x18,%esi
f01014e9:	89 d0                	mov    %edx,%eax
f01014eb:	c1 e0 10             	shl    $0x10,%eax
f01014ee:	09 f0                	or     %esi,%eax
f01014f0:	09 d0                	or     %edx,%eax
f01014f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01014f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01014f7:	fc                   	cld    
f01014f8:	f3 ab                	rep stos %eax,%es:(%edi)
f01014fa:	eb 03                	jmp    f01014ff <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014fc:	fc                   	cld    
f01014fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014ff:	89 f8                	mov    %edi,%eax
f0101501:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101504:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101507:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010150a:	89 ec                	mov    %ebp,%esp
f010150c:	5d                   	pop    %ebp
f010150d:	c3                   	ret    

f010150e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	83 ec 08             	sub    $0x8,%esp
f0101514:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101517:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010151a:	8b 45 08             	mov    0x8(%ebp),%eax
f010151d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101520:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101523:	39 c6                	cmp    %eax,%esi
f0101525:	73 36                	jae    f010155d <memmove+0x4f>
f0101527:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010152a:	39 d0                	cmp    %edx,%eax
f010152c:	73 2f                	jae    f010155d <memmove+0x4f>
		s += n;
		d += n;
f010152e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101531:	f6 c2 03             	test   $0x3,%dl
f0101534:	75 1b                	jne    f0101551 <memmove+0x43>
f0101536:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010153c:	75 13                	jne    f0101551 <memmove+0x43>
f010153e:	f6 c1 03             	test   $0x3,%cl
f0101541:	75 0e                	jne    f0101551 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101543:	83 ef 04             	sub    $0x4,%edi
f0101546:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101549:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010154c:	fd                   	std    
f010154d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010154f:	eb 09                	jmp    f010155a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101551:	83 ef 01             	sub    $0x1,%edi
f0101554:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101557:	fd                   	std    
f0101558:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010155a:	fc                   	cld    
f010155b:	eb 20                	jmp    f010157d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010155d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101563:	75 13                	jne    f0101578 <memmove+0x6a>
f0101565:	a8 03                	test   $0x3,%al
f0101567:	75 0f                	jne    f0101578 <memmove+0x6a>
f0101569:	f6 c1 03             	test   $0x3,%cl
f010156c:	75 0a                	jne    f0101578 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010156e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101571:	89 c7                	mov    %eax,%edi
f0101573:	fc                   	cld    
f0101574:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101576:	eb 05                	jmp    f010157d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101578:	89 c7                	mov    %eax,%edi
f010157a:	fc                   	cld    
f010157b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010157d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101580:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101583:	89 ec                	mov    %ebp,%esp
f0101585:	5d                   	pop    %ebp
f0101586:	c3                   	ret    

f0101587 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101587:	55                   	push   %ebp
f0101588:	89 e5                	mov    %esp,%ebp
f010158a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010158d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101590:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101594:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101597:	89 44 24 04          	mov    %eax,0x4(%esp)
f010159b:	8b 45 08             	mov    0x8(%ebp),%eax
f010159e:	89 04 24             	mov    %eax,(%esp)
f01015a1:	e8 68 ff ff ff       	call   f010150e <memmove>
}
f01015a6:	c9                   	leave  
f01015a7:	c3                   	ret    

f01015a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015a8:	55                   	push   %ebp
f01015a9:	89 e5                	mov    %esp,%ebp
f01015ab:	57                   	push   %edi
f01015ac:	56                   	push   %esi
f01015ad:	53                   	push   %ebx
f01015ae:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01015bc:	eb 1a                	jmp    f01015d8 <memcmp+0x30>
		if (*s1 != *s2)
f01015be:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f01015c2:	83 c2 01             	add    $0x1,%edx
f01015c5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f01015ca:	38 c8                	cmp    %cl,%al
f01015cc:	74 0a                	je     f01015d8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f01015ce:	0f b6 c0             	movzbl %al,%eax
f01015d1:	0f b6 c9             	movzbl %cl,%ecx
f01015d4:	29 c8                	sub    %ecx,%eax
f01015d6:	eb 09                	jmp    f01015e1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015d8:	39 da                	cmp    %ebx,%edx
f01015da:	75 e2                	jne    f01015be <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015e1:	5b                   	pop    %ebx
f01015e2:	5e                   	pop    %esi
f01015e3:	5f                   	pop    %edi
f01015e4:	5d                   	pop    %ebp
f01015e5:	c3                   	ret    

f01015e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015e6:	55                   	push   %ebp
f01015e7:	89 e5                	mov    %esp,%ebp
f01015e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01015ef:	89 c2                	mov    %eax,%edx
f01015f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01015f4:	eb 07                	jmp    f01015fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015f6:	38 08                	cmp    %cl,(%eax)
f01015f8:	74 07                	je     f0101601 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015fa:	83 c0 01             	add    $0x1,%eax
f01015fd:	39 d0                	cmp    %edx,%eax
f01015ff:	72 f5                	jb     f01015f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101601:	5d                   	pop    %ebp
f0101602:	c3                   	ret    

f0101603 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101603:	55                   	push   %ebp
f0101604:	89 e5                	mov    %esp,%ebp
f0101606:	57                   	push   %edi
f0101607:	56                   	push   %esi
f0101608:	53                   	push   %ebx
f0101609:	8b 55 08             	mov    0x8(%ebp),%edx
f010160c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010160f:	eb 03                	jmp    f0101614 <strtol+0x11>
		s++;
f0101611:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101614:	0f b6 02             	movzbl (%edx),%eax
f0101617:	3c 20                	cmp    $0x20,%al
f0101619:	74 f6                	je     f0101611 <strtol+0xe>
f010161b:	3c 09                	cmp    $0x9,%al
f010161d:	74 f2                	je     f0101611 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010161f:	3c 2b                	cmp    $0x2b,%al
f0101621:	75 0a                	jne    f010162d <strtol+0x2a>
		s++;
f0101623:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101626:	bf 00 00 00 00       	mov    $0x0,%edi
f010162b:	eb 10                	jmp    f010163d <strtol+0x3a>
f010162d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101632:	3c 2d                	cmp    $0x2d,%al
f0101634:	75 07                	jne    f010163d <strtol+0x3a>
		s++, neg = 1;
f0101636:	8d 52 01             	lea    0x1(%edx),%edx
f0101639:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010163d:	85 db                	test   %ebx,%ebx
f010163f:	0f 94 c0             	sete   %al
f0101642:	74 05                	je     f0101649 <strtol+0x46>
f0101644:	83 fb 10             	cmp    $0x10,%ebx
f0101647:	75 15                	jne    f010165e <strtol+0x5b>
f0101649:	80 3a 30             	cmpb   $0x30,(%edx)
f010164c:	75 10                	jne    f010165e <strtol+0x5b>
f010164e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101652:	75 0a                	jne    f010165e <strtol+0x5b>
		s += 2, base = 16;
f0101654:	83 c2 02             	add    $0x2,%edx
f0101657:	bb 10 00 00 00       	mov    $0x10,%ebx
f010165c:	eb 13                	jmp    f0101671 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010165e:	84 c0                	test   %al,%al
f0101660:	74 0f                	je     f0101671 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101662:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101667:	80 3a 30             	cmpb   $0x30,(%edx)
f010166a:	75 05                	jne    f0101671 <strtol+0x6e>
		s++, base = 8;
f010166c:	83 c2 01             	add    $0x1,%edx
f010166f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0101671:	b8 00 00 00 00       	mov    $0x0,%eax
f0101676:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101678:	0f b6 0a             	movzbl (%edx),%ecx
f010167b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010167e:	80 fb 09             	cmp    $0x9,%bl
f0101681:	77 08                	ja     f010168b <strtol+0x88>
			dig = *s - '0';
f0101683:	0f be c9             	movsbl %cl,%ecx
f0101686:	83 e9 30             	sub    $0x30,%ecx
f0101689:	eb 1e                	jmp    f01016a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f010168b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010168e:	80 fb 19             	cmp    $0x19,%bl
f0101691:	77 08                	ja     f010169b <strtol+0x98>
			dig = *s - 'a' + 10;
f0101693:	0f be c9             	movsbl %cl,%ecx
f0101696:	83 e9 57             	sub    $0x57,%ecx
f0101699:	eb 0e                	jmp    f01016a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010169b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010169e:	80 fb 19             	cmp    $0x19,%bl
f01016a1:	77 14                	ja     f01016b7 <strtol+0xb4>
			dig = *s - 'A' + 10;
f01016a3:	0f be c9             	movsbl %cl,%ecx
f01016a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01016a9:	39 f1                	cmp    %esi,%ecx
f01016ab:	7d 0e                	jge    f01016bb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f01016ad:	83 c2 01             	add    $0x1,%edx
f01016b0:	0f af c6             	imul   %esi,%eax
f01016b3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01016b5:	eb c1                	jmp    f0101678 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01016b7:	89 c1                	mov    %eax,%ecx
f01016b9:	eb 02                	jmp    f01016bd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01016bb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01016bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016c1:	74 05                	je     f01016c8 <strtol+0xc5>
		*endptr = (char *) s;
f01016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016c6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01016c8:	89 ca                	mov    %ecx,%edx
f01016ca:	f7 da                	neg    %edx
f01016cc:	85 ff                	test   %edi,%edi
f01016ce:	0f 45 c2             	cmovne %edx,%eax
}
f01016d1:	5b                   	pop    %ebx
f01016d2:	5e                   	pop    %esi
f01016d3:	5f                   	pop    %edi
f01016d4:	5d                   	pop    %ebp
f01016d5:	c3                   	ret    
	...

f01016e0 <__udivdi3>:
f01016e0:	83 ec 1c             	sub    $0x1c,%esp
f01016e3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01016e7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01016eb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01016ef:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01016f3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01016f7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01016fb:	85 ff                	test   %edi,%edi
f01016fd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101701:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101705:	89 cd                	mov    %ecx,%ebp
f0101707:	89 44 24 04          	mov    %eax,0x4(%esp)
f010170b:	75 33                	jne    f0101740 <__udivdi3+0x60>
f010170d:	39 f1                	cmp    %esi,%ecx
f010170f:	77 57                	ja     f0101768 <__udivdi3+0x88>
f0101711:	85 c9                	test   %ecx,%ecx
f0101713:	75 0b                	jne    f0101720 <__udivdi3+0x40>
f0101715:	b8 01 00 00 00       	mov    $0x1,%eax
f010171a:	31 d2                	xor    %edx,%edx
f010171c:	f7 f1                	div    %ecx
f010171e:	89 c1                	mov    %eax,%ecx
f0101720:	89 f0                	mov    %esi,%eax
f0101722:	31 d2                	xor    %edx,%edx
f0101724:	f7 f1                	div    %ecx
f0101726:	89 c6                	mov    %eax,%esi
f0101728:	8b 44 24 04          	mov    0x4(%esp),%eax
f010172c:	f7 f1                	div    %ecx
f010172e:	89 f2                	mov    %esi,%edx
f0101730:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101734:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101738:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010173c:	83 c4 1c             	add    $0x1c,%esp
f010173f:	c3                   	ret    
f0101740:	31 d2                	xor    %edx,%edx
f0101742:	31 c0                	xor    %eax,%eax
f0101744:	39 f7                	cmp    %esi,%edi
f0101746:	77 e8                	ja     f0101730 <__udivdi3+0x50>
f0101748:	0f bd cf             	bsr    %edi,%ecx
f010174b:	83 f1 1f             	xor    $0x1f,%ecx
f010174e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101752:	75 2c                	jne    f0101780 <__udivdi3+0xa0>
f0101754:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101758:	76 04                	jbe    f010175e <__udivdi3+0x7e>
f010175a:	39 f7                	cmp    %esi,%edi
f010175c:	73 d2                	jae    f0101730 <__udivdi3+0x50>
f010175e:	31 d2                	xor    %edx,%edx
f0101760:	b8 01 00 00 00       	mov    $0x1,%eax
f0101765:	eb c9                	jmp    f0101730 <__udivdi3+0x50>
f0101767:	90                   	nop
f0101768:	89 f2                	mov    %esi,%edx
f010176a:	f7 f1                	div    %ecx
f010176c:	31 d2                	xor    %edx,%edx
f010176e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101772:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101776:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010177a:	83 c4 1c             	add    $0x1c,%esp
f010177d:	c3                   	ret    
f010177e:	66 90                	xchg   %ax,%ax
f0101780:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101785:	b8 20 00 00 00       	mov    $0x20,%eax
f010178a:	89 ea                	mov    %ebp,%edx
f010178c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101790:	d3 e7                	shl    %cl,%edi
f0101792:	89 c1                	mov    %eax,%ecx
f0101794:	d3 ea                	shr    %cl,%edx
f0101796:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010179b:	09 fa                	or     %edi,%edx
f010179d:	89 f7                	mov    %esi,%edi
f010179f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01017a3:	89 f2                	mov    %esi,%edx
f01017a5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01017a9:	d3 e5                	shl    %cl,%ebp
f01017ab:	89 c1                	mov    %eax,%ecx
f01017ad:	d3 ef                	shr    %cl,%edi
f01017af:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017b4:	d3 e2                	shl    %cl,%edx
f01017b6:	89 c1                	mov    %eax,%ecx
f01017b8:	d3 ee                	shr    %cl,%esi
f01017ba:	09 d6                	or     %edx,%esi
f01017bc:	89 fa                	mov    %edi,%edx
f01017be:	89 f0                	mov    %esi,%eax
f01017c0:	f7 74 24 0c          	divl   0xc(%esp)
f01017c4:	89 d7                	mov    %edx,%edi
f01017c6:	89 c6                	mov    %eax,%esi
f01017c8:	f7 e5                	mul    %ebp
f01017ca:	39 d7                	cmp    %edx,%edi
f01017cc:	72 22                	jb     f01017f0 <__udivdi3+0x110>
f01017ce:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01017d2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017d7:	d3 e5                	shl    %cl,%ebp
f01017d9:	39 c5                	cmp    %eax,%ebp
f01017db:	73 04                	jae    f01017e1 <__udivdi3+0x101>
f01017dd:	39 d7                	cmp    %edx,%edi
f01017df:	74 0f                	je     f01017f0 <__udivdi3+0x110>
f01017e1:	89 f0                	mov    %esi,%eax
f01017e3:	31 d2                	xor    %edx,%edx
f01017e5:	e9 46 ff ff ff       	jmp    f0101730 <__udivdi3+0x50>
f01017ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017f0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01017f3:	31 d2                	xor    %edx,%edx
f01017f5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01017f9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01017fd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101801:	83 c4 1c             	add    $0x1c,%esp
f0101804:	c3                   	ret    
	...

f0101810 <__umoddi3>:
f0101810:	83 ec 1c             	sub    $0x1c,%esp
f0101813:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101817:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010181b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010181f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101823:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101827:	8b 74 24 24          	mov    0x24(%esp),%esi
f010182b:	85 ed                	test   %ebp,%ebp
f010182d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101831:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101835:	89 cf                	mov    %ecx,%edi
f0101837:	89 04 24             	mov    %eax,(%esp)
f010183a:	89 f2                	mov    %esi,%edx
f010183c:	75 1a                	jne    f0101858 <__umoddi3+0x48>
f010183e:	39 f1                	cmp    %esi,%ecx
f0101840:	76 4e                	jbe    f0101890 <__umoddi3+0x80>
f0101842:	f7 f1                	div    %ecx
f0101844:	89 d0                	mov    %edx,%eax
f0101846:	31 d2                	xor    %edx,%edx
f0101848:	8b 74 24 10          	mov    0x10(%esp),%esi
f010184c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101850:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101854:	83 c4 1c             	add    $0x1c,%esp
f0101857:	c3                   	ret    
f0101858:	39 f5                	cmp    %esi,%ebp
f010185a:	77 54                	ja     f01018b0 <__umoddi3+0xa0>
f010185c:	0f bd c5             	bsr    %ebp,%eax
f010185f:	83 f0 1f             	xor    $0x1f,%eax
f0101862:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101866:	75 60                	jne    f01018c8 <__umoddi3+0xb8>
f0101868:	3b 0c 24             	cmp    (%esp),%ecx
f010186b:	0f 87 07 01 00 00    	ja     f0101978 <__umoddi3+0x168>
f0101871:	89 f2                	mov    %esi,%edx
f0101873:	8b 34 24             	mov    (%esp),%esi
f0101876:	29 ce                	sub    %ecx,%esi
f0101878:	19 ea                	sbb    %ebp,%edx
f010187a:	89 34 24             	mov    %esi,(%esp)
f010187d:	8b 04 24             	mov    (%esp),%eax
f0101880:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101884:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101888:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010188c:	83 c4 1c             	add    $0x1c,%esp
f010188f:	c3                   	ret    
f0101890:	85 c9                	test   %ecx,%ecx
f0101892:	75 0b                	jne    f010189f <__umoddi3+0x8f>
f0101894:	b8 01 00 00 00       	mov    $0x1,%eax
f0101899:	31 d2                	xor    %edx,%edx
f010189b:	f7 f1                	div    %ecx
f010189d:	89 c1                	mov    %eax,%ecx
f010189f:	89 f0                	mov    %esi,%eax
f01018a1:	31 d2                	xor    %edx,%edx
f01018a3:	f7 f1                	div    %ecx
f01018a5:	8b 04 24             	mov    (%esp),%eax
f01018a8:	f7 f1                	div    %ecx
f01018aa:	eb 98                	jmp    f0101844 <__umoddi3+0x34>
f01018ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018b0:	89 f2                	mov    %esi,%edx
f01018b2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01018b6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01018ba:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01018be:	83 c4 1c             	add    $0x1c,%esp
f01018c1:	c3                   	ret    
f01018c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018c8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01018cd:	89 e8                	mov    %ebp,%eax
f01018cf:	bd 20 00 00 00       	mov    $0x20,%ebp
f01018d4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01018d8:	89 fa                	mov    %edi,%edx
f01018da:	d3 e0                	shl    %cl,%eax
f01018dc:	89 e9                	mov    %ebp,%ecx
f01018de:	d3 ea                	shr    %cl,%edx
f01018e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01018e5:	09 c2                	or     %eax,%edx
f01018e7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01018eb:	89 14 24             	mov    %edx,(%esp)
f01018ee:	89 f2                	mov    %esi,%edx
f01018f0:	d3 e7                	shl    %cl,%edi
f01018f2:	89 e9                	mov    %ebp,%ecx
f01018f4:	d3 ea                	shr    %cl,%edx
f01018f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01018fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01018ff:	d3 e6                	shl    %cl,%esi
f0101901:	89 e9                	mov    %ebp,%ecx
f0101903:	d3 e8                	shr    %cl,%eax
f0101905:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010190a:	09 f0                	or     %esi,%eax
f010190c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101910:	f7 34 24             	divl   (%esp)
f0101913:	d3 e6                	shl    %cl,%esi
f0101915:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101919:	89 d6                	mov    %edx,%esi
f010191b:	f7 e7                	mul    %edi
f010191d:	39 d6                	cmp    %edx,%esi
f010191f:	89 c1                	mov    %eax,%ecx
f0101921:	89 d7                	mov    %edx,%edi
f0101923:	72 3f                	jb     f0101964 <__umoddi3+0x154>
f0101925:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101929:	72 35                	jb     f0101960 <__umoddi3+0x150>
f010192b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010192f:	29 c8                	sub    %ecx,%eax
f0101931:	19 fe                	sbb    %edi,%esi
f0101933:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101938:	89 f2                	mov    %esi,%edx
f010193a:	d3 e8                	shr    %cl,%eax
f010193c:	89 e9                	mov    %ebp,%ecx
f010193e:	d3 e2                	shl    %cl,%edx
f0101940:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101945:	09 d0                	or     %edx,%eax
f0101947:	89 f2                	mov    %esi,%edx
f0101949:	d3 ea                	shr    %cl,%edx
f010194b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010194f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101953:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101957:	83 c4 1c             	add    $0x1c,%esp
f010195a:	c3                   	ret    
f010195b:	90                   	nop
f010195c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101960:	39 d6                	cmp    %edx,%esi
f0101962:	75 c7                	jne    f010192b <__umoddi3+0x11b>
f0101964:	89 d7                	mov    %edx,%edi
f0101966:	89 c1                	mov    %eax,%ecx
f0101968:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010196c:	1b 3c 24             	sbb    (%esp),%edi
f010196f:	eb ba                	jmp    f010192b <__umoddi3+0x11b>
f0101971:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101978:	39 f5                	cmp    %esi,%ebp
f010197a:	0f 82 f1 fe ff ff    	jb     f0101871 <__umoddi3+0x61>
f0101980:	e9 f8 fe ff ff       	jmp    f010187d <__umoddi3+0x6d>
