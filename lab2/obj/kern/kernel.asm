
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
f0100063:	e8 6f 22 00 00       	call   f01022d7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 27 10 f0 	movl   $0xf0102780,(%esp)
f010007c:	e8 07 17 00 00       	call   f0101788 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 ac 0e 00 00       	call   f0100f32 <mem_init>

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
f01000c1:	c7 04 24 9b 27 10 f0 	movl   $0xf010279b,(%esp)
f01000c8:	e8 bb 16 00 00       	call   f0101788 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 7c 16 00 00       	call   f0101755 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 d7 27 10 f0 	movl   $0xf01027d7,(%esp)
f01000e0:	e8 a3 16 00 00       	call   f0101788 <cprintf>
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
f010010b:	c7 04 24 b3 27 10 f0 	movl   $0xf01027b3,(%esp)
f0100112:	e8 71 16 00 00       	call   f0101788 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 2f 16 00 00       	call   f0101755 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 d7 27 10 f0 	movl   $0xf01027d7,(%esp)
f010012d:	e8 56 16 00 00       	call   f0101788 <cprintf>
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
f010016b:	a1 24 45 11 f0       	mov    0xf0114524,%eax
f0100170:	8d 48 01             	lea    0x1(%eax),%ecx
f0100173:	89 0d 24 45 11 f0    	mov    %ecx,0xf0114524
f0100179:	88 90 20 43 11 f0    	mov    %dl,-0xfeebce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010017f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100185:	75 0a                	jne    f0100191 <cons_intr+0x35>
			cons.wpos = 0;
f0100187:	c7 05 24 45 11 f0 00 	movl   $0x0,0xf0114524
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
f01001b7:	83 0d 00 43 11 f0 40 	orl    $0x40,0xf0114300
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
f01001cf:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f01001d5:	89 cb                	mov    %ecx,%ebx
f01001d7:	83 e3 40             	and    $0x40,%ebx
f01001da:	83 e0 7f             	and    $0x7f,%eax
f01001dd:	85 db                	test   %ebx,%ebx
f01001df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e2:	0f b6 d2             	movzbl %dl,%edx
f01001e5:	0f b6 82 20 29 10 f0 	movzbl -0xfefd6e0(%edx),%eax
f01001ec:	83 c8 40             	or     $0x40,%eax
f01001ef:	0f b6 c0             	movzbl %al,%eax
f01001f2:	f7 d0                	not    %eax
f01001f4:	21 c1                	and    %eax,%ecx
f01001f6:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
		return 0;
f01001fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100201:	e9 9d 00 00 00       	jmp    f01002a3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100206:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f010020c:	f6 c1 40             	test   $0x40,%cl
f010020f:	74 0e                	je     f010021f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100211:	83 c8 80             	or     $0xffffff80,%eax
f0100214:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100216:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100219:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
	}

	shift |= shiftcode[data];
f010021f:	0f b6 d2             	movzbl %dl,%edx
f0100222:	0f b6 82 20 29 10 f0 	movzbl -0xfefd6e0(%edx),%eax
f0100229:	0b 05 00 43 11 f0    	or     0xf0114300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 20 28 10 f0 	movzbl -0xfefd7e0(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 43 11 f0       	mov    %eax,0xf0114300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 00 28 10 f0 	mov    -0xfefd800(,%ecx,4),%ecx
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
f0100282:	c7 04 24 cd 27 10 f0 	movl   $0xf01027cd,(%esp)
f0100289:	e8 fa 14 00 00       	call   f0101788 <cprintf>
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
f010035c:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f0100363:	66 85 c0             	test   %ax,%ax
f0100366:	0f 84 e5 00 00 00    	je     f0100451 <cons_putc+0x1a8>
			crt_pos--;
f010036c:	83 e8 01             	sub    $0x1,%eax
f010036f:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100375:	0f b7 c0             	movzwl %ax,%eax
f0100378:	66 81 e7 00 ff       	and    $0xff00,%di
f010037d:	83 cf 20             	or     $0x20,%edi
f0100380:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f0100386:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038a:	eb 78                	jmp    f0100404 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038c:	66 83 05 28 45 11 f0 	addw   $0x50,0xf0114528
f0100393:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100394:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f010039b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a1:	c1 e8 16             	shr    $0x16,%eax
f01003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a7:	c1 e0 04             	shl    $0x4,%eax
f01003aa:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
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
f01003e6:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f01003ed:	8d 50 01             	lea    0x1(%eax),%edx
f01003f0:	66 89 15 28 45 11 f0 	mov    %dx,0xf0114528
f01003f7:	0f b7 c0             	movzwl %ax,%eax
f01003fa:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f0100400:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100404:	66 81 3d 28 45 11 f0 	cmpw   $0x7cf,0xf0114528
f010040b:	cf 07 
f010040d:	76 42                	jbe    f0100451 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040f:	a1 2c 45 11 f0       	mov    0xf011452c,%eax
f0100414:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010041b:	00 
f010041c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100422:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100426:	89 04 24             	mov    %eax,(%esp)
f0100429:	e8 f6 1e 00 00       	call   f0102324 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042e:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
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
f0100449:	66 83 2d 28 45 11 f0 	subw   $0x50,0xf0114528
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 45 11 f0 	movzwl 0xf0114528,%ebx
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
f0100487:	80 3d 34 45 11 f0 00 	cmpb   $0x0,0xf0114534
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
f01004c5:	a1 20 45 11 f0       	mov    0xf0114520,%eax
f01004ca:	3b 05 24 45 11 f0    	cmp    0xf0114524,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 45 11 f0    	mov    %edx,0xf0114520
f01004db:	0f b6 88 20 43 11 f0 	movzbl -0xfeebce0(%eax),%ecx
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
f01004ec:	c7 05 20 45 11 f0 00 	movl   $0x0,0xf0114520
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
f0100525:	c7 05 30 45 11 f0 b4 	movl   $0x3b4,0xf0114530
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
f010053d:	c7 05 30 45 11 f0 d4 	movl   $0x3d4,0xf0114530
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
f010054c:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
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
f0100571:	89 3d 2c 45 11 f0    	mov    %edi,0xf011452c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100577:	0f b6 d8             	movzbl %al,%ebx
f010057a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057c:	66 89 35 28 45 11 f0 	mov    %si,0xf0114528
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
f01005cd:	88 0d 34 45 11 f0    	mov    %cl,0xf0114534
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
f01005dd:	c7 04 24 d9 27 10 f0 	movl   $0xf01027d9,(%esp)
f01005e4:	e8 9f 11 00 00       	call   f0101788 <cprintf>
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
f0100626:	c7 44 24 08 20 2a 10 	movl   $0xf0102a20,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 3e 2a 10 	movl   $0xf0102a3e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 43 2a 10 f0 	movl   $0xf0102a43,(%esp)
f010063d:	e8 46 11 00 00       	call   f0101788 <cprintf>
f0100642:	c7 44 24 08 e0 2a 10 	movl   $0xf0102ae0,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 4c 2a 10 	movl   $0xf0102a4c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 43 2a 10 f0 	movl   $0xf0102a43,(%esp)
f0100659:	e8 2a 11 00 00       	call   f0101788 <cprintf>
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
f010066b:	c7 04 24 55 2a 10 f0 	movl   $0xf0102a55,(%esp)
f0100672:	e8 11 11 00 00       	call   f0101788 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 08 2b 10 f0 	movl   $0xf0102b08,(%esp)
f0100686:	e8 fd 10 00 00       	call   f0101788 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 30 2b 10 f0 	movl   $0xf0102b30,(%esp)
f01006a2:	e8 e1 10 00 00       	call   f0101788 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 67 27 10 	movl   $0x102767,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 67 27 10 	movl   $0xf0102767,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 54 2b 10 f0 	movl   $0xf0102b54,(%esp)
f01006be:	e8 c5 10 00 00       	call   f0101788 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 43 11 	movl   $0x114300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 43 11 	movl   $0xf0114300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 78 2b 10 f0 	movl   $0xf0102b78,(%esp)
f01006da:	e8 a9 10 00 00       	call   f0101788 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 49 11 	movl   $0x114970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 49 11 	movl   $0xf0114970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 9c 2b 10 f0 	movl   $0xf0102b9c,(%esp)
f01006f6:	e8 8d 10 00 00       	call   f0101788 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006fb:	b8 6f 4d 11 f0       	mov    $0xf0114d6f,%eax
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
f010071c:	c7 04 24 c0 2b 10 f0 	movl   $0xf0102bc0,(%esp)
f0100723:	e8 60 10 00 00       	call   f0101788 <cprintf>
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
f010075e:	e8 1c 11 00 00       	call   f010187f <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 6e 2a 10 f0 	movl   $0xf0102a6e,(%esp)
f0100775:	e8 0e 10 00 00       	call   f0101788 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 89 2a 10 f0 	movl   $0xf0102a89,(%esp)
f010078a:	e8 f9 0f 00 00       	call   f0101788 <cprintf>
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
f0100796:	c7 04 24 d7 27 10 f0 	movl   $0xf01027d7,(%esp)
f010079d:	e8 e6 0f 00 00       	call   f0101788 <cprintf>
			
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
f01007c8:	c7 04 24 90 2a 10 f0 	movl   $0xf0102a90,(%esp)
f01007cf:	e8 b4 0f 00 00       	call   f0101788 <cprintf>
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
f01007fa:	c7 04 24 ec 2b 10 f0 	movl   $0xf0102bec,(%esp)
f0100801:	e8 82 0f 00 00       	call   f0101788 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 10 2c 10 f0 	movl   $0xf0102c10,(%esp)
f010080d:	e8 76 0f 00 00       	call   f0101788 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 a1 2a 10 f0 	movl   $0xf0102aa1,(%esp)
f0100819:	e8 62 18 00 00       	call   f0102080 <readline>
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
f010084a:	c7 04 24 a5 2a 10 f0 	movl   $0xf0102aa5,(%esp)
f0100851:	e8 44 1a 00 00       	call   f010229a <strchr>
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
f010086c:	c7 04 24 aa 2a 10 f0 	movl   $0xf0102aaa,(%esp)
f0100873:	e8 10 0f 00 00       	call   f0101788 <cprintf>
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
f0100894:	c7 04 24 a5 2a 10 f0 	movl   $0xf0102aa5,(%esp)
f010089b:	e8 fa 19 00 00       	call   f010229a <strchr>
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
f01008b6:	c7 44 24 04 3e 2a 10 	movl   $0xf0102a3e,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 73 19 00 00       	call   f010223c <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 4c 2a 10 	movl   $0xf0102a4c,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 5c 19 00 00       	call   f010223c <strcmp>
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
f0100903:	ff 14 85 40 2c 10 f0 	call   *-0xfefd3c0(,%eax,4)


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
f010091a:	c7 04 24 c7 2a 10 f0 	movl   $0xf0102ac7,(%esp)
f0100921:	e8 62 0e 00 00       	call   f0101788 <cprintf>
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
f0100936:	83 3d 38 45 11 f0 00 	cmpl   $0x0,0xf0114538
f010093d:	75 11                	jne    f0100950 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f010093f:	ba 6f 59 11 f0       	mov    $0xf011596f,%edx
f0100944:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094a:	89 15 38 45 11 f0    	mov    %edx,0xf0114538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100950:	85 c0                	test   %eax,%eax
f0100952:	75 07                	jne    f010095b <boot_alloc+0x28>
		return nextfree;
f0100954:	a1 38 45 11 f0       	mov    0xf0114538,%eax
f0100959:	eb 19                	jmp    f0100974 <boot_alloc+0x41>
	result = nextfree;
f010095b:	8b 15 38 45 11 f0    	mov    0xf0114538,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100961:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	a3 38 45 11 f0       	mov    %eax,0xf0114538
	
	// return the head address of the alloc pages;
	return result;
f0100972:	89 d0                	mov    %edx,%eax
}
f0100974:	5d                   	pop    %ebp
f0100975:	c3                   	ret    

f0100976 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100976:	89 d1                	mov    %edx,%ecx
f0100978:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010097b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010097e:	a8 01                	test   $0x1,%al
f0100980:	74 5d                	je     f01009df <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100982:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100987:	89 c1                	mov    %eax,%ecx
f0100989:	c1 e9 0c             	shr    $0xc,%ecx
f010098c:	3b 0d 64 49 11 f0    	cmp    0xf0114964,%ecx
f0100992:	72 26                	jb     f01009ba <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100994:	55                   	push   %ebp
f0100995:	89 e5                	mov    %esp,%ebp
f0100997:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010099a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010099e:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f01009a5:	f0 
f01009a6:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01009ad:	00 
f01009ae:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01009b5:	e8 da f6 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009ba:	c1 ea 0c             	shr    $0xc,%edx
f01009bd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009c3:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009ca:	89 c2                	mov    %eax,%edx
f01009cc:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d4:	85 d2                	test   %edx,%edx
f01009d6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009db:	0f 44 c2             	cmove  %edx,%eax
f01009de:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009e4:	c3                   	ret    

f01009e5 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009e5:	55                   	push   %ebp
f01009e6:	89 e5                	mov    %esp,%ebp
f01009e8:	57                   	push   %edi
f01009e9:	56                   	push   %esi
f01009ea:	53                   	push   %ebx
f01009eb:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009ee:	84 c0                	test   %al,%al
f01009f0:	0f 85 07 03 00 00    	jne    f0100cfd <check_page_free_list+0x318>
f01009f6:	e9 14 03 00 00       	jmp    f0100d0f <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009fb:	c7 44 24 08 74 2c 10 	movl   $0xf0102c74,0x8(%esp)
f0100a02:	f0 
f0100a03:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
f0100a0a:	00 
f0100a0b:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100a12:	e8 7d f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a17:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a1a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a1d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a23:	89 c2                	mov    %eax,%edx
f0100a25:	2b 15 6c 49 11 f0    	sub    0xf011496c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a2b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a31:	0f 95 c2             	setne  %dl
f0100a34:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a37:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a3b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a3d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a41:	8b 00                	mov    (%eax),%eax
f0100a43:	85 c0                	test   %eax,%eax
f0100a45:	75 dc                	jne    f0100a23 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a53:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a56:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a58:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a5b:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a60:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a65:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100a6b:	eb 63                	jmp    f0100ad0 <check_page_free_list+0xeb>
f0100a6d:	89 d8                	mov    %ebx,%eax
f0100a6f:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100a75:	c1 f8 03             	sar    $0x3,%eax
f0100a78:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a7b:	89 c2                	mov    %eax,%edx
f0100a7d:	c1 ea 16             	shr    $0x16,%edx
f0100a80:	39 f2                	cmp    %esi,%edx
f0100a82:	73 4a                	jae    f0100ace <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a84:	89 c2                	mov    %eax,%edx
f0100a86:	c1 ea 0c             	shr    $0xc,%edx
f0100a89:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100a8f:	72 20                	jb     f0100ab1 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a95:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f0100a9c:	f0 
f0100a9d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aa4:	00 
f0100aa5:	c7 04 24 54 2e 10 f0 	movl   $0xf0102e54,(%esp)
f0100aac:	e8 e3 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ab1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ab8:	00 
f0100ab9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ac0:	00 
	return (void *)(pa + KERNBASE);
f0100ac1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ac6:	89 04 24             	mov    %eax,(%esp)
f0100ac9:	e8 09 18 00 00       	call   f01022d7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ace:	8b 1b                	mov    (%ebx),%ebx
f0100ad0:	85 db                	test   %ebx,%ebx
f0100ad2:	75 99                	jne    f0100a6d <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ad4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad9:	e8 55 fe ff ff       	call   f0100933 <boot_alloc>
f0100ade:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ae1:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ae7:	8b 0d 6c 49 11 f0    	mov    0xf011496c,%ecx
		assert(pp < pages + npages);
f0100aed:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100af2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100af5:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100af8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100afb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100afe:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b03:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b06:	e9 97 01 00 00       	jmp    f0100ca2 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0b:	39 ca                	cmp    %ecx,%edx
f0100b0d:	73 24                	jae    f0100b33 <check_page_free_list+0x14e>
f0100b0f:	c7 44 24 0c 62 2e 10 	movl   $0xf0102e62,0xc(%esp)
f0100b16:	f0 
f0100b17:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100b1e:	f0 
f0100b1f:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
f0100b26:	00 
f0100b27:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100b2e:	e8 61 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b33:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b36:	72 24                	jb     f0100b5c <check_page_free_list+0x177>
f0100b38:	c7 44 24 0c 83 2e 10 	movl   $0xf0102e83,0xc(%esp)
f0100b3f:	f0 
f0100b40:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100b47:	f0 
f0100b48:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
f0100b4f:	00 
f0100b50:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100b57:	e8 38 f5 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b5c:	89 d0                	mov    %edx,%eax
f0100b5e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b61:	a8 07                	test   $0x7,%al
f0100b63:	74 24                	je     f0100b89 <check_page_free_list+0x1a4>
f0100b65:	c7 44 24 0c 98 2c 10 	movl   $0xf0102c98,0xc(%esp)
f0100b6c:	f0 
f0100b6d:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100b74:	f0 
f0100b75:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
f0100b7c:	00 
f0100b7d:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100b84:	e8 0b f5 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b89:	c1 f8 03             	sar    $0x3,%eax
f0100b8c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b8f:	85 c0                	test   %eax,%eax
f0100b91:	75 24                	jne    f0100bb7 <check_page_free_list+0x1d2>
f0100b93:	c7 44 24 0c 97 2e 10 	movl   $0xf0102e97,0xc(%esp)
f0100b9a:	f0 
f0100b9b:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100ba2:	f0 
f0100ba3:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
f0100baa:	00 
f0100bab:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100bb2:	e8 dd f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bb7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bbc:	75 24                	jne    f0100be2 <check_page_free_list+0x1fd>
f0100bbe:	c7 44 24 0c a8 2e 10 	movl   $0xf0102ea8,0xc(%esp)
f0100bc5:	f0 
f0100bc6:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100bcd:	f0 
f0100bce:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
f0100bd5:	00 
f0100bd6:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100bdd:	e8 b2 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be2:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100be7:	75 24                	jne    f0100c0d <check_page_free_list+0x228>
f0100be9:	c7 44 24 0c cc 2c 10 	movl   $0xf0102ccc,0xc(%esp)
f0100bf0:	f0 
f0100bf1:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100bf8:	f0 
f0100bf9:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
f0100c00:	00 
f0100c01:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100c08:	e8 87 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c0d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c12:	75 24                	jne    f0100c38 <check_page_free_list+0x253>
f0100c14:	c7 44 24 0c c1 2e 10 	movl   $0xf0102ec1,0xc(%esp)
f0100c1b:	f0 
f0100c1c:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100c23:	f0 
f0100c24:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0100c2b:	00 
f0100c2c:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100c33:	e8 5c f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c38:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c3d:	76 58                	jbe    f0100c97 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c3f:	89 c3                	mov    %eax,%ebx
f0100c41:	c1 eb 0c             	shr    $0xc,%ebx
f0100c44:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c47:	77 20                	ja     f0100c69 <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c4d:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f0100c54:	f0 
f0100c55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c5c:	00 
f0100c5d:	c7 04 24 54 2e 10 f0 	movl   $0xf0102e54,(%esp)
f0100c64:	e8 2b f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c69:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c6e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c71:	76 2a                	jbe    f0100c9d <check_page_free_list+0x2b8>
f0100c73:	c7 44 24 0c f0 2c 10 	movl   $0xf0102cf0,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100c92:	e8 fd f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c97:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100c9b:	eb 03                	jmp    f0100ca0 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100c9d:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca0:	8b 12                	mov    (%edx),%edx
f0100ca2:	85 d2                	test   %edx,%edx
f0100ca4:	0f 85 61 fe ff ff    	jne    f0100b0b <check_page_free_list+0x126>
f0100caa:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cad:	85 db                	test   %ebx,%ebx
f0100caf:	7f 24                	jg     f0100cd5 <check_page_free_list+0x2f0>
f0100cb1:	c7 44 24 0c db 2e 10 	movl   $0xf0102edb,0xc(%esp)
f0100cb8:	f0 
f0100cb9:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100cc0:	f0 
f0100cc1:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100cc8:	00 
f0100cc9:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100cd0:	e8 bf f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100cd5:	85 ff                	test   %edi,%edi
f0100cd7:	7f 4d                	jg     f0100d26 <check_page_free_list+0x341>
f0100cd9:	c7 44 24 0c ed 2e 10 	movl   $0xf0102eed,0xc(%esp)
f0100ce0:	f0 
f0100ce1:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0100ce8:	f0 
f0100ce9:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100cf0:	00 
f0100cf1:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100cf8:	e8 97 f3 ff ff       	call   f0100094 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cfd:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0100d02:	85 c0                	test   %eax,%eax
f0100d04:	0f 85 0d fd ff ff    	jne    f0100a17 <check_page_free_list+0x32>
f0100d0a:	e9 ec fc ff ff       	jmp    f01009fb <check_page_free_list+0x16>
f0100d0f:	83 3d 3c 45 11 f0 00 	cmpl   $0x0,0xf011453c
f0100d16:	0f 84 df fc ff ff    	je     f01009fb <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d1c:	be 00 04 00 00       	mov    $0x400,%esi
f0100d21:	e9 3f fd ff ff       	jmp    f0100a65 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d26:	83 c4 4c             	add    $0x4c,%esp
f0100d29:	5b                   	pop    %ebx
f0100d2a:	5e                   	pop    %esi
f0100d2b:	5f                   	pop    %edi
f0100d2c:	5d                   	pop    %ebp
f0100d2d:	c3                   	ret    

f0100d2e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d2e:	55                   	push   %ebp
f0100d2f:	89 e5                	mov    %esp,%ebp
f0100d31:	56                   	push   %esi
f0100d32:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d33:	be 00 00 00 00       	mov    $0x0,%esi
f0100d38:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d3d:	e9 c5 00 00 00       	jmp    f0100e07 <page_init+0xd9>
		if(i == 0)
f0100d42:	85 db                	test   %ebx,%ebx
f0100d44:	75 16                	jne    f0100d5c <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100d46:	a1 6c 49 11 f0       	mov    0xf011496c,%eax
f0100d4b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d57:	e9 a5 00 00 00       	jmp    f0100e01 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d5c:	3b 1d 40 45 11 f0    	cmp    0xf0114540,%ebx
f0100d62:	73 25                	jae    f0100d89 <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d64:	89 f0                	mov    %esi,%eax
f0100d66:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d6c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d72:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100d78:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d7a:	89 f0                	mov    %esi,%eax
f0100d7c:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d82:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
f0100d87:	eb 78                	jmp    f0100e01 <page_init+0xd3>
f0100d89:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d8f:	83 f8 5f             	cmp    $0x5f,%eax
f0100d92:	77 16                	ja     f0100daa <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100d94:	89 f0                	mov    %esi,%eax
f0100d96:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100d9c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100da2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100da8:	eb 57                	jmp    f0100e01 <page_init+0xd3>
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100daa:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100db0:	76 2c                	jbe    f0100dde <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100db2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db7:	e8 77 fb ff ff       	call   f0100933 <boot_alloc>
f0100dbc:	05 00 00 00 10       	add    $0x10000000,%eax
f0100dc1:	c1 e8 0c             	shr    $0xc,%eax
		}
	//	原来错误的，吧kern_pgdir当成了可用的，但是其实这个是前面申请的地址，是不可用的。
	//	应该是从新的地址开始，调用boot_alloc(0),可以返回当前空闲页的首地址。
	//	else if(i>=EXTPHYSMEM / PGSIZE && 
	//			i < ( ((int) (kern_pgdir)-KERNBASE) / PGSIZE)  )
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100dc4:	39 c3                	cmp    %eax,%ebx
f0100dc6:	73 16                	jae    f0100dde <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100dc8:	89 f0                	mov    %esi,%eax
f0100dca:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100dd0:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100dd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ddc:	eb 23                	jmp    f0100e01 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100dde:	89 f0                	mov    %esi,%eax
f0100de0:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100de6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dec:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100df2:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100df4:	89 f0                	mov    %esi,%eax
f0100df6:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100dfc:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e01:	83 c3 01             	add    $0x1,%ebx
f0100e04:	83 c6 08             	add    $0x8,%esi
f0100e07:	3b 1d 64 49 11 f0    	cmp    0xf0114964,%ebx
f0100e0d:	0f 82 2f ff ff ff    	jb     f0100d42 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100e13:	5b                   	pop    %ebx
f0100e14:	5e                   	pop    %esi
f0100e15:	5d                   	pop    %ebp
f0100e16:	c3                   	ret    

f0100e17 <page_alloc>:

//apply a page, if alloc_flage==0, do not initialize the page;
//if alloc_flags==1, initialize the page and make the entire page '\0';
struct PageInfo *
page_alloc(int alloc_flags)
{	
f0100e17:	55                   	push   %ebp
f0100e18:	89 e5                	mov    %esp,%ebp
f0100e1a:	53                   	push   %ebx
f0100e1b:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL)
f0100e1e:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100e24:	85 db                	test   %ebx,%ebx
f0100e26:	74 6f                	je     f0100e97 <page_alloc+0x80>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e28:	8b 03                	mov    (%ebx),%eax
f0100e2a:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
		page->pp_link = NULL;
f0100e2f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
f0100e35:	89 d8                	mov    %ebx,%eax
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
		page->pp_link = NULL;

		if(alloc_flags & ALLOC_ZERO)
f0100e37:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e3b:	74 5f                	je     f0100e9c <page_alloc+0x85>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e3d:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100e43:	c1 f8 03             	sar    $0x3,%eax
f0100e46:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e49:	89 c2                	mov    %eax,%edx
f0100e4b:	c1 ea 0c             	shr    $0xc,%edx
f0100e4e:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e54:	72 20                	jb     f0100e76 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e56:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e5a:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f0100e61:	f0 
f0100e62:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e69:	00 
f0100e6a:	c7 04 24 54 2e 10 f0 	movl   $0xf0102e54,(%esp)
f0100e71:	e8 1e f2 ff ff       	call   f0100094 <_panic>
	{
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
f0100e76:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e7d:	00 
f0100e7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e85:	00 
	return (void *)(pa + KERNBASE);
f0100e86:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e8b:	89 04 24             	mov    %eax,(%esp)
f0100e8e:	e8 44 14 00 00       	call   f01022d7 <memset>
	}

	return page;
f0100e93:	89 d8                	mov    %ebx,%eax
f0100e95:	eb 05                	jmp    f0100e9c <page_alloc+0x85>
struct PageInfo *
page_alloc(int alloc_flags)
{	
	// Fill this function in
	if(page_free_list == NULL)
		return NULL;
f0100e97:	b8 00 00 00 00       	mov    $0x0,%eax
		char* pageAddress = page2kva(page);
		memset(pageAddress,'\0',PGSIZE);
	}

	return page;
}
f0100e9c:	83 c4 14             	add    $0x14,%esp
f0100e9f:	5b                   	pop    %ebx
f0100ea0:	5d                   	pop    %ebp
f0100ea1:	c3                   	ret    

f0100ea2 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ea2:	55                   	push   %ebp
f0100ea3:	89 e5                	mov    %esp,%ebp
f0100ea5:	83 ec 18             	sub    $0x18,%esp
f0100ea8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link !=NULL)
f0100eab:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100eb0:	75 05                	jne    f0100eb7 <page_free+0x15>
f0100eb2:	83 38 00             	cmpl   $0x0,(%eax)
f0100eb5:	74 1c                	je     f0100ed3 <page_free+0x31>
		panic("pp_ref is not 0 or the pp_link is not NULL. The page is used\n");
f0100eb7:	c7 44 24 08 38 2d 10 	movl   $0xf0102d38,0x8(%esp)
f0100ebe:	f0 
f0100ebf:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100ec6:	00 
f0100ec7:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0100ece:	e8 c1 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100ed3:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100ed9:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100edb:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
	return;
}
f0100ee0:	c9                   	leave  
f0100ee1:	c3                   	ret    

f0100ee2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ee2:	55                   	push   %ebp
f0100ee3:	89 e5                	mov    %esp,%ebp
f0100ee5:	83 ec 18             	sub    $0x18,%esp
f0100ee8:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100eeb:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100eef:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100ef2:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100ef6:	66 85 d2             	test   %dx,%dx
f0100ef9:	75 08                	jne    f0100f03 <page_decref+0x21>
		page_free(pp);
f0100efb:	89 04 24             	mov    %eax,(%esp)
f0100efe:	e8 9f ff ff ff       	call   f0100ea2 <page_free>
}
f0100f03:	c9                   	leave  
f0100f04:	c3                   	ret    

f0100f05 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{	//typedef uint32_t physaddr_t;
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
f0100f08:	8b 55 0c             	mov    0xc(%ebp),%edx
	//即存储在的页表基地址是不是物理地址？
	//是物理地址，保存在cr3寄存器中。
	// Fill this function in
	//取得va的 Page Directory INDEX 的值
	//
	unsigned int pageDirIndex= (physaddr_t)(va) >> 22 & 0x3FF ;
f0100f0b:	89 d0                	mov    %edx,%eax
f0100f0d:	c1 e8 16             	shr    $0x16,%eax
	
	//从Page Directory INDEX中取出对应的page table的地址
	//
	physaddr_t* pageTableBaseAddre  = (physaddr_t*)  (pgdir + pageDirIndex);
f0100f10:	c1 e0 02             	shl    $0x2,%eax
	
	//如果pageTable还没有被创建，而且create==0，则return NULL
	//地址获取失败。
	//
	
	if(pageTableBaseAddre == NULL &&  create == 0)
f0100f13:	03 45 08             	add    0x8(%ebp),%eax
f0100f16:	75 06                	jne    f0100f1e <pgdir_walk+0x19>
f0100f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f1c:	74 0d                	je     f0100f2b <pgdir_walk+0x26>
		}
		**************************************/
	}
	//取出va对应的page table index
	
	unsigned int pageTableIndex = (physaddr_t ) (va) >> 12 & 0x3FF;
f0100f1e:	c1 ea 0a             	shr    $0xa,%edx
	physaddr_t* tempAddress = (physaddr_t*)
					((physaddr_t) (pageTableBaseAddre) >>12<<12 ||PTE_P |PTE_W | PTE_U);
	return (physaddr_t*) pageTableBaseAddre + pageTableIndex;
f0100f21:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100f27:	01 d0                	add    %edx,%eax
f0100f29:	eb 05                	jmp    f0100f30 <pgdir_walk+0x2b>
	//如果pageTable还没有被创建，而且create==0，则return NULL
	//地址获取失败。
	//
	
	if(pageTableBaseAddre == NULL &&  create == 0)
		return NULL;
f0100f2b:	b8 00 00 00 00       	mov    $0x0,%eax
				(physaddr_t) (vaPhyAddre) >>12<<12);
	unsigned int offset = (physaddr_t) va &0xFFF;
	vaPhyAddre = (physaddr_t *) vaPhyAddre +  offset;
	return vaPhyAddre;
	**********************************************/
}
f0100f30:	5d                   	pop    %ebp
f0100f31:	c3                   	ret    

f0100f32 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100f32:	55                   	push   %ebp
f0100f33:	89 e5                	mov    %esp,%ebp
f0100f35:	57                   	push   %edi
f0100f36:	56                   	push   %esi
f0100f37:	53                   	push   %ebx
f0100f38:	83 ec 2c             	sub    $0x2c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f3b:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0100f42:	e8 d1 07 00 00       	call   f0101718 <mc146818_read>
f0100f47:	89 c3                	mov    %eax,%ebx
f0100f49:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100f50:	e8 c3 07 00 00       	call   f0101718 <mc146818_read>
f0100f55:	c1 e0 08             	shl    $0x8,%eax
f0100f58:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100f5a:	89 d8                	mov    %ebx,%eax
f0100f5c:	c1 e0 0a             	shl    $0xa,%eax
f0100f5f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f65:	85 c0                	test   %eax,%eax
f0100f67:	0f 48 c2             	cmovs  %edx,%eax
f0100f6a:	c1 f8 0c             	sar    $0xc,%eax
f0100f6d:	a3 40 45 11 f0       	mov    %eax,0xf0114540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f72:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100f79:	e8 9a 07 00 00       	call   f0101718 <mc146818_read>
f0100f7e:	89 c3                	mov    %eax,%ebx
f0100f80:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0100f87:	e8 8c 07 00 00       	call   f0101718 <mc146818_read>
f0100f8c:	c1 e0 08             	shl    $0x8,%eax
f0100f8f:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100f91:	89 d8                	mov    %ebx,%eax
f0100f93:	c1 e0 0a             	shl    $0xa,%eax
f0100f96:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f9c:	85 c0                	test   %eax,%eax
f0100f9e:	0f 48 c2             	cmovs  %edx,%eax
f0100fa1:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100fa4:	85 c0                	test   %eax,%eax
f0100fa6:	74 0e                	je     f0100fb6 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100fa8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100fae:	89 15 64 49 11 f0    	mov    %edx,0xf0114964
f0100fb4:	eb 0c                	jmp    f0100fc2 <mem_init+0x90>
	else
		npages = npages_basemem;
f0100fb6:	8b 15 40 45 11 f0    	mov    0xf0114540,%edx
f0100fbc:	89 15 64 49 11 f0    	mov    %edx,0xf0114964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100fc2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fc5:	c1 e8 0a             	shr    $0xa,%eax
f0100fc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100fcc:	a1 40 45 11 f0       	mov    0xf0114540,%eax
f0100fd1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fd4:	c1 e8 0a             	shr    $0xa,%eax
f0100fd7:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100fdb:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100fe0:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100fe3:	c1 e8 0a             	shr    $0xa,%eax
f0100fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fea:	c7 04 24 78 2d 10 f0 	movl   $0xf0102d78,(%esp)
f0100ff1:	e8 92 07 00 00       	call   f0101788 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100ff6:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100ffb:	e8 33 f9 ff ff       	call   f0100933 <boot_alloc>
f0101000:	a3 68 49 11 f0       	mov    %eax,0xf0114968
	memset(kern_pgdir, 0, PGSIZE);
f0101005:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010100c:	00 
f010100d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101014:	00 
f0101015:	89 04 24             	mov    %eax,(%esp)
f0101018:	e8 ba 12 00 00       	call   f01022d7 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010101d:	a1 68 49 11 f0       	mov    0xf0114968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101022:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101027:	77 20                	ja     f0101049 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101029:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010102d:	c7 44 24 08 b4 2d 10 	movl   $0xf0102db4,0x8(%esp)
f0101034:	f0 
f0101035:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f010103c:	00 
f010103d:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101044:	e8 4b f0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101049:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010104f:	83 ca 05             	or     $0x5,%edx
f0101052:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0101058:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f010105d:	c1 e0 03             	shl    $0x3,%eax
f0101060:	e8 ce f8 ff ff       	call   f0100933 <boot_alloc>
f0101065:	a3 6c 49 11 f0       	mov    %eax,0xf011496c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f010106a:	8b 3d 64 49 11 f0    	mov    0xf0114964,%edi
f0101070:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101077:	89 54 24 08          	mov    %edx,0x8(%esp)
f010107b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101082:	00 
f0101083:	89 04 24             	mov    %eax,(%esp)
f0101086:	e8 4c 12 00 00       	call   f01022d7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010108b:	e8 9e fc ff ff       	call   f0100d2e <page_init>

	check_page_free_list(1);
f0101090:	b8 01 00 00 00       	mov    $0x1,%eax
f0101095:	e8 4b f9 ff ff       	call   f01009e5 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010109a:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f01010a1:	75 1c                	jne    f01010bf <mem_init+0x18d>
		panic("'pages' is a null pointer!");
f01010a3:	c7 44 24 08 fe 2e 10 	movl   $0xf0102efe,0x8(%esp)
f01010aa:	f0 
f01010ab:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f01010b2:	00 
f01010b3:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01010ba:	e8 d5 ef ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010bf:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f01010c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010c9:	eb 05                	jmp    f01010d0 <mem_init+0x19e>
		++nfree;
f01010cb:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010ce:	8b 00                	mov    (%eax),%eax
f01010d0:	85 c0                	test   %eax,%eax
f01010d2:	75 f7                	jne    f01010cb <mem_init+0x199>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010db:	e8 37 fd ff ff       	call   f0100e17 <page_alloc>
f01010e0:	89 c7                	mov    %eax,%edi
f01010e2:	85 c0                	test   %eax,%eax
f01010e4:	75 24                	jne    f010110a <mem_init+0x1d8>
f01010e6:	c7 44 24 0c 19 2f 10 	movl   $0xf0102f19,0xc(%esp)
f01010ed:	f0 
f01010ee:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01010f5:	f0 
f01010f6:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f01010fd:	00 
f01010fe:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101105:	e8 8a ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010110a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101111:	e8 01 fd ff ff       	call   f0100e17 <page_alloc>
f0101116:	89 c6                	mov    %eax,%esi
f0101118:	85 c0                	test   %eax,%eax
f010111a:	75 24                	jne    f0101140 <mem_init+0x20e>
f010111c:	c7 44 24 0c 2f 2f 10 	movl   $0xf0102f2f,0xc(%esp)
f0101123:	f0 
f0101124:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010112b:	f0 
f010112c:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0101133:	00 
f0101134:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010113b:	e8 54 ef ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101147:	e8 cb fc ff ff       	call   f0100e17 <page_alloc>
f010114c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010114f:	85 c0                	test   %eax,%eax
f0101151:	75 24                	jne    f0101177 <mem_init+0x245>
f0101153:	c7 44 24 0c 45 2f 10 	movl   $0xf0102f45,0xc(%esp)
f010115a:	f0 
f010115b:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101162:	f0 
f0101163:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f010116a:	00 
f010116b:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101172:	e8 1d ef ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101177:	39 f7                	cmp    %esi,%edi
f0101179:	75 24                	jne    f010119f <mem_init+0x26d>
f010117b:	c7 44 24 0c 5b 2f 10 	movl   $0xf0102f5b,0xc(%esp)
f0101182:	f0 
f0101183:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010118a:	f0 
f010118b:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0101192:	00 
f0101193:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010119a:	e8 f5 ee ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010119f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011a2:	39 c6                	cmp    %eax,%esi
f01011a4:	74 04                	je     f01011aa <mem_init+0x278>
f01011a6:	39 c7                	cmp    %eax,%edi
f01011a8:	75 24                	jne    f01011ce <mem_init+0x29c>
f01011aa:	c7 44 24 0c d8 2d 10 	movl   $0xf0102dd8,0xc(%esp)
f01011b1:	f0 
f01011b2:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01011b9:	f0 
f01011ba:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f01011c1:	00 
f01011c2:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01011c9:	e8 c6 ee ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011ce:	8b 15 6c 49 11 f0    	mov    0xf011496c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01011d4:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f01011d9:	c1 e0 0c             	shl    $0xc,%eax
f01011dc:	89 f9                	mov    %edi,%ecx
f01011de:	29 d1                	sub    %edx,%ecx
f01011e0:	c1 f9 03             	sar    $0x3,%ecx
f01011e3:	c1 e1 0c             	shl    $0xc,%ecx
f01011e6:	39 c1                	cmp    %eax,%ecx
f01011e8:	72 24                	jb     f010120e <mem_init+0x2dc>
f01011ea:	c7 44 24 0c 6d 2f 10 	movl   $0xf0102f6d,0xc(%esp)
f01011f1:	f0 
f01011f2:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01011f9:	f0 
f01011fa:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f0101201:	00 
f0101202:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101209:	e8 86 ee ff ff       	call   f0100094 <_panic>
f010120e:	89 f1                	mov    %esi,%ecx
f0101210:	29 d1                	sub    %edx,%ecx
f0101212:	c1 f9 03             	sar    $0x3,%ecx
f0101215:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101218:	39 c8                	cmp    %ecx,%eax
f010121a:	77 24                	ja     f0101240 <mem_init+0x30e>
f010121c:	c7 44 24 0c 8a 2f 10 	movl   $0xf0102f8a,0xc(%esp)
f0101223:	f0 
f0101224:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010122b:	f0 
f010122c:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0101233:	00 
f0101234:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010123b:	e8 54 ee ff ff       	call   f0100094 <_panic>
f0101240:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101243:	29 d1                	sub    %edx,%ecx
f0101245:	89 ca                	mov    %ecx,%edx
f0101247:	c1 fa 03             	sar    $0x3,%edx
f010124a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010124d:	39 d0                	cmp    %edx,%eax
f010124f:	77 24                	ja     f0101275 <mem_init+0x343>
f0101251:	c7 44 24 0c a7 2f 10 	movl   $0xf0102fa7,0xc(%esp)
f0101258:	f0 
f0101259:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101260:	f0 
f0101261:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0101268:	00 
f0101269:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101270:	e8 1f ee ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101275:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f010127a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f010127d:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f0101284:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010128e:	e8 84 fb ff ff       	call   f0100e17 <page_alloc>
f0101293:	85 c0                	test   %eax,%eax
f0101295:	74 24                	je     f01012bb <mem_init+0x389>
f0101297:	c7 44 24 0c c4 2f 10 	movl   $0xf0102fc4,0xc(%esp)
f010129e:	f0 
f010129f:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01012a6:	f0 
f01012a7:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f01012ae:	00 
f01012af:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01012b6:	e8 d9 ed ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01012bb:	89 3c 24             	mov    %edi,(%esp)
f01012be:	e8 df fb ff ff       	call   f0100ea2 <page_free>
	page_free(pp1);
f01012c3:	89 34 24             	mov    %esi,(%esp)
f01012c6:	e8 d7 fb ff ff       	call   f0100ea2 <page_free>
	page_free(pp2);
f01012cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012ce:	89 04 24             	mov    %eax,(%esp)
f01012d1:	e8 cc fb ff ff       	call   f0100ea2 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012dd:	e8 35 fb ff ff       	call   f0100e17 <page_alloc>
f01012e2:	89 c6                	mov    %eax,%esi
f01012e4:	85 c0                	test   %eax,%eax
f01012e6:	75 24                	jne    f010130c <mem_init+0x3da>
f01012e8:	c7 44 24 0c 19 2f 10 	movl   $0xf0102f19,0xc(%esp)
f01012ef:	f0 
f01012f0:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01012f7:	f0 
f01012f8:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f01012ff:	00 
f0101300:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101307:	e8 88 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010130c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101313:	e8 ff fa ff ff       	call   f0100e17 <page_alloc>
f0101318:	89 c7                	mov    %eax,%edi
f010131a:	85 c0                	test   %eax,%eax
f010131c:	75 24                	jne    f0101342 <mem_init+0x410>
f010131e:	c7 44 24 0c 2f 2f 10 	movl   $0xf0102f2f,0xc(%esp)
f0101325:	f0 
f0101326:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010132d:	f0 
f010132e:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f0101335:	00 
f0101336:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010133d:	e8 52 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101342:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101349:	e8 c9 fa ff ff       	call   f0100e17 <page_alloc>
f010134e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101351:	85 c0                	test   %eax,%eax
f0101353:	75 24                	jne    f0101379 <mem_init+0x447>
f0101355:	c7 44 24 0c 45 2f 10 	movl   $0xf0102f45,0xc(%esp)
f010135c:	f0 
f010135d:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101364:	f0 
f0101365:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f010136c:	00 
f010136d:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101374:	e8 1b ed ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101379:	39 fe                	cmp    %edi,%esi
f010137b:	75 24                	jne    f01013a1 <mem_init+0x46f>
f010137d:	c7 44 24 0c 5b 2f 10 	movl   $0xf0102f5b,0xc(%esp)
f0101384:	f0 
f0101385:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010138c:	f0 
f010138d:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0101394:	00 
f0101395:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010139c:	e8 f3 ec ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013a4:	39 c7                	cmp    %eax,%edi
f01013a6:	74 04                	je     f01013ac <mem_init+0x47a>
f01013a8:	39 c6                	cmp    %eax,%esi
f01013aa:	75 24                	jne    f01013d0 <mem_init+0x49e>
f01013ac:	c7 44 24 0c d8 2d 10 	movl   $0xf0102dd8,0xc(%esp)
f01013b3:	f0 
f01013b4:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01013bb:	f0 
f01013bc:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f01013c3:	00 
f01013c4:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01013cb:	e8 c4 ec ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01013d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013d7:	e8 3b fa ff ff       	call   f0100e17 <page_alloc>
f01013dc:	85 c0                	test   %eax,%eax
f01013de:	74 24                	je     f0101404 <mem_init+0x4d2>
f01013e0:	c7 44 24 0c c4 2f 10 	movl   $0xf0102fc4,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01013ff:	e8 90 ec ff ff       	call   f0100094 <_panic>
f0101404:	89 f0                	mov    %esi,%eax
f0101406:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f010140c:	c1 f8 03             	sar    $0x3,%eax
f010140f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101412:	89 c2                	mov    %eax,%edx
f0101414:	c1 ea 0c             	shr    $0xc,%edx
f0101417:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f010141d:	72 20                	jb     f010143f <mem_init+0x50d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101423:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f010142a:	f0 
f010142b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101432:	00 
f0101433:	c7 04 24 54 2e 10 f0 	movl   $0xf0102e54,(%esp)
f010143a:	e8 55 ec ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010143f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101446:	00 
f0101447:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010144e:	00 
	return (void *)(pa + KERNBASE);
f010144f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101454:	89 04 24             	mov    %eax,(%esp)
f0101457:	e8 7b 0e 00 00       	call   f01022d7 <memset>
	page_free(pp0);
f010145c:	89 34 24             	mov    %esi,(%esp)
f010145f:	e8 3e fa ff ff       	call   f0100ea2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101464:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010146b:	e8 a7 f9 ff ff       	call   f0100e17 <page_alloc>
f0101470:	85 c0                	test   %eax,%eax
f0101472:	75 24                	jne    f0101498 <mem_init+0x566>
f0101474:	c7 44 24 0c d3 2f 10 	movl   $0xf0102fd3,0xc(%esp)
f010147b:	f0 
f010147c:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101483:	f0 
f0101484:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f010148b:	00 
f010148c:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101493:	e8 fc eb ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101498:	39 c6                	cmp    %eax,%esi
f010149a:	74 24                	je     f01014c0 <mem_init+0x58e>
f010149c:	c7 44 24 0c f1 2f 10 	movl   $0xf0102ff1,0xc(%esp)
f01014a3:	f0 
f01014a4:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01014ab:	f0 
f01014ac:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01014b3:	00 
f01014b4:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01014bb:	e8 d4 eb ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014c0:	89 f0                	mov    %esi,%eax
f01014c2:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f01014c8:	c1 f8 03             	sar    $0x3,%eax
f01014cb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014ce:	89 c2                	mov    %eax,%edx
f01014d0:	c1 ea 0c             	shr    $0xc,%edx
f01014d3:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f01014d9:	72 20                	jb     f01014fb <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014df:	c7 44 24 08 50 2c 10 	movl   $0xf0102c50,0x8(%esp)
f01014e6:	f0 
f01014e7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01014ee:	00 
f01014ef:	c7 04 24 54 2e 10 f0 	movl   $0xf0102e54,(%esp)
f01014f6:	e8 99 eb ff ff       	call   f0100094 <_panic>
f01014fb:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101501:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101507:	80 38 00             	cmpb   $0x0,(%eax)
f010150a:	74 24                	je     f0101530 <mem_init+0x5fe>
f010150c:	c7 44 24 0c 01 30 10 	movl   $0xf0103001,0xc(%esp)
f0101513:	f0 
f0101514:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010151b:	f0 
f010151c:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0101523:	00 
f0101524:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010152b:	e8 64 eb ff ff       	call   f0100094 <_panic>
f0101530:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101533:	39 d0                	cmp    %edx,%eax
f0101535:	75 d0                	jne    f0101507 <mem_init+0x5d5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101537:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010153a:	a3 3c 45 11 f0       	mov    %eax,0xf011453c

	// free the pages we took
	page_free(pp0);
f010153f:	89 34 24             	mov    %esi,(%esp)
f0101542:	e8 5b f9 ff ff       	call   f0100ea2 <page_free>
	page_free(pp1);
f0101547:	89 3c 24             	mov    %edi,(%esp)
f010154a:	e8 53 f9 ff ff       	call   f0100ea2 <page_free>
	page_free(pp2);
f010154f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101552:	89 04 24             	mov    %eax,(%esp)
f0101555:	e8 48 f9 ff ff       	call   f0100ea2 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010155a:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f010155f:	eb 05                	jmp    f0101566 <mem_init+0x634>
		--nfree;
f0101561:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101564:	8b 00                	mov    (%eax),%eax
f0101566:	85 c0                	test   %eax,%eax
f0101568:	75 f7                	jne    f0101561 <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f010156a:	85 db                	test   %ebx,%ebx
f010156c:	74 24                	je     f0101592 <mem_init+0x660>
f010156e:	c7 44 24 0c 0b 30 10 	movl   $0xf010300b,0xc(%esp)
f0101575:	f0 
f0101576:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010157d:	f0 
f010157e:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f0101585:	00 
f0101586:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010158d:	e8 02 eb ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101592:	c7 04 24 f8 2d 10 f0 	movl   $0xf0102df8,(%esp)
f0101599:	e8 ea 01 00 00       	call   f0101788 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010159e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a5:	e8 6d f8 ff ff       	call   f0100e17 <page_alloc>
f01015aa:	89 c3                	mov    %eax,%ebx
f01015ac:	85 c0                	test   %eax,%eax
f01015ae:	75 24                	jne    f01015d4 <mem_init+0x6a2>
f01015b0:	c7 44 24 0c 19 2f 10 	movl   $0xf0102f19,0xc(%esp)
f01015b7:	f0 
f01015b8:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01015bf:	f0 
f01015c0:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01015c7:	00 
f01015c8:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01015cf:	e8 c0 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015db:	e8 37 f8 ff ff       	call   f0100e17 <page_alloc>
f01015e0:	89 c6                	mov    %eax,%esi
f01015e2:	85 c0                	test   %eax,%eax
f01015e4:	75 24                	jne    f010160a <mem_init+0x6d8>
f01015e6:	c7 44 24 0c 2f 2f 10 	movl   $0xf0102f2f,0xc(%esp)
f01015ed:	f0 
f01015ee:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01015f5:	f0 
f01015f6:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01015fd:	00 
f01015fe:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101605:	e8 8a ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010160a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101611:	e8 01 f8 ff ff       	call   f0100e17 <page_alloc>
f0101616:	85 c0                	test   %eax,%eax
f0101618:	75 24                	jne    f010163e <mem_init+0x70c>
f010161a:	c7 44 24 0c 45 2f 10 	movl   $0xf0102f45,0xc(%esp)
f0101621:	f0 
f0101622:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101629:	f0 
f010162a:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101631:	00 
f0101632:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101639:	e8 56 ea ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010163e:	39 f3                	cmp    %esi,%ebx
f0101640:	75 24                	jne    f0101666 <mem_init+0x734>
f0101642:	c7 44 24 0c 5b 2f 10 	movl   $0xf0102f5b,0xc(%esp)
f0101649:	f0 
f010164a:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f0101651:	f0 
f0101652:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101659:	00 
f010165a:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f0101661:	e8 2e ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101666:	39 c6                	cmp    %eax,%esi
f0101668:	74 04                	je     f010166e <mem_init+0x73c>
f010166a:	39 c3                	cmp    %eax,%ebx
f010166c:	75 24                	jne    f0101692 <mem_init+0x760>
f010166e:	c7 44 24 0c d8 2d 10 	movl   $0xf0102dd8,0xc(%esp)
f0101675:	f0 
f0101676:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f010167d:	f0 
f010167e:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101685:	00 
f0101686:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f010168d:	e8 02 ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101692:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f0101699:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010169c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016a3:	e8 6f f7 ff ff       	call   f0100e17 <page_alloc>
f01016a8:	85 c0                	test   %eax,%eax
f01016aa:	74 24                	je     f01016d0 <mem_init+0x79e>
f01016ac:	c7 44 24 0c c4 2f 10 	movl   $0xf0102fc4,0xc(%esp)
f01016b3:	f0 
f01016b4:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01016bb:	f0 
f01016bc:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01016c3:	00 
f01016c4:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01016cb:	e8 c4 e9 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016d0:	c7 44 24 0c 18 2e 10 	movl   $0xf0102e18,0xc(%esp)
f01016d7:	f0 
f01016d8:	c7 44 24 08 6e 2e 10 	movl   $0xf0102e6e,0x8(%esp)
f01016df:	f0 
f01016e0:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01016e7:	00 
f01016e8:	c7 04 24 48 2e 10 f0 	movl   $0xf0102e48,(%esp)
f01016ef:	e8 a0 e9 ff ff       	call   f0100094 <_panic>

f01016f4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016f4:	55                   	push   %ebp
f01016f5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01016f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01016fc:	5d                   	pop    %ebp
f01016fd:	c3                   	ret    

f01016fe <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01016fe:	55                   	push   %ebp
f01016ff:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0101701:	b8 00 00 00 00       	mov    $0x0,%eax
f0101706:	5d                   	pop    %ebp
f0101707:	c3                   	ret    

f0101708 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101708:	55                   	push   %ebp
f0101709:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010170b:	5d                   	pop    %ebp
f010170c:	c3                   	ret    

f010170d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010170d:	55                   	push   %ebp
f010170e:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101710:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101713:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101716:	5d                   	pop    %ebp
f0101717:	c3                   	ret    

f0101718 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101718:	55                   	push   %ebp
f0101719:	89 e5                	mov    %esp,%ebp
f010171b:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010171f:	ba 70 00 00 00       	mov    $0x70,%edx
f0101724:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101725:	b2 71                	mov    $0x71,%dl
f0101727:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101728:	0f b6 c0             	movzbl %al,%eax
}
f010172b:	5d                   	pop    %ebp
f010172c:	c3                   	ret    

f010172d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010172d:	55                   	push   %ebp
f010172e:	89 e5                	mov    %esp,%ebp
f0101730:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101734:	ba 70 00 00 00       	mov    $0x70,%edx
f0101739:	ee                   	out    %al,(%dx)
f010173a:	b2 71                	mov    $0x71,%dl
f010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010173f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101740:	5d                   	pop    %ebp
f0101741:	c3                   	ret    

f0101742 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101742:	55                   	push   %ebp
f0101743:	89 e5                	mov    %esp,%ebp
f0101745:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101748:	8b 45 08             	mov    0x8(%ebp),%eax
f010174b:	89 04 24             	mov    %eax,(%esp)
f010174e:	e8 9e ee ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0101753:	c9                   	leave  
f0101754:	c3                   	ret    

f0101755 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101755:	55                   	push   %ebp
f0101756:	89 e5                	mov    %esp,%ebp
f0101758:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010175b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101762:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101765:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101769:	8b 45 08             	mov    0x8(%ebp),%eax
f010176c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101770:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101773:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101777:	c7 04 24 42 17 10 f0 	movl   $0xf0101742,(%esp)
f010177e:	e8 11 04 00 00       	call   f0101b94 <vprintfmt>
	return cnt;
}
f0101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101786:	c9                   	leave  
f0101787:	c3                   	ret    

f0101788 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101788:	55                   	push   %ebp
f0101789:	89 e5                	mov    %esp,%ebp
f010178b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010178e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101791:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101795:	8b 45 08             	mov    0x8(%ebp),%eax
f0101798:	89 04 24             	mov    %eax,(%esp)
f010179b:	e8 b5 ff ff ff       	call   f0101755 <vcprintf>
	va_end(ap);

	return cnt;
}
f01017a0:	c9                   	leave  
f01017a1:	c3                   	ret    

f01017a2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01017a2:	55                   	push   %ebp
f01017a3:	89 e5                	mov    %esp,%ebp
f01017a5:	57                   	push   %edi
f01017a6:	56                   	push   %esi
f01017a7:	53                   	push   %ebx
f01017a8:	83 ec 10             	sub    $0x10,%esp
f01017ab:	89 c6                	mov    %eax,%esi
f01017ad:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01017b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01017b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01017b6:	8b 1a                	mov    (%edx),%ebx
f01017b8:	8b 01                	mov    (%ecx),%eax
f01017ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01017bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f01017c4:	eb 77                	jmp    f010183d <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f01017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017c9:	01 d8                	add    %ebx,%eax
f01017cb:	b9 02 00 00 00       	mov    $0x2,%ecx
f01017d0:	99                   	cltd   
f01017d1:	f7 f9                	idiv   %ecx
f01017d3:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017d5:	eb 01                	jmp    f01017d8 <stab_binsearch+0x36>
			m--;
f01017d7:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017d8:	39 d9                	cmp    %ebx,%ecx
f01017da:	7c 1d                	jl     f01017f9 <stab_binsearch+0x57>
f01017dc:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01017df:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f01017e4:	39 fa                	cmp    %edi,%edx
f01017e6:	75 ef                	jne    f01017d7 <stab_binsearch+0x35>
f01017e8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01017eb:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01017ee:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f01017f2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01017f5:	73 18                	jae    f010180f <stab_binsearch+0x6d>
f01017f7:	eb 05                	jmp    f01017fe <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01017f9:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f01017fc:	eb 3f                	jmp    f010183d <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01017fe:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0101801:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0101803:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101806:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f010180d:	eb 2e                	jmp    f010183d <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010180f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0101812:	73 15                	jae    f0101829 <stab_binsearch+0x87>
			*region_right = m - 1;
f0101814:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101817:	48                   	dec    %eax
f0101818:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010181b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010181e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101820:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101827:	eb 14                	jmp    f010183d <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101829:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010182c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010182f:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0101831:	ff 45 0c             	incl   0xc(%ebp)
f0101834:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101836:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010183d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101840:	7e 84                	jle    f01017c6 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101842:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101846:	75 0d                	jne    f0101855 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0101848:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010184b:	8b 00                	mov    (%eax),%eax
f010184d:	48                   	dec    %eax
f010184e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101851:	89 07                	mov    %eax,(%edi)
f0101853:	eb 22                	jmp    f0101877 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101858:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010185a:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010185d:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010185f:	eb 01                	jmp    f0101862 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101861:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101862:	39 c1                	cmp    %eax,%ecx
f0101864:	7d 0c                	jge    f0101872 <stab_binsearch+0xd0>
f0101866:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0101869:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f010186e:	39 fa                	cmp    %edi,%edx
f0101870:	75 ef                	jne    f0101861 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101872:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101875:	89 07                	mov    %eax,(%edi)
	}
}
f0101877:	83 c4 10             	add    $0x10,%esp
f010187a:	5b                   	pop    %ebx
f010187b:	5e                   	pop    %esi
f010187c:	5f                   	pop    %edi
f010187d:	5d                   	pop    %ebp
f010187e:	c3                   	ret    

f010187f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010187f:	55                   	push   %ebp
f0101880:	89 e5                	mov    %esp,%ebp
f0101882:	57                   	push   %edi
f0101883:	56                   	push   %esi
f0101884:	53                   	push   %ebx
f0101885:	83 ec 2c             	sub    $0x2c,%esp
f0101888:	8b 75 08             	mov    0x8(%ebp),%esi
f010188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010188e:	c7 03 16 30 10 f0    	movl   $0xf0103016,(%ebx)
	info->eip_line = 0;
f0101894:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010189b:	c7 43 08 16 30 10 f0 	movl   $0xf0103016,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01018a2:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01018a9:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01018ac:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01018b3:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01018b9:	76 12                	jbe    f01018cd <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018bb:	b8 78 9c 10 f0       	mov    $0xf0109c78,%eax
f01018c0:	3d 81 7f 10 f0       	cmp    $0xf0107f81,%eax
f01018c5:	0f 86 6b 01 00 00    	jbe    f0101a36 <debuginfo_eip+0x1b7>
f01018cb:	eb 1c                	jmp    f01018e9 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01018cd:	c7 44 24 08 20 30 10 	movl   $0xf0103020,0x8(%esp)
f01018d4:	f0 
f01018d5:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f01018dc:	00 
f01018dd:	c7 04 24 2d 30 10 f0 	movl   $0xf010302d,(%esp)
f01018e4:	e8 ab e7 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018e9:	80 3d 77 9c 10 f0 00 	cmpb   $0x0,0xf0109c77
f01018f0:	0f 85 47 01 00 00    	jne    f0101a3d <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01018f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01018fd:	b8 80 7f 10 f0       	mov    $0xf0107f80,%eax
f0101902:	2d 70 32 10 f0       	sub    $0xf0103270,%eax
f0101907:	c1 f8 02             	sar    $0x2,%eax
f010190a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101910:	83 e8 01             	sub    $0x1,%eax
f0101913:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101916:	89 74 24 04          	mov    %esi,0x4(%esp)
f010191a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101921:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101924:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101927:	b8 70 32 10 f0       	mov    $0xf0103270,%eax
f010192c:	e8 71 fe ff ff       	call   f01017a2 <stab_binsearch>
	if (lfile == 0)
f0101931:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101934:	85 c0                	test   %eax,%eax
f0101936:	0f 84 08 01 00 00    	je     f0101a44 <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010193c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010193f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101942:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101945:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101949:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101950:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101953:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101956:	b8 70 32 10 f0       	mov    $0xf0103270,%eax
f010195b:	e8 42 fe ff ff       	call   f01017a2 <stab_binsearch>

	if (lfun <= rfun) {
f0101960:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101963:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0101966:	7f 2e                	jg     f0101996 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101968:	6b c7 0c             	imul   $0xc,%edi,%eax
f010196b:	8d 90 70 32 10 f0    	lea    -0xfefcd90(%eax),%edx
f0101971:	8b 80 70 32 10 f0    	mov    -0xfefcd90(%eax),%eax
f0101977:	b9 78 9c 10 f0       	mov    $0xf0109c78,%ecx
f010197c:	81 e9 81 7f 10 f0    	sub    $0xf0107f81,%ecx
f0101982:	39 c8                	cmp    %ecx,%eax
f0101984:	73 08                	jae    f010198e <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101986:	05 81 7f 10 f0       	add    $0xf0107f81,%eax
f010198b:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010198e:	8b 42 08             	mov    0x8(%edx),%eax
f0101991:	89 43 10             	mov    %eax,0x10(%ebx)
f0101994:	eb 06                	jmp    f010199c <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101996:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010199c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01019a3:	00 
f01019a4:	8b 43 08             	mov    0x8(%ebx),%eax
f01019a7:	89 04 24             	mov    %eax,(%esp)
f01019aa:	e8 0c 09 00 00       	call   f01022bb <strfind>
f01019af:	2b 43 08             	sub    0x8(%ebx),%eax
f01019b2:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01019b5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01019b8:	6b c7 0c             	imul   $0xc,%edi,%eax
f01019bb:	05 70 32 10 f0       	add    $0xf0103270,%eax
f01019c0:	eb 06                	jmp    f01019c8 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01019c2:	83 ef 01             	sub    $0x1,%edi
f01019c5:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01019c8:	39 cf                	cmp    %ecx,%edi
f01019ca:	7c 33                	jl     f01019ff <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f01019cc:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01019d0:	80 fa 84             	cmp    $0x84,%dl
f01019d3:	74 0b                	je     f01019e0 <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01019d5:	80 fa 64             	cmp    $0x64,%dl
f01019d8:	75 e8                	jne    f01019c2 <debuginfo_eip+0x143>
f01019da:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01019de:	74 e2                	je     f01019c2 <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01019e0:	6b ff 0c             	imul   $0xc,%edi,%edi
f01019e3:	8b 87 70 32 10 f0    	mov    -0xfefcd90(%edi),%eax
f01019e9:	ba 78 9c 10 f0       	mov    $0xf0109c78,%edx
f01019ee:	81 ea 81 7f 10 f0    	sub    $0xf0107f81,%edx
f01019f4:	39 d0                	cmp    %edx,%eax
f01019f6:	73 07                	jae    f01019ff <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01019f8:	05 81 7f 10 f0       	add    $0xf0107f81,%eax
f01019fd:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01019ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101a02:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a05:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101a0a:	39 f1                	cmp    %esi,%ecx
f0101a0c:	7d 42                	jge    f0101a50 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0101a0e:	8d 51 01             	lea    0x1(%ecx),%edx
f0101a11:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0101a14:	05 70 32 10 f0       	add    $0xf0103270,%eax
f0101a19:	eb 07                	jmp    f0101a22 <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101a1b:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0101a1f:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101a22:	39 f2                	cmp    %esi,%edx
f0101a24:	74 25                	je     f0101a4b <debuginfo_eip+0x1cc>
f0101a26:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101a29:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0101a2d:	74 ec                	je     f0101a1b <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a34:	eb 1a                	jmp    f0101a50 <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a3b:	eb 13                	jmp    f0101a50 <debuginfo_eip+0x1d1>
f0101a3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a42:	eb 0c                	jmp    f0101a50 <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0101a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a49:	eb 05                	jmp    f0101a50 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a50:	83 c4 2c             	add    $0x2c,%esp
f0101a53:	5b                   	pop    %ebx
f0101a54:	5e                   	pop    %esi
f0101a55:	5f                   	pop    %edi
f0101a56:	5d                   	pop    %ebp
f0101a57:	c3                   	ret    
f0101a58:	66 90                	xchg   %ax,%ax
f0101a5a:	66 90                	xchg   %ax,%ax
f0101a5c:	66 90                	xchg   %ax,%ax
f0101a5e:	66 90                	xchg   %ax,%ax

f0101a60 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101a60:	55                   	push   %ebp
f0101a61:	89 e5                	mov    %esp,%ebp
f0101a63:	57                   	push   %edi
f0101a64:	56                   	push   %esi
f0101a65:	53                   	push   %ebx
f0101a66:	83 ec 3c             	sub    $0x3c,%esp
f0101a69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a6c:	89 d7                	mov    %edx,%edi
f0101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101a74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a77:	89 c3                	mov    %eax,%ebx
f0101a79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a7c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a7f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101a82:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101a87:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101a8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101a8d:	39 d9                	cmp    %ebx,%ecx
f0101a8f:	72 05                	jb     f0101a96 <printnum+0x36>
f0101a91:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0101a94:	77 69                	ja     f0101aff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101a96:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0101a99:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101a9d:	83 ee 01             	sub    $0x1,%esi
f0101aa0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101aa4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101aa8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101aac:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101ab0:	89 c3                	mov    %eax,%ebx
f0101ab2:	89 d6                	mov    %edx,%esi
f0101ab4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101ab7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101aba:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101abe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101ac2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ac5:	89 04 24             	mov    %eax,(%esp)
f0101ac8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101acf:	e8 0c 0a 00 00       	call   f01024e0 <__udivdi3>
f0101ad4:	89 d9                	mov    %ebx,%ecx
f0101ad6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ada:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101ade:	89 04 24             	mov    %eax,(%esp)
f0101ae1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101ae5:	89 fa                	mov    %edi,%edx
f0101ae7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101aea:	e8 71 ff ff ff       	call   f0101a60 <printnum>
f0101aef:	eb 1b                	jmp    f0101b0c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101af1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101af5:	8b 45 18             	mov    0x18(%ebp),%eax
f0101af8:	89 04 24             	mov    %eax,(%esp)
f0101afb:	ff d3                	call   *%ebx
f0101afd:	eb 03                	jmp    f0101b02 <printnum+0xa2>
f0101aff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101b02:	83 ee 01             	sub    $0x1,%esi
f0101b05:	85 f6                	test   %esi,%esi
f0101b07:	7f e8                	jg     f0101af1 <printnum+0x91>
f0101b09:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101b0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b10:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101b14:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101b17:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101b1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101b25:	89 04 24             	mov    %eax,(%esp)
f0101b28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b2f:	e8 dc 0a 00 00       	call   f0102610 <__umoddi3>
f0101b34:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b38:	0f be 80 3b 30 10 f0 	movsbl -0xfefcfc5(%eax),%eax
f0101b3f:	89 04 24             	mov    %eax,(%esp)
f0101b42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b45:	ff d0                	call   *%eax
}
f0101b47:	83 c4 3c             	add    $0x3c,%esp
f0101b4a:	5b                   	pop    %ebx
f0101b4b:	5e                   	pop    %esi
f0101b4c:	5f                   	pop    %edi
f0101b4d:	5d                   	pop    %ebp
f0101b4e:	c3                   	ret    

f0101b4f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101b4f:	55                   	push   %ebp
f0101b50:	89 e5                	mov    %esp,%ebp
f0101b52:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101b55:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101b59:	8b 10                	mov    (%eax),%edx
f0101b5b:	3b 50 04             	cmp    0x4(%eax),%edx
f0101b5e:	73 0a                	jae    f0101b6a <sprintputch+0x1b>
		*b->buf++ = ch;
f0101b60:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101b63:	89 08                	mov    %ecx,(%eax)
f0101b65:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b68:	88 02                	mov    %al,(%edx)
}
f0101b6a:	5d                   	pop    %ebp
f0101b6b:	c3                   	ret    

f0101b6c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101b6c:	55                   	push   %ebp
f0101b6d:	89 e5                	mov    %esp,%ebp
f0101b6f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101b72:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b79:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b7c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b87:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b8a:	89 04 24             	mov    %eax,(%esp)
f0101b8d:	e8 02 00 00 00       	call   f0101b94 <vprintfmt>
	va_end(ap);
}
f0101b92:	c9                   	leave  
f0101b93:	c3                   	ret    

f0101b94 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101b94:	55                   	push   %ebp
f0101b95:	89 e5                	mov    %esp,%ebp
f0101b97:	57                   	push   %edi
f0101b98:	56                   	push   %esi
f0101b99:	53                   	push   %ebx
f0101b9a:	83 ec 3c             	sub    $0x3c,%esp
f0101b9d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101ba3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101ba6:	eb 11                	jmp    f0101bb9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101ba8:	85 c0                	test   %eax,%eax
f0101baa:	0f 84 48 04 00 00    	je     f0101ff8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0101bb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bb4:	89 04 24             	mov    %eax,(%esp)
f0101bb7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101bb9:	83 c7 01             	add    $0x1,%edi
f0101bbc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101bc0:	83 f8 25             	cmp    $0x25,%eax
f0101bc3:	75 e3                	jne    f0101ba8 <vprintfmt+0x14>
f0101bc5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101bc9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101bd0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101bd7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101bde:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101be3:	eb 1f                	jmp    f0101c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101be8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101bec:	eb 16                	jmp    f0101c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101bf1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101bf5:	eb 0d                	jmp    f0101c04 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101bf7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101bfd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c04:	8d 47 01             	lea    0x1(%edi),%eax
f0101c07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101c0a:	0f b6 17             	movzbl (%edi),%edx
f0101c0d:	0f b6 c2             	movzbl %dl,%eax
f0101c10:	83 ea 23             	sub    $0x23,%edx
f0101c13:	80 fa 55             	cmp    $0x55,%dl
f0101c16:	0f 87 bf 03 00 00    	ja     f0101fdb <vprintfmt+0x447>
f0101c1c:	0f b6 d2             	movzbl %dl,%edx
f0101c1f:	ff 24 95 e0 30 10 f0 	jmp    *-0xfefcf20(,%edx,4)
f0101c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101c29:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c2e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101c31:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101c34:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101c38:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0101c3b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0101c3e:	83 f9 09             	cmp    $0x9,%ecx
f0101c41:	77 3c                	ja     f0101c7f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101c43:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101c46:	eb e9                	jmp    f0101c31 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101c48:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c4b:	8b 00                	mov    (%eax),%eax
f0101c4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c50:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c53:	8d 40 04             	lea    0x4(%eax),%eax
f0101c56:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101c5c:	eb 27                	jmp    f0101c85 <vprintfmt+0xf1>
f0101c5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101c61:	85 d2                	test   %edx,%edx
f0101c63:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c68:	0f 49 c2             	cmovns %edx,%eax
f0101c6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101c71:	eb 91                	jmp    f0101c04 <vprintfmt+0x70>
f0101c73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101c76:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101c7d:	eb 85                	jmp    f0101c04 <vprintfmt+0x70>
f0101c7f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c82:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101c85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101c89:	0f 89 75 ff ff ff    	jns    f0101c04 <vprintfmt+0x70>
f0101c8f:	e9 63 ff ff ff       	jmp    f0101bf7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101c94:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101c9a:	e9 65 ff ff ff       	jmp    f0101c04 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c9f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101ca2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101caa:	8b 00                	mov    (%eax),%eax
f0101cac:	89 04 24             	mov    %eax,(%esp)
f0101caf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101cb4:	e9 00 ff ff ff       	jmp    f0101bb9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cb9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101cbc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101cc0:	8b 00                	mov    (%eax),%eax
f0101cc2:	99                   	cltd   
f0101cc3:	31 d0                	xor    %edx,%eax
f0101cc5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101cc7:	83 f8 07             	cmp    $0x7,%eax
f0101cca:	7f 0b                	jg     f0101cd7 <vprintfmt+0x143>
f0101ccc:	8b 14 85 40 32 10 f0 	mov    -0xfefcdc0(,%eax,4),%edx
f0101cd3:	85 d2                	test   %edx,%edx
f0101cd5:	75 20                	jne    f0101cf7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0101cd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cdb:	c7 44 24 08 53 30 10 	movl   $0xf0103053,0x8(%esp)
f0101ce2:	f0 
f0101ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ce7:	89 34 24             	mov    %esi,(%esp)
f0101cea:	e8 7d fe ff ff       	call   f0101b6c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101cf2:	e9 c2 fe ff ff       	jmp    f0101bb9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0101cf7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cfb:	c7 44 24 08 80 2e 10 	movl   $0xf0102e80,0x8(%esp)
f0101d02:	f0 
f0101d03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d07:	89 34 24             	mov    %esi,(%esp)
f0101d0a:	e8 5d fe ff ff       	call   f0101b6c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101d12:	e9 a2 fe ff ff       	jmp    f0101bb9 <vprintfmt+0x25>
f0101d17:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d1a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101d1d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101d20:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101d23:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0101d27:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101d29:	85 ff                	test   %edi,%edi
f0101d2b:	b8 4c 30 10 f0       	mov    $0xf010304c,%eax
f0101d30:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101d33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101d37:	0f 84 92 00 00 00    	je     f0101dcf <vprintfmt+0x23b>
f0101d3d:	85 c9                	test   %ecx,%ecx
f0101d3f:	0f 8e 98 00 00 00    	jle    f0101ddd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d49:	89 3c 24             	mov    %edi,(%esp)
f0101d4c:	e8 17 04 00 00       	call   f0102168 <strnlen>
f0101d51:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101d54:	29 c1                	sub    %eax,%ecx
f0101d56:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0101d59:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101d5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101d60:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101d63:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d65:	eb 0f                	jmp    f0101d76 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0101d67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101d6e:	89 04 24             	mov    %eax,(%esp)
f0101d71:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d73:	83 ef 01             	sub    $0x1,%edi
f0101d76:	85 ff                	test   %edi,%edi
f0101d78:	7f ed                	jg     f0101d67 <vprintfmt+0x1d3>
f0101d7a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101d7d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101d80:	85 c9                	test   %ecx,%ecx
f0101d82:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d87:	0f 49 c1             	cmovns %ecx,%eax
f0101d8a:	29 c1                	sub    %eax,%ecx
f0101d8c:	89 75 08             	mov    %esi,0x8(%ebp)
f0101d8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101d92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101d95:	89 cb                	mov    %ecx,%ebx
f0101d97:	eb 50                	jmp    f0101de9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101d99:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101d9d:	74 1e                	je     f0101dbd <vprintfmt+0x229>
f0101d9f:	0f be d2             	movsbl %dl,%edx
f0101da2:	83 ea 20             	sub    $0x20,%edx
f0101da5:	83 fa 5e             	cmp    $0x5e,%edx
f0101da8:	76 13                	jbe    f0101dbd <vprintfmt+0x229>
					putch('?', putdat);
f0101daa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101dad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101db1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101db8:	ff 55 08             	call   *0x8(%ebp)
f0101dbb:	eb 0d                	jmp    f0101dca <vprintfmt+0x236>
				else
					putch(ch, putdat);
f0101dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101dc0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101dc4:	89 04 24             	mov    %eax,(%esp)
f0101dc7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101dca:	83 eb 01             	sub    $0x1,%ebx
f0101dcd:	eb 1a                	jmp    f0101de9 <vprintfmt+0x255>
f0101dcf:	89 75 08             	mov    %esi,0x8(%ebp)
f0101dd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101dd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101dd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101ddb:	eb 0c                	jmp    f0101de9 <vprintfmt+0x255>
f0101ddd:	89 75 08             	mov    %esi,0x8(%ebp)
f0101de0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101de3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101de6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101de9:	83 c7 01             	add    $0x1,%edi
f0101dec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101df0:	0f be c2             	movsbl %dl,%eax
f0101df3:	85 c0                	test   %eax,%eax
f0101df5:	74 25                	je     f0101e1c <vprintfmt+0x288>
f0101df7:	85 f6                	test   %esi,%esi
f0101df9:	78 9e                	js     f0101d99 <vprintfmt+0x205>
f0101dfb:	83 ee 01             	sub    $0x1,%esi
f0101dfe:	79 99                	jns    f0101d99 <vprintfmt+0x205>
f0101e00:	89 df                	mov    %ebx,%edi
f0101e02:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101e08:	eb 1a                	jmp    f0101e24 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101e0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e0e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101e15:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101e17:	83 ef 01             	sub    $0x1,%edi
f0101e1a:	eb 08                	jmp    f0101e24 <vprintfmt+0x290>
f0101e1c:	89 df                	mov    %ebx,%edi
f0101e1e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101e24:	85 ff                	test   %edi,%edi
f0101e26:	7f e2                	jg     f0101e0a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101e2b:	e9 89 fd ff ff       	jmp    f0101bb9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101e30:	83 f9 01             	cmp    $0x1,%ecx
f0101e33:	7e 19                	jle    f0101e4e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0101e35:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e38:	8b 50 04             	mov    0x4(%eax),%edx
f0101e3b:	8b 00                	mov    (%eax),%eax
f0101e3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e40:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101e43:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e46:	8d 40 08             	lea    0x8(%eax),%eax
f0101e49:	89 45 14             	mov    %eax,0x14(%ebp)
f0101e4c:	eb 38                	jmp    f0101e86 <vprintfmt+0x2f2>
	else if (lflag)
f0101e4e:	85 c9                	test   %ecx,%ecx
f0101e50:	74 1b                	je     f0101e6d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0101e52:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e55:	8b 00                	mov    (%eax),%eax
f0101e57:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e5a:	89 c1                	mov    %eax,%ecx
f0101e5c:	c1 f9 1f             	sar    $0x1f,%ecx
f0101e5f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101e62:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e65:	8d 40 04             	lea    0x4(%eax),%eax
f0101e68:	89 45 14             	mov    %eax,0x14(%ebp)
f0101e6b:	eb 19                	jmp    f0101e86 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f0101e6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e70:	8b 00                	mov    (%eax),%eax
f0101e72:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e75:	89 c1                	mov    %eax,%ecx
f0101e77:	c1 f9 1f             	sar    $0x1f,%ecx
f0101e7a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101e7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e80:	8d 40 04             	lea    0x4(%eax),%eax
f0101e83:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101e86:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101e89:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101e8c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101e91:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101e95:	0f 89 04 01 00 00    	jns    f0101f9f <vprintfmt+0x40b>
				putch('-', putdat);
f0101e9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e9f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101ea6:	ff d6                	call   *%esi
				num = -(long long) num;
f0101ea8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101eab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101eae:	f7 da                	neg    %edx
f0101eb0:	83 d1 00             	adc    $0x0,%ecx
f0101eb3:	f7 d9                	neg    %ecx
f0101eb5:	e9 e5 00 00 00       	jmp    f0101f9f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101eba:	83 f9 01             	cmp    $0x1,%ecx
f0101ebd:	7e 10                	jle    f0101ecf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f0101ebf:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ec2:	8b 10                	mov    (%eax),%edx
f0101ec4:	8b 48 04             	mov    0x4(%eax),%ecx
f0101ec7:	8d 40 08             	lea    0x8(%eax),%eax
f0101eca:	89 45 14             	mov    %eax,0x14(%ebp)
f0101ecd:	eb 26                	jmp    f0101ef5 <vprintfmt+0x361>
	else if (lflag)
f0101ecf:	85 c9                	test   %ecx,%ecx
f0101ed1:	74 12                	je     f0101ee5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0101ed3:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ed6:	8b 10                	mov    (%eax),%edx
f0101ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101edd:	8d 40 04             	lea    0x4(%eax),%eax
f0101ee0:	89 45 14             	mov    %eax,0x14(%ebp)
f0101ee3:	eb 10                	jmp    f0101ef5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0101ee5:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ee8:	8b 10                	mov    (%eax),%edx
f0101eea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101eef:	8d 40 04             	lea    0x4(%eax),%eax
f0101ef2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101ef5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0101efa:	e9 a0 00 00 00       	jmp    f0101f9f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f03:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101f0a:	ff d6                	call   *%esi
			putch('X', putdat);
f0101f0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f10:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101f17:	ff d6                	call   *%esi
			putch('X', putdat);
f0101f19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f1d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101f24:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101f29:	e9 8b fc ff ff       	jmp    f0101bb9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f0101f2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101f39:	ff d6                	call   *%esi
			putch('x', putdat);
f0101f3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f3f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101f46:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101f48:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f4b:	8b 10                	mov    (%eax),%edx
f0101f4d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0101f52:	8d 40 04             	lea    0x4(%eax),%eax
f0101f55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101f58:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f0101f5d:	eb 40                	jmp    f0101f9f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101f5f:	83 f9 01             	cmp    $0x1,%ecx
f0101f62:	7e 10                	jle    f0101f74 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0101f64:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f67:	8b 10                	mov    (%eax),%edx
f0101f69:	8b 48 04             	mov    0x4(%eax),%ecx
f0101f6c:	8d 40 08             	lea    0x8(%eax),%eax
f0101f6f:	89 45 14             	mov    %eax,0x14(%ebp)
f0101f72:	eb 26                	jmp    f0101f9a <vprintfmt+0x406>
	else if (lflag)
f0101f74:	85 c9                	test   %ecx,%ecx
f0101f76:	74 12                	je     f0101f8a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0101f78:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f7b:	8b 10                	mov    (%eax),%edx
f0101f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101f82:	8d 40 04             	lea    0x4(%eax),%eax
f0101f85:	89 45 14             	mov    %eax,0x14(%ebp)
f0101f88:	eb 10                	jmp    f0101f9a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f0101f8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f8d:	8b 10                	mov    (%eax),%edx
f0101f8f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101f94:	8d 40 04             	lea    0x4(%eax),%eax
f0101f97:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0101f9a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101f9f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101fa3:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101fa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101faa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101fb2:	89 14 24             	mov    %edx,(%esp)
f0101fb5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101fb9:	89 da                	mov    %ebx,%edx
f0101fbb:	89 f0                	mov    %esi,%eax
f0101fbd:	e8 9e fa ff ff       	call   f0101a60 <printnum>
			break;
f0101fc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101fc5:	e9 ef fb ff ff       	jmp    f0101bb9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101fca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fce:	89 04 24             	mov    %eax,(%esp)
f0101fd1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101fd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101fd6:	e9 de fb ff ff       	jmp    f0101bb9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101fdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fdf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101fe6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101fe8:	eb 03                	jmp    f0101fed <vprintfmt+0x459>
f0101fea:	83 ef 01             	sub    $0x1,%edi
f0101fed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101ff1:	75 f7                	jne    f0101fea <vprintfmt+0x456>
f0101ff3:	e9 c1 fb ff ff       	jmp    f0101bb9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101ff8:	83 c4 3c             	add    $0x3c,%esp
f0101ffb:	5b                   	pop    %ebx
f0101ffc:	5e                   	pop    %esi
f0101ffd:	5f                   	pop    %edi
f0101ffe:	5d                   	pop    %ebp
f0101fff:	c3                   	ret    

f0102000 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102000:	55                   	push   %ebp
f0102001:	89 e5                	mov    %esp,%ebp
f0102003:	83 ec 28             	sub    $0x28,%esp
f0102006:	8b 45 08             	mov    0x8(%ebp),%eax
f0102009:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010200c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010200f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102013:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102016:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010201d:	85 c0                	test   %eax,%eax
f010201f:	74 30                	je     f0102051 <vsnprintf+0x51>
f0102021:	85 d2                	test   %edx,%edx
f0102023:	7e 2c                	jle    f0102051 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102025:	8b 45 14             	mov    0x14(%ebp),%eax
f0102028:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010202c:	8b 45 10             	mov    0x10(%ebp),%eax
f010202f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102033:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102036:	89 44 24 04          	mov    %eax,0x4(%esp)
f010203a:	c7 04 24 4f 1b 10 f0 	movl   $0xf0101b4f,(%esp)
f0102041:	e8 4e fb ff ff       	call   f0101b94 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102046:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102049:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010204c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010204f:	eb 05                	jmp    f0102056 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102051:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102056:	c9                   	leave  
f0102057:	c3                   	ret    

f0102058 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102058:	55                   	push   %ebp
f0102059:	89 e5                	mov    %esp,%ebp
f010205b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010205e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102061:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102065:	8b 45 10             	mov    0x10(%ebp),%eax
f0102068:	89 44 24 08          	mov    %eax,0x8(%esp)
f010206c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010206f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102073:	8b 45 08             	mov    0x8(%ebp),%eax
f0102076:	89 04 24             	mov    %eax,(%esp)
f0102079:	e8 82 ff ff ff       	call   f0102000 <vsnprintf>
	va_end(ap);

	return rc;
}
f010207e:	c9                   	leave  
f010207f:	c3                   	ret    

f0102080 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102080:	55                   	push   %ebp
f0102081:	89 e5                	mov    %esp,%ebp
f0102083:	57                   	push   %edi
f0102084:	56                   	push   %esi
f0102085:	53                   	push   %ebx
f0102086:	83 ec 1c             	sub    $0x1c,%esp
f0102089:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010208c:	85 c0                	test   %eax,%eax
f010208e:	74 10                	je     f01020a0 <readline+0x20>
		cprintf("%s", prompt);
f0102090:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102094:	c7 04 24 80 2e 10 f0 	movl   $0xf0102e80,(%esp)
f010209b:	e8 e8 f6 ff ff       	call   f0101788 <cprintf>

	i = 0;
	echoing = iscons(0);
f01020a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a7:	e8 66 e5 ff ff       	call   f0100612 <iscons>
f01020ac:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01020ae:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01020b3:	e8 49 e5 ff ff       	call   f0100601 <getchar>
f01020b8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01020ba:	85 c0                	test   %eax,%eax
f01020bc:	79 17                	jns    f01020d5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01020be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01020c2:	c7 04 24 60 32 10 f0 	movl   $0xf0103260,(%esp)
f01020c9:	e8 ba f6 ff ff       	call   f0101788 <cprintf>
			return NULL;
f01020ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01020d3:	eb 6d                	jmp    f0102142 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01020d5:	83 f8 7f             	cmp    $0x7f,%eax
f01020d8:	74 05                	je     f01020df <readline+0x5f>
f01020da:	83 f8 08             	cmp    $0x8,%eax
f01020dd:	75 19                	jne    f01020f8 <readline+0x78>
f01020df:	85 f6                	test   %esi,%esi
f01020e1:	7e 15                	jle    f01020f8 <readline+0x78>
			if (echoing)
f01020e3:	85 ff                	test   %edi,%edi
f01020e5:	74 0c                	je     f01020f3 <readline+0x73>
				cputchar('\b');
f01020e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01020ee:	e8 fe e4 ff ff       	call   f01005f1 <cputchar>
			i--;
f01020f3:	83 ee 01             	sub    $0x1,%esi
f01020f6:	eb bb                	jmp    f01020b3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01020f8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01020fe:	7f 1c                	jg     f010211c <readline+0x9c>
f0102100:	83 fb 1f             	cmp    $0x1f,%ebx
f0102103:	7e 17                	jle    f010211c <readline+0x9c>
			if (echoing)
f0102105:	85 ff                	test   %edi,%edi
f0102107:	74 08                	je     f0102111 <readline+0x91>
				cputchar(c);
f0102109:	89 1c 24             	mov    %ebx,(%esp)
f010210c:	e8 e0 e4 ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0102111:	88 9e 60 45 11 f0    	mov    %bl,-0xfeebaa0(%esi)
f0102117:	8d 76 01             	lea    0x1(%esi),%esi
f010211a:	eb 97                	jmp    f01020b3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010211c:	83 fb 0d             	cmp    $0xd,%ebx
f010211f:	74 05                	je     f0102126 <readline+0xa6>
f0102121:	83 fb 0a             	cmp    $0xa,%ebx
f0102124:	75 8d                	jne    f01020b3 <readline+0x33>
			if (echoing)
f0102126:	85 ff                	test   %edi,%edi
f0102128:	74 0c                	je     f0102136 <readline+0xb6>
				cputchar('\n');
f010212a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0102131:	e8 bb e4 ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0102136:	c6 86 60 45 11 f0 00 	movb   $0x0,-0xfeebaa0(%esi)
			return buf;
f010213d:	b8 60 45 11 f0       	mov    $0xf0114560,%eax
		}
	}
}
f0102142:	83 c4 1c             	add    $0x1c,%esp
f0102145:	5b                   	pop    %ebx
f0102146:	5e                   	pop    %esi
f0102147:	5f                   	pop    %edi
f0102148:	5d                   	pop    %ebp
f0102149:	c3                   	ret    
f010214a:	66 90                	xchg   %ax,%ax
f010214c:	66 90                	xchg   %ax,%ax
f010214e:	66 90                	xchg   %ax,%ax

f0102150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102150:	55                   	push   %ebp
f0102151:	89 e5                	mov    %esp,%ebp
f0102153:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102156:	b8 00 00 00 00       	mov    $0x0,%eax
f010215b:	eb 03                	jmp    f0102160 <strlen+0x10>
		n++;
f010215d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102160:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102164:	75 f7                	jne    f010215d <strlen+0xd>
		n++;
	return n;
}
f0102166:	5d                   	pop    %ebp
f0102167:	c3                   	ret    

f0102168 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102168:	55                   	push   %ebp
f0102169:	89 e5                	mov    %esp,%ebp
f010216b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010216e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102171:	b8 00 00 00 00       	mov    $0x0,%eax
f0102176:	eb 03                	jmp    f010217b <strnlen+0x13>
		n++;
f0102178:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010217b:	39 d0                	cmp    %edx,%eax
f010217d:	74 06                	je     f0102185 <strnlen+0x1d>
f010217f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0102183:	75 f3                	jne    f0102178 <strnlen+0x10>
		n++;
	return n;
}
f0102185:	5d                   	pop    %ebp
f0102186:	c3                   	ret    

f0102187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102187:	55                   	push   %ebp
f0102188:	89 e5                	mov    %esp,%ebp
f010218a:	53                   	push   %ebx
f010218b:	8b 45 08             	mov    0x8(%ebp),%eax
f010218e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102191:	89 c2                	mov    %eax,%edx
f0102193:	83 c2 01             	add    $0x1,%edx
f0102196:	83 c1 01             	add    $0x1,%ecx
f0102199:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010219d:	88 5a ff             	mov    %bl,-0x1(%edx)
f01021a0:	84 db                	test   %bl,%bl
f01021a2:	75 ef                	jne    f0102193 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01021a4:	5b                   	pop    %ebx
f01021a5:	5d                   	pop    %ebp
f01021a6:	c3                   	ret    

f01021a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01021a7:	55                   	push   %ebp
f01021a8:	89 e5                	mov    %esp,%ebp
f01021aa:	53                   	push   %ebx
f01021ab:	83 ec 08             	sub    $0x8,%esp
f01021ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01021b1:	89 1c 24             	mov    %ebx,(%esp)
f01021b4:	e8 97 ff ff ff       	call   f0102150 <strlen>
	strcpy(dst + len, src);
f01021b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01021bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01021c0:	01 d8                	add    %ebx,%eax
f01021c2:	89 04 24             	mov    %eax,(%esp)
f01021c5:	e8 bd ff ff ff       	call   f0102187 <strcpy>
	return dst;
}
f01021ca:	89 d8                	mov    %ebx,%eax
f01021cc:	83 c4 08             	add    $0x8,%esp
f01021cf:	5b                   	pop    %ebx
f01021d0:	5d                   	pop    %ebp
f01021d1:	c3                   	ret    

f01021d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01021d2:	55                   	push   %ebp
f01021d3:	89 e5                	mov    %esp,%ebp
f01021d5:	56                   	push   %esi
f01021d6:	53                   	push   %ebx
f01021d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01021da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01021dd:	89 f3                	mov    %esi,%ebx
f01021df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01021e2:	89 f2                	mov    %esi,%edx
f01021e4:	eb 0f                	jmp    f01021f5 <strncpy+0x23>
		*dst++ = *src;
f01021e6:	83 c2 01             	add    $0x1,%edx
f01021e9:	0f b6 01             	movzbl (%ecx),%eax
f01021ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01021ef:	80 39 01             	cmpb   $0x1,(%ecx)
f01021f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01021f5:	39 da                	cmp    %ebx,%edx
f01021f7:	75 ed                	jne    f01021e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01021f9:	89 f0                	mov    %esi,%eax
f01021fb:	5b                   	pop    %ebx
f01021fc:	5e                   	pop    %esi
f01021fd:	5d                   	pop    %ebp
f01021fe:	c3                   	ret    

f01021ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01021ff:	55                   	push   %ebp
f0102200:	89 e5                	mov    %esp,%ebp
f0102202:	56                   	push   %esi
f0102203:	53                   	push   %ebx
f0102204:	8b 75 08             	mov    0x8(%ebp),%esi
f0102207:	8b 55 0c             	mov    0xc(%ebp),%edx
f010220a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010220d:	89 f0                	mov    %esi,%eax
f010220f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102213:	85 c9                	test   %ecx,%ecx
f0102215:	75 0b                	jne    f0102222 <strlcpy+0x23>
f0102217:	eb 1d                	jmp    f0102236 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102219:	83 c0 01             	add    $0x1,%eax
f010221c:	83 c2 01             	add    $0x1,%edx
f010221f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102222:	39 d8                	cmp    %ebx,%eax
f0102224:	74 0b                	je     f0102231 <strlcpy+0x32>
f0102226:	0f b6 0a             	movzbl (%edx),%ecx
f0102229:	84 c9                	test   %cl,%cl
f010222b:	75 ec                	jne    f0102219 <strlcpy+0x1a>
f010222d:	89 c2                	mov    %eax,%edx
f010222f:	eb 02                	jmp    f0102233 <strlcpy+0x34>
f0102231:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0102233:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0102236:	29 f0                	sub    %esi,%eax
}
f0102238:	5b                   	pop    %ebx
f0102239:	5e                   	pop    %esi
f010223a:	5d                   	pop    %ebp
f010223b:	c3                   	ret    

f010223c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010223c:	55                   	push   %ebp
f010223d:	89 e5                	mov    %esp,%ebp
f010223f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102242:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0102245:	eb 06                	jmp    f010224d <strcmp+0x11>
		p++, q++;
f0102247:	83 c1 01             	add    $0x1,%ecx
f010224a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010224d:	0f b6 01             	movzbl (%ecx),%eax
f0102250:	84 c0                	test   %al,%al
f0102252:	74 04                	je     f0102258 <strcmp+0x1c>
f0102254:	3a 02                	cmp    (%edx),%al
f0102256:	74 ef                	je     f0102247 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0102258:	0f b6 c0             	movzbl %al,%eax
f010225b:	0f b6 12             	movzbl (%edx),%edx
f010225e:	29 d0                	sub    %edx,%eax
}
f0102260:	5d                   	pop    %ebp
f0102261:	c3                   	ret    

f0102262 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102262:	55                   	push   %ebp
f0102263:	89 e5                	mov    %esp,%ebp
f0102265:	53                   	push   %ebx
f0102266:	8b 45 08             	mov    0x8(%ebp),%eax
f0102269:	8b 55 0c             	mov    0xc(%ebp),%edx
f010226c:	89 c3                	mov    %eax,%ebx
f010226e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0102271:	eb 06                	jmp    f0102279 <strncmp+0x17>
		n--, p++, q++;
f0102273:	83 c0 01             	add    $0x1,%eax
f0102276:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102279:	39 d8                	cmp    %ebx,%eax
f010227b:	74 15                	je     f0102292 <strncmp+0x30>
f010227d:	0f b6 08             	movzbl (%eax),%ecx
f0102280:	84 c9                	test   %cl,%cl
f0102282:	74 04                	je     f0102288 <strncmp+0x26>
f0102284:	3a 0a                	cmp    (%edx),%cl
f0102286:	74 eb                	je     f0102273 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102288:	0f b6 00             	movzbl (%eax),%eax
f010228b:	0f b6 12             	movzbl (%edx),%edx
f010228e:	29 d0                	sub    %edx,%eax
f0102290:	eb 05                	jmp    f0102297 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102292:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102297:	5b                   	pop    %ebx
f0102298:	5d                   	pop    %ebp
f0102299:	c3                   	ret    

f010229a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010229a:	55                   	push   %ebp
f010229b:	89 e5                	mov    %esp,%ebp
f010229d:	8b 45 08             	mov    0x8(%ebp),%eax
f01022a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01022a4:	eb 07                	jmp    f01022ad <strchr+0x13>
		if (*s == c)
f01022a6:	38 ca                	cmp    %cl,%dl
f01022a8:	74 0f                	je     f01022b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01022aa:	83 c0 01             	add    $0x1,%eax
f01022ad:	0f b6 10             	movzbl (%eax),%edx
f01022b0:	84 d2                	test   %dl,%dl
f01022b2:	75 f2                	jne    f01022a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01022b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01022b9:	5d                   	pop    %ebp
f01022ba:	c3                   	ret    

f01022bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01022bb:	55                   	push   %ebp
f01022bc:	89 e5                	mov    %esp,%ebp
f01022be:	8b 45 08             	mov    0x8(%ebp),%eax
f01022c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01022c5:	eb 07                	jmp    f01022ce <strfind+0x13>
		if (*s == c)
f01022c7:	38 ca                	cmp    %cl,%dl
f01022c9:	74 0a                	je     f01022d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01022cb:	83 c0 01             	add    $0x1,%eax
f01022ce:	0f b6 10             	movzbl (%eax),%edx
f01022d1:	84 d2                	test   %dl,%dl
f01022d3:	75 f2                	jne    f01022c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01022d5:	5d                   	pop    %ebp
f01022d6:	c3                   	ret    

f01022d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01022d7:	55                   	push   %ebp
f01022d8:	89 e5                	mov    %esp,%ebp
f01022da:	57                   	push   %edi
f01022db:	56                   	push   %esi
f01022dc:	53                   	push   %ebx
f01022dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01022e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01022e3:	85 c9                	test   %ecx,%ecx
f01022e5:	74 36                	je     f010231d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01022e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01022ed:	75 28                	jne    f0102317 <memset+0x40>
f01022ef:	f6 c1 03             	test   $0x3,%cl
f01022f2:	75 23                	jne    f0102317 <memset+0x40>
		c &= 0xFF;
f01022f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01022f8:	89 d3                	mov    %edx,%ebx
f01022fa:	c1 e3 08             	shl    $0x8,%ebx
f01022fd:	89 d6                	mov    %edx,%esi
f01022ff:	c1 e6 18             	shl    $0x18,%esi
f0102302:	89 d0                	mov    %edx,%eax
f0102304:	c1 e0 10             	shl    $0x10,%eax
f0102307:	09 f0                	or     %esi,%eax
f0102309:	09 c2                	or     %eax,%edx
f010230b:	89 d0                	mov    %edx,%eax
f010230d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010230f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102312:	fc                   	cld    
f0102313:	f3 ab                	rep stos %eax,%es:(%edi)
f0102315:	eb 06                	jmp    f010231d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102317:	8b 45 0c             	mov    0xc(%ebp),%eax
f010231a:	fc                   	cld    
f010231b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010231d:	89 f8                	mov    %edi,%eax
f010231f:	5b                   	pop    %ebx
f0102320:	5e                   	pop    %esi
f0102321:	5f                   	pop    %edi
f0102322:	5d                   	pop    %ebp
f0102323:	c3                   	ret    

f0102324 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102324:	55                   	push   %ebp
f0102325:	89 e5                	mov    %esp,%ebp
f0102327:	57                   	push   %edi
f0102328:	56                   	push   %esi
f0102329:	8b 45 08             	mov    0x8(%ebp),%eax
f010232c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010232f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102332:	39 c6                	cmp    %eax,%esi
f0102334:	73 35                	jae    f010236b <memmove+0x47>
f0102336:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102339:	39 d0                	cmp    %edx,%eax
f010233b:	73 2e                	jae    f010236b <memmove+0x47>
		s += n;
		d += n;
f010233d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0102340:	89 d6                	mov    %edx,%esi
f0102342:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102344:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010234a:	75 13                	jne    f010235f <memmove+0x3b>
f010234c:	f6 c1 03             	test   $0x3,%cl
f010234f:	75 0e                	jne    f010235f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102351:	83 ef 04             	sub    $0x4,%edi
f0102354:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102357:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010235a:	fd                   	std    
f010235b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010235d:	eb 09                	jmp    f0102368 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010235f:	83 ef 01             	sub    $0x1,%edi
f0102362:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102365:	fd                   	std    
f0102366:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102368:	fc                   	cld    
f0102369:	eb 1d                	jmp    f0102388 <memmove+0x64>
f010236b:	89 f2                	mov    %esi,%edx
f010236d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010236f:	f6 c2 03             	test   $0x3,%dl
f0102372:	75 0f                	jne    f0102383 <memmove+0x5f>
f0102374:	f6 c1 03             	test   $0x3,%cl
f0102377:	75 0a                	jne    f0102383 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0102379:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010237c:	89 c7                	mov    %eax,%edi
f010237e:	fc                   	cld    
f010237f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102381:	eb 05                	jmp    f0102388 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102383:	89 c7                	mov    %eax,%edi
f0102385:	fc                   	cld    
f0102386:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0102388:	5e                   	pop    %esi
f0102389:	5f                   	pop    %edi
f010238a:	5d                   	pop    %ebp
f010238b:	c3                   	ret    

f010238c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010238c:	55                   	push   %ebp
f010238d:	89 e5                	mov    %esp,%ebp
f010238f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102392:	8b 45 10             	mov    0x10(%ebp),%eax
f0102395:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102399:	8b 45 0c             	mov    0xc(%ebp),%eax
f010239c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01023a3:	89 04 24             	mov    %eax,(%esp)
f01023a6:	e8 79 ff ff ff       	call   f0102324 <memmove>
}
f01023ab:	c9                   	leave  
f01023ac:	c3                   	ret    

f01023ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01023ad:	55                   	push   %ebp
f01023ae:	89 e5                	mov    %esp,%ebp
f01023b0:	56                   	push   %esi
f01023b1:	53                   	push   %ebx
f01023b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01023b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01023b8:	89 d6                	mov    %edx,%esi
f01023ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01023bd:	eb 1a                	jmp    f01023d9 <memcmp+0x2c>
		if (*s1 != *s2)
f01023bf:	0f b6 02             	movzbl (%edx),%eax
f01023c2:	0f b6 19             	movzbl (%ecx),%ebx
f01023c5:	38 d8                	cmp    %bl,%al
f01023c7:	74 0a                	je     f01023d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01023c9:	0f b6 c0             	movzbl %al,%eax
f01023cc:	0f b6 db             	movzbl %bl,%ebx
f01023cf:	29 d8                	sub    %ebx,%eax
f01023d1:	eb 0f                	jmp    f01023e2 <memcmp+0x35>
		s1++, s2++;
f01023d3:	83 c2 01             	add    $0x1,%edx
f01023d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01023d9:	39 f2                	cmp    %esi,%edx
f01023db:	75 e2                	jne    f01023bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01023dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01023e2:	5b                   	pop    %ebx
f01023e3:	5e                   	pop    %esi
f01023e4:	5d                   	pop    %ebp
f01023e5:	c3                   	ret    

f01023e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01023e6:	55                   	push   %ebp
f01023e7:	89 e5                	mov    %esp,%ebp
f01023e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01023ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01023ef:	89 c2                	mov    %eax,%edx
f01023f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01023f4:	eb 07                	jmp    f01023fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01023f6:	38 08                	cmp    %cl,(%eax)
f01023f8:	74 07                	je     f0102401 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01023fa:	83 c0 01             	add    $0x1,%eax
f01023fd:	39 d0                	cmp    %edx,%eax
f01023ff:	72 f5                	jb     f01023f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102401:	5d                   	pop    %ebp
f0102402:	c3                   	ret    

f0102403 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102403:	55                   	push   %ebp
f0102404:	89 e5                	mov    %esp,%ebp
f0102406:	57                   	push   %edi
f0102407:	56                   	push   %esi
f0102408:	53                   	push   %ebx
f0102409:	8b 55 08             	mov    0x8(%ebp),%edx
f010240c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010240f:	eb 03                	jmp    f0102414 <strtol+0x11>
		s++;
f0102411:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102414:	0f b6 0a             	movzbl (%edx),%ecx
f0102417:	80 f9 09             	cmp    $0x9,%cl
f010241a:	74 f5                	je     f0102411 <strtol+0xe>
f010241c:	80 f9 20             	cmp    $0x20,%cl
f010241f:	74 f0                	je     f0102411 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102421:	80 f9 2b             	cmp    $0x2b,%cl
f0102424:	75 0a                	jne    f0102430 <strtol+0x2d>
		s++;
f0102426:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102429:	bf 00 00 00 00       	mov    $0x0,%edi
f010242e:	eb 11                	jmp    f0102441 <strtol+0x3e>
f0102430:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102435:	80 f9 2d             	cmp    $0x2d,%cl
f0102438:	75 07                	jne    f0102441 <strtol+0x3e>
		s++, neg = 1;
f010243a:	8d 52 01             	lea    0x1(%edx),%edx
f010243d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102441:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0102446:	75 15                	jne    f010245d <strtol+0x5a>
f0102448:	80 3a 30             	cmpb   $0x30,(%edx)
f010244b:	75 10                	jne    f010245d <strtol+0x5a>
f010244d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102451:	75 0a                	jne    f010245d <strtol+0x5a>
		s += 2, base = 16;
f0102453:	83 c2 02             	add    $0x2,%edx
f0102456:	b8 10 00 00 00       	mov    $0x10,%eax
f010245b:	eb 10                	jmp    f010246d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010245d:	85 c0                	test   %eax,%eax
f010245f:	75 0c                	jne    f010246d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102461:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102463:	80 3a 30             	cmpb   $0x30,(%edx)
f0102466:	75 05                	jne    f010246d <strtol+0x6a>
		s++, base = 8;
f0102468:	83 c2 01             	add    $0x1,%edx
f010246b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010246d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102472:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102475:	0f b6 0a             	movzbl (%edx),%ecx
f0102478:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010247b:	89 f0                	mov    %esi,%eax
f010247d:	3c 09                	cmp    $0x9,%al
f010247f:	77 08                	ja     f0102489 <strtol+0x86>
			dig = *s - '0';
f0102481:	0f be c9             	movsbl %cl,%ecx
f0102484:	83 e9 30             	sub    $0x30,%ecx
f0102487:	eb 20                	jmp    f01024a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0102489:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010248c:	89 f0                	mov    %esi,%eax
f010248e:	3c 19                	cmp    $0x19,%al
f0102490:	77 08                	ja     f010249a <strtol+0x97>
			dig = *s - 'a' + 10;
f0102492:	0f be c9             	movsbl %cl,%ecx
f0102495:	83 e9 57             	sub    $0x57,%ecx
f0102498:	eb 0f                	jmp    f01024a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010249a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010249d:	89 f0                	mov    %esi,%eax
f010249f:	3c 19                	cmp    $0x19,%al
f01024a1:	77 16                	ja     f01024b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01024a3:	0f be c9             	movsbl %cl,%ecx
f01024a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01024a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01024ac:	7d 0f                	jge    f01024bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01024ae:	83 c2 01             	add    $0x1,%edx
f01024b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01024b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01024b7:	eb bc                	jmp    f0102475 <strtol+0x72>
f01024b9:	89 d8                	mov    %ebx,%eax
f01024bb:	eb 02                	jmp    f01024bf <strtol+0xbc>
f01024bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01024bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01024c3:	74 05                	je     f01024ca <strtol+0xc7>
		*endptr = (char *) s;
f01024c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01024c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01024ca:	f7 d8                	neg    %eax
f01024cc:	85 ff                	test   %edi,%edi
f01024ce:	0f 44 c3             	cmove  %ebx,%eax
}
f01024d1:	5b                   	pop    %ebx
f01024d2:	5e                   	pop    %esi
f01024d3:	5f                   	pop    %edi
f01024d4:	5d                   	pop    %ebp
f01024d5:	c3                   	ret    
f01024d6:	66 90                	xchg   %ax,%ax
f01024d8:	66 90                	xchg   %ax,%ax
f01024da:	66 90                	xchg   %ax,%ax
f01024dc:	66 90                	xchg   %ax,%ax
f01024de:	66 90                	xchg   %ax,%ax

f01024e0 <__udivdi3>:
f01024e0:	55                   	push   %ebp
f01024e1:	57                   	push   %edi
f01024e2:	56                   	push   %esi
f01024e3:	83 ec 0c             	sub    $0xc,%esp
f01024e6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01024ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01024ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01024f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01024f6:	85 c0                	test   %eax,%eax
f01024f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01024fc:	89 ea                	mov    %ebp,%edx
f01024fe:	89 0c 24             	mov    %ecx,(%esp)
f0102501:	75 2d                	jne    f0102530 <__udivdi3+0x50>
f0102503:	39 e9                	cmp    %ebp,%ecx
f0102505:	77 61                	ja     f0102568 <__udivdi3+0x88>
f0102507:	85 c9                	test   %ecx,%ecx
f0102509:	89 ce                	mov    %ecx,%esi
f010250b:	75 0b                	jne    f0102518 <__udivdi3+0x38>
f010250d:	b8 01 00 00 00       	mov    $0x1,%eax
f0102512:	31 d2                	xor    %edx,%edx
f0102514:	f7 f1                	div    %ecx
f0102516:	89 c6                	mov    %eax,%esi
f0102518:	31 d2                	xor    %edx,%edx
f010251a:	89 e8                	mov    %ebp,%eax
f010251c:	f7 f6                	div    %esi
f010251e:	89 c5                	mov    %eax,%ebp
f0102520:	89 f8                	mov    %edi,%eax
f0102522:	f7 f6                	div    %esi
f0102524:	89 ea                	mov    %ebp,%edx
f0102526:	83 c4 0c             	add    $0xc,%esp
f0102529:	5e                   	pop    %esi
f010252a:	5f                   	pop    %edi
f010252b:	5d                   	pop    %ebp
f010252c:	c3                   	ret    
f010252d:	8d 76 00             	lea    0x0(%esi),%esi
f0102530:	39 e8                	cmp    %ebp,%eax
f0102532:	77 24                	ja     f0102558 <__udivdi3+0x78>
f0102534:	0f bd e8             	bsr    %eax,%ebp
f0102537:	83 f5 1f             	xor    $0x1f,%ebp
f010253a:	75 3c                	jne    f0102578 <__udivdi3+0x98>
f010253c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102540:	39 34 24             	cmp    %esi,(%esp)
f0102543:	0f 86 9f 00 00 00    	jbe    f01025e8 <__udivdi3+0x108>
f0102549:	39 d0                	cmp    %edx,%eax
f010254b:	0f 82 97 00 00 00    	jb     f01025e8 <__udivdi3+0x108>
f0102551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102558:	31 d2                	xor    %edx,%edx
f010255a:	31 c0                	xor    %eax,%eax
f010255c:	83 c4 0c             	add    $0xc,%esp
f010255f:	5e                   	pop    %esi
f0102560:	5f                   	pop    %edi
f0102561:	5d                   	pop    %ebp
f0102562:	c3                   	ret    
f0102563:	90                   	nop
f0102564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102568:	89 f8                	mov    %edi,%eax
f010256a:	f7 f1                	div    %ecx
f010256c:	31 d2                	xor    %edx,%edx
f010256e:	83 c4 0c             	add    $0xc,%esp
f0102571:	5e                   	pop    %esi
f0102572:	5f                   	pop    %edi
f0102573:	5d                   	pop    %ebp
f0102574:	c3                   	ret    
f0102575:	8d 76 00             	lea    0x0(%esi),%esi
f0102578:	89 e9                	mov    %ebp,%ecx
f010257a:	8b 3c 24             	mov    (%esp),%edi
f010257d:	d3 e0                	shl    %cl,%eax
f010257f:	89 c6                	mov    %eax,%esi
f0102581:	b8 20 00 00 00       	mov    $0x20,%eax
f0102586:	29 e8                	sub    %ebp,%eax
f0102588:	89 c1                	mov    %eax,%ecx
f010258a:	d3 ef                	shr    %cl,%edi
f010258c:	89 e9                	mov    %ebp,%ecx
f010258e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102592:	8b 3c 24             	mov    (%esp),%edi
f0102595:	09 74 24 08          	or     %esi,0x8(%esp)
f0102599:	89 d6                	mov    %edx,%esi
f010259b:	d3 e7                	shl    %cl,%edi
f010259d:	89 c1                	mov    %eax,%ecx
f010259f:	89 3c 24             	mov    %edi,(%esp)
f01025a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01025a6:	d3 ee                	shr    %cl,%esi
f01025a8:	89 e9                	mov    %ebp,%ecx
f01025aa:	d3 e2                	shl    %cl,%edx
f01025ac:	89 c1                	mov    %eax,%ecx
f01025ae:	d3 ef                	shr    %cl,%edi
f01025b0:	09 d7                	or     %edx,%edi
f01025b2:	89 f2                	mov    %esi,%edx
f01025b4:	89 f8                	mov    %edi,%eax
f01025b6:	f7 74 24 08          	divl   0x8(%esp)
f01025ba:	89 d6                	mov    %edx,%esi
f01025bc:	89 c7                	mov    %eax,%edi
f01025be:	f7 24 24             	mull   (%esp)
f01025c1:	39 d6                	cmp    %edx,%esi
f01025c3:	89 14 24             	mov    %edx,(%esp)
f01025c6:	72 30                	jb     f01025f8 <__udivdi3+0x118>
f01025c8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01025cc:	89 e9                	mov    %ebp,%ecx
f01025ce:	d3 e2                	shl    %cl,%edx
f01025d0:	39 c2                	cmp    %eax,%edx
f01025d2:	73 05                	jae    f01025d9 <__udivdi3+0xf9>
f01025d4:	3b 34 24             	cmp    (%esp),%esi
f01025d7:	74 1f                	je     f01025f8 <__udivdi3+0x118>
f01025d9:	89 f8                	mov    %edi,%eax
f01025db:	31 d2                	xor    %edx,%edx
f01025dd:	e9 7a ff ff ff       	jmp    f010255c <__udivdi3+0x7c>
f01025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01025e8:	31 d2                	xor    %edx,%edx
f01025ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01025ef:	e9 68 ff ff ff       	jmp    f010255c <__udivdi3+0x7c>
f01025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01025f8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01025fb:	31 d2                	xor    %edx,%edx
f01025fd:	83 c4 0c             	add    $0xc,%esp
f0102600:	5e                   	pop    %esi
f0102601:	5f                   	pop    %edi
f0102602:	5d                   	pop    %ebp
f0102603:	c3                   	ret    
f0102604:	66 90                	xchg   %ax,%ax
f0102606:	66 90                	xchg   %ax,%ax
f0102608:	66 90                	xchg   %ax,%ax
f010260a:	66 90                	xchg   %ax,%ax
f010260c:	66 90                	xchg   %ax,%ax
f010260e:	66 90                	xchg   %ax,%ax

f0102610 <__umoddi3>:
f0102610:	55                   	push   %ebp
f0102611:	57                   	push   %edi
f0102612:	56                   	push   %esi
f0102613:	83 ec 14             	sub    $0x14,%esp
f0102616:	8b 44 24 28          	mov    0x28(%esp),%eax
f010261a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010261e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0102622:	89 c7                	mov    %eax,%edi
f0102624:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102628:	8b 44 24 30          	mov    0x30(%esp),%eax
f010262c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0102630:	89 34 24             	mov    %esi,(%esp)
f0102633:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102637:	85 c0                	test   %eax,%eax
f0102639:	89 c2                	mov    %eax,%edx
f010263b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010263f:	75 17                	jne    f0102658 <__umoddi3+0x48>
f0102641:	39 fe                	cmp    %edi,%esi
f0102643:	76 4b                	jbe    f0102690 <__umoddi3+0x80>
f0102645:	89 c8                	mov    %ecx,%eax
f0102647:	89 fa                	mov    %edi,%edx
f0102649:	f7 f6                	div    %esi
f010264b:	89 d0                	mov    %edx,%eax
f010264d:	31 d2                	xor    %edx,%edx
f010264f:	83 c4 14             	add    $0x14,%esp
f0102652:	5e                   	pop    %esi
f0102653:	5f                   	pop    %edi
f0102654:	5d                   	pop    %ebp
f0102655:	c3                   	ret    
f0102656:	66 90                	xchg   %ax,%ax
f0102658:	39 f8                	cmp    %edi,%eax
f010265a:	77 54                	ja     f01026b0 <__umoddi3+0xa0>
f010265c:	0f bd e8             	bsr    %eax,%ebp
f010265f:	83 f5 1f             	xor    $0x1f,%ebp
f0102662:	75 5c                	jne    f01026c0 <__umoddi3+0xb0>
f0102664:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0102668:	39 3c 24             	cmp    %edi,(%esp)
f010266b:	0f 87 e7 00 00 00    	ja     f0102758 <__umoddi3+0x148>
f0102671:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102675:	29 f1                	sub    %esi,%ecx
f0102677:	19 c7                	sbb    %eax,%edi
f0102679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010267d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102681:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102685:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0102689:	83 c4 14             	add    $0x14,%esp
f010268c:	5e                   	pop    %esi
f010268d:	5f                   	pop    %edi
f010268e:	5d                   	pop    %ebp
f010268f:	c3                   	ret    
f0102690:	85 f6                	test   %esi,%esi
f0102692:	89 f5                	mov    %esi,%ebp
f0102694:	75 0b                	jne    f01026a1 <__umoddi3+0x91>
f0102696:	b8 01 00 00 00       	mov    $0x1,%eax
f010269b:	31 d2                	xor    %edx,%edx
f010269d:	f7 f6                	div    %esi
f010269f:	89 c5                	mov    %eax,%ebp
f01026a1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01026a5:	31 d2                	xor    %edx,%edx
f01026a7:	f7 f5                	div    %ebp
f01026a9:	89 c8                	mov    %ecx,%eax
f01026ab:	f7 f5                	div    %ebp
f01026ad:	eb 9c                	jmp    f010264b <__umoddi3+0x3b>
f01026af:	90                   	nop
f01026b0:	89 c8                	mov    %ecx,%eax
f01026b2:	89 fa                	mov    %edi,%edx
f01026b4:	83 c4 14             	add    $0x14,%esp
f01026b7:	5e                   	pop    %esi
f01026b8:	5f                   	pop    %edi
f01026b9:	5d                   	pop    %ebp
f01026ba:	c3                   	ret    
f01026bb:	90                   	nop
f01026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01026c0:	8b 04 24             	mov    (%esp),%eax
f01026c3:	be 20 00 00 00       	mov    $0x20,%esi
f01026c8:	89 e9                	mov    %ebp,%ecx
f01026ca:	29 ee                	sub    %ebp,%esi
f01026cc:	d3 e2                	shl    %cl,%edx
f01026ce:	89 f1                	mov    %esi,%ecx
f01026d0:	d3 e8                	shr    %cl,%eax
f01026d2:	89 e9                	mov    %ebp,%ecx
f01026d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026d8:	8b 04 24             	mov    (%esp),%eax
f01026db:	09 54 24 04          	or     %edx,0x4(%esp)
f01026df:	89 fa                	mov    %edi,%edx
f01026e1:	d3 e0                	shl    %cl,%eax
f01026e3:	89 f1                	mov    %esi,%ecx
f01026e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01026e9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01026ed:	d3 ea                	shr    %cl,%edx
f01026ef:	89 e9                	mov    %ebp,%ecx
f01026f1:	d3 e7                	shl    %cl,%edi
f01026f3:	89 f1                	mov    %esi,%ecx
f01026f5:	d3 e8                	shr    %cl,%eax
f01026f7:	89 e9                	mov    %ebp,%ecx
f01026f9:	09 f8                	or     %edi,%eax
f01026fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01026ff:	f7 74 24 04          	divl   0x4(%esp)
f0102703:	d3 e7                	shl    %cl,%edi
f0102705:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102709:	89 d7                	mov    %edx,%edi
f010270b:	f7 64 24 08          	mull   0x8(%esp)
f010270f:	39 d7                	cmp    %edx,%edi
f0102711:	89 c1                	mov    %eax,%ecx
f0102713:	89 14 24             	mov    %edx,(%esp)
f0102716:	72 2c                	jb     f0102744 <__umoddi3+0x134>
f0102718:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010271c:	72 22                	jb     f0102740 <__umoddi3+0x130>
f010271e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102722:	29 c8                	sub    %ecx,%eax
f0102724:	19 d7                	sbb    %edx,%edi
f0102726:	89 e9                	mov    %ebp,%ecx
f0102728:	89 fa                	mov    %edi,%edx
f010272a:	d3 e8                	shr    %cl,%eax
f010272c:	89 f1                	mov    %esi,%ecx
f010272e:	d3 e2                	shl    %cl,%edx
f0102730:	89 e9                	mov    %ebp,%ecx
f0102732:	d3 ef                	shr    %cl,%edi
f0102734:	09 d0                	or     %edx,%eax
f0102736:	89 fa                	mov    %edi,%edx
f0102738:	83 c4 14             	add    $0x14,%esp
f010273b:	5e                   	pop    %esi
f010273c:	5f                   	pop    %edi
f010273d:	5d                   	pop    %ebp
f010273e:	c3                   	ret    
f010273f:	90                   	nop
f0102740:	39 d7                	cmp    %edx,%edi
f0102742:	75 da                	jne    f010271e <__umoddi3+0x10e>
f0102744:	8b 14 24             	mov    (%esp),%edx
f0102747:	89 c1                	mov    %eax,%ecx
f0102749:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010274d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0102751:	eb cb                	jmp    f010271e <__umoddi3+0x10e>
f0102753:	90                   	nop
f0102754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102758:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010275c:	0f 82 0f ff ff ff    	jb     f0102671 <__umoddi3+0x61>
f0102762:	e9 1a ff ff ff       	jmp    f0102681 <__umoddi3+0x71>
