
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
f0100063:	e8 af 4b 00 00       	call   f0104c17 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b2 04 00 00       	call   f010051f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 c0 50 10 f0 	movl   $0xf01050c0,(%esp)
f010007c:	e8 83 36 00 00       	call   f0103704 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 98 10 00 00       	call   f010111e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 fc 2f 00 00       	call   f0103087 <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 e8 36 00 00       	call   f010377d <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010009c:	00 
f010009d:	c7 04 24 56 b3 11 f0 	movl   $0xf011b356,(%esp)
f01000a4:	e8 b4 31 00 00       	call   f010325d <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a9:	a1 cc d0 17 f0       	mov    0xf017d0cc,%eax
f01000ae:	89 04 24             	mov    %eax,(%esp)
f01000b1:	e8 72 35 00 00       	call   f0103628 <env_run>

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
f01000e3:	c7 04 24 db 50 10 f0 	movl   $0xf01050db,(%esp)
f01000ea:	e8 15 36 00 00       	call   f0103704 <cprintf>
	vcprintf(fmt, ap);
f01000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f3:	89 34 24             	mov    %esi,(%esp)
f01000f6:	e8 d6 35 00 00       	call   f01036d1 <vcprintf>
	cprintf("\n");
f01000fb:	c7 04 24 e1 5f 10 f0 	movl   $0xf0105fe1,(%esp)
f0100102:	e8 fd 35 00 00       	call   f0103704 <cprintf>
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
f010012d:	c7 04 24 f3 50 10 f0 	movl   $0xf01050f3,(%esp)
f0100134:	e8 cb 35 00 00       	call   f0103704 <cprintf>
	vcprintf(fmt, ap);
f0100139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100140:	89 04 24             	mov    %eax,(%esp)
f0100143:	e8 89 35 00 00       	call   f01036d1 <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 e1 5f 10 f0 	movl   $0xf0105fe1,(%esp)
f010014f:	e8 b0 35 00 00       	call   f0103704 <cprintf>
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
f0100205:	0f b6 82 60 52 10 f0 	movzbl -0xfefada0(%edx),%eax
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
f0100242:	0f b6 82 60 52 10 f0 	movzbl -0xfefada0(%edx),%eax
f0100249:	0b 05 80 ce 17 f0    	or     0xf017ce80,%eax
	shift ^= togglecode[data];
f010024f:	0f b6 8a 60 51 10 f0 	movzbl -0xfefaea0(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 80 ce 17 f0       	mov    %eax,0xf017ce80

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 40 51 10 f0 	mov    -0xfefaec0(,%ecx,4),%ecx
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
f01002a2:	c7 04 24 0d 51 10 f0 	movl   $0xf010510d,(%esp)
f01002a9:	e8 56 34 00 00       	call   f0103704 <cprintf>
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
f0100449:	e8 16 48 00 00       	call   f0104c64 <memmove>
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
f01005fd:	c7 04 24 19 51 10 f0 	movl   $0xf0105119,(%esp)
f0100604:	e8 fb 30 00 00       	call   f0103704 <cprintf>
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
f0100646:	c7 44 24 08 60 53 10 	movl   $0xf0105360,0x8(%esp)
f010064d:	f0 
f010064e:	c7 44 24 04 7e 53 10 	movl   $0xf010537e,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 83 53 10 f0 	movl   $0xf0105383,(%esp)
f010065d:	e8 a2 30 00 00       	call   f0103704 <cprintf>
f0100662:	c7 44 24 08 ec 53 10 	movl   $0xf01053ec,0x8(%esp)
f0100669:	f0 
f010066a:	c7 44 24 04 8c 53 10 	movl   $0xf010538c,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 83 53 10 f0 	movl   $0xf0105383,(%esp)
f0100679:	e8 86 30 00 00       	call   f0103704 <cprintf>
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
f010068b:	c7 04 24 95 53 10 f0 	movl   $0xf0105395,(%esp)
f0100692:	e8 6d 30 00 00       	call   f0103704 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100697:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069e:	00 
f010069f:	c7 04 24 14 54 10 f0 	movl   $0xf0105414,(%esp)
f01006a6:	e8 59 30 00 00       	call   f0103704 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ab:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b2:	00 
f01006b3:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006ba:	f0 
f01006bb:	c7 04 24 3c 54 10 f0 	movl   $0xf010543c,(%esp)
f01006c2:	e8 3d 30 00 00       	call   f0103704 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c7:	c7 44 24 08 a7 50 10 	movl   $0x1050a7,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 a7 50 10 	movl   $0xf01050a7,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 60 54 10 f0 	movl   $0xf0105460,(%esp)
f01006de:	e8 21 30 00 00       	call   f0103704 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e3:	c7 44 24 08 65 ce 17 	movl   $0x17ce65,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 65 ce 17 	movl   $0xf017ce65,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 84 54 10 f0 	movl   $0xf0105484,(%esp)
f01006fa:	e8 05 30 00 00       	call   f0103704 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ff:	c7 44 24 08 90 dd 17 	movl   $0x17dd90,0x8(%esp)
f0100706:	00 
f0100707:	c7 44 24 04 90 dd 17 	movl   $0xf017dd90,0x4(%esp)
f010070e:	f0 
f010070f:	c7 04 24 a8 54 10 f0 	movl   $0xf01054a8,(%esp)
f0100716:	e8 e9 2f 00 00       	call   f0103704 <cprintf>
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
f010073c:	c7 04 24 cc 54 10 f0 	movl   $0xf01054cc,(%esp)
f0100743:	e8 bc 2f 00 00       	call   f0103704 <cprintf>
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
f0100762:	c7 04 24 f8 54 10 f0 	movl   $0xf01054f8,(%esp)
f0100769:	e8 96 2f 00 00       	call   f0103704 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010076e:	c7 04 24 1c 55 10 f0 	movl   $0xf010551c,(%esp)
f0100775:	e8 8a 2f 00 00       	call   f0103704 <cprintf>

	if (tf != NULL)
f010077a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010077e:	74 0b                	je     f010078b <monitor+0x32>
		print_trapframe(tf);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	89 04 24             	mov    %eax,(%esp)
f0100786:	e8 24 34 00 00       	call   f0103baf <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010078b:	c7 04 24 ae 53 10 f0 	movl   $0xf01053ae,(%esp)
f0100792:	e8 29 42 00 00       	call   f01049c0 <readline>
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
f01007c3:	c7 04 24 b2 53 10 f0 	movl   $0xf01053b2,(%esp)
f01007ca:	e8 0b 44 00 00       	call   f0104bda <strchr>
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
f01007e5:	c7 04 24 b7 53 10 f0 	movl   $0xf01053b7,(%esp)
f01007ec:	e8 13 2f 00 00       	call   f0103704 <cprintf>
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
f010080d:	c7 04 24 b2 53 10 f0 	movl   $0xf01053b2,(%esp)
f0100814:	e8 c1 43 00 00       	call   f0104bda <strchr>
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
f010082f:	c7 44 24 04 7e 53 10 	movl   $0xf010537e,0x4(%esp)
f0100836:	f0 
f0100837:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010083a:	89 04 24             	mov    %eax,(%esp)
f010083d:	e8 3a 43 00 00       	call   f0104b7c <strcmp>
f0100842:	85 c0                	test   %eax,%eax
f0100844:	74 1b                	je     f0100861 <monitor+0x108>
f0100846:	c7 44 24 04 8c 53 10 	movl   $0xf010538c,0x4(%esp)
f010084d:	f0 
f010084e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 23 43 00 00       	call   f0104b7c <strcmp>
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
f010087c:	ff 14 85 4c 55 10 f0 	call   *-0xfefaab4(,%eax,4)
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
f0100893:	c7 04 24 d4 53 10 f0 	movl   $0xf01053d4,(%esp)
f010089a:	e8 65 2e 00 00       	call   f0103704 <cprintf>
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
f0100916:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f010091d:	f0 
f010091e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100925:	00 
f0100926:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
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
f0100960:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0100967:	f0 
f0100968:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f010096f:	00 
f0100970:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01009bd:	c7 44 24 08 80 55 10 	movl   $0xf0105580,0x8(%esp)
f01009c4:	f0 
f01009c5:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
f01009cc:	00 
f01009cd:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0100a1d:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
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
f0100a27:	8b 1d c0 d0 17 f0    	mov    0xf017d0c0,%ebx
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
f0100a57:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0100a5e:	f0 
f0100a5f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100a66:	00 
f0100a67:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f0100a6e:	e8 43 f6 ff ff       	call   f01000b6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a73:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100a7a:	00 
f0100a7b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100a82:	00 
	return (void *)(pa + KERNBASE);
f0100a83:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a88:	89 04 24             	mov    %eax,(%esp)
f0100a8b:	e8 87 41 00 00       	call   f0104c17 <memset>
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
f0100aa3:	8b 15 c0 d0 17 f0    	mov    0xf017d0c0,%edx
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
f0100ad1:	c7 44 24 0c 33 5d 10 	movl   $0xf0105d33,0xc(%esp)
f0100ad8:	f0 
f0100ad9:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100ae0:	f0 
f0100ae1:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
f0100ae8:	00 
f0100ae9:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100af0:	e8 c1 f5 ff ff       	call   f01000b6 <_panic>
		assert(pp < pages + npages);
f0100af5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100af8:	72 24                	jb     f0100b1e <check_page_free_list+0x177>
f0100afa:	c7 44 24 0c 54 5d 10 	movl   $0xf0105d54,0xc(%esp)
f0100b01:	f0 
f0100b02:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100b09:	f0 
f0100b0a:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0100b11:	00 
f0100b12:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100b19:	e8 98 f5 ff ff       	call   f01000b6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1e:	89 d0                	mov    %edx,%eax
f0100b20:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b23:	a8 07                	test   $0x7,%al
f0100b25:	74 24                	je     f0100b4b <check_page_free_list+0x1a4>
f0100b27:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0100b2e:	f0 
f0100b2f:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100b36:	f0 
f0100b37:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f0100b3e:	00 
f0100b3f:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0100b55:	c7 44 24 0c 68 5d 10 	movl   $0xf0105d68,0xc(%esp)
f0100b5c:	f0 
f0100b5d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100b64:	f0 
f0100b65:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100b6c:	00 
f0100b6d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100b74:	e8 3d f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b79:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b7e:	75 24                	jne    f0100ba4 <check_page_free_list+0x1fd>
f0100b80:	c7 44 24 0c 79 5d 10 	movl   $0xf0105d79,0xc(%esp)
f0100b87:	f0 
f0100b88:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100b8f:	f0 
f0100b90:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100b97:	00 
f0100b98:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100b9f:	e8 12 f5 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ba4:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ba9:	75 24                	jne    f0100bcf <check_page_free_list+0x228>
f0100bab:	c7 44 24 0c d8 55 10 	movl   $0xf01055d8,0xc(%esp)
f0100bb2:	f0 
f0100bb3:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100bba:	f0 
f0100bbb:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100bc2:	00 
f0100bc3:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100bca:	e8 e7 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bcf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bd4:	75 24                	jne    f0100bfa <check_page_free_list+0x253>
f0100bd6:	c7 44 24 0c 92 5d 10 	movl   $0xf0105d92,0xc(%esp)
f0100bdd:	f0 
f0100bde:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100be5:	f0 
f0100be6:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f0100bed:	00 
f0100bee:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0100c0f:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0100c16:	f0 
f0100c17:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100c1e:	00 
f0100c1f:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f0100c26:	e8 8b f4 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100c2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c30:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c33:	76 2a                	jbe    f0100c5f <check_page_free_list+0x2b8>
f0100c35:	c7 44 24 0c fc 55 10 	movl   $0xf01055fc,0xc(%esp)
f0100c3c:	f0 
f0100c3d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100c44:	f0 
f0100c45:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0100c4c:	00 
f0100c4d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0100c73:	c7 44 24 0c ac 5d 10 	movl   $0xf0105dac,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100c92:	e8 1f f4 ff ff       	call   f01000b6 <_panic>
	assert(nfree_extmem > 0);
f0100c97:	85 ff                	test   %edi,%edi
f0100c99:	7f 4d                	jg     f0100ce8 <check_page_free_list+0x341>
f0100c9b:	c7 44 24 0c be 5d 10 	movl   $0xf0105dbe,0xc(%esp)
f0100ca2:	f0 
f0100ca3:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100cba:	e8 f7 f3 ff ff       	call   f01000b6 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cbf:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
f0100cc4:	85 c0                	test   %eax,%eax
f0100cc6:	0f 85 0d fd ff ff    	jne    f01009d9 <check_page_free_list+0x32>
f0100ccc:	e9 ec fc ff ff       	jmp    f01009bd <check_page_free_list+0x16>
f0100cd1:	83 3d c0 d0 17 f0 00 	cmpl   $0x0,0xf017d0c0
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
f0100d1e:	3b 1d c4 d0 17 f0    	cmp    0xf017d0c4,%ebx
f0100d24:	73 25                	jae    f0100d4b <page_init+0x5b>
		{
			pages[i].pp_ref = 0;
f0100d26:	89 f0                	mov    %esi,%eax
f0100d28:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d2e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list; 
f0100d34:	8b 15 c0 d0 17 f0    	mov    0xf017d0c0,%edx
f0100d3a:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100d3c:	89 f0                	mov    %esi,%eax
f0100d3e:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100d44:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
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
f0100dae:	8b 15 c0 d0 17 f0    	mov    0xf017d0c0,%edx
f0100db4:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100db6:	89 f0                	mov    %esi,%eax
f0100db8:	03 05 8c dd 17 f0    	add    0xf017dd8c,%eax
f0100dbe:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
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
f0100de0:	8b 1d c0 d0 17 f0    	mov    0xf017d0c0,%ebx
f0100de6:	85 db                	test   %ebx,%ebx
f0100de8:	74 6f                	je     f0100e59 <page_alloc+0x80>
		return NULL;

	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100dea:	8b 03                	mov    (%ebx),%eax
f0100dec:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
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
f0100e1c:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0100e23:	f0 
f0100e24:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e2b:	00 
f0100e2c:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f0100e33:	e8 7e f2 ff ff       	call   f01000b6 <_panic>
		memset(page2kva(page), 0, PGSIZE);
f0100e38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e3f:	00 
f0100e40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e47:	00 
	return (void *)(pa + KERNBASE);
f0100e48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e4d:	89 04 24             	mov    %eax,(%esp)
f0100e50:	e8 c2 3d 00 00       	call   f0104c17 <memset>
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
f0100e79:	c7 44 24 08 cf 5d 10 	movl   $0xf0105dcf,0x8(%esp)
f0100e80:	f0 
f0100e81:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
f0100e88:	00 
f0100e89:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0100e90:	e8 21 f2 ff ff       	call   f01000b6 <_panic>
	pp->pp_link = page_free_list;
f0100e95:	8b 15 c0 d0 17 f0    	mov    0xf017d0c0,%edx
f0100e9b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e9d:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0
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
f0100f31:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0100f38:	f0 
f0100f39:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f0100f40:	00 
f0100f41:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f010100b:	c7 44 24 08 44 56 10 	movl   $0xf0105644,0x8(%esp)
f0101012:	f0 
f0101013:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010101a:	00 
f010101b:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
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
f010112e:	e8 61 25 00 00       	call   f0103694 <mc146818_read>
f0101133:	89 c3                	mov    %eax,%ebx
f0101135:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010113c:	e8 53 25 00 00       	call   f0103694 <mc146818_read>
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
f0101159:	a3 c4 d0 17 f0       	mov    %eax,0xf017d0c4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010115e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101165:	e8 2a 25 00 00       	call   f0103694 <mc146818_read>
f010116a:	89 c3                	mov    %eax,%ebx
f010116c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101173:	e8 1c 25 00 00       	call   f0103694 <mc146818_read>
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
f01011a2:	8b 15 c4 d0 17 f0    	mov    0xf017d0c4,%edx
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
f01011b8:	a1 c4 d0 17 f0       	mov    0xf017d0c4,%eax
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
f01011d6:	c7 04 24 64 56 10 f0 	movl   $0xf0105664,(%esp)
f01011dd:	e8 22 25 00 00       	call   f0103704 <cprintf>
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
f0101204:	e8 0e 3a 00 00       	call   f0104c17 <memset>
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
f0101219:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0101220:	f0 
f0101221:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0101228:	00 
f0101229:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101256:	8b 0d 84 dd 17 f0    	mov    0xf017dd84,%ecx
f010125c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101263:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101267:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010126e:	00 
f010126f:	89 04 24             	mov    %eax,(%esp)
f0101272:	e8 a0 39 00 00       	call   f0104c17 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs =(struct Env*) boot_alloc(NENV* sizeof(struct Env));
f0101277:	b8 00 80 01 00       	mov    $0x18000,%eax
f010127c:	e8 2f f6 ff ff       	call   f01008b0 <boot_alloc>
f0101281:	a3 cc d0 17 f0       	mov    %eax,0xf017d0cc
	memset(envs, 0, NENV*sizeof(struct Env) );
f0101286:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f010128d:	00 
f010128e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101295:	00 
f0101296:	89 04 24             	mov    %eax,(%esp)
f0101299:	e8 79 39 00 00       	call   f0104c17 <memset>
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
f01012b6:	c7 44 24 08 e6 5d 10 	movl   $0xf0105de6,0x8(%esp)
f01012bd:	f0 
f01012be:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f01012c5:	00 
f01012c6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01012cd:	e8 e4 ed ff ff       	call   f01000b6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012d2:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
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
f01012f9:	c7 44 24 0c 01 5e 10 	movl   $0xf0105e01,0xc(%esp)
f0101300:	f0 
f0101301:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101308:	f0 
f0101309:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0101310:	00 
f0101311:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101318:	e8 99 ed ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010131d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101324:	e8 b0 fa ff ff       	call   f0100dd9 <page_alloc>
f0101329:	89 c6                	mov    %eax,%esi
f010132b:	85 c0                	test   %eax,%eax
f010132d:	75 24                	jne    f0101353 <mem_init+0x235>
f010132f:	c7 44 24 0c 17 5e 10 	movl   $0xf0105e17,0xc(%esp)
f0101336:	f0 
f0101337:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010133e:	f0 
f010133f:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101346:	00 
f0101347:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010134e:	e8 63 ed ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010135a:	e8 7a fa ff ff       	call   f0100dd9 <page_alloc>
f010135f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101362:	85 c0                	test   %eax,%eax
f0101364:	75 24                	jne    f010138a <mem_init+0x26c>
f0101366:	c7 44 24 0c 2d 5e 10 	movl   $0xf0105e2d,0xc(%esp)
f010136d:	f0 
f010136e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101375:	f0 
f0101376:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f010137d:	00 
f010137e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101385:	e8 2c ed ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010138a:	39 f7                	cmp    %esi,%edi
f010138c:	75 24                	jne    f01013b2 <mem_init+0x294>
f010138e:	c7 44 24 0c 43 5e 10 	movl   $0xf0105e43,0xc(%esp)
f0101395:	f0 
f0101396:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010139d:	f0 
f010139e:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01013a5:	00 
f01013a6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01013ad:	e8 04 ed ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013b5:	39 c6                	cmp    %eax,%esi
f01013b7:	74 04                	je     f01013bd <mem_init+0x29f>
f01013b9:	39 c7                	cmp    %eax,%edi
f01013bb:	75 24                	jne    f01013e1 <mem_init+0x2c3>
f01013bd:	c7 44 24 0c c4 56 10 	movl   $0xf01056c4,0xc(%esp)
f01013c4:	f0 
f01013c5:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01013cc:	f0 
f01013cd:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f01013d4:	00 
f01013d5:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01013fd:	c7 44 24 0c 55 5e 10 	movl   $0xf0105e55,0xc(%esp)
f0101404:	f0 
f0101405:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010140c:	f0 
f010140d:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
f0101414:	00 
f0101415:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010141c:	e8 95 ec ff ff       	call   f01000b6 <_panic>
f0101421:	89 f1                	mov    %esi,%ecx
f0101423:	29 d1                	sub    %edx,%ecx
f0101425:	c1 f9 03             	sar    $0x3,%ecx
f0101428:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010142b:	39 c8                	cmp    %ecx,%eax
f010142d:	77 24                	ja     f0101453 <mem_init+0x335>
f010142f:	c7 44 24 0c 72 5e 10 	movl   $0xf0105e72,0xc(%esp)
f0101436:	f0 
f0101437:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010143e:	f0 
f010143f:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
f0101446:	00 
f0101447:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010144e:	e8 63 ec ff ff       	call   f01000b6 <_panic>
f0101453:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101456:	29 d1                	sub    %edx,%ecx
f0101458:	89 ca                	mov    %ecx,%edx
f010145a:	c1 fa 03             	sar    $0x3,%edx
f010145d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101460:	39 d0                	cmp    %edx,%eax
f0101462:	77 24                	ja     f0101488 <mem_init+0x36a>
f0101464:	c7 44 24 0c 8f 5e 10 	movl   $0xf0105e8f,0xc(%esp)
f010146b:	f0 
f010146c:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101473:	f0 
f0101474:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010147b:	00 
f010147c:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101483:	e8 2e ec ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101488:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
f010148d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101490:	c7 05 c0 d0 17 f0 00 	movl   $0x0,0xf017d0c0
f0101497:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010149a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a1:	e8 33 f9 ff ff       	call   f0100dd9 <page_alloc>
f01014a6:	85 c0                	test   %eax,%eax
f01014a8:	74 24                	je     f01014ce <mem_init+0x3b0>
f01014aa:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01014b9:	f0 
f01014ba:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01014c1:	00 
f01014c2:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01014fb:	c7 44 24 0c 01 5e 10 	movl   $0xf0105e01,0xc(%esp)
f0101502:	f0 
f0101503:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010150a:	f0 
f010150b:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0101512:	00 
f0101513:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010151a:	e8 97 eb ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f010151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101526:	e8 ae f8 ff ff       	call   f0100dd9 <page_alloc>
f010152b:	89 c7                	mov    %eax,%edi
f010152d:	85 c0                	test   %eax,%eax
f010152f:	75 24                	jne    f0101555 <mem_init+0x437>
f0101531:	c7 44 24 0c 17 5e 10 	movl   $0xf0105e17,0xc(%esp)
f0101538:	f0 
f0101539:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101540:	f0 
f0101541:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101548:	00 
f0101549:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101550:	e8 61 eb ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155c:	e8 78 f8 ff ff       	call   f0100dd9 <page_alloc>
f0101561:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101564:	85 c0                	test   %eax,%eax
f0101566:	75 24                	jne    f010158c <mem_init+0x46e>
f0101568:	c7 44 24 0c 2d 5e 10 	movl   $0xf0105e2d,0xc(%esp)
f010156f:	f0 
f0101570:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101577:	f0 
f0101578:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f010157f:	00 
f0101580:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101587:	e8 2a eb ff ff       	call   f01000b6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010158c:	39 fe                	cmp    %edi,%esi
f010158e:	75 24                	jne    f01015b4 <mem_init+0x496>
f0101590:	c7 44 24 0c 43 5e 10 	movl   $0xf0105e43,0xc(%esp)
f0101597:	f0 
f0101598:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010159f:	f0 
f01015a0:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f01015a7:	00 
f01015a8:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01015af:	e8 02 eb ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015b7:	39 c7                	cmp    %eax,%edi
f01015b9:	74 04                	je     f01015bf <mem_init+0x4a1>
f01015bb:	39 c6                	cmp    %eax,%esi
f01015bd:	75 24                	jne    f01015e3 <mem_init+0x4c5>
f01015bf:	c7 44 24 0c c4 56 10 	movl   $0xf01056c4,0xc(%esp)
f01015c6:	f0 
f01015c7:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01015ce:	f0 
f01015cf:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f01015d6:	00 
f01015d7:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01015de:	e8 d3 ea ff ff       	call   f01000b6 <_panic>
	assert(!page_alloc(0));
f01015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ea:	e8 ea f7 ff ff       	call   f0100dd9 <page_alloc>
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	74 24                	je     f0101617 <mem_init+0x4f9>
f01015f3:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101602:	f0 
f0101603:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f010160a:	00 
f010160b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101636:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f010163d:	f0 
f010163e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101645:	00 
f0101646:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
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
f010166a:	e8 a8 35 00 00       	call   f0104c17 <memset>
	page_free(pp0);
f010166f:	89 34 24             	mov    %esi,(%esp)
f0101672:	e8 ed f7 ff ff       	call   f0100e64 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010167e:	e8 56 f7 ff ff       	call   f0100dd9 <page_alloc>
f0101683:	85 c0                	test   %eax,%eax
f0101685:	75 24                	jne    f01016ab <mem_init+0x58d>
f0101687:	c7 44 24 0c bb 5e 10 	movl   $0xf0105ebb,0xc(%esp)
f010168e:	f0 
f010168f:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101696:	f0 
f0101697:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f010169e:	00 
f010169f:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01016a6:	e8 0b ea ff ff       	call   f01000b6 <_panic>
	assert(pp && pp0 == pp);
f01016ab:	39 c6                	cmp    %eax,%esi
f01016ad:	74 24                	je     f01016d3 <mem_init+0x5b5>
f01016af:	c7 44 24 0c d9 5e 10 	movl   $0xf0105ed9,0xc(%esp)
f01016b6:	f0 
f01016b7:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01016be:	f0 
f01016bf:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f01016c6:	00 
f01016c7:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01016f2:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101701:	00 
f0101702:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f0101709:	e8 a8 e9 ff ff       	call   f01000b6 <_panic>
f010170e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101714:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010171a:	80 38 00             	cmpb   $0x0,(%eax)
f010171d:	74 24                	je     f0101743 <mem_init+0x625>
f010171f:	c7 44 24 0c e9 5e 10 	movl   $0xf0105ee9,0xc(%esp)
f0101726:	f0 
f0101727:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010172e:	f0 
f010172f:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101736:	00 
f0101737:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f010174d:	a3 c0 d0 17 f0       	mov    %eax,0xf017d0c0

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
f010176d:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
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
f0101781:	c7 44 24 0c f3 5e 10 	movl   $0xf0105ef3,0xc(%esp)
f0101788:	f0 
f0101789:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101790:	f0 
f0101791:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101798:	00 
f0101799:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01017a0:	e8 11 e9 ff ff       	call   f01000b6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017a5:	c7 04 24 e4 56 10 f0 	movl   $0xf01056e4,(%esp)
f01017ac:	e8 53 1f 00 00       	call   f0103704 <cprintf>
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
f01017c4:	c7 44 24 0c 01 5e 10 	movl   $0xf0105e01,0xc(%esp)
f01017cb:	f0 
f01017cc:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01017e3:	e8 ce e8 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ef:	e8 e5 f5 ff ff       	call   f0100dd9 <page_alloc>
f01017f4:	89 c3                	mov    %eax,%ebx
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	75 24                	jne    f010181e <mem_init+0x700>
f01017fa:	c7 44 24 0c 17 5e 10 	movl   $0xf0105e17,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101819:	e8 98 e8 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f010181e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101825:	e8 af f5 ff ff       	call   f0100dd9 <page_alloc>
f010182a:	89 c6                	mov    %eax,%esi
f010182c:	85 c0                	test   %eax,%eax
f010182e:	75 24                	jne    f0101854 <mem_init+0x736>
f0101830:	c7 44 24 0c 2d 5e 10 	movl   $0xf0105e2d,0xc(%esp)
f0101837:	f0 
f0101838:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010183f:	f0 
f0101840:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101847:	00 
f0101848:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010184f:	e8 62 e8 ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101854:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101857:	75 24                	jne    f010187d <mem_init+0x75f>
f0101859:	c7 44 24 0c 43 5e 10 	movl   $0xf0105e43,0xc(%esp)
f0101860:	f0 
f0101861:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101868:	f0 
f0101869:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101870:	00 
f0101871:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101878:	e8 39 e8 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010187d:	39 c3                	cmp    %eax,%ebx
f010187f:	74 05                	je     f0101886 <mem_init+0x768>
f0101881:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101884:	75 24                	jne    f01018aa <mem_init+0x78c>
f0101886:	c7 44 24 0c c4 56 10 	movl   $0xf01056c4,0xc(%esp)
f010188d:	f0 
f010188e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01018a5:	e8 0c e8 ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018aa:	a1 c0 d0 17 f0       	mov    0xf017d0c0,%eax
f01018af:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018b2:	c7 05 c0 d0 17 f0 00 	movl   $0x0,0xf017d0c0
f01018b9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018c3:	e8 11 f5 ff ff       	call   f0100dd9 <page_alloc>
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	74 24                	je     f01018f0 <mem_init+0x7d2>
f01018cc:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f01018d3:	f0 
f01018d4:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01018db:	f0 
f01018dc:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01018e3:	00 
f01018e4:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101910:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f0101917:	f0 
f0101918:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010191f:	f0 
f0101920:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101927:	00 
f0101928:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101959:	c7 44 24 0c 3c 57 10 	movl   $0xf010573c,0xc(%esp)
f0101960:	f0 
f0101961:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101968:	f0 
f0101969:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101970:	00 
f0101971:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01019ad:	c7 44 24 0c 6c 57 10 	movl   $0xf010576c,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01019f8:	c7 44 24 0c 9c 57 10 	movl   $0xf010579c,0xc(%esp)
f01019ff:	f0 
f0101a00:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101a07:	f0 
f0101a08:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101a0f:	00 
f0101a10:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101a37:	c7 44 24 0c c4 57 10 	movl   $0xf01057c4,0xc(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101a4e:	00 
f0101a4f:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101a56:	e8 5b e6 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0101a5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a60:	74 24                	je     f0101a86 <mem_init+0x968>
f0101a62:	c7 44 24 0c fe 5e 10 	movl   $0xf0105efe,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101a81:	e8 30 e6 ff ff       	call   f01000b6 <_panic>
	assert(pp0->pp_ref == 1);
f0101a86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a89:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a8e:	74 24                	je     f0101ab4 <mem_init+0x996>
f0101a90:	c7 44 24 0c 0f 5f 10 	movl   $0xf0105f0f,0xc(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101ad4:	c7 44 24 0c f4 57 10 	movl   $0xf01057f4,0xc(%esp)
f0101adb:	f0 
f0101adc:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101ae3:	f0 
f0101ae4:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0101aeb:	00 
f0101aec:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101b19:	c7 44 24 0c 30 58 10 	movl   $0xf0105830,0xc(%esp)
f0101b20:	f0 
f0101b21:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101b28:	f0 
f0101b29:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101b30:	00 
f0101b31:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101b38:	e8 79 e5 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101b3d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b42:	74 24                	je     f0101b68 <mem_init+0xa4a>
f0101b44:	c7 44 24 0c 20 5f 10 	movl   $0xf0105f20,0xc(%esp)
f0101b4b:	f0 
f0101b4c:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101b53:	f0 
f0101b54:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101b5b:	00 
f0101b5c:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101b63:	e8 4e e5 ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6f:	e8 65 f2 ff ff       	call   f0100dd9 <page_alloc>
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	74 24                	je     f0101b9c <mem_init+0xa7e>
f0101b78:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f0101b7f:	f0 
f0101b80:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101b8f:	00 
f0101b90:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101bc1:	c7 44 24 0c f4 57 10 	movl   $0xf01057f4,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101c06:	c7 44 24 0c 30 58 10 	movl   $0xf0105830,0xc(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101c15:	f0 
f0101c16:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101c1d:	00 
f0101c1e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101c25:	e8 8c e4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101c2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c2f:	74 24                	je     f0101c55 <mem_init+0xb37>
f0101c31:	c7 44 24 0c 20 5f 10 	movl   $0xf0105f20,0xc(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101c40:	f0 
f0101c41:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101c48:	00 
f0101c49:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101c50:	e8 61 e4 ff ff       	call   f01000b6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5c:	e8 78 f1 ff ff       	call   f0100dd9 <page_alloc>
f0101c61:	85 c0                	test   %eax,%eax
f0101c63:	74 24                	je     f0101c89 <mem_init+0xb6b>
f0101c65:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f0101c6c:	f0 
f0101c6d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101c74:	f0 
f0101c75:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101c7c:	00 
f0101c7d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101ca7:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101cb6:	00 
f0101cb7:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101ce3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101ce6:	8d 57 04             	lea    0x4(%edi),%edx
f0101ce9:	39 d0                	cmp    %edx,%eax
f0101ceb:	74 24                	je     f0101d11 <mem_init+0xbf3>
f0101ced:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101cfc:	f0 
f0101cfd:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101d04:	00 
f0101d05:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101d36:	c7 44 24 0c a0 58 10 	movl   $0xf01058a0,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101d7e:	c7 44 24 0c 30 58 10 	movl   $0xf0105830,0xc(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101d95:	00 
f0101d96:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101d9d:	e8 14 e3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101da2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101da7:	74 24                	je     f0101dcd <mem_init+0xcaf>
f0101da9:	c7 44 24 0c 20 5f 10 	movl   $0xf0105f20,0xc(%esp)
f0101db0:	f0 
f0101db1:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101dc0:	00 
f0101dc1:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101dea:	c7 44 24 0c e0 58 10 	movl   $0xf01058e0,0xc(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101e01:	00 
f0101e02:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0101e09:	e8 a8 e2 ff ff       	call   f01000b6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e0e:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0101e13:	f6 00 04             	testb  $0x4,(%eax)
f0101e16:	75 24                	jne    f0101e3c <mem_init+0xd1e>
f0101e18:	c7 44 24 0c 31 5f 10 	movl   $0xf0105f31,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101e5c:	c7 44 24 0c f4 57 10 	movl   $0xf01057f4,0xc(%esp)
f0101e63:	f0 
f0101e64:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101e73:	00 
f0101e74:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101ea2:	c7 44 24 0c 14 59 10 	movl   $0xf0105914,0xc(%esp)
f0101ea9:	f0 
f0101eaa:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101eb9:	00 
f0101eba:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101ee8:	c7 44 24 0c 48 59 10 	movl   $0xf0105948,0xc(%esp)
f0101eef:	f0 
f0101ef0:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101ef7:	f0 
f0101ef8:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101eff:	00 
f0101f00:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101f34:	c7 44 24 0c 80 59 10 	movl   $0xf0105980,0xc(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101f43:	f0 
f0101f44:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101f4b:	00 
f0101f4c:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101f7d:	c7 44 24 0c b8 59 10 	movl   $0xf01059b8,0xc(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101f8c:	f0 
f0101f8d:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101f94:	00 
f0101f95:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0101fc3:	c7 44 24 0c 48 59 10 	movl   $0xf0105948,0xc(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101fda:	00 
f0101fdb:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0102010:	c7 44 24 0c f4 59 10 	movl   $0xf01059f4,0xc(%esp)
f0102017:	f0 
f0102018:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010201f:	f0 
f0102020:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102027:	00 
f0102028:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010202f:	e8 82 e0 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102034:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102039:	89 f8                	mov    %edi,%eax
f010203b:	e8 f8 e8 ff ff       	call   f0100938 <check_va2pa>
f0102040:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102043:	74 24                	je     f0102069 <mem_init+0xf4b>
f0102045:	c7 44 24 0c 20 5a 10 	movl   $0xf0105a20,0xc(%esp)
f010204c:	f0 
f010204d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102054:	f0 
f0102055:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f010205c:	00 
f010205d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102064:	e8 4d e0 ff ff       	call   f01000b6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102069:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010206e:	74 24                	je     f0102094 <mem_init+0xf76>
f0102070:	c7 44 24 0c 47 5f 10 	movl   $0xf0105f47,0xc(%esp)
f0102077:	f0 
f0102078:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010207f:	f0 
f0102080:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102087:	00 
f0102088:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010208f:	e8 22 e0 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102094:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102099:	74 24                	je     f01020bf <mem_init+0xfa1>
f010209b:	c7 44 24 0c 58 5f 10 	movl   $0xf0105f58,0xc(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01020b2:	00 
f01020b3:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01020ba:	e8 f7 df ff ff       	call   f01000b6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020c6:	e8 0e ed ff ff       	call   f0100dd9 <page_alloc>
f01020cb:	85 c0                	test   %eax,%eax
f01020cd:	74 04                	je     f01020d3 <mem_init+0xfb5>
f01020cf:	39 c6                	cmp    %eax,%esi
f01020d1:	74 24                	je     f01020f7 <mem_init+0xfd9>
f01020d3:	c7 44 24 0c 50 5a 10 	movl   $0xf0105a50,0xc(%esp)
f01020da:	f0 
f01020db:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01020ea:	00 
f01020eb:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0102123:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f010212a:	f0 
f010212b:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102132:	f0 
f0102133:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010213a:	00 
f010213b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0102165:	c7 44 24 0c 20 5a 10 	movl   $0xf0105a20,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102184:	e8 2d df ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0102189:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010218e:	74 24                	je     f01021b4 <mem_init+0x1096>
f0102190:	c7 44 24 0c fe 5e 10 	movl   $0xf0105efe,0xc(%esp)
f0102197:	f0 
f0102198:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01021a7:	00 
f01021a8:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01021af:	e8 02 df ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f01021b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021b9:	74 24                	je     f01021df <mem_init+0x10c1>
f01021bb:	c7 44 24 0c 58 5f 10 	movl   $0xf0105f58,0xc(%esp)
f01021c2:	f0 
f01021c3:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01021ca:	f0 
f01021cb:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01021d2:	00 
f01021d3:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01021ff:	c7 44 24 0c 98 5a 10 	movl   $0xf0105a98,0xc(%esp)
f0102206:	f0 
f0102207:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010220e:	f0 
f010220f:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102216:	00 
f0102217:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010221e:	e8 93 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref);
f0102223:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102228:	75 24                	jne    f010224e <mem_init+0x1130>
f010222a:	c7 44 24 0c 69 5f 10 	movl   $0xf0105f69,0xc(%esp)
f0102231:	f0 
f0102232:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102239:	f0 
f010223a:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102241:	00 
f0102242:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102249:	e8 68 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_link == NULL);
f010224e:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102251:	74 24                	je     f0102277 <mem_init+0x1159>
f0102253:	c7 44 24 0c 75 5f 10 	movl   $0xf0105f75,0xc(%esp)
f010225a:	f0 
f010225b:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102262:	f0 
f0102263:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010226a:	00 
f010226b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01022a3:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01022c2:	e8 ef dd ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022c7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022cc:	89 f8                	mov    %edi,%eax
f01022ce:	e8 65 e6 ff ff       	call   f0100938 <check_va2pa>
f01022d3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022d6:	74 24                	je     f01022fc <mem_init+0x11de>
f01022d8:	c7 44 24 0c d0 5a 10 	movl   $0xf0105ad0,0xc(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01022ef:	00 
f01022f0:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01022f7:	e8 ba dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f01022fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102301:	74 24                	je     f0102327 <mem_init+0x1209>
f0102303:	c7 44 24 0c 8a 5f 10 	movl   $0xf0105f8a,0xc(%esp)
f010230a:	f0 
f010230b:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102322:	e8 8f dd ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f0102327:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010232c:	74 24                	je     f0102352 <mem_init+0x1234>
f010232e:	c7 44 24 0c 58 5f 10 	movl   $0xf0105f58,0xc(%esp)
f0102335:	f0 
f0102336:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010233d:	f0 
f010233e:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102345:	00 
f0102346:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010234d:	e8 64 dd ff ff       	call   f01000b6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102352:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102359:	e8 7b ea ff ff       	call   f0100dd9 <page_alloc>
f010235e:	85 c0                	test   %eax,%eax
f0102360:	74 04                	je     f0102366 <mem_init+0x1248>
f0102362:	39 c3                	cmp    %eax,%ebx
f0102364:	74 24                	je     f010238a <mem_init+0x126c>
f0102366:	c7 44 24 0c f8 5a 10 	movl   $0xf0105af8,0xc(%esp)
f010236d:	f0 
f010236e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102375:	f0 
f0102376:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010237d:	00 
f010237e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102385:	e8 2c dd ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010238a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102391:	e8 43 ea ff ff       	call   f0100dd9 <page_alloc>
f0102396:	85 c0                	test   %eax,%eax
f0102398:	74 24                	je     f01023be <mem_init+0x12a0>
f010239a:	c7 44 24 0c ac 5e 10 	movl   $0xf0105eac,0xc(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01023de:	c7 44 24 0c 9c 57 10 	movl   $0xf010579c,0xc(%esp)
f01023e5:	f0 
f01023e6:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01023ed:	f0 
f01023ee:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f01023f5:	00 
f01023f6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01023fd:	e8 b4 dc ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010240b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102410:	74 24                	je     f0102436 <mem_init+0x1318>
f0102412:	c7 44 24 0c 0f 5f 10 	movl   $0xf0105f0f,0xc(%esp)
f0102419:	f0 
f010241a:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102421:	f0 
f0102422:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102429:	00 
f010242a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f010248c:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0102493:	f0 
f0102494:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010249b:	00 
f010249c:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01024a3:	e8 0e dc ff ff       	call   f01000b6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024a8:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f01024ae:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01024b1:	74 24                	je     f01024d7 <mem_init+0x13b9>
f01024b3:	c7 44 24 0c 9b 5f 10 	movl   $0xf0105f9b,0xc(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01024c2:	f0 
f01024c3:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f01024ca:	00 
f01024cb:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f0102500:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0102507:	f0 
f0102508:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010250f:	00 
f0102510:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
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
f0102534:	e8 de 26 00 00       	call   f0104c17 <memset>
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
f0102580:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0102587:	f0 
f0102588:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010258f:	00 
f0102590:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
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
f01025b0:	c7 44 24 0c b3 5f 10 	movl   $0xf0105fb3,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
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
f01025ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01025f2:	89 0d c0 d0 17 f0    	mov    %ecx,0xf017d0c0

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
f0102610:	c7 04 24 ca 5f 10 f0 	movl   $0xf0105fca,(%esp)
f0102617:	e8 e8 10 00 00       	call   f0103704 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	int perm = PTE_U | PTE_P;
	int i=0;
	 n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010261c:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f0102621:	8d 1c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ebx
f0102628:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
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
f010263e:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0102645:	f0 
f0102646:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f010264d:	00 
f010264e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102655:	e8 5c da ff ff       	call   f01000b6 <_panic>
f010265a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102661:	00 
	return (physaddr_t)kva - KERNBASE;
f0102662:	05 00 00 00 10       	add    $0x10000000,%eax
f0102667:	89 04 24             	mov    %eax,(%esp)
f010266a:	89 d9                	mov    %ebx,%ecx
f010266c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102671:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102676:	e8 ec e8 ff ff       	call   f0100f67 <boot_map_region>
	 boot_map_region(kern_pgdir, (pte_t) pages, n, PADDR(pages), (PTE_W | PTE_P) );
f010267b:	8b 15 8c dd 17 f0    	mov    0xf017dd8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102681:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102687:	77 20                	ja     f01026a9 <mem_init+0x158b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102689:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010268d:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0102694:	f0 
f0102695:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010269c:	00 
f010269d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01026a4:	e8 0d da ff ff       	call   f01000b6 <_panic>
f01026a9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01026b0:	00 
	return (physaddr_t)kva - KERNBASE;
f01026b1:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01026b7:	89 04 24             	mov    %eax,(%esp)
f01026ba:	89 d9                	mov    %ebx,%ecx
f01026bc:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01026c1:	e8 a1 e8 ff ff       	call   f0100f67 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	perm = 0x0 | PTE_U | PTE_P;
	n = ROUNDUP(NENV*sizeof(struct Env) , PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), perm);
f01026c6:	a1 cc d0 17 f0       	mov    0xf017d0cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d0:	77 20                	ja     f01026f2 <mem_init+0x15d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026d6:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f01026dd:	f0 
f01026de:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f01026e5:	00 
f01026e6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01026ed:	e8 c4 d9 ff ff       	call   f01000b6 <_panic>
f01026f2:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01026f9:	00 
	return (physaddr_t)kva - KERNBASE;
f01026fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01026ff:	89 04 24             	mov    %eax,(%esp)
f0102702:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102707:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010270c:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102711:	e8 51 e8 ff ff       	call   f0100f67 <boot_map_region>
	boot_map_region(kern_pgdir, (pte_t) envs, n, PADDR(envs), (PTE_W | PTE_P));
f0102716:	8b 15 cc d0 17 f0    	mov    0xf017d0cc,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010271c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102722:	77 20                	ja     f0102744 <mem_init+0x1626>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102724:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102728:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f010272f:	f0 
f0102730:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0102737:	00 
f0102738:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010273f:	e8 72 d9 ff ff       	call   f01000b6 <_panic>
f0102744:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010274b:	00 
	return (physaddr_t)kva - KERNBASE;
f010274c:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102752:	89 04 24             	mov    %eax,(%esp)
f0102755:	b9 00 80 01 00       	mov    $0x18000,%ecx
f010275a:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f010275f:	e8 03 e8 ff ff       	call   f0100f67 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102764:	bb 00 10 11 f0       	mov    $0xf0111000,%ebx
f0102769:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010276f:	77 20                	ja     f0102791 <mem_init+0x1673>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102771:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102775:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f010277c:	f0 
f010277d:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f0102784:	00 
f0102785:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010278c:	e8 25 d9 ff ff       	call   f01000b6 <_panic>
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	perm =0;
	perm = PTE_P |PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f0102791:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102798:	00 
f0102799:	c7 04 24 00 10 11 00 	movl   $0x111000,(%esp)
f01027a0:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027a5:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027aa:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01027af:	e8 b3 e7 ff ff       	call   f0100f67 <boot_map_region>
	int size = ~0;
	size = size - KERNBASE +1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm );
f01027b4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01027bb:	00 
f01027bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027c3:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027c8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027cd:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01027d2:	e8 90 e7 ff ff       	call   f0100f67 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027d7:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f01027dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027df:	a1 84 dd 17 f0       	mov    0xf017dd84,%eax
f01027e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01027e7:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027f6:	8b 3d 8c dd 17 f0    	mov    0xf017dd8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027fc:	89 7d c8             	mov    %edi,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01027ff:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102805:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102808:	be 00 00 00 00       	mov    $0x0,%esi
f010280d:	eb 6b                	jmp    f010287a <mem_init+0x175c>
f010280f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102818:	e8 1b e1 ff ff       	call   f0100938 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010281d:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f0102824:	77 20                	ja     f0102846 <mem_init+0x1728>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102826:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010282a:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0102831:	f0 
f0102832:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0102839:	00 
f010283a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102841:	e8 70 d8 ff ff       	call   f01000b6 <_panic>
f0102846:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102849:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010284c:	39 d0                	cmp    %edx,%eax
f010284e:	74 24                	je     f0102874 <mem_init+0x1756>
f0102850:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f0102857:	f0 
f0102858:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010285f:	f0 
f0102860:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0102867:	00 
f0102868:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010286f:	e8 42 d8 ff ff       	call   f01000b6 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102874:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010287a:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f010287d:	77 90                	ja     f010280f <mem_init+0x16f1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010287f:	8b 35 cc d0 17 f0    	mov    0xf017d0cc,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102885:	89 f7                	mov    %esi,%edi
f0102887:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010288c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010288f:	e8 a4 e0 ff ff       	call   f0100938 <check_va2pa>
f0102894:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010289a:	77 20                	ja     f01028bc <mem_init+0x179e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010289c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01028a0:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f01028a7:	f0 
f01028a8:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f01028af:	00 
f01028b0:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01028b7:	e8 fa d7 ff ff       	call   f01000b6 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028bc:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01028c1:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f01028c7:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01028ca:	39 c2                	cmp    %eax,%edx
f01028cc:	74 24                	je     f01028f2 <mem_init+0x17d4>
f01028ce:	c7 44 24 0c 50 5b 10 	movl   $0xf0105b50,0xc(%esp)
f01028d5:	f0 
f01028d6:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01028dd:	f0 
f01028de:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f01028e5:	00 
f01028e6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01028ed:	e8 c4 d7 ff ff       	call   f01000b6 <_panic>
f01028f2:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028f8:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01028fe:	0f 85 26 05 00 00    	jne    f0102e2a <mem_init+0x1d0c>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102904:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102907:	c1 e7 0c             	shl    $0xc,%edi
f010290a:	be 00 00 00 00       	mov    $0x0,%esi
f010290f:	eb 3c                	jmp    f010294d <mem_init+0x182f>
f0102911:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102917:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010291a:	e8 19 e0 ff ff       	call   f0100938 <check_va2pa>
f010291f:	39 c6                	cmp    %eax,%esi
f0102921:	74 24                	je     f0102947 <mem_init+0x1829>
f0102923:	c7 44 24 0c 84 5b 10 	movl   $0xf0105b84,0xc(%esp)
f010292a:	f0 
f010292b:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102932:	f0 
f0102933:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f010293a:	00 
f010293b:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102942:	e8 6f d7 ff ff       	call   f01000b6 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102947:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010294d:	39 fe                	cmp    %edi,%esi
f010294f:	72 c0                	jb     f0102911 <mem_init+0x17f3>
f0102951:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102956:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010295c:	89 f2                	mov    %esi,%edx
f010295e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102961:	e8 d2 df ff ff       	call   f0100938 <check_va2pa>
f0102966:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102969:	39 d0                	cmp    %edx,%eax
f010296b:	74 24                	je     f0102991 <mem_init+0x1873>
f010296d:	c7 44 24 0c ac 5b 10 	movl   $0xf0105bac,0xc(%esp)
f0102974:	f0 
f0102975:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f010297c:	f0 
f010297d:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102984:	00 
f0102985:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f010298c:	e8 25 d7 ff ff       	call   f01000b6 <_panic>
f0102991:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102997:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010299d:	75 bd                	jne    f010295c <mem_init+0x183e>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010299f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029a4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029a7:	89 f8                	mov    %edi,%eax
f01029a9:	e8 8a df ff ff       	call   f0100938 <check_va2pa>
f01029ae:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029b1:	75 0c                	jne    f01029bf <mem_init+0x18a1>
f01029b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01029b8:	89 fa                	mov    %edi,%edx
f01029ba:	e9 f0 00 00 00       	jmp    f0102aaf <mem_init+0x1991>
f01029bf:	c7 44 24 0c f4 5b 10 	movl   $0xf0105bf4,0xc(%esp)
f01029c6:	f0 
f01029c7:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f01029ce:	f0 
f01029cf:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01029d6:	00 
f01029d7:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f01029de:	e8 d3 d6 ff ff       	call   f01000b6 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029e3:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01029e8:	72 3c                	jb     f0102a26 <mem_init+0x1908>
f01029ea:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01029ef:	76 07                	jbe    f01029f8 <mem_init+0x18da>
f01029f1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029f6:	75 2e                	jne    f0102a26 <mem_init+0x1908>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01029f8:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f01029fc:	0f 85 aa 00 00 00    	jne    f0102aac <mem_init+0x198e>
f0102a02:	c7 44 24 0c e3 5f 10 	movl   $0xf0105fe3,0xc(%esp)
f0102a09:	f0 
f0102a0a:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102a11:	f0 
f0102a12:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0102a19:	00 
f0102a1a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102a21:	e8 90 d6 ff ff       	call   f01000b6 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a26:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a2b:	76 55                	jbe    f0102a82 <mem_init+0x1964>
				assert(pgdir[i] & PTE_P);
f0102a2d:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102a30:	f6 c1 01             	test   $0x1,%cl
f0102a33:	75 24                	jne    f0102a59 <mem_init+0x193b>
f0102a35:	c7 44 24 0c e3 5f 10 	movl   $0xf0105fe3,0xc(%esp)
f0102a3c:	f0 
f0102a3d:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0102a4c:	00 
f0102a4d:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102a54:	e8 5d d6 ff ff       	call   f01000b6 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a59:	f6 c1 02             	test   $0x2,%cl
f0102a5c:	75 4e                	jne    f0102aac <mem_init+0x198e>
f0102a5e:	c7 44 24 0c f4 5f 10 	movl   $0xf0105ff4,0xc(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0102a75:	00 
f0102a76:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102a7d:	e8 34 d6 ff ff       	call   f01000b6 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a82:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f0102a86:	74 24                	je     f0102aac <mem_init+0x198e>
f0102a88:	c7 44 24 0c 05 60 10 	movl   $0xf0106005,0xc(%esp)
f0102a8f:	f0 
f0102a90:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102aa7:	e8 0a d6 ff ff       	call   f01000b6 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102aac:	83 c0 01             	add    $0x1,%eax
f0102aaf:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ab4:	0f 85 29 ff ff ff    	jne    f01029e3 <mem_init+0x18c5>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102aba:	c7 04 24 24 5c 10 f0 	movl   $0xf0105c24,(%esp)
f0102ac1:	e8 3e 0c 00 00       	call   f0103704 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ac6:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102acb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ad0:	77 20                	ja     f0102af2 <mem_init+0x19d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ad6:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102aed:	e8 c4 d5 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102af2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102af7:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102afa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aff:	e8 a3 de ff ff       	call   f01009a7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b04:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b07:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b0a:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b0f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b19:	e8 bb e2 ff ff       	call   f0100dd9 <page_alloc>
f0102b1e:	89 c3                	mov    %eax,%ebx
f0102b20:	85 c0                	test   %eax,%eax
f0102b22:	75 24                	jne    f0102b48 <mem_init+0x1a2a>
f0102b24:	c7 44 24 0c 01 5e 10 	movl   $0xf0105e01,0xc(%esp)
f0102b2b:	f0 
f0102b2c:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102b33:	f0 
f0102b34:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102b3b:	00 
f0102b3c:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102b43:	e8 6e d5 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b4f:	e8 85 e2 ff ff       	call   f0100dd9 <page_alloc>
f0102b54:	89 c7                	mov    %eax,%edi
f0102b56:	85 c0                	test   %eax,%eax
f0102b58:	75 24                	jne    f0102b7e <mem_init+0x1a60>
f0102b5a:	c7 44 24 0c 17 5e 10 	movl   $0xf0105e17,0xc(%esp)
f0102b61:	f0 
f0102b62:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102b69:	f0 
f0102b6a:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102b71:	00 
f0102b72:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102b79:	e8 38 d5 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b85:	e8 4f e2 ff ff       	call   f0100dd9 <page_alloc>
f0102b8a:	89 c6                	mov    %eax,%esi
f0102b8c:	85 c0                	test   %eax,%eax
f0102b8e:	75 24                	jne    f0102bb4 <mem_init+0x1a96>
f0102b90:	c7 44 24 0c 2d 5e 10 	movl   $0xf0105e2d,0xc(%esp)
f0102b97:	f0 
f0102b98:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102b9f:	f0 
f0102ba0:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102ba7:	00 
f0102ba8:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102baf:	e8 02 d5 ff ff       	call   f01000b6 <_panic>
	page_free(pp0);
f0102bb4:	89 1c 24             	mov    %ebx,(%esp)
f0102bb7:	e8 a8 e2 ff ff       	call   f0100e64 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bbc:	89 f8                	mov    %edi,%eax
f0102bbe:	e8 30 dd ff ff       	call   f01008f3 <page2kva>
f0102bc3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bca:	00 
f0102bcb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102bd2:	00 
f0102bd3:	89 04 24             	mov    %eax,(%esp)
f0102bd6:	e8 3c 20 00 00       	call   f0104c17 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bdb:	89 f0                	mov    %esi,%eax
f0102bdd:	e8 11 dd ff ff       	call   f01008f3 <page2kva>
f0102be2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102be9:	00 
f0102bea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102bf1:	00 
f0102bf2:	89 04 24             	mov    %eax,(%esp)
f0102bf5:	e8 1d 20 00 00       	call   f0104c17 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bfa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c01:	00 
f0102c02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c09:	00 
f0102c0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102c0e:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102c13:	89 04 24             	mov    %eax,(%esp)
f0102c16:	e8 70 e4 ff ff       	call   f010108b <page_insert>
	assert(pp1->pp_ref == 1);
f0102c1b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c20:	74 24                	je     f0102c46 <mem_init+0x1b28>
f0102c22:	c7 44 24 0c fe 5e 10 	movl   $0xf0105efe,0xc(%esp)
f0102c29:	f0 
f0102c2a:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102c31:	f0 
f0102c32:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102c39:	00 
f0102c3a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102c41:	e8 70 d4 ff ff       	call   f01000b6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c46:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c4d:	01 01 01 
f0102c50:	74 24                	je     f0102c76 <mem_init+0x1b58>
f0102c52:	c7 44 24 0c 44 5c 10 	movl   $0xf0105c44,0xc(%esp)
f0102c59:	f0 
f0102c5a:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102c61:	f0 
f0102c62:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102c69:	00 
f0102c6a:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102c71:	e8 40 d4 ff ff       	call   f01000b6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c76:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c7d:	00 
f0102c7e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c85:	00 
f0102c86:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c8a:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102c8f:	89 04 24             	mov    %eax,(%esp)
f0102c92:	e8 f4 e3 ff ff       	call   f010108b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c97:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c9e:	02 02 02 
f0102ca1:	74 24                	je     f0102cc7 <mem_init+0x1ba9>
f0102ca3:	c7 44 24 0c 68 5c 10 	movl   $0xf0105c68,0xc(%esp)
f0102caa:	f0 
f0102cab:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102cb2:	f0 
f0102cb3:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102cba:	00 
f0102cbb:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102cc2:	e8 ef d3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0102cc7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ccc:	74 24                	je     f0102cf2 <mem_init+0x1bd4>
f0102cce:	c7 44 24 0c 20 5f 10 	movl   $0xf0105f20,0xc(%esp)
f0102cd5:	f0 
f0102cd6:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102cdd:	f0 
f0102cde:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102ce5:	00 
f0102ce6:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102ced:	e8 c4 d3 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102cf2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cf7:	74 24                	je     f0102d1d <mem_init+0x1bff>
f0102cf9:	c7 44 24 0c 8a 5f 10 	movl   $0xf0105f8a,0xc(%esp)
f0102d00:	f0 
f0102d01:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102d08:	f0 
f0102d09:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102d10:	00 
f0102d11:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102d18:	e8 99 d3 ff ff       	call   f01000b6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d1d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d24:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d27:	89 f0                	mov    %esi,%eax
f0102d29:	e8 c5 db ff ff       	call   f01008f3 <page2kva>
f0102d2e:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102d34:	74 24                	je     f0102d5a <mem_init+0x1c3c>
f0102d36:	c7 44 24 0c 8c 5c 10 	movl   $0xf0105c8c,0xc(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102d45:	f0 
f0102d46:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102d4d:	00 
f0102d4e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102d55:	e8 5c d3 ff ff       	call   f01000b6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d5a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d61:	00 
f0102d62:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102d67:	89 04 24             	mov    %eax,(%esp)
f0102d6a:	e8 ce e2 ff ff       	call   f010103d <page_remove>
	assert(pp2->pp_ref == 0);
f0102d6f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d74:	74 24                	je     f0102d9a <mem_init+0x1c7c>
f0102d76:	c7 44 24 0c 58 5f 10 	movl   $0xf0105f58,0xc(%esp)
f0102d7d:	f0 
f0102d7e:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102d85:	f0 
f0102d86:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102d8d:	00 
f0102d8e:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102d95:	e8 1c d3 ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d9a:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0102d9f:	8b 08                	mov    (%eax),%ecx
f0102da1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102da7:	89 da                	mov    %ebx,%edx
f0102da9:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f0102daf:	c1 fa 03             	sar    $0x3,%edx
f0102db2:	c1 e2 0c             	shl    $0xc,%edx
f0102db5:	39 d1                	cmp    %edx,%ecx
f0102db7:	74 24                	je     f0102ddd <mem_init+0x1cbf>
f0102db9:	c7 44 24 0c 9c 57 10 	movl   $0xf010579c,0xc(%esp)
f0102dc0:	f0 
f0102dc1:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102dc8:	f0 
f0102dc9:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102dd0:	00 
f0102dd1:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102dd8:	e8 d9 d2 ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102ddd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102de3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102de8:	74 24                	je     f0102e0e <mem_init+0x1cf0>
f0102dea:	c7 44 24 0c 0f 5f 10 	movl   $0xf0105f0f,0xc(%esp)
f0102df1:	f0 
f0102df2:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0102df9:	f0 
f0102dfa:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102e01:	00 
f0102e02:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102e09:	e8 a8 d2 ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102e0e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e14:	89 1c 24             	mov    %ebx,(%esp)
f0102e17:	e8 48 e0 ff ff       	call   f0100e64 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e1c:	c7 04 24 b8 5c 10 f0 	movl   $0xf0105cb8,(%esp)
f0102e23:	e8 dc 08 00 00       	call   f0103704 <cprintf>
f0102e28:	eb 0f                	jmp    f0102e39 <mem_init+0x1d1b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e2a:	89 f2                	mov    %esi,%edx
f0102e2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e2f:	e8 04 db ff ff       	call   f0100938 <check_va2pa>
f0102e34:	e9 8e fa ff ff       	jmp    f01028c7 <mem_init+0x17a9>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e39:	83 c4 4c             	add    $0x4c,%esp
f0102e3c:	5b                   	pop    %ebx
f0102e3d:	5e                   	pop    %esi
f0102e3e:	5f                   	pop    %edi
f0102e3f:	5d                   	pop    %ebp
f0102e40:	c3                   	ret    

f0102e41 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102e41:	55                   	push   %ebp
f0102e42:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102e44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e47:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102e4a:	5d                   	pop    %ebp
f0102e4b:	c3                   	ret    

f0102e4c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e4c:	55                   	push   %ebp
f0102e4d:	89 e5                	mov    %esp,%ebp
f0102e4f:	57                   	push   %edi
f0102e50:	56                   	push   %esi
f0102e51:	53                   	push   %ebx
f0102e52:	83 ec 2c             	sub    $0x2c,%esp
f0102e55:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e58:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.
	pte_t ea =(pte_t)  ROUNDUP(va+len, PGSIZE);
f0102e5b:	89 c2                	mov    %eax,%edx
f0102e5d:	03 55 10             	add    0x10(%ebp),%edx
f0102e60:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0102e66:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e6c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	pte_t *pte;
	perm |= PTE_U;
f0102e6f:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102e72:	83 cb 04             	or     $0x4,%ebx
	for(user_mem_check_addr = (pte_t) va; user_mem_check_addr != ea; user_mem_check_addr += PGSIZE){
f0102e75:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
		page_lookup(env->env_pgdir, (void*)user_mem_check_addr, &pte);
f0102e7a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
{
	// LAB 3: Your code here.
	pte_t ea =(pte_t)  ROUNDUP(va+len, PGSIZE);
	pte_t *pte;
	perm |= PTE_U;
	for(user_mem_check_addr = (pte_t) va; user_mem_check_addr != ea; user_mem_check_addr += PGSIZE){
f0102e7d:	eb 3f                	jmp    f0102ebe <user_mem_check+0x72>
		page_lookup(env->env_pgdir, (void*)user_mem_check_addr, &pte);
f0102e7f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102e83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e87:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e8a:	89 04 24             	mov    %eax,(%esp)
f0102e8d:	e8 36 e1 ff ff       	call   f0100fc8 <page_lookup>
		*pte = *pte & 0xfff & perm;
f0102e92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e95:	89 da                	mov    %ebx,%edx
f0102e97:	23 10                	and    (%eax),%edx
f0102e99:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0102e9f:	89 10                	mov    %edx,(%eax)
		if(*pte != perm)
f0102ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ea4:	3b 18                	cmp    (%eax),%ebx
f0102ea6:	75 27                	jne    f0102ecf <user_mem_check+0x83>
			return  -E_FAULT;
		if(user_mem_check_addr > ULIM)
f0102ea8:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f0102ead:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f0102eb2:	77 20                	ja     f0102ed4 <user_mem_check+0x88>
{
	// LAB 3: Your code here.
	pte_t ea =(pte_t)  ROUNDUP(va+len, PGSIZE);
	pte_t *pte;
	perm |= PTE_U;
	for(user_mem_check_addr = (pte_t) va; user_mem_check_addr != ea; user_mem_check_addr += PGSIZE){
f0102eb4:	05 00 10 00 00       	add    $0x1000,%eax
f0102eb9:	a3 bc d0 17 f0       	mov    %eax,0xf017d0bc
f0102ebe:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f0102ec3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102ec6:	75 b7                	jne    f0102e7f <user_mem_check+0x33>
		if(*pte != perm)
			return  -E_FAULT;
		if(user_mem_check_addr > ULIM)
			return user_mem_check_addr;
	}
	return 0;
f0102ec8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ecd:	eb 05                	jmp    f0102ed4 <user_mem_check+0x88>
	perm |= PTE_U;
	for(user_mem_check_addr = (pte_t) va; user_mem_check_addr != ea; user_mem_check_addr += PGSIZE){
		page_lookup(env->env_pgdir, (void*)user_mem_check_addr, &pte);
		*pte = *pte & 0xfff & perm;
		if(*pte != perm)
			return  -E_FAULT;
f0102ecf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		if(user_mem_check_addr > ULIM)
			return user_mem_check_addr;
	}
	return 0;
}
f0102ed4:	83 c4 2c             	add    $0x2c,%esp
f0102ed7:	5b                   	pop    %ebx
f0102ed8:	5e                   	pop    %esi
f0102ed9:	5f                   	pop    %edi
f0102eda:	5d                   	pop    %ebp
f0102edb:	c3                   	ret    

f0102edc <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102edc:	55                   	push   %ebp
f0102edd:	89 e5                	mov    %esp,%ebp
f0102edf:	53                   	push   %ebx
f0102ee0:	83 ec 14             	sub    $0x14,%esp
f0102ee3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ee6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ee9:	83 c8 04             	or     $0x4,%eax
f0102eec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ef0:	8b 45 10             	mov    0x10(%ebp),%eax
f0102ef3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102efa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102efe:	89 1c 24             	mov    %ebx,(%esp)
f0102f01:	e8 46 ff ff ff       	call   f0102e4c <user_mem_check>
f0102f06:	85 c0                	test   %eax,%eax
f0102f08:	79 24                	jns    f0102f2e <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f0a:	a1 bc d0 17 f0       	mov    0xf017d0bc,%eax
f0102f0f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f13:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f1a:	c7 04 24 e4 5c 10 f0 	movl   $0xf0105ce4,(%esp)
f0102f21:	e8 de 07 00 00       	call   f0103704 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f26:	89 1c 24             	mov    %ebx,(%esp)
f0102f29:	e8 a3 06 00 00       	call   f01035d1 <env_destroy>
	}
}
f0102f2e:	83 c4 14             	add    $0x14,%esp
f0102f31:	5b                   	pop    %ebx
f0102f32:	5d                   	pop    %ebp
f0102f33:	c3                   	ret    

f0102f34 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f34:	55                   	push   %ebp
f0102f35:	89 e5                	mov    %esp,%ebp
f0102f37:	57                   	push   %edi
f0102f38:	56                   	push   %esi
f0102f39:	53                   	push   %ebx
f0102f3a:	83 ec 2c             	sub    $0x2c,%esp
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	pde_t* pgdir = e->env_pgdir;
f0102f3d:	8b 78 5c             	mov    0x5c(%eax),%edi
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
f0102f40:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102f47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f4c:	89 d1                	mov    %edx,%ecx
f0102f4e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102f54:	29 c8                	sub    %ecx,%eax
f0102f56:	c1 e8 0c             	shr    $0xc,%eax
f0102f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;i<npages;i++){
f0102f5c:	89 d6                	mov    %edx,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	pde_t* pgdir = e->env_pgdir;
	int i=0;
f0102f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0102f63:	eb 6d                	jmp    f0102fd2 <region_alloc+0x9e>
		struct PageInfo* newPage = page_alloc(0);
f0102f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f6c:	e8 68 de ff ff       	call   f0100dd9 <page_alloc>
		if(newPage == 0)
f0102f71:	85 c0                	test   %eax,%eax
f0102f73:	75 1c                	jne    f0102f91 <region_alloc+0x5d>
			panic("there is no more page to region_alloc for env\n");
f0102f75:	c7 44 24 08 14 60 10 	movl   $0xf0106014,0x8(%esp)
f0102f7c:	f0 
f0102f7d:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0102f84:	00 
f0102f85:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f0102f8c:	e8 25 d1 ff ff       	call   f01000b6 <_panic>
		int ret = page_insert(pgdir, newPage, va+i*PGSIZE, PTE_U|PTE_W );
f0102f91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102f98:	00 
f0102f99:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fa1:	89 3c 24             	mov    %edi,(%esp)
f0102fa4:	e8 e2 e0 ff ff       	call   f010108b <page_insert>
f0102fa9:	81 c6 00 10 00 00    	add    $0x1000,%esi
		if(ret)
f0102faf:	85 c0                	test   %eax,%eax
f0102fb1:	74 1c                	je     f0102fcf <region_alloc+0x9b>
			panic("page_insert fail\n");
f0102fb3:	c7 44 24 08 85 60 10 	movl   $0xf0106085,0x8(%esp)
f0102fba:	f0 
f0102fbb:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f0102fc2:	00 
f0102fc3:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f0102fca:	e8 e7 d0 ff ff       	call   f01000b6 <_panic>
	pde_t* pgdir = e->env_pgdir;
	int i=0;
	//page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	//struct PageInfo *page_alloc(int alloc_flags)
	int npages = (ROUNDUP((pte_t)va + len, PGSIZE) - ROUNDDOWN((pte_t)va, PGSIZE)) / PGSIZE;
	for(;i<npages;i++){
f0102fcf:	83 c3 01             	add    $0x1,%ebx
f0102fd2:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fd5:	7c 8e                	jl     f0102f65 <region_alloc+0x31>
	}
	return ;



}
f0102fd7:	83 c4 2c             	add    $0x2c,%esp
f0102fda:	5b                   	pop    %ebx
f0102fdb:	5e                   	pop    %esi
f0102fdc:	5f                   	pop    %edi
f0102fdd:	5d                   	pop    %ebp
f0102fde:	c3                   	ret    

f0102fdf <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fdf:	55                   	push   %ebp
f0102fe0:	89 e5                	mov    %esp,%ebp
f0102fe2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fe5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102fe8:	85 c0                	test   %eax,%eax
f0102fea:	75 11                	jne    f0102ffd <envid2env+0x1e>
		*env_store = curenv;
f0102fec:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0102ff1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ff4:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ffb:	eb 5e                	jmp    f010305b <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ffd:	89 c2                	mov    %eax,%edx
f0102fff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103005:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103008:	c1 e2 05             	shl    $0x5,%edx
f010300b:	03 15 cc d0 17 f0    	add    0xf017d0cc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103011:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103015:	74 05                	je     f010301c <envid2env+0x3d>
f0103017:	39 42 48             	cmp    %eax,0x48(%edx)
f010301a:	74 10                	je     f010302c <envid2env+0x4d>
		*env_store = 0;
f010301c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010301f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103025:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010302a:	eb 2f                	jmp    f010305b <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010302c:	84 c9                	test   %cl,%cl
f010302e:	74 21                	je     f0103051 <envid2env+0x72>
f0103030:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103035:	39 c2                	cmp    %eax,%edx
f0103037:	74 18                	je     f0103051 <envid2env+0x72>
f0103039:	8b 40 48             	mov    0x48(%eax),%eax
f010303c:	39 42 4c             	cmp    %eax,0x4c(%edx)
f010303f:	74 10                	je     f0103051 <envid2env+0x72>
		*env_store = 0;
f0103041:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010304a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010304f:	eb 0a                	jmp    f010305b <envid2env+0x7c>
	}

	*env_store = e;
f0103051:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103054:	89 10                	mov    %edx,(%eax)
	return 0;
f0103056:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010305b:	5d                   	pop    %ebp
f010305c:	c3                   	ret    

f010305d <env_init_percpu>:


// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010305d:	55                   	push   %ebp
f010305e:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103060:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0103065:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103068:	b8 23 00 00 00       	mov    $0x23,%eax
f010306d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010306f:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103071:	b0 10                	mov    $0x10,%al
f0103073:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103075:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103077:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103079:	ea 80 30 10 f0 08 00 	ljmp   $0x8,$0xf0103080
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103080:	b0 00                	mov    $0x0,%al
f0103082:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103085:	5d                   	pop    %ebp
f0103086:	c3                   	ret    

f0103087 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103087:	55                   	push   %ebp
f0103088:	89 e5                	mov    %esp,%ebp
f010308a:	56                   	push   %esi
f010308b:	53                   	push   %ebx
	// LAB 3: Your code here.

	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
		envs[i].env_id = 0;
f010308c:	8b 35 cc d0 17 f0    	mov    0xf017d0cc,%esi
f0103092:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0103098:	ba 00 04 00 00       	mov    $0x400,%edx
f010309d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030a2:	89 c3                	mov    %eax,%ebx
f01030a4:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030ab:	89 48 44             	mov    %ecx,0x44(%eax)
f01030ae:	83 e8 60             	sub    $0x60,%eax
	// Set up envs array
	// LAB 3: Your code here.

	env_free_list = 0;
	int i;
	for( i = NENV -1; i>=0; i--){
f01030b1:	83 ea 01             	sub    $0x1,%edx
f01030b4:	74 04                	je     f01030ba <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01030b6:	89 d9                	mov    %ebx,%ecx
f01030b8:	eb e8                	jmp    f01030a2 <env_init+0x1b>
f01030ba:	89 35 d0 d0 17 f0    	mov    %esi,0xf017d0d0
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01030c0:	e8 98 ff ff ff       	call   f010305d <env_init_percpu>

}
f01030c5:	5b                   	pop    %ebx
f01030c6:	5e                   	pop    %esi
f01030c7:	5d                   	pop    %ebp
f01030c8:	c3                   	ret    

f01030c9 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030c9:	55                   	push   %ebp
f01030ca:	89 e5                	mov    %esp,%ebp
f01030cc:	53                   	push   %ebx
f01030cd:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030d0:	8b 1d d0 d0 17 f0    	mov    0xf017d0d0,%ebx
f01030d6:	85 db                	test   %ebx,%ebx
f01030d8:	0f 84 6d 01 00 00    	je     f010324b <env_alloc+0x182>

	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01030e5:	e8 ef dc ff ff       	call   f0100dd9 <page_alloc>
f01030ea:	85 c0                	test   %eax,%eax
f01030ec:	0f 84 60 01 00 00    	je     f0103252 <env_alloc+0x189>
f01030f2:	89 c2                	mov    %eax,%edx
f01030f4:	2b 15 8c dd 17 f0    	sub    0xf017dd8c,%edx
f01030fa:	c1 fa 03             	sar    $0x3,%edx
f01030fd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103100:	89 d1                	mov    %edx,%ecx
f0103102:	c1 e9 0c             	shr    $0xc,%ecx
f0103105:	3b 0d 84 dd 17 f0    	cmp    0xf017dd84,%ecx
f010310b:	72 20                	jb     f010312d <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010310d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103111:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f0103118:	f0 
f0103119:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103120:	00 
f0103121:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f0103128:	e8 89 cf ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f010312d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103133:	89 53 5c             	mov    %edx,0x5c(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir =page2kva(p);
	p->pp_ref++;
f0103136:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	//照抄pgdir里面的东西,UTOP以上的。
	
	//i =  PDX(UTOP);
	//for(i ; i<1024; i++)
	//	e->env_pgdir[i] = kern_pgdir[i];
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010313b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103142:	00 
f0103143:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
f0103148:	89 44 24 04          	mov    %eax,0x4(%esp)
f010314c:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010314f:	89 04 24             	mov    %eax,(%esp)
f0103152:	e8 75 1b 00 00       	call   f0104ccc <memcpy>
	


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103157:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010315a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010315f:	77 20                	ja     f0103181 <env_alloc+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103161:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103165:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f010316c:	f0 
f010316d:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f0103174:	00 
f0103175:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f010317c:	e8 35 cf ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103181:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103187:	83 ca 05             	or     $0x5,%edx
f010318a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103190:	8b 43 48             	mov    0x48(%ebx),%eax
f0103193:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103198:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010319d:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031a2:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031a5:	89 da                	mov    %ebx,%edx
f01031a7:	2b 15 cc d0 17 f0    	sub    0xf017d0cc,%edx
f01031ad:	c1 fa 05             	sar    $0x5,%edx
f01031b0:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01031b6:	09 d0                	or     %edx,%eax
f01031b8:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031be:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031c1:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031c8:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031cf:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031d6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01031dd:	00 
f01031de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01031e5:	00 
f01031e6:	89 1c 24             	mov    %ebx,(%esp)
f01031e9:	e8 29 1a 00 00       	call   f0104c17 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031ee:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031f4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031fa:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103200:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103207:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010320d:	8b 43 44             	mov    0x44(%ebx),%eax
f0103210:	a3 d0 d0 17 f0       	mov    %eax,0xf017d0d0
	*newenv_store = e;
f0103215:	8b 45 08             	mov    0x8(%ebp),%eax
f0103218:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010321a:	8b 53 48             	mov    0x48(%ebx),%edx
f010321d:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103222:	85 c0                	test   %eax,%eax
f0103224:	74 05                	je     f010322b <env_alloc+0x162>
f0103226:	8b 40 48             	mov    0x48(%eax),%eax
f0103229:	eb 05                	jmp    f0103230 <env_alloc+0x167>
f010322b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103230:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103234:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103238:	c7 04 24 97 60 10 f0 	movl   $0xf0106097,(%esp)
f010323f:	e8 c0 04 00 00       	call   f0103704 <cprintf>
	return 0;
f0103244:	b8 00 00 00 00       	mov    $0x0,%eax
f0103249:	eb 0c                	jmp    f0103257 <env_alloc+0x18e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010324b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103250:	eb 05                	jmp    f0103257 <env_alloc+0x18e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103252:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103257:	83 c4 14             	add    $0x14,%esp
f010325a:	5b                   	pop    %ebx
f010325b:	5d                   	pop    %ebp
f010325c:	c3                   	ret    

f010325d <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010325d:	55                   	push   %ebp
f010325e:	89 e5                	mov    %esp,%ebp
f0103260:	57                   	push   %edi
f0103261:	56                   	push   %esi
f0103262:	53                   	push   %ebx
f0103263:	83 ec 3c             	sub    $0x3c,%esp
	//env_alloc(struct Env **newenv_store, envid_t parent_id)
	// LAB 3: Your code here.
	struct Env* env=0;
f0103266:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&env, 0);
f010326d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103274:	00 
f0103275:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103278:	89 04 24             	mov    %eax,(%esp)
f010327b:	e8 49 fe ff ff       	call   f01030c9 <env_alloc>
	if(r < 0)
f0103280:	85 c0                	test   %eax,%eax
f0103282:	79 1c                	jns    f01032a0 <env_create+0x43>
		panic("env_create fault\n");
f0103284:	c7 44 24 08 ac 60 10 	movl   $0xf01060ac,0x8(%esp)
f010328b:	f0 
f010328c:	c7 44 24 04 b0 01 00 	movl   $0x1b0,0x4(%esp)
f0103293:	00 
f0103294:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f010329b:	e8 16 ce ff ff       	call   f01000b6 <_panic>
	load_icode(env, binary);
f01032a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	
		struct Elf* elf = (struct Elf*) binary;
		if (elf->e_magic != ELF_MAGIC)
f01032a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a9:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01032af:	74 1c                	je     f01032cd <env_create+0x70>
			panic("e_magic is not right\n");
f01032b1:	c7 44 24 08 be 60 10 	movl   $0xf01060be,0x8(%esp)
f01032b8:	f0 
f01032b9:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01032c0:	00 
f01032c1:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f01032c8:	e8 e9 cd ff ff       	call   f01000b6 <_panic>
		//首先要更改私有地址的pgdir
		lcr3( PADDR(e->env_pgdir));		//程序头表
f01032cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032d0:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032d8:	77 20                	ja     f01032fa <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032de:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f01032e5:	f0 
f01032e6:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f01032ed:	00 
f01032ee:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f01032f5:	e8 bc cd ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032fa:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01032ff:	0f 22 d8             	mov    %eax,%cr3
		struct Proghdr *ph =0;
		struct Proghdr *phEnd =0;
		int phNum=0;
		pte_t* va=0;

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
f0103302:	8b 45 08             	mov    0x8(%ebp),%eax
f0103305:	89 c3                	mov    %eax,%ebx
f0103307:	03 58 1c             	add    0x1c(%eax),%ebx
f010330a:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f010330e:	83 c7 01             	add    $0x1,%edi
	
		int num = elf->e_phnum;
f0103311:	be 01 00 00 00       	mov    $0x1,%esi
f0103316:	eb 68                	jmp    f0103380 <env_create+0x123>
		int i=0;
		for(; i<num; i++){
			ph++;
f0103318:	83 c3 20             	add    $0x20,%ebx
			cprintf("ph%d  = %x\n", i, (unsigned int)ph);	
f010331b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010331f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103323:	c7 04 24 d4 60 10 f0 	movl   $0xf01060d4,(%esp)
f010332a:	e8 d5 03 00 00       	call   f0103704 <cprintf>
			//可载入段
			if(ph->p_type == ELF_PROG_LOAD){
f010332f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103332:	75 49                	jne    f010337d <env_create+0x120>
				region_alloc(e, (void *)ph->p_va, ph->p_memsz);	//为va申请地址。
f0103334:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103337:	8b 53 08             	mov    0x8(%ebx),%edx
f010333a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010333d:	e8 f2 fb ff ff       	call   f0102f34 <region_alloc>
				memmove((void*)ph->p_va,  (void*)(binary + ph->p_offset),  ph->p_filesz);
f0103342:	8b 43 10             	mov    0x10(%ebx),%eax
f0103345:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103349:	8b 45 08             	mov    0x8(%ebp),%eax
f010334c:	03 43 04             	add    0x4(%ebx),%eax
f010334f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103353:	8b 43 08             	mov    0x8(%ebx),%eax
f0103356:	89 04 24             	mov    %eax,(%esp)
f0103359:	e8 06 19 00 00       	call   f0104c64 <memmove>
				memset((void*) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f010335e:	8b 43 10             	mov    0x10(%ebx),%eax
f0103361:	8b 53 14             	mov    0x14(%ebx),%edx
f0103364:	29 c2                	sub    %eax,%edx
f0103366:	89 54 24 08          	mov    %edx,0x8(%esp)
f010336a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103371:	00 
f0103372:	03 43 08             	add    0x8(%ebx),%eax
f0103375:	89 04 24             	mov    %eax,(%esp)
f0103378:	e8 9a 18 00 00       	call   f0104c17 <memset>
f010337d:	83 c6 01             	add    $0x1,%esi
f0103380:	8d 46 ff             	lea    -0x1(%esi),%eax

		ph = (struct Proghdr*) ( binary + elf->e_phoff );
	
		int num = elf->e_phnum;
		int i=0;
		for(; i<num; i++){
f0103383:	39 fe                	cmp    %edi,%esi
f0103385:	75 91                	jne    f0103318 <env_create+0xbb>
	

		phEnd = ph + elf->e_phnum;


		e->env_tf.tf_eip = elf->e_entry;
f0103387:	8b 45 08             	mov    0x8(%ebp),%eax
f010338a:	8b 40 18             	mov    0x18(%eax),%eax
f010338d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103390:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
		    region_alloc(e,(void*)USTACKTOP - PGSIZE,PGSIZE);  
f0103393:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103398:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010339d:	89 f8                	mov    %edi,%eax
f010339f:	e8 90 fb ff ff       	call   f0102f34 <region_alloc>
		    lcr3(PADDR(kern_pgdir));
f01033a4:	a1 88 dd 17 f0       	mov    0xf017dd88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033ae:	77 20                	ja     f01033d0 <env_create+0x173>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033b4:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f01033bb:	f0 
f01033bc:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f01033c3:	00 
f01033c4:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f01033cb:	e8 e6 cc ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01033d0:	05 00 00 00 10       	add    $0x10000000,%eax
f01033d5:	0f 22 d8             	mov    %eax,%cr3
	struct Env* env=0;
	int r = env_alloc(&env, 0);
	if(r < 0)
		panic("env_create fault\n");
	load_icode(env, binary);
	env->env_type = type;
f01033d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033de:	89 50 50             	mov    %edx,0x50(%eax)

}
f01033e1:	83 c4 3c             	add    $0x3c,%esp
f01033e4:	5b                   	pop    %ebx
f01033e5:	5e                   	pop    %esi
f01033e6:	5f                   	pop    %edi
f01033e7:	5d                   	pop    %ebp
f01033e8:	c3                   	ret    

f01033e9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033e9:	55                   	push   %ebp
f01033ea:	89 e5                	mov    %esp,%ebp
f01033ec:	57                   	push   %edi
f01033ed:	56                   	push   %esi
f01033ee:	53                   	push   %ebx
f01033ef:	83 ec 2c             	sub    $0x2c,%esp
f01033f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033f5:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f01033fa:	39 c7                	cmp    %eax,%edi
f01033fc:	75 37                	jne    f0103435 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01033fe:	8b 15 88 dd 17 f0    	mov    0xf017dd88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103404:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010340a:	77 20                	ja     f010342c <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010340c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103410:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f0103417:	f0 
f0103418:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f010341f:	00 
f0103420:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f0103427:	e8 8a cc ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010342c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103432:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103435:	8b 57 48             	mov    0x48(%edi),%edx
f0103438:	85 c0                	test   %eax,%eax
f010343a:	74 05                	je     f0103441 <env_free+0x58>
f010343c:	8b 40 48             	mov    0x48(%eax),%eax
f010343f:	eb 05                	jmp    f0103446 <env_free+0x5d>
f0103441:	b8 00 00 00 00       	mov    $0x0,%eax
f0103446:	89 54 24 08          	mov    %edx,0x8(%esp)
f010344a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010344e:	c7 04 24 e0 60 10 f0 	movl   $0xf01060e0,(%esp)
f0103455:	e8 aa 02 00 00       	call   f0103704 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010345a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103464:	89 c8                	mov    %ecx,%eax
f0103466:	c1 e0 02             	shl    $0x2,%eax
f0103469:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010346c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010346f:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103472:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103478:	0f 84 b7 00 00 00    	je     f0103535 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010347e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103484:	89 f0                	mov    %esi,%eax
f0103486:	c1 e8 0c             	shr    $0xc,%eax
f0103489:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010348c:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f0103492:	72 20                	jb     f01034b4 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103494:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103498:	c7 44 24 08 5c 55 10 	movl   $0xf010555c,0x8(%esp)
f010349f:	f0 
f01034a0:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f01034a7:	00 
f01034a8:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f01034af:	e8 02 cc ff ff       	call   f01000b6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b7:	c1 e0 16             	shl    $0x16,%eax
f01034ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034bd:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034c2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034c9:	01 
f01034ca:	74 17                	je     f01034e3 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034cc:	89 d8                	mov    %ebx,%eax
f01034ce:	c1 e0 0c             	shl    $0xc,%eax
f01034d1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034d8:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034db:	89 04 24             	mov    %eax,(%esp)
f01034de:	e8 5a db ff ff       	call   f010103d <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034e3:	83 c3 01             	add    $0x1,%ebx
f01034e6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034ec:	75 d4                	jne    f01034c2 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034ee:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034f4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034fe:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f0103504:	72 1c                	jb     f0103522 <env_free+0x139>
		panic("pa2page called with invalid pa");
f0103506:	c7 44 24 08 44 56 10 	movl   $0xf0105644,0x8(%esp)
f010350d:	f0 
f010350e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103515:	00 
f0103516:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f010351d:	e8 94 cb ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103522:	a1 8c dd 17 f0       	mov    0xf017dd8c,%eax
f0103527:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010352a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f010352d:	89 04 24             	mov    %eax,(%esp)
f0103530:	e8 6f d9 ff ff       	call   f0100ea4 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103535:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103539:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103540:	0f 85 1b ff ff ff    	jne    f0103461 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103546:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103549:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010354e:	77 20                	ja     f0103570 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103550:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103554:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f010355b:	f0 
f010355c:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
f0103563:	00 
f0103564:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f010356b:	e8 46 cb ff ff       	call   f01000b6 <_panic>
	e->env_pgdir = 0;
f0103570:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103577:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010357c:	c1 e8 0c             	shr    $0xc,%eax
f010357f:	3b 05 84 dd 17 f0    	cmp    0xf017dd84,%eax
f0103585:	72 1c                	jb     f01035a3 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103587:	c7 44 24 08 44 56 10 	movl   $0xf0105644,0x8(%esp)
f010358e:	f0 
f010358f:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103596:	00 
f0103597:	c7 04 24 19 5d 10 f0 	movl   $0xf0105d19,(%esp)
f010359e:	e8 13 cb ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f01035a3:	8b 15 8c dd 17 f0    	mov    0xf017dd8c,%edx
f01035a9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f01035ac:	89 04 24             	mov    %eax,(%esp)
f01035af:	e8 f0 d8 ff ff       	call   f0100ea4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035b4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035bb:	a1 d0 d0 17 f0       	mov    0xf017d0d0,%eax
f01035c0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035c3:	89 3d d0 d0 17 f0    	mov    %edi,0xf017d0d0
}
f01035c9:	83 c4 2c             	add    $0x2c,%esp
f01035cc:	5b                   	pop    %ebx
f01035cd:	5e                   	pop    %esi
f01035ce:	5f                   	pop    %edi
f01035cf:	5d                   	pop    %ebp
f01035d0:	c3                   	ret    

f01035d1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01035d1:	55                   	push   %ebp
f01035d2:	89 e5                	mov    %esp,%ebp
f01035d4:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01035d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01035da:	89 04 24             	mov    %eax,(%esp)
f01035dd:	e8 07 fe ff ff       	call   f01033e9 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01035e2:	c7 04 24 44 60 10 f0 	movl   $0xf0106044,(%esp)
f01035e9:	e8 16 01 00 00       	call   f0103704 <cprintf>
	while (1)
		monitor(NULL);
f01035ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035f5:	e8 5f d1 ff ff       	call   f0100759 <monitor>
f01035fa:	eb f2                	jmp    f01035ee <env_destroy+0x1d>

f01035fc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
f01035ff:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103602:	8b 65 08             	mov    0x8(%ebp),%esp
f0103605:	61                   	popa   
f0103606:	07                   	pop    %es
f0103607:	1f                   	pop    %ds
f0103608:	83 c4 08             	add    $0x8,%esp
f010360b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010360c:	c7 44 24 08 f6 60 10 	movl   $0xf01060f6,0x8(%esp)
f0103613:	f0 
f0103614:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
f010361b:	00 
f010361c:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f0103623:	e8 8e ca ff ff       	call   f01000b6 <_panic>

f0103628 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103628:	55                   	push   %ebp
f0103629:	89 e5                	mov    %esp,%ebp
f010362b:	83 ec 18             	sub    $0x18,%esp
f010362e:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv == 0)
f0103631:	8b 15 c8 d0 17 f0    	mov    0xf017d0c8,%edx
f0103637:	85 d2                	test   %edx,%edx
f0103639:	74 0d                	je     f0103648 <env_run+0x20>
		curenv = e;
	else if(curenv->env_status == ENV_RUNNING)
f010363b:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010363f:	75 07                	jne    f0103648 <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0103641:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	curenv = e;
f0103648:	a3 c8 d0 17 f0       	mov    %eax,0xf017d0c8
	curenv->env_status = ENV_RUNNING;
f010364d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103654:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3( PADDR(curenv->env_pgdir) );
f0103658:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010365b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103661:	77 20                	ja     f0103683 <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103663:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103667:	c7 44 24 08 a0 56 10 	movl   $0xf01056a0,0x8(%esp)
f010366e:	f0 
f010366f:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
f0103676:	00 
f0103677:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f010367e:	e8 33 ca ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103683:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103689:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(& (curenv->env_tf) );
f010368c:	89 04 24             	mov    %eax,(%esp)
f010368f:	e8 68 ff ff ff       	call   f01035fc <env_pop_tf>

f0103694 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103694:	55                   	push   %ebp
f0103695:	89 e5                	mov    %esp,%ebp
f0103697:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010369b:	ba 70 00 00 00       	mov    $0x70,%edx
f01036a0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036a1:	b2 71                	mov    $0x71,%dl
f01036a3:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036a4:	0f b6 c0             	movzbl %al,%eax
}
f01036a7:	5d                   	pop    %ebp
f01036a8:	c3                   	ret    

f01036a9 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036a9:	55                   	push   %ebp
f01036aa:	89 e5                	mov    %esp,%ebp
f01036ac:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036b0:	ba 70 00 00 00       	mov    $0x70,%edx
f01036b5:	ee                   	out    %al,(%dx)
f01036b6:	b2 71                	mov    $0x71,%dl
f01036b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036bb:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036bc:	5d                   	pop    %ebp
f01036bd:	c3                   	ret    

f01036be <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036be:	55                   	push   %ebp
f01036bf:	89 e5                	mov    %esp,%ebp
f01036c1:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01036c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c7:	89 04 24             	mov    %eax,(%esp)
f01036ca:	e8 42 cf ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f01036cf:	c9                   	leave  
f01036d0:	c3                   	ret    

f01036d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036d1:	55                   	push   %ebp
f01036d2:	89 e5                	mov    %esp,%ebp
f01036d4:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01036d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036f3:	c7 04 24 be 36 10 f0 	movl   $0xf01036be,(%esp)
f01036fa:	e8 d5 0d 00 00       	call   f01044d4 <vprintfmt>
	return cnt;
}
f01036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103702:	c9                   	leave  
f0103703:	c3                   	ret    

f0103704 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103704:	55                   	push   %ebp
f0103705:	89 e5                	mov    %esp,%ebp
f0103707:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010370a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010370d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103711:	8b 45 08             	mov    0x8(%ebp),%eax
f0103714:	89 04 24             	mov    %eax,(%esp)
f0103717:	e8 b5 ff ff ff       	call   f01036d1 <vcprintf>
	va_end(ap);

	return cnt;
}
f010371c:	c9                   	leave  
f010371d:	c3                   	ret    
f010371e:	66 90                	xchg   %ax,%ax

f0103720 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103723:	c7 05 04 d9 17 f0 00 	movl   $0xf0000000,0xf017d904
f010372a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010372d:	66 c7 05 08 d9 17 f0 	movw   $0x10,0xf017d908
f0103734:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103736:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f010373d:	67 00 
f010373f:	b8 00 d9 17 f0       	mov    $0xf017d900,%eax
f0103744:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f010374a:	89 c2                	mov    %eax,%edx
f010374c:	c1 ea 10             	shr    $0x10,%edx
f010374f:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103755:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010375c:	c1 e8 18             	shr    $0x18,%eax
f010375f:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103764:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010376b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103770:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103773:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103778:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010377b:	5d                   	pop    %ebp
f010377c:	c3                   	ret    

f010377d <trap_init>:
}


void
trap_init(void)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
	void alignment_check1();
	void machine_check1();
	void SIMD_float_point_error1();
	void system_call1();

	SETGATE(idt[T_DIVIDE],0,GD_KT,  divide_error1, 0);
f0103780:	b8 04 3f 10 f0       	mov    $0xf0103f04,%eax
f0103785:	66 a3 e0 d0 17 f0    	mov    %ax,0xf017d0e0
f010378b:	66 c7 05 e2 d0 17 f0 	movw   $0x8,0xf017d0e2
f0103792:	08 00 
f0103794:	c6 05 e4 d0 17 f0 00 	movb   $0x0,0xf017d0e4
f010379b:	c6 05 e5 d0 17 f0 8e 	movb   $0x8e,0xf017d0e5
f01037a2:	c1 e8 10             	shr    $0x10,%eax
f01037a5:	66 a3 e6 d0 17 f0    	mov    %ax,0xf017d0e6
	SETGATE(idt[T_DEBUG],0,GD_KT,  debug1, 0);
f01037ab:	b8 0e 3f 10 f0       	mov    $0xf0103f0e,%eax
f01037b0:	66 a3 e8 d0 17 f0    	mov    %ax,0xf017d0e8
f01037b6:	66 c7 05 ea d0 17 f0 	movw   $0x8,0xf017d0ea
f01037bd:	08 00 
f01037bf:	c6 05 ec d0 17 f0 00 	movb   $0x0,0xf017d0ec
f01037c6:	c6 05 ed d0 17 f0 8e 	movb   $0x8e,0xf017d0ed
f01037cd:	c1 e8 10             	shr    $0x10,%eax
f01037d0:	66 a3 ee d0 17 f0    	mov    %ax,0xf017d0ee
	SETGATE(idt[T_NMI],0,GD_KT,  nmi1, 0);
f01037d6:	b8 18 3f 10 f0       	mov    $0xf0103f18,%eax
f01037db:	66 a3 f0 d0 17 f0    	mov    %ax,0xf017d0f0
f01037e1:	66 c7 05 f2 d0 17 f0 	movw   $0x8,0xf017d0f2
f01037e8:	08 00 
f01037ea:	c6 05 f4 d0 17 f0 00 	movb   $0x0,0xf017d0f4
f01037f1:	c6 05 f5 d0 17 f0 8e 	movb   $0x8e,0xf017d0f5
f01037f8:	c1 e8 10             	shr    $0x10,%eax
f01037fb:	66 a3 f6 d0 17 f0    	mov    %ax,0xf017d0f6
   	SETGATE(idt[T_BRKPT],0,GD_KT,  breakpoint1,3);
f0103801:	b8 22 3f 10 f0       	mov    $0xf0103f22,%eax
f0103806:	66 a3 f8 d0 17 f0    	mov    %ax,0xf017d0f8
f010380c:	66 c7 05 fa d0 17 f0 	movw   $0x8,0xf017d0fa
f0103813:	08 00 
f0103815:	c6 05 fc d0 17 f0 00 	movb   $0x0,0xf017d0fc
f010381c:	c6 05 fd d0 17 f0 ee 	movb   $0xee,0xf017d0fd
f0103823:	c1 e8 10             	shr    $0x10,%eax
f0103826:	66 a3 fe d0 17 f0    	mov    %ax,0xf017d0fe
	SETGATE(idt[T_OFLOW],0,GD_KT,  overflow1, 0);
f010382c:	b8 2c 3f 10 f0       	mov    $0xf0103f2c,%eax
f0103831:	66 a3 00 d1 17 f0    	mov    %ax,0xf017d100
f0103837:	66 c7 05 02 d1 17 f0 	movw   $0x8,0xf017d102
f010383e:	08 00 
f0103840:	c6 05 04 d1 17 f0 00 	movb   $0x0,0xf017d104
f0103847:	c6 05 05 d1 17 f0 8e 	movb   $0x8e,0xf017d105
f010384e:	c1 e8 10             	shr    $0x10,%eax
f0103851:	66 a3 06 d1 17 f0    	mov    %ax,0xf017d106
	SETGATE(idt[T_BOUND],0,GD_KT,  bounds1, 0);
f0103857:	b8 36 3f 10 f0       	mov    $0xf0103f36,%eax
f010385c:	66 a3 08 d1 17 f0    	mov    %ax,0xf017d108
f0103862:	66 c7 05 0a d1 17 f0 	movw   $0x8,0xf017d10a
f0103869:	08 00 
f010386b:	c6 05 0c d1 17 f0 00 	movb   $0x0,0xf017d10c
f0103872:	c6 05 0d d1 17 f0 8e 	movb   $0x8e,0xf017d10d
f0103879:	c1 e8 10             	shr    $0x10,%eax
f010387c:	66 a3 0e d1 17 f0    	mov    %ax,0xf017d10e
	SETGATE(idt[T_ILLOP],0,GD_KT,  invalid_op1, 0);
f0103882:	b8 40 3f 10 f0       	mov    $0xf0103f40,%eax
f0103887:	66 a3 10 d1 17 f0    	mov    %ax,0xf017d110
f010388d:	66 c7 05 12 d1 17 f0 	movw   $0x8,0xf017d112
f0103894:	08 00 
f0103896:	c6 05 14 d1 17 f0 00 	movb   $0x0,0xf017d114
f010389d:	c6 05 15 d1 17 f0 8e 	movb   $0x8e,0xf017d115
f01038a4:	c1 e8 10             	shr    $0x10,%eax
f01038a7:	66 a3 16 d1 17 f0    	mov    %ax,0xf017d116
	SETGATE(idt[T_DEVICE],0,GD_KT,  device_not_available1, 0);
f01038ad:	b8 4a 3f 10 f0       	mov    $0xf0103f4a,%eax
f01038b2:	66 a3 18 d1 17 f0    	mov    %ax,0xf017d118
f01038b8:	66 c7 05 1a d1 17 f0 	movw   $0x8,0xf017d11a
f01038bf:	08 00 
f01038c1:	c6 05 1c d1 17 f0 00 	movb   $0x0,0xf017d11c
f01038c8:	c6 05 1d d1 17 f0 8e 	movb   $0x8e,0xf017d11d
f01038cf:	c1 e8 10             	shr    $0x10,%eax
f01038d2:	66 a3 1e d1 17 f0    	mov    %ax,0xf017d11e
	SETGATE(idt[T_DBLFLT],0,GD_KT,  double_fault1, 0);
f01038d8:	b8 54 3f 10 f0       	mov    $0xf0103f54,%eax
f01038dd:	66 a3 20 d1 17 f0    	mov    %ax,0xf017d120
f01038e3:	66 c7 05 22 d1 17 f0 	movw   $0x8,0xf017d122
f01038ea:	08 00 
f01038ec:	c6 05 24 d1 17 f0 00 	movb   $0x0,0xf017d124
f01038f3:	c6 05 25 d1 17 f0 8e 	movb   $0x8e,0xf017d125
f01038fa:	c1 e8 10             	shr    $0x10,%eax
f01038fd:	66 a3 26 d1 17 f0    	mov    %ax,0xf017d126
	SETGATE(idt[T_TSS],0,GD_KT,  invalid_TSS1, 0);
f0103903:	b8 5c 3f 10 f0       	mov    $0xf0103f5c,%eax
f0103908:	66 a3 30 d1 17 f0    	mov    %ax,0xf017d130
f010390e:	66 c7 05 32 d1 17 f0 	movw   $0x8,0xf017d132
f0103915:	08 00 
f0103917:	c6 05 34 d1 17 f0 00 	movb   $0x0,0xf017d134
f010391e:	c6 05 35 d1 17 f0 8e 	movb   $0x8e,0xf017d135
f0103925:	c1 e8 10             	shr    $0x10,%eax
f0103928:	66 a3 36 d1 17 f0    	mov    %ax,0xf017d136
	SETGATE(idt[T_SEGNP],0,GD_KT,  segment_not_present1, 0);
f010392e:	b8 64 3f 10 f0       	mov    $0xf0103f64,%eax
f0103933:	66 a3 38 d1 17 f0    	mov    %ax,0xf017d138
f0103939:	66 c7 05 3a d1 17 f0 	movw   $0x8,0xf017d13a
f0103940:	08 00 
f0103942:	c6 05 3c d1 17 f0 00 	movb   $0x0,0xf017d13c
f0103949:	c6 05 3d d1 17 f0 8e 	movb   $0x8e,0xf017d13d
f0103950:	c1 e8 10             	shr    $0x10,%eax
f0103953:	66 a3 3e d1 17 f0    	mov    %ax,0xf017d13e
	SETGATE(idt[T_STACK],0,GD_KT,  stack_segment1, 0);
f0103959:	b8 6c 3f 10 f0       	mov    $0xf0103f6c,%eax
f010395e:	66 a3 40 d1 17 f0    	mov    %ax,0xf017d140
f0103964:	66 c7 05 42 d1 17 f0 	movw   $0x8,0xf017d142
f010396b:	08 00 
f010396d:	c6 05 44 d1 17 f0 00 	movb   $0x0,0xf017d144
f0103974:	c6 05 45 d1 17 f0 8e 	movb   $0x8e,0xf017d145
f010397b:	c1 e8 10             	shr    $0x10,%eax
f010397e:	66 a3 46 d1 17 f0    	mov    %ax,0xf017d146
	SETGATE(idt[T_GPFLT],0,GD_KT,  general_protection1, 0);
f0103984:	b8 74 3f 10 f0       	mov    $0xf0103f74,%eax
f0103989:	66 a3 48 d1 17 f0    	mov    %ax,0xf017d148
f010398f:	66 c7 05 4a d1 17 f0 	movw   $0x8,0xf017d14a
f0103996:	08 00 
f0103998:	c6 05 4c d1 17 f0 00 	movb   $0x0,0xf017d14c
f010399f:	c6 05 4d d1 17 f0 8e 	movb   $0x8e,0xf017d14d
f01039a6:	c1 e8 10             	shr    $0x10,%eax
f01039a9:	66 a3 4e d1 17 f0    	mov    %ax,0xf017d14e
	SETGATE(idt[T_PGFLT],0,GD_KT,  page_fault1, 0);
f01039af:	b8 7c 3f 10 f0       	mov    $0xf0103f7c,%eax
f01039b4:	66 a3 50 d1 17 f0    	mov    %ax,0xf017d150
f01039ba:	66 c7 05 52 d1 17 f0 	movw   $0x8,0xf017d152
f01039c1:	08 00 
f01039c3:	c6 05 54 d1 17 f0 00 	movb   $0x0,0xf017d154
f01039ca:	c6 05 55 d1 17 f0 8e 	movb   $0x8e,0xf017d155
f01039d1:	c1 e8 10             	shr    $0x10,%eax
f01039d4:	66 a3 56 d1 17 f0    	mov    %ax,0xf017d156
	SETGATE(idt[T_FPERR],0,GD_KT,  float_point_error1, 0);
f01039da:	b8 84 3f 10 f0       	mov    $0xf0103f84,%eax
f01039df:	66 a3 60 d1 17 f0    	mov    %ax,0xf017d160
f01039e5:	66 c7 05 62 d1 17 f0 	movw   $0x8,0xf017d162
f01039ec:	08 00 
f01039ee:	c6 05 64 d1 17 f0 00 	movb   $0x0,0xf017d164
f01039f5:	c6 05 65 d1 17 f0 8e 	movb   $0x8e,0xf017d165
f01039fc:	c1 e8 10             	shr    $0x10,%eax
f01039ff:	66 a3 66 d1 17 f0    	mov    %ax,0xf017d166
	SETGATE(idt[T_ALIGN],0,GD_KT,  alignment_check1, 0);
f0103a05:	b8 8e 3f 10 f0       	mov    $0xf0103f8e,%eax
f0103a0a:	66 a3 68 d1 17 f0    	mov    %ax,0xf017d168
f0103a10:	66 c7 05 6a d1 17 f0 	movw   $0x8,0xf017d16a
f0103a17:	08 00 
f0103a19:	c6 05 6c d1 17 f0 00 	movb   $0x0,0xf017d16c
f0103a20:	c6 05 6d d1 17 f0 8e 	movb   $0x8e,0xf017d16d
f0103a27:	c1 e8 10             	shr    $0x10,%eax
f0103a2a:	66 a3 6e d1 17 f0    	mov    %ax,0xf017d16e
	SETGATE(idt[T_MCHK],0,GD_KT,  machine_check1, 0);
f0103a30:	b8 96 3f 10 f0       	mov    $0xf0103f96,%eax
f0103a35:	66 a3 70 d1 17 f0    	mov    %ax,0xf017d170
f0103a3b:	66 c7 05 72 d1 17 f0 	movw   $0x8,0xf017d172
f0103a42:	08 00 
f0103a44:	c6 05 74 d1 17 f0 00 	movb   $0x0,0xf017d174
f0103a4b:	c6 05 75 d1 17 f0 8e 	movb   $0x8e,0xf017d175
f0103a52:	c1 e8 10             	shr    $0x10,%eax
f0103a55:	66 a3 76 d1 17 f0    	mov    %ax,0xf017d176
	SETGATE(idt[T_SIMDERR],0,GD_KT,  SIMD_float_point_error1, 0);
f0103a5b:	b8 a0 3f 10 f0       	mov    $0xf0103fa0,%eax
f0103a60:	66 a3 78 d1 17 f0    	mov    %ax,0xf017d178
f0103a66:	66 c7 05 7a d1 17 f0 	movw   $0x8,0xf017d17a
f0103a6d:	08 00 
f0103a6f:	c6 05 7c d1 17 f0 00 	movb   $0x0,0xf017d17c
f0103a76:	c6 05 7d d1 17 f0 8e 	movb   $0x8e,0xf017d17d
f0103a7d:	c1 e8 10             	shr    $0x10,%eax
f0103a80:	66 a3 7e d1 17 f0    	mov    %ax,0xf017d17e
	SETGATE(idt[T_SYSCALL],0,GD_KT,  system_call1,3);
f0103a86:	b8 aa 3f 10 f0       	mov    $0xf0103faa,%eax
f0103a8b:	66 a3 60 d2 17 f0    	mov    %ax,0xf017d260
f0103a91:	66 c7 05 62 d2 17 f0 	movw   $0x8,0xf017d262
f0103a98:	08 00 
f0103a9a:	c6 05 64 d2 17 f0 00 	movb   $0x0,0xf017d264
f0103aa1:	c6 05 65 d2 17 f0 ee 	movb   $0xee,0xf017d265
f0103aa8:	c1 e8 10             	shr    $0x10,%eax
f0103aab:	66 a3 66 d2 17 f0    	mov    %ax,0xf017d266




	ts.ts_esp0 = KSTACKTOP;
f0103ab1:	c7 05 04 d9 17 f0 00 	movl   $0xf0000000,0xf017d904
f0103ab8:	00 00 f0 
	ts.ts_ss0 =GD_KD;
f0103abb:	66 c7 05 08 d9 17 f0 	movw   $0x10,0xf017d908
f0103ac2:	10 00 
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103ac4:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0103acb:	67 00 
f0103acd:	b8 00 d9 17 f0       	mov    $0xf017d900,%eax
f0103ad2:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103ad8:	89 c2                	mov    %eax,%edx
f0103ada:	c1 ea 10             	shr    $0x10,%edx
f0103add:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103ae3:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0103aea:	c1 e8 18             	shr    $0x18,%eax
f0103aed:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);

	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103af2:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103af9:	b8 28 00 00 00       	mov    $0x28,%eax
f0103afe:	0f 00 d8             	ltr    %ax
	ltr(GD_TSS0);

	// Per-CPU setup 
	trap_init_percpu();
f0103b01:	e8 1a fc ff ff       	call   f0103720 <trap_init_percpu>
}
f0103b06:	5d                   	pop    %ebp
f0103b07:	c3                   	ret    

f0103b08 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103b08:	55                   	push   %ebp
f0103b09:	89 e5                	mov    %esp,%ebp
f0103b0b:	53                   	push   %ebx
f0103b0c:	83 ec 14             	sub    $0x14,%esp
f0103b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103b12:	8b 03                	mov    (%ebx),%eax
f0103b14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b18:	c7 04 24 02 61 10 f0 	movl   $0xf0106102,(%esp)
f0103b1f:	e8 e0 fb ff ff       	call   f0103704 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103b24:	8b 43 04             	mov    0x4(%ebx),%eax
f0103b27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2b:	c7 04 24 11 61 10 f0 	movl   $0xf0106111,(%esp)
f0103b32:	e8 cd fb ff ff       	call   f0103704 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103b37:	8b 43 08             	mov    0x8(%ebx),%eax
f0103b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b3e:	c7 04 24 20 61 10 f0 	movl   $0xf0106120,(%esp)
f0103b45:	e8 ba fb ff ff       	call   f0103704 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103b4a:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b51:	c7 04 24 2f 61 10 f0 	movl   $0xf010612f,(%esp)
f0103b58:	e8 a7 fb ff ff       	call   f0103704 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b5d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b64:	c7 04 24 3e 61 10 f0 	movl   $0xf010613e,(%esp)
f0103b6b:	e8 94 fb ff ff       	call   f0103704 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103b70:	8b 43 14             	mov    0x14(%ebx),%eax
f0103b73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b77:	c7 04 24 4d 61 10 f0 	movl   $0xf010614d,(%esp)
f0103b7e:	e8 81 fb ff ff       	call   f0103704 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b83:	8b 43 18             	mov    0x18(%ebx),%eax
f0103b86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b8a:	c7 04 24 5c 61 10 f0 	movl   $0xf010615c,(%esp)
f0103b91:	e8 6e fb ff ff       	call   f0103704 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b96:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103b99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b9d:	c7 04 24 6b 61 10 f0 	movl   $0xf010616b,(%esp)
f0103ba4:	e8 5b fb ff ff       	call   f0103704 <cprintf>
}
f0103ba9:	83 c4 14             	add    $0x14,%esp
f0103bac:	5b                   	pop    %ebx
f0103bad:	5d                   	pop    %ebp
f0103bae:	c3                   	ret    

f0103baf <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103baf:	55                   	push   %ebp
f0103bb0:	89 e5                	mov    %esp,%ebp
f0103bb2:	56                   	push   %esi
f0103bb3:	53                   	push   %ebx
f0103bb4:	83 ec 10             	sub    $0x10,%esp
f0103bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103bba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bbe:	c7 04 24 a1 62 10 f0 	movl   $0xf01062a1,(%esp)
f0103bc5:	e8 3a fb ff ff       	call   f0103704 <cprintf>
	print_regs(&tf->tf_regs);
f0103bca:	89 1c 24             	mov    %ebx,(%esp)
f0103bcd:	e8 36 ff ff ff       	call   f0103b08 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103bd2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bda:	c7 04 24 bc 61 10 f0 	movl   $0xf01061bc,(%esp)
f0103be1:	e8 1e fb ff ff       	call   f0103704 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103be6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103bea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bee:	c7 04 24 cf 61 10 f0 	movl   $0xf01061cf,(%esp)
f0103bf5:	e8 0a fb ff ff       	call   f0103704 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103bfa:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103bfd:	83 f8 13             	cmp    $0x13,%eax
f0103c00:	77 09                	ja     f0103c0b <print_trapframe+0x5c>
		return excnames[trapno];
f0103c02:	8b 14 85 a0 64 10 f0 	mov    -0xfef9b60(,%eax,4),%edx
f0103c09:	eb 10                	jmp    f0103c1b <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103c0b:	83 f8 30             	cmp    $0x30,%eax
f0103c0e:	ba 7a 61 10 f0       	mov    $0xf010617a,%edx
f0103c13:	b9 86 61 10 f0       	mov    $0xf0106186,%ecx
f0103c18:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c23:	c7 04 24 e2 61 10 f0 	movl   $0xf01061e2,(%esp)
f0103c2a:	e8 d5 fa ff ff       	call   f0103704 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c2f:	3b 1d e0 d8 17 f0    	cmp    0xf017d8e0,%ebx
f0103c35:	75 19                	jne    f0103c50 <print_trapframe+0xa1>
f0103c37:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c3b:	75 13                	jne    f0103c50 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103c3d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103c40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c44:	c7 04 24 f4 61 10 f0 	movl   $0xf01061f4,(%esp)
f0103c4b:	e8 b4 fa ff ff       	call   f0103704 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103c50:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103c53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c57:	c7 04 24 03 62 10 f0 	movl   $0xf0106203,(%esp)
f0103c5e:	e8 a1 fa ff ff       	call   f0103704 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103c63:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c67:	75 51                	jne    f0103cba <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103c69:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103c6c:	89 c2                	mov    %eax,%edx
f0103c6e:	83 e2 01             	and    $0x1,%edx
f0103c71:	ba 95 61 10 f0       	mov    $0xf0106195,%edx
f0103c76:	b9 a0 61 10 f0       	mov    $0xf01061a0,%ecx
f0103c7b:	0f 45 ca             	cmovne %edx,%ecx
f0103c7e:	89 c2                	mov    %eax,%edx
f0103c80:	83 e2 02             	and    $0x2,%edx
f0103c83:	ba ac 61 10 f0       	mov    $0xf01061ac,%edx
f0103c88:	be b2 61 10 f0       	mov    $0xf01061b2,%esi
f0103c8d:	0f 44 d6             	cmove  %esi,%edx
f0103c90:	83 e0 04             	and    $0x4,%eax
f0103c93:	b8 b7 61 10 f0       	mov    $0xf01061b7,%eax
f0103c98:	be cc 62 10 f0       	mov    $0xf01062cc,%esi
f0103c9d:	0f 44 c6             	cmove  %esi,%eax
f0103ca0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103ca4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cac:	c7 04 24 11 62 10 f0 	movl   $0xf0106211,(%esp)
f0103cb3:	e8 4c fa ff ff       	call   f0103704 <cprintf>
f0103cb8:	eb 0c                	jmp    f0103cc6 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103cba:	c7 04 24 e1 5f 10 f0 	movl   $0xf0105fe1,(%esp)
f0103cc1:	e8 3e fa ff ff       	call   f0103704 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103cc6:	8b 43 30             	mov    0x30(%ebx),%eax
f0103cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ccd:	c7 04 24 20 62 10 f0 	movl   $0xf0106220,(%esp)
f0103cd4:	e8 2b fa ff ff       	call   f0103704 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103cd9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ce1:	c7 04 24 2f 62 10 f0 	movl   $0xf010622f,(%esp)
f0103ce8:	e8 17 fa ff ff       	call   f0103704 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ced:	8b 43 38             	mov    0x38(%ebx),%eax
f0103cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf4:	c7 04 24 42 62 10 f0 	movl   $0xf0106242,(%esp)
f0103cfb:	e8 04 fa ff ff       	call   f0103704 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103d00:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103d04:	74 27                	je     f0103d2d <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d06:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d0d:	c7 04 24 51 62 10 f0 	movl   $0xf0106251,(%esp)
f0103d14:	e8 eb f9 ff ff       	call   f0103704 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d19:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d21:	c7 04 24 60 62 10 f0 	movl   $0xf0106260,(%esp)
f0103d28:	e8 d7 f9 ff ff       	call   f0103704 <cprintf>
	}
}
f0103d2d:	83 c4 10             	add    $0x10,%esp
f0103d30:	5b                   	pop    %ebx
f0103d31:	5e                   	pop    %esi
f0103d32:	5d                   	pop    %ebp
f0103d33:	c3                   	ret    

f0103d34 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d34:	55                   	push   %ebp
f0103d35:	89 e5                	mov    %esp,%ebp
f0103d37:	53                   	push   %ebx
f0103d38:	83 ec 14             	sub    $0x14,%esp
f0103d3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103d3e:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT)
f0103d41:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103d46:	75 1c                	jne    f0103d64 <page_fault_handler+0x30>
		panic("page fault happens in the kern mode");
f0103d48:	c7 44 24 08 18 64 10 	movl   $0xf0106418,0x8(%esp)
f0103d4f:	f0 
f0103d50:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f0103d57:	00 
f0103d58:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0103d5f:	e8 52 c3 ff ff       	call   f01000b6 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d64:	8b 53 30             	mov    0x30(%ebx),%edx
f0103d67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d6f:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103d74:	8b 40 48             	mov    0x48(%eax),%eax
f0103d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d7b:	c7 04 24 3c 64 10 f0 	movl   $0xf010643c,(%esp)
f0103d82:	e8 7d f9 ff ff       	call   f0103704 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103d87:	89 1c 24             	mov    %ebx,(%esp)
f0103d8a:	e8 20 fe ff ff       	call   f0103baf <print_trapframe>
	env_destroy(curenv);
f0103d8f:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103d94:	89 04 24             	mov    %eax,(%esp)
f0103d97:	e8 35 f8 ff ff       	call   f01035d1 <env_destroy>
}
f0103d9c:	83 c4 14             	add    $0x14,%esp
f0103d9f:	5b                   	pop    %ebx
f0103da0:	5d                   	pop    %ebp
f0103da1:	c3                   	ret    

f0103da2 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103da2:	55                   	push   %ebp
f0103da3:	89 e5                	mov    %esp,%ebp
f0103da5:	57                   	push   %edi
f0103da6:	56                   	push   %esi
f0103da7:	83 ec 20             	sub    $0x20,%esp
f0103daa:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103dad:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103dae:	9c                   	pushf  
f0103daf:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103db0:	f6 c4 02             	test   $0x2,%ah
f0103db3:	74 24                	je     f0103dd9 <trap+0x37>
f0103db5:	c7 44 24 0c 7f 62 10 	movl   $0xf010627f,0xc(%esp)
f0103dbc:	f0 
f0103dbd:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0103dc4:	f0 
f0103dc5:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0103dcc:	00 
f0103dcd:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0103dd4:	e8 dd c2 ff ff       	call   f01000b6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103dd9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103ddd:	c7 04 24 98 62 10 f0 	movl   $0xf0106298,(%esp)
f0103de4:	e8 1b f9 ff ff       	call   f0103704 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103de9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103ded:	83 e0 03             	and    $0x3,%eax
f0103df0:	66 83 f8 03          	cmp    $0x3,%ax
f0103df4:	75 3c                	jne    f0103e32 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f0103df6:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103dfb:	85 c0                	test   %eax,%eax
f0103dfd:	75 24                	jne    f0103e23 <trap+0x81>
f0103dff:	c7 44 24 0c b3 62 10 	movl   $0xf01062b3,0xc(%esp)
f0103e06:	f0 
f0103e07:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0103e0e:	f0 
f0103e0f:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0103e16:	00 
f0103e17:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0103e1e:	e8 93 c2 ff ff       	call   f01000b6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103e23:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103e28:	89 c7                	mov    %eax,%edi
f0103e2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103e2c:	8b 35 c8 d0 17 f0    	mov    0xf017d0c8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103e32:	89 35 e0 d8 17 f0    	mov    %esi,0xf017d8e0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f0103e38:	8b 46 28             	mov    0x28(%esi),%eax
f0103e3b:	83 f8 0e             	cmp    $0xe,%eax
f0103e3e:	75 0a                	jne    f0103e4a <trap+0xa8>
		page_fault_handler(tf);
f0103e40:	89 34 24             	mov    %esi,(%esp)
f0103e43:	e8 ec fe ff ff       	call   f0103d34 <page_fault_handler>
f0103e48:	eb 7e                	jmp    f0103ec8 <trap+0x126>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f0103e4a:	83 f8 03             	cmp    $0x3,%eax
f0103e4d:	75 0a                	jne    f0103e59 <trap+0xb7>
		monitor(tf);
f0103e4f:	89 34 24             	mov    %esi,(%esp)
f0103e52:	e8 02 c9 ff ff       	call   f0100759 <monitor>
f0103e57:	eb 6f                	jmp    f0103ec8 <trap+0x126>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f0103e59:	83 f8 30             	cmp    $0x30,%eax
f0103e5c:	75 32                	jne    f0103e90 <trap+0xee>
		tf->tf_regs.reg_eax= syscall(tf->tf_regs.reg_eax, 
f0103e5e:	8b 46 04             	mov    0x4(%esi),%eax
f0103e61:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103e65:	8b 06                	mov    (%esi),%eax
f0103e67:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103e6b:	8b 46 10             	mov    0x10(%esi),%eax
f0103e6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e72:	8b 46 18             	mov    0x18(%esi),%eax
f0103e75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e79:	8b 46 14             	mov    0x14(%esi),%eax
f0103e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e80:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103e83:	89 04 24             	mov    %eax,(%esp)
f0103e86:	e8 45 01 00 00       	call   f0103fd0 <syscall>
f0103e8b:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e8e:	eb 38                	jmp    f0103ec8 <trap+0x126>
                            				tf->tf_regs.reg_edi,
                            				tf->tf_regs.reg_esi);
                            return;	
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103e90:	89 34 24             	mov    %esi,(%esp)
f0103e93:	e8 17 fd ff ff       	call   f0103baf <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103e98:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103e9d:	75 1c                	jne    f0103ebb <trap+0x119>
		panic("unhandled trap in kernel");
f0103e9f:	c7 44 24 08 ba 62 10 	movl   $0xf01062ba,0x8(%esp)
f0103ea6:	f0 
f0103ea7:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f0103eae:	00 
f0103eaf:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0103eb6:	e8 fb c1 ff ff       	call   f01000b6 <_panic>
	else {
		env_destroy(curenv);
f0103ebb:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103ec0:	89 04 24             	mov    %eax,(%esp)
f0103ec3:	e8 09 f7 ff ff       	call   f01035d1 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103ec8:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0103ecd:	85 c0                	test   %eax,%eax
f0103ecf:	74 06                	je     f0103ed7 <trap+0x135>
f0103ed1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103ed5:	74 24                	je     f0103efb <trap+0x159>
f0103ed7:	c7 44 24 0c 60 64 10 	movl   $0xf0106460,0xc(%esp)
f0103ede:	f0 
f0103edf:	c7 44 24 08 3f 5d 10 	movl   $0xf0105d3f,0x8(%esp)
f0103ee6:	f0 
f0103ee7:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f0103eee:	00 
f0103eef:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0103ef6:	e8 bb c1 ff ff       	call   f01000b6 <_panic>
	env_run(curenv);
f0103efb:	89 04 24             	mov    %eax,(%esp)
f0103efe:	e8 25 f7 ff ff       	call   f0103628 <env_run>
f0103f03:	90                   	nop

f0103f04 <divide_error1>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_error1, T_DIVIDE)				# divide error
f0103f04:	6a 00                	push   $0x0
f0103f06:	6a 00                	push   $0x0
f0103f08:	e9 a4 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f0d:	90                   	nop

f0103f0e <debug1>:
	TRAPHANDLER_NOEC(debug1, T_DEBUG)					# debug exception
f0103f0e:	6a 00                	push   $0x0
f0103f10:	6a 01                	push   $0x1
f0103f12:	e9 9a 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f17:	90                   	nop

f0103f18 <nmi1>:
	TRAPHANDLER_NOEC(nmi1, T_NMI)					# non-maskable interrupt
f0103f18:	6a 00                	push   $0x0
f0103f1a:	6a 02                	push   $0x2
f0103f1c:	e9 90 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f21:	90                   	nop

f0103f22 <breakpoint1>:
   	 TRAPHANDLER_NOEC(breakpoint1, T_BRKPT)				# breakpoint
f0103f22:	6a 00                	push   $0x0
f0103f24:	6a 03                	push   $0x3
f0103f26:	e9 86 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f2b:	90                   	nop

f0103f2c <overflow1>:
	TRAPHANDLER_NOEC(overflow1, T_OFLOW)				# overflow
f0103f2c:	6a 00                	push   $0x0
f0103f2e:	6a 04                	push   $0x4
f0103f30:	e9 7c 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f35:	90                   	nop

f0103f36 <bounds1>:
	TRAPHANDLER_NOEC(bounds1, T_BOUND)				# bounds check
f0103f36:	6a 00                	push   $0x0
f0103f38:	6a 05                	push   $0x5
f0103f3a:	e9 72 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f3f:	90                   	nop

f0103f40 <invalid_op1>:
	TRAPHANDLER_NOEC(invalid_op1, T_ILLOP)				# illegal opcode
f0103f40:	6a 00                	push   $0x0
f0103f42:	6a 06                	push   $0x6
f0103f44:	e9 68 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f49:	90                   	nop

f0103f4a <device_not_available1>:
	TRAPHANDLER_NOEC(device_not_available1, T_DEVICE)			# device not available
f0103f4a:	6a 00                	push   $0x0
f0103f4c:	6a 07                	push   $0x7
f0103f4e:	e9 5e 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f53:	90                   	nop

f0103f54 <double_fault1>:
	TRAPHANDLER(double_fault1, T_DBLFLT)					# double fault
f0103f54:	6a 08                	push   $0x8
f0103f56:	e9 56 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f5b:	90                   	nop

f0103f5c <invalid_TSS1>:
	TRAPHANDLER(invalid_TSS1, T_TSS)					# invalid task switch segment
f0103f5c:	6a 0a                	push   $0xa
f0103f5e:	e9 4e 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f63:	90                   	nop

f0103f64 <segment_not_present1>:
	TRAPHANDLER(segment_not_present1, T_SEGNP)				# segment not present
f0103f64:	6a 0b                	push   $0xb
f0103f66:	e9 46 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f6b:	90                   	nop

f0103f6c <stack_segment1>:
	TRAPHANDLER(stack_segment1, T_STACK)					# stack exception
f0103f6c:	6a 0c                	push   $0xc
f0103f6e:	e9 3e 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f73:	90                   	nop

f0103f74 <general_protection1>:
	TRAPHANDLER(general_protection1, T_GPFLT)				# general protection fault
f0103f74:	6a 0d                	push   $0xd
f0103f76:	e9 36 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f7b:	90                   	nop

f0103f7c <page_fault1>:
	TRAPHANDLER(page_fault1, T_PGFLT)					# page fault
f0103f7c:	6a 0e                	push   $0xe
f0103f7e:	e9 2e 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f83:	90                   	nop

f0103f84 <float_point_error1>:
	TRAPHANDLER_NOEC(float_point_error1, T_FPERR)				# floating point error
f0103f84:	6a 00                	push   $0x0
f0103f86:	6a 10                	push   $0x10
f0103f88:	e9 24 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f8d:	90                   	nop

f0103f8e <alignment_check1>:
	TRAPHANDLER(alignment_check1, T_ALIGN)				# alignment check
f0103f8e:	6a 11                	push   $0x11
f0103f90:	e9 1c 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f95:	90                   	nop

f0103f96 <machine_check1>:
	TRAPHANDLER_NOEC(machine_check1, T_MCHK)				# machine check
f0103f96:	6a 00                	push   $0x0
f0103f98:	6a 12                	push   $0x12
f0103f9a:	e9 12 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103f9f:	90                   	nop

f0103fa0 <SIMD_float_point_error1>:
	TRAPHANDLER_NOEC(SIMD_float_point_error1, T_SIMDERR)		# SIMD floating point error
f0103fa0:	6a 00                	push   $0x0
f0103fa2:	6a 13                	push   $0x13
f0103fa4:	e9 08 00 00 00       	jmp    f0103fb1 <_alltraps>
f0103fa9:	90                   	nop

f0103faa <system_call1>:

	TRAPHANDLER(system_call1, T_SYSCALL)					#system call
f0103faa:	6a 30                	push   $0x30
f0103fac:	e9 00 00 00 00       	jmp    f0103fb1 <_alltraps>

f0103fb1 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
f0103fb1:	1e                   	push   %ds
	pushl %es
f0103fb2:	06                   	push   %es
	pushal
f0103fb3:	60                   	pusha  
	movl $GD_KD, %eax
f0103fb4:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0103fb9:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103fbb:	8e c0                	mov    %eax,%es

	pushl %esp
f0103fbd:	54                   	push   %esp
	call trap
f0103fbe:	e8 df fd ff ff       	call   f0103da2 <trap>
f0103fc3:	66 90                	xchg   %ax,%ax
f0103fc5:	66 90                	xchg   %ax,%ax
f0103fc7:	66 90                	xchg   %ax,%ax
f0103fc9:	66 90                	xchg   %ax,%ax
f0103fcb:	66 90                	xchg   %ax,%ax
f0103fcd:	66 90                	xchg   %ax,%ax
f0103fcf:	90                   	nop

f0103fd0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103fd0:	55                   	push   %ebp
f0103fd1:	89 e5                	mov    %esp,%ebp
f0103fd3:	83 ec 28             	sub    $0x28,%esp
f0103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch(syscallno){
f0103fd9:	83 f8 01             	cmp    $0x1,%eax
f0103fdc:	74 5e                	je     f010403c <syscall+0x6c>
f0103fde:	83 f8 01             	cmp    $0x1,%eax
f0103fe1:	72 12                	jb     f0103ff5 <syscall+0x25>
f0103fe3:	83 f8 02             	cmp    $0x2,%eax
f0103fe6:	74 5b                	je     f0104043 <syscall+0x73>
f0103fe8:	83 f8 03             	cmp    $0x3,%eax
f0103feb:	74 60                	je     f010404d <syscall+0x7d>
f0103fed:	8d 76 00             	lea    0x0(%esi),%esi
f0103ff0:	e9 c4 00 00 00       	jmp    f01040b9 <syscall+0xe9>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0103ff5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103ffc:	00 
f0103ffd:	8b 45 10             	mov    0x10(%ebp),%eax
f0104000:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104004:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010400b:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0104010:	89 04 24             	mov    %eax,(%esp)
f0104013:	e8 c4 ee ff ff       	call   f0102edc <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104018:	8b 45 0c             	mov    0xc(%ebp),%eax
f010401b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010401f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104022:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104026:	c7 04 24 f0 64 10 f0 	movl   $0xf01064f0,(%esp)
f010402d:	e8 d2 f6 ff ff       	call   f0103704 <cprintf>
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
f0104032:	b8 00 00 00 00       	mov    $0x0,%eax
f0104037:	e9 82 00 00 00       	jmp    f01040be <syscall+0xee>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010403c:	e8 94 c4 ff ff       	call   f01004d5 <cons_getc>
	int ret = 0;
	switch(syscallno){
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
f0104041:	eb 7b                	jmp    f01040be <syscall+0xee>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104043:	a1 c8 d0 17 f0       	mov    0xf017d0c8,%eax
f0104048:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs: 		sys_cputs( (const char *)a1, (size_t) a2);
						break;
		case SYS_cgetc: 		ret = sys_cgetc();		
						break;
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
f010404b:	eb 71                	jmp    f01040be <syscall+0xee>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010404d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104054:	00 
f0104055:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104058:	89 44 24 04          	mov    %eax,0x4(%esp)
f010405c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010405f:	89 04 24             	mov    %eax,(%esp)
f0104062:	e8 78 ef ff ff       	call   f0102fdf <envid2env>
f0104067:	85 c0                	test   %eax,%eax
f0104069:	78 53                	js     f01040be <syscall+0xee>
		return r;
	if (e == curenv)
f010406b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010406e:	8b 15 c8 d0 17 f0    	mov    0xf017d0c8,%edx
f0104074:	39 d0                	cmp    %edx,%eax
f0104076:	75 15                	jne    f010408d <syscall+0xbd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104078:	8b 40 48             	mov    0x48(%eax),%eax
f010407b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010407f:	c7 04 24 f5 64 10 f0 	movl   $0xf01064f5,(%esp)
f0104086:	e8 79 f6 ff ff       	call   f0103704 <cprintf>
f010408b:	eb 1a                	jmp    f01040a7 <syscall+0xd7>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010408d:	8b 40 48             	mov    0x48(%eax),%eax
f0104090:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104094:	8b 42 48             	mov    0x48(%edx),%eax
f0104097:	89 44 24 04          	mov    %eax,0x4(%esp)
f010409b:	c7 04 24 10 65 10 f0 	movl   $0xf0106510,(%esp)
f01040a2:	e8 5d f6 ff ff       	call   f0103704 <cprintf>
	env_destroy(e);
f01040a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040aa:	89 04 24             	mov    %eax,(%esp)
f01040ad:	e8 1f f5 ff ff       	call   f01035d1 <env_destroy>
	return 0;
f01040b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01040b7:	eb 05                	jmp    f01040be <syscall+0xee>
		case SYS_getenvid:	 ret =sys_getenvid();	
						break;
		case SYS_env_destroy:	ret= sys_env_destroy(a1);
						break;
		default:
			return -E_NO_SYS;
f01040b9:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
	return ret;
}
f01040be:	c9                   	leave  
f01040bf:	c3                   	ret    

f01040c0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01040c0:	55                   	push   %ebp
f01040c1:	89 e5                	mov    %esp,%ebp
f01040c3:	57                   	push   %edi
f01040c4:	56                   	push   %esi
f01040c5:	53                   	push   %ebx
f01040c6:	83 ec 14             	sub    $0x14,%esp
f01040c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01040cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01040d2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01040d5:	8b 1a                	mov    (%edx),%ebx
f01040d7:	8b 01                	mov    (%ecx),%eax
f01040d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01040dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01040e3:	e9 88 00 00 00       	jmp    f0104170 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01040e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01040eb:	01 d8                	add    %ebx,%eax
f01040ed:	89 c7                	mov    %eax,%edi
f01040ef:	c1 ef 1f             	shr    $0x1f,%edi
f01040f2:	01 c7                	add    %eax,%edi
f01040f4:	d1 ff                	sar    %edi
f01040f6:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01040f9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01040fc:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01040ff:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104101:	eb 03                	jmp    f0104106 <stab_binsearch+0x46>
			m--;
f0104103:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104106:	39 c3                	cmp    %eax,%ebx
f0104108:	7f 1f                	jg     f0104129 <stab_binsearch+0x69>
f010410a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010410e:	83 ea 0c             	sub    $0xc,%edx
f0104111:	39 f1                	cmp    %esi,%ecx
f0104113:	75 ee                	jne    f0104103 <stab_binsearch+0x43>
f0104115:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104118:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010411b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010411e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104122:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104125:	76 18                	jbe    f010413f <stab_binsearch+0x7f>
f0104127:	eb 05                	jmp    f010412e <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104129:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010412c:	eb 42                	jmp    f0104170 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010412e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104131:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104133:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104136:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010413d:	eb 31                	jmp    f0104170 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010413f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104142:	73 17                	jae    f010415b <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104144:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104147:	83 e8 01             	sub    $0x1,%eax
f010414a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010414d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104150:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104152:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104159:	eb 15                	jmp    f0104170 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010415b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010415e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104161:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0104163:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104167:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104169:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104170:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104173:	0f 8e 6f ff ff ff    	jle    f01040e8 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104179:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010417d:	75 0f                	jne    f010418e <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010417f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104182:	8b 00                	mov    (%eax),%eax
f0104184:	83 e8 01             	sub    $0x1,%eax
f0104187:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010418a:	89 07                	mov    %eax,(%edi)
f010418c:	eb 2c                	jmp    f01041ba <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010418e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104191:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104193:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104196:	8b 0f                	mov    (%edi),%ecx
f0104198:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010419b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010419e:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041a1:	eb 03                	jmp    f01041a6 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01041a3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041a6:	39 c8                	cmp    %ecx,%eax
f01041a8:	7e 0b                	jle    f01041b5 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01041aa:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01041ae:	83 ea 0c             	sub    $0xc,%edx
f01041b1:	39 f3                	cmp    %esi,%ebx
f01041b3:	75 ee                	jne    f01041a3 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01041b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041b8:	89 07                	mov    %eax,(%edi)
	}
}
f01041ba:	83 c4 14             	add    $0x14,%esp
f01041bd:	5b                   	pop    %ebx
f01041be:	5e                   	pop    %esi
f01041bf:	5f                   	pop    %edi
f01041c0:	5d                   	pop    %ebp
f01041c1:	c3                   	ret    

f01041c2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01041c2:	55                   	push   %ebp
f01041c3:	89 e5                	mov    %esp,%ebp
f01041c5:	57                   	push   %edi
f01041c6:	56                   	push   %esi
f01041c7:	53                   	push   %ebx
f01041c8:	83 ec 3c             	sub    $0x3c,%esp
f01041cb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01041d1:	c7 06 28 65 10 f0    	movl   $0xf0106528,(%esi)
	info->eip_line = 0;
f01041d7:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01041de:	c7 46 08 28 65 10 f0 	movl   $0xf0106528,0x8(%esi)
	info->eip_fn_namelen = 9;
f01041e5:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01041ec:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01041ef:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01041f6:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01041fc:	77 21                	ja     f010421f <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01041fe:	a1 00 00 20 00       	mov    0x200000,%eax
f0104203:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104206:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010420b:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0104211:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f0104214:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f010421a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010421d:	eb 1a                	jmp    f0104239 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010421f:	c7 45 cc 0d 0e 11 f0 	movl   $0xf0110e0d,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104226:	c7 45 d0 3d e4 10 f0 	movl   $0xf010e43d,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010422d:	b8 3c e4 10 f0       	mov    $0xf010e43c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104232:	c7 45 d4 50 67 10 f0 	movl   $0xf0106750,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104239:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010423c:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f010423f:	0f 83 2f 01 00 00    	jae    f0104374 <debuginfo_eip+0x1b2>
f0104245:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104249:	0f 85 2c 01 00 00    	jne    f010437b <debuginfo_eip+0x1b9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010424f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104256:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104259:	29 d8                	sub    %ebx,%eax
f010425b:	c1 f8 02             	sar    $0x2,%eax
f010425e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104264:	83 e8 01             	sub    $0x1,%eax
f0104267:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010426a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010426e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104275:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104278:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010427b:	89 d8                	mov    %ebx,%eax
f010427d:	e8 3e fe ff ff       	call   f01040c0 <stab_binsearch>
	if (lfile == 0)
f0104282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104285:	85 c0                	test   %eax,%eax
f0104287:	0f 84 f5 00 00 00    	je     f0104382 <debuginfo_eip+0x1c0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010428d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104290:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104293:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104296:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010429a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01042a1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01042a4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01042a7:	89 d8                	mov    %ebx,%eax
f01042a9:	e8 12 fe ff ff       	call   f01040c0 <stab_binsearch>

	if (lfun <= rfun) {
f01042ae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01042b1:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01042b4:	7f 23                	jg     f01042d9 <debuginfo_eip+0x117>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01042b6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01042b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01042bc:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01042bf:	8b 10                	mov    (%eax),%edx
f01042c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01042c4:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f01042c7:	39 ca                	cmp    %ecx,%edx
f01042c9:	73 06                	jae    f01042d1 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01042cb:	03 55 d0             	add    -0x30(%ebp),%edx
f01042ce:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01042d1:	8b 40 08             	mov    0x8(%eax),%eax
f01042d4:	89 46 10             	mov    %eax,0x10(%esi)
f01042d7:	eb 06                	jmp    f01042df <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01042d9:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01042dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01042df:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01042e6:	00 
f01042e7:	8b 46 08             	mov    0x8(%esi),%eax
f01042ea:	89 04 24             	mov    %eax,(%esp)
f01042ed:	e8 09 09 00 00       	call   f0104bfb <strfind>
f01042f2:	2b 46 08             	sub    0x8(%esi),%eax
f01042f5:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01042f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01042fb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01042fe:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104301:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104304:	eb 06                	jmp    f010430c <debuginfo_eip+0x14a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104306:	83 eb 01             	sub    $0x1,%ebx
f0104309:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010430c:	39 fb                	cmp    %edi,%ebx
f010430e:	7c 2c                	jl     f010433c <debuginfo_eip+0x17a>
	       && stabs[lline].n_type != N_SOL
f0104310:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104314:	80 fa 84             	cmp    $0x84,%dl
f0104317:	74 0b                	je     f0104324 <debuginfo_eip+0x162>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104319:	80 fa 64             	cmp    $0x64,%dl
f010431c:	75 e8                	jne    f0104306 <debuginfo_eip+0x144>
f010431e:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104322:	74 e2                	je     f0104306 <debuginfo_eip+0x144>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104324:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104327:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010432a:	8b 04 87             	mov    (%edi,%eax,4),%eax
f010432d:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104330:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0104333:	39 d0                	cmp    %edx,%eax
f0104335:	73 05                	jae    f010433c <debuginfo_eip+0x17a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104337:	03 45 d0             	add    -0x30(%ebp),%eax
f010433a:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010433c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010433f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104342:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104347:	39 cb                	cmp    %ecx,%ebx
f0104349:	7d 43                	jge    f010438e <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
f010434b:	8d 53 01             	lea    0x1(%ebx),%edx
f010434e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104351:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104354:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104357:	eb 07                	jmp    f0104360 <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104359:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010435d:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104360:	39 ca                	cmp    %ecx,%edx
f0104362:	74 25                	je     f0104389 <debuginfo_eip+0x1c7>
f0104364:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104367:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f010436b:	74 ec                	je     f0104359 <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010436d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104372:	eb 1a                	jmp    f010438e <debuginfo_eip+0x1cc>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104379:	eb 13                	jmp    f010438e <debuginfo_eip+0x1cc>
f010437b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104380:	eb 0c                	jmp    f010438e <debuginfo_eip+0x1cc>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104387:	eb 05                	jmp    f010438e <debuginfo_eip+0x1cc>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104389:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010438e:	83 c4 3c             	add    $0x3c,%esp
f0104391:	5b                   	pop    %ebx
f0104392:	5e                   	pop    %esi
f0104393:	5f                   	pop    %edi
f0104394:	5d                   	pop    %ebp
f0104395:	c3                   	ret    
f0104396:	66 90                	xchg   %ax,%ax
f0104398:	66 90                	xchg   %ax,%ax
f010439a:	66 90                	xchg   %ax,%ax
f010439c:	66 90                	xchg   %ax,%ax
f010439e:	66 90                	xchg   %ax,%ax

f01043a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01043a0:	55                   	push   %ebp
f01043a1:	89 e5                	mov    %esp,%ebp
f01043a3:	57                   	push   %edi
f01043a4:	56                   	push   %esi
f01043a5:	53                   	push   %ebx
f01043a6:	83 ec 3c             	sub    $0x3c,%esp
f01043a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01043ac:	89 d7                	mov    %edx,%edi
f01043ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01043b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01043b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043b7:	89 c3                	mov    %eax,%ebx
f01043b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01043bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01043bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01043c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01043ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01043cd:	39 d9                	cmp    %ebx,%ecx
f01043cf:	72 05                	jb     f01043d6 <printnum+0x36>
f01043d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01043d4:	77 69                	ja     f010443f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01043d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01043d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01043dd:	83 ee 01             	sub    $0x1,%esi
f01043e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01043e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043e8:	8b 44 24 08          	mov    0x8(%esp),%eax
f01043ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01043f0:	89 c3                	mov    %eax,%ebx
f01043f2:	89 d6                	mov    %edx,%esi
f01043f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01043f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01043fa:	89 54 24 08          	mov    %edx,0x8(%esp)
f01043fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104402:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104405:	89 04 24             	mov    %eax,(%esp)
f0104408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010440b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440f:	e8 0c 0a 00 00       	call   f0104e20 <__udivdi3>
f0104414:	89 d9                	mov    %ebx,%ecx
f0104416:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010441a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010441e:	89 04 24             	mov    %eax,(%esp)
f0104421:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104425:	89 fa                	mov    %edi,%edx
f0104427:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010442a:	e8 71 ff ff ff       	call   f01043a0 <printnum>
f010442f:	eb 1b                	jmp    f010444c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104431:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104435:	8b 45 18             	mov    0x18(%ebp),%eax
f0104438:	89 04 24             	mov    %eax,(%esp)
f010443b:	ff d3                	call   *%ebx
f010443d:	eb 03                	jmp    f0104442 <printnum+0xa2>
f010443f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104442:	83 ee 01             	sub    $0x1,%esi
f0104445:	85 f6                	test   %esi,%esi
f0104447:	7f e8                	jg     f0104431 <printnum+0x91>
f0104449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010444c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104450:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104454:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104457:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010445a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010445e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104462:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104465:	89 04 24             	mov    %eax,(%esp)
f0104468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446f:	e8 dc 0a 00 00       	call   f0104f50 <__umoddi3>
f0104474:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104478:	0f be 80 32 65 10 f0 	movsbl -0xfef9ace(%eax),%eax
f010447f:	89 04 24             	mov    %eax,(%esp)
f0104482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104485:	ff d0                	call   *%eax
}
f0104487:	83 c4 3c             	add    $0x3c,%esp
f010448a:	5b                   	pop    %ebx
f010448b:	5e                   	pop    %esi
f010448c:	5f                   	pop    %edi
f010448d:	5d                   	pop    %ebp
f010448e:	c3                   	ret    

f010448f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010448f:	55                   	push   %ebp
f0104490:	89 e5                	mov    %esp,%ebp
f0104492:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104495:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104499:	8b 10                	mov    (%eax),%edx
f010449b:	3b 50 04             	cmp    0x4(%eax),%edx
f010449e:	73 0a                	jae    f01044aa <sprintputch+0x1b>
		*b->buf++ = ch;
f01044a0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01044a3:	89 08                	mov    %ecx,(%eax)
f01044a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01044a8:	88 02                	mov    %al,(%edx)
}
f01044aa:	5d                   	pop    %ebp
f01044ab:	c3                   	ret    

f01044ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
f01044af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01044b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01044b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01044bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ca:	89 04 24             	mov    %eax,(%esp)
f01044cd:	e8 02 00 00 00       	call   f01044d4 <vprintfmt>
	va_end(ap);
}
f01044d2:	c9                   	leave  
f01044d3:	c3                   	ret    

f01044d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01044d4:	55                   	push   %ebp
f01044d5:	89 e5                	mov    %esp,%ebp
f01044d7:	57                   	push   %edi
f01044d8:	56                   	push   %esi
f01044d9:	53                   	push   %ebx
f01044da:	83 ec 3c             	sub    $0x3c,%esp
f01044dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01044e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01044e3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01044e6:	eb 11                	jmp    f01044f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01044e8:	85 c0                	test   %eax,%eax
f01044ea:	0f 84 48 04 00 00    	je     f0104938 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
f01044f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044f4:	89 04 24             	mov    %eax,(%esp)
f01044f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01044f9:	83 c7 01             	add    $0x1,%edi
f01044fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104500:	83 f8 25             	cmp    $0x25,%eax
f0104503:	75 e3                	jne    f01044e8 <vprintfmt+0x14>
f0104505:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104509:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104510:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104517:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010451e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104523:	eb 1f                	jmp    f0104544 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104525:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104528:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010452c:	eb 16                	jmp    f0104544 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010452e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104531:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104535:	eb 0d                	jmp    f0104544 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104537:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010453a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010453d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104544:	8d 47 01             	lea    0x1(%edi),%eax
f0104547:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010454a:	0f b6 17             	movzbl (%edi),%edx
f010454d:	0f b6 c2             	movzbl %dl,%eax
f0104550:	83 ea 23             	sub    $0x23,%edx
f0104553:	80 fa 55             	cmp    $0x55,%dl
f0104556:	0f 87 bf 03 00 00    	ja     f010491b <vprintfmt+0x447>
f010455c:	0f b6 d2             	movzbl %dl,%edx
f010455f:	ff 24 95 c0 65 10 f0 	jmp    *-0xfef9a40(,%edx,4)
f0104566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104569:	ba 00 00 00 00       	mov    $0x0,%edx
f010456e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104571:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104574:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104578:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010457b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010457e:	83 f9 09             	cmp    $0x9,%ecx
f0104581:	77 3c                	ja     f01045bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104583:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104586:	eb e9                	jmp    f0104571 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104588:	8b 45 14             	mov    0x14(%ebp),%eax
f010458b:	8b 00                	mov    (%eax),%eax
f010458d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104590:	8b 45 14             	mov    0x14(%ebp),%eax
f0104593:	8d 40 04             	lea    0x4(%eax),%eax
f0104596:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010459c:	eb 27                	jmp    f01045c5 <vprintfmt+0xf1>
f010459e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01045a1:	85 d2                	test   %edx,%edx
f01045a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01045a8:	0f 49 c2             	cmovns %edx,%eax
f01045ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045b1:	eb 91                	jmp    f0104544 <vprintfmt+0x70>
f01045b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01045b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01045bd:	eb 85                	jmp    f0104544 <vprintfmt+0x70>
f01045bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01045c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01045c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01045c9:	0f 89 75 ff ff ff    	jns    f0104544 <vprintfmt+0x70>
f01045cf:	e9 63 ff ff ff       	jmp    f0104537 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01045d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01045da:	e9 65 ff ff ff       	jmp    f0104544 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01045e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f01045e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045ea:	8b 00                	mov    (%eax),%eax
f01045ec:	89 04 24             	mov    %eax,(%esp)
f01045ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01045f4:	e9 00 ff ff ff       	jmp    f01044f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01045fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104600:	8b 00                	mov    (%eax),%eax
f0104602:	99                   	cltd   
f0104603:	31 d0                	xor    %edx,%eax
f0104605:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104607:	83 f8 07             	cmp    $0x7,%eax
f010460a:	7f 0b                	jg     f0104617 <vprintfmt+0x143>
f010460c:	8b 14 85 20 67 10 f0 	mov    -0xfef98e0(,%eax,4),%edx
f0104613:	85 d2                	test   %edx,%edx
f0104615:	75 20                	jne    f0104637 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
f0104617:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010461b:	c7 44 24 08 4a 65 10 	movl   $0xf010654a,0x8(%esp)
f0104622:	f0 
f0104623:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104627:	89 34 24             	mov    %esi,(%esp)
f010462a:	e8 7d fe ff ff       	call   f01044ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010462f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104632:	e9 c2 fe ff ff       	jmp    f01044f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104637:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010463b:	c7 44 24 08 51 5d 10 	movl   $0xf0105d51,0x8(%esp)
f0104642:	f0 
f0104643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104647:	89 34 24             	mov    %esi,(%esp)
f010464a:	e8 5d fe ff ff       	call   f01044ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010464f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104652:	e9 a2 fe ff ff       	jmp    f01044f9 <vprintfmt+0x25>
f0104657:	8b 45 14             	mov    0x14(%ebp),%eax
f010465a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010465d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104660:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104663:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104667:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104669:	85 ff                	test   %edi,%edi
f010466b:	b8 43 65 10 f0       	mov    $0xf0106543,%eax
f0104670:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104673:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104677:	0f 84 92 00 00 00    	je     f010470f <vprintfmt+0x23b>
f010467d:	85 c9                	test   %ecx,%ecx
f010467f:	0f 8e 98 00 00 00    	jle    f010471d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104685:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104689:	89 3c 24             	mov    %edi,(%esp)
f010468c:	e8 17 04 00 00       	call   f0104aa8 <strnlen>
f0104691:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104694:	29 c1                	sub    %eax,%ecx
f0104696:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
f0104699:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010469d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01046a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01046a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01046a5:	eb 0f                	jmp    f01046b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
f01046a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046ae:	89 04 24             	mov    %eax,(%esp)
f01046b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01046b3:	83 ef 01             	sub    $0x1,%edi
f01046b6:	85 ff                	test   %edi,%edi
f01046b8:	7f ed                	jg     f01046a7 <vprintfmt+0x1d3>
f01046ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01046bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01046c0:	85 c9                	test   %ecx,%ecx
f01046c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01046c7:	0f 49 c1             	cmovns %ecx,%eax
f01046ca:	29 c1                	sub    %eax,%ecx
f01046cc:	89 75 08             	mov    %esi,0x8(%ebp)
f01046cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01046d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01046d5:	89 cb                	mov    %ecx,%ebx
f01046d7:	eb 50                	jmp    f0104729 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01046d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01046dd:	74 1e                	je     f01046fd <vprintfmt+0x229>
f01046df:	0f be d2             	movsbl %dl,%edx
f01046e2:	83 ea 20             	sub    $0x20,%edx
f01046e5:	83 fa 5e             	cmp    $0x5e,%edx
f01046e8:	76 13                	jbe    f01046fd <vprintfmt+0x229>
					putch('?', putdat);
f01046ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01046f8:	ff 55 08             	call   *0x8(%ebp)
f01046fb:	eb 0d                	jmp    f010470a <vprintfmt+0x236>
				else
					putch(ch, putdat);
f01046fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104700:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104704:	89 04 24             	mov    %eax,(%esp)
f0104707:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010470a:	83 eb 01             	sub    $0x1,%ebx
f010470d:	eb 1a                	jmp    f0104729 <vprintfmt+0x255>
f010470f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104712:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010471b:	eb 0c                	jmp    f0104729 <vprintfmt+0x255>
f010471d:	89 75 08             	mov    %esi,0x8(%ebp)
f0104720:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104723:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104726:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104729:	83 c7 01             	add    $0x1,%edi
f010472c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104730:	0f be c2             	movsbl %dl,%eax
f0104733:	85 c0                	test   %eax,%eax
f0104735:	74 25                	je     f010475c <vprintfmt+0x288>
f0104737:	85 f6                	test   %esi,%esi
f0104739:	78 9e                	js     f01046d9 <vprintfmt+0x205>
f010473b:	83 ee 01             	sub    $0x1,%esi
f010473e:	79 99                	jns    f01046d9 <vprintfmt+0x205>
f0104740:	89 df                	mov    %ebx,%edi
f0104742:	8b 75 08             	mov    0x8(%ebp),%esi
f0104745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104748:	eb 1a                	jmp    f0104764 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010474a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010474e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104755:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104757:	83 ef 01             	sub    $0x1,%edi
f010475a:	eb 08                	jmp    f0104764 <vprintfmt+0x290>
f010475c:	89 df                	mov    %ebx,%edi
f010475e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104764:	85 ff                	test   %edi,%edi
f0104766:	7f e2                	jg     f010474a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010476b:	e9 89 fd ff ff       	jmp    f01044f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104770:	83 f9 01             	cmp    $0x1,%ecx
f0104773:	7e 19                	jle    f010478e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
f0104775:	8b 45 14             	mov    0x14(%ebp),%eax
f0104778:	8b 50 04             	mov    0x4(%eax),%edx
f010477b:	8b 00                	mov    (%eax),%eax
f010477d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104780:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104783:	8b 45 14             	mov    0x14(%ebp),%eax
f0104786:	8d 40 08             	lea    0x8(%eax),%eax
f0104789:	89 45 14             	mov    %eax,0x14(%ebp)
f010478c:	eb 38                	jmp    f01047c6 <vprintfmt+0x2f2>
	else if (lflag)
f010478e:	85 c9                	test   %ecx,%ecx
f0104790:	74 1b                	je     f01047ad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
f0104792:	8b 45 14             	mov    0x14(%ebp),%eax
f0104795:	8b 00                	mov    (%eax),%eax
f0104797:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010479a:	89 c1                	mov    %eax,%ecx
f010479c:	c1 f9 1f             	sar    $0x1f,%ecx
f010479f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01047a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01047a5:	8d 40 04             	lea    0x4(%eax),%eax
f01047a8:	89 45 14             	mov    %eax,0x14(%ebp)
f01047ab:	eb 19                	jmp    f01047c6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
f01047ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01047b0:	8b 00                	mov    (%eax),%eax
f01047b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01047b5:	89 c1                	mov    %eax,%ecx
f01047b7:	c1 f9 1f             	sar    $0x1f,%ecx
f01047ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01047bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01047c0:	8d 40 04             	lea    0x4(%eax),%eax
f01047c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01047c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01047c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01047cc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01047d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01047d5:	0f 89 04 01 00 00    	jns    f01048df <vprintfmt+0x40b>
				putch('-', putdat);
f01047db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01047e6:	ff d6                	call   *%esi
				num = -(long long) num;
f01047e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01047eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01047ee:	f7 da                	neg    %edx
f01047f0:	83 d1 00             	adc    $0x0,%ecx
f01047f3:	f7 d9                	neg    %ecx
f01047f5:	e9 e5 00 00 00       	jmp    f01048df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01047fa:	83 f9 01             	cmp    $0x1,%ecx
f01047fd:	7e 10                	jle    f010480f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
f01047ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104802:	8b 10                	mov    (%eax),%edx
f0104804:	8b 48 04             	mov    0x4(%eax),%ecx
f0104807:	8d 40 08             	lea    0x8(%eax),%eax
f010480a:	89 45 14             	mov    %eax,0x14(%ebp)
f010480d:	eb 26                	jmp    f0104835 <vprintfmt+0x361>
	else if (lflag)
f010480f:	85 c9                	test   %ecx,%ecx
f0104811:	74 12                	je     f0104825 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
f0104813:	8b 45 14             	mov    0x14(%ebp),%eax
f0104816:	8b 10                	mov    (%eax),%edx
f0104818:	b9 00 00 00 00       	mov    $0x0,%ecx
f010481d:	8d 40 04             	lea    0x4(%eax),%eax
f0104820:	89 45 14             	mov    %eax,0x14(%ebp)
f0104823:	eb 10                	jmp    f0104835 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
f0104825:	8b 45 14             	mov    0x14(%ebp),%eax
f0104828:	8b 10                	mov    (%eax),%edx
f010482a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010482f:	8d 40 04             	lea    0x4(%eax),%eax
f0104832:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104835:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f010483a:	e9 a0 00 00 00       	jmp    f01048df <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010483f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104843:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010484a:	ff d6                	call   *%esi
			putch('X', putdat);
f010484c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104850:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104857:	ff d6                	call   *%esi
			putch('X', putdat);
f0104859:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010485d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104864:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0104869:	e9 8b fc ff ff       	jmp    f01044f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010486e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104872:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104879:	ff d6                	call   *%esi
			putch('x', putdat);
f010487b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010487f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104886:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104888:	8b 45 14             	mov    0x14(%ebp),%eax
f010488b:	8b 10                	mov    (%eax),%edx
f010488d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0104892:	8d 40 04             	lea    0x4(%eax),%eax
f0104895:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104898:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010489d:	eb 40                	jmp    f01048df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010489f:	83 f9 01             	cmp    $0x1,%ecx
f01048a2:	7e 10                	jle    f01048b4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
f01048a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01048a7:	8b 10                	mov    (%eax),%edx
f01048a9:	8b 48 04             	mov    0x4(%eax),%ecx
f01048ac:	8d 40 08             	lea    0x8(%eax),%eax
f01048af:	89 45 14             	mov    %eax,0x14(%ebp)
f01048b2:	eb 26                	jmp    f01048da <vprintfmt+0x406>
	else if (lflag)
f01048b4:	85 c9                	test   %ecx,%ecx
f01048b6:	74 12                	je     f01048ca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
f01048b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01048bb:	8b 10                	mov    (%eax),%edx
f01048bd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048c2:	8d 40 04             	lea    0x4(%eax),%eax
f01048c5:	89 45 14             	mov    %eax,0x14(%ebp)
f01048c8:	eb 10                	jmp    f01048da <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
f01048ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01048cd:	8b 10                	mov    (%eax),%edx
f01048cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048d4:	8d 40 04             	lea    0x4(%eax),%eax
f01048d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01048da:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01048df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01048e3:	89 44 24 10          	mov    %eax,0x10(%esp)
f01048e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01048f2:	89 14 24             	mov    %edx,(%esp)
f01048f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01048f9:	89 da                	mov    %ebx,%edx
f01048fb:	89 f0                	mov    %esi,%eax
f01048fd:	e8 9e fa ff ff       	call   f01043a0 <printnum>
			break;
f0104902:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104905:	e9 ef fb ff ff       	jmp    f01044f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010490a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010490e:	89 04 24             	mov    %eax,(%esp)
f0104911:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104916:	e9 de fb ff ff       	jmp    f01044f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010491b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010491f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104926:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104928:	eb 03                	jmp    f010492d <vprintfmt+0x459>
f010492a:	83 ef 01             	sub    $0x1,%edi
f010492d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104931:	75 f7                	jne    f010492a <vprintfmt+0x456>
f0104933:	e9 c1 fb ff ff       	jmp    f01044f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104938:	83 c4 3c             	add    $0x3c,%esp
f010493b:	5b                   	pop    %ebx
f010493c:	5e                   	pop    %esi
f010493d:	5f                   	pop    %edi
f010493e:	5d                   	pop    %ebp
f010493f:	c3                   	ret    

f0104940 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104940:	55                   	push   %ebp
f0104941:	89 e5                	mov    %esp,%ebp
f0104943:	83 ec 28             	sub    $0x28,%esp
f0104946:	8b 45 08             	mov    0x8(%ebp),%eax
f0104949:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010494c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010494f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104953:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010495d:	85 c0                	test   %eax,%eax
f010495f:	74 30                	je     f0104991 <vsnprintf+0x51>
f0104961:	85 d2                	test   %edx,%edx
f0104963:	7e 2c                	jle    f0104991 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104965:	8b 45 14             	mov    0x14(%ebp),%eax
f0104968:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010496c:	8b 45 10             	mov    0x10(%ebp),%eax
f010496f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104973:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104976:	89 44 24 04          	mov    %eax,0x4(%esp)
f010497a:	c7 04 24 8f 44 10 f0 	movl   $0xf010448f,(%esp)
f0104981:	e8 4e fb ff ff       	call   f01044d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104986:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104989:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010498f:	eb 05                	jmp    f0104996 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104991:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104996:	c9                   	leave  
f0104997:	c3                   	ret    

f0104998 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104998:	55                   	push   %ebp
f0104999:	89 e5                	mov    %esp,%ebp
f010499b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010499e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01049a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049a5:	8b 45 10             	mov    0x10(%ebp),%eax
f01049a8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01049b6:	89 04 24             	mov    %eax,(%esp)
f01049b9:	e8 82 ff ff ff       	call   f0104940 <vsnprintf>
	va_end(ap);

	return rc;
}
f01049be:	c9                   	leave  
f01049bf:	c3                   	ret    

f01049c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01049c0:	55                   	push   %ebp
f01049c1:	89 e5                	mov    %esp,%ebp
f01049c3:	57                   	push   %edi
f01049c4:	56                   	push   %esi
f01049c5:	53                   	push   %ebx
f01049c6:	83 ec 1c             	sub    $0x1c,%esp
f01049c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01049cc:	85 c0                	test   %eax,%eax
f01049ce:	74 10                	je     f01049e0 <readline+0x20>
		cprintf("%s", prompt);
f01049d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049d4:	c7 04 24 51 5d 10 f0 	movl   $0xf0105d51,(%esp)
f01049db:	e8 24 ed ff ff       	call   f0103704 <cprintf>

	i = 0;
	echoing = iscons(0);
f01049e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01049e7:	e8 46 bc ff ff       	call   f0100632 <iscons>
f01049ec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01049ee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01049f3:	e8 29 bc ff ff       	call   f0100621 <getchar>
f01049f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01049fa:	85 c0                	test   %eax,%eax
f01049fc:	79 17                	jns    f0104a15 <readline+0x55>
			cprintf("read error: %e\n", c);
f01049fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a02:	c7 04 24 40 67 10 f0 	movl   $0xf0106740,(%esp)
f0104a09:	e8 f6 ec ff ff       	call   f0103704 <cprintf>
			return NULL;
f0104a0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a13:	eb 6d                	jmp    f0104a82 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104a15:	83 f8 7f             	cmp    $0x7f,%eax
f0104a18:	74 05                	je     f0104a1f <readline+0x5f>
f0104a1a:	83 f8 08             	cmp    $0x8,%eax
f0104a1d:	75 19                	jne    f0104a38 <readline+0x78>
f0104a1f:	85 f6                	test   %esi,%esi
f0104a21:	7e 15                	jle    f0104a38 <readline+0x78>
			if (echoing)
f0104a23:	85 ff                	test   %edi,%edi
f0104a25:	74 0c                	je     f0104a33 <readline+0x73>
				cputchar('\b');
f0104a27:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104a2e:	e8 de bb ff ff       	call   f0100611 <cputchar>
			i--;
f0104a33:	83 ee 01             	sub    $0x1,%esi
f0104a36:	eb bb                	jmp    f01049f3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104a38:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104a3e:	7f 1c                	jg     f0104a5c <readline+0x9c>
f0104a40:	83 fb 1f             	cmp    $0x1f,%ebx
f0104a43:	7e 17                	jle    f0104a5c <readline+0x9c>
			if (echoing)
f0104a45:	85 ff                	test   %edi,%edi
f0104a47:	74 08                	je     f0104a51 <readline+0x91>
				cputchar(c);
f0104a49:	89 1c 24             	mov    %ebx,(%esp)
f0104a4c:	e8 c0 bb ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f0104a51:	88 9e 80 d9 17 f0    	mov    %bl,-0xfe82680(%esi)
f0104a57:	8d 76 01             	lea    0x1(%esi),%esi
f0104a5a:	eb 97                	jmp    f01049f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104a5c:	83 fb 0d             	cmp    $0xd,%ebx
f0104a5f:	74 05                	je     f0104a66 <readline+0xa6>
f0104a61:	83 fb 0a             	cmp    $0xa,%ebx
f0104a64:	75 8d                	jne    f01049f3 <readline+0x33>
			if (echoing)
f0104a66:	85 ff                	test   %edi,%edi
f0104a68:	74 0c                	je     f0104a76 <readline+0xb6>
				cputchar('\n');
f0104a6a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104a71:	e8 9b bb ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f0104a76:	c6 86 80 d9 17 f0 00 	movb   $0x0,-0xfe82680(%esi)
			return buf;
f0104a7d:	b8 80 d9 17 f0       	mov    $0xf017d980,%eax
		}
	}
}
f0104a82:	83 c4 1c             	add    $0x1c,%esp
f0104a85:	5b                   	pop    %ebx
f0104a86:	5e                   	pop    %esi
f0104a87:	5f                   	pop    %edi
f0104a88:	5d                   	pop    %ebp
f0104a89:	c3                   	ret    
f0104a8a:	66 90                	xchg   %ax,%ax
f0104a8c:	66 90                	xchg   %ax,%ax
f0104a8e:	66 90                	xchg   %ax,%ax

f0104a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104a90:	55                   	push   %ebp
f0104a91:	89 e5                	mov    %esp,%ebp
f0104a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104a96:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a9b:	eb 03                	jmp    f0104aa0 <strlen+0x10>
		n++;
f0104a9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104aa0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104aa4:	75 f7                	jne    f0104a9d <strlen+0xd>
		n++;
	return n;
}
f0104aa6:	5d                   	pop    %ebp
f0104aa7:	c3                   	ret    

f0104aa8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104aa8:	55                   	push   %ebp
f0104aa9:	89 e5                	mov    %esp,%ebp
f0104aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ab1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ab6:	eb 03                	jmp    f0104abb <strnlen+0x13>
		n++;
f0104ab8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104abb:	39 d0                	cmp    %edx,%eax
f0104abd:	74 06                	je     f0104ac5 <strnlen+0x1d>
f0104abf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104ac3:	75 f3                	jne    f0104ab8 <strnlen+0x10>
		n++;
	return n;
}
f0104ac5:	5d                   	pop    %ebp
f0104ac6:	c3                   	ret    

f0104ac7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104ac7:	55                   	push   %ebp
f0104ac8:	89 e5                	mov    %esp,%ebp
f0104aca:	53                   	push   %ebx
f0104acb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104ad1:	89 c2                	mov    %eax,%edx
f0104ad3:	83 c2 01             	add    $0x1,%edx
f0104ad6:	83 c1 01             	add    $0x1,%ecx
f0104ad9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104add:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104ae0:	84 db                	test   %bl,%bl
f0104ae2:	75 ef                	jne    f0104ad3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104ae4:	5b                   	pop    %ebx
f0104ae5:	5d                   	pop    %ebp
f0104ae6:	c3                   	ret    

f0104ae7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104ae7:	55                   	push   %ebp
f0104ae8:	89 e5                	mov    %esp,%ebp
f0104aea:	53                   	push   %ebx
f0104aeb:	83 ec 08             	sub    $0x8,%esp
f0104aee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104af1:	89 1c 24             	mov    %ebx,(%esp)
f0104af4:	e8 97 ff ff ff       	call   f0104a90 <strlen>
	strcpy(dst + len, src);
f0104af9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104afc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b00:	01 d8                	add    %ebx,%eax
f0104b02:	89 04 24             	mov    %eax,(%esp)
f0104b05:	e8 bd ff ff ff       	call   f0104ac7 <strcpy>
	return dst;
}
f0104b0a:	89 d8                	mov    %ebx,%eax
f0104b0c:	83 c4 08             	add    $0x8,%esp
f0104b0f:	5b                   	pop    %ebx
f0104b10:	5d                   	pop    %ebp
f0104b11:	c3                   	ret    

f0104b12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104b12:	55                   	push   %ebp
f0104b13:	89 e5                	mov    %esp,%ebp
f0104b15:	56                   	push   %esi
f0104b16:	53                   	push   %ebx
f0104b17:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b1d:	89 f3                	mov    %esi,%ebx
f0104b1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b22:	89 f2                	mov    %esi,%edx
f0104b24:	eb 0f                	jmp    f0104b35 <strncpy+0x23>
		*dst++ = *src;
f0104b26:	83 c2 01             	add    $0x1,%edx
f0104b29:	0f b6 01             	movzbl (%ecx),%eax
f0104b2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b2f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104b32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b35:	39 da                	cmp    %ebx,%edx
f0104b37:	75 ed                	jne    f0104b26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104b39:	89 f0                	mov    %esi,%eax
f0104b3b:	5b                   	pop    %ebx
f0104b3c:	5e                   	pop    %esi
f0104b3d:	5d                   	pop    %ebp
f0104b3e:	c3                   	ret    

f0104b3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104b3f:	55                   	push   %ebp
f0104b40:	89 e5                	mov    %esp,%ebp
f0104b42:	56                   	push   %esi
f0104b43:	53                   	push   %ebx
f0104b44:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b47:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b4d:	89 f0                	mov    %esi,%eax
f0104b4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104b53:	85 c9                	test   %ecx,%ecx
f0104b55:	75 0b                	jne    f0104b62 <strlcpy+0x23>
f0104b57:	eb 1d                	jmp    f0104b76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104b59:	83 c0 01             	add    $0x1,%eax
f0104b5c:	83 c2 01             	add    $0x1,%edx
f0104b5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104b62:	39 d8                	cmp    %ebx,%eax
f0104b64:	74 0b                	je     f0104b71 <strlcpy+0x32>
f0104b66:	0f b6 0a             	movzbl (%edx),%ecx
f0104b69:	84 c9                	test   %cl,%cl
f0104b6b:	75 ec                	jne    f0104b59 <strlcpy+0x1a>
f0104b6d:	89 c2                	mov    %eax,%edx
f0104b6f:	eb 02                	jmp    f0104b73 <strlcpy+0x34>
f0104b71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104b73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104b76:	29 f0                	sub    %esi,%eax
}
f0104b78:	5b                   	pop    %ebx
f0104b79:	5e                   	pop    %esi
f0104b7a:	5d                   	pop    %ebp
f0104b7b:	c3                   	ret    

f0104b7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104b7c:	55                   	push   %ebp
f0104b7d:	89 e5                	mov    %esp,%ebp
f0104b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104b85:	eb 06                	jmp    f0104b8d <strcmp+0x11>
		p++, q++;
f0104b87:	83 c1 01             	add    $0x1,%ecx
f0104b8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104b8d:	0f b6 01             	movzbl (%ecx),%eax
f0104b90:	84 c0                	test   %al,%al
f0104b92:	74 04                	je     f0104b98 <strcmp+0x1c>
f0104b94:	3a 02                	cmp    (%edx),%al
f0104b96:	74 ef                	je     f0104b87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104b98:	0f b6 c0             	movzbl %al,%eax
f0104b9b:	0f b6 12             	movzbl (%edx),%edx
f0104b9e:	29 d0                	sub    %edx,%eax
}
f0104ba0:	5d                   	pop    %ebp
f0104ba1:	c3                   	ret    

f0104ba2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104ba2:	55                   	push   %ebp
f0104ba3:	89 e5                	mov    %esp,%ebp
f0104ba5:	53                   	push   %ebx
f0104ba6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bac:	89 c3                	mov    %eax,%ebx
f0104bae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104bb1:	eb 06                	jmp    f0104bb9 <strncmp+0x17>
		n--, p++, q++;
f0104bb3:	83 c0 01             	add    $0x1,%eax
f0104bb6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104bb9:	39 d8                	cmp    %ebx,%eax
f0104bbb:	74 15                	je     f0104bd2 <strncmp+0x30>
f0104bbd:	0f b6 08             	movzbl (%eax),%ecx
f0104bc0:	84 c9                	test   %cl,%cl
f0104bc2:	74 04                	je     f0104bc8 <strncmp+0x26>
f0104bc4:	3a 0a                	cmp    (%edx),%cl
f0104bc6:	74 eb                	je     f0104bb3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bc8:	0f b6 00             	movzbl (%eax),%eax
f0104bcb:	0f b6 12             	movzbl (%edx),%edx
f0104bce:	29 d0                	sub    %edx,%eax
f0104bd0:	eb 05                	jmp    f0104bd7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104bd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104bd7:	5b                   	pop    %ebx
f0104bd8:	5d                   	pop    %ebp
f0104bd9:	c3                   	ret    

f0104bda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104bda:	55                   	push   %ebp
f0104bdb:	89 e5                	mov    %esp,%ebp
f0104bdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104be0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104be4:	eb 07                	jmp    f0104bed <strchr+0x13>
		if (*s == c)
f0104be6:	38 ca                	cmp    %cl,%dl
f0104be8:	74 0f                	je     f0104bf9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104bea:	83 c0 01             	add    $0x1,%eax
f0104bed:	0f b6 10             	movzbl (%eax),%edx
f0104bf0:	84 d2                	test   %dl,%dl
f0104bf2:	75 f2                	jne    f0104be6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bf9:	5d                   	pop    %ebp
f0104bfa:	c3                   	ret    

f0104bfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104bfb:	55                   	push   %ebp
f0104bfc:	89 e5                	mov    %esp,%ebp
f0104bfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c05:	eb 07                	jmp    f0104c0e <strfind+0x13>
		if (*s == c)
f0104c07:	38 ca                	cmp    %cl,%dl
f0104c09:	74 0a                	je     f0104c15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104c0b:	83 c0 01             	add    $0x1,%eax
f0104c0e:	0f b6 10             	movzbl (%eax),%edx
f0104c11:	84 d2                	test   %dl,%dl
f0104c13:	75 f2                	jne    f0104c07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0104c15:	5d                   	pop    %ebp
f0104c16:	c3                   	ret    

f0104c17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c17:	55                   	push   %ebp
f0104c18:	89 e5                	mov    %esp,%ebp
f0104c1a:	57                   	push   %edi
f0104c1b:	56                   	push   %esi
f0104c1c:	53                   	push   %ebx
f0104c1d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c23:	85 c9                	test   %ecx,%ecx
f0104c25:	74 36                	je     f0104c5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c27:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c2d:	75 28                	jne    f0104c57 <memset+0x40>
f0104c2f:	f6 c1 03             	test   $0x3,%cl
f0104c32:	75 23                	jne    f0104c57 <memset+0x40>
		c &= 0xFF;
f0104c34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104c38:	89 d3                	mov    %edx,%ebx
f0104c3a:	c1 e3 08             	shl    $0x8,%ebx
f0104c3d:	89 d6                	mov    %edx,%esi
f0104c3f:	c1 e6 18             	shl    $0x18,%esi
f0104c42:	89 d0                	mov    %edx,%eax
f0104c44:	c1 e0 10             	shl    $0x10,%eax
f0104c47:	09 f0                	or     %esi,%eax
f0104c49:	09 c2                	or     %eax,%edx
f0104c4b:	89 d0                	mov    %edx,%eax
f0104c4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104c4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104c52:	fc                   	cld    
f0104c53:	f3 ab                	rep stos %eax,%es:(%edi)
f0104c55:	eb 06                	jmp    f0104c5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104c57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c5a:	fc                   	cld    
f0104c5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104c5d:	89 f8                	mov    %edi,%eax
f0104c5f:	5b                   	pop    %ebx
f0104c60:	5e                   	pop    %esi
f0104c61:	5f                   	pop    %edi
f0104c62:	5d                   	pop    %ebp
f0104c63:	c3                   	ret    

f0104c64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104c64:	55                   	push   %ebp
f0104c65:	89 e5                	mov    %esp,%ebp
f0104c67:	57                   	push   %edi
f0104c68:	56                   	push   %esi
f0104c69:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104c72:	39 c6                	cmp    %eax,%esi
f0104c74:	73 35                	jae    f0104cab <memmove+0x47>
f0104c76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104c79:	39 d0                	cmp    %edx,%eax
f0104c7b:	73 2e                	jae    f0104cab <memmove+0x47>
		s += n;
		d += n;
f0104c7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104c80:	89 d6                	mov    %edx,%esi
f0104c82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104c84:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104c8a:	75 13                	jne    f0104c9f <memmove+0x3b>
f0104c8c:	f6 c1 03             	test   $0x3,%cl
f0104c8f:	75 0e                	jne    f0104c9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104c91:	83 ef 04             	sub    $0x4,%edi
f0104c94:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104c97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104c9a:	fd                   	std    
f0104c9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104c9d:	eb 09                	jmp    f0104ca8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104c9f:	83 ef 01             	sub    $0x1,%edi
f0104ca2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104ca5:	fd                   	std    
f0104ca6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104ca8:	fc                   	cld    
f0104ca9:	eb 1d                	jmp    f0104cc8 <memmove+0x64>
f0104cab:	89 f2                	mov    %esi,%edx
f0104cad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104caf:	f6 c2 03             	test   $0x3,%dl
f0104cb2:	75 0f                	jne    f0104cc3 <memmove+0x5f>
f0104cb4:	f6 c1 03             	test   $0x3,%cl
f0104cb7:	75 0a                	jne    f0104cc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104cb9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104cbc:	89 c7                	mov    %eax,%edi
f0104cbe:	fc                   	cld    
f0104cbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cc1:	eb 05                	jmp    f0104cc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104cc3:	89 c7                	mov    %eax,%edi
f0104cc5:	fc                   	cld    
f0104cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104cc8:	5e                   	pop    %esi
f0104cc9:	5f                   	pop    %edi
f0104cca:	5d                   	pop    %ebp
f0104ccb:	c3                   	ret    

f0104ccc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104ccc:	55                   	push   %ebp
f0104ccd:	89 e5                	mov    %esp,%ebp
f0104ccf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104cd2:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ce3:	89 04 24             	mov    %eax,(%esp)
f0104ce6:	e8 79 ff ff ff       	call   f0104c64 <memmove>
}
f0104ceb:	c9                   	leave  
f0104cec:	c3                   	ret    

f0104ced <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104ced:	55                   	push   %ebp
f0104cee:	89 e5                	mov    %esp,%ebp
f0104cf0:	56                   	push   %esi
f0104cf1:	53                   	push   %ebx
f0104cf2:	8b 55 08             	mov    0x8(%ebp),%edx
f0104cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104cf8:	89 d6                	mov    %edx,%esi
f0104cfa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104cfd:	eb 1a                	jmp    f0104d19 <memcmp+0x2c>
		if (*s1 != *s2)
f0104cff:	0f b6 02             	movzbl (%edx),%eax
f0104d02:	0f b6 19             	movzbl (%ecx),%ebx
f0104d05:	38 d8                	cmp    %bl,%al
f0104d07:	74 0a                	je     f0104d13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104d09:	0f b6 c0             	movzbl %al,%eax
f0104d0c:	0f b6 db             	movzbl %bl,%ebx
f0104d0f:	29 d8                	sub    %ebx,%eax
f0104d11:	eb 0f                	jmp    f0104d22 <memcmp+0x35>
		s1++, s2++;
f0104d13:	83 c2 01             	add    $0x1,%edx
f0104d16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d19:	39 f2                	cmp    %esi,%edx
f0104d1b:	75 e2                	jne    f0104cff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d22:	5b                   	pop    %ebx
f0104d23:	5e                   	pop    %esi
f0104d24:	5d                   	pop    %ebp
f0104d25:	c3                   	ret    

f0104d26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d26:	55                   	push   %ebp
f0104d27:	89 e5                	mov    %esp,%ebp
f0104d29:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104d2f:	89 c2                	mov    %eax,%edx
f0104d31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104d34:	eb 07                	jmp    f0104d3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d36:	38 08                	cmp    %cl,(%eax)
f0104d38:	74 07                	je     f0104d41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d3a:	83 c0 01             	add    $0x1,%eax
f0104d3d:	39 d0                	cmp    %edx,%eax
f0104d3f:	72 f5                	jb     f0104d36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104d41:	5d                   	pop    %ebp
f0104d42:	c3                   	ret    

f0104d43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104d43:	55                   	push   %ebp
f0104d44:	89 e5                	mov    %esp,%ebp
f0104d46:	57                   	push   %edi
f0104d47:	56                   	push   %esi
f0104d48:	53                   	push   %ebx
f0104d49:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d4f:	eb 03                	jmp    f0104d54 <strtol+0x11>
		s++;
f0104d51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d54:	0f b6 0a             	movzbl (%edx),%ecx
f0104d57:	80 f9 09             	cmp    $0x9,%cl
f0104d5a:	74 f5                	je     f0104d51 <strtol+0xe>
f0104d5c:	80 f9 20             	cmp    $0x20,%cl
f0104d5f:	74 f0                	je     f0104d51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104d61:	80 f9 2b             	cmp    $0x2b,%cl
f0104d64:	75 0a                	jne    f0104d70 <strtol+0x2d>
		s++;
f0104d66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104d69:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d6e:	eb 11                	jmp    f0104d81 <strtol+0x3e>
f0104d70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104d75:	80 f9 2d             	cmp    $0x2d,%cl
f0104d78:	75 07                	jne    f0104d81 <strtol+0x3e>
		s++, neg = 1;
f0104d7a:	8d 52 01             	lea    0x1(%edx),%edx
f0104d7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104d81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0104d86:	75 15                	jne    f0104d9d <strtol+0x5a>
f0104d88:	80 3a 30             	cmpb   $0x30,(%edx)
f0104d8b:	75 10                	jne    f0104d9d <strtol+0x5a>
f0104d8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104d91:	75 0a                	jne    f0104d9d <strtol+0x5a>
		s += 2, base = 16;
f0104d93:	83 c2 02             	add    $0x2,%edx
f0104d96:	b8 10 00 00 00       	mov    $0x10,%eax
f0104d9b:	eb 10                	jmp    f0104dad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0104d9d:	85 c0                	test   %eax,%eax
f0104d9f:	75 0c                	jne    f0104dad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104da1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104da3:	80 3a 30             	cmpb   $0x30,(%edx)
f0104da6:	75 05                	jne    f0104dad <strtol+0x6a>
		s++, base = 8;
f0104da8:	83 c2 01             	add    $0x1,%edx
f0104dab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0104dad:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104db2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104db5:	0f b6 0a             	movzbl (%edx),%ecx
f0104db8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0104dbb:	89 f0                	mov    %esi,%eax
f0104dbd:	3c 09                	cmp    $0x9,%al
f0104dbf:	77 08                	ja     f0104dc9 <strtol+0x86>
			dig = *s - '0';
f0104dc1:	0f be c9             	movsbl %cl,%ecx
f0104dc4:	83 e9 30             	sub    $0x30,%ecx
f0104dc7:	eb 20                	jmp    f0104de9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0104dc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0104dcc:	89 f0                	mov    %esi,%eax
f0104dce:	3c 19                	cmp    $0x19,%al
f0104dd0:	77 08                	ja     f0104dda <strtol+0x97>
			dig = *s - 'a' + 10;
f0104dd2:	0f be c9             	movsbl %cl,%ecx
f0104dd5:	83 e9 57             	sub    $0x57,%ecx
f0104dd8:	eb 0f                	jmp    f0104de9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0104dda:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104ddd:	89 f0                	mov    %esi,%eax
f0104ddf:	3c 19                	cmp    $0x19,%al
f0104de1:	77 16                	ja     f0104df9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104de3:	0f be c9             	movsbl %cl,%ecx
f0104de6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104de9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0104dec:	7d 0f                	jge    f0104dfd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0104dee:	83 c2 01             	add    $0x1,%edx
f0104df1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0104df5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0104df7:	eb bc                	jmp    f0104db5 <strtol+0x72>
f0104df9:	89 d8                	mov    %ebx,%eax
f0104dfb:	eb 02                	jmp    f0104dff <strtol+0xbc>
f0104dfd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0104dff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e03:	74 05                	je     f0104e0a <strtol+0xc7>
		*endptr = (char *) s;
f0104e05:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0104e0a:	f7 d8                	neg    %eax
f0104e0c:	85 ff                	test   %edi,%edi
f0104e0e:	0f 44 c3             	cmove  %ebx,%eax
}
f0104e11:	5b                   	pop    %ebx
f0104e12:	5e                   	pop    %esi
f0104e13:	5f                   	pop    %edi
f0104e14:	5d                   	pop    %ebp
f0104e15:	c3                   	ret    
f0104e16:	66 90                	xchg   %ax,%ax
f0104e18:	66 90                	xchg   %ax,%ax
f0104e1a:	66 90                	xchg   %ax,%ax
f0104e1c:	66 90                	xchg   %ax,%ax
f0104e1e:	66 90                	xchg   %ax,%ax

f0104e20 <__udivdi3>:
f0104e20:	55                   	push   %ebp
f0104e21:	57                   	push   %edi
f0104e22:	56                   	push   %esi
f0104e23:	83 ec 0c             	sub    $0xc,%esp
f0104e26:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104e2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0104e2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104e32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104e36:	85 c0                	test   %eax,%eax
f0104e38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e3c:	89 ea                	mov    %ebp,%edx
f0104e3e:	89 0c 24             	mov    %ecx,(%esp)
f0104e41:	75 2d                	jne    f0104e70 <__udivdi3+0x50>
f0104e43:	39 e9                	cmp    %ebp,%ecx
f0104e45:	77 61                	ja     f0104ea8 <__udivdi3+0x88>
f0104e47:	85 c9                	test   %ecx,%ecx
f0104e49:	89 ce                	mov    %ecx,%esi
f0104e4b:	75 0b                	jne    f0104e58 <__udivdi3+0x38>
f0104e4d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e52:	31 d2                	xor    %edx,%edx
f0104e54:	f7 f1                	div    %ecx
f0104e56:	89 c6                	mov    %eax,%esi
f0104e58:	31 d2                	xor    %edx,%edx
f0104e5a:	89 e8                	mov    %ebp,%eax
f0104e5c:	f7 f6                	div    %esi
f0104e5e:	89 c5                	mov    %eax,%ebp
f0104e60:	89 f8                	mov    %edi,%eax
f0104e62:	f7 f6                	div    %esi
f0104e64:	89 ea                	mov    %ebp,%edx
f0104e66:	83 c4 0c             	add    $0xc,%esp
f0104e69:	5e                   	pop    %esi
f0104e6a:	5f                   	pop    %edi
f0104e6b:	5d                   	pop    %ebp
f0104e6c:	c3                   	ret    
f0104e6d:	8d 76 00             	lea    0x0(%esi),%esi
f0104e70:	39 e8                	cmp    %ebp,%eax
f0104e72:	77 24                	ja     f0104e98 <__udivdi3+0x78>
f0104e74:	0f bd e8             	bsr    %eax,%ebp
f0104e77:	83 f5 1f             	xor    $0x1f,%ebp
f0104e7a:	75 3c                	jne    f0104eb8 <__udivdi3+0x98>
f0104e7c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104e80:	39 34 24             	cmp    %esi,(%esp)
f0104e83:	0f 86 9f 00 00 00    	jbe    f0104f28 <__udivdi3+0x108>
f0104e89:	39 d0                	cmp    %edx,%eax
f0104e8b:	0f 82 97 00 00 00    	jb     f0104f28 <__udivdi3+0x108>
f0104e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104e98:	31 d2                	xor    %edx,%edx
f0104e9a:	31 c0                	xor    %eax,%eax
f0104e9c:	83 c4 0c             	add    $0xc,%esp
f0104e9f:	5e                   	pop    %esi
f0104ea0:	5f                   	pop    %edi
f0104ea1:	5d                   	pop    %ebp
f0104ea2:	c3                   	ret    
f0104ea3:	90                   	nop
f0104ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ea8:	89 f8                	mov    %edi,%eax
f0104eaa:	f7 f1                	div    %ecx
f0104eac:	31 d2                	xor    %edx,%edx
f0104eae:	83 c4 0c             	add    $0xc,%esp
f0104eb1:	5e                   	pop    %esi
f0104eb2:	5f                   	pop    %edi
f0104eb3:	5d                   	pop    %ebp
f0104eb4:	c3                   	ret    
f0104eb5:	8d 76 00             	lea    0x0(%esi),%esi
f0104eb8:	89 e9                	mov    %ebp,%ecx
f0104eba:	8b 3c 24             	mov    (%esp),%edi
f0104ebd:	d3 e0                	shl    %cl,%eax
f0104ebf:	89 c6                	mov    %eax,%esi
f0104ec1:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ec6:	29 e8                	sub    %ebp,%eax
f0104ec8:	89 c1                	mov    %eax,%ecx
f0104eca:	d3 ef                	shr    %cl,%edi
f0104ecc:	89 e9                	mov    %ebp,%ecx
f0104ece:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104ed2:	8b 3c 24             	mov    (%esp),%edi
f0104ed5:	09 74 24 08          	or     %esi,0x8(%esp)
f0104ed9:	89 d6                	mov    %edx,%esi
f0104edb:	d3 e7                	shl    %cl,%edi
f0104edd:	89 c1                	mov    %eax,%ecx
f0104edf:	89 3c 24             	mov    %edi,(%esp)
f0104ee2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104ee6:	d3 ee                	shr    %cl,%esi
f0104ee8:	89 e9                	mov    %ebp,%ecx
f0104eea:	d3 e2                	shl    %cl,%edx
f0104eec:	89 c1                	mov    %eax,%ecx
f0104eee:	d3 ef                	shr    %cl,%edi
f0104ef0:	09 d7                	or     %edx,%edi
f0104ef2:	89 f2                	mov    %esi,%edx
f0104ef4:	89 f8                	mov    %edi,%eax
f0104ef6:	f7 74 24 08          	divl   0x8(%esp)
f0104efa:	89 d6                	mov    %edx,%esi
f0104efc:	89 c7                	mov    %eax,%edi
f0104efe:	f7 24 24             	mull   (%esp)
f0104f01:	39 d6                	cmp    %edx,%esi
f0104f03:	89 14 24             	mov    %edx,(%esp)
f0104f06:	72 30                	jb     f0104f38 <__udivdi3+0x118>
f0104f08:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104f0c:	89 e9                	mov    %ebp,%ecx
f0104f0e:	d3 e2                	shl    %cl,%edx
f0104f10:	39 c2                	cmp    %eax,%edx
f0104f12:	73 05                	jae    f0104f19 <__udivdi3+0xf9>
f0104f14:	3b 34 24             	cmp    (%esp),%esi
f0104f17:	74 1f                	je     f0104f38 <__udivdi3+0x118>
f0104f19:	89 f8                	mov    %edi,%eax
f0104f1b:	31 d2                	xor    %edx,%edx
f0104f1d:	e9 7a ff ff ff       	jmp    f0104e9c <__udivdi3+0x7c>
f0104f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104f28:	31 d2                	xor    %edx,%edx
f0104f2a:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f2f:	e9 68 ff ff ff       	jmp    f0104e9c <__udivdi3+0x7c>
f0104f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f38:	8d 47 ff             	lea    -0x1(%edi),%eax
f0104f3b:	31 d2                	xor    %edx,%edx
f0104f3d:	83 c4 0c             	add    $0xc,%esp
f0104f40:	5e                   	pop    %esi
f0104f41:	5f                   	pop    %edi
f0104f42:	5d                   	pop    %ebp
f0104f43:	c3                   	ret    
f0104f44:	66 90                	xchg   %ax,%ax
f0104f46:	66 90                	xchg   %ax,%ax
f0104f48:	66 90                	xchg   %ax,%ax
f0104f4a:	66 90                	xchg   %ax,%ax
f0104f4c:	66 90                	xchg   %ax,%ax
f0104f4e:	66 90                	xchg   %ax,%ax

f0104f50 <__umoddi3>:
f0104f50:	55                   	push   %ebp
f0104f51:	57                   	push   %edi
f0104f52:	56                   	push   %esi
f0104f53:	83 ec 14             	sub    $0x14,%esp
f0104f56:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104f5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104f5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104f62:	89 c7                	mov    %eax,%edi
f0104f64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f68:	8b 44 24 30          	mov    0x30(%esp),%eax
f0104f6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104f70:	89 34 24             	mov    %esi,(%esp)
f0104f73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104f77:	85 c0                	test   %eax,%eax
f0104f79:	89 c2                	mov    %eax,%edx
f0104f7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104f7f:	75 17                	jne    f0104f98 <__umoddi3+0x48>
f0104f81:	39 fe                	cmp    %edi,%esi
f0104f83:	76 4b                	jbe    f0104fd0 <__umoddi3+0x80>
f0104f85:	89 c8                	mov    %ecx,%eax
f0104f87:	89 fa                	mov    %edi,%edx
f0104f89:	f7 f6                	div    %esi
f0104f8b:	89 d0                	mov    %edx,%eax
f0104f8d:	31 d2                	xor    %edx,%edx
f0104f8f:	83 c4 14             	add    $0x14,%esp
f0104f92:	5e                   	pop    %esi
f0104f93:	5f                   	pop    %edi
f0104f94:	5d                   	pop    %ebp
f0104f95:	c3                   	ret    
f0104f96:	66 90                	xchg   %ax,%ax
f0104f98:	39 f8                	cmp    %edi,%eax
f0104f9a:	77 54                	ja     f0104ff0 <__umoddi3+0xa0>
f0104f9c:	0f bd e8             	bsr    %eax,%ebp
f0104f9f:	83 f5 1f             	xor    $0x1f,%ebp
f0104fa2:	75 5c                	jne    f0105000 <__umoddi3+0xb0>
f0104fa4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104fa8:	39 3c 24             	cmp    %edi,(%esp)
f0104fab:	0f 87 e7 00 00 00    	ja     f0105098 <__umoddi3+0x148>
f0104fb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104fb5:	29 f1                	sub    %esi,%ecx
f0104fb7:	19 c7                	sbb    %eax,%edi
f0104fb9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fbd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104fc1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104fc5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104fc9:	83 c4 14             	add    $0x14,%esp
f0104fcc:	5e                   	pop    %esi
f0104fcd:	5f                   	pop    %edi
f0104fce:	5d                   	pop    %ebp
f0104fcf:	c3                   	ret    
f0104fd0:	85 f6                	test   %esi,%esi
f0104fd2:	89 f5                	mov    %esi,%ebp
f0104fd4:	75 0b                	jne    f0104fe1 <__umoddi3+0x91>
f0104fd6:	b8 01 00 00 00       	mov    $0x1,%eax
f0104fdb:	31 d2                	xor    %edx,%edx
f0104fdd:	f7 f6                	div    %esi
f0104fdf:	89 c5                	mov    %eax,%ebp
f0104fe1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104fe5:	31 d2                	xor    %edx,%edx
f0104fe7:	f7 f5                	div    %ebp
f0104fe9:	89 c8                	mov    %ecx,%eax
f0104feb:	f7 f5                	div    %ebp
f0104fed:	eb 9c                	jmp    f0104f8b <__umoddi3+0x3b>
f0104fef:	90                   	nop
f0104ff0:	89 c8                	mov    %ecx,%eax
f0104ff2:	89 fa                	mov    %edi,%edx
f0104ff4:	83 c4 14             	add    $0x14,%esp
f0104ff7:	5e                   	pop    %esi
f0104ff8:	5f                   	pop    %edi
f0104ff9:	5d                   	pop    %ebp
f0104ffa:	c3                   	ret    
f0104ffb:	90                   	nop
f0104ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105000:	8b 04 24             	mov    (%esp),%eax
f0105003:	be 20 00 00 00       	mov    $0x20,%esi
f0105008:	89 e9                	mov    %ebp,%ecx
f010500a:	29 ee                	sub    %ebp,%esi
f010500c:	d3 e2                	shl    %cl,%edx
f010500e:	89 f1                	mov    %esi,%ecx
f0105010:	d3 e8                	shr    %cl,%eax
f0105012:	89 e9                	mov    %ebp,%ecx
f0105014:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105018:	8b 04 24             	mov    (%esp),%eax
f010501b:	09 54 24 04          	or     %edx,0x4(%esp)
f010501f:	89 fa                	mov    %edi,%edx
f0105021:	d3 e0                	shl    %cl,%eax
f0105023:	89 f1                	mov    %esi,%ecx
f0105025:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105029:	8b 44 24 10          	mov    0x10(%esp),%eax
f010502d:	d3 ea                	shr    %cl,%edx
f010502f:	89 e9                	mov    %ebp,%ecx
f0105031:	d3 e7                	shl    %cl,%edi
f0105033:	89 f1                	mov    %esi,%ecx
f0105035:	d3 e8                	shr    %cl,%eax
f0105037:	89 e9                	mov    %ebp,%ecx
f0105039:	09 f8                	or     %edi,%eax
f010503b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010503f:	f7 74 24 04          	divl   0x4(%esp)
f0105043:	d3 e7                	shl    %cl,%edi
f0105045:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105049:	89 d7                	mov    %edx,%edi
f010504b:	f7 64 24 08          	mull   0x8(%esp)
f010504f:	39 d7                	cmp    %edx,%edi
f0105051:	89 c1                	mov    %eax,%ecx
f0105053:	89 14 24             	mov    %edx,(%esp)
f0105056:	72 2c                	jb     f0105084 <__umoddi3+0x134>
f0105058:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010505c:	72 22                	jb     f0105080 <__umoddi3+0x130>
f010505e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105062:	29 c8                	sub    %ecx,%eax
f0105064:	19 d7                	sbb    %edx,%edi
f0105066:	89 e9                	mov    %ebp,%ecx
f0105068:	89 fa                	mov    %edi,%edx
f010506a:	d3 e8                	shr    %cl,%eax
f010506c:	89 f1                	mov    %esi,%ecx
f010506e:	d3 e2                	shl    %cl,%edx
f0105070:	89 e9                	mov    %ebp,%ecx
f0105072:	d3 ef                	shr    %cl,%edi
f0105074:	09 d0                	or     %edx,%eax
f0105076:	89 fa                	mov    %edi,%edx
f0105078:	83 c4 14             	add    $0x14,%esp
f010507b:	5e                   	pop    %esi
f010507c:	5f                   	pop    %edi
f010507d:	5d                   	pop    %ebp
f010507e:	c3                   	ret    
f010507f:	90                   	nop
f0105080:	39 d7                	cmp    %edx,%edi
f0105082:	75 da                	jne    f010505e <__umoddi3+0x10e>
f0105084:	8b 14 24             	mov    (%esp),%edx
f0105087:	89 c1                	mov    %eax,%ecx
f0105089:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010508d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0105091:	eb cb                	jmp    f010505e <__umoddi3+0x10e>
f0105093:	90                   	nop
f0105094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105098:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010509c:	0f 82 0f ff ff ff    	jb     f0104fb1 <__umoddi3+0x61>
f01050a2:	e9 1a ff ff ff       	jmp    f0104fc1 <__umoddi3+0x71>
