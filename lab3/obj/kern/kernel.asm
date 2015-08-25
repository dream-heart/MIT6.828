
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

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
f0100046:	b8 90 cd 17 f0       	mov    $0xf017cd90,%eax
f010004b:	2d 65 be 17 f0       	sub    $0xf017be65,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 65 be 17 f0 	movl   $0xf017be65,(%esp)
f0100063:	e8 7f 41 00 00       	call   f01041e7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b2 04 00 00       	call   f010051f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 46 10 f0 	movl   $0xf0104680,(%esp)
f010007c:	e8 f6 31 00 00       	call   f0103277 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 98 10 00 00       	call   f010111e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 dd 2d 00 00       	call   f0102e68 <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 59 32 00 00       	call   f01032ee <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010009c:	00 
f010009d:	c7 04 24 56 a3 11 f0 	movl   $0xf011a356,(%esp)
f01000a4:	e8 f8 2e 00 00       	call   f0102fa1 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a9:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
f01000ae:	89 04 24             	mov    %eax,(%esp)
f01000b1:	e8 2f 31 00 00       	call   f01031e5 <env_run>

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
f01000c1:	83 3d 80 cd 17 f0 00 	cmpl   $0x0,0xf017cd80
f01000c8:	75 3d                	jne    f0100107 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000ca:	89 35 80 cd 17 f0    	mov    %esi,0xf017cd80

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
f01000e3:	c7 04 24 9b 46 10 f0 	movl   $0xf010469b,(%esp)
f01000ea:	e8 88 31 00 00       	call   f0103277 <cprintf>
	vcprintf(fmt, ap);
f01000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f3:	89 34 24             	mov    %esi,(%esp)
f01000f6:	e8 49 31 00 00       	call   f0103244 <vcprintf>
	cprintf("\n");
f01000fb:	c7 04 24 69 55 10 f0 	movl   $0xf0105569,(%esp)
f0100102:	e8 70 31 00 00       	call   f0103277 <cprintf>
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
f010012d:	c7 04 24 b3 46 10 f0 	movl   $0xf01046b3,(%esp)
f0100134:	e8 3e 31 00 00       	call   f0103277 <cprintf>
	vcprintf(fmt, ap);
f0100139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100140:	89 04 24             	mov    %eax,(%esp)
f0100143:	e8 fc 30 00 00       	call   f0103244 <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 69 55 10 f0 	movl   $0xf0105569,(%esp)
f010014f:	e8 23 31 00 00       	call   f0103277 <cprintf>
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
f010018b:	a1 a4 c0 17 f0       	mov    0xf017c0a4,%eax
f0100190:	8d 48 01             	lea    0x1(%eax),%ecx
f0100193:	89 0d a4 c0 17 f0    	mov    %ecx,0xf017c0a4
f0100199:	88 90 a0 be 17 f0    	mov    %dl,-0xfe84160(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010019f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001a5:	75 0a                	jne    f01001b1 <cons_intr+0x35>
			cons.wpos = 0;
f01001a7:	c7 05 a4 c0 17 f0 00 	movl   $0x0,0xf017c0a4
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
f01001d7:	83 0d 80 be 17 f0 40 	orl    $0x40,0xf017be80
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
f01001ef:	8b 0d 80 be 17 f0    	mov    0xf017be80,%ecx
f01001f5:	89 cb                	mov    %ecx,%ebx
f01001f7:	83 e3 40             	and    $0x40,%ebx
f01001fa:	83 e0 7f             	and    $0x7f,%eax
f01001fd:	85 db                	test   %ebx,%ebx
f01001ff:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100202:	0f b6 d2             	movzbl %dl,%edx
f0100205:	0f b6 82 20 48 10 f0 	movzbl -0xfefb7e0(%edx),%eax
f010020c:	83 c8 40             	or     $0x40,%eax
f010020f:	0f b6 c0             	movzbl %al,%eax
f0100212:	f7 d0                	not    %eax
f0100214:	21 c1                	and    %eax,%ecx
f0100216:	89 0d 80 be 17 f0    	mov    %ecx,0xf017be80
		return 0;
f010021c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100221:	e9 9d 00 00 00       	jmp    f01002c3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100226:	8b 0d 80 be 17 f0    	mov    0xf017be80,%ecx
f010022c:	f6 c1 40             	test   $0x40,%cl
f010022f:	74 0e                	je     f010023f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100231:	83 c8 80             	or     $0xffffff80,%eax
f0100234:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100236:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100239:	89 0d 80 be 17 f0    	mov    %ecx,0xf017be80
	}

	shift |= shiftcode[data];
f010023f:	0f b6 d2             	movzbl %dl,%edx
f0100242:	0f b6 82 20 48 10 f0 	movzbl -0xfefb7e0(%edx),%eax
f0100249:	0b 05 80 be 17 f0    	or     0xf017be80,%eax
	shift ^= togglecode[data];
f010024f:	0f b6 8a 20 47 10 f0 	movzbl -0xfefb8e0(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 80 be 17 f0       	mov    %eax,0xf017be80

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 00 47 10 f0 	mov    -0xfefb900(,%ecx,4),%ecx
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
f01002a2:	c7 04 24 cd 46 10 f0 	movl   $0xf01046cd,(%esp)
f01002a9:	e8 c9 2f 00 00       	call   f0103277 <cprintf>
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
f010037c:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f0100383:	66 85 c0             	test   %ax,%ax
f0100386:	0f 84 e5 00 00 00    	je     f0100471 <cons_putc+0x1a8>
			crt_pos--;
f010038c:	83 e8 01             	sub    $0x1,%eax
f010038f:	66 a3 a8 c0 17 f0    	mov    %ax,0xf017c0a8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100395:	0f b7 c0             	movzwl %ax,%eax
f0100398:	66 81 e7 00 ff       	and    $0xff00,%di
f010039d:	83 cf 20             	or     $0x20,%edi
f01003a0:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
f01003a6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003aa:	eb 78                	jmp    f0100424 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ac:	66 83 05 a8 c0 17 f0 	addw   $0x50,0xf017c0a8
f01003b3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b4:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f01003bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c1:	c1 e8 16             	shr    $0x16,%eax
f01003c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c7:	c1 e0 04             	shl    $0x4,%eax
f01003ca:	66 a3 a8 c0 17 f0    	mov    %ax,0xf017c0a8
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
f0100406:	0f b7 05 a8 c0 17 f0 	movzwl 0xf017c0a8,%eax
f010040d:	8d 50 01             	lea    0x1(%eax),%edx
f0100410:	66 89 15 a8 c0 17 f0 	mov    %dx,0xf017c0a8
f0100417:	0f b7 c0             	movzwl %ax,%eax
f010041a:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
f0100420:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100424:	66 81 3d a8 c0 17 f0 	cmpw   $0x7cf,0xf017c0a8
f010042b:	cf 07 
f010042d:	76 42                	jbe    f0100471 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010042f:	a1 ac c0 17 f0       	mov    0xf017c0ac,%eax
f0100434:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010043b:	00 
f010043c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100442:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100446:	89 04 24             	mov    %eax,(%esp)
f0100449:	e8 e6 3d 00 00       	call   f0104234 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044e:	8b 15 ac c0 17 f0    	mov    0xf017c0ac,%edx
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
f0100469:	66 83 2d a8 c0 17 f0 	subw   $0x50,0xf017c0a8
f0100470:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100471:	8b 0d b0 c0 17 f0    	mov    0xf017c0b0,%ecx
f0100477:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047c:	89 ca                	mov    %ecx,%edx
f010047e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047f:	0f b7 1d a8 c0 17 f0 	movzwl 0xf017c0a8,%ebx
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
f01004a7:	80 3d b4 c0 17 f0 00 	cmpb   $0x0,0xf017c0b4
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
f01004e5:	a1 a0 c0 17 f0       	mov    0xf017c0a0,%eax
f01004ea:	3b 05 a4 c0 17 f0    	cmp    0xf017c0a4,%eax
f01004f0:	74 26                	je     f0100518 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 a0 c0 17 f0    	mov    %edx,0xf017c0a0
f01004fb:	0f b6 88 a0 be 17 f0 	movzbl -0xfe84160(%eax),%ecx
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
f010050c:	c7 05 a0 c0 17 f0 00 	movl   $0x0,0xf017c0a0
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
f0100545:	c7 05 b0 c0 17 f0 b4 	movl   $0x3b4,0xf017c0b0
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
f010055d:	c7 05 b0 c0 17 f0 d4 	movl   $0x3d4,0xf017c0b0
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
f010056c:	8b 0d b0 c0 17 f0    	mov    0xf017c0b0,%ecx
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
f0100591:	89 3d ac c0 17 f0    	mov    %edi,0xf017c0ac

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100597:	0f b6 d8             	movzbl %al,%ebx
f010059a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010059c:	66 89 35 a8 c0 17 f0 	mov    %si,0xf017c0a8
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
f01005ed:	88 0d b4 c0 17 f0    	mov    %cl,0xf017c0b4
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
f01005fd:	c7 04 24 d9 46 10 f0 	movl   $0xf01046d9,(%esp)
f0100604:	e8 6e 2c 00 00       	call   f0103277 <cprintf>
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
f0100646:	c7 44 24 08 20 49 10 	movl   $0xf0104920,0x8(%esp)
f010064d:	f0 
f010064e:	c7 44 24 04 3e 49 10 	movl   $0xf010493e,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 43 49 10 f0 	movl   $0xf0104943,(%esp)
f010065d:	e8 15 2c 00 00       	call   f0103277 <cprintf>
f0100662:	c7 44 24 08 ac 49 10 	movl   $0xf01049ac,0x8(%esp)
f0100669:	f0 
f010066a:	c7 44 24 04 4c 49 10 	movl   $0xf010494c,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 43 49 10 f0 	movl   $0xf0104943,(%esp)
f0100679:	e8 f9 2b 00 00       	call   f0103277 <cprintf>
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
f010068b:	c7 04 24 55 49 10 f0 	movl   $0xf0104955,(%esp)
f0100692:	e8 e0 2b 00 00       	call   f0103277 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100697:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069e:	00 
f010069f:	c7 04 24 d4 49 10 f0 	movl   $0xf01049d4,(%esp)
f01006a6:	e8 cc 2b 00 00       	call   f0103277 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ab:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b2:	00 
f01006b3:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006ba:	f0 
f01006bb:	c7 04 24 fc 49 10 f0 	movl   $0xf01049fc,(%esp)
f01006c2:	e8 b0 2b 00 00       	call   f0103277 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c7:	c7 44 24 08 77 46 10 	movl   $0x104677,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 77 46 10 	movl   $0xf0104677,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 20 4a 10 f0 	movl   $0xf0104a20,(%esp)
f01006de:	e8 94 2b 00 00       	call   f0103277 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e3:	c7 44 24 08 65 be 17 	movl   $0x17be65,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 65 be 17 	movl   $0xf017be65,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 44 4a 10 f0 	movl   $0xf0104a44,(%esp)
f01006fa:	e8 78 2b 00 00       	call   f0103277 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ff:	c7 44 24 08 90 cd 17 	movl   $0x17cd90,0x8(%esp)
f0100706:	00 
f0100707:	c7 44 24 04 90 cd 17 	movl   $0xf017cd90,0x4(%esp)
f010070e:	f0 
f010070f:	c7 04 24 68 4a 10 f0 	movl   $0xf0104a68,(%esp)
f0100716:	e8 5c 2b 00 00       	call   f0103277 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071b:	b8 8f d1 17 f0       	mov    $0xf017d18f,%eax
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
f010073c:	c7 04 24 8c 4a 10 f0 	movl   $0xf0104a8c,(%esp)
f0100743:	e8 2f 2b 00 00       	call   f0103277 <cprintf>
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
f0100762:	c7 04 24 b8 4a 10 f0 	movl   $0xf0104ab8,(%esp)
f0100769:	e8 09 2b 00 00       	call   f0103277 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010076e:	c7 04 24 dc 4a 10 f0 	movl   $0xf0104adc,(%esp)
f0100775:	e8 fd 2a 00 00       	call   f0103277 <cprintf>

	if (tf != NULL)
f010077a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010077e:	74 0b                	je     f010078b <monitor+0x32>
		print_trapframe(tf);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	89 04 24             	mov    %eax,(%esp)
f0100786:	e8 14 2c 00 00       	call   f010339f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010078b:	c7 04 24 6e 49 10 f0 	movl   $0xf010496e,(%esp)
f0100792:	e8 f9 37 00 00       	call   f0103f90 <readline>
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
f01007c3:	c7 04 24 72 49 10 f0 	movl   $0xf0104972,(%esp)
f01007ca:	e8 db 39 00 00       	call   f01041aa <strchr>
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
f01007e5:	c7 04 24 77 49 10 f0 	movl   $0xf0104977,(%esp)
f01007ec:	e8 86 2a 00 00       	call   f0103277 <cprintf>
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
f010080d:	c7 04 24 72 49 10 f0 	movl   $0xf0104972,(%esp)
f0100814:	e8 91 39 00 00       	call   f01041aa <strchr>
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
f010082f:	c7 44 24 04 3e 49 10 	movl   $0xf010493e,0x4(%esp)
f0100836:	f0 
f0100837:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010083a:	89 04 24             	mov    %eax,(%esp)
f010083d:	e8 0a 39 00 00       	call   f010414c <strcmp>
f0100842:	85 c0                	test   %eax,%eax
f0100844:	74 1b                	je     f0100861 <monitor+0x108>
f0100846:	c7 44 24 04 4c 49 10 	movl   $0xf010494c,0x4(%esp)
f010084d:	f0 
f010084e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 f3 38 00 00       	call   f010414c <strcmp>
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
f010087c:	ff 14 85 0c 4b 10 f0 	call   *-0xfefb4f4(,%eax,4)
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
f0100893:	c7 04 24 94 49 10 f0 	movl   $0xf0104994,(%esp)
f010089a:	e8 d8 29 00 00       	call   f0103277 <cprintf>
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
f01008b3:	83 3d b8 c0 17 f0 00 	cmpl   $0x0,0xf017c0b8
f01008ba:	75 11                	jne    f01008cd <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008bc:	ba 8f dd 17 f0       	mov    $0xf017dd8f,%edx
f01008c1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008c7:	89 15 b8 c0 17 f0    	mov    %edx,0xf017c0b8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f01008cd:	85 c0                	test   %eax,%eax
f01008cf:	75 07                	jne    f01008d8 <boot_alloc+0x28>
		return nextfree;
f01008d1:	a1 b8 c0 17 f0       	mov    0xf017c0b8,%eax
f01008d6:	eb 19                	jmp    f01008f1 <boot_alloc+0x41>
	result = nextfree;
f01008d8:	8b 15 b8 c0 17 f0    	mov    0xf017c0b8,%edx
	nextfree += n;
	nextfree = ROUNDUP((char *) nextfree, PGSIZE);	
f01008de:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01008e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008ea:	a3 b8 c0 17 f0       	mov    %eax,0xf017c0b8
	
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
f01008f3:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
f01008f9:	c1 f8 03             	sar    $0x3,%eax
f01008fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008ff:	89 c2                	mov    %eax,%edx
f0100901:	c1 ea 0c             	shr    $0xc,%edx
f0100904:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
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
f0100916:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f010091d:	f0 
f010091e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100925:	00 
f0100926:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
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
f010094e:	3b 0d 84 cd 17 f0    	cmp    0xf017cd84,%ecx
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
f0100960:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0100967:	f0 
f0100968:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f010096f:	00 
f0100970:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01009bd:	c7 44 24 08 40 4b 10 	movl   $0xf0104b40,0x8(%esp)
f01009c4:	f0 
f01009c5:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f01009cc:	00 
f01009cd:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01009e7:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
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
f0100a1d:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
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
f0100a27:	8b 1d bc c0 17 f0    	mov    0xf017c0bc,%ebx
f0100a2d:	eb 63                	jmp    f0100a92 <check_page_free_list+0xeb>
f0100a2f:	89 d8                	mov    %ebx,%eax
f0100a31:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
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
f0100a4b:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
f0100a51:	72 20                	jb     f0100a73 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a57:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0100a5e:	f0 
f0100a5f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100a66:	00 
f0100a67:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f0100a6e:	e8 43 f6 ff ff       	call   f01000b6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a73:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100a7a:	00 
f0100a7b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100a82:	00 
	return (void *)(pa + KERNBASE);
f0100a83:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a88:	89 04 24             	mov    %eax,(%esp)
f0100a8b:	e8 57 37 00 00       	call   f01041e7 <memset>
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
f0100aa3:	8b 15 bc c0 17 f0    	mov    0xf017c0bc,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aa9:	8b 0d 8c cd 17 f0    	mov    0xf017cd8c,%ecx
		assert(pp < pages + npages);
f0100aaf:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
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
f0100ad1:	c7 44 24 0c bb 52 10 	movl   $0xf01052bb,0xc(%esp)
f0100ad8:	f0 
f0100ad9:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100ae0:	f0 
f0100ae1:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0100ae8:	00 
f0100ae9:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100af0:	e8 c1 f5 ff ff       	call   f01000b6 <_panic>
		assert(pp < pages + npages);
f0100af5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100af8:	72 24                	jb     f0100b1e <check_page_free_list+0x177>
f0100afa:	c7 44 24 0c dc 52 10 	movl   $0xf01052dc,0xc(%esp)
f0100b01:	f0 
f0100b02:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100b09:	f0 
f0100b0a:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
f0100b11:	00 
f0100b12:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100b19:	e8 98 f5 ff ff       	call   f01000b6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1e:	89 d0                	mov    %edx,%eax
f0100b20:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b23:	a8 07                	test   $0x7,%al
f0100b25:	74 24                	je     f0100b4b <check_page_free_list+0x1a4>
f0100b27:	c7 44 24 0c 64 4b 10 	movl   $0xf0104b64,0xc(%esp)
f0100b2e:	f0 
f0100b2f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100b36:	f0 
f0100b37:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
f0100b3e:	00 
f0100b3f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0100b55:	c7 44 24 0c f0 52 10 	movl   $0xf01052f0,0xc(%esp)
f0100b5c:	f0 
f0100b5d:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100b64:	f0 
f0100b65:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0100b6c:	00 
f0100b6d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100b74:	e8 3d f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b79:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b7e:	75 24                	jne    f0100ba4 <check_page_free_list+0x1fd>
f0100b80:	c7 44 24 0c 01 53 10 	movl   $0xf0105301,0xc(%esp)
f0100b87:	f0 
f0100b88:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100b8f:	f0 
f0100b90:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f0100b97:	00 
f0100b98:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100b9f:	e8 12 f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ba4:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ba9:	75 24                	jne    f0100bcf <check_page_free_list+0x228>
f0100bab:	c7 44 24 0c 98 4b 10 	movl   $0xf0104b98,0xc(%esp)
f0100bb2:	f0 
f0100bb3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100bba:	f0 
f0100bbb:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100bc2:	00 
f0100bc3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100bca:	e8 e7 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bcf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bd4:	75 24                	jne    f0100bfa <check_page_free_list+0x253>
f0100bd6:	c7 44 24 0c 1a 53 10 	movl   $0xf010531a,0xc(%esp)
f0100bdd:	f0 
f0100bde:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100be5:	f0 
f0100be6:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100bed:	00 
f0100bee:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0100c0f:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0100c16:	f0 
f0100c17:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100c1e:	00 
f0100c1f:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f0100c26:	e8 8b f4 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100c2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c30:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c33:	76 2a                	jbe    f0100c5f <check_page_free_list+0x2b8>
f0100c35:	c7 44 24 0c bc 4b 10 	movl   $0xf0104bbc,0xc(%esp)
f0100c3c:	f0 
f0100c3d:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100c44:	f0 
f0100c45:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100c4c:	00 
f0100c4d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0100c73:	c7 44 24 0c 34 53 10 	movl   $0xf0105334,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100c92:	e8 1f f4 ff ff       	call   f01000b6 <_panic>
	assert(nfree_extmem > 0);
f0100c97:	85 ff                	test   %edi,%edi
f0100c99:	7f 4d                	jg     f0100ce8 <check_page_free_list+0x341>
f0100c9b:	c7 44 24 0c 46 53 10 	movl   $0xf0105346,0xc(%esp)
f0100ca2:	f0 
f0100ca3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100cba:	e8 f7 f3 ff ff       	call   f01000b6 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cbf:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
f0100cc4:	85 c0                	test   %eax,%eax
f0100cc6:	0f 85 0d fd ff ff    	jne    f01009d9 <check_page_free_list+0x32>
f0100ccc:	e9 ec fc ff ff       	jmp    f01009bd <check_page_free_list+0x16>
f0100cd1:	83 3d bc c0 17 f0 00 	cmpl   $0x0,0xf017c0bc
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
f0100d08:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f0100d0d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100d13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d19:	e9 a5 00 00 00       	jmp    f0100dc3 <page_init+0xd3>
			}
		else if(i>=1 && i<npages_basemem)
f0100d1e:	3b 1d c0 c0 17 f0    	cmp    0xf017c0c0,%ebx
f0100d24:	73 25                	jae    f0100d4b <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d26:	89 f0                	mov    %esi,%eax
f0100d28:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
f0100d2e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d34:	8b 15 bc c0 17 f0    	mov    0xf017c0bc,%edx
f0100d3a:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d3c:	89 f0                	mov    %esi,%eax
f0100d3e:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
f0100d44:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
f0100d49:	eb 78                	jmp    f0100dc3 <page_init+0xd3>
f0100d4b:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100d51:	83 f8 5f             	cmp    $0x5f,%eax
f0100d54:	77 16                	ja     f0100d6c <page_init+0x7c>
		{
			pages[i].pp_ref = 1;
f0100d56:	89 f0                	mov    %esi,%eax
f0100d58:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
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
f0100d8c:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
f0100d92:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100d98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100d9e:	eb 23                	jmp    f0100dc3 <page_init+0xd3>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100da0:	89 f0                	mov    %esi,%eax
f0100da2:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
f0100da8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100dae:	8b 15 bc c0 17 f0    	mov    0xf017c0bc,%edx
f0100db4:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100db6:	89 f0                	mov    %esi,%eax
f0100db8:	03 05 8c cd 17 f0    	add    0xf017cd8c,%eax
f0100dbe:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dc3:	83 c3 01             	add    $0x1,%ebx
f0100dc6:	83 c6 08             	add    $0x8,%esi
f0100dc9:	3b 1d 84 cd 17 f0    	cmp    0xf017cd84,%ebx
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
f0100de0:	8b 1d bc c0 17 f0    	mov    0xf017c0bc,%ebx
f0100de6:	85 db                	test   %ebx,%ebx
f0100de8:	74 6f                	je     f0100e59 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100dea:	8b 03                	mov    (%ebx),%eax
f0100dec:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
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
f0100dff:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
f0100e05:	c1 f8 03             	sar    $0x3,%eax
f0100e08:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0b:	89 c2                	mov    %eax,%edx
f0100e0d:	c1 ea 0c             	shr    $0xc,%edx
f0100e10:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
f0100e16:	72 20                	jb     f0100e38 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e18:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e1c:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0100e23:	f0 
f0100e24:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e2b:	00 
f0100e2c:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f0100e33:	e8 7e f2 ff ff       	call   f01000b6 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100e38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e3f:	00 
f0100e40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e47:	00 
	return (void *)(pa + KERNBASE);
f0100e48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e4d:	89 04 24             	mov    %eax,(%esp)
f0100e50:	e8 92 33 00 00       	call   f01041e7 <memset>
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
f0100e79:	c7 44 24 08 57 53 10 	movl   $0xf0105357,0x8(%esp)
f0100e80:	f0 
f0100e81:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100e88:	00 
f0100e89:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0100e90:	e8 21 f2 ff ff       	call   f01000b6 <_panic>
	pp->pp_link = page_free_list;
f0100e95:	8b 15 bc c0 17 f0    	mov    0xf017c0bc,%edx
f0100e9b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e9d:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc
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
f0100efd:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
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
f0100f25:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
f0100f2b:	72 20                	jb     f0100f4d <pgdir_walk+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f31:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0100f38:	f0 
f0100f39:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f0100f40:	00 
f0100f41:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101003:	3b 05 84 cd 17 f0    	cmp    0xf017cd84,%eax
f0101009:	72 1c                	jb     f0101027 <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f010100b:	c7 44 24 08 04 4c 10 	movl   $0xf0104c04,0x8(%esp)
f0101012:	f0 
f0101013:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010101a:	00 
f010101b:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f0101022:	e8 8f f0 ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0101027:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
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
f01010c3:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
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
f01010f5:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
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
f010112e:	e8 d4 20 00 00       	call   f0103207 <mc146818_read>
f0101133:	89 c3                	mov    %eax,%ebx
f0101135:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010113c:	e8 c6 20 00 00       	call   f0103207 <mc146818_read>
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
f0101159:	a3 c0 c0 17 f0       	mov    %eax,0xf017c0c0
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010115e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101165:	e8 9d 20 00 00       	call   f0103207 <mc146818_read>
f010116a:	89 c3                	mov    %eax,%ebx
f010116c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101173:	e8 8f 20 00 00       	call   f0103207 <mc146818_read>
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
f010119a:	89 15 84 cd 17 f0    	mov    %edx,0xf017cd84
f01011a0:	eb 0c                	jmp    f01011ae <mem_init+0x90>
	else
		npages = npages_basemem;
f01011a2:	8b 15 c0 c0 17 f0    	mov    0xf017c0c0,%edx
f01011a8:	89 15 84 cd 17 f0    	mov    %edx,0xf017cd84

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
f01011b8:	a1 c0 c0 17 f0       	mov    0xf017c0c0,%eax
f01011bd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c0:	c1 e8 0a             	shr    $0xa,%eax
f01011c3:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01011c7:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
f01011cc:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011cf:	c1 e8 0a             	shr    $0xa,%eax
f01011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d6:	c7 04 24 24 4c 10 f0 	movl   $0xf0104c24,(%esp)
f01011dd:	e8 95 20 00 00       	call   f0103277 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e7:	e8 c4 f6 ff ff       	call   f01008b0 <boot_alloc>
f01011ec:	a3 88 cd 17 f0       	mov    %eax,0xf017cd88
	memset(kern_pgdir, 0, PGSIZE);
f01011f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011f8:	00 
f01011f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101200:	00 
f0101201:	89 04 24             	mov    %eax,(%esp)
f0101204:	e8 de 2f 00 00       	call   f01041e7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101209:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010120e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101213:	77 20                	ja     f0101235 <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101215:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101219:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0101220:	f0 
f0101221:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101228:	00 
f0101229:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101244:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
f0101249:	c1 e0 03             	shl    $0x3,%eax
f010124c:	e8 5f f6 ff ff       	call   f01008b0 <boot_alloc>
f0101251:	a3 8c cd 17 f0       	mov    %eax,0xf017cd8c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101256:	8b 3d 84 cd 17 f0    	mov    0xf017cd84,%edi
f010125c:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101263:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101267:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010126e:	00 
f010126f:	89 04 24             	mov    %eax,(%esp)
f0101272:	e8 70 2f 00 00       	call   f01041e7 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101277:	b8 00 80 01 00       	mov    $0x18000,%eax
f010127c:	e8 2f f6 ff ff       	call   f01008b0 <boot_alloc>
f0101281:	a3 c8 c0 17 f0       	mov    %eax,0xf017c0c8
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101286:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f010128d:	00 
f010128e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101295:	00 
f0101296:	89 04 24             	mov    %eax,(%esp)
f0101299:	e8 49 2f 00 00       	call   f01041e7 <memset>
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
f01012ad:	83 3d 8c cd 17 f0 00 	cmpl   $0x0,0xf017cd8c
f01012b4:	75 1c                	jne    f01012d2 <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f01012b6:	c7 44 24 08 6e 53 10 	movl   $0xf010536e,0x8(%esp)
f01012bd:	f0 
f01012be:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f01012c5:	00 
f01012c6:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01012cd:	e8 e4 ed ff ff       	call   f01000b6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012d2:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
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
f01012f9:	c7 44 24 0c 89 53 10 	movl   $0xf0105389,0xc(%esp)
f0101300:	f0 
f0101301:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101308:	f0 
f0101309:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101310:	00 
f0101311:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101318:	e8 99 ed ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010131d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101324:	e8 b0 fa ff ff       	call   f0100dd9 <page_alloc>
f0101329:	89 c6                	mov    %eax,%esi
f010132b:	85 c0                	test   %eax,%eax
f010132d:	75 24                	jne    f0101353 <mem_init+0x235>
f010132f:	c7 44 24 0c 9f 53 10 	movl   $0xf010539f,0xc(%esp)
f0101336:	f0 
f0101337:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010133e:	f0 
f010133f:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0101346:	00 
f0101347:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010134e:	e8 63 ed ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010135a:	e8 7a fa ff ff       	call   f0100dd9 <page_alloc>
f010135f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101362:	85 c0                	test   %eax,%eax
f0101364:	75 24                	jne    f010138a <mem_init+0x26c>
f0101366:	c7 44 24 0c b5 53 10 	movl   $0xf01053b5,0xc(%esp)
f010136d:	f0 
f010136e:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101375:	f0 
f0101376:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010137d:	00 
f010137e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101385:	e8 2c ed ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010138a:	39 f7                	cmp    %esi,%edi
f010138c:	75 24                	jne    f01013b2 <mem_init+0x294>
f010138e:	c7 44 24 0c cb 53 10 	movl   $0xf01053cb,0xc(%esp)
f0101395:	f0 
f0101396:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010139d:	f0 
f010139e:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f01013a5:	00 
f01013a6:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01013ad:	e8 04 ed ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013b5:	39 c6                	cmp    %eax,%esi
f01013b7:	74 04                	je     f01013bd <mem_init+0x29f>
f01013b9:	39 c7                	cmp    %eax,%edi
f01013bb:	75 24                	jne    f01013e1 <mem_init+0x2c3>
f01013bd:	c7 44 24 0c 84 4c 10 	movl   $0xf0104c84,0xc(%esp)
f01013c4:	f0 
f01013c5:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01013cc:	f0 
f01013cd:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f01013d4:	00 
f01013d5:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01013dc:	e8 d5 ec ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013e1:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013e7:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
f01013ec:	c1 e0 0c             	shl    $0xc,%eax
f01013ef:	89 f9                	mov    %edi,%ecx
f01013f1:	29 d1                	sub    %edx,%ecx
f01013f3:	c1 f9 03             	sar    $0x3,%ecx
f01013f6:	c1 e1 0c             	shl    $0xc,%ecx
f01013f9:	39 c1                	cmp    %eax,%ecx
f01013fb:	72 24                	jb     f0101421 <mem_init+0x303>
f01013fd:	c7 44 24 0c dd 53 10 	movl   $0xf01053dd,0xc(%esp)
f0101404:	f0 
f0101405:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010140c:	f0 
f010140d:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0101414:	00 
f0101415:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010141c:	e8 95 ec ff ff       	call   f01000b6 <_panic>
f0101421:	89 f1                	mov    %esi,%ecx
f0101423:	29 d1                	sub    %edx,%ecx
f0101425:	c1 f9 03             	sar    $0x3,%ecx
f0101428:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010142b:	39 c8                	cmp    %ecx,%eax
f010142d:	77 24                	ja     f0101453 <mem_init+0x335>
f010142f:	c7 44 24 0c fa 53 10 	movl   $0xf01053fa,0xc(%esp)
f0101436:	f0 
f0101437:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010143e:	f0 
f010143f:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101446:	00 
f0101447:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010144e:	e8 63 ec ff ff       	call   f01000b6 <_panic>
f0101453:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101456:	29 d1                	sub    %edx,%ecx
f0101458:	89 ca                	mov    %ecx,%edx
f010145a:	c1 fa 03             	sar    $0x3,%edx
f010145d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101460:	39 d0                	cmp    %edx,%eax
f0101462:	77 24                	ja     f0101488 <mem_init+0x36a>
f0101464:	c7 44 24 0c 17 54 10 	movl   $0xf0105417,0xc(%esp)
f010146b:	f0 
f010146c:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101473:	f0 
f0101474:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f010147b:	00 
f010147c:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101483:	e8 2e ec ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101488:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
f010148d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101490:	c7 05 bc c0 17 f0 00 	movl   $0x0,0xf017c0bc
f0101497:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010149a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a1:	e8 33 f9 ff ff       	call   f0100dd9 <page_alloc>
f01014a6:	85 c0                	test   %eax,%eax
f01014a8:	74 24                	je     f01014ce <mem_init+0x3b0>
f01014aa:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01014b9:	f0 
f01014ba:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01014c1:	00 
f01014c2:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01014fb:	c7 44 24 0c 89 53 10 	movl   $0xf0105389,0xc(%esp)
f0101502:	f0 
f0101503:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010150a:	f0 
f010150b:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f0101512:	00 
f0101513:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010151a:	e8 97 eb ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101526:	e8 ae f8 ff ff       	call   f0100dd9 <page_alloc>
f010152b:	89 c7                	mov    %eax,%edi
f010152d:	85 c0                	test   %eax,%eax
f010152f:	75 24                	jne    f0101555 <mem_init+0x437>
f0101531:	c7 44 24 0c 9f 53 10 	movl   $0xf010539f,0xc(%esp)
f0101538:	f0 
f0101539:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101540:	f0 
f0101541:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101548:	00 
f0101549:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101550:	e8 61 eb ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155c:	e8 78 f8 ff ff       	call   f0100dd9 <page_alloc>
f0101561:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101564:	85 c0                	test   %eax,%eax
f0101566:	75 24                	jne    f010158c <mem_init+0x46e>
f0101568:	c7 44 24 0c b5 53 10 	movl   $0xf01053b5,0xc(%esp)
f010156f:	f0 
f0101570:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101577:	f0 
f0101578:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f010157f:	00 
f0101580:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101587:	e8 2a eb ff ff       	call   f01000b6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010158c:	39 fe                	cmp    %edi,%esi
f010158e:	75 24                	jne    f01015b4 <mem_init+0x496>
f0101590:	c7 44 24 0c cb 53 10 	movl   $0xf01053cb,0xc(%esp)
f0101597:	f0 
f0101598:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010159f:	f0 
f01015a0:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01015a7:	00 
f01015a8:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01015af:	e8 02 eb ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015b7:	39 c7                	cmp    %eax,%edi
f01015b9:	74 04                	je     f01015bf <mem_init+0x4a1>
f01015bb:	39 c6                	cmp    %eax,%esi
f01015bd:	75 24                	jne    f01015e3 <mem_init+0x4c5>
f01015bf:	c7 44 24 0c 84 4c 10 	movl   $0xf0104c84,0xc(%esp)
f01015c6:	f0 
f01015c7:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01015ce:	f0 
f01015cf:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f01015d6:	00 
f01015d7:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01015de:	e8 d3 ea ff ff       	call   f01000b6 <_panic>
	assert(!page_alloc(0));
f01015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ea:	e8 ea f7 ff ff       	call   f0100dd9 <page_alloc>
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	74 24                	je     f0101617 <mem_init+0x4f9>
f01015f3:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101602:	f0 
f0101603:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f010160a:	00 
f010160b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101612:	e8 9f ea ff ff       	call   f01000b6 <_panic>
f0101617:	89 f0                	mov    %esi,%eax
f0101619:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
f010161f:	c1 f8 03             	sar    $0x3,%eax
f0101622:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101625:	89 c2                	mov    %eax,%edx
f0101627:	c1 ea 0c             	shr    $0xc,%edx
f010162a:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
f0101630:	72 20                	jb     f0101652 <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101632:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101636:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f010163d:	f0 
f010163e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101645:	00 
f0101646:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
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
f010166a:	e8 78 2b 00 00       	call   f01041e7 <memset>
	page_free(pp0);
f010166f:	89 34 24             	mov    %esi,(%esp)
f0101672:	e8 ed f7 ff ff       	call   f0100e64 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010167e:	e8 56 f7 ff ff       	call   f0100dd9 <page_alloc>
f0101683:	85 c0                	test   %eax,%eax
f0101685:	75 24                	jne    f01016ab <mem_init+0x58d>
f0101687:	c7 44 24 0c 43 54 10 	movl   $0xf0105443,0xc(%esp)
f010168e:	f0 
f010168f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101696:	f0 
f0101697:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f010169e:	00 
f010169f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01016a6:	e8 0b ea ff ff       	call   f01000b6 <_panic>
	assert(pp && pp0 == pp);
f01016ab:	39 c6                	cmp    %eax,%esi
f01016ad:	74 24                	je     f01016d3 <mem_init+0x5b5>
f01016af:	c7 44 24 0c 61 54 10 	movl   $0xf0105461,0xc(%esp)
f01016b6:	f0 
f01016b7:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01016be:	f0 
f01016bf:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f01016c6:	00 
f01016c7:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01016ce:	e8 e3 e9 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016d3:	89 f0                	mov    %esi,%eax
f01016d5:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
f01016db:	c1 f8 03             	sar    $0x3,%eax
f01016de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016e1:	89 c2                	mov    %eax,%edx
f01016e3:	c1 ea 0c             	shr    $0xc,%edx
f01016e6:	3b 15 84 cd 17 f0    	cmp    0xf017cd84,%edx
f01016ec:	72 20                	jb     f010170e <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016f2:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101701:	00 
f0101702:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f0101709:	e8 a8 e9 ff ff       	call   f01000b6 <_panic>
f010170e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101714:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010171a:	80 38 00             	cmpb   $0x0,(%eax)
f010171d:	74 24                	je     f0101743 <mem_init+0x625>
f010171f:	c7 44 24 0c 71 54 10 	movl   $0xf0105471,0xc(%esp)
f0101726:	f0 
f0101727:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010172e:	f0 
f010172f:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101736:	00 
f0101737:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f010174d:	a3 bc c0 17 f0       	mov    %eax,0xf017c0bc

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
f010176d:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
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
f0101781:	c7 44 24 0c 7b 54 10 	movl   $0xf010547b,0xc(%esp)
f0101788:	f0 
f0101789:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101790:	f0 
f0101791:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101798:	00 
f0101799:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01017a0:	e8 11 e9 ff ff       	call   f01000b6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017a5:	c7 04 24 a4 4c 10 f0 	movl   $0xf0104ca4,(%esp)
f01017ac:	e8 c6 1a 00 00       	call   f0103277 <cprintf>
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
f01017c4:	c7 44 24 0c 89 53 10 	movl   $0xf0105389,0xc(%esp)
f01017cb:	f0 
f01017cc:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01017e3:	e8 ce e8 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ef:	e8 e5 f5 ff ff       	call   f0100dd9 <page_alloc>
f01017f4:	89 c3                	mov    %eax,%ebx
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	75 24                	jne    f010181e <mem_init+0x700>
f01017fa:	c7 44 24 0c 9f 53 10 	movl   $0xf010539f,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101819:	e8 98 e8 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f010181e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101825:	e8 af f5 ff ff       	call   f0100dd9 <page_alloc>
f010182a:	89 c6                	mov    %eax,%esi
f010182c:	85 c0                	test   %eax,%eax
f010182e:	75 24                	jne    f0101854 <mem_init+0x736>
f0101830:	c7 44 24 0c b5 53 10 	movl   $0xf01053b5,0xc(%esp)
f0101837:	f0 
f0101838:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010183f:	f0 
f0101840:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101847:	00 
f0101848:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010184f:	e8 62 e8 ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101854:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101857:	75 24                	jne    f010187d <mem_init+0x75f>
f0101859:	c7 44 24 0c cb 53 10 	movl   $0xf01053cb,0xc(%esp)
f0101860:	f0 
f0101861:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101868:	f0 
f0101869:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101870:	00 
f0101871:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101878:	e8 39 e8 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010187d:	39 c3                	cmp    %eax,%ebx
f010187f:	74 05                	je     f0101886 <mem_init+0x768>
f0101881:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101884:	75 24                	jne    f01018aa <mem_init+0x78c>
f0101886:	c7 44 24 0c 84 4c 10 	movl   $0xf0104c84,0xc(%esp)
f010188d:	f0 
f010188e:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01018a5:	e8 0c e8 ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018aa:	a1 bc c0 17 f0       	mov    0xf017c0bc,%eax
f01018af:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018b2:	c7 05 bc c0 17 f0 00 	movl   $0x0,0xf017c0bc
f01018b9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018c3:	e8 11 f5 ff ff       	call   f0100dd9 <page_alloc>
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	74 24                	je     f01018f0 <mem_init+0x7d2>
f01018cc:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f01018d3:	f0 
f01018d4:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01018db:	f0 
f01018dc:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01018e3:	00 
f01018e4:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01018eb:	e8 c6 e7 ff ff       	call   f01000b6 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018fe:	00 
f01018ff:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101904:	89 04 24             	mov    %eax,(%esp)
f0101907:	e8 bc f6 ff ff       	call   f0100fc8 <page_lookup>
f010190c:	85 c0                	test   %eax,%eax
f010190e:	74 24                	je     f0101934 <mem_init+0x816>
f0101910:	c7 44 24 0c c4 4c 10 	movl   $0xf0104cc4,0xc(%esp)
f0101917:	f0 
f0101918:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010191f:	f0 
f0101920:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101927:	00 
f0101928:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010192f:	e8 82 e7 ff ff       	call   f01000b6 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101934:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010193b:	00 
f010193c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101943:	00 
f0101944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101948:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f010194d:	89 04 24             	mov    %eax,(%esp)
f0101950:	e8 36 f7 ff ff       	call   f010108b <page_insert>
f0101955:	85 c0                	test   %eax,%eax
f0101957:	78 24                	js     f010197d <mem_init+0x85f>
f0101959:	c7 44 24 0c fc 4c 10 	movl   $0xf0104cfc,0xc(%esp)
f0101960:	f0 
f0101961:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101968:	f0 
f0101969:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101970:	00 
f0101971:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f010199c:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01019a1:	89 04 24             	mov    %eax,(%esp)
f01019a4:	e8 e2 f6 ff ff       	call   f010108b <page_insert>
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	74 24                	je     f01019d1 <mem_init+0x8b3>
f01019ad:	c7 44 24 0c 2c 4d 10 	movl   $0xf0104d2c,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01019cc:	e8 e5 e6 ff ff       	call   f01000b6 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019d1:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019d7:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
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
f01019f8:	c7 44 24 0c 5c 4d 10 	movl   $0xf0104d5c,0xc(%esp)
f01019ff:	f0 
f0101a00:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101a07:	f0 
f0101a08:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101a0f:	00 
f0101a10:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101a37:	c7 44 24 0c 84 4d 10 	movl   $0xf0104d84,0xc(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101a4e:	00 
f0101a4f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101a56:	e8 5b e6 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0101a5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a60:	74 24                	je     f0101a86 <mem_init+0x968>
f0101a62:	c7 44 24 0c 86 54 10 	movl   $0xf0105486,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101a81:	e8 30 e6 ff ff       	call   f01000b6 <_panic>
	assert(pp0->pp_ref == 1);
f0101a86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a89:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a8e:	74 24                	je     f0101ab4 <mem_init+0x996>
f0101a90:	c7 44 24 0c 97 54 10 	movl   $0xf0105497,0xc(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101ad4:	c7 44 24 0c b4 4d 10 	movl   $0xf0104db4,0xc(%esp)
f0101adb:	f0 
f0101adc:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101ae3:	f0 
f0101ae4:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101aeb:	00 
f0101aec:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101af3:	e8 be e5 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101af8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101afd:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101b02:	e8 31 ee ff ff       	call   f0100938 <check_va2pa>
f0101b07:	89 f2                	mov    %esi,%edx
f0101b09:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f0101b0f:	c1 fa 03             	sar    $0x3,%edx
f0101b12:	c1 e2 0c             	shl    $0xc,%edx
f0101b15:	39 d0                	cmp    %edx,%eax
f0101b17:	74 24                	je     f0101b3d <mem_init+0xa1f>
f0101b19:	c7 44 24 0c f0 4d 10 	movl   $0xf0104df0,0xc(%esp)
f0101b20:	f0 
f0101b21:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101b38:	e8 79 e5 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101b3d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b42:	74 24                	je     f0101b68 <mem_init+0xa4a>
f0101b44:	c7 44 24 0c a8 54 10 	movl   $0xf01054a8,0xc(%esp)
f0101b4b:	f0 
f0101b4c:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101b53:	f0 
f0101b54:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101b5b:	00 
f0101b5c:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101b63:	e8 4e e5 ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6f:	e8 65 f2 ff ff       	call   f0100dd9 <page_alloc>
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	74 24                	je     f0101b9c <mem_init+0xa7e>
f0101b78:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f0101b7f:	f0 
f0101b80:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101b8f:	00 
f0101b90:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101b97:	e8 1a e5 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b9c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ba3:	00 
f0101ba4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bab:	00 
f0101bac:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bb0:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101bb5:	89 04 24             	mov    %eax,(%esp)
f0101bb8:	e8 ce f4 ff ff       	call   f010108b <page_insert>
f0101bbd:	85 c0                	test   %eax,%eax
f0101bbf:	74 24                	je     f0101be5 <mem_init+0xac7>
f0101bc1:	c7 44 24 0c b4 4d 10 	movl   $0xf0104db4,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101be0:	e8 d1 e4 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101be5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bea:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101bef:	e8 44 ed ff ff       	call   f0100938 <check_va2pa>
f0101bf4:	89 f2                	mov    %esi,%edx
f0101bf6:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f0101bfc:	c1 fa 03             	sar    $0x3,%edx
f0101bff:	c1 e2 0c             	shl    $0xc,%edx
f0101c02:	39 d0                	cmp    %edx,%eax
f0101c04:	74 24                	je     f0101c2a <mem_init+0xb0c>
f0101c06:	c7 44 24 0c f0 4d 10 	movl   $0xf0104df0,0xc(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101c15:	f0 
f0101c16:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101c1d:	00 
f0101c1e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101c25:	e8 8c e4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101c2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c2f:	74 24                	je     f0101c55 <mem_init+0xb37>
f0101c31:	c7 44 24 0c a8 54 10 	movl   $0xf01054a8,0xc(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101c40:	f0 
f0101c41:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0101c48:	00 
f0101c49:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101c50:	e8 61 e4 ff ff       	call   f01000b6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5c:	e8 78 f1 ff ff       	call   f0100dd9 <page_alloc>
f0101c61:	85 c0                	test   %eax,%eax
f0101c63:	74 24                	je     f0101c89 <mem_init+0xb6b>
f0101c65:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f0101c6c:	f0 
f0101c6d:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101c74:	f0 
f0101c75:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101c7c:	00 
f0101c7d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101c84:	e8 2d e4 ff ff       	call   f01000b6 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c89:	8b 15 88 cd 17 f0    	mov    0xf017cd88,%edx
f0101c8f:	8b 02                	mov    (%edx),%eax
f0101c91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c96:	89 c1                	mov    %eax,%ecx
f0101c98:	c1 e9 0c             	shr    $0xc,%ecx
f0101c9b:	3b 0d 84 cd 17 f0    	cmp    0xf017cd84,%ecx
f0101ca1:	72 20                	jb     f0101cc3 <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ca7:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101cb6:	00 
f0101cb7:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101ced:	c7 44 24 0c 20 4e 10 	movl   $0xf0104e20,0xc(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101cfc:	f0 
f0101cfd:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101d04:	00 
f0101d05:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101d0c:	e8 a5 e3 ff ff       	call   f01000b6 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d18:	00 
f0101d19:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d20:	00 
f0101d21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d25:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101d2a:	89 04 24             	mov    %eax,(%esp)
f0101d2d:	e8 59 f3 ff ff       	call   f010108b <page_insert>
f0101d32:	85 c0                	test   %eax,%eax
f0101d34:	74 24                	je     f0101d5a <mem_init+0xc3c>
f0101d36:	c7 44 24 0c 60 4e 10 	movl   $0xf0104e60,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101d55:	e8 5c e3 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d5a:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
f0101d60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d65:	89 f8                	mov    %edi,%eax
f0101d67:	e8 cc eb ff ff       	call   f0100938 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d6c:	89 f2                	mov    %esi,%edx
f0101d6e:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f0101d74:	c1 fa 03             	sar    $0x3,%edx
f0101d77:	c1 e2 0c             	shl    $0xc,%edx
f0101d7a:	39 d0                	cmp    %edx,%eax
f0101d7c:	74 24                	je     f0101da2 <mem_init+0xc84>
f0101d7e:	c7 44 24 0c f0 4d 10 	movl   $0xf0104df0,0xc(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101d95:	00 
f0101d96:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101d9d:	e8 14 e3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101da2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101da7:	74 24                	je     f0101dcd <mem_init+0xcaf>
f0101da9:	c7 44 24 0c a8 54 10 	movl   $0xf01054a8,0xc(%esp)
f0101db0:	f0 
f0101db1:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101dc0:	00 
f0101dc1:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101dea:	c7 44 24 0c a0 4e 10 	movl   $0xf0104ea0,0xc(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101e01:	00 
f0101e02:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101e09:	e8 a8 e2 ff ff       	call   f01000b6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e0e:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101e13:	f6 00 04             	testb  $0x4,(%eax)
f0101e16:	75 24                	jne    f0101e3c <mem_init+0xd1e>
f0101e18:	c7 44 24 0c b9 54 10 	movl   $0xf01054b9,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0101e5c:	c7 44 24 0c b4 4d 10 	movl   $0xf0104db4,0xc(%esp)
f0101e63:	f0 
f0101e64:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101e73:	00 
f0101e74:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101e7b:	e8 36 e2 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e87:	00 
f0101e88:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e8f:	00 
f0101e90:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101e95:	89 04 24             	mov    %eax,(%esp)
f0101e98:	e8 2a f0 ff ff       	call   f0100ec7 <pgdir_walk>
f0101e9d:	f6 00 02             	testb  $0x2,(%eax)
f0101ea0:	75 24                	jne    f0101ec6 <mem_init+0xda8>
f0101ea2:	c7 44 24 0c d4 4e 10 	movl   $0xf0104ed4,0xc(%esp)
f0101ea9:	f0 
f0101eaa:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101eb9:	00 
f0101eba:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101ec1:	e8 f0 e1 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ec6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ecd:	00 
f0101ece:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ed5:	00 
f0101ed6:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101edb:	89 04 24             	mov    %eax,(%esp)
f0101ede:	e8 e4 ef ff ff       	call   f0100ec7 <pgdir_walk>
f0101ee3:	f6 00 04             	testb  $0x4,(%eax)
f0101ee6:	74 24                	je     f0101f0c <mem_init+0xdee>
f0101ee8:	c7 44 24 0c 08 4f 10 	movl   $0xf0104f08,0xc(%esp)
f0101eef:	f0 
f0101ef0:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101ef7:	f0 
f0101ef8:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101eff:	00 
f0101f00:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101f07:	e8 aa e1 ff ff       	call   f01000b6 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f0c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f13:	00 
f0101f14:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f1b:	00 
f0101f1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f23:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101f28:	89 04 24             	mov    %eax,(%esp)
f0101f2b:	e8 5b f1 ff ff       	call   f010108b <page_insert>
f0101f30:	85 c0                	test   %eax,%eax
f0101f32:	78 24                	js     f0101f58 <mem_init+0xe3a>
f0101f34:	c7 44 24 0c 40 4f 10 	movl   $0xf0104f40,0xc(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101f43:	f0 
f0101f44:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101f4b:	00 
f0101f4c:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101f53:	e8 5e e1 ff ff       	call   f01000b6 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f58:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f5f:	00 
f0101f60:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f67:	00 
f0101f68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f6c:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101f71:	89 04 24             	mov    %eax,(%esp)
f0101f74:	e8 12 f1 ff ff       	call   f010108b <page_insert>
f0101f79:	85 c0                	test   %eax,%eax
f0101f7b:	74 24                	je     f0101fa1 <mem_init+0xe83>
f0101f7d:	c7 44 24 0c 78 4f 10 	movl   $0xf0104f78,0xc(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101f8c:	f0 
f0101f8d:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101f94:	00 
f0101f95:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101f9c:	e8 15 e1 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fa1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa8:	00 
f0101fa9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fb0:	00 
f0101fb1:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0101fb6:	89 04 24             	mov    %eax,(%esp)
f0101fb9:	e8 09 ef ff ff       	call   f0100ec7 <pgdir_walk>
f0101fbe:	f6 00 04             	testb  $0x4,(%eax)
f0101fc1:	74 24                	je     f0101fe7 <mem_init+0xec9>
f0101fc3:	c7 44 24 0c 08 4f 10 	movl   $0xf0104f08,0xc(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101fda:	00 
f0101fdb:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0101fe2:	e8 cf e0 ff ff       	call   f01000b6 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fe7:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
f0101fed:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff2:	89 f8                	mov    %edi,%eax
f0101ff4:	e8 3f e9 ff ff       	call   f0100938 <check_va2pa>
f0101ff9:	89 c1                	mov    %eax,%ecx
f0101ffb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ffe:	89 d8                	mov    %ebx,%eax
f0102000:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
f0102006:	c1 f8 03             	sar    $0x3,%eax
f0102009:	c1 e0 0c             	shl    $0xc,%eax
f010200c:	39 c1                	cmp    %eax,%ecx
f010200e:	74 24                	je     f0102034 <mem_init+0xf16>
f0102010:	c7 44 24 0c b4 4f 10 	movl   $0xf0104fb4,0xc(%esp)
f0102017:	f0 
f0102018:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010202f:	e8 82 e0 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102034:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102039:	89 f8                	mov    %edi,%eax
f010203b:	e8 f8 e8 ff ff       	call   f0100938 <check_va2pa>
f0102040:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102043:	74 24                	je     f0102069 <mem_init+0xf4b>
f0102045:	c7 44 24 0c e0 4f 10 	movl   $0xf0104fe0,0xc(%esp)
f010204c:	f0 
f010204d:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102054:	f0 
f0102055:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f010205c:	00 
f010205d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102064:	e8 4d e0 ff ff       	call   f01000b6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102069:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010206e:	74 24                	je     f0102094 <mem_init+0xf76>
f0102070:	c7 44 24 0c cf 54 10 	movl   $0xf01054cf,0xc(%esp)
f0102077:	f0 
f0102078:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010207f:	f0 
f0102080:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102087:	00 
f0102088:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010208f:	e8 22 e0 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102094:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102099:	74 24                	je     f01020bf <mem_init+0xfa1>
f010209b:	c7 44 24 0c e0 54 10 	movl   $0xf01054e0,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01020ba:	e8 f7 df ff ff       	call   f01000b6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020c6:	e8 0e ed ff ff       	call   f0100dd9 <page_alloc>
f01020cb:	85 c0                	test   %eax,%eax
f01020cd:	74 04                	je     f01020d3 <mem_init+0xfb5>
f01020cf:	39 c6                	cmp    %eax,%esi
f01020d1:	74 24                	je     f01020f7 <mem_init+0xfd9>
f01020d3:	c7 44 24 0c 10 50 10 	movl   $0xf0105010,0xc(%esp)
f01020da:	f0 
f01020db:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01020ea:	00 
f01020eb:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01020f2:	e8 bf df ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020fe:	00 
f01020ff:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102104:	89 04 24             	mov    %eax,(%esp)
f0102107:	e8 31 ef ff ff       	call   f010103d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010210c:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
f0102112:	ba 00 00 00 00       	mov    $0x0,%edx
f0102117:	89 f8                	mov    %edi,%eax
f0102119:	e8 1a e8 ff ff       	call   f0100938 <check_va2pa>
f010211e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102121:	74 24                	je     f0102147 <mem_init+0x1029>
f0102123:	c7 44 24 0c 34 50 10 	movl   $0xf0105034,0xc(%esp)
f010212a:	f0 
f010212b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102132:	f0 
f0102133:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f010213a:	00 
f010213b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102142:	e8 6f df ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102147:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214c:	89 f8                	mov    %edi,%eax
f010214e:	e8 e5 e7 ff ff       	call   f0100938 <check_va2pa>
f0102153:	89 da                	mov    %ebx,%edx
f0102155:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f010215b:	c1 fa 03             	sar    $0x3,%edx
f010215e:	c1 e2 0c             	shl    $0xc,%edx
f0102161:	39 d0                	cmp    %edx,%eax
f0102163:	74 24                	je     f0102189 <mem_init+0x106b>
f0102165:	c7 44 24 0c e0 4f 10 	movl   $0xf0104fe0,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102184:	e8 2d df ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0102189:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010218e:	74 24                	je     f01021b4 <mem_init+0x1096>
f0102190:	c7 44 24 0c 86 54 10 	movl   $0xf0105486,0xc(%esp)
f0102197:	f0 
f0102198:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f01021a7:	00 
f01021a8:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01021af:	e8 02 df ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f01021b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021b9:	74 24                	je     f01021df <mem_init+0x10c1>
f01021bb:	c7 44 24 0c e0 54 10 	movl   $0xf01054e0,0xc(%esp)
f01021c2:	f0 
f01021c3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01021ca:	f0 
f01021cb:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01021d2:	00 
f01021d3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01021ff:	c7 44 24 0c 58 50 10 	movl   $0xf0105058,0xc(%esp)
f0102206:	f0 
f0102207:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010220e:	f0 
f010220f:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0102216:	00 
f0102217:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010221e:	e8 93 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref);
f0102223:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102228:	75 24                	jne    f010224e <mem_init+0x1130>
f010222a:	c7 44 24 0c f1 54 10 	movl   $0xf01054f1,0xc(%esp)
f0102231:	f0 
f0102232:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102239:	f0 
f010223a:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102241:	00 
f0102242:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102249:	e8 68 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_link == NULL);
f010224e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102251:	74 24                	je     f0102277 <mem_init+0x1159>
f0102253:	c7 44 24 0c fd 54 10 	movl   $0xf01054fd,0xc(%esp)
f010225a:	f0 
f010225b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102262:	f0 
f0102263:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f010226a:	00 
f010226b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102272:	e8 3f de ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102277:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010227e:	00 
f010227f:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102284:	89 04 24             	mov    %eax,(%esp)
f0102287:	e8 b1 ed ff ff       	call   f010103d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010228c:	8b 3d 88 cd 17 f0    	mov    0xf017cd88,%edi
f0102292:	ba 00 00 00 00       	mov    $0x0,%edx
f0102297:	89 f8                	mov    %edi,%eax
f0102299:	e8 9a e6 ff ff       	call   f0100938 <check_va2pa>
f010229e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a1:	74 24                	je     f01022c7 <mem_init+0x11a9>
f01022a3:	c7 44 24 0c 34 50 10 	movl   $0xf0105034,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01022c2:	e8 ef dd ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022c7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022cc:	89 f8                	mov    %edi,%eax
f01022ce:	e8 65 e6 ff ff       	call   f0100938 <check_va2pa>
f01022d3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022d6:	74 24                	je     f01022fc <mem_init+0x11de>
f01022d8:	c7 44 24 0c 90 50 10 	movl   $0xf0105090,0xc(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01022ef:	00 
f01022f0:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01022f7:	e8 ba dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f01022fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102301:	74 24                	je     f0102327 <mem_init+0x1209>
f0102303:	c7 44 24 0c 12 55 10 	movl   $0xf0105512,0xc(%esp)
f010230a:	f0 
f010230b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102322:	e8 8f dd ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102327:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010232c:	74 24                	je     f0102352 <mem_init+0x1234>
f010232e:	c7 44 24 0c e0 54 10 	movl   $0xf01054e0,0xc(%esp)
f0102335:	f0 
f0102336:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f010233d:	f0 
f010233e:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102345:	00 
f0102346:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f010234d:	e8 64 dd ff ff       	call   f01000b6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102352:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102359:	e8 7b ea ff ff       	call   f0100dd9 <page_alloc>
f010235e:	85 c0                	test   %eax,%eax
f0102360:	74 04                	je     f0102366 <mem_init+0x1248>
f0102362:	39 c3                	cmp    %eax,%ebx
f0102364:	74 24                	je     f010238a <mem_init+0x126c>
f0102366:	c7 44 24 0c b8 50 10 	movl   $0xf01050b8,0xc(%esp)
f010236d:	f0 
f010236e:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102375:	f0 
f0102376:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010237d:	00 
f010237e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102385:	e8 2c dd ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010238a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102391:	e8 43 ea ff ff       	call   f0100dd9 <page_alloc>
f0102396:	85 c0                	test   %eax,%eax
f0102398:	74 24                	je     f01023be <mem_init+0x12a0>
f010239a:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01023b9:	e8 f8 dc ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023be:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01023c3:	8b 08                	mov    (%eax),%ecx
f01023c5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023ce:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f01023d4:	c1 fa 03             	sar    $0x3,%edx
f01023d7:	c1 e2 0c             	shl    $0xc,%edx
f01023da:	39 d1                	cmp    %edx,%ecx
f01023dc:	74 24                	je     f0102402 <mem_init+0x12e4>
f01023de:	c7 44 24 0c 5c 4d 10 	movl   $0xf0104d5c,0xc(%esp)
f01023e5:	f0 
f01023e6:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01023ed:	f0 
f01023ee:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01023f5:	00 
f01023f6:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01023fd:	e8 b4 dc ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010240b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102410:	74 24                	je     f0102436 <mem_init+0x1318>
f0102412:	c7 44 24 0c 97 54 10 	movl   $0xf0105497,0xc(%esp)
f0102419:	f0 
f010241a:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102421:	f0 
f0102422:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102429:	00 
f010242a:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102457:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f010245c:	89 04 24             	mov    %eax,(%esp)
f010245f:	e8 63 ea ff ff       	call   f0100ec7 <pgdir_walk>
f0102464:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102467:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010246a:	8b 15 88 cd 17 f0    	mov    0xf017cd88,%edx
f0102470:	8b 7a 04             	mov    0x4(%edx),%edi
f0102473:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102479:	8b 0d 84 cd 17 f0    	mov    0xf017cd84,%ecx
f010247f:	89 f8                	mov    %edi,%eax
f0102481:	c1 e8 0c             	shr    $0xc,%eax
f0102484:	39 c8                	cmp    %ecx,%eax
f0102486:	72 20                	jb     f01024a8 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102488:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010248c:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0102493:	f0 
f0102494:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f010249b:	00 
f010249c:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01024a3:	e8 0e dc ff ff       	call   f01000b6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024a8:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01024ae:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01024b1:	74 24                	je     f01024d7 <mem_init+0x13b9>
f01024b3:	c7 44 24 0c 23 55 10 	movl   $0xf0105523,0xc(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01024ca:	00 
f01024cb:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01024e7:	2b 05 8c cd 17 f0    	sub    0xf017cd8c,%eax
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
f0102500:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0102507:	f0 
f0102508:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010250f:	00 
f0102510:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
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
f0102534:	e8 ae 1c 00 00       	call   f01041e7 <memset>
	page_free(pp0);
f0102539:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010253c:	89 3c 24             	mov    %edi,(%esp)
f010253f:	e8 20 e9 ff ff       	call   f0100e64 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102544:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010254b:	00 
f010254c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102553:	00 
f0102554:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102559:	89 04 24             	mov    %eax,(%esp)
f010255c:	e8 66 e9 ff ff       	call   f0100ec7 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102561:	89 fa                	mov    %edi,%edx
f0102563:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f0102569:	c1 fa 03             	sar    $0x3,%edx
f010256c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010256f:	89 d0                	mov    %edx,%eax
f0102571:	c1 e8 0c             	shr    $0xc,%eax
f0102574:	3b 05 84 cd 17 f0    	cmp    0xf017cd84,%eax
f010257a:	72 20                	jb     f010259c <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010257c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102580:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f0102587:	f0 
f0102588:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010258f:	00 
f0102590:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
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
f01025b0:	c7 44 24 0c 3b 55 10 	movl   $0xf010553b,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01025db:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01025e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025e9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01025ef:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01025f2:	89 3d bc c0 17 f0    	mov    %edi,0xf017c0bc

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
f0102610:	c7 04 24 52 55 10 f0 	movl   $0xf0105552,(%esp)
f0102617:	e8 5b 0c 00 00       	call   f0103277 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010261c:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
f0102621:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102628:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	 boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), perm);
f010262e:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102633:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102638:	77 20                	ja     f010265a <mem_init+0x153c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010263e:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102645:	f0 
f0102646:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010264d:	00 
f010264e:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102655:	e8 5c da ff ff       	call   f01000b6 <_panic>
f010265a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102661:	00 
	return (physaddr_t)kva - KERNBASE;
f0102662:	05 00 00 00 10       	add    $0x10000000,%eax
f0102667:	89 04 24             	mov    %eax,(%esp)
f010266a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010266f:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102674:	e8 ee e8 ff ff       	call   f0100f67 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f0102679:	a1 c8 c0 17 f0       	mov    0xf017c0c8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010267e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102683:	77 20                	ja     f01026a5 <mem_init+0x1587>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102685:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102689:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102690:	f0 
f0102691:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0102698:	00 
f0102699:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01026a0:	e8 11 da ff ff       	call   f01000b6 <_panic>
f01026a5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01026ac:	00 
	return (physaddr_t)kva - KERNBASE;
f01026ad:	05 00 00 00 10       	add    $0x10000000,%eax
f01026b2:	89 04 24             	mov    %eax,(%esp)
f01026b5:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026ba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026bf:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f01026c4:	e8 9e e8 ff ff       	call   f0100f67 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c9:	bb 00 00 11 f0       	mov    $0xf0110000,%ebx
f01026ce:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026d4:	77 20                	ja     f01026f6 <mem_init+0x15d8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01026da:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f01026e1:	f0 
f01026e2:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f01026e9:	00 
f01026ea:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01026f1:	e8 c0 d9 ff ff       	call   f01000b6 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f01026f6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01026fd:	00 
f01026fe:	c7 04 24 00 00 11 00 	movl   $0x110000,(%esp)
f0102705:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010270a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010270f:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
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
f0102732:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102737:	e8 2b e8 ff ff       	call   f0100f67 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010273c:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102741:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102744:	a1 84 cd 17 f0       	mov    0xf017cd84,%eax
f0102749:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010274c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102753:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102758:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010275b:	8b 3d 8c cd 17 f0    	mov    0xf017cd8c,%edi
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
f010278f:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102796:	f0 
f0102797:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f010279e:	00 
f010279f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01027a6:	e8 0b d9 ff ff       	call   f01000b6 <_panic>
f01027ab:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01027ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01027b1:	39 d0                	cmp    %edx,%eax
f01027b3:	74 24                	je     f01027d9 <mem_init+0x16bb>
f01027b5:	c7 44 24 0c dc 50 10 	movl   $0xf01050dc,0xc(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01027c4:	f0 
f01027c5:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f01027cc:	00 
f01027cd:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01027e4:	8b 35 c8 c0 17 f0    	mov    0xf017c0c8,%esi
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
f0102805:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f010280c:	f0 
f010280d:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0102814:	00 
f0102815:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102833:	c7 44 24 0c 10 51 10 	movl   $0xf0105110,0xc(%esp)
f010283a:	f0 
f010283b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102842:	f0 
f0102843:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010284a:	00 
f010284b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102888:	c7 44 24 0c 44 51 10 	movl   $0xf0105144,0xc(%esp)
f010288f:	f0 
f0102890:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102897:	f0 
f0102898:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f010289f:	00 
f01028a0:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f01028d2:	c7 44 24 0c 6c 51 10 	movl   $0xf010516c,0xc(%esp)
f01028d9:	f0 
f01028da:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f01028e9:	00 
f01028ea:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102924:	c7 44 24 0c b4 51 10 	movl   $0xf01051b4,0xc(%esp)
f010292b:	f0 
f010292c:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102933:	f0 
f0102934:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f010293b:	00 
f010293c:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102967:	c7 44 24 0c 6b 55 10 	movl   $0xf010556b,0xc(%esp)
f010296e:	f0 
f010296f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102976:	f0 
f0102977:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010297e:	00 
f010297f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f010299a:	c7 44 24 0c 6b 55 10 	movl   $0xf010556b,0xc(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01029a9:	f0 
f01029aa:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01029b1:	00 
f01029b2:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01029b9:	e8 f8 d6 ff ff       	call   f01000b6 <_panic>
				assert(pgdir[i] & PTE_W);
f01029be:	f6 c1 02             	test   $0x2,%cl
f01029c1:	75 4e                	jne    f0102a11 <mem_init+0x18f3>
f01029c3:	c7 44 24 0c 7c 55 10 	movl   $0xf010557c,0xc(%esp)
f01029ca:	f0 
f01029cb:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01029d2:	f0 
f01029d3:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f01029da:	00 
f01029db:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f01029e2:	e8 cf d6 ff ff       	call   f01000b6 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029e7:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f01029eb:	74 24                	je     f0102a11 <mem_init+0x18f3>
f01029ed:	c7 44 24 0c 8d 55 10 	movl   $0xf010558d,0xc(%esp)
f01029f4:	f0 
f01029f5:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f01029fc:	f0 
f01029fd:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0102a04:	00 
f0102a05:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102a1f:	c7 04 24 e4 51 10 f0 	movl   $0xf01051e4,(%esp)
f0102a26:	e8 4c 08 00 00       	call   f0103277 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a2b:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102a30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a35:	77 20                	ja     f0102a57 <mem_init+0x1939>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a3b:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f0102a4a:	00 
f0102a4b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102a89:	c7 44 24 0c 89 53 10 	movl   $0xf0105389,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102aa8:	e8 09 d6 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102aad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab4:	e8 20 e3 ff ff       	call   f0100dd9 <page_alloc>
f0102ab9:	89 c7                	mov    %eax,%edi
f0102abb:	85 c0                	test   %eax,%eax
f0102abd:	75 24                	jne    f0102ae3 <mem_init+0x19c5>
f0102abf:	c7 44 24 0c 9f 53 10 	movl   $0xf010539f,0xc(%esp)
f0102ac6:	f0 
f0102ac7:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102ad6:	00 
f0102ad7:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102ade:	e8 d3 d5 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ae3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aea:	e8 ea e2 ff ff       	call   f0100dd9 <page_alloc>
f0102aef:	89 c6                	mov    %eax,%esi
f0102af1:	85 c0                	test   %eax,%eax
f0102af3:	75 24                	jne    f0102b19 <mem_init+0x19fb>
f0102af5:	c7 44 24 0c b5 53 10 	movl   $0xf01053b5,0xc(%esp)
f0102afc:	f0 
f0102afd:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102b04:	f0 
f0102b05:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0102b0c:	00 
f0102b0d:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
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
f0102b3b:	e8 a7 16 00 00       	call   f01041e7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b40:	89 f0                	mov    %esi,%eax
f0102b42:	e8 ac dd ff ff       	call   f01008f3 <page2kva>
f0102b47:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b4e:	00 
f0102b4f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b56:	00 
f0102b57:	89 04 24             	mov    %eax,(%esp)
f0102b5a:	e8 88 16 00 00       	call   f01041e7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b5f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b66:	00 
f0102b67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b6e:	00 
f0102b6f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b73:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102b78:	89 04 24             	mov    %eax,(%esp)
f0102b7b:	e8 0b e5 ff ff       	call   f010108b <page_insert>
	assert(pp1->pp_ref == 1);
f0102b80:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b85:	74 24                	je     f0102bab <mem_init+0x1a8d>
f0102b87:	c7 44 24 0c 86 54 10 	movl   $0xf0105486,0xc(%esp)
f0102b8e:	f0 
f0102b8f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102b96:	f0 
f0102b97:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102b9e:	00 
f0102b9f:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102ba6:	e8 0b d5 ff ff       	call   f01000b6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bab:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bb2:	01 01 01 
f0102bb5:	74 24                	je     f0102bdb <mem_init+0x1abd>
f0102bb7:	c7 44 24 0c 04 52 10 	movl   $0xf0105204,0xc(%esp)
f0102bbe:	f0 
f0102bbf:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102bc6:	f0 
f0102bc7:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0102bce:	00 
f0102bcf:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102bd6:	e8 db d4 ff ff       	call   f01000b6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bdb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102be2:	00 
f0102be3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bea:	00 
f0102beb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bef:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102bf4:	89 04 24             	mov    %eax,(%esp)
f0102bf7:	e8 8f e4 ff ff       	call   f010108b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bfc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c03:	02 02 02 
f0102c06:	74 24                	je     f0102c2c <mem_init+0x1b0e>
f0102c08:	c7 44 24 0c 28 52 10 	movl   $0xf0105228,0xc(%esp)
f0102c0f:	f0 
f0102c10:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102c1f:	00 
f0102c20:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102c27:	e8 8a d4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0102c2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c31:	74 24                	je     f0102c57 <mem_init+0x1b39>
f0102c33:	c7 44 24 0c a8 54 10 	movl   $0xf01054a8,0xc(%esp)
f0102c3a:	f0 
f0102c3b:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102c42:	f0 
f0102c43:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102c4a:	00 
f0102c4b:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102c52:	e8 5f d4 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102c57:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c5c:	74 24                	je     f0102c82 <mem_init+0x1b64>
f0102c5e:	c7 44 24 0c 12 55 10 	movl   $0xf0105512,0xc(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102c6d:	f0 
f0102c6e:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102c75:	00 
f0102c76:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102c7d:	e8 34 d4 ff ff       	call   f01000b6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c82:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c89:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c8c:	89 f0                	mov    %esi,%eax
f0102c8e:	e8 60 dc ff ff       	call   f01008f3 <page2kva>
f0102c93:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102c99:	74 24                	je     f0102cbf <mem_init+0x1ba1>
f0102c9b:	c7 44 24 0c 4c 52 10 	movl   $0xf010524c,0xc(%esp)
f0102ca2:	f0 
f0102ca3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102caa:	f0 
f0102cab:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102cb2:	00 
f0102cb3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102cba:	e8 f7 d3 ff ff       	call   f01000b6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cbf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102cc6:	00 
f0102cc7:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102ccc:	89 04 24             	mov    %eax,(%esp)
f0102ccf:	e8 69 e3 ff ff       	call   f010103d <page_remove>
	assert(pp2->pp_ref == 0);
f0102cd4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cd9:	74 24                	je     f0102cff <mem_init+0x1be1>
f0102cdb:	c7 44 24 0c e0 54 10 	movl   $0xf01054e0,0xc(%esp)
f0102ce2:	f0 
f0102ce3:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102cea:	f0 
f0102ceb:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102cf2:	00 
f0102cf3:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102cfa:	e8 b7 d3 ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cff:	a1 88 cd 17 f0       	mov    0xf017cd88,%eax
f0102d04:	8b 08                	mov    (%eax),%ecx
f0102d06:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d0c:	89 da                	mov    %ebx,%edx
f0102d0e:	2b 15 8c cd 17 f0    	sub    0xf017cd8c,%edx
f0102d14:	c1 fa 03             	sar    $0x3,%edx
f0102d17:	c1 e2 0c             	shl    $0xc,%edx
f0102d1a:	39 d1                	cmp    %edx,%ecx
f0102d1c:	74 24                	je     f0102d42 <mem_init+0x1c24>
f0102d1e:	c7 44 24 0c 5c 4d 10 	movl   $0xf0104d5c,0xc(%esp)
f0102d25:	f0 
f0102d26:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102d35:	00 
f0102d36:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102d3d:	e8 74 d3 ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102d42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d48:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d4d:	74 24                	je     f0102d73 <mem_init+0x1c55>
f0102d4f:	c7 44 24 0c 97 54 10 	movl   $0xf0105497,0xc(%esp)
f0102d56:	f0 
f0102d57:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0102d5e:	f0 
f0102d5f:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102d66:	00 
f0102d67:	c7 04 24 af 52 10 f0 	movl   $0xf01052af,(%esp)
f0102d6e:	e8 43 d3 ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102d73:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d79:	89 1c 24             	mov    %ebx,(%esp)
f0102d7c:	e8 e3 e0 ff ff       	call   f0100e64 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d81:	c7 04 24 78 52 10 f0 	movl   $0xf0105278,(%esp)
f0102d88:	e8 ea 04 00 00       	call   f0103277 <cprintf>
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

f0102dc0 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102dc0:	55                   	push   %ebp
f0102dc1:	89 e5                	mov    %esp,%ebp
f0102dc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102dc9:	85 c0                	test   %eax,%eax
f0102dcb:	75 11                	jne    f0102dde <envid2env+0x1e>
		*env_store = curenv;
f0102dcd:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f0102dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102dd5:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102dd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ddc:	eb 5e                	jmp    f0102e3c <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102dde:	89 c2                	mov    %eax,%edx
f0102de0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102de6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102de9:	c1 e2 05             	shl    $0x5,%edx
f0102dec:	03 15 c8 c0 17 f0    	add    0xf017c0c8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102df2:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102df6:	74 05                	je     f0102dfd <envid2env+0x3d>
f0102df8:	39 42 48             	cmp    %eax,0x48(%edx)
f0102dfb:	74 10                	je     f0102e0d <envid2env+0x4d>
		*env_store = 0;
f0102dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e06:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e0b:	eb 2f                	jmp    f0102e3c <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e0d:	84 c9                	test   %cl,%cl
f0102e0f:	74 21                	je     f0102e32 <envid2env+0x72>
f0102e11:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f0102e16:	39 c2                	cmp    %eax,%edx
f0102e18:	74 18                	je     f0102e32 <envid2env+0x72>
f0102e1a:	8b 40 48             	mov    0x48(%eax),%eax
f0102e1d:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102e20:	74 10                	je     f0102e32 <envid2env+0x72>
		*env_store = 0;
f0102e22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e2b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e30:	eb 0a                	jmp    f0102e3c <envid2env+0x7c>
	}

	*env_store = e;
f0102e32:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e35:	89 10                	mov    %edx,(%eax)
	return 0;
f0102e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e3c:	5d                   	pop    %ebp
f0102e3d:	c3                   	ret    

f0102e3e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102e3e:	55                   	push   %ebp
f0102e3f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102e41:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102e46:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102e49:	b8 23 00 00 00       	mov    $0x23,%eax
f0102e4e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102e50:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102e52:	b0 10                	mov    $0x10,%al
f0102e54:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102e56:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102e58:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102e5a:	ea 61 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102e61
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102e61:	b0 00                	mov    $0x0,%al
f0102e63:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102e66:	5d                   	pop    %ebp
f0102e67:	c3                   	ret    

f0102e68 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102e68:	55                   	push   %ebp
f0102e69:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102e6b:	e8 ce ff ff ff       	call   f0102e3e <env_init_percpu>
}
f0102e70:	5d                   	pop    %ebp
f0102e71:	c3                   	ret    

f0102e72 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e72:	55                   	push   %ebp
f0102e73:	89 e5                	mov    %esp,%ebp
f0102e75:	53                   	push   %ebx
f0102e76:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e79:	8b 1d cc c0 17 f0    	mov    0xf017c0cc,%ebx
f0102e7f:	85 db                	test   %ebx,%ebx
f0102e81:	0f 84 08 01 00 00    	je     f0102f8f <env_alloc+0x11d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102e8e:	e8 46 df ff ff       	call   f0100dd9 <page_alloc>
f0102e93:	85 c0                	test   %eax,%eax
f0102e95:	0f 84 fb 00 00 00    	je     f0102f96 <env_alloc+0x124>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102e9b:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ea3:	77 20                	ja     f0102ec5 <env_alloc+0x53>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ea9:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102eb0:	f0 
f0102eb1:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102eb8:	00 
f0102eb9:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f0102ec0:	e8 f1 d1 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ec5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ecb:	83 ca 05             	or     $0x5,%edx
f0102ece:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ed4:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ed7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102edc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ee1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ee6:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ee9:	89 da                	mov    %ebx,%edx
f0102eeb:	2b 15 c8 c0 17 f0    	sub    0xf017c0c8,%edx
f0102ef1:	c1 fa 05             	sar    $0x5,%edx
f0102ef4:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102efa:	09 d0                	or     %edx,%eax
f0102efc:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102eff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f02:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102f05:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102f0c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f13:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f1a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102f21:	00 
f0102f22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f29:	00 
f0102f2a:	89 1c 24             	mov    %ebx,(%esp)
f0102f2d:	e8 b5 12 00 00       	call   f01041e7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f32:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f38:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f3e:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f44:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f4b:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102f51:	8b 43 44             	mov    0x44(%ebx),%eax
f0102f54:	a3 cc c0 17 f0       	mov    %eax,0xf017c0cc
	*newenv_store = e;
f0102f59:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f5c:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102f5e:	8b 53 48             	mov    0x48(%ebx),%edx
f0102f61:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f0102f66:	85 c0                	test   %eax,%eax
f0102f68:	74 05                	je     f0102f6f <env_alloc+0xfd>
f0102f6a:	8b 40 48             	mov    0x48(%eax),%eax
f0102f6d:	eb 05                	jmp    f0102f74 <env_alloc+0x102>
f0102f6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f74:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102f78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f7c:	c7 04 24 dd 55 10 f0 	movl   $0xf01055dd,(%esp)
f0102f83:	e8 ef 02 00 00       	call   f0103277 <cprintf>
	return 0;
f0102f88:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8d:	eb 0c                	jmp    f0102f9b <env_alloc+0x129>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102f8f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102f94:	eb 05                	jmp    f0102f9b <env_alloc+0x129>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102f96:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102f9b:	83 c4 14             	add    $0x14,%esp
f0102f9e:	5b                   	pop    %ebx
f0102f9f:	5d                   	pop    %ebp
f0102fa0:	c3                   	ret    

f0102fa1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102fa1:	55                   	push   %ebp
f0102fa2:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102fa4:	5d                   	pop    %ebp
f0102fa5:	c3                   	ret    

f0102fa6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102fa6:	55                   	push   %ebp
f0102fa7:	89 e5                	mov    %esp,%ebp
f0102fa9:	57                   	push   %edi
f0102faa:	56                   	push   %esi
f0102fab:	53                   	push   %ebx
f0102fac:	83 ec 2c             	sub    $0x2c,%esp
f0102faf:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102fb2:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f0102fb7:	39 c7                	cmp    %eax,%edi
f0102fb9:	75 37                	jne    f0102ff2 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0102fbb:	8b 15 88 cd 17 f0    	mov    0xf017cd88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fc7:	77 20                	ja     f0102fe9 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fcd:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0102fdc:	00 
f0102fdd:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f0102fe4:	e8 cd d0 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102fe9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102fef:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ff2:	8b 57 48             	mov    0x48(%edi),%edx
f0102ff5:	85 c0                	test   %eax,%eax
f0102ff7:	74 05                	je     f0102ffe <env_free+0x58>
f0102ff9:	8b 40 48             	mov    0x48(%eax),%eax
f0102ffc:	eb 05                	jmp    f0103003 <env_free+0x5d>
f0102ffe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103003:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010300b:	c7 04 24 f2 55 10 f0 	movl   $0xf01055f2,(%esp)
f0103012:	e8 60 02 00 00       	call   f0103277 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103017:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010301e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103021:	89 c8                	mov    %ecx,%eax
f0103023:	c1 e0 02             	shl    $0x2,%eax
f0103026:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103029:	8b 47 5c             	mov    0x5c(%edi),%eax
f010302c:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f010302f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103035:	0f 84 b7 00 00 00    	je     f01030f2 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010303b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103041:	89 f0                	mov    %esi,%eax
f0103043:	c1 e8 0c             	shr    $0xc,%eax
f0103046:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103049:	3b 05 84 cd 17 f0    	cmp    0xf017cd84,%eax
f010304f:	72 20                	jb     f0103071 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103051:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103055:	c7 44 24 08 1c 4b 10 	movl   $0xf0104b1c,0x8(%esp)
f010305c:	f0 
f010305d:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103064:	00 
f0103065:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f010306c:	e8 45 d0 ff ff       	call   f01000b6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103071:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103074:	c1 e0 16             	shl    $0x16,%eax
f0103077:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010307a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010307f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103086:	01 
f0103087:	74 17                	je     f01030a0 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103089:	89 d8                	mov    %ebx,%eax
f010308b:	c1 e0 0c             	shl    $0xc,%eax
f010308e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103091:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103095:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103098:	89 04 24             	mov    %eax,(%esp)
f010309b:	e8 9d df ff ff       	call   f010103d <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030a0:	83 c3 01             	add    $0x1,%ebx
f01030a3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01030a9:	75 d4                	jne    f010307f <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01030ab:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01030b1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01030bb:	3b 05 84 cd 17 f0    	cmp    0xf017cd84,%eax
f01030c1:	72 1c                	jb     f01030df <env_free+0x139>
		panic("pa2page called with invalid pa");
f01030c3:	c7 44 24 08 04 4c 10 	movl   $0xf0104c04,0x8(%esp)
f01030ca:	f0 
f01030cb:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01030d2:	00 
f01030d3:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f01030da:	e8 d7 cf ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f01030df:	a1 8c cd 17 f0       	mov    0xf017cd8c,%eax
f01030e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01030e7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f01030ea:	89 04 24             	mov    %eax,(%esp)
f01030ed:	e8 b2 dd ff ff       	call   f0100ea4 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01030f2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01030f6:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01030fd:	0f 85 1b ff ff ff    	jne    f010301e <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103103:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103106:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010310b:	77 20                	ja     f010312d <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103111:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f0103118:	f0 
f0103119:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0103120:	00 
f0103121:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f0103128:	e8 89 cf ff ff       	call   f01000b6 <_panic>
	e->env_pgdir = 0;
f010312d:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103134:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103139:	c1 e8 0c             	shr    $0xc,%eax
f010313c:	3b 05 84 cd 17 f0    	cmp    0xf017cd84,%eax
f0103142:	72 1c                	jb     f0103160 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103144:	c7 44 24 08 04 4c 10 	movl   $0xf0104c04,0x8(%esp)
f010314b:	f0 
f010314c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103153:	00 
f0103154:	c7 04 24 a1 52 10 f0 	movl   $0xf01052a1,(%esp)
f010315b:	e8 56 cf ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103160:	8b 15 8c cd 17 f0    	mov    0xf017cd8c,%edx
f0103166:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103169:	89 04 24             	mov    %eax,(%esp)
f010316c:	e8 33 dd ff ff       	call   f0100ea4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103171:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103178:	a1 cc c0 17 f0       	mov    0xf017c0cc,%eax
f010317d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103180:	89 3d cc c0 17 f0    	mov    %edi,0xf017c0cc
}
f0103186:	83 c4 2c             	add    $0x2c,%esp
f0103189:	5b                   	pop    %ebx
f010318a:	5e                   	pop    %esi
f010318b:	5f                   	pop    %edi
f010318c:	5d                   	pop    %ebp
f010318d:	c3                   	ret    

f010318e <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010318e:	55                   	push   %ebp
f010318f:	89 e5                	mov    %esp,%ebp
f0103191:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103194:	8b 45 08             	mov    0x8(%ebp),%eax
f0103197:	89 04 24             	mov    %eax,(%esp)
f010319a:	e8 07 fe ff ff       	call   f0102fa6 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010319f:	c7 04 24 9c 55 10 f0 	movl   $0xf010559c,(%esp)
f01031a6:	e8 cc 00 00 00       	call   f0103277 <cprintf>
	while (1)
		monitor(NULL);
f01031ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031b2:	e8 a2 d5 ff ff       	call   f0100759 <monitor>
f01031b7:	eb f2                	jmp    f01031ab <env_destroy+0x1d>

f01031b9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01031b9:	55                   	push   %ebp
f01031ba:	89 e5                	mov    %esp,%ebp
f01031bc:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01031bf:	8b 65 08             	mov    0x8(%ebp),%esp
f01031c2:	61                   	popa   
f01031c3:	07                   	pop    %es
f01031c4:	1f                   	pop    %ds
f01031c5:	83 c4 08             	add    $0x8,%esp
f01031c8:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01031c9:	c7 44 24 08 08 56 10 	movl   $0xf0105608,0x8(%esp)
f01031d0:	f0 
f01031d1:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01031d8:	00 
f01031d9:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f01031e0:	e8 d1 ce ff ff       	call   f01000b6 <_panic>

f01031e5 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01031e5:	55                   	push   %ebp
f01031e6:	89 e5                	mov    %esp,%ebp
f01031e8:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01031eb:	c7 44 24 08 14 56 10 	movl   $0xf0105614,0x8(%esp)
f01031f2:	f0 
f01031f3:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f01031fa:	00 
f01031fb:	c7 04 24 d2 55 10 f0 	movl   $0xf01055d2,(%esp)
f0103202:	e8 af ce ff ff       	call   f01000b6 <_panic>

f0103207 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103207:	55                   	push   %ebp
f0103208:	89 e5                	mov    %esp,%ebp
f010320a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010320e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103213:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103214:	b2 71                	mov    $0x71,%dl
f0103216:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103217:	0f b6 c0             	movzbl %al,%eax
}
f010321a:	5d                   	pop    %ebp
f010321b:	c3                   	ret    

f010321c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010321c:	55                   	push   %ebp
f010321d:	89 e5                	mov    %esp,%ebp
f010321f:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103223:	ba 70 00 00 00       	mov    $0x70,%edx
f0103228:	ee                   	out    %al,(%dx)
f0103229:	b2 71                	mov    $0x71,%dl
f010322b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010322e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010322f:	5d                   	pop    %ebp
f0103230:	c3                   	ret    

f0103231 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103231:	55                   	push   %ebp
f0103232:	89 e5                	mov    %esp,%ebp
f0103234:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103237:	8b 45 08             	mov    0x8(%ebp),%eax
f010323a:	89 04 24             	mov    %eax,(%esp)
f010323d:	e8 cf d3 ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f0103242:	c9                   	leave  
f0103243:	c3                   	ret    

f0103244 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103244:	55                   	push   %ebp
f0103245:	89 e5                	mov    %esp,%ebp
f0103247:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010324a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103251:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103254:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103258:	8b 45 08             	mov    0x8(%ebp),%eax
f010325b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010325f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103262:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103266:	c7 04 24 31 32 10 f0 	movl   $0xf0103231,(%esp)
f010326d:	e8 32 08 00 00       	call   f0103aa4 <vprintfmt>
	return cnt;
}
f0103272:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103275:	c9                   	leave  
f0103276:	c3                   	ret    

f0103277 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103277:	55                   	push   %ebp
f0103278:	89 e5                	mov    %esp,%ebp
f010327a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010327d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103280:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103284:	8b 45 08             	mov    0x8(%ebp),%eax
f0103287:	89 04 24             	mov    %eax,(%esp)
f010328a:	e8 b5 ff ff ff       	call   f0103244 <vcprintf>
	va_end(ap);

	return cnt;
}
f010328f:	c9                   	leave  
f0103290:	c3                   	ret    

f0103291 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103291:	55                   	push   %ebp
f0103292:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103294:	c7 05 04 c9 17 f0 00 	movl   $0xf0000000,0xf017c904
f010329b:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010329e:	66 c7 05 08 c9 17 f0 	movw   $0x10,0xf017c908
f01032a5:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01032a7:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f01032ae:	67 00 
f01032b0:	b8 00 c9 17 f0       	mov    $0xf017c900,%eax
f01032b5:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f01032bb:	89 c2                	mov    %eax,%edx
f01032bd:	c1 ea 10             	shr    $0x10,%edx
f01032c0:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f01032c6:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f01032cd:	c1 e8 18             	shr    $0x18,%eax
f01032d0:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01032d5:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01032dc:	b8 28 00 00 00       	mov    $0x28,%eax
f01032e1:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01032e4:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f01032e9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01032ec:	5d                   	pop    %ebp
f01032ed:	c3                   	ret    

f01032ee <trap_init>:
}


void
trap_init(void)
{
f01032ee:	55                   	push   %ebp
f01032ef:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f01032f1:	e8 9b ff ff ff       	call   f0103291 <trap_init_percpu>
}
f01032f6:	5d                   	pop    %ebp
f01032f7:	c3                   	ret    

f01032f8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01032f8:	55                   	push   %ebp
f01032f9:	89 e5                	mov    %esp,%ebp
f01032fb:	53                   	push   %ebx
f01032fc:	83 ec 14             	sub    $0x14,%esp
f01032ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103302:	8b 03                	mov    (%ebx),%eax
f0103304:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103308:	c7 04 24 30 56 10 f0 	movl   $0xf0105630,(%esp)
f010330f:	e8 63 ff ff ff       	call   f0103277 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103314:	8b 43 04             	mov    0x4(%ebx),%eax
f0103317:	89 44 24 04          	mov    %eax,0x4(%esp)
f010331b:	c7 04 24 3f 56 10 f0 	movl   $0xf010563f,(%esp)
f0103322:	e8 50 ff ff ff       	call   f0103277 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103327:	8b 43 08             	mov    0x8(%ebx),%eax
f010332a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010332e:	c7 04 24 4e 56 10 f0 	movl   $0xf010564e,(%esp)
f0103335:	e8 3d ff ff ff       	call   f0103277 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010333a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010333d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103341:	c7 04 24 5d 56 10 f0 	movl   $0xf010565d,(%esp)
f0103348:	e8 2a ff ff ff       	call   f0103277 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010334d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103350:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103354:	c7 04 24 6c 56 10 f0 	movl   $0xf010566c,(%esp)
f010335b:	e8 17 ff ff ff       	call   f0103277 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103360:	8b 43 14             	mov    0x14(%ebx),%eax
f0103363:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103367:	c7 04 24 7b 56 10 f0 	movl   $0xf010567b,(%esp)
f010336e:	e8 04 ff ff ff       	call   f0103277 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103373:	8b 43 18             	mov    0x18(%ebx),%eax
f0103376:	89 44 24 04          	mov    %eax,0x4(%esp)
f010337a:	c7 04 24 8a 56 10 f0 	movl   $0xf010568a,(%esp)
f0103381:	e8 f1 fe ff ff       	call   f0103277 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103386:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103389:	89 44 24 04          	mov    %eax,0x4(%esp)
f010338d:	c7 04 24 99 56 10 f0 	movl   $0xf0105699,(%esp)
f0103394:	e8 de fe ff ff       	call   f0103277 <cprintf>
}
f0103399:	83 c4 14             	add    $0x14,%esp
f010339c:	5b                   	pop    %ebx
f010339d:	5d                   	pop    %ebp
f010339e:	c3                   	ret    

f010339f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010339f:	55                   	push   %ebp
f01033a0:	89 e5                	mov    %esp,%ebp
f01033a2:	56                   	push   %esi
f01033a3:	53                   	push   %ebx
f01033a4:	83 ec 10             	sub    $0x10,%esp
f01033a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01033aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033ae:	c7 04 24 cf 57 10 f0 	movl   $0xf01057cf,(%esp)
f01033b5:	e8 bd fe ff ff       	call   f0103277 <cprintf>
	print_regs(&tf->tf_regs);
f01033ba:	89 1c 24             	mov    %ebx,(%esp)
f01033bd:	e8 36 ff ff ff       	call   f01032f8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033c2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033ca:	c7 04 24 ea 56 10 f0 	movl   $0xf01056ea,(%esp)
f01033d1:	e8 a1 fe ff ff       	call   f0103277 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033d6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033de:	c7 04 24 fd 56 10 f0 	movl   $0xf01056fd,(%esp)
f01033e5:	e8 8d fe ff ff       	call   f0103277 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033ea:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01033ed:	83 f8 13             	cmp    $0x13,%eax
f01033f0:	77 09                	ja     f01033fb <print_trapframe+0x5c>
		return excnames[trapno];
f01033f2:	8b 14 85 a0 59 10 f0 	mov    -0xfefa660(,%eax,4),%edx
f01033f9:	eb 10                	jmp    f010340b <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f01033fb:	83 f8 30             	cmp    $0x30,%eax
f01033fe:	ba a8 56 10 f0       	mov    $0xf01056a8,%edx
f0103403:	b9 b4 56 10 f0       	mov    $0xf01056b4,%ecx
f0103408:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010340b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010340f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103413:	c7 04 24 10 57 10 f0 	movl   $0xf0105710,(%esp)
f010341a:	e8 58 fe ff ff       	call   f0103277 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010341f:	3b 1d e0 c8 17 f0    	cmp    0xf017c8e0,%ebx
f0103425:	75 19                	jne    f0103440 <print_trapframe+0xa1>
f0103427:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010342b:	75 13                	jne    f0103440 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010342d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103430:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103434:	c7 04 24 22 57 10 f0 	movl   $0xf0105722,(%esp)
f010343b:	e8 37 fe ff ff       	call   f0103277 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103440:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103443:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103447:	c7 04 24 31 57 10 f0 	movl   $0xf0105731,(%esp)
f010344e:	e8 24 fe ff ff       	call   f0103277 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103453:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103457:	75 51                	jne    f01034aa <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103459:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010345c:	89 c2                	mov    %eax,%edx
f010345e:	83 e2 01             	and    $0x1,%edx
f0103461:	ba c3 56 10 f0       	mov    $0xf01056c3,%edx
f0103466:	b9 ce 56 10 f0       	mov    $0xf01056ce,%ecx
f010346b:	0f 45 ca             	cmovne %edx,%ecx
f010346e:	89 c2                	mov    %eax,%edx
f0103470:	83 e2 02             	and    $0x2,%edx
f0103473:	ba da 56 10 f0       	mov    $0xf01056da,%edx
f0103478:	be e0 56 10 f0       	mov    $0xf01056e0,%esi
f010347d:	0f 44 d6             	cmove  %esi,%edx
f0103480:	83 e0 04             	and    $0x4,%eax
f0103483:	b8 e5 56 10 f0       	mov    $0xf01056e5,%eax
f0103488:	be fa 57 10 f0       	mov    $0xf01057fa,%esi
f010348d:	0f 44 c6             	cmove  %esi,%eax
f0103490:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103494:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103498:	89 44 24 04          	mov    %eax,0x4(%esp)
f010349c:	c7 04 24 3f 57 10 f0 	movl   $0xf010573f,(%esp)
f01034a3:	e8 cf fd ff ff       	call   f0103277 <cprintf>
f01034a8:	eb 0c                	jmp    f01034b6 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01034aa:	c7 04 24 69 55 10 f0 	movl   $0xf0105569,(%esp)
f01034b1:	e8 c1 fd ff ff       	call   f0103277 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01034b6:	8b 43 30             	mov    0x30(%ebx),%eax
f01034b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034bd:	c7 04 24 4e 57 10 f0 	movl   $0xf010574e,(%esp)
f01034c4:	e8 ae fd ff ff       	call   f0103277 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01034c9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034d1:	c7 04 24 5d 57 10 f0 	movl   $0xf010575d,(%esp)
f01034d8:	e8 9a fd ff ff       	call   f0103277 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01034dd:	8b 43 38             	mov    0x38(%ebx),%eax
f01034e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e4:	c7 04 24 70 57 10 f0 	movl   $0xf0105770,(%esp)
f01034eb:	e8 87 fd ff ff       	call   f0103277 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01034f0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034f4:	74 27                	je     f010351d <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01034f6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01034f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034fd:	c7 04 24 7f 57 10 f0 	movl   $0xf010577f,(%esp)
f0103504:	e8 6e fd ff ff       	call   f0103277 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103509:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010350d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103511:	c7 04 24 8e 57 10 f0 	movl   $0xf010578e,(%esp)
f0103518:	e8 5a fd ff ff       	call   f0103277 <cprintf>
	}
}
f010351d:	83 c4 10             	add    $0x10,%esp
f0103520:	5b                   	pop    %ebx
f0103521:	5e                   	pop    %esi
f0103522:	5d                   	pop    %ebp
f0103523:	c3                   	ret    

f0103524 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103524:	55                   	push   %ebp
f0103525:	89 e5                	mov    %esp,%ebp
f0103527:	57                   	push   %edi
f0103528:	56                   	push   %esi
f0103529:	83 ec 10             	sub    $0x10,%esp
f010352c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010352f:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103530:	9c                   	pushf  
f0103531:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103532:	f6 c4 02             	test   $0x2,%ah
f0103535:	74 24                	je     f010355b <trap+0x37>
f0103537:	c7 44 24 0c a1 57 10 	movl   $0xf01057a1,0xc(%esp)
f010353e:	f0 
f010353f:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0103546:	f0 
f0103547:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f010354e:	00 
f010354f:	c7 04 24 ba 57 10 f0 	movl   $0xf01057ba,(%esp)
f0103556:	e8 5b cb ff ff       	call   f01000b6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010355b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010355f:	c7 04 24 c6 57 10 f0 	movl   $0xf01057c6,(%esp)
f0103566:	e8 0c fd ff ff       	call   f0103277 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010356b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010356f:	83 e0 03             	and    $0x3,%eax
f0103572:	66 83 f8 03          	cmp    $0x3,%ax
f0103576:	75 3c                	jne    f01035b4 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f0103578:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f010357d:	85 c0                	test   %eax,%eax
f010357f:	75 24                	jne    f01035a5 <trap+0x81>
f0103581:	c7 44 24 0c e1 57 10 	movl   $0xf01057e1,0xc(%esp)
f0103588:	f0 
f0103589:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0103590:	f0 
f0103591:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f0103598:	00 
f0103599:	c7 04 24 ba 57 10 f0 	movl   $0xf01057ba,(%esp)
f01035a0:	e8 11 cb ff ff       	call   f01000b6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01035a5:	b9 11 00 00 00       	mov    $0x11,%ecx
f01035aa:	89 c7                	mov    %eax,%edi
f01035ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01035ae:	8b 35 c4 c0 17 f0    	mov    0xf017c0c4,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01035b4:	89 35 e0 c8 17 f0    	mov    %esi,0xf017c8e0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01035ba:	89 34 24             	mov    %esi,(%esp)
f01035bd:	e8 dd fd ff ff       	call   f010339f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01035c2:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01035c7:	75 1c                	jne    f01035e5 <trap+0xc1>
		panic("unhandled trap in kernel");
f01035c9:	c7 44 24 08 e8 57 10 	movl   $0xf01057e8,0x8(%esp)
f01035d0:	f0 
f01035d1:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f01035d8:	00 
f01035d9:	c7 04 24 ba 57 10 f0 	movl   $0xf01057ba,(%esp)
f01035e0:	e8 d1 ca ff ff       	call   f01000b6 <_panic>
	else {
		env_destroy(curenv);
f01035e5:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f01035ea:	89 04 24             	mov    %eax,(%esp)
f01035ed:	e8 9c fb ff ff       	call   f010318e <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01035f2:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f01035f7:	85 c0                	test   %eax,%eax
f01035f9:	74 06                	je     f0103601 <trap+0xdd>
f01035fb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035ff:	74 24                	je     f0103625 <trap+0x101>
f0103601:	c7 44 24 0c 44 59 10 	movl   $0xf0105944,0xc(%esp)
f0103608:	f0 
f0103609:	c7 44 24 08 c7 52 10 	movl   $0xf01052c7,0x8(%esp)
f0103610:	f0 
f0103611:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0103618:	00 
f0103619:	c7 04 24 ba 57 10 f0 	movl   $0xf01057ba,(%esp)
f0103620:	e8 91 ca ff ff       	call   f01000b6 <_panic>
	env_run(curenv);
f0103625:	89 04 24             	mov    %eax,(%esp)
f0103628:	e8 b8 fb ff ff       	call   f01031e5 <env_run>

f010362d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010362d:	55                   	push   %ebp
f010362e:	89 e5                	mov    %esp,%ebp
f0103630:	53                   	push   %ebx
f0103631:	83 ec 14             	sub    $0x14,%esp
f0103634:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103637:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010363a:	8b 53 30             	mov    0x30(%ebx),%edx
f010363d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103641:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103645:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f010364a:	8b 40 48             	mov    0x48(%eax),%eax
f010364d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103651:	c7 04 24 70 59 10 f0 	movl   $0xf0105970,(%esp)
f0103658:	e8 1a fc ff ff       	call   f0103277 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010365d:	89 1c 24             	mov    %ebx,(%esp)
f0103660:	e8 3a fd ff ff       	call   f010339f <print_trapframe>
	env_destroy(curenv);
f0103665:	a1 c4 c0 17 f0       	mov    0xf017c0c4,%eax
f010366a:	89 04 24             	mov    %eax,(%esp)
f010366d:	e8 1c fb ff ff       	call   f010318e <env_destroy>
}
f0103672:	83 c4 14             	add    $0x14,%esp
f0103675:	5b                   	pop    %ebx
f0103676:	5d                   	pop    %ebp
f0103677:	c3                   	ret    

f0103678 <syscall>:
f0103678:	55                   	push   %ebp
f0103679:	89 e5                	mov    %esp,%ebp
f010367b:	83 ec 18             	sub    $0x18,%esp
f010367e:	c7 44 24 08 f0 59 10 	movl   $0xf01059f0,0x8(%esp)
f0103685:	f0 
f0103686:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f010368d:	00 
f010368e:	c7 04 24 08 5a 10 f0 	movl   $0xf0105a08,(%esp)
f0103695:	e8 1c ca ff ff       	call   f01000b6 <_panic>

f010369a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010369a:	55                   	push   %ebp
f010369b:	89 e5                	mov    %esp,%ebp
f010369d:	57                   	push   %edi
f010369e:	56                   	push   %esi
f010369f:	53                   	push   %ebx
f01036a0:	83 ec 14             	sub    $0x14,%esp
f01036a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01036a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01036a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01036ac:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01036af:	8b 1a                	mov    (%edx),%ebx
f01036b1:	8b 01                	mov    (%ecx),%eax
f01036b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01036b6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01036bd:	e9 88 00 00 00       	jmp    f010374a <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01036c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01036c5:	01 d8                	add    %ebx,%eax
f01036c7:	89 c7                	mov    %eax,%edi
f01036c9:	c1 ef 1f             	shr    $0x1f,%edi
f01036cc:	01 c7                	add    %eax,%edi
f01036ce:	d1 ff                	sar    %edi
f01036d0:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01036d3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01036d6:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01036d9:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01036db:	eb 03                	jmp    f01036e0 <stab_binsearch+0x46>
			m--;
f01036dd:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01036e0:	39 c3                	cmp    %eax,%ebx
f01036e2:	7f 1f                	jg     f0103703 <stab_binsearch+0x69>
f01036e4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01036e8:	83 ea 0c             	sub    $0xc,%edx
f01036eb:	39 f1                	cmp    %esi,%ecx
f01036ed:	75 ee                	jne    f01036dd <stab_binsearch+0x43>
f01036ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01036f2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01036f5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01036f8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01036fc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01036ff:	76 18                	jbe    f0103719 <stab_binsearch+0x7f>
f0103701:	eb 05                	jmp    f0103708 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103703:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103706:	eb 42                	jmp    f010374a <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103708:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010370b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010370d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103710:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103717:	eb 31                	jmp    f010374a <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103719:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010371c:	73 17                	jae    f0103735 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010371e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103721:	83 e8 01             	sub    $0x1,%eax
f0103724:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103727:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010372a:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010372c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103733:	eb 15                	jmp    f010374a <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103738:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010373b:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010373d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103741:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103743:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010374a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010374d:	0f 8e 6f ff ff ff    	jle    f01036c2 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103753:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103757:	75 0f                	jne    f0103768 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0103759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010375c:	8b 00                	mov    (%eax),%eax
f010375e:	83 e8 01             	sub    $0x1,%eax
f0103761:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103764:	89 07                	mov    %eax,(%edi)
f0103766:	eb 2c                	jmp    f0103794 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103768:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010376b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010376d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103770:	8b 0f                	mov    (%edi),%ecx
f0103772:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103775:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103778:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010377b:	eb 03                	jmp    f0103780 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010377d:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103780:	39 c8                	cmp    %ecx,%eax
f0103782:	7e 0b                	jle    f010378f <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0103784:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103788:	83 ea 0c             	sub    $0xc,%edx
f010378b:	39 f3                	cmp    %esi,%ebx
f010378d:	75 ee                	jne    f010377d <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f010378f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103792:	89 07                	mov    %eax,(%edi)
	}
}
f0103794:	83 c4 14             	add    $0x14,%esp
f0103797:	5b                   	pop    %ebx
f0103798:	5e                   	pop    %esi
f0103799:	5f                   	pop    %edi
f010379a:	5d                   	pop    %ebp
f010379b:	c3                   	ret    

f010379c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010379c:	55                   	push   %ebp
f010379d:	89 e5                	mov    %esp,%ebp
f010379f:	57                   	push   %edi
f01037a0:	56                   	push   %esi
f01037a1:	53                   	push   %ebx
f01037a2:	83 ec 3c             	sub    $0x3c,%esp
f01037a5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01037a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01037ab:	c7 06 17 5a 10 f0    	movl   $0xf0105a17,(%esi)
	info->eip_line = 0;
f01037b1:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01037b8:	c7 46 08 17 5a 10 f0 	movl   $0xf0105a17,0x8(%esi)
	info->eip_fn_namelen = 9;
f01037bf:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01037c6:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01037c9:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01037d0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01037d6:	77 21                	ja     f01037f9 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01037d8:	a1 00 00 20 00       	mov    0x200000,%eax
f01037dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01037e0:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01037e5:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f01037eb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f01037ee:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f01037f4:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01037f7:	eb 1a                	jmp    f0103813 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01037f9:	c7 45 cc 41 f7 10 f0 	movl   $0xf010f741,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103800:	c7 45 d0 69 ce 10 f0 	movl   $0xf010ce69,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103807:	b8 68 ce 10 f0       	mov    $0xf010ce68,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010380c:	c7 45 d4 50 5c 10 f0 	movl   $0xf0105c50,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103813:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103816:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0103819:	0f 83 2f 01 00 00    	jae    f010394e <debuginfo_eip+0x1b2>
f010381f:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103823:	0f 85 2c 01 00 00    	jne    f0103955 <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103829:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103830:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103833:	29 d8                	sub    %ebx,%eax
f0103835:	c1 f8 02             	sar    $0x2,%eax
f0103838:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010383e:	83 e8 01             	sub    $0x1,%eax
f0103841:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103844:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103848:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010384f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103852:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103855:	89 d8                	mov    %ebx,%eax
f0103857:	e8 3e fe ff ff       	call   f010369a <stab_binsearch>
	if (lfile == 0)
f010385c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010385f:	85 c0                	test   %eax,%eax
f0103861:	0f 84 f5 00 00 00    	je     f010395c <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103867:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010386a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010386d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103870:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103874:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010387b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010387e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103881:	89 d8                	mov    %ebx,%eax
f0103883:	e8 12 fe ff ff       	call   f010369a <stab_binsearch>

	if (lfun <= rfun) {
f0103888:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010388b:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010388e:	7f 23                	jg     f01038b3 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103890:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103893:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103896:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103899:	8b 10                	mov    (%eax),%edx
f010389b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010389e:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f01038a1:	39 ca                	cmp    %ecx,%edx
f01038a3:	73 06                	jae    f01038ab <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01038a5:	03 55 d0             	add    -0x30(%ebp),%edx
f01038a8:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01038ab:	8b 40 08             	mov    0x8(%eax),%eax
f01038ae:	89 46 10             	mov    %eax,0x10(%esi)
f01038b1:	eb 06                	jmp    f01038b9 <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01038b3:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01038b6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01038b9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01038c0:	00 
f01038c1:	8b 46 08             	mov    0x8(%esi),%eax
f01038c4:	89 04 24             	mov    %eax,(%esp)
f01038c7:	e8 ff 08 00 00       	call   f01041cb <strfind>
f01038cc:	2b 46 08             	sub    0x8(%esi),%eax
f01038cf:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01038d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01038d5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01038d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01038db:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01038de:	eb 06                	jmp    f01038e6 <debuginfo_eip+0x14a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01038e0:	83 eb 01             	sub    $0x1,%ebx
f01038e3:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01038e6:	39 fb                	cmp    %edi,%ebx
f01038e8:	7c 2c                	jl     f0103916 <debuginfo_eip+0x17a>
	       && stabs[lline].n_type != N_SOL
f01038ea:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01038ee:	80 fa 84             	cmp    $0x84,%dl
f01038f1:	74 0b                	je     f01038fe <debuginfo_eip+0x162>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01038f3:	80 fa 64             	cmp    $0x64,%dl
f01038f6:	75 e8                	jne    f01038e0 <debuginfo_eip+0x144>
f01038f8:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01038fc:	74 e2                	je     f01038e0 <debuginfo_eip+0x144>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01038fe:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103901:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103904:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0103907:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010390a:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010390d:	39 d0                	cmp    %edx,%eax
f010390f:	73 05                	jae    f0103916 <debuginfo_eip+0x17a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103911:	03 45 d0             	add    -0x30(%ebp),%eax
f0103914:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103916:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103919:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010391c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103921:	39 cb                	cmp    %ecx,%ebx
f0103923:	7d 43                	jge    f0103968 <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f0103925:	8d 53 01             	lea    0x1(%ebx),%edx
f0103928:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010392b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010392e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103931:	eb 07                	jmp    f010393a <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103933:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103937:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010393a:	39 ca                	cmp    %ecx,%edx
f010393c:	74 25                	je     f0103963 <debuginfo_eip+0x1c7>
f010393e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103941:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103945:	74 ec                	je     f0103933 <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103947:	b8 00 00 00 00       	mov    $0x0,%eax
f010394c:	eb 1a                	jmp    f0103968 <debuginfo_eip+0x1cc>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010394e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103953:	eb 13                	jmp    f0103968 <debuginfo_eip+0x1cc>
f0103955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010395a:	eb 0c                	jmp    f0103968 <debuginfo_eip+0x1cc>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010395c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103961:	eb 05                	jmp    f0103968 <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103963:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103968:	83 c4 3c             	add    $0x3c,%esp
f010396b:	5b                   	pop    %ebx
f010396c:	5e                   	pop    %esi
f010396d:	5f                   	pop    %edi
f010396e:	5d                   	pop    %ebp
f010396f:	c3                   	ret    

f0103970 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103970:	55                   	push   %ebp
f0103971:	89 e5                	mov    %esp,%ebp
f0103973:	57                   	push   %edi
f0103974:	56                   	push   %esi
f0103975:	53                   	push   %ebx
f0103976:	83 ec 3c             	sub    $0x3c,%esp
f0103979:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010397c:	89 d7                	mov    %edx,%edi
f010397e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103981:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103984:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103987:	89 c3                	mov    %eax,%ebx
f0103989:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010398c:	8b 45 10             	mov    0x10(%ebp),%eax
f010398f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103992:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103997:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010399a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010399d:	39 d9                	cmp    %ebx,%ecx
f010399f:	72 05                	jb     f01039a6 <printnum+0x36>
f01039a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01039a4:	77 69                	ja     f0103a0f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01039a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01039a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01039ad:	83 ee 01             	sub    $0x1,%esi
f01039b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01039b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039b8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01039bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01039c0:	89 c3                	mov    %eax,%ebx
f01039c2:	89 d6                	mov    %edx,%esi
f01039c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01039c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01039ca:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01039d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039d5:	89 04 24             	mov    %eax,(%esp)
f01039d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039df:	e8 0c 0a 00 00       	call   f01043f0 <__udivdi3>
f01039e4:	89 d9                	mov    %ebx,%ecx
f01039e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01039ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01039ee:	89 04 24             	mov    %eax,(%esp)
f01039f1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01039f5:	89 fa                	mov    %edi,%edx
f01039f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039fa:	e8 71 ff ff ff       	call   f0103970 <printnum>
f01039ff:	eb 1b                	jmp    f0103a1c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103a01:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a05:	8b 45 18             	mov    0x18(%ebp),%eax
f0103a08:	89 04 24             	mov    %eax,(%esp)
f0103a0b:	ff d3                	call   *%ebx
f0103a0d:	eb 03                	jmp    f0103a12 <printnum+0xa2>
f0103a0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103a12:	83 ee 01             	sub    $0x1,%esi
f0103a15:	85 f6                	test   %esi,%esi
f0103a17:	7f e8                	jg     f0103a01 <printnum+0x91>
f0103a19:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103a1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a20:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103a24:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a27:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103a32:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a35:	89 04 24             	mov    %eax,(%esp)
f0103a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a3f:	e8 dc 0a 00 00       	call   f0104520 <__umoddi3>
f0103a44:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a48:	0f be 80 21 5a 10 f0 	movsbl -0xfefa5df(%eax),%eax
f0103a4f:	89 04 24             	mov    %eax,(%esp)
f0103a52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a55:	ff d0                	call   *%eax
}
f0103a57:	83 c4 3c             	add    $0x3c,%esp
f0103a5a:	5b                   	pop    %ebx
f0103a5b:	5e                   	pop    %esi
f0103a5c:	5f                   	pop    %edi
f0103a5d:	5d                   	pop    %ebp
f0103a5e:	c3                   	ret    

f0103a5f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103a5f:	55                   	push   %ebp
f0103a60:	89 e5                	mov    %esp,%ebp
f0103a62:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103a65:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103a69:	8b 10                	mov    (%eax),%edx
f0103a6b:	3b 50 04             	cmp    0x4(%eax),%edx
f0103a6e:	73 0a                	jae    f0103a7a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103a70:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103a73:	89 08                	mov    %ecx,(%eax)
f0103a75:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a78:	88 02                	mov    %al,(%edx)
}
f0103a7a:	5d                   	pop    %ebp
f0103a7b:	c3                   	ret    

f0103a7c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103a7c:	55                   	push   %ebp
f0103a7d:	89 e5                	mov    %esp,%ebp
f0103a7f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103a82:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103a85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a89:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a8c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a97:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a9a:	89 04 24             	mov    %eax,(%esp)
f0103a9d:	e8 02 00 00 00       	call   f0103aa4 <vprintfmt>
	va_end(ap);
}
f0103aa2:	c9                   	leave  
f0103aa3:	c3                   	ret    

f0103aa4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103aa4:	55                   	push   %ebp
f0103aa5:	89 e5                	mov    %esp,%ebp
f0103aa7:	57                   	push   %edi
f0103aa8:	56                   	push   %esi
f0103aa9:	53                   	push   %ebx
f0103aaa:	83 ec 3c             	sub    $0x3c,%esp
f0103aad:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ab3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103ab6:	eb 11                	jmp    f0103ac9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103ab8:	85 c0                	test   %eax,%eax
f0103aba:	0f 84 48 04 00 00    	je     f0103f08 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f0103ac0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ac4:	89 04 24             	mov    %eax,(%esp)
f0103ac7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103ac9:	83 c7 01             	add    $0x1,%edi
f0103acc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ad0:	83 f8 25             	cmp    $0x25,%eax
f0103ad3:	75 e3                	jne    f0103ab8 <vprintfmt+0x14>
f0103ad5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103ad9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103ae0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103ae7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103aee:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103af3:	eb 1f                	jmp    f0103b14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103af8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103afc:	eb 16                	jmp    f0103b14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103afe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103b01:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103b05:	eb 0d                	jmp    f0103b14 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103b07:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103b0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b0d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b14:	8d 47 01             	lea    0x1(%edi),%eax
f0103b17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b1a:	0f b6 17             	movzbl (%edi),%edx
f0103b1d:	0f b6 c2             	movzbl %dl,%eax
f0103b20:	83 ea 23             	sub    $0x23,%edx
f0103b23:	80 fa 55             	cmp    $0x55,%dl
f0103b26:	0f 87 bf 03 00 00    	ja     f0103eeb <vprintfmt+0x447>
f0103b2c:	0f b6 d2             	movzbl %dl,%edx
f0103b2f:	ff 24 95 c0 5a 10 f0 	jmp    *-0xfefa540(,%edx,4)
f0103b36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b39:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103b41:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103b44:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103b48:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103b4b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103b4e:	83 f9 09             	cmp    $0x9,%ecx
f0103b51:	77 3c                	ja     f0103b8f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103b53:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103b56:	eb e9                	jmp    f0103b41 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103b58:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b5b:	8b 00                	mov    (%eax),%eax
f0103b5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b60:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b63:	8d 40 04             	lea    0x4(%eax),%eax
f0103b66:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103b6c:	eb 27                	jmp    f0103b95 <vprintfmt+0xf1>
f0103b6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b71:	85 d2                	test   %edx,%edx
f0103b73:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b78:	0f 49 c2             	cmovns %edx,%eax
f0103b7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b81:	eb 91                	jmp    f0103b14 <vprintfmt+0x70>
f0103b83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103b86:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103b8d:	eb 85                	jmp    f0103b14 <vprintfmt+0x70>
f0103b8f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b92:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103b95:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b99:	0f 89 75 ff ff ff    	jns    f0103b14 <vprintfmt+0x70>
f0103b9f:	e9 63 ff ff ff       	jmp    f0103b07 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ba4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103baa:	e9 65 ff ff ff       	jmp    f0103b14 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103baf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103bb2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103bb6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bba:	8b 00                	mov    (%eax),%eax
f0103bbc:	89 04 24             	mov    %eax,(%esp)
f0103bbf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103bc4:	e9 00 ff ff ff       	jmp    f0103ac9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bc9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103bcc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103bd0:	8b 00                	mov    (%eax),%eax
f0103bd2:	99                   	cltd   
f0103bd3:	31 d0                	xor    %edx,%eax
f0103bd5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103bd7:	83 f8 07             	cmp    $0x7,%eax
f0103bda:	7f 0b                	jg     f0103be7 <vprintfmt+0x143>
f0103bdc:	8b 14 85 20 5c 10 f0 	mov    -0xfefa3e0(,%eax,4),%edx
f0103be3:	85 d2                	test   %edx,%edx
f0103be5:	75 20                	jne    f0103c07 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0103be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103beb:	c7 44 24 08 39 5a 10 	movl   $0xf0105a39,0x8(%esp)
f0103bf2:	f0 
f0103bf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bf7:	89 34 24             	mov    %esi,(%esp)
f0103bfa:	e8 7d fe ff ff       	call   f0103a7c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103c02:	e9 c2 fe ff ff       	jmp    f0103ac9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103c07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103c0b:	c7 44 24 08 d9 52 10 	movl   $0xf01052d9,0x8(%esp)
f0103c12:	f0 
f0103c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c17:	89 34 24             	mov    %esi,(%esp)
f0103c1a:	e8 5d fe ff ff       	call   f0103a7c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c22:	e9 a2 fe ff ff       	jmp    f0103ac9 <vprintfmt+0x25>
f0103c27:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c2a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103c2d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c30:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103c33:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0103c37:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103c39:	85 ff                	test   %edi,%edi
f0103c3b:	b8 32 5a 10 f0       	mov    $0xf0105a32,%eax
f0103c40:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103c43:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103c47:	0f 84 92 00 00 00    	je     f0103cdf <vprintfmt+0x23b>
f0103c4d:	85 c9                	test   %ecx,%ecx
f0103c4f:	0f 8e 98 00 00 00    	jle    f0103ced <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c55:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103c59:	89 3c 24             	mov    %edi,(%esp)
f0103c5c:	e8 17 04 00 00       	call   f0104078 <strnlen>
f0103c61:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103c64:	29 c1                	sub    %eax,%ecx
f0103c66:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0103c69:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103c6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103c70:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103c73:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c75:	eb 0f                	jmp    f0103c86 <vprintfmt+0x1e2>
					putch(padc, putdat);
f0103c77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c7e:	89 04 24             	mov    %eax,(%esp)
f0103c81:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c83:	83 ef 01             	sub    $0x1,%edi
f0103c86:	85 ff                	test   %edi,%edi
f0103c88:	7f ed                	jg     f0103c77 <vprintfmt+0x1d3>
f0103c8a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103c90:	85 c9                	test   %ecx,%ecx
f0103c92:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c97:	0f 49 c1             	cmovns %ecx,%eax
f0103c9a:	29 c1                	sub    %eax,%ecx
f0103c9c:	89 75 08             	mov    %esi,0x8(%ebp)
f0103c9f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ca2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ca5:	89 cb                	mov    %ecx,%ebx
f0103ca7:	eb 50                	jmp    f0103cf9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103ca9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103cad:	74 1e                	je     f0103ccd <vprintfmt+0x229>
f0103caf:	0f be d2             	movsbl %dl,%edx
f0103cb2:	83 ea 20             	sub    $0x20,%edx
f0103cb5:	83 fa 5e             	cmp    $0x5e,%edx
f0103cb8:	76 13                	jbe    f0103ccd <vprintfmt+0x229>
					putch('?', putdat);
f0103cba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103cc8:	ff 55 08             	call   *0x8(%ebp)
f0103ccb:	eb 0d                	jmp    f0103cda <vprintfmt+0x236>
				else
					putch(ch, putdat);
f0103ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103cd0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103cd4:	89 04 24             	mov    %eax,(%esp)
f0103cd7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103cda:	83 eb 01             	sub    $0x1,%ebx
f0103cdd:	eb 1a                	jmp    f0103cf9 <vprintfmt+0x255>
f0103cdf:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ce2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ce5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ce8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103ceb:	eb 0c                	jmp    f0103cf9 <vprintfmt+0x255>
f0103ced:	89 75 08             	mov    %esi,0x8(%ebp)
f0103cf0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103cf3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103cf6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103cf9:	83 c7 01             	add    $0x1,%edi
f0103cfc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103d00:	0f be c2             	movsbl %dl,%eax
f0103d03:	85 c0                	test   %eax,%eax
f0103d05:	74 25                	je     f0103d2c <vprintfmt+0x288>
f0103d07:	85 f6                	test   %esi,%esi
f0103d09:	78 9e                	js     f0103ca9 <vprintfmt+0x205>
f0103d0b:	83 ee 01             	sub    $0x1,%esi
f0103d0e:	79 99                	jns    f0103ca9 <vprintfmt+0x205>
f0103d10:	89 df                	mov    %ebx,%edi
f0103d12:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d18:	eb 1a                	jmp    f0103d34 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103d1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d1e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103d25:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103d27:	83 ef 01             	sub    $0x1,%edi
f0103d2a:	eb 08                	jmp    f0103d34 <vprintfmt+0x290>
f0103d2c:	89 df                	mov    %ebx,%edi
f0103d2e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d34:	85 ff                	test   %edi,%edi
f0103d36:	7f e2                	jg     f0103d1a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d3b:	e9 89 fd ff ff       	jmp    f0103ac9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103d40:	83 f9 01             	cmp    $0x1,%ecx
f0103d43:	7e 19                	jle    f0103d5e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0103d45:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d48:	8b 50 04             	mov    0x4(%eax),%edx
f0103d4b:	8b 00                	mov    (%eax),%eax
f0103d4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d50:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103d53:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d56:	8d 40 08             	lea    0x8(%eax),%eax
f0103d59:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d5c:	eb 38                	jmp    f0103d96 <vprintfmt+0x2f2>
	else if (lflag)
f0103d5e:	85 c9                	test   %ecx,%ecx
f0103d60:	74 1b                	je     f0103d7d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0103d62:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d65:	8b 00                	mov    (%eax),%eax
f0103d67:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d6a:	89 c1                	mov    %eax,%ecx
f0103d6c:	c1 f9 1f             	sar    $0x1f,%ecx
f0103d6f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103d72:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d75:	8d 40 04             	lea    0x4(%eax),%eax
f0103d78:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d7b:	eb 19                	jmp    f0103d96 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f0103d7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d80:	8b 00                	mov    (%eax),%eax
f0103d82:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d85:	89 c1                	mov    %eax,%ecx
f0103d87:	c1 f9 1f             	sar    $0x1f,%ecx
f0103d8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103d8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d90:	8d 40 04             	lea    0x4(%eax),%eax
f0103d93:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103d96:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d99:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103d9c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103da1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103da5:	0f 89 04 01 00 00    	jns    f0103eaf <vprintfmt+0x40b>
				putch('-', putdat);
f0103dab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103daf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103db6:	ff d6                	call   *%esi
				num = -(long long) num;
f0103db8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103dbb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103dbe:	f7 da                	neg    %edx
f0103dc0:	83 d1 00             	adc    $0x0,%ecx
f0103dc3:	f7 d9                	neg    %ecx
f0103dc5:	e9 e5 00 00 00       	jmp    f0103eaf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103dca:	83 f9 01             	cmp    $0x1,%ecx
f0103dcd:	7e 10                	jle    f0103ddf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f0103dcf:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dd2:	8b 10                	mov    (%eax),%edx
f0103dd4:	8b 48 04             	mov    0x4(%eax),%ecx
f0103dd7:	8d 40 08             	lea    0x8(%eax),%eax
f0103dda:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ddd:	eb 26                	jmp    f0103e05 <vprintfmt+0x361>
	else if (lflag)
f0103ddf:	85 c9                	test   %ecx,%ecx
f0103de1:	74 12                	je     f0103df5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0103de3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103de6:	8b 10                	mov    (%eax),%edx
f0103de8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ded:	8d 40 04             	lea    0x4(%eax),%eax
f0103df0:	89 45 14             	mov    %eax,0x14(%ebp)
f0103df3:	eb 10                	jmp    f0103e05 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0103df5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103df8:	8b 10                	mov    (%eax),%edx
f0103dfa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dff:	8d 40 04             	lea    0x4(%eax),%eax
f0103e02:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103e05:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0103e0a:	e9 a0 00 00 00       	jmp    f0103eaf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0103e0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e13:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103e1a:	ff d6                	call   *%esi
			putch('X', putdat);
f0103e1c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e20:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103e27:	ff d6                	call   *%esi
			putch('X', putdat);
f0103e29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e2d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0103e34:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103e39:	e9 8b fc ff ff       	jmp    f0103ac9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f0103e3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e42:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103e49:	ff d6                	call   *%esi
			putch('x', putdat);
f0103e4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e4f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103e56:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103e58:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e5b:	8b 10                	mov    (%eax),%edx
f0103e5d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0103e62:	8d 40 04             	lea    0x4(%eax),%eax
f0103e65:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e68:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f0103e6d:	eb 40                	jmp    f0103eaf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e6f:	83 f9 01             	cmp    $0x1,%ecx
f0103e72:	7e 10                	jle    f0103e84 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f0103e74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e77:	8b 10                	mov    (%eax),%edx
f0103e79:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e7c:	8d 40 08             	lea    0x8(%eax),%eax
f0103e7f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103e82:	eb 26                	jmp    f0103eaa <vprintfmt+0x406>
	else if (lflag)
f0103e84:	85 c9                	test   %ecx,%ecx
f0103e86:	74 12                	je     f0103e9a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f0103e88:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e8b:	8b 10                	mov    (%eax),%edx
f0103e8d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e92:	8d 40 04             	lea    0x4(%eax),%eax
f0103e95:	89 45 14             	mov    %eax,0x14(%ebp)
f0103e98:	eb 10                	jmp    f0103eaa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f0103e9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e9d:	8b 10                	mov    (%eax),%edx
f0103e9f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ea4:	8d 40 04             	lea    0x4(%eax),%eax
f0103ea7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103eaa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103eaf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103eb3:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103eb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103eba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103ec2:	89 14 24             	mov    %edx,(%esp)
f0103ec5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103ec9:	89 da                	mov    %ebx,%edx
f0103ecb:	89 f0                	mov    %esi,%eax
f0103ecd:	e8 9e fa ff ff       	call   f0103970 <printnum>
			break;
f0103ed2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ed5:	e9 ef fb ff ff       	jmp    f0103ac9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103eda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ede:	89 04 24             	mov    %eax,(%esp)
f0103ee1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ee3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103ee6:	e9 de fb ff ff       	jmp    f0103ac9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103ef6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ef8:	eb 03                	jmp    f0103efd <vprintfmt+0x459>
f0103efa:	83 ef 01             	sub    $0x1,%edi
f0103efd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103f01:	75 f7                	jne    f0103efa <vprintfmt+0x456>
f0103f03:	e9 c1 fb ff ff       	jmp    f0103ac9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103f08:	83 c4 3c             	add    $0x3c,%esp
f0103f0b:	5b                   	pop    %ebx
f0103f0c:	5e                   	pop    %esi
f0103f0d:	5f                   	pop    %edi
f0103f0e:	5d                   	pop    %ebp
f0103f0f:	c3                   	ret    

f0103f10 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103f10:	55                   	push   %ebp
f0103f11:	89 e5                	mov    %esp,%ebp
f0103f13:	83 ec 28             	sub    $0x28,%esp
f0103f16:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f19:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103f1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103f1f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103f23:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103f26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103f2d:	85 c0                	test   %eax,%eax
f0103f2f:	74 30                	je     f0103f61 <vsnprintf+0x51>
f0103f31:	85 d2                	test   %edx,%edx
f0103f33:	7e 2c                	jle    f0103f61 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103f35:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f3c:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f43:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103f46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f4a:	c7 04 24 5f 3a 10 f0 	movl   $0xf0103a5f,(%esp)
f0103f51:	e8 4e fb ff ff       	call   f0103aa4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103f56:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f59:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f5f:	eb 05                	jmp    f0103f66 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103f66:	c9                   	leave  
f0103f67:	c3                   	ret    

f0103f68 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103f68:	55                   	push   %ebp
f0103f69:	89 e5                	mov    %esp,%ebp
f0103f6b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103f6e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f75:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f78:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f86:	89 04 24             	mov    %eax,(%esp)
f0103f89:	e8 82 ff ff ff       	call   f0103f10 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103f8e:	c9                   	leave  
f0103f8f:	c3                   	ret    

f0103f90 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 1c             	sub    $0x1c,%esp
f0103f99:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103f9c:	85 c0                	test   %eax,%eax
f0103f9e:	74 10                	je     f0103fb0 <readline+0x20>
		cprintf("%s", prompt);
f0103fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fa4:	c7 04 24 d9 52 10 f0 	movl   $0xf01052d9,(%esp)
f0103fab:	e8 c7 f2 ff ff       	call   f0103277 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103fb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103fb7:	e8 76 c6 ff ff       	call   f0100632 <iscons>
f0103fbc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103fbe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103fc3:	e8 59 c6 ff ff       	call   f0100621 <getchar>
f0103fc8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103fca:	85 c0                	test   %eax,%eax
f0103fcc:	79 17                	jns    f0103fe5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103fce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fd2:	c7 04 24 40 5c 10 f0 	movl   $0xf0105c40,(%esp)
f0103fd9:	e8 99 f2 ff ff       	call   f0103277 <cprintf>
			return NULL;
f0103fde:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fe3:	eb 6d                	jmp    f0104052 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103fe5:	83 f8 7f             	cmp    $0x7f,%eax
f0103fe8:	74 05                	je     f0103fef <readline+0x5f>
f0103fea:	83 f8 08             	cmp    $0x8,%eax
f0103fed:	75 19                	jne    f0104008 <readline+0x78>
f0103fef:	85 f6                	test   %esi,%esi
f0103ff1:	7e 15                	jle    f0104008 <readline+0x78>
			if (echoing)
f0103ff3:	85 ff                	test   %edi,%edi
f0103ff5:	74 0c                	je     f0104003 <readline+0x73>
				cputchar('\b');
f0103ff7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103ffe:	e8 0e c6 ff ff       	call   f0100611 <cputchar>
			i--;
f0104003:	83 ee 01             	sub    $0x1,%esi
f0104006:	eb bb                	jmp    f0103fc3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104008:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010400e:	7f 1c                	jg     f010402c <readline+0x9c>
f0104010:	83 fb 1f             	cmp    $0x1f,%ebx
f0104013:	7e 17                	jle    f010402c <readline+0x9c>
			if (echoing)
f0104015:	85 ff                	test   %edi,%edi
f0104017:	74 08                	je     f0104021 <readline+0x91>
				cputchar(c);
f0104019:	89 1c 24             	mov    %ebx,(%esp)
f010401c:	e8 f0 c5 ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f0104021:	88 9e 80 c9 17 f0    	mov    %bl,-0xfe83680(%esi)
f0104027:	8d 76 01             	lea    0x1(%esi),%esi
f010402a:	eb 97                	jmp    f0103fc3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010402c:	83 fb 0d             	cmp    $0xd,%ebx
f010402f:	74 05                	je     f0104036 <readline+0xa6>
f0104031:	83 fb 0a             	cmp    $0xa,%ebx
f0104034:	75 8d                	jne    f0103fc3 <readline+0x33>
			if (echoing)
f0104036:	85 ff                	test   %edi,%edi
f0104038:	74 0c                	je     f0104046 <readline+0xb6>
				cputchar('\n');
f010403a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104041:	e8 cb c5 ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f0104046:	c6 86 80 c9 17 f0 00 	movb   $0x0,-0xfe83680(%esi)
			return buf;
f010404d:	b8 80 c9 17 f0       	mov    $0xf017c980,%eax
		}
	}
}
f0104052:	83 c4 1c             	add    $0x1c,%esp
f0104055:	5b                   	pop    %ebx
f0104056:	5e                   	pop    %esi
f0104057:	5f                   	pop    %edi
f0104058:	5d                   	pop    %ebp
f0104059:	c3                   	ret    
f010405a:	66 90                	xchg   %ax,%ax
f010405c:	66 90                	xchg   %ax,%ax
f010405e:	66 90                	xchg   %ax,%ax

f0104060 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104060:	55                   	push   %ebp
f0104061:	89 e5                	mov    %esp,%ebp
f0104063:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104066:	b8 00 00 00 00       	mov    $0x0,%eax
f010406b:	eb 03                	jmp    f0104070 <strlen+0x10>
		n++;
f010406d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104070:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104074:	75 f7                	jne    f010406d <strlen+0xd>
		n++;
	return n;
}
f0104076:	5d                   	pop    %ebp
f0104077:	c3                   	ret    

f0104078 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104078:	55                   	push   %ebp
f0104079:	89 e5                	mov    %esp,%ebp
f010407b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010407e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104081:	b8 00 00 00 00       	mov    $0x0,%eax
f0104086:	eb 03                	jmp    f010408b <strnlen+0x13>
		n++;
f0104088:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010408b:	39 d0                	cmp    %edx,%eax
f010408d:	74 06                	je     f0104095 <strnlen+0x1d>
f010408f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104093:	75 f3                	jne    f0104088 <strnlen+0x10>
		n++;
	return n;
}
f0104095:	5d                   	pop    %ebp
f0104096:	c3                   	ret    

f0104097 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104097:	55                   	push   %ebp
f0104098:	89 e5                	mov    %esp,%ebp
f010409a:	53                   	push   %ebx
f010409b:	8b 45 08             	mov    0x8(%ebp),%eax
f010409e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01040a1:	89 c2                	mov    %eax,%edx
f01040a3:	83 c2 01             	add    $0x1,%edx
f01040a6:	83 c1 01             	add    $0x1,%ecx
f01040a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01040ad:	88 5a ff             	mov    %bl,-0x1(%edx)
f01040b0:	84 db                	test   %bl,%bl
f01040b2:	75 ef                	jne    f01040a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01040b4:	5b                   	pop    %ebx
f01040b5:	5d                   	pop    %ebp
f01040b6:	c3                   	ret    

f01040b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01040b7:	55                   	push   %ebp
f01040b8:	89 e5                	mov    %esp,%ebp
f01040ba:	53                   	push   %ebx
f01040bb:	83 ec 08             	sub    $0x8,%esp
f01040be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01040c1:	89 1c 24             	mov    %ebx,(%esp)
f01040c4:	e8 97 ff ff ff       	call   f0104060 <strlen>
	strcpy(dst + len, src);
f01040c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01040d0:	01 d8                	add    %ebx,%eax
f01040d2:	89 04 24             	mov    %eax,(%esp)
f01040d5:	e8 bd ff ff ff       	call   f0104097 <strcpy>
	return dst;
}
f01040da:	89 d8                	mov    %ebx,%eax
f01040dc:	83 c4 08             	add    $0x8,%esp
f01040df:	5b                   	pop    %ebx
f01040e0:	5d                   	pop    %ebp
f01040e1:	c3                   	ret    

f01040e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01040e2:	55                   	push   %ebp
f01040e3:	89 e5                	mov    %esp,%ebp
f01040e5:	56                   	push   %esi
f01040e6:	53                   	push   %ebx
f01040e7:	8b 75 08             	mov    0x8(%ebp),%esi
f01040ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01040ed:	89 f3                	mov    %esi,%ebx
f01040ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040f2:	89 f2                	mov    %esi,%edx
f01040f4:	eb 0f                	jmp    f0104105 <strncpy+0x23>
		*dst++ = *src;
f01040f6:	83 c2 01             	add    $0x1,%edx
f01040f9:	0f b6 01             	movzbl (%ecx),%eax
f01040fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01040ff:	80 39 01             	cmpb   $0x1,(%ecx)
f0104102:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104105:	39 da                	cmp    %ebx,%edx
f0104107:	75 ed                	jne    f01040f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104109:	89 f0                	mov    %esi,%eax
f010410b:	5b                   	pop    %ebx
f010410c:	5e                   	pop    %esi
f010410d:	5d                   	pop    %ebp
f010410e:	c3                   	ret    

f010410f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010410f:	55                   	push   %ebp
f0104110:	89 e5                	mov    %esp,%ebp
f0104112:	56                   	push   %esi
f0104113:	53                   	push   %ebx
f0104114:	8b 75 08             	mov    0x8(%ebp),%esi
f0104117:	8b 55 0c             	mov    0xc(%ebp),%edx
f010411a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010411d:	89 f0                	mov    %esi,%eax
f010411f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104123:	85 c9                	test   %ecx,%ecx
f0104125:	75 0b                	jne    f0104132 <strlcpy+0x23>
f0104127:	eb 1d                	jmp    f0104146 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104129:	83 c0 01             	add    $0x1,%eax
f010412c:	83 c2 01             	add    $0x1,%edx
f010412f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104132:	39 d8                	cmp    %ebx,%eax
f0104134:	74 0b                	je     f0104141 <strlcpy+0x32>
f0104136:	0f b6 0a             	movzbl (%edx),%ecx
f0104139:	84 c9                	test   %cl,%cl
f010413b:	75 ec                	jne    f0104129 <strlcpy+0x1a>
f010413d:	89 c2                	mov    %eax,%edx
f010413f:	eb 02                	jmp    f0104143 <strlcpy+0x34>
f0104141:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104143:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104146:	29 f0                	sub    %esi,%eax
}
f0104148:	5b                   	pop    %ebx
f0104149:	5e                   	pop    %esi
f010414a:	5d                   	pop    %ebp
f010414b:	c3                   	ret    

f010414c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010414c:	55                   	push   %ebp
f010414d:	89 e5                	mov    %esp,%ebp
f010414f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104152:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104155:	eb 06                	jmp    f010415d <strcmp+0x11>
		p++, q++;
f0104157:	83 c1 01             	add    $0x1,%ecx
f010415a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010415d:	0f b6 01             	movzbl (%ecx),%eax
f0104160:	84 c0                	test   %al,%al
f0104162:	74 04                	je     f0104168 <strcmp+0x1c>
f0104164:	3a 02                	cmp    (%edx),%al
f0104166:	74 ef                	je     f0104157 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104168:	0f b6 c0             	movzbl %al,%eax
f010416b:	0f b6 12             	movzbl (%edx),%edx
f010416e:	29 d0                	sub    %edx,%eax
}
f0104170:	5d                   	pop    %ebp
f0104171:	c3                   	ret    

f0104172 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104172:	55                   	push   %ebp
f0104173:	89 e5                	mov    %esp,%ebp
f0104175:	53                   	push   %ebx
f0104176:	8b 45 08             	mov    0x8(%ebp),%eax
f0104179:	8b 55 0c             	mov    0xc(%ebp),%edx
f010417c:	89 c3                	mov    %eax,%ebx
f010417e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104181:	eb 06                	jmp    f0104189 <strncmp+0x17>
		n--, p++, q++;
f0104183:	83 c0 01             	add    $0x1,%eax
f0104186:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104189:	39 d8                	cmp    %ebx,%eax
f010418b:	74 15                	je     f01041a2 <strncmp+0x30>
f010418d:	0f b6 08             	movzbl (%eax),%ecx
f0104190:	84 c9                	test   %cl,%cl
f0104192:	74 04                	je     f0104198 <strncmp+0x26>
f0104194:	3a 0a                	cmp    (%edx),%cl
f0104196:	74 eb                	je     f0104183 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104198:	0f b6 00             	movzbl (%eax),%eax
f010419b:	0f b6 12             	movzbl (%edx),%edx
f010419e:	29 d0                	sub    %edx,%eax
f01041a0:	eb 05                	jmp    f01041a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01041a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01041a7:	5b                   	pop    %ebx
f01041a8:	5d                   	pop    %ebp
f01041a9:	c3                   	ret    

f01041aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01041aa:	55                   	push   %ebp
f01041ab:	89 e5                	mov    %esp,%ebp
f01041ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01041b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01041b4:	eb 07                	jmp    f01041bd <strchr+0x13>
		if (*s == c)
f01041b6:	38 ca                	cmp    %cl,%dl
f01041b8:	74 0f                	je     f01041c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01041ba:	83 c0 01             	add    $0x1,%eax
f01041bd:	0f b6 10             	movzbl (%eax),%edx
f01041c0:	84 d2                	test   %dl,%dl
f01041c2:	75 f2                	jne    f01041b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01041c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01041c9:	5d                   	pop    %ebp
f01041ca:	c3                   	ret    

f01041cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01041cb:	55                   	push   %ebp
f01041cc:	89 e5                	mov    %esp,%ebp
f01041ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01041d5:	eb 07                	jmp    f01041de <strfind+0x13>
		if (*s == c)
f01041d7:	38 ca                	cmp    %cl,%dl
f01041d9:	74 0a                	je     f01041e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01041db:	83 c0 01             	add    $0x1,%eax
f01041de:	0f b6 10             	movzbl (%eax),%edx
f01041e1:	84 d2                	test   %dl,%dl
f01041e3:	75 f2                	jne    f01041d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01041e5:	5d                   	pop    %ebp
f01041e6:	c3                   	ret    

f01041e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01041e7:	55                   	push   %ebp
f01041e8:	89 e5                	mov    %esp,%ebp
f01041ea:	57                   	push   %edi
f01041eb:	56                   	push   %esi
f01041ec:	53                   	push   %ebx
f01041ed:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01041f3:	85 c9                	test   %ecx,%ecx
f01041f5:	74 36                	je     f010422d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01041f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01041fd:	75 28                	jne    f0104227 <memset+0x40>
f01041ff:	f6 c1 03             	test   $0x3,%cl
f0104202:	75 23                	jne    f0104227 <memset+0x40>
		c &= 0xFF;
f0104204:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104208:	89 d3                	mov    %edx,%ebx
f010420a:	c1 e3 08             	shl    $0x8,%ebx
f010420d:	89 d6                	mov    %edx,%esi
f010420f:	c1 e6 18             	shl    $0x18,%esi
f0104212:	89 d0                	mov    %edx,%eax
f0104214:	c1 e0 10             	shl    $0x10,%eax
f0104217:	09 f0                	or     %esi,%eax
f0104219:	09 c2                	or     %eax,%edx
f010421b:	89 d0                	mov    %edx,%eax
f010421d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010421f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104222:	fc                   	cld    
f0104223:	f3 ab                	rep stos %eax,%es:(%edi)
f0104225:	eb 06                	jmp    f010422d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104227:	8b 45 0c             	mov    0xc(%ebp),%eax
f010422a:	fc                   	cld    
f010422b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010422d:	89 f8                	mov    %edi,%eax
f010422f:	5b                   	pop    %ebx
f0104230:	5e                   	pop    %esi
f0104231:	5f                   	pop    %edi
f0104232:	5d                   	pop    %ebp
f0104233:	c3                   	ret    

f0104234 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104234:	55                   	push   %ebp
f0104235:	89 e5                	mov    %esp,%ebp
f0104237:	57                   	push   %edi
f0104238:	56                   	push   %esi
f0104239:	8b 45 08             	mov    0x8(%ebp),%eax
f010423c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010423f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104242:	39 c6                	cmp    %eax,%esi
f0104244:	73 35                	jae    f010427b <memmove+0x47>
f0104246:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104249:	39 d0                	cmp    %edx,%eax
f010424b:	73 2e                	jae    f010427b <memmove+0x47>
		s += n;
		d += n;
f010424d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104250:	89 d6                	mov    %edx,%esi
f0104252:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104254:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010425a:	75 13                	jne    f010426f <memmove+0x3b>
f010425c:	f6 c1 03             	test   $0x3,%cl
f010425f:	75 0e                	jne    f010426f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104261:	83 ef 04             	sub    $0x4,%edi
f0104264:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104267:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010426a:	fd                   	std    
f010426b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010426d:	eb 09                	jmp    f0104278 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010426f:	83 ef 01             	sub    $0x1,%edi
f0104272:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104275:	fd                   	std    
f0104276:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104278:	fc                   	cld    
f0104279:	eb 1d                	jmp    f0104298 <memmove+0x64>
f010427b:	89 f2                	mov    %esi,%edx
f010427d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010427f:	f6 c2 03             	test   $0x3,%dl
f0104282:	75 0f                	jne    f0104293 <memmove+0x5f>
f0104284:	f6 c1 03             	test   $0x3,%cl
f0104287:	75 0a                	jne    f0104293 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104289:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010428c:	89 c7                	mov    %eax,%edi
f010428e:	fc                   	cld    
f010428f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104291:	eb 05                	jmp    f0104298 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104293:	89 c7                	mov    %eax,%edi
f0104295:	fc                   	cld    
f0104296:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104298:	5e                   	pop    %esi
f0104299:	5f                   	pop    %edi
f010429a:	5d                   	pop    %ebp
f010429b:	c3                   	ret    

f010429c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010429c:	55                   	push   %ebp
f010429d:	89 e5                	mov    %esp,%ebp
f010429f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01042a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01042a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01042b3:	89 04 24             	mov    %eax,(%esp)
f01042b6:	e8 79 ff ff ff       	call   f0104234 <memmove>
}
f01042bb:	c9                   	leave  
f01042bc:	c3                   	ret    

f01042bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01042bd:	55                   	push   %ebp
f01042be:	89 e5                	mov    %esp,%ebp
f01042c0:	56                   	push   %esi
f01042c1:	53                   	push   %ebx
f01042c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01042c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01042c8:	89 d6                	mov    %edx,%esi
f01042ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042cd:	eb 1a                	jmp    f01042e9 <memcmp+0x2c>
		if (*s1 != *s2)
f01042cf:	0f b6 02             	movzbl (%edx),%eax
f01042d2:	0f b6 19             	movzbl (%ecx),%ebx
f01042d5:	38 d8                	cmp    %bl,%al
f01042d7:	74 0a                	je     f01042e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01042d9:	0f b6 c0             	movzbl %al,%eax
f01042dc:	0f b6 db             	movzbl %bl,%ebx
f01042df:	29 d8                	sub    %ebx,%eax
f01042e1:	eb 0f                	jmp    f01042f2 <memcmp+0x35>
		s1++, s2++;
f01042e3:	83 c2 01             	add    $0x1,%edx
f01042e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042e9:	39 f2                	cmp    %esi,%edx
f01042eb:	75 e2                	jne    f01042cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01042ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042f2:	5b                   	pop    %ebx
f01042f3:	5e                   	pop    %esi
f01042f4:	5d                   	pop    %ebp
f01042f5:	c3                   	ret    

f01042f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01042f6:	55                   	push   %ebp
f01042f7:	89 e5                	mov    %esp,%ebp
f01042f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01042ff:	89 c2                	mov    %eax,%edx
f0104301:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104304:	eb 07                	jmp    f010430d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104306:	38 08                	cmp    %cl,(%eax)
f0104308:	74 07                	je     f0104311 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010430a:	83 c0 01             	add    $0x1,%eax
f010430d:	39 d0                	cmp    %edx,%eax
f010430f:	72 f5                	jb     f0104306 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104311:	5d                   	pop    %ebp
f0104312:	c3                   	ret    

f0104313 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104313:	55                   	push   %ebp
f0104314:	89 e5                	mov    %esp,%ebp
f0104316:	57                   	push   %edi
f0104317:	56                   	push   %esi
f0104318:	53                   	push   %ebx
f0104319:	8b 55 08             	mov    0x8(%ebp),%edx
f010431c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010431f:	eb 03                	jmp    f0104324 <strtol+0x11>
		s++;
f0104321:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104324:	0f b6 0a             	movzbl (%edx),%ecx
f0104327:	80 f9 09             	cmp    $0x9,%cl
f010432a:	74 f5                	je     f0104321 <strtol+0xe>
f010432c:	80 f9 20             	cmp    $0x20,%cl
f010432f:	74 f0                	je     f0104321 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104331:	80 f9 2b             	cmp    $0x2b,%cl
f0104334:	75 0a                	jne    f0104340 <strtol+0x2d>
		s++;
f0104336:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104339:	bf 00 00 00 00       	mov    $0x0,%edi
f010433e:	eb 11                	jmp    f0104351 <strtol+0x3e>
f0104340:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104345:	80 f9 2d             	cmp    $0x2d,%cl
f0104348:	75 07                	jne    f0104351 <strtol+0x3e>
		s++, neg = 1;
f010434a:	8d 52 01             	lea    0x1(%edx),%edx
f010434d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104351:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0104356:	75 15                	jne    f010436d <strtol+0x5a>
f0104358:	80 3a 30             	cmpb   $0x30,(%edx)
f010435b:	75 10                	jne    f010436d <strtol+0x5a>
f010435d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104361:	75 0a                	jne    f010436d <strtol+0x5a>
		s += 2, base = 16;
f0104363:	83 c2 02             	add    $0x2,%edx
f0104366:	b8 10 00 00 00       	mov    $0x10,%eax
f010436b:	eb 10                	jmp    f010437d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010436d:	85 c0                	test   %eax,%eax
f010436f:	75 0c                	jne    f010437d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104371:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104373:	80 3a 30             	cmpb   $0x30,(%edx)
f0104376:	75 05                	jne    f010437d <strtol+0x6a>
		s++, base = 8;
f0104378:	83 c2 01             	add    $0x1,%edx
f010437b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010437d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104382:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104385:	0f b6 0a             	movzbl (%edx),%ecx
f0104388:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010438b:	89 f0                	mov    %esi,%eax
f010438d:	3c 09                	cmp    $0x9,%al
f010438f:	77 08                	ja     f0104399 <strtol+0x86>
			dig = *s - '0';
f0104391:	0f be c9             	movsbl %cl,%ecx
f0104394:	83 e9 30             	sub    $0x30,%ecx
f0104397:	eb 20                	jmp    f01043b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0104399:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010439c:	89 f0                	mov    %esi,%eax
f010439e:	3c 19                	cmp    $0x19,%al
f01043a0:	77 08                	ja     f01043aa <strtol+0x97>
			dig = *s - 'a' + 10;
f01043a2:	0f be c9             	movsbl %cl,%ecx
f01043a5:	83 e9 57             	sub    $0x57,%ecx
f01043a8:	eb 0f                	jmp    f01043b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f01043aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01043ad:	89 f0                	mov    %esi,%eax
f01043af:	3c 19                	cmp    $0x19,%al
f01043b1:	77 16                	ja     f01043c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01043b3:	0f be c9             	movsbl %cl,%ecx
f01043b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01043b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01043bc:	7d 0f                	jge    f01043cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01043be:	83 c2 01             	add    $0x1,%edx
f01043c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01043c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01043c7:	eb bc                	jmp    f0104385 <strtol+0x72>
f01043c9:	89 d8                	mov    %ebx,%eax
f01043cb:	eb 02                	jmp    f01043cf <strtol+0xbc>
f01043cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01043cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01043d3:	74 05                	je     f01043da <strtol+0xc7>
		*endptr = (char *) s;
f01043d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01043da:	f7 d8                	neg    %eax
f01043dc:	85 ff                	test   %edi,%edi
f01043de:	0f 44 c3             	cmove  %ebx,%eax
}
f01043e1:	5b                   	pop    %ebx
f01043e2:	5e                   	pop    %esi
f01043e3:	5f                   	pop    %edi
f01043e4:	5d                   	pop    %ebp
f01043e5:	c3                   	ret    
f01043e6:	66 90                	xchg   %ax,%ax
f01043e8:	66 90                	xchg   %ax,%ax
f01043ea:	66 90                	xchg   %ax,%ax
f01043ec:	66 90                	xchg   %ax,%ax
f01043ee:	66 90                	xchg   %ax,%ax

f01043f0 <__udivdi3>:
f01043f0:	55                   	push   %ebp
f01043f1:	57                   	push   %edi
f01043f2:	56                   	push   %esi
f01043f3:	83 ec 0c             	sub    $0xc,%esp
f01043f6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01043fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01043fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104402:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104406:	85 c0                	test   %eax,%eax
f0104408:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010440c:	89 ea                	mov    %ebp,%edx
f010440e:	89 0c 24             	mov    %ecx,(%esp)
f0104411:	75 2d                	jne    f0104440 <__udivdi3+0x50>
f0104413:	39 e9                	cmp    %ebp,%ecx
f0104415:	77 61                	ja     f0104478 <__udivdi3+0x88>
f0104417:	85 c9                	test   %ecx,%ecx
f0104419:	89 ce                	mov    %ecx,%esi
f010441b:	75 0b                	jne    f0104428 <__udivdi3+0x38>
f010441d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104422:	31 d2                	xor    %edx,%edx
f0104424:	f7 f1                	div    %ecx
f0104426:	89 c6                	mov    %eax,%esi
f0104428:	31 d2                	xor    %edx,%edx
f010442a:	89 e8                	mov    %ebp,%eax
f010442c:	f7 f6                	div    %esi
f010442e:	89 c5                	mov    %eax,%ebp
f0104430:	89 f8                	mov    %edi,%eax
f0104432:	f7 f6                	div    %esi
f0104434:	89 ea                	mov    %ebp,%edx
f0104436:	83 c4 0c             	add    $0xc,%esp
f0104439:	5e                   	pop    %esi
f010443a:	5f                   	pop    %edi
f010443b:	5d                   	pop    %ebp
f010443c:	c3                   	ret    
f010443d:	8d 76 00             	lea    0x0(%esi),%esi
f0104440:	39 e8                	cmp    %ebp,%eax
f0104442:	77 24                	ja     f0104468 <__udivdi3+0x78>
f0104444:	0f bd e8             	bsr    %eax,%ebp
f0104447:	83 f5 1f             	xor    $0x1f,%ebp
f010444a:	75 3c                	jne    f0104488 <__udivdi3+0x98>
f010444c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104450:	39 34 24             	cmp    %esi,(%esp)
f0104453:	0f 86 9f 00 00 00    	jbe    f01044f8 <__udivdi3+0x108>
f0104459:	39 d0                	cmp    %edx,%eax
f010445b:	0f 82 97 00 00 00    	jb     f01044f8 <__udivdi3+0x108>
f0104461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104468:	31 d2                	xor    %edx,%edx
f010446a:	31 c0                	xor    %eax,%eax
f010446c:	83 c4 0c             	add    $0xc,%esp
f010446f:	5e                   	pop    %esi
f0104470:	5f                   	pop    %edi
f0104471:	5d                   	pop    %ebp
f0104472:	c3                   	ret    
f0104473:	90                   	nop
f0104474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104478:	89 f8                	mov    %edi,%eax
f010447a:	f7 f1                	div    %ecx
f010447c:	31 d2                	xor    %edx,%edx
f010447e:	83 c4 0c             	add    $0xc,%esp
f0104481:	5e                   	pop    %esi
f0104482:	5f                   	pop    %edi
f0104483:	5d                   	pop    %ebp
f0104484:	c3                   	ret    
f0104485:	8d 76 00             	lea    0x0(%esi),%esi
f0104488:	89 e9                	mov    %ebp,%ecx
f010448a:	8b 3c 24             	mov    (%esp),%edi
f010448d:	d3 e0                	shl    %cl,%eax
f010448f:	89 c6                	mov    %eax,%esi
f0104491:	b8 20 00 00 00       	mov    $0x20,%eax
f0104496:	29 e8                	sub    %ebp,%eax
f0104498:	89 c1                	mov    %eax,%ecx
f010449a:	d3 ef                	shr    %cl,%edi
f010449c:	89 e9                	mov    %ebp,%ecx
f010449e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01044a2:	8b 3c 24             	mov    (%esp),%edi
f01044a5:	09 74 24 08          	or     %esi,0x8(%esp)
f01044a9:	89 d6                	mov    %edx,%esi
f01044ab:	d3 e7                	shl    %cl,%edi
f01044ad:	89 c1                	mov    %eax,%ecx
f01044af:	89 3c 24             	mov    %edi,(%esp)
f01044b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01044b6:	d3 ee                	shr    %cl,%esi
f01044b8:	89 e9                	mov    %ebp,%ecx
f01044ba:	d3 e2                	shl    %cl,%edx
f01044bc:	89 c1                	mov    %eax,%ecx
f01044be:	d3 ef                	shr    %cl,%edi
f01044c0:	09 d7                	or     %edx,%edi
f01044c2:	89 f2                	mov    %esi,%edx
f01044c4:	89 f8                	mov    %edi,%eax
f01044c6:	f7 74 24 08          	divl   0x8(%esp)
f01044ca:	89 d6                	mov    %edx,%esi
f01044cc:	89 c7                	mov    %eax,%edi
f01044ce:	f7 24 24             	mull   (%esp)
f01044d1:	39 d6                	cmp    %edx,%esi
f01044d3:	89 14 24             	mov    %edx,(%esp)
f01044d6:	72 30                	jb     f0104508 <__udivdi3+0x118>
f01044d8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01044dc:	89 e9                	mov    %ebp,%ecx
f01044de:	d3 e2                	shl    %cl,%edx
f01044e0:	39 c2                	cmp    %eax,%edx
f01044e2:	73 05                	jae    f01044e9 <__udivdi3+0xf9>
f01044e4:	3b 34 24             	cmp    (%esp),%esi
f01044e7:	74 1f                	je     f0104508 <__udivdi3+0x118>
f01044e9:	89 f8                	mov    %edi,%eax
f01044eb:	31 d2                	xor    %edx,%edx
f01044ed:	e9 7a ff ff ff       	jmp    f010446c <__udivdi3+0x7c>
f01044f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01044f8:	31 d2                	xor    %edx,%edx
f01044fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01044ff:	e9 68 ff ff ff       	jmp    f010446c <__udivdi3+0x7c>
f0104504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104508:	8d 47 ff             	lea    -0x1(%edi),%eax
f010450b:	31 d2                	xor    %edx,%edx
f010450d:	83 c4 0c             	add    $0xc,%esp
f0104510:	5e                   	pop    %esi
f0104511:	5f                   	pop    %edi
f0104512:	5d                   	pop    %ebp
f0104513:	c3                   	ret    
f0104514:	66 90                	xchg   %ax,%ax
f0104516:	66 90                	xchg   %ax,%ax
f0104518:	66 90                	xchg   %ax,%ax
f010451a:	66 90                	xchg   %ax,%ax
f010451c:	66 90                	xchg   %ax,%ax
f010451e:	66 90                	xchg   %ax,%ax

f0104520 <__umoddi3>:
f0104520:	55                   	push   %ebp
f0104521:	57                   	push   %edi
f0104522:	56                   	push   %esi
f0104523:	83 ec 14             	sub    $0x14,%esp
f0104526:	8b 44 24 28          	mov    0x28(%esp),%eax
f010452a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010452e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104532:	89 c7                	mov    %eax,%edi
f0104534:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104538:	8b 44 24 30          	mov    0x30(%esp),%eax
f010453c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104540:	89 34 24             	mov    %esi,(%esp)
f0104543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104547:	85 c0                	test   %eax,%eax
f0104549:	89 c2                	mov    %eax,%edx
f010454b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010454f:	75 17                	jne    f0104568 <__umoddi3+0x48>
f0104551:	39 fe                	cmp    %edi,%esi
f0104553:	76 4b                	jbe    f01045a0 <__umoddi3+0x80>
f0104555:	89 c8                	mov    %ecx,%eax
f0104557:	89 fa                	mov    %edi,%edx
f0104559:	f7 f6                	div    %esi
f010455b:	89 d0                	mov    %edx,%eax
f010455d:	31 d2                	xor    %edx,%edx
f010455f:	83 c4 14             	add    $0x14,%esp
f0104562:	5e                   	pop    %esi
f0104563:	5f                   	pop    %edi
f0104564:	5d                   	pop    %ebp
f0104565:	c3                   	ret    
f0104566:	66 90                	xchg   %ax,%ax
f0104568:	39 f8                	cmp    %edi,%eax
f010456a:	77 54                	ja     f01045c0 <__umoddi3+0xa0>
f010456c:	0f bd e8             	bsr    %eax,%ebp
f010456f:	83 f5 1f             	xor    $0x1f,%ebp
f0104572:	75 5c                	jne    f01045d0 <__umoddi3+0xb0>
f0104574:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104578:	39 3c 24             	cmp    %edi,(%esp)
f010457b:	0f 87 e7 00 00 00    	ja     f0104668 <__umoddi3+0x148>
f0104581:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104585:	29 f1                	sub    %esi,%ecx
f0104587:	19 c7                	sbb    %eax,%edi
f0104589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010458d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104591:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104595:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104599:	83 c4 14             	add    $0x14,%esp
f010459c:	5e                   	pop    %esi
f010459d:	5f                   	pop    %edi
f010459e:	5d                   	pop    %ebp
f010459f:	c3                   	ret    
f01045a0:	85 f6                	test   %esi,%esi
f01045a2:	89 f5                	mov    %esi,%ebp
f01045a4:	75 0b                	jne    f01045b1 <__umoddi3+0x91>
f01045a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01045ab:	31 d2                	xor    %edx,%edx
f01045ad:	f7 f6                	div    %esi
f01045af:	89 c5                	mov    %eax,%ebp
f01045b1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01045b5:	31 d2                	xor    %edx,%edx
f01045b7:	f7 f5                	div    %ebp
f01045b9:	89 c8                	mov    %ecx,%eax
f01045bb:	f7 f5                	div    %ebp
f01045bd:	eb 9c                	jmp    f010455b <__umoddi3+0x3b>
f01045bf:	90                   	nop
f01045c0:	89 c8                	mov    %ecx,%eax
f01045c2:	89 fa                	mov    %edi,%edx
f01045c4:	83 c4 14             	add    $0x14,%esp
f01045c7:	5e                   	pop    %esi
f01045c8:	5f                   	pop    %edi
f01045c9:	5d                   	pop    %ebp
f01045ca:	c3                   	ret    
f01045cb:	90                   	nop
f01045cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01045d0:	8b 04 24             	mov    (%esp),%eax
f01045d3:	be 20 00 00 00       	mov    $0x20,%esi
f01045d8:	89 e9                	mov    %ebp,%ecx
f01045da:	29 ee                	sub    %ebp,%esi
f01045dc:	d3 e2                	shl    %cl,%edx
f01045de:	89 f1                	mov    %esi,%ecx
f01045e0:	d3 e8                	shr    %cl,%eax
f01045e2:	89 e9                	mov    %ebp,%ecx
f01045e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e8:	8b 04 24             	mov    (%esp),%eax
f01045eb:	09 54 24 04          	or     %edx,0x4(%esp)
f01045ef:	89 fa                	mov    %edi,%edx
f01045f1:	d3 e0                	shl    %cl,%eax
f01045f3:	89 f1                	mov    %esi,%ecx
f01045f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045f9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01045fd:	d3 ea                	shr    %cl,%edx
f01045ff:	89 e9                	mov    %ebp,%ecx
f0104601:	d3 e7                	shl    %cl,%edi
f0104603:	89 f1                	mov    %esi,%ecx
f0104605:	d3 e8                	shr    %cl,%eax
f0104607:	89 e9                	mov    %ebp,%ecx
f0104609:	09 f8                	or     %edi,%eax
f010460b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010460f:	f7 74 24 04          	divl   0x4(%esp)
f0104613:	d3 e7                	shl    %cl,%edi
f0104615:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104619:	89 d7                	mov    %edx,%edi
f010461b:	f7 64 24 08          	mull   0x8(%esp)
f010461f:	39 d7                	cmp    %edx,%edi
f0104621:	89 c1                	mov    %eax,%ecx
f0104623:	89 14 24             	mov    %edx,(%esp)
f0104626:	72 2c                	jb     f0104654 <__umoddi3+0x134>
f0104628:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010462c:	72 22                	jb     f0104650 <__umoddi3+0x130>
f010462e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104632:	29 c8                	sub    %ecx,%eax
f0104634:	19 d7                	sbb    %edx,%edi
f0104636:	89 e9                	mov    %ebp,%ecx
f0104638:	89 fa                	mov    %edi,%edx
f010463a:	d3 e8                	shr    %cl,%eax
f010463c:	89 f1                	mov    %esi,%ecx
f010463e:	d3 e2                	shl    %cl,%edx
f0104640:	89 e9                	mov    %ebp,%ecx
f0104642:	d3 ef                	shr    %cl,%edi
f0104644:	09 d0                	or     %edx,%eax
f0104646:	89 fa                	mov    %edi,%edx
f0104648:	83 c4 14             	add    $0x14,%esp
f010464b:	5e                   	pop    %esi
f010464c:	5f                   	pop    %edi
f010464d:	5d                   	pop    %ebp
f010464e:	c3                   	ret    
f010464f:	90                   	nop
f0104650:	39 d7                	cmp    %edx,%edi
f0104652:	75 da                	jne    f010462e <__umoddi3+0x10e>
f0104654:	8b 14 24             	mov    (%esp),%edx
f0104657:	89 c1                	mov    %eax,%ecx
f0104659:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010465d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0104661:	eb cb                	jmp    f010462e <__umoddi3+0x10e>
f0104663:	90                   	nop
f0104664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104668:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010466c:	0f 82 0f ff ff ff    	jb     f0104581 <__umoddi3+0x61>
f0104672:	e9 1a ff ff ff       	jmp    f0104591 <__umoddi3+0x71>
