
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
  800047:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  80004e:	e8 6b 01 00 00       	call   8001be <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 67 0f 00 00       	call   800fbf <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 38 16 80 00 	movl   $0x801638,(%esp)
  800065:	e8 54 01 00 00       	call   8001be <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  800073:	e8 46 01 00 00       	call   8001be <cprintf>
	sys_yield();
  800078:	e8 b7 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80007d:	e8 b2 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800082:	e8 ad 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800087:	e8 a8 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 9f 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800095:	e8 9a 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80009a:	e8 95 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 8f 0b 00 00       	call   800c34 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  8000ac:	e8 0d 01 00 00       	call   8001be <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 0a 0b 00 00       	call   800bc3 <sys_env_destroy>
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
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 10             	sub    $0x10,%esp
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000cd:	e8 43 0b 00 00       	call   800c15 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f3:	89 1c 24             	mov    %ebx,(%esp)
  8000f6:	e8 45 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 07 00 00 00       	call   800107 <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80010d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800114:	e8 aa 0a 00 00       	call   800bc3 <sys_env_destroy>
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	53                   	push   %ebx
  80011f:	83 ec 14             	sub    $0x14,%esp
  800122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800125:	8b 13                	mov    (%ebx),%edx
  800127:	8d 42 01             	lea    0x1(%edx),%eax
  80012a:	89 03                	mov    %eax,(%ebx)
  80012c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800133:	3d ff 00 00 00       	cmp    $0xff,%eax
  800138:	75 19                	jne    800153 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800141:	00 
  800142:	8d 43 08             	lea    0x8(%ebx),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 39 0a 00 00       	call   800b86 <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	83 c4 14             	add    $0x14,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800166:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016d:	00 00 00 
	b.cnt = 0;
  800170:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800177:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 44 24 08          	mov    %eax,0x8(%esp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 1b 01 80 00 	movl   $0x80011b,(%esp)
  800199:	e8 76 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 d0 09 00 00       	call   800b86 <sys_cputs>

	return b.cnt;
}
  8001b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 87 ff ff ff       	call   80015d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    
  8001d8:	66 90                	xchg   %ax,%ax
  8001da:	66 90                	xchg   %ax,%ax
  8001dc:	66 90                	xchg   %ax,%ax
  8001de:	66 90                	xchg   %ax,%ax

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 cc 10 00 00       	call   801320 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 9c 11 00 00       	call   801450 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 60 16 80 00 	movsbl 0x801660(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 0a                	jae    8002ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	88 02                	mov    %al,(%edx)
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	e8 02 00 00 00       	call   800314 <vprintfmt>
	va_end(ap);
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 3c             	sub    $0x3c,%esp
  80031d:	8b 75 08             	mov    0x8(%ebp),%esi
  800320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800323:	8b 7d 10             	mov    0x10(%ebp),%edi
  800326:	eb 11                	jmp    800339 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800328:	85 c0                	test   %eax,%eax
  80032a:	0f 84 48 04 00 00    	je     800778 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800330:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	83 c7 01             	add    $0x1,%edi
  80033c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800340:	83 f8 25             	cmp    $0x25,%eax
  800343:	75 e3                	jne    800328 <vprintfmt+0x14>
  800345:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800349:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800350:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800357:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800363:	eb 1f                	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800368:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036c:	eb 16                	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800371:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800375:	eb 0d                	jmp    800384 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800377:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8d 47 01             	lea    0x1(%edi),%eax
  800387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038a:	0f b6 17             	movzbl (%edi),%edx
  80038d:	0f b6 c2             	movzbl %dl,%eax
  800390:	83 ea 23             	sub    $0x23,%edx
  800393:	80 fa 55             	cmp    $0x55,%dl
  800396:	0f 87 bf 03 00 00    	ja     80075b <vprintfmt+0x447>
  80039c:	0f b6 d2             	movzbl %dl,%edx
  80039f:	ff 24 95 20 17 80 00 	jmp    *0x801720(,%edx,4)
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003b4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3c                	ja     8003ff <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 27                	jmp    800405 <vprintfmt+0xf1>
  8003de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	0f 49 c2             	cmovns %edx,%eax
  8003eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 91                	jmp    800384 <vprintfmt+0x70>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	eb 85                	jmp    800384 <vprintfmt+0x70>
  8003ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800402:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	0f 89 75 ff ff ff    	jns    800384 <vprintfmt+0x70>
  80040f:	e9 63 ff ff ff       	jmp    800377 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041a:	e9 65 ff ff ff       	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800422:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800434:	e9 00 ff ff ff       	jmp    800339 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
  800443:	31 d0                	xor    %edx,%eax
  800445:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 09             	cmp    $0x9,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x143>
  80044c:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 20                	jne    800477 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045b:	c7 44 24 08 78 16 80 	movl   $0x801678,0x8(%esp)
  800462:	00 
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 34 24             	mov    %esi,(%esp)
  80046a:	e8 7d fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800472:	e9 c2 fe ff ff       	jmp    800339 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800477:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047b:	c7 44 24 08 81 16 80 	movl   $0x801681,0x8(%esp)
  800482:	00 
  800483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800487:	89 34 24             	mov    %esi,(%esp)
  80048a:	e8 5d fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 a2 fe ff ff       	jmp    800339 <vprintfmt+0x25>
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	b8 71 16 80 00       	mov    $0x801671,%eax
  8004b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b7:	0f 84 92 00 00 00    	je     80054f <vprintfmt+0x23b>
  8004bd:	85 c9                	test   %ecx,%ecx
  8004bf:	0f 8e 98 00 00 00    	jle    80055d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c9:	89 3c 24             	mov    %edi,(%esp)
  8004cc:	e8 47 03 00 00       	call   800818 <strnlen>
  8004d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1d3>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 50                	jmp    800569 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1e                	je     80053d <vprintfmt+0x229>
  80051f:	0f be d2             	movsbl %dl,%edx
  800522:	83 ea 20             	sub    $0x20,%edx
  800525:	83 fa 5e             	cmp    $0x5e,%edx
  800528:	76 13                	jbe    80053d <vprintfmt+0x229>
					putch('?', putdat);
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	eb 0d                	jmp    80054a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80053d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800540:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	83 eb 01             	sub    $0x1,%ebx
  80054d:	eb 1a                	jmp    800569 <vprintfmt+0x255>
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055b:	eb 0c                	jmp    800569 <vprintfmt+0x255>
  80055d:	89 75 08             	mov    %esi,0x8(%ebp)
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800566:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800569:	83 c7 01             	add    $0x1,%edi
  80056c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800570:	0f be c2             	movsbl %dl,%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	74 25                	je     80059c <vprintfmt+0x288>
  800577:	85 f6                	test   %esi,%esi
  800579:	78 9e                	js     800519 <vprintfmt+0x205>
  80057b:	83 ee 01             	sub    $0x1,%esi
  80057e:	79 99                	jns    800519 <vprintfmt+0x205>
  800580:	89 df                	mov    %ebx,%edi
  800582:	8b 75 08             	mov    0x8(%ebp),%esi
  800585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800588:	eb 1a                	jmp    8005a4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	eb 08                	jmp    8005a4 <vprintfmt+0x290>
  80059c:	89 df                	mov    %ebx,%edi
  80059e:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a4:	85 ff                	test   %edi,%edi
  8005a6:	7f e2                	jg     80058a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 89 fd ff ff       	jmp    800339 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7e 19                	jle    8005ce <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 50 04             	mov    0x4(%eax),%edx
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cc:	eb 38                	jmp    800606 <vprintfmt+0x2f2>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 1b                	je     8005ed <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005da:	89 c1                	mov    %eax,%ecx
  8005dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005eb:	eb 19                	jmp    800606 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800606:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800611:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800615:	0f 89 04 01 00 00    	jns    80071f <vprintfmt+0x40b>
				putch('-', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062e:	f7 da                	neg    %edx
  800630:	83 d1 00             	adc    $0x0,%ecx
  800633:	f7 d9                	neg    %ecx
  800635:	e9 e5 00 00 00       	jmp    80071f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063a:	83 f9 01             	cmp    $0x1,%ecx
  80063d:	7e 10                	jle    80064f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	8b 48 04             	mov    0x4(%eax),%ecx
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	eb 26                	jmp    800675 <vprintfmt+0x361>
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 12                	je     800665 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
  800663:	eb 10                	jmp    800675 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800675:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80067a:	e9 a0 00 00 00       	jmp    80071f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80068a:	ff d6                	call   *%esi
			putch('X', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800697:	ff d6                	call   *%esi
			putch('X', putdat);
  800699:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a9:	e9 8b fc ff ff       	jmp    800339 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006dd:	eb 40                	jmp    80071f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ec:	8d 40 08             	lea    0x8(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x406>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
  800708:	eb 10                	jmp    80071a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800723:	89 44 24 10          	mov    %eax,0x10(%esp)
  800727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800732:	89 14 24             	mov    %edx,(%esp)
  800735:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800739:	89 da                	mov    %ebx,%edx
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	e8 9e fa ff ff       	call   8001e0 <printnum>
			break;
  800742:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800745:	e9 ef fb ff ff       	jmp    800339 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800756:	e9 de fb ff ff       	jmp    800339 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800766:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800768:	eb 03                	jmp    80076d <vprintfmt+0x459>
  80076a:	83 ef 01             	sub    $0x1,%edi
  80076d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800771:	75 f7                	jne    80076a <vprintfmt+0x456>
  800773:	e9 c1 fb ff ff       	jmp    800339 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800778:	83 c4 3c             	add    $0x3c,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 28             	sub    $0x28,%esp
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800793:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 30                	je     8007d1 <vsnprintf+0x51>
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	7e 2c                	jle    8007d1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8007af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ba:	c7 04 24 cf 02 80 00 	movl   $0x8002cf,(%esp)
  8007c1:	e8 4e fb ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cf:	eb 05                	jmp    8007d6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	e8 82 ff ff ff       	call   800780 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strlen+0x10>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	75 f7                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strnlen+0x13>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	39 d0                	cmp    %edx,%eax
  80082d:	74 06                	je     800835 <strnlen+0x1d>
  80082f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800833:	75 f3                	jne    800828 <strnlen+0x10>
		n++;
	return n;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800850:	84 db                	test   %bl,%bl
  800852:	75 ef                	jne    800843 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800861:	89 1c 24             	mov    %ebx,(%esp)
  800864:	e8 97 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800870:	01 d8                	add    %ebx,%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 bd ff ff ff       	call   800837 <strcpy>
	return dst;
}
  80087a:	89 d8                	mov    %ebx,%eax
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	89 f3                	mov    %esi,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800892:	89 f2                	mov    %esi,%edx
  800894:	eb 0f                	jmp    8008a5 <strncpy+0x23>
		*dst++ = *src;
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	0f b6 01             	movzbl (%ecx),%eax
  80089c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089f:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	39 da                	cmp    %ebx,%edx
  8008a7:	75 ed                	jne    800896 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	75 0b                	jne    8008d2 <strlcpy+0x23>
  8008c7:	eb 1d                	jmp    8008e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 0b                	je     8008e1 <strlcpy+0x32>
  8008d6:	0f b6 0a             	movzbl (%edx),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	75 ec                	jne    8008c9 <strlcpy+0x1a>
  8008dd:	89 c2                	mov    %eax,%edx
  8008df:	eb 02                	jmp    8008e3 <strlcpy+0x34>
  8008e1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008e6:	29 f0                	sub    %esi,%eax
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f5:	eb 06                	jmp    8008fd <strcmp+0x11>
		p++, q++;
  8008f7:	83 c1 01             	add    $0x1,%ecx
  8008fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fd:	0f b6 01             	movzbl (%ecx),%eax
  800900:	84 c0                	test   %al,%al
  800902:	74 04                	je     800908 <strcmp+0x1c>
  800904:	3a 02                	cmp    (%edx),%al
  800906:	74 ef                	je     8008f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 c3                	mov    %eax,%ebx
  80091e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800921:	eb 06                	jmp    800929 <strncmp+0x17>
		n--, p++, q++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800929:	39 d8                	cmp    %ebx,%eax
  80092b:	74 15                	je     800942 <strncmp+0x30>
  80092d:	0f b6 08             	movzbl (%eax),%ecx
  800930:	84 c9                	test   %cl,%cl
  800932:	74 04                	je     800938 <strncmp+0x26>
  800934:	3a 0a                	cmp    (%edx),%cl
  800936:	74 eb                	je     800923 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 00             	movzbl (%eax),%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
  800940:	eb 05                	jmp    800947 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	eb 07                	jmp    80095d <strchr+0x13>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 0f                	je     800969 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f2                	jne    800956 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	eb 07                	jmp    80097e <strfind+0x13>
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	74 0a                	je     800985 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	0f b6 10             	movzbl (%eax),%edx
  800981:	84 d2                	test   %dl,%dl
  800983:	75 f2                	jne    800977 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800993:	85 c9                	test   %ecx,%ecx
  800995:	74 36                	je     8009cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800997:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099d:	75 28                	jne    8009c7 <memset+0x40>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 23                	jne    8009c7 <memset+0x40>
		c &= 0xFF;
  8009a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a8:	89 d3                	mov    %edx,%ebx
  8009aa:	c1 e3 08             	shl    $0x8,%ebx
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	c1 e6 18             	shl    $0x18,%esi
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	c1 e0 10             	shl    $0x10,%eax
  8009b7:	09 f0                	or     %esi,%eax
  8009b9:	09 c2                	or     %eax,%edx
  8009bb:	89 d0                	mov    %edx,%eax
  8009bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c2:	fc                   	cld    
  8009c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c5:	eb 06                	jmp    8009cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 35                	jae    800a1b <memmove+0x47>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2e                	jae    800a1b <memmove+0x47>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009f0:	89 d6                	mov    %edx,%esi
  8009f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fa:	75 13                	jne    800a0f <memmove+0x3b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 0e                	jne    800a0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a01:	83 ef 04             	sub    $0x4,%edi
  800a04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb 09                	jmp    800a18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0f:	83 ef 01             	sub    $0x1,%edi
  800a12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a15:	fd                   	std    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a18:	fc                   	cld    
  800a19:	eb 1d                	jmp    800a38 <memmove+0x64>
  800a1b:	89 f2                	mov    %esi,%edx
  800a1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	f6 c2 03             	test   $0x3,%dl
  800a22:	75 0f                	jne    800a33 <memmove+0x5f>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	75 0a                	jne    800a33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 05                	jmp    800a38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	fc                   	cld    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
  800a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	e8 79 ff ff ff       	call   8009d4 <memmove>
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6d:	eb 1a                	jmp    800a89 <memcmp+0x2c>
		if (*s1 != *s2)
  800a6f:	0f b6 02             	movzbl (%edx),%eax
  800a72:	0f b6 19             	movzbl (%ecx),%ebx
  800a75:	38 d8                	cmp    %bl,%al
  800a77:	74 0a                	je     800a83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c0             	movzbl %al,%eax
  800a7c:	0f b6 db             	movzbl %bl,%ebx
  800a7f:	29 d8                	sub    %ebx,%eax
  800a81:	eb 0f                	jmp    800a92 <memcmp+0x35>
		s1++, s2++;
  800a83:	83 c2 01             	add    $0x1,%edx
  800a86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a89:	39 f2                	cmp    %esi,%edx
  800a8b:	75 e2                	jne    800a6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa4:	eb 07                	jmp    800aad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	38 08                	cmp    %cl,(%eax)
  800aa8:	74 07                	je     800ab1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	39 d0                	cmp    %edx,%eax
  800aaf:	72 f5                	jb     800aa6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 55 08             	mov    0x8(%ebp),%edx
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abf:	eb 03                	jmp    800ac4 <strtol+0x11>
		s++;
  800ac1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac4:	0f b6 0a             	movzbl (%edx),%ecx
  800ac7:	80 f9 09             	cmp    $0x9,%cl
  800aca:	74 f5                	je     800ac1 <strtol+0xe>
  800acc:	80 f9 20             	cmp    $0x20,%cl
  800acf:	74 f0                	je     800ac1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad1:	80 f9 2b             	cmp    $0x2b,%cl
  800ad4:	75 0a                	jne    800ae0 <strtol+0x2d>
		s++;
  800ad6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb 11                	jmp    800af1 <strtol+0x3e>
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae5:	80 f9 2d             	cmp    $0x2d,%cl
  800ae8:	75 07                	jne    800af1 <strtol+0x3e>
		s++, neg = 1;
  800aea:	8d 52 01             	lea    0x1(%edx),%edx
  800aed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800af6:	75 15                	jne    800b0d <strtol+0x5a>
  800af8:	80 3a 30             	cmpb   $0x30,(%edx)
  800afb:	75 10                	jne    800b0d <strtol+0x5a>
  800afd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b01:	75 0a                	jne    800b0d <strtol+0x5a>
		s += 2, base = 16;
  800b03:	83 c2 02             	add    $0x2,%edx
  800b06:	b8 10 00 00 00       	mov    $0x10,%eax
  800b0b:	eb 10                	jmp    800b1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	75 0c                	jne    800b1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	80 3a 30             	cmpb   $0x30,(%edx)
  800b16:	75 05                	jne    800b1d <strtol+0x6a>
		s++, base = 8;
  800b18:	83 c2 01             	add    $0x1,%edx
  800b1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b25:	0f b6 0a             	movzbl (%edx),%ecx
  800b28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	3c 09                	cmp    $0x9,%al
  800b2f:	77 08                	ja     800b39 <strtol+0x86>
			dig = *s - '0';
  800b31:	0f be c9             	movsbl %cl,%ecx
  800b34:	83 e9 30             	sub    $0x30,%ecx
  800b37:	eb 20                	jmp    800b59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	3c 19                	cmp    $0x19,%al
  800b40:	77 08                	ja     800b4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b42:	0f be c9             	movsbl %cl,%ecx
  800b45:	83 e9 57             	sub    $0x57,%ecx
  800b48:	eb 0f                	jmp    800b59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	3c 19                	cmp    $0x19,%al
  800b51:	77 16                	ja     800b69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b53:	0f be c9             	movsbl %cl,%ecx
  800b56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b5c:	7d 0f                	jge    800b6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b67:	eb bc                	jmp    800b25 <strtol+0x72>
  800b69:	89 d8                	mov    %ebx,%eax
  800b6b:	eb 02                	jmp    800b6f <strtol+0xbc>
  800b6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b73:	74 05                	je     800b7a <strtol+0xc7>
		*endptr = (char *) s;
  800b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b7a:	f7 d8                	neg    %eax
  800b7c:	85 ff                	test   %edi,%edi
  800b7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	89 c6                	mov    %eax,%esi
  800b9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 cb                	mov    %ecx,%ebx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	89 ce                	mov    %ecx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 28                	jle    800c0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800bf8:	00 
  800bf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c00:	00 
  800c01:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800c08:	e8 e7 05 00 00       	call   8011f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0d:	83 c4 2c             	add    $0x2c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 02 00 00 00       	mov    $0x2,%eax
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 d3                	mov    %edx,%ebx
  800c29:	89 d7                	mov    %edx,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_yield>:

void
sys_yield(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	b8 04 00 00 00       	mov    $0x4,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	89 f7                	mov    %esi,%edi
  800c71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800c9a:	e8 55 05 00 00       	call   8011f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9f:	83 c4 2c             	add    $0x2c,%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 28                	jle    800cf2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800cdd:	00 
  800cde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce5:	00 
  800ce6:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800ced:	e8 02 05 00 00       	call   8011f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf2:	83 c4 2c             	add    $0x2c,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 28                	jle    800d45 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d21:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d28:	00 
  800d29:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800d30:	00 
  800d31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d38:	00 
  800d39:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800d40:	e8 af 04 00 00       	call   8011f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d45:	83 c4 2c             	add    $0x2c,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 28                	jle    800d98 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800d83:	00 
  800d84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8b:	00 
  800d8c:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800d93:	e8 5c 04 00 00       	call   8011f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	83 c4 2c             	add    $0x2c,%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800de6:	e8 09 04 00 00       	call   8011f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800deb:	83 c4 2c             	add    $0x2c,%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	be 00 00 00 00       	mov    $0x0,%esi
  800dfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 cb                	mov    %ecx,%ebx
  800e2e:	89 cf                	mov    %ecx,%edi
  800e30:	89 ce                	mov    %ecx,%esi
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 28                	jle    800e60 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e43:	00 
  800e44:	c7 44 24 08 a8 18 80 	movl   $0x8018a8,0x8(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e53:	00 
  800e54:	c7 04 24 c5 18 80 00 	movl   $0x8018c5,(%esp)
  800e5b:	e8 94 03 00 00       	call   8011f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e60:	83 c4 2c             	add    $0x2c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 20             	sub    $0x20,%esp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax


	void *addr = (void *) utf->utf_fault_va;
  800e73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  800e75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e79:	75 2c                	jne    800ea7 <pgfault+0x3f>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800e7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e7f:	c7 04 24 d3 18 80 00 	movl   $0x8018d3,(%esp)
  800e86:	e8 33 f3 ff ff       	call   8001be <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800e8b:	c7 44 24 08 18 19 80 	movl   $0x801918,0x8(%esp)
  800e92:	00 
  800e93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9a:	00 
  800e9b:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  800ea2:	e8 4d 03 00 00       	call   8011f4 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	c1 e8 0c             	shr    $0xc,%eax
  800eac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800eb3:	f6 c4 08             	test   $0x8,%ah
  800eb6:	75 1c                	jne    800ed4 <pgfault+0x6c>
		panic("The pgfault perm is not right\n");
  800eb8:	c7 44 24 08 40 19 80 	movl   $0x801940,0x8(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800ec7:	00 
  800ec8:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  800ecf:	e8 20 03 00 00       	call   8011f4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  800ed4:	e8 3c fd ff ff       	call   800c15 <sys_getenvid>
  800ed9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ee8:	00 
  800ee9:	89 04 24             	mov    %eax,(%esp)
  800eec:	e8 62 fd ff ff       	call   800c53 <sys_page_alloc>
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	79 1c                	jns    800f11 <pgfault+0xa9>
		panic("pgfault sys_page_alloc is not right\n");
  800ef5:	c7 44 24 08 60 19 80 	movl   $0x801960,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  800f0c:	e8 e3 02 00 00       	call   8011f4 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  800f11:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f1e:	00 
  800f1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f23:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f2a:	e8 0d fb ff ff       	call   800a3c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  800f2f:	e8 e1 fc ff ff       	call   800c15 <sys_getenvid>
  800f34:	89 c6                	mov    %eax,%esi
  800f36:	e8 da fc ff ff       	call   800c15 <sys_getenvid>
  800f3b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f42:	00 
  800f43:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f47:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f4b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f52:	00 
  800f53:	89 04 24             	mov    %eax,(%esp)
  800f56:	e8 4c fd ff ff       	call   800ca7 <sys_page_map>
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	79 20                	jns    800f7f <pgfault+0x117>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  800f5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f63:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800f72:	00 
  800f73:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  800f7a:	e8 75 02 00 00       	call   8011f4 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  800f7f:	e8 91 fc ff ff       	call   800c15 <sys_getenvid>
  800f84:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8b:	00 
  800f8c:	89 04 24             	mov    %eax,(%esp)
  800f8f:	e8 66 fd ff ff       	call   800cfa <sys_page_unmap>
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 20                	jns    800fb8 <pgfault+0x150>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  800f98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9c:	c7 44 24 08 b8 19 80 	movl   $0x8019b8,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  800fb3:	e8 3c 02 00 00       	call   8011f4 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  800fc8:	c7 04 24 68 0e 80 00 	movl   $0x800e68,(%esp)
  800fcf:	e8 76 02 00 00       	call   80124a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fd4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd9:	cd 30                	int    $0x30
  800fdb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fde:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 20                	jns    801005 <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  800fe5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fe9:	c7 44 24 08 ec 19 80 	movl   $0x8019ec,0x8(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  800ff8:	00 
  800ff9:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  801000:	e8 ef 01 00 00       	call   8011f4 <_panic>
	if(childEid == 0){
  801005:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801009:	75 1c                	jne    801027 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80100b:	e8 05 fc ff ff       	call   800c15 <sys_getenvid>
  801010:	25 ff 03 00 00       	and    $0x3ff,%eax
  801015:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801018:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80101d:	a3 04 20 80 00       	mov    %eax,0x802004
		return childEid;
  801022:	e9 a0 01 00 00       	jmp    8011c7 <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  801027:	c7 44 24 04 e0 12 80 	movl   $0x8012e0,0x4(%esp)
  80102e:	00 
  80102f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801032:	89 04 24             	mov    %eax,(%esp)
  801035:	e8 66 fd ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  80103a:	89 c7                	mov    %eax,%edi
	if(r < 0)
  80103c:	85 c0                	test   %eax,%eax
  80103e:	79 20                	jns    801060 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801040:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801044:	c7 44 24 08 20 1a 80 	movl   $0x801a20,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801053:	00 
  801054:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  80105b:	e8 94 01 00 00       	call   8011f4 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801060:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801065:	b8 00 00 00 00       	mov    $0x0,%eax
  80106a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 16             	shr    $0x16,%edx
  801077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	0f 84 f7 00 00 00    	je     80117e <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801087:	c1 e8 0c             	shr    $0xc,%eax
  80108a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801091:	f6 c2 04             	test   $0x4,%dl
  801094:	0f 84 e4 00 00 00    	je     80117e <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  80109a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8010a1:	a8 01                	test   $0x1,%al
  8010a3:	0f 84 d5 00 00 00    	je     80117e <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8010a9:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8010af:	75 20                	jne    8010d1 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8010b1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010c0:	ee 
  8010c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010c4:	89 04 24             	mov    %eax,(%esp)
  8010c7:	e8 87 fb ff ff       	call   800c53 <sys_page_alloc>
  8010cc:	e9 84 00 00 00       	jmp    801155 <fork+0x196>
  8010d1:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  8010d7:	89 f8                	mov    %edi,%eax
  8010d9:	c1 e8 0c             	shr    $0xc,%eax
  8010dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  8010e3:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  8010e8:	83 f8 01             	cmp    $0x1,%eax
  8010eb:	19 db                	sbb    %ebx,%ebx
  8010ed:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8010f3:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8010f9:	e8 17 fb ff ff       	call   800c15 <sys_getenvid>
  8010fe:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801102:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801106:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801109:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 8e fb ff ff       	call   800ca7 <sys_page_map>
  801119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 35                	js     801155 <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801120:	e8 f0 fa ff ff       	call   800c15 <sys_getenvid>
  801125:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801128:	e8 e8 fa ff ff       	call   800c15 <sys_getenvid>
  80112d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801131:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801135:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801138:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80113c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	e8 5f fb ff ff       	call   800ca7 <sys_page_map>
  801148:	85 c0                	test   %eax,%eax
  80114a:	bf 00 00 00 00       	mov    $0x0,%edi
  80114f:	0f 4f c7             	cmovg  %edi,%eax
  801152:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801155:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801159:	79 23                	jns    80117e <fork+0x1bf>
  80115b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  80115e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801162:	c7 44 24 08 60 1a 80 	movl   $0x801a60,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  801179:	e8 76 00 00 00       	call   8011f4 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80117e:	89 f1                	mov    %esi,%ecx
  801180:	89 f0                	mov    %esi,%eax
  801182:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801188:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  80118e:	0f 85 de fe ff ff    	jne    801072 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  801194:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80119b:	00 
  80119c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 a6 fb ff ff       	call   800d4d <sys_env_set_status>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	79 1c                	jns    8011c7 <fork+0x208>
		panic("sys_env_set_status");
  8011ab:	c7 44 24 08 ee 18 80 	movl   $0x8018ee,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  8011c2:	e8 2d 00 00 00       	call   8011f4 <_panic>
	return childEid;
}
  8011c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ca:	83 c4 2c             	add    $0x2c,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011d8:	c7 44 24 08 01 19 80 	movl   $0x801901,0x8(%esp)
  8011df:	00 
  8011e0:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8011e7:	00 
  8011e8:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  8011ef:	e8 00 00 00 00       	call   8011f4 <_panic>

008011f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011ff:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801205:	e8 0b fa ff ff       	call   800c15 <sys_getenvid>
  80120a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801211:	8b 55 08             	mov    0x8(%ebp),%edx
  801214:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801218:	89 74 24 08          	mov    %esi,0x8(%esp)
  80121c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801220:	c7 04 24 88 1a 80 00 	movl   $0x801a88,(%esp)
  801227:	e8 92 ef ff ff       	call   8001be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80122c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801230:	8b 45 10             	mov    0x10(%ebp),%eax
  801233:	89 04 24             	mov    %eax,(%esp)
  801236:	e8 22 ef ff ff       	call   80015d <vcprintf>
	cprintf("\n");
  80123b:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  801242:	e8 77 ef ff ff       	call   8001be <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801247:	cc                   	int3   
  801248:	eb fd                	jmp    801247 <_panic+0x53>

0080124a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801250:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801257:	75 44                	jne    80129d <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  801259:	a1 04 20 80 00       	mov    0x802004,%eax
  80125e:	8b 40 48             	mov    0x48(%eax),%eax
  801261:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801268:	00 
  801269:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801270:	ee 
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 da f9 ff ff       	call   800c53 <sys_page_alloc>
		if( r < 0)
  801279:	85 c0                	test   %eax,%eax
  80127b:	79 20                	jns    80129d <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80127d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801281:	c7 44 24 08 ac 1a 80 	movl   $0x801aac,0x8(%esp)
  801288:	00 
  801289:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801290:	00 
  801291:	c7 04 24 08 1b 80 00 	movl   $0x801b08,(%esp)
  801298:	e8 57 ff ff ff       	call   8011f4 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80129d:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a0:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8012a5:	e8 6b f9 ff ff       	call   800c15 <sys_getenvid>
  8012aa:	c7 44 24 04 e0 12 80 	movl   $0x8012e0,0x4(%esp)
  8012b1:	00 
  8012b2:	89 04 24             	mov    %eax,(%esp)
  8012b5:	e8 e6 fa ff ff       	call   800da0 <sys_env_set_pgfault_upcall>
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	79 20                	jns    8012de <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8012be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c2:	c7 44 24 08 dc 1a 80 	movl   $0x801adc,0x8(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8012d1:	00 
  8012d2:	c7 04 24 08 1b 80 00 	movl   $0x801b08,(%esp)
  8012d9:	e8 16 ff ff ff       	call   8011f4 <_panic>


}
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012e0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012e1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012e6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012e8:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8012eb:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8012ef:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8012f3:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8012f7:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8012fa:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8012fd:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  801300:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  801304:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  801308:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  80130c:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801310:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801314:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  801318:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  80131c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  80131d:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80131e:	c3                   	ret    
  80131f:	90                   	nop

00801320 <__udivdi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80132a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80132e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801332:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801336:	85 c0                	test   %eax,%eax
  801338:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133c:	89 ea                	mov    %ebp,%edx
  80133e:	89 0c 24             	mov    %ecx,(%esp)
  801341:	75 2d                	jne    801370 <__udivdi3+0x50>
  801343:	39 e9                	cmp    %ebp,%ecx
  801345:	77 61                	ja     8013a8 <__udivdi3+0x88>
  801347:	85 c9                	test   %ecx,%ecx
  801349:	89 ce                	mov    %ecx,%esi
  80134b:	75 0b                	jne    801358 <__udivdi3+0x38>
  80134d:	b8 01 00 00 00       	mov    $0x1,%eax
  801352:	31 d2                	xor    %edx,%edx
  801354:	f7 f1                	div    %ecx
  801356:	89 c6                	mov    %eax,%esi
  801358:	31 d2                	xor    %edx,%edx
  80135a:	89 e8                	mov    %ebp,%eax
  80135c:	f7 f6                	div    %esi
  80135e:	89 c5                	mov    %eax,%ebp
  801360:	89 f8                	mov    %edi,%eax
  801362:	f7 f6                	div    %esi
  801364:	89 ea                	mov    %ebp,%edx
  801366:	83 c4 0c             	add    $0xc,%esp
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    
  80136d:	8d 76 00             	lea    0x0(%esi),%esi
  801370:	39 e8                	cmp    %ebp,%eax
  801372:	77 24                	ja     801398 <__udivdi3+0x78>
  801374:	0f bd e8             	bsr    %eax,%ebp
  801377:	83 f5 1f             	xor    $0x1f,%ebp
  80137a:	75 3c                	jne    8013b8 <__udivdi3+0x98>
  80137c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801380:	39 34 24             	cmp    %esi,(%esp)
  801383:	0f 86 9f 00 00 00    	jbe    801428 <__udivdi3+0x108>
  801389:	39 d0                	cmp    %edx,%eax
  80138b:	0f 82 97 00 00 00    	jb     801428 <__udivdi3+0x108>
  801391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	31 c0                	xor    %eax,%eax
  80139c:	83 c4 0c             	add    $0xc,%esp
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
  8013a3:	90                   	nop
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	89 f8                	mov    %edi,%eax
  8013aa:	f7 f1                	div    %ecx
  8013ac:	31 d2                	xor    %edx,%edx
  8013ae:	83 c4 0c             	add    $0xc,%esp
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	8b 3c 24             	mov    (%esp),%edi
  8013bd:	d3 e0                	shl    %cl,%eax
  8013bf:	89 c6                	mov    %eax,%esi
  8013c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c6:	29 e8                	sub    %ebp,%eax
  8013c8:	89 c1                	mov    %eax,%ecx
  8013ca:	d3 ef                	shr    %cl,%edi
  8013cc:	89 e9                	mov    %ebp,%ecx
  8013ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013d2:	8b 3c 24             	mov    (%esp),%edi
  8013d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013d9:	89 d6                	mov    %edx,%esi
  8013db:	d3 e7                	shl    %cl,%edi
  8013dd:	89 c1                	mov    %eax,%ecx
  8013df:	89 3c 24             	mov    %edi,(%esp)
  8013e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013e6:	d3 ee                	shr    %cl,%esi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	d3 e2                	shl    %cl,%edx
  8013ec:	89 c1                	mov    %eax,%ecx
  8013ee:	d3 ef                	shr    %cl,%edi
  8013f0:	09 d7                	or     %edx,%edi
  8013f2:	89 f2                	mov    %esi,%edx
  8013f4:	89 f8                	mov    %edi,%eax
  8013f6:	f7 74 24 08          	divl   0x8(%esp)
  8013fa:	89 d6                	mov    %edx,%esi
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	f7 24 24             	mull   (%esp)
  801401:	39 d6                	cmp    %edx,%esi
  801403:	89 14 24             	mov    %edx,(%esp)
  801406:	72 30                	jb     801438 <__udivdi3+0x118>
  801408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	39 c2                	cmp    %eax,%edx
  801412:	73 05                	jae    801419 <__udivdi3+0xf9>
  801414:	3b 34 24             	cmp    (%esp),%esi
  801417:	74 1f                	je     801438 <__udivdi3+0x118>
  801419:	89 f8                	mov    %edi,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	e9 7a ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801428:	31 d2                	xor    %edx,%edx
  80142a:	b8 01 00 00 00       	mov    $0x1,%eax
  80142f:	e9 68 ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	8d 47 ff             	lea    -0x1(%edi),%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	83 c4 0c             	add    $0xc,%esp
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
  801444:	66 90                	xchg   %ax,%ax
  801446:	66 90                	xchg   %ax,%ax
  801448:	66 90                	xchg   %ax,%ax
  80144a:	66 90                	xchg   %ax,%ax
  80144c:	66 90                	xchg   %ax,%ax
  80144e:	66 90                	xchg   %ax,%ax

00801450 <__umoddi3>:
  801450:	55                   	push   %ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	83 ec 14             	sub    $0x14,%esp
  801456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80145a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80145e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801462:	89 c7                	mov    %eax,%edi
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 44 24 30          	mov    0x30(%esp),%eax
  80146c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801470:	89 34 24             	mov    %esi,(%esp)
  801473:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801477:	85 c0                	test   %eax,%eax
  801479:	89 c2                	mov    %eax,%edx
  80147b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80147f:	75 17                	jne    801498 <__umoddi3+0x48>
  801481:	39 fe                	cmp    %edi,%esi
  801483:	76 4b                	jbe    8014d0 <__umoddi3+0x80>
  801485:	89 c8                	mov    %ecx,%eax
  801487:	89 fa                	mov    %edi,%edx
  801489:	f7 f6                	div    %esi
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	31 d2                	xor    %edx,%edx
  80148f:	83 c4 14             	add    $0x14,%esp
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
  801496:	66 90                	xchg   %ax,%ax
  801498:	39 f8                	cmp    %edi,%eax
  80149a:	77 54                	ja     8014f0 <__umoddi3+0xa0>
  80149c:	0f bd e8             	bsr    %eax,%ebp
  80149f:	83 f5 1f             	xor    $0x1f,%ebp
  8014a2:	75 5c                	jne    801500 <__umoddi3+0xb0>
  8014a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014a8:	39 3c 24             	cmp    %edi,(%esp)
  8014ab:	0f 87 e7 00 00 00    	ja     801598 <__umoddi3+0x148>
  8014b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b5:	29 f1                	sub    %esi,%ecx
  8014b7:	19 c7                	sbb    %eax,%edi
  8014b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014c9:	83 c4 14             	add    $0x14,%esp
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
  8014d0:	85 f6                	test   %esi,%esi
  8014d2:	89 f5                	mov    %esi,%ebp
  8014d4:	75 0b                	jne    8014e1 <__umoddi3+0x91>
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	f7 f6                	div    %esi
  8014df:	89 c5                	mov    %eax,%ebp
  8014e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014e5:	31 d2                	xor    %edx,%edx
  8014e7:	f7 f5                	div    %ebp
  8014e9:	89 c8                	mov    %ecx,%eax
  8014eb:	f7 f5                	div    %ebp
  8014ed:	eb 9c                	jmp    80148b <__umoddi3+0x3b>
  8014ef:	90                   	nop
  8014f0:	89 c8                	mov    %ecx,%eax
  8014f2:	89 fa                	mov    %edi,%edx
  8014f4:	83 c4 14             	add    $0x14,%esp
  8014f7:	5e                   	pop    %esi
  8014f8:	5f                   	pop    %edi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    
  8014fb:	90                   	nop
  8014fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801500:	8b 04 24             	mov    (%esp),%eax
  801503:	be 20 00 00 00       	mov    $0x20,%esi
  801508:	89 e9                	mov    %ebp,%ecx
  80150a:	29 ee                	sub    %ebp,%esi
  80150c:	d3 e2                	shl    %cl,%edx
  80150e:	89 f1                	mov    %esi,%ecx
  801510:	d3 e8                	shr    %cl,%eax
  801512:	89 e9                	mov    %ebp,%ecx
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	8b 04 24             	mov    (%esp),%eax
  80151b:	09 54 24 04          	or     %edx,0x4(%esp)
  80151f:	89 fa                	mov    %edi,%edx
  801521:	d3 e0                	shl    %cl,%eax
  801523:	89 f1                	mov    %esi,%ecx
  801525:	89 44 24 08          	mov    %eax,0x8(%esp)
  801529:	8b 44 24 10          	mov    0x10(%esp),%eax
  80152d:	d3 ea                	shr    %cl,%edx
  80152f:	89 e9                	mov    %ebp,%ecx
  801531:	d3 e7                	shl    %cl,%edi
  801533:	89 f1                	mov    %esi,%ecx
  801535:	d3 e8                	shr    %cl,%eax
  801537:	89 e9                	mov    %ebp,%ecx
  801539:	09 f8                	or     %edi,%eax
  80153b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80153f:	f7 74 24 04          	divl   0x4(%esp)
  801543:	d3 e7                	shl    %cl,%edi
  801545:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801549:	89 d7                	mov    %edx,%edi
  80154b:	f7 64 24 08          	mull   0x8(%esp)
  80154f:	39 d7                	cmp    %edx,%edi
  801551:	89 c1                	mov    %eax,%ecx
  801553:	89 14 24             	mov    %edx,(%esp)
  801556:	72 2c                	jb     801584 <__umoddi3+0x134>
  801558:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80155c:	72 22                	jb     801580 <__umoddi3+0x130>
  80155e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801562:	29 c8                	sub    %ecx,%eax
  801564:	19 d7                	sbb    %edx,%edi
  801566:	89 e9                	mov    %ebp,%ecx
  801568:	89 fa                	mov    %edi,%edx
  80156a:	d3 e8                	shr    %cl,%eax
  80156c:	89 f1                	mov    %esi,%ecx
  80156e:	d3 e2                	shl    %cl,%edx
  801570:	89 e9                	mov    %ebp,%ecx
  801572:	d3 ef                	shr    %cl,%edi
  801574:	09 d0                	or     %edx,%eax
  801576:	89 fa                	mov    %edi,%edx
  801578:	83 c4 14             	add    $0x14,%esp
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    
  80157f:	90                   	nop
  801580:	39 d7                	cmp    %edx,%edi
  801582:	75 da                	jne    80155e <__umoddi3+0x10e>
  801584:	8b 14 24             	mov    (%esp),%edx
  801587:	89 c1                	mov    %eax,%ecx
  801589:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80158d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801591:	eb cb                	jmp    80155e <__umoddi3+0x10e>
  801593:	90                   	nop
  801594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801598:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80159c:	0f 82 0f ff ff ff    	jb     8014b1 <__umoddi3+0x61>
  8015a2:	e9 1a ff ff ff       	jmp    8014c1 <__umoddi3+0x71>
