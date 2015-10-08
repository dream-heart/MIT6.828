
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
  800059:	c7 04 24 20 11 80 00 	movl   $0x801120,(%esp)
  800060:	e8 09 01 00 00       	call   80016e <cprintf>
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
  80007a:	e8 46 0b 00 00       	call   800bc5 <sys_getenvid>
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
  8000a8:	e8 0a 00 00 00       	call   8000b7 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c4:	e8 aa 0a 00 00       	call   800b73 <sys_env_destroy>
}
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 14             	sub    $0x14,%esp
  8000d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d5:	8b 13                	mov    (%ebx),%edx
  8000d7:	8d 42 01             	lea    0x1(%edx),%eax
  8000da:	89 03                	mov    %eax,(%ebx)
  8000dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e8:	75 19                	jne    800103 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000ea:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f1:	00 
  8000f2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f5:	89 04 24             	mov    %eax,(%esp)
  8000f8:	e8 39 0a 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800103:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800107:	83 c4 14             	add    $0x14,%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800116:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011d:	00 00 00 
	b.cnt = 0;
  800120:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800127:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800131:	8b 45 08             	mov    0x8(%ebp),%eax
  800134:	89 44 24 08          	mov    %eax,0x8(%esp)
  800138:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	c7 04 24 cb 00 80 00 	movl   $0x8000cb,(%esp)
  800149:	e8 76 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800154:	89 44 24 04          	mov    %eax,0x4(%esp)
  800158:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 d0 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  800166:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800174:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	89 04 24             	mov    %eax,(%esp)
  800181:	e8 87 ff ff ff       	call   80010d <vcprintf>
	va_end(ap);

	return cnt;
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    
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
  8001a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 c3                	mov    %eax,%ebx
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bd:	39 d9                	cmp    %ebx,%ecx
  8001bf:	72 05                	jb     8001c6 <printnum+0x36>
  8001c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001c4:	77 69                	ja     80022f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001cd:	83 ee 01             	sub    $0x1,%esi
  8001d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e0:	89 c3                	mov    %eax,%ebx
  8001e2:	89 d6                	mov    %edx,%esi
  8001e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	e8 6c 0c 00 00       	call   800e70 <__udivdi3>
  800204:	89 d9                	mov    %ebx,%ecx
  800206:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	89 54 24 04          	mov    %edx,0x4(%esp)
  800215:	89 fa                	mov    %edi,%edx
  800217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021a:	e8 71 ff ff ff       	call   800190 <printnum>
  80021f:	eb 1b                	jmp    80023c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	8b 45 18             	mov    0x18(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	ff d3                	call   *%ebx
  80022d:	eb 03                	jmp    800232 <printnum+0xa2>
  80022f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800232:	83 ee 01             	sub    $0x1,%esi
  800235:	85 f6                	test   %esi,%esi
  800237:	7f e8                	jg     800221 <printnum+0x91>
  800239:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800247:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80024a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	e8 3c 0d 00 00       	call   800fa0 <__umoddi3>
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	0f be 80 38 11 80 00 	movsbl 0x801138(%eax),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800275:	ff d0                	call   *%eax
}
  800277:	83 c4 3c             	add    $0x3c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800285:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	3b 50 04             	cmp    0x4(%eax),%edx
  80028e:	73 0a                	jae    80029a <sprintputch+0x1b>
		*b->buf++ = ch;
  800290:	8d 4a 01             	lea    0x1(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	88 02                	mov    %al,(%edx)
}
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	e8 02 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 3c             	sub    $0x3c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 11                	jmp    8002e9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 48 04 00 00    	je     800728 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8002e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	83 c7 01             	add    $0x1,%edi
  8002ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	75 e3                	jne    8002d8 <vprintfmt+0x14>
  8002f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800300:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800307:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	eb 1f                	jmp    800334 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800318:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80031c:	eb 16                	jmp    800334 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800321:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800325:	eb 0d                	jmp    800334 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800327:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80032a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8d 47 01             	lea    0x1(%edi),%eax
  800337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033a:	0f b6 17             	movzbl (%edi),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	83 ea 23             	sub    $0x23,%edx
  800343:	80 fa 55             	cmp    $0x55,%dl
  800346:	0f 87 bf 03 00 00    	ja     80070b <vprintfmt+0x447>
  80034c:	0f b6 d2             	movzbl %dl,%edx
  80034f:	ff 24 95 00 12 80 00 	jmp    *0x801200(,%edx,4)
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800361:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800364:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800368:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80036b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80036e:	83 f9 09             	cmp    $0x9,%ecx
  800371:	77 3c                	ja     8003af <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800373:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800376:	eb e9                	jmp    800361 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 40 04             	lea    0x4(%eax),%eax
  800386:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038c:	eb 27                	jmp    8003b5 <vprintfmt+0xf1>
  80038e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	b8 00 00 00 00       	mov    $0x0,%eax
  800398:	0f 49 c2             	cmovns %edx,%eax
  80039b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a1:	eb 91                	jmp    800334 <vprintfmt+0x70>
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ad:	eb 85                	jmp    800334 <vprintfmt+0x70>
  8003af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b9:	0f 89 75 ff ff ff    	jns    800334 <vprintfmt+0x70>
  8003bf:	e9 63 ff ff ff       	jmp    800327 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ca:	e9 65 ff ff ff       	jmp    800334 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 04 24             	mov    %eax,(%esp)
  8003df:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e4:	e9 00 ff ff ff       	jmp    8002e9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ec:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	99                   	cltd   
  8003f3:	31 d0                	xor    %edx,%eax
  8003f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f7:	83 f8 09             	cmp    $0x9,%eax
  8003fa:	7f 0b                	jg     800407 <vprintfmt+0x143>
  8003fc:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800403:	85 d2                	test   %edx,%edx
  800405:	75 20                	jne    800427 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800407:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040b:	c7 44 24 08 50 11 80 	movl   $0x801150,0x8(%esp)
  800412:	00 
  800413:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800417:	89 34 24             	mov    %esi,(%esp)
  80041a:	e8 7d fe ff ff       	call   80029c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800422:	e9 c2 fe ff ff       	jmp    8002e9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800427:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042b:	c7 44 24 08 59 11 80 	movl   $0x801159,0x8(%esp)
  800432:	00 
  800433:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800437:	89 34 24             	mov    %esi,(%esp)
  80043a:	e8 5d fe ff ff       	call   80029c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800442:	e9 a2 fe ff ff       	jmp    8002e9 <vprintfmt+0x25>
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80044d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800450:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800453:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800457:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800459:	85 ff                	test   %edi,%edi
  80045b:	b8 49 11 80 00       	mov    $0x801149,%eax
  800460:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800463:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800467:	0f 84 92 00 00 00    	je     8004ff <vprintfmt+0x23b>
  80046d:	85 c9                	test   %ecx,%ecx
  80046f:	0f 8e 98 00 00 00    	jle    80050d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	89 54 24 04          	mov    %edx,0x4(%esp)
  800479:	89 3c 24             	mov    %edi,(%esp)
  80047c:	e8 47 03 00 00       	call   8007c8 <strnlen>
  800481:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800489:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800493:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	eb 0f                	jmp    8004a6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800497:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049e:	89 04 24             	mov    %eax,(%esp)
  8004a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	83 ef 01             	sub    $0x1,%edi
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ed                	jg     800497 <vprintfmt+0x1d3>
  8004aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b0:	85 c9                	test   %ecx,%ecx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	0f 49 c1             	cmovns %ecx,%eax
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	89 cb                	mov    %ecx,%ebx
  8004c7:	eb 50                	jmp    800519 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	74 1e                	je     8004ed <vprintfmt+0x229>
  8004cf:	0f be d2             	movsbl %dl,%edx
  8004d2:	83 ea 20             	sub    $0x20,%edx
  8004d5:	83 fa 5e             	cmp    $0x5e,%edx
  8004d8:	76 13                	jbe    8004ed <vprintfmt+0x229>
					putch('?', putdat);
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	eb 0d                	jmp    8004fa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8004ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fa:	83 eb 01             	sub    $0x1,%ebx
  8004fd:	eb 1a                	jmp    800519 <vprintfmt+0x255>
  8004ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800502:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800505:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800508:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050b:	eb 0c                	jmp    800519 <vprintfmt+0x255>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	83 c7 01             	add    $0x1,%edi
  80051c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800520:	0f be c2             	movsbl %dl,%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	74 25                	je     80054c <vprintfmt+0x288>
  800527:	85 f6                	test   %esi,%esi
  800529:	78 9e                	js     8004c9 <vprintfmt+0x205>
  80052b:	83 ee 01             	sub    $0x1,%esi
  80052e:	79 99                	jns    8004c9 <vprintfmt+0x205>
  800530:	89 df                	mov    %ebx,%edi
  800532:	8b 75 08             	mov    0x8(%ebp),%esi
  800535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800538:	eb 1a                	jmp    800554 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	eb 08                	jmp    800554 <vprintfmt+0x290>
  80054c:	89 df                	mov    %ebx,%edi
  80054e:	8b 75 08             	mov    0x8(%ebp),%esi
  800551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800554:	85 ff                	test   %edi,%edi
  800556:	7f e2                	jg     80053a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055b:	e9 89 fd ff ff       	jmp    8002e9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800560:	83 f9 01             	cmp    $0x1,%ecx
  800563:	7e 19                	jle    80057e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 50 04             	mov    0x4(%eax),%edx
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 08             	lea    0x8(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
  80057c:	eb 38                	jmp    8005b6 <vprintfmt+0x2f2>
	else if (lflag)
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	74 1b                	je     80059d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	89 c1                	mov    %eax,%ecx
  80058c:	c1 f9 1f             	sar    $0x1f,%ecx
  80058f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
  80059b:	eb 19                	jmp    8005b6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 c1                	mov    %eax,%ecx
  8005a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 40 04             	lea    0x4(%eax),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c5:	0f 89 04 01 00 00    	jns    8006cf <vprintfmt+0x40b>
				putch('-', putdat);
  8005cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005de:	f7 da                	neg    %edx
  8005e0:	83 d1 00             	adc    $0x0,%ecx
  8005e3:	f7 d9                	neg    %ecx
  8005e5:	e9 e5 00 00 00       	jmp    8006cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ea:	83 f9 01             	cmp    $0x1,%ecx
  8005ed:	7e 10                	jle    8005ff <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f7:	8d 40 08             	lea    0x8(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fd:	eb 26                	jmp    800625 <vprintfmt+0x361>
	else if (lflag)
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	74 12                	je     800615 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	eb 10                	jmp    800625 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800625:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80062a:	e9 a0 00 00 00       	jmp    8006cf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80063a:	ff d6                	call   *%esi
			putch('X', putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800647:	ff d6                	call   *%esi
			putch('X', putdat);
  800649:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800654:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800659:	e9 8b fc ff ff       	jmp    8002e9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80065e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800662:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800669:	ff d6                	call   *%esi
			putch('x', putdat);
  80066b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800682:	8d 40 04             	lea    0x4(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800688:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80068d:	eb 40                	jmp    8006cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 10                	jle    8006a4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a2:	eb 26                	jmp    8006ca <vprintfmt+0x406>
	else if (lflag)
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 12                	je     8006ba <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b8:	eb 10                	jmp    8006ca <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ca:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8006e2:	89 14 24             	mov    %edx,(%esp)
  8006e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 9e fa ff ff       	call   800190 <printnum>
			break;
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f5:	e9 ef fb ff ff       	jmp    8002e9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	89 04 24             	mov    %eax,(%esp)
  800701:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800706:	e9 de fb ff ff       	jmp    8002e9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800716:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800718:	eb 03                	jmp    80071d <vprintfmt+0x459>
  80071a:	83 ef 01             	sub    $0x1,%edi
  80071d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800721:	75 f7                	jne    80071a <vprintfmt+0x456>
  800723:	e9 c1 fb ff ff       	jmp    8002e9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800728:	83 c4 3c             	add    $0x3c,%esp
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 28             	sub    $0x28,%esp
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800743:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800746:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074d:	85 c0                	test   %eax,%eax
  80074f:	74 30                	je     800781 <vsnprintf+0x51>
  800751:	85 d2                	test   %edx,%edx
  800753:	7e 2c                	jle    800781 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075c:	8b 45 10             	mov    0x10(%ebp),%eax
  80075f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800763:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076a:	c7 04 24 7f 02 80 00 	movl   $0x80027f,(%esp)
  800771:	e8 4e fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800776:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800779:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077f:	eb 05                	jmp    800786 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800791:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800795:	8b 45 10             	mov    0x10(%ebp),%eax
  800798:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	89 04 24             	mov    %eax,(%esp)
  8007a9:	e8 82 ff ff ff       	call   800730 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1d>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
		n++;
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	89 c2                	mov    %eax,%edx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800800:	84 db                	test   %bl,%bl
  800802:	75 ef                	jne    8007f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 97 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 bd ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 1d                	jmp    800896 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 0b                	je     800891 <strlcpy+0x32>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	eb 02                	jmp    800893 <strlcpy+0x34>
  800891:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strfind+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0a                	je     800935 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 79 ff ff ff       	call   800984 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 19             	movzbl (%ecx),%ebx
  800a25:	38 d8                	cmp    %bl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	eb 07                	jmp    800a5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	74 07                	je     800a61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	72 f5                	jb     800a56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	80 f9 09             	cmp    $0x9,%cl
  800a7a:	74 f5                	je     800a71 <strtol+0xe>
  800a7c:	80 f9 20             	cmp    $0x20,%cl
  800a7f:	74 f0                	je     800a71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	80 f9 2b             	cmp    $0x2b,%cl
  800a84:	75 0a                	jne    800a90 <strtol+0x2d>
		s++;
  800a86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3e>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	80 f9 2d             	cmp    $0x2d,%cl
  800a98:	75 07                	jne    800aa1 <strtol+0x3e>
		s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800aa6:	75 15                	jne    800abd <strtol+0x5a>
  800aa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aab:	75 10                	jne    800abd <strtol+0x5a>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x5a>
		s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	b8 10 00 00 00       	mov    $0x10,%eax
  800abb:	eb 10                	jmp    800acd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800abd:	85 c0                	test   %eax,%eax
  800abf:	75 0c                	jne    800acd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac6:	75 05                	jne    800acd <strtol+0x6a>
		s++, base = 8;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800adb:	89 f0                	mov    %esi,%eax
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	77 08                	ja     800ae9 <strtol+0x86>
			dig = *s - '0';
  800ae1:	0f be c9             	movsbl %cl,%ecx
  800ae4:	83 e9 30             	sub    $0x30,%ecx
  800ae7:	eb 20                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0x97>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0f                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	3c 19                	cmp    $0x19,%al
  800b01:	77 16                	ja     800b19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b17:	eb bc                	jmp    800ad5 <strtol+0x72>
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	eb 02                	jmp    800b1f <strtol+0xbc>
  800b1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xc7>
		*endptr = (char *) s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800bb8:	e8 5b 02 00 00       	call   800e18 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800c4a:	e8 c9 01 00 00       	call   800e18 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800c9d:	e8 76 01 00 00       	call   800e18 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800cf0:	e8 23 01 00 00       	call   800e18 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800d43:	e8 d0 00 00 00       	call   800e18 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800d96:	e8 7d 00 00 00       	call   800e18 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	be 00 00 00 00       	mov    $0x0,%esi
  800dae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 cb                	mov    %ecx,%ebx
  800dde:	89 cf                	mov    %ecx,%edi
  800de0:	89 ce                	mov    %ecx,%esi
  800de2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 28                	jle    800e10 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dec:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df3:	00 
  800df4:	c7 44 24 08 88 13 80 	movl   $0x801388,0x8(%esp)
  800dfb:	00 
  800dfc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e03:	00 
  800e04:	c7 04 24 a5 13 80 00 	movl   $0x8013a5,(%esp)
  800e0b:	e8 08 00 00 00       	call   800e18 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	83 c4 2c             	add    $0x2c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e20:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e23:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e29:	e8 97 fd ff ff       	call   800bc5 <sys_getenvid>
  800e2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e31:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e3c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e44:	c7 04 24 b4 13 80 00 	movl   $0x8013b4,(%esp)
  800e4b:	e8 1e f3 ff ff       	call   80016e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e54:	8b 45 10             	mov    0x10(%ebp),%eax
  800e57:	89 04 24             	mov    %eax,(%esp)
  800e5a:	e8 ae f2 ff ff       	call   80010d <vcprintf>
	cprintf("\n");
  800e5f:	c7 04 24 2c 11 80 00 	movl   $0x80112c,(%esp)
  800e66:	e8 03 f3 ff ff       	call   80016e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e6b:	cc                   	int3   
  800e6c:	eb fd                	jmp    800e6b <_panic+0x53>
	...

00800e70 <__udivdi3>:
  800e70:	83 ec 1c             	sub    $0x1c,%esp
  800e73:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800e7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e83:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e87:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e8b:	85 ff                	test   %edi,%edi
  800e8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e95:	89 cd                	mov    %ecx,%ebp
  800e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9b:	75 33                	jne    800ed0 <__udivdi3+0x60>
  800e9d:	39 f1                	cmp    %esi,%ecx
  800e9f:	77 57                	ja     800ef8 <__udivdi3+0x88>
  800ea1:	85 c9                	test   %ecx,%ecx
  800ea3:	75 0b                	jne    800eb0 <__udivdi3+0x40>
  800ea5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaa:	31 d2                	xor    %edx,%edx
  800eac:	f7 f1                	div    %ecx
  800eae:	89 c1                	mov    %eax,%ecx
  800eb0:	89 f0                	mov    %esi,%eax
  800eb2:	31 d2                	xor    %edx,%edx
  800eb4:	f7 f1                	div    %ecx
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebc:	f7 f1                	div    %ecx
  800ebe:	89 f2                	mov    %esi,%edx
  800ec0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ec4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ec8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ecc:	83 c4 1c             	add    $0x1c,%esp
  800ecf:	c3                   	ret    
  800ed0:	31 d2                	xor    %edx,%edx
  800ed2:	31 c0                	xor    %eax,%eax
  800ed4:	39 f7                	cmp    %esi,%edi
  800ed6:	77 e8                	ja     800ec0 <__udivdi3+0x50>
  800ed8:	0f bd cf             	bsr    %edi,%ecx
  800edb:	83 f1 1f             	xor    $0x1f,%ecx
  800ede:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ee2:	75 2c                	jne    800f10 <__udivdi3+0xa0>
  800ee4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800ee8:	76 04                	jbe    800eee <__udivdi3+0x7e>
  800eea:	39 f7                	cmp    %esi,%edi
  800eec:	73 d2                	jae    800ec0 <__udivdi3+0x50>
  800eee:	31 d2                	xor    %edx,%edx
  800ef0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef5:	eb c9                	jmp    800ec0 <__udivdi3+0x50>
  800ef7:	90                   	nop
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	f7 f1                	div    %ecx
  800efc:	31 d2                	xor    %edx,%edx
  800efe:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f02:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f06:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	c3                   	ret    
  800f0e:	66 90                	xchg   %ax,%ax
  800f10:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f15:	b8 20 00 00 00       	mov    $0x20,%eax
  800f1a:	89 ea                	mov    %ebp,%edx
  800f1c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f20:	d3 e7                	shl    %cl,%edi
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	d3 ea                	shr    %cl,%edx
  800f26:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f2b:	09 fa                	or     %edi,%edx
  800f2d:	89 f7                	mov    %esi,%edi
  800f2f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f39:	d3 e5                	shl    %cl,%ebp
  800f3b:	89 c1                	mov    %eax,%ecx
  800f3d:	d3 ef                	shr    %cl,%edi
  800f3f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f44:	d3 e2                	shl    %cl,%edx
  800f46:	89 c1                	mov    %eax,%ecx
  800f48:	d3 ee                	shr    %cl,%esi
  800f4a:	09 d6                	or     %edx,%esi
  800f4c:	89 fa                	mov    %edi,%edx
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	f7 74 24 0c          	divl   0xc(%esp)
  800f54:	89 d7                	mov    %edx,%edi
  800f56:	89 c6                	mov    %eax,%esi
  800f58:	f7 e5                	mul    %ebp
  800f5a:	39 d7                	cmp    %edx,%edi
  800f5c:	72 22                	jb     800f80 <__udivdi3+0x110>
  800f5e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f62:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f67:	d3 e5                	shl    %cl,%ebp
  800f69:	39 c5                	cmp    %eax,%ebp
  800f6b:	73 04                	jae    800f71 <__udivdi3+0x101>
  800f6d:	39 d7                	cmp    %edx,%edi
  800f6f:	74 0f                	je     800f80 <__udivdi3+0x110>
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	e9 46 ff ff ff       	jmp    800ec0 <__udivdi3+0x50>
  800f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f80:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f89:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f8d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f91:	83 c4 1c             	add    $0x1c,%esp
  800f94:	c3                   	ret    
	...

00800fa0 <__umoddi3>:
  800fa0:	83 ec 1c             	sub    $0x1c,%esp
  800fa3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fa7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800fab:	8b 44 24 20          	mov    0x20(%esp),%eax
  800faf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fb3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fb7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fbb:	85 ed                	test   %ebp,%ebp
  800fbd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc5:	89 cf                	mov    %ecx,%edi
  800fc7:	89 04 24             	mov    %eax,(%esp)
  800fca:	89 f2                	mov    %esi,%edx
  800fcc:	75 1a                	jne    800fe8 <__umoddi3+0x48>
  800fce:	39 f1                	cmp    %esi,%ecx
  800fd0:	76 4e                	jbe    801020 <__umoddi3+0x80>
  800fd2:	f7 f1                	div    %ecx
  800fd4:	89 d0                	mov    %edx,%eax
  800fd6:	31 d2                	xor    %edx,%edx
  800fd8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fdc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fe0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fe4:	83 c4 1c             	add    $0x1c,%esp
  800fe7:	c3                   	ret    
  800fe8:	39 f5                	cmp    %esi,%ebp
  800fea:	77 54                	ja     801040 <__umoddi3+0xa0>
  800fec:	0f bd c5             	bsr    %ebp,%eax
  800fef:	83 f0 1f             	xor    $0x1f,%eax
  800ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff6:	75 60                	jne    801058 <__umoddi3+0xb8>
  800ff8:	3b 0c 24             	cmp    (%esp),%ecx
  800ffb:	0f 87 07 01 00 00    	ja     801108 <__umoddi3+0x168>
  801001:	89 f2                	mov    %esi,%edx
  801003:	8b 34 24             	mov    (%esp),%esi
  801006:	29 ce                	sub    %ecx,%esi
  801008:	19 ea                	sbb    %ebp,%edx
  80100a:	89 34 24             	mov    %esi,(%esp)
  80100d:	8b 04 24             	mov    (%esp),%eax
  801010:	8b 74 24 10          	mov    0x10(%esp),%esi
  801014:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801018:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80101c:	83 c4 1c             	add    $0x1c,%esp
  80101f:	c3                   	ret    
  801020:	85 c9                	test   %ecx,%ecx
  801022:	75 0b                	jne    80102f <__umoddi3+0x8f>
  801024:	b8 01 00 00 00       	mov    $0x1,%eax
  801029:	31 d2                	xor    %edx,%edx
  80102b:	f7 f1                	div    %ecx
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 f0                	mov    %esi,%eax
  801031:	31 d2                	xor    %edx,%edx
  801033:	f7 f1                	div    %ecx
  801035:	8b 04 24             	mov    (%esp),%eax
  801038:	f7 f1                	div    %ecx
  80103a:	eb 98                	jmp    800fd4 <__umoddi3+0x34>
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	89 f2                	mov    %esi,%edx
  801042:	8b 74 24 10          	mov    0x10(%esp),%esi
  801046:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80104a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80104e:	83 c4 1c             	add    $0x1c,%esp
  801051:	c3                   	ret    
  801052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801058:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80105d:	89 e8                	mov    %ebp,%eax
  80105f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801064:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801068:	89 fa                	mov    %edi,%edx
  80106a:	d3 e0                	shl    %cl,%eax
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	d3 ea                	shr    %cl,%edx
  801070:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801075:	09 c2                	or     %eax,%edx
  801077:	8b 44 24 08          	mov    0x8(%esp),%eax
  80107b:	89 14 24             	mov    %edx,(%esp)
  80107e:	89 f2                	mov    %esi,%edx
  801080:	d3 e7                	shl    %cl,%edi
  801082:	89 e9                	mov    %ebp,%ecx
  801084:	d3 ea                	shr    %cl,%edx
  801086:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80108b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108f:	d3 e6                	shl    %cl,%esi
  801091:	89 e9                	mov    %ebp,%ecx
  801093:	d3 e8                	shr    %cl,%eax
  801095:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109a:	09 f0                	or     %esi,%eax
  80109c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010a0:	f7 34 24             	divl   (%esp)
  8010a3:	d3 e6                	shl    %cl,%esi
  8010a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	f7 e7                	mul    %edi
  8010ad:	39 d6                	cmp    %edx,%esi
  8010af:	89 c1                	mov    %eax,%ecx
  8010b1:	89 d7                	mov    %edx,%edi
  8010b3:	72 3f                	jb     8010f4 <__umoddi3+0x154>
  8010b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010b9:	72 35                	jb     8010f0 <__umoddi3+0x150>
  8010bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010bf:	29 c8                	sub    %ecx,%eax
  8010c1:	19 fe                	sbb    %edi,%esi
  8010c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c8:	89 f2                	mov    %esi,%edx
  8010ca:	d3 e8                	shr    %cl,%eax
  8010cc:	89 e9                	mov    %ebp,%ecx
  8010ce:	d3 e2                	shl    %cl,%edx
  8010d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010d5:	09 d0                	or     %edx,%eax
  8010d7:	89 f2                	mov    %esi,%edx
  8010d9:	d3 ea                	shr    %cl,%edx
  8010db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010e7:	83 c4 1c             	add    $0x1c,%esp
  8010ea:	c3                   	ret    
  8010eb:	90                   	nop
  8010ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	39 d6                	cmp    %edx,%esi
  8010f2:	75 c7                	jne    8010bb <__umoddi3+0x11b>
  8010f4:	89 d7                	mov    %edx,%edi
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8010fc:	1b 3c 24             	sbb    (%esp),%edi
  8010ff:	eb ba                	jmp    8010bb <__umoddi3+0x11b>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	39 f5                	cmp    %esi,%ebp
  80110a:	0f 82 f1 fe ff ff    	jb     801001 <__umoddi3+0x61>
  801110:	e9 f8 fe ff ff       	jmp    80100d <__umoddi3+0x6d>
