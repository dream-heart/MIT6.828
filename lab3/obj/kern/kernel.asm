
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 90 dd 17 f0       	mov    $0xf017dd90,%eax
f010004b:	2d 65 ce 17 f0       	sub    $0xf017ce65,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 65 ce 17 f0 	movl   $0xf017ce65,(%esp)
f0100063:	e8 ef 44 00 00       	call   f0104557 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b2 04 00 00       	call   f010051f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 00 4a 10 f0 	movl   $0xf0104a00,(%esp)
f010007c:	e8 58 35 00 00       	call   f01035d9 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 98 10 00 00       	call   f010111e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 88 2e 00 00       	call   f0102f13 <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 bb 35 00 00       	call   f0103650 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010009c:	00 
f010009d:	c7 04 24 56 b3 11 f0 	movl   $0xf011b356,(%esp)
f01000a4:	e8 89 30 00 00       	call   f0103132 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a9:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f01000ae:	89 04 24             	mov    %eax,(%esp)
f01000b1:	e8 47 34 00 00       	call   f01034fd <env_run>

f01000b6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b6:	55                   	push   %ebp
f01000b7:	89 e5                	mov    %esp,%ebp
f01000b9:	56                   	push   %esi
f01000ba:	53                   	push   %ebx
f01000bb:	83 ec 10             	sub    $0x10,%esp
f01000be:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c1:	83 3d 80 dd 17 f0 00 	cmpl   $0x0,0xf017dd80
f01000c8:	75 3d                	jne    f0100107 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000ca:	89 35 80 dd 17 f0    	mov    %esi,0xf017dd80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d0:	fa                   	cli    
f01000d1:	fc                   	cld    

	va_start(ap, fmt);
f01000d2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01000df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e3:	c7 04 24 1b 4a 10 f0 	movl   $0xf0104a1b,(%esp)
f01000ea:	e8 ea 34 00 00       	call   f01035d9 <cprintf>
	vcprintf(fmt, ap);
f01000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f3:	89 34 24             	mov    %esi,(%esp)
f01000f6:	e8 ab 34 00 00       	call   f01035a6 <vcprintf>
	cprintf("\n");
f01000fb:	c7 04 24 e9 58 10 f0 	movl   $0xf01058e9,(%esp)
f0100102:	e8 d2 34 00 00       	call   f01035d9 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010010e:	e8 46 06 00 00       	call   f0100759 <monitor>
f0100113:	eb f2                	jmp    f0100107 <_panic+0x51>

f0100115 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100115:	55                   	push   %ebp
f0100116:	89 e5                	mov    %esp,%ebp
f0100118:	53                   	push   %ebx
f0100119:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010011c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100122:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100126:	8b 45 08             	mov    0x8(%ebp),%eax
f0100129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012d:	c7 04 24 33 4a 10 f0 	movl   $0xf0104a33,(%esp)
f0100134:	e8 a0 34 00 00       	call   f01035d9 <cprintf>
	vcprintf(fmt, ap);
f0100139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100140:	89 04 24             	mov    %eax,(%esp)
f0100143:	e8 5e 34 00 00       	call   f01035a6 <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 e9 58 10 f0 	movl   $0xf01058e9,(%esp)
f010014f:	e8 85 34 00 00       	call   f01035d9 <cprintf>
	va_end(ap);
}
f0100154:	83 c4 14             	add    $0x14,%esp
f0100157:	5b                   	pop    %ebx
f0100158:	5d                   	pop    %ebp
f0100159:	c3                   	ret    
f010015a:	66 90                	xchg   %ax,%ax
f010015c:	66 90                	xchg   %ax,%ax
f010015e:	66 90                	xchg   %ax,%ax

f0100160 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100160:	55                   	push   %ebp
f0100161:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100163:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100168:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100169:	a8 01                	test   $0x1,%al
f010016b:	74 08                	je     f0100175 <serial_proc_data+0x15>
f010016d:	b2 f8                	mov    $0xf8,%dl
f010016f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100170:	0f b6 c0             	movzbl %al,%eax
f0100173:	eb 05                	jmp    f010017a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010017c:	55                   	push   %ebp
f010017d:	89 e5                	mov    %esp,%ebp
f010017f:	53                   	push   %ebx
f0100180:	83 ec 04             	sub    $0x4,%esp
f0100183:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100185:	eb 2a                	jmp    f01001b1 <cons_intr+0x35>
		if (c == 0)
f0100187:	85 d2                	test   %edx,%edx
f0100189:	74 26                	je     f01001b1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010018b:	a1 a4 d0 17 f0       	mov    0xf017d0a4,%eax
f0100190:	8d 48 01             	lea    0x1(%eax),%ecx
f0100193:	89 0d a4 d0 17 f0    	mov    %ecx,0xf017d0a4
f0100199:	88 90 a0 ce 17 f0    	mov    %dl,-0xfe83160(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010019f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001a5:	75 0a                	jne    f01001b1 <cons_intr+0x35>
			cons.wpos = 0;
f01001a7:	c7 05 a4 d0 17 f0 00 	movl   $0x0,0xf017d0a4
f01001ae:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b1:	ff d3                	call   *%ebx
f01001b3:	89 c2                	mov    %eax,%edx
f01001b5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b8:	75 cd                	jne    f0100187 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ba:	83 c4 04             	add    $0x4,%esp
f01001bd:	5b                   	pop    %ebx
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <kbd_proc_data>:
f01001c0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	0f 84 ef 00 00 00    	je     f01002bd <kbd_proc_data+0xfd>
f01001ce:	b2 60                	mov    $0x60,%dl
f01001d0:	ec                   	in     (%dx),%al
f01001d1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d3:	3c e0                	cmp    $0xe0,%al
f01001d5:	75 0d                	jne    f01001e4 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001d7:	83 0d 80 ce 17 f0 40 	orl    $0x40,0xf017ce80
		return 0;
f01001de:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001e3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001e4:	55                   	push   %ebp
f01001e5:	89 e5                	mov    %esp,%ebp
f01001e7:	53                   	push   %ebx
f01001e8:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001eb:	84 c0                	test   %al,%al
f01001ed:	79 37                	jns    f0100226 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ef:	8b 0d 80 ce 17 f0    	mov    0xf017ce80,%ecx
f01001f5:	89 cb                	mov    %ecx,%ebx
f01001f7:	83 e3 40             	and    $0x40,%ebx
f01001fa:	83 e0 7f             	and    $0x7f,%eax
f01001fd:	85 db                	test   %ebx,%ebx
f01001ff:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100202:	0f b6 d2             	movzbl %dl,%edx
f0100205:	0f b6 82 a0 4b 10 f0 	movzbl -0xfefb460(%edx),%eax
f010020c:	83 c8 40             	or     $0x40,%eax
f010020f:	0f b6 c0             	movzbl %al,%eax
f0100212:	f7 d0                	not    %eax
f0100214:	21 c1                	and    %eax,%ecx
f0100216:	89 0d 80 ce 17 f0    	mov    %ecx,0xf017ce80
		return 0;
f010021c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100221:	e9 9d 00 00 00       	jmp    f01002c3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100226:	8b 0d 80 ce 17 f0    	mov    0xf017ce80,%ecx
f010022c:	f6 c1 40             	test   $0x40,%cl
f010022f:	74 0e                	je     f010023f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100231:	83 c8 80             	or     $0xffffff80,%eax
f0100234:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100236:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100239:	89 0d 80 ce 17 f0    	mov    %ecx,0xf017ce80
	}

	shift |= shiftcode[data];
f010023f:	0f b6 d2             	movzbl %dl,%edx
f0100242:	0f b6 82 a0 4b 10 f0 	movzbl -0xfefb460(%edx),%eax
f0100249:	0b 05 80 ce 17 f0    	or     0xf017ce80,%eax
	shift ^= togglecode[data];
f010024f:	0f b6 8a a0 4a 10 f0 	movzbl -0xfefb560(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 80 ce 17 f0       	mov    %eax,0xf017ce80

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 80 4a 10 f0 	mov    -0xfefb580(,%ecx,4),%ecx
f0100269:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010026d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100270:	a8 08                	test   $0x8,%al
f0100272:	74 1b                	je     f010028f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100274:	89 da                	mov    %ebx,%edx
f0100276:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100279:	83 f9 19             	cmp    $0x19,%ecx
f010027c:	77 05                	ja     f0100283 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010027e:	83 eb 20             	sub    $0x20,%ebx
f0100281:	eb 0c                	jmp    f010028f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100283:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100286:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100289:	83 fa 19             	cmp    $0x19,%edx
f010028c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028f:	f7 d0                	not    %eax
f0100291:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100293:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100295:	f6 c2 06             	test   $0x6,%dl
f0100298:	75 29                	jne    f01002c3 <kbd_proc_data+0x103>
f010029a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002a0:	75 21                	jne    f01002c3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002a2:	c7 04 24 4d 4a 10 f0 	movl   $0xf0104a4d,(%esp)
f01002a9:	e8 2b 33 00 00       	call   f01035d9 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ae:	ba 92 00 00 00       	mov    $0x92,%edx
f01002b3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002b8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b9:	89 d8                	mov    %ebx,%eax
f01002bb:	eb 06                	jmp    f01002c3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002c2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002c3:	83 c4 14             	add    $0x14,%esp
f01002c6:	5b                   	pop    %ebx
f01002c7:	5d                   	pop    %ebp
f01002c8:	c3                   	ret    

f01002c9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c9:	55                   	push   %ebp
f01002ca:	89 e5                	mov    %esp,%ebp
f01002cc:	57                   	push   %edi
f01002cd:	56                   	push   %esi
f01002ce:	53                   	push   %ebx
f01002cf:	83 ec 1c             	sub    $0x1c,%esp
f01002d2:	89 c7                	mov    %eax,%edi
f01002d4:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002de:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e3:	eb 06                	jmp    f01002eb <cons_putc+0x22>
f01002e5:	89 ca                	mov    %ecx,%edx
f01002e7:	ec                   	in     (%dx),%al
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ee:	a8 20                	test   $0x20,%al
f01002f0:	75 05                	jne    f01002f7 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002f2:	83 eb 01             	sub    $0x1,%ebx
f01002f5:	75 ee                	jne    f01002e5 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002f7:	89 f8                	mov    %edi,%eax
f01002f9:	0f b6 c0             	movzbl %al,%eax
f01002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100304:	ee                   	out    %al,(%dx)
f0100305:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030a:	be 79 03 00 00       	mov    $0x379,%esi
f010030f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100314:	eb 06                	jmp    f010031c <cons_putc+0x53>
f0100316:	89 ca                	mov    %ecx,%edx
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	89 f2                	mov    %esi,%edx
f010031e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010031f:	84 c0                	test   %al,%al
f0100321:	78 05                	js     f0100328 <cons_putc+0x5f>
f0100323:	83 eb 01             	sub    $0x1,%ebx
f0100326:	75 ee                	jne    f0100316 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100328:	ba 78 03 00 00       	mov    $0x378,%edx
f010032d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100331:	ee                   	out    %al,(%dx)
f0100332:	b2 7a                	mov    $0x7a,%dl
f0100334:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100339:	ee                   	out    %al,(%dx)
f010033a:	b8 08 00 00 00       	mov    $0x8,%eax
f010033f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100340:	89 fa                	mov    %edi,%edx
f0100342:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100348:	89 f8                	mov    %edi,%eax
f010034a:	80 cc 07             	or     $0x7,%ah
f010034d:	85 d2                	test   %edx,%edx
f010034f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100352:	89 f8                	mov    %edi,%eax
f0100354:	0f b6 c0             	movzbl %al,%eax
f0100357:	83 f8 09             	cmp    $0x9,%eax
f010035a:	74 76                	je     f01003d2 <cons_putc+0x109>
f010035c:	83 f8 09             	cmp    $0x9,%eax
f010035f:	7f 0a                	jg     f010036b <cons_putc+0xa2>
f0100361:	83 f8 08             	cmp    $0x8,%eax
f0100364:	74 16                	je     f010037c <cons_putc+0xb3>
f0100366:	e9 9b 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
f010036b:	83 f8 0a             	cmp    $0xa,%eax
f010036e:	66 90                	xchg   %ax,%ax
f0100370:	74 3a                	je     f01003ac <cons_putc+0xe3>
f0100372:	83 f8 0d             	cmp    $0xd,%eax
f0100375:	74 3d                	je     f01003b4 <cons_putc+0xeb>
f0100377:	e9 8a 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010037c:	0f b7 05 a8 d0 17 f0 	movzwl 0xf017d0a8,%eax
f0100383:	66 85 c0             	test   %ax,%ax
f0100386:	0f 84 e5 00 00 00    	je     f0100471 <cons_putc+0x1a8>
			crt_pos--;
f010038c:	83 e8 01             	sub    $0x1,%eax
f010038f:	66 a3 a8 d0 17 f0    	mov    %ax,0xf017d0a8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100395:	0f b7 c0             	movzwl %ax,%eax
f0100398:	66 81 e7 00 ff       	and    $0xff00,%di
f010039d:	83 cf 20             	or     $0x20,%edi
f01003a0:	8b 15 ac d0 17 f0    	mov    0xf017d0ac,%edx
f01003a6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003aa:	eb 78                	jmp    f0100424 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ac:	66 83 05 a8 d0 17 f0 	addw   $0x50,0xf017d0a8
f01003b3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b4:	0f b7 05 a8 d0 17 f0 	movzwl 0xf017d0a8,%eax
f01003bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c1:	c1 e8 16             	shr    $0x16,%eax
f01003c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c7:	c1 e0 04             	shl    $0x4,%eax
f01003ca:	66 a3 a8 d0 17 f0    	mov    %ax,0xf017d0a8
f01003d0:	eb 52                	jmp    f0100424 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 ed fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e1:	e8 e3 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003e6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003eb:	e8 d9 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f5:	e8 cf fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ff:	e8 c5 fe ff ff       	call   f01002c9 <cons_putc>
f0100404:	eb 1e                	jmp    f0100424 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100406:	0f b7 05 a8 d0 17 f0 	movzwl 0xf017d0a8,%eax
f010040d:	8d 50 01             	lea    0x1(%eax),%edx
f0100410:	66 89 15 a8 d0 17 f0 	mov    %dx,0xf017d0a8
f0100417:	0f b7 c0             	movzwl %ax,%eax
f010041a:	8b 15 ac d0 17 f0    	mov    0xf017d0ac,%edx
f0100420:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100424:	66 81 3d a8 d0 17 f0 	cmpw   $0x7cf,0xf017d0a8
f010042b:	cf 07 
f010042d:	76 42                	jbe    f0100471 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010042f:	a1 ac d0 17 f0       	mov    0xf017d0ac,%eax
f0100434:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010043b:	00 
f010043c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100442:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100446:	89 04 24             	mov    %eax,(%esp)
f0100449:	e8 56 41 00 00       	call   f01045a4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044e:	8b 15 ac d0 17 f0    	mov    0xf017d0ac,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100454:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100459:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045f:	83 c0 01             	add    $0x1,%eax
f0100462:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100467:	75 f0                	jne    f0100459 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100469:	66 83 2d a8 d0 17 f0 	subw   $0x50,0xf017d0a8
f0100470:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100471:	8b 0d b0 d0 17 f0    	mov    0xf017d0b0,%ecx
f0100477:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047c:	89 ca                	mov    %ecx,%edx
f010047e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047f:	0f b7 1d a8 d0 17 f0 	movzwl 0xf017d0a8,%ebx
f0100486:	8d 71 01             	lea    0x1(%ecx),%esi
f0100489:	89 d8                	mov    %ebx,%eax
f010048b:	66 c1 e8 08          	shr    $0x8,%ax
f010048f:	89 f2                	mov    %esi,%edx
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100497:	89 ca                	mov    %ecx,%edx
f0100499:	ee                   	out    %al,(%dx)
f010049a:	89 d8                	mov    %ebx,%eax
f010049c:	89 f2                	mov    %esi,%edx
f010049e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010049f:	83 c4 1c             	add    $0x1c,%esp
f01004a2:	5b                   	pop    %ebx
f01004a3:	5e                   	pop    %esi
f01004a4:	5f                   	pop    %edi
f01004a5:	5d                   	pop    %ebp
f01004a6:	c3                   	ret    

f01004a7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a7:	80 3d b4 d0 17 f0 00 	cmpb   $0x0,0xf017d0b4
f01004ae:	74 11                	je     f01004c1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b0:	55                   	push   %ebp
f01004b1:	89 e5                	mov    %esp,%ebp
f01004b3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b6:	b8 60 01 10 f0       	mov    $0xf0100160,%eax
f01004bb:	e8 bc fc ff ff       	call   f010017c <cons_intr>
}
f01004c0:	c9                   	leave  
f01004c1:	f3 c3                	repz ret 

f01004c3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c9:	b8 c0 01 10 f0       	mov    $0xf01001c0,%eax
f01004ce:	e8 a9 fc ff ff       	call   f010017c <cons_intr>
}
f01004d3:	c9                   	leave  
f01004d4:	c3                   	ret    

f01004d5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004db:	e8 c7 ff ff ff       	call   f01004a7 <serial_intr>
	kbd_intr();
f01004e0:	e8 de ff ff ff       	call   f01004c3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e5:	a1 a0 d0 17 f0       	mov    0xf017d0a0,%eax
f01004ea:	3b 05 a4 d0 17 f0    	cmp    0xf017d0a4,%eax
f01004f0:	74 26                	je     f0100518 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 a0 d0 17 f0    	mov    %edx,0xf017d0a0
f01004fb:	0f b6 88 a0 ce 17 f0 	movzbl -0xfe83160(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100502:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100504:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050a:	75 11                	jne    f010051d <cons_getc+0x48>
			cons.rpos = 0;
f010050c:	c7 05 a0 d0 17 f0 00 	movl   $0x0,0xf017d0a0
f0100513:	00 00 00 
f0100516:	eb 05                	jmp    f010051d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010051d:	c9                   	leave  
f010051e:	c3                   	ret    

f010051f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010051f:	55                   	push   %ebp
f0100520:	89 e5                	mov    %esp,%ebp
f0100522:	57                   	push   %edi
f0100523:	56                   	push   %esi
f0100524:	53                   	push   %ebx
f0100525:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100528:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010052f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100536:	5a a5 
	if (*cp != 0xA55A) {
f0100538:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010053f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100543:	74 11                	je     f0100556 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100545:	c7 05 b0 d0 17 f0 b4 	movl   $0x3b4,0xf017d0b0
f010054c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100554:	eb 16                	jmp    f010056c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100556:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010055d:	c7 05 b0 d0 17 f0 d4 	movl   $0x3d4,0xf017d0b0
f0100564:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100567:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056c:	8b 0d b0 d0 17 f0    	mov    0xf017d0b0,%ecx
f0100572:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100577:	89 ca                	mov    %ecx,%edx
f0100579:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010057a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057d:	89 da                	mov    %ebx,%edx
f010057f:	ec                   	in     (%dx),%al
f0100580:	0f b6 f0             	movzbl %al,%esi
f0100583:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100586:	b8 0f 00 00 00       	mov    $0xf,%eax
f010058b:	89 ca                	mov    %ecx,%edx
f010058d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058e:	89 da                	mov    %ebx,%edx
f0100590:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100591:	89 3d ac d0 17 f0    	mov    %edi,0xf017d0ac

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100597:	0f b6 d8             	movzbl %al,%ebx
f010059a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010059c:	66 89 35 a8 d0 17 f0 	mov    %si,0xf017d0a8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	89 f2                	mov    %esi,%edx
f01005af:	ee                   	out    %al,(%dx)
f01005b0:	b2 fb                	mov    $0xfb,%dl
f01005b2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005bd:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ee                   	out    %al,(%dx)
f01005c5:	b2 f9                	mov    $0xf9,%dl
f01005c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	b2 fb                	mov    $0xfb,%dl
f01005cf:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	b2 fc                	mov    $0xfc,%dl
f01005d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	b2 f9                	mov    $0xf9,%dl
f01005df:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e5:	b2 fd                	mov    $0xfd,%dl
f01005e7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e8:	3c ff                	cmp    $0xff,%al
f01005ea:	0f 95 c1             	setne  %cl
f01005ed:	88 0d b4 d0 17 f0    	mov    %cl,0xf017d0b4
f01005f3:	89 f2                	mov    %esi,%edx
f01005f5:	ec                   	in     (%dx),%al
f01005f6:	89 da                	mov    %ebx,%edx
f01005f8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f9:	84 c9                	test   %cl,%cl
f01005fb:	75 0c                	jne    f0100609 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f01005fd:	c7 04 24 59 4a 10 f0 	movl   $0xf0104a59,(%esp)
f0100604:	e8 d0 2f 00 00       	call   f01035d9 <cprintf>
}
f0100609:	83 c4 1c             	add    $0x1c,%esp
f010060c:	5b                   	pop    %ebx
f010060d:	5e                   	pop    %esi
f010060e:	5f                   	pop    %edi
f010060f:	5d                   	pop    %ebp
f0100610:	c3                   	ret    

f0100611 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100617:	8b 45 08             	mov    0x8(%ebp),%eax
f010061a:	e8 aa fc ff ff       	call   f01002c9 <cons_putc>
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <getchar>:

int
getchar(void)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100627:	e8 a9 fe ff ff       	call   f01004d5 <cons_getc>
f010062c:	85 c0                	test   %eax,%eax
f010062e:	74 f7                	je     f0100627 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <iscons>:

int
iscons(int fdnum)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100635:	b8 01 00 00 00       	mov    $0x1,%eax
f010063a:	5d                   	pop    %ebp
f010063b:	c3                   	ret    
f010063c:	66 90                	xchg   %ax,%ax
f010063e:	66 90                	xchg   %ax,%ax

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	c7 44 24 08 a0 4c 10 	movl   $0xf0104ca0,0x8(%esp)
f010064d:	f0 
f010064e:	c7 44 24 04 be 4c 10 	movl   $0xf0104cbe,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 c3 4c 10 f0 	movl   $0xf0104cc3,(%esp)
f010065d:	e8 77 2f 00 00       	call   f01035d9 <cprintf>
f0100662:	c7 44 24 08 2c 4d 10 	movl   $0xf0104d2c,0x8(%esp)
f0100669:	f0 
f010066a:	c7 44 24 04 cc 4c 10 	movl   $0xf0104ccc,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 c3 4c 10 f0 	movl   $0xf0104cc3,(%esp)
f0100679:	e8 5b 2f 00 00       	call   f01035d9 <cprintf>
	return 0;
}
f010067e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100683:	c9                   	leave  
f0100684:	c3                   	ret    

f0100685 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100685:	55                   	push   %ebp
f0100686:	89 e5                	mov    %esp,%ebp
f0100688:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068b:	c7 04 24 d5 4c 10 f0 	movl   $0xf0104cd5,(%esp)
f0100692:	e8 42 2f 00 00       	call   f01035d9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100697:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069e:	00 
f010069f:	c7 04 24 54 4d 10 f0 	movl   $0xf0104d54,(%esp)
f01006a6:	e8 2e 2f 00 00       	call   f01035d9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ab:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b2:	00 
f01006b3:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006ba:	f0 
f01006bb:	c7 04 24 7c 4d 10 f0 	movl   $0xf0104d7c,(%esp)
f01006c2:	e8 12 2f 00 00       	call   f01035d9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c7:	c7 44 24 08 e7 49 10 	movl   $0x1049e7,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 e7 49 10 	movl   $0xf01049e7,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 a0 4d 10 f0 	movl   $0xf0104da0,(%esp)
f01006de:	e8 f6 2e 00 00       	call   f01035d9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e3:	c7 44 24 08 65 ce 17 	movl   $0x17ce65,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 65 ce 17 	movl   $0xf017ce65,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 c4 4d 10 f0 	movl   $0xf0104dc4,(%esp)
f01006fa:	e8 da 2e 00 00       	call   f01035d9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ff:	c7 44 24 08 90 dd 17 	movl   $0x17dd90,0x8(%esp)
f0100706:	00 
f0100707:	c7 44 24 04 90 dd 17 	movl   $0xf017dd90,0x4(%esp)
f010070e:	f0 
f010070f:	c7 04 24 e8 4d 10 f0 	movl   $0xf0104de8,(%esp)
f0100716:	e8 be 2e 00 00       	call   f01035d9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071b:	b8 8f e1 17 f0       	mov    $0xf017e18f,%eax
f0100720:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100725:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010072a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100730:	85 c0                	test   %eax,%eax
f0100732:	0f 48 c2             	cmovs  %edx,%eax
f0100735:	c1 f8 0a             	sar    $0xa,%eax
f0100738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073c:	c7 04 24 0c 4e 10 f0 	movl   $0xf0104e0c,(%esp)
f0100743:	e8 91 2e 00 00       	call   f01035d9 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100748:	b8 00 00 00 00       	mov    $0x0,%eax
f010074d:	c9                   	leave  
f010074e:	c3                   	ret    

f010074f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074f:	55                   	push   %ebp
f0100750:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100752:	b8 00 00 00 00       	mov    $0x0,%eax
f0100757:	5d                   	pop    %ebp
f0100758:	c3                   	ret    

f0100759 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100759:	55                   	push   %ebp
f010075a:	89 e5                	mov    %esp,%ebp
f010075c:	57                   	push   %edi
f010075d:	56                   	push   %esi
f010075e:	53                   	push   %ebx
f010075f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100762:	c7 04 24 38 4e 10 f0 	movl   $0xf0104e38,(%esp)
f0100769:	e8 6b 2e 00 00       	call   f01035d9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010076e:	c7 04 24 5c 4e 10 f0 	movl   $0xf0104e5c,(%esp)
f0100775:	e8 5f 2e 00 00       	call   f01035d9 <cprintf>

	if (tf != NULL)
f010077a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010077e:	74 0b                	je     f010078b <monitor+0x32>
		print_trapframe(tf);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	89 04 24             	mov    %eax,(%esp)
f0100786:	e8 76 2f 00 00       	call   f0103701 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010078b:	c7 04 24 ee 4c 10 f0 	movl   $0xf0104cee,(%esp)
f0100792:	e8 69 3b 00 00       	call   f0104300 <readline>
f0100797:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100799:	85 c0                	test   %eax,%eax
f010079b:	74 ee                	je     f010078b <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010079d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007a4:	be 00 00 00 00       	mov    $0x0,%esi
f01007a9:	eb 0a                	jmp    f01007b5 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007ab:	c6 03 00             	movb   $0x0,(%ebx)
f01007ae:	89 f7                	mov    %esi,%edi
f01007b0:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007b3:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007b5:	0f b6 03             	movzbl (%ebx),%eax
f01007b8:	84 c0                	test   %al,%al
f01007ba:	74 63                	je     f010081f <monitor+0xc6>
f01007bc:	0f be c0             	movsbl %al,%eax
f01007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c3:	c7 04 24 f2 4c 10 f0 	movl   $0xf0104cf2,(%esp)
f01007ca:	e8 4b 3d 00 00       	call   f010451a <strchr>
f01007cf:	85 c0                	test   %eax,%eax
f01007d1:	75 d8                	jne    f01007ab <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01007d3:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007d6:	74 47                	je     f010081f <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007d8:	83 fe 0f             	cmp    $0xf,%esi
f01007db:	75 16                	jne    f01007f3 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007dd:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007e4:	00 
f01007e5:	c7 04 24 f7 4c 10 f0 	movl   $0xf0104cf7,(%esp)
f01007ec:	e8 e8 2d 00 00       	call   f01035d9 <cprintf>
f01007f1:	eb 98                	jmp    f010078b <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01007f3:	8d 7e 01             	lea    0x1(%esi),%edi
f01007f6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007fa:	eb 03                	jmp    f01007ff <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007fc:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007ff:	0f b6 03             	movzbl (%ebx),%eax
f0100802:	84 c0                	test   %al,%al
f0100804:	74 ad                	je     f01007b3 <monitor+0x5a>
f0100806:	0f be c0             	movsbl %al,%eax
f0100809:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080d:	c7 04 24 f2 4c 10 f0 	movl   $0xf0104cf2,(%esp)
f0100814:	e8 01 3d 00 00       	call   f010451a <strchr>
f0100819:	85 c0                	test   %eax,%eax
f010081b:	74 df                	je     f01007fc <monitor+0xa3>
f010081d:	eb 94                	jmp    f01007b3 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f010081f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100826:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100827:	85 f6                	test   %esi,%esi
f0100829:	0f 84 5c ff ff ff    	je     f010078b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010082f:	c7 44 24 04 be 4c 10 	movl   $0xf0104cbe,0x4(%esp)
f0100836:	f0 
f0100837:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010083a:	89 04 24             	mov    %eax,(%esp)
f010083d:	e8 7a 3c 00 00       	call   f01044bc <strcmp>
f0100842:	85 c0                	test   %eax,%eax
f0100844:	74 1b                	je     f0100861 <monitor+0x108>
f0100846:	c7 44 24 04 cc 4c 10 	movl   $0xf0104ccc,0x4(%esp)
f010084d:	f0 
f010084e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 63 3c 00 00       	call   f01044bc <strcmp>
f0100859:	85 c0                	test   %eax,%eax
f010085b:	75 2f                	jne    f010088c <monitor+0x133>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010085d:	b0 01                	mov    $0x1,%al
f010085f:	eb 05                	jmp    f0100866 <monitor+0x10d>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100861:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100866:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100869:	01 d0                	add    %edx,%eax
f010086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010086e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100872:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100875:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100879:	89 34 24             	mov    %esi,(%esp)
f010087c:	ff 14 85 8c 4e 10 f0 	call   *-0xfefb174(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100883:	85 c0                	test   %eax,%eax
f0100885:	78 1d                	js     f01008a4 <monitor+0x14b>
f0100887:	e9 ff fe ff ff       	jmp    f010078b <monitor+0x32>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010088c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	c7 04 24 14 4d 10 f0 	movl   $0xf0104d14,(%esp)
f010089a:	e8 3a 2d 00 00       	call   f01035d9 <cprintf>
f010089f:	e9 e7 fe ff ff       	jmp    f010078b <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008a4:	83 c4 5c             	add    $0x5c,%esp
f01008a7:	5b                   	pop    %ebx
f01008a8:	5e                   	pop    %esi
f01008a9:	5f                   	pop    %edi
f01008aa:	5d                   	pop    %ebp
f01008ab:	c3                   	ret    
f01008ac:	66 90                	xchg   %ax,%ax
f01008ae:	66 90                	xchg   %ax,%ax

f01008b0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008b0:	55                   	push   %ebp
f01008b1:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008b3:	83 3d b8 d0 17 f0 00 	cmpl   $0x0,0xf017d0b8
f01008ba:	75 11                	jne    f01008cd <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008bc:	ba 8f ed 17 f0       	mov    $0xf017ed8f,%edx
f01008c1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008c7:	89 15 b8 d0 17 f0    	mov    %edx,0xf017d0b8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f01008cd:	85 c0                	test   %eax,%eax
f01008cf:	75 07                	jne    f01008d8 <boot_alloc+0x28>
		return nextfree;
f01008d1:	a1 b8 d0 17 f0       	mov    0xf017d0b8,%eax
f01008d6:	eb 19                	jmp    f01008f1 <boot_alloc+0x41>
	result = nextfree;
f01008d8:	8b 15 b8 d0 17 f0    	mov    0xf017d0b8,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f01008de:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01008e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008ea:	a3 b8 d0 17 f0       	mov    %eax,0xf017d0b8
	
	// return the head address of the alloc pages;
	return result;
f01008ef:	89 d0                	mov    %edx,%eax

}
f01008f1:	5d                   	pop    %ebp
f01008f2:	c3                   	ret    

f01008f3 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01008f3:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f01008f9:	c1 f8 03             	sar    $0x3,%eax
f01008fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008ff:	89 c2                	mov    %eax,%edx
f0100901:	c1 ea 0c             	shr    $0xc,%edx
f0100904:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f010090a:	72 26                	jb     f0100932 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f010090c:	55                   	push   %ebp
f010090d:	89 e5                	mov    %esp,%ebp
f010090f:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100912:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100916:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f010091d:	f0 
f010091e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100925:	00 
f0100926:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f010092d:	e8 84 f7 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100932:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100937:	c3                   	ret    

f0100938 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100938:	89 d1                	mov    %edx,%ecx
f010093a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010093d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100940:	a8 01                	test   $0x1,%al
f0100942:	74 5d                	je     f01009a1 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100949:	89 c1                	mov    %eax,%ecx
f010094b:	c1 e9 0c             	shr    $0xc,%ecx
f010094e:	3b 0d 84 dd 17 f0    	cmp    0xf017dd84,%ecx
f0100954:	72 26                	jb     f010097c <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100956:	55                   	push   %ebp
f0100957:	89 e5                	mov    %esp,%ebp
f0100959:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010095c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100960:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0100967:	f0 
f0100968:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010096f:	00 
f0100970:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100977:	e8 3a f7 ff ff       	call   f01000b6 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f010097c:	c1 ea 0c             	shr    $0xc,%edx
f010097f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100985:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010098c:	89 c2                	mov    %eax,%edx
f010098e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100991:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100996:	85 d2                	test   %edx,%edx
f0100998:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010099d:	0f 44 c2             	cmove  %edx,%eax
f01009a0:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009a6:	c3                   	ret    

f01009a7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	57                   	push   %edi
f01009ab:	56                   	push   %esi
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009b0:	84 c0                	test   %al,%al
f01009b2:	0f 85 07 03 00 00    	jne    f0100cbf <check_page_free_list+0x318>
f01009b8:	e9 14 03 00 00       	jmp    f0100cd1 <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009bd:	c7 44 24 08 c0 4e 10 	movl   $0xf0104ec0,0x8(%esp)
f01009c4:	f0 
f01009c5:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f01009cc:	00 
f01009cd:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01009d4:	e8 dd f6 ff ff       	call   f01000b6 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009d9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009df:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009e5:	89 c2                	mov    %eax,%edx
f01009e7:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009ed:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01009f3:	0f 95 c2             	setne  %dl
f01009f6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01009f9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01009fd:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01009ff:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a03:	8b 00                	mov    (%eax),%eax
f0100a05:	85 c0                	test   %eax,%eax
f0100a07:	75 dc                	jne    f01009e5 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a15:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a18:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a1d:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a22:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a27:	8b 1d bc d0 17 f0    	mov    0xf017d0bc,%ebx
f0100a2d:	eb 63                	jmp    f0100a92 <check_page_free_list+0xeb>
f0100a2f:	89 d8                	mov    %ebx,%eax
f0100a31:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f0100a37:	c1 f8 03             	sar    $0x3,%eax
f0100a3a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a3d:	89 c2                	mov    %eax,%edx
f0100a3f:	c1 ea 16             	shr    $0x16,%edx
f0100a42:	39 f2                	cmp    %esi,%edx
f0100a44:	73 4a                	jae    f0100a90 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a46:	89 c2                	mov    %eax,%edx
f0100a48:	c1 ea 0c             	shr    $0xc,%edx
f0100a4b:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f0100a51:	72 20                	jb     f0100a73 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a57:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0100a5e:	f0 
f0100a5f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100a66:	00 
f0100a67:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0100a6e:	e8 43 f6 ff ff       	call   f01000b6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a73:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100a7a:	00 
f0100a7b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100a82:	00 
	return (void *)(pa + KERNBASE);
f0100a83:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a88:	89 04 24             	mov    %eax,(%esp)
f0100a8b:	e8 c7 3a 00 00       	call   f0104557 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a90:	8b 1b                	mov    (%ebx),%ebx
f0100a92:	85 db                	test   %ebx,%ebx
f0100a94:	75 99                	jne    f0100a2f <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a9b:	e8 10 fe ff ff       	call   f01008b0 <boot_alloc>
f0100aa0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa3:	8b 15 bc d0 17 f0    	mov    0xf017d0bc,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aa9:	8b 0d 8c dd 17 f0    	mov    0xf017dd8c,%ecx
		assert(pp < pages + npages);
f0100aaf:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f0100ab4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ab7:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100aba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100abd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ac0:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ac5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ac8:	e9 97 01 00 00       	jmp    f0100c64 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100acd:	39 ca                	cmp    %ecx,%edx
f0100acf:	73 24                	jae    f0100af5 <check_page_free_list+0x14e>
f0100ad1:	c7 44 24 0c 3b 56 10 	movl   $0xf010563b,0xc(%esp)
f0100ad8:	f0 
f0100ad9:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100ae0:	f0 
f0100ae1:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f0100ae8:	00 
f0100ae9:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100af0:	e8 c1 f5 ff ff       	call   f01000b6 <_panic>
		assert(pp < pages + npages);
f0100af5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100af8:	72 24                	jb     f0100b1e <check_page_free_list+0x177>
f0100afa:	c7 44 24 0c 5c 56 10 	movl   $0xf010565c,0xc(%esp)
f0100b01:	f0 
f0100b02:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100b09:	f0 
f0100b0a:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0100b11:	00 
f0100b12:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100b19:	e8 98 f5 ff ff       	call   f01000b6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1e:	89 d0                	mov    %edx,%eax
f0100b20:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b23:	a8 07                	test   $0x7,%al
f0100b25:	74 24                	je     f0100b4b <check_page_free_list+0x1a4>
f0100b27:	c7 44 24 0c e4 4e 10 	movl   $0xf0104ee4,0xc(%esp)
f0100b2e:	f0 
f0100b2f:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100b36:	f0 
f0100b37:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
f0100b3e:	00 
f0100b3f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100b46:	e8 6b f5 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b4b:	c1 f8 03             	sar    $0x3,%eax
f0100b4e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b51:	85 c0                	test   %eax,%eax
f0100b53:	75 24                	jne    f0100b79 <check_page_free_list+0x1d2>
f0100b55:	c7 44 24 0c 70 56 10 	movl   $0xf0105670,0xc(%esp)
f0100b5c:	f0 
f0100b5d:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100b64:	f0 
f0100b65:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100b6c:	00 
f0100b6d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100b74:	e8 3d f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b79:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b7e:	75 24                	jne    f0100ba4 <check_page_free_list+0x1fd>
f0100b80:	c7 44 24 0c 81 56 10 	movl   $0xf0105681,0xc(%esp)
f0100b87:	f0 
f0100b88:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100b8f:	f0 
f0100b90:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0100b97:	00 
f0100b98:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100b9f:	e8 12 f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ba4:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ba9:	75 24                	jne    f0100bcf <check_page_free_list+0x228>
f0100bab:	c7 44 24 0c 18 4f 10 	movl   $0xf0104f18,0xc(%esp)
f0100bb2:	f0 
f0100bb3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100bba:	f0 
f0100bbb:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0100bc2:	00 
f0100bc3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100bca:	e8 e7 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bcf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bd4:	75 24                	jne    f0100bfa <check_page_free_list+0x253>
f0100bd6:	c7 44 24 0c 9a 56 10 	movl   $0xf010569a,0xc(%esp)
f0100bdd:	f0 
f0100bde:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100be5:	f0 
f0100be6:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100bed:	00 
f0100bee:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100bf5:	e8 bc f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bfa:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bff:	76 58                	jbe    f0100c59 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c01:	89 c3                	mov    %eax,%ebx
f0100c03:	c1 eb 0c             	shr    $0xc,%ebx
f0100c06:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c09:	77 20                	ja     f0100c2b <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c0f:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0100c16:	f0 
f0100c17:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100c1e:	00 
f0100c1f:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0100c26:	e8 8b f4 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100c2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c30:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c33:	76 2a                	jbe    f0100c5f <check_page_free_list+0x2b8>
f0100c35:	c7 44 24 0c 3c 4f 10 	movl   $0xf0104f3c,0xc(%esp)
f0100c3c:	f0 
f0100c3d:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100c44:	f0 
f0100c45:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100c4c:	00 
f0100c4d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100c54:	e8 5d f4 ff ff       	call   f01000b6 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c59:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100c5d:	eb 03                	jmp    f0100c62 <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100c5f:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c62:	8b 12                	mov    (%edx),%edx
f0100c64:	85 d2                	test   %edx,%edx
f0100c66:	0f 85 61 fe ff ff    	jne    f0100acd <check_page_free_list+0x126>
f0100c6c:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c6f:	85 db                	test   %ebx,%ebx
f0100c71:	7f 24                	jg     f0100c97 <check_page_free_list+0x2f0>
f0100c73:	c7 44 24 0c b4 56 10 	movl   $0xf01056b4,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100c92:	e8 1f f4 ff ff       	call   f01000b6 <_panic>
	assert(nfree_extmem > 0);
f0100c97:	85 ff                	test   %edi,%edi
f0100c99:	7f 4d                	jg     f0100ce8 <check_page_free_list+0x341>
f0100c9b:	c7 44 24 0c c6 56 10 	movl   $0xf01056c6,0xc(%esp)
f0100ca2:	f0 
f0100ca3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100cba:	e8 f7 f3 ff ff       	call   f01000b6 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cbf:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f0100cc4:	85 c0                	test   %eax,%eax
f0100cc6:	0f 85 0d fd ff ff    	jne    f01009d9 <check_page_free_list+0x32>
f0100ccc:	e9 ec fc ff ff       	jmp    f01009bd <check_page_free_list+0x16>
f0100cd1:	83 3d bc d0 17 f0 00 	cmpl   $0x0,0xf017d0bc
f0100cd8:	0f 84 df fc ff ff    	je     f01009bd <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cde:	be 00 04 00 00       	mov    $0x400,%esi
f0100ce3:	e9 3f fd ff ff       	jmp    f0100a27 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ce8:	83 c4 4c             	add    $0x4c,%esp
f0100ceb:	5b                   	pop    %ebx
f0100cec:	5e                   	pop    %esi
f0100ced:	5f                   	pop    %edi
f0100cee:	5d                   	pop    %ebp
f0100cef:	c3                   	ret    

f0100cf0 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cf0:	55                   	push   %ebp
f0100cf1:	89 e5                	mov    %esp,%ebp
f0100cf3:	56                   	push   %esi
f0100cf4:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100cf5:	be 00 00 00 00       	mov    $0x0,%esi
f0100cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cff:	e9 c5 00 00 00       	jmp    f0100dc9 <page_init+0xd9>
		if(i == 0)
f0100d04:	85 db                	test   %ebx,%ebx
f0100d06:	75 16                	jne    f0100d1e <page_init+0x2e>
			{	pages[i].pp_ref = 1;
f0100d08:	a1 8c dd 17 f0       	mov    0xf017dd8c,%eax
f0100d0d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d19:	e9 a5 00 00 00       	jmp    f0100dc3 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d1e:	3b 1d c0 d0 17 f0    	cmp    0xf017d0c0,%ebx
f0100d24:	73 25                	jae    f0100d4b <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d26:	89 f0                	mov    %esi,%eax
f0100d28:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d2e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d34:	8b 15 bc d0 17 f0    	mov    0xf017d0bc,%edx
f0100d3a:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d3c:	89 f0                	mov    %esi,%eax
f0100d3e:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d44:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
f0100d49:	eb 78                	jmp    f0100dc3 <page_init+0xd3>
f0100d4b:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d51:	83 f8 5f             	cmp    $0x5f,%eax
f0100d54:	77 16                	ja     f0100d6c <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100d56:	89 f0                	mov    %esi,%eax
f0100d58:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d5e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d6a:	eb 57                	jmp    f0100dc3 <page_init+0xd3>
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100d6c:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100d72:	76 2c                	jbe    f0100da0 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100d74:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d79:	e8 32 fb ff ff       	call   f01008b0 <boot_alloc>
f0100d7e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d83:	c1 e8 0c             	shr    $0xc,%eax
		{
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
	
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100d86:	39 c3                	cmp    %eax,%ebx
f0100d88:	73 16                	jae    f0100da0 <page_init+0xb0>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100d8a:	89 f0                	mov    %esi,%eax
f0100d8c:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d92:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100d98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d9e:	eb 23                	jmp    f0100dc3 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100da0:	89 f0                	mov    %esi,%eax
f0100da2:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100da8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dae:	8b 15 bc d0 17 f0    	mov    0xf017d0bc,%edx
f0100db4:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100db6:	89 f0                	mov    %esi,%eax
f0100db8:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100dbe:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dc3:	83 c3 01             	add    $0x1,%ebx
f0100dc6:	83 c6 08             	add    $0x8,%esi
f0100dc9:	3b 1d 84 dd 17 f0    	cmp    0xf017dd84,%ebx
f0100dcf:	0f 82 2f ff ff ff    	jb     f0100d04 <page_init+0x14>
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100dd5:	5b                   	pop    %ebx
f0100dd6:	5e                   	pop    %esi
f0100dd7:	5d                   	pop    %ebp
f0100dd8:	c3                   	ret    

f0100dd9 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100dd9:	55                   	push   %ebp
f0100dda:	89 e5                	mov    %esp,%ebp
f0100ddc:	53                   	push   %ebx
f0100ddd:	83 ec 14             	sub    $0x14,%esp
	if(page_free_list == NULL)
f0100de0:	8b 1d bc d0 17 f0    	mov    0xf017d0bc,%ebx
f0100de6:	85 db                	test   %ebx,%ebx
f0100de8:	74 6f                	je     f0100e59 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100dea:	8b 03                	mov    (%ebx),%eax
f0100dec:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
	page->pp_link = 0;
f0100df1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
f0100df7:	89 d8                	mov    %ebx,%eax
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
f0100df9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dfd:	74 5f                	je     f0100e5e <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dff:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f0100e05:	c1 f8 03             	sar    $0x3,%eax
f0100e08:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0b:	89 c2                	mov    %eax,%edx
f0100e0d:	c1 ea 0c             	shr    $0xc,%edx
f0100e10:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f0100e16:	72 20                	jb     f0100e38 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e18:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e1c:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0100e23:	f0 
f0100e24:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e2b:	00 
f0100e2c:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0100e33:	e8 7e f2 ff ff       	call   f01000b6 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100e38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e3f:	00 
f0100e40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e47:	00 
	return (void *)(pa + KERNBASE);
f0100e48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e4d:	89 04 24             	mov    %eax,(%esp)
f0100e50:	e8 02 37 00 00       	call   f0104557 <memset>
	return page;
f0100e55:	89 d8                	mov    %ebx,%eax
f0100e57:	eb 05                	jmp    f0100e5e <page_alloc+0x85>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if(page_free_list == NULL)
		return NULL;
f0100e59:	b8 00 00 00 00       	mov    $0x0,%eax
	page_free_list = page->pp_link;
	page->pp_link = 0;
	if(alloc_flags & ALLOC_ZERO)
		memset(page2kva(page), 0, PGSIZE);
	return page;
}
f0100e5e:	83 c4 14             	add    $0x14,%esp
f0100e61:	5b                   	pop    %ebx
f0100e62:	5d                   	pop    %ebp
f0100e63:	c3                   	ret    

f0100e64 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e64:	55                   	push   %ebp
f0100e65:	89 e5                	mov    %esp,%ebp
f0100e67:	83 ec 18             	sub    $0x18,%esp
f0100e6a:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0100e6d:	83 38 00             	cmpl   $0x0,(%eax)
f0100e70:	75 07                	jne    f0100e79 <page_free+0x15>
f0100e72:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e77:	74 1c                	je     f0100e95 <page_free+0x31>
		panic("page_free is not right");
f0100e79:	c7 44 24 08 d7 56 10 	movl   $0xf01056d7,0x8(%esp)
f0100e80:	f0 
f0100e81:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0100e88:	00 
f0100e89:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100e90:	e8 21 f2 ff ff       	call   f01000b6 <_panic>
	pp->pp_link = page_free_list;
f0100e95:	8b 15 bc d0 17 f0    	mov    0xf017d0bc,%edx
f0100e9b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e9d:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
	return; 
}
f0100ea2:	c9                   	leave  
f0100ea3:	c3                   	ret    

f0100ea4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ea4:	55                   	push   %ebp
f0100ea5:	89 e5                	mov    %esp,%ebp
f0100ea7:	83 ec 18             	sub    $0x18,%esp
f0100eaa:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100ead:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100eb1:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100eb4:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100eb8:	66 85 d2             	test   %dx,%dx
f0100ebb:	75 08                	jne    f0100ec5 <page_decref+0x21>
		page_free(pp);
f0100ebd:	89 04 24             	mov    %eax,(%esp)
f0100ec0:	e8 9f ff ff ff       	call   f0100e64 <page_free>
}
f0100ec5:	c9                   	leave  
f0100ec6:	c3                   	ret    

f0100ec7 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ec7:	55                   	push   %ebp
f0100ec8:	89 e5                	mov    %esp,%ebp
f0100eca:	56                   	push   %esi
f0100ecb:	53                   	push   %ebx
f0100ecc:	83 ec 10             	sub    $0x10,%esp
f0100ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
f0100ed2:	89 f3                	mov    %esi,%ebx
f0100ed4:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create == 0)
f0100ed7:	c1 e3 02             	shl    $0x2,%ebx
f0100eda:	03 5d 08             	add    0x8(%ebp),%ebx
f0100edd:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100ee0:	75 2c                	jne    f0100f0e <pgdir_walk+0x47>
f0100ee2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ee6:	74 6c                	je     f0100f54 <pgdir_walk+0x8d>
		return NULL;
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f0100ee8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100eef:	e8 e5 fe ff ff       	call   f0100dd9 <page_alloc>
		if(page == NULL)
f0100ef4:	85 c0                	test   %eax,%eax
f0100ef6:	74 63                	je     f0100f5b <pgdir_walk+0x94>
			return NULL;
		page->pp_ref++;
f0100ef8:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100efd:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f0100f03:	c1 f8 03             	sar    $0x3,%eax
f0100f06:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0100f09:	83 c8 07             	or     $0x7,%eax
f0100f0c:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f0100f0e:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd>>12<<12;
	int pteIndex =(pte_t)va >>12 & 0x3ff;
f0100f10:	c1 ee 0a             	shr    $0xa,%esi
	pte_t * pte =(pte_t*) pgAdd + pteIndex;
f0100f13:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd>>12<<12;
f0100f19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t * pte =(pte_t*) pgAdd + pteIndex;
f0100f1e:	01 f0                	add    %esi,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f20:	89 c2                	mov    %eax,%edx
f0100f22:	c1 ea 0c             	shr    $0xc,%edx
f0100f25:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f0100f2b:	72 20                	jb     f0100f4d <pgdir_walk+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f31:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0100f38:	f0 
f0100f39:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f0100f40:	00 
f0100f41:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0100f48:	e8 69 f1 ff ff       	call   f01000b6 <_panic>
	return KADDR( (pte_t) pte );
f0100f4d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f52:	eb 0c                	jmp    f0100f60 <pgdir_walk+0x99>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >>22;
	if(pgdir[pdeIndex] == 0 && create == 0)
		return NULL;
f0100f54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f59:	eb 05                	jmp    f0100f60 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL)
			return NULL;
f0100f5b:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd>>12<<12;
	int pteIndex =(pte_t)va >>12 & 0x3ff;
	pte_t * pte =(pte_t*) pgAdd + pteIndex;
	return KADDR( (pte_t) pte );
}
f0100f60:	83 c4 10             	add    $0x10,%esp
f0100f63:	5b                   	pop    %ebx
f0100f64:	5e                   	pop    %esi
f0100f65:	5d                   	pop    %ebp
f0100f66:	c3                   	ret    

f0100f67 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f67:	55                   	push   %ebp
f0100f68:	89 e5                	mov    %esp,%ebp
f0100f6a:	57                   	push   %edi
f0100f6b:	56                   	push   %esi
f0100f6c:	53                   	push   %ebx
f0100f6d:	83 ec 2c             	sub    $0x2c,%esp
f0100f70:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f73:	89 ce                	mov    %ecx,%esi
	while(size)
f0100f75:	89 d3                	mov    %edx,%ebx
f0100f77:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f7a:	29 d0                	sub    %edx,%eax
f0100f7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
		if(pte == NULL)
			return;
		*pte= pa |perm|PTE_P;
f0100f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f82:	83 c8 01             	or     $0x1,%eax
f0100f85:	89 45 dc             	mov    %eax,-0x24(%ebp)
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	while(size)
f0100f88:	eb 2c                	jmp    f0100fb6 <boot_map_region+0x4f>
	{
		pte_t* pte = pgdir_walk(pgdir, (void* )va, 1);
f0100f8a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100f91:	00 
f0100f92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f96:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f99:	89 04 24             	mov    %eax,(%esp)
f0100f9c:	e8 26 ff ff ff       	call   f0100ec7 <pgdir_walk>
		if(pte == NULL)
f0100fa1:	85 c0                	test   %eax,%eax
f0100fa3:	74 1b                	je     f0100fc0 <boot_map_region+0x59>
			return;
		*pte= pa |perm|PTE_P;
f0100fa5:	0b 7d dc             	or     -0x24(%ebp),%edi
f0100fa8:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f0100faa:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa  += PGSIZE;
		va  += PGSIZE;
f0100fb0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fb9:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	while(size)
f0100fbc:	85 f6                	test   %esi,%esi
f0100fbe:	75 ca                	jne    f0100f8a <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa  += PGSIZE;
		va  += PGSIZE;
	}
}
f0100fc0:	83 c4 2c             	add    $0x2c,%esp
f0100fc3:	5b                   	pop    %ebx
f0100fc4:	5e                   	pop    %esi
f0100fc5:	5f                   	pop    %edi
f0100fc6:	5d                   	pop    %ebp
f0100fc7:	c3                   	ret    

f0100fc8 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fc8:	55                   	push   %ebp
f0100fc9:	89 e5                	mov    %esp,%ebp
f0100fcb:	53                   	push   %ebx
f0100fcc:	83 ec 14             	sub    $0x14,%esp
f0100fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
pte_t* pte = pgdir_walk(pgdir, va, 0);
f0100fd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fd9:	00 
f0100fda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fe1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe4:	89 04 24             	mov    %eax,(%esp)
f0100fe7:	e8 db fe ff ff       	call   f0100ec7 <pgdir_walk>
	if(pte == NULL)
f0100fec:	85 c0                	test   %eax,%eax
f0100fee:	74 42                	je     f0101032 <page_lookup+0x6a>
		return NULL;
	pte_t pa =  *pte>>12<<12;
f0100ff0:	8b 10                	mov    (%eax),%edx
f0100ff2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0)
f0100ff8:	85 db                	test   %ebx,%ebx
f0100ffa:	74 02                	je     f0100ffe <page_lookup+0x36>
		*pte_store = pte ;
f0100ffc:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ffe:	89 d0                	mov    %edx,%eax
f0101000:	c1 e8 0c             	shr    $0xc,%eax
f0101003:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f0101009:	72 1c                	jb     f0101027 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f010100b:	c7 44 24 08 84 4f 10 	movl   $0xf0104f84,0x8(%esp)
f0101012:	f0 
f0101013:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010101a:	00 
f010101b:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0101022:	e8 8f f0 ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0101027:	8b 15 8c dd 17 f0    	mov    0xf017dd8c,%edx
f010102d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);	
f0101030:	eb 05                	jmp    f0101037 <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
pte_t* pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL)
		return NULL;
f0101032:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa =  *pte>>12<<12;
	if(pte_store != 0)
		*pte_store = pte ;
	return pa2page(pa);	
}
f0101037:	83 c4 14             	add    $0x14,%esp
f010103a:	5b                   	pop    %ebx
f010103b:	5d                   	pop    %ebp
f010103c:	c3                   	ret    

f010103d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010103d:	55                   	push   %ebp
f010103e:	89 e5                	mov    %esp,%ebp
f0101040:	53                   	push   %ebx
f0101041:	83 ec 24             	sub    $0x24,%esp
f0101044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101047:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010104a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010104e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101052:	8b 45 08             	mov    0x8(%ebp),%eax
f0101055:	89 04 24             	mov    %eax,(%esp)
f0101058:	e8 6b ff ff ff       	call   f0100fc8 <page_lookup>
	if(page == 0)
f010105d:	85 c0                	test   %eax,%eax
f010105f:	74 24                	je     f0101085 <page_remove+0x48>
		return;
	*pte = 0;
f0101061:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101064:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f010106a:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f010106e:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101071:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref ==0)
f0101075:	66 85 d2             	test   %dx,%dx
f0101078:	75 08                	jne    f0101082 <page_remove+0x45>
		page_free(page);
f010107a:	89 04 24             	mov    %eax,(%esp)
f010107d:	e8 e2 fd ff ff       	call   f0100e64 <page_free>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101082:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f0101085:	83 c4 24             	add    $0x24,%esp
f0101088:	5b                   	pop    %ebx
f0101089:	5d                   	pop    %ebp
f010108a:	c3                   	ret    

f010108b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010108b:	55                   	push   %ebp
f010108c:	89 e5                	mov    %esp,%ebp
f010108e:	57                   	push   %edi
f010108f:	56                   	push   %esi
f0101090:	53                   	push   %ebx
f0101091:	83 ec 1c             	sub    $0x1c,%esp
f0101094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101097:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f010109a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010a1:	00 
f01010a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a9:	89 04 24             	mov    %eax,(%esp)
f01010ac:	e8 16 fe ff ff       	call   f0100ec7 <pgdir_walk>
f01010b1:	89 c6                	mov    %eax,%esi
	if(pte == NULL)
f01010b3:	85 c0                	test   %eax,%eax
f01010b5:	74 5a                	je     f0101111 <page_insert+0x86>
		return -E_NO_MEM;
	if( (pte[0] &  ~0xfff) == page2pa(pp))
f01010b7:	8b 00                	mov    (%eax),%eax
f01010b9:	89 c1                	mov    %eax,%ecx
f01010bb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c1:	89 da                	mov    %ebx,%edx
f01010c3:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f01010c9:	c1 fa 03             	sar    $0x3,%edx
f01010cc:	c1 e2 0c             	shl    $0xc,%edx
f01010cf:	39 d1                	cmp    %edx,%ecx
f01010d1:	75 07                	jne    f01010da <page_insert+0x4f>
		pp->pp_ref--;
f01010d3:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01010d8:	eb 13                	jmp    f01010ed <page_insert+0x62>
	
	else if(*pte != 0)
f01010da:	85 c0                	test   %eax,%eax
f01010dc:	74 0f                	je     f01010ed <page_insert+0x62>
		page_remove(pgdir, va);
f01010de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010e5:	89 04 24             	mov    %eax,(%esp)
f01010e8:	e8 50 ff ff ff       	call   f010103d <page_remove>

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f01010ed:	8b 55 14             	mov    0x14(%ebp),%edx
f01010f0:	83 ca 01             	or     $0x1,%edx
f01010f3:	89 d8                	mov    %ebx,%eax
f01010f5:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f01010fb:	c1 f8 03             	sar    $0x3,%eax
f01010fe:	c1 e0 0c             	shl    $0xc,%eax
f0101101:	09 d0                	or     %edx,%eax
f0101103:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f0101105:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f010110a:	b8 00 00 00 00       	mov    $0x0,%eax
f010110f:	eb 05                	jmp    f0101116 <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL)
		return -E_NO_MEM;
f0101111:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
	
}
f0101116:	83 c4 1c             	add    $0x1c,%esp
f0101119:	5b                   	pop    %ebx
f010111a:	5e                   	pop    %esi
f010111b:	5f                   	pop    %edi
f010111c:	5d                   	pop    %ebp
f010111d:	c3                   	ret    

f010111e <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010111e:	55                   	push   %ebp
f010111f:	89 e5                	mov    %esp,%ebp
f0101121:	57                   	push   %edi
f0101122:	56                   	push   %esi
f0101123:	53                   	push   %ebx
f0101124:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101127:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010112e:	e8 36 24 00 00       	call   f0103569 <mc146818_read>
f0101133:	89 c3                	mov    %eax,%ebx
f0101135:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010113c:	e8 28 24 00 00       	call   f0103569 <mc146818_read>
f0101141:	c1 e0 08             	shl    $0x8,%eax
f0101144:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101146:	89 d8                	mov    %ebx,%eax
f0101148:	c1 e0 0a             	shl    $0xa,%eax
f010114b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101151:	85 c0                	test   %eax,%eax
f0101153:	0f 48 c2             	cmovs  %edx,%eax
f0101156:	c1 f8 0c             	sar    $0xc,%eax
f0101159:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010115e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101165:	e8 ff 23 00 00       	call   f0103569 <mc146818_read>
f010116a:	89 c3                	mov    %eax,%ebx
f010116c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101173:	e8 f1 23 00 00       	call   f0103569 <mc146818_read>
f0101178:	c1 e0 08             	shl    $0x8,%eax
f010117b:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010117d:	89 d8                	mov    %ebx,%eax
f010117f:	c1 e0 0a             	shl    $0xa,%eax
f0101182:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101188:	85 c0                	test   %eax,%eax
f010118a:	0f 48 c2             	cmovs  %edx,%eax
f010118d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101190:	85 c0                	test   %eax,%eax
f0101192:	74 0e                	je     f01011a2 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101194:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010119a:	89 15 84 dd 17 f0    	mov    %edx,0xf017dd84
f01011a0:	eb 0c                	jmp    f01011ae <mem_init+0x90>
	else
		npages = npages_basemem;
f01011a2:	8b 15 c0 d0 17 f0    	mov    0xf017d0c0,%edx
f01011a8:	89 15 84 dd 17 f0    	mov    %edx,0xf017dd84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01011ae:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011b1:	c1 e8 0a             	shr    $0xa,%eax
f01011b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01011b8:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
f01011bd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c0:	c1 e8 0a             	shr    $0xa,%eax
f01011c3:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01011c7:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f01011cc:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011cf:	c1 e8 0a             	shr    $0xa,%eax
f01011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d6:	c7 04 24 a4 4f 10 f0 	movl   $0xf0104fa4,(%esp)
f01011dd:	e8 f7 23 00 00       	call   f01035d9 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e7:	e8 c4 f6 ff ff       	call   f01008b0 <boot_alloc>
f01011ec:	a3 88 dd 17 f0       	mov    %eax,0xf017dd88
	memset(kern_pgdir, 0, PGSIZE);
f01011f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011f8:	00 
f01011f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101200:	00 
f0101201:	89 04 24             	mov    %eax,(%esp)
f0101204:	e8 4e 33 00 00       	call   f0104557 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101209:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010120e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101213:	77 20                	ja     f0101235 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101215:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101219:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0101220:	f0 
f0101221:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0101228:	00 
f0101229:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101230:	e8 81 ee ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101235:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010123b:	83 ca 05             	or     $0x5,%edx
f010123e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(npages * sizeof (struct PageInfo));
f0101244:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f0101249:	c1 e0 03             	shl    $0x3,%eax
f010124c:	e8 5f f6 ff ff       	call   f01008b0 <boot_alloc>
f0101251:	a3 8c dd 17 f0       	mov    %eax,0xf017dd8c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101256:	8b 3d 84 dd 17 f0    	mov    0xf017dd84,%edi
f010125c:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101263:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101267:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010126e:	00 
f010126f:	89 04 24             	mov    %eax,(%esp)
f0101272:	e8 e0 32 00 00       	call   f0104557 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101277:	b8 00 80 01 00       	mov    $0x18000,%eax
f010127c:	e8 2f f6 ff ff       	call   f01008b0 <boot_alloc>
f0101281:	a3 c8 d0 17 f0       	mov    %eax,0xf017d0c8
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101286:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f010128d:	00 
f010128e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101295:	00 
f0101296:	89 04 24             	mov    %eax,(%esp)
f0101299:	e8 b9 32 00 00       	call   f0104557 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010129e:	e8 4d fa ff ff       	call   f0100cf0 <page_init>

	check_page_free_list(1);
f01012a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01012a8:	e8 fa f6 ff ff       	call   f01009a7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012ad:	83 3d 8c dd 17 f0 00 	cmpl   $0x0,0xf017dd8c
f01012b4:	75 1c                	jne    f01012d2 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f01012b6:	c7 44 24 08 ee 56 10 	movl   $0xf01056ee,0x8(%esp)
f01012bd:	f0 
f01012be:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f01012c5:	00 
f01012c6:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01012cd:	e8 e4 ed ff ff       	call   f01000b6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012d2:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f01012d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012dc:	eb 05                	jmp    f01012e3 <mem_init+0x1c5>
		++nfree;
f01012de:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012e1:	8b 00                	mov    (%eax),%eax
f01012e3:	85 c0                	test   %eax,%eax
f01012e5:	75 f7                	jne    f01012de <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012ee:	e8 e6 fa ff ff       	call   f0100dd9 <page_alloc>
f01012f3:	89 c7                	mov    %eax,%edi
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	75 24                	jne    f010131d <mem_init+0x1ff>
f01012f9:	c7 44 24 0c 09 57 10 	movl   $0xf0105709,0xc(%esp)
f0101300:	f0 
f0101301:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101308:	f0 
f0101309:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0101310:	00 
f0101311:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101318:	e8 99 ed ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010131d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101324:	e8 b0 fa ff ff       	call   f0100dd9 <page_alloc>
f0101329:	89 c6                	mov    %eax,%esi
f010132b:	85 c0                	test   %eax,%eax
f010132d:	75 24                	jne    f0101353 <mem_init+0x235>
f010132f:	c7 44 24 0c 1f 57 10 	movl   $0xf010571f,0xc(%esp)
f0101336:	f0 
f0101337:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010133e:	f0 
f010133f:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101346:	00 
f0101347:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010134e:	e8 63 ed ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010135a:	e8 7a fa ff ff       	call   f0100dd9 <page_alloc>
f010135f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101362:	85 c0                	test   %eax,%eax
f0101364:	75 24                	jne    f010138a <mem_init+0x26c>
f0101366:	c7 44 24 0c 35 57 10 	movl   $0xf0105735,0xc(%esp)
f010136d:	f0 
f010136e:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101375:	f0 
f0101376:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f010137d:	00 
f010137e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101385:	e8 2c ed ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010138a:	39 f7                	cmp    %esi,%edi
f010138c:	75 24                	jne    f01013b2 <mem_init+0x294>
f010138e:	c7 44 24 0c 4b 57 10 	movl   $0xf010574b,0xc(%esp)
f0101395:	f0 
f0101396:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010139d:	f0 
f010139e:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01013a5:	00 
f01013a6:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01013ad:	e8 04 ed ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013b5:	39 c6                	cmp    %eax,%esi
f01013b7:	74 04                	je     f01013bd <mem_init+0x29f>
f01013b9:	39 c7                	cmp    %eax,%edi
f01013bb:	75 24                	jne    f01013e1 <mem_init+0x2c3>
f01013bd:	c7 44 24 0c 04 50 10 	movl   $0xf0105004,0xc(%esp)
f01013c4:	f0 
f01013c5:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01013cc:	f0 
f01013cd:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f01013d4:	00 
f01013d5:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01013dc:	e8 d5 ec ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013e1:	8b 15 8c dd 17 f0    	mov    0xf017dd8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013e7:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f01013ec:	c1 e0 0c             	shl    $0xc,%eax
f01013ef:	89 f9                	mov    %edi,%ecx
f01013f1:	29 d1                	sub    %edx,%ecx
f01013f3:	c1 f9 03             	sar    $0x3,%ecx
f01013f6:	c1 e1 0c             	shl    $0xc,%ecx
f01013f9:	39 c1                	cmp    %eax,%ecx
f01013fb:	72 24                	jb     f0101421 <mem_init+0x303>
f01013fd:	c7 44 24 0c 5d 57 10 	movl   $0xf010575d,0xc(%esp)
f0101404:	f0 
f0101405:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010140c:	f0 
f010140d:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0101414:	00 
f0101415:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010141c:	e8 95 ec ff ff       	call   f01000b6 <_panic>
f0101421:	89 f1                	mov    %esi,%ecx
f0101423:	29 d1                	sub    %edx,%ecx
f0101425:	c1 f9 03             	sar    $0x3,%ecx
f0101428:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010142b:	39 c8                	cmp    %ecx,%eax
f010142d:	77 24                	ja     f0101453 <mem_init+0x335>
f010142f:	c7 44 24 0c 7a 57 10 	movl   $0xf010577a,0xc(%esp)
f0101436:	f0 
f0101437:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010143e:	f0 
f010143f:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0101446:	00 
f0101447:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010144e:	e8 63 ec ff ff       	call   f01000b6 <_panic>
f0101453:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101456:	29 d1                	sub    %edx,%ecx
f0101458:	89 ca                	mov    %ecx,%edx
f010145a:	c1 fa 03             	sar    $0x3,%edx
f010145d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101460:	39 d0                	cmp    %edx,%eax
f0101462:	77 24                	ja     f0101488 <mem_init+0x36a>
f0101464:	c7 44 24 0c 97 57 10 	movl   $0xf0105797,0xc(%esp)
f010146b:	f0 
f010146c:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101473:	f0 
f0101474:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f010147b:	00 
f010147c:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101483:	e8 2e ec ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101488:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f010148d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101490:	c7 05 bc d0 17 f0 00 	movl   $0x0,0xf017d0bc
f0101497:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010149a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a1:	e8 33 f9 ff ff       	call   f0100dd9 <page_alloc>
f01014a6:	85 c0                	test   %eax,%eax
f01014a8:	74 24                	je     f01014ce <mem_init+0x3b0>
f01014aa:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01014b9:	f0 
f01014ba:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f01014c1:	00 
f01014c2:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01014c9:	e8 e8 eb ff ff       	call   f01000b6 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014ce:	89 3c 24             	mov    %edi,(%esp)
f01014d1:	e8 8e f9 ff ff       	call   f0100e64 <page_free>
	page_free(pp1);
f01014d6:	89 34 24             	mov    %esi,(%esp)
f01014d9:	e8 86 f9 ff ff       	call   f0100e64 <page_free>
	page_free(pp2);
f01014de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e1:	89 04 24             	mov    %eax,(%esp)
f01014e4:	e8 7b f9 ff ff       	call   f0100e64 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f0:	e8 e4 f8 ff ff       	call   f0100dd9 <page_alloc>
f01014f5:	89 c6                	mov    %eax,%esi
f01014f7:	85 c0                	test   %eax,%eax
f01014f9:	75 24                	jne    f010151f <mem_init+0x401>
f01014fb:	c7 44 24 0c 09 57 10 	movl   $0xf0105709,0xc(%esp)
f0101502:	f0 
f0101503:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010150a:	f0 
f010150b:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f0101512:	00 
f0101513:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010151a:	e8 97 eb ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101526:	e8 ae f8 ff ff       	call   f0100dd9 <page_alloc>
f010152b:	89 c7                	mov    %eax,%edi
f010152d:	85 c0                	test   %eax,%eax
f010152f:	75 24                	jne    f0101555 <mem_init+0x437>
f0101531:	c7 44 24 0c 1f 57 10 	movl   $0xf010571f,0xc(%esp)
f0101538:	f0 
f0101539:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101540:	f0 
f0101541:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f0101548:	00 
f0101549:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101550:	e8 61 eb ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155c:	e8 78 f8 ff ff       	call   f0100dd9 <page_alloc>
f0101561:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101564:	85 c0                	test   %eax,%eax
f0101566:	75 24                	jne    f010158c <mem_init+0x46e>
f0101568:	c7 44 24 0c 35 57 10 	movl   $0xf0105735,0xc(%esp)
f010156f:	f0 
f0101570:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101577:	f0 
f0101578:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f010157f:	00 
f0101580:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101587:	e8 2a eb ff ff       	call   f01000b6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010158c:	39 fe                	cmp    %edi,%esi
f010158e:	75 24                	jne    f01015b4 <mem_init+0x496>
f0101590:	c7 44 24 0c 4b 57 10 	movl   $0xf010574b,0xc(%esp)
f0101597:	f0 
f0101598:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010159f:	f0 
f01015a0:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f01015a7:	00 
f01015a8:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01015af:	e8 02 eb ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015b7:	39 c7                	cmp    %eax,%edi
f01015b9:	74 04                	je     f01015bf <mem_init+0x4a1>
f01015bb:	39 c6                	cmp    %eax,%esi
f01015bd:	75 24                	jne    f01015e3 <mem_init+0x4c5>
f01015bf:	c7 44 24 0c 04 50 10 	movl   $0xf0105004,0xc(%esp)
f01015c6:	f0 
f01015c7:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01015ce:	f0 
f01015cf:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01015d6:	00 
f01015d7:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01015de:	e8 d3 ea ff ff       	call   f01000b6 <_panic>
	assert(!page_alloc(0));
f01015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ea:	e8 ea f7 ff ff       	call   f0100dd9 <page_alloc>
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	74 24                	je     f0101617 <mem_init+0x4f9>
f01015f3:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101602:	f0 
f0101603:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f010160a:	00 
f010160b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101612:	e8 9f ea ff ff       	call   f01000b6 <_panic>
f0101617:	89 f0                	mov    %esi,%eax
f0101619:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f010161f:	c1 f8 03             	sar    $0x3,%eax
f0101622:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101625:	89 c2                	mov    %eax,%edx
f0101627:	c1 ea 0c             	shr    $0xc,%edx
f010162a:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f0101630:	72 20                	jb     f0101652 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101632:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101636:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f010163d:	f0 
f010163e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101645:	00 
f0101646:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f010164d:	e8 64 ea ff ff       	call   f01000b6 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101652:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101659:	00 
f010165a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101661:	00 
	return (void *)(pa + KERNBASE);
f0101662:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101667:	89 04 24             	mov    %eax,(%esp)
f010166a:	e8 e8 2e 00 00       	call   f0104557 <memset>
	page_free(pp0);
f010166f:	89 34 24             	mov    %esi,(%esp)
f0101672:	e8 ed f7 ff ff       	call   f0100e64 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010167e:	e8 56 f7 ff ff       	call   f0100dd9 <page_alloc>
f0101683:	85 c0                	test   %eax,%eax
f0101685:	75 24                	jne    f01016ab <mem_init+0x58d>
f0101687:	c7 44 24 0c c3 57 10 	movl   $0xf01057c3,0xc(%esp)
f010168e:	f0 
f010168f:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101696:	f0 
f0101697:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f010169e:	00 
f010169f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01016a6:	e8 0b ea ff ff       	call   f01000b6 <_panic>
	assert(pp && pp0 == pp);
f01016ab:	39 c6                	cmp    %eax,%esi
f01016ad:	74 24                	je     f01016d3 <mem_init+0x5b5>
f01016af:	c7 44 24 0c e1 57 10 	movl   $0xf01057e1,0xc(%esp)
f01016b6:	f0 
f01016b7:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01016be:	f0 
f01016bf:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f01016c6:	00 
f01016c7:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01016ce:	e8 e3 e9 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016d3:	89 f0                	mov    %esi,%eax
f01016d5:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f01016db:	c1 f8 03             	sar    $0x3,%eax
f01016de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016e1:	89 c2                	mov    %eax,%edx
f01016e3:	c1 ea 0c             	shr    $0xc,%edx
f01016e6:	3b 15 84 dd 17 f0    	cmp    0xf017dd84,%edx
f01016ec:	72 20                	jb     f010170e <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016f2:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101701:	00 
f0101702:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0101709:	e8 a8 e9 ff ff       	call   f01000b6 <_panic>
f010170e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101714:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010171a:	80 38 00             	cmpb   $0x0,(%eax)
f010171d:	74 24                	je     f0101743 <mem_init+0x625>
f010171f:	c7 44 24 0c f1 57 10 	movl   $0xf01057f1,0xc(%esp)
f0101726:	f0 
f0101727:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010172e:	f0 
f010172f:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0101736:	00 
f0101737:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010173e:	e8 73 e9 ff ff       	call   f01000b6 <_panic>
f0101743:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101746:	39 d0                	cmp    %edx,%eax
f0101748:	75 d0                	jne    f010171a <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010174a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010174d:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc

	// free the pages we took
	page_free(pp0);
f0101752:	89 34 24             	mov    %esi,(%esp)
f0101755:	e8 0a f7 ff ff       	call   f0100e64 <page_free>
	page_free(pp1);
f010175a:	89 3c 24             	mov    %edi,(%esp)
f010175d:	e8 02 f7 ff ff       	call   f0100e64 <page_free>
	page_free(pp2);
f0101762:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101765:	89 04 24             	mov    %eax,(%esp)
f0101768:	e8 f7 f6 ff ff       	call   f0100e64 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010176d:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f0101772:	eb 05                	jmp    f0101779 <mem_init+0x65b>
		--nfree;
f0101774:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101777:	8b 00                	mov    (%eax),%eax
f0101779:	85 c0                	test   %eax,%eax
f010177b:	75 f7                	jne    f0101774 <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f010177d:	85 db                	test   %ebx,%ebx
f010177f:	74 24                	je     f01017a5 <mem_init+0x687>
f0101781:	c7 44 24 0c fb 57 10 	movl   $0xf01057fb,0xc(%esp)
f0101788:	f0 
f0101789:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101790:	f0 
f0101791:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0101798:	00 
f0101799:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01017a0:	e8 11 e9 ff ff       	call   f01000b6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017a5:	c7 04 24 24 50 10 f0 	movl   $0xf0105024,(%esp)
f01017ac:	e8 28 1e 00 00       	call   f01035d9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017b8:	e8 1c f6 ff ff       	call   f0100dd9 <page_alloc>
f01017bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c0:	85 c0                	test   %eax,%eax
f01017c2:	75 24                	jne    f01017e8 <mem_init+0x6ca>
f01017c4:	c7 44 24 0c 09 57 10 	movl   $0xf0105709,0xc(%esp)
f01017cb:	f0 
f01017cc:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01017e3:	e8 ce e8 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ef:	e8 e5 f5 ff ff       	call   f0100dd9 <page_alloc>
f01017f4:	89 c3                	mov    %eax,%ebx
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	75 24                	jne    f010181e <mem_init+0x700>
f01017fa:	c7 44 24 0c 1f 57 10 	movl   $0xf010571f,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101819:	e8 98 e8 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f010181e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101825:	e8 af f5 ff ff       	call   f0100dd9 <page_alloc>
f010182a:	89 c6                	mov    %eax,%esi
f010182c:	85 c0                	test   %eax,%eax
f010182e:	75 24                	jne    f0101854 <mem_init+0x736>
f0101830:	c7 44 24 0c 35 57 10 	movl   $0xf0105735,0xc(%esp)
f0101837:	f0 
f0101838:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010183f:	f0 
f0101840:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101847:	00 
f0101848:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010184f:	e8 62 e8 ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101854:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101857:	75 24                	jne    f010187d <mem_init+0x75f>
f0101859:	c7 44 24 0c 4b 57 10 	movl   $0xf010574b,0xc(%esp)
f0101860:	f0 
f0101861:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101868:	f0 
f0101869:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101870:	00 
f0101871:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101878:	e8 39 e8 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010187d:	39 c3                	cmp    %eax,%ebx
f010187f:	74 05                	je     f0101886 <mem_init+0x768>
f0101881:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101884:	75 24                	jne    f01018aa <mem_init+0x78c>
f0101886:	c7 44 24 0c 04 50 10 	movl   $0xf0105004,0xc(%esp)
f010188d:	f0 
f010188e:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01018a5:	e8 0c e8 ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018aa:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f01018af:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018b2:	c7 05 bc d0 17 f0 00 	movl   $0x0,0xf017d0bc
f01018b9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018c3:	e8 11 f5 ff ff       	call   f0100dd9 <page_alloc>
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	74 24                	je     f01018f0 <mem_init+0x7d2>
f01018cc:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f01018d3:	f0 
f01018d4:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01018db:	f0 
f01018dc:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f01018e3:	00 
f01018e4:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01018eb:	e8 c6 e7 ff ff       	call   f01000b6 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018fe:	00 
f01018ff:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101904:	89 04 24             	mov    %eax,(%esp)
f0101907:	e8 bc f6 ff ff       	call   f0100fc8 <page_lookup>
f010190c:	85 c0                	test   %eax,%eax
f010190e:	74 24                	je     f0101934 <mem_init+0x816>
f0101910:	c7 44 24 0c 44 50 10 	movl   $0xf0105044,0xc(%esp)
f0101917:	f0 
f0101918:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010191f:	f0 
f0101920:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101927:	00 
f0101928:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010192f:	e8 82 e7 ff ff       	call   f01000b6 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101934:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010193b:	00 
f010193c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101943:	00 
f0101944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101948:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f010194d:	89 04 24             	mov    %eax,(%esp)
f0101950:	e8 36 f7 ff ff       	call   f010108b <page_insert>
f0101955:	85 c0                	test   %eax,%eax
f0101957:	78 24                	js     f010197d <mem_init+0x85f>
f0101959:	c7 44 24 0c 7c 50 10 	movl   $0xf010507c,0xc(%esp)
f0101960:	f0 
f0101961:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101968:	f0 
f0101969:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101970:	00 
f0101971:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101978:	e8 39 e7 ff ff       	call   f01000b6 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010197d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101980:	89 04 24             	mov    %eax,(%esp)
f0101983:	e8 dc f4 ff ff       	call   f0100e64 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101988:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010198f:	00 
f0101990:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101997:	00 
f0101998:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010199c:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01019a1:	89 04 24             	mov    %eax,(%esp)
f01019a4:	e8 e2 f6 ff ff       	call   f010108b <page_insert>
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	74 24                	je     f01019d1 <mem_init+0x8b3>
f01019ad:	c7 44 24 0c ac 50 10 	movl   $0xf01050ac,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01019cc:	e8 e5 e6 ff ff       	call   f01000b6 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019d1:	8b 3d 88 dd 17 f0    	mov    0xf017dd88,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019d7:	a1 8c dd 17 f0       	mov    0xf017dd8c,%eax
f01019dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019df:	8b 17                	mov    (%edi),%edx
f01019e1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019e7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01019ea:	29 c1                	sub    %eax,%ecx
f01019ec:	89 c8                	mov    %ecx,%eax
f01019ee:	c1 f8 03             	sar    $0x3,%eax
f01019f1:	c1 e0 0c             	shl    $0xc,%eax
f01019f4:	39 c2                	cmp    %eax,%edx
f01019f6:	74 24                	je     f0101a1c <mem_init+0x8fe>
f01019f8:	c7 44 24 0c dc 50 10 	movl   $0xf01050dc,0xc(%esp)
f01019ff:	f0 
f0101a00:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101a07:	f0 
f0101a08:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101a0f:	00 
f0101a10:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101a17:	e8 9a e6 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a1c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a21:	89 f8                	mov    %edi,%eax
f0101a23:	e8 10 ef ff ff       	call   f0100938 <check_va2pa>
f0101a28:	89 da                	mov    %ebx,%edx
f0101a2a:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a2d:	c1 fa 03             	sar    $0x3,%edx
f0101a30:	c1 e2 0c             	shl    $0xc,%edx
f0101a33:	39 d0                	cmp    %edx,%eax
f0101a35:	74 24                	je     f0101a5b <mem_init+0x93d>
f0101a37:	c7 44 24 0c 04 51 10 	movl   $0xf0105104,0xc(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101a4e:	00 
f0101a4f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101a56:	e8 5b e6 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0101a5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a60:	74 24                	je     f0101a86 <mem_init+0x968>
f0101a62:	c7 44 24 0c 06 58 10 	movl   $0xf0105806,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101a81:	e8 30 e6 ff ff       	call   f01000b6 <_panic>
	assert(pp0->pp_ref == 1);
f0101a86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a89:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a8e:	74 24                	je     f0101ab4 <mem_init+0x996>
f0101a90:	c7 44 24 0c 17 58 10 	movl   $0xf0105817,0xc(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101aaf:	e8 02 e6 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101abb:	00 
f0101abc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ac3:	00 
f0101ac4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ac8:	89 3c 24             	mov    %edi,(%esp)
f0101acb:	e8 bb f5 ff ff       	call   f010108b <page_insert>
f0101ad0:	85 c0                	test   %eax,%eax
f0101ad2:	74 24                	je     f0101af8 <mem_init+0x9da>
f0101ad4:	c7 44 24 0c 34 51 10 	movl   $0xf0105134,0xc(%esp)
f0101adb:	f0 
f0101adc:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101ae3:	f0 
f0101ae4:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101aeb:	00 
f0101aec:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101af3:	e8 be e5 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101af8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101afd:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101b02:	e8 31 ee ff ff       	call   f0100938 <check_va2pa>
f0101b07:	89 f2                	mov    %esi,%edx
f0101b09:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0101b0f:	c1 fa 03             	sar    $0x3,%edx
f0101b12:	c1 e2 0c             	shl    $0xc,%edx
f0101b15:	39 d0                	cmp    %edx,%eax
f0101b17:	74 24                	je     f0101b3d <mem_init+0xa1f>
f0101b19:	c7 44 24 0c 70 51 10 	movl   $0xf0105170,0xc(%esp)
f0101b20:	f0 
f0101b21:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101b38:	e8 79 e5 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101b3d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b42:	74 24                	je     f0101b68 <mem_init+0xa4a>
f0101b44:	c7 44 24 0c 28 58 10 	movl   $0xf0105828,0xc(%esp)
f0101b4b:	f0 
f0101b4c:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101b53:	f0 
f0101b54:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101b5b:	00 
f0101b5c:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101b63:	e8 4e e5 ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6f:	e8 65 f2 ff ff       	call   f0100dd9 <page_alloc>
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	74 24                	je     f0101b9c <mem_init+0xa7e>
f0101b78:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f0101b7f:	f0 
f0101b80:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101b8f:	00 
f0101b90:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101b97:	e8 1a e5 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b9c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ba3:	00 
f0101ba4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bab:	00 
f0101bac:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bb0:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101bb5:	89 04 24             	mov    %eax,(%esp)
f0101bb8:	e8 ce f4 ff ff       	call   f010108b <page_insert>
f0101bbd:	85 c0                	test   %eax,%eax
f0101bbf:	74 24                	je     f0101be5 <mem_init+0xac7>
f0101bc1:	c7 44 24 0c 34 51 10 	movl   $0xf0105134,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101be0:	e8 d1 e4 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101be5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bea:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101bef:	e8 44 ed ff ff       	call   f0100938 <check_va2pa>
f0101bf4:	89 f2                	mov    %esi,%edx
f0101bf6:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0101bfc:	c1 fa 03             	sar    $0x3,%edx
f0101bff:	c1 e2 0c             	shl    $0xc,%edx
f0101c02:	39 d0                	cmp    %edx,%eax
f0101c04:	74 24                	je     f0101c2a <mem_init+0xb0c>
f0101c06:	c7 44 24 0c 70 51 10 	movl   $0xf0105170,0xc(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101c15:	f0 
f0101c16:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101c1d:	00 
f0101c1e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101c25:	e8 8c e4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101c2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c2f:	74 24                	je     f0101c55 <mem_init+0xb37>
f0101c31:	c7 44 24 0c 28 58 10 	movl   $0xf0105828,0xc(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101c40:	f0 
f0101c41:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101c48:	00 
f0101c49:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101c50:	e8 61 e4 ff ff       	call   f01000b6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5c:	e8 78 f1 ff ff       	call   f0100dd9 <page_alloc>
f0101c61:	85 c0                	test   %eax,%eax
f0101c63:	74 24                	je     f0101c89 <mem_init+0xb6b>
f0101c65:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f0101c6c:	f0 
f0101c6d:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101c74:	f0 
f0101c75:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101c7c:	00 
f0101c7d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101c84:	e8 2d e4 ff ff       	call   f01000b6 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c89:	8b 15 88 dd 17 f0    	mov    0xf017dd88,%edx
f0101c8f:	8b 02                	mov    (%edx),%eax
f0101c91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c96:	89 c1                	mov    %eax,%ecx
f0101c98:	c1 e9 0c             	shr    $0xc,%ecx
f0101c9b:	3b 0d 84 dd 17 f0    	cmp    0xf017dd84,%ecx
f0101ca1:	72 20                	jb     f0101cc3 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ca7:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101cb6:	00 
f0101cb7:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101cbe:	e8 f3 e3 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0101cc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ccb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cd2:	00 
f0101cd3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101cda:	00 
f0101cdb:	89 14 24             	mov    %edx,(%esp)
f0101cde:	e8 e4 f1 ff ff       	call   f0100ec7 <pgdir_walk>
f0101ce3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ce6:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ce9:	39 d0                	cmp    %edx,%eax
f0101ceb:	74 24                	je     f0101d11 <mem_init+0xbf3>
f0101ced:	c7 44 24 0c a0 51 10 	movl   $0xf01051a0,0xc(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101cfc:	f0 
f0101cfd:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101d04:	00 
f0101d05:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101d0c:	e8 a5 e3 ff ff       	call   f01000b6 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d18:	00 
f0101d19:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d20:	00 
f0101d21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d25:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101d2a:	89 04 24             	mov    %eax,(%esp)
f0101d2d:	e8 59 f3 ff ff       	call   f010108b <page_insert>
f0101d32:	85 c0                	test   %eax,%eax
f0101d34:	74 24                	je     f0101d5a <mem_init+0xc3c>
f0101d36:	c7 44 24 0c e0 51 10 	movl   $0xf01051e0,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101d55:	e8 5c e3 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d5a:	8b 3d 88 dd 17 f0    	mov    0xf017dd88,%edi
f0101d60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d65:	89 f8                	mov    %edi,%eax
f0101d67:	e8 cc eb ff ff       	call   f0100938 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d6c:	89 f2                	mov    %esi,%edx
f0101d6e:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0101d74:	c1 fa 03             	sar    $0x3,%edx
f0101d77:	c1 e2 0c             	shl    $0xc,%edx
f0101d7a:	39 d0                	cmp    %edx,%eax
f0101d7c:	74 24                	je     f0101da2 <mem_init+0xc84>
f0101d7e:	c7 44 24 0c 70 51 10 	movl   $0xf0105170,0xc(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101d95:	00 
f0101d96:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101d9d:	e8 14 e3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101da2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101da7:	74 24                	je     f0101dcd <mem_init+0xcaf>
f0101da9:	c7 44 24 0c 28 58 10 	movl   $0xf0105828,0xc(%esp)
f0101db0:	f0 
f0101db1:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101dc0:	00 
f0101dc1:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101dc8:	e8 e9 e2 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dd4:	00 
f0101dd5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ddc:	00 
f0101ddd:	89 3c 24             	mov    %edi,(%esp)
f0101de0:	e8 e2 f0 ff ff       	call   f0100ec7 <pgdir_walk>
f0101de5:	f6 00 04             	testb  $0x4,(%eax)
f0101de8:	75 24                	jne    f0101e0e <mem_init+0xcf0>
f0101dea:	c7 44 24 0c 20 52 10 	movl   $0xf0105220,0xc(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101e01:	00 
f0101e02:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101e09:	e8 a8 e2 ff ff       	call   f01000b6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e0e:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101e13:	f6 00 04             	testb  $0x4,(%eax)
f0101e16:	75 24                	jne    f0101e3c <mem_init+0xd1e>
f0101e18:	c7 44 24 0c 39 58 10 	movl   $0xf0105839,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101e37:	e8 7a e2 ff ff       	call   f01000b6 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e3c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e43:	00 
f0101e44:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e4b:	00 
f0101e4c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e50:	89 04 24             	mov    %eax,(%esp)
f0101e53:	e8 33 f2 ff ff       	call   f010108b <page_insert>
f0101e58:	85 c0                	test   %eax,%eax
f0101e5a:	74 24                	je     f0101e80 <mem_init+0xd62>
f0101e5c:	c7 44 24 0c 34 51 10 	movl   $0xf0105134,0xc(%esp)
f0101e63:	f0 
f0101e64:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101e73:	00 
f0101e74:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101e7b:	e8 36 e2 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e87:	00 
f0101e88:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e8f:	00 
f0101e90:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101e95:	89 04 24             	mov    %eax,(%esp)
f0101e98:	e8 2a f0 ff ff       	call   f0100ec7 <pgdir_walk>
f0101e9d:	f6 00 02             	testb  $0x2,(%eax)
f0101ea0:	75 24                	jne    f0101ec6 <mem_init+0xda8>
f0101ea2:	c7 44 24 0c 54 52 10 	movl   $0xf0105254,0xc(%esp)
f0101ea9:	f0 
f0101eaa:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101eb9:	00 
f0101eba:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101ec1:	e8 f0 e1 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ec6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ecd:	00 
f0101ece:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ed5:	00 
f0101ed6:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101edb:	89 04 24             	mov    %eax,(%esp)
f0101ede:	e8 e4 ef ff ff       	call   f0100ec7 <pgdir_walk>
f0101ee3:	f6 00 04             	testb  $0x4,(%eax)
f0101ee6:	74 24                	je     f0101f0c <mem_init+0xdee>
f0101ee8:	c7 44 24 0c 88 52 10 	movl   $0xf0105288,0xc(%esp)
f0101eef:	f0 
f0101ef0:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101ef7:	f0 
f0101ef8:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101eff:	00 
f0101f00:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101f07:	e8 aa e1 ff ff       	call   f01000b6 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f0c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f13:	00 
f0101f14:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f1b:	00 
f0101f1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f23:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101f28:	89 04 24             	mov    %eax,(%esp)
f0101f2b:	e8 5b f1 ff ff       	call   f010108b <page_insert>
f0101f30:	85 c0                	test   %eax,%eax
f0101f32:	78 24                	js     f0101f58 <mem_init+0xe3a>
f0101f34:	c7 44 24 0c c0 52 10 	movl   $0xf01052c0,0xc(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101f43:	f0 
f0101f44:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101f4b:	00 
f0101f4c:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101f53:	e8 5e e1 ff ff       	call   f01000b6 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f58:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f5f:	00 
f0101f60:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f67:	00 
f0101f68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f6c:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101f71:	89 04 24             	mov    %eax,(%esp)
f0101f74:	e8 12 f1 ff ff       	call   f010108b <page_insert>
f0101f79:	85 c0                	test   %eax,%eax
f0101f7b:	74 24                	je     f0101fa1 <mem_init+0xe83>
f0101f7d:	c7 44 24 0c f8 52 10 	movl   $0xf01052f8,0xc(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101f8c:	f0 
f0101f8d:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101f94:	00 
f0101f95:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101f9c:	e8 15 e1 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fa1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa8:	00 
f0101fa9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fb0:	00 
f0101fb1:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101fb6:	89 04 24             	mov    %eax,(%esp)
f0101fb9:	e8 09 ef ff ff       	call   f0100ec7 <pgdir_walk>
f0101fbe:	f6 00 04             	testb  $0x4,(%eax)
f0101fc1:	74 24                	je     f0101fe7 <mem_init+0xec9>
f0101fc3:	c7 44 24 0c 88 52 10 	movl   $0xf0105288,0xc(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101fda:	00 
f0101fdb:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0101fe2:	e8 cf e0 ff ff       	call   f01000b6 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fe7:	8b 3d 88 dd 17 f0    	mov    0xf017dd88,%edi
f0101fed:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff2:	89 f8                	mov    %edi,%eax
f0101ff4:	e8 3f e9 ff ff       	call   f0100938 <check_va2pa>
f0101ff9:	89 c1                	mov    %eax,%ecx
f0101ffb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ffe:	89 d8                	mov    %ebx,%eax
f0102000:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f0102006:	c1 f8 03             	sar    $0x3,%eax
f0102009:	c1 e0 0c             	shl    $0xc,%eax
f010200c:	39 c1                	cmp    %eax,%ecx
f010200e:	74 24                	je     f0102034 <mem_init+0xf16>
f0102010:	c7 44 24 0c 34 53 10 	movl   $0xf0105334,0xc(%esp)
f0102017:	f0 
f0102018:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010202f:	e8 82 e0 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102034:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102039:	89 f8                	mov    %edi,%eax
f010203b:	e8 f8 e8 ff ff       	call   f0100938 <check_va2pa>
f0102040:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102043:	74 24                	je     f0102069 <mem_init+0xf4b>
f0102045:	c7 44 24 0c 60 53 10 	movl   $0xf0105360,0xc(%esp)
f010204c:	f0 
f010204d:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102054:	f0 
f0102055:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010205c:	00 
f010205d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102064:	e8 4d e0 ff ff       	call   f01000b6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102069:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010206e:	74 24                	je     f0102094 <mem_init+0xf76>
f0102070:	c7 44 24 0c 4f 58 10 	movl   $0xf010584f,0xc(%esp)
f0102077:	f0 
f0102078:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010207f:	f0 
f0102080:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102087:	00 
f0102088:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010208f:	e8 22 e0 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102094:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102099:	74 24                	je     f01020bf <mem_init+0xfa1>
f010209b:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01020ba:	e8 f7 df ff ff       	call   f01000b6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020c6:	e8 0e ed ff ff       	call   f0100dd9 <page_alloc>
f01020cb:	85 c0                	test   %eax,%eax
f01020cd:	74 04                	je     f01020d3 <mem_init+0xfb5>
f01020cf:	39 c6                	cmp    %eax,%esi
f01020d1:	74 24                	je     f01020f7 <mem_init+0xfd9>
f01020d3:	c7 44 24 0c 90 53 10 	movl   $0xf0105390,0xc(%esp)
f01020da:	f0 
f01020db:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01020ea:	00 
f01020eb:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01020f2:	e8 bf df ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020fe:	00 
f01020ff:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102104:	89 04 24             	mov    %eax,(%esp)
f0102107:	e8 31 ef ff ff       	call   f010103d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010210c:	8b 3d 88 dd 17 f0    	mov    0xf017dd88,%edi
f0102112:	ba 00 00 00 00       	mov    $0x0,%edx
f0102117:	89 f8                	mov    %edi,%eax
f0102119:	e8 1a e8 ff ff       	call   f0100938 <check_va2pa>
f010211e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102121:	74 24                	je     f0102147 <mem_init+0x1029>
f0102123:	c7 44 24 0c b4 53 10 	movl   $0xf01053b4,0xc(%esp)
f010212a:	f0 
f010212b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102132:	f0 
f0102133:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f010213a:	00 
f010213b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102142:	e8 6f df ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102147:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214c:	89 f8                	mov    %edi,%eax
f010214e:	e8 e5 e7 ff ff       	call   f0100938 <check_va2pa>
f0102153:	89 da                	mov    %ebx,%edx
f0102155:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f010215b:	c1 fa 03             	sar    $0x3,%edx
f010215e:	c1 e2 0c             	shl    $0xc,%edx
f0102161:	39 d0                	cmp    %edx,%eax
f0102163:	74 24                	je     f0102189 <mem_init+0x106b>
f0102165:	c7 44 24 0c 60 53 10 	movl   $0xf0105360,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102184:	e8 2d df ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0102189:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010218e:	74 24                	je     f01021b4 <mem_init+0x1096>
f0102190:	c7 44 24 0c 06 58 10 	movl   $0xf0105806,0xc(%esp)
f0102197:	f0 
f0102198:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01021a7:	00 
f01021a8:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01021af:	e8 02 df ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f01021b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021b9:	74 24                	je     f01021df <mem_init+0x10c1>
f01021bb:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f01021c2:	f0 
f01021c3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01021ca:	f0 
f01021cb:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f01021d2:	00 
f01021d3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01021da:	e8 d7 de ff ff       	call   f01000b6 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021e6:	00 
f01021e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021ee:	00 
f01021ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021f3:	89 3c 24             	mov    %edi,(%esp)
f01021f6:	e8 90 ee ff ff       	call   f010108b <page_insert>
f01021fb:	85 c0                	test   %eax,%eax
f01021fd:	74 24                	je     f0102223 <mem_init+0x1105>
f01021ff:	c7 44 24 0c d8 53 10 	movl   $0xf01053d8,0xc(%esp)
f0102206:	f0 
f0102207:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010220e:	f0 
f010220f:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102216:	00 
f0102217:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010221e:	e8 93 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref);
f0102223:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102228:	75 24                	jne    f010224e <mem_init+0x1130>
f010222a:	c7 44 24 0c 71 58 10 	movl   $0xf0105871,0xc(%esp)
f0102231:	f0 
f0102232:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102239:	f0 
f010223a:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0102241:	00 
f0102242:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102249:	e8 68 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_link == NULL);
f010224e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102251:	74 24                	je     f0102277 <mem_init+0x1159>
f0102253:	c7 44 24 0c 7d 58 10 	movl   $0xf010587d,0xc(%esp)
f010225a:	f0 
f010225b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102262:	f0 
f0102263:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f010226a:	00 
f010226b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102272:	e8 3f de ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102277:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010227e:	00 
f010227f:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102284:	89 04 24             	mov    %eax,(%esp)
f0102287:	e8 b1 ed ff ff       	call   f010103d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010228c:	8b 3d 88 dd 17 f0    	mov    0xf017dd88,%edi
f0102292:	ba 00 00 00 00       	mov    $0x0,%edx
f0102297:	89 f8                	mov    %edi,%eax
f0102299:	e8 9a e6 ff ff       	call   f0100938 <check_va2pa>
f010229e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a1:	74 24                	je     f01022c7 <mem_init+0x11a9>
f01022a3:	c7 44 24 0c b4 53 10 	movl   $0xf01053b4,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01022c2:	e8 ef dd ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022c7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022cc:	89 f8                	mov    %edi,%eax
f01022ce:	e8 65 e6 ff ff       	call   f0100938 <check_va2pa>
f01022d3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022d6:	74 24                	je     f01022fc <mem_init+0x11de>
f01022d8:	c7 44 24 0c 10 54 10 	movl   $0xf0105410,0xc(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01022ef:	00 
f01022f0:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01022f7:	e8 ba dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f01022fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102301:	74 24                	je     f0102327 <mem_init+0x1209>
f0102303:	c7 44 24 0c 92 58 10 	movl   $0xf0105892,0xc(%esp)
f010230a:	f0 
f010230b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102322:	e8 8f dd ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102327:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010232c:	74 24                	je     f0102352 <mem_init+0x1234>
f010232e:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0102335:	f0 
f0102336:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f010233d:	f0 
f010233e:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102345:	00 
f0102346:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010234d:	e8 64 dd ff ff       	call   f01000b6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102352:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102359:	e8 7b ea ff ff       	call   f0100dd9 <page_alloc>
f010235e:	85 c0                	test   %eax,%eax
f0102360:	74 04                	je     f0102366 <mem_init+0x1248>
f0102362:	39 c3                	cmp    %eax,%ebx
f0102364:	74 24                	je     f010238a <mem_init+0x126c>
f0102366:	c7 44 24 0c 38 54 10 	movl   $0xf0105438,0xc(%esp)
f010236d:	f0 
f010236e:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102375:	f0 
f0102376:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f010237d:	00 
f010237e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102385:	e8 2c dd ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010238a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102391:	e8 43 ea ff ff       	call   f0100dd9 <page_alloc>
f0102396:	85 c0                	test   %eax,%eax
f0102398:	74 24                	je     f01023be <mem_init+0x12a0>
f010239a:	c7 44 24 0c b4 57 10 	movl   $0xf01057b4,0xc(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01023b9:	e8 f8 dc ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023be:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01023c3:	8b 08                	mov    (%eax),%ecx
f01023c5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023ce:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f01023d4:	c1 fa 03             	sar    $0x3,%edx
f01023d7:	c1 e2 0c             	shl    $0xc,%edx
f01023da:	39 d1                	cmp    %edx,%ecx
f01023dc:	74 24                	je     f0102402 <mem_init+0x12e4>
f01023de:	c7 44 24 0c dc 50 10 	movl   $0xf01050dc,0xc(%esp)
f01023e5:	f0 
f01023e6:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01023ed:	f0 
f01023ee:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01023f5:	00 
f01023f6:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01023fd:	e8 b4 dc ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010240b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102410:	74 24                	je     f0102436 <mem_init+0x1318>
f0102412:	c7 44 24 0c 17 58 10 	movl   $0xf0105817,0xc(%esp)
f0102419:	f0 
f010241a:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102421:	f0 
f0102422:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0102429:	00 
f010242a:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102431:	e8 80 dc ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102436:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102439:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010243f:	89 04 24             	mov    %eax,(%esp)
f0102442:	e8 1d ea ff ff       	call   f0100e64 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102447:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010244e:	00 
f010244f:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102456:	00 
f0102457:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f010245c:	89 04 24             	mov    %eax,(%esp)
f010245f:	e8 63 ea ff ff       	call   f0100ec7 <pgdir_walk>
f0102464:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102467:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010246a:	8b 15 88 dd 17 f0    	mov    0xf017dd88,%edx
f0102470:	8b 7a 04             	mov    0x4(%edx),%edi
f0102473:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102479:	8b 0d 84 dd 17 f0    	mov    0xf017dd84,%ecx
f010247f:	89 f8                	mov    %edi,%eax
f0102481:	c1 e8 0c             	shr    $0xc,%eax
f0102484:	39 c8                	cmp    %ecx,%eax
f0102486:	72 20                	jb     f01024a8 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102488:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010248c:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0102493:	f0 
f0102494:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f010249b:	00 
f010249c:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01024a3:	e8 0e dc ff ff       	call   f01000b6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024a8:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01024ae:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01024b1:	74 24                	je     f01024d7 <mem_init+0x13b9>
f01024b3:	c7 44 24 0c a3 58 10 	movl   $0xf01058a3,0xc(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01024ca:	00 
f01024cb:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01024d2:	e8 df db ff ff       	call   f01000b6 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024d7:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f01024de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024e1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024e7:	2b 05 8c dd 17 f0    	sub    0xf017dd8c,%eax
f01024ed:	c1 f8 03             	sar    $0x3,%eax
f01024f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024f3:	89 c2                	mov    %eax,%edx
f01024f5:	c1 ea 0c             	shr    $0xc,%edx
f01024f8:	39 d1                	cmp    %edx,%ecx
f01024fa:	77 20                	ja     f010251c <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102500:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0102507:	f0 
f0102508:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010250f:	00 
f0102510:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0102517:	e8 9a db ff ff       	call   f01000b6 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010251c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102523:	00 
f0102524:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010252b:	00 
	return (void *)(pa + KERNBASE);
f010252c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102531:	89 04 24             	mov    %eax,(%esp)
f0102534:	e8 1e 20 00 00       	call   f0104557 <memset>
	page_free(pp0);
f0102539:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010253c:	89 3c 24             	mov    %edi,(%esp)
f010253f:	e8 20 e9 ff ff       	call   f0100e64 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102544:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010254b:	00 
f010254c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102553:	00 
f0102554:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102559:	89 04 24             	mov    %eax,(%esp)
f010255c:	e8 66 e9 ff ff       	call   f0100ec7 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102561:	89 fa                	mov    %edi,%edx
f0102563:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0102569:	c1 fa 03             	sar    $0x3,%edx
f010256c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010256f:	89 d0                	mov    %edx,%eax
f0102571:	c1 e8 0c             	shr    $0xc,%eax
f0102574:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f010257a:	72 20                	jb     f010259c <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010257c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102580:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0102587:	f0 
f0102588:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010258f:	00 
f0102590:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0102597:	e8 1a db ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f010259c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01025a5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025ab:	f6 00 01             	testb  $0x1,(%eax)
f01025ae:	74 24                	je     f01025d4 <mem_init+0x14b6>
f01025b0:	c7 44 24 0c bb 58 10 	movl   $0xf01058bb,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01025cf:	e8 e2 da ff ff       	call   f01000b6 <_panic>
f01025d4:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025d7:	39 d0                	cmp    %edx,%eax
f01025d9:	75 d0                	jne    f01025ab <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025db:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01025e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025e9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025ef:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01025f2:	89 3d bc d0 17 f0    	mov    %edi,0xf017d0bc

	// free the pages we took
	page_free(pp0);
f01025f8:	89 04 24             	mov    %eax,(%esp)
f01025fb:	e8 64 e8 ff ff       	call   f0100e64 <page_free>
	page_free(pp1);
f0102600:	89 1c 24             	mov    %ebx,(%esp)
f0102603:	e8 5c e8 ff ff       	call   f0100e64 <page_free>
	page_free(pp2);
f0102608:	89 34 24             	mov    %esi,(%esp)
f010260b:	e8 54 e8 ff ff       	call   f0100e64 <page_free>

	cprintf("check_page() succeeded!\n");
f0102610:	c7 04 24 d2 58 10 f0 	movl   $0xf01058d2,(%esp)
f0102617:	e8 bd 0f 00 00       	call   f01035d9 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010261c:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f0102621:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102628:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f010262e:	a1 8c dd 17 f0       	mov    0xf017dd8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102633:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102638:	77 20                	ja     f010265a <mem_init+0x153c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010263e:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0102645:	f0 
f0102646:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f010264d:	00 
f010264e:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102655:	e8 5c da ff ff       	call   f01000b6 <_panic>
f010265a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102661:	00 
	return (physaddr_t)kva - KERNBASE;
f0102662:	05 00 00 00 10       	add    $0x10000000,%eax
f0102667:	89 04 24             	mov    %eax,(%esp)
f010266a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010266f:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102674:	e8 ee e8 ff ff       	call   f0100f67 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102679:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010267e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102683:	77 20                	ja     f01026a5 <mem_init+0x1587>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102685:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102689:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0102690:	f0 
f0102691:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f0102698:	00 
f0102699:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01026a0:	e8 11 da ff ff       	call   f01000b6 <_panic>
f01026a5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01026ac:	00 
	return (physaddr_t)kva - KERNBASE;
f01026ad:	05 00 00 00 10       	add    $0x10000000,%eax
f01026b2:	89 04 24             	mov    %eax,(%esp)
f01026b5:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026ba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026bf:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01026c4:	e8 9e e8 ff ff       	call   f0100f67 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c9:	bb 00 10 11 f0       	mov    $0xf0111000,%ebx
f01026ce:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026d4:	77 20                	ja     f01026f6 <mem_init+0x15d8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01026da:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f01026e1:	f0 
f01026e2:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
f01026e9:	00 
f01026ea:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01026f1:	e8 c0 d9 ff ff       	call   f01000b6 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f01026f6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01026fd:	00 
f01026fe:	c7 04 24 00 10 11 00 	movl   $0x111000,(%esp)
f0102705:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010270a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010270f:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102714:	e8 4e e8 ff ff       	call   f0100f67 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f0102719:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102720:	00 
f0102721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102728:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010272d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102732:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102737:	e8 2b e8 ff ff       	call   f0100f67 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010273c:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102741:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102744:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f0102749:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010274c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102753:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102758:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010275b:	8b 3d 8c dd 17 f0    	mov    0xf017dd8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102761:	89 7d c8             	mov    %edi,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102764:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010276a:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010276d:	be 00 00 00 00       	mov    $0x0,%esi
f0102772:	eb 6b                	jmp    f01027df <mem_init+0x16c1>
f0102774:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010277a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010277d:	e8 b6 e1 ff ff       	call   f0100938 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102782:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f0102789:	77 20                	ja     f01027ab <mem_init+0x168d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010278b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010278f:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0102796:	f0 
f0102797:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f010279e:	00 
f010279f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01027a6:	e8 0b d9 ff ff       	call   f01000b6 <_panic>
f01027ab:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01027ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01027b1:	39 d0                	cmp    %edx,%eax
f01027b3:	74 24                	je     f01027d9 <mem_init+0x16bb>
f01027b5:	c7 44 24 0c 5c 54 10 	movl   $0xf010545c,0xc(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01027c4:	f0 
f01027c5:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f01027cc:	00 
f01027cd:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01027d4:	e8 dd d8 ff ff       	call   f01000b6 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027df:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f01027e2:	77 90                	ja     f0102774 <mem_init+0x1656>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027e4:	8b 35 c8 d0 17 f0    	mov    0xf017d0c8,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ea:	89 f7                	mov    %esi,%edi
f01027ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027f4:	e8 3f e1 ff ff       	call   f0100938 <check_va2pa>
f01027f9:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01027ff:	77 20                	ja     f0102821 <mem_init+0x1703>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102801:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102805:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f010280c:	f0 
f010280d:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0102814:	00 
f0102815:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f010281c:	e8 95 d8 ff ff       	call   f01000b6 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102821:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102826:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f010282c:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010282f:	39 c2                	cmp    %eax,%edx
f0102831:	74 24                	je     f0102857 <mem_init+0x1739>
f0102833:	c7 44 24 0c 90 54 10 	movl   $0xf0105490,0xc(%esp)
f010283a:	f0 
f010283b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102842:	f0 
f0102843:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010284a:	00 
f010284b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102852:	e8 5f d8 ff ff       	call   f01000b6 <_panic>
f0102857:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010285d:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102863:	0f 85 26 05 00 00    	jne    f0102d8f <mem_init+0x1c71>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102869:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010286c:	c1 e7 0c             	shl    $0xc,%edi
f010286f:	be 00 00 00 00       	mov    $0x0,%esi
f0102874:	eb 3c                	jmp    f01028b2 <mem_init+0x1794>
f0102876:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010287c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010287f:	e8 b4 e0 ff ff       	call   f0100938 <check_va2pa>
f0102884:	39 c6                	cmp    %eax,%esi
f0102886:	74 24                	je     f01028ac <mem_init+0x178e>
f0102888:	c7 44 24 0c c4 54 10 	movl   $0xf01054c4,0xc(%esp)
f010288f:	f0 
f0102890:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102897:	f0 
f0102898:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f010289f:	00 
f01028a0:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01028a7:	e8 0a d8 ff ff       	call   f01000b6 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028ac:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028b2:	39 fe                	cmp    %edi,%esi
f01028b4:	72 c0                	jb     f0102876 <mem_init+0x1758>
f01028b6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028bb:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028c1:	89 f2                	mov    %esi,%edx
f01028c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028c6:	e8 6d e0 ff ff       	call   f0100938 <check_va2pa>
f01028cb:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01028ce:	39 d0                	cmp    %edx,%eax
f01028d0:	74 24                	je     f01028f6 <mem_init+0x17d8>
f01028d2:	c7 44 24 0c ec 54 10 	movl   $0xf01054ec,0xc(%esp)
f01028d9:	f0 
f01028da:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f01028e9:	00 
f01028ea:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01028f1:	e8 c0 d7 ff ff       	call   f01000b6 <_panic>
f01028f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028fc:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102902:	75 bd                	jne    f01028c1 <mem_init+0x17a3>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102904:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102909:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010290c:	89 f8                	mov    %edi,%eax
f010290e:	e8 25 e0 ff ff       	call   f0100938 <check_va2pa>
f0102913:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102916:	75 0c                	jne    f0102924 <mem_init+0x1806>
f0102918:	b8 00 00 00 00       	mov    $0x0,%eax
f010291d:	89 fa                	mov    %edi,%edx
f010291f:	e9 f0 00 00 00       	jmp    f0102a14 <mem_init+0x18f6>
f0102924:	c7 44 24 0c 34 55 10 	movl   $0xf0105534,0xc(%esp)
f010292b:	f0 
f010292c:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102933:	f0 
f0102934:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f010293b:	00 
f010293c:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102943:	e8 6e d7 ff ff       	call   f01000b6 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102948:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010294d:	72 3c                	jb     f010298b <mem_init+0x186d>
f010294f:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102954:	76 07                	jbe    f010295d <mem_init+0x183f>
f0102956:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010295b:	75 2e                	jne    f010298b <mem_init+0x186d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010295d:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0102961:	0f 85 aa 00 00 00    	jne    f0102a11 <mem_init+0x18f3>
f0102967:	c7 44 24 0c eb 58 10 	movl   $0xf01058eb,0xc(%esp)
f010296e:	f0 
f010296f:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102976:	f0 
f0102977:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f010297e:	00 
f010297f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102986:	e8 2b d7 ff ff       	call   f01000b6 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010298b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102990:	76 55                	jbe    f01029e7 <mem_init+0x18c9>
				assert(pgdir[i] & PTE_P);
f0102992:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102995:	f6 c1 01             	test   $0x1,%cl
f0102998:	75 24                	jne    f01029be <mem_init+0x18a0>
f010299a:	c7 44 24 0c eb 58 10 	movl   $0xf01058eb,0xc(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01029a9:	f0 
f01029aa:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01029b1:	00 
f01029b2:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01029b9:	e8 f8 d6 ff ff       	call   f01000b6 <_panic>
				assert(pgdir[i] & PTE_W);
f01029be:	f6 c1 02             	test   $0x2,%cl
f01029c1:	75 4e                	jne    f0102a11 <mem_init+0x18f3>
f01029c3:	c7 44 24 0c fc 58 10 	movl   $0xf01058fc,0xc(%esp)
f01029ca:	f0 
f01029cb:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01029d2:	f0 
f01029d3:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01029da:	00 
f01029db:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f01029e2:	e8 cf d6 ff ff       	call   f01000b6 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029e7:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f01029eb:	74 24                	je     f0102a11 <mem_init+0x18f3>
f01029ed:	c7 44 24 0c 0d 59 10 	movl   $0xf010590d,0xc(%esp)
f01029f4:	f0 
f01029f5:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102a04:	00 
f0102a05:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102a0c:	e8 a5 d6 ff ff       	call   f01000b6 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a11:	83 c0 01             	add    $0x1,%eax
f0102a14:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102a19:	0f 85 29 ff ff ff    	jne    f0102948 <mem_init+0x182a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a1f:	c7 04 24 64 55 10 f0 	movl   $0xf0105564,(%esp)
f0102a26:	e8 ae 0b 00 00       	call   f01035d9 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a2b:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102a30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a35:	77 20                	ja     f0102a57 <mem_init+0x1939>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a3b:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102a52:	e8 5f d6 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a57:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a5c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a64:	e8 3e df ff ff       	call   f01009a7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a69:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a6c:	83 e0 f3             	and    $0xfffffff3,%eax
f0102a6f:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a74:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a7e:	e8 56 e3 ff ff       	call   f0100dd9 <page_alloc>
f0102a83:	89 c3                	mov    %eax,%ebx
f0102a85:	85 c0                	test   %eax,%eax
f0102a87:	75 24                	jne    f0102aad <mem_init+0x198f>
f0102a89:	c7 44 24 0c 09 57 10 	movl   $0xf0105709,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102aa8:	e8 09 d6 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102aad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab4:	e8 20 e3 ff ff       	call   f0100dd9 <page_alloc>
f0102ab9:	89 c7                	mov    %eax,%edi
f0102abb:	85 c0                	test   %eax,%eax
f0102abd:	75 24                	jne    f0102ae3 <mem_init+0x19c5>
f0102abf:	c7 44 24 0c 1f 57 10 	movl   $0xf010571f,0xc(%esp)
f0102ac6:	f0 
f0102ac7:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102ad6:	00 
f0102ad7:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102ade:	e8 d3 d5 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ae3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aea:	e8 ea e2 ff ff       	call   f0100dd9 <page_alloc>
f0102aef:	89 c6                	mov    %eax,%esi
f0102af1:	85 c0                	test   %eax,%eax
f0102af3:	75 24                	jne    f0102b19 <mem_init+0x19fb>
f0102af5:	c7 44 24 0c 35 57 10 	movl   $0xf0105735,0xc(%esp)
f0102afc:	f0 
f0102afd:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102b04:	f0 
f0102b05:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102b0c:	00 
f0102b0d:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102b14:	e8 9d d5 ff ff       	call   f01000b6 <_panic>
	page_free(pp0);
f0102b19:	89 1c 24             	mov    %ebx,(%esp)
f0102b1c:	e8 43 e3 ff ff       	call   f0100e64 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b21:	89 f8                	mov    %edi,%eax
f0102b23:	e8 cb dd ff ff       	call   f01008f3 <page2kva>
f0102b28:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b2f:	00 
f0102b30:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102b37:	00 
f0102b38:	89 04 24             	mov    %eax,(%esp)
f0102b3b:	e8 17 1a 00 00       	call   f0104557 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b40:	89 f0                	mov    %esi,%eax
f0102b42:	e8 ac dd ff ff       	call   f01008f3 <page2kva>
f0102b47:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b4e:	00 
f0102b4f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b56:	00 
f0102b57:	89 04 24             	mov    %eax,(%esp)
f0102b5a:	e8 f8 19 00 00       	call   f0104557 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b5f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b66:	00 
f0102b67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b6e:	00 
f0102b6f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b73:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102b78:	89 04 24             	mov    %eax,(%esp)
f0102b7b:	e8 0b e5 ff ff       	call   f010108b <page_insert>
	assert(pp1->pp_ref == 1);
f0102b80:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b85:	74 24                	je     f0102bab <mem_init+0x1a8d>
f0102b87:	c7 44 24 0c 06 58 10 	movl   $0xf0105806,0xc(%esp)
f0102b8e:	f0 
f0102b8f:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102b96:	f0 
f0102b97:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102b9e:	00 
f0102b9f:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102ba6:	e8 0b d5 ff ff       	call   f01000b6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bab:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bb2:	01 01 01 
f0102bb5:	74 24                	je     f0102bdb <mem_init+0x1abd>
f0102bb7:	c7 44 24 0c 84 55 10 	movl   $0xf0105584,0xc(%esp)
f0102bbe:	f0 
f0102bbf:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102bc6:	f0 
f0102bc7:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102bce:	00 
f0102bcf:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102bd6:	e8 db d4 ff ff       	call   f01000b6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bdb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102be2:	00 
f0102be3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bea:	00 
f0102beb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bef:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102bf4:	89 04 24             	mov    %eax,(%esp)
f0102bf7:	e8 8f e4 ff ff       	call   f010108b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bfc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c03:	02 02 02 
f0102c06:	74 24                	je     f0102c2c <mem_init+0x1b0e>
f0102c08:	c7 44 24 0c a8 55 10 	movl   $0xf01055a8,0xc(%esp)
f0102c0f:	f0 
f0102c10:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102c1f:	00 
f0102c20:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102c27:	e8 8a d4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0102c2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c31:	74 24                	je     f0102c57 <mem_init+0x1b39>
f0102c33:	c7 44 24 0c 28 58 10 	movl   $0xf0105828,0xc(%esp)
f0102c3a:	f0 
f0102c3b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102c42:	f0 
f0102c43:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102c4a:	00 
f0102c4b:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102c52:	e8 5f d4 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102c57:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5c:	74 24                	je     f0102c82 <mem_init+0x1b64>
f0102c5e:	c7 44 24 0c 92 58 10 	movl   $0xf0105892,0xc(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102c6d:	f0 
f0102c6e:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102c75:	00 
f0102c76:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102c7d:	e8 34 d4 ff ff       	call   f01000b6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c82:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c89:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c8c:	89 f0                	mov    %esi,%eax
f0102c8e:	e8 60 dc ff ff       	call   f01008f3 <page2kva>
f0102c93:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102c99:	74 24                	je     f0102cbf <mem_init+0x1ba1>
f0102c9b:	c7 44 24 0c cc 55 10 	movl   $0xf01055cc,0xc(%esp)
f0102ca2:	f0 
f0102ca3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102caa:	f0 
f0102cab:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102cb2:	00 
f0102cb3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102cba:	e8 f7 d3 ff ff       	call   f01000b6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cbf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102cc6:	00 
f0102cc7:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102ccc:	89 04 24             	mov    %eax,(%esp)
f0102ccf:	e8 69 e3 ff ff       	call   f010103d <page_remove>
	assert(pp2->pp_ref == 0);
f0102cd4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cd9:	74 24                	je     f0102cff <mem_init+0x1be1>
f0102cdb:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0102ce2:	f0 
f0102ce3:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102cea:	f0 
f0102ceb:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102cf2:	00 
f0102cf3:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102cfa:	e8 b7 d3 ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cff:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102d04:	8b 08                	mov    (%eax),%ecx
f0102d06:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d0c:	89 da                	mov    %ebx,%edx
f0102d0e:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0102d14:	c1 fa 03             	sar    $0x3,%edx
f0102d17:	c1 e2 0c             	shl    $0xc,%edx
f0102d1a:	39 d1                	cmp    %edx,%ecx
f0102d1c:	74 24                	je     f0102d42 <mem_init+0x1c24>
f0102d1e:	c7 44 24 0c dc 50 10 	movl   $0xf01050dc,0xc(%esp)
f0102d25:	f0 
f0102d26:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102d35:	00 
f0102d36:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102d3d:	e8 74 d3 ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d48:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d4d:	74 24                	je     f0102d73 <mem_init+0x1c55>
f0102d4f:	c7 44 24 0c 17 58 10 	movl   $0xf0105817,0xc(%esp)
f0102d56:	f0 
f0102d57:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0102d5e:	f0 
f0102d5f:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102d66:	00 
f0102d67:	c7 04 24 2f 56 10 f0 	movl   $0xf010562f,(%esp)
f0102d6e:	e8 43 d3 ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102d73:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d79:	89 1c 24             	mov    %ebx,(%esp)
f0102d7c:	e8 e3 e0 ff ff       	call   f0100e64 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d81:	c7 04 24 f8 55 10 f0 	movl   $0xf01055f8,(%esp)
f0102d88:	e8 4c 08 00 00       	call   f01035d9 <cprintf>
f0102d8d:	eb 0f                	jmp    f0102d9e <mem_init+0x1c80>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d8f:	89 f2                	mov    %esi,%edx
f0102d91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d94:	e8 9f db ff ff       	call   f0100938 <check_va2pa>
f0102d99:	e9 8e fa ff ff       	jmp    f010282c <mem_init+0x170e>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d9e:	83 c4 4c             	add    $0x4c,%esp
f0102da1:	5b                   	pop    %ebx
f0102da2:	5e                   	pop    %esi
f0102da3:	5f                   	pop    %edi
f0102da4:	5d                   	pop    %ebp
f0102da5:	c3                   	ret    

f0102da6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102da6:	55                   	push   %ebp
f0102da7:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102da9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dac:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102daf:	5d                   	pop    %ebp
f0102db0:	c3                   	ret    

f0102db1 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102db1:	55                   	push   %ebp
f0102db2:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102db4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102db9:	5d                   	pop    %ebp
f0102dba:	c3                   	ret    

f0102dbb <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102dbb:	55                   	push   %ebp
f0102dbc:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0102dbe:	5d                   	pop    %ebp
f0102dbf:	c3                   	ret    

f0102dc0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102dc0:	55                   	push   %ebp
f0102dc1:	89 e5                	mov    %esp,%ebp
f0102dc3:	57                   	push   %edi
f0102dc4:	56                   	push   %esi
f0102dc5:	53                   	push   %ebx
f0102dc6:	83 ec 2c             	sub    $0x2c,%esp
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	pde_t* pgdir = e->env_pgdir;
f0102dc9:	8b 78 5c             	mov    0x5c(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f0102dcc:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102dd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dd8:	89 d1                	mov    %edx,%ecx
f0102dda:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102de0:	29 c8                	sub    %ecx,%eax
f0102de2:	c1 e8 0c             	shr    $0xc,%eax
f0102de5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f0102de8:	89 d6                	mov    %edx,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	pde_t* pgdir = e->env_pgdir;
	int i=0;
f0102dea:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0102def:	eb 6d                	jmp    f0102e5e <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f0102df1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102df8:	e8 dc df ff ff       	call   f0100dd9 <page_alloc>
		if(newPage == 0)
f0102dfd:	85 c0                	test   %eax,%eax
f0102dff:	75 1c                	jne    f0102e1d <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f0102e01:	c7 44 24 08 1c 59 10 	movl   $0xf010591c,0x8(%esp)
f0102e08:	f0 
f0102e09:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0102e10:	00 
f0102e11:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0102e18:	e8 99 d2 ff ff       	call   f01000b6 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f0102e1d:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102e24:	00 
f0102e25:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102e29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e2d:	89 3c 24             	mov    %edi,(%esp)
f0102e30:	e8 56 e2 ff ff       	call   f010108b <page_insert>
f0102e35:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f0102e3b:	85 c0                	test   %eax,%eax
f0102e3d:	74 1c                	je     f0102e5b <region_alloc+0x9b>
			panic("page_insert fail\n");
f0102e3f:	c7 44 24 08 8d 59 10 	movl   $0xf010598d,0x8(%esp)
f0102e46:	f0 
f0102e47:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0102e4e:	00 
f0102e4f:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0102e56:	e8 5b d2 ff ff       	call   f01000b6 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0102e5b:	83 c3 01             	add    $0x1,%ebx
f0102e5e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e61:	7c 8e                	jl     f0102df1 <region_alloc+0x31>
	}
	return ;



}
f0102e63:	83 c4 2c             	add    $0x2c,%esp
f0102e66:	5b                   	pop    %ebx
f0102e67:	5e                   	pop    %esi
f0102e68:	5f                   	pop    %edi
f0102e69:	5d                   	pop    %ebp
f0102e6a:	c3                   	ret    

f0102e6b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e6b:	55                   	push   %ebp
f0102e6c:	89 e5                	mov    %esp,%ebp
f0102e6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e74:	85 c0                	test   %eax,%eax
f0102e76:	75 11                	jne    f0102e89 <envid2env+0x1e>
		*env_store = curenv;
f0102e78:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f0102e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e80:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e82:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e87:	eb 5e                	jmp    f0102ee7 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e89:	89 c2                	mov    %eax,%edx
f0102e8b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102e91:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102e94:	c1 e2 05             	shl    $0x5,%edx
f0102e97:	03 15 c8 d0 17 f0    	add    0xf017d0c8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e9d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102ea1:	74 05                	je     f0102ea8 <envid2env+0x3d>
f0102ea3:	39 42 48             	cmp    %eax,0x48(%edx)
f0102ea6:	74 10                	je     f0102eb8 <envid2env+0x4d>
		*env_store = 0;
f0102ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102eb1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eb6:	eb 2f                	jmp    f0102ee7 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eb8:	84 c9                	test   %cl,%cl
f0102eba:	74 21                	je     f0102edd <envid2env+0x72>
f0102ebc:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f0102ec1:	39 c2                	cmp    %eax,%edx
f0102ec3:	74 18                	je     f0102edd <envid2env+0x72>
f0102ec5:	8b 40 48             	mov    0x48(%eax),%eax
f0102ec8:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102ecb:	74 10                	je     f0102edd <envid2env+0x72>
		*env_store = 0;
f0102ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ed0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ed6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102edb:	eb 0a                	jmp    f0102ee7 <envid2env+0x7c>
	}

	*env_store = e;
f0102edd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ee0:	89 10                	mov    %edx,(%eax)
	return 0;
f0102ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ee7:	5d                   	pop    %ebp
f0102ee8:	c3                   	ret    

f0102ee9 <env_init_percpu>:


// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ee9:	55                   	push   %ebp
f0102eea:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102eec:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102ef1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ef4:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ef9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102efb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102efd:	b0 10                	mov    $0x10,%al
f0102eff:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f01:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f03:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f05:	ea 0c 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f0c
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f0c:	b0 00                	mov    $0x0,%al
f0102f0e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f11:	5d                   	pop    %ebp
f0102f12:	c3                   	ret    

f0102f13 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f13:	55                   	push   %ebp
f0102f14:	89 e5                	mov    %esp,%ebp
f0102f16:	53                   	push   %ebx
f0102f17:	83 ec 14             	sub    $0x14,%esp
	// Set up envs array
	// LAB 3: Your code here.

	env_free_list = 0;
f0102f1a:	c7 05 cc d0 17 f0 00 	movl   $0x0,0xf017d0cc
f0102f21:	00 00 00 
f0102f24:	bb a0 7f 01 00       	mov    $0x17fa0,%ebx
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f0102f29:	8b 15 c8 d0 17 f0    	mov    0xf017d0c8,%edx
f0102f2f:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0102f32:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f39:	8b 0d cc d0 17 f0    	mov    0xf017d0cc,%ecx
f0102f3f:	89 4c 1a 44          	mov    %ecx,0x44(%edx,%ebx,1)
		env_free_list = &envs[i];
f0102f43:	a3 cc d0 17 f0       	mov    %eax,0xf017d0cc
		
		memset(&envs[i].env_tf, 0, sizeof(struct Trapframe));
f0102f48:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102f4f:	00 
f0102f50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f57:	00 
f0102f58:	89 04 24             	mov    %eax,(%esp)
f0102f5b:	e8 f7 15 00 00       	call   f0104557 <memset>
		
		envs[i].env_parent_id = 0;
f0102f60:	89 d8                	mov    %ebx,%eax
f0102f62:	03 05 c8 d0 17 f0    	add    0xf017d0c8,%eax
f0102f68:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[i].env_type =  ENV_TYPE_USER;
f0102f6f:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[i].env_status = ENV_FREE;
f0102f76:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_runs = 0;
f0102f7d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[i].env_pgdir = 0;
f0102f84:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%eax)
f0102f8b:	83 eb 60             	sub    $0x60,%ebx
	// Set up envs array
	// LAB 3: Your code here.

	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f0102f8e:	83 fb a0             	cmp    $0xffffffa0,%ebx
f0102f91:	75 96                	jne    f0102f29 <env_init+0x16>
		envs[i].env_runs = 0;
		envs[i].env_pgdir = 0;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f93:	e8 51 ff ff ff       	call   f0102ee9 <env_init_percpu>

}
f0102f98:	83 c4 14             	add    $0x14,%esp
f0102f9b:	5b                   	pop    %ebx
f0102f9c:	5d                   	pop    %ebp
f0102f9d:	c3                   	ret    

f0102f9e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f9e:	55                   	push   %ebp
f0102f9f:	89 e5                	mov    %esp,%ebp
f0102fa1:	53                   	push   %ebx
f0102fa2:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fa5:	8b 1d cc d0 17 f0    	mov    0xf017d0cc,%ebx
f0102fab:	85 db                	test   %ebx,%ebx
f0102fad:	0f 84 6d 01 00 00    	je     f0103120 <env_alloc+0x182>

	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102fba:	e8 1a de ff ff       	call   f0100dd9 <page_alloc>
f0102fbf:	85 c0                	test   %eax,%eax
f0102fc1:	0f 84 60 01 00 00    	je     f0103127 <env_alloc+0x189>
f0102fc7:	89 c2                	mov    %eax,%edx
f0102fc9:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0102fcf:	c1 fa 03             	sar    $0x3,%edx
f0102fd2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fd5:	89 d1                	mov    %edx,%ecx
f0102fd7:	c1 e9 0c             	shr    $0xc,%ecx
f0102fda:	3b 0d 84 dd 17 f0    	cmp    0xf017dd84,%ecx
f0102fe0:	72 20                	jb     f0103002 <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fe2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fe6:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0102fed:	f0 
f0102fee:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102ff5:	00 
f0102ff6:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0102ffd:	e8 b4 d0 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0103002:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103008:	89 53 5c             	mov    %edx,0x5c(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f010300b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103010:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103017:	00 
f0103018:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f010301d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103021:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103024:	89 04 24             	mov    %eax,(%esp)
f0103027:	e8 e0 15 00 00       	call   f010460c <memcpy>
	


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010302c:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010302f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103034:	77 20                	ja     f0103056 <env_alloc+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103036:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010303a:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0103041:	f0 
f0103042:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f0103049:	00 
f010304a:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0103051:	e8 60 d0 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103056:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010305c:	83 ca 05             	or     $0x5,%edx
f010305f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103065:	8b 43 48             	mov    0x48(%ebx),%eax
f0103068:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010306d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103072:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103077:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010307a:	89 da                	mov    %ebx,%edx
f010307c:	2b 15 c8 d0 17 f0    	sub    0xf017d0c8,%edx
f0103082:	c1 fa 05             	sar    $0x5,%edx
f0103085:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010308b:	09 d0                	or     %edx,%eax
f010308d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103090:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103093:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103096:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010309d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030a4:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030ab:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01030b2:	00 
f01030b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01030ba:	00 
f01030bb:	89 1c 24             	mov    %ebx,(%esp)
f01030be:	e8 94 14 00 00       	call   f0104557 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030c3:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030c9:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030cf:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030d5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030dc:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01030e2:	8b 43 44             	mov    0x44(%ebx),%eax
f01030e5:	a3 cc d0 17 f0       	mov    %eax,0xf017d0cc
	*newenv_store = e;
f01030ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01030ed:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030ef:	8b 53 48             	mov    0x48(%ebx),%edx
f01030f2:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f01030f7:	85 c0                	test   %eax,%eax
f01030f9:	74 05                	je     f0103100 <env_alloc+0x162>
f01030fb:	8b 40 48             	mov    0x48(%eax),%eax
f01030fe:	eb 05                	jmp    f0103105 <env_alloc+0x167>
f0103100:	b8 00 00 00 00       	mov    $0x0,%eax
f0103105:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103109:	89 44 24 04          	mov    %eax,0x4(%esp)
f010310d:	c7 04 24 9f 59 10 f0 	movl   $0xf010599f,(%esp)
f0103114:	e8 c0 04 00 00       	call   f01035d9 <cprintf>
	return 0;
f0103119:	b8 00 00 00 00       	mov    $0x0,%eax
f010311e:	eb 0c                	jmp    f010312c <env_alloc+0x18e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103120:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103125:	eb 05                	jmp    f010312c <env_alloc+0x18e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103127:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010312c:	83 c4 14             	add    $0x14,%esp
f010312f:	5b                   	pop    %ebx
f0103130:	5d                   	pop    %ebp
f0103131:	c3                   	ret    

f0103132 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103132:	55                   	push   %ebp
f0103133:	89 e5                	mov    %esp,%ebp
f0103135:	57                   	push   %edi
f0103136:	56                   	push   %esi
f0103137:	53                   	push   %ebx
f0103138:	83 ec 3c             	sub    $0x3c,%esp
	//env_alloc(struct Env **newenv_store, envid_t parent_id)
	// LAB 3: Your code here.
	struct Env* env=0;
f010313b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f0103142:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103149:	00 
f010314a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010314d:	89 04 24             	mov    %eax,(%esp)
f0103150:	e8 49 fe ff ff       	call   f0102f9e <env_alloc>
	if(r < 0)
f0103155:	85 c0                	test   %eax,%eax
f0103157:	79 1c                	jns    f0103175 <env_create+0x43>
		panic("env_create fault\n");
f0103159:	c7 44 24 08 b4 59 10 	movl   $0xf01059b4,0x8(%esp)
f0103160:	f0 
f0103161:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0103168:	00 
f0103169:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0103170:	e8 41 cf ff ff       	call   f01000b6 <_panic>
	load_icode(env, binary);
f0103175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103178:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.

		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f010317b:	8b 45 08             	mov    0x8(%ebp),%eax
f010317e:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103184:	74 1c                	je     f01031a2 <env_create+0x70>
			panic("e_magic is not right\n");
f0103186:	c7 44 24 08 c6 59 10 	movl   $0xf01059c6,0x8(%esp)
f010318d:	f0 
f010318e:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f0103195:	00 
f0103196:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f010319d:	e8 14 cf ff ff       	call   f01000b6 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));
f01031a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031a5:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ad:	77 20                	ja     f01031cf <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031af:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b3:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f01031ba:	f0 
f01031bb:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f01031c2:	00 
f01031c3:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f01031ca:	e8 e7 ce ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031cf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031d4:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f01031d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031da:	89 c3                	mov    %eax,%ebx
f01031dc:	03 58 1c             	add    0x1c(%eax),%ebx
f01031df:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01031e3:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f01031e6:	be 01 00 00 00       	mov    $0x1,%esi
f01031eb:	eb 68                	jmp    f0103255 <env_create+0x123>
		int i=0;
		for(; i<num; i++){
			ph++;
f01031ed:	83 c3 20             	add    $0x20,%ebx
			cprintf("ph%d  = %x\n", i, (unsigned int)ph);	
f01031f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01031f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031f8:	c7 04 24 dc 59 10 f0 	movl   $0xf01059dc,(%esp)
f01031ff:	e8 d5 03 00 00       	call   f01035d9 <cprintf>
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f0103204:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103207:	75 49                	jne    f0103252 <env_create+0x120>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f0103209:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010320c:	8b 53 08             	mov    0x8(%ebx),%edx
f010320f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103212:	e8 a9 fb ff ff       	call   f0102dc0 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f0103217:	8b 43 10             	mov    0x10(%ebx),%eax
f010321a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010321e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103221:	03 43 04             	add    0x4(%ebx),%eax
f0103224:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103228:	8b 43 08             	mov    0x8(%ebx),%eax
f010322b:	89 04 24             	mov    %eax,(%esp)
f010322e:	e8 71 13 00 00       	call   f01045a4 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103233:	8b 43 10             	mov    0x10(%ebx),%eax
f0103236:	8b 53 14             	mov    0x14(%ebx),%edx
f0103239:	29 c2                	sub    %eax,%edx
f010323b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010323f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103246:	00 
f0103247:	03 43 08             	add    0x8(%ebx),%eax
f010324a:	89 04 24             	mov    %eax,(%esp)
f010324d:	e8 05 13 00 00       	call   f0104557 <memset>
f0103252:	83 c6 01             	add    $0x1,%esi
f0103255:	8d 46 ff             	lea    -0x1(%esi),%eax

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103258:	39 fe                	cmp    %edi,%esi
f010325a:	75 91                	jne    f01031ed <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f010325c:	8b 45 08             	mov    0x8(%ebp),%eax
f010325f:	8b 40 18             	mov    0x18(%eax),%eax
f0103262:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103265:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103268:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010326d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103272:	89 f8                	mov    %edi,%eax
f0103274:	e8 47 fb ff ff       	call   f0102dc0 <region_alloc>
		    		    lcr3(PADDR(kern_pgdir));
f0103279:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010327e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103283:	77 20                	ja     f01032a5 <env_create+0x173>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103285:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103289:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0103290:	f0 
f0103291:	c7 44 24 04 a3 01 00 	movl   $0x1a3,0x4(%esp)
f0103298:	00 
f0103299:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f01032a0:	e8 11 ce ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032a5:	05 00 00 00 10       	add    $0x10000000,%eax
f01032aa:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f01032ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032b0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032b3:	89 50 50             	mov    %edx,0x50(%eax)

}
f01032b6:	83 c4 3c             	add    $0x3c,%esp
f01032b9:	5b                   	pop    %ebx
f01032ba:	5e                   	pop    %esi
f01032bb:	5f                   	pop    %edi
f01032bc:	5d                   	pop    %ebp
f01032bd:	c3                   	ret    

f01032be <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032be:	55                   	push   %ebp
f01032bf:	89 e5                	mov    %esp,%ebp
f01032c1:	57                   	push   %edi
f01032c2:	56                   	push   %esi
f01032c3:	53                   	push   %ebx
f01032c4:	83 ec 2c             	sub    $0x2c,%esp
f01032c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032ca:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f01032cf:	39 c7                	cmp    %eax,%edi
f01032d1:	75 37                	jne    f010330a <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01032d3:	8b 15 88 dd 17 f0    	mov    0xf017dd88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01032df:	77 20                	ja     f0103301 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032e5:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f01032ec:	f0 
f01032ed:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f01032f4:	00 
f01032f5:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f01032fc:	e8 b5 cd ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103301:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103307:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010330a:	8b 57 48             	mov    0x48(%edi),%edx
f010330d:	85 c0                	test   %eax,%eax
f010330f:	74 05                	je     f0103316 <env_free+0x58>
f0103311:	8b 40 48             	mov    0x48(%eax),%eax
f0103314:	eb 05                	jmp    f010331b <env_free+0x5d>
f0103316:	b8 00 00 00 00       	mov    $0x0,%eax
f010331b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010331f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103323:	c7 04 24 e8 59 10 f0 	movl   $0xf01059e8,(%esp)
f010332a:	e8 aa 02 00 00       	call   f01035d9 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010332f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103336:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103339:	89 c8                	mov    %ecx,%eax
f010333b:	c1 e0 02             	shl    $0x2,%eax
f010333e:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103341:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103344:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103347:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010334d:	0f 84 b7 00 00 00    	je     f010340a <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103353:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103359:	89 f0                	mov    %esi,%eax
f010335b:	c1 e8 0c             	shr    $0xc,%eax
f010335e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103361:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f0103367:	72 20                	jb     f0103389 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103369:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010336d:	c7 44 24 08 9c 4e 10 	movl   $0xf0104e9c,0x8(%esp)
f0103374:	f0 
f0103375:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
f010337c:	00 
f010337d:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0103384:	e8 2d cd ff ff       	call   f01000b6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103389:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010338c:	c1 e0 16             	shl    $0x16,%eax
f010338f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103392:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103397:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010339e:	01 
f010339f:	74 17                	je     f01033b8 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033a1:	89 d8                	mov    %ebx,%eax
f01033a3:	c1 e0 0c             	shl    $0xc,%eax
f01033a6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01033a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033ad:	8b 47 5c             	mov    0x5c(%edi),%eax
f01033b0:	89 04 24             	mov    %eax,(%esp)
f01033b3:	e8 85 dc ff ff       	call   f010103d <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033b8:	83 c3 01             	add    $0x1,%ebx
f01033bb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01033c1:	75 d4                	jne    f0103397 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033c3:	8b 47 5c             	mov    0x5c(%edi),%eax
f01033c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033c9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01033d3:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f01033d9:	72 1c                	jb     f01033f7 <env_free+0x139>
		panic("pa2page called with invalid pa");
f01033db:	c7 44 24 08 84 4f 10 	movl   $0xf0104f84,0x8(%esp)
f01033e2:	f0 
f01033e3:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01033ea:	00 
f01033eb:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f01033f2:	e8 bf cc ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f01033f7:	a1 8c dd 17 f0       	mov    0xf017dd8c,%eax
f01033fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033ff:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103402:	89 04 24             	mov    %eax,(%esp)
f0103405:	e8 9a da ff ff       	call   f0100ea4 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010340a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010340e:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103415:	0f 85 1b ff ff ff    	jne    f0103336 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010341b:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010341e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103423:	77 20                	ja     f0103445 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103425:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103429:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0103430:	f0 
f0103431:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0103438:	00 
f0103439:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0103440:	e8 71 cc ff ff       	call   f01000b6 <_panic>
	e->env_pgdir = 0;
f0103445:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f010344c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103451:	c1 e8 0c             	shr    $0xc,%eax
f0103454:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f010345a:	72 1c                	jb     f0103478 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f010345c:	c7 44 24 08 84 4f 10 	movl   $0xf0104f84,0x8(%esp)
f0103463:	f0 
f0103464:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010346b:	00 
f010346c:	c7 04 24 21 56 10 f0 	movl   $0xf0105621,(%esp)
f0103473:	e8 3e cc ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103478:	8b 15 8c dd 17 f0    	mov    0xf017dd8c,%edx
f010347e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103481:	89 04 24             	mov    %eax,(%esp)
f0103484:	e8 1b da ff ff       	call   f0100ea4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103489:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103490:	a1 cc d0 17 f0       	mov    0xf017d0cc,%eax
f0103495:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103498:	89 3d cc d0 17 f0    	mov    %edi,0xf017d0cc
}
f010349e:	83 c4 2c             	add    $0x2c,%esp
f01034a1:	5b                   	pop    %ebx
f01034a2:	5e                   	pop    %esi
f01034a3:	5f                   	pop    %edi
f01034a4:	5d                   	pop    %ebp
f01034a5:	c3                   	ret    

f01034a6 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01034a6:	55                   	push   %ebp
f01034a7:	89 e5                	mov    %esp,%ebp
f01034a9:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01034ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01034af:	89 04 24             	mov    %eax,(%esp)
f01034b2:	e8 07 fe ff ff       	call   f01032be <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01034b7:	c7 04 24 4c 59 10 f0 	movl   $0xf010594c,(%esp)
f01034be:	e8 16 01 00 00       	call   f01035d9 <cprintf>
	while (1)
		monitor(NULL);
f01034c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01034ca:	e8 8a d2 ff ff       	call   f0100759 <monitor>
f01034cf:	eb f2                	jmp    f01034c3 <env_destroy+0x1d>

f01034d1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034d1:	55                   	push   %ebp
f01034d2:	89 e5                	mov    %esp,%ebp
f01034d4:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01034d7:	8b 65 08             	mov    0x8(%ebp),%esp
f01034da:	61                   	popa   
f01034db:	07                   	pop    %es
f01034dc:	1f                   	pop    %ds
f01034dd:	83 c4 08             	add    $0x8,%esp
f01034e0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034e1:	c7 44 24 08 fe 59 10 	movl   $0xf01059fe,0x8(%esp)
f01034e8:	f0 
f01034e9:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
f01034f0:	00 
f01034f1:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f01034f8:	e8 b9 cb ff ff       	call   f01000b6 <_panic>

f01034fd <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034fd:	55                   	push   %ebp
f01034fe:	89 e5                	mov    %esp,%ebp
f0103500:	83 ec 18             	sub    $0x18,%esp
f0103503:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103506:	8b 15 c4 d0 17 f0    	mov    0xf017d0c4,%edx
f010350c:	85 d2                	test   %edx,%edx
f010350e:	74 0d                	je     f010351d <env_run+0x20>
		curenv = e;
	else if(curenv->env_status == ENV_RUNNING)
f0103510:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103514:	75 07                	jne    f010351d <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0103516:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	curenv = e;
f010351d:	a3 c4 d0 17 f0       	mov    %eax,0xf017d0c4
	curenv->env_status = ENV_RUNNING;
f0103522:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103529:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f010352d:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103530:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103536:	77 20                	ja     f0103558 <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103538:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010353c:	c7 44 24 08 e0 4f 10 	movl   $0xf0104fe0,0x8(%esp)
f0103543:	f0 
f0103544:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
f010354b:	00 
f010354c:	c7 04 24 82 59 10 f0 	movl   $0xf0105982,(%esp)
f0103553:	e8 5e cb ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103558:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010355e:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(& (curenv->env_tf) );
f0103561:	89 04 24             	mov    %eax,(%esp)
f0103564:	e8 68 ff ff ff       	call   f01034d1 <env_pop_tf>

f0103569 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103569:	55                   	push   %ebp
f010356a:	89 e5                	mov    %esp,%ebp
f010356c:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103570:	ba 70 00 00 00       	mov    $0x70,%edx
f0103575:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103576:	b2 71                	mov    $0x71,%dl
f0103578:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103579:	0f b6 c0             	movzbl %al,%eax
}
f010357c:	5d                   	pop    %ebp
f010357d:	c3                   	ret    

f010357e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010357e:	55                   	push   %ebp
f010357f:	89 e5                	mov    %esp,%ebp
f0103581:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103585:	ba 70 00 00 00       	mov    $0x70,%edx
f010358a:	ee                   	out    %al,(%dx)
f010358b:	b2 71                	mov    $0x71,%dl
f010358d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103590:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103591:	5d                   	pop    %ebp
f0103592:	c3                   	ret    

f0103593 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103593:	55                   	push   %ebp
f0103594:	89 e5                	mov    %esp,%ebp
f0103596:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103599:	8b 45 08             	mov    0x8(%ebp),%eax
f010359c:	89 04 24             	mov    %eax,(%esp)
f010359f:	e8 6d d0 ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f01035a4:	c9                   	leave  
f01035a5:	c3                   	ret    

f01035a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01035a6:	55                   	push   %ebp
f01035a7:	89 e5                	mov    %esp,%ebp
f01035a9:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01035ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01035bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01035c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c8:	c7 04 24 93 35 10 f0 	movl   $0xf0103593,(%esp)
f01035cf:	e8 40 08 00 00       	call   f0103e14 <vprintfmt>
	return cnt;
}
f01035d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01035d7:	c9                   	leave  
f01035d8:	c3                   	ret    

f01035d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01035d9:	55                   	push   %ebp
f01035da:	89 e5                	mov    %esp,%ebp
f01035dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01035df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01035e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035e9:	89 04 24             	mov    %eax,(%esp)
f01035ec:	e8 b5 ff ff ff       	call   f01035a6 <vcprintf>
	va_end(ap);

	return cnt;
}
f01035f1:	c9                   	leave  
f01035f2:	c3                   	ret    

f01035f3 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01035f3:	55                   	push   %ebp
f01035f4:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01035f6:	c7 05 04 d9 17 f0 00 	movl   $0xf0000000,0xf017d904
f01035fd:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103600:	66 c7 05 08 d9 17 f0 	movw   $0x10,0xf017d908
f0103607:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103609:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0103610:	67 00 
f0103612:	b8 00 d9 17 f0       	mov    $0xf017d900,%eax
f0103617:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f010361d:	89 c2                	mov    %eax,%edx
f010361f:	c1 ea 10             	shr    $0x10,%edx
f0103622:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103628:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010362f:	c1 e8 18             	shr    $0x18,%eax
f0103632:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103637:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010363e:	b8 28 00 00 00       	mov    $0x28,%eax
f0103643:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103646:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f010364b:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010364e:	5d                   	pop    %ebp
f010364f:	c3                   	ret    

f0103650 <trap_init>:
}


void
trap_init(void)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103653:	e8 9b ff ff ff       	call   f01035f3 <trap_init_percpu>
}
f0103658:	5d                   	pop    %ebp
f0103659:	c3                   	ret    

f010365a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010365a:	55                   	push   %ebp
f010365b:	89 e5                	mov    %esp,%ebp
f010365d:	53                   	push   %ebx
f010365e:	83 ec 14             	sub    $0x14,%esp
f0103661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103664:	8b 03                	mov    (%ebx),%eax
f0103666:	89 44 24 04          	mov    %eax,0x4(%esp)
f010366a:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0103671:	e8 63 ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103676:	8b 43 04             	mov    0x4(%ebx),%eax
f0103679:	89 44 24 04          	mov    %eax,0x4(%esp)
f010367d:	c7 04 24 19 5a 10 f0 	movl   $0xf0105a19,(%esp)
f0103684:	e8 50 ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103689:	8b 43 08             	mov    0x8(%ebx),%eax
f010368c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103690:	c7 04 24 28 5a 10 f0 	movl   $0xf0105a28,(%esp)
f0103697:	e8 3d ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010369c:	8b 43 0c             	mov    0xc(%ebx),%eax
f010369f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a3:	c7 04 24 37 5a 10 f0 	movl   $0xf0105a37,(%esp)
f01036aa:	e8 2a ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01036af:	8b 43 10             	mov    0x10(%ebx),%eax
f01036b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036b6:	c7 04 24 46 5a 10 f0 	movl   $0xf0105a46,(%esp)
f01036bd:	e8 17 ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036c2:	8b 43 14             	mov    0x14(%ebx),%eax
f01036c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036c9:	c7 04 24 55 5a 10 f0 	movl   $0xf0105a55,(%esp)
f01036d0:	e8 04 ff ff ff       	call   f01035d9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036d5:	8b 43 18             	mov    0x18(%ebx),%eax
f01036d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036dc:	c7 04 24 64 5a 10 f0 	movl   $0xf0105a64,(%esp)
f01036e3:	e8 f1 fe ff ff       	call   f01035d9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036e8:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01036eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ef:	c7 04 24 73 5a 10 f0 	movl   $0xf0105a73,(%esp)
f01036f6:	e8 de fe ff ff       	call   f01035d9 <cprintf>
}
f01036fb:	83 c4 14             	add    $0x14,%esp
f01036fe:	5b                   	pop    %ebx
f01036ff:	5d                   	pop    %ebp
f0103700:	c3                   	ret    

f0103701 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103701:	55                   	push   %ebp
f0103702:	89 e5                	mov    %esp,%ebp
f0103704:	56                   	push   %esi
f0103705:	53                   	push   %ebx
f0103706:	83 ec 10             	sub    $0x10,%esp
f0103709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010370c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103710:	c7 04 24 a9 5b 10 f0 	movl   $0xf0105ba9,(%esp)
f0103717:	e8 bd fe ff ff       	call   f01035d9 <cprintf>
	print_regs(&tf->tf_regs);
f010371c:	89 1c 24             	mov    %ebx,(%esp)
f010371f:	e8 36 ff ff ff       	call   f010365a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103724:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103728:	89 44 24 04          	mov    %eax,0x4(%esp)
f010372c:	c7 04 24 c4 5a 10 f0 	movl   $0xf0105ac4,(%esp)
f0103733:	e8 a1 fe ff ff       	call   f01035d9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103738:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010373c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103740:	c7 04 24 d7 5a 10 f0 	movl   $0xf0105ad7,(%esp)
f0103747:	e8 8d fe ff ff       	call   f01035d9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010374c:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010374f:	83 f8 13             	cmp    $0x13,%eax
f0103752:	77 09                	ja     f010375d <print_trapframe+0x5c>
		return excnames[trapno];
f0103754:	8b 14 85 80 5d 10 f0 	mov    -0xfefa280(,%eax,4),%edx
f010375b:	eb 10                	jmp    f010376d <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f010375d:	83 f8 30             	cmp    $0x30,%eax
f0103760:	ba 82 5a 10 f0       	mov    $0xf0105a82,%edx
f0103765:	b9 8e 5a 10 f0       	mov    $0xf0105a8e,%ecx
f010376a:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010376d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103771:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103775:	c7 04 24 ea 5a 10 f0 	movl   $0xf0105aea,(%esp)
f010377c:	e8 58 fe ff ff       	call   f01035d9 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103781:	3b 1d e0 d8 17 f0    	cmp    0xf017d8e0,%ebx
f0103787:	75 19                	jne    f01037a2 <print_trapframe+0xa1>
f0103789:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010378d:	75 13                	jne    f01037a2 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010378f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103792:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103796:	c7 04 24 fc 5a 10 f0 	movl   $0xf0105afc,(%esp)
f010379d:	e8 37 fe ff ff       	call   f01035d9 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01037a2:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01037a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037a9:	c7 04 24 0b 5b 10 f0 	movl   $0xf0105b0b,(%esp)
f01037b0:	e8 24 fe ff ff       	call   f01035d9 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01037b5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01037b9:	75 51                	jne    f010380c <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01037bb:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01037be:	89 c2                	mov    %eax,%edx
f01037c0:	83 e2 01             	and    $0x1,%edx
f01037c3:	ba 9d 5a 10 f0       	mov    $0xf0105a9d,%edx
f01037c8:	b9 a8 5a 10 f0       	mov    $0xf0105aa8,%ecx
f01037cd:	0f 45 ca             	cmovne %edx,%ecx
f01037d0:	89 c2                	mov    %eax,%edx
f01037d2:	83 e2 02             	and    $0x2,%edx
f01037d5:	ba b4 5a 10 f0       	mov    $0xf0105ab4,%edx
f01037da:	be ba 5a 10 f0       	mov    $0xf0105aba,%esi
f01037df:	0f 44 d6             	cmove  %esi,%edx
f01037e2:	83 e0 04             	and    $0x4,%eax
f01037e5:	b8 bf 5a 10 f0       	mov    $0xf0105abf,%eax
f01037ea:	be d4 5b 10 f0       	mov    $0xf0105bd4,%esi
f01037ef:	0f 44 c6             	cmove  %esi,%eax
f01037f2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01037f6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01037fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037fe:	c7 04 24 19 5b 10 f0 	movl   $0xf0105b19,(%esp)
f0103805:	e8 cf fd ff ff       	call   f01035d9 <cprintf>
f010380a:	eb 0c                	jmp    f0103818 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010380c:	c7 04 24 e9 58 10 f0 	movl   $0xf01058e9,(%esp)
f0103813:	e8 c1 fd ff ff       	call   f01035d9 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103818:	8b 43 30             	mov    0x30(%ebx),%eax
f010381b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010381f:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f0103826:	e8 ae fd ff ff       	call   f01035d9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010382b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010382f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103833:	c7 04 24 37 5b 10 f0 	movl   $0xf0105b37,(%esp)
f010383a:	e8 9a fd ff ff       	call   f01035d9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010383f:	8b 43 38             	mov    0x38(%ebx),%eax
f0103842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103846:	c7 04 24 4a 5b 10 f0 	movl   $0xf0105b4a,(%esp)
f010384d:	e8 87 fd ff ff       	call   f01035d9 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103852:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103856:	74 27                	je     f010387f <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103858:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010385b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010385f:	c7 04 24 59 5b 10 f0 	movl   $0xf0105b59,(%esp)
f0103866:	e8 6e fd ff ff       	call   f01035d9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010386b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010386f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103873:	c7 04 24 68 5b 10 f0 	movl   $0xf0105b68,(%esp)
f010387a:	e8 5a fd ff ff       	call   f01035d9 <cprintf>
	}
}
f010387f:	83 c4 10             	add    $0x10,%esp
f0103882:	5b                   	pop    %ebx
f0103883:	5e                   	pop    %esi
f0103884:	5d                   	pop    %ebp
f0103885:	c3                   	ret    

f0103886 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103886:	55                   	push   %ebp
f0103887:	89 e5                	mov    %esp,%ebp
f0103889:	57                   	push   %edi
f010388a:	56                   	push   %esi
f010388b:	83 ec 10             	sub    $0x10,%esp
f010388e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103891:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103892:	9c                   	pushf  
f0103893:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103894:	f6 c4 02             	test   $0x2,%ah
f0103897:	74 24                	je     f01038bd <trap+0x37>
f0103899:	c7 44 24 0c 7b 5b 10 	movl   $0xf0105b7b,0xc(%esp)
f01038a0:	f0 
f01038a1:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01038a8:	f0 
f01038a9:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f01038b0:	00 
f01038b1:	c7 04 24 94 5b 10 f0 	movl   $0xf0105b94,(%esp)
f01038b8:	e8 f9 c7 ff ff       	call   f01000b6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01038bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01038c1:	c7 04 24 a0 5b 10 f0 	movl   $0xf0105ba0,(%esp)
f01038c8:	e8 0c fd ff ff       	call   f01035d9 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01038cd:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01038d1:	83 e0 03             	and    $0x3,%eax
f01038d4:	66 83 f8 03          	cmp    $0x3,%ax
f01038d8:	75 3c                	jne    f0103916 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f01038da:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f01038df:	85 c0                	test   %eax,%eax
f01038e1:	75 24                	jne    f0103907 <trap+0x81>
f01038e3:	c7 44 24 0c bb 5b 10 	movl   $0xf0105bbb,0xc(%esp)
f01038ea:	f0 
f01038eb:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f01038f2:	f0 
f01038f3:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f01038fa:	00 
f01038fb:	c7 04 24 94 5b 10 f0 	movl   $0xf0105b94,(%esp)
f0103902:	e8 af c7 ff ff       	call   f01000b6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103907:	b9 11 00 00 00       	mov    $0x11,%ecx
f010390c:	89 c7                	mov    %eax,%edi
f010390e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103910:	8b 35 c4 d0 17 f0    	mov    0xf017d0c4,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103916:	89 35 e0 d8 17 f0    	mov    %esi,0xf017d8e0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010391c:	89 34 24             	mov    %esi,(%esp)
f010391f:	e8 dd fd ff ff       	call   f0103701 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103924:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103929:	75 1c                	jne    f0103947 <trap+0xc1>
		panic("unhandled trap in kernel");
f010392b:	c7 44 24 08 c2 5b 10 	movl   $0xf0105bc2,0x8(%esp)
f0103932:	f0 
f0103933:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f010393a:	00 
f010393b:	c7 04 24 94 5b 10 f0 	movl   $0xf0105b94,(%esp)
f0103942:	e8 6f c7 ff ff       	call   f01000b6 <_panic>
	else {
		env_destroy(curenv);
f0103947:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f010394c:	89 04 24             	mov    %eax,(%esp)
f010394f:	e8 52 fb ff ff       	call   f01034a6 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103954:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f0103959:	85 c0                	test   %eax,%eax
f010395b:	74 06                	je     f0103963 <trap+0xdd>
f010395d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103961:	74 24                	je     f0103987 <trap+0x101>
f0103963:	c7 44 24 0c 20 5d 10 	movl   $0xf0105d20,0xc(%esp)
f010396a:	f0 
f010396b:	c7 44 24 08 47 56 10 	movl   $0xf0105647,0x8(%esp)
f0103972:	f0 
f0103973:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f010397a:	00 
f010397b:	c7 04 24 94 5b 10 f0 	movl   $0xf0105b94,(%esp)
f0103982:	e8 2f c7 ff ff       	call   f01000b6 <_panic>
	env_run(curenv);
f0103987:	89 04 24             	mov    %eax,(%esp)
f010398a:	e8 6e fb ff ff       	call   f01034fd <env_run>

f010398f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010398f:	55                   	push   %ebp
f0103990:	89 e5                	mov    %esp,%ebp
f0103992:	53                   	push   %ebx
f0103993:	83 ec 14             	sub    $0x14,%esp
f0103996:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103999:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010399c:	8b 53 30             	mov    0x30(%ebx),%edx
f010399f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01039a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039a7:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f01039ac:	8b 40 48             	mov    0x48(%eax),%eax
f01039af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039b3:	c7 04 24 4c 5d 10 f0 	movl   $0xf0105d4c,(%esp)
f01039ba:	e8 1a fc ff ff       	call   f01035d9 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01039bf:	89 1c 24             	mov    %ebx,(%esp)
f01039c2:	e8 3a fd ff ff       	call   f0103701 <print_trapframe>
	env_destroy(curenv);
f01039c7:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
f01039cc:	89 04 24             	mov    %eax,(%esp)
f01039cf:	e8 d2 fa ff ff       	call   f01034a6 <env_destroy>
}
f01039d4:	83 c4 14             	add    $0x14,%esp
f01039d7:	5b                   	pop    %ebx
f01039d8:	5d                   	pop    %ebp
f01039d9:	c3                   	ret    

f01039da <syscall>:
f01039da:	55                   	push   %ebp
f01039db:	89 e5                	mov    %esp,%ebp
f01039dd:	83 ec 18             	sub    $0x18,%esp
f01039e0:	c7 44 24 08 d0 5d 10 	movl   $0xf0105dd0,0x8(%esp)
f01039e7:	f0 
f01039e8:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f01039ef:	00 
f01039f0:	c7 04 24 e8 5d 10 f0 	movl   $0xf0105de8,(%esp)
f01039f7:	e8 ba c6 ff ff       	call   f01000b6 <_panic>

f01039fc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01039fc:	55                   	push   %ebp
f01039fd:	89 e5                	mov    %esp,%ebp
f01039ff:	57                   	push   %edi
f0103a00:	56                   	push   %esi
f0103a01:	53                   	push   %ebx
f0103a02:	83 ec 14             	sub    $0x14,%esp
f0103a05:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103a08:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103a0b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103a0e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103a11:	8b 1a                	mov    (%edx),%ebx
f0103a13:	8b 01                	mov    (%ecx),%eax
f0103a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a18:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103a1f:	e9 88 00 00 00       	jmp    f0103aac <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0103a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a27:	01 d8                	add    %ebx,%eax
f0103a29:	89 c7                	mov    %eax,%edi
f0103a2b:	c1 ef 1f             	shr    $0x1f,%edi
f0103a2e:	01 c7                	add    %eax,%edi
f0103a30:	d1 ff                	sar    %edi
f0103a32:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103a35:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a38:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103a3b:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103a3d:	eb 03                	jmp    f0103a42 <stab_binsearch+0x46>
			m--;
f0103a3f:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103a42:	39 c3                	cmp    %eax,%ebx
f0103a44:	7f 1f                	jg     f0103a65 <stab_binsearch+0x69>
f0103a46:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a4a:	83 ea 0c             	sub    $0xc,%edx
f0103a4d:	39 f1                	cmp    %esi,%ecx
f0103a4f:	75 ee                	jne    f0103a3f <stab_binsearch+0x43>
f0103a51:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103a54:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a57:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a5a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103a5e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103a61:	76 18                	jbe    f0103a7b <stab_binsearch+0x7f>
f0103a63:	eb 05                	jmp    f0103a6a <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103a65:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103a68:	eb 42                	jmp    f0103aac <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103a6a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103a6d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103a6f:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103a72:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a79:	eb 31                	jmp    f0103aac <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103a7b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103a7e:	73 17                	jae    f0103a97 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103a80:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103a83:	83 e8 01             	sub    $0x1,%eax
f0103a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a89:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103a8c:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103a8e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a95:	eb 15                	jmp    f0103aac <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103a97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a9a:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103a9d:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0103a9f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103aa3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103aa5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103aac:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103aaf:	0f 8e 6f ff ff ff    	jle    f0103a24 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103ab5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103ab9:	75 0f                	jne    f0103aca <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0103abb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103abe:	8b 00                	mov    (%eax),%eax
f0103ac0:	83 e8 01             	sub    $0x1,%eax
f0103ac3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103ac6:	89 07                	mov    %eax,(%edi)
f0103ac8:	eb 2c                	jmp    f0103af6 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103aca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103acd:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103acf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ad2:	8b 0f                	mov    (%edi),%ecx
f0103ad4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ad7:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103ada:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103add:	eb 03                	jmp    f0103ae2 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103adf:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103ae2:	39 c8                	cmp    %ecx,%eax
f0103ae4:	7e 0b                	jle    f0103af1 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0103ae6:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103aea:	83 ea 0c             	sub    $0xc,%edx
f0103aed:	39 f3                	cmp    %esi,%ebx
f0103aef:	75 ee                	jne    f0103adf <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103af1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103af4:	89 07                	mov    %eax,(%edi)
	}
}
f0103af6:	83 c4 14             	add    $0x14,%esp
f0103af9:	5b                   	pop    %ebx
f0103afa:	5e                   	pop    %esi
f0103afb:	5f                   	pop    %edi
f0103afc:	5d                   	pop    %ebp
f0103afd:	c3                   	ret    

f0103afe <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103afe:	55                   	push   %ebp
f0103aff:	89 e5                	mov    %esp,%ebp
f0103b01:	57                   	push   %edi
f0103b02:	56                   	push   %esi
f0103b03:	53                   	push   %ebx
f0103b04:	83 ec 3c             	sub    $0x3c,%esp
f0103b07:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103b0d:	c7 06 f7 5d 10 f0    	movl   $0xf0105df7,(%esi)
	info->eip_line = 0;
f0103b13:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103b1a:	c7 46 08 f7 5d 10 f0 	movl   $0xf0105df7,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103b21:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103b28:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103b2b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103b32:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103b38:	77 21                	ja     f0103b5b <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103b3a:	a1 00 00 20 00       	mov    0x200000,%eax
f0103b3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0103b42:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103b47:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0103b4d:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f0103b50:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0103b56:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0103b59:	eb 1a                	jmp    f0103b75 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103b5b:	c7 45 cc bf 00 11 f0 	movl   $0xf01100bf,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103b62:	c7 45 d0 4d d7 10 f0 	movl   $0xf010d74d,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103b69:	b8 4c d7 10 f0       	mov    $0xf010d74c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103b6e:	c7 45 d4 30 60 10 f0 	movl   $0xf0106030,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b75:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103b78:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0103b7b:	0f 83 2f 01 00 00    	jae    f0103cb0 <debuginfo_eip+0x1b2>
f0103b81:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103b85:	0f 85 2c 01 00 00    	jne    f0103cb7 <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103b95:	29 d8                	sub    %ebx,%eax
f0103b97:	c1 f8 02             	sar    $0x2,%eax
f0103b9a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103ba0:	83 e8 01             	sub    $0x1,%eax
f0103ba3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103ba6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103baa:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103bb1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103bb4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103bb7:	89 d8                	mov    %ebx,%eax
f0103bb9:	e8 3e fe ff ff       	call   f01039fc <stab_binsearch>
	if (lfile == 0)
f0103bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103bc1:	85 c0                	test   %eax,%eax
f0103bc3:	0f 84 f5 00 00 00    	je     f0103cbe <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103bc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103bcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bcf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103bd2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103bd6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103bdd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103be0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103be3:	89 d8                	mov    %ebx,%eax
f0103be5:	e8 12 fe ff ff       	call   f01039fc <stab_binsearch>

	if (lfun <= rfun) {
f0103bea:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103bed:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0103bf0:	7f 23                	jg     f0103c15 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103bf2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103bf5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103bf8:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103bfb:	8b 10                	mov    (%eax),%edx
f0103bfd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103c00:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f0103c03:	39 ca                	cmp    %ecx,%edx
f0103c05:	73 06                	jae    f0103c0d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103c07:	03 55 d0             	add    -0x30(%ebp),%edx
f0103c0a:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103c0d:	8b 40 08             	mov    0x8(%eax),%eax
f0103c10:	89 46 10             	mov    %eax,0x10(%esi)
f0103c13:	eb 06                	jmp    f0103c1b <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103c15:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103c18:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103c1b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103c22:	00 
f0103c23:	8b 46 08             	mov    0x8(%esi),%eax
f0103c26:	89 04 24             	mov    %eax,(%esp)
f0103c29:	e8 0d 09 00 00       	call   f010453b <strfind>
f0103c2e:	2b 46 08             	sub    0x8(%esi),%eax
f0103c31:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103c34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c37:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c3a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103c3d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103c40:	eb 06                	jmp    f0103c48 <debuginfo_eip+0x14a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103c42:	83 eb 01             	sub    $0x1,%ebx
f0103c45:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103c48:	39 fb                	cmp    %edi,%ebx
f0103c4a:	7c 2c                	jl     f0103c78 <debuginfo_eip+0x17a>
	       && stabs[lline].n_type != N_SOL
f0103c4c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0103c50:	80 fa 84             	cmp    $0x84,%dl
f0103c53:	74 0b                	je     f0103c60 <debuginfo_eip+0x162>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c55:	80 fa 64             	cmp    $0x64,%dl
f0103c58:	75 e8                	jne    f0103c42 <debuginfo_eip+0x144>
f0103c5a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103c5e:	74 e2                	je     f0103c42 <debuginfo_eip+0x144>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c63:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c66:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0103c69:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103c6c:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0103c6f:	39 d0                	cmp    %edx,%eax
f0103c71:	73 05                	jae    f0103c78 <debuginfo_eip+0x17a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c73:	03 45 d0             	add    -0x30(%ebp),%eax
f0103c76:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c78:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103c7b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c7e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c83:	39 cb                	cmp    %ecx,%ebx
f0103c85:	7d 43                	jge    f0103cca <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f0103c87:	8d 53 01             	lea    0x1(%ebx),%edx
f0103c8a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c8d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c90:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103c93:	eb 07                	jmp    f0103c9c <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103c95:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103c99:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103c9c:	39 ca                	cmp    %ecx,%edx
f0103c9e:	74 25                	je     f0103cc5 <debuginfo_eip+0x1c7>
f0103ca0:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103ca3:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103ca7:	74 ec                	je     f0103c95 <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cae:	eb 1a                	jmp    f0103cca <debuginfo_eip+0x1cc>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb5:	eb 13                	jmp    f0103cca <debuginfo_eip+0x1cc>
f0103cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cbc:	eb 0c                	jmp    f0103cca <debuginfo_eip+0x1cc>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc3:	eb 05                	jmp    f0103cca <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103cca:	83 c4 3c             	add    $0x3c,%esp
f0103ccd:	5b                   	pop    %ebx
f0103cce:	5e                   	pop    %esi
f0103ccf:	5f                   	pop    %edi
f0103cd0:	5d                   	pop    %ebp
f0103cd1:	c3                   	ret    
f0103cd2:	66 90                	xchg   %ax,%ax
f0103cd4:	66 90                	xchg   %ax,%ax
f0103cd6:	66 90                	xchg   %ax,%ax
f0103cd8:	66 90                	xchg   %ax,%ax
f0103cda:	66 90                	xchg   %ax,%ax
f0103cdc:	66 90                	xchg   %ax,%ax
f0103cde:	66 90                	xchg   %ax,%ax

f0103ce0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ce0:	55                   	push   %ebp
f0103ce1:	89 e5                	mov    %esp,%ebp
f0103ce3:	57                   	push   %edi
f0103ce4:	56                   	push   %esi
f0103ce5:	53                   	push   %ebx
f0103ce6:	83 ec 3c             	sub    $0x3c,%esp
f0103ce9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103cec:	89 d7                	mov    %edx,%edi
f0103cee:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cf1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cf7:	89 c3                	mov    %eax,%ebx
f0103cf9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103cfc:	8b 45 10             	mov    0x10(%ebp),%eax
f0103cff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103d02:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d07:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d0a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103d0d:	39 d9                	cmp    %ebx,%ecx
f0103d0f:	72 05                	jb     f0103d16 <printnum+0x36>
f0103d11:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103d14:	77 69                	ja     f0103d7f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103d16:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0103d19:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103d1d:	83 ee 01             	sub    $0x1,%esi
f0103d20:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d24:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d28:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103d2c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103d30:	89 c3                	mov    %eax,%ebx
f0103d32:	89 d6                	mov    %edx,%esi
f0103d34:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d37:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d3a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103d42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d45:	89 04 24             	mov    %eax,(%esp)
f0103d48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d4f:	e8 0c 0a 00 00       	call   f0104760 <__udivdi3>
f0103d54:	89 d9                	mov    %ebx,%ecx
f0103d56:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103d5a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d5e:	89 04 24             	mov    %eax,(%esp)
f0103d61:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d65:	89 fa                	mov    %edi,%edx
f0103d67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d6a:	e8 71 ff ff ff       	call   f0103ce0 <printnum>
f0103d6f:	eb 1b                	jmp    f0103d8c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d71:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d75:	8b 45 18             	mov    0x18(%ebp),%eax
f0103d78:	89 04 24             	mov    %eax,(%esp)
f0103d7b:	ff d3                	call   *%ebx
f0103d7d:	eb 03                	jmp    f0103d82 <printnum+0xa2>
f0103d7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d82:	83 ee 01             	sub    $0x1,%esi
f0103d85:	85 f6                	test   %esi,%esi
f0103d87:	7f e8                	jg     f0103d71 <printnum+0x91>
f0103d89:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d90:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103d94:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103d97:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d9a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d9e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103da5:	89 04 24             	mov    %eax,(%esp)
f0103da8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103dab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103daf:	e8 dc 0a 00 00       	call   f0104890 <__umoddi3>
f0103db4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103db8:	0f be 80 01 5e 10 f0 	movsbl -0xfefa1ff(%eax),%eax
f0103dbf:	89 04 24             	mov    %eax,(%esp)
f0103dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103dc5:	ff d0                	call   *%eax
}
f0103dc7:	83 c4 3c             	add    $0x3c,%esp
f0103dca:	5b                   	pop    %ebx
f0103dcb:	5e                   	pop    %esi
f0103dcc:	5f                   	pop    %edi
f0103dcd:	5d                   	pop    %ebp
f0103dce:	c3                   	ret    

f0103dcf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103dcf:	55                   	push   %ebp
f0103dd0:	89 e5                	mov    %esp,%ebp
f0103dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103dd5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103dd9:	8b 10                	mov    (%eax),%edx
f0103ddb:	3b 50 04             	cmp    0x4(%eax),%edx
f0103dde:	73 0a                	jae    f0103dea <sprintputch+0x1b>
		*b->buf++ = ch;
f0103de0:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103de3:	89 08                	mov    %ecx,(%eax)
f0103de5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103de8:	88 02                	mov    %al,(%edx)
}
f0103dea:	5d                   	pop    %ebp
f0103deb:	c3                   	ret    

f0103dec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103dec:	55                   	push   %ebp
f0103ded:	89 e5                	mov    %esp,%ebp
f0103def:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103df2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103df5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103df9:	8b 45 10             	mov    0x10(%ebp),%eax
f0103dfc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e0a:	89 04 24             	mov    %eax,(%esp)
f0103e0d:	e8 02 00 00 00       	call   f0103e14 <vprintfmt>
	va_end(ap);
}
f0103e12:	c9                   	leave  
f0103e13:	c3                   	ret    

f0103e14 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103e14:	55                   	push   %ebp
f0103e15:	89 e5                	mov    %esp,%ebp
f0103e17:	57                   	push   %edi
f0103e18:	56                   	push   %esi
f0103e19:	53                   	push   %ebx
f0103e1a:	83 ec 3c             	sub    $0x3c,%esp
f0103e1d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e23:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103e26:	eb 11                	jmp    f0103e39 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103e28:	85 c0                	test   %eax,%eax
f0103e2a:	0f 84 48 04 00 00    	je     f0104278 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0103e30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e34:	89 04 24             	mov    %eax,(%esp)
f0103e37:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103e39:	83 c7 01             	add    $0x1,%edi
f0103e3c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e40:	83 f8 25             	cmp    $0x25,%eax
f0103e43:	75 e3                	jne    f0103e28 <vprintfmt+0x14>
f0103e45:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103e49:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103e50:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103e57:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e63:	eb 1f                	jmp    f0103e84 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e65:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103e68:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103e6c:	eb 16                	jmp    f0103e84 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e71:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e75:	eb 0d                	jmp    f0103e84 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103e77:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e7d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e84:	8d 47 01             	lea    0x1(%edi),%eax
f0103e87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e8a:	0f b6 17             	movzbl (%edi),%edx
f0103e8d:	0f b6 c2             	movzbl %dl,%eax
f0103e90:	83 ea 23             	sub    $0x23,%edx
f0103e93:	80 fa 55             	cmp    $0x55,%dl
f0103e96:	0f 87 bf 03 00 00    	ja     f010425b <vprintfmt+0x447>
f0103e9c:	0f b6 d2             	movzbl %dl,%edx
f0103e9f:	ff 24 95 a0 5e 10 f0 	jmp    *-0xfefa160(,%edx,4)
f0103ea6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ea9:	ba 00 00 00 00       	mov    $0x0,%edx
f0103eae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103eb1:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103eb4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103eb8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103ebb:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103ebe:	83 f9 09             	cmp    $0x9,%ecx
f0103ec1:	77 3c                	ja     f0103eff <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103ec3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103ec6:	eb e9                	jmp    f0103eb1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103ec8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ecb:	8b 00                	mov    (%eax),%eax
f0103ecd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ed0:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ed3:	8d 40 04             	lea    0x4(%eax),%eax
f0103ed6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ed9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103edc:	eb 27                	jmp    f0103f05 <vprintfmt+0xf1>
f0103ede:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103ee1:	85 d2                	test   %edx,%edx
f0103ee3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ee8:	0f 49 c2             	cmovns %edx,%eax
f0103eeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ef1:	eb 91                	jmp    f0103e84 <vprintfmt+0x70>
f0103ef3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103ef6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103efd:	eb 85                	jmp    f0103e84 <vprintfmt+0x70>
f0103eff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103f02:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103f05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103f09:	0f 89 75 ff ff ff    	jns    f0103e84 <vprintfmt+0x70>
f0103f0f:	e9 63 ff ff ff       	jmp    f0103e77 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103f14:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103f1a:	e9 65 ff ff ff       	jmp    f0103e84 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f1f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103f22:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f2a:	8b 00                	mov    (%eax),%eax
f0103f2c:	89 04 24             	mov    %eax,(%esp)
f0103f2f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103f34:	e9 00 ff ff ff       	jmp    f0103e39 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f39:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f3c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103f40:	8b 00                	mov    (%eax),%eax
f0103f42:	99                   	cltd   
f0103f43:	31 d0                	xor    %edx,%eax
f0103f45:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f47:	83 f8 07             	cmp    $0x7,%eax
f0103f4a:	7f 0b                	jg     f0103f57 <vprintfmt+0x143>
f0103f4c:	8b 14 85 00 60 10 f0 	mov    -0xfefa000(,%eax,4),%edx
f0103f53:	85 d2                	test   %edx,%edx
f0103f55:	75 20                	jne    f0103f77 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0103f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f5b:	c7 44 24 08 19 5e 10 	movl   $0xf0105e19,0x8(%esp)
f0103f62:	f0 
f0103f63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f67:	89 34 24             	mov    %esi,(%esp)
f0103f6a:	e8 7d fe ff ff       	call   f0103dec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103f72:	e9 c2 fe ff ff       	jmp    f0103e39 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103f77:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f7b:	c7 44 24 08 59 56 10 	movl   $0xf0105659,0x8(%esp)
f0103f82:	f0 
f0103f83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f87:	89 34 24             	mov    %esi,(%esp)
f0103f8a:	e8 5d fe ff ff       	call   f0103dec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f92:	e9 a2 fe ff ff       	jmp    f0103e39 <vprintfmt+0x25>
f0103f97:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f9a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103f9d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103fa0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103fa3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103fa7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103fa9:	85 ff                	test   %edi,%edi
f0103fab:	b8 12 5e 10 f0       	mov    $0xf0105e12,%eax
f0103fb0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103fb3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103fb7:	0f 84 92 00 00 00    	je     f010404f <vprintfmt+0x23b>
f0103fbd:	85 c9                	test   %ecx,%ecx
f0103fbf:	0f 8e 98 00 00 00    	jle    f010405d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fc5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fc9:	89 3c 24             	mov    %edi,(%esp)
f0103fcc:	e8 17 04 00 00       	call   f01043e8 <strnlen>
f0103fd1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103fd4:	29 c1                	sub    %eax,%ecx
f0103fd6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0103fd9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103fdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103fe0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103fe3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fe5:	eb 0f                	jmp    f0103ff6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0103fe7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103feb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103fee:	89 04 24             	mov    %eax,(%esp)
f0103ff1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ff3:	83 ef 01             	sub    $0x1,%edi
f0103ff6:	85 ff                	test   %edi,%edi
f0103ff8:	7f ed                	jg     f0103fe7 <vprintfmt+0x1d3>
f0103ffa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103ffd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104000:	85 c9                	test   %ecx,%ecx
f0104002:	b8 00 00 00 00       	mov    $0x0,%eax
f0104007:	0f 49 c1             	cmovns %ecx,%eax
f010400a:	29 c1                	sub    %eax,%ecx
f010400c:	89 75 08             	mov    %esi,0x8(%ebp)
f010400f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104012:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104015:	89 cb                	mov    %ecx,%ebx
f0104017:	eb 50                	jmp    f0104069 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104019:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010401d:	74 1e                	je     f010403d <vprintfmt+0x229>
f010401f:	0f be d2             	movsbl %dl,%edx
f0104022:	83 ea 20             	sub    $0x20,%edx
f0104025:	83 fa 5e             	cmp    $0x5e,%edx
f0104028:	76 13                	jbe    f010403d <vprintfmt+0x229>
					putch('?', putdat);
f010402a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010402d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104031:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104038:	ff 55 08             	call   *0x8(%ebp)
f010403b:	eb 0d                	jmp    f010404a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f010403d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104040:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104044:	89 04 24             	mov    %eax,(%esp)
f0104047:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010404a:	83 eb 01             	sub    $0x1,%ebx
f010404d:	eb 1a                	jmp    f0104069 <vprintfmt+0x255>
f010404f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104052:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104055:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104058:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010405b:	eb 0c                	jmp    f0104069 <vprintfmt+0x255>
f010405d:	89 75 08             	mov    %esi,0x8(%ebp)
f0104060:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104063:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104066:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104069:	83 c7 01             	add    $0x1,%edi
f010406c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104070:	0f be c2             	movsbl %dl,%eax
f0104073:	85 c0                	test   %eax,%eax
f0104075:	74 25                	je     f010409c <vprintfmt+0x288>
f0104077:	85 f6                	test   %esi,%esi
f0104079:	78 9e                	js     f0104019 <vprintfmt+0x205>
f010407b:	83 ee 01             	sub    $0x1,%esi
f010407e:	79 99                	jns    f0104019 <vprintfmt+0x205>
f0104080:	89 df                	mov    %ebx,%edi
f0104082:	8b 75 08             	mov    0x8(%ebp),%esi
f0104085:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104088:	eb 1a                	jmp    f01040a4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010408a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010408e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104095:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104097:	83 ef 01             	sub    $0x1,%edi
f010409a:	eb 08                	jmp    f01040a4 <vprintfmt+0x290>
f010409c:	89 df                	mov    %ebx,%edi
f010409e:	8b 75 08             	mov    0x8(%ebp),%esi
f01040a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01040a4:	85 ff                	test   %edi,%edi
f01040a6:	7f e2                	jg     f010408a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01040ab:	e9 89 fd ff ff       	jmp    f0103e39 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01040b0:	83 f9 01             	cmp    $0x1,%ecx
f01040b3:	7e 19                	jle    f01040ce <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f01040b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01040b8:	8b 50 04             	mov    0x4(%eax),%edx
f01040bb:	8b 00                	mov    (%eax),%eax
f01040bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01040c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01040c6:	8d 40 08             	lea    0x8(%eax),%eax
f01040c9:	89 45 14             	mov    %eax,0x14(%ebp)
f01040cc:	eb 38                	jmp    f0104106 <vprintfmt+0x2f2>
	else if (lflag)
f01040ce:	85 c9                	test   %ecx,%ecx
f01040d0:	74 1b                	je     f01040ed <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f01040d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01040d5:	8b 00                	mov    (%eax),%eax
f01040d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040da:	89 c1                	mov    %eax,%ecx
f01040dc:	c1 f9 1f             	sar    $0x1f,%ecx
f01040df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01040e5:	8d 40 04             	lea    0x4(%eax),%eax
f01040e8:	89 45 14             	mov    %eax,0x14(%ebp)
f01040eb:	eb 19                	jmp    f0104106 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f01040ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01040f0:	8b 00                	mov    (%eax),%eax
f01040f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040f5:	89 c1                	mov    %eax,%ecx
f01040f7:	c1 f9 1f             	sar    $0x1f,%ecx
f01040fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104100:	8d 40 04             	lea    0x4(%eax),%eax
f0104103:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104106:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104109:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010410c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104111:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104115:	0f 89 04 01 00 00    	jns    f010421f <vprintfmt+0x40b>
				putch('-', putdat);
f010411b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010411f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104126:	ff d6                	call   *%esi
				num = -(long long) num;
f0104128:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010412b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010412e:	f7 da                	neg    %edx
f0104130:	83 d1 00             	adc    $0x0,%ecx
f0104133:	f7 d9                	neg    %ecx
f0104135:	e9 e5 00 00 00       	jmp    f010421f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010413a:	83 f9 01             	cmp    $0x1,%ecx
f010413d:	7e 10                	jle    f010414f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f010413f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104142:	8b 10                	mov    (%eax),%edx
f0104144:	8b 48 04             	mov    0x4(%eax),%ecx
f0104147:	8d 40 08             	lea    0x8(%eax),%eax
f010414a:	89 45 14             	mov    %eax,0x14(%ebp)
f010414d:	eb 26                	jmp    f0104175 <vprintfmt+0x361>
	else if (lflag)
f010414f:	85 c9                	test   %ecx,%ecx
f0104151:	74 12                	je     f0104165 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0104153:	8b 45 14             	mov    0x14(%ebp),%eax
f0104156:	8b 10                	mov    (%eax),%edx
f0104158:	b9 00 00 00 00       	mov    $0x0,%ecx
f010415d:	8d 40 04             	lea    0x4(%eax),%eax
f0104160:	89 45 14             	mov    %eax,0x14(%ebp)
f0104163:	eb 10                	jmp    f0104175 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0104165:	8b 45 14             	mov    0x14(%ebp),%eax
f0104168:	8b 10                	mov    (%eax),%edx
f010416a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010416f:	8d 40 04             	lea    0x4(%eax),%eax
f0104172:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104175:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010417a:	e9 a0 00 00 00       	jmp    f010421f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010417f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104183:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010418a:	ff d6                	call   *%esi
			putch('X', putdat);
f010418c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104190:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104197:	ff d6                	call   *%esi
			putch('X', putdat);
f0104199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010419d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01041a4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01041a9:	e9 8b fc ff ff       	jmp    f0103e39 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f01041ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01041b9:	ff d6                	call   *%esi
			putch('x', putdat);
f01041bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01041c6:	ff d6                	call   *%esi
			num = (unsigned long long)
f01041c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041cb:	8b 10                	mov    (%eax),%edx
f01041cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f01041d2:	8d 40 04             	lea    0x4(%eax),%eax
f01041d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041d8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01041dd:	eb 40                	jmp    f010421f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01041df:	83 f9 01             	cmp    $0x1,%ecx
f01041e2:	7e 10                	jle    f01041f4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f01041e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01041e7:	8b 10                	mov    (%eax),%edx
f01041e9:	8b 48 04             	mov    0x4(%eax),%ecx
f01041ec:	8d 40 08             	lea    0x8(%eax),%eax
f01041ef:	89 45 14             	mov    %eax,0x14(%ebp)
f01041f2:	eb 26                	jmp    f010421a <vprintfmt+0x406>
	else if (lflag)
f01041f4:	85 c9                	test   %ecx,%ecx
f01041f6:	74 12                	je     f010420a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01041f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041fb:	8b 10                	mov    (%eax),%edx
f01041fd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104202:	8d 40 04             	lea    0x4(%eax),%eax
f0104205:	89 45 14             	mov    %eax,0x14(%ebp)
f0104208:	eb 10                	jmp    f010421a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f010420a:	8b 45 14             	mov    0x14(%ebp),%eax
f010420d:	8b 10                	mov    (%eax),%edx
f010420f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104214:	8d 40 04             	lea    0x4(%eax),%eax
f0104217:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010421a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f010421f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104223:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104227:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010422a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010422e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104232:	89 14 24             	mov    %edx,(%esp)
f0104235:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104239:	89 da                	mov    %ebx,%edx
f010423b:	89 f0                	mov    %esi,%eax
f010423d:	e8 9e fa ff ff       	call   f0103ce0 <printnum>
			break;
f0104242:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104245:	e9 ef fb ff ff       	jmp    f0103e39 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010424a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010424e:	89 04 24             	mov    %eax,(%esp)
f0104251:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104253:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104256:	e9 de fb ff ff       	jmp    f0103e39 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010425b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010425f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104266:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104268:	eb 03                	jmp    f010426d <vprintfmt+0x459>
f010426a:	83 ef 01             	sub    $0x1,%edi
f010426d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104271:	75 f7                	jne    f010426a <vprintfmt+0x456>
f0104273:	e9 c1 fb ff ff       	jmp    f0103e39 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104278:	83 c4 3c             	add    $0x3c,%esp
f010427b:	5b                   	pop    %ebx
f010427c:	5e                   	pop    %esi
f010427d:	5f                   	pop    %edi
f010427e:	5d                   	pop    %ebp
f010427f:	c3                   	ret    

f0104280 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104280:	55                   	push   %ebp
f0104281:	89 e5                	mov    %esp,%ebp
f0104283:	83 ec 28             	sub    $0x28,%esp
f0104286:	8b 45 08             	mov    0x8(%ebp),%eax
f0104289:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010428c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010428f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104293:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104296:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010429d:	85 c0                	test   %eax,%eax
f010429f:	74 30                	je     f01042d1 <vsnprintf+0x51>
f01042a1:	85 d2                	test   %edx,%edx
f01042a3:	7e 2c                	jle    f01042d1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01042a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01042a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01042af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01042b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042ba:	c7 04 24 cf 3d 10 f0 	movl   $0xf0103dcf,(%esp)
f01042c1:	e8 4e fb ff ff       	call   f0103e14 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01042c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01042c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01042cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01042cf:	eb 05                	jmp    f01042d6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01042d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01042d6:	c9                   	leave  
f01042d7:	c3                   	ret    

f01042d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01042d8:	55                   	push   %ebp
f01042d9:	89 e5                	mov    %esp,%ebp
f01042db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01042de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01042e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042e5:	8b 45 10             	mov    0x10(%ebp),%eax
f01042e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01042f6:	89 04 24             	mov    %eax,(%esp)
f01042f9:	e8 82 ff ff ff       	call   f0104280 <vsnprintf>
	va_end(ap);

	return rc;
}
f01042fe:	c9                   	leave  
f01042ff:	c3                   	ret    

f0104300 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104300:	55                   	push   %ebp
f0104301:	89 e5                	mov    %esp,%ebp
f0104303:	57                   	push   %edi
f0104304:	56                   	push   %esi
f0104305:	53                   	push   %ebx
f0104306:	83 ec 1c             	sub    $0x1c,%esp
f0104309:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010430c:	85 c0                	test   %eax,%eax
f010430e:	74 10                	je     f0104320 <readline+0x20>
		cprintf("%s", prompt);
f0104310:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104314:	c7 04 24 59 56 10 f0 	movl   $0xf0105659,(%esp)
f010431b:	e8 b9 f2 ff ff       	call   f01035d9 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104327:	e8 06 c3 ff ff       	call   f0100632 <iscons>
f010432c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010432e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104333:	e8 e9 c2 ff ff       	call   f0100621 <getchar>
f0104338:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010433a:	85 c0                	test   %eax,%eax
f010433c:	79 17                	jns    f0104355 <readline+0x55>
			cprintf("read error: %e\n", c);
f010433e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104342:	c7 04 24 20 60 10 f0 	movl   $0xf0106020,(%esp)
f0104349:	e8 8b f2 ff ff       	call   f01035d9 <cprintf>
			return NULL;
f010434e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104353:	eb 6d                	jmp    f01043c2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104355:	83 f8 7f             	cmp    $0x7f,%eax
f0104358:	74 05                	je     f010435f <readline+0x5f>
f010435a:	83 f8 08             	cmp    $0x8,%eax
f010435d:	75 19                	jne    f0104378 <readline+0x78>
f010435f:	85 f6                	test   %esi,%esi
f0104361:	7e 15                	jle    f0104378 <readline+0x78>
			if (echoing)
f0104363:	85 ff                	test   %edi,%edi
f0104365:	74 0c                	je     f0104373 <readline+0x73>
				cputchar('\b');
f0104367:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010436e:	e8 9e c2 ff ff       	call   f0100611 <cputchar>
			i--;
f0104373:	83 ee 01             	sub    $0x1,%esi
f0104376:	eb bb                	jmp    f0104333 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104378:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010437e:	7f 1c                	jg     f010439c <readline+0x9c>
f0104380:	83 fb 1f             	cmp    $0x1f,%ebx
f0104383:	7e 17                	jle    f010439c <readline+0x9c>
			if (echoing)
f0104385:	85 ff                	test   %edi,%edi
f0104387:	74 08                	je     f0104391 <readline+0x91>
				cputchar(c);
f0104389:	89 1c 24             	mov    %ebx,(%esp)
f010438c:	e8 80 c2 ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f0104391:	88 9e 80 d9 17 f0    	mov    %bl,-0xfe82680(%esi)
f0104397:	8d 76 01             	lea    0x1(%esi),%esi
f010439a:	eb 97                	jmp    f0104333 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010439c:	83 fb 0d             	cmp    $0xd,%ebx
f010439f:	74 05                	je     f01043a6 <readline+0xa6>
f01043a1:	83 fb 0a             	cmp    $0xa,%ebx
f01043a4:	75 8d                	jne    f0104333 <readline+0x33>
			if (echoing)
f01043a6:	85 ff                	test   %edi,%edi
f01043a8:	74 0c                	je     f01043b6 <readline+0xb6>
				cputchar('\n');
f01043aa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01043b1:	e8 5b c2 ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f01043b6:	c6 86 80 d9 17 f0 00 	movb   $0x0,-0xfe82680(%esi)
			return buf;
f01043bd:	b8 80 d9 17 f0       	mov    $0xf017d980,%eax
		}
	}
}
f01043c2:	83 c4 1c             	add    $0x1c,%esp
f01043c5:	5b                   	pop    %ebx
f01043c6:	5e                   	pop    %esi
f01043c7:	5f                   	pop    %edi
f01043c8:	5d                   	pop    %ebp
f01043c9:	c3                   	ret    
f01043ca:	66 90                	xchg   %ax,%ax
f01043cc:	66 90                	xchg   %ax,%ax
f01043ce:	66 90                	xchg   %ax,%ax

f01043d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01043d0:	55                   	push   %ebp
f01043d1:	89 e5                	mov    %esp,%ebp
f01043d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01043d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01043db:	eb 03                	jmp    f01043e0 <strlen+0x10>
		n++;
f01043dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01043e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01043e4:	75 f7                	jne    f01043dd <strlen+0xd>
		n++;
	return n;
}
f01043e6:	5d                   	pop    %ebp
f01043e7:	c3                   	ret    

f01043e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01043e8:	55                   	push   %ebp
f01043e9:	89 e5                	mov    %esp,%ebp
f01043eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01043f6:	eb 03                	jmp    f01043fb <strnlen+0x13>
		n++;
f01043f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043fb:	39 d0                	cmp    %edx,%eax
f01043fd:	74 06                	je     f0104405 <strnlen+0x1d>
f01043ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104403:	75 f3                	jne    f01043f8 <strnlen+0x10>
		n++;
	return n;
}
f0104405:	5d                   	pop    %ebp
f0104406:	c3                   	ret    

f0104407 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104407:	55                   	push   %ebp
f0104408:	89 e5                	mov    %esp,%ebp
f010440a:	53                   	push   %ebx
f010440b:	8b 45 08             	mov    0x8(%ebp),%eax
f010440e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104411:	89 c2                	mov    %eax,%edx
f0104413:	83 c2 01             	add    $0x1,%edx
f0104416:	83 c1 01             	add    $0x1,%ecx
f0104419:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010441d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104420:	84 db                	test   %bl,%bl
f0104422:	75 ef                	jne    f0104413 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104424:	5b                   	pop    %ebx
f0104425:	5d                   	pop    %ebp
f0104426:	c3                   	ret    

f0104427 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104427:	55                   	push   %ebp
f0104428:	89 e5                	mov    %esp,%ebp
f010442a:	53                   	push   %ebx
f010442b:	83 ec 08             	sub    $0x8,%esp
f010442e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104431:	89 1c 24             	mov    %ebx,(%esp)
f0104434:	e8 97 ff ff ff       	call   f01043d0 <strlen>
	strcpy(dst + len, src);
f0104439:	8b 55 0c             	mov    0xc(%ebp),%edx
f010443c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104440:	01 d8                	add    %ebx,%eax
f0104442:	89 04 24             	mov    %eax,(%esp)
f0104445:	e8 bd ff ff ff       	call   f0104407 <strcpy>
	return dst;
}
f010444a:	89 d8                	mov    %ebx,%eax
f010444c:	83 c4 08             	add    $0x8,%esp
f010444f:	5b                   	pop    %ebx
f0104450:	5d                   	pop    %ebp
f0104451:	c3                   	ret    

f0104452 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	56                   	push   %esi
f0104456:	53                   	push   %ebx
f0104457:	8b 75 08             	mov    0x8(%ebp),%esi
f010445a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010445d:	89 f3                	mov    %esi,%ebx
f010445f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104462:	89 f2                	mov    %esi,%edx
f0104464:	eb 0f                	jmp    f0104475 <strncpy+0x23>
		*dst++ = *src;
f0104466:	83 c2 01             	add    $0x1,%edx
f0104469:	0f b6 01             	movzbl (%ecx),%eax
f010446c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010446f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104472:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104475:	39 da                	cmp    %ebx,%edx
f0104477:	75 ed                	jne    f0104466 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104479:	89 f0                	mov    %esi,%eax
f010447b:	5b                   	pop    %ebx
f010447c:	5e                   	pop    %esi
f010447d:	5d                   	pop    %ebp
f010447e:	c3                   	ret    

f010447f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010447f:	55                   	push   %ebp
f0104480:	89 e5                	mov    %esp,%ebp
f0104482:	56                   	push   %esi
f0104483:	53                   	push   %ebx
f0104484:	8b 75 08             	mov    0x8(%ebp),%esi
f0104487:	8b 55 0c             	mov    0xc(%ebp),%edx
f010448a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010448d:	89 f0                	mov    %esi,%eax
f010448f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104493:	85 c9                	test   %ecx,%ecx
f0104495:	75 0b                	jne    f01044a2 <strlcpy+0x23>
f0104497:	eb 1d                	jmp    f01044b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104499:	83 c0 01             	add    $0x1,%eax
f010449c:	83 c2 01             	add    $0x1,%edx
f010449f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01044a2:	39 d8                	cmp    %ebx,%eax
f01044a4:	74 0b                	je     f01044b1 <strlcpy+0x32>
f01044a6:	0f b6 0a             	movzbl (%edx),%ecx
f01044a9:	84 c9                	test   %cl,%cl
f01044ab:	75 ec                	jne    f0104499 <strlcpy+0x1a>
f01044ad:	89 c2                	mov    %eax,%edx
f01044af:	eb 02                	jmp    f01044b3 <strlcpy+0x34>
f01044b1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01044b3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01044b6:	29 f0                	sub    %esi,%eax
}
f01044b8:	5b                   	pop    %ebx
f01044b9:	5e                   	pop    %esi
f01044ba:	5d                   	pop    %ebp
f01044bb:	c3                   	ret    

f01044bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01044bc:	55                   	push   %ebp
f01044bd:	89 e5                	mov    %esp,%ebp
f01044bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01044c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01044c5:	eb 06                	jmp    f01044cd <strcmp+0x11>
		p++, q++;
f01044c7:	83 c1 01             	add    $0x1,%ecx
f01044ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01044cd:	0f b6 01             	movzbl (%ecx),%eax
f01044d0:	84 c0                	test   %al,%al
f01044d2:	74 04                	je     f01044d8 <strcmp+0x1c>
f01044d4:	3a 02                	cmp    (%edx),%al
f01044d6:	74 ef                	je     f01044c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01044d8:	0f b6 c0             	movzbl %al,%eax
f01044db:	0f b6 12             	movzbl (%edx),%edx
f01044de:	29 d0                	sub    %edx,%eax
}
f01044e0:	5d                   	pop    %ebp
f01044e1:	c3                   	ret    

f01044e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01044e2:	55                   	push   %ebp
f01044e3:	89 e5                	mov    %esp,%ebp
f01044e5:	53                   	push   %ebx
f01044e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044ec:	89 c3                	mov    %eax,%ebx
f01044ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01044f1:	eb 06                	jmp    f01044f9 <strncmp+0x17>
		n--, p++, q++;
f01044f3:	83 c0 01             	add    $0x1,%eax
f01044f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01044f9:	39 d8                	cmp    %ebx,%eax
f01044fb:	74 15                	je     f0104512 <strncmp+0x30>
f01044fd:	0f b6 08             	movzbl (%eax),%ecx
f0104500:	84 c9                	test   %cl,%cl
f0104502:	74 04                	je     f0104508 <strncmp+0x26>
f0104504:	3a 0a                	cmp    (%edx),%cl
f0104506:	74 eb                	je     f01044f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104508:	0f b6 00             	movzbl (%eax),%eax
f010450b:	0f b6 12             	movzbl (%edx),%edx
f010450e:	29 d0                	sub    %edx,%eax
f0104510:	eb 05                	jmp    f0104517 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104512:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104517:	5b                   	pop    %ebx
f0104518:	5d                   	pop    %ebp
f0104519:	c3                   	ret    

f010451a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010451a:	55                   	push   %ebp
f010451b:	89 e5                	mov    %esp,%ebp
f010451d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104520:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104524:	eb 07                	jmp    f010452d <strchr+0x13>
		if (*s == c)
f0104526:	38 ca                	cmp    %cl,%dl
f0104528:	74 0f                	je     f0104539 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010452a:	83 c0 01             	add    $0x1,%eax
f010452d:	0f b6 10             	movzbl (%eax),%edx
f0104530:	84 d2                	test   %dl,%dl
f0104532:	75 f2                	jne    f0104526 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104534:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104539:	5d                   	pop    %ebp
f010453a:	c3                   	ret    

f010453b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010453b:	55                   	push   %ebp
f010453c:	89 e5                	mov    %esp,%ebp
f010453e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104541:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104545:	eb 07                	jmp    f010454e <strfind+0x13>
		if (*s == c)
f0104547:	38 ca                	cmp    %cl,%dl
f0104549:	74 0a                	je     f0104555 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010454b:	83 c0 01             	add    $0x1,%eax
f010454e:	0f b6 10             	movzbl (%eax),%edx
f0104551:	84 d2                	test   %dl,%dl
f0104553:	75 f2                	jne    f0104547 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0104555:	5d                   	pop    %ebp
f0104556:	c3                   	ret    

f0104557 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104557:	55                   	push   %ebp
f0104558:	89 e5                	mov    %esp,%ebp
f010455a:	57                   	push   %edi
f010455b:	56                   	push   %esi
f010455c:	53                   	push   %ebx
f010455d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104560:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104563:	85 c9                	test   %ecx,%ecx
f0104565:	74 36                	je     f010459d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104567:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010456d:	75 28                	jne    f0104597 <memset+0x40>
f010456f:	f6 c1 03             	test   $0x3,%cl
f0104572:	75 23                	jne    f0104597 <memset+0x40>
		c &= 0xFF;
f0104574:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104578:	89 d3                	mov    %edx,%ebx
f010457a:	c1 e3 08             	shl    $0x8,%ebx
f010457d:	89 d6                	mov    %edx,%esi
f010457f:	c1 e6 18             	shl    $0x18,%esi
f0104582:	89 d0                	mov    %edx,%eax
f0104584:	c1 e0 10             	shl    $0x10,%eax
f0104587:	09 f0                	or     %esi,%eax
f0104589:	09 c2                	or     %eax,%edx
f010458b:	89 d0                	mov    %edx,%eax
f010458d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010458f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104592:	fc                   	cld    
f0104593:	f3 ab                	rep stos %eax,%es:(%edi)
f0104595:	eb 06                	jmp    f010459d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104597:	8b 45 0c             	mov    0xc(%ebp),%eax
f010459a:	fc                   	cld    
f010459b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010459d:	89 f8                	mov    %edi,%eax
f010459f:	5b                   	pop    %ebx
f01045a0:	5e                   	pop    %esi
f01045a1:	5f                   	pop    %edi
f01045a2:	5d                   	pop    %ebp
f01045a3:	c3                   	ret    

f01045a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01045a4:	55                   	push   %ebp
f01045a5:	89 e5                	mov    %esp,%ebp
f01045a7:	57                   	push   %edi
f01045a8:	56                   	push   %esi
f01045a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01045af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01045b2:	39 c6                	cmp    %eax,%esi
f01045b4:	73 35                	jae    f01045eb <memmove+0x47>
f01045b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01045b9:	39 d0                	cmp    %edx,%eax
f01045bb:	73 2e                	jae    f01045eb <memmove+0x47>
		s += n;
		d += n;
f01045bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01045c0:	89 d6                	mov    %edx,%esi
f01045c2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01045ca:	75 13                	jne    f01045df <memmove+0x3b>
f01045cc:	f6 c1 03             	test   $0x3,%cl
f01045cf:	75 0e                	jne    f01045df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01045d1:	83 ef 04             	sub    $0x4,%edi
f01045d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01045d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01045da:	fd                   	std    
f01045db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045dd:	eb 09                	jmp    f01045e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01045df:	83 ef 01             	sub    $0x1,%edi
f01045e2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01045e5:	fd                   	std    
f01045e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01045e8:	fc                   	cld    
f01045e9:	eb 1d                	jmp    f0104608 <memmove+0x64>
f01045eb:	89 f2                	mov    %esi,%edx
f01045ed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045ef:	f6 c2 03             	test   $0x3,%dl
f01045f2:	75 0f                	jne    f0104603 <memmove+0x5f>
f01045f4:	f6 c1 03             	test   $0x3,%cl
f01045f7:	75 0a                	jne    f0104603 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01045f9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01045fc:	89 c7                	mov    %eax,%edi
f01045fe:	fc                   	cld    
f01045ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104601:	eb 05                	jmp    f0104608 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104603:	89 c7                	mov    %eax,%edi
f0104605:	fc                   	cld    
f0104606:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104608:	5e                   	pop    %esi
f0104609:	5f                   	pop    %edi
f010460a:	5d                   	pop    %ebp
f010460b:	c3                   	ret    

f010460c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010460c:	55                   	push   %ebp
f010460d:	89 e5                	mov    %esp,%ebp
f010460f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104612:	8b 45 10             	mov    0x10(%ebp),%eax
f0104615:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104619:	8b 45 0c             	mov    0xc(%ebp),%eax
f010461c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104620:	8b 45 08             	mov    0x8(%ebp),%eax
f0104623:	89 04 24             	mov    %eax,(%esp)
f0104626:	e8 79 ff ff ff       	call   f01045a4 <memmove>
}
f010462b:	c9                   	leave  
f010462c:	c3                   	ret    

f010462d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010462d:	55                   	push   %ebp
f010462e:	89 e5                	mov    %esp,%ebp
f0104630:	56                   	push   %esi
f0104631:	53                   	push   %ebx
f0104632:	8b 55 08             	mov    0x8(%ebp),%edx
f0104635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104638:	89 d6                	mov    %edx,%esi
f010463a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010463d:	eb 1a                	jmp    f0104659 <memcmp+0x2c>
		if (*s1 != *s2)
f010463f:	0f b6 02             	movzbl (%edx),%eax
f0104642:	0f b6 19             	movzbl (%ecx),%ebx
f0104645:	38 d8                	cmp    %bl,%al
f0104647:	74 0a                	je     f0104653 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104649:	0f b6 c0             	movzbl %al,%eax
f010464c:	0f b6 db             	movzbl %bl,%ebx
f010464f:	29 d8                	sub    %ebx,%eax
f0104651:	eb 0f                	jmp    f0104662 <memcmp+0x35>
		s1++, s2++;
f0104653:	83 c2 01             	add    $0x1,%edx
f0104656:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104659:	39 f2                	cmp    %esi,%edx
f010465b:	75 e2                	jne    f010463f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010465d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104662:	5b                   	pop    %ebx
f0104663:	5e                   	pop    %esi
f0104664:	5d                   	pop    %ebp
f0104665:	c3                   	ret    

f0104666 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104666:	55                   	push   %ebp
f0104667:	89 e5                	mov    %esp,%ebp
f0104669:	8b 45 08             	mov    0x8(%ebp),%eax
f010466c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010466f:	89 c2                	mov    %eax,%edx
f0104671:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104674:	eb 07                	jmp    f010467d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104676:	38 08                	cmp    %cl,(%eax)
f0104678:	74 07                	je     f0104681 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010467a:	83 c0 01             	add    $0x1,%eax
f010467d:	39 d0                	cmp    %edx,%eax
f010467f:	72 f5                	jb     f0104676 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104681:	5d                   	pop    %ebp
f0104682:	c3                   	ret    

f0104683 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104683:	55                   	push   %ebp
f0104684:	89 e5                	mov    %esp,%ebp
f0104686:	57                   	push   %edi
f0104687:	56                   	push   %esi
f0104688:	53                   	push   %ebx
f0104689:	8b 55 08             	mov    0x8(%ebp),%edx
f010468c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010468f:	eb 03                	jmp    f0104694 <strtol+0x11>
		s++;
f0104691:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104694:	0f b6 0a             	movzbl (%edx),%ecx
f0104697:	80 f9 09             	cmp    $0x9,%cl
f010469a:	74 f5                	je     f0104691 <strtol+0xe>
f010469c:	80 f9 20             	cmp    $0x20,%cl
f010469f:	74 f0                	je     f0104691 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01046a1:	80 f9 2b             	cmp    $0x2b,%cl
f01046a4:	75 0a                	jne    f01046b0 <strtol+0x2d>
		s++;
f01046a6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01046a9:	bf 00 00 00 00       	mov    $0x0,%edi
f01046ae:	eb 11                	jmp    f01046c1 <strtol+0x3e>
f01046b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01046b5:	80 f9 2d             	cmp    $0x2d,%cl
f01046b8:	75 07                	jne    f01046c1 <strtol+0x3e>
		s++, neg = 1;
f01046ba:	8d 52 01             	lea    0x1(%edx),%edx
f01046bd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01046c1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f01046c6:	75 15                	jne    f01046dd <strtol+0x5a>
f01046c8:	80 3a 30             	cmpb   $0x30,(%edx)
f01046cb:	75 10                	jne    f01046dd <strtol+0x5a>
f01046cd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01046d1:	75 0a                	jne    f01046dd <strtol+0x5a>
		s += 2, base = 16;
f01046d3:	83 c2 02             	add    $0x2,%edx
f01046d6:	b8 10 00 00 00       	mov    $0x10,%eax
f01046db:	eb 10                	jmp    f01046ed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f01046dd:	85 c0                	test   %eax,%eax
f01046df:	75 0c                	jne    f01046ed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01046e1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01046e3:	80 3a 30             	cmpb   $0x30,(%edx)
f01046e6:	75 05                	jne    f01046ed <strtol+0x6a>
		s++, base = 8;
f01046e8:	83 c2 01             	add    $0x1,%edx
f01046eb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f01046ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046f2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01046f5:	0f b6 0a             	movzbl (%edx),%ecx
f01046f8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01046fb:	89 f0                	mov    %esi,%eax
f01046fd:	3c 09                	cmp    $0x9,%al
f01046ff:	77 08                	ja     f0104709 <strtol+0x86>
			dig = *s - '0';
f0104701:	0f be c9             	movsbl %cl,%ecx
f0104704:	83 e9 30             	sub    $0x30,%ecx
f0104707:	eb 20                	jmp    f0104729 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0104709:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010470c:	89 f0                	mov    %esi,%eax
f010470e:	3c 19                	cmp    $0x19,%al
f0104710:	77 08                	ja     f010471a <strtol+0x97>
			dig = *s - 'a' + 10;
f0104712:	0f be c9             	movsbl %cl,%ecx
f0104715:	83 e9 57             	sub    $0x57,%ecx
f0104718:	eb 0f                	jmp    f0104729 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010471a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010471d:	89 f0                	mov    %esi,%eax
f010471f:	3c 19                	cmp    $0x19,%al
f0104721:	77 16                	ja     f0104739 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104723:	0f be c9             	movsbl %cl,%ecx
f0104726:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104729:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010472c:	7d 0f                	jge    f010473d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010472e:	83 c2 01             	add    $0x1,%edx
f0104731:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0104735:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0104737:	eb bc                	jmp    f01046f5 <strtol+0x72>
f0104739:	89 d8                	mov    %ebx,%eax
f010473b:	eb 02                	jmp    f010473f <strtol+0xbc>
f010473d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010473f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104743:	74 05                	je     f010474a <strtol+0xc7>
		*endptr = (char *) s;
f0104745:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104748:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010474a:	f7 d8                	neg    %eax
f010474c:	85 ff                	test   %edi,%edi
f010474e:	0f 44 c3             	cmove  %ebx,%eax
}
f0104751:	5b                   	pop    %ebx
f0104752:	5e                   	pop    %esi
f0104753:	5f                   	pop    %edi
f0104754:	5d                   	pop    %ebp
f0104755:	c3                   	ret    
f0104756:	66 90                	xchg   %ax,%ax
f0104758:	66 90                	xchg   %ax,%ax
f010475a:	66 90                	xchg   %ax,%ax
f010475c:	66 90                	xchg   %ax,%ax
f010475e:	66 90                	xchg   %ax,%ax

f0104760 <__udivdi3>:
f0104760:	55                   	push   %ebp
f0104761:	57                   	push   %edi
f0104762:	56                   	push   %esi
f0104763:	83 ec 0c             	sub    $0xc,%esp
f0104766:	8b 44 24 28          	mov    0x28(%esp),%eax
f010476a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010476e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104772:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104776:	85 c0                	test   %eax,%eax
f0104778:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010477c:	89 ea                	mov    %ebp,%edx
f010477e:	89 0c 24             	mov    %ecx,(%esp)
f0104781:	75 2d                	jne    f01047b0 <__udivdi3+0x50>
f0104783:	39 e9                	cmp    %ebp,%ecx
f0104785:	77 61                	ja     f01047e8 <__udivdi3+0x88>
f0104787:	85 c9                	test   %ecx,%ecx
f0104789:	89 ce                	mov    %ecx,%esi
f010478b:	75 0b                	jne    f0104798 <__udivdi3+0x38>
f010478d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104792:	31 d2                	xor    %edx,%edx
f0104794:	f7 f1                	div    %ecx
f0104796:	89 c6                	mov    %eax,%esi
f0104798:	31 d2                	xor    %edx,%edx
f010479a:	89 e8                	mov    %ebp,%eax
f010479c:	f7 f6                	div    %esi
f010479e:	89 c5                	mov    %eax,%ebp
f01047a0:	89 f8                	mov    %edi,%eax
f01047a2:	f7 f6                	div    %esi
f01047a4:	89 ea                	mov    %ebp,%edx
f01047a6:	83 c4 0c             	add    $0xc,%esp
f01047a9:	5e                   	pop    %esi
f01047aa:	5f                   	pop    %edi
f01047ab:	5d                   	pop    %ebp
f01047ac:	c3                   	ret    
f01047ad:	8d 76 00             	lea    0x0(%esi),%esi
f01047b0:	39 e8                	cmp    %ebp,%eax
f01047b2:	77 24                	ja     f01047d8 <__udivdi3+0x78>
f01047b4:	0f bd e8             	bsr    %eax,%ebp
f01047b7:	83 f5 1f             	xor    $0x1f,%ebp
f01047ba:	75 3c                	jne    f01047f8 <__udivdi3+0x98>
f01047bc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01047c0:	39 34 24             	cmp    %esi,(%esp)
f01047c3:	0f 86 9f 00 00 00    	jbe    f0104868 <__udivdi3+0x108>
f01047c9:	39 d0                	cmp    %edx,%eax
f01047cb:	0f 82 97 00 00 00    	jb     f0104868 <__udivdi3+0x108>
f01047d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047d8:	31 d2                	xor    %edx,%edx
f01047da:	31 c0                	xor    %eax,%eax
f01047dc:	83 c4 0c             	add    $0xc,%esp
f01047df:	5e                   	pop    %esi
f01047e0:	5f                   	pop    %edi
f01047e1:	5d                   	pop    %ebp
f01047e2:	c3                   	ret    
f01047e3:	90                   	nop
f01047e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047e8:	89 f8                	mov    %edi,%eax
f01047ea:	f7 f1                	div    %ecx
f01047ec:	31 d2                	xor    %edx,%edx
f01047ee:	83 c4 0c             	add    $0xc,%esp
f01047f1:	5e                   	pop    %esi
f01047f2:	5f                   	pop    %edi
f01047f3:	5d                   	pop    %ebp
f01047f4:	c3                   	ret    
f01047f5:	8d 76 00             	lea    0x0(%esi),%esi
f01047f8:	89 e9                	mov    %ebp,%ecx
f01047fa:	8b 3c 24             	mov    (%esp),%edi
f01047fd:	d3 e0                	shl    %cl,%eax
f01047ff:	89 c6                	mov    %eax,%esi
f0104801:	b8 20 00 00 00       	mov    $0x20,%eax
f0104806:	29 e8                	sub    %ebp,%eax
f0104808:	89 c1                	mov    %eax,%ecx
f010480a:	d3 ef                	shr    %cl,%edi
f010480c:	89 e9                	mov    %ebp,%ecx
f010480e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104812:	8b 3c 24             	mov    (%esp),%edi
f0104815:	09 74 24 08          	or     %esi,0x8(%esp)
f0104819:	89 d6                	mov    %edx,%esi
f010481b:	d3 e7                	shl    %cl,%edi
f010481d:	89 c1                	mov    %eax,%ecx
f010481f:	89 3c 24             	mov    %edi,(%esp)
f0104822:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104826:	d3 ee                	shr    %cl,%esi
f0104828:	89 e9                	mov    %ebp,%ecx
f010482a:	d3 e2                	shl    %cl,%edx
f010482c:	89 c1                	mov    %eax,%ecx
f010482e:	d3 ef                	shr    %cl,%edi
f0104830:	09 d7                	or     %edx,%edi
f0104832:	89 f2                	mov    %esi,%edx
f0104834:	89 f8                	mov    %edi,%eax
f0104836:	f7 74 24 08          	divl   0x8(%esp)
f010483a:	89 d6                	mov    %edx,%esi
f010483c:	89 c7                	mov    %eax,%edi
f010483e:	f7 24 24             	mull   (%esp)
f0104841:	39 d6                	cmp    %edx,%esi
f0104843:	89 14 24             	mov    %edx,(%esp)
f0104846:	72 30                	jb     f0104878 <__udivdi3+0x118>
f0104848:	8b 54 24 04          	mov    0x4(%esp),%edx
f010484c:	89 e9                	mov    %ebp,%ecx
f010484e:	d3 e2                	shl    %cl,%edx
f0104850:	39 c2                	cmp    %eax,%edx
f0104852:	73 05                	jae    f0104859 <__udivdi3+0xf9>
f0104854:	3b 34 24             	cmp    (%esp),%esi
f0104857:	74 1f                	je     f0104878 <__udivdi3+0x118>
f0104859:	89 f8                	mov    %edi,%eax
f010485b:	31 d2                	xor    %edx,%edx
f010485d:	e9 7a ff ff ff       	jmp    f01047dc <__udivdi3+0x7c>
f0104862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104868:	31 d2                	xor    %edx,%edx
f010486a:	b8 01 00 00 00       	mov    $0x1,%eax
f010486f:	e9 68 ff ff ff       	jmp    f01047dc <__udivdi3+0x7c>
f0104874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104878:	8d 47 ff             	lea    -0x1(%edi),%eax
f010487b:	31 d2                	xor    %edx,%edx
f010487d:	83 c4 0c             	add    $0xc,%esp
f0104880:	5e                   	pop    %esi
f0104881:	5f                   	pop    %edi
f0104882:	5d                   	pop    %ebp
f0104883:	c3                   	ret    
f0104884:	66 90                	xchg   %ax,%ax
f0104886:	66 90                	xchg   %ax,%ax
f0104888:	66 90                	xchg   %ax,%ax
f010488a:	66 90                	xchg   %ax,%ax
f010488c:	66 90                	xchg   %ax,%ax
f010488e:	66 90                	xchg   %ax,%ax

f0104890 <__umoddi3>:
f0104890:	55                   	push   %ebp
f0104891:	57                   	push   %edi
f0104892:	56                   	push   %esi
f0104893:	83 ec 14             	sub    $0x14,%esp
f0104896:	8b 44 24 28          	mov    0x28(%esp),%eax
f010489a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010489e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01048a2:	89 c7                	mov    %eax,%edi
f01048a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01048ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01048b0:	89 34 24             	mov    %esi,(%esp)
f01048b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048b7:	85 c0                	test   %eax,%eax
f01048b9:	89 c2                	mov    %eax,%edx
f01048bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048bf:	75 17                	jne    f01048d8 <__umoddi3+0x48>
f01048c1:	39 fe                	cmp    %edi,%esi
f01048c3:	76 4b                	jbe    f0104910 <__umoddi3+0x80>
f01048c5:	89 c8                	mov    %ecx,%eax
f01048c7:	89 fa                	mov    %edi,%edx
f01048c9:	f7 f6                	div    %esi
f01048cb:	89 d0                	mov    %edx,%eax
f01048cd:	31 d2                	xor    %edx,%edx
f01048cf:	83 c4 14             	add    $0x14,%esp
f01048d2:	5e                   	pop    %esi
f01048d3:	5f                   	pop    %edi
f01048d4:	5d                   	pop    %ebp
f01048d5:	c3                   	ret    
f01048d6:	66 90                	xchg   %ax,%ax
f01048d8:	39 f8                	cmp    %edi,%eax
f01048da:	77 54                	ja     f0104930 <__umoddi3+0xa0>
f01048dc:	0f bd e8             	bsr    %eax,%ebp
f01048df:	83 f5 1f             	xor    $0x1f,%ebp
f01048e2:	75 5c                	jne    f0104940 <__umoddi3+0xb0>
f01048e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01048e8:	39 3c 24             	cmp    %edi,(%esp)
f01048eb:	0f 87 e7 00 00 00    	ja     f01049d8 <__umoddi3+0x148>
f01048f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01048f5:	29 f1                	sub    %esi,%ecx
f01048f7:	19 c7                	sbb    %eax,%edi
f01048f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104901:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104905:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104909:	83 c4 14             	add    $0x14,%esp
f010490c:	5e                   	pop    %esi
f010490d:	5f                   	pop    %edi
f010490e:	5d                   	pop    %ebp
f010490f:	c3                   	ret    
f0104910:	85 f6                	test   %esi,%esi
f0104912:	89 f5                	mov    %esi,%ebp
f0104914:	75 0b                	jne    f0104921 <__umoddi3+0x91>
f0104916:	b8 01 00 00 00       	mov    $0x1,%eax
f010491b:	31 d2                	xor    %edx,%edx
f010491d:	f7 f6                	div    %esi
f010491f:	89 c5                	mov    %eax,%ebp
f0104921:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104925:	31 d2                	xor    %edx,%edx
f0104927:	f7 f5                	div    %ebp
f0104929:	89 c8                	mov    %ecx,%eax
f010492b:	f7 f5                	div    %ebp
f010492d:	eb 9c                	jmp    f01048cb <__umoddi3+0x3b>
f010492f:	90                   	nop
f0104930:	89 c8                	mov    %ecx,%eax
f0104932:	89 fa                	mov    %edi,%edx
f0104934:	83 c4 14             	add    $0x14,%esp
f0104937:	5e                   	pop    %esi
f0104938:	5f                   	pop    %edi
f0104939:	5d                   	pop    %ebp
f010493a:	c3                   	ret    
f010493b:	90                   	nop
f010493c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104940:	8b 04 24             	mov    (%esp),%eax
f0104943:	be 20 00 00 00       	mov    $0x20,%esi
f0104948:	89 e9                	mov    %ebp,%ecx
f010494a:	29 ee                	sub    %ebp,%esi
f010494c:	d3 e2                	shl    %cl,%edx
f010494e:	89 f1                	mov    %esi,%ecx
f0104950:	d3 e8                	shr    %cl,%eax
f0104952:	89 e9                	mov    %ebp,%ecx
f0104954:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104958:	8b 04 24             	mov    (%esp),%eax
f010495b:	09 54 24 04          	or     %edx,0x4(%esp)
f010495f:	89 fa                	mov    %edi,%edx
f0104961:	d3 e0                	shl    %cl,%eax
f0104963:	89 f1                	mov    %esi,%ecx
f0104965:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104969:	8b 44 24 10          	mov    0x10(%esp),%eax
f010496d:	d3 ea                	shr    %cl,%edx
f010496f:	89 e9                	mov    %ebp,%ecx
f0104971:	d3 e7                	shl    %cl,%edi
f0104973:	89 f1                	mov    %esi,%ecx
f0104975:	d3 e8                	shr    %cl,%eax
f0104977:	89 e9                	mov    %ebp,%ecx
f0104979:	09 f8                	or     %edi,%eax
f010497b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010497f:	f7 74 24 04          	divl   0x4(%esp)
f0104983:	d3 e7                	shl    %cl,%edi
f0104985:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104989:	89 d7                	mov    %edx,%edi
f010498b:	f7 64 24 08          	mull   0x8(%esp)
f010498f:	39 d7                	cmp    %edx,%edi
f0104991:	89 c1                	mov    %eax,%ecx
f0104993:	89 14 24             	mov    %edx,(%esp)
f0104996:	72 2c                	jb     f01049c4 <__umoddi3+0x134>
f0104998:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010499c:	72 22                	jb     f01049c0 <__umoddi3+0x130>
f010499e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01049a2:	29 c8                	sub    %ecx,%eax
f01049a4:	19 d7                	sbb    %edx,%edi
f01049a6:	89 e9                	mov    %ebp,%ecx
f01049a8:	89 fa                	mov    %edi,%edx
f01049aa:	d3 e8                	shr    %cl,%eax
f01049ac:	89 f1                	mov    %esi,%ecx
f01049ae:	d3 e2                	shl    %cl,%edx
f01049b0:	89 e9                	mov    %ebp,%ecx
f01049b2:	d3 ef                	shr    %cl,%edi
f01049b4:	09 d0                	or     %edx,%eax
f01049b6:	89 fa                	mov    %edi,%edx
f01049b8:	83 c4 14             	add    $0x14,%esp
f01049bb:	5e                   	pop    %esi
f01049bc:	5f                   	pop    %edi
f01049bd:	5d                   	pop    %ebp
f01049be:	c3                   	ret    
f01049bf:	90                   	nop
f01049c0:	39 d7                	cmp    %edx,%edi
f01049c2:	75 da                	jne    f010499e <__umoddi3+0x10e>
f01049c4:	8b 14 24             	mov    (%esp),%edx
f01049c7:	89 c1                	mov    %eax,%ecx
f01049c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01049cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01049d1:	eb cb                	jmp    f010499e <__umoddi3+0x10e>
f01049d3:	90                   	nop
f01049d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01049d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01049dc:	0f 82 0f ff ff ff    	jb     f01048f1 <__umoddi3+0x61>
f01049e2:	e9 1a ff ff ff       	jmp    f0104901 <__umoddi3+0x71>
