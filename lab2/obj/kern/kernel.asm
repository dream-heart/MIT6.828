
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
f0100063:	e8 cf 19 00 00       	call   f0101a37 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 1e 10 f0 	movl   $0xf0101ee0,(%esp)
f010007c:	e8 6e 0e 00 00       	call   f0100eef <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 f1 08 00 00       	call   f0100977 <mem_init>

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
f01000c1:	c7 04 24 fb 1e 10 f0 	movl   $0xf0101efb,(%esp)
f01000c8:	e8 22 0e 00 00       	call   f0100eef <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 e3 0d 00 00       	call   f0100ebc <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 37 1f 10 f0 	movl   $0xf0101f37,(%esp)
f01000e0:	e8 0a 0e 00 00       	call   f0100eef <cprintf>
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
f010010b:	c7 04 24 13 1f 10 f0 	movl   $0xf0101f13,(%esp)
f0100112:	e8 d8 0d 00 00       	call   f0100eef <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 96 0d 00 00       	call   f0100ebc <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 37 1f 10 f0 	movl   $0xf0101f37,(%esp)
f010012d:	e8 bd 0d 00 00       	call   f0100eef <cprintf>
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
f01001e5:	0f b6 82 80 20 10 f0 	movzbl -0xfefdf80(%edx),%eax
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
f0100222:	0f b6 82 80 20 10 f0 	movzbl -0xfefdf80(%edx),%eax
f0100229:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 80 1f 10 f0 	movzbl -0xfefe080(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 60 1f 10 f0 	mov    -0xfefe0a0(,%ecx,4),%ecx
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
f0100282:	c7 04 24 2d 1f 10 f0 	movl   $0xf0101f2d,(%esp)
f0100289:	e8 61 0c 00 00       	call   f0100eef <cprintf>
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
f0100429:	e8 56 16 00 00       	call   f0101a84 <memmove>
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
f01005dd:	c7 04 24 39 1f 10 f0 	movl   $0xf0101f39,(%esp)
f01005e4:	e8 06 09 00 00       	call   f0100eef <cprintf>
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
f0100626:	c7 44 24 08 80 21 10 	movl   $0xf0102180,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 9e 21 10 	movl   $0xf010219e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 a3 21 10 f0 	movl   $0xf01021a3,(%esp)
f010063d:	e8 ad 08 00 00       	call   f0100eef <cprintf>
f0100642:	c7 44 24 08 40 22 10 	movl   $0xf0102240,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 ac 21 10 	movl   $0xf01021ac,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 a3 21 10 f0 	movl   $0xf01021a3,(%esp)
f0100659:	e8 91 08 00 00       	call   f0100eef <cprintf>
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
f010066b:	c7 04 24 b5 21 10 f0 	movl   $0xf01021b5,(%esp)
f0100672:	e8 78 08 00 00       	call   f0100eef <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 68 22 10 f0 	movl   $0xf0102268,(%esp)
f0100686:	e8 64 08 00 00       	call   f0100eef <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 90 22 10 f0 	movl   $0xf0102290,(%esp)
f01006a2:	e8 48 08 00 00       	call   f0100eef <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 c7 1e 10 	movl   $0x101ec7,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 c7 1e 10 	movl   $0xf0101ec7,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 b4 22 10 f0 	movl   $0xf01022b4,(%esp)
f01006be:	e8 2c 08 00 00       	call   f0100eef <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 d8 22 10 f0 	movl   $0xf01022d8,(%esp)
f01006da:	e8 10 08 00 00       	call   f0100eef <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 39 11 	movl   $0x113970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 39 11 	movl   $0xf0113970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 fc 22 10 f0 	movl   $0xf01022fc,(%esp)
f01006f6:	e8 f4 07 00 00       	call   f0100eef <cprintf>
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
f010071c:	c7 04 24 20 23 10 f0 	movl   $0xf0102320,(%esp)
f0100723:	e8 c7 07 00 00       	call   f0100eef <cprintf>
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
f010075e:	e8 83 08 00 00       	call   f0100fe6 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 ce 21 10 f0 	movl   $0xf01021ce,(%esp)
f0100775:	e8 75 07 00 00       	call   f0100eef <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 e9 21 10 f0 	movl   $0xf01021e9,(%esp)
f010078a:	e8 60 07 00 00       	call   f0100eef <cprintf>
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
f0100796:	c7 04 24 37 1f 10 f0 	movl   $0xf0101f37,(%esp)
f010079d:	e8 4d 07 00 00       	call   f0100eef <cprintf>
			
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
f01007c8:	c7 04 24 f0 21 10 f0 	movl   $0xf01021f0,(%esp)
f01007cf:	e8 1b 07 00 00       	call   f0100eef <cprintf>
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
f01007fa:	c7 04 24 4c 23 10 f0 	movl   $0xf010234c,(%esp)
f0100801:	e8 e9 06 00 00       	call   f0100eef <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 70 23 10 f0 	movl   $0xf0102370,(%esp)
f010080d:	e8 dd 06 00 00       	call   f0100eef <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 01 22 10 f0 	movl   $0xf0102201,(%esp)
f0100819:	e8 c2 0f 00 00       	call   f01017e0 <readline>
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
f010084a:	c7 04 24 05 22 10 f0 	movl   $0xf0102205,(%esp)
f0100851:	e8 a4 11 00 00       	call   f01019fa <strchr>
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
f010086c:	c7 04 24 0a 22 10 f0 	movl   $0xf010220a,(%esp)
f0100873:	e8 77 06 00 00       	call   f0100eef <cprintf>
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
f0100894:	c7 04 24 05 22 10 f0 	movl   $0xf0102205,(%esp)
f010089b:	e8 5a 11 00 00       	call   f01019fa <strchr>
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
f01008b6:	c7 44 24 04 9e 21 10 	movl   $0xf010219e,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 d3 10 00 00       	call   f010199c <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 ac 21 10 	movl   $0xf01021ac,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 bc 10 00 00       	call   f010199c <strcmp>
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
f0100903:	ff 14 85 a0 23 10 f0 	call   *-0xfefdc60(,%eax,4)


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
f010091a:	c7 04 24 27 22 10 f0 	movl   $0xf0102227,(%esp)
f0100921:	e8 c9 05 00 00       	call   f0100eef <cprintf>
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

f0100933 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100933:	55                   	push   %ebp
f0100934:	89 e5                	mov    %esp,%ebp
f0100936:	53                   	push   %ebx
f0100937:	8b 1d 3c 35 11 f0    	mov    0xf011353c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010093d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100942:	eb 22                	jmp    f0100966 <page_init+0x33>
f0100944:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f010094b:	89 d1                	mov    %edx,%ecx
f010094d:	03 0d 6c 39 11 f0    	add    0xf011396c,%ecx
f0100953:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100959:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010095b:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f010095e:	89 d3                	mov    %edx,%ebx
f0100960:	03 1d 6c 39 11 f0    	add    0xf011396c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100966:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f010096c:	72 d6                	jb     f0100944 <page_init+0x11>
f010096e:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100974:	5b                   	pop    %ebx
f0100975:	5d                   	pop    %ebp
f0100976:	c3                   	ret    

f0100977 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	57                   	push   %edi
f010097b:	56                   	push   %esi
f010097c:	53                   	push   %ebx
f010097d:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100980:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0100987:	e8 f3 04 00 00       	call   f0100e7f <mc146818_read>
f010098c:	89 c3                	mov    %eax,%ebx
f010098e:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100995:	e8 e5 04 00 00       	call   f0100e7f <mc146818_read>
f010099a:	c1 e0 08             	shl    $0x8,%eax
f010099d:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010099f:	89 d8                	mov    %ebx,%eax
f01009a1:	c1 e0 0a             	shl    $0xa,%eax
f01009a4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01009aa:	85 c0                	test   %eax,%eax
f01009ac:	0f 48 c2             	cmovs  %edx,%eax
f01009af:	c1 f8 0c             	sar    $0xc,%eax
f01009b2:	a3 40 35 11 f0       	mov    %eax,0xf0113540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009b7:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01009be:	e8 bc 04 00 00       	call   f0100e7f <mc146818_read>
f01009c3:	89 c3                	mov    %eax,%ebx
f01009c5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01009cc:	e8 ae 04 00 00       	call   f0100e7f <mc146818_read>
f01009d1:	c1 e0 08             	shl    $0x8,%eax
f01009d4:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01009d6:	89 d8                	mov    %ebx,%eax
f01009d8:	c1 e0 0a             	shl    $0xa,%eax
f01009db:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01009e1:	85 c0                	test   %eax,%eax
f01009e3:	0f 48 c2             	cmovs  %edx,%eax
f01009e6:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01009e9:	85 c0                	test   %eax,%eax
f01009eb:	74 0e                	je     f01009fb <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01009ed:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01009f3:	89 15 64 39 11 f0    	mov    %edx,0xf0113964
f01009f9:	eb 0c                	jmp    f0100a07 <mem_init+0x90>
	else
		npages = npages_basemem;
f01009fb:	8b 15 40 35 11 f0    	mov    0xf0113540,%edx
f0100a01:	89 15 64 39 11 f0    	mov    %edx,0xf0113964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100a07:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a0a:	c1 e8 0a             	shr    $0xa,%eax
f0100a0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100a11:	a1 40 35 11 f0       	mov    0xf0113540,%eax
f0100a16:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a19:	c1 e8 0a             	shr    $0xa,%eax
f0100a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100a20:	a1 64 39 11 f0       	mov    0xf0113964,%eax
f0100a25:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a28:	c1 e8 0a             	shr    $0xa,%eax
f0100a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2f:	c7 04 24 b0 23 10 f0 	movl   $0xf01023b0,(%esp)
f0100a36:	e8 b4 04 00 00       	call   f0100eef <cprintf>
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a3b:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f0100a42:	75 0f                	jne    f0100a53 <mem_init+0xdc>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f0100a44:	b8 6f 49 11 f0       	mov    $0xf011496f,%eax
f0100a49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4e:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	//
	// LAB 2: Your code here.
	
	if(n==0)
		return nextfree;
	result = nextfree;
f0100a53:	a1 38 35 11 f0       	mov    0xf0113538,%eax
	nextfree += n;
	//roundup(nextfree,pgsize);--->
	//nextfree+pgsize-1-nextfree%pgsize
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100a58:	8d 90 ff 1f 00 00    	lea    0x1fff(%eax),%edx
f0100a5e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a64:	89 15 38 35 11 f0    	mov    %edx,0xf0113538
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到nextfree，即这条语句生申请了一个页面，kern_padir是新页面的头地址-1
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100a6a:	a3 68 39 11 f0       	mov    %eax,0xf0113968
	memset(kern_pgdir, 0, PGSIZE);
f0100a6f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100a76:	00 
f0100a77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a7e:	00 
f0100a7f:	89 04 24             	mov    %eax,(%esp)
f0100a82:	e8 b0 0f 00 00       	call   f0101a37 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100a87:	a1 68 39 11 f0       	mov    0xf0113968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100a8c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100a91:	77 20                	ja     f0100ab3 <mem_init+0x13c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100a93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a97:	c7 44 24 08 ec 23 10 	movl   $0xf01023ec,0x8(%esp)
f0100a9e:	f0 
f0100a9f:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f0100aa6:	00 
f0100aa7:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100aae:	e8 e1 f5 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ab3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ab9:	83 ca 05             	or     $0x5,%edx
f0100abc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100ac2:	e8 6c fe ff ff       	call   f0100933 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ac7:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100acc:	85 c0                	test   %eax,%eax
f0100ace:	75 1c                	jne    f0100aec <mem_init+0x175>
		panic("'page_free_list' is a null pointer!");
f0100ad0:	c7 44 24 08 10 24 10 	movl   $0xf0102410,0x8(%esp)
f0100ad7:	f0 
f0100ad8:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
f0100adf:	00 
f0100ae0:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100ae7:	e8 a8 f5 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100aec:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100aef:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100af2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100af5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100af8:	89 c2                	mov    %eax,%edx
f0100afa:	2b 15 6c 39 11 f0    	sub    0xf011396c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b00:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b06:	0f 95 c2             	setne  %dl
f0100b09:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b0c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b10:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b12:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b16:	8b 00                	mov    (%eax),%eax
f0100b18:	85 c0                	test   %eax,%eax
f0100b1a:	75 dc                	jne    f0100af8 <mem_init+0x181>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b25:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b28:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b2b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b2d:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100b30:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
f0100b36:	eb 64                	jmp    f0100b9c <mem_init+0x225>
f0100b38:	89 d8                	mov    %ebx,%eax
f0100b3a:	2b 05 6c 39 11 f0    	sub    0xf011396c,%eax
f0100b40:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b43:	89 c2                	mov    %eax,%edx
f0100b45:	c1 e2 0c             	shl    $0xc,%edx
f0100b48:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0100b4d:	75 4b                	jne    f0100b9a <mem_init+0x223>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b4f:	89 d0                	mov    %edx,%eax
f0100b51:	c1 e8 0c             	shr    $0xc,%eax
f0100b54:	3b 05 64 39 11 f0    	cmp    0xf0113964,%eax
f0100b5a:	72 20                	jb     f0100b7c <mem_init+0x205>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b60:	c7 44 24 08 34 24 10 	movl   $0xf0102434,0x8(%esp)
f0100b67:	f0 
f0100b68:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100b6f:	00 
f0100b70:	c7 04 24 04 25 10 f0 	movl   $0xf0102504,(%esp)
f0100b77:	e8 18 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b7c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b83:	00 
f0100b84:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b8b:	00 
	return (void *)(pa + KERNBASE);
f0100b8c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100b92:	89 14 24             	mov    %edx,(%esp)
f0100b95:	e8 9d 0e 00 00       	call   f0101a37 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b9a:	8b 1b                	mov    (%ebx),%ebx
f0100b9c:	85 db                	test   %ebx,%ebx
f0100b9e:	75 98                	jne    f0100b38 <mem_init+0x1c1>
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ba0:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f0100ba7:	75 0f                	jne    f0100bb8 <mem_init+0x241>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f0100ba9:	b8 6f 49 11 f0       	mov    $0xf011496f,%eax
f0100bae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bb3:	a3 38 35 11 f0       	mov    %eax,0xf0113538
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
		return nextfree;
f0100bb8:	a1 38 35 11 f0       	mov    0xf0113538,%eax
f0100bbd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc0:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100bc5:	89 45 c0             	mov    %eax,-0x40(%ebp)
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bc8:	8b 0d 6c 39 11 f0    	mov    0xf011396c,%ecx
		assert(pp < pages + npages);
f0100bce:	8b 3d 64 39 11 f0    	mov    0xf0113964,%edi
f0100bd4:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0100bd7:	8d 3c f9             	lea    (%ecx,%edi,8),%edi
f0100bda:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be0:	89 c2                	mov    %eax,%edx
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100be2:	bf 00 00 00 00       	mov    $0x0,%edi
f0100be7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100bec:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100bef:	e9 97 01 00 00       	jmp    f0100d8b <mem_init+0x414>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bf4:	39 d1                	cmp    %edx,%ecx
f0100bf6:	76 24                	jbe    f0100c1c <mem_init+0x2a5>
f0100bf8:	c7 44 24 0c 12 25 10 	movl   $0xf0102512,0xc(%esp)
f0100bff:	f0 
f0100c00:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100c07:	f0 
f0100c08:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
f0100c0f:	00 
f0100c10:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100c17:	e8 78 f4 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100c1c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c1f:	72 24                	jb     f0100c45 <mem_init+0x2ce>
f0100c21:	c7 44 24 0c 33 25 10 	movl   $0xf0102533,0xc(%esp)
f0100c28:	f0 
f0100c29:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100c30:	f0 
f0100c31:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100c38:	00 
f0100c39:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100c40:	e8 4f f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c45:	89 d0                	mov    %edx,%eax
f0100c47:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c4a:	a8 07                	test   $0x7,%al
f0100c4c:	74 24                	je     f0100c72 <mem_init+0x2fb>
f0100c4e:	c7 44 24 0c 58 24 10 	movl   $0xf0102458,0xc(%esp)
f0100c55:	f0 
f0100c56:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100c5d:	f0 
f0100c5e:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
f0100c65:	00 
f0100c66:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100c6d:	e8 22 f4 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c72:	c1 f8 03             	sar    $0x3,%eax
f0100c75:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c78:	85 c0                	test   %eax,%eax
f0100c7a:	75 24                	jne    f0100ca0 <mem_init+0x329>
f0100c7c:	c7 44 24 0c 47 25 10 	movl   $0xf0102547,0xc(%esp)
f0100c83:	f0 
f0100c84:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100c8b:	f0 
f0100c8c:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
f0100c93:	00 
f0100c94:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100c9b:	e8 f4 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ca0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ca5:	75 24                	jne    f0100ccb <mem_init+0x354>
f0100ca7:	c7 44 24 0c 58 25 10 	movl   $0xf0102558,0xc(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100cb6:	f0 
f0100cb7:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
f0100cbe:	00 
f0100cbf:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100cc6:	e8 c9 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ccb:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cd0:	75 24                	jne    f0100cf6 <mem_init+0x37f>
f0100cd2:	c7 44 24 0c 8c 24 10 	movl   $0xf010248c,0xc(%esp)
f0100cd9:	f0 
f0100cda:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100ce1:	f0 
f0100ce2:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
f0100ce9:	00 
f0100cea:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100cf1:	e8 9e f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cf6:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cfb:	75 24                	jne    f0100d21 <mem_init+0x3aa>
f0100cfd:	c7 44 24 0c 71 25 10 	movl   $0xf0102571,0xc(%esp)
f0100d04:	f0 
f0100d05:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
f0100d14:	00 
f0100d15:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100d1c:	e8 73 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d21:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d26:	76 58                	jbe    f0100d80 <mem_init+0x409>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d28:	89 c3                	mov    %eax,%ebx
f0100d2a:	c1 eb 0c             	shr    $0xc,%ebx
f0100d2d:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100d30:	77 20                	ja     f0100d52 <mem_init+0x3db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d36:	c7 44 24 08 34 24 10 	movl   $0xf0102434,0x8(%esp)
f0100d3d:	f0 
f0100d3e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100d45:	00 
f0100d46:	c7 04 24 04 25 10 f0 	movl   $0xf0102504,(%esp)
f0100d4d:	e8 42 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100d52:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d57:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100d5a:	76 2a                	jbe    f0100d86 <mem_init+0x40f>
f0100d5c:	c7 44 24 0c b0 24 10 	movl   $0xf01024b0,0xc(%esp)
f0100d63:	f0 
f0100d64:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100d6b:	f0 
f0100d6c:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
f0100d73:	00 
f0100d74:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100d7b:	e8 14 f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d80:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100d84:	eb 03                	jmp    f0100d89 <mem_init+0x412>
		else
			++nfree_extmem;
f0100d86:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d89:	8b 12                	mov    (%edx),%edx
f0100d8b:	85 d2                	test   %edx,%edx
f0100d8d:	0f 85 61 fe ff ff    	jne    f0100bf4 <mem_init+0x27d>
f0100d93:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d96:	85 db                	test   %ebx,%ebx
f0100d98:	7f 24                	jg     f0100dbe <mem_init+0x447>
f0100d9a:	c7 44 24 0c 8b 25 10 	movl   $0xf010258b,0xc(%esp)
f0100da1:	f0 
f0100da2:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100da9:	f0 
f0100daa:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
f0100db1:	00 
f0100db2:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100db9:	e8 d6 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100dbe:	85 ff                	test   %edi,%edi
f0100dc0:	7f 24                	jg     f0100de6 <mem_init+0x46f>
f0100dc2:	c7 44 24 0c 9d 25 10 	movl   $0xf010259d,0xc(%esp)
f0100dc9:	f0 
f0100dca:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100dd1:	f0 
f0100dd2:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f0100dd9:	00 
f0100dda:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100de1:	e8 ae f2 ff ff       	call   f0100094 <_panic>
f0100de6:	8b 45 c0             	mov    -0x40(%ebp),%eax
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100de9:	85 c9                	test   %ecx,%ecx
f0100deb:	75 20                	jne    f0100e0d <mem_init+0x496>
		panic("'pages' is a null pointer!");
f0100ded:	c7 44 24 08 ae 25 10 	movl   $0xf01025ae,0x8(%esp)
f0100df4:	f0 
f0100df5:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0100dfc:	00 
f0100dfd:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100e04:	e8 8b f2 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100e09:	8b 00                	mov    (%eax),%eax
f0100e0b:	eb 00                	jmp    f0100e0d <mem_init+0x496>
f0100e0d:	85 c0                	test   %eax,%eax
f0100e0f:	75 f8                	jne    f0100e09 <mem_init+0x492>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100e11:	c7 44 24 0c c9 25 10 	movl   $0xf01025c9,0xc(%esp)
f0100e18:	f0 
f0100e19:	c7 44 24 08 1e 25 10 	movl   $0xf010251e,0x8(%esp)
f0100e20:	f0 
f0100e21:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
f0100e28:	00 
f0100e29:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f0100e30:	e8 5f f2 ff ff       	call   f0100094 <_panic>

f0100e35 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e35:	55                   	push   %ebp
f0100e36:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100e38:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e3d:	5d                   	pop    %ebp
f0100e3e:	c3                   	ret    

f0100e3f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e3f:	55                   	push   %ebp
f0100e40:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100e42:	5d                   	pop    %ebp
f0100e43:	c3                   	ret    

f0100e44 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e44:	55                   	push   %ebp
f0100e45:	89 e5                	mov    %esp,%ebp
f0100e47:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100e4a:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100e4f:	5d                   	pop    %ebp
f0100e50:	c3                   	ret    

f0100e51 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e51:	55                   	push   %ebp
f0100e52:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100e54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e59:	5d                   	pop    %ebp
f0100e5a:	c3                   	ret    

f0100e5b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100e5b:	55                   	push   %ebp
f0100e5c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100e5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e63:	5d                   	pop    %ebp
f0100e64:	c3                   	ret    

f0100e65 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100e65:	55                   	push   %ebp
f0100e66:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100e68:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e6d:	5d                   	pop    %ebp
f0100e6e:	c3                   	ret    

f0100e6f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100e6f:	55                   	push   %ebp
f0100e70:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100e72:	5d                   	pop    %ebp
f0100e73:	c3                   	ret    

f0100e74 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100e74:	55                   	push   %ebp
f0100e75:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e77:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e7a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100e7d:	5d                   	pop    %ebp
f0100e7e:	c3                   	ret    

f0100e7f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100e7f:	55                   	push   %ebp
f0100e80:	89 e5                	mov    %esp,%ebp
f0100e82:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100e86:	ba 70 00 00 00       	mov    $0x70,%edx
f0100e8b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100e8c:	b2 71                	mov    $0x71,%dl
f0100e8e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100e8f:	0f b6 c0             	movzbl %al,%eax
}
f0100e92:	5d                   	pop    %ebp
f0100e93:	c3                   	ret    

f0100e94 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100e94:	55                   	push   %ebp
f0100e95:	89 e5                	mov    %esp,%ebp
f0100e97:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100e9b:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ea0:	ee                   	out    %al,(%dx)
f0100ea1:	b2 71                	mov    $0x71,%dl
f0100ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ea6:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100ea7:	5d                   	pop    %ebp
f0100ea8:	c3                   	ret    

f0100ea9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ea9:	55                   	push   %ebp
f0100eaa:	89 e5                	mov    %esp,%ebp
f0100eac:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100eaf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eb2:	89 04 24             	mov    %eax,(%esp)
f0100eb5:	e8 37 f7 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0100eba:	c9                   	leave  
f0100ebb:	c3                   	ret    

f0100ebc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ebc:	55                   	push   %ebp
f0100ebd:	89 e5                	mov    %esp,%ebp
f0100ebf:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100ec2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ecc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ed0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100eda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ede:	c7 04 24 a9 0e 10 f0 	movl   $0xf0100ea9,(%esp)
f0100ee5:	e8 0a 04 00 00       	call   f01012f4 <vprintfmt>
	return cnt;
}
f0100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100eed:	c9                   	leave  
f0100eee:	c3                   	ret    

f0100eef <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100eef:	55                   	push   %ebp
f0100ef0:	89 e5                	mov    %esp,%ebp
f0100ef2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100ef5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eff:	89 04 24             	mov    %eax,(%esp)
f0100f02:	e8 b5 ff ff ff       	call   f0100ebc <vcprintf>
	va_end(ap);

	return cnt;
}
f0100f07:	c9                   	leave  
f0100f08:	c3                   	ret    

f0100f09 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100f09:	55                   	push   %ebp
f0100f0a:	89 e5                	mov    %esp,%ebp
f0100f0c:	57                   	push   %edi
f0100f0d:	56                   	push   %esi
f0100f0e:	53                   	push   %ebx
f0100f0f:	83 ec 10             	sub    $0x10,%esp
f0100f12:	89 c6                	mov    %eax,%esi
f0100f14:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100f17:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100f1d:	8b 1a                	mov    (%edx),%ebx
f0100f1f:	8b 01                	mov    (%ecx),%eax
f0100f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f24:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100f2b:	eb 77                	jmp    f0100fa4 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100f30:	01 d8                	add    %ebx,%eax
f0100f32:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100f37:	99                   	cltd   
f0100f38:	f7 f9                	idiv   %ecx
f0100f3a:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100f3c:	eb 01                	jmp    f0100f3f <stab_binsearch+0x36>
			m--;
f0100f3e:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100f3f:	39 d9                	cmp    %ebx,%ecx
f0100f41:	7c 1d                	jl     f0100f60 <stab_binsearch+0x57>
f0100f43:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100f46:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100f4b:	39 fa                	cmp    %edi,%edx
f0100f4d:	75 ef                	jne    f0100f3e <stab_binsearch+0x35>
f0100f4f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100f52:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100f55:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100f59:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100f5c:	73 18                	jae    f0100f76 <stab_binsearch+0x6d>
f0100f5e:	eb 05                	jmp    f0100f65 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100f60:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100f63:	eb 3f                	jmp    f0100fa4 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100f65:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100f68:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100f6a:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100f6d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100f74:	eb 2e                	jmp    f0100fa4 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100f76:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100f79:	73 15                	jae    f0100f90 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f7e:	48                   	dec    %eax
f0100f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f82:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100f85:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100f87:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100f8e:	eb 14                	jmp    f0100fa4 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100f90:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100f93:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100f96:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100f98:	ff 45 0c             	incl   0xc(%ebp)
f0100f9b:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100f9d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100fa4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100fa7:	7e 84                	jle    f0100f2d <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100fa9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100fad:	75 0d                	jne    f0100fbc <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100faf:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100fb2:	8b 00                	mov    (%eax),%eax
f0100fb4:	48                   	dec    %eax
f0100fb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fb8:	89 07                	mov    %eax,(%edi)
f0100fba:	eb 22                	jmp    f0100fde <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100fbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fbf:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100fc1:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100fc4:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100fc6:	eb 01                	jmp    f0100fc9 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100fc8:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100fc9:	39 c1                	cmp    %eax,%ecx
f0100fcb:	7d 0c                	jge    f0100fd9 <stab_binsearch+0xd0>
f0100fcd:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100fd0:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100fd5:	39 fa                	cmp    %edi,%edx
f0100fd7:	75 ef                	jne    f0100fc8 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100fd9:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100fdc:	89 07                	mov    %eax,(%edi)
	}
}
f0100fde:	83 c4 10             	add    $0x10,%esp
f0100fe1:	5b                   	pop    %ebx
f0100fe2:	5e                   	pop    %esi
f0100fe3:	5f                   	pop    %edi
f0100fe4:	5d                   	pop    %ebp
f0100fe5:	c3                   	ret    

f0100fe6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100fe6:	55                   	push   %ebp
f0100fe7:	89 e5                	mov    %esp,%ebp
f0100fe9:	57                   	push   %edi
f0100fea:	56                   	push   %esi
f0100feb:	53                   	push   %ebx
f0100fec:	83 ec 2c             	sub    $0x2c,%esp
f0100fef:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ff5:	c7 03 df 25 10 f0    	movl   $0xf01025df,(%ebx)
	info->eip_line = 0;
f0100ffb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101002:	c7 43 08 df 25 10 f0 	movl   $0xf01025df,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101009:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101010:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101013:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010101a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101020:	76 12                	jbe    f0101034 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101022:	b8 2f 89 10 f0       	mov    $0xf010892f,%eax
f0101027:	3d 19 6d 10 f0       	cmp    $0xf0106d19,%eax
f010102c:	0f 86 6b 01 00 00    	jbe    f010119d <debuginfo_eip+0x1b7>
f0101032:	eb 1c                	jmp    f0101050 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101034:	c7 44 24 08 e9 25 10 	movl   $0xf01025e9,0x8(%esp)
f010103b:	f0 
f010103c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0101043:	00 
f0101044:	c7 04 24 f6 25 10 f0 	movl   $0xf01025f6,(%esp)
f010104b:	e8 44 f0 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101050:	80 3d 2e 89 10 f0 00 	cmpb   $0x0,0xf010892e
f0101057:	0f 85 47 01 00 00    	jne    f01011a4 <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010105d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101064:	b8 18 6d 10 f0       	mov    $0xf0106d18,%eax
f0101069:	2d 30 28 10 f0       	sub    $0xf0102830,%eax
f010106e:	c1 f8 02             	sar    $0x2,%eax
f0101071:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101077:	83 e8 01             	sub    $0x1,%eax
f010107a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010107d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101081:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101088:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010108b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010108e:	b8 30 28 10 f0       	mov    $0xf0102830,%eax
f0101093:	e8 71 fe ff ff       	call   f0100f09 <stab_binsearch>
	if (lfile == 0)
f0101098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010109b:	85 c0                	test   %eax,%eax
f010109d:	0f 84 08 01 00 00    	je     f01011ab <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01010a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01010a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01010ac:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010b0:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01010b7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01010ba:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01010bd:	b8 30 28 10 f0       	mov    $0xf0102830,%eax
f01010c2:	e8 42 fe ff ff       	call   f0100f09 <stab_binsearch>

	if (lfun <= rfun) {
f01010c7:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01010ca:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f01010cd:	7f 2e                	jg     f01010fd <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01010cf:	6b c7 0c             	imul   $0xc,%edi,%eax
f01010d2:	8d 90 30 28 10 f0    	lea    -0xfefd7d0(%eax),%edx
f01010d8:	8b 80 30 28 10 f0    	mov    -0xfefd7d0(%eax),%eax
f01010de:	b9 2f 89 10 f0       	mov    $0xf010892f,%ecx
f01010e3:	81 e9 19 6d 10 f0    	sub    $0xf0106d19,%ecx
f01010e9:	39 c8                	cmp    %ecx,%eax
f01010eb:	73 08                	jae    f01010f5 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01010ed:	05 19 6d 10 f0       	add    $0xf0106d19,%eax
f01010f2:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01010f5:	8b 42 08             	mov    0x8(%edx),%eax
f01010f8:	89 43 10             	mov    %eax,0x10(%ebx)
f01010fb:	eb 06                	jmp    f0101103 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01010fd:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101100:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101103:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010110a:	00 
f010110b:	8b 43 08             	mov    0x8(%ebx),%eax
f010110e:	89 04 24             	mov    %eax,(%esp)
f0101111:	e8 05 09 00 00       	call   f0101a1b <strfind>
f0101116:	2b 43 08             	sub    0x8(%ebx),%eax
f0101119:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010111c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010111f:	6b c7 0c             	imul   $0xc,%edi,%eax
f0101122:	05 30 28 10 f0       	add    $0xf0102830,%eax
f0101127:	eb 06                	jmp    f010112f <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0101129:	83 ef 01             	sub    $0x1,%edi
f010112c:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010112f:	39 cf                	cmp    %ecx,%edi
f0101131:	7c 33                	jl     f0101166 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0101133:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0101137:	80 fa 84             	cmp    $0x84,%dl
f010113a:	74 0b                	je     f0101147 <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010113c:	80 fa 64             	cmp    $0x64,%dl
f010113f:	75 e8                	jne    f0101129 <debuginfo_eip+0x143>
f0101141:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0101145:	74 e2                	je     f0101129 <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101147:	6b ff 0c             	imul   $0xc,%edi,%edi
f010114a:	8b 87 30 28 10 f0    	mov    -0xfefd7d0(%edi),%eax
f0101150:	ba 2f 89 10 f0       	mov    $0xf010892f,%edx
f0101155:	81 ea 19 6d 10 f0    	sub    $0xf0106d19,%edx
f010115b:	39 d0                	cmp    %edx,%eax
f010115d:	73 07                	jae    f0101166 <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010115f:	05 19 6d 10 f0       	add    $0xf0106d19,%eax
f0101164:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101166:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101169:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010116c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101171:	39 f1                	cmp    %esi,%ecx
f0101173:	7d 42                	jge    f01011b7 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0101175:	8d 51 01             	lea    0x1(%ecx),%edx
f0101178:	6b c1 0c             	imul   $0xc,%ecx,%eax
f010117b:	05 30 28 10 f0       	add    $0xf0102830,%eax
f0101180:	eb 07                	jmp    f0101189 <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101182:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0101186:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101189:	39 f2                	cmp    %esi,%edx
f010118b:	74 25                	je     f01011b2 <debuginfo_eip+0x1cc>
f010118d:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101190:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0101194:	74 ec                	je     f0101182 <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101196:	b8 00 00 00 00       	mov    $0x0,%eax
f010119b:	eb 1a                	jmp    f01011b7 <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010119d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011a2:	eb 13                	jmp    f01011b7 <debuginfo_eip+0x1d1>
f01011a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011a9:	eb 0c                	jmp    f01011b7 <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01011ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011b0:	eb 05                	jmp    f01011b7 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01011b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011b7:	83 c4 2c             	add    $0x2c,%esp
f01011ba:	5b                   	pop    %ebx
f01011bb:	5e                   	pop    %esi
f01011bc:	5f                   	pop    %edi
f01011bd:	5d                   	pop    %ebp
f01011be:	c3                   	ret    
f01011bf:	90                   	nop

f01011c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01011c0:	55                   	push   %ebp
f01011c1:	89 e5                	mov    %esp,%ebp
f01011c3:	57                   	push   %edi
f01011c4:	56                   	push   %esi
f01011c5:	53                   	push   %ebx
f01011c6:	83 ec 3c             	sub    $0x3c,%esp
f01011c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011cc:	89 d7                	mov    %edx,%edi
f01011ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d7:	89 c3                	mov    %eax,%ebx
f01011d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011dc:	8b 45 10             	mov    0x10(%ebp),%eax
f01011df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01011e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01011ed:	39 d9                	cmp    %ebx,%ecx
f01011ef:	72 05                	jb     f01011f6 <printnum+0x36>
f01011f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01011f4:	77 69                	ja     f010125f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01011f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01011f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01011fd:	83 ee 01             	sub    $0x1,%esi
f0101200:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101204:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101208:	8b 44 24 08          	mov    0x8(%esp),%eax
f010120c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101210:	89 c3                	mov    %eax,%ebx
f0101212:	89 d6                	mov    %edx,%esi
f0101214:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101217:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010121a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010121e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101222:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101225:	89 04 24             	mov    %eax,(%esp)
f0101228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010122b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010122f:	e8 0c 0a 00 00       	call   f0101c40 <__udivdi3>
f0101234:	89 d9                	mov    %ebx,%ecx
f0101236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010123a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010123e:	89 04 24             	mov    %eax,(%esp)
f0101241:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101245:	89 fa                	mov    %edi,%edx
f0101247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010124a:	e8 71 ff ff ff       	call   f01011c0 <printnum>
f010124f:	eb 1b                	jmp    f010126c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101251:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101255:	8b 45 18             	mov    0x18(%ebp),%eax
f0101258:	89 04 24             	mov    %eax,(%esp)
f010125b:	ff d3                	call   *%ebx
f010125d:	eb 03                	jmp    f0101262 <printnum+0xa2>
f010125f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101262:	83 ee 01             	sub    $0x1,%esi
f0101265:	85 f6                	test   %esi,%esi
f0101267:	7f e8                	jg     f0101251 <printnum+0x91>
f0101269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010126c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101270:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101274:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101277:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010127a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010127e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101282:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101285:	89 04 24             	mov    %eax,(%esp)
f0101288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010128b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010128f:	e8 dc 0a 00 00       	call   f0101d70 <__umoddi3>
f0101294:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101298:	0f be 80 04 26 10 f0 	movsbl -0xfefd9fc(%eax),%eax
f010129f:	89 04 24             	mov    %eax,(%esp)
f01012a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012a5:	ff d0                	call   *%eax
}
f01012a7:	83 c4 3c             	add    $0x3c,%esp
f01012aa:	5b                   	pop    %ebx
f01012ab:	5e                   	pop    %esi
f01012ac:	5f                   	pop    %edi
f01012ad:	5d                   	pop    %ebp
f01012ae:	c3                   	ret    

f01012af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01012af:	55                   	push   %ebp
f01012b0:	89 e5                	mov    %esp,%ebp
f01012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01012b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01012b9:	8b 10                	mov    (%eax),%edx
f01012bb:	3b 50 04             	cmp    0x4(%eax),%edx
f01012be:	73 0a                	jae    f01012ca <sprintputch+0x1b>
		*b->buf++ = ch;
f01012c0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01012c3:	89 08                	mov    %ecx,(%eax)
f01012c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c8:	88 02                	mov    %al,(%edx)
}
f01012ca:	5d                   	pop    %ebp
f01012cb:	c3                   	ret    

f01012cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01012cc:	55                   	push   %ebp
f01012cd:	89 e5                	mov    %esp,%ebp
f01012cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01012d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01012d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01012dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ea:	89 04 24             	mov    %eax,(%esp)
f01012ed:	e8 02 00 00 00       	call   f01012f4 <vprintfmt>
	va_end(ap);
}
f01012f2:	c9                   	leave  
f01012f3:	c3                   	ret    

f01012f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01012f4:	55                   	push   %ebp
f01012f5:	89 e5                	mov    %esp,%ebp
f01012f7:	57                   	push   %edi
f01012f8:	56                   	push   %esi
f01012f9:	53                   	push   %ebx
f01012fa:	83 ec 3c             	sub    $0x3c,%esp
f01012fd:	8b 75 08             	mov    0x8(%ebp),%esi
f0101300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101303:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101306:	eb 11                	jmp    f0101319 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101308:	85 c0                	test   %eax,%eax
f010130a:	0f 84 48 04 00 00    	je     f0101758 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0101310:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101314:	89 04 24             	mov    %eax,(%esp)
f0101317:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101319:	83 c7 01             	add    $0x1,%edi
f010131c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101320:	83 f8 25             	cmp    $0x25,%eax
f0101323:	75 e3                	jne    f0101308 <vprintfmt+0x14>
f0101325:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101329:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101330:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101337:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010133e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101343:	eb 1f                	jmp    f0101364 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101345:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101348:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010134c:	eb 16                	jmp    f0101364 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101351:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101355:	eb 0d                	jmp    f0101364 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101357:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010135a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010135d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101364:	8d 47 01             	lea    0x1(%edi),%eax
f0101367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010136a:	0f b6 17             	movzbl (%edi),%edx
f010136d:	0f b6 c2             	movzbl %dl,%eax
f0101370:	83 ea 23             	sub    $0x23,%edx
f0101373:	80 fa 55             	cmp    $0x55,%dl
f0101376:	0f 87 bf 03 00 00    	ja     f010173b <vprintfmt+0x447>
f010137c:	0f b6 d2             	movzbl %dl,%edx
f010137f:	ff 24 95 a0 26 10 f0 	jmp    *-0xfefd960(,%edx,4)
f0101386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101389:	ba 00 00 00 00       	mov    $0x0,%edx
f010138e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101391:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101394:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101398:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010139b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010139e:	83 f9 09             	cmp    $0x9,%ecx
f01013a1:	77 3c                	ja     f01013df <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01013a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01013a6:	eb e9                	jmp    f0101391 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01013a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ab:	8b 00                	mov    (%eax),%eax
f01013ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01013b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b3:	8d 40 04             	lea    0x4(%eax),%eax
f01013b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01013bc:	eb 27                	jmp    f01013e5 <vprintfmt+0xf1>
f01013be:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01013c1:	85 d2                	test   %edx,%edx
f01013c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01013c8:	0f 49 c2             	cmovns %edx,%eax
f01013cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01013d1:	eb 91                	jmp    f0101364 <vprintfmt+0x70>
f01013d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01013d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01013dd:	eb 85                	jmp    f0101364 <vprintfmt+0x70>
f01013df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01013e2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01013e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01013e9:	0f 89 75 ff ff ff    	jns    f0101364 <vprintfmt+0x70>
f01013ef:	e9 63 ff ff ff       	jmp    f0101357 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01013f4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01013fa:	e9 65 ff ff ff       	jmp    f0101364 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013ff:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101402:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010140a:	8b 00                	mov    (%eax),%eax
f010140c:	89 04 24             	mov    %eax,(%esp)
f010140f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101414:	e9 00 ff ff ff       	jmp    f0101319 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101419:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010141c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101420:	8b 00                	mov    (%eax),%eax
f0101422:	99                   	cltd   
f0101423:	31 d0                	xor    %edx,%eax
f0101425:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101427:	83 f8 07             	cmp    $0x7,%eax
f010142a:	7f 0b                	jg     f0101437 <vprintfmt+0x143>
f010142c:	8b 14 85 00 28 10 f0 	mov    -0xfefd800(,%eax,4),%edx
f0101433:	85 d2                	test   %edx,%edx
f0101435:	75 20                	jne    f0101457 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0101437:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010143b:	c7 44 24 08 1c 26 10 	movl   $0xf010261c,0x8(%esp)
f0101442:	f0 
f0101443:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101447:	89 34 24             	mov    %esi,(%esp)
f010144a:	e8 7d fe ff ff       	call   f01012cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010144f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101452:	e9 c2 fe ff ff       	jmp    f0101319 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0101457:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010145b:	c7 44 24 08 30 25 10 	movl   $0xf0102530,0x8(%esp)
f0101462:	f0 
f0101463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101467:	89 34 24             	mov    %esi,(%esp)
f010146a:	e8 5d fe ff ff       	call   f01012cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010146f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101472:	e9 a2 fe ff ff       	jmp    f0101319 <vprintfmt+0x25>
f0101477:	8b 45 14             	mov    0x14(%ebp),%eax
f010147a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010147d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101480:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101483:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101489:	85 ff                	test   %edi,%edi
f010148b:	b8 15 26 10 f0       	mov    $0xf0102615,%eax
f0101490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101493:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101497:	0f 84 92 00 00 00    	je     f010152f <vprintfmt+0x23b>
f010149d:	85 c9                	test   %ecx,%ecx
f010149f:	0f 8e 98 00 00 00    	jle    f010153d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f01014a5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014a9:	89 3c 24             	mov    %edi,(%esp)
f01014ac:	e8 17 04 00 00       	call   f01018c8 <strnlen>
f01014b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01014b4:	29 c1                	sub    %eax,%ecx
f01014b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f01014b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01014bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01014c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01014c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01014c5:	eb 0f                	jmp    f01014d6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f01014c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014ce:	89 04 24             	mov    %eax,(%esp)
f01014d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01014d3:	83 ef 01             	sub    $0x1,%edi
f01014d6:	85 ff                	test   %edi,%edi
f01014d8:	7f ed                	jg     f01014c7 <vprintfmt+0x1d3>
f01014da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01014e0:	85 c9                	test   %ecx,%ecx
f01014e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01014e7:	0f 49 c1             	cmovns %ecx,%eax
f01014ea:	29 c1                	sub    %eax,%ecx
f01014ec:	89 75 08             	mov    %esi,0x8(%ebp)
f01014ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01014f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01014f5:	89 cb                	mov    %ecx,%ebx
f01014f7:	eb 50                	jmp    f0101549 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01014f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01014fd:	74 1e                	je     f010151d <vprintfmt+0x229>
f01014ff:	0f be d2             	movsbl %dl,%edx
f0101502:	83 ea 20             	sub    $0x20,%edx
f0101505:	83 fa 5e             	cmp    $0x5e,%edx
f0101508:	76 13                	jbe    f010151d <vprintfmt+0x229>
					putch('?', putdat);
f010150a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010150d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101511:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101518:	ff 55 08             	call   *0x8(%ebp)
f010151b:	eb 0d                	jmp    f010152a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f010151d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101520:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101524:	89 04 24             	mov    %eax,(%esp)
f0101527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010152a:	83 eb 01             	sub    $0x1,%ebx
f010152d:	eb 1a                	jmp    f0101549 <vprintfmt+0x255>
f010152f:	89 75 08             	mov    %esi,0x8(%ebp)
f0101532:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101538:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010153b:	eb 0c                	jmp    f0101549 <vprintfmt+0x255>
f010153d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101540:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101546:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101549:	83 c7 01             	add    $0x1,%edi
f010154c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101550:	0f be c2             	movsbl %dl,%eax
f0101553:	85 c0                	test   %eax,%eax
f0101555:	74 25                	je     f010157c <vprintfmt+0x288>
f0101557:	85 f6                	test   %esi,%esi
f0101559:	78 9e                	js     f01014f9 <vprintfmt+0x205>
f010155b:	83 ee 01             	sub    $0x1,%esi
f010155e:	79 99                	jns    f01014f9 <vprintfmt+0x205>
f0101560:	89 df                	mov    %ebx,%edi
f0101562:	8b 75 08             	mov    0x8(%ebp),%esi
f0101565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101568:	eb 1a                	jmp    f0101584 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010156a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010156e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101575:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101577:	83 ef 01             	sub    $0x1,%edi
f010157a:	eb 08                	jmp    f0101584 <vprintfmt+0x290>
f010157c:	89 df                	mov    %ebx,%edi
f010157e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101584:	85 ff                	test   %edi,%edi
f0101586:	7f e2                	jg     f010156a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010158b:	e9 89 fd ff ff       	jmp    f0101319 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101590:	83 f9 01             	cmp    $0x1,%ecx
f0101593:	7e 19                	jle    f01015ae <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0101595:	8b 45 14             	mov    0x14(%ebp),%eax
f0101598:	8b 50 04             	mov    0x4(%eax),%edx
f010159b:	8b 00                	mov    (%eax),%eax
f010159d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01015a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01015a6:	8d 40 08             	lea    0x8(%eax),%eax
f01015a9:	89 45 14             	mov    %eax,0x14(%ebp)
f01015ac:	eb 38                	jmp    f01015e6 <vprintfmt+0x2f2>
	else if (lflag)
f01015ae:	85 c9                	test   %ecx,%ecx
f01015b0:	74 1b                	je     f01015cd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f01015b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01015b5:	8b 00                	mov    (%eax),%eax
f01015b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015ba:	89 c1                	mov    %eax,%ecx
f01015bc:	c1 f9 1f             	sar    $0x1f,%ecx
f01015bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01015c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01015c5:	8d 40 04             	lea    0x4(%eax),%eax
f01015c8:	89 45 14             	mov    %eax,0x14(%ebp)
f01015cb:	eb 19                	jmp    f01015e6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f01015cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01015d0:	8b 00                	mov    (%eax),%eax
f01015d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015d5:	89 c1                	mov    %eax,%ecx
f01015d7:	c1 f9 1f             	sar    $0x1f,%ecx
f01015da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01015dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01015e0:	8d 40 04             	lea    0x4(%eax),%eax
f01015e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01015e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01015e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01015ec:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01015f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01015f5:	0f 89 04 01 00 00    	jns    f01016ff <vprintfmt+0x40b>
				putch('-', putdat);
f01015fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101606:	ff d6                	call   *%esi
				num = -(long long) num;
f0101608:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010160b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010160e:	f7 da                	neg    %edx
f0101610:	83 d1 00             	adc    $0x0,%ecx
f0101613:	f7 d9                	neg    %ecx
f0101615:	e9 e5 00 00 00       	jmp    f01016ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010161a:	83 f9 01             	cmp    $0x1,%ecx
f010161d:	7e 10                	jle    f010162f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f010161f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101622:	8b 10                	mov    (%eax),%edx
f0101624:	8b 48 04             	mov    0x4(%eax),%ecx
f0101627:	8d 40 08             	lea    0x8(%eax),%eax
f010162a:	89 45 14             	mov    %eax,0x14(%ebp)
f010162d:	eb 26                	jmp    f0101655 <vprintfmt+0x361>
	else if (lflag)
f010162f:	85 c9                	test   %ecx,%ecx
f0101631:	74 12                	je     f0101645 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0101633:	8b 45 14             	mov    0x14(%ebp),%eax
f0101636:	8b 10                	mov    (%eax),%edx
f0101638:	b9 00 00 00 00       	mov    $0x0,%ecx
f010163d:	8d 40 04             	lea    0x4(%eax),%eax
f0101640:	89 45 14             	mov    %eax,0x14(%ebp)
f0101643:	eb 10                	jmp    f0101655 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0101645:	8b 45 14             	mov    0x14(%ebp),%eax
f0101648:	8b 10                	mov    (%eax),%edx
f010164a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010164f:	8d 40 04             	lea    0x4(%eax),%eax
f0101652:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101655:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010165a:	e9 a0 00 00 00       	jmp    f01016ff <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010165f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101663:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010166a:	ff d6                	call   *%esi
			putch('X', putdat);
f010166c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101670:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101677:	ff d6                	call   *%esi
			putch('X', putdat);
f0101679:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010167d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101684:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101689:	e9 8b fc ff ff       	jmp    f0101319 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010168e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101692:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101699:	ff d6                	call   *%esi
			putch('x', putdat);
f010169b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010169f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01016a6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01016a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01016ab:	8b 10                	mov    (%eax),%edx
f01016ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f01016b2:	8d 40 04             	lea    0x4(%eax),%eax
f01016b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01016b8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01016bd:	eb 40                	jmp    f01016ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01016bf:	83 f9 01             	cmp    $0x1,%ecx
f01016c2:	7e 10                	jle    f01016d4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f01016c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01016c7:	8b 10                	mov    (%eax),%edx
f01016c9:	8b 48 04             	mov    0x4(%eax),%ecx
f01016cc:	8d 40 08             	lea    0x8(%eax),%eax
f01016cf:	89 45 14             	mov    %eax,0x14(%ebp)
f01016d2:	eb 26                	jmp    f01016fa <vprintfmt+0x406>
	else if (lflag)
f01016d4:	85 c9                	test   %ecx,%ecx
f01016d6:	74 12                	je     f01016ea <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01016d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01016db:	8b 10                	mov    (%eax),%edx
f01016dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01016e2:	8d 40 04             	lea    0x4(%eax),%eax
f01016e5:	89 45 14             	mov    %eax,0x14(%ebp)
f01016e8:	eb 10                	jmp    f01016fa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01016ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01016ed:	8b 10                	mov    (%eax),%edx
f01016ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01016f4:	8d 40 04             	lea    0x4(%eax),%eax
f01016f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01016fa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01016ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101703:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101707:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010170a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010170e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101712:	89 14 24             	mov    %edx,(%esp)
f0101715:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101719:	89 da                	mov    %ebx,%edx
f010171b:	89 f0                	mov    %esi,%eax
f010171d:	e8 9e fa ff ff       	call   f01011c0 <printnum>
			break;
f0101722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101725:	e9 ef fb ff ff       	jmp    f0101319 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010172a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010172e:	89 04 24             	mov    %eax,(%esp)
f0101731:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101736:	e9 de fb ff ff       	jmp    f0101319 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010173b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010173f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101746:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101748:	eb 03                	jmp    f010174d <vprintfmt+0x459>
f010174a:	83 ef 01             	sub    $0x1,%edi
f010174d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101751:	75 f7                	jne    f010174a <vprintfmt+0x456>
f0101753:	e9 c1 fb ff ff       	jmp    f0101319 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101758:	83 c4 3c             	add    $0x3c,%esp
f010175b:	5b                   	pop    %ebx
f010175c:	5e                   	pop    %esi
f010175d:	5f                   	pop    %edi
f010175e:	5d                   	pop    %ebp
f010175f:	c3                   	ret    

f0101760 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	83 ec 28             	sub    $0x28,%esp
f0101766:	8b 45 08             	mov    0x8(%ebp),%eax
f0101769:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010176c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010176f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101773:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101776:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010177d:	85 c0                	test   %eax,%eax
f010177f:	74 30                	je     f01017b1 <vsnprintf+0x51>
f0101781:	85 d2                	test   %edx,%edx
f0101783:	7e 2c                	jle    f01017b1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101785:	8b 45 14             	mov    0x14(%ebp),%eax
f0101788:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010178c:	8b 45 10             	mov    0x10(%ebp),%eax
f010178f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101793:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101796:	89 44 24 04          	mov    %eax,0x4(%esp)
f010179a:	c7 04 24 af 12 10 f0 	movl   $0xf01012af,(%esp)
f01017a1:	e8 4e fb ff ff       	call   f01012f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01017a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01017ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017af:	eb 05                	jmp    f01017b6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01017b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01017b6:	c9                   	leave  
f01017b7:	c3                   	ret    

f01017b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01017b8:	55                   	push   %ebp
f01017b9:	89 e5                	mov    %esp,%ebp
f01017bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01017be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01017c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017c5:	8b 45 10             	mov    0x10(%ebp),%eax
f01017c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d6:	89 04 24             	mov    %eax,(%esp)
f01017d9:	e8 82 ff ff ff       	call   f0101760 <vsnprintf>
	va_end(ap);

	return rc;
}
f01017de:	c9                   	leave  
f01017df:	c3                   	ret    

f01017e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01017e0:	55                   	push   %ebp
f01017e1:	89 e5                	mov    %esp,%ebp
f01017e3:	57                   	push   %edi
f01017e4:	56                   	push   %esi
f01017e5:	53                   	push   %ebx
f01017e6:	83 ec 1c             	sub    $0x1c,%esp
f01017e9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01017ec:	85 c0                	test   %eax,%eax
f01017ee:	74 10                	je     f0101800 <readline+0x20>
		cprintf("%s", prompt);
f01017f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f4:	c7 04 24 30 25 10 f0 	movl   $0xf0102530,(%esp)
f01017fb:	e8 ef f6 ff ff       	call   f0100eef <cprintf>

	i = 0;
	echoing = iscons(0);
f0101800:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101807:	e8 06 ee ff ff       	call   f0100612 <iscons>
f010180c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010180e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101813:	e8 e9 ed ff ff       	call   f0100601 <getchar>
f0101818:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010181a:	85 c0                	test   %eax,%eax
f010181c:	79 17                	jns    f0101835 <readline+0x55>
			cprintf("read error: %e\n", c);
f010181e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101822:	c7 04 24 20 28 10 f0 	movl   $0xf0102820,(%esp)
f0101829:	e8 c1 f6 ff ff       	call   f0100eef <cprintf>
			return NULL;
f010182e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101833:	eb 6d                	jmp    f01018a2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101835:	83 f8 7f             	cmp    $0x7f,%eax
f0101838:	74 05                	je     f010183f <readline+0x5f>
f010183a:	83 f8 08             	cmp    $0x8,%eax
f010183d:	75 19                	jne    f0101858 <readline+0x78>
f010183f:	85 f6                	test   %esi,%esi
f0101841:	7e 15                	jle    f0101858 <readline+0x78>
			if (echoing)
f0101843:	85 ff                	test   %edi,%edi
f0101845:	74 0c                	je     f0101853 <readline+0x73>
				cputchar('\b');
f0101847:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010184e:	e8 9e ed ff ff       	call   f01005f1 <cputchar>
			i--;
f0101853:	83 ee 01             	sub    $0x1,%esi
f0101856:	eb bb                	jmp    f0101813 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101858:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010185e:	7f 1c                	jg     f010187c <readline+0x9c>
f0101860:	83 fb 1f             	cmp    $0x1f,%ebx
f0101863:	7e 17                	jle    f010187c <readline+0x9c>
			if (echoing)
f0101865:	85 ff                	test   %edi,%edi
f0101867:	74 08                	je     f0101871 <readline+0x91>
				cputchar(c);
f0101869:	89 1c 24             	mov    %ebx,(%esp)
f010186c:	e8 80 ed ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0101871:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f0101877:	8d 76 01             	lea    0x1(%esi),%esi
f010187a:	eb 97                	jmp    f0101813 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010187c:	83 fb 0d             	cmp    $0xd,%ebx
f010187f:	74 05                	je     f0101886 <readline+0xa6>
f0101881:	83 fb 0a             	cmp    $0xa,%ebx
f0101884:	75 8d                	jne    f0101813 <readline+0x33>
			if (echoing)
f0101886:	85 ff                	test   %edi,%edi
f0101888:	74 0c                	je     f0101896 <readline+0xb6>
				cputchar('\n');
f010188a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101891:	e8 5b ed ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0101896:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
			return buf;
f010189d:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
		}
	}
}
f01018a2:	83 c4 1c             	add    $0x1c,%esp
f01018a5:	5b                   	pop    %ebx
f01018a6:	5e                   	pop    %esi
f01018a7:	5f                   	pop    %edi
f01018a8:	5d                   	pop    %ebp
f01018a9:	c3                   	ret    
f01018aa:	66 90                	xchg   %ax,%ax
f01018ac:	66 90                	xchg   %ax,%ax
f01018ae:	66 90                	xchg   %ax,%ax

f01018b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01018b0:	55                   	push   %ebp
f01018b1:	89 e5                	mov    %esp,%ebp
f01018b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01018b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01018bb:	eb 03                	jmp    f01018c0 <strlen+0x10>
		n++;
f01018bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01018c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01018c4:	75 f7                	jne    f01018bd <strlen+0xd>
		n++;
	return n;
}
f01018c6:	5d                   	pop    %ebp
f01018c7:	c3                   	ret    

f01018c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01018c8:	55                   	push   %ebp
f01018c9:	89 e5                	mov    %esp,%ebp
f01018cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01018d6:	eb 03                	jmp    f01018db <strnlen+0x13>
		n++;
f01018d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018db:	39 d0                	cmp    %edx,%eax
f01018dd:	74 06                	je     f01018e5 <strnlen+0x1d>
f01018df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01018e3:	75 f3                	jne    f01018d8 <strnlen+0x10>
		n++;
	return n;
}
f01018e5:	5d                   	pop    %ebp
f01018e6:	c3                   	ret    

f01018e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01018e7:	55                   	push   %ebp
f01018e8:	89 e5                	mov    %esp,%ebp
f01018ea:	53                   	push   %ebx
f01018eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01018f1:	89 c2                	mov    %eax,%edx
f01018f3:	83 c2 01             	add    $0x1,%edx
f01018f6:	83 c1 01             	add    $0x1,%ecx
f01018f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01018fd:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101900:	84 db                	test   %bl,%bl
f0101902:	75 ef                	jne    f01018f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101904:	5b                   	pop    %ebx
f0101905:	5d                   	pop    %ebp
f0101906:	c3                   	ret    

f0101907 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101907:	55                   	push   %ebp
f0101908:	89 e5                	mov    %esp,%ebp
f010190a:	53                   	push   %ebx
f010190b:	83 ec 08             	sub    $0x8,%esp
f010190e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101911:	89 1c 24             	mov    %ebx,(%esp)
f0101914:	e8 97 ff ff ff       	call   f01018b0 <strlen>
	strcpy(dst + len, src);
f0101919:	8b 55 0c             	mov    0xc(%ebp),%edx
f010191c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101920:	01 d8                	add    %ebx,%eax
f0101922:	89 04 24             	mov    %eax,(%esp)
f0101925:	e8 bd ff ff ff       	call   f01018e7 <strcpy>
	return dst;
}
f010192a:	89 d8                	mov    %ebx,%eax
f010192c:	83 c4 08             	add    $0x8,%esp
f010192f:	5b                   	pop    %ebx
f0101930:	5d                   	pop    %ebp
f0101931:	c3                   	ret    

f0101932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101932:	55                   	push   %ebp
f0101933:	89 e5                	mov    %esp,%ebp
f0101935:	56                   	push   %esi
f0101936:	53                   	push   %ebx
f0101937:	8b 75 08             	mov    0x8(%ebp),%esi
f010193a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010193d:	89 f3                	mov    %esi,%ebx
f010193f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101942:	89 f2                	mov    %esi,%edx
f0101944:	eb 0f                	jmp    f0101955 <strncpy+0x23>
		*dst++ = *src;
f0101946:	83 c2 01             	add    $0x1,%edx
f0101949:	0f b6 01             	movzbl (%ecx),%eax
f010194c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010194f:	80 39 01             	cmpb   $0x1,(%ecx)
f0101952:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101955:	39 da                	cmp    %ebx,%edx
f0101957:	75 ed                	jne    f0101946 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101959:	89 f0                	mov    %esi,%eax
f010195b:	5b                   	pop    %ebx
f010195c:	5e                   	pop    %esi
f010195d:	5d                   	pop    %ebp
f010195e:	c3                   	ret    

f010195f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010195f:	55                   	push   %ebp
f0101960:	89 e5                	mov    %esp,%ebp
f0101962:	56                   	push   %esi
f0101963:	53                   	push   %ebx
f0101964:	8b 75 08             	mov    0x8(%ebp),%esi
f0101967:	8b 55 0c             	mov    0xc(%ebp),%edx
f010196a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010196d:	89 f0                	mov    %esi,%eax
f010196f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101973:	85 c9                	test   %ecx,%ecx
f0101975:	75 0b                	jne    f0101982 <strlcpy+0x23>
f0101977:	eb 1d                	jmp    f0101996 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101979:	83 c0 01             	add    $0x1,%eax
f010197c:	83 c2 01             	add    $0x1,%edx
f010197f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101982:	39 d8                	cmp    %ebx,%eax
f0101984:	74 0b                	je     f0101991 <strlcpy+0x32>
f0101986:	0f b6 0a             	movzbl (%edx),%ecx
f0101989:	84 c9                	test   %cl,%cl
f010198b:	75 ec                	jne    f0101979 <strlcpy+0x1a>
f010198d:	89 c2                	mov    %eax,%edx
f010198f:	eb 02                	jmp    f0101993 <strlcpy+0x34>
f0101991:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101993:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101996:	29 f0                	sub    %esi,%eax
}
f0101998:	5b                   	pop    %ebx
f0101999:	5e                   	pop    %esi
f010199a:	5d                   	pop    %ebp
f010199b:	c3                   	ret    

f010199c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010199c:	55                   	push   %ebp
f010199d:	89 e5                	mov    %esp,%ebp
f010199f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01019a5:	eb 06                	jmp    f01019ad <strcmp+0x11>
		p++, q++;
f01019a7:	83 c1 01             	add    $0x1,%ecx
f01019aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01019ad:	0f b6 01             	movzbl (%ecx),%eax
f01019b0:	84 c0                	test   %al,%al
f01019b2:	74 04                	je     f01019b8 <strcmp+0x1c>
f01019b4:	3a 02                	cmp    (%edx),%al
f01019b6:	74 ef                	je     f01019a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01019b8:	0f b6 c0             	movzbl %al,%eax
f01019bb:	0f b6 12             	movzbl (%edx),%edx
f01019be:	29 d0                	sub    %edx,%eax
}
f01019c0:	5d                   	pop    %ebp
f01019c1:	c3                   	ret    

f01019c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01019c2:	55                   	push   %ebp
f01019c3:	89 e5                	mov    %esp,%ebp
f01019c5:	53                   	push   %ebx
f01019c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01019c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01019cc:	89 c3                	mov    %eax,%ebx
f01019ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01019d1:	eb 06                	jmp    f01019d9 <strncmp+0x17>
		n--, p++, q++;
f01019d3:	83 c0 01             	add    $0x1,%eax
f01019d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01019d9:	39 d8                	cmp    %ebx,%eax
f01019db:	74 15                	je     f01019f2 <strncmp+0x30>
f01019dd:	0f b6 08             	movzbl (%eax),%ecx
f01019e0:	84 c9                	test   %cl,%cl
f01019e2:	74 04                	je     f01019e8 <strncmp+0x26>
f01019e4:	3a 0a                	cmp    (%edx),%cl
f01019e6:	74 eb                	je     f01019d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01019e8:	0f b6 00             	movzbl (%eax),%eax
f01019eb:	0f b6 12             	movzbl (%edx),%edx
f01019ee:	29 d0                	sub    %edx,%eax
f01019f0:	eb 05                	jmp    f01019f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01019f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01019f7:	5b                   	pop    %ebx
f01019f8:	5d                   	pop    %ebp
f01019f9:	c3                   	ret    

f01019fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01019fa:	55                   	push   %ebp
f01019fb:	89 e5                	mov    %esp,%ebp
f01019fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a04:	eb 07                	jmp    f0101a0d <strchr+0x13>
		if (*s == c)
f0101a06:	38 ca                	cmp    %cl,%dl
f0101a08:	74 0f                	je     f0101a19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a0a:	83 c0 01             	add    $0x1,%eax
f0101a0d:	0f b6 10             	movzbl (%eax),%edx
f0101a10:	84 d2                	test   %dl,%dl
f0101a12:	75 f2                	jne    f0101a06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a19:	5d                   	pop    %ebp
f0101a1a:	c3                   	ret    

f0101a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101a1b:	55                   	push   %ebp
f0101a1c:	89 e5                	mov    %esp,%ebp
f0101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a25:	eb 07                	jmp    f0101a2e <strfind+0x13>
		if (*s == c)
f0101a27:	38 ca                	cmp    %cl,%dl
f0101a29:	74 0a                	je     f0101a35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101a2b:	83 c0 01             	add    $0x1,%eax
f0101a2e:	0f b6 10             	movzbl (%eax),%edx
f0101a31:	84 d2                	test   %dl,%dl
f0101a33:	75 f2                	jne    f0101a27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0101a35:	5d                   	pop    %ebp
f0101a36:	c3                   	ret    

f0101a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101a37:	55                   	push   %ebp
f0101a38:	89 e5                	mov    %esp,%ebp
f0101a3a:	57                   	push   %edi
f0101a3b:	56                   	push   %esi
f0101a3c:	53                   	push   %ebx
f0101a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101a43:	85 c9                	test   %ecx,%ecx
f0101a45:	74 36                	je     f0101a7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101a4d:	75 28                	jne    f0101a77 <memset+0x40>
f0101a4f:	f6 c1 03             	test   $0x3,%cl
f0101a52:	75 23                	jne    f0101a77 <memset+0x40>
		c &= 0xFF;
f0101a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101a58:	89 d3                	mov    %edx,%ebx
f0101a5a:	c1 e3 08             	shl    $0x8,%ebx
f0101a5d:	89 d6                	mov    %edx,%esi
f0101a5f:	c1 e6 18             	shl    $0x18,%esi
f0101a62:	89 d0                	mov    %edx,%eax
f0101a64:	c1 e0 10             	shl    $0x10,%eax
f0101a67:	09 f0                	or     %esi,%eax
f0101a69:	09 c2                	or     %eax,%edx
f0101a6b:	89 d0                	mov    %edx,%eax
f0101a6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101a6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101a72:	fc                   	cld    
f0101a73:	f3 ab                	rep stos %eax,%es:(%edi)
f0101a75:	eb 06                	jmp    f0101a7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101a77:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a7a:	fc                   	cld    
f0101a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101a7d:	89 f8                	mov    %edi,%eax
f0101a7f:	5b                   	pop    %ebx
f0101a80:	5e                   	pop    %esi
f0101a81:	5f                   	pop    %edi
f0101a82:	5d                   	pop    %ebp
f0101a83:	c3                   	ret    

f0101a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101a84:	55                   	push   %ebp
f0101a85:	89 e5                	mov    %esp,%ebp
f0101a87:	57                   	push   %edi
f0101a88:	56                   	push   %esi
f0101a89:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101a92:	39 c6                	cmp    %eax,%esi
f0101a94:	73 35                	jae    f0101acb <memmove+0x47>
f0101a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101a99:	39 d0                	cmp    %edx,%eax
f0101a9b:	73 2e                	jae    f0101acb <memmove+0x47>
		s += n;
		d += n;
f0101a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101aa0:	89 d6                	mov    %edx,%esi
f0101aa2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101aaa:	75 13                	jne    f0101abf <memmove+0x3b>
f0101aac:	f6 c1 03             	test   $0x3,%cl
f0101aaf:	75 0e                	jne    f0101abf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101ab1:	83 ef 04             	sub    $0x4,%edi
f0101ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101ab7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101aba:	fd                   	std    
f0101abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101abd:	eb 09                	jmp    f0101ac8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101abf:	83 ef 01             	sub    $0x1,%edi
f0101ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101ac5:	fd                   	std    
f0101ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101ac8:	fc                   	cld    
f0101ac9:	eb 1d                	jmp    f0101ae8 <memmove+0x64>
f0101acb:	89 f2                	mov    %esi,%edx
f0101acd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101acf:	f6 c2 03             	test   $0x3,%dl
f0101ad2:	75 0f                	jne    f0101ae3 <memmove+0x5f>
f0101ad4:	f6 c1 03             	test   $0x3,%cl
f0101ad7:	75 0a                	jne    f0101ae3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101ad9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101adc:	89 c7                	mov    %eax,%edi
f0101ade:	fc                   	cld    
f0101adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101ae1:	eb 05                	jmp    f0101ae8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101ae3:	89 c7                	mov    %eax,%edi
f0101ae5:	fc                   	cld    
f0101ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101ae8:	5e                   	pop    %esi
f0101ae9:	5f                   	pop    %edi
f0101aea:	5d                   	pop    %ebp
f0101aeb:	c3                   	ret    

f0101aec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101aec:	55                   	push   %ebp
f0101aed:	89 e5                	mov    %esp,%ebp
f0101aef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101af2:	8b 45 10             	mov    0x10(%ebp),%eax
f0101af5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101af9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101afc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b00:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b03:	89 04 24             	mov    %eax,(%esp)
f0101b06:	e8 79 ff ff ff       	call   f0101a84 <memmove>
}
f0101b0b:	c9                   	leave  
f0101b0c:	c3                   	ret    

f0101b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101b0d:	55                   	push   %ebp
f0101b0e:	89 e5                	mov    %esp,%ebp
f0101b10:	56                   	push   %esi
f0101b11:	53                   	push   %ebx
f0101b12:	8b 55 08             	mov    0x8(%ebp),%edx
f0101b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b18:	89 d6                	mov    %edx,%esi
f0101b1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b1d:	eb 1a                	jmp    f0101b39 <memcmp+0x2c>
		if (*s1 != *s2)
f0101b1f:	0f b6 02             	movzbl (%edx),%eax
f0101b22:	0f b6 19             	movzbl (%ecx),%ebx
f0101b25:	38 d8                	cmp    %bl,%al
f0101b27:	74 0a                	je     f0101b33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101b29:	0f b6 c0             	movzbl %al,%eax
f0101b2c:	0f b6 db             	movzbl %bl,%ebx
f0101b2f:	29 d8                	sub    %ebx,%eax
f0101b31:	eb 0f                	jmp    f0101b42 <memcmp+0x35>
		s1++, s2++;
f0101b33:	83 c2 01             	add    $0x1,%edx
f0101b36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b39:	39 f2                	cmp    %esi,%edx
f0101b3b:	75 e2                	jne    f0101b1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b42:	5b                   	pop    %ebx
f0101b43:	5e                   	pop    %esi
f0101b44:	5d                   	pop    %ebp
f0101b45:	c3                   	ret    

f0101b46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101b46:	55                   	push   %ebp
f0101b47:	89 e5                	mov    %esp,%ebp
f0101b49:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101b4f:	89 c2                	mov    %eax,%edx
f0101b51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101b54:	eb 07                	jmp    f0101b5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b56:	38 08                	cmp    %cl,(%eax)
f0101b58:	74 07                	je     f0101b61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101b5a:	83 c0 01             	add    $0x1,%eax
f0101b5d:	39 d0                	cmp    %edx,%eax
f0101b5f:	72 f5                	jb     f0101b56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101b61:	5d                   	pop    %ebp
f0101b62:	c3                   	ret    

f0101b63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101b63:	55                   	push   %ebp
f0101b64:	89 e5                	mov    %esp,%ebp
f0101b66:	57                   	push   %edi
f0101b67:	56                   	push   %esi
f0101b68:	53                   	push   %ebx
f0101b69:	8b 55 08             	mov    0x8(%ebp),%edx
f0101b6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101b6f:	eb 03                	jmp    f0101b74 <strtol+0x11>
		s++;
f0101b71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101b74:	0f b6 0a             	movzbl (%edx),%ecx
f0101b77:	80 f9 09             	cmp    $0x9,%cl
f0101b7a:	74 f5                	je     f0101b71 <strtol+0xe>
f0101b7c:	80 f9 20             	cmp    $0x20,%cl
f0101b7f:	74 f0                	je     f0101b71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101b81:	80 f9 2b             	cmp    $0x2b,%cl
f0101b84:	75 0a                	jne    f0101b90 <strtol+0x2d>
		s++;
f0101b86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101b89:	bf 00 00 00 00       	mov    $0x0,%edi
f0101b8e:	eb 11                	jmp    f0101ba1 <strtol+0x3e>
f0101b90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101b95:	80 f9 2d             	cmp    $0x2d,%cl
f0101b98:	75 07                	jne    f0101ba1 <strtol+0x3e>
		s++, neg = 1;
f0101b9a:	8d 52 01             	lea    0x1(%edx),%edx
f0101b9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101ba1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101ba6:	75 15                	jne    f0101bbd <strtol+0x5a>
f0101ba8:	80 3a 30             	cmpb   $0x30,(%edx)
f0101bab:	75 10                	jne    f0101bbd <strtol+0x5a>
f0101bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101bb1:	75 0a                	jne    f0101bbd <strtol+0x5a>
		s += 2, base = 16;
f0101bb3:	83 c2 02             	add    $0x2,%edx
f0101bb6:	b8 10 00 00 00       	mov    $0x10,%eax
f0101bbb:	eb 10                	jmp    f0101bcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0101bbd:	85 c0                	test   %eax,%eax
f0101bbf:	75 0c                	jne    f0101bcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101bc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101bc3:	80 3a 30             	cmpb   $0x30,(%edx)
f0101bc6:	75 05                	jne    f0101bcd <strtol+0x6a>
		s++, base = 8;
f0101bc8:	83 c2 01             	add    $0x1,%edx
f0101bcb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0101bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101bd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101bd5:	0f b6 0a             	movzbl (%edx),%ecx
f0101bd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0101bdb:	89 f0                	mov    %esi,%eax
f0101bdd:	3c 09                	cmp    $0x9,%al
f0101bdf:	77 08                	ja     f0101be9 <strtol+0x86>
			dig = *s - '0';
f0101be1:	0f be c9             	movsbl %cl,%ecx
f0101be4:	83 e9 30             	sub    $0x30,%ecx
f0101be7:	eb 20                	jmp    f0101c09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0101be9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0101bec:	89 f0                	mov    %esi,%eax
f0101bee:	3c 19                	cmp    $0x19,%al
f0101bf0:	77 08                	ja     f0101bfa <strtol+0x97>
			dig = *s - 'a' + 10;
f0101bf2:	0f be c9             	movsbl %cl,%ecx
f0101bf5:	83 e9 57             	sub    $0x57,%ecx
f0101bf8:	eb 0f                	jmp    f0101c09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0101bfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0101bfd:	89 f0                	mov    %esi,%eax
f0101bff:	3c 19                	cmp    $0x19,%al
f0101c01:	77 16                	ja     f0101c19 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0101c03:	0f be c9             	movsbl %cl,%ecx
f0101c06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101c09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0101c0c:	7d 0f                	jge    f0101c1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0101c0e:	83 c2 01             	add    $0x1,%edx
f0101c11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0101c15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0101c17:	eb bc                	jmp    f0101bd5 <strtol+0x72>
f0101c19:	89 d8                	mov    %ebx,%eax
f0101c1b:	eb 02                	jmp    f0101c1f <strtol+0xbc>
f0101c1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0101c1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101c23:	74 05                	je     f0101c2a <strtol+0xc7>
		*endptr = (char *) s;
f0101c25:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0101c2a:	f7 d8                	neg    %eax
f0101c2c:	85 ff                	test   %edi,%edi
f0101c2e:	0f 44 c3             	cmove  %ebx,%eax
}
f0101c31:	5b                   	pop    %ebx
f0101c32:	5e                   	pop    %esi
f0101c33:	5f                   	pop    %edi
f0101c34:	5d                   	pop    %ebp
f0101c35:	c3                   	ret    
f0101c36:	66 90                	xchg   %ax,%ax
f0101c38:	66 90                	xchg   %ax,%ax
f0101c3a:	66 90                	xchg   %ax,%ax
f0101c3c:	66 90                	xchg   %ax,%ax
f0101c3e:	66 90                	xchg   %ax,%ax

f0101c40 <__udivdi3>:
f0101c40:	55                   	push   %ebp
f0101c41:	57                   	push   %edi
f0101c42:	56                   	push   %esi
f0101c43:	83 ec 0c             	sub    $0xc,%esp
f0101c46:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101c4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0101c4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101c52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101c56:	85 c0                	test   %eax,%eax
f0101c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c5c:	89 ea                	mov    %ebp,%edx
f0101c5e:	89 0c 24             	mov    %ecx,(%esp)
f0101c61:	75 2d                	jne    f0101c90 <__udivdi3+0x50>
f0101c63:	39 e9                	cmp    %ebp,%ecx
f0101c65:	77 61                	ja     f0101cc8 <__udivdi3+0x88>
f0101c67:	85 c9                	test   %ecx,%ecx
f0101c69:	89 ce                	mov    %ecx,%esi
f0101c6b:	75 0b                	jne    f0101c78 <__udivdi3+0x38>
f0101c6d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c72:	31 d2                	xor    %edx,%edx
f0101c74:	f7 f1                	div    %ecx
f0101c76:	89 c6                	mov    %eax,%esi
f0101c78:	31 d2                	xor    %edx,%edx
f0101c7a:	89 e8                	mov    %ebp,%eax
f0101c7c:	f7 f6                	div    %esi
f0101c7e:	89 c5                	mov    %eax,%ebp
f0101c80:	89 f8                	mov    %edi,%eax
f0101c82:	f7 f6                	div    %esi
f0101c84:	89 ea                	mov    %ebp,%edx
f0101c86:	83 c4 0c             	add    $0xc,%esp
f0101c89:	5e                   	pop    %esi
f0101c8a:	5f                   	pop    %edi
f0101c8b:	5d                   	pop    %ebp
f0101c8c:	c3                   	ret    
f0101c8d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c90:	39 e8                	cmp    %ebp,%eax
f0101c92:	77 24                	ja     f0101cb8 <__udivdi3+0x78>
f0101c94:	0f bd e8             	bsr    %eax,%ebp
f0101c97:	83 f5 1f             	xor    $0x1f,%ebp
f0101c9a:	75 3c                	jne    f0101cd8 <__udivdi3+0x98>
f0101c9c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101ca0:	39 34 24             	cmp    %esi,(%esp)
f0101ca3:	0f 86 9f 00 00 00    	jbe    f0101d48 <__udivdi3+0x108>
f0101ca9:	39 d0                	cmp    %edx,%eax
f0101cab:	0f 82 97 00 00 00    	jb     f0101d48 <__udivdi3+0x108>
f0101cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101cb8:	31 d2                	xor    %edx,%edx
f0101cba:	31 c0                	xor    %eax,%eax
f0101cbc:	83 c4 0c             	add    $0xc,%esp
f0101cbf:	5e                   	pop    %esi
f0101cc0:	5f                   	pop    %edi
f0101cc1:	5d                   	pop    %ebp
f0101cc2:	c3                   	ret    
f0101cc3:	90                   	nop
f0101cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101cc8:	89 f8                	mov    %edi,%eax
f0101cca:	f7 f1                	div    %ecx
f0101ccc:	31 d2                	xor    %edx,%edx
f0101cce:	83 c4 0c             	add    $0xc,%esp
f0101cd1:	5e                   	pop    %esi
f0101cd2:	5f                   	pop    %edi
f0101cd3:	5d                   	pop    %ebp
f0101cd4:	c3                   	ret    
f0101cd5:	8d 76 00             	lea    0x0(%esi),%esi
f0101cd8:	89 e9                	mov    %ebp,%ecx
f0101cda:	8b 3c 24             	mov    (%esp),%edi
f0101cdd:	d3 e0                	shl    %cl,%eax
f0101cdf:	89 c6                	mov    %eax,%esi
f0101ce1:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ce6:	29 e8                	sub    %ebp,%eax
f0101ce8:	89 c1                	mov    %eax,%ecx
f0101cea:	d3 ef                	shr    %cl,%edi
f0101cec:	89 e9                	mov    %ebp,%ecx
f0101cee:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101cf2:	8b 3c 24             	mov    (%esp),%edi
f0101cf5:	09 74 24 08          	or     %esi,0x8(%esp)
f0101cf9:	89 d6                	mov    %edx,%esi
f0101cfb:	d3 e7                	shl    %cl,%edi
f0101cfd:	89 c1                	mov    %eax,%ecx
f0101cff:	89 3c 24             	mov    %edi,(%esp)
f0101d02:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101d06:	d3 ee                	shr    %cl,%esi
f0101d08:	89 e9                	mov    %ebp,%ecx
f0101d0a:	d3 e2                	shl    %cl,%edx
f0101d0c:	89 c1                	mov    %eax,%ecx
f0101d0e:	d3 ef                	shr    %cl,%edi
f0101d10:	09 d7                	or     %edx,%edi
f0101d12:	89 f2                	mov    %esi,%edx
f0101d14:	89 f8                	mov    %edi,%eax
f0101d16:	f7 74 24 08          	divl   0x8(%esp)
f0101d1a:	89 d6                	mov    %edx,%esi
f0101d1c:	89 c7                	mov    %eax,%edi
f0101d1e:	f7 24 24             	mull   (%esp)
f0101d21:	39 d6                	cmp    %edx,%esi
f0101d23:	89 14 24             	mov    %edx,(%esp)
f0101d26:	72 30                	jb     f0101d58 <__udivdi3+0x118>
f0101d28:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101d2c:	89 e9                	mov    %ebp,%ecx
f0101d2e:	d3 e2                	shl    %cl,%edx
f0101d30:	39 c2                	cmp    %eax,%edx
f0101d32:	73 05                	jae    f0101d39 <__udivdi3+0xf9>
f0101d34:	3b 34 24             	cmp    (%esp),%esi
f0101d37:	74 1f                	je     f0101d58 <__udivdi3+0x118>
f0101d39:	89 f8                	mov    %edi,%eax
f0101d3b:	31 d2                	xor    %edx,%edx
f0101d3d:	e9 7a ff ff ff       	jmp    f0101cbc <__udivdi3+0x7c>
f0101d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d48:	31 d2                	xor    %edx,%edx
f0101d4a:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d4f:	e9 68 ff ff ff       	jmp    f0101cbc <__udivdi3+0x7c>
f0101d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d58:	8d 47 ff             	lea    -0x1(%edi),%eax
f0101d5b:	31 d2                	xor    %edx,%edx
f0101d5d:	83 c4 0c             	add    $0xc,%esp
f0101d60:	5e                   	pop    %esi
f0101d61:	5f                   	pop    %edi
f0101d62:	5d                   	pop    %ebp
f0101d63:	c3                   	ret    
f0101d64:	66 90                	xchg   %ax,%ax
f0101d66:	66 90                	xchg   %ax,%ax
f0101d68:	66 90                	xchg   %ax,%ax
f0101d6a:	66 90                	xchg   %ax,%ax
f0101d6c:	66 90                	xchg   %ax,%ax
f0101d6e:	66 90                	xchg   %ax,%ax

f0101d70 <__umoddi3>:
f0101d70:	55                   	push   %ebp
f0101d71:	57                   	push   %edi
f0101d72:	56                   	push   %esi
f0101d73:	83 ec 14             	sub    $0x14,%esp
f0101d76:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101d7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101d7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101d82:	89 c7                	mov    %eax,%edi
f0101d84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d88:	8b 44 24 30          	mov    0x30(%esp),%eax
f0101d8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101d90:	89 34 24             	mov    %esi,(%esp)
f0101d93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d97:	85 c0                	test   %eax,%eax
f0101d99:	89 c2                	mov    %eax,%edx
f0101d9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101d9f:	75 17                	jne    f0101db8 <__umoddi3+0x48>
f0101da1:	39 fe                	cmp    %edi,%esi
f0101da3:	76 4b                	jbe    f0101df0 <__umoddi3+0x80>
f0101da5:	89 c8                	mov    %ecx,%eax
f0101da7:	89 fa                	mov    %edi,%edx
f0101da9:	f7 f6                	div    %esi
f0101dab:	89 d0                	mov    %edx,%eax
f0101dad:	31 d2                	xor    %edx,%edx
f0101daf:	83 c4 14             	add    $0x14,%esp
f0101db2:	5e                   	pop    %esi
f0101db3:	5f                   	pop    %edi
f0101db4:	5d                   	pop    %ebp
f0101db5:	c3                   	ret    
f0101db6:	66 90                	xchg   %ax,%ax
f0101db8:	39 f8                	cmp    %edi,%eax
f0101dba:	77 54                	ja     f0101e10 <__umoddi3+0xa0>
f0101dbc:	0f bd e8             	bsr    %eax,%ebp
f0101dbf:	83 f5 1f             	xor    $0x1f,%ebp
f0101dc2:	75 5c                	jne    f0101e20 <__umoddi3+0xb0>
f0101dc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101dc8:	39 3c 24             	cmp    %edi,(%esp)
f0101dcb:	0f 87 e7 00 00 00    	ja     f0101eb8 <__umoddi3+0x148>
f0101dd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101dd5:	29 f1                	sub    %esi,%ecx
f0101dd7:	19 c7                	sbb    %eax,%edi
f0101dd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ddd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101de1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101de5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101de9:	83 c4 14             	add    $0x14,%esp
f0101dec:	5e                   	pop    %esi
f0101ded:	5f                   	pop    %edi
f0101dee:	5d                   	pop    %ebp
f0101def:	c3                   	ret    
f0101df0:	85 f6                	test   %esi,%esi
f0101df2:	89 f5                	mov    %esi,%ebp
f0101df4:	75 0b                	jne    f0101e01 <__umoddi3+0x91>
f0101df6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101dfb:	31 d2                	xor    %edx,%edx
f0101dfd:	f7 f6                	div    %esi
f0101dff:	89 c5                	mov    %eax,%ebp
f0101e01:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101e05:	31 d2                	xor    %edx,%edx
f0101e07:	f7 f5                	div    %ebp
f0101e09:	89 c8                	mov    %ecx,%eax
f0101e0b:	f7 f5                	div    %ebp
f0101e0d:	eb 9c                	jmp    f0101dab <__umoddi3+0x3b>
f0101e0f:	90                   	nop
f0101e10:	89 c8                	mov    %ecx,%eax
f0101e12:	89 fa                	mov    %edi,%edx
f0101e14:	83 c4 14             	add    $0x14,%esp
f0101e17:	5e                   	pop    %esi
f0101e18:	5f                   	pop    %edi
f0101e19:	5d                   	pop    %ebp
f0101e1a:	c3                   	ret    
f0101e1b:	90                   	nop
f0101e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e20:	8b 04 24             	mov    (%esp),%eax
f0101e23:	be 20 00 00 00       	mov    $0x20,%esi
f0101e28:	89 e9                	mov    %ebp,%ecx
f0101e2a:	29 ee                	sub    %ebp,%esi
f0101e2c:	d3 e2                	shl    %cl,%edx
f0101e2e:	89 f1                	mov    %esi,%ecx
f0101e30:	d3 e8                	shr    %cl,%eax
f0101e32:	89 e9                	mov    %ebp,%ecx
f0101e34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e38:	8b 04 24             	mov    (%esp),%eax
f0101e3b:	09 54 24 04          	or     %edx,0x4(%esp)
f0101e3f:	89 fa                	mov    %edi,%edx
f0101e41:	d3 e0                	shl    %cl,%eax
f0101e43:	89 f1                	mov    %esi,%ecx
f0101e45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e49:	8b 44 24 10          	mov    0x10(%esp),%eax
f0101e4d:	d3 ea                	shr    %cl,%edx
f0101e4f:	89 e9                	mov    %ebp,%ecx
f0101e51:	d3 e7                	shl    %cl,%edi
f0101e53:	89 f1                	mov    %esi,%ecx
f0101e55:	d3 e8                	shr    %cl,%eax
f0101e57:	89 e9                	mov    %ebp,%ecx
f0101e59:	09 f8                	or     %edi,%eax
f0101e5b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101e5f:	f7 74 24 04          	divl   0x4(%esp)
f0101e63:	d3 e7                	shl    %cl,%edi
f0101e65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101e69:	89 d7                	mov    %edx,%edi
f0101e6b:	f7 64 24 08          	mull   0x8(%esp)
f0101e6f:	39 d7                	cmp    %edx,%edi
f0101e71:	89 c1                	mov    %eax,%ecx
f0101e73:	89 14 24             	mov    %edx,(%esp)
f0101e76:	72 2c                	jb     f0101ea4 <__umoddi3+0x134>
f0101e78:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0101e7c:	72 22                	jb     f0101ea0 <__umoddi3+0x130>
f0101e7e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101e82:	29 c8                	sub    %ecx,%eax
f0101e84:	19 d7                	sbb    %edx,%edi
f0101e86:	89 e9                	mov    %ebp,%ecx
f0101e88:	89 fa                	mov    %edi,%edx
f0101e8a:	d3 e8                	shr    %cl,%eax
f0101e8c:	89 f1                	mov    %esi,%ecx
f0101e8e:	d3 e2                	shl    %cl,%edx
f0101e90:	89 e9                	mov    %ebp,%ecx
f0101e92:	d3 ef                	shr    %cl,%edi
f0101e94:	09 d0                	or     %edx,%eax
f0101e96:	89 fa                	mov    %edi,%edx
f0101e98:	83 c4 14             	add    $0x14,%esp
f0101e9b:	5e                   	pop    %esi
f0101e9c:	5f                   	pop    %edi
f0101e9d:	5d                   	pop    %ebp
f0101e9e:	c3                   	ret    
f0101e9f:	90                   	nop
f0101ea0:	39 d7                	cmp    %edx,%edi
f0101ea2:	75 da                	jne    f0101e7e <__umoddi3+0x10e>
f0101ea4:	8b 14 24             	mov    (%esp),%edx
f0101ea7:	89 c1                	mov    %eax,%ecx
f0101ea9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0101ead:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101eb1:	eb cb                	jmp    f0101e7e <__umoddi3+0x10e>
f0101eb3:	90                   	nop
f0101eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101eb8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0101ebc:	0f 82 0f ff ff ff    	jb     f0101dd1 <__umoddi3+0x61>
f0101ec2:	e9 1a ff ff ff       	jmp    f0101de1 <__umoddi3+0x71>
