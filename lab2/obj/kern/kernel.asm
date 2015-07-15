
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f0100046:	b8 70 49 11 f0       	mov    $0xf0114970,%eax
f010004b:	2d 00 43 11 f0       	sub    $0xf0114300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 43 11 f0 	movl   $0xf0114300,(%esp)
f0100063:	e8 cb 21 00 00       	call   f0102233 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 7f 04 00 00       	call   f01004ec <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 00 27 10 f0 	movl   $0xf0102700,(%esp)
f010007c:	e8 d5 16 00 00       	call   f0101756 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 4d 0e 00 00       	call   f0100ed3 <mem_init>

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
f010009f:	83 3d 60 49 11 f0 00 	cmpl   $0x0,0xf0114960
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 49 11 f0    	mov    %esi,0xf0114960

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
f01000c1:	c7 04 24 1b 27 10 f0 	movl   $0xf010271b,(%esp)
f01000c8:	e8 89 16 00 00       	call   f0101756 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 4a 16 00 00       	call   f0101723 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 57 27 10 f0 	movl   $0xf0102757,(%esp)
f01000e0:	e8 71 16 00 00       	call   f0101756 <cprintf>
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
f010010b:	c7 04 24 33 27 10 f0 	movl   $0xf0102733,(%esp)
f0100112:	e8 3f 16 00 00       	call   f0101756 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 fd 15 00 00       	call   f0101723 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 57 27 10 f0 	movl   $0xf0102757,(%esp)
f010012d:	e8 24 16 00 00       	call   f0101756 <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    
f0100138:	66 90                	xchg   %ax,%ax
f010013a:	66 90                	xchg   %ax,%ax
f010013c:	66 90                	xchg   %ax,%ax
f010013e:	66 90                	xchg   %ax,%ax

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
f0100179:	8b 15 24 45 11 f0    	mov    0xf0114524,%edx
f010017f:	88 82 20 43 11 f0    	mov    %al,-0xfeebce0(%edx)
f0100185:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100188:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010018d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100192:	0f 44 c2             	cmove  %edx,%eax
f0100195:	a3 24 45 11 f0       	mov    %eax,0xf0114524
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
f0100252:	0f b7 05 34 45 11 f0 	movzwl 0xf0114534,%eax
f0100259:	66 85 c0             	test   %ax,%ax
f010025c:	0f 84 e4 00 00 00    	je     f0100346 <cons_putc+0x19f>
			crt_pos--;
f0100262:	83 e8 01             	sub    $0x1,%eax
f0100265:	66 a3 34 45 11 f0    	mov    %ax,0xf0114534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010026b:	0f b7 c0             	movzwl %ax,%eax
f010026e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100273:	83 cf 20             	or     $0x20,%edi
f0100276:	8b 15 30 45 11 f0    	mov    0xf0114530,%edx
f010027c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100280:	eb 77                	jmp    f01002f9 <cons_putc+0x152>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100282:	66 83 05 34 45 11 f0 	addw   $0x50,0xf0114534
f0100289:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010028a:	0f b7 05 34 45 11 f0 	movzwl 0xf0114534,%eax
f0100291:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100297:	c1 e8 16             	shr    $0x16,%eax
f010029a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010029d:	c1 e0 04             	shl    $0x4,%eax
f01002a0:	66 a3 34 45 11 f0    	mov    %ax,0xf0114534
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
f01002dc:	0f b7 05 34 45 11 f0 	movzwl 0xf0114534,%eax
f01002e3:	0f b7 c8             	movzwl %ax,%ecx
f01002e6:	8b 15 30 45 11 f0    	mov    0xf0114530,%edx
f01002ec:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01002f0:	83 c0 01             	add    $0x1,%eax
f01002f3:	66 a3 34 45 11 f0    	mov    %ax,0xf0114534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002f9:	66 81 3d 34 45 11 f0 	cmpw   $0x7cf,0xf0114534
f0100300:	cf 07 
f0100302:	76 42                	jbe    f0100346 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100304:	a1 30 45 11 f0       	mov    0xf0114530,%eax
f0100309:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100310:	00 
f0100311:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100317:	89 54 24 04          	mov    %edx,0x4(%esp)
f010031b:	89 04 24             	mov    %eax,(%esp)
f010031e:	e8 6b 1f 00 00       	call   f010228e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100323:	8b 15 30 45 11 f0    	mov    0xf0114530,%edx
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
f010033e:	66 83 2d 34 45 11 f0 	subw   $0x50,0xf0114534
f0100345:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100346:	8b 0d 2c 45 11 f0    	mov    0xf011452c,%ecx
f010034c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100351:	89 ca                	mov    %ecx,%edx
f0100353:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100354:	0f b7 35 34 45 11 f0 	movzwl 0xf0114534,%esi
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
f010039f:	83 0d 28 45 11 f0 40 	orl    $0x40,0xf0114528
		return 0;
f01003a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ab:	e9 c4 00 00 00       	jmp    f0100474 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003b0:	84 c0                	test   %al,%al
f01003b2:	79 37                	jns    f01003eb <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003b4:	8b 0d 28 45 11 f0    	mov    0xf0114528,%ecx
f01003ba:	89 cb                	mov    %ecx,%ebx
f01003bc:	83 e3 40             	and    $0x40,%ebx
f01003bf:	83 e0 7f             	and    $0x7f,%eax
f01003c2:	85 db                	test   %ebx,%ebx
f01003c4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003c7:	0f b6 d2             	movzbl %dl,%edx
f01003ca:	0f b6 82 80 27 10 f0 	movzbl -0xfefd880(%edx),%eax
f01003d1:	83 c8 40             	or     $0x40,%eax
f01003d4:	0f b6 c0             	movzbl %al,%eax
f01003d7:	f7 d0                	not    %eax
f01003d9:	21 c1                	and    %eax,%ecx
f01003db:	89 0d 28 45 11 f0    	mov    %ecx,0xf0114528
		return 0;
f01003e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e6:	e9 89 00 00 00       	jmp    f0100474 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01003eb:	8b 0d 28 45 11 f0    	mov    0xf0114528,%ecx
f01003f1:	f6 c1 40             	test   $0x40,%cl
f01003f4:	74 0e                	je     f0100404 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003f6:	89 c2                	mov    %eax,%edx
f01003f8:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003fb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003fe:	89 0d 28 45 11 f0    	mov    %ecx,0xf0114528
	}

	shift |= shiftcode[data];
f0100404:	0f b6 d2             	movzbl %dl,%edx
f0100407:	0f b6 82 80 27 10 f0 	movzbl -0xfefd880(%edx),%eax
f010040e:	0b 05 28 45 11 f0    	or     0xf0114528,%eax
	shift ^= togglecode[data];
f0100414:	0f b6 8a 80 28 10 f0 	movzbl -0xfefd780(%edx),%ecx
f010041b:	31 c8                	xor    %ecx,%eax
f010041d:	a3 28 45 11 f0       	mov    %eax,0xf0114528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100422:	89 c1                	mov    %eax,%ecx
f0100424:	83 e1 03             	and    $0x3,%ecx
f0100427:	8b 0c 8d 80 29 10 f0 	mov    -0xfefd680(,%ecx,4),%ecx
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
f010045d:	c7 04 24 4d 27 10 f0 	movl   $0xf010274d,(%esp)
f0100464:	e8 ed 12 00 00       	call   f0101756 <cprintf>
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
f0100482:	80 3d 00 43 11 f0 00 	cmpb   $0x0,0xf0114300
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
f01004b9:	8b 15 20 45 11 f0    	mov    0xf0114520,%edx
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
f01004c4:	3b 15 24 45 11 f0    	cmp    0xf0114524,%edx
f01004ca:	74 1e                	je     f01004ea <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004cc:	0f b6 82 20 43 11 f0 	movzbl -0xfeebce0(%edx),%eax
f01004d3:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004d6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004e1:	0f 44 d1             	cmove  %ecx,%edx
f01004e4:	89 15 20 45 11 f0    	mov    %edx,0xf0114520
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
f0100512:	c7 05 2c 45 11 f0 b4 	movl   $0x3b4,0xf011452c
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
f010052a:	c7 05 2c 45 11 f0 d4 	movl   $0x3d4,0xf011452c
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
f0100539:	8b 0d 2c 45 11 f0    	mov    0xf011452c,%ecx
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
f010055e:	89 35 30 45 11 f0    	mov    %esi,0xf0114530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100564:	0f b6 d8             	movzbl %al,%ebx
f0100567:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100569:	66 89 3d 34 45 11 f0 	mov    %di,0xf0114534
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
f01005bc:	a2 00 43 11 f0       	mov    %al,0xf0114300
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
f01005cd:	c7 04 24 59 27 10 f0 	movl   $0xf0102759,(%esp)
f01005d4:	e8 7d 11 00 00       	call   f0101756 <cprintf>
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
f010060c:	66 90                	xchg   %ax,%ax
f010060e:	66 90                	xchg   %ax,%ax

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
f0100616:	c7 04 24 90 29 10 f0 	movl   $0xf0102990,(%esp)
f010061d:	e8 34 11 00 00       	call   f0101756 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100622:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100629:	00 
f010062a:	c7 04 24 50 2a 10 f0 	movl   $0xf0102a50,(%esp)
f0100631:	e8 20 11 00 00       	call   f0101756 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100636:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010063d:	00 
f010063e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100645:	f0 
f0100646:	c7 04 24 78 2a 10 f0 	movl   $0xf0102a78,(%esp)
f010064d:	e8 04 11 00 00       	call   f0101756 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100652:	c7 44 24 08 e7 26 10 	movl   $0x1026e7,0x8(%esp)
f0100659:	00 
f010065a:	c7 44 24 04 e7 26 10 	movl   $0xf01026e7,0x4(%esp)
f0100661:	f0 
f0100662:	c7 04 24 9c 2a 10 f0 	movl   $0xf0102a9c,(%esp)
f0100669:	e8 e8 10 00 00       	call   f0101756 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010066e:	c7 44 24 08 00 43 11 	movl   $0x114300,0x8(%esp)
f0100675:	00 
f0100676:	c7 44 24 04 00 43 11 	movl   $0xf0114300,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 c0 2a 10 f0 	movl   $0xf0102ac0,(%esp)
f0100685:	e8 cc 10 00 00       	call   f0101756 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010068a:	c7 44 24 08 70 49 11 	movl   $0x114970,0x8(%esp)
f0100691:	00 
f0100692:	c7 44 24 04 70 49 11 	movl   $0xf0114970,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 e4 2a 10 f0 	movl   $0xf0102ae4,(%esp)
f01006a1:	e8 b0 10 00 00       	call   f0101756 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006a6:	b8 6f 4d 11 f0       	mov    $0xf0114d6f,%eax
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
f01006c7:	c7 04 24 08 2b 10 f0 	movl   $0xf0102b08,(%esp)
f01006ce:	e8 83 10 00 00       	call   f0101756 <cprintf>
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
f01006e0:	c7 44 24 08 a9 29 10 	movl   $0xf01029a9,0x8(%esp)
f01006e7:	f0 
f01006e8:	c7 44 24 04 c7 29 10 	movl   $0xf01029c7,0x4(%esp)
f01006ef:	f0 
f01006f0:	c7 04 24 cc 29 10 f0 	movl   $0xf01029cc,(%esp)
f01006f7:	e8 5a 10 00 00       	call   f0101756 <cprintf>
f01006fc:	c7 44 24 08 34 2b 10 	movl   $0xf0102b34,0x8(%esp)
f0100703:	f0 
f0100704:	c7 44 24 04 d5 29 10 	movl   $0xf01029d5,0x4(%esp)
f010070b:	f0 
f010070c:	c7 04 24 cc 29 10 f0 	movl   $0xf01029cc,(%esp)
f0100713:	e8 3e 10 00 00       	call   f0101756 <cprintf>
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
f0100753:	e8 f8 10 00 00       	call   f0101850 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100758:	8b 46 04             	mov    0x4(%esi),%eax
f010075b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010075f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100763:	c7 04 24 de 29 10 f0 	movl   $0xf01029de,(%esp)
f010076a:	e8 e7 0f 00 00       	call   f0101756 <cprintf>
			for(i=0;i<5;++i)
f010076f:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%08x  ", arg[i]);
f0100774:	8b 44 9d bc          	mov    -0x44(%ebp,%ebx,4),%eax
f0100778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010077c:	c7 04 24 f9 29 10 f0 	movl   $0xf01029f9,(%esp)
f0100783:	e8 ce 0f 00 00       	call   f0101756 <cprintf>
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
f0100790:	c7 04 24 57 27 10 f0 	movl   $0xf0102757,(%esp)
f0100797:	e8 ba 0f 00 00       	call   f0101756 <cprintf>
			
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
f01007c2:	c7 04 24 00 2a 10 f0 	movl   $0xf0102a00,(%esp)
f01007c9:	e8 88 0f 00 00       	call   f0101756 <cprintf>
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
f01007ee:	c7 04 24 5c 2b 10 f0 	movl   $0xf0102b5c,(%esp)
f01007f5:	e8 5c 0f 00 00       	call   f0101756 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007fa:	c7 04 24 80 2b 10 f0 	movl   $0xf0102b80,(%esp)
f0100801:	e8 50 0f 00 00       	call   f0101756 <cprintf>
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
f0100809:	c7 04 24 11 2a 10 f0 	movl   $0xf0102a11,(%esp)
f0100810:	e8 cb 17 00 00       	call   f0101fe0 <readline>
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
f010083d:	c7 04 24 15 2a 10 f0 	movl   $0xf0102a15,(%esp)
f0100844:	e8 ad 19 00 00       	call   f01021f6 <strchr>
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
f010085f:	c7 04 24 1a 2a 10 f0 	movl   $0xf0102a1a,(%esp)
f0100866:	e8 eb 0e 00 00       	call   f0101756 <cprintf>
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
f0100887:	c7 04 24 15 2a 10 f0 	movl   $0xf0102a15,(%esp)
f010088e:	e8 63 19 00 00       	call   f01021f6 <strchr>
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
f01008a9:	c7 44 24 04 c7 29 10 	movl   $0xf01029c7,0x4(%esp)
f01008b0:	f0 
f01008b1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008b4:	89 04 24             	mov    %eax,(%esp)
f01008b7:	e8 db 18 00 00       	call   f0102197 <strcmp>
f01008bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01008c1:	85 c0                	test   %eax,%eax
f01008c3:	74 1c                	je     f01008e1 <monitor+0xfc>
f01008c5:	c7 44 24 04 d5 29 10 	movl   $0xf01029d5,0x4(%esp)
f01008cc:	f0 
f01008cd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d0:	89 04 24             	mov    %eax,(%esp)
f01008d3:	e8 bf 18 00 00       	call   f0102197 <strcmp>
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
f01008f4:	ff 14 95 b0 2b 10 f0 	call   *-0xfefd450(,%edx,4)


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
f010090b:	c7 04 24 37 2a 10 f0 	movl   $0xf0102a37,(%esp)
f0100912:	e8 3f 0e 00 00       	call   f0101756 <cprintf>
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

f0100924 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100924:	55                   	push   %ebp
f0100925:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100927:	83 3d 38 45 11 f0 00 	cmpl   $0x0,0xf0114538
f010092e:	75 11                	jne    f0100941 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f0100930:	ba 6f 59 11 f0       	mov    $0xf011596f,%edx
f0100935:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010093b:	89 15 38 45 11 f0    	mov    %edx,0xf0114538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100941:	85 c0                	test   %eax,%eax
f0100943:	75 07                	jne    f010094c <boot_alloc+0x28>
		return nextfree;
f0100945:	a1 38 45 11 f0       	mov    0xf0114538,%eax
f010094a:	eb 19                	jmp    f0100965 <boot_alloc+0x41>
	result = nextfree;
f010094c:	8b 15 38 45 11 f0    	mov    0xf0114538,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100952:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100959:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010095e:	a3 38 45 11 f0       	mov    %eax,0xf0114538
	
	// return the head address of the alloc pages;
	return result;
f0100963:	89 d0                	mov    %edx,%eax
}
f0100965:	5d                   	pop    %ebp
f0100966:	c3                   	ret    

f0100967 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100967:	89 d1                	mov    %edx,%ecx
f0100969:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010096c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010096f:	a8 01                	test   $0x1,%al
f0100971:	74 5d                	je     f01009d0 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100973:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100978:	89 c1                	mov    %eax,%ecx
f010097a:	c1 e9 0c             	shr    $0xc,%ecx
f010097d:	3b 0d 64 49 11 f0    	cmp    0xf0114964,%ecx
f0100983:	72 26                	jb     f01009ab <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100985:	55                   	push   %ebp
f0100986:	89 e5                	mov    %esp,%ebp
f0100988:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010098b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010098f:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f0100996:	f0 
f0100997:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010099e:	00 
f010099f:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01009a6:	e8 e9 f6 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009ab:	c1 ea 0c             	shr    $0xc,%edx
f01009ae:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009b4:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009bb:	89 c2                	mov    %eax,%edx
f01009bd:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c5:	85 d2                	test   %edx,%edx
f01009c7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009cc:	0f 44 c2             	cmove  %edx,%eax
f01009cf:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009d5:	c3                   	ret    

f01009d6 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009d6:	55                   	push   %ebp
f01009d7:	89 e5                	mov    %esp,%ebp
f01009d9:	57                   	push   %edi
f01009da:	56                   	push   %esi
f01009db:	53                   	push   %ebx
f01009dc:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009df:	84 c0                	test   %al,%al
f01009e1:	0f 85 07 03 00 00    	jne    f0100cee <check_page_free_list+0x318>
f01009e7:	e9 14 03 00 00       	jmp    f0100d00 <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009ec:	c7 44 24 08 e4 2b 10 	movl   $0xf0102be4,0x8(%esp)
f01009f3:	f0 
f01009f4:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
f01009fb:	00 
f01009fc:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100a03:	e8 8c f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a08:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a0e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a14:	89 c2                	mov    %eax,%edx
f0100a16:	2b 15 6c 49 11 f0    	sub    0xf011496c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a1c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a22:	0f 95 c2             	setne  %dl
f0100a25:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a28:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a2c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a2e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a32:	8b 00                	mov    (%eax),%eax
f0100a34:	85 c0                	test   %eax,%eax
f0100a36:	75 dc                	jne    f0100a14 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a44:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a47:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a49:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a4c:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a51:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a56:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100a5c:	eb 63                	jmp    f0100ac1 <check_page_free_list+0xeb>
f0100a5e:	89 d8                	mov    %ebx,%eax
f0100a60:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100a66:	c1 f8 03             	sar    $0x3,%eax
f0100a69:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a6c:	89 c2                	mov    %eax,%edx
f0100a6e:	c1 ea 16             	shr    $0x16,%edx
f0100a71:	39 f2                	cmp    %esi,%edx
f0100a73:	73 4a                	jae    f0100abf <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a75:	89 c2                	mov    %eax,%edx
f0100a77:	c1 ea 0c             	shr    $0xc,%edx
f0100a7a:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100a80:	72 20                	jb     f0100aa2 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a82:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a86:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f0100a8d:	f0 
f0100a8e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100a95:	00 
f0100a96:	c7 04 24 c4 2d 10 f0 	movl   $0xf0102dc4,(%esp)
f0100a9d:	e8 f2 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100aa2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100aa9:	00 
f0100aaa:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ab1:	00 
	return (void *)(pa + KERNBASE);
f0100ab2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ab7:	89 04 24             	mov    %eax,(%esp)
f0100aba:	e8 74 17 00 00       	call   f0102233 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100abf:	8b 1b                	mov    (%ebx),%ebx
f0100ac1:	85 db                	test   %ebx,%ebx
f0100ac3:	75 99                	jne    f0100a5e <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ac5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aca:	e8 55 fe ff ff       	call   f0100924 <boot_alloc>
f0100acf:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad2:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad8:	8b 0d 6c 49 11 f0    	mov    0xf011496c,%ecx
		assert(pp < pages + npages);
f0100ade:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100ae3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ae6:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ae9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aec:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100aef:	bf 00 00 00 00       	mov    $0x0,%edi
f0100af4:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af7:	e9 97 01 00 00       	jmp    f0100c93 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100afc:	39 ca                	cmp    %ecx,%edx
f0100afe:	73 24                	jae    f0100b24 <check_page_free_list+0x14e>
f0100b00:	c7 44 24 0c d2 2d 10 	movl   $0xf0102dd2,0xc(%esp)
f0100b07:	f0 
f0100b08:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100b0f:	f0 
f0100b10:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
f0100b17:	00 
f0100b18:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100b1f:	e8 70 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b24:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b27:	72 24                	jb     f0100b4d <check_page_free_list+0x177>
f0100b29:	c7 44 24 0c f3 2d 10 	movl   $0xf0102df3,0xc(%esp)
f0100b30:	f0 
f0100b31:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100b38:	f0 
f0100b39:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0100b40:	00 
f0100b41:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100b48:	e8 47 f5 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b4d:	89 d0                	mov    %edx,%eax
f0100b4f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b52:	a8 07                	test   $0x7,%al
f0100b54:	74 24                	je     f0100b7a <check_page_free_list+0x1a4>
f0100b56:	c7 44 24 0c 08 2c 10 	movl   $0xf0102c08,0xc(%esp)
f0100b5d:	f0 
f0100b5e:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100b65:	f0 
f0100b66:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f0100b6d:	00 
f0100b6e:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100b75:	e8 1a f5 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7a:	c1 f8 03             	sar    $0x3,%eax
f0100b7d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b80:	85 c0                	test   %eax,%eax
f0100b82:	75 24                	jne    f0100ba8 <check_page_free_list+0x1d2>
f0100b84:	c7 44 24 0c 07 2e 10 	movl   $0xf0102e07,0xc(%esp)
f0100b8b:	f0 
f0100b8c:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100b93:	f0 
f0100b94:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
f0100b9b:	00 
f0100b9c:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100ba3:	e8 ec f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ba8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bad:	75 24                	jne    f0100bd3 <check_page_free_list+0x1fd>
f0100baf:	c7 44 24 0c 18 2e 10 	movl   $0xf0102e18,0xc(%esp)
f0100bb6:	f0 
f0100bb7:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100bbe:	f0 
f0100bbf:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
f0100bc6:	00 
f0100bc7:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100bce:	e8 c1 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bd3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bd8:	75 24                	jne    f0100bfe <check_page_free_list+0x228>
f0100bda:	c7 44 24 0c 3c 2c 10 	movl   $0xf0102c3c,0xc(%esp)
f0100be1:	f0 
f0100be2:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100be9:	f0 
f0100bea:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
f0100bf1:	00 
f0100bf2:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100bf9:	e8 96 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bfe:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c03:	75 24                	jne    f0100c29 <check_page_free_list+0x253>
f0100c05:	c7 44 24 0c 31 2e 10 	movl   $0xf0102e31,0xc(%esp)
f0100c0c:	f0 
f0100c0d:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100c14:	f0 
f0100c15:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
f0100c1c:	00 
f0100c1d:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100c24:	e8 6b f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c29:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c2e:	76 58                	jbe    f0100c88 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c30:	89 c3                	mov    %eax,%ebx
f0100c32:	c1 eb 0c             	shr    $0xc,%ebx
f0100c35:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c38:	77 20                	ja     f0100c5a <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c3e:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f0100c45:	f0 
f0100c46:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c4d:	00 
f0100c4e:	c7 04 24 c4 2d 10 f0 	movl   $0xf0102dc4,(%esp)
f0100c55:	e8 3a f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c5a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5f:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c62:	76 2a                	jbe    f0100c8e <check_page_free_list+0x2b8>
f0100c64:	c7 44 24 0c 60 2c 10 	movl   $0xf0102c60,0xc(%esp)
f0100c6b:	f0 
f0100c6c:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100c73:	f0 
f0100c74:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
f0100c7b:	00 
f0100c7c:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100c83:	e8 0c f4 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c88:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100c8c:	eb 03                	jmp    f0100c91 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100c8e:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c91:	8b 12                	mov    (%edx),%edx
f0100c93:	85 d2                	test   %edx,%edx
f0100c95:	0f 85 61 fe ff ff    	jne    f0100afc <check_page_free_list+0x126>
f0100c9b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c9e:	85 db                	test   %ebx,%ebx
f0100ca0:	7f 24                	jg     f0100cc6 <check_page_free_list+0x2f0>
f0100ca2:	c7 44 24 0c 4b 2e 10 	movl   $0xf0102e4b,0xc(%esp)
f0100ca9:	f0 
f0100caa:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100cb1:	f0 
f0100cb2:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100cb9:	00 
f0100cba:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100cc1:	e8 ce f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100cc6:	85 ff                	test   %edi,%edi
f0100cc8:	7f 4d                	jg     f0100d17 <check_page_free_list+0x341>
f0100cca:	c7 44 24 0c 5d 2e 10 	movl   $0xf0102e5d,0xc(%esp)
f0100cd1:	f0 
f0100cd2:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0100cd9:	f0 
f0100cda:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0100ce1:	00 
f0100ce2:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100ce9:	e8 a6 f3 ff ff       	call   f0100094 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cee:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0100cf3:	85 c0                	test   %eax,%eax
f0100cf5:	0f 85 0d fd ff ff    	jne    f0100a08 <check_page_free_list+0x32>
f0100cfb:	e9 ec fc ff ff       	jmp    f01009ec <check_page_free_list+0x16>
f0100d00:	83 3d 3c 45 11 f0 00 	cmpl   $0x0,0xf011453c
f0100d07:	0f 84 df fc ff ff    	je     f01009ec <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d0d:	be 00 04 00 00       	mov    $0x400,%esi
f0100d12:	e9 3f fd ff ff       	jmp    f0100a56 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d17:	83 c4 4c             	add    $0x4c,%esp
f0100d1a:	5b                   	pop    %ebx
f0100d1b:	5e                   	pop    %esi
f0100d1c:	5f                   	pop    %edi
f0100d1d:	5d                   	pop    %ebp
f0100d1e:	c3                   	ret    

f0100d1f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d1f:	55                   	push   %ebp
f0100d20:	89 e5                	mov    %esp,%ebp
f0100d22:	56                   	push   %esi
f0100d23:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d24:	be 00 00 00 00       	mov    $0x0,%esi
f0100d29:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d2e:	e9 c5 00 00 00       	jmp    f0100df8 <page_init+0xd9>
		if(i == 0)
f0100d33:	85 db                	test   %ebx,%ebx
f0100d35:	75 16                	jne    f0100d4d <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100d37:	a1 6c 49 11 f0       	mov    0xf011496c,%eax
f0100d3c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d48:	e9 a5 00 00 00       	jmp    f0100df2 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d4d:	3b 1d 40 45 11 f0    	cmp    0xf0114540,%ebx
f0100d53:	73 25                	jae    f0100d7a <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d55:	89 f0                	mov    %esi,%eax
f0100d57:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d5d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d63:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100d69:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d6b:	89 f0                	mov    %esi,%eax
f0100d6d:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d73:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
f0100d78:	eb 78                	jmp    f0100df2 <page_init+0xd3>
f0100d7a:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d80:	83 f8 5f             	cmp    $0x5f,%eax
f0100d83:	77 16                	ja     f0100d9b <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100d85:	89 f0                	mov    %esi,%eax
f0100d87:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d8d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100d93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d99:	eb 57                	jmp    f0100df2 <page_init+0xd3>
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100d9b:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100da1:	76 2c                	jbe    f0100dcf <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100da3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da8:	e8 77 fb ff ff       	call   f0100924 <boot_alloc>
f0100dad:	05 00 00 00 10       	add    $0x10000000,%eax
f0100db2:	c1 e8 0c             	shr    $0xc,%eax
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100db5:	39 c3                	cmp    %eax,%ebx
f0100db7:	73 16                	jae    f0100dcf <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100db9:	89 f0                	mov    %esi,%eax
f0100dbb:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100dc1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100dc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100dcd:	eb 23                	jmp    f0100df2 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100dcf:	89 f0                	mov    %esi,%eax
f0100dd1:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100dd7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100ddd:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100de3:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100de5:	89 f0                	mov    %esi,%eax
f0100de7:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100ded:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100df2:	83 c3 01             	add    $0x1,%ebx
f0100df5:	83 c6 08             	add    $0x8,%esi
f0100df8:	3b 1d 64 49 11 f0    	cmp    0xf0114964,%ebx
f0100dfe:	0f 82 2f ff ff ff    	jb     f0100d33 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100e04:	5b                   	pop    %ebx
f0100e05:	5e                   	pop    %esi
f0100e06:	5d                   	pop    %ebp
f0100e07:	c3                   	ret    

f0100e08 <page_alloc>:

//apply a page, if alloc_flage==0, do not initialize the page;
//if alloc_flags==1, initialize the page and make the entire page '\0';
struct PageInfo *
page_alloc(int alloc_flags)
{	
f0100e08:	55                   	push   %ebp
f0100e09:	89 e5                	mov    %esp,%ebp
f0100e0b:	53                   	push   %ebx
f0100e0c:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100e0f:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100e15:	85 db                	test   %ebx,%ebx
f0100e17:	74 6f                	je     f0100e88 <page_alloc+0x80>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e19:	8b 03                	mov    (%ebx),%eax
f0100e1b:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
		page->pp_link = NULL;
f0100e20:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
f0100e26:	89 d8                	mov    %ebx,%eax
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
		page->pp_link = NULL;

		if(alloc_flags & ALLOC_ZERO)
f0100e28:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e2c:	74 5f                	je     f0100e8d <page_alloc+0x85>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e2e:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100e34:	c1 f8 03             	sar    $0x3,%eax
f0100e37:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3a:	89 c2                	mov    %eax,%edx
f0100e3c:	c1 ea 0c             	shr    $0xc,%edx
f0100e3f:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e45:	72 20                	jb     f0100e67 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e4b:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f0100e52:	f0 
f0100e53:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e5a:	00 
f0100e5b:	c7 04 24 c4 2d 10 f0 	movl   $0xf0102dc4,(%esp)
f0100e62:	e8 2d f2 ff ff       	call   f0100094 <_panic>
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
f0100e67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e6e:	00 
f0100e6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e76:	00 
	return (void *)(pa + KERNBASE);
f0100e77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e7c:	89 04 24             	mov    %eax,(%esp)
f0100e7f:	e8 af 13 00 00       	call   f0102233 <memset>
	}

	return page;
f0100e84:	89 d8                	mov    %ebx,%eax
f0100e86:	eb 05                	jmp    f0100e8d <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{	
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0100e88:	b8 00 00 00 00       	mov    $0x0,%eax
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
}
f0100e8d:	83 c4 14             	add    $0x14,%esp
f0100e90:	5b                   	pop    %ebx
f0100e91:	5d                   	pop    %ebp
f0100e92:	c3                   	ret    

f0100e93 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e93:	55                   	push   %ebp
f0100e94:	89 e5                	mov    %esp,%ebp
f0100e96:	83 ec 18             	sub    $0x18,%esp
f0100e99:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link !=NULL)
f0100e9c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ea1:	75 05                	jne    f0100ea8 <page_free+0x15>
f0100ea3:	83 38 00             	cmpl   $0x0,(%eax)
f0100ea6:	74 1c                	je     f0100ec4 <page_free+0x31>
		panic("pp_ref is not 0 or the pp_link is not NULL. The page is used\n");
f0100ea8:	c7 44 24 08 a8 2c 10 	movl   $0xf0102ca8,0x8(%esp)
f0100eaf:	f0 
f0100eb0:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100eb7:	00 
f0100eb8:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100ebf:	e8 d0 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100ec4:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100eca:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ecc:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
	return;
}
f0100ed1:	c9                   	leave  
f0100ed2:	c3                   	ret    

f0100ed3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100ed3:	55                   	push   %ebp
f0100ed4:	89 e5                	mov    %esp,%ebp
f0100ed6:	57                   	push   %edi
f0100ed7:	56                   	push   %esi
f0100ed8:	53                   	push   %ebx
f0100ed9:	83 ec 2c             	sub    $0x2c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100edc:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0100ee3:	e8 00 08 00 00       	call   f01016e8 <mc146818_read>
f0100ee8:	89 c3                	mov    %eax,%ebx
f0100eea:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100ef1:	e8 f2 07 00 00       	call   f01016e8 <mc146818_read>
f0100ef6:	c1 e0 08             	shl    $0x8,%eax
f0100ef9:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100efb:	89 d8                	mov    %ebx,%eax
f0100efd:	c1 e0 0a             	shl    $0xa,%eax
f0100f00:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f06:	85 c0                	test   %eax,%eax
f0100f08:	0f 48 c2             	cmovs  %edx,%eax
f0100f0b:	c1 f8 0c             	sar    $0xc,%eax
f0100f0e:	a3 40 45 11 f0       	mov    %eax,0xf0114540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f13:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100f1a:	e8 c9 07 00 00       	call   f01016e8 <mc146818_read>
f0100f1f:	89 c3                	mov    %eax,%ebx
f0100f21:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0100f28:	e8 bb 07 00 00       	call   f01016e8 <mc146818_read>
f0100f2d:	c1 e0 08             	shl    $0x8,%eax
f0100f30:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100f32:	89 d8                	mov    %ebx,%eax
f0100f34:	c1 e0 0a             	shl    $0xa,%eax
f0100f37:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f3d:	85 c0                	test   %eax,%eax
f0100f3f:	0f 48 c2             	cmovs  %edx,%eax
f0100f42:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100f45:	85 c0                	test   %eax,%eax
f0100f47:	74 0e                	je     f0100f57 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100f49:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100f4f:	89 15 64 49 11 f0    	mov    %edx,0xf0114964
f0100f55:	eb 0c                	jmp    f0100f63 <mem_init+0x90>
	else
		npages = npages_basemem;
f0100f57:	8b 15 40 45 11 f0    	mov    0xf0114540,%edx
f0100f5d:	89 15 64 49 11 f0    	mov    %edx,0xf0114964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100f63:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f66:	c1 e8 0a             	shr    $0xa,%eax
f0100f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100f6d:	a1 40 45 11 f0       	mov    0xf0114540,%eax
f0100f72:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f75:	c1 e8 0a             	shr    $0xa,%eax
f0100f78:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100f7c:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100f81:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f84:	c1 e8 0a             	shr    $0xa,%eax
f0100f87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f8b:	c7 04 24 e8 2c 10 f0 	movl   $0xf0102ce8,(%esp)
f0100f92:	e8 bf 07 00 00       	call   f0101756 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100f97:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100f9c:	e8 83 f9 ff ff       	call   f0100924 <boot_alloc>
f0100fa1:	a3 68 49 11 f0       	mov    %eax,0xf0114968
	memset(kern_pgdir, 0, PGSIZE);
f0100fa6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fad:	00 
f0100fae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fb5:	00 
f0100fb6:	89 04 24             	mov    %eax,(%esp)
f0100fb9:	e8 75 12 00 00       	call   f0102233 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fbe:	a1 68 49 11 f0       	mov    0xf0114968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fc8:	77 20                	ja     f0100fea <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fce:	c7 44 24 08 24 2d 10 	movl   $0xf0102d24,0x8(%esp)
f0100fd5:	f0 
f0100fd6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f0100fdd:	00 
f0100fde:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0100fe5:	e8 aa f0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100fea:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ff0:	83 ca 05             	or     $0x5,%edx
f0100ff3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0100ff9:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100ffe:	c1 e0 03             	shl    $0x3,%eax
f0101001:	e8 1e f9 ff ff       	call   f0100924 <boot_alloc>
f0101006:	a3 6c 49 11 f0       	mov    %eax,0xf011496c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f010100b:	8b 3d 64 49 11 f0    	mov    0xf0114964,%edi
f0101011:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101018:	89 54 24 08          	mov    %edx,0x8(%esp)
f010101c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101023:	00 
f0101024:	89 04 24             	mov    %eax,(%esp)
f0101027:	e8 07 12 00 00       	call   f0102233 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010102c:	e8 ee fc ff ff       	call   f0100d1f <page_init>

	check_page_free_list(1);
f0101031:	b8 01 00 00 00       	mov    $0x1,%eax
f0101036:	e8 9b f9 ff ff       	call   f01009d6 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010103b:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f0101042:	75 1c                	jne    f0101060 <mem_init+0x18d>
		panic("'pages' is a null pointer!");
f0101044:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010104b:	f0 
f010104c:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101053:	00 
f0101054:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010105b:	e8 34 f0 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101060:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101065:	bb 00 00 00 00       	mov    $0x0,%ebx
f010106a:	eb 05                	jmp    f0101071 <mem_init+0x19e>
		++nfree;
f010106c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010106f:	8b 00                	mov    (%eax),%eax
f0101071:	85 c0                	test   %eax,%eax
f0101073:	75 f7                	jne    f010106c <mem_init+0x199>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010107c:	e8 87 fd ff ff       	call   f0100e08 <page_alloc>
f0101081:	89 c7                	mov    %eax,%edi
f0101083:	85 c0                	test   %eax,%eax
f0101085:	75 24                	jne    f01010ab <mem_init+0x1d8>
f0101087:	c7 44 24 0c 89 2e 10 	movl   $0xf0102e89,0xc(%esp)
f010108e:	f0 
f010108f:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101096:	f0 
f0101097:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f010109e:	00 
f010109f:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01010a6:	e8 e9 ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01010ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010b2:	e8 51 fd ff ff       	call   f0100e08 <page_alloc>
f01010b7:	89 c6                	mov    %eax,%esi
f01010b9:	85 c0                	test   %eax,%eax
f01010bb:	75 24                	jne    f01010e1 <mem_init+0x20e>
f01010bd:	c7 44 24 0c 9f 2e 10 	movl   $0xf0102e9f,0xc(%esp)
f01010c4:	f0 
f01010c5:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01010dc:	e8 b3 ef ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01010e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010e8:	e8 1b fd ff ff       	call   f0100e08 <page_alloc>
f01010ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010f0:	85 c0                	test   %eax,%eax
f01010f2:	75 24                	jne    f0101118 <mem_init+0x245>
f01010f4:	c7 44 24 0c b5 2e 10 	movl   $0xf0102eb5,0xc(%esp)
f01010fb:	f0 
f01010fc:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101103:	f0 
f0101104:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f010110b:	00 
f010110c:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101113:	e8 7c ef ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101118:	39 f7                	cmp    %esi,%edi
f010111a:	75 24                	jne    f0101140 <mem_init+0x26d>
f010111c:	c7 44 24 0c cb 2e 10 	movl   $0xf0102ecb,0xc(%esp)
f0101123:	f0 
f0101124:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010112b:	f0 
f010112c:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0101133:	00 
f0101134:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010113b:	e8 54 ef ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101143:	39 c6                	cmp    %eax,%esi
f0101145:	74 04                	je     f010114b <mem_init+0x278>
f0101147:	39 c7                	cmp    %eax,%edi
f0101149:	75 24                	jne    f010116f <mem_init+0x29c>
f010114b:	c7 44 24 0c 48 2d 10 	movl   $0xf0102d48,0xc(%esp)
f0101152:	f0 
f0101153:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010115a:	f0 
f010115b:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0101162:	00 
f0101163:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010116a:	e8 25 ef ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010116f:	8b 15 6c 49 11 f0    	mov    0xf011496c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101175:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f010117a:	c1 e0 0c             	shl    $0xc,%eax
f010117d:	89 f9                	mov    %edi,%ecx
f010117f:	29 d1                	sub    %edx,%ecx
f0101181:	c1 f9 03             	sar    $0x3,%ecx
f0101184:	c1 e1 0c             	shl    $0xc,%ecx
f0101187:	39 c1                	cmp    %eax,%ecx
f0101189:	72 24                	jb     f01011af <mem_init+0x2dc>
f010118b:	c7 44 24 0c dd 2e 10 	movl   $0xf0102edd,0xc(%esp)
f0101192:	f0 
f0101193:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010119a:	f0 
f010119b:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f01011a2:	00 
f01011a3:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01011aa:	e8 e5 ee ff ff       	call   f0100094 <_panic>
f01011af:	89 f1                	mov    %esi,%ecx
f01011b1:	29 d1                	sub    %edx,%ecx
f01011b3:	c1 f9 03             	sar    $0x3,%ecx
f01011b6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01011b9:	39 c8                	cmp    %ecx,%eax
f01011bb:	77 24                	ja     f01011e1 <mem_init+0x30e>
f01011bd:	c7 44 24 0c fa 2e 10 	movl   $0xf0102efa,0xc(%esp)
f01011c4:	f0 
f01011c5:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01011cc:	f0 
f01011cd:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
f01011d4:	00 
f01011d5:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01011dc:	e8 b3 ee ff ff       	call   f0100094 <_panic>
f01011e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01011e4:	29 d1                	sub    %edx,%ecx
f01011e6:	89 ca                	mov    %ecx,%edx
f01011e8:	c1 fa 03             	sar    $0x3,%edx
f01011eb:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01011ee:	39 d0                	cmp    %edx,%eax
f01011f0:	77 24                	ja     f0101216 <mem_init+0x343>
f01011f2:	c7 44 24 0c 17 2f 10 	movl   $0xf0102f17,0xc(%esp)
f01011f9:	f0 
f01011fa:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101201:	f0 
f0101202:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0101209:	00 
f010120a:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101211:	e8 7e ee ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101216:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f010121b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f010121e:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f0101225:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101228:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010122f:	e8 d4 fb ff ff       	call   f0100e08 <page_alloc>
f0101234:	85 c0                	test   %eax,%eax
f0101236:	74 24                	je     f010125c <mem_init+0x389>
f0101238:	c7 44 24 0c 34 2f 10 	movl   $0xf0102f34,0xc(%esp)
f010123f:	f0 
f0101240:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101247:	f0 
f0101248:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f010124f:	00 
f0101250:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101257:	e8 38 ee ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010125c:	89 3c 24             	mov    %edi,(%esp)
f010125f:	e8 2f fc ff ff       	call   f0100e93 <page_free>
	page_free(pp1);
f0101264:	89 34 24             	mov    %esi,(%esp)
f0101267:	e8 27 fc ff ff       	call   f0100e93 <page_free>
	page_free(pp2);
f010126c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010126f:	89 04 24             	mov    %eax,(%esp)
f0101272:	e8 1c fc ff ff       	call   f0100e93 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101277:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010127e:	e8 85 fb ff ff       	call   f0100e08 <page_alloc>
f0101283:	89 c6                	mov    %eax,%esi
f0101285:	85 c0                	test   %eax,%eax
f0101287:	75 24                	jne    f01012ad <mem_init+0x3da>
f0101289:	c7 44 24 0c 89 2e 10 	movl   $0xf0102e89,0xc(%esp)
f0101290:	f0 
f0101291:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101298:	f0 
f0101299:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01012a0:	00 
f01012a1:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01012a8:	e8 e7 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012b4:	e8 4f fb ff ff       	call   f0100e08 <page_alloc>
f01012b9:	89 c7                	mov    %eax,%edi
f01012bb:	85 c0                	test   %eax,%eax
f01012bd:	75 24                	jne    f01012e3 <mem_init+0x410>
f01012bf:	c7 44 24 0c 9f 2e 10 	movl   $0xf0102e9f,0xc(%esp)
f01012c6:	f0 
f01012c7:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01012ce:	f0 
f01012cf:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f01012d6:	00 
f01012d7:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01012de:	e8 b1 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01012e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012ea:	e8 19 fb ff ff       	call   f0100e08 <page_alloc>
f01012ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012f2:	85 c0                	test   %eax,%eax
f01012f4:	75 24                	jne    f010131a <mem_init+0x447>
f01012f6:	c7 44 24 0c b5 2e 10 	movl   $0xf0102eb5,0xc(%esp)
f01012fd:	f0 
f01012fe:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101305:	f0 
f0101306:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f010130d:	00 
f010130e:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101315:	e8 7a ed ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010131a:	39 fe                	cmp    %edi,%esi
f010131c:	75 24                	jne    f0101342 <mem_init+0x46f>
f010131e:	c7 44 24 0c cb 2e 10 	movl   $0xf0102ecb,0xc(%esp)
f0101325:	f0 
f0101326:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010132d:	f0 
f010132e:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0101335:	00 
f0101336:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010133d:	e8 52 ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101345:	39 c7                	cmp    %eax,%edi
f0101347:	74 04                	je     f010134d <mem_init+0x47a>
f0101349:	39 c6                	cmp    %eax,%esi
f010134b:	75 24                	jne    f0101371 <mem_init+0x49e>
f010134d:	c7 44 24 0c 48 2d 10 	movl   $0xf0102d48,0xc(%esp)
f0101354:	f0 
f0101355:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010135c:	f0 
f010135d:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f0101364:	00 
f0101365:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010136c:	e8 23 ed ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101371:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101378:	e8 8b fa ff ff       	call   f0100e08 <page_alloc>
f010137d:	85 c0                	test   %eax,%eax
f010137f:	74 24                	je     f01013a5 <mem_init+0x4d2>
f0101381:	c7 44 24 0c 34 2f 10 	movl   $0xf0102f34,0xc(%esp)
f0101388:	f0 
f0101389:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101390:	f0 
f0101391:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0101398:	00 
f0101399:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01013a0:	e8 ef ec ff ff       	call   f0100094 <_panic>
f01013a5:	89 f0                	mov    %esi,%eax
f01013a7:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f01013ad:	c1 f8 03             	sar    $0x3,%eax
f01013b0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013b3:	89 c2                	mov    %eax,%edx
f01013b5:	c1 ea 0c             	shr    $0xc,%edx
f01013b8:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f01013be:	72 20                	jb     f01013e0 <mem_init+0x50d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013c4:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f01013cb:	f0 
f01013cc:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01013d3:	00 
f01013d4:	c7 04 24 c4 2d 10 f0 	movl   $0xf0102dc4,(%esp)
f01013db:	e8 b4 ec ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01013e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013e7:	00 
f01013e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01013ef:	00 
	return (void *)(pa + KERNBASE);
f01013f0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013f5:	89 04 24             	mov    %eax,(%esp)
f01013f8:	e8 36 0e 00 00       	call   f0102233 <memset>
	page_free(pp0);
f01013fd:	89 34 24             	mov    %esi,(%esp)
f0101400:	e8 8e fa ff ff       	call   f0100e93 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101405:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010140c:	e8 f7 f9 ff ff       	call   f0100e08 <page_alloc>
f0101411:	85 c0                	test   %eax,%eax
f0101413:	75 24                	jne    f0101439 <mem_init+0x566>
f0101415:	c7 44 24 0c 43 2f 10 	movl   $0xf0102f43,0xc(%esp)
f010141c:	f0 
f010141d:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101424:	f0 
f0101425:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
f010142c:	00 
f010142d:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101434:	e8 5b ec ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101439:	39 c6                	cmp    %eax,%esi
f010143b:	74 24                	je     f0101461 <mem_init+0x58e>
f010143d:	c7 44 24 0c 61 2f 10 	movl   $0xf0102f61,0xc(%esp)
f0101444:	f0 
f0101445:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010144c:	f0 
f010144d:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f0101454:	00 
f0101455:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010145c:	e8 33 ec ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101461:	89 f0                	mov    %esi,%eax
f0101463:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0101469:	c1 f8 03             	sar    $0x3,%eax
f010146c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010146f:	89 c2                	mov    %eax,%edx
f0101471:	c1 ea 0c             	shr    $0xc,%edx
f0101474:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f010147a:	72 20                	jb     f010149c <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101480:	c7 44 24 08 c0 2b 10 	movl   $0xf0102bc0,0x8(%esp)
f0101487:	f0 
f0101488:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010148f:	00 
f0101490:	c7 04 24 c4 2d 10 f0 	movl   $0xf0102dc4,(%esp)
f0101497:	e8 f8 eb ff ff       	call   f0100094 <_panic>
f010149c:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01014a2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014a8:	80 38 00             	cmpb   $0x0,(%eax)
f01014ab:	74 24                	je     f01014d1 <mem_init+0x5fe>
f01014ad:	c7 44 24 0c 71 2f 10 	movl   $0xf0102f71,0xc(%esp)
f01014b4:	f0 
f01014b5:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01014bc:	f0 
f01014bd:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01014c4:	00 
f01014c5:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01014cc:	e8 c3 eb ff ff       	call   f0100094 <_panic>
f01014d1:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014d4:	39 d0                	cmp    %edx,%eax
f01014d6:	75 d0                	jne    f01014a8 <mem_init+0x5d5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014db:	a3 3c 45 11 f0       	mov    %eax,0xf011453c

	// free the pages we took
	page_free(pp0);
f01014e0:	89 34 24             	mov    %esi,(%esp)
f01014e3:	e8 ab f9 ff ff       	call   f0100e93 <page_free>
	page_free(pp1);
f01014e8:	89 3c 24             	mov    %edi,(%esp)
f01014eb:	e8 a3 f9 ff ff       	call   f0100e93 <page_free>
	page_free(pp2);
f01014f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01014f3:	89 04 24             	mov    %eax,(%esp)
f01014f6:	e8 98 f9 ff ff       	call   f0100e93 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014fb:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101500:	eb 05                	jmp    f0101507 <mem_init+0x634>
		--nfree;
f0101502:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101505:	8b 00                	mov    (%eax),%eax
f0101507:	85 c0                	test   %eax,%eax
f0101509:	75 f7                	jne    f0101502 <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f010150b:	85 db                	test   %ebx,%ebx
f010150d:	74 24                	je     f0101533 <mem_init+0x660>
f010150f:	c7 44 24 0c 7b 2f 10 	movl   $0xf0102f7b,0xc(%esp)
f0101516:	f0 
f0101517:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010151e:	f0 
f010151f:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0101526:	00 
f0101527:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010152e:	e8 61 eb ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101533:	c7 04 24 68 2d 10 f0 	movl   $0xf0102d68,(%esp)
f010153a:	e8 17 02 00 00       	call   f0101756 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010153f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101546:	e8 bd f8 ff ff       	call   f0100e08 <page_alloc>
f010154b:	89 c3                	mov    %eax,%ebx
f010154d:	85 c0                	test   %eax,%eax
f010154f:	75 24                	jne    f0101575 <mem_init+0x6a2>
f0101551:	c7 44 24 0c 89 2e 10 	movl   $0xf0102e89,0xc(%esp)
f0101558:	f0 
f0101559:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101560:	f0 
f0101561:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101568:	00 
f0101569:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101570:	e8 1f eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101575:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010157c:	e8 87 f8 ff ff       	call   f0100e08 <page_alloc>
f0101581:	89 c6                	mov    %eax,%esi
f0101583:	85 c0                	test   %eax,%eax
f0101585:	75 24                	jne    f01015ab <mem_init+0x6d8>
f0101587:	c7 44 24 0c 9f 2e 10 	movl   $0xf0102e9f,0xc(%esp)
f010158e:	f0 
f010158f:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101596:	f0 
f0101597:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f010159e:	00 
f010159f:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01015a6:	e8 e9 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015b2:	e8 51 f8 ff ff       	call   f0100e08 <page_alloc>
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	75 24                	jne    f01015df <mem_init+0x70c>
f01015bb:	c7 44 24 0c b5 2e 10 	movl   $0xf0102eb5,0xc(%esp)
f01015c2:	f0 
f01015c3:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01015ca:	f0 
f01015cb:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01015d2:	00 
f01015d3:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f01015da:	e8 b5 ea ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015df:	39 f3                	cmp    %esi,%ebx
f01015e1:	75 24                	jne    f0101607 <mem_init+0x734>
f01015e3:	c7 44 24 0c cb 2e 10 	movl   $0xf0102ecb,0xc(%esp)
f01015ea:	f0 
f01015eb:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01015fa:	00 
f01015fb:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101602:	e8 8d ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101607:	39 c6                	cmp    %eax,%esi
f0101609:	74 04                	je     f010160f <mem_init+0x73c>
f010160b:	39 c3                	cmp    %eax,%ebx
f010160d:	75 24                	jne    f0101633 <mem_init+0x760>
f010160f:	c7 44 24 0c 48 2d 10 	movl   $0xf0102d48,0xc(%esp)
f0101616:	f0 
f0101617:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010161e:	f0 
f010161f:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101626:	00 
f0101627:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010162e:	e8 61 ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101633:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f010163a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101644:	e8 bf f7 ff ff       	call   f0100e08 <page_alloc>
f0101649:	85 c0                	test   %eax,%eax
f010164b:	74 24                	je     f0101671 <mem_init+0x79e>
f010164d:	c7 44 24 0c 34 2f 10 	movl   $0xf0102f34,0xc(%esp)
f0101654:	f0 
f0101655:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f010165c:	f0 
f010165d:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101664:	00 
f0101665:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f010166c:	e8 23 ea ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101671:	c7 44 24 0c 88 2d 10 	movl   $0xf0102d88,0xc(%esp)
f0101678:	f0 
f0101679:	c7 44 24 08 de 2d 10 	movl   $0xf0102dde,0x8(%esp)
f0101680:	f0 
f0101681:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101688:	00 
f0101689:	c7 04 24 b8 2d 10 f0 	movl   $0xf0102db8,(%esp)
f0101690:	e8 ff e9 ff ff       	call   f0100094 <_panic>

f0101695 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101695:	55                   	push   %ebp
f0101696:	89 e5                	mov    %esp,%ebp
f0101698:	83 ec 18             	sub    $0x18,%esp
f010169b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010169e:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01016a2:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01016a5:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016a9:	66 85 d2             	test   %dx,%dx
f01016ac:	75 08                	jne    f01016b6 <page_decref+0x21>
		page_free(pp);
f01016ae:	89 04 24             	mov    %eax,(%esp)
f01016b1:	e8 dd f7 ff ff       	call   f0100e93 <page_free>
}
f01016b6:	c9                   	leave  
f01016b7:	c3                   	ret    

f01016b8 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	
f01016b8:	55                   	push   %ebp
f01016b9:	89 e5                	mov    %esp,%ebp
		return NULL;

	//页面申请成功    page != NULL
	********************************************************/
	return NULL;
}
f01016bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c0:	5d                   	pop    %ebp
f01016c1:	c3                   	ret    

f01016c2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016c2:	55                   	push   %ebp
f01016c3:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01016c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ca:	5d                   	pop    %ebp
f01016cb:	c3                   	ret    

f01016cc <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01016cc:	55                   	push   %ebp
f01016cd:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01016cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d4:	5d                   	pop    %ebp
f01016d5:	c3                   	ret    

f01016d6 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01016d6:	55                   	push   %ebp
f01016d7:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f01016d9:	5d                   	pop    %ebp
f01016da:	c3                   	ret    

f01016db <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01016db:	55                   	push   %ebp
f01016dc:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016e1:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01016e4:	5d                   	pop    %ebp
f01016e5:	c3                   	ret    
f01016e6:	66 90                	xchg   %ax,%ax

f01016e8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01016e8:	55                   	push   %ebp
f01016e9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01016eb:	ba 70 00 00 00       	mov    $0x70,%edx
f01016f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01016f4:	b2 71                	mov    $0x71,%dl
f01016f6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01016f7:	0f b6 c0             	movzbl %al,%eax
}
f01016fa:	5d                   	pop    %ebp
f01016fb:	c3                   	ret    

f01016fc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01016fc:	55                   	push   %ebp
f01016fd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01016ff:	ba 70 00 00 00       	mov    $0x70,%edx
f0101704:	8b 45 08             	mov    0x8(%ebp),%eax
f0101707:	ee                   	out    %al,(%dx)
f0101708:	b2 71                	mov    $0x71,%dl
f010170a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010170d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010170e:	5d                   	pop    %ebp
f010170f:	c3                   	ret    

f0101710 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101710:	55                   	push   %ebp
f0101711:	89 e5                	mov    %esp,%ebp
f0101713:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101716:	8b 45 08             	mov    0x8(%ebp),%eax
f0101719:	89 04 24             	mov    %eax,(%esp)
f010171c:	e8 c0 ee ff ff       	call   f01005e1 <cputchar>
	*cnt++;
}
f0101721:	c9                   	leave  
f0101722:	c3                   	ret    

f0101723 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101723:	55                   	push   %ebp
f0101724:	89 e5                	mov    %esp,%ebp
f0101726:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0101729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101730:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101733:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101737:	8b 45 08             	mov    0x8(%ebp),%eax
f010173a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010173e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101741:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101745:	c7 04 24 10 17 10 f0 	movl   $0xf0101710,(%esp)
f010174c:	e8 2c 04 00 00       	call   f0101b7d <vprintfmt>
	return cnt;
}
f0101751:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101754:	c9                   	leave  
f0101755:	c3                   	ret    

f0101756 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101756:	55                   	push   %ebp
f0101757:	89 e5                	mov    %esp,%ebp
f0101759:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010175c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010175f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101763:	8b 45 08             	mov    0x8(%ebp),%eax
f0101766:	89 04 24             	mov    %eax,(%esp)
f0101769:	e8 b5 ff ff ff       	call   f0101723 <vcprintf>
	va_end(ap);

	return cnt;
}
f010176e:	c9                   	leave  
f010176f:	c3                   	ret    

f0101770 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101770:	55                   	push   %ebp
f0101771:	89 e5                	mov    %esp,%ebp
f0101773:	57                   	push   %edi
f0101774:	56                   	push   %esi
f0101775:	53                   	push   %ebx
f0101776:	83 ec 10             	sub    $0x10,%esp
f0101779:	89 c3                	mov    %eax,%ebx
f010177b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010177e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101781:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101784:	8b 0a                	mov    (%edx),%ecx
f0101786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101789:	8b 00                	mov    (%eax),%eax
f010178b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010178e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0101795:	eb 77                	jmp    f010180e <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0101797:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010179a:	01 c8                	add    %ecx,%eax
f010179c:	bf 02 00 00 00       	mov    $0x2,%edi
f01017a1:	99                   	cltd   
f01017a2:	f7 ff                	idiv   %edi
f01017a4:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017a6:	eb 01                	jmp    f01017a9 <stab_binsearch+0x39>
			m--;
f01017a8:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017a9:	39 ca                	cmp    %ecx,%edx
f01017ab:	7c 1d                	jl     f01017ca <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01017ad:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017b0:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f01017b5:	39 f7                	cmp    %esi,%edi
f01017b7:	75 ef                	jne    f01017a8 <stab_binsearch+0x38>
f01017b9:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01017bc:	6b fa 0c             	imul   $0xc,%edx,%edi
f01017bf:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f01017c3:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f01017c6:	73 18                	jae    f01017e0 <stab_binsearch+0x70>
f01017c8:	eb 05                	jmp    f01017cf <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01017ca:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f01017cd:	eb 3f                	jmp    f010180e <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01017cf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01017d2:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f01017d4:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01017d7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01017de:	eb 2e                	jmp    f010180e <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01017e0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f01017e3:	76 15                	jbe    f01017fa <stab_binsearch+0x8a>
			*region_right = m - 1;
f01017e5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01017e8:	4f                   	dec    %edi
f01017e9:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01017ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017ef:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01017f1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01017f8:	eb 14                	jmp    f010180e <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01017fa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01017fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101800:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0101802:	ff 45 0c             	incl   0xc(%ebp)
f0101805:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101807:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010180e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101811:	7e 84                	jle    f0101797 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101813:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101817:	75 0d                	jne    f0101826 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0101819:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010181c:	8b 02                	mov    (%edx),%eax
f010181e:	48                   	dec    %eax
f010181f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101822:	89 01                	mov    %eax,(%ecx)
f0101824:	eb 22                	jmp    f0101848 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101826:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101829:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010182b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010182e:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101830:	eb 01                	jmp    f0101833 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101832:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101833:	39 c1                	cmp    %eax,%ecx
f0101835:	7d 0c                	jge    f0101843 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101837:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f010183a:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f010183f:	39 f2                	cmp    %esi,%edx
f0101841:	75 ef                	jne    f0101832 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101843:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101846:	89 02                	mov    %eax,(%edx)
	}
}
f0101848:	83 c4 10             	add    $0x10,%esp
f010184b:	5b                   	pop    %ebx
f010184c:	5e                   	pop    %esi
f010184d:	5f                   	pop    %edi
f010184e:	5d                   	pop    %ebp
f010184f:	c3                   	ret    

f0101850 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101850:	55                   	push   %ebp
f0101851:	89 e5                	mov    %esp,%ebp
f0101853:	83 ec 38             	sub    $0x38,%esp
f0101856:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101859:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010185c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010185f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101865:	c7 03 86 2f 10 f0    	movl   $0xf0102f86,(%ebx)
	info->eip_line = 0;
f010186b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101872:	c7 43 08 86 2f 10 f0 	movl   $0xf0102f86,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101879:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101880:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101883:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010188a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101890:	76 12                	jbe    f01018a4 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101892:	b8 c3 9d 10 f0       	mov    $0xf0109dc3,%eax
f0101897:	3d 91 80 10 f0       	cmp    $0xf0108091,%eax
f010189c:	0f 86 5a 01 00 00    	jbe    f01019fc <debuginfo_eip+0x1ac>
f01018a2:	eb 1c                	jmp    f01018c0 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01018a4:	c7 44 24 08 90 2f 10 	movl   $0xf0102f90,0x8(%esp)
f01018ab:	f0 
f01018ac:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f01018b3:	00 
f01018b4:	c7 04 24 9d 2f 10 f0 	movl   $0xf0102f9d,(%esp)
f01018bb:	e8 d4 e7 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01018c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018c5:	80 3d c2 9d 10 f0 00 	cmpb   $0x0,0xf0109dc2
f01018cc:	0f 85 36 01 00 00    	jne    f0101a08 <debuginfo_eip+0x1b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01018d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01018d9:	b8 90 80 10 f0       	mov    $0xf0108090,%eax
f01018de:	2d d0 31 10 f0       	sub    $0xf01031d0,%eax
f01018e3:	c1 f8 02             	sar    $0x2,%eax
f01018e6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01018ec:	83 e8 01             	sub    $0x1,%eax
f01018ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01018f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018f6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01018fd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101900:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101903:	b8 d0 31 10 f0       	mov    $0xf01031d0,%eax
f0101908:	e8 63 fe ff ff       	call   f0101770 <stab_binsearch>
	if (lfile == 0)
f010190d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0101910:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0101915:	85 d2                	test   %edx,%edx
f0101917:	0f 84 eb 00 00 00    	je     f0101a08 <debuginfo_eip+0x1b8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010191d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0101920:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101923:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101926:	89 74 24 04          	mov    %esi,0x4(%esp)
f010192a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101931:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101934:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101937:	b8 d0 31 10 f0       	mov    $0xf01031d0,%eax
f010193c:	e8 2f fe ff ff       	call   f0101770 <stab_binsearch>

	if (lfun <= rfun) {
f0101941:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101944:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0101947:	7f 2e                	jg     f0101977 <debuginfo_eip+0x127>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101949:	6b c7 0c             	imul   $0xc,%edi,%eax
f010194c:	8d 90 d0 31 10 f0    	lea    -0xfefce30(%eax),%edx
f0101952:	8b 80 d0 31 10 f0    	mov    -0xfefce30(%eax),%eax
f0101958:	b9 c3 9d 10 f0       	mov    $0xf0109dc3,%ecx
f010195d:	81 e9 91 80 10 f0    	sub    $0xf0108091,%ecx
f0101963:	39 c8                	cmp    %ecx,%eax
f0101965:	73 08                	jae    f010196f <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101967:	05 91 80 10 f0       	add    $0xf0108091,%eax
f010196c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010196f:	8b 42 08             	mov    0x8(%edx),%eax
f0101972:	89 43 10             	mov    %eax,0x10(%ebx)
f0101975:	eb 06                	jmp    f010197d <debuginfo_eip+0x12d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101977:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010197a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010197d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101984:	00 
f0101985:	8b 43 08             	mov    0x8(%ebx),%eax
f0101988:	89 04 24             	mov    %eax,(%esp)
f010198b:	e8 87 08 00 00       	call   f0102217 <strfind>
f0101990:	2b 43 08             	sub    0x8(%ebx),%eax
f0101993:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101996:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101999:	eb 03                	jmp    f010199e <debuginfo_eip+0x14e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010199b:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010199e:	39 cf                	cmp    %ecx,%edi
f01019a0:	7c 27                	jl     f01019c9 <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f01019a2:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01019a5:	8d 14 85 d0 31 10 f0 	lea    -0xfefce30(,%eax,4),%edx
f01019ac:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01019b0:	3c 84                	cmp    $0x84,%al
f01019b2:	74 61                	je     f0101a15 <debuginfo_eip+0x1c5>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01019b4:	3c 64                	cmp    $0x64,%al
f01019b6:	75 e3                	jne    f010199b <debuginfo_eip+0x14b>
f01019b8:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01019bc:	74 dd                	je     f010199b <debuginfo_eip+0x14b>
f01019be:	66 90                	xchg   %ax,%ax
f01019c0:	eb 53                	jmp    f0101a15 <debuginfo_eip+0x1c5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01019c2:	05 91 80 10 f0       	add    $0xf0108091,%eax
f01019c7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01019c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01019cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01019cf:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01019d4:	39 d1                	cmp    %edx,%ecx
f01019d6:	7d 30                	jge    f0101a08 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
f01019d8:	8d 41 01             	lea    0x1(%ecx),%eax
f01019db:	eb 07                	jmp    f01019e4 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01019dd:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01019e1:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01019e4:	39 d0                	cmp    %edx,%eax
f01019e6:	74 1b                	je     f0101a03 <debuginfo_eip+0x1b3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01019e8:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01019eb:	80 3c 8d d4 31 10 f0 	cmpb   $0xa0,-0xfefce2c(,%ecx,4)
f01019f2:	a0 
f01019f3:	74 e8                	je     f01019dd <debuginfo_eip+0x18d>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01019f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01019fa:	eb 0c                	jmp    f0101a08 <debuginfo_eip+0x1b8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01019fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a01:	eb 05                	jmp    f0101a08 <debuginfo_eip+0x1b8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a08:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101a0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101a0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101a11:	89 ec                	mov    %ebp,%esp
f0101a13:	5d                   	pop    %ebp
f0101a14:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101a15:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101a18:	8b 87 d0 31 10 f0    	mov    -0xfefce30(%edi),%eax
f0101a1e:	ba c3 9d 10 f0       	mov    $0xf0109dc3,%edx
f0101a23:	81 ea 91 80 10 f0    	sub    $0xf0108091,%edx
f0101a29:	39 d0                	cmp    %edx,%eax
f0101a2b:	72 95                	jb     f01019c2 <debuginfo_eip+0x172>
f0101a2d:	eb 9a                	jmp    f01019c9 <debuginfo_eip+0x179>
f0101a2f:	90                   	nop

f0101a30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101a30:	55                   	push   %ebp
f0101a31:	89 e5                	mov    %esp,%ebp
f0101a33:	57                   	push   %edi
f0101a34:	56                   	push   %esi
f0101a35:	53                   	push   %ebx
f0101a36:	83 ec 3c             	sub    $0x3c,%esp
f0101a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a3c:	89 d7                	mov    %edx,%edi
f0101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a41:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101a44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a47:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101a4a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101a4d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101a50:	85 c0                	test   %eax,%eax
f0101a52:	75 08                	jne    f0101a5c <printnum+0x2c>
f0101a54:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101a57:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101a5a:	77 59                	ja     f0101ab5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101a5c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101a60:	83 eb 01             	sub    $0x1,%ebx
f0101a63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a67:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a6e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0101a72:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0101a76:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a7d:	00 
f0101a7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101a81:	89 04 24             	mov    %eax,(%esp)
f0101a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101a87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a8b:	e8 d0 09 00 00       	call   f0102460 <__udivdi3>
f0101a90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101a94:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101a98:	89 04 24             	mov    %eax,(%esp)
f0101a9b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101a9f:	89 fa                	mov    %edi,%edx
f0101aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101aa4:	e8 87 ff ff ff       	call   f0101a30 <printnum>
f0101aa9:	eb 11                	jmp    f0101abc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101aab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101aaf:	89 34 24             	mov    %esi,(%esp)
f0101ab2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101ab5:	83 eb 01             	sub    $0x1,%ebx
f0101ab8:	85 db                	test   %ebx,%ebx
f0101aba:	7f ef                	jg     f0101aab <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101abc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ac0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101ac4:	8b 45 10             	mov    0x10(%ebp),%eax
f0101ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101acb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101ad2:	00 
f0101ad3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101ad6:	89 04 24             	mov    %eax,(%esp)
f0101ad9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101adc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ae0:	e8 ab 0a 00 00       	call   f0102590 <__umoddi3>
f0101ae5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ae9:	0f be 80 ab 2f 10 f0 	movsbl -0xfefd055(%eax),%eax
f0101af0:	89 04 24             	mov    %eax,(%esp)
f0101af3:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0101af6:	83 c4 3c             	add    $0x3c,%esp
f0101af9:	5b                   	pop    %ebx
f0101afa:	5e                   	pop    %esi
f0101afb:	5f                   	pop    %edi
f0101afc:	5d                   	pop    %ebp
f0101afd:	c3                   	ret    

f0101afe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101afe:	55                   	push   %ebp
f0101aff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101b01:	83 fa 01             	cmp    $0x1,%edx
f0101b04:	7e 0e                	jle    f0101b14 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101b06:	8b 10                	mov    (%eax),%edx
f0101b08:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101b0b:	89 08                	mov    %ecx,(%eax)
f0101b0d:	8b 02                	mov    (%edx),%eax
f0101b0f:	8b 52 04             	mov    0x4(%edx),%edx
f0101b12:	eb 22                	jmp    f0101b36 <getuint+0x38>
	else if (lflag)
f0101b14:	85 d2                	test   %edx,%edx
f0101b16:	74 10                	je     f0101b28 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101b18:	8b 10                	mov    (%eax),%edx
f0101b1a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101b1d:	89 08                	mov    %ecx,(%eax)
f0101b1f:	8b 02                	mov    (%edx),%eax
f0101b21:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b26:	eb 0e                	jmp    f0101b36 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101b28:	8b 10                	mov    (%eax),%edx
f0101b2a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101b2d:	89 08                	mov    %ecx,(%eax)
f0101b2f:	8b 02                	mov    (%edx),%eax
f0101b31:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101b36:	5d                   	pop    %ebp
f0101b37:	c3                   	ret    

f0101b38 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101b38:	55                   	push   %ebp
f0101b39:	89 e5                	mov    %esp,%ebp
f0101b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101b3e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101b42:	8b 10                	mov    (%eax),%edx
f0101b44:	3b 50 04             	cmp    0x4(%eax),%edx
f0101b47:	73 0a                	jae    f0101b53 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101b4c:	88 0a                	mov    %cl,(%edx)
f0101b4e:	83 c2 01             	add    $0x1,%edx
f0101b51:	89 10                	mov    %edx,(%eax)
}
f0101b53:	5d                   	pop    %ebp
f0101b54:	c3                   	ret    

f0101b55 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101b55:	55                   	push   %ebp
f0101b56:	89 e5                	mov    %esp,%ebp
f0101b58:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101b5b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b62:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b65:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b69:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b70:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b73:	89 04 24             	mov    %eax,(%esp)
f0101b76:	e8 02 00 00 00       	call   f0101b7d <vprintfmt>
	va_end(ap);
}
f0101b7b:	c9                   	leave  
f0101b7c:	c3                   	ret    

f0101b7d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101b7d:	55                   	push   %ebp
f0101b7e:	89 e5                	mov    %esp,%ebp
f0101b80:	57                   	push   %edi
f0101b81:	56                   	push   %esi
f0101b82:	53                   	push   %ebx
f0101b83:	83 ec 4c             	sub    $0x4c,%esp
f0101b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101b89:	8b 75 10             	mov    0x10(%ebp),%esi
f0101b8c:	eb 12                	jmp    f0101ba0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101b8e:	85 c0                	test   %eax,%eax
f0101b90:	0f 84 bf 03 00 00    	je     f0101f55 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
f0101b96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b9a:	89 04 24             	mov    %eax,(%esp)
f0101b9d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101ba0:	0f b6 06             	movzbl (%esi),%eax
f0101ba3:	83 c6 01             	add    $0x1,%esi
f0101ba6:	83 f8 25             	cmp    $0x25,%eax
f0101ba9:	75 e3                	jne    f0101b8e <vprintfmt+0x11>
f0101bab:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0101baf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0101bb6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0101bbb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101bc2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101bc7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101bca:	eb 2b                	jmp    f0101bf7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bcc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101bcf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0101bd3:	eb 22                	jmp    f0101bf7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bd5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101bd8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0101bdc:	eb 19                	jmp    f0101bf7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bde:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0101be1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101be8:	eb 0d                	jmp    f0101bf7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101bea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101bf0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bf7:	0f b6 16             	movzbl (%esi),%edx
f0101bfa:	0f b6 c2             	movzbl %dl,%eax
f0101bfd:	8d 7e 01             	lea    0x1(%esi),%edi
f0101c00:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0101c03:	83 ea 23             	sub    $0x23,%edx
f0101c06:	80 fa 55             	cmp    $0x55,%dl
f0101c09:	0f 87 28 03 00 00    	ja     f0101f37 <vprintfmt+0x3ba>
f0101c0f:	0f b6 d2             	movzbl %dl,%edx
f0101c12:	ff 24 95 40 30 10 f0 	jmp    *-0xfefcfc0(,%edx,4)
f0101c19:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101c23:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101c28:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0101c2b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0101c2f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101c32:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101c35:	83 fa 09             	cmp    $0x9,%edx
f0101c38:	77 2f                	ja     f0101c69 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101c3a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101c3d:	eb e9                	jmp    f0101c28 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101c3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c42:	8d 50 04             	lea    0x4(%eax),%edx
f0101c45:	89 55 14             	mov    %edx,0x14(%ebp)
f0101c48:	8b 00                	mov    (%eax),%eax
f0101c4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101c50:	eb 1a                	jmp    f0101c6c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c52:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0101c55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101c59:	79 9c                	jns    f0101bf7 <vprintfmt+0x7a>
f0101c5b:	eb 81                	jmp    f0101bde <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101c60:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0101c67:	eb 8e                	jmp    f0101bf7 <vprintfmt+0x7a>
f0101c69:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0101c6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101c70:	79 85                	jns    f0101bf7 <vprintfmt+0x7a>
f0101c72:	e9 73 ff ff ff       	jmp    f0101bea <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101c77:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c7a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101c7d:	e9 75 ff ff ff       	jmp    f0101bf7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101c82:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c85:	8d 50 04             	lea    0x4(%eax),%edx
f0101c88:	89 55 14             	mov    %edx,0x14(%ebp)
f0101c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c8f:	8b 00                	mov    (%eax),%eax
f0101c91:	89 04 24             	mov    %eax,(%esp)
f0101c94:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c97:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101c9a:	e9 01 ff ff ff       	jmp    f0101ba0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101c9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ca2:	8d 50 04             	lea    0x4(%eax),%edx
f0101ca5:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ca8:	8b 00                	mov    (%eax),%eax
f0101caa:	89 c2                	mov    %eax,%edx
f0101cac:	c1 fa 1f             	sar    $0x1f,%edx
f0101caf:	31 d0                	xor    %edx,%eax
f0101cb1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101cb3:	83 f8 07             	cmp    $0x7,%eax
f0101cb6:	7f 0b                	jg     f0101cc3 <vprintfmt+0x146>
f0101cb8:	8b 14 85 a0 31 10 f0 	mov    -0xfefce60(,%eax,4),%edx
f0101cbf:	85 d2                	test   %edx,%edx
f0101cc1:	75 23                	jne    f0101ce6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
f0101cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cc7:	c7 44 24 08 c3 2f 10 	movl   $0xf0102fc3,0x8(%esp)
f0101cce:	f0 
f0101ccf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101cd6:	89 3c 24             	mov    %edi,(%esp)
f0101cd9:	e8 77 fe ff ff       	call   f0101b55 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cde:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101ce1:	e9 ba fe ff ff       	jmp    f0101ba0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0101ce6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cea:	c7 44 24 08 f0 2d 10 	movl   $0xf0102df0,0x8(%esp)
f0101cf1:	f0 
f0101cf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cf6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101cf9:	89 3c 24             	mov    %edi,(%esp)
f0101cfc:	e8 54 fe ff ff       	call   f0101b55 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d01:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101d04:	e9 97 fe ff ff       	jmp    f0101ba0 <vprintfmt+0x23>
f0101d09:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101d12:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d15:	8d 50 04             	lea    0x4(%eax),%edx
f0101d18:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d1b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0101d1d:	85 f6                	test   %esi,%esi
f0101d1f:	ba bc 2f 10 f0       	mov    $0xf0102fbc,%edx
f0101d24:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0101d27:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101d2b:	0f 8e 8c 00 00 00    	jle    f0101dbd <vprintfmt+0x240>
f0101d31:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0101d35:	0f 84 82 00 00 00    	je     f0101dbd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d3f:	89 34 24             	mov    %esi,(%esp)
f0101d42:	e8 81 03 00 00       	call   f01020c8 <strnlen>
f0101d47:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d4a:	29 c2                	sub    %eax,%edx
f0101d4c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0101d4f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0101d53:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101d56:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0101d59:	89 de                	mov    %ebx,%esi
f0101d5b:	89 d3                	mov    %edx,%ebx
f0101d5d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d5f:	eb 0d                	jmp    f0101d6e <vprintfmt+0x1f1>
					putch(padc, putdat);
f0101d61:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d65:	89 3c 24             	mov    %edi,(%esp)
f0101d68:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d6b:	83 eb 01             	sub    $0x1,%ebx
f0101d6e:	85 db                	test   %ebx,%ebx
f0101d70:	7f ef                	jg     f0101d61 <vprintfmt+0x1e4>
f0101d72:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101d75:	89 f3                	mov    %esi,%ebx
f0101d77:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0101d7a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101d7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d83:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0101d87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101d8a:	29 c2                	sub    %eax,%edx
f0101d8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101d8f:	eb 2c                	jmp    f0101dbd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101d91:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101d95:	74 18                	je     f0101daf <vprintfmt+0x232>
f0101d97:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101d9a:	83 fa 5e             	cmp    $0x5e,%edx
f0101d9d:	76 10                	jbe    f0101daf <vprintfmt+0x232>
					putch('?', putdat);
f0101d9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101da3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101daa:	ff 55 08             	call   *0x8(%ebp)
f0101dad:	eb 0a                	jmp    f0101db9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
f0101daf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101db3:	89 04 24             	mov    %eax,(%esp)
f0101db6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101db9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0101dbd:	0f be 06             	movsbl (%esi),%eax
f0101dc0:	83 c6 01             	add    $0x1,%esi
f0101dc3:	85 c0                	test   %eax,%eax
f0101dc5:	74 25                	je     f0101dec <vprintfmt+0x26f>
f0101dc7:	85 ff                	test   %edi,%edi
f0101dc9:	78 c6                	js     f0101d91 <vprintfmt+0x214>
f0101dcb:	83 ef 01             	sub    $0x1,%edi
f0101dce:	79 c1                	jns    f0101d91 <vprintfmt+0x214>
f0101dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101dd3:	89 de                	mov    %ebx,%esi
f0101dd5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101dd8:	eb 1a                	jmp    f0101df4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101dda:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101dde:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101de5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101de7:	83 eb 01             	sub    $0x1,%ebx
f0101dea:	eb 08                	jmp    f0101df4 <vprintfmt+0x277>
f0101dec:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101def:	89 de                	mov    %ebx,%esi
f0101df1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101df4:	85 db                	test   %ebx,%ebx
f0101df6:	7f e2                	jg     f0101dda <vprintfmt+0x25d>
f0101df8:	89 7d 08             	mov    %edi,0x8(%ebp)
f0101dfb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101dfd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101e00:	e9 9b fd ff ff       	jmp    f0101ba0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101e05:	83 f9 01             	cmp    $0x1,%ecx
f0101e08:	7e 10                	jle    f0101e1a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
f0101e0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e0d:	8d 50 08             	lea    0x8(%eax),%edx
f0101e10:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e13:	8b 30                	mov    (%eax),%esi
f0101e15:	8b 78 04             	mov    0x4(%eax),%edi
f0101e18:	eb 26                	jmp    f0101e40 <vprintfmt+0x2c3>
	else if (lflag)
f0101e1a:	85 c9                	test   %ecx,%ecx
f0101e1c:	74 12                	je     f0101e30 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f0101e1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e21:	8d 50 04             	lea    0x4(%eax),%edx
f0101e24:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e27:	8b 30                	mov    (%eax),%esi
f0101e29:	89 f7                	mov    %esi,%edi
f0101e2b:	c1 ff 1f             	sar    $0x1f,%edi
f0101e2e:	eb 10                	jmp    f0101e40 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
f0101e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e33:	8d 50 04             	lea    0x4(%eax),%edx
f0101e36:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e39:	8b 30                	mov    (%eax),%esi
f0101e3b:	89 f7                	mov    %esi,%edi
f0101e3d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101e40:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101e45:	85 ff                	test   %edi,%edi
f0101e47:	0f 89 ac 00 00 00    	jns    f0101ef9 <vprintfmt+0x37c>
				putch('-', putdat);
f0101e4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e51:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101e58:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101e5b:	f7 de                	neg    %esi
f0101e5d:	83 d7 00             	adc    $0x0,%edi
f0101e60:	f7 df                	neg    %edi
			}
			base = 10;
f0101e62:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101e67:	e9 8d 00 00 00       	jmp    f0101ef9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101e6c:	89 ca                	mov    %ecx,%edx
f0101e6e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101e71:	e8 88 fc ff ff       	call   f0101afe <getuint>
f0101e76:	89 c6                	mov    %eax,%esi
f0101e78:	89 d7                	mov    %edx,%edi
			base = 10;
f0101e7a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0101e7f:	eb 78                	jmp    f0101ef9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101e81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e85:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101e8c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e93:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101e9a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101e9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ea1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101ea8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101eab:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101eae:	e9 ed fc ff ff       	jmp    f0101ba0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0101eb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101eb7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101ebe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101ec1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ec5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101ecc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101ecf:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ed2:	8d 50 04             	lea    0x4(%eax),%edx
f0101ed5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101ed8:	8b 30                	mov    (%eax),%esi
f0101eda:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101edf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101ee4:	eb 13                	jmp    f0101ef9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101ee6:	89 ca                	mov    %ecx,%edx
f0101ee8:	8d 45 14             	lea    0x14(%ebp),%eax
f0101eeb:	e8 0e fc ff ff       	call   f0101afe <getuint>
f0101ef0:	89 c6                	mov    %eax,%esi
f0101ef2:	89 d7                	mov    %edx,%edi
			base = 16;
f0101ef4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101ef9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0101efd:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101f01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f04:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f0c:	89 34 24             	mov    %esi,(%esp)
f0101f0f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f13:	89 da                	mov    %ebx,%edx
f0101f15:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f18:	e8 13 fb ff ff       	call   f0101a30 <printnum>
			break;
f0101f1d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101f20:	e9 7b fc ff ff       	jmp    f0101ba0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101f25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f29:	89 04 24             	mov    %eax,(%esp)
f0101f2c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101f32:	e9 69 fc ff ff       	jmp    f0101ba0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101f37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f3b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101f42:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101f45:	eb 03                	jmp    f0101f4a <vprintfmt+0x3cd>
f0101f47:	83 ee 01             	sub    $0x1,%esi
f0101f4a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101f4e:	75 f7                	jne    f0101f47 <vprintfmt+0x3ca>
f0101f50:	e9 4b fc ff ff       	jmp    f0101ba0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101f55:	83 c4 4c             	add    $0x4c,%esp
f0101f58:	5b                   	pop    %ebx
f0101f59:	5e                   	pop    %esi
f0101f5a:	5f                   	pop    %edi
f0101f5b:	5d                   	pop    %ebp
f0101f5c:	c3                   	ret    

f0101f5d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101f5d:	55                   	push   %ebp
f0101f5e:	89 e5                	mov    %esp,%ebp
f0101f60:	83 ec 28             	sub    $0x28,%esp
f0101f63:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f66:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101f69:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101f6c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101f70:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101f73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	74 30                	je     f0101fae <vsnprintf+0x51>
f0101f7e:	85 d2                	test   %edx,%edx
f0101f80:	7e 2c                	jle    f0101fae <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101f82:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f89:	8b 45 10             	mov    0x10(%ebp),%eax
f0101f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f90:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101f93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f97:	c7 04 24 38 1b 10 f0 	movl   $0xf0101b38,(%esp)
f0101f9e:	e8 da fb ff ff       	call   f0101b7d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101fa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101fa6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101fac:	eb 05                	jmp    f0101fb3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101fae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101fb3:	c9                   	leave  
f0101fb4:	c3                   	ret    

f0101fb5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101fb5:	55                   	push   %ebp
f0101fb6:	89 e5                	mov    %esp,%ebp
f0101fb8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101fbb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101fbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fc2:	8b 45 10             	mov    0x10(%ebp),%eax
f0101fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0101fd3:	89 04 24             	mov    %eax,(%esp)
f0101fd6:	e8 82 ff ff ff       	call   f0101f5d <vsnprintf>
	va_end(ap);

	return rc;
}
f0101fdb:	c9                   	leave  
f0101fdc:	c3                   	ret    
f0101fdd:	66 90                	xchg   %ax,%ax
f0101fdf:	90                   	nop

f0101fe0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101fe0:	55                   	push   %ebp
f0101fe1:	89 e5                	mov    %esp,%ebp
f0101fe3:	57                   	push   %edi
f0101fe4:	56                   	push   %esi
f0101fe5:	53                   	push   %ebx
f0101fe6:	83 ec 1c             	sub    $0x1c,%esp
f0101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101fec:	85 c0                	test   %eax,%eax
f0101fee:	74 10                	je     f0102000 <readline+0x20>
		cprintf("%s", prompt);
f0101ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ff4:	c7 04 24 f0 2d 10 f0 	movl   $0xf0102df0,(%esp)
f0101ffb:	e8 56 f7 ff ff       	call   f0101756 <cprintf>

	i = 0;
	echoing = iscons(0);
f0102000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102007:	e8 f6 e5 ff ff       	call   f0100602 <iscons>
f010200c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010200e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102013:	e8 d9 e5 ff ff       	call   f01005f1 <getchar>
f0102018:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010201a:	85 c0                	test   %eax,%eax
f010201c:	79 17                	jns    f0102035 <readline+0x55>
			cprintf("read error: %e\n", c);
f010201e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102022:	c7 04 24 c0 31 10 f0 	movl   $0xf01031c0,(%esp)
f0102029:	e8 28 f7 ff ff       	call   f0101756 <cprintf>
			return NULL;
f010202e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102033:	eb 6d                	jmp    f01020a2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102035:	83 f8 08             	cmp    $0x8,%eax
f0102038:	74 05                	je     f010203f <readline+0x5f>
f010203a:	83 f8 7f             	cmp    $0x7f,%eax
f010203d:	75 19                	jne    f0102058 <readline+0x78>
f010203f:	85 f6                	test   %esi,%esi
f0102041:	7e 15                	jle    f0102058 <readline+0x78>
			if (echoing)
f0102043:	85 ff                	test   %edi,%edi
f0102045:	74 0c                	je     f0102053 <readline+0x73>
				cputchar('\b');
f0102047:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010204e:	e8 8e e5 ff ff       	call   f01005e1 <cputchar>
			i--;
f0102053:	83 ee 01             	sub    $0x1,%esi
f0102056:	eb bb                	jmp    f0102013 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102058:	83 fb 1f             	cmp    $0x1f,%ebx
f010205b:	7e 1f                	jle    f010207c <readline+0x9c>
f010205d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102063:	7f 17                	jg     f010207c <readline+0x9c>
			if (echoing)
f0102065:	85 ff                	test   %edi,%edi
f0102067:	74 08                	je     f0102071 <readline+0x91>
				cputchar(c);
f0102069:	89 1c 24             	mov    %ebx,(%esp)
f010206c:	e8 70 e5 ff ff       	call   f01005e1 <cputchar>
			buf[i++] = c;
f0102071:	88 9e 60 45 11 f0    	mov    %bl,-0xfeebaa0(%esi)
f0102077:	83 c6 01             	add    $0x1,%esi
f010207a:	eb 97                	jmp    f0102013 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010207c:	83 fb 0a             	cmp    $0xa,%ebx
f010207f:	74 05                	je     f0102086 <readline+0xa6>
f0102081:	83 fb 0d             	cmp    $0xd,%ebx
f0102084:	75 8d                	jne    f0102013 <readline+0x33>
			if (echoing)
f0102086:	85 ff                	test   %edi,%edi
f0102088:	74 0c                	je     f0102096 <readline+0xb6>
				cputchar('\n');
f010208a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0102091:	e8 4b e5 ff ff       	call   f01005e1 <cputchar>
			buf[i] = 0;
f0102096:	c6 86 60 45 11 f0 00 	movb   $0x0,-0xfeebaa0(%esi)
			return buf;
f010209d:	b8 60 45 11 f0       	mov    $0xf0114560,%eax
		}
	}
}
f01020a2:	83 c4 1c             	add    $0x1c,%esp
f01020a5:	5b                   	pop    %ebx
f01020a6:	5e                   	pop    %esi
f01020a7:	5f                   	pop    %edi
f01020a8:	5d                   	pop    %ebp
f01020a9:	c3                   	ret    
f01020aa:	66 90                	xchg   %ax,%ax
f01020ac:	66 90                	xchg   %ax,%ax
f01020ae:	66 90                	xchg   %ax,%ax

f01020b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01020b0:	55                   	push   %ebp
f01020b1:	89 e5                	mov    %esp,%ebp
f01020b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01020b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01020bb:	eb 03                	jmp    f01020c0 <strlen+0x10>
		n++;
f01020bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01020c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01020c4:	75 f7                	jne    f01020bd <strlen+0xd>
		n++;
	return n;
}
f01020c6:	5d                   	pop    %ebp
f01020c7:	c3                   	ret    

f01020c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01020c8:	55                   	push   %ebp
f01020c9:	89 e5                	mov    %esp,%ebp
f01020cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01020ce:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01020d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01020d6:	eb 03                	jmp    f01020db <strnlen+0x13>
		n++;
f01020d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01020db:	39 d0                	cmp    %edx,%eax
f01020dd:	74 06                	je     f01020e5 <strnlen+0x1d>
f01020df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01020e3:	75 f3                	jne    f01020d8 <strnlen+0x10>
		n++;
	return n;
}
f01020e5:	5d                   	pop    %ebp
f01020e6:	c3                   	ret    

f01020e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01020e7:	55                   	push   %ebp
f01020e8:	89 e5                	mov    %esp,%ebp
f01020ea:	53                   	push   %ebx
f01020eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01020ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01020f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01020f6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01020fa:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01020fd:	83 c2 01             	add    $0x1,%edx
f0102100:	84 c9                	test   %cl,%cl
f0102102:	75 f2                	jne    f01020f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0102104:	5b                   	pop    %ebx
f0102105:	5d                   	pop    %ebp
f0102106:	c3                   	ret    

f0102107 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102107:	55                   	push   %ebp
f0102108:	89 e5                	mov    %esp,%ebp
f010210a:	53                   	push   %ebx
f010210b:	83 ec 08             	sub    $0x8,%esp
f010210e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0102111:	89 1c 24             	mov    %ebx,(%esp)
f0102114:	e8 97 ff ff ff       	call   f01020b0 <strlen>
	strcpy(dst + len, src);
f0102119:	8b 55 0c             	mov    0xc(%ebp),%edx
f010211c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102120:	01 d8                	add    %ebx,%eax
f0102122:	89 04 24             	mov    %eax,(%esp)
f0102125:	e8 bd ff ff ff       	call   f01020e7 <strcpy>
	return dst;
}
f010212a:	89 d8                	mov    %ebx,%eax
f010212c:	83 c4 08             	add    $0x8,%esp
f010212f:	5b                   	pop    %ebx
f0102130:	5d                   	pop    %ebp
f0102131:	c3                   	ret    

f0102132 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102132:	55                   	push   %ebp
f0102133:	89 e5                	mov    %esp,%ebp
f0102135:	56                   	push   %esi
f0102136:	53                   	push   %ebx
f0102137:	8b 45 08             	mov    0x8(%ebp),%eax
f010213a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010213d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102140:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102145:	eb 0f                	jmp    f0102156 <strncpy+0x24>
		*dst++ = *src;
f0102147:	0f b6 1a             	movzbl (%edx),%ebx
f010214a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010214d:	80 3a 01             	cmpb   $0x1,(%edx)
f0102150:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102153:	83 c1 01             	add    $0x1,%ecx
f0102156:	39 f1                	cmp    %esi,%ecx
f0102158:	75 ed                	jne    f0102147 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010215a:	5b                   	pop    %ebx
f010215b:	5e                   	pop    %esi
f010215c:	5d                   	pop    %ebp
f010215d:	c3                   	ret    

f010215e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010215e:	55                   	push   %ebp
f010215f:	89 e5                	mov    %esp,%ebp
f0102161:	56                   	push   %esi
f0102162:	53                   	push   %ebx
f0102163:	8b 75 08             	mov    0x8(%ebp),%esi
f0102166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102169:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010216c:	89 f0                	mov    %esi,%eax
f010216e:	85 d2                	test   %edx,%edx
f0102170:	75 0a                	jne    f010217c <strlcpy+0x1e>
f0102172:	eb 1d                	jmp    f0102191 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102174:	88 18                	mov    %bl,(%eax)
f0102176:	83 c0 01             	add    $0x1,%eax
f0102179:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010217c:	83 ea 01             	sub    $0x1,%edx
f010217f:	74 0b                	je     f010218c <strlcpy+0x2e>
f0102181:	0f b6 19             	movzbl (%ecx),%ebx
f0102184:	84 db                	test   %bl,%bl
f0102186:	75 ec                	jne    f0102174 <strlcpy+0x16>
f0102188:	89 c2                	mov    %eax,%edx
f010218a:	eb 02                	jmp    f010218e <strlcpy+0x30>
f010218c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010218e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0102191:	29 f0                	sub    %esi,%eax
}
f0102193:	5b                   	pop    %ebx
f0102194:	5e                   	pop    %esi
f0102195:	5d                   	pop    %ebp
f0102196:	c3                   	ret    

f0102197 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102197:	55                   	push   %ebp
f0102198:	89 e5                	mov    %esp,%ebp
f010219a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010219d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01021a0:	eb 06                	jmp    f01021a8 <strcmp+0x11>
		p++, q++;
f01021a2:	83 c1 01             	add    $0x1,%ecx
f01021a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01021a8:	0f b6 01             	movzbl (%ecx),%eax
f01021ab:	84 c0                	test   %al,%al
f01021ad:	74 04                	je     f01021b3 <strcmp+0x1c>
f01021af:	3a 02                	cmp    (%edx),%al
f01021b1:	74 ef                	je     f01021a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01021b3:	0f b6 c0             	movzbl %al,%eax
f01021b6:	0f b6 12             	movzbl (%edx),%edx
f01021b9:	29 d0                	sub    %edx,%eax
}
f01021bb:	5d                   	pop    %ebp
f01021bc:	c3                   	ret    

f01021bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01021bd:	55                   	push   %ebp
f01021be:	89 e5                	mov    %esp,%ebp
f01021c0:	53                   	push   %ebx
f01021c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01021c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01021c7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01021ca:	eb 09                	jmp    f01021d5 <strncmp+0x18>
		n--, p++, q++;
f01021cc:	83 ea 01             	sub    $0x1,%edx
f01021cf:	83 c0 01             	add    $0x1,%eax
f01021d2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01021d5:	85 d2                	test   %edx,%edx
f01021d7:	74 15                	je     f01021ee <strncmp+0x31>
f01021d9:	0f b6 18             	movzbl (%eax),%ebx
f01021dc:	84 db                	test   %bl,%bl
f01021de:	74 04                	je     f01021e4 <strncmp+0x27>
f01021e0:	3a 19                	cmp    (%ecx),%bl
f01021e2:	74 e8                	je     f01021cc <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01021e4:	0f b6 00             	movzbl (%eax),%eax
f01021e7:	0f b6 11             	movzbl (%ecx),%edx
f01021ea:	29 d0                	sub    %edx,%eax
f01021ec:	eb 05                	jmp    f01021f3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01021ee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01021f3:	5b                   	pop    %ebx
f01021f4:	5d                   	pop    %ebp
f01021f5:	c3                   	ret    

f01021f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01021f6:	55                   	push   %ebp
f01021f7:	89 e5                	mov    %esp,%ebp
f01021f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01021fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102200:	eb 07                	jmp    f0102209 <strchr+0x13>
		if (*s == c)
f0102202:	38 ca                	cmp    %cl,%dl
f0102204:	74 0f                	je     f0102215 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102206:	83 c0 01             	add    $0x1,%eax
f0102209:	0f b6 10             	movzbl (%eax),%edx
f010220c:	84 d2                	test   %dl,%dl
f010220e:	75 f2                	jne    f0102202 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0102210:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102215:	5d                   	pop    %ebp
f0102216:	c3                   	ret    

f0102217 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102217:	55                   	push   %ebp
f0102218:	89 e5                	mov    %esp,%ebp
f010221a:	8b 45 08             	mov    0x8(%ebp),%eax
f010221d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102221:	eb 07                	jmp    f010222a <strfind+0x13>
		if (*s == c)
f0102223:	38 ca                	cmp    %cl,%dl
f0102225:	74 0a                	je     f0102231 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102227:	83 c0 01             	add    $0x1,%eax
f010222a:	0f b6 10             	movzbl (%eax),%edx
f010222d:	84 d2                	test   %dl,%dl
f010222f:	75 f2                	jne    f0102223 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0102231:	5d                   	pop    %ebp
f0102232:	c3                   	ret    

f0102233 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102233:	55                   	push   %ebp
f0102234:	89 e5                	mov    %esp,%ebp
f0102236:	83 ec 0c             	sub    $0xc,%esp
f0102239:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010223c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010223f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0102242:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102245:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102248:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010224b:	85 c9                	test   %ecx,%ecx
f010224d:	74 30                	je     f010227f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010224f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102255:	75 25                	jne    f010227c <memset+0x49>
f0102257:	f6 c1 03             	test   $0x3,%cl
f010225a:	75 20                	jne    f010227c <memset+0x49>
		c &= 0xFF;
f010225c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010225f:	89 d3                	mov    %edx,%ebx
f0102261:	c1 e3 08             	shl    $0x8,%ebx
f0102264:	89 d6                	mov    %edx,%esi
f0102266:	c1 e6 18             	shl    $0x18,%esi
f0102269:	89 d0                	mov    %edx,%eax
f010226b:	c1 e0 10             	shl    $0x10,%eax
f010226e:	09 f0                	or     %esi,%eax
f0102270:	09 d0                	or     %edx,%eax
f0102272:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0102274:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102277:	fc                   	cld    
f0102278:	f3 ab                	rep stos %eax,%es:(%edi)
f010227a:	eb 03                	jmp    f010227f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010227c:	fc                   	cld    
f010227d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010227f:	89 f8                	mov    %edi,%eax
f0102281:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0102284:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102287:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010228a:	89 ec                	mov    %ebp,%esp
f010228c:	5d                   	pop    %ebp
f010228d:	c3                   	ret    

f010228e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010228e:	55                   	push   %ebp
f010228f:	89 e5                	mov    %esp,%ebp
f0102291:	83 ec 08             	sub    $0x8,%esp
f0102294:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0102297:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010229a:	8b 45 08             	mov    0x8(%ebp),%eax
f010229d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01022a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01022a3:	39 c6                	cmp    %eax,%esi
f01022a5:	73 36                	jae    f01022dd <memmove+0x4f>
f01022a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01022aa:	39 d0                	cmp    %edx,%eax
f01022ac:	73 2f                	jae    f01022dd <memmove+0x4f>
		s += n;
		d += n;
f01022ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01022b1:	f6 c2 03             	test   $0x3,%dl
f01022b4:	75 1b                	jne    f01022d1 <memmove+0x43>
f01022b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01022bc:	75 13                	jne    f01022d1 <memmove+0x43>
f01022be:	f6 c1 03             	test   $0x3,%cl
f01022c1:	75 0e                	jne    f01022d1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01022c3:	83 ef 04             	sub    $0x4,%edi
f01022c6:	8d 72 fc             	lea    -0x4(%edx),%esi
f01022c9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01022cc:	fd                   	std    
f01022cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01022cf:	eb 09                	jmp    f01022da <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01022d1:	83 ef 01             	sub    $0x1,%edi
f01022d4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01022d7:	fd                   	std    
f01022d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01022da:	fc                   	cld    
f01022db:	eb 20                	jmp    f01022fd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01022dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01022e3:	75 13                	jne    f01022f8 <memmove+0x6a>
f01022e5:	a8 03                	test   $0x3,%al
f01022e7:	75 0f                	jne    f01022f8 <memmove+0x6a>
f01022e9:	f6 c1 03             	test   $0x3,%cl
f01022ec:	75 0a                	jne    f01022f8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01022ee:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01022f1:	89 c7                	mov    %eax,%edi
f01022f3:	fc                   	cld    
f01022f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01022f6:	eb 05                	jmp    f01022fd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01022f8:	89 c7                	mov    %eax,%edi
f01022fa:	fc                   	cld    
f01022fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01022fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102300:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102303:	89 ec                	mov    %ebp,%esp
f0102305:	5d                   	pop    %ebp
f0102306:	c3                   	ret    

f0102307 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102307:	55                   	push   %ebp
f0102308:	89 e5                	mov    %esp,%ebp
f010230a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010230d:	8b 45 10             	mov    0x10(%ebp),%eax
f0102310:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102314:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102317:	89 44 24 04          	mov    %eax,0x4(%esp)
f010231b:	8b 45 08             	mov    0x8(%ebp),%eax
f010231e:	89 04 24             	mov    %eax,(%esp)
f0102321:	e8 68 ff ff ff       	call   f010228e <memmove>
}
f0102326:	c9                   	leave  
f0102327:	c3                   	ret    

f0102328 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102328:	55                   	push   %ebp
f0102329:	89 e5                	mov    %esp,%ebp
f010232b:	57                   	push   %edi
f010232c:	56                   	push   %esi
f010232d:	53                   	push   %ebx
f010232e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102331:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102334:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102337:	ba 00 00 00 00       	mov    $0x0,%edx
f010233c:	eb 1a                	jmp    f0102358 <memcmp+0x30>
		if (*s1 != *s2)
f010233e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0102342:	83 c2 01             	add    $0x1,%edx
f0102345:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f010234a:	38 c8                	cmp    %cl,%al
f010234c:	74 0a                	je     f0102358 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
f010234e:	0f b6 c0             	movzbl %al,%eax
f0102351:	0f b6 c9             	movzbl %cl,%ecx
f0102354:	29 c8                	sub    %ecx,%eax
f0102356:	eb 09                	jmp    f0102361 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102358:	39 da                	cmp    %ebx,%edx
f010235a:	75 e2                	jne    f010233e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010235c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102361:	5b                   	pop    %ebx
f0102362:	5e                   	pop    %esi
f0102363:	5f                   	pop    %edi
f0102364:	5d                   	pop    %ebp
f0102365:	c3                   	ret    

f0102366 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102366:	55                   	push   %ebp
f0102367:	89 e5                	mov    %esp,%ebp
f0102369:	8b 45 08             	mov    0x8(%ebp),%eax
f010236c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010236f:	89 c2                	mov    %eax,%edx
f0102371:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102374:	eb 07                	jmp    f010237d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102376:	38 08                	cmp    %cl,(%eax)
f0102378:	74 07                	je     f0102381 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010237a:	83 c0 01             	add    $0x1,%eax
f010237d:	39 d0                	cmp    %edx,%eax
f010237f:	72 f5                	jb     f0102376 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102381:	5d                   	pop    %ebp
f0102382:	c3                   	ret    

f0102383 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102383:	55                   	push   %ebp
f0102384:	89 e5                	mov    %esp,%ebp
f0102386:	57                   	push   %edi
f0102387:	56                   	push   %esi
f0102388:	53                   	push   %ebx
f0102389:	8b 55 08             	mov    0x8(%ebp),%edx
f010238c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010238f:	eb 03                	jmp    f0102394 <strtol+0x11>
		s++;
f0102391:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102394:	0f b6 02             	movzbl (%edx),%eax
f0102397:	3c 20                	cmp    $0x20,%al
f0102399:	74 f6                	je     f0102391 <strtol+0xe>
f010239b:	3c 09                	cmp    $0x9,%al
f010239d:	74 f2                	je     f0102391 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010239f:	3c 2b                	cmp    $0x2b,%al
f01023a1:	75 0a                	jne    f01023ad <strtol+0x2a>
		s++;
f01023a3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01023a6:	bf 00 00 00 00       	mov    $0x0,%edi
f01023ab:	eb 10                	jmp    f01023bd <strtol+0x3a>
f01023ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01023b2:	3c 2d                	cmp    $0x2d,%al
f01023b4:	75 07                	jne    f01023bd <strtol+0x3a>
		s++, neg = 1;
f01023b6:	8d 52 01             	lea    0x1(%edx),%edx
f01023b9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01023bd:	85 db                	test   %ebx,%ebx
f01023bf:	0f 94 c0             	sete   %al
f01023c2:	74 05                	je     f01023c9 <strtol+0x46>
f01023c4:	83 fb 10             	cmp    $0x10,%ebx
f01023c7:	75 15                	jne    f01023de <strtol+0x5b>
f01023c9:	80 3a 30             	cmpb   $0x30,(%edx)
f01023cc:	75 10                	jne    f01023de <strtol+0x5b>
f01023ce:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01023d2:	75 0a                	jne    f01023de <strtol+0x5b>
		s += 2, base = 16;
f01023d4:	83 c2 02             	add    $0x2,%edx
f01023d7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01023dc:	eb 13                	jmp    f01023f1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01023de:	84 c0                	test   %al,%al
f01023e0:	74 0f                	je     f01023f1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01023e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01023e7:	80 3a 30             	cmpb   $0x30,(%edx)
f01023ea:	75 05                	jne    f01023f1 <strtol+0x6e>
		s++, base = 8;
f01023ec:	83 c2 01             	add    $0x1,%edx
f01023ef:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01023f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01023f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01023f8:	0f b6 0a             	movzbl (%edx),%ecx
f01023fb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01023fe:	80 fb 09             	cmp    $0x9,%bl
f0102401:	77 08                	ja     f010240b <strtol+0x88>
			dig = *s - '0';
f0102403:	0f be c9             	movsbl %cl,%ecx
f0102406:	83 e9 30             	sub    $0x30,%ecx
f0102409:	eb 1e                	jmp    f0102429 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f010240b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010240e:	80 fb 19             	cmp    $0x19,%bl
f0102411:	77 08                	ja     f010241b <strtol+0x98>
			dig = *s - 'a' + 10;
f0102413:	0f be c9             	movsbl %cl,%ecx
f0102416:	83 e9 57             	sub    $0x57,%ecx
f0102419:	eb 0e                	jmp    f0102429 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010241b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010241e:	80 fb 19             	cmp    $0x19,%bl
f0102421:	77 14                	ja     f0102437 <strtol+0xb4>
			dig = *s - 'A' + 10;
f0102423:	0f be c9             	movsbl %cl,%ecx
f0102426:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102429:	39 f1                	cmp    %esi,%ecx
f010242b:	7d 0e                	jge    f010243b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
f010242d:	83 c2 01             	add    $0x1,%edx
f0102430:	0f af c6             	imul   %esi,%eax
f0102433:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0102435:	eb c1                	jmp    f01023f8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102437:	89 c1                	mov    %eax,%ecx
f0102439:	eb 02                	jmp    f010243d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010243b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010243d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0102441:	74 05                	je     f0102448 <strtol+0xc5>
		*endptr = (char *) s;
f0102443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102446:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0102448:	89 ca                	mov    %ecx,%edx
f010244a:	f7 da                	neg    %edx
f010244c:	85 ff                	test   %edi,%edi
f010244e:	0f 45 c2             	cmovne %edx,%eax
}
f0102451:	5b                   	pop    %ebx
f0102452:	5e                   	pop    %esi
f0102453:	5f                   	pop    %edi
f0102454:	5d                   	pop    %ebp
f0102455:	c3                   	ret    
f0102456:	66 90                	xchg   %ax,%ax
f0102458:	66 90                	xchg   %ax,%ax
f010245a:	66 90                	xchg   %ax,%ax
f010245c:	66 90                	xchg   %ax,%ax
f010245e:	66 90                	xchg   %ax,%ax

f0102460 <__udivdi3>:
f0102460:	55                   	push   %ebp
f0102461:	57                   	push   %edi
f0102462:	56                   	push   %esi
f0102463:	83 ec 0c             	sub    $0xc,%esp
f0102466:	8b 44 24 28          	mov    0x28(%esp),%eax
f010246a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010246e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0102472:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0102476:	85 c0                	test   %eax,%eax
f0102478:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010247c:	89 ea                	mov    %ebp,%edx
f010247e:	89 0c 24             	mov    %ecx,(%esp)
f0102481:	75 2d                	jne    f01024b0 <__udivdi3+0x50>
f0102483:	39 e9                	cmp    %ebp,%ecx
f0102485:	77 61                	ja     f01024e8 <__udivdi3+0x88>
f0102487:	85 c9                	test   %ecx,%ecx
f0102489:	89 ce                	mov    %ecx,%esi
f010248b:	75 0b                	jne    f0102498 <__udivdi3+0x38>
f010248d:	b8 01 00 00 00       	mov    $0x1,%eax
f0102492:	31 d2                	xor    %edx,%edx
f0102494:	f7 f1                	div    %ecx
f0102496:	89 c6                	mov    %eax,%esi
f0102498:	31 d2                	xor    %edx,%edx
f010249a:	89 e8                	mov    %ebp,%eax
f010249c:	f7 f6                	div    %esi
f010249e:	89 c5                	mov    %eax,%ebp
f01024a0:	89 f8                	mov    %edi,%eax
f01024a2:	f7 f6                	div    %esi
f01024a4:	89 ea                	mov    %ebp,%edx
f01024a6:	83 c4 0c             	add    $0xc,%esp
f01024a9:	5e                   	pop    %esi
f01024aa:	5f                   	pop    %edi
f01024ab:	5d                   	pop    %ebp
f01024ac:	c3                   	ret    
f01024ad:	8d 76 00             	lea    0x0(%esi),%esi
f01024b0:	39 e8                	cmp    %ebp,%eax
f01024b2:	77 24                	ja     f01024d8 <__udivdi3+0x78>
f01024b4:	0f bd e8             	bsr    %eax,%ebp
f01024b7:	83 f5 1f             	xor    $0x1f,%ebp
f01024ba:	75 3c                	jne    f01024f8 <__udivdi3+0x98>
f01024bc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01024c0:	39 34 24             	cmp    %esi,(%esp)
f01024c3:	0f 86 9f 00 00 00    	jbe    f0102568 <__udivdi3+0x108>
f01024c9:	39 d0                	cmp    %edx,%eax
f01024cb:	0f 82 97 00 00 00    	jb     f0102568 <__udivdi3+0x108>
f01024d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01024d8:	31 d2                	xor    %edx,%edx
f01024da:	31 c0                	xor    %eax,%eax
f01024dc:	83 c4 0c             	add    $0xc,%esp
f01024df:	5e                   	pop    %esi
f01024e0:	5f                   	pop    %edi
f01024e1:	5d                   	pop    %ebp
f01024e2:	c3                   	ret    
f01024e3:	90                   	nop
f01024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01024e8:	89 f8                	mov    %edi,%eax
f01024ea:	f7 f1                	div    %ecx
f01024ec:	31 d2                	xor    %edx,%edx
f01024ee:	83 c4 0c             	add    $0xc,%esp
f01024f1:	5e                   	pop    %esi
f01024f2:	5f                   	pop    %edi
f01024f3:	5d                   	pop    %ebp
f01024f4:	c3                   	ret    
f01024f5:	8d 76 00             	lea    0x0(%esi),%esi
f01024f8:	89 e9                	mov    %ebp,%ecx
f01024fa:	8b 3c 24             	mov    (%esp),%edi
f01024fd:	d3 e0                	shl    %cl,%eax
f01024ff:	89 c6                	mov    %eax,%esi
f0102501:	b8 20 00 00 00       	mov    $0x20,%eax
f0102506:	29 e8                	sub    %ebp,%eax
f0102508:	89 c1                	mov    %eax,%ecx
f010250a:	d3 ef                	shr    %cl,%edi
f010250c:	89 e9                	mov    %ebp,%ecx
f010250e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102512:	8b 3c 24             	mov    (%esp),%edi
f0102515:	09 74 24 08          	or     %esi,0x8(%esp)
f0102519:	89 d6                	mov    %edx,%esi
f010251b:	d3 e7                	shl    %cl,%edi
f010251d:	89 c1                	mov    %eax,%ecx
f010251f:	89 3c 24             	mov    %edi,(%esp)
f0102522:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102526:	d3 ee                	shr    %cl,%esi
f0102528:	89 e9                	mov    %ebp,%ecx
f010252a:	d3 e2                	shl    %cl,%edx
f010252c:	89 c1                	mov    %eax,%ecx
f010252e:	d3 ef                	shr    %cl,%edi
f0102530:	09 d7                	or     %edx,%edi
f0102532:	89 f2                	mov    %esi,%edx
f0102534:	89 f8                	mov    %edi,%eax
f0102536:	f7 74 24 08          	divl   0x8(%esp)
f010253a:	89 d6                	mov    %edx,%esi
f010253c:	89 c7                	mov    %eax,%edi
f010253e:	f7 24 24             	mull   (%esp)
f0102541:	39 d6                	cmp    %edx,%esi
f0102543:	89 14 24             	mov    %edx,(%esp)
f0102546:	72 30                	jb     f0102578 <__udivdi3+0x118>
f0102548:	8b 54 24 04          	mov    0x4(%esp),%edx
f010254c:	89 e9                	mov    %ebp,%ecx
f010254e:	d3 e2                	shl    %cl,%edx
f0102550:	39 c2                	cmp    %eax,%edx
f0102552:	73 05                	jae    f0102559 <__udivdi3+0xf9>
f0102554:	3b 34 24             	cmp    (%esp),%esi
f0102557:	74 1f                	je     f0102578 <__udivdi3+0x118>
f0102559:	89 f8                	mov    %edi,%eax
f010255b:	31 d2                	xor    %edx,%edx
f010255d:	e9 7a ff ff ff       	jmp    f01024dc <__udivdi3+0x7c>
f0102562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102568:	31 d2                	xor    %edx,%edx
f010256a:	b8 01 00 00 00       	mov    $0x1,%eax
f010256f:	e9 68 ff ff ff       	jmp    f01024dc <__udivdi3+0x7c>
f0102574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102578:	8d 47 ff             	lea    -0x1(%edi),%eax
f010257b:	31 d2                	xor    %edx,%edx
f010257d:	83 c4 0c             	add    $0xc,%esp
f0102580:	5e                   	pop    %esi
f0102581:	5f                   	pop    %edi
f0102582:	5d                   	pop    %ebp
f0102583:	c3                   	ret    
f0102584:	66 90                	xchg   %ax,%ax
f0102586:	66 90                	xchg   %ax,%ax
f0102588:	66 90                	xchg   %ax,%ax
f010258a:	66 90                	xchg   %ax,%ax
f010258c:	66 90                	xchg   %ax,%ax
f010258e:	66 90                	xchg   %ax,%ax

f0102590 <__umoddi3>:
f0102590:	55                   	push   %ebp
f0102591:	57                   	push   %edi
f0102592:	56                   	push   %esi
f0102593:	83 ec 14             	sub    $0x14,%esp
f0102596:	8b 44 24 28          	mov    0x28(%esp),%eax
f010259a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010259e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01025a2:	89 c7                	mov    %eax,%edi
f01025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01025a8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01025ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01025b0:	89 34 24             	mov    %esi,(%esp)
f01025b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01025b7:	85 c0                	test   %eax,%eax
f01025b9:	89 c2                	mov    %eax,%edx
f01025bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01025bf:	75 17                	jne    f01025d8 <__umoddi3+0x48>
f01025c1:	39 fe                	cmp    %edi,%esi
f01025c3:	76 4b                	jbe    f0102610 <__umoddi3+0x80>
f01025c5:	89 c8                	mov    %ecx,%eax
f01025c7:	89 fa                	mov    %edi,%edx
f01025c9:	f7 f6                	div    %esi
f01025cb:	89 d0                	mov    %edx,%eax
f01025cd:	31 d2                	xor    %edx,%edx
f01025cf:	83 c4 14             	add    $0x14,%esp
f01025d2:	5e                   	pop    %esi
f01025d3:	5f                   	pop    %edi
f01025d4:	5d                   	pop    %ebp
f01025d5:	c3                   	ret    
f01025d6:	66 90                	xchg   %ax,%ax
f01025d8:	39 f8                	cmp    %edi,%eax
f01025da:	77 54                	ja     f0102630 <__umoddi3+0xa0>
f01025dc:	0f bd e8             	bsr    %eax,%ebp
f01025df:	83 f5 1f             	xor    $0x1f,%ebp
f01025e2:	75 5c                	jne    f0102640 <__umoddi3+0xb0>
f01025e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01025e8:	39 3c 24             	cmp    %edi,(%esp)
f01025eb:	0f 87 e7 00 00 00    	ja     f01026d8 <__umoddi3+0x148>
f01025f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01025f5:	29 f1                	sub    %esi,%ecx
f01025f7:	19 c7                	sbb    %eax,%edi
f01025f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01025fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102601:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102605:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0102609:	83 c4 14             	add    $0x14,%esp
f010260c:	5e                   	pop    %esi
f010260d:	5f                   	pop    %edi
f010260e:	5d                   	pop    %ebp
f010260f:	c3                   	ret    
f0102610:	85 f6                	test   %esi,%esi
f0102612:	89 f5                	mov    %esi,%ebp
f0102614:	75 0b                	jne    f0102621 <__umoddi3+0x91>
f0102616:	b8 01 00 00 00       	mov    $0x1,%eax
f010261b:	31 d2                	xor    %edx,%edx
f010261d:	f7 f6                	div    %esi
f010261f:	89 c5                	mov    %eax,%ebp
f0102621:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102625:	31 d2                	xor    %edx,%edx
f0102627:	f7 f5                	div    %ebp
f0102629:	89 c8                	mov    %ecx,%eax
f010262b:	f7 f5                	div    %ebp
f010262d:	eb 9c                	jmp    f01025cb <__umoddi3+0x3b>
f010262f:	90                   	nop
f0102630:	89 c8                	mov    %ecx,%eax
f0102632:	89 fa                	mov    %edi,%edx
f0102634:	83 c4 14             	add    $0x14,%esp
f0102637:	5e                   	pop    %esi
f0102638:	5f                   	pop    %edi
f0102639:	5d                   	pop    %ebp
f010263a:	c3                   	ret    
f010263b:	90                   	nop
f010263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102640:	8b 04 24             	mov    (%esp),%eax
f0102643:	be 20 00 00 00       	mov    $0x20,%esi
f0102648:	89 e9                	mov    %ebp,%ecx
f010264a:	29 ee                	sub    %ebp,%esi
f010264c:	d3 e2                	shl    %cl,%edx
f010264e:	89 f1                	mov    %esi,%ecx
f0102650:	d3 e8                	shr    %cl,%eax
f0102652:	89 e9                	mov    %ebp,%ecx
f0102654:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102658:	8b 04 24             	mov    (%esp),%eax
f010265b:	09 54 24 04          	or     %edx,0x4(%esp)
f010265f:	89 fa                	mov    %edi,%edx
f0102661:	d3 e0                	shl    %cl,%eax
f0102663:	89 f1                	mov    %esi,%ecx
f0102665:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102669:	8b 44 24 10          	mov    0x10(%esp),%eax
f010266d:	d3 ea                	shr    %cl,%edx
f010266f:	89 e9                	mov    %ebp,%ecx
f0102671:	d3 e7                	shl    %cl,%edi
f0102673:	89 f1                	mov    %esi,%ecx
f0102675:	d3 e8                	shr    %cl,%eax
f0102677:	89 e9                	mov    %ebp,%ecx
f0102679:	09 f8                	or     %edi,%eax
f010267b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010267f:	f7 74 24 04          	divl   0x4(%esp)
f0102683:	d3 e7                	shl    %cl,%edi
f0102685:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102689:	89 d7                	mov    %edx,%edi
f010268b:	f7 64 24 08          	mull   0x8(%esp)
f010268f:	39 d7                	cmp    %edx,%edi
f0102691:	89 c1                	mov    %eax,%ecx
f0102693:	89 14 24             	mov    %edx,(%esp)
f0102696:	72 2c                	jb     f01026c4 <__umoddi3+0x134>
f0102698:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010269c:	72 22                	jb     f01026c0 <__umoddi3+0x130>
f010269e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01026a2:	29 c8                	sub    %ecx,%eax
f01026a4:	19 d7                	sbb    %edx,%edi
f01026a6:	89 e9                	mov    %ebp,%ecx
f01026a8:	89 fa                	mov    %edi,%edx
f01026aa:	d3 e8                	shr    %cl,%eax
f01026ac:	89 f1                	mov    %esi,%ecx
f01026ae:	d3 e2                	shl    %cl,%edx
f01026b0:	89 e9                	mov    %ebp,%ecx
f01026b2:	d3 ef                	shr    %cl,%edi
f01026b4:	09 d0                	or     %edx,%eax
f01026b6:	89 fa                	mov    %edi,%edx
f01026b8:	83 c4 14             	add    $0x14,%esp
f01026bb:	5e                   	pop    %esi
f01026bc:	5f                   	pop    %edi
f01026bd:	5d                   	pop    %ebp
f01026be:	c3                   	ret    
f01026bf:	90                   	nop
f01026c0:	39 d7                	cmp    %edx,%edi
f01026c2:	75 da                	jne    f010269e <__umoddi3+0x10e>
f01026c4:	8b 14 24             	mov    (%esp),%edx
f01026c7:	89 c1                	mov    %eax,%ecx
f01026c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01026cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01026d1:	eb cb                	jmp    f010269e <__umoddi3+0x10e>
f01026d3:	90                   	nop
f01026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01026d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01026dc:	0f 82 0f ff ff ff    	jb     f01025f1 <__umoddi3+0x61>
f01026e2:	e9 1a ff ff ff       	jmp    f0102601 <__umoddi3+0x71>
