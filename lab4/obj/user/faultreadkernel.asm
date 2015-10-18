
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  80004a:	e8 0c 01 00 00       	call   80015b <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	66 90                	xchg   %ax,%ax
  800053:	90                   	nop

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800066:	e8 29 0b 00 00       	call   800b94 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
  8000a3:	90                   	nop

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 81 0a 00 00       	call   800b37 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	83 c0 01             	add    $0x1,%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 19                	jne    8000f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000de:	00 
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 ee 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f4:	83 c4 14             	add    $0x14,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011e:	8b 45 08             	mov    0x8(%ebp),%eax
  800121:	89 44 24 08          	mov    %eax,0x8(%esp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800136:	e8 92 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 85 09 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 87 ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	66 90                	xchg   %ax,%ax
  800177:	66 90                	xchg   %ax,%ax
  800179:	66 90                	xchg   %ax,%ax
  80017b:	66 90                	xchg   %ax,%ax
  80017d:	66 90                	xchg   %ax,%ax
  80017f:	90                   	nop

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
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	75 08                	jne    8001ac <printnum+0x2c>
  8001a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 59                	ja     800205 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b0:	83 eb 01             	sub    $0x1,%ebx
  8001b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001be:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cd:	00 
  8001ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	e8 e0 0c 00 00       	call   800ec0 <__udivdi3>
  8001e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ef:	89 fa                	mov    %edi,%edx
  8001f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f4:	e8 87 ff ff ff       	call   800180 <printnum>
  8001f9:	eb 11                	jmp    80020c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001ff:	89 34 24             	mov    %esi,(%esp)
  800202:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800205:	83 eb 01             	sub    $0x1,%ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f ef                	jg     8001fb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800222:	00 
  800223:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	e8 bb 0d 00 00       	call   800ff0 <__umoddi3>
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	0f be 80 91 11 80 00 	movsbl 0x801191(%eax),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800246:	83 c4 3c             	add    $0x3c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x38>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800292:	8b 10                	mov    (%eax),%edx
  800294:	3b 50 04             	cmp    0x4(%eax),%edx
  800297:	73 0a                	jae    8002a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  800299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029c:	88 0a                	mov    %cl,(%edx)
  80029e:	83 c2 01             	add    $0x1,%edx
  8002a1:	89 10                	mov    %edx,(%eax)
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	e8 02 00 00 00       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 4c             	sub    $0x4c,%esp
  8002d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dc:	eb 12                	jmp    8002f0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	0f 84 bf 03 00 00    	je     8006a5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8002e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f0:	0f b6 06             	movzbl (%esi),%eax
  8002f3:	83 c6 01             	add    $0x1,%esi
  8002f6:	83 f8 25             	cmp    $0x25,%eax
  8002f9:	75 e3                	jne    8002de <vprintfmt+0x11>
  8002fb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002ff:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800306:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80031a:	eb 2b                	jmp    800347 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 22                	jmp    800347 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 19                	jmp    800347 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 0d                	jmp    800347 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800340:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	0f b6 16             	movzbl (%esi),%edx
  80034a:	0f b6 c2             	movzbl %dl,%eax
  80034d:	8d 7e 01             	lea    0x1(%esi),%edi
  800350:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800353:	83 ea 23             	sub    $0x23,%edx
  800356:	80 fa 55             	cmp    $0x55,%dl
  800359:	0f 87 28 03 00 00    	ja     800687 <vprintfmt+0x3ba>
  80035f:	0f b6 d2             	movzbl %dl,%edx
  800362:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  800369:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80036c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800373:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800378:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80037b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80037f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800382:	8d 50 d0             	lea    -0x30(%eax),%edx
  800385:	83 fa 09             	cmp    $0x9,%edx
  800388:	77 2f                	ja     8003b9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038d:	eb e9                	jmp    800378 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038f:	8b 45 14             	mov    0x14(%ebp),%eax
  800392:	8d 50 04             	lea    0x4(%eax),%edx
  800395:	89 55 14             	mov    %edx,0x14(%ebp)
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a0:	eb 1a                	jmp    8003bc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a9:	79 9c                	jns    800347 <vprintfmt+0x7a>
  8003ab:	eb 81                	jmp    80032e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003b7:	eb 8e                	jmp    800347 <vprintfmt+0x7a>
  8003b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8003bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c0:	79 85                	jns    800347 <vprintfmt+0x7a>
  8003c2:	e9 73 ff ff ff       	jmp    80033a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cd:	e9 75 ff ff ff       	jmp    800347 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	89 04 24             	mov    %eax,(%esp)
  8003e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ea:	e9 01 ff ff ff       	jmp    8002f0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	89 c2                	mov    %eax,%edx
  8003fc:	c1 fa 1f             	sar    $0x1f,%edx
  8003ff:	31 d0                	xor    %edx,%eax
  800401:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800403:	83 f8 09             	cmp    $0x9,%eax
  800406:	7f 0b                	jg     800413 <vprintfmt+0x146>
  800408:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  80040f:	85 d2                	test   %edx,%edx
  800411:	75 23                	jne    800436 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800417:	c7 44 24 08 a9 11 80 	movl   $0x8011a9,0x8(%esp)
  80041e:	00 
  80041f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800423:	8b 7d 08             	mov    0x8(%ebp),%edi
  800426:	89 3c 24             	mov    %edi,(%esp)
  800429:	e8 77 fe ff ff       	call   8002a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800431:	e9 ba fe ff ff       	jmp    8002f0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800436:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043a:	c7 44 24 08 b2 11 80 	movl   $0x8011b2,0x8(%esp)
  800441:	00 
  800442:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800446:	8b 7d 08             	mov    0x8(%ebp),%edi
  800449:	89 3c 24             	mov    %edi,(%esp)
  80044c:	e8 54 fe ff ff       	call   8002a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800454:	e9 97 fe ff ff       	jmp    8002f0 <vprintfmt+0x23>
  800459:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80046d:	85 f6                	test   %esi,%esi
  80046f:	ba a2 11 80 00       	mov    $0x8011a2,%edx
  800474:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800477:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047b:	0f 8e 8c 00 00 00    	jle    80050d <vprintfmt+0x240>
  800481:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800485:	0f 84 82 00 00 00    	je     80050d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048f:	89 34 24             	mov    %esi,(%esp)
  800492:	e8 b1 02 00 00       	call   800748 <strnlen>
  800497:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049a:	29 c2                	sub    %eax,%edx
  80049c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80049f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004a9:	89 de                	mov    %ebx,%esi
  8004ab:	89 d3                	mov    %edx,%ebx
  8004ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	eb 0d                	jmp    8004be <vprintfmt+0x1f1>
					putch(padc, putdat);
  8004b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b5:	89 3c 24             	mov    %edi,(%esp)
  8004b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 eb 01             	sub    $0x1,%ebx
  8004be:	85 db                	test   %ebx,%ebx
  8004c0:	7f ef                	jg     8004b1 <vprintfmt+0x1e4>
  8004c2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c5:	89 f3                	mov    %esi,%ebx
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8004d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004df:	eb 2c                	jmp    80050d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e5:	74 18                	je     8004ff <vprintfmt+0x232>
  8004e7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ea:	83 fa 5e             	cmp    $0x5e,%edx
  8004ed:	76 10                	jbe    8004ff <vprintfmt+0x232>
					putch('?', putdat);
  8004ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	eb 0a                	jmp    800509 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800509:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80050d:	0f be 06             	movsbl (%esi),%eax
  800510:	83 c6 01             	add    $0x1,%esi
  800513:	85 c0                	test   %eax,%eax
  800515:	74 25                	je     80053c <vprintfmt+0x26f>
  800517:	85 ff                	test   %edi,%edi
  800519:	78 c6                	js     8004e1 <vprintfmt+0x214>
  80051b:	83 ef 01             	sub    $0x1,%edi
  80051e:	79 c1                	jns    8004e1 <vprintfmt+0x214>
  800520:	8b 7d 08             	mov    0x8(%ebp),%edi
  800523:	89 de                	mov    %ebx,%esi
  800525:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800528:	eb 1a                	jmp    800544 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800535:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	83 eb 01             	sub    $0x1,%ebx
  80053a:	eb 08                	jmp    800544 <vprintfmt+0x277>
  80053c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053f:	89 de                	mov    %ebx,%esi
  800541:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f e2                	jg     80052a <vprintfmt+0x25d>
  800548:	89 7d 08             	mov    %edi,0x8(%ebp)
  80054b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800550:	e9 9b fd ff ff       	jmp    8002f0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800555:	83 f9 01             	cmp    $0x1,%ecx
  800558:	7e 10                	jle    80056a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 08             	lea    0x8(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 30                	mov    (%eax),%esi
  800565:	8b 78 04             	mov    0x4(%eax),%edi
  800568:	eb 26                	jmp    800590 <vprintfmt+0x2c3>
	else if (lflag)
  80056a:	85 c9                	test   %ecx,%ecx
  80056c:	74 12                	je     800580 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 30                	mov    (%eax),%esi
  800579:	89 f7                	mov    %esi,%edi
  80057b:	c1 ff 1f             	sar    $0x1f,%edi
  80057e:	eb 10                	jmp    800590 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 30                	mov    (%eax),%esi
  80058b:	89 f7                	mov    %esi,%edi
  80058d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800595:	85 ff                	test   %edi,%edi
  800597:	0f 89 ac 00 00 00    	jns    800649 <vprintfmt+0x37c>
				putch('-', putdat);
  80059d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ab:	f7 de                	neg    %esi
  8005ad:	83 d7 00             	adc    $0x0,%edi
  8005b0:	f7 df                	neg    %edi
			}
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 8d 00 00 00       	jmp    800649 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bc:	89 ca                	mov    %ecx,%edx
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 88 fc ff ff       	call   80024e <getuint>
  8005c6:	89 c6                	mov    %eax,%esi
  8005c8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005cf:	eb 78                	jmp    800649 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005dc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ea:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005fe:	e9 ed fc ff ff       	jmp    8002f0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800607:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800615:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800628:	8b 30                	mov    (%eax),%esi
  80062a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800634:	eb 13                	jmp    800649 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800636:	89 ca                	mov    %ecx,%edx
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 0e fc ff ff       	call   80024e <getuint>
  800640:	89 c6                	mov    %eax,%esi
  800642:	89 d7                	mov    %edx,%edi
			base = 16;
  800644:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800649:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80064d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800651:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800654:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800658:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065c:	89 34 24             	mov    %esi,(%esp)
  80065f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800663:	89 da                	mov    %ebx,%edx
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	e8 13 fb ff ff       	call   800180 <printnum>
			break;
  80066d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800670:	e9 7b fc ff ff       	jmp    8002f0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800675:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800682:	e9 69 fc ff ff       	jmp    8002f0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800687:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800695:	eb 03                	jmp    80069a <vprintfmt+0x3cd>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069e:	75 f7                	jne    800697 <vprintfmt+0x3ca>
  8006a0:	e9 4b fc ff ff       	jmp    8002f0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a5:	83 c4 4c             	add    $0x4c,%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 28             	sub    $0x28,%esp
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	74 30                	je     8006fe <vsnprintf+0x51>
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	7e 2c                	jle    8006fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  8006ee:	e8 da fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 82 ff ff ff       	call   8006ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
  80072d:	66 90                	xchg   %ax,%ax
  80072f:	90                   	nop

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 03                	jmp    800740 <strlen+0x10>
		n++;
  80073d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800744:	75 f7                	jne    80073d <strlen+0xd>
		n++;
	return n;
}
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	eb 03                	jmp    80075b <strnlen+0x13>
		n++;
  800758:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	39 d0                	cmp    %edx,%eax
  80075d:	74 06                	je     800765 <strnlen+0x1d>
  80075f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800763:	75 f3                	jne    800758 <strnlen+0x10>
		n++;
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800771:	ba 00 00 00 00       	mov    $0x0,%edx
  800776:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80077a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80077d:	83 c2 01             	add    $0x1,%edx
  800780:	84 c9                	test   %cl,%cl
  800782:	75 f2                	jne    800776 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800791:	89 1c 24             	mov    %ebx,(%esp)
  800794:	e8 97 ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a0:	01 d8                	add    %ebx,%eax
  8007a2:	89 04 24             	mov    %eax,(%esp)
  8007a5:	e8 bd ff ff ff       	call   800767 <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	83 c4 08             	add    $0x8,%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c5:	eb 0f                	jmp    8007d6 <strncpy+0x24>
		*dst++ = *src;
  8007c7:	0f b6 1a             	movzbl (%edx),%ebx
  8007ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	39 f1                	cmp    %esi,%ecx
  8007d8:	75 ed                	jne    8007c7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	75 0a                	jne    8007fc <strlcpy+0x1e>
  8007f2:	eb 1d                	jmp    800811 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f4:	88 18                	mov    %bl,(%eax)
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007fc:	83 ea 01             	sub    $0x1,%edx
  8007ff:	74 0b                	je     80080c <strlcpy+0x2e>
  800801:	0f b6 19             	movzbl (%ecx),%ebx
  800804:	84 db                	test   %bl,%bl
  800806:	75 ec                	jne    8007f4 <strlcpy+0x16>
  800808:	89 c2                	mov    %eax,%edx
  80080a:	eb 02                	jmp    80080e <strlcpy+0x30>
  80080c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80080e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800811:	29 f0                	sub    %esi,%eax
}
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800820:	eb 06                	jmp    800828 <strcmp+0x11>
		p++, q++;
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	84 c0                	test   %al,%al
  80082d:	74 04                	je     800833 <strcmp+0x1c>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	74 ef                	je     800822 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 c0             	movzbl %al,%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80084a:	eb 09                	jmp    800855 <strncmp+0x18>
		n--, p++, q++;
  80084c:	83 ea 01             	sub    $0x1,%edx
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800855:	85 d2                	test   %edx,%edx
  800857:	74 15                	je     80086e <strncmp+0x31>
  800859:	0f b6 18             	movzbl (%eax),%ebx
  80085c:	84 db                	test   %bl,%bl
  80085e:	74 04                	je     800864 <strncmp+0x27>
  800860:	3a 19                	cmp    (%ecx),%bl
  800862:	74 e8                	je     80084c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 00             	movzbl (%eax),%eax
  800867:	0f b6 11             	movzbl (%ecx),%edx
  80086a:	29 d0                	sub    %edx,%eax
  80086c:	eb 05                	jmp    800873 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800880:	eb 07                	jmp    800889 <strchr+0x13>
		if (*s == c)
  800882:	38 ca                	cmp    %cl,%dl
  800884:	74 0f                	je     800895 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	0f b6 10             	movzbl (%eax),%edx
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f2                	jne    800882 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	eb 07                	jmp    8008aa <strfind+0x13>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	74 0a                	je     8008b1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 10             	movzbl (%eax),%edx
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f2                	jne    8008a3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 0c             	sub    $0xc,%esp
  8008b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cb:	85 c9                	test   %ecx,%ecx
  8008cd:	74 30                	je     8008ff <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d5:	75 25                	jne    8008fc <memset+0x49>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 20                	jne    8008fc <memset+0x49>
		c &= 0xFF;
  8008dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	c1 e3 08             	shl    $0x8,%ebx
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	c1 e6 18             	shl    $0x18,%esi
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 10             	shl    $0x10,%eax
  8008ee:	09 f0                	or     %esi,%eax
  8008f0:	09 d0                	or     %edx,%eax
  8008f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 03                	jmp    8008ff <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	fc                   	cld    
  8008fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800904:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800907:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80090a:	89 ec                	mov    %ebp,%esp
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800917:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800923:	39 c6                	cmp    %eax,%esi
  800925:	73 36                	jae    80095d <memmove+0x4f>
  800927:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092a:	39 d0                	cmp    %edx,%eax
  80092c:	73 2f                	jae    80095d <memmove+0x4f>
		s += n;
		d += n;
  80092e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800931:	f6 c2 03             	test   $0x3,%dl
  800934:	75 1b                	jne    800951 <memmove+0x43>
  800936:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093c:	75 13                	jne    800951 <memmove+0x43>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 0e                	jne    800951 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800943:	83 ef 04             	sub    $0x4,%edi
  800946:	8d 72 fc             	lea    -0x4(%edx),%esi
  800949:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094c:	fd                   	std    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 09                	jmp    80095a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800951:	83 ef 01             	sub    $0x1,%edi
  800954:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800957:	fd                   	std    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095a:	fc                   	cld    
  80095b:	eb 20                	jmp    80097d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x6a>
  800965:	a8 03                	test   $0x3,%al
  800967:	75 0f                	jne    800978 <memmove+0x6a>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0a                	jne    800978 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800980:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800983:	89 ec                	mov    %ebp,%esp
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098d:	8b 45 10             	mov    0x10(%ebp),%eax
  800990:	89 44 24 08          	mov    %eax,0x8(%esp)
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 68 ff ff ff       	call   80090e <memmove>
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bc:	eb 1a                	jmp    8009d8 <memcmp+0x30>
		if (*s1 != *s2)
  8009be:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  8009c2:	83 c2 01             	add    $0x1,%edx
  8009c5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  8009ca:	38 c8                	cmp    %cl,%al
  8009cc:	74 0a                	je     8009d8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  8009ce:	0f b6 c0             	movzbl %al,%eax
  8009d1:	0f b6 c9             	movzbl %cl,%ecx
  8009d4:	29 c8                	sub    %ecx,%eax
  8009d6:	eb 09                	jmp    8009e1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	39 da                	cmp    %ebx,%edx
  8009da:	75 e2                	jne    8009be <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f4:	eb 07                	jmp    8009fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	38 08                	cmp    %cl,(%eax)
  8009f8:	74 07                	je     800a01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	72 f5                	jb     8009f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	eb 03                	jmp    800a14 <strtol+0x11>
		s++;
  800a11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	0f b6 02             	movzbl (%edx),%eax
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f6                	je     800a11 <strtol+0xe>
  800a1b:	3c 09                	cmp    $0x9,%al
  800a1d:	74 f2                	je     800a11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1f:	3c 2b                	cmp    $0x2b,%al
  800a21:	75 0a                	jne    800a2d <strtol+0x2a>
		s++;
  800a23:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 10                	jmp    800a3d <strtol+0x3a>
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a32:	3c 2d                	cmp    $0x2d,%al
  800a34:	75 07                	jne    800a3d <strtol+0x3a>
		s++, neg = 1;
  800a36:	8d 52 01             	lea    0x1(%edx),%edx
  800a39:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	0f 94 c0             	sete   %al
  800a42:	74 05                	je     800a49 <strtol+0x46>
  800a44:	83 fb 10             	cmp    $0x10,%ebx
  800a47:	75 15                	jne    800a5e <strtol+0x5b>
  800a49:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4c:	75 10                	jne    800a5e <strtol+0x5b>
  800a4e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a52:	75 0a                	jne    800a5e <strtol+0x5b>
		s += 2, base = 16;
  800a54:	83 c2 02             	add    $0x2,%edx
  800a57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5c:	eb 13                	jmp    800a71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 0f                	je     800a71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a67:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6a:	75 05                	jne    800a71 <strtol+0x6e>
		s++, base = 8;
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	0f b6 0a             	movzbl (%edx),%ecx
  800a7b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7e:	80 fb 09             	cmp    $0x9,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x88>
			dig = *s - '0';
  800a83:	0f be c9             	movsbl %cl,%ecx
  800a86:	83 e9 30             	sub    $0x30,%ecx
  800a89:	eb 1e                	jmp    800aa9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a8b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x98>
			dig = *s - 'a' + 10;
  800a93:	0f be c9             	movsbl %cl,%ecx
  800a96:	83 e9 57             	sub    $0x57,%ecx
  800a99:	eb 0e                	jmp    800aa9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800a9b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 14                	ja     800ab7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa9:	39 f1                	cmp    %esi,%ecx
  800aab:	7d 0e                	jge    800abb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	0f af c6             	imul   %esi,%eax
  800ab3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb c1                	jmp    800a78 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab7:	89 c1                	mov    %eax,%ecx
  800ab9:	eb 02                	jmp    800abd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 05                	je     800ac8 <strtol+0xc5>
		*endptr = (char *) s;
  800ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac8:	89 ca                	mov    %ecx,%edx
  800aca:	f7 da                	neg    %edx
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 45 c2             	cmovne %edx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
  800ad6:	66 90                	xchg   %ax,%ax

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ae1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ae4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800afd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b03:	89 ec                	mov    %ebp,%esp
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 0c             	sub    $0xc,%esp
  800b0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b2d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b33:	89 ec                	mov    %ebp,%esp
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 38             	sub    $0x38,%esp
  800b3d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b40:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b43:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 cb                	mov    %ecx,%ebx
  800b55:	89 cf                	mov    %ecx,%edi
  800b57:	89 ce                	mov    %ecx,%esi
  800b59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 28                	jle    800b87 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b63:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b6a:	00 
  800b6b:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800b72:	00 
  800b73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b7a:	00 
  800b7b:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800b82:	e8 d5 02 00 00       	call   800e5c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b90:	89 ec                	mov    %ebp,%esp
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc0:	89 ec                	mov    %ebp,%esp
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bcd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf0:	89 ec                	mov    %ebp,%esp
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 38             	sub    $0x38,%esp
  800bfa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bfd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c00:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	be 00 00 00 00       	mov    $0x0,%esi
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 f7                	mov    %esi,%edi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 28                	jle    800c46 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c22:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c29:	00 
  800c2a:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800c31:	00 
  800c32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c39:	00 
  800c3a:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800c41:	e8 16 02 00 00       	call   800e5c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4f:	89 ec                	mov    %ebp,%esp
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 38             	sub    $0x38,%esp
  800c59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 28                	jle    800ca4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c87:	00 
  800c88:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c97:	00 
  800c98:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800c9f:	e8 b8 01 00 00       	call   800e5c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800caa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cad:	89 ec                	mov    %ebp,%esp
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 38             	sub    $0x38,%esp
  800cb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 28                	jle    800d02 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cde:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800ced:	00 
  800cee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf5:	00 
  800cf6:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800cfd:	e8 5a 01 00 00       	call   800e5c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 38             	sub    $0x38,%esp
  800d15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 08 00 00 00       	mov    $0x8,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 28                	jle    800d60 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d43:	00 
  800d44:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d53:	00 
  800d54:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800d5b:	e8 fc 00 00 00       	call   800e5c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d60:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d63:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d69:	89 ec                	mov    %ebp,%esp
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 38             	sub    $0x38,%esp
  800d73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d79:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 09 00 00 00       	mov    $0x9,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800db9:	e8 9e 00 00 00       	call   800e5c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfb:	89 ec                	mov    %ebp,%esp
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 38             	sub    $0x38,%esp
  800e05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 28                	jle    800e4f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e32:	00 
  800e33:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 05 14 80 00 	movl   $0x801405,(%esp)
  800e4a:	e8 0d 00 00 00       	call   800e5c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e64:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e67:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e6d:	e8 22 fd ff ff       	call   800b94 <sys_getenvid>
  800e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e75:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e88:	c7 04 24 14 14 80 00 	movl   $0x801414,(%esp)
  800e8f:	e8 c7 f2 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e98:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9b:	89 04 24             	mov    %eax,(%esp)
  800e9e:	e8 57 f2 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800ea3:	c7 04 24 38 14 80 00 	movl   $0x801438,(%esp)
  800eaa:	e8 ac f2 ff ff       	call   80015b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eaf:	cc                   	int3   
  800eb0:	eb fd                	jmp    800eaf <_panic+0x53>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__udivdi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ece:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ed2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800edc:	89 ea                	mov    %ebp,%edx
  800ede:	89 0c 24             	mov    %ecx,(%esp)
  800ee1:	75 2d                	jne    800f10 <__udivdi3+0x50>
  800ee3:	39 e9                	cmp    %ebp,%ecx
  800ee5:	77 61                	ja     800f48 <__udivdi3+0x88>
  800ee7:	85 c9                	test   %ecx,%ecx
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	75 0b                	jne    800ef8 <__udivdi3+0x38>
  800eed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef2:	31 d2                	xor    %edx,%edx
  800ef4:	f7 f1                	div    %ecx
  800ef6:	89 c6                	mov    %eax,%esi
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	89 e8                	mov    %ebp,%eax
  800efc:	f7 f6                	div    %esi
  800efe:	89 c5                	mov    %eax,%ebp
  800f00:	89 f8                	mov    %edi,%eax
  800f02:	f7 f6                	div    %esi
  800f04:	89 ea                	mov    %ebp,%edx
  800f06:	83 c4 0c             	add    $0xc,%esp
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
  800f0d:	8d 76 00             	lea    0x0(%esi),%esi
  800f10:	39 e8                	cmp    %ebp,%eax
  800f12:	77 24                	ja     800f38 <__udivdi3+0x78>
  800f14:	0f bd e8             	bsr    %eax,%ebp
  800f17:	83 f5 1f             	xor    $0x1f,%ebp
  800f1a:	75 3c                	jne    800f58 <__udivdi3+0x98>
  800f1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f20:	39 34 24             	cmp    %esi,(%esp)
  800f23:	0f 86 9f 00 00 00    	jbe    800fc8 <__udivdi3+0x108>
  800f29:	39 d0                	cmp    %edx,%eax
  800f2b:	0f 82 97 00 00 00    	jb     800fc8 <__udivdi3+0x108>
  800f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	31 c0                	xor    %eax,%eax
  800f3c:	83 c4 0c             	add    $0xc,%esp
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	89 f8                	mov    %edi,%eax
  800f4a:	f7 f1                	div    %ecx
  800f4c:	31 d2                	xor    %edx,%edx
  800f4e:	83 c4 0c             	add    $0xc,%esp
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
  800f55:	8d 76 00             	lea    0x0(%esi),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	8b 3c 24             	mov    (%esp),%edi
  800f5d:	d3 e0                	shl    %cl,%eax
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	b8 20 00 00 00       	mov    $0x20,%eax
  800f66:	29 e8                	sub    %ebp,%eax
  800f68:	89 c1                	mov    %eax,%ecx
  800f6a:	d3 ef                	shr    %cl,%edi
  800f6c:	89 e9                	mov    %ebp,%ecx
  800f6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f72:	8b 3c 24             	mov    (%esp),%edi
  800f75:	09 74 24 08          	or     %esi,0x8(%esp)
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	d3 e7                	shl    %cl,%edi
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	89 3c 24             	mov    %edi,(%esp)
  800f82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f86:	d3 ee                	shr    %cl,%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	d3 e2                	shl    %cl,%edx
  800f8c:	89 c1                	mov    %eax,%ecx
  800f8e:	d3 ef                	shr    %cl,%edi
  800f90:	09 d7                	or     %edx,%edi
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	f7 74 24 08          	divl   0x8(%esp)
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	89 c7                	mov    %eax,%edi
  800f9e:	f7 24 24             	mull   (%esp)
  800fa1:	39 d6                	cmp    %edx,%esi
  800fa3:	89 14 24             	mov    %edx,(%esp)
  800fa6:	72 30                	jb     800fd8 <__udivdi3+0x118>
  800fa8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fac:	89 e9                	mov    %ebp,%ecx
  800fae:	d3 e2                	shl    %cl,%edx
  800fb0:	39 c2                	cmp    %eax,%edx
  800fb2:	73 05                	jae    800fb9 <__udivdi3+0xf9>
  800fb4:	3b 34 24             	cmp    (%esp),%esi
  800fb7:	74 1f                	je     800fd8 <__udivdi3+0x118>
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	e9 7a ff ff ff       	jmp    800f3c <__udivdi3+0x7c>
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	31 d2                	xor    %edx,%edx
  800fca:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcf:	e9 68 ff ff ff       	jmp    800f3c <__udivdi3+0x7c>
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	83 c4 0c             	add    $0xc,%esp
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
  800fe4:	66 90                	xchg   %ax,%ax
  800fe6:	66 90                	xchg   %ax,%ax
  800fe8:	66 90                	xchg   %ax,%ax
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	83 ec 14             	sub    $0x14,%esp
  800ff6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ffa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ffe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801002:	89 c7                	mov    %eax,%edi
  801004:	89 44 24 04          	mov    %eax,0x4(%esp)
  801008:	8b 44 24 30          	mov    0x30(%esp),%eax
  80100c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801010:	89 34 24             	mov    %esi,(%esp)
  801013:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801017:	85 c0                	test   %eax,%eax
  801019:	89 c2                	mov    %eax,%edx
  80101b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80101f:	75 17                	jne    801038 <__umoddi3+0x48>
  801021:	39 fe                	cmp    %edi,%esi
  801023:	76 4b                	jbe    801070 <__umoddi3+0x80>
  801025:	89 c8                	mov    %ecx,%eax
  801027:	89 fa                	mov    %edi,%edx
  801029:	f7 f6                	div    %esi
  80102b:	89 d0                	mov    %edx,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	83 c4 14             	add    $0x14,%esp
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	66 90                	xchg   %ax,%ax
  801038:	39 f8                	cmp    %edi,%eax
  80103a:	77 54                	ja     801090 <__umoddi3+0xa0>
  80103c:	0f bd e8             	bsr    %eax,%ebp
  80103f:	83 f5 1f             	xor    $0x1f,%ebp
  801042:	75 5c                	jne    8010a0 <__umoddi3+0xb0>
  801044:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801048:	39 3c 24             	cmp    %edi,(%esp)
  80104b:	0f 87 e7 00 00 00    	ja     801138 <__umoddi3+0x148>
  801051:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801055:	29 f1                	sub    %esi,%ecx
  801057:	19 c7                	sbb    %eax,%edi
  801059:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801061:	8b 44 24 08          	mov    0x8(%esp),%eax
  801065:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801069:	83 c4 14             	add    $0x14,%esp
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
  801070:	85 f6                	test   %esi,%esi
  801072:	89 f5                	mov    %esi,%ebp
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f6                	div    %esi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	8b 44 24 04          	mov    0x4(%esp),%eax
  801085:	31 d2                	xor    %edx,%edx
  801087:	f7 f5                	div    %ebp
  801089:	89 c8                	mov    %ecx,%eax
  80108b:	f7 f5                	div    %ebp
  80108d:	eb 9c                	jmp    80102b <__umoddi3+0x3b>
  80108f:	90                   	nop
  801090:	89 c8                	mov    %ecx,%eax
  801092:	89 fa                	mov    %edi,%edx
  801094:	83 c4 14             	add    $0x14,%esp
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    
  80109b:	90                   	nop
  80109c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	8b 04 24             	mov    (%esp),%eax
  8010a3:	be 20 00 00 00       	mov    $0x20,%esi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	29 ee                	sub    %ebp,%esi
  8010ac:	d3 e2                	shl    %cl,%edx
  8010ae:	89 f1                	mov    %esi,%ecx
  8010b0:	d3 e8                	shr    %cl,%eax
  8010b2:	89 e9                	mov    %ebp,%ecx
  8010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b8:	8b 04 24             	mov    (%esp),%eax
  8010bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8010bf:	89 fa                	mov    %edi,%edx
  8010c1:	d3 e0                	shl    %cl,%eax
  8010c3:	89 f1                	mov    %esi,%ecx
  8010c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010cd:	d3 ea                	shr    %cl,%edx
  8010cf:	89 e9                	mov    %ebp,%ecx
  8010d1:	d3 e7                	shl    %cl,%edi
  8010d3:	89 f1                	mov    %esi,%ecx
  8010d5:	d3 e8                	shr    %cl,%eax
  8010d7:	89 e9                	mov    %ebp,%ecx
  8010d9:	09 f8                	or     %edi,%eax
  8010db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010df:	f7 74 24 04          	divl   0x4(%esp)
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010e9:	89 d7                	mov    %edx,%edi
  8010eb:	f7 64 24 08          	mull   0x8(%esp)
  8010ef:	39 d7                	cmp    %edx,%edi
  8010f1:	89 c1                	mov    %eax,%ecx
  8010f3:	89 14 24             	mov    %edx,(%esp)
  8010f6:	72 2c                	jb     801124 <__umoddi3+0x134>
  8010f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010fc:	72 22                	jb     801120 <__umoddi3+0x130>
  8010fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801102:	29 c8                	sub    %ecx,%eax
  801104:	19 d7                	sbb    %edx,%edi
  801106:	89 e9                	mov    %ebp,%ecx
  801108:	89 fa                	mov    %edi,%edx
  80110a:	d3 e8                	shr    %cl,%eax
  80110c:	89 f1                	mov    %esi,%ecx
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	89 e9                	mov    %ebp,%ecx
  801112:	d3 ef                	shr    %cl,%edi
  801114:	09 d0                	or     %edx,%eax
  801116:	89 fa                	mov    %edi,%edx
  801118:	83 c4 14             	add    $0x14,%esp
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    
  80111f:	90                   	nop
  801120:	39 d7                	cmp    %edx,%edi
  801122:	75 da                	jne    8010fe <__umoddi3+0x10e>
  801124:	8b 14 24             	mov    (%esp),%edx
  801127:	89 c1                	mov    %eax,%ecx
  801129:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80112d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801131:	eb cb                	jmp    8010fe <__umoddi3+0x10e>
  801133:	90                   	nop
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80113c:	0f 82 0f ff ff ff    	jb     801051 <__umoddi3+0x61>
  801142:	e9 1a ff ff ff       	jmp    801061 <__umoddi3+0x71>
