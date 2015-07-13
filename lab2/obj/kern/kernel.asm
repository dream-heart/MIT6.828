
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
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 50 39 11 f0       	mov    $0xf0113950,%eax
f010004b:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f0100063:	e8 cb 16 00 00       	call   f0101733 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 7f 04 00 00       	call   f01004ec <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 1c 10 f0 	movl   $0xf0101c20,(%esp)
f010007c:	e8 d1 0b 00 00       	call   f0100c52 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 c9 08 00 00       	call   f010094f <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 53 07 00 00       	call   f01007e5 <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 40 39 11 f0 00 	cmpl   $0x0,0xf0113940
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 40 39 11 f0    	mov    %esi,0xf0113940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 3b 1c 10 f0 	movl   $0xf0101c3b,(%esp)
f01000c8:	e8 85 0b 00 00       	call   f0100c52 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 46 0b 00 00       	call   f0100c1f <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 77 1c 10 f0 	movl   $0xf0101c77,(%esp)
f01000e0:	e8 6d 0b 00 00       	call   f0100c52 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 f4 06 00 00       	call   f01007e5 <monitor>
f01000f1:	eb f2                	jmp    f01000e5 <_panic+0x51>

f01000f3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	53                   	push   %ebx
f01000f7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010b:	c7 04 24 53 1c 10 f0 	movl   $0xf0101c53,(%esp)
f0100112:	e8 3b 0b 00 00       	call   f0100c52 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 f9 0a 00 00       	call   f0100c1f <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 77 1c 10 f0 	movl   $0xf0101c77,(%esp)
f010012d:	e8 20 0b 00 00       	call   f0100c52 <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    
	...

f0100140 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba 84 00 00 00       	mov    $0x84,%edx
f0100148:	ec                   	in     (%dx),%al
f0100149:	ec                   	in     (%dx),%al
f010014a:	ec                   	in     (%dx),%al
f010014b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010014c:	5d                   	pop    %ebp
f010014d:	c3                   	ret    

f010014e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100156:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100157:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 06                	je     f0100166 <serial_proc_data+0x18>
f0100160:	b2 f8                	mov    $0xf8,%dl
f0100162:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100163:	0f b6 c8             	movzbl %al,%ecx
}
f0100166:	89 c8                	mov    %ecx,%eax
f0100168:	5d                   	pop    %ebp
f0100169:	c3                   	ret    

f010016a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016a:	55                   	push   %ebp
f010016b:	89 e5                	mov    %esp,%ebp
f010016d:	53                   	push   %ebx
f010016e:	83 ec 04             	sub    $0x4,%esp
f0100171:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100173:	eb 25                	jmp    f010019a <cons_intr+0x30>
		if (c == 0)
f0100175:	85 c0                	test   %eax,%eax
f0100177:	74 21                	je     f010019a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100179:	8b 15 24 35 11 f0    	mov    0xf0113524,%edx
f010017f:	88 82 20 33 11 f0    	mov    %al,-0xfeecce0(%edx)
f0100185:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100188:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010018d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100192:	0f 44 c2             	cmove  %edx,%eax
f0100195:	a3 24 35 11 f0       	mov    %eax,0xf0113524
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010019a:	ff d3                	call   *%ebx
f010019c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010019f:	75 d4                	jne    f0100175 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001a1:	83 c4 04             	add    $0x4,%esp
f01001a4:	5b                   	pop    %ebx
f01001a5:	5d                   	pop    %ebp
f01001a6:	c3                   	ret    

f01001a7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001a7:	55                   	push   %ebp
f01001a8:	89 e5                	mov    %esp,%ebp
f01001aa:	57                   	push   %edi
f01001ab:	56                   	push   %esi
f01001ac:	53                   	push   %ebx
f01001ad:	83 ec 2c             	sub    $0x2c,%esp
f01001b0:	89 c7                	mov    %eax,%edi
f01001b2:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001b7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01001bc:	eb 05                	jmp    f01001c3 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001be:	e8 7d ff ff ff       	call   f0100140 <delay>
f01001c3:	89 f2                	mov    %esi,%edx
f01001c5:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001c6:	a8 20                	test   $0x20,%al
f01001c8:	75 05                	jne    f01001cf <cons_putc+0x28>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001ca:	83 eb 01             	sub    $0x1,%ebx
f01001cd:	75 ef                	jne    f01001be <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001cf:	89 fa                	mov    %edi,%edx
f01001d1:	89 f8                	mov    %edi,%eax
f01001d3:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d6:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001db:	ee                   	out    %al,(%dx)
f01001dc:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e1:	be 79 03 00 00       	mov    $0x379,%esi
f01001e6:	eb 05                	jmp    f01001ed <cons_putc+0x46>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01001e8:	e8 53 ff ff ff       	call   f0100140 <delay>
f01001ed:	89 f2                	mov    %esi,%edx
f01001ef:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001f0:	84 c0                	test   %al,%al
f01001f2:	78 05                	js     f01001f9 <cons_putc+0x52>
f01001f4:	83 eb 01             	sub    $0x1,%ebx
f01001f7:	75 ef                	jne    f01001e8 <cons_putc+0x41>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f9:	ba 78 03 00 00       	mov    $0x378,%edx
f01001fe:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100202:	ee                   	out    %al,(%dx)
f0100203:	b2 7a                	mov    $0x7a,%dl
f0100205:	b8 0d 00 00 00       	mov    $0xd,%eax
f010020a:	ee                   	out    %al,(%dx)
f010020b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100210:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100211:	89 fa                	mov    %edi,%edx
f0100213:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100219:	89 f8                	mov    %edi,%eax
f010021b:	80 cc 07             	or     $0x7,%ah
f010021e:	85 d2                	test   %edx,%edx
f0100220:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100223:	89 f8                	mov    %edi,%eax
f0100225:	25 ff 00 00 00       	and    $0xff,%eax
f010022a:	83 f8 09             	cmp    $0x9,%eax
f010022d:	74 79                	je     f01002a8 <cons_putc+0x101>
f010022f:	83 f8 09             	cmp    $0x9,%eax
f0100232:	7f 0e                	jg     f0100242 <cons_putc+0x9b>
f0100234:	83 f8 08             	cmp    $0x8,%eax
f0100237:	0f 85 9f 00 00 00    	jne    f01002dc <cons_putc+0x135>
f010023d:	8d 76 00             	lea    0x0(%esi),%esi
f0100240:	eb 10                	jmp    f0100252 <cons_putc+0xab>
f0100242:	83 f8 0a             	cmp    $0xa,%eax
f0100245:	74 3b                	je     f0100282 <cons_putc+0xdb>
f0100247:	83 f8 0d             	cmp    $0xd,%eax
f010024a:	0f 85 8c 00 00 00    	jne    f01002dc <cons_putc+0x135>
f0100250:	eb 38                	jmp    f010028a <cons_putc+0xe3>
	case '\b':
		if (crt_pos > 0) {
f0100252:	0f b7 05 34 35 11 f0 	movzwl 0xf0113534,%eax
f0100259:	66 85 c0             	test   %ax,%ax
f010025c:	0f 84 e4 00 00 00    	je     f0100346 <cons_putc+0x19f>
			crt_pos--;
f0100262:	83 e8 01             	sub    $0x1,%eax
f0100265:	66 a3 34 35 11 f0    	mov    %ax,0xf0113534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010026b:	0f b7 c0             	movzwl %ax,%eax
f010026e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100273:	83 cf 20             	or     $0x20,%edi
f0100276:	8b 15 30 35 11 f0    	mov    0xf0113530,%edx
f010027c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100280:	eb 77                	jmp    f01002f9 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100282:	66 83 05 34 35 11 f0 	addw   $0x50,0xf0113534
f0100289:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010028a:	0f b7 05 34 35 11 f0 	movzwl 0xf0113534,%eax
f0100291:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100297:	c1 e8 16             	shr    $0x16,%eax
f010029a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010029d:	c1 e0 04             	shl    $0x4,%eax
f01002a0:	66 a3 34 35 11 f0    	mov    %ax,0xf0113534
f01002a6:	eb 51                	jmp    f01002f9 <cons_putc+0x152>
		break;
	case '\t':
		cons_putc(' ');
f01002a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ad:	e8 f5 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b7:	e8 eb fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c1:	e8 e1 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01002cb:	e8 d7 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d5:	e8 cd fe ff ff       	call   f01001a7 <cons_putc>
f01002da:	eb 1d                	jmp    f01002f9 <cons_putc+0x152>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002dc:	0f b7 05 34 35 11 f0 	movzwl 0xf0113534,%eax
f01002e3:	0f b7 c8             	movzwl %ax,%ecx
f01002e6:	8b 15 30 35 11 f0    	mov    0xf0113530,%edx
f01002ec:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01002f0:	83 c0 01             	add    $0x1,%eax
f01002f3:	66 a3 34 35 11 f0    	mov    %ax,0xf0113534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002f9:	66 81 3d 34 35 11 f0 	cmpw   $0x7cf,0xf0113534
f0100300:	cf 07 
f0100302:	76 42                	jbe    f0100346 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100304:	a1 30 35 11 f0       	mov    0xf0113530,%eax
f0100309:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100310:	00 
f0100311:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100317:	89 54 24 04          	mov    %edx,0x4(%esp)
f010031b:	89 04 24             	mov    %eax,(%esp)
f010031e:	e8 6b 14 00 00       	call   f010178e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100323:	8b 15 30 35 11 f0    	mov    0xf0113530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100329:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010032e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100334:	83 c0 01             	add    $0x1,%eax
f0100337:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010033c:	75 f0                	jne    f010032e <cons_putc+0x187>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010033e:	66 83 2d 34 35 11 f0 	subw   $0x50,0xf0113534
f0100345:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100346:	8b 0d 2c 35 11 f0    	mov    0xf011352c,%ecx
f010034c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100351:	89 ca                	mov    %ecx,%edx
f0100353:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100354:	0f b7 35 34 35 11 f0 	movzwl 0xf0113534,%esi
f010035b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010035e:	89 f0                	mov    %esi,%eax
f0100360:	66 c1 e8 08          	shr    $0x8,%ax
f0100364:	89 da                	mov    %ebx,%edx
f0100366:	ee                   	out    %al,(%dx)
f0100367:	b8 0f 00 00 00       	mov    $0xf,%eax
f010036c:	89 ca                	mov    %ecx,%edx
f010036e:	ee                   	out    %al,(%dx)
f010036f:	89 f0                	mov    %esi,%eax
f0100371:	89 da                	mov    %ebx,%edx
f0100373:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100374:	83 c4 2c             	add    $0x2c,%esp
f0100377:	5b                   	pop    %ebx
f0100378:	5e                   	pop    %esi
f0100379:	5f                   	pop    %edi
f010037a:	5d                   	pop    %ebp
f010037b:	c3                   	ret    

f010037c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010037c:	55                   	push   %ebp
f010037d:	89 e5                	mov    %esp,%ebp
f010037f:	53                   	push   %ebx
f0100380:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100383:	ba 64 00 00 00       	mov    $0x64,%edx
f0100388:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100389:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010038e:	a8 01                	test   $0x1,%al
f0100390:	0f 84 de 00 00 00    	je     f0100474 <kbd_proc_data+0xf8>
f0100396:	b2 60                	mov    $0x60,%dl
f0100398:	ec                   	in     (%dx),%al
f0100399:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010039b:	3c e0                	cmp    $0xe0,%al
f010039d:	75 11                	jne    f01003b0 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010039f:	83 0d 28 35 11 f0 40 	orl    $0x40,0xf0113528
		return 0;
f01003a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ab:	e9 c4 00 00 00       	jmp    f0100474 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003b0:	84 c0                	test   %al,%al
f01003b2:	79 37                	jns    f01003eb <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003b4:	8b 0d 28 35 11 f0    	mov    0xf0113528,%ecx
f01003ba:	89 cb                	mov    %ecx,%ebx
f01003bc:	83 e3 40             	and    $0x40,%ebx
f01003bf:	83 e0 7f             	and    $0x7f,%eax
f01003c2:	85 db                	test   %ebx,%ebx
f01003c4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003c7:	0f b6 d2             	movzbl %dl,%edx
f01003ca:	0f b6 82 a0 1c 10 f0 	movzbl -0xfefe360(%edx),%eax
f01003d1:	83 c8 40             	or     $0x40,%eax
f01003d4:	0f b6 c0             	movzbl %al,%eax
f01003d7:	f7 d0                	not    %eax
f01003d9:	21 c1                	and    %eax,%ecx
f01003db:	89 0d 28 35 11 f0    	mov    %ecx,0xf0113528
		return 0;
f01003e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e6:	e9 89 00 00 00       	jmp    f0100474 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01003eb:	8b 0d 28 35 11 f0    	mov    0xf0113528,%ecx
f01003f1:	f6 c1 40             	test   $0x40,%cl
f01003f4:	74 0e                	je     f0100404 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003f6:	89 c2                	mov    %eax,%edx
f01003f8:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003fb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003fe:	89 0d 28 35 11 f0    	mov    %ecx,0xf0113528
	}

	shift |= shiftcode[data];
f0100404:	0f b6 d2             	movzbl %dl,%edx
f0100407:	0f b6 82 a0 1c 10 f0 	movzbl -0xfefe360(%edx),%eax
f010040e:	0b 05 28 35 11 f0    	or     0xf0113528,%eax
	shift ^= togglecode[data];
f0100414:	0f b6 8a a0 1d 10 f0 	movzbl -0xfefe260(%edx),%ecx
f010041b:	31 c8                	xor    %ecx,%eax
f010041d:	a3 28 35 11 f0       	mov    %eax,0xf0113528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100422:	89 c1                	mov    %eax,%ecx
f0100424:	83 e1 03             	and    $0x3,%ecx
f0100427:	8b 0c 8d a0 1e 10 f0 	mov    -0xfefe160(,%ecx,4),%ecx
f010042e:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100432:	a8 08                	test   $0x8,%al
f0100434:	74 19                	je     f010044f <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100436:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100439:	83 fa 19             	cmp    $0x19,%edx
f010043c:	77 05                	ja     f0100443 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010043e:	83 eb 20             	sub    $0x20,%ebx
f0100441:	eb 0c                	jmp    f010044f <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100443:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100446:	8d 53 20             	lea    0x20(%ebx),%edx
f0100449:	83 f9 19             	cmp    $0x19,%ecx
f010044c:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010044f:	f7 d0                	not    %eax
f0100451:	a8 06                	test   $0x6,%al
f0100453:	75 1f                	jne    f0100474 <kbd_proc_data+0xf8>
f0100455:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010045b:	75 17                	jne    f0100474 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010045d:	c7 04 24 6d 1c 10 f0 	movl   $0xf0101c6d,(%esp)
f0100464:	e8 e9 07 00 00       	call   f0100c52 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100469:	ba 92 00 00 00       	mov    $0x92,%edx
f010046e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100473:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100474:	89 d8                	mov    %ebx,%eax
f0100476:	83 c4 14             	add    $0x14,%esp
f0100479:	5b                   	pop    %ebx
f010047a:	5d                   	pop    %ebp
f010047b:	c3                   	ret    

f010047c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010047c:	55                   	push   %ebp
f010047d:	89 e5                	mov    %esp,%ebp
f010047f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100482:	80 3d 00 33 11 f0 00 	cmpb   $0x0,0xf0113300
f0100489:	74 0a                	je     f0100495 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010048b:	b8 4e 01 10 f0       	mov    $0xf010014e,%eax
f0100490:	e8 d5 fc ff ff       	call   f010016a <cons_intr>
}
f0100495:	c9                   	leave  
f0100496:	c3                   	ret    

f0100497 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100497:	55                   	push   %ebp
f0100498:	89 e5                	mov    %esp,%ebp
f010049a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010049d:	b8 7c 03 10 f0       	mov    $0xf010037c,%eax
f01004a2:	e8 c3 fc ff ff       	call   f010016a <cons_intr>
}
f01004a7:	c9                   	leave  
f01004a8:	c3                   	ret    

f01004a9 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004a9:	55                   	push   %ebp
f01004aa:	89 e5                	mov    %esp,%ebp
f01004ac:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004af:	e8 c8 ff ff ff       	call   f010047c <serial_intr>
	kbd_intr();
f01004b4:	e8 de ff ff ff       	call   f0100497 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004b9:	8b 15 20 35 11 f0    	mov    0xf0113520,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01004bf:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c4:	3b 15 24 35 11 f0    	cmp    0xf0113524,%edx
f01004ca:	74 1e                	je     f01004ea <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004cc:	0f b6 82 20 33 11 f0 	movzbl -0xfeecce0(%edx),%eax
f01004d3:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004d6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004e1:	0f 44 d1             	cmove  %ecx,%edx
f01004e4:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
		return c;
	}
	return 0;
}
f01004ea:	c9                   	leave  
f01004eb:	c3                   	ret    

f01004ec <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ec:	55                   	push   %ebp
f01004ed:	89 e5                	mov    %esp,%ebp
f01004ef:	57                   	push   %edi
f01004f0:	56                   	push   %esi
f01004f1:	53                   	push   %ebx
f01004f2:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f5:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004fc:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100503:	5a a5 
	if (*cp != 0xA55A) {
f0100505:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010050c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100510:	74 11                	je     f0100523 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100512:	c7 05 2c 35 11 f0 b4 	movl   $0x3b4,0xf011352c
f0100519:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010051c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100521:	eb 16                	jmp    f0100539 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100523:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010052a:	c7 05 2c 35 11 f0 d4 	movl   $0x3d4,0xf011352c
f0100531:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100534:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100539:	8b 0d 2c 35 11 f0    	mov    0xf011352c,%ecx
f010053f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100544:	89 ca                	mov    %ecx,%edx
f0100546:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100547:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054a:	89 da                	mov    %ebx,%edx
f010054c:	ec                   	in     (%dx),%al
f010054d:	0f b6 f8             	movzbl %al,%edi
f0100550:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100553:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100558:	89 ca                	mov    %ecx,%edx
f010055a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055b:	89 da                	mov    %ebx,%edx
f010055d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055e:	89 35 30 35 11 f0    	mov    %esi,0xf0113530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100564:	0f b6 d8             	movzbl %al,%ebx
f0100567:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100569:	66 89 3d 34 35 11 f0 	mov    %di,0xf0113534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100570:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100575:	b8 00 00 00 00       	mov    $0x0,%eax
f010057a:	89 da                	mov    %ebx,%edx
f010057c:	ee                   	out    %al,(%dx)
f010057d:	b2 fb                	mov    $0xfb,%dl
f010057f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100584:	ee                   	out    %al,(%dx)
f0100585:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010058a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058f:	89 ca                	mov    %ecx,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	b2 f9                	mov    $0xf9,%dl
f0100594:	b8 00 00 00 00       	mov    $0x0,%eax
f0100599:	ee                   	out    %al,(%dx)
f010059a:	b2 fb                	mov    $0xfb,%dl
f010059c:	b8 03 00 00 00       	mov    $0x3,%eax
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	b2 fc                	mov    $0xfc,%dl
f01005a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	b2 f9                	mov    $0xf9,%dl
f01005ac:	b8 01 00 00 00       	mov    $0x1,%eax
f01005b1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b2:	b2 fd                	mov    $0xfd,%dl
f01005b4:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b5:	3c ff                	cmp    $0xff,%al
f01005b7:	0f 95 c0             	setne  %al
f01005ba:	89 c6                	mov    %eax,%esi
f01005bc:	a2 00 33 11 f0       	mov    %al,0xf0113300
f01005c1:	89 da                	mov    %ebx,%edx
f01005c3:	ec                   	in     (%dx),%al
f01005c4:	89 ca                	mov    %ecx,%edx
f01005c6:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005c7:	89 f0                	mov    %esi,%eax
f01005c9:	84 c0                	test   %al,%al
f01005cb:	75 0c                	jne    f01005d9 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f01005cd:	c7 04 24 79 1c 10 f0 	movl   $0xf0101c79,(%esp)
f01005d4:	e8 79 06 00 00       	call   f0100c52 <cprintf>
}
f01005d9:	83 c4 1c             	add    $0x1c,%esp
f01005dc:	5b                   	pop    %ebx
f01005dd:	5e                   	pop    %esi
f01005de:	5f                   	pop    %edi
f01005df:	5d                   	pop    %ebp
f01005e0:	c3                   	ret    

f01005e1 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005e1:	55                   	push   %ebp
f01005e2:	89 e5                	mov    %esp,%ebp
f01005e4:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01005ea:	e8 b8 fb ff ff       	call   f01001a7 <cons_putc>
}
f01005ef:	c9                   	leave  
f01005f0:	c3                   	ret    

f01005f1 <getchar>:

int
getchar(void)
{
f01005f1:	55                   	push   %ebp
f01005f2:	89 e5                	mov    %esp,%ebp
f01005f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005f7:	e8 ad fe ff ff       	call   f01004a9 <cons_getc>
f01005fc:	85 c0                	test   %eax,%eax
f01005fe:	74 f7                	je     f01005f7 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <iscons>:

int
iscons(int fdnum)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100605:	b8 01 00 00 00       	mov    $0x1,%eax
f010060a:	5d                   	pop    %ebp
f010060b:	c3                   	ret    
f010060c:	00 00                	add    %al,(%eax)
	...

f0100610 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100616:	c7 04 24 b0 1e 10 f0 	movl   $0xf0101eb0,(%esp)
f010061d:	e8 30 06 00 00       	call   f0100c52 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100622:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100629:	00 
f010062a:	c7 04 24 70 1f 10 f0 	movl   $0xf0101f70,(%esp)
f0100631:	e8 1c 06 00 00       	call   f0100c52 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100636:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010063d:	00 
f010063e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100645:	f0 
f0100646:	c7 04 24 98 1f 10 f0 	movl   $0xf0101f98,(%esp)
f010064d:	e8 00 06 00 00       	call   f0100c52 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100652:	c7 44 24 08 05 1c 10 	movl   $0x101c05,0x8(%esp)
f0100659:	00 
f010065a:	c7 44 24 04 05 1c 10 	movl   $0xf0101c05,0x4(%esp)
f0100661:	f0 
f0100662:	c7 04 24 bc 1f 10 f0 	movl   $0xf0101fbc,(%esp)
f0100669:	e8 e4 05 00 00       	call   f0100c52 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010066e:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f0100675:	00 
f0100676:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 e0 1f 10 f0 	movl   $0xf0101fe0,(%esp)
f0100685:	e8 c8 05 00 00       	call   f0100c52 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010068a:	c7 44 24 08 50 39 11 	movl   $0x113950,0x8(%esp)
f0100691:	00 
f0100692:	c7 44 24 04 50 39 11 	movl   $0xf0113950,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 04 20 10 f0 	movl   $0xf0102004,(%esp)
f01006a1:	e8 ac 05 00 00       	call   f0100c52 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006a6:	b8 4f 3d 11 f0       	mov    $0xf0113d4f,%eax
f01006ab:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006b0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006b5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006bb:	85 c0                	test   %eax,%eax
f01006bd:	0f 48 c2             	cmovs  %edx,%eax
f01006c0:	c1 f8 0a             	sar    $0xa,%eax
f01006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006c7:	c7 04 24 28 20 10 f0 	movl   $0xf0102028,(%esp)
f01006ce:	e8 7f 05 00 00       	call   f0100c52 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	c9                   	leave  
f01006d9:	c3                   	ret    

f01006da <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006da:	55                   	push   %ebp
f01006db:	89 e5                	mov    %esp,%ebp
f01006dd:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006e0:	c7 44 24 08 c9 1e 10 	movl   $0xf0101ec9,0x8(%esp)
f01006e7:	f0 
f01006e8:	c7 44 24 04 e7 1e 10 	movl   $0xf0101ee7,0x4(%esp)
f01006ef:	f0 
f01006f0:	c7 04 24 ec 1e 10 f0 	movl   $0xf0101eec,(%esp)
f01006f7:	e8 56 05 00 00       	call   f0100c52 <cprintf>
f01006fc:	c7 44 24 08 54 20 10 	movl   $0xf0102054,0x8(%esp)
f0100703:	f0 
f0100704:	c7 44 24 04 f5 1e 10 	movl   $0xf0101ef5,0x4(%esp)
f010070b:	f0 
f010070c:	c7 04 24 ec 1e 10 f0 	movl   $0xf0101eec,(%esp)
f0100713:	e8 3a 05 00 00       	call   f0100c52 <cprintf>
	return 0;
}
f0100718:	b8 00 00 00 00       	mov    $0x0,%eax
f010071d:	c9                   	leave  
f010071e:	c3                   	ret    

f010071f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	struct Eipdebuginfo info;
f010071f:	55                   	push   %ebp
f0100720:	89 e5                	mov    %esp,%ebp
f0100722:	57                   	push   %edi
f0100723:	56                   	push   %esi
f0100724:	53                   	push   %ebx
f0100725:	83 ec 5c             	sub    $0x5c,%esp
	unsigned int *ebp=(unsigned int *)read_ebp();
f0100728:	89 ee                	mov    %ebp,%esi

static __inline uint32_t
read_esp(void)
{
	uint32_t esp;
	__asm __volatile("movl %%esp,%0" : "=r" (esp));
f010072a:	89 e0                	mov    %esp,%eax
	while(ebp)
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f010072c:	8d 7d d0             	lea    -0x30(%ebp),%edi
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f010072f:	e9 9c 00 00 00       	jmp    f01007d0 <mon_backtrace+0xb1>
f0100734:	b8 00 00 00 00       	mov    $0x0,%eax
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
f0100739:	8b 54 86 08          	mov    0x8(%esi,%eax,4),%edx
f010073d:	89 54 85 bc          	mov    %edx,-0x44(%ebp,%eax,4)
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
	{		
			for(i=0;i<5;i++)
f0100741:	83 c0 01             	add    $0x1,%eax
f0100744:	83 f8 05             	cmp    $0x5,%eax
f0100747:	75 f0                	jne    f0100739 <mon_backtrace+0x1a>
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f0100749:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010074d:	8b 46 04             	mov    0x4(%esi),%eax
f0100750:	89 04 24             	mov    %eax,(%esp)
f0100753:	e8 f8 05 00 00       	call   f0100d50 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100758:	8b 46 04             	mov    0x4(%esi),%eax
f010075b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010075f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100763:	c7 04 24 fe 1e 10 f0 	movl   $0xf0101efe,(%esp)
f010076a:	e8 e3 04 00 00       	call   f0100c52 <cprintf>
			for(i=0;i<5;++i)
f010076f:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%08x  ", arg[i]);
f0100774:	8b 44 9d bc          	mov    -0x44(%ebp,%ebx,4),%eax
f0100778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010077c:	c7 04 24 19 1f 10 f0 	movl   $0xf0101f19,(%esp)
f0100783:	e8 ca 04 00 00       	call   f0100c52 <cprintf>
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
			for(i=0;i<5;++i)
f0100788:	83 c3 01             	add    $0x1,%ebx
f010078b:	83 fb 05             	cmp    $0x5,%ebx
f010078e:	75 e4                	jne    f0100774 <mon_backtrace+0x55>
			cprintf("%08x  ", arg[i]);
			cprintf("\n");
f0100790:	c7 04 24 77 1c 10 f0 	movl   $0xf0101c77,(%esp)
f0100797:	e8 b6 04 00 00       	call   f0100c52 <cprintf>
			
			cprintf("\t\t%s:%u:%.*s+%u\n",
f010079c:	8b 46 04             	mov    0x4(%esi),%eax
f010079f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007a2:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01007a9:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01007b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c2:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f01007c9:	e8 84 04 00 00       	call   f0100c52 <cprintf>
				info.eip_line,
				info.eip_fn_namelen,
				info.eip_fn_name,
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
f01007ce:	8b 36                	mov    (%esi),%esi
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f01007d0:	85 f6                	test   %esi,%esi
f01007d2:	0f 85 5c ff ff ff    	jne    f0100734 <mon_backtrace+0x15>
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
	}
	return 0;
}
f01007d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007dd:	83 c4 5c             	add    $0x5c,%esp
f01007e0:	5b                   	pop    %ebx
f01007e1:	5e                   	pop    %esi
f01007e2:	5f                   	pop    %edi
f01007e3:	5d                   	pop    %ebp
f01007e4:	c3                   	ret    

f01007e5 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	57                   	push   %edi
f01007e9:	56                   	push   %esi
f01007ea:	53                   	push   %ebx
f01007eb:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007ee:	c7 04 24 7c 20 10 f0 	movl   $0xf010207c,(%esp)
f01007f5:	e8 58 04 00 00       	call   f0100c52 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007fa:	c7 04 24 a0 20 10 f0 	movl   $0xf01020a0,(%esp)
f0100801:	e8 4c 04 00 00       	call   f0100c52 <cprintf>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100806:	8d 7d a8             	lea    -0x58(%ebp),%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100809:	c7 04 24 31 1f 10 f0 	movl   $0xf0101f31,(%esp)
f0100810:	e8 cb 0c 00 00       	call   f01014e0 <readline>
f0100815:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100817:	85 c0                	test   %eax,%eax
f0100819:	74 ee                	je     f0100809 <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010081b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100822:	be 00 00 00 00       	mov    $0x0,%esi
f0100827:	eb 06                	jmp    f010082f <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100829:	c6 03 00             	movb   $0x0,(%ebx)
f010082c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010082f:	0f b6 03             	movzbl (%ebx),%eax
f0100832:	84 c0                	test   %al,%al
f0100834:	74 63                	je     f0100899 <monitor+0xb4>
f0100836:	0f be c0             	movsbl %al,%eax
f0100839:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083d:	c7 04 24 35 1f 10 f0 	movl   $0xf0101f35,(%esp)
f0100844:	e8 ad 0e 00 00       	call   f01016f6 <strchr>
f0100849:	85 c0                	test   %eax,%eax
f010084b:	75 dc                	jne    f0100829 <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f010084d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100850:	74 47                	je     f0100899 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100852:	83 fe 0f             	cmp    $0xf,%esi
f0100855:	75 16                	jne    f010086d <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100857:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010085e:	00 
f010085f:	c7 04 24 3a 1f 10 f0 	movl   $0xf0101f3a,(%esp)
f0100866:	e8 e7 03 00 00       	call   f0100c52 <cprintf>
f010086b:	eb 9c                	jmp    f0100809 <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f010086d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100871:	83 c6 01             	add    $0x1,%esi
f0100874:	eb 03                	jmp    f0100879 <monitor+0x94>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100876:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100879:	0f b6 03             	movzbl (%ebx),%eax
f010087c:	84 c0                	test   %al,%al
f010087e:	74 af                	je     f010082f <monitor+0x4a>
f0100880:	0f be c0             	movsbl %al,%eax
f0100883:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100887:	c7 04 24 35 1f 10 f0 	movl   $0xf0101f35,(%esp)
f010088e:	e8 63 0e 00 00       	call   f01016f6 <strchr>
f0100893:	85 c0                	test   %eax,%eax
f0100895:	74 df                	je     f0100876 <monitor+0x91>
f0100897:	eb 96                	jmp    f010082f <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100899:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008a0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008a1:	85 f6                	test   %esi,%esi
f01008a3:	0f 84 60 ff ff ff    	je     f0100809 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008a9:	c7 44 24 04 e7 1e 10 	movl   $0xf0101ee7,0x4(%esp)
f01008b0:	f0 
f01008b1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008b4:	89 04 24             	mov    %eax,(%esp)
f01008b7:	e8 db 0d 00 00       	call   f0101697 <strcmp>
f01008bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01008c1:	85 c0                	test   %eax,%eax
f01008c3:	74 1c                	je     f01008e1 <monitor+0xfc>
f01008c5:	c7 44 24 04 f5 1e 10 	movl   $0xf0101ef5,0x4(%esp)
f01008cc:	f0 
f01008cd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d0:	89 04 24             	mov    %eax,(%esp)
f01008d3:	e8 bf 0d 00 00       	call   f0101697 <strcmp>
f01008d8:	85 c0                	test   %eax,%eax
f01008da:	75 28                	jne    f0100904 <monitor+0x11f>
f01008dc:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008e1:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01008e4:	01 c2                	add    %eax,%edx
f01008e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01008f1:	89 34 24             	mov    %esi,(%esp)
f01008f4:	ff 14 95 d0 20 10 f0 	call   *-0xfefdf30(,%edx,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008fb:	85 c0                	test   %eax,%eax
f01008fd:	78 1d                	js     f010091c <monitor+0x137>
f01008ff:	e9 05 ff ff ff       	jmp    f0100809 <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100904:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100907:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090b:	c7 04 24 57 1f 10 f0 	movl   $0xf0101f57,(%esp)
f0100912:	e8 3b 03 00 00       	call   f0100c52 <cprintf>
f0100917:	e9 ed fe ff ff       	jmp    f0100809 <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010091c:	83 c4 5c             	add    $0x5c,%esp
f010091f:	5b                   	pop    %ebx
f0100920:	5e                   	pop    %esi
f0100921:	5f                   	pop    %edi
f0100922:	5d                   	pop    %ebp
f0100923:	c3                   	ret    

f0100924 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100924:	55                   	push   %ebp
f0100925:	89 e5                	mov    %esp,%ebp
f0100927:	56                   	push   %esi
f0100928:	53                   	push   %ebx
f0100929:	83 ec 10             	sub    $0x10,%esp
f010092c:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010092e:	89 04 24             	mov    %eax,(%esp)
f0100931:	e8 ae 02 00 00       	call   f0100be4 <mc146818_read>
f0100936:	89 c6                	mov    %eax,%esi
f0100938:	83 c3 01             	add    $0x1,%ebx
f010093b:	89 1c 24             	mov    %ebx,(%esp)
f010093e:	e8 a1 02 00 00       	call   f0100be4 <mc146818_read>
f0100943:	c1 e0 08             	shl    $0x8,%eax
f0100946:	09 f0                	or     %esi,%eax
}
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	5b                   	pop    %ebx
f010094c:	5e                   	pop    %esi
f010094d:	5d                   	pop    %ebp
f010094e:	c3                   	ret    

f010094f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010094f:	55                   	push   %ebp
f0100950:	89 e5                	mov    %esp,%ebp
f0100952:	83 ec 18             	sub    $0x18,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100955:	b8 15 00 00 00       	mov    $0x15,%eax
f010095a:	e8 c5 ff ff ff       	call   f0100924 <nvram_read>
f010095f:	c1 e0 0a             	shl    $0xa,%eax
f0100962:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100968:	85 c0                	test   %eax,%eax
f010096a:	0f 48 c2             	cmovs  %edx,%eax
f010096d:	c1 f8 0c             	sar    $0xc,%eax
f0100970:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100975:	b8 17 00 00 00       	mov    $0x17,%eax
f010097a:	e8 a5 ff ff ff       	call   f0100924 <nvram_read>
f010097f:	c1 e0 0a             	shl    $0xa,%eax
f0100982:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100988:	85 c0                	test   %eax,%eax
f010098a:	0f 48 c2             	cmovs  %edx,%eax
f010098d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100990:	85 c0                	test   %eax,%eax
f0100992:	74 0e                	je     f01009a2 <mem_init+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100994:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010099a:	89 15 44 39 11 f0    	mov    %edx,0xf0113944
f01009a0:	eb 0c                	jmp    f01009ae <mem_init+0x5f>
	else
		npages = npages_basemem;
f01009a2:	8b 15 38 35 11 f0    	mov    0xf0113538,%edx
f01009a8:	89 15 44 39 11 f0    	mov    %edx,0xf0113944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01009ae:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01009b1:	c1 e8 0a             	shr    $0xa,%eax
f01009b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01009b8:	a1 38 35 11 f0       	mov    0xf0113538,%eax
f01009bd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01009c0:	c1 e8 0a             	shr    $0xa,%eax
f01009c3:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01009c7:	a1 44 39 11 f0       	mov    0xf0113944,%eax
f01009cc:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01009cf:	c1 e8 0a             	shr    $0xa,%eax
f01009d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d6:	c7 04 24 e0 20 10 f0 	movl   $0xf01020e0,(%esp)
f01009dd:	e8 70 02 00 00       	call   f0100c52 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f01009e2:	c7 44 24 08 1c 21 10 	movl   $0xf010211c,0x8(%esp)
f01009e9:	f0 
f01009ea:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
f01009f1:	00 
f01009f2:	c7 04 24 ac 21 10 f0 	movl   $0xf01021ac,(%esp)
f01009f9:	e8 96 f6 ff ff       	call   f0100094 <_panic>

f01009fe <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01009fe:	55                   	push   %ebp
f01009ff:	89 e5                	mov    %esp,%ebp
f0100a01:	56                   	push   %esi
f0100a02:	53                   	push   %ebx
	for (i = 0; i < npages; i++) {
		if(i == 0)
			{	pages[i].pp_ref = 1;
				pages[i].pp_link = NULL;
			}
		if(i>=1 && i<npages_basemem)
f0100a03:	8b 35 38 35 11 f0    	mov    0xf0113538,%esi
f0100a09:	8b 1d 3c 35 11 f0    	mov    0xf011353c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a14:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a19:	e9 9b 00 00 00       	jmp    f0100ab9 <page_init+0xbb>
		if(i == 0)
f0100a1e:	85 c0                	test   %eax,%eax
f0100a20:	75 14                	jne    f0100a36 <page_init+0x38>
			{	pages[i].pp_ref = 1;
f0100a22:	8b 0d 4c 39 11 f0    	mov    0xf011394c,%ecx
f0100a28:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
				pages[i].pp_link = NULL;
f0100a2e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100a34:	eb 65                	jmp    f0100a9b <page_init+0x9d>
			}
		if(i>=1 && i<npages_basemem)
f0100a36:	39 f0                	cmp    %esi,%eax
f0100a38:	73 18                	jae    f0100a52 <page_init+0x54>
		{
			pages[i].pp_ref = 0;
f0100a3a:	89 d1                	mov    %edx,%ecx
f0100a3c:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
f0100a42:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list; 
f0100a48:	89 19                	mov    %ebx,(%ecx)
			page_free_list = &pages[i];
f0100a4a:	89 d3                	mov    %edx,%ebx
f0100a4c:	03 1d 4c 39 11 f0    	add    0xf011394c,%ebx
		}
		if(i>=IOPHYSMEM/PGSIZE && i< (unsigned int)EXTPHYSMEM/PGSIZE )
f0100a52:	8d 88 60 ff ff ff    	lea    -0xa0(%eax),%ecx
f0100a58:	83 f9 5f             	cmp    $0x5f,%ecx
f0100a5b:	77 14                	ja     f0100a71 <page_init+0x73>
		{
			pages[i].pp_ref = 1;
f0100a5d:	89 d1                	mov    %edx,%ecx
f0100a5f:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
f0100a65:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100a6b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		}
		if(i>=EXTPHYSMEM/PGSIZE && i< (unsigned int)kern_pgdir/PGSIZE)
f0100a71:	3d ff 00 00 00       	cmp    $0xff,%eax
f0100a76:	76 23                	jbe    f0100a9b <page_init+0x9d>
f0100a78:	8b 0d 48 39 11 f0    	mov    0xf0113948,%ecx
f0100a7e:	c1 e9 0c             	shr    $0xc,%ecx
f0100a81:	39 c8                	cmp    %ecx,%eax
f0100a83:	73 16                	jae    f0100a9b <page_init+0x9d>
		{
			pages[i].pp_ref = 1;
f0100a85:	89 d1                	mov    %edx,%ecx
f0100a87:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
f0100a8d:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
			pages[i].pp_link =NULL;
f0100a93:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100a99:	eb 18                	jmp    f0100ab3 <page_init+0xb5>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100a9b:	89 d1                	mov    %edx,%ecx
f0100a9d:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
f0100aa3:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100aa9:	89 19                	mov    %ebx,(%ecx)
			page_free_list = &pages[i];
f0100aab:	89 d3                	mov    %edx,%ebx
f0100aad:	03 1d 4c 39 11 f0    	add    0xf011394c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ab3:	83 c0 01             	add    $0x1,%eax
f0100ab6:	83 c2 08             	add    $0x8,%edx
f0100ab9:	3b 05 44 39 11 f0    	cmp    0xf0113944,%eax
f0100abf:	0f 82 59 ff ff ff    	jb     f0100a1e <page_init+0x20>
f0100ac5:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100acb:	5b                   	pop    %ebx
f0100acc:	5e                   	pop    %esi
f0100acd:	5d                   	pop    %ebp
f0100ace:	c3                   	ret    

f0100acf <page_alloc>:

//apply a page, if alloc_flage==0, do not initialize the page;
//if alloc_flags==1, initialize the page and make the entire page '\0';
struct PageInfo *
page_alloc(int alloc_flags)
{	
f0100acf:	55                   	push   %ebp
f0100ad0:	89 e5                	mov    %esp,%ebp
f0100ad2:	53                   	push   %ebx
f0100ad3:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100ad6:	8b 1d 3c 35 11 f0    	mov    0xf011353c,%ebx
f0100adc:	85 db                	test   %ebx,%ebx
f0100ade:	74 6b                	je     f0100b4b <page_alloc+0x7c>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100ae0:	8b 03                	mov    (%ebx),%eax
f0100ae2:	a3 3c 35 11 f0       	mov    %eax,0xf011353c
		page->pp_link = NULL;
f0100ae7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if(alloc_flags & ALLOC_ZERO)
f0100aed:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100af1:	74 58                	je     f0100b4b <page_alloc+0x7c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100af3:	89 d8                	mov    %ebx,%eax
f0100af5:	2b 05 4c 39 11 f0    	sub    0xf011394c,%eax
f0100afb:	c1 f8 03             	sar    $0x3,%eax
f0100afe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b01:	89 c2                	mov    %eax,%edx
f0100b03:	c1 ea 0c             	shr    $0xc,%edx
f0100b06:	3b 15 44 39 11 f0    	cmp    0xf0113944,%edx
f0100b0c:	72 20                	jb     f0100b2e <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b12:	c7 44 24 08 48 21 10 	movl   $0xf0102148,0x8(%esp)
f0100b19:	f0 
f0100b1a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100b21:	00 
f0100b22:	c7 04 24 b8 21 10 f0 	movl   $0xf01021b8,(%esp)
f0100b29:	e8 66 f5 ff ff       	call   f0100094 <_panic>
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
f0100b2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100b35:	00 
f0100b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b3d:	00 
	return (void *)(pa + KERNBASE);
f0100b3e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b43:	89 04 24             	mov    %eax,(%esp)
f0100b46:	e8 e8 0b 00 00       	call   f0101733 <memset>
	}

	return page;
}
f0100b4b:	89 d8                	mov    %ebx,%eax
f0100b4d:	83 c4 14             	add    $0x14,%esp
f0100b50:	5b                   	pop    %ebx
f0100b51:	5d                   	pop    %ebp
f0100b52:	c3                   	ret    

f0100b53 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100b53:	55                   	push   %ebp
f0100b54:	89 e5                	mov    %esp,%ebp
f0100b56:	83 ec 18             	sub    $0x18,%esp
f0100b59:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link !=NULL)
f0100b5c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100b61:	75 05                	jne    f0100b68 <page_free+0x15>
f0100b63:	83 38 00             	cmpl   $0x0,(%eax)
f0100b66:	74 1c                	je     f0100b84 <page_free+0x31>
		panic("pp_ref is not 0 or the pp_link is not NULL. The page is used\n");
f0100b68:	c7 44 24 08 6c 21 10 	movl   $0xf010216c,0x8(%esp)
f0100b6f:	f0 
f0100b70:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f0100b77:	00 
f0100b78:	c7 04 24 ac 21 10 f0 	movl   $0xf01021ac,(%esp)
f0100b7f:	e8 10 f5 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100b84:	8b 15 3c 35 11 f0    	mov    0xf011353c,%edx
f0100b8a:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100b8c:	a3 3c 35 11 f0       	mov    %eax,0xf011353c
	return;
}
f0100b91:	c9                   	leave  
f0100b92:	c3                   	ret    

f0100b93 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100b93:	55                   	push   %ebp
f0100b94:	89 e5                	mov    %esp,%ebp
f0100b96:	83 ec 18             	sub    $0x18,%esp
f0100b99:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100b9c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100ba0:	83 ea 01             	sub    $0x1,%edx
f0100ba3:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100ba7:	66 85 d2             	test   %dx,%dx
f0100baa:	75 08                	jne    f0100bb4 <page_decref+0x21>
		page_free(pp);
f0100bac:	89 04 24             	mov    %eax,(%esp)
f0100baf:	e8 9f ff ff ff       	call   f0100b53 <page_free>
}
f0100bb4:	c9                   	leave  
f0100bb5:	c3                   	ret    

f0100bb6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100bb6:	55                   	push   %ebp
f0100bb7:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100bb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bbe:	5d                   	pop    %ebp
f0100bbf:	c3                   	ret    

f0100bc0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100bc0:	55                   	push   %ebp
f0100bc1:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100bc3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc8:	5d                   	pop    %ebp
f0100bc9:	c3                   	ret    

f0100bca <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100bca:	55                   	push   %ebp
f0100bcb:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100bcd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd2:	5d                   	pop    %ebp
f0100bd3:	c3                   	ret    

f0100bd4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100bd4:	55                   	push   %ebp
f0100bd5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100bd7:	5d                   	pop    %ebp
f0100bd8:	c3                   	ret    

f0100bd9 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100bd9:	55                   	push   %ebp
f0100bda:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdf:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100be2:	5d                   	pop    %ebp
f0100be3:	c3                   	ret    

f0100be4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100be4:	55                   	push   %ebp
f0100be5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100be7:	ba 70 00 00 00       	mov    $0x70,%edx
f0100bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bef:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100bf0:	b2 71                	mov    $0x71,%dl
f0100bf2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100bf3:	0f b6 c0             	movzbl %al,%eax
}
f0100bf6:	5d                   	pop    %ebp
f0100bf7:	c3                   	ret    

f0100bf8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100bf8:	55                   	push   %ebp
f0100bf9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100bfb:	ba 70 00 00 00       	mov    $0x70,%edx
f0100c00:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c03:	ee                   	out    %al,(%dx)
f0100c04:	b2 71                	mov    $0x71,%dl
f0100c06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c09:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100c0a:	5d                   	pop    %ebp
f0100c0b:	c3                   	ret    

f0100c0c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100c0c:	55                   	push   %ebp
f0100c0d:	89 e5                	mov    %esp,%ebp
f0100c0f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100c12:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c15:	89 04 24             	mov    %eax,(%esp)
f0100c18:	e8 c4 f9 ff ff       	call   f01005e1 <cputchar>
	*cnt++;
}
f0100c1d:	c9                   	leave  
f0100c1e:	c3                   	ret    

f0100c1f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100c1f:	55                   	push   %ebp
f0100c20:	89 e5                	mov    %esp,%ebp
f0100c22:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100c25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c33:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c36:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c41:	c7 04 24 0c 0c 10 f0 	movl   $0xf0100c0c,(%esp)
f0100c48:	e8 30 04 00 00       	call   f010107d <vprintfmt>
	return cnt;
}
f0100c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c50:	c9                   	leave  
f0100c51:	c3                   	ret    

f0100c52 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c52:	55                   	push   %ebp
f0100c53:	89 e5                	mov    %esp,%ebp
f0100c55:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c58:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c62:	89 04 24             	mov    %eax,(%esp)
f0100c65:	e8 b5 ff ff ff       	call   f0100c1f <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c6a:	c9                   	leave  
f0100c6b:	c3                   	ret    
f0100c6c:	00 00                	add    %al,(%eax)
	...

f0100c70 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c70:	55                   	push   %ebp
f0100c71:	89 e5                	mov    %esp,%ebp
f0100c73:	57                   	push   %edi
f0100c74:	56                   	push   %esi
f0100c75:	53                   	push   %ebx
f0100c76:	83 ec 10             	sub    $0x10,%esp
f0100c79:	89 c3                	mov    %eax,%ebx
f0100c7b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100c7e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100c81:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c84:	8b 0a                	mov    (%edx),%ecx
f0100c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c89:	8b 00                	mov    (%eax),%eax
f0100c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c8e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100c95:	eb 77                	jmp    f0100d0e <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c9a:	01 c8                	add    %ecx,%eax
f0100c9c:	bf 02 00 00 00       	mov    $0x2,%edi
f0100ca1:	99                   	cltd   
f0100ca2:	f7 ff                	idiv   %edi
f0100ca4:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ca6:	eb 01                	jmp    f0100ca9 <stab_binsearch+0x39>
			m--;
f0100ca8:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ca9:	39 ca                	cmp    %ecx,%edx
f0100cab:	7c 1d                	jl     f0100cca <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100cad:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100cb0:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100cb5:	39 f7                	cmp    %esi,%edi
f0100cb7:	75 ef                	jne    f0100ca8 <stab_binsearch+0x38>
f0100cb9:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100cbc:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100cbf:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100cc3:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100cc6:	73 18                	jae    f0100ce0 <stab_binsearch+0x70>
f0100cc8:	eb 05                	jmp    f0100ccf <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100cca:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100ccd:	eb 3f                	jmp    f0100d0e <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100ccf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100cd2:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100cd4:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100cd7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100cde:	eb 2e                	jmp    f0100d0e <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100ce0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100ce3:	76 15                	jbe    f0100cfa <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100ce5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100ce8:	4f                   	dec    %edi
f0100ce9:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cef:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100cf1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100cf8:	eb 14                	jmp    f0100d0e <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100cfa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100cfd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100d00:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100d02:	ff 45 0c             	incl   0xc(%ebp)
f0100d05:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100d07:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100d0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100d11:	7e 84                	jle    f0100c97 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100d13:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100d17:	75 0d                	jne    f0100d26 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100d19:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d1c:	8b 02                	mov    (%edx),%eax
f0100d1e:	48                   	dec    %eax
f0100d1f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d22:	89 01                	mov    %eax,(%ecx)
f0100d24:	eb 22                	jmp    f0100d48 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d29:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100d2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d2e:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d30:	eb 01                	jmp    f0100d33 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100d32:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d33:	39 c1                	cmp    %eax,%ecx
f0100d35:	7d 0c                	jge    f0100d43 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100d37:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100d3a:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100d3f:	39 f2                	cmp    %esi,%edx
f0100d41:	75 ef                	jne    f0100d32 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100d43:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d46:	89 02                	mov    %eax,(%edx)
	}
}
f0100d48:	83 c4 10             	add    $0x10,%esp
f0100d4b:	5b                   	pop    %ebx
f0100d4c:	5e                   	pop    %esi
f0100d4d:	5f                   	pop    %edi
f0100d4e:	5d                   	pop    %ebp
f0100d4f:	c3                   	ret    

f0100d50 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d50:	55                   	push   %ebp
f0100d51:	89 e5                	mov    %esp,%ebp
f0100d53:	83 ec 38             	sub    $0x38,%esp
f0100d56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100d59:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100d5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100d5f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d65:	c7 03 c6 21 10 f0    	movl   $0xf01021c6,(%ebx)
	info->eip_line = 0;
f0100d6b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100d72:	c7 43 08 c6 21 10 f0 	movl   $0xf01021c6,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100d79:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100d80:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100d83:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d8a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100d90:	76 12                	jbe    f0100da4 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d92:	b8 ba 84 10 f0       	mov    $0xf01084ba,%eax
f0100d97:	3d a5 68 10 f0       	cmp    $0xf01068a5,%eax
f0100d9c:	0f 86 5a 01 00 00    	jbe    f0100efc <debuginfo_eip+0x1ac>
f0100da2:	eb 1c                	jmp    f0100dc0 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100da4:	c7 44 24 08 d0 21 10 	movl   $0xf01021d0,0x8(%esp)
f0100dab:	f0 
f0100dac:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100db3:	00 
f0100db4:	c7 04 24 dd 21 10 f0 	movl   $0xf01021dd,(%esp)
f0100dbb:	e8 d4 f2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100dc5:	80 3d b9 84 10 f0 00 	cmpb   $0x0,0xf01084b9
f0100dcc:	0f 85 36 01 00 00    	jne    f0100f08 <debuginfo_eip+0x1b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100dd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100dd9:	b8 a4 68 10 f0       	mov    $0xf01068a4,%eax
f0100dde:	2d 10 24 10 f0       	sub    $0xf0102410,%eax
f0100de3:	c1 f8 02             	sar    $0x2,%eax
f0100de6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100dec:	83 e8 01             	sub    $0x1,%eax
f0100def:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100df2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100df6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100dfd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100e00:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100e03:	b8 10 24 10 f0       	mov    $0xf0102410,%eax
f0100e08:	e8 63 fe ff ff       	call   f0100c70 <stab_binsearch>
	if (lfile == 0)
f0100e0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100e15:	85 d2                	test   %edx,%edx
f0100e17:	0f 84 eb 00 00 00    	je     f0100f08 <debuginfo_eip+0x1b8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100e1d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100e20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e23:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100e26:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e2a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100e31:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100e34:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e37:	b8 10 24 10 f0       	mov    $0xf0102410,%eax
f0100e3c:	e8 2f fe ff ff       	call   f0100c70 <stab_binsearch>

	if (lfun <= rfun) {
f0100e41:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100e44:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100e47:	7f 2e                	jg     f0100e77 <debuginfo_eip+0x127>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e49:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100e4c:	8d 90 10 24 10 f0    	lea    -0xfefdbf0(%eax),%edx
f0100e52:	8b 80 10 24 10 f0    	mov    -0xfefdbf0(%eax),%eax
f0100e58:	b9 ba 84 10 f0       	mov    $0xf01084ba,%ecx
f0100e5d:	81 e9 a5 68 10 f0    	sub    $0xf01068a5,%ecx
f0100e63:	39 c8                	cmp    %ecx,%eax
f0100e65:	73 08                	jae    f0100e6f <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e67:	05 a5 68 10 f0       	add    $0xf01068a5,%eax
f0100e6c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e6f:	8b 42 08             	mov    0x8(%edx),%eax
f0100e72:	89 43 10             	mov    %eax,0x10(%ebx)
f0100e75:	eb 06                	jmp    f0100e7d <debuginfo_eip+0x12d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100e77:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100e7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e7d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100e84:	00 
f0100e85:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e88:	89 04 24             	mov    %eax,(%esp)
f0100e8b:	e8 87 08 00 00       	call   f0101717 <strfind>
f0100e90:	2b 43 08             	sub    0x8(%ebx),%eax
f0100e93:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e96:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100e99:	eb 03                	jmp    f0100e9e <debuginfo_eip+0x14e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100e9b:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e9e:	39 cf                	cmp    %ecx,%edi
f0100ea0:	7c 27                	jl     f0100ec9 <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f0100ea2:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100ea5:	8d 14 85 10 24 10 f0 	lea    -0xfefdbf0(,%eax,4),%edx
f0100eac:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100eb0:	3c 84                	cmp    $0x84,%al
f0100eb2:	74 61                	je     f0100f15 <debuginfo_eip+0x1c5>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100eb4:	3c 64                	cmp    $0x64,%al
f0100eb6:	75 e3                	jne    f0100e9b <debuginfo_eip+0x14b>
f0100eb8:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100ebc:	74 dd                	je     f0100e9b <debuginfo_eip+0x14b>
f0100ebe:	66 90                	xchg   %ax,%ax
f0100ec0:	eb 53                	jmp    f0100f15 <debuginfo_eip+0x1c5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ec2:	05 a5 68 10 f0       	add    $0xf01068a5,%eax
f0100ec7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ec9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100ecc:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ecf:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ed4:	39 d1                	cmp    %edx,%ecx
f0100ed6:	7d 30                	jge    f0100f08 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
f0100ed8:	8d 41 01             	lea    0x1(%ecx),%eax
f0100edb:	eb 07                	jmp    f0100ee4 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100edd:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100ee1:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100ee4:	39 d0                	cmp    %edx,%eax
f0100ee6:	74 1b                	je     f0100f03 <debuginfo_eip+0x1b3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ee8:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100eeb:	80 3c 8d 14 24 10 f0 	cmpb   $0xa0,-0xfefdbec(,%ecx,4)
f0100ef2:	a0 
f0100ef3:	74 e8                	je     f0100edd <debuginfo_eip+0x18d>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ef5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efa:	eb 0c                	jmp    f0100f08 <debuginfo_eip+0x1b8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f01:	eb 05                	jmp    f0100f08 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f03:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f08:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100f0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100f0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100f11:	89 ec                	mov    %ebp,%esp
f0100f13:	5d                   	pop    %ebp
f0100f14:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f15:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100f18:	8b 87 10 24 10 f0    	mov    -0xfefdbf0(%edi),%eax
f0100f1e:	ba ba 84 10 f0       	mov    $0xf01084ba,%edx
f0100f23:	81 ea a5 68 10 f0    	sub    $0xf01068a5,%edx
f0100f29:	39 d0                	cmp    %edx,%eax
f0100f2b:	72 95                	jb     f0100ec2 <debuginfo_eip+0x172>
f0100f2d:	eb 9a                	jmp    f0100ec9 <debuginfo_eip+0x179>
	...

f0100f30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f30:	55                   	push   %ebp
f0100f31:	89 e5                	mov    %esp,%ebp
f0100f33:	57                   	push   %edi
f0100f34:	56                   	push   %esi
f0100f35:	53                   	push   %ebx
f0100f36:	83 ec 3c             	sub    $0x3c,%esp
f0100f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f3c:	89 d7                	mov    %edx,%edi
f0100f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f41:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f47:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f4a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f4d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f50:	85 c0                	test   %eax,%eax
f0100f52:	75 08                	jne    f0100f5c <printnum+0x2c>
f0100f54:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f57:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100f5a:	77 59                	ja     f0100fb5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f5c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100f60:	83 eb 01             	sub    $0x1,%ebx
f0100f63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f67:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f6e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100f72:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100f76:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100f7d:	00 
f0100f7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f81:	89 04 24             	mov    %eax,(%esp)
f0100f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f8b:	e8 d0 09 00 00       	call   f0101960 <__udivdi3>
f0100f90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100f94:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100f98:	89 04 24             	mov    %eax,(%esp)
f0100f9b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f9f:	89 fa                	mov    %edi,%edx
f0100fa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fa4:	e8 87 ff ff ff       	call   f0100f30 <printnum>
f0100fa9:	eb 11                	jmp    f0100fbc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100fab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100faf:	89 34 24             	mov    %esi,(%esp)
f0100fb2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100fb5:	83 eb 01             	sub    $0x1,%ebx
f0100fb8:	85 db                	test   %ebx,%ebx
f0100fba:	7f ef                	jg     f0100fab <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fc0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100fc4:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fc7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fcb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100fd2:	00 
f0100fd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fd6:	89 04 24             	mov    %eax,(%esp)
f0100fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fe0:	e8 ab 0a 00 00       	call   f0101a90 <__umoddi3>
f0100fe5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fe9:	0f be 80 eb 21 10 f0 	movsbl -0xfefde15(%eax),%eax
f0100ff0:	89 04 24             	mov    %eax,(%esp)
f0100ff3:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100ff6:	83 c4 3c             	add    $0x3c,%esp
f0100ff9:	5b                   	pop    %ebx
f0100ffa:	5e                   	pop    %esi
f0100ffb:	5f                   	pop    %edi
f0100ffc:	5d                   	pop    %ebp
f0100ffd:	c3                   	ret    

f0100ffe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ffe:	55                   	push   %ebp
f0100fff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101001:	83 fa 01             	cmp    $0x1,%edx
f0101004:	7e 0e                	jle    f0101014 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101006:	8b 10                	mov    (%eax),%edx
f0101008:	8d 4a 08             	lea    0x8(%edx),%ecx
f010100b:	89 08                	mov    %ecx,(%eax)
f010100d:	8b 02                	mov    (%edx),%eax
f010100f:	8b 52 04             	mov    0x4(%edx),%edx
f0101012:	eb 22                	jmp    f0101036 <getuint+0x38>
	else if (lflag)
f0101014:	85 d2                	test   %edx,%edx
f0101016:	74 10                	je     f0101028 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101018:	8b 10                	mov    (%eax),%edx
f010101a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010101d:	89 08                	mov    %ecx,(%eax)
f010101f:	8b 02                	mov    (%edx),%eax
f0101021:	ba 00 00 00 00       	mov    $0x0,%edx
f0101026:	eb 0e                	jmp    f0101036 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101028:	8b 10                	mov    (%eax),%edx
f010102a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010102d:	89 08                	mov    %ecx,(%eax)
f010102f:	8b 02                	mov    (%edx),%eax
f0101031:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101036:	5d                   	pop    %ebp
f0101037:	c3                   	ret    

f0101038 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101038:	55                   	push   %ebp
f0101039:	89 e5                	mov    %esp,%ebp
f010103b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010103e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101042:	8b 10                	mov    (%eax),%edx
f0101044:	3b 50 04             	cmp    0x4(%eax),%edx
f0101047:	73 0a                	jae    f0101053 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101049:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010104c:	88 0a                	mov    %cl,(%edx)
f010104e:	83 c2 01             	add    $0x1,%edx
f0101051:	89 10                	mov    %edx,(%eax)
}
f0101053:	5d                   	pop    %ebp
f0101054:	c3                   	ret    

f0101055 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101055:	55                   	push   %ebp
f0101056:	89 e5                	mov    %esp,%ebp
f0101058:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010105b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010105e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101062:	8b 45 10             	mov    0x10(%ebp),%eax
f0101065:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101069:	8b 45 0c             	mov    0xc(%ebp),%eax
f010106c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101070:	8b 45 08             	mov    0x8(%ebp),%eax
f0101073:	89 04 24             	mov    %eax,(%esp)
f0101076:	e8 02 00 00 00       	call   f010107d <vprintfmt>
	va_end(ap);
}
f010107b:	c9                   	leave  
f010107c:	c3                   	ret    

f010107d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010107d:	55                   	push   %ebp
f010107e:	89 e5                	mov    %esp,%ebp
f0101080:	57                   	push   %edi
f0101081:	56                   	push   %esi
f0101082:	53                   	push   %ebx
f0101083:	83 ec 4c             	sub    $0x4c,%esp
f0101086:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101089:	8b 75 10             	mov    0x10(%ebp),%esi
f010108c:	eb 12                	jmp    f01010a0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010108e:	85 c0                	test   %eax,%eax
f0101090:	0f 84 bf 03 00 00    	je     f0101455 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f0101096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010109a:	89 04 24             	mov    %eax,(%esp)
f010109d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01010a0:	0f b6 06             	movzbl (%esi),%eax
f01010a3:	83 c6 01             	add    $0x1,%esi
f01010a6:	83 f8 25             	cmp    $0x25,%eax
f01010a9:	75 e3                	jne    f010108e <vprintfmt+0x11>
f01010ab:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01010af:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01010b6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01010bb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01010ca:	eb 2b                	jmp    f01010f7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010cc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01010cf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01010d3:	eb 22                	jmp    f01010f7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01010d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01010dc:	eb 19                	jmp    f01010f7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01010e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01010e8:	eb 0d                	jmp    f01010f7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01010ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01010ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010f0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f7:	0f b6 16             	movzbl (%esi),%edx
f01010fa:	0f b6 c2             	movzbl %dl,%eax
f01010fd:	8d 7e 01             	lea    0x1(%esi),%edi
f0101100:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0101103:	83 ea 23             	sub    $0x23,%edx
f0101106:	80 fa 55             	cmp    $0x55,%dl
f0101109:	0f 87 28 03 00 00    	ja     f0101437 <vprintfmt+0x3ba>
f010110f:	0f b6 d2             	movzbl %dl,%edx
f0101112:	ff 24 95 80 22 10 f0 	jmp    *-0xfefdd80(,%edx,4)
f0101119:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010111c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101123:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101128:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010112b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010112f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101132:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101135:	83 fa 09             	cmp    $0x9,%edx
f0101138:	77 2f                	ja     f0101169 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010113a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010113d:	eb e9                	jmp    f0101128 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010113f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101142:	8d 50 04             	lea    0x4(%eax),%edx
f0101145:	89 55 14             	mov    %edx,0x14(%ebp)
f0101148:	8b 00                	mov    (%eax),%eax
f010114a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010114d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101150:	eb 1a                	jmp    f010116c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101152:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0101155:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101159:	79 9c                	jns    f01010f7 <vprintfmt+0x7a>
f010115b:	eb 81                	jmp    f01010de <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010115d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101160:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0101167:	eb 8e                	jmp    f01010f7 <vprintfmt+0x7a>
f0101169:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f010116c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101170:	79 85                	jns    f01010f7 <vprintfmt+0x7a>
f0101172:	e9 73 ff ff ff       	jmp    f01010ea <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101177:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010117a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010117d:	e9 75 ff ff ff       	jmp    f01010f7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101182:	8b 45 14             	mov    0x14(%ebp),%eax
f0101185:	8d 50 04             	lea    0x4(%eax),%edx
f0101188:	89 55 14             	mov    %edx,0x14(%ebp)
f010118b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010118f:	8b 00                	mov    (%eax),%eax
f0101191:	89 04 24             	mov    %eax,(%esp)
f0101194:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101197:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010119a:	e9 01 ff ff ff       	jmp    f01010a0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010119f:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a2:	8d 50 04             	lea    0x4(%eax),%edx
f01011a5:	89 55 14             	mov    %edx,0x14(%ebp)
f01011a8:	8b 00                	mov    (%eax),%eax
f01011aa:	89 c2                	mov    %eax,%edx
f01011ac:	c1 fa 1f             	sar    $0x1f,%edx
f01011af:	31 d0                	xor    %edx,%eax
f01011b1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01011b3:	83 f8 07             	cmp    $0x7,%eax
f01011b6:	7f 0b                	jg     f01011c3 <vprintfmt+0x146>
f01011b8:	8b 14 85 e0 23 10 f0 	mov    -0xfefdc20(,%eax,4),%edx
f01011bf:	85 d2                	test   %edx,%edx
f01011c1:	75 23                	jne    f01011e6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f01011c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011c7:	c7 44 24 08 03 22 10 	movl   $0xf0102203,0x8(%esp)
f01011ce:	f0 
f01011cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011d3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01011d6:	89 3c 24             	mov    %edi,(%esp)
f01011d9:	e8 77 fe ff ff       	call   f0101055 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011de:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01011e1:	e9 ba fe ff ff       	jmp    f01010a0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01011e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01011ea:	c7 44 24 08 0c 22 10 	movl   $0xf010220c,0x8(%esp)
f01011f1:	f0 
f01011f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011f6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01011f9:	89 3c 24             	mov    %edi,(%esp)
f01011fc:	e8 54 fe ff ff       	call   f0101055 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101201:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101204:	e9 97 fe ff ff       	jmp    f01010a0 <vprintfmt+0x23>
f0101209:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010120c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010120f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101212:	8b 45 14             	mov    0x14(%ebp),%eax
f0101215:	8d 50 04             	lea    0x4(%eax),%edx
f0101218:	89 55 14             	mov    %edx,0x14(%ebp)
f010121b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010121d:	85 f6                	test   %esi,%esi
f010121f:	ba fc 21 10 f0       	mov    $0xf01021fc,%edx
f0101224:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0101227:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010122b:	0f 8e 8c 00 00 00    	jle    f01012bd <vprintfmt+0x240>
f0101231:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0101235:	0f 84 82 00 00 00    	je     f01012bd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f010123b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010123f:	89 34 24             	mov    %esi,(%esp)
f0101242:	e8 81 03 00 00       	call   f01015c8 <strnlen>
f0101247:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010124a:	29 c2                	sub    %eax,%edx
f010124c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f010124f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0101253:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101256:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0101259:	89 de                	mov    %ebx,%esi
f010125b:	89 d3                	mov    %edx,%ebx
f010125d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010125f:	eb 0d                	jmp    f010126e <vprintfmt+0x1f1>
					putch(padc, putdat);
f0101261:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101265:	89 3c 24             	mov    %edi,(%esp)
f0101268:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010126b:	83 eb 01             	sub    $0x1,%ebx
f010126e:	85 db                	test   %ebx,%ebx
f0101270:	7f ef                	jg     f0101261 <vprintfmt+0x1e4>
f0101272:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101275:	89 f3                	mov    %esi,%ebx
f0101277:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f010127a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010127e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101283:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0101287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010128a:	29 c2                	sub    %eax,%edx
f010128c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010128f:	eb 2c                	jmp    f01012bd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101291:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101295:	74 18                	je     f01012af <vprintfmt+0x232>
f0101297:	8d 50 e0             	lea    -0x20(%eax),%edx
f010129a:	83 fa 5e             	cmp    $0x5e,%edx
f010129d:	76 10                	jbe    f01012af <vprintfmt+0x232>
					putch('?', putdat);
f010129f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012a3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01012aa:	ff 55 08             	call   *0x8(%ebp)
f01012ad:	eb 0a                	jmp    f01012b9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f01012af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012b3:	89 04 24             	mov    %eax,(%esp)
f01012b6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012b9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01012bd:	0f be 06             	movsbl (%esi),%eax
f01012c0:	83 c6 01             	add    $0x1,%esi
f01012c3:	85 c0                	test   %eax,%eax
f01012c5:	74 25                	je     f01012ec <vprintfmt+0x26f>
f01012c7:	85 ff                	test   %edi,%edi
f01012c9:	78 c6                	js     f0101291 <vprintfmt+0x214>
f01012cb:	83 ef 01             	sub    $0x1,%edi
f01012ce:	79 c1                	jns    f0101291 <vprintfmt+0x214>
f01012d0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012d3:	89 de                	mov    %ebx,%esi
f01012d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012d8:	eb 1a                	jmp    f01012f4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01012da:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01012e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01012e7:	83 eb 01             	sub    $0x1,%ebx
f01012ea:	eb 08                	jmp    f01012f4 <vprintfmt+0x277>
f01012ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012ef:	89 de                	mov    %ebx,%esi
f01012f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012f4:	85 db                	test   %ebx,%ebx
f01012f6:	7f e2                	jg     f01012da <vprintfmt+0x25d>
f01012f8:	89 7d 08             	mov    %edi,0x8(%ebp)
f01012fb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101300:	e9 9b fd ff ff       	jmp    f01010a0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101305:	83 f9 01             	cmp    $0x1,%ecx
f0101308:	7e 10                	jle    f010131a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f010130a:	8b 45 14             	mov    0x14(%ebp),%eax
f010130d:	8d 50 08             	lea    0x8(%eax),%edx
f0101310:	89 55 14             	mov    %edx,0x14(%ebp)
f0101313:	8b 30                	mov    (%eax),%esi
f0101315:	8b 78 04             	mov    0x4(%eax),%edi
f0101318:	eb 26                	jmp    f0101340 <vprintfmt+0x2c3>
	else if (lflag)
f010131a:	85 c9                	test   %ecx,%ecx
f010131c:	74 12                	je     f0101330 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f010131e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101321:	8d 50 04             	lea    0x4(%eax),%edx
f0101324:	89 55 14             	mov    %edx,0x14(%ebp)
f0101327:	8b 30                	mov    (%eax),%esi
f0101329:	89 f7                	mov    %esi,%edi
f010132b:	c1 ff 1f             	sar    $0x1f,%edi
f010132e:	eb 10                	jmp    f0101340 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f0101330:	8b 45 14             	mov    0x14(%ebp),%eax
f0101333:	8d 50 04             	lea    0x4(%eax),%edx
f0101336:	89 55 14             	mov    %edx,0x14(%ebp)
f0101339:	8b 30                	mov    (%eax),%esi
f010133b:	89 f7                	mov    %esi,%edi
f010133d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101340:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101345:	85 ff                	test   %edi,%edi
f0101347:	0f 89 ac 00 00 00    	jns    f01013f9 <vprintfmt+0x37c>
				putch('-', putdat);
f010134d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101351:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101358:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010135b:	f7 de                	neg    %esi
f010135d:	83 d7 00             	adc    $0x0,%edi
f0101360:	f7 df                	neg    %edi
			}
			base = 10;
f0101362:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101367:	e9 8d 00 00 00       	jmp    f01013f9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010136c:	89 ca                	mov    %ecx,%edx
f010136e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101371:	e8 88 fc ff ff       	call   f0100ffe <getuint>
f0101376:	89 c6                	mov    %eax,%esi
f0101378:	89 d7                	mov    %edx,%edi
			base = 10;
f010137a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010137f:	eb 78                	jmp    f01013f9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101381:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101385:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010138c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010138f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101393:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010139a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010139d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013a1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01013a8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01013ae:	e9 ed fc ff ff       	jmp    f01010a0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f01013b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013b7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01013be:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01013c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013c5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01013cc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01013cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d2:	8d 50 04             	lea    0x4(%eax),%edx
f01013d5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01013d8:	8b 30                	mov    (%eax),%esi
f01013da:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01013df:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01013e4:	eb 13                	jmp    f01013f9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013e6:	89 ca                	mov    %ecx,%edx
f01013e8:	8d 45 14             	lea    0x14(%ebp),%eax
f01013eb:	e8 0e fc ff ff       	call   f0100ffe <getuint>
f01013f0:	89 c6                	mov    %eax,%esi
f01013f2:	89 d7                	mov    %edx,%edi
			base = 16;
f01013f4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013f9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01013fd:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101404:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101408:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140c:	89 34 24             	mov    %esi,(%esp)
f010140f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101413:	89 da                	mov    %ebx,%edx
f0101415:	8b 45 08             	mov    0x8(%ebp),%eax
f0101418:	e8 13 fb ff ff       	call   f0100f30 <printnum>
			break;
f010141d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101420:	e9 7b fc ff ff       	jmp    f01010a0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101425:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101429:	89 04 24             	mov    %eax,(%esp)
f010142c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010142f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101432:	e9 69 fc ff ff       	jmp    f01010a0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101437:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010143b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101442:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101445:	eb 03                	jmp    f010144a <vprintfmt+0x3cd>
f0101447:	83 ee 01             	sub    $0x1,%esi
f010144a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010144e:	75 f7                	jne    f0101447 <vprintfmt+0x3ca>
f0101450:	e9 4b fc ff ff       	jmp    f01010a0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101455:	83 c4 4c             	add    $0x4c,%esp
f0101458:	5b                   	pop    %ebx
f0101459:	5e                   	pop    %esi
f010145a:	5f                   	pop    %edi
f010145b:	5d                   	pop    %ebp
f010145c:	c3                   	ret    

f010145d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010145d:	55                   	push   %ebp
f010145e:	89 e5                	mov    %esp,%ebp
f0101460:	83 ec 28             	sub    $0x28,%esp
f0101463:	8b 45 08             	mov    0x8(%ebp),%eax
f0101466:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101469:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010146c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101470:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101473:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010147a:	85 c0                	test   %eax,%eax
f010147c:	74 30                	je     f01014ae <vsnprintf+0x51>
f010147e:	85 d2                	test   %edx,%edx
f0101480:	7e 2c                	jle    f01014ae <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101482:	8b 45 14             	mov    0x14(%ebp),%eax
f0101485:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101489:	8b 45 10             	mov    0x10(%ebp),%eax
f010148c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101490:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101493:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101497:	c7 04 24 38 10 10 f0 	movl   $0xf0101038,(%esp)
f010149e:	e8 da fb ff ff       	call   f010107d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014ac:	eb 05                	jmp    f01014b3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01014ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01014b3:	c9                   	leave  
f01014b4:	c3                   	ret    

f01014b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014b5:	55                   	push   %ebp
f01014b6:	89 e5                	mov    %esp,%ebp
f01014b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01014c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d3:	89 04 24             	mov    %eax,(%esp)
f01014d6:	e8 82 ff ff ff       	call   f010145d <vsnprintf>
	va_end(ap);

	return rc;
}
f01014db:	c9                   	leave  
f01014dc:	c3                   	ret    
f01014dd:	00 00                	add    %al,(%eax)
	...

f01014e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014e0:	55                   	push   %ebp
f01014e1:	89 e5                	mov    %esp,%ebp
f01014e3:	57                   	push   %edi
f01014e4:	56                   	push   %esi
f01014e5:	53                   	push   %ebx
f01014e6:	83 ec 1c             	sub    $0x1c,%esp
f01014e9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014ec:	85 c0                	test   %eax,%eax
f01014ee:	74 10                	je     f0101500 <readline+0x20>
		cprintf("%s", prompt);
f01014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014f4:	c7 04 24 0c 22 10 f0 	movl   $0xf010220c,(%esp)
f01014fb:	e8 52 f7 ff ff       	call   f0100c52 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101507:	e8 f6 f0 ff ff       	call   f0100602 <iscons>
f010150c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010150e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101513:	e8 d9 f0 ff ff       	call   f01005f1 <getchar>
f0101518:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010151a:	85 c0                	test   %eax,%eax
f010151c:	79 17                	jns    f0101535 <readline+0x55>
			cprintf("read error: %e\n", c);
f010151e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101522:	c7 04 24 00 24 10 f0 	movl   $0xf0102400,(%esp)
f0101529:	e8 24 f7 ff ff       	call   f0100c52 <cprintf>
			return NULL;
f010152e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101533:	eb 6d                	jmp    f01015a2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101535:	83 f8 08             	cmp    $0x8,%eax
f0101538:	74 05                	je     f010153f <readline+0x5f>
f010153a:	83 f8 7f             	cmp    $0x7f,%eax
f010153d:	75 19                	jne    f0101558 <readline+0x78>
f010153f:	85 f6                	test   %esi,%esi
f0101541:	7e 15                	jle    f0101558 <readline+0x78>
			if (echoing)
f0101543:	85 ff                	test   %edi,%edi
f0101545:	74 0c                	je     f0101553 <readline+0x73>
				cputchar('\b');
f0101547:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010154e:	e8 8e f0 ff ff       	call   f01005e1 <cputchar>
			i--;
f0101553:	83 ee 01             	sub    $0x1,%esi
f0101556:	eb bb                	jmp    f0101513 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101558:	83 fb 1f             	cmp    $0x1f,%ebx
f010155b:	7e 1f                	jle    f010157c <readline+0x9c>
f010155d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101563:	7f 17                	jg     f010157c <readline+0x9c>
			if (echoing)
f0101565:	85 ff                	test   %edi,%edi
f0101567:	74 08                	je     f0101571 <readline+0x91>
				cputchar(c);
f0101569:	89 1c 24             	mov    %ebx,(%esp)
f010156c:	e8 70 f0 ff ff       	call   f01005e1 <cputchar>
			buf[i++] = c;
f0101571:	88 9e 40 35 11 f0    	mov    %bl,-0xfeecac0(%esi)
f0101577:	83 c6 01             	add    $0x1,%esi
f010157a:	eb 97                	jmp    f0101513 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010157c:	83 fb 0a             	cmp    $0xa,%ebx
f010157f:	74 05                	je     f0101586 <readline+0xa6>
f0101581:	83 fb 0d             	cmp    $0xd,%ebx
f0101584:	75 8d                	jne    f0101513 <readline+0x33>
			if (echoing)
f0101586:	85 ff                	test   %edi,%edi
f0101588:	74 0c                	je     f0101596 <readline+0xb6>
				cputchar('\n');
f010158a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101591:	e8 4b f0 ff ff       	call   f01005e1 <cputchar>
			buf[i] = 0;
f0101596:	c6 86 40 35 11 f0 00 	movb   $0x0,-0xfeecac0(%esi)
			return buf;
f010159d:	b8 40 35 11 f0       	mov    $0xf0113540,%eax
		}
	}
}
f01015a2:	83 c4 1c             	add    $0x1c,%esp
f01015a5:	5b                   	pop    %ebx
f01015a6:	5e                   	pop    %esi
f01015a7:	5f                   	pop    %edi
f01015a8:	5d                   	pop    %ebp
f01015a9:	c3                   	ret    
f01015aa:	00 00                	add    %al,(%eax)
f01015ac:	00 00                	add    %al,(%eax)
	...

f01015b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015bb:	eb 03                	jmp    f01015c0 <strlen+0x10>
		n++;
f01015bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01015c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015c4:	75 f7                	jne    f01015bd <strlen+0xd>
		n++;
	return n;
}
f01015c6:	5d                   	pop    %ebp
f01015c7:	c3                   	ret    

f01015c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015c8:	55                   	push   %ebp
f01015c9:	89 e5                	mov    %esp,%ebp
f01015cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01015ce:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d6:	eb 03                	jmp    f01015db <strnlen+0x13>
		n++;
f01015d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015db:	39 d0                	cmp    %edx,%eax
f01015dd:	74 06                	je     f01015e5 <strnlen+0x1d>
f01015df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015e3:	75 f3                	jne    f01015d8 <strnlen+0x10>
		n++;
	return n;
}
f01015e5:	5d                   	pop    %ebp
f01015e6:	c3                   	ret    

f01015e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015e7:	55                   	push   %ebp
f01015e8:	89 e5                	mov    %esp,%ebp
f01015ea:	53                   	push   %ebx
f01015eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01015f6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01015fa:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015fd:	83 c2 01             	add    $0x1,%edx
f0101600:	84 c9                	test   %cl,%cl
f0101602:	75 f2                	jne    f01015f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101604:	5b                   	pop    %ebx
f0101605:	5d                   	pop    %ebp
f0101606:	c3                   	ret    

f0101607 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
f010160a:	53                   	push   %ebx
f010160b:	83 ec 08             	sub    $0x8,%esp
f010160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101611:	89 1c 24             	mov    %ebx,(%esp)
f0101614:	e8 97 ff ff ff       	call   f01015b0 <strlen>
	strcpy(dst + len, src);
f0101619:	8b 55 0c             	mov    0xc(%ebp),%edx
f010161c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101620:	01 d8                	add    %ebx,%eax
f0101622:	89 04 24             	mov    %eax,(%esp)
f0101625:	e8 bd ff ff ff       	call   f01015e7 <strcpy>
	return dst;
}
f010162a:	89 d8                	mov    %ebx,%eax
f010162c:	83 c4 08             	add    $0x8,%esp
f010162f:	5b                   	pop    %ebx
f0101630:	5d                   	pop    %ebp
f0101631:	c3                   	ret    

f0101632 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101632:	55                   	push   %ebp
f0101633:	89 e5                	mov    %esp,%ebp
f0101635:	56                   	push   %esi
f0101636:	53                   	push   %ebx
f0101637:	8b 45 08             	mov    0x8(%ebp),%eax
f010163a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010163d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101640:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101645:	eb 0f                	jmp    f0101656 <strncpy+0x24>
		*dst++ = *src;
f0101647:	0f b6 1a             	movzbl (%edx),%ebx
f010164a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010164d:	80 3a 01             	cmpb   $0x1,(%edx)
f0101650:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101653:	83 c1 01             	add    $0x1,%ecx
f0101656:	39 f1                	cmp    %esi,%ecx
f0101658:	75 ed                	jne    f0101647 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010165a:	5b                   	pop    %ebx
f010165b:	5e                   	pop    %esi
f010165c:	5d                   	pop    %ebp
f010165d:	c3                   	ret    

f010165e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010165e:	55                   	push   %ebp
f010165f:	89 e5                	mov    %esp,%ebp
f0101661:	56                   	push   %esi
f0101662:	53                   	push   %ebx
f0101663:	8b 75 08             	mov    0x8(%ebp),%esi
f0101666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101669:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010166c:	89 f0                	mov    %esi,%eax
f010166e:	85 d2                	test   %edx,%edx
f0101670:	75 0a                	jne    f010167c <strlcpy+0x1e>
f0101672:	eb 1d                	jmp    f0101691 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101674:	88 18                	mov    %bl,(%eax)
f0101676:	83 c0 01             	add    $0x1,%eax
f0101679:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010167c:	83 ea 01             	sub    $0x1,%edx
f010167f:	74 0b                	je     f010168c <strlcpy+0x2e>
f0101681:	0f b6 19             	movzbl (%ecx),%ebx
f0101684:	84 db                	test   %bl,%bl
f0101686:	75 ec                	jne    f0101674 <strlcpy+0x16>
f0101688:	89 c2                	mov    %eax,%edx
f010168a:	eb 02                	jmp    f010168e <strlcpy+0x30>
f010168c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010168e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101691:	29 f0                	sub    %esi,%eax
}
f0101693:	5b                   	pop    %ebx
f0101694:	5e                   	pop    %esi
f0101695:	5d                   	pop    %ebp
f0101696:	c3                   	ret    

f0101697 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101697:	55                   	push   %ebp
f0101698:	89 e5                	mov    %esp,%ebp
f010169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010169d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016a0:	eb 06                	jmp    f01016a8 <strcmp+0x11>
		p++, q++;
f01016a2:	83 c1 01             	add    $0x1,%ecx
f01016a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01016a8:	0f b6 01             	movzbl (%ecx),%eax
f01016ab:	84 c0                	test   %al,%al
f01016ad:	74 04                	je     f01016b3 <strcmp+0x1c>
f01016af:	3a 02                	cmp    (%edx),%al
f01016b1:	74 ef                	je     f01016a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016b3:	0f b6 c0             	movzbl %al,%eax
f01016b6:	0f b6 12             	movzbl (%edx),%edx
f01016b9:	29 d0                	sub    %edx,%eax
}
f01016bb:	5d                   	pop    %ebp
f01016bc:	c3                   	ret    

f01016bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016bd:	55                   	push   %ebp
f01016be:	89 e5                	mov    %esp,%ebp
f01016c0:	53                   	push   %ebx
f01016c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01016c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01016c7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01016ca:	eb 09                	jmp    f01016d5 <strncmp+0x18>
		n--, p++, q++;
f01016cc:	83 ea 01             	sub    $0x1,%edx
f01016cf:	83 c0 01             	add    $0x1,%eax
f01016d2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01016d5:	85 d2                	test   %edx,%edx
f01016d7:	74 15                	je     f01016ee <strncmp+0x31>
f01016d9:	0f b6 18             	movzbl (%eax),%ebx
f01016dc:	84 db                	test   %bl,%bl
f01016de:	74 04                	je     f01016e4 <strncmp+0x27>
f01016e0:	3a 19                	cmp    (%ecx),%bl
f01016e2:	74 e8                	je     f01016cc <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016e4:	0f b6 00             	movzbl (%eax),%eax
f01016e7:	0f b6 11             	movzbl (%ecx),%edx
f01016ea:	29 d0                	sub    %edx,%eax
f01016ec:	eb 05                	jmp    f01016f3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01016ee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01016f3:	5b                   	pop    %ebx
f01016f4:	5d                   	pop    %ebp
f01016f5:	c3                   	ret    

f01016f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016f6:	55                   	push   %ebp
f01016f7:	89 e5                	mov    %esp,%ebp
f01016f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101700:	eb 07                	jmp    f0101709 <strchr+0x13>
		if (*s == c)
f0101702:	38 ca                	cmp    %cl,%dl
f0101704:	74 0f                	je     f0101715 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101706:	83 c0 01             	add    $0x1,%eax
f0101709:	0f b6 10             	movzbl (%eax),%edx
f010170c:	84 d2                	test   %dl,%dl
f010170e:	75 f2                	jne    f0101702 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101710:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101715:	5d                   	pop    %ebp
f0101716:	c3                   	ret    

f0101717 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101717:	55                   	push   %ebp
f0101718:	89 e5                	mov    %esp,%ebp
f010171a:	8b 45 08             	mov    0x8(%ebp),%eax
f010171d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101721:	eb 07                	jmp    f010172a <strfind+0x13>
		if (*s == c)
f0101723:	38 ca                	cmp    %cl,%dl
f0101725:	74 0a                	je     f0101731 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101727:	83 c0 01             	add    $0x1,%eax
f010172a:	0f b6 10             	movzbl (%eax),%edx
f010172d:	84 d2                	test   %dl,%dl
f010172f:	75 f2                	jne    f0101723 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0101731:	5d                   	pop    %ebp
f0101732:	c3                   	ret    

f0101733 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101733:	55                   	push   %ebp
f0101734:	89 e5                	mov    %esp,%ebp
f0101736:	83 ec 0c             	sub    $0xc,%esp
f0101739:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010173c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010173f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101742:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101745:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101748:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010174b:	85 c9                	test   %ecx,%ecx
f010174d:	74 30                	je     f010177f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010174f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101755:	75 25                	jne    f010177c <memset+0x49>
f0101757:	f6 c1 03             	test   $0x3,%cl
f010175a:	75 20                	jne    f010177c <memset+0x49>
		c &= 0xFF;
f010175c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010175f:	89 d3                	mov    %edx,%ebx
f0101761:	c1 e3 08             	shl    $0x8,%ebx
f0101764:	89 d6                	mov    %edx,%esi
f0101766:	c1 e6 18             	shl    $0x18,%esi
f0101769:	89 d0                	mov    %edx,%eax
f010176b:	c1 e0 10             	shl    $0x10,%eax
f010176e:	09 f0                	or     %esi,%eax
f0101770:	09 d0                	or     %edx,%eax
f0101772:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101774:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101777:	fc                   	cld    
f0101778:	f3 ab                	rep stos %eax,%es:(%edi)
f010177a:	eb 03                	jmp    f010177f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010177c:	fc                   	cld    
f010177d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010177f:	89 f8                	mov    %edi,%eax
f0101781:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101784:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101787:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010178a:	89 ec                	mov    %ebp,%esp
f010178c:	5d                   	pop    %ebp
f010178d:	c3                   	ret    

f010178e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010178e:	55                   	push   %ebp
f010178f:	89 e5                	mov    %esp,%ebp
f0101791:	83 ec 08             	sub    $0x8,%esp
f0101794:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101797:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010179a:	8b 45 08             	mov    0x8(%ebp),%eax
f010179d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017a3:	39 c6                	cmp    %eax,%esi
f01017a5:	73 36                	jae    f01017dd <memmove+0x4f>
f01017a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017aa:	39 d0                	cmp    %edx,%eax
f01017ac:	73 2f                	jae    f01017dd <memmove+0x4f>
		s += n;
		d += n;
f01017ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017b1:	f6 c2 03             	test   $0x3,%dl
f01017b4:	75 1b                	jne    f01017d1 <memmove+0x43>
f01017b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017bc:	75 13                	jne    f01017d1 <memmove+0x43>
f01017be:	f6 c1 03             	test   $0x3,%cl
f01017c1:	75 0e                	jne    f01017d1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017c3:	83 ef 04             	sub    $0x4,%edi
f01017c6:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017c9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01017cc:	fd                   	std    
f01017cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017cf:	eb 09                	jmp    f01017da <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017d1:	83 ef 01             	sub    $0x1,%edi
f01017d4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01017d7:	fd                   	std    
f01017d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017da:	fc                   	cld    
f01017db:	eb 20                	jmp    f01017fd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017e3:	75 13                	jne    f01017f8 <memmove+0x6a>
f01017e5:	a8 03                	test   $0x3,%al
f01017e7:	75 0f                	jne    f01017f8 <memmove+0x6a>
f01017e9:	f6 c1 03             	test   $0x3,%cl
f01017ec:	75 0a                	jne    f01017f8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017ee:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01017f1:	89 c7                	mov    %eax,%edi
f01017f3:	fc                   	cld    
f01017f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017f6:	eb 05                	jmp    f01017fd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017f8:	89 c7                	mov    %eax,%edi
f01017fa:	fc                   	cld    
f01017fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101800:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101803:	89 ec                	mov    %ebp,%esp
f0101805:	5d                   	pop    %ebp
f0101806:	c3                   	ret    

f0101807 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101807:	55                   	push   %ebp
f0101808:	89 e5                	mov    %esp,%ebp
f010180a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010180d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101810:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101814:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101817:	89 44 24 04          	mov    %eax,0x4(%esp)
f010181b:	8b 45 08             	mov    0x8(%ebp),%eax
f010181e:	89 04 24             	mov    %eax,(%esp)
f0101821:	e8 68 ff ff ff       	call   f010178e <memmove>
}
f0101826:	c9                   	leave  
f0101827:	c3                   	ret    

f0101828 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101828:	55                   	push   %ebp
f0101829:	89 e5                	mov    %esp,%ebp
f010182b:	57                   	push   %edi
f010182c:	56                   	push   %esi
f010182d:	53                   	push   %ebx
f010182e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101831:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101834:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101837:	ba 00 00 00 00       	mov    $0x0,%edx
f010183c:	eb 1a                	jmp    f0101858 <memcmp+0x30>
		if (*s1 != *s2)
f010183e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0101842:	83 c2 01             	add    $0x1,%edx
f0101845:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f010184a:	38 c8                	cmp    %cl,%al
f010184c:	74 0a                	je     f0101858 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f010184e:	0f b6 c0             	movzbl %al,%eax
f0101851:	0f b6 c9             	movzbl %cl,%ecx
f0101854:	29 c8                	sub    %ecx,%eax
f0101856:	eb 09                	jmp    f0101861 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101858:	39 da                	cmp    %ebx,%edx
f010185a:	75 e2                	jne    f010183e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010185c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101861:	5b                   	pop    %ebx
f0101862:	5e                   	pop    %esi
f0101863:	5f                   	pop    %edi
f0101864:	5d                   	pop    %ebp
f0101865:	c3                   	ret    

f0101866 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101866:	55                   	push   %ebp
f0101867:	89 e5                	mov    %esp,%ebp
f0101869:	8b 45 08             	mov    0x8(%ebp),%eax
f010186c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010186f:	89 c2                	mov    %eax,%edx
f0101871:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101874:	eb 07                	jmp    f010187d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101876:	38 08                	cmp    %cl,(%eax)
f0101878:	74 07                	je     f0101881 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010187a:	83 c0 01             	add    $0x1,%eax
f010187d:	39 d0                	cmp    %edx,%eax
f010187f:	72 f5                	jb     f0101876 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101881:	5d                   	pop    %ebp
f0101882:	c3                   	ret    

f0101883 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101883:	55                   	push   %ebp
f0101884:	89 e5                	mov    %esp,%ebp
f0101886:	57                   	push   %edi
f0101887:	56                   	push   %esi
f0101888:	53                   	push   %ebx
f0101889:	8b 55 08             	mov    0x8(%ebp),%edx
f010188c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010188f:	eb 03                	jmp    f0101894 <strtol+0x11>
		s++;
f0101891:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101894:	0f b6 02             	movzbl (%edx),%eax
f0101897:	3c 20                	cmp    $0x20,%al
f0101899:	74 f6                	je     f0101891 <strtol+0xe>
f010189b:	3c 09                	cmp    $0x9,%al
f010189d:	74 f2                	je     f0101891 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010189f:	3c 2b                	cmp    $0x2b,%al
f01018a1:	75 0a                	jne    f01018ad <strtol+0x2a>
		s++;
f01018a3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01018a6:	bf 00 00 00 00       	mov    $0x0,%edi
f01018ab:	eb 10                	jmp    f01018bd <strtol+0x3a>
f01018ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01018b2:	3c 2d                	cmp    $0x2d,%al
f01018b4:	75 07                	jne    f01018bd <strtol+0x3a>
		s++, neg = 1;
f01018b6:	8d 52 01             	lea    0x1(%edx),%edx
f01018b9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018bd:	85 db                	test   %ebx,%ebx
f01018bf:	0f 94 c0             	sete   %al
f01018c2:	74 05                	je     f01018c9 <strtol+0x46>
f01018c4:	83 fb 10             	cmp    $0x10,%ebx
f01018c7:	75 15                	jne    f01018de <strtol+0x5b>
f01018c9:	80 3a 30             	cmpb   $0x30,(%edx)
f01018cc:	75 10                	jne    f01018de <strtol+0x5b>
f01018ce:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01018d2:	75 0a                	jne    f01018de <strtol+0x5b>
		s += 2, base = 16;
f01018d4:	83 c2 02             	add    $0x2,%edx
f01018d7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018dc:	eb 13                	jmp    f01018f1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01018de:	84 c0                	test   %al,%al
f01018e0:	74 0f                	je     f01018f1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018e7:	80 3a 30             	cmpb   $0x30,(%edx)
f01018ea:	75 05                	jne    f01018f1 <strtol+0x6e>
		s++, base = 8;
f01018ec:	83 c2 01             	add    $0x1,%edx
f01018ef:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01018f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01018f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01018f8:	0f b6 0a             	movzbl (%edx),%ecx
f01018fb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01018fe:	80 fb 09             	cmp    $0x9,%bl
f0101901:	77 08                	ja     f010190b <strtol+0x88>
			dig = *s - '0';
f0101903:	0f be c9             	movsbl %cl,%ecx
f0101906:	83 e9 30             	sub    $0x30,%ecx
f0101909:	eb 1e                	jmp    f0101929 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f010190b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010190e:	80 fb 19             	cmp    $0x19,%bl
f0101911:	77 08                	ja     f010191b <strtol+0x98>
			dig = *s - 'a' + 10;
f0101913:	0f be c9             	movsbl %cl,%ecx
f0101916:	83 e9 57             	sub    $0x57,%ecx
f0101919:	eb 0e                	jmp    f0101929 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010191b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010191e:	80 fb 19             	cmp    $0x19,%bl
f0101921:	77 14                	ja     f0101937 <strtol+0xb4>
			dig = *s - 'A' + 10;
f0101923:	0f be c9             	movsbl %cl,%ecx
f0101926:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101929:	39 f1                	cmp    %esi,%ecx
f010192b:	7d 0e                	jge    f010193b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f010192d:	83 c2 01             	add    $0x1,%edx
f0101930:	0f af c6             	imul   %esi,%eax
f0101933:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0101935:	eb c1                	jmp    f01018f8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101937:	89 c1                	mov    %eax,%ecx
f0101939:	eb 02                	jmp    f010193d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010193b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010193d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101941:	74 05                	je     f0101948 <strtol+0xc5>
		*endptr = (char *) s;
f0101943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101946:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101948:	89 ca                	mov    %ecx,%edx
f010194a:	f7 da                	neg    %edx
f010194c:	85 ff                	test   %edi,%edi
f010194e:	0f 45 c2             	cmovne %edx,%eax
}
f0101951:	5b                   	pop    %ebx
f0101952:	5e                   	pop    %esi
f0101953:	5f                   	pop    %edi
f0101954:	5d                   	pop    %ebp
f0101955:	c3                   	ret    
	...

f0101960 <__udivdi3>:
f0101960:	83 ec 1c             	sub    $0x1c,%esp
f0101963:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101967:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010196b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010196f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101973:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101977:	8b 74 24 24          	mov    0x24(%esp),%esi
f010197b:	85 ff                	test   %edi,%edi
f010197d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101981:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101985:	89 cd                	mov    %ecx,%ebp
f0101987:	89 44 24 04          	mov    %eax,0x4(%esp)
f010198b:	75 33                	jne    f01019c0 <__udivdi3+0x60>
f010198d:	39 f1                	cmp    %esi,%ecx
f010198f:	77 57                	ja     f01019e8 <__udivdi3+0x88>
f0101991:	85 c9                	test   %ecx,%ecx
f0101993:	75 0b                	jne    f01019a0 <__udivdi3+0x40>
f0101995:	b8 01 00 00 00       	mov    $0x1,%eax
f010199a:	31 d2                	xor    %edx,%edx
f010199c:	f7 f1                	div    %ecx
f010199e:	89 c1                	mov    %eax,%ecx
f01019a0:	89 f0                	mov    %esi,%eax
f01019a2:	31 d2                	xor    %edx,%edx
f01019a4:	f7 f1                	div    %ecx
f01019a6:	89 c6                	mov    %eax,%esi
f01019a8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01019ac:	f7 f1                	div    %ecx
f01019ae:	89 f2                	mov    %esi,%edx
f01019b0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01019b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01019b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01019bc:	83 c4 1c             	add    $0x1c,%esp
f01019bf:	c3                   	ret    
f01019c0:	31 d2                	xor    %edx,%edx
f01019c2:	31 c0                	xor    %eax,%eax
f01019c4:	39 f7                	cmp    %esi,%edi
f01019c6:	77 e8                	ja     f01019b0 <__udivdi3+0x50>
f01019c8:	0f bd cf             	bsr    %edi,%ecx
f01019cb:	83 f1 1f             	xor    $0x1f,%ecx
f01019ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01019d2:	75 2c                	jne    f0101a00 <__udivdi3+0xa0>
f01019d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01019d8:	76 04                	jbe    f01019de <__udivdi3+0x7e>
f01019da:	39 f7                	cmp    %esi,%edi
f01019dc:	73 d2                	jae    f01019b0 <__udivdi3+0x50>
f01019de:	31 d2                	xor    %edx,%edx
f01019e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01019e5:	eb c9                	jmp    f01019b0 <__udivdi3+0x50>
f01019e7:	90                   	nop
f01019e8:	89 f2                	mov    %esi,%edx
f01019ea:	f7 f1                	div    %ecx
f01019ec:	31 d2                	xor    %edx,%edx
f01019ee:	8b 74 24 10          	mov    0x10(%esp),%esi
f01019f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01019f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01019fa:	83 c4 1c             	add    $0x1c,%esp
f01019fd:	c3                   	ret    
f01019fe:	66 90                	xchg   %ax,%ax
f0101a00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a05:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a0a:	89 ea                	mov    %ebp,%edx
f0101a0c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101a10:	d3 e7                	shl    %cl,%edi
f0101a12:	89 c1                	mov    %eax,%ecx
f0101a14:	d3 ea                	shr    %cl,%edx
f0101a16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a1b:	09 fa                	or     %edi,%edx
f0101a1d:	89 f7                	mov    %esi,%edi
f0101a1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a23:	89 f2                	mov    %esi,%edx
f0101a25:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101a29:	d3 e5                	shl    %cl,%ebp
f0101a2b:	89 c1                	mov    %eax,%ecx
f0101a2d:	d3 ef                	shr    %cl,%edi
f0101a2f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a34:	d3 e2                	shl    %cl,%edx
f0101a36:	89 c1                	mov    %eax,%ecx
f0101a38:	d3 ee                	shr    %cl,%esi
f0101a3a:	09 d6                	or     %edx,%esi
f0101a3c:	89 fa                	mov    %edi,%edx
f0101a3e:	89 f0                	mov    %esi,%eax
f0101a40:	f7 74 24 0c          	divl   0xc(%esp)
f0101a44:	89 d7                	mov    %edx,%edi
f0101a46:	89 c6                	mov    %eax,%esi
f0101a48:	f7 e5                	mul    %ebp
f0101a4a:	39 d7                	cmp    %edx,%edi
f0101a4c:	72 22                	jb     f0101a70 <__udivdi3+0x110>
f0101a4e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0101a52:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a57:	d3 e5                	shl    %cl,%ebp
f0101a59:	39 c5                	cmp    %eax,%ebp
f0101a5b:	73 04                	jae    f0101a61 <__udivdi3+0x101>
f0101a5d:	39 d7                	cmp    %edx,%edi
f0101a5f:	74 0f                	je     f0101a70 <__udivdi3+0x110>
f0101a61:	89 f0                	mov    %esi,%eax
f0101a63:	31 d2                	xor    %edx,%edx
f0101a65:	e9 46 ff ff ff       	jmp    f01019b0 <__udivdi3+0x50>
f0101a6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a70:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101a73:	31 d2                	xor    %edx,%edx
f0101a75:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101a79:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101a7d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101a81:	83 c4 1c             	add    $0x1c,%esp
f0101a84:	c3                   	ret    
	...

f0101a90 <__umoddi3>:
f0101a90:	83 ec 1c             	sub    $0x1c,%esp
f0101a93:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101a97:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0101a9b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101a9f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101aa3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101aa7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101aab:	85 ed                	test   %ebp,%ebp
f0101aad:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ab5:	89 cf                	mov    %ecx,%edi
f0101ab7:	89 04 24             	mov    %eax,(%esp)
f0101aba:	89 f2                	mov    %esi,%edx
f0101abc:	75 1a                	jne    f0101ad8 <__umoddi3+0x48>
f0101abe:	39 f1                	cmp    %esi,%ecx
f0101ac0:	76 4e                	jbe    f0101b10 <__umoddi3+0x80>
f0101ac2:	f7 f1                	div    %ecx
f0101ac4:	89 d0                	mov    %edx,%eax
f0101ac6:	31 d2                	xor    %edx,%edx
f0101ac8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101acc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101ad0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101ad4:	83 c4 1c             	add    $0x1c,%esp
f0101ad7:	c3                   	ret    
f0101ad8:	39 f5                	cmp    %esi,%ebp
f0101ada:	77 54                	ja     f0101b30 <__umoddi3+0xa0>
f0101adc:	0f bd c5             	bsr    %ebp,%eax
f0101adf:	83 f0 1f             	xor    $0x1f,%eax
f0101ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ae6:	75 60                	jne    f0101b48 <__umoddi3+0xb8>
f0101ae8:	3b 0c 24             	cmp    (%esp),%ecx
f0101aeb:	0f 87 07 01 00 00    	ja     f0101bf8 <__umoddi3+0x168>
f0101af1:	89 f2                	mov    %esi,%edx
f0101af3:	8b 34 24             	mov    (%esp),%esi
f0101af6:	29 ce                	sub    %ecx,%esi
f0101af8:	19 ea                	sbb    %ebp,%edx
f0101afa:	89 34 24             	mov    %esi,(%esp)
f0101afd:	8b 04 24             	mov    (%esp),%eax
f0101b00:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101b04:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101b08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101b0c:	83 c4 1c             	add    $0x1c,%esp
f0101b0f:	c3                   	ret    
f0101b10:	85 c9                	test   %ecx,%ecx
f0101b12:	75 0b                	jne    f0101b1f <__umoddi3+0x8f>
f0101b14:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b19:	31 d2                	xor    %edx,%edx
f0101b1b:	f7 f1                	div    %ecx
f0101b1d:	89 c1                	mov    %eax,%ecx
f0101b1f:	89 f0                	mov    %esi,%eax
f0101b21:	31 d2                	xor    %edx,%edx
f0101b23:	f7 f1                	div    %ecx
f0101b25:	8b 04 24             	mov    (%esp),%eax
f0101b28:	f7 f1                	div    %ecx
f0101b2a:	eb 98                	jmp    f0101ac4 <__umoddi3+0x34>
f0101b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b30:	89 f2                	mov    %esi,%edx
f0101b32:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101b36:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101b3a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101b3e:	83 c4 1c             	add    $0x1c,%esp
f0101b41:	c3                   	ret    
f0101b42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b48:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b4d:	89 e8                	mov    %ebp,%eax
f0101b4f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0101b54:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0101b58:	89 fa                	mov    %edi,%edx
f0101b5a:	d3 e0                	shl    %cl,%eax
f0101b5c:	89 e9                	mov    %ebp,%ecx
f0101b5e:	d3 ea                	shr    %cl,%edx
f0101b60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b65:	09 c2                	or     %eax,%edx
f0101b67:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101b6b:	89 14 24             	mov    %edx,(%esp)
f0101b6e:	89 f2                	mov    %esi,%edx
f0101b70:	d3 e7                	shl    %cl,%edi
f0101b72:	89 e9                	mov    %ebp,%ecx
f0101b74:	d3 ea                	shr    %cl,%edx
f0101b76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101b7f:	d3 e6                	shl    %cl,%esi
f0101b81:	89 e9                	mov    %ebp,%ecx
f0101b83:	d3 e8                	shr    %cl,%eax
f0101b85:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b8a:	09 f0                	or     %esi,%eax
f0101b8c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101b90:	f7 34 24             	divl   (%esp)
f0101b93:	d3 e6                	shl    %cl,%esi
f0101b95:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101b99:	89 d6                	mov    %edx,%esi
f0101b9b:	f7 e7                	mul    %edi
f0101b9d:	39 d6                	cmp    %edx,%esi
f0101b9f:	89 c1                	mov    %eax,%ecx
f0101ba1:	89 d7                	mov    %edx,%edi
f0101ba3:	72 3f                	jb     f0101be4 <__umoddi3+0x154>
f0101ba5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101ba9:	72 35                	jb     f0101be0 <__umoddi3+0x150>
f0101bab:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101baf:	29 c8                	sub    %ecx,%eax
f0101bb1:	19 fe                	sbb    %edi,%esi
f0101bb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bb8:	89 f2                	mov    %esi,%edx
f0101bba:	d3 e8                	shr    %cl,%eax
f0101bbc:	89 e9                	mov    %ebp,%ecx
f0101bbe:	d3 e2                	shl    %cl,%edx
f0101bc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bc5:	09 d0                	or     %edx,%eax
f0101bc7:	89 f2                	mov    %esi,%edx
f0101bc9:	d3 ea                	shr    %cl,%edx
f0101bcb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101bcf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101bd3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101bd7:	83 c4 1c             	add    $0x1c,%esp
f0101bda:	c3                   	ret    
f0101bdb:	90                   	nop
f0101bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101be0:	39 d6                	cmp    %edx,%esi
f0101be2:	75 c7                	jne    f0101bab <__umoddi3+0x11b>
f0101be4:	89 d7                	mov    %edx,%edi
f0101be6:	89 c1                	mov    %eax,%ecx
f0101be8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0101bec:	1b 3c 24             	sbb    (%esp),%edi
f0101bef:	eb ba                	jmp    f0101bab <__umoddi3+0x11b>
f0101bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bf8:	39 f5                	cmp    %esi,%ebp
f0101bfa:	0f 82 f1 fe ff ff    	jb     f0101af1 <__umoddi3+0x61>
f0101c00:	e9 f8 fe ff ff       	jmp    f0101afd <__umoddi3+0x6d>
