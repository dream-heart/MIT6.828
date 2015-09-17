
obj/user/spin：     文件格式 elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  80004e:	e8 58 01 00 00       	call   8001ab <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 00 0e 00 00       	call   800e58 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  800065:	e8 41 01 00 00       	call   8001ab <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 c8 11 80 00 	movl   $0x8011c8,(%esp)
  800073:	e8 33 01 00 00       	call   8001ab <cprintf>
	sys_yield();
  800078:	e8 a7 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  80007d:	e8 a2 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  800082:	e8 9d 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  800087:	e8 98 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 8f 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  800095:	e8 8a 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  80009a:	e8 85 0b 00 00       	call   800c24 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 7f 0b 00 00       	call   800c24 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 f0 11 80 00 	movl   $0x8011f0,(%esp)
  8000ac:	e8 fa 00 00 00       	call   8001ab <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 fa 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 18             	sub    $0x18,%esp
  8000c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000cb:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d2:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d5:	85 c0                	test   %eax,%eax
  8000d7:	7e 08                	jle    8000e1 <libmain+0x22>
		binaryname = argv[0];
  8000d9:	8b 0a                	mov    (%edx),%ecx
  8000db:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000e5:	89 04 24             	mov    %eax,(%esp)
  8000e8:	e8 53 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000ed:	e8 02 00 00 00       	call   8000f4 <exit>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800101:	e8 ad 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 14             	sub    $0x14,%esp
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800112:	8b 13                	mov    (%ebx),%edx
  800114:	8d 42 01             	lea    0x1(%edx),%eax
  800117:	89 03                	mov    %eax,(%ebx)
  800119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800120:	3d ff 00 00 00       	cmp    $0xff,%eax
  800125:	75 19                	jne    800140 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800127:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012e:	00 
  80012f:	8d 43 08             	lea    0x8(%ebx),%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 3c 0a 00 00       	call   800b76 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800140:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800144:	83 c4 14             	add    $0x14,%esp
  800147:	5b                   	pop    %ebx
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800153:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015a:	00 00 00 
	b.cnt = 0;
  80015d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800164:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 44 24 08          	mov    %eax,0x8(%esp)
  800175:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	c7 04 24 08 01 80 00 	movl   $0x800108,(%esp)
  800186:	e8 79 01 00 00       	call   800304 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 d3 09 00 00       	call   800b76 <sys_cputs>

	return b.cnt;
}
  8001a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 87 ff ff ff       	call   80014a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	66 90                	xchg   %ax,%ax
  8001c7:	66 90                	xchg   %ax,%ax
  8001c9:	66 90                	xchg   %ax,%ax
  8001cb:	66 90                	xchg   %ax,%ax
  8001cd:	66 90                	xchg   %ax,%ax
  8001cf:	90                   	nop

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 3c             	sub    $0x3c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	89 c3                	mov    %eax,%ebx
  8001e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001fd:	39 d9                	cmp    %ebx,%ecx
  8001ff:	72 05                	jb     800206 <printnum+0x36>
  800201:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800204:	77 69                	ja     80026f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800206:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800209:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80020d:	83 ee 01             	sub    $0x1,%esi
  800210:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 44 24 08          	mov    0x8(%esp),%eax
  80021c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800220:	89 c3                	mov    %eax,%ebx
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800227:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80022a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80022e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 bc 0c 00 00       	call   800f00 <__udivdi3>
  800244:	89 d9                	mov    %ebx,%ecx
  800246:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	89 54 24 04          	mov    %edx,0x4(%esp)
  800255:	89 fa                	mov    %edi,%edx
  800257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025a:	e8 71 ff ff ff       	call   8001d0 <printnum>
  80025f:	eb 1b                	jmp    80027c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800265:	8b 45 18             	mov    0x18(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff d3                	call   *%ebx
  80026d:	eb 03                	jmp    800272 <printnum+0xa2>
  80026f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	83 ee 01             	sub    $0x1,%esi
  800275:	85 f6                	test   %esi,%esi
  800277:	7f e8                	jg     800261 <printnum+0x91>
  800279:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800280:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800284:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800287:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800292:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80029b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029f:	e8 8c 0d 00 00       	call   801030 <__umoddi3>
  8002a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a8:	0f be 80 40 12 80 00 	movsbl 0x801240(%eax),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b5:	ff d0                	call   *%eax
}
  8002b7:	83 c4 3c             	add    $0x3c,%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ce:	73 0a                	jae    8002da <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	88 02                	mov    %al,(%edx)
}
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 02 00 00 00       	call   800304 <vprintfmt>
	va_end(ap);
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 3c             	sub    $0x3c,%esp
  80030d:	8b 75 08             	mov    0x8(%ebp),%esi
  800310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800313:	8b 7d 10             	mov    0x10(%ebp),%edi
  800316:	eb 11                	jmp    800329 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800318:	85 c0                	test   %eax,%eax
  80031a:	0f 84 48 04 00 00    	je     800768 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800320:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	83 c7 01             	add    $0x1,%edi
  80032c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 e3                	jne    800318 <vprintfmt+0x14>
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800353:	eb 1f                	jmp    800374 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035c:	eb 16                	jmp    800374 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800361:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800365:	eb 0d                	jmp    800374 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800367:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8d 47 01             	lea    0x1(%edi),%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037a:	0f b6 17             	movzbl (%edi),%edx
  80037d:	0f b6 c2             	movzbl %dl,%eax
  800380:	83 ea 23             	sub    $0x23,%edx
  800383:	80 fa 55             	cmp    $0x55,%dl
  800386:	0f 87 bf 03 00 00    	ja     80074b <vprintfmt+0x447>
  80038c:	0f b6 d2             	movzbl %dl,%edx
  80038f:	ff 24 95 00 13 80 00 	jmp    *0x801300(,%edx,4)
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ae:	83 f9 09             	cmp    $0x9,%ecx
  8003b1:	77 3c                	ja     8003ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b6:	eb e9                	jmp    8003a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 40 04             	lea    0x4(%eax),%eax
  8003c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cc:	eb 27                	jmp    8003f5 <vprintfmt+0xf1>
  8003ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d8:	0f 49 c2             	cmovns %edx,%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e1:	eb 91                	jmp    800374 <vprintfmt+0x70>
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ed:	eb 85                	jmp    800374 <vprintfmt+0x70>
  8003ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f9:	0f 89 75 ff ff ff    	jns    800374 <vprintfmt+0x70>
  8003ff:	e9 63 ff ff ff       	jmp    800367 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800404:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040a:	e9 65 ff ff ff       	jmp    800374 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800412:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800416:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800424:	e9 00 ff ff ff       	jmp    800329 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	99                   	cltd   
  800433:	31 d0                	xor    %edx,%eax
  800435:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800437:	83 f8 09             	cmp    $0x9,%eax
  80043a:	7f 0b                	jg     800447 <vprintfmt+0x143>
  80043c:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800443:	85 d2                	test   %edx,%edx
  800445:	75 20                	jne    800467 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044b:	c7 44 24 08 58 12 80 	movl   $0x801258,0x8(%esp)
  800452:	00 
  800453:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800457:	89 34 24             	mov    %esi,(%esp)
  80045a:	e8 7d fe ff ff       	call   8002dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 c2 fe ff ff       	jmp    800329 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800467:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046b:	c7 44 24 08 61 12 80 	movl   $0x801261,0x8(%esp)
  800472:	00 
  800473:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800477:	89 34 24             	mov    %esi,(%esp)
  80047a:	e8 5d fe ff ff       	call   8002dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800482:	e9 a2 fe ff ff       	jmp    800329 <vprintfmt+0x25>
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800490:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800497:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800499:	85 ff                	test   %edi,%edi
  80049b:	b8 51 12 80 00       	mov    $0x801251,%eax
  8004a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a7:	0f 84 92 00 00 00    	je     80053f <vprintfmt+0x23b>
  8004ad:	85 c9                	test   %ecx,%ecx
  8004af:	0f 8e 98 00 00 00    	jle    80054d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b9:	89 3c 24             	mov    %edi,(%esp)
  8004bc:	e8 47 03 00 00       	call   800808 <strnlen>
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	29 c1                	sub    %eax,%ecx
  8004c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	eb 0f                	jmp    8004e6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	85 ff                	test   %edi,%edi
  8004e8:	7f ed                	jg     8004d7 <vprintfmt+0x1d3>
  8004ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f0:	85 c9                	test   %ecx,%ecx
  8004f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f7:	0f 49 c1             	cmovns %ecx,%eax
  8004fa:	29 c1                	sub    %eax,%ecx
  8004fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800502:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800505:	89 cb                	mov    %ecx,%ebx
  800507:	eb 50                	jmp    800559 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050d:	74 1e                	je     80052d <vprintfmt+0x229>
  80050f:	0f be d2             	movsbl %dl,%edx
  800512:	83 ea 20             	sub    $0x20,%edx
  800515:	83 fa 5e             	cmp    $0x5e,%edx
  800518:	76 13                	jbe    80052d <vprintfmt+0x229>
					putch('?', putdat);
  80051a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	eb 0d                	jmp    80053a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80052d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800530:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	83 eb 01             	sub    $0x1,%ebx
  80053d:	eb 1a                	jmp    800559 <vprintfmt+0x255>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	eb 0c                	jmp    800559 <vprintfmt+0x255>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	83 c7 01             	add    $0x1,%edi
  80055c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800560:	0f be c2             	movsbl %dl,%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	74 25                	je     80058c <vprintfmt+0x288>
  800567:	85 f6                	test   %esi,%esi
  800569:	78 9e                	js     800509 <vprintfmt+0x205>
  80056b:	83 ee 01             	sub    $0x1,%esi
  80056e:	79 99                	jns    800509 <vprintfmt+0x205>
  800570:	89 df                	mov    %ebx,%edi
  800572:	8b 75 08             	mov    0x8(%ebp),%esi
  800575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800585:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	83 ef 01             	sub    $0x1,%edi
  80058a:	eb 08                	jmp    800594 <vprintfmt+0x290>
  80058c:	89 df                	mov    %ebx,%edi
  80058e:	8b 75 08             	mov    0x8(%ebp),%esi
  800591:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800594:	85 ff                	test   %edi,%edi
  800596:	7f e2                	jg     80057a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	e9 89 fd ff ff       	jmp    800329 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a0:	83 f9 01             	cmp    $0x1,%ecx
  8005a3:	7e 19                	jle    8005be <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 50 04             	mov    0x4(%eax),%edx
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 08             	lea    0x8(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 38                	jmp    8005f6 <vprintfmt+0x2f2>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	74 1b                	je     8005dd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	89 c1                	mov    %eax,%ecx
  8005cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 40 04             	lea    0x4(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005db:	eb 19                	jmp    8005f6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 c1                	mov    %eax,%ecx
  8005e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	0f 89 04 01 00 00    	jns    80070f <vprintfmt+0x40b>
				putch('-', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800616:	ff d6                	call   *%esi
				num = -(long long) num;
  800618:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061e:	f7 da                	neg    %edx
  800620:	83 d1 00             	adc    $0x0,%ecx
  800623:	f7 d9                	neg    %ecx
  800625:	e9 e5 00 00 00       	jmp    80070f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 f9 01             	cmp    $0x1,%ecx
  80062d:	7e 10                	jle    80063f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	8b 48 04             	mov    0x4(%eax),%ecx
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
  80063d:	eb 26                	jmp    800665 <vprintfmt+0x361>
	else if (lflag)
  80063f:	85 c9                	test   %ecx,%ecx
  800641:	74 12                	je     800655 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
  800653:	eb 10                	jmp    800665 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800665:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80066a:	e9 a0 00 00 00       	jmp    80070f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80067a:	ff d6                	call   *%esi
			putch('X', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800687:	ff d6                	call   *%esi
			putch('X', putdat);
  800689:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800694:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800699:	e9 8b fc ff ff       	jmp    800329 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006af:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006cd:	eb 40                	jmp    80070f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cf:	83 f9 01             	cmp    $0x1,%ecx
  8006d2:	7e 10                	jle    8006e4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dc:	8d 40 08             	lea    0x8(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	eb 26                	jmp    80070a <vprintfmt+0x406>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 12                	je     8006fa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f8:	eb 10                	jmp    80070a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800713:	89 44 24 10          	mov    %eax,0x10(%esp)
  800717:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800722:	89 14 24             	mov    %edx,(%esp)
  800725:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800729:	89 da                	mov    %ebx,%edx
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	e8 9e fa ff ff       	call   8001d0 <printnum>
			break;
  800732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800735:	e9 ef fb ff ff       	jmp    800329 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800746:	e9 de fb ff ff       	jmp    800329 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800756:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	eb 03                	jmp    80075d <vprintfmt+0x459>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x456>
  800763:	e9 c1 fb ff ff       	jmp    800329 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800768:	83 c4 3c             	add    $0x3c,%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 28             	sub    $0x28,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 30                	je     8007c1 <vsnprintf+0x51>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 2c                	jle    8007c1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079c:	8b 45 10             	mov    0x10(%ebp),%eax
  80079f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007aa:	c7 04 24 bf 02 80 00 	movl   $0x8002bf,(%esp)
  8007b1:	e8 4e fb ff ff       	call   800304 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bf:	eb 05                	jmp    8007c6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	e8 82 ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 03                	jmp    800800 <strlen+0x10>
		n++;
  8007fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	75 f7                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strnlen+0x13>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1d>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f3                	jne    800818 <strnlen+0x10>
		n++;
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800840:	84 db                	test   %bl,%bl
  800842:	75 ef                	jne    800833 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800844:	5b                   	pop    %ebx
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	89 1c 24             	mov    %ebx,(%esp)
  800854:	e8 97 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	01 d8                	add    %ebx,%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 bd ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	89 f3                	mov    %esi,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 0f                	jmp    800895 <strncpy+0x23>
		*dst++ = *src;
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088f:	80 39 01             	cmpb   $0x1,(%ecx)
  800892:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	39 da                	cmp    %ebx,%edx
  800897:	75 ed                	jne    800886 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ad:	89 f0                	mov    %esi,%eax
  8008af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	75 0b                	jne    8008c2 <strlcpy+0x23>
  8008b7:	eb 1d                	jmp    8008d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
  8008bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 0b                	je     8008d1 <strlcpy+0x32>
  8008c6:	0f b6 0a             	movzbl (%edx),%ecx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	75 ec                	jne    8008b9 <strlcpy+0x1a>
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	eb 02                	jmp    8008d3 <strlcpy+0x34>
  8008d1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008d3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d6:	29 f0                	sub    %esi,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e5:	eb 06                	jmp    8008ed <strcmp+0x11>
		p++, q++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	84 c0                	test   %al,%al
  8008f2:	74 04                	je     8008f8 <strcmp+0x1c>
  8008f4:	3a 02                	cmp    (%edx),%al
  8008f6:	74 ef                	je     8008e7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 c0             	movzbl %al,%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800911:	eb 06                	jmp    800919 <strncmp+0x17>
		n--, p++, q++;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800919:	39 d8                	cmp    %ebx,%eax
  80091b:	74 15                	je     800932 <strncmp+0x30>
  80091d:	0f b6 08             	movzbl (%eax),%ecx
  800920:	84 c9                	test   %cl,%cl
  800922:	74 04                	je     800928 <strncmp+0x26>
  800924:	3a 0a                	cmp    (%edx),%cl
  800926:	74 eb                	je     800913 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
  800930:	eb 05                	jmp    800937 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 07                	jmp    80094d <strchr+0x13>
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 0f                	je     800959 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	eb 07                	jmp    80096e <strfind+0x13>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f2                	jne    800967 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 36                	je     8009bd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800987:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098d:	75 28                	jne    8009b7 <memset+0x40>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 23                	jne    8009b7 <memset+0x40>
		c &= 0xFF;
  800994:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800998:	89 d3                	mov    %edx,%ebx
  80099a:	c1 e3 08             	shl    $0x8,%ebx
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 18             	shl    $0x18,%esi
  8009a2:	89 d0                	mov    %edx,%eax
  8009a4:	c1 e0 10             	shl    $0x10,%eax
  8009a7:	09 f0                	or     %esi,%eax
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009af:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b2:	fc                   	cld    
  8009b3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b5:	eb 06                	jmp    8009bd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	fc                   	cld    
  8009bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d2:	39 c6                	cmp    %eax,%esi
  8009d4:	73 35                	jae    800a0b <memmove+0x47>
  8009d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d9:	39 d0                	cmp    %edx,%eax
  8009db:	73 2e                	jae    800a0b <memmove+0x47>
		s += n;
		d += n;
  8009dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ea:	75 13                	jne    8009ff <memmove+0x3b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 0e                	jne    8009ff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 1d                	jmp    800a28 <memmove+0x64>
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 0f                	jne    800a23 <memmove+0x5f>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 0a                	jne    800a23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a1c:	89 c7                	mov    %eax,%edi
  800a1e:	fc                   	cld    
  800a1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a21:	eb 05                	jmp    800a28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 79 ff ff ff       	call   8009c4 <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5d:	eb 1a                	jmp    800a79 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5f:	0f b6 02             	movzbl (%edx),%eax
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	38 d8                	cmp    %bl,%al
  800a67:	74 0a                	je     800a73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c0             	movzbl %al,%eax
  800a6c:	0f b6 db             	movzbl %bl,%ebx
  800a6f:	29 d8                	sub    %ebx,%eax
  800a71:	eb 0f                	jmp    800a82 <memcmp+0x35>
		s1++, s2++;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a79:	39 f2                	cmp    %esi,%edx
  800a7b:	75 e2                	jne    800a5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a94:	eb 07                	jmp    800a9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 07                	je     800aa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	72 f5                	jb     800a96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	eb 03                	jmp    800ab4 <strtol+0x11>
		s++;
  800ab1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	0f b6 0a             	movzbl (%edx),%ecx
  800ab7:	80 f9 09             	cmp    $0x9,%cl
  800aba:	74 f5                	je     800ab1 <strtol+0xe>
  800abc:	80 f9 20             	cmp    $0x20,%cl
  800abf:	74 f0                	je     800ab1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac1:	80 f9 2b             	cmp    $0x2b,%cl
  800ac4:	75 0a                	jne    800ad0 <strtol+0x2d>
		s++;
  800ac6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ace:	eb 11                	jmp    800ae1 <strtol+0x3e>
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad5:	80 f9 2d             	cmp    $0x2d,%cl
  800ad8:	75 07                	jne    800ae1 <strtol+0x3e>
		s++, neg = 1;
  800ada:	8d 52 01             	lea    0x1(%edx),%edx
  800add:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ae6:	75 15                	jne    800afd <strtol+0x5a>
  800ae8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aeb:	75 10                	jne    800afd <strtol+0x5a>
  800aed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af1:	75 0a                	jne    800afd <strtol+0x5a>
		s += 2, base = 16;
  800af3:	83 c2 02             	add    $0x2,%edx
  800af6:	b8 10 00 00 00       	mov    $0x10,%eax
  800afb:	eb 10                	jmp    800b0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800afd:	85 c0                	test   %eax,%eax
  800aff:	75 0c                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b01:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b03:	80 3a 30             	cmpb   $0x30,(%edx)
  800b06:	75 05                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 0a             	movzbl (%edx),%ecx
  800b18:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b1b:	89 f0                	mov    %esi,%eax
  800b1d:	3c 09                	cmp    $0x9,%al
  800b1f:	77 08                	ja     800b29 <strtol+0x86>
			dig = *s - '0';
  800b21:	0f be c9             	movsbl %cl,%ecx
  800b24:	83 e9 30             	sub    $0x30,%ecx
  800b27:	eb 20                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b2c:	89 f0                	mov    %esi,%eax
  800b2e:	3c 19                	cmp    $0x19,%al
  800b30:	77 08                	ja     800b3a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b32:	0f be c9             	movsbl %cl,%ecx
  800b35:	83 e9 57             	sub    $0x57,%ecx
  800b38:	eb 0f                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b3d:	89 f0                	mov    %esi,%eax
  800b3f:	3c 19                	cmp    $0x19,%al
  800b41:	77 16                	ja     800b59 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b43:	0f be c9             	movsbl %cl,%ecx
  800b46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b4c:	7d 0f                	jge    800b5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b57:	eb bc                	jmp    800b15 <strtol+0x72>
  800b59:	89 d8                	mov    %ebx,%eax
  800b5b:	eb 02                	jmp    800b5f <strtol+0xbc>
  800b5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b63:	74 05                	je     800b6a <strtol+0xc7>
		*endptr = (char *) s;
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b6a:	f7 d8                	neg    %eax
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 c6                	mov    %eax,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 cb                	mov    %ecx,%ebx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	89 ce                	mov    %ecx,%esi
  800bcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 28                	jle    800bfd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800be0:	00 
  800be1:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800be8:	00 
  800be9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf0:	00 
  800bf1:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800bf8:	e8 9f 02 00 00       	call   800e9c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfd:	83 c4 2c             	add    $0x2c,%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 02 00 00 00       	mov    $0x2,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_yield>:

void
sys_yield(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	89 f7                	mov    %esi,%edi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c8a:	e8 0d 02 00 00       	call   800e9c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8f:	83 c4 2c             	add    $0x2c,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cdd:	e8 ba 01 00 00       	call   800e9c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce2:	83 c4 2c             	add    $0x2c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 28                	jle    800d35 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d18:	00 
  800d19:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d30:	e8 67 01 00 00       	call   800e9c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d35:	83 c4 2c             	add    $0x2c,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 28                	jle    800d88 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d73:	00 
  800d74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7b:	00 
  800d7c:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d83:	e8 14 01 00 00       	call   800e9c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d88:	83 c4 2c             	add    $0x2c,%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 28                	jle    800ddb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dce:	00 
  800dcf:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800dd6:	e8 c1 00 00 00       	call   800e9c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddb:	83 c4 2c             	add    $0x2c,%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	be 00 00 00 00       	mov    $0x0,%esi
  800dee:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 cb                	mov    %ecx,%ebx
  800e1e:	89 cf                	mov    %ecx,%edi
  800e20:	89 ce                	mov    %ecx,%esi
  800e22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 28                	jle    800e50 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e33:	00 
  800e34:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e43:	00 
  800e44:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e4b:	e8 4c 00 00 00       	call   800e9c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e50:	83 c4 2c             	add    $0x2c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e5e:	c7 44 24 08 bf 14 80 	movl   $0x8014bf,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 b3 14 80 00 	movl   $0x8014b3,(%esp)
  800e75:	e8 22 00 00 00       	call   800e9c <_panic>

00800e7a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800e80:	c7 44 24 08 be 14 80 	movl   $0x8014be,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 b3 14 80 00 	movl   $0x8014b3,(%esp)
  800e97:	e8 00 00 00 00       	call   800e9c <_panic>

00800e9c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ea4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ea7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ead:	e8 53 fd ff ff       	call   800c05 <sys_getenvid>
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ec0:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec8:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  800ecf:	e8 d7 f2 ff ff       	call   8001ab <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ed4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  800edb:	89 04 24             	mov    %eax,(%esp)
  800ede:	e8 67 f2 ff ff       	call   80014a <vcprintf>
	cprintf("\n");
  800ee3:	c7 04 24 34 12 80 00 	movl   $0x801234,(%esp)
  800eea:	e8 bc f2 ff ff       	call   8001ab <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eef:	cc                   	int3   
  800ef0:	eb fd                	jmp    800eef <_panic+0x53>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f0a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f0e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f12:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f16:	85 c0                	test   %eax,%eax
  800f18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1c:	89 ea                	mov    %ebp,%edx
  800f1e:	89 0c 24             	mov    %ecx,(%esp)
  800f21:	75 2d                	jne    800f50 <__udivdi3+0x50>
  800f23:	39 e9                	cmp    %ebp,%ecx
  800f25:	77 61                	ja     800f88 <__udivdi3+0x88>
  800f27:	85 c9                	test   %ecx,%ecx
  800f29:	89 ce                	mov    %ecx,%esi
  800f2b:	75 0b                	jne    800f38 <__udivdi3+0x38>
  800f2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f32:	31 d2                	xor    %edx,%edx
  800f34:	f7 f1                	div    %ecx
  800f36:	89 c6                	mov    %eax,%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	89 e8                	mov    %ebp,%eax
  800f3c:	f7 f6                	div    %esi
  800f3e:	89 c5                	mov    %eax,%ebp
  800f40:	89 f8                	mov    %edi,%eax
  800f42:	f7 f6                	div    %esi
  800f44:	89 ea                	mov    %ebp,%edx
  800f46:	83 c4 0c             	add    $0xc,%esp
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	39 e8                	cmp    %ebp,%eax
  800f52:	77 24                	ja     800f78 <__udivdi3+0x78>
  800f54:	0f bd e8             	bsr    %eax,%ebp
  800f57:	83 f5 1f             	xor    $0x1f,%ebp
  800f5a:	75 3c                	jne    800f98 <__udivdi3+0x98>
  800f5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f60:	39 34 24             	cmp    %esi,(%esp)
  800f63:	0f 86 9f 00 00 00    	jbe    801008 <__udivdi3+0x108>
  800f69:	39 d0                	cmp    %edx,%eax
  800f6b:	0f 82 97 00 00 00    	jb     801008 <__udivdi3+0x108>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	31 c0                	xor    %eax,%eax
  800f7c:	83 c4 0c             	add    $0xc,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 f8                	mov    %edi,%eax
  800f8a:	f7 f1                	div    %ecx
  800f8c:	31 d2                	xor    %edx,%edx
  800f8e:	83 c4 0c             	add    $0xc,%esp
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	8b 3c 24             	mov    (%esp),%edi
  800f9d:	d3 e0                	shl    %cl,%eax
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa6:	29 e8                	sub    %ebp,%eax
  800fa8:	89 c1                	mov    %eax,%ecx
  800faa:	d3 ef                	shr    %cl,%edi
  800fac:	89 e9                	mov    %ebp,%ecx
  800fae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fb2:	8b 3c 24             	mov    (%esp),%edi
  800fb5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fb9:	89 d6                	mov    %edx,%esi
  800fbb:	d3 e7                	shl    %cl,%edi
  800fbd:	89 c1                	mov    %eax,%ecx
  800fbf:	89 3c 24             	mov    %edi,(%esp)
  800fc2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc6:	d3 ee                	shr    %cl,%esi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	d3 e2                	shl    %cl,%edx
  800fcc:	89 c1                	mov    %eax,%ecx
  800fce:	d3 ef                	shr    %cl,%edi
  800fd0:	09 d7                	or     %edx,%edi
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	f7 74 24 08          	divl   0x8(%esp)
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	f7 24 24             	mull   (%esp)
  800fe1:	39 d6                	cmp    %edx,%esi
  800fe3:	89 14 24             	mov    %edx,(%esp)
  800fe6:	72 30                	jb     801018 <__udivdi3+0x118>
  800fe8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fec:	89 e9                	mov    %ebp,%ecx
  800fee:	d3 e2                	shl    %cl,%edx
  800ff0:	39 c2                	cmp    %eax,%edx
  800ff2:	73 05                	jae    800ff9 <__udivdi3+0xf9>
  800ff4:	3b 34 24             	cmp    (%esp),%esi
  800ff7:	74 1f                	je     801018 <__udivdi3+0x118>
  800ff9:	89 f8                	mov    %edi,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	e9 7a ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	31 d2                	xor    %edx,%edx
  80100a:	b8 01 00 00 00       	mov    $0x1,%eax
  80100f:	e9 68 ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	8d 47 ff             	lea    -0x1(%edi),%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 0c             	add    $0xc,%esp
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    
  801024:	66 90                	xchg   %ax,%ax
  801026:	66 90                	xchg   %ax,%ax
  801028:	66 90                	xchg   %ax,%ax
  80102a:	66 90                	xchg   %ax,%ax
  80102c:	66 90                	xchg   %ax,%ax
  80102e:	66 90                	xchg   %ax,%ax

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	83 ec 14             	sub    $0x14,%esp
  801036:	8b 44 24 28          	mov    0x28(%esp),%eax
  80103a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80103e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801042:	89 c7                	mov    %eax,%edi
  801044:	89 44 24 04          	mov    %eax,0x4(%esp)
  801048:	8b 44 24 30          	mov    0x30(%esp),%eax
  80104c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801050:	89 34 24             	mov    %esi,(%esp)
  801053:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801057:	85 c0                	test   %eax,%eax
  801059:	89 c2                	mov    %eax,%edx
  80105b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105f:	75 17                	jne    801078 <__umoddi3+0x48>
  801061:	39 fe                	cmp    %edi,%esi
  801063:	76 4b                	jbe    8010b0 <__umoddi3+0x80>
  801065:	89 c8                	mov    %ecx,%eax
  801067:	89 fa                	mov    %edi,%edx
  801069:	f7 f6                	div    %esi
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	83 c4 14             	add    $0x14,%esp
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
  801076:	66 90                	xchg   %ax,%ax
  801078:	39 f8                	cmp    %edi,%eax
  80107a:	77 54                	ja     8010d0 <__umoddi3+0xa0>
  80107c:	0f bd e8             	bsr    %eax,%ebp
  80107f:	83 f5 1f             	xor    $0x1f,%ebp
  801082:	75 5c                	jne    8010e0 <__umoddi3+0xb0>
  801084:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801088:	39 3c 24             	cmp    %edi,(%esp)
  80108b:	0f 87 e7 00 00 00    	ja     801178 <__umoddi3+0x148>
  801091:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801095:	29 f1                	sub    %esi,%ecx
  801097:	19 c7                	sbb    %eax,%edi
  801099:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010a9:	83 c4 14             	add    $0x14,%esp
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	89 f5                	mov    %esi,%ebp
  8010b4:	75 0b                	jne    8010c1 <__umoddi3+0x91>
  8010b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	f7 f6                	div    %esi
  8010bf:	89 c5                	mov    %eax,%ebp
  8010c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010c5:	31 d2                	xor    %edx,%edx
  8010c7:	f7 f5                	div    %ebp
  8010c9:	89 c8                	mov    %ecx,%eax
  8010cb:	f7 f5                	div    %ebp
  8010cd:	eb 9c                	jmp    80106b <__umoddi3+0x3b>
  8010cf:	90                   	nop
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 fa                	mov    %edi,%edx
  8010d4:	83 c4 14             	add    $0x14,%esp
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	8b 04 24             	mov    (%esp),%eax
  8010e3:	be 20 00 00 00       	mov    $0x20,%esi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	29 ee                	sub    %ebp,%esi
  8010ec:	d3 e2                	shl    %cl,%edx
  8010ee:	89 f1                	mov    %esi,%ecx
  8010f0:	d3 e8                	shr    %cl,%eax
  8010f2:	89 e9                	mov    %ebp,%ecx
  8010f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f8:	8b 04 24             	mov    (%esp),%eax
  8010fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	d3 e0                	shl    %cl,%eax
  801103:	89 f1                	mov    %esi,%ecx
  801105:	89 44 24 08          	mov    %eax,0x8(%esp)
  801109:	8b 44 24 10          	mov    0x10(%esp),%eax
  80110d:	d3 ea                	shr    %cl,%edx
  80110f:	89 e9                	mov    %ebp,%ecx
  801111:	d3 e7                	shl    %cl,%edi
  801113:	89 f1                	mov    %esi,%ecx
  801115:	d3 e8                	shr    %cl,%eax
  801117:	89 e9                	mov    %ebp,%ecx
  801119:	09 f8                	or     %edi,%eax
  80111b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80111f:	f7 74 24 04          	divl   0x4(%esp)
  801123:	d3 e7                	shl    %cl,%edi
  801125:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801129:	89 d7                	mov    %edx,%edi
  80112b:	f7 64 24 08          	mull   0x8(%esp)
  80112f:	39 d7                	cmp    %edx,%edi
  801131:	89 c1                	mov    %eax,%ecx
  801133:	89 14 24             	mov    %edx,(%esp)
  801136:	72 2c                	jb     801164 <__umoddi3+0x134>
  801138:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80113c:	72 22                	jb     801160 <__umoddi3+0x130>
  80113e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801142:	29 c8                	sub    %ecx,%eax
  801144:	19 d7                	sbb    %edx,%edi
  801146:	89 e9                	mov    %ebp,%ecx
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 e8                	shr    %cl,%eax
  80114c:	89 f1                	mov    %esi,%ecx
  80114e:	d3 e2                	shl    %cl,%edx
  801150:	89 e9                	mov    %ebp,%ecx
  801152:	d3 ef                	shr    %cl,%edi
  801154:	09 d0                	or     %edx,%eax
  801156:	89 fa                	mov    %edi,%edx
  801158:	83 c4 14             	add    $0x14,%esp
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
  80115f:	90                   	nop
  801160:	39 d7                	cmp    %edx,%edi
  801162:	75 da                	jne    80113e <__umoddi3+0x10e>
  801164:	8b 14 24             	mov    (%esp),%edx
  801167:	89 c1                	mov    %eax,%ecx
  801169:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80116d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801171:	eb cb                	jmp    80113e <__umoddi3+0x10e>
  801173:	90                   	nop
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80117c:	0f 82 0f ff ff ff    	jb     801091 <__umoddi3+0x61>
  801182:	e9 1a ff ff ff       	jmp    8010a1 <__umoddi3+0x71>
