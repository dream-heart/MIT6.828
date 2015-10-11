
obj/user/faultread：     文件格式 elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	a1 00 00 00 00       	mov    0x0,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  800049:	e8 01 01 00 00       	call   80014f <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80005e:	e8 42 0b 00 00       	call   800ba5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 a9 0a 00 00       	call   800b53 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 13                	mov    (%ebx),%edx
  8000b8:	8d 42 01             	lea    0x1(%edx),%eax
  8000bb:	89 03                	mov    %eax,(%ebx)
  8000bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 38 0a 00 00       	call   800b16 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e8:	83 c4 14             	add    $0x14,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  80012a:	e8 75 01 00 00       	call   8002a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 cf 09 00 00       	call   800b16 <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 87 ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	66 90                	xchg   %ax,%ax
  80016b:	66 90                	xchg   %ax,%ax
  80016d:	66 90                	xchg   %ax,%ax
  80016f:	90                   	nop

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 c3                	mov    %eax,%ebx
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019d:	39 d9                	cmp    %ebx,%ecx
  80019f:	72 05                	jb     8001a6 <printnum+0x36>
  8001a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a4:	77 69                	ja     80020f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ad:	83 ee 01             	sub    $0x1,%esi
  8001b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c0:	89 c3                	mov    %eax,%ebx
  8001c2:	89 d6                	mov    %edx,%esi
  8001c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	e8 6c 0c 00 00       	call   800e50 <__udivdi3>
  8001e4:	89 d9                	mov    %ebx,%ecx
  8001e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 71 ff ff ff       	call   800170 <printnum>
  8001ff:	eb 1b                	jmp    80021c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	8b 45 18             	mov    0x18(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	ff d3                	call   *%ebx
  80020d:	eb 03                	jmp    800212 <printnum+0xa2>
  80020f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800212:	83 ee 01             	sub    $0x1,%esi
  800215:	85 f6                	test   %esi,%esi
  800217:	7f e8                	jg     800201 <printnum+0x91>
  800219:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 3c 0d 00 00       	call   800f80 <__umoddi3>
  800244:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800248:	0f be 80 08 11 80 00 	movsbl 0x801108(%eax),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800255:	ff d0                	call   *%eax
}
  800257:	83 c4 3c             	add    $0x3c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	3b 50 04             	cmp    0x4(%eax),%edx
  80026e:	73 0a                	jae    80027a <sprintputch+0x1b>
		*b->buf++ = ch;
  800270:	8d 4a 01             	lea    0x1(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	88 02                	mov    %al,(%edx)
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800285:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800289:	8b 45 10             	mov    0x10(%ebp),%eax
  80028c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	e8 02 00 00 00       	call   8002a4 <vprintfmt>
	va_end(ap);
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 3c             	sub    $0x3c,%esp
  8002ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b6:	eb 11                	jmp    8002c9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	0f 84 48 04 00 00    	je     800708 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8002c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c9:	83 c7 01             	add    $0x1,%edi
  8002cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d0:	83 f8 25             	cmp    $0x25,%eax
  8002d3:	75 e3                	jne    8002b8 <vprintfmt+0x14>
  8002d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f3:	eb 1f                	jmp    800314 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002fc:	eb 16                	jmp    800314 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800301:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800305:	eb 0d                	jmp    800314 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800307:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80030a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8d 47 01             	lea    0x1(%edi),%eax
  800317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031a:	0f b6 17             	movzbl (%edi),%edx
  80031d:	0f b6 c2             	movzbl %dl,%eax
  800320:	83 ea 23             	sub    $0x23,%edx
  800323:	80 fa 55             	cmp    $0x55,%dl
  800326:	0f 87 bf 03 00 00    	ja     8006eb <vprintfmt+0x447>
  80032c:	0f b6 d2             	movzbl %dl,%edx
  80032f:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800341:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800344:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800348:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80034b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80034e:	83 f9 09             	cmp    $0x9,%ecx
  800351:	77 3c                	ja     80038f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800353:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800356:	eb e9                	jmp    800341 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8b 00                	mov    (%eax),%eax
  80035d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 40 04             	lea    0x4(%eax),%eax
  800366:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036c:	eb 27                	jmp    800395 <vprintfmt+0xf1>
  80036e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800371:	85 d2                	test   %edx,%edx
  800373:	b8 00 00 00 00       	mov    $0x0,%eax
  800378:	0f 49 c2             	cmovns %edx,%eax
  80037b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800381:	eb 91                	jmp    800314 <vprintfmt+0x70>
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800386:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038d:	eb 85                	jmp    800314 <vprintfmt+0x70>
  80038f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800392:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800395:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800399:	0f 89 75 ff ff ff    	jns    800314 <vprintfmt+0x70>
  80039f:	e9 63 ff ff ff       	jmp    800307 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003aa:	e9 65 ff ff ff       	jmp    800314 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c4:	e9 00 ff ff ff       	jmp    8002c9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003d0:	8b 00                	mov    (%eax),%eax
  8003d2:	99                   	cltd   
  8003d3:	31 d0                	xor    %edx,%eax
  8003d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d7:	83 f8 09             	cmp    $0x9,%eax
  8003da:	7f 0b                	jg     8003e7 <vprintfmt+0x143>
  8003dc:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	75 20                	jne    800407 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8003e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003eb:	c7 44 24 08 20 11 80 	movl   $0x801120,0x8(%esp)
  8003f2:	00 
  8003f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f7:	89 34 24             	mov    %esi,(%esp)
  8003fa:	e8 7d fe ff ff       	call   80027c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800402:	e9 c2 fe ff ff       	jmp    8002c9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800407:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80040b:	c7 44 24 08 29 11 80 	movl   $0x801129,0x8(%esp)
  800412:	00 
  800413:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800417:	89 34 24             	mov    %esi,(%esp)
  80041a:	e8 5d fe ff ff       	call   80027c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800422:	e9 a2 fe ff ff       	jmp    8002c9 <vprintfmt+0x25>
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80042d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800430:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800433:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800437:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800439:	85 ff                	test   %edi,%edi
  80043b:	b8 19 11 80 00       	mov    $0x801119,%eax
  800440:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800443:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800447:	0f 84 92 00 00 00    	je     8004df <vprintfmt+0x23b>
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	0f 8e 98 00 00 00    	jle    8004ed <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	89 54 24 04          	mov    %edx,0x4(%esp)
  800459:	89 3c 24             	mov    %edi,(%esp)
  80045c:	e8 47 03 00 00       	call   8007a8 <strnlen>
  800461:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800469:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80046d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800470:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800473:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	eb 0f                	jmp    800486 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800477:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	85 ff                	test   %edi,%edi
  800488:	7f ed                	jg     800477 <vprintfmt+0x1d3>
  80048a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80048d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800490:	85 c9                	test   %ecx,%ecx
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	0f 49 c1             	cmovns %ecx,%eax
  80049a:	29 c1                	sub    %eax,%ecx
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a5:	89 cb                	mov    %ecx,%ebx
  8004a7:	eb 50                	jmp    8004f9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ad:	74 1e                	je     8004cd <vprintfmt+0x229>
  8004af:	0f be d2             	movsbl %dl,%edx
  8004b2:	83 ea 20             	sub    $0x20,%edx
  8004b5:	83 fa 5e             	cmp    $0x5e,%edx
  8004b8:	76 13                	jbe    8004cd <vprintfmt+0x229>
					putch('?', putdat);
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8004cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x255>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x255>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800500:	0f be c2             	movsbl %dl,%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	74 25                	je     80052c <vprintfmt+0x288>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 9e                	js     8004a9 <vprintfmt+0x205>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 99                	jns    8004a9 <vprintfmt+0x205>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 1a                	jmp    800534 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800525:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800527:	83 ef 01             	sub    $0x1,%edi
  80052a:	eb 08                	jmp    800534 <vprintfmt+0x290>
  80052c:	89 df                	mov    %ebx,%edi
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800534:	85 ff                	test   %edi,%edi
  800536:	7f e2                	jg     80051a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053b:	e9 89 fd ff ff       	jmp    8002c9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800540:	83 f9 01             	cmp    $0x1,%ecx
  800543:	7e 19                	jle    80055e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 50 04             	mov    0x4(%eax),%edx
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 08             	lea    0x8(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
  80055c:	eb 38                	jmp    800596 <vprintfmt+0x2f2>
	else if (lflag)
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	74 1b                	je     80057d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 c1                	mov    %eax,%ecx
  80056c:	c1 f9 1f             	sar    $0x1f,%ecx
  80056f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 04             	lea    0x4(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	eb 19                	jmp    800596 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a5:	0f 89 04 01 00 00    	jns    8006af <vprintfmt+0x40b>
				putch('-', putdat);
  8005ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005af:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005be:	f7 da                	neg    %edx
  8005c0:	83 d1 00             	adc    $0x0,%ecx
  8005c3:	f7 d9                	neg    %ecx
  8005c5:	e9 e5 00 00 00       	jmp    8006af <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ca:	83 f9 01             	cmp    $0x1,%ecx
  8005cd:	7e 10                	jle    8005df <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb 26                	jmp    800605 <vprintfmt+0x361>
	else if (lflag)
  8005df:	85 c9                	test   %ecx,%ecx
  8005e1:	74 12                	je     8005f5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f3:	eb 10                	jmp    800605 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800605:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80060a:	e9 a0 00 00 00       	jmp    8006af <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80061a:	ff d6                	call   *%esi
			putch('X', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800627:	ff d6                	call   *%esi
			putch('X', putdat);
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800634:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800639:	e9 8b fc ff ff       	jmp    8002c9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800649:	ff d6                	call   *%esi
			putch('x', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800656:	ff d6                	call   *%esi
			num = (unsigned long long)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80066d:	eb 40                	jmp    8006af <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 f9 01             	cmp    $0x1,%ecx
  800672:	7e 10                	jle    800684 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	8b 48 04             	mov    0x4(%eax),%ecx
  80067c:	8d 40 08             	lea    0x8(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	eb 26                	jmp    8006aa <vprintfmt+0x406>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 12                	je     80069a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
  800698:	eb 10                	jmp    8006aa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006aa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8006c2:	89 14 24             	mov    %edx,(%esp)
  8006c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006c9:	89 da                	mov    %ebx,%edx
  8006cb:	89 f0                	mov    %esi,%eax
  8006cd:	e8 9e fa ff ff       	call   800170 <printnum>
			break;
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	e9 ef fb ff ff       	jmp    8002c9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006de:	89 04 24             	mov    %eax,(%esp)
  8006e1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e6:	e9 de fb ff ff       	jmp    8002c9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f8:	eb 03                	jmp    8006fd <vprintfmt+0x459>
  8006fa:	83 ef 01             	sub    $0x1,%edi
  8006fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800701:	75 f7                	jne    8006fa <vprintfmt+0x456>
  800703:	e9 c1 fb ff ff       	jmp    8002c9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800708:	83 c4 3c             	add    $0x3c,%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 28             	sub    $0x28,%esp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 30                	je     800761 <vsnprintf+0x51>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 2c                	jle    800761 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	8b 45 10             	mov    0x10(%ebp),%eax
  80073f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074a:	c7 04 24 5f 02 80 00 	movl   $0x80025f,(%esp)
  800751:	e8 4e fb ff ff       	call   8002a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800756:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800759:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075f:	eb 05                	jmp    800766 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	89 04 24             	mov    %eax,(%esp)
  800789:	e8 82 ff ff ff       	call   800710 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 03                	jmp    8007a0 <strlen+0x10>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	75 f7                	jne    80079d <strlen+0xd>
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strnlen+0x13>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	39 d0                	cmp    %edx,%eax
  8007bd:	74 06                	je     8007c5 <strnlen+0x1d>
  8007bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c3:	75 f3                	jne    8007b8 <strnlen+0x10>
		n++;
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	83 c1 01             	add    $0x1,%ecx
  8007d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ef                	jne    8007d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	89 1c 24             	mov    %ebx,(%esp)
  8007f4:	e8 97 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800800:	01 d8                	add    %ebx,%eax
  800802:	89 04 24             	mov    %eax,(%esp)
  800805:	e8 bd ff ff ff       	call   8007c7 <strcpy>
	return dst;
}
  80080a:	89 d8                	mov    %ebx,%eax
  80080c:	83 c4 08             	add    $0x8,%esp
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 c9                	test   %ecx,%ecx
  800855:	75 0b                	jne    800862 <strlcpy+0x23>
  800857:	eb 1d                	jmp    800876 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 0b                	je     800871 <strlcpy+0x32>
  800866:	0f b6 0a             	movzbl (%edx),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 ec                	jne    800859 <strlcpy+0x1a>
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	eb 02                	jmp    800873 <strlcpy+0x34>
  800871:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800873:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800876:	29 f0                	sub    %esi,%eax
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800885:	eb 06                	jmp    80088d <strcmp+0x11>
		p++, q++;
  800887:	83 c1 01             	add    $0x1,%ecx
  80088a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	84 c0                	test   %al,%al
  800892:	74 04                	je     800898 <strcmp+0x1c>
  800894:	3a 02                	cmp    (%edx),%al
  800896:	74 ef                	je     800887 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 c0             	movzbl %al,%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b1:	eb 06                	jmp    8008b9 <strncmp+0x17>
		n--, p++, q++;
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b9:	39 d8                	cmp    %ebx,%eax
  8008bb:	74 15                	je     8008d2 <strncmp+0x30>
  8008bd:	0f b6 08             	movzbl (%eax),%ecx
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	74 04                	je     8008c8 <strncmp+0x26>
  8008c4:	3a 0a                	cmp    (%edx),%cl
  8008c6:	74 eb                	je     8008b3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
  8008d0:	eb 05                	jmp    8008d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 07                	jmp    8008ed <strchr+0x13>
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 0f                	je     8008f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strfind+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0a                	je     800915 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800923:	85 c9                	test   %ecx,%ecx
  800925:	74 36                	je     80095d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800927:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092d:	75 28                	jne    800957 <memset+0x40>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 23                	jne    800957 <memset+0x40>
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 18             	shl    $0x18,%esi
  800942:	89 d0                	mov    %edx,%eax
  800944:	c1 e0 10             	shl    $0x10,%eax
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb 06                	jmp    80095d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800972:	39 c6                	cmp    %eax,%esi
  800974:	73 35                	jae    8009ab <memmove+0x47>
  800976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800979:	39 d0                	cmp    %edx,%eax
  80097b:	73 2e                	jae    8009ab <memmove+0x47>
		s += n;
		d += n;
  80097d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800980:	89 d6                	mov    %edx,%esi
  800982:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098a:	75 13                	jne    80099f <memmove+0x3b>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 0e                	jne    80099f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800991:	83 ef 04             	sub    $0x4,%edi
  800994:	8d 72 fc             	lea    -0x4(%edx),%esi
  800997:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099a:	fd                   	std    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 09                	jmp    8009a8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099f:	83 ef 01             	sub    $0x1,%edi
  8009a2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a8:	fc                   	cld    
  8009a9:	eb 1d                	jmp    8009c8 <memmove+0x64>
  8009ab:	89 f2                	mov    %esi,%edx
  8009ad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 0f                	jne    8009c3 <memmove+0x5f>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0a                	jne    8009c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 05                	jmp    8009c8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c3:	89 c7                	mov    %eax,%edi
  8009c5:	fc                   	cld    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 79 ff ff ff       	call   800964 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f8:	89 d6                	mov    %edx,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 1a                	jmp    800a19 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ff:	0f b6 02             	movzbl (%edx),%eax
  800a02:	0f b6 19             	movzbl (%ecx),%ebx
  800a05:	38 d8                	cmp    %bl,%al
  800a07:	74 0a                	je     800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 0f                	jmp    800a22 <memcmp+0x35>
		s1++, s2++;
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	39 f2                	cmp    %esi,%edx
  800a1b:	75 e2                	jne    8009ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	eb 07                	jmp    800a3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a36:	38 08                	cmp    %cl,(%eax)
  800a38:	74 07                	je     800a41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	72 f5                	jb     800a36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 0a             	movzbl (%edx),%ecx
  800a57:	80 f9 09             	cmp    $0x9,%cl
  800a5a:	74 f5                	je     800a51 <strtol+0xe>
  800a5c:	80 f9 20             	cmp    $0x20,%cl
  800a5f:	74 f0                	je     800a51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	80 f9 2b             	cmp    $0x2b,%cl
  800a64:	75 0a                	jne    800a70 <strtol+0x2d>
		s++;
  800a66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6e:	eb 11                	jmp    800a81 <strtol+0x3e>
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	80 f9 2d             	cmp    $0x2d,%cl
  800a78:	75 07                	jne    800a81 <strtol+0x3e>
		s++, neg = 1;
  800a7a:	8d 52 01             	lea    0x1(%edx),%edx
  800a7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a86:	75 15                	jne    800a9d <strtol+0x5a>
  800a88:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8b:	75 10                	jne    800a9d <strtol+0x5a>
  800a8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a91:	75 0a                	jne    800a9d <strtol+0x5a>
		s += 2, base = 16;
  800a93:	83 c2 02             	add    $0x2,%edx
  800a96:	b8 10 00 00 00       	mov    $0x10,%eax
  800a9b:	eb 10                	jmp    800aad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	75 0c                	jne    800aad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa6:	75 05                	jne    800aad <strtol+0x6a>
		s++, base = 8;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800aad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ab2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	0f b6 0a             	movzbl (%edx),%ecx
  800ab8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	77 08                	ja     800ac9 <strtol+0x86>
			dig = *s - '0';
  800ac1:	0f be c9             	movsbl %cl,%ecx
  800ac4:	83 e9 30             	sub    $0x30,%ecx
  800ac7:	eb 20                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ac9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	3c 19                	cmp    $0x19,%al
  800ad0:	77 08                	ja     800ada <strtol+0x97>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0f                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800add:	89 f0                	mov    %esi,%eax
  800adf:	3c 19                	cmp    $0x19,%al
  800ae1:	77 16                	ja     800af9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aec:	7d 0f                	jge    800afd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800af5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800af7:	eb bc                	jmp    800ab5 <strtol+0x72>
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	eb 02                	jmp    800aff <strtol+0xbc>
  800afd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xc7>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b0a:	f7 d8                	neg    %eax
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	b8 03 00 00 00       	mov    $0x3,%eax
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7e 28                	jle    800b9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b80:	00 
  800b81:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800b88:	00 
  800b89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b90:	00 
  800b91:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800b98:	e8 5b 02 00 00       	call   800df8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9d:	83 c4 2c             	add    $0x2c,%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	be 00 00 00 00       	mov    $0x0,%esi
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	89 f7                	mov    %esi,%edi
  800c01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 28                	jle    800c2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800c2a:	e8 c9 01 00 00       	call   800df8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	83 c4 2c             	add    $0x2c,%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 28                	jle    800c82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c65:	00 
  800c66:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800c6d:	00 
  800c6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c75:	00 
  800c76:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800c7d:	e8 76 01 00 00       	call   800df8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c82:	83 c4 2c             	add    $0x2c,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 28                	jle    800cd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc8:	00 
  800cc9:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800cd0:	e8 23 01 00 00       	call   800df8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd5:	83 c4 2c             	add    $0x2c,%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 28                	jle    800d28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800d13:	00 
  800d14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1b:	00 
  800d1c:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800d23:	e8 d0 00 00 00       	call   800df8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d28:	83 c4 2c             	add    $0x2c,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 28                	jle    800d7b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6e:	00 
  800d6f:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800d76:	e8 7d 00 00 00       	call   800df8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7b:	83 c4 2c             	add    $0x2c,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	be 00 00 00 00       	mov    $0x0,%esi
  800d8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 cb                	mov    %ecx,%ebx
  800dbe:	89 cf                	mov    %ecx,%edi
  800dc0:	89 ce                	mov    %ecx,%esi
  800dc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 28                	jle    800df0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 08 48 13 80 	movl   $0x801348,0x8(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de3:	00 
  800de4:	c7 04 24 65 13 80 00 	movl   $0x801365,(%esp)
  800deb:	e8 08 00 00 00       	call   800df8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df0:	83 c4 2c             	add    $0x2c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e00:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e03:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e09:	e8 97 fd ff ff       	call   800ba5 <sys_getenvid>
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e1c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e24:	c7 04 24 74 13 80 00 	movl   $0x801374,(%esp)
  800e2b:	e8 1f f3 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e34:	8b 45 10             	mov    0x10(%ebp),%eax
  800e37:	89 04 24             	mov    %eax,(%esp)
  800e3a:	e8 af f2 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800e3f:	c7 04 24 fc 10 80 00 	movl   $0x8010fc,(%esp)
  800e46:	e8 04 f3 ff ff       	call   80014f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e4b:	cc                   	int3   
  800e4c:	eb fd                	jmp    800e4b <_panic+0x53>
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e5a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e5e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e62:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e66:	85 c0                	test   %eax,%eax
  800e68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e6c:	89 ea                	mov    %ebp,%edx
  800e6e:	89 0c 24             	mov    %ecx,(%esp)
  800e71:	75 2d                	jne    800ea0 <__udivdi3+0x50>
  800e73:	39 e9                	cmp    %ebp,%ecx
  800e75:	77 61                	ja     800ed8 <__udivdi3+0x88>
  800e77:	85 c9                	test   %ecx,%ecx
  800e79:	89 ce                	mov    %ecx,%esi
  800e7b:	75 0b                	jne    800e88 <__udivdi3+0x38>
  800e7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e82:	31 d2                	xor    %edx,%edx
  800e84:	f7 f1                	div    %ecx
  800e86:	89 c6                	mov    %eax,%esi
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	89 e8                	mov    %ebp,%eax
  800e8c:	f7 f6                	div    %esi
  800e8e:	89 c5                	mov    %eax,%ebp
  800e90:	89 f8                	mov    %edi,%eax
  800e92:	f7 f6                	div    %esi
  800e94:	89 ea                	mov    %ebp,%edx
  800e96:	83 c4 0c             	add    $0xc,%esp
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	39 e8                	cmp    %ebp,%eax
  800ea2:	77 24                	ja     800ec8 <__udivdi3+0x78>
  800ea4:	0f bd e8             	bsr    %eax,%ebp
  800ea7:	83 f5 1f             	xor    $0x1f,%ebp
  800eaa:	75 3c                	jne    800ee8 <__udivdi3+0x98>
  800eac:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb0:	39 34 24             	cmp    %esi,(%esp)
  800eb3:	0f 86 9f 00 00 00    	jbe    800f58 <__udivdi3+0x108>
  800eb9:	39 d0                	cmp    %edx,%eax
  800ebb:	0f 82 97 00 00 00    	jb     800f58 <__udivdi3+0x108>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	31 c0                	xor    %eax,%eax
  800ecc:	83 c4 0c             	add    $0xc,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	89 f8                	mov    %edi,%eax
  800eda:	f7 f1                	div    %ecx
  800edc:	31 d2                	xor    %edx,%edx
  800ede:	83 c4 0c             	add    $0xc,%esp
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	8b 3c 24             	mov    (%esp),%edi
  800eed:	d3 e0                	shl    %cl,%eax
  800eef:	89 c6                	mov    %eax,%esi
  800ef1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef6:	29 e8                	sub    %ebp,%eax
  800ef8:	89 c1                	mov    %eax,%ecx
  800efa:	d3 ef                	shr    %cl,%edi
  800efc:	89 e9                	mov    %ebp,%ecx
  800efe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f02:	8b 3c 24             	mov    (%esp),%edi
  800f05:	09 74 24 08          	or     %esi,0x8(%esp)
  800f09:	89 d6                	mov    %edx,%esi
  800f0b:	d3 e7                	shl    %cl,%edi
  800f0d:	89 c1                	mov    %eax,%ecx
  800f0f:	89 3c 24             	mov    %edi,(%esp)
  800f12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f16:	d3 ee                	shr    %cl,%esi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	d3 e2                	shl    %cl,%edx
  800f1c:	89 c1                	mov    %eax,%ecx
  800f1e:	d3 ef                	shr    %cl,%edi
  800f20:	09 d7                	or     %edx,%edi
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	89 f8                	mov    %edi,%eax
  800f26:	f7 74 24 08          	divl   0x8(%esp)
  800f2a:	89 d6                	mov    %edx,%esi
  800f2c:	89 c7                	mov    %eax,%edi
  800f2e:	f7 24 24             	mull   (%esp)
  800f31:	39 d6                	cmp    %edx,%esi
  800f33:	89 14 24             	mov    %edx,(%esp)
  800f36:	72 30                	jb     800f68 <__udivdi3+0x118>
  800f38:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f3c:	89 e9                	mov    %ebp,%ecx
  800f3e:	d3 e2                	shl    %cl,%edx
  800f40:	39 c2                	cmp    %eax,%edx
  800f42:	73 05                	jae    800f49 <__udivdi3+0xf9>
  800f44:	3b 34 24             	cmp    (%esp),%esi
  800f47:	74 1f                	je     800f68 <__udivdi3+0x118>
  800f49:	89 f8                	mov    %edi,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	e9 7a ff ff ff       	jmp    800ecc <__udivdi3+0x7c>
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5f:	e9 68 ff ff ff       	jmp    800ecc <__udivdi3+0x7c>
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	83 c4 0c             	add    $0xc,%esp
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	66 90                	xchg   %ax,%ax
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	83 ec 14             	sub    $0x14,%esp
  800f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f98:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa0:	89 34 24             	mov    %esi,(%esp)
  800fa3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	89 c2                	mov    %eax,%edx
  800fab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800faf:	75 17                	jne    800fc8 <__umoddi3+0x48>
  800fb1:	39 fe                	cmp    %edi,%esi
  800fb3:	76 4b                	jbe    801000 <__umoddi3+0x80>
  800fb5:	89 c8                	mov    %ecx,%eax
  800fb7:	89 fa                	mov    %edi,%edx
  800fb9:	f7 f6                	div    %esi
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	83 c4 14             	add    $0x14,%esp
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
  800fc6:	66 90                	xchg   %ax,%ax
  800fc8:	39 f8                	cmp    %edi,%eax
  800fca:	77 54                	ja     801020 <__umoddi3+0xa0>
  800fcc:	0f bd e8             	bsr    %eax,%ebp
  800fcf:	83 f5 1f             	xor    $0x1f,%ebp
  800fd2:	75 5c                	jne    801030 <__umoddi3+0xb0>
  800fd4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fd8:	39 3c 24             	cmp    %edi,(%esp)
  800fdb:	0f 87 e7 00 00 00    	ja     8010c8 <__umoddi3+0x148>
  800fe1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe5:	29 f1                	sub    %esi,%ecx
  800fe7:	19 c7                	sbb    %eax,%edi
  800fe9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ff1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ff5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ff9:	83 c4 14             	add    $0x14,%esp
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    
  801000:	85 f6                	test   %esi,%esi
  801002:	89 f5                	mov    %esi,%ebp
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f6                	div    %esi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	8b 44 24 04          	mov    0x4(%esp),%eax
  801015:	31 d2                	xor    %edx,%edx
  801017:	f7 f5                	div    %ebp
  801019:	89 c8                	mov    %ecx,%eax
  80101b:	f7 f5                	div    %ebp
  80101d:	eb 9c                	jmp    800fbb <__umoddi3+0x3b>
  80101f:	90                   	nop
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 fa                	mov    %edi,%edx
  801024:	83 c4 14             	add    $0x14,%esp
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	90                   	nop
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	8b 04 24             	mov    (%esp),%eax
  801033:	be 20 00 00 00       	mov    $0x20,%esi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	29 ee                	sub    %ebp,%esi
  80103c:	d3 e2                	shl    %cl,%edx
  80103e:	89 f1                	mov    %esi,%ecx
  801040:	d3 e8                	shr    %cl,%eax
  801042:	89 e9                	mov    %ebp,%ecx
  801044:	89 44 24 04          	mov    %eax,0x4(%esp)
  801048:	8b 04 24             	mov    (%esp),%eax
  80104b:	09 54 24 04          	or     %edx,0x4(%esp)
  80104f:	89 fa                	mov    %edi,%edx
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 f1                	mov    %esi,%ecx
  801055:	89 44 24 08          	mov    %eax,0x8(%esp)
  801059:	8b 44 24 10          	mov    0x10(%esp),%eax
  80105d:	d3 ea                	shr    %cl,%edx
  80105f:	89 e9                	mov    %ebp,%ecx
  801061:	d3 e7                	shl    %cl,%edi
  801063:	89 f1                	mov    %esi,%ecx
  801065:	d3 e8                	shr    %cl,%eax
  801067:	89 e9                	mov    %ebp,%ecx
  801069:	09 f8                	or     %edi,%eax
  80106b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80106f:	f7 74 24 04          	divl   0x4(%esp)
  801073:	d3 e7                	shl    %cl,%edi
  801075:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801079:	89 d7                	mov    %edx,%edi
  80107b:	f7 64 24 08          	mull   0x8(%esp)
  80107f:	39 d7                	cmp    %edx,%edi
  801081:	89 c1                	mov    %eax,%ecx
  801083:	89 14 24             	mov    %edx,(%esp)
  801086:	72 2c                	jb     8010b4 <__umoddi3+0x134>
  801088:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80108c:	72 22                	jb     8010b0 <__umoddi3+0x130>
  80108e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801092:	29 c8                	sub    %ecx,%eax
  801094:	19 d7                	sbb    %edx,%edi
  801096:	89 e9                	mov    %ebp,%ecx
  801098:	89 fa                	mov    %edi,%edx
  80109a:	d3 e8                	shr    %cl,%eax
  80109c:	89 f1                	mov    %esi,%ecx
  80109e:	d3 e2                	shl    %cl,%edx
  8010a0:	89 e9                	mov    %ebp,%ecx
  8010a2:	d3 ef                	shr    %cl,%edi
  8010a4:	09 d0                	or     %edx,%eax
  8010a6:	89 fa                	mov    %edi,%edx
  8010a8:	83 c4 14             	add    $0x14,%esp
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    
  8010af:	90                   	nop
  8010b0:	39 d7                	cmp    %edx,%edi
  8010b2:	75 da                	jne    80108e <__umoddi3+0x10e>
  8010b4:	8b 14 24             	mov    (%esp),%edx
  8010b7:	89 c1                	mov    %eax,%ecx
  8010b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010c1:	eb cb                	jmp    80108e <__umoddi3+0x10e>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010cc:	0f 82 0f ff ff ff    	jb     800fe1 <__umoddi3+0x61>
  8010d2:	e9 1a ff ff ff       	jmp    800ff1 <__umoddi3+0x71>
