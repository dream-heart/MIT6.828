
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
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 30 11 f0       	mov    $0xf0113000,%esp

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
f0100046:	b8 70 59 11 f0       	mov    $0xf0115970,%eax
f010004b:	2d 00 53 11 f0       	sub    $0xf0115300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 53 11 f0 	movl   $0xf0115300,(%esp)
f0100063:	e8 df 27 00 00       	call   f0102847 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 00 2d 10 f0 	movl   $0xf0102d00,(%esp)
f010007c:	e8 75 1c 00 00       	call   f0101cf6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 d1 0e 00 00       	call   f0100f57 <mem_init>

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
f010009f:	83 3d 60 59 11 f0 00 	cmpl   $0x0,0xf0115960
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 59 11 f0    	mov    %esi,0xf0115960

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
f01000c1:	c7 04 24 1b 2d 10 f0 	movl   $0xf0102d1b,(%esp)
f01000c8:	e8 29 1c 00 00       	call   f0101cf6 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 ea 1b 00 00       	call   f0101cc3 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 57 2d 10 f0 	movl   $0xf0102d57,(%esp)
f01000e0:	e8 11 1c 00 00       	call   f0101cf6 <cprintf>
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
f010010b:	c7 04 24 33 2d 10 f0 	movl   $0xf0102d33,(%esp)
f0100112:	e8 df 1b 00 00       	call   f0101cf6 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 9d 1b 00 00       	call   f0101cc3 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 57 2d 10 f0 	movl   $0xf0102d57,(%esp)
f010012d:	e8 c4 1b 00 00       	call   f0101cf6 <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    
	...

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
f010016b:	a1 24 55 11 f0       	mov    0xf0115524,%eax
f0100170:	8d 48 01             	lea    0x1(%eax),%ecx
f0100173:	89 0d 24 55 11 f0    	mov    %ecx,0xf0115524
f0100179:	88 90 20 53 11 f0    	mov    %dl,-0xfeeace0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010017f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100185:	75 0a                	jne    f0100191 <cons_intr+0x35>
			cons.wpos = 0;
f0100187:	c7 05 24 55 11 f0 00 	movl   $0x0,0xf0115524
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
f01001b7:	83 0d 00 53 11 f0 40 	orl    $0x40,0xf0115300
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
f01001cf:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f01001d5:	89 cb                	mov    %ecx,%ebx
f01001d7:	83 e3 40             	and    $0x40,%ebx
f01001da:	83 e0 7f             	and    $0x7f,%eax
f01001dd:	85 db                	test   %ebx,%ebx
f01001df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e2:	0f b6 d2             	movzbl %dl,%edx
f01001e5:	0f b6 82 a0 2e 10 f0 	movzbl -0xfefd160(%edx),%eax
f01001ec:	83 c8 40             	or     $0x40,%eax
f01001ef:	0f b6 c0             	movzbl %al,%eax
f01001f2:	f7 d0                	not    %eax
f01001f4:	21 c1                	and    %eax,%ecx
f01001f6:	89 0d 00 53 11 f0    	mov    %ecx,0xf0115300
		return 0;
f01001fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100201:	e9 9d 00 00 00       	jmp    f01002a3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100206:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f010020c:	f6 c1 40             	test   $0x40,%cl
f010020f:	74 0e                	je     f010021f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100211:	83 c8 80             	or     $0xffffff80,%eax
f0100214:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100216:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100219:	89 0d 00 53 11 f0    	mov    %ecx,0xf0115300
	}

	shift |= shiftcode[data];
f010021f:	0f b6 d2             	movzbl %dl,%edx
f0100222:	0f b6 82 a0 2e 10 f0 	movzbl -0xfefd160(%edx),%eax
f0100229:	0b 05 00 53 11 f0    	or     0xf0115300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a a0 2d 10 f0 	movzbl -0xfefd260(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 53 11 f0       	mov    %eax,0xf0115300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 80 2d 10 f0 	mov    -0xfefd280(,%ecx,4),%ecx
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
f0100282:	c7 04 24 4d 2d 10 f0 	movl   $0xf0102d4d,(%esp)
f0100289:	e8 68 1a 00 00       	call   f0101cf6 <cprintf>
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
f010035c:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f0100363:	66 85 c0             	test   %ax,%ax
f0100366:	0f 84 e5 00 00 00    	je     f0100451 <cons_putc+0x1a8>
			crt_pos--;
f010036c:	83 e8 01             	sub    $0x1,%eax
f010036f:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100375:	0f b7 c0             	movzwl %ax,%eax
f0100378:	66 81 e7 00 ff       	and    $0xff00,%di
f010037d:	83 cf 20             	or     $0x20,%edi
f0100380:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f0100386:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038a:	eb 78                	jmp    f0100404 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038c:	66 83 05 28 55 11 f0 	addw   $0x50,0xf0115528
f0100393:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100394:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f010039b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a1:	c1 e8 16             	shr    $0x16,%eax
f01003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a7:	c1 e0 04             	shl    $0x4,%eax
f01003aa:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
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
f01003e6:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f01003ed:	8d 50 01             	lea    0x1(%eax),%edx
f01003f0:	66 89 15 28 55 11 f0 	mov    %dx,0xf0115528
f01003f7:	0f b7 c0             	movzwl %ax,%eax
f01003fa:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f0100400:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100404:	66 81 3d 28 55 11 f0 	cmpw   $0x7cf,0xf0115528
f010040b:	cf 07 
f010040d:	76 42                	jbe    f0100451 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040f:	a1 2c 55 11 f0       	mov    0xf011552c,%eax
f0100414:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010041b:	00 
f010041c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100422:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100426:	89 04 24             	mov    %eax,(%esp)
f0100429:	e8 66 24 00 00       	call   f0102894 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042e:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
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
f0100449:	66 83 2d 28 55 11 f0 	subw   $0x50,0xf0115528
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 55 11 f0    	mov    0xf0115530,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 55 11 f0 	movzwl 0xf0115528,%ebx
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
f0100487:	80 3d 34 55 11 f0 00 	cmpb   $0x0,0xf0115534
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
f01004c5:	a1 20 55 11 f0       	mov    0xf0115520,%eax
f01004ca:	3b 05 24 55 11 f0    	cmp    0xf0115524,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 55 11 f0    	mov    %edx,0xf0115520
f01004db:	0f b6 88 20 53 11 f0 	movzbl -0xfeeace0(%eax),%ecx
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
f01004ec:	c7 05 20 55 11 f0 00 	movl   $0x0,0xf0115520
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
f0100525:	c7 05 30 55 11 f0 b4 	movl   $0x3b4,0xf0115530
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
f010053d:	c7 05 30 55 11 f0 d4 	movl   $0x3d4,0xf0115530
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
f010054c:	8b 0d 30 55 11 f0    	mov    0xf0115530,%ecx
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
f0100571:	89 3d 2c 55 11 f0    	mov    %edi,0xf011552c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100577:	0f b6 d8             	movzbl %al,%ebx
f010057a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057c:	66 89 35 28 55 11 f0 	mov    %si,0xf0115528
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
f01005cd:	88 0d 34 55 11 f0    	mov    %cl,0xf0115534
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
f01005dd:	c7 04 24 59 2d 10 f0 	movl   $0xf0102d59,(%esp)
f01005e4:	e8 0d 17 00 00       	call   f0101cf6 <cprintf>
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
f010061c:	00 00                	add    %al,(%eax)
	...

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
f0100626:	c7 44 24 08 a0 2f 10 	movl   $0xf0102fa0,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 be 2f 10 	movl   $0xf0102fbe,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 c3 2f 10 f0 	movl   $0xf0102fc3,(%esp)
f010063d:	e8 b4 16 00 00       	call   f0101cf6 <cprintf>
f0100642:	c7 44 24 08 60 30 10 	movl   $0xf0103060,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 cc 2f 10 	movl   $0xf0102fcc,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 c3 2f 10 f0 	movl   $0xf0102fc3,(%esp)
f0100659:	e8 98 16 00 00       	call   f0101cf6 <cprintf>
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
f010066b:	c7 04 24 d5 2f 10 f0 	movl   $0xf0102fd5,(%esp)
f0100672:	e8 7f 16 00 00       	call   f0101cf6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 88 30 10 f0 	movl   $0xf0103088,(%esp)
f0100686:	e8 6b 16 00 00       	call   f0101cf6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 b0 30 10 f0 	movl   $0xf01030b0,(%esp)
f01006a2:	e8 4f 16 00 00       	call   f0101cf6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 f5 2c 10 	movl   $0x102cf5,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 f5 2c 10 	movl   $0xf0102cf5,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 d4 30 10 f0 	movl   $0xf01030d4,(%esp)
f01006be:	e8 33 16 00 00       	call   f0101cf6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 53 11 	movl   $0x115300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 53 11 	movl   $0xf0115300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 f8 30 10 f0 	movl   $0xf01030f8,(%esp)
f01006da:	e8 17 16 00 00       	call   f0101cf6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 59 11 	movl   $0x115970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 59 11 	movl   $0xf0115970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 1c 31 10 f0 	movl   $0xf010311c,(%esp)
f01006f6:	e8 fb 15 00 00       	call   f0101cf6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006fb:	b8 6f 5d 11 f0       	mov    $0xf0115d6f,%eax
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
f010071c:	c7 04 24 40 31 10 f0 	movl   $0xf0103140,(%esp)
f0100723:	e8 ce 15 00 00       	call   f0101cf6 <cprintf>
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
f010075e:	e8 8a 16 00 00       	call   f0101ded <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 ee 2f 10 f0 	movl   $0xf0102fee,(%esp)
f0100775:	e8 7c 15 00 00       	call   f0101cf6 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 09 30 10 f0 	movl   $0xf0103009,(%esp)
f010078a:	e8 67 15 00 00       	call   f0101cf6 <cprintf>
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
f0100796:	c7 04 24 57 2d 10 f0 	movl   $0xf0102d57,(%esp)
f010079d:	e8 54 15 00 00       	call   f0101cf6 <cprintf>
			
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
f01007c8:	c7 04 24 10 30 10 f0 	movl   $0xf0103010,(%esp)
f01007cf:	e8 22 15 00 00       	call   f0101cf6 <cprintf>
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
f01007fa:	c7 04 24 6c 31 10 f0 	movl   $0xf010316c,(%esp)
f0100801:	e8 f0 14 00 00       	call   f0101cf6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 90 31 10 f0 	movl   $0xf0103190,(%esp)
f010080d:	e8 e4 14 00 00       	call   f0101cf6 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 21 30 10 f0 	movl   $0xf0103021,(%esp)
f0100819:	e8 d2 1d 00 00       	call   f01025f0 <readline>
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
f010084a:	c7 04 24 25 30 10 f0 	movl   $0xf0103025,(%esp)
f0100851:	e8 b4 1f 00 00       	call   f010280a <strchr>
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
f010086c:	c7 04 24 2a 30 10 f0 	movl   $0xf010302a,(%esp)
f0100873:	e8 7e 14 00 00       	call   f0101cf6 <cprintf>
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
f0100894:	c7 04 24 25 30 10 f0 	movl   $0xf0103025,(%esp)
f010089b:	e8 6a 1f 00 00       	call   f010280a <strchr>
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
f01008b6:	c7 44 24 04 be 2f 10 	movl   $0xf0102fbe,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 e3 1e 00 00       	call   f01027ac <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 cc 2f 10 	movl   $0xf0102fcc,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 cc 1e 00 00       	call   f01027ac <strcmp>
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
f0100903:	ff 14 85 c0 31 10 f0 	call   *-0xfefce40(,%eax,4)


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
f010091a:	c7 04 24 47 30 10 f0 	movl   $0xf0103047,(%esp)
f0100921:	e8 d0 13 00 00       	call   f0101cf6 <cprintf>
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
	...

f0100934 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100934:	55                   	push   %ebp
f0100935:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100937:	83 3d 3c 55 11 f0 00 	cmpl   $0x0,0xf011553c
f010093e:	75 11                	jne    f0100951 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f0100940:	ba 6f 69 11 f0       	mov    $0xf011696f,%edx
f0100945:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094b:	89 15 3c 55 11 f0    	mov    %edx,0xf011553c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
		return nextfree;
f0100951:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100957:	85 c0                	test   %eax,%eax
f0100959:	74 17                	je     f0100972 <boot_alloc+0x3e>
		return nextfree;
	result = nextfree;
f010095b:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100961:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	a3 3c 55 11 f0       	mov    %eax,0xf011553c
	
	// return the head address of the alloc pages;
	return result;
}
f0100972:	89 d0                	mov    %edx,%eax
f0100974:	5d                   	pop    %ebp
f0100975:	c3                   	ret    

f0100976 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100976:	55                   	push   %ebp
f0100977:	89 e5                	mov    %esp,%ebp
f0100979:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010097c:	89 d1                	mov    %edx,%ecx
f010097e:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100981:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100989:	f6 c1 01             	test   $0x1,%cl
f010098c:	74 57                	je     f01009e5 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010098e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100994:	89 c8                	mov    %ecx,%eax
f0100996:	c1 e8 0c             	shr    $0xc,%eax
f0100999:	3b 05 64 59 11 f0    	cmp    0xf0115964,%eax
f010099f:	72 20                	jb     f01009c1 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009a1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01009a5:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f01009ac:	f0 
f01009ad:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f01009b4:	00 
f01009b5:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01009bc:	e8 d3 f6 ff ff       	call   f0100094 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01009c1:	c1 ea 0c             	shr    $0xc,%edx
f01009c4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009ca:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01009d1:	89 c2                	mov    %eax,%edx
f01009d3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009db:	85 d2                	test   %edx,%edx
f01009dd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009e2:	0f 44 c2             	cmove  %edx,%eax
}
f01009e5:	c9                   	leave  
f01009e6:	c3                   	ret    

f01009e7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009e7:	55                   	push   %ebp
f01009e8:	89 e5                	mov    %esp,%ebp
f01009ea:	83 ec 18             	sub    $0x18,%esp
f01009ed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009f0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01009f3:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009f5:	89 04 24             	mov    %eax,(%esp)
f01009f8:	e8 89 12 00 00       	call   f0101c86 <mc146818_read>
f01009fd:	89 c6                	mov    %eax,%esi
f01009ff:	83 c3 01             	add    $0x1,%ebx
f0100a02:	89 1c 24             	mov    %ebx,(%esp)
f0100a05:	e8 7c 12 00 00       	call   f0101c86 <mc146818_read>
f0100a0a:	c1 e0 08             	shl    $0x8,%eax
f0100a0d:	09 f0                	or     %esi,%eax
}
f0100a0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a12:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a15:	89 ec                	mov    %ebp,%esp
f0100a17:	5d                   	pop    %ebp
f0100a18:	c3                   	ret    

f0100a19 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a19:	55                   	push   %ebp
f0100a1a:	89 e5                	mov    %esp,%ebp
f0100a1c:	57                   	push   %edi
f0100a1d:	56                   	push   %esi
f0100a1e:	53                   	push   %ebx
f0100a1f:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a22:	3c 01                	cmp    $0x1,%al
f0100a24:	19 f6                	sbb    %esi,%esi
f0100a26:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100a2c:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100a2f:	8b 15 40 55 11 f0    	mov    0xf0115540,%edx
f0100a35:	85 d2                	test   %edx,%edx
f0100a37:	75 1c                	jne    f0100a55 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100a39:	c7 44 24 08 f4 31 10 	movl   $0xf01031f4,0x8(%esp)
f0100a40:	f0 
f0100a41:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
f0100a48:	00 
f0100a49:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100a50:	e8 3f f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0100a55:	84 c0                	test   %al,%al
f0100a57:	74 4b                	je     f0100aa4 <check_page_free_list+0x8b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a59:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100a5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a5f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a62:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a65:	89 d0                	mov    %edx,%eax
f0100a67:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f0100a6d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a70:	c1 e8 16             	shr    $0x16,%eax
f0100a73:	39 c6                	cmp    %eax,%esi
f0100a75:	0f 96 c0             	setbe  %al
f0100a78:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100a7b:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100a7f:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a81:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a85:	8b 12                	mov    (%edx),%edx
f0100a87:	85 d2                	test   %edx,%edx
f0100a89:	75 da                	jne    f0100a65 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a94:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100a9a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a9f:	a3 40 55 11 f0       	mov    %eax,0xf0115540
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aa4:	8b 1d 40 55 11 f0    	mov    0xf0115540,%ebx
f0100aaa:	eb 63                	jmp    f0100b0f <check_page_free_list+0xf6>
f0100aac:	89 d8                	mov    %ebx,%eax
f0100aae:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f0100ab4:	c1 f8 03             	sar    $0x3,%eax
f0100ab7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aba:	89 c2                	mov    %eax,%edx
f0100abc:	c1 ea 16             	shr    $0x16,%edx
f0100abf:	39 d6                	cmp    %edx,%esi
f0100ac1:	76 4a                	jbe    f0100b0d <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac3:	89 c2                	mov    %eax,%edx
f0100ac5:	c1 ea 0c             	shr    $0xc,%edx
f0100ac8:	3b 15 64 59 11 f0    	cmp    0xf0115964,%edx
f0100ace:	72 20                	jb     f0100af0 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ad4:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f0100adb:	f0 
f0100adc:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ae3:	00 
f0100ae4:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f0100aeb:	e8 a4 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100af7:	00 
f0100af8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100aff:	00 
	return (void *)(pa + KERNBASE);
f0100b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b05:	89 04 24             	mov    %eax,(%esp)
f0100b08:	e8 3a 1d 00 00       	call   f0102847 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b0d:	8b 1b                	mov    (%ebx),%ebx
f0100b0f:	85 db                	test   %ebx,%ebx
f0100b11:	75 99                	jne    f0100aac <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b18:	e8 17 fe ff ff       	call   f0100934 <boot_alloc>
f0100b1d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b20:	8b 15 40 55 11 f0    	mov    0xf0115540,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b26:	8b 0d 6c 59 11 f0    	mov    0xf011596c,%ecx
		assert(pp < pages + npages);
f0100b2c:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f0100b31:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b34:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b3a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b3d:	be 00 00 00 00       	mov    $0x0,%esi
f0100b42:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b45:	e9 97 01 00 00       	jmp    f0100ce1 <check_page_free_list+0x2c8>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b4a:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100b4d:	73 24                	jae    f0100b73 <check_page_free_list+0x15a>
f0100b4f:	c7 44 24 0c 2e 36 10 	movl   $0xf010362e,0xc(%esp)
f0100b56:	f0 
f0100b57:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100b5e:	f0 
f0100b5f:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100b66:	00 
f0100b67:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100b6e:	e8 21 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b73:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b76:	72 24                	jb     f0100b9c <check_page_free_list+0x183>
f0100b78:	c7 44 24 0c 4f 36 10 	movl   $0xf010364f,0xc(%esp)
f0100b7f:	f0 
f0100b80:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100b87:	f0 
f0100b88:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0100b8f:	00 
f0100b90:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100b97:	e8 f8 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b9c:	89 d0                	mov    %edx,%eax
f0100b9e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ba1:	a8 07                	test   $0x7,%al
f0100ba3:	74 24                	je     f0100bc9 <check_page_free_list+0x1b0>
f0100ba5:	c7 44 24 0c 18 32 10 	movl   $0xf0103218,0xc(%esp)
f0100bac:	f0 
f0100bad:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100bb4:	f0 
f0100bb5:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100bbc:	00 
f0100bbd:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100bc4:	e8 cb f4 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc9:	c1 f8 03             	sar    $0x3,%eax
f0100bcc:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bcf:	85 c0                	test   %eax,%eax
f0100bd1:	75 24                	jne    f0100bf7 <check_page_free_list+0x1de>
f0100bd3:	c7 44 24 0c 63 36 10 	movl   $0xf0103663,0xc(%esp)
f0100bda:	f0 
f0100bdb:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100be2:	f0 
f0100be3:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0100bea:	00 
f0100beb:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100bf2:	e8 9d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bf7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bfc:	75 24                	jne    f0100c22 <check_page_free_list+0x209>
f0100bfe:	c7 44 24 0c 74 36 10 	movl   $0xf0103674,0xc(%esp)
f0100c05:	f0 
f0100c06:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100c0d:	f0 
f0100c0e:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0100c15:	00 
f0100c16:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100c1d:	e8 72 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c22:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c27:	75 24                	jne    f0100c4d <check_page_free_list+0x234>
f0100c29:	c7 44 24 0c 4c 32 10 	movl   $0xf010324c,0xc(%esp)
f0100c30:	f0 
f0100c31:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100c38:	f0 
f0100c39:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100c40:	00 
f0100c41:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100c48:	e8 47 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c4d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c52:	75 24                	jne    f0100c78 <check_page_free_list+0x25f>
f0100c54:	c7 44 24 0c 8d 36 10 	movl   $0xf010368d,0xc(%esp)
f0100c5b:	f0 
f0100c5c:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100c63:	f0 
f0100c64:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100c6b:	00 
f0100c6c:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100c73:	e8 1c f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c78:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c7d:	76 58                	jbe    f0100cd7 <check_page_free_list+0x2be>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c7f:	89 c1                	mov    %eax,%ecx
f0100c81:	c1 e9 0c             	shr    $0xc,%ecx
f0100c84:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c87:	77 20                	ja     f0100ca9 <check_page_free_list+0x290>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c8d:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f0100c94:	f0 
f0100c95:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c9c:	00 
f0100c9d:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f0100ca4:	e8 eb f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100ca9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cae:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100cb1:	76 29                	jbe    f0100cdc <check_page_free_list+0x2c3>
f0100cb3:	c7 44 24 0c 70 32 10 	movl   $0xf0103270,0xc(%esp)
f0100cba:	f0 
f0100cbb:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100cc2:	f0 
f0100cc3:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100cca:	00 
f0100ccb:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100cd2:	e8 bd f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cd7:	83 c6 01             	add    $0x1,%esi
f0100cda:	eb 03                	jmp    f0100cdf <check_page_free_list+0x2c6>
		else
			++nfree_extmem;
f0100cdc:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cdf:	8b 12                	mov    (%edx),%edx
f0100ce1:	85 d2                	test   %edx,%edx
f0100ce3:	0f 85 61 fe ff ff    	jne    f0100b4a <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ce9:	85 f6                	test   %esi,%esi
f0100ceb:	7f 24                	jg     f0100d11 <check_page_free_list+0x2f8>
f0100ced:	c7 44 24 0c a7 36 10 	movl   $0xf01036a7,0xc(%esp)
f0100cf4:	f0 
f0100cf5:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100cfc:	f0 
f0100cfd:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
f0100d04:	00 
f0100d05:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100d0c:	e8 83 f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d11:	85 db                	test   %ebx,%ebx
f0100d13:	7f 24                	jg     f0100d39 <check_page_free_list+0x320>
f0100d15:	c7 44 24 0c b9 36 10 	movl   $0xf01036b9,0xc(%esp)
f0100d1c:	f0 
f0100d1d:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0100d24:	f0 
f0100d25:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0100d2c:	00 
f0100d2d:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100d34:	e8 5b f3 ff ff       	call   f0100094 <_panic>
}
f0100d39:	83 c4 4c             	add    $0x4c,%esp
f0100d3c:	5b                   	pop    %ebx
f0100d3d:	5e                   	pop    %esi
f0100d3e:	5f                   	pop    %edi
f0100d3f:	5d                   	pop    %ebp
f0100d40:	c3                   	ret    

f0100d41 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d41:	55                   	push   %ebp
f0100d42:	89 e5                	mov    %esp,%ebp
f0100d44:	56                   	push   %esi
f0100d45:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d46:	be 00 00 00 00       	mov    $0x0,%esi
f0100d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d50:	e9 c5 00 00 00       	jmp    f0100e1a <page_init+0xd9>
		if(i == 0)
f0100d55:	85 db                	test   %ebx,%ebx
f0100d57:	75 16                	jne    f0100d6f <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100d59:	a1 6c 59 11 f0       	mov    0xf011596c,%eax
f0100d5e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d6a:	e9 a5 00 00 00       	jmp    f0100e14 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d6f:	3b 1d 38 55 11 f0    	cmp    0xf0115538,%ebx
f0100d75:	73 25                	jae    f0100d9c <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d77:	89 f0                	mov    %esi,%eax
f0100d79:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100d7f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d85:	8b 15 40 55 11 f0    	mov    0xf0115540,%edx
f0100d8b:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d8d:	89 f0                	mov    %esi,%eax
f0100d8f:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100d95:	a3 40 55 11 f0       	mov    %eax,0xf0115540
f0100d9a:	eb 78                	jmp    f0100e14 <page_init+0xd3>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d9c:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100da2:	83 f8 5f             	cmp    $0x5f,%eax
f0100da5:	77 16                	ja     f0100dbd <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100da7:	89 f0                	mov    %esi,%eax
f0100da9:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100daf:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100db5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100dbb:	eb 57                	jmp    f0100e14 <page_init+0xd3>
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100dbd:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100dc3:	76 2c                	jbe    f0100df1 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100dc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dca:	e8 65 fb ff ff       	call   f0100934 <boot_alloc>
f0100dcf:	05 00 00 00 10       	add    $0x10000000,%eax
f0100dd4:	c1 e8 0c             	shr    $0xc,%eax
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100dd7:	39 c3                	cmp    %eax,%ebx
f0100dd9:	73 16                	jae    f0100df1 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100ddb:	89 f0                	mov    %esi,%eax
f0100ddd:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100de3:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100de9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100def:	eb 23                	jmp    f0100e14 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100df1:	89 f0                	mov    %esi,%eax
f0100df3:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100df9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dff:	8b 15 40 55 11 f0    	mov    0xf0115540,%edx
f0100e05:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100e07:	89 f0                	mov    %esi,%eax
f0100e09:	03 05 6c 59 11 f0    	add    0xf011596c,%eax
f0100e0f:	a3 40 55 11 f0       	mov    %eax,0xf0115540
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e14:	83 c3 01             	add    $0x1,%ebx
f0100e17:	83 c6 08             	add    $0x8,%esi
f0100e1a:	3b 1d 64 59 11 f0    	cmp    0xf0115964,%ebx
f0100e20:	0f 82 2f ff ff ff    	jb     f0100d55 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100e26:	5b                   	pop    %ebx
f0100e27:	5e                   	pop    %esi
f0100e28:	5d                   	pop    %ebp
f0100e29:	c3                   	ret    

f0100e2a <page_alloc>:

//apply a page, if alloc_flage==0, do not initialize the page;
//if alloc_flags==1, initialize the page and make the entire page '\0';
struct PageInfo *
page_alloc(int alloc_flags)
{	
f0100e2a:	55                   	push   %ebp
f0100e2b:	89 e5                	mov    %esp,%ebp
f0100e2d:	53                   	push   %ebx
f0100e2e:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100e31:	8b 1d 40 55 11 f0    	mov    0xf0115540,%ebx
f0100e37:	85 db                	test   %ebx,%ebx
f0100e39:	74 6b                	je     f0100ea6 <page_alloc+0x7c>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e3b:	8b 03                	mov    (%ebx),%eax
f0100e3d:	a3 40 55 11 f0       	mov    %eax,0xf0115540
		page->pp_link = NULL;
f0100e42:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if(alloc_flags & ALLOC_ZERO)
f0100e48:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e4c:	74 58                	je     f0100ea6 <page_alloc+0x7c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e4e:	89 d8                	mov    %ebx,%eax
f0100e50:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f0100e56:	c1 f8 03             	sar    $0x3,%eax
f0100e59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e5c:	89 c2                	mov    %eax,%edx
f0100e5e:	c1 ea 0c             	shr    $0xc,%edx
f0100e61:	3b 15 64 59 11 f0    	cmp    0xf0115964,%edx
f0100e67:	72 20                	jb     f0100e89 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e6d:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f0100e74:	f0 
f0100e75:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e7c:	00 
f0100e7d:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f0100e84:	e8 0b f2 ff ff       	call   f0100094 <_panic>
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
f0100e89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e90:	00 
f0100e91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e98:	00 
	return (void *)(pa + KERNBASE);
f0100e99:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e9e:	89 04 24             	mov    %eax,(%esp)
f0100ea1:	e8 a1 19 00 00       	call   f0102847 <memset>
	}

	return page;
}
f0100ea6:	89 d8                	mov    %ebx,%eax
f0100ea8:	83 c4 14             	add    $0x14,%esp
f0100eab:	5b                   	pop    %ebx
f0100eac:	5d                   	pop    %ebp
f0100ead:	c3                   	ret    

f0100eae <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100eae:	55                   	push   %ebp
f0100eaf:	89 e5                	mov    %esp,%ebp
f0100eb1:	83 ec 18             	sub    $0x18,%esp
f0100eb4:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link !=NULL)
f0100eb7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ebc:	75 05                	jne    f0100ec3 <page_free+0x15>
f0100ebe:	83 38 00             	cmpl   $0x0,(%eax)
f0100ec1:	74 1c                	je     f0100edf <page_free+0x31>
		panic("pp_ref is not 0 or the pp_link is not NULL. The page is used\n");
f0100ec3:	c7 44 24 08 b8 32 10 	movl   $0xf01032b8,0x8(%esp)
f0100eca:	f0 
f0100ecb:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100ed2:	00 
f0100ed3:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0100eda:	e8 b5 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100edf:	8b 15 40 55 11 f0    	mov    0xf0115540,%edx
f0100ee5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ee7:	a3 40 55 11 f0       	mov    %eax,0xf0115540
	return;
}
f0100eec:	c9                   	leave  
f0100eed:	c3                   	ret    

f0100eee <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100eee:	55                   	push   %ebp
f0100eef:	89 e5                	mov    %esp,%ebp
f0100ef1:	83 ec 18             	sub    $0x18,%esp
f0100ef4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100ef7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100efb:	83 ea 01             	sub    $0x1,%edx
f0100efe:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f02:	66 85 d2             	test   %dx,%dx
f0100f05:	75 08                	jne    f0100f0f <page_decref+0x21>
		page_free(pp);
f0100f07:	89 04 24             	mov    %eax,(%esp)
f0100f0a:	e8 9f ff ff ff       	call   f0100eae <page_free>
}
f0100f0f:	c9                   	leave  
f0100f10:	c3                   	ret    

f0100f11 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	//typedef uint32_t physaddr_t;
f0100f11:	55                   	push   %ebp
f0100f12:	89 e5                	mov    %esp,%ebp
f0100f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//即存储在的页表基地址是不是物理地址？
	//是物理地址，保存在cr3寄存器中。
	// Fill this function in
	//取得va的 Page Directory INDEX 的值
	//
	unsigned int pageDirIndex= (physaddr_t)(va) >> 22 & 0x3FF ;
f0100f17:	89 ca                	mov    %ecx,%edx
f0100f19:	c1 ea 16             	shr    $0x16,%edx
	
	//从Page Directory INDEX中取出对应的page table的地址
	//
	physaddr_t* pageTableBaseAddrePointer  = (physaddr_t*)  (pgdir + pageDirIndex);
f0100f1c:	c1 e2 02             	shl    $0x2,%edx
	
	//如果pageTable还没有被创建，而且create==0，则return NULL
	//地址获取失败。
	//
	
	if(pageTableBaseAddrePointer == NULL &&  create == 0)
f0100f1f:	03 55 08             	add    0x8(%ebp),%edx
f0100f22:	75 0b                	jne    f0100f2f <pgdir_walk+0x1e>
		return NULL;
f0100f24:	b8 00 00 00 00       	mov    $0x0,%eax
	
	//如果pageTable还没有被创建，而且create==0，则return NULL
	//地址获取失败。
	//
	
	if(pageTableBaseAddrePointer == NULL &&  create == 0)
f0100f29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f2d:	74 12                	je     f0100f41 <pgdir_walk+0x30>
	}
	//取出va对应的page table index
	
	unsigned int pageTableOffset = (physaddr_t ) (va) >> 12 & 0x3FF;
	
	physaddr_t pageTableAddre = (*pageTableBaseAddrePointer>>12<<12) + pageTableOffset;
f0100f2f:	8b 02                	mov    (%edx),%eax
f0100f31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		}
		**************************************/
	}
	//取出va对应的page table index
	
	unsigned int pageTableOffset = (physaddr_t ) (va) >> 12 & 0x3FF;
f0100f36:	c1 e9 0c             	shr    $0xc,%ecx
f0100f39:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	
	physaddr_t pageTableAddre = (*pageTableBaseAddrePointer>>12<<12) + pageTableOffset;
f0100f3f:	01 c8                	add    %ecx,%eax
				(physaddr_t) (vaPhyAddre) >>12<<12);
	unsigned int offset = (physaddr_t) va &0xFFF;
	vaPhyAddre = (physaddr_t *) vaPhyAddre +  offset;
	return vaPhyAddre;
	**********************************************/
}
f0100f41:	5d                   	pop    %ebp
f0100f42:	c3                   	ret    

f0100f43 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f43:	55                   	push   %ebp
f0100f44:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100f46:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f4b:	5d                   	pop    %ebp
f0100f4c:	c3                   	ret    

f0100f4d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f4d:	55                   	push   %ebp
f0100f4e:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100f50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f55:	5d                   	pop    %ebp
f0100f56:	c3                   	ret    

f0100f57 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100f57:	55                   	push   %ebp
f0100f58:	89 e5                	mov    %esp,%ebp
f0100f5a:	57                   	push   %edi
f0100f5b:	56                   	push   %esi
f0100f5c:	53                   	push   %ebx
f0100f5d:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100f60:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f65:	e8 7d fa ff ff       	call   f01009e7 <nvram_read>
f0100f6a:	c1 e0 0a             	shl    $0xa,%eax
f0100f6d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f73:	85 c0                	test   %eax,%eax
f0100f75:	0f 48 c2             	cmovs  %edx,%eax
f0100f78:	c1 f8 0c             	sar    $0xc,%eax
f0100f7b:	a3 38 55 11 f0       	mov    %eax,0xf0115538
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100f80:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f85:	e8 5d fa ff ff       	call   f01009e7 <nvram_read>
f0100f8a:	c1 e0 0a             	shl    $0xa,%eax
f0100f8d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f93:	85 c0                	test   %eax,%eax
f0100f95:	0f 48 c2             	cmovs  %edx,%eax
f0100f98:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100f9b:	85 c0                	test   %eax,%eax
f0100f9d:	74 0e                	je     f0100fad <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100f9f:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100fa5:	89 15 64 59 11 f0    	mov    %edx,0xf0115964
f0100fab:	eb 0c                	jmp    f0100fb9 <mem_init+0x62>
	else
		npages = npages_basemem;
f0100fad:	8b 15 38 55 11 f0    	mov    0xf0115538,%edx
f0100fb3:	89 15 64 59 11 f0    	mov    %edx,0xf0115964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100fb9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fbc:	c1 e8 0a             	shr    $0xa,%eax
f0100fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100fc3:	a1 38 55 11 f0       	mov    0xf0115538,%eax
f0100fc8:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fcb:	c1 e8 0a             	shr    $0xa,%eax
f0100fce:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100fd2:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f0100fd7:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fda:	c1 e8 0a             	shr    $0xa,%eax
f0100fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fe1:	c7 04 24 f8 32 10 f0 	movl   $0xf01032f8,(%esp)
f0100fe8:	e8 09 0d 00 00       	call   f0101cf6 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100fed:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100ff2:	e8 3d f9 ff ff       	call   f0100934 <boot_alloc>
f0100ff7:	a3 68 59 11 f0       	mov    %eax,0xf0115968
	memset(kern_pgdir, 0, PGSIZE);
f0100ffc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101003:	00 
f0101004:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010100b:	00 
f010100c:	89 04 24             	mov    %eax,(%esp)
f010100f:	e8 33 18 00 00       	call   f0102847 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101014:	a1 68 59 11 f0       	mov    0xf0115968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101019:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010101e:	77 20                	ja     f0101040 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101020:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101024:	c7 44 24 08 34 33 10 	movl   $0xf0103334,0x8(%esp)
f010102b:	f0 
f010102c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f0101033:	00 
f0101034:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010103b:	e8 54 f0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101040:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101046:	83 ca 05             	or     $0x5,%edx
f0101049:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f010104f:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f0101054:	c1 e0 03             	shl    $0x3,%eax
f0101057:	e8 d8 f8 ff ff       	call   f0100934 <boot_alloc>
f010105c:	a3 6c 59 11 f0       	mov    %eax,0xf011596c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f0101061:	8b 15 64 59 11 f0    	mov    0xf0115964,%edx
f0101067:	c1 e2 03             	shl    $0x3,%edx
f010106a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010106e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101075:	00 
f0101076:	89 04 24             	mov    %eax,(%esp)
f0101079:	e8 c9 17 00 00       	call   f0102847 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010107e:	e8 be fc ff ff       	call   f0100d41 <page_init>

	check_page_free_list(1);
f0101083:	b8 01 00 00 00       	mov    $0x1,%eax
f0101088:	e8 8c f9 ff ff       	call   f0100a19 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010108d:	83 3d 6c 59 11 f0 00 	cmpl   $0x0,0xf011596c
f0101094:	75 1c                	jne    f01010b2 <mem_init+0x15b>
		panic("'pages' is a null pointer!");
f0101096:	c7 44 24 08 ca 36 10 	movl   $0xf01036ca,0x8(%esp)
f010109d:	f0 
f010109e:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f01010a5:	00 
f01010a6:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01010ad:	e8 e2 ef ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010b2:	a1 40 55 11 f0       	mov    0xf0115540,%eax
f01010b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010bc:	eb 05                	jmp    f01010c3 <mem_init+0x16c>
		++nfree;
f01010be:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010c1:	8b 00                	mov    (%eax),%eax
f01010c3:	85 c0                	test   %eax,%eax
f01010c5:	75 f7                	jne    f01010be <mem_init+0x167>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010ce:	e8 57 fd ff ff       	call   f0100e2a <page_alloc>
f01010d3:	89 c6                	mov    %eax,%esi
f01010d5:	85 c0                	test   %eax,%eax
f01010d7:	75 24                	jne    f01010fd <mem_init+0x1a6>
f01010d9:	c7 44 24 0c e5 36 10 	movl   $0xf01036e5,0xc(%esp)
f01010e0:	f0 
f01010e1:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01010e8:	f0 
f01010e9:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f01010f0:	00 
f01010f1:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01010f8:	e8 97 ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01010fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101104:	e8 21 fd ff ff       	call   f0100e2a <page_alloc>
f0101109:	89 c7                	mov    %eax,%edi
f010110b:	85 c0                	test   %eax,%eax
f010110d:	75 24                	jne    f0101133 <mem_init+0x1dc>
f010110f:	c7 44 24 0c fb 36 10 	movl   $0xf01036fb,0xc(%esp)
f0101116:	f0 
f0101117:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010111e:	f0 
f010111f:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0101126:	00 
f0101127:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010112e:	e8 61 ef ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010113a:	e8 eb fc ff ff       	call   f0100e2a <page_alloc>
f010113f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101142:	85 c0                	test   %eax,%eax
f0101144:	75 24                	jne    f010116a <mem_init+0x213>
f0101146:	c7 44 24 0c 11 37 10 	movl   $0xf0103711,0xc(%esp)
f010114d:	f0 
f010114e:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101155:	f0 
f0101156:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f010115d:	00 
f010115e:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101165:	e8 2a ef ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010116a:	39 fe                	cmp    %edi,%esi
f010116c:	75 24                	jne    f0101192 <mem_init+0x23b>
f010116e:	c7 44 24 0c 27 37 10 	movl   $0xf0103727,0xc(%esp)
f0101175:	f0 
f0101176:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010117d:	f0 
f010117e:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0101185:	00 
f0101186:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010118d:	e8 02 ef ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101192:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101195:	74 05                	je     f010119c <mem_init+0x245>
f0101197:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010119a:	75 24                	jne    f01011c0 <mem_init+0x269>
f010119c:	c7 44 24 0c 58 33 10 	movl   $0xf0103358,0xc(%esp)
f01011a3:	f0 
f01011a4:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01011ab:	f0 
f01011ac:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f01011b3:	00 
f01011b4:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01011bb:	e8 d4 ee ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011c0:	8b 15 6c 59 11 f0    	mov    0xf011596c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01011c6:	a1 64 59 11 f0       	mov    0xf0115964,%eax
f01011cb:	c1 e0 0c             	shl    $0xc,%eax
f01011ce:	89 f1                	mov    %esi,%ecx
f01011d0:	29 d1                	sub    %edx,%ecx
f01011d2:	c1 f9 03             	sar    $0x3,%ecx
f01011d5:	c1 e1 0c             	shl    $0xc,%ecx
f01011d8:	39 c1                	cmp    %eax,%ecx
f01011da:	72 24                	jb     f0101200 <mem_init+0x2a9>
f01011dc:	c7 44 24 0c 39 37 10 	movl   $0xf0103739,0xc(%esp)
f01011e3:	f0 
f01011e4:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01011eb:	f0 
f01011ec:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f01011f3:	00 
f01011f4:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01011fb:	e8 94 ee ff ff       	call   f0100094 <_panic>
f0101200:	89 f9                	mov    %edi,%ecx
f0101202:	29 d1                	sub    %edx,%ecx
f0101204:	c1 f9 03             	sar    $0x3,%ecx
f0101207:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010120a:	39 c8                	cmp    %ecx,%eax
f010120c:	77 24                	ja     f0101232 <mem_init+0x2db>
f010120e:	c7 44 24 0c 56 37 10 	movl   $0xf0103756,0xc(%esp)
f0101215:	f0 
f0101216:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010121d:	f0 
f010121e:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f0101225:	00 
f0101226:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010122d:	e8 62 ee ff ff       	call   f0100094 <_panic>
f0101232:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101235:	29 d1                	sub    %edx,%ecx
f0101237:	89 ca                	mov    %ecx,%edx
f0101239:	c1 fa 03             	sar    $0x3,%edx
f010123c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010123f:	39 d0                	cmp    %edx,%eax
f0101241:	77 24                	ja     f0101267 <mem_init+0x310>
f0101243:	c7 44 24 0c 73 37 10 	movl   $0xf0103773,0xc(%esp)
f010124a:	f0 
f010124b:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101252:	f0 
f0101253:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f010125a:	00 
f010125b:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101262:	e8 2d ee ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101267:	a1 40 55 11 f0       	mov    0xf0115540,%eax
f010126c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010126f:	c7 05 40 55 11 f0 00 	movl   $0x0,0xf0115540
f0101276:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101280:	e8 a5 fb ff ff       	call   f0100e2a <page_alloc>
f0101285:	85 c0                	test   %eax,%eax
f0101287:	74 24                	je     f01012ad <mem_init+0x356>
f0101289:	c7 44 24 0c 90 37 10 	movl   $0xf0103790,0xc(%esp)
f0101290:	f0 
f0101291:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101298:	f0 
f0101299:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f01012a0:	00 
f01012a1:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01012a8:	e8 e7 ed ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01012ad:	89 34 24             	mov    %esi,(%esp)
f01012b0:	e8 f9 fb ff ff       	call   f0100eae <page_free>
	page_free(pp1);
f01012b5:	89 3c 24             	mov    %edi,(%esp)
f01012b8:	e8 f1 fb ff ff       	call   f0100eae <page_free>
	page_free(pp2);
f01012bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012c0:	89 04 24             	mov    %eax,(%esp)
f01012c3:	e8 e6 fb ff ff       	call   f0100eae <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012cf:	e8 56 fb ff ff       	call   f0100e2a <page_alloc>
f01012d4:	89 c6                	mov    %eax,%esi
f01012d6:	85 c0                	test   %eax,%eax
f01012d8:	75 24                	jne    f01012fe <mem_init+0x3a7>
f01012da:	c7 44 24 0c e5 36 10 	movl   $0xf01036e5,0xc(%esp)
f01012e1:	f0 
f01012e2:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01012e9:	f0 
f01012ea:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f01012f1:	00 
f01012f2:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01012f9:	e8 96 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101305:	e8 20 fb ff ff       	call   f0100e2a <page_alloc>
f010130a:	89 c7                	mov    %eax,%edi
f010130c:	85 c0                	test   %eax,%eax
f010130e:	75 24                	jne    f0101334 <mem_init+0x3dd>
f0101310:	c7 44 24 0c fb 36 10 	movl   $0xf01036fb,0xc(%esp)
f0101317:	f0 
f0101318:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010131f:	f0 
f0101320:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0101327:	00 
f0101328:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010132f:	e8 60 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101334:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010133b:	e8 ea fa ff ff       	call   f0100e2a <page_alloc>
f0101340:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101343:	85 c0                	test   %eax,%eax
f0101345:	75 24                	jne    f010136b <mem_init+0x414>
f0101347:	c7 44 24 0c 11 37 10 	movl   $0xf0103711,0xc(%esp)
f010134e:	f0 
f010134f:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101356:	f0 
f0101357:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f010135e:	00 
f010135f:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101366:	e8 29 ed ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010136b:	39 fe                	cmp    %edi,%esi
f010136d:	75 24                	jne    f0101393 <mem_init+0x43c>
f010136f:	c7 44 24 0c 27 37 10 	movl   $0xf0103727,0xc(%esp)
f0101376:	f0 
f0101377:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010137e:	f0 
f010137f:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101386:	00 
f0101387:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010138e:	e8 01 ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101393:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101396:	74 05                	je     f010139d <mem_init+0x446>
f0101398:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010139b:	75 24                	jne    f01013c1 <mem_init+0x46a>
f010139d:	c7 44 24 0c 58 33 10 	movl   $0xf0103358,0xc(%esp)
f01013a4:	f0 
f01013a5:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01013ac:	f0 
f01013ad:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f01013b4:	00 
f01013b5:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01013bc:	e8 d3 ec ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01013c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013c8:	e8 5d fa ff ff       	call   f0100e2a <page_alloc>
f01013cd:	85 c0                	test   %eax,%eax
f01013cf:	74 24                	je     f01013f5 <mem_init+0x49e>
f01013d1:	c7 44 24 0c 90 37 10 	movl   $0xf0103790,0xc(%esp)
f01013d8:	f0 
f01013d9:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01013e0:	f0 
f01013e1:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f01013e8:	00 
f01013e9:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01013f0:	e8 9f ec ff ff       	call   f0100094 <_panic>
f01013f5:	89 f0                	mov    %esi,%eax
f01013f7:	2b 05 6c 59 11 f0    	sub    0xf011596c,%eax
f01013fd:	c1 f8 03             	sar    $0x3,%eax
f0101400:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101403:	89 c2                	mov    %eax,%edx
f0101405:	c1 ea 0c             	shr    $0xc,%edx
f0101408:	3b 15 64 59 11 f0    	cmp    0xf0115964,%edx
f010140e:	72 20                	jb     f0101430 <mem_init+0x4d9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101410:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101414:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f010141b:	f0 
f010141c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101423:	00 
f0101424:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f010142b:	e8 64 ec ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101430:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101437:	00 
f0101438:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010143f:	00 
	return (void *)(pa + KERNBASE);
f0101440:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101445:	89 04 24             	mov    %eax,(%esp)
f0101448:	e8 fa 13 00 00       	call   f0102847 <memset>
	page_free(pp0);
f010144d:	89 34 24             	mov    %esi,(%esp)
f0101450:	e8 59 fa ff ff       	call   f0100eae <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101455:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010145c:	e8 c9 f9 ff ff       	call   f0100e2a <page_alloc>
f0101461:	85 c0                	test   %eax,%eax
f0101463:	75 24                	jne    f0101489 <mem_init+0x532>
f0101465:	c7 44 24 0c 9f 37 10 	movl   $0xf010379f,0xc(%esp)
f010146c:	f0 
f010146d:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101474:	f0 
f0101475:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f010147c:	00 
f010147d:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101484:	e8 0b ec ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101489:	39 c6                	cmp    %eax,%esi
f010148b:	74 24                	je     f01014b1 <mem_init+0x55a>
f010148d:	c7 44 24 0c bd 37 10 	movl   $0xf01037bd,0xc(%esp)
f0101494:	f0 
f0101495:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010149c:	f0 
f010149d:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f01014a4:	00 
f01014a5:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01014ac:	e8 e3 eb ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b1:	89 f2                	mov    %esi,%edx
f01014b3:	2b 15 6c 59 11 f0    	sub    0xf011596c,%edx
f01014b9:	c1 fa 03             	sar    $0x3,%edx
f01014bc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014bf:	89 d0                	mov    %edx,%eax
f01014c1:	c1 e8 0c             	shr    $0xc,%eax
f01014c4:	3b 05 64 59 11 f0    	cmp    0xf0115964,%eax
f01014ca:	72 20                	jb     f01014ec <mem_init+0x595>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01014d0:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f01014d7:	f0 
f01014d8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01014df:	00 
f01014e0:	c7 04 24 20 36 10 f0 	movl   $0xf0103620,(%esp)
f01014e7:	e8 a8 eb ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01014ec:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01014f2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014f8:	80 38 00             	cmpb   $0x0,(%eax)
f01014fb:	74 24                	je     f0101521 <mem_init+0x5ca>
f01014fd:	c7 44 24 0c cd 37 10 	movl   $0xf01037cd,0xc(%esp)
f0101504:	f0 
f0101505:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010150c:	f0 
f010150d:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0101514:	00 
f0101515:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010151c:	e8 73 eb ff ff       	call   f0100094 <_panic>
f0101521:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101524:	39 d0                	cmp    %edx,%eax
f0101526:	75 d0                	jne    f01014f8 <mem_init+0x5a1>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101528:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010152b:	89 0d 40 55 11 f0    	mov    %ecx,0xf0115540

	// free the pages we took
	page_free(pp0);
f0101531:	89 34 24             	mov    %esi,(%esp)
f0101534:	e8 75 f9 ff ff       	call   f0100eae <page_free>
	page_free(pp1);
f0101539:	89 3c 24             	mov    %edi,(%esp)
f010153c:	e8 6d f9 ff ff       	call   f0100eae <page_free>
	page_free(pp2);
f0101541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101544:	89 04 24             	mov    %eax,(%esp)
f0101547:	e8 62 f9 ff ff       	call   f0100eae <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010154c:	a1 40 55 11 f0       	mov    0xf0115540,%eax
f0101551:	eb 05                	jmp    f0101558 <mem_init+0x601>
		--nfree;
f0101553:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101556:	8b 00                	mov    (%eax),%eax
f0101558:	85 c0                	test   %eax,%eax
f010155a:	75 f7                	jne    f0101553 <mem_init+0x5fc>
		--nfree;
	assert(nfree == 0);
f010155c:	85 db                	test   %ebx,%ebx
f010155e:	74 24                	je     f0101584 <mem_init+0x62d>
f0101560:	c7 44 24 0c d7 37 10 	movl   $0xf01037d7,0xc(%esp)
f0101567:	f0 
f0101568:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010156f:	f0 
f0101570:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101577:	00 
f0101578:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010157f:	e8 10 eb ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101584:	c7 04 24 78 33 10 f0 	movl   $0xf0103378,(%esp)
f010158b:	e8 66 07 00 00       	call   f0101cf6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101590:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101597:	e8 8e f8 ff ff       	call   f0100e2a <page_alloc>
f010159c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010159f:	85 c0                	test   %eax,%eax
f01015a1:	75 24                	jne    f01015c7 <mem_init+0x670>
f01015a3:	c7 44 24 0c e5 36 10 	movl   $0xf01036e5,0xc(%esp)
f01015aa:	f0 
f01015ab:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01015b2:	f0 
f01015b3:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01015ba:	00 
f01015bb:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01015c2:	e8 cd ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ce:	e8 57 f8 ff ff       	call   f0100e2a <page_alloc>
f01015d3:	89 c6                	mov    %eax,%esi
f01015d5:	85 c0                	test   %eax,%eax
f01015d7:	75 24                	jne    f01015fd <mem_init+0x6a6>
f01015d9:	c7 44 24 0c fb 36 10 	movl   $0xf01036fb,0xc(%esp)
f01015e0:	f0 
f01015e1:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01015e8:	f0 
f01015e9:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f01015f0:	00 
f01015f1:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01015f8:	e8 97 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101604:	e8 21 f8 ff ff       	call   f0100e2a <page_alloc>
f0101609:	89 c3                	mov    %eax,%ebx
f010160b:	85 c0                	test   %eax,%eax
f010160d:	75 24                	jne    f0101633 <mem_init+0x6dc>
f010160f:	c7 44 24 0c 11 37 10 	movl   $0xf0103711,0xc(%esp)
f0101616:	f0 
f0101617:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010161e:	f0 
f010161f:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101626:	00 
f0101627:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010162e:	e8 61 ea ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101633:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101636:	75 24                	jne    f010165c <mem_init+0x705>
f0101638:	c7 44 24 0c 27 37 10 	movl   $0xf0103727,0xc(%esp)
f010163f:	f0 
f0101640:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101647:	f0 
f0101648:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f010164f:	00 
f0101650:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101657:	e8 38 ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165c:	39 c6                	cmp    %eax,%esi
f010165e:	74 05                	je     f0101665 <mem_init+0x70e>
f0101660:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101663:	75 24                	jne    f0101689 <mem_init+0x732>
f0101665:	c7 44 24 0c 58 33 10 	movl   $0xf0103358,0xc(%esp)
f010166c:	f0 
f010166d:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101674:	f0 
f0101675:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f010167c:	00 
f010167d:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101684:	e8 0b ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101689:	c7 05 40 55 11 f0 00 	movl   $0x0,0xf0115540
f0101690:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101693:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010169a:	e8 8b f7 ff ff       	call   f0100e2a <page_alloc>
f010169f:	85 c0                	test   %eax,%eax
f01016a1:	74 24                	je     f01016c7 <mem_init+0x770>
f01016a3:	c7 44 24 0c 90 37 10 	movl   $0xf0103790,0xc(%esp)
f01016aa:	f0 
f01016ab:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01016b2:	f0 
f01016b3:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01016ba:	00 
f01016bb:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01016c2:	e8 cd e9 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016c7:	8b 3d 68 59 11 f0    	mov    0xf0115968,%edi
f01016cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016db:	00 
f01016dc:	89 3c 24             	mov    %edi,(%esp)
f01016df:	e8 69 f8 ff ff       	call   f0100f4d <page_lookup>
f01016e4:	85 c0                	test   %eax,%eax
f01016e6:	74 24                	je     f010170c <mem_init+0x7b5>
f01016e8:	c7 44 24 0c 98 33 10 	movl   $0xf0103398,0xc(%esp)
f01016ef:	f0 
f01016f0:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01016f7:	f0 
f01016f8:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01016ff:	00 
f0101700:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101707:	e8 88 e9 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010170c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101713:	00 
f0101714:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010171b:	00 
f010171c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101720:	89 3c 24             	mov    %edi,(%esp)
f0101723:	e8 1b f8 ff ff       	call   f0100f43 <page_insert>
f0101728:	85 c0                	test   %eax,%eax
f010172a:	78 24                	js     f0101750 <mem_init+0x7f9>
f010172c:	c7 44 24 0c d0 33 10 	movl   $0xf01033d0,0xc(%esp)
f0101733:	f0 
f0101734:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010173b:	f0 
f010173c:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101743:	00 
f0101744:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010174b:	e8 44 e9 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101750:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101753:	89 04 24             	mov    %eax,(%esp)
f0101756:	e8 53 f7 ff ff       	call   f0100eae <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010175b:	8b 3d 68 59 11 f0    	mov    0xf0115968,%edi
f0101761:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101768:	00 
f0101769:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101770:	00 
f0101771:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101775:	89 3c 24             	mov    %edi,(%esp)
f0101778:	e8 c6 f7 ff ff       	call   f0100f43 <page_insert>
f010177d:	85 c0                	test   %eax,%eax
f010177f:	74 24                	je     f01017a5 <mem_init+0x84e>
f0101781:	c7 44 24 0c 00 34 10 	movl   $0xf0103400,0xc(%esp)
f0101788:	f0 
f0101789:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101790:	f0 
f0101791:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101798:	00 
f0101799:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01017a0:	e8 ef e8 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017a5:	8b 0d 6c 59 11 f0    	mov    0xf011596c,%ecx
f01017ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017ae:	8b 17                	mov    (%edi),%edx
f01017b0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017b9:	29 c8                	sub    %ecx,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
f01017c1:	39 c2                	cmp    %eax,%edx
f01017c3:	74 24                	je     f01017e9 <mem_init+0x892>
f01017c5:	c7 44 24 0c 30 34 10 	movl   $0xf0103430,0xc(%esp)
f01017cc:	f0 
f01017cd:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01017d4:	f0 
f01017d5:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f01017dc:	00 
f01017dd:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01017e4:	e8 ab e8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01017ee:	89 f8                	mov    %edi,%eax
f01017f0:	e8 81 f1 ff ff       	call   f0100976 <check_va2pa>
f01017f5:	89 f2                	mov    %esi,%edx
f01017f7:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01017fa:	c1 fa 03             	sar    $0x3,%edx
f01017fd:	c1 e2 0c             	shl    $0xc,%edx
f0101800:	39 d0                	cmp    %edx,%eax
f0101802:	74 24                	je     f0101828 <mem_init+0x8d1>
f0101804:	c7 44 24 0c 58 34 10 	movl   $0xf0103458,0xc(%esp)
f010180b:	f0 
f010180c:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101823:	e8 6c e8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101828:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010182d:	74 24                	je     f0101853 <mem_init+0x8fc>
f010182f:	c7 44 24 0c e2 37 10 	movl   $0xf01037e2,0xc(%esp)
f0101836:	f0 
f0101837:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010183e:	f0 
f010183f:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101846:	00 
f0101847:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010184e:	e8 41 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101856:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010185b:	74 24                	je     f0101881 <mem_init+0x92a>
f010185d:	c7 44 24 0c f3 37 10 	movl   $0xf01037f3,0xc(%esp)
f0101864:	f0 
f0101865:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010186c:	f0 
f010186d:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101874:	00 
f0101875:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010187c:	e8 13 e8 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101881:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101888:	00 
f0101889:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101890:	00 
f0101891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101895:	89 3c 24             	mov    %edi,(%esp)
f0101898:	e8 a6 f6 ff ff       	call   f0100f43 <page_insert>
f010189d:	85 c0                	test   %eax,%eax
f010189f:	74 24                	je     f01018c5 <mem_init+0x96e>
f01018a1:	c7 44 24 0c 88 34 10 	movl   $0xf0103488,0xc(%esp)
f01018a8:	f0 
f01018a9:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f01018b8:	00 
f01018b9:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01018c0:	e8 cf e7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018ca:	89 f8                	mov    %edi,%eax
f01018cc:	e8 a5 f0 ff ff       	call   f0100976 <check_va2pa>
f01018d1:	89 da                	mov    %ebx,%edx
f01018d3:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01018d6:	c1 fa 03             	sar    $0x3,%edx
f01018d9:	c1 e2 0c             	shl    $0xc,%edx
f01018dc:	39 d0                	cmp    %edx,%eax
f01018de:	74 24                	je     f0101904 <mem_init+0x9ad>
f01018e0:	c7 44 24 0c c4 34 10 	movl   $0xf01034c4,0xc(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01018ef:	f0 
f01018f0:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f01018f7:	00 
f01018f8:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01018ff:	e8 90 e7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101904:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101909:	74 24                	je     f010192f <mem_init+0x9d8>
f010190b:	c7 44 24 0c 04 38 10 	movl   $0xf0103804,0xc(%esp)
f0101912:	f0 
f0101913:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010191a:	f0 
f010191b:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101922:	00 
f0101923:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010192a:	e8 65 e7 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010192f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101936:	e8 ef f4 ff ff       	call   f0100e2a <page_alloc>
f010193b:	85 c0                	test   %eax,%eax
f010193d:	74 24                	je     f0101963 <mem_init+0xa0c>
f010193f:	c7 44 24 0c 90 37 10 	movl   $0xf0103790,0xc(%esp)
f0101946:	f0 
f0101947:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f010194e:	f0 
f010194f:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101956:	00 
f0101957:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f010195e:	e8 31 e7 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101963:	8b 35 68 59 11 f0    	mov    0xf0115968,%esi
f0101969:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101970:	00 
f0101971:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101978:	00 
f0101979:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010197d:	89 34 24             	mov    %esi,(%esp)
f0101980:	e8 be f5 ff ff       	call   f0100f43 <page_insert>
f0101985:	85 c0                	test   %eax,%eax
f0101987:	74 24                	je     f01019ad <mem_init+0xa56>
f0101989:	c7 44 24 0c 88 34 10 	movl   $0xf0103488,0xc(%esp)
f0101990:	f0 
f0101991:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101998:	f0 
f0101999:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f01019a0:	00 
f01019a1:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01019a8:	e8 e7 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ad:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019b2:	89 f0                	mov    %esi,%eax
f01019b4:	e8 bd ef ff ff       	call   f0100976 <check_va2pa>
f01019b9:	89 da                	mov    %ebx,%edx
f01019bb:	2b 15 6c 59 11 f0    	sub    0xf011596c,%edx
f01019c1:	c1 fa 03             	sar    $0x3,%edx
f01019c4:	c1 e2 0c             	shl    $0xc,%edx
f01019c7:	39 d0                	cmp    %edx,%eax
f01019c9:	74 24                	je     f01019ef <mem_init+0xa98>
f01019cb:	c7 44 24 0c c4 34 10 	movl   $0xf01034c4,0xc(%esp)
f01019d2:	f0 
f01019d3:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f01019da:	f0 
f01019db:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01019e2:	00 
f01019e3:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f01019ea:	e8 a5 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01019ef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019f4:	74 24                	je     f0101a1a <mem_init+0xac3>
f01019f6:	c7 44 24 0c 04 38 10 	movl   $0xf0103804,0xc(%esp)
f01019fd:	f0 
f01019fe:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101a05:	f0 
f0101a06:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101a0d:	00 
f0101a0e:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101a15:	e8 7a e6 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a21:	e8 04 f4 ff ff       	call   f0100e2a <page_alloc>
f0101a26:	85 c0                	test   %eax,%eax
f0101a28:	74 24                	je     f0101a4e <mem_init+0xaf7>
f0101a2a:	c7 44 24 0c 90 37 10 	movl   $0xf0103790,0xc(%esp)
f0101a31:	f0 
f0101a32:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101a39:	f0 
f0101a3a:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101a41:	00 
f0101a42:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101a49:	e8 46 e6 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a4e:	8b 35 68 59 11 f0    	mov    0xf0115968,%esi
f0101a54:	8b 0e                	mov    (%esi),%ecx
f0101a56:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101a59:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a5f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a62:	89 c8                	mov    %ecx,%eax
f0101a64:	c1 e8 0c             	shr    $0xc,%eax
f0101a67:	3b 05 64 59 11 f0    	cmp    0xf0115964,%eax
f0101a6d:	72 20                	jb     f0101a8f <mem_init+0xb38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a6f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101a73:	c7 44 24 08 d0 31 10 	movl   $0xf01031d0,0x8(%esp)
f0101a7a:	f0 
f0101a7b:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101a82:	00 
f0101a83:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101a8a:	e8 05 e6 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a96:	00 
f0101a97:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101a9e:	00 
f0101a9f:	89 34 24             	mov    %esi,(%esp)
f0101aa2:	e8 6a f4 ff ff       	call   f0100f11 <pgdir_walk>
f0101aa7:	89 c7                	mov    %eax,%edi
f0101aa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aac:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101ab1:	39 c7                	cmp    %eax,%edi
f0101ab3:	74 24                	je     f0101ad9 <mem_init+0xb82>
f0101ab5:	c7 44 24 0c f4 34 10 	movl   $0xf01034f4,0xc(%esp)
f0101abc:	f0 
f0101abd:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101ac4:	f0 
f0101ac5:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101acc:	00 
f0101acd:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101ad4:	e8 bb e5 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ad9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ae0:	00 
f0101ae1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ae8:	00 
f0101ae9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101aed:	89 34 24             	mov    %esi,(%esp)
f0101af0:	e8 4e f4 ff ff       	call   f0100f43 <page_insert>
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	74 24                	je     f0101b1d <mem_init+0xbc6>
f0101af9:	c7 44 24 0c 34 35 10 	movl   $0xf0103534,0xc(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101b08:	f0 
f0101b09:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101b10:	00 
f0101b11:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101b18:	e8 77 e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b1d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b22:	89 f0                	mov    %esi,%eax
f0101b24:	e8 4d ee ff ff       	call   f0100976 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b29:	89 da                	mov    %ebx,%edx
f0101b2b:	2b 15 6c 59 11 f0    	sub    0xf011596c,%edx
f0101b31:	c1 fa 03             	sar    $0x3,%edx
f0101b34:	c1 e2 0c             	shl    $0xc,%edx
f0101b37:	39 d0                	cmp    %edx,%eax
f0101b39:	74 24                	je     f0101b5f <mem_init+0xc08>
f0101b3b:	c7 44 24 0c c4 34 10 	movl   $0xf01034c4,0xc(%esp)
f0101b42:	f0 
f0101b43:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101b4a:	f0 
f0101b4b:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101b52:	00 
f0101b53:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101b5a:	e8 35 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101b5f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b64:	74 24                	je     f0101b8a <mem_init+0xc33>
f0101b66:	c7 44 24 0c 04 38 10 	movl   $0xf0103804,0xc(%esp)
f0101b6d:	f0 
f0101b6e:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101b75:	f0 
f0101b76:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101b7d:	00 
f0101b7e:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101b85:	e8 0a e5 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b8a:	8b 3f                	mov    (%edi),%edi
f0101b8c:	f7 c7 04 00 00 00    	test   $0x4,%edi
f0101b92:	75 24                	jne    f0101bb8 <mem_init+0xc61>
f0101b94:	c7 44 24 0c 74 35 10 	movl   $0xf0103574,0xc(%esp)
f0101b9b:	f0 
f0101b9c:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101ba3:	f0 
f0101ba4:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101bab:	00 
f0101bac:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101bb3:	e8 dc e4 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bb8:	f6 45 d0 04          	testb  $0x4,-0x30(%ebp)
f0101bbc:	75 24                	jne    f0101be2 <mem_init+0xc8b>
f0101bbe:	c7 44 24 0c 15 38 10 	movl   $0xf0103815,0xc(%esp)
f0101bc5:	f0 
f0101bc6:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101bcd:	f0 
f0101bce:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101bd5:	00 
f0101bd6:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101bdd:	e8 b2 e4 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101be2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101be9:	00 
f0101bea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bf1:	00 
f0101bf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bf6:	89 34 24             	mov    %esi,(%esp)
f0101bf9:	e8 45 f3 ff ff       	call   f0100f43 <page_insert>
f0101bfe:	85 c0                	test   %eax,%eax
f0101c00:	74 24                	je     f0101c26 <mem_init+0xccf>
f0101c02:	c7 44 24 0c 88 34 10 	movl   $0xf0103488,0xc(%esp)
f0101c09:	f0 
f0101c0a:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101c11:	f0 
f0101c12:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101c19:	00 
f0101c1a:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101c21:	e8 6e e4 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c26:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0101c2c:	75 24                	jne    f0101c52 <mem_init+0xcfb>
f0101c2e:	c7 44 24 0c a8 35 10 	movl   $0xf01035a8,0xc(%esp)
f0101c35:	f0 
f0101c36:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101c3d:	f0 
f0101c3e:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101c45:	00 
f0101c46:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101c4d:	e8 42 e4 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c52:	c7 44 24 0c dc 35 10 	movl   $0xf01035dc,0xc(%esp)
f0101c59:	f0 
f0101c5a:	c7 44 24 08 3a 36 10 	movl   $0xf010363a,0x8(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101c69:	00 
f0101c6a:	c7 04 24 14 36 10 f0 	movl   $0xf0103614,(%esp)
f0101c71:	e8 1e e4 ff ff       	call   f0100094 <_panic>

f0101c76 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101c76:	55                   	push   %ebp
f0101c77:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0101c79:	5d                   	pop    %ebp
f0101c7a:	c3                   	ret    

f0101c7b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101c7b:	55                   	push   %ebp
f0101c7c:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c81:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101c84:	5d                   	pop    %ebp
f0101c85:	c3                   	ret    

f0101c86 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101c86:	55                   	push   %ebp
f0101c87:	89 e5                	mov    %esp,%ebp
f0101c89:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101c8d:	ba 70 00 00 00       	mov    $0x70,%edx
f0101c92:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101c93:	b2 71                	mov    $0x71,%dl
f0101c95:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101c96:	0f b6 c0             	movzbl %al,%eax
}
f0101c99:	5d                   	pop    %ebp
f0101c9a:	c3                   	ret    

f0101c9b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0101c9b:	55                   	push   %ebp
f0101c9c:	89 e5                	mov    %esp,%ebp
f0101c9e:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101ca2:	ba 70 00 00 00       	mov    $0x70,%edx
f0101ca7:	ee                   	out    %al,(%dx)
f0101ca8:	b2 71                	mov    $0x71,%dl
f0101caa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101cad:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101cae:	5d                   	pop    %ebp
f0101caf:	c3                   	ret    

f0101cb0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101cb0:	55                   	push   %ebp
f0101cb1:	89 e5                	mov    %esp,%ebp
f0101cb3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cb9:	89 04 24             	mov    %eax,(%esp)
f0101cbc:	e8 30 e9 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0101cc1:	c9                   	leave  
f0101cc2:	c3                   	ret    

f0101cc3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101cc3:	55                   	push   %ebp
f0101cc4:	89 e5                	mov    %esp,%ebp
f0101cc6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0101cc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cda:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101cde:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ce5:	c7 04 24 b0 1c 10 f0 	movl   $0xf0101cb0,(%esp)
f0101cec:	e8 13 04 00 00       	call   f0102104 <vprintfmt>
	return cnt;
}
f0101cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101cf4:	c9                   	leave  
f0101cf5:	c3                   	ret    

f0101cf6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101cf6:	55                   	push   %ebp
f0101cf7:	89 e5                	mov    %esp,%ebp
f0101cf9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101cfc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101cff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d03:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d06:	89 04 24             	mov    %eax,(%esp)
f0101d09:	e8 b5 ff ff ff       	call   f0101cc3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0101d0e:	c9                   	leave  
f0101d0f:	c3                   	ret    

f0101d10 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101d10:	55                   	push   %ebp
f0101d11:	89 e5                	mov    %esp,%ebp
f0101d13:	57                   	push   %edi
f0101d14:	56                   	push   %esi
f0101d15:	53                   	push   %ebx
f0101d16:	83 ec 10             	sub    $0x10,%esp
f0101d19:	89 c6                	mov    %eax,%esi
f0101d1b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101d1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101d21:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101d24:	8b 1a                	mov    (%edx),%ebx
f0101d26:	8b 01                	mov    (%ecx),%eax
f0101d28:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101d2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0101d32:	eb 77                	jmp    f0101dab <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0101d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d37:	01 d8                	add    %ebx,%eax
f0101d39:	b9 02 00 00 00       	mov    $0x2,%ecx
f0101d3e:	99                   	cltd   
f0101d3f:	f7 f9                	idiv   %ecx
f0101d41:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101d43:	eb 01                	jmp    f0101d46 <stab_binsearch+0x36>
			m--;
f0101d45:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101d46:	39 d9                	cmp    %ebx,%ecx
f0101d48:	7c 1d                	jl     f0101d67 <stab_binsearch+0x57>
f0101d4a:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0101d4d:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0101d52:	39 fa                	cmp    %edi,%edx
f0101d54:	75 ef                	jne    f0101d45 <stab_binsearch+0x35>
f0101d56:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101d59:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0101d5c:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0101d60:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0101d63:	73 18                	jae    f0101d7d <stab_binsearch+0x6d>
f0101d65:	eb 05                	jmp    f0101d6c <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101d67:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0101d6a:	eb 3f                	jmp    f0101dab <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0101d6c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0101d6f:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0101d71:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101d74:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101d7b:	eb 2e                	jmp    f0101dab <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101d7d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0101d80:	73 15                	jae    f0101d97 <stab_binsearch+0x87>
			*region_right = m - 1;
f0101d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d85:	48                   	dec    %eax
f0101d86:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101d89:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d8c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101d8e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101d95:	eb 14                	jmp    f0101dab <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d9a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0101d9d:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0101d9f:	ff 45 0c             	incl   0xc(%ebp)
f0101da2:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101da4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101dab:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101dae:	7e 84                	jle    f0101d34 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101db0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101db4:	75 0d                	jne    f0101dc3 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0101db6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101db9:	8b 00                	mov    (%eax),%eax
f0101dbb:	48                   	dec    %eax
f0101dbc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101dbf:	89 07                	mov    %eax,(%edi)
f0101dc1:	eb 22                	jmp    f0101de5 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101dc6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101dc8:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0101dcb:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101dcd:	eb 01                	jmp    f0101dd0 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101dcf:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101dd0:	39 c1                	cmp    %eax,%ecx
f0101dd2:	7d 0c                	jge    f0101de0 <stab_binsearch+0xd0>
f0101dd4:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0101dd7:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0101ddc:	39 fa                	cmp    %edi,%edx
f0101dde:	75 ef                	jne    f0101dcf <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101de0:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101de3:	89 07                	mov    %eax,(%edi)
	}
}
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	5b                   	pop    %ebx
f0101de9:	5e                   	pop    %esi
f0101dea:	5f                   	pop    %edi
f0101deb:	5d                   	pop    %ebp
f0101dec:	c3                   	ret    

f0101ded <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101ded:	55                   	push   %ebp
f0101dee:	89 e5                	mov    %esp,%ebp
f0101df0:	57                   	push   %edi
f0101df1:	56                   	push   %esi
f0101df2:	53                   	push   %ebx
f0101df3:	83 ec 2c             	sub    $0x2c,%esp
f0101df6:	8b 75 08             	mov    0x8(%ebp),%esi
f0101df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101dfc:	c7 03 2b 38 10 f0    	movl   $0xf010382b,(%ebx)
	info->eip_line = 0;
f0101e02:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101e09:	c7 43 08 2b 38 10 f0 	movl   $0xf010382b,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101e10:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101e17:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101e1a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101e21:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101e27:	76 12                	jbe    f0101e3b <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101e29:	b8 a8 a7 10 f0       	mov    $0xf010a7a8,%eax
f0101e2e:	3d 51 8a 10 f0       	cmp    $0xf0108a51,%eax
f0101e33:	0f 86 6b 01 00 00    	jbe    f0101fa4 <debuginfo_eip+0x1b7>
f0101e39:	eb 1c                	jmp    f0101e57 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101e3b:	c7 44 24 08 35 38 10 	movl   $0xf0103835,0x8(%esp)
f0101e42:	f0 
f0101e43:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0101e4a:	00 
f0101e4b:	c7 04 24 42 38 10 f0 	movl   $0xf0103842,(%esp)
f0101e52:	e8 3d e2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101e57:	80 3d a7 a7 10 f0 00 	cmpb   $0x0,0xf010a7a7
f0101e5e:	0f 85 47 01 00 00    	jne    f0101fab <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101e64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101e6b:	b8 50 8a 10 f0       	mov    $0xf0108a50,%eax
f0101e70:	2d 70 3a 10 f0       	sub    $0xf0103a70,%eax
f0101e75:	c1 f8 02             	sar    $0x2,%eax
f0101e78:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101e7e:	83 e8 01             	sub    $0x1,%eax
f0101e81:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101e84:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e88:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101e8f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101e92:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101e95:	b8 70 3a 10 f0       	mov    $0xf0103a70,%eax
f0101e9a:	e8 71 fe ff ff       	call   f0101d10 <stab_binsearch>
	if (lfile == 0)
f0101e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ea2:	85 c0                	test   %eax,%eax
f0101ea4:	0f 84 08 01 00 00    	je     f0101fb2 <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101eaa:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0101ead:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101eb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101eb3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101eb7:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101ebe:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101ec1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101ec4:	b8 70 3a 10 f0       	mov    $0xf0103a70,%eax
f0101ec9:	e8 42 fe ff ff       	call   f0101d10 <stab_binsearch>

	if (lfun <= rfun) {
f0101ece:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101ed1:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0101ed4:	7f 2e                	jg     f0101f04 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101ed6:	6b c7 0c             	imul   $0xc,%edi,%eax
f0101ed9:	8d 90 70 3a 10 f0    	lea    -0xfefc590(%eax),%edx
f0101edf:	8b 80 70 3a 10 f0    	mov    -0xfefc590(%eax),%eax
f0101ee5:	b9 a8 a7 10 f0       	mov    $0xf010a7a8,%ecx
f0101eea:	81 e9 51 8a 10 f0    	sub    $0xf0108a51,%ecx
f0101ef0:	39 c8                	cmp    %ecx,%eax
f0101ef2:	73 08                	jae    f0101efc <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101ef4:	05 51 8a 10 f0       	add    $0xf0108a51,%eax
f0101ef9:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101efc:	8b 42 08             	mov    0x8(%edx),%eax
f0101eff:	89 43 10             	mov    %eax,0x10(%ebx)
f0101f02:	eb 06                	jmp    f0101f0a <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101f04:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101f07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101f0a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101f11:	00 
f0101f12:	8b 43 08             	mov    0x8(%ebx),%eax
f0101f15:	89 04 24             	mov    %eax,(%esp)
f0101f18:	e8 0e 09 00 00       	call   f010282b <strfind>
f0101f1d:	2b 43 08             	sub    0x8(%ebx),%eax
f0101f20:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101f23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101f26:	6b c7 0c             	imul   $0xc,%edi,%eax
f0101f29:	05 70 3a 10 f0       	add    $0xf0103a70,%eax
f0101f2e:	eb 06                	jmp    f0101f36 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0101f30:	83 ef 01             	sub    $0x1,%edi
f0101f33:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101f36:	39 cf                	cmp    %ecx,%edi
f0101f38:	7c 33                	jl     f0101f6d <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0101f3a:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0101f3e:	80 fa 84             	cmp    $0x84,%dl
f0101f41:	74 0b                	je     f0101f4e <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101f43:	80 fa 64             	cmp    $0x64,%dl
f0101f46:	75 e8                	jne    f0101f30 <debuginfo_eip+0x143>
f0101f48:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0101f4c:	74 e2                	je     f0101f30 <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101f4e:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101f51:	8b 87 70 3a 10 f0    	mov    -0xfefc590(%edi),%eax
f0101f57:	ba a8 a7 10 f0       	mov    $0xf010a7a8,%edx
f0101f5c:	81 ea 51 8a 10 f0    	sub    $0xf0108a51,%edx
f0101f62:	39 d0                	cmp    %edx,%eax
f0101f64:	73 07                	jae    f0101f6d <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101f66:	05 51 8a 10 f0       	add    $0xf0108a51,%eax
f0101f6b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101f6d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101f70:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101f73:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101f78:	39 f1                	cmp    %esi,%ecx
f0101f7a:	7d 42                	jge    f0101fbe <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0101f7c:	8d 51 01             	lea    0x1(%ecx),%edx
f0101f7f:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0101f82:	05 70 3a 10 f0       	add    $0xf0103a70,%eax
f0101f87:	eb 07                	jmp    f0101f90 <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101f89:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0101f8d:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101f90:	39 f2                	cmp    %esi,%edx
f0101f92:	74 25                	je     f0101fb9 <debuginfo_eip+0x1cc>
f0101f94:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101f97:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0101f9b:	74 ec                	je     f0101f89 <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101f9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fa2:	eb 1a                	jmp    f0101fbe <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101fa9:	eb 13                	jmp    f0101fbe <debuginfo_eip+0x1d1>
f0101fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101fb0:	eb 0c                	jmp    f0101fbe <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0101fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101fb7:	eb 05                	jmp    f0101fbe <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101fb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101fbe:	83 c4 2c             	add    $0x2c,%esp
f0101fc1:	5b                   	pop    %ebx
f0101fc2:	5e                   	pop    %esi
f0101fc3:	5f                   	pop    %edi
f0101fc4:	5d                   	pop    %ebp
f0101fc5:	c3                   	ret    
	...

f0101fd0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101fd0:	55                   	push   %ebp
f0101fd1:	89 e5                	mov    %esp,%ebp
f0101fd3:	57                   	push   %edi
f0101fd4:	56                   	push   %esi
f0101fd5:	53                   	push   %ebx
f0101fd6:	83 ec 3c             	sub    $0x3c,%esp
f0101fd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101fdc:	89 d7                	mov    %edx,%edi
f0101fde:	8b 45 08             	mov    0x8(%ebp),%eax
f0101fe1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101fe7:	89 c3                	mov    %eax,%ebx
f0101fe9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fec:	8b 45 10             	mov    0x10(%ebp),%eax
f0101fef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101ff2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101ff7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ffa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101ffd:	39 d9                	cmp    %ebx,%ecx
f0101fff:	72 05                	jb     f0102006 <printnum+0x36>
f0102001:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102004:	77 69                	ja     f010206f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102006:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0102009:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010200d:	83 ee 01             	sub    $0x1,%esi
f0102010:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102014:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102018:	8b 44 24 08          	mov    0x8(%esp),%eax
f010201c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0102020:	89 c3                	mov    %eax,%ebx
f0102022:	89 d6                	mov    %edx,%esi
f0102024:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102027:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010202a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010202e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102032:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102035:	89 04 24             	mov    %eax,(%esp)
f0102038:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010203b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010203f:	e8 0c 0a 00 00       	call   f0102a50 <__udivdi3>
f0102044:	89 d9                	mov    %ebx,%ecx
f0102046:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010204a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010204e:	89 04 24             	mov    %eax,(%esp)
f0102051:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102055:	89 fa                	mov    %edi,%edx
f0102057:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010205a:	e8 71 ff ff ff       	call   f0101fd0 <printnum>
f010205f:	eb 1b                	jmp    f010207c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102061:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102065:	8b 45 18             	mov    0x18(%ebp),%eax
f0102068:	89 04 24             	mov    %eax,(%esp)
f010206b:	ff d3                	call   *%ebx
f010206d:	eb 03                	jmp    f0102072 <printnum+0xa2>
f010206f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102072:	83 ee 01             	sub    $0x1,%esi
f0102075:	85 f6                	test   %esi,%esi
f0102077:	7f e8                	jg     f0102061 <printnum+0x91>
f0102079:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010207c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102080:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102084:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102087:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010208a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010208e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102092:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102095:	89 04 24             	mov    %eax,(%esp)
f0102098:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010209b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010209f:	e8 dc 0a 00 00       	call   f0102b80 <__umoddi3>
f01020a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01020a8:	0f be 80 50 38 10 f0 	movsbl -0xfefc7b0(%eax),%eax
f01020af:	89 04 24             	mov    %eax,(%esp)
f01020b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01020b5:	ff d0                	call   *%eax
}
f01020b7:	83 c4 3c             	add    $0x3c,%esp
f01020ba:	5b                   	pop    %ebx
f01020bb:	5e                   	pop    %esi
f01020bc:	5f                   	pop    %edi
f01020bd:	5d                   	pop    %ebp
f01020be:	c3                   	ret    

f01020bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01020bf:	55                   	push   %ebp
f01020c0:	89 e5                	mov    %esp,%ebp
f01020c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01020c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01020c9:	8b 10                	mov    (%eax),%edx
f01020cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01020ce:	73 0a                	jae    f01020da <sprintputch+0x1b>
		*b->buf++ = ch;
f01020d0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01020d3:	89 08                	mov    %ecx,(%eax)
f01020d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01020d8:	88 02                	mov    %al,(%edx)
}
f01020da:	5d                   	pop    %ebp
f01020db:	c3                   	ret    

f01020dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01020dc:	55                   	push   %ebp
f01020dd:	89 e5                	mov    %esp,%ebp
f01020df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01020e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01020e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01020ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01020f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01020f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01020fa:	89 04 24             	mov    %eax,(%esp)
f01020fd:	e8 02 00 00 00       	call   f0102104 <vprintfmt>
	va_end(ap);
}
f0102102:	c9                   	leave  
f0102103:	c3                   	ret    

f0102104 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102104:	55                   	push   %ebp
f0102105:	89 e5                	mov    %esp,%ebp
f0102107:	57                   	push   %edi
f0102108:	56                   	push   %esi
f0102109:	53                   	push   %ebx
f010210a:	83 ec 3c             	sub    $0x3c,%esp
f010210d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102113:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102116:	eb 11                	jmp    f0102129 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102118:	85 c0                	test   %eax,%eax
f010211a:	0f 84 48 04 00 00    	je     f0102568 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0102120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102124:	89 04 24             	mov    %eax,(%esp)
f0102127:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102129:	83 c7 01             	add    $0x1,%edi
f010212c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102130:	83 f8 25             	cmp    $0x25,%eax
f0102133:	75 e3                	jne    f0102118 <vprintfmt+0x14>
f0102135:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102139:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102140:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102147:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010214e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102153:	eb 1f                	jmp    f0102174 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102155:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102158:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010215c:	eb 16                	jmp    f0102174 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010215e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102161:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102165:	eb 0d                	jmp    f0102174 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0102167:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010216a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010216d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102174:	8d 47 01             	lea    0x1(%edi),%eax
f0102177:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010217a:	0f b6 17             	movzbl (%edi),%edx
f010217d:	0f b6 c2             	movzbl %dl,%eax
f0102180:	83 ea 23             	sub    $0x23,%edx
f0102183:	80 fa 55             	cmp    $0x55,%dl
f0102186:	0f 87 bf 03 00 00    	ja     f010254b <vprintfmt+0x447>
f010218c:	0f b6 d2             	movzbl %dl,%edx
f010218f:	ff 24 95 e0 38 10 f0 	jmp    *-0xfefc720(,%edx,4)
f0102196:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102199:	ba 00 00 00 00       	mov    $0x0,%edx
f010219e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01021a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01021a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01021a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f01021ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01021ae:	83 f9 09             	cmp    $0x9,%ecx
f01021b1:	77 3c                	ja     f01021ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01021b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01021b6:	eb e9                	jmp    f01021a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01021b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01021bb:	8b 00                	mov    (%eax),%eax
f01021bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01021c3:	8d 40 04             	lea    0x4(%eax),%eax
f01021c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01021cc:	eb 27                	jmp    f01021f5 <vprintfmt+0xf1>
f01021ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01021d1:	85 d2                	test   %edx,%edx
f01021d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01021d8:	0f 49 c2             	cmovns %edx,%eax
f01021db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01021e1:	eb 91                	jmp    f0102174 <vprintfmt+0x70>
f01021e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01021e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01021ed:	eb 85                	jmp    f0102174 <vprintfmt+0x70>
f01021ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01021f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01021f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01021f9:	0f 89 75 ff ff ff    	jns    f0102174 <vprintfmt+0x70>
f01021ff:	e9 63 ff ff ff       	jmp    f0102167 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102204:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102207:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010220a:	e9 65 ff ff ff       	jmp    f0102174 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010220f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102212:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0102216:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010221a:	8b 00                	mov    (%eax),%eax
f010221c:	89 04 24             	mov    %eax,(%esp)
f010221f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102221:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102224:	e9 00 ff ff ff       	jmp    f0102129 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102229:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010222c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0102230:	8b 00                	mov    (%eax),%eax
f0102232:	99                   	cltd   
f0102233:	31 d0                	xor    %edx,%eax
f0102235:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102237:	83 f8 07             	cmp    $0x7,%eax
f010223a:	7f 0b                	jg     f0102247 <vprintfmt+0x143>
f010223c:	8b 14 85 40 3a 10 f0 	mov    -0xfefc5c0(,%eax,4),%edx
f0102243:	85 d2                	test   %edx,%edx
f0102245:	75 20                	jne    f0102267 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0102247:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010224b:	c7 44 24 08 68 38 10 	movl   $0xf0103868,0x8(%esp)
f0102252:	f0 
f0102253:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102257:	89 34 24             	mov    %esi,(%esp)
f010225a:	e8 7d fe ff ff       	call   f01020dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010225f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102262:	e9 c2 fe ff ff       	jmp    f0102129 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0102267:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010226b:	c7 44 24 08 4c 36 10 	movl   $0xf010364c,0x8(%esp)
f0102272:	f0 
f0102273:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102277:	89 34 24             	mov    %esi,(%esp)
f010227a:	e8 5d fe ff ff       	call   f01020dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010227f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102282:	e9 a2 fe ff ff       	jmp    f0102129 <vprintfmt+0x25>
f0102287:	8b 45 14             	mov    0x14(%ebp),%eax
f010228a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010228d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102290:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102293:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0102297:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102299:	85 ff                	test   %edi,%edi
f010229b:	b8 61 38 10 f0       	mov    $0xf0103861,%eax
f01022a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01022a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01022a7:	0f 84 92 00 00 00    	je     f010233f <vprintfmt+0x23b>
f01022ad:	85 c9                	test   %ecx,%ecx
f01022af:	0f 8e 98 00 00 00    	jle    f010234d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f01022b5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01022b9:	89 3c 24             	mov    %edi,(%esp)
f01022bc:	e8 17 04 00 00       	call   f01026d8 <strnlen>
f01022c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01022c4:	29 c1                	sub    %eax,%ecx
f01022c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f01022c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01022cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01022d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01022d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01022d5:	eb 0f                	jmp    f01022e6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f01022d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01022de:	89 04 24             	mov    %eax,(%esp)
f01022e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01022e3:	83 ef 01             	sub    $0x1,%edi
f01022e6:	85 ff                	test   %edi,%edi
f01022e8:	7f ed                	jg     f01022d7 <vprintfmt+0x1d3>
f01022ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01022f0:	85 c9                	test   %ecx,%ecx
f01022f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01022f7:	0f 49 c1             	cmovns %ecx,%eax
f01022fa:	29 c1                	sub    %eax,%ecx
f01022fc:	89 75 08             	mov    %esi,0x8(%ebp)
f01022ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102302:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102305:	89 cb                	mov    %ecx,%ebx
f0102307:	eb 50                	jmp    f0102359 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102309:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010230d:	74 1e                	je     f010232d <vprintfmt+0x229>
f010230f:	0f be d2             	movsbl %dl,%edx
f0102312:	83 ea 20             	sub    $0x20,%edx
f0102315:	83 fa 5e             	cmp    $0x5e,%edx
f0102318:	76 13                	jbe    f010232d <vprintfmt+0x229>
					putch('?', putdat);
f010231a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010231d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102321:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0102328:	ff 55 08             	call   *0x8(%ebp)
f010232b:	eb 0d                	jmp    f010233a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f010232d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102330:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102334:	89 04 24             	mov    %eax,(%esp)
f0102337:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010233a:	83 eb 01             	sub    $0x1,%ebx
f010233d:	eb 1a                	jmp    f0102359 <vprintfmt+0x255>
f010233f:	89 75 08             	mov    %esi,0x8(%ebp)
f0102342:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102345:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102348:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010234b:	eb 0c                	jmp    f0102359 <vprintfmt+0x255>
f010234d:	89 75 08             	mov    %esi,0x8(%ebp)
f0102350:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102353:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102356:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102359:	83 c7 01             	add    $0x1,%edi
f010235c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0102360:	0f be c2             	movsbl %dl,%eax
f0102363:	85 c0                	test   %eax,%eax
f0102365:	74 25                	je     f010238c <vprintfmt+0x288>
f0102367:	85 f6                	test   %esi,%esi
f0102369:	78 9e                	js     f0102309 <vprintfmt+0x205>
f010236b:	83 ee 01             	sub    $0x1,%esi
f010236e:	79 99                	jns    f0102309 <vprintfmt+0x205>
f0102370:	89 df                	mov    %ebx,%edi
f0102372:	8b 75 08             	mov    0x8(%ebp),%esi
f0102375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102378:	eb 1a                	jmp    f0102394 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010237a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010237e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0102385:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102387:	83 ef 01             	sub    $0x1,%edi
f010238a:	eb 08                	jmp    f0102394 <vprintfmt+0x290>
f010238c:	89 df                	mov    %ebx,%edi
f010238e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102394:	85 ff                	test   %edi,%edi
f0102396:	7f e2                	jg     f010237a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010239b:	e9 89 fd ff ff       	jmp    f0102129 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01023a0:	83 f9 01             	cmp    $0x1,%ecx
f01023a3:	7e 19                	jle    f01023be <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f01023a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01023a8:	8b 50 04             	mov    0x4(%eax),%edx
f01023ab:	8b 00                	mov    (%eax),%eax
f01023ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01023b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01023b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01023b6:	8d 40 08             	lea    0x8(%eax),%eax
f01023b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01023bc:	eb 38                	jmp    f01023f6 <vprintfmt+0x2f2>
	else if (lflag)
f01023be:	85 c9                	test   %ecx,%ecx
f01023c0:	74 1b                	je     f01023dd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f01023c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01023c5:	8b 00                	mov    (%eax),%eax
f01023c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01023ca:	89 c1                	mov    %eax,%ecx
f01023cc:	c1 f9 1f             	sar    $0x1f,%ecx
f01023cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01023d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01023d5:	8d 40 04             	lea    0x4(%eax),%eax
f01023d8:	89 45 14             	mov    %eax,0x14(%ebp)
f01023db:	eb 19                	jmp    f01023f6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f01023dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01023e0:	8b 00                	mov    (%eax),%eax
f01023e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01023e5:	89 c1                	mov    %eax,%ecx
f01023e7:	c1 f9 1f             	sar    $0x1f,%ecx
f01023ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01023ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01023f0:	8d 40 04             	lea    0x4(%eax),%eax
f01023f3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01023f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01023f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01023fc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102401:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102405:	0f 89 04 01 00 00    	jns    f010250f <vprintfmt+0x40b>
				putch('-', putdat);
f010240b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010240f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0102416:	ff d6                	call   *%esi
				num = -(long long) num;
f0102418:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010241b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010241e:	f7 da                	neg    %edx
f0102420:	83 d1 00             	adc    $0x0,%ecx
f0102423:	f7 d9                	neg    %ecx
f0102425:	e9 e5 00 00 00       	jmp    f010250f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010242a:	83 f9 01             	cmp    $0x1,%ecx
f010242d:	7e 10                	jle    f010243f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f010242f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102432:	8b 10                	mov    (%eax),%edx
f0102434:	8b 48 04             	mov    0x4(%eax),%ecx
f0102437:	8d 40 08             	lea    0x8(%eax),%eax
f010243a:	89 45 14             	mov    %eax,0x14(%ebp)
f010243d:	eb 26                	jmp    f0102465 <vprintfmt+0x361>
	else if (lflag)
f010243f:	85 c9                	test   %ecx,%ecx
f0102441:	74 12                	je     f0102455 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0102443:	8b 45 14             	mov    0x14(%ebp),%eax
f0102446:	8b 10                	mov    (%eax),%edx
f0102448:	b9 00 00 00 00       	mov    $0x0,%ecx
f010244d:	8d 40 04             	lea    0x4(%eax),%eax
f0102450:	89 45 14             	mov    %eax,0x14(%ebp)
f0102453:	eb 10                	jmp    f0102465 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0102455:	8b 45 14             	mov    0x14(%ebp),%eax
f0102458:	8b 10                	mov    (%eax),%edx
f010245a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010245f:	8d 40 04             	lea    0x4(%eax),%eax
f0102462:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102465:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010246a:	e9 a0 00 00 00       	jmp    f010250f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010246f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102473:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010247a:	ff d6                	call   *%esi
			putch('X', putdat);
f010247c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102480:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0102487:	ff d6                	call   *%esi
			putch('X', putdat);
f0102489:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010248d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0102494:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0102499:	e9 8b fc ff ff       	jmp    f0102129 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010249e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01024a9:	ff d6                	call   *%esi
			putch('x', putdat);
f01024ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024af:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01024b6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01024b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01024bb:	8b 10                	mov    (%eax),%edx
f01024bd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f01024c2:	8d 40 04             	lea    0x4(%eax),%eax
f01024c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01024c8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01024cd:	eb 40                	jmp    f010250f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01024cf:	83 f9 01             	cmp    $0x1,%ecx
f01024d2:	7e 10                	jle    f01024e4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f01024d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01024d7:	8b 10                	mov    (%eax),%edx
f01024d9:	8b 48 04             	mov    0x4(%eax),%ecx
f01024dc:	8d 40 08             	lea    0x8(%eax),%eax
f01024df:	89 45 14             	mov    %eax,0x14(%ebp)
f01024e2:	eb 26                	jmp    f010250a <vprintfmt+0x406>
	else if (lflag)
f01024e4:	85 c9                	test   %ecx,%ecx
f01024e6:	74 12                	je     f01024fa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01024e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01024eb:	8b 10                	mov    (%eax),%edx
f01024ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01024f2:	8d 40 04             	lea    0x4(%eax),%eax
f01024f5:	89 45 14             	mov    %eax,0x14(%ebp)
f01024f8:	eb 10                	jmp    f010250a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01024fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01024fd:	8b 10                	mov    (%eax),%edx
f01024ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102504:	8d 40 04             	lea    0x4(%eax),%eax
f0102507:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010250a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010250f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102513:	89 44 24 10          	mov    %eax,0x10(%esp)
f0102517:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010251a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010251e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102522:	89 14 24             	mov    %edx,(%esp)
f0102525:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102529:	89 da                	mov    %ebx,%edx
f010252b:	89 f0                	mov    %esi,%eax
f010252d:	e8 9e fa ff ff       	call   f0101fd0 <printnum>
			break;
f0102532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102535:	e9 ef fb ff ff       	jmp    f0102129 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010253a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010253e:	89 04 24             	mov    %eax,(%esp)
f0102541:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102546:	e9 de fb ff ff       	jmp    f0102129 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010254b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010254f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0102556:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102558:	eb 03                	jmp    f010255d <vprintfmt+0x459>
f010255a:	83 ef 01             	sub    $0x1,%edi
f010255d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102561:	75 f7                	jne    f010255a <vprintfmt+0x456>
f0102563:	e9 c1 fb ff ff       	jmp    f0102129 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0102568:	83 c4 3c             	add    $0x3c,%esp
f010256b:	5b                   	pop    %ebx
f010256c:	5e                   	pop    %esi
f010256d:	5f                   	pop    %edi
f010256e:	5d                   	pop    %ebp
f010256f:	c3                   	ret    

f0102570 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102570:	55                   	push   %ebp
f0102571:	89 e5                	mov    %esp,%ebp
f0102573:	83 ec 28             	sub    $0x28,%esp
f0102576:	8b 45 08             	mov    0x8(%ebp),%eax
f0102579:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010257c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010257f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102583:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102586:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010258d:	85 c0                	test   %eax,%eax
f010258f:	74 30                	je     f01025c1 <vsnprintf+0x51>
f0102591:	85 d2                	test   %edx,%edx
f0102593:	7e 2c                	jle    f01025c1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102595:	8b 45 14             	mov    0x14(%ebp),%eax
f0102598:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010259c:	8b 45 10             	mov    0x10(%ebp),%eax
f010259f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01025a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01025a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01025aa:	c7 04 24 bf 20 10 f0 	movl   $0xf01020bf,(%esp)
f01025b1:	e8 4e fb ff ff       	call   f0102104 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01025b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01025b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01025bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01025bf:	eb 05                	jmp    f01025c6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01025c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01025c6:	c9                   	leave  
f01025c7:	c3                   	ret    

f01025c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01025c8:	55                   	push   %ebp
f01025c9:	89 e5                	mov    %esp,%ebp
f01025cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01025ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01025d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025d5:	8b 45 10             	mov    0x10(%ebp),%eax
f01025d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01025dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01025df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01025e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01025e6:	89 04 24             	mov    %eax,(%esp)
f01025e9:	e8 82 ff ff ff       	call   f0102570 <vsnprintf>
	va_end(ap);

	return rc;
}
f01025ee:	c9                   	leave  
f01025ef:	c3                   	ret    

f01025f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01025f0:	55                   	push   %ebp
f01025f1:	89 e5                	mov    %esp,%ebp
f01025f3:	57                   	push   %edi
f01025f4:	56                   	push   %esi
f01025f5:	53                   	push   %ebx
f01025f6:	83 ec 1c             	sub    $0x1c,%esp
f01025f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01025fc:	85 c0                	test   %eax,%eax
f01025fe:	74 10                	je     f0102610 <readline+0x20>
		cprintf("%s", prompt);
f0102600:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102604:	c7 04 24 4c 36 10 f0 	movl   $0xf010364c,(%esp)
f010260b:	e8 e6 f6 ff ff       	call   f0101cf6 <cprintf>

	i = 0;
	echoing = iscons(0);
f0102610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102617:	e8 f6 df ff ff       	call   f0100612 <iscons>
f010261c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010261e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102623:	e8 d9 df ff ff       	call   f0100601 <getchar>
f0102628:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010262a:	85 c0                	test   %eax,%eax
f010262c:	79 17                	jns    f0102645 <readline+0x55>
			cprintf("read error: %e\n", c);
f010262e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102632:	c7 04 24 60 3a 10 f0 	movl   $0xf0103a60,(%esp)
f0102639:	e8 b8 f6 ff ff       	call   f0101cf6 <cprintf>
			return NULL;
f010263e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102643:	eb 6d                	jmp    f01026b2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102645:	83 f8 7f             	cmp    $0x7f,%eax
f0102648:	74 05                	je     f010264f <readline+0x5f>
f010264a:	83 f8 08             	cmp    $0x8,%eax
f010264d:	75 19                	jne    f0102668 <readline+0x78>
f010264f:	85 f6                	test   %esi,%esi
f0102651:	7e 15                	jle    f0102668 <readline+0x78>
			if (echoing)
f0102653:	85 ff                	test   %edi,%edi
f0102655:	74 0c                	je     f0102663 <readline+0x73>
				cputchar('\b');
f0102657:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010265e:	e8 8e df ff ff       	call   f01005f1 <cputchar>
			i--;
f0102663:	83 ee 01             	sub    $0x1,%esi
f0102666:	eb bb                	jmp    f0102623 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102668:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010266e:	7f 1c                	jg     f010268c <readline+0x9c>
f0102670:	83 fb 1f             	cmp    $0x1f,%ebx
f0102673:	7e 17                	jle    f010268c <readline+0x9c>
			if (echoing)
f0102675:	85 ff                	test   %edi,%edi
f0102677:	74 08                	je     f0102681 <readline+0x91>
				cputchar(c);
f0102679:	89 1c 24             	mov    %ebx,(%esp)
f010267c:	e8 70 df ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0102681:	88 9e 60 55 11 f0    	mov    %bl,-0xfeeaaa0(%esi)
f0102687:	8d 76 01             	lea    0x1(%esi),%esi
f010268a:	eb 97                	jmp    f0102623 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010268c:	83 fb 0d             	cmp    $0xd,%ebx
f010268f:	74 05                	je     f0102696 <readline+0xa6>
f0102691:	83 fb 0a             	cmp    $0xa,%ebx
f0102694:	75 8d                	jne    f0102623 <readline+0x33>
			if (echoing)
f0102696:	85 ff                	test   %edi,%edi
f0102698:	74 0c                	je     f01026a6 <readline+0xb6>
				cputchar('\n');
f010269a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01026a1:	e8 4b df ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f01026a6:	c6 86 60 55 11 f0 00 	movb   $0x0,-0xfeeaaa0(%esi)
			return buf;
f01026ad:	b8 60 55 11 f0       	mov    $0xf0115560,%eax
		}
	}
}
f01026b2:	83 c4 1c             	add    $0x1c,%esp
f01026b5:	5b                   	pop    %ebx
f01026b6:	5e                   	pop    %esi
f01026b7:	5f                   	pop    %edi
f01026b8:	5d                   	pop    %ebp
f01026b9:	c3                   	ret    
f01026ba:	00 00                	add    %al,(%eax)
f01026bc:	00 00                	add    %al,(%eax)
	...

f01026c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01026c0:	55                   	push   %ebp
f01026c1:	89 e5                	mov    %esp,%ebp
f01026c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01026c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01026cb:	eb 03                	jmp    f01026d0 <strlen+0x10>
		n++;
f01026cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01026d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01026d4:	75 f7                	jne    f01026cd <strlen+0xd>
		n++;
	return n;
}
f01026d6:	5d                   	pop    %ebp
f01026d7:	c3                   	ret    

f01026d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01026d8:	55                   	push   %ebp
f01026d9:	89 e5                	mov    %esp,%ebp
f01026db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01026de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01026e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01026e6:	eb 03                	jmp    f01026eb <strnlen+0x13>
		n++;
f01026e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01026eb:	39 d0                	cmp    %edx,%eax
f01026ed:	74 06                	je     f01026f5 <strnlen+0x1d>
f01026ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01026f3:	75 f3                	jne    f01026e8 <strnlen+0x10>
		n++;
	return n;
}
f01026f5:	5d                   	pop    %ebp
f01026f6:	c3                   	ret    

f01026f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01026f7:	55                   	push   %ebp
f01026f8:	89 e5                	mov    %esp,%ebp
f01026fa:	53                   	push   %ebx
f01026fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01026fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102701:	89 c2                	mov    %eax,%edx
f0102703:	83 c2 01             	add    $0x1,%edx
f0102706:	83 c1 01             	add    $0x1,%ecx
f0102709:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010270d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0102710:	84 db                	test   %bl,%bl
f0102712:	75 ef                	jne    f0102703 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0102714:	5b                   	pop    %ebx
f0102715:	5d                   	pop    %ebp
f0102716:	c3                   	ret    

f0102717 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102717:	55                   	push   %ebp
f0102718:	89 e5                	mov    %esp,%ebp
f010271a:	53                   	push   %ebx
f010271b:	83 ec 08             	sub    $0x8,%esp
f010271e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0102721:	89 1c 24             	mov    %ebx,(%esp)
f0102724:	e8 97 ff ff ff       	call   f01026c0 <strlen>
	strcpy(dst + len, src);
f0102729:	8b 55 0c             	mov    0xc(%ebp),%edx
f010272c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102730:	01 d8                	add    %ebx,%eax
f0102732:	89 04 24             	mov    %eax,(%esp)
f0102735:	e8 bd ff ff ff       	call   f01026f7 <strcpy>
	return dst;
}
f010273a:	89 d8                	mov    %ebx,%eax
f010273c:	83 c4 08             	add    $0x8,%esp
f010273f:	5b                   	pop    %ebx
f0102740:	5d                   	pop    %ebp
f0102741:	c3                   	ret    

f0102742 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102742:	55                   	push   %ebp
f0102743:	89 e5                	mov    %esp,%ebp
f0102745:	56                   	push   %esi
f0102746:	53                   	push   %ebx
f0102747:	8b 75 08             	mov    0x8(%ebp),%esi
f010274a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010274d:	89 f3                	mov    %esi,%ebx
f010274f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102752:	89 f2                	mov    %esi,%edx
f0102754:	eb 0f                	jmp    f0102765 <strncpy+0x23>
		*dst++ = *src;
f0102756:	83 c2 01             	add    $0x1,%edx
f0102759:	0f b6 01             	movzbl (%ecx),%eax
f010275c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010275f:	80 39 01             	cmpb   $0x1,(%ecx)
f0102762:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102765:	39 da                	cmp    %ebx,%edx
f0102767:	75 ed                	jne    f0102756 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102769:	89 f0                	mov    %esi,%eax
f010276b:	5b                   	pop    %ebx
f010276c:	5e                   	pop    %esi
f010276d:	5d                   	pop    %ebp
f010276e:	c3                   	ret    

f010276f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010276f:	55                   	push   %ebp
f0102770:	89 e5                	mov    %esp,%ebp
f0102772:	56                   	push   %esi
f0102773:	53                   	push   %ebx
f0102774:	8b 75 08             	mov    0x8(%ebp),%esi
f0102777:	8b 55 0c             	mov    0xc(%ebp),%edx
f010277a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010277d:	89 f0                	mov    %esi,%eax
f010277f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102783:	85 c9                	test   %ecx,%ecx
f0102785:	75 0b                	jne    f0102792 <strlcpy+0x23>
f0102787:	eb 1d                	jmp    f01027a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102789:	83 c0 01             	add    $0x1,%eax
f010278c:	83 c2 01             	add    $0x1,%edx
f010278f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102792:	39 d8                	cmp    %ebx,%eax
f0102794:	74 0b                	je     f01027a1 <strlcpy+0x32>
f0102796:	0f b6 0a             	movzbl (%edx),%ecx
f0102799:	84 c9                	test   %cl,%cl
f010279b:	75 ec                	jne    f0102789 <strlcpy+0x1a>
f010279d:	89 c2                	mov    %eax,%edx
f010279f:	eb 02                	jmp    f01027a3 <strlcpy+0x34>
f01027a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01027a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01027a6:	29 f0                	sub    %esi,%eax
}
f01027a8:	5b                   	pop    %ebx
f01027a9:	5e                   	pop    %esi
f01027aa:	5d                   	pop    %ebp
f01027ab:	c3                   	ret    

f01027ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01027ac:	55                   	push   %ebp
f01027ad:	89 e5                	mov    %esp,%ebp
f01027af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01027b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01027b5:	eb 06                	jmp    f01027bd <strcmp+0x11>
		p++, q++;
f01027b7:	83 c1 01             	add    $0x1,%ecx
f01027ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01027bd:	0f b6 01             	movzbl (%ecx),%eax
f01027c0:	84 c0                	test   %al,%al
f01027c2:	74 04                	je     f01027c8 <strcmp+0x1c>
f01027c4:	3a 02                	cmp    (%edx),%al
f01027c6:	74 ef                	je     f01027b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01027c8:	0f b6 c0             	movzbl %al,%eax
f01027cb:	0f b6 12             	movzbl (%edx),%edx
f01027ce:	29 d0                	sub    %edx,%eax
}
f01027d0:	5d                   	pop    %ebp
f01027d1:	c3                   	ret    

f01027d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01027d2:	55                   	push   %ebp
f01027d3:	89 e5                	mov    %esp,%ebp
f01027d5:	53                   	push   %ebx
f01027d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01027d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01027dc:	89 c3                	mov    %eax,%ebx
f01027de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01027e1:	eb 06                	jmp    f01027e9 <strncmp+0x17>
		n--, p++, q++;
f01027e3:	83 c0 01             	add    $0x1,%eax
f01027e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01027e9:	39 d8                	cmp    %ebx,%eax
f01027eb:	74 15                	je     f0102802 <strncmp+0x30>
f01027ed:	0f b6 08             	movzbl (%eax),%ecx
f01027f0:	84 c9                	test   %cl,%cl
f01027f2:	74 04                	je     f01027f8 <strncmp+0x26>
f01027f4:	3a 0a                	cmp    (%edx),%cl
f01027f6:	74 eb                	je     f01027e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01027f8:	0f b6 00             	movzbl (%eax),%eax
f01027fb:	0f b6 12             	movzbl (%edx),%edx
f01027fe:	29 d0                	sub    %edx,%eax
f0102800:	eb 05                	jmp    f0102807 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102802:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102807:	5b                   	pop    %ebx
f0102808:	5d                   	pop    %ebp
f0102809:	c3                   	ret    

f010280a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010280a:	55                   	push   %ebp
f010280b:	89 e5                	mov    %esp,%ebp
f010280d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102810:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102814:	eb 07                	jmp    f010281d <strchr+0x13>
		if (*s == c)
f0102816:	38 ca                	cmp    %cl,%dl
f0102818:	74 0f                	je     f0102829 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010281a:	83 c0 01             	add    $0x1,%eax
f010281d:	0f b6 10             	movzbl (%eax),%edx
f0102820:	84 d2                	test   %dl,%dl
f0102822:	75 f2                	jne    f0102816 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0102824:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102829:	5d                   	pop    %ebp
f010282a:	c3                   	ret    

f010282b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010282b:	55                   	push   %ebp
f010282c:	89 e5                	mov    %esp,%ebp
f010282e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102835:	eb 07                	jmp    f010283e <strfind+0x13>
		if (*s == c)
f0102837:	38 ca                	cmp    %cl,%dl
f0102839:	74 0a                	je     f0102845 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010283b:	83 c0 01             	add    $0x1,%eax
f010283e:	0f b6 10             	movzbl (%eax),%edx
f0102841:	84 d2                	test   %dl,%dl
f0102843:	75 f2                	jne    f0102837 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0102845:	5d                   	pop    %ebp
f0102846:	c3                   	ret    

f0102847 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102847:	55                   	push   %ebp
f0102848:	89 e5                	mov    %esp,%ebp
f010284a:	57                   	push   %edi
f010284b:	56                   	push   %esi
f010284c:	53                   	push   %ebx
f010284d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102850:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0102853:	85 c9                	test   %ecx,%ecx
f0102855:	74 36                	je     f010288d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0102857:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010285d:	75 28                	jne    f0102887 <memset+0x40>
f010285f:	f6 c1 03             	test   $0x3,%cl
f0102862:	75 23                	jne    f0102887 <memset+0x40>
		c &= 0xFF;
f0102864:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0102868:	89 d3                	mov    %edx,%ebx
f010286a:	c1 e3 08             	shl    $0x8,%ebx
f010286d:	89 d6                	mov    %edx,%esi
f010286f:	c1 e6 18             	shl    $0x18,%esi
f0102872:	89 d0                	mov    %edx,%eax
f0102874:	c1 e0 10             	shl    $0x10,%eax
f0102877:	09 f0                	or     %esi,%eax
f0102879:	09 c2                	or     %eax,%edx
f010287b:	89 d0                	mov    %edx,%eax
f010287d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010287f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102882:	fc                   	cld    
f0102883:	f3 ab                	rep stos %eax,%es:(%edi)
f0102885:	eb 06                	jmp    f010288d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102887:	8b 45 0c             	mov    0xc(%ebp),%eax
f010288a:	fc                   	cld    
f010288b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010288d:	89 f8                	mov    %edi,%eax
f010288f:	5b                   	pop    %ebx
f0102890:	5e                   	pop    %esi
f0102891:	5f                   	pop    %edi
f0102892:	5d                   	pop    %ebp
f0102893:	c3                   	ret    

f0102894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102894:	55                   	push   %ebp
f0102895:	89 e5                	mov    %esp,%ebp
f0102897:	57                   	push   %edi
f0102898:	56                   	push   %esi
f0102899:	8b 45 08             	mov    0x8(%ebp),%eax
f010289c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010289f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01028a2:	39 c6                	cmp    %eax,%esi
f01028a4:	73 35                	jae    f01028db <memmove+0x47>
f01028a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01028a9:	39 d0                	cmp    %edx,%eax
f01028ab:	73 2e                	jae    f01028db <memmove+0x47>
		s += n;
		d += n;
f01028ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01028b0:	89 d6                	mov    %edx,%esi
f01028b2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01028b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01028ba:	75 13                	jne    f01028cf <memmove+0x3b>
f01028bc:	f6 c1 03             	test   $0x3,%cl
f01028bf:	75 0e                	jne    f01028cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01028c1:	83 ef 04             	sub    $0x4,%edi
f01028c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01028c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01028ca:	fd                   	std    
f01028cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01028cd:	eb 09                	jmp    f01028d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01028cf:	83 ef 01             	sub    $0x1,%edi
f01028d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01028d5:	fd                   	std    
f01028d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01028d8:	fc                   	cld    
f01028d9:	eb 1d                	jmp    f01028f8 <memmove+0x64>
f01028db:	89 f2                	mov    %esi,%edx
f01028dd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01028df:	f6 c2 03             	test   $0x3,%dl
f01028e2:	75 0f                	jne    f01028f3 <memmove+0x5f>
f01028e4:	f6 c1 03             	test   $0x3,%cl
f01028e7:	75 0a                	jne    f01028f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01028e9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01028ec:	89 c7                	mov    %eax,%edi
f01028ee:	fc                   	cld    
f01028ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01028f1:	eb 05                	jmp    f01028f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01028f3:	89 c7                	mov    %eax,%edi
f01028f5:	fc                   	cld    
f01028f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01028f8:	5e                   	pop    %esi
f01028f9:	5f                   	pop    %edi
f01028fa:	5d                   	pop    %ebp
f01028fb:	c3                   	ret    

f01028fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01028fc:	55                   	push   %ebp
f01028fd:	89 e5                	mov    %esp,%ebp
f01028ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102902:	8b 45 10             	mov    0x10(%ebp),%eax
f0102905:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102909:	8b 45 0c             	mov    0xc(%ebp),%eax
f010290c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102910:	8b 45 08             	mov    0x8(%ebp),%eax
f0102913:	89 04 24             	mov    %eax,(%esp)
f0102916:	e8 79 ff ff ff       	call   f0102894 <memmove>
}
f010291b:	c9                   	leave  
f010291c:	c3                   	ret    

f010291d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010291d:	55                   	push   %ebp
f010291e:	89 e5                	mov    %esp,%ebp
f0102920:	56                   	push   %esi
f0102921:	53                   	push   %ebx
f0102922:	8b 55 08             	mov    0x8(%ebp),%edx
f0102925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102928:	89 d6                	mov    %edx,%esi
f010292a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010292d:	eb 1a                	jmp    f0102949 <memcmp+0x2c>
		if (*s1 != *s2)
f010292f:	0f b6 02             	movzbl (%edx),%eax
f0102932:	0f b6 19             	movzbl (%ecx),%ebx
f0102935:	38 d8                	cmp    %bl,%al
f0102937:	74 0a                	je     f0102943 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0102939:	0f b6 c0             	movzbl %al,%eax
f010293c:	0f b6 db             	movzbl %bl,%ebx
f010293f:	29 d8                	sub    %ebx,%eax
f0102941:	eb 0f                	jmp    f0102952 <memcmp+0x35>
		s1++, s2++;
f0102943:	83 c2 01             	add    $0x1,%edx
f0102946:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102949:	39 f2                	cmp    %esi,%edx
f010294b:	75 e2                	jne    f010292f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010294d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102952:	5b                   	pop    %ebx
f0102953:	5e                   	pop    %esi
f0102954:	5d                   	pop    %ebp
f0102955:	c3                   	ret    

f0102956 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102956:	55                   	push   %ebp
f0102957:	89 e5                	mov    %esp,%ebp
f0102959:	8b 45 08             	mov    0x8(%ebp),%eax
f010295c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010295f:	89 c2                	mov    %eax,%edx
f0102961:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102964:	eb 07                	jmp    f010296d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102966:	38 08                	cmp    %cl,(%eax)
f0102968:	74 07                	je     f0102971 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010296a:	83 c0 01             	add    $0x1,%eax
f010296d:	39 d0                	cmp    %edx,%eax
f010296f:	72 f5                	jb     f0102966 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102971:	5d                   	pop    %ebp
f0102972:	c3                   	ret    

f0102973 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102973:	55                   	push   %ebp
f0102974:	89 e5                	mov    %esp,%ebp
f0102976:	57                   	push   %edi
f0102977:	56                   	push   %esi
f0102978:	53                   	push   %ebx
f0102979:	8b 55 08             	mov    0x8(%ebp),%edx
f010297c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010297f:	eb 03                	jmp    f0102984 <strtol+0x11>
		s++;
f0102981:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102984:	0f b6 0a             	movzbl (%edx),%ecx
f0102987:	80 f9 09             	cmp    $0x9,%cl
f010298a:	74 f5                	je     f0102981 <strtol+0xe>
f010298c:	80 f9 20             	cmp    $0x20,%cl
f010298f:	74 f0                	je     f0102981 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102991:	80 f9 2b             	cmp    $0x2b,%cl
f0102994:	75 0a                	jne    f01029a0 <strtol+0x2d>
		s++;
f0102996:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102999:	bf 00 00 00 00       	mov    $0x0,%edi
f010299e:	eb 11                	jmp    f01029b1 <strtol+0x3e>
f01029a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01029a5:	80 f9 2d             	cmp    $0x2d,%cl
f01029a8:	75 07                	jne    f01029b1 <strtol+0x3e>
		s++, neg = 1;
f01029aa:	8d 52 01             	lea    0x1(%edx),%edx
f01029ad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01029b1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01029b6:	75 15                	jne    f01029cd <strtol+0x5a>
f01029b8:	80 3a 30             	cmpb   $0x30,(%edx)
f01029bb:	75 10                	jne    f01029cd <strtol+0x5a>
f01029bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01029c1:	75 0a                	jne    f01029cd <strtol+0x5a>
		s += 2, base = 16;
f01029c3:	83 c2 02             	add    $0x2,%edx
f01029c6:	b8 10 00 00 00       	mov    $0x10,%eax
f01029cb:	eb 10                	jmp    f01029dd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f01029cd:	85 c0                	test   %eax,%eax
f01029cf:	75 0c                	jne    f01029dd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01029d1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01029d3:	80 3a 30             	cmpb   $0x30,(%edx)
f01029d6:	75 05                	jne    f01029dd <strtol+0x6a>
		s++, base = 8;
f01029d8:	83 c2 01             	add    $0x1,%edx
f01029db:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f01029dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01029e2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01029e5:	0f b6 0a             	movzbl (%edx),%ecx
f01029e8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01029eb:	89 f0                	mov    %esi,%eax
f01029ed:	3c 09                	cmp    $0x9,%al
f01029ef:	77 08                	ja     f01029f9 <strtol+0x86>
			dig = *s - '0';
f01029f1:	0f be c9             	movsbl %cl,%ecx
f01029f4:	83 e9 30             	sub    $0x30,%ecx
f01029f7:	eb 20                	jmp    f0102a19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01029f9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01029fc:	89 f0                	mov    %esi,%eax
f01029fe:	3c 19                	cmp    $0x19,%al
f0102a00:	77 08                	ja     f0102a0a <strtol+0x97>
			dig = *s - 'a' + 10;
f0102a02:	0f be c9             	movsbl %cl,%ecx
f0102a05:	83 e9 57             	sub    $0x57,%ecx
f0102a08:	eb 0f                	jmp    f0102a19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0102a0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0102a0d:	89 f0                	mov    %esi,%eax
f0102a0f:	3c 19                	cmp    $0x19,%al
f0102a11:	77 16                	ja     f0102a29 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0102a13:	0f be c9             	movsbl %cl,%ecx
f0102a16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102a19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0102a1c:	7d 0f                	jge    f0102a2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0102a1e:	83 c2 01             	add    $0x1,%edx
f0102a21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0102a25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0102a27:	eb bc                	jmp    f01029e5 <strtol+0x72>
f0102a29:	89 d8                	mov    %ebx,%eax
f0102a2b:	eb 02                	jmp    f0102a2f <strtol+0xbc>
f0102a2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0102a2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0102a33:	74 05                	je     f0102a3a <strtol+0xc7>
		*endptr = (char *) s;
f0102a35:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102a38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0102a3a:	f7 d8                	neg    %eax
f0102a3c:	85 ff                	test   %edi,%edi
f0102a3e:	0f 44 c3             	cmove  %ebx,%eax
}
f0102a41:	5b                   	pop    %ebx
f0102a42:	5e                   	pop    %esi
f0102a43:	5f                   	pop    %edi
f0102a44:	5d                   	pop    %ebp
f0102a45:	c3                   	ret    
	...

f0102a50 <__udivdi3>:
f0102a50:	83 ec 1c             	sub    $0x1c,%esp
f0102a53:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102a57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0102a5b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102a5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102a63:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102a67:	8b 74 24 24          	mov    0x24(%esp),%esi
f0102a6b:	85 ff                	test   %edi,%edi
f0102a6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102a71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102a75:	89 cd                	mov    %ecx,%ebp
f0102a77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a7b:	75 33                	jne    f0102ab0 <__udivdi3+0x60>
f0102a7d:	39 f1                	cmp    %esi,%ecx
f0102a7f:	77 57                	ja     f0102ad8 <__udivdi3+0x88>
f0102a81:	85 c9                	test   %ecx,%ecx
f0102a83:	75 0b                	jne    f0102a90 <__udivdi3+0x40>
f0102a85:	b8 01 00 00 00       	mov    $0x1,%eax
f0102a8a:	31 d2                	xor    %edx,%edx
f0102a8c:	f7 f1                	div    %ecx
f0102a8e:	89 c1                	mov    %eax,%ecx
f0102a90:	89 f0                	mov    %esi,%eax
f0102a92:	31 d2                	xor    %edx,%edx
f0102a94:	f7 f1                	div    %ecx
f0102a96:	89 c6                	mov    %eax,%esi
f0102a98:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102a9c:	f7 f1                	div    %ecx
f0102a9e:	89 f2                	mov    %esi,%edx
f0102aa0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102aa4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102aa8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102aac:	83 c4 1c             	add    $0x1c,%esp
f0102aaf:	c3                   	ret    
f0102ab0:	31 d2                	xor    %edx,%edx
f0102ab2:	31 c0                	xor    %eax,%eax
f0102ab4:	39 f7                	cmp    %esi,%edi
f0102ab6:	77 e8                	ja     f0102aa0 <__udivdi3+0x50>
f0102ab8:	0f bd cf             	bsr    %edi,%ecx
f0102abb:	83 f1 1f             	xor    $0x1f,%ecx
f0102abe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102ac2:	75 2c                	jne    f0102af0 <__udivdi3+0xa0>
f0102ac4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0102ac8:	76 04                	jbe    f0102ace <__udivdi3+0x7e>
f0102aca:	39 f7                	cmp    %esi,%edi
f0102acc:	73 d2                	jae    f0102aa0 <__udivdi3+0x50>
f0102ace:	31 d2                	xor    %edx,%edx
f0102ad0:	b8 01 00 00 00       	mov    $0x1,%eax
f0102ad5:	eb c9                	jmp    f0102aa0 <__udivdi3+0x50>
f0102ad7:	90                   	nop
f0102ad8:	89 f2                	mov    %esi,%edx
f0102ada:	f7 f1                	div    %ecx
f0102adc:	31 d2                	xor    %edx,%edx
f0102ade:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102ae2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102ae6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102aea:	83 c4 1c             	add    $0x1c,%esp
f0102aed:	c3                   	ret    
f0102aee:	66 90                	xchg   %ax,%ax
f0102af0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102af5:	b8 20 00 00 00       	mov    $0x20,%eax
f0102afa:	89 ea                	mov    %ebp,%edx
f0102afc:	2b 44 24 04          	sub    0x4(%esp),%eax
f0102b00:	d3 e7                	shl    %cl,%edi
f0102b02:	89 c1                	mov    %eax,%ecx
f0102b04:	d3 ea                	shr    %cl,%edx
f0102b06:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102b0b:	09 fa                	or     %edi,%edx
f0102b0d:	89 f7                	mov    %esi,%edi
f0102b0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b13:	89 f2                	mov    %esi,%edx
f0102b15:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102b19:	d3 e5                	shl    %cl,%ebp
f0102b1b:	89 c1                	mov    %eax,%ecx
f0102b1d:	d3 ef                	shr    %cl,%edi
f0102b1f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102b24:	d3 e2                	shl    %cl,%edx
f0102b26:	89 c1                	mov    %eax,%ecx
f0102b28:	d3 ee                	shr    %cl,%esi
f0102b2a:	09 d6                	or     %edx,%esi
f0102b2c:	89 fa                	mov    %edi,%edx
f0102b2e:	89 f0                	mov    %esi,%eax
f0102b30:	f7 74 24 0c          	divl   0xc(%esp)
f0102b34:	89 d7                	mov    %edx,%edi
f0102b36:	89 c6                	mov    %eax,%esi
f0102b38:	f7 e5                	mul    %ebp
f0102b3a:	39 d7                	cmp    %edx,%edi
f0102b3c:	72 22                	jb     f0102b60 <__udivdi3+0x110>
f0102b3e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0102b42:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102b47:	d3 e5                	shl    %cl,%ebp
f0102b49:	39 c5                	cmp    %eax,%ebp
f0102b4b:	73 04                	jae    f0102b51 <__udivdi3+0x101>
f0102b4d:	39 d7                	cmp    %edx,%edi
f0102b4f:	74 0f                	je     f0102b60 <__udivdi3+0x110>
f0102b51:	89 f0                	mov    %esi,%eax
f0102b53:	31 d2                	xor    %edx,%edx
f0102b55:	e9 46 ff ff ff       	jmp    f0102aa0 <__udivdi3+0x50>
f0102b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102b60:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102b63:	31 d2                	xor    %edx,%edx
f0102b65:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102b69:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102b6d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102b71:	83 c4 1c             	add    $0x1c,%esp
f0102b74:	c3                   	ret    
	...

f0102b80 <__umoddi3>:
f0102b80:	83 ec 1c             	sub    $0x1c,%esp
f0102b83:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102b87:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0102b8b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102b8f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102b93:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102b97:	8b 74 24 24          	mov    0x24(%esp),%esi
f0102b9b:	85 ed                	test   %ebp,%ebp
f0102b9d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ba5:	89 cf                	mov    %ecx,%edi
f0102ba7:	89 04 24             	mov    %eax,(%esp)
f0102baa:	89 f2                	mov    %esi,%edx
f0102bac:	75 1a                	jne    f0102bc8 <__umoddi3+0x48>
f0102bae:	39 f1                	cmp    %esi,%ecx
f0102bb0:	76 4e                	jbe    f0102c00 <__umoddi3+0x80>
f0102bb2:	f7 f1                	div    %ecx
f0102bb4:	89 d0                	mov    %edx,%eax
f0102bb6:	31 d2                	xor    %edx,%edx
f0102bb8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102bbc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102bc0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102bc4:	83 c4 1c             	add    $0x1c,%esp
f0102bc7:	c3                   	ret    
f0102bc8:	39 f5                	cmp    %esi,%ebp
f0102bca:	77 54                	ja     f0102c20 <__umoddi3+0xa0>
f0102bcc:	0f bd c5             	bsr    %ebp,%eax
f0102bcf:	83 f0 1f             	xor    $0x1f,%eax
f0102bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bd6:	75 60                	jne    f0102c38 <__umoddi3+0xb8>
f0102bd8:	3b 0c 24             	cmp    (%esp),%ecx
f0102bdb:	0f 87 07 01 00 00    	ja     f0102ce8 <__umoddi3+0x168>
f0102be1:	89 f2                	mov    %esi,%edx
f0102be3:	8b 34 24             	mov    (%esp),%esi
f0102be6:	29 ce                	sub    %ecx,%esi
f0102be8:	19 ea                	sbb    %ebp,%edx
f0102bea:	89 34 24             	mov    %esi,(%esp)
f0102bed:	8b 04 24             	mov    (%esp),%eax
f0102bf0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102bf4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102bf8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102bfc:	83 c4 1c             	add    $0x1c,%esp
f0102bff:	c3                   	ret    
f0102c00:	85 c9                	test   %ecx,%ecx
f0102c02:	75 0b                	jne    f0102c0f <__umoddi3+0x8f>
f0102c04:	b8 01 00 00 00       	mov    $0x1,%eax
f0102c09:	31 d2                	xor    %edx,%edx
f0102c0b:	f7 f1                	div    %ecx
f0102c0d:	89 c1                	mov    %eax,%ecx
f0102c0f:	89 f0                	mov    %esi,%eax
f0102c11:	31 d2                	xor    %edx,%edx
f0102c13:	f7 f1                	div    %ecx
f0102c15:	8b 04 24             	mov    (%esp),%eax
f0102c18:	f7 f1                	div    %ecx
f0102c1a:	eb 98                	jmp    f0102bb4 <__umoddi3+0x34>
f0102c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102c20:	89 f2                	mov    %esi,%edx
f0102c22:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102c26:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102c2a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102c2e:	83 c4 1c             	add    $0x1c,%esp
f0102c31:	c3                   	ret    
f0102c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102c38:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102c3d:	89 e8                	mov    %ebp,%eax
f0102c3f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0102c44:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0102c48:	89 fa                	mov    %edi,%edx
f0102c4a:	d3 e0                	shl    %cl,%eax
f0102c4c:	89 e9                	mov    %ebp,%ecx
f0102c4e:	d3 ea                	shr    %cl,%edx
f0102c50:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102c55:	09 c2                	or     %eax,%edx
f0102c57:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102c5b:	89 14 24             	mov    %edx,(%esp)
f0102c5e:	89 f2                	mov    %esi,%edx
f0102c60:	d3 e7                	shl    %cl,%edi
f0102c62:	89 e9                	mov    %ebp,%ecx
f0102c64:	d3 ea                	shr    %cl,%edx
f0102c66:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102c6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102c6f:	d3 e6                	shl    %cl,%esi
f0102c71:	89 e9                	mov    %ebp,%ecx
f0102c73:	d3 e8                	shr    %cl,%eax
f0102c75:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102c7a:	09 f0                	or     %esi,%eax
f0102c7c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102c80:	f7 34 24             	divl   (%esp)
f0102c83:	d3 e6                	shl    %cl,%esi
f0102c85:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102c89:	89 d6                	mov    %edx,%esi
f0102c8b:	f7 e7                	mul    %edi
f0102c8d:	39 d6                	cmp    %edx,%esi
f0102c8f:	89 c1                	mov    %eax,%ecx
f0102c91:	89 d7                	mov    %edx,%edi
f0102c93:	72 3f                	jb     f0102cd4 <__umoddi3+0x154>
f0102c95:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0102c99:	72 35                	jb     f0102cd0 <__umoddi3+0x150>
f0102c9b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102c9f:	29 c8                	sub    %ecx,%eax
f0102ca1:	19 fe                	sbb    %edi,%esi
f0102ca3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102ca8:	89 f2                	mov    %esi,%edx
f0102caa:	d3 e8                	shr    %cl,%eax
f0102cac:	89 e9                	mov    %ebp,%ecx
f0102cae:	d3 e2                	shl    %cl,%edx
f0102cb0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102cb5:	09 d0                	or     %edx,%eax
f0102cb7:	89 f2                	mov    %esi,%edx
f0102cb9:	d3 ea                	shr    %cl,%edx
f0102cbb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102cbf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102cc3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102cc7:	83 c4 1c             	add    $0x1c,%esp
f0102cca:	c3                   	ret    
f0102ccb:	90                   	nop
f0102ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102cd0:	39 d6                	cmp    %edx,%esi
f0102cd2:	75 c7                	jne    f0102c9b <__umoddi3+0x11b>
f0102cd4:	89 d7                	mov    %edx,%edi
f0102cd6:	89 c1                	mov    %eax,%ecx
f0102cd8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0102cdc:	1b 3c 24             	sbb    (%esp),%edi
f0102cdf:	eb ba                	jmp    f0102c9b <__umoddi3+0x11b>
f0102ce1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102ce8:	39 f5                	cmp    %esi,%ebp
f0102cea:	0f 82 f1 fe ff ff    	jb     f0102be1 <__umoddi3+0x61>
f0102cf0:	e9 f8 fe ff ff       	jmp    f0102bed <__umoddi3+0x6d>
