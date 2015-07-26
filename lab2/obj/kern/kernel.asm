
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
f0100063:	e8 8f 38 00 00       	call   f01038f7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 c0 3d 10 f0 	movl   $0xf0103dc0,(%esp)
f010007c:	e8 26 2d 00 00       	call   f0102da7 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 a7 10 00 00       	call   f010112d <mem_init>

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
f01000c1:	c7 04 24 db 3d 10 f0 	movl   $0xf0103ddb,(%esp)
f01000c8:	e8 da 2c 00 00       	call   f0102da7 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 9b 2c 00 00       	call   f0102d74 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 01 4d 10 f0 	movl   $0xf0104d01,(%esp)
f01000e0:	e8 c2 2c 00 00       	call   f0102da7 <cprintf>
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
f010010b:	c7 04 24 f3 3d 10 f0 	movl   $0xf0103df3,(%esp)
f0100112:	e8 90 2c 00 00       	call   f0102da7 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 4e 2c 00 00       	call   f0102d74 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 01 4d 10 f0 	movl   $0xf0104d01,(%esp)
f010012d:	e8 75 2c 00 00       	call   f0102da7 <cprintf>
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
f01001e5:	0f b6 82 60 3f 10 f0 	movzbl -0xfefc0a0(%edx),%eax
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
f0100222:	0f b6 82 60 3f 10 f0 	movzbl -0xfefc0a0(%edx),%eax
f0100229:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 60 3e 10 f0 	movzbl -0xfefc1a0(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 40 3e 10 f0 	mov    -0xfefc1c0(,%ecx,4),%ecx
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
f0100282:	c7 04 24 0d 3e 10 f0 	movl   $0xf0103e0d,(%esp)
f0100289:	e8 19 2b 00 00       	call   f0102da7 <cprintf>
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
f0100429:	e8 16 35 00 00       	call   f0103944 <memmove>
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
f01005dd:	c7 04 24 19 3e 10 f0 	movl   $0xf0103e19,(%esp)
f01005e4:	e8 be 27 00 00       	call   f0102da7 <cprintf>
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
f0100626:	c7 44 24 08 60 40 10 	movl   $0xf0104060,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 7e 40 10 	movl   $0xf010407e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 83 40 10 f0 	movl   $0xf0104083,(%esp)
f010063d:	e8 65 27 00 00       	call   f0102da7 <cprintf>
f0100642:	c7 44 24 08 20 41 10 	movl   $0xf0104120,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 8c 40 10 	movl   $0xf010408c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 83 40 10 f0 	movl   $0xf0104083,(%esp)
f0100659:	e8 49 27 00 00       	call   f0102da7 <cprintf>
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
f010066b:	c7 04 24 95 40 10 f0 	movl   $0xf0104095,(%esp)
f0100672:	e8 30 27 00 00       	call   f0102da7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100677:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010067e:	00 
f010067f:	c7 04 24 48 41 10 f0 	movl   $0xf0104148,(%esp)
f0100686:	e8 1c 27 00 00       	call   f0102da7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068b:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100692:	00 
f0100693:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069a:	f0 
f010069b:	c7 04 24 70 41 10 f0 	movl   $0xf0104170,(%esp)
f01006a2:	e8 00 27 00 00       	call   f0102da7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a7:	c7 44 24 08 a5 3d 10 	movl   $0x103da5,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 a5 3d 10 	movl   $0xf0103da5,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 94 41 10 f0 	movl   $0xf0104194,(%esp)
f01006be:	e8 e4 26 00 00       	call   f0102da7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c3:	c7 44 24 08 00 73 11 	movl   $0x117300,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 00 73 11 	movl   $0xf0117300,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 b8 41 10 f0 	movl   $0xf01041b8,(%esp)
f01006da:	e8 c8 26 00 00       	call   f0102da7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	c7 44 24 08 70 79 11 	movl   $0x117970,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 70 79 11 	movl   $0xf0117970,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 dc 41 10 f0 	movl   $0xf01041dc,(%esp)
f01006f6:	e8 ac 26 00 00       	call   f0102da7 <cprintf>
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
f010071c:	c7 04 24 00 42 10 f0 	movl   $0xf0104200,(%esp)
f0100723:	e8 7f 26 00 00       	call   f0102da7 <cprintf>
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
f010075e:	e8 3b 27 00 00       	call   f0102e9e <debuginfo_eip>
			cprintf("  ebp %08x eip %08x args  ",(unsigned int)ebp,*eip );
f0100763:	8b 43 04             	mov    0x4(%ebx),%eax
f0100766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010076e:	c7 04 24 ae 40 10 f0 	movl   $0xf01040ae,(%esp)
f0100775:	e8 2d 26 00 00       	call   f0102da7 <cprintf>
f010077a:	8d 7d bc             	lea    -0x44(%ebp),%edi
			for(i=0;i<5;++i)
			cprintf("%08x  ", arg[i]);
f010077d:	8b 07                	mov    (%edi),%eax
f010077f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100783:	c7 04 24 c9 40 10 f0 	movl   $0xf01040c9,(%esp)
f010078a:	e8 18 26 00 00       	call   f0102da7 <cprintf>
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
f0100796:	c7 04 24 01 4d 10 f0 	movl   $0xf0104d01,(%esp)
f010079d:	e8 05 26 00 00       	call   f0102da7 <cprintf>
			
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
f01007c8:	c7 04 24 d0 40 10 f0 	movl   $0xf01040d0,(%esp)
f01007cf:	e8 d3 25 00 00       	call   f0102da7 <cprintf>
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
f01007fa:	c7 04 24 2c 42 10 f0 	movl   $0xf010422c,(%esp)
f0100801:	e8 a1 25 00 00       	call   f0102da7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100806:	c7 04 24 50 42 10 f0 	movl   $0xf0104250,(%esp)
f010080d:	e8 95 25 00 00       	call   f0102da7 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 e1 40 10 f0 	movl   $0xf01040e1,(%esp)
f0100819:	e8 82 2e 00 00       	call   f01036a0 <readline>
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
f010084a:	c7 04 24 e5 40 10 f0 	movl   $0xf01040e5,(%esp)
f0100851:	e8 64 30 00 00       	call   f01038ba <strchr>
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
f010086c:	c7 04 24 ea 40 10 f0 	movl   $0xf01040ea,(%esp)
f0100873:	e8 2f 25 00 00       	call   f0102da7 <cprintf>
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
f0100894:	c7 04 24 e5 40 10 f0 	movl   $0xf01040e5,(%esp)
f010089b:	e8 1a 30 00 00       	call   f01038ba <strchr>
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
f01008b6:	c7 44 24 04 7e 40 10 	movl   $0xf010407e,0x4(%esp)
f01008bd:	f0 
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 93 2f 00 00       	call   f010385c <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1b                	je     f01008e8 <monitor+0xf7>
f01008cd:	c7 44 24 04 8c 40 10 	movl   $0xf010408c,0x4(%esp)
f01008d4:	f0 
f01008d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d8:	89 04 24             	mov    %eax,(%esp)
f01008db:	e8 7c 2f 00 00       	call   f010385c <strcmp>
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
f0100903:	ff 14 85 80 42 10 f0 	call   *-0xfefbd80(,%eax,4)


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
f010091a:	c7 04 24 07 41 10 f0 	movl   $0xf0104107,(%esp)
f0100921:	e8 81 24 00 00       	call   f0102da7 <cprintf>
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
f0100937:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f010093e:	75 11                	jne    f0100951 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);	
f0100940:	ba 6f 89 11 f0       	mov    $0xf011896f,%edx
f0100945:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094b:	89 15 3c 75 11 f0    	mov    %edx,0xf011753c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
		return nextfree;
f0100951:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n==0)
f0100957:	85 c0                	test   %eax,%eax
f0100959:	74 17                	je     f0100972 <boot_alloc+0x3e>
		return nextfree;
	result = nextfree;
f010095b:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f0100961:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	
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
f0100999:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f010099f:	72 20                	jb     f01009c1 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009a1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01009a5:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f01009ac:	f0 
f01009ad:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f01009b4:	00 
f01009b5:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f01009f8:	e8 3a 23 00 00       	call   f0102d37 <mc146818_read>
f01009fd:	89 c6                	mov    %eax,%esi
f01009ff:	83 c3 01             	add    $0x1,%ebx
f0100a02:	89 1c 24             	mov    %ebx,(%esp)
f0100a05:	e8 2d 23 00 00       	call   f0102d37 <mc146818_read>
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
f0100a2f:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0100a35:	85 d2                	test   %edx,%edx
f0100a37:	75 1c                	jne    f0100a55 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100a39:	c7 44 24 08 b4 42 10 	movl   $0xf01042b4,0x8(%esp)
f0100a40:	f0 
f0100a41:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100a48:	00 
f0100a49:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0100a67:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
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
f0100a9f:	a3 40 75 11 f0       	mov    %eax,0xf0117540
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aa4:	8b 1d 40 75 11 f0    	mov    0xf0117540,%ebx
f0100aaa:	eb 63                	jmp    f0100b0f <check_page_free_list+0xf6>
f0100aac:	89 d8                	mov    %ebx,%eax
f0100aae:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
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
f0100ac8:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100ace:	72 20                	jb     f0100af0 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ad4:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0100adb:	f0 
f0100adc:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ae3:	00 
f0100ae4:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0100aeb:	e8 a4 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100af7:	00 
f0100af8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100aff:	00 
	return (void *)(pa + KERNBASE);
f0100b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b05:	89 04 24             	mov    %eax,(%esp)
f0100b08:	e8 ea 2d 00 00       	call   f01038f7 <memset>
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
f0100b20:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b26:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100b2c:	a1 64 79 11 f0       	mov    0xf0117964,%eax
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
f0100b4f:	c7 44 24 0c 6a 4a 10 	movl   $0xf0104a6a,0xc(%esp)
f0100b56:	f0 
f0100b57:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100b5e:	f0 
f0100b5f:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f0100b66:	00 
f0100b67:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100b6e:	e8 21 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b73:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b76:	72 24                	jb     f0100b9c <check_page_free_list+0x183>
f0100b78:	c7 44 24 0c 8b 4a 10 	movl   $0xf0104a8b,0xc(%esp)
f0100b7f:	f0 
f0100b80:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100b87:	f0 
f0100b88:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0100b8f:	00 
f0100b90:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100b97:	e8 f8 f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b9c:	89 d0                	mov    %edx,%eax
f0100b9e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ba1:	a8 07                	test   $0x7,%al
f0100ba3:	74 24                	je     f0100bc9 <check_page_free_list+0x1b0>
f0100ba5:	c7 44 24 0c d8 42 10 	movl   $0xf01042d8,0xc(%esp)
f0100bac:	f0 
f0100bad:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100bb4:	f0 
f0100bb5:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
f0100bbc:	00 
f0100bbd:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0100bd3:	c7 44 24 0c 9f 4a 10 	movl   $0xf0104a9f,0xc(%esp)
f0100bda:	f0 
f0100bdb:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100be2:	f0 
f0100be3:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100bea:	00 
f0100beb:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100bf2:	e8 9d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bf7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bfc:	75 24                	jne    f0100c22 <check_page_free_list+0x209>
f0100bfe:	c7 44 24 0c b0 4a 10 	movl   $0xf0104ab0,0xc(%esp)
f0100c05:	f0 
f0100c06:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100c0d:	f0 
f0100c0e:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0100c15:	00 
f0100c16:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100c1d:	e8 72 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c22:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c27:	75 24                	jne    f0100c4d <check_page_free_list+0x234>
f0100c29:	c7 44 24 0c 0c 43 10 	movl   $0xf010430c,0xc(%esp)
f0100c30:	f0 
f0100c31:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100c38:	f0 
f0100c39:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0100c40:	00 
f0100c41:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100c48:	e8 47 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c4d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c52:	75 24                	jne    f0100c78 <check_page_free_list+0x25f>
f0100c54:	c7 44 24 0c c9 4a 10 	movl   $0xf0104ac9,0xc(%esp)
f0100c5b:	f0 
f0100c5c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100c63:	f0 
f0100c64:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100c6b:	00 
f0100c6c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0100c8d:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0100c94:	f0 
f0100c95:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c9c:	00 
f0100c9d:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0100ca4:	e8 eb f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100ca9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cae:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100cb1:	76 29                	jbe    f0100cdc <check_page_free_list+0x2c3>
f0100cb3:	c7 44 24 0c 30 43 10 	movl   $0xf0104330,0xc(%esp)
f0100cba:	f0 
f0100cbb:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100cc2:	f0 
f0100cc3:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100cca:	00 
f0100ccb:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0100ced:	c7 44 24 0c e3 4a 10 	movl   $0xf0104ae3,0xc(%esp)
f0100cf4:	f0 
f0100cf5:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100cfc:	f0 
f0100cfd:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100d04:	00 
f0100d05:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100d0c:	e8 83 f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d11:	85 db                	test   %ebx,%ebx
f0100d13:	7f 24                	jg     f0100d39 <check_page_free_list+0x320>
f0100d15:	c7 44 24 0c f5 4a 10 	movl   $0xf0104af5,0xc(%esp)
f0100d1c:	f0 
f0100d1d:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0100d24:	f0 
f0100d25:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100d2c:	00 
f0100d2d:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0100d59:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100d5e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d6a:	e9 a5 00 00 00       	jmp    f0100e14 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d6f:	3b 1d 38 75 11 f0    	cmp    0xf0117538,%ebx
f0100d75:	73 25                	jae    f0100d9c <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d77:	89 f0                	mov    %esi,%eax
f0100d79:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100d7f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d85:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0100d8b:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d8d:	89 f0                	mov    %esi,%eax
f0100d8f:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100d95:	a3 40 75 11 f0       	mov    %eax,0xf0117540
f0100d9a:	eb 78                	jmp    f0100e14 <page_init+0xd3>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d9c:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100da2:	83 f8 5f             	cmp    $0x5f,%eax
f0100da5:	77 16                	ja     f0100dbd <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100da7:	89 f0                	mov    %esi,%eax
f0100da9:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
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
f0100ddd:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100de3:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100de9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100def:	eb 23                	jmp    f0100e14 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100df1:	89 f0                	mov    %esi,%eax
f0100df3:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100df9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dff:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0100e05:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100e07:	89 f0                	mov    %esi,%eax
f0100e09:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100e0f:	a3 40 75 11 f0       	mov    %eax,0xf0117540
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100e14:	83 c3 01             	add    $0x1,%ebx
f0100e17:	83 c6 08             	add    $0x8,%esi
f0100e1a:	3b 1d 64 79 11 f0    	cmp    0xf0117964,%ebx
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
f0100e31:	8b 1d 40 75 11 f0    	mov    0xf0117540,%ebx
f0100e37:	85 db                	test   %ebx,%ebx
f0100e39:	74 6b                	je     f0100ea6 <page_alloc+0x7c>
		return NULL;
	
		struct PageInfo* page = page_free_list;
		page_free_list = page->pp_link;
f0100e3b:	8b 03                	mov    (%ebx),%eax
f0100e3d:	a3 40 75 11 f0       	mov    %eax,0xf0117540
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
f0100e50:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100e56:	c1 f8 03             	sar    $0x3,%eax
f0100e59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e5c:	89 c2                	mov    %eax,%edx
f0100e5e:	c1 ea 0c             	shr    $0xc,%edx
f0100e61:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100e67:	72 20                	jb     f0100e89 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e6d:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0100e74:	f0 
f0100e75:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e7c:	00 
f0100e7d:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
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
f0100ea1:	e8 51 2a 00 00       	call   f01038f7 <memset>
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
f0100ec3:	c7 44 24 08 78 43 10 	movl   $0xf0104378,0x8(%esp)
f0100eca:	f0 
f0100ecb:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0100ed2:	00 
f0100ed3:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100eda:	e8 b5 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100edf:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0100ee5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ee7:	a3 40 75 11 f0       	mov    %eax,0xf0117540
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
{	
f0100f11:	55                   	push   %ebp
f0100f12:	89 e5                	mov    %esp,%ebp
f0100f14:	56                   	push   %esi
f0100f15:	53                   	push   %ebx
f0100f16:	83 ec 10             	sub    $0x10,%esp
f0100f19:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int pdx =(physaddr_t)(va) >>22 & 0x3FF;
f0100f1c:	89 f3                	mov    %esi,%ebx
f0100f1e:	c1 eb 16             	shr    $0x16,%ebx
	//
	// va->base address of the pte; has not add the pageTable offset;
	//
	pgdir = pgdir + pdx;
f0100f21:	c1 e3 02             	shl    $0x2,%ebx
f0100f24:	03 5d 08             	add    0x8(%ebp),%ebx
	if(*pgdir == 0 )
f0100f27:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f2a:	75 2c                	jne    f0100f58 <pgdir_walk+0x47>
	{
		if(create == 0)
f0100f2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f30:	74 6c                	je     f0100f9e <pgdir_walk+0x8d>
			return NULL;
		struct PageInfo* newPage = page_alloc(1);
f0100f32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f39:	e8 ec fe ff ff       	call   f0100e2a <page_alloc>
		if(newPage == NULL)
f0100f3e:	85 c0                	test   %eax,%eax
f0100f40:	74 63                	je     f0100fa5 <pgdir_walk+0x94>
			return NULL;
		newPage->pp_ref++;
f0100f42:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f47:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f4d:	c1 f8 03             	sar    $0x3,%eax
f0100f50:	c1 e0 0c             	shl    $0xc,%eax
		*pgdir = page2pa(newPage);	//物理地址
		*pgdir |= (PTE_P |PTE_W | PTE_U);	//不懂
f0100f53:	83 c8 07             	or     $0x7,%eax
f0100f56:	89 03                	mov    %eax,(%ebx)
	}

	unsigned int ptx = (physaddr_t)(va) >>12 & 0x3FF;
	pte_t pte_pa = *pgdir & (~0xFFF); 				//va对应的pte页表的首项物理地址 
f0100f58:	8b 03                	mov    (%ebx),%eax
f0100f5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5f:	89 c2                	mov    %eax,%edx
f0100f61:	c1 ea 0c             	shr    $0xc,%edx
f0100f64:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100f6a:	72 20                	jb     f0100f8c <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f70:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0100f77:	f0 
f0100f78:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0100f7f:	00 
f0100f80:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0100f87:	e8 08 f1 ff ff       	call   f0100094 <_panic>
		newPage->pp_ref++;
		*pgdir = page2pa(newPage);	//物理地址
		*pgdir |= (PTE_P |PTE_W | PTE_U);	//不懂
	}

	unsigned int ptx = (physaddr_t)(va) >>12 & 0x3FF;
f0100f8c:	c1 ee 0a             	shr    $0xa,%esi
	pte_t pte_pa = *pgdir & (~0xFFF); 				//va对应的pte页表的首项物理地址 
	pte_t* vPte = KADDR(pte_pa);				//得到pte的虚拟地址（+kernbase）,并把地址赋给vPte;
	return &vPte[ptx];					//返回的是va对应的pte项的虚拟地址
f0100f8f:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f95:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f9c:	eb 0c                	jmp    f0100faa <pgdir_walk+0x99>
	//
	pgdir = pgdir + pdx;
	if(*pgdir == 0 )
	{
		if(create == 0)
			return NULL;
f0100f9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa3:	eb 05                	jmp    f0100faa <pgdir_walk+0x99>
		struct PageInfo* newPage = page_alloc(1);
		if(newPage == NULL)
			return NULL;
f0100fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	return &vPte[ptx];					//返回的是va对应的pte项的虚拟地址
	//需要返回虚拟地址，而不是物理地址，搞死人啊！！！
	//pte_t* vaPTE = (physaddr_t*) ((*vaPTEBaseAddrePointer >> 12 << 12) +ptOffset) ;
	//return vaPTE;

}
f0100faa:	83 c4 10             	add    $0x10,%esp
f0100fad:	5b                   	pop    %ebx
f0100fae:	5e                   	pop    %esi
f0100faf:	5d                   	pop    %ebp
f0100fb0:	c3                   	ret    

f0100fb1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fb1:	55                   	push   %ebp
f0100fb2:	89 e5                	mov    %esp,%ebp
f0100fb4:	53                   	push   %ebx
f0100fb5:	83 ec 14             	sub    $0x14,%esp
f0100fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t * pt = pgdir_walk(pgdir, va,0);
f0100fbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fc2:	00 
f0100fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fca:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fcd:	89 04 24             	mov    %eax,(%esp)
f0100fd0:	e8 3c ff ff ff       	call   f0100f11 <pgdir_walk>
	if(pt == NULL )
f0100fd5:	85 c0                	test   %eax,%eax
f0100fd7:	74 3a                	je     f0101013 <page_lookup+0x62>
		return NULL;
	if( pte_store != NULL)
f0100fd9:	85 db                	test   %ebx,%ebx
f0100fdb:	74 02                	je     f0100fdf <page_lookup+0x2e>
		*pte_store = pt;
f0100fdd:	89 03                	mov    %eax,(%ebx)
	//struct PageInfo* ret = pa2page( (pte_t) pageTable);
	struct PageInfo* page = pa2page(  *pt & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
f0100fdf:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe1:	c1 e8 0c             	shr    $0xc,%eax
f0100fe4:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100fea:	72 1c                	jb     f0101008 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fec:	c7 44 24 08 b8 43 10 	movl   $0xf01043b8,0x8(%esp)
f0100ff3:	f0 
f0100ff4:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100ffb:	00 
f0100ffc:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0101003:	e8 8c f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101008:	c1 e0 03             	shl    $0x3,%eax
f010100b:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
	return page;
f0101011:	eb 05                	jmp    f0101018 <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * pt = pgdir_walk(pgdir, va,0);
	if(pt == NULL )
		return NULL;
f0101013:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo* page = pa2page(  *pt & ~0xFFF);	//pgdir_walk中给出的pageTable的地址是虚拟地址
	return page;

	// Fill this function in
	
}
f0101018:	83 c4 14             	add    $0x14,%esp
f010101b:	5b                   	pop    %ebx
f010101c:	5d                   	pop    %ebp
f010101d:	c3                   	ret    

f010101e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010101e:	55                   	push   %ebp
f010101f:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101021:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101024:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101027:	5d                   	pop    %ebp
f0101028:	c3                   	ret    

f0101029 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{	
f0101029:	55                   	push   %ebp
f010102a:	89 e5                	mov    %esp,%ebp
f010102c:	83 ec 28             	sub    $0x28,%esp
f010102f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101032:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101035:	8b 75 08             	mov    0x8(%ebp),%esi
f0101038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//有问题  还要再看看
	pte_t * pte = 0 ;
f010103b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	pte_t ** pt_store = &pte;
f0101042:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101045:	89 44 24 08          	mov    %eax,0x8(%esp)
	struct PageInfo* phyPage = page_lookup(pgdir, va, pt_store);
f0101049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010104d:	89 34 24             	mov    %esi,(%esp)
f0101050:	e8 5c ff ff ff       	call   f0100fb1 <page_lookup>
	if(phyPage == 0)
f0101055:	85 c0                	test   %eax,%eax
f0101057:	74 1d                	je     f0101076 <page_remove+0x4d>
		return ;
	page_decref(phyPage);
f0101059:	89 04 24             	mov    %eax,(%esp)
f010105c:	e8 8d fe ff ff       	call   f0100eee <page_decref>
	*pte = 0;
f0101061:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101064:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//
	//remove的操作相当于把va和其对应的物理地址断开联系，感觉只有在va重新映射的时候
	//才会调用这个函数。而tlb_invalidate(va)函数的作用，就是把TLB中，va的缓存清除掉。
	//TLB，mmu的转换缓存，以并行方式查找，速度很快，是va->pa转换速度的前提。
	//
	tlb_invalidate(pgdir,va);	
f010106a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010106e:	89 34 24             	mov    %esi,(%esp)
f0101071:	e8 a8 ff ff ff       	call   f010101e <tlb_invalidate>
	return;
}
f0101076:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101079:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010107c:	89 ec                	mov    %ebp,%esp
f010107e:	5d                   	pop    %ebp
f010107f:	c3                   	ret    

f0101080 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101080:	55                   	push   %ebp
f0101081:	89 e5                	mov    %esp,%ebp
f0101083:	83 ec 28             	sub    $0x28,%esp
f0101086:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101089:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010108c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010108f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101092:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* PT = pgdir_walk(pgdir,va,1);
f0101095:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010109c:	00 
f010109d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a4:	89 04 24             	mov    %eax,(%esp)
f01010a7:	e8 65 fe ff ff       	call   f0100f11 <pgdir_walk>
f01010ac:	89 c6                	mov    %eax,%esi
	if(PT == NULL)
f01010ae:	85 c0                	test   %eax,%eax
f01010b0:	74 69                	je     f010111b <page_insert+0x9b>
		return -E_NO_MEM;
	// va 已经指向了pp
	if( (*PT & ~0xFFF) == page2pa(pp) )	//*vaPT里面存储的是va所在页的物理地址
f01010b2:	8b 00                	mov    (%eax),%eax
f01010b4:	89 c1                	mov    %eax,%ecx
f01010b6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010bc:	89 da                	mov    %ebx,%edx
f01010be:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01010c4:	c1 fa 03             	sar    $0x3,%edx
f01010c7:	c1 e2 0c             	shl    $0xc,%edx
f01010ca:	39 d1                	cmp    %edx,%ecx
f01010cc:	75 16                	jne    f01010e4 <page_insert+0x64>
		{
			tlb_invalidate(pgdir,va);	//为什么？
f01010ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d5:	89 04 24             	mov    %eax,(%esp)
f01010d8:	e8 41 ff ff ff       	call   f010101e <tlb_invalidate>
			pp->pp_ref--;
f01010dd:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01010e2:	eb 13                	jmp    f01010f7 <page_insert+0x77>
		}
	//若va已经分配，则取消其分配 简单检测*vaPT里面的值是否是0来判断
	else  if(*PT != 0)	
f01010e4:	85 c0                	test   %eax,%eax
f01010e6:	74 0f                	je     f01010f7 <page_insert+0x77>
		page_remove(pgdir,va);
f01010e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ef:	89 04 24             	mov    %eax,(%esp)
f01010f2:	e8 32 ff ff ff       	call   f0101029 <page_remove>
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	PT[0] = page2pa(pp)| perm | PTE_P;
f01010f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fa:	83 c8 01             	or     $0x1,%eax
f01010fd:	89 da                	mov    %ebx,%edx
f01010ff:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101105:	c1 fa 03             	sar    $0x3,%edx
f0101108:	c1 e2 0c             	shl    $0xc,%edx
f010110b:	09 d0                	or     %edx,%eax
f010110d:	89 06                	mov    %eax,(%esi)
	pp->pp_ref ++;
f010110f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0; 
f0101114:	b8 00 00 00 00       	mov    $0x0,%eax
f0101119:	eb 05                	jmp    f0101120 <page_insert+0xa0>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* PT = pgdir_walk(pgdir,va,1);
	if(PT == NULL)
		return -E_NO_MEM;
f010111b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	//*vaPT = page2pa(pp);
	//pte_t test = *vaPT;
	PT[0] = page2pa(pp)| perm | PTE_P;
	pp->pp_ref ++;
	return 0; 
}
f0101120:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101123:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101126:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101129:	89 ec                	mov    %ebp,%esp
f010112b:	5d                   	pop    %ebp
f010112c:	c3                   	ret    

f010112d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010112d:	55                   	push   %ebp
f010112e:	89 e5                	mov    %esp,%ebp
f0101130:	57                   	push   %edi
f0101131:	56                   	push   %esi
f0101132:	53                   	push   %ebx
f0101133:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101136:	b8 15 00 00 00       	mov    $0x15,%eax
f010113b:	e8 a7 f8 ff ff       	call   f01009e7 <nvram_read>
f0101140:	c1 e0 0a             	shl    $0xa,%eax
f0101143:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101149:	85 c0                	test   %eax,%eax
f010114b:	0f 48 c2             	cmovs  %edx,%eax
f010114e:	c1 f8 0c             	sar    $0xc,%eax
f0101151:	a3 38 75 11 f0       	mov    %eax,0xf0117538
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101156:	b8 17 00 00 00       	mov    $0x17,%eax
f010115b:	e8 87 f8 ff ff       	call   f01009e7 <nvram_read>
f0101160:	c1 e0 0a             	shl    $0xa,%eax
f0101163:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101169:	85 c0                	test   %eax,%eax
f010116b:	0f 48 c2             	cmovs  %edx,%eax
f010116e:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101171:	85 c0                	test   %eax,%eax
f0101173:	74 0e                	je     f0101183 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101175:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010117b:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
f0101181:	eb 0c                	jmp    f010118f <mem_init+0x62>
	else
		npages = npages_basemem;
f0101183:	8b 15 38 75 11 f0    	mov    0xf0117538,%edx
f0101189:	89 15 64 79 11 f0    	mov    %edx,0xf0117964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010118f:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101192:	c1 e8 0a             	shr    $0xa,%eax
f0101195:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101199:	a1 38 75 11 f0       	mov    0xf0117538,%eax
f010119e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011a1:	c1 e8 0a             	shr    $0xa,%eax
f01011a4:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01011a8:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01011ad:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011b0:	c1 e8 0a             	shr    $0xa,%eax
f01011b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011b7:	c7 04 24 d8 43 10 f0 	movl   $0xf01043d8,(%esp)
f01011be:	e8 e4 1b 00 00       	call   f0102da7 <cprintf>
	//typedef uint32_t pde_t;
	//pde_t *kern_pgdir;		// Kernel's initial page directory
	//#define PGSIZE		4096		// bytes mapped by a page

	//kern_padir得到，即这条语句生申请了一个页面，kern_padir是新页面的头地址
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011c3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011c8:	e8 67 f7 ff ff       	call   f0100934 <boot_alloc>
f01011cd:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f01011d2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011d9:	00 
f01011da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011e1:	00 
f01011e2:	89 04 24             	mov    %eax,(%esp)
f01011e5:	e8 0d 27 00 00       	call   f01038f7 <memset>
	// a virtual pnage table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011ea:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011f4:	77 20                	ja     f0101216 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011fa:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f0101201:	f0 
f0101202:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
f0101209:	00 
f010120a:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101211:	e8 7e ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101216:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010121c:	83 ca 05             	or     $0x5,%edx
f010121f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	{ 	//Next page on the free list.
		struct PageInfo *pp_link;
		uint16_t pp_ref;
		}
********************************************/
	pages = (struct PageInfo* ) boot_alloc(npages * sizeof( struct PageInfo) );
f0101225:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010122a:	c1 e0 03             	shl    $0x3,%eax
f010122d:	e8 02 f7 ff ff       	call   f0100934 <boot_alloc>
f0101232:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages,0,npages * sizeof(struct PageInfo) )  ;
f0101237:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f010123d:	c1 e2 03             	shl    $0x3,%edx
f0101240:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101244:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010124b:	00 
f010124c:	89 04 24             	mov    %eax,(%esp)
f010124f:	e8 a3 26 00 00       	call   f01038f7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101254:	e8 e8 fa ff ff       	call   f0100d41 <page_init>

	check_page_free_list(1);
f0101259:	b8 01 00 00 00       	mov    $0x1,%eax
f010125e:	e8 b6 f7 ff ff       	call   f0100a19 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101263:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f010126a:	75 1c                	jne    f0101288 <mem_init+0x15b>
		panic("'pages' is a null pointer!");
f010126c:	c7 44 24 08 06 4b 10 	movl   $0xf0104b06,0x8(%esp)
f0101273:	f0 
f0101274:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f010127b:	00 
f010127c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101283:	e8 0c ee ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101288:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f010128d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101292:	eb 05                	jmp    f0101299 <mem_init+0x16c>
		++nfree;
f0101294:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101297:	8b 00                	mov    (%eax),%eax
f0101299:	85 c0                	test   %eax,%eax
f010129b:	75 f7                	jne    f0101294 <mem_init+0x167>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010129d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012a4:	e8 81 fb ff ff       	call   f0100e2a <page_alloc>
f01012a9:	89 c6                	mov    %eax,%esi
f01012ab:	85 c0                	test   %eax,%eax
f01012ad:	75 24                	jne    f01012d3 <mem_init+0x1a6>
f01012af:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f01012b6:	f0 
f01012b7:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01012be:	f0 
f01012bf:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01012c6:	00 
f01012c7:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01012ce:	e8 c1 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012da:	e8 4b fb ff ff       	call   f0100e2a <page_alloc>
f01012df:	89 c7                	mov    %eax,%edi
f01012e1:	85 c0                	test   %eax,%eax
f01012e3:	75 24                	jne    f0101309 <mem_init+0x1dc>
f01012e5:	c7 44 24 0c 37 4b 10 	movl   $0xf0104b37,0xc(%esp)
f01012ec:	f0 
f01012ed:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01012f4:	f0 
f01012f5:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f01012fc:	00 
f01012fd:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101304:	e8 8b ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101310:	e8 15 fb ff ff       	call   f0100e2a <page_alloc>
f0101315:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101318:	85 c0                	test   %eax,%eax
f010131a:	75 24                	jne    f0101340 <mem_init+0x213>
f010131c:	c7 44 24 0c 4d 4b 10 	movl   $0xf0104b4d,0xc(%esp)
f0101323:	f0 
f0101324:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010132b:	f0 
f010132c:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0101333:	00 
f0101334:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010133b:	e8 54 ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101340:	39 fe                	cmp    %edi,%esi
f0101342:	75 24                	jne    f0101368 <mem_init+0x23b>
f0101344:	c7 44 24 0c 63 4b 10 	movl   $0xf0104b63,0xc(%esp)
f010134b:	f0 
f010134c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101353:	f0 
f0101354:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f010135b:	00 
f010135c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101363:	e8 2c ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101368:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010136b:	74 05                	je     f0101372 <mem_init+0x245>
f010136d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101370:	75 24                	jne    f0101396 <mem_init+0x269>
f0101372:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f0101379:	f0 
f010137a:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101381:	f0 
f0101382:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f0101389:	00 
f010138a:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101391:	e8 fe ec ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101396:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010139c:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01013a1:	c1 e0 0c             	shl    $0xc,%eax
f01013a4:	89 f1                	mov    %esi,%ecx
f01013a6:	29 d1                	sub    %edx,%ecx
f01013a8:	c1 f9 03             	sar    $0x3,%ecx
f01013ab:	c1 e1 0c             	shl    $0xc,%ecx
f01013ae:	39 c1                	cmp    %eax,%ecx
f01013b0:	72 24                	jb     f01013d6 <mem_init+0x2a9>
f01013b2:	c7 44 24 0c 75 4b 10 	movl   $0xf0104b75,0xc(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01013c1:	f0 
f01013c2:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f01013c9:	00 
f01013ca:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01013d1:	e8 be ec ff ff       	call   f0100094 <_panic>
f01013d6:	89 f9                	mov    %edi,%ecx
f01013d8:	29 d1                	sub    %edx,%ecx
f01013da:	c1 f9 03             	sar    $0x3,%ecx
f01013dd:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013e0:	39 c8                	cmp    %ecx,%eax
f01013e2:	77 24                	ja     f0101408 <mem_init+0x2db>
f01013e4:	c7 44 24 0c 92 4b 10 	movl   $0xf0104b92,0xc(%esp)
f01013eb:	f0 
f01013ec:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01013f3:	f0 
f01013f4:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f01013fb:	00 
f01013fc:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101403:	e8 8c ec ff ff       	call   f0100094 <_panic>
f0101408:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010140b:	29 d1                	sub    %edx,%ecx
f010140d:	89 ca                	mov    %ecx,%edx
f010140f:	c1 fa 03             	sar    $0x3,%edx
f0101412:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101415:	39 d0                	cmp    %edx,%eax
f0101417:	77 24                	ja     f010143d <mem_init+0x310>
f0101419:	c7 44 24 0c af 4b 10 	movl   $0xf0104baf,0xc(%esp)
f0101420:	f0 
f0101421:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101428:	f0 
f0101429:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101430:	00 
f0101431:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101438:	e8 57 ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010143d:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f0101442:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101445:	c7 05 40 75 11 f0 00 	movl   $0x0,0xf0117540
f010144c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010144f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101456:	e8 cf f9 ff ff       	call   f0100e2a <page_alloc>
f010145b:	85 c0                	test   %eax,%eax
f010145d:	74 24                	je     f0101483 <mem_init+0x356>
f010145f:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f0101466:	f0 
f0101467:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010146e:	f0 
f010146f:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f0101476:	00 
f0101477:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010147e:	e8 11 ec ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101483:	89 34 24             	mov    %esi,(%esp)
f0101486:	e8 23 fa ff ff       	call   f0100eae <page_free>
	page_free(pp1);
f010148b:	89 3c 24             	mov    %edi,(%esp)
f010148e:	e8 1b fa ff ff       	call   f0100eae <page_free>
	page_free(pp2);
f0101493:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101496:	89 04 24             	mov    %eax,(%esp)
f0101499:	e8 10 fa ff ff       	call   f0100eae <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010149e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a5:	e8 80 f9 ff ff       	call   f0100e2a <page_alloc>
f01014aa:	89 c6                	mov    %eax,%esi
f01014ac:	85 c0                	test   %eax,%eax
f01014ae:	75 24                	jne    f01014d4 <mem_init+0x3a7>
f01014b0:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f01014b7:	f0 
f01014b8:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01014bf:	f0 
f01014c0:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f01014c7:	00 
f01014c8:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01014cf:	e8 c0 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01014d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014db:	e8 4a f9 ff ff       	call   f0100e2a <page_alloc>
f01014e0:	89 c7                	mov    %eax,%edi
f01014e2:	85 c0                	test   %eax,%eax
f01014e4:	75 24                	jne    f010150a <mem_init+0x3dd>
f01014e6:	c7 44 24 0c 37 4b 10 	movl   $0xf0104b37,0xc(%esp)
f01014ed:	f0 
f01014ee:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01014f5:	f0 
f01014f6:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f01014fd:	00 
f01014fe:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101505:	e8 8a eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010150a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101511:	e8 14 f9 ff ff       	call   f0100e2a <page_alloc>
f0101516:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101519:	85 c0                	test   %eax,%eax
f010151b:	75 24                	jne    f0101541 <mem_init+0x414>
f010151d:	c7 44 24 0c 4d 4b 10 	movl   $0xf0104b4d,0xc(%esp)
f0101524:	f0 
f0101525:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010152c:	f0 
f010152d:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101534:	00 
f0101535:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010153c:	e8 53 eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101541:	39 fe                	cmp    %edi,%esi
f0101543:	75 24                	jne    f0101569 <mem_init+0x43c>
f0101545:	c7 44 24 0c 63 4b 10 	movl   $0xf0104b63,0xc(%esp)
f010154c:	f0 
f010154d:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101554:	f0 
f0101555:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f010155c:	00 
f010155d:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101564:	e8 2b eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101569:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010156c:	74 05                	je     f0101573 <mem_init+0x446>
f010156e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101571:	75 24                	jne    f0101597 <mem_init+0x46a>
f0101573:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f010157a:	f0 
f010157b:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101582:	f0 
f0101583:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f010158a:	00 
f010158b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101592:	e8 fd ea ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101597:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010159e:	e8 87 f8 ff ff       	call   f0100e2a <page_alloc>
f01015a3:	85 c0                	test   %eax,%eax
f01015a5:	74 24                	je     f01015cb <mem_init+0x49e>
f01015a7:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f01015ae:	f0 
f01015af:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f01015be:	00 
f01015bf:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01015c6:	e8 c9 ea ff ff       	call   f0100094 <_panic>
f01015cb:	89 f0                	mov    %esi,%eax
f01015cd:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01015d3:	c1 f8 03             	sar    $0x3,%eax
f01015d6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d9:	89 c2                	mov    %eax,%edx
f01015db:	c1 ea 0c             	shr    $0xc,%edx
f01015de:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01015e4:	72 20                	jb     f0101606 <mem_init+0x4d9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015ea:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01015f9:	00 
f01015fa:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0101601:	e8 8e ea ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101606:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010160d:	00 
f010160e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101615:	00 
	return (void *)(pa + KERNBASE);
f0101616:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010161b:	89 04 24             	mov    %eax,(%esp)
f010161e:	e8 d4 22 00 00       	call   f01038f7 <memset>
	page_free(pp0);
f0101623:	89 34 24             	mov    %esi,(%esp)
f0101626:	e8 83 f8 ff ff       	call   f0100eae <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010162b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101632:	e8 f3 f7 ff ff       	call   f0100e2a <page_alloc>
f0101637:	85 c0                	test   %eax,%eax
f0101639:	75 24                	jne    f010165f <mem_init+0x532>
f010163b:	c7 44 24 0c db 4b 10 	movl   $0xf0104bdb,0xc(%esp)
f0101642:	f0 
f0101643:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010164a:	f0 
f010164b:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0101652:	00 
f0101653:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010165a:	e8 35 ea ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010165f:	39 c6                	cmp    %eax,%esi
f0101661:	74 24                	je     f0101687 <mem_init+0x55a>
f0101663:	c7 44 24 0c f9 4b 10 	movl   $0xf0104bf9,0xc(%esp)
f010166a:	f0 
f010166b:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101672:	f0 
f0101673:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f010167a:	00 
f010167b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101682:	e8 0d ea ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101687:	89 f2                	mov    %esi,%edx
f0101689:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f010168f:	c1 fa 03             	sar    $0x3,%edx
f0101692:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101695:	89 d0                	mov    %edx,%eax
f0101697:	c1 e8 0c             	shr    $0xc,%eax
f010169a:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f01016a0:	72 20                	jb     f01016c2 <mem_init+0x595>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01016a6:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f01016ad:	f0 
f01016ae:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016b5:	00 
f01016b6:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f01016bd:	e8 d2 e9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01016c2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01016c8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016ce:	80 38 00             	cmpb   $0x0,(%eax)
f01016d1:	74 24                	je     f01016f7 <mem_init+0x5ca>
f01016d3:	c7 44 24 0c 09 4c 10 	movl   $0xf0104c09,0xc(%esp)
f01016da:	f0 
f01016db:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01016e2:	f0 
f01016e3:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01016ea:	00 
f01016eb:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01016f2:	e8 9d e9 ff ff       	call   f0100094 <_panic>
f01016f7:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016fa:	39 d0                	cmp    %edx,%eax
f01016fc:	75 d0                	jne    f01016ce <mem_init+0x5a1>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016fe:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101701:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	// free the pages we took
	page_free(pp0);
f0101707:	89 34 24             	mov    %esi,(%esp)
f010170a:	e8 9f f7 ff ff       	call   f0100eae <page_free>
	page_free(pp1);
f010170f:	89 3c 24             	mov    %edi,(%esp)
f0101712:	e8 97 f7 ff ff       	call   f0100eae <page_free>
	page_free(pp2);
f0101717:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171a:	89 04 24             	mov    %eax,(%esp)
f010171d:	e8 8c f7 ff ff       	call   f0100eae <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101722:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f0101727:	eb 05                	jmp    f010172e <mem_init+0x601>
		--nfree;
f0101729:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010172c:	8b 00                	mov    (%eax),%eax
f010172e:	85 c0                	test   %eax,%eax
f0101730:	75 f7                	jne    f0101729 <mem_init+0x5fc>
		--nfree;
	assert(nfree == 0);
f0101732:	85 db                	test   %ebx,%ebx
f0101734:	74 24                	je     f010175a <mem_init+0x62d>
f0101736:	c7 44 24 0c 13 4c 10 	movl   $0xf0104c13,0xc(%esp)
f010173d:	f0 
f010173e:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101745:	f0 
f0101746:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f010174d:	00 
f010174e:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101755:	e8 3a e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010175a:	c7 04 24 58 44 10 f0 	movl   $0xf0104458,(%esp)
f0101761:	e8 41 16 00 00       	call   f0102da7 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101766:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176d:	e8 b8 f6 ff ff       	call   f0100e2a <page_alloc>
f0101772:	89 c7                	mov    %eax,%edi
f0101774:	85 c0                	test   %eax,%eax
f0101776:	75 24                	jne    f010179c <mem_init+0x66f>
f0101778:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f010177f:	f0 
f0101780:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101787:	f0 
f0101788:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f010178f:	00 
f0101790:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101797:	e8 f8 e8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010179c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a3:	e8 82 f6 ff ff       	call   f0100e2a <page_alloc>
f01017a8:	89 c6                	mov    %eax,%esi
f01017aa:	85 c0                	test   %eax,%eax
f01017ac:	75 24                	jne    f01017d2 <mem_init+0x6a5>
f01017ae:	c7 44 24 0c 37 4b 10 	movl   $0xf0104b37,0xc(%esp)
f01017b5:	f0 
f01017b6:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01017bd:	f0 
f01017be:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f01017c5:	00 
f01017c6:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01017cd:	e8 c2 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017d9:	e8 4c f6 ff ff       	call   f0100e2a <page_alloc>
f01017de:	89 c3                	mov    %eax,%ebx
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	75 24                	jne    f0101808 <mem_init+0x6db>
f01017e4:	c7 44 24 0c 4d 4b 10 	movl   $0xf0104b4d,0xc(%esp)
f01017eb:	f0 
f01017ec:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01017f3:	f0 
f01017f4:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01017fb:	00 
f01017fc:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101803:	e8 8c e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101808:	39 f7                	cmp    %esi,%edi
f010180a:	75 24                	jne    f0101830 <mem_init+0x703>
f010180c:	c7 44 24 0c 63 4b 10 	movl   $0xf0104b63,0xc(%esp)
f0101813:	f0 
f0101814:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010181b:	f0 
f010181c:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101823:	00 
f0101824:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010182b:	e8 64 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101830:	39 c6                	cmp    %eax,%esi
f0101832:	74 04                	je     f0101838 <mem_init+0x70b>
f0101834:	39 c7                	cmp    %eax,%edi
f0101836:	75 24                	jne    f010185c <mem_init+0x72f>
f0101838:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f010183f:	f0 
f0101840:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101847:	f0 
f0101848:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f010184f:	00 
f0101850:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101857:	e8 38 e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010185c:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0101862:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101865:	c7 05 40 75 11 f0 00 	movl   $0x0,0xf0117540
f010186c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101876:	e8 af f5 ff ff       	call   f0100e2a <page_alloc>
f010187b:	85 c0                	test   %eax,%eax
f010187d:	74 24                	je     f01018a3 <mem_init+0x776>
f010187f:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f0101886:	f0 
f0101887:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010188e:	f0 
f010188f:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101896:	00 
f0101897:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010189e:	e8 f1 e7 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018b1:	00 
f01018b2:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018b7:	89 04 24             	mov    %eax,(%esp)
f01018ba:	e8 f2 f6 ff ff       	call   f0100fb1 <page_lookup>
f01018bf:	85 c0                	test   %eax,%eax
f01018c1:	74 24                	je     f01018e7 <mem_init+0x7ba>
f01018c3:	c7 44 24 0c 78 44 10 	movl   $0xf0104478,0xc(%esp)
f01018ca:	f0 
f01018cb:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01018d2:	f0 
f01018d3:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f01018da:	00 
f01018db:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01018e2:	e8 ad e7 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018e7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018ee:	00 
f01018ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018f6:	00 
f01018f7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018fb:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101900:	89 04 24             	mov    %eax,(%esp)
f0101903:	e8 78 f7 ff ff       	call   f0101080 <page_insert>
f0101908:	85 c0                	test   %eax,%eax
f010190a:	78 24                	js     f0101930 <mem_init+0x803>
f010190c:	c7 44 24 0c b0 44 10 	movl   $0xf01044b0,0xc(%esp)
f0101913:	f0 
f0101914:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010191b:	f0 
f010191c:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101923:	00 
f0101924:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010192b:	e8 64 e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101930:	89 3c 24             	mov    %edi,(%esp)
f0101933:	e8 76 f5 ff ff       	call   f0100eae <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101938:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010193f:	00 
f0101940:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101947:	00 
f0101948:	89 74 24 04          	mov    %esi,0x4(%esp)
f010194c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101951:	89 04 24             	mov    %eax,(%esp)
f0101954:	e8 27 f7 ff ff       	call   f0101080 <page_insert>
f0101959:	85 c0                	test   %eax,%eax
f010195b:	74 24                	je     f0101981 <mem_init+0x854>
f010195d:	c7 44 24 0c e0 44 10 	movl   $0xf01044e0,0xc(%esp)
f0101964:	f0 
f0101965:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010196c:	f0 
f010196d:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101974:	00 
f0101975:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010197c:	e8 13 e7 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101981:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0101987:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010198a:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010198f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101992:	8b 11                	mov    (%ecx),%edx
f0101994:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010199a:	89 f8                	mov    %edi,%eax
f010199c:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010199f:	c1 f8 03             	sar    $0x3,%eax
f01019a2:	c1 e0 0c             	shl    $0xc,%eax
f01019a5:	39 c2                	cmp    %eax,%edx
f01019a7:	74 24                	je     f01019cd <mem_init+0x8a0>
f01019a9:	c7 44 24 0c 10 45 10 	movl   $0xf0104510,0xc(%esp)
f01019b0:	f0 
f01019b1:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01019b8:	f0 
f01019b9:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f01019c0:	00 
f01019c1:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01019c8:	e8 c7 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01019d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d5:	e8 9c ef ff ff       	call   f0100976 <check_va2pa>
f01019da:	89 f2                	mov    %esi,%edx
f01019dc:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019df:	c1 fa 03             	sar    $0x3,%edx
f01019e2:	c1 e2 0c             	shl    $0xc,%edx
f01019e5:	39 d0                	cmp    %edx,%eax
f01019e7:	74 24                	je     f0101a0d <mem_init+0x8e0>
f01019e9:	c7 44 24 0c 38 45 10 	movl   $0xf0104538,0xc(%esp)
f01019f0:	f0 
f01019f1:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01019f8:	f0 
f01019f9:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0101a00:	00 
f0101a01:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101a08:	e8 87 e6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101a0d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a12:	74 24                	je     f0101a38 <mem_init+0x90b>
f0101a14:	c7 44 24 0c 1e 4c 10 	movl   $0xf0104c1e,0xc(%esp)
f0101a1b:	f0 
f0101a1c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101a23:	f0 
f0101a24:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101a2b:	00 
f0101a2c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101a33:	e8 5c e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101a38:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a3d:	74 24                	je     f0101a63 <mem_init+0x936>
f0101a3f:	c7 44 24 0c 2f 4c 10 	movl   $0xf0104c2f,0xc(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101a4e:	f0 
f0101a4f:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101a56:	00 
f0101a57:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101a5e:	e8 31 e6 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a63:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a6a:	00 
f0101a6b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a72:	00 
f0101a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a7a:	89 14 24             	mov    %edx,(%esp)
f0101a7d:	e8 fe f5 ff ff       	call   f0101080 <page_insert>
f0101a82:	85 c0                	test   %eax,%eax
f0101a84:	74 24                	je     f0101aaa <mem_init+0x97d>
f0101a86:	c7 44 24 0c 68 45 10 	movl   $0xf0104568,0xc(%esp)
f0101a8d:	f0 
f0101a8e:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101a95:	f0 
f0101a96:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a9d:	00 
f0101a9e:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101aa5:	e8 ea e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aaa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aaf:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ab4:	e8 bd ee ff ff       	call   f0100976 <check_va2pa>
f0101ab9:	89 da                	mov    %ebx,%edx
f0101abb:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101ac1:	c1 fa 03             	sar    $0x3,%edx
f0101ac4:	c1 e2 0c             	shl    $0xc,%edx
f0101ac7:	39 d0                	cmp    %edx,%eax
f0101ac9:	74 24                	je     f0101aef <mem_init+0x9c2>
f0101acb:	c7 44 24 0c a4 45 10 	movl   $0xf01045a4,0xc(%esp)
f0101ad2:	f0 
f0101ad3:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101ae2:	00 
f0101ae3:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101aea:	e8 a5 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101aef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101af4:	74 24                	je     f0101b1a <mem_init+0x9ed>
f0101af6:	c7 44 24 0c 40 4c 10 	movl   $0xf0104c40,0xc(%esp)
f0101afd:	f0 
f0101afe:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101b0d:	00 
f0101b0e:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101b15:	e8 7a e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b21:	e8 04 f3 ff ff       	call   f0100e2a <page_alloc>
f0101b26:	85 c0                	test   %eax,%eax
f0101b28:	74 24                	je     f0101b4e <mem_init+0xa21>
f0101b2a:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f0101b31:	f0 
f0101b32:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101b39:	f0 
f0101b3a:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101b41:	00 
f0101b42:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101b49:	e8 46 e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b4e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b55:	00 
f0101b56:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b5d:	00 
f0101b5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b62:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101b67:	89 04 24             	mov    %eax,(%esp)
f0101b6a:	e8 11 f5 ff ff       	call   f0101080 <page_insert>
f0101b6f:	85 c0                	test   %eax,%eax
f0101b71:	74 24                	je     f0101b97 <mem_init+0xa6a>
f0101b73:	c7 44 24 0c 68 45 10 	movl   $0xf0104568,0xc(%esp)
f0101b7a:	f0 
f0101b7b:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101b82:	f0 
f0101b83:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101b8a:	00 
f0101b8b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101b92:	e8 fd e4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ba1:	e8 d0 ed ff ff       	call   f0100976 <check_va2pa>
f0101ba6:	89 da                	mov    %ebx,%edx
f0101ba8:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101bae:	c1 fa 03             	sar    $0x3,%edx
f0101bb1:	c1 e2 0c             	shl    $0xc,%edx
f0101bb4:	39 d0                	cmp    %edx,%eax
f0101bb6:	74 24                	je     f0101bdc <mem_init+0xaaf>
f0101bb8:	c7 44 24 0c a4 45 10 	movl   $0xf01045a4,0xc(%esp)
f0101bbf:	f0 
f0101bc0:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101bc7:	f0 
f0101bc8:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101bcf:	00 
f0101bd0:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101bd7:	e8 b8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101bdc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101be1:	74 24                	je     f0101c07 <mem_init+0xada>
f0101be3:	c7 44 24 0c 40 4c 10 	movl   $0xf0104c40,0xc(%esp)
f0101bea:	f0 
f0101beb:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101bfa:	00 
f0101bfb:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101c02:	e8 8d e4 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c0e:	e8 17 f2 ff ff       	call   f0100e2a <page_alloc>
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	74 24                	je     f0101c3b <mem_init+0xb0e>
f0101c17:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f0101c1e:	f0 
f0101c1f:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101c26:	f0 
f0101c27:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101c2e:	00 
f0101c2f:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101c36:	e8 59 e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c3b:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101c41:	8b 02                	mov    (%edx),%eax
f0101c43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c48:	89 c1                	mov    %eax,%ecx
f0101c4a:	c1 e9 0c             	shr    $0xc,%ecx
f0101c4d:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101c53:	72 20                	jb     f0101c75 <mem_init+0xb48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c55:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c59:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0101c60:	f0 
f0101c61:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101c68:	00 
f0101c69:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101c70:	e8 1f e4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101c75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c84:	00 
f0101c85:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c8c:	00 
f0101c8d:	89 14 24             	mov    %edx,(%esp)
f0101c90:	e8 7c f2 ff ff       	call   f0100f11 <pgdir_walk>
f0101c95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c98:	83 c2 04             	add    $0x4,%edx
f0101c9b:	39 d0                	cmp    %edx,%eax
f0101c9d:	74 24                	je     f0101cc3 <mem_init+0xb96>
f0101c9f:	c7 44 24 0c d4 45 10 	movl   $0xf01045d4,0xc(%esp)
f0101ca6:	f0 
f0101ca7:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101cb6:	00 
f0101cb7:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101cbe:	e8 d1 e3 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101cca:	00 
f0101ccb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cd2:	00 
f0101cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cd7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101cdc:	89 04 24             	mov    %eax,(%esp)
f0101cdf:	e8 9c f3 ff ff       	call   f0101080 <page_insert>
f0101ce4:	85 c0                	test   %eax,%eax
f0101ce6:	74 24                	je     f0101d0c <mem_init+0xbdf>
f0101ce8:	c7 44 24 0c 14 46 10 	movl   $0xf0104614,0xc(%esp)
f0101cef:	f0 
f0101cf0:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101cf7:	f0 
f0101cf8:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101cff:	00 
f0101d00:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101d07:	e8 88 e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d0c:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0101d12:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101d15:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d1a:	89 c8                	mov    %ecx,%eax
f0101d1c:	e8 55 ec ff ff       	call   f0100976 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d21:	89 da                	mov    %ebx,%edx
f0101d23:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101d29:	c1 fa 03             	sar    $0x3,%edx
f0101d2c:	c1 e2 0c             	shl    $0xc,%edx
f0101d2f:	39 d0                	cmp    %edx,%eax
f0101d31:	74 24                	je     f0101d57 <mem_init+0xc2a>
f0101d33:	c7 44 24 0c a4 45 10 	movl   $0xf01045a4,0xc(%esp)
f0101d3a:	f0 
f0101d3b:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101d42:	f0 
f0101d43:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101d4a:	00 
f0101d4b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101d52:	e8 3d e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d57:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d5c:	74 24                	je     f0101d82 <mem_init+0xc55>
f0101d5e:	c7 44 24 0c 40 4c 10 	movl   $0xf0104c40,0xc(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101d75:	00 
f0101d76:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101d7d:	e8 12 e3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d89:	00 
f0101d8a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d91:	00 
f0101d92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d95:	89 04 24             	mov    %eax,(%esp)
f0101d98:	e8 74 f1 ff ff       	call   f0100f11 <pgdir_walk>
f0101d9d:	f6 00 04             	testb  $0x4,(%eax)
f0101da0:	75 24                	jne    f0101dc6 <mem_init+0xc99>
f0101da2:	c7 44 24 0c 54 46 10 	movl   $0xf0104654,0xc(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101db9:	00 
f0101dba:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101dc1:	e8 ce e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dc6:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101dcb:	f6 00 04             	testb  $0x4,(%eax)
f0101dce:	75 24                	jne    f0101df4 <mem_init+0xcc7>
f0101dd0:	c7 44 24 0c 51 4c 10 	movl   $0xf0104c51,0xc(%esp)
f0101dd7:	f0 
f0101dd8:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101ddf:	f0 
f0101de0:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101de7:	00 
f0101de8:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101def:	e8 a0 e2 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101df4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dfb:	00 
f0101dfc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e03:	00 
f0101e04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e08:	89 04 24             	mov    %eax,(%esp)
f0101e0b:	e8 70 f2 ff ff       	call   f0101080 <page_insert>
f0101e10:	85 c0                	test   %eax,%eax
f0101e12:	74 24                	je     f0101e38 <mem_init+0xd0b>
f0101e14:	c7 44 24 0c 68 45 10 	movl   $0xf0104568,0xc(%esp)
f0101e1b:	f0 
f0101e1c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101e23:	f0 
f0101e24:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101e2b:	00 
f0101e2c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101e33:	e8 5c e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e3f:	00 
f0101e40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e47:	00 
f0101e48:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e4d:	89 04 24             	mov    %eax,(%esp)
f0101e50:	e8 bc f0 ff ff       	call   f0100f11 <pgdir_walk>
f0101e55:	f6 00 02             	testb  $0x2,(%eax)
f0101e58:	75 24                	jne    f0101e7e <mem_init+0xd51>
f0101e5a:	c7 44 24 0c 88 46 10 	movl   $0xf0104688,0xc(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101e71:	00 
f0101e72:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101e79:	e8 16 e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e7e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e85:	00 
f0101e86:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e8d:	00 
f0101e8e:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e93:	89 04 24             	mov    %eax,(%esp)
f0101e96:	e8 76 f0 ff ff       	call   f0100f11 <pgdir_walk>
f0101e9b:	f6 00 04             	testb  $0x4,(%eax)
f0101e9e:	74 24                	je     f0101ec4 <mem_init+0xd97>
f0101ea0:	c7 44 24 0c bc 46 10 	movl   $0xf01046bc,0xc(%esp)
f0101ea7:	f0 
f0101ea8:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101eaf:	f0 
f0101eb0:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101eb7:	00 
f0101eb8:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101ebf:	e8 d0 e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ec4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ecb:	00 
f0101ecc:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101ed3:	00 
f0101ed4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ed8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101edd:	89 04 24             	mov    %eax,(%esp)
f0101ee0:	e8 9b f1 ff ff       	call   f0101080 <page_insert>
f0101ee5:	85 c0                	test   %eax,%eax
f0101ee7:	78 24                	js     f0101f0d <mem_init+0xde0>
f0101ee9:	c7 44 24 0c f4 46 10 	movl   $0xf01046f4,0xc(%esp)
f0101ef0:	f0 
f0101ef1:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101ef8:	f0 
f0101ef9:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101f00:	00 
f0101f01:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101f08:	e8 87 e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f0d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f14:	00 
f0101f15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f1c:	00 
f0101f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f21:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f26:	89 04 24             	mov    %eax,(%esp)
f0101f29:	e8 52 f1 ff ff       	call   f0101080 <page_insert>
f0101f2e:	85 c0                	test   %eax,%eax
f0101f30:	74 24                	je     f0101f56 <mem_init+0xe29>
f0101f32:	c7 44 24 0c 2c 47 10 	movl   $0xf010472c,0xc(%esp)
f0101f39:	f0 
f0101f3a:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101f41:	f0 
f0101f42:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101f49:	00 
f0101f4a:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101f51:	e8 3e e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f5d:	00 
f0101f5e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f65:	00 
f0101f66:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f6b:	89 04 24             	mov    %eax,(%esp)
f0101f6e:	e8 9e ef ff ff       	call   f0100f11 <pgdir_walk>
f0101f73:	f6 00 04             	testb  $0x4,(%eax)
f0101f76:	74 24                	je     f0101f9c <mem_init+0xe6f>
f0101f78:	c7 44 24 0c bc 46 10 	movl   $0xf01046bc,0xc(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101f87:	f0 
f0101f88:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101f8f:	00 
f0101f90:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101f97:	e8 f8 e0 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f9c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101fa1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fa4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fa9:	e8 c8 e9 ff ff       	call   f0100976 <check_va2pa>
f0101fae:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fb1:	89 f0                	mov    %esi,%eax
f0101fb3:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101fb9:	c1 f8 03             	sar    $0x3,%eax
f0101fbc:	c1 e0 0c             	shl    $0xc,%eax
f0101fbf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fc2:	74 24                	je     f0101fe8 <mem_init+0xebb>
f0101fc4:	c7 44 24 0c 68 47 10 	movl   $0xf0104768,0xc(%esp)
f0101fcb:	f0 
f0101fcc:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0101fd3:	f0 
f0101fd4:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101fdb:	00 
f0101fdc:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0101fe3:	e8 ac e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fe8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff0:	e8 81 e9 ff ff       	call   f0100976 <check_va2pa>
f0101ff5:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ff8:	74 24                	je     f010201e <mem_init+0xef1>
f0101ffa:	c7 44 24 0c 94 47 10 	movl   $0xf0104794,0xc(%esp)
f0102001:	f0 
f0102002:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102009:	f0 
f010200a:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102011:	00 
f0102012:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102019:	e8 76 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010201e:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102023:	74 24                	je     f0102049 <mem_init+0xf1c>
f0102025:	c7 44 24 0c 67 4c 10 	movl   $0xf0104c67,0xc(%esp)
f010202c:	f0 
f010202d:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102034:	f0 
f0102035:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f010203c:	00 
f010203d:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102044:	e8 4b e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102049:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010204e:	74 24                	je     f0102074 <mem_init+0xf47>
f0102050:	c7 44 24 0c 78 4c 10 	movl   $0xf0104c78,0xc(%esp)
f0102057:	f0 
f0102058:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010205f:	f0 
f0102060:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102067:	00 
f0102068:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010206f:	e8 20 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010207b:	e8 aa ed ff ff       	call   f0100e2a <page_alloc>
f0102080:	85 c0                	test   %eax,%eax
f0102082:	74 04                	je     f0102088 <mem_init+0xf5b>
f0102084:	39 c3                	cmp    %eax,%ebx
f0102086:	74 24                	je     f01020ac <mem_init+0xf7f>
f0102088:	c7 44 24 0c c4 47 10 	movl   $0xf01047c4,0xc(%esp)
f010208f:	f0 
f0102090:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102097:	f0 
f0102098:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f010209f:	00 
f01020a0:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01020a7:	e8 e8 df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020b3:	00 
f01020b4:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020b9:	89 04 24             	mov    %eax,(%esp)
f01020bc:	e8 68 ef ff ff       	call   f0101029 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020c1:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f01020c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01020ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01020cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020d2:	e8 9f e8 ff ff       	call   f0100976 <check_va2pa>
f01020d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020da:	74 24                	je     f0102100 <mem_init+0xfd3>
f01020dc:	c7 44 24 0c e8 47 10 	movl   $0xf01047e8,0xc(%esp)
f01020e3:	f0 
f01020e4:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01020f3:	00 
f01020f4:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01020fb:	e8 94 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102100:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102105:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102108:	e8 69 e8 ff ff       	call   f0100976 <check_va2pa>
f010210d:	89 f2                	mov    %esi,%edx
f010210f:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102115:	c1 fa 03             	sar    $0x3,%edx
f0102118:	c1 e2 0c             	shl    $0xc,%edx
f010211b:	39 d0                	cmp    %edx,%eax
f010211d:	74 24                	je     f0102143 <mem_init+0x1016>
f010211f:	c7 44 24 0c 94 47 10 	movl   $0xf0104794,0xc(%esp)
f0102126:	f0 
f0102127:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010212e:	f0 
f010212f:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102136:	00 
f0102137:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010213e:	e8 51 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102143:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102148:	74 24                	je     f010216e <mem_init+0x1041>
f010214a:	c7 44 24 0c 1e 4c 10 	movl   $0xf0104c1e,0xc(%esp)
f0102151:	f0 
f0102152:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102159:	f0 
f010215a:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102161:	00 
f0102162:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102169:	e8 26 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010216e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102173:	74 24                	je     f0102199 <mem_init+0x106c>
f0102175:	c7 44 24 0c 78 4c 10 	movl   $0xf0104c78,0xc(%esp)
f010217c:	f0 
f010217d:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102184:	f0 
f0102185:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f010218c:	00 
f010218d:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102194:	e8 fb de ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102199:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021a0:	00 
f01021a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021a8:	00 
f01021a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021ad:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021b0:	89 0c 24             	mov    %ecx,(%esp)
f01021b3:	e8 c8 ee ff ff       	call   f0101080 <page_insert>
f01021b8:	85 c0                	test   %eax,%eax
f01021ba:	74 24                	je     f01021e0 <mem_init+0x10b3>
f01021bc:	c7 44 24 0c 0c 48 10 	movl   $0xf010480c,0xc(%esp)
f01021c3:	f0 
f01021c4:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01021cb:	f0 
f01021cc:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01021d3:	00 
f01021d4:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01021db:	e8 b4 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01021e0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021e5:	75 24                	jne    f010220b <mem_init+0x10de>
f01021e7:	c7 44 24 0c 89 4c 10 	movl   $0xf0104c89,0xc(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f01021fe:	00 
f01021ff:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102206:	e8 89 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010220b:	83 3e 00             	cmpl   $0x0,(%esi)
f010220e:	74 24                	je     f0102234 <mem_init+0x1107>
f0102210:	c7 44 24 0c 95 4c 10 	movl   $0xf0104c95,0xc(%esp)
f0102217:	f0 
f0102218:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010221f:	f0 
f0102220:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102227:	00 
f0102228:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010222f:	e8 60 de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102234:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010223b:	00 
f010223c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102241:	89 04 24             	mov    %eax,(%esp)
f0102244:	e8 e0 ed ff ff       	call   f0101029 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102249:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010224e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102251:	ba 00 00 00 00       	mov    $0x0,%edx
f0102256:	e8 1b e7 ff ff       	call   f0100976 <check_va2pa>
f010225b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225e:	74 24                	je     f0102284 <mem_init+0x1157>
f0102260:	c7 44 24 0c e8 47 10 	movl   $0xf01047e8,0xc(%esp)
f0102267:	f0 
f0102268:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010226f:	f0 
f0102270:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102277:	00 
f0102278:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010227f:	e8 10 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102284:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102289:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228c:	e8 e5 e6 ff ff       	call   f0100976 <check_va2pa>
f0102291:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102294:	74 24                	je     f01022ba <mem_init+0x118d>
f0102296:	c7 44 24 0c 44 48 10 	movl   $0xf0104844,0xc(%esp)
f010229d:	f0 
f010229e:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01022ad:	00 
f01022ae:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01022b5:	e8 da dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01022ba:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022bf:	74 24                	je     f01022e5 <mem_init+0x11b8>
f01022c1:	c7 44 24 0c aa 4c 10 	movl   $0xf0104caa,0xc(%esp)
f01022c8:	f0 
f01022c9:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01022d0:	f0 
f01022d1:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f01022d8:	00 
f01022d9:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01022e0:	e8 af dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01022e5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022ea:	74 24                	je     f0102310 <mem_init+0x11e3>
f01022ec:	c7 44 24 0c 78 4c 10 	movl   $0xf0104c78,0xc(%esp)
f01022f3:	f0 
f01022f4:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01022fb:	f0 
f01022fc:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102303:	00 
f0102304:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010230b:	e8 84 dd ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102317:	e8 0e eb ff ff       	call   f0100e2a <page_alloc>
f010231c:	85 c0                	test   %eax,%eax
f010231e:	74 04                	je     f0102324 <mem_init+0x11f7>
f0102320:	39 c6                	cmp    %eax,%esi
f0102322:	74 24                	je     f0102348 <mem_init+0x121b>
f0102324:	c7 44 24 0c 6c 48 10 	movl   $0xf010486c,0xc(%esp)
f010232b:	f0 
f010232c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102333:	f0 
f0102334:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010233b:	00 
f010233c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102343:	e8 4c dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102348:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010234f:	e8 d6 ea ff ff       	call   f0100e2a <page_alloc>
f0102354:	85 c0                	test   %eax,%eax
f0102356:	74 24                	je     f010237c <mem_init+0x124f>
f0102358:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f010235f:	f0 
f0102360:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102367:	f0 
f0102368:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f010236f:	00 
f0102370:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102377:	e8 18 dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010237c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102381:	8b 08                	mov    (%eax),%ecx
f0102383:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102389:	89 fa                	mov    %edi,%edx
f010238b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102391:	c1 fa 03             	sar    $0x3,%edx
f0102394:	c1 e2 0c             	shl    $0xc,%edx
f0102397:	39 d1                	cmp    %edx,%ecx
f0102399:	74 24                	je     f01023bf <mem_init+0x1292>
f010239b:	c7 44 24 0c 10 45 10 	movl   $0xf0104510,0xc(%esp)
f01023a2:	f0 
f01023a3:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01023aa:	f0 
f01023ab:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01023b2:	00 
f01023b3:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01023ba:	e8 d5 dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01023bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023c5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023ca:	74 24                	je     f01023f0 <mem_init+0x12c3>
f01023cc:	c7 44 24 0c 2f 4c 10 	movl   $0xf0104c2f,0xc(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01023db:	f0 
f01023dc:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f01023e3:	00 
f01023e4:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01023eb:	e8 a4 dc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01023f0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023f6:	89 3c 24             	mov    %edi,(%esp)
f01023f9:	e8 b0 ea ff ff       	call   f0100eae <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102405:	00 
f0102406:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010240d:	00 
f010240e:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102413:	89 04 24             	mov    %eax,(%esp)
f0102416:	e8 f6 ea ff ff       	call   f0100f11 <pgdir_walk>
f010241b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010241e:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0102424:	8b 51 04             	mov    0x4(%ecx),%edx
f0102427:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010242d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102430:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0102436:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102439:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010243c:	c1 ea 0c             	shr    $0xc,%edx
f010243f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102442:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102445:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102448:	72 23                	jb     f010246d <mem_init+0x1340>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010244a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010244d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102451:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0102458:	f0 
f0102459:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102460:	00 
f0102461:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102468:	e8 27 dc ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010246d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102470:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102476:	39 d0                	cmp    %edx,%eax
f0102478:	74 24                	je     f010249e <mem_init+0x1371>
f010247a:	c7 44 24 0c bb 4c 10 	movl   $0xf0104cbb,0xc(%esp)
f0102481:	f0 
f0102482:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102489:	f0 
f010248a:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102491:	00 
f0102492:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102499:	e8 f6 db ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010249e:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024a5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ab:	89 f8                	mov    %edi,%eax
f01024ad:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01024b3:	c1 f8 03             	sar    $0x3,%eax
f01024b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024b9:	89 c1                	mov    %eax,%ecx
f01024bb:	c1 e9 0c             	shr    $0xc,%ecx
f01024be:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024c1:	77 20                	ja     f01024e3 <mem_init+0x13b6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024c7:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f01024ce:	f0 
f01024cf:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024d6:	00 
f01024d7:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f01024de:	e8 b1 db ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ea:	00 
f01024eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024f2:	00 
	return (void *)(pa + KERNBASE);
f01024f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f8:	89 04 24             	mov    %eax,(%esp)
f01024fb:	e8 f7 13 00 00       	call   f01038f7 <memset>
	page_free(pp0);
f0102500:	89 3c 24             	mov    %edi,(%esp)
f0102503:	e8 a6 e9 ff ff       	call   f0100eae <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102508:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010250f:	00 
f0102510:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102517:	00 
f0102518:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010251d:	89 04 24             	mov    %eax,(%esp)
f0102520:	e8 ec e9 ff ff       	call   f0100f11 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102525:	89 fa                	mov    %edi,%edx
f0102527:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f010252d:	c1 fa 03             	sar    $0x3,%edx
f0102530:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102533:	89 d0                	mov    %edx,%eax
f0102535:	c1 e8 0c             	shr    $0xc,%eax
f0102538:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f010253e:	72 20                	jb     f0102560 <mem_init+0x1433>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102540:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102544:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f010254b:	f0 
f010254c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102553:	00 
f0102554:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f010255b:	e8 34 db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102560:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102569:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010256f:	f6 00 01             	testb  $0x1,(%eax)
f0102572:	74 24                	je     f0102598 <mem_init+0x146b>
f0102574:	c7 44 24 0c d3 4c 10 	movl   $0xf0104cd3,0xc(%esp)
f010257b:	f0 
f010257c:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102583:	f0 
f0102584:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f010258b:	00 
f010258c:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102593:	e8 fc da ff ff       	call   f0100094 <_panic>
f0102598:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010259b:	39 d0                	cmp    %edx,%eax
f010259d:	75 d0                	jne    f010256f <mem_init+0x1442>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010259f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01025a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025aa:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025b0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01025b3:	89 0d 40 75 11 f0    	mov    %ecx,0xf0117540

	// free the pages we took
	page_free(pp0);
f01025b9:	89 3c 24             	mov    %edi,(%esp)
f01025bc:	e8 ed e8 ff ff       	call   f0100eae <page_free>
	page_free(pp1);
f01025c1:	89 34 24             	mov    %esi,(%esp)
f01025c4:	e8 e5 e8 ff ff       	call   f0100eae <page_free>
	page_free(pp2);
f01025c9:	89 1c 24             	mov    %ebx,(%esp)
f01025cc:	e8 dd e8 ff ff       	call   f0100eae <page_free>

	cprintf("check_page() succeeded!\n");
f01025d1:	c7 04 24 ea 4c 10 f0 	movl   $0xf0104cea,(%esp)
f01025d8:	e8 ca 07 00 00       	call   f0102da7 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
		int perm = PTE_U | PTE_P ;
		int state = page_insert(kern_pgdir, pa2page (PADDR(pages) ), (void*) UPAGES, perm);
f01025dd:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e7:	77 20                	ja     f0102609 <mem_init+0x14dc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025ed:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f01025f4:	f0 
f01025f5:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f01025fc:	00 
f01025fd:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102604:	e8 8b da ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102609:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010260f:	c1 ea 0c             	shr    $0xc,%edx
f0102612:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102618:	72 1c                	jb     f0102636 <mem_init+0x1509>
		panic("pa2page called with invalid pa");
f010261a:	c7 44 24 08 b8 43 10 	movl   $0xf01043b8,0x8(%esp)
f0102621:	f0 
f0102622:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0102629:	00 
f010262a:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0102631:	e8 5e da ff ff       	call   f0100094 <_panic>
f0102636:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010263d:	00 
f010263e:	c7 44 24 08 00 00 00 	movl   $0xef000000,0x8(%esp)
f0102645:	ef 
	return &pages[PGNUM(pa)];
f0102646:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102649:	89 44 24 04          	mov    %eax,0x4(%esp)
f010264d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102652:	89 04 24             	mov    %eax,(%esp)
f0102655:	e8 26 ea ff ff       	call   f0101080 <page_insert>
		//assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
		//test
		int a = check_va2pa(kern_pgdir, UPAGES );
f010265a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010265f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102664:	e8 0d e3 ff ff       	call   f0100976 <check_va2pa>
		int b = PADDR(pages);
f0102669:	8b 1d 6c 79 11 f0    	mov    0xf011796c,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010266f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102675:	77 20                	ja     f0102697 <mem_init+0x156a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102677:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010267b:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f0102682:	f0 
f0102683:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f010268a:	00 
f010268b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102692:	e8 fd d9 ff ff       	call   f0100094 <_panic>
		cprintf( "check_va2pa(kern_pgdir, UPAGES ) =  %d  ", a);
f0102697:	89 44 24 04          	mov    %eax,0x4(%esp)
f010269b:	c7 04 24 90 48 10 f0 	movl   $0xf0104890,(%esp)
f01026a2:	e8 00 07 00 00       	call   f0102da7 <cprintf>
	return (physaddr_t)kva - KERNBASE;
f01026a7:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
		cprintf("   PADDR(pages) =   %d ",b);
f01026ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026b1:	c7 04 24 03 4d 10 f0 	movl   $0xf0104d03,(%esp)
f01026b8:	e8 ea 06 00 00       	call   f0102da7 <cprintf>
		cprintf("\n");
f01026bd:	c7 04 24 01 4d 10 f0 	movl   $0xf0104d01,(%esp)
f01026c4:	e8 de 06 00 00       	call   f0102da7 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026c9:	8b 1d 68 79 11 f0    	mov    0xf0117968,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	//for (i = 0; i < n; i += PGSIZE)
	i =0;
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026cf:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026d4:	89 d8                	mov    %ebx,%eax
f01026d6:	e8 9b e2 ff ff       	call   f0100976 <check_va2pa>
f01026db:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026e1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026e7:	77 20                	ja     f0102709 <mem_init+0x15dc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026ed:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f01026f4:	f0 
f01026f5:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f01026fc:	00 
f01026fd:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102704:	e8 8b d9 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102709:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010270f:	39 d0                	cmp    %edx,%eax
f0102711:	74 61                	je     f0102774 <mem_init+0x1647>
f0102713:	c7 44 24 0c bc 48 10 	movl   $0xf01048bc,0xc(%esp)
f010271a:	f0 
f010271b:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102722:	f0 
f0102723:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f010272a:	00 
f010272b:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102732:	e8 5d d9 ff ff       	call   f0100094 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102737:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010273d:	89 d8                	mov    %ebx,%eax
f010273f:	e8 32 e2 ff ff       	call   f0100976 <check_va2pa>
f0102744:	39 c6                	cmp    %eax,%esi
f0102746:	74 24                	je     f010276c <mem_init+0x163f>
f0102748:	c7 44 24 0c f0 48 10 	movl   $0xf01048f0,0xc(%esp)
f010274f:	f0 
f0102750:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102757:	f0 
f0102758:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010275f:	00 
f0102760:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102767:	e8 28 d9 ff ff       	call   f0100094 <_panic>
	i =0;
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010276c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102772:	eb 05                	jmp    f0102779 <mem_init+0x164c>

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	//for (i = 0; i < n; i += PGSIZE)
	i =0;
	assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102774:	be 00 00 00 00       	mov    $0x0,%esi


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102779:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010277e:	c1 e0 0c             	shl    $0xc,%eax
f0102781:	39 c6                	cmp    %eax,%esi
f0102783:	72 b2                	jb     f0102737 <mem_init+0x160a>
f0102785:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010278a:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010278f:	89 f2                	mov    %esi,%edx
f0102791:	89 d8                	mov    %ebx,%eax
f0102793:	e8 de e1 ff ff       	call   f0100976 <check_va2pa>
f0102798:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010279e:	77 24                	ja     f01027c4 <mem_init+0x1697>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a0:	c7 44 24 0c 00 d0 10 	movl   $0xf010d000,0xc(%esp)
f01027a7:	f0 
f01027a8:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f01027af:	f0 
f01027b0:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01027b7:	00 
f01027b8:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01027bf:	e8 d0 d8 ff ff       	call   f0100094 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027c4:	8d 96 00 50 11 10    	lea    0x10115000(%esi),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027ca:	39 d0                	cmp    %edx,%eax
f01027cc:	74 24                	je     f01027f2 <mem_init+0x16c5>
f01027ce:	c7 44 24 0c 18 49 10 	movl   $0xf0104918,0xc(%esp)
f01027d5:	f0 
f01027d6:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01027dd:	f0 
f01027de:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01027e5:	00 
f01027e6:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01027ed:	e8 a2 d8 ff ff       	call   f0100094 <_panic>
f01027f2:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01027f8:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01027fe:	75 8f                	jne    f010278f <mem_init+0x1662>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102800:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102805:	89 d8                	mov    %ebx,%eax
f0102807:	e8 6a e1 ff ff       	call   f0100976 <check_va2pa>
f010280c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010280f:	74 24                	je     f0102835 <mem_init+0x1708>
f0102811:	c7 44 24 0c 60 49 10 	movl   $0xf0104960,0xc(%esp)
f0102818:	f0 
f0102819:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102820:	f0 
f0102821:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0102828:	00 
f0102829:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102830:	e8 5f d8 ff ff       	call   f0100094 <_panic>
f0102835:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010283a:	ba 01 00 00 00       	mov    $0x1,%edx
f010283f:	8d 88 44 fc ff ff    	lea    -0x3bc(%eax),%ecx
f0102845:	83 f9 03             	cmp    $0x3,%ecx
f0102848:	77 39                	ja     f0102883 <mem_init+0x1756>
f010284a:	89 d6                	mov    %edx,%esi
f010284c:	d3 e6                	shl    %cl,%esi
f010284e:	89 f1                	mov    %esi,%ecx
f0102850:	f6 c1 0b             	test   $0xb,%cl
f0102853:	74 2e                	je     f0102883 <mem_init+0x1756>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102855:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102859:	0f 85 aa 00 00 00    	jne    f0102909 <mem_init+0x17dc>
f010285f:	c7 44 24 0c 1b 4d 10 	movl   $0xf0104d1b,0xc(%esp)
f0102866:	f0 
f0102867:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f010286e:	f0 
f010286f:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102876:	00 
f0102877:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010287e:	e8 11 d8 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102883:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102888:	76 55                	jbe    f01028df <mem_init+0x17b2>
				assert(pgdir[i] & PTE_P);
f010288a:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f010288d:	f6 c1 01             	test   $0x1,%cl
f0102890:	75 24                	jne    f01028b6 <mem_init+0x1789>
f0102892:	c7 44 24 0c 1b 4d 10 	movl   $0xf0104d1b,0xc(%esp)
f0102899:	f0 
f010289a:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01028a1:	f0 
f01028a2:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01028a9:	00 
f01028aa:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01028b1:	e8 de d7 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f01028b6:	f6 c1 02             	test   $0x2,%cl
f01028b9:	75 4e                	jne    f0102909 <mem_init+0x17dc>
f01028bb:	c7 44 24 0c 2c 4d 10 	movl   $0xf0104d2c,0xc(%esp)
f01028c2:	f0 
f01028c3:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01028ca:	f0 
f01028cb:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f01028d2:	00 
f01028d3:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01028da:	e8 b5 d7 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f01028df:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028e3:	74 24                	je     f0102909 <mem_init+0x17dc>
f01028e5:	c7 44 24 0c 3d 4d 10 	movl   $0xf0104d3d,0xc(%esp)
f01028ec:	f0 
f01028ed:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01028f4:	f0 
f01028f5:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01028fc:	00 
f01028fd:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102904:	e8 8b d7 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102909:	83 c0 01             	add    $0x1,%eax
f010290c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102911:	0f 85 28 ff ff ff    	jne    f010283f <mem_init+0x1712>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102917:	c7 04 24 90 49 10 f0 	movl   $0xf0104990,(%esp)
f010291e:	e8 84 04 00 00       	call   f0102da7 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102923:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102928:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010292d:	77 20                	ja     f010294f <mem_init+0x1822>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010292f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102933:	c7 44 24 08 14 44 10 	movl   $0xf0104414,0x8(%esp)
f010293a:	f0 
f010293b:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0102942:	00 
f0102943:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f010294a:	e8 45 d7 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010294f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102954:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102957:	b8 00 00 00 00       	mov    $0x0,%eax
f010295c:	e8 b8 e0 ff ff       	call   f0100a19 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102961:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102964:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102969:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010296c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010296f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102976:	e8 af e4 ff ff       	call   f0100e2a <page_alloc>
f010297b:	89 c6                	mov    %eax,%esi
f010297d:	85 c0                	test   %eax,%eax
f010297f:	75 24                	jne    f01029a5 <mem_init+0x1878>
f0102981:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f0102988:	f0 
f0102989:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102990:	f0 
f0102991:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0102998:	00 
f0102999:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01029a0:	e8 ef d6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01029a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029ac:	e8 79 e4 ff ff       	call   f0100e2a <page_alloc>
f01029b1:	89 c7                	mov    %eax,%edi
f01029b3:	85 c0                	test   %eax,%eax
f01029b5:	75 24                	jne    f01029db <mem_init+0x18ae>
f01029b7:	c7 44 24 0c 37 4b 10 	movl   $0xf0104b37,0xc(%esp)
f01029be:	f0 
f01029bf:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01029c6:	f0 
f01029c7:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01029ce:	00 
f01029cf:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f01029d6:	e8 b9 d6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01029db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029e2:	e8 43 e4 ff ff       	call   f0100e2a <page_alloc>
f01029e7:	89 c3                	mov    %eax,%ebx
f01029e9:	85 c0                	test   %eax,%eax
f01029eb:	75 24                	jne    f0102a11 <mem_init+0x18e4>
f01029ed:	c7 44 24 0c 4d 4b 10 	movl   $0xf0104b4d,0xc(%esp)
f01029f4:	f0 
f01029f5:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102a04:	00 
f0102a05:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102a0c:	e8 83 d6 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102a11:	89 34 24             	mov    %esi,(%esp)
f0102a14:	e8 95 e4 ff ff       	call   f0100eae <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a19:	89 f8                	mov    %edi,%eax
f0102a1b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102a21:	c1 f8 03             	sar    $0x3,%eax
f0102a24:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a27:	89 c2                	mov    %eax,%edx
f0102a29:	c1 ea 0c             	shr    $0xc,%edx
f0102a2c:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102a32:	72 20                	jb     f0102a54 <mem_init+0x1927>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a34:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a38:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0102a3f:	f0 
f0102a40:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a47:	00 
f0102a48:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0102a4f:	e8 40 d6 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a54:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a5b:	00 
f0102a5c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102a63:	00 
	return (void *)(pa + KERNBASE);
f0102a64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a69:	89 04 24             	mov    %eax,(%esp)
f0102a6c:	e8 86 0e 00 00       	call   f01038f7 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a71:	89 d8                	mov    %ebx,%eax
f0102a73:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102a79:	c1 f8 03             	sar    $0x3,%eax
f0102a7c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a7f:	89 c2                	mov    %eax,%edx
f0102a81:	c1 ea 0c             	shr    $0xc,%edx
f0102a84:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102a8a:	72 20                	jb     f0102aac <mem_init+0x197f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a90:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0102aa7:	e8 e8 d5 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102aac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ab3:	00 
f0102ab4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102abb:	00 
	return (void *)(pa + KERNBASE);
f0102abc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ac1:	89 04 24             	mov    %eax,(%esp)
f0102ac4:	e8 2e 0e 00 00       	call   f01038f7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ac9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ad0:	00 
f0102ad1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ad8:	00 
f0102ad9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102add:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102ae2:	89 04 24             	mov    %eax,(%esp)
f0102ae5:	e8 96 e5 ff ff       	call   f0101080 <page_insert>
	assert(pp1->pp_ref == 1);
f0102aea:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102aef:	74 24                	je     f0102b15 <mem_init+0x19e8>
f0102af1:	c7 44 24 0c 1e 4c 10 	movl   $0xf0104c1e,0xc(%esp)
f0102af8:	f0 
f0102af9:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102b00:	f0 
f0102b01:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0102b08:	00 
f0102b09:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102b10:	e8 7f d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b15:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b1c:	01 01 01 
f0102b1f:	74 24                	je     f0102b45 <mem_init+0x1a18>
f0102b21:	c7 44 24 0c b0 49 10 	movl   $0xf01049b0,0xc(%esp)
f0102b28:	f0 
f0102b29:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102b30:	f0 
f0102b31:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102b38:	00 
f0102b39:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102b40:	e8 4f d5 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b45:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b4c:	00 
f0102b4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b54:	00 
f0102b55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b59:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102b5e:	89 04 24             	mov    %eax,(%esp)
f0102b61:	e8 1a e5 ff ff       	call   f0101080 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b66:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b6d:	02 02 02 
f0102b70:	74 24                	je     f0102b96 <mem_init+0x1a69>
f0102b72:	c7 44 24 0c d4 49 10 	movl   $0xf01049d4,0xc(%esp)
f0102b79:	f0 
f0102b7a:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102b81:	f0 
f0102b82:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102b89:	00 
f0102b8a:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102b91:	e8 fe d4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102b96:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b9b:	74 24                	je     f0102bc1 <mem_init+0x1a94>
f0102b9d:	c7 44 24 0c 40 4c 10 	movl   $0xf0104c40,0xc(%esp)
f0102ba4:	f0 
f0102ba5:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102bac:	f0 
f0102bad:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102bb4:	00 
f0102bb5:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102bbc:	e8 d3 d4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102bc1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bc6:	74 24                	je     f0102bec <mem_init+0x1abf>
f0102bc8:	c7 44 24 0c aa 4c 10 	movl   $0xf0104caa,0xc(%esp)
f0102bcf:	f0 
f0102bd0:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102bd7:	f0 
f0102bd8:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102bdf:	00 
f0102be0:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102be7:	e8 a8 d4 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bec:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bf3:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf6:	89 d8                	mov    %ebx,%eax
f0102bf8:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102bfe:	c1 f8 03             	sar    $0x3,%eax
f0102c01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c04:	89 c2                	mov    %eax,%edx
f0102c06:	c1 ea 0c             	shr    $0xc,%edx
f0102c09:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102c0f:	72 20                	jb     f0102c31 <mem_init+0x1b04>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c11:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c15:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0102c1c:	f0 
f0102c1d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102c24:	00 
f0102c25:	c7 04 24 5c 4a 10 f0 	movl   $0xf0104a5c,(%esp)
f0102c2c:	e8 63 d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c31:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c38:	03 03 03 
f0102c3b:	74 24                	je     f0102c61 <mem_init+0x1b34>
f0102c3d:	c7 44 24 0c f8 49 10 	movl   $0xf01049f8,0xc(%esp)
f0102c44:	f0 
f0102c45:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102c4c:	f0 
f0102c4d:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102c54:	00 
f0102c55:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102c5c:	e8 33 d4 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c61:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c68:	00 
f0102c69:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102c6e:	89 04 24             	mov    %eax,(%esp)
f0102c71:	e8 b3 e3 ff ff       	call   f0101029 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c76:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c7b:	74 24                	je     f0102ca1 <mem_init+0x1b74>
f0102c7d:	c7 44 24 0c 78 4c 10 	movl   $0xf0104c78,0xc(%esp)
f0102c84:	f0 
f0102c85:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102c8c:	f0 
f0102c8d:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102c94:	00 
f0102c95:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
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
f0102cae:	89 f2                	mov    %esi,%edx
f0102cb0:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102cb6:	c1 fa 03             	sar    $0x3,%edx
f0102cb9:	c1 e2 0c             	shl    $0xc,%edx
f0102cbc:	39 d1                	cmp    %edx,%ecx
f0102cbe:	74 24                	je     f0102ce4 <mem_init+0x1bb7>
f0102cc0:	c7 44 24 0c 10 45 10 	movl   $0xf0104510,0xc(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102cd7:	00 
f0102cd8:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102cdf:	e8 b0 d3 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102ce4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cea:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cef:	74 24                	je     f0102d15 <mem_init+0x1be8>
f0102cf1:	c7 44 24 0c 2f 4c 10 	movl   $0xf0104c2f,0xc(%esp)
f0102cf8:	f0 
f0102cf9:	c7 44 24 08 76 4a 10 	movl   $0xf0104a76,0x8(%esp)
f0102d00:	f0 
f0102d01:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102d08:	00 
f0102d09:	c7 04 24 50 4a 10 f0 	movl   $0xf0104a50,(%esp)
f0102d10:	e8 7f d3 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102d15:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d1b:	89 34 24             	mov    %esi,(%esp)
f0102d1e:	e8 8b e1 ff ff       	call   f0100eae <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d23:	c7 04 24 24 4a 10 f0 	movl   $0xf0104a24,(%esp)
f0102d2a:	e8 78 00 00 00       	call   f0102da7 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d2f:	83 c4 3c             	add    $0x3c,%esp
f0102d32:	5b                   	pop    %ebx
f0102d33:	5e                   	pop    %esi
f0102d34:	5f                   	pop    %edi
f0102d35:	5d                   	pop    %ebp
f0102d36:	c3                   	ret    

f0102d37 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102d37:	55                   	push   %ebp
f0102d38:	89 e5                	mov    %esp,%ebp
f0102d3a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d3e:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d43:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d44:	b2 71                	mov    $0x71,%dl
f0102d46:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d47:	0f b6 c0             	movzbl %al,%eax
}
f0102d4a:	5d                   	pop    %ebp
f0102d4b:	c3                   	ret    

f0102d4c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d4c:	55                   	push   %ebp
f0102d4d:	89 e5                	mov    %esp,%ebp
f0102d4f:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d53:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d58:	ee                   	out    %al,(%dx)
f0102d59:	b2 71                	mov    $0x71,%dl
f0102d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d5e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d5f:	5d                   	pop    %ebp
f0102d60:	c3                   	ret    

f0102d61 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d61:	55                   	push   %ebp
f0102d62:	89 e5                	mov    %esp,%ebp
f0102d64:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102d67:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d6a:	89 04 24             	mov    %eax,(%esp)
f0102d6d:	e8 7f d8 ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0102d72:	c9                   	leave  
f0102d73:	c3                   	ret    

f0102d74 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d74:	55                   	push   %ebp
f0102d75:	89 e5                	mov    %esp,%ebp
f0102d77:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102d7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d88:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d96:	c7 04 24 61 2d 10 f0 	movl   $0xf0102d61,(%esp)
f0102d9d:	e8 12 04 00 00       	call   f01031b4 <vprintfmt>
	return cnt;
}
f0102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102da5:	c9                   	leave  
f0102da6:	c3                   	ret    

f0102da7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102da7:	55                   	push   %ebp
f0102da8:	89 e5                	mov    %esp,%ebp
f0102daa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102dad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102db0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102db4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102db7:	89 04 24             	mov    %eax,(%esp)
f0102dba:	e8 b5 ff ff ff       	call   f0102d74 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102dbf:	c9                   	leave  
f0102dc0:	c3                   	ret    

f0102dc1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102dc1:	55                   	push   %ebp
f0102dc2:	89 e5                	mov    %esp,%ebp
f0102dc4:	57                   	push   %edi
f0102dc5:	56                   	push   %esi
f0102dc6:	53                   	push   %ebx
f0102dc7:	83 ec 10             	sub    $0x10,%esp
f0102dca:	89 c6                	mov    %eax,%esi
f0102dcc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102dcf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102dd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102dd5:	8b 1a                	mov    (%edx),%ebx
f0102dd7:	8b 01                	mov    (%ecx),%eax
f0102dd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102ddc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102de3:	eb 77                	jmp    f0102e5c <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0102de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102de8:	01 d8                	add    %ebx,%eax
f0102dea:	b9 02 00 00 00       	mov    $0x2,%ecx
f0102def:	99                   	cltd   
f0102df0:	f7 f9                	idiv   %ecx
f0102df2:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102df4:	eb 01                	jmp    f0102df7 <stab_binsearch+0x36>
			m--;
f0102df6:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102df7:	39 d9                	cmp    %ebx,%ecx
f0102df9:	7c 1d                	jl     f0102e18 <stab_binsearch+0x57>
f0102dfb:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102dfe:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102e03:	39 fa                	cmp    %edi,%edx
f0102e05:	75 ef                	jne    f0102df6 <stab_binsearch+0x35>
f0102e07:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102e0a:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102e0d:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0102e11:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e14:	73 18                	jae    f0102e2e <stab_binsearch+0x6d>
f0102e16:	eb 05                	jmp    f0102e1d <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102e18:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0102e1b:	eb 3f                	jmp    f0102e5c <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102e1d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e20:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0102e22:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e25:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e2c:	eb 2e                	jmp    f0102e5c <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102e2e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102e31:	73 15                	jae    f0102e48 <stab_binsearch+0x87>
			*region_right = m - 1;
f0102e33:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102e36:	48                   	dec    %eax
f0102e37:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102e3a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e3d:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e3f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e46:	eb 14                	jmp    f0102e5c <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e48:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e4b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102e4e:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0102e50:	ff 45 0c             	incl   0xc(%ebp)
f0102e53:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e55:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102e5c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102e5f:	7e 84                	jle    f0102de5 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102e61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102e65:	75 0d                	jne    f0102e74 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0102e67:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e6a:	8b 00                	mov    (%eax),%eax
f0102e6c:	48                   	dec    %eax
f0102e6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e70:	89 07                	mov    %eax,(%edi)
f0102e72:	eb 22                	jmp    f0102e96 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e77:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e79:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102e7c:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e7e:	eb 01                	jmp    f0102e81 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e80:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e81:	39 c1                	cmp    %eax,%ecx
f0102e83:	7d 0c                	jge    f0102e91 <stab_binsearch+0xd0>
f0102e85:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0102e88:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102e8d:	39 fa                	cmp    %edi,%edx
f0102e8f:	75 ef                	jne    f0102e80 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e91:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0102e94:	89 07                	mov    %eax,(%edi)
	}
}
f0102e96:	83 c4 10             	add    $0x10,%esp
f0102e99:	5b                   	pop    %ebx
f0102e9a:	5e                   	pop    %esi
f0102e9b:	5f                   	pop    %edi
f0102e9c:	5d                   	pop    %ebp
f0102e9d:	c3                   	ret    

f0102e9e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e9e:	55                   	push   %ebp
f0102e9f:	89 e5                	mov    %esp,%ebp
f0102ea1:	57                   	push   %edi
f0102ea2:	56                   	push   %esi
f0102ea3:	53                   	push   %ebx
f0102ea4:	83 ec 2c             	sub    $0x2c,%esp
f0102ea7:	8b 75 08             	mov    0x8(%ebp),%esi
f0102eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102ead:	c7 03 4b 4d 10 f0    	movl   $0xf0104d4b,(%ebx)
	info->eip_line = 0;
f0102eb3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102eba:	c7 43 08 4b 4d 10 f0 	movl   $0xf0104d4b,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102ec1:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102ec8:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102ecb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102ed2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ed8:	76 12                	jbe    f0102eec <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102eda:	b8 bc ca 10 f0       	mov    $0xf010cabc,%eax
f0102edf:	3d 15 ad 10 f0       	cmp    $0xf010ad15,%eax
f0102ee4:	0f 86 6b 01 00 00    	jbe    f0103055 <debuginfo_eip+0x1b7>
f0102eea:	eb 1c                	jmp    f0102f08 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102eec:	c7 44 24 08 55 4d 10 	movl   $0xf0104d55,0x8(%esp)
f0102ef3:	f0 
f0102ef4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102efb:	00 
f0102efc:	c7 04 24 62 4d 10 f0 	movl   $0xf0104d62,(%esp)
f0102f03:	e8 8c d1 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102f08:	80 3d bb ca 10 f0 00 	cmpb   $0x0,0xf010cabb
f0102f0f:	0f 85 47 01 00 00    	jne    f010305c <debuginfo_eip+0x1be>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102f15:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102f1c:	b8 14 ad 10 f0       	mov    $0xf010ad14,%eax
f0102f21:	2d 90 4f 10 f0       	sub    $0xf0104f90,%eax
f0102f26:	c1 f8 02             	sar    $0x2,%eax
f0102f29:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102f2f:	83 e8 01             	sub    $0x1,%eax
f0102f32:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102f35:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f39:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102f40:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f43:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f46:	b8 90 4f 10 f0       	mov    $0xf0104f90,%eax
f0102f4b:	e8 71 fe ff ff       	call   f0102dc1 <stab_binsearch>
	if (lfile == 0)
f0102f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f53:	85 c0                	test   %eax,%eax
f0102f55:	0f 84 08 01 00 00    	je     f0103063 <debuginfo_eip+0x1c5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f5b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102f5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f61:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f64:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f68:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102f6f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f72:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f75:	b8 90 4f 10 f0       	mov    $0xf0104f90,%eax
f0102f7a:	e8 42 fe ff ff       	call   f0102dc1 <stab_binsearch>

	if (lfun <= rfun) {
f0102f7f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102f82:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0102f85:	7f 2e                	jg     f0102fb5 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f87:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102f8a:	8d 90 90 4f 10 f0    	lea    -0xfefb070(%eax),%edx
f0102f90:	8b 80 90 4f 10 f0    	mov    -0xfefb070(%eax),%eax
f0102f96:	b9 bc ca 10 f0       	mov    $0xf010cabc,%ecx
f0102f9b:	81 e9 15 ad 10 f0    	sub    $0xf010ad15,%ecx
f0102fa1:	39 c8                	cmp    %ecx,%eax
f0102fa3:	73 08                	jae    f0102fad <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102fa5:	05 15 ad 10 f0       	add    $0xf010ad15,%eax
f0102faa:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102fad:	8b 42 08             	mov    0x8(%edx),%eax
f0102fb0:	89 43 10             	mov    %eax,0x10(%ebx)
f0102fb3:	eb 06                	jmp    f0102fbb <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102fb5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102fb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102fbb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102fc2:	00 
f0102fc3:	8b 43 08             	mov    0x8(%ebx),%eax
f0102fc6:	89 04 24             	mov    %eax,(%esp)
f0102fc9:	e8 0d 09 00 00       	call   f01038db <strfind>
f0102fce:	2b 43 08             	sub    0x8(%ebx),%eax
f0102fd1:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fd4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102fd7:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102fda:	05 90 4f 10 f0       	add    $0xf0104f90,%eax
f0102fdf:	eb 06                	jmp    f0102fe7 <debuginfo_eip+0x149>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102fe1:	83 ef 01             	sub    $0x1,%edi
f0102fe4:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fe7:	39 cf                	cmp    %ecx,%edi
f0102fe9:	7c 33                	jl     f010301e <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
f0102feb:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0102fef:	80 fa 84             	cmp    $0x84,%dl
f0102ff2:	74 0b                	je     f0102fff <debuginfo_eip+0x161>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102ff4:	80 fa 64             	cmp    $0x64,%dl
f0102ff7:	75 e8                	jne    f0102fe1 <debuginfo_eip+0x143>
f0102ff9:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102ffd:	74 e2                	je     f0102fe1 <debuginfo_eip+0x143>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102fff:	6b ff 0c             	imul   $0xc,%edi,%edi
f0103002:	8b 87 90 4f 10 f0    	mov    -0xfefb070(%edi),%eax
f0103008:	ba bc ca 10 f0       	mov    $0xf010cabc,%edx
f010300d:	81 ea 15 ad 10 f0    	sub    $0xf010ad15,%edx
f0103013:	39 d0                	cmp    %edx,%eax
f0103015:	73 07                	jae    f010301e <debuginfo_eip+0x180>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103017:	05 15 ad 10 f0       	add    $0xf010ad15,%eax
f010301c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010301e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103021:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103024:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103029:	39 f1                	cmp    %esi,%ecx
f010302b:	7d 42                	jge    f010306f <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
f010302d:	8d 51 01             	lea    0x1(%ecx),%edx
f0103030:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103033:	05 90 4f 10 f0       	add    $0xf0104f90,%eax
f0103038:	eb 07                	jmp    f0103041 <debuginfo_eip+0x1a3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010303a:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010303e:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103041:	39 f2                	cmp    %esi,%edx
f0103043:	74 25                	je     f010306a <debuginfo_eip+0x1cc>
f0103045:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103048:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f010304c:	74 ec                	je     f010303a <debuginfo_eip+0x19c>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010304e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103053:	eb 1a                	jmp    f010306f <debuginfo_eip+0x1d1>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010305a:	eb 13                	jmp    f010306f <debuginfo_eip+0x1d1>
f010305c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103061:	eb 0c                	jmp    f010306f <debuginfo_eip+0x1d1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103063:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103068:	eb 05                	jmp    f010306f <debuginfo_eip+0x1d1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010306a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010306f:	83 c4 2c             	add    $0x2c,%esp
f0103072:	5b                   	pop    %ebx
f0103073:	5e                   	pop    %esi
f0103074:	5f                   	pop    %edi
f0103075:	5d                   	pop    %ebp
f0103076:	c3                   	ret    
	...

f0103080 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103080:	55                   	push   %ebp
f0103081:	89 e5                	mov    %esp,%ebp
f0103083:	57                   	push   %edi
f0103084:	56                   	push   %esi
f0103085:	53                   	push   %ebx
f0103086:	83 ec 3c             	sub    $0x3c,%esp
f0103089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010308c:	89 d7                	mov    %edx,%edi
f010308e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103091:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103094:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103097:	89 c3                	mov    %eax,%ebx
f0103099:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010309c:	8b 45 10             	mov    0x10(%ebp),%eax
f010309f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01030a2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01030aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01030ad:	39 d9                	cmp    %ebx,%ecx
f01030af:	72 05                	jb     f01030b6 <printnum+0x36>
f01030b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01030b4:	77 69                	ja     f010311f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01030b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01030bd:	83 ee 01             	sub    $0x1,%esi
f01030c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01030c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030c8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01030cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01030d0:	89 c3                	mov    %eax,%ebx
f01030d2:	89 d6                	mov    %edx,%esi
f01030d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01030d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01030da:	89 54 24 08          	mov    %edx,0x8(%esp)
f01030de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01030e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030e5:	89 04 24             	mov    %eax,(%esp)
f01030e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01030eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030ef:	e8 0c 0a 00 00       	call   f0103b00 <__udivdi3>
f01030f4:	89 d9                	mov    %ebx,%ecx
f01030f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01030fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01030fe:	89 04 24             	mov    %eax,(%esp)
f0103101:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103105:	89 fa                	mov    %edi,%edx
f0103107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010310a:	e8 71 ff ff ff       	call   f0103080 <printnum>
f010310f:	eb 1b                	jmp    f010312c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103111:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103115:	8b 45 18             	mov    0x18(%ebp),%eax
f0103118:	89 04 24             	mov    %eax,(%esp)
f010311b:	ff d3                	call   *%ebx
f010311d:	eb 03                	jmp    f0103122 <printnum+0xa2>
f010311f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103122:	83 ee 01             	sub    $0x1,%esi
f0103125:	85 f6                	test   %esi,%esi
f0103127:	7f e8                	jg     f0103111 <printnum+0x91>
f0103129:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010312c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103130:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103134:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103137:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010313a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010313e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103142:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103145:	89 04 24             	mov    %eax,(%esp)
f0103148:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010314b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010314f:	e8 dc 0a 00 00       	call   f0103c30 <__umoddi3>
f0103154:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103158:	0f be 80 70 4d 10 f0 	movsbl -0xfefb290(%eax),%eax
f010315f:	89 04 24             	mov    %eax,(%esp)
f0103162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103165:	ff d0                	call   *%eax
}
f0103167:	83 c4 3c             	add    $0x3c,%esp
f010316a:	5b                   	pop    %ebx
f010316b:	5e                   	pop    %esi
f010316c:	5f                   	pop    %edi
f010316d:	5d                   	pop    %ebp
f010316e:	c3                   	ret    

f010316f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010316f:	55                   	push   %ebp
f0103170:	89 e5                	mov    %esp,%ebp
f0103172:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103175:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103179:	8b 10                	mov    (%eax),%edx
f010317b:	3b 50 04             	cmp    0x4(%eax),%edx
f010317e:	73 0a                	jae    f010318a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103180:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103183:	89 08                	mov    %ecx,(%eax)
f0103185:	8b 45 08             	mov    0x8(%ebp),%eax
f0103188:	88 02                	mov    %al,(%edx)
}
f010318a:	5d                   	pop    %ebp
f010318b:	c3                   	ret    

f010318c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010318c:	55                   	push   %ebp
f010318d:	89 e5                	mov    %esp,%ebp
f010318f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103192:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103195:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103199:	8b 45 10             	mov    0x10(%ebp),%eax
f010319c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031aa:	89 04 24             	mov    %eax,(%esp)
f01031ad:	e8 02 00 00 00       	call   f01031b4 <vprintfmt>
	va_end(ap);
}
f01031b2:	c9                   	leave  
f01031b3:	c3                   	ret    

f01031b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031b4:	55                   	push   %ebp
f01031b5:	89 e5                	mov    %esp,%ebp
f01031b7:	57                   	push   %edi
f01031b8:	56                   	push   %esi
f01031b9:	53                   	push   %ebx
f01031ba:	83 ec 3c             	sub    $0x3c,%esp
f01031bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01031c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031c3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01031c6:	eb 11                	jmp    f01031d9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01031c8:	85 c0                	test   %eax,%eax
f01031ca:	0f 84 48 04 00 00    	je     f0103618 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01031d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031d4:	89 04 24             	mov    %eax,(%esp)
f01031d7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01031d9:	83 c7 01             	add    $0x1,%edi
f01031dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01031e0:	83 f8 25             	cmp    $0x25,%eax
f01031e3:	75 e3                	jne    f01031c8 <vprintfmt+0x14>
f01031e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01031e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01031f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01031f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01031fe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103203:	eb 1f                	jmp    f0103224 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103205:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103208:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010320c:	eb 16                	jmp    f0103224 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010320e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103211:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103215:	eb 0d                	jmp    f0103224 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103217:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010321a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010321d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103224:	8d 47 01             	lea    0x1(%edi),%eax
f0103227:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010322a:	0f b6 17             	movzbl (%edi),%edx
f010322d:	0f b6 c2             	movzbl %dl,%eax
f0103230:	83 ea 23             	sub    $0x23,%edx
f0103233:	80 fa 55             	cmp    $0x55,%dl
f0103236:	0f 87 bf 03 00 00    	ja     f01035fb <vprintfmt+0x447>
f010323c:	0f b6 d2             	movzbl %dl,%edx
f010323f:	ff 24 95 00 4e 10 f0 	jmp    *-0xfefb200(,%edx,4)
f0103246:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103249:	ba 00 00 00 00       	mov    $0x0,%edx
f010324e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103251:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103254:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103258:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010325b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010325e:	83 f9 09             	cmp    $0x9,%ecx
f0103261:	77 3c                	ja     f010329f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103263:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103266:	eb e9                	jmp    f0103251 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103268:	8b 45 14             	mov    0x14(%ebp),%eax
f010326b:	8b 00                	mov    (%eax),%eax
f010326d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103270:	8b 45 14             	mov    0x14(%ebp),%eax
f0103273:	8d 40 04             	lea    0x4(%eax),%eax
f0103276:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103279:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010327c:	eb 27                	jmp    f01032a5 <vprintfmt+0xf1>
f010327e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103281:	85 d2                	test   %edx,%edx
f0103283:	b8 00 00 00 00       	mov    $0x0,%eax
f0103288:	0f 49 c2             	cmovns %edx,%eax
f010328b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010328e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103291:	eb 91                	jmp    f0103224 <vprintfmt+0x70>
f0103293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103296:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010329d:	eb 85                	jmp    f0103224 <vprintfmt+0x70>
f010329f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01032a2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01032a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01032a9:	0f 89 75 ff ff ff    	jns    f0103224 <vprintfmt+0x70>
f01032af:	e9 63 ff ff ff       	jmp    f0103217 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01032b4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01032ba:	e9 65 ff ff ff       	jmp    f0103224 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032bf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032c2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01032c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032ca:	8b 00                	mov    (%eax),%eax
f01032cc:	89 04 24             	mov    %eax,(%esp)
f01032cf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01032d4:	e9 00 ff ff ff       	jmp    f01031d9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032d9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01032dc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01032e0:	8b 00                	mov    (%eax),%eax
f01032e2:	99                   	cltd   
f01032e3:	31 d0                	xor    %edx,%eax
f01032e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01032e7:	83 f8 07             	cmp    $0x7,%eax
f01032ea:	7f 0b                	jg     f01032f7 <vprintfmt+0x143>
f01032ec:	8b 14 85 60 4f 10 f0 	mov    -0xfefb0a0(,%eax,4),%edx
f01032f3:	85 d2                	test   %edx,%edx
f01032f5:	75 20                	jne    f0103317 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f01032f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032fb:	c7 44 24 08 88 4d 10 	movl   $0xf0104d88,0x8(%esp)
f0103302:	f0 
f0103303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103307:	89 34 24             	mov    %esi,(%esp)
f010330a:	e8 7d fe ff ff       	call   f010318c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010330f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103312:	e9 c2 fe ff ff       	jmp    f01031d9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103317:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010331b:	c7 44 24 08 88 4a 10 	movl   $0xf0104a88,0x8(%esp)
f0103322:	f0 
f0103323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103327:	89 34 24             	mov    %esi,(%esp)
f010332a:	e8 5d fe ff ff       	call   f010318c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010332f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103332:	e9 a2 fe ff ff       	jmp    f01031d9 <vprintfmt+0x25>
f0103337:	8b 45 14             	mov    0x14(%ebp),%eax
f010333a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010333d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103340:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103343:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103347:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103349:	85 ff                	test   %edi,%edi
f010334b:	b8 81 4d 10 f0       	mov    $0xf0104d81,%eax
f0103350:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103353:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103357:	0f 84 92 00 00 00    	je     f01033ef <vprintfmt+0x23b>
f010335d:	85 c9                	test   %ecx,%ecx
f010335f:	0f 8e 98 00 00 00    	jle    f01033fd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103365:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103369:	89 3c 24             	mov    %edi,(%esp)
f010336c:	e8 17 04 00 00       	call   f0103788 <strnlen>
f0103371:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103374:	29 c1                	sub    %eax,%ecx
f0103376:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0103379:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010337d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103380:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103383:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103385:	eb 0f                	jmp    f0103396 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0103387:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010338b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010338e:	89 04 24             	mov    %eax,(%esp)
f0103391:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103393:	83 ef 01             	sub    $0x1,%edi
f0103396:	85 ff                	test   %edi,%edi
f0103398:	7f ed                	jg     f0103387 <vprintfmt+0x1d3>
f010339a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010339d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01033a0:	85 c9                	test   %ecx,%ecx
f01033a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01033a7:	0f 49 c1             	cmovns %ecx,%eax
f01033aa:	29 c1                	sub    %eax,%ecx
f01033ac:	89 75 08             	mov    %esi,0x8(%ebp)
f01033af:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01033b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01033b5:	89 cb                	mov    %ecx,%ebx
f01033b7:	eb 50                	jmp    f0103409 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01033b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01033bd:	74 1e                	je     f01033dd <vprintfmt+0x229>
f01033bf:	0f be d2             	movsbl %dl,%edx
f01033c2:	83 ea 20             	sub    $0x20,%edx
f01033c5:	83 fa 5e             	cmp    $0x5e,%edx
f01033c8:	76 13                	jbe    f01033dd <vprintfmt+0x229>
					putch('?', putdat);
f01033ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01033d8:	ff 55 08             	call   *0x8(%ebp)
f01033db:	eb 0d                	jmp    f01033ea <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01033dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01033e4:	89 04 24             	mov    %eax,(%esp)
f01033e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033ea:	83 eb 01             	sub    $0x1,%ebx
f01033ed:	eb 1a                	jmp    f0103409 <vprintfmt+0x255>
f01033ef:	89 75 08             	mov    %esi,0x8(%ebp)
f01033f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01033f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01033f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01033fb:	eb 0c                	jmp    f0103409 <vprintfmt+0x255>
f01033fd:	89 75 08             	mov    %esi,0x8(%ebp)
f0103400:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103403:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103406:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103409:	83 c7 01             	add    $0x1,%edi
f010340c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103410:	0f be c2             	movsbl %dl,%eax
f0103413:	85 c0                	test   %eax,%eax
f0103415:	74 25                	je     f010343c <vprintfmt+0x288>
f0103417:	85 f6                	test   %esi,%esi
f0103419:	78 9e                	js     f01033b9 <vprintfmt+0x205>
f010341b:	83 ee 01             	sub    $0x1,%esi
f010341e:	79 99                	jns    f01033b9 <vprintfmt+0x205>
f0103420:	89 df                	mov    %ebx,%edi
f0103422:	8b 75 08             	mov    0x8(%ebp),%esi
f0103425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103428:	eb 1a                	jmp    f0103444 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010342a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010342e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103435:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103437:	83 ef 01             	sub    $0x1,%edi
f010343a:	eb 08                	jmp    f0103444 <vprintfmt+0x290>
f010343c:	89 df                	mov    %ebx,%edi
f010343e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103444:	85 ff                	test   %edi,%edi
f0103446:	7f e2                	jg     f010342a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010344b:	e9 89 fd ff ff       	jmp    f01031d9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103450:	83 f9 01             	cmp    $0x1,%ecx
f0103453:	7e 19                	jle    f010346e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0103455:	8b 45 14             	mov    0x14(%ebp),%eax
f0103458:	8b 50 04             	mov    0x4(%eax),%edx
f010345b:	8b 00                	mov    (%eax),%eax
f010345d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103460:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103463:	8b 45 14             	mov    0x14(%ebp),%eax
f0103466:	8d 40 08             	lea    0x8(%eax),%eax
f0103469:	89 45 14             	mov    %eax,0x14(%ebp)
f010346c:	eb 38                	jmp    f01034a6 <vprintfmt+0x2f2>
	else if (lflag)
f010346e:	85 c9                	test   %ecx,%ecx
f0103470:	74 1b                	je     f010348d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0103472:	8b 45 14             	mov    0x14(%ebp),%eax
f0103475:	8b 00                	mov    (%eax),%eax
f0103477:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010347a:	89 c1                	mov    %eax,%ecx
f010347c:	c1 f9 1f             	sar    $0x1f,%ecx
f010347f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103482:	8b 45 14             	mov    0x14(%ebp),%eax
f0103485:	8d 40 04             	lea    0x4(%eax),%eax
f0103488:	89 45 14             	mov    %eax,0x14(%ebp)
f010348b:	eb 19                	jmp    f01034a6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f010348d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103490:	8b 00                	mov    (%eax),%eax
f0103492:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103495:	89 c1                	mov    %eax,%ecx
f0103497:	c1 f9 1f             	sar    $0x1f,%ecx
f010349a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010349d:	8b 45 14             	mov    0x14(%ebp),%eax
f01034a0:	8d 40 04             	lea    0x4(%eax),%eax
f01034a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01034a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01034ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01034b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01034b5:	0f 89 04 01 00 00    	jns    f01035bf <vprintfmt+0x40b>
				putch('-', putdat);
f01034bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01034c6:	ff d6                	call   *%esi
				num = -(long long) num;
f01034c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01034ce:	f7 da                	neg    %edx
f01034d0:	83 d1 00             	adc    $0x0,%ecx
f01034d3:	f7 d9                	neg    %ecx
f01034d5:	e9 e5 00 00 00       	jmp    f01035bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01034da:	83 f9 01             	cmp    $0x1,%ecx
f01034dd:	7e 10                	jle    f01034ef <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01034df:	8b 45 14             	mov    0x14(%ebp),%eax
f01034e2:	8b 10                	mov    (%eax),%edx
f01034e4:	8b 48 04             	mov    0x4(%eax),%ecx
f01034e7:	8d 40 08             	lea    0x8(%eax),%eax
f01034ea:	89 45 14             	mov    %eax,0x14(%ebp)
f01034ed:	eb 26                	jmp    f0103515 <vprintfmt+0x361>
	else if (lflag)
f01034ef:	85 c9                	test   %ecx,%ecx
f01034f1:	74 12                	je     f0103505 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f01034f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f6:	8b 10                	mov    (%eax),%edx
f01034f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034fd:	8d 40 04             	lea    0x4(%eax),%eax
f0103500:	89 45 14             	mov    %eax,0x14(%ebp)
f0103503:	eb 10                	jmp    f0103515 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0103505:	8b 45 14             	mov    0x14(%ebp),%eax
f0103508:	8b 10                	mov    (%eax),%edx
f010350a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010350f:	8d 40 04             	lea    0x4(%eax),%eax
f0103512:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103515:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010351a:	e9 a0 00 00 00       	jmp    f01035bf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010351f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103523:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010352a:	ff d6                	call   *%esi
			putch('X', putdat);
f010352c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103530:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103537:	ff d6                	call   *%esi
			putch('X', putdat);
f0103539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010353d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103544:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103549:	e9 8b fc ff ff       	jmp    f01031d9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010354e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103552:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103559:	ff d6                	call   *%esi
			putch('x', putdat);
f010355b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010355f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103566:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103568:	8b 45 14             	mov    0x14(%ebp),%eax
f010356b:	8b 10                	mov    (%eax),%edx
f010356d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0103572:	8d 40 04             	lea    0x4(%eax),%eax
f0103575:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103578:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010357d:	eb 40                	jmp    f01035bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010357f:	83 f9 01             	cmp    $0x1,%ecx
f0103582:	7e 10                	jle    f0103594 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0103584:	8b 45 14             	mov    0x14(%ebp),%eax
f0103587:	8b 10                	mov    (%eax),%edx
f0103589:	8b 48 04             	mov    0x4(%eax),%ecx
f010358c:	8d 40 08             	lea    0x8(%eax),%eax
f010358f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103592:	eb 26                	jmp    f01035ba <vprintfmt+0x406>
	else if (lflag)
f0103594:	85 c9                	test   %ecx,%ecx
f0103596:	74 12                	je     f01035aa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0103598:	8b 45 14             	mov    0x14(%ebp),%eax
f010359b:	8b 10                	mov    (%eax),%edx
f010359d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035a2:	8d 40 04             	lea    0x4(%eax),%eax
f01035a5:	89 45 14             	mov    %eax,0x14(%ebp)
f01035a8:	eb 10                	jmp    f01035ba <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01035aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01035ad:	8b 10                	mov    (%eax),%edx
f01035af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035b4:	8d 40 04             	lea    0x4(%eax),%eax
f01035b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01035ba:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01035bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01035c3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01035c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01035d2:	89 14 24             	mov    %edx,(%esp)
f01035d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01035d9:	89 da                	mov    %ebx,%edx
f01035db:	89 f0                	mov    %esi,%eax
f01035dd:	e8 9e fa ff ff       	call   f0103080 <printnum>
			break;
f01035e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035e5:	e9 ef fb ff ff       	jmp    f01031d9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01035ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035ee:	89 04 24             	mov    %eax,(%esp)
f01035f1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01035f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01035f6:	e9 de fb ff ff       	jmp    f01031d9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01035fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103606:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103608:	eb 03                	jmp    f010360d <vprintfmt+0x459>
f010360a:	83 ef 01             	sub    $0x1,%edi
f010360d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103611:	75 f7                	jne    f010360a <vprintfmt+0x456>
f0103613:	e9 c1 fb ff ff       	jmp    f01031d9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103618:	83 c4 3c             	add    $0x3c,%esp
f010361b:	5b                   	pop    %ebx
f010361c:	5e                   	pop    %esi
f010361d:	5f                   	pop    %edi
f010361e:	5d                   	pop    %ebp
f010361f:	c3                   	ret    

f0103620 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103620:	55                   	push   %ebp
f0103621:	89 e5                	mov    %esp,%ebp
f0103623:	83 ec 28             	sub    $0x28,%esp
f0103626:	8b 45 08             	mov    0x8(%ebp),%eax
f0103629:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010362c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010362f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103633:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010363d:	85 c0                	test   %eax,%eax
f010363f:	74 30                	je     f0103671 <vsnprintf+0x51>
f0103641:	85 d2                	test   %edx,%edx
f0103643:	7e 2c                	jle    f0103671 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103645:	8b 45 14             	mov    0x14(%ebp),%eax
f0103648:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010364c:	8b 45 10             	mov    0x10(%ebp),%eax
f010364f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103653:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103656:	89 44 24 04          	mov    %eax,0x4(%esp)
f010365a:	c7 04 24 6f 31 10 f0 	movl   $0xf010316f,(%esp)
f0103661:	e8 4e fb ff ff       	call   f01031b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103666:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103669:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010366c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010366f:	eb 05                	jmp    f0103676 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103676:	c9                   	leave  
f0103677:	c3                   	ret    

f0103678 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103678:	55                   	push   %ebp
f0103679:	89 e5                	mov    %esp,%ebp
f010367b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010367e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103681:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103685:	8b 45 10             	mov    0x10(%ebp),%eax
f0103688:	89 44 24 08          	mov    %eax,0x8(%esp)
f010368c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103693:	8b 45 08             	mov    0x8(%ebp),%eax
f0103696:	89 04 24             	mov    %eax,(%esp)
f0103699:	e8 82 ff ff ff       	call   f0103620 <vsnprintf>
	va_end(ap);

	return rc;
}
f010369e:	c9                   	leave  
f010369f:	c3                   	ret    

f01036a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01036a0:	55                   	push   %ebp
f01036a1:	89 e5                	mov    %esp,%ebp
f01036a3:	57                   	push   %edi
f01036a4:	56                   	push   %esi
f01036a5:	53                   	push   %ebx
f01036a6:	83 ec 1c             	sub    $0x1c,%esp
f01036a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01036ac:	85 c0                	test   %eax,%eax
f01036ae:	74 10                	je     f01036c0 <readline+0x20>
		cprintf("%s", prompt);
f01036b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036b4:	c7 04 24 88 4a 10 f0 	movl   $0xf0104a88,(%esp)
f01036bb:	e8 e7 f6 ff ff       	call   f0102da7 <cprintf>

	i = 0;
	echoing = iscons(0);
f01036c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036c7:	e8 46 cf ff ff       	call   f0100612 <iscons>
f01036cc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01036ce:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01036d3:	e8 29 cf ff ff       	call   f0100601 <getchar>
f01036d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01036da:	85 c0                	test   %eax,%eax
f01036dc:	79 17                	jns    f01036f5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01036de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e2:	c7 04 24 80 4f 10 f0 	movl   $0xf0104f80,(%esp)
f01036e9:	e8 b9 f6 ff ff       	call   f0102da7 <cprintf>
			return NULL;
f01036ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f3:	eb 6d                	jmp    f0103762 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01036f5:	83 f8 7f             	cmp    $0x7f,%eax
f01036f8:	74 05                	je     f01036ff <readline+0x5f>
f01036fa:	83 f8 08             	cmp    $0x8,%eax
f01036fd:	75 19                	jne    f0103718 <readline+0x78>
f01036ff:	85 f6                	test   %esi,%esi
f0103701:	7e 15                	jle    f0103718 <readline+0x78>
			if (echoing)
f0103703:	85 ff                	test   %edi,%edi
f0103705:	74 0c                	je     f0103713 <readline+0x73>
				cputchar('\b');
f0103707:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010370e:	e8 de ce ff ff       	call   f01005f1 <cputchar>
			i--;
f0103713:	83 ee 01             	sub    $0x1,%esi
f0103716:	eb bb                	jmp    f01036d3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103718:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010371e:	7f 1c                	jg     f010373c <readline+0x9c>
f0103720:	83 fb 1f             	cmp    $0x1f,%ebx
f0103723:	7e 17                	jle    f010373c <readline+0x9c>
			if (echoing)
f0103725:	85 ff                	test   %edi,%edi
f0103727:	74 08                	je     f0103731 <readline+0x91>
				cputchar(c);
f0103729:	89 1c 24             	mov    %ebx,(%esp)
f010372c:	e8 c0 ce ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0103731:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103737:	8d 76 01             	lea    0x1(%esi),%esi
f010373a:	eb 97                	jmp    f01036d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010373c:	83 fb 0d             	cmp    $0xd,%ebx
f010373f:	74 05                	je     f0103746 <readline+0xa6>
f0103741:	83 fb 0a             	cmp    $0xa,%ebx
f0103744:	75 8d                	jne    f01036d3 <readline+0x33>
			if (echoing)
f0103746:	85 ff                	test   %edi,%edi
f0103748:	74 0c                	je     f0103756 <readline+0xb6>
				cputchar('\n');
f010374a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103751:	e8 9b ce ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0103756:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010375d:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103762:	83 c4 1c             	add    $0x1c,%esp
f0103765:	5b                   	pop    %ebx
f0103766:	5e                   	pop    %esi
f0103767:	5f                   	pop    %edi
f0103768:	5d                   	pop    %ebp
f0103769:	c3                   	ret    
f010376a:	00 00                	add    %al,(%eax)
f010376c:	00 00                	add    %al,(%eax)
	...

f0103770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103770:	55                   	push   %ebp
f0103771:	89 e5                	mov    %esp,%ebp
f0103773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103776:	b8 00 00 00 00       	mov    $0x0,%eax
f010377b:	eb 03                	jmp    f0103780 <strlen+0x10>
		n++;
f010377d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103784:	75 f7                	jne    f010377d <strlen+0xd>
		n++;
	return n;
}
f0103786:	5d                   	pop    %ebp
f0103787:	c3                   	ret    

f0103788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103788:	55                   	push   %ebp
f0103789:	89 e5                	mov    %esp,%ebp
f010378b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010378e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103791:	b8 00 00 00 00       	mov    $0x0,%eax
f0103796:	eb 03                	jmp    f010379b <strnlen+0x13>
		n++;
f0103798:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010379b:	39 d0                	cmp    %edx,%eax
f010379d:	74 06                	je     f01037a5 <strnlen+0x1d>
f010379f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01037a3:	75 f3                	jne    f0103798 <strnlen+0x10>
		n++;
	return n;
}
f01037a5:	5d                   	pop    %ebp
f01037a6:	c3                   	ret    

f01037a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01037a7:	55                   	push   %ebp
f01037a8:	89 e5                	mov    %esp,%ebp
f01037aa:	53                   	push   %ebx
f01037ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01037ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01037b1:	89 c2                	mov    %eax,%edx
f01037b3:	83 c2 01             	add    $0x1,%edx
f01037b6:	83 c1 01             	add    $0x1,%ecx
f01037b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01037bd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01037c0:	84 db                	test   %bl,%bl
f01037c2:	75 ef                	jne    f01037b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01037c4:	5b                   	pop    %ebx
f01037c5:	5d                   	pop    %ebp
f01037c6:	c3                   	ret    

f01037c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01037c7:	55                   	push   %ebp
f01037c8:	89 e5                	mov    %esp,%ebp
f01037ca:	53                   	push   %ebx
f01037cb:	83 ec 08             	sub    $0x8,%esp
f01037ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01037d1:	89 1c 24             	mov    %ebx,(%esp)
f01037d4:	e8 97 ff ff ff       	call   f0103770 <strlen>
	strcpy(dst + len, src);
f01037d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037dc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037e0:	01 d8                	add    %ebx,%eax
f01037e2:	89 04 24             	mov    %eax,(%esp)
f01037e5:	e8 bd ff ff ff       	call   f01037a7 <strcpy>
	return dst;
}
f01037ea:	89 d8                	mov    %ebx,%eax
f01037ec:	83 c4 08             	add    $0x8,%esp
f01037ef:	5b                   	pop    %ebx
f01037f0:	5d                   	pop    %ebp
f01037f1:	c3                   	ret    

f01037f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01037f2:	55                   	push   %ebp
f01037f3:	89 e5                	mov    %esp,%ebp
f01037f5:	56                   	push   %esi
f01037f6:	53                   	push   %ebx
f01037f7:	8b 75 08             	mov    0x8(%ebp),%esi
f01037fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01037fd:	89 f3                	mov    %esi,%ebx
f01037ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103802:	89 f2                	mov    %esi,%edx
f0103804:	eb 0f                	jmp    f0103815 <strncpy+0x23>
		*dst++ = *src;
f0103806:	83 c2 01             	add    $0x1,%edx
f0103809:	0f b6 01             	movzbl (%ecx),%eax
f010380c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010380f:	80 39 01             	cmpb   $0x1,(%ecx)
f0103812:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103815:	39 da                	cmp    %ebx,%edx
f0103817:	75 ed                	jne    f0103806 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103819:	89 f0                	mov    %esi,%eax
f010381b:	5b                   	pop    %ebx
f010381c:	5e                   	pop    %esi
f010381d:	5d                   	pop    %ebp
f010381e:	c3                   	ret    

f010381f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010381f:	55                   	push   %ebp
f0103820:	89 e5                	mov    %esp,%ebp
f0103822:	56                   	push   %esi
f0103823:	53                   	push   %ebx
f0103824:	8b 75 08             	mov    0x8(%ebp),%esi
f0103827:	8b 55 0c             	mov    0xc(%ebp),%edx
f010382a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010382d:	89 f0                	mov    %esi,%eax
f010382f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103833:	85 c9                	test   %ecx,%ecx
f0103835:	75 0b                	jne    f0103842 <strlcpy+0x23>
f0103837:	eb 1d                	jmp    f0103856 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103839:	83 c0 01             	add    $0x1,%eax
f010383c:	83 c2 01             	add    $0x1,%edx
f010383f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103842:	39 d8                	cmp    %ebx,%eax
f0103844:	74 0b                	je     f0103851 <strlcpy+0x32>
f0103846:	0f b6 0a             	movzbl (%edx),%ecx
f0103849:	84 c9                	test   %cl,%cl
f010384b:	75 ec                	jne    f0103839 <strlcpy+0x1a>
f010384d:	89 c2                	mov    %eax,%edx
f010384f:	eb 02                	jmp    f0103853 <strlcpy+0x34>
f0103851:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103853:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103856:	29 f0                	sub    %esi,%eax
}
f0103858:	5b                   	pop    %ebx
f0103859:	5e                   	pop    %esi
f010385a:	5d                   	pop    %ebp
f010385b:	c3                   	ret    

f010385c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010385c:	55                   	push   %ebp
f010385d:	89 e5                	mov    %esp,%ebp
f010385f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103862:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103865:	eb 06                	jmp    f010386d <strcmp+0x11>
		p++, q++;
f0103867:	83 c1 01             	add    $0x1,%ecx
f010386a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010386d:	0f b6 01             	movzbl (%ecx),%eax
f0103870:	84 c0                	test   %al,%al
f0103872:	74 04                	je     f0103878 <strcmp+0x1c>
f0103874:	3a 02                	cmp    (%edx),%al
f0103876:	74 ef                	je     f0103867 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103878:	0f b6 c0             	movzbl %al,%eax
f010387b:	0f b6 12             	movzbl (%edx),%edx
f010387e:	29 d0                	sub    %edx,%eax
}
f0103880:	5d                   	pop    %ebp
f0103881:	c3                   	ret    

f0103882 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103882:	55                   	push   %ebp
f0103883:	89 e5                	mov    %esp,%ebp
f0103885:	53                   	push   %ebx
f0103886:	8b 45 08             	mov    0x8(%ebp),%eax
f0103889:	8b 55 0c             	mov    0xc(%ebp),%edx
f010388c:	89 c3                	mov    %eax,%ebx
f010388e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103891:	eb 06                	jmp    f0103899 <strncmp+0x17>
		n--, p++, q++;
f0103893:	83 c0 01             	add    $0x1,%eax
f0103896:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103899:	39 d8                	cmp    %ebx,%eax
f010389b:	74 15                	je     f01038b2 <strncmp+0x30>
f010389d:	0f b6 08             	movzbl (%eax),%ecx
f01038a0:	84 c9                	test   %cl,%cl
f01038a2:	74 04                	je     f01038a8 <strncmp+0x26>
f01038a4:	3a 0a                	cmp    (%edx),%cl
f01038a6:	74 eb                	je     f0103893 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01038a8:	0f b6 00             	movzbl (%eax),%eax
f01038ab:	0f b6 12             	movzbl (%edx),%edx
f01038ae:	29 d0                	sub    %edx,%eax
f01038b0:	eb 05                	jmp    f01038b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01038b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01038b7:	5b                   	pop    %ebx
f01038b8:	5d                   	pop    %ebp
f01038b9:	c3                   	ret    

f01038ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01038ba:	55                   	push   %ebp
f01038bb:	89 e5                	mov    %esp,%ebp
f01038bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01038c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01038c4:	eb 07                	jmp    f01038cd <strchr+0x13>
		if (*s == c)
f01038c6:	38 ca                	cmp    %cl,%dl
f01038c8:	74 0f                	je     f01038d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01038ca:	83 c0 01             	add    $0x1,%eax
f01038cd:	0f b6 10             	movzbl (%eax),%edx
f01038d0:	84 d2                	test   %dl,%dl
f01038d2:	75 f2                	jne    f01038c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01038d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038d9:	5d                   	pop    %ebp
f01038da:	c3                   	ret    

f01038db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01038db:	55                   	push   %ebp
f01038dc:	89 e5                	mov    %esp,%ebp
f01038de:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01038e5:	eb 07                	jmp    f01038ee <strfind+0x13>
		if (*s == c)
f01038e7:	38 ca                	cmp    %cl,%dl
f01038e9:	74 0a                	je     f01038f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01038eb:	83 c0 01             	add    $0x1,%eax
f01038ee:	0f b6 10             	movzbl (%eax),%edx
f01038f1:	84 d2                	test   %dl,%dl
f01038f3:	75 f2                	jne    f01038e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01038f5:	5d                   	pop    %ebp
f01038f6:	c3                   	ret    

f01038f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01038f7:	55                   	push   %ebp
f01038f8:	89 e5                	mov    %esp,%ebp
f01038fa:	57                   	push   %edi
f01038fb:	56                   	push   %esi
f01038fc:	53                   	push   %ebx
f01038fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103903:	85 c9                	test   %ecx,%ecx
f0103905:	74 36                	je     f010393d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103907:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010390d:	75 28                	jne    f0103937 <memset+0x40>
f010390f:	f6 c1 03             	test   $0x3,%cl
f0103912:	75 23                	jne    f0103937 <memset+0x40>
		c &= 0xFF;
f0103914:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103918:	89 d3                	mov    %edx,%ebx
f010391a:	c1 e3 08             	shl    $0x8,%ebx
f010391d:	89 d6                	mov    %edx,%esi
f010391f:	c1 e6 18             	shl    $0x18,%esi
f0103922:	89 d0                	mov    %edx,%eax
f0103924:	c1 e0 10             	shl    $0x10,%eax
f0103927:	09 f0                	or     %esi,%eax
f0103929:	09 c2                	or     %eax,%edx
f010392b:	89 d0                	mov    %edx,%eax
f010392d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010392f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103932:	fc                   	cld    
f0103933:	f3 ab                	rep stos %eax,%es:(%edi)
f0103935:	eb 06                	jmp    f010393d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103937:	8b 45 0c             	mov    0xc(%ebp),%eax
f010393a:	fc                   	cld    
f010393b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010393d:	89 f8                	mov    %edi,%eax
f010393f:	5b                   	pop    %ebx
f0103940:	5e                   	pop    %esi
f0103941:	5f                   	pop    %edi
f0103942:	5d                   	pop    %ebp
f0103943:	c3                   	ret    

f0103944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103944:	55                   	push   %ebp
f0103945:	89 e5                	mov    %esp,%ebp
f0103947:	57                   	push   %edi
f0103948:	56                   	push   %esi
f0103949:	8b 45 08             	mov    0x8(%ebp),%eax
f010394c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010394f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103952:	39 c6                	cmp    %eax,%esi
f0103954:	73 35                	jae    f010398b <memmove+0x47>
f0103956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103959:	39 d0                	cmp    %edx,%eax
f010395b:	73 2e                	jae    f010398b <memmove+0x47>
		s += n;
		d += n;
f010395d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103960:	89 d6                	mov    %edx,%esi
f0103962:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103964:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010396a:	75 13                	jne    f010397f <memmove+0x3b>
f010396c:	f6 c1 03             	test   $0x3,%cl
f010396f:	75 0e                	jne    f010397f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103971:	83 ef 04             	sub    $0x4,%edi
f0103974:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103977:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010397a:	fd                   	std    
f010397b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010397d:	eb 09                	jmp    f0103988 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010397f:	83 ef 01             	sub    $0x1,%edi
f0103982:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103985:	fd                   	std    
f0103986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103988:	fc                   	cld    
f0103989:	eb 1d                	jmp    f01039a8 <memmove+0x64>
f010398b:	89 f2                	mov    %esi,%edx
f010398d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010398f:	f6 c2 03             	test   $0x3,%dl
f0103992:	75 0f                	jne    f01039a3 <memmove+0x5f>
f0103994:	f6 c1 03             	test   $0x3,%cl
f0103997:	75 0a                	jne    f01039a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103999:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010399c:	89 c7                	mov    %eax,%edi
f010399e:	fc                   	cld    
f010399f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01039a1:	eb 05                	jmp    f01039a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01039a3:	89 c7                	mov    %eax,%edi
f01039a5:	fc                   	cld    
f01039a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01039a8:	5e                   	pop    %esi
f01039a9:	5f                   	pop    %edi
f01039aa:	5d                   	pop    %ebp
f01039ab:	c3                   	ret    

f01039ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01039ac:	55                   	push   %ebp
f01039ad:	89 e5                	mov    %esp,%ebp
f01039af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01039b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01039b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c3:	89 04 24             	mov    %eax,(%esp)
f01039c6:	e8 79 ff ff ff       	call   f0103944 <memmove>
}
f01039cb:	c9                   	leave  
f01039cc:	c3                   	ret    

f01039cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01039cd:	55                   	push   %ebp
f01039ce:	89 e5                	mov    %esp,%ebp
f01039d0:	56                   	push   %esi
f01039d1:	53                   	push   %ebx
f01039d2:	8b 55 08             	mov    0x8(%ebp),%edx
f01039d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01039d8:	89 d6                	mov    %edx,%esi
f01039da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01039dd:	eb 1a                	jmp    f01039f9 <memcmp+0x2c>
		if (*s1 != *s2)
f01039df:	0f b6 02             	movzbl (%edx),%eax
f01039e2:	0f b6 19             	movzbl (%ecx),%ebx
f01039e5:	38 d8                	cmp    %bl,%al
f01039e7:	74 0a                	je     f01039f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01039e9:	0f b6 c0             	movzbl %al,%eax
f01039ec:	0f b6 db             	movzbl %bl,%ebx
f01039ef:	29 d8                	sub    %ebx,%eax
f01039f1:	eb 0f                	jmp    f0103a02 <memcmp+0x35>
		s1++, s2++;
f01039f3:	83 c2 01             	add    $0x1,%edx
f01039f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01039f9:	39 f2                	cmp    %esi,%edx
f01039fb:	75 e2                	jne    f01039df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01039fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a02:	5b                   	pop    %ebx
f0103a03:	5e                   	pop    %esi
f0103a04:	5d                   	pop    %ebp
f0103a05:	c3                   	ret    

f0103a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103a06:	55                   	push   %ebp
f0103a07:	89 e5                	mov    %esp,%ebp
f0103a09:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103a0f:	89 c2                	mov    %eax,%edx
f0103a11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103a14:	eb 07                	jmp    f0103a1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103a16:	38 08                	cmp    %cl,(%eax)
f0103a18:	74 07                	je     f0103a21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103a1a:	83 c0 01             	add    $0x1,%eax
f0103a1d:	39 d0                	cmp    %edx,%eax
f0103a1f:	72 f5                	jb     f0103a16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103a21:	5d                   	pop    %ebp
f0103a22:	c3                   	ret    

f0103a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103a23:	55                   	push   %ebp
f0103a24:	89 e5                	mov    %esp,%ebp
f0103a26:	57                   	push   %edi
f0103a27:	56                   	push   %esi
f0103a28:	53                   	push   %ebx
f0103a29:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103a2f:	eb 03                	jmp    f0103a34 <strtol+0x11>
		s++;
f0103a31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103a34:	0f b6 0a             	movzbl (%edx),%ecx
f0103a37:	80 f9 09             	cmp    $0x9,%cl
f0103a3a:	74 f5                	je     f0103a31 <strtol+0xe>
f0103a3c:	80 f9 20             	cmp    $0x20,%cl
f0103a3f:	74 f0                	je     f0103a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103a41:	80 f9 2b             	cmp    $0x2b,%cl
f0103a44:	75 0a                	jne    f0103a50 <strtol+0x2d>
		s++;
f0103a46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103a49:	bf 00 00 00 00       	mov    $0x0,%edi
f0103a4e:	eb 11                	jmp    f0103a61 <strtol+0x3e>
f0103a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103a55:	80 f9 2d             	cmp    $0x2d,%cl
f0103a58:	75 07                	jne    f0103a61 <strtol+0x3e>
		s++, neg = 1;
f0103a5a:	8d 52 01             	lea    0x1(%edx),%edx
f0103a5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103a61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0103a66:	75 15                	jne    f0103a7d <strtol+0x5a>
f0103a68:	80 3a 30             	cmpb   $0x30,(%edx)
f0103a6b:	75 10                	jne    f0103a7d <strtol+0x5a>
f0103a6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103a71:	75 0a                	jne    f0103a7d <strtol+0x5a>
		s += 2, base = 16;
f0103a73:	83 c2 02             	add    $0x2,%edx
f0103a76:	b8 10 00 00 00       	mov    $0x10,%eax
f0103a7b:	eb 10                	jmp    f0103a8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0103a7d:	85 c0                	test   %eax,%eax
f0103a7f:	75 0c                	jne    f0103a8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103a81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103a83:	80 3a 30             	cmpb   $0x30,(%edx)
f0103a86:	75 05                	jne    f0103a8d <strtol+0x6a>
		s++, base = 8;
f0103a88:	83 c2 01             	add    $0x1,%edx
f0103a8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0103a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103a95:	0f b6 0a             	movzbl (%edx),%ecx
f0103a98:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0103a9b:	89 f0                	mov    %esi,%eax
f0103a9d:	3c 09                	cmp    $0x9,%al
f0103a9f:	77 08                	ja     f0103aa9 <strtol+0x86>
			dig = *s - '0';
f0103aa1:	0f be c9             	movsbl %cl,%ecx
f0103aa4:	83 e9 30             	sub    $0x30,%ecx
f0103aa7:	eb 20                	jmp    f0103ac9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0103aa9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0103aac:	89 f0                	mov    %esi,%eax
f0103aae:	3c 19                	cmp    $0x19,%al
f0103ab0:	77 08                	ja     f0103aba <strtol+0x97>
			dig = *s - 'a' + 10;
f0103ab2:	0f be c9             	movsbl %cl,%ecx
f0103ab5:	83 e9 57             	sub    $0x57,%ecx
f0103ab8:	eb 0f                	jmp    f0103ac9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0103aba:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0103abd:	89 f0                	mov    %esi,%eax
f0103abf:	3c 19                	cmp    $0x19,%al
f0103ac1:	77 16                	ja     f0103ad9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0103ac3:	0f be c9             	movsbl %cl,%ecx
f0103ac6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103ac9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0103acc:	7d 0f                	jge    f0103add <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0103ace:	83 c2 01             	add    $0x1,%edx
f0103ad1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0103ad5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0103ad7:	eb bc                	jmp    f0103a95 <strtol+0x72>
f0103ad9:	89 d8                	mov    %ebx,%eax
f0103adb:	eb 02                	jmp    f0103adf <strtol+0xbc>
f0103add:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0103adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103ae3:	74 05                	je     f0103aea <strtol+0xc7>
		*endptr = (char *) s;
f0103ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ae8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103aea:	f7 d8                	neg    %eax
f0103aec:	85 ff                	test   %edi,%edi
f0103aee:	0f 44 c3             	cmove  %ebx,%eax
}
f0103af1:	5b                   	pop    %ebx
f0103af2:	5e                   	pop    %esi
f0103af3:	5f                   	pop    %edi
f0103af4:	5d                   	pop    %ebp
f0103af5:	c3                   	ret    
	...

f0103b00 <__udivdi3>:
f0103b00:	83 ec 1c             	sub    $0x1c,%esp
f0103b03:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103b07:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0103b0b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103b0f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103b13:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103b17:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103b1b:	85 ff                	test   %edi,%edi
f0103b1d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103b21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b25:	89 cd                	mov    %ecx,%ebp
f0103b27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2b:	75 33                	jne    f0103b60 <__udivdi3+0x60>
f0103b2d:	39 f1                	cmp    %esi,%ecx
f0103b2f:	77 57                	ja     f0103b88 <__udivdi3+0x88>
f0103b31:	85 c9                	test   %ecx,%ecx
f0103b33:	75 0b                	jne    f0103b40 <__udivdi3+0x40>
f0103b35:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b3a:	31 d2                	xor    %edx,%edx
f0103b3c:	f7 f1                	div    %ecx
f0103b3e:	89 c1                	mov    %eax,%ecx
f0103b40:	89 f0                	mov    %esi,%eax
f0103b42:	31 d2                	xor    %edx,%edx
f0103b44:	f7 f1                	div    %ecx
f0103b46:	89 c6                	mov    %eax,%esi
f0103b48:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103b4c:	f7 f1                	div    %ecx
f0103b4e:	89 f2                	mov    %esi,%edx
f0103b50:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103b54:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103b58:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103b5c:	83 c4 1c             	add    $0x1c,%esp
f0103b5f:	c3                   	ret    
f0103b60:	31 d2                	xor    %edx,%edx
f0103b62:	31 c0                	xor    %eax,%eax
f0103b64:	39 f7                	cmp    %esi,%edi
f0103b66:	77 e8                	ja     f0103b50 <__udivdi3+0x50>
f0103b68:	0f bd cf             	bsr    %edi,%ecx
f0103b6b:	83 f1 1f             	xor    $0x1f,%ecx
f0103b6e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103b72:	75 2c                	jne    f0103ba0 <__udivdi3+0xa0>
f0103b74:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0103b78:	76 04                	jbe    f0103b7e <__udivdi3+0x7e>
f0103b7a:	39 f7                	cmp    %esi,%edi
f0103b7c:	73 d2                	jae    f0103b50 <__udivdi3+0x50>
f0103b7e:	31 d2                	xor    %edx,%edx
f0103b80:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b85:	eb c9                	jmp    f0103b50 <__udivdi3+0x50>
f0103b87:	90                   	nop
f0103b88:	89 f2                	mov    %esi,%edx
f0103b8a:	f7 f1                	div    %ecx
f0103b8c:	31 d2                	xor    %edx,%edx
f0103b8e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103b92:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103b96:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103b9a:	83 c4 1c             	add    $0x1c,%esp
f0103b9d:	c3                   	ret    
f0103b9e:	66 90                	xchg   %ax,%ax
f0103ba0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103ba5:	b8 20 00 00 00       	mov    $0x20,%eax
f0103baa:	89 ea                	mov    %ebp,%edx
f0103bac:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103bb0:	d3 e7                	shl    %cl,%edi
f0103bb2:	89 c1                	mov    %eax,%ecx
f0103bb4:	d3 ea                	shr    %cl,%edx
f0103bb6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103bbb:	09 fa                	or     %edi,%edx
f0103bbd:	89 f7                	mov    %esi,%edi
f0103bbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103bc3:	89 f2                	mov    %esi,%edx
f0103bc5:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103bc9:	d3 e5                	shl    %cl,%ebp
f0103bcb:	89 c1                	mov    %eax,%ecx
f0103bcd:	d3 ef                	shr    %cl,%edi
f0103bcf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103bd4:	d3 e2                	shl    %cl,%edx
f0103bd6:	89 c1                	mov    %eax,%ecx
f0103bd8:	d3 ee                	shr    %cl,%esi
f0103bda:	09 d6                	or     %edx,%esi
f0103bdc:	89 fa                	mov    %edi,%edx
f0103bde:	89 f0                	mov    %esi,%eax
f0103be0:	f7 74 24 0c          	divl   0xc(%esp)
f0103be4:	89 d7                	mov    %edx,%edi
f0103be6:	89 c6                	mov    %eax,%esi
f0103be8:	f7 e5                	mul    %ebp
f0103bea:	39 d7                	cmp    %edx,%edi
f0103bec:	72 22                	jb     f0103c10 <__udivdi3+0x110>
f0103bee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0103bf2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103bf7:	d3 e5                	shl    %cl,%ebp
f0103bf9:	39 c5                	cmp    %eax,%ebp
f0103bfb:	73 04                	jae    f0103c01 <__udivdi3+0x101>
f0103bfd:	39 d7                	cmp    %edx,%edi
f0103bff:	74 0f                	je     f0103c10 <__udivdi3+0x110>
f0103c01:	89 f0                	mov    %esi,%eax
f0103c03:	31 d2                	xor    %edx,%edx
f0103c05:	e9 46 ff ff ff       	jmp    f0103b50 <__udivdi3+0x50>
f0103c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103c10:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103c13:	31 d2                	xor    %edx,%edx
f0103c15:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103c19:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103c1d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103c21:	83 c4 1c             	add    $0x1c,%esp
f0103c24:	c3                   	ret    
	...

f0103c30 <__umoddi3>:
f0103c30:	83 ec 1c             	sub    $0x1c,%esp
f0103c33:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103c37:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0103c3b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103c3f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103c43:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103c47:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103c4b:	85 ed                	test   %ebp,%ebp
f0103c4d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103c51:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c55:	89 cf                	mov    %ecx,%edi
f0103c57:	89 04 24             	mov    %eax,(%esp)
f0103c5a:	89 f2                	mov    %esi,%edx
f0103c5c:	75 1a                	jne    f0103c78 <__umoddi3+0x48>
f0103c5e:	39 f1                	cmp    %esi,%ecx
f0103c60:	76 4e                	jbe    f0103cb0 <__umoddi3+0x80>
f0103c62:	f7 f1                	div    %ecx
f0103c64:	89 d0                	mov    %edx,%eax
f0103c66:	31 d2                	xor    %edx,%edx
f0103c68:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103c6c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103c70:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103c74:	83 c4 1c             	add    $0x1c,%esp
f0103c77:	c3                   	ret    
f0103c78:	39 f5                	cmp    %esi,%ebp
f0103c7a:	77 54                	ja     f0103cd0 <__umoddi3+0xa0>
f0103c7c:	0f bd c5             	bsr    %ebp,%eax
f0103c7f:	83 f0 1f             	xor    $0x1f,%eax
f0103c82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c86:	75 60                	jne    f0103ce8 <__umoddi3+0xb8>
f0103c88:	3b 0c 24             	cmp    (%esp),%ecx
f0103c8b:	0f 87 07 01 00 00    	ja     f0103d98 <__umoddi3+0x168>
f0103c91:	89 f2                	mov    %esi,%edx
f0103c93:	8b 34 24             	mov    (%esp),%esi
f0103c96:	29 ce                	sub    %ecx,%esi
f0103c98:	19 ea                	sbb    %ebp,%edx
f0103c9a:	89 34 24             	mov    %esi,(%esp)
f0103c9d:	8b 04 24             	mov    (%esp),%eax
f0103ca0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103ca4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103ca8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103cac:	83 c4 1c             	add    $0x1c,%esp
f0103caf:	c3                   	ret    
f0103cb0:	85 c9                	test   %ecx,%ecx
f0103cb2:	75 0b                	jne    f0103cbf <__umoddi3+0x8f>
f0103cb4:	b8 01 00 00 00       	mov    $0x1,%eax
f0103cb9:	31 d2                	xor    %edx,%edx
f0103cbb:	f7 f1                	div    %ecx
f0103cbd:	89 c1                	mov    %eax,%ecx
f0103cbf:	89 f0                	mov    %esi,%eax
f0103cc1:	31 d2                	xor    %edx,%edx
f0103cc3:	f7 f1                	div    %ecx
f0103cc5:	8b 04 24             	mov    (%esp),%eax
f0103cc8:	f7 f1                	div    %ecx
f0103cca:	eb 98                	jmp    f0103c64 <__umoddi3+0x34>
f0103ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103cd0:	89 f2                	mov    %esi,%edx
f0103cd2:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103cd6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103cda:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103cde:	83 c4 1c             	add    $0x1c,%esp
f0103ce1:	c3                   	ret    
f0103ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103ce8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103ced:	89 e8                	mov    %ebp,%eax
f0103cef:	bd 20 00 00 00       	mov    $0x20,%ebp
f0103cf4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0103cf8:	89 fa                	mov    %edi,%edx
f0103cfa:	d3 e0                	shl    %cl,%eax
f0103cfc:	89 e9                	mov    %ebp,%ecx
f0103cfe:	d3 ea                	shr    %cl,%edx
f0103d00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103d05:	09 c2                	or     %eax,%edx
f0103d07:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103d0b:	89 14 24             	mov    %edx,(%esp)
f0103d0e:	89 f2                	mov    %esi,%edx
f0103d10:	d3 e7                	shl    %cl,%edi
f0103d12:	89 e9                	mov    %ebp,%ecx
f0103d14:	d3 ea                	shr    %cl,%edx
f0103d16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103d1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103d1f:	d3 e6                	shl    %cl,%esi
f0103d21:	89 e9                	mov    %ebp,%ecx
f0103d23:	d3 e8                	shr    %cl,%eax
f0103d25:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103d2a:	09 f0                	or     %esi,%eax
f0103d2c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103d30:	f7 34 24             	divl   (%esp)
f0103d33:	d3 e6                	shl    %cl,%esi
f0103d35:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103d39:	89 d6                	mov    %edx,%esi
f0103d3b:	f7 e7                	mul    %edi
f0103d3d:	39 d6                	cmp    %edx,%esi
f0103d3f:	89 c1                	mov    %eax,%ecx
f0103d41:	89 d7                	mov    %edx,%edi
f0103d43:	72 3f                	jb     f0103d84 <__umoddi3+0x154>
f0103d45:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0103d49:	72 35                	jb     f0103d80 <__umoddi3+0x150>
f0103d4b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103d4f:	29 c8                	sub    %ecx,%eax
f0103d51:	19 fe                	sbb    %edi,%esi
f0103d53:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103d58:	89 f2                	mov    %esi,%edx
f0103d5a:	d3 e8                	shr    %cl,%eax
f0103d5c:	89 e9                	mov    %ebp,%ecx
f0103d5e:	d3 e2                	shl    %cl,%edx
f0103d60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103d65:	09 d0                	or     %edx,%eax
f0103d67:	89 f2                	mov    %esi,%edx
f0103d69:	d3 ea                	shr    %cl,%edx
f0103d6b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103d6f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103d73:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103d77:	83 c4 1c             	add    $0x1c,%esp
f0103d7a:	c3                   	ret    
f0103d7b:	90                   	nop
f0103d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103d80:	39 d6                	cmp    %edx,%esi
f0103d82:	75 c7                	jne    f0103d4b <__umoddi3+0x11b>
f0103d84:	89 d7                	mov    %edx,%edi
f0103d86:	89 c1                	mov    %eax,%ecx
f0103d88:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0103d8c:	1b 3c 24             	sbb    (%esp),%edi
f0103d8f:	eb ba                	jmp    f0103d4b <__umoddi3+0x11b>
f0103d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103d98:	39 f5                	cmp    %esi,%ebp
f0103d9a:	0f 82 f1 fe ff ff    	jb     f0103c91 <__umoddi3+0x61>
f0103da0:	e9 f8 fe ff ff       	jmp    f0103c9d <__umoddi3+0x6d>
