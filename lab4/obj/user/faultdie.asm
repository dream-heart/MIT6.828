
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800060:	e8 36 01 00 00       	call   80019b <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 6a 0b 00 00       	call   800bd4 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 05 0b 00 00       	call   800b77 <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 16 0e 00 00       	call   800e9c <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000a6:	e8 29 0b 00 00       	call   800bd4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 81 0a 00 00       	call   800b77 <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	83 c0 01             	add    $0x1,%eax
  80010e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	75 19                	jne    800130 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800117:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011e:	00 
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 ee 09 00 00       	call   800b18 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	83 c4 14             	add    $0x14,%esp
  800137:	5b                   	pop    %ebx
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800176:	e8 92 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 85 09 00 00       	call   800b18 <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 87 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	75 08                	jne    8001ec <printnum+0x2c>
  8001e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 59                	ja     800245 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f0:	83 eb 01             	sub    $0x1,%ebx
  8001f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fe:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800202:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800206:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020d:	00 
  80020e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800211:	89 04 24             	mov    %eax,(%esp)
  800214:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	e8 10 0d 00 00       	call   800f30 <__udivdi3>
  800220:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800224:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	89 fa                	mov    %edi,%edx
  800231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800234:	e8 87 ff ff ff       	call   8001c0 <printnum>
  800239:	eb 11                	jmp    80024c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023f:	89 34 24             	mov    %esi,(%esp)
  800242:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800245:	83 eb 01             	sub    $0x1,%ebx
  800248:	85 db                	test   %ebx,%ebx
  80024a:	7f ef                	jg     80023b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800250:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800254:	8b 45 10             	mov    0x10(%ebp),%eax
  800257:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800262:	00 
  800263:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	e8 eb 0d 00 00       	call   801060 <__umoddi3>
  800275:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800279:	0f be 80 06 12 80 00 	movsbl 0x801206(%eax),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800286:	83 c4 3c             	add    $0x3c,%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800291:	83 fa 01             	cmp    $0x1,%edx
  800294:	7e 0e                	jle    8002a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	8b 52 04             	mov    0x4(%edx),%edx
  8002a2:	eb 22                	jmp    8002c6 <getuint+0x38>
	else if (lflag)
  8002a4:	85 d2                	test   %edx,%edx
  8002a6:	74 10                	je     8002b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	eb 0e                	jmp    8002c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d7:	73 0a                	jae    8002e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002dc:	88 0a                	mov    %cl,(%edx)
  8002de:	83 c2 01             	add    $0x1,%edx
  8002e1:	89 10                	mov    %edx,(%eax)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800300:	8b 45 08             	mov    0x8(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	e8 02 00 00 00       	call   80030d <vprintfmt>
	va_end(ap);
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 4c             	sub    $0x4c,%esp
  800316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800319:	8b 75 10             	mov    0x10(%ebp),%esi
  80031c:	eb 12                	jmp    800330 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031e:	85 c0                	test   %eax,%eax
  800320:	0f 84 bf 03 00 00    	je     8006e5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800326:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800330:	0f b6 06             	movzbl (%esi),%eax
  800333:	83 c6 01             	add    $0x1,%esi
  800336:	83 f8 25             	cmp    $0x25,%eax
  800339:	75 e3                	jne    80031e <vprintfmt+0x11>
  80033b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80033f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800346:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80035a:	eb 2b                	jmp    800387 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800363:	eb 22                	jmp    800387 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80036c:	eb 19                	jmp    800387 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800371:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800378:	eb 0d                	jmp    800387 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80037d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800380:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	0f b6 16             	movzbl (%esi),%edx
  80038a:	0f b6 c2             	movzbl %dl,%eax
  80038d:	8d 7e 01             	lea    0x1(%esi),%edi
  800390:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800393:	83 ea 23             	sub    $0x23,%edx
  800396:	80 fa 55             	cmp    $0x55,%dl
  800399:	0f 87 28 03 00 00    	ja     8006c7 <vprintfmt+0x3ba>
  80039f:	0f b6 d2             	movzbl %dl,%edx
  8003a2:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  8003a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ac:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003b3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003bb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003bf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c5:	83 fa 09             	cmp    $0x9,%edx
  8003c8:	77 2f                	ja     8003f9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cd:	eb e9                	jmp    8003b8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 50 04             	lea    0x4(%eax),%edx
  8003d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e0:	eb 1a                	jmp    8003fc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e9:	79 9c                	jns    800387 <vprintfmt+0x7a>
  8003eb:	eb 81                	jmp    80036e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f7:	eb 8e                	jmp    800387 <vprintfmt+0x7a>
  8003f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8003fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800400:	79 85                	jns    800387 <vprintfmt+0x7a>
  800402:	e9 73 ff ff ff       	jmp    80037a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800407:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040d:	e9 75 ff ff ff       	jmp    800387 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 04 24             	mov    %eax,(%esp)
  800424:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042a:	e9 01 ff ff ff       	jmp    800330 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	89 c2                	mov    %eax,%edx
  80043c:	c1 fa 1f             	sar    $0x1f,%edx
  80043f:	31 d0                	xor    %edx,%eax
  800441:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 09             	cmp    $0x9,%eax
  800446:	7f 0b                	jg     800453 <vprintfmt+0x146>
  800448:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	75 23                	jne    800476 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800453:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800457:	c7 44 24 08 1e 12 80 	movl   $0x80121e,0x8(%esp)
  80045e:	00 
  80045f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800463:	8b 7d 08             	mov    0x8(%ebp),%edi
  800466:	89 3c 24             	mov    %edi,(%esp)
  800469:	e8 77 fe ff ff       	call   8002e5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800471:	e9 ba fe ff ff       	jmp    800330 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800476:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047a:	c7 44 24 08 27 12 80 	movl   $0x801227,0x8(%esp)
  800481:	00 
  800482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800486:	8b 7d 08             	mov    0x8(%ebp),%edi
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	e8 54 fe ff ff       	call   8002e5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800494:	e9 97 fe ff ff       	jmp    800330 <vprintfmt+0x23>
  800499:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004ad:	85 f6                	test   %esi,%esi
  8004af:	ba 17 12 80 00       	mov    $0x801217,%edx
  8004b4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bb:	0f 8e 8c 00 00 00    	jle    80054d <vprintfmt+0x240>
  8004c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c5:	0f 84 82 00 00 00    	je     80054d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 b1 02 00 00       	call   800788 <strnlen>
  8004d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	89 d3                	mov    %edx,%ebx
  8004ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 0d                	jmp    8004fe <vprintfmt+0x1f1>
					putch(padc, putdat);
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	89 3c 24             	mov    %edi,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 eb 01             	sub    $0x1,%ebx
  8004fe:	85 db                	test   %ebx,%ebx
  800500:	7f ef                	jg     8004f1 <vprintfmt+0x1e4>
  800502:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800505:	89 f3                	mov    %esi,%ebx
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80050a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051a:	29 c2                	sub    %eax,%edx
  80051c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051f:	eb 2c                	jmp    80054d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800525:	74 18                	je     80053f <vprintfmt+0x232>
  800527:	8d 50 e0             	lea    -0x20(%eax),%edx
  80052a:	83 fa 5e             	cmp    $0x5e,%edx
  80052d:	76 10                	jbe    80053f <vprintfmt+0x232>
					putch('?', putdat);
  80052f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800533:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	eb 0a                	jmp    800549 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80053f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80054d:	0f be 06             	movsbl (%esi),%eax
  800550:	83 c6 01             	add    $0x1,%esi
  800553:	85 c0                	test   %eax,%eax
  800555:	74 25                	je     80057c <vprintfmt+0x26f>
  800557:	85 ff                	test   %edi,%edi
  800559:	78 c6                	js     800521 <vprintfmt+0x214>
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	79 c1                	jns    800521 <vprintfmt+0x214>
  800560:	8b 7d 08             	mov    0x8(%ebp),%edi
  800563:	89 de                	mov    %ebx,%esi
  800565:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800568:	eb 1a                	jmp    800584 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800575:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800577:	83 eb 01             	sub    $0x1,%ebx
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x277>
  80057c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057f:	89 de                	mov    %ebx,%esi
  800581:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f e2                	jg     80056a <vprintfmt+0x25d>
  800588:	89 7d 08             	mov    %edi,0x8(%ebp)
  80058b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800590:	e9 9b fd ff ff       	jmp    800330 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800595:	83 f9 01             	cmp    $0x1,%ecx
  800598:	7e 10                	jle    8005aa <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 08             	lea    0x8(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 30                	mov    (%eax),%esi
  8005a5:	8b 78 04             	mov    0x4(%eax),%edi
  8005a8:	eb 26                	jmp    8005d0 <vprintfmt+0x2c3>
	else if (lflag)
  8005aa:	85 c9                	test   %ecx,%ecx
  8005ac:	74 12                	je     8005c0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 30                	mov    (%eax),%esi
  8005b9:	89 f7                	mov    %esi,%edi
  8005bb:	c1 ff 1f             	sar    $0x1f,%edi
  8005be:	eb 10                	jmp    8005d0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	89 f7                	mov    %esi,%edi
  8005cd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	0f 89 ac 00 00 00    	jns    800689 <vprintfmt+0x37c>
				putch('-', putdat);
  8005dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005eb:	f7 de                	neg    %esi
  8005ed:	83 d7 00             	adc    $0x0,%edi
  8005f0:	f7 df                	neg    %edi
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 8d 00 00 00       	jmp    800689 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 88 fc ff ff       	call   80028e <getuint>
  800606:	89 c6                	mov    %eax,%esi
  800608:	89 d7                	mov    %edx,%edi
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060f:	eb 78                	jmp    800689 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800615:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80061c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80062a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80062d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800631:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80063e:	e9 ed fc ff ff       	jmp    800330 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800651:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800655:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800668:	8b 30                	mov    (%eax),%esi
  80066a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 13                	jmp    800689 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800676:	89 ca                	mov    %ecx,%edx
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 0e fc ff ff       	call   80028e <getuint>
  800680:	89 c6                	mov    %eax,%esi
  800682:	89 d7                	mov    %edx,%edi
			base = 16;
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800689:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80068d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800691:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800694:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800698:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069c:	89 34 24             	mov    %esi,(%esp)
  80069f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a3:	89 da                	mov    %ebx,%edx
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	e8 13 fb ff ff       	call   8001c0 <printnum>
			break;
  8006ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b0:	e9 7b fc ff ff       	jmp    800330 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c2:	e9 69 fc ff ff       	jmp    800330 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	eb 03                	jmp    8006da <vprintfmt+0x3cd>
  8006d7:	83 ee 01             	sub    $0x1,%esi
  8006da:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006de:	75 f7                	jne    8006d7 <vprintfmt+0x3ca>
  8006e0:	e9 4b fc ff ff       	jmp    800330 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e5:	83 c4 4c             	add    $0x4c,%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 28             	sub    $0x28,%esp
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 30                	je     80073e <vsnprintf+0x51>
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 2c                	jle    80073e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800719:	8b 45 10             	mov    0x10(%ebp),%eax
  80071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	c7 04 24 c8 02 80 00 	movl   $0x8002c8,(%esp)
  80072e:	e8 da fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800736:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800752:	8b 45 10             	mov    0x10(%ebp),%eax
  800755:	89 44 24 08          	mov    %eax,0x8(%esp)
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 82 ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    
  80076d:	00 00                	add    %al,(%eax)
	...

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strlen+0x10>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	75 f7                	jne    80077d <strlen+0xd>
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	eb 03                	jmp    80079b <strnlen+0x13>
		n++;
  800798:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1d>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f3                	jne    800798 <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ba:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bd:	83 c2 01             	add    $0x1,%edx
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	75 f2                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d1:	89 1c 24             	mov    %ebx,(%esp)
  8007d4:	e8 97 ff ff ff       	call   800770 <strlen>
	strcpy(dst + len, src);
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	e8 bd ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007ea:	89 d8                	mov    %ebx,%eax
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	eb 0f                	jmp    800816 <strncpy+0x24>
		*dst++ = *src;
  800807:	0f b6 1a             	movzbl (%edx),%ebx
  80080a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 3a 01             	cmpb   $0x1,(%edx)
  800810:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	39 f1                	cmp    %esi,%ecx
  800818:	75 ed                	jne    800807 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	85 d2                	test   %edx,%edx
  800830:	75 0a                	jne    80083c <strlcpy+0x1e>
  800832:	eb 1d                	jmp    800851 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800834:	88 18                	mov    %bl,(%eax)
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083c:	83 ea 01             	sub    $0x1,%edx
  80083f:	74 0b                	je     80084c <strlcpy+0x2e>
  800841:	0f b6 19             	movzbl (%ecx),%ebx
  800844:	84 db                	test   %bl,%bl
  800846:	75 ec                	jne    800834 <strlcpy+0x16>
  800848:	89 c2                	mov    %eax,%edx
  80084a:	eb 02                	jmp    80084e <strlcpy+0x30>
  80084c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80084e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800851:	29 f0                	sub    %esi,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800860:	eb 06                	jmp    800868 <strcmp+0x11>
		p++, q++;
  800862:	83 c1 01             	add    $0x1,%ecx
  800865:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	84 c0                	test   %al,%al
  80086d:	74 04                	je     800873 <strcmp+0x1c>
  80086f:	3a 02                	cmp    (%edx),%al
  800871:	74 ef                	je     800862 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 c0             	movzbl %al,%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 09                	jmp    800895 <strncmp+0x18>
		n--, p++, q++;
  80088c:	83 ea 01             	sub    $0x1,%edx
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800895:	85 d2                	test   %edx,%edx
  800897:	74 15                	je     8008ae <strncmp+0x31>
  800899:	0f b6 18             	movzbl (%eax),%ebx
  80089c:	84 db                	test   %bl,%bl
  80089e:	74 04                	je     8008a4 <strncmp+0x27>
  8008a0:	3a 19                	cmp    (%ecx),%bl
  8008a2:	74 e8                	je     80088c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	0f b6 00             	movzbl (%eax),%eax
  8008a7:	0f b6 11             	movzbl (%ecx),%edx
  8008aa:	29 d0                	sub    %edx,%eax
  8008ac:	eb 05                	jmp    8008b3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c0:	eb 07                	jmp    8008c9 <strchr+0x13>
		if (*s == c)
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 0f                	je     8008d5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e1:	eb 07                	jmp    8008ea <strfind+0x13>
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	74 0a                	je     8008f1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f2                	jne    8008e3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	83 ec 0c             	sub    $0xc,%esp
  8008f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 30                	je     80093f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800915:	75 25                	jne    80093c <memset+0x49>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 20                	jne    80093c <memset+0x49>
		c &= 0xFF;
  80091c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800934:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 03                	jmp    80093f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	89 f8                	mov    %edi,%eax
  800941:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800944:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800947:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80094a:	89 ec                	mov    %ebp,%esp
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800957:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800963:	39 c6                	cmp    %eax,%esi
  800965:	73 36                	jae    80099d <memmove+0x4f>
  800967:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	73 2f                	jae    80099d <memmove+0x4f>
		s += n;
		d += n;
  80096e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	f6 c2 03             	test   $0x3,%dl
  800974:	75 1b                	jne    800991 <memmove+0x43>
  800976:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097c:	75 13                	jne    800991 <memmove+0x43>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0e                	jne    800991 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800983:	83 ef 04             	sub    $0x4,%edi
  800986:	8d 72 fc             	lea    -0x4(%edx),%esi
  800989:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098c:	fd                   	std    
  80098d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098f:	eb 09                	jmp    80099a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800991:	83 ef 01             	sub    $0x1,%edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 20                	jmp    8009bd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a3:	75 13                	jne    8009b8 <memmove+0x6a>
  8009a5:	a8 03                	test   $0x3,%al
  8009a7:	75 0f                	jne    8009b8 <memmove+0x6a>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 0a                	jne    8009b8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 05                	jmp    8009bd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009c3:	89 ec                	mov    %ebp,%esp
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 68 ff ff ff       	call   80094e <memmove>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fc:	eb 1a                	jmp    800a18 <memcmp+0x30>
		if (*s1 != *s2)
  8009fe:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a02:	83 c2 01             	add    $0x1,%edx
  800a05:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a0a:	38 c8                	cmp    %cl,%al
  800a0c:	74 0a                	je     800a18 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	0f b6 c9             	movzbl %cl,%ecx
  800a14:	29 c8                	sub    %ecx,%eax
  800a16:	eb 09                	jmp    800a21 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a18:	39 da                	cmp    %ebx,%edx
  800a1a:	75 e2                	jne    8009fe <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
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
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800a54:	0f b6 02             	movzbl (%edx),%eax
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f6                	je     800a51 <strtol+0xe>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f2                	je     800a51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	75 0a                	jne    800a6d <strtol+0x2a>
		s++;
  800a63:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 10                	jmp    800a7d <strtol+0x3a>
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a72:	3c 2d                	cmp    $0x2d,%al
  800a74:	75 07                	jne    800a7d <strtol+0x3a>
		s++, neg = 1;
  800a76:	8d 52 01             	lea    0x1(%edx),%edx
  800a79:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	0f 94 c0             	sete   %al
  800a82:	74 05                	je     800a89 <strtol+0x46>
  800a84:	83 fb 10             	cmp    $0x10,%ebx
  800a87:	75 15                	jne    800a9e <strtol+0x5b>
  800a89:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8c:	75 10                	jne    800a9e <strtol+0x5b>
  800a8e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a92:	75 0a                	jne    800a9e <strtol+0x5b>
		s += 2, base = 16;
  800a94:	83 c2 02             	add    $0x2,%edx
  800a97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9c:	eb 13                	jmp    800ab1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9e:	84 c0                	test   %al,%al
  800aa0:	74 0f                	je     800ab1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa7:	80 3a 30             	cmpb   $0x30,(%edx)
  800aaa:	75 05                	jne    800ab1 <strtol+0x6e>
		s++, base = 8;
  800aac:	83 c2 01             	add    $0x1,%edx
  800aaf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab8:	0f b6 0a             	movzbl (%edx),%ecx
  800abb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x88>
			dig = *s - '0';
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 30             	sub    $0x30,%ecx
  800ac9:	eb 1e                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ace:	80 fb 19             	cmp    $0x19,%bl
  800ad1:	77 08                	ja     800adb <strtol+0x98>
			dig = *s - 'a' + 10;
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 57             	sub    $0x57,%ecx
  800ad9:	eb 0e                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800adb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 14                	ja     800af7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae9:	39 f1                	cmp    %esi,%ecx
  800aeb:	7d 0e                	jge    800afb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800aed:	83 c2 01             	add    $0x1,%edx
  800af0:	0f af c6             	imul   %esi,%eax
  800af3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af5:	eb c1                	jmp    800ab8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af7:	89 c1                	mov    %eax,%ecx
  800af9:	eb 02                	jmp    800afd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b01:	74 05                	je     800b08 <strtol+0xc5>
		*endptr = (char *) s;
  800b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b06:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b08:	89 ca                	mov    %ecx,%edx
  800b0a:	f7 da                	neg    %edx
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 45 c2             	cmovne %edx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
	...

00800b18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b24:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	89 c6                	mov    %eax,%esi
  800b38:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b43:	89 ec                	mov    %ebp,%esp
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b60:	89 d1                	mov    %edx,%ecx
  800b62:	89 d3                	mov    %edx,%ebx
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b73:	89 ec                	mov    %ebp,%esp
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 38             	sub    $0x38,%esp
  800b7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800bc2:	e8 0d 03 00 00       	call   800ed4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd0:	89 ec                	mov    %ebp,%esp
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800be8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 d7                	mov    %edx,%edi
  800bf3:	89 d6                	mov    %edx,%esi
  800bf5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c00:	89 ec                	mov    %ebp,%esp
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_yield>:

void
sys_yield(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c30:	89 ec                	mov    %ebp,%esp
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 38             	sub    $0x38,%esp
  800c3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	be 00 00 00 00       	mov    $0x0,%esi
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 f7                	mov    %esi,%edi
  800c58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 28                	jle    800c86 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c62:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c69:	00 
  800c6a:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800c71:	00 
  800c72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c79:	00 
  800c7a:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800c81:	e8 4e 02 00 00       	call   800ed4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8f:	89 ec                	mov    %ebp,%esp
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 38             	sub    $0x38,%esp
  800c99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	8b 75 18             	mov    0x18(%ebp),%esi
  800caa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 28                	jle    800ce4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc7:	00 
  800cc8:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd7:	00 
  800cd8:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800cdf:	e8 f0 01 00 00       	call   800ed4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ced:	89 ec                	mov    %ebp,%esp
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 38             	sub    $0x38,%esp
  800cf7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cfa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 28                	jle    800d42 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d25:	00 
  800d26:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d35:	00 
  800d36:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800d3d:	e8 92 01 00 00       	call   800ed4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4b:	89 ec                	mov    %ebp,%esp
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 38             	sub    $0x38,%esp
  800d55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 08 00 00 00       	mov    $0x8,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 28                	jle    800da0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d83:	00 
  800d84:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800d8b:	00 
  800d8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d93:	00 
  800d94:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800d9b:	e8 34 01 00 00       	call   800ed4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da9:	89 ec                	mov    %ebp,%esp
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 38             	sub    $0x38,%esp
  800db3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	89 df                	mov    %ebx,%edi
  800dce:	89 de                	mov    %ebx,%esi
  800dd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7e 28                	jle    800dfe <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dda:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de1:	00 
  800de2:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800de9:	00 
  800dea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df1:	00 
  800df2:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800df9:	e8 d6 00 00 00       	call   800ed4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	be 00 00 00 00       	mov    $0x0,%esi
  800e1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3b:	89 ec                	mov    %ebp,%esp
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 38             	sub    $0x38,%esp
  800e45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 28                	jle    800e8f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e72:	00 
  800e73:	c7 44 24 08 48 14 80 	movl   $0x801448,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 65 14 80 00 	movl   $0x801465,(%esp)
  800e8a:	e8 45 00 00 00       	call   800ed4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ea2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ea9:	75 1c                	jne    800ec7 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800eab:	c7 44 24 08 74 14 80 	movl   $0x801474,0x8(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800eba:	00 
  800ebb:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  800ec2:	e8 0d 00 00 00       	call   800ed4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    
  800ed1:	00 00                	add    %al,(%eax)
	...

00800ed4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800edc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800edf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ee5:	e8 ea fc ff ff       	call   800bd4 <sys_getenvid>
  800eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eed:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f00:	c7 04 24 a8 14 80 00 	movl   $0x8014a8,(%esp)
  800f07:	e8 8f f2 ff ff       	call   80019b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f10:	8b 45 10             	mov    0x10(%ebp),%eax
  800f13:	89 04 24             	mov    %eax,(%esp)
  800f16:	e8 1f f2 ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  800f1b:	c7 04 24 fa 11 80 00 	movl   $0x8011fa,(%esp)
  800f22:	e8 74 f2 ff ff       	call   80019b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f27:	cc                   	int3   
  800f28:	eb fd                	jmp    800f27 <_panic+0x53>
  800f2a:	00 00                	add    %al,(%eax)
  800f2c:	00 00                	add    %al,(%eax)
	...

00800f30 <__udivdi3>:
  800f30:	83 ec 1c             	sub    $0x1c,%esp
  800f33:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f37:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f3b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f3f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f43:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f47:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f4b:	85 ff                	test   %edi,%edi
  800f4d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	89 cd                	mov    %ecx,%ebp
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	75 33                	jne    800f90 <__udivdi3+0x60>
  800f5d:	39 f1                	cmp    %esi,%ecx
  800f5f:	77 57                	ja     800fb8 <__udivdi3+0x88>
  800f61:	85 c9                	test   %ecx,%ecx
  800f63:	75 0b                	jne    800f70 <__udivdi3+0x40>
  800f65:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6a:	31 d2                	xor    %edx,%edx
  800f6c:	f7 f1                	div    %ecx
  800f6e:	89 c1                	mov    %eax,%ecx
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	31 d2                	xor    %edx,%edx
  800f74:	f7 f1                	div    %ecx
  800f76:	89 c6                	mov    %eax,%esi
  800f78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 f2                	mov    %esi,%edx
  800f80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	c3                   	ret    
  800f90:	31 d2                	xor    %edx,%edx
  800f92:	31 c0                	xor    %eax,%eax
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	77 e8                	ja     800f80 <__udivdi3+0x50>
  800f98:	0f bd cf             	bsr    %edi,%ecx
  800f9b:	83 f1 1f             	xor    $0x1f,%ecx
  800f9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fa2:	75 2c                	jne    800fd0 <__udivdi3+0xa0>
  800fa4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fa8:	76 04                	jbe    800fae <__udivdi3+0x7e>
  800faa:	39 f7                	cmp    %esi,%edi
  800fac:	73 d2                	jae    800f80 <__udivdi3+0x50>
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	eb c9                	jmp    800f80 <__udivdi3+0x50>
  800fb7:	90                   	nop
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	f7 f1                	div    %ecx
  800fbc:	31 d2                	xor    %edx,%edx
  800fbe:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fca:	83 c4 1c             	add    $0x1c,%esp
  800fcd:	c3                   	ret    
  800fce:	66 90                	xchg   %ax,%ax
  800fd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fda:	89 ea                	mov    %ebp,%edx
  800fdc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	d3 ea                	shr    %cl,%edx
  800fe6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800feb:	09 fa                	or     %edi,%edx
  800fed:	89 f7                	mov    %esi,%edi
  800fef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ff9:	d3 e5                	shl    %cl,%ebp
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	d3 ef                	shr    %cl,%edi
  800fff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801004:	d3 e2                	shl    %cl,%edx
  801006:	89 c1                	mov    %eax,%ecx
  801008:	d3 ee                	shr    %cl,%esi
  80100a:	09 d6                	or     %edx,%esi
  80100c:	89 fa                	mov    %edi,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	f7 74 24 0c          	divl   0xc(%esp)
  801014:	89 d7                	mov    %edx,%edi
  801016:	89 c6                	mov    %eax,%esi
  801018:	f7 e5                	mul    %ebp
  80101a:	39 d7                	cmp    %edx,%edi
  80101c:	72 22                	jb     801040 <__udivdi3+0x110>
  80101e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801022:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801027:	d3 e5                	shl    %cl,%ebp
  801029:	39 c5                	cmp    %eax,%ebp
  80102b:	73 04                	jae    801031 <__udivdi3+0x101>
  80102d:	39 d7                	cmp    %edx,%edi
  80102f:	74 0f                	je     801040 <__udivdi3+0x110>
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	e9 46 ff ff ff       	jmp    800f80 <__udivdi3+0x50>
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	8d 46 ff             	lea    -0x1(%esi),%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	8b 74 24 10          	mov    0x10(%esp),%esi
  801049:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80104d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801051:	83 c4 1c             	add    $0x1c,%esp
  801054:	c3                   	ret    
	...

00801060 <__umoddi3>:
  801060:	83 ec 1c             	sub    $0x1c,%esp
  801063:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801067:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80106b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80106f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801073:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80107b:	85 ed                	test   %ebp,%ebp
  80107d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	89 cf                	mov    %ecx,%edi
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	89 f2                	mov    %esi,%edx
  80108c:	75 1a                	jne    8010a8 <__umoddi3+0x48>
  80108e:	39 f1                	cmp    %esi,%ecx
  801090:	76 4e                	jbe    8010e0 <__umoddi3+0x80>
  801092:	f7 f1                	div    %ecx
  801094:	89 d0                	mov    %edx,%eax
  801096:	31 d2                	xor    %edx,%edx
  801098:	8b 74 24 10          	mov    0x10(%esp),%esi
  80109c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010a4:	83 c4 1c             	add    $0x1c,%esp
  8010a7:	c3                   	ret    
  8010a8:	39 f5                	cmp    %esi,%ebp
  8010aa:	77 54                	ja     801100 <__umoddi3+0xa0>
  8010ac:	0f bd c5             	bsr    %ebp,%eax
  8010af:	83 f0 1f             	xor    $0x1f,%eax
  8010b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b6:	75 60                	jne    801118 <__umoddi3+0xb8>
  8010b8:	3b 0c 24             	cmp    (%esp),%ecx
  8010bb:	0f 87 07 01 00 00    	ja     8011c8 <__umoddi3+0x168>
  8010c1:	89 f2                	mov    %esi,%edx
  8010c3:	8b 34 24             	mov    (%esp),%esi
  8010c6:	29 ce                	sub    %ecx,%esi
  8010c8:	19 ea                	sbb    %ebp,%edx
  8010ca:	89 34 24             	mov    %esi,(%esp)
  8010cd:	8b 04 24             	mov    (%esp),%eax
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	85 c9                	test   %ecx,%ecx
  8010e2:	75 0b                	jne    8010ef <__umoddi3+0x8f>
  8010e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f1                	div    %ecx
  8010ed:	89 c1                	mov    %eax,%ecx
  8010ef:	89 f0                	mov    %esi,%eax
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	f7 f1                	div    %ecx
  8010f5:	8b 04 24             	mov    (%esp),%eax
  8010f8:	f7 f1                	div    %ecx
  8010fa:	eb 98                	jmp    801094 <__umoddi3+0x34>
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	89 f2                	mov    %esi,%edx
  801102:	8b 74 24 10          	mov    0x10(%esp),%esi
  801106:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80110a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	c3                   	ret    
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111d:	89 e8                	mov    %ebp,%eax
  80111f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801124:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801128:	89 fa                	mov    %edi,%edx
  80112a:	d3 e0                	shl    %cl,%eax
  80112c:	89 e9                	mov    %ebp,%ecx
  80112e:	d3 ea                	shr    %cl,%edx
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	09 c2                	or     %eax,%edx
  801137:	8b 44 24 08          	mov    0x8(%esp),%eax
  80113b:	89 14 24             	mov    %edx,(%esp)
  80113e:	89 f2                	mov    %esi,%edx
  801140:	d3 e7                	shl    %cl,%edi
  801142:	89 e9                	mov    %ebp,%ecx
  801144:	d3 ea                	shr    %cl,%edx
  801146:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	d3 e6                	shl    %cl,%esi
  801151:	89 e9                	mov    %ebp,%ecx
  801153:	d3 e8                	shr    %cl,%eax
  801155:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115a:	09 f0                	or     %esi,%eax
  80115c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801160:	f7 34 24             	divl   (%esp)
  801163:	d3 e6                	shl    %cl,%esi
  801165:	89 74 24 08          	mov    %esi,0x8(%esp)
  801169:	89 d6                	mov    %edx,%esi
  80116b:	f7 e7                	mul    %edi
  80116d:	39 d6                	cmp    %edx,%esi
  80116f:	89 c1                	mov    %eax,%ecx
  801171:	89 d7                	mov    %edx,%edi
  801173:	72 3f                	jb     8011b4 <__umoddi3+0x154>
  801175:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801179:	72 35                	jb     8011b0 <__umoddi3+0x150>
  80117b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117f:	29 c8                	sub    %ecx,%eax
  801181:	19 fe                	sbb    %edi,%esi
  801183:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801188:	89 f2                	mov    %esi,%edx
  80118a:	d3 e8                	shr    %cl,%eax
  80118c:	89 e9                	mov    %ebp,%ecx
  80118e:	d3 e2                	shl    %cl,%edx
  801190:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801195:	09 d0                	or     %edx,%eax
  801197:	89 f2                	mov    %esi,%edx
  801199:	d3 ea                	shr    %cl,%edx
  80119b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80119f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a7:	83 c4 1c             	add    $0x1c,%esp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	39 d6                	cmp    %edx,%esi
  8011b2:	75 c7                	jne    80117b <__umoddi3+0x11b>
  8011b4:	89 d7                	mov    %edx,%edi
  8011b6:	89 c1                	mov    %eax,%ecx
  8011b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011bc:	1b 3c 24             	sbb    (%esp),%edi
  8011bf:	eb ba                	jmp    80117b <__umoddi3+0x11b>
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 f5                	cmp    %esi,%ebp
  8011ca:	0f 82 f1 fe ff ff    	jb     8010c1 <__umoddi3+0x61>
  8011d0:	e9 f8 fe ff ff       	jmp    8010cd <__umoddi3+0x6d>
