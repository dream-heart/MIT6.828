
obj/user/divzero:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  800060:	e8 0a 01 00 00       	call   80016f <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80007a:	e8 25 0b 00 00       	call   800ba4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 7d 0a 00 00       	call   800b47 <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	83 c0 01             	add    $0x1,%eax
  8000e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e9:	75 19                	jne    800104 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f2:	00 
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	89 04 24             	mov    %eax,(%esp)
  8000f9:	e8 ea 09 00 00       	call   800ae8 <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800108:	83 c4 14             	add    $0x14,%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  80014a:	e8 8e 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 81 09 00 00       	call   800ae8 <sys_cputs>

	return b.cnt;
}
  800167:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800175:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 87 ff ff ff       	call   80010e <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	75 08                	jne    8001bc <printnum+0x2c>
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ba:	77 59                	ja     800215 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c0:	83 eb 01             	sub    $0x1,%ebx
  8001c3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001dd:	00 
  8001de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e1:	89 04 24             	mov    %eax,(%esp)
  8001e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001eb:	e8 e0 0c 00 00       	call   800ed0 <__udivdi3>
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ff:	89 fa                	mov    %edi,%edx
  800201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800204:	e8 87 ff ff ff       	call   800190 <printnum>
  800209:	eb 11                	jmp    80021c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020f:	89 34 24             	mov    %esi,(%esp)
  800212:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800215:	83 eb 01             	sub    $0x1,%ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f ef                	jg     80020b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 10             	mov    0x10(%ebp),%eax
  800227:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800232:	00 
  800233:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	e8 bb 0d 00 00       	call   801000 <__umoddi3>
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	0f be 80 98 11 80 00 	movsbl 0x801198(%eax),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800256:	83 c4 3c             	add    $0x3c,%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800261:	83 fa 01             	cmp    $0x1,%edx
  800264:	7e 0e                	jle    800274 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	8b 52 04             	mov    0x4(%edx),%edx
  800272:	eb 22                	jmp    800296 <getuint+0x38>
	else if (lflag)
  800274:	85 d2                	test   %edx,%edx
  800276:	74 10                	je     800288 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	eb 0e                	jmp    800296 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a7:	73 0a                	jae    8002b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ac:	88 0a                	mov    %cl,(%edx)
  8002ae:	83 c2 01             	add    $0x1,%edx
  8002b1:	89 10                	mov    %edx,(%eax)
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	e8 02 00 00 00       	call   8002dd <vprintfmt>
	va_end(ap);
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 4c             	sub    $0x4c,%esp
  8002e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002ec:	eb 12                	jmp    800300 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	0f 84 bf 03 00 00    	je     8006b5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8002f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800300:	0f b6 06             	movzbl (%esi),%eax
  800303:	83 c6 01             	add    $0x1,%esi
  800306:	83 f8 25             	cmp    $0x25,%eax
  800309:	75 e3                	jne    8002ee <vprintfmt+0x11>
  80030b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80030f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800316:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80031b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80032a:	eb 2b                	jmp    800357 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800333:	eb 22                	jmp    800357 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80033c:	eb 19                	jmp    800357 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800341:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800348:	eb 0d                	jmp    800357 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	0f b6 16             	movzbl (%esi),%edx
  80035a:	0f b6 c2             	movzbl %dl,%eax
  80035d:	8d 7e 01             	lea    0x1(%esi),%edi
  800360:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800363:	83 ea 23             	sub    $0x23,%edx
  800366:	80 fa 55             	cmp    $0x55,%dl
  800369:	0f 87 28 03 00 00    	ja     800697 <vprintfmt+0x3ba>
  80036f:	0f b6 d2             	movzbl %dl,%edx
  800372:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  800379:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80037c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800383:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800388:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80038b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80038f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800392:	8d 50 d0             	lea    -0x30(%eax),%edx
  800395:	83 fa 09             	cmp    $0x9,%edx
  800398:	77 2f                	ja     8003c9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80039d:	eb e9                	jmp    800388 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 50 04             	lea    0x4(%eax),%edx
  8003a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b0:	eb 1a                	jmp    8003cc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b9:	79 9c                	jns    800357 <vprintfmt+0x7a>
  8003bb:	eb 81                	jmp    80033e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c7:	eb 8e                	jmp    800357 <vprintfmt+0x7a>
  8003c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8003cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d0:	79 85                	jns    800357 <vprintfmt+0x7a>
  8003d2:	e9 73 ff ff ff       	jmp    80034a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003dd:	e9 75 ff ff ff       	jmp    800357 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fa:	e9 01 ff ff ff       	jmp    800300 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 c2                	mov    %eax,%edx
  80040c:	c1 fa 1f             	sar    $0x1f,%edx
  80040f:	31 d0                	xor    %edx,%eax
  800411:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 09             	cmp    $0x9,%eax
  800416:	7f 0b                	jg     800423 <vprintfmt+0x146>
  800418:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	75 23                	jne    800446 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800427:	c7 44 24 08 b0 11 80 	movl   $0x8011b0,0x8(%esp)
  80042e:	00 
  80042f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800433:	8b 7d 08             	mov    0x8(%ebp),%edi
  800436:	89 3c 24             	mov    %edi,(%esp)
  800439:	e8 77 fe ff ff       	call   8002b5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800441:	e9 ba fe ff ff       	jmp    800300 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800446:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044a:	c7 44 24 08 b9 11 80 	movl   $0x8011b9,0x8(%esp)
  800451:	00 
  800452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800456:	8b 7d 08             	mov    0x8(%ebp),%edi
  800459:	89 3c 24             	mov    %edi,(%esp)
  80045c:	e8 54 fe ff ff       	call   8002b5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800464:	e9 97 fe ff ff       	jmp    800300 <vprintfmt+0x23>
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80047d:	85 f6                	test   %esi,%esi
  80047f:	ba a9 11 80 00       	mov    $0x8011a9,%edx
  800484:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800487:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048b:	0f 8e 8c 00 00 00    	jle    80051d <vprintfmt+0x240>
  800491:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800495:	0f 84 82 00 00 00    	je     80051d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049f:	89 34 24             	mov    %esi,(%esp)
  8004a2:	e8 b1 02 00 00       	call   800758 <strnlen>
  8004a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004aa:	29 c2                	sub    %eax,%edx
  8004ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004af:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004b3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004b6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004b9:	89 de                	mov    %ebx,%esi
  8004bb:	89 d3                	mov    %edx,%ebx
  8004bd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	eb 0d                	jmp    8004ce <vprintfmt+0x1f1>
					putch(padc, putdat);
  8004c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c5:	89 3c 24             	mov    %edi,(%esp)
  8004c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	83 eb 01             	sub    $0x1,%ebx
  8004ce:	85 db                	test   %ebx,%ebx
  8004d0:	7f ef                	jg     8004c1 <vprintfmt+0x1e4>
  8004d2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004d5:	89 f3                	mov    %esi,%ebx
  8004d7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8004e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ea:	29 c2                	sub    %eax,%edx
  8004ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ef:	eb 2c                	jmp    80051d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f5:	74 18                	je     80050f <vprintfmt+0x232>
  8004f7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fa:	83 fa 5e             	cmp    $0x5e,%edx
  8004fd:	76 10                	jbe    80050f <vprintfmt+0x232>
					putch('?', putdat);
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050a:	ff 55 08             	call   *0x8(%ebp)
  80050d:	eb 0a                	jmp    800519 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80050f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800519:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80051d:	0f be 06             	movsbl (%esi),%eax
  800520:	83 c6 01             	add    $0x1,%esi
  800523:	85 c0                	test   %eax,%eax
  800525:	74 25                	je     80054c <vprintfmt+0x26f>
  800527:	85 ff                	test   %edi,%edi
  800529:	78 c6                	js     8004f1 <vprintfmt+0x214>
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	79 c1                	jns    8004f1 <vprintfmt+0x214>
  800530:	8b 7d 08             	mov    0x8(%ebp),%edi
  800533:	89 de                	mov    %ebx,%esi
  800535:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800538:	eb 1a                	jmp    800554 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800545:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 08                	jmp    800554 <vprintfmt+0x277>
  80054c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80054f:	89 de                	mov    %ebx,%esi
  800551:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800554:	85 db                	test   %ebx,%ebx
  800556:	7f e2                	jg     80053a <vprintfmt+0x25d>
  800558:	89 7d 08             	mov    %edi,0x8(%ebp)
  80055b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800560:	e9 9b fd ff ff       	jmp    800300 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800565:	83 f9 01             	cmp    $0x1,%ecx
  800568:	7e 10                	jle    80057a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 08             	lea    0x8(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 30                	mov    (%eax),%esi
  800575:	8b 78 04             	mov    0x4(%eax),%edi
  800578:	eb 26                	jmp    8005a0 <vprintfmt+0x2c3>
	else if (lflag)
  80057a:	85 c9                	test   %ecx,%ecx
  80057c:	74 12                	je     800590 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 30                	mov    (%eax),%esi
  800589:	89 f7                	mov    %esi,%edi
  80058b:	c1 ff 1f             	sar    $0x1f,%edi
  80058e:	eb 10                	jmp    8005a0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	0f 89 ac 00 00 00    	jns    800659 <vprintfmt+0x37c>
				putch('-', putdat);
  8005ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bb:	f7 de                	neg    %esi
  8005bd:	83 d7 00             	adc    $0x0,%edi
  8005c0:	f7 df                	neg    %edi
			}
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 8d 00 00 00       	jmp    800659 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 88 fc ff ff       	call   80025e <getuint>
  8005d6:	89 c6                	mov    %eax,%esi
  8005d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005df:	eb 78                	jmp    800659 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ec:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800601:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80060e:	e9 ed fc ff ff       	jmp    800300 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800617:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800625:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800638:	8b 30                	mov    (%eax),%esi
  80063a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800644:	eb 13                	jmp    800659 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800646:	89 ca                	mov    %ecx,%edx
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	e8 0e fc ff ff       	call   80025e <getuint>
  800650:	89 c6                	mov    %eax,%esi
  800652:	89 d7                	mov    %edx,%edi
			base = 16;
  800654:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800659:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80065d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800661:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800664:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066c:	89 34 24             	mov    %esi,(%esp)
  80066f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800673:	89 da                	mov    %ebx,%edx
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	e8 13 fb ff ff       	call   800190 <printnum>
			break;
  80067d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800680:	e9 7b fc ff ff       	jmp    800300 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800692:	e9 69 fc ff ff       	jmp    800300 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a5:	eb 03                	jmp    8006aa <vprintfmt+0x3cd>
  8006a7:	83 ee 01             	sub    $0x1,%esi
  8006aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ae:	75 f7                	jne    8006a7 <vprintfmt+0x3ca>
  8006b0:	e9 4b fc ff ff       	jmp    800300 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b5:	83 c4 4c             	add    $0x4c,%esp
  8006b8:	5b                   	pop    %ebx
  8006b9:	5e                   	pop    %esi
  8006ba:	5f                   	pop    %edi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 28             	sub    $0x28,%esp
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 30                	je     80070e <vsnprintf+0x51>
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	7e 2c                	jle    80070e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 98 02 80 00 	movl   $0x800298,(%esp)
  8006fe:	e8 da fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800703:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800706:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	eb 05                	jmp    800713 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	e8 82 ff ff ff       	call   8006bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    
  80073d:	00 00                	add    %al,(%eax)
	...

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
		n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 d0                	cmp    %edx,%eax
  80076d:	74 06                	je     800775 <strnlen+0x1d>
  80076f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80078a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	84 c9                	test   %cl,%cl
  800792:	75 f2                	jne    800786 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	89 1c 24             	mov    %ebx,(%esp)
  8007a4:	e8 97 ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 bd ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d5:	eb 0f                	jmp    8007e6 <strncpy+0x24>
		*dst++ = *src;
  8007d7:	0f b6 1a             	movzbl (%edx),%ebx
  8007da:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	39 f1                	cmp    %esi,%ecx
  8007e8:	75 ed                	jne    8007d7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	85 d2                	test   %edx,%edx
  800800:	75 0a                	jne    80080c <strlcpy+0x1e>
  800802:	eb 1d                	jmp    800821 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800804:	88 18                	mov    %bl,(%eax)
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080c:	83 ea 01             	sub    $0x1,%edx
  80080f:	74 0b                	je     80081c <strlcpy+0x2e>
  800811:	0f b6 19             	movzbl (%ecx),%ebx
  800814:	84 db                	test   %bl,%bl
  800816:	75 ec                	jne    800804 <strlcpy+0x16>
  800818:	89 c2                	mov    %eax,%edx
  80081a:	eb 02                	jmp    80081e <strlcpy+0x30>
  80081c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80081e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	eb 06                	jmp    800838 <strcmp+0x11>
		p++, q++;
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 04                	je     800843 <strcmp+0x1c>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 ef                	je     800832 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80085a:	eb 09                	jmp    800865 <strncmp+0x18>
		n--, p++, q++;
  80085c:	83 ea 01             	sub    $0x1,%edx
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	85 d2                	test   %edx,%edx
  800867:	74 15                	je     80087e <strncmp+0x31>
  800869:	0f b6 18             	movzbl (%eax),%ebx
  80086c:	84 db                	test   %bl,%bl
  80086e:	74 04                	je     800874 <strncmp+0x27>
  800870:	3a 19                	cmp    (%ecx),%bl
  800872:	74 e8                	je     80085c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 00             	movzbl (%eax),%eax
  800877:	0f b6 11             	movzbl (%ecx),%edx
  80087a:	29 d0                	sub    %edx,%eax
  80087c:	eb 05                	jmp    800883 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	eb 07                	jmp    800899 <strchr+0x13>
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 0f                	je     8008a5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	0f b6 10             	movzbl (%eax),%edx
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f2                	jne    800892 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	eb 07                	jmp    8008ba <strfind+0x13>
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	74 0a                	je     8008c1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 10             	movzbl (%eax),%edx
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f2                	jne    8008b3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 0c             	sub    $0xc,%esp
  8008c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008db:	85 c9                	test   %ecx,%ecx
  8008dd:	74 30                	je     80090f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e5:	75 25                	jne    80090c <memset+0x49>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 20                	jne    80090c <memset+0x49>
		c &= 0xFF;
  8008ec:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ef:	89 d3                	mov    %edx,%ebx
  8008f1:	c1 e3 08             	shl    $0x8,%ebx
  8008f4:	89 d6                	mov    %edx,%esi
  8008f6:	c1 e6 18             	shl    $0x18,%esi
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	c1 e0 10             	shl    $0x10,%eax
  8008fe:	09 f0                	or     %esi,%eax
  800900:	09 d0                	or     %edx,%eax
  800902:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800904:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800907:	fc                   	cld    
  800908:	f3 ab                	rep stos %eax,%es:(%edi)
  80090a:	eb 03                	jmp    80090f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	fc                   	cld    
  80090d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090f:	89 f8                	mov    %edi,%eax
  800911:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800914:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800917:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80091a:	89 ec                	mov    %ebp,%esp
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 08             	sub    $0x8,%esp
  800924:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800927:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800933:	39 c6                	cmp    %eax,%esi
  800935:	73 36                	jae    80096d <memmove+0x4f>
  800937:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	73 2f                	jae    80096d <memmove+0x4f>
		s += n;
		d += n;
  80093e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	f6 c2 03             	test   $0x3,%dl
  800944:	75 1b                	jne    800961 <memmove+0x43>
  800946:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094c:	75 13                	jne    800961 <memmove+0x43>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0e                	jne    800961 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 20                	jmp    80098d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 13                	jne    800988 <memmove+0x6a>
  800975:	a8 03                	test   $0x3,%al
  800977:	75 0f                	jne    800988 <memmove+0x6a>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800990:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800993:	89 ec                	mov    %ebp,%esp
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099d:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	e8 68 ff ff ff       	call   80091e <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	57                   	push   %edi
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cc:	eb 1a                	jmp    8009e8 <memcmp+0x30>
		if (*s1 != *s2)
  8009ce:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
  8009d5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  8009da:	38 c8                	cmp    %cl,%al
  8009dc:	74 0a                	je     8009e8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c0             	movzbl %al,%eax
  8009e1:	0f b6 c9             	movzbl %cl,%ecx
  8009e4:	29 c8                	sub    %ecx,%eax
  8009e6:	eb 09                	jmp    8009f1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	39 da                	cmp    %ebx,%edx
  8009ea:	75 e2                	jne    8009ce <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a04:	eb 07                	jmp    800a0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	38 08                	cmp    %cl,(%eax)
  800a08:	74 07                	je     800a11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	72 f5                	jb     800a06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	eb 03                	jmp    800a24 <strtol+0x11>
		s++;
  800a21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a24:	0f b6 02             	movzbl (%edx),%eax
  800a27:	3c 20                	cmp    $0x20,%al
  800a29:	74 f6                	je     800a21 <strtol+0xe>
  800a2b:	3c 09                	cmp    $0x9,%al
  800a2d:	74 f2                	je     800a21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2f:	3c 2b                	cmp    $0x2b,%al
  800a31:	75 0a                	jne    800a3d <strtol+0x2a>
		s++;
  800a33:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3b:	eb 10                	jmp    800a4d <strtol+0x3a>
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a42:	3c 2d                	cmp    $0x2d,%al
  800a44:	75 07                	jne    800a4d <strtol+0x3a>
		s++, neg = 1;
  800a46:	8d 52 01             	lea    0x1(%edx),%edx
  800a49:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	0f 94 c0             	sete   %al
  800a52:	74 05                	je     800a59 <strtol+0x46>
  800a54:	83 fb 10             	cmp    $0x10,%ebx
  800a57:	75 15                	jne    800a6e <strtol+0x5b>
  800a59:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5c:	75 10                	jne    800a6e <strtol+0x5b>
  800a5e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a62:	75 0a                	jne    800a6e <strtol+0x5b>
		s += 2, base = 16;
  800a64:	83 c2 02             	add    $0x2,%edx
  800a67:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6c:	eb 13                	jmp    800a81 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6e:	84 c0                	test   %al,%al
  800a70:	74 0f                	je     800a81 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a72:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a77:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7a:	75 05                	jne    800a81 <strtol+0x6e>
		s++, base = 8;
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a88:	0f b6 0a             	movzbl (%edx),%ecx
  800a8b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x88>
			dig = *s - '0';
  800a93:	0f be c9             	movsbl %cl,%ecx
  800a96:	83 e9 30             	sub    $0x30,%ecx
  800a99:	eb 1e                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x98>
			dig = *s - 'a' + 10;
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 57             	sub    $0x57,%ecx
  800aa9:	eb 0e                	jmp    800ab9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aab:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 14                	ja     800ac7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ab3:	0f be c9             	movsbl %cl,%ecx
  800ab6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab9:	39 f1                	cmp    %esi,%ecx
  800abb:	7d 0e                	jge    800acb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	0f af c6             	imul   %esi,%eax
  800ac3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ac5:	eb c1                	jmp    800a88 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	89 c1                	mov    %eax,%ecx
  800ac9:	eb 02                	jmp    800acd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 05                	je     800ad8 <strtol+0xc5>
		*endptr = (char *) s;
  800ad3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad8:	89 ca                	mov    %ecx,%edx
  800ada:	f7 da                	neg    %edx
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 45 c2             	cmovne %edx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    
	...

00800ae8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800af1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800af4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
  800b02:	89 c3                	mov    %eax,%ebx
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	89 c6                	mov    %eax,%esi
  800b08:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b13:	89 ec                	mov    %ebp,%esp
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b43:	89 ec                	mov    %ebp,%esp
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 38             	sub    $0x38,%esp
  800b4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7e 28                	jle    800b97 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b73:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7a:	00 
  800b7b:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800b82:	00 
  800b83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8a:	00 
  800b8b:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800b92:	e8 d5 02 00 00       	call   800e6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba0:	89 ec                	mov    %ebp,%esp
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd0:	89 ec                	mov    %ebp,%esp
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_yield>:

void
sys_yield(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bdd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
  800be8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 d7                	mov    %edx,%edi
  800bf3:	89 d6                	mov    %edx,%esi
  800bf5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c00:	89 ec                	mov    %ebp,%esp
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 38             	sub    $0x38,%esp
  800c0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	be 00 00 00 00       	mov    $0x0,%esi
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 28                	jle    800c56 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c32:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c39:	00 
  800c3a:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800c41:	00 
  800c42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c49:	00 
  800c4a:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800c51:	e8 16 02 00 00       	call   800e6c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c59:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c5c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c5f:	89 ec                	mov    %ebp,%esp
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 38             	sub    $0x38,%esp
  800c69:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 28                	jle    800cb4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c90:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c97:	00 
  800c98:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca7:	00 
  800ca8:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800caf:	e8 b8 01 00 00       	call   800e6c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 38             	sub    $0x38,%esp
  800cc7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800d0d:	e8 5a 01 00 00       	call   800e6c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1b:	89 ec                	mov    %ebp,%esp
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 38             	sub    $0x38,%esp
  800d25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 08 00 00 00       	mov    $0x8,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 28                	jle    800d70 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d53:	00 
  800d54:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d63:	00 
  800d64:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800d6b:	e8 fc 00 00 00       	call   800e6c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d70:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d73:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d76:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d79:	89 ec                	mov    %ebp,%esp
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 38             	sub    $0x38,%esp
  800d83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d89:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 09 00 00 00       	mov    $0x9,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800dc9:	e8 9e 00 00 00       	call   800e6c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	be 00 00 00 00       	mov    $0x0,%esi
  800def:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 38             	sub    $0x38,%esp
  800e15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 cb                	mov    %ecx,%ebx
  800e2d:	89 cf                	mov    %ecx,%edi
  800e2f:	89 ce                	mov    %ecx,%esi
  800e31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 28                	jle    800e5f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800e5a:	e8 0d 00 00 00       	call   800e6c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e74:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e77:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e7d:	e8 22 fd ff ff       	call   800ba4 <sys_getenvid>
  800e82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e85:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e98:	c7 04 24 14 14 80 00 	movl   $0x801414,(%esp)
  800e9f:	e8 cb f2 ff ff       	call   80016f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea8:	8b 45 10             	mov    0x10(%ebp),%eax
  800eab:	89 04 24             	mov    %eax,(%esp)
  800eae:	e8 5b f2 ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  800eb3:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800eba:	e8 b0 f2 ff ff       	call   80016f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ebf:	cc                   	int3   
  800ec0:	eb fd                	jmp    800ebf <_panic+0x53>
	...

00800ed0 <__udivdi3>:
  800ed0:	83 ec 1c             	sub    $0x1c,%esp
  800ed3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800ed7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800edb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800edf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ee3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ee7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800eeb:	85 ff                	test   %edi,%edi
  800eed:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef5:	89 cd                	mov    %ecx,%ebp
  800ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efb:	75 33                	jne    800f30 <__udivdi3+0x60>
  800efd:	39 f1                	cmp    %esi,%ecx
  800eff:	77 57                	ja     800f58 <__udivdi3+0x88>
  800f01:	85 c9                	test   %ecx,%ecx
  800f03:	75 0b                	jne    800f10 <__udivdi3+0x40>
  800f05:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0a:	31 d2                	xor    %edx,%edx
  800f0c:	f7 f1                	div    %ecx
  800f0e:	89 c1                	mov    %eax,%ecx
  800f10:	89 f0                	mov    %esi,%eax
  800f12:	31 d2                	xor    %edx,%edx
  800f14:	f7 f1                	div    %ecx
  800f16:	89 c6                	mov    %eax,%esi
  800f18:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f1c:	f7 f1                	div    %ecx
  800f1e:	89 f2                	mov    %esi,%edx
  800f20:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	c3                   	ret    
  800f30:	31 d2                	xor    %edx,%edx
  800f32:	31 c0                	xor    %eax,%eax
  800f34:	39 f7                	cmp    %esi,%edi
  800f36:	77 e8                	ja     800f20 <__udivdi3+0x50>
  800f38:	0f bd cf             	bsr    %edi,%ecx
  800f3b:	83 f1 1f             	xor    $0x1f,%ecx
  800f3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f42:	75 2c                	jne    800f70 <__udivdi3+0xa0>
  800f44:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f48:	76 04                	jbe    800f4e <__udivdi3+0x7e>
  800f4a:	39 f7                	cmp    %esi,%edi
  800f4c:	73 d2                	jae    800f20 <__udivdi3+0x50>
  800f4e:	31 d2                	xor    %edx,%edx
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	eb c9                	jmp    800f20 <__udivdi3+0x50>
  800f57:	90                   	nop
  800f58:	89 f2                	mov    %esi,%edx
  800f5a:	f7 f1                	div    %ecx
  800f5c:	31 d2                	xor    %edx,%edx
  800f5e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f62:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f66:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f6a:	83 c4 1c             	add    $0x1c,%esp
  800f6d:	c3                   	ret    
  800f6e:	66 90                	xchg   %ax,%ax
  800f70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f75:	b8 20 00 00 00       	mov    $0x20,%eax
  800f7a:	89 ea                	mov    %ebp,%edx
  800f7c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f80:	d3 e7                	shl    %cl,%edi
  800f82:	89 c1                	mov    %eax,%ecx
  800f84:	d3 ea                	shr    %cl,%edx
  800f86:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f8b:	09 fa                	or     %edi,%edx
  800f8d:	89 f7                	mov    %esi,%edi
  800f8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f99:	d3 e5                	shl    %cl,%ebp
  800f9b:	89 c1                	mov    %eax,%ecx
  800f9d:	d3 ef                	shr    %cl,%edi
  800f9f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fa4:	d3 e2                	shl    %cl,%edx
  800fa6:	89 c1                	mov    %eax,%ecx
  800fa8:	d3 ee                	shr    %cl,%esi
  800faa:	09 d6                	or     %edx,%esi
  800fac:	89 fa                	mov    %edi,%edx
  800fae:	89 f0                	mov    %esi,%eax
  800fb0:	f7 74 24 0c          	divl   0xc(%esp)
  800fb4:	89 d7                	mov    %edx,%edi
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	f7 e5                	mul    %ebp
  800fba:	39 d7                	cmp    %edx,%edi
  800fbc:	72 22                	jb     800fe0 <__udivdi3+0x110>
  800fbe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800fc2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fc7:	d3 e5                	shl    %cl,%ebp
  800fc9:	39 c5                	cmp    %eax,%ebp
  800fcb:	73 04                	jae    800fd1 <__udivdi3+0x101>
  800fcd:	39 d7                	cmp    %edx,%edi
  800fcf:	74 0f                	je     800fe0 <__udivdi3+0x110>
  800fd1:	89 f0                	mov    %esi,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	e9 46 ff ff ff       	jmp    800f20 <__udivdi3+0x50>
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fe9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ff1:	83 c4 1c             	add    $0x1c,%esp
  800ff4:	c3                   	ret    
	...

00801000 <__umoddi3>:
  801000:	83 ec 1c             	sub    $0x1c,%esp
  801003:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801007:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80100b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80100f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801013:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801017:	8b 74 24 24          	mov    0x24(%esp),%esi
  80101b:	85 ed                	test   %ebp,%ebp
  80101d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801021:	89 44 24 08          	mov    %eax,0x8(%esp)
  801025:	89 cf                	mov    %ecx,%edi
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	89 f2                	mov    %esi,%edx
  80102c:	75 1a                	jne    801048 <__umoddi3+0x48>
  80102e:	39 f1                	cmp    %esi,%ecx
  801030:	76 4e                	jbe    801080 <__umoddi3+0x80>
  801032:	f7 f1                	div    %ecx
  801034:	89 d0                	mov    %edx,%eax
  801036:	31 d2                	xor    %edx,%edx
  801038:	8b 74 24 10          	mov    0x10(%esp),%esi
  80103c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801040:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801044:	83 c4 1c             	add    $0x1c,%esp
  801047:	c3                   	ret    
  801048:	39 f5                	cmp    %esi,%ebp
  80104a:	77 54                	ja     8010a0 <__umoddi3+0xa0>
  80104c:	0f bd c5             	bsr    %ebp,%eax
  80104f:	83 f0 1f             	xor    $0x1f,%eax
  801052:	89 44 24 04          	mov    %eax,0x4(%esp)
  801056:	75 60                	jne    8010b8 <__umoddi3+0xb8>
  801058:	3b 0c 24             	cmp    (%esp),%ecx
  80105b:	0f 87 07 01 00 00    	ja     801168 <__umoddi3+0x168>
  801061:	89 f2                	mov    %esi,%edx
  801063:	8b 34 24             	mov    (%esp),%esi
  801066:	29 ce                	sub    %ecx,%esi
  801068:	19 ea                	sbb    %ebp,%edx
  80106a:	89 34 24             	mov    %esi,(%esp)
  80106d:	8b 04 24             	mov    (%esp),%eax
  801070:	8b 74 24 10          	mov    0x10(%esp),%esi
  801074:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801078:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80107c:	83 c4 1c             	add    $0x1c,%esp
  80107f:	c3                   	ret    
  801080:	85 c9                	test   %ecx,%ecx
  801082:	75 0b                	jne    80108f <__umoddi3+0x8f>
  801084:	b8 01 00 00 00       	mov    $0x1,%eax
  801089:	31 d2                	xor    %edx,%edx
  80108b:	f7 f1                	div    %ecx
  80108d:	89 c1                	mov    %eax,%ecx
  80108f:	89 f0                	mov    %esi,%eax
  801091:	31 d2                	xor    %edx,%edx
  801093:	f7 f1                	div    %ecx
  801095:	8b 04 24             	mov    (%esp),%eax
  801098:	f7 f1                	div    %ecx
  80109a:	eb 98                	jmp    801034 <__umoddi3+0x34>
  80109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	89 f2                	mov    %esi,%edx
  8010a2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010aa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ae:	83 c4 1c             	add    $0x1c,%esp
  8010b1:	c3                   	ret    
  8010b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010bd:	89 e8                	mov    %ebp,%eax
  8010bf:	bd 20 00 00 00       	mov    $0x20,%ebp
  8010c4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8010c8:	89 fa                	mov    %edi,%edx
  8010ca:	d3 e0                	shl    %cl,%eax
  8010cc:	89 e9                	mov    %ebp,%ecx
  8010ce:	d3 ea                	shr    %cl,%edx
  8010d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010d5:	09 c2                	or     %eax,%edx
  8010d7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010db:	89 14 24             	mov    %edx,(%esp)
  8010de:	89 f2                	mov    %esi,%edx
  8010e0:	d3 e7                	shl    %cl,%edi
  8010e2:	89 e9                	mov    %ebp,%ecx
  8010e4:	d3 ea                	shr    %cl,%edx
  8010e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	d3 e6                	shl    %cl,%esi
  8010f1:	89 e9                	mov    %ebp,%ecx
  8010f3:	d3 e8                	shr    %cl,%eax
  8010f5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010fa:	09 f0                	or     %esi,%eax
  8010fc:	8b 74 24 08          	mov    0x8(%esp),%esi
  801100:	f7 34 24             	divl   (%esp)
  801103:	d3 e6                	shl    %cl,%esi
  801105:	89 74 24 08          	mov    %esi,0x8(%esp)
  801109:	89 d6                	mov    %edx,%esi
  80110b:	f7 e7                	mul    %edi
  80110d:	39 d6                	cmp    %edx,%esi
  80110f:	89 c1                	mov    %eax,%ecx
  801111:	89 d7                	mov    %edx,%edi
  801113:	72 3f                	jb     801154 <__umoddi3+0x154>
  801115:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801119:	72 35                	jb     801150 <__umoddi3+0x150>
  80111b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80111f:	29 c8                	sub    %ecx,%eax
  801121:	19 fe                	sbb    %edi,%esi
  801123:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801128:	89 f2                	mov    %esi,%edx
  80112a:	d3 e8                	shr    %cl,%eax
  80112c:	89 e9                	mov    %ebp,%ecx
  80112e:	d3 e2                	shl    %cl,%edx
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	09 d0                	or     %edx,%eax
  801137:	89 f2                	mov    %esi,%edx
  801139:	d3 ea                	shr    %cl,%edx
  80113b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80113f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801143:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801147:	83 c4 1c             	add    $0x1c,%esp
  80114a:	c3                   	ret    
  80114b:	90                   	nop
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	39 d6                	cmp    %edx,%esi
  801152:	75 c7                	jne    80111b <__umoddi3+0x11b>
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 c1                	mov    %eax,%ecx
  801158:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80115c:	1b 3c 24             	sbb    (%esp),%edi
  80115f:	eb ba                	jmp    80111b <__umoddi3+0x11b>
  801161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801168:	39 f5                	cmp    %esi,%ebp
  80116a:	0f 82 f1 fe ff ff    	jb     801061 <__umoddi3+0x61>
  801170:	e9 f8 fe ff ff       	jmp    80106d <__umoddi3+0x6d>
