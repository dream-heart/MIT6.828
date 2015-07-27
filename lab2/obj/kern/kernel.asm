
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

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
f0100046:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 73 11 f0 	movl   $0xf0117300,(%esp)
f0100063:	e8 9f 38 00 00       	call   f0103907 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 a0 3d 10 f0 	movl   $0xf0103da0,(%esp)
f010007c:	e8 31 2d 00 00       	call   f0102db2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 ac 10 00 00       	call   f0101132 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 5f 07 00 00       	call   f01007f1 <monitor>
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
f010009f:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 79 11 f0    	mov    %esi,0xf0117960

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
f01000c1:	c7 04 24 bb 3d 10 f0 	movl   $0xf0103dbb,(%esp)
f01000c8:	e8 e5 2c 00 00       	call   f0102db2 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 a6 2c 00 00       	call   f0102d7f <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 b5 4c 10 f0 	movl   $0xf0104cb5,(%esp)
f01000e0:	e8 cd 2c 00 00       	call   f0102db2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 00 07 00 00       	call   f01007f1 <monitor>
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
f010010b:	c7 04 24 d3 3d 10 f0 	movl   $0xf0103dd3,(%esp)
f0100112:	e8 9b 2c 00 00       	call   f0102db2 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 59 2c 00 00       	call   f0102d7f <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 b5 4c 10 f0 	movl   $0xf0104cb5,(%esp)
f010012d:	e8 80 2c 00 00       	call   f0102db2 <cprintf>
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

f0100140 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100148:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100149:	a8 01                	test   $0x1,%al
f010014b:	74 08                	je     f0100155 <serial_proc_data+0x15>
f010014d:	b2 f8                	mov    $0xf8,%dl
f010014f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100150:	0f b6 c0             	movzbl %al,%eax
f0100153:	eb 05                	jmp    f010015a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010015a:	5d                   	pop    %ebp
f010015b:	c3                   	ret    

f010015c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp
f010015f:	53                   	push   %ebx
f0100160:	83 ec 04             	sub    $0x4,%esp
f0100163:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100165:	eb 2a                	jmp    f0100191 <cons_intr+0x35>
		if (c == 0)
f0100167:	85 d2                	test   %edx,%edx
f0100169:	74 26                	je     f0100191 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010016b:	a1 24 75 11 f0       	mov    0xf0117524,%eax
f0100170:	8d 48 01             	lea    0x1(%eax),%ecx
f0100173:	89 0d 24 75 11 f0    	mov    %ecx,0xf0117524
f0100179:	88 90 20 73 11 f0    	mov    %dl,-0xfee8ce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010017f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100185:	75 0a                	jne    f0100191 <cons_intr+0x35>
			cons.wpos = 0;
f0100187:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f010018e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100191:	ff d3                	call   *%ebx
f0100193:	89 c2                	mov    %eax,%edx
f0100195:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100198:	75 cd                	jne    f0100167 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010019a:	83 c4 04             	add    $0x4,%esp
f010019d:	5b                   	pop    %ebx
f010019e:	5d                   	pop    %ebp
f010019f:	c3                   	ret    

f01001a0 <kbd_proc_data>:
f01001a0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001a5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001a6:	a8 01                	test   $0x1,%al
f01001a8:	0f 84 ef 00 00 00    	je     f010029d <kbd_proc_data+0xfd>
f01001ae:	b2 60                	mov    $0x60,%dl
f01001b0:	ec                   	in     (%dx),%al
f01001b1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001b3:	3c e0                	cmp    $0xe0,%al
f01001b5:	75 0d                	jne    f01001c4 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001b7:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01001be:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001c3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001c4:	55                   	push   %ebp
f01001c5:	89 e5                	mov    %esp,%ebp
f01001c7:	53                   	push   %ebx
f01001c8:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001cb:	84 c0                	test   %al,%al
f01001cd:	79 37                	jns    f0100206 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001cf:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001d5:	89 cb                	mov    %ecx,%ebx
f01001d7:	83 e3 40             	and    $0x40,%ebx
f01001da:	83 e0 7f             	and    $0x7f,%eax
f01001dd:	85 db                	test   %ebx,%ebx
f01001df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e2:	0f b6 d2             	movzbl %dl,%edx
f01001e5:	0f b6 82 40 3f 10 f0 	movzbl -0xfefc0c0(%edx),%eax
f01001ec:	83 c8 40             	or     $0x40,%eax
f01001ef:	0f b6 c0             	movzbl %al,%eax
f01001f2:	f7 d0                	not    %eax
f01001f4:	21 c1                	and    %eax,%ecx
f01001f6:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
		return 0;
f01001fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100201:	e9 9d 00 00 00       	jmp    f01002a3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100206:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f010020c:	f6 c1 40             	test   $0x40,%cl
f010020f:	74 0e                	je     f010021f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100211:	83 c8 80             	or     $0xffffff80,%eax
f0100214:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100216:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100219:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f010021f:	0f b6 d2             	movzbl %dl,%edx
f0100222:	0f b6 82 40 3f 10 f0 	movzbl -0xfefc0c0(%edx),%eax
f0100229:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 40 3e 10 f0 	movzbl -0xfefc1c0(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 20 3e 10 f0 	mov    -0xfefc1e0(,%ecx,4),%ecx
f0100249:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100250:	a8 08                	test   $0x8,%al
f0100252:	74 1b                	je     f010026f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100254:	89 da                	mov    %ebx,%edx
f0100256:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100259:	83 f9 19             	cmp    $0x19,%ecx
f010025c:	77 05                	ja     f0100263 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010025e:	83 eb 20             	sub    $0x20,%ebx
f0100261:	eb 0c                	jmp    f010026f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100263:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100266:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100269:	83 fa 19             	cmp    $0x19,%edx
f010026c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026f:	f7 d0                	not    %eax
f0100271:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100273:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100275:	f6 c2 06             	test   $0x6,%dl
f0100278:	75 29                	jne    f01002a3 <kbd_proc_data+0x103>
f010027a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100280:	75 21                	jne    f01002a3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100282:	c7 04 24 ed 3d 10 f0 	movl   $0xf0103ded,(%esp)
f0100289:	e8 24 2b 00 00       	call   f0102db2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100293:	b8 03 00 00 00       	mov    $0x3,%eax
f0100298:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100299:	89 d8                	mov    %ebx,%eax
f010029b:	eb 06                	jmp    f01002a3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010029d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002a2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002a3:	83 c4 14             	add    $0x14,%esp
f01002a6:	5b                   	pop    %ebx
f01002a7:	5d                   	pop    %ebp
f01002a8:	c3                   	ret    

f01002a9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a9:	55                   	push   %ebp
f01002aa:	89 e5                	mov    %esp,%ebp
f01002ac:	57                   	push   %edi
f01002ad:	56                   	push   %esi
f01002ae:	53                   	push   %ebx
f01002af:	83 ec 1c             	sub    $0x1c,%esp
f01002b2:	89 c7                	mov    %eax,%edi
f01002b4:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002be:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c3:	eb 06                	jmp    f01002cb <cons_putc+0x22>
f01002c5:	89 ca                	mov    %ecx,%edx
f01002c7:	ec                   	in     (%dx),%al
f01002c8:	ec                   	in     (%dx),%al
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	89 f2                	mov    %esi,%edx
f01002cd:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ce:	a8 20                	test   $0x20,%al
f01002d0:	75 05                	jne    f01002d7 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d2:	83 eb 01             	sub    $0x1,%ebx
f01002d5:	75 ee                	jne    f01002c5 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002d7:	89 f8                	mov    %edi,%eax
f01002d9:	0f b6 c0             	movzbl %al,%eax
f01002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002df:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e4:	ee                   	out    %al,(%dx)
f01002e5:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ea:	be 79 03 00 00       	mov    $0x379,%esi
f01002ef:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002f4:	eb 06                	jmp    f01002fc <cons_putc+0x53>
f01002f6:	89 ca                	mov    %ecx,%edx
f01002f8:	ec                   	in     (%dx),%al
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	ec                   	in     (%dx),%al
f01002fb:	ec                   	in     (%dx),%al
f01002fc:	89 f2                	mov    %esi,%edx
f01002fe:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002ff:	84 c0                	test   %al,%al
f0100301:	78 05                	js     f0100308 <cons_putc+0x5f>
f0100303:	83 eb 01             	sub    $0x1,%ebx
f0100306:	75 ee                	jne    f01002f6 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100308:	ba 78 03 00 00       	mov    $0x378,%edx
f010030d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100311:	ee                   	out    %al,(%dx)
f0100312:	b2 7a                	mov    $0x7a,%dl
f0100314:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100319:	ee                   	out    %al,(%dx)
f010031a:	b8 08 00 00 00       	mov    $0x8,%eax
f010031f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100320:	89 fa                	mov    %edi,%edx
f0100322:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100328:	89 f8                	mov    %edi,%eax
f010032a:	80 cc 07             	or     $0x7,%ah
f010032d:	85 d2                	test   %edx,%edx
f010032f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	0f b6 c0             	movzbl %al,%eax
f0100337:	83 f8 09             	cmp    $0x9,%eax
f010033a:	74 76                	je     f01003b2 <cons_putc+0x109>
f010033c:	83 f8 09             	cmp    $0x9,%eax
f010033f:	7f 0a                	jg     f010034b <cons_putc+0xa2>
f0100341:	83 f8 08             	cmp    $0x8,%eax
f0100344:	74 16                	je     f010035c <cons_putc+0xb3>
f0100346:	e9 9b 00 00 00       	jmp    f01003e6 <cons_putc+0x13d>
f010034b:	83 f8 0a             	cmp    $0xa,%eax
f010034e:	66 90                	xchg   %ax,%ax
f0100350:	74 3a                	je     f010038c <cons_putc+0xe3>
f0100352:	83 f8 0d             	cmp    $0xd,%eax
f0100355:	74 3d                	je     f0100394 <cons_putc+0xeb>
f0100357:	e9 8a 00 00 00       	jmp    f01003e6 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010035c:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100363:	66 85 c0             	test   %ax,%ax
f0100366:	0f 84 e5 00 00 00    	je     f0100451 <cons_putc+0x1a8>
			crt_pos--;
f010036c:	83 e8 01             	sub    $0x1,%eax
f010036f:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100375:	0f b7 c0             	movzwl %ax,%eax
f0100378:	66 81 e7 00 ff       	and    $0xff00,%di
f010037d:	83 cf 20             	or     $0x20,%edi
f0100380:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100386:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038a:	eb 78                	jmp    f0100404 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038c:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f0100393:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100394:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f010039b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a1:	c1 e8 16             	shr    $0x16,%eax
f01003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a7:	c1 e0 04             	shl    $0x4,%eax
f01003aa:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003b0:	eb 52                	jmp    f0100404 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f01003b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b7:	e8 ed fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c1:	e8 e3 fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cb:	e8 d9 fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d5:	e8 cf fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003da:	b8 20 00 00 00       	mov    $0x20,%eax
f01003df:	e8 c5 fe ff ff       	call   f01002a9 <cons_putc>
f01003e4:	eb 1e                	jmp    f0100404 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e6:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003ed:	8d 50 01             	lea    0x1(%eax),%edx
f01003f0:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f01003f7:	0f b7 c0             	movzwl %ax,%eax
f01003fa:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100400:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100404:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f010040b:	cf 07 
f010040d:	76 42                	jbe    f0100451 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040f:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f0100414:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010041b:	00 
f010041c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100422:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100426:	89 04 24             	mov    %eax,(%esp)
f0100429:	e8 26 35 00 00       	call   f0103954 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042e:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100434:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100439:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043f:	83 c0 01             	add    $0x1,%eax
f0100442:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100447:	75 f0                	jne    f0100439 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047f:	83 c4 1c             	add    $0x1c,%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 40 01 10 f0       	mov    $0xf0100140,%eax
f010049b:	e8 bc fc ff ff       	call   f010015c <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 a0 01 10 f0       	mov    $0xf01001a0,%eax
f01004ae:	e8 a9 fc ff ff       	call   f010015c <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004ca:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f01004db:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 ca                	mov    %ecx,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 f0             	movzbl %al,%esi
f0100563:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 ca                	mov    %ecx,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 3d 2c 75 11 f0    	mov    %edi,0xf011752c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100577:	0f b6 d8             	movzbl %al,%ebx
f010057a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057c:	66 89 35 28 75 11 f0 	mov    %si,0xf0117528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100583:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
f010058d:	89 f2                	mov    %esi,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 fb                	mov    $0xfb,%dl
f0100592:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059d:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a2:	89 da                	mov    %ebx,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 f9                	mov    $0xf9,%dl
f01005a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ac:	ee                   	out    %al,(%dx)
f01005ad:	b2 fb                	mov    $0xfb,%dl
f01005af:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	b2 fc                	mov    $0xfc,%dl
f01005b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	b2 f9                	mov    $0xf9,%dl
f01005bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01005c4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c5:	b2 fd                	mov    $0xfd,%dl
f01005c7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c8:	3c ff                	cmp    $0xff,%al
f01005ca:	0f 95 c1             	setne  %cl
f01005cd:	88 0d 34 75 11 f0    	mov    %cl,0xf0117534
f01005d3:	89 f2                	mov    %esi,%edx
f01005d5:	ec                   	in     (%dx),%al
f01005d6:	89 da                	mov    %ebx,%edx
f01005d8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d9:	84 c9                	test   %cl,%cl
f01005db:	75 0c                	jne    f01005e9 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f01005dd:	c7 04 24 f9 3d 10 f0 	movl   $0xf0103df9,(%esp)
f01005e4:	e8 c9 27 00 00       	call   f0102db2 <cprintf>
}
f01005e9:	83 c4 1c             	add    $0x1c,%esp
f01005ec:	5b                   	pop    %ebx
f01005ed:	5e                   	pop    %esi
f01005ee:	5f                   	pop    %edi
f01005ef:	5d                   	pop    %ebp
f01005f0:	c3                   	ret    

f01005f1 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f1:	55                   	push   %ebp
f01005f2:	89 e5                	mov    %esp,%ebp
f01005f4:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fa:	e8 aa fc ff ff       	call   f01002a9 <cons_putc>
}
f01005ff:	c9                   	leave  
f0100600:	c3                   	ret    

f0100601 <getchar>:

int
getchar(void)
{
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
f0100604:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100607:	e8 a9 fe ff ff       	call   f01004b5 <cons_getc>
f010060c:	85 c0                	test   %eax,%eax
f010060e:	74 f7                	je     f0100607 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <iscons>:

int
iscons(int fdnum)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100615:	b8 01 00 00 00       	mov    $0x1,%eax
f010061a:	5d                   	pop    %ebp
f010061b:	c3                   	ret    
f010061c:	66 90                	xchg   %ax,%ax
f010061e:	66 90                	xchg   %ax,%ax

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	c7 44 24 08 40 40 10 	movl   $0xf0104040,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 5e 40 10 	movl   $0xf010405e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 63 40 10 f0 	movl   $0xf0104063,(%esp)
f010063d:	e8 70 27 00 00       	call   f0102db2 <cprintf>
f0100642:	c7 44 24 08 00 41 10 	movl   $0xf0104100,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 6c 40 10 	movl   $0xf010406c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 63 40 10 f0 	movl   $0xf0104063,(%esp)
f0100659:	e8 54 27 00 00       	call   f0102db2 <cprintf>
	return 0;
}
f010065e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100663:	c9                   	leave  
f0100664:	c3                   	ret    

f0100665 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100665:	55                   	push   %ebp
f0100666:	89 e5                	mov    %esp,%ebp
f0100668:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010066b:	c7 04 24 75 40 10 f0 	movl   $0xf0104075,(%esp)
f0100672:	e8 3b 27 00 00       	call   f0102db2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 28 41 10 f0 	movl   $0xf0104128,(%esp)
f0100686:	e8 27 27 00 00       	call   f0102db2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 50 41 10 f0 	movl   $0xf0104150,(%esp)
f01006a2:	e8 0b 27 00 00       	call   f0102db2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 97 3d 10 	movl   $0x103d97,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 97 3d 10 	movl   $0xf0103d97,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 74 41 10 f0 	movl   $0xf0104174,(%esp)
f01006be:	e8 ef 26 00 00       	call   f0102db2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 73 11 	movl   $0x117300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 73 11 	movl   $0xf0117300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 98 41 10 f0 	movl   $0xf0104198,(%esp)
f01006da:	e8 d3 26 00 00       	call   f0102db2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 79 11 	movl   $0x117970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 79 11 	movl   $0xf0117970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 bc 41 10 f0 	movl   $0xf01041bc,(%esp)
f01006f6:	e8 b7 26 00 00       	call   f0102db2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006fb:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f0100700:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100705:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010070a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100710:	85 c0                	test   %eax,%eax
f0100712:	0f 48 c2             	cmovs  %edx,%eax
f0100715:	c1 f8 0a             	sar    $0xa,%eax
f0100718:	89 44 24 04          	mov    %eax,0x4(%esp)
f010071c:	c7 04 24 e0 41 10 f0 	movl   $0xf01041e0,(%esp)
f0100723:	e8 8a 26 00 00       	call   f0102db2 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100728:	b8 00 00 00 00       	mov    $0x0,%eax
f010072d:	c9                   	leave  
f010072e:	c3                   	ret    

f010072f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	struct Eipdebuginfo info;
f010072f:	55                   	push   %ebp
f0100730:	89 e5                	mov    %esp,%ebp
f0100732:	57                   	push   %edi
f0100733:	56                   	push   %esi
f0100734:	53                   	push   %ebx
f0100735:	83 ec 5c             	sub    $0x5c,%esp
	unsigned int *ebp=(unsigned int *)read_ebp();
f0100738:	89 eb                	mov    %ebp,%ebx

static __inline uint32_t
read_esp(void)
{
	uint32_t esp;
	__asm __volatile("movl %%esp,%0" : "=r" (esp));
f010073a:	89 e0                	mov    %esp,%eax
	while(ebp)
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f010073c:	8d 75 d0             	lea    -0x30(%ebp),%esi
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f010073f:	e9 92 00 00 00       	jmp    f01007d6 <mon_backtrace+0xa7>
	{		
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
f0100744:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100748:	89 54 85 bc          	mov    %edx,-0x44(%ebp,%eax,4)
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
	{		
			for(i=0;i<5;i++)
f010074c:	83 c0 01             	add    $0x1,%eax
f010074f:	83 f8 05             	cmp    $0x5,%eax
f0100752:	75 f0                	jne    f0100744 <mon_backtrace+0x15>
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
f0100754:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100758:	8b 43 04             	mov    0x4(%ebx),%eax
f010075b:	89 04 24             	mov    %eax,(%esp)
f010075e:	e8 46 27 00 00       	call   f0102ea9 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 8e 40 10 f0 	movl   $0xf010408e,(%esp)
f0100775:	e8 38 26 00 00       	call   f0102db2 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 a9 40 10 f0 	movl   $0xf01040a9,(%esp)
f010078a:	e8 23 26 00 00       	call   f0102db2 <cprintf>
f010078f:	83 c7 04             	add    $0x4,%edi
			for(i=0;i<5;i++)
				arg[i]=*(ebp+i+2);
			eip=ebp+1;
			debuginfo_eip(*eip,&info);
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
			for(i=0;i<5;++i)
f0100792:	39 f7                	cmp    %esi,%edi
f0100794:	75 e7                	jne    f010077d <mon_backtrace+0x4e>
			cprintf("%08x  ", arg[i]);
			cprintf("\n");
f0100796:	c7 04 24 b5 4c 10 f0 	movl   $0xf0104cb5,(%esp)
f010079d:	e8 10 26 00 00       	call   f0102db2 <cprintf>
			
			cprintf("\t\t%s:%u:%.*s+%u\n",
f01007a2:	8b 43 04             	mov    0x4(%ebx),%eax
f01007a5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007a8:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01007af:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01007b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c8:	c7 04 24 b0 40 10 f0 	movl   $0xf01040b0,(%esp)
f01007cf:	e8 de 25 00 00       	call   f0102db2 <cprintf>
				info.eip_line,
				info.eip_fn_namelen,
				info.eip_fn_name,
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
f01007d4:	8b 1b                	mov    (%ebx),%ebx
	unsigned int *ebp=(unsigned int *)read_ebp();
	unsigned int *esp=(unsigned int *)read_esp();
	unsigned int *eip=0;
	unsigned int arg[5];
	int i=0;
	while(ebp)
f01007d6:	85 db                	test   %ebx,%ebx
f01007d8:	74 0a                	je     f01007e4 <mon_backtrace+0xb5>
f01007da:	b8 00 00 00 00       	mov    $0x0,%eax
f01007df:	e9 60 ff ff ff       	jmp    f0100744 <mon_backtrace+0x15>
				*eip-info.eip_fn_addr);
			esp=ebp+2;
			ebp=(unsigned int *)*ebp;
	}
	return 0;
}
f01007e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e9:	83 c4 5c             	add    $0x5c,%esp
f01007ec:	5b                   	pop    %ebx
f01007ed:	5e                   	pop    %esi
f01007ee:	5f                   	pop    %edi
f01007ef:	5d                   	pop    %ebp
f01007f0:	c3                   	ret    

f01007f1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007f1:	55                   	push   %ebp
f01007f2:	89 e5                	mov    %esp,%ebp
f01007f4:	57                   	push   %edi
f01007f5:	56                   	push   %esi
f01007f6:	53                   	push   %ebx
f01007f7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007fa:	c7 04 24 0c 42 10 f0 	movl   $0xf010420c,(%esp)
f0100801:	e8 ac 25 00 00       	call   f0102db2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 30 42 10 f0 	movl   $0xf0104230,(%esp)
f010080d:	e8 a0 25 00 00       	call   f0102db2 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 c1 40 10 f0 	movl   $0xf01040c1,(%esp)
f0100819:	e8 92 2e 00 00       	call   f01036b0 <readline>
f010081e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100820:	85 c0                	test   %eax,%eax
f0100822:	74 ee                	je     f0100812 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100824:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010082b:	be 00 00 00 00       	mov    $0x0,%esi
f0100830:	eb 0a                	jmp    f010083c <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100832:	c6 03 00             	movb   $0x0,(%ebx)
f0100835:	89 f7                	mov    %esi,%edi
f0100837:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010083a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010083c:	0f b6 03             	movzbl (%ebx),%eax
f010083f:	84 c0                	test   %al,%al
f0100841:	74 63                	je     f01008a6 <monitor+0xb5>
f0100843:	0f be c0             	movsbl %al,%eax
f0100846:	89 44 24 04          	mov    %eax,0x4(%esp)
f010084a:	c7 04 24 c5 40 10 f0 	movl   $0xf01040c5,(%esp)
f0100851:	e8 74 30 00 00       	call   f01038ca <strchr>
f0100856:	85 c0                	test   %eax,%eax
f0100858:	75 d8                	jne    f0100832 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f010085a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010085d:	74 47                	je     f01008a6 <monitor+0xb5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010085f:	83 fe 0f             	cmp    $0xf,%esi
f0100862:	75 16                	jne    f010087a <monitor+0x89>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100864:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010086b:	00 
f010086c:	c7 04 24 ca 40 10 f0 	movl   $0xf01040ca,(%esp)
f0100873:	e8 3a 25 00 00       	call   f0102db2 <cprintf>
f0100878:	eb 98                	jmp    f0100812 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f010087a:	8d 7e 01             	lea    0x1(%esi),%edi
f010087d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100881:	eb 03                	jmp    f0100886 <monitor+0x95>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100883:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100886:	0f b6 03             	movzbl (%ebx),%eax
f0100889:	84 c0                	test   %al,%al
f010088b:	74 ad                	je     f010083a <monitor+0x49>
f010088d:	0f be c0             	movsbl %al,%eax
f0100890:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100894:	c7 04 24 c5 40 10 f0 	movl   $0xf01040c5,(%esp)
f010089b:	e8 2a 30 00 00       	call   f01038ca <strchr>
f01008a0:	85 c0                	test   %eax,%eax
f01008a2:	74 df                	je     f0100883 <monitor+0x92>
f01008a4:	eb 94                	jmp    f010083a <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f01008a6:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ad:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008ae:	85 f6                	test   %esi,%esi
f01008b0:	0f 84 5c ff ff ff    	je     f0100812 <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b6:	c7 44 24 04 5e 40 10 	movl   $0xf010405e,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 a3 2f 00 00       	call   f010386c <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 6c 40 10 	movl   $0xf010406c,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 8c 2f 00 00       	call   f010386c <strcmp>
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	75 2f                	jne    f0100913 <monitor+0x122>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008e4:	b0 01                	mov    $0x1,%al
f01008e6:	eb 05                	jmp    f01008ed <monitor+0xfc>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e8:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008ed:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008f0:	01 d0                	add    %edx,%eax
f01008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01008f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01008f9:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100900:	89 34 24             	mov    %esi,(%esp)
f0100903:	ff 14 85 60 42 10 f0 	call   *-0xfefbda0(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010090a:	85 c0                	test   %eax,%eax
f010090c:	78 1d                	js     f010092b <monitor+0x13a>
f010090e:	e9 ff fe ff ff       	jmp    f0100812 <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100913:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100916:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091a:	c7 04 24 e7 40 10 f0 	movl   $0xf01040e7,(%esp)
f0100921:	e8 8c 24 00 00       	call   f0102db2 <cprintf>
f0100926:	e9 e7 fe ff ff       	jmp    f0100812 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092b:	83 c4 5c             	add    $0x5c,%esp
f010092e:	5b                   	pop    %ebx
f010092f:	5e                   	pop    %esi
f0100930:	5f                   	pop    %edi
f0100931:	5d                   	pop    %ebp
f0100932:	c3                   	ret    

f0100933 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100933:	55                   	push   %ebp
f0100934:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100936:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f010093d:	75 11                	jne    f0100950 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f010093f:	ba 6f 89 11 f0       	mov    $0xf011896f,%edx
f0100944:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094a:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100950:	85 c0                	test   %eax,%eax
f0100952:	75 07                	jne    f010095b <boot_alloc+0x28>
		return nextfree;
f0100954:	a1 38 75 11 f0       	mov    0xf0117538,%eax
f0100959:	eb 19                	jmp    f0100974 <boot_alloc+0x41>
	result = nextfree;
f010095b:	8b 15 38 75 11 f0    	mov    0xf0117538,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100961:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	a3 38 75 11 f0       	mov    %eax,0xf0117538
	
	// return the head address of the alloc pages;
	return result;
f0100972:	89 d0                	mov    %edx,%eax
}
f0100974:	5d                   	pop    %ebp
f0100975:	c3                   	ret    

f0100976 <page2kva>:
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100976:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010097c:	c1 f8 03             	sar    $0x3,%eax
f010097f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100982:	89 c2                	mov    %eax,%edx
f0100984:	c1 ea 0c             	shr    $0xc,%edx
f0100987:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f010098d:	72 26                	jb     f01009b5 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f010098f:	55                   	push   %ebp
f0100990:	89 e5                	mov    %esp,%ebp
f0100992:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100995:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100999:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f01009a0:	f0 
f01009a1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01009a8:	00 
f01009a9:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f01009b0:	e8 df f6 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01009b5:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f01009ba:	c3                   	ret    

f01009bb <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009bb:	89 d1                	mov    %edx,%ecx
f01009bd:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009c0:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c3:	a8 01                	test   $0x1,%al
f01009c5:	74 5d                	je     f0100a24 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009cc:	89 c1                	mov    %eax,%ecx
f01009ce:	c1 e9 0c             	shr    $0xc,%ecx
f01009d1:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f01009d7:	72 26                	jb     f01009ff <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009d9:	55                   	push   %ebp
f01009da:	89 e5                	mov    %esp,%ebp
f01009dc:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009e3:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f01009ea:	f0 
f01009eb:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01009f2:	00 
f01009f3:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01009fa:	e8 95 f6 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009ff:	c1 ea 0c             	shr    $0xc,%edx
f0100a02:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a08:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a0f:	89 c2                	mov    %eax,%edx
f0100a11:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a19:	85 d2                	test   %edx,%edx
f0100a1b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a20:	0f 44 c2             	cmove  %edx,%eax
f0100a23:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a29:	c3                   	ret    

f0100a2a <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a2a:	55                   	push   %ebp
f0100a2b:	89 e5                	mov    %esp,%ebp
f0100a2d:	57                   	push   %edi
f0100a2e:	56                   	push   %esi
f0100a2f:	53                   	push   %ebx
f0100a30:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a33:	84 c0                	test   %al,%al
f0100a35:	0f 85 07 03 00 00    	jne    f0100d42 <check_page_free_list+0x318>
f0100a3b:	e9 14 03 00 00       	jmp    f0100d54 <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a40:	c7 44 24 08 94 42 10 	movl   $0xf0104294,0x8(%esp)
f0100a47:	f0 
f0100a48:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100a4f:	00 
f0100a50:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100a57:	e8 38 f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a5c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a5f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a62:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a65:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a68:	89 c2                	mov    %eax,%edx
f0100a6a:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a70:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a76:	0f 95 c2             	setne  %dl
f0100a79:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a7c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a80:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a82:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a86:	8b 00                	mov    (%eax),%eax
f0100a88:	85 c0                	test   %eax,%eax
f0100a8a:	75 dc                	jne    f0100a68 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a98:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a9b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100aa0:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa5:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aaa:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ab0:	eb 63                	jmp    f0100b15 <check_page_free_list+0xeb>
f0100ab2:	89 d8                	mov    %ebx,%eax
f0100ab4:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100aba:	c1 f8 03             	sar    $0x3,%eax
f0100abd:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ac0:	89 c2                	mov    %eax,%edx
f0100ac2:	c1 ea 16             	shr    $0x16,%edx
f0100ac5:	39 f2                	cmp    %esi,%edx
f0100ac7:	73 4a                	jae    f0100b13 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac9:	89 c2                	mov    %eax,%edx
f0100acb:	c1 ea 0c             	shr    $0xc,%edx
f0100ace:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100ad4:	72 20                	jb     f0100af6 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ada:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0100ae1:	f0 
f0100ae2:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ae9:	00 
f0100aea:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0100af1:	e8 9e f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af6:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100afd:	00 
f0100afe:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b05:	00 
	return (void *)(pa + KERNBASE);
f0100b06:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b0b:	89 04 24             	mov    %eax,(%esp)
f0100b0e:	e8 f4 2d 00 00       	call   f0103907 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b13:	8b 1b                	mov    (%ebx),%ebx
f0100b15:	85 db                	test   %ebx,%ebx
f0100b17:	75 99                	jne    f0100ab2 <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b1e:	e8 10 fe ff ff       	call   f0100933 <boot_alloc>
f0100b23:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b26:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b2c:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100b32:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100b37:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b3a:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b40:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b43:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b48:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b4b:	e9 97 01 00 00       	jmp    f0100ce7 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b50:	39 ca                	cmp    %ecx,%edx
f0100b52:	73 24                	jae    f0100b78 <check_page_free_list+0x14e>
f0100b54:	c7 44 24 0c 1e 4a 10 	movl   $0xf0104a1e,0xc(%esp)
f0100b5b:	f0 
f0100b5c:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100b63:	f0 
f0100b64:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100b6b:	00 
f0100b6c:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100b73:	e8 1c f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b78:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b7b:	72 24                	jb     f0100ba1 <check_page_free_list+0x177>
f0100b7d:	c7 44 24 0c 3f 4a 10 	movl   $0xf0104a3f,0xc(%esp)
f0100b84:	f0 
f0100b85:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100b8c:	f0 
f0100b8d:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100b94:	00 
f0100b95:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100b9c:	e8 f3 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ba1:	89 d0                	mov    %edx,%eax
f0100ba3:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ba6:	a8 07                	test   $0x7,%al
f0100ba8:	74 24                	je     f0100bce <check_page_free_list+0x1a4>
f0100baa:	c7 44 24 0c b8 42 10 	movl   $0xf01042b8,0xc(%esp)
f0100bb1:	f0 
f0100bb2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100bb9:	f0 
f0100bba:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f0100bc1:	00 
f0100bc2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100bc9:	e8 c6 f4 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bce:	c1 f8 03             	sar    $0x3,%eax
f0100bd1:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bd4:	85 c0                	test   %eax,%eax
f0100bd6:	75 24                	jne    f0100bfc <check_page_free_list+0x1d2>
f0100bd8:	c7 44 24 0c 53 4a 10 	movl   $0xf0104a53,0xc(%esp)
f0100bdf:	f0 
f0100be0:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100be7:	f0 
f0100be8:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f0100bef:	00 
f0100bf0:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100bf7:	e8 98 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bfc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c01:	75 24                	jne    f0100c27 <check_page_free_list+0x1fd>
f0100c03:	c7 44 24 0c 64 4a 10 	movl   $0xf0104a64,0xc(%esp)
f0100c0a:	f0 
f0100c0b:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100c12:	f0 
f0100c13:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f0100c1a:	00 
f0100c1b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100c22:	e8 6d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c27:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c2c:	75 24                	jne    f0100c52 <check_page_free_list+0x228>
f0100c2e:	c7 44 24 0c ec 42 10 	movl   $0xf01042ec,0xc(%esp)
f0100c35:	f0 
f0100c36:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100c3d:	f0 
f0100c3e:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0100c45:	00 
f0100c46:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100c4d:	e8 42 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c52:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c57:	75 24                	jne    f0100c7d <check_page_free_list+0x253>
f0100c59:	c7 44 24 0c 7d 4a 10 	movl   $0xf0104a7d,0xc(%esp)
f0100c60:	f0 
f0100c61:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100c68:	f0 
f0100c69:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100c70:	00 
f0100c71:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100c78:	e8 17 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c7d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c82:	76 58                	jbe    f0100cdc <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c84:	89 c3                	mov    %eax,%ebx
f0100c86:	c1 eb 0c             	shr    $0xc,%ebx
f0100c89:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c8c:	77 20                	ja     f0100cae <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c92:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0100c99:	f0 
f0100c9a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ca1:	00 
f0100ca2:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0100ca9:	e8 e6 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100cae:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cb3:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100cb6:	76 2a                	jbe    f0100ce2 <check_page_free_list+0x2b8>
f0100cb8:	c7 44 24 0c 10 43 10 	movl   $0xf0104310,0xc(%esp)
f0100cbf:	f0 
f0100cc0:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100cc7:	f0 
f0100cc8:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100ccf:	00 
f0100cd0:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100cd7:	e8 b8 f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cdc:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100ce0:	eb 03                	jmp    f0100ce5 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100ce2:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce5:	8b 12                	mov    (%edx),%edx
f0100ce7:	85 d2                	test   %edx,%edx
f0100ce9:	0f 85 61 fe ff ff    	jne    f0100b50 <check_page_free_list+0x126>
f0100cef:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cf2:	85 db                	test   %ebx,%ebx
f0100cf4:	7f 24                	jg     f0100d1a <check_page_free_list+0x2f0>
f0100cf6:	c7 44 24 0c 97 4a 10 	movl   $0xf0104a97,0xc(%esp)
f0100cfd:	f0 
f0100cfe:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100d05:	f0 
f0100d06:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f0100d0d:	00 
f0100d0e:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100d15:	e8 7a f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d1a:	85 ff                	test   %edi,%edi
f0100d1c:	7f 4d                	jg     f0100d6b <check_page_free_list+0x341>
f0100d1e:	c7 44 24 0c a9 4a 10 	movl   $0xf0104aa9,0xc(%esp)
f0100d25:	f0 
f0100d26:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0100d2d:	f0 
f0100d2e:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f0100d35:	00 
f0100d36:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100d3d:	e8 52 f3 ff ff       	call   f0100094 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d42:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100d47:	85 c0                	test   %eax,%eax
f0100d49:	0f 85 0d fd ff ff    	jne    f0100a5c <check_page_free_list+0x32>
f0100d4f:	e9 ec fc ff ff       	jmp    f0100a40 <check_page_free_list+0x16>
f0100d54:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d5b:	0f 84 df fc ff ff    	je     f0100a40 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d61:	be 00 04 00 00       	mov    $0x400,%esi
f0100d66:	e9 3f fd ff ff       	jmp    f0100aaa <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d6b:	83 c4 4c             	add    $0x4c,%esp
f0100d6e:	5b                   	pop    %ebx
f0100d6f:	5e                   	pop    %esi
f0100d70:	5f                   	pop    %edi
f0100d71:	5d                   	pop    %ebp
f0100d72:	c3                   	ret    

f0100d73 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d73:	55                   	push   %ebp
f0100d74:	89 e5                	mov    %esp,%ebp
f0100d76:	56                   	push   %esi
f0100d77:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d78:	be 00 00 00 00       	mov    $0x0,%esi
f0100d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d82:	e9 c5 00 00 00       	jmp    f0100e4c <page_init+0xd9>
		if(i == 0)
f0100d87:	85 db                	test   %ebx,%ebx
f0100d89:	75 16                	jne    f0100da1 <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100d8b:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100d90:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d9c:	e9 a5 00 00 00       	jmp    f0100e46 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100da1:	3b 1d 40 75 11 f0    	cmp    0xf0117540,%ebx
f0100da7:	73 25                	jae    f0100dce <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100da9:	89 f0                	mov    %esi,%eax
f0100dab:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100db1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100db7:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100dbd:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100dbf:	89 f0                	mov    %esi,%eax
f0100dc1:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100dc7:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
f0100dcc:	eb 78                	jmp    f0100e46 <page_init+0xd3>
f0100dce:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100dd4:	83 f8 5f             	cmp    $0x5f,%eax
f0100dd7:	77 16                	ja     f0100def <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100dd9:	89 f0                	mov    %esi,%eax
f0100ddb:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100de1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100de7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ded:	eb 57                	jmp    f0100e46 <page_init+0xd3>
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100def:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100df5:	76 2c                	jbe    f0100e23 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfc:	e8 32 fb ff ff       	call   f0100933 <boot_alloc>
f0100e01:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e06:	c1 e8 0c             	shr    $0xc,%eax
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100e09:	39 c3                	cmp    %eax,%ebx
f0100e0b:	73 16                	jae    f0100e23 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100e0d:	89 f0                	mov    %esi,%eax
f0100e0f:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100e15:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100e1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100e21:	eb 23                	jmp    f0100e46 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100e23:	89 f0                	mov    %esi,%eax
f0100e25:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100e2b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100e31:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100e37:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100e39:	89 f0                	mov    %esi,%eax
f0100e3b:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100e41:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e46:	83 c3 01             	add    $0x1,%ebx
f0100e49:	83 c6 08             	add    $0x8,%esi
f0100e4c:	3b 1d 64 79 11 f0    	cmp    0xf0117964,%ebx
f0100e52:	0f 82 2f ff ff ff    	jb     f0100d87 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100e58:	5b                   	pop    %ebx
f0100e59:	5e                   	pop    %esi
f0100e5a:	5d                   	pop    %ebp
f0100e5b:	c3                   	ret    

f0100e5c <page_alloc>:

//apply a page, if alloc_flage==0, do not initialize the page;
//if alloc_flags==1, initialize the page and make the entire page '\0';
struct PageInfo *
page_alloc(int alloc_flags)
{	
f0100e5c:	55                   	push   %ebp
f0100e5d:	89 e5                	mov    %esp,%ebp
f0100e5f:	53                   	push   %ebx
f0100e60:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100e63:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e69:	85 db                	test   %ebx,%ebx
f0100e6b:	74 6f                	je     f0100edc <page_alloc+0x80>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e6d:	8b 03                	mov    (%ebx),%eax
f0100e6f:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
		page->pp_link = NULL;
f0100e74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
f0100e7a:	89 d8                	mov    %ebx,%eax
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
		page->pp_link = NULL;

		if(alloc_flags & ALLOC_ZERO)
f0100e7c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e80:	74 5f                	je     f0100ee1 <page_alloc+0x85>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e82:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100e88:	c1 f8 03             	sar    $0x3,%eax
f0100e8b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e8e:	89 c2                	mov    %eax,%edx
f0100e90:	c1 ea 0c             	shr    $0xc,%edx
f0100e93:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100e99:	72 20                	jb     f0100ebb <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e9f:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0100ea6:	f0 
f0100ea7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100eae:	00 
f0100eaf:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0100eb6:	e8 d9 f1 ff ff       	call   f0100094 <_panic>
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
f0100ebb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ec2:	00 
f0100ec3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eca:	00 
	return (void *)(pa + KERNBASE);
f0100ecb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed0:	89 04 24             	mov    %eax,(%esp)
f0100ed3:	e8 2f 2a 00 00       	call   f0103907 <memset>
	}

	return page;
f0100ed8:	89 d8                	mov    %ebx,%eax
f0100eda:	eb 05                	jmp    f0100ee1 <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{	
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0100edc:	b8 00 00 00 00       	mov    $0x0,%eax
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
}
f0100ee1:	83 c4 14             	add    $0x14,%esp
f0100ee4:	5b                   	pop    %ebx
f0100ee5:	5d                   	pop    %ebp
f0100ee6:	c3                   	ret    

f0100ee7 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ee7:	55                   	push   %ebp
f0100ee8:	89 e5                	mov    %esp,%ebp
f0100eea:	83 ec 18             	sub    $0x18,%esp
f0100eed:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link !=NULL)
f0100ef0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ef5:	75 05                	jne    f0100efc <page_free+0x15>
f0100ef7:	83 38 00             	cmpl   $0x0,(%eax)
f0100efa:	74 1c                	je     f0100f18 <page_free+0x31>
		panic("pp_ref is not 0 or the pp_link is not NULL. The page is used\n");
f0100efc:	c7 44 24 08 58 43 10 	movl   $0xf0104358,0x8(%esp)
f0100f03:	f0 
f0100f04:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
f0100f0b:	00 
f0100f0c:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100f13:	e8 7c f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100f18:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f1e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f20:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	return;
}
f0100f25:	c9                   	leave  
f0100f26:	c3                   	ret    

f0100f27 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f27:	55                   	push   %ebp
f0100f28:	89 e5                	mov    %esp,%ebp
f0100f2a:	83 ec 18             	sub    $0x18,%esp
f0100f2d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f30:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100f34:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100f37:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f3b:	66 85 d2             	test   %dx,%dx
f0100f3e:	75 08                	jne    f0100f48 <page_decref+0x21>
		page_free(pp);
f0100f40:	89 04 24             	mov    %eax,(%esp)
f0100f43:	e8 9f ff ff ff       	call   f0100ee7 <page_free>
}
f0100f48:	c9                   	leave  
f0100f49:	c3                   	ret    

f0100f4a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	
f0100f4a:	55                   	push   %ebp
f0100f4b:	89 e5                	mov    %esp,%ebp
f0100f4d:	56                   	push   %esi
f0100f4e:	53                   	push   %ebx
f0100f4f:	83 ec 10             	sub    $0x10,%esp
f0100f52:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int pdx =(physaddr_t)(va) >>22 & 0x3FF;
f0100f55:	89 f3                	mov    %esi,%ebx
f0100f57:	c1 eb 16             	shr    $0x16,%ebx
	//
	// va->base address of the pte; has not add the pageTable offset;
	//
	pgdir = pgdir + pdx;
f0100f5a:	c1 e3 02             	shl    $0x2,%ebx
f0100f5d:	03 5d 08             	add    0x8(%ebp),%ebx
	if(*pgdir == 0 )
f0100f60:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f63:	75 2c                	jne    f0100f91 <pgdir_walk+0x47>
	{
		if(create == 0)
f0100f65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f69:	74 6c                	je     f0100fd7 <pgdir_walk+0x8d>
			return NULL;
		struct PageInfo* newPage = page_alloc(1);
f0100f6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f72:	e8 e5 fe ff ff       	call   f0100e5c <page_alloc>
		if(newPage == NULL)
f0100f77:	85 c0                	test   %eax,%eax
f0100f79:	74 63                	je     f0100fde <pgdir_walk+0x94>
			return NULL;
		newPage->pp_ref++;
f0100f7b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f80:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f86:	c1 f8 03             	sar    $0x3,%eax
f0100f89:	c1 e0 0c             	shl    $0xc,%eax
		*pgdir = page2pa(newPage);	//物理地址
		*pgdir |= (PTE_P |PTE_W | PTE_U);	//不懂
f0100f8c:	83 c8 07             	or     $0x7,%eax
f0100f8f:	89 03                	mov    %eax,(%ebx)
	}

	unsigned int ptx = (physaddr_t)(va) >>12 & 0x3FF;
f0100f91:	c1 ee 0c             	shr    $0xc,%esi
f0100f94:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t pte_pa = *pgdir & (~0xFFF); 				//va对应的pte页表的首项物理地址 
f0100f9a:	8b 03                	mov    (%ebx),%eax
f0100f9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa1:	89 c2                	mov    %eax,%edx
f0100fa3:	c1 ea 0c             	shr    $0xc,%edx
f0100fa6:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100fac:	72 20                	jb     f0100fce <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb2:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0100fb9:	f0 
f0100fba:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
f0100fc1:	00 
f0100fc2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0100fc9:	e8 c6 f0 ff ff       	call   f0100094 <_panic>
	pte_t* vPte = KADDR(pte_pa);				//得到pte的虚拟地址（+kernbase）,并把地址赋给vPte;
	return &vPte[ptx];					//返回的是va对应的pte项的虚拟地址
f0100fce:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100fd5:	eb 0c                	jmp    f0100fe3 <pgdir_walk+0x99>
	//
	pgdir = pgdir + pdx;
	if(*pgdir == 0 )
	{
		if(create == 0)
			return NULL;
f0100fd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdc:	eb 05                	jmp    f0100fe3 <pgdir_walk+0x99>
		struct PageInfo* newPage = page_alloc(1);
		if(newPage == NULL)
			return NULL;
f0100fde:	b8 00 00 00 00       	mov    $0x0,%eax
	return &vPte[ptx];					//返回的是va对应的pte项的虚拟地址
	//需要返回虚拟地址，而不是物理地址，搞死人啊！！！
	//pte_t* vaPTE = (physaddr_t*) ((*vaPTEBaseAddrePointer >> 12 << 12) +ptOffset) ;
	//return vaPTE;

}
f0100fe3:	83 c4 10             	add    $0x10,%esp
f0100fe6:	5b                   	pop    %ebx
f0100fe7:	5e                   	pop    %esi
f0100fe8:	5d                   	pop    %ebp
f0100fe9:	c3                   	ret    

f0100fea <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	53                   	push   %ebx
f0100fee:	83 ec 14             	sub    $0x14,%esp
f0100ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt = pgdir_walk(pgdir, va,0);
f0100ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ffb:	00 
f0100ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101003:	8b 45 08             	mov    0x8(%ebp),%eax
f0101006:	89 04 24             	mov    %eax,(%esp)
f0101009:	e8 3c ff ff ff       	call   f0100f4a <pgdir_walk>
	if(pt == NULL )
f010100e:	85 c0                	test   %eax,%eax
f0101010:	74 3a                	je     f010104c <page_lookup+0x62>
		return NULL;
	if( pte_store != NULL)
f0101012:	85 db                	test   %ebx,%ebx
f0101014:	74 02                	je     f0101018 <page_lookup+0x2e>
		*pte_store = pt;
f0101016:	89 03                	mov    %eax,(%ebx)
	//struct PageInfo* ret = pa2page( (pte_t) pageTable);
	struct PageInfo* page = pa2page(  *pt & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
f0101018:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010101a:	c1 e8 0c             	shr    $0xc,%eax
f010101d:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0101023:	72 1c                	jb     f0101041 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101025:	c7 44 24 08 98 43 10 	movl   $0xf0104398,0x8(%esp)
f010102c:	f0 
f010102d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101034:	00 
f0101035:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f010103c:	e8 53 f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101041:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101047:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return page;
f010104a:	eb 05                	jmp    f0101051 <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * pt = pgdir_walk(pgdir, va,0);
	if(pt == NULL )
		return NULL;
f010104c:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo* page = pa2page(  *pt & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
	return page;

	// Fill this function in
	
}
f0101051:	83 c4 14             	add    $0x14,%esp
f0101054:	5b                   	pop    %ebx
f0101055:	5d                   	pop    %ebp
f0101056:	c3                   	ret    

f0101057 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{	
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
f010105a:	53                   	push   %ebx
f010105b:	83 ec 24             	sub    $0x24,%esp
f010105e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//有问题  还要再看看
	pte_t * pte = 0 ;
f0101061:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	pte_t ** pt_store = &pte;
	struct PageInfo* phyPage = page_lookup(pgdir, va, pt_store);
f0101068:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010106b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010106f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101073:	8b 45 08             	mov    0x8(%ebp),%eax
f0101076:	89 04 24             	mov    %eax,(%esp)
f0101079:	e8 6c ff ff ff       	call   f0100fea <page_lookup>
	if(phyPage == 0)
f010107e:	85 c0                	test   %eax,%eax
f0101080:	74 14                	je     f0101096 <page_remove+0x3f>
		return ;
	page_decref(phyPage);
f0101082:	89 04 24             	mov    %eax,(%esp)
f0101085:	e8 9d fe ff ff       	call   f0100f27 <page_decref>
	*pte = 0;
f010108a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010108d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101093:	0f 01 3b             	invlpg (%ebx)
	//才会调用这个函数。而tlb_invalidate(va)函数的作用，就是把TLB中，va的缓存清除掉。
	//TLB，mmu的转换缓存，以并行方式查找，速度很快，是va->pa转换速度的前提。
	//
	tlb_invalidate(pgdir,va);	
	return;
}
f0101096:	83 c4 24             	add    $0x24,%esp
f0101099:	5b                   	pop    %ebx
f010109a:	5d                   	pop    %ebp
f010109b:	c3                   	ret    

f010109c <page_insert>:
// and page2pa.
//
//把va指向pp所对应的物理地址，即 (pp-pages)<<12
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010109c:	55                   	push   %ebp
f010109d:	89 e5                	mov    %esp,%ebp
f010109f:	57                   	push   %edi
f01010a0:	56                   	push   %esi
f01010a1:	53                   	push   %ebx
f01010a2:	83 ec 1c             	sub    $0x1c,%esp
f01010a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010a8:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* PT = pgdir_walk(pgdir,va,1);
f01010ab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010b2:	00 
f01010b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ba:	89 04 24             	mov    %eax,(%esp)
f01010bd:	e8 88 fe ff ff       	call   f0100f4a <pgdir_walk>
f01010c2:	89 c6                	mov    %eax,%esi
	if(PT == NULL)
f01010c4:	85 c0                	test   %eax,%eax
f01010c6:	74 5d                	je     f0101125 <page_insert+0x89>
		return -E_NO_MEM;
	// va 已经指向了pp
	if( (*PT & ~0xFFF) == page2pa(pp) )	//*vaPT里面存储的是va所在页的物理地址
f01010c8:	8b 00                	mov    (%eax),%eax
f01010ca:	89 c1                	mov    %eax,%ecx
f01010cc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010d2:	89 da                	mov    %ebx,%edx
f01010d4:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01010da:	c1 fa 03             	sar    $0x3,%edx
f01010dd:	c1 e2 0c             	shl    $0xc,%edx
f01010e0:	39 d1                	cmp    %edx,%ecx
f01010e2:	75 0a                	jne    f01010ee <page_insert+0x52>
f01010e4:	0f 01 3f             	invlpg (%edi)
		{
			tlb_invalidate(pgdir,va);	//为什么？
			pp->pp_ref--;
f01010e7:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01010ec:	eb 13                	jmp    f0101101 <page_insert+0x65>
		}
	//若va已经分配，则取消其分配 简单检测*vaPT里面的值是否是0来判断
	else  if(*PT != 0)	
f01010ee:	85 c0                	test   %eax,%eax
f01010f0:	74 0f                	je     f0101101 <page_insert+0x65>
		page_remove(pgdir,va);
f01010f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01010f9:	89 04 24             	mov    %eax,(%esp)
f01010fc:	e8 56 ff ff ff       	call   f0101057 <page_remove>
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	PT[0] = page2pa(pp)| perm | PTE_P;
f0101101:	8b 55 14             	mov    0x14(%ebp),%edx
f0101104:	83 ca 01             	or     $0x1,%edx
f0101107:	89 d8                	mov    %ebx,%eax
f0101109:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010110f:	c1 f8 03             	sar    $0x3,%eax
f0101112:	c1 e0 0c             	shl    $0xc,%eax
f0101115:	09 d0                	or     %edx,%eax
f0101117:	89 06                	mov    %eax,(%esi)
	pp->pp_ref ++;
f0101119:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0; 
f010111e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101123:	eb 05                	jmp    f010112a <page_insert+0x8e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* PT = pgdir_walk(pgdir,va,1);
	if(PT == NULL)
		return -E_NO_MEM;
f0101125:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	PT[0] = page2pa(pp)| perm | PTE_P;
	pp->pp_ref ++;
	return 0; 
}
f010112a:	83 c4 1c             	add    $0x1c,%esp
f010112d:	5b                   	pop    %ebx
f010112e:	5e                   	pop    %esi
f010112f:	5f                   	pop    %edi
f0101130:	5d                   	pop    %ebp
f0101131:	c3                   	ret    

f0101132 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101132:	55                   	push   %ebp
f0101133:	89 e5                	mov    %esp,%ebp
f0101135:	57                   	push   %edi
f0101136:	56                   	push   %esi
f0101137:	53                   	push   %ebx
f0101138:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010113b:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101142:	e8 fb 1b 00 00       	call   f0102d42 <mc146818_read>
f0101147:	89 c3                	mov    %eax,%ebx
f0101149:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101150:	e8 ed 1b 00 00       	call   f0102d42 <mc146818_read>
f0101155:	c1 e0 08             	shl    $0x8,%eax
f0101158:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010115a:	89 d8                	mov    %ebx,%eax
f010115c:	c1 e0 0a             	shl    $0xa,%eax
f010115f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101165:	85 c0                	test   %eax,%eax
f0101167:	0f 48 c2             	cmovs  %edx,%eax
f010116a:	c1 f8 0c             	sar    $0xc,%eax
f010116d:	a3 40 75 11 f0       	mov    %eax,0xf0117540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101172:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101179:	e8 c4 1b 00 00       	call   f0102d42 <mc146818_read>
f010117e:	89 c3                	mov    %eax,%ebx
f0101180:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101187:	e8 b6 1b 00 00       	call   f0102d42 <mc146818_read>
f010118c:	c1 e0 08             	shl    $0x8,%eax
f010118f:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101191:	89 d8                	mov    %ebx,%eax
f0101193:	c1 e0 0a             	shl    $0xa,%eax
f0101196:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010119c:	85 c0                	test   %eax,%eax
f010119e:	0f 48 c2             	cmovs  %edx,%eax
f01011a1:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01011a4:	85 c0                	test   %eax,%eax
f01011a6:	74 0e                	je     f01011b6 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01011a8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01011ae:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
f01011b4:	eb 0c                	jmp    f01011c2 <mem_init+0x90>
	else
		npages = npages_basemem;
f01011b6:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f01011bc:	89 15 64 79 11 f0    	mov    %edx,0xf0117964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01011c2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c5:	c1 e8 0a             	shr    $0xa,%eax
f01011c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01011cc:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f01011d1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011d4:	c1 e8 0a             	shr    $0xa,%eax
f01011d7:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01011db:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01011e0:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011e3:	c1 e8 0a             	shr    $0xa,%eax
f01011e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ea:	c7 04 24 b8 43 10 f0 	movl   $0xf01043b8,(%esp)
f01011f1:	e8 bc 1b 00 00       	call   f0102db2 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011f6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011fb:	e8 33 f7 ff ff       	call   f0100933 <boot_alloc>
f0101200:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f0101205:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010120c:	00 
f010120d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101214:	00 
f0101215:	89 04 24             	mov    %eax,(%esp)
f0101218:	e8 ea 26 00 00       	call   f0103907 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010121d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101222:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101227:	77 20                	ja     f0101249 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101229:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010122d:	c7 44 24 08 f4 43 10 	movl   $0xf01043f4,0x8(%esp)
f0101234:	f0 
f0101235:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f010123c:	00 
f010123d:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101244:	e8 4b ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101249:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010124f:	83 ca 05             	or     $0x5,%edx
f0101252:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0101258:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010125d:	c1 e0 03             	shl    $0x3,%eax
f0101260:	e8 ce f6 ff ff       	call   f0100933 <boot_alloc>
f0101265:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f010126a:	8b 3d 64 79 11 f0    	mov    0xf0117964,%edi
f0101270:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101277:	89 54 24 08          	mov    %edx,0x8(%esp)
f010127b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101282:	00 
f0101283:	89 04 24             	mov    %eax,(%esp)
f0101286:	e8 7c 26 00 00       	call   f0103907 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010128b:	e8 e3 fa ff ff       	call   f0100d73 <page_init>

	check_page_free_list(1);
f0101290:	b8 01 00 00 00       	mov    $0x1,%eax
f0101295:	e8 90 f7 ff ff       	call   f0100a2a <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010129a:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f01012a1:	75 1c                	jne    f01012bf <mem_init+0x18d>
		panic("'pages' is a null pointer!");
f01012a3:	c7 44 24 08 ba 4a 10 	movl   $0xf0104aba,0x8(%esp)
f01012aa:	f0 
f01012ab:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f01012b2:	00 
f01012b3:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01012ba:	e8 d5 ed ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012bf:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01012c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012c9:	eb 05                	jmp    f01012d0 <mem_init+0x19e>
		++nfree;
f01012cb:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012ce:	8b 00                	mov    (%eax),%eax
f01012d0:	85 c0                	test   %eax,%eax
f01012d2:	75 f7                	jne    f01012cb <mem_init+0x199>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012db:	e8 7c fb ff ff       	call   f0100e5c <page_alloc>
f01012e0:	89 c7                	mov    %eax,%edi
f01012e2:	85 c0                	test   %eax,%eax
f01012e4:	75 24                	jne    f010130a <mem_init+0x1d8>
f01012e6:	c7 44 24 0c d5 4a 10 	movl   $0xf0104ad5,0xc(%esp)
f01012ed:	f0 
f01012ee:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01012f5:	f0 
f01012f6:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f01012fd:	00 
f01012fe:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101305:	e8 8a ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010130a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101311:	e8 46 fb ff ff       	call   f0100e5c <page_alloc>
f0101316:	89 c6                	mov    %eax,%esi
f0101318:	85 c0                	test   %eax,%eax
f010131a:	75 24                	jne    f0101340 <mem_init+0x20e>
f010131c:	c7 44 24 0c eb 4a 10 	movl   $0xf0104aeb,0xc(%esp)
f0101323:	f0 
f0101324:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010132b:	f0 
f010132c:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101333:	00 
f0101334:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010133b:	e8 54 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101347:	e8 10 fb ff ff       	call   f0100e5c <page_alloc>
f010134c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010134f:	85 c0                	test   %eax,%eax
f0101351:	75 24                	jne    f0101377 <mem_init+0x245>
f0101353:	c7 44 24 0c 01 4b 10 	movl   $0xf0104b01,0xc(%esp)
f010135a:	f0 
f010135b:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101362:	f0 
f0101363:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f010136a:	00 
f010136b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101372:	e8 1d ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101377:	39 f7                	cmp    %esi,%edi
f0101379:	75 24                	jne    f010139f <mem_init+0x26d>
f010137b:	c7 44 24 0c 17 4b 10 	movl   $0xf0104b17,0xc(%esp)
f0101382:	f0 
f0101383:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010138a:	f0 
f010138b:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101392:	00 
f0101393:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010139a:	e8 f5 ec ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010139f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013a2:	39 c6                	cmp    %eax,%esi
f01013a4:	74 04                	je     f01013aa <mem_init+0x278>
f01013a6:	39 c7                	cmp    %eax,%edi
f01013a8:	75 24                	jne    f01013ce <mem_init+0x29c>
f01013aa:	c7 44 24 0c 18 44 10 	movl   $0xf0104418,0xc(%esp)
f01013b1:	f0 
f01013b2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01013c9:	e8 c6 ec ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ce:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013d4:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01013d9:	c1 e0 0c             	shl    $0xc,%eax
f01013dc:	89 f9                	mov    %edi,%ecx
f01013de:	29 d1                	sub    %edx,%ecx
f01013e0:	c1 f9 03             	sar    $0x3,%ecx
f01013e3:	c1 e1 0c             	shl    $0xc,%ecx
f01013e6:	39 c1                	cmp    %eax,%ecx
f01013e8:	72 24                	jb     f010140e <mem_init+0x2dc>
f01013ea:	c7 44 24 0c 29 4b 10 	movl   $0xf0104b29,0xc(%esp)
f01013f1:	f0 
f01013f2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01013f9:	f0 
f01013fa:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f0101401:	00 
f0101402:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101409:	e8 86 ec ff ff       	call   f0100094 <_panic>
f010140e:	89 f1                	mov    %esi,%ecx
f0101410:	29 d1                	sub    %edx,%ecx
f0101412:	c1 f9 03             	sar    $0x3,%ecx
f0101415:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101418:	39 c8                	cmp    %ecx,%eax
f010141a:	77 24                	ja     f0101440 <mem_init+0x30e>
f010141c:	c7 44 24 0c 46 4b 10 	movl   $0xf0104b46,0xc(%esp)
f0101423:	f0 
f0101424:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010142b:	f0 
f010142c:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f0101433:	00 
f0101434:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010143b:	e8 54 ec ff ff       	call   f0100094 <_panic>
f0101440:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101443:	29 d1                	sub    %edx,%ecx
f0101445:	89 ca                	mov    %ecx,%edx
f0101447:	c1 fa 03             	sar    $0x3,%edx
f010144a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010144d:	39 d0                	cmp    %edx,%eax
f010144f:	77 24                	ja     f0101475 <mem_init+0x343>
f0101451:	c7 44 24 0c 63 4b 10 	movl   $0xf0104b63,0xc(%esp)
f0101458:	f0 
f0101459:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101460:	f0 
f0101461:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0101468:	00 
f0101469:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101470:	e8 1f ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101475:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010147a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010147d:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101484:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101487:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010148e:	e8 c9 f9 ff ff       	call   f0100e5c <page_alloc>
f0101493:	85 c0                	test   %eax,%eax
f0101495:	74 24                	je     f01014bb <mem_init+0x389>
f0101497:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f010149e:	f0 
f010149f:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01014a6:	f0 
f01014a7:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f01014ae:	00 
f01014af:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01014b6:	e8 d9 eb ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014bb:	89 3c 24             	mov    %edi,(%esp)
f01014be:	e8 24 fa ff ff       	call   f0100ee7 <page_free>
	page_free(pp1);
f01014c3:	89 34 24             	mov    %esi,(%esp)
f01014c6:	e8 1c fa ff ff       	call   f0100ee7 <page_free>
	page_free(pp2);
f01014cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014ce:	89 04 24             	mov    %eax,(%esp)
f01014d1:	e8 11 fa ff ff       	call   f0100ee7 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014dd:	e8 7a f9 ff ff       	call   f0100e5c <page_alloc>
f01014e2:	89 c6                	mov    %eax,%esi
f01014e4:	85 c0                	test   %eax,%eax
f01014e6:	75 24                	jne    f010150c <mem_init+0x3da>
f01014e8:	c7 44 24 0c d5 4a 10 	movl   $0xf0104ad5,0xc(%esp)
f01014ef:	f0 
f01014f0:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01014f7:	f0 
f01014f8:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f01014ff:	00 
f0101500:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101507:	e8 88 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010150c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101513:	e8 44 f9 ff ff       	call   f0100e5c <page_alloc>
f0101518:	89 c7                	mov    %eax,%edi
f010151a:	85 c0                	test   %eax,%eax
f010151c:	75 24                	jne    f0101542 <mem_init+0x410>
f010151e:	c7 44 24 0c eb 4a 10 	movl   $0xf0104aeb,0xc(%esp)
f0101525:	f0 
f0101526:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010152d:	f0 
f010152e:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0101535:	00 
f0101536:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010153d:	e8 52 eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101542:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101549:	e8 0e f9 ff ff       	call   f0100e5c <page_alloc>
f010154e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101551:	85 c0                	test   %eax,%eax
f0101553:	75 24                	jne    f0101579 <mem_init+0x447>
f0101555:	c7 44 24 0c 01 4b 10 	movl   $0xf0104b01,0xc(%esp)
f010155c:	f0 
f010155d:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101564:	f0 
f0101565:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f010156c:	00 
f010156d:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101574:	e8 1b eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101579:	39 fe                	cmp    %edi,%esi
f010157b:	75 24                	jne    f01015a1 <mem_init+0x46f>
f010157d:	c7 44 24 0c 17 4b 10 	movl   $0xf0104b17,0xc(%esp)
f0101584:	f0 
f0101585:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010158c:	f0 
f010158d:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101594:	00 
f0101595:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010159c:	e8 f3 ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015a4:	39 c7                	cmp    %eax,%edi
f01015a6:	74 04                	je     f01015ac <mem_init+0x47a>
f01015a8:	39 c6                	cmp    %eax,%esi
f01015aa:	75 24                	jne    f01015d0 <mem_init+0x49e>
f01015ac:	c7 44 24 0c 18 44 10 	movl   $0xf0104418,0xc(%esp)
f01015b3:	f0 
f01015b4:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01015bb:	f0 
f01015bc:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f01015c3:	00 
f01015c4:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01015cb:	e8 c4 ea ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01015d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d7:	e8 80 f8 ff ff       	call   f0100e5c <page_alloc>
f01015dc:	85 c0                	test   %eax,%eax
f01015de:	74 24                	je     f0101604 <mem_init+0x4d2>
f01015e0:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f01015e7:	f0 
f01015e8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01015ef:	f0 
f01015f0:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01015f7:	00 
f01015f8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01015ff:	e8 90 ea ff ff       	call   f0100094 <_panic>
f0101604:	89 f0                	mov    %esi,%eax
f0101606:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010160c:	c1 f8 03             	sar    $0x3,%eax
f010160f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101612:	89 c2                	mov    %eax,%edx
f0101614:	c1 ea 0c             	shr    $0xc,%edx
f0101617:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f010161d:	72 20                	jb     f010163f <mem_init+0x50d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010161f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101623:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f010162a:	f0 
f010162b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101632:	00 
f0101633:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f010163a:	e8 55 ea ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010163f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101646:	00 
f0101647:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010164e:	00 
	return (void *)(pa + KERNBASE);
f010164f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101654:	89 04 24             	mov    %eax,(%esp)
f0101657:	e8 ab 22 00 00       	call   f0103907 <memset>
	page_free(pp0);
f010165c:	89 34 24             	mov    %esi,(%esp)
f010165f:	e8 83 f8 ff ff       	call   f0100ee7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101664:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010166b:	e8 ec f7 ff ff       	call   f0100e5c <page_alloc>
f0101670:	85 c0                	test   %eax,%eax
f0101672:	75 24                	jne    f0101698 <mem_init+0x566>
f0101674:	c7 44 24 0c 8f 4b 10 	movl   $0xf0104b8f,0xc(%esp)
f010167b:	f0 
f010167c:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101683:	f0 
f0101684:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f010168b:	00 
f010168c:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101693:	e8 fc e9 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101698:	39 c6                	cmp    %eax,%esi
f010169a:	74 24                	je     f01016c0 <mem_init+0x58e>
f010169c:	c7 44 24 0c ad 4b 10 	movl   $0xf0104bad,0xc(%esp)
f01016a3:	f0 
f01016a4:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01016ab:	f0 
f01016ac:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01016b3:	00 
f01016b4:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01016bb:	e8 d4 e9 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016c0:	89 f0                	mov    %esi,%eax
f01016c2:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01016c8:	c1 f8 03             	sar    $0x3,%eax
f01016cb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016ce:	89 c2                	mov    %eax,%edx
f01016d0:	c1 ea 0c             	shr    $0xc,%edx
f01016d3:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01016d9:	72 20                	jb     f01016fb <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016df:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f01016e6:	f0 
f01016e7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016ee:	00 
f01016ef:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f01016f6:	e8 99 e9 ff ff       	call   f0100094 <_panic>
f01016fb:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101701:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101707:	80 38 00             	cmpb   $0x0,(%eax)
f010170a:	74 24                	je     f0101730 <mem_init+0x5fe>
f010170c:	c7 44 24 0c bd 4b 10 	movl   $0xf0104bbd,0xc(%esp)
f0101713:	f0 
f0101714:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010171b:	f0 
f010171c:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f0101723:	00 
f0101724:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010172b:	e8 64 e9 ff ff       	call   f0100094 <_panic>
f0101730:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101733:	39 d0                	cmp    %edx,%eax
f0101735:	75 d0                	jne    f0101707 <mem_init+0x5d5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101737:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010173a:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f010173f:	89 34 24             	mov    %esi,(%esp)
f0101742:	e8 a0 f7 ff ff       	call   f0100ee7 <page_free>
	page_free(pp1);
f0101747:	89 3c 24             	mov    %edi,(%esp)
f010174a:	e8 98 f7 ff ff       	call   f0100ee7 <page_free>
	page_free(pp2);
f010174f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101752:	89 04 24             	mov    %eax,(%esp)
f0101755:	e8 8d f7 ff ff       	call   f0100ee7 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010175a:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010175f:	eb 05                	jmp    f0101766 <mem_init+0x634>
		--nfree;
f0101761:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101764:	8b 00                	mov    (%eax),%eax
f0101766:	85 c0                	test   %eax,%eax
f0101768:	75 f7                	jne    f0101761 <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f010176a:	85 db                	test   %ebx,%ebx
f010176c:	74 24                	je     f0101792 <mem_init+0x660>
f010176e:	c7 44 24 0c c7 4b 10 	movl   $0xf0104bc7,0xc(%esp)
f0101775:	f0 
f0101776:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010177d:	f0 
f010177e:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101785:	00 
f0101786:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010178d:	e8 02 e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101792:	c7 04 24 38 44 10 f0 	movl   $0xf0104438,(%esp)
f0101799:	e8 14 16 00 00       	call   f0102db2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010179e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a5:	e8 b2 f6 ff ff       	call   f0100e5c <page_alloc>
f01017aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	75 24                	jne    f01017d5 <mem_init+0x6a3>
f01017b1:	c7 44 24 0c d5 4a 10 	movl   $0xf0104ad5,0xc(%esp)
f01017b8:	f0 
f01017b9:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01017c0:	f0 
f01017c1:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01017c8:	00 
f01017c9:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01017d0:	e8 bf e8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017dc:	e8 7b f6 ff ff       	call   f0100e5c <page_alloc>
f01017e1:	89 c3                	mov    %eax,%ebx
f01017e3:	85 c0                	test   %eax,%eax
f01017e5:	75 24                	jne    f010180b <mem_init+0x6d9>
f01017e7:	c7 44 24 0c eb 4a 10 	movl   $0xf0104aeb,0xc(%esp)
f01017ee:	f0 
f01017ef:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01017f6:	f0 
f01017f7:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01017fe:	00 
f01017ff:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101806:	e8 89 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010180b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101812:	e8 45 f6 ff ff       	call   f0100e5c <page_alloc>
f0101817:	89 c6                	mov    %eax,%esi
f0101819:	85 c0                	test   %eax,%eax
f010181b:	75 24                	jne    f0101841 <mem_init+0x70f>
f010181d:	c7 44 24 0c 01 4b 10 	movl   $0xf0104b01,0xc(%esp)
f0101824:	f0 
f0101825:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010182c:	f0 
f010182d:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101834:	00 
f0101835:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010183c:	e8 53 e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101841:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101844:	75 24                	jne    f010186a <mem_init+0x738>
f0101846:	c7 44 24 0c 17 4b 10 	movl   $0xf0104b17,0xc(%esp)
f010184d:	f0 
f010184e:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101855:	f0 
f0101856:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010185d:	00 
f010185e:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101865:	e8 2a e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010186a:	39 c3                	cmp    %eax,%ebx
f010186c:	74 05                	je     f0101873 <mem_init+0x741>
f010186e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101871:	75 24                	jne    f0101897 <mem_init+0x765>
f0101873:	c7 44 24 0c 18 44 10 	movl   $0xf0104418,0xc(%esp)
f010187a:	f0 
f010187b:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101882:	f0 
f0101883:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f010188a:	00 
f010188b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101892:	e8 fd e7 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101897:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010189c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010189f:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01018a6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018b0:	e8 a7 f5 ff ff       	call   f0100e5c <page_alloc>
f01018b5:	85 c0                	test   %eax,%eax
f01018b7:	74 24                	je     f01018dd <mem_init+0x7ab>
f01018b9:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f01018c0:	f0 
f01018c1:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01018c8:	f0 
f01018c9:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01018d0:	00 
f01018d1:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01018d8:	e8 b7 e7 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018eb:	00 
f01018ec:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018f1:	89 04 24             	mov    %eax,(%esp)
f01018f4:	e8 f1 f6 ff ff       	call   f0100fea <page_lookup>
f01018f9:	85 c0                	test   %eax,%eax
f01018fb:	74 24                	je     f0101921 <mem_init+0x7ef>
f01018fd:	c7 44 24 0c 58 44 10 	movl   $0xf0104458,0xc(%esp)
f0101904:	f0 
f0101905:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010190c:	f0 
f010190d:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101914:	00 
f0101915:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010191c:	e8 73 e7 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101921:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101928:	00 
f0101929:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101930:	00 
f0101931:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101935:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010193a:	89 04 24             	mov    %eax,(%esp)
f010193d:	e8 5a f7 ff ff       	call   f010109c <page_insert>
f0101942:	85 c0                	test   %eax,%eax
f0101944:	78 24                	js     f010196a <mem_init+0x838>
f0101946:	c7 44 24 0c 90 44 10 	movl   $0xf0104490,0xc(%esp)
f010194d:	f0 
f010194e:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101955:	f0 
f0101956:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010195d:	00 
f010195e:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101965:	e8 2a e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010196a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010196d:	89 04 24             	mov    %eax,(%esp)
f0101970:	e8 72 f5 ff ff       	call   f0100ee7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101975:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010197c:	00 
f010197d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101984:	00 
f0101985:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101989:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010198e:	89 04 24             	mov    %eax,(%esp)
f0101991:	e8 06 f7 ff ff       	call   f010109c <page_insert>
f0101996:	85 c0                	test   %eax,%eax
f0101998:	74 24                	je     f01019be <mem_init+0x88c>
f010199a:	c7 44 24 0c c0 44 10 	movl   $0xf01044c0,0xc(%esp)
f01019a1:	f0 
f01019a2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01019a9:	f0 
f01019aa:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01019b1:	00 
f01019b2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01019b9:	e8 d6 e6 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019be:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019c4:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01019c9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019cc:	8b 17                	mov    (%edi),%edx
f01019ce:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01019d7:	29 c1                	sub    %eax,%ecx
f01019d9:	89 c8                	mov    %ecx,%eax
f01019db:	c1 f8 03             	sar    $0x3,%eax
f01019de:	c1 e0 0c             	shl    $0xc,%eax
f01019e1:	39 c2                	cmp    %eax,%edx
f01019e3:	74 24                	je     f0101a09 <mem_init+0x8d7>
f01019e5:	c7 44 24 0c f0 44 10 	movl   $0xf01044f0,0xc(%esp)
f01019ec:	f0 
f01019ed:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01019fc:	00 
f01019fd:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101a04:	e8 8b e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a09:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a0e:	89 f8                	mov    %edi,%eax
f0101a10:	e8 a6 ef ff ff       	call   f01009bb <check_va2pa>
f0101a15:	89 da                	mov    %ebx,%edx
f0101a17:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a1a:	c1 fa 03             	sar    $0x3,%edx
f0101a1d:	c1 e2 0c             	shl    $0xc,%edx
f0101a20:	39 d0                	cmp    %edx,%eax
f0101a22:	74 24                	je     f0101a48 <mem_init+0x916>
f0101a24:	c7 44 24 0c 18 45 10 	movl   $0xf0104518,0xc(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101a33:	f0 
f0101a34:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101a3b:	00 
f0101a3c:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101a43:	e8 4c e6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101a48:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a4d:	74 24                	je     f0101a73 <mem_init+0x941>
f0101a4f:	c7 44 24 0c d2 4b 10 	movl   $0xf0104bd2,0xc(%esp)
f0101a56:	f0 
f0101a57:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101a5e:	f0 
f0101a5f:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101a66:	00 
f0101a67:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101a6e:	e8 21 e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101a73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a76:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a7b:	74 24                	je     f0101aa1 <mem_init+0x96f>
f0101a7d:	c7 44 24 0c e3 4b 10 	movl   $0xf0104be3,0xc(%esp)
f0101a84:	f0 
f0101a85:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101a8c:	f0 
f0101a8d:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101a94:	00 
f0101a95:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101a9c:	e8 f3 e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aa1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101aa8:	00 
f0101aa9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ab0:	00 
f0101ab1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ab5:	89 3c 24             	mov    %edi,(%esp)
f0101ab8:	e8 df f5 ff ff       	call   f010109c <page_insert>
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	74 24                	je     f0101ae5 <mem_init+0x9b3>
f0101ac1:	c7 44 24 0c 48 45 10 	movl   $0xf0104548,0xc(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101ad0:	f0 
f0101ad1:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101ad8:	00 
f0101ad9:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101ae0:	e8 af e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aea:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101aef:	e8 c7 ee ff ff       	call   f01009bb <check_va2pa>
f0101af4:	89 f2                	mov    %esi,%edx
f0101af6:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101afc:	c1 fa 03             	sar    $0x3,%edx
f0101aff:	c1 e2 0c             	shl    $0xc,%edx
f0101b02:	39 d0                	cmp    %edx,%eax
f0101b04:	74 24                	je     f0101b2a <mem_init+0x9f8>
f0101b06:	c7 44 24 0c 84 45 10 	movl   $0xf0104584,0xc(%esp)
f0101b0d:	f0 
f0101b0e:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101b15:	f0 
f0101b16:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101b1d:	00 
f0101b1e:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101b25:	e8 6a e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101b2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b2f:	74 24                	je     f0101b55 <mem_init+0xa23>
f0101b31:	c7 44 24 0c f4 4b 10 	movl   $0xf0104bf4,0xc(%esp)
f0101b38:	f0 
f0101b39:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101b48:	00 
f0101b49:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101b50:	e8 3f e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b5c:	e8 fb f2 ff ff       	call   f0100e5c <page_alloc>
f0101b61:	85 c0                	test   %eax,%eax
f0101b63:	74 24                	je     f0101b89 <mem_init+0xa57>
f0101b65:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f0101b6c:	f0 
f0101b6d:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101b74:	f0 
f0101b75:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101b7c:	00 
f0101b7d:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101b84:	e8 0b e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b89:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b90:	00 
f0101b91:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b98:	00 
f0101b99:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b9d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ba2:	89 04 24             	mov    %eax,(%esp)
f0101ba5:	e8 f2 f4 ff ff       	call   f010109c <page_insert>
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	74 24                	je     f0101bd2 <mem_init+0xaa0>
f0101bae:	c7 44 24 0c 48 45 10 	movl   $0xf0104548,0xc(%esp)
f0101bb5:	f0 
f0101bb6:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101bbd:	f0 
f0101bbe:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0101bc5:	00 
f0101bc6:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101bcd:	e8 c2 e4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101bdc:	e8 da ed ff ff       	call   f01009bb <check_va2pa>
f0101be1:	89 f2                	mov    %esi,%edx
f0101be3:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101be9:	c1 fa 03             	sar    $0x3,%edx
f0101bec:	c1 e2 0c             	shl    $0xc,%edx
f0101bef:	39 d0                	cmp    %edx,%eax
f0101bf1:	74 24                	je     f0101c17 <mem_init+0xae5>
f0101bf3:	c7 44 24 0c 84 45 10 	movl   $0xf0104584,0xc(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101c02:	f0 
f0101c03:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101c0a:	00 
f0101c0b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101c12:	e8 7d e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c17:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c1c:	74 24                	je     f0101c42 <mem_init+0xb10>
f0101c1e:	c7 44 24 0c f4 4b 10 	movl   $0xf0104bf4,0xc(%esp)
f0101c25:	f0 
f0101c26:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101c2d:	f0 
f0101c2e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101c35:	00 
f0101c36:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101c3d:	e8 52 e4 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c49:	e8 0e f2 ff ff       	call   f0100e5c <page_alloc>
f0101c4e:	85 c0                	test   %eax,%eax
f0101c50:	74 24                	je     f0101c76 <mem_init+0xb44>
f0101c52:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f0101c59:	f0 
f0101c5a:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101c69:	00 
f0101c6a:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101c71:	e8 1e e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c76:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101c7c:	8b 02                	mov    (%edx),%eax
f0101c7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c83:	89 c1                	mov    %eax,%ecx
f0101c85:	c1 e9 0c             	shr    $0xc,%ecx
f0101c88:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101c8e:	72 20                	jb     f0101cb0 <mem_init+0xb7e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c94:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0101c9b:	f0 
f0101c9c:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101ca3:	00 
f0101ca4:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101cab:	e8 e4 e3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101cb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cbf:	00 
f0101cc0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101cc7:	00 
f0101cc8:	89 14 24             	mov    %edx,(%esp)
f0101ccb:	e8 7a f2 ff ff       	call   f0100f4a <pgdir_walk>
f0101cd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101cd3:	8d 57 04             	lea    0x4(%edi),%edx
f0101cd6:	39 d0                	cmp    %edx,%eax
f0101cd8:	74 24                	je     f0101cfe <mem_init+0xbcc>
f0101cda:	c7 44 24 0c b4 45 10 	movl   $0xf01045b4,0xc(%esp)
f0101ce1:	f0 
f0101ce2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101ce9:	f0 
f0101cea:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101cf1:	00 
f0101cf2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101cf9:	e8 96 e3 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cfe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d05:	00 
f0101d06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d0d:	00 
f0101d0e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d12:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101d17:	89 04 24             	mov    %eax,(%esp)
f0101d1a:	e8 7d f3 ff ff       	call   f010109c <page_insert>
f0101d1f:	85 c0                	test   %eax,%eax
f0101d21:	74 24                	je     f0101d47 <mem_init+0xc15>
f0101d23:	c7 44 24 0c f4 45 10 	movl   $0xf01045f4,0xc(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101d32:	f0 
f0101d33:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d3a:	00 
f0101d3b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101d42:	e8 4d e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d47:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101d4d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d52:	89 f8                	mov    %edi,%eax
f0101d54:	e8 62 ec ff ff       	call   f01009bb <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d59:	89 f2                	mov    %esi,%edx
f0101d5b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101d61:	c1 fa 03             	sar    $0x3,%edx
f0101d64:	c1 e2 0c             	shl    $0xc,%edx
f0101d67:	39 d0                	cmp    %edx,%eax
f0101d69:	74 24                	je     f0101d8f <mem_init+0xc5d>
f0101d6b:	c7 44 24 0c 84 45 10 	movl   $0xf0104584,0xc(%esp)
f0101d72:	f0 
f0101d73:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101d7a:	f0 
f0101d7b:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101d82:	00 
f0101d83:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101d8a:	e8 05 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d8f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d94:	74 24                	je     f0101dba <mem_init+0xc88>
f0101d96:	c7 44 24 0c f4 4b 10 	movl   $0xf0104bf4,0xc(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101dad:	00 
f0101dae:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101db5:	e8 da e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dc1:	00 
f0101dc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101dc9:	00 
f0101dca:	89 3c 24             	mov    %edi,(%esp)
f0101dcd:	e8 78 f1 ff ff       	call   f0100f4a <pgdir_walk>
f0101dd2:	f6 00 04             	testb  $0x4,(%eax)
f0101dd5:	75 24                	jne    f0101dfb <mem_init+0xcc9>
f0101dd7:	c7 44 24 0c 34 46 10 	movl   $0xf0104634,0xc(%esp)
f0101dde:	f0 
f0101ddf:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101de6:	f0 
f0101de7:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101dee:	00 
f0101def:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101df6:	e8 99 e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dfb:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e00:	f6 00 04             	testb  $0x4,(%eax)
f0101e03:	75 24                	jne    f0101e29 <mem_init+0xcf7>
f0101e05:	c7 44 24 0c 05 4c 10 	movl   $0xf0104c05,0xc(%esp)
f0101e0c:	f0 
f0101e0d:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101e14:	f0 
f0101e15:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101e1c:	00 
f0101e1d:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101e24:	e8 6b e2 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e29:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e30:	00 
f0101e31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e38:	00 
f0101e39:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e3d:	89 04 24             	mov    %eax,(%esp)
f0101e40:	e8 57 f2 ff ff       	call   f010109c <page_insert>
f0101e45:	85 c0                	test   %eax,%eax
f0101e47:	74 24                	je     f0101e6d <mem_init+0xd3b>
f0101e49:	c7 44 24 0c 48 45 10 	movl   $0xf0104548,0xc(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101e58:	f0 
f0101e59:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e60:	00 
f0101e61:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101e68:	e8 27 e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e74:	00 
f0101e75:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e7c:	00 
f0101e7d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e82:	89 04 24             	mov    %eax,(%esp)
f0101e85:	e8 c0 f0 ff ff       	call   f0100f4a <pgdir_walk>
f0101e8a:	f6 00 02             	testb  $0x2,(%eax)
f0101e8d:	75 24                	jne    f0101eb3 <mem_init+0xd81>
f0101e8f:	c7 44 24 0c 68 46 10 	movl   $0xf0104668,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101eae:	e8 e1 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101eb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101eba:	00 
f0101ebb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ec2:	00 
f0101ec3:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ec8:	89 04 24             	mov    %eax,(%esp)
f0101ecb:	e8 7a f0 ff ff       	call   f0100f4a <pgdir_walk>
f0101ed0:	f6 00 04             	testb  $0x4,(%eax)
f0101ed3:	74 24                	je     f0101ef9 <mem_init+0xdc7>
f0101ed5:	c7 44 24 0c 9c 46 10 	movl   $0xf010469c,0xc(%esp)
f0101edc:	f0 
f0101edd:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101ee4:	f0 
f0101ee5:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101eec:	00 
f0101eed:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101ef4:	e8 9b e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ef9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f00:	00 
f0101f01:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f08:	00 
f0101f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f10:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f15:	89 04 24             	mov    %eax,(%esp)
f0101f18:	e8 7f f1 ff ff       	call   f010109c <page_insert>
f0101f1d:	85 c0                	test   %eax,%eax
f0101f1f:	78 24                	js     f0101f45 <mem_init+0xe13>
f0101f21:	c7 44 24 0c d4 46 10 	movl   $0xf01046d4,0xc(%esp)
f0101f28:	f0 
f0101f29:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101f30:	f0 
f0101f31:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101f38:	00 
f0101f39:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101f40:	e8 4f e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f45:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f4c:	00 
f0101f4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f54:	00 
f0101f55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f59:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f5e:	89 04 24             	mov    %eax,(%esp)
f0101f61:	e8 36 f1 ff ff       	call   f010109c <page_insert>
f0101f66:	85 c0                	test   %eax,%eax
f0101f68:	74 24                	je     f0101f8e <mem_init+0xe5c>
f0101f6a:	c7 44 24 0c 0c 47 10 	movl   $0xf010470c,0xc(%esp)
f0101f71:	f0 
f0101f72:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101f79:	f0 
f0101f7a:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101f81:	00 
f0101f82:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101f89:	e8 06 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f95:	00 
f0101f96:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f9d:	00 
f0101f9e:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101fa3:	89 04 24             	mov    %eax,(%esp)
f0101fa6:	e8 9f ef ff ff       	call   f0100f4a <pgdir_walk>
f0101fab:	f6 00 04             	testb  $0x4,(%eax)
f0101fae:	74 24                	je     f0101fd4 <mem_init+0xea2>
f0101fb0:	c7 44 24 0c 9c 46 10 	movl   $0xf010469c,0xc(%esp)
f0101fb7:	f0 
f0101fb8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101fc7:	00 
f0101fc8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0101fcf:	e8 c0 e0 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fd4:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101fda:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdf:	89 f8                	mov    %edi,%eax
f0101fe1:	e8 d5 e9 ff ff       	call   f01009bb <check_va2pa>
f0101fe6:	89 c1                	mov    %eax,%ecx
f0101fe8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101feb:	89 d8                	mov    %ebx,%eax
f0101fed:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101ff3:	c1 f8 03             	sar    $0x3,%eax
f0101ff6:	c1 e0 0c             	shl    $0xc,%eax
f0101ff9:	39 c1                	cmp    %eax,%ecx
f0101ffb:	74 24                	je     f0102021 <mem_init+0xeef>
f0101ffd:	c7 44 24 0c 48 47 10 	movl   $0xf0104748,0xc(%esp)
f0102004:	f0 
f0102005:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010200c:	f0 
f010200d:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102014:	00 
f0102015:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010201c:	e8 73 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102021:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102026:	89 f8                	mov    %edi,%eax
f0102028:	e8 8e e9 ff ff       	call   f01009bb <check_va2pa>
f010202d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102030:	74 24                	je     f0102056 <mem_init+0xf24>
f0102032:	c7 44 24 0c 74 47 10 	movl   $0xf0104774,0xc(%esp)
f0102039:	f0 
f010203a:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102041:	f0 
f0102042:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102049:	00 
f010204a:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102051:	e8 3e e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102056:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010205b:	74 24                	je     f0102081 <mem_init+0xf4f>
f010205d:	c7 44 24 0c 1b 4c 10 	movl   $0xf0104c1b,0xc(%esp)
f0102064:	f0 
f0102065:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010206c:	f0 
f010206d:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102074:	00 
f0102075:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010207c:	e8 13 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102081:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102086:	74 24                	je     f01020ac <mem_init+0xf7a>
f0102088:	c7 44 24 0c 2c 4c 10 	movl   $0xf0104c2c,0xc(%esp)
f010208f:	f0 
f0102090:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102097:	f0 
f0102098:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f010209f:	00 
f01020a0:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01020a7:	e8 e8 df ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020b3:	e8 a4 ed ff ff       	call   f0100e5c <page_alloc>
f01020b8:	85 c0                	test   %eax,%eax
f01020ba:	74 04                	je     f01020c0 <mem_init+0xf8e>
f01020bc:	39 c6                	cmp    %eax,%esi
f01020be:	74 24                	je     f01020e4 <mem_init+0xfb2>
f01020c0:	c7 44 24 0c a4 47 10 	movl   $0xf01047a4,0xc(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f01020d7:	00 
f01020d8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01020df:	e8 b0 df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020eb:	00 
f01020ec:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020f1:	89 04 24             	mov    %eax,(%esp)
f01020f4:	e8 5e ef ff ff       	call   f0101057 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020f9:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f01020ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0102104:	89 f8                	mov    %edi,%eax
f0102106:	e8 b0 e8 ff ff       	call   f01009bb <check_va2pa>
f010210b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010210e:	74 24                	je     f0102134 <mem_init+0x1002>
f0102110:	c7 44 24 0c c8 47 10 	movl   $0xf01047c8,0xc(%esp)
f0102117:	f0 
f0102118:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010211f:	f0 
f0102120:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102127:	00 
f0102128:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010212f:	e8 60 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102134:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102139:	89 f8                	mov    %edi,%eax
f010213b:	e8 7b e8 ff ff       	call   f01009bb <check_va2pa>
f0102140:	89 da                	mov    %ebx,%edx
f0102142:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102148:	c1 fa 03             	sar    $0x3,%edx
f010214b:	c1 e2 0c             	shl    $0xc,%edx
f010214e:	39 d0                	cmp    %edx,%eax
f0102150:	74 24                	je     f0102176 <mem_init+0x1044>
f0102152:	c7 44 24 0c 74 47 10 	movl   $0xf0104774,0xc(%esp)
f0102159:	f0 
f010215a:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102161:	f0 
f0102162:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102169:	00 
f010216a:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102171:	e8 1e df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102176:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010217b:	74 24                	je     f01021a1 <mem_init+0x106f>
f010217d:	c7 44 24 0c d2 4b 10 	movl   $0xf0104bd2,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010219c:	e8 f3 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01021a1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a6:	74 24                	je     f01021cc <mem_init+0x109a>
f01021a8:	c7 44 24 0c 2c 4c 10 	movl   $0xf0104c2c,0xc(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01021b7:	f0 
f01021b8:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01021bf:	00 
f01021c0:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01021c7:	e8 c8 de ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021d3:	00 
f01021d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021db:	00 
f01021dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021e0:	89 3c 24             	mov    %edi,(%esp)
f01021e3:	e8 b4 ee ff ff       	call   f010109c <page_insert>
f01021e8:	85 c0                	test   %eax,%eax
f01021ea:	74 24                	je     f0102210 <mem_init+0x10de>
f01021ec:	c7 44 24 0c ec 47 10 	movl   $0xf01047ec,0xc(%esp)
f01021f3:	f0 
f01021f4:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01021fb:	f0 
f01021fc:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102203:	00 
f0102204:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010220b:	e8 84 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102210:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102215:	75 24                	jne    f010223b <mem_init+0x1109>
f0102217:	c7 44 24 0c 3d 4c 10 	movl   $0xf0104c3d,0xc(%esp)
f010221e:	f0 
f010221f:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102226:	f0 
f0102227:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f010222e:	00 
f010222f:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102236:	e8 59 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010223b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010223e:	74 24                	je     f0102264 <mem_init+0x1132>
f0102240:	c7 44 24 0c 49 4c 10 	movl   $0xf0104c49,0xc(%esp)
f0102247:	f0 
f0102248:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010224f:	f0 
f0102250:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102257:	00 
f0102258:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010225f:	e8 30 de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102264:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010226b:	00 
f010226c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102271:	89 04 24             	mov    %eax,(%esp)
f0102274:	e8 de ed ff ff       	call   f0101057 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102279:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f010227f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102284:	89 f8                	mov    %edi,%eax
f0102286:	e8 30 e7 ff ff       	call   f01009bb <check_va2pa>
f010228b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010228e:	74 24                	je     f01022b4 <mem_init+0x1182>
f0102290:	c7 44 24 0c c8 47 10 	movl   $0xf01047c8,0xc(%esp)
f0102297:	f0 
f0102298:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01022af:	e8 e0 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022b9:	89 f8                	mov    %edi,%eax
f01022bb:	e8 fb e6 ff ff       	call   f01009bb <check_va2pa>
f01022c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022c3:	74 24                	je     f01022e9 <mem_init+0x11b7>
f01022c5:	c7 44 24 0c 24 48 10 	movl   $0xf0104824,0xc(%esp)
f01022cc:	f0 
f01022cd:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01022d4:	f0 
f01022d5:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f01022dc:	00 
f01022dd:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01022e4:	e8 ab dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01022e9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022ee:	74 24                	je     f0102314 <mem_init+0x11e2>
f01022f0:	c7 44 24 0c 5e 4c 10 	movl   $0xf0104c5e,0xc(%esp)
f01022f7:	f0 
f01022f8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102307:	00 
f0102308:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010230f:	e8 80 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102314:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102319:	74 24                	je     f010233f <mem_init+0x120d>
f010231b:	c7 44 24 0c 2c 4c 10 	movl   $0xf0104c2c,0xc(%esp)
f0102322:	f0 
f0102323:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010232a:	f0 
f010232b:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102332:	00 
f0102333:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010233a:	e8 55 dd ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010233f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102346:	e8 11 eb ff ff       	call   f0100e5c <page_alloc>
f010234b:	85 c0                	test   %eax,%eax
f010234d:	74 04                	je     f0102353 <mem_init+0x1221>
f010234f:	39 c3                	cmp    %eax,%ebx
f0102351:	74 24                	je     f0102377 <mem_init+0x1245>
f0102353:	c7 44 24 0c 4c 48 10 	movl   $0xf010484c,0xc(%esp)
f010235a:	f0 
f010235b:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102362:	f0 
f0102363:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f010236a:	00 
f010236b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102372:	e8 1d dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010237e:	e8 d9 ea ff ff       	call   f0100e5c <page_alloc>
f0102383:	85 c0                	test   %eax,%eax
f0102385:	74 24                	je     f01023ab <mem_init+0x1279>
f0102387:	c7 44 24 0c 80 4b 10 	movl   $0xf0104b80,0xc(%esp)
f010238e:	f0 
f010238f:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102396:	f0 
f0102397:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f010239e:	00 
f010239f:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01023a6:	e8 e9 dc ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023ab:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01023b0:	8b 08                	mov    (%eax),%ecx
f01023b2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023bb:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01023c1:	c1 fa 03             	sar    $0x3,%edx
f01023c4:	c1 e2 0c             	shl    $0xc,%edx
f01023c7:	39 d1                	cmp    %edx,%ecx
f01023c9:	74 24                	je     f01023ef <mem_init+0x12bd>
f01023cb:	c7 44 24 0c f0 44 10 	movl   $0xf01044f0,0xc(%esp)
f01023d2:	f0 
f01023d3:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01023da:	f0 
f01023db:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01023e2:	00 
f01023e3:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01023ea:	e8 a5 dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01023ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023f8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023fd:	74 24                	je     f0102423 <mem_init+0x12f1>
f01023ff:	c7 44 24 0c e3 4b 10 	movl   $0xf0104be3,0xc(%esp)
f0102406:	f0 
f0102407:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010240e:	f0 
f010240f:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102416:	00 
f0102417:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010241e:	e8 71 dc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102423:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102426:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010242c:	89 04 24             	mov    %eax,(%esp)
f010242f:	e8 b3 ea ff ff       	call   f0100ee7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102434:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010243b:	00 
f010243c:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102443:	00 
f0102444:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102449:	89 04 24             	mov    %eax,(%esp)
f010244c:	e8 f9 ea ff ff       	call   f0100f4a <pgdir_walk>
f0102451:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102457:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f010245d:	8b 7a 04             	mov    0x4(%edx),%edi
f0102460:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102466:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f010246c:	89 f8                	mov    %edi,%eax
f010246e:	c1 e8 0c             	shr    $0xc,%eax
f0102471:	39 c8                	cmp    %ecx,%eax
f0102473:	72 20                	jb     f0102495 <mem_init+0x1363>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102475:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102479:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0102480:	f0 
f0102481:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102488:	00 
f0102489:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102490:	e8 ff db ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102495:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010249b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010249e:	74 24                	je     f01024c4 <mem_init+0x1392>
f01024a0:	c7 44 24 0c 6f 4c 10 	movl   $0xf0104c6f,0xc(%esp)
f01024a7:	f0 
f01024a8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01024af:	f0 
f01024b0:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f01024b7:	00 
f01024b8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01024bf:	e8 d0 db ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024c4:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f01024cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ce:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024d4:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01024da:	c1 f8 03             	sar    $0x3,%eax
f01024dd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024e0:	89 c2                	mov    %eax,%edx
f01024e2:	c1 ea 0c             	shr    $0xc,%edx
f01024e5:	39 d1                	cmp    %edx,%ecx
f01024e7:	77 20                	ja     f0102509 <mem_init+0x13d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024ed:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f01024f4:	f0 
f01024f5:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024fc:	00 
f01024fd:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0102504:	e8 8b db ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102509:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102510:	00 
f0102511:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102518:	00 
	return (void *)(pa + KERNBASE);
f0102519:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010251e:	89 04 24             	mov    %eax,(%esp)
f0102521:	e8 e1 13 00 00       	call   f0103907 <memset>
	page_free(pp0);
f0102526:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102529:	89 3c 24             	mov    %edi,(%esp)
f010252c:	e8 b6 e9 ff ff       	call   f0100ee7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102531:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102538:	00 
f0102539:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102540:	00 
f0102541:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102546:	89 04 24             	mov    %eax,(%esp)
f0102549:	e8 fc e9 ff ff       	call   f0100f4a <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010254e:	89 fa                	mov    %edi,%edx
f0102550:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102556:	c1 fa 03             	sar    $0x3,%edx
f0102559:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255c:	89 d0                	mov    %edx,%eax
f010255e:	c1 e8 0c             	shr    $0xc,%eax
f0102561:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0102567:	72 20                	jb     f0102589 <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102569:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010256d:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0102574:	f0 
f0102575:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010257c:	00 
f010257d:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0102584:	e8 0b db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102589:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010258f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102592:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102598:	f6 00 01             	testb  $0x1,(%eax)
f010259b:	74 24                	je     f01025c1 <mem_init+0x148f>
f010259d:	c7 44 24 0c 87 4c 10 	movl   $0xf0104c87,0xc(%esp)
f01025a4:	f0 
f01025a5:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01025ac:	f0 
f01025ad:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f01025b4:	00 
f01025b5:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01025bc:	e8 d3 da ff ff       	call   f0100094 <_panic>
f01025c1:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025c4:	39 d0                	cmp    %edx,%eax
f01025c6:	75 d0                	jne    f0102598 <mem_init+0x1466>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025c8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01025cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025d6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01025df:	89 3d 3c 75 11 f0    	mov    %edi,0xf011753c

	// free the pages we took
	page_free(pp0);
f01025e5:	89 04 24             	mov    %eax,(%esp)
f01025e8:	e8 fa e8 ff ff       	call   f0100ee7 <page_free>
	page_free(pp1);
f01025ed:	89 1c 24             	mov    %ebx,(%esp)
f01025f0:	e8 f2 e8 ff ff       	call   f0100ee7 <page_free>
	page_free(pp2);
f01025f5:	89 34 24             	mov    %esi,(%esp)
f01025f8:	e8 ea e8 ff ff       	call   f0100ee7 <page_free>

	cprintf("check_page() succeeded!\n");
f01025fd:	c7 04 24 9e 4c 10 f0 	movl   $0xf0104c9e,(%esp)
f0102604:	e8 a9 07 00 00       	call   f0102db2 <cprintf>
	// Your code goes here:
	//把UPAGES指向pages的所有页面
	//UPAGES指向pages地址所在的页面。
		int perm = PTE_U | PTE_P ;
		int i = 0;
		n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102609:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010260e:	8d 34 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%esi
f0102615:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		for (i = 0; i < n; i += PGSIZE)
f010261b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102620:	e9 86 00 00 00       	jmp    f01026ab <mem_init+0x1579>
f0102625:	8d 8b 00 00 00 ef    	lea    -0x11000000(%ebx),%ecx
			page_insert(kern_pgdir, pa2page(PADDR(pages) + i), (void *) (UPAGES +i), perm);
f010262b:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102630:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102635:	77 20                	ja     f0102657 <mem_init+0x1525>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102637:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010263b:	c7 44 24 08 f4 43 10 	movl   $0xf01043f4,0x8(%esp)
f0102642:	f0 
f0102643:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f010264a:	00 
f010264b:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102652:	e8 3d da ff ff       	call   f0100094 <_panic>
f0102657:	8d 94 10 00 00 00 10 	lea    0x10000000(%eax,%edx,1),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010265e:	c1 ea 0c             	shr    $0xc,%edx
f0102661:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102667:	72 1c                	jb     f0102685 <mem_init+0x1553>
		panic("pa2page called with invalid pa");
f0102669:	c7 44 24 08 98 43 10 	movl   $0xf0104398,0x8(%esp)
f0102670:	f0 
f0102671:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0102678:	00 
f0102679:	c7 04 24 04 4a 10 f0 	movl   $0xf0104a04,(%esp)
f0102680:	e8 0f da ff ff       	call   f0100094 <_panic>
f0102685:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010268c:	00 
f010268d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
	return &pages[PGNUM(pa)];
f0102691:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102694:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102698:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010269d:	89 04 24             	mov    %eax,(%esp)
f01026a0:	e8 f7 e9 ff ff       	call   f010109c <page_insert>
	//把UPAGES指向pages的所有页面
	//UPAGES指向pages地址所在的页面。
		int perm = PTE_U | PTE_P ;
		int i = 0;
		n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
		for (i = 0; i < n; i += PGSIZE)
f01026a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026ab:	89 da                	mov    %ebx,%edx
f01026ad:	39 de                	cmp    %ebx,%esi
f01026af:	0f 87 70 ff ff ff    	ja     f0102625 <mem_init+0x14f3>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026b5:	be 00 d0 10 f0       	mov    $0xf010d000,%esi
f01026ba:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01026c0:	77 20                	ja     f01026e2 <mem_init+0x15b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01026c6:	c7 44 24 08 f4 43 10 	movl   $0xf01043f4,0x8(%esp)
f01026cd:	f0 
f01026ce:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f01026d5:	00 
f01026d6:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01026dd:	e8 b2 d9 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01026e2:	bf 00 d0 10 00       	mov    $0x10d000,%edi
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

		boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), PTE_W |PTE_P);
f01026e7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01026ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026ef:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
	{
		pde_t *vaPageTable = pgdir_walk(pgdir, (void *)va, 1);
f01026f4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026fb:	00 
f01026fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102700:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102703:	89 04 24             	mov    %eax,(%esp)
f0102706:	e8 3f e8 ff ff       	call   f0100f4a <pgdir_walk>
		if(vaPageTable == NULL)
f010270b:	85 c0                	test   %eax,%eax
f010270d:	74 1b                	je     f010272a <mem_init+0x15f8>
			return ;
		//
		//notice: the pa and va is page-aligned, so the offset is zero;
		//
		*vaPageTable = pa | perm | PTE_P;
f010270f:	89 fa                	mov    %edi,%edx
f0102711:	83 ca 03             	or     $0x3,%edx
f0102714:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
f0102716:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		pa +=PGSIZE;
f010271c:	81 c7 00 10 00 00    	add    $0x1000,%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f0102722:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102728:	75 ca                	jne    f01026f4 <mem_init+0x15c2>
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	unsigned int size = ~0;
	size = size - KERNBASE + 1; 
	size = ROUNDUP(size, PGSIZE);
	boot_map_region(kern_pgdir, KERNBASE, size, (uintptr_t)0, PTE_W |PTE_P);
f010272a:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010272f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102732:	bb 00 00 00 f0       	mov    $0xf0000000,%ebx
f0102737:	8d bb 00 00 00 10    	lea    0x10000000(%ebx),%edi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
	{
		pde_t *vaPageTable = pgdir_walk(pgdir, (void *)va, 1);
f010273d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102744:	00 
f0102745:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010274c:	89 04 24             	mov    %eax,(%esp)
f010274f:	e8 f6 e7 ff ff       	call   f0100f4a <pgdir_walk>
		if(vaPageTable == NULL)
f0102754:	85 c0                	test   %eax,%eax
f0102756:	74 0d                	je     f0102765 <mem_init+0x1633>
			return ;
		//
		//notice: the pa and va is page-aligned, so the offset is zero;
		//
		*vaPageTable = pa | perm | PTE_P;
f0102758:	83 cf 03             	or     $0x3,%edi
f010275b:	89 38                	mov    %edi,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size)
f010275d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102763:	75 d2                	jne    f0102737 <mem_init+0x1605>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102765:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010276b:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0102770:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102773:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010277a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010277f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102782:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102787:	89 45 cc             	mov    %eax,-0x34(%ebp)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010278a:	89 45 c8             	mov    %eax,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010278d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102792:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102795:	bb 00 00 00 00       	mov    $0x0,%ebx
f010279a:	eb 6d                	jmp    f0102809 <mem_init+0x16d7>
f010279c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027a2:	89 f8                	mov    %edi,%eax
f01027a4:	e8 12 e2 ff ff       	call   f01009bb <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a9:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01027b0:	77 23                	ja     f01027d5 <mem_init+0x16a3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027b9:	c7 44 24 08 f4 43 10 	movl   $0xf01043f4,0x8(%esp)
f01027c0:	f0 
f01027c1:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f01027c8:	00 
f01027c9:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01027d0:	e8 bf d8 ff ff       	call   f0100094 <_panic>
f01027d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01027d8:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01027db:	39 c2                	cmp    %eax,%edx
f01027dd:	74 24                	je     f0102803 <mem_init+0x16d1>
f01027df:	c7 44 24 0c 70 48 10 	movl   $0xf0104870,0xc(%esp)
f01027e6:	f0 
f01027e7:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01027ee:	f0 
f01027ef:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f01027f6:	00 
f01027f7:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01027fe:	e8 91 d8 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102803:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102809:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f010280c:	77 8e                	ja     f010279c <mem_init+0x166a>
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010280e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102811:	c1 e0 0c             	shl    $0xc,%eax
f0102814:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102817:	bb 00 00 00 00       	mov    $0x0,%ebx
f010281c:	eb 3b                	jmp    f0102859 <mem_init+0x1727>
f010281e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102824:	89 f8                	mov    %edi,%eax
f0102826:	e8 90 e1 ff ff       	call   f01009bb <check_va2pa>
f010282b:	39 c3                	cmp    %eax,%ebx
f010282d:	74 24                	je     f0102853 <mem_init+0x1721>
f010282f:	c7 44 24 0c a4 48 10 	movl   $0xf01048a4,0xc(%esp)
f0102836:	f0 
f0102837:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010283e:	f0 
f010283f:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0102846:	00 
f0102847:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010284e:	e8 41 d8 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102853:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102859:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010285c:	72 c0                	jb     f010281e <mem_init+0x16ec>
f010285e:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0102863:	81 c6 00 80 00 20    	add    $0x20008000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102869:	89 da                	mov    %ebx,%edx
f010286b:	89 f8                	mov    %edi,%eax
f010286d:	e8 49 e1 ff ff       	call   f01009bb <check_va2pa>
f0102872:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102875:	39 d0                	cmp    %edx,%eax
f0102877:	74 24                	je     f010289d <mem_init+0x176b>
f0102879:	c7 44 24 0c cc 48 10 	movl   $0xf01048cc,0xc(%esp)
f0102880:	f0 
f0102881:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102888:	f0 
f0102889:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102890:	00 
f0102891:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102898:	e8 f7 d7 ff ff       	call   f0100094 <_panic>
f010289d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028a3:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01028a9:	75 be                	jne    f0102869 <mem_init+0x1737>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028ab:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028b0:	89 f8                	mov    %edi,%eax
f01028b2:	e8 04 e1 ff ff       	call   f01009bb <check_va2pa>
f01028b7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028ba:	75 0a                	jne    f01028c6 <mem_init+0x1794>
f01028bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01028c1:	e9 f0 00 00 00       	jmp    f01029b6 <mem_init+0x1884>
f01028c6:	c7 44 24 0c 14 49 10 	movl   $0xf0104914,0xc(%esp)
f01028cd:	f0 
f01028ce:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f01028d5:	f0 
f01028d6:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f01028dd:	00 
f01028de:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01028e5:	e8 aa d7 ff ff       	call   f0100094 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028ea:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01028ef:	72 3c                	jb     f010292d <mem_init+0x17fb>
f01028f1:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028f6:	76 07                	jbe    f01028ff <mem_init+0x17cd>
f01028f8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028fd:	75 2e                	jne    f010292d <mem_init+0x17fb>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01028ff:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102903:	0f 85 aa 00 00 00    	jne    f01029b3 <mem_init+0x1881>
f0102909:	c7 44 24 0c b7 4c 10 	movl   $0xf0104cb7,0xc(%esp)
f0102910:	f0 
f0102911:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102918:	f0 
f0102919:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0102920:	00 
f0102921:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102928:	e8 67 d7 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010292d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102932:	76 55                	jbe    f0102989 <mem_init+0x1857>
				assert(pgdir[i] & PTE_P);
f0102934:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102937:	f6 c2 01             	test   $0x1,%dl
f010293a:	75 24                	jne    f0102960 <mem_init+0x182e>
f010293c:	c7 44 24 0c b7 4c 10 	movl   $0xf0104cb7,0xc(%esp)
f0102943:	f0 
f0102944:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010294b:	f0 
f010294c:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0102953:	00 
f0102954:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f010295b:	e8 34 d7 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102960:	f6 c2 02             	test   $0x2,%dl
f0102963:	75 4e                	jne    f01029b3 <mem_init+0x1881>
f0102965:	c7 44 24 0c c8 4c 10 	movl   $0xf0104cc8,0xc(%esp)
f010296c:	f0 
f010296d:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102974:	f0 
f0102975:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f010297c:	00 
f010297d:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102984:	e8 0b d7 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102989:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010298d:	74 24                	je     f01029b3 <mem_init+0x1881>
f010298f:	c7 44 24 0c d9 4c 10 	movl   $0xf0104cd9,0xc(%esp)
f0102996:	f0 
f0102997:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f010299e:	f0 
f010299f:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01029a6:	00 
f01029a7:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01029ae:	e8 e1 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029b3:	83 c0 01             	add    $0x1,%eax
f01029b6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01029bb:	0f 85 29 ff ff ff    	jne    f01028ea <mem_init+0x17b8>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029c1:	c7 04 24 44 49 10 f0 	movl   $0xf0104944,(%esp)
f01029c8:	e8 e5 03 00 00       	call   f0102db2 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029cd:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029d7:	77 20                	ja     f01029f9 <mem_init+0x18c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029dd:	c7 44 24 08 f4 43 10 	movl   $0xf01043f4,0x8(%esp)
f01029e4:	f0 
f01029e5:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
f01029ec:	00 
f01029ed:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f01029f4:	e8 9b d6 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029f9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029fe:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a01:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a06:	e8 1f e0 ff ff       	call   f0100a2a <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a0b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a0e:	83 e0 f3             	and    $0xfffffff3,%eax
f0102a11:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a16:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a20:	e8 37 e4 ff ff       	call   f0100e5c <page_alloc>
f0102a25:	89 c3                	mov    %eax,%ebx
f0102a27:	85 c0                	test   %eax,%eax
f0102a29:	75 24                	jne    f0102a4f <mem_init+0x191d>
f0102a2b:	c7 44 24 0c d5 4a 10 	movl   $0xf0104ad5,0xc(%esp)
f0102a32:	f0 
f0102a33:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102a42:	00 
f0102a43:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102a4a:	e8 45 d6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a56:	e8 01 e4 ff ff       	call   f0100e5c <page_alloc>
f0102a5b:	89 c7                	mov    %eax,%edi
f0102a5d:	85 c0                	test   %eax,%eax
f0102a5f:	75 24                	jne    f0102a85 <mem_init+0x1953>
f0102a61:	c7 44 24 0c eb 4a 10 	movl   $0xf0104aeb,0xc(%esp)
f0102a68:	f0 
f0102a69:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102a70:	f0 
f0102a71:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102a78:	00 
f0102a79:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102a80:	e8 0f d6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a8c:	e8 cb e3 ff ff       	call   f0100e5c <page_alloc>
f0102a91:	89 c6                	mov    %eax,%esi
f0102a93:	85 c0                	test   %eax,%eax
f0102a95:	75 24                	jne    f0102abb <mem_init+0x1989>
f0102a97:	c7 44 24 0c 01 4b 10 	movl   $0xf0104b01,0xc(%esp)
f0102a9e:	f0 
f0102a9f:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102aa6:	f0 
f0102aa7:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102aae:	00 
f0102aaf:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102ab6:	e8 d9 d5 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102abb:	89 1c 24             	mov    %ebx,(%esp)
f0102abe:	e8 24 e4 ff ff       	call   f0100ee7 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ac3:	89 f8                	mov    %edi,%eax
f0102ac5:	e8 ac de ff ff       	call   f0100976 <page2kva>
f0102aca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ad1:	00 
f0102ad2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102ad9:	00 
f0102ada:	89 04 24             	mov    %eax,(%esp)
f0102add:	e8 25 0e 00 00       	call   f0103907 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ae2:	89 f0                	mov    %esi,%eax
f0102ae4:	e8 8d de ff ff       	call   f0100976 <page2kva>
f0102ae9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102af0:	00 
f0102af1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102af8:	00 
f0102af9:	89 04 24             	mov    %eax,(%esp)
f0102afc:	e8 06 0e 00 00       	call   f0103907 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b01:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b08:	00 
f0102b09:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b10:	00 
f0102b11:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b15:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102b1a:	89 04 24             	mov    %eax,(%esp)
f0102b1d:	e8 7a e5 ff ff       	call   f010109c <page_insert>
	assert(pp1->pp_ref == 1);
f0102b22:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b27:	74 24                	je     f0102b4d <mem_init+0x1a1b>
f0102b29:	c7 44 24 0c d2 4b 10 	movl   $0xf0104bd2,0xc(%esp)
f0102b30:	f0 
f0102b31:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102b38:	f0 
f0102b39:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102b40:	00 
f0102b41:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102b48:	e8 47 d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b4d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b54:	01 01 01 
f0102b57:	74 24                	je     f0102b7d <mem_init+0x1a4b>
f0102b59:	c7 44 24 0c 64 49 10 	movl   $0xf0104964,0xc(%esp)
f0102b60:	f0 
f0102b61:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102b68:	f0 
f0102b69:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102b70:	00 
f0102b71:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102b78:	e8 17 d5 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b7d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b84:	00 
f0102b85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b8c:	00 
f0102b8d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b91:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102b96:	89 04 24             	mov    %eax,(%esp)
f0102b99:	e8 fe e4 ff ff       	call   f010109c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b9e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ba5:	02 02 02 
f0102ba8:	74 24                	je     f0102bce <mem_init+0x1a9c>
f0102baa:	c7 44 24 0c 88 49 10 	movl   $0xf0104988,0xc(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102bb9:	f0 
f0102bba:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102bc1:	00 
f0102bc2:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102bc9:	e8 c6 d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102bce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bd3:	74 24                	je     f0102bf9 <mem_init+0x1ac7>
f0102bd5:	c7 44 24 0c f4 4b 10 	movl   $0xf0104bf4,0xc(%esp)
f0102bdc:	f0 
f0102bdd:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102be4:	f0 
f0102be5:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102bec:	00 
f0102bed:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102bf4:	e8 9b d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102bf9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bfe:	74 24                	je     f0102c24 <mem_init+0x1af2>
f0102c00:	c7 44 24 0c 5e 4c 10 	movl   $0xf0104c5e,0xc(%esp)
f0102c07:	f0 
f0102c08:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102c0f:	f0 
f0102c10:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102c17:	00 
f0102c18:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102c1f:	e8 70 d4 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c24:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c2b:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c2e:	89 f0                	mov    %esi,%eax
f0102c30:	e8 41 dd ff ff       	call   f0100976 <page2kva>
f0102c35:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102c3b:	74 24                	je     f0102c61 <mem_init+0x1b2f>
f0102c3d:	c7 44 24 0c ac 49 10 	movl   $0xf01049ac,0xc(%esp)
f0102c44:	f0 
f0102c45:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102c4c:	f0 
f0102c4d:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102c54:	00 
f0102c55:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102c5c:	e8 33 d4 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c61:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c68:	00 
f0102c69:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102c6e:	89 04 24             	mov    %eax,(%esp)
f0102c71:	e8 e1 e3 ff ff       	call   f0101057 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c76:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c7b:	74 24                	je     f0102ca1 <mem_init+0x1b6f>
f0102c7d:	c7 44 24 0c 2c 4c 10 	movl   $0xf0104c2c,0xc(%esp)
f0102c84:	f0 
f0102c85:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102c8c:	f0 
f0102c8d:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102c94:	00 
f0102c95:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102c9c:	e8 f3 d3 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ca1:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102ca6:	8b 08                	mov    (%eax),%ecx
f0102ca8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cae:	89 da                	mov    %ebx,%edx
f0102cb0:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102cb6:	c1 fa 03             	sar    $0x3,%edx
f0102cb9:	c1 e2 0c             	shl    $0xc,%edx
f0102cbc:	39 d1                	cmp    %edx,%ecx
f0102cbe:	74 24                	je     f0102ce4 <mem_init+0x1bb2>
f0102cc0:	c7 44 24 0c f0 44 10 	movl   $0xf01044f0,0xc(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102cd7:	00 
f0102cd8:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102cdf:	e8 b0 d3 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102ce4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cea:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cef:	74 24                	je     f0102d15 <mem_init+0x1be3>
f0102cf1:	c7 44 24 0c e3 4b 10 	movl   $0xf0104be3,0xc(%esp)
f0102cf8:	f0 
f0102cf9:	c7 44 24 08 2a 4a 10 	movl   $0xf0104a2a,0x8(%esp)
f0102d00:	f0 
f0102d01:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0102d08:	00 
f0102d09:	c7 04 24 12 4a 10 f0 	movl   $0xf0104a12,(%esp)
f0102d10:	e8 7f d3 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102d15:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d1b:	89 1c 24             	mov    %ebx,(%esp)
f0102d1e:	e8 c4 e1 ff ff       	call   f0100ee7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d23:	c7 04 24 d8 49 10 f0 	movl   $0xf01049d8,(%esp)
f0102d2a:	e8 83 00 00 00       	call   f0102db2 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d2f:	83 c4 4c             	add    $0x4c,%esp
f0102d32:	5b                   	pop    %ebx
f0102d33:	5e                   	pop    %esi
f0102d34:	5f                   	pop    %edi
f0102d35:	5d                   	pop    %ebp
f0102d36:	c3                   	ret    

f0102d37 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102d37:	55                   	push   %ebp
f0102d38:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d3d:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102d40:	5d                   	pop    %ebp
f0102d41:	c3                   	ret    

f0102d42 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102d42:	55                   	push   %ebp
f0102d43:	89 e5                	mov    %esp,%ebp
f0102d45:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d49:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d4e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d4f:	b2 71                	mov    $0x71,%dl
f0102d51:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d52:	0f b6 c0             	movzbl %al,%eax
}
f0102d55:	5d                   	pop    %ebp
f0102d56:	c3                   	ret    

f0102d57 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d57:	55                   	push   %ebp
f0102d58:	89 e5                	mov    %esp,%ebp
f0102d5a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d5e:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d63:	ee                   	out    %al,(%dx)
f0102d64:	b2 71                	mov    $0x71,%dl
f0102d66:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d69:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d6a:	5d                   	pop    %ebp
f0102d6b:	c3                   	ret    

f0102d6c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d6c:	55                   	push   %ebp
f0102d6d:	89 e5                	mov    %esp,%ebp
f0102d6f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102d72:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d75:	89 04 24             	mov    %eax,(%esp)
f0102d78:	e8 74 d8 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0102d7d:	c9                   	leave  
f0102d7e:	c3                   	ret    

f0102d7f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d7f:	55                   	push   %ebp
f0102d80:	89 e5                	mov    %esp,%ebp
f0102d82:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102d85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d93:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d96:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102da1:	c7 04 24 6c 2d 10 f0 	movl   $0xf0102d6c,(%esp)
f0102da8:	e8 17 04 00 00       	call   f01031c4 <vprintfmt>
	return cnt;
}
f0102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102db0:	c9                   	leave  
f0102db1:	c3                   	ret    

f0102db2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102db2:	55                   	push   %ebp
f0102db3:	89 e5                	mov    %esp,%ebp
f0102db5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102db8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dc2:	89 04 24             	mov    %eax,(%esp)
f0102dc5:	e8 b5 ff ff ff       	call   f0102d7f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102dca:	c9                   	leave  
f0102dcb:	c3                   	ret    

f0102dcc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102dcc:	55                   	push   %ebp
f0102dcd:	89 e5                	mov    %esp,%ebp
f0102dcf:	57                   	push   %edi
f0102dd0:	56                   	push   %esi
f0102dd1:	53                   	push   %ebx
f0102dd2:	83 ec 10             	sub    $0x10,%esp
f0102dd5:	89 c6                	mov    %eax,%esi
f0102dd7:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102dda:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102ddd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102de0:	8b 1a                	mov    (%edx),%ebx
f0102de2:	8b 01                	mov    (%ecx),%eax
f0102de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102de7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102dee:	eb 77                	jmp    f0102e67 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0102df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102df3:	01 d8                	add    %ebx,%eax
f0102df5:	b9 02 00 00 00       	mov    $0x2,%ecx
f0102dfa:	99                   	cltd   
f0102dfb:	f7 f9                	idiv   %ecx
f0102dfd:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102dff:	eb 01                	jmp    f0102e02 <stab_binsearch+0x36>
			m--;
f0102e01:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102e02:	39 d9                	cmp    %ebx,%ecx
f0102e04:	7c 1d                	jl     f0102e23 <stab_binsearch+0x57>
f0102e06:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102e09:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102e0e:	39 fa                	cmp    %edi,%edx
f0102e10:	75 ef                	jne    f0102e01 <stab_binsearch+0x35>
f0102e12:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102e15:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102e18:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0102e1c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e1f:	73 18                	jae    f0102e39 <stab_binsearch+0x6d>
f0102e21:	eb 05                	jmp    f0102e28 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102e23:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0102e26:	eb 3f                	jmp    f0102e67 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102e28:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e2b:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0102e2d:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e30:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e37:	eb 2e                	jmp    f0102e67 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102e39:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102e3c:	73 15                	jae    f0102e53 <stab_binsearch+0x87>
			*region_right = m - 1;
f0102e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102e41:	48                   	dec    %eax
f0102e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102e45:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e48:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e4a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e51:	eb 14                	jmp    f0102e67 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e53:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e56:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102e59:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0102e5b:	ff 45 0c             	incl   0xc(%ebp)
f0102e5e:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e60:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102e67:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102e6a:	7e 84                	jle    f0102df0 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102e6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102e70:	75 0d                	jne    f0102e7f <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0102e72:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e75:	8b 00                	mov    (%eax),%eax
f0102e77:	48                   	dec    %eax
f0102e78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e7b:	89 07                	mov    %eax,(%edi)
f0102e7d:	eb 22                	jmp    f0102ea1 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e82:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e84:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e87:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e89:	eb 01                	jmp    f0102e8c <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e8b:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e8c:	39 c1                	cmp    %eax,%ecx
f0102e8e:	7d 0c                	jge    f0102e9c <stab_binsearch+0xd0>
f0102e90:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0102e93:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102e98:	39 fa                	cmp    %edi,%edx
f0102e9a:	75 ef                	jne    f0102e8b <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e9c:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0102e9f:	89 07                	mov    %eax,(%edi)
	}
}
f0102ea1:	83 c4 10             	add    $0x10,%esp
f0102ea4:	5b                   	pop    %ebx
f0102ea5:	5e                   	pop    %esi
f0102ea6:	5f                   	pop    %edi
f0102ea7:	5d                   	pop    %ebp
f0102ea8:	c3                   	ret    

f0102ea9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102ea9:	55                   	push   %ebp
f0102eaa:	89 e5                	mov    %esp,%ebp
f0102eac:	57                   	push   %edi
f0102ead:	56                   	push   %esi
f0102eae:	53                   	push   %ebx
f0102eaf:	83 ec 2c             	sub    $0x2c,%esp
f0102eb2:	8b 75 08             	mov    0x8(%ebp),%esi
f0102eb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102eb8:	c7 03 e7 4c 10 f0    	movl   $0xf0104ce7,(%ebx)
	info->eip_line = 0;
f0102ebe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102ec5:	c7 43 08 e7 4c 10 f0 	movl   $0xf0104ce7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102ecc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102ed3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102ed6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102edd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ee3:	76 12                	jbe    f0102ef7 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ee5:	b8 ca ca 10 f0       	mov    $0xf010caca,%eax
f0102eea:	3d 2d ad 10 f0       	cmp    $0xf010ad2d,%eax
f0102eef:	0f 86 6b 01 00 00    	jbe    f0103060 <debuginfo_eip+0x1b7>
f0102ef5:	eb 1c                	jmp    f0102f13 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ef7:	c7 44 24 08 f1 4c 10 	movl   $0xf0104cf1,0x8(%esp)
f0102efe:	f0 
f0102eff:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102f06:	00 
f0102f07:	c7 04 24 fe 4c 10 f0 	movl   $0xf0104cfe,(%esp)
f0102f0e:	e8 81 d1 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102f13:	80 3d c9 ca 10 f0 00 	cmpb   $0x0,0xf010cac9
f0102f1a:	0f 85 47 01 00 00    	jne    f0103067 <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102f20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102f27:	b8 2c ad 10 f0       	mov    $0xf010ad2c,%eax
f0102f2c:	2d 30 4f 10 f0       	sub    $0xf0104f30,%eax
f0102f31:	c1 f8 02             	sar    $0x2,%eax
f0102f34:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102f3a:	83 e8 01             	sub    $0x1,%eax
f0102f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102f40:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f44:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102f4b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f4e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f51:	b8 30 4f 10 f0       	mov    $0xf0104f30,%eax
f0102f56:	e8 71 fe ff ff       	call   f0102dcc <stab_binsearch>
	if (lfile == 0)
f0102f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f5e:	85 c0                	test   %eax,%eax
f0102f60:	0f 84 08 01 00 00    	je     f010306e <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f66:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f6f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f73:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102f7a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f80:	b8 30 4f 10 f0       	mov    $0xf0104f30,%eax
f0102f85:	e8 42 fe ff ff       	call   f0102dcc <stab_binsearch>

	if (lfun <= rfun) {
f0102f8a:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102f8d:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0102f90:	7f 2e                	jg     f0102fc0 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f92:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102f95:	8d 90 30 4f 10 f0    	lea    -0xfefb0d0(%eax),%edx
f0102f9b:	8b 80 30 4f 10 f0    	mov    -0xfefb0d0(%eax),%eax
f0102fa1:	b9 ca ca 10 f0       	mov    $0xf010caca,%ecx
f0102fa6:	81 e9 2d ad 10 f0    	sub    $0xf010ad2d,%ecx
f0102fac:	39 c8                	cmp    %ecx,%eax
f0102fae:	73 08                	jae    f0102fb8 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102fb0:	05 2d ad 10 f0       	add    $0xf010ad2d,%eax
f0102fb5:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102fb8:	8b 42 08             	mov    0x8(%edx),%eax
f0102fbb:	89 43 10             	mov    %eax,0x10(%ebx)
f0102fbe:	eb 06                	jmp    f0102fc6 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102fc0:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102fc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102fc6:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102fcd:	00 
f0102fce:	8b 43 08             	mov    0x8(%ebx),%eax
f0102fd1:	89 04 24             	mov    %eax,(%esp)
f0102fd4:	e8 12 09 00 00       	call   f01038eb <strfind>
f0102fd9:	2b 43 08             	sub    0x8(%ebx),%eax
f0102fdc:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fdf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102fe2:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102fe5:	05 30 4f 10 f0       	add    $0xf0104f30,%eax
f0102fea:	eb 06                	jmp    f0102ff2 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102fec:	83 ef 01             	sub    $0x1,%edi
f0102fef:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102ff2:	39 cf                	cmp    %ecx,%edi
f0102ff4:	7c 33                	jl     f0103029 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0102ff6:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0102ffa:	80 fa 84             	cmp    $0x84,%dl
f0102ffd:	74 0b                	je     f010300a <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102fff:	80 fa 64             	cmp    $0x64,%dl
f0103002:	75 e8                	jne    f0102fec <debuginfo_eip+0x143>
f0103004:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103008:	74 e2                	je     f0102fec <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010300a:	6b ff 0c             	imul   $0xc,%edi,%edi
f010300d:	8b 87 30 4f 10 f0    	mov    -0xfefb0d0(%edi),%eax
f0103013:	ba ca ca 10 f0       	mov    $0xf010caca,%edx
f0103018:	81 ea 2d ad 10 f0    	sub    $0xf010ad2d,%edx
f010301e:	39 d0                	cmp    %edx,%eax
f0103020:	73 07                	jae    f0103029 <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103022:	05 2d ad 10 f0       	add    $0xf010ad2d,%eax
f0103027:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103029:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010302c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010302f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103034:	39 f1                	cmp    %esi,%ecx
f0103036:	7d 42                	jge    f010307a <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0103038:	8d 51 01             	lea    0x1(%ecx),%edx
f010303b:	6b c1 0c             	imul   $0xc,%ecx,%eax
f010303e:	05 30 4f 10 f0       	add    $0xf0104f30,%eax
f0103043:	eb 07                	jmp    f010304c <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103045:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103049:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010304c:	39 f2                	cmp    %esi,%edx
f010304e:	74 25                	je     f0103075 <debuginfo_eip+0x1cc>
f0103050:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103053:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103057:	74 ec                	je     f0103045 <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103059:	b8 00 00 00 00       	mov    $0x0,%eax
f010305e:	eb 1a                	jmp    f010307a <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103065:	eb 13                	jmp    f010307a <debuginfo_eip+0x1d1>
f0103067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010306c:	eb 0c                	jmp    f010307a <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010306e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103073:	eb 05                	jmp    f010307a <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103075:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010307a:	83 c4 2c             	add    $0x2c,%esp
f010307d:	5b                   	pop    %ebx
f010307e:	5e                   	pop    %esi
f010307f:	5f                   	pop    %edi
f0103080:	5d                   	pop    %ebp
f0103081:	c3                   	ret    
f0103082:	66 90                	xchg   %ax,%ax
f0103084:	66 90                	xchg   %ax,%ax
f0103086:	66 90                	xchg   %ax,%ax
f0103088:	66 90                	xchg   %ax,%ax
f010308a:	66 90                	xchg   %ax,%ax
f010308c:	66 90                	xchg   %ax,%ax
f010308e:	66 90                	xchg   %ax,%ax

f0103090 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103090:	55                   	push   %ebp
f0103091:	89 e5                	mov    %esp,%ebp
f0103093:	57                   	push   %edi
f0103094:	56                   	push   %esi
f0103095:	53                   	push   %ebx
f0103096:	83 ec 3c             	sub    $0x3c,%esp
f0103099:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010309c:	89 d7                	mov    %edx,%edi
f010309e:	8b 45 08             	mov    0x8(%ebp),%eax
f01030a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01030a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a7:	89 c3                	mov    %eax,%ebx
f01030a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01030ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01030af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01030b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01030ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01030bd:	39 d9                	cmp    %ebx,%ecx
f01030bf:	72 05                	jb     f01030c6 <printnum+0x36>
f01030c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01030c4:	77 69                	ja     f010312f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01030c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01030cd:	83 ee 01             	sub    $0x1,%esi
f01030d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01030d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030d8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01030dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01030e0:	89 c3                	mov    %eax,%ebx
f01030e2:	89 d6                	mov    %edx,%esi
f01030e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01030e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01030ea:	89 54 24 08          	mov    %edx,0x8(%esp)
f01030ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01030f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030f5:	89 04 24             	mov    %eax,(%esp)
f01030f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030ff:	e8 0c 0a 00 00       	call   f0103b10 <__udivdi3>
f0103104:	89 d9                	mov    %ebx,%ecx
f0103106:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010310a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010310e:	89 04 24             	mov    %eax,(%esp)
f0103111:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103115:	89 fa                	mov    %edi,%edx
f0103117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311a:	e8 71 ff ff ff       	call   f0103090 <printnum>
f010311f:	eb 1b                	jmp    f010313c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103121:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103125:	8b 45 18             	mov    0x18(%ebp),%eax
f0103128:	89 04 24             	mov    %eax,(%esp)
f010312b:	ff d3                	call   *%ebx
f010312d:	eb 03                	jmp    f0103132 <printnum+0xa2>
f010312f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103132:	83 ee 01             	sub    $0x1,%esi
f0103135:	85 f6                	test   %esi,%esi
f0103137:	7f e8                	jg     f0103121 <printnum+0x91>
f0103139:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010313c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103140:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103144:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103147:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010314a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010314e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103152:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103155:	89 04 24             	mov    %eax,(%esp)
f0103158:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010315b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010315f:	e8 dc 0a 00 00       	call   f0103c40 <__umoddi3>
f0103164:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103168:	0f be 80 0c 4d 10 f0 	movsbl -0xfefb2f4(%eax),%eax
f010316f:	89 04 24             	mov    %eax,(%esp)
f0103172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103175:	ff d0                	call   *%eax
}
f0103177:	83 c4 3c             	add    $0x3c,%esp
f010317a:	5b                   	pop    %ebx
f010317b:	5e                   	pop    %esi
f010317c:	5f                   	pop    %edi
f010317d:	5d                   	pop    %ebp
f010317e:	c3                   	ret    

f010317f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010317f:	55                   	push   %ebp
f0103180:	89 e5                	mov    %esp,%ebp
f0103182:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103185:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103189:	8b 10                	mov    (%eax),%edx
f010318b:	3b 50 04             	cmp    0x4(%eax),%edx
f010318e:	73 0a                	jae    f010319a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103190:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103193:	89 08                	mov    %ecx,(%eax)
f0103195:	8b 45 08             	mov    0x8(%ebp),%eax
f0103198:	88 02                	mov    %al,(%edx)
}
f010319a:	5d                   	pop    %ebp
f010319b:	c3                   	ret    

f010319c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010319c:	55                   	push   %ebp
f010319d:	89 e5                	mov    %esp,%ebp
f010319f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01031a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01031ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ba:	89 04 24             	mov    %eax,(%esp)
f01031bd:	e8 02 00 00 00       	call   f01031c4 <vprintfmt>
	va_end(ap);
}
f01031c2:	c9                   	leave  
f01031c3:	c3                   	ret    

f01031c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031c4:	55                   	push   %ebp
f01031c5:	89 e5                	mov    %esp,%ebp
f01031c7:	57                   	push   %edi
f01031c8:	56                   	push   %esi
f01031c9:	53                   	push   %ebx
f01031ca:	83 ec 3c             	sub    $0x3c,%esp
f01031cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01031d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031d3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01031d6:	eb 11                	jmp    f01031e9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01031d8:	85 c0                	test   %eax,%eax
f01031da:	0f 84 48 04 00 00    	je     f0103628 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01031e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031e4:	89 04 24             	mov    %eax,(%esp)
f01031e7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01031e9:	83 c7 01             	add    $0x1,%edi
f01031ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01031f0:	83 f8 25             	cmp    $0x25,%eax
f01031f3:	75 e3                	jne    f01031d8 <vprintfmt+0x14>
f01031f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01031f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103200:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103207:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010320e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103213:	eb 1f                	jmp    f0103234 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103215:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103218:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010321c:	eb 16                	jmp    f0103234 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010321e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103221:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103225:	eb 0d                	jmp    f0103234 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103227:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010322a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010322d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103234:	8d 47 01             	lea    0x1(%edi),%eax
f0103237:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010323a:	0f b6 17             	movzbl (%edi),%edx
f010323d:	0f b6 c2             	movzbl %dl,%eax
f0103240:	83 ea 23             	sub    $0x23,%edx
f0103243:	80 fa 55             	cmp    $0x55,%dl
f0103246:	0f 87 bf 03 00 00    	ja     f010360b <vprintfmt+0x447>
f010324c:	0f b6 d2             	movzbl %dl,%edx
f010324f:	ff 24 95 a0 4d 10 f0 	jmp    *-0xfefb260(,%edx,4)
f0103256:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103259:	ba 00 00 00 00       	mov    $0x0,%edx
f010325e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103261:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103264:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103268:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010326b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010326e:	83 f9 09             	cmp    $0x9,%ecx
f0103271:	77 3c                	ja     f01032af <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103273:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103276:	eb e9                	jmp    f0103261 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103278:	8b 45 14             	mov    0x14(%ebp),%eax
f010327b:	8b 00                	mov    (%eax),%eax
f010327d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103280:	8b 45 14             	mov    0x14(%ebp),%eax
f0103283:	8d 40 04             	lea    0x4(%eax),%eax
f0103286:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010328c:	eb 27                	jmp    f01032b5 <vprintfmt+0xf1>
f010328e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103291:	85 d2                	test   %edx,%edx
f0103293:	b8 00 00 00 00       	mov    $0x0,%eax
f0103298:	0f 49 c2             	cmovns %edx,%eax
f010329b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010329e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01032a1:	eb 91                	jmp    f0103234 <vprintfmt+0x70>
f01032a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01032a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01032ad:	eb 85                	jmp    f0103234 <vprintfmt+0x70>
f01032af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01032b2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01032b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01032b9:	0f 89 75 ff ff ff    	jns    f0103234 <vprintfmt+0x70>
f01032bf:	e9 63 ff ff ff       	jmp    f0103227 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01032c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01032ca:	e9 65 ff ff ff       	jmp    f0103234 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032cf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01032d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032da:	8b 00                	mov    (%eax),%eax
f01032dc:	89 04 24             	mov    %eax,(%esp)
f01032df:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01032e4:	e9 00 ff ff ff       	jmp    f01031e9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032e9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01032ec:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01032f0:	8b 00                	mov    (%eax),%eax
f01032f2:	99                   	cltd   
f01032f3:	31 d0                	xor    %edx,%eax
f01032f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01032f7:	83 f8 07             	cmp    $0x7,%eax
f01032fa:	7f 0b                	jg     f0103307 <vprintfmt+0x143>
f01032fc:	8b 14 85 00 4f 10 f0 	mov    -0xfefb100(,%eax,4),%edx
f0103303:	85 d2                	test   %edx,%edx
f0103305:	75 20                	jne    f0103327 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0103307:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010330b:	c7 44 24 08 24 4d 10 	movl   $0xf0104d24,0x8(%esp)
f0103312:	f0 
f0103313:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103317:	89 34 24             	mov    %esi,(%esp)
f010331a:	e8 7d fe ff ff       	call   f010319c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010331f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103322:	e9 c2 fe ff ff       	jmp    f01031e9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103327:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010332b:	c7 44 24 08 3c 4a 10 	movl   $0xf0104a3c,0x8(%esp)
f0103332:	f0 
f0103333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103337:	89 34 24             	mov    %esi,(%esp)
f010333a:	e8 5d fe ff ff       	call   f010319c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010333f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103342:	e9 a2 fe ff ff       	jmp    f01031e9 <vprintfmt+0x25>
f0103347:	8b 45 14             	mov    0x14(%ebp),%eax
f010334a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010334d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103350:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103353:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103357:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103359:	85 ff                	test   %edi,%edi
f010335b:	b8 1d 4d 10 f0       	mov    $0xf0104d1d,%eax
f0103360:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103363:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103367:	0f 84 92 00 00 00    	je     f01033ff <vprintfmt+0x23b>
f010336d:	85 c9                	test   %ecx,%ecx
f010336f:	0f 8e 98 00 00 00    	jle    f010340d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103375:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103379:	89 3c 24             	mov    %edi,(%esp)
f010337c:	e8 17 04 00 00       	call   f0103798 <strnlen>
f0103381:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103384:	29 c1                	sub    %eax,%ecx
f0103386:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0103389:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010338d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103390:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103393:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103395:	eb 0f                	jmp    f01033a6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0103397:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010339b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010339e:	89 04 24             	mov    %eax,(%esp)
f01033a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01033a3:	83 ef 01             	sub    $0x1,%edi
f01033a6:	85 ff                	test   %edi,%edi
f01033a8:	7f ed                	jg     f0103397 <vprintfmt+0x1d3>
f01033aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01033ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01033b0:	85 c9                	test   %ecx,%ecx
f01033b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01033b7:	0f 49 c1             	cmovns %ecx,%eax
f01033ba:	29 c1                	sub    %eax,%ecx
f01033bc:	89 75 08             	mov    %esi,0x8(%ebp)
f01033bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01033c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01033c5:	89 cb                	mov    %ecx,%ebx
f01033c7:	eb 50                	jmp    f0103419 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01033c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01033cd:	74 1e                	je     f01033ed <vprintfmt+0x229>
f01033cf:	0f be d2             	movsbl %dl,%edx
f01033d2:	83 ea 20             	sub    $0x20,%edx
f01033d5:	83 fa 5e             	cmp    $0x5e,%edx
f01033d8:	76 13                	jbe    f01033ed <vprintfmt+0x229>
					putch('?', putdat);
f01033da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01033e8:	ff 55 08             	call   *0x8(%ebp)
f01033eb:	eb 0d                	jmp    f01033fa <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01033ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01033f4:	89 04 24             	mov    %eax,(%esp)
f01033f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033fa:	83 eb 01             	sub    $0x1,%ebx
f01033fd:	eb 1a                	jmp    f0103419 <vprintfmt+0x255>
f01033ff:	89 75 08             	mov    %esi,0x8(%ebp)
f0103402:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103405:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103408:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010340b:	eb 0c                	jmp    f0103419 <vprintfmt+0x255>
f010340d:	89 75 08             	mov    %esi,0x8(%ebp)
f0103410:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103413:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103416:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103419:	83 c7 01             	add    $0x1,%edi
f010341c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103420:	0f be c2             	movsbl %dl,%eax
f0103423:	85 c0                	test   %eax,%eax
f0103425:	74 25                	je     f010344c <vprintfmt+0x288>
f0103427:	85 f6                	test   %esi,%esi
f0103429:	78 9e                	js     f01033c9 <vprintfmt+0x205>
f010342b:	83 ee 01             	sub    $0x1,%esi
f010342e:	79 99                	jns    f01033c9 <vprintfmt+0x205>
f0103430:	89 df                	mov    %ebx,%edi
f0103432:	8b 75 08             	mov    0x8(%ebp),%esi
f0103435:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103438:	eb 1a                	jmp    f0103454 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010343a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010343e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103445:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103447:	83 ef 01             	sub    $0x1,%edi
f010344a:	eb 08                	jmp    f0103454 <vprintfmt+0x290>
f010344c:	89 df                	mov    %ebx,%edi
f010344e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103454:	85 ff                	test   %edi,%edi
f0103456:	7f e2                	jg     f010343a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010345b:	e9 89 fd ff ff       	jmp    f01031e9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103460:	83 f9 01             	cmp    $0x1,%ecx
f0103463:	7e 19                	jle    f010347e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0103465:	8b 45 14             	mov    0x14(%ebp),%eax
f0103468:	8b 50 04             	mov    0x4(%eax),%edx
f010346b:	8b 00                	mov    (%eax),%eax
f010346d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103470:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103473:	8b 45 14             	mov    0x14(%ebp),%eax
f0103476:	8d 40 08             	lea    0x8(%eax),%eax
f0103479:	89 45 14             	mov    %eax,0x14(%ebp)
f010347c:	eb 38                	jmp    f01034b6 <vprintfmt+0x2f2>
	else if (lflag)
f010347e:	85 c9                	test   %ecx,%ecx
f0103480:	74 1b                	je     f010349d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0103482:	8b 45 14             	mov    0x14(%ebp),%eax
f0103485:	8b 00                	mov    (%eax),%eax
f0103487:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010348a:	89 c1                	mov    %eax,%ecx
f010348c:	c1 f9 1f             	sar    $0x1f,%ecx
f010348f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103492:	8b 45 14             	mov    0x14(%ebp),%eax
f0103495:	8d 40 04             	lea    0x4(%eax),%eax
f0103498:	89 45 14             	mov    %eax,0x14(%ebp)
f010349b:	eb 19                	jmp    f01034b6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010349d:	8b 45 14             	mov    0x14(%ebp),%eax
f01034a0:	8b 00                	mov    (%eax),%eax
f01034a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034a5:	89 c1                	mov    %eax,%ecx
f01034a7:	c1 f9 1f             	sar    $0x1f,%ecx
f01034aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01034ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01034b0:	8d 40 04             	lea    0x4(%eax),%eax
f01034b3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01034b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01034bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01034c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01034c5:	0f 89 04 01 00 00    	jns    f01035cf <vprintfmt+0x40b>
				putch('-', putdat);
f01034cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01034d6:	ff d6                	call   *%esi
				num = -(long long) num;
f01034d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01034de:	f7 da                	neg    %edx
f01034e0:	83 d1 00             	adc    $0x0,%ecx
f01034e3:	f7 d9                	neg    %ecx
f01034e5:	e9 e5 00 00 00       	jmp    f01035cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01034ea:	83 f9 01             	cmp    $0x1,%ecx
f01034ed:	7e 10                	jle    f01034ff <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01034ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f2:	8b 10                	mov    (%eax),%edx
f01034f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01034f7:	8d 40 08             	lea    0x8(%eax),%eax
f01034fa:	89 45 14             	mov    %eax,0x14(%ebp)
f01034fd:	eb 26                	jmp    f0103525 <vprintfmt+0x361>
	else if (lflag)
f01034ff:	85 c9                	test   %ecx,%ecx
f0103501:	74 12                	je     f0103515 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0103503:	8b 45 14             	mov    0x14(%ebp),%eax
f0103506:	8b 10                	mov    (%eax),%edx
f0103508:	b9 00 00 00 00       	mov    $0x0,%ecx
f010350d:	8d 40 04             	lea    0x4(%eax),%eax
f0103510:	89 45 14             	mov    %eax,0x14(%ebp)
f0103513:	eb 10                	jmp    f0103525 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0103515:	8b 45 14             	mov    0x14(%ebp),%eax
f0103518:	8b 10                	mov    (%eax),%edx
f010351a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010351f:	8d 40 04             	lea    0x4(%eax),%eax
f0103522:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103525:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010352a:	e9 a0 00 00 00       	jmp    f01035cf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010352f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103533:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010353a:	ff d6                	call   *%esi
			putch('X', putdat);
f010353c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103540:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103547:	ff d6                	call   *%esi
			putch('X', putdat);
f0103549:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010354d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103554:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103559:	e9 8b fc ff ff       	jmp    f01031e9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010355e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103562:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103569:	ff d6                	call   *%esi
			putch('x', putdat);
f010356b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010356f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103576:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103578:	8b 45 14             	mov    0x14(%ebp),%eax
f010357b:	8b 10                	mov    (%eax),%edx
f010357d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0103582:	8d 40 04             	lea    0x4(%eax),%eax
f0103585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103588:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010358d:	eb 40                	jmp    f01035cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010358f:	83 f9 01             	cmp    $0x1,%ecx
f0103592:	7e 10                	jle    f01035a4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0103594:	8b 45 14             	mov    0x14(%ebp),%eax
f0103597:	8b 10                	mov    (%eax),%edx
f0103599:	8b 48 04             	mov    0x4(%eax),%ecx
f010359c:	8d 40 08             	lea    0x8(%eax),%eax
f010359f:	89 45 14             	mov    %eax,0x14(%ebp)
f01035a2:	eb 26                	jmp    f01035ca <vprintfmt+0x406>
	else if (lflag)
f01035a4:	85 c9                	test   %ecx,%ecx
f01035a6:	74 12                	je     f01035ba <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01035a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01035ab:	8b 10                	mov    (%eax),%edx
f01035ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035b2:	8d 40 04             	lea    0x4(%eax),%eax
f01035b5:	89 45 14             	mov    %eax,0x14(%ebp)
f01035b8:	eb 10                	jmp    f01035ca <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01035ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01035bd:	8b 10                	mov    (%eax),%edx
f01035bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035c4:	8d 40 04             	lea    0x4(%eax),%eax
f01035c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01035ca:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01035cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01035d3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01035d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035de:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01035e2:	89 14 24             	mov    %edx,(%esp)
f01035e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01035e9:	89 da                	mov    %ebx,%edx
f01035eb:	89 f0                	mov    %esi,%eax
f01035ed:	e8 9e fa ff ff       	call   f0103090 <printnum>
			break;
f01035f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035f5:	e9 ef fb ff ff       	jmp    f01031e9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01035fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035fe:	89 04 24             	mov    %eax,(%esp)
f0103601:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103606:	e9 de fb ff ff       	jmp    f01031e9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010360b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010360f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103616:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103618:	eb 03                	jmp    f010361d <vprintfmt+0x459>
f010361a:	83 ef 01             	sub    $0x1,%edi
f010361d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103621:	75 f7                	jne    f010361a <vprintfmt+0x456>
f0103623:	e9 c1 fb ff ff       	jmp    f01031e9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103628:	83 c4 3c             	add    $0x3c,%esp
f010362b:	5b                   	pop    %ebx
f010362c:	5e                   	pop    %esi
f010362d:	5f                   	pop    %edi
f010362e:	5d                   	pop    %ebp
f010362f:	c3                   	ret    

f0103630 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103630:	55                   	push   %ebp
f0103631:	89 e5                	mov    %esp,%ebp
f0103633:	83 ec 28             	sub    $0x28,%esp
f0103636:	8b 45 08             	mov    0x8(%ebp),%eax
f0103639:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010363c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010363f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103643:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010364d:	85 c0                	test   %eax,%eax
f010364f:	74 30                	je     f0103681 <vsnprintf+0x51>
f0103651:	85 d2                	test   %edx,%edx
f0103653:	7e 2c                	jle    f0103681 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103655:	8b 45 14             	mov    0x14(%ebp),%eax
f0103658:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010365c:	8b 45 10             	mov    0x10(%ebp),%eax
f010365f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103663:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103666:	89 44 24 04          	mov    %eax,0x4(%esp)
f010366a:	c7 04 24 7f 31 10 f0 	movl   $0xf010317f,(%esp)
f0103671:	e8 4e fb ff ff       	call   f01031c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103676:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103679:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010367c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010367f:	eb 05                	jmp    f0103686 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103681:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103686:	c9                   	leave  
f0103687:	c3                   	ret    

f0103688 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103688:	55                   	push   %ebp
f0103689:	89 e5                	mov    %esp,%ebp
f010368b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010368e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103691:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103695:	8b 45 10             	mov    0x10(%ebp),%eax
f0103698:	89 44 24 08          	mov    %eax,0x8(%esp)
f010369c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010369f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a6:	89 04 24             	mov    %eax,(%esp)
f01036a9:	e8 82 ff ff ff       	call   f0103630 <vsnprintf>
	va_end(ap);

	return rc;
}
f01036ae:	c9                   	leave  
f01036af:	c3                   	ret    

f01036b0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01036b0:	55                   	push   %ebp
f01036b1:	89 e5                	mov    %esp,%ebp
f01036b3:	57                   	push   %edi
f01036b4:	56                   	push   %esi
f01036b5:	53                   	push   %ebx
f01036b6:	83 ec 1c             	sub    $0x1c,%esp
f01036b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01036bc:	85 c0                	test   %eax,%eax
f01036be:	74 10                	je     f01036d0 <readline+0x20>
		cprintf("%s", prompt);
f01036c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036c4:	c7 04 24 3c 4a 10 f0 	movl   $0xf0104a3c,(%esp)
f01036cb:	e8 e2 f6 ff ff       	call   f0102db2 <cprintf>

	i = 0;
	echoing = iscons(0);
f01036d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036d7:	e8 36 cf ff ff       	call   f0100612 <iscons>
f01036dc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01036de:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01036e3:	e8 19 cf ff ff       	call   f0100601 <getchar>
f01036e8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01036ea:	85 c0                	test   %eax,%eax
f01036ec:	79 17                	jns    f0103705 <readline+0x55>
			cprintf("read error: %e\n", c);
f01036ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036f2:	c7 04 24 20 4f 10 f0 	movl   $0xf0104f20,(%esp)
f01036f9:	e8 b4 f6 ff ff       	call   f0102db2 <cprintf>
			return NULL;
f01036fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103703:	eb 6d                	jmp    f0103772 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103705:	83 f8 7f             	cmp    $0x7f,%eax
f0103708:	74 05                	je     f010370f <readline+0x5f>
f010370a:	83 f8 08             	cmp    $0x8,%eax
f010370d:	75 19                	jne    f0103728 <readline+0x78>
f010370f:	85 f6                	test   %esi,%esi
f0103711:	7e 15                	jle    f0103728 <readline+0x78>
			if (echoing)
f0103713:	85 ff                	test   %edi,%edi
f0103715:	74 0c                	je     f0103723 <readline+0x73>
				cputchar('\b');
f0103717:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010371e:	e8 ce ce ff ff       	call   f01005f1 <cputchar>
			i--;
f0103723:	83 ee 01             	sub    $0x1,%esi
f0103726:	eb bb                	jmp    f01036e3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103728:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010372e:	7f 1c                	jg     f010374c <readline+0x9c>
f0103730:	83 fb 1f             	cmp    $0x1f,%ebx
f0103733:	7e 17                	jle    f010374c <readline+0x9c>
			if (echoing)
f0103735:	85 ff                	test   %edi,%edi
f0103737:	74 08                	je     f0103741 <readline+0x91>
				cputchar(c);
f0103739:	89 1c 24             	mov    %ebx,(%esp)
f010373c:	e8 b0 ce ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0103741:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103747:	8d 76 01             	lea    0x1(%esi),%esi
f010374a:	eb 97                	jmp    f01036e3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010374c:	83 fb 0d             	cmp    $0xd,%ebx
f010374f:	74 05                	je     f0103756 <readline+0xa6>
f0103751:	83 fb 0a             	cmp    $0xa,%ebx
f0103754:	75 8d                	jne    f01036e3 <readline+0x33>
			if (echoing)
f0103756:	85 ff                	test   %edi,%edi
f0103758:	74 0c                	je     f0103766 <readline+0xb6>
				cputchar('\n');
f010375a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103761:	e8 8b ce ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0103766:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010376d:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103772:	83 c4 1c             	add    $0x1c,%esp
f0103775:	5b                   	pop    %ebx
f0103776:	5e                   	pop    %esi
f0103777:	5f                   	pop    %edi
f0103778:	5d                   	pop    %ebp
f0103779:	c3                   	ret    
f010377a:	66 90                	xchg   %ax,%ax
f010377c:	66 90                	xchg   %ax,%ax
f010377e:	66 90                	xchg   %ax,%ax

f0103780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103780:	55                   	push   %ebp
f0103781:	89 e5                	mov    %esp,%ebp
f0103783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103786:	b8 00 00 00 00       	mov    $0x0,%eax
f010378b:	eb 03                	jmp    f0103790 <strlen+0x10>
		n++;
f010378d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103794:	75 f7                	jne    f010378d <strlen+0xd>
		n++;
	return n;
}
f0103796:	5d                   	pop    %ebp
f0103797:	c3                   	ret    

f0103798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103798:	55                   	push   %ebp
f0103799:	89 e5                	mov    %esp,%ebp
f010379b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010379e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01037a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01037a6:	eb 03                	jmp    f01037ab <strnlen+0x13>
		n++;
f01037a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01037ab:	39 d0                	cmp    %edx,%eax
f01037ad:	74 06                	je     f01037b5 <strnlen+0x1d>
f01037af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01037b3:	75 f3                	jne    f01037a8 <strnlen+0x10>
		n++;
	return n;
}
f01037b5:	5d                   	pop    %ebp
f01037b6:	c3                   	ret    

f01037b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01037b7:	55                   	push   %ebp
f01037b8:	89 e5                	mov    %esp,%ebp
f01037ba:	53                   	push   %ebx
f01037bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01037c1:	89 c2                	mov    %eax,%edx
f01037c3:	83 c2 01             	add    $0x1,%edx
f01037c6:	83 c1 01             	add    $0x1,%ecx
f01037c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01037cd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01037d0:	84 db                	test   %bl,%bl
f01037d2:	75 ef                	jne    f01037c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01037d4:	5b                   	pop    %ebx
f01037d5:	5d                   	pop    %ebp
f01037d6:	c3                   	ret    

f01037d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01037d7:	55                   	push   %ebp
f01037d8:	89 e5                	mov    %esp,%ebp
f01037da:	53                   	push   %ebx
f01037db:	83 ec 08             	sub    $0x8,%esp
f01037de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01037e1:	89 1c 24             	mov    %ebx,(%esp)
f01037e4:	e8 97 ff ff ff       	call   f0103780 <strlen>
	strcpy(dst + len, src);
f01037e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037f0:	01 d8                	add    %ebx,%eax
f01037f2:	89 04 24             	mov    %eax,(%esp)
f01037f5:	e8 bd ff ff ff       	call   f01037b7 <strcpy>
	return dst;
}
f01037fa:	89 d8                	mov    %ebx,%eax
f01037fc:	83 c4 08             	add    $0x8,%esp
f01037ff:	5b                   	pop    %ebx
f0103800:	5d                   	pop    %ebp
f0103801:	c3                   	ret    

f0103802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103802:	55                   	push   %ebp
f0103803:	89 e5                	mov    %esp,%ebp
f0103805:	56                   	push   %esi
f0103806:	53                   	push   %ebx
f0103807:	8b 75 08             	mov    0x8(%ebp),%esi
f010380a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010380d:	89 f3                	mov    %esi,%ebx
f010380f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103812:	89 f2                	mov    %esi,%edx
f0103814:	eb 0f                	jmp    f0103825 <strncpy+0x23>
		*dst++ = *src;
f0103816:	83 c2 01             	add    $0x1,%edx
f0103819:	0f b6 01             	movzbl (%ecx),%eax
f010381c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010381f:	80 39 01             	cmpb   $0x1,(%ecx)
f0103822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103825:	39 da                	cmp    %ebx,%edx
f0103827:	75 ed                	jne    f0103816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103829:	89 f0                	mov    %esi,%eax
f010382b:	5b                   	pop    %ebx
f010382c:	5e                   	pop    %esi
f010382d:	5d                   	pop    %ebp
f010382e:	c3                   	ret    

f010382f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010382f:	55                   	push   %ebp
f0103830:	89 e5                	mov    %esp,%ebp
f0103832:	56                   	push   %esi
f0103833:	53                   	push   %ebx
f0103834:	8b 75 08             	mov    0x8(%ebp),%esi
f0103837:	8b 55 0c             	mov    0xc(%ebp),%edx
f010383a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010383d:	89 f0                	mov    %esi,%eax
f010383f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103843:	85 c9                	test   %ecx,%ecx
f0103845:	75 0b                	jne    f0103852 <strlcpy+0x23>
f0103847:	eb 1d                	jmp    f0103866 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103849:	83 c0 01             	add    $0x1,%eax
f010384c:	83 c2 01             	add    $0x1,%edx
f010384f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103852:	39 d8                	cmp    %ebx,%eax
f0103854:	74 0b                	je     f0103861 <strlcpy+0x32>
f0103856:	0f b6 0a             	movzbl (%edx),%ecx
f0103859:	84 c9                	test   %cl,%cl
f010385b:	75 ec                	jne    f0103849 <strlcpy+0x1a>
f010385d:	89 c2                	mov    %eax,%edx
f010385f:	eb 02                	jmp    f0103863 <strlcpy+0x34>
f0103861:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103863:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103866:	29 f0                	sub    %esi,%eax
}
f0103868:	5b                   	pop    %ebx
f0103869:	5e                   	pop    %esi
f010386a:	5d                   	pop    %ebp
f010386b:	c3                   	ret    

f010386c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010386c:	55                   	push   %ebp
f010386d:	89 e5                	mov    %esp,%ebp
f010386f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103872:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103875:	eb 06                	jmp    f010387d <strcmp+0x11>
		p++, q++;
f0103877:	83 c1 01             	add    $0x1,%ecx
f010387a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010387d:	0f b6 01             	movzbl (%ecx),%eax
f0103880:	84 c0                	test   %al,%al
f0103882:	74 04                	je     f0103888 <strcmp+0x1c>
f0103884:	3a 02                	cmp    (%edx),%al
f0103886:	74 ef                	je     f0103877 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103888:	0f b6 c0             	movzbl %al,%eax
f010388b:	0f b6 12             	movzbl (%edx),%edx
f010388e:	29 d0                	sub    %edx,%eax
}
f0103890:	5d                   	pop    %ebp
f0103891:	c3                   	ret    

f0103892 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103892:	55                   	push   %ebp
f0103893:	89 e5                	mov    %esp,%ebp
f0103895:	53                   	push   %ebx
f0103896:	8b 45 08             	mov    0x8(%ebp),%eax
f0103899:	8b 55 0c             	mov    0xc(%ebp),%edx
f010389c:	89 c3                	mov    %eax,%ebx
f010389e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01038a1:	eb 06                	jmp    f01038a9 <strncmp+0x17>
		n--, p++, q++;
f01038a3:	83 c0 01             	add    $0x1,%eax
f01038a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01038a9:	39 d8                	cmp    %ebx,%eax
f01038ab:	74 15                	je     f01038c2 <strncmp+0x30>
f01038ad:	0f b6 08             	movzbl (%eax),%ecx
f01038b0:	84 c9                	test   %cl,%cl
f01038b2:	74 04                	je     f01038b8 <strncmp+0x26>
f01038b4:	3a 0a                	cmp    (%edx),%cl
f01038b6:	74 eb                	je     f01038a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01038b8:	0f b6 00             	movzbl (%eax),%eax
f01038bb:	0f b6 12             	movzbl (%edx),%edx
f01038be:	29 d0                	sub    %edx,%eax
f01038c0:	eb 05                	jmp    f01038c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01038c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01038c7:	5b                   	pop    %ebx
f01038c8:	5d                   	pop    %ebp
f01038c9:	c3                   	ret    

f01038ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01038ca:	55                   	push   %ebp
f01038cb:	89 e5                	mov    %esp,%ebp
f01038cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01038d4:	eb 07                	jmp    f01038dd <strchr+0x13>
		if (*s == c)
f01038d6:	38 ca                	cmp    %cl,%dl
f01038d8:	74 0f                	je     f01038e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01038da:	83 c0 01             	add    $0x1,%eax
f01038dd:	0f b6 10             	movzbl (%eax),%edx
f01038e0:	84 d2                	test   %dl,%dl
f01038e2:	75 f2                	jne    f01038d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01038e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038e9:	5d                   	pop    %ebp
f01038ea:	c3                   	ret    

f01038eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01038eb:	55                   	push   %ebp
f01038ec:	89 e5                	mov    %esp,%ebp
f01038ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01038f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01038f5:	eb 07                	jmp    f01038fe <strfind+0x13>
		if (*s == c)
f01038f7:	38 ca                	cmp    %cl,%dl
f01038f9:	74 0a                	je     f0103905 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01038fb:	83 c0 01             	add    $0x1,%eax
f01038fe:	0f b6 10             	movzbl (%eax),%edx
f0103901:	84 d2                	test   %dl,%dl
f0103903:	75 f2                	jne    f01038f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0103905:	5d                   	pop    %ebp
f0103906:	c3                   	ret    

f0103907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103907:	55                   	push   %ebp
f0103908:	89 e5                	mov    %esp,%ebp
f010390a:	57                   	push   %edi
f010390b:	56                   	push   %esi
f010390c:	53                   	push   %ebx
f010390d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103913:	85 c9                	test   %ecx,%ecx
f0103915:	74 36                	je     f010394d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103917:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010391d:	75 28                	jne    f0103947 <memset+0x40>
f010391f:	f6 c1 03             	test   $0x3,%cl
f0103922:	75 23                	jne    f0103947 <memset+0x40>
		c &= 0xFF;
f0103924:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103928:	89 d3                	mov    %edx,%ebx
f010392a:	c1 e3 08             	shl    $0x8,%ebx
f010392d:	89 d6                	mov    %edx,%esi
f010392f:	c1 e6 18             	shl    $0x18,%esi
f0103932:	89 d0                	mov    %edx,%eax
f0103934:	c1 e0 10             	shl    $0x10,%eax
f0103937:	09 f0                	or     %esi,%eax
f0103939:	09 c2                	or     %eax,%edx
f010393b:	89 d0                	mov    %edx,%eax
f010393d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010393f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103942:	fc                   	cld    
f0103943:	f3 ab                	rep stos %eax,%es:(%edi)
f0103945:	eb 06                	jmp    f010394d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103947:	8b 45 0c             	mov    0xc(%ebp),%eax
f010394a:	fc                   	cld    
f010394b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010394d:	89 f8                	mov    %edi,%eax
f010394f:	5b                   	pop    %ebx
f0103950:	5e                   	pop    %esi
f0103951:	5f                   	pop    %edi
f0103952:	5d                   	pop    %ebp
f0103953:	c3                   	ret    

f0103954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103954:	55                   	push   %ebp
f0103955:	89 e5                	mov    %esp,%ebp
f0103957:	57                   	push   %edi
f0103958:	56                   	push   %esi
f0103959:	8b 45 08             	mov    0x8(%ebp),%eax
f010395c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010395f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103962:	39 c6                	cmp    %eax,%esi
f0103964:	73 35                	jae    f010399b <memmove+0x47>
f0103966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103969:	39 d0                	cmp    %edx,%eax
f010396b:	73 2e                	jae    f010399b <memmove+0x47>
		s += n;
		d += n;
f010396d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103970:	89 d6                	mov    %edx,%esi
f0103972:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103974:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010397a:	75 13                	jne    f010398f <memmove+0x3b>
f010397c:	f6 c1 03             	test   $0x3,%cl
f010397f:	75 0e                	jne    f010398f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103981:	83 ef 04             	sub    $0x4,%edi
f0103984:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103987:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010398a:	fd                   	std    
f010398b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010398d:	eb 09                	jmp    f0103998 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010398f:	83 ef 01             	sub    $0x1,%edi
f0103992:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103995:	fd                   	std    
f0103996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103998:	fc                   	cld    
f0103999:	eb 1d                	jmp    f01039b8 <memmove+0x64>
f010399b:	89 f2                	mov    %esi,%edx
f010399d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010399f:	f6 c2 03             	test   $0x3,%dl
f01039a2:	75 0f                	jne    f01039b3 <memmove+0x5f>
f01039a4:	f6 c1 03             	test   $0x3,%cl
f01039a7:	75 0a                	jne    f01039b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01039a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01039ac:	89 c7                	mov    %eax,%edi
f01039ae:	fc                   	cld    
f01039af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01039b1:	eb 05                	jmp    f01039b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01039b3:	89 c7                	mov    %eax,%edi
f01039b5:	fc                   	cld    
f01039b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01039b8:	5e                   	pop    %esi
f01039b9:	5f                   	pop    %edi
f01039ba:	5d                   	pop    %ebp
f01039bb:	c3                   	ret    

f01039bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01039bc:	55                   	push   %ebp
f01039bd:	89 e5                	mov    %esp,%ebp
f01039bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01039c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01039c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d3:	89 04 24             	mov    %eax,(%esp)
f01039d6:	e8 79 ff ff ff       	call   f0103954 <memmove>
}
f01039db:	c9                   	leave  
f01039dc:	c3                   	ret    

f01039dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01039dd:	55                   	push   %ebp
f01039de:	89 e5                	mov    %esp,%ebp
f01039e0:	56                   	push   %esi
f01039e1:	53                   	push   %ebx
f01039e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01039e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01039e8:	89 d6                	mov    %edx,%esi
f01039ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01039ed:	eb 1a                	jmp    f0103a09 <memcmp+0x2c>
		if (*s1 != *s2)
f01039ef:	0f b6 02             	movzbl (%edx),%eax
f01039f2:	0f b6 19             	movzbl (%ecx),%ebx
f01039f5:	38 d8                	cmp    %bl,%al
f01039f7:	74 0a                	je     f0103a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01039f9:	0f b6 c0             	movzbl %al,%eax
f01039fc:	0f b6 db             	movzbl %bl,%ebx
f01039ff:	29 d8                	sub    %ebx,%eax
f0103a01:	eb 0f                	jmp    f0103a12 <memcmp+0x35>
		s1++, s2++;
f0103a03:	83 c2 01             	add    $0x1,%edx
f0103a06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103a09:	39 f2                	cmp    %esi,%edx
f0103a0b:	75 e2                	jne    f01039ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a12:	5b                   	pop    %ebx
f0103a13:	5e                   	pop    %esi
f0103a14:	5d                   	pop    %ebp
f0103a15:	c3                   	ret    

f0103a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103a16:	55                   	push   %ebp
f0103a17:	89 e5                	mov    %esp,%ebp
f0103a19:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103a1f:	89 c2                	mov    %eax,%edx
f0103a21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103a24:	eb 07                	jmp    f0103a2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103a26:	38 08                	cmp    %cl,(%eax)
f0103a28:	74 07                	je     f0103a31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103a2a:	83 c0 01             	add    $0x1,%eax
f0103a2d:	39 d0                	cmp    %edx,%eax
f0103a2f:	72 f5                	jb     f0103a26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103a31:	5d                   	pop    %ebp
f0103a32:	c3                   	ret    

f0103a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103a33:	55                   	push   %ebp
f0103a34:	89 e5                	mov    %esp,%ebp
f0103a36:	57                   	push   %edi
f0103a37:	56                   	push   %esi
f0103a38:	53                   	push   %ebx
f0103a39:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103a3f:	eb 03                	jmp    f0103a44 <strtol+0x11>
		s++;
f0103a41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103a44:	0f b6 0a             	movzbl (%edx),%ecx
f0103a47:	80 f9 09             	cmp    $0x9,%cl
f0103a4a:	74 f5                	je     f0103a41 <strtol+0xe>
f0103a4c:	80 f9 20             	cmp    $0x20,%cl
f0103a4f:	74 f0                	je     f0103a41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103a51:	80 f9 2b             	cmp    $0x2b,%cl
f0103a54:	75 0a                	jne    f0103a60 <strtol+0x2d>
		s++;
f0103a56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103a59:	bf 00 00 00 00       	mov    $0x0,%edi
f0103a5e:	eb 11                	jmp    f0103a71 <strtol+0x3e>
f0103a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103a65:	80 f9 2d             	cmp    $0x2d,%cl
f0103a68:	75 07                	jne    f0103a71 <strtol+0x3e>
		s++, neg = 1;
f0103a6a:	8d 52 01             	lea    0x1(%edx),%edx
f0103a6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103a71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0103a76:	75 15                	jne    f0103a8d <strtol+0x5a>
f0103a78:	80 3a 30             	cmpb   $0x30,(%edx)
f0103a7b:	75 10                	jne    f0103a8d <strtol+0x5a>
f0103a7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103a81:	75 0a                	jne    f0103a8d <strtol+0x5a>
		s += 2, base = 16;
f0103a83:	83 c2 02             	add    $0x2,%edx
f0103a86:	b8 10 00 00 00       	mov    $0x10,%eax
f0103a8b:	eb 10                	jmp    f0103a9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0103a8d:	85 c0                	test   %eax,%eax
f0103a8f:	75 0c                	jne    f0103a9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103a91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103a93:	80 3a 30             	cmpb   $0x30,(%edx)
f0103a96:	75 05                	jne    f0103a9d <strtol+0x6a>
		s++, base = 8;
f0103a98:	83 c2 01             	add    $0x1,%edx
f0103a9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0103a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103aa2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103aa5:	0f b6 0a             	movzbl (%edx),%ecx
f0103aa8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0103aab:	89 f0                	mov    %esi,%eax
f0103aad:	3c 09                	cmp    $0x9,%al
f0103aaf:	77 08                	ja     f0103ab9 <strtol+0x86>
			dig = *s - '0';
f0103ab1:	0f be c9             	movsbl %cl,%ecx
f0103ab4:	83 e9 30             	sub    $0x30,%ecx
f0103ab7:	eb 20                	jmp    f0103ad9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0103ab9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0103abc:	89 f0                	mov    %esi,%eax
f0103abe:	3c 19                	cmp    $0x19,%al
f0103ac0:	77 08                	ja     f0103aca <strtol+0x97>
			dig = *s - 'a' + 10;
f0103ac2:	0f be c9             	movsbl %cl,%ecx
f0103ac5:	83 e9 57             	sub    $0x57,%ecx
f0103ac8:	eb 0f                	jmp    f0103ad9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0103aca:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0103acd:	89 f0                	mov    %esi,%eax
f0103acf:	3c 19                	cmp    $0x19,%al
f0103ad1:	77 16                	ja     f0103ae9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0103ad3:	0f be c9             	movsbl %cl,%ecx
f0103ad6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103ad9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0103adc:	7d 0f                	jge    f0103aed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0103ade:	83 c2 01             	add    $0x1,%edx
f0103ae1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0103ae5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0103ae7:	eb bc                	jmp    f0103aa5 <strtol+0x72>
f0103ae9:	89 d8                	mov    %ebx,%eax
f0103aeb:	eb 02                	jmp    f0103aef <strtol+0xbc>
f0103aed:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0103aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103af3:	74 05                	je     f0103afa <strtol+0xc7>
		*endptr = (char *) s;
f0103af5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103af8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103afa:	f7 d8                	neg    %eax
f0103afc:	85 ff                	test   %edi,%edi
f0103afe:	0f 44 c3             	cmove  %ebx,%eax
}
f0103b01:	5b                   	pop    %ebx
f0103b02:	5e                   	pop    %esi
f0103b03:	5f                   	pop    %edi
f0103b04:	5d                   	pop    %ebp
f0103b05:	c3                   	ret    
f0103b06:	66 90                	xchg   %ax,%ax
f0103b08:	66 90                	xchg   %ax,%ax
f0103b0a:	66 90                	xchg   %ax,%ax
f0103b0c:	66 90                	xchg   %ax,%ax
f0103b0e:	66 90                	xchg   %ax,%ax

f0103b10 <__udivdi3>:
f0103b10:	55                   	push   %ebp
f0103b11:	57                   	push   %edi
f0103b12:	56                   	push   %esi
f0103b13:	83 ec 0c             	sub    $0xc,%esp
f0103b16:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103b1a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0103b1e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0103b22:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103b26:	85 c0                	test   %eax,%eax
f0103b28:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b2c:	89 ea                	mov    %ebp,%edx
f0103b2e:	89 0c 24             	mov    %ecx,(%esp)
f0103b31:	75 2d                	jne    f0103b60 <__udivdi3+0x50>
f0103b33:	39 e9                	cmp    %ebp,%ecx
f0103b35:	77 61                	ja     f0103b98 <__udivdi3+0x88>
f0103b37:	85 c9                	test   %ecx,%ecx
f0103b39:	89 ce                	mov    %ecx,%esi
f0103b3b:	75 0b                	jne    f0103b48 <__udivdi3+0x38>
f0103b3d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b42:	31 d2                	xor    %edx,%edx
f0103b44:	f7 f1                	div    %ecx
f0103b46:	89 c6                	mov    %eax,%esi
f0103b48:	31 d2                	xor    %edx,%edx
f0103b4a:	89 e8                	mov    %ebp,%eax
f0103b4c:	f7 f6                	div    %esi
f0103b4e:	89 c5                	mov    %eax,%ebp
f0103b50:	89 f8                	mov    %edi,%eax
f0103b52:	f7 f6                	div    %esi
f0103b54:	89 ea                	mov    %ebp,%edx
f0103b56:	83 c4 0c             	add    $0xc,%esp
f0103b59:	5e                   	pop    %esi
f0103b5a:	5f                   	pop    %edi
f0103b5b:	5d                   	pop    %ebp
f0103b5c:	c3                   	ret    
f0103b5d:	8d 76 00             	lea    0x0(%esi),%esi
f0103b60:	39 e8                	cmp    %ebp,%eax
f0103b62:	77 24                	ja     f0103b88 <__udivdi3+0x78>
f0103b64:	0f bd e8             	bsr    %eax,%ebp
f0103b67:	83 f5 1f             	xor    $0x1f,%ebp
f0103b6a:	75 3c                	jne    f0103ba8 <__udivdi3+0x98>
f0103b6c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103b70:	39 34 24             	cmp    %esi,(%esp)
f0103b73:	0f 86 9f 00 00 00    	jbe    f0103c18 <__udivdi3+0x108>
f0103b79:	39 d0                	cmp    %edx,%eax
f0103b7b:	0f 82 97 00 00 00    	jb     f0103c18 <__udivdi3+0x108>
f0103b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103b88:	31 d2                	xor    %edx,%edx
f0103b8a:	31 c0                	xor    %eax,%eax
f0103b8c:	83 c4 0c             	add    $0xc,%esp
f0103b8f:	5e                   	pop    %esi
f0103b90:	5f                   	pop    %edi
f0103b91:	5d                   	pop    %ebp
f0103b92:	c3                   	ret    
f0103b93:	90                   	nop
f0103b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b98:	89 f8                	mov    %edi,%eax
f0103b9a:	f7 f1                	div    %ecx
f0103b9c:	31 d2                	xor    %edx,%edx
f0103b9e:	83 c4 0c             	add    $0xc,%esp
f0103ba1:	5e                   	pop    %esi
f0103ba2:	5f                   	pop    %edi
f0103ba3:	5d                   	pop    %ebp
f0103ba4:	c3                   	ret    
f0103ba5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ba8:	89 e9                	mov    %ebp,%ecx
f0103baa:	8b 3c 24             	mov    (%esp),%edi
f0103bad:	d3 e0                	shl    %cl,%eax
f0103baf:	89 c6                	mov    %eax,%esi
f0103bb1:	b8 20 00 00 00       	mov    $0x20,%eax
f0103bb6:	29 e8                	sub    %ebp,%eax
f0103bb8:	89 c1                	mov    %eax,%ecx
f0103bba:	d3 ef                	shr    %cl,%edi
f0103bbc:	89 e9                	mov    %ebp,%ecx
f0103bbe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103bc2:	8b 3c 24             	mov    (%esp),%edi
f0103bc5:	09 74 24 08          	or     %esi,0x8(%esp)
f0103bc9:	89 d6                	mov    %edx,%esi
f0103bcb:	d3 e7                	shl    %cl,%edi
f0103bcd:	89 c1                	mov    %eax,%ecx
f0103bcf:	89 3c 24             	mov    %edi,(%esp)
f0103bd2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103bd6:	d3 ee                	shr    %cl,%esi
f0103bd8:	89 e9                	mov    %ebp,%ecx
f0103bda:	d3 e2                	shl    %cl,%edx
f0103bdc:	89 c1                	mov    %eax,%ecx
f0103bde:	d3 ef                	shr    %cl,%edi
f0103be0:	09 d7                	or     %edx,%edi
f0103be2:	89 f2                	mov    %esi,%edx
f0103be4:	89 f8                	mov    %edi,%eax
f0103be6:	f7 74 24 08          	divl   0x8(%esp)
f0103bea:	89 d6                	mov    %edx,%esi
f0103bec:	89 c7                	mov    %eax,%edi
f0103bee:	f7 24 24             	mull   (%esp)
f0103bf1:	39 d6                	cmp    %edx,%esi
f0103bf3:	89 14 24             	mov    %edx,(%esp)
f0103bf6:	72 30                	jb     f0103c28 <__udivdi3+0x118>
f0103bf8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103bfc:	89 e9                	mov    %ebp,%ecx
f0103bfe:	d3 e2                	shl    %cl,%edx
f0103c00:	39 c2                	cmp    %eax,%edx
f0103c02:	73 05                	jae    f0103c09 <__udivdi3+0xf9>
f0103c04:	3b 34 24             	cmp    (%esp),%esi
f0103c07:	74 1f                	je     f0103c28 <__udivdi3+0x118>
f0103c09:	89 f8                	mov    %edi,%eax
f0103c0b:	31 d2                	xor    %edx,%edx
f0103c0d:	e9 7a ff ff ff       	jmp    f0103b8c <__udivdi3+0x7c>
f0103c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103c18:	31 d2                	xor    %edx,%edx
f0103c1a:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c1f:	e9 68 ff ff ff       	jmp    f0103b8c <__udivdi3+0x7c>
f0103c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103c28:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103c2b:	31 d2                	xor    %edx,%edx
f0103c2d:	83 c4 0c             	add    $0xc,%esp
f0103c30:	5e                   	pop    %esi
f0103c31:	5f                   	pop    %edi
f0103c32:	5d                   	pop    %ebp
f0103c33:	c3                   	ret    
f0103c34:	66 90                	xchg   %ax,%ax
f0103c36:	66 90                	xchg   %ax,%ax
f0103c38:	66 90                	xchg   %ax,%ax
f0103c3a:	66 90                	xchg   %ax,%ax
f0103c3c:	66 90                	xchg   %ax,%ax
f0103c3e:	66 90                	xchg   %ax,%ax

f0103c40 <__umoddi3>:
f0103c40:	55                   	push   %ebp
f0103c41:	57                   	push   %edi
f0103c42:	56                   	push   %esi
f0103c43:	83 ec 14             	sub    $0x14,%esp
f0103c46:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103c4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103c4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0103c52:	89 c7                	mov    %eax,%edi
f0103c54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c58:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103c5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103c60:	89 34 24             	mov    %esi,(%esp)
f0103c63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103c67:	85 c0                	test   %eax,%eax
f0103c69:	89 c2                	mov    %eax,%edx
f0103c6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103c6f:	75 17                	jne    f0103c88 <__umoddi3+0x48>
f0103c71:	39 fe                	cmp    %edi,%esi
f0103c73:	76 4b                	jbe    f0103cc0 <__umoddi3+0x80>
f0103c75:	89 c8                	mov    %ecx,%eax
f0103c77:	89 fa                	mov    %edi,%edx
f0103c79:	f7 f6                	div    %esi
f0103c7b:	89 d0                	mov    %edx,%eax
f0103c7d:	31 d2                	xor    %edx,%edx
f0103c7f:	83 c4 14             	add    $0x14,%esp
f0103c82:	5e                   	pop    %esi
f0103c83:	5f                   	pop    %edi
f0103c84:	5d                   	pop    %ebp
f0103c85:	c3                   	ret    
f0103c86:	66 90                	xchg   %ax,%ax
f0103c88:	39 f8                	cmp    %edi,%eax
f0103c8a:	77 54                	ja     f0103ce0 <__umoddi3+0xa0>
f0103c8c:	0f bd e8             	bsr    %eax,%ebp
f0103c8f:	83 f5 1f             	xor    $0x1f,%ebp
f0103c92:	75 5c                	jne    f0103cf0 <__umoddi3+0xb0>
f0103c94:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103c98:	39 3c 24             	cmp    %edi,(%esp)
f0103c9b:	0f 87 e7 00 00 00    	ja     f0103d88 <__umoddi3+0x148>
f0103ca1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103ca5:	29 f1                	sub    %esi,%ecx
f0103ca7:	19 c7                	sbb    %eax,%edi
f0103ca9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103cad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103cb1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103cb5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103cb9:	83 c4 14             	add    $0x14,%esp
f0103cbc:	5e                   	pop    %esi
f0103cbd:	5f                   	pop    %edi
f0103cbe:	5d                   	pop    %ebp
f0103cbf:	c3                   	ret    
f0103cc0:	85 f6                	test   %esi,%esi
f0103cc2:	89 f5                	mov    %esi,%ebp
f0103cc4:	75 0b                	jne    f0103cd1 <__umoddi3+0x91>
f0103cc6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ccb:	31 d2                	xor    %edx,%edx
f0103ccd:	f7 f6                	div    %esi
f0103ccf:	89 c5                	mov    %eax,%ebp
f0103cd1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103cd5:	31 d2                	xor    %edx,%edx
f0103cd7:	f7 f5                	div    %ebp
f0103cd9:	89 c8                	mov    %ecx,%eax
f0103cdb:	f7 f5                	div    %ebp
f0103cdd:	eb 9c                	jmp    f0103c7b <__umoddi3+0x3b>
f0103cdf:	90                   	nop
f0103ce0:	89 c8                	mov    %ecx,%eax
f0103ce2:	89 fa                	mov    %edi,%edx
f0103ce4:	83 c4 14             	add    $0x14,%esp
f0103ce7:	5e                   	pop    %esi
f0103ce8:	5f                   	pop    %edi
f0103ce9:	5d                   	pop    %ebp
f0103cea:	c3                   	ret    
f0103ceb:	90                   	nop
f0103cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103cf0:	8b 04 24             	mov    (%esp),%eax
f0103cf3:	be 20 00 00 00       	mov    $0x20,%esi
f0103cf8:	89 e9                	mov    %ebp,%ecx
f0103cfa:	29 ee                	sub    %ebp,%esi
f0103cfc:	d3 e2                	shl    %cl,%edx
f0103cfe:	89 f1                	mov    %esi,%ecx
f0103d00:	d3 e8                	shr    %cl,%eax
f0103d02:	89 e9                	mov    %ebp,%ecx
f0103d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d08:	8b 04 24             	mov    (%esp),%eax
f0103d0b:	09 54 24 04          	or     %edx,0x4(%esp)
f0103d0f:	89 fa                	mov    %edi,%edx
f0103d11:	d3 e0                	shl    %cl,%eax
f0103d13:	89 f1                	mov    %esi,%ecx
f0103d15:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d19:	8b 44 24 10          	mov    0x10(%esp),%eax
f0103d1d:	d3 ea                	shr    %cl,%edx
f0103d1f:	89 e9                	mov    %ebp,%ecx
f0103d21:	d3 e7                	shl    %cl,%edi
f0103d23:	89 f1                	mov    %esi,%ecx
f0103d25:	d3 e8                	shr    %cl,%eax
f0103d27:	89 e9                	mov    %ebp,%ecx
f0103d29:	09 f8                	or     %edi,%eax
f0103d2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0103d2f:	f7 74 24 04          	divl   0x4(%esp)
f0103d33:	d3 e7                	shl    %cl,%edi
f0103d35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103d39:	89 d7                	mov    %edx,%edi
f0103d3b:	f7 64 24 08          	mull   0x8(%esp)
f0103d3f:	39 d7                	cmp    %edx,%edi
f0103d41:	89 c1                	mov    %eax,%ecx
f0103d43:	89 14 24             	mov    %edx,(%esp)
f0103d46:	72 2c                	jb     f0103d74 <__umoddi3+0x134>
f0103d48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0103d4c:	72 22                	jb     f0103d70 <__umoddi3+0x130>
f0103d4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103d52:	29 c8                	sub    %ecx,%eax
f0103d54:	19 d7                	sbb    %edx,%edi
f0103d56:	89 e9                	mov    %ebp,%ecx
f0103d58:	89 fa                	mov    %edi,%edx
f0103d5a:	d3 e8                	shr    %cl,%eax
f0103d5c:	89 f1                	mov    %esi,%ecx
f0103d5e:	d3 e2                	shl    %cl,%edx
f0103d60:	89 e9                	mov    %ebp,%ecx
f0103d62:	d3 ef                	shr    %cl,%edi
f0103d64:	09 d0                	or     %edx,%eax
f0103d66:	89 fa                	mov    %edi,%edx
f0103d68:	83 c4 14             	add    $0x14,%esp
f0103d6b:	5e                   	pop    %esi
f0103d6c:	5f                   	pop    %edi
f0103d6d:	5d                   	pop    %ebp
f0103d6e:	c3                   	ret    
f0103d6f:	90                   	nop
f0103d70:	39 d7                	cmp    %edx,%edi
f0103d72:	75 da                	jne    f0103d4e <__umoddi3+0x10e>
f0103d74:	8b 14 24             	mov    (%esp),%edx
f0103d77:	89 c1                	mov    %eax,%ecx
f0103d79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0103d7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0103d81:	eb cb                	jmp    f0103d4e <__umoddi3+0x10e>
f0103d83:	90                   	nop
f0103d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103d88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0103d8c:	0f 82 0f ff ff ff    	jb     f0103ca1 <__umoddi3+0x61>
f0103d92:	e9 1a ff ff ff       	jmp    f0103cb1 <__umoddi3+0x71>
