
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	89 44 24 04          	mov    %eax,0x4(%esp)
  800054:	c7 04 24 c0 0e 80 00 	movl   $0x800ec0,(%esp)
  80005b:	e8 04 01 00 00       	call   800164 <cprintf>
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 10             	sub    $0x10,%esp
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800070:	e8 40 0b 00 00       	call   800bb5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007d:	c1 e0 05             	shl    $0x5,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 20 80 00       	mov    %eax,0x802008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x33>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	89 74 24 04          	mov    %esi,0x4(%esp)
  800099:	89 1c 24             	mov    %ebx,(%esp)
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 07 00 00 00       	call   8000ad <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 a4 0a 00 00       	call   800b63 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 14             	sub    $0x14,%esp
  8000c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cb:	8b 13                	mov    (%ebx),%edx
  8000cd:	8d 42 01             	lea    0x1(%edx),%eax
  8000d0:	89 03                	mov    %eax,(%ebx)
  8000d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000de:	75 19                	jne    8000f9 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e7:	00 
  8000e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000eb:	89 04 24             	mov    %eax,(%esp)
  8000ee:	e8 33 0a 00 00       	call   800b26 <sys_cputs>
		b->idx = 0;
  8000f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c1 00 80 00 	movl   $0x8000c1,(%esp)
  80013f:	e8 70 01 00 00       	call   8002b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 ca 09 00 00       	call   800b26 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
  80017e:	66 90                	xchg   %ax,%ax

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 c3                	mov    %eax,%ebx
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	39 d9                	cmp    %ebx,%ecx
  8001af:	72 05                	jb     8001b6 <printnum+0x36>
  8001b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001bd:	83 ee 01             	sub    $0x1,%esi
  8001c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d0:	89 c3                	mov    %eax,%ebx
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	e8 3c 0a 00 00       	call   800c30 <__udivdi3>
  8001f4:	89 d9                	mov    %ebx,%ecx
  8001f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	89 54 24 04          	mov    %edx,0x4(%esp)
  800205:	89 fa                	mov    %edi,%edx
  800207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020a:	e8 71 ff ff ff       	call   800180 <printnum>
  80020f:	eb 1b                	jmp    80022c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800215:	8b 45 18             	mov    0x18(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff d3                	call   *%ebx
  80021d:	eb 03                	jmp    800222 <printnum+0xa2>
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 ee 01             	sub    $0x1,%esi
  800225:	85 f6                	test   %esi,%esi
  800227:	7f e8                	jg     800211 <printnum+0x91>
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800230:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800237:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 0c 0b 00 00       	call   800d60 <__umoddi3>
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	0f be 80 d8 0e 80 00 	movsbl 0x800ed8(%eax),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800265:	ff d0                	call   *%eax
}
  800267:	83 c4 3c             	add    $0x3c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1b>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	89 04 24             	mov    %eax,(%esp)
  8002ad:	e8 02 00 00 00       	call   8002b4 <vprintfmt>
	va_end(ap);
}
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 3c             	sub    $0x3c,%esp
  8002bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c6:	eb 11                	jmp    8002d9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 84 48 04 00 00    	je     800718 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8002d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d9:	83 c7 01             	add    $0x1,%edi
  8002dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e0:	83 f8 25             	cmp    $0x25,%eax
  8002e3:	75 e3                	jne    8002c8 <vprintfmt+0x14>
  8002e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800303:	eb 1f                	jmp    800324 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800308:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030c:	eb 16                	jmp    800324 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800311:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800315:	eb 0d                	jmp    800324 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800317:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80031a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 17             	movzbl (%edi),%edx
  80032d:	0f b6 c2             	movzbl %dl,%eax
  800330:	83 ea 23             	sub    $0x23,%edx
  800333:	80 fa 55             	cmp    $0x55,%dl
  800336:	0f 87 bf 03 00 00    	ja     8006fb <vprintfmt+0x447>
  80033c:	0f b6 d2             	movzbl %dl,%edx
  80033f:	ff 24 95 80 0f 80 00 	jmp    *0x800f80(,%edx,4)
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800351:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800354:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800358:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80035b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80035e:	83 f9 09             	cmp    $0x9,%ecx
  800361:	77 3c                	ja     80039f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800363:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800366:	eb e9                	jmp    800351 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8b 00                	mov    (%eax),%eax
  80036d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 40 04             	lea    0x4(%eax),%eax
  800376:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037c:	eb 27                	jmp    8003a5 <vprintfmt+0xf1>
  80037e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800381:	85 d2                	test   %edx,%edx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	0f 49 c2             	cmovns %edx,%eax
  80038b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	eb 91                	jmp    800324 <vprintfmt+0x70>
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039d:	eb 85                	jmp    800324 <vprintfmt+0x70>
  80039f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a9:	0f 89 75 ff ff ff    	jns    800324 <vprintfmt+0x70>
  8003af:	e9 63 ff ff ff       	jmp    800317 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ba:	e9 65 ff ff ff       	jmp    800324 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 00 ff ff ff       	jmp    8002d9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003dc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	99                   	cltd   
  8003e3:	31 d0                	xor    %edx,%eax
  8003e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e7:	83 f8 07             	cmp    $0x7,%eax
  8003ea:	7f 0b                	jg     8003f7 <vprintfmt+0x143>
  8003ec:	8b 14 85 e0 10 80 00 	mov    0x8010e0(,%eax,4),%edx
  8003f3:	85 d2                	test   %edx,%edx
  8003f5:	75 20                	jne    800417 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8003f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fb:	c7 44 24 08 f0 0e 80 	movl   $0x800ef0,0x8(%esp)
  800402:	00 
  800403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800407:	89 34 24             	mov    %esi,(%esp)
  80040a:	e8 7d fe ff ff       	call   80028c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800412:	e9 c2 fe ff ff       	jmp    8002d9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800417:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041b:	c7 44 24 08 f9 0e 80 	movl   $0x800ef9,0x8(%esp)
  800422:	00 
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 34 24             	mov    %esi,(%esp)
  80042a:	e8 5d fe ff ff       	call   80028c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800432:	e9 a2 fe ff ff       	jmp    8002d9 <vprintfmt+0x25>
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80043d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800440:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800447:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800449:	85 ff                	test   %edi,%edi
  80044b:	b8 e9 0e 80 00       	mov    $0x800ee9,%eax
  800450:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800453:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800457:	0f 84 92 00 00 00    	je     8004ef <vprintfmt+0x23b>
  80045d:	85 c9                	test   %ecx,%ecx
  80045f:	0f 8e 98 00 00 00    	jle    8004fd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	89 54 24 04          	mov    %edx,0x4(%esp)
  800469:	89 3c 24             	mov    %edi,(%esp)
  80046c:	e8 47 03 00 00       	call   8007b8 <strnlen>
  800471:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800474:	29 c1                	sub    %eax,%ecx
  800476:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800479:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800480:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800483:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	eb 0f                	jmp    800496 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800487:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	83 ef 01             	sub    $0x1,%edi
  800496:	85 ff                	test   %edi,%edi
  800498:	7f ed                	jg     800487 <vprintfmt+0x1d3>
  80049a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a0:	85 c9                	test   %ecx,%ecx
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	0f 49 c1             	cmovns %ecx,%eax
  8004aa:	29 c1                	sub    %eax,%ecx
  8004ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8004af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b5:	89 cb                	mov    %ecx,%ebx
  8004b7:	eb 50                	jmp    800509 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bd:	74 1e                	je     8004dd <vprintfmt+0x229>
  8004bf:	0f be d2             	movsbl %dl,%edx
  8004c2:	83 ea 20             	sub    $0x20,%edx
  8004c5:	83 fa 5e             	cmp    $0x5e,%edx
  8004c8:	76 13                	jbe    8004dd <vprintfmt+0x229>
					putch('?', putdat);
  8004ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d8:	ff 55 08             	call   *0x8(%ebp)
  8004db:	eb 0d                	jmp    8004ea <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8004dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	eb 1a                	jmp    800509 <vprintfmt+0x255>
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fb:	eb 0c                	jmp    800509 <vprintfmt+0x255>
  8004fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800506:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800509:	83 c7 01             	add    $0x1,%edi
  80050c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800510:	0f be c2             	movsbl %dl,%eax
  800513:	85 c0                	test   %eax,%eax
  800515:	74 25                	je     80053c <vprintfmt+0x288>
  800517:	85 f6                	test   %esi,%esi
  800519:	78 9e                	js     8004b9 <vprintfmt+0x205>
  80051b:	83 ee 01             	sub    $0x1,%esi
  80051e:	79 99                	jns    8004b9 <vprintfmt+0x205>
  800520:	89 df                	mov    %ebx,%edi
  800522:	8b 75 08             	mov    0x8(%ebp),%esi
  800525:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800528:	eb 1a                	jmp    800544 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800535:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	83 ef 01             	sub    $0x1,%edi
  80053a:	eb 08                	jmp    800544 <vprintfmt+0x290>
  80053c:	89 df                	mov    %ebx,%edi
  80053e:	8b 75 08             	mov    0x8(%ebp),%esi
  800541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800544:	85 ff                	test   %edi,%edi
  800546:	7f e2                	jg     80052a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054b:	e9 89 fd ff ff       	jmp    8002d9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800550:	83 f9 01             	cmp    $0x1,%ecx
  800553:	7e 19                	jle    80056e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 50 04             	mov    0x4(%eax),%edx
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 08             	lea    0x8(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	eb 38                	jmp    8005a6 <vprintfmt+0x2f2>
	else if (lflag)
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	74 1b                	je     80058d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	89 c1                	mov    %eax,%ecx
  80057c:	c1 f9 1f             	sar    $0x1f,%ecx
  80057f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
  80058b:	eb 19                	jmp    8005a6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800595:	89 c1                	mov    %eax,%ecx
  800597:	c1 f9 1f             	sar    $0x1f,%ecx
  80059a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 40 04             	lea    0x4(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b5:	0f 89 04 01 00 00    	jns    8006bf <vprintfmt+0x40b>
				putch('-', putdat);
  8005bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ce:	f7 da                	neg    %edx
  8005d0:	83 d1 00             	adc    $0x0,%ecx
  8005d3:	f7 d9                	neg    %ecx
  8005d5:	e9 e5 00 00 00       	jmp    8006bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005da:	83 f9 01             	cmp    $0x1,%ecx
  8005dd:	7e 10                	jle    8005ef <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ed:	eb 26                	jmp    800615 <vprintfmt+0x361>
	else if (lflag)
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	74 12                	je     800605 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	eb 10                	jmp    800615 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800615:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80061a:	e9 a0 00 00 00       	jmp    8006bf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80062a:	ff d6                	call   *%esi
			putch('X', putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800637:	ff d6                	call   *%esi
			putch('X', putdat);
  800639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800644:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800649:	e9 8b fc ff ff       	jmp    8002d9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800659:	ff d6                	call   *%esi
			putch('x', putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800666:	ff d6                	call   *%esi
			num = (unsigned long long)
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800678:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80067d:	eb 40                	jmp    8006bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067f:	83 f9 01             	cmp    $0x1,%ecx
  800682:	7e 10                	jle    800694 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	8b 48 04             	mov    0x4(%eax),%ecx
  80068c:	8d 40 08             	lea    0x8(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
  800692:	eb 26                	jmp    8006ba <vprintfmt+0x406>
	else if (lflag)
  800694:	85 c9                	test   %ecx,%ecx
  800696:	74 12                	je     8006aa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a8:	eb 10                	jmp    8006ba <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ba:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8006d2:	89 14 24             	mov    %edx,(%esp)
  8006d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006d9:	89 da                	mov    %ebx,%edx
  8006db:	89 f0                	mov    %esi,%eax
  8006dd:	e8 9e fa ff ff       	call   800180 <printnum>
			break;
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 ef fb ff ff       	jmp    8002d9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	89 04 24             	mov    %eax,(%esp)
  8006f1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f6:	e9 de fb ff ff       	jmp    8002d9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800706:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	eb 03                	jmp    80070d <vprintfmt+0x459>
  80070a:	83 ef 01             	sub    $0x1,%edi
  80070d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800711:	75 f7                	jne    80070a <vprintfmt+0x456>
  800713:	e9 c1 fb ff ff       	jmp    8002d9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800718:	83 c4 3c             	add    $0x3c,%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 28             	sub    $0x28,%esp
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800733:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 30                	je     800771 <vsnprintf+0x51>
  800741:	85 d2                	test   %edx,%edx
  800743:	7e 2c                	jle    800771 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074c:	8b 45 10             	mov    0x10(%ebp),%eax
  80074f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800753:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075a:	c7 04 24 6f 02 80 00 	movl   $0x80026f,(%esp)
  800761:	e8 4e fb ff ff       	call   8002b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800766:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800769:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076f:	eb 05                	jmp    800776 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800785:	8b 45 10             	mov    0x10(%ebp),%eax
  800788:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	89 04 24             	mov    %eax,(%esp)
  800799:	e8 82 ff ff ff       	call   800720 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	eb 03                	jmp    8007b0 <strlen+0x10>
		n++;
  8007ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b4:	75 f7                	jne    8007ad <strlen+0xd>
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 03                	jmp    8007cb <strnlen+0x13>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	39 d0                	cmp    %edx,%eax
  8007cd:	74 06                	je     8007d5 <strnlen+0x1d>
  8007cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d3:	75 f3                	jne    8007c8 <strnlen+0x10>
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c1 01             	add    $0x1,%ecx
  8007e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 ef                	jne    8007e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800801:	89 1c 24             	mov    %ebx,(%esp)
  800804:	e8 97 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800810:	01 d8                	add    %ebx,%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 bd ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  80081a:	89 d8                	mov    %ebx,%eax
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 75 08             	mov    0x8(%ebp),%esi
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	89 f3                	mov    %esi,%ebx
  80082f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 0f                	jmp    800845 <strncpy+0x23>
		*dst++ = *src;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083f:	80 39 01             	cmpb   $0x1,(%ecx)
  800842:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	39 da                	cmp    %ebx,%edx
  800847:	75 ed                	jne    800836 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800849:	89 f0                	mov    %esi,%eax
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 75 08             	mov    0x8(%ebp),%esi
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80085d:	89 f0                	mov    %esi,%eax
  80085f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800863:	85 c9                	test   %ecx,%ecx
  800865:	75 0b                	jne    800872 <strlcpy+0x23>
  800867:	eb 1d                	jmp    800886 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800872:	39 d8                	cmp    %ebx,%eax
  800874:	74 0b                	je     800881 <strlcpy+0x32>
  800876:	0f b6 0a             	movzbl (%edx),%ecx
  800879:	84 c9                	test   %cl,%cl
  80087b:	75 ec                	jne    800869 <strlcpy+0x1a>
  80087d:	89 c2                	mov    %eax,%edx
  80087f:	eb 02                	jmp    800883 <strlcpy+0x34>
  800881:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800883:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800886:	29 f0                	sub    %esi,%eax
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800895:	eb 06                	jmp    80089d <strcmp+0x11>
		p++, q++;
  800897:	83 c1 01             	add    $0x1,%ecx
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089d:	0f b6 01             	movzbl (%ecx),%eax
  8008a0:	84 c0                	test   %al,%al
  8008a2:	74 04                	je     8008a8 <strcmp+0x1c>
  8008a4:	3a 02                	cmp    (%edx),%al
  8008a6:	74 ef                	je     800897 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 c0             	movzbl %al,%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c1:	eb 06                	jmp    8008c9 <strncmp+0x17>
		n--, p++, q++;
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	39 d8                	cmp    %ebx,%eax
  8008cb:	74 15                	je     8008e2 <strncmp+0x30>
  8008cd:	0f b6 08             	movzbl (%eax),%ecx
  8008d0:	84 c9                	test   %cl,%cl
  8008d2:	74 04                	je     8008d8 <strncmp+0x26>
  8008d4:	3a 0a                	cmp    (%edx),%cl
  8008d6:	74 eb                	je     8008c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 00             	movzbl (%eax),%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
  8008e0:	eb 05                	jmp    8008e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f4:	eb 07                	jmp    8008fd <strchr+0x13>
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 0f                	je     800909 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	75 f2                	jne    8008f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	eb 07                	jmp    80091e <strfind+0x13>
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	74 0a                	je     800925 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	84 d2                	test   %dl,%dl
  800923:	75 f2                	jne    800917 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 36                	je     80096d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800937:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093d:	75 28                	jne    800967 <memset+0x40>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 23                	jne    800967 <memset+0x40>
		c &= 0xFF;
  800944:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 08             	shl    $0x8,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 18             	shl    $0x18,%esi
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 10             	shl    $0x10,%eax
  800957:	09 f0                	or     %esi,%eax
  800959:	09 c2                	or     %eax,%edx
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800962:	fc                   	cld    
  800963:	f3 ab                	rep stos %eax,%es:(%edi)
  800965:	eb 06                	jmp    80096d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 35                	jae    8009bb <memmove+0x47>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2e                	jae    8009bb <memmove+0x47>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800990:	89 d6                	mov    %edx,%esi
  800992:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099a:	75 13                	jne    8009af <memmove+0x3b>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0e                	jne    8009af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1d                	jmp    8009d8 <memmove+0x64>
  8009bb:	89 f2                	mov    %esi,%edx
  8009bd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	f6 c2 03             	test   $0x3,%dl
  8009c2:	75 0f                	jne    8009d3 <memmove+0x5f>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 0a                	jne    8009d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d1:	eb 05                	jmp    8009d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d3:	89 c7                	mov    %eax,%edi
  8009d5:	fc                   	cld    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 79 ff ff ff       	call   800974 <memmove>
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 55 08             	mov    0x8(%ebp),%edx
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a08:	89 d6                	mov    %edx,%esi
  800a0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	eb 1a                	jmp    800a29 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0f:	0f b6 02             	movzbl (%edx),%eax
  800a12:	0f b6 19             	movzbl (%ecx),%ebx
  800a15:	38 d8                	cmp    %bl,%al
  800a17:	74 0a                	je     800a23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 db             	movzbl %bl,%ebx
  800a1f:	29 d8                	sub    %ebx,%eax
  800a21:	eb 0f                	jmp    800a32 <memcmp+0x35>
		s1++, s2++;
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 f2                	cmp    %esi,%edx
  800a2b:	75 e2                	jne    800a0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3f:	89 c2                	mov    %eax,%edx
  800a41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a44:	eb 07                	jmp    800a4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 07                	je     800a51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	39 d0                	cmp    %edx,%eax
  800a4f:	72 f5                	jb     800a46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x11>
		s++;
  800a61:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 0a             	movzbl (%edx),%ecx
  800a67:	80 f9 09             	cmp    $0x9,%cl
  800a6a:	74 f5                	je     800a61 <strtol+0xe>
  800a6c:	80 f9 20             	cmp    $0x20,%cl
  800a6f:	74 f0                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a71:	80 f9 2b             	cmp    $0x2b,%cl
  800a74:	75 0a                	jne    800a80 <strtol+0x2d>
		s++;
  800a76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb 11                	jmp    800a91 <strtol+0x3e>
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	80 f9 2d             	cmp    $0x2d,%cl
  800a88:	75 07                	jne    800a91 <strtol+0x3e>
		s++, neg = 1;
  800a8a:	8d 52 01             	lea    0x1(%edx),%edx
  800a8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a96:	75 15                	jne    800aad <strtol+0x5a>
  800a98:	80 3a 30             	cmpb   $0x30,(%edx)
  800a9b:	75 10                	jne    800aad <strtol+0x5a>
  800a9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa1:	75 0a                	jne    800aad <strtol+0x5a>
		s += 2, base = 16;
  800aa3:	83 c2 02             	add    $0x2,%edx
  800aa6:	b8 10 00 00 00       	mov    $0x10,%eax
  800aab:	eb 10                	jmp    800abd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	75 0c                	jne    800abd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ab6:	75 05                	jne    800abd <strtol+0x6a>
		s++, base = 8;
  800ab8:	83 c2 01             	add    $0x1,%edx
  800abb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800abd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ac2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac5:	0f b6 0a             	movzbl (%edx),%ecx
  800ac8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800acb:	89 f0                	mov    %esi,%eax
  800acd:	3c 09                	cmp    $0x9,%al
  800acf:	77 08                	ja     800ad9 <strtol+0x86>
			dig = *s - '0';
  800ad1:	0f be c9             	movsbl %cl,%ecx
  800ad4:	83 e9 30             	sub    $0x30,%ecx
  800ad7:	eb 20                	jmp    800af9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ad9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800adc:	89 f0                	mov    %esi,%eax
  800ade:	3c 19                	cmp    $0x19,%al
  800ae0:	77 08                	ja     800aea <strtol+0x97>
			dig = *s - 'a' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 57             	sub    $0x57,%ecx
  800ae8:	eb 0f                	jmp    800af9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800aed:	89 f0                	mov    %esi,%eax
  800aef:	3c 19                	cmp    $0x19,%al
  800af1:	77 16                	ja     800b09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800af3:	0f be c9             	movsbl %cl,%ecx
  800af6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800afc:	7d 0f                	jge    800b0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800afe:	83 c2 01             	add    $0x1,%edx
  800b01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b07:	eb bc                	jmp    800ac5 <strtol+0x72>
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	eb 02                	jmp    800b0f <strtol+0xbc>
  800b0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b13:	74 05                	je     800b1a <strtol+0xc7>
		*endptr = (char *) s;
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b1a:	f7 d8                	neg    %eax
  800b1c:	85 ff                	test   %edi,%edi
  800b1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	89 c6                	mov    %eax,%esi
  800b3d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b71:	b8 03 00 00 00       	mov    $0x3,%eax
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 cb                	mov    %ecx,%ebx
  800b7b:	89 cf                	mov    %ecx,%edi
  800b7d:	89 ce                	mov    %ecx,%esi
  800b7f:	cd 30                	int    $0x30
		: "cc", "memory");
	//D EDI,
	//S  ESI 
	//"memory""
	//代表不使用寄存器作为缓存存储变量，2.不打乱执行顺序
	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7e 28                	jle    800bad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b90:	00 
  800b91:	c7 44 24 08 00 11 80 	movl   $0x801100,0x8(%esp)
  800b98:	00 
  800b99:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800ba0:	00 
  800ba1:	c7 04 24 1d 11 80 00 	movl   $0x80111d,(%esp)
  800ba8:	e8 27 00 00 00       	call   800bd4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bad:	83 c4 2c             	add    $0x2c,%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc5:	89 d1                	mov    %edx,%ecx
  800bc7:	89 d3                	mov    %edx,%ebx
  800bc9:	89 d7                	mov    %edx,%edi
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800bdc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bdf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800be5:	e8 cb ff ff ff       	call   800bb5 <sys_getenvid>
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bed:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bf8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c00:	c7 04 24 2c 11 80 00 	movl   $0x80112c,(%esp)
  800c07:	e8 58 f5 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c10:	8b 45 10             	mov    0x10(%ebp),%eax
  800c13:	89 04 24             	mov    %eax,(%esp)
  800c16:	e8 e8 f4 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800c1b:	c7 04 24 cc 0e 80 00 	movl   $0x800ecc,(%esp)
  800c22:	e8 3d f5 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c27:	cc                   	int3   
  800c28:	eb fd                	jmp    800c27 <_panic+0x53>
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800c3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c46:	85 c0                	test   %eax,%eax
  800c48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c4c:	89 ea                	mov    %ebp,%edx
  800c4e:	89 0c 24             	mov    %ecx,(%esp)
  800c51:	75 2d                	jne    800c80 <__udivdi3+0x50>
  800c53:	39 e9                	cmp    %ebp,%ecx
  800c55:	77 61                	ja     800cb8 <__udivdi3+0x88>
  800c57:	85 c9                	test   %ecx,%ecx
  800c59:	89 ce                	mov    %ecx,%esi
  800c5b:	75 0b                	jne    800c68 <__udivdi3+0x38>
  800c5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c62:	31 d2                	xor    %edx,%edx
  800c64:	f7 f1                	div    %ecx
  800c66:	89 c6                	mov    %eax,%esi
  800c68:	31 d2                	xor    %edx,%edx
  800c6a:	89 e8                	mov    %ebp,%eax
  800c6c:	f7 f6                	div    %esi
  800c6e:	89 c5                	mov    %eax,%ebp
  800c70:	89 f8                	mov    %edi,%eax
  800c72:	f7 f6                	div    %esi
  800c74:	89 ea                	mov    %ebp,%edx
  800c76:	83 c4 0c             	add    $0xc,%esp
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
  800c7d:	8d 76 00             	lea    0x0(%esi),%esi
  800c80:	39 e8                	cmp    %ebp,%eax
  800c82:	77 24                	ja     800ca8 <__udivdi3+0x78>
  800c84:	0f bd e8             	bsr    %eax,%ebp
  800c87:	83 f5 1f             	xor    $0x1f,%ebp
  800c8a:	75 3c                	jne    800cc8 <__udivdi3+0x98>
  800c8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c90:	39 34 24             	cmp    %esi,(%esp)
  800c93:	0f 86 9f 00 00 00    	jbe    800d38 <__udivdi3+0x108>
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	0f 82 97 00 00 00    	jb     800d38 <__udivdi3+0x108>
  800ca1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	31 c0                	xor    %eax,%eax
  800cac:	83 c4 0c             	add    $0xc,%esp
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
  800cb3:	90                   	nop
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	89 f8                	mov    %edi,%eax
  800cba:	f7 f1                	div    %ecx
  800cbc:	31 d2                	xor    %edx,%edx
  800cbe:	83 c4 0c             	add    $0xc,%esp
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
  800cc5:	8d 76 00             	lea    0x0(%esi),%esi
  800cc8:	89 e9                	mov    %ebp,%ecx
  800cca:	8b 3c 24             	mov    (%esp),%edi
  800ccd:	d3 e0                	shl    %cl,%eax
  800ccf:	89 c6                	mov    %eax,%esi
  800cd1:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd6:	29 e8                	sub    %ebp,%eax
  800cd8:	89 c1                	mov    %eax,%ecx
  800cda:	d3 ef                	shr    %cl,%edi
  800cdc:	89 e9                	mov    %ebp,%ecx
  800cde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce2:	8b 3c 24             	mov    (%esp),%edi
  800ce5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ce9:	89 d6                	mov    %edx,%esi
  800ceb:	d3 e7                	shl    %cl,%edi
  800ced:	89 c1                	mov    %eax,%ecx
  800cef:	89 3c 24             	mov    %edi,(%esp)
  800cf2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cf6:	d3 ee                	shr    %cl,%esi
  800cf8:	89 e9                	mov    %ebp,%ecx
  800cfa:	d3 e2                	shl    %cl,%edx
  800cfc:	89 c1                	mov    %eax,%ecx
  800cfe:	d3 ef                	shr    %cl,%edi
  800d00:	09 d7                	or     %edx,%edi
  800d02:	89 f2                	mov    %esi,%edx
  800d04:	89 f8                	mov    %edi,%eax
  800d06:	f7 74 24 08          	divl   0x8(%esp)
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	f7 24 24             	mull   (%esp)
  800d11:	39 d6                	cmp    %edx,%esi
  800d13:	89 14 24             	mov    %edx,(%esp)
  800d16:	72 30                	jb     800d48 <__udivdi3+0x118>
  800d18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d1c:	89 e9                	mov    %ebp,%ecx
  800d1e:	d3 e2                	shl    %cl,%edx
  800d20:	39 c2                	cmp    %eax,%edx
  800d22:	73 05                	jae    800d29 <__udivdi3+0xf9>
  800d24:	3b 34 24             	cmp    (%esp),%esi
  800d27:	74 1f                	je     800d48 <__udivdi3+0x118>
  800d29:	89 f8                	mov    %edi,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	e9 7a ff ff ff       	jmp    800cac <__udivdi3+0x7c>
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	31 d2                	xor    %edx,%edx
  800d3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3f:	e9 68 ff ff ff       	jmp    800cac <__udivdi3+0x7c>
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d4b:	31 d2                	xor    %edx,%edx
  800d4d:	83 c4 0c             	add    $0xc,%esp
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
  800d54:	66 90                	xchg   %ax,%ax
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	83 ec 14             	sub    $0x14,%esp
  800d66:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d72:	89 c7                	mov    %eax,%edi
  800d74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d78:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d80:	89 34 24             	mov    %esi,(%esp)
  800d83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d8f:	75 17                	jne    800da8 <__umoddi3+0x48>
  800d91:	39 fe                	cmp    %edi,%esi
  800d93:	76 4b                	jbe    800de0 <__umoddi3+0x80>
  800d95:	89 c8                	mov    %ecx,%eax
  800d97:	89 fa                	mov    %edi,%edx
  800d99:	f7 f6                	div    %esi
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	83 c4 14             	add    $0x14,%esp
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
  800da6:	66 90                	xchg   %ax,%ax
  800da8:	39 f8                	cmp    %edi,%eax
  800daa:	77 54                	ja     800e00 <__umoddi3+0xa0>
  800dac:	0f bd e8             	bsr    %eax,%ebp
  800daf:	83 f5 1f             	xor    $0x1f,%ebp
  800db2:	75 5c                	jne    800e10 <__umoddi3+0xb0>
  800db4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800db8:	39 3c 24             	cmp    %edi,(%esp)
  800dbb:	0f 87 e7 00 00 00    	ja     800ea8 <__umoddi3+0x148>
  800dc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dc5:	29 f1                	sub    %esi,%ecx
  800dc7:	19 c7                	sbb    %eax,%edi
  800dc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dd1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800dd9:	83 c4 14             	add    $0x14,%esp
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
  800de0:	85 f6                	test   %esi,%esi
  800de2:	89 f5                	mov    %esi,%ebp
  800de4:	75 0b                	jne    800df1 <__umoddi3+0x91>
  800de6:	b8 01 00 00 00       	mov    $0x1,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	f7 f6                	div    %esi
  800def:	89 c5                	mov    %eax,%ebp
  800df1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df5:	31 d2                	xor    %edx,%edx
  800df7:	f7 f5                	div    %ebp
  800df9:	89 c8                	mov    %ecx,%eax
  800dfb:	f7 f5                	div    %ebp
  800dfd:	eb 9c                	jmp    800d9b <__umoddi3+0x3b>
  800dff:	90                   	nop
  800e00:	89 c8                	mov    %ecx,%eax
  800e02:	89 fa                	mov    %edi,%edx
  800e04:	83 c4 14             	add    $0x14,%esp
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
  800e0b:	90                   	nop
  800e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e10:	8b 04 24             	mov    (%esp),%eax
  800e13:	be 20 00 00 00       	mov    $0x20,%esi
  800e18:	89 e9                	mov    %ebp,%ecx
  800e1a:	29 ee                	sub    %ebp,%esi
  800e1c:	d3 e2                	shl    %cl,%edx
  800e1e:	89 f1                	mov    %esi,%ecx
  800e20:	d3 e8                	shr    %cl,%eax
  800e22:	89 e9                	mov    %ebp,%ecx
  800e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e28:	8b 04 24             	mov    (%esp),%eax
  800e2b:	09 54 24 04          	or     %edx,0x4(%esp)
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	d3 e0                	shl    %cl,%eax
  800e33:	89 f1                	mov    %esi,%ecx
  800e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e39:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e3d:	d3 ea                	shr    %cl,%edx
  800e3f:	89 e9                	mov    %ebp,%ecx
  800e41:	d3 e7                	shl    %cl,%edi
  800e43:	89 f1                	mov    %esi,%ecx
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	89 e9                	mov    %ebp,%ecx
  800e49:	09 f8                	or     %edi,%eax
  800e4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e4f:	f7 74 24 04          	divl   0x4(%esp)
  800e53:	d3 e7                	shl    %cl,%edi
  800e55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	f7 64 24 08          	mull   0x8(%esp)
  800e5f:	39 d7                	cmp    %edx,%edi
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	89 14 24             	mov    %edx,(%esp)
  800e66:	72 2c                	jb     800e94 <__umoddi3+0x134>
  800e68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  800e6c:	72 22                	jb     800e90 <__umoddi3+0x130>
  800e6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800e72:	29 c8                	sub    %ecx,%eax
  800e74:	19 d7                	sbb    %edx,%edi
  800e76:	89 e9                	mov    %ebp,%ecx
  800e78:	89 fa                	mov    %edi,%edx
  800e7a:	d3 e8                	shr    %cl,%eax
  800e7c:	89 f1                	mov    %esi,%ecx
  800e7e:	d3 e2                	shl    %cl,%edx
  800e80:	89 e9                	mov    %ebp,%ecx
  800e82:	d3 ef                	shr    %cl,%edi
  800e84:	09 d0                	or     %edx,%eax
  800e86:	89 fa                	mov    %edi,%edx
  800e88:	83 c4 14             	add    $0x14,%esp
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    
  800e8f:	90                   	nop
  800e90:	39 d7                	cmp    %edx,%edi
  800e92:	75 da                	jne    800e6e <__umoddi3+0x10e>
  800e94:	8b 14 24             	mov    (%esp),%edx
  800e97:	89 c1                	mov    %eax,%ecx
  800e99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  800e9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  800ea1:	eb cb                	jmp    800e6e <__umoddi3+0x10e>
  800ea3:	90                   	nop
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800eac:	0f 82 0f ff ff ff    	jb     800dc1 <__umoddi3+0x61>
  800eb2:	e9 1a ff ff ff       	jmp    800dd1 <__umoddi3+0x71>
