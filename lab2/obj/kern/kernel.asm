
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
f0100063:	e8 bf 37 00 00       	call   f0103827 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 c0 3c 10 f0 	movl   $0xf0103cc0,(%esp)
f010007c:	e8 5f 2c 00 00       	call   f0102ce0 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 67 10 00 00       	call   f01010ed <mem_init>

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
f01000c1:	c7 04 24 db 3c 10 f0 	movl   $0xf0103cdb,(%esp)
f01000c8:	e8 13 2c 00 00       	call   f0102ce0 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 d4 2b 00 00       	call   f0102cad <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 d5 4b 10 f0 	movl   $0xf0104bd5,(%esp)
f01000e0:	e8 fb 2b 00 00       	call   f0102ce0 <cprintf>
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
f010010b:	c7 04 24 f3 3c 10 f0 	movl   $0xf0103cf3,(%esp)
f0100112:	e8 c9 2b 00 00       	call   f0102ce0 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 87 2b 00 00       	call   f0102cad <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 d5 4b 10 f0 	movl   $0xf0104bd5,(%esp)
f010012d:	e8 ae 2b 00 00       	call   f0102ce0 <cprintf>
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
f01001e5:	0f b6 82 60 3e 10 f0 	movzbl -0xfefc1a0(%edx),%eax
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
f0100222:	0f b6 82 60 3e 10 f0 	movzbl -0xfefc1a0(%edx),%eax
f0100229:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 40 3d 10 f0 	mov    -0xfefc2c0(,%ecx,4),%ecx
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
f0100282:	c7 04 24 0d 3d 10 f0 	movl   $0xf0103d0d,(%esp)
f0100289:	e8 52 2a 00 00       	call   f0102ce0 <cprintf>
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
f0100429:	e8 46 34 00 00       	call   f0103874 <memmove>
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
f01005dd:	c7 04 24 19 3d 10 f0 	movl   $0xf0103d19,(%esp)
f01005e4:	e8 f7 26 00 00       	call   f0102ce0 <cprintf>
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
f0100626:	c7 44 24 08 60 3f 10 	movl   $0xf0103f60,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 7e 3f 10 	movl   $0xf0103f7e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 83 3f 10 f0 	movl   $0xf0103f83,(%esp)
f010063d:	e8 9e 26 00 00       	call   f0102ce0 <cprintf>
f0100642:	c7 44 24 08 20 40 10 	movl   $0xf0104020,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 8c 3f 10 	movl   $0xf0103f8c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 83 3f 10 f0 	movl   $0xf0103f83,(%esp)
f0100659:	e8 82 26 00 00       	call   f0102ce0 <cprintf>
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
f010066b:	c7 04 24 95 3f 10 f0 	movl   $0xf0103f95,(%esp)
f0100672:	e8 69 26 00 00       	call   f0102ce0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 48 40 10 f0 	movl   $0xf0104048,(%esp)
f0100686:	e8 55 26 00 00       	call   f0102ce0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 70 40 10 f0 	movl   $0xf0104070,(%esp)
f01006a2:	e8 39 26 00 00       	call   f0102ce0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 b7 3c 10 	movl   $0x103cb7,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 b7 3c 10 	movl   $0xf0103cb7,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 94 40 10 f0 	movl   $0xf0104094,(%esp)
f01006be:	e8 1d 26 00 00       	call   f0102ce0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 73 11 	movl   $0x117300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 73 11 	movl   $0xf0117300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 b8 40 10 f0 	movl   $0xf01040b8,(%esp)
f01006da:	e8 01 26 00 00       	call   f0102ce0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 79 11 	movl   $0x117970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 79 11 	movl   $0xf0117970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 dc 40 10 f0 	movl   $0xf01040dc,(%esp)
f01006f6:	e8 e5 25 00 00       	call   f0102ce0 <cprintf>
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
f010071c:	c7 04 24 00 41 10 f0 	movl   $0xf0104100,(%esp)
f0100723:	e8 b8 25 00 00       	call   f0102ce0 <cprintf>
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
f010075e:	e8 74 26 00 00       	call   f0102dd7 <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 ae 3f 10 f0 	movl   $0xf0103fae,(%esp)
f0100775:	e8 66 25 00 00       	call   f0102ce0 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 c9 3f 10 f0 	movl   $0xf0103fc9,(%esp)
f010078a:	e8 51 25 00 00       	call   f0102ce0 <cprintf>
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
f0100796:	c7 04 24 d5 4b 10 f0 	movl   $0xf0104bd5,(%esp)
f010079d:	e8 3e 25 00 00       	call   f0102ce0 <cprintf>
			
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
f01007c8:	c7 04 24 d0 3f 10 f0 	movl   $0xf0103fd0,(%esp)
f01007cf:	e8 0c 25 00 00       	call   f0102ce0 <cprintf>
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
f01007fa:	c7 04 24 2c 41 10 f0 	movl   $0xf010412c,(%esp)
f0100801:	e8 da 24 00 00       	call   f0102ce0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 50 41 10 f0 	movl   $0xf0104150,(%esp)
f010080d:	e8 ce 24 00 00       	call   f0102ce0 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 e1 3f 10 f0 	movl   $0xf0103fe1,(%esp)
f0100819:	e8 b2 2d 00 00       	call   f01035d0 <readline>
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
f010084a:	c7 04 24 e5 3f 10 f0 	movl   $0xf0103fe5,(%esp)
f0100851:	e8 94 2f 00 00       	call   f01037ea <strchr>
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
f010086c:	c7 04 24 ea 3f 10 f0 	movl   $0xf0103fea,(%esp)
f0100873:	e8 68 24 00 00       	call   f0102ce0 <cprintf>
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
f0100894:	c7 04 24 e5 3f 10 f0 	movl   $0xf0103fe5,(%esp)
f010089b:	e8 4a 2f 00 00       	call   f01037ea <strchr>
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
f01008b6:	c7 44 24 04 7e 3f 10 	movl   $0xf0103f7e,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 c3 2e 00 00       	call   f010378c <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 8c 3f 10 	movl   $0xf0103f8c,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 ac 2e 00 00       	call   f010378c <strcmp>
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
f0100903:	ff 14 85 80 41 10 f0 	call   *-0xfefbe80(,%eax,4)


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
f010091a:	c7 04 24 07 40 10 f0 	movl   $0xf0104007,(%esp)
f0100921:	e8 ba 23 00 00       	call   f0102ce0 <cprintf>
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
f010098c:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
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
f010099e:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f01009a5:	f0 
f01009a6:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f01009ad:	00 
f01009ae:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
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
f01009fb:	c7 44 24 08 b4 41 10 	movl   $0xf01041b4,0x8(%esp)
f0100a02:	f0 
f0100a03:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f0100a0a:	00 
f0100a0b:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
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
f0100a25:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
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
f0100a5b:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
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
f0100a65:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100a6b:	eb 63                	jmp    f0100ad0 <check_page_free_list+0xeb>
f0100a6d:	89 d8                	mov    %ebx,%eax
f0100a6f:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
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
f0100a89:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100a8f:	72 20                	jb     f0100ab1 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a95:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0100a9c:	f0 
f0100a9d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aa4:	00 
f0100aa5:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f0100aac:	e8 e3 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ab1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ab8:	00 
f0100ab9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ac0:	00 
	return (void *)(pa + KERNBASE);
f0100ac1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ac6:	89 04 24             	mov    %eax,(%esp)
f0100ac9:	e8 59 2d 00 00       	call   f0103827 <memset>
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
f0100ae1:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ae7:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100aed:	a1 64 79 11 f0       	mov    0xf0117964,%eax
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
f0100b0f:	c7 44 24 0c 3e 49 10 	movl   $0xf010493e,0xc(%esp)
f0100b16:	f0 
f0100b17:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100b1e:	f0 
f0100b1f:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0100b26:	00 
f0100b27:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100b2e:	e8 61 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b33:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b36:	72 24                	jb     f0100b5c <check_page_free_list+0x177>
f0100b38:	c7 44 24 0c 5f 49 10 	movl   $0xf010495f,0xc(%esp)
f0100b3f:	f0 
f0100b40:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100b47:	f0 
f0100b48:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100b4f:	00 
f0100b50:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100b57:	e8 38 f5 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b5c:	89 d0                	mov    %edx,%eax
f0100b5e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b61:	a8 07                	test   $0x7,%al
f0100b63:	74 24                	je     f0100b89 <check_page_free_list+0x1a4>
f0100b65:	c7 44 24 0c d8 41 10 	movl   $0xf01041d8,0xc(%esp)
f0100b6c:	f0 
f0100b6d:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100b74:	f0 
f0100b75:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0100b7c:	00 
f0100b7d:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
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
f0100b93:	c7 44 24 0c 73 49 10 	movl   $0xf0104973,0xc(%esp)
f0100b9a:	f0 
f0100b9b:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100ba2:	f0 
f0100ba3:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0100baa:	00 
f0100bab:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100bb2:	e8 dd f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bb7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bbc:	75 24                	jne    f0100be2 <check_page_free_list+0x1fd>
f0100bbe:	c7 44 24 0c 84 49 10 	movl   $0xf0104984,0xc(%esp)
f0100bc5:	f0 
f0100bc6:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100bcd:	f0 
f0100bce:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100bd5:	00 
f0100bd6:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100bdd:	e8 b2 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be2:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100be7:	75 24                	jne    f0100c0d <check_page_free_list+0x228>
f0100be9:	c7 44 24 0c 0c 42 10 	movl   $0xf010420c,0xc(%esp)
f0100bf0:	f0 
f0100bf1:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100bf8:	f0 
f0100bf9:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100c00:	00 
f0100c01:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100c08:	e8 87 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c0d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c12:	75 24                	jne    f0100c38 <check_page_free_list+0x253>
f0100c14:	c7 44 24 0c 9d 49 10 	movl   $0xf010499d,0xc(%esp)
f0100c1b:	f0 
f0100c1c:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100c23:	f0 
f0100c24:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100c2b:	00 
f0100c2c:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
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
f0100c4d:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0100c54:	f0 
f0100c55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c5c:	00 
f0100c5d:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f0100c64:	e8 2b f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c69:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c6e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c71:	76 2a                	jbe    f0100c9d <check_page_free_list+0x2b8>
f0100c73:	c7 44 24 0c 30 42 10 	movl   $0xf0104230,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
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
f0100cb1:	c7 44 24 0c b7 49 10 	movl   $0xf01049b7,0xc(%esp)
f0100cb8:	f0 
f0100cb9:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100cc0:	f0 
f0100cc1:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0100cc8:	00 
f0100cc9:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100cd0:	e8 bf f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100cd5:	85 ff                	test   %edi,%edi
f0100cd7:	7f 4d                	jg     f0100d26 <check_page_free_list+0x341>
f0100cd9:	c7 44 24 0c c9 49 10 	movl   $0xf01049c9,0xc(%esp)
f0100ce0:	f0 
f0100ce1:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0100ce8:	f0 
f0100ce9:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0100cf0:	00 
f0100cf1:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100cf8:	e8 97 f3 ff ff       	call   f0100094 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cfd:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100d02:	85 c0                	test   %eax,%eax
f0100d04:	0f 85 0d fd ff ff    	jne    f0100a17 <check_page_free_list+0x32>
f0100d0a:	e9 ec fc ff ff       	jmp    f01009fb <check_page_free_list+0x16>
f0100d0f:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
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
f0100d46:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100d4b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d57:	e9 a5 00 00 00       	jmp    f0100e01 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d5c:	3b 1d 40 75 11 f0    	cmp    0xf0117540,%ebx
f0100d62:	73 25                	jae    f0100d89 <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d64:	89 f0                	mov    %esi,%eax
f0100d66:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100d6c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d72:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100d78:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d7a:	89 f0                	mov    %esi,%eax
f0100d7c:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100d82:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
f0100d87:	eb 78                	jmp    f0100e01 <page_init+0xd3>
f0100d89:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d8f:	83 f8 5f             	cmp    $0x5f,%eax
f0100d92:	77 16                	ja     f0100daa <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100d94:	89 f0                	mov    %esi,%eax
f0100d96:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
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
f0100dca:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100dd0:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100dd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ddc:	eb 23                	jmp    f0100e01 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100dde:	89 f0                	mov    %esi,%eax
f0100de0:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100de6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dec:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100df2:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100df4:	89 f0                	mov    %esi,%eax
f0100df6:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100dfc:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e01:	83 c3 01             	add    $0x1,%ebx
f0100e04:	83 c6 08             	add    $0x8,%esi
f0100e07:	3b 1d 64 79 11 f0    	cmp    0xf0117964,%ebx
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
f0100e1e:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e24:	85 db                	test   %ebx,%ebx
f0100e26:	74 6f                	je     f0100e97 <page_alloc+0x80>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e28:	8b 03                	mov    (%ebx),%eax
f0100e2a:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
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
f0100e3d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100e43:	c1 f8 03             	sar    $0x3,%eax
f0100e46:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e49:	89 c2                	mov    %eax,%edx
f0100e4b:	c1 ea 0c             	shr    $0xc,%edx
f0100e4e:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100e54:	72 20                	jb     f0100e76 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e56:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e5a:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0100e61:	f0 
f0100e62:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e69:	00 
f0100e6a:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
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
f0100e8e:	e8 94 29 00 00       	call   f0103827 <memset>
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
f0100eb7:	c7 44 24 08 78 42 10 	movl   $0xf0104278,0x8(%esp)
f0100ebe:	f0 
f0100ebf:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100ec6:	00 
f0100ec7:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100ece:	e8 c1 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100ed3:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100ed9:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100edb:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
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
{	
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
f0100f08:	56                   	push   %esi
f0100f09:	53                   	push   %ebx
f0100f0a:	83 ec 10             	sub    $0x10,%esp
f0100f0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int pdOffset =(physaddr_t)(va) >>22 & 0x3FF;
f0100f10:	89 f3                	mov    %esi,%ebx
f0100f12:	c1 eb 16             	shr    $0x16,%ebx
	//
	// va->base address of the pte; has not add the pageTable offset;
	//
	pte_t* vaPTEBaseAddrePointer = pgdir + pdOffset;
f0100f15:	c1 e3 02             	shl    $0x2,%ebx
f0100f18:	03 5d 08             	add    0x8(%ebp),%ebx
	if(*vaPTEBaseAddrePointer == 0 )
f0100f1b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f1e:	75 2c                	jne    f0100f4c <pgdir_walk+0x47>
	{
		if(create == 0)
f0100f20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f24:	74 6c                	je     f0100f92 <pgdir_walk+0x8d>
			return NULL;
		struct PageInfo* newPage = page_alloc(1);
f0100f26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f2d:	e8 e5 fe ff ff       	call   f0100e17 <page_alloc>
		if(newPage == NULL)
f0100f32:	85 c0                	test   %eax,%eax
f0100f34:	74 63                	je     f0100f99 <pgdir_walk+0x94>
			return NULL;
		newPage->pp_ref++;
f0100f36:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f3b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f41:	c1 f8 03             	sar    $0x3,%eax
f0100f44:	c1 e0 0c             	shl    $0xc,%eax
		*vaPTEBaseAddrePointer = (physaddr_t) page2pa(newPage);	//物理地址
		*vaPTEBaseAddrePointer |= (PTE_P |PTE_W | PTE_U);
f0100f47:	83 c8 07             	or     $0x7,%eax
f0100f4a:	89 03                	mov    %eax,(%ebx)
	}

	unsigned int ptOffset = (physaddr_t)(va) >>12 & 0x3FF;
f0100f4c:	c1 ee 0c             	shr    $0xc,%esi
f0100f4f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t PTEpa = *vaPTEBaseAddrePointer & (~0xFFF); 	//va对应的pte页表的物理地址， 没有加上pte的偏移量
f0100f55:	8b 03                	mov    (%ebx),%eax
f0100f57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5c:	89 c2                	mov    %eax,%edx
f0100f5e:	c1 ea 0c             	shr    $0xc,%edx
f0100f61:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100f67:	72 20                	jb     f0100f89 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f6d:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0100f74:	f0 
f0100f75:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f0100f7c:	00 
f0100f7d:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0100f84:	e8 0b f1 ff ff       	call   f0100094 <_panic>
	pte_t* vpte = KADDR(PTEpa);				//得到PTEpad的虚拟地址（+kernbase）
	return &vpte[ptOffset];					//返回的是va对应的pte项的虚拟地址
f0100f89:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100f90:	eb 0c                	jmp    f0100f9e <pgdir_walk+0x99>
	//
	pte_t* vaPTEBaseAddrePointer = pgdir + pdOffset;
	if(*vaPTEBaseAddrePointer == 0 )
	{
		if(create == 0)
			return NULL;
f0100f92:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f97:	eb 05                	jmp    f0100f9e <pgdir_walk+0x99>
		struct PageInfo* newPage = page_alloc(1);
		if(newPage == NULL)
			return NULL;
f0100f99:	b8 00 00 00 00       	mov    $0x0,%eax
	return &vpte[ptOffset];					//返回的是va对应的pte项的虚拟地址
	//需要返回虚拟地址，而不是物理地址，搞死人啊！！！
	//pte_t* vaPTE = (physaddr_t*) ((*vaPTEBaseAddrePointer >> 12 << 12) +ptOffset) ;
	//return vaPTE;

}
f0100f9e:	83 c4 10             	add    $0x10,%esp
f0100fa1:	5b                   	pop    %ebx
f0100fa2:	5e                   	pop    %esi
f0100fa3:	5d                   	pop    %ebp
f0100fa4:	c3                   	ret    

f0100fa5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fa5:	55                   	push   %ebp
f0100fa6:	89 e5                	mov    %esp,%ebp
f0100fa8:	53                   	push   %ebx
f0100fa9:	83 ec 14             	sub    $0x14,%esp
f0100fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pageTable = pgdir_walk(pgdir, va,0);
f0100faf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fb6:	00 
f0100fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc1:	89 04 24             	mov    %eax,(%esp)
f0100fc4:	e8 3c ff ff ff       	call   f0100f05 <pgdir_walk>
	if(pageTable == NULL )
f0100fc9:	85 c0                	test   %eax,%eax
f0100fcb:	74 3a                	je     f0101007 <page_lookup+0x62>
		return NULL;
	if( pte_store != NULL)
f0100fcd:	85 db                	test   %ebx,%ebx
f0100fcf:	74 02                	je     f0100fd3 <page_lookup+0x2e>
		*pte_store = pageTable;
f0100fd1:	89 03                	mov    %eax,(%ebx)
	//struct PageInfo* ret = pa2page( (pte_t) pageTable);
	struct PageInfo* ret = pa2page(  *pageTable & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
f0100fd3:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd5:	c1 e8 0c             	shr    $0xc,%eax
f0100fd8:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100fde:	72 1c                	jb     f0100ffc <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fe0:	c7 44 24 08 b8 42 10 	movl   $0xf01042b8,0x8(%esp)
f0100fe7:	f0 
f0100fe8:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100fef:	00 
f0100ff0:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f0100ff7:	e8 98 f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0100ffc:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101002:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return ret;
f0101005:	eb 05                	jmp    f010100c <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * pageTable = pgdir_walk(pgdir, va,0);
	if(pageTable == NULL )
		return NULL;
f0101007:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo* ret = pa2page(  *pageTable & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
	return ret;

	// Fill this function in
	
}
f010100c:	83 c4 14             	add    $0x14,%esp
f010100f:	5b                   	pop    %ebx
f0101010:	5d                   	pop    %ebp
f0101011:	c3                   	ret    

f0101012 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{	
f0101012:	55                   	push   %ebp
f0101013:	89 e5                	mov    %esp,%ebp
f0101015:	53                   	push   %ebx
f0101016:	83 ec 24             	sub    $0x24,%esp
f0101019:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//有问题  还要再看看
	pte_t * pte = 0 ;
f010101c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	pte_t ** pt_store = &pte;
	struct PageInfo* phyPage = page_lookup(pgdir, va, pt_store);
f0101023:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101026:	89 44 24 08          	mov    %eax,0x8(%esp)
f010102a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010102e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101031:	89 04 24             	mov    %eax,(%esp)
f0101034:	e8 6c ff ff ff       	call   f0100fa5 <page_lookup>
	if(phyPage == 0)
f0101039:	85 c0                	test   %eax,%eax
f010103b:	74 14                	je     f0101051 <page_remove+0x3f>
		return ;
	page_decref(phyPage);
f010103d:	89 04 24             	mov    %eax,(%esp)
f0101040:	e8 9d fe ff ff       	call   f0100ee2 <page_decref>
	*pte = 0;
f0101045:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101048:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010104e:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir,va);
	return;
}
f0101051:	83 c4 24             	add    $0x24,%esp
f0101054:	5b                   	pop    %ebx
f0101055:	5d                   	pop    %ebp
f0101056:	c3                   	ret    

f0101057 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
f010105a:	57                   	push   %edi
f010105b:	56                   	push   %esi
f010105c:	53                   	push   %ebx
f010105d:	83 ec 1c             	sub    $0x1c,%esp
f0101060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101063:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* vaPT = pgdir_walk(pgdir,va,1);
f0101066:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010106d:	00 
f010106e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101072:	8b 45 08             	mov    0x8(%ebp),%eax
f0101075:	89 04 24             	mov    %eax,(%esp)
f0101078:	e8 88 fe ff ff       	call   f0100f05 <pgdir_walk>
f010107d:	89 c6                	mov    %eax,%esi
	if(vaPT == NULL)
f010107f:	85 c0                	test   %eax,%eax
f0101081:	74 5d                	je     f01010e0 <page_insert+0x89>
		return -E_NO_MEM;
	// va 已经指向了pp
	if( (*vaPT & ~0xFFF) == page2pa(pp) )	//*vaPT里面存储的是va所在页的物理地址
f0101083:	8b 00                	mov    (%eax),%eax
f0101085:	89 c1                	mov    %eax,%ecx
f0101087:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010108d:	89 da                	mov    %ebx,%edx
f010108f:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101095:	c1 fa 03             	sar    $0x3,%edx
f0101098:	c1 e2 0c             	shl    $0xc,%edx
f010109b:	39 d1                	cmp    %edx,%ecx
f010109d:	75 0a                	jne    f01010a9 <page_insert+0x52>
f010109f:	0f 01 3f             	invlpg (%edi)
		{
			tlb_invalidate(pgdir,va);
			pp->pp_ref--;
f01010a2:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01010a7:	eb 13                	jmp    f01010bc <page_insert+0x65>
		}
	else  if(*vaPT != 0)	//若va已经分配，则取消其分配
f01010a9:	85 c0                	test   %eax,%eax
f01010ab:	74 0f                	je     f01010bc <page_insert+0x65>
		page_remove(pgdir,va);
f01010ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010b4:	89 04 24             	mov    %eax,(%esp)
f01010b7:	e8 56 ff ff ff       	call   f0101012 <page_remove>
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	vaPT[0] = page2pa(pp)| perm | PTE_P;
f01010bc:	8b 55 14             	mov    0x14(%ebp),%edx
f01010bf:	83 ca 01             	or     $0x1,%edx
f01010c2:	89 d8                	mov    %ebx,%eax
f01010c4:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01010ca:	c1 f8 03             	sar    $0x3,%eax
f01010cd:	c1 e0 0c             	shl    $0xc,%eax
f01010d0:	09 d0                	or     %edx,%eax
f01010d2:	89 06                	mov    %eax,(%esi)
	pp->pp_ref ++;
f01010d4:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0; 
f01010d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01010de:	eb 05                	jmp    f01010e5 <page_insert+0x8e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* vaPT = pgdir_walk(pgdir,va,1);
	if(vaPT == NULL)
		return -E_NO_MEM;
f01010e0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	vaPT[0] = page2pa(pp)| perm | PTE_P;
	pp->pp_ref ++;
	return 0; 
}
f01010e5:	83 c4 1c             	add    $0x1c,%esp
f01010e8:	5b                   	pop    %ebx
f01010e9:	5e                   	pop    %esi
f01010ea:	5f                   	pop    %edi
f01010eb:	5d                   	pop    %ebp
f01010ec:	c3                   	ret    

f01010ed <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010ed:	55                   	push   %ebp
f01010ee:	89 e5                	mov    %esp,%ebp
f01010f0:	57                   	push   %edi
f01010f1:	56                   	push   %esi
f01010f2:	53                   	push   %ebx
f01010f3:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010f6:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01010fd:	e8 6e 1b 00 00       	call   f0102c70 <mc146818_read>
f0101102:	89 c3                	mov    %eax,%ebx
f0101104:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010110b:	e8 60 1b 00 00       	call   f0102c70 <mc146818_read>
f0101110:	c1 e0 08             	shl    $0x8,%eax
f0101113:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101115:	89 d8                	mov    %ebx,%eax
f0101117:	c1 e0 0a             	shl    $0xa,%eax
f010111a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101120:	85 c0                	test   %eax,%eax
f0101122:	0f 48 c2             	cmovs  %edx,%eax
f0101125:	c1 f8 0c             	sar    $0xc,%eax
f0101128:	a3 40 75 11 f0       	mov    %eax,0xf0117540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010112d:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101134:	e8 37 1b 00 00       	call   f0102c70 <mc146818_read>
f0101139:	89 c3                	mov    %eax,%ebx
f010113b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101142:	e8 29 1b 00 00       	call   f0102c70 <mc146818_read>
f0101147:	c1 e0 08             	shl    $0x8,%eax
f010114a:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010114c:	89 d8                	mov    %ebx,%eax
f010114e:	c1 e0 0a             	shl    $0xa,%eax
f0101151:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101157:	85 c0                	test   %eax,%eax
f0101159:	0f 48 c2             	cmovs  %edx,%eax
f010115c:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010115f:	85 c0                	test   %eax,%eax
f0101161:	74 0e                	je     f0101171 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101163:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101169:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
f010116f:	eb 0c                	jmp    f010117d <mem_init+0x90>
	else
		npages = npages_basemem;
f0101171:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0101177:	89 15 64 79 11 f0    	mov    %edx,0xf0117964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010117d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101180:	c1 e8 0a             	shr    $0xa,%eax
f0101183:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101187:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f010118c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010118f:	c1 e8 0a             	shr    $0xa,%eax
f0101192:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101196:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010119b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010119e:	c1 e8 0a             	shr    $0xa,%eax
f01011a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011a5:	c7 04 24 d8 42 10 f0 	movl   $0xf01042d8,(%esp)
f01011ac:	e8 2f 1b 00 00       	call   f0102ce0 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011b1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011b6:	e8 78 f7 ff ff       	call   f0100933 <boot_alloc>
f01011bb:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f01011c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011c7:	00 
f01011c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011cf:	00 
f01011d0:	89 04 24             	mov    %eax,(%esp)
f01011d3:	e8 4f 26 00 00       	call   f0103827 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011d8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011e2:	77 20                	ja     f0101204 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011e8:	c7 44 24 08 14 43 10 	movl   $0xf0104314,0x8(%esp)
f01011ef:	f0 
f01011f0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f01011f7:	00 
f01011f8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01011ff:	e8 90 ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101204:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010120a:	83 ca 05             	or     $0x5,%edx
f010120d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0101213:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101218:	c1 e0 03             	shl    $0x3,%eax
f010121b:	e8 13 f7 ff ff       	call   f0100933 <boot_alloc>
f0101220:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f0101225:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f010122b:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101232:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101236:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010123d:	00 
f010123e:	89 04 24             	mov    %eax,(%esp)
f0101241:	e8 e1 25 00 00       	call   f0103827 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101246:	e8 e3 fa ff ff       	call   f0100d2e <page_init>

	check_page_free_list(1);
f010124b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101250:	e8 90 f7 ff ff       	call   f01009e5 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101255:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f010125c:	75 1c                	jne    f010127a <mem_init+0x18d>
		panic("'pages' is a null pointer!");
f010125e:	c7 44 24 08 da 49 10 	movl   $0xf01049da,0x8(%esp)
f0101265:	f0 
f0101266:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f010126d:	00 
f010126e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101275:	e8 1a ee ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010127a:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010127f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101284:	eb 05                	jmp    f010128b <mem_init+0x19e>
		++nfree;
f0101286:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101289:	8b 00                	mov    (%eax),%eax
f010128b:	85 c0                	test   %eax,%eax
f010128d:	75 f7                	jne    f0101286 <mem_init+0x199>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101296:	e8 7c fb ff ff       	call   f0100e17 <page_alloc>
f010129b:	89 c7                	mov    %eax,%edi
f010129d:	85 c0                	test   %eax,%eax
f010129f:	75 24                	jne    f01012c5 <mem_init+0x1d8>
f01012a1:	c7 44 24 0c f5 49 10 	movl   $0xf01049f5,0xc(%esp)
f01012a8:	f0 
f01012a9:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01012b0:	f0 
f01012b1:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f01012b8:	00 
f01012b9:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01012c0:	e8 cf ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012cc:	e8 46 fb ff ff       	call   f0100e17 <page_alloc>
f01012d1:	89 c6                	mov    %eax,%esi
f01012d3:	85 c0                	test   %eax,%eax
f01012d5:	75 24                	jne    f01012fb <mem_init+0x20e>
f01012d7:	c7 44 24 0c 0b 4a 10 	movl   $0xf0104a0b,0xc(%esp)
f01012de:	f0 
f01012df:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01012e6:	f0 
f01012e7:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f01012ee:	00 
f01012ef:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01012f6:	e8 99 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101302:	e8 10 fb ff ff       	call   f0100e17 <page_alloc>
f0101307:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010130a:	85 c0                	test   %eax,%eax
f010130c:	75 24                	jne    f0101332 <mem_init+0x245>
f010130e:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f0101315:	f0 
f0101316:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010131d:	f0 
f010131e:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f0101325:	00 
f0101326:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010132d:	e8 62 ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101332:	39 f7                	cmp    %esi,%edi
f0101334:	75 24                	jne    f010135a <mem_init+0x26d>
f0101336:	c7 44 24 0c 37 4a 10 	movl   $0xf0104a37,0xc(%esp)
f010133d:	f0 
f010133e:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101345:	f0 
f0101346:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f010134d:	00 
f010134e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101355:	e8 3a ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010135a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010135d:	39 c6                	cmp    %eax,%esi
f010135f:	74 04                	je     f0101365 <mem_init+0x278>
f0101361:	39 c7                	cmp    %eax,%edi
f0101363:	75 24                	jne    f0101389 <mem_init+0x29c>
f0101365:	c7 44 24 0c 38 43 10 	movl   $0xf0104338,0xc(%esp)
f010136c:	f0 
f010136d:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101374:	f0 
f0101375:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010137c:	00 
f010137d:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101384:	e8 0b ed ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101389:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010138f:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101394:	c1 e0 0c             	shl    $0xc,%eax
f0101397:	89 f9                	mov    %edi,%ecx
f0101399:	29 d1                	sub    %edx,%ecx
f010139b:	c1 f9 03             	sar    $0x3,%ecx
f010139e:	c1 e1 0c             	shl    $0xc,%ecx
f01013a1:	39 c1                	cmp    %eax,%ecx
f01013a3:	72 24                	jb     f01013c9 <mem_init+0x2dc>
f01013a5:	c7 44 24 0c 49 4a 10 	movl   $0xf0104a49,0xc(%esp)
f01013ac:	f0 
f01013ad:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01013b4:	f0 
f01013b5:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f01013bc:	00 
f01013bd:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01013c4:	e8 cb ec ff ff       	call   f0100094 <_panic>
f01013c9:	89 f1                	mov    %esi,%ecx
f01013cb:	29 d1                	sub    %edx,%ecx
f01013cd:	c1 f9 03             	sar    $0x3,%ecx
f01013d0:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013d3:	39 c8                	cmp    %ecx,%eax
f01013d5:	77 24                	ja     f01013fb <mem_init+0x30e>
f01013d7:	c7 44 24 0c 66 4a 10 	movl   $0xf0104a66,0xc(%esp)
f01013de:	f0 
f01013df:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01013e6:	f0 
f01013e7:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f01013ee:	00 
f01013ef:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01013f6:	e8 99 ec ff ff       	call   f0100094 <_panic>
f01013fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01013fe:	29 d1                	sub    %edx,%ecx
f0101400:	89 ca                	mov    %ecx,%edx
f0101402:	c1 fa 03             	sar    $0x3,%edx
f0101405:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101408:	39 d0                	cmp    %edx,%eax
f010140a:	77 24                	ja     f0101430 <mem_init+0x343>
f010140c:	c7 44 24 0c 83 4a 10 	movl   $0xf0104a83,0xc(%esp)
f0101413:	f0 
f0101414:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010141b:	f0 
f010141c:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f0101423:	00 
f0101424:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010142b:	e8 64 ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101430:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101435:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101438:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f010143f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101442:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101449:	e8 c9 f9 ff ff       	call   f0100e17 <page_alloc>
f010144e:	85 c0                	test   %eax,%eax
f0101450:	74 24                	je     f0101476 <mem_init+0x389>
f0101452:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f0101459:	f0 
f010145a:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101461:	f0 
f0101462:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0101469:	00 
f010146a:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101471:	e8 1e ec ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101476:	89 3c 24             	mov    %edi,(%esp)
f0101479:	e8 24 fa ff ff       	call   f0100ea2 <page_free>
	page_free(pp1);
f010147e:	89 34 24             	mov    %esi,(%esp)
f0101481:	e8 1c fa ff ff       	call   f0100ea2 <page_free>
	page_free(pp2);
f0101486:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101489:	89 04 24             	mov    %eax,(%esp)
f010148c:	e8 11 fa ff ff       	call   f0100ea2 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101498:	e8 7a f9 ff ff       	call   f0100e17 <page_alloc>
f010149d:	89 c6                	mov    %eax,%esi
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	75 24                	jne    f01014c7 <mem_init+0x3da>
f01014a3:	c7 44 24 0c f5 49 10 	movl   $0xf01049f5,0xc(%esp)
f01014aa:	f0 
f01014ab:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01014b2:	f0 
f01014b3:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f01014ba:	00 
f01014bb:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01014c2:	e8 cd eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01014c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ce:	e8 44 f9 ff ff       	call   f0100e17 <page_alloc>
f01014d3:	89 c7                	mov    %eax,%edi
f01014d5:	85 c0                	test   %eax,%eax
f01014d7:	75 24                	jne    f01014fd <mem_init+0x410>
f01014d9:	c7 44 24 0c 0b 4a 10 	movl   $0xf0104a0b,0xc(%esp)
f01014e0:	f0 
f01014e1:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01014e8:	f0 
f01014e9:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01014f0:	00 
f01014f1:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01014f8:	e8 97 eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01014fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101504:	e8 0e f9 ff ff       	call   f0100e17 <page_alloc>
f0101509:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010150c:	85 c0                	test   %eax,%eax
f010150e:	75 24                	jne    f0101534 <mem_init+0x447>
f0101510:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f0101517:	f0 
f0101518:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010151f:	f0 
f0101520:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0101527:	00 
f0101528:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010152f:	e8 60 eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101534:	39 fe                	cmp    %edi,%esi
f0101536:	75 24                	jne    f010155c <mem_init+0x46f>
f0101538:	c7 44 24 0c 37 4a 10 	movl   $0xf0104a37,0xc(%esp)
f010153f:	f0 
f0101540:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101547:	f0 
f0101548:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f010154f:	00 
f0101550:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101557:	e8 38 eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010155c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010155f:	39 c7                	cmp    %eax,%edi
f0101561:	74 04                	je     f0101567 <mem_init+0x47a>
f0101563:	39 c6                	cmp    %eax,%esi
f0101565:	75 24                	jne    f010158b <mem_init+0x49e>
f0101567:	c7 44 24 0c 38 43 10 	movl   $0xf0104338,0xc(%esp)
f010156e:	f0 
f010156f:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101576:	f0 
f0101577:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010157e:	00 
f010157f:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101586:	e8 09 eb ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010158b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101592:	e8 80 f8 ff ff       	call   f0100e17 <page_alloc>
f0101597:	85 c0                	test   %eax,%eax
f0101599:	74 24                	je     f01015bf <mem_init+0x4d2>
f010159b:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f01015a2:	f0 
f01015a3:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01015aa:	f0 
f01015ab:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f01015b2:	00 
f01015b3:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01015ba:	e8 d5 ea ff ff       	call   f0100094 <_panic>
f01015bf:	89 f0                	mov    %esi,%eax
f01015c1:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01015c7:	c1 f8 03             	sar    $0x3,%eax
f01015ca:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015cd:	89 c2                	mov    %eax,%edx
f01015cf:	c1 ea 0c             	shr    $0xc,%edx
f01015d2:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01015d8:	72 20                	jb     f01015fa <mem_init+0x50d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015de:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f01015e5:	f0 
f01015e6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01015ed:	00 
f01015ee:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f01015f5:	e8 9a ea ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015fa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101601:	00 
f0101602:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101609:	00 
	return (void *)(pa + KERNBASE);
f010160a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010160f:	89 04 24             	mov    %eax,(%esp)
f0101612:	e8 10 22 00 00       	call   f0103827 <memset>
	page_free(pp0);
f0101617:	89 34 24             	mov    %esi,(%esp)
f010161a:	e8 83 f8 ff ff       	call   f0100ea2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010161f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101626:	e8 ec f7 ff ff       	call   f0100e17 <page_alloc>
f010162b:	85 c0                	test   %eax,%eax
f010162d:	75 24                	jne    f0101653 <mem_init+0x566>
f010162f:	c7 44 24 0c af 4a 10 	movl   $0xf0104aaf,0xc(%esp)
f0101636:	f0 
f0101637:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010163e:	f0 
f010163f:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101646:	00 
f0101647:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010164e:	e8 41 ea ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101653:	39 c6                	cmp    %eax,%esi
f0101655:	74 24                	je     f010167b <mem_init+0x58e>
f0101657:	c7 44 24 0c cd 4a 10 	movl   $0xf0104acd,0xc(%esp)
f010165e:	f0 
f010165f:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101666:	f0 
f0101667:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f010166e:	00 
f010166f:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101676:	e8 19 ea ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010167b:	89 f0                	mov    %esi,%eax
f010167d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101683:	c1 f8 03             	sar    $0x3,%eax
f0101686:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101689:	89 c2                	mov    %eax,%edx
f010168b:	c1 ea 0c             	shr    $0xc,%edx
f010168e:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101694:	72 20                	jb     f01016b6 <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101696:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010169a:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f01016a1:	f0 
f01016a2:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016a9:	00 
f01016aa:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f01016b1:	e8 de e9 ff ff       	call   f0100094 <_panic>
f01016b6:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01016bc:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016c2:	80 38 00             	cmpb   $0x0,(%eax)
f01016c5:	74 24                	je     f01016eb <mem_init+0x5fe>
f01016c7:	c7 44 24 0c dd 4a 10 	movl   $0xf0104add,0xc(%esp)
f01016ce:	f0 
f01016cf:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01016d6:	f0 
f01016d7:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01016de:	00 
f01016df:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01016e6:	e8 a9 e9 ff ff       	call   f0100094 <_panic>
f01016eb:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016ee:	39 d0                	cmp    %edx,%eax
f01016f0:	75 d0                	jne    f01016c2 <mem_init+0x5d5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016f5:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01016fa:	89 34 24             	mov    %esi,(%esp)
f01016fd:	e8 a0 f7 ff ff       	call   f0100ea2 <page_free>
	page_free(pp1);
f0101702:	89 3c 24             	mov    %edi,(%esp)
f0101705:	e8 98 f7 ff ff       	call   f0100ea2 <page_free>
	page_free(pp2);
f010170a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010170d:	89 04 24             	mov    %eax,(%esp)
f0101710:	e8 8d f7 ff ff       	call   f0100ea2 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101715:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010171a:	eb 05                	jmp    f0101721 <mem_init+0x634>
		--nfree;
f010171c:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010171f:	8b 00                	mov    (%eax),%eax
f0101721:	85 c0                	test   %eax,%eax
f0101723:	75 f7                	jne    f010171c <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f0101725:	85 db                	test   %ebx,%ebx
f0101727:	74 24                	je     f010174d <mem_init+0x660>
f0101729:	c7 44 24 0c e7 4a 10 	movl   $0xf0104ae7,0xc(%esp)
f0101730:	f0 
f0101731:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101738:	f0 
f0101739:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101740:	00 
f0101741:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101748:	e8 47 e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010174d:	c7 04 24 58 43 10 f0 	movl   $0xf0104358,(%esp)
f0101754:	e8 87 15 00 00       	call   f0102ce0 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101759:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101760:	e8 b2 f6 ff ff       	call   f0100e17 <page_alloc>
f0101765:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101768:	85 c0                	test   %eax,%eax
f010176a:	75 24                	jne    f0101790 <mem_init+0x6a3>
f010176c:	c7 44 24 0c f5 49 10 	movl   $0xf01049f5,0xc(%esp)
f0101773:	f0 
f0101774:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010177b:	f0 
f010177c:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101783:	00 
f0101784:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010178b:	e8 04 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101790:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101797:	e8 7b f6 ff ff       	call   f0100e17 <page_alloc>
f010179c:	89 c3                	mov    %eax,%ebx
f010179e:	85 c0                	test   %eax,%eax
f01017a0:	75 24                	jne    f01017c6 <mem_init+0x6d9>
f01017a2:	c7 44 24 0c 0b 4a 10 	movl   $0xf0104a0b,0xc(%esp)
f01017a9:	f0 
f01017aa:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01017b1:	f0 
f01017b2:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f01017b9:	00 
f01017ba:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01017c1:	e8 ce e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017cd:	e8 45 f6 ff ff       	call   f0100e17 <page_alloc>
f01017d2:	89 c6                	mov    %eax,%esi
f01017d4:	85 c0                	test   %eax,%eax
f01017d6:	75 24                	jne    f01017fc <mem_init+0x70f>
f01017d8:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f01017df:	f0 
f01017e0:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01017e7:	f0 
f01017e8:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f01017ef:	00 
f01017f0:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01017f7:	e8 98 e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017fc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017ff:	75 24                	jne    f0101825 <mem_init+0x738>
f0101801:	c7 44 24 0c 37 4a 10 	movl   $0xf0104a37,0xc(%esp)
f0101808:	f0 
f0101809:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101810:	f0 
f0101811:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101818:	00 
f0101819:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101820:	e8 6f e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101825:	39 c3                	cmp    %eax,%ebx
f0101827:	74 05                	je     f010182e <mem_init+0x741>
f0101829:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010182c:	75 24                	jne    f0101852 <mem_init+0x765>
f010182e:	c7 44 24 0c 38 43 10 	movl   $0xf0104338,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010184d:	e8 42 e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101852:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101857:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010185a:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101861:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101864:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010186b:	e8 a7 f5 ff ff       	call   f0100e17 <page_alloc>
f0101870:	85 c0                	test   %eax,%eax
f0101872:	74 24                	je     f0101898 <mem_init+0x7ab>
f0101874:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f010187b:	f0 
f010187c:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101883:	f0 
f0101884:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f010188b:	00 
f010188c:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101893:	e8 fc e7 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101898:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010189b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010189f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018a6:	00 
f01018a7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018ac:	89 04 24             	mov    %eax,(%esp)
f01018af:	e8 f1 f6 ff ff       	call   f0100fa5 <page_lookup>
f01018b4:	85 c0                	test   %eax,%eax
f01018b6:	74 24                	je     f01018dc <mem_init+0x7ef>
f01018b8:	c7 44 24 0c 78 43 10 	movl   $0xf0104378,0xc(%esp)
f01018bf:	f0 
f01018c0:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01018c7:	f0 
f01018c8:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01018cf:	00 
f01018d0:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01018d7:	e8 b8 e7 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018e3:	00 
f01018e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018eb:	00 
f01018ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01018f0:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018f5:	89 04 24             	mov    %eax,(%esp)
f01018f8:	e8 5a f7 ff ff       	call   f0101057 <page_insert>
f01018fd:	85 c0                	test   %eax,%eax
f01018ff:	78 24                	js     f0101925 <mem_init+0x838>
f0101901:	c7 44 24 0c b0 43 10 	movl   $0xf01043b0,0xc(%esp)
f0101908:	f0 
f0101909:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101910:	f0 
f0101911:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101918:	00 
f0101919:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101920:	e8 6f e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101928:	89 04 24             	mov    %eax,(%esp)
f010192b:	e8 72 f5 ff ff       	call   f0100ea2 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101930:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101937:	00 
f0101938:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010193f:	00 
f0101940:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101944:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101949:	89 04 24             	mov    %eax,(%esp)
f010194c:	e8 06 f7 ff ff       	call   f0101057 <page_insert>
f0101951:	85 c0                	test   %eax,%eax
f0101953:	74 24                	je     f0101979 <mem_init+0x88c>
f0101955:	c7 44 24 0c e0 43 10 	movl   $0xf01043e0,0xc(%esp)
f010195c:	f0 
f010195d:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101964:	f0 
f0101965:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f010196c:	00 
f010196d:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101974:	e8 1b e7 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101979:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010197f:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101984:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101987:	8b 17                	mov    (%edi),%edx
f0101989:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010198f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101992:	29 c1                	sub    %eax,%ecx
f0101994:	89 c8                	mov    %ecx,%eax
f0101996:	c1 f8 03             	sar    $0x3,%eax
f0101999:	c1 e0 0c             	shl    $0xc,%eax
f010199c:	39 c2                	cmp    %eax,%edx
f010199e:	74 24                	je     f01019c4 <mem_init+0x8d7>
f01019a0:	c7 44 24 0c 10 44 10 	movl   $0xf0104410,0xc(%esp)
f01019a7:	f0 
f01019a8:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01019af:	f0 
f01019b0:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01019b7:	00 
f01019b8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01019bf:	e8 d0 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01019c9:	89 f8                	mov    %edi,%eax
f01019cb:	e8 a6 ef ff ff       	call   f0100976 <check_va2pa>
f01019d0:	89 da                	mov    %ebx,%edx
f01019d2:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01019d5:	c1 fa 03             	sar    $0x3,%edx
f01019d8:	c1 e2 0c             	shl    $0xc,%edx
f01019db:	39 d0                	cmp    %edx,%eax
f01019dd:	74 24                	je     f0101a03 <mem_init+0x916>
f01019df:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01019ee:	f0 
f01019ef:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f01019f6:	00 
f01019f7:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01019fe:	e8 91 e6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101a03:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a08:	74 24                	je     f0101a2e <mem_init+0x941>
f0101a0a:	c7 44 24 0c f2 4a 10 	movl   $0xf0104af2,0xc(%esp)
f0101a11:	f0 
f0101a12:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101a19:	f0 
f0101a1a:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101a21:	00 
f0101a22:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101a29:	e8 66 e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101a2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a31:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a36:	74 24                	je     f0101a5c <mem_init+0x96f>
f0101a38:	c7 44 24 0c 03 4b 10 	movl   $0xf0104b03,0xc(%esp)
f0101a3f:	f0 
f0101a40:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101a47:	f0 
f0101a48:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101a4f:	00 
f0101a50:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101a57:	e8 38 e6 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a5c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a63:	00 
f0101a64:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a6b:	00 
f0101a6c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a70:	89 3c 24             	mov    %edi,(%esp)
f0101a73:	e8 df f5 ff ff       	call   f0101057 <page_insert>
f0101a78:	85 c0                	test   %eax,%eax
f0101a7a:	74 24                	je     f0101aa0 <mem_init+0x9b3>
f0101a7c:	c7 44 24 0c 68 44 10 	movl   $0xf0104468,0xc(%esp)
f0101a83:	f0 
f0101a84:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101a8b:	f0 
f0101a8c:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101a93:	00 
f0101a94:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101a9b:	e8 f4 e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa5:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101aaa:	e8 c7 ee ff ff       	call   f0100976 <check_va2pa>
f0101aaf:	89 f2                	mov    %esi,%edx
f0101ab1:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101ab7:	c1 fa 03             	sar    $0x3,%edx
f0101aba:	c1 e2 0c             	shl    $0xc,%edx
f0101abd:	39 d0                	cmp    %edx,%eax
f0101abf:	74 24                	je     f0101ae5 <mem_init+0x9f8>
f0101ac1:	c7 44 24 0c a4 44 10 	movl   $0xf01044a4,0xc(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101ad0:	f0 
f0101ad1:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101ad8:	00 
f0101ad9:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101ae0:	e8 af e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aea:	74 24                	je     f0101b10 <mem_init+0xa23>
f0101aec:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101b03:	00 
f0101b04:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101b0b:	e8 84 e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b17:	e8 fb f2 ff ff       	call   f0100e17 <page_alloc>
f0101b1c:	85 c0                	test   %eax,%eax
f0101b1e:	74 24                	je     f0101b44 <mem_init+0xa57>
f0101b20:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f0101b27:	f0 
f0101b28:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101b2f:	f0 
f0101b30:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101b37:	00 
f0101b38:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101b3f:	e8 50 e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b44:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b4b:	00 
f0101b4c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b53:	00 
f0101b54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b58:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101b5d:	89 04 24             	mov    %eax,(%esp)
f0101b60:	e8 f2 f4 ff ff       	call   f0101057 <page_insert>
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	74 24                	je     f0101b8d <mem_init+0xaa0>
f0101b69:	c7 44 24 0c 68 44 10 	movl   $0xf0104468,0xc(%esp)
f0101b70:	f0 
f0101b71:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101b78:	f0 
f0101b79:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101b80:	00 
f0101b81:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101b88:	e8 07 e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b92:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101b97:	e8 da ed ff ff       	call   f0100976 <check_va2pa>
f0101b9c:	89 f2                	mov    %esi,%edx
f0101b9e:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101ba4:	c1 fa 03             	sar    $0x3,%edx
f0101ba7:	c1 e2 0c             	shl    $0xc,%edx
f0101baa:	39 d0                	cmp    %edx,%eax
f0101bac:	74 24                	je     f0101bd2 <mem_init+0xae5>
f0101bae:	c7 44 24 0c a4 44 10 	movl   $0xf01044a4,0xc(%esp)
f0101bb5:	f0 
f0101bb6:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101bbd:	f0 
f0101bbe:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101bc5:	00 
f0101bc6:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101bcd:	e8 c2 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101bd2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd7:	74 24                	je     f0101bfd <mem_init+0xb10>
f0101bd9:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0101be0:	f0 
f0101be1:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101be8:	f0 
f0101be9:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101bf0:	00 
f0101bf1:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101bf8:	e8 97 e4 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c04:	e8 0e f2 ff ff       	call   f0100e17 <page_alloc>
f0101c09:	85 c0                	test   %eax,%eax
f0101c0b:	74 24                	je     f0101c31 <mem_init+0xb44>
f0101c0d:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f0101c14:	f0 
f0101c15:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101c24:	00 
f0101c25:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101c2c:	e8 63 e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c31:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101c37:	8b 02                	mov    (%edx),%eax
f0101c39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c3e:	89 c1                	mov    %eax,%ecx
f0101c40:	c1 e9 0c             	shr    $0xc,%ecx
f0101c43:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101c49:	72 20                	jb     f0101c6b <mem_init+0xb7e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c4f:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0101c56:	f0 
f0101c57:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101c5e:	00 
f0101c5f:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101c66:	e8 29 e4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101c6b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c7a:	00 
f0101c7b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c82:	00 
f0101c83:	89 14 24             	mov    %edx,(%esp)
f0101c86:	e8 7a f2 ff ff       	call   f0100f05 <pgdir_walk>
f0101c8b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c8e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c91:	39 d0                	cmp    %edx,%eax
f0101c93:	74 24                	je     f0101cb9 <mem_init+0xbcc>
f0101c95:	c7 44 24 0c d4 44 10 	movl   $0xf01044d4,0xc(%esp)
f0101c9c:	f0 
f0101c9d:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101ca4:	f0 
f0101ca5:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101cac:	00 
f0101cad:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101cb4:	e8 db e3 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cb9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101cc0:	00 
f0101cc1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cc8:	00 
f0101cc9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ccd:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101cd2:	89 04 24             	mov    %eax,(%esp)
f0101cd5:	e8 7d f3 ff ff       	call   f0101057 <page_insert>
f0101cda:	85 c0                	test   %eax,%eax
f0101cdc:	74 24                	je     f0101d02 <mem_init+0xc15>
f0101cde:	c7 44 24 0c 14 45 10 	movl   $0xf0104514,0xc(%esp)
f0101ce5:	f0 
f0101ce6:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101ced:	f0 
f0101cee:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101cf5:	00 
f0101cf6:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101cfd:	e8 92 e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d02:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101d08:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0d:	89 f8                	mov    %edi,%eax
f0101d0f:	e8 62 ec ff ff       	call   f0100976 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d14:	89 f2                	mov    %esi,%edx
f0101d16:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101d1c:	c1 fa 03             	sar    $0x3,%edx
f0101d1f:	c1 e2 0c             	shl    $0xc,%edx
f0101d22:	39 d0                	cmp    %edx,%eax
f0101d24:	74 24                	je     f0101d4a <mem_init+0xc5d>
f0101d26:	c7 44 24 0c a4 44 10 	movl   $0xf01044a4,0xc(%esp)
f0101d2d:	f0 
f0101d2e:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101d35:	f0 
f0101d36:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101d3d:	00 
f0101d3e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101d45:	e8 4a e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d4a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d4f:	74 24                	je     f0101d75 <mem_init+0xc88>
f0101d51:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101d60:	f0 
f0101d61:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101d68:	00 
f0101d69:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101d70:	e8 1f e3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d7c:	00 
f0101d7d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d84:	00 
f0101d85:	89 3c 24             	mov    %edi,(%esp)
f0101d88:	e8 78 f1 ff ff       	call   f0100f05 <pgdir_walk>
f0101d8d:	f6 00 04             	testb  $0x4,(%eax)
f0101d90:	75 24                	jne    f0101db6 <mem_init+0xcc9>
f0101d92:	c7 44 24 0c 54 45 10 	movl   $0xf0104554,0xc(%esp)
f0101d99:	f0 
f0101d9a:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101da1:	f0 
f0101da2:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101da9:	00 
f0101daa:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101db1:	e8 de e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101db6:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101dbb:	f6 00 04             	testb  $0x4,(%eax)
f0101dbe:	75 24                	jne    f0101de4 <mem_init+0xcf7>
f0101dc0:	c7 44 24 0c 25 4b 10 	movl   $0xf0104b25,0xc(%esp)
f0101dc7:	f0 
f0101dc8:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101dcf:	f0 
f0101dd0:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101dd7:	00 
f0101dd8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101ddf:	e8 b0 e2 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101de4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101deb:	00 
f0101dec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101df3:	00 
f0101df4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101df8:	89 04 24             	mov    %eax,(%esp)
f0101dfb:	e8 57 f2 ff ff       	call   f0101057 <page_insert>
f0101e00:	85 c0                	test   %eax,%eax
f0101e02:	74 24                	je     f0101e28 <mem_init+0xd3b>
f0101e04:	c7 44 24 0c 68 44 10 	movl   $0xf0104468,0xc(%esp)
f0101e0b:	f0 
f0101e0c:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101e13:	f0 
f0101e14:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101e1b:	00 
f0101e1c:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101e23:	e8 6c e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e2f:	00 
f0101e30:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e37:	00 
f0101e38:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e3d:	89 04 24             	mov    %eax,(%esp)
f0101e40:	e8 c0 f0 ff ff       	call   f0100f05 <pgdir_walk>
f0101e45:	f6 00 02             	testb  $0x2,(%eax)
f0101e48:	75 24                	jne    f0101e6e <mem_init+0xd81>
f0101e4a:	c7 44 24 0c 88 45 10 	movl   $0xf0104588,0xc(%esp)
f0101e51:	f0 
f0101e52:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101e59:	f0 
f0101e5a:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101e61:	00 
f0101e62:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101e69:	e8 26 e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e6e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e75:	00 
f0101e76:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e7d:	00 
f0101e7e:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e83:	89 04 24             	mov    %eax,(%esp)
f0101e86:	e8 7a f0 ff ff       	call   f0100f05 <pgdir_walk>
f0101e8b:	f6 00 04             	testb  $0x4,(%eax)
f0101e8e:	74 24                	je     f0101eb4 <mem_init+0xdc7>
f0101e90:	c7 44 24 0c bc 45 10 	movl   $0xf01045bc,0xc(%esp)
f0101e97:	f0 
f0101e98:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101e9f:	f0 
f0101ea0:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101ea7:	00 
f0101ea8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101eaf:	e8 e0 e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101eb4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ebb:	00 
f0101ebc:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101ec3:	00 
f0101ec4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ecb:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ed0:	89 04 24             	mov    %eax,(%esp)
f0101ed3:	e8 7f f1 ff ff       	call   f0101057 <page_insert>
f0101ed8:	85 c0                	test   %eax,%eax
f0101eda:	78 24                	js     f0101f00 <mem_init+0xe13>
f0101edc:	c7 44 24 0c f4 45 10 	movl   $0xf01045f4,0xc(%esp)
f0101ee3:	f0 
f0101ee4:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101eeb:	f0 
f0101eec:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101ef3:	00 
f0101ef4:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101efb:	e8 94 e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f00:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f07:	00 
f0101f08:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f0f:	00 
f0101f10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f14:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f19:	89 04 24             	mov    %eax,(%esp)
f0101f1c:	e8 36 f1 ff ff       	call   f0101057 <page_insert>
f0101f21:	85 c0                	test   %eax,%eax
f0101f23:	74 24                	je     f0101f49 <mem_init+0xe5c>
f0101f25:	c7 44 24 0c 2c 46 10 	movl   $0xf010462c,0xc(%esp)
f0101f2c:	f0 
f0101f2d:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101f34:	f0 
f0101f35:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101f3c:	00 
f0101f3d:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101f44:	e8 4b e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f50:	00 
f0101f51:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f58:	00 
f0101f59:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f5e:	89 04 24             	mov    %eax,(%esp)
f0101f61:	e8 9f ef ff ff       	call   f0100f05 <pgdir_walk>
f0101f66:	f6 00 04             	testb  $0x4,(%eax)
f0101f69:	74 24                	je     f0101f8f <mem_init+0xea2>
f0101f6b:	c7 44 24 0c bc 45 10 	movl   $0xf01045bc,0xc(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101f82:	00 
f0101f83:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101f8a:	e8 05 e1 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f8f:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101f95:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9a:	89 f8                	mov    %edi,%eax
f0101f9c:	e8 d5 e9 ff ff       	call   f0100976 <check_va2pa>
f0101fa1:	89 c1                	mov    %eax,%ecx
f0101fa3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fa6:	89 d8                	mov    %ebx,%eax
f0101fa8:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101fae:	c1 f8 03             	sar    $0x3,%eax
f0101fb1:	c1 e0 0c             	shl    $0xc,%eax
f0101fb4:	39 c1                	cmp    %eax,%ecx
f0101fb6:	74 24                	je     f0101fdc <mem_init+0xeef>
f0101fb8:	c7 44 24 0c 68 46 10 	movl   $0xf0104668,0xc(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101fc7:	f0 
f0101fc8:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101fcf:	00 
f0101fd0:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0101fd7:	e8 b8 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fdc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fe1:	89 f8                	mov    %edi,%eax
f0101fe3:	e8 8e e9 ff ff       	call   f0100976 <check_va2pa>
f0101fe8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101feb:	74 24                	je     f0102011 <mem_init+0xf24>
f0101fed:	c7 44 24 0c 94 46 10 	movl   $0xf0104694,0xc(%esp)
f0101ff4:	f0 
f0101ff5:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0101ffc:	f0 
f0101ffd:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0102004:	00 
f0102005:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010200c:	e8 83 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102011:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102016:	74 24                	je     f010203c <mem_init+0xf4f>
f0102018:	c7 44 24 0c 3b 4b 10 	movl   $0xf0104b3b,0xc(%esp)
f010201f:	f0 
f0102020:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102027:	f0 
f0102028:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010202f:	00 
f0102030:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102037:	e8 58 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010203c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102041:	74 24                	je     f0102067 <mem_init+0xf7a>
f0102043:	c7 44 24 0c 4c 4b 10 	movl   $0xf0104b4c,0xc(%esp)
f010204a:	f0 
f010204b:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102052:	f0 
f0102053:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010205a:	00 
f010205b:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102062:	e8 2d e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102067:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010206e:	e8 a4 ed ff ff       	call   f0100e17 <page_alloc>
f0102073:	85 c0                	test   %eax,%eax
f0102075:	74 04                	je     f010207b <mem_init+0xf8e>
f0102077:	39 c6                	cmp    %eax,%esi
f0102079:	74 24                	je     f010209f <mem_init+0xfb2>
f010207b:	c7 44 24 0c c4 46 10 	movl   $0xf01046c4,0xc(%esp)
f0102082:	f0 
f0102083:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010208a:	f0 
f010208b:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102092:	00 
f0102093:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010209a:	e8 f5 df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010209f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020a6:	00 
f01020a7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020ac:	89 04 24             	mov    %eax,(%esp)
f01020af:	e8 5e ef ff ff       	call   f0101012 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020b4:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f01020ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01020bf:	89 f8                	mov    %edi,%eax
f01020c1:	e8 b0 e8 ff ff       	call   f0100976 <check_va2pa>
f01020c6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020c9:	74 24                	je     f01020ef <mem_init+0x1002>
f01020cb:	c7 44 24 0c e8 46 10 	movl   $0xf01046e8,0xc(%esp)
f01020d2:	f0 
f01020d3:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01020da:	f0 
f01020db:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f01020e2:	00 
f01020e3:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01020ea:	e8 a5 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020ef:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020f4:	89 f8                	mov    %edi,%eax
f01020f6:	e8 7b e8 ff ff       	call   f0100976 <check_va2pa>
f01020fb:	89 da                	mov    %ebx,%edx
f01020fd:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102103:	c1 fa 03             	sar    $0x3,%edx
f0102106:	c1 e2 0c             	shl    $0xc,%edx
f0102109:	39 d0                	cmp    %edx,%eax
f010210b:	74 24                	je     f0102131 <mem_init+0x1044>
f010210d:	c7 44 24 0c 94 46 10 	movl   $0xf0104694,0xc(%esp)
f0102114:	f0 
f0102115:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010211c:	f0 
f010211d:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102124:	00 
f0102125:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010212c:	e8 63 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102131:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102136:	74 24                	je     f010215c <mem_init+0x106f>
f0102138:	c7 44 24 0c f2 4a 10 	movl   $0xf0104af2,0xc(%esp)
f010213f:	f0 
f0102140:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102147:	f0 
f0102148:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f010214f:	00 
f0102150:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102157:	e8 38 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010215c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102161:	74 24                	je     f0102187 <mem_init+0x109a>
f0102163:	c7 44 24 0c 4c 4b 10 	movl   $0xf0104b4c,0xc(%esp)
f010216a:	f0 
f010216b:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102172:	f0 
f0102173:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f010217a:	00 
f010217b:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102182:	e8 0d df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102187:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010218e:	00 
f010218f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102196:	00 
f0102197:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010219b:	89 3c 24             	mov    %edi,(%esp)
f010219e:	e8 b4 ee ff ff       	call   f0101057 <page_insert>
f01021a3:	85 c0                	test   %eax,%eax
f01021a5:	74 24                	je     f01021cb <mem_init+0x10de>
f01021a7:	c7 44 24 0c 0c 47 10 	movl   $0xf010470c,0xc(%esp)
f01021ae:	f0 
f01021af:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01021b6:	f0 
f01021b7:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01021be:	00 
f01021bf:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01021c6:	e8 c9 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01021cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021d0:	75 24                	jne    f01021f6 <mem_init+0x1109>
f01021d2:	c7 44 24 0c 5d 4b 10 	movl   $0xf0104b5d,0xc(%esp)
f01021d9:	f0 
f01021da:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01021e1:	f0 
f01021e2:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01021e9:	00 
f01021ea:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01021f1:	e8 9e de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f01021f6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021f9:	74 24                	je     f010221f <mem_init+0x1132>
f01021fb:	c7 44 24 0c 69 4b 10 	movl   $0xf0104b69,0xc(%esp)
f0102202:	f0 
f0102203:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010220a:	f0 
f010220b:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102212:	00 
f0102213:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010221a:	e8 75 de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010221f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102226:	00 
f0102227:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010222c:	89 04 24             	mov    %eax,(%esp)
f010222f:	e8 de ed ff ff       	call   f0101012 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102234:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f010223a:	ba 00 00 00 00       	mov    $0x0,%edx
f010223f:	89 f8                	mov    %edi,%eax
f0102241:	e8 30 e7 ff ff       	call   f0100976 <check_va2pa>
f0102246:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102249:	74 24                	je     f010226f <mem_init+0x1182>
f010224b:	c7 44 24 0c e8 46 10 	movl   $0xf01046e8,0xc(%esp)
f0102252:	f0 
f0102253:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010225a:	f0 
f010225b:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0102262:	00 
f0102263:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010226a:	e8 25 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010226f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102274:	89 f8                	mov    %edi,%eax
f0102276:	e8 fb e6 ff ff       	call   f0100976 <check_va2pa>
f010227b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010227e:	74 24                	je     f01022a4 <mem_init+0x11b7>
f0102280:	c7 44 24 0c 44 47 10 	movl   $0xf0104744,0xc(%esp)
f0102287:	f0 
f0102288:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010228f:	f0 
f0102290:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0102297:	00 
f0102298:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010229f:	e8 f0 dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01022a4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a9:	74 24                	je     f01022cf <mem_init+0x11e2>
f01022ab:	c7 44 24 0c 7e 4b 10 	movl   $0xf0104b7e,0xc(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01022ba:	f0 
f01022bb:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f01022c2:	00 
f01022c3:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01022ca:	e8 c5 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01022cf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022d4:	74 24                	je     f01022fa <mem_init+0x120d>
f01022d6:	c7 44 24 0c 4c 4b 10 	movl   $0xf0104b4c,0xc(%esp)
f01022dd:	f0 
f01022de:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01022e5:	f0 
f01022e6:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01022ed:	00 
f01022ee:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01022f5:	e8 9a dd ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102301:	e8 11 eb ff ff       	call   f0100e17 <page_alloc>
f0102306:	85 c0                	test   %eax,%eax
f0102308:	74 04                	je     f010230e <mem_init+0x1221>
f010230a:	39 c3                	cmp    %eax,%ebx
f010230c:	74 24                	je     f0102332 <mem_init+0x1245>
f010230e:	c7 44 24 0c 6c 47 10 	movl   $0xf010476c,0xc(%esp)
f0102315:	f0 
f0102316:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010231d:	f0 
f010231e:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102325:	00 
f0102326:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010232d:	e8 62 dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102332:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102339:	e8 d9 ea ff ff       	call   f0100e17 <page_alloc>
f010233e:	85 c0                	test   %eax,%eax
f0102340:	74 24                	je     f0102366 <mem_init+0x1279>
f0102342:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f0102349:	f0 
f010234a:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102351:	f0 
f0102352:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0102359:	00 
f010235a:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102361:	e8 2e dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102366:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010236b:	8b 08                	mov    (%eax),%ecx
f010236d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102373:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102376:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f010237c:	c1 fa 03             	sar    $0x3,%edx
f010237f:	c1 e2 0c             	shl    $0xc,%edx
f0102382:	39 d1                	cmp    %edx,%ecx
f0102384:	74 24                	je     f01023aa <mem_init+0x12bd>
f0102386:	c7 44 24 0c 10 44 10 	movl   $0xf0104410,0xc(%esp)
f010238d:	f0 
f010238e:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102395:	f0 
f0102396:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010239d:	00 
f010239e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01023a5:	e8 ea dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01023aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b3:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023b8:	74 24                	je     f01023de <mem_init+0x12f1>
f01023ba:	c7 44 24 0c 03 4b 10 	movl   $0xf0104b03,0xc(%esp)
f01023c1:	f0 
f01023c2:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01023c9:	f0 
f01023ca:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01023d1:	00 
f01023d2:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01023d9:	e8 b6 dc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01023de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023e1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023e7:	89 04 24             	mov    %eax,(%esp)
f01023ea:	e8 b3 ea ff ff       	call   f0100ea2 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01023f6:	00 
f01023f7:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01023fe:	00 
f01023ff:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102404:	89 04 24             	mov    %eax,(%esp)
f0102407:	e8 f9 ea ff ff       	call   f0100f05 <pgdir_walk>
f010240c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010240f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102412:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0102418:	8b 7a 04             	mov    0x4(%edx),%edi
f010241b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102421:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f0102427:	89 f8                	mov    %edi,%eax
f0102429:	c1 e8 0c             	shr    $0xc,%eax
f010242c:	39 c8                	cmp    %ecx,%eax
f010242e:	72 20                	jb     f0102450 <mem_init+0x1363>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102430:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102434:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f010243b:	f0 
f010243c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102443:	00 
f0102444:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010244b:	e8 44 dc ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102450:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102456:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102459:	74 24                	je     f010247f <mem_init+0x1392>
f010245b:	c7 44 24 0c 8f 4b 10 	movl   $0xf0104b8f,0xc(%esp)
f0102462:	f0 
f0102463:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010246a:	f0 
f010246b:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102472:	00 
f0102473:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010247a:	e8 15 dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010247f:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102486:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102489:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010248f:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102495:	c1 f8 03             	sar    $0x3,%eax
f0102498:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010249b:	89 c2                	mov    %eax,%edx
f010249d:	c1 ea 0c             	shr    $0xc,%edx
f01024a0:	39 d1                	cmp    %edx,%ecx
f01024a2:	77 20                	ja     f01024c4 <mem_init+0x13d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024a8:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f01024af:	f0 
f01024b0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024b7:	00 
f01024b8:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f01024bf:	e8 d0 db ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024cb:	00 
f01024cc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024d3:	00 
	return (void *)(pa + KERNBASE);
f01024d4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024d9:	89 04 24             	mov    %eax,(%esp)
f01024dc:	e8 46 13 00 00       	call   f0103827 <memset>
	page_free(pp0);
f01024e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01024e4:	89 3c 24             	mov    %edi,(%esp)
f01024e7:	e8 b6 e9 ff ff       	call   f0100ea2 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01024ec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01024f3:	00 
f01024f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024fb:	00 
f01024fc:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102501:	89 04 24             	mov    %eax,(%esp)
f0102504:	e8 fc e9 ff ff       	call   f0100f05 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102509:	89 fa                	mov    %edi,%edx
f010250b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102511:	c1 fa 03             	sar    $0x3,%edx
f0102514:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102517:	89 d0                	mov    %edx,%eax
f0102519:	c1 e8 0c             	shr    $0xc,%eax
f010251c:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0102522:	72 20                	jb     f0102544 <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102524:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102528:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f010252f:	f0 
f0102530:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102537:	00 
f0102538:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f010253f:	e8 50 db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102544:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010254a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010254d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102553:	f6 00 01             	testb  $0x1,(%eax)
f0102556:	74 24                	je     f010257c <mem_init+0x148f>
f0102558:	c7 44 24 0c a7 4b 10 	movl   $0xf0104ba7,0xc(%esp)
f010255f:	f0 
f0102560:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102567:	f0 
f0102568:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010256f:	00 
f0102570:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102577:	e8 18 db ff ff       	call   f0100094 <_panic>
f010257c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010257f:	39 d0                	cmp    %edx,%eax
f0102581:	75 d0                	jne    f0102553 <mem_init+0x1466>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102583:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102588:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010258e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102591:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102597:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010259a:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f01025a0:	89 04 24             	mov    %eax,(%esp)
f01025a3:	e8 fa e8 ff ff       	call   f0100ea2 <page_free>
	page_free(pp1);
f01025a8:	89 1c 24             	mov    %ebx,(%esp)
f01025ab:	e8 f2 e8 ff ff       	call   f0100ea2 <page_free>
	page_free(pp2);
f01025b0:	89 34 24             	mov    %esi,(%esp)
f01025b3:	e8 ea e8 ff ff       	call   f0100ea2 <page_free>

	cprintf("check_page() succeeded!\n");
f01025b8:	c7 04 24 be 4b 10 f0 	movl   $0xf0104bbe,(%esp)
f01025bf:	e8 1c 07 00 00       	call   f0102ce0 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01025c4:	8b 35 68 79 11 f0    	mov    0xf0117968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025ca:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01025cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025d2:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01025d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01025de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025e1:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01025e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01025ec:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01025f7:	eb 6a                	jmp    f0102663 <mem_init+0x1576>
f01025f9:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025ff:	89 f0                	mov    %esi,%eax
f0102601:	e8 70 e3 ff ff       	call   f0100976 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102606:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010260d:	77 23                	ja     f0102632 <mem_init+0x1545>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010260f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102612:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102616:	c7 44 24 08 14 43 10 	movl   $0xf0104314,0x8(%esp)
f010261d:	f0 
f010261e:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102625:	00 
f0102626:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010262d:	e8 62 da ff ff       	call   f0100094 <_panic>
f0102632:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102635:	39 c2                	cmp    %eax,%edx
f0102637:	74 24                	je     f010265d <mem_init+0x1570>
f0102639:	c7 44 24 0c 90 47 10 	movl   $0xf0104790,0xc(%esp)
f0102640:	f0 
f0102641:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102648:	f0 
f0102649:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102650:	00 
f0102651:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102658:	e8 37 da ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010265d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102663:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102666:	77 91                	ja     f01025f9 <mem_init+0x150c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102668:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010266b:	c1 e7 0c             	shl    $0xc,%edi
f010266e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102673:	eb 3b                	jmp    f01026b0 <mem_init+0x15c3>
f0102675:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010267b:	89 f0                	mov    %esi,%eax
f010267d:	e8 f4 e2 ff ff       	call   f0100976 <check_va2pa>
f0102682:	39 c3                	cmp    %eax,%ebx
f0102684:	74 24                	je     f01026aa <mem_init+0x15bd>
f0102686:	c7 44 24 0c c4 47 10 	movl   $0xf01047c4,0xc(%esp)
f010268d:	f0 
f010268e:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102695:	f0 
f0102696:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f010269d:	00 
f010269e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01026a5:	e8 ea d9 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026b0:	39 fb                	cmp    %edi,%ebx
f01026b2:	72 c1                	jb     f0102675 <mem_init+0x1588>
f01026b4:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026b9:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026be:	89 da                	mov    %ebx,%edx
f01026c0:	89 f0                	mov    %esi,%eax
f01026c2:	e8 af e2 ff ff       	call   f0100976 <check_va2pa>
f01026c7:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01026cd:	77 24                	ja     f01026f3 <mem_init+0x1606>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026cf:	c7 44 24 0c 00 d0 10 	movl   $0xf010d000,0xc(%esp)
f01026d6:	f0 
f01026d7:	c7 44 24 08 14 43 10 	movl   $0xf0104314,0x8(%esp)
f01026de:	f0 
f01026df:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f01026e6:	00 
f01026e7:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01026ee:	e8 a1 d9 ff ff       	call   f0100094 <_panic>
f01026f3:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f01026f9:	39 d0                	cmp    %edx,%eax
f01026fb:	74 24                	je     f0102721 <mem_init+0x1634>
f01026fd:	c7 44 24 0c ec 47 10 	movl   $0xf01047ec,0xc(%esp)
f0102704:	f0 
f0102705:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010270c:	f0 
f010270d:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0102714:	00 
f0102715:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010271c:	e8 73 d9 ff ff       	call   f0100094 <_panic>
f0102721:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102727:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010272d:	75 8f                	jne    f01026be <mem_init+0x15d1>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010272f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102734:	89 f0                	mov    %esi,%eax
f0102736:	e8 3b e2 ff ff       	call   f0100976 <check_va2pa>
f010273b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010273e:	75 0a                	jne    f010274a <mem_init+0x165d>
f0102740:	b8 00 00 00 00       	mov    $0x0,%eax
f0102745:	e9 f0 00 00 00       	jmp    f010283a <mem_init+0x174d>
f010274a:	c7 44 24 0c 34 48 10 	movl   $0xf0104834,0xc(%esp)
f0102751:	f0 
f0102752:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102759:	f0 
f010275a:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0102761:	00 
f0102762:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102769:	e8 26 d9 ff ff       	call   f0100094 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010276e:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102773:	72 3c                	jb     f01027b1 <mem_init+0x16c4>
f0102775:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010277a:	76 07                	jbe    f0102783 <mem_init+0x1696>
f010277c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102781:	75 2e                	jne    f01027b1 <mem_init+0x16c4>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102783:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102787:	0f 85 aa 00 00 00    	jne    f0102837 <mem_init+0x174a>
f010278d:	c7 44 24 0c d7 4b 10 	movl   $0xf0104bd7,0xc(%esp)
f0102794:	f0 
f0102795:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010279c:	f0 
f010279d:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f01027a4:	00 
f01027a5:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01027ac:	e8 e3 d8 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027b1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027b6:	76 55                	jbe    f010280d <mem_init+0x1720>
				assert(pgdir[i] & PTE_P);
f01027b8:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01027bb:	f6 c2 01             	test   $0x1,%dl
f01027be:	75 24                	jne    f01027e4 <mem_init+0x16f7>
f01027c0:	c7 44 24 0c d7 4b 10 	movl   $0xf0104bd7,0xc(%esp)
f01027c7:	f0 
f01027c8:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01027cf:	f0 
f01027d0:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01027d7:	00 
f01027d8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01027df:	e8 b0 d8 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f01027e4:	f6 c2 02             	test   $0x2,%dl
f01027e7:	75 4e                	jne    f0102837 <mem_init+0x174a>
f01027e9:	c7 44 24 0c e8 4b 10 	movl   $0xf0104be8,0xc(%esp)
f01027f0:	f0 
f01027f1:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01027f8:	f0 
f01027f9:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0102800:	00 
f0102801:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102808:	e8 87 d8 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f010280d:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102811:	74 24                	je     f0102837 <mem_init+0x174a>
f0102813:	c7 44 24 0c f9 4b 10 	movl   $0xf0104bf9,0xc(%esp)
f010281a:	f0 
f010281b:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102822:	f0 
f0102823:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f010282a:	00 
f010282b:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102832:	e8 5d d8 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102837:	83 c0 01             	add    $0x1,%eax
f010283a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010283f:	0f 85 29 ff ff ff    	jne    f010276e <mem_init+0x1681>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102845:	c7 04 24 64 48 10 f0 	movl   $0xf0104864,(%esp)
f010284c:	e8 8f 04 00 00       	call   f0102ce0 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102851:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102856:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010285b:	77 20                	ja     f010287d <mem_init+0x1790>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102861:	c7 44 24 08 14 43 10 	movl   $0xf0104314,0x8(%esp)
f0102868:	f0 
f0102869:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f0102870:	00 
f0102871:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102878:	e8 17 d8 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010287d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102882:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102885:	b8 00 00 00 00       	mov    $0x0,%eax
f010288a:	e8 56 e1 ff ff       	call   f01009e5 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010288f:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102892:	83 e0 f3             	and    $0xfffffff3,%eax
f0102895:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010289a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010289d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028a4:	e8 6e e5 ff ff       	call   f0100e17 <page_alloc>
f01028a9:	89 c3                	mov    %eax,%ebx
f01028ab:	85 c0                	test   %eax,%eax
f01028ad:	75 24                	jne    f01028d3 <mem_init+0x17e6>
f01028af:	c7 44 24 0c f5 49 10 	movl   $0xf01049f5,0xc(%esp)
f01028b6:	f0 
f01028b7:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01028be:	f0 
f01028bf:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01028c6:	00 
f01028c7:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f01028ce:	e8 c1 d7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01028d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028da:	e8 38 e5 ff ff       	call   f0100e17 <page_alloc>
f01028df:	89 c7                	mov    %eax,%edi
f01028e1:	85 c0                	test   %eax,%eax
f01028e3:	75 24                	jne    f0102909 <mem_init+0x181c>
f01028e5:	c7 44 24 0c 0b 4a 10 	movl   $0xf0104a0b,0xc(%esp)
f01028ec:	f0 
f01028ed:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f01028f4:	f0 
f01028f5:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01028fc:	00 
f01028fd:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102904:	e8 8b d7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102909:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102910:	e8 02 e5 ff ff       	call   f0100e17 <page_alloc>
f0102915:	89 c6                	mov    %eax,%esi
f0102917:	85 c0                	test   %eax,%eax
f0102919:	75 24                	jne    f010293f <mem_init+0x1852>
f010291b:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f0102922:	f0 
f0102923:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f010292a:	f0 
f010292b:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102932:	00 
f0102933:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f010293a:	e8 55 d7 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f010293f:	89 1c 24             	mov    %ebx,(%esp)
f0102942:	e8 5b e5 ff ff       	call   f0100ea2 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102947:	89 f8                	mov    %edi,%eax
f0102949:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010294f:	c1 f8 03             	sar    $0x3,%eax
f0102952:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102955:	89 c2                	mov    %eax,%edx
f0102957:	c1 ea 0c             	shr    $0xc,%edx
f010295a:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102960:	72 20                	jb     f0102982 <mem_init+0x1895>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102962:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102966:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f010296d:	f0 
f010296e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102975:	00 
f0102976:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f010297d:	e8 12 d7 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102982:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102989:	00 
f010298a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102991:	00 
	return (void *)(pa + KERNBASE);
f0102992:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102997:	89 04 24             	mov    %eax,(%esp)
f010299a:	e8 88 0e 00 00       	call   f0103827 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010299f:	89 f0                	mov    %esi,%eax
f01029a1:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01029a7:	c1 f8 03             	sar    $0x3,%eax
f01029aa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ad:	89 c2                	mov    %eax,%edx
f01029af:	c1 ea 0c             	shr    $0xc,%edx
f01029b2:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01029b8:	72 20                	jb     f01029da <mem_init+0x18ed>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029be:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f01029c5:	f0 
f01029c6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01029cd:	00 
f01029ce:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f01029d5:	e8 ba d6 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029da:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029e1:	00 
f01029e2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01029e9:	00 
	return (void *)(pa + KERNBASE);
f01029ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029ef:	89 04 24             	mov    %eax,(%esp)
f01029f2:	e8 30 0e 00 00       	call   f0103827 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029f7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01029fe:	00 
f01029ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a06:	00 
f0102a07:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102a0b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102a10:	89 04 24             	mov    %eax,(%esp)
f0102a13:	e8 3f e6 ff ff       	call   f0101057 <page_insert>
	assert(pp1->pp_ref == 1);
f0102a18:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a1d:	74 24                	je     f0102a43 <mem_init+0x1956>
f0102a1f:	c7 44 24 0c f2 4a 10 	movl   $0xf0104af2,0xc(%esp)
f0102a26:	f0 
f0102a27:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102a36:	00 
f0102a37:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102a3e:	e8 51 d6 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a43:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a4a:	01 01 01 
f0102a4d:	74 24                	je     f0102a73 <mem_init+0x1986>
f0102a4f:	c7 44 24 0c 84 48 10 	movl   $0xf0104884,0xc(%esp)
f0102a56:	f0 
f0102a57:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102a5e:	f0 
f0102a5f:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102a66:	00 
f0102a67:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102a6e:	e8 21 d6 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a73:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102a7a:	00 
f0102a7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a82:	00 
f0102a83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a87:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102a8c:	89 04 24             	mov    %eax,(%esp)
f0102a8f:	e8 c3 e5 ff ff       	call   f0101057 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a94:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a9b:	02 02 02 
f0102a9e:	74 24                	je     f0102ac4 <mem_init+0x19d7>
f0102aa0:	c7 44 24 0c a8 48 10 	movl   $0xf01048a8,0xc(%esp)
f0102aa7:	f0 
f0102aa8:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102aaf:	f0 
f0102ab0:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102ab7:	00 
f0102ab8:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102abf:	e8 d0 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102ac4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ac9:	74 24                	je     f0102aef <mem_init+0x1a02>
f0102acb:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0102ad2:	f0 
f0102ad3:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102ada:	f0 
f0102adb:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102ae2:	00 
f0102ae3:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102aea:	e8 a5 d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102aef:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102af4:	74 24                	je     f0102b1a <mem_init+0x1a2d>
f0102af6:	c7 44 24 0c 7e 4b 10 	movl   $0xf0104b7e,0xc(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102b0d:	00 
f0102b0e:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102b15:	e8 7a d5 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b1a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b21:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b24:	89 f0                	mov    %esi,%eax
f0102b26:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102b2c:	c1 f8 03             	sar    $0x3,%eax
f0102b2f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b32:	89 c2                	mov    %eax,%edx
f0102b34:	c1 ea 0c             	shr    $0xc,%edx
f0102b37:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102b3d:	72 20                	jb     f0102b5f <mem_init+0x1a72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b43:	c7 44 24 08 90 41 10 	movl   $0xf0104190,0x8(%esp)
f0102b4a:	f0 
f0102b4b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102b52:	00 
f0102b53:	c7 04 24 30 49 10 f0 	movl   $0xf0104930,(%esp)
f0102b5a:	e8 35 d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b5f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b66:	03 03 03 
f0102b69:	74 24                	je     f0102b8f <mem_init+0x1aa2>
f0102b6b:	c7 44 24 0c cc 48 10 	movl   $0xf01048cc,0xc(%esp)
f0102b72:	f0 
f0102b73:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102b7a:	f0 
f0102b7b:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102b82:	00 
f0102b83:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102b8a:	e8 05 d5 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b8f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b96:	00 
f0102b97:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102b9c:	89 04 24             	mov    %eax,(%esp)
f0102b9f:	e8 6e e4 ff ff       	call   f0101012 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ba4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ba9:	74 24                	je     f0102bcf <mem_init+0x1ae2>
f0102bab:	c7 44 24 0c 4c 4b 10 	movl   $0xf0104b4c,0xc(%esp)
f0102bb2:	f0 
f0102bb3:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102bba:	f0 
f0102bbb:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102bc2:	00 
f0102bc3:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102bca:	e8 c5 d4 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bcf:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102bd4:	8b 08                	mov    (%eax),%ecx
f0102bd6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bdc:	89 da                	mov    %ebx,%edx
f0102bde:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102be4:	c1 fa 03             	sar    $0x3,%edx
f0102be7:	c1 e2 0c             	shl    $0xc,%edx
f0102bea:	39 d1                	cmp    %edx,%ecx
f0102bec:	74 24                	je     f0102c12 <mem_init+0x1b25>
f0102bee:	c7 44 24 0c 10 44 10 	movl   $0xf0104410,0xc(%esp)
f0102bf5:	f0 
f0102bf6:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0102c05:	00 
f0102c06:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102c0d:	e8 82 d4 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102c12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c18:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c1d:	74 24                	je     f0102c43 <mem_init+0x1b56>
f0102c1f:	c7 44 24 0c 03 4b 10 	movl   $0xf0104b03,0xc(%esp)
f0102c26:	f0 
f0102c27:	c7 44 24 08 4a 49 10 	movl   $0xf010494a,0x8(%esp)
f0102c2e:	f0 
f0102c2f:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102c36:	00 
f0102c37:	c7 04 24 24 49 10 f0 	movl   $0xf0104924,(%esp)
f0102c3e:	e8 51 d4 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102c43:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102c49:	89 1c 24             	mov    %ebx,(%esp)
f0102c4c:	e8 51 e2 ff ff       	call   f0100ea2 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c51:	c7 04 24 f8 48 10 f0 	movl   $0xf01048f8,(%esp)
f0102c58:	e8 83 00 00 00       	call   f0102ce0 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c5d:	83 c4 3c             	add    $0x3c,%esp
f0102c60:	5b                   	pop    %ebx
f0102c61:	5e                   	pop    %esi
f0102c62:	5f                   	pop    %edi
f0102c63:	5d                   	pop    %ebp
f0102c64:	c3                   	ret    

f0102c65 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102c65:	55                   	push   %ebp
f0102c66:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102c68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c6b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102c6e:	5d                   	pop    %ebp
f0102c6f:	c3                   	ret    

f0102c70 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102c70:	55                   	push   %ebp
f0102c71:	89 e5                	mov    %esp,%ebp
f0102c73:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c77:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c7c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102c7d:	b2 71                	mov    $0x71,%dl
f0102c7f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102c80:	0f b6 c0             	movzbl %al,%eax
}
f0102c83:	5d                   	pop    %ebp
f0102c84:	c3                   	ret    

f0102c85 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102c85:	55                   	push   %ebp
f0102c86:	89 e5                	mov    %esp,%ebp
f0102c88:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c8c:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c91:	ee                   	out    %al,(%dx)
f0102c92:	b2 71                	mov    $0x71,%dl
f0102c94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c97:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c98:	5d                   	pop    %ebp
f0102c99:	c3                   	ret    

f0102c9a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c9a:	55                   	push   %ebp
f0102c9b:	89 e5                	mov    %esp,%ebp
f0102c9d:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102ca0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ca3:	89 04 24             	mov    %eax,(%esp)
f0102ca6:	e8 46 d9 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0102cab:	c9                   	leave  
f0102cac:	c3                   	ret    

f0102cad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102cad:	55                   	push   %ebp
f0102cae:	89 e5                	mov    %esp,%ebp
f0102cb0:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102cb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102cba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102cc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ccf:	c7 04 24 9a 2c 10 f0 	movl   $0xf0102c9a,(%esp)
f0102cd6:	e8 09 04 00 00       	call   f01030e4 <vprintfmt>
	return cnt;
}
f0102cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cde:	c9                   	leave  
f0102cdf:	c3                   	ret    

f0102ce0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ce0:	55                   	push   %ebp
f0102ce1:	89 e5                	mov    %esp,%ebp
f0102ce3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102ce6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ced:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cf0:	89 04 24             	mov    %eax,(%esp)
f0102cf3:	e8 b5 ff ff ff       	call   f0102cad <vcprintf>
	va_end(ap);

	return cnt;
}
f0102cf8:	c9                   	leave  
f0102cf9:	c3                   	ret    

f0102cfa <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102cfa:	55                   	push   %ebp
f0102cfb:	89 e5                	mov    %esp,%ebp
f0102cfd:	57                   	push   %edi
f0102cfe:	56                   	push   %esi
f0102cff:	53                   	push   %ebx
f0102d00:	83 ec 10             	sub    $0x10,%esp
f0102d03:	89 c6                	mov    %eax,%esi
f0102d05:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102d08:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d0e:	8b 1a                	mov    (%edx),%ebx
f0102d10:	8b 01                	mov    (%ecx),%eax
f0102d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d15:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102d1c:	eb 77                	jmp    f0102d95 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0102d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d21:	01 d8                	add    %ebx,%eax
f0102d23:	b9 02 00 00 00       	mov    $0x2,%ecx
f0102d28:	99                   	cltd   
f0102d29:	f7 f9                	idiv   %ecx
f0102d2b:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d2d:	eb 01                	jmp    f0102d30 <stab_binsearch+0x36>
			m--;
f0102d2f:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d30:	39 d9                	cmp    %ebx,%ecx
f0102d32:	7c 1d                	jl     f0102d51 <stab_binsearch+0x57>
f0102d34:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102d37:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102d3c:	39 fa                	cmp    %edi,%edx
f0102d3e:	75 ef                	jne    f0102d2f <stab_binsearch+0x35>
f0102d40:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102d43:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102d46:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0102d4a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102d4d:	73 18                	jae    f0102d67 <stab_binsearch+0x6d>
f0102d4f:	eb 05                	jmp    f0102d56 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102d51:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0102d54:	eb 3f                	jmp    f0102d95 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102d56:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d59:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0102d5b:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d5e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102d65:	eb 2e                	jmp    f0102d95 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102d67:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102d6a:	73 15                	jae    f0102d81 <stab_binsearch+0x87>
			*region_right = m - 1;
f0102d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d6f:	48                   	dec    %eax
f0102d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d73:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102d76:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d78:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102d7f:	eb 14                	jmp    f0102d95 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102d81:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102d84:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102d87:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0102d89:	ff 45 0c             	incl   0xc(%ebp)
f0102d8c:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d8e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d95:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102d98:	7e 84                	jle    f0102d1e <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d9a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d9e:	75 0d                	jne    f0102dad <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0102da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102da3:	8b 00                	mov    (%eax),%eax
f0102da5:	48                   	dec    %eax
f0102da6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102da9:	89 07                	mov    %eax,(%edi)
f0102dab:	eb 22                	jmp    f0102dcf <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102db0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102db2:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102db5:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102db7:	eb 01                	jmp    f0102dba <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102db9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102dba:	39 c1                	cmp    %eax,%ecx
f0102dbc:	7d 0c                	jge    f0102dca <stab_binsearch+0xd0>
f0102dbe:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0102dc1:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102dc6:	39 fa                	cmp    %edi,%edx
f0102dc8:	75 ef                	jne    f0102db9 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102dca:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0102dcd:	89 07                	mov    %eax,(%edi)
	}
}
f0102dcf:	83 c4 10             	add    $0x10,%esp
f0102dd2:	5b                   	pop    %ebx
f0102dd3:	5e                   	pop    %esi
f0102dd4:	5f                   	pop    %edi
f0102dd5:	5d                   	pop    %ebp
f0102dd6:	c3                   	ret    

f0102dd7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102dd7:	55                   	push   %ebp
f0102dd8:	89 e5                	mov    %esp,%ebp
f0102dda:	57                   	push   %edi
f0102ddb:	56                   	push   %esi
f0102ddc:	53                   	push   %ebx
f0102ddd:	83 ec 2c             	sub    $0x2c,%esp
f0102de0:	8b 75 08             	mov    0x8(%ebp),%esi
f0102de3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102de6:	c7 03 07 4c 10 f0    	movl   $0xf0104c07,(%ebx)
	info->eip_line = 0;
f0102dec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102df3:	c7 43 08 07 4c 10 f0 	movl   $0xf0104c07,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102dfa:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102e01:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102e04:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102e0b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e11:	76 12                	jbe    f0102e25 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e13:	b8 38 c8 10 f0       	mov    $0xf010c838,%eax
f0102e18:	3d b5 aa 10 f0       	cmp    $0xf010aab5,%eax
f0102e1d:	0f 86 6b 01 00 00    	jbe    f0102f8e <debuginfo_eip+0x1b7>
f0102e23:	eb 1c                	jmp    f0102e41 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102e25:	c7 44 24 08 11 4c 10 	movl   $0xf0104c11,0x8(%esp)
f0102e2c:	f0 
f0102e2d:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102e34:	00 
f0102e35:	c7 04 24 1e 4c 10 f0 	movl   $0xf0104c1e,(%esp)
f0102e3c:	e8 53 d2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e41:	80 3d 37 c8 10 f0 00 	cmpb   $0x0,0xf010c837
f0102e48:	0f 85 47 01 00 00    	jne    f0102f95 <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102e4e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102e55:	b8 b4 aa 10 f0       	mov    $0xf010aab4,%eax
f0102e5a:	2d 50 4e 10 f0       	sub    $0xf0104e50,%eax
f0102e5f:	c1 f8 02             	sar    $0x2,%eax
f0102e62:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102e68:	83 e8 01             	sub    $0x1,%eax
f0102e6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102e6e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102e72:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102e79:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102e7c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102e7f:	b8 50 4e 10 f0       	mov    $0xf0104e50,%eax
f0102e84:	e8 71 fe ff ff       	call   f0102cfa <stab_binsearch>
	if (lfile == 0)
f0102e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e8c:	85 c0                	test   %eax,%eax
f0102e8e:	0f 84 08 01 00 00    	je     f0102f9c <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e94:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102e9d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ea1:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102ea8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102eab:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102eae:	b8 50 4e 10 f0       	mov    $0xf0104e50,%eax
f0102eb3:	e8 42 fe ff ff       	call   f0102cfa <stab_binsearch>

	if (lfun <= rfun) {
f0102eb8:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102ebb:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0102ebe:	7f 2e                	jg     f0102eee <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102ec0:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102ec3:	8d 90 50 4e 10 f0    	lea    -0xfefb1b0(%eax),%edx
f0102ec9:	8b 80 50 4e 10 f0    	mov    -0xfefb1b0(%eax),%eax
f0102ecf:	b9 38 c8 10 f0       	mov    $0xf010c838,%ecx
f0102ed4:	81 e9 b5 aa 10 f0    	sub    $0xf010aab5,%ecx
f0102eda:	39 c8                	cmp    %ecx,%eax
f0102edc:	73 08                	jae    f0102ee6 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102ede:	05 b5 aa 10 f0       	add    $0xf010aab5,%eax
f0102ee3:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102ee6:	8b 42 08             	mov    0x8(%edx),%eax
f0102ee9:	89 43 10             	mov    %eax,0x10(%ebx)
f0102eec:	eb 06                	jmp    f0102ef4 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102eee:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102ef1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102ef4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102efb:	00 
f0102efc:	8b 43 08             	mov    0x8(%ebx),%eax
f0102eff:	89 04 24             	mov    %eax,(%esp)
f0102f02:	e8 04 09 00 00       	call   f010380b <strfind>
f0102f07:	2b 43 08             	sub    0x8(%ebx),%eax
f0102f0a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f0d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102f10:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102f13:	05 50 4e 10 f0       	add    $0xf0104e50,%eax
f0102f18:	eb 06                	jmp    f0102f20 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102f1a:	83 ef 01             	sub    $0x1,%edi
f0102f1d:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f20:	39 cf                	cmp    %ecx,%edi
f0102f22:	7c 33                	jl     f0102f57 <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0102f24:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0102f28:	80 fa 84             	cmp    $0x84,%dl
f0102f2b:	74 0b                	je     f0102f38 <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f2d:	80 fa 64             	cmp    $0x64,%dl
f0102f30:	75 e8                	jne    f0102f1a <debuginfo_eip+0x143>
f0102f32:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102f36:	74 e2                	je     f0102f1a <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102f38:	6b ff 0c             	imul   $0xc,%edi,%edi
f0102f3b:	8b 87 50 4e 10 f0    	mov    -0xfefb1b0(%edi),%eax
f0102f41:	ba 38 c8 10 f0       	mov    $0xf010c838,%edx
f0102f46:	81 ea b5 aa 10 f0    	sub    $0xf010aab5,%edx
f0102f4c:	39 d0                	cmp    %edx,%eax
f0102f4e:	73 07                	jae    f0102f57 <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102f50:	05 b5 aa 10 f0       	add    $0xf010aab5,%eax
f0102f55:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f57:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102f5a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f5d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f62:	39 f1                	cmp    %esi,%ecx
f0102f64:	7d 42                	jge    f0102fa8 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f0102f66:	8d 51 01             	lea    0x1(%ecx),%edx
f0102f69:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0102f6c:	05 50 4e 10 f0       	add    $0xf0104e50,%eax
f0102f71:	eb 07                	jmp    f0102f7a <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102f73:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0102f77:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f7a:	39 f2                	cmp    %esi,%edx
f0102f7c:	74 25                	je     f0102fa3 <debuginfo_eip+0x1cc>
f0102f7e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102f81:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0102f85:	74 ec                	je     f0102f73 <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f87:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8c:	eb 1a                	jmp    f0102fa8 <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102f8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f93:	eb 13                	jmp    f0102fa8 <debuginfo_eip+0x1d1>
f0102f95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f9a:	eb 0c                	jmp    f0102fa8 <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102fa1:	eb 05                	jmp    f0102fa8 <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fa8:	83 c4 2c             	add    $0x2c,%esp
f0102fab:	5b                   	pop    %ebx
f0102fac:	5e                   	pop    %esi
f0102fad:	5f                   	pop    %edi
f0102fae:	5d                   	pop    %ebp
f0102faf:	c3                   	ret    

f0102fb0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102fb0:	55                   	push   %ebp
f0102fb1:	89 e5                	mov    %esp,%ebp
f0102fb3:	57                   	push   %edi
f0102fb4:	56                   	push   %esi
f0102fb5:	53                   	push   %ebx
f0102fb6:	83 ec 3c             	sub    $0x3c,%esp
f0102fb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102fbc:	89 d7                	mov    %edx,%edi
f0102fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc7:	89 c3                	mov    %eax,%ebx
f0102fc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102fcc:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fcf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fd7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102fda:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102fdd:	39 d9                	cmp    %ebx,%ecx
f0102fdf:	72 05                	jb     f0102fe6 <printnum+0x36>
f0102fe1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102fe4:	77 69                	ja     f010304f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102fe6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0102fe9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0102fed:	83 ee 01             	sub    $0x1,%esi
f0102ff0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102ff4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ff8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102ffc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103000:	89 c3                	mov    %eax,%ebx
f0103002:	89 d6                	mov    %edx,%esi
f0103004:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103007:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010300a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010300e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103012:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103015:	89 04 24             	mov    %eax,(%esp)
f0103018:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010301b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010301f:	e8 0c 0a 00 00       	call   f0103a30 <__udivdi3>
f0103024:	89 d9                	mov    %ebx,%ecx
f0103026:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010302a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010302e:	89 04 24             	mov    %eax,(%esp)
f0103031:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103035:	89 fa                	mov    %edi,%edx
f0103037:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010303a:	e8 71 ff ff ff       	call   f0102fb0 <printnum>
f010303f:	eb 1b                	jmp    f010305c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103041:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103045:	8b 45 18             	mov    0x18(%ebp),%eax
f0103048:	89 04 24             	mov    %eax,(%esp)
f010304b:	ff d3                	call   *%ebx
f010304d:	eb 03                	jmp    f0103052 <printnum+0xa2>
f010304f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103052:	83 ee 01             	sub    $0x1,%esi
f0103055:	85 f6                	test   %esi,%esi
f0103057:	7f e8                	jg     f0103041 <printnum+0x91>
f0103059:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010305c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103060:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103064:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103067:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010306a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010306e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103072:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103075:	89 04 24             	mov    %eax,(%esp)
f0103078:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010307b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010307f:	e8 dc 0a 00 00       	call   f0103b60 <__umoddi3>
f0103084:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103088:	0f be 80 2c 4c 10 f0 	movsbl -0xfefb3d4(%eax),%eax
f010308f:	89 04 24             	mov    %eax,(%esp)
f0103092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103095:	ff d0                	call   *%eax
}
f0103097:	83 c4 3c             	add    $0x3c,%esp
f010309a:	5b                   	pop    %ebx
f010309b:	5e                   	pop    %esi
f010309c:	5f                   	pop    %edi
f010309d:	5d                   	pop    %ebp
f010309e:	c3                   	ret    

f010309f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010309f:	55                   	push   %ebp
f01030a0:	89 e5                	mov    %esp,%ebp
f01030a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01030a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01030a9:	8b 10                	mov    (%eax),%edx
f01030ab:	3b 50 04             	cmp    0x4(%eax),%edx
f01030ae:	73 0a                	jae    f01030ba <sprintputch+0x1b>
		*b->buf++ = ch;
f01030b0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01030b3:	89 08                	mov    %ecx,(%eax)
f01030b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b8:	88 02                	mov    %al,(%edx)
}
f01030ba:	5d                   	pop    %ebp
f01030bb:	c3                   	ret    

f01030bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01030bc:	55                   	push   %ebp
f01030bd:	89 e5                	mov    %esp,%ebp
f01030bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01030c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01030c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030c9:	8b 45 10             	mov    0x10(%ebp),%eax
f01030cc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01030da:	89 04 24             	mov    %eax,(%esp)
f01030dd:	e8 02 00 00 00       	call   f01030e4 <vprintfmt>
	va_end(ap);
}
f01030e2:	c9                   	leave  
f01030e3:	c3                   	ret    

f01030e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01030e4:	55                   	push   %ebp
f01030e5:	89 e5                	mov    %esp,%ebp
f01030e7:	57                   	push   %edi
f01030e8:	56                   	push   %esi
f01030e9:	53                   	push   %ebx
f01030ea:	83 ec 3c             	sub    $0x3c,%esp
f01030ed:	8b 75 08             	mov    0x8(%ebp),%esi
f01030f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030f3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01030f6:	eb 11                	jmp    f0103109 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01030f8:	85 c0                	test   %eax,%eax
f01030fa:	0f 84 48 04 00 00    	je     f0103548 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0103100:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103104:	89 04 24             	mov    %eax,(%esp)
f0103107:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103109:	83 c7 01             	add    $0x1,%edi
f010310c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103110:	83 f8 25             	cmp    $0x25,%eax
f0103113:	75 e3                	jne    f01030f8 <vprintfmt+0x14>
f0103115:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103119:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103120:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103127:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010312e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103133:	eb 1f                	jmp    f0103154 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103135:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103138:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010313c:	eb 16                	jmp    f0103154 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010313e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103141:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103145:	eb 0d                	jmp    f0103154 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103147:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010314a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010314d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103154:	8d 47 01             	lea    0x1(%edi),%eax
f0103157:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010315a:	0f b6 17             	movzbl (%edi),%edx
f010315d:	0f b6 c2             	movzbl %dl,%eax
f0103160:	83 ea 23             	sub    $0x23,%edx
f0103163:	80 fa 55             	cmp    $0x55,%dl
f0103166:	0f 87 bf 03 00 00    	ja     f010352b <vprintfmt+0x447>
f010316c:	0f b6 d2             	movzbl %dl,%edx
f010316f:	ff 24 95 c0 4c 10 f0 	jmp    *-0xfefb340(,%edx,4)
f0103176:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103179:	ba 00 00 00 00       	mov    $0x0,%edx
f010317e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103181:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103184:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103188:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010318b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010318e:	83 f9 09             	cmp    $0x9,%ecx
f0103191:	77 3c                	ja     f01031cf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103193:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103196:	eb e9                	jmp    f0103181 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103198:	8b 45 14             	mov    0x14(%ebp),%eax
f010319b:	8b 00                	mov    (%eax),%eax
f010319d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01031a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01031a3:	8d 40 04             	lea    0x4(%eax),%eax
f01031a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01031ac:	eb 27                	jmp    f01031d5 <vprintfmt+0xf1>
f01031ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01031b1:	85 d2                	test   %edx,%edx
f01031b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01031b8:	0f 49 c2             	cmovns %edx,%eax
f01031bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031c1:	eb 91                	jmp    f0103154 <vprintfmt+0x70>
f01031c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01031c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01031cd:	eb 85                	jmp    f0103154 <vprintfmt+0x70>
f01031cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01031d2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01031d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01031d9:	0f 89 75 ff ff ff    	jns    f0103154 <vprintfmt+0x70>
f01031df:	e9 63 ff ff ff       	jmp    f0103147 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01031e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01031ea:	e9 65 ff ff ff       	jmp    f0103154 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031ef:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01031f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01031f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031fa:	8b 00                	mov    (%eax),%eax
f01031fc:	89 04 24             	mov    %eax,(%esp)
f01031ff:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103201:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103204:	e9 00 ff ff ff       	jmp    f0103109 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103209:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010320c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103210:	8b 00                	mov    (%eax),%eax
f0103212:	99                   	cltd   
f0103213:	31 d0                	xor    %edx,%eax
f0103215:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103217:	83 f8 07             	cmp    $0x7,%eax
f010321a:	7f 0b                	jg     f0103227 <vprintfmt+0x143>
f010321c:	8b 14 85 20 4e 10 f0 	mov    -0xfefb1e0(,%eax,4),%edx
f0103223:	85 d2                	test   %edx,%edx
f0103225:	75 20                	jne    f0103247 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0103227:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010322b:	c7 44 24 08 44 4c 10 	movl   $0xf0104c44,0x8(%esp)
f0103232:	f0 
f0103233:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103237:	89 34 24             	mov    %esi,(%esp)
f010323a:	e8 7d fe ff ff       	call   f01030bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010323f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103242:	e9 c2 fe ff ff       	jmp    f0103109 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103247:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010324b:	c7 44 24 08 5c 49 10 	movl   $0xf010495c,0x8(%esp)
f0103252:	f0 
f0103253:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103257:	89 34 24             	mov    %esi,(%esp)
f010325a:	e8 5d fe ff ff       	call   f01030bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010325f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103262:	e9 a2 fe ff ff       	jmp    f0103109 <vprintfmt+0x25>
f0103267:	8b 45 14             	mov    0x14(%ebp),%eax
f010326a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010326d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103270:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103273:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103277:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103279:	85 ff                	test   %edi,%edi
f010327b:	b8 3d 4c 10 f0       	mov    $0xf0104c3d,%eax
f0103280:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103283:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103287:	0f 84 92 00 00 00    	je     f010331f <vprintfmt+0x23b>
f010328d:	85 c9                	test   %ecx,%ecx
f010328f:	0f 8e 98 00 00 00    	jle    f010332d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103295:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103299:	89 3c 24             	mov    %edi,(%esp)
f010329c:	e8 17 04 00 00       	call   f01036b8 <strnlen>
f01032a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01032a4:	29 c1                	sub    %eax,%ecx
f01032a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f01032a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01032ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01032b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01032b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01032b5:	eb 0f                	jmp    f01032c6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f01032b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032be:	89 04 24             	mov    %eax,(%esp)
f01032c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01032c3:	83 ef 01             	sub    $0x1,%edi
f01032c6:	85 ff                	test   %edi,%edi
f01032c8:	7f ed                	jg     f01032b7 <vprintfmt+0x1d3>
f01032ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01032cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01032d0:	85 c9                	test   %ecx,%ecx
f01032d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01032d7:	0f 49 c1             	cmovns %ecx,%eax
f01032da:	29 c1                	sub    %eax,%ecx
f01032dc:	89 75 08             	mov    %esi,0x8(%ebp)
f01032df:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01032e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01032e5:	89 cb                	mov    %ecx,%ebx
f01032e7:	eb 50                	jmp    f0103339 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01032e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01032ed:	74 1e                	je     f010330d <vprintfmt+0x229>
f01032ef:	0f be d2             	movsbl %dl,%edx
f01032f2:	83 ea 20             	sub    $0x20,%edx
f01032f5:	83 fa 5e             	cmp    $0x5e,%edx
f01032f8:	76 13                	jbe    f010330d <vprintfmt+0x229>
					putch('?', putdat);
f01032fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103301:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103308:	ff 55 08             	call   *0x8(%ebp)
f010330b:	eb 0d                	jmp    f010331a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f010330d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103310:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103314:	89 04 24             	mov    %eax,(%esp)
f0103317:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010331a:	83 eb 01             	sub    $0x1,%ebx
f010331d:	eb 1a                	jmp    f0103339 <vprintfmt+0x255>
f010331f:	89 75 08             	mov    %esi,0x8(%ebp)
f0103322:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103325:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103328:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010332b:	eb 0c                	jmp    f0103339 <vprintfmt+0x255>
f010332d:	89 75 08             	mov    %esi,0x8(%ebp)
f0103330:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103333:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103336:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103339:	83 c7 01             	add    $0x1,%edi
f010333c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103340:	0f be c2             	movsbl %dl,%eax
f0103343:	85 c0                	test   %eax,%eax
f0103345:	74 25                	je     f010336c <vprintfmt+0x288>
f0103347:	85 f6                	test   %esi,%esi
f0103349:	78 9e                	js     f01032e9 <vprintfmt+0x205>
f010334b:	83 ee 01             	sub    $0x1,%esi
f010334e:	79 99                	jns    f01032e9 <vprintfmt+0x205>
f0103350:	89 df                	mov    %ebx,%edi
f0103352:	8b 75 08             	mov    0x8(%ebp),%esi
f0103355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103358:	eb 1a                	jmp    f0103374 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010335a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010335e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103365:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103367:	83 ef 01             	sub    $0x1,%edi
f010336a:	eb 08                	jmp    f0103374 <vprintfmt+0x290>
f010336c:	89 df                	mov    %ebx,%edi
f010336e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103374:	85 ff                	test   %edi,%edi
f0103376:	7f e2                	jg     f010335a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010337b:	e9 89 fd ff ff       	jmp    f0103109 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103380:	83 f9 01             	cmp    $0x1,%ecx
f0103383:	7e 19                	jle    f010339e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0103385:	8b 45 14             	mov    0x14(%ebp),%eax
f0103388:	8b 50 04             	mov    0x4(%eax),%edx
f010338b:	8b 00                	mov    (%eax),%eax
f010338d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103390:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103393:	8b 45 14             	mov    0x14(%ebp),%eax
f0103396:	8d 40 08             	lea    0x8(%eax),%eax
f0103399:	89 45 14             	mov    %eax,0x14(%ebp)
f010339c:	eb 38                	jmp    f01033d6 <vprintfmt+0x2f2>
	else if (lflag)
f010339e:	85 c9                	test   %ecx,%ecx
f01033a0:	74 1b                	je     f01033bd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f01033a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a5:	8b 00                	mov    (%eax),%eax
f01033a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01033aa:	89 c1                	mov    %eax,%ecx
f01033ac:	c1 f9 1f             	sar    $0x1f,%ecx
f01033af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01033b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01033b5:	8d 40 04             	lea    0x4(%eax),%eax
f01033b8:	89 45 14             	mov    %eax,0x14(%ebp)
f01033bb:	eb 19                	jmp    f01033d6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f01033bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01033c0:	8b 00                	mov    (%eax),%eax
f01033c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01033c5:	89 c1                	mov    %eax,%ecx
f01033c7:	c1 f9 1f             	sar    $0x1f,%ecx
f01033ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01033cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01033d0:	8d 40 04             	lea    0x4(%eax),%eax
f01033d3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01033d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01033dc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01033e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01033e5:	0f 89 04 01 00 00    	jns    f01034ef <vprintfmt+0x40b>
				putch('-', putdat);
f01033eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01033f6:	ff d6                	call   *%esi
				num = -(long long) num;
f01033f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01033fe:	f7 da                	neg    %edx
f0103400:	83 d1 00             	adc    $0x0,%ecx
f0103403:	f7 d9                	neg    %ecx
f0103405:	e9 e5 00 00 00       	jmp    f01034ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010340a:	83 f9 01             	cmp    $0x1,%ecx
f010340d:	7e 10                	jle    f010341f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f010340f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103412:	8b 10                	mov    (%eax),%edx
f0103414:	8b 48 04             	mov    0x4(%eax),%ecx
f0103417:	8d 40 08             	lea    0x8(%eax),%eax
f010341a:	89 45 14             	mov    %eax,0x14(%ebp)
f010341d:	eb 26                	jmp    f0103445 <vprintfmt+0x361>
	else if (lflag)
f010341f:	85 c9                	test   %ecx,%ecx
f0103421:	74 12                	je     f0103435 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0103423:	8b 45 14             	mov    0x14(%ebp),%eax
f0103426:	8b 10                	mov    (%eax),%edx
f0103428:	b9 00 00 00 00       	mov    $0x0,%ecx
f010342d:	8d 40 04             	lea    0x4(%eax),%eax
f0103430:	89 45 14             	mov    %eax,0x14(%ebp)
f0103433:	eb 10                	jmp    f0103445 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0103435:	8b 45 14             	mov    0x14(%ebp),%eax
f0103438:	8b 10                	mov    (%eax),%edx
f010343a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010343f:	8d 40 04             	lea    0x4(%eax),%eax
f0103442:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103445:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010344a:	e9 a0 00 00 00       	jmp    f01034ef <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010344f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103453:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010345a:	ff d6                	call   *%esi
			putch('X', putdat);
f010345c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103460:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103467:	ff d6                	call   *%esi
			putch('X', putdat);
f0103469:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010346d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103474:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103479:	e9 8b fc ff ff       	jmp    f0103109 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010347e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103482:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103489:	ff d6                	call   *%esi
			putch('x', putdat);
f010348b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010348f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103496:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103498:	8b 45 14             	mov    0x14(%ebp),%eax
f010349b:	8b 10                	mov    (%eax),%edx
f010349d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f01034a2:	8d 40 04             	lea    0x4(%eax),%eax
f01034a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01034a8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01034ad:	eb 40                	jmp    f01034ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01034af:	83 f9 01             	cmp    $0x1,%ecx
f01034b2:	7e 10                	jle    f01034c4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f01034b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01034b7:	8b 10                	mov    (%eax),%edx
f01034b9:	8b 48 04             	mov    0x4(%eax),%ecx
f01034bc:	8d 40 08             	lea    0x8(%eax),%eax
f01034bf:	89 45 14             	mov    %eax,0x14(%ebp)
f01034c2:	eb 26                	jmp    f01034ea <vprintfmt+0x406>
	else if (lflag)
f01034c4:	85 c9                	test   %ecx,%ecx
f01034c6:	74 12                	je     f01034da <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01034c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01034cb:	8b 10                	mov    (%eax),%edx
f01034cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034d2:	8d 40 04             	lea    0x4(%eax),%eax
f01034d5:	89 45 14             	mov    %eax,0x14(%ebp)
f01034d8:	eb 10                	jmp    f01034ea <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01034da:	8b 45 14             	mov    0x14(%ebp),%eax
f01034dd:	8b 10                	mov    (%eax),%edx
f01034df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034e4:	8d 40 04             	lea    0x4(%eax),%eax
f01034e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01034ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01034ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01034f3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01034f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103502:	89 14 24             	mov    %edx,(%esp)
f0103505:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103509:	89 da                	mov    %ebx,%edx
f010350b:	89 f0                	mov    %esi,%eax
f010350d:	e8 9e fa ff ff       	call   f0102fb0 <printnum>
			break;
f0103512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103515:	e9 ef fb ff ff       	jmp    f0103109 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010351a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010351e:	89 04 24             	mov    %eax,(%esp)
f0103521:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103526:	e9 de fb ff ff       	jmp    f0103109 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010352b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010352f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103536:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103538:	eb 03                	jmp    f010353d <vprintfmt+0x459>
f010353a:	83 ef 01             	sub    $0x1,%edi
f010353d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103541:	75 f7                	jne    f010353a <vprintfmt+0x456>
f0103543:	e9 c1 fb ff ff       	jmp    f0103109 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103548:	83 c4 3c             	add    $0x3c,%esp
f010354b:	5b                   	pop    %ebx
f010354c:	5e                   	pop    %esi
f010354d:	5f                   	pop    %edi
f010354e:	5d                   	pop    %ebp
f010354f:	c3                   	ret    

f0103550 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103550:	55                   	push   %ebp
f0103551:	89 e5                	mov    %esp,%ebp
f0103553:	83 ec 28             	sub    $0x28,%esp
f0103556:	8b 45 08             	mov    0x8(%ebp),%eax
f0103559:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010355c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010355f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103563:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103566:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010356d:	85 c0                	test   %eax,%eax
f010356f:	74 30                	je     f01035a1 <vsnprintf+0x51>
f0103571:	85 d2                	test   %edx,%edx
f0103573:	7e 2c                	jle    f01035a1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103575:	8b 45 14             	mov    0x14(%ebp),%eax
f0103578:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357c:	8b 45 10             	mov    0x10(%ebp),%eax
f010357f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103583:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103586:	89 44 24 04          	mov    %eax,0x4(%esp)
f010358a:	c7 04 24 9f 30 10 f0 	movl   $0xf010309f,(%esp)
f0103591:	e8 4e fb ff ff       	call   f01030e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103596:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103599:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010359f:	eb 05                	jmp    f01035a6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01035a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01035a6:	c9                   	leave  
f01035a7:	c3                   	ret    

f01035a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01035a8:	55                   	push   %ebp
f01035a9:	89 e5                	mov    %esp,%ebp
f01035ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01035ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01035b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035b5:	8b 45 10             	mov    0x10(%ebp),%eax
f01035b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c6:	89 04 24             	mov    %eax,(%esp)
f01035c9:	e8 82 ff ff ff       	call   f0103550 <vsnprintf>
	va_end(ap);

	return rc;
}
f01035ce:	c9                   	leave  
f01035cf:	c3                   	ret    

f01035d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01035d0:	55                   	push   %ebp
f01035d1:	89 e5                	mov    %esp,%ebp
f01035d3:	57                   	push   %edi
f01035d4:	56                   	push   %esi
f01035d5:	53                   	push   %ebx
f01035d6:	83 ec 1c             	sub    $0x1c,%esp
f01035d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01035dc:	85 c0                	test   %eax,%eax
f01035de:	74 10                	je     f01035f0 <readline+0x20>
		cprintf("%s", prompt);
f01035e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035e4:	c7 04 24 5c 49 10 f0 	movl   $0xf010495c,(%esp)
f01035eb:	e8 f0 f6 ff ff       	call   f0102ce0 <cprintf>

	i = 0;
	echoing = iscons(0);
f01035f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035f7:	e8 16 d0 ff ff       	call   f0100612 <iscons>
f01035fc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01035fe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103603:	e8 f9 cf ff ff       	call   f0100601 <getchar>
f0103608:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010360a:	85 c0                	test   %eax,%eax
f010360c:	79 17                	jns    f0103625 <readline+0x55>
			cprintf("read error: %e\n", c);
f010360e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103612:	c7 04 24 40 4e 10 f0 	movl   $0xf0104e40,(%esp)
f0103619:	e8 c2 f6 ff ff       	call   f0102ce0 <cprintf>
			return NULL;
f010361e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103623:	eb 6d                	jmp    f0103692 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103625:	83 f8 7f             	cmp    $0x7f,%eax
f0103628:	74 05                	je     f010362f <readline+0x5f>
f010362a:	83 f8 08             	cmp    $0x8,%eax
f010362d:	75 19                	jne    f0103648 <readline+0x78>
f010362f:	85 f6                	test   %esi,%esi
f0103631:	7e 15                	jle    f0103648 <readline+0x78>
			if (echoing)
f0103633:	85 ff                	test   %edi,%edi
f0103635:	74 0c                	je     f0103643 <readline+0x73>
				cputchar('\b');
f0103637:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010363e:	e8 ae cf ff ff       	call   f01005f1 <cputchar>
			i--;
f0103643:	83 ee 01             	sub    $0x1,%esi
f0103646:	eb bb                	jmp    f0103603 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103648:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010364e:	7f 1c                	jg     f010366c <readline+0x9c>
f0103650:	83 fb 1f             	cmp    $0x1f,%ebx
f0103653:	7e 17                	jle    f010366c <readline+0x9c>
			if (echoing)
f0103655:	85 ff                	test   %edi,%edi
f0103657:	74 08                	je     f0103661 <readline+0x91>
				cputchar(c);
f0103659:	89 1c 24             	mov    %ebx,(%esp)
f010365c:	e8 90 cf ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0103661:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103667:	8d 76 01             	lea    0x1(%esi),%esi
f010366a:	eb 97                	jmp    f0103603 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010366c:	83 fb 0d             	cmp    $0xd,%ebx
f010366f:	74 05                	je     f0103676 <readline+0xa6>
f0103671:	83 fb 0a             	cmp    $0xa,%ebx
f0103674:	75 8d                	jne    f0103603 <readline+0x33>
			if (echoing)
f0103676:	85 ff                	test   %edi,%edi
f0103678:	74 0c                	je     f0103686 <readline+0xb6>
				cputchar('\n');
f010367a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103681:	e8 6b cf ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0103686:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010368d:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103692:	83 c4 1c             	add    $0x1c,%esp
f0103695:	5b                   	pop    %ebx
f0103696:	5e                   	pop    %esi
f0103697:	5f                   	pop    %edi
f0103698:	5d                   	pop    %ebp
f0103699:	c3                   	ret    
f010369a:	66 90                	xchg   %ax,%ax
f010369c:	66 90                	xchg   %ax,%ax
f010369e:	66 90                	xchg   %ax,%ax

f01036a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01036a0:	55                   	push   %ebp
f01036a1:	89 e5                	mov    %esp,%ebp
f01036a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01036a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ab:	eb 03                	jmp    f01036b0 <strlen+0x10>
		n++;
f01036ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01036b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01036b4:	75 f7                	jne    f01036ad <strlen+0xd>
		n++;
	return n;
}
f01036b6:	5d                   	pop    %ebp
f01036b7:	c3                   	ret    

f01036b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01036b8:	55                   	push   %ebp
f01036b9:	89 e5                	mov    %esp,%ebp
f01036bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01036c6:	eb 03                	jmp    f01036cb <strnlen+0x13>
		n++;
f01036c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036cb:	39 d0                	cmp    %edx,%eax
f01036cd:	74 06                	je     f01036d5 <strnlen+0x1d>
f01036cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01036d3:	75 f3                	jne    f01036c8 <strnlen+0x10>
		n++;
	return n;
}
f01036d5:	5d                   	pop    %ebp
f01036d6:	c3                   	ret    

f01036d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01036d7:	55                   	push   %ebp
f01036d8:	89 e5                	mov    %esp,%ebp
f01036da:	53                   	push   %ebx
f01036db:	8b 45 08             	mov    0x8(%ebp),%eax
f01036de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01036e1:	89 c2                	mov    %eax,%edx
f01036e3:	83 c2 01             	add    $0x1,%edx
f01036e6:	83 c1 01             	add    $0x1,%ecx
f01036e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01036ed:	88 5a ff             	mov    %bl,-0x1(%edx)
f01036f0:	84 db                	test   %bl,%bl
f01036f2:	75 ef                	jne    f01036e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01036f4:	5b                   	pop    %ebx
f01036f5:	5d                   	pop    %ebp
f01036f6:	c3                   	ret    

f01036f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01036f7:	55                   	push   %ebp
f01036f8:	89 e5                	mov    %esp,%ebp
f01036fa:	53                   	push   %ebx
f01036fb:	83 ec 08             	sub    $0x8,%esp
f01036fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103701:	89 1c 24             	mov    %ebx,(%esp)
f0103704:	e8 97 ff ff ff       	call   f01036a0 <strlen>
	strcpy(dst + len, src);
f0103709:	8b 55 0c             	mov    0xc(%ebp),%edx
f010370c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103710:	01 d8                	add    %ebx,%eax
f0103712:	89 04 24             	mov    %eax,(%esp)
f0103715:	e8 bd ff ff ff       	call   f01036d7 <strcpy>
	return dst;
}
f010371a:	89 d8                	mov    %ebx,%eax
f010371c:	83 c4 08             	add    $0x8,%esp
f010371f:	5b                   	pop    %ebx
f0103720:	5d                   	pop    %ebp
f0103721:	c3                   	ret    

f0103722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103722:	55                   	push   %ebp
f0103723:	89 e5                	mov    %esp,%ebp
f0103725:	56                   	push   %esi
f0103726:	53                   	push   %ebx
f0103727:	8b 75 08             	mov    0x8(%ebp),%esi
f010372a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010372d:	89 f3                	mov    %esi,%ebx
f010372f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103732:	89 f2                	mov    %esi,%edx
f0103734:	eb 0f                	jmp    f0103745 <strncpy+0x23>
		*dst++ = *src;
f0103736:	83 c2 01             	add    $0x1,%edx
f0103739:	0f b6 01             	movzbl (%ecx),%eax
f010373c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010373f:	80 39 01             	cmpb   $0x1,(%ecx)
f0103742:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103745:	39 da                	cmp    %ebx,%edx
f0103747:	75 ed                	jne    f0103736 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103749:	89 f0                	mov    %esi,%eax
f010374b:	5b                   	pop    %ebx
f010374c:	5e                   	pop    %esi
f010374d:	5d                   	pop    %ebp
f010374e:	c3                   	ret    

f010374f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010374f:	55                   	push   %ebp
f0103750:	89 e5                	mov    %esp,%ebp
f0103752:	56                   	push   %esi
f0103753:	53                   	push   %ebx
f0103754:	8b 75 08             	mov    0x8(%ebp),%esi
f0103757:	8b 55 0c             	mov    0xc(%ebp),%edx
f010375a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010375d:	89 f0                	mov    %esi,%eax
f010375f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103763:	85 c9                	test   %ecx,%ecx
f0103765:	75 0b                	jne    f0103772 <strlcpy+0x23>
f0103767:	eb 1d                	jmp    f0103786 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103769:	83 c0 01             	add    $0x1,%eax
f010376c:	83 c2 01             	add    $0x1,%edx
f010376f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103772:	39 d8                	cmp    %ebx,%eax
f0103774:	74 0b                	je     f0103781 <strlcpy+0x32>
f0103776:	0f b6 0a             	movzbl (%edx),%ecx
f0103779:	84 c9                	test   %cl,%cl
f010377b:	75 ec                	jne    f0103769 <strlcpy+0x1a>
f010377d:	89 c2                	mov    %eax,%edx
f010377f:	eb 02                	jmp    f0103783 <strlcpy+0x34>
f0103781:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103783:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103786:	29 f0                	sub    %esi,%eax
}
f0103788:	5b                   	pop    %ebx
f0103789:	5e                   	pop    %esi
f010378a:	5d                   	pop    %ebp
f010378b:	c3                   	ret    

f010378c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010378c:	55                   	push   %ebp
f010378d:	89 e5                	mov    %esp,%ebp
f010378f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103792:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103795:	eb 06                	jmp    f010379d <strcmp+0x11>
		p++, q++;
f0103797:	83 c1 01             	add    $0x1,%ecx
f010379a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010379d:	0f b6 01             	movzbl (%ecx),%eax
f01037a0:	84 c0                	test   %al,%al
f01037a2:	74 04                	je     f01037a8 <strcmp+0x1c>
f01037a4:	3a 02                	cmp    (%edx),%al
f01037a6:	74 ef                	je     f0103797 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01037a8:	0f b6 c0             	movzbl %al,%eax
f01037ab:	0f b6 12             	movzbl (%edx),%edx
f01037ae:	29 d0                	sub    %edx,%eax
}
f01037b0:	5d                   	pop    %ebp
f01037b1:	c3                   	ret    

f01037b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01037b2:	55                   	push   %ebp
f01037b3:	89 e5                	mov    %esp,%ebp
f01037b5:	53                   	push   %ebx
f01037b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037bc:	89 c3                	mov    %eax,%ebx
f01037be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01037c1:	eb 06                	jmp    f01037c9 <strncmp+0x17>
		n--, p++, q++;
f01037c3:	83 c0 01             	add    $0x1,%eax
f01037c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01037c9:	39 d8                	cmp    %ebx,%eax
f01037cb:	74 15                	je     f01037e2 <strncmp+0x30>
f01037cd:	0f b6 08             	movzbl (%eax),%ecx
f01037d0:	84 c9                	test   %cl,%cl
f01037d2:	74 04                	je     f01037d8 <strncmp+0x26>
f01037d4:	3a 0a                	cmp    (%edx),%cl
f01037d6:	74 eb                	je     f01037c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01037d8:	0f b6 00             	movzbl (%eax),%eax
f01037db:	0f b6 12             	movzbl (%edx),%edx
f01037de:	29 d0                	sub    %edx,%eax
f01037e0:	eb 05                	jmp    f01037e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01037e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01037e7:	5b                   	pop    %ebx
f01037e8:	5d                   	pop    %ebp
f01037e9:	c3                   	ret    

f01037ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01037ea:	55                   	push   %ebp
f01037eb:	89 e5                	mov    %esp,%ebp
f01037ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01037f4:	eb 07                	jmp    f01037fd <strchr+0x13>
		if (*s == c)
f01037f6:	38 ca                	cmp    %cl,%dl
f01037f8:	74 0f                	je     f0103809 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01037fa:	83 c0 01             	add    $0x1,%eax
f01037fd:	0f b6 10             	movzbl (%eax),%edx
f0103800:	84 d2                	test   %dl,%dl
f0103802:	75 f2                	jne    f01037f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103804:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103809:	5d                   	pop    %ebp
f010380a:	c3                   	ret    

f010380b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010380b:	55                   	push   %ebp
f010380c:	89 e5                	mov    %esp,%ebp
f010380e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103815:	eb 07                	jmp    f010381e <strfind+0x13>
		if (*s == c)
f0103817:	38 ca                	cmp    %cl,%dl
f0103819:	74 0a                	je     f0103825 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010381b:	83 c0 01             	add    $0x1,%eax
f010381e:	0f b6 10             	movzbl (%eax),%edx
f0103821:	84 d2                	test   %dl,%dl
f0103823:	75 f2                	jne    f0103817 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0103825:	5d                   	pop    %ebp
f0103826:	c3                   	ret    

f0103827 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103827:	55                   	push   %ebp
f0103828:	89 e5                	mov    %esp,%ebp
f010382a:	57                   	push   %edi
f010382b:	56                   	push   %esi
f010382c:	53                   	push   %ebx
f010382d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103830:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103833:	85 c9                	test   %ecx,%ecx
f0103835:	74 36                	je     f010386d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103837:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010383d:	75 28                	jne    f0103867 <memset+0x40>
f010383f:	f6 c1 03             	test   $0x3,%cl
f0103842:	75 23                	jne    f0103867 <memset+0x40>
		c &= 0xFF;
f0103844:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103848:	89 d3                	mov    %edx,%ebx
f010384a:	c1 e3 08             	shl    $0x8,%ebx
f010384d:	89 d6                	mov    %edx,%esi
f010384f:	c1 e6 18             	shl    $0x18,%esi
f0103852:	89 d0                	mov    %edx,%eax
f0103854:	c1 e0 10             	shl    $0x10,%eax
f0103857:	09 f0                	or     %esi,%eax
f0103859:	09 c2                	or     %eax,%edx
f010385b:	89 d0                	mov    %edx,%eax
f010385d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010385f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103862:	fc                   	cld    
f0103863:	f3 ab                	rep stos %eax,%es:(%edi)
f0103865:	eb 06                	jmp    f010386d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103867:	8b 45 0c             	mov    0xc(%ebp),%eax
f010386a:	fc                   	cld    
f010386b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010386d:	89 f8                	mov    %edi,%eax
f010386f:	5b                   	pop    %ebx
f0103870:	5e                   	pop    %esi
f0103871:	5f                   	pop    %edi
f0103872:	5d                   	pop    %ebp
f0103873:	c3                   	ret    

f0103874 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103874:	55                   	push   %ebp
f0103875:	89 e5                	mov    %esp,%ebp
f0103877:	57                   	push   %edi
f0103878:	56                   	push   %esi
f0103879:	8b 45 08             	mov    0x8(%ebp),%eax
f010387c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010387f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103882:	39 c6                	cmp    %eax,%esi
f0103884:	73 35                	jae    f01038bb <memmove+0x47>
f0103886:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103889:	39 d0                	cmp    %edx,%eax
f010388b:	73 2e                	jae    f01038bb <memmove+0x47>
		s += n;
		d += n;
f010388d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103890:	89 d6                	mov    %edx,%esi
f0103892:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103894:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010389a:	75 13                	jne    f01038af <memmove+0x3b>
f010389c:	f6 c1 03             	test   $0x3,%cl
f010389f:	75 0e                	jne    f01038af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01038a1:	83 ef 04             	sub    $0x4,%edi
f01038a4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01038a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01038aa:	fd                   	std    
f01038ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038ad:	eb 09                	jmp    f01038b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01038af:	83 ef 01             	sub    $0x1,%edi
f01038b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01038b5:	fd                   	std    
f01038b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01038b8:	fc                   	cld    
f01038b9:	eb 1d                	jmp    f01038d8 <memmove+0x64>
f01038bb:	89 f2                	mov    %esi,%edx
f01038bd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01038bf:	f6 c2 03             	test   $0x3,%dl
f01038c2:	75 0f                	jne    f01038d3 <memmove+0x5f>
f01038c4:	f6 c1 03             	test   $0x3,%cl
f01038c7:	75 0a                	jne    f01038d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01038c9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01038cc:	89 c7                	mov    %eax,%edi
f01038ce:	fc                   	cld    
f01038cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038d1:	eb 05                	jmp    f01038d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01038d3:	89 c7                	mov    %eax,%edi
f01038d5:	fc                   	cld    
f01038d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01038d8:	5e                   	pop    %esi
f01038d9:	5f                   	pop    %edi
f01038da:	5d                   	pop    %ebp
f01038db:	c3                   	ret    

f01038dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01038dc:	55                   	push   %ebp
f01038dd:	89 e5                	mov    %esp,%ebp
f01038df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01038e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01038e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038f3:	89 04 24             	mov    %eax,(%esp)
f01038f6:	e8 79 ff ff ff       	call   f0103874 <memmove>
}
f01038fb:	c9                   	leave  
f01038fc:	c3                   	ret    

f01038fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01038fd:	55                   	push   %ebp
f01038fe:	89 e5                	mov    %esp,%ebp
f0103900:	56                   	push   %esi
f0103901:	53                   	push   %ebx
f0103902:	8b 55 08             	mov    0x8(%ebp),%edx
f0103905:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103908:	89 d6                	mov    %edx,%esi
f010390a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010390d:	eb 1a                	jmp    f0103929 <memcmp+0x2c>
		if (*s1 != *s2)
f010390f:	0f b6 02             	movzbl (%edx),%eax
f0103912:	0f b6 19             	movzbl (%ecx),%ebx
f0103915:	38 d8                	cmp    %bl,%al
f0103917:	74 0a                	je     f0103923 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103919:	0f b6 c0             	movzbl %al,%eax
f010391c:	0f b6 db             	movzbl %bl,%ebx
f010391f:	29 d8                	sub    %ebx,%eax
f0103921:	eb 0f                	jmp    f0103932 <memcmp+0x35>
		s1++, s2++;
f0103923:	83 c2 01             	add    $0x1,%edx
f0103926:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103929:	39 f2                	cmp    %esi,%edx
f010392b:	75 e2                	jne    f010390f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010392d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103932:	5b                   	pop    %ebx
f0103933:	5e                   	pop    %esi
f0103934:	5d                   	pop    %ebp
f0103935:	c3                   	ret    

f0103936 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103936:	55                   	push   %ebp
f0103937:	89 e5                	mov    %esp,%ebp
f0103939:	8b 45 08             	mov    0x8(%ebp),%eax
f010393c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010393f:	89 c2                	mov    %eax,%edx
f0103941:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103944:	eb 07                	jmp    f010394d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103946:	38 08                	cmp    %cl,(%eax)
f0103948:	74 07                	je     f0103951 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010394a:	83 c0 01             	add    $0x1,%eax
f010394d:	39 d0                	cmp    %edx,%eax
f010394f:	72 f5                	jb     f0103946 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103951:	5d                   	pop    %ebp
f0103952:	c3                   	ret    

f0103953 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103953:	55                   	push   %ebp
f0103954:	89 e5                	mov    %esp,%ebp
f0103956:	57                   	push   %edi
f0103957:	56                   	push   %esi
f0103958:	53                   	push   %ebx
f0103959:	8b 55 08             	mov    0x8(%ebp),%edx
f010395c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010395f:	eb 03                	jmp    f0103964 <strtol+0x11>
		s++;
f0103961:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103964:	0f b6 0a             	movzbl (%edx),%ecx
f0103967:	80 f9 09             	cmp    $0x9,%cl
f010396a:	74 f5                	je     f0103961 <strtol+0xe>
f010396c:	80 f9 20             	cmp    $0x20,%cl
f010396f:	74 f0                	je     f0103961 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103971:	80 f9 2b             	cmp    $0x2b,%cl
f0103974:	75 0a                	jne    f0103980 <strtol+0x2d>
		s++;
f0103976:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103979:	bf 00 00 00 00       	mov    $0x0,%edi
f010397e:	eb 11                	jmp    f0103991 <strtol+0x3e>
f0103980:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103985:	80 f9 2d             	cmp    $0x2d,%cl
f0103988:	75 07                	jne    f0103991 <strtol+0x3e>
		s++, neg = 1;
f010398a:	8d 52 01             	lea    0x1(%edx),%edx
f010398d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103991:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0103996:	75 15                	jne    f01039ad <strtol+0x5a>
f0103998:	80 3a 30             	cmpb   $0x30,(%edx)
f010399b:	75 10                	jne    f01039ad <strtol+0x5a>
f010399d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01039a1:	75 0a                	jne    f01039ad <strtol+0x5a>
		s += 2, base = 16;
f01039a3:	83 c2 02             	add    $0x2,%edx
f01039a6:	b8 10 00 00 00       	mov    $0x10,%eax
f01039ab:	eb 10                	jmp    f01039bd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f01039ad:	85 c0                	test   %eax,%eax
f01039af:	75 0c                	jne    f01039bd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01039b1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01039b3:	80 3a 30             	cmpb   $0x30,(%edx)
f01039b6:	75 05                	jne    f01039bd <strtol+0x6a>
		s++, base = 8;
f01039b8:	83 c2 01             	add    $0x1,%edx
f01039bb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f01039bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01039c2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01039c5:	0f b6 0a             	movzbl (%edx),%ecx
f01039c8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01039cb:	89 f0                	mov    %esi,%eax
f01039cd:	3c 09                	cmp    $0x9,%al
f01039cf:	77 08                	ja     f01039d9 <strtol+0x86>
			dig = *s - '0';
f01039d1:	0f be c9             	movsbl %cl,%ecx
f01039d4:	83 e9 30             	sub    $0x30,%ecx
f01039d7:	eb 20                	jmp    f01039f9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01039d9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01039dc:	89 f0                	mov    %esi,%eax
f01039de:	3c 19                	cmp    $0x19,%al
f01039e0:	77 08                	ja     f01039ea <strtol+0x97>
			dig = *s - 'a' + 10;
f01039e2:	0f be c9             	movsbl %cl,%ecx
f01039e5:	83 e9 57             	sub    $0x57,%ecx
f01039e8:	eb 0f                	jmp    f01039f9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01039ea:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01039ed:	89 f0                	mov    %esi,%eax
f01039ef:	3c 19                	cmp    $0x19,%al
f01039f1:	77 16                	ja     f0103a09 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01039f3:	0f be c9             	movsbl %cl,%ecx
f01039f6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01039f9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01039fc:	7d 0f                	jge    f0103a0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01039fe:	83 c2 01             	add    $0x1,%edx
f0103a01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0103a05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0103a07:	eb bc                	jmp    f01039c5 <strtol+0x72>
f0103a09:	89 d8                	mov    %ebx,%eax
f0103a0b:	eb 02                	jmp    f0103a0f <strtol+0xbc>
f0103a0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0103a0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103a13:	74 05                	je     f0103a1a <strtol+0xc7>
		*endptr = (char *) s;
f0103a15:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103a18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103a1a:	f7 d8                	neg    %eax
f0103a1c:	85 ff                	test   %edi,%edi
f0103a1e:	0f 44 c3             	cmove  %ebx,%eax
}
f0103a21:	5b                   	pop    %ebx
f0103a22:	5e                   	pop    %esi
f0103a23:	5f                   	pop    %edi
f0103a24:	5d                   	pop    %ebp
f0103a25:	c3                   	ret    
f0103a26:	66 90                	xchg   %ax,%ax
f0103a28:	66 90                	xchg   %ax,%ax
f0103a2a:	66 90                	xchg   %ax,%ax
f0103a2c:	66 90                	xchg   %ax,%ax
f0103a2e:	66 90                	xchg   %ax,%ax

f0103a30 <__udivdi3>:
f0103a30:	55                   	push   %ebp
f0103a31:	57                   	push   %edi
f0103a32:	56                   	push   %esi
f0103a33:	83 ec 0c             	sub    $0xc,%esp
f0103a36:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103a3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0103a3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0103a42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103a46:	85 c0                	test   %eax,%eax
f0103a48:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a4c:	89 ea                	mov    %ebp,%edx
f0103a4e:	89 0c 24             	mov    %ecx,(%esp)
f0103a51:	75 2d                	jne    f0103a80 <__udivdi3+0x50>
f0103a53:	39 e9                	cmp    %ebp,%ecx
f0103a55:	77 61                	ja     f0103ab8 <__udivdi3+0x88>
f0103a57:	85 c9                	test   %ecx,%ecx
f0103a59:	89 ce                	mov    %ecx,%esi
f0103a5b:	75 0b                	jne    f0103a68 <__udivdi3+0x38>
f0103a5d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a62:	31 d2                	xor    %edx,%edx
f0103a64:	f7 f1                	div    %ecx
f0103a66:	89 c6                	mov    %eax,%esi
f0103a68:	31 d2                	xor    %edx,%edx
f0103a6a:	89 e8                	mov    %ebp,%eax
f0103a6c:	f7 f6                	div    %esi
f0103a6e:	89 c5                	mov    %eax,%ebp
f0103a70:	89 f8                	mov    %edi,%eax
f0103a72:	f7 f6                	div    %esi
f0103a74:	89 ea                	mov    %ebp,%edx
f0103a76:	83 c4 0c             	add    $0xc,%esp
f0103a79:	5e                   	pop    %esi
f0103a7a:	5f                   	pop    %edi
f0103a7b:	5d                   	pop    %ebp
f0103a7c:	c3                   	ret    
f0103a7d:	8d 76 00             	lea    0x0(%esi),%esi
f0103a80:	39 e8                	cmp    %ebp,%eax
f0103a82:	77 24                	ja     f0103aa8 <__udivdi3+0x78>
f0103a84:	0f bd e8             	bsr    %eax,%ebp
f0103a87:	83 f5 1f             	xor    $0x1f,%ebp
f0103a8a:	75 3c                	jne    f0103ac8 <__udivdi3+0x98>
f0103a8c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103a90:	39 34 24             	cmp    %esi,(%esp)
f0103a93:	0f 86 9f 00 00 00    	jbe    f0103b38 <__udivdi3+0x108>
f0103a99:	39 d0                	cmp    %edx,%eax
f0103a9b:	0f 82 97 00 00 00    	jb     f0103b38 <__udivdi3+0x108>
f0103aa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103aa8:	31 d2                	xor    %edx,%edx
f0103aaa:	31 c0                	xor    %eax,%eax
f0103aac:	83 c4 0c             	add    $0xc,%esp
f0103aaf:	5e                   	pop    %esi
f0103ab0:	5f                   	pop    %edi
f0103ab1:	5d                   	pop    %ebp
f0103ab2:	c3                   	ret    
f0103ab3:	90                   	nop
f0103ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ab8:	89 f8                	mov    %edi,%eax
f0103aba:	f7 f1                	div    %ecx
f0103abc:	31 d2                	xor    %edx,%edx
f0103abe:	83 c4 0c             	add    $0xc,%esp
f0103ac1:	5e                   	pop    %esi
f0103ac2:	5f                   	pop    %edi
f0103ac3:	5d                   	pop    %ebp
f0103ac4:	c3                   	ret    
f0103ac5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ac8:	89 e9                	mov    %ebp,%ecx
f0103aca:	8b 3c 24             	mov    (%esp),%edi
f0103acd:	d3 e0                	shl    %cl,%eax
f0103acf:	89 c6                	mov    %eax,%esi
f0103ad1:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ad6:	29 e8                	sub    %ebp,%eax
f0103ad8:	89 c1                	mov    %eax,%ecx
f0103ada:	d3 ef                	shr    %cl,%edi
f0103adc:	89 e9                	mov    %ebp,%ecx
f0103ade:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103ae2:	8b 3c 24             	mov    (%esp),%edi
f0103ae5:	09 74 24 08          	or     %esi,0x8(%esp)
f0103ae9:	89 d6                	mov    %edx,%esi
f0103aeb:	d3 e7                	shl    %cl,%edi
f0103aed:	89 c1                	mov    %eax,%ecx
f0103aef:	89 3c 24             	mov    %edi,(%esp)
f0103af2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103af6:	d3 ee                	shr    %cl,%esi
f0103af8:	89 e9                	mov    %ebp,%ecx
f0103afa:	d3 e2                	shl    %cl,%edx
f0103afc:	89 c1                	mov    %eax,%ecx
f0103afe:	d3 ef                	shr    %cl,%edi
f0103b00:	09 d7                	or     %edx,%edi
f0103b02:	89 f2                	mov    %esi,%edx
f0103b04:	89 f8                	mov    %edi,%eax
f0103b06:	f7 74 24 08          	divl   0x8(%esp)
f0103b0a:	89 d6                	mov    %edx,%esi
f0103b0c:	89 c7                	mov    %eax,%edi
f0103b0e:	f7 24 24             	mull   (%esp)
f0103b11:	39 d6                	cmp    %edx,%esi
f0103b13:	89 14 24             	mov    %edx,(%esp)
f0103b16:	72 30                	jb     f0103b48 <__udivdi3+0x118>
f0103b18:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103b1c:	89 e9                	mov    %ebp,%ecx
f0103b1e:	d3 e2                	shl    %cl,%edx
f0103b20:	39 c2                	cmp    %eax,%edx
f0103b22:	73 05                	jae    f0103b29 <__udivdi3+0xf9>
f0103b24:	3b 34 24             	cmp    (%esp),%esi
f0103b27:	74 1f                	je     f0103b48 <__udivdi3+0x118>
f0103b29:	89 f8                	mov    %edi,%eax
f0103b2b:	31 d2                	xor    %edx,%edx
f0103b2d:	e9 7a ff ff ff       	jmp    f0103aac <__udivdi3+0x7c>
f0103b32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103b38:	31 d2                	xor    %edx,%edx
f0103b3a:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b3f:	e9 68 ff ff ff       	jmp    f0103aac <__udivdi3+0x7c>
f0103b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b48:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103b4b:	31 d2                	xor    %edx,%edx
f0103b4d:	83 c4 0c             	add    $0xc,%esp
f0103b50:	5e                   	pop    %esi
f0103b51:	5f                   	pop    %edi
f0103b52:	5d                   	pop    %ebp
f0103b53:	c3                   	ret    
f0103b54:	66 90                	xchg   %ax,%ax
f0103b56:	66 90                	xchg   %ax,%ax
f0103b58:	66 90                	xchg   %ax,%ax
f0103b5a:	66 90                	xchg   %ax,%ax
f0103b5c:	66 90                	xchg   %ax,%ax
f0103b5e:	66 90                	xchg   %ax,%ax

f0103b60 <__umoddi3>:
f0103b60:	55                   	push   %ebp
f0103b61:	57                   	push   %edi
f0103b62:	56                   	push   %esi
f0103b63:	83 ec 14             	sub    $0x14,%esp
f0103b66:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103b6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103b6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0103b72:	89 c7                	mov    %eax,%edi
f0103b74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b78:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103b7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103b80:	89 34 24             	mov    %esi,(%esp)
f0103b83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103b87:	85 c0                	test   %eax,%eax
f0103b89:	89 c2                	mov    %eax,%edx
f0103b8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103b8f:	75 17                	jne    f0103ba8 <__umoddi3+0x48>
f0103b91:	39 fe                	cmp    %edi,%esi
f0103b93:	76 4b                	jbe    f0103be0 <__umoddi3+0x80>
f0103b95:	89 c8                	mov    %ecx,%eax
f0103b97:	89 fa                	mov    %edi,%edx
f0103b99:	f7 f6                	div    %esi
f0103b9b:	89 d0                	mov    %edx,%eax
f0103b9d:	31 d2                	xor    %edx,%edx
f0103b9f:	83 c4 14             	add    $0x14,%esp
f0103ba2:	5e                   	pop    %esi
f0103ba3:	5f                   	pop    %edi
f0103ba4:	5d                   	pop    %ebp
f0103ba5:	c3                   	ret    
f0103ba6:	66 90                	xchg   %ax,%ax
f0103ba8:	39 f8                	cmp    %edi,%eax
f0103baa:	77 54                	ja     f0103c00 <__umoddi3+0xa0>
f0103bac:	0f bd e8             	bsr    %eax,%ebp
f0103baf:	83 f5 1f             	xor    $0x1f,%ebp
f0103bb2:	75 5c                	jne    f0103c10 <__umoddi3+0xb0>
f0103bb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103bb8:	39 3c 24             	cmp    %edi,(%esp)
f0103bbb:	0f 87 e7 00 00 00    	ja     f0103ca8 <__umoddi3+0x148>
f0103bc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103bc5:	29 f1                	sub    %esi,%ecx
f0103bc7:	19 c7                	sbb    %eax,%edi
f0103bc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103bcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103bd1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103bd5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103bd9:	83 c4 14             	add    $0x14,%esp
f0103bdc:	5e                   	pop    %esi
f0103bdd:	5f                   	pop    %edi
f0103bde:	5d                   	pop    %ebp
f0103bdf:	c3                   	ret    
f0103be0:	85 f6                	test   %esi,%esi
f0103be2:	89 f5                	mov    %esi,%ebp
f0103be4:	75 0b                	jne    f0103bf1 <__umoddi3+0x91>
f0103be6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103beb:	31 d2                	xor    %edx,%edx
f0103bed:	f7 f6                	div    %esi
f0103bef:	89 c5                	mov    %eax,%ebp
f0103bf1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103bf5:	31 d2                	xor    %edx,%edx
f0103bf7:	f7 f5                	div    %ebp
f0103bf9:	89 c8                	mov    %ecx,%eax
f0103bfb:	f7 f5                	div    %ebp
f0103bfd:	eb 9c                	jmp    f0103b9b <__umoddi3+0x3b>
f0103bff:	90                   	nop
f0103c00:	89 c8                	mov    %ecx,%eax
f0103c02:	89 fa                	mov    %edi,%edx
f0103c04:	83 c4 14             	add    $0x14,%esp
f0103c07:	5e                   	pop    %esi
f0103c08:	5f                   	pop    %edi
f0103c09:	5d                   	pop    %ebp
f0103c0a:	c3                   	ret    
f0103c0b:	90                   	nop
f0103c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103c10:	8b 04 24             	mov    (%esp),%eax
f0103c13:	be 20 00 00 00       	mov    $0x20,%esi
f0103c18:	89 e9                	mov    %ebp,%ecx
f0103c1a:	29 ee                	sub    %ebp,%esi
f0103c1c:	d3 e2                	shl    %cl,%edx
f0103c1e:	89 f1                	mov    %esi,%ecx
f0103c20:	d3 e8                	shr    %cl,%eax
f0103c22:	89 e9                	mov    %ebp,%ecx
f0103c24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c28:	8b 04 24             	mov    (%esp),%eax
f0103c2b:	09 54 24 04          	or     %edx,0x4(%esp)
f0103c2f:	89 fa                	mov    %edi,%edx
f0103c31:	d3 e0                	shl    %cl,%eax
f0103c33:	89 f1                	mov    %esi,%ecx
f0103c35:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c39:	8b 44 24 10          	mov    0x10(%esp),%eax
f0103c3d:	d3 ea                	shr    %cl,%edx
f0103c3f:	89 e9                	mov    %ebp,%ecx
f0103c41:	d3 e7                	shl    %cl,%edi
f0103c43:	89 f1                	mov    %esi,%ecx
f0103c45:	d3 e8                	shr    %cl,%eax
f0103c47:	89 e9                	mov    %ebp,%ecx
f0103c49:	09 f8                	or     %edi,%eax
f0103c4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0103c4f:	f7 74 24 04          	divl   0x4(%esp)
f0103c53:	d3 e7                	shl    %cl,%edi
f0103c55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103c59:	89 d7                	mov    %edx,%edi
f0103c5b:	f7 64 24 08          	mull   0x8(%esp)
f0103c5f:	39 d7                	cmp    %edx,%edi
f0103c61:	89 c1                	mov    %eax,%ecx
f0103c63:	89 14 24             	mov    %edx,(%esp)
f0103c66:	72 2c                	jb     f0103c94 <__umoddi3+0x134>
f0103c68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0103c6c:	72 22                	jb     f0103c90 <__umoddi3+0x130>
f0103c6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103c72:	29 c8                	sub    %ecx,%eax
f0103c74:	19 d7                	sbb    %edx,%edi
f0103c76:	89 e9                	mov    %ebp,%ecx
f0103c78:	89 fa                	mov    %edi,%edx
f0103c7a:	d3 e8                	shr    %cl,%eax
f0103c7c:	89 f1                	mov    %esi,%ecx
f0103c7e:	d3 e2                	shl    %cl,%edx
f0103c80:	89 e9                	mov    %ebp,%ecx
f0103c82:	d3 ef                	shr    %cl,%edi
f0103c84:	09 d0                	or     %edx,%eax
f0103c86:	89 fa                	mov    %edi,%edx
f0103c88:	83 c4 14             	add    $0x14,%esp
f0103c8b:	5e                   	pop    %esi
f0103c8c:	5f                   	pop    %edi
f0103c8d:	5d                   	pop    %ebp
f0103c8e:	c3                   	ret    
f0103c8f:	90                   	nop
f0103c90:	39 d7                	cmp    %edx,%edi
f0103c92:	75 da                	jne    f0103c6e <__umoddi3+0x10e>
f0103c94:	8b 14 24             	mov    (%esp),%edx
f0103c97:	89 c1                	mov    %eax,%ecx
f0103c99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0103c9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0103ca1:	eb cb                	jmp    f0103c6e <__umoddi3+0x10e>
f0103ca3:	90                   	nop
f0103ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ca8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0103cac:	0f 82 0f ff ff ff    	jb     f0103bc1 <__umoddi3+0x61>
f0103cb2:	e9 1a ff ff ff       	jmp    f0103bd1 <__umoddi3+0x71>
