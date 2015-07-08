
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
f0100046:	b8 70 39 11 f0       	mov    $0xf0113970,%eax
f010004b:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f0100063:	e8 0f 1a 00 00       	call   f0101a77 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f010007c:	e8 a7 0e 00 00       	call   f0100f28 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 34 09 00 00       	call   f01009ba <mem_init>

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
f010009f:	83 3d 60 39 11 f0 00 	cmpl   $0x0,0xf0113960
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 39 11 f0    	mov    %esi,0xf0113960

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
f01000c1:	c7 04 24 3b 1f 10 f0 	movl   $0xf0101f3b,(%esp)
f01000c8:	e8 5b 0e 00 00       	call   f0100f28 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 1c 0e 00 00       	call   f0100ef5 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f01000e0:	e8 43 0e 00 00       	call   f0100f28 <cprintf>
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
f010010b:	c7 04 24 53 1f 10 f0 	movl   $0xf0101f53,(%esp)
f0100112:	e8 11 0e 00 00       	call   f0100f28 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 cf 0d 00 00       	call   f0100ef5 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f010012d:	e8 f6 0d 00 00       	call   f0100f28 <cprintf>
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
f010016b:	a1 24 35 11 f0       	mov    0xf0113524,%eax
f0100170:	8d 48 01             	lea    0x1(%eax),%ecx
f0100173:	89 0d 24 35 11 f0    	mov    %ecx,0xf0113524
f0100179:	88 90 20 33 11 f0    	mov    %dl,-0xfeecce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010017f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100185:	75 0a                	jne    f0100191 <cons_intr+0x35>
			cons.wpos = 0;
f0100187:	c7 05 24 35 11 f0 00 	movl   $0x0,0xf0113524
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
f01001b7:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
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
f01001cf:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001d5:	89 cb                	mov    %ecx,%ebx
f01001d7:	83 e3 40             	and    $0x40,%ebx
f01001da:	83 e0 7f             	and    $0x7f,%eax
f01001dd:	85 db                	test   %ebx,%ebx
f01001df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e2:	0f b6 d2             	movzbl %dl,%edx
f01001e5:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f01001ec:	83 c8 40             	or     $0x40,%eax
f01001ef:	0f b6 c0             	movzbl %al,%eax
f01001f2:	f7 d0                	not    %eax
f01001f4:	21 c1                	and    %eax,%ecx
f01001f6:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
		return 0;
f01001fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100201:	e9 9d 00 00 00       	jmp    f01002a3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100206:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f010020c:	f6 c1 40             	test   $0x40,%cl
f010020f:	74 0e                	je     f010021f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100211:	83 c8 80             	or     $0xffffff80,%eax
f0100214:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100216:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100219:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
	}

	shift |= shiftcode[data];
f010021f:	0f b6 d2             	movzbl %dl,%edx
f0100222:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f0100229:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a c0 1f 10 f0 	movzbl -0xfefe040(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d a0 1f 10 f0 	mov    -0xfefe060(,%ecx,4),%ecx
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
f0100282:	c7 04 24 6d 1f 10 f0 	movl   $0xf0101f6d,(%esp)
f0100289:	e8 9a 0c 00 00       	call   f0100f28 <cprintf>
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
f010035c:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f0100363:	66 85 c0             	test   %ax,%ax
f0100366:	0f 84 e5 00 00 00    	je     f0100451 <cons_putc+0x1a8>
			crt_pos--;
f010036c:	83 e8 01             	sub    $0x1,%eax
f010036f:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100375:	0f b7 c0             	movzwl %ax,%eax
f0100378:	66 81 e7 00 ff       	and    $0xff00,%di
f010037d:	83 cf 20             	or     $0x20,%edi
f0100380:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100386:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038a:	eb 78                	jmp    f0100404 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038c:	66 83 05 28 35 11 f0 	addw   $0x50,0xf0113528
f0100393:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100394:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010039b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a1:	c1 e8 16             	shr    $0x16,%eax
f01003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a7:	c1 e0 04             	shl    $0x4,%eax
f01003aa:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
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
f01003e6:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f01003ed:	8d 50 01             	lea    0x1(%eax),%edx
f01003f0:	66 89 15 28 35 11 f0 	mov    %dx,0xf0113528
f01003f7:	0f b7 c0             	movzwl %ax,%eax
f01003fa:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100400:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100404:	66 81 3d 28 35 11 f0 	cmpw   $0x7cf,0xf0113528
f010040b:	cf 07 
f010040d:	76 42                	jbe    f0100451 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040f:	a1 2c 35 11 f0       	mov    0xf011352c,%eax
f0100414:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010041b:	00 
f010041c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100422:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100426:	89 04 24             	mov    %eax,(%esp)
f0100429:	e8 96 16 00 00       	call   f0101ac4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042e:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
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
f0100449:	66 83 2d 28 35 11 f0 	subw   $0x50,0xf0113528
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 35 11 f0 	movzwl 0xf0113528,%ebx
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
f0100487:	80 3d 34 35 11 f0 00 	cmpb   $0x0,0xf0113534
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
f01004c5:	a1 20 35 11 f0       	mov    0xf0113520,%eax
f01004ca:	3b 05 24 35 11 f0    	cmp    0xf0113524,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
f01004db:	0f b6 88 20 33 11 f0 	movzbl -0xfeecce0(%eax),%ecx
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
f01004ec:	c7 05 20 35 11 f0 00 	movl   $0x0,0xf0113520
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
f0100525:	c7 05 30 35 11 f0 b4 	movl   $0x3b4,0xf0113530
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
f010053d:	c7 05 30 35 11 f0 d4 	movl   $0x3d4,0xf0113530
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
f010054c:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
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
f0100571:	89 3d 2c 35 11 f0    	mov    %edi,0xf011352c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100577:	0f b6 d8             	movzbl %al,%ebx
f010057a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057c:	66 89 35 28 35 11 f0 	mov    %si,0xf0113528
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
f01005cd:	88 0d 34 35 11 f0    	mov    %cl,0xf0113534
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
f01005dd:	c7 04 24 79 1f 10 f0 	movl   $0xf0101f79,(%esp)
f01005e4:	e8 3f 09 00 00       	call   f0100f28 <cprintf>
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
f0100626:	c7 44 24 08 c0 21 10 	movl   $0xf01021c0,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 de 21 10 	movl   $0xf01021de,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 e3 21 10 f0 	movl   $0xf01021e3,(%esp)
f010063d:	e8 e6 08 00 00       	call   f0100f28 <cprintf>
f0100642:	c7 44 24 08 80 22 10 	movl   $0xf0102280,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 ec 21 10 	movl   $0xf01021ec,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 e3 21 10 f0 	movl   $0xf01021e3,(%esp)
f0100659:	e8 ca 08 00 00       	call   f0100f28 <cprintf>
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
f010066b:	c7 04 24 f5 21 10 f0 	movl   $0xf01021f5,(%esp)
f0100672:	e8 b1 08 00 00       	call   f0100f28 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 a8 22 10 f0 	movl   $0xf01022a8,(%esp)
f0100686:	e8 9d 08 00 00       	call   f0100f28 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 d0 22 10 f0 	movl   $0xf01022d0,(%esp)
f01006a2:	e8 81 08 00 00       	call   f0100f28 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 07 1f 10 	movl   $0x101f07,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 07 1f 10 	movl   $0xf0101f07,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 f4 22 10 f0 	movl   $0xf01022f4,(%esp)
f01006be:	e8 65 08 00 00       	call   f0100f28 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 18 23 10 f0 	movl   $0xf0102318,(%esp)
f01006da:	e8 49 08 00 00       	call   f0100f28 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 39 11 	movl   $0x113970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 39 11 	movl   $0xf0113970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 3c 23 10 f0 	movl   $0xf010233c,(%esp)
f01006f6:	e8 2d 08 00 00       	call   f0100f28 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006fb:	b8 6f 3d 11 f0       	mov    $0xf0113d6f,%eax
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
f010071c:	c7 04 24 60 23 10 f0 	movl   $0xf0102360,(%esp)
f0100723:	e8 00 08 00 00       	call   f0100f28 <cprintf>
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
f010075e:	e8 bc 08 00 00       	call   f010101f <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 0e 22 10 f0 	movl   $0xf010220e,(%esp)
f0100775:	e8 ae 07 00 00       	call   f0100f28 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 29 22 10 f0 	movl   $0xf0102229,(%esp)
f010078a:	e8 99 07 00 00       	call   f0100f28 <cprintf>
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
f0100796:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f010079d:	e8 86 07 00 00       	call   f0100f28 <cprintf>
			
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
f01007c8:	c7 04 24 30 22 10 f0 	movl   $0xf0102230,(%esp)
f01007cf:	e8 54 07 00 00       	call   f0100f28 <cprintf>
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
f01007fa:	c7 04 24 8c 23 10 f0 	movl   $0xf010238c,(%esp)
f0100801:	e8 22 07 00 00       	call   f0100f28 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 b0 23 10 f0 	movl   $0xf01023b0,(%esp)
f010080d:	e8 16 07 00 00       	call   f0100f28 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 41 22 10 f0 	movl   $0xf0102241,(%esp)
f0100819:	e8 02 10 00 00       	call   f0101820 <readline>
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
f010084a:	c7 04 24 45 22 10 f0 	movl   $0xf0102245,(%esp)
f0100851:	e8 e4 11 00 00       	call   f0101a3a <strchr>
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
f010086c:	c7 04 24 4a 22 10 f0 	movl   $0xf010224a,(%esp)
f0100873:	e8 b0 06 00 00       	call   f0100f28 <cprintf>
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
f0100894:	c7 04 24 45 22 10 f0 	movl   $0xf0102245,(%esp)
f010089b:	e8 9a 11 00 00       	call   f0101a3a <strchr>
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
f01008b6:	c7 44 24 04 de 21 10 	movl   $0xf01021de,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 13 11 00 00       	call   f01019dc <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 ec 21 10 	movl   $0xf01021ec,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 fc 10 00 00       	call   f01019dc <strcmp>
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
f0100903:	ff 14 85 e0 23 10 f0 	call   *-0xfefdc20(,%eax,4)


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
f010091a:	c7 04 24 67 22 10 f0 	movl   $0xf0102267,(%esp)
f0100921:	e8 02 06 00 00       	call   f0100f28 <cprintf>
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
f0100936:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f010093d:	75 11                	jne    f0100950 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f010093f:	ba 6f 49 11 f0       	mov    $0xf011496f,%edx
f0100944:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094a:	89 15 38 35 11 f0    	mov    %edx,0xf0113538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100950:	85 c0                	test   %eax,%eax
f0100952:	75 07                	jne    f010095b <boot_alloc+0x28>
		return nextfree;
f0100954:	a1 38 35 11 f0       	mov    0xf0113538,%eax
f0100959:	eb 19                	jmp    f0100974 <boot_alloc+0x41>
	result = nextfree;
f010095b:	8b 15 38 35 11 f0    	mov    0xf0113538,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100961:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	return result;
f0100972:	89 d0                	mov    %edx,%eax
}
f0100974:	5d                   	pop    %ebp
f0100975:	c3                   	ret    

f0100976 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100976:	55                   	push   %ebp
f0100977:	89 e5                	mov    %esp,%ebp
f0100979:	53                   	push   %ebx
f010097a:	8b 1d 3c 35 11 f0    	mov    0xf011353c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100980:	b8 00 00 00 00       	mov    $0x0,%eax
f0100985:	eb 22                	jmp    f01009a9 <page_init+0x33>
f0100987:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f010098e:	89 d1                	mov    %edx,%ecx
f0100990:	03 0d 6c 39 11 f0    	add    0xf011396c,%ecx
f0100996:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010099c:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010099e:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f01009a1:	89 d3                	mov    %edx,%ebx
f01009a3:	03 1d 6c 39 11 f0    	add    0xf011396c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009a9:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f01009af:	72 d6                	jb     f0100987 <page_init+0x11>
f01009b1:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01009b7:	5b                   	pop    %ebx
f01009b8:	5d                   	pop    %ebp
f01009b9:	c3                   	ret    

f01009ba <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01009ba:	55                   	push   %ebp
f01009bb:	89 e5                	mov    %esp,%ebp
f01009bd:	57                   	push   %edi
f01009be:	56                   	push   %esi
f01009bf:	53                   	push   %ebx
f01009c0:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009c3:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01009ca:	e8 e9 04 00 00       	call   f0100eb8 <mc146818_read>
f01009cf:	89 c3                	mov    %eax,%ebx
f01009d1:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01009d8:	e8 db 04 00 00       	call   f0100eb8 <mc146818_read>
f01009dd:	c1 e0 08             	shl    $0x8,%eax
f01009e0:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01009e2:	89 d8                	mov    %ebx,%eax
f01009e4:	c1 e0 0a             	shl    $0xa,%eax
f01009e7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01009ed:	85 c0                	test   %eax,%eax
f01009ef:	0f 48 c2             	cmovs  %edx,%eax
f01009f2:	c1 f8 0c             	sar    $0xc,%eax
f01009f5:	a3 40 35 11 f0       	mov    %eax,0xf0113540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009fa:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100a01:	e8 b2 04 00 00       	call   f0100eb8 <mc146818_read>
f0100a06:	89 c3                	mov    %eax,%ebx
f0100a08:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0100a0f:	e8 a4 04 00 00       	call   f0100eb8 <mc146818_read>
f0100a14:	c1 e0 08             	shl    $0x8,%eax
f0100a17:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100a19:	89 d8                	mov    %ebx,%eax
f0100a1b:	c1 e0 0a             	shl    $0xa,%eax
f0100a1e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	0f 48 c2             	cmovs  %edx,%eax
f0100a29:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	74 0e                	je     f0100a3e <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100a30:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100a36:	89 15 64 39 11 f0    	mov    %edx,0xf0113964
f0100a3c:	eb 0c                	jmp    f0100a4a <mem_init+0x90>
	else
		npages = npages_basemem;
f0100a3e:	8b 15 40 35 11 f0    	mov    0xf0113540,%edx
f0100a44:	89 15 64 39 11 f0    	mov    %edx,0xf0113964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100a4a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a4d:	c1 e8 0a             	shr    $0xa,%eax
f0100a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100a54:	a1 40 35 11 f0       	mov    0xf0113540,%eax
f0100a59:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a5c:	c1 e8 0a             	shr    $0xa,%eax
f0100a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100a63:	a1 64 39 11 f0       	mov    0xf0113964,%eax
f0100a68:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a6b:	c1 e8 0a             	shr    $0xa,%eax
f0100a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a72:	c7 04 24 f0 23 10 f0 	movl   $0xf01023f0,(%esp)
f0100a79:	e8 aa 04 00 00       	call   f0100f28 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到nextfree，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100a7e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100a83:	e8 ab fe ff ff       	call   f0100933 <boot_alloc>
f0100a88:	a3 68 39 11 f0       	mov    %eax,0xf0113968
	memset(kern_pgdir, 0, PGSIZE);
f0100a8d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100a94:	00 
f0100a95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a9c:	00 
f0100a9d:	89 04 24             	mov    %eax,(%esp)
f0100aa0:	e8 d2 0f 00 00       	call   f0101a77 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100aa5:	a1 68 39 11 f0       	mov    0xf0113968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100aaa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100aaf:	77 20                	ja     f0100ad1 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ab1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ab5:	c7 44 24 08 2c 24 10 	movl   $0xf010242c,0x8(%esp)
f0100abc:	f0 
f0100abd:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f0100ac4:	00 
f0100ac5:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100acc:	e8 c3 f5 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ad1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ad7:	83 ca 05             	or     $0x5,%edx
f0100ada:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0100ae0:	a1 64 39 11 f0       	mov    0xf0113964,%eax
f0100ae5:	c1 e0 03             	shl    $0x3,%eax
f0100ae8:	e8 46 fe ff ff       	call   f0100933 <boot_alloc>
f0100aed:	a3 6c 39 11 f0       	mov    %eax,0xf011396c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f0100af2:	8b 3d 64 39 11 f0    	mov    0xf0113964,%edi
f0100af8:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0100aff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100b03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b0a:	00 
f0100b0b:	89 04 24             	mov    %eax,(%esp)
f0100b0e:	e8 64 0f 00 00       	call   f0101a77 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100b13:	e8 5e fe ff ff       	call   f0100976 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b18:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100b1d:	85 c0                	test   %eax,%eax
f0100b1f:	75 1c                	jne    f0100b3d <mem_init+0x183>
		panic("'page_free_list' is a null pointer!");
f0100b21:	c7 44 24 08 50 24 10 	movl   $0xf0102450,0x8(%esp)
f0100b28:	f0 
f0100b29:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
f0100b30:	00 
f0100b31:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100b38:	e8 57 f5 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b3d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b40:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b43:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b49:	89 c2                	mov    %eax,%edx
f0100b4b:	2b 15 6c 39 11 f0    	sub    0xf011396c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b51:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b57:	0f 95 c2             	setne  %dl
f0100b5a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b5d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b61:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b63:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b67:	8b 00                	mov    (%eax),%eax
f0100b69:	85 c0                	test   %eax,%eax
f0100b6b:	75 dc                	jne    f0100b49 <mem_init+0x18f>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b76:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b79:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b7c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b7e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100b81:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
f0100b87:	eb 64                	jmp    f0100bed <mem_init+0x233>
f0100b89:	89 d8                	mov    %ebx,%eax
f0100b8b:	2b 05 6c 39 11 f0    	sub    0xf011396c,%eax
f0100b91:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b94:	89 c2                	mov    %eax,%edx
f0100b96:	c1 e2 0c             	shl    $0xc,%edx
f0100b99:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0100b9e:	75 4b                	jne    f0100beb <mem_init+0x231>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba0:	89 d0                	mov    %edx,%eax
f0100ba2:	c1 e8 0c             	shr    $0xc,%eax
f0100ba5:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f0100bab:	72 20                	jb     f0100bcd <mem_init+0x213>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bad:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100bb1:	c7 44 24 08 74 24 10 	movl   $0xf0102474,0x8(%esp)
f0100bb8:	f0 
f0100bb9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100bc0:	00 
f0100bc1:	c7 04 24 44 25 10 f0 	movl   $0xf0102544,(%esp)
f0100bc8:	e8 c7 f4 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bcd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100bd4:	00 
f0100bd5:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100bdc:	00 
	return (void *)(pa + KERNBASE);
f0100bdd:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100be3:	89 14 24             	mov    %edx,(%esp)
f0100be6:	e8 8c 0e 00 00       	call   f0101a77 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100beb:	8b 1b                	mov    (%ebx),%ebx
f0100bed:	85 db                	test   %ebx,%ebx
f0100bef:	75 98                	jne    f0100b89 <mem_init+0x1cf>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bf1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bf6:	e8 38 fd ff ff       	call   f0100933 <boot_alloc>
f0100bfb:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bfe:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100c03:	89 45 c0             	mov    %eax,-0x40(%ebp)
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c06:	8b 0d 6c 39 11 f0    	mov    0xf011396c,%ecx
		assert(pp < pages + npages);
f0100c0c:	8b 3d 64 39 11 f0    	mov    0xf0113964,%edi
f0100c12:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c15:	8d 3c f9             	lea    (%ecx,%edi,8),%edi
f0100c18:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c1b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1e:	89 c2                	mov    %eax,%edx
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c20:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c25:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100c28:	e9 97 01 00 00       	jmp    f0100dc4 <mem_init+0x40a>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c2d:	39 d1                	cmp    %edx,%ecx
f0100c2f:	76 24                	jbe    f0100c55 <mem_init+0x29b>
f0100c31:	c7 44 24 0c 52 25 10 	movl   $0xf0102552,0xc(%esp)
f0100c38:	f0 
f0100c39:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100c40:	f0 
f0100c41:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
f0100c48:	00 
f0100c49:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100c50:	e8 3f f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c55:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c58:	72 24                	jb     f0100c7e <mem_init+0x2c4>
f0100c5a:	c7 44 24 0c 73 25 10 	movl   $0xf0102573,0xc(%esp)
f0100c61:	f0 
f0100c62:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100c69:	f0 
f0100c6a:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
f0100c71:	00 
f0100c72:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100c79:	e8 16 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7e:	89 d0                	mov    %edx,%eax
f0100c80:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c83:	a8 07                	test   $0x7,%al
f0100c85:	74 24                	je     f0100cab <mem_init+0x2f1>
f0100c87:	c7 44 24 0c 98 24 10 	movl   $0xf0102498,0xc(%esp)
f0100c8e:	f0 
f0100c8f:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100c96:	f0 
f0100c97:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f0100c9e:	00 
f0100c9f:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100ca6:	e8 e9 f3 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cab:	c1 f8 03             	sar    $0x3,%eax
f0100cae:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cb1:	85 c0                	test   %eax,%eax
f0100cb3:	75 24                	jne    f0100cd9 <mem_init+0x31f>
f0100cb5:	c7 44 24 0c 87 25 10 	movl   $0xf0102587,0xc(%esp)
f0100cbc:	f0 
f0100cbd:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100cc4:	f0 
f0100cc5:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
f0100ccc:	00 
f0100ccd:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100cd4:	e8 bb f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd9:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cde:	75 24                	jne    f0100d04 <mem_init+0x34a>
f0100ce0:	c7 44 24 0c 98 25 10 	movl   $0xf0102598,0xc(%esp)
f0100ce7:	f0 
f0100ce8:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100cef:	f0 
f0100cf0:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
f0100cf7:	00 
f0100cf8:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100cff:	e8 90 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d04:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d09:	75 24                	jne    f0100d2f <mem_init+0x375>
f0100d0b:	c7 44 24 0c cc 24 10 	movl   $0xf01024cc,0xc(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100d1a:	f0 
f0100d1b:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
f0100d22:	00 
f0100d23:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100d2a:	e8 65 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d2f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d34:	75 24                	jne    f0100d5a <mem_init+0x3a0>
f0100d36:	c7 44 24 0c b1 25 10 	movl   $0xf01025b1,0xc(%esp)
f0100d3d:	f0 
f0100d3e:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100d45:	f0 
f0100d46:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f0100d4d:	00 
f0100d4e:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100d55:	e8 3a f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d5a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d5f:	76 58                	jbe    f0100db9 <mem_init+0x3ff>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d61:	89 c3                	mov    %eax,%ebx
f0100d63:	c1 eb 0c             	shr    $0xc,%ebx
f0100d66:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100d69:	77 20                	ja     f0100d8b <mem_init+0x3d1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d6f:	c7 44 24 08 74 24 10 	movl   $0xf0102474,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 44 25 10 f0 	movl   $0xf0102544,(%esp)
f0100d86:	e8 09 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100d8b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d90:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d93:	76 2a                	jbe    f0100dbf <mem_init+0x405>
f0100d95:	c7 44 24 0c f0 24 10 	movl   $0xf01024f0,0xc(%esp)
f0100d9c:	f0 
f0100d9d:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100da4:	f0 
f0100da5:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
f0100dac:	00 
f0100dad:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100db4:	e8 db f2 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100db9:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100dbd:	eb 03                	jmp    f0100dc2 <mem_init+0x408>
		else
			++nfree_extmem;
f0100dbf:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dc2:	8b 12                	mov    (%edx),%edx
f0100dc4:	85 d2                	test   %edx,%edx
f0100dc6:	0f 85 61 fe ff ff    	jne    f0100c2d <mem_init+0x273>
f0100dcc:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dcf:	85 db                	test   %ebx,%ebx
f0100dd1:	7f 24                	jg     f0100df7 <mem_init+0x43d>
f0100dd3:	c7 44 24 0c cb 25 10 	movl   $0xf01025cb,0xc(%esp)
f0100dda:	f0 
f0100ddb:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100de2:	f0 
f0100de3:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
f0100dea:	00 
f0100deb:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100df2:	e8 9d f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100df7:	85 ff                	test   %edi,%edi
f0100df9:	7f 24                	jg     f0100e1f <mem_init+0x465>
f0100dfb:	c7 44 24 0c dd 25 10 	movl   $0xf01025dd,0xc(%esp)
f0100e02:	f0 
f0100e03:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100e1a:	e8 75 f2 ff ff       	call   f0100094 <_panic>
f0100e1f:	8b 45 c0             	mov    -0x40(%ebp),%eax
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100e22:	85 c9                	test   %ecx,%ecx
f0100e24:	75 20                	jne    f0100e46 <mem_init+0x48c>
		panic("'pages' is a null pointer!");
f0100e26:	c7 44 24 08 ee 25 10 	movl   $0xf01025ee,0x8(%esp)
f0100e2d:	f0 
f0100e2e:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
f0100e35:	00 
f0100e36:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100e3d:	e8 52 f2 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100e42:	8b 00                	mov    (%eax),%eax
f0100e44:	eb 00                	jmp    f0100e46 <mem_init+0x48c>
f0100e46:	85 c0                	test   %eax,%eax
f0100e48:	75 f8                	jne    f0100e42 <mem_init+0x488>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100e4a:	c7 44 24 0c 09 26 10 	movl   $0xf0102609,0xc(%esp)
f0100e51:	f0 
f0100e52:	c7 44 24 08 5e 25 10 	movl   $0xf010255e,0x8(%esp)
f0100e59:	f0 
f0100e5a:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
f0100e61:	00 
f0100e62:	c7 04 24 38 25 10 f0 	movl   $0xf0102538,(%esp)
f0100e69:	e8 26 f2 ff ff       	call   f0100094 <_panic>

f0100e6e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e6e:	55                   	push   %ebp
f0100e6f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100e71:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e76:	5d                   	pop    %ebp
f0100e77:	c3                   	ret    

f0100e78 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e78:	55                   	push   %ebp
f0100e79:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100e7b:	5d                   	pop    %ebp
f0100e7c:	c3                   	ret    

f0100e7d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e7d:	55                   	push   %ebp
f0100e7e:	89 e5                	mov    %esp,%ebp
f0100e80:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100e83:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100e88:	5d                   	pop    %ebp
f0100e89:	c3                   	ret    

f0100e8a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e8a:	55                   	push   %ebp
f0100e8b:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100e8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e92:	5d                   	pop    %ebp
f0100e93:	c3                   	ret    

f0100e94 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100e94:	55                   	push   %ebp
f0100e95:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9c:	5d                   	pop    %ebp
f0100e9d:	c3                   	ret    

f0100e9e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100e9e:	55                   	push   %ebp
f0100e9f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100ea1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea6:	5d                   	pop    %ebp
f0100ea7:	c3                   	ret    

f0100ea8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ea8:	55                   	push   %ebp
f0100ea9:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100eab:	5d                   	pop    %ebp
f0100eac:	c3                   	ret    

f0100ead <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100ead:	55                   	push   %ebp
f0100eae:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eb3:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100eb6:	5d                   	pop    %ebp
f0100eb7:	c3                   	ret    

f0100eb8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100eb8:	55                   	push   %ebp
f0100eb9:	89 e5                	mov    %esp,%ebp
f0100ebb:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ebf:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ec4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100ec5:	b2 71                	mov    $0x71,%dl
f0100ec7:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100ec8:	0f b6 c0             	movzbl %al,%eax
}
f0100ecb:	5d                   	pop    %ebp
f0100ecc:	c3                   	ret    

f0100ecd <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100ecd:	55                   	push   %ebp
f0100ece:	89 e5                	mov    %esp,%ebp
f0100ed0:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ed4:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ed9:	ee                   	out    %al,(%dx)
f0100eda:	b2 71                	mov    $0x71,%dl
f0100edc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100edf:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100ee0:	5d                   	pop    %ebp
f0100ee1:	c3                   	ret    

f0100ee2 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ee2:	55                   	push   %ebp
f0100ee3:	89 e5                	mov    %esp,%ebp
f0100ee5:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100ee8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eeb:	89 04 24             	mov    %eax,(%esp)
f0100eee:	e8 fe f6 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0100ef3:	c9                   	leave  
f0100ef4:	c3                   	ret    

f0100ef5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ef5:	55                   	push   %ebp
f0100ef6:	89 e5                	mov    %esp,%ebp
f0100ef8:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100efb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100f02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f05:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f09:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f0c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f17:	c7 04 24 e2 0e 10 f0 	movl   $0xf0100ee2,(%esp)
f0100f1e:	e8 11 04 00 00       	call   f0101334 <vprintfmt>
	return cnt;
}
f0100f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f26:	c9                   	leave  
f0100f27:	c3                   	ret    

f0100f28 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100f28:	55                   	push   %ebp
f0100f29:	89 e5                	mov    %esp,%ebp
f0100f2b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100f2e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100f31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f35:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f38:	89 04 24             	mov    %eax,(%esp)
f0100f3b:	e8 b5 ff ff ff       	call   f0100ef5 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100f40:	c9                   	leave  
f0100f41:	c3                   	ret    

f0100f42 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100f42:	55                   	push   %ebp
f0100f43:	89 e5                	mov    %esp,%ebp
f0100f45:	57                   	push   %edi
f0100f46:	56                   	push   %esi
f0100f47:	53                   	push   %ebx
f0100f48:	83 ec 10             	sub    $0x10,%esp
f0100f4b:	89 c6                	mov    %eax,%esi
f0100f4d:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100f50:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100f56:	8b 1a                	mov    (%edx),%ebx
f0100f58:	8b 01                	mov    (%ecx),%eax
f0100f5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f5d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100f64:	eb 77                	jmp    f0100fdd <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100f69:	01 d8                	add    %ebx,%eax
f0100f6b:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100f70:	99                   	cltd   
f0100f71:	f7 f9                	idiv   %ecx
f0100f73:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100f75:	eb 01                	jmp    f0100f78 <stab_binsearch+0x36>
			m--;
f0100f77:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100f78:	39 d9                	cmp    %ebx,%ecx
f0100f7a:	7c 1d                	jl     f0100f99 <stab_binsearch+0x57>
f0100f7c:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100f7f:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100f84:	39 fa                	cmp    %edi,%edx
f0100f86:	75 ef                	jne    f0100f77 <stab_binsearch+0x35>
f0100f88:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100f8b:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100f8e:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100f92:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100f95:	73 18                	jae    f0100faf <stab_binsearch+0x6d>
f0100f97:	eb 05                	jmp    f0100f9e <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100f99:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100f9c:	eb 3f                	jmp    f0100fdd <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100f9e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100fa1:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100fa3:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100fa6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100fad:	eb 2e                	jmp    f0100fdd <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100faf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100fb2:	73 15                	jae    f0100fc9 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100fb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100fb7:	48                   	dec    %eax
f0100fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100fbb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100fbe:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100fc0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100fc7:	eb 14                	jmp    f0100fdd <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100fc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100fcc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100fcf:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100fd1:	ff 45 0c             	incl   0xc(%ebp)
f0100fd4:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100fd6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100fdd:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100fe0:	7e 84                	jle    f0100f66 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100fe2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100fe6:	75 0d                	jne    f0100ff5 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100fe8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100feb:	8b 00                	mov    (%eax),%eax
f0100fed:	48                   	dec    %eax
f0100fee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ff1:	89 07                	mov    %eax,(%edi)
f0100ff3:	eb 22                	jmp    f0101017 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ff8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ffa:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100ffd:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100fff:	eb 01                	jmp    f0101002 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101001:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101002:	39 c1                	cmp    %eax,%ecx
f0101004:	7d 0c                	jge    f0101012 <stab_binsearch+0xd0>
f0101006:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0101009:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f010100e:	39 fa                	cmp    %edi,%edx
f0101010:	75 ef                	jne    f0101001 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101012:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101015:	89 07                	mov    %eax,(%edi)
	}
}
f0101017:	83 c4 10             	add    $0x10,%esp
f010101a:	5b                   	pop    %ebx
f010101b:	5e                   	pop    %esi
f010101c:	5f                   	pop    %edi
f010101d:	5d                   	pop    %ebp
f010101e:	c3                   	ret    

f010101f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	57                   	push   %edi
f0101023:	56                   	push   %esi
f0101024:	53                   	push   %ebx
f0101025:	83 ec 2c             	sub    $0x2c,%esp
f0101028:	8b 75 08             	mov    0x8(%ebp),%esi
f010102b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010102e:	c7 03 1f 26 10 f0    	movl   $0xf010261f,(%ebx)
	info->eip_line = 0;
f0101034:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010103b:	c7 43 08 1f 26 10 f0 	movl   $0xf010261f,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101042:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101049:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010104c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101053:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101059:	76 12                	jbe    f010106d <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010105b:	b8 cc 89 10 f0       	mov    $0xf01089cc,%eax
f0101060:	3d 95 6d 10 f0       	cmp    $0xf0106d95,%eax
f0101065:	0f 86 6b 01 00 00    	jbe    f01011d6 <debuginfo_eip+0x1b7>
f010106b:	eb 1c                	jmp    f0101089 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010106d:	c7 44 24 08 29 26 10 	movl   $0xf0102629,0x8(%esp)
f0101074:	f0 
f0101075:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f010107c:	00 
f010107d:	c7 04 24 36 26 10 f0 	movl   $0xf0102636,(%esp)
f0101084:	e8 0b f0 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101089:	80 3d cb 89 10 f0 00 	cmpb   $0x0,0xf01089cb
f0101090:	0f 85 47 01 00 00    	jne    f01011dd <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101096:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010109d:	b8 94 6d 10 f0       	mov    $0xf0106d94,%eax
f01010a2:	2d 70 28 10 f0       	sub    $0xf0102870,%eax
f01010a7:	c1 f8 02             	sar    $0x2,%eax
f01010aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01010b0:	83 e8 01             	sub    $0x1,%eax
f01010b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01010b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010ba:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01010c1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01010c4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01010c7:	b8 70 28 10 f0       	mov    $0xf0102870,%eax
f01010cc:	e8 71 fe ff ff       	call   f0100f42 <stab_binsearch>
	if (lfile == 0)
f01010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010d4:	85 c0                	test   %eax,%eax
f01010d6:	0f 84 08 01 00 00    	je     f01011e4 <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01010dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01010df:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01010e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010e9:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01010f0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01010f3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01010f6:	b8 70 28 10 f0       	mov    $0xf0102870,%eax
f01010fb:	e8 42 fe ff ff       	call   f0100f42 <stab_binsearch>

	if (lfun <= rfun) {
f0101100:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101103:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0101106:	7f 2e                	jg     f0101136 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101108:	6b c7 0c             	imul   $0xc,%edi,%eax
f010110b:	8d 90 70 28 10 f0    	lea    -0xfefd790(%eax),%edx
f0101111:	8b 80 70 28 10 f0    	mov    -0xfefd790(%eax),%eax
f0101117:	b9 cc 89 10 f0       	mov    $0xf01089cc,%ecx
f010111c:	81 e9 95 6d 10 f0    	sub    $0xf0106d95,%ecx
f0101122:	39 c8                	cmp    %ecx,%eax
f0101124:	73 08                	jae    f010112e <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101126:	05 95 6d 10 f0       	add    $0xf0106d95,%eax
f010112b:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010112e:	8b 42 08             	mov    0x8(%edx),%eax
f0101131:	89 43 10             	mov    %eax,0x10(%ebx)
f0101134:	eb 06                	jmp    f010113c <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101136:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101139:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010113c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101143:	00 
f0101144:	8b 43 08             	mov    0x8(%ebx),%eax
f0101147:	89 04 24             	mov    %eax,(%esp)
f010114a:	e8 0c 09 00 00       	call   f0101a5b <strfind>
f010114f:	2b 43 08             	sub    0x8(%ebx),%eax
f0101152:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101155:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101158:	6b c7 0c             	imul   $0xc,%edi,%eax
f010115b:	05 70 28 10 f0       	add    $0xf0102870,%eax
f0101160:	eb 06                	jmp    f0101168 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0101162:	83 ef 01             	sub    $0x1,%edi
f0101165:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101168:	39 cf                	cmp    %ecx,%edi
f010116a:	7c 33                	jl     f010119f <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f010116c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0101170:	80 fa 84             	cmp    $0x84,%dl
f0101173:	74 0b                	je     f0101180 <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101175:	80 fa 64             	cmp    $0x64,%dl
f0101178:	75 e8                	jne    f0101162 <debuginfo_eip+0x143>
f010117a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010117e:	74 e2                	je     f0101162 <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101180:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101183:	8b 87 70 28 10 f0    	mov    -0xfefd790(%edi),%eax
f0101189:	ba cc 89 10 f0       	mov    $0xf01089cc,%edx
f010118e:	81 ea 95 6d 10 f0    	sub    $0xf0106d95,%edx
f0101194:	39 d0                	cmp    %edx,%eax
f0101196:	73 07                	jae    f010119f <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101198:	05 95 6d 10 f0       	add    $0xf0106d95,%eax
f010119d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010119f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01011a2:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01011a5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01011aa:	39 f1                	cmp    %esi,%ecx
f01011ac:	7d 42                	jge    f01011f0 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f01011ae:	8d 51 01             	lea    0x1(%ecx),%edx
f01011b1:	6b c1 0c             	imul   $0xc,%ecx,%eax
f01011b4:	05 70 28 10 f0       	add    $0xf0102870,%eax
f01011b9:	eb 07                	jmp    f01011c2 <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01011bb:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01011bf:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01011c2:	39 f2                	cmp    %esi,%edx
f01011c4:	74 25                	je     f01011eb <debuginfo_eip+0x1cc>
f01011c6:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01011c9:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f01011cd:	74 ec                	je     f01011bb <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01011cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d4:	eb 1a                	jmp    f01011f0 <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01011d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011db:	eb 13                	jmp    f01011f0 <debuginfo_eip+0x1d1>
f01011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011e2:	eb 0c                	jmp    f01011f0 <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01011e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011e9:	eb 05                	jmp    f01011f0 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01011eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011f0:	83 c4 2c             	add    $0x2c,%esp
f01011f3:	5b                   	pop    %ebx
f01011f4:	5e                   	pop    %esi
f01011f5:	5f                   	pop    %edi
f01011f6:	5d                   	pop    %ebp
f01011f7:	c3                   	ret    
f01011f8:	66 90                	xchg   %ax,%ax
f01011fa:	66 90                	xchg   %ax,%ax
f01011fc:	66 90                	xchg   %ax,%ax
f01011fe:	66 90                	xchg   %ax,%ax

f0101200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	57                   	push   %edi
f0101204:	56                   	push   %esi
f0101205:	53                   	push   %ebx
f0101206:	83 ec 3c             	sub    $0x3c,%esp
f0101209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010120c:	89 d7                	mov    %edx,%edi
f010120e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101211:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101214:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101217:	89 c3                	mov    %eax,%ebx
f0101219:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010121c:	8b 45 10             	mov    0x10(%ebp),%eax
f010121f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101222:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101227:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010122a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010122d:	39 d9                	cmp    %ebx,%ecx
f010122f:	72 05                	jb     f0101236 <printnum+0x36>
f0101231:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0101234:	77 69                	ja     f010129f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101236:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0101239:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010123d:	83 ee 01             	sub    $0x1,%esi
f0101240:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101244:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101248:	8b 44 24 08          	mov    0x8(%esp),%eax
f010124c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101250:	89 c3                	mov    %eax,%ebx
f0101252:	89 d6                	mov    %edx,%esi
f0101254:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101257:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010125a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010125e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101262:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101265:	89 04 24             	mov    %eax,(%esp)
f0101268:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010126b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010126f:	e8 0c 0a 00 00       	call   f0101c80 <__udivdi3>
f0101274:	89 d9                	mov    %ebx,%ecx
f0101276:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010127a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010127e:	89 04 24             	mov    %eax,(%esp)
f0101281:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101285:	89 fa                	mov    %edi,%edx
f0101287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010128a:	e8 71 ff ff ff       	call   f0101200 <printnum>
f010128f:	eb 1b                	jmp    f01012ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101291:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101295:	8b 45 18             	mov    0x18(%ebp),%eax
f0101298:	89 04 24             	mov    %eax,(%esp)
f010129b:	ff d3                	call   *%ebx
f010129d:	eb 03                	jmp    f01012a2 <printnum+0xa2>
f010129f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01012a2:	83 ee 01             	sub    $0x1,%esi
f01012a5:	85 f6                	test   %esi,%esi
f01012a7:	7f e8                	jg     f0101291 <printnum+0x91>
f01012a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01012ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01012b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012be:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012c5:	89 04 24             	mov    %eax,(%esp)
f01012c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012cf:	e8 dc 0a 00 00       	call   f0101db0 <__umoddi3>
f01012d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012d8:	0f be 80 44 26 10 f0 	movsbl -0xfefd9bc(%eax),%eax
f01012df:	89 04 24             	mov    %eax,(%esp)
f01012e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012e5:	ff d0                	call   *%eax
}
f01012e7:	83 c4 3c             	add    $0x3c,%esp
f01012ea:	5b                   	pop    %ebx
f01012eb:	5e                   	pop    %esi
f01012ec:	5f                   	pop    %edi
f01012ed:	5d                   	pop    %ebp
f01012ee:	c3                   	ret    

f01012ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01012ef:	55                   	push   %ebp
f01012f0:	89 e5                	mov    %esp,%ebp
f01012f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01012f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01012f9:	8b 10                	mov    (%eax),%edx
f01012fb:	3b 50 04             	cmp    0x4(%eax),%edx
f01012fe:	73 0a                	jae    f010130a <sprintputch+0x1b>
		*b->buf++ = ch;
f0101300:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101303:	89 08                	mov    %ecx,(%eax)
f0101305:	8b 45 08             	mov    0x8(%ebp),%eax
f0101308:	88 02                	mov    %al,(%edx)
}
f010130a:	5d                   	pop    %ebp
f010130b:	c3                   	ret    

f010130c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010130c:	55                   	push   %ebp
f010130d:	89 e5                	mov    %esp,%ebp
f010130f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101315:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101319:	8b 45 10             	mov    0x10(%ebp),%eax
f010131c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101320:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101323:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101327:	8b 45 08             	mov    0x8(%ebp),%eax
f010132a:	89 04 24             	mov    %eax,(%esp)
f010132d:	e8 02 00 00 00       	call   f0101334 <vprintfmt>
	va_end(ap);
}
f0101332:	c9                   	leave  
f0101333:	c3                   	ret    

f0101334 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101334:	55                   	push   %ebp
f0101335:	89 e5                	mov    %esp,%ebp
f0101337:	57                   	push   %edi
f0101338:	56                   	push   %esi
f0101339:	53                   	push   %ebx
f010133a:	83 ec 3c             	sub    $0x3c,%esp
f010133d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101343:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101346:	eb 11                	jmp    f0101359 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101348:	85 c0                	test   %eax,%eax
f010134a:	0f 84 48 04 00 00    	je     f0101798 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0101350:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101354:	89 04 24             	mov    %eax,(%esp)
f0101357:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101359:	83 c7 01             	add    $0x1,%edi
f010135c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101360:	83 f8 25             	cmp    $0x25,%eax
f0101363:	75 e3                	jne    f0101348 <vprintfmt+0x14>
f0101365:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101369:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101370:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101377:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010137e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101383:	eb 1f                	jmp    f01013a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101385:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101388:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010138c:	eb 16                	jmp    f01013a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101391:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101395:	eb 0d                	jmp    f01013a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101397:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010139a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010139d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013a4:	8d 47 01             	lea    0x1(%edi),%eax
f01013a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013aa:	0f b6 17             	movzbl (%edi),%edx
f01013ad:	0f b6 c2             	movzbl %dl,%eax
f01013b0:	83 ea 23             	sub    $0x23,%edx
f01013b3:	80 fa 55             	cmp    $0x55,%dl
f01013b6:	0f 87 bf 03 00 00    	ja     f010177b <vprintfmt+0x447>
f01013bc:	0f b6 d2             	movzbl %dl,%edx
f01013bf:	ff 24 95 e0 26 10 f0 	jmp    *-0xfefd920(,%edx,4)
f01013c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01013c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01013ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01013d1:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01013d4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01013d8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f01013db:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01013de:	83 f9 09             	cmp    $0x9,%ecx
f01013e1:	77 3c                	ja     f010141f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01013e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01013e6:	eb e9                	jmp    f01013d1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01013e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013eb:	8b 00                	mov    (%eax),%eax
f01013ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01013f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f3:	8d 40 04             	lea    0x4(%eax),%eax
f01013f6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01013fc:	eb 27                	jmp    f0101425 <vprintfmt+0xf1>
f01013fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101401:	85 d2                	test   %edx,%edx
f0101403:	b8 00 00 00 00       	mov    $0x0,%eax
f0101408:	0f 49 c2             	cmovns %edx,%eax
f010140b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010140e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101411:	eb 91                	jmp    f01013a4 <vprintfmt+0x70>
f0101413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101416:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010141d:	eb 85                	jmp    f01013a4 <vprintfmt+0x70>
f010141f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101422:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101429:	0f 89 75 ff ff ff    	jns    f01013a4 <vprintfmt+0x70>
f010142f:	e9 63 ff ff ff       	jmp    f0101397 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101434:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010143a:	e9 65 ff ff ff       	jmp    f01013a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010143f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101442:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101446:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010144a:	8b 00                	mov    (%eax),%eax
f010144c:	89 04 24             	mov    %eax,(%esp)
f010144f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101454:	e9 00 ff ff ff       	jmp    f0101359 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101459:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010145c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101460:	8b 00                	mov    (%eax),%eax
f0101462:	99                   	cltd   
f0101463:	31 d0                	xor    %edx,%eax
f0101465:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101467:	83 f8 07             	cmp    $0x7,%eax
f010146a:	7f 0b                	jg     f0101477 <vprintfmt+0x143>
f010146c:	8b 14 85 40 28 10 f0 	mov    -0xfefd7c0(,%eax,4),%edx
f0101473:	85 d2                	test   %edx,%edx
f0101475:	75 20                	jne    f0101497 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0101477:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010147b:	c7 44 24 08 5c 26 10 	movl   $0xf010265c,0x8(%esp)
f0101482:	f0 
f0101483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101487:	89 34 24             	mov    %esi,(%esp)
f010148a:	e8 7d fe ff ff       	call   f010130c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010148f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101492:	e9 c2 fe ff ff       	jmp    f0101359 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0101497:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010149b:	c7 44 24 08 70 25 10 	movl   $0xf0102570,0x8(%esp)
f01014a2:	f0 
f01014a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014a7:	89 34 24             	mov    %esi,(%esp)
f01014aa:	e8 5d fe ff ff       	call   f010130c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01014b2:	e9 a2 fe ff ff       	jmp    f0101359 <vprintfmt+0x25>
f01014b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01014ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01014bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01014c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01014c3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01014c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01014c9:	85 ff                	test   %edi,%edi
f01014cb:	b8 55 26 10 f0       	mov    $0xf0102655,%eax
f01014d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01014d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01014d7:	0f 84 92 00 00 00    	je     f010156f <vprintfmt+0x23b>
f01014dd:	85 c9                	test   %ecx,%ecx
f01014df:	0f 8e 98 00 00 00    	jle    f010157d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f01014e5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014e9:	89 3c 24             	mov    %edi,(%esp)
f01014ec:	e8 17 04 00 00       	call   f0101908 <strnlen>
f01014f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01014f4:	29 c1                	sub    %eax,%ecx
f01014f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f01014f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01014fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101500:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101503:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101505:	eb 0f                	jmp    f0101516 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0101507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010150b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010150e:	89 04 24             	mov    %eax,(%esp)
f0101511:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101513:	83 ef 01             	sub    $0x1,%edi
f0101516:	85 ff                	test   %edi,%edi
f0101518:	7f ed                	jg     f0101507 <vprintfmt+0x1d3>
f010151a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010151d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101520:	85 c9                	test   %ecx,%ecx
f0101522:	b8 00 00 00 00       	mov    $0x0,%eax
f0101527:	0f 49 c1             	cmovns %ecx,%eax
f010152a:	29 c1                	sub    %eax,%ecx
f010152c:	89 75 08             	mov    %esi,0x8(%ebp)
f010152f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101532:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101535:	89 cb                	mov    %ecx,%ebx
f0101537:	eb 50                	jmp    f0101589 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010153d:	74 1e                	je     f010155d <vprintfmt+0x229>
f010153f:	0f be d2             	movsbl %dl,%edx
f0101542:	83 ea 20             	sub    $0x20,%edx
f0101545:	83 fa 5e             	cmp    $0x5e,%edx
f0101548:	76 13                	jbe    f010155d <vprintfmt+0x229>
					putch('?', putdat);
f010154a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010154d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101551:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101558:	ff 55 08             	call   *0x8(%ebp)
f010155b:	eb 0d                	jmp    f010156a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f010155d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101560:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101564:	89 04 24             	mov    %eax,(%esp)
f0101567:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010156a:	83 eb 01             	sub    $0x1,%ebx
f010156d:	eb 1a                	jmp    f0101589 <vprintfmt+0x255>
f010156f:	89 75 08             	mov    %esi,0x8(%ebp)
f0101572:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010157b:	eb 0c                	jmp    f0101589 <vprintfmt+0x255>
f010157d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101580:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101589:	83 c7 01             	add    $0x1,%edi
f010158c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101590:	0f be c2             	movsbl %dl,%eax
f0101593:	85 c0                	test   %eax,%eax
f0101595:	74 25                	je     f01015bc <vprintfmt+0x288>
f0101597:	85 f6                	test   %esi,%esi
f0101599:	78 9e                	js     f0101539 <vprintfmt+0x205>
f010159b:	83 ee 01             	sub    $0x1,%esi
f010159e:	79 99                	jns    f0101539 <vprintfmt+0x205>
f01015a0:	89 df                	mov    %ebx,%edi
f01015a2:	8b 75 08             	mov    0x8(%ebp),%esi
f01015a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015a8:	eb 1a                	jmp    f01015c4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01015aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01015b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01015b7:	83 ef 01             	sub    $0x1,%edi
f01015ba:	eb 08                	jmp    f01015c4 <vprintfmt+0x290>
f01015bc:	89 df                	mov    %ebx,%edi
f01015be:	8b 75 08             	mov    0x8(%ebp),%esi
f01015c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015c4:	85 ff                	test   %edi,%edi
f01015c6:	7f e2                	jg     f01015aa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01015c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01015cb:	e9 89 fd ff ff       	jmp    f0101359 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01015d0:	83 f9 01             	cmp    $0x1,%ecx
f01015d3:	7e 19                	jle    f01015ee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f01015d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01015d8:	8b 50 04             	mov    0x4(%eax),%edx
f01015db:	8b 00                	mov    (%eax),%eax
f01015dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01015e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01015e6:	8d 40 08             	lea    0x8(%eax),%eax
f01015e9:	89 45 14             	mov    %eax,0x14(%ebp)
f01015ec:	eb 38                	jmp    f0101626 <vprintfmt+0x2f2>
	else if (lflag)
f01015ee:	85 c9                	test   %ecx,%ecx
f01015f0:	74 1b                	je     f010160d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f01015f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01015f5:	8b 00                	mov    (%eax),%eax
f01015f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015fa:	89 c1                	mov    %eax,%ecx
f01015fc:	c1 f9 1f             	sar    $0x1f,%ecx
f01015ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101602:	8b 45 14             	mov    0x14(%ebp),%eax
f0101605:	8d 40 04             	lea    0x4(%eax),%eax
f0101608:	89 45 14             	mov    %eax,0x14(%ebp)
f010160b:	eb 19                	jmp    f0101626 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010160d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101610:	8b 00                	mov    (%eax),%eax
f0101612:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101615:	89 c1                	mov    %eax,%ecx
f0101617:	c1 f9 1f             	sar    $0x1f,%ecx
f010161a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010161d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101620:	8d 40 04             	lea    0x4(%eax),%eax
f0101623:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101626:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101629:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010162c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101631:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101635:	0f 89 04 01 00 00    	jns    f010173f <vprintfmt+0x40b>
				putch('-', putdat);
f010163b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010163f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101646:	ff d6                	call   *%esi
				num = -(long long) num;
f0101648:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010164b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010164e:	f7 da                	neg    %edx
f0101650:	83 d1 00             	adc    $0x0,%ecx
f0101653:	f7 d9                	neg    %ecx
f0101655:	e9 e5 00 00 00       	jmp    f010173f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010165a:	83 f9 01             	cmp    $0x1,%ecx
f010165d:	7e 10                	jle    f010166f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f010165f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101662:	8b 10                	mov    (%eax),%edx
f0101664:	8b 48 04             	mov    0x4(%eax),%ecx
f0101667:	8d 40 08             	lea    0x8(%eax),%eax
f010166a:	89 45 14             	mov    %eax,0x14(%ebp)
f010166d:	eb 26                	jmp    f0101695 <vprintfmt+0x361>
	else if (lflag)
f010166f:	85 c9                	test   %ecx,%ecx
f0101671:	74 12                	je     f0101685 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0101673:	8b 45 14             	mov    0x14(%ebp),%eax
f0101676:	8b 10                	mov    (%eax),%edx
f0101678:	b9 00 00 00 00       	mov    $0x0,%ecx
f010167d:	8d 40 04             	lea    0x4(%eax),%eax
f0101680:	89 45 14             	mov    %eax,0x14(%ebp)
f0101683:	eb 10                	jmp    f0101695 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0101685:	8b 45 14             	mov    0x14(%ebp),%eax
f0101688:	8b 10                	mov    (%eax),%edx
f010168a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010168f:	8d 40 04             	lea    0x4(%eax),%eax
f0101692:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101695:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010169a:	e9 a0 00 00 00       	jmp    f010173f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010169f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016a3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01016aa:	ff d6                	call   *%esi
			putch('X', putdat);
f01016ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01016b7:	ff d6                	call   *%esi
			putch('X', putdat);
f01016b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016bd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01016c4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01016c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01016c9:	e9 8b fc ff ff       	jmp    f0101359 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f01016ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01016d9:	ff d6                	call   *%esi
			putch('x', putdat);
f01016db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01016e6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01016e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01016eb:	8b 10                	mov    (%eax),%edx
f01016ed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f01016f2:	8d 40 04             	lea    0x4(%eax),%eax
f01016f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01016f8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01016fd:	eb 40                	jmp    f010173f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01016ff:	83 f9 01             	cmp    $0x1,%ecx
f0101702:	7e 10                	jle    f0101714 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0101704:	8b 45 14             	mov    0x14(%ebp),%eax
f0101707:	8b 10                	mov    (%eax),%edx
f0101709:	8b 48 04             	mov    0x4(%eax),%ecx
f010170c:	8d 40 08             	lea    0x8(%eax),%eax
f010170f:	89 45 14             	mov    %eax,0x14(%ebp)
f0101712:	eb 26                	jmp    f010173a <vprintfmt+0x406>
	else if (lflag)
f0101714:	85 c9                	test   %ecx,%ecx
f0101716:	74 12                	je     f010172a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0101718:	8b 45 14             	mov    0x14(%ebp),%eax
f010171b:	8b 10                	mov    (%eax),%edx
f010171d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101722:	8d 40 04             	lea    0x4(%eax),%eax
f0101725:	89 45 14             	mov    %eax,0x14(%ebp)
f0101728:	eb 10                	jmp    f010173a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f010172a:	8b 45 14             	mov    0x14(%ebp),%eax
f010172d:	8b 10                	mov    (%eax),%edx
f010172f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101734:	8d 40 04             	lea    0x4(%eax),%eax
f0101737:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010173a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010173f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101743:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101747:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010174a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010174e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101752:	89 14 24             	mov    %edx,(%esp)
f0101755:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101759:	89 da                	mov    %ebx,%edx
f010175b:	89 f0                	mov    %esi,%eax
f010175d:	e8 9e fa ff ff       	call   f0101200 <printnum>
			break;
f0101762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101765:	e9 ef fb ff ff       	jmp    f0101359 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010176a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010176e:	89 04 24             	mov    %eax,(%esp)
f0101771:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101776:	e9 de fb ff ff       	jmp    f0101359 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010177b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010177f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101786:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101788:	eb 03                	jmp    f010178d <vprintfmt+0x459>
f010178a:	83 ef 01             	sub    $0x1,%edi
f010178d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101791:	75 f7                	jne    f010178a <vprintfmt+0x456>
f0101793:	e9 c1 fb ff ff       	jmp    f0101359 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101798:	83 c4 3c             	add    $0x3c,%esp
f010179b:	5b                   	pop    %ebx
f010179c:	5e                   	pop    %esi
f010179d:	5f                   	pop    %edi
f010179e:	5d                   	pop    %ebp
f010179f:	c3                   	ret    

f01017a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01017a0:	55                   	push   %ebp
f01017a1:	89 e5                	mov    %esp,%ebp
f01017a3:	83 ec 28             	sub    $0x28,%esp
f01017a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01017a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01017ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01017af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01017b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01017b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01017bd:	85 c0                	test   %eax,%eax
f01017bf:	74 30                	je     f01017f1 <vsnprintf+0x51>
f01017c1:	85 d2                	test   %edx,%edx
f01017c3:	7e 2c                	jle    f01017f1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01017c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01017c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017cc:	8b 45 10             	mov    0x10(%ebp),%eax
f01017cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017da:	c7 04 24 ef 12 10 f0 	movl   $0xf01012ef,(%esp)
f01017e1:	e8 4e fb ff ff       	call   f0101334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01017e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017ef:	eb 05                	jmp    f01017f6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01017f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01017f6:	c9                   	leave  
f01017f7:	c3                   	ret    

f01017f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01017f8:	55                   	push   %ebp
f01017f9:	89 e5                	mov    %esp,%ebp
f01017fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01017fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101801:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101805:	8b 45 10             	mov    0x10(%ebp),%eax
f0101808:	89 44 24 08          	mov    %eax,0x8(%esp)
f010180c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010180f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101813:	8b 45 08             	mov    0x8(%ebp),%eax
f0101816:	89 04 24             	mov    %eax,(%esp)
f0101819:	e8 82 ff ff ff       	call   f01017a0 <vsnprintf>
	va_end(ap);

	return rc;
}
f010181e:	c9                   	leave  
f010181f:	c3                   	ret    

f0101820 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101820:	55                   	push   %ebp
f0101821:	89 e5                	mov    %esp,%ebp
f0101823:	57                   	push   %edi
f0101824:	56                   	push   %esi
f0101825:	53                   	push   %ebx
f0101826:	83 ec 1c             	sub    $0x1c,%esp
f0101829:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010182c:	85 c0                	test   %eax,%eax
f010182e:	74 10                	je     f0101840 <readline+0x20>
		cprintf("%s", prompt);
f0101830:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101834:	c7 04 24 70 25 10 f0 	movl   $0xf0102570,(%esp)
f010183b:	e8 e8 f6 ff ff       	call   f0100f28 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101847:	e8 c6 ed ff ff       	call   f0100612 <iscons>
f010184c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010184e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101853:	e8 a9 ed ff ff       	call   f0100601 <getchar>
f0101858:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010185a:	85 c0                	test   %eax,%eax
f010185c:	79 17                	jns    f0101875 <readline+0x55>
			cprintf("read error: %e\n", c);
f010185e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101862:	c7 04 24 60 28 10 f0 	movl   $0xf0102860,(%esp)
f0101869:	e8 ba f6 ff ff       	call   f0100f28 <cprintf>
			return NULL;
f010186e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101873:	eb 6d                	jmp    f01018e2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101875:	83 f8 7f             	cmp    $0x7f,%eax
f0101878:	74 05                	je     f010187f <readline+0x5f>
f010187a:	83 f8 08             	cmp    $0x8,%eax
f010187d:	75 19                	jne    f0101898 <readline+0x78>
f010187f:	85 f6                	test   %esi,%esi
f0101881:	7e 15                	jle    f0101898 <readline+0x78>
			if (echoing)
f0101883:	85 ff                	test   %edi,%edi
f0101885:	74 0c                	je     f0101893 <readline+0x73>
				cputchar('\b');
f0101887:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010188e:	e8 5e ed ff ff       	call   f01005f1 <cputchar>
			i--;
f0101893:	83 ee 01             	sub    $0x1,%esi
f0101896:	eb bb                	jmp    f0101853 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101898:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010189e:	7f 1c                	jg     f01018bc <readline+0x9c>
f01018a0:	83 fb 1f             	cmp    $0x1f,%ebx
f01018a3:	7e 17                	jle    f01018bc <readline+0x9c>
			if (echoing)
f01018a5:	85 ff                	test   %edi,%edi
f01018a7:	74 08                	je     f01018b1 <readline+0x91>
				cputchar(c);
f01018a9:	89 1c 24             	mov    %ebx,(%esp)
f01018ac:	e8 40 ed ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f01018b1:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f01018b7:	8d 76 01             	lea    0x1(%esi),%esi
f01018ba:	eb 97                	jmp    f0101853 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01018bc:	83 fb 0d             	cmp    $0xd,%ebx
f01018bf:	74 05                	je     f01018c6 <readline+0xa6>
f01018c1:	83 fb 0a             	cmp    $0xa,%ebx
f01018c4:	75 8d                	jne    f0101853 <readline+0x33>
			if (echoing)
f01018c6:	85 ff                	test   %edi,%edi
f01018c8:	74 0c                	je     f01018d6 <readline+0xb6>
				cputchar('\n');
f01018ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01018d1:	e8 1b ed ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f01018d6:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
			return buf;
f01018dd:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
		}
	}
}
f01018e2:	83 c4 1c             	add    $0x1c,%esp
f01018e5:	5b                   	pop    %ebx
f01018e6:	5e                   	pop    %esi
f01018e7:	5f                   	pop    %edi
f01018e8:	5d                   	pop    %ebp
f01018e9:	c3                   	ret    
f01018ea:	66 90                	xchg   %ax,%ax
f01018ec:	66 90                	xchg   %ax,%ax
f01018ee:	66 90                	xchg   %ax,%ax

f01018f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01018f0:	55                   	push   %ebp
f01018f1:	89 e5                	mov    %esp,%ebp
f01018f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01018f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01018fb:	eb 03                	jmp    f0101900 <strlen+0x10>
		n++;
f01018fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101900:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101904:	75 f7                	jne    f01018fd <strlen+0xd>
		n++;
	return n;
}
f0101906:	5d                   	pop    %ebp
f0101907:	c3                   	ret    

f0101908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101908:	55                   	push   %ebp
f0101909:	89 e5                	mov    %esp,%ebp
f010190b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010190e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101911:	b8 00 00 00 00       	mov    $0x0,%eax
f0101916:	eb 03                	jmp    f010191b <strnlen+0x13>
		n++;
f0101918:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010191b:	39 d0                	cmp    %edx,%eax
f010191d:	74 06                	je     f0101925 <strnlen+0x1d>
f010191f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101923:	75 f3                	jne    f0101918 <strnlen+0x10>
		n++;
	return n;
}
f0101925:	5d                   	pop    %ebp
f0101926:	c3                   	ret    

f0101927 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101927:	55                   	push   %ebp
f0101928:	89 e5                	mov    %esp,%ebp
f010192a:	53                   	push   %ebx
f010192b:	8b 45 08             	mov    0x8(%ebp),%eax
f010192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101931:	89 c2                	mov    %eax,%edx
f0101933:	83 c2 01             	add    $0x1,%edx
f0101936:	83 c1 01             	add    $0x1,%ecx
f0101939:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010193d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101940:	84 db                	test   %bl,%bl
f0101942:	75 ef                	jne    f0101933 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101944:	5b                   	pop    %ebx
f0101945:	5d                   	pop    %ebp
f0101946:	c3                   	ret    

f0101947 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101947:	55                   	push   %ebp
f0101948:	89 e5                	mov    %esp,%ebp
f010194a:	53                   	push   %ebx
f010194b:	83 ec 08             	sub    $0x8,%esp
f010194e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101951:	89 1c 24             	mov    %ebx,(%esp)
f0101954:	e8 97 ff ff ff       	call   f01018f0 <strlen>
	strcpy(dst + len, src);
f0101959:	8b 55 0c             	mov    0xc(%ebp),%edx
f010195c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101960:	01 d8                	add    %ebx,%eax
f0101962:	89 04 24             	mov    %eax,(%esp)
f0101965:	e8 bd ff ff ff       	call   f0101927 <strcpy>
	return dst;
}
f010196a:	89 d8                	mov    %ebx,%eax
f010196c:	83 c4 08             	add    $0x8,%esp
f010196f:	5b                   	pop    %ebx
f0101970:	5d                   	pop    %ebp
f0101971:	c3                   	ret    

f0101972 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101972:	55                   	push   %ebp
f0101973:	89 e5                	mov    %esp,%ebp
f0101975:	56                   	push   %esi
f0101976:	53                   	push   %ebx
f0101977:	8b 75 08             	mov    0x8(%ebp),%esi
f010197a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010197d:	89 f3                	mov    %esi,%ebx
f010197f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101982:	89 f2                	mov    %esi,%edx
f0101984:	eb 0f                	jmp    f0101995 <strncpy+0x23>
		*dst++ = *src;
f0101986:	83 c2 01             	add    $0x1,%edx
f0101989:	0f b6 01             	movzbl (%ecx),%eax
f010198c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010198f:	80 39 01             	cmpb   $0x1,(%ecx)
f0101992:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101995:	39 da                	cmp    %ebx,%edx
f0101997:	75 ed                	jne    f0101986 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101999:	89 f0                	mov    %esi,%eax
f010199b:	5b                   	pop    %ebx
f010199c:	5e                   	pop    %esi
f010199d:	5d                   	pop    %ebp
f010199e:	c3                   	ret    

f010199f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010199f:	55                   	push   %ebp
f01019a0:	89 e5                	mov    %esp,%ebp
f01019a2:	56                   	push   %esi
f01019a3:	53                   	push   %ebx
f01019a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01019a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01019aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01019ad:	89 f0                	mov    %esi,%eax
f01019af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01019b3:	85 c9                	test   %ecx,%ecx
f01019b5:	75 0b                	jne    f01019c2 <strlcpy+0x23>
f01019b7:	eb 1d                	jmp    f01019d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01019b9:	83 c0 01             	add    $0x1,%eax
f01019bc:	83 c2 01             	add    $0x1,%edx
f01019bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01019c2:	39 d8                	cmp    %ebx,%eax
f01019c4:	74 0b                	je     f01019d1 <strlcpy+0x32>
f01019c6:	0f b6 0a             	movzbl (%edx),%ecx
f01019c9:	84 c9                	test   %cl,%cl
f01019cb:	75 ec                	jne    f01019b9 <strlcpy+0x1a>
f01019cd:	89 c2                	mov    %eax,%edx
f01019cf:	eb 02                	jmp    f01019d3 <strlcpy+0x34>
f01019d1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01019d3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01019d6:	29 f0                	sub    %esi,%eax
}
f01019d8:	5b                   	pop    %ebx
f01019d9:	5e                   	pop    %esi
f01019da:	5d                   	pop    %ebp
f01019db:	c3                   	ret    

f01019dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01019dc:	55                   	push   %ebp
f01019dd:	89 e5                	mov    %esp,%ebp
f01019df:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01019e5:	eb 06                	jmp    f01019ed <strcmp+0x11>
		p++, q++;
f01019e7:	83 c1 01             	add    $0x1,%ecx
f01019ea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01019ed:	0f b6 01             	movzbl (%ecx),%eax
f01019f0:	84 c0                	test   %al,%al
f01019f2:	74 04                	je     f01019f8 <strcmp+0x1c>
f01019f4:	3a 02                	cmp    (%edx),%al
f01019f6:	74 ef                	je     f01019e7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01019f8:	0f b6 c0             	movzbl %al,%eax
f01019fb:	0f b6 12             	movzbl (%edx),%edx
f01019fe:	29 d0                	sub    %edx,%eax
}
f0101a00:	5d                   	pop    %ebp
f0101a01:	c3                   	ret    

f0101a02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101a02:	55                   	push   %ebp
f0101a03:	89 e5                	mov    %esp,%ebp
f0101a05:	53                   	push   %ebx
f0101a06:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a0c:	89 c3                	mov    %eax,%ebx
f0101a0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101a11:	eb 06                	jmp    f0101a19 <strncmp+0x17>
		n--, p++, q++;
f0101a13:	83 c0 01             	add    $0x1,%eax
f0101a16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101a19:	39 d8                	cmp    %ebx,%eax
f0101a1b:	74 15                	je     f0101a32 <strncmp+0x30>
f0101a1d:	0f b6 08             	movzbl (%eax),%ecx
f0101a20:	84 c9                	test   %cl,%cl
f0101a22:	74 04                	je     f0101a28 <strncmp+0x26>
f0101a24:	3a 0a                	cmp    (%edx),%cl
f0101a26:	74 eb                	je     f0101a13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a28:	0f b6 00             	movzbl (%eax),%eax
f0101a2b:	0f b6 12             	movzbl (%edx),%edx
f0101a2e:	29 d0                	sub    %edx,%eax
f0101a30:	eb 05                	jmp    f0101a37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101a32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101a37:	5b                   	pop    %ebx
f0101a38:	5d                   	pop    %ebp
f0101a39:	c3                   	ret    

f0101a3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101a3a:	55                   	push   %ebp
f0101a3b:	89 e5                	mov    %esp,%ebp
f0101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a44:	eb 07                	jmp    f0101a4d <strchr+0x13>
		if (*s == c)
f0101a46:	38 ca                	cmp    %cl,%dl
f0101a48:	74 0f                	je     f0101a59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a4a:	83 c0 01             	add    $0x1,%eax
f0101a4d:	0f b6 10             	movzbl (%eax),%edx
f0101a50:	84 d2                	test   %dl,%dl
f0101a52:	75 f2                	jne    f0101a46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a59:	5d                   	pop    %ebp
f0101a5a:	c3                   	ret    

f0101a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101a5b:	55                   	push   %ebp
f0101a5c:	89 e5                	mov    %esp,%ebp
f0101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a65:	eb 07                	jmp    f0101a6e <strfind+0x13>
		if (*s == c)
f0101a67:	38 ca                	cmp    %cl,%dl
f0101a69:	74 0a                	je     f0101a75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101a6b:	83 c0 01             	add    $0x1,%eax
f0101a6e:	0f b6 10             	movzbl (%eax),%edx
f0101a71:	84 d2                	test   %dl,%dl
f0101a73:	75 f2                	jne    f0101a67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0101a75:	5d                   	pop    %ebp
f0101a76:	c3                   	ret    

f0101a77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101a77:	55                   	push   %ebp
f0101a78:	89 e5                	mov    %esp,%ebp
f0101a7a:	57                   	push   %edi
f0101a7b:	56                   	push   %esi
f0101a7c:	53                   	push   %ebx
f0101a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101a80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101a83:	85 c9                	test   %ecx,%ecx
f0101a85:	74 36                	je     f0101abd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101a87:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101a8d:	75 28                	jne    f0101ab7 <memset+0x40>
f0101a8f:	f6 c1 03             	test   $0x3,%cl
f0101a92:	75 23                	jne    f0101ab7 <memset+0x40>
		c &= 0xFF;
f0101a94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101a98:	89 d3                	mov    %edx,%ebx
f0101a9a:	c1 e3 08             	shl    $0x8,%ebx
f0101a9d:	89 d6                	mov    %edx,%esi
f0101a9f:	c1 e6 18             	shl    $0x18,%esi
f0101aa2:	89 d0                	mov    %edx,%eax
f0101aa4:	c1 e0 10             	shl    $0x10,%eax
f0101aa7:	09 f0                	or     %esi,%eax
f0101aa9:	09 c2                	or     %eax,%edx
f0101aab:	89 d0                	mov    %edx,%eax
f0101aad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101aaf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101ab2:	fc                   	cld    
f0101ab3:	f3 ab                	rep stos %eax,%es:(%edi)
f0101ab5:	eb 06                	jmp    f0101abd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101aba:	fc                   	cld    
f0101abb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101abd:	89 f8                	mov    %edi,%eax
f0101abf:	5b                   	pop    %ebx
f0101ac0:	5e                   	pop    %esi
f0101ac1:	5f                   	pop    %edi
f0101ac2:	5d                   	pop    %ebp
f0101ac3:	c3                   	ret    

f0101ac4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101ac4:	55                   	push   %ebp
f0101ac5:	89 e5                	mov    %esp,%ebp
f0101ac7:	57                   	push   %edi
f0101ac8:	56                   	push   %esi
f0101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
f0101acc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101ad2:	39 c6                	cmp    %eax,%esi
f0101ad4:	73 35                	jae    f0101b0b <memmove+0x47>
f0101ad6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101ad9:	39 d0                	cmp    %edx,%eax
f0101adb:	73 2e                	jae    f0101b0b <memmove+0x47>
		s += n;
		d += n;
f0101add:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101ae0:	89 d6                	mov    %edx,%esi
f0101ae2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101ae4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101aea:	75 13                	jne    f0101aff <memmove+0x3b>
f0101aec:	f6 c1 03             	test   $0x3,%cl
f0101aef:	75 0e                	jne    f0101aff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101af1:	83 ef 04             	sub    $0x4,%edi
f0101af4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101af7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101afa:	fd                   	std    
f0101afb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101afd:	eb 09                	jmp    f0101b08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101aff:	83 ef 01             	sub    $0x1,%edi
f0101b02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101b05:	fd                   	std    
f0101b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101b08:	fc                   	cld    
f0101b09:	eb 1d                	jmp    f0101b28 <memmove+0x64>
f0101b0b:	89 f2                	mov    %esi,%edx
f0101b0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b0f:	f6 c2 03             	test   $0x3,%dl
f0101b12:	75 0f                	jne    f0101b23 <memmove+0x5f>
f0101b14:	f6 c1 03             	test   $0x3,%cl
f0101b17:	75 0a                	jne    f0101b23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101b19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101b1c:	89 c7                	mov    %eax,%edi
f0101b1e:	fc                   	cld    
f0101b1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101b21:	eb 05                	jmp    f0101b28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101b23:	89 c7                	mov    %eax,%edi
f0101b25:	fc                   	cld    
f0101b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101b28:	5e                   	pop    %esi
f0101b29:	5f                   	pop    %edi
f0101b2a:	5d                   	pop    %ebp
f0101b2b:	c3                   	ret    

f0101b2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101b2c:	55                   	push   %ebp
f0101b2d:	89 e5                	mov    %esp,%ebp
f0101b2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101b32:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b35:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b40:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b43:	89 04 24             	mov    %eax,(%esp)
f0101b46:	e8 79 ff ff ff       	call   f0101ac4 <memmove>
}
f0101b4b:	c9                   	leave  
f0101b4c:	c3                   	ret    

f0101b4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101b4d:	55                   	push   %ebp
f0101b4e:	89 e5                	mov    %esp,%ebp
f0101b50:	56                   	push   %esi
f0101b51:	53                   	push   %ebx
f0101b52:	8b 55 08             	mov    0x8(%ebp),%edx
f0101b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b58:	89 d6                	mov    %edx,%esi
f0101b5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b5d:	eb 1a                	jmp    f0101b79 <memcmp+0x2c>
		if (*s1 != *s2)
f0101b5f:	0f b6 02             	movzbl (%edx),%eax
f0101b62:	0f b6 19             	movzbl (%ecx),%ebx
f0101b65:	38 d8                	cmp    %bl,%al
f0101b67:	74 0a                	je     f0101b73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101b69:	0f b6 c0             	movzbl %al,%eax
f0101b6c:	0f b6 db             	movzbl %bl,%ebx
f0101b6f:	29 d8                	sub    %ebx,%eax
f0101b71:	eb 0f                	jmp    f0101b82 <memcmp+0x35>
		s1++, s2++;
f0101b73:	83 c2 01             	add    $0x1,%edx
f0101b76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b79:	39 f2                	cmp    %esi,%edx
f0101b7b:	75 e2                	jne    f0101b5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b82:	5b                   	pop    %ebx
f0101b83:	5e                   	pop    %esi
f0101b84:	5d                   	pop    %ebp
f0101b85:	c3                   	ret    

f0101b86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101b86:	55                   	push   %ebp
f0101b87:	89 e5                	mov    %esp,%ebp
f0101b89:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101b8f:	89 c2                	mov    %eax,%edx
f0101b91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101b94:	eb 07                	jmp    f0101b9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b96:	38 08                	cmp    %cl,(%eax)
f0101b98:	74 07                	je     f0101ba1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101b9a:	83 c0 01             	add    $0x1,%eax
f0101b9d:	39 d0                	cmp    %edx,%eax
f0101b9f:	72 f5                	jb     f0101b96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101ba1:	5d                   	pop    %ebp
f0101ba2:	c3                   	ret    

f0101ba3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101ba3:	55                   	push   %ebp
f0101ba4:	89 e5                	mov    %esp,%ebp
f0101ba6:	57                   	push   %edi
f0101ba7:	56                   	push   %esi
f0101ba8:	53                   	push   %ebx
f0101ba9:	8b 55 08             	mov    0x8(%ebp),%edx
f0101bac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101baf:	eb 03                	jmp    f0101bb4 <strtol+0x11>
		s++;
f0101bb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101bb4:	0f b6 0a             	movzbl (%edx),%ecx
f0101bb7:	80 f9 09             	cmp    $0x9,%cl
f0101bba:	74 f5                	je     f0101bb1 <strtol+0xe>
f0101bbc:	80 f9 20             	cmp    $0x20,%cl
f0101bbf:	74 f0                	je     f0101bb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101bc1:	80 f9 2b             	cmp    $0x2b,%cl
f0101bc4:	75 0a                	jne    f0101bd0 <strtol+0x2d>
		s++;
f0101bc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101bc9:	bf 00 00 00 00       	mov    $0x0,%edi
f0101bce:	eb 11                	jmp    f0101be1 <strtol+0x3e>
f0101bd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101bd5:	80 f9 2d             	cmp    $0x2d,%cl
f0101bd8:	75 07                	jne    f0101be1 <strtol+0x3e>
		s++, neg = 1;
f0101bda:	8d 52 01             	lea    0x1(%edx),%edx
f0101bdd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101be1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101be6:	75 15                	jne    f0101bfd <strtol+0x5a>
f0101be8:	80 3a 30             	cmpb   $0x30,(%edx)
f0101beb:	75 10                	jne    f0101bfd <strtol+0x5a>
f0101bed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101bf1:	75 0a                	jne    f0101bfd <strtol+0x5a>
		s += 2, base = 16;
f0101bf3:	83 c2 02             	add    $0x2,%edx
f0101bf6:	b8 10 00 00 00       	mov    $0x10,%eax
f0101bfb:	eb 10                	jmp    f0101c0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0101bfd:	85 c0                	test   %eax,%eax
f0101bff:	75 0c                	jne    f0101c0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101c01:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101c03:	80 3a 30             	cmpb   $0x30,(%edx)
f0101c06:	75 05                	jne    f0101c0d <strtol+0x6a>
		s++, base = 8;
f0101c08:	83 c2 01             	add    $0x1,%edx
f0101c0b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0101c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101c12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101c15:	0f b6 0a             	movzbl (%edx),%ecx
f0101c18:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0101c1b:	89 f0                	mov    %esi,%eax
f0101c1d:	3c 09                	cmp    $0x9,%al
f0101c1f:	77 08                	ja     f0101c29 <strtol+0x86>
			dig = *s - '0';
f0101c21:	0f be c9             	movsbl %cl,%ecx
f0101c24:	83 e9 30             	sub    $0x30,%ecx
f0101c27:	eb 20                	jmp    f0101c49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0101c29:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0101c2c:	89 f0                	mov    %esi,%eax
f0101c2e:	3c 19                	cmp    $0x19,%al
f0101c30:	77 08                	ja     f0101c3a <strtol+0x97>
			dig = *s - 'a' + 10;
f0101c32:	0f be c9             	movsbl %cl,%ecx
f0101c35:	83 e9 57             	sub    $0x57,%ecx
f0101c38:	eb 0f                	jmp    f0101c49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0101c3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0101c3d:	89 f0                	mov    %esi,%eax
f0101c3f:	3c 19                	cmp    $0x19,%al
f0101c41:	77 16                	ja     f0101c59 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0101c43:	0f be c9             	movsbl %cl,%ecx
f0101c46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101c49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0101c4c:	7d 0f                	jge    f0101c5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0101c4e:	83 c2 01             	add    $0x1,%edx
f0101c51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0101c55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0101c57:	eb bc                	jmp    f0101c15 <strtol+0x72>
f0101c59:	89 d8                	mov    %ebx,%eax
f0101c5b:	eb 02                	jmp    f0101c5f <strtol+0xbc>
f0101c5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0101c5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101c63:	74 05                	je     f0101c6a <strtol+0xc7>
		*endptr = (char *) s;
f0101c65:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0101c6a:	f7 d8                	neg    %eax
f0101c6c:	85 ff                	test   %edi,%edi
f0101c6e:	0f 44 c3             	cmove  %ebx,%eax
}
f0101c71:	5b                   	pop    %ebx
f0101c72:	5e                   	pop    %esi
f0101c73:	5f                   	pop    %edi
f0101c74:	5d                   	pop    %ebp
f0101c75:	c3                   	ret    
f0101c76:	66 90                	xchg   %ax,%ax
f0101c78:	66 90                	xchg   %ax,%ax
f0101c7a:	66 90                	xchg   %ax,%ax
f0101c7c:	66 90                	xchg   %ax,%ax
f0101c7e:	66 90                	xchg   %ax,%ax

f0101c80 <__udivdi3>:
f0101c80:	55                   	push   %ebp
f0101c81:	57                   	push   %edi
f0101c82:	56                   	push   %esi
f0101c83:	83 ec 0c             	sub    $0xc,%esp
f0101c86:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101c8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0101c8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101c92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101c96:	85 c0                	test   %eax,%eax
f0101c98:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c9c:	89 ea                	mov    %ebp,%edx
f0101c9e:	89 0c 24             	mov    %ecx,(%esp)
f0101ca1:	75 2d                	jne    f0101cd0 <__udivdi3+0x50>
f0101ca3:	39 e9                	cmp    %ebp,%ecx
f0101ca5:	77 61                	ja     f0101d08 <__udivdi3+0x88>
f0101ca7:	85 c9                	test   %ecx,%ecx
f0101ca9:	89 ce                	mov    %ecx,%esi
f0101cab:	75 0b                	jne    f0101cb8 <__udivdi3+0x38>
f0101cad:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cb2:	31 d2                	xor    %edx,%edx
f0101cb4:	f7 f1                	div    %ecx
f0101cb6:	89 c6                	mov    %eax,%esi
f0101cb8:	31 d2                	xor    %edx,%edx
f0101cba:	89 e8                	mov    %ebp,%eax
f0101cbc:	f7 f6                	div    %esi
f0101cbe:	89 c5                	mov    %eax,%ebp
f0101cc0:	89 f8                	mov    %edi,%eax
f0101cc2:	f7 f6                	div    %esi
f0101cc4:	89 ea                	mov    %ebp,%edx
f0101cc6:	83 c4 0c             	add    $0xc,%esp
f0101cc9:	5e                   	pop    %esi
f0101cca:	5f                   	pop    %edi
f0101ccb:	5d                   	pop    %ebp
f0101ccc:	c3                   	ret    
f0101ccd:	8d 76 00             	lea    0x0(%esi),%esi
f0101cd0:	39 e8                	cmp    %ebp,%eax
f0101cd2:	77 24                	ja     f0101cf8 <__udivdi3+0x78>
f0101cd4:	0f bd e8             	bsr    %eax,%ebp
f0101cd7:	83 f5 1f             	xor    $0x1f,%ebp
f0101cda:	75 3c                	jne    f0101d18 <__udivdi3+0x98>
f0101cdc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101ce0:	39 34 24             	cmp    %esi,(%esp)
f0101ce3:	0f 86 9f 00 00 00    	jbe    f0101d88 <__udivdi3+0x108>
f0101ce9:	39 d0                	cmp    %edx,%eax
f0101ceb:	0f 82 97 00 00 00    	jb     f0101d88 <__udivdi3+0x108>
f0101cf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101cf8:	31 d2                	xor    %edx,%edx
f0101cfa:	31 c0                	xor    %eax,%eax
f0101cfc:	83 c4 0c             	add    $0xc,%esp
f0101cff:	5e                   	pop    %esi
f0101d00:	5f                   	pop    %edi
f0101d01:	5d                   	pop    %ebp
f0101d02:	c3                   	ret    
f0101d03:	90                   	nop
f0101d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d08:	89 f8                	mov    %edi,%eax
f0101d0a:	f7 f1                	div    %ecx
f0101d0c:	31 d2                	xor    %edx,%edx
f0101d0e:	83 c4 0c             	add    $0xc,%esp
f0101d11:	5e                   	pop    %esi
f0101d12:	5f                   	pop    %edi
f0101d13:	5d                   	pop    %ebp
f0101d14:	c3                   	ret    
f0101d15:	8d 76 00             	lea    0x0(%esi),%esi
f0101d18:	89 e9                	mov    %ebp,%ecx
f0101d1a:	8b 3c 24             	mov    (%esp),%edi
f0101d1d:	d3 e0                	shl    %cl,%eax
f0101d1f:	89 c6                	mov    %eax,%esi
f0101d21:	b8 20 00 00 00       	mov    $0x20,%eax
f0101d26:	29 e8                	sub    %ebp,%eax
f0101d28:	89 c1                	mov    %eax,%ecx
f0101d2a:	d3 ef                	shr    %cl,%edi
f0101d2c:	89 e9                	mov    %ebp,%ecx
f0101d2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101d32:	8b 3c 24             	mov    (%esp),%edi
f0101d35:	09 74 24 08          	or     %esi,0x8(%esp)
f0101d39:	89 d6                	mov    %edx,%esi
f0101d3b:	d3 e7                	shl    %cl,%edi
f0101d3d:	89 c1                	mov    %eax,%ecx
f0101d3f:	89 3c 24             	mov    %edi,(%esp)
f0101d42:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101d46:	d3 ee                	shr    %cl,%esi
f0101d48:	89 e9                	mov    %ebp,%ecx
f0101d4a:	d3 e2                	shl    %cl,%edx
f0101d4c:	89 c1                	mov    %eax,%ecx
f0101d4e:	d3 ef                	shr    %cl,%edi
f0101d50:	09 d7                	or     %edx,%edi
f0101d52:	89 f2                	mov    %esi,%edx
f0101d54:	89 f8                	mov    %edi,%eax
f0101d56:	f7 74 24 08          	divl   0x8(%esp)
f0101d5a:	89 d6                	mov    %edx,%esi
f0101d5c:	89 c7                	mov    %eax,%edi
f0101d5e:	f7 24 24             	mull   (%esp)
f0101d61:	39 d6                	cmp    %edx,%esi
f0101d63:	89 14 24             	mov    %edx,(%esp)
f0101d66:	72 30                	jb     f0101d98 <__udivdi3+0x118>
f0101d68:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101d6c:	89 e9                	mov    %ebp,%ecx
f0101d6e:	d3 e2                	shl    %cl,%edx
f0101d70:	39 c2                	cmp    %eax,%edx
f0101d72:	73 05                	jae    f0101d79 <__udivdi3+0xf9>
f0101d74:	3b 34 24             	cmp    (%esp),%esi
f0101d77:	74 1f                	je     f0101d98 <__udivdi3+0x118>
f0101d79:	89 f8                	mov    %edi,%eax
f0101d7b:	31 d2                	xor    %edx,%edx
f0101d7d:	e9 7a ff ff ff       	jmp    f0101cfc <__udivdi3+0x7c>
f0101d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d88:	31 d2                	xor    %edx,%edx
f0101d8a:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d8f:	e9 68 ff ff ff       	jmp    f0101cfc <__udivdi3+0x7c>
f0101d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d98:	8d 47 ff             	lea    -0x1(%edi),%eax
f0101d9b:	31 d2                	xor    %edx,%edx
f0101d9d:	83 c4 0c             	add    $0xc,%esp
f0101da0:	5e                   	pop    %esi
f0101da1:	5f                   	pop    %edi
f0101da2:	5d                   	pop    %ebp
f0101da3:	c3                   	ret    
f0101da4:	66 90                	xchg   %ax,%ax
f0101da6:	66 90                	xchg   %ax,%ax
f0101da8:	66 90                	xchg   %ax,%ax
f0101daa:	66 90                	xchg   %ax,%ax
f0101dac:	66 90                	xchg   %ax,%ax
f0101dae:	66 90                	xchg   %ax,%ax

f0101db0 <__umoddi3>:
f0101db0:	55                   	push   %ebp
f0101db1:	57                   	push   %edi
f0101db2:	56                   	push   %esi
f0101db3:	83 ec 14             	sub    $0x14,%esp
f0101db6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101dba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101dbe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101dc2:	89 c7                	mov    %eax,%edi
f0101dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101dc8:	8b 44 24 30          	mov    0x30(%esp),%eax
f0101dcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101dd0:	89 34 24             	mov    %esi,(%esp)
f0101dd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101dd7:	85 c0                	test   %eax,%eax
f0101dd9:	89 c2                	mov    %eax,%edx
f0101ddb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101ddf:	75 17                	jne    f0101df8 <__umoddi3+0x48>
f0101de1:	39 fe                	cmp    %edi,%esi
f0101de3:	76 4b                	jbe    f0101e30 <__umoddi3+0x80>
f0101de5:	89 c8                	mov    %ecx,%eax
f0101de7:	89 fa                	mov    %edi,%edx
f0101de9:	f7 f6                	div    %esi
f0101deb:	89 d0                	mov    %edx,%eax
f0101ded:	31 d2                	xor    %edx,%edx
f0101def:	83 c4 14             	add    $0x14,%esp
f0101df2:	5e                   	pop    %esi
f0101df3:	5f                   	pop    %edi
f0101df4:	5d                   	pop    %ebp
f0101df5:	c3                   	ret    
f0101df6:	66 90                	xchg   %ax,%ax
f0101df8:	39 f8                	cmp    %edi,%eax
f0101dfa:	77 54                	ja     f0101e50 <__umoddi3+0xa0>
f0101dfc:	0f bd e8             	bsr    %eax,%ebp
f0101dff:	83 f5 1f             	xor    $0x1f,%ebp
f0101e02:	75 5c                	jne    f0101e60 <__umoddi3+0xb0>
f0101e04:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101e08:	39 3c 24             	cmp    %edi,(%esp)
f0101e0b:	0f 87 e7 00 00 00    	ja     f0101ef8 <__umoddi3+0x148>
f0101e11:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101e15:	29 f1                	sub    %esi,%ecx
f0101e17:	19 c7                	sbb    %eax,%edi
f0101e19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101e1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101e21:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101e25:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101e29:	83 c4 14             	add    $0x14,%esp
f0101e2c:	5e                   	pop    %esi
f0101e2d:	5f                   	pop    %edi
f0101e2e:	5d                   	pop    %ebp
f0101e2f:	c3                   	ret    
f0101e30:	85 f6                	test   %esi,%esi
f0101e32:	89 f5                	mov    %esi,%ebp
f0101e34:	75 0b                	jne    f0101e41 <__umoddi3+0x91>
f0101e36:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e3b:	31 d2                	xor    %edx,%edx
f0101e3d:	f7 f6                	div    %esi
f0101e3f:	89 c5                	mov    %eax,%ebp
f0101e41:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101e45:	31 d2                	xor    %edx,%edx
f0101e47:	f7 f5                	div    %ebp
f0101e49:	89 c8                	mov    %ecx,%eax
f0101e4b:	f7 f5                	div    %ebp
f0101e4d:	eb 9c                	jmp    f0101deb <__umoddi3+0x3b>
f0101e4f:	90                   	nop
f0101e50:	89 c8                	mov    %ecx,%eax
f0101e52:	89 fa                	mov    %edi,%edx
f0101e54:	83 c4 14             	add    $0x14,%esp
f0101e57:	5e                   	pop    %esi
f0101e58:	5f                   	pop    %edi
f0101e59:	5d                   	pop    %ebp
f0101e5a:	c3                   	ret    
f0101e5b:	90                   	nop
f0101e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e60:	8b 04 24             	mov    (%esp),%eax
f0101e63:	be 20 00 00 00       	mov    $0x20,%esi
f0101e68:	89 e9                	mov    %ebp,%ecx
f0101e6a:	29 ee                	sub    %ebp,%esi
f0101e6c:	d3 e2                	shl    %cl,%edx
f0101e6e:	89 f1                	mov    %esi,%ecx
f0101e70:	d3 e8                	shr    %cl,%eax
f0101e72:	89 e9                	mov    %ebp,%ecx
f0101e74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e78:	8b 04 24             	mov    (%esp),%eax
f0101e7b:	09 54 24 04          	or     %edx,0x4(%esp)
f0101e7f:	89 fa                	mov    %edi,%edx
f0101e81:	d3 e0                	shl    %cl,%eax
f0101e83:	89 f1                	mov    %esi,%ecx
f0101e85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e89:	8b 44 24 10          	mov    0x10(%esp),%eax
f0101e8d:	d3 ea                	shr    %cl,%edx
f0101e8f:	89 e9                	mov    %ebp,%ecx
f0101e91:	d3 e7                	shl    %cl,%edi
f0101e93:	89 f1                	mov    %esi,%ecx
f0101e95:	d3 e8                	shr    %cl,%eax
f0101e97:	89 e9                	mov    %ebp,%ecx
f0101e99:	09 f8                	or     %edi,%eax
f0101e9b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101e9f:	f7 74 24 04          	divl   0x4(%esp)
f0101ea3:	d3 e7                	shl    %cl,%edi
f0101ea5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101ea9:	89 d7                	mov    %edx,%edi
f0101eab:	f7 64 24 08          	mull   0x8(%esp)
f0101eaf:	39 d7                	cmp    %edx,%edi
f0101eb1:	89 c1                	mov    %eax,%ecx
f0101eb3:	89 14 24             	mov    %edx,(%esp)
f0101eb6:	72 2c                	jb     f0101ee4 <__umoddi3+0x134>
f0101eb8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0101ebc:	72 22                	jb     f0101ee0 <__umoddi3+0x130>
f0101ebe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101ec2:	29 c8                	sub    %ecx,%eax
f0101ec4:	19 d7                	sbb    %edx,%edi
f0101ec6:	89 e9                	mov    %ebp,%ecx
f0101ec8:	89 fa                	mov    %edi,%edx
f0101eca:	d3 e8                	shr    %cl,%eax
f0101ecc:	89 f1                	mov    %esi,%ecx
f0101ece:	d3 e2                	shl    %cl,%edx
f0101ed0:	89 e9                	mov    %ebp,%ecx
f0101ed2:	d3 ef                	shr    %cl,%edi
f0101ed4:	09 d0                	or     %edx,%eax
f0101ed6:	89 fa                	mov    %edi,%edx
f0101ed8:	83 c4 14             	add    $0x14,%esp
f0101edb:	5e                   	pop    %esi
f0101edc:	5f                   	pop    %edi
f0101edd:	5d                   	pop    %ebp
f0101ede:	c3                   	ret    
f0101edf:	90                   	nop
f0101ee0:	39 d7                	cmp    %edx,%edi
f0101ee2:	75 da                	jne    f0101ebe <__umoddi3+0x10e>
f0101ee4:	8b 14 24             	mov    (%esp),%edx
f0101ee7:	89 c1                	mov    %eax,%ecx
f0101ee9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0101eed:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101ef1:	eb cb                	jmp    f0101ebe <__umoddi3+0x10e>
f0101ef3:	90                   	nop
f0101ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ef8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0101efc:	0f 82 0f ff ff ff    	jb     f0101e11 <__umoddi3+0x61>
f0101f02:	e9 1a ff ff ff       	jmp    f0101e21 <__umoddi3+0x71>
