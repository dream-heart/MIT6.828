
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 61 00 00 00       	call   800092 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

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
  800059:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800060:	e8 2c 01 00 00       	call   800191 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 7b 0b 00 00       	call   800be5 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 21 0b 00 00       	call   800b93 <sys_env_destroy>
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
  800081:	e8 05 0e 00 00       	call   800e8b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 10             	sub    $0x10,%esp
  80009a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8000a0:	e8 40 0b 00 00       	call   800be5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000a5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b7:	85 db                	test   %ebx,%ebx
  8000b9:	7e 07                	jle    8000c2 <libmain+0x30>
		binaryname = argv[0];
  8000bb:	8b 06                	mov    (%esi),%eax
  8000bd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 a6 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000ce:	e8 07 00 00 00       	call   8000da <exit>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e7:	e8 a7 0a 00 00       	call   800b93 <sys_env_destroy>
}
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    

008000ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 14             	sub    $0x14,%esp
  8000f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f8:	8b 13                	mov    (%ebx),%edx
  8000fa:	8d 42 01             	lea    0x1(%edx),%eax
  8000fd:	89 03                	mov    %eax,(%ebx)
  8000ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800102:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800106:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010b:	75 19                	jne    800126 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80010d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800114:	00 
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 36 0a 00 00       	call   800b56 <sys_cputs>
		b->idx = 0;
  800120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800126:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012a:	83 c4 14             	add    $0x14,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    

00800130 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800139:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800140:	00 00 00 
	b.cnt = 0;
  800143:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800154:	8b 45 08             	mov    0x8(%ebp),%eax
  800157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	c7 04 24 ee 00 80 00 	movl   $0x8000ee,(%esp)
  80016c:	e8 73 01 00 00       	call   8002e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 cd 09 00 00       	call   800b56 <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 87 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    
  8001ab:	66 90                	xchg   %ax,%ax
  8001ad:	66 90                	xchg   %ax,%ax
  8001af:	90                   	nop

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 3c             	sub    $0x3c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d7                	mov    %edx,%edi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 c3                	mov    %eax,%ebx
  8001c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001dd:	39 d9                	cmp    %ebx,%ecx
  8001df:	72 05                	jb     8001e6 <printnum+0x36>
  8001e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e4:	77 69                	ja     80024f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ed:	83 ee 01             	sub    $0x1,%esi
  8001f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800200:	89 c3                	mov    %eax,%ebx
  800202:	89 d6                	mov    %edx,%esi
  800204:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800207:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80020a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80020e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	e8 9c 0d 00 00       	call   800fc0 <__udivdi3>
  800224:	89 d9                	mov    %ebx,%ecx
  800226:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	89 54 24 04          	mov    %edx,0x4(%esp)
  800235:	89 fa                	mov    %edi,%edx
  800237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023a:	e8 71 ff ff ff       	call   8001b0 <printnum>
  80023f:	eb 1b                	jmp    80025c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	8b 45 18             	mov    0x18(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff d3                	call   *%ebx
  80024d:	eb 03                	jmp    800252 <printnum+0xa2>
  80024f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	83 ee 01             	sub    $0x1,%esi
  800255:	85 f6                	test   %esi,%esi
  800257:	7f e8                	jg     800241 <printnum+0x91>
  800259:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800267:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 6c 0e 00 00       	call   8010f0 <__umoddi3>
  800284:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800288:	0f be 80 86 12 80 00 	movsbl 0x801286(%eax),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800295:	ff d0                	call   *%eax
}
  800297:	83 c4 3c             	add    $0x3c,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ae:	73 0a                	jae    8002ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	88 02                	mov    %al,(%edx)
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	e8 02 00 00 00       	call   8002e4 <vprintfmt>
	va_end(ap);
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 3c             	sub    $0x3c,%esp
  8002ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 48 04 00 00    	je     800748 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800300:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	83 c7 01             	add    $0x1,%edi
  80030c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	75 e3                	jne    8002f8 <vprintfmt+0x14>
  800315:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800319:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800320:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800333:	eb 1f                	jmp    800354 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80033c:	eb 16                	jmp    800354 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb 0d                	jmp    800354 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800347:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8d 47 01             	lea    0x1(%edi),%eax
  800357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035a:	0f b6 17             	movzbl (%edi),%edx
  80035d:	0f b6 c2             	movzbl %dl,%eax
  800360:	83 ea 23             	sub    $0x23,%edx
  800363:	80 fa 55             	cmp    $0x55,%dl
  800366:	0f 87 bf 03 00 00    	ja     80072b <vprintfmt+0x447>
  80036c:	0f b6 d2             	movzbl %dl,%edx
  80036f:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800381:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800384:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800388:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80038b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80038e:	83 f9 09             	cmp    $0x9,%ecx
  800391:	77 3c                	ja     8003cf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800393:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800396:	eb e9                	jmp    800381 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 40 04             	lea    0x4(%eax),%eax
  8003a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ac:	eb 27                	jmp    8003d5 <vprintfmt+0xf1>
  8003ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	0f 49 c2             	cmovns %edx,%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c1:	eb 91                	jmp    800354 <vprintfmt+0x70>
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cd:	eb 85                	jmp    800354 <vprintfmt+0x70>
  8003cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	0f 89 75 ff ff ff    	jns    800354 <vprintfmt+0x70>
  8003df:	e9 63 ff ff ff       	jmp    800347 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ea:	e9 65 ff ff ff       	jmp    800354 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800404:	e9 00 ff ff ff       	jmp    800309 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	99                   	cltd   
  800413:	31 d0                	xor    %edx,%eax
  800415:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800417:	83 f8 0f             	cmp    $0xf,%eax
  80041a:	7f 0b                	jg     800427 <vprintfmt+0x143>
  80041c:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800423:	85 d2                	test   %edx,%edx
  800425:	75 20                	jne    800447 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800427:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042b:	c7 44 24 08 9e 12 80 	movl   $0x80129e,0x8(%esp)
  800432:	00 
  800433:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800437:	89 34 24             	mov    %esi,(%esp)
  80043a:	e8 7d fe ff ff       	call   8002bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800442:	e9 c2 fe ff ff       	jmp    800309 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800447:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044b:	c7 44 24 08 a7 12 80 	movl   $0x8012a7,0x8(%esp)
  800452:	00 
  800453:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800457:	89 34 24             	mov    %esi,(%esp)
  80045a:	e8 5d fe ff ff       	call   8002bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800462:	e9 a2 fe ff ff       	jmp    800309 <vprintfmt+0x25>
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80046d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800477:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800479:	85 ff                	test   %edi,%edi
  80047b:	b8 97 12 80 00       	mov    $0x801297,%eax
  800480:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800483:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800487:	0f 84 92 00 00 00    	je     80051f <vprintfmt+0x23b>
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	0f 8e 98 00 00 00    	jle    80052d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	89 54 24 04          	mov    %edx,0x4(%esp)
  800499:	89 3c 24             	mov    %edi,(%esp)
  80049c:	e8 47 03 00 00       	call   8007e8 <strnlen>
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1d3>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 50                	jmp    800539 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1e                	je     80050d <vprintfmt+0x229>
  8004ef:	0f be d2             	movsbl %dl,%edx
  8004f2:	83 ea 20             	sub    $0x20,%edx
  8004f5:	83 fa 5e             	cmp    $0x5e,%edx
  8004f8:	76 13                	jbe    80050d <vprintfmt+0x229>
					putch('?', putdat);
  8004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800508:	ff 55 08             	call   *0x8(%ebp)
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80050d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800510:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	eb 1a                	jmp    800539 <vprintfmt+0x255>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb 0c                	jmp    800539 <vprintfmt+0x255>
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800540:	0f be c2             	movsbl %dl,%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	74 25                	je     80056c <vprintfmt+0x288>
  800547:	85 f6                	test   %esi,%esi
  800549:	78 9e                	js     8004e9 <vprintfmt+0x205>
  80054b:	83 ee 01             	sub    $0x1,%esi
  80054e:	79 99                	jns    8004e9 <vprintfmt+0x205>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	eb 1a                	jmp    800574 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800565:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800567:	83 ef 01             	sub    $0x1,%edi
  80056a:	eb 08                	jmp    800574 <vprintfmt+0x290>
  80056c:	89 df                	mov    %ebx,%edi
  80056e:	8b 75 08             	mov    0x8(%ebp),%esi
  800571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800574:	85 ff                	test   %edi,%edi
  800576:	7f e2                	jg     80055a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057b:	e9 89 fd ff ff       	jmp    800309 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 19                	jle    80059e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 50 04             	mov    0x4(%eax),%edx
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 40 08             	lea    0x8(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
  80059c:	eb 38                	jmp    8005d6 <vprintfmt+0x2f2>
	else if (lflag)
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	74 1b                	je     8005bd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 c1                	mov    %eax,%ecx
  8005ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8005af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bb:	eb 19                	jmp    8005d6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 c1                	mov    %eax,%ecx
  8005c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e5:	0f 89 04 01 00 00    	jns    8006ef <vprintfmt+0x40b>
				putch('-', putdat);
  8005eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fe:	f7 da                	neg    %edx
  800600:	83 d1 00             	adc    $0x0,%ecx
  800603:	f7 d9                	neg    %ecx
  800605:	e9 e5 00 00 00       	jmp    8006ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060a:	83 f9 01             	cmp    $0x1,%ecx
  80060d:	7e 10                	jle    80061f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	8b 48 04             	mov    0x4(%eax),%ecx
  800617:	8d 40 08             	lea    0x8(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
  80061d:	eb 26                	jmp    800645 <vprintfmt+0x361>
	else if (lflag)
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	74 12                	je     800635 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
  800633:	eb 10                	jmp    800645 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063f:	8d 40 04             	lea    0x4(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800645:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80064a:	e9 a0 00 00 00       	jmp    8006ef <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80064f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800653:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80065a:	ff d6                	call   *%esi
			putch('X', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800667:	ff d6                	call   *%esi
			putch('X', putdat);
  800669:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800674:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800679:	e9 8b fc ff ff       	jmp    800309 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800689:	ff d6                	call   *%esi
			putch('x', putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800696:	ff d6                	call   *%esi
			num = (unsigned long long)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006ad:	eb 40                	jmp    8006ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006af:	83 f9 01             	cmp    $0x1,%ecx
  8006b2:	7e 10                	jle    8006c4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c2:	eb 26                	jmp    8006ea <vprintfmt+0x406>
	else if (lflag)
  8006c4:	85 c9                	test   %ecx,%ecx
  8006c6:	74 12                	je     8006da <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d8:	eb 10                	jmp    8006ea <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800702:	89 14 24             	mov    %edx,(%esp)
  800705:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800709:	89 da                	mov    %ebx,%edx
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	e8 9e fa ff ff       	call   8001b0 <printnum>
			break;
  800712:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800715:	e9 ef fb ff ff       	jmp    800309 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800723:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800726:	e9 de fb ff ff       	jmp    800309 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	eb 03                	jmp    80073d <vprintfmt+0x459>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800741:	75 f7                	jne    80073a <vprintfmt+0x456>
  800743:	e9 c1 fb ff ff       	jmp    800309 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800748:	83 c4 3c             	add    $0x3c,%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 28             	sub    $0x28,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 30                	je     8007a1 <vsnprintf+0x51>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 2c                	jle    8007a1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077c:	8b 45 10             	mov    0x10(%ebp),%eax
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078a:	c7 04 24 9f 02 80 00 	movl   $0x80029f,(%esp)
  800791:	e8 4e fb ff ff       	call   8002e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800796:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800799:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	e8 82 ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strlen+0x10>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e4:	75 f7                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	eb 03                	jmp    8007fb <strnlen+0x13>
		n++;
  8007f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1d>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f3                	jne    8007f8 <strnlen+0x10>
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800831:	89 1c 24             	mov    %ebx,(%esp)
  800834:	e8 97 ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800840:	01 d8                	add    %ebx,%eax
  800842:	89 04 24             	mov    %eax,(%esp)
  800845:	e8 bd ff ff ff       	call   800807 <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	5b                   	pop    %ebx
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f2                	mov    %esi,%edx
  800864:	eb 0f                	jmp    800875 <strncpy+0x23>
		*dst++ = *src;
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	0f b6 01             	movzbl (%ecx),%eax
  80086c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 39 01             	cmpb   $0x1,(%ecx)
  800872:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800875:	39 da                	cmp    %ebx,%edx
  800877:	75 ed                	jne    800866 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 c9                	test   %ecx,%ecx
  800895:	75 0b                	jne    8008a2 <strlcpy+0x23>
  800897:	eb 1d                	jmp    8008b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a2:	39 d8                	cmp    %ebx,%eax
  8008a4:	74 0b                	je     8008b1 <strlcpy+0x32>
  8008a6:	0f b6 0a             	movzbl (%edx),%ecx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 ec                	jne    800899 <strlcpy+0x1a>
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 02                	jmp    8008b3 <strlcpy+0x34>
  8008b1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b6:	29 f0                	sub    %esi,%eax
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c5:	eb 06                	jmp    8008cd <strcmp+0x11>
		p++, q++;
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cd:	0f b6 01             	movzbl (%ecx),%eax
  8008d0:	84 c0                	test   %al,%al
  8008d2:	74 04                	je     8008d8 <strcmp+0x1c>
  8008d4:	3a 02                	cmp    (%edx),%al
  8008d6:	74 ef                	je     8008c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 c0             	movzbl %al,%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x17>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 15                	je     800912 <strncmp+0x30>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x26>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
  800910:	eb 05                	jmp    800917 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 07                	jmp    80092d <strchr+0x13>
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 0f                	je     800939 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	eb 07                	jmp    80094e <strfind+0x13>
		if (*s == c)
  800947:	38 ca                	cmp    %cl,%dl
  800949:	74 0a                	je     800955 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	0f b6 10             	movzbl (%eax),%edx
  800951:	84 d2                	test   %dl,%dl
  800953:	75 f2                	jne    800947 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800963:	85 c9                	test   %ecx,%ecx
  800965:	74 36                	je     80099d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800967:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096d:	75 28                	jne    800997 <memset+0x40>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 23                	jne    800997 <memset+0x40>
		c &= 0xFF;
  800974:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d3                	mov    %edx,%ebx
  80097a:	c1 e3 08             	shl    $0x8,%ebx
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 18             	shl    $0x18,%esi
  800982:	89 d0                	mov    %edx,%eax
  800984:	c1 e0 10             	shl    $0x10,%eax
  800987:	09 f0                	or     %esi,%eax
  800989:	09 c2                	or     %eax,%edx
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800992:	fc                   	cld    
  800993:	f3 ab                	rep stos %eax,%es:(%edi)
  800995:	eb 06                	jmp    80099d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	fc                   	cld    
  80099b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b2:	39 c6                	cmp    %eax,%esi
  8009b4:	73 35                	jae    8009eb <memmove+0x47>
  8009b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b9:	39 d0                	cmp    %edx,%eax
  8009bb:	73 2e                	jae    8009eb <memmove+0x47>
		s += n;
		d += n;
  8009bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009c0:	89 d6                	mov    %edx,%esi
  8009c2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ca:	75 13                	jne    8009df <memmove+0x3b>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0e                	jne    8009df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d1:	83 ef 04             	sub    $0x4,%edi
  8009d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009da:	fd                   	std    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb 09                	jmp    8009e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009df:	83 ef 01             	sub    $0x1,%edi
  8009e2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e5:	fd                   	std    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e8:	fc                   	cld    
  8009e9:	eb 1d                	jmp    800a08 <memmove+0x64>
  8009eb:	89 f2                	mov    %esi,%edx
  8009ed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	75 0f                	jne    800a03 <memmove+0x5f>
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 0a                	jne    800a03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 05                	jmp    800a08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a12:	8b 45 10             	mov    0x10(%ebp),%eax
  800a15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 79 ff ff ff       	call   8009a4 <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 55 08             	mov    0x8(%ebp),%edx
  800a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3d:	eb 1a                	jmp    800a59 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3f:	0f b6 02             	movzbl (%edx),%eax
  800a42:	0f b6 19             	movzbl (%ecx),%ebx
  800a45:	38 d8                	cmp    %bl,%al
  800a47:	74 0a                	je     800a53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a49:	0f b6 c0             	movzbl %al,%eax
  800a4c:	0f b6 db             	movzbl %bl,%ebx
  800a4f:	29 d8                	sub    %ebx,%eax
  800a51:	eb 0f                	jmp    800a62 <memcmp+0x35>
		s1++, s2++;
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a59:	39 f2                	cmp    %esi,%edx
  800a5b:	75 e2                	jne    800a3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a74:	eb 07                	jmp    800a7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a76:	38 08                	cmp    %cl,(%eax)
  800a78:	74 07                	je     800a81 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	72 f5                	jb     800a76 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	eb 03                	jmp    800a94 <strtol+0x11>
		s++;
  800a91:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a94:	0f b6 0a             	movzbl (%edx),%ecx
  800a97:	80 f9 09             	cmp    $0x9,%cl
  800a9a:	74 f5                	je     800a91 <strtol+0xe>
  800a9c:	80 f9 20             	cmp    $0x20,%cl
  800a9f:	74 f0                	je     800a91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa1:	80 f9 2b             	cmp    $0x2b,%cl
  800aa4:	75 0a                	jne    800ab0 <strtol+0x2d>
		s++;
  800aa6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb 11                	jmp    800ac1 <strtol+0x3e>
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab5:	80 f9 2d             	cmp    $0x2d,%cl
  800ab8:	75 07                	jne    800ac1 <strtol+0x3e>
		s++, neg = 1;
  800aba:	8d 52 01             	lea    0x1(%edx),%edx
  800abd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ac6:	75 15                	jne    800add <strtol+0x5a>
  800ac8:	80 3a 30             	cmpb   $0x30,(%edx)
  800acb:	75 10                	jne    800add <strtol+0x5a>
  800acd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad1:	75 0a                	jne    800add <strtol+0x5a>
		s += 2, base = 16;
  800ad3:	83 c2 02             	add    $0x2,%edx
  800ad6:	b8 10 00 00 00       	mov    $0x10,%eax
  800adb:	eb 10                	jmp    800aed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800add:	85 c0                	test   %eax,%eax
  800adf:	75 0c                	jne    800aed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae6:	75 05                	jne    800aed <strtol+0x6a>
		s++, base = 8;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800aed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800af2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 0a             	movzbl (%edx),%ecx
  800af8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800afb:	89 f0                	mov    %esi,%eax
  800afd:	3c 09                	cmp    $0x9,%al
  800aff:	77 08                	ja     800b09 <strtol+0x86>
			dig = *s - '0';
  800b01:	0f be c9             	movsbl %cl,%ecx
  800b04:	83 e9 30             	sub    $0x30,%ecx
  800b07:	eb 20                	jmp    800b29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b0c:	89 f0                	mov    %esi,%eax
  800b0e:	3c 19                	cmp    $0x19,%al
  800b10:	77 08                	ja     800b1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b12:	0f be c9             	movsbl %cl,%ecx
  800b15:	83 e9 57             	sub    $0x57,%ecx
  800b18:	eb 0f                	jmp    800b29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b1d:	89 f0                	mov    %esi,%eax
  800b1f:	3c 19                	cmp    $0x19,%al
  800b21:	77 16                	ja     800b39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b23:	0f be c9             	movsbl %cl,%ecx
  800b26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b2c:	7d 0f                	jge    800b3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b37:	eb bc                	jmp    800af5 <strtol+0x72>
  800b39:	89 d8                	mov    %ebx,%eax
  800b3b:	eb 02                	jmp    800b3f <strtol+0xbc>
  800b3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b43:	74 05                	je     800b4a <strtol+0xc7>
		*endptr = (char *) s;
  800b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b4a:	f7 d8                	neg    %eax
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 c3                	mov    %eax,%ebx
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 cb                	mov    %ecx,%ebx
  800bab:	89 cf                	mov    %ecx,%edi
  800bad:	89 ce                	mov    %ecx,%esi
  800baf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 28                	jle    800bdd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bc0:	00 
  800bc1:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd0:	00 
  800bd1:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800bd8:	e8 83 03 00 00       	call   800f60 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdd:	83 c4 2c             	add    $0x2c,%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf5:	89 d1                	mov    %edx,%ecx
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 d6                	mov    %edx,%esi
  800bfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_yield>:

void
sys_yield(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	be 00 00 00 00       	mov    $0x0,%esi
  800c31:	b8 04 00 00 00       	mov    $0x4,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3f:	89 f7                	mov    %esi,%edi
  800c41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 28                	jle    800c6f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c52:	00 
  800c53:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c62:	00 
  800c63:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800c6a:	e8 f1 02 00 00       	call   800f60 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6f:	83 c4 2c             	add    $0x2c,%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	b8 05 00 00 00       	mov    $0x5,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c91:	8b 75 18             	mov    0x18(%ebp),%esi
  800c94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 28                	jle    800cc2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800cad:	00 
  800cae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb5:	00 
  800cb6:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800cbd:	e8 9e 02 00 00       	call   800f60 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc2:	83 c4 2c             	add    $0x2c,%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800d10:	e8 4b 02 00 00       	call   800f60 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800d63:	e8 f8 01 00 00       	call   800f60 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d68:	83 c4 2c             	add    $0x2c,%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 28                	jle    800dbb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d97:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800db6:	e8 a5 01 00 00       	call   800f60 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbb:	83 c4 2c             	add    $0x2c,%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800e09:	e8 52 01 00 00       	call   800f60 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	be 00 00 00 00       	mov    $0x0,%esi
  800e21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e32:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
  800e3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	89 cb                	mov    %ecx,%ebx
  800e51:	89 cf                	mov    %ecx,%edi
  800e53:	89 ce                	mov    %ecx,%esi
  800e55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7e 28                	jle    800e83 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e66:	00 
  800e67:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e76:	00 
  800e77:	c7 04 24 9c 15 80 00 	movl   $0x80159c,(%esp)
  800e7e:	e8 dd 00 00 00       	call   800f60 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e83:	83 c4 2c             	add    $0x2c,%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e91:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e98:	75 44                	jne    800ede <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  800e9a:	a1 04 20 80 00       	mov    0x802004,%eax
  800e9f:	8b 40 48             	mov    0x48(%eax),%eax
  800ea2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800eb1:	ee 
  800eb2:	89 04 24             	mov    %eax,(%esp)
  800eb5:	e8 69 fd ff ff       	call   800c23 <sys_page_alloc>
		if( r < 0)
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 20                	jns    800ede <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  800ebe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec2:	c7 44 24 08 ac 15 80 	movl   $0x8015ac,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 08 16 80 00 	movl   $0x801608,(%esp)
  800ed9:	e8 82 00 00 00       	call   800f60 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  800ee6:	e8 fa fc ff ff       	call   800be5 <sys_getenvid>
  800eeb:	c7 44 24 04 21 0f 80 	movl   $0x800f21,0x4(%esp)
  800ef2:	00 
  800ef3:	89 04 24             	mov    %eax,(%esp)
  800ef6:	e8 c8 fe ff ff       	call   800dc3 <sys_env_set_pgfault_upcall>
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 20                	jns    800f1f <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  800eff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f03:	c7 44 24 08 dc 15 80 	movl   $0x8015dc,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 08 16 80 00 	movl   $0x801608,(%esp)
  800f1a:	e8 41 00 00 00       	call   800f60 <_panic>


}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f21:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f22:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800f27:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f29:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  800f2c:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  800f30:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  800f34:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  800f38:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  800f3b:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  800f3e:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  800f41:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  800f45:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  800f49:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  800f4d:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  800f51:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  800f55:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  800f59:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  800f5d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  800f5e:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  800f5f:	c3                   	ret    

00800f60 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f68:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f6b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f71:	e8 6f fc ff ff       	call   800be5 <sys_getenvid>
  800f76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f79:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f80:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f84:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8c:	c7 04 24 18 16 80 00 	movl   $0x801618,(%esp)
  800f93:	e8 f9 f1 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9f:	89 04 24             	mov    %eax,(%esp)
  800fa2:	e8 89 f1 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  800fa7:	c7 04 24 7a 12 80 00 	movl   $0x80127a,(%esp)
  800fae:	e8 de f1 ff ff       	call   800191 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fb3:	cc                   	int3   
  800fb4:	eb fd                	jmp    800fb3 <_panic+0x53>
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800fce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fdc:	89 ea                	mov    %ebp,%edx
  800fde:	89 0c 24             	mov    %ecx,(%esp)
  800fe1:	75 2d                	jne    801010 <__udivdi3+0x50>
  800fe3:	39 e9                	cmp    %ebp,%ecx
  800fe5:	77 61                	ja     801048 <__udivdi3+0x88>
  800fe7:	85 c9                	test   %ecx,%ecx
  800fe9:	89 ce                	mov    %ecx,%esi
  800feb:	75 0b                	jne    800ff8 <__udivdi3+0x38>
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff2:	31 d2                	xor    %edx,%edx
  800ff4:	f7 f1                	div    %ecx
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	89 e8                	mov    %ebp,%eax
  800ffc:	f7 f6                	div    %esi
  800ffe:	89 c5                	mov    %eax,%ebp
  801000:	89 f8                	mov    %edi,%eax
  801002:	f7 f6                	div    %esi
  801004:	89 ea                	mov    %ebp,%edx
  801006:	83 c4 0c             	add    $0xc,%esp
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	39 e8                	cmp    %ebp,%eax
  801012:	77 24                	ja     801038 <__udivdi3+0x78>
  801014:	0f bd e8             	bsr    %eax,%ebp
  801017:	83 f5 1f             	xor    $0x1f,%ebp
  80101a:	75 3c                	jne    801058 <__udivdi3+0x98>
  80101c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801020:	39 34 24             	cmp    %esi,(%esp)
  801023:	0f 86 9f 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801029:	39 d0                	cmp    %edx,%eax
  80102b:	0f 82 97 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	31 c0                	xor    %eax,%eax
  80103c:	83 c4 0c             	add    $0xc,%esp
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 f8                	mov    %edi,%eax
  80104a:	f7 f1                	div    %ecx
  80104c:	31 d2                	xor    %edx,%edx
  80104e:	83 c4 0c             	add    $0xc,%esp
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	8b 3c 24             	mov    (%esp),%edi
  80105d:	d3 e0                	shl    %cl,%eax
  80105f:	89 c6                	mov    %eax,%esi
  801061:	b8 20 00 00 00       	mov    $0x20,%eax
  801066:	29 e8                	sub    %ebp,%eax
  801068:	89 c1                	mov    %eax,%ecx
  80106a:	d3 ef                	shr    %cl,%edi
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801072:	8b 3c 24             	mov    (%esp),%edi
  801075:	09 74 24 08          	or     %esi,0x8(%esp)
  801079:	89 d6                	mov    %edx,%esi
  80107b:	d3 e7                	shl    %cl,%edi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 3c 24             	mov    %edi,(%esp)
  801082:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801086:	d3 ee                	shr    %cl,%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	d3 e2                	shl    %cl,%edx
  80108c:	89 c1                	mov    %eax,%ecx
  80108e:	d3 ef                	shr    %cl,%edi
  801090:	09 d7                	or     %edx,%edi
  801092:	89 f2                	mov    %esi,%edx
  801094:	89 f8                	mov    %edi,%eax
  801096:	f7 74 24 08          	divl   0x8(%esp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 24 24             	mull   (%esp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 14 24             	mov    %edx,(%esp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	39 c2                	cmp    %eax,%edx
  8010b2:	73 05                	jae    8010b9 <__udivdi3+0xf9>
  8010b4:	3b 34 24             	cmp    (%esp),%esi
  8010b7:	74 1f                	je     8010d8 <__udivdi3+0x118>
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	e9 7a ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cf:	e9 68 ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	83 c4 0c             	add    $0xc,%esp
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    
  8010e4:	66 90                	xchg   %ax,%ax
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	66 90                	xchg   %ax,%ax
  8010ea:	66 90                	xchg   %ax,%ax
  8010ec:	66 90                	xchg   %ax,%ax
  8010ee:	66 90                	xchg   %ax,%ax

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	83 ec 14             	sub    $0x14,%esp
  8010f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801102:	89 c7                	mov    %eax,%edi
  801104:	89 44 24 04          	mov    %eax,0x4(%esp)
  801108:	8b 44 24 30          	mov    0x30(%esp),%eax
  80110c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801110:	89 34 24             	mov    %esi,(%esp)
  801113:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801117:	85 c0                	test   %eax,%eax
  801119:	89 c2                	mov    %eax,%edx
  80111b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111f:	75 17                	jne    801138 <__umoddi3+0x48>
  801121:	39 fe                	cmp    %edi,%esi
  801123:	76 4b                	jbe    801170 <__umoddi3+0x80>
  801125:	89 c8                	mov    %ecx,%eax
  801127:	89 fa                	mov    %edi,%edx
  801129:	f7 f6                	div    %esi
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	31 d2                	xor    %edx,%edx
  80112f:	83 c4 14             	add    $0x14,%esp
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
  801136:	66 90                	xchg   %ax,%ax
  801138:	39 f8                	cmp    %edi,%eax
  80113a:	77 54                	ja     801190 <__umoddi3+0xa0>
  80113c:	0f bd e8             	bsr    %eax,%ebp
  80113f:	83 f5 1f             	xor    $0x1f,%ebp
  801142:	75 5c                	jne    8011a0 <__umoddi3+0xb0>
  801144:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801148:	39 3c 24             	cmp    %edi,(%esp)
  80114b:	0f 87 e7 00 00 00    	ja     801238 <__umoddi3+0x148>
  801151:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801155:	29 f1                	sub    %esi,%ecx
  801157:	19 c7                	sbb    %eax,%edi
  801159:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801161:	8b 44 24 08          	mov    0x8(%esp),%eax
  801165:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801169:	83 c4 14             	add    $0x14,%esp
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
  801170:	85 f6                	test   %esi,%esi
  801172:	89 f5                	mov    %esi,%ebp
  801174:	75 0b                	jne    801181 <__umoddi3+0x91>
  801176:	b8 01 00 00 00       	mov    $0x1,%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	f7 f6                	div    %esi
  80117f:	89 c5                	mov    %eax,%ebp
  801181:	8b 44 24 04          	mov    0x4(%esp),%eax
  801185:	31 d2                	xor    %edx,%edx
  801187:	f7 f5                	div    %ebp
  801189:	89 c8                	mov    %ecx,%eax
  80118b:	f7 f5                	div    %ebp
  80118d:	eb 9c                	jmp    80112b <__umoddi3+0x3b>
  80118f:	90                   	nop
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 fa                	mov    %edi,%edx
  801194:	83 c4 14             	add    $0x14,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	8b 04 24             	mov    (%esp),%eax
  8011a3:	be 20 00 00 00       	mov    $0x20,%esi
  8011a8:	89 e9                	mov    %ebp,%ecx
  8011aa:	29 ee                	sub    %ebp,%esi
  8011ac:	d3 e2                	shl    %cl,%edx
  8011ae:	89 f1                	mov    %esi,%ecx
  8011b0:	d3 e8                	shr    %cl,%eax
  8011b2:	89 e9                	mov    %ebp,%ecx
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	8b 04 24             	mov    (%esp),%eax
  8011bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	d3 e0                	shl    %cl,%eax
  8011c3:	89 f1                	mov    %esi,%ecx
  8011c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011cd:	d3 ea                	shr    %cl,%edx
  8011cf:	89 e9                	mov    %ebp,%ecx
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f1                	mov    %esi,%ecx
  8011d5:	d3 e8                	shr    %cl,%eax
  8011d7:	89 e9                	mov    %ebp,%ecx
  8011d9:	09 f8                	or     %edi,%eax
  8011db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8011df:	f7 74 24 04          	divl   0x4(%esp)
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e9:	89 d7                	mov    %edx,%edi
  8011eb:	f7 64 24 08          	mull   0x8(%esp)
  8011ef:	39 d7                	cmp    %edx,%edi
  8011f1:	89 c1                	mov    %eax,%ecx
  8011f3:	89 14 24             	mov    %edx,(%esp)
  8011f6:	72 2c                	jb     801224 <__umoddi3+0x134>
  8011f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011fc:	72 22                	jb     801220 <__umoddi3+0x130>
  8011fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801202:	29 c8                	sub    %ecx,%eax
  801204:	19 d7                	sbb    %edx,%edi
  801206:	89 e9                	mov    %ebp,%ecx
  801208:	89 fa                	mov    %edi,%edx
  80120a:	d3 e8                	shr    %cl,%eax
  80120c:	89 f1                	mov    %esi,%ecx
  80120e:	d3 e2                	shl    %cl,%edx
  801210:	89 e9                	mov    %ebp,%ecx
  801212:	d3 ef                	shr    %cl,%edi
  801214:	09 d0                	or     %edx,%eax
  801216:	89 fa                	mov    %edi,%edx
  801218:	83 c4 14             	add    $0x14,%esp
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    
  80121f:	90                   	nop
  801220:	39 d7                	cmp    %edx,%edi
  801222:	75 da                	jne    8011fe <__umoddi3+0x10e>
  801224:	8b 14 24             	mov    (%esp),%edx
  801227:	89 c1                	mov    %eax,%ecx
  801229:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80122d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801231:	eb cb                	jmp    8011fe <__umoddi3+0x10e>
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80123c:	0f 82 0f ff ff ff    	jb     801151 <__umoddi3+0x61>
  801242:	e9 1a ff ff ff       	jmp    801161 <__umoddi3+0x71>
